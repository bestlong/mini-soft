{*******************************************************************************
  ����: dmzn@163.com 2013-3-7
  ����: ͨѶЭ��
*******************************************************************************}
unit USysProtocol;

interface

uses
  Windows, Classes, Graphics, SysUtils, SyncObjs, CPortTypes;
  
const
  cHeader_0           = $FE;
  cHeader_1           = $FE;
  cHeader_2           = $FE;                  //��ʼ�ֽ�
  cFooter_0           = $FD;                  //�����ֽ�
  cFrameIDMax         = $FC;                  //�����
  cAddr_Broadcast     = $7F;                  //�㲥��ַ
  
  cFun_Query          = $01;                  //��ѯָ��
  cFun_Repair         = $02;                  //��ָ֡��
  cFun_SetIndex       = $03;                  //���õ�ַ
  cFun_DevLocate      = $04;                  //װ�ö�λ
  cFun_SetTime        = $05;                  //����ʱ��
  cFun_BreakPipeMin   = $06;                  //�ƶ������
  cFun_BreakPipeMax   = $07;                  //�ƶ�������
  cFun_BreakPotMin    = $08;                  //�ƶ������
  cFun_BreakPotMax    = $09;                  //�ƶ�������
  cFun_TotalPipeMin   = $0A;                  //�ܷ�����
  cFun_TotalPipeMax   = $0B;                  //�ܷ������
  cFun_Reset          = $0C;                  //��������

type
  PDataItem = ^TDataItem;
  TDataItem = record
    FHeader: array[0..2] of Byte;             //��ʼ��
    FIndex: Byte;                             //��ַ����
    FFunction: Byte;                          //������
    FDataLen: Byte;                           //���ݳ���
    FData: array[0..63] of Byte;              //����
    FCRC: Byte;                               //У��ֵ
    FFooter: Byte;                            //������
  end;

  PBufferData = ^TBufferData;
  TBufferData = record
    FUsed: Boolean;                           //�Ƿ�ʹ��
    FData: PDataItem;                         //����ָ��
  end;

  TDataBytes = array of Byte;                 //�ֽ���

const
  cSize_DataItem = SizeOf(TDataItem);         //�ֽ���

type
  TDataBufferManager = class(TObject)
  private
    FBuffer: TList;
    //���ݻ���
    FSyncLock: TCriticalSection;
    //ͬ������
  protected
    procedure ClearBuffer(const nFree: Boolean);
    //������Դ
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    function LockData: PDataItem;
    procedure ReleaseData(const nData: PDataItem);
    //�����ͷ�
  end;

//------------------------------------------------------------------------------
const
  cCOM_BaudRate: TBaudRate = br4800;          //������
  cCOM_DataBits: TDataBits = dbEight;         //����λ
  cCOM_StopBits: TStopBits = sbOneStopBit;    //ֹͣλ

