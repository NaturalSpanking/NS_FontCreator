program NS_FontCreator;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  add_table in 'add_table.pas' {Form2},
  Unit3 in 'Unit3.pas' {Form3},
  FontRasterizer in 'FontRasterizer.pas',
  UnicodeNames in 'UnicodeNames.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
