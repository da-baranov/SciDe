object MainForm: TMainForm
  Left = 315
  Top = 121
  Width = 1191
  Height = 775
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
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlContainer: TPanel
    Left = 193
    Top = 0
    Width = 982
    Height = 717
    Align = alClient
    BevelOuter = bvNone
    Caption = 'pnlContainer'
    TabOrder = 0
    object spl1: TSplitter
      Left = 0
      Top = 528
      Width = 982
      Height = 5
      Cursor = crVSplit
      Align = alBottom
    end
    object txtLog: TMemo
      Left = 0
      Top = 533
      Width = 982
      Height = 184
      Align = alBottom
      Color = 16771799
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
      Width = 982
      Height = 528
      Align = alClient
      PopupMenu = ctxSciter
      TabOrder = 1
      OnDocumentComplete = Sciter1DocumentComplete
      OnMethodCall = Sciter1MethodCall
      OnStdErr = OnSciterOut
      OnStdOut = OnSciterOut
      OnStdWarn = OnSciterOut
    end
  end
  object pnlCommands: TPanel
    Left = 0
    Top = 0
    Width = 193
    Height = 717
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 58
      Top = 72
      Width = 6
      Height = 13
      Caption = '+'
    end
    object GC: TButton
      Left = 10
      Top = 140
      Width = 160
      Height = 25
      Caption = 'Invoke GC'
      TabOrder = 0
      OnClick = GCClick
    end
    object txt1: TEdit
      Left = 20
      Top = 70
      Width = 33
      Height = 21
      TabOrder = 1
      Text = '2'
    end
    object txt2: TEdit
      Left = 70
      Top = 70
      Width = 41
      Height = 21
      TabOrder = 2
      Text = '2'
    end
    object cmdEval: TButton
      Left = 120
      Top = 70
      Width = 61
      Height = 25
      Caption = 'Eval'
      TabOrder = 3
      OnClick = cmdEvalClick
    end
    object cmdCallNative: TButton
      Left = 10
      Top = 110
      Width = 160
      Height = 25
      Caption = 'Call native SayHello'
      TabOrder = 4
      OnClick = cmdCallNativeClick
    end
    object cmdGetCaseHistory: TButton
      Left = 10
      Top = 170
      Width = 160
      Height = 25
      Caption = 'Show case history JSON'
      TabOrder = 5
      OnClick = cmdGetCaseHistoryClick
    end
    object cmdReload: TButton
      Left = 20
      Top = 10
      Width = 151
      Height = 25
      Caption = 'Refresh'
      TabOrder = 6
      OnClick = cmdReloadClick
    end
    object Button1: TButton
      Left = 10
      Top = 210
      Width = 161
      Height = 25
      Caption = 'Test JSON serialization'
      TabOrder = 7
      OnClick = Button1Click
    end
    object cmdSetObject: TButton
      Left = 10
      Top = 240
      Width = 161
      Height = 25
      Caption = 'Set object'
      TabOrder = 8
      OnClick = cmdSetObjectClick
    end
    object cmdSaveToFile: TButton
      Left = 10
      Top = 270
      Width = 161
      Height = 25
      Caption = 'Save to file'
      TabOrder = 9
      OnClick = cmdSaveToFileClick
    end
    object cmdShowInspector: TButton
      Left = 8
      Top = 304
      Width = 161
      Height = 25
      Caption = 'Show Inspector'
      TabOrder = 10
      OnClick = cmdShowInspectorClick
    end
  end
  object mm1: TMainMenu
    Left = 209
    Top = 104
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
    Left = 207
    Top = 136
    object mnuElementAtCursor: TMenuItem
      Caption = 'Find element at cursor'
      OnClick = mnuElementAtCursorClick
    end
  end
  object sfd: TSaveDialog
    DefaultExt = 'htm'
    Filter = 'HTML files (*.htm)|*.htm'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 180
    Top = 270
  end
end
