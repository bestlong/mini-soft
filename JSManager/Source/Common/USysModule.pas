{*******************************************************************************
  ����: dmzn@163.com 2009-6-25
  ����: ��Ԫģ��

  ��ע: ����ģ������ע������,ֻҪUsesһ�¼���.
*******************************************************************************}
unit USysModule;

{$I Link.Inc}

interface

uses
  {$IFDEF MultiJS}
  UFormZTParam_M, UFormJS_M,
  {$ELSE}
  UFormZTParam, UFormJS,
  {$ENDIF}
  UFrameLog, UFrameSysLog, UFormIncInfo, UFormPassword,
  UFrameStockType, UFormStockType, UFrameTruckInfo, UFormTruckInfo,
  UFrameJSLog, UFrameCustomer, UFormCustomer, UFormBackupAccess,
  UFormRestoreAccess, UFrameJSItem, UFormJSItem;

implementation

end.
