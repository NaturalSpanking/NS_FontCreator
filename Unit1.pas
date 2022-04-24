unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFreeType, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.jpeg, Vcl.Grids, Vcl.ComCtrls, Vcl.Menus;

type
  TSymb = record
    Width: integer;
    Heigth: integer;
    BytesPerColumn: integer;
    BufferSize: integer;
    Buffer: PByte;
  end;

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    FontDialog1: TFontDialog;
    Button3: TButton;
    StringGrid1: TStringGrid;
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
  i, j, k: integer;
  x, y: integer;
  S: TSymb;
  glyph_index: integer;
begin
  for i := 0 to StringGrid1.ColCount do
    for j := 0 to StringGrid1.RowCount do
      StringGrid1.Cells[i, j] := '';
  S := Render(ord(Edit1.Text[1]));
  StringGrid1.RowCount := S.Heigth;
  StringGrid1.ColCount := S.Width;
  k := 0;
  for i := 0 to S.BufferSize do
  begin
    for j := 0 to 7 do
      if (S.Buffer[i] shl j) and 128 > 0 then
      begin
        x := i div S.BytesPerColumn;
        y := 8*(i mod S.BytesPerColumn) + j;
        StringGrid1.Cells[x, y] := 'X';
      end;
  end;
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
  for i := 1 to 1000 do
    Set_FT_Font;
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
    Result := Result + [ftlfTargetMono]; // другие флаги фигня
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
  Result.Heigth := face.Size.Metrics.Height div 64 + 1;
  Result.Width := face.glyph.Metrics.Width div 64;
  Result.BytesPerColumn := Result.Heigth div 8;
  if Result.BytesPerColumn * 8 < Result.Heigth then
    inc(Result.BytesPerColumn);
  Result.BufferSize := Result.BytesPerColumn * Result.Width;
  Result.Buffer := GetMemory(Result.BufferSize);
  // FillChar(Result.Buffer, Result.BufferSize, 0);
  // StringGrid1.RowCount := face.Size.Metrics.Height div 64 + 1;
  // StringGrid1.ColCount := face.glyph.Metrics.Width div 64;

  for i := 0 to Result.BufferSize do
    Result.Buffer[i] := 0;
  k := 0;
  for i := 0 to (face.glyph.Bitmap.Rows * face.glyph.Bitmap.Pitch) - 1 do
  begin
    for j := 0 to 7 do
    begin
      if face.glyph.Bitmap.Buffer[i] shl j and 128 > 0 then
      begin
        P_x := k * 8 + j;
        P_y := (face.Size.Metrics.Ascender - face.glyph.Metrics.HorzBearingY)
          div 64 + i div face.glyph.Bitmap.Pitch + 1;
        byte_idx := (P_y div 8) + Result.BytesPerColumn * P_x;
        Result.Buffer[byte_idx] := Result.Buffer[byte_idx] +
          1 shl (7 - P_y mod 8);

        // StringGrid1.Cells[P_x, P_y] := 'X';
      end;

    end;
    inc(k);
    if k = face.glyph.Bitmap.Pitch then
      k := 0;
  end;
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
  face.LoadGlyph(face.GetCharIndex(ord('Щ')), CheckLoadFlags);
  StatusBar1.Panels[1].Text := IntToStr(face.Size.Metrics.Height div 64 + 1) +
    'x' + IntToStr(face.Size.Metrics.MaxAdvance div 64);
  // IntToStr(face.glyph.Metrics.Width div 64);

end;

end.
