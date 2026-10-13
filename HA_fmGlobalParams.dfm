object fmGlobalParams: TfmGlobalParams
  Left = 477
  Top = 307
  Width = 313
  Height = 336
  BorderIcons = [biSystemMenu]
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 272
    Width = 305
    Height = 37
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Panel3: TPanel
      Left = 208
      Top = 0
      Width = 97
      Height = 37
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object BtnOK: TButton
        Left = 18
        Top = 9
        Width = 75
        Height = 23
        Caption = 'OK'
        ModalResult = 1
        TabOrder = 0
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 305
    Height = 272
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 1
    object OI: TGsvObjectInspectorGrid
      Left = 1
      Top = 1
      Width = 303
      Height = 270
      Align = alClient
      ParentFont = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBtnText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      TabOrder = 0
      ReadOnly = False
      BorderStyle = bsNone
      DividerPosition = 151
      TypeVisibleProps = vp_Props
      ColorReadOnlyProp = clBlack
      OnEnumProperties = OIEnumProperties
      OnGetStringValue = OIGetStringValue
      OnSetStringValue = OISetStringValue
      OnGetIntegerValue = OIGetIntegerValue
      OnSetIntegerValue = OISetIntegerValue
    end
  end
end
