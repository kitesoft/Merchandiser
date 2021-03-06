unit u_RO;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, sTooledit, Buttons, sSpeedButton, Mask, sCurrEdit, sCurrencyEdit,
  ExtCtrls, cxCustomData, cxGraphics, cxDataStorage, cxEdit, cxGridLevel,
  cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGrid, cxCurrencyEdit, UFungsi, ComCtrls, sSkinProvider,
  cxImageComboBox, cxStyles, sDialogs, StdCtrls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxNavigator, cxFilter, cxData, sMaskEdit,
  sCustomComboEdit;

type
  Tf_RO = class(TForm)
    panel4: TPanel;
    sPanel1: TPanel;
    Grid: TcxGrid;
    TableView: TcxGridTableView;
    ableViewColumn1: TcxGridColumn;
    ableViewColumn2: TcxGridColumn;
    t_view_Qty: TcxGridColumn;
    t_view_harga: TcxGridColumn;
    t_view_HPP: TcxGridColumn;
    Level: TcxGridLevel;
    panel1: TPanel;
    Mm_nama: TMemo;
    ce_harga: TsCurrencyEdit;
    panel2: TPanel;
    sLabel1: TLabel;
    sLabel3: TLabel;
    sLabel4: TLabel;
    ed_no_faktur: TEdit;
    ed_tgl: TsDateEdit;
    ed_supplier: TEdit;
    panel3: TPanel;
    ed_nilai_faktur: TsCurrencyEdit;
    sSpeedButton18: TsSpeedButton;
    sSkinProvider1: TsSkinProvider;
    sLabel5: TLabel;
    od: TOpenDialog;
    sPanel2: TPanel;
    b_load: TButton;
    spnl1: TPanel;
    b_simpan: TButton;
    b_new: TButton;
    b_print: TButton;
    t_view_barcode: TcxGridColumn;
    procedure WMMDIACTIVATE(var msg: TWMMDIACTIVATE); message WM_MDIACTIVATE;
    procedure bersih;
    procedure tampil_data;
    procedure TableViewTcxGridDataControllerTcxDataSummaryFooterSummaryItems4GetText
      (Sender: TcxDataSummaryItem; const AValue: Variant; AIsFooter: Boolean;
      var AText: string);
    procedure TableViewFocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure b_newClick(Sender: TObject);
    procedure b_simpanClick(Sender: TObject);
    procedure b_printClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ed_no_fakturChange(Sender: TObject);
    procedure sSpeedButton18Click(Sender: TObject);
    procedure b_loadClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    no_faktur: string;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  f_RO: Tf_RO;

implementation

uses
  u_dm, u_utama;

{$R *.dfm}

procedure Tf_RO.WMMDIACTIVATE(var msg: TWMMDIACTIVATE);
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

procedure Tf_RO.bersih;
begin
  ed_tgl.Date := now();
  Mm_nama.Clear;
  ce_harga.Clear;
  ed_supplier.Text := f_utama.sb.Panels[8].Text;
  ed_no_faktur.Clear;
  TableView.DataController.RecordCount := 0;
  ed_nilai_faktur.Clear;

  b_simpan.Enabled := true;
  b_print.Enabled := False;
end;

procedure Tf_RO.tampil_data;
var
  h: Integer;
  harga: real;
