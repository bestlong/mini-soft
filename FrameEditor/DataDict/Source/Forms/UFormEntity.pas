{*******************************************************************************
  ����: dmzn@163.com 2007-11-11
  ����: ���,�޸�(�����ʶ,ʵ���ʶ)

  ��ע:
  &."�����ʶ"���ڱ�ʶһ����������.
  &."ʵ���ʶ"��ʾһ�������ڵ�ĳ������,�����������ֵ���.
  &."�����ʶ"��"ʵ���ʶ"���ڿյ�һ������.
*******************************************************************************}
unit UFormEntity;

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
    procedure LoadData(const nProgID,nEntity: string);
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
  UMgrDataDict, USysDict, ULibFun, USysConst;

//------------------------------------------------------------------------------
//Date: 2007-11-11
//Desc: ���ʵ���ʶ
function ShowAddEntityForm: Boolean;
begin
  with TFrmEntity.Create(Application) do
  begin
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
    Caption := '�޸�ʵ��';
    LoadData(nProgID, nEntity);
    Result := ShowModal = mrOK;
    Free;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ���뵱ǰʵ������
procedure TFrmEntity.LoadData(const nProgID,nEntity: string);
var nList: TList;
    nIdx: integer;
begin
  Edit_Prog.Text := nProgID;
  Edit_Entity.Text := nEntity;
  
  Edit_Prog.ReadOnly := True;
  Edit_Entity.ReadOnly := True;
  if not gSysEntityManager.LoadProgList then Exit;

  nList := gSysEntityManager.ProgList;
  for nIdx:=nList.Count - 1 downto 0 do
   with PEntityItemData(nList[nIdx])^ do
   if (CompareText(nProgID, FProgID) = 0) and (CompareText(nEntity, FEntity) = 0) then
   begin
     Edit_Desc.Text := FTitle;
   end;
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
var nItem: TEntityItemData;
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

  nItem.FProgID := Edit_Prog.Text;
  nItem.FEntity := Edit_Entity.Text;
  nItem.FTitle := Edit_Desc.Text;

  if gSysEntityManager.AddEntityToDB(nItem) then
  begin
    ShowMsg('�����ύ�ɹ�', sHint);
    ModalResult := mrOK;
  end else ShowMsg('�����ύʧ��', sHint);
end;

end.
