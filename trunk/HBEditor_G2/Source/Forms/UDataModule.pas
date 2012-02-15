unit UDataModule;

interface

uses
  Windows, SysUtils, Classes, Forms, UProtocol, USysConst, SPComm;

type
  TFDM = class(TDataModule)
    Comm1: TComm;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure Comm1ReceiveData(Sender: TObject; Buffer: Pointer;
      BufferLength: Word);
  private
    { Private declarations }
    FBuffer: array of Byte;
    //���ջ���
  public
    { Public declarations }
    FWaitCommand: Integer;
    //�ȴ�������
    FWaitResult: Boolean;
    //�ȴ�����
    FValidBuffer: array of Byte;
    //��Ч����
    procedure SetWaitTime(const nDataSize: Word);
    function WaitForTimeOut(var nMsg: string): Boolean;
    //�ȴ���ʱ
  end;

var
  FDM: TFDM;

implementation

{$R *.dfm}

procedure TFDM.DataModuleCreate(Sender: TObject);
begin
  //nothing
end;

procedure TFDM.DataModuleDestroy(Sender: TObject);
begin
  Comm1.StopComm;
end;

//Date: 2009-11-16
//Parm: ������ʾ��Ϣ
//Desc: �ظ�����ȴ�,ֱ�����յ���Ч����
function TFDM.WaitForTimeOut(var nMsg: string): Boolean;
var nInit: Int64;
begin
  Result := False;
  nMsg := '�������ͨ�ų�ʱ';

  FWaitResult := False;
  nInit := GetTickCount;

  while GetTickCount - nInit < gSendInterval do
  begin
    Application.ProcessMessages;
    Result := FWaitResult;

    if Result then
         Break
    else Sleep(1);
  end;
end;

//Desc: ���ó�ʱ���
procedure TFDM.SetWaitTime(const nDataSize: Word);
begin
  gSendInterval := Trunc(nDataSize * 0.5);
  if gSendInterval < cSendInterval_Long then
    gSendInterval := cSendInterval_Long;
  //xxxxx
end;

procedure TFDM.Comm1ReceiveData(Sender: TObject; Buffer: Pointer;
  BufferLength: Word);
var nLen: integer;
    i,nCount: integer;
    nBase: THead_Respond_Base;
begin
  nLen := Length(FBuffer);
  SetLength(FBuffer, nLen + BufferLength);
  Move(Buffer^, FBuffer[nLen], BufferLength);

  nCount := High(FBuffer) - cSize_Respond_Base;
  //��������Э��ͷ�ĳ���

  for i:=Low(FBuffer) to nCount do
  if (FBuffer[i] = cHead_DataRecv_Hi) and (FBuffer[i+1] = cHead_DataRecv_Low) then
  begin
    Move(FBuffer[i], nBase, cSize_Respond_Base);
    //ȡ����Э��ͷ

    case nBase.FCommand of
      cCmd_SetBorder:     //���ñ߿�
        nLen := cSize_Head_Respond_SetBorder;
      cCmd_SetScanMode:   //ɨ��ģʽ
        nLen := cSize_Head_Respond_ScanMode;
      cCmd_SetELevel:     //��Ч��ƽ
        nLen := cSize_Head_Respond_ELevel;
      cCmd_ConnCtrl:      //����������
        nLen := cSize_Head_Respond_ConnCtrl;
      cCmd_SetDeviceNo:   //�����豸��
        nLen := cSize_Head_Respond_SetDeviceNo;
      cCmd_ResetCtrl:     //��λ������
        nLen := cSize_Head_Respond_ResetCtrl;
      cCmd_SetBright:     //��������
        nLen := cSize_Head_Respond_SetBright;
      cCmd_SetBrightTime: //ʱ������
        nLen := cSize_Head_Respond_SetBrightTime;
      cCmd_AdjustTime:    //У׼ʱ��
        nLen := cSize_Head_Respond_AdjustTime;
      cCmd_OpenOrClose:   //������Ļ
        nLen := cSize_Head_Respond_OpenOrClose;
      cCmd_OCTime:        //����ʱ��
        nLen := cSize_Head_Respond_OCTime;
      cCmd_PlayDays:      //��������
        nLen := cSize_Head_Respond_PlayDays;
      cCmd_ReadStatus:    //��ȡ״̬
        nLen := cSize_Head_Respond_ReadStatus;
      cCmd_SetScreenWH:   //��Ļ���
        nLen := cSize_Head_Respond_SetScreenWH;
      cCmd_DataBegin:     //��ʼ֡
        nLen := cSize_Head_Respond_DataBegin;
      cCmd_DataEnd:       //����֡
        nLen := cSize_Head_Respond_DataEnd;
      cCmd_SendPicData:   //ͼƬ����
        nLen := cSize_Head_Respond_PicData;
      cCmd_SendSimuClock:   //ģ��ʱ��
        nLen := cSize_Head_Respond_Clock;
      cCmd_SendAnimate:   //��������
        nLen := cSize_Head_Respond_Animate
      else
      begin               //�޷�ʶ��ָ��
        SetLength(FBuffer, 0); Exit;
      end;
    end;

    if Length(FBuffer) - i >= nLen then
    begin
      if nBase.FCommand = FWaitCommand then
      begin
        FWaitCommand := -1;
        SetLength(FValidBuffer, nLen);

        Move(FBuffer[i], FValidBuffer[0], nLen);
        FWaitResult := True;
      end;

      SetLength(FBuffer, 0);
      Break;
    end;
  end;

  if nLen > 100 then
    SetLength(FBuffer, 0);
  //���������
end;

end.
