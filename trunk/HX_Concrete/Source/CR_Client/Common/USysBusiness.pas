{*******************************************************************************
  ����: dmzn@163.com 2007-10-09
  ����: ϵͳҵ���߼���Ԫ
*******************************************************************************}
unit USysBusiness;

interface

uses
  Windows, Controls, Classes, SysUtils, UBusinessWorker, UBusinessConst,
  UBusinessPacker, UFormBase, ULibFun, USysConst;

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


