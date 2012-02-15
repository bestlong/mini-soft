{*******************************************************************************
  ����: dmzn@163.com 2011-01-23
  ����: ���ɲɹ��ƻ�
*******************************************************************************}
unit UFormBuyPlan;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, dxLayoutControl, StdCtrls, cxControls, cxMemo,
  cxButtonEdit, cxLabel, cxTextEdit, cxContainer, cxEdit, cxMaskEdit,
  cxDropDownEdit, cxCalendar, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, cxRadioGroup;

type
  TfFormBuyPlan = class(TfFormNormal)
    dxLayout1Item12: TdxLayoutItem;
    EditMemo: TcxMemo;
    EditWeek: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item4: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditWeekPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FLastInterval: Cardinal;
    //�ϴ�ִ��
    FNowYear,FNowWeek,FWeekName: string;
    //���ڲ���
    procedure InitFormData;
    //��������
    procedure ShowNowWeek;
    //��ʾ����
    procedure ShowHintText(const nText: string);
    //��ʾ����
    procedure MakePlan(const nNeedCombine: Boolean);
    //���ɼƻ�
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UFormBase, UMgrControl, UDataModule, UFormCtrl, USysDB, USysConst,
  USysBusiness;

class function TfFormBuyPlan.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if not Assigned(nParam) then Exit;

  nP := nParam;
  if nP.FCommand <> cCmd_AddData then Exit;

  with TfFormBuyPlan.Create(Application) do
  try
    Caption := '�ɹ��ƻ�';
    InitFormData;
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormBuyPlan.FormID: integer;
begin
  Result := cFI_FormBuyPlan;
end;

procedure TfFormBuyPlan.FormCreate(Sender: TObject);
begin
  LoadFormConfig(Self);
end;

procedure TfFormBuyPlan.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveFormConfig(Self);
end;

//------------------------------------------------------------------------------
procedure TfFormBuyPlan.ShowNowWeek;
begin
  if FNowWeek = '' then
       EditWeek.Text := '��ѡ��ɹ�����'
  else EditWeek.Text := Format('%s ���:[ %s ]', [FWeekName, FNowYear]);

  EditWeek.SelStart := 0;
  EditWeek.SelLength := 0;
  Application.ProcessMessages;
end;

procedure TfFormBuyPlan.InitFormData;
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

  ShowNowWeek;
end;

procedure TfFormBuyPlan.ShowHintText(const nText: string);
begin
  EditMemo.Lines.Add(IntToStr(EditMemo.Lines.Count) + ' ::: ' + nText);
  Application.ProcessMessages;

  if GetTickCount - FLastInterval < 500 then
    Sleep(525);
  FLastInterval := GetTickCount;
end;

