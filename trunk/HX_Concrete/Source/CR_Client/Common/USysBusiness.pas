{*******************************************************************************
  ����: dmzn@163.com 2007-10-09
  ����: ϵͳҵ���߼���Ԫ
*******************************************************************************}
unit USysBusiness;

interface

uses
  Windows, Controls, Classes, SysUtils, cxCustomData, UBusinessWorker,
  UBusinessConst, UBusinessPacker, UFormBase, ULibFun, USysConst;

type
  PTruckItem = ^TTruckItem;
  TTruckItem = record
    FIndex      : Integer;
    FTruck      : string;    
    FLine       : string;    
    FLineName   : string;
    FIsVIP      : string;    
    FInTime     : TDateTime;

    FCallNum    : Integer;
    FAnswered   : string;   
  end;

  TTruckDataSource = class(TcxCustomDataSource)
  private
    FTrucks: TList;
    FListA: TStrings;
    FListB: TStrings;
  protected
    procedure ClearTrucks(const nFree: Boolean);
    function GetValue(ARecordHandle: TcxDataRecordHandle;
      AItemHandle: TcxDataItemHandle): Variant; override;
    function GetRecordCount: Integer; override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadTrucks(const nSrvURL: string);
  end;

function GetTruckCard(const nTruck: string): string;
//�������
function SetTruckCard(const nTruck: string): Boolean;
function SaveTruckCard(const nTruck,nCard: string): Boolean;
//�����󶨴ſ�
function LogoutBillCard(const nCard: string): Boolean;
//ע��ָ����

function MakeTruckIn(const nCard: string): Boolean;
//������վ
function MakeTruckOut(const nCard: string): Boolean;
//������վ
function MakeTruckResponse(const nCard: string): Boolean;
//����Ӧ��

implementation

constructor TTruckDataSource.Create;
begin
  inherited;
  FTrucks := TList.Create;
  FListA := TStringList.Create;
  FListB := TStringList.Create;
end;

destructor TTruckDataSource.Destroy;
begin
  ClearTrucks(True);
  FListA.Free;
  FListB.Free;
  inherited;
end;

procedure TTruckDataSource.ClearTrucks(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FTrucks.Count - 1 downto 0 do
  begin
    Dispose(PTruckItem(FTrucks[nIdx]));
    FTrucks.Delete(nIdx);
  end;

  if nFree then
    FreeAndNil(FTrucks);
  //xxxxx
end;

function TTruckDataSource.GetRecordCount: Integer;
begin
  Result := FTrucks.Count;
end;

function TTruckDataSource.GetValue(ARecordHandle: TcxDataRecordHandle;
  AItemHandle: TcxDataItemHandle): Variant;
var nColumn: Integer;
    nItem: PTruckItem;
begin
  nColumn := GetDefaultItemID(Integer(AItemHandle));
  nItem := FTrucks[Integer(ARecordHandle)];

  case nColumn of
    0: Result := nItem.FIndex;
    1: Result := nItem.FTruck;
    //2: Result := nItem.FLine;
    2: Result := nItem.FLineName;
    3: Result := nItem.FIsVIP;
    4: Result := nItem.FCallNum;
    5: Result := nItem.FAnswered;
    6: Result := nItem.FInTime;
  end;
end;

procedure TTruckDataSource.LoadTrucks(const nSrvURL: string);
var nIdx: Integer;
    nItem: PTruckItem;
    nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    gSysParam.FRemoteURL := nSrvURL;
    nIn.FCommand := cBC_LoadQueueTrucks;
    
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_RemoteQueue);
    if not nWorker.WorkActive(@nIn, @nOut) then Exit;
  finally
    gBusinessWorkerManager.RelaseWorkder(nWorker);
  end;

  ClearTrucks(False);
  FListA.Text := nOut.FData;

  for nIdx:=0 to FListA.Count - 1 do
  begin
    FListB.Text := PackerDecodeStr(FListA[nIdx]);
    New(nItem);
    FTrucks.Add(nItem);

    with FListB do
    begin
      nItem.FIndex := nIdx + 1;
      nItem.FTruck := Values['Truck'];
      nItem.FLine := Values['Line'];
      nItem.FLineName := Values['LineName'];   

      nItem.FCallNum := StrToInt(Values['CallNum']);
      nItem.FIsVIP := Values['IsVIP'];
      nItem.FAnswered := Values['Answered'];
      nItem.FInTime := Str2DateTime(Values['InTime']);
    end;
  end;

  DataChanged;
  //apply data
end;

//------------------------------------------------------------------------------
//Date: 2013-07-13
//Parm: ����;ָ��
//Desc: ��MIT��ִ��nCMDָ��
function DoMITBusinessCMD(const nData: string; const nCMD: Integer): Boolean;
var nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessCommand);
    Result := nWorker.WorkActive(@nIn, @nOut);
  finally
    gBusinessWorkerManager.RelaseWorkder(nWorker);
  end;
end;

//Date: 2013-07-08
//Parm: ���ƺ�;�ſ���
//Desc: ΪnTruck�󶨴ſ�nCard
function SaveTruckCard(const nTruck,nCard: string): Boolean;
var nList: TStrings;
begin
  nList := nil;
  try
    nList := TStringList.Create;
    with nList do
    begin
      Values['Card'] := nCard;
      Values['Truck'] := nTruck;
    end;

    Result := DoMITBusinessCMD(nList.Text, cBC_SaveTruckCard);
  finally
    nList.Free;
  end;
end;

//Date: 2013-7-8
//Parm: �ſ���
//Desc: ע��ָ���ſ���
function LogoutBillCard(const nCard: string): Boolean;
begin
  Result := DoMITBusinessCMD(nCard, cBC_LogoutBillCard);
end;

//Date: 2013-07-10
//Parm: ���ƺ�
//Desc: ΪnTruck�󶨴ſ�
function SetTruckCard(const nTruck: string): Boolean;
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  nP.FParamA := nTruck;
  nP.FParamB := '���������ſ�:';

  CreateBaseFormItem(cFI_FormMakeCard, '', @nP);
  Result := (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK);
end;

//Date: 2013-07-10
//Desc: ����,�������
function GetTruckCard(const nTruck: string): string;
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_EditData;
  nP.FParamA := nTruck;
  nP.FParamB := '��ˢ�ſ�:';

  CreateBaseFormItem(cFI_FormMakeCard, '', @nP);
  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
       Result := nP.FParamB
  else Result := '';
end;

//------------------------------------------------------------------------------
//Date: 2013-07-10
//Desc: ������վ
function MakeTruckIn(const nCard: string): Boolean;
begin
  Result := DoMITBusinessCMD(nCard, cBC_MakeTruckIn);
end;

//Date: 2013-07-10
//Desc: ������վ
function MakeTruckOut(const nCard: string): Boolean;
begin
  Result := DoMITBusinessCMD(nCard, cBC_MakeTruckOut);
end;

//Date: 2013-07-10
//Desc: �����ֳ�ˢ��Ӧ��
function MakeTruckResponse(const nCard: string): Boolean;
begin
  Result := DoMITBusinessCMD(nCard, cBC_MakeTruckResponse);
end;

end.


