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

  T_FR_Font = record
    face: TFTFace;
    height: integer;
    bpc: integer;
    min_w: integer;
    max_w: integer;
    pFont: PByte;
    font_mem_size: integer;
    extended_font_name: string;
  end;

var
  font_data: T_FR_Font;

procedure FR_SetFont(const Font: TFont);
procedure FR_Render(symb: PSymb);
procedure FR_AddColAtLeft(psy: PSymb);
procedure FR_AddColAtRight(psy: PSymb);
procedure FR_DelColAtLeft(psy: PSymb);
procedure FR_DelColAtRight(psy: PSymb);

implementation

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
  if font_data.font_mem_size > 0 then
  begin
    font_data.face.Destroy;
    FreeMemory(font_data.pFont);
    font_data.font_mem_size := 0;
  end;
  font_data.font_mem_size := GetFontData(dc, 0, 0, nil,
    font_data.font_mem_size);
  font_data.pFont := GetMemory(font_data.font_mem_size);
  if GetFontData(dc, 0, 0, font_data.pFont, font_data.font_mem_size) = GDI_ERROR
  then
    raise Exception.Create('Failed to get font data.');
  font_data.face := TFTFace.Create(font_data.pFont, font_data.font_mem_size, 0);
  font_data.face.SetPixelSize(0, Font.Size);
  CancelDC(dc);
  DeleteDC(dc);
  font_data.extended_font_name := string(font_data.face.FamilyName) + ' ' +
    string(font_data.face.StyleName) + ' ' + FR_FontStyleToString(Font.style) +
    string(IntToStr(Font.Size));
  font_data.height := font_data.face.Size.Metrics.height div 64;
  font_data.bpc := font_data.height div 8;
  if font_data.bpc * 8 < font_data.height then
    inc(font_data.bpc);
  font_data.max_w := 0;
  font_data.min_w := font_data.face.Size.Metrics.MaxAdvance div 64;
end;

procedure FR_Render(symb: PSymb);
var
  P_x, P_y, i, j, k: integer;
  byte_idx: integer;
  glyph_index: integer;
begin
  if symb.Buffer <> nil then
    FreeMemory(symb.Buffer);

  glyph_index := font_data.face.GetCharIndex(symb.Code);
  font_data.face.LoadGlyph(glyph_index, [ftlfMonochrome, ftlfTargetMono,
    ftlfRender]);
  symb.BearingX := font_data.face.glyph.Metrics.HorzBearingX div 64;
  symb.BearingY := font_data.face.glyph.Metrics.HorzBearingY div 64;
  font_data.height := font_data.face.Size.Metrics.height div 64;
  symb.Width := font_data.face.glyph.Bitmap.Width; // это правильнее
  symb.Ascender := font_data.face.Size.Metrics.Ascender div 64;
  symb.Descender := font_data.face.Size.Metrics.Descender div 64;
  symb.Advance := font_data.face.glyph.Metrics.HorzAdvance div 64;
  if symb.Code = 32 then
    symb.Width := symb.Advance;

  if symb.Width > font_data.max_w then
    font_data.max_w := symb.Width;
  if symb.Width < font_data.min_w then
    font_data.min_w := symb.Width;
  symb.BufferSize := font_data.bpc * symb.Width;
  symb.Buffer := AllocMem(symb.BufferSize); // не надо очищать
  k := 0;
  for i := 0 to (font_data.face.glyph.Bitmap.Rows *
    font_data.face.glyph.Bitmap.Pitch) - 1 do
  begin
    for j := 0 to 7 do
      if font_data.face.glyph.Bitmap.Buffer[i] shl j and 128 > 0 then
      begin
        P_x := k * 8 + j; // это правильнее
        P_y := (font_data.face.Size.Metrics.Ascender -
          font_data.face.glyph.Metrics.HorzBearingY) div 64 +
          i div font_data.face.glyph.Bitmap.Pitch;
        byte_idx := (P_y div 8) + font_data.bpc * P_x;
        // symb.Buffer[byte_idx] := symb.Buffer[byte_idx] + 1 shl (7 - P_y mod 8); так было изначально, символы перевернуты получаются
        symb.Buffer[byte_idx] := symb.Buffer[byte_idx] +
          128 shr (7 - P_y mod 8);
        // так есть совместимость с GLCD font creator
      end;
    inc(k);
    if k = font_data.face.glyph.Bitmap.Pitch then
      k := 0;
  end;
  font_data.face.glyph.Bitmap.Done;
end;

end.
