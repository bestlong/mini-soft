{*******************************************************************************
  ����: dmzn@163.com 2009-11-10
  ����: ��������
*******************************************************************************}
unit UFormSendData;

{$I Link.inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ULibFun, UDataModule, USysConst, UProtocol, UMovedItems, UMovedControl,
  UFormWait, UFormTextEditor, UFormSetWH, UFormConnTest, GIFImage, UFormBorder,
  UMgrLang, UMgrFontSmooth, UBoderControl, ComCtrls, StdCtrls;

type
  TfFormSendData = class(TForm)
    GroupBox1: TGroupBox;
    BtnSend: TButton;
    BtnExit: TButton;
    Label2: TLabel;
    EditDevice: TComboBox;
    Label1: TLabel;
    ListItems: TListView;
    Check1: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnExitClick(Sender: TObject);
    procedure BtnSendClick(Sender: TObject);
  private
    { Private declarations }
    FScreen: PScreenItem;
    //��Ļ����
    FItemList: TList;
    //����б�
    procedure InitFormData;
    //��ʼ������
    procedure OnTrans(const nItem: TComponent; var nNext: Boolean);
    //����
  public
    { Public declarations }
  end;

function ShowSendDataForm(const nScreen: PScreenItem;
  const nItems: TList): Boolean;
function SendDataToDevice(const nScreen: PScreenItem; const nDevice: Integer;
  const nItems: TList): Boolean;
function ReadDeviceStatus(const nScreen: PScreenItem; const nDevice: Integer;
  var nStatus: THead_Respond_ReadStatus; var nHint: string): Boolean;
//��ں���

var
  gIsSending: Boolean = False;
  //������
  gNeedAdjustWH: Boolean = False;
  //��У�����

implementation

{$R *.dfm}

type
  TPictureDataItem = record
    FData: PPictureData;
    FBuffer: TDynamicBitmapArray;
  end;

const
  cThreshole_Red   = 32;
  cThreshole_Green = 32;
  cThreshole_Blue  = 32; //��ɫ��ֵ

var
  gInvertScan: Boolean = False;
  //����ɨ��

//------------------------------------------------------------------------------
//Date: 2009-11-18
//Parm: ��Ļ����;����б�
//Desc: ��nScreen����nItems�б�ָ�����������
function ShowSendDataForm(const nScreen: PScreenItem;
  const nItems: TList): Boolean;
begin
  with TfFormSendData.Create(Application) do
  begin
    Caption := ML('��������');
    FItemList := nItems;
    FScreen := nScreen;

    InitFormData;
    Result := ShowModal = mrOk;
    Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormSendData.FormCreate(Sender: TObject);
begin
  LoadFormConfig(Self);
  gMultiLangManager.SectionID := Name;

  gMultiLangManager.OnTransItem := OnTrans;
  gMultiLangManager.TranslateAllCtrl(Self);
  gMultiLangManager.OnTransItem := nil;  
end;

procedure TfFormSendData.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if gIsSending then
       Action := caNone
  else SaveFormConfig(Self);
end;

procedure TfFormSendData.BtnExitClick(Sender: TObject);
begin
  Close;
end;

//Desc: ����
procedure TfFormSendData.OnTrans(const nItem: TComponent; var nNext: Boolean);
var nIdx: Integer;
begin
  if nItem = ListItems then
  begin
    nNext := False;
    for nIdx:=ListItems.Columns.Count - 1 downto 0 do
      ListItems.Columns[nIdx].Caption := ML(ListItems.Columns[nIdx].Caption);
    //xxxxx
  end;
end;

//------------------------------------------------------------------------------
//Desc: ��ʼ������
procedure TfFormSendData.InitFormData;
var nStr: string;
    nIdx: integer;
    nItem: PMovedItemData;
begin
  Check1.Checked := gInvertScan;
  EditDevice.Clear;
  EditDevice.Items.Add(ML('ȫ���豸'));
  
  for nIdx:=Low(FScreen.FDevice) to High(FScreen.FDevice) do
  begin
    nStr := Format('%d-%s', [FScreen.FDevice[nIdx].FID, FScreen.FDevice[nIdx].FName]);
    EditDevice.Items.Add(nStr);
  end;

  EditDevice.ItemIndex := 0;
  ListItems.Items.Clear;

  for nIdx:=0 to FItemList.Count - 1 do
  with ListItems.Items.Add do
  begin
    nItem := FItemList[nIdx];
    Caption := IntToStr(nIdx);
    SubItems.Add(TZnMovedControl(nItem.FItem).ShortName);
  end;
end;

//Desc: ��������
procedure TfFormSendData.BtnSendClick(Sender: TObject);
begin
  ShowWaitForm(ML('���ݷ�����'));
  try
    gInvertScan := Check1.Checked;
    BtnSend.Enabled := False;

    if SendDataToDevice(FScreen, EditDevice.ItemIndex - 1, FItemList) then
    begin
      ModalResult := mrOk;
      ShowMsg(ML('���ͳɹ�'), sHint);
    end;
  finally
    CloseWaitForm;
    BtnSend.Enabled := True;
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

//------------------------------------------------------------------------------
//Desc: �ϲ�nS���ݵ�nD��
procedure CombinByteArray(var nS,nD: TDynamicByteArray);
var nInt,nLen: integer;
begin
  nInt := Length(nS);
  nLen := Length(nD);
  
  SetLength(nD, nInt + nLen);
  Move(nS[Low(nS)], nD[nLen], nInt);
end;

//Desc: ����nColor���Ƿ���nFix��ɫ����
function HasFixColor(const nFix,nColor: TColor): Boolean;
var nVal: Byte;
begin
  case nFix of
   clRed:
    begin
      nVal := GetRValue(nColor);
      Result := nVal >= cThreshole_Red;
    end;
   clGreen:
    begin
      nVal := GetGValue(nColor);
      Result := nVal >= cThreshole_Green;
    end;
   clBlue:
    begin
      nVal := GetBValue(nColor);
      Result := nVal >= cThreshole_Blue;
    end else
    begin
      Result := False; Exit;
    end;
  end;
end;

//Desc: ʹ�õ�ɫ����ɨ��nBmp,����nData������
procedure ScanWithSingleMode(const nBmp: TBitmap; const nBgColor: TColor;
 var nData: TDynamicByteArray);
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
      if nBmp.Canvas.Pixels[nX, nY] = nBgColor then
           nBuf[nX + 1] := '1'
      else nBuf[nX + 1] := '0';

      if gInvertScan then
       if nBuf[nX + 1] = '0' then
            nBuf[nX + 1] := '1'
       else nBuf[nX + 1] := '0';
    end;

    MakeByteArray(nBuf, nBits);
    CombinByteArray(nBits, nData);
  end;
end;

//Desc: ʹ��˫ɫ����ɨ��nBmp,����nData������
procedure ScanWithDoubleMode(const nBmp: TBitmap; var nData: TDynamicByteArray);
var nX,nY: integer;
    nColor: Integer;
    nSR,nSG: string;
    nBits: TDynamicByteArray;
begin
  SetLength(nData, 0);
  SetLength(nSR, nBmp.Width);
  SetLength(nSG, nBmp.Width);

  for nY :=0 to nBmp.Height - 1 do
  begin
    for nX:=0 to nBmp.Width - 1 do
    begin
      nColor := ColorToRGB(nBmp.Canvas.Pixels[nX, nY]);
      if HasFixColor(clRed, nColor) then
           nSR[nX + 1] := '0'
      else nSR[nX + 1] := '1';

      if HasFixColor(clGreen, nColor) then
           nSG[nX + 1] := '0'
      else nSG[nX + 1] := '1';

      if gInvertScan then
       if nSR[nX + 1] = '0' then
            nSR[nX + 1] := '1'
       else nSR[nX + 1] := '0';

      if gInvertScan then
       if nSG[nX + 1] = '0' then
            nSG[nX + 1] := '1'
       else nSG[nX + 1] := '0';
    end;

    MakeByteArray(nSR, nBits);
    CombinByteArray(nBits, nData);

    MakeByteArray(nSG, nBits);
    CombinByteArray(nBits, nData);
  end;
end;

//Desc: ʹ��ȫɫ����ɨ��nBmp,����nData������
procedure ScanWithFullMode(const nBmp: TBitmap; var nData: TDynamicByteArray);
var nX,nY: integer;
    nColor: Integer;
    nSR,nSG,nSB: string;
    nBits: TDynamicByteArray;
begin
  SetLength(nData, 0);
  SetLength(nSR, nBmp.Width);
  SetLength(nSG, nBmp.Width);
  SetLength(nSB, nBmp.Width);

  for nY :=0 to nBmp.Height - 1 do
  begin
    for nX:=0 to nBmp.Width - 1 do
    begin
      nColor := ColorToRGB(nBmp.Canvas.Pixels[nX, nY]);
      if HasFixColor(clRed, nColor) then
           nSR[nX + 1] := '0'
      else nSR[nX + 1] := '1';

      if HasFixColor(clGreen, nColor) then
           nSG[nX + 1] := '0'
      else nSG[nX + 1] := '1';

      if HasFixColor(clBlue, nColor) then
           nSB[nX + 1] := '0'
      else nSB[nX + 1] := '1';

      if gInvertScan then
       if nSR[nX + 1] = '0' then
            nSR[nX + 1] := '1'
       else nSR[nX + 1] := '0';

      if gInvertScan then
       if nSG[nX + 1] = '0' then
            nSG[nX + 1] := '1'
       else nSG[nX + 1] := '0';

      if gInvertScan then
       if nSB[nX + 1] = '0' then
            nSB[nX + 1] := '1'
       else nSB[nX + 1] := '0';
    end;

    MakeByteArray(nSR, nBits);
    CombinByteArray(nBits, nData);

    MakeByteArray(nSG, nBits);
    CombinByteArray(nBits, nData);

    MakeByteArray(nSB, nBits);
    CombinByteArray(nBits, nData);
  end;
end;

//------------------------------------------------------------------------------
//Desc: ��nBmp����nW,nH��С���,�������nData��.
function SplitPicture(const nBmp: TBitmap; const nW,nH: Integer;
 var nData: TDynamicBitmapArray): Boolean;
var nSR,nDR: TRect;
    nL,nT,nIdx: integer;
begin
  nT := 0;
  SetLength(nData, 0);    
  
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

  Result := Length(nData) > 0;
end;

//Desc: ɨ���ı����nItem������,��ͼƬ��ʽ����nData��
function BuildTextItemData(const nItem: PMovedItemData;
 var nData: TDynamicBitmapDataArray): Boolean;
var nText: string;
    nBmp: TBitmap;
    nTItem: TTextMovedItem;
    nBuf: TDynamicBitmapArray;
    i,nCount,nIdx,nW,nNum: Integer;
begin
  nTItem := TTextMovedItem(nItem.FItem);
  try
    nText := nTItem.Text;
    if not nTItem.SplitText then
    begin
      Result := True; Exit;
    end;

    nBmp := nil;
    SetLength(nData, 0);
    nCount := nTItem.Lines.Count - 1;

    for i:=0 to nCount do
    try
      nTItem.Text := nTItem.Lines[i];
      nBmp := TBitmap.Create;
      nBmp.Canvas.Font.Assign(nTItem.Font);

      nW := nBmp.Canvas.TextWidth(nTItem.Text);
      nNum := Trunc(nW / nTItem.Width);
      if nW mod nTItem.Width <> 0 then Inc(nNum);
      //����������һ��

      nBmp.Height := nTItem.Height;
      nBmp.Width := nTItem.Width * nNum;
      nTItem.DoPaint(nBmp.Canvas, Rect(0, 0, nBmp.Width, nBmp.Height));
      //��������
      
      if SplitPicture(nBmp, nTItem.Width, nTItem.Height, nBuf) then
      begin
        nIdx := Length(nData);
        nNum := nIdx + Length(nBuf);
        SetLength(nData, nNum);

        nW := 0;
        while nIdx < nNum do
        begin
          nData[nIdx].FBitmap := nBuf[nW];
          Inc(nW);
          
          nData[nIdx].FModeEnter := nTItem.ModeEnter;
          nData[nIdx].FModeExit := nTItem.ModeExit;
          nData[nIdx].FSpeedEnter := nTItem.SpeedEnter;
          nData[nIdx].FSpeedExit := nTItem.SpeedExit;
          nData[nIdx].FKeedTime := nTItem.KeedTime;
          nData[nIdx].FModeSerial := nTItem.ModeSerial; Inc(nIdx);
        end;
      end; //���ͼƬ
    finally
      nBmp.Free;
    end;

    Result := Length(nData) > 0;
    if not Result then
      raise Exception.Create('');
    nTItem.Text := nText;
  except
    Result := False;
    nTItem.Text := nText;

    nText := ML('ɨ�����[%s]ʱ��������,�޷�����ͼƬ����!!');
    ShowDlg(Format(nText, [nItem.FItem.ShortName]), sHint);
  end;
end;

//Desc: ��nItem��nPic������ɨ��ΪͼƬ��
function ScanPictureData(const nItem: TPictureMovedItem; const nPic: PPictureData;
 var nData: TDynamicBitmapArray): Boolean;
var nRect: TRect;
    nBmp: TPicture;
    nGif: TGIFImage;
    i,nCount,nLen: integer;
begin
  nBmp := nil;
  Result := False;

  if nPic.FType = ptPic then
  try
    nBmp := TPicture.Create;
    nBmp.LoadFromFile(nPic.FFile);

    if nBmp.Graphic is TGIFImage then
    begin
      nGif := TGIFImage(nBmp.Graphic);
      SetLength(nData, 0);

      nCount := nGif.Images.Count - 1;
      for i:=0 to nCount do
      begin
        nLen := Length(nData);
        SetLength(nData, nLen + 1);

        nData[nLen] := TBitmap.Create;
        nData[nLen].Width := nItem.Width;
        nData[nLen].Height := nItem.Height;

        nRect := Rect(0, 0, nItem.Width, nItem.Height);
        nData[nLen].Canvas.StretchDraw(nRect, nGif.Images[i].Bitmap);
      end;

      Result := Length(nData) > 0;
      Exit;
    end; //Gif����

    SetLength(nData, 1);
    nData[0] := TBitmap.Create;
    nData[0].Width := nItem.Width;
    nData[0].Height := nItem.Height;
    
    nRect := Rect(0, 0, nItem.Width, nItem.Height);
    nData[0].Canvas.StretchDraw(nRect, nBmp.Graphic);

    Result := True;
    Exit;
    //ͼƬɨ�����
  finally
    if Assigned(nBmp) then nBmp.Free;
  end;

  if nPic.FType = ptText then
    Result := LoadFileToBitmap(nPic.FFile, nData, nItem.Width, nItem.Height,
                                False, nPic.FSingleLine);
  //ɨ���ı�
end;

//Desc: ɨ��ͼ�����nItem������,��ͼƬ��ʽ����nData��
function BuildPictureItemData(const nItem: PMovedItemData;
 var nData: TDynamicBitmapDataArray): Boolean;
var nStr: string;
    nPic: PPictureData;
    nPItem: TPictureMovedItem;
    nBuf: TDynamicBitmapArray;
    i,nCount,nIdx,nLen,nNum: Integer;
begin
  nPItem := TPictureMovedItem(nItem.FItem);
  try
    SetLength(nData, 0);
    nCount := nPItem.DataList.Count - 1;

    if nCount < 0 then
    begin
      Result := True; Exit;
    end;

    for i:=0 to nCount do
    begin
      nPic := nPItem.DataList[i];
      if not ScanPictureData(nPItem, nPic, nBuf) then Continue;

      nIdx := Length(nData);
      nLen := nIdx + Length(nBuf);
      SetLength(nData, nLen);

      nNum := 0;
      while nIdx < nLen do
      begin
        nData[nIdx].FBitmap := nBuf[nNum];
        Inc(nNum);
          
        nData[nIdx].FModeEnter := nPic.FModeEnter;
        nData[nIdx].FModeExit := nPic.FModeExit;
        nData[nIdx].FSpeedEnter := nPic.FSpeedEnter;
        nData[nIdx].FSpeedExit := nPic.FSpeedExit;
        nData[nIdx].FKeedTime := nPic.FKeedTime;
        nData[nIdx].FModeSerial := nPic.FModeSerial; Inc(nIdx);
      end;
    end;
    
    Result := Length(nData) > 0;
    if not Result then
      raise Exception.Create('');
    //xxxxx
  except
    Result := False;
    nStr := ML('ɨ�����[%s]ʱ��������,�޷�����ͼƬ����!!');
    ShowDlg(Format(nStr, [nItem.FItem.ShortName]), sHint);
  end;
end;

//Desc: ɨ�趯�����nItem������,��ͼƬ��ʽ����nData��
function BuildAnimateItemData(const nItem: PMovedItemData;
 var nData: TDynamicBitmapDataArray): Boolean;
var nStr: string;
    nRect: TRect;
    nGif: TGIFImage;
    i,nCount,nLen: Integer;
    nAnimate: TAnimateMovedItem;
begin
  nGif := nil;
  SetLength(nData, 0);
  nAnimate := TAnimateMovedItem(nItem.FItem);
  try
    if not FileExists(nAnimate.ImageFile) then
    begin
      Result := True; Exit;
    end;

    nGif := TGIFImage.Create;
    nGif.LoadFromFile(nAnimate.ImageFile);
    nCount := nGif.Images.Count - 1;

    for i:=0 to nCount do
    begin
      nLen := Length(nData);
      SetLength(nData, nLen + 1);
      FillChar(nData[nLen], SizeOf(TBitmapDataItem), #0);

      nData[nLen].FBitmap := TBitmap.Create;
      nData[nLen].FBitmap.Width := nAnimate.Width;
      nData[nLen].FBitmap.Height := nAnimate.Height;

      nRect := Rect(0, 0, nAnimate.Width, nAnimate.Height);
      nData[nLen].FBitmap.Canvas.StretchDraw(nRect, nGif.Images[i].Bitmap);
    end;
    
    Result := Length(nData) > 0;
    if not Result then
      raise Exception.Create('');
    //xxxxx
  except
    nGif.Free;
    Result := False;
    
    nStr := ML('ɨ�����[%s]ʱ��������,�޷�����ͼƬ����!!');
    ShowDlg(Format(nStr, [nItem.FItem.ShortName]), sHint);
  end;
end;

//Desc: ����nDataͼƬ���ݵ���λ��
function SendPictureDataToDevice(nItem: PMovedItemData; nScreen: PScreenItem;
  nDevice: Integer; nData: TDynamicBitmapDataArray): Boolean;
var nStr: string;
    nCRC: Word;
    nIdx,nCount,nLen: integer;
    nBuf: TDynamicByteArray;
    nSend: THead_Send_PicData;
    nRespond: THead_Respond_PicData;
begin
  Result := True;
  FillChar(nSend, cSize_Head_Send_PicData, #0);

  nSend.FHead := Swap(cHead_DataSend); 
  nSend.FCardType := nScreen.FCard;
  nSend.FCommand := cCmd_SendPicData;

  if nDevice > -1 then
       nSend.FDevice := Swap(nScreen.FDevice[nDevice].FID)
  else nSend.FDevice := sFlag_BroadCast;

  nSend.FAllID := Swap(Length(nData));
  nSend.FLevel := nItem.FLevel;
  nSend.FIndexID := nItem.FTypeIdx;
  
  with nItem^ do
  begin
    nSend.FPosX := Swap(FPosX);
    nSend.FPosY := Swap(FPosY);
    nSend.FWidth := Swap(FWidth);
    nSend.FHeight := Swap(FHeight);
  end;

  try
    nCount := High(nData);
    for nIdx:=Low(nData) to nCount do
    begin
      nStr := ML('�������[ %s ]��[ %d ]Ļ����ʱʧ��!!');
      nStr := Format(nStr, [nItem.FItem.ShortName, nIdx]);

      case nScreen.FType of
        stSingle: ScanWithSingleMode(nData[nIdx].FBitmap, nItem.FItem.Color, nBuf);
        stDouble: ScanWithDoubleMode(nData[nIdx].FBitmap, nBuf);
        stFull: ScanWithFullMode(nData[nIdx].FBitmap, nBuf);
      end;

      nSend.FNowID := Swap(nIdx);
      nSend.FLen := Swap(Length(nBuf) + cSize_Head_Send_PicData + 2);
      //����Э������

      nSend.FMode[0] := nData[nIdx].FModeEnter;
      nSend.FMode[1] := nData[nIdx].FSpeedEnter;
      nSend.FMode[2] := nData[nIdx].FKeedTime;
      nSend.FMode[3] := nData[nIdx].FModeExit;
      nSend.FMode[4] := nData[nIdx].FSpeedExit;
      nSend.FMode[5] := nData[nIdx].FModeSerial;
      nSend.FMode[6] := Ord(nScreen.FType) + 1;
      //���ģʽ

      nStr := '�������[ %s ]��[ %d ]Ļ����ʱʧ��!!';
      nStr := Format(nStr, [nItem.FItem.ShortName, nIdx]);
      FDM.FWaitCommand := nSend.FCommand;
      Result := FDM.Comm1.WriteCommData(@nSend, cSize_Head_Send_PicData);

      if Result then
      begin
        nLen := Length(nBuf);
        FDM.SetWaitTime(nLen);
        Result := FDM.Comm1.WriteCommData(@nBuf[Low(nBuf)], nLen);
      end;
      //ͼƬ����

      if Result then
      begin
        nCRC := 0;
        Result := FDM.Comm1.WriteCommData(@nCRC, SizeOf(nCRC));
      end;
      //У��λ
      if not Result then Break;

      Result := FDM.WaitForTimeOut(nStr);
      if not Result then
      begin
        nStr := ML('�������[ %s ]��[ %d ]Ļ����ʱ��λ������Ӧ!!');
        nStr := Format(nStr, [nItem.FItem.ShortName, nIdx]); Break;
      end;

      nStr := ML('���[ %s ]��[ %d ]Ļ�����ѳɹ�����,����λ�������쳣!!');
      nStr := Format(nStr, [nItem.FItem.ShortName, nIdx]);
      Move(FDM.FValidBuffer[0], nRespond, cSize_Head_Respond_PicData);
      
      Result := nRespond.FFlag = sFlag_OK;
      if Result then
      begin
        nStr := ML('��.�������[ %s ]��[ %d/%d ]Ļ���ݳɹ�!!');
        nStr := Format(nStr, [nItem.FItem.ShortName, nIdx, nCount]);
        ShowMsgOnLastPanelOfStatusBar(nStr);
      end else Break;
    end;
  except
    //ignor any Error
  end;

  if not Result then
    ShowDlg(nStr, sHint);
  //xxxxx
end;

//Desc: ����nData�������ݵ���λ��
function SendAnimateDataToDevice(nItem: PMovedItemData; nScreen: PScreenItem;
  nDevice: Integer; nData: TDynamicBitmapDataArray): Boolean;
var nStr: string;
    nCRC: Word;
    nIdx,nCount,nLen: integer;
    nBuf: TDynamicByteArray;
    nSend: THead_Send_Animate;
    nRespond: THead_Respond_Animate;
begin
  Result := True;
  FillChar(nSend, cSize_Head_Send_Animate, #0);

  nSend.FHead := Swap(cHead_DataSend); 
  nSend.FCardType := nScreen.FCard;
  nSend.FCommand := cCmd_SendAnimate;

  if nDevice > -1 then
       nSend.FDevice := Swap(nScreen.FDevice[nDevice].FID)
  else nSend.FDevice := sFlag_BroadCast;
  
  nSend.FAllID := Swap(Length(nData));
  nSend.FLevel := nItem.FLevel;
  nSend.FIndexID := nItem.FTypeIdx;
  nSend.FSpeed := TAnimateMovedItem(nItem.FItem).Speed;
  
  with nItem^ do
  begin
    nSend.FPosX := Swap(FPosX);
    nSend.FPosY := Swap(FPosY);
    nSend.FWidth := Swap(FWidth);
    nSend.FHeight := Swap(FHeight);
  end;

  try
    nCount := High(nData);
    for nIdx:=Low(nData) to nCount do
    begin
      nStr := ML('�������[ %s ]��[ %d ]Ļ����ʱʧ��!!');
      nStr := Format(nStr, [nItem.FItem.ShortName, nIdx]);

      case nScreen.FType of
        stSingle: ScanWithSingleMode(nData[nIdx].FBitmap, nItem.FItem.Color, nBuf);
        stDouble: ScanWithDoubleMode(nData[nIdx].FBitmap, nBuf);
        stFull: ScanWithFullMode(nData[nIdx].FBitmap, nBuf);
      end;

      nSend.FNowID := Swap(nIdx);
      nSend.FLen := Swap(Length(nBuf) + cSize_Head_Send_Animate + 2);
      //����Э������

      nStr := ML('�������[ %s ]��[ %d ]Ļ����ʱʧ��!!');
      nStr := Format(nStr, [nItem.FItem.ShortName, nIdx]);
      FDM.FWaitCommand := nSend.FCommand;
      Result := FDM.Comm1.WriteCommData(@nSend, cSize_Head_Send_Animate);

      if Result then
      begin
        nLen := Length(nBuf);
        FDM.SetWaitTime(nLen);
        Result := FDM.Comm1.WriteCommData(@nBuf[Low(nBuf)], nLen);
      end;
      //ͼƬ����

      if Result then
      begin
        nCRC := 0;
        Result := FDM.Comm1.WriteCommData(@nCRC, SizeOf(nCRC));
      end;
      //У��λ
      if not Result then Break;

      Result := FDM.WaitForTimeOut(nStr);
      if not Result then
      begin
        nStr := ML('�������[ %s ]��[ %d ]Ļ����ʱ��λ������Ӧ!!');
        nStr := Format(nStr, [nItem.FItem.ShortName, nIdx]); Break;
      end;

      nStr := ML('���[ %s ]��[ %d ]Ļ�����ѳɹ�����,����λ�������쳣!!');
      nStr := Format(nStr, [nItem.FItem.ShortName, nIdx]);
      Move(FDM.FValidBuffer[0], nRespond, cSize_Head_Respond_Animate);
      
      Result := nRespond.FFlag = sFlag_OK;
      if Result then
      begin
        nStr := ML('��.���Ͷ���[ %s ]��[ %d/%d ]Ļ���ݳɹ�!!');
        nStr := Format(nStr, [nItem.FItem.ShortName, nIdx, nCount]);
        ShowMsgOnLastPanelOfStatusBar(nStr);
      end else Break;
    end;
  except
    //ignor any Error
  end;

  if not Result then
    ShowDlg(nStr, sHint);
  //xxxxx
end;

//Desc: ��ȡnColor��Ӧ������
function ColorOrder(const nColor: TColor): Byte;
begin
  case nColor of
   clRed: Result := 1;
   clGreen: Result := 2;
   clYellow: Result := 3 else Result := 1;
  end;
end;

//Desc: ����ģ��ʱ�ӵ���λ��
function SendClockItemToDevice(nItem: PMovedItemData; nScreen: PScreenItem;
  nDevice: Integer): Boolean;
var nStr: string;
    nCRC: Word;
    nBmp: TBitmap;
    nLen: Integer;
    nCItem: TClockMovedItem;
    nSend: THead_Send_Clock;
    nBuf: TDynamicByteArray;
    nRespond: THead_Respond_Clock;
begin
  Result := True;
  nCItem := TClockMovedItem(nItem.FItem);
  FillChar(nSend, cSize_Head_Send_Clock, #0);

  nSend.FHead := Swap(cHead_DataSend);
  nSend.FCardType := nScreen.FCard;
  
  if nDevice > -1 then
       nSend.FDevice := Swap(nScreen.FDevice[nDevice].FID)
  else nSend.FDevice := sFlag_BroadCast;

  nSend.FCommand := cCmd_SendSimuClock;
  nSend.FLevel := nItem.FLevel;
  nSend.FIndexID := nItem.FTypeIdx;

  with nItem^ do
  begin
    nSend.FPosX := Swap(FPosX);
    nSend.FPosY := Swap(FPosY);
    nSend.FWidth := Swap(FWidth);
    nSend.FHeight := Swap(FHeight);
  end;

  nSend.FParam := Swap($12);
  nSend.FPointX := Swap(nCItem.DotPoint.X);
  nSend.FPointY := Swap(nCItem.DotPoint.Y);
  nSend.FZhenColor[0] := ColorOrder(nCItem.ColorHour);
  nSend.FZhenColor[1] := ColorOrder(nCItem.ColorMin);
  nSend.FZhenColor[2] := ColorOrder(nCItem.ColorSec);

  try
    nBmp := nil;
    SetLength(nBuf, 0);

    if Assigned(nCItem.Image.Graphic) then
    try
      nBmp := TBitmap.Create;
      nBmp.Width := nCItem.Width;
      nBmp.Height := nCItem.Height;
      nBmp.Canvas.StretchDraw(nCItem.ClientRect, nCItem.Image.Graphic);

      case nScreen.FType of
        stSingle: ScanWithSingleMode(nBmp, nItem.FItem.Color, nBuf);
        stDouble: ScanWithDoubleMode(nBmp, nBuf);
        stFull: ScanWithFullMode(nBmp, nBuf);
      end;
    finally
      nBmp.Free;
    end;

    nStr := ML('�������[ %s ]��[ %d ]Ļ����ʱʧ��!!');
    nSend.FParam := Swap(Length(nBuf) + 8);
    nSend.FLen := Swap(cSize_Head_Send_Clock + Length(nBuf) + 2);

    FDM.FWaitCommand := nSend.FCommand;
    Result := FDM.Comm1.WriteCommData(@nSend, cSize_Head_Send_Clock);

    if Result and (Length(nBuf) > 0) then
    begin
      nLen := Length(nBuf);
      FDM.SetWaitTime(nLen);
      Result := FDM.Comm1.WriteCommData(@nBuf[Low(nBuf)], nLen);
    end;
    //ͼƬ����

    if Result then
    begin
      nCRC := 0;
      Result := FDM.Comm1.WriteCommData(@nCRC, SizeOf(nCRC));
    end;
    //У��λ
    
    if not Result then
      raise Exception.Create('');
    //xxxxx

    Result :=  FDM.WaitForTimeOut(nStr);
    if not Result then
    begin
      nStr := ML('�������[ %s ]ʱ��λ������Ӧ!!');
      nStr := Format(nStr, [nItem.FItem.ShortName]);
      raise Exception.Create('');
    end;

    Move(FDM.FValidBuffer[0], nRespond, cSize_Head_Respond_Clock);
    Result := nRespond.FFlag = sFlag_OK;

    if not Result then
    begin
      nStr := ML('���[ %s ]�����ѳɹ�����,����λ�������쳣!!');
      nStr := Format(nStr, [nItem.FItem.ShortName]);
      raise Exception.Create('');
    end;
  except
    //ignor any Error
  end;

  if not Result then
    ShowDlg(nStr, sHint);
  //xxxxx
end;

//Desc: ��������ʱ�ӵ���λ��
function SendTimeItemToDevice(nItem: PMovedItemData; nScreen: PScreenItem;
  nDevice: Integer): Boolean;
var nStr: string;
    nTItem: TTimeMovedItem;
    nSend: THead_Send_AreaTime;
    nRespond: THead_Respond_AreaTime;
begin
  Result := True;
  nTItem := TTimeMovedItem(nItem.FItem);
  FillChar(nSend, cSize_Head_Send_AreaTime, #0);

  nSend.FHead := Swap(cHead_DataSend);
  nSend.FCardType := nScreen.FCard;
  nSend.FLen := Swap(cSize_Head_Send_AreaTime);

  if nDevice > -1 then
       nSend.FDevice := Swap(nScreen.FDevice[nDevice].FID)
  else nSend.FDevice := sFlag_BroadCast;

  nSend.FCommand := cCmd_SendAreaTime;
  nSend.FLevel := nItem.FLevel;
  nSend.FIndexID := nItem.FTypeIdx;

  with nItem^ do
  begin
    nSend.FPosX := Swap(FPosX);
    nSend.FPosY := Swap(FPosY);
    nSend.FWidth := Swap(FWidth);
    nSend.FHeight := Swap(FHeight);
  end;

  nSend.FParam := Swap($12);
  nSend.FModeChar := nTItem.ModeChar;
  nSend.FModeLine := nTItem.ModeLine;
  nSend.FModeDate := nTItem.ModeDate;
  nSend.FModeWeek := nTItem.ModeWeek;
  nSend.FModeTime := nTItem.ModeTime;
  
  try
    FDM.FWaitCommand := nSend.FCommand;
    FDM.Comm1.WriteCommData(@nSend, cSize_Head_Send_AreaTime);

    Result :=  FDM.WaitForTimeOut(nStr);
    begin
      nStr := '�������[ %s ]ʱ��λ������Ӧ!!';
      nStr := Format(nStr, [nItem.FItem.ShortName]);
    end;

    Move(FDM.FValidBuffer[0], nRespond, cSize_Head_Respond_AreaTime);
    Result := nRespond.FFlag = sFlag_OK;

    if not Result then
    begin
      nStr := ML('���[ %s ]�����ѳɹ�����,����λ�������쳣!!');
      nStr := Format(nStr, [nItem.FItem.ShortName]);
    end;
  except
    //ignor any Error
  end;

  if not Result then
    ShowDlg(nStr, sHint);
  //xxxxx
end;

//Desc: ����nItem�����ݵ���λ��
function SendItemData(nItem: PMovedItemData; nScreen: PScreenItem;
  nDevice: integer): Boolean;
var nIdx: integer;
    nReverse: Boolean;
    nData: TDynamicBitmapDataArray;
begin
  nReverse := gInvertScan;
  SetLength(nData, 0);
  try
    if nItem.FItem is TTextMovedItem then
    begin
      Result := BuildTextItemData(nItem, nData);
      //ɨ������
      if Result then
        Result := SendPictureDataToDevice(nItem, nScreen, nDevice, nData);
      //��������
    end else

    if nItem.FItem  is TPictureMovedItem then
    begin
      Result := BuildPictureItemData(nItem, nData);
      //ɨ������
      if Result then
        Result := SendPictureDataToDevice(nItem, nScreen, nDevice, nData);
      //ͼ�Ļ���
    end else

    if nItem.FItem is TAnimateMovedItem then
    begin
      gInvertScan := TAnimateMovedItem(nItem.FItem).Reverse;
      //�л�ɨ��ģʽ
      
      Result := BuildAnimateItemData(nItem, nData);
      //ɨ������
      if Result then
        Result := SendAnimateDataToDevice(nItem, nScreen, nDevice, nData);
      //����
    end else

    if nItem.FItem is TClockMovedItem then
    begin
      Result := SendClockItemToDevice(nItem, nScreen, nDevice);
      //ģ��ʱ��
    end else

    if nItem.FItem is TTimeMovedItem then
    begin
      Result := SendTimeItemToDevice(nItem, nScreen, nDevice);
      //ʱ�����
    end else Result := False;
  finally
    gInvertScan := nReverse;
    for nIdx:=Low(nData) to High(nData) do
      nData[nIdx].FBitmap.Free;
    //xxxxx
  end;
end;

//Desc: ����"���ݴ��俪ʼ֡"
function OpenSendData(nScreen: PScreenItem; nDevice,nAreaNum: Integer): Boolean;
var nStr: string;
    nData: THead_Send_DataBegin;
    nRespond: THead_Respond_DataBegin;
begin
  {$IFDEF VCom}
  Result := True; Exit;
  {$ENDIF}

  Result := False;
  FillChar(nData, cSize_Head_Send_DataBegin, #0);

  nData.FHead := Swap(cHead_DataSend);
  nData.FLen := Swap(cSize_Head_Send_DataBegin);
  nData.FCardType := nScreen.FCard;
  nData.FColorType := Ord(nScreen.FType) + 1;

  if nDevice > -1 then
       nData.FDevice := Swap(nScreen.FDevice[nDevice].FID)
  else nData.FDevice := sFlag_BroadCast;
  
  nData.FAreaNum := nAreaNum;
  nData.FCommand := cCmd_DataBegin;  

  with FDM do
  try
    FWaitCommand := nData.FCommand;
    Result := Comm1.WriteCommData(@nData, cSize_Head_Send_DataBegin);

    if not Result then
    begin
      nStr := ML('"��ʼ֡"���ݷ���ʧ��,�޷��򿪴���ģʽ!!');
      ShowDlg(nStr, sHint);  Exit;
    end;

    Result := WaitForTimeOut(nStr);
    if not Result then
    begin
      nStr := ML('�ȴ�"��ʼ֡"��Ӧ��ʱ,�޷��򿪴���ģʽ!!');
      ShowDlg(nStr, sHint);  Exit;
    end;

    Move(FDM.FValidBuffer[0], nRespond, cSize_Head_Respond_DataBegin);
    Result := nRespond.FFlag = sFlag_OK;

    if Result then
    begin
      nStr := ML('��.�򿪴���ģʽ,��ʼ��������!');
      ShowMsgOnLastPanelOfStatusBar(nStr);
    end else
    begin
      nStr := ML('"��ʼ֡"���ͳɹ�,����λ���򿪴���ģʽʧ��!!');
      ShowDlg(nStr, sHint);  Exit;
    end;
  except
    ShowMsg(ML('�޷��򿪴���ģʽ'), sHint);
  end;
end;

//Desc: ����"���ݴ������֡"
function CloseSendData(nScreen: PScreenItem; nDevice: Integer): Boolean;
var nStr: string;
    nSend: THead_Send_DataEnd;
    nRespond: THead_Respond_DataEnd;
begin
  {$IFDEF VCom}
  Result := True; Exit;
  {$ENDIF}
  
  Result := False;
  FillChar(nSend, cSize_Head_Send_DataEnd, #0);

  nSend.FHead := Swap(cHead_DataSend);
  nSend.FLen := Swap(cSize_Head_Send_DataEnd);
  nSend.FCardType := nScreen.FCard;
  nSend.FCommand := cCmd_DataEnd;

  if nDevice > -1 then
       nSend.FDevice := Swap(nScreen.FDevice[nDevice].FID)
  else nSend.FDevice := sFlag_BroadCast;

  with FDM do
  try
    FWaitCommand := nSend.FCommand;
    Result := Comm1.WriteCommData(@nSend, cSize_Head_Send_DataEnd);

    if not Result then
    begin
      nStr := ML('"����֡"���ݷ���ʧ��,�޷��رմ���ģʽ!!');
      ShowDlg(nStr, sHint);  Exit;
    end;

    Result := WaitForTimeOut(nStr);
    if not Result then
    begin
      nStr := ML('�ȴ�"����֡"��Ӧ��ʱ,�޷��رմ���ģʽ!!');
      ShowDlg(nStr, sHint);  Exit;
    end;

    Move(FDM.FValidBuffer[0], nRespond, cSize_Head_Respond_DataEnd);
    Result := nRespond.FFlag = sFlag_OK;

    if Result then
    begin
      nStr := ML('��.�رմ���ģʽ,���ݷ������!');
      ShowMsgOnLastPanelOfStatusBar(nStr);
    end else
    begin
      nStr := ML('"����֡"���ͳɹ�,����λ���رմ���ģʽʧ��!!');
      ShowDlg(nStr, sHint);  Exit;
    end;
  except
    ShowMsg(ML('�޷��رմ���ģʽ'), sHint);
  end;
end;

//Date: 2009-12-06
//Parm: ��Ļ;�豸����
//Desc: ��nDevice>0ʱ,ͬ��nScreen.nDevice�Ŀ��.
function AdjustScreenWH(const nScreen: PScreenItem; nDevice: Integer): Boolean;
var nStr: string;
    nData: THead_Respond_ConnCtrl;
begin
  if (nDevice < 0) and (not gNeedAdjustWH) then
  begin
    Result := True; Exit;
  end;

  Result := ConnectCtrl(nScreen, nDevice, nData, nStr, True);
  if not Result  then
  begin
    ShowMsg(nStr, sHint); Exit;
  end;

  if nData.FCardType <> nScreen.FCard then
  begin
    Result := False;
    ShowWaitForm('', False);

    nStr := '��ǰ��Ļ���������������һ��,������ȡ��!!' + #13#10 +
            '����"��������"�˵����޸Ŀ�����.';
    ShowDlg(ML(nStr), sHint); Exit;
  end;

  if (nData.FScreen[0] * 8 = nScreen.FLenY) and
     (nData.FScreen[1] * 8 = nScreen.FLenX) then Exit;

  ShowWaitForm('', False);
  try
    nStr := '��ǰ��Ļ�ߴ����������һ��,��Ӱ�����ݵ���ʾ.' + #13#10 +
            '�Ƿ�ͬ����Ļ�ߴ�? ѡ��"��"����������.';
    if not QueryDlg(ML(nStr), sAsk) then Exit;
  finally
    ShowWaitForm('', True);
  end;

  Result := SetDeviceWH(nScreen, nDevice, nScreen.FLenX, nScreen.FLenY, nStr);
  if not Result then ShowMsg(nStr, sHint);
end;

//Date: 2009-11-23
//Parm: ��Ļ����;�豸����;����б�
//Desc: ��nScreen.nDevice����nItems�б�ָ�����������
function SendDataToDevice(const nScreen: PScreenItem; const nDevice: Integer;
  const nItems: TList): Boolean;
var nStr: string;
    nPCtrl: TObject;
    i,nCount: integer;
begin
  Result := False;
  gMultiLangManager.SectionID := sMLSend;

  i := CardItemIndex(nScreen.FCard);
  if (i > -1) and (nItems.Count > cCardList[i].FLimite) then
  begin
    ShowWaitForm('', False);
    nStr := '������������Ϊ[ %d ],�ѳ������տ�[ %d ]����������!' + #13#10#13#10 +
            '���ܻᵼ�½��տ������쳣,�Ƿ��������?';
    nStr := Format(ML(nStr), [nItems.Count, cCardList[i].FLimite]);

    if QueryDlg(nStr, sAsk) then
         ShowWaitForm('', True)
    else Exit;
  end;

  with FDM do
  try
    gIsSending := True;
    try
      Comm1.StopComm;
      Comm1.CommName := nScreen.FPort;
      Comm1.BaudRate := nScreen.FBote;

      {$IFNDEF VCom}
      Comm1.StartComm;
      Sleep(500);
      {$ENDIF}

      if not AdjustScreenWH(nScreen, nDevice) then Exit;
      //�������
      if not OpenSendData(nScreen, nDevice, nItems.Count) then Exit;
      //�޷���������ģʽ

      gSmoothSwitcher.CloseSmooth;
      //�ر�ƽ������
      gSendInterval := cSendInterval_Long;
      nCount := nItems.Count - 1;

      for i:=0 to nCount do
      try
        nStr := ML('��.���ڷ������[ %s ]������...');
        nStr := Format(nStr, [PMovedItemData(nItems[i]).FItem.ShortName]);
        ShowMsgOnLastPanelOfStatusBar(nStr);

        Result := SendItemData(nItems[i], nScreen, nDevice);
        if not Result then Break;
      except
        //ignor any error
      end;

      if not CloseSendData(nScreen, nDevice) then
        Result := False;
      //xxxxx

      nPCtrl := PMovedItemData(nItems[0]).FItem.Owner;
      if not SendBorderToDevice(nScreen, nDevice, TZnBorderControl(nPCtrl), nStr) then
      begin
        Result := False;
        ShowDlg(nStr, sError);
      end; //���ͱ߿�
    finally
      gIsSending := False;
      gSendInterval := cSendInterval_Short;
      gSmoothSwitcher.OpenSmooth;
      
      Comm1.StopComm;
      ShowMsgOnLastPanelOfStatusBar(ML(sCorConcept, sMLMain));      
    end;
  except
    ShowMsg(ML('�������ͨ��ʧ��'), sHint);
  end;
end;

//Date: 2009-12-06
//Parm: ��Ļ;�豸���;״̬;��Ϣ��ʾ
//Desc: ��ȡnScreen.nDevice��״̬,����ǰ��Ҫ����Comm1.
function ReadDeviceStatus(const nScreen: PScreenItem; const nDevice: Integer;
  var nStatus: THead_Respond_ReadStatus; var nHint: string): Boolean;
var nStr: string;
    nData: THead_Send_ReadStatus;
begin
  {$IFDEF VCom}
  Result := True; Exit;
  {$ENDIF}

  Result := False;
  FillChar(nData, cSize_Head_Send_ReadStatus, #0);

  nData.FHead := Swap(cHead_DataSend);
  nData.FLen := Swap(cSize_Head_Send_ReadStatus);
  nData.FCardType := nScreen.FCard;

  if nDevice > -1 then
       nData.FDevice := Swap(nScreen.FDevice[nDevice].FID)
  else nData.FDevice := sFlag_BroadCast;
  nData.FCommand := cCmd_ReadStatus;

  with FDM do
  try
    nHint := ML('����״̬��ѯ����ʧ��', sMLSend);
    FWaitCommand := nData.FCommand;

    Result := Comm1.WriteCommData(@nData, cSize_Head_Send_ReadStatus);
    if not Result then Exit;

    nHint := ML('״̬��ѯ������Ӧ��ʱ', sMLSend);
    Result := WaitForTimeOut(nStr);
    if not Result then Exit;

    Move(FDM.FValidBuffer[0], nStatus, cSize_Head_Respond_ReadStatus);
    Result := nStatus.FFlag = sFlag_OK;

    if Result then
         nHint := ''
    else nHint := ML('��ѯ������״̬ʧ��', sMLSend);
  except
    //ingnor any error
  end;
end;

end.
