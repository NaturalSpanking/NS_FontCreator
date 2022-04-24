unit NS_rasterizer;

interface

uses
  Winapi.Windows, System.SysUtils, Vcl.Graphics, uFreeType;

type
  ERenderFlags = (rfNoHinting, rfForceAutohint, rfTargetMono);
  TRenderFlags = set of rfNoHinting .. ERenderFlags(7);

  TLibVersion = record
    major: integer;
    minor: integer;
    patch: integer;
  end;

  TGlyph = record
    Data: PByte;
    Width: integer;
    Height: integer;
    Pitch: integer;
    Ascender: integer;
    Descender: integer;
    HorzBearingX: integer;
    HorzBearingY: integer;
  end;

  PGlyph = ^TGlyph;

  TRasterizer = class
  private
    ft_lib: TFTLibrary;
    ft_face: TFTFace;
    ver: TLibVersion;
    pFont: PByte;
    font_mem_size: integer;
    procedure set_font(font: TFont);

  public
    property font: TFont write set_font;
    function Render(char_idx: integer; flags: TRenderFlags): PGlyph;
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

function TRasterizer.Render(char_idx: integer; flags: TRenderFlags): PGlyph;
var
  i: integer;
  rendef_flags: TFTRenderMode;
  load_flags: TFTLoadFlags;
  glyph_index: integer;
begin

  glyph_index := FT_Get_Char_Index(ft_face, char_idx);
  // Exception.Create();
  load_flags := [ftlfMonochrome, ftlfRender];
  if rfNoHinting in flags then
    load_flags := load_flags + [ftlfNoHinting];
  if rfForceAutohint in flags then
    load_flags := load_flags + [ftlfForceAutohint];
  if rfTargetMono in flags then
    load_flags := load_flags + [ftlfTargetMono];
  if FT_Load_Glyph(ft_face, glyph_index, load_flags) > 0 then
    raise Exception.Create('Failed to load glyph');
  new(Result);
  // Result.Width := ft_face.Glyph.Bitmap.Width;
  Result.Width := ft_face.Glyph.Metrics.Width div 64;
  // Result.Height := ft_face.Glyph.Bitmap.Rows;
  Result.Height := ft_face.Size.Metrics.Height div 64 + 1;
  Result.Pitch := ft_face.Glyph.Bitmap.Pitch;
  Result.Ascender := ft_face.Size.Metrics.Ascender div 64;
  Result.Descender := ft_face.Size.Metrics.Descender div 64;
  Result.HorzBearingX := ft_face.Glyph.Metrics.HorzBearingX div 64;
  Result.HorzBearingY := ft_face.Glyph.Metrics.HorzBearingY div 64;
  Result.Data := SysGetMem(ft_face.Glyph.Bitmap.Rows *
    ft_face.Glyph.Bitmap.Pitch);
  for i := 0 to ft_face.Glyph.Bitmap.Rows * ft_face.Glyph.Bitmap.Pitch do
    Result.Data[i] := ft_face.Glyph.Bitmap.Buffer[i];

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
