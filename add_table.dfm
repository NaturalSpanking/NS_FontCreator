object Form2: TForm2
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Add...'
  ClientHeight = 128
  ClientWidth = 314
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -19
  Font.Name = 'Times New Roman'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 21
  object Label1: TLabel
    Left = 136
    Top = 16
    Width = 45
    Height = 21
    Caption = 'From:'
  end
  object Label2: TLabel
    Left = 136
    Top = 51
    Width = 25
    Height = 21
    Caption = 'To:'
  end
  object RadioGroup1: TRadioGroup
    Left = 8
    Top = 8
    Width = 113
    Height = 113
    Caption = 'Presets'
    Items.Strings = (
      'ASCII'
      'Cyrillic'
      'Single'
      'Range')
    TabOrder = 0
    OnClick = RadioGroup1Click
  end
  object Edit1: TEdit
    Left = 187
    Top = 13
    Width = 121
    Height = 29
    Enabled = False
    TabOrder = 1
    Text = '32'
  end
  object Edit2: TEdit
    Left = 187
    Top = 48
    Width = 121
    Height = 29
    Enabled = False
    TabOrder = 2
    Text = '127'
  end
  object Button1: TButton
    Left = 233
    Top = 96
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 3
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 136
    Top = 96
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = Button2Click
  end
end
