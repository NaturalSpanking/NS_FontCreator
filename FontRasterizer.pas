unit FontRasterizer;

interface

uses
  SysUtils, Classes, uFreeType;

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

  T_FR_Font = record
    face: TFTFace;
    Heigth: integer;
    bpc: integer;
    min_w: integer;
    max_w: integer;
    pFont: PByte;
    font_mem_size: integer;
    extended_font_name: string;
  end;

implementation

end.
