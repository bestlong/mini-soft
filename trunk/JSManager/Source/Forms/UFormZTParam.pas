{*******************************************************************************
  ����: dmzn 2009-9-13
  ����: վ̨����
*******************************************************************************}
unit UFormZTParam;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, StdCtrls, ExtCtrls, dxLayoutControl, cxContainer, cxEdit,
  cxTextEdit, cxControls, cxMemo, UFormBase, cxGraphics, cxMaskEdit,
  cxDropDownEdit;

type
  TfFormZTParam = class(TBaseForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Group1: TdxLayoutGroup;
    EditDesc: TcxTextEdit;
    dxLayoutControl1Item2: TdxLayoutItem;
    BtnExit: TButton;
    dxLayoutControl1Item7: TdxLayoutItem;
    BtnOK: TButton;
    dxLayoutControl1Item8: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    PortList1: TcxComboBox;
    dxLayoutControl1Item1: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditDescPropertiesChange(Sender: TObject);
    procedure PortList1PropertiesChange(Sender: TObject);
  private
    { Private declarations }
    procedure InitFormData;
    {*��ʼ������*}
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

function LoadZTList(const nList: TStrings; const nAll: Boolean): Boolean;
//��ں���

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, UAdjustForm, USysConst, USysFun, USysDB,
  USysPopedom;

ResourceString
  sZTParam = 'ZTParam';

//------------------------------------------------------------------------------
class function TfFormZTParam.CreateForm;
begin
  Result := nil;

  with TfFormZTParam.Create(Application) do
  begin
    InitFormData;
    BtnOK.Enabled := gPopedomManager.HasPopedom(nPopedom, sPopedom_Edit);

    ShowModal;
    Free;
  end;
end;

class function TfFormZTParam.FormID: integer;
begin
  Result := cFI_FormZTParam;
end;

procedure TfFormZTParam.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  ReleaseCtrlData(Self);
end;

//------------------------------------------------------------------------------
//Desc: ��ȡջ̨�б�
function LoadZTList(const nList: TStrings; const nAll: Boolean): Boolean;
var nStr: string;
    nIdx: integer;
    nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    GetComPortNames(nList);
    Result := nList.Count > 0;

    nIdx := 0;
    while nIdx < nList.Count do
    begin
      nStr := nIni.ReadString(sZTParam, nList[nIdx], '��');
      if (nStr = '��') and (not nAll) then
      begin
        nList.Delete(nIdx); Continue;
      end;

      nList[nIdx] := Format('%s=%s.%s', [nList[nIdx], nList[nIdx], nStr]);
      Inc(nIdx);
    end;
  finally
    nIni.Free;
  end;
end;

//Desc: ��ʼ����������
procedure TfFormZTParam.InitFormData;
begin
  if LoadZTList(PortList1.Properties.Items, True) then
       AdjustStringsItem(PortList1.Properties.Items, False)
  else ShowMsg('��ȡCOM�˿��б�ʧ��', sHint);
end;

//Desc: �޸Ķ˿�����
procedure TfFormZTParam.EditDescPropertiesChange(Sender: TObject);
var nStr: string;
    nIdx: integer;
begin
  if EditDesc.Focused and (PortList1.ItemIndex > -1) then
  begin
    nIdx := PortList1.ItemIndex;
    nStr := GetCtrlData(PortList1) + '.' + Trim(EditDesc.Text);

    PortList1.Properties.Items[nIdx] := nStr;
    PortList1.Text := nStr;
    PortList1.ItemIndex := nIdx;
  end;
end;

//Desc: ��ȡ����
procedure TfFormZTParam.PortList1PropertiesChange(Sender: TObject);
var nStr: string;
begin
  if PortList1.Focused and (PortList1.ItemIndex > -1) then
  begin
    nStr := PortList1.Properties.Items[PortList1.ItemIndex];
    System.Delete(nStr, 1, Pos('.', nStr));
    EditDesc.Text := nStr;
  end;
end;

//Desc: ����
procedure TfFormZTParam.BtnOKClick(Sender: TObject);
var nStr: string;
    nIni: TIniFile;
    i,nCount: integer;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    with PortList1.Properties do
    begin
      nCount := Items.Count - 1;

      for i:=0 to nCount do
      begin
        nStr := Items[i];
        System.Delete(nStr, 1, Pos('.', nStr));
        nIni.WriteString(sZTParam, GetStringsItemData(Items, i), nStr);
      end;
    end;
  finally
    nIni.Free;
  end;

  ModalResult := mrOK;
  ShowMsg('�����ѱ���', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormZTParam, TfFormZTParam.FormID);
end.
