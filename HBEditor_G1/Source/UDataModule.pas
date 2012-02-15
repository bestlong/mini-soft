{*******************************************************************************
  ����: dmzn@163.com 2010-8-31
  ����: ���ݿ������ͨѶ
*******************************************************************************}
unit UDataModule;

interface

uses
  SysUtils, Classes, Types, dxSkinsCore, dxSkinsDefaultPainters, ImgList,
  Controls, CPort, XPMan, Graphics, UMgrLang, ULibFun, USysConst,
  cxLookAndFeels;

type
  TFDM = class(TDataModule)
    cxLF1: TcxLookAndFeelController;
    XP1: TXPManifest;
    ComPort1: TComPort;
    ImagesBase: TImageList;
  private
    { Private declarations }
  public
    { Public declarations }
    function ConnCard(var nNewConn: Boolean; var nHint: string): Boolean;
    {*���ӿ�*}
    function GetCardWH(var nWH: TPoint; var nHint: string;
      const nRespond: Boolean = False): Boolean;
    {*��ȡ���*}
    function SendCardWH(const nWH: TPoint; var nHint: string): Boolean;
    {*���ÿ��*}
    function SendClock(var nHint: string): Boolean;
    {*����ʱ��*}
  end;

var
  FDM: TFDM;

function RegularInt(const nInt: Integer; const nLen: Integer): string;
//ͳһ����
function Hex2Normal(const nStr: string; const nLen: Integer = 2): string;
function HexStr(const nByte: Byte): string; overload;
function HexStr(const nStr: string): string; overload;
function HexStr(const nBytes: TDynamicByteArray): string; overload;
//ʮ�������ַ���
procedure ScanWithSingleMode(const nBmp: TBitmap; const nBgColor: TColor;
 var nData: TDynamicByteArray; const nInvertScan: Boolean = False); overload;
function ScanWithSingleMode(const nBmp: TBitmap; const nBgColor: TColor;
 const nInvertScan: Boolean = False): string; overload;
//ɨ��ͼƬ

implementation

{$R *.dfm}

//------------------------------------------------------------------------------
//Desc: ��������ʽ������,������ǰ��0
function RegularInt(const nInt: Integer; const nLen: Integer): string;
begin
  Result := IntToStr(nInt);
  Result := StringOfChar('0', nLen - Length(Result)) + Result;
end;

//Desc: �ֽ�תʮ������
function HexStr(const nByte: Byte): string;
const
  HexDigs: array [0..15] of char = '0123456789abcdef';
var nB1,nB2: Byte;
begin
  nB1 := nByte and $F;
  nB2 := nByte shr 4;
  Result:= HexDigs[nB2] + HexDigs[nB1];
end;

//Desc: ��nBytesתΪʮ�������ַ���
function HexStr(const nBytes: TDynamicByteArray): string;
var nIdx: Integer;
begin
  Result := '';
  for nIdx:=Low(nBytes) to High(nBytes) do
    Result := Result + HexStr(nBytes[nIdx]);
  //xxxxx
end;

//Desc: ��nStr����������תΪʮ����������
function HexStr(const nStr: string): string;
begin
  if IsNumber(nStr, False) then
       Result := HexStr(StrToInt(nStr))
  else Result := '';
end;

//Desc: ��ʮ������nStrתΪ����ʮ����
function Hex2Normal(const nStr: string; const nLen: Integer): string;
begin
  Result := '$' + nStr;
  if nLen < 1 then
       Result := IntToStr(StrToInt(Result))
  else Result := RegularInt(StrToInt(Result), nLen);
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

//Desc: ʹ�õ�ɫ����ɨ��nBmp,����nData������
procedure ScanWithSingleMode(const nBmp: TBitmap; const nBgColor: TColor;
 var nData: TDynamicByteArray; const nInvertScan: Boolean = False);
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

      if nInvertScan then
       if nBuf[nX + 1] = '0' then
            nBuf[nX + 1] := '1'
       else nBuf[nX + 1] := '0';
    end;

    MakeByteArray(nBuf, nBits);
    CombinByteArray(nBits, nData);
  end;
end;

//Desc: ��nBmpɨ��Ϊ�ַ�������
function ScanWithSingleMode(const nBmp: TBitmap; const nBgColor: TColor;
 const nInvertScan: Boolean = False): string;
var nData: TDynamicByteArray;
begin
  ScanWithSingleMode(nBmp, nBgColor, nData, nInvertScan);
  Result := HexStr(nData);
end;

