unit add_table;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm2 = class(TForm)
    RadioGroup1: TRadioGroup;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    procedure RadioGroup1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    res: boolean;
    from_code: integer;
    to_code: integer;
  public
    function Execute: boolean;
    property RangeBegin: integer read from_code;
    property RangeEnd: integer read to_code;
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.Button1Click(Sender: TObject);
begin
  from_code := StrToInt(Edit1.Text);
  to_code := StrToInt(Edit2.Text);
  res := True;
  Close;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  res := False;
  Close;
end;

function TForm2.Execute: boolean;
begin
  ShowModal;
  Result := res;
end;

procedure TForm2.RadioGroup1Click(Sender: TObject);
begin
  Edit1.Enabled := False;
  Edit2.Enabled := False;
  case RadioGroup1.ItemIndex of
    0:
      begin
        Edit1.Text := IntToStr(32);
        Edit2.Text := IntToStr(127);;
      end;

    1:
      begin
        Edit1.Text := IntToStr(1040);
        Edit2.Text := IntToStr(1103);;
      end;
    2:
      begin
        Edit1.Enabled := True;
      end;
    3:
      begin
        Edit1.Enabled := True;
        Edit2.Enabled := True;
      end;
  end;
end;

end.
