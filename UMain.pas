unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  GR32, GR32_Image, GR32_Layers, GR32_Misc, GR32_Text,
  GR32_Objects, ExtCtrls, ComCtrls, StdCtrls, XPMan, Buttons, Spin,
  EZCrypt, MMSystem;

const
  WM_AFTER_SHOW = WM_USER + 300; // custom message

  MARGIN_LEFT = 20; // Margin kiri area Gambar Dakon
  DM = 70; // Dameter dakon
  SP = 10; // Spasi antar Dakon

type
  TPlayer = (Player1, Player2);
  TStatusDakon = (sdNormal, sdHover, sdStart, sdEnd, sdDown, sdActive);
  TStatusDakons = set of TStatusDakon;
  TIntegerArray = array of Integer;
  TSound = (sWin, sZap, sStep, sStop, sGet);
  TFrmMain = class(TForm)
    img32: TImage32;
    SB1: TStatusBar;
    PnlTop: TPanel;
    XPManifest1: TXPManifest;
    btnCreateDakon: TBitBtn;
    PageControl1: TPageControl;
    Tab2Pemain: TTabSheet;
    TabKomputer: TTabSheet;
    Label4: TLabel;
    ePlayer1: TEdit;
    ePlayer2: TEdit;
    Label5: TLabel;
    rbLevel1: TRadioButton;
    rbLevel2: TRadioButton;
    rbLevel3: TRadioButton;
    Label6: TLabel;
    ePlayerKomputer: TEdit;
    Label7: TLabel;
    Label9: TLabel;
    rbPemain1: TRadioButton;
    rbPemain2: TRadioButton;
    Panel1: TPanel;
    Label10: TLabel;
    rbPemain1C: TRadioButton;
    rbComputer: TRadioButton;
    Label1: TLabel;
    spJmlDakon: TSpinEdit;
    spJmlBiji: TSpinEdit;
    Label2: TLabel;
    btnStop: TBitBtn;
    btnScore: TBitBtn;
    rbLevel4: TRadioButton;
    Panel2: TPanel;
    cbSuara: TCheckBox;
    lblKecepatan: TLabel;
    TrackSpeed: TTrackBar;
    lblms: TLabel;
    Image321: TImage32;
    procedure FormCreate(Sender: TObject);
    procedure img32MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer; Layer: TCustomLayer);
    procedure img32MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure FormShow(Sender: TObject);
    procedure btnCreateDakonClick(Sender: TObject);
    procedure img32MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnStopClick(Sender: TObject);
    procedure TrackSpeedChange(Sender: TObject);
    procedure btnScoreClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    fontSzDakon,

    // Jumlah Total Dakon + 2 Lumbung, harus genap
    jmlObject,
    // Jumlah biji per Dakon
    jmlBiji: Integer;

    {TODO Pause the Game }
    // Digunakan agar permainan bisa di Pause..
//    PauseGame : Boolean;
//    IdxPause, BijiPause  : Integer;

    curPlayer: TPlayer;
    ttfcArial: TTrueTypeFont;
    lblPlayer1, lblPlayer2: TText32;

    // Menyimpan status UI dakon, lihat TStatusDakon
    statusDakon: array of TStatusDakons;
    // Array Object Dakon
    DakonKe: array of TDrawObjEllipse;
    // Status apakah dakon sedang jalan
    isPlaying, EndGame: Boolean;

    // langkah Komputer
    //ComputerStep : TIntegerArray;

    procedure WmAfterShow(var Msg: TMessage); message WM_AFTER_SHOW;
    procedure DrawPlayerNames(const pemain1, pemain2: WideString);
    procedure EnableOptions(enabled: Boolean = True);
    procedure ObjDptBom(const obj: TDrawObjEllipse);
    procedure ObjGray(const obj: TDrawObjEllipse);
  public
    { Public declarations }
    procedure Inisialiasi;
    procedure DrawObject;
    procedure DrawBackground;
    procedure ObjHover(const obj: TDrawObjEllipse);
    procedure ObjNormal(const obj: TDrawObjEllipse);
    procedure ObjDown(const obj: TDrawObjEllipse);
    procedure ObjFinish(const obj: TDrawObjEllipse);
    procedure ObjActive(const obj: TDrawObjEllipse);
    procedure ObjMerah(const obj: TDrawObjEllipse);

    procedure ClearAllHover;
    // mengecek apakah mouse event diijinkan di DakonNo
    function MouseEventAllowed(DakonNo: Integer): Boolean;

    function GetJmlBiji(NoDakon: Integer): Integer;
    procedure SetJmlBiji(noDakon: Integer; jmlBiji: string);

    // SrcBijiSisa rencana digunakan untuk mendukung PAUSE game
    procedure PutarBijiDakon(iStart: Integer; SrcBijiSisa : Integer =0);
    procedure StartPutarDakon(iStart: Integer);
    procedure SetNextPlayer(player: TPlayer);

    procedure SaveWinner(const nama, dakon: string; nilai: Integer);
    procedure PlayTheSound(Sound: TSound);

    function GetPanjangDakon : Integer;
    function GetDakonRect : TRect;

    // --- Simple AI for Comptuer ----
    // Mencari path terbaik, hasilnya disimpan dalam dst, tiap item = CSV of No dakon
    // timeout = waktu timeout pencarian path
    procedure GetBestPath(var dst: TStringList; player: TPlayer; MaxDeep: Integer);
    procedure ComputerTurn;
    procedure ComputerStart(StepsInCsv: string);

    procedure SetInfoPlayer(const BijiSisa: Integer);
  end;

var
  FrmMain: TFrmMain;
  Kunci: TWordTriple;
  HighScoreFilename: string;


implementation

uses
  UScore, NxGrid;


{$R *.dfm}

// Untuk mengetest hilangkan tanda titik dibawah ini
// bisa juga ditambahkan di berbagai tempat ketika ingin mengetes
// dengan {$IFDEF DEBUG} ... {$ENDIF}
{$DEFINE DEBUG}

