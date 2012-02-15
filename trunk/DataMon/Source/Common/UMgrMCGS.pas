{*******************************************************************************
  ����: dmzn@163.com 2011-5-25
  ����: MCGSʵʱ���ݿ�ɼ�������
*******************************************************************************}
unit UMgrMCGS;

{$I Link.Inc}
interface

uses
  Windows, SysUtils, Classes, ActiveX, ComObj, Variants, IniFiles, UWaitItem,
  ULibFun, UMgrSync, USysConst;

type
  TMCGSSyncType = (stData, stWarnHint, stNoRun);
  //ͬ������:����,��ʾ,δ����

  TMCGSItemStatus = (isNone, isAdd, isUpdate);
  //״̬:δ֪,���,����

  TMCGSItemData = record
    FCH,FDH: string;            //����,����
    FSerial: Word;              //����˳��
    FStatus: TMCGSItemStatus;   //״̬
    FLastUpdate: TDateTime;     //�ϴθ���
  end;
  //����������

  PMCGSParamItem = ^TMCGSParamItem;
  TMCGSParamItem = record
    FCH,FDH: string[32];        //����,����
    FSerial: Word;              //����˳��
    Fw1,Fw2,Fw3,Fw4: Double;    //�¶�
    Fs1,Fs2,Fs3,Fs4: Double;    //ʪ��
    Ffj1,Ffj2,Ffj3,Ffj4,Ffj5: Word; //���
    Ffjo,Ffjc: Word;		        //�����ͣ
    Ftfjb: Word;                //ͨ�缶��
    Ftfbj: Word;                //ͨ�籨��
    Frs1,Frs2,Frs3,Frs4:Word;   //��ˮ
    Frld,Frlh: Double;          //����
    Fllt,Fllk: Double;	        //����
    Frll: Double;		            //������
    Fslt,fslk: Word;	          //ˮ��
    Fsww: Double;	              //�����¶�
    Fcold: Word;	              //��
    Fhot: Word;	                //��
    Fweight:Double;             //����
    Fmw: Double;                //Ŀ���¶�
    Faq: Double;	              //����
    Ffy1,Ffy2: Double;	        //��ѹ
    Fslkd: Double;              //ˮ������
    Fslb:Double;                //ˮ����
    Fccl,Fccr:Double;           //�ര
  end;
  //ÿ����ɼ�������

  TMCGSParamItems = array of TMCGSParamItem;
  //������

  TMCGSManager = class;

  TMCGSReader = class(TThread)
  private
    FOwner: TMCGSManager;
    //������
    FWaiter: TWaitObject;
    //�ȴ�����
    FDataCenter: OleVariant;
    //��������
  protected
    procedure DoExecute;
    procedure Execute; override;
    //�߳���
    procedure HintMsg(const nStr: string);
    //������ʾ
    function ReadParam(const nDH: Integer; var nItem: TMCGSParamItem): Boolean;
    //��ȡ����
  public
    constructor Create(AOwner: TMCGSManager);
    destructor Destroy; override;
    //�����ͷ�
    procedure Stop;
    //��ֹ�߳�
  end;

  TMCGSOnItem = procedure (const nItem: TMCGSItemData) of Object;
  TMCGSOnData = procedure (const nData: TMCGSParamItem) of Object;
  //�¼�

  TMCGSManager = class(TObject)
  private
    FCH: string;
    //����
    FDH: array of TMCGSItemData;
    //�����б�
    FInterval: Integer;
    //�ɼ�Ƶ��
    FReader: TMCGSReader;
    //�ɼ��߳�
    FSyncer: TDataSynchronizer;
    //ͬ������
    FOnItem: TMCGSOnItem;
    FOnData: TMCGSOnData;
    FOnDataSync: TMCGSOnData;
    //�¼����
  protected
     procedure DoSync(const nData: Pointer; const nSize: Cardinal);
     procedure DoSyncFree(const nData: Pointer; const nSize: Cardinal);
     //ͬ���¼�
     function GetStatus: Boolean;
     //��ȡ״̬
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure SetDH(const nCH,nDH: string);
    //���ö���
    function StartReader(var nHint: string): Boolean;
    procedure StopReader;
    //��ͣ�ɼ�
    property CH: string read FCH;
    property IsBusy: Boolean read GetStatus;
    property Interval: Integer read FInterval write FInterval;
    property OnItem: TMCGSOnItem read FOnItem write FOnItem;
    property OnData: TMCGSOnData read FOnData write FOnData;
    property OnDataSync: TMCGSOnData read FOnDataSync write FOnDataSync;
    //�������
  end;

