{*******************************************************************************
  ����: dmzn@163.com 2013-3-18
  ����: ��ѯ����
*******************************************************************************}
unit UFrameReport;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, USysProtocol, Series, UFrameBase, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, DB, ADODB,
  ExtCtrls, cxCheckBox, TeeProcs, TeEngine, Chart, Grids, DBGrids, cxPC,
  cxDropDownEdit, cxCheckComboBox, cxTextEdit, cxMaskEdit, cxCalendar,
  cxLabel, StdCtrls;

type
  TfFrameReport = class(TfFrameBase)
    Panel2: TPanel;
    Panel1: TPanel;
    BtnNext: TButton;
    cxLabel1: TcxLabel;
    EditTime: TcxDateEdit;
    BtnPre: TButton;
    TimerUI: TTimer;
    wPage: TcxPageControl;
    SheetBreakPipe: TcxTabSheet;
    SheetBreakPot: TcxTabSheet;
    SheetTotalPipe: TcxTabSheet;
    SheetChart: TcxTabSheet;
    DBGrid1: TDBGrid;
    QueryBreakPipe: TADOQuery;
    QueryBreakPot: TADOQuery;
    QueryTotalPipe: TADOQuery;
    DataSource1: TDataSource;
    DataSource2: TDataSource;
    DataSource3: TDataSource;
    cxLabel2: TcxLabel;
    EditDevice: TcxCheckComboBox;
    Chart1: TChart;
    CheckBreakPipe: TcxCheckBox;
    CheckTotalPipe: TcxCheckBox;
    CheckBreakPot: TcxCheckBox;
    DBGrid2: TDBGrid;
    DBGrid3: TDBGrid;
    Bevel1: TBevel;
    EditCheck: TcxComboBox;
    EditPage: TcxComboBox;
    procedure TimerUITimer(Sender: TObject);
    procedure CheckBreakPipeClick(Sender: TObject);
    procedure BtnPreClick(Sender: TObject);
    procedure BtnNextClick(Sender: TObject);
    procedure EditTimePropertiesEditValueChanged(Sender: TObject);
    procedure EditTimeKeyPress(Sender: TObject; var Key: Char);
    procedure EditCheckPropertiesChange(Sender: TObject);
    procedure EditDevicePropertiesCloseUp(Sender: TObject);
    procedure Chart1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Chart1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Chart1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure EditPagePropertiesChange(Sender: TObject);
  protected
    { Protected declarations }
    FDataList: TList;
    FLastDraw: Int64;
    FCanDrawCross: Boolean;
    FLastDevice: string;
    FPageBegin,FPageEnd: TDateTime;
    procedure OnShowFrame; override;
    procedure OnDestroyFrame; override;
    //inhere
    function GetPageSize: TDateTime;
    function BuildDeviceIDList: string;
    procedure LoadDeviceList;
    procedure QueryData(nInitChart: Boolean = False; nQuery: Boolean = True);
    //ui data
    procedure InitDataItem(const nData: Pointer; const nType: TItemType;
     const nSeries: TComponent; const nDev: PDeviceItem);
    function GetSeries(nDevice: string; nType: TItemType): TFastLineSeries;
    function AddSeries(nDevice: PDeviceItem; nType: TItemType): TFastLineSeries;
    procedure AddDataItem(const nType: TItemType);
    procedure AddChartItem(const nType: TItemType; nInit: Boolean = False);      
    procedure RemoveDataItem(const nSeries: TObject);
    //series
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UMgrConnection, UFormWait, USysLoger, USysConst, USysDB;
  
type
  PDataItem = ^TDataItem;
  TDataItem = record
    FItemType: TItemType;
    FSeries: TComponent;
    FDevice: PDeviceItem;
  end;

class function TfFrameReport.FrameID: integer;
begin
  Result := cFI_FrameReport;
end;

procedure TfFrameReport.OnShowFrame;
begin
  FLastDraw := 0;
  FCanDrawCross := True;

  FDataList := TList.Create;
  TimerUI.Enabled := True;
  TimerUI.Tag := 10;
end;

