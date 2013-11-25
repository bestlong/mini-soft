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
  cWorker_GetSAPName          = $0011;
  cWorker_GetRFCName          = $0012;
  cWorker_GetMITName          = $0015;

  {*query field define*}
  cQF_Bill                    = $0001;
  cQF_BillPick                = $0002;
  cQF_BillPost                = $0003;
  cQF_BillCard                = $0004;
  cQF_QueryGuard              = $0005;
  cQF_QueryLadingSan          = $0006;
  cQF_QueryLadingDai          = $0007;
  cQF_QueryPound              = $0008;
  cQF_QuerySaleDtl            = $0009;
  cQF_QuerySaleTotal          = $0010;
  cQF_QueryTruck              = $0011;

  {*business command*}
  cBC_ReadBillInfo            = $0001;
  cBC_ReadOrderInfo           = $0002;
  cBC_ReadTruckInfo           = $0003;

  cBC_LoadMaterails           = $0021;
  cBC_SavePoundData           = $0022;
  cBC_GetPostBills            = $0023;
  cBC_SavePostBills           = $0025;
  cBC_SaveBillCard            = $0026;
  cBC_LogoutBillCard          = $0028;
  cBC_DeletePoundLog          = $0029;

  cBC_GetPoundCard            = $0050;
  cBC_GetQueueData            = $0051;
  cBC_SaveCountData           = $0052;
  cBC_RemoteExecSQL           = $0055;
  cBC_PrintCode               = $0056;
  cBC_PrinterEnable           = $0057;
  cBC_PrintFixCode            = $0058;

  cBC_JSStart                 = $0060;
  cBC_JSStop                  = $0061;
  cBC_JSPause                 = $0062;
  cBC_JSGetStatus             = $0063;