var
  gMCGSManager: TMCGSManager = nil;
  //ȫ��ʹ��

implementation

type
  TVarItem = record
    FVarName: string;    //������
    FIndex: Integer;     //��������
  end;

  TVarName = record
    FInnerName: string;  //�ڲ�����
    FOutName: string;    //�ⲿ����
  end;

const
  cSize_HintBuffer = 200;

  cDHNull = '!';
  //null dh

  cVarItem: array[0..39] of TVarItem = ((FVarName:'���1_%d'; FIndex:0),
     (FVarName:'���2_%d';     FIndex:1), (FVarName:'���3_%d';     FIndex:2),
     (FVarName:'���4_%d';     FIndex:3), (FVarName:'���5_%d';     FIndex:4),
     (FVarName:'�����ʼ1_%d'; FIndex:5), (FVarName:'���ֹͣ1_%d'; FIndex:6),
     (FVarName:'ͨ�缶��1_%d'; FIndex:7), (FVarName:'��ˮ1_%d';     FIndex:8),
     (FVarName:'��ˮ2_%d';     FIndex:9), (FVarName:'��ˮ3_%d';     FIndex:10),
     (FVarName:'��ˮ4_%d';     FIndex:11),(FVarName:'Ŀ���¶�1_%d'; FIndex:12),
     (FVarName:'�¶�1_%d';     FIndex:13),(FVarName:'�¶�2_%d';     FIndex:14),
     (FVarName:'�¶�3_%d';     FIndex:15),(FVarName:'�¶�4_%d';     FIndex:16),
     (FVarName:'ʪ��1_%d';     FIndex:17),(FVarName:'ʪ��2_%d';     FIndex:18),
     (FVarName:'ʪ��3_%d';     FIndex:19),(FVarName:'ʪ��4_%d';     FIndex:20),
     (FVarName:'����d_%d';     FIndex:21),(FVarName:'����h_%d';     FIndex:22),
     (FVarName:'����t_%d';     FIndex:23),(FVarName:'����k_%d';     FIndex:24),
     (FVarName:'ˮ��t_%d';     FIndex:25),(FVarName:'ˮ��k_%d';     FIndex:26),
     (FVarName:'�����¶�1_%d'; FIndex:27),(FVarName:'��1_%d';       FIndex:28),
     (FVarName:'��1_%d';       FIndex:29),(FVarName:'ͨ�籨��1_%d'; FIndex:30),
     (FVarName:'������1_%d';   FIndex:31),(FVarName:'����1_%d';     FIndex:32),
     (FVarName:'����1_%d';     FIndex:33),(FVarName:'��ѹ1_%d';     FIndex:34),
     (FVarName:'��ѹ2_%d';     FIndex:35),(FVarName:'ˮ������1_%d'; FIndex:36),
     (FVarName:'ˮ����1_%d';   FIndex:37),(FVarName:'�രl_%d';     FIndex:38),
     (FVarName:'�രr_%d';     FIndex:39));
  //MCGS variant

var
  gVarNames: array of TVarName;
  //����ӳ��

function LoadVarNames: Boolean;
var nStr: string;
    nIni: TIniFile;
    nList: TStrings;
    i,nIdx,nCount: Integer;
begin
  Result := False;
  nList := nil;
  SetLength(gVarNames, 0);

  nIni := TIniFile.Create(gPath + 'DH.ini');
  try
    nList := TStringList.Create;
    nIni.ReadSection('DH', nList);
    if nList.Count < 1 then Exit;

    nIdx := 0;
    nCount := nList.Count - 1;

    for i:=0 to nCount do
    begin
      nStr := nIni.ReadString('DH', nList[i], '');
      if nStr = '' then Continue;

      SetLength(gVarNames, nIdx+1);
      gVarNames[nIdx].FInnerName := nList[i];
      gVarNames[nIdx].FOutName := nStr;
      Inc(nIdx);
    end;

    Result := Length(gVarNames) > 0;
  finally
    nList.Free;
    nIni.Free;
  end;
