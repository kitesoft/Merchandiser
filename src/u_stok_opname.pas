unit u_stok_opname;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, sSpeedButton, sCurrencyEdit, ExtCtrls, cxCustomData,
  cxGraphics, cxDataStorage, cxEdit, cxGridLevel, cxClasses, cxControls,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGrid,
  cxCurrencyEdit, UFungsi, ComCtrls, sSkinProvider, cxImageComboBox, cxStyles,
  sDialogs, DB, cxDBData, cxGridDBTableView, StdCtrls, Mask, MemDS, DBAccess,
  MyAccess, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, dxSkinscxPCPainter, cxNavigator, Vcl.Samples.Spin,
  cxFilter, cxData, sMaskEdit, sCustomComboEdit, sCurrEdit;

type
  Tf_stok_opname = class(TForm)
    panel4: TPanel;
    sPanel1: TPanel;
    panel1: TPanel;
    Mm_nama: TMemo;
    ce_harga: TsCurrencyEdit;
    panel2: TPanel;
    sBevel1: TBevel;
    sLabel1: TLabel;
    ed_kodeSO: TEdit;
    ed_code: TEdit;
    sSpeedButton18: TsSpeedButton;
    sSkinProvider1: TsSkinProvider;
    sLabel5: TLabel;
    BtnAuto: TButton;
    spnl1: TPanel;
    BtnCetak: TButton;
    Sb_cari: TsSpeedButton;
    grid: TcxGrid;
    t_koreksi: TcxGridDBTableView;
    t_koreksiRak: TcxGridDBColumn;
    t_koreksiShelving: TcxGridDBColumn;
    t_koreksiColumn1: TcxGridDBColumn;
    t_koreksikd_barang: TcxGridDBColumn;
    t_koreksibarcode: TcxGridDBColumn;
    t_koreksin_barang: TcxGridDBColumn;
    t_koreksiqty_real: TcxGridDBColumn;
    t_koreksiColumn2: TcxGridDBColumn;
    l_koreksi: TcxGridLevel;
    rg_pilihan: TRadioGroup;
    BtnTambah: TButton;
    pnl1: TPanel;
    BtnBaru: TButton;
    BtnBatal: TButton;
    BtnKoreksi: TButton;
    BtnSimpan: TButton;
    QListData: TMyQuery;
    dsDsListData: TDataSource;
    se_rak: TSpinEdit;
    procedure ed_codeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnBaruClick(Sender: TObject);
    procedure Sb_cariClick(Sender: TObject);
    procedure BtnSimpanClick(Sender: TObject);
    procedure BtnCetakClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ed_kodeSOChange(Sender: TObject);
    procedure sSpeedButton18Click(Sender: TObject);
    procedure BtnAutoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure WMMDIACTIVATE(var msg: TWMMDIACTIVATE); message WM_MDIACTIVATE;
    procedure ed_codeKeyPress(Sender: TObject; var Key: Char);
    procedure ed_kodeSOKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BtnTambahClick(Sender: TObject);
    procedure segarkan;
    procedure BtnBatalClick(Sender: TObject);
    procedure BtnKoreksiClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  f_stok_opname: Tf_stok_opname;

implementation

uses
  u_dm, u_cari, u_utama;

{$R *.dfm}

procedure Tf_stok_opname.WMMDIACTIVATE(var msg: TWMMDIACTIVATE);
var
  active: TWinControl;
  idx: Integer;
begin
  active := FindControl(msg.ActiveWnd);
  if not(dm.metu_kabeh) then
  begin
    if Assigned(active) then
    begin
      idx := f_utama.tc_child.Tabs.IndexOfObject(TObject(msg.ActiveWnd));
      f_utama.tc_child.Tag := -1;
      f_utama.tc_child.TabIndex := idx;
      f_utama.tc_child.Tag := 0;
    end;
  end;
end;

