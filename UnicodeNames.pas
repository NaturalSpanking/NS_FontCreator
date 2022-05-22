unit UnicodeNames;

interface

uses
  SysUtils, Classes;

type
  PUniData = ^TUniData;

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
    empty_data: TUniData;
    // glyph_names_arr: PUniData;
    function search_data(Code: integer): PUniData;
  public
    procedure Free;
    constructor Create;
    destructor Destroy; override;
    property Data[Code: integer]: PUniData read search_data;
  end;

var
  UniNamer: TUnicodeNamer;

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
  arr_size := 0;
  empty_data.Code := 0;
  empty_data.U_plus := '';
  empty_data.Name := 'NO DATA';

  if not FileExists('UnicodeData.txt') then
  begin
    // raise Exception.Create('Missing UnicodeData.txt');
    // Assert(false, 'Missing UnicodeData.txt');
    // что-то это ничего не работает
    // halt;
  end;
  sl := TStringList.Create;
  sl.Clear;
  sl.Delimiter := ';';
  sl.StrictDelimiter := true;
  if FileExists('UnicodeData.txt') then
  begin
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
    CloseFile(f);
  end;
  sl.Free;
end;

destructor TUnicodeNamer.Destroy;
begin
  arr_size := 0;
  inherited Destroy;
end;

procedure TUnicodeNamer.Free;
begin
  if Self <> nil then
    Destroy;
end;

function TUnicodeNamer.search_data(Code: integer): PUniData;
var
  a, b, i: integer;
begin
  if arr_size = 0 then
  begin
    Result := @empty_data;
    exit;
  end;

  b := arr_size;
  a := 0;
  repeat
    i := ((b - a) div 2) + a;
    if glyph_names_arr[i].Code < Code then
      a := i
    else
      b := i;
  until glyph_names_arr[i].Code = Code;
  Result := @glyph_names_arr[i];
end;

initialization

UniNamer := TUnicodeNamer.Create;

finalization

UniNamer.Free;

end.
