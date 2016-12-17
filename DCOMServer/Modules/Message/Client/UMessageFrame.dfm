object FMessage: TFMessage
  Left = 0
  Top = 0
  Width = 319
  Height = 281
  TabOrder = 0
  DesignSize = (
    319
    281)
  object Bevel3: TBevel
    Left = 0
    Top = 0
    Width = 319
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    Constraints.MinWidth = 319
    Shape = bsFrame
  end
  object Bevel2: TBevel
    Left = 0
    Top = 141
    Width = 319
    Height = 140
    Anchors = [akLeft, akTop, akRight, akBottom]
    Constraints.MinHeight = 140
    Constraints.MinWidth = 319
    Shape = bsFrame
  end
  object Bevel1: TBevel
    Left = 0
    Top = 22
    Width = 319
    Height = 121
    Anchors = [akLeft, akTop, akRight]
    Constraints.MinHeight = 121
    Constraints.MinWidth = 319
    Shape = bsFrame
  end
  object LabelSender: TLabel
    Left = 4
    Top = 27
    Width = 78
    Height = 13
    Caption = #1054#1090#1087#1088#1072#1074#1080#1090#1077#1083#1100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LabelReceiver: TLabel
    Left = 4
    Top = 65
    Width = 70
    Height = 13
    Caption = #1055#1086#1083#1091#1095#1072#1090#1077#1083#1100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LabelSubject: TLabel
    Left = 4
    Top = 103
    Width = 32
    Height = 13
    Caption = #1058#1077#1084#1072
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LabelMessage: TLabel
    Left = 4
    Top = 147
    Width = 68
    Height = 13
    Caption = #1057#1086#1086#1073#1097#1077#1085#1080#1077
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LabelAttachments: TLabel
    Left = 172
    Top = 27
    Width = 139
    Height = 13
    Caption = #1055#1088#1080#1082#1088#1077#1087#1083#1077#1085#1085#1099#1077' '#1092#1072#1081#1083#1099
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LLabelPriority: TLabel
    Left = 4
    Top = 5
    Width = 68
    Height = 13
    Caption = #1055#1088#1080#1086#1088#1080#1090#1077#1090':'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object LLabelType: TLabel
    Left = 204
    Top = 5
    Width = 27
    Height = 13
    Caption = #1058#1080#1087':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LabelPriority: TLabel
    Left = 75
    Top = 5
    Width = 6
    Height = 13
    Caption = '?'
  end
  object LabelType: TLabel
    Left = 233
    Top = 5
    Width = 6
    Height = 13
    Caption = '?'
  end
  object EditSender: TEdit
    Left = 4
    Top = 41
    Width = 161
    Height = 21
    ReadOnly = True
    TabOrder = 0
    Text = '?'
  end
  object EditReceiver: TEdit
    Left = 4
    Top = 79
    Width = 161
    Height = 21
    ReadOnly = True
    TabOrder = 1
    Text = '?'
  end
  object EditSubject: TEdit
    Left = 4
    Top = 117
    Width = 161
    Height = 21
    ReadOnly = True
    TabOrder = 2
    Text = '?'
  end
  object MemoMessage: TMemo
    Left = 4
    Top = 161
    Width = 310
    Height = 116
    Anchors = [akLeft, akTop, akRight, akBottom]
    Constraints.MinHeight = 116
    Constraints.MinWidth = 310
    Lines.Strings = (
      '?')
    ReadOnly = True
    TabOrder = 3
  end
  object ListBoxAttachments: TListBox
    Left = 172
    Top = 41
    Width = 142
    Height = 97
    Anchors = [akLeft, akTop, akRight]
    Constraints.MinHeight = 97
    Constraints.MinWidth = 138
    ItemHeight = 13
    Items.Strings = (
      '?')
    TabOrder = 4
  end
end
