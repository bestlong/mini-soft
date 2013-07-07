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
    FTrucks     : TList;
  end;//װ����

  PTruckItem = ^TTruckItem;
  TTruckItem = record
    FEnable     : Boolean;
    FTruck      : string;      //���ƺ�
    FConNo      : string;      //���Ϻ�
    FConName    : string;      //Ʒ����
    FLine       : string;      //װ����
    FTaskID     : string;      //����
    
    FInTime     : Int64;       //����ʱ��
    FInFact     : Boolean;     //�Ƿ����
    FInLade     : Boolean;     //�Ƿ����
    FIsVIP      : string;      //��Ȩ��
    FIndex      : Integer;     //��������
  end;

  TQueueParam = record
    FLoaded     : Boolean;     //������
  end;

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
    FTruckChanged: Boolean;
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
    //����װ����
    procedure LoadTrucks;
    //���복��
    procedure InvalidTruckOutofQueue;
    //���д���
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
    //װ����
    FLineLoaded: Boolean;
    //�Ƿ�������
    FLineChanged: Int64;
    //���б䶯
    FSyncLock: TCriticalSection;
    //ͬ����
    FDBReader: TTruckQueueDBReader;
    //���ݶ�д
  protected
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
    function GetVoiceTruck(const nSeparator: string;
     const nLocked: Boolean): string;
    //��������
    procedure RefreshTrucks(const nLoadLine: Boolean);
    //ˢ�¶���
    function GetLine(const nLineID: string): Integer;
    //װ����
    function TruckInQueue(const nTruck: string): Integer;
    function TruckInLine(const nTruck: string; const nList: TList): Integer;
    //��������
    property Lines: TList read FLines;
    property LineChanged: Int64 read FLineChanged;
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
  FLineChanged := GetTickCount;

  FLines := TList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TTruckQueueManager.Destroy;
begin
  StopQueue;
  ClearLines(True);

  FSyncLock.Free;
  inherited;
end;

//Desc: �ͷ�װ����
procedure TTruckQueueManager.FreeLine(nItem: PLineItem; nIdx: Integer);
var i: Integer;
begin
  if Assigned(nItem) then
    nIdx := FLines.IndexOf(nItem);
  if nIdx < 0 then Exit;

  if (not Assigned(nItem)) and (nIdx > -1) then
    nItem := FLines[nIdx];
  if not Assigned(nItem) then Exit;

  for i:=nItem.FTrucks.Count - 1 downto 0 do
  begin
    Dispose(PTruckItem(nItem.FTrucks[i]));
    nItem.FTrucks.Delete(i);
  end;

  nItem.FTrucks.Free;
  Dispose(PLineItem(nItem));
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

//Date: 2012-8-24
//Parm: �ָ���;�Ƿ�����
//Desc: ��ȡ���������ĳ����б�
function TTruckQueueManager.GetVoiceTruck(const nSeparator: string;
  const nLocked: Boolean): string;
var i,nIdx: Integer;
    nLine: PLineItem;
    nTruck: PTruckItem;
begin
  if nLocked then SyncLock.Enter;
  try
    Result := '';

    for nIdx:=0 to Lines.Count - 1 do
    begin
      nLine := Lines[nIdx];
      for i:=0 to nLine.FTrucks.Count - 1 do
      begin
        nTruck := nLine.FTrucks[i];
        Result := Result + nTruck.FTruck + nSeparator;
        //xxxxx
      end;
    end;

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

//Date: 2012-4-15
//Parm: װ���߱�ʾ
//Desc: ������ʶΪnLineID��װ����(���������)
function TTruckQueueManager.GetLine(const nLineID: string): Integer;
var nIdx: Integer;
begin
  Result := -1;
              
  for nIdx:=FLines.Count - 1 downto 0 do
  if CompareText(nLineID, PLineItem(FLines[nIdx]).FLineID) = 0 then
  begin
    Result := nIdx;
    Break;
  end;
end;

//Date: 2012-4-14
//Parm: ���ƺ�;�б�
//Desc: �ж�nTruck�Ƿ���nList����������(���������)
function TTruckQueueManager.TruckInLine(const nTruck: string;
  const nList: TList): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=nList.Count - 1 downto 0 do
  if CompareText(nTruck, PTruckItem(nList[nIdx]).FTruck) = 0 then
  begin
    Result := nIdx;
    Break;
  end;
end;

