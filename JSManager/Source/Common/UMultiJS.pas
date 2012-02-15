{*******************************************************************************
  ����: dmzn@163.com 2010-11-22
  ����: �������������

  ��ע:
  *.����Ԫʵ����һ����˿�,һ�˿ڶ�װ�����ļ���������.
*******************************************************************************}
unit UMultiJS;

interface

uses
  Windows, Classes, CPort, CPortTypes, SysUtils, SyncObjs, UMgrSync, UWaitItem,
  ULibFun;

const   
  cMultiJS_Truck = 3;            //���Ƴ���
  cMultiJS_DaiNum = 4;           //��������
  cMultiJS_Delay = 9;            //����ӳ�
  cMultiJS_Tunnel = 9;           //������ 
  cMultiJS_Interval = 500;       //ˢ��Ƶ��

type
  TMultiJSManager = class;
  TMultJSItem = class;

  PMultiJSTunnel = ^TMultiJSTunnel;
  TMultiJSTunnel = record
    FTunnel: Word;
    //�������
    FDelay: Word;
    //�ӳ�ʱ��
    FTruck: array[0..cMultiJS_Truck - 1] of Char;
    //���ƺ�
    FDaiNum: Word;
    //��װ����
    FHasDone: Word;
    //��װ����
    FLastRead: Cardinal;
    //�ϴζ�ȡ
    FLastRecv: Cardinal;
    //�ϴν���
  end;

  PMultiJSPortData = ^TMultiJSPortData;
  TMultiJSPortData = record
    FCOMPort: array[0..4] of Char;
    //�˿ں�
    FBaudRate: Word;
    //��������
    FTunnel: TList;
    //��������
    FReader: TMultJSItem;
    //�����߳�
  end;

  TMultJSItem = class(TThread)
  private
    FOwner: TMultiJSManager;
    //ӵ����
    FComObj: TComPort;
    //���ڶ���
    FPort: PMultiJSPortData;
    //�˿�����
    FWaiter: TWaitObject;
    //�ȴ�����
    FSyncer: TDataSynchronizer;
    //ͬ������
  protected
    procedure Execute; override;
    //�߳���
    procedure DoSyncEvent(const nData: Pointer; const nSize: Cardinal);
    procedure DoSyncFree(const nData: Pointer; const nSize: Cardinal);
    //ͬ������
  public
    constructor Create(AOwner: TMultiJSManager; nPort: PMultiJSPortData);
    destructor Destroy; override;
    //�����ͷ�
    procedure StopThread;
    //ֹͣ�߳�
    procedure SuspendThread;
    procedure ResumeThread;
    //��ͣ����
  end;

  TMultiJSEvent = procedure (nPort: string; nData: TMultiJSTunnel) of Object;
  //any event

  TMultiJSManager = class(TObject)
  private
    FPorts: TList;
    //�˿�����
    FTunnelEvent: TMultiJSEvent;
    //���ݱ䶯
  protected
    procedure ClearPort(const nPort: PMultiJSPortData);
    procedure ClearPorts(const nFree: Boolean);
    //��������
    function GetPort(const nPort: string): Integer;
    //�����˿�
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure AddPort(const nCOMPort: string; const nBaudRate: Word;
      const nTunnelNum: Byte);
    function DelPort(const nCOMPort: string; var nHint: string): Boolean;
    //�˿ڹ���
    function SetTunnelData(const nCOMPort: string; const nTunnel,nDelay: Word;
      const nTruck: string; const nDaiNum: Word; var nHint: string): Boolean;
    //���ü���
    function StopTunnel(const nCOMPort: string; const nTunnel: Word;
      var nHint: string): Boolean;
    //ֹͣ����
    property Ports: TList read FPorts;
    property OnData: TMultiJSEvent read FTunnelEvent write FTunnelEvent;
    //�������
  end;

implementation

const
  cStopDaiNum = 9999;
  //��Ϊֹͣ��ײ������

  cSize_Port = SizeOf(TMultiJSPortData);
  cSize_Tunnel = SizeOf(TMultiJSTunnel);

//------------------------------------------------------------------------------
constructor TMultJSItem.Create(AOwner: TMultiJSManager; nPort: PMultiJSPortData);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FPort := nPort;

  FComObj := TComPort.Create(nil);
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := cMultiJS_Interval;
  
  FSyncer := TDataSynchronizer.Create;
  FSyncer.SyncEvent := DoSyncEvent;
  FSyncer.SyncFreeEvent := DoSyncFree;
