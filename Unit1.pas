unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.UITypes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFreeType, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.jpeg, Vcl.Grids, Vcl.ComCtrls, Vcl.Menus, Vcl.ToolWin,
  FontRasterizer, UnicodeNames, Vcl.ButtonGroup, Vcl.Buttons, Vcl.ValEdit;

type
  TForm1 = class(TForm)
    FontDialog1: TFontDialog;
    Panel1: TPanel;
    TreeView1: TTreeView;
    Splitter2: TSplitter;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    StatusBar1: TStatusBar;
    Image2: TImage;
    Label1: TLabel;
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
    Addcolumnatleft1: TMenuItem;
    Addcolumnatright1: TMenuItem;
    Removecolumnatleft1: TMenuItem;
    Removecolumnatright1: TMenuItem;
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
    SaveDialog2: TSaveDialog;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    Clone1: TMenuItem;
    Clone2: TMenuItem;
    N1: TMenuItem;
    Add1: TMenuItem;
    Addrowatbottom1: TMenuItem;
    Removerowattop1: TMenuItem;
    Removerowattop2: TMenuItem;
    SpeedButton9: TSpeedButton;
    SpeedButton10: TSpeedButton;
    SpeedButton11: TSpeedButton;
    SpeedButton12: TSpeedButton;
    ValueListEditor1: TValueListEditor;
    N4: TMenuItem;
    Cropheight1: TMenuItem;
    procedure FR_FullRepaint(Sender: TObject);
    procedure FR_SelectFont(Sender: TObject);
    procedure FR_AddRange(Sender: TObject);
    procedure FR_DecFontSize(Sender: TObject);
    procedure FR_IncFontSize(Sender: TObject);
    procedure FR_AddTable(Sender: TObject);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
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
    procedure Image2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure Clone1Click(Sender: TObject);
    procedure Addrowatbottom1Click(Sender: TObject);
    procedure Add1Click(Sender: TObject);
    procedure Removerowattop2Click(Sender: TObject);
    procedure Removerowattop1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure Image2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure Image2MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure Cropheight1Click(Sender: TObject);
  private
    move_btn: TMouseButton;
    isDown: Boolean;
    procedure ClearImg;
    procedure FR_Save(FName: string);
    procedure FR_Load(FName: string);
    procedure FR_GenerateNew;
    function gen_table(var f: TextFile; table: TTreeNode): string;
    function mv_spaces(S: string): string;
    procedure UpdateInfo;

  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses add_table, Unit3;

function GetEntryCount(C: char; S: string): integer;
var
  i: integer;
begin
  Result := 0;
  for i := 1 to Length(S) do
    if S[i] = C then
      inc(Result);
end;

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
  i: integer;
begin
  if (font_data = nil) then
  begin
    FR_SelectFont(Sender);
    exit;
  end;
  FR_SetFont(FontDialog1.Font);
  for i := 0 to TreeView1.Items.Count - 1 do
    if TreeView1.Items[i].Parent <> nil then
    begin
      TSymbol(TreeView1.Items[i].Data).Render;
    end;
  ClearImg;
  if (TreeView1.Selected <> nil) and (TreeView1.Selected.Parent <> nil) then
    TSymbol(TreeView1.Selected.Data).Show(Image2);
  UpdateInfo;
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
    if Autorepaint1.Checked then
      FR_FullRepaint(Sender);
    UpdateInfo;
  end;
end;

function TForm1.gen_table(var f: TextFile; table: TTreeNode): string;
var
  psy: TSymbol;
  tmp: TTreeNode;
  S: string;
  p: ^integer;
begin
  S := '';
  tmp := table.getFirstChild;
  while tmp <> nil do
  begin
    psy := tmp.Data;
    S := S + psy.Build(f) + ', ';
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

procedure TForm1.Image2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if (TreeView1.Selected <> nil) and (TreeView1.Selected.Parent <> nil) then
  begin
    TSymbol(TreeView1.Selected.Data).ChangePixel(Image2, Button, Shift, X, Y);
    TSymbol(TreeView1.Selected.Data).Show(Image2);
  end;
  move_btn := Button;
  isDown := true;
end;

procedure TForm1.Image2MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin
  if not isDown then
    exit;
  if (TreeView1.Selected <> nil) and (TreeView1.Selected.Parent <> nil) then
  begin
    TSymbol(TreeView1.Selected.Data).ChangePixel(Image2, move_btn, Shift, X, Y);
    TSymbol(TreeView1.Selected.Data).Show(Image2);
  end;
