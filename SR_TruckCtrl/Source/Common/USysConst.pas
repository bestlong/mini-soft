{*******************************************************************************
  ����: dmzn@ylsoft.com 2007-10-09
  ����: ��Ŀͨ�ó�,�������嵥Ԫ
*******************************************************************************}
unit USysConst;

interface

uses
  Windows, SysUtils, Classes, Forms, IniFiles, Registry, UMgrDBConn,
  dxStatusBar, UBase64, ULibFun, UDataModule, UFormWait;

const
  cSBar_Date            = 0;                         //�����������
  cSBar_Time            = 1;                         //ʱ���������
  cColor_Timeout        = 0;

const
  {*Frame ID*}
  cFI_FrameRunLog       = $0001;                     //ϵͳ��־
  cFI_FrameRunMon       = $0002;                     //���м��
  cFI_FrameRealTime     = $0003;                     //ʵʱ���
  cFI_FrameReport       = $0005;                     //�����ѯ
  cFI_FrameConfig       = $0006;                     //��������
  cFI_FrameSetSystem    = $0010;                     //ϵͳ����
  cFI_FrameSetPort      = $0011;                     //��������
  cFI_FrameSetDevice    = $0012;                     //�豸����
  cFI_FrameHistogram    = $0013;                     //��״��ʾ

  cFI_FormSetDB         = $0020;                     //���ݿ�
  cFI_FormCOMPort       = $0021;                     //�˿�����
  cFI_FormDevice        = $0022;                     //�豸����
  cFI_FormSetIndex      = $0023;                     //���õ�ַ
  cFI_FormPressMax      = $0025;                     //ѹ������
  cFI_FormSysParam      = $0026;                     //ϵͳ����
  cFI_FormChartStyle    = $0027;                     //������

  {*Command*}
  cCmd_ViewSysLog       = $0001;                     //ϵͳ��־
  cCmd_RefreshData      = $0002;
  cCmd_RefreshDevList   = $0003;                     //ˢ������
                                                              
  cCmd_ModalResult      = $1001;                     //Modal����
  cCmd_FormClose        = $1002;                     //�رմ���
  cCmd_AddData          = $1003;                     //�������
  cCmd_EditData         = $1005;                     //�޸�����
  cCmd_ViewData         = $1006;                     //�鿴����
  cCmd_DeleteData       = $1007;                     //ɾ������

  cCmd_ViewPortData     = $1010;                     //�鿴�˿�
  cCmd_ViewDeviceData   = $1011;                     //�鿴�豸

type
  TSysParam = record
    FProgID     : string;                            //�����ʶ
    FAppTitle   : string;                            //�����������ʾ
    FMainTitle  : string;                            //���������

    FUserName   : string;                            //��ǰ�û�
    FUserPwd    : string;                            //�û�����
    FIsAdmin    : Boolean;                           //�Ƿ����Ա

    FAutoStart  : Boolean;                           //����������
    FAutoMin    : Boolean;                           //������С��

    FTrainID    : string;                            //�𳵱�ʶ
    FQInterval  : Cardinal;                          //��ѯָ����
    FPrintSend  : Boolean;
    FPrintRecv  : Boolean;                           //��ӡ��������
    FUIInterval : Integer;                           //����������
    FUIMaxValue : Double;                            //���������ֵ
    FChartCount : Integer;                           //�������ݵ����
    FReportPage : Integer;                           //����ҳ��С
  end;
  //ϵͳ����

//------------------------------------------------------------------------------
var
  gPath: string;                                     //��������·��
  gSysParam:TSysParam;                               //���򻷾�����
  gDBPram: TDBParam;                                 //���ݿ����
  gStatusBar: TdxStatusBar;                          //ȫ��ʹ��״̬��

