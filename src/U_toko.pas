unit U_toko;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ComCtrls, Buttons, DBCtrls, ExtCtrls, UFungsi, cxStyles,
  cxGraphics, cxDataStorage, cxEdit, DB, cxDBData, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxControls, cxGridCustomView,
  cxGrid, StdCtrls;

type
  TF_toko = class(TForm)
    sButton2: TButton;
    cb_periode: TComboBox;
    btnMutasi: TButton;
    btnGross: TButton;
    lbl1: TLabel;
    btnMutasiHarga: TButton;
    procedure btnGrossClick(Sender: TObject);
    procedure btnMutasiClick(Sender: TObject);
    procedure sButton2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cb_periodeChange(Sender: TObject);
    procedure cekPeriode;
  private
    bulan, tahun, periode: string;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  F_toko: TF_toko;

implementation

uses
  u_dm;

{$R *.dfm}

procedure TF_toko.btnGrossClick(Sender: TObject);
begin
  fungsi.SQLExec(dm.Q_laporan,
    'select * from tb_gross_margin where MONTH(tanggal)="' + bulan +
    '" and YEAR(tanggal)="' + tahun + '" and kd_perusahaan="' + dm.kd_perusahaan
    + '"', true);
  dm.laporan.LoadFromFile(dm.Path + 'laporan\gp_gross.fr3');
  dm.laporan.ShowReport;
end;

procedure TF_toko.btnMutasiClick(Sender: TObject);
begin
  fungsi.SQLExec(dm.Q_laporan,
    'select * from tb_mutasi_bulan where MONTH(tgl)="' + bulan +
    '" and YEAR(tgl)="' + tahun + '" and kd_perusahaan="' + dm.kd_perusahaan +
    '"', true);
  if TButton(Sender).Name = 'btnMutasi' then
    dm.laporan.LoadFromFile(dm.Path + 'laporan\gp_mutasi_global_stok.fr3')
  else
    dm.laporan.LoadFromFile(dm.Path + 'laporan\gp_mutasi_global_uang.fr3');

  dm.laporan.ShowReport;
end;

procedure TF_toko.sButton2Click(Sender: TObject);
begin
  fungsi.SQLExec(dm.Q_laporan, 'select * from vw_stok_out where kd_perusahaan="'
    + dm.kd_perusahaan + '"', true);
  dm.laporan.LoadFromFile(dm.Path + 'laporan\gp_stok_out_harian.fr3');
  dm.laporan.ShowReport;
end;

procedure TF_toko.FormCreate(Sender: TObject);
var
  x: Integer;
begin
  fungsi.SQLExec(dm.Q_temp, 'SELECT LEFT(tb_mutasi_bulan.tgl,7) as periode, ' +
    'left(date(now()),7) as sekarang FROM tb_mutasi_bulan where kd_perusahaan = "'
    + dm.kd_perusahaan + '" GROUP BY LEFT(tb_mutasi_bulan.tgl,7)', true);

  for x := 1 to dm.Q_temp.RecordCount do
  begin
    cb_periode.Items.Add(dm.Q_temp.fieldbyname('periode').AsString);
    dm.Q_temp.Next;
  end;

  cb_periode.ItemIndex := cb_periode.Items.Count - 1;
  cekPeriode;
end;

procedure TF_toko.cb_periodeChange(Sender: TObject);
begin
  cekPeriode;
end;

procedure TF_toko.cekPeriode;
begin
  periode := cb_periode.Text;
  bulan := Copy(periode, 6, 2);
  tahun := Copy(periode, 1, 4);
end;

end.
