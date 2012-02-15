{*******************************************************************************
  ����: dmzn 2009-2-6
  ����: ���ó���,�������嵥Ԫ
*******************************************************************************}
unit USysConst;

{$I link.inc}
interface

uses
  Windows, Classes, Controls, ComCtrls, Graphics, StdCtrls, SysUtils, Forms,
  IniFiles, UTitleBar, UMovedControl;

const
  cImgScreen    = 4;   //��Ļͼ��
  cImgMovie     = 5;   //��Ŀͼ��
  cImgText      = 6;   //�ı�ͼ��
  cImgPicture   = 7;   //ͼ��ͼ��
  cImgClock     = 9;   //ʱ��ͼ��
  cImgTime      = 10;  //ʱ��ͼ��

  cItemColorList: array[0..2] of TColor = (clRed, clGreen, clYellow);
  //��ɫ�б�

//------------------------------------------------------------------------------  
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
  TCardAreaType = (atText, atPic, atAnimate, atClock, atTime);
  //����������

  TCardForbid = set of TCardAreaType;
  //��֧����������

  TCardItem = record
    FCard: Byte;             //����
    FName: string;           //����
    FLimite: Byte;           //��������
    FForbid: TCardForbid;    //��֧������
  end;

const
  cCardList: array[0..6] of TCardItem = (
       (FCard: 0;FName: 'HB-F0'; FLimite: 3; FForbid: [atAnimate, atClock]),
       (FCard: 1;FName: 'HB-F1'; FLimite: 3; FForbid: [atAnimate]),
       (FCard: 2;FName: 'HB-F2'; FLimite: 3; FForbid: [atAnimate]),
       (FCard: 3;FName: 'HB-F3'; FLimite: 6; FForbid: []),
       (FCard: 4;FName: 'HB-F4'; FLimite: 8; FForbid: []),
       (FCard: 5;FName: 'HB-F5'; FLimite: 10; FForbid: []),
       (FCard: 6;FName: 'HB-F6'; FLimite: 16; FForbid: []));
  //������

type
  TConnType = (ctComm, ctGPRS, ctNet);
  //ͨ��ģʽ

  TConnItem = record
    FType: TConnType;
    FName: string;
  end;

const
  cConnList: array[0..2] of TConnItem = (
             (FType: ctComm; FName: '����ͨ��(Ĭ��)'),
             (FType: ctGPRS; FName: 'GPRSͨ��'),
             (FType: ctNet; FName: '����ͨѶ'));
  //ͨ������

//------------------------------------------------------------------------------
type
  TEffectMode = record
    FMode: Byte;
    FText: string;
  end;

const
  cEnterMode: array[0..22] of TEffectMode = ((FMode:0 ;FText: 'ֱ����ʾ'),
              (FMode:1 ;FText: '��˸����'), (FMode:2 ;FText: '��������'),
              (FMode:3 ;FText: '��������'), (FMode:4 ;FText: '����չ��'),
              (FMode:5 ;FText: '����չ��'), (FMode:6 ;FText: '���������м�'),
              (FMode:7 ;FText: '���м�������'), (FMode:8 ;FText: '��������'),
              (FMode:9 ;FText: '����չ��'), (FMode:10 ;FText: '����չ��'),
              (FMode:11 ;FText: '���������м�'), (FMode:12 ;FText: '���м�������'),
              (FMode:13 ;FText: 'ˮƽ��Ҷ��'), (FMode:14 ;FText: '��ֱ��Ҷ��'),

              (FMode:15 ;FText: '���Ͻǲ���'), (FMode:16 ;FText: '���Ͻǲ���'),
              (FMode:17 ;FText: '���½���Խ�'), (FMode:18 ;FText: '���ҽ����չ'),
              (FMode:19 ;FText: '������˸'), (FMode:20 ;FText: 'б����չ��'),
              (FMode:21 ;FText: '����չ��'), (FMode:22 ;FText: '����'));

  cExitMode: array[0..22] of TEffectMode = ((FMode:0 ;FText: 'ֱ������'),
              (FMode:1 ;FText: '��˸����'), (FMode:2 ;FText: '�����Ƴ�'),
              (FMode:3 ;FText: '�����Ƴ�'), (FMode:4 ;FText: '���Ҳ���'),
              (FMode:5 ;FText: '�������'), (FMode:6 ;FText: '���������м�'),
              (FMode:7 ;FText: '���м�������'), (FMode:8 ;FText: '�����Ƴ�'),
              (FMode:9 ;FText: '���ϲ���'), (FMode:10 ;FText: '���²���'),
              (FMode:11 ;FText: '���������м�'), (FMode:12 ;FText: '���м�������'),
              (FMode:13 ;FText: 'ˮƽ��Ҷ��'), (FMode:14 ;FText: '��ֱ��Ҷ��'),

              (FMode:15 ;FText: '���½��˳�'), (FMode:16 ;FText: '���½��˳�'),
              (FMode:17 ;FText: '���½������'), (FMode:18 ;FText: '���ҽ������'),
              (FMode:19 ;FText: '������˸�˳�'), (FMode:20 ;FText: 'б�����˳�'),
              (FMode:21 ;FText: '�����˳�'), (FMode:22 ;FText: '����'));

