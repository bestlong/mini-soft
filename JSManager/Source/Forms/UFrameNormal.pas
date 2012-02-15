{*******************************************************************************
  ����: dmzn@163.com 2009-06-11
  ����: �ṩ���ù��ܵĻ�����
*******************************************************************************}
unit UFrameNormal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  USysFun, IniFiles, cxButtonEdit, cxStyles, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, ADODB,
  cxContainer, cxLabel, UBitmapPanel, cxSplitter, dxLayoutControl,
  cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, UFrameBase;

type
  TfFrameNormal = class(TBaseFrame)
    ToolBar1: TToolBar;
    BtnAdd: TToolButton;
    BtnEdit: TToolButton;
    BtnDel: TToolButton;
    S1: TToolButton;
    BtnRefresh: TToolButton;
    S2: TToolButton;
    BtnPrint: TToolButton;
    BtnPreview: TToolButton;
    BtnExport: TToolButton;
    S3: TToolButton;
    BtnExit: TToolButton;
    cxGrid1: TcxGrid;
    cxView1: TcxGridDBTableView;
    cxLevel1: TcxGridLevel;
    dxLayout1: TdxLayoutControl;
    dxGroup1: TdxLayoutGroup;
    GroupSearch1: TdxLayoutGroup;
    GroupDetail1: TdxLayoutGroup;
    SQLQuery: TADOQuery;
    DataSource1: TDataSource;
    cxSplitter1: TcxSplitter;
    TitlePanel1: TZnBitmapPanel;
    TitleBar: TcxLabel;
    procedure BtnRefreshClick(Sender: TObject);
    procedure BtnExportClick(Sender: TObject);
    procedure BtnPrintClick(Sender: TObject);
    procedure BtnPreviewClick(Sender: TObject);
    procedure cxView1FocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure ToolBar1AdvancedCustomDraw(Sender: TToolBar;
      const ARect: TRect; Stage: TCustomDrawStage;
      var DefaultDraw: Boolean);
    procedure BtnExitClick(Sender: TObject);
  private
    { Private declarations }
  protected
    FBarImage: TBitmap;
    {*������*}
    FWhere: string;
    {*��������*}
    FShowDetailInfo: Boolean;
    {*��ʾ������Ϣ*}
    procedure SetZOrder(TopMost: Boolean); override;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    procedure OnLoadPopedom; override;
    {*���ຯ��*}
    procedure OnLoadGridConfig(const nIni: TIniFile); virtual;
    procedure OnSaveGridConfig(const nIni: TIniFile); virtual;
    {*�������*}
    procedure OnInitFormData(var nDefault: Boolean; const nWhere: string = '';
     const nQuery: TADOQuery = nil); virtual;
    procedure InitFormData(const nWhere: string = '';
     const nQuery: TADOQuery = nil); virtual;
    function InitFormDataSQL(const nWhere: string): string; virtual;
    procedure AfterInitFormData; virtual;
    {*��������*}
    procedure GetData(Sender: TObject; var nData: string); virtual;
    function SetData(Sender: TObject; const nData: string): Boolean; virtual;
    {*��д����*}
  public
    { Public declarations }
  published
    procedure OnCtrlKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState); virtual;
    procedure OnCtrlKeyPress(Sender: TObject; var Key: Char); virtual;
    {*��������*}
  end;

procedure SetFrameChangeEvent(const nCallBack: TControlChangeEvent);
//���ñ䶯�¼�

implementation

{$R *.dfm}

uses
  ULibFun, UAdjustForm, UFormWait, UFormCtrl, UDataModule, USysConst, USysGrid,
  USysDataDict, USysPopedom, USysDB;

var
  gFrameChange: TControlChangeEvent = nil;
  //Frame�䶯

procedure SetFrameChangeEvent(const nCallBack: TControlChangeEvent);
begin
  gFrameChange := nCallBack;
end;

//------------------------------------------------------------------------------
procedure TfFrameNormal.OnCreateFrame;
var nStr: string;
    nIni: TIniFile;
