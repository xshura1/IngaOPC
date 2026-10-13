object fmDriverLinks: TfmDriverLinks
  Left = 495
  Top = 262
  Width = 481
  Height = 393
  Caption = 'fmDriverLinks'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 473
    Height = 41
    Align = alTop
    Caption = 'Panel1'
    TabOrder = 0
    object Button1: TButton
      Left = 12
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object SB: TScrollBox
    Left = 0
    Top = 41
    Width = 473
    Height = 325
    HorzScrollBar.Tracking = True
    VertScrollBar.Tracking = True
    Align = alClient
    BorderStyle = bsNone
    TabOrder = 1
    OnResize = SBResize
  end
end
