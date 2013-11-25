{*******************************************************************************
  ����: dmzn@163.com 2009-10-13
  ����: ��������
*******************************************************************************}
unit UFormJSItem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, cxMemo, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, dxLayoutControl, StdCtrls;

type
  TfFormJSItem = class(TfFormNormal)
    EditTruck: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    EditStock: TcxComboBox;
    dxLayout1Item5: TdxLayoutItem;
    EditSID: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditWeight: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditNum: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditMemo: TcxMemo;
    dxLayout1Item13: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    cxLabel1: TcxLabel;
    dxLayout1Item14: TdxLayoutItem;
    EditCus: TcxComboBox;
    dxLayout1Item15: TdxLayoutItem;
    EditBC: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    dxLayout1Group4: TdxLayoutGroup;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditStockPropertiesChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EditCusKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditWeightPropertiesChange(Sender: TObject);
    procedure EditNumPropertiesChange(Sender: TObject);
  private
    { Private declarations }
  protected
    FRecordID: string;
    //��¼���
    FPerWeight: Double;
    //����
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
    procedure GetSaveSQLList(const nList: TStrings); override;
    //���ຯ��
    procedure InitFormData;
    //��ʼ������
    procedure SetCtrlStatus(const nEnable: Boolean);
    //����״̬
    procedure GetData(Sender: TObject; var nData: string);
    //��ȡ����
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UAdjustForm, UDataModule,  USysConst, USysDB,
  UFormBase, UFormCtrl, UFrameBase;

var
  gForm: TfFormJSItem = nil;

//------------------------------------------------------------------------------
class function TfFormJSItem.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  case nP.FCommand of
    cCmd_AddData:
      with TfFormJSItem.Create(Application) do
      begin
        Caption := '������¼ - ���';
        InitFormData;

        nP.FCommand := cCmd_ModalResult;
        nP.FParamA := ShowModal;
        Free;
      end;
   cCmd_EditData:
    with TfFormJSItem.Create(Application) do
    begin
      Caption := '�����¼ - �޸�';
      FRecordID := nP.FParamA;
      InitFormData;

      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
      Free;
    end;
   cCmd_ViewData:
    begin
      if not Assigned(gForm) then
      begin
        gForm := TfFormJSItem.Create(Application);
        gForm.Caption := '�����¼ - �鿴';
        gForm.FormStyle := fsStayOnTop;
        gForm.BtnOK.Visible := False;
      end;

      with gForm do
      begin
        FRecordID := nP.FParamA;
        InitFormData;
        if not gForm.Showing then gForm.Show;
      end;
    end;
   cCmd_FormClose:
    begin
      if Assigned(gForm) then FreeAndNil(gForm);
    end;
  end;
end;

class function TfFormJSItem.FormID: integer;
begin
  Result := cFI_FormJSItem;
end;

procedure TfFormJSItem.FormCreate(Sender: TObject);
begin
  FRecordID := '';
  ResetHintAllCtrl(Self, 'T', sTable_JSLog);
  
  LoadFormConfig(Self);
  inherited;
end;

procedure TfFormJSItem.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveFormConfig(Self);
  gForm := nil;
  Action := caFree;
  ReleaseCtrlData(Self);
end;

//------------------------------------------------------------------------------
//Desc: �������״̬
procedure TfFormJSItem.SetCtrlStatus(const nEnable: Boolean);
begin
  EditSID.Enabled := nEnable;
  EditWeight.Enabled := nEnable;
  EditNum.Enabled := nEnable;
end;

//Desc: ��ʼ������
procedure TfFormJSItem.InitFormData;
var nStr: string;
begin
  SetCtrlStatus(False);
  
  if EditTruck.Properties.Items.Count < 1 then
  begin
    nStr := 'Select Distinct T_TruckNo From %s Order By T_TruckNo';
    nStr := Format(nStr, [sTable_TruckInfo]);
    FDM.FillStringsData(EditTruck.Properties.Items, nStr);
  end;

  if EditCus.Properties.Items.Count < 1 then
  begin
    nStr := 'Select Distinct C_Name From %s Order By C_Name';
    nStr := Format(nStr, [sTable_Customer]);
    FDM.FillStringsData(EditCus.Properties.Items, nStr);
  end;

  if EditStock.Properties.Items.Count < 1 then
  begin
    nStr := 'S_ID=Select S_ID,S_Name From %s Order By S_ID';
    nStr := Format(nStr, [sTable_StockType]);

    FDM.FillStringsData(EditStock.Properties.Items, nStr, -1, '��');
    AdjustStringsItem(EditStock.Properties.Items, False);
  end;

  if FRecordID <> '' then
  begin
    nStr := 'Select * From %s Where L_ID=%s';
    nStr := Format(nStr, [sTable_JSLog, FRecordID]);
    LoadDataToForm(FDM.QuerySQL(nStr), Self, sTable_JSLog);
    
    EditCus.Text := FDM.SqlQuery.FieldByName('L_Customer').AsString;
    EditTruck.Text := FDM.SqlQuery.FieldByName('L_TruckNo').AsString;
  end;