procedure Tf_stok_opname.ed_codeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  kd_brg: string;
begin
  if Key = vk_return then
  begin
    if ed_kodeSO.Text = '' then
    begin
      ShowMessage('Masukkan Kode SO terlebih Dahulu');
      ed_kodeSO.SetFocus;
      Exit;
    end;

    PeekMessage(Mgs, 0, WM_CHAR, WM_CHAR, PM_REMOVE);
    if ed_code.Text = '' then
      Exit;

    fungsi.sqlExec(dm.Q_temp,
      'SELECT kd_barang from tb_barang where ((kd_barang = "' + ed_code.Text +
      '" OR barcode3 = "' + ed_code.Text + '" OR barcode2 = "' + ed_code.Text +
      '" OR barcode1 = "' + ed_code.Text + '") AND kd_perusahaan="' +
      dm.kd_perusahaan + '")', true);

    kd_brg := dm.Q_temp.fieldbyname('kd_barang').AsString;

    if dm.Q_temp.RecordCount = 0 then
    begin
      ShowMessage('data tidak dapat ditemukan dalam daftar barang...');
      ed_code.Clear;
      Exit;
    end;

    dm.db_conn.StartTransaction;
    try
      fungsi.sqlExec(dm.Q_Exe,
        'INSERT IGNORE INTO tb_koreksi_temp(kd_perusahaan,kd_koreksi, ' +
        'Rak,Shelving,urut,kd_barang,barcode,n_barang,qty_oh,harga_pokok) ' +
        'SELECT kd_perusahaan,' + quotedstr(ed_kodeSO.Text) +
        ',no_rak,no_shelving,no_urut, ' +
        'kd_barang,barcode3,n_barang,stok_OH,hpp_aktif FROM vw_so WHERE ' +
        '(kd_perusahaan="' + dm.kd_perusahaan + '" AND kd_barang = "' + kd_brg +
        '")', false);

      dm.db_conn.Commit;
      segarkan;
      ed_code.Clear;
    except
      on e: exception do
      begin
        dm.db_conn.Rollback;
        ShowMessage('proses tambah data gagal '#10#13'' + e.Message);
      end;
    end;
  end;

  if Key = vk_f2 then
    Sb_cariClick(Sender);

  if Key = vk_up then
  begin
    if t_koreksi.DataController.FocusedRowIndex >= 1 then
      t_koreksi.DataController.FocusedRowIndex :=
        t_koreksi.DataController.FocusedRowIndex - 1;
    Key := VK_NONAME;
  end;

  if Key = vk_down then
  begin
    PeekMessage(Mgs, 0, WM_CHAR, WM_CHAR, PM_REMOVE);
    t_koreksi.DataController.FocusedRowIndex :=
      t_koreksi.DataController.FocusedRowIndex + 1;
  end;

  if Key = vk_delete then
    if (MessageDlg('Yakinkah, Anda akan menghapus data ini???', mtConfirmation,
      [mbYes, mbNo], 0) = mrYes) then
      QListData.Delete;
end;

procedure Tf_stok_opname.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = vk_f2 then
    ed_code.SetFocus;
  if Key = vk_f5 then
    BtnAutoClick(Sender);
end;

procedure Tf_stok_opname.BtnBaruClick(Sender: TObject);
begin
  BtnAutoClick(Sender);
end;

procedure Tf_stok_opname.Sb_cariClick(Sender: TObject);
begin
  ed_code.SetFocus;
  application.CreateForm(tf_cari, f_cari);
  with f_cari do
    try
      _SQLi := 'select kd_barang, n_barang from tb_barang ' +
        'where kd_perusahaan="' + dm.kd_perusahaan + '"';
      tblcap[0] := 'Kode';
      tblcap[1] := 'Deskripsi';
      if ShowModal = mrOk then
      begin
        ed_code.Text := TblVal[0];
      end;
    finally
      close;
    end;
end;

procedure Tf_stok_opname.BtnSimpanClick(Sender: TObject);
begin
  if BtnKoreksi.Enabled = true then
  begin
    ShowMessage
      ('Tidak Dapat menyimpan, Data SO belum dikoreksi, Koreksi Terlebih Dahulu!!!');
    Exit;
  end;

  if MessageDlg('Yakinkah Anda akan Menyimpan Data ini???...', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes then
  begin
    dm.db_conn.StartTransaction;
    try
      fungsi.sqlExec(dm.Q_Exe, 'call sp_simpan_SO("' + dm.kd_perusahaan + '","'
        + ed_kodeSO.Text + '","' + dm.kd_pengguna + '")', false);

      ShowMessage('proses Simpan Stok Opname untuk '#10#13'' + ed_kodeSO.Text +
        ' Telah Sukses...');

      dm.db_conn.Commit;
      BtnAutoClick(Self);
    except
      on e: exception do
      begin
        dm.db_conn.Rollback;
        MessageDlg('proses Simpan Stok Opname gagal,ulangi lagi!!! '#10#13'' +
          e.Message, mterror, [mbOk], 0);
      end;
    end;
  end;
end;

procedure Tf_stok_opname.BtnCetakClick(Sender: TObject);
begin
  fungsi.sqlExec(dm.Q_laporan, 'select * from vw_so_temp where kd_koreksi="' +
    ed_kodeSO.Text + '" AND kd_perusahaan = "' + dm.kd_perusahaan + '"', true);

  dm.laporan.LoadFromFile(dm.Path + 'laporan\p_persiapan_SO.fr3');
  dm.laporan.ShowReport;
end;

procedure Tf_stok_opname.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := cafree;
  f_stok_opname := nil;
  f_utama.MDIChildDestroyed(Self.Handle);
end;

procedure Tf_stok_opname.ed_kodeSOChange(Sender: TObject);
begin
  segarkan;
end;

procedure Tf_stok_opname.sSpeedButton18Click(Sender: TObject);
begin
  close;
end;

procedure Tf_stok_opname.BtnAutoClick(Sender: TObject);
var
  a: Integer;
begin
  fungsi.sqlExec(dm.Q_temp,
    'select IFNULL(MAX(RIGHT(kd_koreksi,4)),0) + 1 AS ahir from tb_koreksi_temp '
    + 'where kd_perusahaan= "' + dm.kd_perusahaan + '"', true);

  a := dm.Q_temp.fieldbyname('ahir').AsInteger;

  if a < 10 then
    ed_kodeSO.Text := 'SP000' + inttostr(a)
  else if a < 100 then
    ed_kodeSO.Text := 'SO00' + inttostr(a)
  else if a < 1000 then
    ed_kodeSO.Text := 'SO0' + inttostr(a)
  else if a < 10000 then
    ed_kodeSO.Text := 'SO' + inttostr(a);

  segarkan;
end;

procedure Tf_stok_opname.FormCreate(Sender: TObject);
begin
  f_utama.MDIChildCreated(Self.Handle);
end;

procedure Tf_stok_opname.ed_codeKeyPress(Sender: TObject; var Key: Char);
var
  kode: string;
  tempat: Integer;
begin
  kode := inttostr(StrToIntDef(ed_code.Text, 0));

  if Key = #43 then // tanda + ubah qty real
  begin
    tempat := t_koreksi.DataController.FocusedRowIndex;

    Delete(kode, pos('+', kode), 1);
    ed_code.Clear;
    Key := #0;

    if QListData.RecordCount = 0 then
      Exit;

    if (Length(kode) = 0) then
      Exit;

    if kode <> QListData.fieldbyname('qty_real').AsString then
    begin
      QListData.Edit;
      QListData.fieldbyname('qty_real').AsString := kode;
      QListData.Post;

      t_koreksi.DataController.FocusedRowIndex := tempat;
      BtnKoreksi.Enabled := true;
    end;

    t_koreksi.DataController.FocusedRowIndex :=
      t_koreksi.DataController.FocusedRowIndex + 1;
  end;
end;

procedure Tf_stok_opname.ed_kodeSOKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = vk_return) then
  begin
    PeekMessage(Mgs, 0, WM_CHAR, WM_CHAR, PM_REMOVE);
    BtnAutoClick(Self);
  end;
end;

procedure Tf_stok_opname.BtnTambahClick(Sender: TObject);
var
  semua: string;
begin
  if ed_kodeSO.Text = '' then
  begin
    ShowMessage('Masukkan Kode SO terlebih Dahulu');
    ed_kodeSO.SetFocus;
    Exit;
  end;

  if rg_pilihan.ItemIndex = 0 then
    semua := 'Y'
  else
    semua := 'N';

  dm.db_conn.StartTransaction;
  try
    fungsi.sqlExec(dm.Q_Exe, 'call sp_persiapan_SO("' + dm.kd_perusahaan + '","'
      + ed_kodeSO.Text + '","' + semua + '",' + se_rak.Text + ')', false);

    dm.db_conn.Commit;
    segarkan;
    ShowMessage('Proses Tambah data Berhasil...');
  except
    on e: exception do
    begin
      dm.db_conn.Rollback;
      ShowMessage('penyimpanan data gagal '#10#13'' + e.Message);
    end;
  end;
end;

procedure Tf_stok_opname.segarkan;
begin
  fungsi.sqlExec(QListData, 'select * from tb_koreksi_temp where kd_koreksi="' +
    ed_kodeSO.Text + '" and kd_perusahaan ="' + dm.kd_perusahaan +
    '" ORDER BY Rak, Shelving, urut, kd_barang', true);
  Self.Caption := 'Stock Opname ' + ed_kodeSO.Text;
  f_utama.tc_child.Tabs.Strings[f_utama.tc_child.TabIndex] := Caption;
  BtnKoreksi.Enabled := true;
end;

procedure Tf_stok_opname.BtnBatalClick(Sender: TObject);
begin
  if MessageDlg('Yakinkah Anda Akan membatalkan '#10#13'' + ed_kodeSO.Text,
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    dm.db_conn.StartTransaction;
    try
      fungsi.sqlExec(dm.Q_Exe, 'delete from tb_koreksi_temp where kd_koreksi="'
        + ed_kodeSO.Text + '" AND kd_perusahaan = "' + dm.kd_perusahaan +
        '"', false);

      ShowMessage('proses Pembatalan stok Opname untuk '#10#13'' +
        ed_kodeSO.Text + ' Telah Sukses...');

      BtnAutoClick(Self);

      dm.db_conn.Commit;
    except
      on e: exception do
      begin
        dm.db_conn.Rollback;
        ShowMessage('pembatalan SO gagal '#10#13'' + e.Message);
      end;
    end;
  end;
end;

procedure Tf_stok_opname.BtnKoreksiClick(Sender: TObject);
var
  lama, baru: Integer;
begin
  dm.db_conn.StartTransaction;
  try
    lama := QListData.RecordCount;

    fungsi.sqlExec(dm.Q_Exe, 'call sp_koreksi_data("' + ed_kodeSO.Text + '","' +
      dm.kd_perusahaan + '")', false);
    dm.db_conn.Commit;

    segarkan;
    BtnKoreksi.Enabled := false;

    baru := QListData.RecordCount;

    ShowMessage(inttostr(lama - baru) + ' Item Dari ' + inttostr(lama) +
      ' Item '#10#13'Telah Terkoreksi...');

  except
    on e: exception do
    begin
      dm.db_conn.Rollback;
      ShowMessage('koreksi data gagal '#10#13'' + e.Message);
    end;
  end;
end;

end.
