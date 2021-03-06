{*******************************************************************************
  作者: dmzn@163.com 2008-08-07
  描述: 系统数据库常量定义

  备注:
  *.自动创建SQL语句,支持变量:$Inc,自增;$Float,浮点;$Integer=sFlag_Integer;
    $Decimal=sFlag_Decimal;$Image,二进制流
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
  //系统表项

var
  gSysTableList: TList = nil;                        //系统表数组
  gSysDBType: TSysDatabaseType = dtSQLServer;        //系统数据类型

//------------------------------------------------------------------------------
const
  //自增字段
  sField_Access_AutoInc          = 'Counter';
  sField_SQLServer_AutoInc       = 'Integer IDENTITY (1,1) PRIMARY KEY';

  //小数字段
  sField_Access_Decimal          = 'Float';
  sField_SQLServer_Decimal       = 'Decimal(15, 5)';

  //图片字段
  sField_Access_Image            = 'OLEObject';
  sField_SQLServer_Image         = 'Image';

  //日期相关
  sField_SQLServer_Now           = 'getDate()';

ResourceString     
  {*权限项*}
  sPopedom_Read       = 'A';                         //浏览
  sPopedom_Add        = 'B';                         //添加
  sPopedom_Edit       = 'C';                         //修改
  sPopedom_Delete     = 'D';                         //删除
  sPopedom_Preview    = 'E';                         //预览
  sPopedom_Print      = 'F';                         //打印
  sPopedom_Export     = 'G';                         //导出

  {*相关标记*}
  sFlag_Yes           = 'Y';                         //是
  sFlag_No            = 'N';                         //否
  sFlag_Enabled       = 'Y';                         //启用
  sFlag_Disabled      = 'N';                         //禁用

  sFlag_Integer       = 'I';                         //整数
  sFlag_Decimal       = 'D';                         //小数

  sFlag_CarType       = 'CarType';                   //车厢类型
  sFlag_CarMode       = 'CarMode';                   //车厢型号
  sFlag_TrainID       = 'TrainID';                   //火车标识

  sFlag_QInterval     = 'QueryInterval';             //查询间隔
  sFlag_CollectTime   = 'CollectInterval';           //采集间隔
  sFlag_ResetTime     = 'FrameResetTime';            //时钟同步
  sFlag_PrintSend     = 'PrintSendData';
  sFlag_PrintRecv     = 'PrintRecvData';             //打印数据
  sFlag_UIInterval    = 'UIItemInterval';            //界面间隔
  sFlag_UIMaxValue    = 'UIItemMaxValue';            //最大进度
  sFlag_ChartCount    = 'ChartMaxCount';             //最大点数
  sFlag_ChartTime     = 'ChartTimeLong';             //数据时长
  sFlag_ReportPage    = 'ReportPageSize';            //报表页(小时)

  {*数据表*}
  sTable_Entity       = 'Sys_Entity';                //字典实体
  sTable_DictItem     = 'Sys_DataDict';              //字典明细
  sTable_SysDict      = 'Sys_Dict';                  //系统字典
  sTable_ExtInfo      = 'Sys_ExtInfo';               //附加信息
  sTable_SysLog       = 'Sys_EventLog';              //系统日志
  sTable_BaseInfo     = 'Sys_BaseInfo';              //基础信息

  sTable_Carriage     = 'T_Carriage';                //车厢
  sTable_Device       = 'T_Device';                  //设备
  sTable_Port         = 'T_COMPort';                 //串口

  sTable_BreakPipe    = 'T_BreakPipe';
  sTable_BreakPot     = 'T_BreakPot';
  sTable_TotalPipe    = 'T_TotalPipe';               //数据记录

  {*新建表*}
  sSQL_NewSysDict = 'Create Table $Table(D_ID $Inc, D_Name varChar(15),' +
       'D_Desc varChar(30), D_Value varChar(50), D_Memo varChar(20),' +
       'D_ParamA $Float, D_ParamB varChar(50), D_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   系统字典: SysDict
   *.D_ID: 编号
   *.D_Name: 名称
   *.D_Desc: 描述
   *.D_Value: 取值
   *.D_Memo: 相关信息
   *.D_ParamA: 浮点参数
   *.D_ParamB: 字符参数
   *.D_Index: 显示索引
  -----------------------------------------------------------------------------}
  
  sSQL_NewExtInfo = 'Create Table $Table(I_ID $Inc, I_Group varChar(20),' +
       'I_ItemID varChar(20), I_Item varChar(30), I_Info varChar(50),' +
       'I_ParamA $Float, I_ParamB varChar(50), I_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   扩展信息表: ExtInfo
   *.I_ID: 编号
   *.I_Group: 信息分组
   *.I_ItemID: 信息标识
   *.I_Item: 信息项
   *.I_Info: 信息内容
   *.I_ParamA: 浮点参数
   *.I_ParamB: 字符参数
   *.I_Memo: 备注信息
   *.I_Index: 显示索引
  -----------------------------------------------------------------------------}
  
  sSQL_NewSysLog = 'Create Table $Table(L_ID $Inc, L_Date DateTime,' +
       'L_Man varChar(32),L_Group varChar(20), L_ItemID varChar(20),' +
       'L_KeyID varChar(20), L_Event varChar(220))';
  {-----------------------------------------------------------------------------
   系统日志: SysLog
   *.L_ID: 编号
   *.L_Date: 操作日期
   *.L_Man: 操作人
   *.L_Group: 信息分组
   *.L_ItemID: 信息标识
   *.L_KeyID: 辅助标识
   *.L_Event: 事件
  -----------------------------------------------------------------------------}

  sSQL_NewBaseInfo = 'Create Table $Table(B_ID $Inc, B_Group varChar(15),' +
       'B_Text varChar(50), B_Py varChar(25), B_Memo varChar(25),' +
       'B_PID Integer, B_Index Float)';
  {-----------------------------------------------------------------------------
   基本信息表: BaseInfo
   *.B_ID: 编号
   *.B_Group: 分组
   *.B_Text: 内容
   *.B_Py: 拼音简写
   *.B_Memo: 备注信息
   *.B_PID: 上级节点
   *.B_Index: 创建顺序
  -----------------------------------------------------------------------------}

  sSQL_NewCarriage = 'Create Table $Table(R_ID $Inc, C_ID varChar(15),' +
       'C_Name varChar(50), C_TypeID Integer, C_TypeName varChar(32), ' +
       'C_ModeID Integer, C_ModeName varChar(32), C_Position Integer)';
  {-----------------------------------------------------------------------------
   车厢: Carriage
   *.R_ID: 记录号
   *.C_ID: 标识
   *.C_Name: 名称
   *.C_TypeID,C_TypeName: 类型
   *.C_ModeID,C_ModeName: 型号
   *.C_Postion: 前后位置
  -----------------------------------------------------------------------------}

  sSQL_NewDevice = 'Create Table $Table(R_ID $Inc, D_ID varChar(15),' +
       'D_Port varChar(16), D_Serial varChar(50), D_Index Integer,' +
       'D_Carriage varChar(15), D_clBreakPipe Integer, D_clBreakPot Integer,' +
       'D_clTotalPot Integer)';
  {-----------------------------------------------------------------------------
   设备: Device
   *.R_ID: 记录号
   *.D_ID: 标识
   *.D_Port: 端口
   *.D_Serial: 装置号
   *.D_Index: 地址索引
   *.D_Carriage: 车厢
   *.D_clBreakPipe,D_clBreakPot,D_clTotalPot: 曲线颜色
  -----------------------------------------------------------------------------}

  sSQL_NewCOMPort = 'Create Table $Table(R_ID $Inc, C_ID varChar(15),' +
       'C_Name varChar(50), C_Port varChar(16), C_Baund varChar(16),' +
       'C_DataBits varChar(16), C_StopBits varChar(16), C_Position Integer)';
  {-----------------------------------------------------------------------------
   串口: port
   *.R_ID: 记录号
   *.C_ID: 编号
   *.C_Name: 名称
   *.C_Port: 端口
   *.C_Baund: 波特率
   *.C_DataBits: 数据位
   *.C_StopBits: 起停位
   *.C_Position: 前后位置
  -----------------------------------------------------------------------------}

  sSQL_NewBreakPipe = 'Create Table $Table(R_ID $Inc, P_Train varChar(15),' +
       'P_Device varChar(15), P_Carriage varChar(15),' +
       'P_Value $Float, P_Number Integer, P_Date DateTime)';
  {-----------------------------------------------------------------------------
   制动管: BreakPipe
   *.R_ID: 记录号
   *.P_Train: 车辆标识
   *.P_Device: 设备
   *.P_Carriage: 车厢
   *.P_Value: 数据
   *.P_Number: 个数
   *.P_Date: 采集日期
  -----------------------------------------------------------------------------}

  sSQL_NewBreakPot = 'Create Table $Table(R_ID $Inc, P_Train varChar(15),' +
       'P_Device varChar(15), P_Carriage varChar(15),' +
       'P_Value $Float, P_Number Integer, P_Date DateTime)';
  {-----------------------------------------------------------------------------
   制动缸: BreakPot
   *.R_ID: 记录号
   *.P_Train: 车辆标识
   *.P_Device: 设备
   *.P_Carriage: 车厢
   *.P_Value: 数据
   *.P_Number: 个数
   *.P_Date: 采集日期
  -----------------------------------------------------------------------------}

  sSQL_NewTotalPipe = 'Create Table $Table(R_ID $Inc, P_Train varChar(15),' +
       'P_Device varChar(15), P_Carriage varChar(15),' +
       'P_Value $Float, P_Date DateTime)';
  {-----------------------------------------------------------------------------
   总风管: TotalPipe
   *.R_ID: 记录号
   *.P_Train: 车辆标识
   *.P_Device: 设备
   *.P_Carriage: 车厢
   *.P_Value: 数据
   *.P_Date: 采集日期
  -----------------------------------------------------------------------------}

//------------------------------------------------------------------------------
// 数据查询
//------------------------------------------------------------------------------
  sQuery_SysDict = 'Select D_ID, D_Value, D_Memo From $Table ' +
                   'Where D_Name=''$Name'' Order By D_Index Desc';
  {-----------------------------------------------------------------------------
   从数据字典读取数据
   *.$Table: 数据字典表
   *.$Name: 字典项名称
  -----------------------------------------------------------------------------}

  sQuery_ExtInfo = 'Select I_ID, I_Item, I_Info From $Table Where ' +
                   'I_Group=''$Group'' and I_ItemID=''$ID'' Order By I_Index Desc';    
  {-----------------------------------------------------------------------------
   从扩展信息表读取数据
   *.$Table: 扩展信息表
   *.$Group: 分组名称
   *.$ID: 信息标识
  -----------------------------------------------------------------------------}
  
implementation

//------------------------------------------------------------------------------
//Desc: 添加系统表项
procedure AddSysTableItem(const nTable,nNewSQL: string);
var nP: PSysTableItem;
begin
  New(nP);
  gSysTableList.Add(nP);

  nP.FTable := nTable;
  nP.FNewSQL := nNewSQL;
end;

//Desc: 系统表
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

//Desc: 清理系统表
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


