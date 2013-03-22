{*******************************************************************************
  ����: dmzn@163.com 2013-3-20
  ����: ѹ������
*******************************************************************************}
unit UFormPressMax;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, UFormBase, USysProtocol, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit,
  dxLayoutControl, StdCtrls, ExtCtrls;

type
  TfFormPressMax = class(TfFormNormal)
    EditValue: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    dxLayout1Item4: TdxLayoutItem;
    Bevel1: TBevel;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FCMD: Byte;
    FPort: PCOMParam;
    FDev: PDeviceItem;
    procedure InitFormData;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}

uses
  ULibFun, UMgrControl, UMgrConnection, UFormWait, USysConst, USysDB;

class function TfFormPressMax.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  nP := nParam;

  with TfFormPressMax.Create(Application) do
  begin
    FCMD := nP.FCommand;
    FPort := Pointer(Integer(nP.FParamA));
    FDev := Pointer(Integer(nP.FParamB));

    InitFormData;
    ShowModal;
    Free;
  end;
end;

class function TfFormPressMax.FormID: integer;
begin
  Result := cFI_FormPressMax;
end;

procedure TfFormPressMax.InitFormData;
begin
  case FCMD of
   cFun_BreakPipeMax : Caption := sBreakPipe;
   cFun_BreakPotMax  : Caption := sBreakPot;
   cFun_TotalPipeMax : Caption := sTotalPipe;
  end;
end;

//Date: 2013-3-20
//Parm: ��ֵ;�ֽ���
//Desc: ���nVal�ĸߵ��ֽ�
procedure SplitData(const nVal: Word; var nData: TDataBytes);
var nD: TDoubleByte;
begin
  nD := TDoubleByte(nVal);
  SetLength(nData, 2);

  nData[0] := nD.FL;
  nData[1] := nD.FH and $03; //0000 0011
end;

procedure TfFormPressMax.BtnOKClick(Sender: TObject);
var nStr: string;
    nVal: Word;
    nData: TDataBytes;
begin
  if not IsNumber(EditValue.Text, False) then
  begin
    EditValue.SetFocus;
    ShowMsg('ѹ��ֵΪ����0������', sHint); Exit;
  end;

  nVal := StrToInt(EditValue.Text);
  if (nVal < 1) or (nVal > 1000) then
  begin
    EditValue.SetFocus;
    ShowMsg('ѹ��ֵ����1-1000֮��', sHint); Exit;
  end;

  BtnOK.Enabled := False;
  try
    ShowWaitForm(Self, '����ѹ������', True);
    Sleep(500);
    SplitData(nVal, nData);
    
    if gPortManager.DeviceCommand(FPort.FPortName, FDev.FIndex, FCMD, nData,
       nStr) then
    begin
      ModalResult := mrOk;
      ShowMsg('�������', sHint);
    end else ShowMsg(nStr, sHint);
  finally
    BtnOK.Enabled := True;
    CloseWaitForm;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormPressMax, TfFormPressMax.FormID);
end.
