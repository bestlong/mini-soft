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

    FUserID     : string;                            //�û����
    FUserName   : string;                            //�û���
    FUserPwd    : string;                            //�û�����

    FTableEntity: string;                            //ʵ���
    FTableDict  : string;                            //�ֵ����
  end;
  
//------------------------------------------------------------------------------
var
  gPath: string;                                     //��������·��
  gSysParam:TSysParam;                               //���򻷾�����
  gStatusBar: TStatusBar;                            //ȫ��ʹ��״̬��

//------------------------------------------------------------------------------
ResourceString
  sProgID             = 'MKF';                       //Ĭ�ϱ�ʶ
  sAppTitle           = 'Ȩ�ޱ༭��';                //�������
  sMainCaption        = 'Ȩ�ޱ༭��';                //�����ڱ���

  sHint               = '��ʾ';                      //�Ի������
  sAsk                = 'ѯ��';                      //ѯ�ʶԻ���
  sWarn               = '����';                      //����Ի���

  sDate               = '����:��%s��';               //����������
  sTime               = 'ʱ��:��%s��';               //������ʱ��

  sConfigFile         = 'Config.Ini';                //�������ļ�
  sConfigSec          = 'Config';                    //������С��
  sVerifyCode         = ';Verify:';                  //У������

  sFormConfig         = 'FormInfo.ini';              //��������
  sSetupSec           = 'Setup';                     //����С��
  sDBConfig           = 'DBConn.ini';                //���ݿ�����

  sInvalidConfig      = '�����ļ���Ч���Ѿ���';    //�����ļ���Ч
  sCloseQuery         = 'ȷ��Ҫ�˳�������?';         //�������˳�

  sTableSec           = 'DBTable';                   //���ݿ�С��
  sTable_Entity       = 'Sys_Entity';
  sTable_Dict         = 'Sys_DataDict';              //������

implementation

end.