// Fungsi delay yang digunakan, alternatif dari sleep
// Kalau dengan sleep, aplikasi terhenti sama sekali (terkesan 'hang')
// Dengan fungsi ini, event lain masih bisa diproses

procedure Delay(dwMilliseconds: Longint);
var
//  iStart, iStop: DWORD;
  iStart, iStop: Integer;
begin
  iStart := GetTickCount;
  repeat
    iStop := GetTickCount;
    Application.ProcessMessages;
    Sleep(3); // addition to avoid high CPU last
  until (iStop - iStart) >= dwMilliseconds;
end;


procedure TFrmMain.Inisialiasi;
begin
  fontSzDakon := 18;

  // Tentukan maksimal jumlah dakon berdasar lebar layar monitor
  spJmlDakon.MaxValue := (Screen.Width - 2 * (DM + SP * 2) - MARGIN_LEFT * 2) div (DM + SP);

  img32.Bitmap.DrawMode := dmBlend;
  img32.SetupBitmap;
  HighScoreFilename := ExtractFilePath(Application.ExeName) + 'dakon.dat';

  lblPlayer1 := TText32.Create;
  lblPlayer2 := TText32.Create;
  ttfcArial := TrueTypeFontClass.Create('Arial', 30);

  lblms.Caption := IntToStr(TrackSpeed.Position) + 'ms';
//  PauseGame := False;
end;


procedure TFrmMain.FormCreate(Sender: TObject);
begin
  Inisialiasi;
end;

procedure TFrmMain.ObjHover(const obj: TDrawObjEllipse);
begin
  obj.StrokeColor := clGreen32;
  obj.Font.Color := clMaroon;
  // Jika lumbung (digunakan saat lumbung bertambah isinya)
  if (obj.Tag = jmlObject) or (obj.Tag = (jmlObject div 2)) then
    obj.Font.Size := fontSzDakon + 6
  else
    obj.Font.Size := fontSzDakon;

  obj.StrokeStyle := psSolid;
  obj.FillColors := MakeArrayOfColor32([$CCFFFFFF, $CCADFF30]);
  obj.RePaint;
end;

procedure TFrmMain.ObjNormal(const obj: TDrawObjEllipse);
begin
  if (sdActive in statusDakon[obj.Tag]) and
    (obj.Tag < jmlObject) then
  begin
    ObjActive(obj);
    Exit;
  end;
  obj.StrokeColor := $CCAA4400;
  obj.Font.Color := clNavy;
  obj.Font.Size := fontSzDakon;
  obj.StrokeStyle := psSolid;
  obj.FillColors := MakeArrayOfColor32([$CCFFFFFF, $CCDDDD44]);
  obj.RePaint;
end;

procedure TFrmMain.ObjDown(const obj: TDrawObjEllipse);
begin
  obj.StrokeColor := clNavy32;
  obj.Font.Color := clBlack;
  obj.Font.Size := fontSzDakon - 2;
  obj.StrokeStyle := psSolid;
  obj.FillColors := MakeArrayOfColor32([$CCFFFFFF, $CC71A732]);
  obj.RePaint;
end;

procedure TFrmMain.ObjFinish(const obj: TDrawObjEllipse);
begin
  obj.StrokeColor := $CC557FFF;
  obj.Font.Color := clBlue;
  obj.Font.Size := fontSzDakon;
  obj.StrokeStyle := psSolid;
  obj.FillColors := MakeArrayOfColor32([$CCFFFFFF, $CCAAD4FF]);
  obj.RePaint;
end;

procedure TFrmMain.ObjActive(const obj: TDrawObjEllipse);
begin
  statusDakon[obj.Tag] := statusDakon[obj.Tag] + [sdActive];
  obj.StrokeColor := $CC3333CC;
  obj.Font.Size := fontSzDakon;
  obj.Font.Color := clRed;
  obj.StrokeStyle := psDot;
  obj.FillColors := MakeArrayOfColor32([$CCFFFFFF, $CCAAD4FF]);
  obj.RePaint;
end;

procedure TFrmMain.ObjMerah(const obj: TDrawObjEllipse);
begin
  obj.StrokeColor := $CCCC0000;
  obj.Font.Size := fontSzDakon;
  obj.Font.Color := clMaroon;
  obj.StrokeStyle := psSolid;
  obj.FillColors := MakeArrayOfColor32([$CCFFFFFF, $CCFF9999]);
  obj.RePaint;
end;

procedure TFrmMain.ObjDptBom(const obj: TDrawObjEllipse);
begin
  obj.StrokeColor := $FFFF5500;
  obj.Font.Color := clNavy;
  obj.Font.Size := fontSzDakon + 8;
  obj.StrokeStyle := psSolid;
  obj.FillColors := MakeArrayOfColor32([$CCFFFFFF, $EEF5AE45]);
  obj.RePaint;
end;

procedure TFrmMain.ObjGray(const obj: TDrawObjEllipse);
begin
  obj.StrokeColor := $FF999999;
  obj.Font.Color := clGray;
  obj.Font.Size := fontSzDakon - 2;
  obj.StrokeStyle := psSolid;
  obj.FillColors := MakeArrayOfColor32([$CCFFFFFF, $AABCBCBC]);
  obj.RePaint;
end;

procedure TFrmMain.ClearAllHover;
var
  i, tag: integer;
{$IFDEF DEBUG}
  a, b, c: Int64;
{$ENDIF}
begin
{$IFDEF DEBUG}
  QueryPerformanceFrequency(c);
  QueryPerformanceCounter(a);
{$ENDIF}
  for i := 0 to img32.Layers.Count - 1 do
    if img32.Layers.Items[i] is TDrawObjEllipse then
    begin
      tag := img32.Layers.Items[i].Tag;
      if sdHover in statusDakon[tag] then
      begin
        ObjNormal(TDrawObjEllipse(img32.Layers.Items[i]));
        statusDakon[tag] := statusDakon[tag] - [sdHover];
      end;
    end;
{$IFDEF DEBUG}
  QueryPerformanceCounter(b);
  SB1.Panels[0].Text := FloatToStrF(1000 * (B - A) / C, ffFixed, 4, 4) + ' ms';
{$ENDIF}
end;


