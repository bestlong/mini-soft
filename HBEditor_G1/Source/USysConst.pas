{*******************************************************************************
  ����: dmzn@163.com 2010-9-2
  ����: ϵͳ��������
*******************************************************************************}
unit USysConst;

interface

uses
  Windows, Classes, Forms, Graphics, dxStatusBar, SysUtils, UMgrLang;

type
  TDynamicByteArray = array of Byte;
  TByteData = array[0..7] of Byte;

  TByteInt = record
    FB1,FB2,FB3,FB4: Byte;
  end;

const
  cByteMask: TByteData = (128, 64, 32, 16, 8, 4, 2, 1);

//------------------------------------------------------------------------------
type
  TCodeText = record
    FCode: string;        //����
    FText: string;        //����
  end;

const
  cEnterMode: array[0..14] of TCodeText = ((FCode:'00';FText:'ֱ����ʾ'),
              (FCode:'01';FText:'��˸����'), (FCode:'02';FText:'��������'),
              (FCode:'03';FText:'��������'), (FCode:'04';FText:'����չ��'),
              (FCode:'05';FText:'����չ��'), (FCode:'06';FText:'���������м�'),
              (FCode:'07';FText:'���м�������'), (FCode:'08';FText:'��������'),
              (FCode:'09';FText:'����չ��'), (FCode:'0a';FText:'����չ��'),
              (FCode:'0b';FText:'���������м�'), (FCode:'0c';FText:'���м�������'),
              (FCode:'0d';FText:'ˮƽ��Ҷ��'), (FCode:'0e';FText:'��ֱ��Ҷ��'));

  cExitMode: array[0..14] of TCodeText = ((FCode:'00';FText:'ֱ������'),
              (FCode:'01';FText:'��˸����'), (FCode:'02';FText:'�����Ƴ�'),
              (FCode:'03';FText:'�����Ƴ�'), (FCode:'04';FText:'���Ҳ���'),
              (FCode:'05';FText:'�������'), (FCode:'06';FText:'���������м�'),
              (FCode:'07';FText:'���м�������'), (FCode:'08' ;FText:'�����Ƴ�'),
              (FCode:'09';FText:'���ϲ���'), (FCode:'0a';FText:'���²���'),
              (FCode:'0b';FText:'���������м�'), (FCode:'0c';FText:'���м�������'),
              (FCode:'0d';FText:'ˮƽ��Ҷ��'), (FCode:'0e';FText:'��ֱ��Ҷ��'));

  cTimeChar: array[0..1] of TCodeText = ((FCode:'00';FText:'����'),
             (FCode:'01';FText:'�ַ�'));
  //ʱ�Ӹ�ʽ
  cDispMode: array[0..1] of TCodeText = ((FCode:'00';FText:'�̶���ʾ'),
             (FCode:'01';FText:'����ģʽ'));
  //��ʾģʽ
  cDispPos: array[0..8] of TCodeText = ((FCode:'00';FText:'�϶˾���'),
            (FCode:'01';FText:'�϶˾���'), (FCode:'02';FText:'�϶˾���'),
            (FCode:'03';FText:'�м����'), (FCode:'04';FText:'�м����'),
            (FCode:'05';FText:'�м����'), (FCode:'06';FText:'�¶˾���'),
            (FCode:'07';FText:'�¶˾���'), (FCode:'08';FText:'�¶˾���'));
  //��ʾλ��

//------------------------------------------------------------------------------
const
  cSendInterval_Long = 4200;
  cSendInterval_Short = 1000; //���ͳ�ʱ�ȴ�

  cItemColorList: array[0..2] of TColor = (clRed, clGreen, clYellow);
  //��ɫ�б�

//------------------------------------------------------------------------------
type
  TSysParam = record
    FAppTitle: string;                            //�������
    FMainTitle: string;                           //������
    FCopyLeft: string;                            //״̬��.��Ȩ
    FCopyRight: string;                           //����.��Ȩ

    FIsAdmin: Boolean;                            //����Ա��¼
    FCOMMPort: string;                            //���Ӷ˿�
    FCOMMBote: Integer;                           //���䲨����

    FScreenWidth: Integer;
    FScreenHeight: Integer;                       //��Ļ���

    FEnableClock: Boolean;
    FClockChar: string;
    FClockMode: string;
    FClockPos: string;
    FClockYear: string;
    FClockMonth: string;
    FClockDay: string;
    FClockWeek: string;
    FClockTime: string;                           //ʱ�Ӳ���
    FClockSYear: string;
    FClockSMonth: string;
    FClockSDay: string;
    FClockSHour: string;
    FClockSMin: string;
    FClockSSec: string;
    FClockSWeek: string;                          //ʱ������

    FEnablePD: Boolean;
    FPlayDays: string;                            //��������
  end;

var
  gPath: string;                                  //��������·��
  gSysParam: TSysParam;                           //ϵͳ����

  gIsSending: Boolean = False;                    //����״̬
  gSendInterval: Word = cSendInterval_Short;      //���ͳ�ʱ
  gStatusBar: TdxStatusBar;                       //ȫ��ʹ��״̬��

  //xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  sHint: string;                      //�����Գ���
  sAsk: string;
  sWarn: string;
  sError: string;

//------------------------------------------------------------------------------
procedure SetRStringMultiLang;
//����������
procedure FillColorList(const nList: TStrings);
//�����ɫ
function GetColorIndex(const nList: TStrings; const nColor: TColor): Integer;
//������ɫ
procedure ShowMsgOnLastPanelOfStatusBar(const nMsg: string);
procedure StatusBarMsg(const nMsg: string; const nIdx: integer);
//��״̬����ʾ��Ϣ

resourcestring
  sProgID           = 'HBEdit';                   //�����ʾ
  sAppTitle         = '�������';                 //������
  sMainTitle        = 'ͼ�ı༭��';               //������

  sConfigFile       = 'Config.ini';               //������
  sFormConfig       = 'Forms.ini';                //��������
  sBackImage        = 'bg.bmp';                   //����

  {*���Ա��*}
  sMLMain           = 'fFormMain';
  sMLCommon         = 'Common';

  {*Ĭ�ϱ���*}
  rsHint            = '��ʾ';
  rsAsk             = 'ѯ��';
  rsWarn            = '����';
  rsError           = '����';

  sCorConcept       = '��.�Ƽ����� �������� ��Ϸ��� ����δ��';
                                                  //��ҵ����

  sCopyRight        = '��.��Ȩ����: �������';    //��Ȩ����
  sInvalidConfig    = '�����ļ���Ч���Ѿ���';   //�����ļ���Ч
  
implementation

//Desc: �����ַ�������
procedure SetRStringMultiLang;
begin
  sHint := ML(rsHint, sMLCommon);
  sAsk := ML(rsAsk);
  sWarn := ML(rsWarn);
  sError := ML(rsError);
end;

//Desc: ��cItemColorList����ɫ��䵽nList��
procedure FillColorList(const nList: TStrings);
var nIdx: integer;
begin
  nList.Clear;
  for nIdx:=Low(cItemColorList) to High(cItemColorList) do
  begin
    nList.AddObject(IntToStr(nIdx), TObject(cItemColorList[nIdx]))
  end;
end;

//Desc: ����nColor��nList�е�����
function GetColorIndex(const nList: TStrings; const nColor: TColor): Integer;
var i: integer;
begin
  Result := -1;
  for i:=nList.Count - 1 downto 0 do
   if nList.Objects[i] = TObject(nColor) then
   begin
     Result := i; Break;
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