//------------------------------------------------------------------------------
//Desc: ���ӿ��ƿ�
function TFDM.ConnCard(var nNewConn: Boolean; var nHint: string): Boolean;
begin
  try
    nNewConn := ComPort1.Connected and (ComPort1.Port = gSysParam.FCOMMPort) and
       (ComPort1.BaudRate = StrToBaudRate(IntToStr(gSysParam.FCOMMBote)));
    nNewConn := not nNewConn;

    if nNewConn then
    begin
      ComPort1.Close;
      ComPort1.Port := gSysParam.FCOMMPort;
      ComPort1.BaudRate := StrToBaudRate(IntToStr(gSysParam.FCOMMBote));
      ComPort1.Open;
    end;

    nHint := '';
    Result := True;

    ComPort1.ClearBuffer(True, True);
    //��ջ���,�������
  except
    Result := False;
    nHint := ML('���ӿ�����ʧ��', sMLCommon);
  end;
end;

//Date: 2010-9-5
//Parm: ���;�Ƿ���Ӧ��λ��
//Desc: ��ȡ��λ�����
function TFDM.GetCardWH(var nWH: TPoint; var nHint: string;
  const nRespond: Boolean): Boolean;
var nStr: string;
    nBool: Boolean;
begin
  Result := False;
  nBool := False;
  try
    try
      if not ConnCard(nBool, nHint) then Exit;

      ComPort1.Write('F', 1);
      if (ComPort1.ReadStr(nStr, 3) <> 3) or (nStr[1] <> 'F') then
      begin
        nHint := '��������ʧ��'#13'������ȷ�����߼���Դ'; Exit;
      end else nHint := '��ȡ��Ļ�����ɹ�';

      nWH.X := Ord(nStr[3]) * 8;
      nWH.Y := Ord(nStr[2]) * 8;

      if not nRespond then
      begin
        Result := True; Exit;
      end;

      //------------------------------------------------------------------------
      if (nWH.X <> gSysParam.FScreenWidth) or (nWH.Y <> gSysParam.FScreenHeight) then
      begin
        nHint := '��λ���뿨��Ļ�ߴ粻��'; Exit;
      end;

      ComPort1.ClearBuffer(True, False);
      //������뻺��,��������ַ�����

      ComPort1.Write('L', 1);
      Sleep(120);
      //�ȴ���λ������

      if (ComPort1.ReadStr(nStr, 1) <> 1) or (nStr[1] <> 'L') then
      begin
        nHint := '��ȡ����ͬ�����ݴ���'; Exit;
      end;

      Result := True;
    except
      nHint := '�������ͨ�Ŵ���';
    end;  
  finally
    if nHint <> '' then
      nHint := ML(nHint, sMLCommon);
    //xxxxx

    if nBool then
      ComPort1.Close;
    //xxxxx
  end;
end;

//Desc: ����ʱ������
function TFDM.SendClock(var nHint: string): Boolean;
var nStr: string;
    nLen: Integer;
    nBool: Boolean;
begin
  Result := False;
  nBool := False;
  try
    try
      if not ConnCard(nBool, nHint) then Exit;

      with gSysParam do
       nStr := FClockChar + FClockMode + FClockPos + FClockYear + FClockMonth +
               FClockDay + FClockWeek + FClockTime + FClockSYear + FClockSMonth +
               FClockSDay + FClockSHour + FClockSMin + FClockSSec + FClockSWeek;
      //ʱ��ṹ

      nStr := 'R' + nStr + 'Q';
      nLen := Length(nStr);

      if ComPort1.Write(PChar(nStr), nLen) <> nLen then
      begin
        nHint := 'ʱ�����ݷ���ʧ��'; Exit;
      end;

      if gSysParam.FEnablePD then
      begin
        nStr := 'U' + gSysParam.FPlayDays;
        ComPort1.Write(PChar(nStr), Length(nStr));
      end;

      Result := True;
      nHint := 'ʱ��ͬ���ɹ�';
    except
      nHint := '�������ͨ�Ŵ���';
    end;  
  finally
    if nHint <> '' then
      nHint := ML(nHint, sMLCommon);
    //xxxxx

    if nBool then
      ComPort1.Close;
    //xxxxx
  end;
end;

//Desc: ���ÿ��
function TFDM.SendCardWH(const nWH: TPoint; var nHint: string): Boolean;
var nStr: string;
    nBool: Boolean;
begin
  nHint := '';
  Result := False;

  nBool := True;
  try
    try
      if not ConnCard(nBool, nHint) then Exit;

       nHint := '��Ļ����޷�����';
      ComPort1.Write('S', 1);
      if (ComPort1.ReadStr(nStr, 1) <> 1) or (nStr <> 'S') then Exit;

      nStr := HexStr(Trunc(nWH.X / 8)) + HexStr(nWH.Y) + 'W';
      ComPort1.Write(PChar(nStr), Length(nStr)); 
      if (ComPort1.ReadStr(nStr, 1) <> 1) or (nStr <> 'W') then Exit;

      Result := True;
      nHint := '��Ļ��߳ɹ�����';
    except
      nHint := '�������ͨ�Ŵ���';
    end;  
  finally
    if nHint <> '' then
      nHint := ML(nHint, sMLCommon);
    //xxxxx

    if nBool then
      ComPort1.Close;
    //xxxxx
  end;
end;

end.