function TFrmMain.MouseEventAllowed(DakonNo: Integer): Boolean;
begin
  Result := False;
  if EndGame then Exit;
  if isPlaying then Exit;
  // Jika yg di hover adalah Lumbung, maka exit
  if (DakonNo = jmlObject) or (DakonNo = (jmlObject div 2)) then Exit;
  // Ijinkan khusus untuk curPlayer
  if (curPlayer = Player1) and (DakonNo > (jmlObject div 2)) then Exit;
  if (curPlayer = Player2) and (DakonNo < (jmlObject div 2)) then Exit;

  if TabKomputer.Showing and (curPlayer = Player2) then Exit;
  if GetJmlBiji(DakonNo) = 0 then Exit;

  // Selain kriteria diatas, ijinkan Dakon
  Result := True;
end;


procedure TFrmMain.img32MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer; Layer: TCustomLayer);
var
  pts: TArrayOfFloatPoint;
  rec: TFloatRect;
  tag: integer;
begin
  if layer is TDrawObjEllipse then
  begin
    tag := TDrawObjEllipse(layer).Tag;

    // Menghindari repetisi..
    if not MouseEventAllowed(tag) then Exit;

    // Jika status dakon sudah hover, maka exit
    if sdHover in statusDakon[tag] then Exit;

{$IFDEF DEBUG}
    SB1.Panels[0].Text := 'Obj:' + IntToStr(tag);
    SB1.Panels[1].Text := 'Index:' + IntToStr(TDrawObjEllipse(layer).Index);
{$ENDIF}
    // Ambil Trect dari Object
    rec := TDrawObjEllipse(layer).Location;
    // Kurangi 4 pixel, karena gambar ada didalam kotak sekitar 4px
    InflateRect(rec, -4, -4);
    // Ambil posisi tepi/border, ubah ke Array of FloatPoint
    pts := AFixedToAFloat(GetEllipsePoints(rec));

    ClearAllHover;
    // Jika mouse ada didalam polygon / object
    if PtInPolygon(FloatPoint(x, y), pts) then
    begin
      ObjHover(TDrawObjEllipse(layer));
      statusDakon[tag] := statusDakon[tag] + [sdHover];
    end
  end
end;

procedure TFrmMain.img32MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  pts: TArrayOfFloatPoint;
  rec: TFloatRect;
  tag: Integer;
begin
  // Copas dari fungsi MouseMove sebelumnya
  if layer is TDrawObjEllipse then
  begin
    tag := TDrawObjEllipse(layer).Tag;

    // Menghindari repetisi
    if not MouseEventAllowed(tag) then Exit;

    // Ambil Trect dari Object
    rec := TDrawObjEllipse(layer).Location;
    // Kurangi 4 pixel, karena gambar ada didalam kotak sekitar 4px
    InflateRect(rec, -4, -4);

    // Ambil posisi tepi/border, ubah ke Array of FloatPoint
    pts := AFixedToAFloat(GetEllipsePoints(rec));
    // Jika mouse ada didalam polygon / object
    if PtInPolygon(FloatPoint(x, y), pts) then
      ObjDown(TDrawObjEllipse(layer))
    else
      ObjNormal(TDrawObjEllipse(layer));
  end;
end;

procedure TFrmMain.img32MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  pts: TArrayOfFloatPoint;
  rec: TFloatRect;
  tag: Integer;
begin
  // Copas dari fungsi MouseMove sebelumnya
  if layer is TDrawObjEllipse then
  begin
    tag := TDrawObjEllipse(layer).Tag;

    // Menghindari repetisi
    if not MouseEventAllowed(tag) then Exit;

    // Ambil Trect dari Object
    rec := TDrawObjEllipse(layer).Location;
    // Kurangi 4 pixel, karena gambar ada didalam kotak sekitar 4px
    InflateRect(rec, -4, -4);

    // Ambil posisi tepi/border, ubah ke Array of FloatPoint
    pts := AFixedToAFloat(GetEllipsePoints(rec));
    // Jika mouse ada didalam polygon/object
    if PtInPolygon(FloatPoint(x, y), pts) then
    begin
      ObjNormal(TDrawObjEllipse(layer));
      StartPutarDakon(tag);
    end;
  end;
end;


// Procedure untuk menggambar Dakon dan Lumbung serta nilai isinya

procedure TFrmMain.DrawObject;
var
  i, x1, y1, x2, y2, lumb1, lumb2: integer;
  sz: TFloatRect;
  obj: TDrawObjEllipse;
