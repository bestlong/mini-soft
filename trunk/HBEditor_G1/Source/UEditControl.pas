{*******************************************************************************
  ����: dmzn@163.com 2010-9-5
  ����: ���ݱ༭��
*******************************************************************************}
unit UEditControl;

interface

uses
  Windows, Forms, StdCtrls, Classes, Controls, SysUtils, Graphics;

type
  PBitmapDataItem = ^TBitmapDataItem;
  TBitmapDataItem = record
    FBitmap: TBitmap;
    //ͼƬ����
    FText: string;
    //�ı�����
    FFont: TFont;
    //������
    FVerAlign: Byte;
    FHorAlign: Byte;
    //����ģʽ
    FModeEnter: string[2];
    FModeExit: string[2];
    //������ģʽ
    FSpeedEnter: string[2];
    FSpeedExit: string[2];
    //�������ٶ�
    FKeedTime: string[2];
    FModeSerial: string[2];
    //ͣ��ʱ��,����ǰ��
  end;

  TDynamicBitmapArray = array of TBitmap;
  //ͼƬ����
  TDynamicBitmapDataArray = array of TBitmapDataItem;
  //ͼƬ��������

  TScrollMode = (smNormal, smHor, smVer);
  //��ĸ����ģʽ: ����,��ˮƽ,����ֱ

  THBEditControl = class(TGraphicControl)
  private
    FText: string;
    //�ı�
    FActiveData: PBitmapDataItem;
    FData: TList;
    //����
    FHasClock: Boolean;
    //��ʱ��
    FClockWidth: Word;
    //ʱ�ӿ��
    FNormalFont: TFont;
    //��������
    FWraper: TMemo;
    //���ж���
    FHideBlank: Boolean;
    //�����ո�
  protected
    procedure Paint; override;
    procedure PaintClock;
    //����
    function NewDataItem(var nIdx: Integer; const nList: TList): Boolean;
    //�½���������
    function TextWidth: Integer;
    //�ı������
    procedure WrapText(const nText: string; const nFont: TFont);
    //����ı�
    function HorPaint(var nBMPs: TDynamicBitmapArray): Boolean;
    function VerPaint(var nBMPs: TDynamicBitmapArray): Boolean;
    //���ض���;����
    function SplitData(const nList: TList; nData: TDynamicBitmapArray): Boolean;
    //�������
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //�����ͷ�
    procedure DeleteData(const nData: TList; const nIdx: Integer);
    procedure ClearData(const nData: TList; const nFree: Boolean = True;
      nForm: Integer = 0);
    //������Դ
    function SpitTextVer(const nData: TList): Boolean;
    function SpitTextHor(const nData: TList): Boolean;
    function SpitTextNormal(const nData: TList): Boolean;
    //����ı�
    procedure PaintData(const nValue: PBitmapDataItem);
    //�����ı�����
    procedure SetActiveData(const nValue: PBitmapDataItem;
     const nFocus: Boolean = False);
    //���û����
    function ScrollMode: TScrollMode;
    //����ģʽ
    property Data: TList read FData;
    property NormalFont: TFont read FNormalFont;
    property Text: string read FText write FText;  
    property ActiveData: PBitmapDataItem read FActiveData;
    property HasClock: Boolean read FHasClock write FHasClock;
    property HideBlank: Boolean read FHideBlank write FHideBlank;
  end;

implementation

uses
  IniFiles, ULibFun, UMgrLang, USysConst;
  
const
  cYes = '01';
  cNo  = '00';

  cWord = '00';
  cChar = '01';

//------------------------------------------------------------------------------
constructor THBEditControl.Create(AOwner: TComponent);
var nStr: string;
    nIni: TIniFile;
