{*******************************************************************************
  ����: dmzn@163.com 2009-6-25
  ����: ��Ԫģ��

  ��ע: ����ģ������ע������,ֻҪUsesһ�¼���.
*******************************************************************************}
unit USysModule;

{$I Link.Inc}

interface

uses
  {$IFDEF NetMode}
  UFormJS_Net, UMultiJS_Net, UFormBackupSQL, UFormRestoreSQL,
  {$ELSE}
  UFormZTParam_M, UFormJS_M, UFormBackupAccess, UFormRestoreAccess,
  {$ENDIF}
  UFrameLog, UFrameSysLog, UFormIncInfo, UFormPassword,
  UFrameStockType, UFormStockType, UFrameTruckInfo, UFormTruckInfo,
  UFrameJSLog, UFrameCustomer, UFormCustomer, UFrameJSItem, UFormJSItem;

procedure InitSystemObject;
procedure RunSystemObject;
procedure FreeSystemObject;

implementation

uses
  USysLoger, USysConst;

//Desc: ��ʼ��ϵͳ����
procedure InitSystemObject;
begin
  gSysLoger := TSysLoger.Create(gPath + sLogDir);
  //system loger

  {$IFDEF NetMode}
  gMultiJSManager.LoadFile(gPath + 'JSQ.xml');
  {$ENDIF}
end;

//Desc: ����ϵͳ����
procedure RunSystemObject;
begin

end;

//Desc: �ͷ�ϵͳ����
procedure FreeSystemObject;
begin

end;

end.