begin
  lumb1 := jmlObject div 2;
  lumb2 := jmlObject;

  // Inisialisasi Array StatusDakon, index mulai 1, 0 tidak dipakai
  SetLength(statusDakon, jmlObject + 1);

  // Inisialisasi array dakon, index dakon mulai 1, 0 tidak dipakai
  SetLength(DakonKe, jmlObject + 1);

  for i := 1 to jmlObject do
  begin
    obj := TDrawObjEllipse.Create(img32.Layers);
    DakonKe[i] := obj;
    with obj do
    begin
      Delay(10);
      Application.ProcessMessages;
      // Tag digunakan di Mouse Event
      Tag := i;
      statusDakon[i] := [sdNormal];

      if (i <> lumb1) and (i <> lumb2) then
        SetJmlBiji(i, IntToStr(jmlBiji));

      Font.Name := 'Tahoma';
      Font.Style := [fsBold];
      if curPlayer = player1 then
      begin
        if i < lumb1 then
          ObjActive(obj)
        else
          ObjNormal(obj)
      end
      else
      begin
        if (i > lumb1) and (i < lumb2) then
          ObjActive(obj)
        else
          ObjNormal(obj)
      end;

      FillStyle := fsRadial;
      StrokeWidth := 2;
      //BalloonPos := bpBottomLeft;
      //ShadowOffset := 3;

      // Default untuk Object 1..8
      x1 := MARGIN_LEFT + DM * i + SP + SP * i;
      x2 := DM + x1;
      y1 := DM * 3;
      y2 := DM + y1;
      // LUmbung ke-1 (object ke-8)
      if i = lumb1 then
      begin
        y1 := DM * 2;
        y2 := DM + y1;
      end
      else if i > lumb1 then
      begin
        x2 := MARGIN_LEFT + (DM * lumb2 + SP + SP * lumb2) - (DM * (i - 1) + SP + SP * (i - 1));
        x1 := x2 - DM;
        y1 := DM;
        y2 := DM + y1;
        // Lumbung-2 (object ke-16)
        if i = lumb2 then
        begin
          y1 := y1 + DM;
          y2 := y1 + DM;
        end;
      end;

      sz := FloatRect(x1, y1, x2, y2);
      // untuk obj 16 dan 8 perbesar ukurannya = Lumbung
      if (i = lumb2) or (i = lumb1) then
        InflateRect(sz, SP, SP);

      Position(sz, 0);
      Repaint;
    end;
  end;
end;

procedure TFrmMain.DrawPlayerNames(const pemain1, pemain2: WideString);
var
  lbr: Single;
  r2, r1: TFloatRect;
begin
  img32.Bitmap.Clear($FFF0F0F0);

  // lebar/panjang dakon
  lbr := GetPanjangDakon;

  if (lbr < (Screen.Width - MARGIN_LEFT)) and (lbr > 786) then
    FrmMain.Width := Round(lbr + 2 * MARGIN_LEFT)
  else if lbr < 786 then
    FrmMain.Width := 786;

  FrmMain.Height := PnlTop.Height + DM * 6;

  r2 := FloatRect(MARGIN_LEFT, 0, lbr, DM);
  r1 := FloatRect(MARGIN_LEFT, DM * 4, lbr, DM * 5);

  lblPlayer1.Draw(img32.Bitmap, r1, pemain1, ttfcArial, clBlack32, aCenter, aMiddle);
  //lblPlayer1.DrawAndOutline(img32.Bitmap,r1.Left,r1.Right,pemain1,ttfcArial,2.0,clGreen32,clYellow32);
  lblPlayer2.Draw(img32.Bitmap, r2, pemain2, ttfcArial, clBlack32, aCenter, aMiddle);
end;

// Memastikan agar dijalankan ketika Form sudah tampil
// di event FormShow saja tidak cukup. Credit to torry.net

procedure TFrmMain.WmAfterShow(var Msg: TMessage);
begin
  // Jika dakon ingin otomatis dibuat ketika Form tampil
  //btnCreateDakon.Click;
end;

procedure TFrmMain.FormShow(Sender: TObject);
begin
  // Post the custom message WM_AFTER_SHOW to our form
  PostMessage(Self.Handle, WM_AFTER_SHOW, 0, 0);
end;

procedure TFrmMain.btnCreateDakonClick(Sender: TObject);
var
  lbr: Integer;
begin
  jmlObject := 2 + spJmlDakon.Value * 2;
  jmlBiji := spJmlBiji.Value;

  if Tab2Pemain.Showing then
  begin
    if (Trim(ePlayer1.Text) = '') or (Trim(ePlayer2.Text) = '') then
    begin
      MessageDlg('Pemain 1 dan 2 tidak boleh kosong' + #13#10 +
        'Silahkan diisi terlebih dahulu', mtError, [mbOK], 0);
      Exit;
    end;

    if rbPemain1.Checked then
      curPlayer := Player1
    else
      curPlayer := Player2;
  end
  else
  begin
    if Trim(ePlayerKomputer.Text) = '' then
    begin
      MessageDlg('Anda belum mengisikan nama' + #13#10 +
        'Silahkan diisi terlebih dahulu', mtError, [mbOK], 0);
      Exit;
    end;

    if rbComputer.Checked then
      curPlayer := Player2
    else
      curPlayer := Player1;
  end;
  SetInfoPlayer(jmlBiji);

  EnableOptions(false);

  // lebar/panjang dakon
  lbr := GetPanjangDakon;
  img32.Layers.Clear;
  img32.Bitmap.SetSize(lbr + 2 * MARGIN_LEFT, img32.Height);
  img32.Layers.MouseEvents := True;

  DrawBackground;

  if Tab2Pemain.Showing then
    DrawPlayerNames(ePlayer1.Text, ePlayer2.Text)
  else
    DrawPlayerNames(ePlayerKomputer.Text, 'Komputer');
  DrawObject;

  if TabKomputer.Showing and rbComputer.Checked then
  begin
    Delay(1000);
    ComputerTurn;
  end;
end;


procedure TFrmMain.btnStopClick(Sender: TObject);
begin
  EnableOptions(true);
end;

// Algoritma utama memutar biji dakon
// iStart = Index No dakon yg mulai memutar

procedure TFrmMain.PutarBijiDakon(iStart: Integer; SrcBijiSisa : Integer =0);
var
  iNext, BijiSisa, iEnd, n, m, lumb1, lumb2: Integer;
  GantiPemain: Boolean;

  // Lumbung dapat tambahan biji dari Ngebom lawannya
  procedure DapatBom(lumbung, dptBiji: Integer);
  begin
    PlayTheSound(sZap);
    ObjMerah(DakonKe[lumb2 - iEnd]);
    Delay(500);
    SetJmlBiji(lumb2 - iEnd, '');
    ObjNormal(DakonKe[lumb2 - iEnd]);

    m := GetJmlBiji(lumbung);
    SetJmlBiji(lumbung, IntToStr(m + dptBiji));

    // Animasi Suara dan Warna Lumbung
    ObjDptBom(DakonKe[lumbung]);
    PlayTheSound(sWin);
    Delay(1000);
    ObjNormal(DakonKe[lumbung]);
  end;
