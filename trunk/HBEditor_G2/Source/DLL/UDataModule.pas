{*******************************************************************************
  ����: dmzn@163.com 2010-7-21
  ����: �⹦��ʵ�ֲ���
*******************************************************************************}
unit UDataModule;

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, UProtocol, ULibConst, SPComm,
  CPort, CPortTypes;

type
  TFDM = class(TDataModule)
    CPort1: TComPort;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure CPort1RxChar(Sender: TObject; Count: Integer);
  private
    { Private declarations }
    FBuffer: array of Byte;
    //���ջ���
    procedure CommReceiveData(const nBuf: PChar; const nBufLen: Word);
    //��������
  public
    { Public declarations }
    FWaitCommand: Integer;
    //�ȴ�������
    FWaitResult: Boolean;
    //�ȴ�����
    FValidBuffer: array of Byte;
    //��Ч����
    function WaitForTimeOut(var nMsg: string): Boolean;
    //�ȴ���ʱ
  end;

var
  FDM: TFDM;

procedure CommPortInit(const nComm: PChar; const nBaudRate: DWORD); stdcall;
//��ʼ���˿�
function CommPortConn: Boolean; stdcall;
function CommPortClose: Boolean; stdcall;
//���Ӻ͹ر�

procedure TransInit(const nCardType,nAreaNum,nInvert: Byte); stdcall;
//�����ʼ��
function TransBegin(const nMsg: PChar): Boolean; stdcall;
//���俪ʼ
function TransData(const nRect: PAreaRect; const nMode: PAreaMode;
 const nFont: PAreaFont; const nText,nMsg: PChar): Boolean; stdcall;
//��������
function TransEnd(const nMsg: PChar): Boolean; stdcall;
//�������

implementation

{$R *.dfm}

type
  TCardItem = record
    FCardType: Byte;
    FAreaNum: Byte;
    FInvert: Boolean;
  end;

var
  gCardItem: TCardItem;
  //������

//------------------------------------------------------------------------------
//Date: 2010-7-20
//Parm: �˿�;������
//Desc: ��ʼ����������
procedure CommPortInit(const nComm: PChar; const nBaudRate: DWORD);
begin
  with FDM.CPort1 do
  begin
    Close;
    Port := nComm;
    BaudRate := StrToBaudRate(IntToStr(nBaudRate));
  end;
end;

//Desc: ����
function CommPortConn: Boolean;
begin
  with FDM.CPort1 do
  try
    Close;
    //close first;
    Open;
    Result := Connected;
  except
    Result := False;
  end;
end;

//Desc: �ر�����
function CommPortClose: Boolean;
begin
  try
    FDM.CPort1.Close;
    Result := not FDM.CPort1.Connected;
  except
    Result := False;
  end;
end;