end;

procedure TForm1.Image2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  isDown := false;
end;

procedure TForm1.Makesources1Click(Sender: TObject);
begin
  FR_GenerateNew;
end;

procedure TForm1.Movedown1Click(Sender: TObject);
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;
  TSymbol(TreeView1.Selected.Data).MoveDown;
  TSymbol(TreeView1.Selected.Data).Show(Image2);
end;

procedure TForm1.Moveleft1Click(Sender: TObject);
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;
  TSymbol(TreeView1.Selected.Data).MoveLeft;
  TSymbol(TreeView1.Selected.Data).Show(Image2);
end;

procedure TForm1.Moveright1Click(Sender: TObject);
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;
  TSymbol(TreeView1.Selected.Data).MoveRight;
  TSymbol(TreeView1.Selected.Data).Show(Image2);
end;

procedure TForm1.Moveup1Click(Sender: TObject);
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;
  TSymbol(TreeView1.Selected.Data).MoveUp;
  TSymbol(TreeView1.Selected.Data).Show(Image2);
end;

function TForm1.mv_spaces(S: string): string;
var
  i: integer;
begin
  Result := '';
  for i := 1 to Length(S) do
    if S[i] = ' ' then
      Result := Result + '_'
    else
      Result := Result + S[i];
end;

procedure TForm1.New1Click(Sender: TObject);
begin
  TreeView1.Items.Clear;
  ClearImg;
  SaveDialog1.FileName := '';
  SaveDialog2.FileName := '';
  OpenDialog1.FileName := '';
  font_data.extended_font_name := '';
  Form1.Caption := 'NS Font Creator';

  FR_FreeFont;

  StatusBar1.Panels[0].Text := '';
  StatusBar1.Panels[1].Text := '';
  StatusBar1.Panels[2].Text := '';
  ValueListEditor1.Values['Height'] := '';
  ValueListEditor1.Values['Ascender'] := '';
  ValueListEditor1.Values['Descender'] := '';
  ValueListEditor1.Values['MaxAdvance'] := '';
  ValueListEditor1.Values['BPC'] := '';
  ValueListEditor1.Values['Advance'] := '';
  ValueListEditor1.Values['BearingX'] := '';
  ValueListEditor1.Values['BearingY'] := '';
  ValueListEditor1.Values['FreeTop'] := '';
  ValueListEditor1.Values['FreeBottom'] := '';
  ValueListEditor1.Values['GlyphHeight'] := '';
  ValueListEditor1.Values['GlyphWidth'] := '';

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
  if OpenDialog1.FileName <> '' then
  begin
    S := OpenDialog1.FileName;
    while pos('\', S) <> 0 do
      delete(S, 1, pos('\', S));
    delete(S, pos('.', S), Length(S));
    SaveDialog2.FileName := mv_spaces(S) + '.c';
  end
  else
  begin
    SaveDialog2.FileName := mv_spaces(font_data.extended_font_name) + '.c';
  end;
  if not SaveDialog2.Execute then
    exit;
  if FileExists(SaveDialog2.FileName) then
    if MessageDlg('File is exist. Rewrite?', mtConfirmation, [mbYes, mbCancel],
      0) = mrCancel then
      exit;
  S := '';
  AssignFile(f, SaveDialog2.FileName);
  rewrite(f);
  writeln(f, '/* This font generated by NS Font creator */');
  writeln(f);
  writeln(f, '#include "NS_fonts.h"');
  writeln(f);
  writeln(f, '#if ' + UpperCase(mv_spaces(font_data.extended_font_name)));
  writeln(f);
  for i := 0 to TreeView1.Items.Count - 1 do
    if TreeView1.Items[i].Parent = nil then
      S := S + '&' + gen_table(f, TreeView1.Items[i]) + ', ';
  if GetEntryCount(',', S) = 1 then
    S := S + S;
  writeln(f, 'const TFont ' + mv_spaces(font_data.extended_font_name) + ' = {');
  write(f, #9);
  if font_data <> nil then
    writeln(f, IntToStr(font_data.Height) + ', ' +
      IntToStr(font_data.MaxAdvance) + ', ' + IntToStr(font_data.bpc) + ',');

  writeln(f, #9, '{' + S + '}');
  writeln(f, '};');
  writeln(f, '//const PFont p' + mv_spaces(font_data.extended_font_name) +
    ' = &' + mv_spaces(font_data.extended_font_name) + ';');
  writeln(f, '#endif');
  writeln(f);
  writeln(f, '#ifndef ' + UpperCase(mv_spaces(font_data.extended_font_name)));
  writeln(f);
  writeln(f, '//Copy this to "NS_fonts.h"');
  writeln(f, '#define ' + UpperCase(mv_spaces(font_data.extended_font_name)) +
    #9 + '1');
  writeln(f);
  writeln(f, '#ifdef ' + UpperCase(mv_spaces(font_data.extended_font_name)));
  writeln(f, 'extern const TFont ' +
    mv_spaces(font_data.extended_font_name) + ';');
  writeln(f, '#endif ');
  writeln(f);
  writeln(f, '#endif ');
  CloseFile(f);
end;

procedure TForm1.ClearImg;
begin
  // ������� �����
  Image2.Picture.Bitmap.Width := Image2.Width;
  Image2.Picture.Bitmap.Height := Image2.Height;
  Image2.Canvas.Brush.Color := clGray;
  Image2.Canvas.FillRect(Rect(0, 0, Image2.Width, Image2.Height));
end;

procedure TForm1.Clone1Click(Sender: TObject);
var
  psy: TSymbol;
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Parent = nil) then
    exit;
  psy := TSymbol.Create(TSymbol(TreeView1.Selected.Data).Code);
  psy.CopyData(TSymbol(TreeView1.Selected.Data));

  TreeView1.Items.AddObjectFirst(TreeView1.Selected, '''' + chr(psy.Code) + ''''
    + ' - ' + IntToStr(psy.Code), psy);
end;

procedure TForm1.Cropheight1Click(Sender: TObject);
var
  i, X: integer;
  min_top, min_bot: integer;
begin
  if font_data.Height = 0 then
    exit;
  min_top := font_data.Height;
  min_bot := font_data.Height;
  for i := 0 to TreeView1.Items.Count - 1 do
    if (TreeView1.Items[i] <> nil) and (TreeView1.Items[i].Parent <> nil) and
      (TreeView1.Items[i].Data <> nil) then
    begin
      X := TSymbol(TreeView1.Items[i].Data).FreeTop;
      if X < min_top then
        min_top := X;
      X := TSymbol(TreeView1.Items[i].Data).FreeBottom;
      if X < min_bot then
        min_bot := X;
    end;
  for i := 1 to min_top do
    Removerowattop1Click(Form1);
  for i := 1 to min_bot do
    Removerowattop2Click(Form1);
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.FR_AddRange(Sender: TObject);
var
  i: integer;
  p: ^integer;
  psy: TSymbol;
begin
  if Form2.Execute and (TreeView1.Selected <> nil) then
    for i := 0 to Form2.CharList.Count - 1 do
    begin
      p := Form2.CharList[i];
      psy := TSymbol.Create(p^);
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
    FR_SelectFont(Sender);
    exit;
  end;
  FontDialog1.Font.Size := FontDialog1.Font.Size - 1;
  FR_SetFont(FontDialog1.Font);
  if Autorepaint1.Checked then
    FR_FullRepaint(Sender);
  UpdateInfo;
end;

procedure TForm1.FR_IncFontSize(Sender: TObject);
begin
  if font_data = nil then
  begin
    FR_SelectFont(Sender);
    exit;
  end;
  FontDialog1.Font.Size := FontDialog1.Font.Size + 1;
  FR_SetFont(FontDialog1.Font);
  if Autorepaint1.Checked then
    FR_FullRepaint(Sender);
  UpdateInfo;
end;

procedure TForm1.FR_Delete(Sender: TObject);
begin
  TreeView1.Selected.delete;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var
  f: file of Byte;
  Wp: TWindowPlacement;
begin
  AssignFile(f, ExtractFileDir(Application.ExeName) + '\params.dat');
  if GetWindowPlacement(Form1.Handle, @Wp) then
  begin
    rewrite(f);
    BlockWrite(f, Wp, sizeof(TWindowPlacement));
    CloseFile(f);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  StatusBar1.Panels[3].Text :=
    ('FreeType''s version is ' + IntToStr(TFTManager.MajorVersion) + '.' +
    IntToStr(TFTManager.MinorVersion) + '.' + IntToStr(TFTManager.PatchVersion))
    + '       ';
  FR_CreateFont;
  ClearImg;
  if ParamCount = 1 then
  begin
    OpenDialog1.FileName := ParamStr(1);
    FR_Load(OpenDialog1.FileName);
    SaveDialog1.FileName := OpenDialog1.FileName;
    Form1.Caption := 'NS Font Creator' + ' - ' + OpenDialog1.FileName;
    UpdateInfo;
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FR_FreeFont;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  ClearImg;
  if TreeView1.Selected = nil then
    exit;
  if TreeView1.Selected.Parent <> nil then
  begin
    TSymbol(TreeView1.Selected.Data).Show(Image2);
  end;

end;

procedure TForm1.FormShow(Sender: TObject);
var
  f: file of Byte;
  Wp: TWindowPlacement;
begin
  AssignFile(f, ExtractFileDir(Application.ExeName) + '\params.dat');
  if FileExists(ExtractFileDir(Application.ExeName) + '\params.dat') then
  begin
    reset(f);
    BlockRead(f, Wp, sizeof(TWindowPlacement));
    CloseFile(f);
    SetWindowPlacement(Form1.Handle, @Wp);
  end;
end;

procedure TForm1.FR_Save(FName: string);
var
  stream: TMemoryStream;
  f: file;
  i: integer;
  b: Byte;
  psy: TSymbol;
  p: ^integer;
begin
  stream := TMemoryStream.Create; // ��������� ������
  AssignFile(f, FName);
  rewrite(f, 1);
  TreeView1.SaveToStream(stream);
  i := stream.Size;
  BlockWrite(f, i, sizeof(integer)); // ������ ������� ������
  BlockWrite(f, stream.Memory^, i); // ������ ������
  stream.Free;

  for i := 0 to TreeView1.Items.Count - 1 do // ���������� ������ ������
  begin
    if TreeView1.Items[i].Parent <> nil then
    begin
      b := 1; // 1 - ��������
      BlockWrite(f, b, 1); // ������ ��������
      psy := TreeView1.Items[i].Data;
      psy.WriteToFile(f); // ������ ��������� ������� � ������� ��������
    end
    else
    begin
      b := 0; // 0 - ������
      BlockWrite(f, b, 1); // ������ ��������
      p := TreeView1.Items[i].Data;
      BlockWrite(f, p^, sizeof(integer)); // ������ ������� �������
    end;
  end;

  if font_data = nil then // ���������� ���������� ������
  begin
    b := 0; // 0 - ��� ������ � ������
    BlockWrite(f, b, 1);
  end
  else
  begin
    b := 1; // 1 - ���� ������ � ������
    BlockWrite(f, b, 1);
    BlockWrite(f, font_data^, sizeof(T_FR_Font) - sizeof(string));
    b := Length(font_data.extended_font_name);
    BlockWrite(f, b, sizeof(integer));
    BlockWrite(f, font_data.extended_font_name[1], b * sizeof(char));

    i := FontDialog1.Font.Charset;
    BlockWrite(f, i, sizeof(integer));
    i := FontDialog1.Font.Color;
    BlockWrite(f, i, sizeof(integer));
    i := FontDialog1.Font.Size;
    BlockWrite(f, i, sizeof(integer));
    i := Byte(FontDialog1.Font.style);
    BlockWrite(f, i, sizeof(integer));
    i := Length(FontDialog1.Font.Name);
    BlockWrite(f, i, sizeof(integer));
    BlockWrite(f, FontDialog1.Font.Name[1], i * sizeof(char));
  end;
  CloseFile(f);
  Form1.Caption := 'NS Font Creator' + ' - ' + SaveDialog1.FileName;
  OpenDialog1.FileName := SaveDialog1.FileName;
end;

procedure TForm1.FR_Load(FName: string);
var
  stream: TMemoryStream;
  f: file;
  i: integer;
  b: Byte;
  S: string;
  psy: TSymbol;
  p: ^integer;
begin

  stream := TMemoryStream.Create; // �������� ������
  AssignFile(f, FName);
  reset(f, 1);
  BlockRead(f, i, sizeof(integer));
  stream.SetSize(i);
  BlockRead(f, stream.Memory^, i);
  TreeView1.LoadFromStream(stream);
  stream.Free;

  for i := 0 to TreeView1.Items.Count - 1 do // �������� ������ ������
  begin
    BlockRead(f, b, 1); // ������ ��������
    if b = 1 then // ��������
    begin
      psy := TSymbol.Create(0);
      psy.ReadFromFile(f);
      TreeView1.Items[i].Data := psy;
      TreeView1.Items[i].Text := '''' + chr(psy.Code) + '''' + ' - ' +
        IntToStr(psy.Code);
    end
    else // ������
    begin
      new(p);
      BlockRead(f, p^, sizeof(integer)); // ������ ������� �������
      TreeView1.Items[i].Data := p;
    end;
  end;

  BlockRead(f, b, 1); // ������ ������� ������ � ������
  if b = 1 then
  begin
    BlockRead(f, font_data^, sizeof(T_FR_Font) - sizeof(string));
    BlockRead(f, b, sizeof(integer));
    SetLength(font_data.extended_font_name, b);
    BlockRead(f, font_data.extended_font_name[1], b * sizeof(char));

    BlockRead(f, i, sizeof(integer));
    FontDialog1.Font.Charset := TFontCharset(i);
    BlockRead(f, i, sizeof(integer));
    FontDialog1.Font.Color := TColor(i);
    BlockRead(f, i, sizeof(integer));
    FontDialog1.Font.Size := i;
    BlockRead(f, i, sizeof(integer));
    FontDialog1.Font.style := TFontStyles(Byte(i));
    BlockRead(f, i, sizeof(integer));
    SetLength(S, i);
    BlockRead(f, S[1], (i) * sizeof(char));
    FontDialog1.Font.Name := S;
  end;
  CloseFile(f);
end;

procedure TForm1.Open1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    FR_Load(OpenDialog1.FileName);
    SaveDialog1.FileName := OpenDialog1.FileName;
    Form1.Caption := 'NS Font Creator' + ' - ' + OpenDialog1.FileName;
    UpdateInfo;
  end;
end;

procedure TForm1.Add1Click(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to TreeView1.Items.Count - 1 do
    if TreeView1.Items[i].Parent <> nil then
    begin
      TSymbol(TreeView1.Items[i].Data).AddRowAtBottom;
    end;

  inc(font_data.Height);
  inc(font_data.Ascender);
  if font_data.Height > font_data.bpc * 8 then
    inc(font_data.bpc);

  for i := 0 to TreeView1.Items.Count - 1 do
    if TreeView1.Items[i].Parent <> nil then
    begin
      TSymbol(TreeView1.Items[i].Data).MoveDown;
    end;
  UpdateInfo;
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;
  ClearImg;
  TSymbol(TreeView1.Selected.Data).Show(Image2);

end;

procedure TForm1.Addcolumnatleft1Click(Sender: TObject);
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;
  ClearImg;
  TSymbol(TreeView1.Selected.Data).AddColAtLeft;
  TSymbol(TreeView1.Selected.Data).Show(Image2);
  UpdateInfo;
end;

procedure TForm1.Addcolumnatright1Click(Sender: TObject);
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;
  ClearImg;
  TSymbol(TreeView1.Selected.Data).AddColAtRight;
  TSymbol(TreeView1.Selected.Data).Show(Image2);
  UpdateInfo;
end;

procedure TForm1.Addrowatbottom1Click(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to TreeView1.Items.Count - 1 do
    if TreeView1.Items[i].Parent <> nil then
    begin
      TSymbol(TreeView1.Items[i].Data).AddRowAtBottom;
    end;

  inc(font_data.Height);
  inc(font_data.Ascender);
  if font_data.Height > font_data.bpc * 8 then
    inc(font_data.bpc);
  UpdateInfo;
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;
  ClearImg;
  TSymbol(TreeView1.Selected.Data).Show(Image2);

end;

procedure TForm1.Removecolumnatleft1Click(Sender: TObject);
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;
  ClearImg;
  TSymbol(TreeView1.Selected.Data).DelColAtLeft;
  TSymbol(TreeView1.Selected.Data).Show(Image2);
  UpdateInfo;
end;

procedure TForm1.Removecolumnatright1Click(Sender: TObject);
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;
  ClearImg;
  TSymbol(TreeView1.Selected.Data).DelColAtRight;
  TSymbol(TreeView1.Selected.Data).Show(Image2);
  UpdateInfo;
end;

procedure TForm1.Removerowattop1Click(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to TreeView1.Items.Count - 1 do
    if TreeView1.Items[i].Parent <> nil then
    begin
      TSymbol(TreeView1.Items[i].Data).MoveUp;
      TSymbol(TreeView1.Items[i].Data).DelRowAtBottom;
    end;

  dec(font_data.Height);
  dec(font_data.Ascender);
  if font_data.Height <= (font_data.bpc - 1) * 8 then
    dec(font_data.bpc);
  UpdateInfo;
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;
  ClearImg;
  TSymbol(TreeView1.Selected.Data).Show(Image2);
end;

procedure TForm1.Removerowattop2Click(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to TreeView1.Items.Count - 1 do
    if TreeView1.Items[i].Parent <> nil then
    begin
      TSymbol(TreeView1.Items[i].Data).DelRowAtBottom;
    end;

  dec(font_data.Height);
  dec(font_data.Ascender);
  if font_data.Height <= (font_data.bpc - 1) * 8 then
    dec(font_data.bpc);
  UpdateInfo;
  if (TreeView1.Selected = nil) or (TreeView1.Selected.Text[1] <> '''') then
    exit;
  ClearImg;
  TSymbol(TreeView1.Selected.Data).Show(Image2);
end;

procedure TForm1.FR_RenameTable(Sender: TObject);
var
  S, X: string;
  p: ^integer;
begin
  if TreeView1.Selected.Parent <> nil then
    TreeView1.Selected := TreeView1.Selected.Parent;
  S := TreeView1.Selected.Text;
  X := copy(S, pos(':', S), Length(S));
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
        [mbYes, mbCancel], 0) = mrYes then
        FR_Save(SaveDialog1.FileName);
  end;
end;

procedure TForm1.Saveas1Click(Sender: TObject);
begin
  SaveDialog1.FileName := font_data.extended_font_name;
  if SaveDialog1.Execute then
    if not FileExists(SaveDialog1.FileName) then
      FR_Save(SaveDialog1.FileName)
    else if MessageDlg('File is exist. Rewrite?', mtConfirmation,
      [mbYes, mbCancel], 0) = mrYes then
      FR_Save(SaveDialog1.FileName);
end;

procedure TForm1.TreeView1Change(Sender: TObject; Node: TTreeNode);
var
  psy: TSymbol;
begin
  ClearImg;
  if (Node.Parent <> nil) then
  begin
    psy := Node.Data;
    psy.Show(Image2);
  end;
  UpdateInfo;
end;

procedure TForm1.TreeView1Deletion(Sender: TObject; Node: TTreeNode);
begin
  if Node.Text[1] = '''' then
  begin
    TSymbol(Node.Data).Free;
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
    TreeView1.Selected.delete;
  // if (Key = VK_UP) and (ssShift in Shift) then
  // TreeView1.Selected.MoveTo(TreeView1.Items[TreeView1.Selected.Index-1],naInsert);
end;

procedure TForm1.UpdateInfo;
var
  UD: PUniData;
  psy: TSymbol;
  a, b: integer;
begin
  if (font_data <> nil) and (font_data.Height <> 0) then
  begin
    StatusBar1.Panels[0].Text := font_data.extended_font_name;
    StatusBar1.Panels[1].Text := IntToStr(font_data.Height) + 'x' +
      IntToStr(font_data.min_w) + '..' + IntToStr(font_data.max_w);

    ValueListEditor1.Values['Height'] := IntToStr(font_data.Height);
    ValueListEditor1.Values['Ascender'] := IntToStr(font_data.Ascender);
    ValueListEditor1.Values['Descender'] := IntToStr(font_data.Descender);
    ValueListEditor1.Values['MaxAdvance'] := IntToStr(font_data.MaxAdvance);
    ValueListEditor1.Values['BPC'] := IntToStr(font_data.bpc);
  end;

  if (TreeView1.Selected <> nil) and (TreeView1.Selected.Parent <> nil) then
  begin
    if (TreeView1.Selected.Data <> nil) then
    begin
      psy := TSymbol(TreeView1.Selected.Data);
      ValueListEditor1.Values['Advance'] := IntToStr(psy.Advance);
      ValueListEditor1.Values['BearingX'] := IntToStr(psy.BearingX);
      ValueListEditor1.Values['BearingY'] := IntToStr(psy.BearingY);
      a := psy.FreeTop;
      b := psy.FreeBottom;
      ValueListEditor1.Values['FreeTop'] := IntToStr(a);
      ValueListEditor1.Values['FreeBottom'] := IntToStr(b);
      ValueListEditor1.Values['GlyphHeight'] :=
        IntToStr(font_data.Height - a - b);
      ValueListEditor1.Values['GlyphWidth'] := IntToStr(psy.Width);
      UD := UniNamer.Data[psy.Code];
      StatusBar1.Panels[2].Text := 'U+' + UD.U_plus + ' - ' + UD.Name;
    end;
  end
  else
    StatusBar1.Panels[2].Text := '';

end;

end.
