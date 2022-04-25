unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFreeType, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.jpeg, Vcl.Grids, Vcl.ComCtrls, Vcl.Menus;

type
  TSymb = record
    Code: integer;
    Width: integer;
    Heigth: integer;
    Ascender: integer;
    Descender: integer;
    BytesPerColumn: integer;
    BufferSize: integer;
    Buffer: PByte;
  end;

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    FontDialog1: TFontDialog;
    Button3: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Button4: TButton;
    Edit1: TEdit;
    Panel1: TPanel;
    TreeView1: TTreeView;
    Image1: TImage;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    StatusBar1: TStatusBar;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Memo1: TMemo;
    Image2: TImage;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private
    face: TFTFace;
    pFont: PByte;
    font_mem_size: integer;
    rendef_flags: TFTRenderMode;
    procedure AddLog(S: string);
    procedure Set_FT_Font;
    procedure ShowSymb(var symbol: TSymb);
    function Render(char_idx: smallint): TSymb;
    function CheckLoadFlags: TFTLoadFlags;
    function FontStyletoString(style: TFontStyles): string;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.AddLog(S: string);
begin
  // Memo1.Lines.Add(S);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  S: TSymb;
begin
  S := Render(ord(Edit1.Text[1]));
  ShowSymb(S);
  FreeMemory(S.Buffer);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if FontDialog1.Execute(Application.Handle) then
    Set_FT_Font;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  face.glyph.Bitmap.Done;
  face.Destroy;
  FreeMem(pFont);
  font_mem_size := 0;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  x: integer;
begin
  StatusBar1.Panels[3].Text :=
    ('FreeType''s version is ' + IntToStr(TFTManager.MajorVersion) + '.' +
    IntToStr(TFTManager.MinorVersion) + '.' + IntToStr(TFTManager.PatchVersion))
    + '       ';
  Set_FT_Font;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  i: integer;
begin
  for i := 1 to 10000 do
    // Set_FT_Font;
    Button1.Click;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  FontDialog1.Font.Size := FontDialog1.Font.Size - 1;
  Set_FT_Font;
  Button1.Click;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  FontDialog1.Font.Size := FontDialog1.Font.Size + 1;
  Set_FT_Font;
  Button1.Click;
end;

function TForm1.CheckLoadFlags: TFTLoadFlags;
begin
  Result := [ftlfMonochrome, ftlfRender];
  if CheckBox1.Checked then
    Result := Result + [ftlfNoHinting];
  if CheckBox2.Checked then
    Result := Result + [ftlfForceAutohint];
  if CheckBox3.Checked then
    Result := Result + [ftlfTargetMono]; // другие флаги фигн€
end;

function TForm1.FontStyletoString(style: TFontStyles): string;
begin
  Result := '';
  if fsStrikeOut in style then
    Result := Result + ' StrikeOut';
  if fsUnderline in style then
    Result := Result + ' Underline';
  if fsItalic in style then
    Result := Result + ' Italic';
  if fsBold in style then
    Result := Result + ' Bold';
end;

function TForm1.Render(char_idx: smallint): TSymb;
var
  P_x, P_y, i, j, k: integer;
  c: byte;
  byte_idx: integer;
  glyph_index: integer;
begin
  glyph_index := face.GetCharIndex(char_idx);
  face.LoadGlyph(glyph_index, CheckLoadFlags);
  if ftffGlyphNames in face.FaceFlags then
    StatusBar1.Panels[2].Text := face.GetGlyphName(glyph_index)
  else
    StatusBar1.Panels[2].Text := 'Face hasn'' t glyph names ';
  Result.Code := char_idx;
  Result.Heigth := face.Size.Metrics.Height div 64 + 1;
  Result.Width := face.glyph.Metrics.Width div 64;
  Result.Ascender := face.Size.Metrics.Ascender div 64;
  Result.Descender := face.Size.Metrics.Descender div 64;
  Result.BytesPerColumn := Result.Heigth div 8;
  if Result.BytesPerColumn * 8 < Result.Heigth then
    inc(Result.BytesPerColumn);
  Result.BufferSize := Result.BytesPerColumn * Result.Width;
  Result.Buffer := AllocMem(Result.BufferSize); // не надо очищать
  k := 0;
  for i := 0 to (face.glyph.Bitmap.Rows * face.glyph.Bitmap.Pitch) - 1 do
  begin
    for j := 0 to 7 do
      if face.glyph.Bitmap.Buffer[i] shl j and 128 > 0 then
      begin
        P_x := k * 8 + j;
        P_y := (face.Size.Metrics.Ascender - face.glyph.Metrics.HorzBearingY)
          div 64 + i div face.glyph.Bitmap.Pitch + 1;
        byte_idx := (P_y div 8) + Result.BytesPerColumn * P_x;
        Result.Buffer[byte_idx] := Result.Buffer[byte_idx] +
          1 shl (7 - P_y mod 8);
      end;
    inc(k);
    if k = face.glyph.Bitmap.Pitch then
      k := 0;
  end;
  face.glyph.Bitmap.Done;
