{*******************************************************************************
  ����: dmzn@163.com 2010-7-20
  ����: ��������
*******************************************************************************}
unit ULibConst;

interface

uses Graphics;

const
  cSendInterval_Long = 4200;
  cSendInterval_Short = 1000; //���ͳ�ʱ�ȴ�

//------------------------------------------------------------------------------  
type
  TDynamicByteArray = array of Byte;
  TByteData = array[0..7] of Byte;

  TByteInt = record
    FB1,FB2,FB3,FB4: Byte;
  end;

const
  cByteMask: TByteData = (128, 64, 32, 16, 8, 4, 2, 1);

type
  TDynamicBitmapArray = array of TBitmap;
  //ͼƬ����

  PAreaRect = ^TAreaRect;
  TAreaRect = record
    FLeft: Word;
    FTop: Word;
    FWidth: Word;
    FHeight: Word;
  end; //�������

  PAreaMode = ^TAreaMode;
  TAreaMode = record
    FEnterMode: Byte;
    FEnterSpeed: Byte;
    FKeepTime: Byte;
    FExitMode: Byte;
    FExitSpeed: Byte;
    FModeSerial: Byte;
    FSingleColor: Byte;
  end; //������Ч

  PAreaFont = ^TAreaFont;
  TAreaFont = record
    FName: array[0..31] of Char;
    FSize: Word;
  end; //����
  
var
  gSendInterval: Word = cSendInterval_Short; //���ͳ�ʱ

implementation

end.