type
  TItemType = (itBreakPipe, itBreakPot, itTotalPipe);
  //������
  TItemFlag = (ifRoot, ifPort, ifDevice, ifDeviceUnusedRoot, ifDeviceUnused);
  //���

  PCarriageItem = ^TCarriageItem;
  TCarriageItem = record
    FItemID: string;                          //�����ʶ
    FName: string;                            //��������
    FPostion: Word;                           //����λ��

    FTypeID: Word;
    FTypeName: string;                        //��������
    FModeID: Word;
    FModeName: string;                        //�����ͺ�
  end;

  TDeviceData = record
    FNum: Word;                               //����
    FData: Word;                              //����
  end;

  PDeviceItem = ^TDeviceItem;
  TDeviceItem = record
    FItemID: string;                          //�豸��ʶ
    FCOMPort: string;                         //���ڴ���
    FIndex: Byte;                             //��ַ����
    FSerial: string;                          //װ�ñ��

    FCarriageID: string;                      //�����ʶ
    FCarriage: PCarriageItem;                 //���ڳ���

    FColorBreakPipe: TColor;
    FColorBreakPot: TColor;
    FColorTotalPipe: TColor;                  //������ɫ

    FLastActive: Int64;                       //�ϴλ
    FLastFrameID: Byte;                       //�ϴ�֡��
    FDeviceUsed: Boolean;                     //��ʹ��
    FDeviceValid: Boolean;                    //�豸��Ч

    //--------------------------------------------------------------------------
    FTotalPipeTimeBase: TDateTime;            //ʱ���׼
    FTotalPipeTimeNow: TDateTime;             //��ǰʱ��
    FTotalPipe: Word;                         //�ܷ��

    FBreakPipeTimeBase: TDateTime;            //ʱ���׼
    FBreakPipeTimeNow: TDateTime;             //��ǰʱ��
    FBreakPipeNum: Word;
    FBreakPipe: array[0..31] of TDeviceData;  //�ƶ���

    FBreakPotTimeBase: TDateTime;             //ʱ���׼
    FBreakPotTimeNow: TDateTime;              //��ǰʱ��
    FBreakPotNum: Word;
    FBreakPot: array[0..31] of TDeviceData;   //�ƶ���
  end;

  PCOMParam = ^TCOMParam;
  TCOMParam = record
    FItemID: string;                          //���ڱ�ʶ
    FName: string;                            //��������
    FPostion: Word;                           //����λ��

    FPortName: string;                        //ͨ�Ŷ˿�
    FBaudRate: TBaudRate;                     //������
    FDataBits: TDataBits;                     //����λ
    FStopBits: TStopBits;                     //ֹͣλ

    FRunFlag: string;                         //���б��
    FLastActive: Int64;                       //�ϴλ
    FLastQuery: Int64;                        //�ϴβ�ѯ
    FCOMValid: Boolean;                       //������Ч
  end;

  PCOMItem = ^TCOMItem;
  TCOMItem = record
    FParam: PCOMParam;                        //���ڲ���
    FDevices: TList;                          //�豸�б�
  end;

type
  TDeviceManager = class(TObject)
  private
    FCarriages: TList;
    //�����б�
    FDevices: TList;
    //�豸���
    FParams: TList;
    //�����б�
    FPorts: TList;
    //�����б�
    FSyncLock: TCriticalSection;
    //ͬ������
  protected
    procedure ClearList(const nFree: Boolean);
    procedure ClearPorts(const nFree: Boolean);
    //�ͷ���Դ
    function FindCarriage(const nItemID: string): Integer;
    function FindDevice(const nItemID: string): Integer;
    function FindParam(const nPort: string): Integer;
    //��������
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure AddCarriage(const nItem: TCarriageItem);
    //��ɾ����
    procedure AddDevice(const nItem: TDeviceItem);
    //��ɾ�豸
    procedure AddParam(const nItem: TCOMParam);
    //��ɾ����
    procedure AdjustDevice;
    //�����豸
    function LockCarriageList: TList;
    function LockDeviceList: TList;
    function LockPortList: TList;  
    procedure ReleaseLock;
    //�豸�б�
  end;

var
  gDeviceManager: TDeviceManager = nil;
  gDataManager: TDataBufferManager = nil;
  //ȫ��ʹ��

resourcestring
  sBreakPipe          = '�ƶ���';
  sBreakPot           = '�ƶ���';
  sTotalPipe          = '�ܷ��';             //��������
  
implementation

constructor TDataBufferManager.Create;
begin
  FBuffer := TList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TDataBufferManager.Destroy;
begin
  ClearBuffer(True);
  FreeAndNil(FSyncLock);
  inherited;
end;

//Desc: �������ݻ���
procedure TDataBufferManager.ClearBuffer(const nFree: Boolean);
var nIdx: Integer;
    nItem: PBufferData;
begin
  for nIdx:=FBuffer.Count - 1 downto 0 do
  begin
    nItem := FBuffer[nIdx];
    FBuffer.Delete(nIdx);

    Dispose(nItem.FData);
    Dispose(nItem);
  end;

  if nFree then
    FreeAndNil(FBuffer);
  //free list
end;

//Date: 2013-3-7
//Parm: none
//Desc: ��������
function TDataBufferManager.LockData: PDataItem;
var nIdx: Integer;
    nItem: PBufferData;
begin
  Result := nil;
  nItem := nil;
  //init

  FSyncLock.Enter;
  try
    for nIdx:=0 to FBuffer.Count - 1 do
     if not PBufferData(FBuffer[nIdx]).FUsed then
     begin
       nItem := FBuffer[nIdx];
       Break;
     end;
    //not used data

    if not Assigned(nItem) then
    begin
      New(nItem);
      New(nItem.FData);
      FBuffer.Add(nItem);
    end;
  finally
    if Assigned(nItem) then
    begin
      nItem.FUsed := True;
      Result := nItem.FData;
    end;
    FSyncLock.Leave;
  end;   
