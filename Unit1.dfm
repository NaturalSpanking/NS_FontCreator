object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 701
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
    Top = 577
    Width = 1424
    Height = 105
    Align = alBottom
    ExplicitLeft = 216
    ExplicitTop = 574
    ExplicitWidth = 105
  end
  object Splitter1: TSplitter
    Left = 0
    Top = 574
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
    Height = 574
    ExplicitLeft = 168
    ExplicitTop = 280
    ExplicitHeight = 100
  end
  object Image2: TImage
    Left = 148
    Top = 0
    Width = 1049
    Height = 574
    Align = alClient
    ExplicitLeft = 304
    ExplicitTop = 112
    ExplicitWidth = 105
    ExplicitHeight = 105
  end
  object Panel1: TPanel
    Left = 1197
    Top = 0
    Width = 227
    Height = 574
    Align = alRight
    TabOrder = 0
    object Button1: TButton
      Left = 70
      Top = 39
      Width = 75
      Height = 25
      Caption = 'Draw'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 70
      Top = 70
      Width = 75
      Height = 25
      Caption = 'Font'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 70
      Top = 101
      Width = 75
      Height = 25
      Caption = 'Free'
      TabOrder = 2
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 70
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
      Checked = True
      State = cbChecked
      TabOrder = 6
      OnClick = Button1Click
    end
    object Edit1: TEdit
      Left = 70
      Top = 132
      Width = 27
      Height = 29
      TabOrder = 7
      Text = 'j'
    end
    object Button5: TButton
      Left = 96
      Top = 320
      Width = 75
      Height = 25
      Caption = 'Button5'
      TabOrder = 8
      OnClick = Button5Click
    end
    object Button6: TButton
      Left = 31
      Top = 70
      Width = 33
      Height = 25
      Caption = 'a'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
      TabOrder = 9
      OnClick = Button6Click
    end
    object Button7: TButton
      Left = 151
      Top = 70
      Width = 33
      Height = 25
      Caption = 'a'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -29
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
      TabOrder = 10
      OnClick = Button7Click
    end
    object Button8: TButton
      Left = 103
      Top = 134
      Width = 26
      Height = 27
      Caption = 'Button8'
      TabOrder = 11
      OnClick = Button8Click
    end
    object Button9: TButton
      Left = 37
      Top = 129
      Width = 27
      Height = 35
      Caption = 'Button9'
      TabOrder = 12
      OnClick = Button9Click
    end
  end
  object TreeView1: TTreeView
    Left = 0
    Top = 0
    Width = 145
    Height = 574
    Align = alLeft
    Indent = 19
    TabOrder = 1
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 682
    Width = 1424
    Height = 19
    Panels = <
      item
        Width = 300
      end
      item
        Text = '50x78'
        Width = 50
      end
      item
        Width = 550
      end
      item
        Alignment = taRightJustify
        Width = 150
      end>
  end
  object FontDialog1: TFontDialog
    Ctl3D = False
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Times New Roman'
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
