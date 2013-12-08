{*******************************************************************************
  ����: dmzn@163.com 2013-12-07
  ����: ����ҵ����������
*******************************************************************************}
unit UMITWorker;

{$I Link.Inc}
interface

uses
  Windows, Classes, SysUtils, ULibFun, UMgrDBConn, UBusinessWorker,
  UBusinessPacker, UBusinessConst;

type
  TMITWorkerBase = class(TBusinessWorkerBase)
  protected
    FInBase: PBWDataBase;
    FOutBase: PBWDataBase;
    //��γ���
    FInInfo: TBWWorkerInfoType;
    FOutInfo: TBWWorkerInfoType;
    //������Ϣ
    FDataResult: string;
    //�������
    procedure SetIOData(const nIn,nOut: Pointer); virtual;
    procedure GetIOData(var nIn,nOut: Pointer); virtual;
    function DoMITWork: Boolean; virtual; abstract;
    //����ҵ��
    procedure SetOutBaseInfo;
    //�����Ϣ
  public
    class procedure SetResult(const nData: PBWDataBase; 
      const nResult: Boolean; const nCode,nDesc: string);
    //�����ֵ
    function DoWork(var nData: string): Boolean; overload; override;
    function DoWork(const nIn,nOut: Pointer): Boolean; overload; override;
    //ִ��ҵ��
  end;

  TMITDBWorker = class(TMITWorkerBase)
  protected
    FErrNum: Integer;
    //������
    FDBConn: PDBWorker;
    //����ͨ��
    FDataOutNeedUnPack: Boolean;
    //�������
    function VerifyParamIn: Boolean; virtual;
    //��֤���
    function DoAfterDBWork(const nResult: Boolean): Boolean; virtual;
    function DoDBWork: Boolean; virtual; abstract;
    //����ҵ��
  public
    function DoMITWork: Boolean; override;
    //ִ��ҵ��
  end;

  TClientWorkerBase = class(TBusinessWorkerBase)
  protected
    FListA,FListB: TStrings;
    //�ַ��б�
    procedure WriteLog(const nEvent: string);
    //��¼��־
    function ErrDescription(const nCode, nDesc: string;
      const nInclude: TDynamicStrArray): string;
    //��������
    function MITWork(var nData: string): Boolean;
    //ִ��ҵ��
    function GetFixedServiceURL: string; virtual;
    //�̶���ַ
  public
    constructor Create; override;
    destructor destroy; override;
    //�����ͷ�
    function DoWork(const nIn, nOut: Pointer): Boolean; override;
    //ִ��ҵ��
  end;

implementation

uses
  UMgrParam, UMgrChannel, UChannelChooser, UPlugWorker, USysLoger,
  MIT_Service_Intf;

//Date: 2013-12-07
//Parm: ���;����
//Desc: ִ����nInΪ��ε�ҵ��,���nOut���
function TMITWorkerBase.DoWork(const nIn, nOut: Pointer): Boolean;
begin
  FInBase := nIn;
  FOutBase := nOut;

  FOutInfo := itFinal;
  SetIOData(FInBase, FOutBase);
  //delivery param

  FPacker.InitData(FOutBase, False, True, False);
  //init exclude base
  
  FOutBase^ := FInBase^;
  SetResult(FOutBase, True, 'S.00', 'ҵ�����');

  Result := DoMITWork;
  //do business

  SetOutBaseInfo;
  //fill woker info
end;

//Date: 2013-12-07
//Parm: ���������
//Desc: ��ȡ�������ݿ��������Դ
function TMITWorkerBase.DoWork(var nData: string): Boolean;
begin
  FOutInfo := itFinal;   
  GetIOData(Pointer(FInBase), Pointer(FOutBase));
  FPacker.UnPackIn(nData, FInBase);

  FPacker.InitData(FOutBase, False, True, False);
  //init exclude base
  
  FOutBase^ := FInBase^;
  SetResult(FOutBase, True, 'S.00', 'ҵ�����');

  Result := DoMITWork;
  //do business

  if Result then
  begin
    SetOutBaseInfo;
    //fill woker info
    nData := FPacker.PackOut(FOutBase);
    //pack data
  end else
  begin
    nData := FDataResult;
    //return error message
  end;
end;

//Date: 2013-12-07
//Parm: ����;���;������;��������
//Desc: ����nData���������
class procedure TMITWorkerBase.SetResult(const nData: PBWDataBase;
  const nResult: Boolean; const nCode,nDesc: string);
begin
  with nData^ do
  begin
    FResult := nResult;
    FErrCode := nCode;
    FErrDesc := nDesc;
  end;
end;

//Desc: �������ȡ��γ���
procedure TMITWorkerBase.GetIOData(var nIn,nOut: Pointer);
var nStr: string;
begin
  nStr := '��������[ %s ]��֧��Զ�̵���.';
  nStr := Format(nStr, [FunctionName]);
  raise Exception.Create(nStr);
end;

//Desc: ����������γ���
procedure TMITWorkerBase.SetIOData(const nIn,nOut: Pointer);
var nStr: string;
begin
  nStr := '��������[ %s ]��֧�ֱ��ص���.';
  nStr := Format(nStr, [FunctionName]);
  raise Exception.Create(nStr);
end;

//Desc: ��д�����Ϣ
procedure TMITWorkerBase.SetOutBaseInfo;
  procedure SetWorkerInfo(var nInfo: TBWWorkerInfo);
  begin
    with nInfo do
    begin
      FUser   := gPlugRunParam.FLocalName;
      FIP     := gPlugRunParam.FLocalIP;
      FMAC    := gPlugRunParam.FLocalMAC;
      FTime   := FWorkTime;
      FKpLong := GetTickCount - FWorkTimeInit;
    end;
  end;
