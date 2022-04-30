unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFreeType, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.jpeg, Vcl.Grids, Vcl.ComCtrls, Vcl.Menus;

const
  UnicodeArrSize = 34627;

type
  PSymb = ^TSymb;

  TSymb = record
    Code: integer;
    Width: integer;
    Heigth: integer;
    Ascender: integer;
    Descender: integer;
    BearingX: integer;
    BearingY: integer;
    Advance: integer;
    BytesPerColumn: integer;
    BufferSize: integer;
    Buffer: PByte;
  end;

  TUnicodeData = record
    Code: integer;
    U_plus: string;
    Name: string; // [60]
  end;

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    FontDialog1: TFontDialog;
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
    Image2: TImage;
    Button10: TButton;
    Label1: TLabel;
    Button3: TButton;
    Button4: TButton;
    procedure FR_FullRepaint(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FR_AddRange(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure FR_AddTable(Sender: TObject);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    curNode: TTreeNode;
    face: TFTFace;
    pFont: PByte;
    font_mem_size: integer;
    rendef_flags: TFTRenderMode;
    glyph_names_arr: array [0 .. UnicodeArrSize] of TUnicodeData;
    procedure AddLog(S: string);
    procedure FR_SetFont;
    procedure FR_ShowSymbol(var symbol: PSymb);
    procedure FR_LoadUnicodeNames;
    procedure FR_Render(symb: PSymb);
    function FR_FontStyleToString(style: TFontStyles): string;
    function FR_SearchUnicodeName(Code: integer): string;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses add_table;

procedure TForm1.AddLog(S: string);
begin
  // Memo1.Lines.Add(S);
end;

procedure TForm1.FR_AddTable(Sender: TObject);
var
  S: string;
begin
  S := 'table1';
  if InputQuery('Table name', 'Enter new table name', S) then
    TreeView1.Items.Add(nil, S);
end;

procedure TForm1.FR_FullRepaint(Sender: TObject);
var
  psy: PSymb;
  i: integer;
begin
  for i := 0 to TreeView1.Items.Count - 1 do
  begin
    psy := TreeView1.Items[i].Data;
    if psy <> nil then
    begin
      FR_Render(psy);
      if i = TreeView1.Selected.AbsoluteIndex then
        FR_ShowSymbol(psy);
    end;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if FontDialog1.Execute(Application.Handle) then
    FR_SetFont;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  stream: TMemoryStream;
  f: file;
  i: integer;
  b: byte;
  psy: PSymb;
begin
  stream := TMemoryStream.Create;
  AssignFile(f, 'saving.dat');
  rewrite(f, 1);
  TreeView1.SaveToStream(stream);
  i := stream.Size;
  BlockWrite(f, i, sizeof(integer));
  BlockWrite(f, stream.Memory^, i);
  stream.Free;
  for i := 0 to TreeView1.Items.Count - 1 do
  begin
    psy := TreeView1.Items[i].Data;
    if psy <> nil then
    begin
      b := 1;
      BlockWrite(f, b, 1);
      BlockWrite(f, psy^, sizeof(TSymb));
      BlockWrite(f, psy.Buffer^, psy.BufferSize);
    end
    else
    begin
      b := 0;
      BlockWrite(f, b, 1);
    end;
  end;
  i := FontDialog1.Font.Charset;
  BlockWrite(f, i, sizeof(integer));
  i := FontDialog1.Font.Color;
  BlockWrite(f, i, sizeof(integer));
  i := FontDialog1.Font.Size;
  BlockWrite(f, i, sizeof(integer));
  i := byte(FontDialog1.Font.style);
  BlockWrite(f, i, sizeof(integer));
  i := length(FontDialog1.Font.Name);
  BlockWrite(f, i, sizeof(integer));
  BlockWrite(f, FontDialog1.Font.Name[1], i * sizeof(char));
  CloseFile(f);

end;

procedure TForm1.Button4Click(Sender: TObject);
var
  stream: TMemoryStream;
  f: file;
  i: integer;
  b: byte;
  s:string;
  psy: PSymb;
begin
  stream := TMemoryStream.Create;
  AssignFile(f, 'saving.dat');
  reset(f, 1);
  BlockRead(f, i, sizeof(integer));
  stream.SetSize(i);
  BlockRead(f, stream.Memory^, i);
  TreeView1.LoadFromStream(stream);
  stream.Free;
  for i := 0 to TreeView1.Items.Count - 1 do
  begin
    BlockRead(f, b, 1);
    if b = 1 then
    begin
      psy := new(PSymb);
      BlockRead(f, psy^, sizeof(TSymb));
      if psy.BufferSize > 0 then
      begin
        psy.Buffer := GetMemory(psy.BufferSize);
        BlockRead(f, psy.Buffer^, psy.BufferSize);
      end;
      TreeView1.Items[i].Data := psy;
    end;
  end;

  BlockRead(f, i, sizeof(integer));
  FontDialog1.Font.Charset := TFontCharset(i);
  BlockRead(f, i, sizeof(integer));
  FontDialog1.Font.Color := TColor(i);
  BlockRead(f, i, sizeof(integer));
  FontDialog1.Font.Size := i;
  BlockRead(f, i, sizeof(integer));
  FontDialog1.Font.style := TFontStyles(byte(i));
  
  BlockRead(f, i, sizeof(integer));
  SetLength(s, i);  
  BlockRead(f, s[1], (i) * sizeof(char));
  FontDialog1.Font.Name :=s;
  FR_SetFont;
  TreeView1.Select(TreeView1.Items[0]);
  CloseFile(f);
end;

procedure TForm1.FR_AddRange(Sender: TObject);
var
  i: integer;
  psy: PSymb;
begin
  if Form2.Execute and (curNode <> nil) then
    for i := Form2.RangeBegin to Form2.RangeEnd do
    begin
      psy := new(PSymb);
      psy.Code := i;
      psy.Buffer := nil;
      if curNode.Parent = nil then
        TreeView1.Items.AddChildObject(curNode, '''' + chr(psy.Code) + '''' +
          ' - ' + IntToStr(psy.Code), psy)
      else
        TreeView1.Items.AddObject(curNode, '''' + chr(psy.Code) + '''' + ' - ' +
          IntToStr(psy.Code), psy);
    end;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  FontDialog1.Font.Size := FontDialog1.Font.Size - 1;
  FR_SetFont;
  Button1.Click;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  FontDialog1.Font.Size := FontDialog1.Font.Size + 1;
  FR_SetFont;
  Button1.Click;
end;

function TForm1.FR_FontStyleToString(style: TFontStyles): string;
begin
  Result := '';
  if fsStrikeOut in style then
    Result := Result + 'StrikeOut ';
  if fsUnderline in style then
    Result := Result + 'Underline ';
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  StatusBar1.Panels[3].Text :=
    ('FreeType''s version is ' + IntToStr(TFTManager.MajorVersion) + '.' +
    IntToStr(TFTManager.MinorVersion) + '.' + IntToStr(TFTManager.PatchVersion))
    + '       ';
  FR_SetFont;
  FR_LoadUnicodeNames;
end;

procedure TForm1.FormDestroy(Sender: TObject);
var
  i: integer;
  psy: PSymb;
begin
  for i := 0 to TreeView1.Items.Count - 1 do
  begin
    psy := TreeView1.Items[i].Data;
    if psy <> nil then
    begin
      if psy.Buffer <> nil then
        FreeMemory(psy.Buffer);
      Dispose(psy);
    end;
  end;
  face.glyph.Bitmap.Done;
  face.Destroy;
  FreeMemory(pFont);
  font_mem_size := 0;
end;

function TForm1.FR_SearchUnicodeName(Code: integer): string;
var
  a, b, i: integer;
begin
  b := UnicodeArrSize;
  a := 0;
  repeat
    i := ((b - a) div 2) + a;
    if glyph_names_arr[i].Code < Code then
      a := i
    else
      b := i;
  until glyph_names_arr[i].Code = Code;
  Result := glyph_names_arr[i].U_plus + ' - ' + glyph_names_arr[i].Name;
end;

procedure TForm1.FR_LoadUnicodeNames;
var
  f: TextFile;
  sl: TStringList;
  S: string;
  i: integer;
begin
  sl := TStringList.Create;
  sl.Clear;
  sl.Delimiter := ';';
  sl.StrictDelimiter := true;
  AssignFile(f, 'UnicodeData.txt');
  reset(f);
  repeat
    readln(f, S);
    sl.DelimitedText := S;
    glyph_names_arr[i].Code := StrToInt('$' + sl[0]);
    glyph_names_arr[i].Name := sl[1];
    glyph_names_arr[i].U_plus := 'U+' + sl[0];
    inc(i);
  until EOF(f);
  sl.Free;
end;

procedure TForm1.FR_Render(symb: PSymb);
var
  P_x, P_y, i, j, k: integer;
  c: byte;
  byte_idx: integer;
  glyph_index: integer;
begin
  if symb.Buffer <> nil then
    FreeMemory(symb.Buffer);

  glyph_index := face.GetCharIndex(symb.Code);
  face.LoadGlyph(glyph_index, [ftlfMonochrome, ftlfTargetMono, ftlfRender]);
  symb.BearingX := face.glyph.Metrics.HorzBearingX div 64;
  symb.BearingY := face.glyph.Metrics.HorzBearingY div 64;
  symb.Heigth := face.Size.Metrics.Height div 64;
  // Result.Width := face.glyph.Metrics.Width div 64 + abs(Result.BearingX);
  symb.Width := face.glyph.Bitmap.Width; // это правильнее
  symb.Ascender := face.Size.Metrics.Ascender div 64;
  symb.Descender := face.Size.Metrics.Descender div 64;
  symb.Advance := face.glyph.Metrics.HorzAdvance div 64;
  symb.BytesPerColumn := symb.Heigth div 8;
  if symb.BytesPerColumn * 8 < symb.Heigth then
    inc(symb.BytesPerColumn);
  symb.BufferSize := symb.BytesPerColumn * symb.Width;
  symb.Buffer := AllocMem(symb.BufferSize); // не надо очищать
  k := 0;
  for i := 0 to (face.glyph.Bitmap.Rows * face.glyph.Bitmap.Pitch) - 1 do
  begin
    for j := 0 to 7 do
      if face.glyph.Bitmap.Buffer[i] shl j and 128 > 0 then
      begin
        // P_x := abs(Result.BearingX) + k * 8 + j;
        P_x := k * 8 + j; // это правильнее
        P_y := (face.Size.Metrics.Ascender - face.glyph.Metrics.HorzBearingY)
          div 64 + i div face.glyph.Bitmap.Pitch;
        byte_idx := (P_y div 8) + symb.BytesPerColumn * P_x;
        symb.Buffer[byte_idx] := symb.Buffer[byte_idx] + 1 shl (7 - P_y mod 8);
      end;
    inc(k);
    if k = face.glyph.Bitmap.Pitch then
      k := 0;
  end;
  face.glyph.Bitmap.Done;
end;

procedure TForm1.FR_SetFont;
var
  dc: HDC;
begin
  dc := CreateDC('DISPLAY', nil, nil, nil);
  SelectObject(dc, FontDialog1.Font.Handle);
  if font_mem_size > 0 then
  begin
    face.Destroy;
    FreeMemory(pFont);
  end;
  font_mem_size := GetFontData(dc, 0, 0, nil, font_mem_size);
  pFont := GetMemory(font_mem_size);
  if GetFontData(dc, 0, 0, pFont, font_mem_size) = GDI_ERROR then
    raise Exception.Create('Failed to get font data.');
  face := TFTFace.Create(pFont, font_mem_size, 0);
  face.SetPixelSize(0, FontDialog1.Font.Size);
  CancelDC(dc);
  DeleteDC(dc);
  StatusBar1.Panels[0].Text := face.FamilyName + ' ' + face.StyleName + ' ' +
    FR_FontStyleToString(FontDialog1.Font.style) +
    IntToStr(FontDialog1.Font.Size);
  StatusBar1.Panels[1].Text := IntToStr(face.Size.Metrics.Height div 64) + 'x' +
    IntToStr(face.Size.Metrics.MaxAdvance div 64);
end;

procedure TForm1.FR_ShowSymbol(var symbol: PSymb);
var
  i, j: integer;
  x, y: integer;
  grid_size: integer;
  origin: TPoint;
  bbox: TRect;
  R: TRect;
begin
  // очистка канвы
  Image2.Picture.Bitmap.Width := Image2.Width;
  Image2.Picture.Bitmap.Height := Image2.Height;
  Image2.Canvas.Brush.Color := clGray;
  Image2.Canvas.FillRect(Rect(0, 0, Image2.Width, Image2.Height));
  // вычисление размера сетки
  grid_size := round(Image2.Height * 7 / 10 / symbol.Heigth);
  i := round(Image2.Width * 5 / 10 / symbol.Width);
  if i < grid_size then
    grid_size := i;
  // вычисление координат
  origin.x := round(Image2.Width / 8);
  origin.y := round(Image2.Height * 9 / 12);
  bbox.Left := origin.x;
  bbox.Right := origin.x + symbol.Advance * grid_size;
  bbox.Top := origin.y - symbol.Ascender * grid_size;
  bbox.Bottom := origin.y - symbol.Descender * grid_size;
  // заливка коробки белым
  Image2.Canvas.Brush.Color := clWhite;
  for x := symbol.BearingX to symbol.Width - 1 + symbol.BearingX do
    for y := 0 to symbol.Heigth - 1 do
    begin
      R := Rect(bbox.Left + x * grid_size, bbox.Top + y * grid_size,
        bbox.Left + x * grid_size + grid_size, bbox.Top + y * grid_size +
        grid_size);
      Image2.Canvas.FillRect(R);
    end;
  // отрисовка символа
  Image2.Canvas.Brush.Color := clBlack;
  for i := 0 to symbol.BufferSize - 1 do
    for j := 0 to 7 do
    begin
      x := i div symbol.BytesPerColumn + symbol.BearingX;
      y := 8 * (i mod symbol.BytesPerColumn) + j;
      R := Rect(bbox.Left + x * grid_size, bbox.Top + y * grid_size,
        bbox.Left + x * grid_size + grid_size, bbox.Top + y * grid_size +
        grid_size);
      if (symbol.Buffer[i] shl j) and 128 > 0 then
        Image2.Canvas.FillRect(R);
    end;
  // отрисовка сетки
  with Image2.Canvas do
  begin
    // горизонтальные черные линии
    pen.Color := clBlack;
    j := origin.y;
    while j > 0 do // выше базовой
    begin
      MoveTo(0, j);
      LineTo(Image2.Width, j);
      dec(j, grid_size);
    end;
    j := origin.y;
    while j < Image2.Height do // ниже базовой
    begin
      MoveTo(0, j);
      LineTo(Image2.Width, j);
      inc(j, grid_size);
    end;
    // горизонтальные красные линии
    pen.Color := clRed;
    MoveTo(0, origin.y);
    LineTo(Image2.Width, origin.y); // базовая линия горизонтальная
    MoveTo(0, bbox.Top);
    LineTo(Image2.Width, bbox.Top); // Ascender
    MoveTo(0, bbox.Bottom);
    LineTo(Image2.Width, bbox.Bottom); // Descender
    // вертикальные черные линии
    pen.Color := clBlack;
    j := origin.x;
    while j > 0 do // левее базовой
    begin
      MoveTo(j, 0);
      LineTo(j, Image2.Height);
      dec(j, grid_size);
    end;
    j := origin.x;
    while j < Image2.Width do // правее базовой
    begin
      MoveTo(j, 0);
      LineTo(j, Image2.Height);
      inc(j, grid_size);
    end;
    // вертикальные красные линии
    pen.Color := clRed;
    MoveTo(origin.x, 0);
    LineTo(origin.x, Image2.Height); // базовая линия вертикальная
    MoveTo(bbox.Right, 0);
    LineTo(bbox.Right, Image2.Height); // Advance
  end;
  StatusBar1.Panels[2].Text := FR_SearchUnicodeName(symbol.Code);
end;

procedure TForm1.TreeView1Change(Sender: TObject; Node: TTreeNode);
var
  psy: PSymb;
begin
  curNode := Node;
  if (curNode.getFirstChild = nil) and (curNode.Parent <> nil) and
    (curNode.Data <> nil) then
  begin
    psy := curNode.Data;
    if psy.BufferSize > 0 then
      FR_ShowSymbol(psy);
  end;
end;

end.
