{*******************************************************************************
  ����: dmzn@ylsoft.com 2007-10-09
  ����: ��Ŀͨ�ó�,�������嵥Ԫ
*******************************************************************************}
unit USysConst;

interface

uses
  SysUtils, Classes, ComCtrls, UMgrSync;

const
  cSBar_Date            = 0;                         //�����������
  cSBar_Time            = 1;                         //ʱ���������
  cImg_Pack             = 2;                         //����������
  cImg_Time             = 3;                         //ʱ�������

type
  TSysParam = record
    FProgID     : string;                            //�����ʶ
    FAppTitle   : string;                            //�����������ʾ
    FMainTitle  : string;                            //���������
    FHintText   : string;                            //��ʾ�ı�
    FCopyRight  : string;                            //��������ʾ����
  end;
  //ϵͳ����

  TWriteDebugLog = procedure (const nMsg: string; const nMustShow: Boolean) of object;
  //������־

  procedure ShowSyncLog(const nMsg: string);
  //�߳�ͬ����־

//------------------------------------------------------------------------------
var
  gPath: string;                                     //��������·��
  gSysParam:TSysParam;                               //���򻷾�����
  gDebugLog: TWriteDebugLog;                         //������־

//------------------------------------------------------------------------------
ResourceString
  sProgID             = 'DMZN';                      //Ĭ�ϱ�ʶ
  sAppTitle           = 'DMZN';                      //�������
  sMainCaption        = 'DMZN';                      //�����ڱ���

  sHint               = '��ʾ';                      //�Ի������
  sWarn               = '����';                      //==
  sAsk                = 'ѯ��';                      //ѯ�ʶԻ���
  sError              = 'δ֪����';                  //����Ի���

  sDate               = '����:��%s��';               //����������
  sTime               = 'ʱ��:��%s��';               //������ʱ��
  sUser               = '�û�:��%s��';               //�������û�

  sLogDir             = 'Logs\';                     //��־Ŀ¼
  sLogExt             = '.log';                      //��־��չ��
  sLogField           = #9;                          //��¼�ָ���

  sImageDir           = 'Images\';                   //ͼƬĿ¼
  sReportDir          = 'Report\';                   //����Ŀ¼
  sBackupDir          = 'Backup\';                   //����Ŀ¼
  sBackupFile         = 'Bacup.idx';                 //��������

  sConfigFile         = 'Config.Ini';                //�������ļ�
  sConfigSec          = 'Config';                    //������С��
  sVerifyCode         = ';Verify:';                  //У������

  sFormConfig         = 'FormInfo.ini';              //��������
  sSetupSec           = 'Setup';                     //����С��
  sDBConfig           = 'DBConn.ini';                //��������

  sExportExt          = '.txt';                      //����Ĭ����չ��
  sExportFilter       = '�ı�(*.txt)|*.txt|�����ļ�(*.*)|*.*';
                                                     //������������

  sInvalidConfig      = '�����ļ���Ч���Ѿ���';    //�����ļ���Ч
  sCloseQuery         = 'ȷ��Ҫ�˳�������?';         //�������˳�

  
implementation

var
  gLogSync: TDataSynchronizer = nil;
  //��־ͬ������

procedure ShowSyncLog(const nMsg: string);
var nBuf: PChar;
    nLen: Integer;
begin
  nLen := Length(nMsg);
  if nLen < 1 then Exit;

  GetMem(nBuf, nLen+1);
  StrLCopy(nBuf, PChar(nMsg), nLen);

  gLogSync.AddData(nBuf, nLen + 1);
  gLogSync.ApplySync;
end;

procedure DoSync(const nData: Pointer; const nSize: Cardinal);
begin
  gDebugLog(StrPas(nData), True);
end;

procedure DoFree(const nData: Pointer; const nSize: Cardinal);
begin
  FreeMem(nData, nSize);
end;

initialization
  gLogSync := TDataSynchronizer.Create;
  gLogSync.SyncProcedure := DoSync;
  gLogSync.SyncFreeProcedure := DoFree;
finalization
  FreeAndNil(gLogSync);
end.


