object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'X3 : TC - Saitek X52 Pro'
  ClientHeight = 286
  ClientWidth = 492
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 9
    Top = 11
    Width = 118
    Height = 13
    Caption = 'Path to DirectOutput.dll:'
  end
  object Label2: TLabel
    Left = 9
    Top = 42
    Width = 93
    Height = 13
    Caption = 'Path to X3 log files:'
  end
  object ExitButton: TButton
    Left = 409
    Top = 233
    Width = 75
    Height = 25
    Caption = 'Exit'
    TabOrder = 0
    OnClick = ExitButtonClick
  end
  object Memo1: TMemo
    Left = 8
    Top = 67
    Width = 377
    Height = 190
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object ReInitButton: TButton
    Left = 409
    Top = 161
    Width = 75
    Height = 25
    Caption = 'ReInit'
    TabOrder = 2
    OnClick = ReInitButtonClick
  end
  object TestButton: TButton
    Left = 409
    Top = 199
    Width = 75
    Height = 25
    Caption = 'Test'
    TabOrder = 3
    OnClick = TestButtonClick
  end
  object DllPath: TEdit
    Left = 134
    Top = 8
    Width = 291
    Height = 21
    TabOrder = 4
  end
  object DLLBrowse: TButton
    Left = 431
    Top = 8
    Width = 53
    Height = 22
    Caption = 'Browse'
    TabOrder = 5
    OnClick = DLLBrowseClick
  end
  object X3Path: TEdit
    Left = 134
    Top = 39
    Width = 291
    Height = 21
    TabOrder = 6
  end
  object X3TCBrowse: TButton
    Left = 431
    Top = 39
    Width = 53
    Height = 22
    Caption = 'Browse'
    TabOrder = 7
    OnClick = X3TCBrowseClick
  end
  object SaveButton: TButton
    Left = 395
    Top = 72
    Width = 89
    Height = 22
    Caption = 'Save paths'
    TabOrder = 8
    OnClick = SaveButtonClick
  end
  object debug_mode_checkbox: TCheckBox
    Left = 134
    Top = 263
    Width = 129
    Height = 17
    Caption = 'Activate debug mode'
    TabOrder = 9
  end
  object TestTimer: TTimer
    Enabled = False
    Interval = 50
    OnTimer = TestTimerTimer
    Left = 187
    Top = 184
  end
  object MainTimer: TTimer
    Enabled = False
    Interval = 250
    OnTimer = MainTimerTimer
    Left = 250
    Top = 190
  end
end
