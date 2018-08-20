unit UScore;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, NxColumnClasses, NxColumns, NxScrollControl,
  NxCustomGridControl, NxCustomGrid, NxGrid, StdCtrls;

type
  TFrmScore = class(TForm)
    NxScore: TNextGrid;
    NxTextColumn1: TNxTextColumn;
    NxTextColumn2: TNxTextColumn;
    NxColNilai: TNxNumberColumn;
    Label1: TLabel;
    cbDakon: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure cbDakonChange(Sender: TObject);
    procedure NxScoreCellColoring(Sender: TObject; ACol, ARow: Integer;
      var CellColor, GridColor: TColor; CellState: TCellState);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadScore;
    procedure RefreshComboDakon;
  end;

var
  FrmScore: TFrmScore;

implementation

uses
  EZCrypt,UMain;

{$R *.dfm}

{ TFrmScore }

procedure TFrmScore.LoadScore;
var
  mIn,mOut : TMemoryStream;
begin
  if FileExists(HighScoreFilename) then
  begin
    Min  := TMemoryStream.Create;
    Mout := TMemoryStream.Create;
    try
      // load file score ke memory stream
      Min.LoadFromFile(HighScoreFilename);
      mOut.SetSize(mIn.Size);
      // Decrypt terlebih dahulu
      MemoryDecrypt(mIn.Memory,mIn.Size,mOut.Memory,mOut.Size,Kunci);
      {$IFDEF DEBUG}
      mOut.SaveToFile('hasil_decrypt.txt');
      {$ENDIF}
      // load score ke grid
      NxScore.LoadFromStream(mOut);
    finally
      mIn.Free;
      mOut.Free;
    end;
  end;

end;

procedure TFrmScore.FormCreate(Sender: TObject);
begin
  LoadScore;
  RefreshComboDakon;
end;

procedure TFrmScore.RefreshComboDakon;
var
  i : Integer;
begin
  cbDakon.Clear;
  for i:=0 to NxScore.RowCount-1 do
  begin
    // tambahkan kategori ( dakon x bji ) jika belum ada di combobox
    if cbDakon.Items.IndexOf(NxScore.Cells[1,i]) < 0 then
      cbDakon.Items.Add(NxScore.Cells[1,i]);
  end;
  cbDakon.Sorted := True;
end;

procedure TFrmScore.cbDakonChange(Sender: TObject);
var
  i : integer;
begin
  for i:=0 to NxScore.RowCount-1 do
  begin
    // tampilkan hanya jika isi kolom = pilihan di combobox
    NxScore.RowVisible[i] := NxScore.Cells[1,i] = cbDakon.Text;
  end;  
end;

procedure TFrmScore.NxScoreCellColoring(Sender: TObject; ACol,
  ARow: Integer; var CellColor, GridColor: TColor; CellState: TCellState);
begin
  if not(csSelected in CellState) then
  begin
    if (ARow mod 2 = 0) then
      CellColor := $00F5F5F5;
  end
end;

end.
