unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.UITypes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFreeType, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.jpeg, Vcl.Grids, Vcl.ComCtrls, Vcl.Menus, Vcl.ToolWin;

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
    Button6: TButton;
    Button7: TButton;
    Image2: TImage;
    Label1: TLabel;
    Button3: TButton;
    Button4: TButton;
    PopupMenu1: TPopupMenu;
    Addtable1: TMenuItem;
    Addsymbols1: TMenuItem;
    Delete1: TMenuItem;
    Renametable1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    Saveas1: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    ools1: TMenuItem;
    Help1: TMenuItem;
    Charset1: TMenuItem;
    Exit1: TMenuItem;
    Addtable2: TMenuItem;
    Addsymbols2: TMenuItem;
    Renametable2: TMenuItem;
    Delete2: TMenuItem;
    Symbol1: TMenuItem;
    Addrowattop1: TMenuItem;
    Addrowatbottom1: TMenuItem;
    Removerowattop1: TMenuItem;
    Removerowatbottom1: TMenuItem;
    Addcolumnatleft1: TMenuItem;
    Addcolumnatright1: TMenuItem;
    Removecolumnatleft1: TMenuItem;
    Removecolumnatright1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    Moveup1: TMenuItem;
    Movedown1: TMenuItem;
    Moveleft1: TMenuItem;
    Moderight1: TMenuItem;
    New1: TMenuItem;
    Makesources1: TMenuItem;
    Abuot: TMenuItem;
    Repaintall1: TMenuItem;
    Autorepaint1: TMenuItem;
    N3: TMenuItem;
    Font1: TMenuItem;
    Select1: TMenuItem;
    Increasesize1: TMenuItem;
    Decreasesize1: TMenuItem;
    procedure FR_FullRepaint(Sender: TObject);
    procedure FR_SelectFont(Sender: TObject);
    procedure FR_AddRange(Sender: TObject);
    procedure FR_DecFontSize(Sender: TObject);
    procedure FR_IncFontSize(Sender: TObject);
    procedure FR_AddTable(Sender: TObject);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FR_Delete(Sender: TObject);
    procedure TreeView1Deletion(Sender: TObject; Node: TTreeNode);
    procedure FormResize(Sender: TObject);
    procedure FR_RenameTable(Sender: TObject);
    procedure TreeView1DragDrop(Sender, Source: TObject; X, Y: integer);
    procedure TreeView1DragOver(Sender, Source: TObject; X, Y: integer;
      State: TDragState; var Accept: Boolean);
    procedure TreeView1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Save1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Saveas1Click(Sender: TObject);
    procedure Autorepaint1Click(Sender: TObject);
  private
    // curNode: TTreeNode;
    face: TFTFace;
    pFont: PByte;
    font_mem_size: integer;
    extended_font_name: string;
    glyph_names_arr: array [0 .. UnicodeArrSize] of TUnicodeData;
    procedure FR_Save(FName: string);
    procedure FR_Load(FName: string);
    procedure FR_SetFont;
    procedure FR_ShowSymbol(var symbol: PSymb);
    procedure FR_LoadUnicodeNames;
    procedure FR_Render(symb: PSymb);
    procedure FR_FreeSymb(var symb: PSymb);
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
  if font_mem_size = 0 then
  begin
    MessageDlg('Font must be selected first', mtInformation, [mbOk], 0);
    exit;
  end;
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

procedure TForm1.Autorepaint1Click(Sender: TObject);
begin
  Autorepaint1.Checked := not Autorepaint1.Checked;
end;

procedure TForm1.FR_SelectFont(Sender: TObject);
begin
  if FontDialog1.Execute(Application.Handle) then
  begin
    FR_SetFont;
    if Autorepaint1.Checked then
      FR_FullRepaint(Sender);
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  FR_Save('saving.dat');
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  FR_Load('saving.dat');
end;

procedure TForm1.FR_AddRange(Sender: TObject);
var
  i: integer;
  psy: PSymb;