//Date: 2010-7-20
//Parm: ������;�������;��תɨ��
//Desc: ��ʼ���������
procedure TransInit(const nCardType,nAreaNum,nInvert: Byte);
begin
  FillChar(gCardItem, SizeOf(gCardItem), #0);
  gCardItem.FCardType := nCardType;
  gCardItem.FAreaNum := nAreaNum;
  gCardItem.FInvert := nInvert = 1;
end;

//Date: 2010-7-20
//Parm: [out]��ʾ��Ϣ
//Desc: ��������
function TransBegin(const nMsg: PChar): Boolean;
var nStr: string;
    nData: THead_Send_DataBegin;
    nRespond: THead_Respond_DataBegin;
begin
  Result := False;
  FillChar(nData, cSize_Head_Send_DataBegin, #0);

  nData.FHead := Swap(cHead_DataSend);
  nData.FLen := Swap(cSize_Head_Send_DataBegin);
  nData.FCardType := gCardItem.FCardType;

  nData.FDevice := sFlag_BroadCast;
  nData.FAreaNum := gCardItem.FAreaNum;
  nData.FCommand := cCmd_DataBegin;  

  with FDM do
  try
    FWaitCommand := nData.FCommand;
    CPort1.ClearBuffer(True, True);
    Result := CPort1.Write(@nData, cSize_Head_Send_DataBegin) =
                                   cSize_Head_Send_DataBegin;
    //xxxxx

    if not Result then
    begin
      nStr := '"��ʼ֡"���ݷ���ʧ��,�޷��򿪴���ģʽ!!';
      StrPCopy(nMsg, nStr); Exit;
    end;

    Result := WaitForTimeOut(nStr);
    if not Result then
    begin
      nStr := '�ȴ�"��ʼ֡"��Ӧ��ʱ,�޷��򿪴���ģʽ!!';
      StrPCopy(nMsg, nStr);  Exit;
    end;

    Move(FDM.FValidBuffer[0], nRespond, cSize_Head_Respond_DataBegin);
    Result := nRespond.FFlag = sFlag_OK;

    if Result then
    begin
      nStr := '�򿪴���ģʽ,��ʼ��������!';
      StrPCopy(nMsg, nStr);
    end else
    begin
      nStr := '"��ʼ֡"���ͳɹ�,����λ���򿪴���ģʽʧ��!!';
      StrPCopy(nMsg, nStr);
    end;
  except
    StrPCopy(nMsg, '�޷��򿪴���ģʽ');
  end;
end;

//------------------------------------------------------------------------------
//Desc: ��nData����һ���ֽ�
function MakeByte(const nData: TByteData): Byte;
var i,nLen: integer;
begin
  Result := 255;
  nLen := High(nData);

  for i:=Low(nData) to nLen do
  if nData[i] = 1 then
       Result := Result or cByteMask[i]
  else Result := Result and (255 xor cByteMask[i]);
end;

//Desc: ��nData����nByte�ֽ�����
procedure CharToByte(const nData: string; var nByte: TByteData);
var nIdx: integer;
begin
  for nIdx:=1 to 8 do
    nByte[nIdx - 1] := StrToInt(nData[nIdx]);
end;

//Desc: ��nData����nArray�ֽ���
procedure MakeByteArray(const nData: string; var nArray: TDynamicByteArray);
var nStr: string;
    nBit: TByteData;
    i,nIdx,nLen: integer;
begin
  nLen := Length(nData);
  if nLen mod 8 = 0 then
       nStr := nData
  else nStr := nData + StringOfChar('0', 8 - nLen mod 8);

  nLen := Length(nStr);
  i := nLen div 8;
  SetLength(nArray, i);

  nIdx := 0;
  for i:=1 to nLen do
   if i mod 8 = 0 then
   begin
     CharToByte(Copy(nStr, nIdx * 8 + 1, 8), nBit);
     nArray[nIdx] := MakeByte(nBit);
     Inc(nIdx);
   end;
end;

//Desc: �ϲ�nS���ݵ�nD��
procedure CombinByteArray(var nS,nD: TDynamicByteArray);
var nInt,nLen: integer;
begin
  nInt := Length(nS);
  nLen := Length(nD);
  
  SetLength(nD, nInt + nLen);
  Move(nS[Low(nS)], nD[nLen], nInt);
end;

//Desc: ʹ�õ�ɫ����ɨ��nBmp,����nData������
procedure ScanWithSingleMode(const nBmp: TBitmap; var nData: TDynamicByteArray);
var nBuf: string;
    nX,nY: integer;
    nBits: TDynamicByteArray;
begin
  SetLength(nData, 0);
  SetLength(nBuf, nBmp.Width);

  for nY :=0 to nBmp.Height - 1 do
  begin
    for nX:=0 to nBmp.Width - 1 do
    begin
      if nBmp.Canvas.Pixels[nX, nY] = clBlack then
           nBuf[nX + 1] := '1'
      else nBuf[nX + 1] := '0';

      if gCardItem.FInvert then
       if nBuf[nX + 1] = '0' then
            nBuf[nX + 1] := '1'
       else nBuf[nX + 1] := '0';
    end;

    MakeByteArray(nBuf, nBits);
    CombinByteArray(nBits, nData);
  end;
end;

//Desc: ��nFont����nCanvas����
procedure AssignCanvasFont(const nCanvas: TCanvas; const nFont: TAreaFont);
begin
  with nCanvas do
  begin
    Font.Color := clRed;
    Font.Name := nFont.FName;
    Font.Size := nFont.FSize;
    SetBkMode(Handle, TRANSPARENT);
  end;
end;

//Desc: ��nBmp����nW,nH��С���,�������nData��.
procedure SplitPicture(const nBmp: TBitmap; const nW,nH: Integer;
 var nData: TDynamicBitmapArray);
var nSR,nDR: TRect;
    nL,nT,nIdx: integer;
begin
  nT := 0;
  while nT < nBmp.Height do
  begin
    nL := 0;

    while nL < nBmp.Width do
    begin
      nIdx := Length(nData);
      SetLength(nData, nIdx + 1);

      nData[nIdx] := TBitmap.Create;
      nData[nIdx].Width := nW;
      nData[nIdx].Height := nH;

      nSR := Rect(nL, nT, nL + nW, nT + nH);
      nDR := Rect(0, 0, nW, nH);

      nData[nIdx].Canvas.CopyRect(nDR, nBmp.Canvas, nSR);
      //��������ͼƬ
      Inc(nL, nW); 
    end;

    Inc(nT, nH);
  end;
end;

//Desc: ��nText���Ƶ�һ��ͼƬ��,����nData
procedure DrawText(const nRect: TAreaRect; const nFont: TAreaFont;
 const nText: string; var nData: TDynamicBitmapArray);
var nStr: WideString;
    nBigBuf: TDynamicBitmapArray;
    nPos,nLen,nL,nT,nW,nBufIdx: integer;
begin
  nStr := nText;
  SetLength(nData, 0);

  SetLength(nBigBuf, 1);
  nBigBuf[0] := TBitmap.Create;
  try
    with nBigBuf[0] do
    begin
      AssignCanvasFont(Canvas, nFont);
      nW := Canvas.TextWidth(nStr);
      //���ݿ��

      nL := Trunc(nW / nRect.FWidth);
      if (nW mod nRect.FWidth) <> 0 then Inc(nL);
      //��Ҫ�ֵ���Ļ��

      nT := Trunc(4096 / nRect.FWidth);
      if nT > nL then nT := nL;
      //����ͼƬ�������

      Height := nRect.FHeight;
      Width := nRect.FWidth * nT;
      //ͼƬ��С

      Canvas.Brush.Color := clBlack;
      Canvas.FillRect(Rect(0, 0, Width, Height));

      nT := Canvas.TextHeight(nStr);
      nT := Trunc((nRect.FHeight - nT) / 2);
      //�����������
    end;             

    nL := 0;
    //�������
    nPos := 1;
    //�ı�����
    nBufIdx := 0;
    //��������
    nLen := Length(nStr);

    while nPos <= nLen do
    with nBigBuf[nBufIdx] do
    begin
      Canvas.TextOut(nL, nT, nStr[nPos]);
      Inc(nL, Canvas.TextWidth(nStr[nPos]));
      Inc(nPos);

      if nPos <= nLen then
           nW := Canvas.TextWidth(nStr[nPos])
      else nW := 0;

      if nL + nW > Width then
      begin
        nL := 0;
        Inc(nBufIdx);

        SetLength(nBigBuf, nBufIdx+1);
        nBigBuf[nBufIdx] := TBitmap.Create;
        nBigBuf[nBufIdx].Width := nBigBuf[0].Width;
        nBigBuf[nBufIdx].Height := nBigBuf[0].Height;

        nBigBuf[nBufIdx].Canvas.Brush.Color := clBlack;
        nBigBuf[nBufIdx].Canvas.FillRect(Rect(0, 0, Width, Height));
        AssignCanvasFont(Canvas, nFont);
      end;
    end;

    //--------------------------------------------------------------------------
    for nBufIdx:=Low(nBigBuf) to High(nBigBuf) do
      SplitPicture(nBigBuf[nBufIdx], nRect.FWidth, nRect.FHeight, nData);
    //����
  finally
    for nBufIdx:=Low(nBigBuf) to High(nBigBuf) do
      nBigBuf[nBufIdx].Free;
    //xxxxx
  end;
end;

//Date: 2010-7-20
//Parm: ����;ģʽ;����;����
//Desc: ��nRect������,��nModeģʽ��ʾnText����
function TransData(const nRect: PAreaRect; const nMode: PAreaMode;
 const nFont: PAreaFont; const nText,nMsg: PChar): Boolean;
var nStr: string;
    nIdx: Integer;
    nBuf: TDynamicBitmapArray;

    nCRC: Word;
    nData: TDynamicByteArray;
    nSend: THead_Send_PicData;
    nRespond: THead_Respond_PicData;
begin
  Result := False;
  StrPCopy(nMsg, '');

  nStr := StrPas(nText);
  if nStr = '' then Exit;

  try
    DrawText(nRect^, nFont^, nStr, nBuf);
    if Length(nBuf) < 1 then
    begin
      StrPCopy(nMsg, '�޷�ɨ���ı�����,������ֹ!'); Exit;
    end;

    //--------------------------------------------------------------------------
    FillChar(nSend, cSize_Head_Send_PicData, #0);
    nSend.FHead := Swap(cHead_DataSend);
    nSend.FCardType := gCardItem.FCardType;
    nSend.FCommand := cCmd_SendPicData;

    nSend.FDevice := sFlag_BroadCast;
    nSend.FAllID := Swap(Length(nBuf));
    nSend.FLevel := 0;
    nSend.FIndexID := 0;

    nSend.FPosX := Swap(nRect.FLeft);
    nSend.FPosY := Swap(nRect.FTop);
    nSend.FWidth := Swap(nRect.FWidth);
    nSend.FHeight := Swap(nRect.FHeight);

    for nIdx:=Low(nBuf) to High(nBuf) do
    try
      ScanWithSingleMode(nBuf[nIdx], nData);
      nSend.FNowID := Swap(nIdx);
      nSend.FLen := Swap(Length(nData) + cSize_Head_Send_PicData + 2);
      //����Э������

      nSend.FMode[0] := nMode.FEnterMode;
      nSend.FMode[1] := nMode.FEnterSpeed;
      nSend.FMode[2] := nMode.FKeepTime;
      nSend.FMode[3] := nMode.FExitMode;
      nSend.FMode[4] := nMode.FExitSpeed;
      nSend.FMode[5] := nMode.FModeSerial;
      nSend.FMode[6] := 1;
      //���ģʽ

      FDM.FWaitCommand := nSend.FCommand;
      Result := FDM.CPort1.Write(@nSend, cSize_Head_Send_PicData) > 0;

      if Result then
        Result := FDM.CPort1.Write(@nData[Low(nData)], Length(nData)) > 0;
      //ͼƬ����

      if Result then
      begin
        nCRC := 0;
        Result := FDM.CPort1.Write(@nCRC, SizeOf(nCRC)) > 0;
      end;
      //У��λ

      if not Result then
      begin
        nStr := '��[ %d ]Ļ���ݷ���ʧ��!!';
        StrPCopy(nMsg, Format(nStr, [nIdx])); Break;
      end;

      Result := FDM.WaitForTimeOut(nStr);
      if not Result then
      begin
        nStr := '���͵�[ %d ]Ļ����ʱ��λ������Ӧ!!';
        StrPCopy(nMsg, Format(nStr, [nIdx])); Break;
      end;

      Move(FDM.FValidBuffer[0], nRespond, cSize_Head_Respond_PicData);
      Result := nRespond.FFlag = sFlag_OK;
      //����ж�
      
      if not Result then
      begin
        nStr := '��[ %d ]Ļ�����ѳɹ�����,����λ�������쳣!!';
        StrPCopy(nMsg, Format(nStr, [nIdx])); Break;
      end;
    except
      nStr := '���͵�[ %d ]Ļ����ʱ��������!!';
      StrPCopy(nMsg, Format(nStr, [nIdx])); Break;
    end;
  finally
    for nIdx:=Low(nBuf) to High(nBuf) do
      nBuf[nIdx].Free;
    //xxxxx
  end;
end;

//Date: 2010-7-20
//Parm: [out]��ʾ��Ϣ
//Desc: �رմ���
function TransEnd(const nMsg: PChar): Boolean;
var nStr: string;
    nSend: THead_Send_DataEnd;
    nRespond: THead_Respond_DataEnd;
begin
  Result := False;
  FillChar(nSend, cSize_Head_Send_DataEnd, #0);

  nSend.FHead := Swap(cHead_DataSend);
  nSend.FLen := Swap(cSize_Head_Send_DataEnd);
  nSend.FCardType := gCardItem.FCardType;
  nSend.FCommand := cCmd_DataEnd;
  nSend.FDevice := sFlag_BroadCast;

  with FDM do
  try
    FWaitCommand := nSend.FCommand;
    CPort1.ClearBuffer(True, True);
    Result := CPort1.Write(@nSend, cSize_Head_Send_DataEnd) =
                                   cSize_Head_Send_DataEnd;
    //xxxxx

    if not Result then
    begin
      nStr := '"����֡"���ݷ���ʧ��,�޷��رմ���ģʽ!!';
      StrPCopy(nMsg, nStr); Exit;
    end;

    Result := WaitForTimeOut(nStr);
    if not Result then
    begin
      nStr := '�ȴ�"����֡"��Ӧ��ʱ,�޷��رմ���ģʽ!!';
      StrPCopy(nMsg, nStr); Exit;
    end;

    Move(FDM.FValidBuffer[0], nRespond, cSize_Head_Respond_DataEnd);
    Result := nRespond.FFlag = sFlag_OK;

    if Result then
    begin
      nStr := '�رմ���ģʽ,���ݷ������!';
      StrPCopy(nMsg, nStr);
    end else
    begin
      nStr := '"����֡"���ͳɹ�,����λ���رմ���ģʽʧ��!!';
      StrPCopy(nMsg, nStr);
    end;
  except
    StrPCopy(nMsg, '�޷��رմ���ģʽ');
  end;
end;

//------------------------------------------------------------------------------
procedure TFDM.DataModuleCreate(Sender: TObject);
begin
  //nothing
end;

procedure TFDM.DataModuleDestroy(Sender: TObject);
begin
  CPort1.Close;
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

//Desc: ��ȡ����
procedure TFDM.CPort1RxChar(Sender: TObject; Count: Integer);
var nBuf: array of Char;
begin
  SetLength(nBuf, Count);
  CPort1.Read(@nBuf[0], Count);
  CommReceiveData(@nBuf[0], Count);
end;

//Date: 2010-7-21
//Parm: ����;��С
//Desc: �����ܵ�������
procedure TFDM.CommReceiveData(const nBuf: PChar; const nBufLen: Word);
var nLen: integer;
    i,nCount: integer;
    nBase: THead_Respond_Base;
begin
  nLen := Length(FBuffer);
  SetLength(FBuffer, nLen + nBufLen);
  Move(nBuf^, FBuffer[nLen], nBufLen);

  nCount := High(FBuffer) - cSize_Respond_Base;
  //��������Э��ͷ�ĳ���

  for i:=Low(FBuffer) to nCount do
  if (FBuffer[i] = cHead_DataRecv_Hi) and (FBuffer[i+1] = cHead_DataRecv_Low) then
  begin
    Move(FBuffer[i], nBase, cSize_Respond_Base);
    //ȡ����Э��ͷ

    case nBase.FCommand of
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

initialization
  //FDM := TFDM.Create(nil);
  Application.CreateForm(TFDM, FDM);
finalization
  FDM.Free;
end.
