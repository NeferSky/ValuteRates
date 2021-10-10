unit Main;

interface

uses
  VrConst, JsonHelper,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.JSON,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  Data.DB,
  uNsGraphFMX;

type
  TfrmMain = class(TForm)
    tmUpdateRates: TTimer;
    mtRates: TFDMemTable;
    mtRatesRateDate: TDateField;
    mtRatesValuteId: TStringField;
    mtRatesValuteName: TStringField;
    mtRatesCharCode: TStringField;
    mtRatesRate: TFloatField;
    mtRatesColor: TLargeintField;
    IdHTTP1: TIdHTTP;
    NsGraph: TNsGraph;
    procedure tmUpdateRatesTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    function GetRates: Boolean;
    procedure RepaintGraph;
    function GetActiveValutes: TStringDynArray;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  {$IFDEF RELEASE}
  frmMain.Transparency := True;
  {$ENDIF}

  frmMain.Top := 0;
  frmMain.Left := Screen.DisplayFromForm(frmMain).Bounds.Width - frmMain.Width;
  frmMain.Height := Screen.DisplayFromForm(frmMain).WorkareaRect.Height;

  NsGraph.BeginDate := Now - 90;
  NsGraph.EndDate := Now;

  tmUpdateRatesTimer(Self);
  tmUpdateRates.Interval := 500;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  mtRates.Close;
end;

procedure TfrmMain.tmUpdateRatesTimer(Sender: TObject);
begin
  try
    try
      NsGraph.DrawGrid;

      if GetRates then
        RepaintGraph;

    except
      NsGraph.DrawGrid;
    end;

  finally
    tmUpdateRates.Interval := 15 * 60 * 1000;
  end;
end;

function TfrmMain.GetActiveValutes: TStringDynArray;
var
  Response: string;
  JsonResponse: TJSONObject;
  ValutesArr: TJSONArray;
  ValutesEnum: TJSONArrayEnumerator;
  I: Integer;
begin
  SetLength(Result, 0);
  Response := IdHTTP1.Get('http://127.0.0.1:' + VR_PORT.ToString + GET_VALUTES);
  JsonResponse := TJSONObject.ParseJSONValue(Response).AsObject;
  try
    if JsonResponse.IsValueExists('error') then
    begin
      ShowMessage(JsonResponse.GetValueStr('error'));
      Exit;
    end;

    ValutesArr := JsonResponse.GetValueArray('valutes');
    SetLength(Result, ValutesArr.Count);
    I := 0;

    ValutesEnum := ValutesArr.GetEnumerator;
    try
      while ValutesEnum.MoveNext do
      begin
        Result[I] := ValutesEnum.CurrentObject.GetValueStr('Id');
        Inc(I);
      end;

    finally
      ValutesEnum.Free;
    end;

  finally
    JsonResponse.Free;
  end;
end;

function TfrmMain.GetRates: Boolean;
var
  Response: string;
  JsonResponse: TJSONObject;
  RatesArr: TJSONArray;
  RatesEnum: TJSONArrayEnumerator;
begin
  Response := IdHTTP1.Get('http://127.0.0.1:' + VR_PORT.ToString + GET_RATES);
  JsonResponse := TJSONObject.ParseJSONValue(Response).AsObject;
  try
    if JsonResponse.IsValueExists('error') then
    begin
      ShowMessage(JsonResponse.GetValueStr('error'));
      Result := False;
      Exit;
    end;

    mtRates.Filtered := False;
    mtRates.Close;
    mtRates.Open;

    RatesArr := JsonResponse.GetValueArray('rates');
    RatesEnum := RatesArr.GetEnumerator;
    try
      while RatesEnum.MoveNext do
      begin
        mtRates.Insert;
        mtRates.FieldByName('RateDate').AsDateTime := RatesEnum.CurrentObject.GetValueDate('RateDate');
        mtRates.FieldByName('ValuteId').AsString := RatesEnum.CurrentObject.GetValueStr('ValuteId');
        mtRates.FieldByName('ValuteName').AsString := RatesEnum.CurrentObject.GetValueStr('ValuteName');
        mtRates.FieldByName('CharCode').AsString := RatesEnum.CurrentObject.GetValueStr('CharCode');
        mtRates.FieldByName('Color').AsLongWord := RatesEnum.CurrentObject.GetValueInt('Color');
        mtRates.FieldByName('Rate').AsFloat := StrToFloat(RatesEnum.CurrentObject.GetValueStr('Rate'));
        mtRates.Post;
      end;

    finally
      RatesEnum.Free;
    end;

    mtRates.IndexFieldNames := 'Rate';

    mtRates.First;
    NsGraph.MinY := Round(mtRates.FieldByName('Rate').AsFloat);
    mtRates.Last;
    NsGraph.MaxY := Round(mtRates.FieldByName('Rate').AsFloat);

    mtRates.IndexFieldNames := 'RateDate;ValuteId';

  finally
    JsonResponse.Free;
  end;

  Result := not(Response.IsEmpty);
end;

procedure TfrmMain.RepaintGraph;
var
  Valute: string;
  Valutes: TStringDynArray;
begin
  Valutes := GetActiveValutes;

  for Valute in Valutes do
    NsGraph.DrawGraph(Valute);
end;

end.