end;

function GetOutName(const nInner: string): string;
var nIdx: Integer;
begin
  Result := '';
  for nIdx:=Low(gVarNames) to High(gVarNames) do
  if gVarNames[nIdx].FInnerName = nInner then
  begin
    Result := gVarNames[nIdx].FOutName; Exit;
  end;
end;

//------------------------------------------------------------------------------
constructor TMCGSReader.Create(AOwner: TMCGSManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FDataCenter := Unassigned;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := FOwner.FInterval * 1000;
end;

destructor TMCGSReader.Destroy;
begin
  FWaiter.Free;
  FDataCenter := Unassigned;
  inherited;
end;

procedure TMCGSReader.HintMsg(const nStr: string);
var nBuf: PChar;
begin
  GetMem(nBuf, cSize_HintBuffer);
  StrLCopy(nBuf, PChar(nStr), cSize_HintBuffer);

  with FOwner do
  begin
    FSyncer.AddData(nBuf, Ord(stWarnHint));
    FSyncer.ApplySync;
  end;
end;

procedure TMCGSReader.Stop;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TMCGSReader.Execute;
begin
  CoInitialize(nil);

  while not Terminated do
  try
    DoExecute;
  except
    on E:Exception do
    begin
      {$IFDEF DEBUG}
      HintMsg(E.Message);
      {$ENDIF}

      Sleep(320);
    end;
  end;

  CoUninitialize;
end;

procedure TMCGSReader.DoExecute;
var nIdx: Integer;
    nVar: OleVariant;
    nItem: TMCGSParamItem;
    nPItem: PMCGSParamItem;
begin 
  with FOwner do
  begin
    FWaiter.EnterWait;
    if Terminated then Exit;

    try
      if VarIsEmpty(FDataCenter) then
      begin
        FDataCenter := GetActiveOleObject('McgsRun.DataCentre');
        if VarIsEmpty(FDataCenter) then Exit;
      end;

      nVar := FDataCenter.McgsDataNum;
      //check object valid
    except
      on E:Exception do
      begin
        FDataCenter := Unassigned;
        //has invalid

        {$IFDEF DEBUG}
        HintMsg(E.Message);
        {$ENDIF}

        FSyncer.AddData(nil, Ord(stNoRun));
        FSyncer.ApplySync;
        //update ui status
        Exit;
      end;
    end;

    {$IFDEF DEBUG}
    HintMsg('������гɹ�,��ʼ��ȡ����.');
    {$ENDIF}

    for nIdx:=Low(FDH) to High(FDH) do
    begin
      if FDH[nIdx].FDH = cDHNull then Continue;
      //null

      nItem.FCH := FDH[nIdx].FCH;
      nItem.FDH := FDH[nIdx].FDH;
      nItem.FSerial := FDH[nIdx].FSerial;

      if not ReadParam(nIdx+1, nItem) then Continue;
      //read params

      {$IFDEF DEBUG}
      HintMsg('���ݶ�ȡ���,ͬ������.');
      {$ENDIF}

      if Assigned(FOnData) then
        FOnData(nItem);
      //thread event

      New(nPItem);
      nPItem^ := nItem;

      FSyncer.AddData(nPItem, 0);
      FSyncer.ApplySync;
    end;
  end;
end;

//Desc: ��ʵʱ���ݿ��ж�ȡ����ΪnDH�Ĳ���
function TMCGSReader.ReadParam(const nDH: Integer; var nItem: TMCGSParamItem): Boolean;
var nIdx: Integer;
    nName,nVal,nRes: OleVariant;
begin
  for nIdx:=Low(cVarItem) to High(cVarItem) do
  with cVarItem[nIdx] do
  begin
    nName := Format(FVarName, [nDH]);
    nName := GetOutName(nName);

    {$IFDEF DEBUG}
    HintMsg(Format('��ʼ��ȡ����:[ %s ] -> [ %s ]', [FVarName, nName]));
    {$ENDIF}

    if nName = '' then
    begin
      case FIndex of
       0: nItem.Ffj1 := 0;
       1: nItem.Ffj2 := 0;
       2: nItem.Ffj3 := 0;
       3: nItem.Ffj4 := 0;
       4: nItem.Ffj5 := 0;
       5: nItem.Ffjo := 0;
       6: nItem.Ffjc := 0;
       7: nItem.Ftfjb := 0;
       8: nItem.Frs1 := 0;
       9: nItem.Frs2 := 0;
       10: nItem.Frs3 := 0;
       11: nItem.Frs4 := 0;
       12: nItem.Fmw := 0;
       13: nItem.Fw1 := 0;
       14: nItem.Fw2 := 0;
       15: nItem.Fw3 := 0;
       16: nItem.Fw4 := 0;
       17: nItem.Fs1 := 0;
       18: nItem.Fs2 := 0;
       19: nItem.Fs3 := 0;
       20: nItem.Fs4 := 0;
       21: nItem.Frld := 0;
       22: nItem.Frlh := 0;
       23: nItem.Fllt := 0;
       24: nItem.Fllk := 0;
       25: nItem.Fslt := 0;
       26: nItem.fslk := 0;
       27: nItem.Fsww := 0;
       28: nItem.Fcold := 0;
       29: nItem.Fhot := 0;
       30: nItem.Ftfbj := 0;
       31: nItem.Frll := 0;
       32: nItem.Fweight := 0;
       33: nItem.Faq := 0;
       34: nItem.Ffy1 := 0;
       35: nItem.Ffy2 := 0;
       36: nItem.Fslkd := 0;
       37: nItem.Fslb := 0;
       38: nItem.Fccl := 0;
       39: nItem.Fccr := 0;
      end;

      {$IFDEF DEBUG}
      HintMsg(Format('����[ %s ]����Ҫ����,������.', [FVarName]));
      {$ENDIF}
      Continue;
    end; //default value

    nRes := FDataCenter.GetValueFromName(nName, nVal);
    Result := nRes = 0;

    if not Result then
    begin
      HintMsg(Format('����[ %s ]�������,������.', [nName]));
      Exit;
    end;

    case FIndex of
     0: nItem.Ffj1 := nVal;
     1: nItem.Ffj2 := nVal;
     2: nItem.Ffj3 := nVal;
     3: nItem.Ffj4 := nVal;
     4: nItem.Ffj5 := nVal;
     5: nItem.Ffjo := nVal;
     6: nItem.Ffjc := nVal;
     7: nItem.Ftfjb := nVal;
     8: nItem.Frs1 := nVal;
     9: nItem.Frs2 := nVal;
     10: nItem.Frs3 := nVal;
     11: nItem.Frs4 := nVal;
     12: nItem.Fmw := nVal;
     13: nItem.Fw1 := nVal;
     14: nItem.Fw2 := nVal;
     15: nItem.Fw3 := nVal;
     16: nItem.Fw4 := nVal;
     17: nItem.Fs1 := nVal;
     18: nItem.Fs2 := nVal;
     19: nItem.Fs3 := nVal;
     20: nItem.Fs4 := nVal;
     21: nItem.Frld := nVal;
     22: nItem.Frlh := nVal;
     23: nItem.Fllt := nVal;
     24: nItem.Fllk := nVal;
     25: nItem.Fslt := nVal;
     26: nItem.fslk := nVal;
     27: nItem.Fsww := nVal;
     28: nItem.Fcold := nVal;
     29: nItem.Fhot := nVal;
     30: nItem.Ftfbj := nVal;
     31: nItem.Frll := nVal;
     32: nItem.Fweight := nVal;
     33: nItem.Faq := nVal;
     34: nItem.Ffy1 := nVal;
     35: nItem.Ffy2 := nVal;
     36: nItem.Fslkd := nVal;
     37: nItem.Fslb := nVal;
     38: nItem.Fccl := nVal;
     39: nItem.Fccr := nVal;
    end;

    nVal := Unassigned;
    //set item value
    {$IFDEF DEBUG}
    HintMsg(nName + '�������.');
    {$ENDIF}
  end;

  Result := True;
end;

//------------------------------------------------------------------------------
constructor TMCGSManager.Create;
begin
  FCH := '';
  SetLength(FDH, 0);

  FInterval := 5;
  FReader := nil;

  FSyncer := TDataSynchronizer.Create;
  FSyncer.SyncEvent := DoSync;
  FSyncer.SyncFreeEvent := DoSyncFree;
end;

destructor TMCGSManager.Destroy;
begin
  StopReader;
  FSyncer.Free;
  inherited;
end;

function TMCGSManager.GetStatus: Boolean;
begin
  Result := Assigned(FReader);
end;

//Date: 2011-5-25
//Parm: ����;����
//Desc: ���ó���,����
procedure TMCGSManager.SetDH(const nCH,nDH: string);
var nIdx: Integer;
    nList: TStrings;
begin
  if IsBusy then Exit;
  //running

  nList := TStringList.Create;
  try
    FCH := nCH;
    SetLength(FDH, 0);

    if not SplitStr(nDH, nList, 0, ',') then Exit;
    SetLength(FDH, nList.Count);

    for nIdx:=Low(FDH) to High(FDH) do
    begin
      with FDH[nIdx] do
      begin
        FCH := nCH;
        FDH := nList[nIdx];
        FSerial := nIdx;
        FStatus := isAdd;
        FLastUpdate := Now;
      end;
      
      if Assigned(FOnItem) then
        FOnItem(FDH[nIdx]);
      //xxxxx
    end;
  finally
    nList.Free;
  end;
end;

//Desc: ֹͣ�ɼ�
procedure TMCGSManager.StopReader;
var nIdx: Integer;
begin
  if Assigned(FReader) then
  begin
    FReader.Stop;
    FReader := nil;
  end;

  for nIdx:=Low(FDH) to High(FDH) do
  begin
    FDH[nIdx].FStatus := isNone;
    FDH[nIdx].FLastUpdate := Now;
    
    if Assigned(FOnItem) then
      FOnItem(FDH[nIdx]);
    //xxxxx
  end;
end;

//Desc: �����ɼ�
function TMCGSManager.StartReader(var nHint: string): Boolean;
begin
  Result := False;
  if FCH = '' then
  begin
    nHint := '������Ч'; Exit;
  end;

  if Length(FDH) < 1 then
  begin
    nHint := '������Ч'; Exit;
  end;

  if not LoadVarNames then
  begin
    nHint := '��ȡ���������'; Exit;
  end;

  if not Assigned(FReader) then
    FReader := TMCGSReader.Create(Self);
  Result := Assigned(FReader);
end;

//Desc: �̵߳�������ͬ������
procedure TMCGSManager.DoSync(const nData: Pointer; const nSize: Cardinal);
var nIdx: Integer;
    nItem: PMCGSParamItem;
begin
  case nSize of
   Ord(stNoRun):
    begin
      if Assigned(FOnItem) then
      begin
        for nIdx:=Low(FDH) to High(FDH) do
        begin
          with FDH[nIdx] do
          begin
            FStatus := isNone;
            FLastUpdate := Now;
          end;

          FOnItem(FDH[nIdx]);
        end;

        Exit; //datacentre invalid
      end;
    end;
   Ord(stData):
    begin
      nItem := nData;
      if Assigned(FOnItem) then
      begin
        with FDH[nItem.FSerial] do
        begin
          FStatus := isUpdate;
          FLastUpdate := Now;
        end;

        FOnItem(FDH[nItem.FSerial]);
      end;

      if Assigned(FOnDataSync) then
        FOnDataSync(nItem^);
      //xxxxx
    end;
   Ord(stWarnHint):
    begin
      gDebugLog(StrPas(PChar(nData)), False);
    end;
  end;
end;

//Desc: �ͷ���Դ
procedure TMCGSManager.DoSyncFree(const nData: Pointer; const nSize: Cardinal);
begin
  case nSize of
    Ord(stData): Dispose(PMCGSParamItem(nData));
    Ord(stWarnHint): FreeMem(nData, cSize_HintBuffer);
  end;
end;

initialization
  gMCGSManager := TMCGSManager.Create;
finalization
  FreeAndNil(gMCGSManager);
end.


