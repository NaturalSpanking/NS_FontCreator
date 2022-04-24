object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 801
  ClientWidth = 1424
  Color = clBtnFace
  Constraints.MaxHeight = 1440
  Constraints.MaxWidth = 2560
  Constraints.MinHeight = 600
  Constraints.MinWidth = 800
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -19
  Font.Name = 'Times New Roman'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 21
  object Image1: TImage
    Left = 0
    Top = 677
    Width = 1424
    Height = 105
    Align = alBottom
    ExplicitLeft = 216
    ExplicitTop = 574
    ExplicitWidth = 105
  end
  object Splitter1: TSplitter
    Left = 0
    Top = 674
    Width = 1424
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    Beveled = True
    ExplicitTop = 573
    ExplicitWidth = 1091
  end
  object Splitter2: TSplitter
    Left = 145
    Top = 0
    Height = 674
    ExplicitLeft = 168
    ExplicitTop = 280
    ExplicitHeight = 100
  end
  object StringGrid1: TStringGrid
    Left = 148
    Top = 0
    Width = 1049
    Height = 674
    Align = alClient
    DefaultColWidth = 32
    TabOrder = 0
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
  object Panel1: TPanel
    Left = 1197
    Top = 0
    Width = 227
    Height = 674
    Align = alRight
    TabOrder = 1
    object Button1: TButton
      Left = 110
      Top = 48
      Width = 75
      Height = 25
      Caption = 'Draw'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 110
      Top = 88
      Width = 75
      Height = 25
      Caption = 'Font'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 110
      Top = 128
      Width = 75
      Height = 25
      Caption = 'Free'
      TabOrder = 2
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 110
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Init'
      TabOrder = 3
      OnClick = Button4Click
    end
    object CheckBox1: TCheckBox
      Left = 15
      Top = 193
      Width = 130
      Height = 17
      Caption = 'NoHinting'
      TabOrder = 4
      OnClick = Button1Click
    end
    object CheckBox2: TCheckBox
      Left = 15
      Top = 216
      Width = 130
      Height = 17
      Caption = 'Force auto-hit'
      TabOrder = 5
      OnClick = Button1Click
    end
    object CheckBox3: TCheckBox
      Left = 15
      Top = 239
      Width = 130
      Height = 17
      Caption = 'Target mono'
      TabOrder = 6
      OnClick = Button1Click
    end
    object Edit1: TEdit
      Left = 54
      Top = 46
      Width = 27
      Height = 29
      TabOrder = 7
      Text = 'g'
    end
  end
  object TreeView1: TTreeView
    Left = 0
    Top = 0
    Width = 145
    Height = 674
    Align = alLeft
    Indent = 19
    TabOrder = 2
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 782
    Width = 1424
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
  object FontDialog1: TFontDialog
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    Left = 792
    Top = 8
  end
  object MainMenu1: TMainMenu
    Left = 744
    Top = 8
    object File1: TMenuItem
      Caption = 'File'
    end
  end
end