begin
  ed_supplier.Text := dm.Q_list_receipt.fieldbyname('kd_suplier').AsString;
  ed_no_faktur.Text := dm.Q_list_receipt.fieldbyname('kd_receipt').AsString;
  Self.Caption := Format('RO(%s)', [ed_no_faktur.Text]);
  no_faktur := dm.Q_list_receipt.fieldbyname('kd_receipt').AsString;
  ed_tgl.Text := formatdatetime('dd/MM/yyyy',
    dm.Q_list_receipt.fieldbyname('tgl_receipt').AsDateTime);

  fungsi.SQLExec(dm.Q_temp,
    'select * from tb_receipt_rinci where kd_perusahaan="' +
    dm.Q_list_receipt.fieldbyname('kd_perusahaan').AsString +
    '" and kd_receipt="' + dm.Q_list_receipt.fieldbyname('kd_receipt').AsString
    + '"', true);

  if dm.Q_temp.RecordCount <> 0 then
  begin
    TableView.DataController.RecordCount := dm.Q_temp.RecordCount;
    for h := 0 to dm.Q_temp.RecordCount - 1 do
    begin
      TableView.DataController.SetValue(h, 0, dm.Q_temp.fieldbyname('kd_barang')
        .AsString);
      TableView.DataController.SetValue(h, 1, dm.Q_temp.fieldbyname('n_barang')
        .AsString);
      TableView.DataController.SetValue(h, 2,
        dm.Q_temp.fieldbyname('qty_receipt').AsString);
      TableView.DataController.SetValue(h, 4,
        dm.Q_temp.fieldbyname('harga_pokok').AsString);
      TableView.DataController.SetValue(h, 5, dm.Q_temp.fieldbyname('barcode')
        .AsString);
      harga := dm.Q_temp.fieldbyname('harga_pokok').AsFloat /
        dm.Q_temp.fieldbyname('qty_receipt').AsFloat;
      TableView.DataController.SetValue(h, 3, harga);
      dm.Q_temp.Next;
    end;
  end;
  b_simpan.Enabled := False;
  b_print.Enabled := true;
end;

procedure Tf_RO.
  TableViewTcxGridDataControllerTcxDataSummaryFooterSummaryItems4GetText
  (Sender: TcxDataSummaryItem; const AValue: Variant; AIsFooter: Boolean;
  var AText: string);
begin
  if (AText <> '') then
    ed_nilai_faktur.Value := AValue
  else
    ed_nilai_faktur.Clear;
end;

procedure Tf_RO.TableViewFocusedRecordChanged(Sender: TcxCustomGridTableView;
  APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
  ANewItemRecordFocusingChanged: Boolean);
begin
  if TableView.DataController.RecordCount = 0 then
  begin
    Mm_nama.Clear;
    ce_harga.Clear;
    ed_nilai_faktur.Clear;
    exit;
  end;

  try
    Mm_nama.Text := AFocusedRecord.Values[1];
    ce_harga.Text := AFocusedRecord.Values[3];
  except
  end;
end;

procedure Tf_RO.b_newClick(Sender: TObject);
begin
  bersih;
end;

procedure Tf_RO.b_simpanClick(Sender: TObject);
var
  x: Integer;
  tunai, plus_PPN, isi_sql: string;
begin
  if (ed_no_faktur.Color = clblue) then
  begin
    showmessage('no faktur ini sudah ada dalam database....');
    exit;
  end;

  if TableView.DataController.RecordCount = 0 then
  begin
    showmessage('Data barang masih kosong...');
    exit;
  end;

  tunai := 'N';
  plus_PPN := 'Y';

  for x := 0 to TableView.DataController.RecordCount - 1 do
  begin
    isi_sql := isi_sql + '("' + dm.kd_perusahaan + '","' + ed_no_faktur.Text +
      '","' + formatdatetime('yyyy-MM-dd', ed_tgl.Date) + '","' +
      TableView.DataController.GetDisplayText(x, 0) + '","' +
      TableView.DataController.GetDisplayText(x, 1) + '","' +
      floattostr(TableView.DataController.GetValue(x, 2)) + '","' +
      floattostr(TableView.DataController.GetValue(x, 4)) + '",0,"' +
      TableView.DataController.GetDisplayText(x, 5) + '",date(now())),';
  end;
  delete(isi_sql, length(isi_sql), 1);

  dm.db_conn.StartTransaction;
  try
    fungsi.SQLExec(dm.Q_exe,
      'insert into tb_receipt_global(kd_perusahaan,kd_receipt,tgl_receipt,' +
      'kd_suplier,jatuh_tempo,tunai,plus_PPN,PPN,disk_rp,nilai_faktur,pengguna,simpan_pada) values ("'
      + dm.kd_perusahaan + '","' + ed_no_faktur.Text + '","' +
      formatdatetime('yyyy-MM-dd', ed_tgl.Date) + '","' + ed_supplier.Text +
      '",7,"' + tunai + '","' + plus_PPN + '",0,0,"' + ed_nilai_faktur.Text +
      '","' + dm.kd_pengguna + '",now())', False);

    fungsi.SQLExec(dm.Q_exe,
      'insert into tb_receipt_rinci(kd_perusahaan,kd_receipt,tgl_receipt,' +
      'kd_barang,n_barang,qty_receipt,harga_pokok,diskon,barcode,tgl_simpan) values '
      + isi_sql, False);

    dm.db_conn.Commit;
    showmessage('penyimpanan data berhasil...');
    ed_no_faktur.Color := clblue;
  except
    on E: exception do
    begin
      dm.db_conn.Rollback;
      messagedlg('proses penyimpanan gagal,ulangi lagi!!! '#10#13'' + E.Message,
        mterror, [mbOk], 0);
      exit;
    end;
  end;

