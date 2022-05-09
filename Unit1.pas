unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.UITypes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFreeType, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.jpeg, Vcl.Grids, Vcl.ComCtrls, Vcl.Menus, Vcl.ToolWin,
  FontRasterizer, UnicodeNames;

type
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
    Moveright1: TMenuItem;
    New1: TMenuItem;
    Makesources1: TMenuItem;
    Abuot: TMenuItem;
    Repaintall1: TMenuItem;
    Autorepaint1: TMenuItem;
    Font1: TMenuItem;
    Select1: TMenuItem;
    Increasesize1: TMenuItem;
    Decreasesize1: TMenuItem;
    N3: TMenuItem;
    Button5: TButton;
    SaveDialog2: TSaveDialog;
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
    procedure Button5Click(Sender: TObject);
    procedure Makesources1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Moveup1Click(Sender: TObject);
    procedure Movedown1Click(Sender: TObject);
    procedure Addcolumnatright1Click(Sender: TObject);
    procedure Addcolumnatleft1Click(Sender: TObject);
    procedure Moveright1Click(Sender: TObject);
    procedure Moveleft1Click(Sender: TObject);
    procedure Removecolumnatleft1Click(Sender: TObject);
    procedure Removecolumnatright1Click(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure Addrowatbottom1Click(Sender: TObject);
  private
    UniNamer: TUnicodeNamer;
    font_data: T_FR_Font;
    procedure FR_Save(FName: string);
    procedure FR_Load(FName: string);
    procedure FR_SetFont;
    procedure FR_ShowSymbol(symbol: PSymb);
    procedure FR_Render(symb: PSymb);
    procedure FR_FreeSymb(symb: PSymb);
    procedure FR_GenerateNew;
    function gen_table(var f: TextFile; table: TTreeNode): string;
    function gen_symb(var f: TextFile; psy: PSymb): string;
    function mv_spaces(S: string): string;
    function FR_FontStyleToString(style: TFontStyles): string;

  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses add_table, Unit3;

procedure TForm1.FR_AddTable(Sender: TObject);
var
  p: ^integer;
begin
  if Form3.Execute then
  begin
    new(p);
    p^ := Form3.FirstChar;
    TreeView1.Items.AddObject(nil, Form3.TableName + ': ' + '''' + chr(p^)
      + '''', p);
  end;
end;

procedure TForm1.FR_FullRepaint(Sender: TObject);
var
  psy: PSymb;
  i: integer;
begin
  if font_data.font_mem_size = 0 then
  begin
    // MessageDlg('Font must be selected first', mtInformation, [mbOk], 0);
    FR_SelectFont(Sender);
    exit;
  end;
  for i := 0 to TreeView1.Items.Count - 1 do
    if TreeView1.Items[i].Parent <> nil then
    begin
      psy := TreeView1.Items[i].Data;
      FR_Render(psy);
      if (TreeView1.Selected <> nil) and (i = TreeView1.Selected.AbsoluteIndex)
      then
        FR_ShowSymbol(psy);
    end;
  StatusBar1.Panels[1].Text :=
    IntToStr(font_data.face.Size.Metrics.Height div 64) + 'x' +
    IntToStr(font_data.min_w) + '..' + IntToStr(font_data.max_w);
end;

procedure TForm1.Addcolumnatleft1Click(Sender: TObject);
var
  psy: PSymb;
  p: PByte;
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;

  psy := TreeView1.Selected.Data;
  p := AllocMem(psy.BufferSize + font_data.bpc);
  CopyMemory(p + font_data.bpc, psy.Buffer, psy.BufferSize);
  FreeMemory(psy.Buffer);
  psy.Buffer := p;
  inc(psy.Width);
  inc(psy.BufferSize, font_data.bpc);
  FR_ShowSymbol(psy);
end;

procedure TForm1.Addcolumnatright1Click(Sender: TObject);
var
  psy: PSymb;
  p: PByte;
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;

  psy := TreeView1.Selected.Data;
  p := AllocMem(psy.BufferSize + font_data.bpc);
  CopyMemory(p, psy.Buffer, psy.BufferSize);
  FreeMemory(psy.Buffer);
  psy.Buffer := p;
  inc(psy.Width);
  inc(psy.BufferSize, font_data.bpc);
  FR_ShowSymbol(psy);
end;

procedure TForm1.Addrowatbottom1Click(Sender: TObject);
var
  psy: PSymb;
  i, j, k: integer;
  isIncBpc: Boolean;
  p: PByte;
begin
  isIncBpc := false;
  inc(font_data.Heigth);
  for i := 0 to TreeView1.Items.Count - 1 do
  begin
    if (TreeView1.Items[i].Text[1] <> '''') or (TreeView1.Items[i].Data = nil)
    then
      continue;
    psy := TreeView1.Items[i].Data;
    if psy.Buffer = nil then
      continue;
    if (font_data.Heigth div 8) > font_data.bpc then
    begin
      isIncBpc := true;
      p := AllocMem(psy.BufferSize + psy.Width);
      k := 0;
      for j := 0 to psy.BufferSize - 1 do
      begin
        p[k] := psy.Buffer[j];
        inc(k);
        if i mod font_data.bpc = font_data.bpc - 1 then
          inc(k);
      end;
      inc(psy.BufferSize, psy.Width);
      FreeMemory(psy.Buffer);
      psy.Buffer := p;
    end;
  end;
  if isIncBpc then
    inc(font_data.bpc);
  psy := TreeView1.Selected.Data;
  FR_ShowSymbol(psy);
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

function TForm1.gen_symb(var f: TextFile; psy: PSymb): string;
var
  UD: PUniData;
  i: integer;
begin
  if psy = nil then
    exit;
  UD := UniNamer.Data[psy.Code];
  writeln(f, '/* ' + 'U+' + UD.U_plus + ' - ' + UD.Name + ' */');
  write(f, 'static const unsigned char _U_' + UD.U_plus + '[] = {');
  Result := '_U_' + UD.U_plus;
  if psy.Buffer = nil then
  begin
    writeln(f, '/* NO DATA */};');
    exit;
  end;
  write(f, '0x', IntToHex(byte(psy.Width)), ', ');
  for i := 0 to psy.BufferSize - 1 do
    write(f, '0x', IntToHex(psy.Buffer[i]), ', ');
  writeln(f, '};');
end;

function TForm1.gen_table(var f: TextFile; table: TTreeNode): string;
var
  tmp: TTreeNode;
  S: string;
  p: ^integer;
begin
  S := '';
  tmp := table.getFirstChild;
  while tmp <> nil do
  begin
    S := S + gen_symb(f, tmp.Data) + ', ';
    tmp := table.GetNextChild(tmp);
  end;
  writeln(f);
  writeln(f, 'static const TFontTable ', '_' + copy(table.Text, 1,
    pos(':', table.Text) - 1), ' = {');
  p := table.Data;
  writeln(f, #9, '''' + chr(p^) + '''' + ',');
  writeln(f, #9, '{ ' + S + '}');
  writeln(f, '};');
  writeln(f);

  Result := '_' + copy(table.Text, 1, pos(':', table.Text) - 1);
end;

procedure TForm1.Makesources1Click(Sender: TObject);
begin
  FR_GenerateNew;
end;

procedure TForm1.Movedown1Click(Sender: TObject);
var
  psy: PSymb;
  i: integer;
  b: integer;
  Y: integer;
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;

  psy := TreeView1.Selected.Data;
  Y := 0;
  for i := 1 to 8 - (font_data.bpc * 8 - font_data.Heigth) do
  begin
    Y := Y shl 1;
    inc(Y);
  end;
  for i := psy.BufferSize - 1 downto 0 do
  begin
    if ((psy.Buffer[i - 1] and 128) <> 0) and
      ((i - 1) mod font_data.bpc <> font_data.bpc - 1) then
      b := 1
    else
      b := 0;
    if i mod font_data.bpc = font_data.bpc - 1 then
      psy.Buffer[i] := ((psy.Buffer[i] shl 1) or b) and Y
    else
      psy.Buffer[i] := (psy.Buffer[i] shl 1) or b;
  end;
  FR_ShowSymbol(psy);
end;

procedure TForm1.Moveleft1Click(Sender: TObject);
var
  psy: PSymb;
  i: integer;
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;

  psy := TreeView1.Selected.Data;
  for i := 0 to psy.BufferSize - font_data.bpc do
  begin
    psy.Buffer[i] := psy.Buffer[i + font_data.bpc];
  end;
  FillChar(psy.Buffer[psy.BufferSize - font_data.bpc], font_data.bpc, 0);
  FR_ShowSymbol(psy);
end;

procedure TForm1.Moveright1Click(Sender: TObject);
var
  psy: PSymb;
  i: integer;
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;

  psy := TreeView1.Selected.Data;
  for i := psy.BufferSize - 1 downto font_data.bpc do
  begin
    psy.Buffer[i] := psy.Buffer[i - font_data.bpc];
  end;
  FillChar(psy.Buffer[0], font_data.bpc, 0);
  FR_ShowSymbol(psy);
end;

procedure TForm1.Moveup1Click(Sender: TObject);
var
  psy: PSymb;
  i: integer;
  b: integer;
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;

  psy := TreeView1.Selected.Data;
  for i := 0 to psy.BufferSize - 1 do
  begin
    if ((psy.Buffer[i + 1] and 1) <> 0) and ((i + 1) mod font_data.bpc <> 0)
    then
      b := 128
    else
      b := 0;
    psy.Buffer[i] := (psy.Buffer[i] shr 1) or b;
  end;
  FR_ShowSymbol(psy);
end;

function TForm1.mv_spaces(S: string): string;
var
  i: integer;
begin
  Result := '';
  for i := 1 to length(S) do
    if S[i] = ' ' then
      Result := Result + '_'
    else
      Result := Result + S[i];
end;

procedure TForm1.New1Click(Sender: TObject);
begin
  TreeView1.Items.Clear;
  FR_ShowSymbol(nil);
  SaveDialog1.FileName := '';
  SaveDialog2.FileName := '';
  OpenDialog1.FileName := '';
  font_data.extended_font_name := '';
  Form1.Caption := 'NS Font Creator';
  if font_data.font_mem_size > 0 then
  begin
    font_data.face.Destroy;
    FreeMemory(font_data.pFont);
    font_data.font_mem_size := 0;
  end;
  StatusBar1.Panels[0].Text := '';
  StatusBar1.Panels[1].Text := '';
  StatusBar1.Panels[2].Text := '';
  FontDialog1.Font.Name := 'Times New Roman';
  FontDialog1.Font.Size := 14;
  FontDialog1.Font.style := [];
end;

procedure TForm1.FR_GenerateNew;
var
  i: integer;
  f: TextFile;
  S: string;
begin
  S := '';
  SaveDialog2.FileName := mv_spaces(font_data.extended_font_name) + '.c';
  if not SaveDialog2.Execute then
    exit;

  AssignFile(f, SaveDialog2.FileName);
  rewrite(f);
  writeln(f, '/* This font generated by NS Font creator */');
  writeln(f);
  writeln(f, '#include "NS_fonts.h"');
  writeln(f);
  for i := 0 to TreeView1.Items.Count - 1 do
    if TreeView1.Items[i].Parent = nil then
      S := S + '&' + gen_table(f, TreeView1.Items[i]) + ', ';

  writeln(f);
  writeln(f, 'static const TFont _' + mv_spaces(font_data.extended_font_name)
    + ' = {');
  write(f, #9);
  if font_data.font_mem_size > 0 then
    writeln(f, IntToStr(Form1.font_data.face.Size.Metrics.Height div 64) + ', '
      + IntToStr(Form1.font_data.face.Size.Metrics.MaxAdvance div 64) + ', ' +
      IntToStr(Form1.font_data.bpc) + ',');

  writeln(f, #9, '{' + S + '}');
  writeln(f, '};');
  writeln(f);
  writeln(f, 'const PFont ' + mv_spaces(font_data.extended_font_name) + ' = &_'
    + mv_spaces(font_data.extended_font_name) + ';');
  CloseFile(f);
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  FR_GenerateNew;
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.FR_AddRange(Sender: TObject);
var
  i: integer;
  p: ^integer;
  psy: PSymb;
begin
  if Form2.Execute and (TreeView1.Selected <> nil) then
    for i := 0 to Form2.CharList.Count - 1 do
    begin
      p := Form2.CharList[i];
      psy := new(PSymb);
      psy.Code := p^;
      psy.BufferSize := 0;
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
  if font_data.font_mem_size = 0 then
  begin
    // MessageDlg('Font must be selected first', mtInformation, [mbOk], 0);
    FR_SelectFont(Sender);
    exit;
  end;
  FontDialog1.Font.Size := FontDialog1.Font.Size - 1;
  FR_SetFont;
  if Autorepaint1.Checked then
    FR_FullRepaint(Sender);
end;

procedure TForm1.FR_IncFontSize(Sender: TObject);
begin
  if font_data.font_mem_size = 0 then
  begin
    // MessageDlg('Font must be selected first', mtInformation, [mbOk], 0);
    FR_SelectFont(Sender);
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

procedure TForm1.FR_FreeSymb(symb: PSymb);
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
  font_data.font_mem_size := 0;
  UniNamer := TUnicodeNamer.Create;
  FR_ShowSymbol(nil);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if font_data.font_mem_size > 0 then
  begin
    font_data.face.glyph.Bitmap.Done;
    font_data.face.Destroy;
    FreeMemory(font_data.pFont);
  end;
  UniNamer.Free;
end;

procedure TForm1.FormResize(Sender: TObject);
var
  psy: PSymb;
begin
  if TreeView1.Selected = nil then
    exit;
  if TreeView1.Selected.Parent <> nil then
  begin
    psy := TreeView1.Selected.Data;
    FR_ShowSymbol(psy);
  end;

end;

procedure TForm1.FR_Save(FName: string);
var
  stream: TMemoryStream;
  f: file;
  i: integer;
  b: byte;
  psy: PSymb;
  p: ^integer;
begin
  stream := TMemoryStream.Create; // соханение дерева
  AssignFile(f, FName);
  rewrite(f, 1);
  TreeView1.SaveToStream(stream);
  i := stream.Size;
  BlockWrite(f, i, sizeof(integer)); // запись размера дерева
  BlockWrite(f, stream.Memory^, i); // запись дерева
  stream.Free;

  for i := 0 to TreeView1.Items.Count - 1 do // сохранение данных дерева
  begin
    if TreeView1.Items[i].Parent <> nil then
    begin
      b := 1; // 1 - листочек
      BlockWrite(f, b, 1); // запись признака
      psy := TreeView1.Items[i].Data;
      BlockWrite(f, psy^, sizeof(TSymb)); // запись структуры символа
      BlockWrite(f, psy.Buffer^, psy.BufferSize); // запись массива пикселей
    end
    else
    begin
      b := 0; // 0 - корень
      BlockWrite(f, b, 1); // запись признака
      p := TreeView1.Items[i].Data;
      BlockWrite(f, p^, sizeof(integer)); // запись первого символа
    end;
  end;

  if font_data.font_mem_size = 0 then // сохранение параметров шрифта
  begin
    b := 0; // 0 - нет данных о шрифте
    BlockWrite(f, b, 1);
  end
  else
  begin
    b := 1; // 1 - есть данные о шрифте
    BlockWrite(f, b, 1);
    BlockWrite(f, font_data.Heigth, sizeof(integer)); // запись данных шрифта
    BlockWrite(f, font_data.bpc, sizeof(integer)); // запись данных шрифта
    BlockWrite(f, font_data.min_w, sizeof(integer)); // запись данных шрифта
    BlockWrite(f, font_data.max_w, sizeof(integer)); // запись данных шрифта

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

procedure TForm1.FR_Load(FName: string);
var
  stream: TMemoryStream;
  f: file;
  i: integer;
  b: byte;
  S: string;
  psy: PSymb;
  p: ^integer;
begin

  stream := TMemoryStream.Create; // загрузка дерева
  AssignFile(f, FName);
  reset(f, 1);
  BlockRead(f, i, sizeof(integer));
  stream.SetSize(i);
  BlockRead(f, stream.Memory^, i);
  TreeView1.LoadFromStream(stream);
  stream.Free;

  for i := 0 to TreeView1.Items.Count - 1 do // загрузка данных дерева
  begin
    BlockRead(f, b, 1); // чтение признака
    if b = 1 then // листочек
    begin
      psy := new(PSymb);
      BlockRead(f, psy^, sizeof(TSymb));
      if psy.BufferSize > 0 then
      begin
        psy.Buffer := GetMemory(psy.BufferSize);
        BlockRead(f, psy.Buffer^, psy.BufferSize);
      end;
      TreeView1.Items[i].Data := psy;
      TreeView1.Items[i].Text := '''' + chr(psy.Code) + '''' + ' - ' +
        IntToStr(psy.Code);
    end
    else // корень
    begin
      new(p);
      BlockRead(f, p^, sizeof(integer)); // чтение первого символа
      TreeView1.Items[i].Data := p;
    end;
  end;

  BlockRead(f, b, 1); // чтения наличия данных о шрифте
  if b = 1 then
  begin
    BlockRead(f, font_data.Heigth, sizeof(integer)); // загрузка данных шрифта
    BlockRead(f, font_data.bpc, sizeof(integer));
    BlockRead(f, font_data.min_w, sizeof(integer));
    BlockRead(f, font_data.max_w, sizeof(integer));
    font_data.font_mem_size := 0;
    font_data.pFont := nil;

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

procedure TForm1.FR_Render(symb: PSymb);
var
  P_x, P_y, i, j, k: integer;
  byte_idx: integer;
  glyph_index: integer;
begin
  if symb.Buffer <> nil then
    FreeMemory(symb.Buffer);

  glyph_index := font_data.face.GetCharIndex(symb.Code);
  font_data.face.LoadGlyph(glyph_index, [ftlfMonochrome, ftlfTargetMono,
    ftlfRender]);
  symb.BearingX := font_data.face.glyph.Metrics.HorzBearingX div 64;
  symb.BearingY := font_data.face.glyph.Metrics.HorzBearingY div 64;
  font_data.Heigth := font_data.face.Size.Metrics.Height div 64;
  symb.Width := font_data.face.glyph.Bitmap.Width; // это правильнее
  symb.Ascender := font_data.face.Size.Metrics.Ascender div 64;
  symb.Descender := font_data.face.Size.Metrics.Descender div 64;
  symb.Advance := font_data.face.glyph.Metrics.HorzAdvance div 64;
  if symb.Code = 32 then
    symb.Width := symb.Advance;

  if symb.Width > font_data.max_w then
    font_data.max_w := symb.Width;
  if symb.Width < font_data.min_w then
    font_data.min_w := symb.Width;
  symb.BufferSize := font_data.bpc * symb.Width;
  symb.Buffer := AllocMem(symb.BufferSize); // не надо очищать
  k := 0;
  for i := 0 to (font_data.face.glyph.Bitmap.Rows *
    font_data.face.glyph.Bitmap.Pitch) - 1 do
  begin
    for j := 0 to 7 do
      if font_data.face.glyph.Bitmap.Buffer[i] shl j and 128 > 0 then
      begin
        P_x := k * 8 + j; // это правильнее
        P_y := (font_data.face.Size.Metrics.Ascender -
          font_data.face.glyph.Metrics.HorzBearingY) div 64 +
          i div font_data.face.glyph.Bitmap.Pitch;
        byte_idx := (P_y div 8) + font_data.bpc * P_x;
        // symb.Buffer[byte_idx] := symb.Buffer[byte_idx] + 1 shl (7 - P_y mod 8); так было изначально, символы перевернуты получаются
        symb.Buffer[byte_idx] := symb.Buffer[byte_idx] +
          128 shr (7 - P_y mod 8);
        // так есть совместимость с GLCD font creator
      end;
    inc(k);
    if k = font_data.face.glyph.Bitmap.Pitch then
      k := 0;
  end;
  font_data.face.glyph.Bitmap.Done;
end;

procedure TForm1.FR_SetFont;
var
  dc: HDC;
begin
  dc := CreateDC('DISPLAY', nil, nil, nil);
  SelectObject(dc, FontDialog1.Font.Handle);
  if font_data.font_mem_size > 0 then
  begin
    font_data.face.Destroy;
    FreeMemory(font_data.pFont);
    font_data.font_mem_size := 0;
  end;
  font_data.font_mem_size := GetFontData(dc, 0, 0, nil,
    font_data.font_mem_size);
  font_data.pFont := GetMemory(font_data.font_mem_size);
  if GetFontData(dc, 0, 0, font_data.pFont, font_data.font_mem_size) = GDI_ERROR
  then
    raise Exception.Create('Failed to get font data.');
  font_data.face := TFTFace.Create(font_data.pFont, font_data.font_mem_size, 0);
  font_data.face.SetPixelSize(0, FontDialog1.Font.Size);
  CancelDC(dc);
  DeleteDC(dc);
  font_data.extended_font_name := string(font_data.face.FamilyName) + ' ' +
    string(font_data.face.StyleName) + ' ' + FR_FontStyleToString
    (FontDialog1.Font.style) + string(IntToStr(FontDialog1.Font.Size));
  StatusBar1.Panels[0].Text := font_data.extended_font_name;
  font_data.Heigth := font_data.face.Size.Metrics.Height div 64;
  font_data.bpc := font_data.Heigth div 8;
  if font_data.bpc * 8 < font_data.Heigth then
    inc(font_data.bpc);
  font_data.max_w := 0;
  font_data.min_w := font_data.face.Size.Metrics.MaxAdvance div 64;
  StatusBar1.Panels[1].Text :=
    IntToStr(font_data.face.Size.Metrics.Height div 64) + 'x' +
    IntToStr(font_data.min_w) + '..' + IntToStr(font_data.max_w)
  // else
  // StatusBar1.Panels[1].Text :=
  // IntToStr(face.Size.Metrics.Height div 64) + 'x??';
end;

procedure TForm1.FR_ShowSymbol(symbol: PSymb);
var
  i, j: integer;
  X, Y: integer;
  grid_size: integer;
  origin: TPoint;
  bbox: TRect;
  R: TRect;
  UD: PUniData;
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
  grid_size := round(Image2.Height * 7 / 10 / font_data.Heigth);
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
    for Y := 0 to font_data.Heigth - 1 do
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
      X := i div font_data.bpc + symbol.BearingX;
      Y := 8 * (i mod font_data.bpc) + j;
      R := Rect(bbox.Left + X * grid_size, bbox.Top + Y * grid_size,
        bbox.Left + X * grid_size + grid_size, bbox.Top + Y * grid_size +
        grid_size);
      // if (symbol.Buffer[i] shl j) and 128 > 0 then
      if (symbol.Buffer[i] shr j) and 1 > 0 then // совместимость с GLCD
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
    LineTo(Image2.Width, origin.Y);
    // базовая линия горизонтальная
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
    LineTo(origin.X, Image2.Height);
    // базовая линия вертикальная
    MoveTo(bbox.Right, 0);
    LineTo(bbox.Right, Image2.Height); // Advance
  end;
  UD := UniNamer.Data[symbol.Code];
  if UD <> nil then
    StatusBar1.Panels[2].Text := 'U+' + UD.U_plus + ' - ' + UD.Name;

end;

procedure TForm1.Open1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    FR_Load(OpenDialog1.FileName);
    SaveDialog1.FileName := OpenDialog1.FileName;
  end;
end;

procedure TForm1.Removecolumnatleft1Click(Sender: TObject);
var
  psy: PSymb;
  p: PByte;
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;

  psy := TreeView1.Selected.Data;
  p := AllocMem(psy.BufferSize - font_data.bpc);
  CopyMemory(p, psy.Buffer + font_data.bpc, psy.BufferSize - font_data.bpc);
  FreeMemory(psy.Buffer);
  psy.Buffer := p;
  dec(psy.Width);
  dec(psy.BufferSize, font_data.bpc);
  FR_ShowSymbol(psy);
end;

procedure TForm1.Removecolumnatright1Click(Sender: TObject);
var
  psy: PSymb;
  p: PByte;
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;

  psy := TreeView1.Selected.Data;
  p := AllocMem(psy.BufferSize - font_data.bpc);
  CopyMemory(p, psy.Buffer, psy.BufferSize - font_data.bpc);
  FreeMemory(psy.Buffer);
  psy.Buffer := p;
  dec(psy.Width);
  dec(psy.BufferSize, font_data.bpc);
  FR_ShowSymbol(psy);
end;

procedure TForm1.FR_RenameTable(Sender: TObject);
var
  S, X: string;
  p: ^integer;
begin
  if TreeView1.Selected.Parent <> nil then
    TreeView1.Selected := TreeView1.Selected.Parent;
  S := TreeView1.Selected.Text;
  X := copy(S, pos(':', S), length(S));
  S := copy(S, 1, pos(':', S) - 1);
  p := TreeView1.Selected.Data;
  Form3.TableName := S;
  Form3.FirstChar := p^;
  if Form3.Execute then
  begin
    p^ := Form3.FirstChar;
    TreeView1.Selected.Text := Form3.TableName + ': ' + '''' + chr(p^) + '''';
  end;
end;

procedure TForm1.Save1Click(Sender: TObject);
begin
  if OpenDialog1.FileName <> '' then
    FR_Save(OpenDialog1.FileName)
  else
  begin
    SaveDialog1.FileName := font_data.extended_font_name;
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
  SaveDialog1.FileName := font_data.extended_font_name;
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
  p: ^integer;
begin
  if Node.Text[1] = '''' then
  begin
    psy := Node.Data;
    FR_FreeSymb(psy);
  end
  else
  begin
    p := Node.Data;
    Dispose(p);
  end;
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
