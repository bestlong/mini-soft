{*******************************************************************************
  ����: dmzn@163.com 2010-11-22
  ����: �������������

  ��ע:
  *.����Ԫʵ����TCPģʽ��һ����װ�����ļ���������.
*******************************************************************************}
unit UMultiJS_Net;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, NativeXml, UMgrSync, UWaitItem, ULibFun,
  USysLoger, IdGlobal, IdTCPConnection, IdTCPClient;

const   
  cMultiJS_Truck           = 8;         //���Ƴ���
  cMultiJS_DaiNum          = 5;         //��������
  cMultiJS_Delay           = 9;         //����ӳ�
  cMultiJS_Tunnel          = 10;        //������
  cMultiJS_Interval        = 1200;      //ˢ��Ƶ��

  cFrame_Control           = $05;       //����֡
  cFrame_Display           = $09;       //��ʾ֡
  cFrame_Query             = $12;       //��ѯ֡
  cFrame_Clear             = $27;       //����֡

type
  TMultiJSManager = class;
  TMultJSItem = class;

  PMultiJSTunnel = ^TMultiJSTunnel;
  TMultiJSTunnel = record
    FID: string;
    FName: string;    
    //ͨ����ʶ
    FTunnel: Word;
    //�������
    FDelay: Word;
    //�ӳ�ʱ��
    FReader: string;
    //��ͷ��ַ
    FTruck: array[0..cMultiJS_Truck - 1] of Char;
    //���ƺ�
    FDaiNum: Word;
    //��װ����
    FHasDone: Word;
    //��װ����
  end;

  PMultiJSHost= ^TMultiJSHost;
  TMultiJSHost = record
    FName: string;
    FHostIP: string;
    FHostPort: Integer;
    //������Ϣ
    F485Addr: Byte;
    //��·��ַ
    FTunnelNum: Byte;
    //��Ч����
    FTunnel: TList;
    //��������
    FReader: TMultJSItem;
    //�����߳�
  end;

  TMultiJSPeerSend = record
    FAddr: Byte;
    FDelay: Byte;
    FTruck: array[0..cMultiJS_Truck - 1] of Char;
    FDai: array[0..cMultiJS_DaiNum - 1] of Char;
  end;

  PMultiJSDataSend = ^TMultiJSDataSend;
  TMultiJSDataSend = record
    FHeader : array[0..1] of Byte;    //֡ͷ
    FAddr   : Byte;                   //485��ַ
    FType   : Byte;                   //����,��ѯ
    FData   : TMultiJSPeerSend;       //��Ч����
    FEnd    : Byte;                   //����֡
  end;

  TMultiJSPeerRecv = record
    FAddr: Byte;
    FDai: array[0..cMultiJS_DaiNum - 1] of Char;
  end;

  PMultiJSDataRecv = ^TMultiJSDataRecv;
  TMultiJSDataRecv = record
    FHeader : array[0..1] of Char;    //֡ͷ
    FAddr   : Byte;                   //485��ַ
    FType   : Byte;                   //����,��ѯ
    FData   : array[0..cMultiJS_Tunnel - 1] of TMultiJSPeerRecv;
    FEnd    : Byte;                   //����֡
  end;

  TMultJSItem = class(TThread)
  private
    FOwner: TMultiJSManager;
    //ӵ����
    FHost: PMultiJSHost;
    //������
    FClient: TIdTCPClient;
    //�ͻ���
    FTmpList: TList;
    FBuffer: TThreadList;
    //���ͻ���
    FRecv: TMultiJSDataRecv;
    //���ջ���
    FNowTunnel: PMultiJSTunnel;
    //��ǰͨ��
    FWaiter: TWaitObject;
    //�ȴ�����
  protected
    procedure Execute; override;
    //�߳���
    procedure ClearBuffer(const nList: TList);
    //��ջ���
    procedure DeleteFromBuffer(nAddr: Byte; nList: TList);
    //ɾ��ָ��
    procedure AddQueryFrame(const nList: TList);
    //��ѯָ��
    procedure SendDataFrame(const nData: PMultiJSDataSend);
    //��������
    procedure ApplyRespondData;
    //���´���
    function GetTunnel(const nTunnel: Byte): PMultiJSTunnel;
    //����ͨ��
    procedure SyncNowTunnel;
    //ͬ��ͨ��
  public
    constructor Create(AOwner: TMultiJSManager; nHost: PMultiJSHost);
    destructor Destroy; override;
    //�����ͷ�
    procedure Wakeup;
    procedure StopMe;
    //ֹͣ�߳�
  end;

  TMultiJSChange = procedure (const nTunnel: PMultiJSTunnel) of object;
  //�¼�

  TMultiJSManager = class(TObject)
  private
    FEnableQuery: Boolean;
    //������ѯ
    FEnableCount: Boolean;
    //��������
    FHosts: TList;
    //�����б�
    FFileName: string;
    //�����ļ�
    FChangeThread: TMultiJSChange;
    FChangeSync: TMultiJSChange;
    //�¼����
  protected
    procedure DisposeHost(const nHost: PMultiJSHost);
    procedure ClearHost(const nFree: Boolean);
    //��������
    function GetTunnel(const nID: string; var nHost: PMultiJSHost;
      var nTunnel: PMultiJSTunnel): Boolean;
    //����ͨ��
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure LoadFile(const nFile: string);
    //��ȡ����
    procedure StartJS;
    procedure StopJS;
    //��ͣ����
    function AddJS(const nTunnel,nTruck:string; const nDaiNum: Integer;
     const nOnlyDisplay: Boolean = False): Boolean;
    //��Ӽ���
    function DelJS(const nTunnel: string): Boolean;
    //ɾ������
    function GetJSStatus(const nList: TStrings): Boolean;
    //����״̬
    property Hosts: TList read FHosts;
    property FileName: string read FFileName;
    property QueryEnable: Boolean read FEnableQuery write FEnableQuery;
    property CountEnable: Boolean read FEnableCount write FEnableCount;
    property ChangeSync: TMultiJSChange read FChangeSync write FChangeSync;
    property ChangeThread: TMultiJSChange read FChangeThread write FChangeThread;
    //�������
  end;

