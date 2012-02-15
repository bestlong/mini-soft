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

  sFlag_CaiZhi        = 'C';                         //����
  sFlag_DanWei        = 'D';                         //��λ
  sFlag_GuiGe         = 'G';                         //���

  sFlag_BeiPin        = 'B';                         //��Ʒ����
  sFalg_CaiLiao       = 'C';                         //��������

  sFlag_NInNOut       = 'I';                         //�Ƚ��ȳ�
  sFlag_NInBOut       = 'O';                         //�Ƚ����

  sFlag_CommonItem    = 'CommonItem';                //������Ϣ
  sFlag_DepartItem    = 'DepartItem';                //������Ϣ��
  sFlag_StorageItem   = 'StorageItem';               //��λ��Ϣ��
  sFlag_ProviderItem  = 'ProviderItem';              //��Ӧ����Ϣ
  sFlag_GoodsTpItem   = 'GoodsTypeItem';             //������Ϣ��

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

  sTable_Unit         = 'K_Unit';                    //������
  sTable_Department   = 'K_Department';              //���ŵ�λ
  sTable_Storage      = 'K_Storage';                 //�ֿ��λ
  sTable_Provider     = 'K_Provider';                //��Ӧ��
  sTable_ProvideDtl   = 'K_ProvideDtl';              //��Ӧ��ϸ

  sTable_GoodsType    = 'K_GoodsType';               //��Ʒ����
  sTable_Goods        = 'K_Goods';                   //��Ʒ��Ϣ
  sTable_Weeks        = 'K_Weeks';                   //�ɹ�����
  sTable_BuyReq       = 'K_BuyReq';                  //�ɹ�����
  sTable_BuyPlan      = 'K_BuyPlan';                 //�ɹ��ƻ�

  sTable_YuanLiao     = 'K_YuanLiao';                //ԭ�����
  sTable_BeiPin       = 'K_BeiPin';                  //��Ʒ���
  sTable_ChuKu        = 'K_ChuKu';                   //��Ʒ����
  sTable_ChuKuDtl     = 'K_ChuKuDtl';                //������ϸ
  sTable_KuCun        = 'K_KuCun';                   //����̵�
  sTable_KuCunTmp     = 'K_KuCunTemp';               //��ʱ���

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
       'I_ItemID varChar(20), I_Item varChar(30), I_Info varChar(500),' +
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
       'B_Text varChar(100), B_Py varChar(25), B_Memo varChar(50),' +
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

  sSQL_NewUnit = 'Create Table $Table(R_ID $Inc, U_Name varChar(32),' +
       'U_PY varChar(32), U_Type Char(1))';
  {-----------------------------------------------------------------------------
   ������: Unit
   *.R_ID: ���
   *.U_Name: ����
   *.U_PY: ƴ��
   *.U_Type: ����(D,���,C����)
  -----------------------------------------------------------------------------}

  sSQL_NewDepartment = 'Create Table $Table(R_ID $Inc, D_ID varChar(15),' +
       'D_Name varChar(52), D_PY varChar(54), D_Parent varChar(15),' +
       'D_Owner varChar(32), D_Phone varChar(22))';
  {-----------------------------------------------------------------------------
   ���ŵ�λ: Department
   *.D_ID: ���
   *.D_Name: ����
   *.D_PY: ƴ��
   *.D_Parent: ����λ
   *.D_Owner: ����
   *.D_Phone: �绰
  -----------------------------------------------------------------------------}

  sSQL_NewStorage = 'Create Table $Table(R_ID $Inc, S_ID varChar(15),' +
       'S_Name varChar(52), S_PY varChar(52), S_Parent varChar(15),' +
       'S_Owner varChar(32), S_Phone varChar(22))';
  {-----------------------------------------------------------------------------
   �ֿ��λ: Storage
   *.S_ID: ���
   *.S_Name: ����
   *.S_PY: ƴ��
   *.S_Parent: ���ֿ�
   *.S_Owner: ����Ա
   *.S_Phone: �绰
  -----------------------------------------------------------------------------}

  sSQL_NewProvider = 'Create Table $Table(R_ID $Inc, P_ID varChar(15),' +
       'P_Name varChar(52), P_PY varChar(52), P_Owner varChar(32),' +
       'P_Phone varChar(22), P_Fax varChar(22), P_Addr varChar(100))';
  {-----------------------------------------------------------------------------
   ��Ӧ����: Provider
   *.P_ID: ���
   *.P_Name: ����
   *.P_PY: ƴ��
   *.P_Owner: ��ϵ��
   *.P_Phone: �绰
   *.P_Fax:����
   *.P_Addr: ��ַ
  -----------------------------------------------------------------------------}

  sSQL_NewProvideDtl = 'Create Table $Table(R_ID $Inc, D_PID varChar(15),' +
       'D_Goods varChar(15), D_Valid Char(1) Default ''Y'')';
  {-----------------------------------------------------------------------------
   ��Ӧ����: Provider
   *.R_ID: ���
   *.D_PID: ��Ӧ��
   *.D_Goods: ��Ʒ
   *.D_Valid: ��Ч(Y,N)
  -----------------------------------------------------------------------------}

  sSQL_NewGoodsType = 'Create Table $Table(R_ID $Inc, T_ID varChar(15),' +
       'T_Name varChar(32), T_Parent varChar(15))';
  {-----------------------------------------------------------------------------
   ��Ʒ����: GoodsType
   *.T_ID: ���
   *.T_Name: ����
   *.T_Parent: ����
  -----------------------------------------------------------------------------}

  sSQL_NewGoods = 'Create Table $Table(R_ID $Inc, G_ID varChar(15),' +
       'G_Name varChar(52), G_PY varChar(52), G_CaiZhi varChar(32),' +
       'G_GuiGe varChar(32), G_Unit varChar(32), G_Type Char(1),' +
       'G_GType varChar(100), G_Storage varChar(15), G_OutStyle Char(1))';
  {-----------------------------------------------------------------------------
   ��Ʒ: Storage
   *.G_ID: ���
   *.G_Name: ����
   *.G_PY: ƴ��
   *.G_CaiZhi: ����
   *.G_GuiGe: ���
   *.G_Unit: ��λ
   *.G_Type: ����(��Ʒ,����)
   *.G_GType: ��Ʒ����
   *.G_Storage: ��λ
   *.G_OutStyle: ���ֹ���(�Ƚ��ȳ�..)
  -----------------------------------------------------------------------------}

  sSQL_NewWeeks = 'Create Table $Table(W_ID $Inc, W_NO varChar(15),' +
       'W_Name varChar(50), W_Begin DateTime, W_End DateTime,' +
       'W_Man varChar(32), W_Date DateTime, W_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   �ɹ�����:Weeks
   *.W_ID:��¼���
   *.W_NO:���ڱ��
   *.W_Name:����
   *.W_Begin:��ʼ
   *.W_End:����
   *.W_Man:������
   *.W_Date:����ʱ��
   *.W_Memo:��ע��Ϣ
  -----------------------------------------------------------------------------}

  sSQL_NewBuyReq = 'Create Table $Table(R_ID $Inc, R_Week varChar(15),' +
       'R_Department varChar(15), R_Goods varChar(15), R_Num $Float Default 0,' +
       'R_Date DateTime, R_Man varChar(32), R_Memo varChar(100))';
  {-----------------------------------------------------------------------------
   �ɹ�����:BuyReq
   *.R_ID:��¼���
   *.R_Week:���ڱ��
   *.R_Department:����
   *.R_Goods:��Ʒ
   *.R_Num:������
   *.R_Date:����ʱ��
   *.R_Man:������
   *.R_Memo:��ע��Ϣ
  -----------------------------------------------------------------------------}

  sSQL_NewBuyPlan = 'Create Table $Table(P_ID $Inc, P_Week varChar(15),' +
       'P_Goods varChar(15), P_Num $Float Default 0, P_Has $Float Default 0,' +
       'P_Done $Float Default 0, P_Man varChar(32), P_Date DateTime)';
  {-----------------------------------------------------------------------------
   �ɹ��ƻ�:BuyPlan
   *.P_ID:��¼���
   *.P_Week:���ڱ��
   *.P_Goods:��Ʒ
   *.P_Num:��Ŀ
   *.P_Has:���
   *.P_Done:�����
   *.P_Man:������
   *.P_Date:����ʱ��
  -----------------------------------------------------------------------------}

  sSQL_NewYuanLiao = 'Create Table $Table(R_ID $Inc, Y_Week varChar(15),' +
       'Y_Goods varChar(15), Y_GuiGe varChar(32), Y_Unit varChar(32),' +
       'Y_Provider varChar(15), Y_Storage varChar(15), Y_Num $Float,' +
       'Y_Price $Float, Y_Memo varChar(100), Y_Man varChar(32), Y_Date DateTime)';
  {-----------------------------------------------------------------------------
   ��Ʒ: YuanLiao
   *.R_ID: ���
   *.Y_Week:����
   *.Y_Goods: ��Ʒ
   *.Y_GuiGe: ���
   *.Y_Unit: ��λ
   *.Y_Provider: ��Ӧ��
   *.Y_Storage: ��λ
   *.Y_Num,Y_Price:��������
   *.Y_Memo: ��ע��Ϣ
   *.Y_Man,Y_Date: �����
  -----------------------------------------------------------------------------}

  sSQL_NewBeiPin = 'Create Table $Table(R_ID $Inc, B_Week varChar(15),' +
       'B_Goods varChar(15), B_Serial varChar(32), B_TuNo varChar(32),' +
       'B_CaiZhi varChar(32), B_GuiGe varChar(32), B_Unit varChar(32),' +
       'B_Provider varChar(15), B_Storage varChar(15), B_Num $Float,' +
       'B_Price $Float, B_PerZ $Float, B_Memo varChar(100), B_Man varChar(32),'+
       'B_Date DateTime)';
  {-----------------------------------------------------------------------------
   ��Ʒ: BeiPin
   *.R_ID: ���
   *.B_Week: ����
   *.B_Goods: ��Ʒ
   *.B_Serial:���
   *.B_TuNo:ͼ��
   *.B_CaiZhi:����
   *.B_GuiGe: ���
   *.B_Unit: ��λ
   *.B_Provider: ��Ӧ��
   *.B_Storage: ��λ
   *.B_Num,Y_Price:��������
   *.B_PerZ: ����
   *.B_Memo: ��ע��Ϣ
   *.B_Man,B_Date: �����
  -----------------------------------------------------------------------------}

  sSQL_NewChuKU = 'Create Table $Table(R_ID $Inc, C_Goods varChar(15),' +
       'C_GType Char(1), C_Depart varChar(15), C_Num $Float, '+
       'C_Memo varChar(100), C_Man varChar(32), C_Date DateTime)';
  {-----------------------------------------------------------------------------
   ��Ʒ: ChuKu
   *.R_ID: ���
   *.C_Goods: ��Ʒ
   *.C_GType: ����
   *.C_Depart: ����
   *.C_Num:����
   *.C_Memo:��ע
   *.C_Man,C_Date: �����
  -----------------------------------------------------------------------------}

  sSQL_NewChuKuDtl = 'Create Table $Table(R_ID $Inc, D_CID varChar(15),' +
       'D_RID varChar(15), D_RWeek varChar(15), D_RStorage varChar(15),' +
       'D_Goods varChar(15), D_Num $Float)';
  {-----------------------------------------------------------------------------
   ��Ʒ: ChuKuDtl
   *.R_ID: ���
   *.D_CID: �����¼��
   *.D_RID: ����¼��
   *.D_RWeek: �������
   *.D_RStorage: ����λ
   *.D_Goods: ��Ʒ���
   *.D_Num: ��������
  -----------------------------------------------------------------------------}

  sSQL_NewKuCun = 'Create Table $Table(R_ID $Inc, K_Goods varChar(15),' +
       'K_Storage varChar(15), K_RuKu $Float Default 0,' +
       'K_ChuKu $Float Default 0, K_Man varChar(32), K_Date DateTime)';
  {-----------------------------------------------------------------------------
   ��Ʒ: BeiPin
   *.R_ID: ���
   *.K_Goods: ��Ʒ
   *.K_Storage: ��λ
   *.K_RuKu:�����
   *.K_ChuKu:������
   *.K_Man,K_Date:�̿���
  -----------------------------------------------------------------------------}