begin
  // isi dakon harus lebih dari 1');
  // if (iStart > 15) or (iStart = 8) or (jml<1) then Exit;

  lumb1 := jmlObject div 2;
  lumb2 := jmlObject;

  // TODO: Jika permainan dimulai setelah sebelumyya Pause
  //  if SrcBijiSisa > 0 then
  //    BijiSisa := SrcBijiSisa
  //  else

    // Inisialisasi Biji Dakon yg diambil
    BijiSisa := StrToIntDef(DakonKe[iStart].Text, 0);
    // Biji dakon diambil, sehingga kosongi captionnya
    SetJmlBiji(iStart, '');


  iNext := iStart + 1;
  // Jalankan terus (putar)  biji dakon sampai BijiSisa=0
  while (BijiSisa > 0) and not EndGame do
  begin
    if iNext > lumb2 then iNext := 1;

    // Cek melewati lumbung atau tidak
    if (iNext = lumb1) and (curPlayer = player2) then iNext := lumb1 + 1;
    if (iNext = lumb2) and (curPlayer = Player1) then iNext := 1;

    // Tambah 1 Biji untuk Dakon yg dilewati
    SetJmlBiji(iNext, IntToStr(GetJmlBiji(iNext) + 1));

    // Jika biji masuk ke Lumbung sendiri
    if (iNext = lumb2) or (iNext = lumb1) then
    begin
      PlayTheSound(sGet);
      Delay(100);
    end
    else
      PlayTheSound(sStep);

    // Ubah tampilan (UI) dakon yang aktif
    if BijiSisa = 1 then
    begin
      if (iNext = lumb2) <> (iNext = lumb1) then
        PlayTheSound(sStop);

      ObjFinish(DakonKe[iNext]);
      Delay(500);
    end
    else
    begin
      ObjHover(DakonKe[iNext]);
      Delay(TrackSpeed.Position);
    end;

//    if PauseGame and (BijiSisa > 1) then
//    begin
//      IdxPause  := iNext;
//      BijiPause := BijiSisa-1;
//      ClearAllHover;
//      ObjHover(DakonKe[iNext]);
//      Break;
//    end;

    if EndGame then Exit;
    ObjNormal(DakonKe[iNext]);
    Inc(iNext);
    Dec(BijiSisa);
    SetInfoPlayer(BijiSisa - 1);

    // Jika Biji Dakon habis
    if BijiSisa = 0 then
    begin
      iEnd := iNext - 1;
      // Jika dakon berhenti di tempat yg tidak kosong
      if GetJmlBiji(iEnd) > 1 then
        if (iEnd <> lumb1) and (iEnd <> lumb2) then
        begin
          BijiSisa := GetJmlBiji(iEnd);
          SetJmlBiji(iEnd, '');
        end
    end;
  end;

  iEnd := iNext - 1;
  GantiPemain := True;

  // Jika dakon terakhir masuk lumbungnya sendiri
  if (iEnd = lumb1) or (iEnd = lumb2) then
    GantiPemain := False
  else
    // Persiapan NGEBOM
    // Jika isi dakon yang diisi sebelumnya "kosong"
    if (GetJmlBiji(iEnd) = 1) then
    begin
      // Jika dakon terakhir "milik sendiri",
      if ((curPlayer = Player1) and (iEnd < lumb1)) or
        ((curPlayer = Player2) and (iEnd > lumb1)) then
      begin
          // ambil jumlah biji dakon lawan yang ada dihadapannya
        n := GetJmlBiji(lumb2 - iEnd);
          // Ngebom jika dihadapannya lebih dari 1
        if n > 0 then
        begin
            // Lihat procedure DapatBom
          if curPlayer = Player1 then
            DapatBom(lumb1, n)
          else
            DapatBom(lumb2, n);
        end;
      end;
    end;

  if GantiPemain then
    if curPlayer = Player1 then
      SetNextPlayer(Player2)
    else
      SetNextPlayer(Player1)
  else
    // Pemain aktif putar dakon lagi
    SetNextPlayer(curPlayer);
end;

function TFrmMain.GetJmlBiji(NoDakon: Integer): Integer;
begin
  Result := StrToIntDef(DakonKe[NoDakon].Text, 0);
end;

procedure TFrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  if not EndGame then
    EndGame := True;
  CanClose := True;
end;

procedure TFrmMain.SetJmlBiji(noDakon: Integer; jmlBiji: string);
begin
  DakonKe[noDakon].Text := jmlBiji;
  DakonKe[noDakon].RePaint;
end;

procedure TFrmMain.SetNextPlayer(player: TPlayer);
var
  i, div2: integer;
  n1, n2, iMax: Integer;
  oldPlayer: TPlayer;
  nama: string;