var
  gMultiJSManager: TMultiJSManager = nil;
  //ȫ��ʹ��

implementation

const
  cSizeHost         = SizeOf(TMultiJSHost);
  cSizeTunnel       = SizeOf(TMultiJSTunnel);
  cSizeDataSend     = SizeOf(TMultiJSDataSend);
  cSizeDataRecv     = SizeOf(TMultiJSDataRecv);
  cSizePeerRecv     = SizeOf(TMultiJSPeerRecv);
                                             
//------------------------------------------------------------------------------
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TMultiJSManager, '�������������', nEvent);
end;  

constructor TMultJSItem.Create(AOwner: TMultiJSManager; nHost: PMultiJSHost);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FHost := nHost;

  FTmpList := TList.Create;
  FBuffer := TThreadList.Create;
  
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := cMultiJS_Interval;

  FClient := TIdTCPClient.Create;
  FClient.ReadTimeout := 5 * 1000;
  FClient.ConnectTimeout := 5 * 1000;
end;

destructor TMultJSItem.Destroy;
var nList: TList;
begin
  FClient.Disconnect;
  FClient.Free;
  
  nList := FBuffer.LockList;
  try
    ClearBuffer(nList);
  finally
    FBuffer.UnlockList;
    FBuffer.Free;
  end;
       
  ClearBuffer(FTmpList);
  FTmpList.Free;

  FWaiter.Free;
  inherited;
end;

procedure TMultJSItem.ClearBuffer(const nList: TList);
var nIdx: Integer;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    Dispose(PMultiJSDataSend(nList[nIdx]));
    nList.Delete(nIdx);
  end;
end;

//Date: 2012-4-23
//Parm: ͨ�����;�б�
//Desc: ��nList��ɾ����ʶΪnTunnel������
procedure TMultJSItem.DeleteFromBuffer(nAddr: Byte; nList: TList);
var nIdx: Integer;
    nData: PMultiJSDataSend;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    nData := nList[nIdx];
    if nData.FData.FAddr = nAddr then
    begin
      Dispose(nData);
      nList.Delete(nIdx);
      Exit;
    end;
  end;
end;

//Desc: �ͷ��߳�
procedure TMultJSItem.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

//Desc: �����߳�
procedure TMultJSItem.Wakeup;
begin
  FWaiter.Wakeup;
end;

