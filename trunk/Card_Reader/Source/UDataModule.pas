{*******************************************************************************
  ����: dmzn@163.com 2009-5-20
  ����: ���ݿ����ӡ�������� 
*******************************************************************************}
unit UDataModule;

{$I Link.Inc}
interface

uses
  Windows, Graphics, SysUtils, Classes, IniFiles, CPort, UWaitItem, NativeXml,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient;

type
  TReaderType = (rtIn, rtOut);
  //��,��

  PReaderItem = ^TReaderItem;
  TReaderItem = record
    FID: string[36];
    FName: string[36];
    FType: TReaderType;
    FGroup: Integer;
    FAddrNo: Integer;
  end;

  TCardAction = record
    FCardNo: string;
    FTime: TDateTime;
    FReader: PReaderItem;
  end;

  PCardLog = ^TCardLog;
  TCardLog = record
    FCardNo: array[0..31] of Char;
    FAction: Byte;
    FTime: TDateTime;
  end;

  TFDM = class;
  TCardSender = class(TThread)
  private
    FOwner: TFDM;
    //ӵ����
    FBuffer: TList;
    //���ͻ���
    FUser,FPwd: string;
    //�û���,����
    FClient: TIdTCPClient;
    //�ͻ���
    FWaiter: TWaitObject;
    //�ȴ�����
    FMsg: string;
    //��־��Ϣ
    FXML: TNativeXml;
    //�ĵ�����
    FStream: TMemoryStream;
    //������
  protected
    function DoExecute: Boolean;
    procedure Execute; override;
    //ִ�ж���
    procedure ShowLog(const nMsg: string);
    procedure DoShowLog;
    //��ʾ��־
  public
    constructor Create(const nOwner: TFDM);
    destructor Destroy; override;
    //�����ͷ�
    procedure StopMe;
    //ֹͣ�߳�
  end;

  TFDM = class(TDataModule)
    IdClient1: TIdTCPClient;
    ComPort1: TComPort;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
  private
    { Private declarations }
    FReaders: TList;
    //��ͷ�б�
    FCardLen: Integer;
    //���ų���
    FTimeLen: TDateTime;
    //��Գ�ʱ
    FActions: array of TCardAction;
    //�����б�
    FRcvData: string;
    //��������
    FBuffer: TThreadList;
    //���ͻ���
    FSender: TCardSender;
    //���Ͷ���
  protected
    procedure ClearBuffer(const nList: TList);
    procedure ClearReaders(const nFreeMe: Boolean);
    //������Դ
    function FindReader(const nID: string): Integer; overload;
    function FindReader(const nAddr: Integer): Integer; overload;
    //������ͷ
    function FindAction(const nCardNo: string): Integer;
    //��������
    procedure DoFindCard(const nCardData: string);
    //��������
  public
    { Public declarations }
    procedure AddReader(const nReader: PReaderItem);
    procedure DelReader(const nID: string);
    //���ɾ��
    procedure LoadReaders(const nIni: TIniFile);
    procedure SaveReaders(const nIni: TIniFile);
    //���뱣��
    function StartService(var nHint: string): Boolean;
    procedure StopService;
    //��ͣ����
    property Readers: TList read FReaders;
    //�������
  end;

var
  FDM: TFDM;

implementation

{$R *.dfm}

uses
  ULibFun, UFormMain;

const
  cBufferMax = 1000;
  //����ͻ���

//------------------------------------------------------------------------------
procedure TFDM.DataModuleCreate(Sender: TObject);
begin
  FReaders := TList.Create;
  FBuffer := TThreadList.Create;
end;

procedure TFDM.DataModuleDestroy(Sender: TObject);
begin
  StopService;
  ClearReaders(True);
  FBuffer.Free;
end;

