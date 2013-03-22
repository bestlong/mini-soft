{*******************************************************************************
  ����: dmzn@163.com 2008-08-07
  ����: ϵͳ���ݿⳣ������

  ��ע:
  *.�Զ�����SQL���,֧�ֱ���:$Inc,����;$Float,����;$Integer=sFlag_Integer;
    $Decimal=sFlag_Decimal;$Image,��������
*******************************************************************************}
unit USysDB;

{$I Link.inc}
interface

uses
  SysUtils, Classes;

const
  cSysDatabaseName: array[0..4] of String = (
     'Access', 'SQL', 'MySQL', 'Oracle', 'DB2');
  //db names

type
  TSysDatabaseType = (dtAccess, dtSQLServer, dtMySQL, dtOracle, dtDB2);
  //db types

  PSysTableItem = ^TSysTableItem;
  TSysTableItem = record
    FTable: string;
    FNewSQL: string;
  end;
  //ϵͳ����

var
  gSysTableList: TList = nil;                        //ϵͳ������
  gSysDBType: TSysDatabaseType = dtSQLServer;        //ϵͳ��������

//------------------------------------------------------------------------------
const
  //�����ֶ�
  sField_Access_AutoInc          = 'Counter';
  sField_SQLServer_AutoInc       = 'Integer IDENTITY (1,1) PRIMARY KEY';

  //С���ֶ�
  sField_Access_Decimal          = 'Float';
  sField_SQLServer_Decimal       = 'Decimal(15, 5)';

  //ͼƬ�ֶ�
  sField_Access_Image            = 'OLEObject';
  sField_SQLServer_Image         = 'Image';

  //�������
  sField_SQLServer_Now           = 'getDate()';