//Desc: �߳���
procedure TMultJSItem.Execute;
var nIdx: Integer;
    nList: TList;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    try
      if not FClient.Connected then
      begin
        FClient.Host := FHost.FHostIP;
        FClient.Port := FHost.FHostPort;
        FClient.Connect;
      end;
    except
      WriteLog(Format('���Ӽ�����[ %s ]ʧ��', [FHost.FHostIP]));
      FClient.Disconnect;
      Continue;
    end;

    nList := FBuffer.LockList;
    try
      for nIdx:=0 to nList.Count - 1 do
        FTmpList.Add(nList[nIdx]);
      nList.Clear;
    finally
      FBuffer.UnlockList;
    end;

    if (FTmpList.Count < 1) and FOwner.FEnableQuery then
      AddQueryFrame(FTmpList);
    //��Ӳ�ѯ֡

    if FTmpList.Count > 0 then
    try
      FClient.Socket.InputBuffer.Clear;
      //��ջ���

      for nIdx:=0 to FTmpList.Count - 1 do
        SendDataFrame(FTmpList[nIdx]);
      //��������֡

      ClearBuffer(FTmpList);
    except
      ClearBuffer(FTmpList);
      FClient.Disconnect;
      
      if Assigned(FClient.IOHandler) then
        FClient.IOHandler.InputBuffer.Clear;
      raise;
    end;
  except
    On E:Exception do
    begin
      WriteLog(Format('Host:[ %s ] %s', [FHost.FHostIP, E.Message]));
    end;
  end;
end;

