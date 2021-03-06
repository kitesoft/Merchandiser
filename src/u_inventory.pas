unit u_inventory;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, DB, DBGrids, Buttons, sSkinProvider, ExtCtrls, UFungsi,
  DBCtrls, frxClass, frxDBSet, StdCtrls, Grids;

type
  NewControl = class(TControl);

  TF_Inventory = class(TForm)
    pc_inventory: TPageControl;
    ts_jelajah: TTabSheet;
    db_barang: TDBGrid;
    ts_detail: TTabSheet;
    sSkinProvider1: TsSkinProvider;
    sPanel1: TPanel;
    gb_kondisi: TGroupBox;
    rb_like: TRadioButton;
    rb_sama: TRadioButton;
    rb_lebih: TRadioButton;
    rb_kurang: TRadioButton;
    rb_tdk_sama: TRadioButton;
    gb_saring: TGroupBox;
    rb_plu: TRadioButton;
    rb_min_order: TRadioButton;
    rb_max_stok: TRadioButton;
    rb_min_stok: TRadioButton;
    rb_lebih_sama: TRadioButton;
    rb_kurang_sama: TRadioButton;
    ts_mutasi: TTabSheet;
    sLabel1: TLabel;
    sLabel2: TLabel;
    sLabel3: TLabel;
    Ed_golongan: TEdit;
    sLabel4: TLabel;
    Ed_Merk: TEdit;
    Ed_Kategori: TEdit;
    Ed_Jenis: TEdit;
    l_aktif: TLabel;
    sGroupBox1: TGroupBox;
    sLabel11: TLabel;
    sLabel12: TLabel;
    sLabel13: TLabel;
    sLabel14: TLabel;
    sGroupBox2: TGroupBox;
    sLabel6: TLabel;
    sLabel9: TLabel;
    sLabel8: TLabel;
    sLabel7: TLabel;
    sLabel15: TLabel;
    sLabel16: TLabel;
    sGroupBox3: TGroupBox;
    sGroupBox4: TGroupBox;
    ed_sat1: TEdit;
    ed_sat2: TEdit;
    ed_sat3: TEdit;
    sGroupBox5: TGroupBox;
    sLabel17: TLabel;
    sLabel18: TLabel;
    sLabel19: TLabel;
    Ed_urut: TEdit;
    Ed_shelving: TEdit;
    Ed_rak: TEdit;
    ed_LD: TEdit;
    sLabel20: TLabel;
    ed_AB: TEdit;
    sLabel21: TLabel;
    ed_KK: TEdit;
    sLabel22: TLabel;
    sLabel23: TLabel;
    ed_DB: TEdit;
    Ed_min_display: TEdit;
    sLabel24: TLabel;
    sGroupBox6: TGroupBox;
    Ed_Cari: TEdit;
    L_hasil: TLabel;
    ed_temp: TEdit;
    ud_cari: TUpDown;
    B_Cari: TButton;
    rb_minO: TRadioButton;
    rb_minS: TRadioButton;
    rb_maxS: TRadioButton;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    sLabel10: TLabel;
    sLabel25: TLabel;
    ed_pid: TEdit;
    ed_nama: TEdit;
    ed_pid2: TEdit;
    ed_nama2: TEdit;
    ds_mutasi: TDataSource;
    ds_barang: TDataSource;
    ed_trans_ah: TEdit;
    ed_kirim_ah: TEdit;
    ed_kosong_ah: TEdit;
    ed_qty1: TEdit;
    ed_qty2: TEdit;
    ed_bar1: TEdit;
    ed_bar2: TEdit;
    ed_bar3: TEdit;
    ed_minstok: TEdit;
    ed_maxstok: TEdit;
    ed_minor: TEdit;
    ed_time: TEdit;
    db_mutasi: TfrxDBDataset;
    laporan: TfrxReport;
    B_Print: TButton;
    db_laporan: TfrxDBDataset;
    sButton1: TButton;
    procedure ubah_detail;
    procedure FormShow(Sender: TObject);
    procedure Ed_CariChange(Sender: TObject);
    procedure rb_pluClick(Sender: TObject);
    procedure B_CariClick(Sender: TObject);
    procedure db_barangTitleClick(Column: TColumn);
    procedure FormCreate(Sender: TObject);
    procedure rb_minSClick(Sender: TObject);
    procedure ts_detailClickBtn(Sender: TObject);
    procedure ts_mutasiClickBtn(Sender: TObject);
    procedure pc_inventoryChange(Sender: TObject);
    procedure B_PrintClick(Sender: TObject);
    procedure sButton1Click(Sender: TObject);
  private
    procedure DBGridScroll(var Message: TMessage);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  F_Inventory: TF_Inventory;

