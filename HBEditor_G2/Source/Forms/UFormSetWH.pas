{*******************************************************************************
  ����: dmzn@163.com 2009-11-10
  ����: ������Ļ���
*******************************************************************************}
unit UFormSetWH;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ULibFun, UDataModule, USysConst, UProtocol, StdCtrls, UMgrLang;

type
  TfFormSetWH = class(TForm)
    GroupBox1: TGroupBox;
    BtnTest: TButton;
    BtnExit: TButton;
    Label1: TLabel;
    Label2: TLabel;
    EditScreen: TComboBox;
    EditDevice: TComboBox;
    Label3: TLabel;
    EditW: TEdit;
    Label4: TLabel;
    EditH: TEdit;
    Label5: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnExitClick(Sender: TObject);
    procedure EditScreenChange(Sender: TObject);
    procedure BtnTestClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function SetDeviceWH(const nScreen: PScreenItem; const nDevice: Integer;
  const nW,nH: Integer; var nHint: string): Boolean;
function ShowSetWHForm: Boolean;
//��ں���

implementation

{$R *.dfm}

//Desc: ��ߴ���
function ShowSetWHForm: Boolean;
begin
  with TfFormSetWH.Create(Application) do
  begin
    Caption := ML('��Ļ���');
    Result := ShowModal = mrOk;
    Free;
  end;
end;

//Date: 2009-12-06
//Parm: ��Ļ;�豸��;��,��;��ʾ����
//Desc: ����nScreen.nDevice���ΪnW.nH,����ǰ��ҪComm����
function SetDeviceWH(const nScreen: PScreenItem; const nDevice: Integer;
  const nW,nH: Integer; var nHint: string): Boolean;
var nData: THead_Send_SetScreenWH;
    nRespond: THead_Respond_SetScreenWH;
begin
  Result := False;
  FillChar(nData, cSize_Head_Send_SetScreenWH, #0);

  nData.FHead := Swap(cHead_DataSend);
  nData.FLen := Swap(cSize_Head_Send_SetScreenWH);
  nData.FCardType := nScreen.FCard;

  if nDevice > -1 then
       nData.FDevice := Swap(nScreen.FDevice[nDevice].FID)
  else nData.FDevice := sFlag_BroadCast;

  nData.FCommand := cCmd_SetScreenWH;     
  nData.FScreenWH[0] := Trunc(nW / 8);
  nData.FScreenWH[1] := Trunc(nH / 8);

  with FDM do
  try
    FWaitCommand := nData.FCommand;
    Result := Comm1.WriteCommData(@nData, cSize_Head_Send_SetScreenWH);

    if not Result then
    begin
     nHint := '�������ÿ������ʧ��'; Exit;
    end;

    Result := WaitForTimeOut(nHint);
    if not Result then
    begin
      nHint := '���ÿ������Ӧ��ʱ'; Exit;
    end;

    Move(FDM.FValidBuffer[0], nRespond, cSize_Head_Respond_SetScreenWH);
    Result := nRespond.FFlag = sFlag_OK;
    if not Result then nHint := '�������ʧ��';
  except
    //ignor any error
  end;

  nHint := ML(nHint);
end;

//------------------------------------------------------------------------------
procedure TfFormSetWH.FormCreate(Sender: TObject);
var i,nCount: integer;
    nItem: PScreenItem;
begin
  LoadFormConfig(Self);
  gMultiLangManager.SectionID := Name;
  gMultiLangManager.TranslateAllCtrl(Self);
  
  EditScreen.Clear;
  nCount := gScreenList.Count - 1;

  for i:=0 to nCount do
  begin
    nItem := gScreenList[i];
    EditScreen.Items.Add(Format('%d-%s', [nItem.FID, nItem.FName]));
  end;

  if EditScreen.Items.Count > 0 then
  begin
    EditScreen.ItemIndex := 0;
    EditScreenChange(nil);
  end;
end;

procedure TfFormSetWH.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveFormConfig(Self);
end;

procedure TfFormSetWH.BtnExitClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------
//Desc: ��ȡ�豸��
procedure TfFormSetWH.EditScreenChange(Sender: TObject);
var nStr: string;
    nIdx: integer;
    nItem: PScreenItem;
begin
  EditDevice.Clear;
  if EditScreen.ItemIndex < 0 then Exit;

  nItem := gScreenList[EditScreen.ItemIndex];
  EditW.Text := IntToStr(nItem.FLenX);
  EditH.Text := IntToStr(nItem.FLenY);

  EditDevice.Items.Add(ML('ȫ���豸'));
  for nIdx:=Low(nItem.FDevice) to High(nItem.FDevice) do
  begin
    nStr := Format('%d-%s', [nItem.FDevice[nIdx].FID, nItem.FDevice[nIdx].FName]);
    EditDevice.Items.Add(nStr);
  end;

  EditDevice.ItemIndex := 0;
end;

//Desc: ����
procedure TfFormSetWH.BtnTestClick(Sender: TObject);
var nStr: string;
    nIdx: integer;
    nItem: PScreenItem;
begin
  if EditScreen.ItemIndex < 0 then
  begin
    EditScreen.SetFocus;
    ShowMsg(ML('��ѡ������õ���Ļ'), sHint); Exit;
  end;

  if not IsNumber(EditW.Text, False) then
  begin
    EditW.SetFocus;
    ShowMsg(ML('��������Ч�Ŀ��ֵ'), sHint); Exit;
  end;

  if not IsNumber(EditH.Text, False) then
  begin
    EditH.SetFocus;
    ShowMsg(ML('��������Ч�ĸ߶�ֵ'), sHint); Exit;
  end;

  with FDM do
  try
    BtnTest.Enabled := False;
    nStr := '�������ͨ��ʧ��';

    nItem := gScreenList[EditScreen.ItemIndex];
    nIdx := EditDevice.ItemIndex - 1;

    Comm1.StopComm;
    Comm1.CommName := nItem.FPort;
    Comm1.BaudRate := nItem.FBote;

    Comm1.StartComm;
    Sleep(500);
        
    if SetDeviceWH(nItem, nIdx, StrToInt(EditW.Text), StrToInt(EditH.Text), nStr) then
    begin
      ModalResult := mrOk;
      ShowMsg('������óɹ�', sHint);
    end else raise Exception.Create('');
  except
    BtnTest.Enabled := True;
    ShowMsg(ML(nStr), sHint);
  end;
end;

end.
