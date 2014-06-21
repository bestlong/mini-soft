{*******************************************************************************
  ����: dmzn@163.com 2012-02-03
  ����: ҵ��������

  ��ע:
  *.����In/Out����,��ô���TBWDataBase������,��λ�ڵ�һ��Ԫ��.
*******************************************************************************}
unit UBusinessConst;

interface

uses
  UBusinessPacker;
  
const
  {*channel type*}
  cBus_Channel_Connection     = $0002;
  cBus_Channel_Business       = $0005;

  {*worker action code*}
  cWorker_GetPackerName       = $0010;
  cWorker_GetMITName          = $0012;

  {*business command*}
  cBC_RemoteExecSQL           = $0050;
  cBC_ReaderCardIn            = $0052;
  cBC_MakeTruckIn             = $0053;
  cBC_MakeTruckOut            = $0055;
  cBC_MakeTruckCall           = $0056;
  cBC_MakeTruckResponse       = $0057;
  cBC_SaveTruckCard           = $0060;
  cBC_LogoutBillCard          = $0061;
  cBC_LoadQueueTrucks         = $0062;

type
  PWorkerBusinessCommand = ^TWorkerBusinessCommand;
  TWorkerBusinessCommand = record
    FBase     : TBWDataBase;
    FCommand  : Integer;           //����
    FData     : string;            //����
  end;

resourcestring
  {*common function*}
  sSys_SweetHeart             = 'Sys_SweetHeart';       //����ָ��
  sSys_BasePacker             = 'Sys_BasePacker';       //���������

  {*business mit function name*}
  sBus_BusinessCommand        = 'Bus_BusinessCommand';  //ҵ��ָ��

  {*client function name*}
  sCLI_BusinessCommand        = 'CLI_BusinessCommand';  //ҵ��ָ��
  sCLI_RemoteQueue            = 'CLI_RemoteQueue';      //ҵ��ָ��

implementation

end.


