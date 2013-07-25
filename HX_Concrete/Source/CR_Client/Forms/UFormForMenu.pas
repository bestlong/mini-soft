{*******************************************************************************
  ����: dmzn@163.com 2013-07-10
  ����: ҵ��˵��������.

  ��ע:
  *.���ڿ�ܵĲ˵����ñ����Ǵ����Frame,��֧�ֺ�����Ӧ.���Զ����޴���ҵ��,��Ҫ
    �ô��ڵ�CreateForm����.
*******************************************************************************}
unit UFormForMenu;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormBase;

type
  TfFormForMenu = class(TBaseForm)
  private
    { Private declarations }
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}

uses
  ULibFun, UMgrControl, UFormWait, USysBusiness, USysConst;

class function TfFormForMenu.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nCard: string;
    nBool: Boolean;
begin
  Result := nil;
  if nPopedom = 'MAIN_D01' then
    nCard := '��վҵ��'
  else if nPopedom = 'MAIN_D02' then
    nCard := '��վҵ��'
  else if nPopedom = 'MAIN_D04' then
    nCard := '˾��ˢ��';
  //xxxxx

  nCard := GetTruckCard(nCard);
  if nCard = '' then Exit;

  ShowWaitForm(Application.MainForm, '����ҵ��', True);
  try
    if nPopedom = 'MAIN_D01' then
      nBool := MakeTruckIn(nCard)
    else if nPopedom = 'MAIN_D02' then
      nBool := MakeTruckOut(nCard)
    else if nPopedom = 'MAIN_D04' then
      nBool := MakeTruckResponse(nCard) else nBool := False;
  finally
    CloseWaitForm;
  end;

  if nBool then
    ShowMsg('�����ɹ�', sHint);
  //xxxxx
end;

class function TfFormForMenu.FormID: integer;
begin
  Result := cFI_FormBusiness;
end;

initialization
  gControlManager.RegCtrl(TfFormForMenu, TfFormForMenu.FormID);
finalization

end.
