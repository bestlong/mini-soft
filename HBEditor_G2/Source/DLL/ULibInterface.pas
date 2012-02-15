{*******************************************************************************
  ����: dmzn@163.com 2010-7-20
  ����: �⺯���ӿ�
*******************************************************************************}
unit ULibInterface;

interface

uses
  Windows, Classes, ULibConst;

const
  cLibDLL = 'HBLibrary.dll';

procedure CommPortInit(const nComm: PChar; const nBaudRate: DWORD); stdcall; external cLibDLL;
//��ʼ���˿�
function CommPortConn: Boolean; stdcall; external cLibDLL;
function CommPortClose: Boolean; stdcall; external cLibDLL;
//���Ӻ͹ر�

procedure TransInit(const nCardType,nAreaNum,nInvert: Byte); stdcall; external cLibDLL;
//�����ʼ��
function TransBegin(const nMsg: PChar): Boolean; stdcall; external cLibDLL;
//���俪ʼ
function TransData(const nRect: PAreaRect; const nMode: PAreaMode;
 const nFont: PAreaFont; const nText,nMsg: PChar): Boolean; stdcall; external cLibDLL;
//��������
function TransEnd(const nMsg: PChar): Boolean; stdcall; external cLibDLL;
//�������

implementation

end.