end;

//Desc: ѡ��Ʒ��
procedure TfFormJSItem.EditStockPropertiesChange(Sender: TObject);
var nStr: string;
begin
  FPerWeight := 0;
  SetCtrlStatus(False);
  if EditStock.ItemIndex < 0 then Exit;

  nStr := 'Select S_Weight From %s Where S_ID=''%s''';
  nStr := Format(nStr, [sTable_StockType, GetCtrlData(EditStock)]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    FPerWeight := Fields[0].AsFloat;
    if FPerWeight <=0 then
    begin
      ShowMsg('��Ʒ�ִ��ز�������!', sHint); Exit;
    end;
  end else
  begin
    ShowMsg('��Ʒ������Ч', sHint); Exit;
  end;

  SetCtrlStatus(True);
end;

//Desc: �������
procedure TfFormJSItem.EditWeightPropertiesChange(Sender: TObject);
var nStr: string;
    nInt: integer;
begin
  if not EditWeight.IsFocused then Exit;
  //need focus first

  nStr := EditWeight.Text;
  nInt := Length(nStr);
  if (nInt > 0) and (nStr[nInt] = '.') then Exit;

  if FPerWeight > 0 then
  if IsNumber(EditWeight.Text, True) then
  begin
    nInt := Round(StrToFloat(EditWeight.Text) * 1000 / FPerWeight);
    EditNum.Text := IntToStr(nInt);
  end else
  begin
    EditWeight.Text := '0';
    EditWeight.SelectAll;
  end;
end;

//Desc: �������
procedure TfFormJSItem.EditNumPropertiesChange(Sender: TObject);
var nStr: string;
    nInt: integer;
    nValue: Double;
begin
  if not EditNum.IsFocused then Exit;
  //need focus first

  nStr := EditNum.Text;
  nInt := Length(nStr);
  if (nInt > 0) and (nStr[nInt] = '.') then Exit;

  if FPerWeight > 0 then
  if IsNumber(EditNum.Text, False) then
  begin
    nValue := StrToInt(EditNum.Text) * FPerWeight / 1000;
    //EditWeight.Text := FloatToStr(nValue);
  end else
  begin
    EditNum.Text := '0';
    EditNum.SelectAll;
  end;
end;

//Desc: �����ͻ�
procedure TfFormJSItem.EditCusKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var nStr: string;
begin
  if Key = 13 then
  begin
    Key := 0;
    nStr := 'Select C_Name From %s Where C_ID Like ''%%%s%%'' Or ' +
            'C_Name Like ''%%%s%%'' Or C_PY Like ''%%%s%%''';
    nStr := Format(nStr, [sTable_Customer, EditCus.Text, EditCus.Text, EditCus.Text]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      EditCus.Text := Fields[0].AsString;
    end;
  end;
end;

//Desc: ��֤Sender�����Ƿ���Ч
function TfFormJSItem.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
begin
  Result := True;

  if Sender = EditTruck then
  begin
    Result := Length(EditTruck.Text) >= 3;
    nHint := '���ƺ�Ӧ����3λ';
  end else

  if Sender = EditStock then
  begin
    Result := EditStock.ItemIndex > -1;
    nHint := '��ѡ����Ч��ˮ��Ʒ��';
  end else

  if Sender = EditWeight then
  begin
    Result := IsNumber(EditWeight.Text, True) and (StrToFloat(EditWeight.Text) > 0);
    nHint := '��������Ч�������';
  end else

  if Sender = EditNum then
  begin
    Result := IsNumber(EditNum.Text, False) and (StrToInt(EditNum.Text) >= 0);
    nHint := '��������Ч�Ĵ���';
  end;
end;

//Desc: ��ȡSender������
procedure TfFormJSItem.GetData(Sender: TObject; var nData: string);
begin
  if Sender = EditTruck then nData := EditTruck.Text else
  if Sender = EditCus then nData := EditCus.Text;
end;

//Desc: ����SQL���
procedure TfFormJSItem.GetSaveSQLList(const nList: TStrings);
var nStr: string;
    nExt: TStrings;
begin
  nExt := TStringList.Create;
  try
    nExt.Add('L_PValue=0');
    //nExt.Add('L_DaiShu=0');

    if FRecordID = '' then
    begin
      nExt.Add('L_Date=''' + DateTime2Str(Now) + '''');
      nExt.Add('L_Man=''' + gSysParam.FUserID + '''');
      nExt.Add('L_HasDone=''' + sFlag_No + '''');

      nStr := MakeSQLByForm(Self, sTable_JSLog, '', True, GetData, nExt);
      nList.Add(nStr);
    end else
    begin
      nStr := 'L_ID=' + FRecordID;
      nStr := MakeSQLByForm(Self, sTable_JSLog, nStr, False, GetData, nExt);
      nList.Add(nStr);
    end;
  finally
    nExt.Free;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormJSItem, TfFormJSItem.FormID);
end.
