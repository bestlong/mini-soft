{*******************************************************************************
  ����: dmzn@ylsoft.com 2007-10-09
  ����: ��Ŀͨ�ó�,�������嵥Ԫ
*******************************************************************************}
unit USysConst;

interface

uses
  SysUtils, Classes, ComCtrls;

const
  cSBar_Date            = 0;                         //�����������
  cSBar_Time            = 1;                         //ʱ���������
  cSBar_User            = 2;                         //�û��������
  cRecMenuMax           = 5;                         //���ʹ�õ����������Ŀ��
  cPrecision            = 100;                       //��������
  
const
  {*Frame ID*}
  cFI_FrameSysLog       = $0001;                     //ϵͳ��־
  cFI_FrameViewLog      = $0002;                     //������־
  cFI_FrameUnit         = $0010;                     //���ʹ��
  cFI_FrameDepartment   = $0011;                     //���ŵ�λ
  cFI_FrameStorage      = $0012;                     //�ֿ��λ
  cFI_FrameProvider     = $0013;                     //��Ӧ����
  cFI_FrameGoodsType    = $0014;                     //��Ʒ����
  cFI_FrameGoods        = $0015;                     //Ʒ������
  cFI_FrameWeeks        = $0016;                     //�ɹ�����
  cFI_FramePlan         = $0017;                     //�ɹ��ƻ�
  cFI_FrameRYuanLiao    = $0020;                     //ԭ�����
  cFI_FrameRBeiPin      = $0021;                     //��Ʒ���
  cFI_FrameChuKu        = $0022;                     //��Ʒ����

  cFI_FrameQBuyPlan     = $0030;                     //�ɹ�����
  cFI_FrameQKuCun       = $0031;                     //��汨��

  cFI_FormBackup        = $1001;                     //���ݱ���
  cFI_FormRestore       = $1002;                     //���ݻָ�
  cFI_FormIncInfo       = $1003;                     //��˾��Ϣ
  cFI_FormChangePwd     = $1005;                     //�޸�����
  cFI_FormBaseInfo      = $1006;                     //������Ϣ

  cFI_FormUnit          = $1010;                     //������
  cFI_FormDepartment    = $1011;                     //���ŵ�λ
  cFI_FormStorage       = $1012;                     //�ֿ��λ
  cFI_FormProvider      = $1013;                     //��Ӧ����
  cFI_FormGoodsType     = $1014;                     //��Ʒ����
  cFI_FormGoods         = $1015;                     //Ʒ������
  cFI_FormWeeks         = $1016;                     //�ɹ�����
  cFI_FormGetWeek       = $1017;                     //ɸѡ����
  cFI_FormBuyReq        = $1018;                     //�ɹ�����
  cFI_FormBuyPlan       = $1019;                     //�ɹ��ƻ�

  cFI_FormRYuanLiao     = $1020;                     //ԭ�����
  cFI_FormRBeiPin       = $1021;                     //��Ʒ���
  cFI_FormChuKu         = $1022;                     //��Ʒ����

  {*Command*}
  cCmd_RefreshData      = $0002;                     //ˢ������
  cCmd_ViewSysLog       = $0003;                     //ϵͳ��־

  cCmd_ModalResult      = $1001;                     //Modal����
  cCmd_FormClose        = $1002;                     //�رմ���
  cCmd_AddData          = $1003;                     //�������
  cCmd_EditData         = $1005;                     //�޸�����
  cCmd_ViewData         = $1006;                     //�鿴����
  cCmd_GetData          = $1007;                     //ѡ������

type
  TSysParam = record
    FProgID     : string;                            //�����ʶ
    FAppTitle   : string;                            //�����������ʾ
    FMainTitle  : string;                            //���������
    FHintText   : string;                            //��ʾ�ı�
    FCopyRight  : string;                            //��������ʾ����

    FUserID     : string;                            //�û���ʶ
    FUserName   : string;                            //��ǰ�û�
    FUserPwd    : string;                            //�û�����
    FGroupID    : string;                            //������
    FIsAdmin    : Boolean;                           //�Ƿ����Ա
    FIsNormal   : Boolean;                           //�ʻ��Ƿ�����

    FRecMenuMax : integer;                           //����������
    FIconFile   : string;                            //ͼ�������ļ�
  end;
  //ϵͳ����

  TModuleItemType = (mtFrame, mtForm);
  //ģ������

  PMenuModuleItem = ^TMenuModuleItem;
  TMenuModuleItem = record
    FMenuID: string;                                 //�˵�����
    FModule: integer;                                //ģ���ʶ
    FItemType: TModuleItemType;                      //ģ������
  end;

//------------------------------------------------------------------------------
var
  gPath: string;                                     //��������·��
  gSysParam:TSysParam;                               //���򻷾�����
  gStatusBar: TStatusBar;                            //ȫ��ʹ��״̬��
  gMenuModule: TList = nil;                          //�˵�ģ��ӳ���

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

//------------------------------------------------------------------------------
//Desc: ��Ӳ˵�ģ��ӳ����
procedure AddMenuModuleItem(const nMenu: string; const nModule: Integer;
 const nType: TModuleItemType = mtFrame);
var nItem: PMenuModuleItem;
begin
  New(nItem);
  gMenuModule.Add(nItem);

  nItem.FMenuID := nMenu;
  nItem.FModule := nModule;
  nItem.FItemType := nType;
end;

//Desc: �˵�ģ��ӳ���
procedure InitMenuModuleList;
begin
  gMenuModule := TList.Create;

  AddMenuModuleItem('MAIN_A01', cFI_FormIncInfo, mtForm);
  AddMenuModuleItem('MAIN_A02', cFI_FrameSysLog);
  AddMenuModuleItem('MAIN_A03', cFI_FormBackup, mtForm);
  AddMenuModuleItem('MAIN_A04', cFI_FormRestore, mtForm);
  AddMenuModuleItem('MAIN_A05', cFI_FormChangePwd, mtForm);

  AddMenuModuleItem('MAIN_B01', cFI_FrameUnit);
  AddMenuModuleItem('MAIN_B02', cFI_FrameDepartment);
  AddMenuModuleItem('MAIN_B03', cFI_FrameStorage);
  AddMenuModuleItem('MAIN_B04', cFI_FrameProvider);
  AddMenuModuleItem('MAIN_B05', cFI_FormBaseInfo, mtForm);
  AddMenuModuleItem('MAIN_B06', cFI_FrameGoods);

  AddMenuModuleItem('MAIN_C01', cFI_FramePlan);
  AddMenuModuleItem('MAIN_C02', cFI_FrameRYuanLiao);
  AddMenuModuleItem('MAIN_C03', cFI_FrameRBeiPin);
  AddMenuModuleItem('MAIN_C05', cFI_FrameWeeks);

  AddMenuModuleItem('MAIN_D01', cFI_FormChuKu, mtForm);
  AddMenuModuleItem('MAIN_D02', cFI_FrameChuKu);

  AddMenuModuleItem('MAIN_E01', cFI_FrameQBuyPlan);
  AddMenuModuleItem('MAIN_E02', cFI_FrameQKuCun);
end;

//Desc: ����ģ���б�
procedure ClearMenuModuleList;
var nIdx: integer;
begin
  for nIdx:=gMenuModule.Count - 1 downto 0 do
  begin
    Dispose(PMenuModuleItem(gMenuModule[nIdx]));
    gMenuModule.Delete(nIdx);
  end;

  FreeAndNil(gMenuModule);
end;

initialization
  InitMenuModuleList;
finalization
  ClearMenuModuleList;
end.


