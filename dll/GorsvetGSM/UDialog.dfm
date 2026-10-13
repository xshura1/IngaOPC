object fmDialog: TfmDialog
  Left = 580
  Top = 286
  BorderStyle = bsDialog
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
  ClientHeight = 222
  ClientWidth = 181
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 12
    Top = 13
    Width = 28
    Height = 13
    Caption = #1055#1086#1088#1090':'
  end
  object Label2: TLabel
    Left = 12
    Top = 41
    Width = 51
    Height = 13
    Caption = #1057#1082#1086#1088#1086#1089#1090#1100':'
  end
  object Label3: TLabel
    Left = 12
    Top = 69
    Width = 44
    Height = 13
    Caption = #1044#1072#1085#1085#1099#1077':'
  end
  object Label4: TLabel
    Left = 12
    Top = 97
    Width = 45
    Height = 13
    Caption = #1055#1072#1088#1080#1090#1077#1090':'
  end
  object Label5: TLabel
    Left = 12
    Top = 125
    Width = 58
    Height = 13
    Caption = #1057#1090#1086#1087'. '#1073#1080#1090#1099':'
  end
  object Label6: TLabel
    Left = 12
    Top = 154
    Width = 72
    Height = 13
    Caption = #1058#1072#1081#1084' '#1072#1091#1090' ('#1084#1089'.)'
  end
  object CBPort: TComboBox
    Left = 88
    Top = 10
    Width = 84
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 2
    Items.Strings = (
      'sdf'
      'we'
      'qwert'
      'qwer'
      'wert')
  end
  object CBBaud: TComboBox
    Left = 88
    Top = 38
    Width = 84
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 3
    Items.Strings = (
      '75'
      '110 '
      '150'
      '300 '
      '600'
      '1200 '
      '1800 '
      '2400'
      '4800'
      '7200'
      '9600'
      '14400'
      '19200'
      '38400'
      '56000'
      '57600'
      '115200'
      '128000')
  end
  object CBByte: TComboBox
    Left = 88
    Top = 66
    Width = 84
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 4
    Items.Strings = (
      '5'
      '6'
      '7'
      '8')
  end
  object CBPar: TComboBox
    Left = 88
    Top = 94
    Width = 84
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 5
    Items.Strings = (
      #1053#1077#1090
      #1053#1077#1095#1077#1090'.'
      #1063#1077#1090'.'
      #1052#1072#1088#1082'.'
      #1055#1088#1086#1073#1077#1083)
  end
  object CBSB: TComboBox
    Left = 88
    Top = 122
    Width = 84
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 6
    Items.Strings = (
      '1'
      '1.5'
      '2')
  end
  object BtnOK: TButton
    Left = 12
    Top = 186
    Width = 75
    Height = 25
    Caption = #1054#1050
    ModalResult = 1
    TabOrder = 0
    OnClick = BtnOKClick
  end
  object BtnCancel: TButton
    Left = 96
    Top = 186
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 1
  end
  object EDTimeOut: TSpinEdit
    Left = 88
    Top = 152
    Width = 85
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 7
    Value = 0
  end
end
