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
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    ft_lib: TFTLibrary;
    face: TFTFace;
    pFont: PByte;
    font_mem_size: integer;
    glyph_index: integer;
    load_flags: TFTLoadFlags;
    rendef_flags: TFTRenderMode;
    procedure AddLog(S: string);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.AddLog(S: string);
begin
  //Memo1.Lines.Add(S);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  x, i, j, k: integer;
  c: byte;
begin
  glyph_index := FT_Get_Char_Index(face, ord(Edit1.Text[1]));

  load_flags := [ftlfMonochrome, ftlfRender];
  if CheckBox1.Checked then
    load_flags := load_flags + [ftlfNoHinting];
  if CheckBox2.Checked then
    load_flags := load_flags + [ftlfForceAutohint];
  if CheckBox3.Checked then
    load_flags := load_flags + [ftlfTargetMono];
//  if CheckBox4.Checked then // фигня какая-то
//    load_flags := load_flags + [ftlfAdvanceOnly];
//  if CheckBox5.Checked then
//    load_flags := load_flags + [ftlfComputeMetrics];
//  if CheckBox6.Checked then
//    load_flags := load_flags +[ftlfNoScale];

  x := FT_Load_Glyph(face, glyph_index, load_flags);
  if x <> 0 then
  begin
    AddLog('Failed to load glyph');
  end;

  // рендер уже сделан выше
  // разыменовывание указателя происходит тут
  // к этому моменту в буфере что-то есть уже
  // x := FT_Render_Glyph(face.Glyph^, ftrmMono);
  // if x <> 0 then
  // begin
  // AddLog('Failed to render the glyph');
  // end;

  for i := 0 to StringGrid1.ColCount do
    for j := 0 to StringGrid1.RowCount do
      StringGrid1.Cells[i, j] := '';


//  StringGrid1.RowCount := face.Glyph.Metrics.Height div 64;
  StringGrid1.RowCount := face.Size.Metrics.Height div 64 + 1;
  StringGrid1.ColCount := face.Glyph.Metrics.Width div 64;

  {
    Glyph.Bitmap.Pitch в монохромном режиме выдает количество байт на строку, четное число
    при этом используется 1 бит на пиксель
  }
  k := 0;
  for i := 0 to (face.Glyph.Bitmap.Rows * face.Glyph.Bitmap.Pitch) - 1 do
  begin
    for j := 0 to 7 do
    begin
      if face.Glyph.Bitmap.Buffer[i] shl j and 128 > 0 then
        StringGrid1.Cells[k * 8 + j,(face.Size.Metrics.Ascender - face.Glyph.Metrics.HorzBearingY) div 64 + i div face.Glyph.Bitmap.Pitch + 1] := 'X';
    end;
    inc(k);
    if k = face.Glyph.Bitmap.Pitch then
      k := 0;

  end;

  { не правильно работает
    for i := 0 to (face.Glyph.Bitmap.Rows) - 1 do
    begin
    for k := 0 to face.Glyph.Bitmap.Pitch - 1 do
    begin
    c := face.Glyph.Bitmap.Buffer[i * face.Glyph.Bitmap.Pitch + k];
    // c := c + (face.Glyph.Bitmap.Buffer[i * face.Glyph.Bitmap.Pitch +1] shl 8);
    for j := 0 to face.Glyph.Bitmap.Width do
    begin
    if (c shr (j)) and 1 > 0 then // +face.Glyph.BitmapLeft
    StringGrid1.Cells[8*k + face.Glyph.Bitmap.Width - j, i] := 'X';
    end;
    end;
    end;
  }

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  FontDialog1.Font := Form1.Font;
  if FontDialog1.Execute(Application.Handle) then
  begin
    Form1.Font := FontDialog1.Font;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  face.Glyph.Bitmap.Done;
  FT_Done_Face(face);
  FT_Done_FreeType(ft_lib);
  FreeMem(pFont);
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  x, major, minor, patch: integer;
begin
  x := FT_Init_FreeType(ft_lib);
  if x <> 0 then
  begin
    AddLog('init fail');
    exit;
  end;

  FT_Library_Version(ft_lib, major, minor, patch);
  AddLog('FreeType''s version is ' + IntToStr(major) + '.' +
    IntToStr(minor) + '.' + IntToStr(patch));

  font_mem_size := GetFontData(Form1.Canvas.Handle, 0, 0, nil, font_mem_size);
  GetMem(pFont, font_mem_size);
  if GetFontData(Form1.Canvas.Handle, 0, 0, pFont, font_mem_size) = GDI_ERROR
  then
  begin
    FreeMem(pFont);
    FT_Done_FreeType(ft_lib);
    exit;
  end;

  // x := FT_New_Face(ft_lib, PAnsiChar(FontDialog1.Font.GetNamePath), 0, face);
  x := FT_New_Memory_Face(ft_lib, pFont, font_mem_size, 0, face);
  if x <> 0 then
  begin
    AddLog('Failed to load face');
  end;

  x := FT_Set_Pixel_Sizes(face, 0, Form1.Font.Size);
//  x := FT_Set_Char_Size(face,0,Form1.Font.Size,96,96);
  if x <> 0 then
  begin
    AddLog('Failed to set pixel size');
  end;
end;

end.
