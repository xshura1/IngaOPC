object fmSetup: TfmSetup
  Left = 565
  Top = 317
  BorderStyle = bsDialog
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1087#1086#1088#1090#1072
  ClientHeight = 353
  ClientWidth = 311
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 74
    Top = 322
    Width = 75
    Height = 24
    Caption = #1054#1050
    ModalResult = 1
    TabOrder = 0
  end
  object GroupBox1: TGroupBox
    Left = 3
    Top = 6
    Width = 304
    Height = 307
    Caption = 'TCP '#1087#1086#1088#1090' '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    object Label8: TLabel
      Left = 9
      Top = 60
      Width = 121
      Height = 13
      Caption = #1058#1072#1081#1084'-'#1072#1091#1090' '#1085#1072' '#1095#1090#1077#1085#1080#1077' ('#1084#1089')'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label6: TLabel
      Left = 9
      Top = 130
      Width = 178
      Height = 26
      Caption = #1048#1085#1090#1077#1088#1074#1072#1083' '#1087#1086#1076#1072#1095#1080' '#1076#1072#1085#1085#1099#1093' '#1076#1083#1103#13#10#1087#1086#1076#1076#1077#1088#1078#1072#1085#1080#1103' TCP '#1089#1086#1077#1076#1080#1085#1077#1085#1080#1103' ('#1084#1089')'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label1: TLabel
      Left = 9
      Top = 21
      Width = 66
      Height = 13
      Caption = #1053#1086#1084#1077#1088' '#1087#1086#1088#1090#1072
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 9
      Top = 166
      Width = 167
      Height = 13
      Caption = #1048#1085#1090#1077#1088#1074#1072#1083' '#1086#1087#1088#1086#1089#1072' '#1089#1086#1089#1090#1086#1103#1085#1080#1103' ('#1084#1089')'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label3: TLabel
      Left = 9
      Top = 90
      Width = 157
      Height = 13
      Caption = #1058#1072#1081#1084'-'#1072#1091#1090' '#1085#1072' '#1095#1090#1077#1085#1080#1077' '#1087#1086' 485 ('#1084#1089')'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label4: TLabel
      Left = 9
      Top = 230
      Width = 157
      Height = 26
      Caption = #1042#1088#1077#1084#1103' '#1072#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1086#1081' '#1087#1086#1076#1072#1095#1080#13#10#1082#1086#1084#1072#1085#1076#1099' "'#1047#1072#1075#1088#1091#1079#1082#1072' '#1074#1088#1077#1084#1077#1085#1080'"'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label5: TLabel
      Left = 9
      Top = 272
      Width = 144
      Height = 26
      Caption = #1052#1072#1082#1089'. '#1074#1088#1077#1084#1103' '#1088#1072#1073#1086#1090#1099#13#10#1087#1086' '#1072#1074#1072#1088#1080#1081#1085#1086#1084#1091' '#1082#1072#1085#1072#1083#1091' ('#1089#1077#1082'.)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object ComboTimeoutRead: TRxSpinEdit
      Left = 192
      Top = 57
      Width = 100
      Height = 21
      ButtonKind = bkStandard
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object ComboIntervalTCP: TRxSpinEdit
      Left = 192
      Top = 133
      Width = 100
      Height = 21
      ButtonKind = bkStandard
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
    object NoPort: TRxSpinEdit
      Left = 192
      Top = 18
      Width = 100
      Height = 21
      ButtonKind = bkStandard
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
    end
    object ComboIntervalFullSost: TRxSpinEdit
      Left = 192
      Top = 163
      Width = 100
      Height = 21
      ButtonKind = bkStandard
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
    end
    object ComboTimeoutRead485: TRxSpinEdit
      Left = 192
      Top = 87
      Width = 100
      Height = 21
      ButtonKind = bkStandard
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
    end
    object DTTime: TDateTimePicker
      Left = 192
      Top = 232
      Width = 100
      Height = 21
      Date = 39076.421231006940000000
      Time = 39076.421231006940000000
      Kind = dtkTime
      TabOrder = 5
    end
    object CBAutoLoadData: TCheckBox
      Left = 9
      Top = 208
      Width = 280
      Height = 17
      Caption = #1040#1074#1090#1086#1087#1086#1076#1072#1095#1072' '#1082#1086#1084#1072#1085#1076#1099' "'#1047#1072#1075#1088#1091#1079#1082#1072' '#1074#1088#1077#1084#1077#1085#1080'"'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 6
    end
    object ComboTimeLimitAlarm: TRxSpinEdit
      Left = 192
      Top = 276
      Width = 100
      Height = 21
      ButtonKind = bkStandard
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 7
    end
  end
  object Button2: TButton
    Left = 161
    Top = 322
    Width = 75
    Height = 24
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 2
  end
end
