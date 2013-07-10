{*******************************************************************************
  ����: dmzn@163.com 2012-3-6
  ����: Զ�̷�����õ�Ԫ
*******************************************************************************}
unit UROModule;

{$I Link.Inc}
interface

uses
  SysUtils, Classes, SyncObjs, IdContext, uROClassFactories, uROServerIntf,
  IdGlobal, IdSocketHandle, IdBaseComponent, IdComponent, IdUDPBase,
  IdUDPServer, uROIndyTCPServer, uROClient, uROServer, uROIndyHTTPServer,
  uROSOAPMessage, uROBinMessage;

type
  TROServerType = (stTcp, stHttp);
  TROServerTypes = set of TROServerType;
  //��������
  
  PROModuleStatus = ^TROModuleStatus;
  TROModuleStatus = record
    FSrvTCP: Boolean;
    FSrvHttp: Boolean;               //����״̬
    FNumTCPActive: Cardinal;
    FNumTCPTotal: Cardinal;
    FNumTCPMax: Cardinal;
    FNumHttpActive: Cardinal;
    FNumHttpMax: Cardinal;
    FNumHttpTotal: Cardinal;         //���Ӽ���
    FNumConnection: Cardinal;
    FNumBusiness: Cardinal;          //�������
    FNumActionError: Cardinal;       //ִ�д������
  end;

  TROModule = class(TDataModule)
    ROBinMsg: TROBinMessage;
    ROSOAPMsg: TROSOAPMessage;
    ROHttp1: TROIndyHTTPServer;
    ROTcp1: TROIndyTCPServer;
    ServerUDP1: TIdUDPServer;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure ROHttp1AfterServerActivate(Sender: TObject);
    procedure ROTcp1InternalIndyServerConnect(AContext: TIdContext);
    procedure ROHttp1InternalIndyServerConnect(AContext: TIdContext);
    procedure ROHttp1InternalIndyServerDisconnect(AContext: TIdContext);
    procedure ROTcp1InternalIndyServerDisconnect(AContext: TIdContext);
    procedure ServerUDP1UDPRead(AThread: TIdUDPListenerThread;
      AData: TIdBytes; ABinding: TIdSocketHandle);
  private
    { Private declarations }
    FStatus: TROModuleStatus;
    //����״̬
    FSrvConnection: IROClassFactory;
    //���ӷ����೧
    FSrvBusiness: IROClassFactory;
    //���ݷ����೧
    FSyncLock: TCriticalSection;
    //ͬ����
    procedure RegClassFactories;
    //ע���೧
    procedure UnregClassFactories;
    //��ע��
    procedure BeforeStartServer;
    procedure AfterStopServer;
    //׼��,�ƺ�
    procedure WriteLog(const nLog: string);
    //��¼��־
  public
    { Public declarations }
    function ActiveServer(const nServer: TROServerTypes; const nActive: Boolean;
     var nMsg: string): Boolean;
    //�������
    function LockModuleStatus: PROModuleStatus;
    procedure ReleaseStatusLock;
    //��ȡ״̬
  end;

var
  ROModule: TROModule;

implementation

{$R *.dfm}

uses
  SrvBusiness_Impl, SrvConnection_Impl, MIT_Service_Invk, UMgrQUeue,
  UMgrLEDCard, UMgrHardHelper, U02NReader, UHardBusiness,
  UMgrRemoteVoice, USysLoger, UParamManager, UMgrDBConn, UMITConst;

