unit FontRasterizer;

interface

uses
  SysUtils, Classes, Windows, Graphics, UITypes, ExtCtrls, UnicodeNames,
  uFreeType;

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

  TSymbol = class
    char_code: integer;
    Width: integer;
    Advance: integer;
    Ascender: integer;
    Descender: integer;
    BearingX: integer;
    BearingY: integer;
  private
    BufferSize: integer;
    Buffer: PByte;
  public
    constructor Create(Code: integer);
    destructor Destroy; override;
    procedure Free;
    procedure Render;
    procedure Show(var Image: TImage);
    function Build(var f: TextFile): string;

    procedure AddColAtLeft;
    procedure AddColAtRight;
    procedure DelColAtLeft;
    procedure DelColAtRight;

    procedure MoveUp;
    procedure MoveDown;
    procedure MoveLeft;
    procedure MoveRight;
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

procedure FR_ShowSymbol(symbol: PSymb; var Image: TImage);
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

function FR_BuildSymb(psy: PSymb; var f: TextFile): string;

implementation

var
  fr_face: TFTFace;
  pFont: PByte;
  font_mem_size: integer;

procedure FR_ShowSymbol(symbol: PSymb; var Image: TImage);
var
  i, j: integer;
  X, Y: integer;
  grid_size: integer;
  origin: TPoint;
  bbox: TRect;
  R: TRect;
begin
  // очистка канвы
  Image.Picture.Bitmap.Width := Image.Width;
  Image.Picture.Bitmap.height := Image.height;
  Image.Canvas.Brush.Color := clGray;
  Image.Canvas.FillRect(Rect(0, 0, Image.Width, Image.height));
  if (symbol = nil) or (symbol.Buffer = nil) then
  begin
    Image.Canvas.Font.Name := 'Times New Roman';
    Image.Canvas.Font.Size := 14;
    SetTextAlign(Image.Canvas.Handle, TA_CENTER);
    Image.Canvas.TextOut(Image.Width div 2, Image.height div 2, 'NO DATA');
    exit;
  end;
  // вычисление размера сетки
  grid_size := round(Image.height * 7 / 10 / font_data.height);
  i := round(Image.Width * 5 / 10 / symbol.Width);
  if i < grid_size then
    grid_size := i;
  // вычисление координат
  origin.X := round(Image.Width / 8);
  origin.Y := round(Image.height * 9 / 12);
  bbox.Left := origin.X;
  bbox.Right := origin.X + symbol.Advance * grid_size;
  bbox.Top := origin.Y - symbol.Ascender * grid_size;
  bbox.Bottom := origin.Y - symbol.Descender * grid_size;
  // заливка коробки белым
  Image.Canvas.Brush.Color := clWhite;
  for X := symbol.BearingX to symbol.Width - 1 + symbol.BearingX do
    for Y := 0 to font_data.height - 1 do
    begin
      R := Rect(bbox.Left + X * grid_size, bbox.Top + Y * grid_size,
        bbox.Left + X * grid_size + grid_size, bbox.Top + Y * grid_size +
        grid_size);
      Image.Canvas.FillRect(R);
    end;
  // отрисовка символа
  Image.Canvas.Brush.Color := clBlack;
  for i := 0 to symbol.BufferSize - 1 do
    for j := 0 to 7 do
    begin
      X := i div font_data.bpc + symbol.BearingX;
      Y := 8 * (i mod font_data.bpc) + j;
      R := Rect(bbox.Left + X * grid_size, bbox.Top + Y * grid_size,
        bbox.Left + X * grid_size + grid_size, bbox.Top + Y * grid_size +
        grid_size);
      // if (symbol.Buffer[i] shl j) and 128 > 0 then
      if (symbol.Buffer[i] shr j) and 1 > 0 then // совместимость с GLCD
        Image.Canvas.FillRect(R);
    end;
  // отрисовка сетки
  with Image.Canvas do
  begin
    // горизонтальные черные линии
    pen.Color := clBlack;
    j := origin.Y;
    while j > 0 do // выше базовой
    begin
      MoveTo(0, j);
      LineTo(Image.Width, j);
      dec(j, grid_size);
    end;
    j := origin.Y;
    while j < Image.height do // ниже базовой
    begin
      MoveTo(0, j);
      LineTo(Image.Width, j);
      inc(j, grid_size);
    end;
    // горизонтальные красные линии
    pen.Color := clRed;
    MoveTo(0, origin.Y);
    LineTo(Image.Width, origin.Y);
    // базовая линия горизонтальная
    MoveTo(0, bbox.Top);
    LineTo(Image.Width, bbox.Top); // Ascender
    MoveTo(0, bbox.Bottom);
    LineTo(Image.Width, bbox.Bottom); // Descender
    // вертикальные черные линии
    pen.Color := clBlack;
    j := origin.X;
    while j > 0 do // левее базовой
    begin
      MoveTo(j, 0);
      LineTo(j, Image.height);
      dec(j, grid_size);
    end;
    j := origin.X;
    while j < Image.Width do // правее базовой
    begin
      MoveTo(j, 0);
      LineTo(j, Image.height);
      inc(j, grid_size);
    end;
    // вертикальные красные линии
    pen.Color := clRed;
    MoveTo(origin.X, 0);
    LineTo(origin.X, Image.height);
    // базовая линия вертикальная
    MoveTo(bbox.Right, 0);
    LineTo(bbox.Right, Image.height); // Advance
  end;
