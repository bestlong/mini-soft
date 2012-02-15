{*******************************************************************************
  ����: dmzn@163.com 2009-09-13
  ����: Ʒ�ֹ���
*******************************************************************************}
unit UFormStockType;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, dxLayoutControl, StdCtrls, cxControls, 
  cxMemo, cxTextEdit, cxDropDownEdit, cxContainer, cxEdit, cxMaskEdit,
  cxCalendar, cxGraphics, cxMCListBox, cxImage, cxButtonEdit;

type
  TfFormStockType = class(TfFormNormal)
    EditName: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditMemo: TcxMemo;
    dxLayout1Item6: TdxLayoutItem;
    EditID: TcxButtonEdit;
    dxLayout1Item12: TdxLayoutItem;
    EditType: TcxComboBox;
    dxLayout1Item13: TdxLayoutItem;
    EditWeight: TcxTextEdit;
    dxLayout1Item14: TdxLayoutItem;
    EditLevel: TcxTextEdit;
    dxLayout1Item16: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    dxLayout1Group3: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  protected
    FRecordID: string;
    //��¼���
    FPrefixID: string;
    //ǰ׺���
    FIDLength: integer;
    //ǰ׺����
    procedure GetSaveSQLList(const nList: TStrings); override;
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
    //���෽��
    procedure InitFormData(const nID: string);
    //��ʼ������
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}

uses
  IniFiles, UMgrControl, UAdjustForm, UFormCtrl, ULibFun, UDataModule, 
  UFormBase, USysFun, USysConst, USysDB;

var
  gForm: TfFormStockType = nil;
  
//------------------------------------------------------------------------------
class function TfFormStockType.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  case nP.FCommand of
   cCmd_AddData:
    with TfFormStockType.Create(Application) do
    begin
      FRecordID := '';
      Caption := 'ˮ��Ʒ�� - ���';

      InitFormData('');
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
      Free;
    end;
   cCmd_EditData:
    with TfFormStockType.Create(Application) do
    begin
      FRecordID := nP.FParamA;
      Caption := 'ˮ��Ʒ�� - �޸�';

      InitFormData(FRecordID);
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
      Free;
    end;
   cCmd_ViewData:
    begin
      if not Assigned(gForm) then
      begin
        gForm := TfFormStockType.Create(Application);
        gForm.Caption := 'ˮ��Ʒ�� - �鿴';
        gForm.FormStyle := fsStayOnTop;
        gForm.BtnOK.Visible := False;
      end;

      with gForm do
      begin
        FRecordID := nP.FParamA;
        InitFormData(FRecordID);
        if not gForm.Showing then gForm.Show;
      end;
    end;
   cCmd_FormClose:
    begin
      if Assigned(gForm) then FreeAndNil(gForm);
    end;
  end;
end;

class function TfFormStockType.FormID: integer;
begin
  Result := cFI_FormStockType;
end;

procedure TfFormStockType.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self);
    FPrefixID := nIni.ReadString(Name, 'IDPrefix', 'PZ');
    FIDLength := nIni.ReadInteger(Name, 'IDLength', 8);
  finally
    nIni.Free;
  end;

  AdjustCtrlData(Self);
  ResetHintAllCtrl(Self, 'T', sTable_StockType);
end;

procedure TfFormStockType.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self);
  finally
    nIni.Free;
  end;

  gForm := nil;
  Action := caFree;
  ReleaseCtrlData(Self);
end;

//------------------------------------------------------------------------------
procedure TfFormStockType.InitFormData(const nID: string);
var nStr: string;
begin
 if nID <> '' then
  begin
    nStr := 'Select * From %s Where S_ID=''%s''';
    nStr := Format(nStr, [sTable_StockType, nID]);
    LoadDataToCtrl(FDM.QueryTemp(nStr), Self, '');  
  end;
end;

//Desc: ������
procedure TfFormStockType.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  EditID.Text := FDM.GetRandomID(FPrefixID, FIDLength);
end;

//Desc: ��֤����
function TfFormStockType.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var nStr: string;
begin
  Result := True;

  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    Result := EditID.Text <> '';
    nHint := '����д��Ч�ı��';

    if Result and (FRecordID = '') then
    begin
      nStr := 'Select Count(*) From %s Where S_ID=''%s''';
      nStr := Format(nStr, [sTable_StockType, EditID.Text]);

      Result := FDM.QueryTemp(nStr).Fields[0].AsInteger < 1;
      nHint := '�ñ�ŵ�Ʒ���Ѿ�����';
    end;
  end else

  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    Result := EditName.Text <> '';
    nHint := '����д��Ч��Ʒ������';
  end else

  if Sender = EditType then
  begin
    Result := EditType.ItemIndex > -1;
    nHint := '��ѡ����Ч������';
  end;

  if Sender = EditWeight then
  begin
    Result := IsNumber(EditWeight.Text, True);
    nHint := '��������Ч�Ĵ���';
  end;
end;

//Desc: �����������
procedure TfFormStockType.GetSaveSQLList(const nList: TStrings);
var nStr: string;
begin
  if FRecordID = '' then
  begin
    nStr := MakeSQLByForm(Self, sTable_StockType, '', True);
    nList.Add(nStr);
  end else
  begin
    nStr := 'S_ID=''' + FRecordID + '''';
    nStr := MakeSQLByForm(Self, sTable_StockType, nStr, False);
    nList.Add(nStr);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormStockType, TfFormStockType.FormID);
end.
