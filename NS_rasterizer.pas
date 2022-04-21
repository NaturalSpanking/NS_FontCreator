unit NS_rasterizer;

interface

uses
  Winapi.Windows, System.SysUtils, Vcl.Graphics, uFreeType;

type
  ERenderFlags = (rfNoHinting, rfForceAutohint, rfTargetMono);

  TLibVersion = record
    major: integer;
    minor: integer;
    patch: integer;
  end;

  TRasterizer = class
  private
    ft_lib: TFTLibrary;
    ft_face: TFTFace;
    load_flags: TFTLoadFlags;
    rendef_flags: TFTRenderMode;
    ver: TLibVersion;
    font: TFont;
    pFont: PByte;
    font_mem_size: integer;
    glyph_index: integer;
    procedure set_font(font: TFont);
    procedure do_render;
  public
    constructor Create;
    destructor Free;
  end;

implementation

{ TRasterizer }

constructor TRasterizer.Create;
begin
  if FT_Init_FreeType(ft_lib) <> 0 then
  begin
    raise Exception.Create('Error Message');
  end;
  FT_Library_Version(ft_lib, ver.major, ver.minor, ver.patch);
end;

procedure TRasterizer.do_render;
begin
  {
    glyph_index := FT_Get_Char_Index(face, ord(Edit1.Text[1]));
    exception.Create();
    load_flags := [ftlfMonochrome, ftlfRender];
    if CheckBox1.Checked then
    load_flags := load_flags + [ftlfNoHinting];
    if CheckBox2.Checked then
    load_flags := load_flags + [ftlfForceAutohint];
    if CheckBox3.Checked then
    load_flags := load_flags + [ftlfTargetMono];
    x := FT_Load_Glyph(face, glyph_index, load_flags);
    if x <> 0 then
    begin
    AddLog('Failed to load glyph');
    end;
  }

  {
    for i := 0 to (face.Glyph.Bitmap.Rows * face.Glyph.Bitmap.Pitch) - 1 do
    begin
    for j := 0 to 7 do
    begin
    if face.Glyph.Bitmap.Buffer[i] shl j and 128 > 0 then
    StringGrid1.Cells[k * 8 + j,
    (face.Size.Metrics.Ascender - face.Glyph.Metrics.HorzBearingY) div 64
    + i div face.Glyph.Bitmap.Pitch + 1] := 'X';
    end;
    inc(k);
    if k = face.Glyph.Bitmap.Pitch then
    k := 0;
    end;
  }
end;

destructor TRasterizer.Free;
begin
  ft_face.Glyph.Bitmap.Done;
  FT_Done_Face(ft_face);
  FT_Done_FreeType(ft_lib);
  FreeMem(pFont);
end;

procedure TRasterizer.set_font(font: TFont);
begin
  // x := FT_New_Face(ft_lib, PAnsiChar(FontDialog1.Font.GetNamePath), 0, face);
  {
    x := FT_New_Memory_Face(ft_lib, pFont, font_mem_size, 0, face);
    if x <> 0 then
    begin
    AddLog('Failed to load face');
    end;

    x := FT_Set_Pixel_Sizes(face, 0, Form1.Font.Size);
    // x := FT_Set_Char_Size(face,0,Form1.Font.Size,96,96);
    if x <> 0 then
    begin
    AddLog('Failed to set pixel size');
    end;
  }
end;

end.

{
  FontDialog1.Font := Form1.Font;
  if FontDialog1.Execute(Application.Handle) then
  begin
    Form1.Font := FontDialog1.Font;
    font_mem_size := GetFontData(Form1.Canvas.Handle, 0, 0, nil, font_mem_size);
    GetMem(pFont, font_mem_size);
    if GetFontData(Form1.Canvas.Handle, 0, 0, pFont, font_mem_size) = GDI_ERROR
    then
    begin
      FreeMem(pFont);
      exit;
    end;
  end;
}
