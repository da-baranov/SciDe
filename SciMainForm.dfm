object MainForm: TMainForm
  Left = 240
  Top = 272
  Width = 1223
  Height = 723
  Caption = 'SciDe - test form'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  Menu = mm1
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlContainer: TPanel
    Left = 289
    Top = 0
    Width = 918
    Height = 665
    Align = alClient
    BevelOuter = bvNone
    Caption = 'pnlContainer'
    TabOrder = 0
    object spl1: TSplitter
      Left = 0
      Top = 476
      Width = 918
      Height = 5
      Cursor = crVSplit
      Align = alBottom
    end
    object txtLog: TMemo
      Left = 0
      Top = 481
      Width = 918
      Height = 184
      Align = alBottom
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 0
    end
    object Sciter1: TSciter
      Left = 0
      Top = 0
      Width = 918
      Height = 476
      Align = alClient
      Caption = 'Sciter'
      PopupMenu = ctxSciter
      TabOrder = 1
      OnDocumentComplete = Sciter1DocumentComplete
      OnStdErr = OnSciterOut
      OnStdOut = OnSciterOut
      OnStdWarn = OnSciterOut
    end
  end
  object pc: TPageControl
    Left = 0
    Top = 0
    Width = 289
    Height = 665
    ActivePage = tsDOM
    Align = alLeft
    MultiLine = True
    TabOrder = 1
    object tsDOM: TTabSheet
      Caption = 'DOM manipulations'
      ImageIndex = 3
      object GC: TButton
        Left = 10
        Top = 10
        Width = 75
        Height = 25
        Caption = 'GC'
        TabOrder = 0
        OnClick = GCClick
      end
    end
  end
  object mm1: TMainMenu
    Left = 369
    Top = 56
    object Actions1: TMenuItem
      Caption = 'Actions'
      object NavigatetoSciterwebsite1: TMenuItem
        Caption = 'Navigate to Sciter website'
        OnClick = NavigatetoSciterwebsite1Click
      end
      object DumpHTML1: TMenuItem
        Caption = 'Dump HTML'
        OnClick = DumpHTML1Click
      end
    end
  end
  object ctxSciter: TPopupMenu
    Left = 839
    Top = 120
    object mnuElementAtCursor: TMenuItem
      Caption = 'Find element at cursor'
      OnClick = mnuElementAtCursorClick
    end
  end
end
