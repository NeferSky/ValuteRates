program ValuteRatesClient;

uses
  {$IFDEF MEMORY_LEAKS_CHECK}
  FastMM4,
  {$ENDIF }
  {$IFDEF DEBUG}
  ExceptionJCLSupport,
  {$ENDIF }
  FMX.Platform.Win,
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF }
  System.StartUpCopy,
  FMX.Forms,
  JSONHelper in '..\CommonSources\JSONHelper.pas',
  VrConst in '..\CommonSources\VrConst.pas',
  Main in 'Main.pas' {frmMain};

{$R *.res}

{$IFDEF MSWINDOWS}
procedure HideAppOnTaskbar(AMainForm: TForm);
var
  AppHandle: HWND;
begin
  AppHandle := ApplicationHWND;
  ShowWindow(AppHandle, SW_HIDE);
  SetWindowLong(AppHandle, GWL_EXSTYLE, GetWindowLong(AppHandle, GWL_EXSTYLE) and (not WS_EX_APPWINDOW) or WS_EX_TOOLWINDOW);
end;
{$ENDIF}

begin
{$IFDEF MSWINDOWS}
  CreateMutex(nil, True, '{45CA007A-A192-4406-8058-9ED7E910F5B2}');
  if GetLastError = ERROR_ALREADY_EXISTS then
    Exit;
{$ENDIF}

  Application.Initialize;
  {$IFDEF MSWINDOWS}
  HideAppOnTaskbar(frmMain);
{$ENDIF}
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
