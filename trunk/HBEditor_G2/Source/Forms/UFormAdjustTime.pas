{*******************************************************************************
  ����: dmzn@163.com 2009-11-10
  ����: У׼ʱ��
*******************************************************************************}
unit UFormAdjustTime;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ULibFun, UDataModule, USysConst, UProtocol, StdCtrls, Mask, UMgrLang;

type
  TfFormAdjustTime = class(TForm)
    GroupBox1: TGroupBox;
    BtnTest: TButton;
    BtnExit: TButton;
    Label1: TLabel;
    Label2: TLabel;
    EditScreen: TComboBox;
    EditDevice: TComboBox;
    Label3: TLabel;
    EditTime: TMaskEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnExitClick(Sender: TObject);
    procedure EditScreenChange(Sender: TObject);
    procedure BtnTestClick(Sender: TObject);
  private
    { Private declarations }
    procedure SetNowTime;
    //��ǰʱ��
    function GetSetTime: TStrings;
    //����ʱ��
  public
    { Public declarations }
  end;

function ShowAdjustTimeForm: Boolean;
//��ں���

implementation

{$R *.dfm}

//Desc: ʱ��У׼����
function ShowAdjustTimeForm: Boolean;
begin
  with TfFormAdjustTime.Create(Application) do
  begin
    Caption := ML('У׼ʱ��');
    Result := ShowModal = mrOk;
    Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormAdjustTime.FormCreate(Sender: TObject);
var i,nCount: integer;
    nItem: PScreenItem;
begin   
  LoadFormConfig(Self);
  gMultiLangManager.SectionID := Name;

  gMultiLangManager.TranslateAllCtrl(Self);
  EditTime.EditMask := ML(EditTime.EditMask);

  SetNowTime;
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

procedure TfFormAdjustTime.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveFormConfig(Self);
end;

procedure TfFormAdjustTime.BtnExitClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------
//Desc: ��ȡ�豸��
procedure TfFormAdjustTime.EditScreenChange(Sender: TObject);
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

//Desc: ���õ�ǰʱ��
procedure TfFormAdjustTime.SetNowTime;
var nStr: string;
    nWeek: Word;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    nStr := FormatDateTime('YY.MM.DD.hh.mm.ss', Now);
    SplitStr(nStr, nList, 6, '.');

    nWeek := DayOfWeek(Now) - 1;
    if nWeek < 1 then nWeek := 7;

    nStr := ML('%s��%s��%s��  ����:%d  ʱ��:%sʱ%s��%s��');
    nStr := Format(nStr, [nList[0], nList[1], nList[2],
            nWeek, nList[3], nList[4], nList[5]]);
    EditTime.Text := nStr;
  finally
    nList.Free;
  end;
end;

//Desc: ��ȡ�û����õ�ʱ��
function TfFormAdjustTime.GetSetTime: TStrings;
var nStr: string;
    nIdx: integer;
begin
  nStr := EditTime.Text;
  for nIdx:=Length(nStr) downto 1 do
   if not (nStr[nIdx] in ['0'..'9']) then nStr[nIdx] := ' ';
  //xxxxx

  Result := TStringList.Create;
  if not SplitStr(nStr, Result, 0, ' ') then FreeAndNil(Result);

  for nIdx:=Result.Count - 1 downto 0 do
    if Trim(Result[nIdx]) = '' then Result.Delete(nIdx);
  if Result.Count <> 7 then FreeAndNil(Result);
end;

//Desc: ����
procedure TfFormAdjustTime.BtnTestClick(Sender: TObject);
var nStr: string;
    nList: TStrings;
    nItem: PScreenItem;
    nData: THead_Send_AdjustTime;
    nRespond: THead_Respond_AdjustTime;
begin
  if EditScreen.ItemIndex < 0 then
  begin
    EditScreen.SetFocus;
    ShowMsg(ML('��ѡ���У׼����Ļ'), sHint); Exit;
  end;

  nList := GetSetTime;
  if not Assigned(nList) then
  begin
    EditTime.SetFocus;
    ShowMsg(ML('��������Ч��ʱ��'), sHint); Exit;
  end;

  nItem := gScreenList[EditScreen.ItemIndex];
  FillChar(nData, cSize_Head_Send_AdjustTime, #0);

  nData.FHead := Swap(cHead_DataSend);
  nData.FLen := Swap(cSize_Head_Send_AdjustTime);
  nData.FCardType := nItem.FCard;
  nData.FCommand := cCmd_AdjustTime;

  if EditDevice.ItemIndex > 0 then
       nData.FDevice := Swap(nItem.FDevice[EditDevice.ItemIndex - 1].FID)
  else nData.FDevice := sFlag_BroadCast;

  nData.FTime[0] := StrToInt(nList[0]);
  nData.FTime[1] := StrToInt(nList[1]);
  nData.FTime[2] := StrToInt(nList[2]);
  nData.FTime[3] := StrToInt(nList[3]);
  nData.FTime[4] := StrToInt(nList[4]);
  //nData.FTime[4] := nData.FTime[4] mod 12;
  nData.FTime[5] := StrToInt(nList[5]);
  nData.FTime[6] := StrToInt(nList[6]);
  nList.Free;

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
    Comm1.WriteCommData(@nData, cSize_Head_Send_AdjustTime);

    if not WaitForTimeOut(nStr) then
      raise Exception.Create('');
    //xxxxx

    Move(FDM.FValidBuffer[0], nRespond, cSize_Head_Respond_AdjustTime);
    if nRespond.FFlag = sFlag_OK then
    begin
      ModalResult := mrOk;
      ShowMsg(ML('ʱ��У׼�ɹ�'), sHint);
    end else ShowMsg(ML('ʱ��У׼ʧ��'), sHint);

    BtnTest.Enabled := True;
  except
    BtnTest.Enabled := True;
    ShowMsg(ML(nStr), sHint);
  end;
end;

end.
