object Form1: TForm1
  Left = 377
  Top = 221
  BorderStyle = bsDialog
  Caption = #1050#1086#1085#1074#1077#1088#1090#1077#1088' '#1092#1072#1081#1083#1086#1074' IngaOPC Server '
  ClientHeight = 152
  ClientWidth = 374
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 83
    Height = 13
    Caption = #1048#1089#1093#1086#1076#1085#1099#1081' '#1092#1072#1081#1083':'
  end
  object SpeedButton1: TSpeedButton
    Left = 343
    Top = 25
    Width = 23
    Height = 22
    Caption = '...'
    OnClick = SpeedButton1Click
  end
  object Label2: TLabel
    Left = 8
    Top = 60
    Width = 66
    Height = 13
    Caption = #1053#1086#1074#1099#1081' '#1092#1072#1081#1083':'
  end
  object SpeedButton2: TSpeedButton
    Left = 343
    Top = 77
    Width = 23
    Height = 22
    Caption = '...'
    OnClick = SpeedButton2Click
  end
  object Edit1: TEdit
    Left = 8
    Top = 26
    Width = 330
    Height = 21
    TabOrder = 0
  end
  object Edit2: TEdit
    Left = 8
    Top = 78
    Width = 330
    Height = 21
    TabOrder = 1
  end
  object Button1: TButton
    Left = 8
    Top = 116
    Width = 113
    Height = 25
    Caption = #1050#1086#1085#1074#1077#1088#1090#1080#1088#1086#1074#1072#1090#1100
    TabOrder = 2
  end
  object OD: TOpenDialog
    Filter = 'Inga Template File|*.igt|Inga Config File|*.igc'
    Left = 116
    Top = 48
  end
end