end;

procedure Tf_RO.b_printClick(Sender: TObject);
begin
  fungsi.SQLExec(dm.Q_laporan,
    'select * from vw_cetak_receipt where kd_perusahaan="' + dm.kd_perusahaan +
    '" and kd_receipt="' + no_faktur + '"', true);
  dm.laporan.LoadFromFile(dm.Path + 'laporan\gp_receipt_rinci.fr3');
  dm.laporan.ShowReport;
end;

procedure Tf_RO.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  f_utama.MDIChildDestroyed(Self.Handle);
  Action := cafree;
  f_RO := nil;
end;

procedure Tf_RO.ed_no_fakturChange(Sender: TObject);
begin
  fungsi.SQLExec(dm.Q_temp,
    'select kd_receipt from tb_receipt_global where kd_receipt="' +
    ed_no_faktur.Text + '" and kd_perusahaan="' + dm.kd_perusahaan + '"', true);
  if not(dm.Q_temp.Eof) then
  begin
    ed_no_faktur.Color := clblue;
    no_faktur := ed_no_faktur.Text;
    b_print.Enabled := true;
  end
  else
  begin
    ed_no_faktur.Color := clwhite;
    b_print.Enabled := true;
  end;
end;

procedure Tf_RO.sSpeedButton18Click(Sender: TObject);
begin
  close;
end;

procedure Tf_RO.b_loadClick(Sender: TObject);
var
  F: TextFile;
  Tmp, x: Integer;
  TmpStr: string;
begin
  od.InitialDir := dm.DocPath;
  if od.Execute then
  begin
    try
      bersih;
      fungsi.amankan(od.FileName, od.FileName, 321);
      AssignFile(F, od.FileName);
      Reset(F);
      Readln(F, TmpStr);
      // ed_supplier.text:= TmpStr;
      Readln(F, TmpStr);
      // L_supp.caption:= TmpStr;
      Readln(F, TmpStr);
      ed_no_faktur.Text := TmpStr;
      Readln(F, TmpStr);
      ed_tgl.Date := now();
      // ed_tgl.Text:=TmpStr;
      Readln(F, Tmp);
      TableView.DataController.RecordCount := Tmp;
      for x := 0 to TableView.DataController.RecordCount - 1 do
      begin
        Readln(F, TmpStr);
        TableView.DataController.SetValue(x, 0, TmpStr);
        Readln(F, TmpStr);
        TableView.DataController.SetValue(x, 1, TmpStr);
        Readln(F, TmpStr);
        TableView.DataController.SetValue(x, 2, TmpStr);
        Readln(F, TmpStr);
        TableView.DataController.SetValue(x, 3, TmpStr);
        Readln(F, TmpStr);
        TableView.DataController.SetValue(x, 4, TmpStr);
        Readln(F, TmpStr);
        TableView.DataController.SetValue(x, 5, TmpStr);
      end;
      CloseFile(F);

      TableView.DataController.ChangeFocusedRowIndex
        (TableView.DataController.RecordCount);
      // mm_nama.Text:= tableView.DataController.GetValue(tableview.DataController.RecordCount-1,1);
      // ce_harga.Text:= tableView.DataController.GetValue(tableview.DataController.RecordCount-1,3);

      fungsi.amankan(od.FileName, od.FileName, 321);
    except
      showmessage('proses load data gagal...');
    end;
  end;

end;

procedure Tf_RO.FormCreate(Sender: TObject);
begin
  f_utama.MDIChildCreated(Self.Handle);
  b_new.Enabled := not dm.OnServer;
  b_load.Enabled := not dm.OnServer;
end;

end.
