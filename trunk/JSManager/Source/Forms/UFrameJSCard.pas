{*******************************************************************************
  ����: dmzn@163.com 2009-09-13
  ����: ����ſ�
*******************************************************************************}
unit UFrameJSCard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, dxLayoutControl, cxMaskEdit,
  cxButtonEdit, cxTextEdit, ADODB, cxContainer, cxLabel, cxGridLevel,
  cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, ComCtrls, ToolWin, Menus,
  cxLookAndFeels, cxLookAndFeelPainters, UBitmapPanel, cxSplitter,
  dxSkinsCore, dxSkinsDefaultPainters;

type
  TfFrameCard = class(TfFrameNormal)
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    EditStock: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditCus: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    cxTextEdit5: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    //ʱ������
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    {*��ѯSQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormDateFilter, UFormInputbox, UFormBase,
  USysFun, USysConst, USysDB;

class function TfFrameCard.FrameID: integer;
begin
  Result := cFI_FrameCard;
end;

procedure TfFrameCard.OnCreateFrame;
begin
  inherited;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameCard.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

//------------------------------------------------------------------------------
function TfFrameCard.InitFormDataSQL(const nWhere: string): string;
begin
  EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);

  Result := 'Select * From %s Where (L_BillDate>=''%s'') And (L_BillDate<''%s'')';
  Result := Format(Result, [sTable_JSItem, Date2Str(FStart), Date2Str(FEnd+1)]);

  if nWhere <> '' then
    Result := Result + ' And (' + nWhere + ')';
  //xxxxx
end;

//Desc: ����ɸѡ
procedure TfFrameCard.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

//Desc: ִ�в�ѯ
procedure TfFrameCard.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditTruck then
  begin
    FWhere := 'L_TruckNo Like ''%' + EditTruck.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditStock then
  begin
    FWhere := 'L_StockID Like ''%%%s%%'' Or L_Stock Like ''%%%s%%''';
    FWhere := Format(FWhere, [EditStock.Text, EditStock.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditCus then
  begin
    FWhere := 'L_Customer Like ''%' + EditCus.Text + '%''';
    InitFormData(FWhere);
  end;
end;

//------------------------------------------------------------------------------
//Desc: ������Ч��¼
procedure TfFrameCard.BtnEditClick(Sender: TObject);
var nStr: string;
begin
  nStr := '������������24Сʱ�ĵ���,Ҫ������?';
  if not QueryDlg(nStr, sAsk) then Exit;

  nStr := 'Delete From %s Where L_BillDate<%s-1';
  nStr := Format(nStr, [sTable_JSItem, sField_SQLServer_Now]);
  FDM.ExecuteSQL(nStr);

  InitFormData(FWhere);
  ShowMsg('�������', sHint);
end;

//Desc: ɾ��������
procedure TfFrameCard.BtnDelClick(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫɾ���ļ�¼', sHint); Exit;
  end;

  nStr := SQLQuery.FieldByName('L_Customer').AsString;
  if not QueryDlg('ȷ��Ҫɾ���ͻ�[ ' + nStr + ' ]�ķ�������?', sAsk) then Exit;

  nStr := 'Delete From %s Where L_Bill=''%s''';
  nStr := Format(nStr, [sTable_JSItem, SQLQuery.FieldByName('L_Bill').AsString]);
  FDM.ExecuteSQL(nStr);

  InitFormData(FWhere);
  ShowMsg('ɾ���ɹ�', sHint);
end;

procedure TfFrameCard.BtnAddClick(Sender: TObject);
var nStr,nCard: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�쿨�ļ�¼', sHint); Exit;
  end;

  nCard := '';
  if not ShowInputBox('������ſ���:', '�쿨', nCard, 15) then Exit;

  nStr := Format('Update %s Set L_Card='''' Where L_Card=''%s''',
          [sTable_JSItem, nCard]);
  FDM.ExecuteSQL(nStr);

  nStr := Format('Update %s Set L_Card=''%s'' Where L_Bill=''%s''',
          [sTable_JSItem, nCard, SQLQuery.FieldByName('L_Bill').AsString]);
  //xxxxx

  FDM.ExecuteSQL(nStr);
  InitFormData(FWhere);
end;

initialization
  gControlManager.RegCtrl(TfFrameCard, TfFrameCard.FrameID);
end.
