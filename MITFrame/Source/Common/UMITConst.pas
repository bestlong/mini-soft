{*******************************************************************************
  ����: dmzn@163.com 2011-10-22
  ����: ��������
*******************************************************************************}
unit UMITConst;

{$I Link.Inc}
interface

uses
  Windows, SysUtils, Classes, ComCtrls, Forms, IniFiles, Registry,
  ZnExeData, USysMAC;

const
  cSBar_Date            = 0;                         //�����������
  cSBar_Time            = 1;                         //ʱ���������
  cSBar_User            = 2;                         //�û��������

type
  TSysParam = record
    FProgID     : string;                            //�����ʶ
    FAppTitle   : string;                            //�����������ʾ
    FMainTitle  : string;                            //���������
    FHintText   : string;                            //��ʾ�ı�

    FLocalIP    : string;                            //����IP
    FLocalMAC   : string;                            //����MAC
    FLocalName  : string;                            //��������

    FDisplayDPI : Integer;                           //��Ļ�ֱ���
    FAutoMin    : Boolean;                           //�Զ���С��
  end;
  //ϵͳ����

var
  gPath: string;                                     //��������·��
  gSysParam:TSysParam;                               //���򻷾�����
  gStatusBar: TStatusBar;                            //ȫ��ʹ��״̬��
  gShareData: TZnPostData;                           //��������ݹ���

procedure InitSystemEnvironment;
//��ʼ��ϵͳ���л����ı���
procedure ActionSysParameter(const nIsRead: Boolean);
//��дϵͳ���ò���

procedure ShowMsgOnLastPanelOfStatusBar(const nMsg: string);
procedure StatusBarMsg(const nMsg: string; const nIdx: integer);
//��״̬����ʾ��Ϣ

//------------------------------------------------------------------------------
ResourceString
  sProgID             = 'Bus_MIT';                   //Ĭ�ϱ�ʶ
  sAppTitle           = 'Bus_MIT';                   //�������
  sMainCaption        = 'ͨ���м��';                //�����ڱ���
  sHintText           = 'ͨ���м������';            //��ʾ����

  sHint               = '��ʾ';                      //�Ի������
  sWarn               = '����';                      //==
  sAsk                = 'ѯ��';                      //ѯ�ʶԻ���
  sError              = '����';                      //����Ի���

  sDate               = '����:��%s��';               //����������
  sTime               = 'ʱ��:��%s��';               //������ʱ��
  sUser               = '�û�:��%s��';               //�������û�
                                                               
  sConfigFile         = 'Config.Ini';                //�������ļ�
  sFormConfig         = 'FormInfo.ini';              //��������
  sLogDir             = 'Logs\';                     //��־Ŀ¼
  sLogSyncLock        = 'SyncLock_MIT_CommonMIT';    //��־ͬ����

  sInvalidConfig      = '�����ļ���Ч���Ѿ���';    //�����ļ���Ч
  sCloseQuery         = 'ȷ��Ҫ�˳�������?';         //�������˳�
  
implementation

procedure InitSystemEnvironment;
begin
  Randomize;
  ShortDateFormat := 'YYYY-MM-DD';
  gPath := ExtractFilePath(Application.ExeName);
end;

//Desc: ��дϵͳ���ò���
procedure ActionSysParameter(const nIsRead: Boolean);
var nIni: TIniFile;
begin
  nIni := nil;
  try
    nIni := TIniFile.Create(gPath + sConfigFile);
    //config file

    with nIni,gSysParam do
    begin
      if nIsRead then
      begin 
        FProgID     := ParamStr(1);
        FAppTitle   := sAppTitle;
        FMainTitle  := sMainCaption;
        FHintText   := sHintText;

        FLocalMAC   := MakeActionID_MAC;
        GetLocalIPConfig(FLocalName, FLocalIP);
        FDisplayDPI := GetDeviceCaps(GetDC(0), LOGPIXELSY);
      end else
      begin
        WriteBool('System', 'AutoMin', FAutoMin);
      end;
    end;
  finally
    nIni.Free;
  end; 
end;

//------------------------------------------------------------------------------
//Desc: ��ȫ��״̬�����һ��Panel����ʾnMsg��Ϣ
procedure ShowMsgOnLastPanelOfStatusBar(const nMsg: string);
begin
  if Assigned(gStatusBar) and (gStatusBar.Panels.Count > 0) then
  begin
    gStatusBar.Panels[gStatusBar.Panels.Count - 1].Text := nMsg;
    Application.ProcessMessages;
  end;
end;

//Desc: ������nIdx��Panel����ʾnMsg��Ϣ
procedure StatusBarMsg(const nMsg: string; const nIdx: integer);
begin
  if Assigned(gStatusBar) and (gStatusBar.Panels.Count > nIdx) and
     (nIdx > -1) then
  begin
    gStatusBar.Panels[nIdx].Text := nMsg;
    gStatusBar.Panels[nIdx].Width := gStatusBar.Canvas.TextWidth(nMsg) +
                                     Trunc(gSysParam.FDisplayDPI * Length(nMsg) / 50);
    //Application.ProcessMessages;
  end;
end;

end.
