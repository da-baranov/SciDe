object MainForm: TMainForm
  Left = 413
  Top = 237
  Width = 814
  Height = 624
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
    Width = 509
    Height = 566
    Align = alClient
    BevelOuter = bvNone
    Caption = 'pnlContainer'
    TabOrder = 0
    object spl1: TSplitter
      Left = 0
      Top = 377
      Width = 509
      Height = 5
      Cursor = crVSplit
      Align = alBottom
    end
    object sctr1: TSciter
      Left = 0
      Top = 0
      Width = 509
      Height = 377
      Align = alClient
      BevelInner = bvSpace
      BevelKind = bkSoft
      BevelOuter = bvRaised
      BorderWidth = 1
      Caption = 'Sciter1'
      TabOrder = 0
      OnHandleCreated = sctr1HandleCreated
      OnStdErr = sctr1StdErr
      OnStdOut = sctr1StdErr
      OnStdWarn = sctr1StdErr
      Html = '<h1>'#1055#1088#1080#1074#1077#1090'</h1>'
    end
    object txtLog: TMemo
      Left = 0
      Top = 382
      Width = 509
      Height = 184
      Align = alBottom
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 1
    end
  end
  object pc: TPageControl
    Left = 0
    Top = 0
    Width = 289
    Height = 566
    ActivePage = tsDOM
    Align = alLeft
    MultiLine = True
    TabOrder = 1
    object tsBrowser: TTabSheet
      Caption = 'Sciter samples'
      object tv1: TShellTreeView
        Left = 0
        Top = 0
        Width = 281
        Height = 520
        AutoContextMenus = False
        ObjectTypes = [otFolders, otNonFolders]
        Root = 'C:\'
        UseShellImages = True
        Align = alClient
        AutoRefresh = False
        HideSelection = False
        Indent = 19
        ParentColor = False
        RightClickSelect = True
        ShowRoot = False
        TabOrder = 0
        OnChange = tv1Change
      end
    end
    object ts3: TTabSheet
      Caption = 'Sciter events'
      ImageIndex = 2
      object cmd1: TButton
        Left = 10
        Top = 6
        Width = 263
        Height = 25
        Caption = 'Subscribe to body events'
        TabOrder = 0
        OnClick = cmd1Click
      end
      object cmdUnsubscribe: TButton
        Left = 10
        Top = 40
        Width = 261
        Height = 25
        Caption = 'Unsubscribe'
        TabOrder = 1
        OnClick = cmdUnsubscribeClick
      end
    end
    object tsDOM: TTabSheet
      Caption = 'DOM manipulations'
      ImageIndex = 3
      object cmd4: TButton
        Left = 20
        Top = 10
        Width = 251
        Height = 25
        Caption = 'Create headings'
        TabOrder = 0
        OnClick = cmd4Click
      end
      object cmdChangeHeadingsText: TButton
        Left = 20
        Top = 40
        Width = 251
        Height = 25
        Caption = 'Change headings text'
        TabOrder = 1
        OnClick = cmdChangeHeadingsTextClick
      end
      object cmdRemoveHeadings: TButton
        Left = 20
        Top = 70
        Width = 251
        Height = 25
        Caption = 'Remove headings'
        TabOrder = 2
        OnClick = cmdRemoveHeadingsClick
      end
      object cmdSetInnerText: TButton
        Left = 20
        Top = 110
        Width = 251
        Height = 25
        Caption = 'Set inner text'
        TabOrder = 3
        OnClick = cmdSetInnerTextClick
      end
      object cmdInnerHtml: TButton
        Left = 20
        Top = 140
        Width = 251
        Height = 25
        Caption = 'Set inner HTML'
        TabOrder = 4
        OnClick = cmdInnerHtmlClick
      end
    end
    object tsNative: TTabSheet
      Caption = 'Native'
      ImageIndex = 3
      object cmdCallNativeForm: TButton
        Left = 10
        Top = 10
        Width = 261
        Height = 25
        Caption = 'Call native form'
        TabOrder = 0
        OnClick = cmdCallNativeFormClick
      end
      object cmdCallNativeFunction: TButton
        Left = 10
        Top = 40
        Width = 261
        Height = 25
        Caption = 'Call native function'
        TabOrder = 1
        OnClick = cmdCallNativeFunctionClick
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
end
