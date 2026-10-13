object fmViewLog: TfmViewLog
  Tag = 3
  Left = 277
  Top = 263
  Width = 627
  Height = 416
  BorderStyle = bsSizeToolWin
  Caption = #1057#1080#1089#1090#1077#1084#1085#1099#1081' '#1083#1086#1075
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
    Width = 619
    Height = 389
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 0
    object TV: TVirtualStringTree
      Left = 1
      Top = 1
      Width = 617
      Height = 387
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
      Indent = 0
      TabOrder = 0
      TreeOptions.PaintOptions = [toHideFocusRect, toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toThemeAware, toUseBlendedImages]
      TreeOptions.SelectionOptions = [toFullRowSelect]
      OnGetText = TVGetText
      Columns = <
        item
          Position = 0
          Width = 100
          WideText = #1044#1072#1090#1072
        end
        item
          Position = 1
          Width = 100
          WideText = #1054#1073#1098#1077#1082#1090
        end
        item
          Position = 2
          Width = 100
          WideText = #1060#1091#1085#1082#1094#1080#1103
        end
        item
          Position = 3
          Width = 100
          WideText = #1053#1086#1084#1077#1088' '#1086#1096#1080#1073#1082#1080
        end
        item
          Position = 4
          Width = 217
          WideText = #1054#1087#1080#1089#1072#1085#1080#1077' '#1086#1096#1080#1073#1082#1080
        end>
    end
  end
end
