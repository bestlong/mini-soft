inherited fFrameSystem: TfFrameSystem
  Width = 746
  Height = 180
  Font.Color = clGreen
  object Label1: TLabel
    Left = 25
    Top = 62
    Width = 204
    Height = 12
    Caption = #33509#20351#29992#20854#23427#26041#24335#21551#21160','#35831#19981#35201#21246#36873#27492#39033'.'
    Color = clBlack
    Font.Charset = GB2312_CHARSET
    Font.Color = clGray
    Font.Height = -12
    Font.Name = #23435#20307
    Font.Style = []
    ParentColor = False
    ParentFont = False
    Transparent = True
  end
  object Label2: TLabel
    Left = 25
    Top = 108
    Width = 204
    Height = 12
    Caption = #36873#20013#35813#39033','#31243#24207#36816#34892#21518#23558#33258#21160#21551#21160#26381#21153'.'
    Color = clBlack
    Enabled = False
    Font.Charset = GB2312_CHARSET
    Font.Color = clGray
    Font.Height = -12
    Font.Name = #23435#20307
    Font.Style = []
    ParentColor = False
    ParentFont = False
    Transparent = True
  end
  object BtnSetDB: TcxButton
    Left = 10
    Top = 132
    Width = 120
    Height = 35
    Caption = #37197#32622#25968#25454#24211
    TabOrder = 0
    OnClick = BtnSetDBClick
  end
  object CheckAutoRun: TCheckBox
    Left = 10
    Top = 40
    Width = 165
    Height = 17
    Caption = #24320#26426#21518#33258#21160#36816#34892
    Font.Charset = GB2312_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = CheckAutoRunClick
  end
  object CheckAutoMin: TCheckBox
    Left = 10
    Top = 85
    Width = 165
    Height = 17
    Caption = #36816#34892#21518#21551#21160#30417#27979#26381#21153
    Enabled = False
    Font.Charset = GB2312_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = CheckAutoRunClick
  end
  object BtnSetUI: TcxButton
    Left = 139
    Top = 132
    Width = 120
    Height = 35
    Caption = #37197#32622#30028#38754
    TabOrder = 3
    OnClick = BtnSetUIClick
  end
  object cxLabel1: TcxLabel
    Left = 0
    Top = 0
    Align = alTop
    AutoSize = False
    Caption = #31995#32479#35774#32622':'
    ParentFont = False
    Properties.Alignment.Vert = taVCenter
    Properties.LineOptions.Alignment = cxllaBottom
    Properties.LineOptions.OuterColor = clGreen
    Properties.LineOptions.Visible = True
    Height = 30
    Width = 746
    AnchorY = 15
  end
  object cxGroupBox1: TcxGroupBox
    Left = 402
    Top = 32
    Caption = #21151#33021
    ParentFont = False
    TabOrder = 5
    Height = 135
    Width = 115
    object BtnAddPort: TcxButton
      Left = 12
      Top = 22
      Width = 85
      Height = 30
      Caption = #28155#21152#20018#21475
      TabOrder = 0
      OnClick = BtnAddPortClick
    end
    object BtnSetAddr: TcxButton
      Left = 12
      Top = 61
      Width = 85
      Height = 30
      Caption = #35013#32622#22320#22336
      TabOrder = 1
      OnClick = BtnSetAddrClick
    end
    object BtnTime: TcxButton
      Left = 12
      Top = 100
      Width = 85
      Height = 30
      Caption = #26657#27491#26102#38388
      TabOrder = 2
      OnClick = BtnTimeClick
    end
  end
  object BtnParam: TcxButton
    Left = 268
    Top = 132
    Width = 122
    Height = 35
    Caption = #37197#32622#36816#34892#21442#25968
    TabOrder = 6
    OnClick = BtnParamClick
  end
end