procedure TfFrameReport.OnDestroyFrame;
var nIdx: Integer;
begin
  for nIdx:=FDataList.Count - 1 downto 0 do
  begin
    Dispose(PDataItem(FDataList[nIdx]));
    FDataList.Delete(nIdx);
  end;

  FreeAndNil(FDataList);
end;

procedure TfFrameReport.TimerUITimer(Sender: TObject);
var nIdx: Integer;
begin
  if (FLastDraw > 0) and (GetTickCount - FLastDraw > 3200) and
     (GetKeyState(VK_SHIFT) and $80000000 = 0) then
  begin
    FLastDraw := 0;
    Chart1.Repaint;
  end;
  
  if TimerUI.Tag < 1 then Exit;
  TimerUI.Tag := 0;

  EditPage.Properties.Items.Add('Ĭ��');
  EditPage.ItemIndex := 0;

  nIdx := 5;
  while nIdx < 65 do
  begin
    EditPage.Properties.Items.Add(IntToStr(nIdx));
    Inc(nIdx, 5);
  end;

  wPage.ActivePageIndex := 0;
  InitChartStyle(Chart1);

  FLastDevice := '';
  LoadDeviceList;

  FPageEnd := Now;
  FPageBegin := FPageEnd - GetPageSize;
  QueryData(True, False);
end;

procedure TfFrameReport.Chart1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FCanDrawCross := False;
  if FLastDraw > 0 then
  begin
    FLastDraw := 0;
    Chart1.Repaint;
  end;
end;

procedure TfFrameReport.Chart1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  with Chart1 do
  begin
    if not FCanDrawCross then Exit;
    if Chart1.SeriesList.Count < 1 then Exit;
    
    Repaint;
    FLastDraw := GetTickCount;

    if X < ChartRect.Left then X := ChartRect.Left + 1;
    if X > ChartRect.Right then X := ChartRect.Right - 1;
    if Y < ChartRect.Top then Y := ChartRect.Top + 1;
    if Y > ChartRect.Bottom then Y := ChartRect.Bottom - 1;

    Canvas.Pen.Color := clAqua;
    Canvas.Pen.Style := psSolid;
    Canvas.DoVertLine(X, ChartRect.Top, ChartRect.Bottom);
    Canvas.DoHorizLine(ChartRect.Left, ChartRect.Right, Y);

    DrawChartCrossLine(Chart1, X, Y);
    //��������
  end;
end;

procedure TfFrameReport.Chart1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FCanDrawCross := True;
end;

//------------------------------------------------------------------------------
//Date: 2013-04-17
//Parm: ����;�ڵ�����;����
//Desc: ��ʼ��������
procedure TfFrameReport.InitDataItem(const nData: Pointer;
  const nType: TItemType; const nSeries: TComponent; const nDev: PDeviceItem);