end;

destructor TMultJSItem.Destroy;
begin
  FComObj.Free;
  FWaiter.Free;
  FSyncer.Free;
  inherited;
end;

//Desc: �ͷ��߳�
procedure TMultJSItem.StopThread;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  FComObj.Close;
  Free;
end;

//Desc: ��������
procedure TMultJSItem.SuspendThread;
begin
  while not FWaiter.IsWaiting do;
  FWaiter.Interval := INFINITE;

  FWaiter.Wakeup;
  while not FWaiter.IsWaiting do;
end;

//Desc: ��������
procedure TMultJSItem.ResumeThread;
begin
  while not FWaiter.IsWaiting do;
  FWaiter.Interval := cMultiJS_Interval;

  FWaiter.Wakeup;
  while not FWaiter.IsWaiting do;
end;

procedure TMultJSItem.DoSyncEvent(const nData: Pointer; const nSize: Cardinal);
begin
  if Assigned(FOwner.FTunnelEvent) then
  begin
    FOwner.FTunnelEvent(FPort.FCOMPort, PMultiJSTunnel(nData)^);
  end;
end;

procedure TMultJSItem.DoSyncFree(const nData: Pointer; const nSize: Cardinal);
begin
  Dispose(PMultiJSTunnel(nData));
end;

//Desc: �߳���
procedure TMultJSItem.Execute;
var nIdx,nLen,nInt,nDS: Integer;
    nStr,nTruck,nTmp: string;
    nTunnel,nSync: PMultiJSTunnel;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if FWaiter.WaitResult <> WAIT_TIMEOUT then Continue;

    if not FComObj.Connected then
    begin
      FComObj.Port := FPort.FCOMPort;
      FComObj.BaudRate := StrToBaudRate(IntToStr(FPort.FBaudRate));

      FComObj.SyncMethod := smNone;
      FComObj.Timeouts.ReadInterval := 100;
      FComObj.Timeouts.ReadTotalMultiplier := 20;
      FComObj.Open;

      if FComObj.Connected then
        FComObj.ClearBuffer(True, True);
      //xxxxx
    end;

    if not FComObj.Connected then Continue;
    nStr := #$0A + #$55;

    for nIdx:=0 to FPort.FTunnel.Count - 1 do
    begin
      nTunnel := FPort.FTunnel[nIdx];
      nTruck := nTunnel.FTruck;
      nTruck := StringOfChar('0', cMultiJS_Truck - Length(nTruck)) + nTruck;

      nTmp := IntToStr(nTunnel.FDaiNum);
      nTmp := StringOfChar('0', cMultiJS_DaiNum - Length(nTmp)) + nTmp;

      nStr := nStr + Format('%d%d%s%s', [nTunnel.FTunnel, nTunnel.FDelay,
                     nTruck, nTmp]);
      //xxxxx
    end;

    nStr := nStr + #$0D;
    FComObj.ClearBuffer(True, False);
    FComObj.Write(PChar(nStr), Length(nStr));
    //��������

    //--------------------------------------------------------------------------
    nLen := 5 * FPort.FTunnel.Count + 3;
    //��Ч����=(1λ���� + 4λ����) * ���� + ֡ͷ֡β
    SetLength(nStr, nLen);
    FillChar(PChar(nStr)^, nLen, #0);

    if FComObj.Read(PChar(nStr), nLen) <> nLen then  Continue;
    //��ȡ����

    if (nStr[1]<>#$0A) or (nStr[2]<>#$55) or (nStr[nLen]<>#$0D) then Continue;
    //��Ч����

    nInt := 0;
    nStr := Copy(nStr, 3, nLen - 3);

    for nIdx:=0 to FPort.FTunnel.Count - 1 do
    begin
      if Terminated then Exit;
      nTmp := Copy(nStr, nIdx * 5 + 1, 5);
      //1λ���� + 4λ����

      nTunnel := FPort.FTunnel[nIdx];
      if nTmp[1] <> IntToStr(nTunnel.FTunnel) then Continue;

      System.Delete(nTmp, 1, 1);
      if not IsNumber(nTmp, False) then Continue;

      if StrToInt(nTmp) > nTunnel.FHasDone then
      begin
        nDS := StrToInt(nTmp);
        if (nDS - nTunnel.FHasDone > 1) and
           (nTunnel.FLastRead - nTunnel.FLastRecv < nTunnel.FDelay * 2 * 100) then
        begin
          nTunnel.FLastRead := GetTickCount; Continue;
        end;
        //С�������ӳ��յ�����һ��,��Ϊ��Ч

        nTunnel.FLastRead := GetTickCount;
        nTunnel.FLastRecv := nTunnel.FLastRead;

        nTunnel.FHasDone := nDS;
        New(nSync);
        Move(nTunnel^, nSync^, cSize_Tunnel);

        FSyncer.AddData(nSync, cSize_Tunnel);
        Inc(nInt);
      end;

      if nTunnel.FHasDone >= nTunnel.FDaiNum then
      begin
        nLen := nTunnel.FTunnel;
        nDS := nTunnel.FDaiNum;
        FillChar(nTunnel^, cSize_Tunnel, #0);
        
        if nDS > 0 then
          nTunnel.FDaiNum := cStopDaiNum;
        nTunnel.FTunnel := nLen;
      end;
    end;

    if nInt > 0 then
      FSyncer.ApplySync;
    //xxxxx
  except
    //ignor any error
  end;
end;

//------------------------------------------------------------------------------
constructor TMultiJSManager.Create;
begin
  FPorts := TList.Create;
end;

destructor TMultiJSManager.Destroy;
begin
  ClearPorts(True);
  inherited;
end;

//Desc: ����˿�����
procedure TMultiJSManager.ClearPorts(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FPorts.Count - 1 downto 0 do
  begin
    ClearPort(FPorts[nIdx]);
    FPorts.Delete(nIdx);
  end;

  if nFree then
    FreeAndNil(FPorts);
  //xxxxx
end;

//Desc: �ͷ�nData�˿�
procedure TMultiJSManager.ClearPort(const nPort: PMultiJSPortData);
var nIdx: Integer;
begin
  nPort.FReader.StopThread;
  //stop thread first
  
  for nIdx:=nPort.FTunnel.Count - 1 downto 0 do
  begin
    Dispose(PMultiJSTunnel(nPort.FTunnel[nIdx]));
    nPort.FTunnel.Delete(nIdx);
  end;

  nPort.FTunnel.Free;
  Dispose(nPort);
end;

//Desc: ���ض˿�nPort������
function TMultiJSManager.GetPort(const nPort: string): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=FPorts.Count - 1 downto 0 do
  if CompareStr(nPort, PMultiJSPortData(FPorts[nIdx]).FCOMPort) = 0 then
  begin
    Result := nIdx; Break;
  end;
end;

//Date: 2010-11-22
//Parm: �˿�;������;����
//Desc: ���һ��������ΪnBaunRate,����ΪnTunnelNum�Ķ˿�
procedure TMultiJSManager.AddPort(const nCOMPort: string; const nBaudRate: Word;
  const nTunnelNum: Byte);
var nStr: string;
    nIdx: Integer;
    nPort: PMultiJSPortData;
    nTunnel: PMultiJSTunnel;
begin
  if nTunnelNum > cMultiJS_Tunnel then
  begin
    nStr := Format('����Ϊ���[ %d ]������', [cMultiJS_Tunnel]);
    raise Exception.Create(nStr);
  end;

  nPort := nil;
  try
    nIdx := GetPort(nCOMPort);
    if nIdx > -1 then
      nPort := FPorts[nIdx];
    //xxxxx
    
    if not Assigned(nPort) then
    begin
      New(nPort);
      FPorts.Add(nPort);
      FillChar(nPort^, cSize_Port, #0);

      StrPCopy(@nPort.FCOMPort[0], nCOMPort);
      nPort.FTunnel := TList.Create;
      nPort.FReader := TMultJSItem.Create(Self, nPort);
    end;

    nPort.FReader.SuspendThread;
    //stop thread

    if nPort.FBaudRate <> nBaudRate then
    begin
      nPort.FReader.FComObj.Close;
      nPort.FBaudRate := nBaudRate;
    end;

    if nPort.FTunnel.Count > nTunnelNum then
    begin
      for nIdx:=nPort.FTunnel.Count - 1 downto nTunnelNum do
      begin
        Dispose(PMultiJSTunnel(nPort.FTunnel[nIdx]));
        nPort.FTunnel.Delete(nIdx);
      end;
    end else

    if nPort.FTunnel.Count < nTunnelNum then
    begin
      for nIdx:=nPort.FTunnel.Count to nTunnelNum - 1 do
      begin
        New(nTunnel);
        nPort.FTunnel.Add(nTunnel);

        FillChar(nTunnel^, cSize_Tunnel, #0);
        nTunnel.FTunnel := nIdx + 1;
      end;
    end;
  finally
    if Assigned(nPort) then
      nPort.FReader.ResumeThread;
    //xxxxx
  end;
end;

//Desc: ɾ��nCOMPort�˿�
function TMultiJSManager.DelPort(const nCOMPort: string;
  var nHint: string): Boolean;
var nIdx: Integer;
begin
  for nIdx:=FPorts.Count - 1 downto 0 do
  if CompareStr(nCOMPort, PMultiJSPortData(FPorts[nIdx]).FCOMPort) = 0 then
  begin
    ClearPort(FPorts[nIdx]);
    FPorts.Delete(nIdx);
    
    Result := True;
    nHint := ''; Exit;
  end;

  Result := False;
  nHint := Format('û���ҵ�[ %s ]�˿�', [nCOMPort]);
end;

//Date: 2010-11-22
//Parm: �˿�;����;�ӳ�;����;����;��ʾ����
//Desc: ��nCOMPort.nTunnel�������һ��nTruck.nDaiNum����
function TMultiJSManager.SetTunnelData(const nCOMPort: string;
  const nTunnel,nDelay: Word; const nTruck: string; const nDaiNum: Word;
  var nHint: string): Boolean;
var nIdx: Integer;
    nPort: PMultiJSPortData;
    nPTunnel: PMultiJSTunnel;
begin
  Result := False;
  if nDelay > cMultiJS_Delay then
  begin
    nHint := Format('�ӳ�Ϊ���[ %d ]������', [cMultiJS_Delay]); Exit;
  end;

  if Length(IntToStr(nDaiNum)) > cMultiJS_DaiNum then
  begin
    nHint := Format('�������Ϊ[ %d ]λ����', [cMultiJS_DaiNum]); Exit;
  end;

  nIdx := GetPort(nCOMPort);
  if nIdx < 0 then
  begin
    nHint := '��Ч��ͨѶ�˿�'; Exit;
  end;

  nPTunnel := nil;
  nPort := FPorts[nIdx];

  for nIdx:=nPort.FTunnel.Count - 1 downto 0 do
  if PMultiJSTunnel(nPort.FTunnel[nIdx]).FTunnel = nTunnel then
  begin
    nPTunnel := nPort.FTunnel[nIdx]; Break;
  end;

  if not Assigned(nPTunnel) then
  begin
    nHint := '��Ч��װ������'; Exit;
  end;

  nPort.FReader.SuspendThread;
  try
    if (nDaiNum <> cStopDaiNum) and (nPTunnel.FDaiNum <> cStopDaiNum) then
     if (nDaiNum > 0) and (nPTunnel.FDaiNum > nPTunnel.FHasDone) then
      begin
        nHint := '�õ�װ����,���Ժ�'; Exit;
      end;
    //valid check

    nIdx := nPTunnel.FTunnel;
    FillChar(nPTunnel^, cSize_Tunnel, #0);
    nPTunnel.FTunnel := nIdx;

    nPTunnel.FDelay := nDelay;
    nPTunnel.FDaiNum := nDaiNum;

    nIdx := cMultiJS_Truck;
    StrPCopy(@nPTunnel.FTruck, Copy(nTruck, Length(nTruck) - nIdx + 1, nIdx));

    nHint := '';
    Result := True;
  finally
    nPort.FReader.ResumeThread;
  end;
end;

//Date: 2010-11-22
//Parm: �˿�;����;��ʾ����
//Desc: ֹͣnCOMPort.nTunnel���ļ���
function TMultiJSManager.StopTunnel(const nCOMPort: string;
  const nTunnel: Word; var nHint: string): Boolean;
begin
  Result := SetTunnelData(nCOMPort, nTunnel, 0, '', cStopDaiNum, nHint);
end;

end.