end;

function FR_BuildSymb(psy: PSymb; var f: TextFile): string;
var
  UD: PUniData;
  i: integer;
begin
  if psy = nil then
    exit;
  UD := UniNamer.Data[psy.Code];
  writeln(f, '/* ' + 'U+' + UD.U_plus + ' - ' + UD.Name + ' */');
  write(f, 'static const unsigned char _U_' + UD.U_plus + '[] = {');
  Result := '_U_' + UD.U_plus;
  if psy.Buffer = nil then
  begin
    writeln(f, '/* NO DATA */};');
    exit;
  end;
  write(f, '0x', IntToHex(byte(psy.Width)), ', ');
  for i := 0 to psy.BufferSize - 1 do
    write(f, '0x', IntToHex(psy.Buffer[i]), ', ');
  writeln(f, '};');
end;

function FR_CreateFont: P_FR_Font;
begin
  new(font_data);
  Result := font_data;
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
  inc(psy.BearingX);
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
  dec(psy.BearingX);
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
  for i := 0 to (abs(fr_face.glyph.Bitmap.Rows) *
    (fr_face.glyph.Bitmap.Pitch)) - 1 do
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

{ TSymbol }

constructor TSymbol.Create(Code: integer);
begin
  char_code := Code;
  Width := 0;
  Advance := 0;
  Ascender := 0;
  Descender := 0;
  BearingX := 0;
  BearingY := 0;
  BufferSize := 0;
  Buffer := nil;
end;

destructor TSymbol.Destroy;
begin
  if Buffer <> nil then
    FreeMemory(Buffer);
  inherited;
end;

procedure TSymbol.Free;
begin
  if self <> nil then
    Destroy;
end;

procedure TSymbol.AddColAtLeft;
var
  p: PByte;
begin
  p := AllocMem(BufferSize + font_data.bpc);
  CopyMemory(p + font_data.bpc, Buffer, BufferSize);
  FreeMemory(Buffer);
  Buffer := p;
  inc(Width);
  inc(BufferSize, font_data.bpc);
  dec(BearingX);
end;

procedure TSymbol.AddColAtRight;
var
  p: PByte;
begin
  p := AllocMem(BufferSize + font_data.bpc);
  CopyMemory(p, Buffer, BufferSize);
  FreeMemory(Buffer);
  Buffer := p;
  inc(Width);
  inc(BufferSize, font_data.bpc);
end;

function TSymbol.Build(var f: TextFile): string;
var
  UD: PUniData;
  i: integer;
begin
  if self = nil then
    exit;
  UD := UniNamer.Data[self.char_code];
  writeln(f, '/* ' + 'U+' + UD.U_plus + ' - ' + UD.Name + ' */');
  write(f, 'static const unsigned char _U_' + UD.U_plus + '[] = {');
  Result := '_U_' + UD.U_plus;
  if self.Buffer = nil then
  begin
    writeln(f, '/* NO DATA */};');
    exit;
  end;
  write(f, '0x', IntToHex(byte(self.Width)), ', ');
  for i := 0 to self.BufferSize - 1 do
    write(f, '0x', IntToHex(self.Buffer[i]), ', ');
  writeln(f, '};');
