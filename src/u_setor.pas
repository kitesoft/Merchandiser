unit u_setor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFungsi, DB, sCustomComboEdit, sCurrEdit, sCurrencyEdit, Buttons,
  frxClass, frxDBSet, cxStyles, cxGraphics, cxDataStorage, cxEdit, cxDBData,
  cxGridLevel, cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, ComCtrls, cxCurrencyEdit,
  sTooledit, ExtCtrls, Menus, StdCtrls, Mask, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxNavigator, cxCustomData, cxFilter, cxData, sMaskEdit;

type
  TF_Setor = class(TForm)
    ds_kasir: TDataSource;
    laporan: TfrxReport;
    setor_kasir: TfrxDBDataset;
    R_detail_setor: TfrxReport;
    Detail_setor: TfrxDBDataset;
    grid: TcxGrid;
    t_data: TcxGridDBTableView;
    l_data: TcxGridLevel;
    t_datauser: TcxGridDBColumn;
    t_datatanggal: TcxGridDBColumn;
    t_datastatus: TcxGridDBColumn;
    t_datakomp: TcxGridDBColumn;
    t_datan_user: TcxGridDBColumn;
    gb_1: TGroupBox;
    l_1: TLabel;
    l_3: TLabel;
    ed_Kd_kasir: TEdit;
    ed_set_Real: TsCurrencyEdit;
    b_simpan: TBitBtn;
    b_cetak: TBitBtn;
    p1: TPanel;
    l_5: TLabel;
    b_refresh: TBitBtn;
    de_trans: TsDateEdit;
    sLabel1: TLabel;
    edNama: TEdit;
    sLabel2: TLabel;
    edWaktu: TEdit;
    edIP: TEdit;
    sLabel3: TLabel;
    procedure FormShow(Sender: TObject);
    procedure ed_Kd_kasirKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ed_set_RealKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure b_simpanClick(Sender: TObject);
    procedure b_cetakClick(Sender: TObject);
    procedure b_refreshClick(Sender: TObject);
    procedure laporanClickObject(view: TfrxView; Button: TMouseButton;
      Shift: TShiftState; var Modified: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  F_Setor: TF_Setor;

implementation

uses
  u_dm;

{$R *.dfm}

procedure TF_Setor.FormShow(Sender: TObject);
begin

  fungsi.SQLExec(dm.Q_temp,
    'select tanggal from tb_login_kasir where kd_perusahaan="' +
    dm.kd_perusahaan + '" ' + 'and kd_jaga="' + dm.kd_pengguna +
    '"  and `status` = ''online'' order by `status` ASC limit 1', true);
  if dm.Q_temp.Eof then
    de_trans.Date := Date()
  else
    de_trans.Date := dm.Q_temp.FieldByName('tanggal').AsDateTime;

  b_refreshClick(Self);
end;

procedure TF_Setor.ed_Kd_kasirKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = vk_return then
  begin
    PeekMessage(Mgs, 0, WM_CHAR, WM_CHAR, PM_REMOVE);
    fungsi.SQLExec(dm.Q_temp,
      'select * from tb_login_kasir inner join tb_user on ' +
      'tb_user.kd_user=tb_login_kasir.user where tb_login_kasir.kd_perusahaan="'
      + dm.kd_perusahaan + '" ' + 'and tb_login_kasir.user="' + ed_Kd_kasir.Text
      + '" and tb_login_kasir.kd_jaga="' + dm.kd_pengguna +
      '" and status=''online''', true);
    if dm.Q_temp.Eof then
    begin
      showmessage('Id Kasir ini tidak ada dalam daftar kasir yang belum setor');
      ed_set_Real.SetFocus;
      ed_Kd_kasir.SetFocus;
    end
    else
    begin
      edNama.Text := dm.Q_temp.FieldByName('n_user').AsString;
      edWaktu.Text := dm.Q_temp.FieldByName('tanggal').AsString;
      edIP.Text := dm.Q_temp.FieldByName('komp').AsString;
      ed_set_Real.ReadOnly := false;
      ed_set_Real.SetFocus;
      b_simpan.Enabled := true;
    end;
  end;
end;

procedure TF_Setor.ed_set_RealKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = vk_return then
  begin
    PeekMessage(Mgs, 0, WM_CHAR, WM_CHAR, PM_REMOVE);
    b_simpan.SetFocus;
  end;
end;

procedure TF_Setor.b_simpanClick(Sender: TObject);
begin
  dm.db_conn.StartTransaction;
  try
    fungsi.SQLExec(dm.Q_exe, 'call sp_setor_kasir("' + dm.kd_perusahaan + '","'
      + ed_Kd_kasir.Text + '","' + dm.kd_pengguna + '")', false);

    fungsi.SQLExec(dm.Q_exe, 'update tb_login_kasir set jumlah_setor_real="' +
      ed_set_Real.Text +
      '", tgl_logout=now(),status=''offline'' where kd_perusahaan="' +
      dm.kd_perusahaan + '" and user="' + ed_Kd_kasir.Text + '" and kd_jaga="' +
      dm.kd_pengguna + '" and status="online"', false);

    dm.db_conn.Commit;
    showmessage('penyimpanan data sukses');
    b_refreshClick(Self);
  except
    on e: exception do
    begin
      dm.db_conn.Rollback;
      showmessage('penyimpanan data gagal '#10#13'' + e.Message);
    end;
  end;
end;

procedure TF_Setor.b_cetakClick(Sender: TObject);
begin
  fungsi.SQLExec(dm.Q_laporan,
    'select * from tb_login_kasir inner join tb_user on ' +
    'tb_user.kd_user=tb_login_kasir.`user` ' +
    'where status=''offline'' and tanggal >= "' +
    formatdatetime('yyyy-MM-dd hh:mm:ss', de_trans.Date) +
    '" and tb_login_kasir.kd_jaga="' + dm.kd_pengguna +
    '" and tb_login_kasir.kd_perusahaan="' + dm.kd_perusahaan + '"', true);
  laporan.LoadFromFile(dm.Path + 'laporan\p_setor_kasir.fr3');
  laporan.ShowReport;
end;

procedure TF_Setor.b_refreshClick(Sender: TObject);
begin
  ed_Kd_kasir.Clear;
  ed_set_Real.Clear;
  ed_set_Real.ReadOnly := true;
  b_simpan.Enabled := false;

  fungsi.SQLExec(dm.Q_show, 'SELECT * FROM tb_login_kasir INNER JOIN tb_user ' +
    'ON tb_user.kd_user = tb_login_kasir.`user` WHERE ' + 'tanggal >= "' +
    formatdatetime('yyyy-MM-dd hh:mm:ss', de_trans.Date) + '" AND ' +
    'tb_login_kasir.kd_jaga="' + dm.kd_pengguna + '" AND ' +
    'tb_login_kasir.kd_perusahaan="' + dm.kd_perusahaan + '" ' +
    'ORDER BY tanggal DESC', true);

  if dm.Q_show.Eof then
  begin
    de_trans.SetFocus;
    ed_Kd_kasir.Enabled := false;
    ed_set_Real.Enabled := false;
    b_cetak.Enabled := false;
  end
  else
  begin
    b_cetak.Enabled := true;
    ed_Kd_kasir.Enabled := true;
    ed_set_Real.Enabled := true;
    ed_Kd_kasir.SetFocus;
  end;
end;

procedure TF_Setor.laporanClickObject(view: TfrxView; Button: TMouseButton;
  Shift: TShiftState; var Modified: Boolean);
var
  LSql, LView, LKasir, LLogin: string;
begin
  if view.Name = 'mm_kasir_user' then
  begin
    LView := view.TagStr;
    LKasir := Copy(LView, 1, Pos(':', LView) - 2);
    LLogin := Copy(LView, Pos(':', LView) + 2, Length(LView));

    LSql := Format('SELECT * FROM tb_login_kasir lk INNER JOIN tb_user us ' +
      'ON us.kd_user = lk.user WHERE lk.kd_perusahaan="%s" AND lk.user="%s" ' +
      'AND lk.kd_jaga="%s" and tanggal = "%s"', [dm.kd_perusahaan, LKasir,
      dm.kd_pengguna, LLogin]);

    fungsi.SQLExec(dm.Q_temp, LSql, true);

    R_detail_setor.LoadFromFile(dm.Path + 'laporan\p_setor_kasir_detail.fr3');
    R_detail_setor.ShowReport;
  end;
end;

end.
