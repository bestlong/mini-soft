{*******************************************************************************
  ����: dmzn@163.com 2011-6-7
  ����: ��Ʒ����
*******************************************************************************}
unit UFrameChuKu;

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
  TfFrameChuKu = class(TfFrameNormal)
    EditName: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item2: TdxLayoutItem;
    dxLayout1Item5: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure EditWeekPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
    FStart,FEnd: TDate;
    //ʱ������
  protected
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //���෽��
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, UDataModule, UFormBase,
  USysBusiness, UFormDateFilter;

class function TfFrameChuKu.FrameID: integer;
begin
  Result := cFI_FrameChuKu;
end;

procedure TfFrameChuKu.OnCreateFrame;
begin
  inherited;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameChuKu.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

//Desc: �ر�
procedure TfFrameChuKu.BtnExitClick(Sender: TObject);
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
function TfFrameChuKu.InitFormDataSQL(const nWhere: string): string;
begin
  EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);

  Result := 'Select D_Name,G_Name,G_Unit,ck.* From %s ck ' +
            ' Left Join %s bm On bm.D_ID=ck.C_Depart ' +
            ' Left Join %s wp On wp.G_ID=ck.C_Goods ';
  Result := Format(Result, [sTable_ChuKu, sTable_Department, sTable_Goods]);

  Result := Result + 'Where (C_Date>=''%s'' and C_Date <''%s'')';
  Result := Format(Result, [Date2Str(FStart), Date2Str(FEnd + 1)]);

  if nWhere <> '' then
    Result := Result + ' And (' + nWhere + ')';
  //xxxxx
end;

//Desc: ��Ʒ����
procedure TfFrameChuKu.BtnAddClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  nParam.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormChuKu, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: ִ�в�ѯ
procedure TfFrameChuKu.EditIDPropertiesButtonClick(Sender: TObject;
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

//Desc: ѡ��ʱ��
procedure TfFrameChuKu.EditWeekPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

initialization
  gControlManager.RegCtrl(TfFrameChuKu, TfFrameChuKu.FrameID);
end.
