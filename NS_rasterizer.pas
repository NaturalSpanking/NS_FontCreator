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
    pFont: PByte;
    font_mem_size: integer;
    glyph_index: integer;
    procedure set_font(font: TFont);
    procedure do_render;
  public
    property Font:TFont write set_font;
    procedure Free;
    constructor Create;
    destructor Destroy;
  end;

implementation

{ TRasterizer }

constructor TRasterizer.Create;
begin
  if FT_Init_FreeType(ft_lib) <> 0 then
    raise Exception.Create('Failed to init FreeType library.');
  FT_Library_Version(ft_lib, ver.major, ver.minor, ver.patch);
  pFont := nil;
  font_mem_size := 0;
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

destructor TRasterizer.Destroy;
begin
  ft_face.Glyph.Bitmap.Done;
  FT_Done_Face(ft_face);
  FT_Done_FreeType(ft_lib);
  if font_mem_size > 0 then
    FreeMem(pFont);
end;

procedure TRasterizer.set_font(font: TFont);
var
  dc: HDC;
begin
  dc := CreateDC('DISPLAY', nil, nil, nil);
  SelectObject(dc, font.Handle);
  if font_mem_size > 0 then
  begin
    FT_Done_Face(ft_face);
    FreeMem(pFont);
  end;
  font_mem_size := GetFontData(dc, 0, 0, nil, font_mem_size);
  GetMem(pFont, font_mem_size);
  if GetFontData(dc, 0, 0, pFont, font_mem_size) = GDI_ERROR then
    raise Exception.Create('Failed to get font data.');
  // x := FT_New_Face(ft_lib, PAnsiChar(FontDialog1.Font.GetNamePath), 0, face);
  if FT_New_Memory_Face(ft_lib, pFont, font_mem_size, 0, ft_face) <> 0 then
    raise Exception.Create('Failed to get font face.');
  // x := FT_Set_Char_Size(face,0,Form1.Font.Size,96,96);
  if FT_Set_Pixel_Sizes(ft_face, 0, font.Size) <> 0 then
    raise Exception.Create('Failed to set pixel size.');
  CancelDC(dc);
  DeleteDC(dc);
end;

procedure TRasterizer.Free;
begin
  // under ARC, this method isn't actually called since the compiler translates
  // the call to be a mere nil assignment to the instance variable, which then calls _InstClear
{$IFNDEF AUTOREFCOUNT}
  if Self <> nil then
    Destroy;
{$ENDIF}
end;

end.
