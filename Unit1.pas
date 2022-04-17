unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFreeType, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.jpeg, Vcl.Grids;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    FontDialog1: TFontDialog;
    Button3: TButton;
    StringGrid1: TStringGrid;
    Panel1: TPanel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
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
  Memo1.Lines.Add(S);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  x, i, j: integer;
  major, minor, patch: integer;
  c: short;
begin
  x := FT_Init_FreeType(ft_lib);
  if x <> 0 then
  begin
    AddLog('init fail');
    exit;
  end;

  FT_Library_Version(ft_lib, major, minor, patch);
  Memo1.Lines.Add('FreeType''s version is ' + IntToStr(major) + '.' +
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
  if x <> 0 then
  begin
    AddLog('Failed to set pixel size');
  end;

  glyph_index := FT_Get_Char_Index(face, ord('g'));

  load_flags := [
  ftlfMonochrome,
//  ftlfNoHinting,
//  ftlfForceAutohint,
  ftlfTargetMono,
  ftlfRender
  ];
  if not CheckBox1.Checked then load_flags := load_flags + ftlfNoHinting;

  x := FT_Load_Glyph(face, glyph_index, load_flags);
  if x <> 0 then
  begin
    AddLog('Failed to load glyph');
  end;

  // разыменовывание указателя происходит тут
  // к этому моменту в буфере что-то есть уже
  // x := FT_Render_Glyph(face.Glyph^, ftrmMono);
  if x <> 0 then
  begin
    AddLog('Failed to render the glyph');
  end;

  StringGrid1.ColCount := face.Glyph.Bitmap.Width+5;
  StringGrid1.RowCount := face.Glyph.Bitmap.Rows;
  {
    Glyph.Bitmap.Pitch в монохромном режиме выдает количество байт на строку, четное число
    при этом используется 1 бит на пиксель
  }
  for i := 0 to face.Glyph.Bitmap.Rows do
  begin
    c := face.Glyph.Bitmap.Buffer[i * face.Glyph.Bitmap.Pitch];
    for j := 0 to face.Glyph.Bitmap.Width do
    begin

      if (c shr (j+1)) and 1 > 0 then
        StringGrid1.Cells[face.Glyph.Bitmap.Width-j, i] := 'X'
      else
        StringGrid1.Cells[face.Glyph.Bitmap.Width-j, i] := '';
    end;
  end;

  FT_Done_Face(face);
  FT_Done_FreeType(ft_lib);
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
  // Image1.Picture.Bitmap.Canvas.Pen.Width := 2;
  // Image1.Picture.Bitmap.Canvas.Pen.Color := clBlack;
  // Image1.Picture.Bitmap.Canvas.LineTo(100, 100);
  Form1.Canvas.Pen.Width := 2;
  Form1.Canvas.Pen.Color := clYellow;
  Form1.Canvas.MoveTo(0, 0);
  Form1.Canvas.LineTo(100, 100);
end;

end.
