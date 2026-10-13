object fmTemplateOpenDialog: TfmTemplateOpenDialog
  Left = 466
  Top = 383
  Width = 438
  Height = 262
  BorderIcons = [biSystemMenu]
  Caption = 'fmTemplateOpenDialog'
  Color = clBtnFace
  Constraints.MinWidth = 185
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 197
    Width = 430
    Height = 38
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Panel2: TPanel
      Left = 128
      Top = 0
      Width = 302
      Height = 38
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object BtnCancel: TButton
        Left = 221
        Top = 9
        Width = 75
        Height = 23
        Caption = #1054#1090#1084#1077#1085#1072
        ModalResult = 2
        TabOrder = 0
      end
      object BtnOK: TButton
        Left = 134
        Top = 9
        Width = 75
        Height = 23
        Caption = #1054#1090#1082#1088#1099#1090#1100
        ModalResult = 1
        TabOrder = 1
      end
      object BtnDel: TButton
        Left = 2
        Top = 9
        Width = 75
        Height = 23
        Caption = #1059#1076#1072#1083#1080#1090#1100
        TabOrder = 2
        OnClick = BtnDelClick
      end
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 430
    Height = 170
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 1
    object LB: TListBox
      Left = 1
      Top = 1
      Width = 428
      Height = 168
      Align = alClient
      BorderStyle = bsNone
      ItemHeight = 13
      TabOrder = 0
      OnClick = LBClick
      OnDblClick = LBDblClick
      OnKeyPress = LBKeyPress
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 170
    Width = 430
    Height = 27
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'Panel4'
    TabOrder = 2
    OnResize = Panel4Resize
    object Edit1: TEdit
      Left = 0
      Top = 3
      Width = 379
      Height = 21
      TabOrder = 0
      OnChange = Edit1Change
    end
  end
end
