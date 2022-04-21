program NS_FontCreator;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  NS_rasterizer in 'NS_rasterizer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
