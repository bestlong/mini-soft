{*******************************************************************************
  ����: dmzn@163.com 2014-04-27
  ����: �������������ӿ�ʵ��
*******************************************************************************}
unit UNetCounter;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, UMultiJS_Net, USysLoger;

procedure LibraryEntity(const nReason: Integer);
//��ں���

function JSLoadConfig(const nConfigFile: PChar): Boolean; stdcall;
//��������
procedure JSServiceStart; stdcall;
procedure JSServiceStop; stdcall;
//��ͣ����
function JSStart(const nTunnel,nTruck: PChar; const nDaiNum: Integer): Boolean; stdcall;
//��Ӽ���
function JSStop(const nTunnel: PChar): Boolean; stdcall;
//ֹͣ����
function JSStatus(const nStatus: PChar): Integer; stdcall;
//����״̬    

implementation

const
  sLogDir             = 'Logs\';                     //��־Ŀ¼
  sLogSyncLock        = 'SyncLock_MIT_CommonMIT';    //��־ͬ����

var
  gPath: string;
  //ģ������·��
  gStatusList: TStrings = nil;
  gSyncLock: TCriticalSection = nil;
  //����״̬�б�

//------------------------------------------------------------------------------
//Date: 2014-04-27
//Desc: ��ʼ��ϵͳ����
procedure InitSystemObjects;
var nBuf: array[0..MAX_PATH-1] of Char;
begin
  gPath := Copy(nBuf, 1, GetModuleFileName(HInstance, nBuf, MAX_PATH));
  gPath := ExtractFilePath(gPath);

  gSysLoger := TSysLoger.Create(gPath + sLogDir, sLogSyncLock);
  //��־������

  gStatusList := TStringList.Create;
  gSyncLock := TCriticalSection.Create;
end;

//Date: 2014-04-27
//Desc: �ͷ�ϵͳ����
procedure FreeSystemObjects;
begin
  FreeAndNil(gStatusList);
  FreeAndNil(gSyncLock);
end;

procedure LibraryEntity(const nReason: Integer);
begin
  case nReason of
   DLL_PROCESS_ATTACH : InitSystemObjects;
   DLL_PROCESS_DETACH : FreeSystemObjects;
   DLL_THREAD_ATTACH : IsMultiThread := True;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2014-04-27
//Parm: �����ļ�·��
//Desc: �����������������������ļ�
function JSLoadConfig(const nConfigFile: PChar): Boolean;
begin
  Result := False;
  try
    gMultiJSManager.LoadFile(nConfigFile);
    Result := True;
  except
    on E: Exception do
    begin
      gSysLoger.AddLog(TMultiJSManager, '�������������', E.Message);
    end;
  end;
end;

//Date: 2014-04-28
//Desc: ��������
procedure JSServiceStart;
begin
  gMultiJSManager.StartJS;
end;

//Date: 2014-04-28
//Desc: ֹͣ����
procedure JSServiceStop;
begin
  gMultiJSManager.StopJS;
end;

//Date: 2014-04-27
//Parm: ͨ����;���ƺ�;����
//Desc: ��nTunnel����nTruck.nDaiNum����
function JSStart(const nTunnel,nTruck: PChar; const nDaiNum: Integer): Boolean;
begin
  Result := gMultiJSManager.AddJS(nTunnel, nTruck, nDaiNum);
end;

//Date: 2014-04-28
//Parm: ͨ����
//Desc: ��nTunnel����ֹͣ����ָ��
function JSStop(const nTunnel: PChar): Boolean;
begin
  Result := gMultiJSManager.DelJS(nTunnel);
end;

//Date: 2014-04-28
//Parm: ״̬���
//Desc: ��ȡ�������,������Ч���ݳ���
function JSStatus(const nStatus: PChar): Integer;
begin
  gSyncLock.Enter;
  try
    gMultiJSManager.GetJSStatus(gStatusList);
    Result := Length(StrPCopy(nStatus, gStatusList.Text));
  finally
    gSyncLock.Leave;
  end;
end;

end.
