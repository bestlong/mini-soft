{*******************************************************************************
  ����: dmzn@163.com 2007-11-11
  ����: ���,�޸�(�����ʶ,ʵ���ʶ)

  ��ע:
  &."�����ʶ"���ڱ�ʶһ����������.
  &."ʵ���ʶ"��ʾһ�������ڵ�ĳ���˵�,���������ɲ˵���.
  &."�����ʶ"��"ʵ���ʶ"���ڿյ�һ������.
  &."��ʾ��ʶ"��"�˵���ʶ"���ڿյ�һ������.
*******************************************************************************}
unit Menu_AddEntity;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TFrmEntity = class(TForm)
    BtnSave: TButton;
    Button2: TButton;
    Panel1: TPanel;
    Edit_Entity: TLabeledEdit;
    Edit_Prog: TLabeledEdit;
    Label1: TLabel;
    Edit_Desc: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnSaveClick(Sender: TObject);
    procedure Edit_ProgKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FProgID,FEntity: string;
    {*��ʶ*}
    procedure LoadData;
    {*��������*}
  public
    { Public declarations }
  end;

function ShowAddEntityForm: Boolean;
function ShowEditEntityForm(const nProgID,nEntity: string): Boolean;
//��ں���

implementation

{$R *.dfm}
uses
  Menu_DM, Menu_Const, ULibFun;

ResourceString
  sSelectEntity = 'Select M_ProgID,M_Entity,M_Title From %s where ' +
                  'M_ProgID=''%s'' and M_Entity=''%s''';
  //��ѯ�ƶ�ʵ��
  sInsertEntity = 'Insert into %s(M_ProgID,M_Entity,M_Title,M_MenuID,M_NewOrder) ' +
                  'Values(''%s'',''%s'',''%s'', '''', 0)';
  //׷��ʵ��
  sUpdateEntity = 'Update %s Set M_Title=''%s'' where M_ProgID=''%s'' and ' +
                  'M_Entity=''%s'' and M_MenuID=''''';
  //����ʵ��

//------------------------------------------------------------------------------
//Date: 2007-11-11
//Desc: ���ʵ���ʶ
function ShowAddEntityForm: Boolean;
begin
  with TFrmEntity.Create(Application) do
  begin
    FProgID := '';
    FEntity := '';
    Caption := '���ʵ��';

    Result := ShowModal = mrOK;
    Free;
  end;
end;

//Date: 2007-11-11
//Parm: �����ʶ;ʵ���ʶ
//Desc: �޸�nProgID�µ�nEntityʵ��
function ShowEditEntityForm(const nProgID,nEntity: string): Boolean;
begin
  with TFrmEntity.Create(Application) do
  begin
    FProgID := nProgID;
    FEntity := nEntity;
    Caption := '�޸�ʵ��';

    LoadData;
    Result := ShowModal = mrOK;
    Free;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ���뵱ǰʵ������
procedure TFrmEntity.LoadData;
begin
  FDM.SQLTemp.Close;
  FDM.SQLTemp.SQL.Text := Format(sSelectEntity, [gMenuTable, FProgID, FEntity]);
  FDM.SQLTemp.Open;

  if FDM.SQLTemp.RecordCount > 0 then
  begin
    Edit_Prog.Text := FProgID;
    Edit_Entity.Text := FEntity;
    Edit_Desc.Text := FDM.SQLTemp.FieldByName('M_Title').AsString;
  end else ShowMsg('�޷���λָ��"ʵ��"', sHint);

  Edit_Prog.ReadOnly := True;
  Edit_Entity.ReadOnly := True;
end;

//------------------------------------------------------------------------------
procedure TFrmEntity.FormCreate(Sender: TObject);
begin
  LoadFormConfig(Self);
end;

procedure TFrmEntity.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveFormConfig(Self);
end;

//------------------------------------------------------------------------------
//Desc: ��ת����
procedure TFrmEntity.Edit_ProgKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    Perform(WM_NEXTDLGCTL, 0, 0);
  end;
end;

//Desc: ����ʵ��
procedure TFrmEntity.BtnSaveClick(Sender: TObject);
var nStr: string;
begin
  Edit_Prog.Text := Trim(Edit_Prog.Text);
  Edit_Entity.Text := Trim(Edit_Entity.Text);
  Edit_Desc.Text := Trim(Edit_Desc.Text);

  if (Edit_Prog.Text = '') then
  begin
    ShowMsg('������"�����ʶ"', sHint); Exit;
  end;

  if (Edit_Desc.Text = '') then
  begin
    ShowMsg('������"��ʶ����"', sHint); Exit;
  end;

  if not Edit_Prog.ReadOnly then
  begin
    nStr := Format(sSelectEntity, [gMenuTable, Edit_Prog.Text, Edit_Entity.Text]);
    FDM.SQLTemp.Close;                                                            
    FDM.SQLTemp.SQL.Text := nStr;
    FDM.SQLTemp.Open;

    if FDM.SQLTemp.RecordCount > 0 then
    begin
      ShowMsg('��ʵ���Ѿ�����', sHint); Exit;
    end;
  end;

  if Edit_Prog.ReadOnly then
       nStr := Format(sUpdateEntity, [gMenuTable, Edit_Desc.Text, Edit_Prog.Text, Edit_Entity.Text])
  else nStr := Format(sInsertEntity, [gMenuTable, Edit_Prog.Text, Edit_Entity.Text, Edit_Desc.Text]);

  FDM.SQLCmd.Close;
  FDM.SQLCmd.SQL.Text := nStr;
  if FDM.SQLCmd.ExecSQL > 0 then
  begin
    ShowMsg('�����ύ�ɹ�', sHint);
    ModalResult := mrOK;
  end else ShowMsg('���ݺ����ύʧ��', sHint);
end;

end.