//Desc: ��nList����Ӳ�ѯ֡
procedure TMultJSItem.AddQueryFrame(const nList: TList);
var nSend: PMultiJSDataSend;
begin
  New(nSend);
  nList.Add(nSend);
  FillChar(nSend^, cSizeDataSend, #0);

  with nSend^ do
  begin
    FHeader[0] := $0A;
    FHeader[1] := $55;
    FAddr := FHost.F485Addr;

    FType := cFrame_Query;
    FEnd := $0D;
  end;
end;

//Desc: ��������
procedure TMultJSItem.SendDataFrame(const nData: PMultiJSDataSend);
var nBuf: TIdBytes;
    nSize: Integer;
begin
  nBuf := RawToBytes(nData^, cSizeDataSend);
  FClient.Socket.Write(nBuf);

  nSize := cSizeDataRecv - (cMultiJS_Tunnel - FHost.FTunnelNum) * cSizePeerRecv;
  FClient.Socket.ReadBytes(nBuf, nSize, False);

  BytesToRaw(nBuf, FRecv, nSize);
  ApplyRespondData;
end;

//Desc: ͬ����ǰͨ��
procedure TMultJSItem.SyncNowTunnel;
begin
  FOwner.FChangeSync(FNowTunnel);
end;

//Desc: ���´���������
procedure TMultJSItem.ApplyRespondData;
var nIdx,nInt: Integer;
    nTunnel: PMultiJSTunnel;
begin
  for nIdx:=0 to FHost.FTunnelNum - 1 do
  begin
    nTunnel := GetTunnel(FRecv.FData[nIdx].FAddr);
    if not Assigned(nTunnel) then Continue;

    nInt := StrToInt(FRecv.FData[nIdx].FDai);
    if nTunnel.FHasDone = nInt then Continue;
    nTunnel.FHasDone := nInt;

    if Assigned(FOwner.FChangeThread) then
      FOwner.FChangeThread(nTunnel);
    //thread event

    if Assigned(FOwner.FChangeSync) then
    try 
      FNowTunnel := nTunnel;
      Synchronize(SyncNowTunnel);
    except
      //ignor any error
    end;
  end;
end;

//Date: 2012-4-23
//Parm: ͨ����
//Desc: ����nTunnelͨ��
function TMultJSItem.GetTunnel(const nTunnel: Byte): PMultiJSTunnel;
var nIdx: Integer;
begin
  Result := nil;

  for nIdx:=0 to FHost.FTunnel.Count - 1 do
  if PMultiJSTunnel(FHost.FTunnel[nIdx]).FTunnel = nTunnel then
  begin
    Result := FHost.FTunnel[nIdx];
    Exit;
  end;
end;

//------------------------------------------------------------------------------
constructor TMultiJSManager.Create;
begin
  FEnableQuery := False;
  FEnableCount := False;
  FHosts := TList.Create;
end;

destructor TMultiJSManager.Destroy;
begin
  StopJS;
  ClearHost(True);
  inherited;
end;

//Desc: �ͷ�nData�˿�
procedure TMultiJSManager.DisposeHost(const nHost: PMultiJSHost);
var nIdx: Integer;
begin
  for nIdx:=nHost.FTunnel.Count - 1 downto 0 do
  begin
    Dispose(PMultiJSTunnel(nHost.FTunnel[nIdx]));
    nHost.FTunnel.Delete(nIdx);
  end;

  nHost.FTunnel.Free;
  Dispose(nHost);
end;

//Desc: ����˿�����
procedure TMultiJSManager.ClearHost(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FHosts.Count - 1 downto 0 do
  begin
    DisposeHost(FHosts[nIdx]);
    FHosts.Delete(nIdx);
  end;

  if nFree then
    FreeAndNil(FHosts);
  //xxxxx
end;

//Desc: ��������
procedure TMultiJSManager.StartJS;
var nIdx: Integer;
    nHost: PMultiJSHost;
begin
  if FEnableCount then
  begin
    for nIdx:=0 to FHosts.Count - 1 do
    begin
      nHost := FHosts[nIdx];
      if Assigned(nHost.FReader) then Continue;

      nHost.FReader := TMultJSItem.Create(Self, nHost);
      //new reader
    end;
  end;
end;

//Desc: ֹͣ����
procedure TMultiJSManager.StopJS;
var nIdx: Integer;
    nHost: PMultiJSHost;
begin
  for nIdx:=0 to FHosts.Count - 1 do
  begin
    nHost := FHosts[nIdx];
    if Assigned(nHost.FReader) then
    begin
      nHost.FReader.StopMe;
      nHost.FReader := nil;
    end;
  end;
end;

//Desc: ��ȡ��������
procedure TMultiJSManager.LoadFile(const nFile: string);
var i,nIdx: Integer;
    nNode,nTmp: TXmlNode;
    nXML: TNativeXml;
    nHost: PMultiJSHost;
    nTunnel: PMultiJSTunnel;
begin
  FFileName := nFile;
  nXML := TNativeXml.Create;
  try
    ClearHost(False);
    nXML.LoadFromFile(nFile);

    nTmp := nXML.Root.FindNode('config');
    if Assigned(nTmp) then
    begin
      nIdx := nTmp.NodeByName('query').ValueAsInteger;
      FEnableQuery := nIdx = 1;

      nIdx := nTmp.NodeByName('count').ValueAsInteger;
      FEnableCount := nIdx = 1;
    end;

    for nIdx:=0 to nXML.Root.NodeCount - 1 do
    begin
      nTmp := nXML.Root.Nodes[nIdx];
      if nTmp.Name <> 'item' then Continue;
      
      New(nHost);
      FHosts.Add(nHost);

      with nHost^ do
      begin
        FName := nTmp.AttributeByName['name'];
        nNode := nTmp.NodeByName('param');

        FHostIP := nNode.NodeByName('ip').ValueAsString;
        FHostPort := nNode.NodeByName('port').ValueAsInteger;
        F485Addr := nNode.NodeByName('addr').ValueAsInteger;
        FTunnelNum := nNode.NodeByName('linenum').ValueAsInteger;

        FTunnel := TList.Create;
        FReader := nil;
      end;

      nTmp := nTmp.NodeByName('lines');
      for i:=0 to nTmp.NodeCount - 1 do
      begin
        nNode := nTmp.Nodes[i];
        New(nTunnel);
        nHost.FTunnel.Add(nTunnel);

        with nTunnel^ do
        begin
          FID := nNode.NodeByName('id').ValueAsString;
          FName := nNode.NodeByName('name').ValueAsString;
          FTunnel := nNode.NodeByName('tunnel').ValueAsInteger;
          FDelay := nNode.NodeByName('delay').ValueAsInteger;
        end;
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2012-4-23
//Parm: ͨ����ʶ
//Desc: ����nIDͨ��
function TMultiJSManager.GetTunnel(const nID: string; var nHost: PMultiJSHost;
  var nTunnel: PMultiJSTunnel): Boolean;
var i,nIdx: Integer;
    nPHost: PMultiJSHost;
    nPTunnel: PMultiJSTunnel;
begin
  Result := False;

  for i:=0 to FHosts.Count - 1 do
  begin
    nPHost := FHosts[i];
    for nIdx:=0 to nPHost.FTunnel.Count - 1 do
    begin
      nPTunnel := nPHost.FTunnel[nIdx];
      if CompareText(nID, nPTunnel.FID) = 0 then
      begin
        nHost := nPHost;
        nTunnel := nPTunnel;

        Result := True;
        Exit;
      end;
    end;
  end;
end;

//Date: 2012-4-23
//Parm: ͨ����ʶ;����;����;ֻ��ʾ������
//Desc: ��nTunnel���һ����������
function TMultiJSManager.AddJS(const nTunnel, nTruck: string;
 const nDaiNum: Integer; const nOnlyDisplay: Boolean): Boolean;
var nStr: string;
    nList: TList;
    nPH: PMultiJSHost;
    nPT: PMultiJSTunnel;
    nSend: PMultiJSDataSend;
begin
  Result := False;
  if not FEnableCount then
  begin
    WriteLog('������δ����config.count����.');
    Exit;
  end;

  if not (GetTunnel(nTunnel, nPH, nPT) and Assigned(nPH.FReader)) then
  begin
    WriteLog(Format('ͨ����[ %s ]��Ч.', [nTunnel]));
    Exit;
  end;

  nList := nPH.FReader.FBuffer.LockList;
  try
    nPH.FReader.DeleteFromBuffer(nPT.FTunnel, nList);
    //����δִ������

    New(nSend);
    nList.Add(nSend);

    FillChar(nSend^, cSizeDataSend, #0);
    //init

    with nSend^ do
    begin
      FHeader[0] := $0A;
      FHeader[1] := $55;
      FAddr := nPH.F485Addr;

      if nOnlyDisplay then
           FType := cFrame_Display
      else FType := cFrame_Control;

      with FData do
      begin
        FAddr := nPT.FTunnel;
        FDelay := nPT.FDelay;

        nStr := Copy(nTruck, 1, cMultiJS_Truck);
        nStr := nStr + StringOfChar(' ', cMultiJS_Truck - Length(nStr));
        StrPCopy(@FTruck[0], nStr);

        nPT.FDaiNum := nDaiNum;
        nStr := IntToStr(nDaiNum);
        nStr := StringOfChar('0', cMultiJS_DaiNum - Length(nStr)) + nStr;
        StrPCopy(@FDai[0], nStr);
      end;

      FEnd := $0D;
    end;

    Result := True;
  finally
    nPH.FReader.FBuffer.UnlockList;
  end;
end;

//Date: 2012-4-23
//Parm: ͨ����
//Desc: ֹͣnTunnel����
function TMultiJSManager.DelJS(const nTunnel: string): Boolean;
var nList: TList;
    nPH: PMultiJSHost;
    nPT: PMultiJSTunnel;
    nSend: PMultiJSDataSend;
begin
  Result := False;
  if not (GetTunnel(nTunnel, nPH, nPT) and Assigned(nPH.FReader)) then
  begin
    WriteLog(Format('ͨ����[ %s ]��Ч.', [nTunnel]));
    Exit;
  end;

  nList := nPH.FReader.FBuffer.LockList;
  try
    nPH.FReader.DeleteFromBuffer(nPT.FTunnel, nList);
    //����δִ������
    
    New(nSend);
    nList.Add(nSend);

    FillChar(nSend^, cSizeDataSend, #0);
    //init

    with nSend^ do
    begin
      FHeader[0] := $0A;
      FHeader[1] := $55;
      FAddr := nPH.F485Addr;
      FType := cFrame_Clear;

      FData.FAddr := nPT.FTunnel;
      FEnd := $0D;
    end;

    Result := True;
  finally
    nPH.FReader.FBuffer.UnlockList;
  end;
end;

//Date: 2013-07-22
//Parm: ����б�(tunnel=dai)
//Desc: ��ȡ��ͨ���ļ������
function TMultiJSManager.GetJSStatus(const nList: TStrings): Boolean;
var i,nIdx: Integer;
    nPHost: PMultiJSHost;
    nPTunnel: PMultiJSTunnel;
begin
  Result := True;
  nList.Clear;

  for i:=0 to FHosts.Count - 1 do
  begin
    nPHost := FHosts[i];
    for nIdx:=0 to nPHost.FTunnel.Count - 1 do
    begin
      nPHost.FReader.FBuffer.LockList;
      try
        nPTunnel := nPHost.FTunnel[nIdx];
        nList.Values[nPTunnel.FID] := IntToStr(nPTunnel.FHasDone);
      finally
        nPHost.FReader.FBuffer.UnlockList;
      end;
    end
  end;
end;

initialization
  gMultiJSManager := TMultiJSManager.Create;
finalization
  FreeAndNil(gMultiJSManager);
end.
