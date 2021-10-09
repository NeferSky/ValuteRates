unit JSONHelper;

interface

uses
  Classes, SysUtils, JSON, System.Generics.Collections;

type
  TJSONObjectHelper = class Helper for TJSONObject
  public
    //-- GetValue
    function GetValueBool(const Name: string): Boolean;
    function GetValueInt(const Name: string): Int64;
    function GetValueStr(const Name: string): String;
    function GetValueDateTime(const Name: string): TDateTime; overload;
    function GetValueDateTime(const Name: string; FS: TFormatSettings): TDateTime; overload;
    function GetValueDate(const Name: string): TDate; overload;
    function GetValueDate(const Name: string; FS: TFormatSettings): TDate; overload;
    function GetValueTime(const Name: string): TTime; overload;
    function GetValueTime(const Name: string; FS: TFormatSettings): TTime; overload;
    function GetValueArray(const Name: string): TJSONArray;
    function GetValueObject(const Name: string): TJSONObject;

    //-- GetValueDef
    function GetValueBoolDef(const Name: string; Def: Boolean = False): Boolean;
    function GetValueIntDef(const Name: string; Def: Int64 = 0): Int64;
    function GetValueStrDef(const Name: string; Def: String = ''): String;
    function GetValueDateTimeDef(const Name: string; Def: TDateTime = 0): TDateTime; overload;
    function GetValueDateTimeDef(const Name: string; FS: TFormatSettings; Def: TDateTime = 0): TDateTime; overload;
    function GetValueDateDef(const Name: string; Def: TDate = 0): TDate; overload;
    function GetValueDateDef(const Name: string; FS: TFormatSettings; Def: TDate = 0): TDate; overload;
    function GetValueTimeDef(const Name: string; Def: TTime = 0): TTime; overload;
    function GetValueTimeDef(const Name: string; FS: TFormatSettings; Def: TTime = 0): TTime; overload;

    //-- AddPair
    function AddPairBool(const Str: String; const Val: Boolean): TJSONObject;
    function AddPairInt(const Str: String; const Val: Int64): TJSONObject;
    function AddPairStr(const Str: String; const Val: String): TJSONObject;
    function AddPairDateTime(const Str: String; const Val: TDateTime): TJSONObject; overload;
    function AddPairDateTime(const Str: String; const Format: String; const Val: TDateTime): TJSONObject; overload;
    function AddPairDate(const Str: String; const Val: TDate): TJSONObject; overload;
    function AddPairDate(const Str: String; const Format: String; const Val: TDate): TJSONObject; overload;
    function AddPairTime(const Str: String; const Val: TTime): TJSONObject; overload;
    function AddPairTime(const Str: String; const Format: String; const Val: TTime): TJSONObject; overload;
    function AddPairNull(const Str: String): TJSONObject;
    function AddPairArray(const Str: String): TJSONObject;
    function AddPairObject(const Str: String): TJSONObject;

    function IsValueExists(const Name: string): Boolean;
    class function CreateFromStrings(const SourceSl: TStrings; AllAsString: Boolean = False): TJSONObject;
    class function CreateFromCommaText(const str: String; AllAsString: Boolean = False): TJSONObject;
    class function JsonStrToCommaText(const JsonStr: String): String;
    function ToCommaText: String;
  end;

  TJSONArrayEnumeratorHelper = class Helper for TJSONArrayEnumerator
  public
    function CurrentObject: TJSONObject;
  end;

  TJSONValueHelper = class Helper for TJSONValue
    function AsBoolean: Boolean;
    function AsInteger: Int64;
    function AsString: String;
    function AsDateTime: TDateTime; overload;
    function AsDateTime(FS: TFormatSettings): TDateTime; overload;
    function AsDate: TDate; overload;
    function AsDate(FS: TFormatSettings): TDate; overload;
    function AsTime: TTime; overload;
    function AsTime(FS: TFormatSettings): TTime; overload;
    function AsObject: TJSONObject;
    function AsArray: TJSONArray;
  end;

implementation

{ TJSONObjectHelper }

