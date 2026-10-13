object fmInspector: TfmInspector
  Left = 880
  Top = 534
  Width = 232
  Height = 333
  BorderStyle = bsSizeToolWin
  Caption = #1048#1085#1089#1087#1077#1082#1090#1086#1088' '#1086#1073#1098#1077#1082#1090#1086#1074
  Color = clBtnFace
  DockSite = True
  DragKind = dkDock
  DragMode = dmAutomatic
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 224
    Height = 306
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object PageControl: TPageControlEx
      Left = 0
      Top = 22
      Width = 224
      Height = 22
      ActivePage = TabSheet1
      Align = alTop
      TabOrder = 0
      OnChange = PageControlChange
      object TabSheet1: TTabSheet
        Caption = #1057#1074#1086#1081#1089#1090#1074#1072
      end
      object TabSheet2: TTabSheet
        Caption = #1057#1086#1073#1099#1090#1080#1103
        ImageIndex = 1
      end
    end
    object Panel2: TPanel
      Left = 0
      Top = 0
      Width = 224
      Height = 22
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      OnResize = Panel2Resize
      object SpeedButton1: TSpeedButton
        Left = 148
        Top = 0
        Width = 23
        Height = 22
        OnClick = SpeedButton1Click
      end
      object Edit1: TEdit
        Left = 0
        Top = 0
        Width = 121
        Height = 21
        ReadOnly = True
        TabOrder = 0
      end
    end
    object OI: TGsvObjectInspectorGrid
      Left = 0
      Top = 44
      Width = 224
      Height = 262
      Align = alClient
      BevelInner = bvNone
      BevelKind = bkTile
      Ctl3D = True
      ParentCtl3D = False
      ParentFont = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBtnText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      TabOrder = 2
      ReadOnly = False
      Color = clWhite
      ParentColor = False
      BorderStyle = bsNone
      RowHeight = 18
      DividerPosition = 111
      TypeVisibleProps = vp_Props
      ColorReadOnlyProp = clWhite
      OnEnumProperties = OIEnumProperties
      OnGetStringValue = OIGetStringValue
      OnSetStringValue = OISetStringValue
      OnGetIntegerValue = OIGetIntegerValue
      OnSetIntegerValue = OISetIntegerValue
      OnFillList = OIFillList
      OnShowDialog = OIShowDialog
      OnNeedValueProp = OINeedValueProp
    end
  end
end
