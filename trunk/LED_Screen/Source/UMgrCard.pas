{*******************************************************************************
  ����: dmzn@ylsoft.com 2011-03-13
  ����: LED���ƿ�����
*******************************************************************************}
unit UMgrCard;

interface

uses
  Windows, SysUtils, Classes, IniFiles, NativeXml, UWaitItem, ULibFun,
  USysConst, UBase64;

const
  //�ط�����
  cSend_TryNum                 = 3;

  //��ʱ�����ļ�
  cSend_File                   = 'run.txt';
            
  //������ͨѶģʽ
  SEND_MODE_COMM               = 0;
  SEND_MODE_NET                = 2;
  
  //�û�������Ϣ�����
  SEND_CMD_PARAMETER           = $A1FF; //������������
  SEND_CMD_SCREENSCAN          = $A1FE; //����ɨ�跽ʽ��
  SEND_CMD_SENDALLPROGRAM      = $A1F0; //�������н�Ŀ��Ϣ��
  SEND_CMD_POWERON             = $A2FF; //ǿ�ƿ���
  SEND_CMD_POWEROFF            = $A2FE; //ǿ�ƹػ�
  SEND_CMD_TIMERPOWERONOFF     = $A2FD; //��ʱ���ػ�
  SEND_CMD_CANCEL_TIMERPOWERONOFF = $A2FC; //ȡ����ʱ���ػ�
  SEND_CMD_RESIVETIME          = $A2FB; //У��ʱ�䡣
  SEND_CMD_ADJUSTLIGHT         = $A2FA; //���ȵ�����

  //ͨѶ���󷵻ش���ֵ
  RETURN_NOERROR               = 0;
  RETURN_ERROR_AERETYPE        = $F7;
  RETURN_ERROR_RA_SCREENNO     = $F8;
  RETURN_ERROR_NOFIND_AREAFILE = $F9;
  RETURN_ERROR_NOFIND_AREA     = $FA;
  RETURN_ERROR_NOFIND_PROGRAM  = $FB;
  RETURN_ERROR_NOFIND_SCREENNO = $FC;
  RETURN_ERROR_NOW_SENDING     = $FD;
  RETURN_ERROR_OTHER           = $FF;

  //����������
  CONTROLLER_TYPE_FOURTH    = $40;
  CONTROLLER_TYPE_WILDCARD  = $FFFE;
  CONTROLLER_TYPE_3T        = $10;
  CONTROLLER_TYPE_3A        = $20;
  CONTROLLER_TYPE_3A1       = $21;
  CONTROLLER_TYPE_3A2       = $22;
  CONTROLLER_TYPE_3M        = $30;

  CONTROLLER_TYPE_4A1       = $0141;
  CONTROLLER_TYPE_4A2       = $0241;
  CONTROLLER_TYPE_4A3       = $0341;
  CONTROLLER_TYPE_4AQ       = $1041;
  CONTROLLER_TYPE_4A        = $0041;

  CONTROLLER_TYPE_4M1       = $0142;
  CONTROLLER_TYPE_4M        = $0042;
  CONTROLLER_TYPE_4MC       = $0C42;

  CONTROLLER_TYPE_4C        = $0043;
  CONTROLLER_TYPE_4E1       = $0144;
  CONTROLLER_TYPE_4E        = $0044;

type
  TCardCode = record
    FCode: Word;
    FDesc: string;
  end;

