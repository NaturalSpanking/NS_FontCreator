unit FontRasterizer;

interface

uses
  SysUtils, Classes, uFreeType, Windows, Graphics;

type
  PSymb = ^TSymb;

  TSymb = record
    Code: integer;
    Width: integer;
    Advance: integer;
    Ascender: integer;
    Descender: integer;
    BearingX: integer;
    BearingY: integer;
    BufferSize: integer;
    Buffer: PByte;
  end;

  P_FR_Font = ^T_FR_Font;

  T_FR_Font = record
    MaxAdvance: integer;
    height: integer;
    bpc: integer;
    min_w: integer;
    max_w: integer;
    extended_font_name: string;
  end;

var
  font_data: P_FR_Font;

function FR_CreateFont: P_FR_Font;
procedure FR_SetFont(const Font: TFont);
procedure FR_FreeFont;

procedure FR_Render(symb: PSymb);

function FR_CreateSymb(Code: integer): PSymb;
procedure FR_FreeSymb(symb: PSymb);

procedure FR_AddColAtLeft(psy: PSymb);
procedure FR_AddColAtRight(psy: PSymb);
procedure FR_DelColAtLeft(psy: PSymb);
procedure FR_DelColAtRight(psy: PSymb);

procedure FR_MoveUp(psy: PSymb);
procedure FR_MoveDown(psy: PSymb);
procedure FR_MoveLeft(psy: PSymb);
procedure FR_MoveRight(psy: PSymb);

implementation

var
  fr_face: TFTFace;
  pFont: PByte;
  font_mem_size: integer;

function FR_CreateFont: P_FR_Font;
begin
  new(font_data);
end;

procedure FR_FreeFont;
begin
  if font_mem_size = 0 then
    exit;
  fr_face.glyph.Bitmap.Done;
  fr_face.Destroy;
  FreeMemory(pFont);
  font_mem_size := 0;
end;

function FR_CreateSymb(Code: integer): PSymb;
begin
  Result := new(PSymb);
  Result.Code := Code;
  Result.Width := 0;
  Result.Advance := 0;
  Result.Ascender := 0;
  Result.Descender := 0;
  Result.BearingX := 0;
  Result.BearingY := 0;
  Result.BufferSize := 0;
  Result.Buffer := nil;
end;

procedure FR_FreeSymb(symb: PSymb);
begin
  if symb <> nil then
  begin
    if symb.Buffer <> nil then
      FreeMemory(symb.Buffer);
    Dispose(symb);
  end;
  symb := nil;
end;

procedure FR_MoveLeft(psy: PSymb);
var
  i: integer;
begin
  for i := 0 to psy.BufferSize - font_data.bpc do
  begin
    psy.Buffer[i] := psy.Buffer[i + font_data.bpc];
  end;
  FillChar(psy.Buffer[psy.BufferSize - font_data.bpc], font_data.bpc, 0);
end;

procedure FR_MoveRight(psy: PSymb);
var
  i: integer;
begin
  for i := psy.BufferSize - 1 downto font_data.bpc do
  begin
    psy.Buffer[i] := psy.Buffer[i - font_data.bpc];
  end;
  FillChar(psy.Buffer[0], font_data.bpc, 0);
end;

procedure FR_MoveUp(psy: PSymb);
var
  i: integer;
  b: integer;
begin
  for i := 0 to psy.BufferSize - 1 do
  begin
    if ((psy.Buffer[i + 1] and 1) <> 0) and ((i + 1) mod font_data.bpc <> 0)
    then
      b := 128
    else
      b := 0;
    psy.Buffer[i] := (psy.Buffer[i] shr 1) or b;
  end;
end;

procedure FR_MoveDown(psy: PSymb);
var
  i: integer;
  b: integer;
  Y: integer;
begin
  Y := 0;
  for i := 1 to 8 - (font_data.bpc * 8 - font_data.height) do
  begin
    Y := Y shl 1;
    inc(Y);
  end;
  for i := psy.BufferSize - 1 downto 0 do
  begin
    if ((psy.Buffer[i - 1] and 128) <> 0) and
      ((i - 1) mod font_data.bpc <> font_data.bpc - 1) then
      b := 1
    else
      b := 0;
    if i mod font_data.bpc = font_data.bpc - 1 then
      psy.Buffer[i] := ((psy.Buffer[i] shl 1) or b) and Y
    else
      psy.Buffer[i] := (psy.Buffer[i] shl 1) or b;
  end;
end;

procedure FR_DelColAtLeft(psy: PSymb);
var
  p: PByte;
begin
  p := AllocMem(psy.BufferSize - font_data.bpc);
  CopyMemory(p, psy.Buffer + font_data.bpc, psy.BufferSize - font_data.bpc);
  FreeMemory(psy.Buffer);
  psy.Buffer := p;
  dec(psy.Width);
  dec(psy.BufferSize, font_data.bpc);
end;

procedure FR_DelColAtRight(psy: PSymb);
var
  p: PByte;
begin
  p := AllocMem(psy.BufferSize - font_data.bpc);
  CopyMemory(p, psy.Buffer, psy.BufferSize - font_data.bpc);
  FreeMemory(psy.Buffer);
  psy.Buffer := p;
  dec(psy.Width);
  dec(psy.BufferSize, font_data.bpc);