begin
  Name := MakeFrameName(FrameID);
  FWhere := '';
  FShowDetailInfo := True;

  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    nStr := gPath + sImageDir + 'title.bmp';
    nStr := ReplaceGlobalPath(nIni.ReadString(Name, 'TitleImage', nStr));
    if FileExists(nStr) then TitlePanel1.LoadBitmap(nStr);

    nStr := gPath + sImageDir + 'bar.bmp';
    nStr := ReplaceGlobalPath(nIni.ReadString(Name, 'BarImage', nStr));
    if FileExists(nStr) then
    begin
      FBarImage := TBitmap.Create;
      FBarImage.LoadFromFile(nStr);
    end else FBarImage := nil;

    dxLayout1.Height := nIni.ReadInteger(Name, 'InfoPanelH', dxLayout1.Height);
    if nIni.ReadBool(Name, 'QuickInfo', True) then
         cxSplitter1.State := ssOpened
    else cxSplitter1.State := ssClosed;

    nIni.Free;
  except
    nIni.Free;
    FreeAndNil(FBarImage);
  end;

  if Assigned(gFrameChange) then
    gFrameChange(TitleBar.Caption, Self, fsNew);
  //xxxxx
end;

procedure TfFrameNormal.OnDestroyFrame;
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    nIni.WriteBool(Name, 'QuickInfo', cxSplitter1.State = ssOpened);
    if cxSplitter1.State = ssClosed then cxSplitter1.State := ssOpened;
    
    nIni.WriteInteger(Name, 'InfoPanelH', dxLayout1.Height);
    SaveUserDefineTableView(Name, cxView1, nIni);
    OnSaveGridConfig(nIni);
  finally
    nIni.Free;
  end;

  FreeAndNil(FBarImage);
  if Assigned(gFrameChange) then
    gFrameChange(TitleBar.Caption, Self, fsFree);
  //xxxxx
end;

//Desc: ���Z��λ�ñ䶯
procedure TfFrameNormal.SetZOrder(TopMost: Boolean);
begin
  inherited;
  if Assigned(gFrameChange) then
    gFrameChange(TitleBar.Caption, Self, fsActive);
  //xxxxx
end;

//Desc: ��ȡȨ��
procedure TfFrameNormal.OnLoadPopedom;
var nStr: string;
    nIni: TIniFile;
begin
  if not gSysParam.FIsAdmin then
  begin
    nStr := gPopedomManager.FindUserPopedom(gSysParam.FUserID, PopedomItem);
    BtnAdd.Enabled := Pos(sPopedom_Add, nStr) > 0;
    BtnEdit.Enabled := Pos(sPopedom_Edit, nStr) > 0;
    BtnDel.Enabled := Pos(sPopedom_Delete, nStr) > 0;
    BtnPrint.Enabled := Pos(sPopedom_Print, nStr) > 0;
    BtnPreview.Enabled := Pos(sPopedom_Preview, nStr) > 0;
    BtnExport.Enabled := Pos(sPopedom_Export, nStr) > 0;
  end;

  Visible := False;
  Application.ProcessMessages;
  ShowWaitForm(ParentForm, '��ȡ����');

  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    gSysEntityManager.BuildViewColumn(cxView1, PopedomItem);
    //��ʼ����ͷ
    InitTableView(Name, cxView1, nIni);
    //��ʼ������˳��
    OnLoadGridConfig(nIni);
    //������չ��ʼ��
    InitFormData;
    //��ʼ������
  finally
    nIni.Free;
    Visible := True;
    CloseWaitForm;
  end;
end;

//------------------------------------------------------------------------------
procedure TfFrameNormal.OnLoadGridConfig(const nIni: TIniFile);
begin

end;

procedure TfFrameNormal.OnSaveGridConfig(const nIni: TIniFile);
begin

end;

procedure TfFrameNormal.GetData(Sender: TObject; var nData: string);
begin

end;

//Desc: ����Sender������ΪnData
function TfFrameNormal.SetData(Sender: TObject; const nData: string): Boolean;
var nStr: string;
    nObj: TObject;
    nRIdx,nCIdx: integer;
    nTable,nField: string;
begin
  Result := False;

  if (cxView1.Controller.SelectedRowCount > 0) and (Sender is TComponent) and
     GetTableByHint(Sender as TComponent, nTable, nField)then
  begin
    nRIdx := cxView1.Controller.SelectedRows[0].RecordIndex;
    nObj := cxView1.DataController.GetItemByFieldName(nField);
    
    if Assigned(nObj) then
         nCIdx := cxView1.DataController.GetItemByFieldName(nField).Index
    else Exit;
    
    nStr := cxView1.DataController.GetDisplayText(nRIdx, nCIdx);
    if nStr = '' then nStr := nData;

    SetCtrlData(Sender as TComponent, nStr);
    Result := True;
  end;