begin
  if Form2.Execute and (TreeView1.Selected <> nil) then
    for i := Form2.RangeBegin to Form2.RangeEnd do
    begin
      psy := new(PSymb);
      psy.Code := i;
      psy.BufferSize :=0;
      psy.Buffer := nil;
      if TreeView1.Selected.Parent = nil then
        TreeView1.Items.AddChildObject(TreeView1.Selected,
          '''' + chr(psy.Code) + '''' + ' - ' + IntToStr(psy.Code), psy)
      else
        TreeView1.Items.AddObject(TreeView1.Selected, '''' + chr(psy.Code) +
          '''' + ' - ' + IntToStr(psy.Code), psy);

    end;
end;

procedure TForm1.FR_DecFontSize(Sender: TObject);
begin
  if font_mem_size = 0 then
  begin
    MessageDlg('Font must be selected first', mtInformation, [mbOk], 0);
    exit;
  end;
  FontDialog1.Font.Size := FontDialog1.Font.Size - 1;
  FR_SetFont;
  if Autorepaint1.Checked then
    FR_FullRepaint(Sender);
end;

procedure TForm1.FR_IncFontSize(Sender: TObject);
begin
  if font_mem_size = 0 then
  begin
    MessageDlg('Font must be selected first', mtInformation, [mbOk], 0);
    exit;
  end;
  FontDialog1.Font.Size := FontDialog1.Font.Size + 1;
  FR_SetFont;
  if Autorepaint1.Checked then
    FR_FullRepaint(Sender);
end;

procedure TForm1.FR_Delete(Sender: TObject);
begin
  TreeView1.Selected.Delete;
end;

function TForm1.FR_FontStyleToString(style: TFontStyles): string;
begin
  Result := '';
  if fsStrikeOut in style then
    Result := Result + 'StrikeOut ';
  if fsUnderline in style then
    Result := Result + 'Underline ';
end;

procedure TForm1.FR_FreeSymb(var symb: PSymb);
begin
  if symb <> nil then
  begin
    if symb.Buffer <> nil then
      FreeMemory(symb.Buffer);
    Dispose(symb);
  end;
  symb := nil;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  StatusBar1.Panels[3].Text :=
    ('FreeType''s version is ' + IntToStr(TFTManager.MajorVersion) + '.' +
    IntToStr(TFTManager.MinorVersion) + '.' + IntToStr(TFTManager.PatchVersion))
    + '       ';
  font_mem_size := 0;
  FR_LoadUnicodeNames;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if font_mem_size > 0 then
  begin
    face.glyph.Bitmap.Done;
    face.Destroy;
    FreeMemory(pFont);
  end;

end;

procedure TForm1.FormResize(Sender: TObject);
var
  psy: PSymb;
begin
  if TreeView1.Selected = nil then
    exit;
  psy := TreeView1.Selected.Data;
  FR_ShowSymbol(psy);

end;

procedure TForm1.FR_Save(FName: string);
var
  stream: TMemoryStream;
  f: file;
  i: integer;
  b: byte;
  psy: PSymb;
begin
  stream := TMemoryStream.Create;
  AssignFile(f, FName);
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
  if font_mem_size = 0 then
  begin
    b := 0;
    BlockWrite(f, b, 1);
  end
  else
  begin
    b := 1;
    BlockWrite(f, b, 1);
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
  end;
  CloseFile(f);
  Form1.Caption := 'NS Font Creator' + ' - ' + SaveDialog1.FileName;
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

procedure TForm1.FR_Load(FName: string);
var
  stream: TMemoryStream;
  f: file;
  i: integer;
  b: byte;
  S: string;
  psy: PSymb;
begin
  stream := TMemoryStream.Create;
  AssignFile(f, FName);
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
      TreeView1.Items[i].Text := '''' + chr(psy.Code) + '''' + ' - ' + IntToStr(psy.Code);
    end;
  end;
  BlockRead(f, b, 1);
  if b = 1 then
  begin
    BlockRead(f, i, sizeof(integer));
    FontDialog1.Font.Charset := TFontCharset(i);
    BlockRead(f, i, sizeof(integer));
    FontDialog1.Font.Color := TColor(i);
    BlockRead(f, i, sizeof(integer));
    FontDialog1.Font.Size := i;
    BlockRead(f, i, sizeof(integer));
    FontDialog1.Font.style := TFontStyles(byte(i));
    BlockRead(f, i, sizeof(integer));
    SetLength(S, i);
    BlockRead(f, S[1], (i) * sizeof(char));
    FontDialog1.Font.Name := S;
    FR_SetFont;
  end;

  // TreeView1.Select(TreeView1.Items[0]);
  CloseFile(f);
  Form1.Caption := 'NS Font Creator' + ' - ' + OpenDialog1.FileName;
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
  i := 0;
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
  extended_font_name := string(face.FamilyName) + ' ' + string(face.StyleName) +
    ' ' + FR_FontStyleToString(FontDialog1.Font.style) +
    string(IntToStr(FontDialog1.Font.Size));
  StatusBar1.Panels[0].Text := extended_font_name;

  StatusBar1.Panels[1].Text := IntToStr(face.Size.Metrics.Height div 64) + 'x' +
    IntToStr(face.Size.Metrics.MaxAdvance div 64);
end;

procedure TForm1.FR_ShowSymbol(var symbol: PSymb);
var
  i, j: integer;
  X, Y: integer;
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
  if (symbol = nil) or (symbol.Buffer = nil) then
  begin
    Image2.Canvas.Font := Form1.Font;
    SetTextAlign(Image2.Canvas.Handle, TA_CENTER);
    Image2.Canvas.TextOut(Image2.Width div 2, Image2.Height div 2, 'NO DATA');
    exit;
  end;
  // вычисление размера сетки
  grid_size := round(Image2.Height * 7 / 10 / symbol.Heigth);
  i := round(Image2.Width * 5 / 10 / symbol.Width);
  if i < grid_size then
    grid_size := i;
  // вычисление координат
  origin.X := round(Image2.Width / 8);
  origin.Y := round(Image2.Height * 9 / 12);
  bbox.Left := origin.X;
  bbox.Right := origin.X + symbol.Advance * grid_size;
  bbox.Top := origin.Y - symbol.Ascender * grid_size;
  bbox.Bottom := origin.Y - symbol.Descender * grid_size;
  // заливка коробки белым
  Image2.Canvas.Brush.Color := clWhite;
  for X := symbol.BearingX to symbol.Width - 1 + symbol.BearingX do
    for Y := 0 to symbol.Heigth - 1 do
    begin
      R := Rect(bbox.Left + X * grid_size, bbox.Top + Y * grid_size,
        bbox.Left + X * grid_size + grid_size, bbox.Top + Y * grid_size +
        grid_size);
      Image2.Canvas.FillRect(R);
    end;
  // отрисовка символа
  Image2.Canvas.Brush.Color := clBlack;
  for i := 0 to symbol.BufferSize - 1 do
    for j := 0 to 7 do
    begin
      X := i div symbol.BytesPerColumn + symbol.BearingX;
      Y := 8 * (i mod symbol.BytesPerColumn) + j;
      R := Rect(bbox.Left + X * grid_size, bbox.Top + Y * grid_size,
        bbox.Left + X * grid_size + grid_size, bbox.Top + Y * grid_size +
        grid_size);
      if (symbol.Buffer[i] shl j) and 128 > 0 then
        Image2.Canvas.FillRect(R);
    end;
  // отрисовка сетки
  with Image2.Canvas do
  begin
    // горизонтальные черные линии
    pen.Color := clBlack;
    j := origin.Y;
    while j > 0 do // выше базовой
    begin
      MoveTo(0, j);
      LineTo(Image2.Width, j);
      dec(j, grid_size);
    end;
    j := origin.Y;
    while j < Image2.Height do // ниже базовой
    begin
      MoveTo(0, j);
      LineTo(Image2.Width, j);
      inc(j, grid_size);
    end;
    // горизонтальные красные линии
    pen.Color := clRed;
    MoveTo(0, origin.Y);
    LineTo(Image2.Width, origin.Y); // базовая линия горизонтальная
    MoveTo(0, bbox.Top);
    LineTo(Image2.Width, bbox.Top); // Ascender
    MoveTo(0, bbox.Bottom);
    LineTo(Image2.Width, bbox.Bottom); // Descender
    // вертикальные черные линии
    pen.Color := clBlack;
    j := origin.X;
    while j > 0 do // левее базовой
    begin
      MoveTo(j, 0);
      LineTo(j, Image2.Height);
      dec(j, grid_size);
    end;
    j := origin.X;
    while j < Image2.Width do // правее базовой
    begin
      MoveTo(j, 0);
      LineTo(j, Image2.Height);
      inc(j, grid_size);
    end;
    // вертикальные красные линии
    pen.Color := clRed;
    MoveTo(origin.X, 0);
    LineTo(origin.X, Image2.Height); // базовая линия вертикальная
    MoveTo(bbox.Right, 0);
    LineTo(bbox.Right, Image2.Height); // Advance
  end;
  StatusBar1.Panels[2].Text := FR_SearchUnicodeName(symbol.Code);
end;

procedure TForm1.Open1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    FR_Load(OpenDialog1.FileName);    
    // SaveDialog1.FileName:=OpenDialog1.FileName;
  end;
end;

procedure TForm1.FR_RenameTable(Sender: TObject);
var
  S: string;
begin
  if TreeView1.Selected.Parent <> nil then
    TreeView1.Selected := TreeView1.Selected.Parent;
  S := TreeView1.Selected.Text;
  if InputQuery('Rename table', 'Enter new name:', S) then
    TreeView1.Selected.Text := S;
end;

procedure TForm1.Save1Click(Sender: TObject);
begin
  if OpenDialog1.FileName <> '' then
    FR_Save(OpenDialog1.FileName)
  else
  begin
    SaveDialog1.FileName := extended_font_name;
    if SaveDialog1.Execute then
      if not FileExists(SaveDialog1.FileName) then
        FR_Save(SaveDialog1.FileName)
      else if MessageDlg('File is exist. Rewrite?', mtConfirmation,
        [mbYes, mbNo], 0) = mrYes then
        FR_Save(SaveDialog1.FileName);
  end;
end;

procedure TForm1.Saveas1Click(Sender: TObject);

begin
  SaveDialog1.FileName := extended_font_name;
  if SaveDialog1.Execute then
    if not FileExists(SaveDialog1.FileName) then
      FR_Save(SaveDialog1.FileName)
    else if MessageDlg('File is exist. Rewrite?', mtConfirmation, [mbYes, mbNo],
      0) = mrYes then
      FR_Save(SaveDialog1.FileName);
end;

procedure TForm1.TreeView1Change(Sender: TObject; Node: TTreeNode);
var
  psy: PSymb;
begin
  if (Node.getFirstChild = nil) and (Node.Parent <> nil) then
  begin
    psy := Node.Data;
    FR_ShowSymbol(psy);
  end;
end;

procedure TForm1.TreeView1Deletion(Sender: TObject; Node: TTreeNode);
var
  psy: PSymb;
begin
  psy := Node.Data;
  FR_FreeSymb(psy);
end;

procedure TForm1.TreeView1DragDrop(Sender, Source: TObject; X, Y: integer);
var
  AnItem: TTreeNode;
  AttachMode: TNodeAttachMode;
  HT: THitTests;
begin
  AttachMode := naInsert;
  if TreeView1.Selected = nil then
    exit;
  HT := TreeView1.GetHitTestInfoAt(X, Y);
  AnItem := TreeView1.GetNodeAt(X, Y);
  if (HT - [htOnItem, htOnIcon, htNowhere, htOnIndent, htOnRight] <> HT) then
  begin
    if (htOnItem in HT) or (htOnIcon in HT) then
    begin
      if (AnItem.Parent = nil) and (TreeView1.Selected.Parent <> nil) then
        AttachMode := naAddChild
      else
        AttachMode := naInsert;
    end
    else if htNowhere in HT then
      AttachMode := naAdd
    else if (htOnIndent in HT) or (htOnRight in HT) then
      AttachMode := naInsert;
    TreeView1.Selected.MoveTo(AnItem, AttachMode);
  end;
end;

procedure TForm1.TreeView1DragOver(Sender, Source: TObject; X, Y: integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := Sender = Source;
end;

procedure TForm1.TreeView1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DELETE) and (TreeView1.Selected <> nil) then
    TreeView1.Selected.Delete;
  // if (Key = VK_UP) and (ssShift in Shift) then
  // TreeView1.Selected.MoveTo(TreeView1.Items[TreeView1.Selected.Index-1],naInsert);
end;

end.
