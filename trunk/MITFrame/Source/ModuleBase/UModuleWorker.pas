{*******************************************************************************
  ����: dmzn@163.com 2013-12-04
  ����: ģ��ҵ�����
*******************************************************************************}
unit UModuleWorker;

interface

uses
  UBusinessWorker, UBusinessPacker, UBusinessConst, UMITWorker, UPlugWorker;

implementation

//------------------------------------------------------------------------------
var
  gModuleID: string = '';
  //ģ���ʶ

initialization
  gModuleID := TPlugWorker.ModuleInfo.FModuleID;
  
end.
