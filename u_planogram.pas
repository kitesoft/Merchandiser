unit u_planogram;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, sLabel, sEdit,u_fungsi,
  sSpinEdit, sButton, sSkinProvider, cxStyles,
  cxGraphics, cxDataStorage, cxEdit, DB,
  cxDBData, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGridLevel, cxClasses, cxControls, cxGridCustomView, cxGrid, sCheckBox,
  Mask, sMaskEdit, sCustomComboEdit, sCurrEdit, 
  cxCustomData, cxFilter, cxData, sCurrencyEdit;

type
  Tf_planogram = class(TForm)
    se_rak: TsSpinEdit;
    se_shelving: TsSpinEdit;
    sLabel2: TsLabel;
    sLabel3: TsLabel;
    sSkinProvider1: TsSkinProvider;
    grid_plano: TcxGrid;
    t_data_plano: TcxGridDBTableView;
    l_data_plano: TcxGridLevel;
    t_data_planoColumn1: TcxGridDBColumn;
    t_data_planoColumn2: TcxGridDBColumn;
    t_data_planoColumn3: TcxGridDBColumn;
    t_data_planoColumn4: TcxGridDBColumn;
    t_data_planoColumn5: TcxGridDBColumn;
    t_data_planoColumn6: TcxGridDBColumn;
    t_data_planoColumn7: TcxGridDBColumn;
    t_data_planoColumn8: TcxGridDBColumn;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    b_cetak: TsButton;
    sButton1: TsButton;
    procedure se_rakChange(Sender: TObject);
    procedure se_shelvingChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure b_cetakClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  f_planogram: Tf_planogram;
  fungsi:tfungsi;
  kd_barang: string;

implementation

uses u_dm, u_utama;

{$R *.dfm}

procedure Tf_planogram.se_rakChange(Sender: TObject);
begin
if se_rak.Value>0 then
begin
fungsi.SQLExec(dm.Q_show,'select * from vw_planogram_set where (kd_perusahaan="'+f_utama.sb.Panels[5].Text
+'" and no_rak='+se_rak.Text+' and no_shelving='+se_shelving.Text+')',true);

se_shelving.Enabled:= true;
end else
begin
  se_shelving.Value:=0;
  se_shelving.Enabled:= false;
end;
end;

procedure Tf_planogram.se_shelvingChange(Sender: TObject);
begin
if se_shelving.Value>0 then
begin
fungsi.SQLExec(dm.Q_show,'select * from vw_planogram_set where (kd_perusahaan="'+f_utama.sb.Panels[5].Text
+'" and no_rak='+se_rak.Text+' and no_shelving='+se_shelving.Text+')',true);
end else
begin
  dm.Q_show.Close;
end;
end;

procedure Tf_planogram.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
dm.Q_show.Close;
action:= cafree;
end;

procedure Tf_planogram.b_cetakClick(Sender: TObject);
begin
fungsi.SQLExec(dm.Q_laporan,'select * from vw_planogram where kd_perusahaan="'+f_utama.sb.Panels[5].Text+'"',true);
dm.laporan.LoadFromFile(dm.a_Path + 'laporan\gp_planogram.fr3');
dm.laporan.ShowReport;
end;

procedure Tf_planogram.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if key=vk_escape then close;

if key=vk_f3 then se_rak.SetFocus;
if key=vk_f4 then se_shelving.SetFocus;
if key=vk_f5 then grid_plano.SetFocus;
end;

procedure Tf_planogram.sButton1Click(Sender: TObject);
begin
fungsi.SQLExec(dm.Q_laporan,'select * from vw_planogram where kd_perusahaan="'+
f_utama.sb.Panels[5].Text+'" and no_rak ='+se_rak.Text+'',true);
dm.laporan.LoadFromFile(dm.a_path + 'laporan\gp_planogram.fr3');
dm.laporan.ShowReport;
end;

end.
