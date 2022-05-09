unit UnicodeNames;

interface

uses
  SysUtils, Classes;

type

  TUniData = record
    Code: integer;
    U_plus: string;
    Name: string; // [60]
  end;

  TUnicodeNamer = class
  private
    arr_size: integer;
    // [0 .. 34627]
    glyph_names_arr: array of TUniData;
    function search_data(Code: integer): TUniData;
  public
    constructor Create;
    destructor Destroy; override;
    property Data[Code: integer]: TUniData read search_data;
  end;

implementation

{ TUnicodeNamer }

constructor TUnicodeNamer.Create;
var
  f: TextFile;
  sl: TStringList;
  S: string;
  i: integer;
begin
  inherited Create;
  if not FileExists('UnicodeData.txt') then
    raise Exception.Create('Missing UnicodeData.txt');

  sl := TStringList.Create;
  sl.Clear;
  sl.Delimiter := ';';
  sl.StrictDelimiter := true;
  AssignFile(f, 'UnicodeData.txt');
  reset(f);
  arr_size := 0;
  while not EOF(f) do
  begin
    readln(f);
    inc(arr_size);
  end;
  SetLength(glyph_names_arr, arr_size + 1);
  CloseFile(f);
  reset(f);
  i := 0;
  repeat
    readln(f, S);
    sl.DelimitedText := S;
    glyph_names_arr[i].Code := StrToInt('$' + sl[0]);
    glyph_names_arr[i].Name := sl[1];
    glyph_names_arr[i].U_plus := sl[0];
    inc(i);
  until EOF(f);
  sl.Free;
  CloseFile(f);
end;

destructor TUnicodeNamer.Destroy;
begin
  inherited Destroy;
end;

function TUnicodeNamer.search_data(Code: integer): TUniData;
var
  a, b, i: integer;
begin
  b := arr_size;
  a := 0;
  repeat
    i := ((b - a) div 2) + a;
    if glyph_names_arr[i].Code < Code then
      a := i
    else
      b := i;
  until glyph_names_arr[i].Code = Code;
  Result := glyph_names_arr[i];
  // Result := glyph_names_arr[i].U_plus + ' - ' + glyph_names_arr[i].Name;
end;

end.