//Date: 2012-4-14
//Parm: ���ƺ�
//Desc: �ж�nTruck�Ƿ��ڶ�����(���������)
function TTruckQueueManager.TruckInQueue(const nTruck: string): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=FLines.Count - 1 downto 0 do
  if TruckInLine(nTruck, PLineItem(FLines[nIdx]).FTrucks) > -1 then
  begin
    Result := nIdx;
    Break;
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

        FTruckChanged := False;
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

    FLineChanged := GetTickCount;
    First;

    while not Eof do
    begin
      nStr := FieldByName('Z_ID').AsString;
      nIdx := GetLine(nStr);

      if nIdx < 0 then
      begin
        New(nLine);
        FLines.Add(nLine);
        nLine.FTrucks := TList.Create;
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
//Desc: Desc: ����װ������
procedure TTruckQueueDBReader.LoadTrucks;
var nStr: string;
    i,nIdx: Integer;
begin
  nStr := 'Select * From %s Where IsNull(T_Valid,''%s'')<>''%s'' $Ext ' +
          'Order By T_Index ASC,T_InFact ASC,T_InTime ASC';
  nStr := Format(nStr, [sTable_ZCTrucks, sFlag_Yes, sFlag_No]);

  {++++++++++++++++++++++++++++++ ע�� +++++++++++++++++++++++++
   1.����ģʽʱ,����ʱ��(T_InFact)Ϊ��,�����Կ���ʱ��(T_InTime)Ϊ׼.
   2.����ģʽʱ,�����ѽ���ʱ��Ϊ׼.
   3.����������, T_InFact��T_InTime���ܵ���˳��.
  -------------------------------------------------------------}

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

        FInFact     := FieldByName('T_InFact').AsString <> '';
        FInLade     := FieldByName('T_InLade').AsString <> '';

        FIndex      := FieldByName('T_Index').AsInteger;
        if FIndex < 1 then FIndex := MaxInt;
      end;
      
      Inc(nIdx);
      Next;
    end;
  end else SetLength(FTruckPool, 0);
  //�ɽ��������ڶ��г��������

  InvalidTruckOutofQueue;
  //����Ч�����Ƴ�����

  if Length(FTruckPool) < 1 then Exit;
  //���³�������

  //--------------------------------------------------------------------------
  for nIdx:=0 to FOwner.FLines.Count - 1 do
  with PLineItem(FOwner.Lines[nIdx])^,FOwner do
  begin
    for i:=Low(FTruckPool) to High(FTruckPool) do
    if FTruckPool[i].FEnable then
    begin
      if FTruckPool[i].FLine <> FLineID then Continue;
      if TruckInLine(FTruckPool[i].FTruck, FTrucks) >= 0 then Continue;

      //MakePoolTruckIn(i, FOwner.Lines[nIdx]);
      //�����г�������,ȫ������
    end;

  end;
end;

//Date: 2012-4-15
//Desc: ����Ч����(�ѳ���,������ʱ)�Ƴ�����
procedure TTruckQueueDBReader.InvalidTruckOutofQueue;
var nStr: string;
    i,j,nIdx: Integer;
    nLine: PLineItem;
    nTruck: PTruckItem;
begin
  with FOwner do
  begin
    for nIdx:=FLines.Count - 1 downto 0 do
     with PLineItem(FLines[nIdx])^ do
      for i:=FTrucks.Count - 1 downto 0 do
       PTruckItem(FTrucks[i]).FEnable := False;
    //xxxxx
  end;

  for nIdx:=FOwner.FLines.Count - 1 downto 0 do
  begin

  end;

  for nIdx:=FOwner.FLines.Count - 1 downto 0 do
  begin
    nLine := FOwner.FLines[nIdx];
    for i:=nLine.FTrucks.Count - 1 downto 0 do
    begin
      nTruck := nLine.FTrucks[i];
      if nTruck.FEnable then Continue;

      {$IFDEF DEBUG}
      WriteLog(Format('����[ %s ]��Ч����.', [nTruck.FTruck]));
      {$ENDIF}
      
      Dispose(nTruck);
      nLine.FTrucks.Delete(i);

      FTruckChanged := True;
      FOwner.FLineChanged := GetTickCount;
    end;
  end;
  //������Ч����
end;

initialization
  gTruckQueueManager := TTruckQueueManager.Create
finalization
  FreeAndNil(gTruckQueueManager);
end.