begin
  inherited;
  ParentFont := True;

  Width := 128;
  Height := 64;
  
  FText := '';
  FHasClock := False;
  HideBlank := False;

  FActiveData := nil;
  FData := TList.Create;  

  FWraper := TMemo.Create(AOwner);
  FWraper.Visible := False;
  
  FNormalFont := TFont.Create;
  FNormalFont.Assign(Font);
  FNormalFont.Color := clRed;

  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    nStr := nIni.ReadString('Editor', 'FontName', '');
    if nStr <> '' then FNormalFont.Name := nStr;

    nStr := nIni.ReadString('Editor', 'FontSize', '');
    if IsNumber(nStr, False) then FNormalFont.Size := StrToInt(nStr);
    if FNormalFont.Size < 9 then FNormalFont.Size := 9;

    nStr := nIni.ReadString('Editor', 'FontColor', '');
    if IsNumber(nStr, False) then FNormalFont.Color := StrToInt(nStr);
  finally
    nIni.Free;
  end;
end;

destructor THBEditControl.Destroy;
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    nIni.WriteString('Editor', 'FontName', FNormalFont.Name);
    nIni.WriteInteger('Editor', 'FontSize', FNormalFont.Size);
    nIni.WriteInteger('Editor', 'FontColor', FNormalFont.Color);
  finally
    nIni.Free;
    FNormalFont.Free;
  end;

  ClearData(FData);
  inherited;
end;

//Desc: ɾ��nData������ΪnIdx������
procedure THBEditControl.DeleteData(const nData: TList; const nIdx: Integer);
var nItem: PBitmapDataItem;
begin
  if (nIdx > -1) and (nIdx < nData.Count) then
  begin
    nItem := nData[nIdx];
    if nItem = FActiveData then
      FActiveData := nil;
    //xxxxx

    nItem.FBitmap.Free;
    nItem.FBitmap := nil;

    nItem.FFont.Free;
    nItem.FFont := nil;

    Dispose(nItem);
    nData.Delete(nIdx);
  end;
end;

//Date: 2010-9-8
//Parm: ����;�Ƿ��ͷ�;��ʼλ��
//Desc: ��nForm������ʼ�ͷ�nData�б��е�����
procedure THBEditControl.ClearData(const nData: TList; const nFree: Boolean;
 nForm: Integer);
var nIdx: Integer;
begin
  if (nForm < 0) or nFree then
    nForm := 0;
  //��������
  
  for nIdx:=nData.Count - 1 downto nForm do
    DeleteData(nData, nIdx);
  //xxxxx
  
  if nFree then
    nData.Free;
  //�ͷŶ���
end;

//Desc: ��Ч���ı������
function THBEditControl.TextWidth: Integer;
begin
  Result := Width - FClockWidth;
  if Result <= 0 then Result := 1;
end;

//Desc: ��nValue�������Զ�����
procedure THBEditControl.WrapText(const nText: string; const nFont: TFont);
begin
  FWraper.Parent := Self.Parent;
  FWraper.Width := TextWidth;
  FWraper.Height := Height * 3;
  
  FWraper.Font.Assign(nFont);
  Application.ProcessMessages;
  FWraper.Text := nText; 
end;

//Desc: ����nValue�����ݵ�nValue.FBitmap
procedure THBEditControl.PaintData(const nValue: PBitmapDataItem);
var nIdx,nLen: Integer;
    nL,nT,nW,nH: Integer;
