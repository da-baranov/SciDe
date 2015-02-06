object MainForm: TMainForm
  Left = 328
  Top = 198
  Width = 1208
  Height = 675
  Caption = 'MainForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object cmd1: TButton
    Left = 570
    Top = 30
    Width = 191
    Height = 25
    Caption = 'Subscribe to events'
    TabOrder = 0
    OnClick = cmd1Click
  end
  object cmd2: TButton
    Left = 570
    Top = 60
    Width = 191
    Height = 25
    Caption = 'Register and call native method'
    TabOrder = 1
    OnClick = cmd2Click
  end
  object cmd3: TButton
    Left = 570
    Top = 90
    Width = 191
    Height = 25
    Caption = 'Call script function hello_from_sciter'
    TabOrder = 2
    OnClick = cmd3Click
  end
  object cmd4: TButton
    Left = 570
    Top = 120
    Width = 191
    Height = 25
    Caption = 'Call OLE object'
    TabOrder = 3
    OnClick = cmd4Click
  end
  object txt1: TMemo
    Left = 560
    Top = 540
    Width = 621
    Height = 91
    Lines.Strings = (
      'txt1')
    TabOrder = 4
  end
  object cmd5: TButton
    Left = 570
    Top = 150
    Width = 71
    Height = 25
    Caption = 'Test DOM'
    TabOrder = 5
    OnClick = cmd5Click
  end
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 551
    Height = 637
    Align = alLeft
    Caption = 'pnl1'
    TabOrder = 6
  end
  object cmd6: TButton
    Left = 570
    Top = 180
    Width = 191
    Height = 25
    Caption = 'Get children count'
    TabOrder = 7
    OnClick = cmd6Click
  end
  object cmd7: TButton
    Left = 570
    Top = 210
    Width = 191
    Height = 25
    Caption = 'cmd7'
    TabOrder = 8
    OnClick = cmd7Click
  end
  object cmd8: TButton
    Left = 740
    Top = 150
    Width = 101
    Height = 25
    Caption = 'Remove headings'
    TabOrder = 9
    OnClick = cmd8Click
  end
  object cmd9: TButton
    Left = 650
    Top = 150
    Width = 81
    Height = 25
    Caption = 'Change h1 text'
    TabOrder = 10
    OnClick = cmd9Click
  end
  object cmd10: TButton
    Left = 820
    Top = 230
    Width = 75
    Height = 25
    Caption = 'cmd10'
    TabOrder = 11
    OnClick = cmd10Click
  end
  object cmd11: TButton
    Left = 770
    Top = 30
    Width = 75
    Height = 25
    Caption = 'Load Google'
    TabOrder = 12
    OnClick = cmd11Click
  end
  object cmd12: TButton
    Left = 850
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Set focus'
    TabOrder = 13
    OnClick = cmd12Click
  end
end
