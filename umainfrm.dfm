object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Test Search Text'
  ClientHeight = 348
  ClientWidth = 544
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  DesignSize = (
    544
    348)
  PixelsPerInch = 96
  TextHeight = 20
  object Label1: TLabel
    Left = 220
    Top = 106
    Width = 60
    Height = 20
    Caption = 'Standard'
  end
  object Label2: TLabel
    Left = 380
    Top = 106
    Width = 76
    Height = 20
    Caption = 'Ownerdraw'
  end
  object bAdd: TButton
    Left = 375
    Top = 21
    Width = 157
    Height = 27
    Action = aAdd
    Default = True
    TabOrder = 1
  end
  object eAdd: TEdit
    Left = 212
    Top = 20
    Width = 157
    Height = 28
    TabOrder = 2
    TextHint = '(Enter new text here)'
  end
  object lbAdded: TListBox
    Left = 8
    Top = 20
    Width = 198
    Height = 320
    Anchors = [akLeft, akTop, akBottom]
    ItemHeight = 20
    Sorted = True
    TabOrder = 3
  end
  object bClear: TButton
    Left = 375
    Top = 64
    Width = 157
    Height = 25
    Action = aClear
    TabOrder = 4
  end
  object STO: TSearchText
    Left = 375
    Top = 132
    Width = 157
    Height = 25
    ItemHeight = 60
    Style = stsOwnerDraw
    TabOrder = 5
    OnDrawItem = STDrawItem
    OnMeasureItem = STOMeasureItem
  end
  object ST: TSearchText
    Left = 212
    Top = 132
    Width = 157
    Height = 25
    TabOrder = 0
  end
  object AL: TActionList
    Left = 136
    Top = 8
    object aAdd: TAction
      Caption = 'Add to search'
      OnExecute = aAddExecute
      OnUpdate = aAddUpdate
    end
    object aClear: TAction
      Caption = 'Clear'
      OnExecute = aClearExecute
      OnUpdate = aClearUpdate
    end
  end
end
