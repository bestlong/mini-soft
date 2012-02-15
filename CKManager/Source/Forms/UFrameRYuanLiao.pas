{*******************************************************************************
  ����: dmzn@163.com 2011-6-7
  ����: ����ԭ�����
*******************************************************************************}
unit UFrameRYuanLiao;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, ADODB, cxContainer, cxLabel,
  dxLayoutControl, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxTextEdit, cxMaskEdit, cxButtonEdit, UBitmapPanel,
  cxSplitter, Menus, cxLookAndFeels, cxLookAndFeelPainters;

type
  TfFrameRYuanLiao = class(TfFrameNormal)
    EditName: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item2: TdxLayoutItem;
    dxLayout1Item5: TdxLayoutItem;
    EditWeek: TcxButtonEdit;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure EditWeekPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
    FNowYear,FNowWeek,FWeekName: string;
    //��ǰ����
    procedure LoadDefaultWeek;
    //Ĭ������
  protected
    procedure OnCreateFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //���෽��
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, UDataModule, UFormBase, USysBusiness;

class function TfFrameRYuanLiao.FrameID: integer;
begin
  Result := cFI_FrameRYuanLiao;
end;

procedure TfFrameRYuanLiao.OnCreateFrame;
begin
  inherited;
  LoadDefaultWeek;
end;

//Desc: �ر�
procedure TfFrameRYuanLiao.BtnExitClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if not IsBusy then
  begin
    nParam.FCommand := cCmd_FormClose;
    CreateBaseFormItem(cFI_FormRYuanLiao, '', @nParam); Close;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ���ݲ�ѯSQL
function TfFrameRYuanLiao.InitFormDataSQL(const nWhere: string): string;
var nInt: Integer;
    nStr,nWeek: string;
begin
  if (FNowYear = '') and (FNowWeek = '') then
  begin
    EditWeek.Text := '��ѡ��ɹ�����'; Exit;
  end;

  nStr := '���:[ %s ] ����:[ %s ]';
  EditWeek.Text := Format(nStr, [FNowYear, FWeekName]);

  if FNowWeek = '' then
  begin
    nWeek := 'Where (W_Begin>=''$S'' and ' +
             'W_Begin<''$E'') or (W_End>=''$S'' and W_End<''$E'') ' +
             'Order By W_Begin';
    nInt := StrToInt(FNowYear);

    nWeek := MacroValue(nWeek, [MI('$W', sTable_Weeks),
            MI('$S', IntToStr(nInt)), MI('$E', IntToStr(nInt+1))]);
    //xxxxx
  end else nWeek := Format('Where Y_Week=''%s''', [FNowWeek]);

  Result := 'Select W_Name,S_Name,S_Owner,P_Name,yl.*,gs.* From %s yl' +
            ' Left Join %s wk On wk.W_NO=yl.Y_Week ' +
            ' Left Join %s gs On gs.G_ID=yl.Y_Goods ' +
            ' Left Join %s st On st.S_ID=yl.Y_Storage ' +
            ' Left Join %s pr On pr.P_ID=yl.Y_Provider ';
  Result := Format(Result, [sTable_YuanLiao, sTable_Weeks, sTable_Goods,
            sTable_Storage, sTable_Provider]);
  //xxxxx

  if FWhere = '' then
       Result := Result + nWeek
  else Result := Result + 'Where ( ' + FWhere + ' )';
end;

//Desc: ����Ĭ������
procedure TfFrameRYuanLiao.LoadDefaultWeek;
var nP: TFormCommandParam;
begin
  FNowYear := '';
  FNowWeek := '';
  FWeekName := '';
  nP.FCommand := cCmd_GetData;

  nP.FParamA := FNowYear;
  nP.FParamB := FNowWeek;
  nP.FParamE := sFlag_Yes;
  CreateBaseFormItem(cFI_FormGetWeek, PopedomItem, @nP);

  if nP.FCommand = cCmd_ModalResult then
  begin
    FNowYear := nP.FParamB;
    FNowWeek := nP.FParamC;
    FWeekName := nP.FParamD;
  end;
end;

//Desc: ���
procedure TfFrameRYuanLiao.BtnAddClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if FNowWeek = '' then
  begin
    ShowMsg('��ѡ��ɹ�����', sHint); Exit;
  end;

  if IsNextWeekEnable(FNowWeek) then
  begin
    ShowMsg('�������ѽ���', sHint); Exit;
  end;

  nParam.FCommand := cCmd_AddData;
  nParam.FParamA := FNowWeek;
  CreateBaseFormItem(cFI_FormRYuanLiao, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: ɾ��
procedure TfFrameRYuanLiao.BtnDelClick(Sender: TObject);
var nStr,nSQL: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫɾ���ļ�¼', sHint); Exit;
  end;

  nStr := SQLQuery.FieldByName('Y_Week').AsString;
  if IsNextWeekEnable(nStr) then
  begin
    ShowMsg('�������ѽ���', sHint); Exit;
  end;

  nStr := SQLQuery.FieldByName('R_ID').AsString;
  if not QueryDlg('ȷ��Ҫɾ�����Ϊ[ ' + nStr + ' ]����¼��?', sAsk) then Exit;

  FDM.ADOConn.BeginTrans;
  with SQLQuery do
  try
    nStr := FieldByName('R_ID').AsString;
    nSQL := 'Delete From %s Where R_ID=%s';
    nSQL := Format(nSQL, [sTable_YuanLiao, nStr]);
    FDM.ExecuteSQL(nSQL);
    {
    nSQL := 'Update %s Set P_Done=P_Done-%s Where P_Week=''%s'' and P_Goods=''%s''';
    nSQL := Format(nSQL, [sTable_BuyPlan, FieldByName('Y_Num').AsString,
            FieldByName('Y_Week').AsString, FieldByName('Y_Goods').AsString]);
    FDM.ExecuteSQL(nSQL);
    }
    FDM.ADOConn.CommitTrans;
    InitFormData(FWhere);
    ShowMsg('�ѳɹ�ɾ����¼', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('ɾ������ʧ��', sError);
  end;
end;

//Desc: ִ�в�ѯ
procedure TfFrameRYuanLiao.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := 'G_Name like ''%%%s%%'' Or G_PY Like ''%%%s%%''';
    FWhere := Format(FWhere, [EditName.Text, EditName.Text]);
    InitFormData(FWhere);
  end;
end;

//Desc: ѡ������
procedure TfFrameRYuanLiao.EditWeekPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_GetData;
  nP.FParamA := FNowYear;
  nP.FParamB := FNowWeek;
  CreateBaseFormItem(cFI_FormGetWeek, PopedomItem, @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    FNowYear := nP.FParamB;
    FNowWeek := nP.FParamC;
    FWeekName := nP.FParamD;

    InitFormData(FWhere);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameRYuanLiao, TfFrameRYuanLiao.FrameID);
end.