/// <summary>
/// Добавление в JSONObject boolean-пары.
/// </summary>
/// <param name="Str">
/// имя ключа
/// </param>
/// <param name="Val">
/// значение
/// </param>
/// <returns>
/// Возвращает тот же json-объект, с уже добавленной парой.
/// </returns>
function TJSONObjectHelper.AddPairBool(const Str: String; const Val: Boolean): TJSONObject;
begin
  if not Str.IsEmpty then
    AddPair(TJSONPair.Create(Str, TJSONBool.Create(Val)));
  Result := Self;
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Добавление в JSONObject числовой пары.
/// </summary>
/// <param name="Str">
/// имя ключа
/// </param>
/// <param name="Val">
/// значение
/// </param>
/// <returns>
/// Возвращает тот же json-объект, с уже добавленной парой.
/// </returns>
function TJSONObjectHelper.AddPairInt(const Str: String; const Val: Int64): TJSONObject;
begin
  if not Str.IsEmpty then
    AddPair(TJSONPair.Create(Str, TJSONNumber.Create(Val)));
  Result := Self;
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Добавление в JSONObject пары с датой-временем.
/// </summary>
/// <param name="Str">
/// имя ключа
/// </param>
/// <param name="Val">
/// значение
/// </param>
/// <returns>
/// Возвращает тот же json-объект, с уже добавленной парой.
/// </returns>
function TJSONObjectHelper.AddPairDateTime(const Str: String; const Val: TDateTime): TJSONObject;
begin
  Result := AddPairDateTime(Str, 'dd.mm.yyyy hh:nn:ss', Val);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Добавление в JSONObject пары с датой-временем.
/// </summary>
/// <param name="Str">
/// имя ключа
/// </param>
/// <param name="Format">
/// Формат даты-времени в котором надо записать значение
/// </param>
/// <param name="Val">
/// значение
/// </param>
/// <returns>
/// Возвращает тот же json-объект, с уже добавленной парой.
/// </returns>
function TJSONObjectHelper.AddPairDateTime(const Str: String; const Format: String; const Val: TDateTime): TJSONObject;
begin
  if not Str.IsEmpty then
    AddPair(TJSONPair.Create(Str, FormatDateTime(Format, Val)));
  Result := Self;
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Добавление в JSONObject пары с датой.
/// </summary>
/// <param name="Str">
/// имя ключа
/// </param>
/// <param name="Val">
/// значение
/// </param>
/// <returns>
/// Возвращает тот же json-объект, с уже добавленной парой.
/// </returns>
function TJSONObjectHelper.AddPairDate(const Str: String; const Val: TDate): TJSONObject;
begin
  Result := AddPairDate(Str, 'dd.mm.yyyy', Val);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Добавление в JSONObject пары с датой.
/// </summary>
/// <param name="Str">
/// имя ключа
/// </param>
/// <param name="Format">
/// Формат даты в котором надо записать значение
/// </param>
/// <param name="Val">
/// значение
/// </param>
/// <returns>
/// Возвращает тот же json-объект, с уже добавленной парой.
/// </returns>
function TJSONObjectHelper.AddPairDate(const Str: String; const Format: String; const Val: TDate): TJSONObject;
begin
  if not Str.IsEmpty then
    AddPair(TJSONPair.Create(Str, FormatDateTime(Format, Val)));
  Result := Self;
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Добавление в JSONObject пары с временем.
/// </summary>
/// <param name="Str">
/// имя ключа
/// </param>
/// <param name="Val">
/// значение
/// </param>
/// <returns>
/// Возвращает тот же json-объект, с уже добавленной парой.
/// </returns>
function TJSONObjectHelper.AddPairTime(const Str: String; const Val: TTime): TJSONObject;
begin
  Result := AddPairTime(Str, 'hh:nn:ss', Val);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Добавление в JSONObject пары с временем.
