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
    Caption = 'Draw'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 944
    Top = 0
    Width = 147
    Height = 638
    Align = alRight
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
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
    Caption = 'Free'
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
    ColWidths = (
      32
      32
      32
      32
      32)
    RowHeights = (
      24
      24
      24
      24
      24)
  end
  object CheckBox1: TCheckBox
    Left = 791
    Top = 184
    Width = 97
    Height = 17
    Caption = 'NoHinting'
    TabOrder = 5
    OnClick = Button1Click
  end
  object CheckBox2: TCheckBox
    Left = 791
    Top = 216
    Width = 130
    Height = 17
    Caption = 'Force auto-hit'
    TabOrder = 6
    OnClick = Button1Click
  end
  object CheckBox3: TCheckBox
    Left = 791
    Top = 248
    Width = 130
    Height = 17
    Caption = 'Target mono'
    TabOrder = 7
    OnClick = Button1Click
  end
  object Button4: TButton
    Left = 824
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Init'
    TabOrder = 8
    OnClick = Button4Click
  end
  object Edit1: TEdit
    Left = 791
    Top = 46
    Width = 27
    Height = 29
    TabOrder = 9
    Text = 'g'
  end
  object CheckBox4: TCheckBox
    Left = 791
    Top = 280
    Width = 130
    Height = 17
    Caption = 'AdvanceOnly'
    TabOrder = 10
    OnClick = Button1Click
  end
  object CheckBox5: TCheckBox
    Left = 791
    Top = 312
    Width = 130
    Height = 17
    Caption = 'ComputeMetrics'
    TabOrder = 11
    OnClick = Button1Click
  end
  object CheckBox6: TCheckBox
    Left = 791
    Top = 344
    Width = 97
    Height = 17
    Caption = 'NoScale'
    TabOrder = 12
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