const
  cCardEffects: array[0..39] of TCardCode = (
             (FCode: $00; FDesc:'�����ʾ'),
             (FCode: $01; FDesc:'��̬'),
             (FCode: $02; FDesc:'���ٴ��'),
             (FCode: $03; FDesc:'�����ƶ�'),
             (FCode: $04; FDesc:'��������'),
             (FCode: $05; FDesc:'�����ƶ�'),
             (FCode: $06; FDesc:'��������'),
             (FCode: $07; FDesc:'��˸'),
             (FCode: $08; FDesc:'Ʈѩ'),
             (FCode: $09; FDesc:'ð��'),
             (FCode: $0A; FDesc:'�м��Ƴ�'),
             (FCode: $0B; FDesc:'��������'),
             (FCode: $0C; FDesc:'���ҽ�������'),
             (FCode: $0D; FDesc:'���½�������'),
             (FCode: $0E; FDesc:'����պ�'),
             (FCode: $0F; FDesc:'�����'),
             (FCode: $10; FDesc:'��������'),
             (FCode: $11; FDesc:'��������'),
             (FCode: $12; FDesc:'��������'),
             (FCode: $13; FDesc:'��������'),
             (FCode: $14; FDesc:'��������'),
             (FCode: $15; FDesc:'��������'),
             (FCode: $16; FDesc:'��������'),
             (FCode: $17; FDesc:'��������'),
             (FCode: $18; FDesc:'���ҽ�����Ļ'),
             (FCode: $19; FDesc:'���½�����Ļ'),
             (FCode: $1A; FDesc:'��ɢ����'),
             (FCode: $1B; FDesc:'ˮƽ��ҳ'),
             (FCode: $1D; FDesc:'������Ļ'),
             (FCode: $1E; FDesc:'������Ļ'),
             (FCode: $1F; FDesc:'������Ļ'),
             (FCode: $20; FDesc:'������Ļ'),
             (FCode: $21; FDesc:'���ұպ�'),
             (FCode: $22; FDesc:'���ҶԿ�'),
             (FCode: $23; FDesc:'���±պ�'),
             (FCode: $24; FDesc:'���¶Կ�'),
             (FCode: $25; FDesc:'��������'),
             (FCode: $26; FDesc:'��������'),
             (FCode: $27; FDesc:'�����ƶ�'),
             (FCode: $28; FDesc:'��������'));
  //ϵͳ֧�ֵ���Ч

  cCardList: array[0..1] of TCardCode = (
             (FCode:CONTROLLER_TYPE_4M; FDesc:'BX-4M'),
             (FCode:CONTROLLER_TYPE_4M1; FDesc:'BX-4M1'));
  //ϵͳ֧�ֵĿ��б�

  cCardScreens: array[0..2] of TCardCode = ((FCode:1; FDesc:'С��'),
             (FCode:2; FDesc:'����'), (FCode:3; FDesc:'����'));
  //ϵͳ֧�ֵ���Ļ����

type
  TCardStatus = (csNormal, csSending, csDone);
  //����;����;���ͽ���

  PCardItem = ^TCardItem;
  TCardItem = record
    FType: Integer;         //����
    FSerial: string;        //���
    FName: string;          //����

    FCard: Integer;         //������
    FDataOE: Byte;          //OE�趨
    FIP: string;            //IP
    FPort: Integer;         //�˿�
    FWidth: Integer;        //���
    FHeight: Integer;       //�߶�
    FSpeed: Integer;        //����
    FKeep: Integer;         //ͣ��

    FEffect: Integer;       //��Ч
    FFontName: string;      //����
    FFontSize: Integer;     //��С
    FFontBold: Byte;        //�Ӵ�

    FCounter: Byte;         //����
    FStatus: TCardStatus;   //״̬
    FLatUpdate: string;     //����ʱ��
  end;

  TCardMessage = procedure (const nItem: TCardItem; const nMsg: string) of Object;
  //��Ϣ״̬

  TCardManager = class;
  TCardSendThread = class(TThread)
  private
    FOwner: TCardManager;
    //ӵ����
    FWaiter: TWaitObject;
    //�ȴ�����
    FNowItem: PCardItem;
    //��ǰ����
    FMessage: string;
    //��ʾ��Ϣ

    FFileOpt: TStrings;
    //�ļ�����
    FBusy: Boolean;
    //����״̬
    FXML: TNativeXml;
    FFileName: string;
    //��������
  protected
    procedure Execute; override;
    procedure DoExecute;
    //ִ���߳�
    procedure SyncHintMsg;
    procedure DoHintMsg(const nMsg: string; const nStatus: TCardStatus = csNormal);
    //��ʾ��Ϣ
    function SendData(const nData: TXmlNode): Boolean;
    //��������
  public
    constructor Create(AOwner: TCardManager);
    destructor Destroy; override;
    //�����ͷ�
    function Start(const nFile: string): Boolean;
    procedure Stop;
    //����ֹͣ
  end;

  TCardManager = class(TObject)
  private
    FCards: TList;
    //���б�     
    FFileName: string;
    //�洢�ļ�
    FChanged: Boolean;
    //���ݸı�
    FSender: TCardSendThread;
    //�����߳�
    FMessage: TCardMessage;
    //��Ϣ״̬
  protected
    procedure ClearList(const nFree: Boolean);
    //������Դ
    function FindCard(const nSerial: string): Integer;
    //������
    function LoadFile(const nFile: string): Boolean;
    function SaveFile(const nFile: string): Boolean;
    //���뱣��
    procedure SetFileName(const nFile: string);
    //�����ļ�
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure AddCard(const nCard: TCardItem);
    procedure DelCard(const nSerial: string);
    //���ɾ��
    function SendData(const nFile: string): Boolean;
    //��������
    function GetErrorDesc(const nErr: Integer): string;
    //��������
    property Cards: TList read FCards;
    property FileName: string read FFileName write SetFileName;
    property OnMessage: TCardMessage read FMessage write FMessage;
    //�������
  end;

