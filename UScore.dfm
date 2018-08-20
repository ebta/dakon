object FrmScore: TFrmScore
  Left = 465
  Top = 256
  BorderStyle = bsDialog
  Caption = 'Skor/Nilai Tertinggi'
  ClientHeight = 340
  ClientWidth = 381
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 14
  object Label1: TLabel
    Left = 12
    Top = 12
    Width = 97
    Height = 14
    Caption = 'Pilih Jml Dakon  x Biji'
  end
  object NxScore: TNextGrid
    Left = 12
    Top = 36
    Width = 357
    Height = 293
    GridLinesStyle = lsHorizontalOnly
    HeaderSize = 25
    HeaderStyle = hsFlatBorders
    Options = [goDisableColumnMoving, goGrid, goHeader, goSelectFullRow]
    TabOrder = 0
    TabStop = True
    OnCellColoring = NxScoreCellColoring
    object NxTextColumn1: TNxTextColumn
      DefaultWidth = 153
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      Header.Caption = 'Nama Pemain'
      Header.Alignment = taCenter
      Options = [coAutoSize, coCanClick, coCanInput, coCanSort, coPublicUsing, coShowTextFitHint]
      Padding = 5
      ParentFont = False
      Position = 0
      SortType = stAlphabetic
      Width = 153
    end
    object NxTextColumn2: TNxTextColumn
      Alignment = taCenter
      DefaultWidth = 122
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      Header.Caption = 'Dakon x Biji'
      Header.Alignment = taCenter
      ParentFont = False
      Position = 1
      SortType = stAlphabetic
      Width = 122
    end
    object NxColNilai: TNxNumberColumn
      Alignment = taCenter
      DefaultValue = '0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      Header.Caption = 'Nilai'
      Header.Alignment = taCenter
      ParentFont = False
      Position = 2
      SortType = stNumeric
      Increment = 1.000000000000000000
      Precision = 0
    end
  end
  object cbDakon: TComboBox
    Left = 124
    Top = 8
    Width = 145
    Height = 22
    Style = csDropDownList
    ItemHeight = 14
    TabOrder = 1
    OnChange = cbDakonChange
  end
end
