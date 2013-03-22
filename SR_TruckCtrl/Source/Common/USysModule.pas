{*******************************************************************************
  ����: dmzn@163.com 2009-6-25
  ����: ��Ԫģ��

  ��ע: ����ģ������ע������,ֻҪUsesһ�¼���.
*******************************************************************************}
unit USysModule;

{$I Link.Inc}
interface

uses
  Windows, Forms, SysUtils, USysConst,
  //System Object
  UMgrDBConn, USysLoger, USysShareMem, UMgrConnection, 
  //System frame Module
  UFrameRealTime, UFrameRunMon, UFrameReport, UFrameRunLog, UFrameConfig,
  UFrameSetSystem, UFrameSetDevice, UFrameSetPort, UFrameHistogram,
  //System form Module
  UFormSetDB, UFormCOMPort, UFormDevice, UFormSetIndex, UFormPressMax,
  UFormSysParam, UFormChartStyle;

procedure InitSystemObject;
procedure RunSystemObject(const nFormHandle: THandle);
procedure FreeSystemObject;

implementation

//Desc: ��ʼ��ϵͳ����
procedure InitSystemObject;
begin
  gSysLoger := TSysLoger.Create(gPath + sLogDir, 'SR_TruckCtrl_Loger');
  //system loger

  //gDBConnManager := TDBConnManager.Create;
  gDBConnManager.MaxConn := 10; 
  //db conn pool

  {$IFNDEF DEBUG}
  gProcessMonitorClient := TProcessMonitorClient.Create(gSysParam.FProgID);
  //process monitor
  {$ENDIF}
end;

//Desc: ����ϵͳ����
procedure RunSystemObject(const nFormHandle: THandle);
var nStr: string;
begin
  {$IFNDEF DEBUG}
  if Assigned(gProcessMonitorClient) then
  begin
    gProcessMonitorClient.UpdateHandle(nFormHandle, GetCurrentProcessId, nStr);
    gProcessMonitorClient.StartMonitor(nStr, FMonInterval);
  end;
  {$ENDIF}
end;

//Desc: �ͷ�ϵͳ����
procedure FreeSystemObject;
begin
  gPortManager.StopReader;
  //stop port
  
  if Assigned(gProcessMonitorSapMITClient) then
  begin
    gProcessMonitorSapMITClient.StopMonitor(Application.Active);
    FreeAndNil(gProcessMonitorSapMITClient);
  end; //stop monitor
end;

end.
