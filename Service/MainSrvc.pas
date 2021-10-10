unit MainSrvc;

interface

uses
  VrConst,
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Generics.Collections, System.SyncObjs,
  Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdContext, IdCustomHTTPServer, IdCustomTCPServer, IdHTTPServer,
  MSXML, Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc, Xml.Win.msxmldom,
  Data.DB,
  JSON, JSONHelper, NsLogUtils,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TStringArray = array of string;
  THTTPCommandGetMethod = procedure(const ARequestInfo: TIdHTTPRequestInfo; var aJsonResponse: TJSONObject) of object;

type
  TValuteRates = class(TService)
    IdHTTP1: TIdHTTP;
    tmUpdateRates: TTimer;
    xmlRates: TXMLDocument;
    dbValuteRates: TFDConnection;
    qryUpdate: TFDQuery;
    IdHTTPServer1: TIdHTTPServer;
    qryClient: TFDQuery;
    dbClient: TFDConnection;
    procedure tmUpdateRatesTimer(Sender: TObject);
    procedure IdHTTPServer1CommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceDestroy(Sender: TObject);
  private
    { Private declarations }
    fEndpoints: TDictionary<string, THTTPCommandGetMethod>;
    procedure GetValutes(const ARequestInfo: TIdHTTPRequestInfo; var aJsonResponse: TJSONObject);
    procedure GetRates(const ARequestInfo: TIdHTTPRequestInfo; var aJsonResponse: TJSONObject);

    function GetActiveValutes: TStringArray;
    function GetLastDate(aValute: string): TDate;
    procedure UpdateRates;
    procedure UpdateRate(aValute: string; aDate: TDate);
    function GetXML(aDate: TDate): TXMLDocument;
    function SaveRate(aDate: TDate; const aXml: TXMLDocument; const aValute: string): Boolean;
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  ValuteRates: TValuteRates;

implementation

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  ValuteRates.Controller(CtrlCode);
end;

function TValuteRates.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TValuteRates.ServiceCreate(Sender: TObject);
begin
  fEndpoints := TDictionary<string, THTTPCommandGetMethod>.Create;
  fEndpoints.Add(GET_VALUTES, GetValutes);
  fEndpoints.Add(GET_RATES, GetRates);

  tmUpdateRates.Interval := 1000;
  tmUpdateRates.Enabled := True;

  IdHTTPServer1.DefaultPort := VR_PORT;
  IdHTTPServer1.Active := True;
end;

procedure TValuteRates.ServiceDestroy(Sender: TObject);
begin
  IdHTTPServer1.Active := False;
  fEndpoints.Free;
end;

function TValuteRates.GetActiveValutes: TStringArray;
begin
  try
    qryUpdate.Open('select ID from GET_ACTIVE_VALUTES');
    SetLength(Result, qryUpdate.RecordCount);

    qryUpdate.First;
    while not qryUpdate.Eof do
    begin
      Result[qryUpdate.RecNo - 1] := qryUpdate.FieldByName('ID').AsString;
      qryUpdate.Next;
    end;
    qryUpdate.Close;

  except
    SetLength(Result, 0);
  end;
end;

function TValuteRates.GetLastDate(aValute: string): TDate;
const
  START_DATE: String = '01.01.2021';
begin
  try
    qryUpdate.SQL.Text := 'select LAST_DATE from GET_LAST_DATE(:VALUTE)';
    qryUpdate.Params.ParamByName('VALUTE').Value := aValute;
    qryUpdate.Prepare;
    qryUpdate.Open;

    Result := qryUpdate.FieldByName('LAST_DATE').AsDateTime;
    if Result = 0 then
      Result := StrToDate(START_DATE);
    qryUpdate.Close;

  except
    Result := StrToDate(START_DATE);
  end;
end;

procedure TValuteRates.tmUpdateRatesTimer(Sender: TObject);
begin
  tmUpdateRates.Enabled := False;
  try
    UpdateRates;
  finally
    tmUpdateRates.Interval := 60 * 60 * 1000;
    tmUpdateRates.Enabled := True;
  end;
end;

procedure TValuteRates.UpdateRates;
var
  Valutes: TStringArray;
  Valute: string;
  CurDate: TDate;
begin
  dbValuteRates.Open;
  try
    Valutes := GetActiveValutes;

    for Valute in Valutes do
    begin
      CurDate := GetLastDate(Valute);
      while CurDate < Date do
      begin
        UpdateRate(Valute, CurDate);
        CurDate := CurDate + 1;
      end;
    end;

  finally
    dbValuteRates.Close;
  end;
end;

procedure TValuteRates.UpdateRate(aValute: string; aDate: TDate);
var
  Xml: TXMLDocument;
begin
  Xml := GetXML(aDate);
  try
    SaveRate(aDate, Xml, aValute);
  except
    on e: Exception do
      NsLog('[UpdateRate] ' + DateToStr(aDate) + ' exception: ' + e.Message);
  end;
end;

function TValuteRates.GetXML(aDate: TDate): TXMLDocument;
var
  Request, Response: string;
begin
{
<ValCurs Date="07.08.2021" name="Foreign Currency Market">
  <Valute ID="R01235">
    <NumCode>840</NumCode>
    <CharCode>USD</CharCode>
    <Nominal>1</Nominal>
    <Name>Доллар США</Name>
    <Value>73,1304</Value>
  </Valute>
  <Valute ID="R01239">
    <NumCode>978</NumCode>
    <CharCode>EUR</CharCode>
    <Nominal>1</Nominal>
    <Name>Евро</Name>
    <Value>86,4621</Value>
  </Valute>
</ValCurs>
}
  Result := xmlRates; // Такое некрасивое решение из-за того, что TXMLDocument динамически создается кривой, и жалуется что он не Active
  try
    Request := 'http://www.cbr.ru/scripts/XML_daily.asp?date_req=' + FormatDateTime('dd/mm/yyyy', aDate);
    IdHTTP1.Request.ContentType := 'application/soap+xml; charset=utf-8';
    Response := IdHTTP1.Get(Request);
    //NsLog(Request + sLineBreak + Response);
    Result.LoadFromXML(Response);
  except
    on e: Exception do
    begin
      NsLog('[GetXML] exception: ' + e.Message);
      Result.XML.Clear;
    end;
  end;
  Result.Active := True;