end;

//Date: 2013-3-7
//Parm: ����
//Desc: ���nData����
procedure TDataBufferManager.ReleaseData(const nData: PDataItem);
var nIdx: Integer;
    nItem: PBufferData;
begin
  if Assigned(nData) then
  try
    FSyncLock.Enter;
    //sync

    for nIdx:=0 to FBuffer.Count - 1 do
    begin
      nItem := FBuffer[nIdx];
      if nItem.FData = nData then
      begin
        nItem.FUsed := False;
        Exit;
      end;
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//------------------------------------------------------------------------------
constructor TDeviceManager.Create;
begin
  FCarriages := TList.Create;
  FDevices := TList.Create;
  FParams := TList.Create;
  FPorts := TList.Create;

  FSyncLock := TCriticalSection.Create;
  //new lock
end;

destructor TDeviceManager.Destroy;
begin
  ClearList(True);
  ClearPorts(True);
  
  FreeAndNil(FSyncLock);
  inherited;
end;

//Desc: ������Դ
procedure TDeviceManager.ClearList(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FCarriages.Count - 1 downto 0 do
  begin
    Dispose(PCarriageItem(FCarriages[nIdx]));
    FCarriages.Delete(nIdx);
  end;

  for nIdx:=FDevices.Count - 1 downto 0 do
  begin
    Dispose(PDeviceItem(FDevices[nIdx]));
    FDevices.Delete(nIdx);
  end;

  for nIdx:=FParams.Count - 1 downto 0 do
  begin
    Dispose(PCOMParam(FParams[nIdx]));
    FParams.Delete(nIdx);
  end;

  if nFree then
  begin
    FreeAndNil(FCarriages);
    FreeAndNil(FDevices);
    FreeAndNil(FParams);
  end;
end;

//Date: 2013-3-7
//Desc: ����˿��б�
procedure TDeviceManager.ClearPorts(const nFree: Boolean);
var nIdx: Integer;
    nCOM: PCOMItem;
begin
  for nIdx:=FPorts.Count - 1 downto 0 do
  begin
    nCOM := FPorts[nIdx];
    nCOM.FDevices.Free;

    Dispose(nCOM);
    FPorts.Delete(nIdx);
  end;

  if nFree then
    FreeAndNil(FPorts);
  //free list
end;

//Date: 2013-3-7
//Parm: �����ʶ
//Desc: ����nItemID������������,��������
function TDeviceManager.FindCarriage(const nItemID: string): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=FCarriages.Count - 1 downto 0 do
  if CompareText(nItemID, PCarriageItem(FCarriages[nIdx]).FItemID) = 0 then
  begin
    Result := nIdx;
    Break;
  end;
end;

//Date: 2013-3-7
//Parm: �豸��ʶ
//Desc: ����nItemID�����豸��Ϣ,��������
function TDeviceManager.FindDevice(const nItemID: string): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=FDevices.Count - 1 downto 0 do
  if CompareText(nItemID, PDeviceItem(FDevices[nIdx]).FItemID) = 0 then
  begin
    Result := nIdx;
    Break;
  end;
end;

//Date: 2013-3-7
//Parm: ������ʶ
//Desc: ����nItemID��������,��������
function TDeviceManager.FindParam(const nPort: string): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=FParams.Count - 1 downto 0 do
  if CompareText(nPort, PCOMParam(FParams[nIdx]).FPortName) = 0 then
  begin
    Result := nIdx;
    Break;
  end;
end;

//Date: 2013-3-7
//Parm: ��������
//Desc: ���nItem����
procedure TDeviceManager.AddCarriage(const nItem: TCarriageItem);
var nIdx: Integer;
    nP: PCarriageItem;
begin
  FSyncLock.Enter;
  try
    nIdx := FindCarriage(nItem.FItemID);
    if nIdx < 0 then
    begin
      New(nP);
      FCarriages.Add(nP);
    end else nP := FCarriages[nIdx];

    nP^ := nItem;
    //new data
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2013-3-7
//Parm: �豸����
//Desc: ���nItem�豸
procedure TDeviceManager.AddDevice(const nItem: TDeviceItem);
var nIdx: Integer;
    nP: PDeviceItem;
begin
  FSyncLock.Enter;
  try
    nIdx := FindDevice(nItem.FItemID);
    if nIdx < 0 then
    begin
      New(nP);
      FDevices.Add(nP);
    end else nP := FDevices[nIdx];

    nP^ := nItem;
    nP.FDeviceValid := True;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2013-3-7
//Parm: ���ڲ���
//Desc: ���nItem����
procedure TDeviceManager.AddParam(const nItem: TCOMParam);
var nIdx: Integer;
    nP: PCOMParam;
begin
  FSyncLock.Enter;
  try
    nIdx := FindParam(nItem.FPortName);
    if nIdx < 0 then
    begin
      New(nP);
      FParams.Add(nP);
    end else nP := FParams[nIdx];

    nP^ := nItem;
    nP.FCOMValid := True;
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: ��������
function TDeviceManager.LockCarriageList: TList;
begin
  FSyncLock.Enter;
  Result := FCarriages;
end;

//Desc: �����豸
function TDeviceManager.LockDeviceList: TList;
begin
  FSyncLock.Enter;
  Result := FDevices;
end;

//Desc: ��������
function TDeviceManager.LockPortList: TList;
begin
  FSyncLock.Enter;
  Result := FPorts;
end;

//Desc: �������
procedure TDeviceManager.ReleaseLock;
begin
  FSyncLock.Leave;
end;

//Date: 2013-3-8
//Parm: �豸;�豸�б�
//Desc: ����nDevice��nList��Ӧ�ò����λ��
function GetDevicePos(const nDevice: PDeviceItem; const nList: TList): Integer;
var nIdx: Integer;
    nP: PCarriageItem;
begin
  Result := nList.Count;
  if not Assigned(nDevice.FCarriage) then Exit;

  for nIdx:=0 to nList.Count - 1 do
  begin
    nP := PDeviceItem(nList[nIdx]).FCarriage;

    if Assigned(nP) and (nP.FPostion > nDevice.FCarriage.FPostion) then
    begin
      Result := nIdx;
      Break;
    end;
  end;
end;

//Date: 2013-3-8
//Parm: ������;�����б�
//Desc: ����nParam��nList��Ӧ�ò����λ��
function GetParamPos(const nParam: PCOMParam; const nList: TList): Integer;
var nIdx: Integer;
begin
  Result := nList.Count;
  //default is last

  for nIdx:=0 to nList.Count - 1 do
  if PCOMItem(nList[nIdx]).FParam.FPostion > nParam.FPostion then
  begin
    Result := nIdx;
    Break;
  end;
end;

//Desc: �����ֲ�����������
procedure TDeviceManager.AdjustDevice;
var i,nIdx,nPos: Integer;
    nCOM: PCOMItem;
    nDevice: PDeviceItem;
begin
  FSyncLock.Enter;
  try
    for i:=FDevices.Count - 1 downto 0 do
    begin
      nDevice := FDevices[i];
      nDevice.FDeviceUsed := False;
      nIdx := FindCarriage(nDevice.FCarriageID);

      if nIdx < 0 then
           nDevice.FCarriage := nil
      else nDevice.FCarriage := FCarriages[nIdx];
    end;

    ClearPorts(False);
    //init list
    
    for i:=0 to FParams.Count - 1 do
    begin
      if not PCOMParam(FParams[i]).FCOMValid then Continue;
      //invalid 

      New(nCOM);
      FPorts.Insert(GetParamPos(FParams[i], FPorts), nCOM);

      nCOM.FParam := FParams[i];
      nCOM.FDevices := TList.Create;

      for nIdx:=0 to FDevices.Count - 1 do
      begin
        nDevice := FDevices[nIdx];
        if not nDevice.FDeviceValid then Continue;
        
        if CompareText(nCOM.FParam.FPortName, nDevice.FCOMPort) = 0 then
        begin
          nDevice.FDeviceUsed := Assigned(nDevice.FCarriage);
          nPos := GetDevicePos(nDevice, nCOM.FDevices);
          nCOM.FDevices.Insert(nPos, nDevice);               
        end; //link
      end;
    end;
  finally
    FSyncLock.Leave;
  end;   
end;

initialization
  gDataManager := TDataBufferManager.Create;
  gDeviceManager := TDeviceManager.Create;
finalization
  FreeAndNil(gDeviceManager);
  FreeAndNil(gDataManager);
end.

