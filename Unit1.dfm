object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 638
  ClientWidth = 1091
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -19
  Font.Name = 'Times New Roman'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 21
  object Button1: TButton
    Left = 824
    Top = 48
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 919
    Top = 0
    Width = 172
    Height = 638
    Align = alRight
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
    ExplicitLeft = 680
    ExplicitHeight = 929
  end
  object Button2: TButton
    Left = 824
    Top = 88
    Width = 75
    Height = 25
    Caption = 'Font'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 824
    Top = 128
    Width = 75
    Height = 25
    Caption = 'Button3'
    TabOrder = 3
    OnClick = Button3Click
  end
  object StringGrid1: TStringGrid
    Left = 0
    Top = 0
    Width = 785
    Height = 638
    Align = alLeft
    DefaultColWidth = 32
    TabOrder = 4
    ExplicitHeight = 929
  end
  object Panel1: TPanel
    Left = 791
    Top = 304
    Width = 108
    Height = 41
    Caption = 'Panel1'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
  end
  object CheckBox1: TCheckBox
    Left = 791
    Top = 184
    Width = 97
    Height = 17
    Caption = 'Hiting'
    TabOrder = 6
    OnClick = Button1Click
  end
  object CheckBox2: TCheckBox
    Left = 791
    Top = 216
    Width = 130
    Height = 17
    Caption = 'Force auto-hit'
    TabOrder = 7
    OnClick = Button1Click
  end
  object FontDialog1: TFontDialog
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Left = 960
    Top = 16
  end
end