type
  PReadXSSaleOrderIn = ^TReadXSSaleOrderIn;
  TReadXSSaleOrderIn = record
    FBase  : TBWDataBase;          //��������
    FVBELN : string;               //���۶�����
    FVSTEL : string;               //װ�˵�,���յ�
  end;

  PReadXSSaleOrderOut = ^TReadXSSaleOrderOut;
  TReadXSSaleOrderOut = record
    FBase     : TBWDataBase;
    FVBELN    : string;            //���۶�����
    FAUART    : string;            //����ƾ֤����
    FBEZEI    : string;            //��������
    FVKORG    : string;            //������֯
    FVTEXT    : string;            //������֯����
    FKUNNR_AG : string;            //�۴﷽
    FNAME1_AG : string;            //�۴﷽����
    FKUNNR_WE : string;            //�ʹ﷽
    FNAME1_WE : string;            //�ʹ﷽����
    FVBELN_CT : string;            //�����ͬ��
    FLIFNR_CT : string;            //���乩Ӧ��
    FNAME1_CT : string;            //��Ӧ������
    FOTHER_MG : string;            //������Ϣ

    FPOSNR    : string;            //������Ŀ��
    FWERKS    : string;            //����
    FNAME1    : string;            //��������
    FVSTEL    : string;            //װ�˵�
    FVTEXT_1  : string;            //װ�˵�����
    FLGORT    : string;            //���ص�
    FLGOBE    : string;            //���ص�����
    FMATNR    : string;            //���Ϻ�
    FARKTX    : string;            //��������
    FMVGR1    : string;            //������1
    FBEZEI_1  : string;            //��������
    FKWMENG   : Double;            //�ۼƶ�������
    FRFMNG    : Double;            //��������
    FWTSL     : Double;            //δ������
    FKYSL     : Double;            //��������
    FVSART    : string;            //ת�����ͱ��
    FBEZEI_VT : string;            //װ�����͵�����
  end;

  PReadCRMOrderIn = ^TReadCRMOrderIn;                   // {* 20130515
  TReadCRMOrderIn = record
    FBase  : TBWDataBase;          //��������
    FCRM   : string;               //CRM�������
  end;

  PReadCRMOrderOut =^TReadCRMOrderOut;
  TReadCRMOrderOut = record
    FBase  : TBWDataBase;
    FVBELN : string;               //������
    FTRUCK : string;               //����
    FValue : Double;               //����
  end;                                                 // crm����ί�е� *}

  PReadZCSaleOrderIn = ^TReadZCSaleOrderIn;
  TReadZCSaleOrderIn = record
    FBase  : TBWDataBase;          //��������
    FVBELN : string;               //���۶�����
    FVSTEL : string;               //װ�˵�,���յ�
  end;

  PReadZCSaleOrderOut = ^TReadZCSaleOrderOut;
  TReadZCSaleOrderOut = record
    FBase     : TBWDataBase;
    FVBELN    : string;            //ת��������
    FBSART    : string;            //ƾ֤����
    FBATXT    : string;            //ƾ֤���͵ļ������
    FLIFNR    : string;            //��Ӧ��
    FNAME1    : string;            //��Ӧ������
    FKUNNR_WE : string;            //�ʹ﷽
    FNAME1_WE : string;            //�ʹ﷽����
    FVBELN_CT : string;            //�����ͬ��
    FLIFNR_CT : string;            //���乩Ӧ��
    FNAME1_CT : string;            //��Ӧ������
    FOTHER_MG : string;            //������Ϣ

    FPOSNR    : string;            //ת��������Ŀ��
    FWERKS    : string;            //����
    FNAME1_1  : string;            //��������
    FVSTEL    : string;            //װ�˵�/���յ�
    FVTEXT    : string;            //װ�˵�����
    FLGORT    : string;            //���ص�
    FLGOBE    : string;            //���ص�����
    FWERKS_J  : string;            //��������
    FNAME1_J  : string;            //������������
    FMATNR    : string;            //���Ϻ�
    FTXZ01    : string;            //��������
    FMENGE    : Double;            //��������
    FYTSL     : Double;            //��������
    FWTSL     : Double;            //δ������
    FVSART    : string;            //װ������
    FBEZEI_VT : string;            //װ����������
  end;

  PWorkerCreateBillIn = ^TWorkerCreateBillIn;
  TWorkerCreateBillIn = record
    FBase     : TBWDataBase;       //��������
    FType     : string;            //����(����,ת��)
    FOrder    : string;            //��ȡ��������
    
    FVBELN    : string;            //���۶�����
    FVSTEL    : string;            //װ�˵�,���յ�
    FLFIMG    : string;            //������
    FKDMAT    : string;            //������
    FSDABW    : string;            //�ͻ�����
    FLGORT    : string;            //���ص�
    FSeal     : string;            //��ǩ��
    FIsVIP    : string;            //VIP��
    FCRM      : string;            //CRM����                            20130517
  end;

  PWorkerCreateBillOut = ^TWorkerCreateBillOut;
  TWorkerCreateBillOut = record
    FBase     : TBWDataBase;
    FVBELN    : string;            //��������
    FBOLNR    : string;            //�������
    FLFART    : string;            //����������       *tanxin 2013-03-21
  end;

  PWorkerModifyBillIn = ^TWorkerModifyBillIn;
  TWorkerModifyBillIn = record
    FBase     : TBWDataBase;
    FVBELN    : string;            //��������
    FLFIMG    : string;            //������
    FKDMAT    : string;            //������
    FBOLNR    : string;            //�������
    FSeal     : string;            //��ǩ��
  end;

  PWorkerDeleteBillIn = ^TWorkerDeleteBillIn;
  TWorkerDeleteBillIn = record
    FBase     : TBWDataBase;
    FVBELN    : string;            //��������
  end;

  PWorkerPickBillIn = ^TWorkerPickBillIn;
  TWorkerPickBillIn = record
    FBase     : TBWDataBase;
    FVBELN    : string;            //��������
    FLFIMG    : string;            //��������
    FType     : string;            //����(D,S)
    FPValue   : string;
    FMValue   : string;            //Ƥ,ë��
  end;

  PWorkerPickBillOut = ^TWorkerPickBillOut;
  TWorkerPickBillOut = record
    FBase     : TBWDataBase;
    FVBELN    : string;            //��������
    FKODAT    : string;            //��������
    FKOUHR    : string;            //���ʱ��
    FLFIMG    : string;            //��������        *tanxin 2013-03-25
  end;

  PWorkerPostBillIn = ^TWorkerPostBillIn;
  TWorkerPostBillIn = record
    FBase     : TBWDataBase;
    FData     : string;            //��������
  end;

  PWorkerPostBillOut = ^TWorkerPostBillOut;
  TWorkerPostBillOut = record
    FBase     : TBWDataBase;
    FData     : string;            //���˽��
  end;

  PWorkerReadMatnrOut = ^TWorkerReadMatnrOut;
  TWorkerReadMatnrOut = record
    FBase     : TBWDataBase;
    FMatnr    : string;            //�����б�
  end;

  PWorkerPoundReadNewIn = ^TWorkerPoundReadNewIn;
  TWorkerPoundReadNewIn = record
    FBase     : TBWDataBase;
    FVBELN    : string;            //ƾ֤����
  end;

  PWorkerPoundReadNewOut = ^TWorkerPoundReadNewOut;
  TWorkerPoundReadNewOut = record
    FBase     : TBWDataBase;
    FMSG      : string;            //�����ʶ
    FMSG_TEXT : string;            //�������
    FZRETURN  : string;            //�������
  end;

  PWorkerPoundWeighNewIn = ^TWorkerPoundWeighNewIn;
  TWorkerPoundWeighNewIn = record
    FBase     : TBWDataBase;
    FIMODE    : string;            //U,д;R��;D,ɾ
    FWEIGITEM : string;            //���ؼ�¼��
    FWEIID    : string;            //���ر����
  end;

  PWorkerPoundWeighNewOut = ^TWorkerPoundWeighNewOut;
  TWorkerPoundWeighNewOut = record
    FBase     : TBWDataBase;
    FOFLAG    : string;            //�����ʶ
    FWEIGITEM : string;            //���ؼ�¼��
    FLOG      : string;            //��������
  end;

  PWorkerQueryFieldData = ^TWorkerQueryFieldData;
  TWorkerQueryFieldData = record
    FBase     : TBWDataBase;
    FType     : Integer;           //����
    FData     : string;            //����
  end;

  PWorkerBusinessCommand = ^TWorkerBusinessCommand;
  TWorkerBusinessCommand = record
    FBase     : TBWDataBase;
    FCommand  : Integer;           //����
    FData     : string;            //����
    FSAPOK    : Boolean;           //SAP����
  end;

  PWorkerBusinessPound = ^TWorkerBusinessPound;
  TWorkerBusinessPound = record
    FBase     : TBWDataBase;
    FCommand  : Integer;           //ָ��
    FNewPound : Boolean;           //�³���
    FType     : string;            //��������
    FPound    : string;            //���ر��
    
    FCard     : string;            //�ſ���
    FBillID   : string;            //��������
    FOrder    : string;            //������
    FTruck    : string;            //���ƺ�
    FTruckID  : string;            //������¼
    FCusID    : string;            //�ͻ����
    FCusName  : string;            //�ͻ�����
    FMType    : string;            //��������
    FMID      : string;            //���ϱ��
    FMName    : string;            //��������
    FFactNum  : string;            //��������
    FLimValue : Double;            //Ʊ��
    FPValue   : Double;
    FPDate    : string;
    FPMan     : string;            //Ƥ��
    FMValue   : Double;
    FMDate    : string;
    FMMan     : string;            //ë��
    FStation  : string;            //��վ���
    FDirect   : string;            //����(��,��)
    FPModel   : string;            //����ģʽ
    FStatus   : string;            //״̬(Ƥ,ë)
    FSAPOK    : Boolean;           //SAP����
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


