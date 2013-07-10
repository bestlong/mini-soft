{*******************************************************************************
  ����: dmzn@163.com 2012-4-11
  ����: װ�����й���
*******************************************************************************}
unit UMgrQueue;

{$I Link.Inc}
interface

uses
  Windows, Classes, DB, SysUtils, SyncObjs, UMgrDBConn, UWaitItem, ULibFun,
  USysLoger, USysDB;

const
  cTruckMaxCalledNum = 2;
  //���������д���
  cCall_Prefix_1     = $1C;
  cCall_Prefix_2     = $2B;
  //����Э��ǰ׺

type
  PLineItem = ^TLineItem;
  TLineItem = record
    FEnable     : Boolean;
    FLineID     : string;
    FName       : string;
    FConNo      : string;
    FConName    : string;
    FConType    : string;

    FQueueMax   : Integer;
    FIsVIP      : string;
    FIsValid    : Boolean;
    FIndex      : Integer;
  end;//װ����

  PTruckItem = ^TTruckItem;
  TTruckItem = record
    FEnable     : Boolean;
    FTruck      : string;      //���ƺ�
    FConNo      : string;      //���Ϻ�
    FConName    : string;      //Ʒ����
    FLine       : string;      //װ����
    FTaskID     : string;      //����
    FIsVIP      : string;      //��Ȩ��

    FCallNum    : Byte;        //���д���
    FCallIP     : string;
    FCallPort   : Integer;     //���е�ַ
    FAnswered   : Boolean;     //ˢ��Ӧ��
  end;

  TQueueParam = record
    FLoaded     : Boolean;     //������
  end;

  TTruckScanCallback = function (const nTruck: PTruckItem): Boolean;
  //����ɨ��ص�����

  TTruckQueueManager = class;
  TTruckQueueDBReader = class(TThread)
  private
    FOwner: TTruckQueueManager;
    //ӵ����
    FDBConn: PDBWorker;
    //���ݶ���
    FWaiter: TWaitObject;
    //�ȴ�����
    FParam: TQueueParam;
    //���в���
    FTruckPool: array of TTruckItem;
    //��������
  protected
    procedure Execute; override;
    //ִ���߳�
    procedure ExecuteSQL(const nList: TStrings);
    //ִ��SQL���
    procedure LoadQueueParam;
    //�����ŶӲ���
    procedure LoadLines;
    procedure LoadTrucks;
    //���복��
    function GetLine(const nLineID: string): Integer;
    function TruckInPool(const nTruck: string): Integer;
    function TruckInList(const nTruck: string): Integer;
    //��������
    procedure InvalidTruckOutofQueue;
    procedure MakeTruckIn(var nStart: Integer; const nFilter: TTruckScanCallback);
    //ɨ�����
  public
    constructor Create(AOwner: TTruckQueueManager);
    destructor Destroy; override;
    //�����ͷ�
    procedure Wakup;
    procedure StopMe;
    //��ͣ�߳�
  end;

  TTruckQueueManager = class(TObject)
  private
    FDBName: string;
    //���ݱ�ʶ
    FLines: TList;
    FTrucks: TList;
    //�����б�
    FLineLoaded: Boolean;
    //�Ƿ�������
    FQueueChanged: Int64;
    //���б䶯
    FSyncLock: TCriticalSection;
    //ͬ����
    FDBReader: TTruckQueueDBReader;
    //���ݶ�д
  protected
    procedure FreeTruck(nItem: PTruckItem; nIdx: Integer = -1);
    procedure ClearTrucks(const nFree: Boolean);
    procedure FreeLine(nItem: PLineItem; nIdx: Integer = -1);
    procedure ClearLines(const nFree: Boolean);
    //�ͷ���Դ
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure StartQueue(const nDB: string);
    procedure StopQueue;
    //��ͣ����
    function TruckInQueue(const nTruck: string; const nLocked: Boolean): Integer;
    //��������
    function GetVoiceTruck(const nSeparator: string;
     const nLocked: Boolean): string;
    //��������
    procedure RefreshTrucks(const nLoadLine: Boolean);
    //ˢ�¶���
    property Lines: TList read FLines;
    property Trucks: TList read FTrucks;
    property QueueChanged: Int64 read FQueueChanged;
    property SyncLock: TCriticalSection read FSyncLock;
    //�������
  end;

var
  gTruckQueueManager: TTruckQueueManager = nil;
  //ȫ��ʹ��

implementation

//Desc: ��¼��־
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TTruckQueueManager, 'װ�����е���', nEvent);
end;