begin
  case FOutInfo of
   itFrom  : SetWorkerInfo(FOutBase.FFrom);
   itVia   : SetWorkerInfo(FOutBase.FVia);
   itFinal : SetWorkerInfo(FOutBase.FFinal);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2013-12-07
//Desc: ��ȡ�������ݿ��������Դ
function TMITDBWorker.DoMITWork: Boolean;
begin
  Result := False;
  FDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    FDBConn := gDBConnManager.GetConnection(FDB.FID, FErrNum);
    if not Assigned(FDBConn) then
    begin
      FDataResult := '����[ %s ]���ݿ�ʧ��(ErrCode: %d).';
      FDataResult := Format(FDataResult, [FDB.FID, FErrNum]);
      
      SetResult(FOutBase, False, 'E.00', FDataResult);
      Exit;
    end;

    if not FDBConn.FConn.Connected then
      FDBConn.FConn.Connected := True;
    //conn db

    FDataOutNeedUnPack := False;
    //
    if not VerifyParamIn then Exit;
    //invalid input parameter

    Result := DoDBWork;
    //execute worker

    if Result then
    begin
      if FDataOutNeedUnPack then
        FPacker.UnPackOut(FDataResult, FOutBase);
      Result := DoAfterDBWork(True);
    end else DoAfterDBWork(False);
  finally
    gDBConnManager.ReleaseConnection(FDBConn);
  end;
end;

//Desc: ���ݿ������Ϻ���βҵ��
function TMITDBWorker.DoAfterDBWork( const nResult: Boolean): Boolean;
begin
  Result := True;
end;

//Desc: ��֤����Ƿ���Ч
function TMITDBWorker.VerifyParamIn: Boolean;
begin
  Result := True;
end;

//------------------------------------------------------------------------------
procedure TClientWorkerBase.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(ClassType, '�ͻ�ҵ�����', nEvent);
end;

constructor TClientWorkerBase.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  inherited;
end;

destructor TClientWorkerBase.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  inherited;
end;

//Date: 2012-3-11
//Parm: ���;����
//Desc: ִ��ҵ�񲢶��쳣������
function TClientWorkerBase.DoWork(const nIn, nOut: Pointer): Boolean;
var nStr: string;
    nParam: string;
    nArray: TDynamicStrArray;
begin
  with PBWDataBase(nIn)^ do
  begin
    nParam := FParam;
    FPacker.InitData(nIn, True, False);

    with FFrom do
    begin
      FUser   := gPlugRunParam.FLocalName;
      FIP     := gPlugRunParam.FLocalIP;
      FMAC    := gPlugRunParam.FLocalMAC;
      FTime   := FWorkTime;
      FKpLong := FWorkTimeInit;
    end;
  end;

  nStr := FPacker.PackIn(nIn);
  Result := MITWork(nStr);
end;

//Date: 2012-3-20
//Parm: ����;����
//Desc: ��ʽ����������
function TClientWorkerBase.ErrDescription(const nCode, nDesc: string;
  const nInclude: TDynamicStrArray): string;
var nIdx: Integer;
begin
  FListA.Text := StringReplace(nCode, #9, #13#10, [rfReplaceAll]);
  FListB.Text := StringReplace(nDesc, #9, #13#10, [rfReplaceAll]);

  if FListA.Count <> FListB.Count then
  begin
    Result := '��.����: ' + nCode + #13#10 +
              '   ����: ' + nDesc + #13#10#13#10;
  end else Result := '';

  for nIdx:=0 to FListA.Count - 1 do
  if (Length(nInclude) = 0) or (StrArrayIndex(FListA[nIdx], nInclude) > -1) then
  begin
    Result := Result + '��.����: ' + FListA[nIdx] + #13#10 +
                       '   ����: ' + FListB[nIdx] + #13#10#13#10;
  end;
end;

//Desc: ǿ��ָ�������ַ
function TClientWorkerBase.GetFixedServiceURL: string;
begin
  Result := '';
end;

//Date: 2012-3-9
//Parm: �������
//Desc: ����MITִ�о���ҵ��
function TClientWorkerBase.MITWork(var nData: string): Boolean;
var nChannel: PChannelItem;
begin
  Result := False;
  nChannel := nil;
  try
    nChannel := gChannelManager.LockChannel(cBus_Channel_Business);
    if not Assigned(nChannel) then
    begin
      nData := '����MIT����ʧ��(BUS-MIT No Channel).';
      Exit;
    end;

    with nChannel^ do
    while True do
    try
      if not Assigned(FChannel) then
        FChannel := CoSrvBusiness.Create(FMsg, FHttp);
      //xxxxx

      if GetFixedServiceURL = '' then
           FHttp.TargetURL := gChannelChoolser.ActiveURL
      else FHttp.TargetURL := GetFixedServiceURL;

      Result := ISrvBusiness(FChannel).Action(GetFlagStr(cWorker_GetMITName),
                                              nData);
      //call mit funciton
      Break;
    except
      on E:Exception do
      begin
        if (GetFixedServiceURL <> '') or
           (gChannelChoolser.GetChannelURL = FHttp.TargetURL) then
        begin
          nData := Format('%s(BY %s ).', [E.Message, gPlugRunParam.FLocalName]);
          WriteLog('Function:[ ' + FunctionName + ' ]' + E.Message);
          Exit;
        end;
      end;
    end;
  finally
    gChannelManager.ReleaseChannel(nChannel);
  end;
end;

end.