var nP: PDataItem;
begin
  nP := nData;
  FillChar(nP^, SizeOf(TDataItem), #0);

  nP.FItemType := nType;
  nP.FSeries := nSeries;
  nP.FDevice := nDev;
end;

//Date: 2013-04-17
//Parm: �豸;����
//Desc: ���һ��nDevice.nType��ͼ��
function TfFrameReport.AddSeries(nDevice: PDeviceItem;
  nType: TItemType): TFastLineSeries;
var nStr: string;
    nIdx: Integer;
    nColor: TColor;
    nData: PDataItem;
    nSeries: TFastLineSeries;
begin
  for nIdx:=Chart1.SeriesList.Count - 1 downto 0 do
  begin
    nData := FDataList[Chart1.Series[nIdx].Tag];
    if (nData.FDevice = nDevice) and (nData.FItemType = nType) then
    begin
      Result := Chart1.Series[nIdx] as TFastLineSeries;
      Exit;
    end;
  end;

  case nType of
   itBreakPipe:
    begin
      nStr := Format('%s:%s', [nDevice.FCarriage.FName, sBreakPipe]);
      nColor := nDevice.FColorBreakPipe;
    end;
   itBreakPot:
    begin
      nStr := Format('%s:%s', [nDevice.FCarriage.FName, sBreakPot]);
      nColor := nDevice.FColorBreakPot;
    end;
   itTotalPipe:
    begin
      nStr := Format('%s:%s', [nDevice.FCarriage.FName, sTotalPipe]);
      nColor := nDevice.FColorTotalPipe;
    end else
    begin
      nColor := 0;
    end;
  end;

  nSeries := TFastLineSeries.Create(Chart1);
  Result := nSeries;
  Chart1.AddSeries(nSeries);

  nSeries.Title := nStr;
  nSeries.XValues.DateTime := True;
  if nColor <> 0 then
    nSeries.SeriesColor := nColor;
  //xxxxx

  New(nData);
  nSeries.Tag := FDataList.Add(nData);
  InitDataItem(nData, nType, nSeries, nDevice);
end;

//Date: 2013-04-17
//Parm: �豸���;����
//Desc: ����nDevice.nType��ͼ��
function TfFrameReport.GetSeries(nDevice: string;
  nType: TItemType): TFastLineSeries;
var nIdx: Integer;
    nData: PDataItem;
begin
  Result := nil;

  for nIdx:=Chart1.SeriesList.Count - 1 downto 0 do
  begin
    nData := FDataList[Chart1.Series[nIdx].Tag];
    if (nData.FDevice.FItemID = nDevice) and (nData.FItemType = nType) then
    begin
      Result := Chart1.Series[nIdx] as TFastLineSeries;
      Exit;
    end;
  end;
end;

//Date: 2013-04-17
//Parm: ����
//Desc: ���nType�����ݵ�ͼ��
procedure TfFrameReport.AddDataItem(const nType: TItemType);
var nDS: TDataSet;
    nInt: Integer;
    nDate: TDateTime;
    nSeries: TFastLineSeries;
begin
  case nType of
   itBreakPipe : nDS := QueryBreakPipe;
   itBreakPot  : nDS := QueryBreakPot;
   itTotalPipe : nDS := QueryTotalPipe else Exit;
  end;

  if (not nDS.Active) or (nDS.RecordCount < 1) then Exit;
  //no data
  nDS.First;
  
  while not nDS.Eof do
  try
    nSeries := GetSeries(nDS.FieldByName('P_Device').AsString, nType);
    if not Assigned(nSeries) then Continue;

    nDate := nDS.FieldByName('P_Date').AsDateTime;
    //init base time

    nSeries.AddXY(nDate, nDS.FieldByName('P_Value').AsFloat);
    if nType = itTotalPipe then Continue;

    nInt := nDS.FieldByName('P_Number').AsInteger;
    if nInt >= 3 then
    begin
      TPortReadManager.IncTime(nDate, nInt - 1);
      nSeries.AddXY(nDate, nDS.FieldByName('P_Value').AsFloat);
    end;
  finally
    nDS.Next;
  end;
end;

//Date: 2013-3-18
//Parm: ����
//Desc: ���nType�������ߵ�Chart
procedure TfFrameReport.AddChartItem(const nType: TItemType; nInit: Boolean);
var nIdx: Integer;
    nDev: PDeviceItem;
begin
  if nInit then
  begin
    for nIdx:=Chart1.SeriesCount - 1 downto 0 do
      Chart1.RemoveSeries(Chart1.Series[nIdx]);
    //clear
  end;

  for nIdx:=0 to EditDevice.Properties.Items.Count - 1 do
  if EditDevice.States[nIdx] = cbsChecked then
  begin
    nDev := Pointer(EditDevice.Properties.Items[nIdx].Tag);
    if nType = itAll then
    begin
      if CheckBreakPipe.Checked then AddSeries(nDev, itBreakPipe).Clear;
      if CheckBreakPot.Checked then AddSeries(nDev, itBreakPot).Clear;
      if CheckTotalPipe.Checked then AddSeries(nDev, itTotalPipe).Clear;
    end else
    begin
      AddSeries(nDev, nType).Clear;
    end;
  end;

  if nType = itAll then
  begin
    if CheckBreakPipe.Checked then AddDataItem(itBreakPipe);
    if CheckBreakPot.Checked then AddDataItem(itBreakPot);
    if CheckTotalPipe.Checked then AddDataItem(itTotalPipe);
  end else
  begin
    AddDataItem(nType);
  end;
end;

//Date: 2013-04-17
//Parm: ����
//Desc: ɾ��nSeries��������ݽڵ�
procedure TfFrameReport.RemoveDataItem(const nSeries: TObject);
var nIdx: Integer;
    nData: PDataItem;
begin
  for nIdx:=FDataList.Count - 1 downto 0 do
  begin
    nData := FDataList[nIdx];
    if nData.FSeries <> nSeries then Continue;

    Dispose(nData);
    FDataList.Delete(nIdx);
  end;

  for nIdx:=FDataList.Count - 1 downto 0 do
  begin
    nData := FDataList[nIdx];
    nData.FSeries.Tag := nIdx;
  end; //adjust index
end;

//------------------------------------------------------------------------------
//Desc: ��ȡ��ҳ��С
function TfFrameReport.GetPageSize: TDateTime;
begin
  Result := gSysParam.FReportPage / 24;
  if EditPage.ItemIndex <> 0 then
  begin
    if IsNumber(EditPage.Text, False) then
    begin
      Result := StrToInt(EditPage.Text) / (24 * 60);
      //minute
    end else
    begin
      EditPage.ItemIndex := 0;
      //default
    end;
  end;
end;

//Desc: �����豸�б�
procedure TfFrameReport.LoadDeviceList;
var i,nIdx: Integer;
    nList: TList;
    nPort: PCOMItem;
    nDev: PDeviceItem;
begin
  nList := gDeviceManager.LockPortList;
  try
    for i:=0 to nList.Count - 1 do
    begin
      nPort := nList[i];
      //xxxxx

      for nIdx:=0 to nPort.FDevices.Count - 1 do
      begin
        nDev := nPort.FDevices[nIdx];
        if not nDev.FDeviceUsed then Continue;

        with EditDevice.Properties.Items.Add do
        begin
          Description := nDev.FCarriage.FName;
          Tag := Integer(nDev);
          EditDevice.States[EditDevice.Properties.Items.Count-1] := cbsUnchecked;
        end;
      end;
    end;
  finally
    gDeviceManager.ReleaseLock;
  end;
end;

//Desc: �豸ID�б�,����SQL in()��ѯ
function TfFrameReport.BuildDeviceIDList: string;
var nIdx: Integer;
    nDev: PDeviceItem;
begin
  Result := '';

  for nIdx:=0 to EditDevice.Properties.Items.Count - 1 do
  if EditDevice.States[nIdx] = cbsChecked then
  begin
    nDev := Pointer(EditDevice.Properties.Items[nIdx].Tag);
    if Trim(nDev.FCarriageID) = '' then Continue;

    if Result = '' then
         Result := Format('''%s''', [nDev.FCarriageID])
    else Result := Result + Format(',''%s''', [nDev.FCarriageID]);
  end;
end;

//Date: 2013-3-18
//Parm: ʱ��
//Desc: ��ѯnDataǰ3Сʱ����
procedure TfFrameReport.QueryData(nInitChart, nQuery: Boolean);
var nStr,nSQL,nDevs: string;
    nInit: Int64;
begin
  if FPageEnd > Now() then
  begin
    FPageEnd := Now();
    FPageBegin := FPageEnd - GetPageSize;
  end;

  EditTime.Date := FPageEnd;
  if not nQuery then Exit;

  nDevs := BuildDeviceIDList;
  if nDevs = '' then Exit;
  //not device
  
  nInit := GetTickCount;
  try
    ShowWaitForm(ParentForm, '��ȡ����', True);
    LockWindowUpdate(Handle);

    nStr := 'Select a.*,C_Name From %s a ' +
            ' Left Join %s On C_ID=P_Carriage ' +
            'Where C_ID In (%s) and (P_Date>=''%s'' and P_Date<=''%s'')';
    //xxxxx
  
    nSQL := Format(nStr, [sTable_BreakPipe, sTable_Carriage, nDevs,
            DateTime2Str(FPageBegin), DateTime2Str(FPageEnd)]);
    FDM.QueryData(QueryBreakPipe, nSQL);

    nSQL := Format(nStr, [sTable_BreakPot, sTable_Carriage, nDevs,
            DateTime2Str(FPageBegin), DateTime2Str(FPageEnd)]);
    FDM.QueryData(QueryBreakPot, nSQL);

    nSQL := Format(nStr, [sTable_TotalPipe, sTable_Carriage, nDevs,
            DateTime2Str(FPageBegin), DateTime2Str(FPageEnd)]);
    FDM.QueryData(QueryTotalPipe, nSQL);

    AddChartItem(itAll, nInitChart);
    //add series
  finally
    Application.ProcessMessages;
    LockWindowUpdate(0);

    if GetTickCount - nInit < 500 then
      Sleep(500);
    CloseWaitForm;
  end;
end;

//Desc: ѡ������
procedure TfFrameReport.CheckBreakPipeClick(Sender: TObject);
var nIdx: Integer;
    nType: TItemType;
    nData: PDataItem;
begin
  case (Sender as TComponent).Tag of
   10: nType := itBreakPipe;
   20: nType := itBreakPot;
   30: nType := itTotalPipe else Exit;
  end;

  if (Sender as TcxCheckBox).Checked then
  begin
    AddChartItem(nType);
  end else
  begin
    for nIdx:=Chart1.SeriesCount - 1 downto 0 do
    begin
      nData := FDataList[Chart1.Series[nIdx].Tag];
      //data

      if nData.FItemType = nType then
      begin
        RemoveDataItem(Chart1.Series[nIdx]);
        Chart1.RemoveSeries(Chart1.Series[nIdx]);
      end;
    end;
  end;
end;

//Desc: ��һҳ
procedure TfFrameReport.BtnPreClick(Sender: TObject);
begin
  FPageEnd := FPageBegin;
  FPageBegin := FPageEnd - GetPageSize;
  QueryData;
end;

//Desc: ��һҳ
procedure TfFrameReport.BtnNextClick(Sender: TObject);
begin
  FPageBegin := FPageEnd;
  FPageEnd := FPageBegin + GetPageSize;
  QueryData;
end;

//Desc: �ֶ���дʱ��
procedure TfFrameReport.EditTimePropertiesEditValueChanged(Sender: TObject);
begin
  if EditTime.IsFocused then
  begin
    FPageEnd := EditTime.Date;
    if FPageEnd < 0 then Exit;
    
    FPageBegin := FPageEnd - GetPageSize;
    QueryData;
  end;
end;

//Desc: ��������
procedure TfFrameReport.EditTimeKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    EditTimePropertiesEditValueChanged(nil);
  end;
end;

//Desc: �豸����
procedure TfFrameReport.EditCheckPropertiesChange(Sender: TObject);
var nIdx: Integer;
begin
  for nIdx:=EditDevice.Properties.Items.Count - 1 downto 0 do
  begin
    case EditCheck.ItemIndex of
     0: EditDevice.States[nIdx] := cbsChecked;
     1: EditDevice.States[nIdx] := cbsUnchecked;
     2:
      if EditDevice.States[nIdx] = cbsChecked then
           EditDevice.States[nIdx] := cbsUnchecked
      else EditDevice.States[nIdx] := cbsChecked;
    end;
  end;

  EditDevicePropertiesCloseUp(nil);
  //do query
end;

//Desc: Ӧ�ò�ѯ����
procedure TfFrameReport.EditDevicePropertiesCloseUp(Sender: TObject);
var nStr: string;
begin
  nStr := BuildDeviceIDList;
  if nStr = FLastDevice then Exit;
  FLastDevice := nStr;
  
  if not EditCheck.Focused then
    EditCheck.ItemIndex := -1;
  QueryData(True);
end;

//Desc: Ӧ�÷�ҳ�仯
procedure TfFrameReport.EditPagePropertiesChange(Sender: TObject);
begin
  if EditPage.IsFocused then
  begin
    FPageBegin := FPageEnd - GetPageSize;
    QueryData;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameReport, TfFrameReport.FrameID);
end.
