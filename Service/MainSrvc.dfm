object ValuteRates: TValuteRates
  OldCreateOrder = False
  OnCreate = ServiceCreate
  OnDestroy = ServiceDestroy
  DisplayName = 'NeferSky valute rates service'
  Height = 225
  Width = 273
  object IdHTTP1: TIdHTTP
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 24
    Top = 24
  end
  object tmUpdateRates: TTimer
    Enabled = False
    OnTimer = tmUpdateRatesTimer
    Left = 24
    Top = 152
  end
  object xmlRates: TXMLDocument
    Left = 96
    Top = 152
  end
  object dbValuteRates: TFDConnection
    Params.Strings = (
      'User_Name=SYSDBA'
      'Password=masterkey'
      'Protocol=TCPIP'
      'Server=127.0.0.1'
      'Port=3050'
      'CharacterSet=UTF8'
      'Database=P:\Firebird\VALUTERATES.FDB'
      'DriverID=FB')
    ResourceOptions.AssignedValues = [rvKeepConnection]
    LoginPrompt = False
    Left = 24
    Top = 88
  end
  object qryUpdate: TFDQuery
    Connection = dbValuteRates
    Left = 96
    Top = 88
  end
  object IdHTTPServer1: TIdHTTPServer
    Bindings = <>
    DefaultPort = 4848
    OnCommandGet = IdHTTPServer1CommandGet
    Left = 96
    Top = 24
  end
  object qryClient: TFDQuery
    Connection = dbClient
    Left = 96
    Top = 152
  end
  object dbClient: TFDConnection
    Params.Strings = (
      'Database=P:\Firebird\VALUTERATES.FDB'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'Protocol=TCPIP'
      'Server=127.0.0.1'
      'CharacterSet=UTF8'
      'DriverID=FB')
    LoginPrompt = False
    Left = 24
    Top = 152
  end
end
