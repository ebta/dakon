program Dakon;

uses
  FastMM4,
  Forms,
  UMain in 'UMain.pas' {FrmMain},
  UScore in 'UScore.pas' {FrmScore},
  EZCrypt in 'EZCrypt.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.CreateForm(TFrmScore, FrmScore);
  Application.Run;
end.
