{*******************************************************************************
  ����: dmzn@163.com 2009-6-25
  ����: ��Ԫģ��

  ��ע: ����ģ������ע������,ֻҪUsesһ�¼���.
*******************************************************************************}
unit USysModule;

{$I Link.Inc}
interface

uses
  //System Object
  UHardWorker, UMITPacker, UMgrChannel, UMgrDBConn, UMgrQueue,
  UMgrLEDCard, UMgrHardHelper, U02NReader, UMgrRemoteVoice;

procedure InitSystemObject;
procedure RunSystemObject(const nFormHandle: THandle);
procedure FreeSystemObject;

implementation

uses
  Windows, Forms, SysUtils, USysLoger, UMITConst, USysShareMem, UParamManager;

//Desc: ��ʼ��ϵͳ����
procedure InitSystemObject;
begin
  gSysLoger := TSysLoger.Create(gPath + sLogDir, 'Hard_Mon_Loger');
  //system loger

  //gDBConnManager := TDBConnManager.Create;
  //db conn pool

  gParamManager := TParamManager.Create(gPath + sConfigFile);
  if gSysParam.FProgID <> '' then
    gParamManager.GetParamPack(gSysParam.FProgID, True);
  //runtime parameter

  gProcessMonitorClient := TProcessMonitorClient.Create(gSysParam.FProgID);
  //process monitor

  gHardwareHelper := THardwareHelper.Create;
  //Զ���ͷ
end;

//Desc: ����ϵͳ����
procedure RunSystemObject(const nFormHandle: THandle);
var nStr: string;
begin
  try
    nStr := 'LED';
    gCardManager.TempDir := gPath + 'Temp\';
    gCardManager.FileName := gPath + 'LED.xml';

    nStr := 'Զ���ͷ';
    gHardwareHelper.LoadConfig(gPath + '900MK.xml');

    nStr := '�����ͷ';
    g02NReader.LoadConfig(gPath + 'Readers.xml');

    nStr := '��������';
    gVoiceHelper.LoadConfig(gPath + 'Voice.xml');
  except
    on E:Exception do
    begin
      nStr := Format('����[ %s ]�����ļ�ʧ��: %s', [nStr, E.Message]);
      gSysLoger.AddLog(nStr);
    end;
  end;
end;

//Desc: �ͷ�ϵͳ����
procedure FreeSystemObject;
begin
  FreeAndNil(gHardShareData);
  //hard monitor
  
  if Assigned(gProcessMonitorClient) then
  begin
    gProcessMonitorClient.StopMonitor(Application.Active);
    FreeAndNil(gProcessMonitorClient);
  end; //stop monitor
end;

end.
