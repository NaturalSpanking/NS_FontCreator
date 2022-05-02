object Form2: TForm2
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Add...'
  ClientHeight = 110
  ClientWidth = 409
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -19
  Font.Name = 'Times New Roman'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 21
  object Label1: TLabel
    Left = 8
    Top = 11
    Width = 50
    Height = 21
    Caption = 'Preset:'
  end
  object Label2: TLabel
    Left = 8
    Top = 46
    Width = 71
    Height = 21
    Caption = 'Elements:'
  end
  object Edit1: TEdit
    Left = 87
    Top = 43
    Width = 313
    Height = 29
    TabOrder = 0
  end
  object Button1: TButton
    Left = 232
    Top = 78
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 325
    Top = 78
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = Button2Click
  end
  object ComboBox1: TComboBox
    Left = 87
    Top = 8
    Width = 313
    Height = 29
    TabOrder = 3
    OnSelect = ComboBox1Select
  end
end
