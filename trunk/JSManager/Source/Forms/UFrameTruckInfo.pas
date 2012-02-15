{*******************************************************************************
  ����: dmzn@163.com 2009-9-13
  ����: ��������
*******************************************************************************}
unit UFrameTruckInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, ADODB, cxContainer, cxLabel,
  dxLayoutControl, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxTextEdit, cxMaskEdit, cxButtonEdit;

type
  TfFrameTruckInfo = class(TfFrameNormal)
    EditID: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    procedure BtnExitClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure cxView1DblClick(Sender: TObject);
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
  protected
    function InitFormDataSQL(const nWhere: string): string; override;
    {*��ѯSQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, UFormBase, UDataModule;

class function TfFrameTruckInfo.FrameID: integer;
begin
  Result := cFI_FrameTruckInfo;
end;

procedure TfFrameTruckInfo.BtnExitClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if not IsBusy then
  begin
    nParam.FCommand := cCmd_FormClose;
    CreateBaseFormItem(cFI_FormTruckInfo, '', @nParam); Close;
  end;
end;

function TfFrameTruckInfo.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select * From ' + sTable_TruckInfo;
  if nWhere <> '' then Result := Result + ' Where ' + nWhere;
end;

//------------------------------------------------------------------------------
procedure TfFrameTruckInfo.BtnAddClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  nParam.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormTruckInfo, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

procedure TfFrameTruckInfo.BtnEditClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�༭�ļ�¼', sHint); Exit;
  end;

  nParam.FCommand := cCmd_EditData;
  nParam.FParamA := SQLQuery.FieldByName('T_ID').AsString;
  CreateBaseFormItem(cFI_FormTruckInfo, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData(FWhere);
  end;
end;

procedure TfFrameTruckInfo.BtnDelClick(Sender: TObject);
var nStr,nSQL: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫɾ���ļ�¼', sHint); Exit;
  end;

  nStr := SQLQuery.FieldByName('T_TruckNo').AsString;
  if not QueryDlg('ȷ��Ҫɾ���ƺ�Ϊ[ ' + nStr + ' ]�ĳ�����?', sAsk) then Exit;

  FDM.ADOConn.BeginTrans;
  try
    nStr := SQLQuery.FieldByName('T_ID').AsString;
    nSQL := 'Delete From %s Where T_ID=%s';
    nSQL := Format(nSQL, [sTable_TruckInfo, nStr]);
    FDM.ExecuteSQL(nSQL);

    nSQL := 'Delete From %s Where I_Group=''%s'' and I_ItemID=''%s''';
    nSQL := Format(nSQL, [sTable_ExtInfo, sFlag_TruckItem, nStr]); 
    FDM.ExecuteSQL(nSQL);

    FDM.ADOConn.CommitTrans;
    InitFormData(FWhere);
    ShowMsg('�ѳɹ�ɾ����¼', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('ɾ����¼ʧ��', 'δ֪����');
  end;
end;

procedure TfFrameTruckInfo.cxView1DblClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nParam.FCommand := cCmd_ViewData;
    nParam.FParamA := SQLQuery.FieldByName('T_ID').AsString;
    CreateBaseFormItem(cFI_FormTruckInfo, PopedomItem, @nParam);
  end;
end;

procedure TfFrameTruckInfo.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditID then
  begin
    FWhere := 'T_TruckNo Like ''%' + EditID.Text + '%''';
    InitFormData(FWhere);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameTruckInfo, TfFrameTruckInfo.FrameID);
end.
