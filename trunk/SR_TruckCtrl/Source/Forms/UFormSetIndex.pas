{*******************************************************************************
  ����: dmzn@163.com 2013-3-9
  ����: ���õ�ַ
*******************************************************************************}
unit UFormSetIndex;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, UFormBase, USysProtocol, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit,
  cxDropDownEdit, cxLabel, cxTextEdit, dxLayoutControl, StdCtrls;

type
  TfFormSetIndex = class(TfFormNormal)
    EditIndex: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditSerial: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
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
  ULibFun, UMgrControl, UMgrConnection, UFormWait, USysConst, USysDB;

class function TfFormSetIndex.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;

  with TfFormSetIndex.Create(Application) do
  begin
    ShowModal;
    Free;
  end;
end;

class function TfFormSetIndex.FormID: integer;
begin
  Result := cFI_FormSetIndex;
end;

//Desc: ���õ�ַ
procedure TfFormSetIndex.BtnOKClick(Sender: TObject);
var nStr: string;
    nIdx: Integer;
    nData: TDataBytes;
    nList: TList;
    nPort: PCOMItem;
begin
  if (not IsNumber(EditIndex.Text, False)) or
     (StrToInt(EditIndex.Text) >= High(Byte)) then
  begin
    EditIndex.SetFocus;
    ShowMsg('��ַΪС��255������', sHint); Exit;
  end;

  EditSerial.Text := Trim(EditSerial.Text);
  if Length(EditSerial.Text) < 4 then
  begin
    EditSerial.SetFocus;
    ShowMsg('װ�ñ����Ҫ4λ', sHint); Exit;
  end;

  nStr := EditSerial.Text;
  for nIdx:=1 to Length(nStr) do
   if not (nStr[nIdx] in ['0'..'9','a'..'f','A'..'F']) then
   begin
     EditSerial.SetFocus;
     ShowMsg('���ȡ0-9,A-F�ַ�', sHint); Exit;
   end;

  SetLength(nData, 1 + Length(nStr));
  nData[0] := StrToInt(EditIndex.Text);

  nIdx := 1;  
  while nIdx <= Length(nStr) do
  begin
    nData[nIdx] := StrToInt('$' + nStr[nIdx]);
    Inc(nIdx);
  end;

  //----------------------------------------------------------------------------
  nList := gDeviceManager.LockPortList; 
  try
    BtnOK.Enabled := False;
    ShowWaitForm(Self, '���õ�ַ', True);
    //progress

    for nIdx:=0 to nList.Count - 1 do
    begin
      nPort := nList[nIdx];
      if gPortManager.DeviceCommand(nPort.FParam.FPortName, cAddr_Broadcast,
         cFun_SetIndex, nData, nStr) then
      begin
        ShowMsg('���óɹ�', sHint);
        ModalResult := mrOk;
        Exit;
      end;
    end;

    BtnOK.Enabled := True;
    ShowMsg('���豸��Ӧ', sHint);
  finally
    gDeviceManager.ReleaseLock;
    CloseWaitForm;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormSetIndex, TfFormSetIndex.FormID);
end.