//------------------------------------------------------------------------------
// ���ݲ�ѯ
//------------------------------------------------------------------------------
  sQuery_SysDict = 'Select D_ID, D_Value, D_Memo From $Table ' +
                   'Where D_Name=''$Name'' Order By D_Index ASC';
  {-----------------------------------------------------------------------------
   �������ֵ��ȡ����
   *.$Table:�����ֵ��
   *.$Name:�ֵ�������
  -----------------------------------------------------------------------------}

  sQuery_ExtInfo = 'Select I_ID, I_Item, I_Info From $Table Where ' +
                   'I_Group=''$Group'' and I_ItemID=''$ID'' Order By I_Index Desc';
  {-----------------------------------------------------------------------------
   ����չ��Ϣ���ȡ����
   *.$Table:��չ��Ϣ��
   *.$Group:��������
   *.$ID:��Ϣ��ʶ
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

  AddSysTableItem(sTable_Unit, sSQL_NewUnit);
  AddSysTableItem(sTable_Department, sSQL_NewDepartment);
  AddSysTableItem(sTable_Storage, sSQL_NewStorage);

  AddSysTableItem(sTable_Provider, sSQL_NewProvider);
  AddSysTableItem(sTable_ProvideDtl, sSQL_NewProvideDtl);

  AddSysTableItem(sTable_GoodsType, sSQL_NewGoodsType);
  AddSysTableItem(sTable_Goods, sSQL_NewGoods);
  AddSysTableItem(sTable_Weeks, sSQL_NewWeeks);
  AddSysTableItem(sTable_BuyReq, sSQL_NewBuyReq);
  AddSysTableItem(sTable_BuyPlan, sSQL_NewBuyPlan);

  AddSysTableItem(sTable_YuanLiao, sSQL_NewYuanLiao);
  AddSysTableItem(sTable_BeiPin, sSQL_NewBeiPin);
  AddSysTableItem(sTable_ChuKu, sSQL_NewChuKU);
  AddSysTableItem(sTable_ChuKuDtl, sSQL_NewChuKuDtl);

  AddSysTableItem(sTable_KuCun, sSQL_NewKuCun);
  AddSysTableItem(sTable_KuCunTmp, sSQL_NewKuCun);
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


