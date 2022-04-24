unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFreeType, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.jpeg, Vcl.Grids, Vcl.ComCtrls, Vcl.Menus;

type
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
    glyph_index: integer;
    load_flags: TFTLoadFlags;
    rendef_flags: TFTRenderMode;
    procedure AddLog(S: string);
    procedure Set_FT_Font;
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
  x, i, j, k: integer;
  c: byte;
begin
  glyph_index := face.GetCharIndex(ord(Edit1.Text[1]));

  load_flags := [ftlfMonochrome, ftlfRender];
  if CheckBox1.Checked then
    load_flags := load_flags + [ftlfNoHinting];
  if CheckBox2.Checked then
    load_flags := load_flags + [ftlfForceAutohint];
  if CheckBox3.Checked then
    load_flags := load_flags + [ftlfTargetMono]; // другие флаги фигня

  face.LoadGlyph(glyph_index, load_flags);
  if ftffGlyphNames in face.FaceFlags then
    StatusBar1.Panels[0].Text := face.GetGlyphName(glyph_index)
  else
    StatusBar1.Panels[0].Text := 'Face hasn'' t glyph names ';

      for i := 0 to StringGrid1.ColCount do for j :=
      0 to StringGrid1.RowCount do StringGrid1.Cells[i, j] := '';

  // StringGrid1.RowCount := face.Glyph.Metrics.Height div 64;
  StringGrid1.RowCount := face.Size.Metrics.Height div 64 + 1;
  StringGrid1.ColCount := face.glyph.Metrics.Width div 64;

  {
    Glyph.Bitmap.Pitch в монохромном режиме выдает количество байт на строку, четное число
    при этом используется 1 бит на пиксель
  }
  k := 0;
  for i := 0 to (face.glyph.Bitmap.Rows * face.glyph.Bitmap.Pitch) - 1 do
  begin
    for j := 0 to 7 do
    begin
      if face.glyph.Bitmap.Buffer[i] shl j and 128 > 0 then
        StringGrid1.Cells[k * 8 + j,
          (face.Size.Metrics.Ascender - face.glyph.Metrics.HorzBearingY) div 64
          + i div face.glyph.Bitmap.Pitch + 1] := 'X';
    end;
    inc(k);
    if k = face.glyph.Bitmap.Pitch then
      k := 0;

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
  FT_Done_Face(face);
  FreeMem(pFont);
  font_mem_size := 0;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  x: integer;
begin
  StatusBar1.Panels[0].Text :=
    ('FreeType''s version is ' + IntToStr(TFTManager.MajorVersion) + '.' +
    IntToStr(TFTManager.MinorVersion) + '.' +
    IntToStr(TFTManager.PatchVersion));
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
end;

end.
