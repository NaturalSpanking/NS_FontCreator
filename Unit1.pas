unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.jpeg, Vcl.Grids, Vcl.ComCtrls, Vcl.Menus, NS_Rasterizer;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    FontDialog1: TFontDialog;
    Button3: TButton;
    StringGrid1: TStringGrid;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Button4: TButton;
    Edit1: TEdit;
    Panel1: TPanel;
    TreeView1: TTreeView;
    Image1: TImage;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    StatusBar1: TStatusBar;
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    raster: TRasterizer;
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
  // Memo1.Lines.Add(S);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i, j, k: integer;
  G,H: PGlyph;
begin
  for i := 0 to StringGrid1.ColCount do
    for j := 0 to StringGrid1.RowCount do
      StringGrid1.Cells[i, j] := '';

   G:=raster.Render(ord('g'),[]);
   H:=raster.Render(ord('h'),[]);
  // StringGrid1.RowCount := face.Size.Metrics.Height div 64 + 1;
  StringGrid1.RowCount := G.Height;
  // StringGrid1.ColCount := face.Glyph.Metrics.Width div 64;
  StringGrid1.ColCount := G.Width;

  for i := 0 to (G.Height * G.Pitch) - 1 do
    begin
    for j := 0 to 7 do
    begin
    if G.Data[i] shl j and 128 > 0 then
    StringGrid1.Cells[k * 8 + j,
    (G.Ascender - G.HorzBearingY)+ i div G.Pitch + 1] := 'X';
    end;
    inc(k);
    if k = G.Pitch then
    k := 0;
    end;

  {
    Glyph.Bitmap.Pitch в монохромном режиме выдает количество байт на строку, четное число
    при этом используется 1 бит на пиксель
  }
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if FontDialog1.Execute then
    raster.Font := FontDialog1.Font;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  raster.Free;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  raster := TRasterizer.Create;
  raster.Font := FontDialog1.Font;
end;

end.