begin
  if EndGame then Exit;
  div2 := jmlObject div 2;
  // Jumlah dakon tersisa dimasing2 pemain
  n1 := 0; n2 := 0;
  oldPlayer := curPlayer;
  curPlayer := player;
  SetInfoPlayer(-1);

  // jumlah total dakon tersisa pemain-1
  for i := 1 to div2 - 1 do
    n1 := n1 + GetJmlBiji(i);

  // Jumlah total dakon tersisa pemain-2
  for i := div2 + 1 to jmlObject - 1 do
    n2 := n2 + GetJmlBiji(i);

  if (n1 = 0) and (n2 = 0) then
  begin
    // n1 dan n2 sekarang jumlah lumbung1 dan 2
    n1 := GetJmlBiji(jmlObject div 2);
    n2 := GetJmlBiji(jmlObject);
    img32.Layers.MouseEvents := False;

    if n1 = n2 then
    begin
      if MessageDlg('Permainan berakhir SERI..' + #13#10 +
        'Apakah akan memulai lagi dari awal?', mtConfirmation, [mbYes, mbNo],
        0) = mrYes then
      begin
        btnCreateDakon.Click;
      end
      else
        EnableOptions;
      Exit;
    end
    else if n1 > n2 then
    begin
      iMax := n1;
      if Tab2Pemain.Showing then
        nama := ePlayer1.Text
      else
        nama := ePlayerKomputer.Text;
    end
    else
    begin
      iMax := n2;
      if Tab2Pemain.Showing then
        nama := ePlayer2.Text
      else
        nama := 'Komputer';
    end;

    SaveWinner(nama, Format('%d x %d', [spJmlDakon.Value, spJmlBiji.Value]), iMax);
    MessageDlg('Permainan Selesai'#13 +
      'Pemenangnya adalah: ' + nama, mtInformation, [mbOK], 0);
    EnableOptions;
    Exit;
  end;

  if player = Player1 then
    // Jika Player-1 dakonnya masih ada yg bisa diputarkan
    if n1 > 0 then
      for i := 1 to div2 - 1 do
      begin
        // tandai dakon 1 yg bisa di klik/aktif
        if GetJmlBiji(i) > 0 then
          ObjActive(DakonKe[i]);
      end
    else
      // Jika dakon pemain 1 habis, ganti pemain-2
      SetNextPlayer(player2)
  else
  begin
    // jika dakon-2 masih ada yg bisa diputarkan
    if n2 > 0 then
    begin
      // tandai dakon 2 yg bisa di klik/aktif
      for i := div2 + 1 to jmlObject - 1 do
      begin
        if GetJmlBiji(i) > 0 then
          ObjActive(DakonKe[i]);
      end;

      // Gantian komputer yg main
      // Pastikan dijalankan saat pergantian ke Komputer, sekali saja
      // Ketika sebelumnya komputer yg jalan, maka tidak diulang lagi ComputerTurn
      if (TabKomputer.Showing) and (oldPlayer = Player1) then
      begin
        Delay(500);
        ComputerTurn;
      end;
    end
    else
      // dakon-2 sudah habis semua, ganti pemain-1
      SetNextPlayer(Player1);
  end;
end;

procedure TFrmMain.StartPutarDakon(iStart: Integer);
var
  i: integer;
begin
  //if isPlaying then Exit;
  isPlaying := True;
  // Hilangkan status Active
  for i := 1 to jmlObject do
  begin
    statusDakon[i] := statusDakon[i] - [sdActive];
    ObjNormal(DakonKe[i]);
  end;

  PutarBijiDakon(iStart);
//  if not PauseGame then
  isPlaying := False;
end;

// Algoritma mencari semua langkah yang mungkin dilakukan oleh Player
// MaxDeep adalah kedalaman looping

procedure TFrmMain.GetBestPath(var dst: TStringList; player: TPlayer; MaxDeep: Integer);
var
  i, j, x1, x2, idxLumbung: integer;
  JmlBijiDakonOrg, jmlBijiTmp, Steps: TIntegerArray;
  PutarLagi: Boolean;
  {$IFDEF DEBUG}
  WalkCnt : Integer;
  {$ENDIF}

  // Digunakan sebagai AI untuk menentukan hasil dakon masuk lumbung
  // result TRUE jika putaran diulang lagi oleh player
  function _PutarBijiDakon(var jmlBijiDakon: TIntegerArray; iStart: Integer): Boolean;
  var
    iNext, BijiSisa, iEnd, n, m, lumb1, lumb2: Integer;
    GantiPemain: Boolean;
  begin
    lumb1 := jmlObject div 2;
    lumb2 := jmlObject;

    // Inisialisasi Biji Dakon yg diambil
    BijiSisa := jmlBijiDakon[iStart];
    // Biji dakon diambil, sehingga kosongi nilainya
    jmlBijiDakon[iStart] := 0;

    iNext := iStart + 1;
    // Jalankan terus (putar)  biji dakon sampai BijiSisa=0
    while BijiSisa > 0 do
    begin
      if iNext > lumb2 then iNext := 1;

      // Cek melewati lumbung atau tidak
      if (iNext = lumb1) and (Player = player2) then iNext := lumb1 + 1;
      if (iNext = lumb2) and (Player = Player1) then iNext := 1;

      // Tambah 1 Biji untuk Dakon yg dilewati
      jmlBijiDakon[iNext] := jmlBijiDakon[iNext] + 1;

      Inc(iNext);
      Dec(BijiSisa);

      // Jika Biji Dakon habis
      if BijiSisa = 0 then
      begin
        iEnd := iNext - 1;
        // Jika dakon berhenti di tempat yg tidak kosong
        if jmlBijiDakon[iEnd] > 1 then
          if (iEnd <> lumb1) and (iEnd <> lumb2) then
          begin
            BijiSisa := jmlBijiDakon[iEnd];
            jmlBijiDakon[iEnd] := 0;
          end
      end;
    end;

    iEnd := iNext - 1;
    GantiPemain := True;

    // Jika dakon terakhir masuk lumbungnya sendiri
    if (iEnd = lumb1) or (iEnd = lumb2) then
      GantiPemain := False
    else
      // Persiapan NGEBOM, jika dakon terakhir bijinya = 0
      if jmlBijiDakon[iEnd] = 1 then
      begin
        // Dan jika dakon terakhir "milik sendiri"
        if ((player = Player1) and (iEnd < lumb1)) or
          ((player = Player2) and (iEnd > lumb1)) then
        begin
          // Jumlah biji dakon lawan yg berhadapan
          n := jmlBijiDakon[lumb2 - iEnd];
          // Ngebom dilakukn jika biji dihadapannya > 0
          if n > 0 then
          begin
            jmlBijiDakon[lumb2 - iEnd] := 0;
            if Player = Player1 then
            begin
              m := jmlBijiDakon[lumb1];
              jmlBijiDakon[lumb1] := m + n;
            end
            else
            begin
              m := jmlBijiDakon[lumb2];
              jmlBijiDakon[lumb2] := m + n;
            end;
          end;
        end;
      end;

    Result := not GantiPemain;
  end;

  // Menghitung total sisa biji dakon. Dakon ke x1 sampai x2
  function GetTotalBijiPlayer(BijiRef: TIntegerArray; x1, x2: Integer): Integer;
  var
    i: Integer;
  begin
    Result := 0;
    for i := x1 to x2 do
      Result := Result + BijiRef[i];
  end;

  procedure _DoWalk(const BijiRef: TIntegerArray; const StepStart: string);
  var
    tmp: TIntegerArray;
    i: Integer;
    PutarLagi: Boolean;
    step: string;
  begin
    for i := x1 to x2 do
    begin
      inc(steps[i]);

      tmp := Copy(BijiRef, 0, MaxInt);
      if tmp[i] = 0 then Continue;
      PutarLagi := _PutarBijiDakon(tmp, i);

      step := Format('%s,%d', [StepStart, i]);

      // Jika ingin melihat semua langkah komputer
      // yang mungkin dilakukan komputer, baik menyebabkan ganti pemain atau tidak
      // dst.Add(Format('%.3d=%s',[tmp[idxLumbung],step]) );

      if Steps[i] >= MaxDeep then Continue;
{$IFDEF DEBUG}
      WalkCnt := WalkCnt + 1;
{$ENDIF}

      if PutarLagi and (GetTotalBijiPlayer(jmlBijiTmp, x1, x2) > 0) then
        _DoWalk(tmp, step)
      else
        // langkah yang disimpan hanya yang langkahnya menyebabkan ganti pemain
        dst.Add(Format('%.3d=%s', [tmp[idxLumbung], step]));
    end;
  end;

