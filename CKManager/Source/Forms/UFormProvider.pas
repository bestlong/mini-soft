{*******************************************************************************
  ����: dmzn@163.com 2011-6-7
  ����: ��Ӧ�̹���
*******************************************************************************}
unit UFormProvider;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, dxLayoutControl, StdCtrls, cxControls, cxMemo,
  cxButtonEdit, cxLabel, cxTextEdit, cxContainer, cxEdit, cxMaskEdit,
  cxDropDownEdit, cxCalendar, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, cxMCListBox;

type
  TfFormProvider = class(TfFormNormal)
    dxLayout1Item7: TdxLayoutItem;
    EditName: TcxTextEdit;
    dxLayout1Group2: TdxLayoutGroup;
    dxLayout1Item3: TdxLayoutItem;
    InfoItems: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    InfoList1: TcxMCListBox;
    dxLayout1Item5: TdxLayoutItem;
    EditInfo: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    BtnAdd: TButton;
    dxLayout1Item8: TdxLayoutItem;
    BtnDel: TButton;
    dxLayout1Group3: TdxLayoutGroup;
    dxLayout1Group4: TdxLayoutGroup;
    dxLayout1Group5: TdxLayoutGroup;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item10: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item11: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item12: TdxLayoutItem;
    dxLayout1Group6: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FRecordID: string;
    //��¼���
    procedure InitFormData(const nID: string);
    //��������
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UFormCtrl, UAdjustForm, UFormBase, UMgrControl, USysDB, 
  USysConst, UDataModule, USysBusiness, USysGrid;

var
  gForm: TfFormProvider = nil;
  //ȫ��ʹ��

class function TfFormProvider.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  case nP.FCommand of
   cCmd_AddData:
    with TfFormProvider.Create(Application) do
    begin
      FRecordID := '';
      Caption := '��Ӧ�� - ���';

      InitFormData('');
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
      Free;
    end;
   cCmd_EditData:
    with TfFormProvider.Create(Application) do
    begin
      Caption := '��Ӧ�� - �޸�';
      FRecordID := nP.FParamA;

      InitFormData(FRecordID);
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
      Free;
    end;
   cCmd_ViewData:
    begin
      if not Assigned(gForm) then
      begin
        gForm := TfFormProvider.Create(Application);
        with gForm do
        begin
          Caption := '��Ӧ�� - �鿴';
          FormStyle := fsStayOnTop; 
          BtnOK.Visible := False;
        end;
      end;

      with gForm  do
      begin
        FRecordID := nP.FParamA;
        InitFormData(FRecordID);
        if not Showing then Show;
      end;
    end;
   cCmd_FormClose:
    begin
      if Assigned(gForm) then FreeAndNil(gForm);
    end;
  end;
end;

class function TfFormProvider.FormID: integer;
begin
  Result := cFI_FormProvider;
end;

procedure TfFormProvider.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadMCListBoxConfig(Name, InfoList1, nIni);
    ResetHintAllForm(Self, 'T', sTable_Provider);
  finally
    nIni.Free;
  end;
end;

procedure TfFormProvider.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SaveMCListBoxConfig(Name, InfoList1, nIni);
  finally
    nIni.Free;
  end;

  if not (fsModal in FormState) then
  begin
    gForm := nil;
    Action := caFree;
  end;
  ReleaseCtrlData(Self);
end;

//------------------------------------------------------------------------------
procedure TfFormProvider.InitFormData(const nID: string);
var nStr: string;
begin
  if nID <> '' then
  begin
    nStr := 'Select * From %s Where P_ID=''%s''';
    nStr := Format(nStr, [sTable_Provider, nID]);

    LoadDataToCtrl(FDM.QueryTemp(nStr), Self);
    LoadItemExtInfo(InfoList1.Items, sFlag_ProviderItem, nID);
  end;
end;

//Desc: ��֤����
function TfFormProvider.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
begin
  Result := True;

  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    Result := EditName.Text <> '';
    nHint := '����д��Ч������';
  end;
end;

procedure TfFormProvider.BtnAddClick(Sender: TObject);
begin
  InfoItems.Text := Trim(InfoItems.Text);
  if InfoItems.Text = '' then
  begin
    InfoItems.SetFocus;
    ShowMsg('����д��Ч����Ϣ��', sHint); Exit;
  end;

  EditInfo.Text := Trim(EditInfo.Text);
  if EditInfo.Text = '' then
  begin
    EditInfo.SetFocus;
    ShowMsg('����д��Ч����Ϣ����', sHint); Exit;
  end;

  InfoList1.Items.Add(InfoItems.Text + InfoList1.Delimiter + EditInfo.Text);
  ActiveControl := InfoItems;
end;

procedure TfFormProvider.BtnDelClick(Sender: TObject);
var nIdx: integer;
begin
  if InfoList1.ItemIndex < 0 then
  begin
    ShowMsg('��ѡ��Ҫɾ��������', sHint); Exit;
  end;

  nIdx := InfoList1.ItemIndex;
  InfoList1.Items.Delete(InfoList1.ItemIndex);

  if nIdx >= InfoList1.Count then Dec(nIdx);
  InfoList1.ItemIndex := nIdx;
  ShowMsg('��Ϣ����ɾ��', sHint);
end;

//Desc: ����
procedure TfFormProvider.BtnOKClick(Sender: TObject);
var nList: TStrings;
    i: integer;
    nStr,nSQL, nId: string;
begin
  if not IsDataValid then Exit;

  nList := TStringList.Create;
  nList.Text := Format('P_PY=''%s''', [GetPinYinOfStr(EditName.Text)]);

  if FRecordID = '' then
  begin
     nSQL := MakeSQLByForm(Self, sTable_Provider, '', True, nil, nList);
  end else
  begin
    nStr := 'P_ID=''' + FRecordID + '''';
    nSQL := MakeSQLByForm(Self, sTable_Provider, nStr, False, nil, nList);
  end;

  nList.Free;
  FDM.ADOConn.BeginTrans;
  try
    FDM.ExecuteSQL(nSQL);

    if FRecordID = '' then
    begin
      i := FDM.GetFieldMax(sTable_Provider, 'R_ID');
      nID := FDM.GetSerialID2('GY', sTable_Provider, 'R_ID', 'P_ID', i);

      nSQL := 'Update %s Set P_ID=''%s'' Where R_ID=%d';
      nSQL := Format(nSQL, [sTable_Provider, nID, i]);
      FDM.ExecuteSQL(nSQL);
    end else nID := FRecordID;

    SaveItemExtInfo(InfoList1.Items, sFlag_ProviderItem, nID, FRecordID <> '');
    //ext info

    FDM.ADOConn.CommitTrans;
    ModalResult := mrOK;
    ShowMsg('�����ѱ���', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('���ݱ���ʧ��', sError);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormProvider, TfFormProvider.FormID);
end.
