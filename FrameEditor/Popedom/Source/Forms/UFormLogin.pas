{*******************************************************************************
  ����: dmzn@163.com 2008-8-8
  ����: �û���¼����
*******************************************************************************}
unit UFormLogin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons;

type
  TfFormLogin = class(TForm)
    Image1: TImage;
    GroupBox1: TGroupBox;
    Edit_User: TLabeledEdit;
    Edit_Pwd: TLabeledEdit;
    LabelCopy: TLabel;
    BtnExit: TSpeedButton;
    BtnSet: TSpeedButton;
    BtnLogin: TButton;
    procedure BtnSetClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure BtnLoginClick(Sender: TObject);
    procedure Edit_UserKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function ShowLoginForm: Boolean;
//��ں���

implementation

{$R *.dfm}
uses
  USysConst, USysFun, USysPopedom, USysMenu, UDataModule, ULibFun, UMgrPopedom,
  UFormWait, UFormConn;

ResourceString
  sConnDBError = '�������ݿ�ʧ��,���ô����Զ������Ӧ';

//------------------------------------------------------------------------------
//Desc: �û���¼
function ShowLoginForm: Boolean;
var nStr: string;
begin
  with TfFormLogin.Create(Application) do
  begin
    Caption := 'Ȩ�� - ��¼';
    Edit_User.Text := gSysParam.FUserName;

    nStr := gPath + sLogoFile;
    if FileExists(nStr) then
      Image1.Picture.LoadFromFile(nStr);
    //logo

    if gSysParam.FCopyRight <> '' then
      LabelCopy.Caption := gSysParam.FCopyRight;
    //copyright
    
    Result := ShowModal = mrOk;
    Free
  end;
end;

//------------------------------------------------------------------------------
//Desc: ���Ӳ��Իص�
function TestConn(const nConnStr: string): Boolean;
begin
  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := nConnStr;
  FDM.ADOConn.Open;
  Result := FDM.ADOConn.Connected;
end;

//Desc: ����
procedure TfFormLogin.BtnSetClick(Sender: TObject);
begin
  ShowConnectDBSetupForm(TestConn);
end;

//Desc: �˳�
procedure TfFormLogin.BtnExitClick(Sender: TObject);
begin
  Close;
end;

//Desc: ��¼
procedure TfFormLogin.BtnLoginClick(Sender: TObject);
var nStr: string;
    nMsg: string;
begin
  Edit_User.Text := Trim(Edit_User.Text);
  Edit_Pwd.Text := Trim(Edit_Pwd.Text);

  if (Edit_User.Text = '') or (Edit_Pwd.Text = '') then
  begin
    ShowMsg('�������û���������', sHint); Exit;
  end;

  nStr := BuildConnectDBStr;
  
  while nStr = '' do
  begin
    ShowMsg('��������ȷ��"���ݿ�"���ò���', sHint);
    if ShowConnectDBSetupForm(TestConn) then
         nStr := BuildConnectDBStr
    else Exit;
  end;

  nMsg := '';
  ShowWaitForm(Self, '�������ݿ�');
  try
    try
      FDM.ADOConn.Connected := False;
      FDM.ADOConn.ConnectionString := nStr;
      FDM.ADOConn.Connected := True;

      if not gPopedomManager.CreateUserTable then
       raise Exception.Create('');
    except
      ShowDlg(sConnDBError, sWarn, Handle); Exit;
    end;

    nStr := 'Select U_NAME from $a Where U_NAME=''$b'' and ' +
            'U_PASSWORD=''$c'' and U_Identity=$d and U_State=$e';
    nStr := MacroValue(nStr, [MI('$a', gSysParam.FTableUser),
                              MI('$b', Edit_User.Text),
                              MI('$c', Edit_Pwd.Text),
                              MI('$d', IntToStr(cPopedomUser_Admin)),
                              MI('$e', IntToStr(cPopedomUser_Normal))]);

    FDM.SqlQuery.Close;
    FDM.SqlQuery.SQL.Text := nStr;
    FDM.SqlQuery.Open;

    if FDM.SqlQuery.RecordCount <> 1 then
    begin
      Edit_User.SetFocus;
      nMsg := '������û���������,����������'; Exit;
    end;

    gSysParam.FUserID := Edit_User.Text;
    gSysParam.FUserName := FDM.SqlQuery.Fields[0].AsString;
    gSysParam.FUserPwd := Edit_Pwd.Text;

    gPopedomManager.CreateGroupTable;
    gPopedomManager.CreatePopedomTable;
    gPopedomManager.CreatePopItemTable;

    gMenuManager.CreateMenuTable;
    ModalResult := mrOk;
  finally
    CloseWaitForm;
    if nMsg <> '' then ShowDlg(nMsg, sHint);
  end;
end;

procedure TfFormLogin.Edit_UserKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN, VK_DOWN: SwitchFocusCtrl(Self, True);
    VK_UP: SwitchFocusCtrl(Self, False);
  end;
end;

end.
