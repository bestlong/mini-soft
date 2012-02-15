{*******************************************************************************
  ����: dmzn@163.com 2011-5-29
  ����: ����ģ��
*******************************************************************************}
unit UDataModule;

interface

uses
  Windows, SysUtils, Classes, DB, ADODB, SyncObjs, uROClient, uROClassFactories,
  uROBinMessage, uROServer, uROIndyTCPServer, uROIndyHTTPServer, uROServerIntf;

type
  PServerParam = ^TServerParam;
  TServerParam = record
    FConnStr: string;      //�����ַ���
    FConnMax: Integer;     //���ӳ�
    FSvrPort: Integer;     //�����˿�
    FObjMax: Integer;      //�����
    FWeekInt: Integer;     //���ڼ��
  end;
  
  TFDM = class(TDataModule)
    LocalConn: TADOConnection;
    SQLQuery: TADOQuery;
    SQLCmd: TADOQuery;
    ROSvr1: TROIndyHTTPServer;
    ROBin1: TROBinMessage;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    FParam: TServerParam;
    //������
    FConnLock: TCriticalSection;
    //������
    FConnections: array of TADOConnection;
    //���Ӷ���
    FUploadData: IROClassFactory;
    //���ݷ����೧
  protected
    procedure RegClassFactories;
    //ע���೧
    procedure UnregClassFactories;
    //��ע��
    function ExecuteSQL(const nSQL: string): Integer;
    function QuerySQL(const nSQL: string): TDataSet;
    //���ݿ���� 
  public
    { Public declarations }
    function GetConn: TADOConnection;
    procedure ReleaseConn(const nConn: TADOConnection);
    procedure ConnAction(const nOpen: Boolean; const nConnStr: string);
    //���ӹ���
    function ActiveServer(const nActive: Boolean; const nParam: PServerParam = nil): Boolean;
    //�������
  end;

var
  FDM: TFDM;

implementation

{$R *.dfm}

uses
  ZnMD5, ULibFun, DataMon_Invk, DataMon_Intf, DataService_Impl, USysConst,
  UMgrDBWriter;

const
  cConn_Idle = 10;
  cConn_Used = 27;

procedure TFDM.DataModuleCreate(Sender: TObject);
begin
  SetLength(FConnections, 0);
  FConnLock := TCriticalSection.Create;
end;

procedure TFDM.DataModuleDestroy(Sender: TObject);
begin
  FConnLock.Free;
end;

function TFDM.ExecuteSQL(const nSQL: string): Integer;
begin
  try
    SQLCmd.Close;
    SQLCmd.SQL.Text := nSQL;
    Result := SQLCmd.ExecSQL;
  except
    on E:Exception do
    begin
      Result := -1;
      ShowSyncLog(E.Message);
    end;
  end;
end;

function TFDM.QuerySQL(const nSQL: string): TDataSet;
begin
  SQLQuery.Close;
  SQLQuery.SQL.Text := nSQL;
  SQLQuery.Open;
  Result := SQLQuery;
end;

function TFDM.GetConn: TADOConnection;
var nIdx,nLen: Integer;
begin
  Result := nil;
  FConnLock.Enter;
  try
    for nIdx:=Low(FConnections) to High(FConnections) do
    if FConnections[nIdx].Tag = cConn_Idle then
    begin
      FConnections[nIdx].Tag := cConn_Used;
      Result := FConnections[nIdx];
    end;

    nLen := Length(FConnections);
    if (not Assigned(Result)) and (nLen < 25) then
    begin
      SetLength(FConnections, nLen + 1);
      FConnections[nLen] := TADOConnection.Create(Self);
      Result := FConnections[nLen];

      Result.Tag := cConn_Used;
      Result.LoginPrompt := False;
    end;

    if Assigned(Result) then
    begin
      if LocalConn.Connected and (not Result.Connected) then
      begin
        Result.Close;
        Result.ConnectionString := FParam.FConnStr;
        Result.Open;
      end;

      if not LocalConn.Connected then
        Result.Close;
      //xxxxx
    end;
  finally
    FConnLock.Leave;
  end;
end;

procedure TFDM.ConnAction(const nOpen: Boolean; const nConnStr: string);
var nIdx: Integer;
begin
  FConnLock.Enter;
  try
    for nIdx:=Low(FConnections) to High(FConnections) do
    begin
      if nOpen then
      begin
        FConnections[nIdx].Close;
        FConnections[nIdx].ConnectionString := nConnStr;
        FConnections[nIdx].Open;
      end else FConnections[nIdx].Close;
    end;
  finally
    FConnLock.Leave;
  end;
end;

procedure TFDM.ReleaseConn(const nConn: TADOConnection);
var nIdx: Integer;
begin
  FConnLock.Enter;
  try
    for nIdx:=Low(FConnections) to High(FConnections) do
    if FConnections[nIdx] = nConn then
    begin
      FConnections[nIdx].Tag := cConn_Idle;
      Break;
    end;
  finally
    FConnLock.Leave;
  end;
end;

//------------------------------------------------------------------------------
procedure Create_DataService(out anInstance : IUnknown);
begin
  anInstance := TDataService.Create;
end;

procedure TFDM.RegClassFactories;
begin
  UnregClassFactories;
  FUploadData := TROPooledClassFactory.Create('DataService',
                     Create_DataService, TDataService_Invoker,
                     FParam.FObjMax);
  //object pool
end;

procedure TFDM.UnregClassFactories;
begin
  if Assigned(FUploadData) then
  begin
    UnRegisterClassFactory(FUploadData);
    FUploadData := nil;
  end;
end;

//Date: 2011-5-29
//Parm: ����,ֹͣ;��ʾ����;����
//Desc: ������ֹͣ����
function TFDM.ActiveServer(const nActive: Boolean; const nParam: PServerParam): Boolean;
begin   
  if Assigned(nParam) then
    FParam := nParam^;
  Result := True;

  try
    if nActive then
    begin
      LocalConn.Close;
      LocalConn.ConnectionString := FParam.FConnStr;
      LocalConn.Connected := True;

      if not Assigned(gDBWriteManager) then
      begin
        gDBWriteManager := TDBWriteManager.Create;
        gDBWriteManager.WeekInterval := FParam.FWeekInt;
        if not gDBWriteManager.StartWriter(FParam.FConnStr) then Exit;
      end;

      if not Assigned(FUploadData) then
        RegClassFactories;
      //xxxxx

      ROSvr1.Active := False;
      ROSvr1.Port := FParam.FSvrPort;
      ROSvr1.Active := True;
    end else
    begin
      ROSvr1.Active := False;
      UnregClassFactories;

      LocalConn.Connected := False;
      FreeAndNil(gDBWriteManager);
    end;
  except
    Result := False;
  end;
end;

end.
