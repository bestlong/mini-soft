{*******************************************************************************
  ����: dmzn@163.com 2012-4-22
  ����: Ӳ������ҵ��
*******************************************************************************}
unit UHardBusiness;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, SysUtils, IdGlobal, IdSocketHandle, IdUDPServer,
  UMgrDBConn, UMgrHardHelper, U02NReader,
  UParamManager, UBusinessWorker, UBusinessConst, UBusinessPacker;

procedure WhenReaderCardArrived(const nReader: THHReaderItem);
//���¿��ŵ����ͷ
procedure WhenReaderCardIn(nHost: TReaderHost; nCard: TReaderCard);
//�ֳ���ͷ���¿���
procedure When2ClientUDPRead(AThread: TIdUDPListenerThread; AData: TIdBytes;
  ABinding: TIdSocketHandle);
//�ͻ��������ݵ���

implementation

uses
  ULibFun, USysDB, USysLoger;

//------------------------------------------------------------------------------
procedure WriteHardHelperLog(const nEvent: string);
begin
  gSysLoger.AddLog(THardwareHelper, 'Ӳ���ػ�����', nEvent);
end;

//Date: 2013-07-08
//Parm: �ſ���
//Desc: ��nCard����������
procedure MakeTruckIn(const nCard: string);
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := cBC_MakeTruckIn;
    nIn.FData := nCard;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);

    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessCommand);
    if not nWorker.WorkActive(nStr) then
    begin
      WriteHardHelperLog(nStr);
    end;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorkder(nWorker);
  end;
end;

//Date: 2013-07-08
//Parm: ����;��ͷ;��ӡ��
//Desc: ��nCard���г���
procedure MakeTruckOut(const nCard: string);
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := cBC_MakeTruckOut;
    nIn.FData := nCard;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);

    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessCommand);
    if not nWorker.WorkActive(nStr) then
    begin
      WriteHardHelperLog(nStr);
    end;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorkder(nWorker);
  end;
end;

//Date: 2012-4-22
//Parm: ��ͷ����
//Desc: ��nReader�����Ŀ��������嶯��
procedure WhenReaderCardArrived(const nReader: THHReaderItem);
var nStr: string;
    nErrNum: Integer;
    nDBConn: PDBWorker;
begin
  nDBConn := nil;
  {$IFDEF DEBUG}
  WriteHardHelperLog('WhenReaderCardArrived����.');
  {$ENDIF}

  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
    if not Assigned(nDBConn) then
    begin
      WriteHardHelperLog('����HM���ݿ�ʧ��(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nStr := 'Select C_Card From $TB Where C_Card=''$CD'' or ' +
            'C_Card2=''$CD'' or C_Card3=''$CD''';
    nStr := MacroValue(nStr, [MI('$TB', sTable_Card), MI('$CD', nReader.FCard)]);

    with gDBConnManager.WorkerQuery(nDBConn, nStr) do
    if RecordCount > 0 then
    begin
      nStr := Fields[0].AsString;
    end else
    begin
      nStr := Format('�ſ���[ %s ]ƥ��ʧ��.', [nReader.FCard]);
      WriteHardHelperLog(nStr);
      Exit;
    end;

    try
      if nReader.FType = rtIn then
      begin
        MakeTruckIn(nStr);
      end else

      if nReader.FType = rtOut then
      begin
        MakeTruckOut(nStr);
      end;
    except
      On E:Exception do
      begin
        WriteHardHelperLog(E.Message);
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(FDB.FID, nDBConn);
  end;
end;

//------------------------------------------------------------------------------
procedure WriteNearReaderLog(const nEvent: string);
begin
  gSysLoger.AddLog(T02NReader, '�ֳ����������', nEvent);
end;

//Date: 2013-07-08
//Parm: ͨ����;�ſ�
//Desc: ��nCard��Ӧ�ĳ��ŷ��Ϳͻ���
procedure MakeTruck2Client(const nTunnel,nCard: string);
var nStr: string;
    nList: TStrings;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nList := nil;
  nPacker := nil;
  nWorker := nil;
  try
    nList := TStringList.Create;
    nList.Values['Card'] := nCard;
    nList.Values['Line'] := nTunnel;

    nIn.FCommand := cBC_ReaderCardIn;
    nIn.FData := nList.Text;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);

    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessCommand);
    if not nWorker.WorkActive(nStr) then
    begin
      WriteNearReaderLog(nStr);
    end;
  finally
    nList.Free;
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorkder(nWorker);
  end;
end;

//Date: 2012-07-08
//Parm: ����;����
//Desc: ��nHost.nCard�µ�������������
procedure WhenReaderCardIn(nHost: TReaderHost; nCard: TReaderCard);
begin 
  if nHost.FType = rtOnce then
  begin
    MakeTruck2Client(nHost.FTunnel, nCard.FCard);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2013-07-08
//Desc: �ͻ��˷���UDP���ݰ�
procedure When2ClientUDPRead(AThread: TIdUDPListenerThread; AData: TIdBytes;
  ABinding: TIdSocketHandle);
begin

end;

end.
