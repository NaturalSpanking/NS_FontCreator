unit add_table;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm2 = class(TForm)
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ComboBox1Select(Sender: TObject);
  private
    res: boolean;
    presets: TStringList;
    int_list: TList;
    procedure clear_list;
    procedure parse_preset(str: string);
  public
    function Execute: boolean;
    property CharList: TList read int_list;
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.Button1Click(Sender: TObject);
begin
  parse_preset(Edit1.Text);
  res := True;
  Close;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  res := False;
  Close;
end;

procedure TForm2.clear_list;
var
  i: integer;
begin
  for i := 0 to int_list.Count - 1 do
    dispose(int_list[i]);
  int_list.Clear;
end;

procedure TForm2.ComboBox1Select(Sender: TObject);
var
  s: string;
begin
  clear_list;
  s := presets[ComboBox1.ItemIndex];
  s := copy(s, pos(':', s) + 1, length(s));
  if s[1] = ' ' then
    delete(s, 1, 1);
  Edit1.Text := s;
end;

function TForm2.Execute: boolean;
begin
  ShowModal;
  Result := res;
end;

procedure TForm2.FormCreate(Sender: TObject);
var
  i: integer;
  s: string;
begin
  s := ExtractFileDir(Application.ExeName);
  s := s + '\Presets.txt';
  int_list := TList.Create;
  presets := TStringList.Create;
  presets.LoadFromFile(s);
  for i := 0 to presets.Count - 1 do
    ComboBox1.Items.Add(copy(presets[i], 1, pos(':', presets[i]) - 1));
  ComboBox1.ItemIndex := 0;
  ComboBox1Select(Form2);
end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  clear_list;
  presets.Free;
  int_list.Free;
end;

procedure TForm2.parse_preset(str: string);
var
  x: string;
  i: integer;
  p: ^integer;
  com_pos, minus_pos: integer;
  start, stop: integer;
begin
  clear_list;
  str := copy(str, pos(':', str) + 1, length(str)); // удаление названия пресета
  for i := 1 to length(str) do // удаление пробелов
    if str[i] = ' ' then
      delete(str, i, 1);
  repeat
    com_pos := pos(',', str);
    if com_pos = 0 then
      com_pos := length(str) + 1;
    // поиск позиции запятой, если нету - конец строки
    x := copy(str, 1, com_pos - 1); // подстрока до запятой
    minus_pos := pos('-', x); // проверка - диапазон или число
    if minus_pos > 0 then // есть минус
    begin
      start := StrToInt(copy(x, 1, minus_pos - 1));
      // вычисление первого индекса
      stop := StrToInt(copy(x, minus_pos + 1, length(x)));
      // вычисление последнего
      for i := start to stop do // заполнение в цикле
      begin
        new(p);
        p^ := i;
        int_list.Add(p);
      end;
    end
    else // нет минуса
    begin // просто добавление числа
      new(p);
      p^ := StrToInt(copy(x, 1, com_pos - 1));
      int_list.Add(p);
    end;
    delete(str, 1, com_pos);
  until length(str) = 0;
end;

end.