begin
  with nValue^ do
  begin
    if not Assigned(FBitmap) then
      FBitmap := TBitmap.Create;
    FBitmap.Width := TextWidth;
    FBitmap.Height := Height;

    FBitmap.Canvas.Brush.Color := clBlack;
    FBitmap.Canvas.FillRect(Rect(0, 0, FBitmap.Width, FBitmap.Height));

    FBitmap.Canvas.Font.Assign(nValue.FFont);
    SetBkMode(FBitmap.Canvas.Handle, TRANSPARENT);
    
    WrapText(nValue.FText, nValue.FFont);
    nLen := FWraper.Lines.Count - 1;

    if nValue.FVerAlign = 0 then  //����
      nT := 0 else
    begin
      nH := 0;
      for nIdx:=0 to nLen do
        nH := nH + FBitmap.Canvas.TextHeight(FWraper.Lines[nIdx]);
      //�����ܸ߶�

      if nValue.FVerAlign = 1 then //����
           nT := Trunc((Height - nH) / 2)
      else nT := Height - nH;      //����
    end;

    for nIdx:=0 to nLen do
    begin
      if nValue.FHorAlign = 0 then
        nL := 0 else
      begin
        nW := FBitmap.Canvas.TextWidth(FWraper.Lines[nIdx]);
        //���п�

        if nValue.FHorAlign = 1 then //����
             nL := Trunc((Width - nW) / 2)
        else nL := Width - nW;       //����
      end;

      FBitmap.Canvas.TextOut(nL, nT, FWraper.Lines[nIdx]);
      nH := FBitmap.Canvas.TextHeight(FWraper.Lines[nIdx]);

      nT := nT + nH;
      if nT >= Height then Break;
    end;
  end;
end;


//Desc: ���û����
procedure THBEditControl.SetActiveData(const nValue: PBitmapDataItem;
 const nFocus: Boolean = False);
begin
  if (nValue = FActiveData) and (not nFocus) then Exit;
  //����Ҫ����

  if Assigned(nValue) then
    PaintData(nValue);
  //xxxxx

  FActiveData := nValue;
  Invalidate;
end;

procedure THBEditControl.Paint;
begin
  Canvas.Brush.Color := clBlack;
  Canvas.FillRect(ClientRect);

  FClockWidth := 0;
  if FHasClock then PaintClock;

  if Assigned(FActiveData) and Assigned(FActiveData.FBitmap) then
  begin
    Canvas.Draw(FClockWidth+1, 0, FActiveData.FBitmap);
  end;
end;

function WeekNow: string;
begin  
  case DayOfWeek(Now) of
    1: Result := '��';
    2: Result := 'һ';
    3: Result := '��';
    4: Result := '��';
    5: Result := '��';
    6: Result := '��';
    7: Result := '��';
  end;

  Result := '����' + Result;
end;

//Desc: ����ʱ��
procedure THBEditControl.PaintClock;
var nStr: string;
    nL,nT,nW,nH: Word;