end;

procedure TForm1.Set_FT_Font;
var
  dc: HDC;
begin
  dc := CreateDC('DISPLAY', nil, nil, nil);
  SelectObject(dc, FontDialog1.Font.Handle);
  if font_mem_size > 0 then
  begin
    face.Destroy;
    FreeMem(pFont);
  end;
  font_mem_size := GetFontData(dc, 0, 0, nil, font_mem_size);
  GetMem(pFont, font_mem_size);
  if GetFontData(dc, 0, 0, pFont, font_mem_size) = GDI_ERROR then
    raise Exception.Create('Failed to get font data.');
  face := TFTFace.Create(pFont, font_mem_size, 0);
  face.SetPixelSize(0, FontDialog1.Font.Size);
  CancelDC(dc);
  DeleteDC(dc);
  StatusBar1.Panels[0].Text := FontDialog1.Font.Name +
    FontStyletoString(FontDialog1.Font.style) + ' ' +
    IntToStr(FontDialog1.Font.Size);
  // face.LoadGlyph(face.GetCharIndex(ord('ў')), CheckLoadFlags);
  StatusBar1.Panels[1].Text := IntToStr(face.Size.Metrics.Height div 64 + 1) +
    'x' + IntToStr(face.Size.Metrics.MaxAdvance div 64);
  // IntToStr(face.glyph.Metrics.Width div 64);

end;

procedure TForm1.ShowSymb(var symbol: TSymb);
var
  a, b: integer;
  i, j: integer;
  x, y: integer;
  grid_size: integer;
  R: TRect;
begin
  Image2.Picture.Bitmap.Width := Image2.Width;
  Image2.Picture.Bitmap.Height := Image2.Height;
  grid_size := round(Image2.Height * 8 / 10 / symbol.Heigth);
  i := round(Image2.Width * 5 / 10 / symbol.Width);
  if i < grid_size then
    grid_size := i;

  Image2.Canvas.Brush.Color := clGray;
  Image2.Canvas.FillRect(Rect(0, 0, Image2.Width, Image2.Height));

  a := round(Image2.Height * 2 / 3) - symbol.Ascender * grid_size;
  b := round(Image2.Width / 8);
  Image2.Canvas.Brush.Color := clWhite;
  for x := 0 to symbol.Width - 1 do
    for y := 0 to symbol.Heigth - 1 do
    begin
      R := Rect(b + x * grid_size, a + y * grid_size - grid_size,
        b + x * grid_size + grid_size, a + y * grid_size);
      Image2.Canvas.FillRect(R);
    end;

  Image2.Canvas.pen.Color := clWhite;
  Image2.Canvas.Brush.Color := clBlack;
  for i := 0 to symbol.BufferSize - 1 do
    for j := 0 to 7 do
    begin
      x := i div symbol.BytesPerColumn;
      y := 8 * (i mod symbol.BytesPerColumn) + j;
      R := Rect(b + x * grid_size, a + y * grid_size - grid_size,
        b + x * grid_size + grid_size, a + y * grid_size);
      if (symbol.Buffer[i] shl j) and 128 > 0 then
        Image2.Canvas.FillRect(R);
    end;

  with Image2.Canvas do
  begin
    i := round(Image2.Height * 2 / 3);
    pen.Color := clBlack;
    j := i;
    while j > 0 do
    begin
      MoveTo(0, j);
      LineTo(Image2.Width, j);
      dec(j, grid_size);
    end;
    while j < Image2.Height do
    begin
      MoveTo(0, j);
      LineTo(Image2.Width, j);
      inc(j, grid_size);
    end;
    pen.Color := clRed;
    MoveTo(0, i);
    LineTo(Image2.Width, i); // базова€ лини€ горизонтальна€
    j := i - symbol.Ascender * grid_size;
    MoveTo(0, j);
    LineTo(Image2.Width, j); // Ascender
    j := i - symbol.Descender * grid_size;
    MoveTo(0, j);
    LineTo(Image2.Width, j); // Descender

    i := round(Image2.Width / 8);
    pen.Color := clBlack;
    j := i;
    while j > 0 do
    begin
      MoveTo(j, 0);
      LineTo(j, Image2.Height);
      dec(j, grid_size);
    end;
    j := i;
    while j < Image2.Width do
    begin
      MoveTo(j, 0);
      LineTo(j, Image2.Height);
      inc(j, grid_size);
    end;
    pen.Color := clRed;
    MoveTo(i, 0);
    LineTo(i, Image2.Height); // базова€ лини€ вертикальна€
  end;
end;

end.
