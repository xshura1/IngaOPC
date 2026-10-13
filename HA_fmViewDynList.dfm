object fmViewDynList: TfmViewDynList
  Tag = 8
  Left = 321
  Top = 253
  Width = 754
  Height = 341
  BorderStyle = bsSizeToolWin
  Caption = #1054#1095#1077#1088#1077#1076#1100' '#1082#1086#1084#1072#1085#1076
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 746
    Height = 314
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 0
    object TV: TVirtualStringTree
      Left = 1
      Top = 1
      Width = 744
      Height = 312
      Align = alClient
      BorderStyle = bsNone
      Header.AutoSizeIndex = -1
      Header.Font.Charset = DEFAULT_CHARSET
      Header.Font.Color = clWindowText
      Header.Font.Height = -11
      Header.Font.Name = 'MS Sans Serif'
      Header.Font.Style = []
      Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoVisible]
      Header.Style = hsFlatButtons
      TabOrder = 0
      TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowVertGridLines, toThemeAware, toUseBlendedImages]
      OnGetText = TVGetText
      Columns = <
        item
          Position = 0
          Width = 200
          WideText = #1059#1089#1090#1088#1086#1081#1089#1090#1074#1086
        end
        item
          Position = 1
          Width = 268
          WideText = #1053#1086#1084#1077#1088' '#1082#1086#1084#1072#1085#1076#1099
        end
        item
          Position = 2
          Width = 185
          WideText = #1055#1088#1080#1086#1088#1080#1090#1077#1090
        end
        item
          Position = 3
          Width = 91
          WideText = #1057#1090#1072#1090#1091#1089
        end>
    end
  end
end
