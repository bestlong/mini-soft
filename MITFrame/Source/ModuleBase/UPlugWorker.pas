{*******************************************************************************
  ����: dmzn@163.com 2013-11-23
  ����: ģ�鹤������,������Ӧ����¼�
*******************************************************************************}
unit UPlugWorker;

interface

uses
  Windows, Classes, UMgrPlug;

type
  TPlugWorker = class(TPlugEventWorker)
  public
    class function ModuleInfo: TPlugModuleInfo; override;
  end;

implementation

class function TPlugWorker.ModuleInfo: TPlugModuleInfo;
begin
  Result := inherited ModuleInfo;
  Result.FModuleName := '����ģ��';
end;

end.