var
  gCardManager: TCardManager = nil;
  //ȫ��ʹ��

implementation

const
  cDLL = 'BX_IV.dll';

function AddScreen(nControlType, nScreenNo, nWidth, nHeight, nScreenType, 
  nPixelMode: Integer; nDataDA, nDataOE: Integer; nRowOrder, nFreqPar: Integer; 
  pCom: PChar; nBaud: Integer;
  pSocketIP: PChar; nSocketPort: Integer): integer; stdcall; external cDLL;
//��ӡ�������ʾ��
function AddScreenProgram(nScreenNo, nProgramType: Integer; nPlayLength: Integer;
  nStartYear, nStartMonth, nStartDay, nEndYear, nEndMonth, nEndDay: Integer;
  nMonPlay, nTuesPlay, nWedPlay, nThursPlay, bFriPlay, nSatPlay, 
  nSunPlay: integer; nStartHour, nStartMinute, nEndHour,
  nEndMinute: Integer): Integer; stdcall; external cDLL;
//��ָ����ʾ����ӽ�Ŀ
function AddScreenProgramBmpTextArea(nScreenNo, nProgramOrd: Integer;
  nX, nY, nWidth, nHeight: integer): Integer; stdcall; external cDLL;
//��ָ����ʾ��ָ����Ŀ���ͼ������
function AddScreenProgramAreaBmpTextFile(nScreenNo, nProgramOrd,
  nAreaOrd: Integer; pFileName: PChar; pFontName: PChar; nFontSize, nBold, 
  nFontColor: Integer; nStunt, nRunSpeed,
  nShowTime: Integer): Integer; stdcall; external cDLL;
//��ָ����ʾ��ָ����Ŀָ����������ļ�
function DeleteScreen(nScreenNo: Integer): Integer; stdcall; external cDLL;
//ɾ��ָ����ʾ��
function DeleteScreenProgram(nScreenNo,
  nProgramOrd: Integer): Integer; stdcall; external cDLL;
//ɾ��ָ����ʾ��ָ����Ŀ
function DeleteScreenProgramArea(nScreenNo, nProgramOrd,
  nAreaOrd: Integer): Integer; stdcall; external cDLL;
//ɾ��ָ����ʾ��ָ����Ŀ��ָ������
function DeleteScreenProgramAreaBmpTextFile(nScreenNo, nProgramOrd, nAreaOrd,
  nFileOrd: Integer): Integer; stdcall; external cDLL;
//ɾ��ָ����ʾ��ָ����Ŀָ��ͼ�������ָ���ļ�
function SendScreenInfo(nScreenNo, nSendMode, nSendCmd,
  nOtherParam1: Integer): Integer; stdcall; external cDLL;
//������Ӧ�����ʾ��

