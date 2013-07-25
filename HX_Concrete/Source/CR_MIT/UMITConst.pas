{*******************************************************************************
  ����: dmzn@163.com 2011-10-22
  ����: ��������
*******************************************************************************}
unit UMITConst;

{$I Link.Inc}
interface

uses
  Windows, SysUtils, Classes, ComCtrls, Forms, IniFiles, Registry, IdUDPServer,
  USysMAC;

const
  cSBar_Date            = 0;                         //�����������
  cSBar_Time            = 1;                         //ʱ���������
  cSBar_User            = 2;                         //�û��������

const
  cFI_FrameRunlog     = $0002;                       //������־
  cFI_FrameSummary    = $0005;                       //��ϢժҪ
  cFI_FrameParam      = $0006;                       //��������
  cFI_FrameHard       = $0007;                       //Ӳ������

type
  TSysParam = record
    FProgID     : string;                            //�����ʶ
    FAppTitle   : string;                            //�����������ʾ
    FMainTitle  : string;                            //���������
    FHintText   : string;                            //��ʾ�ı�

    FCompany    : string;                            //��˾����
    FAutoStart  : Boolean;                           //����������
    FAutoMin    : Boolean;                           //������С��

    FLocalIP    : string;                            //����IP
    FLocalMAC   : string;                            //����MAC
    FLocalName  : string;                            //��������
    F02NReader  : Integer;                           //�ֳ�������
    F2ClientUDP : Integer;                           //�Կͻ���UDP
  end;
  //ϵͳ����

var
  gPath: string;                                     //��������·��
  gSysParam:TSysParam;                               //���򻷾�����
  gStatusBar: TStatusBar;                            //ȫ��ʹ��״̬��
  gClientUDPServer: TIdUDPServer;                    //�ͻ���UDPͨ��

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
  sAppTitle           = 'Business MIT';              //�������
  sMainCaption        = 'ҵ���м��';                //�����ڱ���
  sHintText           = '����ϵͳ����ҵ�����';      //��ʾ����

  sAutoStartKey       = 'HX_BusMIT';                 //��������ֵ
  sStartServerHint    = '����ҵ��MIT����';           //��ʾ����


  sHint               = '��ʾ';                      //�Ի������
  sWarn               = '����';                      //==
  sAsk                = 'ѯ��';                      //ѯ�ʶԻ���
  sError              = 'δ֪����';                  //����Ի���

  sDate               = '����:��%s��';               //����������
  sTime               = 'ʱ��:��%s��';               //������ʱ��
  sUser               = '�û�:��%s��';               //�������û�
                                                               
  sConfigFile         = 'Config.Ini';                //�������ļ�
  sFormConfig         = 'FormInfo.ini';              //��������
  sLogDir             = 'Logs\';                     //��־Ŀ¼
  sSetupSec           = 'Setup';                     //����С��

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
    nReg: TRegistry;
begin
  nIni := nil;
  nReg := nil;
  try
    nReg := TRegistry.Create;
    nReg.RootKey := HKEY_CURRENT_USER;
    nReg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True);
    //registry

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

        FAutoStart := nReg.ValueExists(sAutoStartKey);
        FAutoMin := ReadBool('System', 'AutoMin', False);

        FLocalMAC   := MakeActionID_MAC;
        GetLocalIPConfig(FLocalName, FLocalIP);

        F02NReader := ReadInteger('System', '02NReader', 1234);
        F2ClientUDP := ReadInteger('System', 'ClientUDPPort', 8050);
      end else
      begin
        WriteBool('System', 'AutoMin', FAutoMin);

        if FAutoStart then
          nReg.WriteString(sAutoStartKey, Application.ExeName)
        else if nReg.ValueExists(sAutoStartKey) then
          nReg.DeleteValue(sAutoStartKey);
        //xxxxx
      end;
    end;
  finally
    nReg.Free;
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
    gStatusBar.Panels[nIdx].Width := gStatusBar.Canvas.TextWidth(nMsg) + 20;
    Application.ProcessMessages;
  end;
end;

end.
