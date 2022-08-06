unit Unit3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm3 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Button1: TButton;
    Button2: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    res: boolean;
    table_name: string;
    first_char: integer;
  public
    function Execute: boolean;
    property TableName: string read table_name write table_name;
    property FirstChar: integer read first_char write first_char;
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}
{ TForm3 }

procedure TForm3.Button1Click(Sender: TObject);
begin
  if length(Edit2.Text) = 0 then
    Edit2.Text := ' ';

  res := true;
  table_name := Edit1.Text;
  first_char := ord(Edit2.Text[1]);
  Form3.Close;
end;

procedure TForm3.Button2Click(Sender: TObject);
begin
  res := false;
  Form3.Close;
end;

function TForm3.Execute: boolean;
begin
  Edit1.Text := table_name;
  Edit2.Text := chr(first_char);
  Form3.ShowModal;
  Result := res;
end;

end.