end;

procedure TSymbol.DelColAtLeft;
var
  p: PByte;
begin
  p := AllocMem(BufferSize - font_data.bpc);
  CopyMemory(p, Buffer + font_data.bpc, BufferSize - font_data.bpc);
  FreeMemory(Buffer);
  Buffer := p;
  dec(Width);
  dec(BufferSize, font_data.bpc);
  inc(BearingX);
end;

procedure TSymbol.DelColAtRight;
var
  p: PByte;
begin
  p := AllocMem(BufferSize - font_data.bpc);
  CopyMemory(p, Buffer, BufferSize - font_data.bpc);
  FreeMemory(Buffer);
  Buffer := p;
  dec(Width);
  dec(BufferSize, font_data.bpc);
end;

procedure TSymbol.MoveDown;
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
  for i := BufferSize - 1 downto 0 do
  begin
    if ((Buffer[i - 1] and 128) <> 0) and
      ((i - 1) mod font_data.bpc <> font_data.bpc - 1) then
      b := 1
    else
      b := 0;
    if i mod font_data.bpc = font_data.bpc - 1 then
      Buffer[i] := ((Buffer[i] shl 1) or b) and Y
    else
      Buffer[i] := (Buffer[i] shl 1) or b;
  end;
end;

procedure TSymbol.MoveLeft;
var
  i: integer;
begin
  for i := 0 to BufferSize - font_data.bpc do
  begin
    Buffer[i] := Buffer[i + font_data.bpc];
  end;
  FillChar(Buffer[BufferSize - font_data.bpc], font_data.bpc, 0);
end;

procedure TSymbol.MoveRight;
var
  i: integer;
begin
  for i := BufferSize - 1 downto font_data.bpc do
  begin
    Buffer[i] := Buffer[i - font_data.bpc];
  end;
  FillChar(Buffer[0], font_data.bpc, 0);
end;

procedure TSymbol.MoveUp;
var
  i: integer;
  b: integer;
begin
  for i := 0 to BufferSize - 1 do
  begin
    if ((Buffer[i + 1] and 1) <> 0) and ((i + 1) mod font_data.bpc <> 0) then
      b := 128
    else
      b := 0;
    Buffer[i] := (Buffer[i] shr 1) or b;
  end;
end;

procedure TSymbol.Render;
var
  P_x, P_y, i, j, k: integer;
  byte_idx: integer;
  glyph_index: integer;
begin
  if self.Buffer <> nil then
    FreeMemory(self.Buffer);

  glyph_index := fr_face.GetCharIndex(self.char_code);
  fr_face.LoadGlyph(glyph_index, [ftlfMonochrome, ftlfTargetMono, ftlfRender]);
  self.BearingX := fr_face.glyph.Metrics.HorzBearingX div 64;
  self.BearingY := fr_face.glyph.Metrics.HorzBearingY div 64;
  font_data.height := fr_face.Size.Metrics.height div 64;
  self.Width := fr_face.glyph.Bitmap.Width; // это правильнее
  self.Ascender := fr_face.Size.Metrics.Ascender div 64;
  self.Descender := fr_face.Size.Metrics.Descender div 64;
  self.Advance := fr_face.glyph.Metrics.HorzAdvance div 64;
  if self.char_code = 32 then
    self.Width := self.Advance;

  if self.Width > font_data.max_w then
    font_data.max_w := self.Width;
  if self.Width < font_data.min_w then
    font_data.min_w := self.Width;
  self.BufferSize := font_data.bpc * self.Width;
  self.Buffer := AllocMem(self.BufferSize); // не надо очищать
  k := 0;
  for i := 0 to (abs(fr_face.glyph.Bitmap.Rows) *
    (fr_face.glyph.Bitmap.Pitch)) - 1 do
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
        self.Buffer[byte_idx] := self.Buffer[byte_idx] +
          128 shr (7 - P_y mod 8);
        // так есть совместимость с GLCD font creator
      end;
    inc(k);
    if k = fr_face.glyph.Bitmap.Pitch then
      k := 0;
  end;
  fr_face.glyph.Bitmap.Done;
end;