implementation

uses
  u_dm, u_utama;

{$R *.dfm}

procedure TF_Inventory.DBGridScroll(var Message: TMessage);
var
  count: short;
begin
  if (Message.Msg = WM_MOUSEWHEEL) then
  begin
    count := HIWORD(Message.WParam);
    count := count div 120;
    db_barang.DataSource.DataSet.MoveBy(-count);
  end
  else
    NewControl(db_barang).WndProc(Message);
end;

procedure TF_Inventory.ubah_detail;
begin
  ed_pid.Text := dm.Q_show.FieldByName('kd_barang').AsString;
  ed_nama.Text := dm.Q_show.FieldByName('n_barang').AsString;
  ed_pid2.Text := ed_pid.Text;
  ed_nama2.Text := ed_nama.Text;
  ed_qty1.Text := dm.Q_show.FieldByName('qty1').AsString;
  ed_qty2.Text := dm.Q_show.FieldByName('qty2').AsString;
  ed_bar1.Text := dm.Q_show.FieldByName('barcode1').AsString;
  ed_bar2.Text := dm.Q_show.FieldByName('barcode2').AsString;
  ed_bar3.Text := dm.Q_show.FieldByName('barcode3').AsString;
  ed_minstok.Text := dm.Q_show.FieldByName('minstok').AsString;
  ed_maxstok.Text := dm.Q_show.FieldByName('maxstok').AsString;
  ed_minor.Text := dm.Q_show.FieldByName('minor').AsString;
  ed_time.Text := dm.Q_show.FieldByName('leadtime').AsString;
  if dm.Q_show.FieldByName('aktif').AsString = 'Y' then
    l_aktif.Caption := 'AKTIF'
  else
    l_aktif.Caption := 'TIDAK AKTIF';

  fungsi.SQLExec(dm.Q_temp,
    'SELECT tb_golongan.N_golbrg AS N_golbrg, tb_merk.N_merk AS N_merk, ' +
    'tb_jenis.N_Jenis AS N_Jenis, tb_kategori.n_kategori AS n_kategori, tb_jenis.Kd_Jenis, '
    + 'tb_barang.kd_barang FROM ((((((tb_barang)) LEFT JOIN tb_jenis ON ((tb_jenis.Kd_Jenis = tb_barang.kd_jenis))) '
    + 'LEFT JOIN tb_kategori ON ((tb_kategori.tag = tb_barang.kd_kategori))) LEFT JOIN tb_merk ON ((tb_merk.kd_merk = tb_barang.kd_merk))) '
    + 'LEFT JOIN tb_golongan ON (((tb_golongan.kd_golbrg = tb_barang.kd_golbrg) AND (tb_golongan.kd_jenis = tb_jenis.Kd_Jenis)))) '
    + 'where kd_barang="' + ed_pid.Text + '"', true);

  Ed_Jenis.Text := dm.Q_temp.FieldByName('n_jenis').AsString;
  Ed_golongan.Text := dm.Q_temp.FieldByName('n_golbrg').AsString;
  Ed_Merk.Text := dm.Q_temp.FieldByName('n_merk').AsString;
  Ed_Kategori.Text := dm.Q_temp.FieldByName('n_kategori').AsString;

  fungsi.SQLExec(dm.Q_temp, 'select * from tb_satuan where kd_satuan="' +
    dm.Q_show.FieldByName('kd_sat1').AsString + '"', true);
  ed_sat1.Text := dm.Q_temp.FieldByName('n_satuan').AsString;
  fungsi.SQLExec(dm.Q_temp, 'select * from tb_satuan where kd_satuan="' +
    dm.Q_show.FieldByName('kd_sat2').AsString + '"', true);
  ed_sat2.Text := dm.Q_temp.FieldByName('n_satuan').AsString;
  fungsi.SQLExec(dm.Q_temp, 'select * from tb_satuan where kd_satuan="' +
    dm.Q_show.FieldByName('kd_sat3').AsString + '"', true);
  ed_sat3.Text := dm.Q_temp.FieldByName('n_satuan').AsString;

  fungsi.SQLExec(dm.Q_temp,
    'select max(beli.tgl) as tgl_beli_ahir, max(jual.tgl) ' +
    'as tgl_jual_ahir, max(kosong.tgl) as tgl_kosong_ahir from tb_mutasi beli, tb_mutasi jual, tb_mutasi kosong '
    + 'where beli.kd_barang = "' + ed_pid.Text + '" and beli.stok_receipt > 0 '
    + 'and jual.kd_barang = "' + ed_pid.Text + '" and jual.stok_sales > 0   ' +
    'and kosong.kd_barang = "' + ed_pid.Text +
    '" and kosong.stok_ahir <= 0 ', true);

  ed_trans_ah.Text := dm.Q_temp.FieldByName('tgl_jual_ahir').AsString;
  ed_kirim_ah.Text := dm.Q_temp.FieldByName('tgl_beli_ahir').AsString;
  ed_kosong_ah.Text := dm.Q_temp.FieldByName('tgl_kosong_ahir').AsString;

  fungsi.SQLExec(dm.Q_temp, 'select * from tb_planogram where kd_barang="' +
    dm.Q_show.FieldByName('kd_barang').AsString + '"', true);
  Ed_rak.Text := dm.Q_temp.FieldByName('no_rak').AsString;
  Ed_shelving.Text := dm.Q_temp.FieldByName('no_shelving').AsString;
  Ed_urut.Text := dm.Q_temp.FieldByName('no_urut').AsString;
  Ed_min_display.Text := dm.Q_temp.FieldByName('min_display').AsString;
  ed_LD.Text := dm.Q_temp.FieldByName('kapasitas').AsString;
  ed_KK.Text := dm.Q_temp.FieldByName('kk').AsString;
  ed_AB.Text := dm.Q_temp.FieldByName('ab').AsString;
  ed_DB.Text := dm.Q_temp.FieldByName('db').AsString;

