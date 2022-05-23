object Form3: TForm3
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Add table'
  ClientHeight = 93
  ClientWidth = 512
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Times New Roman'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 19
  object Label1: TLabel
    Left = 8
    Top = 11
    Width = 72
    Height = 19
    Caption = 'Table name:'
  end
  object Label2: TLabel
    Left = 8
    Top = 59
    Width = 60
    Height = 19
    Caption = 'First char:'
  end
  object Edit1: TEdit
    Left = 103
    Top = 8
    Width = 402
    Height = 27
    TabOrder = 0
    Text = 'Table1'
  end
  object Edit2: TEdit
    Left = 103
    Top = 56
    Width = 26
    Height = 27
    TabOrder = 1
  end
  object Button1: TButton
    Left = 333
    Top = 58
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 430
    Top = 58
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = Button2Click
  end
end