procedure TfFormBuyPlan.EditWeekPropertiesButtonClick(Sender: TObject;
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
  end;

  ShowNowWeek;
end;

//Desc: ��ʼ����
procedure TfFormBuyPlan.BtnOKClick(Sender: TObject);
var nStr: string;
begin
  if FNowWeek = '' then
  begin
    EditWeek.SetFocus;
    ShowMsg('��ѡ����Ч������', sHint); Exit;
  end;

  if not IsWeekValid(FNowWeek, nStr) then
  begin
    EditWeek.SetFocus;
    ShowMsg(nStr, sHint); Exit;
  end;

  if IsNextWeekEnable(FNowWeek) then
  begin
    nStr := '�������ѽ���,ϵͳ��ֹ�ò���!';
    ShowDlg(nStr, sHint); Exit;
  end;

  nStr := '�ò���������Ҫһ��ʱ��,�����ĵȺ�.' + #13#10 +
          'Ҫ������?';
  if not QueryDlg(nStr, sAsk) then Exit;

  FDM.ADOConn.BeginTrans;
  try
    BtnOK.Enabled := False;
    EditMemo.Clear;
    MakePlan(True);

    nStr := '�û�[ %s ]������[ %s ]ִ�мƻ����ɲ���.';
    nStr := Format(nStr, [gSysParam.FUserID, FWeekName]);
    FDM.WriteSysLog(sFlag_CommonItem, FNowWeek, nStr, False);

    FDM.ADOConn.CommitTrans;      
    ModalResult := mrOk;
    ShowMsg('�ɹ��ƻ��������', sHint);
  except
    on E:Exception do
    begin
      BtnOK.Enabled := True;
      FDM.ADOConn.RollbackTrans;
      ShowHintText(E.Message);
    end;
  end;
end;

//Desc: ���ɲɹ��ƻ�
procedure TfFormBuyPlan.MakePlan(const nNeedCombine: Boolean);
var nStr,nSQL,nRK,nCK: string;
begin
  nStr := 'Delete From %s Where P_Week=''%s''';
  nStr := Format(nStr, [sTable_BuyPlan, FNowWeek]);

  ShowHintText('��ʼ���������ڵľ�����...');
  FDM.ExecuteSQL(nStr);
  ShowHintText('�������������!');

  nStr := 'Select R_Goods,Sum(R_Num) as R_All From %s ' +
          'Where R_Week=''%s'' Group By R_Goods';
  nStr := Format(nStr, [sTable_BuyReq, FNowWeek]);

  nSQL := 'Select req.*,''%s'' As P_Week,''%s'' As P_Man,' +
          '%s As P_Date From (%s) req';
  nSQL := Format(nSQL, [FNowWeek, gSysParam.FUserID, FDM.SQLServerNow, nStr]);

  nStr := 'Insert Into %s(P_Goods,P_Num,P_Week,P_Man,P_Date) Select * From (%s) t';
  nSQL := Format(nStr, [sTable_BuyPlan, nSQL]);

  ShowHintText('��ʼ���㱾���ڸ����ŵĲɹ�����...');
  FDM.ExecuteSQL(nSQL);
  ShowHintText('�ɹ�����������!');

  nRK := 'Select B_Goods,B_Num From $BP ' +
         ' Union All ' +
         'Select Y_Goods,Y_Num From $YL ';
  nRK := MacroValue(nRK, [MI('$BP', sTable_BeiPin), MI('$YL', sTable_YuanLiao)]);
  //xxxxx

  nStr := 'Select B_Goods,Sum(B_Num) as B_RuKu From (%s) t Group By B_Goods';
  nRK := Format(nStr, [nRK]);
  //���ϼ�

  nCK := 'Select C_Goods,Sum(C_Num) as C_ChuKu From %s Group By C_Goods';
  nCK := Format(nCK, [sTable_ChuKu]);
  //����ϼ�

  nStr := 'Select B_Goods,IsNull(B_RuKu,0)-IsNull(C_ChuKu,0) As B_All From (%s) r ' +
          ' Left Join (%s) c On c.C_Goods=r.B_Goods ';
  nRK := Format(nStr, [nRK, nCK]);
  //�ܿ��

  nStr := 'Update $BP Set P_Has=B_All From ($RK) r ' +
          'Where P_Week=''$WK'' And r.B_Goods=P_Goods';
  nStr := MacroValue(nStr, [MI('$BP', sTable_BuyPlan), MI('$RK', nRK),
          MI('$WK', FNowWeek)]);
  //xxxxx

  ShowHintText('��ʼ�̵���...');
  FDM.ExecuteSQL(nStr);
  ShowHintText('����̵����!');

  nRK := 'Select B_Goods,B_Num From $BP Where B_Week=''$WK''' +
         ' Union All ' +
         'Select Y_Goods,Y_Num From $YL Where Y_Week=''$WK''';
  nRK := MacroValue(nRK, [MI('$BP', sTable_BeiPin),
         MI('$YL', sTable_YuanLiao), MI('$WK', FNowWeek)]);
  //xxxxx

  nStr := 'Select B_Goods,Sum(B_Num) as B_RuKu From (%s) t Group By B_Goods';
  nRK := Format(nStr, [nRK]);
  //���������ϼ�

  nStr := 'Update $BP Set P_Has=P_Has-IsNull(B_RuKu,0),' +
          'P_Done=IsNull(B_RuKu,0) From ($RK) r ' +
          'Where P_Week=''$WK'' And r.B_Goods=P_Goods';
  nStr := MacroValue(nStr, [MI('$BP', sTable_BuyPlan), MI('$RK', nRK),
          MI('$WK', FNowWeek)]);
  //xxxxx

  ShowHintText('��ʼ�����������������...');
  FDM.ExecuteSQL(nStr);
  ShowHintText('�����ڿ�������ݵ������!');

  nCK := 'Select D_Goods,Sum(D_Num) as D_ChuKu From %s ' +
         'Where D_RWeek=''%s'' Group By D_Goods';
  nCK := Format(nCK, [sTable_ChuKuDtl, FNowWeek]);
  //�����ڳ���ϼ�

  nStr := 'Update $BP Set P_Has=P_Has+IsNull(D_ChuKu,0) From ($CK) c ' +
          'Where P_Week=''$WK'' And c.D_Goods=P_Goods';
  nStr := MacroValue(nStr, [MI('$BP', sTable_BuyPlan), MI('$CK', nCK),
          MI('$WK', FNowWeek)]);
  //xxxxx

  ShowHintText('��ʼ���������ڳ�������...');
  FDM.ExecuteSQL(nStr);
  ShowHintText('�����ڿ�������ݵ������!');

  nStr := 'Delete From %s Where P_Week=''%s'' And P_Num<=0';
  nStr := Format(nStr, [sTable_BuyPlan, FNowWeek]);

  ShowHintText('��ʼ������ʱ��Ч����...');
  FDM.ExecuteSQL(nStr);
  ShowHintText('��Ч�����������!');
end;

initialization
  gControlManager.RegCtrl(TfFormBuyPlan, TfFormBuyPlan.FormID);
end.