/// </summary>
/// <param name="Str">
/// имя ключа
/// </param>
/// <param name="Format">
/// Формат времени в котором надо записать значение
/// </param>
/// <param name="Val">
/// значение
/// </param>
/// <returns>
/// Возвращает тот же json-объект, с уже добавленной парой.
/// </returns>
function TJSONObjectHelper.AddPairTime(const Str: String; const Format: String; const Val: TTime): TJSONObject;
begin
  if not Str.IsEmpty then
    AddPair(TJSONPair.Create(Str, FormatDateTime(Format, Val)));
  Result := Self;
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Добавление в JSONObject null-пары.
/// </summary>
/// <param name="Str">
/// имя ключа
/// </param>
/// <returns>
/// Возвращает тот же json-объект, с уже добавленной парой.
/// </returns>
function TJSONObjectHelper.AddPairNull(const Str: String): TJSONObject;
begin
  if not Str.IsEmpty then
    AddPair(TJSONPair.Create(Str, TJSONNull.Create));
  Result := Self;
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Добавление в JSONObject строковой пары. Экранирует обратный слеш в отличие от AddPair.
/// </summary>
/// <param name="Str">
/// имя ключа
/// </param>
/// <param name="Val">
/// значение
/// </param>
/// <returns>
/// Возвращает тот же json-объект, с уже добавленной парой.
/// </returns>
function TJSONObjectHelper.AddPairStr(const Str, Val: String): TJSONObject;
begin
  if (not Str.IsEmpty) and (not Val.IsEmpty) then
    AddPair(TJSONPair.Create(Str, StringReplace(Val, '\', '\\', [rfReplaceAll])));
  Result := Self;
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Добавление в JSONObject array-пары.
/// </summary>
/// <param name="Str">
/// имя ключа
/// <returns>
/// Возвращает тот же json-объект, с уже добавленной парой.
/// </returns>
function TJSONObjectHelper.AddPairArray(const Str: String): TJSONObject;
begin
  if not Str.IsEmpty then
    AddPair(TJSONPair.Create(Str, TJSONArray.Create));
  Result := Self;
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Добавление в JSONObject object-пары.
/// </summary>
/// <param name="Str">
/// имя ключа
/// <returns>
/// Возвращает тот же json-объект, с уже добавленной парой.
/// </returns>
function TJSONObjectHelper.AddPairObject(const Str: String): TJSONObject;
begin
  if not Str.IsEmpty then
    AddPair(TJSONPair.Create(Str, TJSONObject.Create));
  Result := Self;
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает указанный ключ как boolean.
/// </summary>
/// <param name="Name">
/// имя ключа
/// </param>
/// <returns>
/// Возвращает boolean. Если не удалось прочитать - вернет False.
/// </returns>
function TJSONObjectHelper.GetValueBool(const Name: string): Boolean;
begin
  if IsValueExists(Name) then
    TryGetValue<Boolean>(Name, Result);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает указанный ключ как integer.
/// </summary>
/// <param name="Name">
/// имя ключа
/// </param>
/// <returns>
/// Возвращает integer. Если не удалось прочитать - вернет 0.
/// </returns>
function TJSONObjectHelper.GetValueInt(const Name: string): Int64;
begin
  if IsValueExists(Name) then
    TryGetValue<Int64>(Name, Result);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает указанный ключ как string.
/// </summary>
/// <param name="Name">
/// имя ключа
/// </param>
/// <returns>
/// Возвращает string. Если не удалось прочитать - вернет пустую строку.
/// </returns>
function TJSONObjectHelper.GetValueStr(const Name: string): String;
begin
  if IsValueExists(Name) then
    TryGetValue<String>(Name, Result);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает указанный ключ как TDateTime.
/// </summary>
/// <param name="Name">
/// имя ключа
/// </param>
/// <returns>
/// Возвращает TDateTime. Если не удалось прочитать - вернет 30.12.1899 00:00:00.
/// </returns>
function TJSONObjectHelper.GetValueDateTime(const Name: string): TDateTime;
var
  FS: TFormatSettings;
begin
  FS.ShortDateFormat := 'dd.mm.yyyy';
  FS.DateSeparator := '.';
  FS.ShortTimeFormat := 'hh:nn:ss';
  FS.TimeSeparator := ':';
  Result := GetValueDateTime(Name, FS);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает указанный ключ как TDateTime.
/// </summary>
/// <param name="Name">
/// Имя ключа
/// </param>
/// <param name="FS">
/// Формат даты-времени в значении
/// </param>
/// <returns>
/// Возвращает TDateTime. Если не удалось прочитать - вернет 30.12.1899 00:00:00.
/// </returns>
function TJSONObjectHelper.GetValueDateTime(const Name: string; FS: TFormatSettings): TDateTime;
var
  S: String;
begin
  Result := 0;
  if IsValueExists(Name) then
  begin
    TryGetValue<String>(Name, S);
    try
      Result := StrToDateTime(S, FS);
    except
      on e: EConvertError do
        Result := 0;
    end;
  end;
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает указанный ключ как TDate.
/// </summary>
/// <param name="Name">
/// имя ключа
/// </param>
/// <returns>
/// Возвращает TDate. Если не удалось прочитать - вернет 30.12.1899.
/// </returns>
function TJSONObjectHelper.GetValueDate(const Name: string): TDate;
var
  FS: TFormatSettings;
begin
  FS.ShortDateFormat := 'dd.mm.yyyy';
  FS.DateSeparator := '.';
  Result := GetValueDate(Name, FS);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает указанный ключ как TDate.
/// </summary>
/// <param name="Name">
/// имя ключа
/// </param>
/// <param name="FS">
/// Формат даты в значении
/// </param>
/// <returns>
/// Возвращает TDate. Если не удалось прочитать - вернет 30.12.1899.
/// </returns>
function TJSONObjectHelper.GetValueDate(const Name: string; FS: TFormatSettings): TDate;
var
  S: String;
begin
  Result := 0;
  if IsValueExists(Name) then
  begin
    TryGetValue<String>(Name, S);
    try
      Result := StrToDateTime(S, FS);
    except
      on e: EConvertError do
        Result := 0;
    end;
  end;
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает указанный ключ как TTime.
/// </summary>
/// <param name="Name">
/// имя ключа
/// </param>
/// <returns>
/// Возвращает TTime. Если не удалось прочитать - вернет 00:00:00.
/// </returns>
function TJSONObjectHelper.GetValueTime(const Name: string): TTime;
var
  FS: TFormatSettings;
begin
  FS.ShortTimeFormat := 'hh:nn:ss';
  FS.TimeSeparator := ':';
  Result := GetValueTime(Name, FS);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает указанный ключ как TTime.
/// </summary>
/// <param name="Name">
/// имя ключа
/// </param>
/// <param name="FS">
/// Формат времени в значении
/// </param>
/// <returns>
/// Возвращает TTime. Если не удалось прочитать - вернет 00:00:00.
/// </returns>
function TJSONObjectHelper.GetValueTime(const Name: string; FS: TFormatSettings): TTime;
var
  S: String;
begin
  Result := 0;
  if IsValueExists(Name) then
  begin
    TryGetValue<String>(Name, S);
    try
      Result := StrToTime(S, FS);
    except
      on e: EConvertError do
        Result := 0;
    end;
  end;
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает указанный ключ как TJSONArray.
/// </summary>
/// <param name="Name">
/// имя ключа
/// </param>
/// <returns>
/// Возвращает TJSONArray. Если не удалось прочитать - вернет null.
/// </returns>
function TJSONObjectHelper.GetValueArray(const Name: string): TJSONArray;
begin
  if IsValueExists(Name) then
    TryGetValue<TJSONArray>(Name, Result);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает указанный ключ как TJSONObject.
/// </summary>
/// <param name="Name">
/// имя ключа
/// </param>
/// <returns>
/// Возвращает string. Если не удалось прочитать - вернет null.
/// </returns>
function TJSONObjectHelper.GetValueObject(const Name: string): TJSONObject;
begin
  if IsValueExists(Name) then
    TryGetValue<TJSONObject>(Name, Result);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает указанный ключ как boolean.
/// </summary>
/// <param name="Name">
/// имя ключа
/// </param>
/// <param name="Def">
/// значение по умолчанию
/// </param>
/// <returns>
/// Возвращает boolean. Если не удалось прочитать - подставляет Def.
/// </returns>
function TJSONObjectHelper.GetValueBoolDef(const Name: string; Def: Boolean): Boolean;
begin
  Result := Def;
  if IsValueExists(Name) then
    TryGetValue<Boolean>(Name, Result);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает указанный ключ как integer.
/// </summary>
/// <param name="Name">
/// имя ключа
/// </param>
/// <param name="Def">
/// значение по умолчанию
/// </param>
/// <returns>
/// Возвращает integer. Если не удалось прочитать - подставляет Def.
/// </returns>
function TJSONObjectHelper.GetValueIntDef(const Name: string; Def: Int64): Int64;
begin
  Result := Def;
  if IsValueExists(Name) then
    TryGetValue<Int64>(Name, Result);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает указанный ключ как string.
/// </summary>
/// <param name="Name">
/// имя ключа
/// </param>
/// <param name="Def">
/// значение по умолчанию
/// </param>
/// <returns>
/// Возвращает string. Если не удалось прочитать - подставляет Def.
/// </returns>
function TJSONObjectHelper.GetValueStrDef(const Name: string; Def: String): String;
begin
  Result := Def;
  if IsValueExists(Name) then
    TryGetValue<String>(Name, Result);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает указанный ключ как TDateTime.
/// </summary>
/// <param name="Name">
/// имя ключа
/// </param>
/// <param name="Def">
/// значение по умолчанию
/// </param>
/// <returns>
/// Возвращает TDateTime. Если не удалось прочитать - подставляет Def.
/// </returns>
function TJSONObjectHelper.GetValueDateTimeDef(const Name: string; Def: TDateTime): TDateTime;
var
  FS: TFormatSettings;
begin
  FS.ShortDateFormat := 'dd.mm.yyyy';
  FS.DateSeparator := '.';
  FS.ShortTimeFormat := 'hh:nn:ss';
  FS.TimeSeparator := ':';
  Result := GetValueDateTimeDef(Name, FS, Def);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает указанный ключ как TDateTime.
/// </summary>
/// <param name="Name">
/// имя ключа
/// </param>
/// <param name="FS">
/// Формат даты-времени в значении
/// </param>
/// <param name="Def">
/// значение по умолчанию
/// </param>
/// <returns>
/// Возвращает TDateTime. Если не удалось прочитать - подставляет Def.
/// </returns>
function TJSONObjectHelper.GetValueDateTimeDef(const Name: string; FS: TFormatSettings; Def: TDateTime): TDateTime;
var
  S: String;
begin
  Result := Def;
  if IsValueExists(Name) then
  begin
    TryGetValue<String>(Name, S);
    try
      Result := StrToDateTime(S, FS);
    except
      on e: EConvertError do
        Result := Def;
    end;
  end;
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает указанный ключ как TDate.
/// </summary>
/// <param name="Name">
/// имя ключа
/// </param>
/// <param name="Def">
/// значение по умолчанию
/// </param>
/// <returns>
/// Возвращает TDate. Если не удалось прочитать - подставляет Def.
/// </returns>
function TJSONObjectHelper.GetValueDateDef(const Name: string; Def: TDate): TDate;
var
  FS: TFormatSettings;
begin
  FS.ShortDateFormat := 'dd.mm.yyyy';
  FS.DateSeparator := '.';
  Result := GetValueDateDef(Name, FS, Def);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает указанный ключ как TDate.
/// </summary>
/// <param name="Name">
/// имя ключа
/// </param>
/// <param name="FS">
/// Формат даты в значении
/// </param>
/// <param name="Def">
/// значение по умолчанию
/// </param>
/// <returns>
/// Возвращает TDate. Если не удалось прочитать - подставляет Def.
/// </returns>
function TJSONObjectHelper.GetValueDateDef(const Name: string; FS: TFormatSettings; Def: TDate): TDate;
var
  S: String;
begin
  Result := Def;
  if IsValueExists(Name) then
  begin
    TryGetValue<String>(Name, S);
    try
      Result := StrToDateTime(S, FS);
    except
      on e: EConvertError do
        Result := Def;
    end;
  end;
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает указанный ключ как TTime.
/// </summary>
/// <param name="Name">
/// имя ключа
/// </param>
/// <param name="Def">
/// значение по умолчанию
/// </param>
/// <returns>
/// Возвращает TTime. Если не удалось прочитать - подставляет Def.
/// </returns>
function TJSONObjectHelper.GetValueTimeDef(const Name: string; Def: TTime): TTime;
var
  FS: TFormatSettings;
begin
  FS.ShortTimeFormat := 'hh:nn:ss';
  FS.TimeSeparator := ':';
  Result := GetValueTimeDef(Name, FS, Def);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает указанный ключ как TTime.
/// </summary>
/// <param name="Name">
/// имя ключа
/// </param>
/// <param name="FS">
/// Формат времени в значении
/// </param>
/// <param name="Def">
/// значение по умолчанию
/// </param>
/// <returns>
/// Возвращает TTime. Если не удалось прочитать - подставляет Def.
/// </returns>
function TJSONObjectHelper.GetValueTimeDef(const Name: string; FS: TFormatSettings; Def: TTime): TTime;
var
  S: String;
begin
  Result := Def;
  if IsValueExists(Name) then
  begin
    TryGetValue<String>(Name, S);
    try
      Result := StrToTime(S, FS);
    except
      on e: EConvertError do
        Result := Def;
    end;
  end;
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Проверяет, существует ли указанная пара.
/// </summary>
/// <param name="Name">
/// имя ключа
/// </param>
/// <returns>
/// Возвращает true, если пара существует, False - если нет.
/// </returns>
function TJSONObjectHelper.IsValueExists(const Name: string): Boolean;
begin
  Result := Assigned(GetValue(Name));
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Преобразует переданный Strings в одноуровневый JSONObject.
/// </summary>
/// <param name="sl">
/// strings для преобразования.
/// <param name="AllAsString">
/// Если True - пытается преобразовывать boolean и integer.
/// Если False - возвращает все элементы как String.
/// </param>
/// <returns>
/// Возвращает JSONObject, наполненный парами.
/// </returns>
class function TJSONObjectHelper.CreateFromStrings(const SourceSl: TStrings; AllAsString: Boolean = False): TJSONObject;

  function ProcessObject(const Str: String): TJSONObject;
  var
    sl: TStringList;
    I: Integer;
    ValInt: Int64;
    ValBool: Boolean;
  begin
    Result := TJSONObject.Create;
    sl := TStringList.Create;
    try
      sl.CommaText := Str;
      for I := 0 to sl.Count - 1 do
      begin
        if AllAsString then
          Result.AddPairStr(sl.Names[I], sl.ValueFromIndex[I])

        else
        begin
          if TryStrToInt64(sl.ValueFromIndex[I], ValInt) then
            Result.AddPairInt(sl.Names[I], ValInt)

          else if TryStrToBool(sl.ValueFromIndex[I], ValBool) then
            Result.AddPairBool(sl.Names[I], ValBool)

          else
            Result.AddPair(sl.Names[I], sl.ValueFromIndex[I]);
        end;
      end;

    finally
      sl.Free;
    end;
  end;

  function CorrectString(Str: String): String;
  begin
    if Str.StartsWith(',') then
      Delete(Str, 1, 1);

    if Str.EndsWith(',') then
      Delete(Str, Str.Length, 1);

    // Удваниваем слеши...
    Str := Str.Replace('\', '\\', [rfReplaceAll]);
    // ...но слеши могли принадлежать спец.символам \r\n, возвращаем их на место
    Str := Str.Replace('\\n', '\n', [rfReplaceAll]);
    Str := Str.Replace('\\r', '\r', [rfReplaceAll]);

    Result := Str;
  end;

var
  S: String;
  I: Integer;
  ListArr: TJSONArray;

begin
  Result := TJSONObject.Create;

  // Лист объектов
  if SourceSl.Text.Contains(sLineBreak) then
  begin
    Result.AddPairArray('list');
    ListArr := Result.GetValueArray('list');

    for I := 0 to SourceSl.Count - 1 do
    begin
      S := CorrectString(SourceSl[I]);
      ListArr.AddElement(ProcessObject(S));
    end;
  end

  // Лист - один объект
  else
  begin
    S := CorrectString(SourceSl.Text);
    Result := ProcessObject(S);
  end;
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Преобразует переданный Strings.CommaText в одноуровневый JSONObject.
/// </summary>
/// <param name="sl">
/// CommaText для преобразования.
/// <param name="AllAsString">
/// Если True - пытается преобразовывать boolean и integer.
/// Если False - возвращает все элементы как String.
/// </param>
/// <returns>
/// Возвращает JSONObject, наполненный парами.
/// </returns>
class function TJSONObjectHelper.CreateFromCommaText(const str: String; AllAsString: Boolean = False): TJSONObject;
var
  SourceSl: TStringList;
begin
  SourceSl := TStringList.Create;
  try
    SourceSl.Text := str;
    Result := CreateFromStrings(SourceSl, AllAsString);
  finally
    SourceSl.Free;
  end;
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Преобразует переданную JSON-строку в одноуровневый Strings.CommaText.
/// </summary>
/// <param name="sl">
/// JSON-строка для преобразования.
/// </param>
/// <returns>
/// Возвращает Strings.CommaText.
/// </returns>
class function TJSONObjectHelper.JsonStrToCommaText(const JsonStr: String): String;
var
  ResultSl, slLvl2: TStringList;
  JSONObject: TJSONObject;
  JSONEnum, JSONEnumLvl2: TJSONPairEnumerator;
  JSONPair, JSONPairLvl2: TJSONPair;
  Key, Value: String;
begin
  ResultSl := TStringList.Create;
  try
    JSONObject := TJSONObject.ParseJSONValue(JsonStr) as TJSONObject;
    JSONEnum := JSONObject.GetEnumerator;
    while JSONEnum.MoveNext do
    begin
      JSONPair := JSONEnum.GetCurrent;
      if (JSONPair.JsonValue is TJSONObject) then
      begin
        JSONEnumLvl2 := (JSONPair.JsonValue as TJSONObject).GetEnumerator;
        slLvl2 := TStringList.Create;
        while JSONEnumLvl2.MoveNext do
        begin
          JSONPairLvl2 := JSONEnum.GetCurrent;
          if (JSONPairLvl2.JsonValue is TJSONObject) or
             (JSONPairLvl2.JsonValue is TJSONArray) then
          begin
            // Третий уровень совать некуда
          end
          else
          begin
            Key := JSONPairLvl2.JsonString.Value;
            Value := JSONPairLvl2.JsonValue.GetValue<String>;
            slLvl2.AddPair(Key, Value);
          end;
        end;
        Key := JSONPair.JsonString.Value;
        Value := slLvl2.CommaText;
        ResultSl.AddPair(Key, Value);
      end
      else if (JSONPair.JsonValue is TJSONArray) then
      begin
        // С массивами пока погодим
      end
      else
      begin
        Key := JSONPair.JsonString.Value;
        Value := JSONPair.JsonValue.GetValue<String>;
        ResultSl.AddPair(Key, Value);
      end;
    end;
    Result := ResultSl.CommaText;

  finally
    ResultSl.Free;
  end;
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Преобразует JSONObject в одноуровневый Strings.CommaText.
/// </summary>
/// <returns>
/// Возвращает Strings.CommaText.
/// </returns>
function TJSONObjectHelper.ToCommaText: String;
begin
  Result := JsonStrToCommaText(ToString);
end;

// ----------------------------------------------------------------------------

{ TJSONArrayEnumeratorHelper }

/// <summary>
/// Читает Current Энумератора как TJSONObject.
/// </summary>
/// <returns>
/// Возвращает TJSONObject. Если не удалось прочитать - вернет null.
/// </returns>
function TJSONArrayEnumeratorHelper.CurrentObject: TJSONObject;
begin
  Result := Current as TJSONObject;
end;

// ----------------------------------------------------------------------------

{ TJSONValueHelper }

/// <summary>
/// Читает объект значения как boolean.
/// </summary>
/// <returns>
/// Возвращает boolean. Если не удалось прочитать - вернет False.
/// </returns>
function TJSONValueHelper.AsBoolean: Boolean;
begin
  TryGetValue<Boolean>(Result);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает объект значения как integer.
/// </summary>
/// <returns>
/// Возвращает integer. Если не удалось прочитать - вернет 0.
/// </returns>
function TJSONValueHelper.AsInteger: Int64;
begin
  TryGetValue<Int64>(Result);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает объект значения как string.
/// </summary>
/// <returns>
/// Возвращает string. Если не удалось прочитать - вернет пустую строку.
/// </returns>
function TJSONValueHelper.AsString: String;
begin
  TryGetValue<String>(Result);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает объект значения как TDateTime.
/// </summary>
/// <returns>
/// Возвращает TDateTime. Если не удалось прочитать - вернет 31.12.1899 00:00:00.
/// </returns>
function TJSONValueHelper.AsDateTime: TDateTime;
var
  S: String;
begin
  TryGetValue<String>(S);
  Result := StrToDateTime(S);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает объект значения как TDateTime.
/// </summary>
/// <param name="FS">
/// Формат даты-времени в значении
/// </param>
/// <returns>
/// Возвращает TDateTime. Если не удалось прочитать - вернет 31.12.1899 00:00:00.
/// </returns>
function TJSONValueHelper.AsDateTime(FS: TFormatSettings): TDateTime;
var
  S: String;
begin
  TryGetValue<String>(S);
  Result := StrToDateTime(S, FS);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает объект значения как TDate.
/// </summary>
/// <returns>
/// Возвращает TDate. Если не удалось прочитать - вернет 31.12.1899.
/// </returns>
function TJSONValueHelper.AsDate: TDate;
var
  S: String;
begin
  TryGetValue<String>(S);
  Result := StrToDateTime(S);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает объект значения как TDate.
/// </summary>
/// <param name="FS">
/// Формат даты в значении
/// </param>
/// <returns>
/// Возвращает TDate. Если не удалось прочитать - вернет 31.12.1899.
/// </returns>
function TJSONValueHelper.AsDate(FS: TFormatSettings): TDate;
var
  S: String;
begin
  TryGetValue<String>(S);
  Result := StrToDateTime(S, FS);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает объект значения как TTime.
/// </summary>
/// <returns>
/// Возвращает TTime. Если не удалось прочитать - вернет 00:00:00.
/// </returns>
function TJSONValueHelper.AsTime: TTime;
var
  S: String;
begin
  TryGetValue<String>(S);
  Result := StrToTime(S);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает объект значения как TTime.
/// </summary>
/// <param name="FS">
/// Формат времени в значении
/// </param>
/// <returns>
/// Возвращает TTime. Если не удалось прочитать - вернет 00:00:00.
/// </returns>
function TJSONValueHelper.AsTime(FS: TFormatSettings): TTime;
var
  S: String;
begin
  TryGetValue<String>(S);
  Result := StrToTime(S, FS);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает объект значения как TJSONObject.
/// </summary>
/// <returns>
/// Возвращает TJSONObject. Если не удалось прочитать - вернет null.
/// </returns>
function TJSONValueHelper.AsObject: TJSONObject;
begin
  TryGetValue<TJSONObject>(Result);
end;

// ----------------------------------------------------------------------------

/// <summary>
/// Читает объект значения как TJSONArray.
/// </summary>
/// <returns>
/// Возвращает TJSONArray. Если не удалось прочитать - вернет null.
/// </returns>
function TJSONValueHelper.AsArray: TJSONArray;
begin
  TryGetValue<TJSONArray>(Result);
end;

end.