//------------------------------------------------------------------------------
procedure TROModule.DataModuleCreate(Sender: TObject);
begin
  FSrvConnection := nil;
  FSrvBusiness := nil;
  FillChar(FStatus, SizeOf(FStatus), #0);
  FSyncLock := TCriticalSection.Create;
end;

procedure TROModule.DataModuleDestroy(Sender: TObject);
begin
  UnregClassFactories;
  FSyncLock.Free;
end;

procedure TROModule.WriteLog(const nLog: string);
begin
  gSysLoger.AddLog(TROModule, 'Զ�̷���ģ��', nLog);
end;

//Desc: ͬ������ģ��״̬
function TROModule.LockModuleStatus: PROModuleStatus;
begin
  FSyncLock.Enter;
  Result := @FStatus;
end;

//Desc: �ͷ�ģ��ͬ����
procedure TROModule.ReleaseStatusLock;
begin
  FSyncLock.Leave;
end;

//Desc: ����������
procedure TROModule.ROHttp1AfterServerActivate(Sender: TObject);
begin
  with LockModuleStatus^ do
  begin
    FSrvTCP := ROTcp1.Active;
    FSrvHttp := ROHttp1.Active;
    ReleaseStatusLock;
  end;
end;

//Desc: TCP������
procedure TROModule.ROTcp1InternalIndyServerConnect(AContext: TIdContext);
begin
  with LockModuleStatus^ do
  begin
    FNumTCPTotal := FNumTCPTotal + 1;
    FNumTCPActive := FNumTCPActive + 1;

    if FNumTCPActive > FNumTCPMax then
      FNumTCPMax := FNumTCPActive;
    ReleaseStatusLock;
  end;
end;

//Desc: Http������
procedure TROModule.ROHttp1InternalIndyServerConnect(AContext: TIdContext);
begin
  with LockModuleStatus^ do
  begin
    FNumHttpTotal := FNumHttpTotal + 1;
    FNumHttpActive := FNumHttpActive + 1;

    if FNumHttpActive > FNumHttpMax then
      FNumHttpMax := FNumHttpActive;
    ReleaseStatusLock;
  end;
end;

//Desc: TCP�Ͽ�
procedure TROModule.ROTcp1InternalIndyServerDisconnect(AContext: TIdContext);
begin
  with LockModuleStatus^ do
  begin
    FNumTCPActive := FNumTCPActive - 1;
    ReleaseStatusLock;
  end;
end;

//Desc: HTTP�Ͽ�
procedure TROModule.ROHttp1InternalIndyServerDisconnect(AContext: TIdContext);
begin
  with LockModuleStatus^ do
  begin
    FNumHttpActive := FNumHttpActive - 1;
    ReleaseStatusLock;
  end;
end;

//Desc: udpҵ��
procedure TROModule.ServerUDP1UDPRead(AThread: TIdUDPListenerThread;
  AData: TIdBytes; ABinding: TIdSocketHandle);
begin
  When2ClientUDPRead(AThread, AData, ABinding);
end;

//------------------------------------------------------------------------------
procedure Create_SrvBusiness(out anInstance : IUnknown);
begin
  anInstance := TSrvBusiness.Create;
end;

procedure Create_SrvConnection(out anInstance : IUnknown);
begin
  anInstance := TSrvConnection.Create;
end;

//Desc: ע���೧
procedure TROModule.RegClassFactories;
begin
  UnregClassFactories;
  //unreg first

  if Assigned(gParamManager.ActiveParam) then
  with gParamManager.ActiveParam.FPerform^ do
  begin
    FSrvConnection := TROPooledClassFactory.Create('SrvConnection',
                Create_SrvConnection, TSrvConnection_Invoker,
                FPoolSizeConn, FPoolBehaviorConn);
    FSrvBusiness := TROPooledClassFactory.Create('SrvBusiness',
                Create_SrvBusiness, TSrvBusiness_Invoker,
                FPoolSizeBusiness, FPoolBehaviorBusiness);
  end;
end;

//Desc: ע���೧
procedure TROModule.UnregClassFactories;
begin
  if Assigned(FSrvConnection) then
  begin
    UnRegisterClassFactory(FSrvConnection);
    FSrvConnection := nil;
  end;

  if Assigned(FSrvBusiness) then
  begin
    UnRegisterClassFactory(FSrvBusiness);
    FSrvBusiness := nil;
  end;
end;

//Desc: ����ǰ׼������
procedure TROModule.BeforeStartServer;
begin
  if (FSrvConnection = nil) or (FSrvBusiness = nil) then
    RegClassFactories;
  //xxxxx

  gClientUDPServer := ServerUDP1;
  //for global use
  
  with gClientUDPServer do
  begin
    Active := False;
    DefaultPort := gSysParam.F2ClientUDP;
    Active := True;
  end;

  with gParamManager do
  begin
    gDBConnManager.AddParam(gParamManager.ActiveParam.FDB^);
    gDBConnManager.MaxConn := gParamManager.ActiveParam.FPerform.FPoolSizeConn;
    //db

    gTruckQueueManager.StartQueue(gParamManager.ActiveParam.FDB.FID);
    //truck queue
    gCardManager.StartSender;
    //led display

    gHardwareHelper.OnProce := WhenReaderCardArrived;
    //gHardwareHelper.StartRead;
    //long reader

    g02NReader.OnCardIn := WhenReaderCardIn;
    g02NReader.OnCardOut := nil;
    g02NReader.StartReader;
    //near reader

    //gVoiceHelper.StartVoice;
    //voice
  end;
end;

//Date: 2010-8-7
//Parm: ��������;����;��ʾ��Ϣ
//Desc: ��nServerִ��nActive����
function TROModule.ActiveServer(const nServer: TROServerTypes;
  const nActive: Boolean; var nMsg: string): Boolean;
begin
  try
    if nActive and ((not ROTcp1.Active) and (not ROHttp1.Active)) then
      BeforeStartServer;
    //����ǰ׼��

    if stTcp in nServer then
    begin
      if nActive then
      begin
        ROTcp1.Active := False;
        ROTcp1.Port := gParamManager.ActiveParam.FPerform.FPortTCP;
      end;

      ROTcp1.Active := nActive;
    end;

    if stHttp in nServer then
    begin
      if nActive then
      begin
        ROHttp1.Active := False;
        ROHttp1.Port := gParamManager.ActiveParam.FPerform.FPortHttp;
      end;
      
      ROHttp1.Active := nActive;
    end;

    if (not ROTcp1.Active) and (not ROHttp1.Active) then
    begin
      UnregClassFactories;
      //ж���೧
      AfterStopServer;
      //�ر��ƺ�
    end;

    Result := True;
    nMsg := '';
  except
    on nE:Exception do
    begin
      Result := False;
      nMsg := nE.Message;
      WriteLog(nMsg);
    end;
  end;
end;

//Desc: ����رպ��ƺ���
procedure TROModule.AfterStopServer;
begin
  gVoiceHelper.StopVoice;
  //voice
  g02NReader.StopReader;
  g02NReader.OnCardIn := nil;
  g02NReader.OnCardOut := nil;

  gHardwareHelper.StopRead;
  gHardwareHelper.OnProce := nil;
  //reader

  gCardManager.StopSender;
  //led

  gTruckQueueManager.StopQueue;
  //queue
  gDBConnManager.Disconnection();
  //stop db pool
end;

end.