ResourceString     
  {*Ȩ����*}
  sPopedom_Read       = 'A';                         //���
  sPopedom_Add        = 'B';                         //���
  sPopedom_Edit       = 'C';                         //�޸�
  sPopedom_Delete     = 'D';                         //ɾ��
  sPopedom_Preview    = 'E';                         //Ԥ��
  sPopedom_Print      = 'F';                         //��ӡ
  sPopedom_Export     = 'G';                         //����

  {*��ر��*}
  sFlag_Yes           = 'Y';                         //��
  sFlag_No            = 'N';                         //��
  sFlag_Enabled       = 'Y';                         //����
  sFlag_Disabled      = 'N';                         //����

  sFlag_Integer       = 'I';                         //����
  sFlag_Decimal       = 'D';                         //С��

  sFlag_CarType       = 'CarType';                   //��������
  sFlag_CarMode       = 'CarMode';                   //�����ͺ�
  sFlag_TrainID       = 'TrainID';                   //�𳵱�ʶ

  sFlag_QInterval     = 'QueryInterval';             //��ѯ���
  sFlag_PrintSend     = 'PrintSendData';
  sFlag_PrintRecv     = 'PrintRecvData';             //��ӡ����
  sFlag_UIInterval    = 'UIItemInterval';            //������
  sFlag_UIMaxValue    = 'UIItemMaxValue';            //������
  sFlag_ChartCount    = 'ChartMaxCount';             //������
  sFlag_ReportPage    = 'ReportPageSize';            //����ҳ(Сʱ)

  {*���ݱ�*}
  sTable_Entity       = 'Sys_Entity';                //�ֵ�ʵ��
  sTable_DictItem     = 'Sys_DataDict';              //�ֵ���ϸ
  sTable_SysDict      = 'Sys_Dict';                  //ϵͳ�ֵ�
  sTable_ExtInfo      = 'Sys_ExtInfo';               //������Ϣ
  sTable_SysLog       = 'Sys_EventLog';              //ϵͳ��־
  sTable_BaseInfo     = 'Sys_BaseInfo';              //������Ϣ

  sTable_Carriage     = 'T_Carriage';                //����
  sTable_Device       = 'T_Device';                  //�豸
  sTable_Port         = 'T_COMPort';                 //����

  sTable_BreakPipe    = 'T_BreakPipe';
  sTable_BreakPot     = 'T_BreakPot';
  sTable_TotalPipe    = 'T_TotalPipe';               //���ݼ�¼

  {*�½���*}
  sSQL_NewSysDict = 'Create Table $Table(D_ID $Inc, D_Name varChar(15),' +
       'D_Desc varChar(30), D_Value varChar(50), D_Memo varChar(20),' +
       'D_ParamA $Float, D_ParamB varChar(50), D_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   ϵͳ�ֵ�: SysDict
   *.D_ID: ���
   *.D_Name: ����
   *.D_Desc: ����
   *.D_Value: ȡֵ
   *.D_Memo: �����Ϣ
   *.D_ParamA: �������
   *.D_ParamB: �ַ�����
   *.D_Index: ��ʾ����
  -----------------------------------------------------------------------------}
  
  sSQL_NewExtInfo = 'Create Table $Table(I_ID $Inc, I_Group varChar(20),' +
       'I_ItemID varChar(20), I_Item varChar(30), I_Info varChar(50),' +
       'I_ParamA $Float, I_ParamB varChar(50), I_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   ��չ��Ϣ��: ExtInfo
   *.I_ID: ���
   *.I_Group: ��Ϣ����
   *.I_ItemID: ��Ϣ��ʶ
   *.I_Item: ��Ϣ��
   *.I_Info: ��Ϣ����
   *.I_ParamA: �������
   *.I_ParamB: �ַ�����
   *.I_Memo: ��ע��Ϣ
   *.I_Index: ��ʾ����
  -----------------------------------------------------------------------------}
  
  sSQL_NewSysLog = 'Create Table $Table(L_ID $Inc, L_Date DateTime,' +
       'L_Man varChar(32),L_Group varChar(20), L_ItemID varChar(20),' +
       'L_KeyID varChar(20), L_Event varChar(220))';
  {-----------------------------------------------------------------------------
   ϵͳ��־: SysLog
   *.L_ID: ���
   *.L_Date: ��������
   *.L_Man: ������
   *.L_Group: ��Ϣ����
   *.L_ItemID: ��Ϣ��ʶ
   *.L_KeyID: ������ʶ
   *.L_Event: �¼�
  -----------------------------------------------------------------------------}

  sSQL_NewBaseInfo = 'Create Table $Table(B_ID $Inc, B_Group varChar(15),' +
       'B_Text varChar(50), B_Py varChar(25), B_Memo varChar(25),' +
       'B_PID Integer, B_Index Float)';
  {-----------------------------------------------------------------------------
   ������Ϣ��: BaseInfo
   *.B_ID: ���
   *.B_Group: ����
   *.B_Text: ����
   *.B_Py: ƴ����д
   *.B_Memo: ��ע��Ϣ
   *.B_PID: �ϼ��ڵ�
   *.B_Index: ����˳��
  -----------------------------------------------------------------------------}

  sSQL_NewCarriage = 'Create Table $Table(R_ID $Inc, C_ID varChar(15),' +
       'C_Name varChar(50), C_TypeID Integer, C_TypeName varChar(32), ' +
       'C_ModeID Integer, C_ModeName varChar(32), C_Position Integer)';
  {-----------------------------------------------------------------------------
   ����: Carriage
   *.R_ID: ��¼��
   *.C_ID: ��ʶ
   *.C_Name: ����
   *.C_TypeID,C_TypeName: ����
   *.C_ModeID,C_ModeName: �ͺ�
   *.C_Postion: ǰ��λ��
  -----------------------------------------------------------------------------}

  sSQL_NewDevice = 'Create Table $Table(R_ID $Inc, D_ID varChar(15),' +
       'D_Port varChar(16), D_Serial varChar(50), D_Index Integer,' +
       'D_Carriage varChar(15))';
  {-----------------------------------------------------------------------------
   �豸: Device
   *.R_ID: ��¼��
   *.D_ID: ��ʶ
   *.D_Port: �˿�
   *.D_Serial: װ�ú�
   *.D_Index: ��ַ����
   *.D_Carriage: ����
  -----------------------------------------------------------------------------}

  sSQL_NewCOMPort = 'Create Table $Table(R_ID $Inc, C_ID varChar(15),' +
       'C_Name varChar(50), C_Port varChar(16), C_Baund varChar(16),' +
       'C_DataBits varChar(16), C_StopBits varChar(16), C_Position Integer)';
  {-----------------------------------------------------------------------------
   ����: port
   *.R_ID: ��¼��
   *.C_ID: ���
   *.C_Name: ����
   *.C_Port: �˿�
   *.C_Baund: ������
   *.C_DataBits: ����λ
   *.C_StopBits: ��ͣλ
   *.C_Position: ǰ��λ��
  -----------------------------------------------------------------------------}

  sSQL_NewBreakPipe = 'Create Table $Table(R_ID $Inc, P_Train varChar(15),' +
       'P_Carriage varChar(15), P_Value $Float, P_Number Integer, P_Date DateTime)';
  {-----------------------------------------------------------------------------
   �ƶ���: BreakPipe
   *.R_ID: ��¼��
   *.P_Train: ������ʶ
   *.P_Carriage: ����
   *.P_Value: ����
   *.P_Number: ����
   *.P_Date: �ɼ�����
  -----------------------------------------------------------------------------}

  sSQL_NewBreakPot = 'Create Table $Table(R_ID $Inc, P_Train varChar(15),' +
       'P_Carriage varChar(15), P_Value $Float, P_Number Integer, P_Date DateTime)';
  {-----------------------------------------------------------------------------
   �ƶ���: BreakPot
   *.R_ID: ��¼��
   *.P_Train: ������ʶ
   *.P_Carriage: ����
   *.P_Value: ����
   *.P_Number: ����
   *.P_Date: �ɼ�����
  -----------------------------------------------------------------------------}

  sSQL_NewTotalPipe = 'Create Table $Table(R_ID $Inc, P_Train varChar(15),' +
       'P_Carriage varChar(15), P_Value $Float, P_Date DateTime)';
  {-----------------------------------------------------------------------------
   �ƶ���: TotalPipe
   *.R_ID: ��¼��
   *.P_Train: ������ʶ
   *.P_Carriage: ����
   *.P_Value: ����
   *.P_Date: �ɼ�����
  -----------------------------------------------------------------------------}

