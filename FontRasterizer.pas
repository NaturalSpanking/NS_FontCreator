unit FontRasterizer;

interface

uses
  SysUtils, Classes, Windows, Graphics, UITypes, ExtCtrls, UnicodeNames,
  uFreeType;

type

  TSymbol = class
  private
    sData: record
      char_code: integer;
      Width: integer;
      Advance: integer;
      BearingX: integer;
      BearingY: integer;
      BufferSize: integer;
    end;

    Buffer: PByte;
  public
    property Code: integer read sData.char_code;

    constructor Create(Code: integer);
    destructor Destroy; override;
    procedure Free;
    procedure Render;
    procedure Show(var Image: TImage);
    function Build(var f: TextFile): string;
    procedure WriteToFile(var f: file);
    procedure ReadFromFile(var f: file);

    procedure AddColAtLeft;
    procedure AddColAtRight;
    procedure DelColAtLeft;
    procedure DelColAtRight;

    procedure MoveUp;
    procedure MoveDown;
    procedure MoveLeft;
    procedure MoveRight;

    procedure CopyData(Source: TSymbol);
    procedure ChangePixel(Image: TImage; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
  end;

  P_FR_Font = ^T_FR_Font;

  T_FR_Font = record
    MaxAdvance: integer;
    height: integer;
    Ascender: integer;
    Descender: integer;
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

implementation

var
  fr_face: TFTFace;
  pFont: PByte;
  font_mem_size: integer;

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
  font_data.Ascender := fr_face.Size.Metrics.Ascender div 64;
  font_data.Descender := fr_face.Size.Metrics.Descender div 64;
  font_data.MaxAdvance := fr_face.Size.Metrics.MaxAdvance div 64;
  font_data.bpc := font_data.height div 8;
  if font_data.bpc * 8 < font_data.height then
    inc(font_data.bpc);
  font_data.max_w := 0;
  font_data.min_w := fr_face.Size.Metrics.MaxAdvance div 64;
end;

{ TSymbol }

constructor TSymbol.Create(Code: integer);
begin
  sData.char_code := Code;
  sData.Width := 0;
  sData.Advance := 0;
  sData.BearingX := 0;
  sData.BearingY := 0;
  sData.BufferSize := 0;
  Buffer := nil;
end;

destructor TSymbol.Destroy;
begin
  if self.Buffer <> nil then
    FreeMemory(self.Buffer);
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
  p := AllocMem(self.sData.BufferSize + font_data.bpc);
  CopyMemory(p + font_data.bpc, self.Buffer, self.sData.BufferSize);
  FreeMemory(self.Buffer);
  self.Buffer := p;
  inc(self.sData.Width);
  inc(self.sData.BufferSize, font_data.bpc);
  dec(self.sData.BearingX);
end;

procedure TSymbol.AddColAtRight;
var
  p: PByte;
begin
  p := AllocMem(self.sData.BufferSize + font_data.bpc);
  CopyMemory(p, self.Buffer, self.sData.BufferSize);
  FreeMemory(self.Buffer);
  self.Buffer := p;
  inc(self.sData.Width);
  inc(self.sData.BufferSize, font_data.bpc);
end;

function TSymbol.Build(var f: TextFile): string;
var
  UD: PUniData;
  i: integer;
begin
  if self = nil then
    exit;
  UD := UniNamer.Data[self.sData.char_code];
  writeln(f, '/* ' + 'U+' + UD.U_plus + ' - ' + UD.Name + ' */');
  write(f, 'static const unsigned char _U_' + UD.U_plus + '[] = {');
  Result := '_U_' + UD.U_plus;
  if self.Buffer = nil then
  begin
    writeln(f, '/* NO DATA */};');
    exit;
  end;
  write(f, '0x', IntToHex(byte(self.sData.Width)), ', ');
  for i := 0 to self.sData.BufferSize - 1 do
    write(f, '0x', IntToHex(self.Buffer[i]), ', ');
  writeln(f, '};');
end;

procedure TSymbol.DelColAtLeft;
var
  p: PByte;
begin
  p := AllocMem(self.sData.BufferSize - font_data.bpc);
  CopyMemory(p, self.Buffer + font_data.bpc, self.sData.BufferSize -
    font_data.bpc);
  FreeMemory(self.Buffer);
  self.Buffer := p;
  dec(self.sData.Width);
  dec(self.sData.BufferSize, font_data.bpc);
  inc(self.sData.BearingX);
end;

procedure TSymbol.DelColAtRight;
var
  p: PByte;
begin
  p := AllocMem(self.sData.BufferSize - font_data.bpc);
  CopyMemory(p, self.Buffer, self.sData.BufferSize - font_data.bpc);
  FreeMemory(self.Buffer);
  self.Buffer := p;
  dec(self.sData.Width);
  dec(self.sData.BufferSize, font_data.bpc);
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
  for i := self.sData.BufferSize - 1 downto 0 do
  begin
    if ((self.Buffer[i - 1] and 128) <> 0) and
      ((i - 1) mod font_data.bpc <> font_data.bpc - 1) then
      b := 1
    else
      b := 0;
    if i mod font_data.bpc = font_data.bpc - 1 then
      self.Buffer[i] := ((self.Buffer[i] shl 1) or b) and Y
    else
      self.Buffer[i] := (self.Buffer[i] shl 1) or b;
  end;
end;

procedure TSymbol.MoveLeft;
var
  i: integer;
begin
  for i := 0 to self.sData.BufferSize - font_data.bpc do
  begin
    self.Buffer[i] := self.Buffer[i + font_data.bpc];
  end;
  FillChar(self.Buffer[self.sData.BufferSize - font_data.bpc],
    font_data.bpc, 0);
end;

procedure TSymbol.MoveRight;
var
  i: integer;
begin
  for i := self.sData.BufferSize - 1 downto font_data.bpc do
  begin
    self.Buffer[i] := self.Buffer[i - font_data.bpc];
  end;
  FillChar(self.Buffer[0], font_data.bpc, 0);
end;

procedure TSymbol.MoveUp;
var
  i: integer;
  b: integer;
begin
  for i := 0 to self.sData.BufferSize - 1 do
  begin
    if ((self.Buffer[i + 1] and 1) <> 0) and ((i + 1) mod font_data.bpc <> 0)
    then
      b := 128
    else
      b := 0;
    self.Buffer[i] := (self.Buffer[i] shr 1) or b;
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
  glyph_index := fr_face.GetCharIndex(self.sData.char_code);
  fr_face.LoadGlyph(glyph_index, [ftlfMonochrome, ftlfTargetMono, ftlfRender]);
  self.sData.BearingX := fr_face.glyph.Metrics.HorzBearingX div 64;
  self.sData.BearingY := fr_face.glyph.Metrics.HorzBearingY div 64;
  self.sData.Width := fr_face.glyph.Bitmap.Width;
  self.sData.Advance := fr_face.glyph.Metrics.HorzAdvance div 64;
  if self.sData.char_code = 32 then
    self.sData.Width := self.sData.Advance;

  if self.sData.Width > font_data.max_w then
    font_data.max_w := self.sData.Width;
  if self.sData.Width < font_data.min_w then
    font_data.min_w := self.sData.Width;
  self.sData.BufferSize := font_data.bpc * self.sData.Width;
  self.Buffer := AllocMem(self.sData.BufferSize);
  // не надо очищать
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

procedure TSymbol.ChangePixel(Image: TImage; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  i, j: integer;
  grid_size: integer;
  origin: TPoint;
  b: byte;
begin
  if (self = nil) or (self.Buffer = nil) then
    exit;
  // вычисление размера сетки
  grid_size := round(Image.height * 7 / 10 / font_data.height);
  i := round(Image.Width * 5 / 10 / self.sData.Width);
  if i < grid_size then
    grid_size := i;
  // вычисление координат
  origin.X := round(Image.Width / 8);
  origin.Y := round(Image.height * 9 / 12);
  if (X < origin.X + self.sData.BearingX * grid_size) or
    (X > origin.X + (self.sData.BearingX + self.sData.Width) * grid_size) or
    (Y < origin.Y - font_data.Ascender * grid_size) or
    (Y > origin.Y - font_data.Ascender * grid_size + font_data.height *
    grid_size)
  then
    exit;
  i := (X - origin.X - self.sData.BearingX * grid_size) div grid_size;
  j := (Y - origin.Y + font_data.Ascender * grid_size) div grid_size;

  b := self.Buffer[i * font_data.bpc + j div 8];
  if Button = TMouseButton.mbLeft then
    b := b or (1 shl (j mod 8));
  if Button = TMouseButton.mbRight then
    b := b and not(1 shl (j mod 8));
  self.Buffer[i * font_data.bpc + j div 8] := b;
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
  i := round(Image.Width * 5 / 10 / self.sData.Width);
  if i < grid_size then
    grid_size := i;
  // вычисление координат
  origin.X := round(Image.Width / 8);
  origin.Y := round(Image.height * 9 / 12);
  bbox.Left := origin.X;
  bbox.Right := origin.X + self.sData.Advance * grid_size;
  bbox.Top := origin.Y - font_data.Ascender * grid_size;
  bbox.Bottom := origin.Y - font_data.Descender * grid_size;
  // заливка коробки белым
  Image.Canvas.Brush.Color := clWhite;
  for X := self.sData.BearingX to self.sData.Width - 1 + self.sData.BearingX do
    for Y := 0 to font_data.height - 1 do
    begin
      R := Rect(bbox.Left + X * grid_size, bbox.Top + Y * grid_size,
        bbox.Left + X * grid_size + grid_size, bbox.Top + Y * grid_size +
        grid_size);
      Image.Canvas.FillRect(R);
    end;
  // отрисовка символа
  Image.Canvas.Brush.Color := clBlack;
  for i := 0 to self.sData.BufferSize - 1 do
    for j := 0 to 7 do
    begin
      X := i div font_data.bpc + self.sData.BearingX;
      Y := 8 * (i mod font_data.bpc) + j;
      R := Rect(bbox.Left + X * grid_size, bbox.Top + Y * grid_size,
        bbox.Left + X * grid_size + grid_size, bbox.Top + Y * grid_size +
        grid_size);
      // if (symbol.Buffer[i] shl j) and 128 > 0 then
      if (self.Buffer[i] shr j) and 1 > 0 then
        // совместимость с GLCD
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

procedure TSymbol.CopyData(Source: TSymbol);
var
  i: integer;
begin
  self.sData := Source.sData;
  self.Buffer := AllocMem(self.sData.BufferSize);
  for i := 0 to self.sData.BufferSize - 1 do
    self.Buffer[i] := Source.Buffer[i];
end;

procedure TSymbol.WriteToFile(var f: &file);
begin
  BlockWrite(f, self.sData, sizeof(sData)); // запись структуры символа
  BlockWrite(f, self.Buffer^, self.sData.BufferSize);
  // запись массива пикселей
end;

procedure TSymbol.ReadFromFile(var f: &file);
begin
  BlockRead(f, self.sData, sizeof(sData));
  if self.sData.BufferSize > 0 then
  begin
    self.Buffer := GetMemory(self.sData.BufferSize);
    BlockRead(f, self.Buffer^, self.sData.BufferSize);
  end;
end;

end.