end;

procedure FR_AddColAtRight(psy: PSymb);
var
  p: PByte;
begin
  p := AllocMem(psy.BufferSize + font_data.bpc);
  CopyMemory(p, psy.Buffer, psy.BufferSize);
  FreeMemory(psy.Buffer);
  psy.Buffer := p;
  inc(psy.Width);
  inc(psy.BufferSize, font_data.bpc);
end;

procedure FR_AddColAtLeft(psy: PSymb);
var
  p: PByte;
begin
  p := AllocMem(psy.BufferSize + font_data.bpc);
  CopyMemory(p + font_data.bpc, psy.Buffer, psy.BufferSize);
  FreeMemory(psy.Buffer);
  psy.Buffer := p;
  inc(psy.Width);
  inc(psy.BufferSize, font_data.bpc);
end;

function FR_FontStyleToString(style: TFontStyles): string;
begin
  Result := '';
  if fsStrikeOut in style then
    Result := Result + 'StrikeOut ';
  if fsUnderline in style then
    Result := Result + 'Underline ';
end;

procedure FR_SetFont(const Font: TFont);
var
  dc: HDC;
begin
  dc := CreateDC('DISPLAY', nil, nil, nil);
  SelectObject(dc, Font.Handle);
  if font_mem_size > 0 then
  begin
    fr_face.Destroy;
    FreeMemory(pFont);
    font_mem_size := 0;
  end;
  font_mem_size := GetFontData(dc, 0, 0, nil, font_mem_size);
  pFont := GetMemory(font_mem_size);
  if GetFontData(dc, 0, 0, pFont, font_mem_size) = GDI_ERROR then
    raise Exception.Create('Failed to get font data.');
  fr_face := TFTFace.Create(pFont, font_mem_size, 0);
  fr_face.SetPixelSize(0, Font.Size);
  CancelDC(dc);
  DeleteDC(dc);
  font_data.extended_font_name := string(fr_face.FamilyName) + ' ' +
    string(fr_face.StyleName) + ' ' + FR_FontStyleToString(Font.style) +
    string(IntToStr(Font.Size));
  font_data.height := fr_face.Size.Metrics.height div 64;
  font_data.MaxAdvance := fr_face.Size.Metrics.MaxAdvance div 64;
  font_data.bpc := font_data.height div 8;
  if font_data.bpc * 8 < font_data.height then
    inc(font_data.bpc);
  font_data.max_w := 0;
  font_data.min_w := fr_face.Size.Metrics.MaxAdvance div 64;
end;

procedure FR_Render(symb: PSymb);
var
  P_x, P_y, i, j, k: integer;
  byte_idx: integer;
  glyph_index: integer;
begin
  if symb.Buffer <> nil then
    FreeMemory(symb.Buffer);

  glyph_index := fr_face.GetCharIndex(symb.Code);
  fr_face.LoadGlyph(glyph_index, [ftlfMonochrome, ftlfTargetMono, ftlfRender]);
  symb.BearingX := fr_face.glyph.Metrics.HorzBearingX div 64;
  symb.BearingY := fr_face.glyph.Metrics.HorzBearingY div 64;
  font_data.height := fr_face.Size.Metrics.height div 64;
  symb.Width := fr_face.glyph.Bitmap.Width; // это правильнее
  symb.Ascender := fr_face.Size.Metrics.Ascender div 64;
  symb.Descender := fr_face.Size.Metrics.Descender div 64;
  symb.Advance := fr_face.glyph.Metrics.HorzAdvance div 64;
  if symb.Code = 32 then
    symb.Width := symb.Advance;

  if symb.Width > font_data.max_w then
    font_data.max_w := symb.Width;
  if symb.Width < font_data.min_w then
    font_data.min_w := symb.Width;
  symb.BufferSize := font_data.bpc * symb.Width;
  symb.Buffer := AllocMem(symb.BufferSize); // не надо очищать
  k := 0;
  for i := 0 to (fr_face.glyph.Bitmap.Rows * fr_face.glyph.Bitmap.Pitch) - 1 do
  begin
    for j := 0 to 7 do
      if fr_face.glyph.Bitmap.Buffer[i] shl j and 128 > 0 then
      begin
        P_x := k * 8 + j; // это правильнее
        P_y := (fr_face.Size.Metrics.Ascender -
          fr_face.glyph.Metrics.HorzBearingY) div 64 +
          i div fr_face.glyph.Bitmap.Pitch;
        byte_idx := (P_y div 8) + font_data.bpc * P_x;
        // symb.Buffer[byte_idx] := symb.Buffer[byte_idx] + 1 shl (7 - P_y mod 8); так было изначально, символы перевернуты получаются
        symb.Buffer[byte_idx] := symb.Buffer[byte_idx] +
          128 shr (7 - P_y mod 8);
        // так есть совместимость с GLCD font creator
      end;
    inc(k);
    if k = fr_face.glyph.Bitmap.Pitch then
      k := 0;
  end;
  fr_face.glyph.Bitmap.Done;
end;

end.