//------------------------------------------------------------------------------
// ���ݲ�ѯ
//------------------------------------------------------------------------------
  sQuery_SysDict = 'Select D_ID, D_Value, D_Memo From $Table ' +
                   'Where D_Name=''$Name'' Order By D_Index Desc';
  {-----------------------------------------------------------------------------
   �������ֵ��ȡ����
   *.$Table: �����ֵ��
   *.$Name: �ֵ�������
  -----------------------------------------------------------------------------}

  sQuery_ExtInfo = 'Select I_ID, I_Item, I_Info From $Table Where ' +
                   'I_Group=''$Group'' and I_ItemID=''$ID'' Order By I_Index Desc';    
  {-----------------------------------------------------------------------------
   ����չ��Ϣ���ȡ����
   *.$Table: ��չ��Ϣ��
   *.$Group: ��������
   *.$ID: ��Ϣ��ʶ
  -----------------------------------------------------------------------------}
  
implementation

//------------------------------------------------------------------------------
//Desc: ���ϵͳ����
procedure AddSysTableItem(const nTable,nNewSQL: string);
var nP: PSysTableItem;
begin
  New(nP);
  gSysTableList.Add(nP);

  nP.FTable := nTable;
  nP.FNewSQL := nNewSQL;
end;

//Desc: ϵͳ��
procedure InitSysTableList;
begin
  gSysTableList := TList.Create;

  AddSysTableItem(sTable_SysDict, sSQL_NewSysDict);

  AddSysTableItem(sTable_ExtInfo, sSQL_NewExtInfo);

  AddSysTableItem(sTable_SysLog, sSQL_NewSysLog);

  AddSysTableItem(sTable_BaseInfo, sSQL_NewBaseInfo);

  AddSysTableItem(sTable_Carriage, sSQL_NewCarriage);

  AddSysTableItem(sTable_Device, sSQL_NewDevice);

  AddSysTableItem(sTable_Port, sSQL_NewCOMPort);

  AddSysTableItem(sTable_BreakPipe, sSQL_NewBreakPipe);
  AddSysTableItem(sTable_BreakPot, sSQL_NewBreakPot);
  AddSysTableItem(sTable_TotalPipe, sSQL_NewTotalPipe);
end;

//Desc: ����ϵͳ��
procedure ClearSysTableList;
var nIdx: integer;
begin
  for nIdx:= gSysTableList.Count - 1 downto 0 do
  begin
    Dispose(PSysTableItem(gSysTableList[nIdx]));
    gSysTableList.Delete(nIdx);
  end;

  FreeAndNil(gSysTableList);
end;

initialization
  InitSysTableList;
finalization
  ClearSysTableList;
end.