//------------------------------------------------------------------------------
type
  TDeviceItem = record
    FID: integer;
    FName: string;
  end;

  TScreenType = (stSingle, stDouble, stFull);

  PScreenItem = ^TScreenItem;
  TScreenItem = record
    FID: integer;
    FName: string;
    FCard: Byte;
    FLenX: Word;
    FLenY: Word;
    FType: TScreenType;
    FPort: string;
    FBote: Integer;
    FDevice: array of TDeviceItem;
  end;

type
  PMovedItemData = ^TMovedItemData;
  TMovedItemData = record
    FItem: TZnMovedControl;  //���
    FPosX: integer;
    FPosY: integer;          //���Ͻ�����
    FWidth: integer;
    FHeight: integer;        //���
    FLevel: Byte;            //���ȼ�
    FTypeIdx: Byte;          //������
  end;
  
  PBitmapDataItem = ^TBitmapDataItem;
  TBitmapDataItem = record
    FBitmap: TBitmap;
    //ͼƬ����
    FModeEnter: Byte;
    FModeExit: Byte;
    //������ģʽ
    FSpeedEnter: Byte;
    FSpeedExit: Byte;
    //�������ٶ�
    FKeedTime: Byte;
    FModeSerial: Byte;
    //ͣ��ʱ��,����ǰ��
  end;

  TDynamicBitmapArray = array of TBitmap;
  //ͼƬ����
  TDynamicBitmapDataArray = array of TBitmapDataItem;
  //ͼƬ��������

const
  cSendInterval_Long = 4200;
  cSendInterval_Short = 1000; //���ͳ�ʱ�ȴ�

//------------------------------------------------------------------------------
type
  TSysParam = record
    FAppTitle: string;                            //�������
    FMainTitle: string;                           //������
    FCopyLeft: string;                            //״̬��.��Ȩ
    FCopyRight: string;                           //����.��Ȩ
  end;

var
  gPath: string;                                  //��������·��
  gSysParam: TSysParam;                           //ϵͳ����

  gScreenList: TList;                             //���б�
  gSendInterval: Word = cSendInterval_Short;      //���ͳ�ʱ
  gIsFullColor: Boolean;                          //�Ƿ�ȫ��
  gStatusBar: TStatusBar;                         //ȫ��ʹ��״̬��

  //xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  sHint: string;
  sAsk: string;
  sError: string;

  sCaptionScreen: string;
  sCaptionMovie: string;
  sCaptionText: string;
  sCaptionPicture: string;
  sCaptionAnimate: string;
  sCaptionTime: string;
  sCaptionClock: string;                          //ȫ���ַ�����
  
//------------------------------------------------------------------------------
procedure SetRStringMultiLang;
//����������
procedure SetTitleBarStatus(const nCtrl: TWinControl; const nActive: Boolean);
//���ñ�����״̬
procedure FillColorCombox(const nCombox: TComboBox);
//�����ɫ
procedure SetColorComboxIndex(const nCombox: TComboBox; const nColor: TColor);
//������ɫ
function CardItemIndex(const nCard: Byte): Integer;
//��ȡ������
procedure ClearMovedItemDataList(const nList: TList; const nFree: Boolean);
//����ؼ��б�
procedure ShowMsgOnLastPanelOfStatusBar(const nMsg: string);
procedure StatusBarMsg(const nMsg: string; const nIdx: integer);
//��״̬����ʾ��Ϣ

