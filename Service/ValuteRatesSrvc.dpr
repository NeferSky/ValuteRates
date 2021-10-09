program ValuteRatesSrvc;

uses
  {$IFDEF MEMORY_LEAKS_CHECK}
  FastMM4,
  {$ENDIF }
  {$IFDEF DEBUG}
  ExceptionJCLSupport,
  {$ENDIF }
  Vcl.SvcMgr,
  MainSrvc in 'MainSrvc.pas' {ValuteRates: TService},
  JSONHelper in '..\CommonSources\JSONHelper.pas',
  VrConst in '..\CommonSources\VrConst.pas';

{$R *.RES}

begin
  // Windows 2003 Server requires StartServiceCtrlDispatcher to be
  // called before CoRegisterClassObject, which can be called indirectly
  // by Application.Initialize. TServiceApplication.DelayInitialize allows
  // Application.Initialize to be called from TService.Main (after
  // StartServiceCtrlDispatcher has been called).
  //
  // Delayed initialization of the Application object may affect
  // events which then occur prior to initialization, such as
  // TService.OnCreate. It is only recommended if the ServiceApplication
  // registers a class object with OLE and is intended for use with
  // Windows 2003 Server.
  //
  // Application.DelayInitialize := True;
  //
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TValuteRates, ValuteRates);
  Application.Run;
end.
