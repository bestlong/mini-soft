{*******************************************************************************
  ����: dmzn@163.com 2009-11-10
  ����: �����Զ���Ļ����
*******************************************************************************}
unit UFormSetBrightTime;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ULibFun, UDataModule, USysConst, UProtocol, StdCtrls, Mask, UMgrLang;

type
  TfFormSetBrightTime = class(TForm)
    GroupBox1: TGroupBox;
    BtnTest: TButton;
    BtnExit: TButton;
    Label1: TLabel;
    Label2: TLabel;
    EditScreen: TComboBox;
    EditDevice: TComboBox;
    GroupBox2: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    EditStart: TMaskEdit;
    EditEnd: TMaskEdit;
    Label7: TLabel;
    EditBright: TComboBox;
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

function ShowSetBrightTimeForm: Boolean;
//��ں���

implementation

{$R *.dfm}

//Desc: ��Ļ�Զ����ȴ���
function ShowSetBrightTimeForm: Boolean;
begin
  with TfFormSetBrightTime.Create(Application) do
  begin
    Caption := ML('�Զ���Ļ����');
    Result := ShowModal = mrOk;
    Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormSetBrightTime.FormCreate(Sender: TObject);
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

procedure TfFormSetBrightTime.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveFormConfig(Self);
end;

procedure TfFormSetBrightTime.BtnExitClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------
//Desc: ��ȡ�豸��
procedure TfFormSetBrightTime.EditScreenChange(Sender: TObject);
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
procedure TfFormSetBrightTime.BtnTestClick(Sender: TObject);
var nStr: string;
    nPos: Integer;
    nItem: PScreenItem;
    nData: THead_Send_SetBrightTime;
    nRespond: THead_Respond_SetBrightTime;
begin
  if EditScreen.ItemIndex < 0 then
  begin
    EditScreen.SetFocus;
    ShowMsg(ML('��ѡ������õ���Ļ'), sHint); Exit;
  end;

  nItem := gScreenList[EditScreen.ItemIndex];
  FillChar(nData, cSize_Head_Send_SetBrightTime, #0);

  try
    nStr := EditStart.Text;
    nPos := Pos(':', nStr);

    nData.FTimeBegin[0] := StrToInt(Copy(nStr, 1, nPos - 1));
    System.Delete(nStr, 1, nPos);
    nData.FTimeBegin[1] := StrToInt(nStr);
  except
    EditStart.SetFocus;
    ShowMsg(ML('��������Ч����ʼʱ��'), sHint); Exit;
  end;

  try
    nStr := EditEnd.Text;
    nPos := Pos(':', nStr);

    nData.FTimeEnd[0] := StrToInt(Copy(nStr, 1, nPos - 1));
    System.Delete(nStr, 1, nPos);
    nData.FTimeEnd[1] := StrToInt(nStr);
  except
    EditEnd.SetFocus;
    ShowMsg(ML('��������Ч�Ľ���ʱ��'), sHint); Exit;
  end;  

  nData.FHead := Swap(cHead_DataSend);
  nData.FLen := Swap(cSize_Head_Send_SetBrightTime);
  nData.FCardType := nItem.FCard;

  if EditDevice.ItemIndex > 0 then
       nData.FDevice := Swap(nItem.FDevice[EditDevice.ItemIndex - 1].FID)
  else nData.FDevice := sFlag_BroadCast;

  nData.FCommand := cCmd_SetBrightTime;
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

    Move(FDM.FValidBuffer[0], nRespond, cSize_Head_Respond_SetBrightTime);
    if nRespond.FFlag = sFlag_OK then
    begin
      ModalResult := mrOk;
      ShowMsg(ML('�����ɹ�'), sHint);
    end else ShowMsg(ML('����ʧ��'), sHint);

    BtnTest.Enabled := True;
  except
    BtnTest.Enabled := True;
    ShowMsg(ML(nStr), sHint);
  end;
end;

end.