procedure TSymbol.Show(var Image: TImage);
var
  i, j: integer;
  X, Y: integer;
  grid_size: integer;
  origin: TPoint;
  bbox: TRect;
  R: TRect;
begin
  // очистка канвы
  Image.Picture.Bitmap.Width := Image.Width;
  Image.Picture.Bitmap.height := Image.height;
  Image.Canvas.Brush.Color := clGray;
  Image.Canvas.FillRect(Rect(0, 0, Image.Width, Image.height));
  if (self = nil) or (self.Buffer = nil) then
  begin
    Image.Canvas.Font.Name := 'Times New Roman';
    Image.Canvas.Font.Size := 14;
    SetTextAlign(Image.Canvas.Handle, TA_CENTER);
    Image.Canvas.TextOut(Image.Width div 2, Image.height div 2, 'NO DATA');
    exit;
  end;
  // вычисление размера сетки
  grid_size := round(Image.height * 7 / 10 / font_data.height);
  i := round(Image.Width * 5 / 10 / self.Width);
  if i < grid_size then
    grid_size := i;
  // вычисление координат
  origin.X := round(Image.Width / 8);
  origin.Y := round(Image.height * 9 / 12);
  bbox.Left := origin.X;
  bbox.Right := origin.X + self.Advance * grid_size;
  bbox.Top := origin.Y - self.Ascender * grid_size;
  bbox.Bottom := origin.Y - self.Descender * grid_size;
  // заливка коробки белым
  Image.Canvas.Brush.Color := clWhite;
  for X := self.BearingX to self.Width - 1 + self.BearingX do
    for Y := 0 to font_data.height - 1 do
    begin
      R := Rect(bbox.Left + X * grid_size, bbox.Top + Y * grid_size,
        bbox.Left + X * grid_size + grid_size, bbox.Top + Y * grid_size +
        grid_size);
      Image.Canvas.FillRect(R);
    end;
  // отрисовка символа
  Image.Canvas.Brush.Color := clBlack;
  for i := 0 to self.BufferSize - 1 do
    for j := 0 to 7 do
    begin
      X := i div font_data.bpc + self.BearingX;
      Y := 8 * (i mod font_data.bpc) + j;
      R := Rect(bbox.Left + X * grid_size, bbox.Top + Y * grid_size,
        bbox.Left + X * grid_size + grid_size, bbox.Top + Y * grid_size +
        grid_size);
      // if (symbol.Buffer[i] shl j) and 128 > 0 then
      if (self.Buffer[i] shr j) and 1 > 0 then // совместимость с GLCD
        Image.Canvas.FillRect(R);
    end;
  // отрисовка сетки
  with Image.Canvas do
  begin
    // горизонтальные черные линии
    pen.Color := clBlack;
    j := origin.Y;
    while j > 0 do // выше базовой
    begin
      MoveTo(0, j);
      LineTo(Image.Width, j);
      dec(j, grid_size);
    end;
    j := origin.Y;
    while j < Image.height do // ниже базовой
    begin
      MoveTo(0, j);
      LineTo(Image.Width, j);
      inc(j, grid_size);
    end;
    // горизонтальные красные линии
    pen.Color := clRed;
    MoveTo(0, origin.Y);
    LineTo(Image.Width, origin.Y);
    // базовая линия горизонтальная
    MoveTo(0, bbox.Top);
    LineTo(Image.Width, bbox.Top); // Ascender
    MoveTo(0, bbox.Bottom);
    LineTo(Image.Width, bbox.Bottom); // Descender
    // вертикальные черные линии
    pen.Color := clBlack;
    j := origin.X;
    while j > 0 do // левее базовой
    begin
      MoveTo(j, 0);
      LineTo(j, Image.height);
      dec(j, grid_size);
    end;
    j := origin.X;
    while j < Image.Width do // правее базовой
    begin
      MoveTo(j, 0);
      LineTo(j, Image.height);
      inc(j, grid_size);
    end;
    // вертикальные красные линии
    pen.Color := clRed;
    MoveTo(origin.X, 0);
    LineTo(origin.X, Image.height);
    // базовая линия вертикальная
    MoveTo(bbox.Right, 0);
    LineTo(bbox.Right, Image.height); // Advance
  end;
end;

end.