begin
  if not Assigned(dst) then Exit;
  SetLength(JmlBijiDakonOrg, jmlObject + 1); // index 0 diabaikan
  // banyaknya langkah oleh setiap dakon
  SetLength(Steps, jmlObject + 1); // index 0 diabaikan
  // Ambil JumlahBiji Dakon Sebenarnya
  for i := 1 to jmlObject do
    JmlBijiDakonOrg[i] := GetJmlBiji(i);
  // Menentukan batas No Dakon awal sampai akhir, misal 9-15
  x1 := 1;
  x2 := jmlObject - 1;

  if player = Player1 then
    x2 := (jmlObject div 2) - 1
  else
    x1 := (jmlObject div 2) + 1;

  {$IFDEF DEBUG}
  WalkCnt := 0;
  {$ENDIF}


  // Index Lumbung current Player
  idxLumbung := x2 + 1;
  for i := x1 to x2 do
  begin
    for j := 1 to jmlObject do
      Steps[j] := 0;

    jmlBijiTmp := Copy(JmlBijiDakonOrg, 0, MaxInt);
    if jmlBijiTmp[i] = 0 then Continue;
    PutarLagi := _PutarBijiDakon(jmlBijiTmp, i);

    {$IFDEF DEBUG}
    WalkCnt := WalkCnt + 1;
    {$ENDIF}
    //dst.Add(Format('%.3d=%d',[jmlBijiTmp[idxLumbung],i] ) );
    if PutarLagi and (GetTotalBijiPlayer(jmlBijiTmp, x1, x2) > 0) then
      _DoWalk(jmlBijiTmp, IntToStr(i))
    else
      // langkah yang disimpan hanya yang langkahnya menyebabkan ganti pemain
      dst.Add(Format('%.3d=%d', [jmlBijiTmp[idxLumbung], i]));
  end;

  {$IFDEF DEBUG}
  SB1.Panels[1].Text := Format('Jumlah total iterasi %.3d',[WalkCnt]);
  Delay(1000);
  {$ENDIF}
end;

procedure TFrmMain.EnableOptions(enabled: Boolean = True);
var
  i: Integer;
begin
  EndGame := enabled;
  for i := 0 to PnlTop.ControlCount - 1 do
    PnlTop.Controls[i].Enabled := enabled;

  for i := 0 to Tab2Pemain.ControlCount - 1 do
    Tab2Pemain.Controls[i].Enabled := enabled;

  for i := 0 to TabKomputer.ControlCount - 1 do
    TabKomputer.Controls[i].Enabled := enabled;

  for i := 0 to Panel1.ControlCount - 1 do
    Panel1.Controls[i].Enabled := enabled;

  btnStop.Enabled := not enabled;
//  TrackSpeed.Enabled := True;
//  lblKecepatan.Enabled := True;
//  lblms.Enabled := True;
  btnScore.Enabled := True;
//  cbSuara.Enabled := True;

//  btnPause.Enabled := not enabled;

  if enabled then
  begin
    for i := 1 to jmlObject do
    begin
      ObjGray(DakonKe[i]);
    end;

    SB1.Panels[0].Text := 'Permainan selesai';
    SB1.Panels[1].Text := 'Silahkan klik tombol "Mulai baru" untuk memulai permainan';
  end;
end;

procedure TFrmMain.TrackSpeedChange(Sender: TObject);
begin
  lblms.Caption := Format('%dms', [TrackSpeed.Position]);
  if TrackSpeed.Position < 100 then
    cbSuara.Checked := false;
end;

procedure TFrmMain.ComputerStart(StepsInCsv: string);
var
  csv: TStringList;
  i, idx: Integer;
begin
  csv := TStringList.Create;
  try
    csv.Delimiter := ',';
    csv.DelimitedText := StepsInCsv;

    for i := 0 to csv.Count - 1 do
    begin
      if EndGame then Exit;
      idx := StrToIntDef(csv[i], 0);
      if idx = 0 then Continue;

      ObjHover(Dakonke[idx]);
      Delay(700);
      ObjDown(Dakonke[idx]);
      Delay(100);
      ObjNormal(Dakonke[idx]);
      Delay(100);
      StartPutarDakon(idx);
    end;
  finally
    csv.Free;
  end;
end;

procedure TFrmMain.ComputerTurn;
var
  sl: TStringList;
  s, csv: string;
  Deep, maxIdx, selIdx, midIdx: Integer;
