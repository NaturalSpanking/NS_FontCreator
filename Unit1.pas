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
    procedure FR_Save(FName: string);
    procedure FR_Load(FName: string);
    procedure FR_GenerateNew;
    function gen_table(var f: TextFile; table: TTreeNode): string;
    function mv_spaces(S: string): string;

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
  if font_data = nil then
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
        FR_ShowSymbol(psy, Image2);
    end;
  StatusBar1.Panels[1].Text := IntToStr(font_data.Height) + 'x' +
    IntToStr(font_data.min_w) + '..' + IntToStr(font_data.max_w);
end;

procedure TForm1.Addcolumnatleft1Click(Sender: TObject);
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;
  FR_AddColAtLeft(TreeView1.Selected.Data);
  FR_ShowSymbol(TreeView1.Selected.Data, Image2);
end;

procedure TForm1.Addcolumnatright1Click(Sender: TObject);
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;
  FR_AddColAtRight(TreeView1.Selected.Data);
  FR_ShowSymbol(TreeView1.Selected.Data, Image2);
end;

procedure TForm1.Addrowatbottom1Click(Sender: TObject);
var
  psy: PSymb;
  i, j, k: integer;
  isIncBpc: Boolean;
  p: PByte;
begin
  isIncBpc := false;
  inc(font_data.Height);
  for i := 0 to TreeView1.Items.Count - 1 do
  begin
    if (TreeView1.Items[i].Text[1] <> '''') or (TreeView1.Items[i].Data = nil)
    then
      continue;
    psy := TreeView1.Items[i].Data;
    if psy.Buffer = nil then
      continue;
    if (font_data.Height div 8) > font_data.bpc then
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
  FR_ShowSymbol(psy, Image2);
end;

procedure TForm1.Autorepaint1Click(Sender: TObject);
begin
  Autorepaint1.Checked := not Autorepaint1.Checked;
end;

procedure TForm1.FR_SelectFont(Sender: TObject);
begin
  if FontDialog1.Execute(Application.Handle) then
  begin
    FR_SetFont(FontDialog1.Font);
    StatusBar1.Panels[0].Text := font_data.extended_font_name;
    StatusBar1.Panels[1].Text := IntToStr(font_data.Height div 64) + 'x' +
      IntToStr(font_data.min_w) + '..' + IntToStr(font_data.max_w);
    // else
    // StatusBar1.Panels[1].Text :=
    // IntToStr(face.Size.Metrics.Height div 64) + 'x??';
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
    S := S + FR_BuildSymb(tmp.Data, f) + ', ';
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
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;
  FR_MoveDown(TreeView1.Selected.Data);
  FR_ShowSymbol(TreeView1.Selected.Data, Image2);
end;

procedure TForm1.Moveleft1Click(Sender: TObject);
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;
  FR_MoveLeft(TreeView1.Selected.Data);
  FR_ShowSymbol(TreeView1.Selected.Data, Image2);
end;

procedure TForm1.Moveright1Click(Sender: TObject);
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;
  FR_MoveRight(TreeView1.Selected.Data);
  FR_ShowSymbol(TreeView1.Selected.Data, Image2);
end;

procedure TForm1.Moveup1Click(Sender: TObject);
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;
  FR_MoveUp(TreeView1.Selected.Data);
  FR_ShowSymbol(TreeView1.Selected.Data, Image2);
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
  FR_ShowSymbol(nil, Image2);
  SaveDialog1.FileName := '';
  SaveDialog2.FileName := '';
  OpenDialog1.FileName := '';
  font_data.extended_font_name := '';
  Form1.Caption := 'NS Font Creator';

  FR_FreeFont;

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
  if font_data <> nil then
    writeln(f, IntToStr(font_data.Height) + ', ' +
      IntToStr(font_data.MaxAdvance) + ', ' + IntToStr(font_data.bpc) + ',');

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
      psy := FR_CreateSymb(p^);
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
  if font_data = nil then
  begin
    // MessageDlg('Font must be selected first', mtInformation, [mbOk], 0);
    FR_SelectFont(Sender);
    exit;
  end;
  FontDialog1.Font.Size := FontDialog1.Font.Size - 1;
  FR_SetFont(FontDialog1.Font);
  StatusBar1.Panels[0].Text := font_data.extended_font_name;
  StatusBar1.Panels[1].Text := IntToStr(font_data.Height) + 'x' +
    IntToStr(font_data.min_w) + '..' + IntToStr(font_data.max_w);
  if Autorepaint1.Checked then
    FR_FullRepaint(Sender);
end;

procedure TForm1.FR_IncFontSize(Sender: TObject);
begin
  if font_data = nil then
  begin
    // MessageDlg('Font must be selected first', mtInformation, [mbOk], 0);
    FR_SelectFont(Sender);
    exit;
  end;
  FontDialog1.Font.Size := FontDialog1.Font.Size + 1;
  FR_SetFont(FontDialog1.Font);
  StatusBar1.Panels[0].Text := font_data.extended_font_name;
  StatusBar1.Panels[1].Text := IntToStr(font_data.Height) + 'x' +
    IntToStr(font_data.min_w) + '..' + IntToStr(font_data.max_w);
  if Autorepaint1.Checked then
    FR_FullRepaint(Sender);
end;

procedure TForm1.FR_Delete(Sender: TObject);
begin
  TreeView1.Selected.Delete;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  StatusBar1.Panels[3].Text :=
    ('FreeType''s version is ' + IntToStr(TFTManager.MajorVersion) + '.' +
    IntToStr(TFTManager.MinorVersion) + '.' + IntToStr(TFTManager.PatchVersion))
    + '       ';
  FR_CreateFont;
  FR_ShowSymbol(nil, Image2);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FR_FreeFont;
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
    FR_ShowSymbol(psy, Image2);
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

  if font_data = nil then // сохранение параметров шрифта
  begin
    b := 0; // 0 - нет данных о шрифте
    BlockWrite(f, b, 1);
  end
  else
  begin
    b := 1; // 1 - есть данные о шрифте
    BlockWrite(f, b, 1);
    BlockWrite(f, font_data.Height, sizeof(integer)); // запись данных шрифта
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
      psy := FR_CreateSymb(0);
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
    BlockRead(f, font_data.Height, sizeof(integer)); // загрузка данных шрифта
    BlockRead(f, font_data.bpc, sizeof(integer));
    BlockRead(f, font_data.min_w, sizeof(integer));
    BlockRead(f, font_data.max_w, sizeof(integer));

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
    FR_SetFont(FontDialog1.Font);
  end;

  // TreeView1.Select(TreeView1.Items[0]);
  CloseFile(f);
end;

procedure TForm1.Open1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    FR_Load(OpenDialog1.FileName);
    SaveDialog1.FileName := OpenDialog1.FileName;
    Form1.Caption := 'NS Font Creator' + ' - ' + OpenDialog1.FileName;
    StatusBar1.Panels[0].Text := font_data.extended_font_name;
    StatusBar1.Panels[1].Text := IntToStr(font_data.Height div 64) + 'x' +
      IntToStr(font_data.min_w) + '..' + IntToStr(font_data.max_w);
  end;
end;

procedure TForm1.Removecolumnatleft1Click(Sender: TObject);
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;
  FR_DelColAtLeft(TreeView1.Selected.Data);
  FR_ShowSymbol(TreeView1.Selected.Data, Image2);
end;

procedure TForm1.Removecolumnatright1Click(Sender: TObject);
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;
  FR_DelColAtRight(TreeView1.Selected.Data);
  FR_ShowSymbol(TreeView1.Selected.Data, Image2);
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
  UD: PUniData;
  psy: PSymb;
begin
  if (Node.getFirstChild = nil) and (Node.Parent <> nil) then
  begin
    psy := Node.Data;
    FR_ShowSymbol(psy, Image2);
    UD := UniNamer.Data[psy.Code];
    StatusBar1.Panels[2].Text := 'U+' + UD.U_plus + ' - ' + UD.Name;
  end
  else
    StatusBar1.Panels[2].Text := '';
end;

procedure TForm1.TreeView1Deletion(Sender: TObject; Node: TTreeNode);
begin
  if Node.Text[1] = '''' then
  begin
    FR_FreeSymb(Node.Data);
  end
  else
  begin
    Dispose(Node.Data);
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
