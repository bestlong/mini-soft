{*******************************************************************************
  ����: dmzn@ylsoft.com 2007-10-09
  ����: ��Ŀͨ�ó�,�������嵥Ԫ
*******************************************************************************}
unit USysConst;

interface

uses
  ComCtrls;

const
  cSBar_Date            = 0;                         //�����������
  cSBar_Time            = 1;                         //ʱ���������

type
  TSysParam = record
    FProgID     : string;                            //�����ʶ
    FAppTitle   : string;                            //�����������ʾ
    FMainTitle  : string;                            //���������
    FHintText   : string;                            //��������ʾ����
    FCopyRight  : string;                            //�����Ȩ

    FUserID     : string;                            //�û����
    FUserName   : string;                            //�û���
    FUserPwd    : string;                            //�û�����

    FTableMenu  : string;                            //�˵���
    FTableUser  : string;                            //�û���
    FTableGroup : string;                            //Ȩ����
    FTablePopedom: string;                           //Ȩ�ޱ�
    FTablePopItem: string;                           //Ȩ����
  end;
  
//------------------------------------------------------------------------------
var
  gPath: string;                                     //��������·��
  gSysParam:TSysParam;                               //���򻷾�����
  gStatusBar: TStatusBar;                            //ȫ��ʹ��״̬��

//------------------------------------------------------------------------------
ResourceString
  sProgID             = 'EPOP';                      //Ĭ�ϱ�ʶ
  sAppTitle           = 'Ȩ�ޱ༭��';                //�������
  sMainCaption        = 'Ȩ�ޱ༭��';                //�����ڱ���

  sHint               = '��ʾ';                      //�Ի������
  sAsk                = 'ѯ��';                      //ѯ�ʶԻ���
  sWarn               = '����';                      //����Ի���

  sDate               = '����:��%s��';               //����������
  sTime               = 'ʱ��:��%s��';               //������ʱ��

  sLogoFile           = 'Logo.bmp';                  //��¼Logo
  sDBConnFile         = 'DBConn.ini';                //���ݿ�����             

  sConfigFile         = 'Config.Ini';                //�������ļ�
  sConfigSec          = 'Config';                    //������С��
  sVerifyCode         = ';Verify:';                  //У������

  sFormConfig         = 'FormInfo.ini';              //��������
  sSetupSec           = 'Setup';                     //����С��

  sInvalidConfig      = '�����ļ���Ч���Ѿ���';    //�����ļ���Ч
  sCloseQuery         = 'ȷ��Ҫ�˳�������?';         //�������˳�

  sTableSec           = 'DBTable';                   //���ݿ�С��
  sTable_Menu         = 'Sys_Menu';
  sTable_User         = 'Sys_User';
  sTable_Group        = 'Sys_Group';
  sTable_Popedom      = 'Sys_Popedom';
  sTable_PopItem      = 'Sys_PopItem';               //������

implementation

end.