//------------------------------------------------------------------------------
constructor TCardSendThread.Create(AOwner: TCardManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FFileOpt := TStringList.Create;

  FXML := TNativeXml.Create;
  FWaiter := TWaitObject.Create;
end;

destructor TCardSendThread.Destroy;
begin
  FWaiter.Free;
  FXML.Free;
  FFileOpt.Free;
  inherited;
end;

//Desc: ֹͣ(�ⲿ����)
procedure TCardSendThread.Stop;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TCardSendThread.DoHintMsg(const nMsg: string; const nStatus: TCardStatus);
begin
  FMessage := nMsg;
  FNowItem.FStatus := nStatus;
  Synchronize(SyncHintMsg);
end;

procedure TCardSendThread.SyncHintMsg;
begin
  if Assigned(FOwner.FMessage) then
    FOwner.FMessage(FNowItem^, FMessage);
  //hint message
end;

//Desc: �����߳�
function TCardSendThread.Start(const nFile: string): Boolean;
begin
  Result := (not FBusy) and FileExists(nFile);
  if not Result then Exit;

  try
    FXML.LoadFromFile(nFile);
    FFileName := nFile;
    FWaiter.Wakeup;
  except
    Result := False;
  end;
end;

procedure TCardSendThread.Execute;
var nIdx: Integer;
begin
  FBusy := False;

  while True do
  try
    FWaiter.EnterWait;
    if Terminated then Break;

    for nIdx:=FOwner.FCards.Count - 1 downto 0 do
    begin
      FNowItem := FOwner.Cards[nIdx];
      FNowItem.FCounter := 0;
    end;
    
    FBusy := True;
    DoExecute;
    FBusy := False;
  except
    Sleep(500);
    FBusy := False;
    //maybe any error
  end;
end;

//Desc: ִ�з���
procedure TCardSendThread.DoExecute;
var nStr: string;
    nNode: TXmlNode;
    i,nLen,nIdx: Integer;
begin
  while not Terminated do
  try
    nLen := 0;
    
    for nIdx:=FOwner.FCards.Count - 1 downto 0 do
    begin
      if Terminated then Break;
      FNowItem := FOwner.FCards[nIdx];

      if FNowItem.FCounter < cSend_TryNum then
      begin
        Inc(nLen); Break;
      end;
    end;

    if nLen < 1 then Exit;
    //has send all

    for nIdx:=FOwner.FCards.Count - 1 downto 0 do
    begin
      if Terminated then Break;
      FNowItem := FOwner.FCards[nIdx];
      if FNowItem.FCounter >= cSend_TryNum then Continue;
      
      DoHintMsg('��ʼ����', csSending);
      FNowItem.FLatUpdate := '';
      
      Inc(FNowItem.FCounter);
      nLen := FXML.Root.NodeCount - 1;

      for i:=0 to nLen do
      begin
        nNode := FXML.Root.Nodes[i];

        if nNode.HasAttribute('ID') then
        begin
          nStr := nNode.AttributeByName['ID'];
          if (nStr = FNowItem.FSerial) and SendData(nNode) then
          begin
            FNowItem.FCounter := cSend_TryNum; Break;
          end;
        end else

        if nNode.HasAttribute('type') then
        begin
          nStr := nNode.AttributeByName['type'];
          if IsNumber(nStr, False) and (StrToInt(nStr) = FNowItem.FType) and
             SendData(nNode) then
          begin
            FNowItem.FCounter := cSend_TryNum; Break;
          end;
        end;
      end;

      if FNowItem.FCounter >= cSend_TryNum then
        DoHintMsg('�������', csDone);
      //xxxxx
    end;
  except
    //ignor any error
  end;
end;

//Desc: ��FNowItem����nData����
function TCardSendThread.SendData(const nData: TXmlNode): Boolean;
var nRes: Integer;
    nNode: TXmlNode;
begin
  Result := False;
  nNode := nData.FindNode('Content');

  if (not Assigned(nNode)) or (nNode.ValueAsString = '') then
  begin
    DoHintMsg('���ݽڵ���Ч'); Exit;
  end;

  with FNowItem^,FOwner do
  try
    nRes := DeleteScreen(1);
    DoHintMsg(Format('DeleteScreen:%s', [GetErrorDesc(nRes)]));
    if (nRes<>RETURN_NOERROR) and (nRes<>RETURN_ERROR_NOFIND_SCREENNO) then Exit;

    nRes := AddScreen(FCard, 1, FWidth, FHeight, 1, 2, 0, FDataOE, 0, 0, 
            'COM1', 9600, PChar(FIP), FPort);
    DoHintMsg(Format('AddScreen:%s', [GetErrorDesc(nRes)]));
    if nRes <> RETURN_NOERROR then Exit;

    nRes := AddScreenProgram(1, 0, 0, 65535, 11, 26, 2011, 11, 26, 1, 1, 1,
            1, 1, 1, 1, 0, 0, 23, 59);
    DoHintMsg(Format('AddScreenProgram:%s', [GetErrorDesc(nRes)]));
    if nRes <> RETURN_NOERROR then Exit;

    nRes := AddScreenProgramBmpTextArea(1, 0, 0, 0, FWidth, FHeight);
    DoHintMsg(Format('AddScreenProgramBmpTextArea:%s', [GetErrorDesc(nRes)]));
    if nRes <> RETURN_NOERROR then Exit;

    if nNode.HasAttribute('encode') and (nNode.AttributeByName['encode'] = 'y') then
         FFileOpt.Text := DecodeBase64(nNode.ValueAsString)
    else FFileOpt.Text := nNode.ValueAsString;

    FFileOpt.SaveToFile(gPath + cSend_File);
    Sleep(100);
    //wait I/O

    nRes := AddScreenProgramAreaBmpTextFile(1, 0, 0, PChar(gPath + cSend_File),
            PChar(FFontName), FFontSize, FFontBold, 1, FEffect, FSpeed, FKeep);
    DoHintMsg(Format('AddScreenProgramAreaBmpTextFile:%s', [GetErrorDesc(nRes)]));
    if nRes <> RETURN_NOERROR then Exit;

    nRes := SendScreenInfo(1, SEND_MODE_NET, SEND_CMD_SENDALLPROGRAM, 0);
    DoHintMsg(Format('SendScreenInfo:%s', [GetErrorDesc(nRes)]));
  except
    //ignor any error
  end;

  Result := True;
  FNowItem.FLatUpdate := Time2Str(Now);
end;

//------------------------------------------------------------------------------
constructor TCardManager.Create;
begin
  FFileName := '';
  FChanged := False;
  FCards := TList.Create;
  FSender := TCardSendThread.Create(Self);
end;

destructor TCardManager.Destroy;
begin
  FSender.Stop;
  //stop thread

  if FChanged and (FFileName <> '') then
    SaveFile(FFileName);
  ClearList(True);
  inherited;
end;

procedure TCardManager.ClearList(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FCards.Count - 1 downto 0 do
  begin
    Dispose(PCardItem(FCards[nIdx]));
    FCards.Delete(nIdx);
  end;

  if nFree then FreeAndNil(FCards);
end;

function TCardManager.FindCard(const nSerial: string): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=FCards.Count - 1 downto 0 do
  if CompareText(PCardItem(FCards[nIdx]).FSerial, nSerial) = 0 then
  begin
    Result := nIdx; Break;
  end;
end;

procedure TCardManager.AddCard(const nCard: TCardItem);
var nIdx: Integer;
    nItem: PCardItem;
begin
  nIdx := FindCard(nCard.FSerial);
  if nIdx < 0 then
  begin
    New(nItem);
    FCards.Add(nItem);
    FillChar(nItem^, SizeOf(TCardItem), #0);
  end else nItem := FCards[nIdx];

  with nItem^ do
  begin
    FType := nCard.FType;
    FSerial := nCard.FSerial;
    FName := nCard.FName;

    FCard := nCard.FCard;
    FDataOE := nCard.FDataOE;
    FIP := nCard.FIP;
    FPort := nCard.FPort;
    FWidth := nCard.FWidth;
    FHeight := nCard.FHeight;

    FSpeed := nCard.FSpeed;
    FKeep := nCard.FKeep;
    FEffect := nCard.FEffect;
    FFontName := nCard.FFontName;
    FFontSize := nCard.FFontSize;
    FFontBold := nCard.FFontBold; 
  end;

  FChanged := True;
end;

procedure TCardManager.DelCard(const nSerial: string);
var nIdx: Integer;
begin
  nIdx := FindCard(nSerial);
  if nIdx > -1 then
  begin
    Dispose(PCardItem(FCards[nIdx]));
    FCards.Delete(nIdx);
  end;

  FChanged := True;
end;

procedure TCardManager.SetFileName(const nFile: string);
begin
  if (nFile <> FFileName) and LoadFile(nFile) then FFileName := nFile;
end;

function TCardManager.LoadFile(const nFile: string): Boolean;
var nIni: TIniFile;
    nList: TStrings;
    i,nLen: Integer;
    nItem: PCardItem;
begin
  nIni := nil;
  nList := nil;
  try
    nIni := TIniFile.Create(nFile);
    nList := TStringList.Create;
    nIni.ReadSections(nList);

    nLen := nList.Count - 1;
    ClearList(False);
    FChanged := False;

    for i:=0 to nLen do
    if nIni.ReadString(nList[i], 'Flag', '') = nList[i] then
    begin
      New(nItem);
      FCards.Add(nItem);

      with nItem^,nIni do
      begin
        FType := ReadInteger(nList[i], 'Type', 0);
        FSerial := ReadString(nList[i], 'Serial', '');
        FName := ReadString(nList[i], 'Name', '');
        FCard := ReadInteger(nList[i], 'Card', 0);
        FDataOE := ReadInteger(nList[i], 'DataOE', 0);
        FIP := ReadString(nList[i], 'IP', '');
        FPort := ReadInteger(nList[i], 'Port', 0);
        FWidth := ReadInteger(nList[i], 'Width', 0);
        FHeight := ReadInteger(nList[i], 'Height', 0);
        FSpeed := ReadInteger(nList[i], 'Speed', 0);
        FKeep := ReadInteger(nList[i], 'Keep', 0);
        FEffect := ReadInteger(nList[i], 'Effect', 0);
        FFontName := ReadString(nList[i], 'FontName', '����');
        FFontSize := ReadInteger(nList[i], 'FontSize', 9);
        FFontBold := ReadInteger(nList[i], 'FontBold', 0);
      end;  
    end;        
    
    Result := True;
  except
    Result := False;
  end;

  nList.Free;
  nIni.Free;
end;

function TCardManager.SaveFile(const nFile: string): Boolean;
var nStr: string;
    nIni: TIniFile;
    nList: TStrings;
    i,nLen: Integer;
begin
  nIni := nil;
  nList := nil;
  try
    nIni := TIniFile.Create(nFile);
    nList := TStringList.Create;

    nIni.ReadSections(nList);
    nLen := nList.Count - 1;
      
    for i:=0 to nLen do
     if nIni.ReadString(nList[i], 'Flag', '') = nList[i] then
      nIni.EraseSection(nList[i]);
    //����

    nLen := FCards.Count - 1;
    for i:=0 to nLen do
    begin
      nStr := Format('Card_%d', [i]);
      nIni.WriteString(nStr, 'Flag', nStr);

      with PCardItem(FCards[i])^,nIni do
      begin
        WriteInteger(nStr, 'Type', FType);
        WriteString(nStr, 'Serial', FSerial);
        WriteString(nStr, 'Name', FName);
        WriteInteger(nStr, 'Card', FCard);
        WriteInteger(nStr, 'DataOE', FDataOE);
        WriteString(nStr, 'IP', FIP);
        WriteInteger(nStr, 'Port', FPort);
        WriteInteger(nStr, 'Width', FWidth);
        WriteInteger(nStr, 'Height', FHeight);
        WriteInteger(nStr, 'Speed', FSpeed);
        WriteInteger(nStr, 'Keep', FKeep);
        WriteInteger(nStr, 'Effect', FEffect);

        WriteString(nStr, 'FontName', FFontName);
        WriteInteger(nStr, 'FontSize', FFontSize);
        WriteInteger(nStr, 'FontBold', FFontBold);
      end;
    end;

    FChanged := False;
    Result := True;   
  except
    Result := False;
  end;

  nList.Free;
  nIni.Free;
end;

//------------------------------------------------------------------------------
function TCardManager.GetErrorDesc(const nErr: Integer): string;
begin
  case nErr of
    RETURN_ERROR_AERETYPE: Result := '�������ʹ���,����ӡ�ɾ��ͼ������' +
                      '�ļ�ʱ�������ͳ����ش����ʹ���.';
    RETURN_ERROR_RA_SCREENNO: Result := '�Ѿ��и���ʾ����Ϣ,��Ҫ����' +
                      '�趨����DeleteScreenɾ������ʾ�������.';
    RETURN_ERROR_NOFIND_AREAFILE: Result := 'û���ҵ���Ч�������ļ�';
    RETURN_ERROR_NOFIND_AREA: Result := 'û���ҵ���Ч����ʾ����,����' +
                        'ʹ��AddScreenProgramBmpTextArea���������Ϣ.';
    RETURN_ERROR_NOFIND_PROGRAM: Result := 'û���ҵ���Ч����ʾ����Ŀ.����' +
                        'ʹ��AddScreenProgram�������ָ����Ŀ.';
    RETURN_ERROR_NOFIND_SCREENNO: Result := 'ϵͳ��û�в��ҵ�����ʾ��,����' +
                        'ʹ��AddScreen���������ʾ��.';
    RETURN_ERROR_NOW_SENDING: Result := 'ϵͳ�����������ʾ��ͨѶ,���Ժ���ͨѶ.';
    RETURN_ERROR_OTHER: Result := '��������.';
    RETURN_NOERROR: Result := '�����ɹ�' else Result := 'δ����Ĵ���.';
  end;
end;

//Desc: ���������ļ�
function TCardManager.SendData(const nFile: string): Boolean;
begin
  Result := FSender.Start(nFile);
end;

initialization
  gCardManager := TCardManager.Create;
finalization
  FreeAndNil(gCardManager);
end.


