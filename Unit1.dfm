object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'NS Font Creator'
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
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 21
  object Image1: TImage
    Left = 0
    Top = 717
    Width = 1424
    Height = 105
    Align = alBottom
    Constraints.MaxHeight = 300
    Constraints.MinHeight = 46
  end
  object Splitter1: TSplitter
    Left = 0
    Top = 714
    Width = 1424
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    AutoSnap = False
    Beveled = True
    OnMoved = FormResize
    ExplicitTop = 573
    ExplicitWidth = 1091
  end
  object Splitter2: TSplitter
    Left = 151
    Top = 0
    Height = 714
    AutoSnap = False
    ExplicitLeft = 168
    ExplicitTop = 280
    ExplicitHeight = 100
  end
  object Image2: TImage
    Left = 154
    Top = 0
    Width = 1043
    Height = 714
    Align = alClient
    ExplicitTop = 29
    ExplicitHeight = 660
  end
  object Panel1: TPanel
    Left = 1197
    Top = 0
    Width = 227
    Height = 714
    Align = alRight
    TabOrder = 0
    ExplicitHeight = 693
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
      OnClick = FR_FullRepaint
    end
    object Button2: TButton
      Left = 70
      Top = 70
      Width = 75
      Height = 25
      Caption = 'Font'
      TabOrder = 1
      OnClick = FR_SelectFont
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
      TabOrder = 2
      OnClick = FR_DecFontSize
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
      TabOrder = 3
      OnClick = FR_IncFontSize
    end
    object Button3: TButton
      Left = 24
      Top = 200
      Width = 75
      Height = 25
      Caption = 'save'
      TabOrder = 4
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 24
      Top = 439
      Width = 75
      Height = 25
      Caption = 'load'
      TabOrder = 5
      OnClick = Button4Click
    end
    object Button5: TButton
      Left = 24
      Top = 328
      Width = 75
      Height = 25
      Caption = 'Gen'
      TabOrder = 6
      OnClick = Button5Click
    end
  end
  object TreeView1: TTreeView
    Left = 0
    Top = 0
    Width = 151
    Height = 714
    Align = alLeft
    Constraints.MaxWidth = 300
    Constraints.MinWidth = 151
    DragMode = dmAutomatic
    HideSelection = False
    Indent = 20
    PopupMenu = PopupMenu1
    ReadOnly = True
    RightClickSelect = True
    TabOrder = 1
    OnChange = TreeView1Change
    OnDeletion = TreeView1Deletion
    OnDragDrop = TreeView1DragDrop
    OnDragOver = TreeView1DragOver
    OnKeyDown = TreeView1KeyDown
    ExplicitHeight = 693
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
    ExplicitTop = 801
  end
  object FontDialog1: TFontDialog
    Ctl3D = False
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Times New Roman'
    Font.Style = []
    Left = 232
    Top = 8
  end
  object MainMenu1: TMainMenu
    Left = 312
    Top = 8
    object File1: TMenuItem
      Caption = 'File'
      object Makesources1: TMenuItem
        Caption = 'Build'
        ShortCut = 16450
        OnClick = Makesources1Click
      end
      object New1: TMenuItem
        Caption = 'New'
        ShortCut = 16462
      end
      object Open1: TMenuItem
        Caption = 'Open'
        ShortCut = 16463
        OnClick = Open1Click
      end
      object Save1: TMenuItem
        Caption = 'Save'
        ShortCut = 16467
        OnClick = Save1Click
      end
      object Saveas1: TMenuItem
        Caption = 'Save as...'
        OnClick = Saveas1Click
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        ShortCut = 32883
      end
    end
    object Font1: TMenuItem
      Caption = 'Font'
      object Repaintall1: TMenuItem
        Caption = 'Repaint all'
        ShortCut = 16466
        OnClick = FR_FullRepaint
      end
      object Autorepaint1: TMenuItem
        Caption = 'Autorepaint'
        Checked = True
        OnClick = Autorepaint1Click
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object Select1: TMenuItem
        Caption = 'Select'
        OnClick = FR_SelectFont
      end
      object Increasesize1: TMenuItem
        Caption = 'Increase size'
        OnClick = FR_IncFontSize
      end
      object Decreasesize1: TMenuItem
        Caption = 'Decrease size'
        OnClick = FR_DecFontSize
      end
    end
    object Charset1: TMenuItem
      Caption = 'Charset'
      object Addtable2: TMenuItem
        Caption = 'Add table'
        OnClick = FR_AddTable
      end
      object Renametable2: TMenuItem
        Caption = 'Edit table'
        OnClick = FR_RenameTable
      end
      object Addsymbols2: TMenuItem
        Caption = 'Add symbols'
        OnClick = FR_AddRange
      end
      object Delete2: TMenuItem
        Caption = 'Delete'
        OnClick = FR_Delete
      end
    end
    object Symbol1: TMenuItem
      Caption = 'Glyphs'
      object Moveup1: TMenuItem
        Caption = 'Move up'
      end
      object Movedown1: TMenuItem
        Caption = 'Move down'
      end
      object Moveleft1: TMenuItem
        Caption = 'Move left'
      end
      object Moderight1: TMenuItem
        Caption = 'Mode right'
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Addrowattop1: TMenuItem
        Caption = 'Add row at top'
      end
      object Addrowatbottom1: TMenuItem
        Caption = 'Add row at bottom'
      end
      object Addcolumnatleft1: TMenuItem
        Caption = 'Add column at left'
      end
      object Addcolumnatright1: TMenuItem
        Caption = 'Add column at right'
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Removerowattop1: TMenuItem
        Caption = 'Remove row at top'
      end
      object Removerowatbottom1: TMenuItem
        Caption = 'Remove row at bottom'
      end
      object Removecolumnatleft1: TMenuItem
        Caption = 'Remove column at left'
      end
      object Removecolumnatright1: TMenuItem
        Caption = 'Remove column at right'
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
    end
    object Abuot: TMenuItem
      Caption = 'About'
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 312
    Top = 64
    object Addtable1: TMenuItem
      Caption = 'Add table'
      OnClick = FR_AddTable
    end
    object Renametable1: TMenuItem
      Caption = 'Edit table'
      OnClick = FR_RenameTable
    end
    object Addsymbols1: TMenuItem
      Caption = 'Add symbols'
      OnClick = FR_AddRange
    end
    object Delete1: TMenuItem
      Caption = 'Delete'
      OnClick = FR_Delete
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'NS Font file|*.nsfont|Any File|*.*'
    Left = 232
    Top = 64
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '.nsfont'
    Filter = 'NS Font file|*.nsfont'
    Left = 232
    Top = 128
  end
  object SaveDialog2: TSaveDialog
    Filter = 'C source code|*.c'
    Left = 232
    Top = 184
  end
end