begin
  with gSysParam do
  begin
    if FClockChar = cChar then
         FClockWidth := 64
    else FClockWidth := 96;

    Canvas.Brush.Color := clSkyBlue;
    Canvas.FillRect(Rect(1, 1, FClockWidth, Height-1));
    
    Canvas.Font.Assign(Font);
    SetBkMode(Canvas.Handle, TRANSPARENT);

    if Height < 17 then
    begin
      nStr := Time2Str(Now);
      nW := Canvas.TextWidth(nStr);
      nH := Canvas.TextHeight(nStr);

      nL := Trunc((FClockWidth - nW) / 2);
      nT := Trunc((Height - nH) / 2);  

      Canvas.Font.Color := clRed;
      Canvas.TextOut(nL, nT, nStr);
    end else

    if Height < 33 then
    begin
      if gSysParam.FClockChar = '00' then
      begin
        nStr := ML('YYYY��MM��DD��', sMLCommon);
        nStr := FormatDateTime(nStr, Date());
      end else nStr := Date2Str(Now);
      nW := Canvas.TextWidth(nStr);

      nL := Trunc((FClockWidth - nW) / 2);
      Canvas.Font.Color := clRed;
      Canvas.TextOut(nL, 1, nStr);

      nStr := Time2Str(Now);
      nW := Canvas.TextWidth(nStr);
      nH := Canvas.TextHeight(nStr);

      nL := Trunc((FClockWidth - nW) / 2);
      nT := Height - nH - 1;

      Canvas.Font.Color := clRed;
      Canvas.TextOut(nL, nT, nStr);
    end else
    begin
      if gSysParam.FClockChar = '00' then
      begin
        nStr := ML('YYYY��MM��DD��', sMLCommon);
        nStr := FormatDateTime(nStr, Date());
      end else nStr := Date2Str(Now);
      nW := Canvas.TextWidth(nStr);

      nL := Trunc((FClockWidth - nW) / 2);
      Canvas.Font.Color := clRed;
      Canvas.TextOut(nL, 1, nStr);

      nStr := Time2Str(Now);
      nW := Canvas.TextWidth(nStr);
      nH := Canvas.TextHeight(nStr);

      nL := Trunc((FClockWidth - nW) / 2);
      nT := Height - nH - 1;

      Canvas.Font.Color := clRed;
      Canvas.TextOut(nL, nT, nStr);

      nStr := ML(WeekNow, sMLCommon);
      nW := Canvas.TextWidth(nStr);
      nH := Canvas.TextHeight(nStr);

      nL := Trunc((FClockWidth - nW) / 2);
      nT := Trunc((Height - nH) / 2);
      Canvas.Font.Color := clRed;
      Canvas.TextOut(nL, nT, nStr);
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2010-9-8
//Parm: ����;�б�
//Desc: ��nList�д�������ΪnIdx��������,���´�������true
function THBEditControl.NewDataItem(var nIdx: Integer; const nList: TList): Boolean;
var nItem: PBitmapDataItem;
begin
  if (nIdx > -1) and (nIdx < nList.Count) then
  begin
    PBitmapDataItem(nList[nIdx]).FText := '';
    Result := False; Exit;
  end;

  New(nItem);
  nIdx := nList.Add(nItem);
  FillChar(nItem^, SizeOf(TBitmapDataItem), #0);

  nItem.FFont := TFont.Create;
  nItem.FFont.Assign(FNormalFont);

  nItem.FVerAlign := 0;
  nItem.FHorAlign := 0;
  nItem.FModeEnter := '03';
  nItem.FModeExit := '03';
  nItem.FSpeedEnter := '05';
  nItem.FSpeedExit := '05';
  nItem.FKeedTime := '01';
  nItem.FModeSerial := '01';
  Result:= True;
end;

//Desc: �������ģʽ
function THBEditControl.SpitTextNormal(const nData: TList): Boolean;
var nStr: string;
    nItem: PBitmapDataItem;
    i,nIdx,nLen,nT,nH: Integer;
begin
  Result := False;
  FText := TrimLeft(FText);
  
  if FText  = '' then
  begin
    ClearData(nData); Exit;
  end;

  nIdx := 0;
  NewDataItem(nIdx, nData);
  nItem := nData[nIdx];

  nStr := FText;
  while nStr <> '' do
  begin
    WrapText(nStr, nItem.FFont);
    nT := 0;
    nLen := FWraper.Lines.Count - 1;

    for i:=0 to nLen do
    begin
      if nItem.FText = '' then
           nItem.FText := FWraper.Lines[i]
      else nItem.FText := nItem.FText + #13#10 + FWraper.Lines[i];

      System.Delete(nStr, 1, Length(FWraper.Lines[i]));
      if (Length(nStr) > 0) and (nStr[1] = #13) then System.Delete(nStr, 1, 1);
      if (Length(nStr) > 0) and (nStr[1] = #10) then System.Delete(nStr, 1, 1);

      Canvas.Font.Assign(nItem.FFont);
      nH := Canvas.TextHeight(FWraper.Lines[i]);
      nT := nT + nH;

      if i < nLen then
           nH := Canvas.TextHeight(FWraper.Lines[i+1])
      else Break;
      //��һ�и�

      if nT + nH > Height then
      begin
        Inc(nIdx);
        NewDataItem(nIdx, nData);
        nItem := nData[nIdx]; Break;
      end;
    end;
  end;

  ClearData(nData, False, nIdx+1);
  //������Ч����
  Result := True;
end;

//Desc: ����ɨ��ģʽ
function THBEditControl.ScrollMode: TScrollMode;
var nIdx: Integer;
    nItem: PBitmapDataItem;
begin
  Result := smNormal;
  for nIdx:=0 to FData.Count - 1 do
  begin
    nItem := FData[nIdx];

    if nIdx = 0 then
    begin
      if (nItem.FModeEnter = '03') and
         (nItem.FModeSerial = '01') then Result := smHor
      else
      if (nItem.FModeEnter = '08') and
         (nItem.FModeSerial = '01') then Result := smVer;
    end else
    begin
      if not
      ((
        (Result = smHor) and (nItem.FModeEnter = '03') and
        (nItem.FModeSerial = '01')
      ) or
      (
        (Result = smVer) and (nItem.FModeEnter = '08') and
        (nItem.FModeSerial = '01')
      )) then
      begin
        Result := smNormal; Break;
      end;
    end;
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

//Desc: �ͷ�nBMPs�еĶ���
procedure ClearBitmapArray(var nBMPs: TDynamicBitmapArray);
var nIdx: Integer;
begin
  for nIdx:=Low(nBMPs) to High(nBMPs) do
    nBMPs[nIdx].Free;
  SetLength(nBMPs, 0);
end;

//Desc: ��nData�е�ͼƬ�������߲�ɵ���ͼƬ
function THBEditControl.SplitData(const nList: TList;
  nData: TDynamicBitmapArray): Boolean;
var i,nIdx: Integer;
    nSmall: TDynamicBitmapArray;
    nItem,nFirst: PBitmapDataItem;
begin
  Result := False;
  if FData.Count < 1 then Exit;
  nFirst := FData[0];

  for nIdx:=Low(nData) to High(nData) do
  begin
    Result := SplitPicture(nData[nIdx], TextWidth, Height, nSmall);
    if not Result then Exit;

    for i:=Low(nSmall) to High(nSmall) do
    begin
      New(nItem);
      nList.Add(nItem);
      FillChar(nItem^, SizeOf(TBitmapDataItem), #0);

      nItem.FBitmap := nSmall[i];
      nItem.FModeEnter := nFirst.FModeEnter;
      nItem.FModeExit := nFirst.FModeExit;
      nItem.FModeSerial := nFirst.FModeSerial;
      nItem.FSpeedEnter := nFirst.FSpeedEnter;
      nItem.FSpeedExit := nFirst.FSpeedExit;
      nItem.FKeedTime := nFirst.FKeedTime;
    end;
  end;  
end;

//Desc: ��FData�е����ݻ��Ƶ�nBMPsͼƬ����,ÿ��ͼƬ��������������
function THBEditControl.HorPaint(var nBMPs: TDynamicBitmapArray): Boolean;
var nBmp,nTmp: TBitmap;
    nSR,nDR: TRect;
    nStr: WideString;
    nL,nT,nW,nH: Integer;
    i,j,nIdx,nLen: Integer;
    nItem,nFirst: PBitmapDataItem;

  //�´�ͼ
  procedure NewBigBitmap;
  begin
    SetLength(nBMPs, nIdx+1);
    nBMPs[nIdx] := TBitmap.Create;
    nBMPs[nIdx].Height := Height;
    nBMPs[nIdx].Width := Trunc(2048 / TextWidth) * TextWidth;

    with nBMPs[nIdx].Canvas do
    begin
      Brush.Color := clBlack;
      FillRect(Rect(0, 0, nBMPs[nIdx].Width, nBMPs[nIdx].Height));
    end;

    if Assigned(nItem) then
    begin
      nBMPs[nIdx].Canvas.Font.Assign(nItem.FFont);
      SetBkMode(nBMPs[nIdx].Canvas.Handle, TRANSPARENT);
    end;
  end;

  //��Сͼ
  procedure NewSmallBitmap;
  begin
    nBmp.Width := nW;
    nBmp.Height := Height;

    with nBmp.Canvas do
    begin
      Brush.Color := clBlack;
      FillRect(Rect(0, 0, nBmp.Width, nBmp.Height));
    end;

    if Assigned(nItem) then
    begin
      nBmp.Canvas.Font.Assign(nItem.FFont);
      SetBkMode(nBmp.Canvas.Handle, TRANSPARENT);
    end;
  end;
begin
  Result := FData.Count > 0;
  if not Result then Exit;
  nFirst := FData[0];

  nItem := nil;
  nBmp := TBitmap.Create;
  try
    nL := 0;
    nIdx := 0;
    NewBigBitmap;

    for i:=0 to FData.Count -1 do
    begin
      nItem := FData[i];
      nStr := nItem.FText;
      nLen := Length(nStr);

      nBMPs[nIdx].Canvas.Font.Assign(nItem.FFont);
      SetBkMode(nBMPs[nIdx].Canvas.Handle, TRANSPARENT);

      for j:=1 to nLen do
      begin
        nW := nBMPs[nIdx].Canvas.TextWidth(nStr[j]); 
        if nFirst.FVerAlign = 0 then
          nT := 0 else
        begin
          nH := nBMPs[nIdx].Canvas.TextHeight(nStr[j]);
          if nFirst.FVerAlign = 1 then
               nT := Trunc((nBMPs[nIdx].Height - nH) / 2)
          else nT := nBMPs[nIdx].Height - nH;
        end;

        if nL + nW <= nBMPs[nIdx].Width then
        begin
          nBMPs[nIdx].Canvas.TextOut(nL, nT, nStr[j]);
          nL := nL + nW;

          if nL = nBMPs[nIdx].Width then
          begin
            nL := 0;
            Inc(nIdx);
            NewBigBitmap;
          end;

          Continue;
        end; //������

        NewSmallBitmap;
        nBmp.Canvas.TextOut(0, nT, nStr[j]);
        nBMPs[nIdx].Canvas.Draw(nL, 0, nBmp);
        //���ư���

        Inc(nIdx);
        NewBigBitmap;
        nL := nBMPs[nIdx].Width - nL;

        nSR := Rect(nL, 0, nBmp.Width, nBmp.Height);
        nDR := Rect(0, 0, nW - nL, nBMPs[nIdx].Height);
        nBMPs[nIdx].Canvas.CopyRect(nDR, nBmp.Canvas, nSR);
        //���°���

        nL := nW - nL;
        //��һ����ʼ
      end;
    end;

    nLen := Trunc(nL / TextWidth);
    if nL mod TextWidth <> 0 then Inc(nLen);

    nW := nLen * TextWidth;
    if nW < nBMPs[nIdx].Width then
    begin
      NewSmallBitmap;
      nBmp.Canvas.Draw(0, 0, nBMPs[nIdx]);

      nTmp := nBmp;
      nBmp := nBMPs[nIdx];
      nBMPs[nIdx] := nTmp;
    end;
  finally
    nBmp.Free;
  end;
end;

//Desc: ����ˮƽ����ʱ���
function THBEditControl.SpitTextHor(const nData: TList): Boolean;
var nBigs: TDynamicBitmapArray;
begin
  SetLength(nBigs, 0);
  try
    Result := HorPaint(nBigs);
    if Result then
      Result := SplitData(nData, nBigs);
    //xxxxx
  finally
    ClearBitmapArray(nBigs);
  end;
end;

//Desc: ��FData�е����ݻ��Ƶ�nBMPsͼƬ����,ÿ��ͼƬ��������������
function THBEditControl.VerPaint(var nBMPs: TDynamicBitmapArray): Boolean;
var nBmp,nTmp: TBitmap;
    nSR,nDR: TRect;
    nL,nT,nW,nH: Integer;
    i,j,nIdx,nLen: Integer;
    nItem,nFirst: PBitmapDataItem;

  //�´�ͼ
  procedure NewBigBitmap;
  begin
    SetLength(nBMPs, nIdx+1);
    nBMPs[nIdx] := TBitmap.Create;
    nBMPs[nIdx].Width := TextWidth;
    nBMPs[nIdx].Height := Trunc(2048 / Height) * Height;

    with nBMPs[nIdx].Canvas do
    begin
      Brush.Color := clBlack;
      FillRect(Rect(0, 0, nBMPs[nIdx].Width, nBMPs[nIdx].Height));
    end;

    if Assigned(nItem) then
    begin
      nBMPs[nIdx].Canvas.Font.Assign(nItem.FFont);
      SetBkMode(nBMPs[nIdx].Canvas.Handle, TRANSPARENT);
    end;
  end;

  //��Сͼ
  procedure NewSmallBitmap;
  begin
    nBmp.Height := nH;
    nBmp.Width := TextWidth;

    with nBmp.Canvas do
    begin
      Brush.Color := clBlack;
      FillRect(Rect(0, 0, nBmp.Width, nBmp.Height));
    end;

    if Assigned(nItem) then
    begin
      nBmp.Canvas.Font.Assign(nItem.FFont);
      SetBkMode(nBmp.Canvas.Handle, TRANSPARENT);
    end;
  end;
begin
  Result := FData.Count > 0;
  if not Result then Exit;
  nFirst := FData[0];

  nItem := nil;
  nBmp := TBitmap.Create;
  try
    nT := 0;
    nIdx := 0;
    NewBigBitmap;
                            
    for i:=0 to FData.Count -1 do
    begin
      nItem := FData[i];
      WrapText(nItem.FText, nItem.FFont);

      nBMPs[nIdx].Canvas.Font.Assign(nItem.FFont);
      SetBkMode(nBMPs[nIdx].Canvas.Handle, TRANSPARENT);

      nLen := FWraper.Lines.Count - 1;
      for j:=0 to nLen do
      begin
        nH := nBMPs[nIdx].Canvas.TextHeight(FWraper.Lines[j]);
        if nFirst.FHorAlign = 0 then
          nL := 0 else
        begin
          nW := nBMPs[nIdx].Canvas.TextWidth(FWraper.Lines[j]);
          if nFirst.FHorAlign = 1 then
               nL := Trunc((nBMPs[nIdx].Width - nW) / 2)
          else nL := nBMPs[nIdx].Width - nW;
        end;

        if nT + nH <= nBMPs[nIdx].Height then
        begin
          nBMPs[nIdx].Canvas.TextOut(nL, nT, FWraper.Lines[j]);
          nT := nT + nH;

          if nT = nBMPs[nIdx].Height then
          begin
            nT := 0;
            Inc(nIdx);
            NewBigBitmap;
          end;

          Continue;
        end; //������

        NewSmallBitmap;
        nBmp.Canvas.TextOut(nL, 0, FWraper.Lines[j]);
        nBMPs[nIdx].Canvas.Draw(0, nT, nBmp);
        //���ư���

        Inc(nIdx);
        NewBigBitmap;
        nT := nBMPs[nIdx].Height - nT;

        nSR := Rect(0, nT, nBmp.Width, nBmp.Height);
        nDR := Rect(0, 0, nBMPs[nIdx].Width, nH - nT);
        nBMPs[nIdx].Canvas.CopyRect(nDR, nBmp.Canvas, nSR);
        //���°���

        nT := nH - nT;
        //��һ����ʼ
      end;
    end;

    nLen := Trunc(nT / Height);
    if nT mod Height <> 0 then Inc(nLen);

    nH := nLen * Height;
    if nH < nBMPs[nIdx].Height then
    begin
      NewSmallBitmap;
      nBmp.Canvas.Draw(0, 0, nBMPs[nIdx]);

      nTmp := nBmp;
      nBmp := nBMPs[nIdx];
      nBMPs[nIdx] := nTmp;
    end;
  finally
    nBmp.Free;
  end;
end;

//Desc: ��ֱ����ʱ���
function THBEditControl.SpitTextVer(const nData: TList): Boolean;
var nBigs: TDynamicBitmapArray;
begin
  SetLength(nBigs, 0);
  try
    Result := VerPaint(nBigs);
    if Result then
      Result := SplitData(nData, nBigs);
    //xxxxx
  finally
    ClearBitmapArray(nBigs);
  end;
end;

end.