ResourceString
  sProgID           = 'HBEdit';                   //�����ʾ
  sAppTitle         = '�������';                 //������
  sMainTitle        = 'ͼ�ı༭��';               //������

  sConfigFile       = 'Config.ini';               //������
  sFormConfig       = 'Forms.ini';                //��������
  sScreenConfig     = 'Screen.ini';               //��Ļ����
  sBackImage        = 'bg.bmp';                   //����
  sDocument         = 'Document\';                //�ı�Ŀ¼

  sCorConcept       = '��.�Ƽ����� �������� ��Ϸ��� ����δ��';
                                                  //��ҵ����
  {$IFDEF mhkj}
  sCopyRight        = '��.��Ȩ����: ħ�ÿƼ�';
  {$ELSE}
  sCopyRight        = '��.��Ȩ����: �������';
  {$ENDIF}

  sInvalidConfig    = '�����ļ���Ч���Ѿ���';   //�����ļ���Ч

  sMLCommon         = 'Common';                   //�����Թ�����
  sMLFrame          = 'FrameItem';                //�����Ա༭��
  sMLMain           = 'fFormMain';                //������������
  sMLSend           = 'fFormSendData';            //�����Է���
  sMLTxtEdt         = 'fFormTextEditor';          //�����Ը��ı�

implementation

uses UMgrLang;

resourcestring
  {$IFDEF en}
  rsHint             = 'hint';
  rsAsk              = 'ask';
  rsError            = 'error';

  rsCaptionScreen    = '%d-Screen';                //��Ļ����
  rsCaptionMovie     = 'Programm-%d';              //��Ŀ����
  rsCaptionText      = 'Text-%d';                  //��Ļ����
  rsCaptionPicture   = 'Pic&Txt-%d';               //ͼ�ı���
  rsCaptionAnimate   = 'Animate-%d';               //ͼ�ı���
  rsCaptionTime      = 'Time-%d';                  //ʱ�����
  rsCaptionClock     = 'Clock-%d';                 //ʱ�����
  {$ELSE}
  rsHint             = '��ʾ';
  rsAsk              = 'ѯ��';
  rsError            = 'δ֪';

  rsCaptionScreen    = '%d-��ʾ��';                //��Ļ����
  rsCaptionMovie     = '��Ŀ-%d';                  //��Ŀ����
  rsCaptionText      = '��Ļ-%d';                  //��Ļ����
  rsCaptionPicture   = 'ͼ��-%d';                  //ͼ�ı���
  rsCaptionAnimate   = '����-%d';                  //ͼ�ı���
  rsCaptionTime      = 'ʱ��-%d';                  //ʱ�����
  rsCaptionClock     = 'ʱ��-%d';                  //ʱ�����
  {$ENDIF}

procedure SetRStringMultiLang;
begin
  sHint := ML(rsHint, sMLCommon);
  sAsk := ML(rsAsk);
  sError := ML(rsError);

  sCaptionScreen := ML(rsCaptionScreen);
  sCaptionMovie := ML(rsCaptionMovie);
  sCaptionText := ML(rsCaptionText);
  sCaptionPicture := ML(rsCaptionPicture);
  sCaptionAnimate := ML(rsCaptionAnimate);
  sCaptionTime := ML(rsCaptionTime);
  sCaptionClock := ML(rsCaptionClock);
end;

//------------------------------------------------------------------------------
//Desc: ��cItemColorList����ɫ��䵽nCombox��
procedure FillColorCombox(const nCombox: TComboBox);
var nIdx: integer;
begin
  nCombox.Clear;
  for nIdx:=Low(cItemColorList) to High(cItemColorList) do
  begin
    nCombox.Items.AddObject(IntToStr(nIdx), TObject(cItemColorList[nIdx]))
  end;
end;

//Desc: ����nCombox����ɫֵΪnColor
procedure SetColorComboxIndex(const nCombox: TComboBox; const nColor: TColor);
var i: integer;
begin
  nCombox.ItemIndex := -1;
  for i:=nCombox.Items.Count - 1 downto 0 do
   if nCombox.Items.Objects[i] = TObject(nColor) then
   begin
     nCombox.ItemIndex := i; Break;
   end;
end;

//Desc: ����nCtrl�ϱ�������״̬
procedure SetTitleBarStatus(const nCtrl: TWinControl; const nActive: Boolean);
var i,nCount: integer;
begin
  nCount := nCtrl.ControlCount - 1;
  for i:=0 to nCount do
   if nCtrl.Controls[i] is TZnTitleBar then
     TZnTitleBar(nCtrl.Controls[i]).Active := nActive;
end;

//Desc: ��ȡnCard�ڿ��б������
function CardItemIndex(const nCard: Byte): Integer;
begin
  for Result:=Low(cCardList) to High(cCardList) do
   if cCardList[Result].FCard = nCard then Exit;
  Result := -1;
end;

//Desc: ����nList�ؼ��б�
procedure ClearMovedItemDataList(const nList: TList; const nFree: Boolean);
var nIdx: integer;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    Dispose(PMovedItemData(nList[nIdx]));
    nList.Delete(nIdx);
  end;

  if nFree then nList.Free;
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