constructor TTruckQueueManager.Create;
begin
  FDBReader := nil;
  FLineLoaded := False;
  FQueueChanged := GetTickCount;

  FLines := TList.Create;
  FTrucks := TList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TTruckQueueManager.Destroy;
begin
  StopQueue;
  ClearLines(True);
  ClearTrucks(True);

  FSyncLock.Free;
  inherited;
end;

//Desc: �ͷų���
procedure TTruckQueueManager.FreeTruck(nItem: PTruckItem; nIdx: Integer);
begin
  if (nIdx < 0) and Assigned(nItem) then
    nIdx := FTrucks.IndexOf(nItem);
  if nIdx < 0 then Exit;

  if (not Assigned(nItem)) and (nIdx > -1) then
    nItem := FTrucks[nIdx];
  if not Assigned(nItem) then Exit;

  Dispose(nItem);
  FTrucks.Delete(nIdx);
end;

procedure TTruckQueueManager.ClearTrucks(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FTrucks.Count - 1 downto 0 do
    FreeTruck(nil, nIdx);
  if nFree then FreeAndNil(FTrucks);
end;

//Desc: �ͷ�װ����
procedure TTruckQueueManager.FreeLine(nItem: PLineItem; nIdx: Integer);
begin
  if (nIdx < 0) and Assigned(nItem) then
    nIdx := FLines.IndexOf(nItem);
  if nIdx < 0 then Exit;

  if (not Assigned(nItem)) and (nIdx > -1) then
    nItem := FLines[nIdx];
  if not Assigned(nItem) then Exit;

  Dispose(nItem);
  FLines.Delete(nIdx);
end;

procedure TTruckQueueManager.ClearLines(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FLines.Count - 1 downto 0 do
    FreeLine(nil, nIdx);
  if nFree then FreeAndNil(FLines);
end;

procedure TTruckQueueManager.StartQueue(const nDB: string);
begin
  FDBName := nDB;
  if not Assigned(FDBReader) then
    FDBReader := TTruckQueueDBReader.Create(Self);
  FDBReader.Wakup;
end;

procedure TTruckQueueManager.StopQueue;
begin
  if Assigned(FDBReader) then
  try
    FSyncLock.Enter;
    FDBReader.StopMe;
  finally
    FSyncLock.Leave;
  end;

  FDBReader := nil;
end;

//Date: 2013-07-08
//Parm: ���ƺ�;�Ƿ�����
//Desc: ����nTruck�ڶ����е�λ������
function TTruckQueueManager.TruckInQueue(const nTruck: string;
  const nLocked: Boolean): Integer;
var nIdx: Integer;
begin
  if nLocked then SyncLock.Enter;
  try
    Result := -1;

    for nIdx:=FTrucks.Count - 1 downto 0 do
    if CompareText(nTruck, PTruckItem(FTrucks[nIdx]).FTruck) = 0 then
    begin
      Result := nIdx;
      Break;
    end;
  finally
    if nLocked then SyncLock.Leave;
  end;
end;

//Date: 2012-8-24
//Parm: �ָ���;�Ƿ�����
//Desc: ��ȡ���������ĳ����б�
function TTruckQueueManager.GetVoiceTruck(const nSeparator: string;
  const nLocked: Boolean): string;
var i,nIdx: Integer;
    nTruck: PTruckItem;
begin
  if nLocked then SyncLock.Enter;
  try
    Result := '';

    i := Length(Result);
    if i > 0 then
    begin
      nIdx := Length(nSeparator);
      Result := Copy(Result, 1, i - nIdx);
    end;
  finally
    if nLocked then SyncLock.Leave;
  end;
end;

procedure TTruckQueueManager.RefreshTrucks(const nLoadLine: Boolean);
begin
  if Assigned(FDBReader) then
  begin
    if nLoadLine then
      FLineLoaded := False;
    FDBReader.Wakup;
  end;
end;

//------------------------------------------------------------------------------
constructor TTruckQueueDBReader.Create(AOwner: TTruckQueueManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  with FParam do
  begin
    FLoaded := False;
  end;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 20 * 1000;
end;

destructor TTruckQueueDBReader.Destroy;
begin
  FWaiter.Free;
  inherited;
end;

procedure TTruckQueueDBReader.Wakup;
begin
  FWaiter.Wakeup;
end;

procedure TTruckQueueDBReader.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TTruckQueueDBReader.Execute;
var nErr: Integer;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    FDBConn := gDBConnManager.GetConnection(FOwner.FDBName, nErr);
    try
      if not Assigned(FDBConn) then
      begin
        WriteLog('DB connection is null.');
        Continue;
      end;

      if not FDBConn.FConn.Connected then
      begin
        FDBConn.FConn.Connected := True;
        //conn db
      end;

      FOwner.FSyncLock.Enter;
      try
        LoadQueueParam;
        LoadLines;
        LoadTrucks;
      finally
        FOwner.FSyncLock.Leave;
      end;
    finally
      gDBConnManager.ReleaseConnection(FOwner.FDBName, FDBConn);
    end;
  except
    on E: Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//Desc: ִ��SQL���
procedure TTruckQueueDBReader.ExecuteSQL(const nList: TStrings);
var nIdx: Integer;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    gDBConnManager.WorkerExec(FDBConn, nList[nIdx]);
    nList.Delete(nIdx);
  end;
end;

//Desc: �����ŶӲ���
procedure TTruckQueueDBReader.LoadQueueParam;
var nStr: string;
begin
  Exit;
  if FParam.FLoaded then Exit;

  nStr := 'Select D_Value,D_Memo From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    FParam.FLoaded := True;
    First;

    while not Eof do
    begin
      Next;
    end;
  end;
end;

//Date: 2012-4-15
//Parm: װ���߱�ʶ
//Desc: ������ʶΪnLineID��װ����
function TTruckQueueDBReader.GetLine(const nLineID: string): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=FOwner.FLines.Count - 1 downto 0 do
  if CompareText(nLineID, PLineItem(FOwner.FLines[nIdx]).FLineID) = 0 then
  begin
    Result := nIdx;
    Break;
  end;
end;

//Desc: ����װ�����б�
procedure TTruckQueueDBReader.LoadLines;
var nStr: string;
    nLine: PLineItem;
    i,nIdx,nInt: Integer;
begin
  if FOwner.FLineLoaded then Exit;
  nStr := 'Select * From %s Order By Z_Index ASC';
  nStr := Format(nStr, [sTable_ZCLines]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr),FOwner do
  begin
    FLineLoaded := True;
    if RecordCount < 1 then Exit;

    for nIdx:=FLines.Count - 1 downto 0 do
      PLineItem(FLines[nIdx]).FEnable := False;
    //xxxxx

    First;
    while not Eof do
    begin
      nStr := FieldByName('Z_ID').AsString;
      nIdx := GetLine(nStr);

      if nIdx < 0 then
      begin
        New(nLine);
        FLines.Add(nLine);
      end else nLine := FLines[nIdx];

      with nLine^ do
      begin
        FEnable     := True;
        FLineID     := FieldByName('Z_ID').AsString;
        FName       := FieldByName('Z_Name').AsString;

        FConNo      := FieldByName('Z_ConNo').AsString;
        FConName    := FieldByName('Z_ConName').AsString;
        FConType    := FieldByName('Z_ConType').AsString;

        FQueueMax   := FieldByName('Z_QueueMax').AsInteger;
        FIsVIP      := FieldByName('Z_VIPLine').AsString;
        FIsValid    := FieldByName('Z_Valid').AsString <> sFlag_No;
        FIndex      := FieldByName('Z_Index').AsInteger;
      end;

      Next;
    end;

    for nIdx:=FLines.Count - 1 downto 0 do
    begin
      if not PLineItem(FLines[nIdx]).FEnable then
        FreeLine(nil, nIdx);
      //xxxxx
    end;

    for nIdx:=0 to FLines.Count - 1 do
    begin
      nLine := FLines[nIdx];
      nInt := -1;

      for i:=nIdx+1 to FLines.Count - 1 do
      if PLineItem(FLines[i]).FIndex < nLine.FIndex then
      begin
        nInt := i;
        nLine := FLines[i];
        //find the mininum
      end;

      if nInt > -1 then
      begin
        FLines[nInt] := FLines[nIdx];
        FLines[nIdx] := nLine;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2013-07-07
//Parm: ���ƺ�
//Desc: ����nTruck��FTruckPool�е�λ��
function TTruckQueueDBReader.TruckInPool(const nTruck: string): Integer;
var nIdx: Integer;
begin
  Result := - 1;
  
  for nIdx:=Low(FTruckPool) to High(FTruckPool) do
  if CompareText(nTruck, FTruckPool[nIdx].FTruck) = 0 then
  begin
    Result := nIdx;
    Break;
  end;
end;

//Date: 2013-07-07
//Parm: ���ƺ�
//Desc: ����nTruck��FTrucks�е�λ��
function TTruckQueueDBReader.TruckInList(const nTruck: string): Integer;
var nIdx: Integer;
begin
  Result := - 1;

  for nIdx:=FOwner.FTrucks.Count - 1 downto 0 do
  if CompareText(nTruck, PTruckItem(FOwner.FTrucks[nIdx]).FTruck) = 0 then
  begin
    Result := nIdx;
    Break;
  end;    
end;

//Date: 2012-4-15
//Desc: ����Ч����(�ѳ���,������ʱ)�Ƴ�����
procedure TTruckQueueDBReader.InvalidTruckOutofQueue;
var nIdx: Integer;
    nTruck: PTruckItem;
begin
  for nIdx:=FOwner.FTrucks.Count - 1 downto 0 do
  begin
    nTruck := FOwner.FTrucks[nIdx];
    if TruckInPool(nTruck.FTruck) >= 0 then Continue;

    {$IFDEF DEBUG}
    WriteLog(Format('����[ %s ]��Ч����.', [nTruck.FTruck]));
    {$ENDIF}

    FOwner.FreeTruck(nTruck, nIdx);
    FOwner.FQueueChanged := GetTickCount;
  end;
end;

//Date: 2013-07-07
//Parm: ɨ��FTrucks��ʼ����;������
//Desc: ��FTruckPool����nFilter�ĳ�����ӵ�nStart��ʼ���б���
procedure TTruckQueueDBReader.MakeTruckIn(var nStart: Integer;
  const nFilter: TTruckScanCallback);
var nIdx,nPos: Integer;
    nTruck: PTruckItem;
begin
  with FOwner do
  begin
    for nIdx:=Low(FTruckPool) to High(FTruckPool) do
    begin
      if not nFilter(@FTruckPool[nIdx]) then Continue;
      //������ɸѡ����

      nPos := TruckInList(FTruckPool[nIdx].FTruck);
      if nPos = nStart then
      begin
        Inc(nStart);
        Continue;
      end;
      //��������ȷλ��,���账��

      FQueueChanged := GetTickCount;
      //���¶��б䶯���

      if nPos < 0 then
      begin
        New(nTruck);
        FTrucks.Insert(nStart, nTruck);

        nTruck^ := FTruckPool[nIdx];
        Inc(nStart);
      end else //���ڶ��������
      begin
        nTruck := FTrucks[nStart];
        FTrucks[nIdx] := FTrucks[nPos];

        FTrucks[nPos] := nTruck;
        Inc(nStart);
      end;     //���ڶ����򽻻�
    end;
  end;
end;

//Desc: װ����Ϊ�ջص�
function Filter_LineIsNull(const nTruck: PTruckItem): Boolean;
begin
  Result := nTruck.FLine = '';
end;

//Desc: װ���߲�Ϊ�ջص�
function Filter_LineIsNotNull(const nTruck: PTruckItem): Boolean;
begin
  Result := nTruck.FLine <> '';
end;

//Desc: Desc: ����װ������
procedure TTruckQueueDBReader.LoadTrucks;
var nStr: string;
    i,j,nIdx,nPos: Integer;
    nTruck,nTmp: PTruckItem;
begin
  nStr := 'Select zt.* From %s zt ' +
          ' Left Join %s tl on tl.T_ID=zt.T_TruckLog ' +
          'Where IsNull(T_Valid,''%s'')<>''%s'' ' +
          'Order By T_InTime ASC';
  nStr := Format(nStr, [sTable_ZCTrucks, sTable_TruckLog, sFlag_Yes, sFlag_No]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    SetLength(FTruckPool, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    begin
      with FTruckPool[nIdx] do
      begin
        FEnable     := True;
        FTruck      := FieldByName('T_Truck').AsString;
        FConNo      := FieldByName('T_ConNo').AsString;
        FConName    := FieldByName('T_ConName').AsString;

        FLine       := FieldByName('T_Line').AsString;
        FTaskID     := FieldByName('T_TaskID').AsString;
        FIsVIP      := FieldByName('T_VIP').AsString;

        FCallNum    := 0;
        FCallIP     := '';
        FCallPort   := 0;
        FAnswered   := False;
      end;
      
      Inc(nIdx);
      Next;
    end;
  end else SetLength(FTruckPool, 0);
  //�ɽ��������ڶ��г��������

  InvalidTruckOutofQueue;
  //��Ч��������

  nIdx := 0;
  MakeTruckIn(nIdx, @Filter_LineIsNotNull);
  //װ���߲�Ϊ������

  MakeTruckIn(nIdx, @Filter_LineIsNull);
  //������������
end;

initialization
  gTruckQueueManager := TTruckQueueManager.Create
finalization
  FreeAndNil(gTruckQueueManager);
end.