end;

procedure TF_Inventory.FormShow(Sender: TObject);
begin
  pc_inventory.ActivePage := ts_jelajah;
  fungsi.SQLExec(dm.Q_show, 'select * from tb_barang where kd_perusahaan=' +
    quotedstr(dm.kd_perusahaan) + '', true);
  L_hasil.Caption := 'Ada ' + inttostr(dm.Q_show.RecordCount) + ' Item';
end;

procedure TF_Inventory.Ed_CariChange(Sender: TObject);
begin
  if rb_plu.Checked and rb_like.Checked then
  begin
    fungsi.SQLExec(dm.Q_show, 'select * from tb_barang where kd_barang like "%'
      + Ed_Cari.Text + '%" or n_barang like "%' + Ed_Cari.Text +
      '%" order by kd_barang and kd_perusahaan=' + quotedstr(dm.kd_perusahaan) +
      '', true);

    L_hasil.Caption := 'Ada ' + inttostr(dm.Q_show.RecordCount) + ' Item';
  end;
end;

procedure TF_Inventory.rb_pluClick(Sender: TObject);
begin
  B_Cari.Visible := not(rb_plu.Checked);
  rb_like.Enabled := rb_plu.Checked;
  rb_sama.Enabled := not(rb_plu.Checked);
  rb_tdk_sama.Enabled := not(rb_plu.Checked);
  rb_lebih.Enabled := not(rb_plu.Checked);
  rb_kurang.Enabled := not(rb_plu.Checked);
  rb_lebih_sama.Enabled := not(rb_plu.Checked);
  rb_kurang_sama.Enabled := not(rb_plu.Checked);
  Ed_Cari.Text := '';

  rb_minS.Visible := not(rb_plu.Checked);
  rb_minO.Visible := not(rb_plu.Checked);
  rb_maxS.Visible := not(rb_plu.Checked);

  if not(rb_plu.Checked) then
  begin

    fungsi.SQLExec(dm.Q_show,
      'select * from tb_barang order by kd_barang', true);

    L_hasil.Caption := 'Ada ' + inttostr(dm.Q_show.RecordCount) + ' Item';

    Ed_Cari.Left := 208;
    Ed_Cari.Width := 40;
    ud_cari.Associate := Ed_Cari;
    ud_cari.Visible := true;
    ud_cari.Width := 40;
    rb_sama.Checked := true;
  end
  else
  begin
    Ed_Cari.Left := 8;
    Ed_Cari.Width := 281;
    rb_like.Checked := true;
    ud_cari.Visible := false;
    ud_cari.Associate := ed_temp;
    Ed_Cari.SetFocus;
  end;

end;

procedure TF_Inventory.B_CariClick(Sender: TObject);
var
  kategori, kondisi: string;
