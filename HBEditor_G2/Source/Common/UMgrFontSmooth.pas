{*******************************************************************************
  ����: dmzn@163.com 2010-06-25
  ����: ����/�ر�ϵͳ"ƽ�������Ե"����
*******************************************************************************}
unit UMgrFontSmooth;

interface

uses
  Windows, Classes, Messages, Registry, SysUtils;

type
  TSmoothFontSwitch = class
  private
    FInitSmooth: Boolean;
    //ϵͳ״̬
    function DoSmooth(const nOpen: Boolean): Boolean;
    //ִ�в���
  public
    constructor Create;
    destructor Destroy; override;
    function OpenSmooth: Boolean;
    function CloseSmooth: Boolean;
  end;

var
  gSmoothSwitcher: TSmoothFontSwitch = nil;
  //ȫ��ʹ��

implementation

//Desc: ����
constructor TSmoothFontSwitch.Create;
begin
  SystemParametersInfo(SPI_GETFONTSMOOTHING, 0, @FInitSmooth, 0);
end;

//Desc: �ͷ�
destructor TSmoothFontSwitch.Destroy;
begin
  OpenSmooth;
  inherited;
end;

//Desc: ���û�ر�ƽ����ʾ
function TSmoothFontSwitch.DoSmooth(const nOpen: Boolean): Boolean;
begin
  if (not nOpen) or FInitSmooth then
       Result := SystemParametersInfo(SPI_SETFONTSMOOTHING, Byte(nOpen), nil, SPIF_UPDATEINIFILE)
  else Result := False;
end;

//Desc: ����ƽ����ʾ
function TSmoothFontSwitch.OpenSmooth: Boolean;
begin
  Result := DoSmooth(True);
end;

//Desc: �ر�ƽ����ʾ
function TSmoothFontSwitch.CloseSmooth: Boolean;
begin
  Result := DoSmooth(False);
end;

initialization
  gSmoothSwitcher := TSmoothFontSwitch.Create;
finalization
  FreeAndNil(gSmoothSwitcher);
end.
