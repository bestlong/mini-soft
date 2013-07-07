{*******************************************************************************
  ����: dmzn@163.com 2012-02-03
  ����: ҵ��������

  ��ע:
  *.����In/Out����,��ô���TBWDataBase������,��λ�ڵ�һ��Ԫ��.
*******************************************************************************}
unit UBusinessConst;

interface

const
  {*channel type*}
  cBus_Channel_Connection     = $0002;
  cBus_Channel_Business       = $0005;

  {*worker action code*}
  cWorker_GetPackerName       = $0010;
  cWorker_GetMITName          = $0012;

  {*business command*}
  cBC_RemoteExecSQL           = $0055;

type
  TBWWorkerInfo = record
    FUser   : string;              //������
    FIP     : string;              //IP��ַ
    FMAC    : string;              //������ʶ
    FTime   : TDateTime;           //����ʱ��
    FKpLong : Int64;               //����ʱ��
  end;

  PBWDataBase = ^TBWDataBase;
  TBWDataBase = record
    FWorker   : string;            //��װ��
    FFrom     : TBWWorkerInfo;     //Դ
    FVia      : TBWWorkerInfo;     //����
    FFinal    : TBWWorkerInfo;     //����

    FMsgNO    : string;            //��Ϣ��
    FKey      : string;            //��¼���
    FParam    : string;            //��չ����

    FResult   : Boolean;           //ִ�н��
    FErrCode  : string;            //�������
    FErrDesc  : string;            //��������
  end;

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

  {*sap mit function name*}
  sSAP_ServiceStatus          = 'SAP_ServiceStatus';    //����״̬
  sSAP_ReadXSSaleOrder        = 'SAP_Read_XSSaleOrder'; //���۶���
  sSAP_ReadZCSaleOrder        = 'SAP_Read_ZCSaleOrder'; //ת������
  sSAP_CreateSaleBill         = 'SAP_Create_SaleBill';  //����������
  sSAP_ModifySaleBill         = 'SAP_Modify_SaleBill';  //�޸Ľ�����
  sSAP_DeleteSaleBill         = 'SAP_Delete_SaleBill';  //ɾ��������
  sSAP_PickSaleBill           = 'SAP_Pick_SaleBill';    //���佻����
  sSAP_PostSaleBill           = 'SAP_Post_SaleBill';    //���˽�����
  sSAP_ReadSaleBill           = 'SAP_Read_SaleBill';    //��ȡ������

  sSAP_PoundReadMatnr         = 'SAP_Pound_ReadMatnr';  //��ȡ����
  sSAP_PoundReadNew           = 'SAP_Pound_ReadNew';    //���ض�ȡ
  sSAP_PoundWeighNew          = 'SAP_Pound_WeighNew';   //���ؽӿ�

  {*business mit function name*}
  sBus_ServiceStatus          = 'Bus_ServiceStatus';    //����״̬
  sBus_ReadXSSaleOrder        = 'Bus_Read_XSSaleOrder'; //���۶���
  sBus_ReadZCSaleOrder        = 'Bus_Read_ZCSaleOrder'; //ת������
  sBus_CreateSaleBill         = 'Bus_Create_SaleBill';  //����������
  sBus_ModifySaleBill         = 'Bus_Modify_SaleBill';  //�޸Ľ�����
  sBus_DeleteSaleBill         = 'Bus_Delete_SaleBill';  //ɾ��������
  sBus_PickSaleBill           = 'Bus_Pick_SaleBill';    //���佻����
  sBus_PostSaleBill           = 'Bus_Post_SaleBill';    //���˽�����
  sBus_ReadSaleBill           = 'Bus_Read_SaleBill';    //��ȡ������
  sBus_ReadCRMOrder           = 'Bus_Read_CRMOrder';    //CRM�����   20130515

  sBus_PoundReadMatnr         = 'Bus_Pound_ReadMatnr';  //��ȡ����
  sBus_PoundReadNew           = 'Bus_Pound_ReadNew';    //���ض�ȡ
  sBus_PoundWeighNew          = 'Bus_Pound_WeighNew';   //���ؽӿ�
  sBus_PoundCommand           = 'Bus_Pound_Command';    //���ز���

  sBus_GetQueryField          = 'Bus_GetQueryField';    //��ѯ���ֶ�
  sBus_BusinessCommand        = 'Bus_BusinessCommand';  //ҵ��ָ��
  sHM_BusinessCommand         = 'HH_BusinessCommand';   //Ӳ���ػ�

  {*client function name*}
  sCLI_ServiceStatus          = 'CLI_ServiceStatus';    //����״̬
  sCLI_ReadXSSaleOrder        = 'CLI_Read_XSSaleOrder'; //���۶���
  sCLI_ReadZCSaleOrder        = 'CLI_Read_ZCSaleOrder'; //ת������
  sCLI_ReadCRMOrder           = 'sCLI_Read_CRMOrder';   //CRM�����   20130515
  sCLI_CreateSaleBill         = 'CLI_Create_SaleBill';  //����������
  sCLI_ModifySaleBill         = 'CLI_Modify_SaleBill';  //�޸Ľ�����
  sCLI_DeleteSaleBill         = 'CLI_Delete_SaleBill';  //ɾ��������
  sCLI_PickSaleBill           = 'CLI_Pick_SaleBill';    //���佻����
  sCLI_PostSaleBill           = 'CLI_Post_SaleBill';    //���˽�����
  sCLI_ReadSaleBill           = 'CLI_Read_SaleBill';    //��ȡ������

  sCLI_PoundReadMatnr         = 'CLI_Pound_ReadMatnr';  //��ȡ����
  sCLI_PoundReadNew           = 'CLI_Pound_ReadNew';    //���ض�ȡ
  sCLI_PoundWeighNew          = 'CLI_Pound_WeighNew';   //���ؽӿ�

  sCLI_GetQueryField          = 'CLI_GetQueryField';    //��ѯ���ֶ�
  sCLI_BusinessCommand        = 'CLI_BusinessCommand';  //ҵ��ָ��
  sCLI_PoundCommand           = 'CLI_Pound_Command';    //���ز���
  sCLI_HardwareMonitor        = 'CLI_Hardware_Monitor'; //Ӳ���ػ�
  sCLI_TruckQueue             = 'CLI_TruckQueue';       //�����Ŷ�

implementation

end.