begin
  // berhenti sejenak
  Delay(2000);
  Randomize;
  sl := TStringList.Create;
  try
    // Deep akan menentukan berapa maksimal langkah komputer

    if rbLevel1.Checked then
      Deep := 1 + Random(2) // Deep 1..2
    else if rbLevel2.Checked then
      Deep := 3 + Random(2) // Deep 3..4
    else if rbLevel3.Checked then
      Deep := 6 + Random(3) // Deep 6..8
    else
      Deep := 9 + Random(4); // Deep 9..12

    GetBestPath(sl, Player2, Deep);
    sl.Sort;
{$IFDEF DEBUG}
    sl.SaveToFile(Format('step-%d.txt',[Deep]));
{$ENDIF}

    // ambil index berdasar level
    maxIdx := sl.Count - 1;
    midIdx := maxIdx div 2;
    selIdx := maxIdx;

    if rbLevel1.Checked then
      selIdx := Random(midIdx)
    else if rbLevel2.Checked then
      selIdx := midIdx + Random(maxIdx - midIdx)
    else if rbLevel3.Checked then
      selIdx := midIdx + (midIdx div 2) + Random(maxIdx - (midIdx div 2));
    // else selIdx = maxIdx;

    if selIdx > maxIdx then selIdx := maxIdx;

    s := sl[selIdx];
    csv := Copy(s, Pos('=', s) + 1, MaxInt);
{$IFDEF DEBUG}
    SB1.Panels[1].Text := s;
{$ENDIF}
    ComputerStart(csv);
  finally
    sl.Free;
  end;

end;

procedure TFrmMain.btnScoreClick(Sender: TObject);
begin
  FrmScore.ShowModal;
end;

procedure TFrmMain.SaveWinner(const nama, dakon: string; nilai: Integer);
var
  i: integer;
  mIn, mOut: TMemoryStream;
begin
  with FrmScore.NxScore do
  begin
    i := AddRow;
    Cells[0, i] := nama;
    Cells[1, i] := dakon;
    Cell[2, i].AsInteger := nilai;
    SortColumn(FrmScore.NxScore.Columns[2], false);
    FrmScore.RefreshComboDakon;

    mIn := TMemoryStream.Create;
    mOut := TMemoryStream.Create;
    try
      SaveToStream(mIn, #9);
      mOut.SetSize(mIn.Size);
      MemoryEncrypt(mIn.Memory, mIn.Size, mOut.Memory, mOut.Size, Kunci);
      mOut.SaveToFile(HighScoreFilename);
    finally
      mIn.Free;
      mOut.Free;
    end;
  end;
end;

procedure TFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  lblPlayer1.Free;
  lblPlayer2.Free;
  ttfcArial.Free;
  //bgDakon.Free;
end;

procedure TFrmMain.PlayTheSound(Sound: TSound);
var
  dir, sndFile: string;
begin
  if not cbSuara.Checked then Exit;
  //   sWin, sZap, sStep, sBeep, sStop
  case Sound of
    sWin: sndFile := 'win.wav';
    sZap: sndFile := 'zap.wav';
    sStep: sndFile := 'step.wav';
    sStop: sndFile := 'finish.wav';
    sGet: sndFile := 'get.wav';
  end;

  dir := ExtractFilePath(Application.ExeName) + 'sounds/';
  if FileExists(dir + sndFile) then
    PlaySound(PChar(dir + sndFile), 0, SND_FILENAME or SND_ASYNC);

end;

procedure TFrmMain.SetInfoPlayer(const BijiSisa: Integer);
{$IFNDEF DEBUG}
var
  nama: string;
{$ENDIF}
begin
{$IFNDEF DEBUG}
  if Tab2Pemain.Showing then
    if curPlayer = Player1 then
      nama := ePlayer1.Text
    else
      nama := ePlayer2.Text
  else
    if curPlayer = player1 then
      nama := ePlayerKomputer.Text
    else
      nama := 'Komputer';

  SB1.Panels[0].Text := 'Pemain aktif: ' + nama;
//  if PauseGame then
//    SB1.Panels[1].Text := 'Pemain menghentikan sementara permainan. Klik tombol "Jalankan lagi" untuk melanjutkan'
//  else
  if BijiSisa > -1 then
    SB1.Panels[1].Text := 'Sisa biji: ' + InttoStr(BijiSisa)
  else
    SB1.Panels[1].Text := 'Menunggu "' + nama + '" memilih dakon yang akan diputar';
  {$ENDIF}
end;

procedure TFrmMain.DrawBackground;
var
  bg : TDrawObjRectangle;
  r : TRect;
begin
  bg := TDrawObjRectangle.Create(img32.Layers);
  bg.Rounded := True;
  bg.FillColor := clLightGray32;
  bg.StrokeColor := clRed32;
  bg.StrokeWidth := 0;
  // Lebar panjang dakon
  r := GetDakonRect;
  InflateRect(r,10,15);
  bg.Position(FloatRect(r),0);
  bg.RePaint;
end;

function TFrmMain.GetPanjangDakon: Integer;
begin
  Result := 2 * (DM + 2 * SP) + // diameter lumbung = DM+2*SP
    (jmlObject div 2 - 1) * (DM + SP) - SP;// +
    //(2 * jmlObject div 2); // border * jumlah dakon
end;

function TFrmMain.GetDakonRect: TRect;
begin
  Result.Left := MARGIN_LEFT;
  Result.Right := Result.Left + GetPanjangDakon;
  Result.Top := DM;
  Result.Bottom := DM*4;
end;

//procedure TFrmMain.btnPauseClick(Sender: TObject);
//begin
//  if not isPlaying then Exit;
//  PauseGame := not PauseGame;
//  if PauseGame then
//  begin
//    btnPause.Caption := 'Jalan lagi';
//  end
//  else
//  begin
//    btnPause.Caption := 'Pause';
//    PutarBijiDakon(IdxPause, BijiPause);
//  end;
//end;

end.

