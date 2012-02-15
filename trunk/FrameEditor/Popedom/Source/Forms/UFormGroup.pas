{*******************************************************************************
  ����: dmzn@ylsoft.com 2008-2-27
  ����: ��������Ϣ
*******************************************************************************}
unit UFormGroup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, ImgList;

type
  TfFormGroup = class(TForm)
    Edit_Name: TLabeledEdit;
    Edit_Desc: TLabeledEdit;
    BtnOK: TButton;
    BtnExit: TButton;
    Box_CanDel: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FIsAdd: Boolean;
    {*�Ƿ����*}
    FGroupID: string;
    {*���ʶ*}

    procedure LoadGroupInfo(const nGroup: string);
    {*��������Ϣ*}
  public
    { Public declarations }
  end;

function ShowAddGroupForm: Boolean;
function ShowEditGroupForm(const nGroup: string): Boolean;
function DeleteGroup(const nGroup,nName: string): Boolean;
//��ں���

implementation

{$R *.dfm}
uses
  ULibFun, USysFun, USysConst, USysPopedom, UMgrPopedom, UDataModule;

//------------------------------------------------------------------------------
//Desc: �����
function ShowAddGroupForm: Boolean;
begin
  with TfFormGroup.Create(Application) do
  begin
    Caption := '�½���';
    FIsAdd := True;

    Result := ShowModal = mrOK;
    Free
  end;
end;

//Desc: �޸�nGroup��
function ShowEditGroupForm(const nGroup: string): Boolean;
begin
  with TfFormGroup.Create(Application) do
  begin
    Caption := '�޸���';
    FIsAdd := False;
    FGroupID := nGroup;

    LoadGroupInfo(nGroup);
    Result := ShowModal = mrOK;
    Free
  end;
end;

//Desc: ɾ��nGroup��
function DeleteGroup(const nGroup,nName: string): Boolean;
var nStr: string;
begin
  Result := False;
  nStr := 'ȷ��Ҫɾ�� [%s] ����';
  nStr := Format(nStr, [nName]);
  if not QueryDlg(nStr, sAsk) then Exit;

  ShowMsgOnLastPanelOfStatusBar('���ڶ�ȡ����Ϣ,���Ժ�...');
  try
    nStr := 'Select G_CANDEL From %s Where G_ID=%s';
    nStr := Format(nStr, [gSysParam.FTableGroup, nGroup]);

    FDM.SQLQuery.Close;
    FDM.SQLQuery.SQL.Text := nStr;
    FDM.SQLQuery.Open;

    if FDM.SQLQuery.RecordCount <> 1 then
    begin
      ShowDlg('�޷���ȡ������ϸ��Ϣ,������ֹ!', sHint); Exit;
    end;

    FDM.SQLQuery.First;
    if FDM.SQLQuery.Fields[0].AsInteger <> cPopedomGroup_CanDel then
    begin
      nStr := '����Ա���ø��鲻��ɾ��' + #13#10 +
              'ȷ��Ҫɾ������,�����趨"����ɾ��"����';
      ShowDlg(nStr, sHint); Exit;
    end;

    ShowMsgOnLastPanelOfStatusBar('����ִ��ɾ������,���Ժ�...');
    nStr := 'Delete From %s Where P_GROUP=%s';
    nStr := Format(nStr, [gSysParam.FTablePopedom, nGroup]);

    FDM.ADOConn.BeginTrans;
    FDM.Command.Close;
    FDM.Command.SQL.Text := nStr;
    Result := FDM.Command.ExecSQL > -1;

    if Result then
    begin
      nStr := 'Delete From %s Where G_ID=%s';
      nStr := Format(nStr, [gSysParam.FTableGroup, nGroup]);

      FDM.Command.Close;
      FDM.Command.SQL.Text := nStr;
      Result := FDM.Command.ExecSQL > -1;
    end;

    if not Result then
    begin
      FDM.ADOConn.RollbackTrans;
      ShowDlg('ɾ�����̳����쳣,������ֹ', sHint);
    end else FDM.ADOConn.CommitTrans;
  finally
    ShowMsgOnLastPanelOfStatusBar('');
    if FDM.ADOConn.InTransaction then FDM.ADOConn.RollbackTrans;
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormGroup.FormCreate(Sender: TObject);
begin
  LoadFormConfig(Self);
end;

procedure TfFormGroup.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveFormConfig(Self);
end;

//------------------------------------------------------------------------------
//Desc: ��ȡnGroup����Ϣ
procedure TfFormGroup.LoadGroupInfo(const nGroup: string);
var nStr: string;
begin
  ShowMsgOnLastPanelOfStatusBar('���ڶ�ȡ����Ϣ,���Ժ�...');
  try
    nStr := 'Select * From %s Where G_ID=%s';
    nStr := Format(nStr, [gSysParam.FTableGroup, nGroup]);

    FDM.SQLQuery.Close;
    FDM.SQLQuery.SQL.Text := nStr;
    FDM.SQLQuery.Open;

    if FDM.SQLQuery.RecordCount <> 1 then
    begin
      ShowDlg('�޷���ȡ�������Ϣ', sHint); Exit;
    end;

    FDM.SQLQuery.First;
    Edit_Name.Text := FDM.SQLQuery.FieldByName('G_NAME').AsString;
    Edit_Desc.Text := FDM.SQLQuery.FieldByName('G_DESC').AsString;
    Box_CanDel.Checked := FDM.SQLQuery.FieldByName('G_CANDEL').AsInteger = cPopedomGroup_CanDel;
  finally
    ShowMsgOnLastPanelOfStatusBar('');
  end;
end;

//Desc: ����
procedure TfFormGroup.BtnOKClick(Sender: TObject);
var nStr,nID: string;
    nDel: integer;
begin
  Edit_Name.Text := Trim(Edit_Name.Text);
  if Edit_Name.Text = '' then
  begin
    Edit_Name.SetFocus;
    ShowDlg('������������', sHint); Exit;
  end;

  if Box_CanDel.Checked then
       nDel := cPopedomGroup_CanDel
  else nDel := cPopedomGroup_NoDel;

  if FIsAdd then
  begin
    nStr := 'Select Max(G_ID) From $Group';
    nStr := MacroValue(nStr, [MI('$Group', gSysParam.FTableGroup)]);

    FDM.SQLQuery.Close;
    FDM.SQLQuery.SQL.Text := nStr;
    FDM.SQLQuery.Open;
    nID := IntToStr(FDM.SQLQuery.Fields[0].AsInteger + 1);
    
    nStr := 'Insert Into $Group(G_ID, G_PROGID, G_NAME, G_DESC, G_CANDEL) ' +
            'Values($GID, ''%s'', ''%s'', ''%s'', %d)';
    nStr := MacroValue(nStr, [MI('$Group', gSysParam.FTableGroup), MI('$GID', nID)]);
    nStr := Format(nStr, [gSysParam.FProgID, Edit_Name.Text, Edit_Desc.Text, nDel]);
  end else
  begin
    nStr := 'Update %s Set G_NAME=''%s'', G_DESC=''%s'', G_CANDEL=%d ' +
            'Where G_ID=%s';
    nStr := Format(nStr, [gSysParam.FTableGroup, Edit_Name.Text, Edit_Desc.Text, nDel, FGroupID]);
  end;

  FDM.Command.Close;
  FDM.Command.SQL.Text := nStr;
  if FDM.Command.ExecSQL > -1 then
  begin
    ModalResult := mrOk;
    ShowMsg('����Ϣ�Ѿ�����', sHint);
  end else ShowDlg('�޷��ύ����Ϣ', 'δ֪����');
end;

end.