begin
  if rb_min_order.Checked = true then
    kategori := 'minor';
  if rb_min_stok.Checked = true then
    kategori := 'minstok';
  if rb_max_stok.Checked = true then
    kategori := 'maxstok';

  if rb_sama.Checked = true then
    kondisi := '=';
  if rb_tdk_sama.Checked = true then
    kondisi := '<>';
  if rb_lebih.Checked = true then
    kondisi := '>';
  if rb_kurang.Checked = true then
    kondisi := '<';
  if rb_lebih_sama.Checked = true then
    kondisi := '>=';
  if rb_kurang_sama.Checked = true then
    kondisi := '<=';

  fungsi.SQLExec(dm.Q_show, 'select * from tb_barang where kd_perusahaan="' +
    dm.kd_perusahaan + '" and ' + kategori + ' ' + kondisi + ' ' + Ed_Cari.Text
    + ' order by kd_barang', true);

  L_hasil.Caption := 'Ada ' + inttostr(dm.Q_show.RecordCount) + ' Item';
end;

procedure TF_Inventory.db_barangTitleClick(Column: TColumn);
begin
  // dm.Q_show.SortFieldNames:=column.FieldName;
end;

procedure TF_Inventory.FormCreate(Sender: TObject);
begin
  db_barang.WindowProc := DBGridScroll;
end;

procedure TF_Inventory.rb_minSClick(Sender: TObject);
var
  kategori, kondisi, gol: string;
begin
  if rb_min_order.Checked = true then
    kategori := 'minor';
  if rb_min_stok.Checked = true then
    kategori := 'minstok';
  if rb_max_stok.Checked = true then
    kategori := 'maxstok';

  if rb_sama.Checked = true then
    kondisi := '=';
  if rb_tdk_sama.Checked = true then
    kondisi := '<>';
  if rb_lebih.Checked = true then
    kondisi := '>';
  if rb_kurang.Checked = true then
    kondisi := '<';
  if rb_lebih_sama.Checked = true then
    kondisi := '>=';
  if rb_kurang_sama.Checked = true then
    kondisi := '<=';

  if rb_minS.Checked = true then
    gol := 'minstok';
  if rb_maxS.Checked = true then
    gol := 'maxstok';
  if rb_minO.Checked = true then
    gol := 'minor';

  fungsi.SQLExec(dm.Q_show, 'select * from tb_barang where ' + kategori + ' ' +
    kondisi + ' ' + gol + ' order by kd_barang', true);

  L_hasil.Caption := 'Ada ' + inttostr(dm.Q_show.RecordCount) + ' Item';
end;

procedure TF_Inventory.ts_detailClickBtn(Sender: TObject);
begin
  ubah_detail;
end;

procedure TF_Inventory.ts_mutasiClickBtn(Sender: TObject);
begin
  ed_pid.Text := dm.Q_show.FieldByName('kd_barang').AsString;
  fungsi.SQLExec(dm.Q_temp, 'select * from tb_mutasi WHERE kd_perusahaan="' +
    dm.kd_perusahaan + '" and MONTH(tb_mutasi.tgl)=MONTH(NOW()) and kd_barang="'
    + ed_pid.Text + '"', true);
  dm.Q_temp.RecNo := dm.Q_temp.RecordCount;
end;

procedure TF_Inventory.pc_inventoryChange(Sender: TObject);
begin
  ed_pid.Text := dm.Q_show.FieldByName('kd_barang').AsString;
  if pc_inventory.ActivePage = ts_detail then
  begin
    ubah_detail;
  end
  else if pc_inventory.ActivePage = ts_mutasi then
  begin
    fungsi.SQLExec(dm.Q_temp, 'select * from tb_mutasi WHERE left(tgl,7)="' +
      F_Utama.cb_periode.Text + '" and kd_barang="' + ed_pid.Text +
      '" and kd_perusahaan="' + dm.kd_perusahaan + '"', true);
    dm.Q_temp.RecNo := dm.Q_temp.RecordCount;
  end;

end;

procedure TF_Inventory.B_PrintClick(Sender: TObject);
begin
  laporan.LoadFromFile(dm.Path + 'laporan\gp_mutasi_brg.fr3');
  laporan.ShowReport;
end;

procedure TF_Inventory.sButton1Click(Sender: TObject);
begin
  laporan.LoadFromFile(dm.Path + 'laporan\p_daftar_barang.fr3');
  laporan.ShowReport;
end;

end.