//------------------------------------------------------------------------------
ResourceString
  sProgID             = 'TruckCtrl';                 //Ĭ�ϱ�ʶ
  sAppTitle           = '�ƶ����';                  //�������
  sMainCaption        = '���𹲺� - �ƶ����';       //�����ڱ���
  sAutoStartKey       = 'SR_TruckCtrl';              //��������ֵ

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

  sStyleConfig        = 'Style.ini';                 //�������
  sStyleDevList       = 'DeviceList';                //�豸�б�
  
  sExportExt          = '.txt';                      //����Ĭ����չ��
  sExportFilter       = '�ı�(*.txt)|*.txt|�����ļ�(*.*)|*.*';
                                                     //������������ 

  sInvalidConfig      = '�����ļ���Ч���Ѿ���';    //�����ļ���Ч
  sCloseQuery         = 'ȷ��Ҫ�˳�������?';         //�������˳�

procedure InitSystemEnvironment;
//��ʼ��ϵͳ���л����ı���
procedure ActionSysParameter(const nIsRead: Boolean);
//��дϵͳ���ò���
procedure ActionDBConfig(const nIsRead: Boolean);
//��д���ݿ�����
function CheckDBConnection(const nHint: Boolean = True): Boolean;

procedure ShowMsgOnLastPanelOfStatusBar(const nMsg: string);
procedure StatusBarMsg(const nMsg: string; const nIdx: integer);
//��״̬����ʾ��Ϣ

implementation

//Desc: ��ʼ�����л���
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
        FProgID     := sProgID;
        FAppTitle   := sAppTitle;
        FMainTitle  := sMainCaption;

        FAutoStart := nReg.ValueExists(sAutoStartKey);
        FAutoMin := ReadBool('System', 'AutoMin', False);
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

//Desc: ��д���ݿ����ò���
procedure ActionDBConfig(const nIsRead: Boolean);
var nStr: string;
    nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sConfigFile);
  with nIni,gDBPram do
  try
    nStr := ReadString('DBConfig', 'Active', '0');
    //active index
    
    if nIsRead then
    begin
      FID   := sProgID;
      FHost := ReadString('DBConfig', 'Host_' + nStr, '');
      FPort := ReadInteger('DBConfig', 'Port_' + nStr, 1433);
      FDB   := ReadString('DBConfig', 'DB_' + nStr, '');
      FUser := ReadString('DBConfig', 'User_' + nStr, '');
      FPwd  := DecodeBase64(ReadString('DBConfig', 'Password_' + nStr, ''));
      FConn := DecodeBase64(ReadString('DBConfig', 'ConnStr_' + nStr, ''));

      FEnable    := True;
      FNumWorker := 10;
    end else
    begin
      WriteString('DBConfig', 'Host_' + nStr, FHost);
      WriteInteger('DBConfig', 'Port_' + nStr, FPort);
      WriteString('DBConfig', 'DB_' + nStr, FDB);
      WriteString('DBConfig', 'User_' + nStr, FUser);
      WriteString('DBConfig', 'Password_' + nStr, EncodeBase64(FPwd));
      WriteString('DBConfig', 'ConnStr_' + nStr, EncodeBase64(FConn));
    end;
  finally
    nIni.Free;
  end;   
end;

//Date: 2013-3-11
//Parm: �Ƿ���ʾ
//Desc: ������������Ƿ�����
function CheckDBConnection(const nHint: Boolean): Boolean;
begin
  with FDM.ADOConn do
  begin
    Result := Connected;
    if Result then Exit;

    if gDBPram.FHost = '' then
    begin
      if nHint then
        ShowMsg('���������ݿ�', sHint);
      Exit;
    end;

    if nHint then
    begin
      ShowWaitForm(Application.MainForm, '�������ݿ�');
      Sleep(1200);
    end;

    try
      ConnectionString := gDBConnManager.MakeDBConnection(gDBPram);
      Connected := True;
      Result := Connected;

      if Result then
        FDM.AdjustAllSystemTables;
      //create new table
    except
      if nHint then
        ShowMsg('�������ݿ�ʧ��', sHint);
      Result := False;
    end;

    if nHint then
      CloseWaitForm;
    //xxxxx
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


