object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 841
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
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 21
  object Image1: TImage
    Left = 0
    Top = 717
    Width = 1424
    Height = 105
    Align = alBottom
    ExplicitLeft = 216
    ExplicitTop = 574
    ExplicitWidth = 105
  end
  object Splitter1: TSplitter
    Left = 0
    Top = 714
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
    Height = 714
    ExplicitLeft = 168
    ExplicitTop = 280
    ExplicitHeight = 100
  end
  object Image2: TImage
    Left = 148
    Top = 0
    Width = 1049
    Height = 714
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
    Height = 714
    Align = alRight
    TabOrder = 0
    ExplicitHeight = 534
    object Label1: TLabel
      Left = 6
      Top = 690
      Width = 72
      Height = 21
      Caption = '1440x900'
    end
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
    object Button5: TButton
      Left = 16
      Top = 351
      Width = 75
      Height = 25
      Caption = 'add range'
      TabOrder = 2
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
      TabOrder = 3
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
      TabOrder = 4
      OnClick = Button7Click
    end
    object Button10: TButton
      Left = 15
      Top = 320
      Width = 75
      Height = 25
      Caption = 'add root'
      TabOrder = 5
      OnClick = Button10Click
    end
    object Button3: TButton
      Left = 24
      Top = 408
      Width = 75
      Height = 25
      Caption = 'save'
      TabOrder = 6
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 24
      Top = 439
      Width = 75
      Height = 25
      Caption = 'load'
      TabOrder = 7
      OnClick = Button4Click
    end
  end
  object TreeView1: TTreeView
    Left = 0
    Top = 0
    Width = 145
    Height = 714
    Align = alLeft
    DragMode = dmAutomatic
    HideSelection = False
    Indent = 19
    TabOrder = 1
    OnChange = TreeView1Change
    ExplicitHeight = 534
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 822
    Width = 1424
    Height = 19
    Panels = <
      item
        Width = 300
      end
      item
        Width = 50
      end
      item
        Width = 550
      end
      item
        Alignment = taRightJustify
        Width = 150
      end>
    ExplicitTop = 642
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
