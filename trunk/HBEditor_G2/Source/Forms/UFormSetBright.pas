{*******************************************************************************
  ����: dmzn@163.com 2009-11-10
  ����: ������Ļ����
*******************************************************************************}
unit UFormSetBright;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ULibFun, UDataModule, USysConst, UProtocol, StdCtrls, UMgrLang;

type
  TfFormSetBright = class(TForm)
    GroupBox1: TGroupBox;
    BtnTest: TButton;
    BtnExit: TButton;
    Label1: TLabel;
    Label2: TLabel;
    EditScreen: TComboBox;
    EditDevice: TComboBox;
    EditBright: TComboBox;
    Label3: TLabel;
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

function ShowSetBrightForm: Boolean;
//��ں���

implementation

{$R *.dfm}

//Desc: �������ô���
function ShowSetBrightForm: Boolean;
begin
  with TfFormSetBright.Create(Application) do
  begin
    Caption := ML('��������');
    Result := ShowModal = mrOk;
    Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormSetBright.FormCreate(Sender: TObject);
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

procedure TfFormSetBright.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveFormConfig(Self);
end;

procedure TfFormSetBright.BtnExitClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------
//Desc: ��ȡ�豸��
procedure TfFormSetBright.EditScreenChange(Sender: TObject);
var nStr: string;
    nIdx: integer;
    nItem: PScreenItem;
begin
  EditDevice.Clear;
  if EditScreen.ItemIndex < 0 then Exit;

  EditDevice.Items.Add(ML('ȫ���豸'));
  nItem := gScreenList[EditScreen.ItemIndex];

  for nIdx:=Low(nItem.FDevice) to High(nItem.FDevice) do
  begin
    nStr := Format('%d-%s', [nItem.FDevice[nIdx].FID, nItem.FDevice[nIdx].FName]);
    EditDevice.Items.Add(nStr);
  end;

  EditDevice.ItemIndex := 0;
end;

//Desc: ����
procedure TfFormSetBright.BtnTestClick(Sender: TObject);
var nStr: string;
    nItem: PScreenItem;
    nData: THead_Send_SetBright;
    nRespond: THead_Respond_SetBright;
begin
  if EditScreen.ItemIndex < 0 then
  begin
    EditScreen.SetFocus;
    ShowMsg(ML('��ѡ������õ���Ļ'), sHint); Exit;
  end;

  nItem := gScreenList[EditScreen.ItemIndex];
  FillChar(nData, cSize_Head_Send_SetBright, #0);

  nData.FHead := Swap(cHead_DataSend);
  nData.FLen := Swap(cSize_Head_Send_SetBright);
  nData.FCardType := nItem.FCard;

  if EditDevice.ItemIndex > 0 then
       nData.FDevice := Swap(nItem.FDevice[EditDevice.ItemIndex - 1].FID)
  else nData.FDevice := sFlag_BroadCast;
  
  nData.FCommand := cCmd_SetBright;
  nData.FBright := StrToInt(EditBright.Text);

  with FDM do
  try
    BtnTest.Enabled := False;
    nStr := '�������ͨ��ʧ��';

    Comm1.StopComm;
    Comm1.CommName := nItem.FPort;
    Comm1.BaudRate := nItem.FBote;

    Comm1.StartComm;
    Sleep(500);

    nStr := '��������ʧ��';
    FWaitCommand := nData.FCommand;
    Comm1.WriteCommData(@nData, cSize_Head_Send_SetBright);

    if not WaitForTimeOut(nStr) then
      raise Exception.Create('');
    //xxxxx

    Move(FDM.FValidBuffer[0], nRespond, cSize_Head_Respond_SetBright);
    if nRespond.FFlag = sFlag_OK then
    begin
      ModalResult := mrOk;
      ShowMsg(ML('�������óɹ�'), sHint);
    end else ShowMsg(ML('��������ʧ��'), sHint);

    BtnTest.Enabled := True;
  except
    BtnTest.Enabled := True;
    ShowMsg(ML(nStr), sHint);
  end;
end;

end.