procedure TFDM.ClearReaders(const nFreeMe: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FReaders.Count - 1 downto 0 do
  begin
    Dispose(PReaderItem(FReaders[nIdx]));
    FReaders.Delete(nIdx);
  end;

  if nFreeMe then FreeAndNil(FReaders);
end;

procedure TFDM.ClearBuffer(const nList: TList);
var nIdx: Integer;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    Dispose(PCardLog(nList[nIdx]));
    nList.Delete(nIdx);
  end;
end;

function TFDM.FindReader(const nID: string): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=FReaders.Count - 1 downto 0 do
  if CompareText(PReaderItem(FReaders[nIdx]).FID, nID) = 0 then
  begin
    Result := nIdx; Break;
  end;
end;

function TFDM.FindReader(const nAddr: Integer): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=FReaders.Count - 1 downto 0 do
  if PReaderItem(FReaders[nIdx]).FAddrNo = nAddr then
  begin
    Result := nIdx; Break;
  end;
end;

function TFDM.FindAction(const nCardNo: string): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=Low(FActions) to High(FActions) do
  if FActions[nIdx].FCardNo = nCardNo then
  begin
    Result := nIdx; Break;
  end;
end;

procedure TFDM.AddReader(const nReader: PReaderItem);
var nIdx: Integer;
begin
  nIdx := FindReader(nReader.FID);
  if nIdx > -1 then
  begin
    Dispose(PReaderItem(FReaders[nIdx]));
    FReaders[nIdx] := nReader;
  end else FReaders.Add(nReader);
end;

procedure TFDM.DelReader(const nID: string);
var nIdx: Integer;
begin
  nIdx := FindReader(nID);
  if nIdx > -1 then
  begin
    Dispose(PReaderItem(FReaders[nIdx]));
    FReaders.Delete(nIdx);
  end;
end;

procedure TFDM.LoadReaders(const nIni: TIniFile);
var nStr: string;
    nIdx: Integer;
    nReader: PReaderItem;
begin
  ClearReaders(False);
  nIdx := nIni.ReadInteger('Readers', 'Number', 0);

  while nIdx > 0 do
  begin
    New(nReader);
    FReaders.Add(nReader);

    Dec(nIdx);
    nStr := 'Reader_' + IntToStr(nIdx);

    nReader.FID := nIni.ReadString(nStr, 'Serial', 'id');
    nReader.FName := nIni.ReadString(nStr, 'Name', '');
    nReader.FType := TReaderType(nIni.ReadInteger(nStr, 'Type', Ord(rtIn)));
    nReader.FGroup := nIni.ReadInteger(nStr, 'Group', 0);
    nReader.FAddrNo := nIni.ReadInteger(nStr, 'Addr', 0);
  end;
end;

procedure TFDM.SaveReaders(const nIni: TIniFile);
var nStr: string;
    nIdx: Integer;
begin
  for nIdx:=FReaders.Count - 1 downto 0 do
  with PReaderItem(FReaders[nIdx])^ do
  begin
    nStr := 'Reader_' + IntToStr(nIdx);
    nIni.WriteString(nStr, 'Serial', FID);
    nIni.WriteString(nStr, 'Name', FName);
    nIni.WriteInteger(nStr, 'Type', Ord(FType));
    nIni.WriteInteger(nStr, 'Group', FGroup);
    nIni.WriteInteger(nStr, 'Addr', FAddrNo);
  end;
  nIni.WriteInteger('Readers', 'Number', FReaders.Count);
end;

//------------------------------------------------------------------------------
//Desc: ��������
function TFDM.StartService(var nHint: string): Boolean;
begin
  with fFormMain do
  begin
    nHint := '�����ɹ�';
    Result := True;

    SetLength(FActions, 0);
    FCardLen := StrToInt(EditNoLen.Text);
    FTimeLen := StrToInt(EditTimeLen.Text) / (60 * 24);

    with IdClient1 do
    begin
      Host := EditIP.Text;
      Port := StrToInt(EditPort.Text);

      ReadTimeout := 5 * 1000;
      try
        Connect;
      except
        Result := False;
        nHint := '�޷����ӵ�������'; Exit;
      end;
    end;

    with ComPort1 do
    begin
      Close;
      Port := EditComm.Text;
      BaudRate := StrToBaudRate(EditBaud.Text);

      try
        Open;
      except
        Result := False;
        nHint := '�޷���ָ������'; Exit;
      end;
    end;

    if Assigned(FSender) then
    begin
      Result := False;
      nHint := '�����߳��߼�����'; Exit;
    end;

    FSender := TCardSender.Create(Self);
    //�����߳�
  end;
end;

procedure TFDM.StopService;
begin
  ComPort1.Close;
  //ֹͣ����
  SetLength(FActions, 0);
  //��ն���

  if Assigned(FSender) then
  begin
    FSender.StopMe;
    FreeAndNil(FSender);
  end;
  //ֹͣ����

  try
    ClearBuffer(FBuffer.LockList);
  finally
    FBuffer.UnlockList;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ��ȡ������
procedure TFDM.ComPort1RxChar(Sender: TObject; Count: Integer);
var nStr: string;
    nIdx,nLen,nS,nE: Integer;
begin
  ComPort1.ReadStr(nStr, Count);
  FRcvData := FRcvData + nStr;
  nLen := Length(FRcvData);

  nS := 1;
  nE := 0;
  try
    for nIdx:=1 to nLen do
    begin
      if FRcvData[nIdx] = #2 then
      begin
        nS := nIdx;
      end else

      if FRcvData[nIdx] = #13 then
      begin
        nE := nIdx;
        if nE - nS >= FCardLen then
          DoFindCard(Copy(FRcvData, nS + 1, nE - nS - 3));
        //xxxxx
      end;
    end;
  finally
    if nE > 0 then
      System.Delete(FRcvData, 1, nE);
    //xxxxx
  end;
end;

//Desc: ת��nCardNo��ʽ
function ConvertCardNo(const nCardNo: string; const nCardLen: Integer): string;
begin
  Result := IntToStr(StrToInt('$' + nCardNo));
  Result := StringOfChar('0', nCardLen - Length(Result)) + Result;
end;

//Desc: ����ɼ���������(addr + card)
procedure TFDM.DoFindCard(const nCardData: string);
var nLog: PCardLog;
    nStr,nCardNo: string;
    nIdx,nInt,nLen: Integer;
begin
  nLen := Length(nCardData);
  nStr := Copy(nCardData, 1, nLen - FCardLen);
  if not IsNumber(nStr, False) then Exit;

  nInt := FindReader(StrToInt(nStr));
  if nInt < 0 then Exit;

  nCardNo := Copy(nCardData, nLen - FCardLen + 1, FCardLen);
  nCardNo := ConvertCardNo(nCardNo, FCardLen);

  if fFormMain.CheckLogs.Checked then
  begin
    nStr := '�ɼ�:[ %s ] ��ַ:[ %d ] ����:[ %s ]';
    nStr := Format(nStr, [nCardData, PReaderItem(FReaders[nInt]).FAddrNo, nCardNo]);
    fFormMain.ShowLog(nStr);
  end;
  
  nIdx := FindAction(nCardNo);
  if (nIdx < 0) or
     //����ʷ����
     (Now - FActions[nIdx].FTime >= FTimeLen) or
     //��Գ�ʱ
     (PReaderItem(FReaders[nInt]).FGroup <> FActions[nIdx].FReader.FGroup) or
     //����ͬһ����
     (PReaderItem(FReaders[nInt]).FType = FActions[nIdx].FReader.FType) then
     //ͬ��ͬ����
  begin
    if nIdx < 0 then
    begin
      nIdx := Length(FActions);
      SetLength(FActions, nIdx+1);
    end;

    with FActions[nIdx] do
    begin
      FCardNo := nCardNo;
      FTime := Now;
      FReader := FReaders[nInt];
    end;

    Exit;
  end;

  with PReaderItem(FReaders[nInt])^, FActions[nIdx], fFormMain do
  begin
    nStr := DateTime2Str(Now);
    if FType = rtIn then
         ShowRunStatus(nStr, nCardNo, '����(in)', FReader.FName + ' -> ' + FName)
    else ShowRunStatus(nStr, nCardNo, '����(out)', FName + ' <- ' + FReader.FName);

    with FBuffer.LockList do
    try
      if Count >= cBufferMax then
      begin
        fFormMain.ShowLog('�����̷��ͻ������');
        Exit;
      end;

      New(nLog);
      Add(nLog);

      StrPCopy(@nLog.FCardNo[0], nCardNo);
      nLog.FAction := Ord(FType);
      nLog.FTime := Now;
    finally
      FBuffer.UnlockList;
    end;
  end;
end;

//------------------------------------------------------------------------------
constructor TCardSender.Create(const nOwner: TFDM);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := nOwner;
  FClient := FOwner.IdClient1;
  FUser := fFormMain.EditUser.Text;
  FPwd := fFormMain.EditPwd.Text;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 5 * 1000;
  
  FBuffer := TList.Create;
  FXML := TNativeXml.Create;
  FStream := TMemoryStream.Create;
end;

destructor TCardSender.Destroy;
begin 
  FBuffer.Free;
  FXML.Free;
  FStream.Free;
  FWaiter.Free;
  inherited;
end;

procedure TCardSender.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;
  WaitFor;
end;

procedure TCardSender.ShowLog(const nMsg: string);
begin
  FMsg := nMsg;
  Synchronize(DoShowLog);
end;

procedure TCardSender.DoShowLog;
begin
  fFormMain.ShowLog(FMsg);
end;

procedure TCardSender.Execute;
var nList: TList;
    nIdx: Integer;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Break;

    if FBuffer.Count > cBufferMax then
    begin
      FOwner.ClearBuffer(FBuffer);
      ShowLog('���̷߳��ͻ������');
    end;

    nList := FOwner.FBuffer.LockList;
    try
      for nIdx:=nList.Count - 1 downto 0 do
        FBuffer.Add(nList[nIdx]);
      nList.Clear;
    finally
      FOwner.FBuffer.UnlockList;
    end;

    if (FBuffer.Count > 0) and DoExecute then
      FOwner.ClearBuffer(FBuffer);
    //��������
  except
    //ignor any error
  end;

  FOwner.ClearBuffer(FBuffer);
  FClient.Disconnect;
end;

function TCardSender.DoExecute: Boolean;
var nIdx: Integer;
    nNode: TXmlNode;
begin
  Result := False;
  if not FClient.Connected then
  try
    FClient.Connect;
  except
    on E:Exception do
    begin
      ShowLog('���ӷ�����ʧ��: ' + E.Message);
      Exit;
    end;
  end;

  with FXML do
  begin
    Clear;
    //XmlFormat := xfReadable;

    EncodingString := 'gb2312';
    VersionString := '1.0';
    Root.Name := 'CardItems';

    with Root.NodeNew('Verify') do
    begin
      NodeNew('User').ValueAsString := FUser;
      NodeNew('Password').ValueAsString := FPwd;
    end;

    nNode := Root.NodeNew('Items');
    //item node
    
    for nIdx:=FBuffer.Count - 1 downto 0 do
    with PCardLog(FBuffer[nIdx])^, nNode.NodeNew('Item') do
    begin
      NodeNew('CardNo').ValueAsString := FCardNo;
      NodeNew('Action').ValueAsInteger := FAction;
      NodeNew('Time').ValueAsString := DateTime2Str(FTime);
    end;
  end;

  FXML.SaveToStream(FStream);
  FClient.Socket.Write(FStream, FStream.Size, True);

  if FClient.Socket.ReadByte() = 0 then
       ShowLog('���̷߳������,Զ���ѽ���!')
  else ShowLog('���̷߳������,Զ�̾���!!');
  Result := True;
end;

end.