end;

function TValuteRates.SaveRate(aDate: TDate; const aXml: TXMLDocument; const aValute: string): Boolean;
var
  ValCursNode, ValuteNode, CurValuteNode: IXMLNode;
  I: Integer;
  Value: Double;
begin
  Result := False;
  for I := 0 to (aXml.ChildNodes.Count - 1) do
  begin
    aXml.Active := True;
    ValCursNode := aXml.ChildNodes[I];
    if ValCursNode.NodeName = 'ValCurs' then
      break;
    ValCursNode := nil;
  end;

  if Assigned(ValCursNode) then
  begin
    for I := 0 to (ValCursNode.ChildNodes.Count - 1) do
    begin
      ValuteNode := ValCursNode.ChildNodes[I];
      if ValuteNode.Attributes['ID'] = aValute then
      begin
        CurValuteNode := ValuteNode;
        break;
      end;
    end;
  end;

  if Assigned(CurValuteNode) then
  begin
    try
      Value := CurValuteNode.ChildValues['Value'];
      qryUpdate.SQL.Text := 'execute procedure INSERT_RATE(:ADATE, :ANAME, :ARATE)';
      qryUpdate.Prepare;

      qryUpdate.ParamByName('ADATE').Value := aDate;
      qryUpdate.ParamByName('ANAME').Value := aValute;
      qryUpdate.ParamByName('ARATE').Value := Value;
      qryUpdate.ExecSQL;
      qryUpdate.Close;

      Result := True;

    except
      Result := False;
    end;
  end;
end;

procedure TValuteRates.IdHTTPServer1CommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  JsonResponse: TJSONObject;
  Method: THTTPCommandGetMethod;
begin
  try
    if fEndpoints.TryGetValue(ARequestInfo.Document, Method) then
    begin
      if Assigned(Method) then
      begin
        JsonResponse := TJSONObject.Create;
        try
          Method(ARequestInfo, JsonResponse);

          AResponseInfo.ContentType := 'application/json; utf-8';
          AResponseInfo.ContentText := JsonResponse.ToJson;
          AResponseInfo.ResponseNo := 200;

        finally
          JsonResponse.Free;
        end;
      end;
    end;

  except
    on e: Exception do
    begin
      AResponseInfo.ResponseText := e.Message;
      AResponseInfo.ResponseNo := 500;
    end;
  end;
end;

procedure TValuteRates.GetValutes(const ARequestInfo: TIdHTTPRequestInfo; var aJsonResponse: TJSONObject);
var
  Item: TJSONObject;
  SubArr: TJSONArray;
begin
  aJsonResponse.AddPairArray('valutes');
  SubArr := aJsonResponse.GetValueArray('valutes');

  try
    dbClient.Open;
    try
      qryClient.Open('select ID, NAME, CHAR_CODE, COLOR from GET_ACTIVE_VALUTES');

      qryClient.First;
      while not qryClient.Eof do
      begin
        Item := TJSONObject.Create;
        Item.AddPairStr('Id', qryClient.FieldByName('ID').AsString);
        Item.AddPairStr('Name', qryClient.FieldByName('NAME').AsString);
        Item.AddPairStr('CharCode', qryClient.FieldByName('CHAR_CODE').AsString);
        Item.AddPairInt('Color', qryClient.FieldByName('COLOR').AsLongWord);
        SubArr.AddElement(Item);
        qryClient.Next;
      end;

    finally
      dbClient.Close;
    end;

  except
    SubArr.Free;
    aJsonResponse.AddPairArray('valutes');
  end;
end;

procedure TValuteRates.GetRates(const ARequestInfo: TIdHTTPRequestInfo; var aJsonResponse: TJSONObject);
var
  Item: TJSONObject;
  SubArr: TJSONArray;
begin
  aJsonResponse.AddPairArray('rates');
  SubArr := aJsonResponse.GetValueArray('rates');

  try
    dbClient.Open;
    try
      qryClient.Open('select RATE_DATE, VALUTE_ID, VALUTE_NAME, VALUTE_CHAR_CODE, VALUTE_COLOR, RATE from GET_RATES');

      qryClient.First;
      while not qryClient.Eof do
      begin
        Item := TJSONObject.Create;
        Item.AddPairDate('RateDate', qryClient.FieldByName('RATE_DATE').AsDateTime);
        Item.AddPairStr('ValuteId', qryClient.FieldByName('VALUTE_ID').AsString);
        Item.AddPairStr('ValuteName', qryClient.FieldByName('VALUTE_NAME').AsString);
        Item.AddPairStr('CharCode', qryClient.FieldByName('VALUTE_CHAR_CODE').AsString);
        Item.AddPairInt('Color', qryClient.FieldByName('VALUTE_COLOR').AsLongWord);
        Item.AddPairStr('Rate', qryClient.FieldByName('RATE').AsString);
        SubArr.AddElement(Item);
        qryClient.Next;
      end;

    finally
      dbClient.Close;
    end;

  except
    SubArr.Free;
    aJsonResponse.AddPairArray('rates');
  end;
end;

end.
