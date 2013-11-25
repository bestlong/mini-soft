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

  sFlag_StockDai      = 'D';                         //��װ
  sFlag_StockSan      = 'S';                         //ɢװ

  sFlag_SysParam      = 'SysParam';                  //ϵͳ����
  sFlag_ValidDate     = 'SysValidDate';              //��Ч��
  sFlag_KeyName       = 'SysKeyName';                //ʶ����
  sFlag_Tunnel        = 'JSTunnelNum';               //װ������

  sFlag_TruckItem     = 'TruckInfo';                 //������Ϣ
  sFlag_TruckType     = 'TruckType';                 //��������
  sFlag_CustomerItem  = 'CustomerItem';              //�ͻ���Ϣ

  {*���ݱ�*}
  sTable_Group        = 'Sys_Group';                 //�û���
  sTable_User         = 'Sys_User';                  //�û���
  sTable_Menu         = 'Sys_Menu';                  //�˵���
  sTable_Popedom      = 'Sys_Popedom';               //Ȩ�ޱ�
  sTable_PopItem      = 'Sys_PopItem';               //Ȩ����
  sTable_Entity       = 'Sys_Entity';                //�ֵ�ʵ��
  sTable_DictItem     = 'Sys_DataDict';              //�ֵ���ϸ

  sTable_SysDict      = 'Sys_Dict';                  //ϵͳ�ֵ�
  sTable_ExtInfo      = 'Sys_ExtInfo';               //������Ϣ
  sTable_SysLog       = 'Sys_EventLog';              //ϵͳ��־
  sTable_BaseInfo     = 'Sys_BaseInfo';              //������Ϣ

  sTable_StockType    = 'Sys_StockType';             //ˮ��Ʒ��
  sTable_TruckInfo    = 'Sys_TruckInfo';             //��������
  sTable_Customer     = 'Sys_Customer';              //�ͻ�����
  sTable_JSLog        = 'Sys_JSLog';                 //������־

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

  sSQL_NewStockType = 'Create Table $Table(S_ID varChar(15), S_Type Char(1),' +
       'S_Name varChar(50), S_Level varChar(50), S_Weight $Float,' +
       'S_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   Ʒ�ֹ���: StockType
   *.S_ID: ���
   *.S_Type: ����(��,ɢ)
   *.S_Name: Ʒ������
   *.S_Level: ǿ�ȵȼ�
   *.S_Weight: ����
  -----------------------------------------------------------------------------}

  sSQL_NewTruckInfo = 'Create Table $Table(T_ID $Inc, T_TruckNo varChar(15),' +
       'T_Type varChar(32), T_Owner varChar(50), T_Phone varChar(32),' +
       'T_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   ������Ϣ: TruckInfo
   *.T_ID: ���
   *.T_TruckNo: ���ƺ�
   *.T_Type: ��������
   *.T_Owner: ����
   *.T_Phone: ��ϵ��ʽ
   *.T_Memo: ��ע��Ϣ
  -----------------------------------------------------------------------------}

  sSQL_NewCustomer = 'Create Table $Table(C_ID varChar(15), C_Name varChar(100),' +
       'C_PY varChar(100), C_Addr varChar(100), C_Phone varChar(32),' +
       'C_Memo varChar(50), C_Date DateTime)';
  {-----------------------------------------------------------------------------
   �ͻ���Ϣ: Customer
   *.C_ID: ���
   *.C_Name: ����
   *.C_PY: ƴ����д
   *.C_Addr: ��ַ
   *.C_Phone: ��ϵ��ʽ
   *.C_Memo: ��ע��Ϣ
   *.C_Date: ����ʱ��
  -----------------------------------------------------------------------------}

  sSQL_NewJSLog = 'Create Table $Table(L_ID $Inc, L_CusID varChar(15), ' +
       'L_Customer varChar(100), L_StockID varChar(15), L_Stock varChar(100),' +
       'L_TruckNo varChar(15),  L_SerialID varChar(32),' +
       'L_Weight $Float, L_DaiShu Integer, L_BC Integer, L_PValue $Float,' +
       'L_ZTLine varChar(32), L_Date DateTime, L_Man varChar(32),' +
       'L_HasDone Char(1), L_OKTime DateTime, L_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   ������־: JSLog
   *.L_ID: ���
   *.L_CusID: �ͻ����
   *.L_Customer: �ͻ�
   *.L_TruckNo: ���ƺ�
   *.L_StockID: Ʒ�ֱ��
   *.L_Stock: ˮ��Ʒ��
   *.L_SerialID: ���κ�
   *.L_Weight: �������
   *.L_DaiShu: �������
   *.L_BC: �������
   *.L_PValue: �ƴ���
   *.L_ZTLine: ջ̨λ��
   *.L_Date: ��������
   *.L_Man: ������
   *.L_HasDone: �Ƿ�װ��
   *.L_OKTime: ���ʱ��
   *.L_Memo: ��ע
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

  AddSysTableItem(sTable_StockType, sSQL_NewStockType);

  AddSysTableItem(sTable_TruckInfo, sSQL_NewTruckInfo);

  AddSysTableItem(sTable_Customer, sSQL_NewCustomer);

  AddSysTableItem(sTable_JSLog, sSQL_NewJSLog);
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


