inherited fFrameRunLog: TfFrameRunLog
  Width = 698
  Height = 435
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 698
    Height = 435
    Align = alClient
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    object Panel1: TPanel
      Left = 0
      Top = 0
      Width = 698
      Height = 45
      Align = alTop
      BevelOuter = bvNone
      BorderWidth = 3
      ParentColor = True
      TabOrder = 0
      DesignSize = (
        698
        45)
      object Bevel1: TBevel
        Left = 3
        Top = 37
        Width = 692
        Height = 5
        Align = alBottom
        Shape = bsBottomLine
      end
      object Bevel2: TBevel
        Left = 510
        Top = 3
        Width = 5
        Height = 35
        Anchors = [akTop, akRight]
        Shape = bsLeftLine
      end
      object Check1: TCheckBox
        Left = 10
        Top = 3
        Width = 250
        Height = 35
        Caption = #26174#31034#36816#34892#26102#25968#25454
        Font.Charset = GB2312_CHARSET
        Font.Color = clWindowText
        Font.Height = -29
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnClick = Check1Click
      end
      object BtnClear: TButton
        Left = 602
        Top = 3
        Width = 85
        Height = 35
        Anchors = [akTop, akRight]
        Caption = #28165#31354
        Font.Charset = GB2312_CHARSET
        Font.Color = clWindowText
        Font.Height = -29
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        OnClick = BtnClearClick
      end
      object BtnCopy: TButton
        Left = 517
        Top = 3
        Width = 85
        Height = 35
        Anchors = [akTop, akRight]
        Caption = #22797#21046
        Font.Charset = GB2312_CHARSET
        Font.Color = clWindowText
        Font.Height = -29
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        OnClick = BtnCopyClick
      end
      object BtnHistogram: TButton
        Left = 420
        Top = 3
        Width = 85
        Height = 35
        Anchors = [akTop, akRight]
        Caption = #26609#22270
        Font.Charset = GB2312_CHARSET
        Font.Color = clWindowText
        Font.Height = -29
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        TabOrder = 3
        OnClick = BtnHistogramClick
      end
    end
    object MemoLog: TMemo
      Left = 0
      Top = 45
      Width = 698
      Height = 390
      Align = alClient
      BorderStyle = bsNone
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 1
    end
  end
end