end;

//Desc: ������������SQL���
function TfFrameNormal.InitFormDataSQL(const nWhere: string): string;
begin
  Result := '';
end;

//Desc: ִ�����ݲ�ѯ
procedure TfFrameNormal.OnInitFormData(var nDefault: Boolean; const nWhere: string;
  const nQuery: TADOQuery);
begin

end;

//Desc: �����������
procedure TfFrameNormal.InitFormData(const nWhere: string; const nQuery: TADOQuery);
var nStr: string;
    nBool: Boolean;
begin
  BtnRefresh.Enabled := False;
  try
    ShowMsgOnLastPanelOfStatusBar('���ڶ�ȡ����,���Ժ�...');
    nBool := True;

    OnInitFormData(nBool, nWhere, nQuery);
    if not nBool then Exit;
    
    nStr := InitFormDataSQL(nWhere);
    if nStr = '' then Exit;

    if Assigned(nQuery) then
         FDM.QueryData(nQuery, nStr)
    else FDM.QueryData(SQLQuery, nStr);
  finally
    ShowMsgOnLastPanelOfStatusBar('');
    BtnRefresh.Enabled := True;
    AfterInitFormData;
  end;
end;

//Desc: ���������
procedure TfFrameNormal.AfterInitFormData;
begin

end;

//------------------------------------------------------------------------------
//Desc: ���ƹ���������
procedure TfFrameNormal.ToolBar1AdvancedCustomDraw(Sender: TToolBar;
  const ARect: TRect; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
var nRect: TRect;
begin
  if (not Assigned(FBarImage)) or (FBarImage.Width < 1) then Exit;
  nRect := Rect(ARect.Left, ARect.Top, 0, ARect.Bottom);

  while nRect.Right < ARect.Right do
  begin
    nRect.Right := nRect.Left + FBarImage.Width;
    ToolBar1.Canvas.StretchDraw(nRect, FBarImage);
    nRect.Left := nRect.Left + FBarImage.Width;
  end;
end;

//Desc: ��Ӧ�س�
procedure TfFrameNormal.OnCtrlKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;

    if Sender is TcxButtonEdit then
    with TcxButtonEdit(Sender) do
    begin
      Properties.OnButtonClick(Sender, 0);
      SelectAll;
    end else SwitchFocusCtrl(Self, True);
  end;
end;

//Desc: �����ݼ�
procedure TfFrameNormal.OnCtrlKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_DOWN:
      begin
        Key := 0; SwitchFocusCtrl(Self, True);
      end;
    VK_UP:
      begin
        Key := 0; SwitchFocusCtrl(Self, False);
      end;
  end;
end;

//------------------------------------------------------------------------------
//Desc: �˳�
procedure TfFrameNormal.BtnExitClick(Sender: TObject);
begin
  if not FIsBusy then Close;
end;

//Desc: ˢ��
procedure TfFrameNormal.BtnRefreshClick(Sender: TObject);
begin
  FWhere := '';
  InitFormData(FWhere);
end;

//Desc: ����
procedure TfFrameNormal.BtnExportClick(Sender: TObject);
begin
  if SQLQuery.Active and (SQLQuery.RecordCount > 0) then
       ExportGridData(cxGrid1)
  else ShowMsg('û�п��Ե���������', sHint);
end;

//Desc: ��ӡ
procedure TfFrameNormal.BtnPrintClick(Sender: TObject);
begin
  if SQLQuery.Active and (SQLQuery.RecordCount > 0) then
       GridPrintData(cxGrid1, TitleBar.Caption)
  else ShowMsg('û�п��Դ�ӡ������', sHint);
end;

//Desc: Ԥ��
procedure TfFrameNormal.BtnPreviewClick(Sender: TObject);
begin
  if SQLQuery.Active and (SQLQuery.RecordCount > 0) then
       GridPrintPreview(cxGrid1, TitleBar.Caption)
  else ShowMsg('û�п���Ԥ��������', sHint);
end;

//Desc: ������Ϣ
procedure TfFrameNormal.cxView1FocusedRecordChanged(
  Sender: TcxCustomGridTableView; APrevFocusedRecord,
  AFocusedRecord: TcxCustomGridRecord;
  ANewItemRecordFocusingChanged: Boolean);
begin
  if FShowDetailInfo and Assigned(APrevFocusedRecord) then
    LoadDataToCtrl(SQLQuery, dxLayout1, '', SetData);
end;

end.
