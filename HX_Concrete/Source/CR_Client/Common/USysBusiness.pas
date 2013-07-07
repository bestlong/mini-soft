{*******************************************************************************
  ����: dmzn@163.com 2007-10-09
  ����: ϵͳҵ���߼���Ԫ
*******************************************************************************}
unit USysBusiness;

interface

uses
  Windows, Classes, Controls, SysUtils, ULibFun, UBusinessWorker,
  UBusinessConst, UBusinessPacker, UClientWorker, UDataModule, UDataReport,
  USysNumber, UFormBase, UFormCtrl, UFormDateFilter, USysDB, USysConst;

type
  TLadingTruckItem = record
    FCard     : string;      //�ſ���
    FTruck    : string;      //���ƺ�
    FStatus   : string;      //��ǰ
    FNext     : string;      //��һ

    FOrder    : string;      //������
    FOrderTy  : string;      //����
    FCusName  : string;      //�ͻ�����

    FBill     : string;      //������
    FType     : string;      //����
    FStock    : string;      //Ʒ��
    FValue    : Double;      //�����
  end;

  TLadingTruckItems = array of TLadingTruckItem;

  PZTLineItem = ^TZTLineItem;
  TZTLineItem = record
    FID       : string;      //���
    FName     : string;      //����
    FStock    : string;      //Ʒ��
    FWeight   : Integer;     //����
    FValid    : Boolean;     //�Ƿ���Ч
  end;

  PZTTruckItem = ^TZTTruckItem;
  TZTTruckItem = record
    FTruck    : string;      //���ƺ�
    FLine     : string;      //ͨ��
    FBill     : string;      //�����
    FValue    : Double;      //�����
    FDai      : Integer;     //����
    FTotal    : Integer;     //����
    FInFact   : Boolean;     //�Ƿ����
    FIsRun    : Boolean;     //�Ƿ�����    
  end;

  TZTLineItems = array of TZTLineItem;
  TZTTruckItems = array of TZTTruckItem;

//------------------------------------------------------------------------------
function GetQueryField(const nType: Integer): string;
//��ȡ��ѯ���ֶ�

procedure InitPoundItem(var nData: TWorkerBusinessPound);
//��ʼ������Ϣ
function ReadPoundLog(var nData: TWorkerBusinessPound): Boolean;
//��ȡ���ع�����Ϣ
function PoundReadBill(var nData: TWorkerBusinessPound): Boolean;
//��ȡ������
function PoundReadOrder(var nData: TWorkerBusinessPound): Boolean;
//��ȡԭ�ϵ�
function PoundDeleteLog(const nPound: string): Boolean;
function PoundDeleteSAPLog(const nPound: string): Boolean;
//ɾ��������¼
function PoundReadTruck(var nData: TWorkerBusinessPound): Boolean;
//��ȡ����������Ϣ
function PoundLoadMaterails(const nID,nName: TStrings): Boolean;
//��ȡ�����б�
function PoundSaveData(var nData: TWorkerBusinessPound): Boolean;
//�����������

function SetBillCard(const nBill,nTruck: string; nVerify: Boolean): Boolean;
//�������ƿ�
function SaveBillCard(const nBill,nTruck,nCard: string;
 const nCardA: string = ''; const nCardB: string = ''): Boolean;
//������󶨴ſ�
function LogoutBillCard(const nCard: string; const nBill: string = ''): Boolean;
//ע����
function GetLadingBills(const nCard,nPost: string;
 var nData: TLadingTruckItems): Boolean;
//��ȡָ����λ�������б�
procedure LoadBillItemToMC(const nItem: TLadingTruckItem; const nMC: TStrings;
 const nDelimiter: string = ';');
//���뽻������Ϣ
function SaveLadingBills(const nPost: string; nData: TLadingTruckItems): Boolean;
//����ָ����λ�Ľ�����

function ReadPoundCard(const nPound: string): string;
//��ȡ�����ſ���
function CheckSAPServiceStatus: Boolean;
//���SAP����״̬
function LoadTruckQueue(var nLines: TZTLineItems; var nTrucks: TZTTruckItems;
 const nRefreshLine: Boolean = False): Boolean;
//��ȡ��������
function MakeTruckOutQueue(const nLine,nTruck: string): Boolean;
//��������
procedure PrinterEnable(const nTunnel: string; const nEnable: Boolean);
//��ͣ�����

function PrintBillReport(const nBill,nStock: string; nAsk: Boolean): Boolean;
//��ӡ������
function PrintPoundReport(const nPound: string; nAsk: Boolean): Boolean;
//��ӡ������

implementation

type
  TMaterailsItem = record
    FID   : string;         //���
    FName : string;         //����
  end;
  
var
  gMaterails: array of TMaterailsItem;
  //ȫ��ʹ��

//------------------------------------------------------------------------------
//Date: 2012-3-20
//Parm: ��ѯ����
//Desc: ��ȡnType������ֶ�
function GetQueryField(const nType: Integer): string;
var nIn: TWorkerQueryFieldData;
    nOut: TWorkerQueryFieldData;
    nWorker: TBusinessWorkerBase;
begin
  Result := '*';
  Exit;
  //if gSysParam.FNetBusMIT then Exit;
  
  nWorker := nil;
  try
    nIn.FType := nType;
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_GetQueryField);

    if nWorker.WorkActive(@nIn, @nOut) then
    begin
      Result := Trim(nOut.FData);
      if Result = '' then Result := '*';
    end;
  finally
    gBusinessWorkerManager.RelaseWorkder(nWorker);
  end;
end;

//------------------------------------------------------------------------------
//Desc: ��ʼ�����ؼ�¼
procedure InitPoundItem(var nData: TWorkerBusinessPound);
var nPacker: TBusinessPackerBase;
begin
  nPacker := gBusinessPackerManager.LockPacker(sBus_PoundCommand);
  try
    nPacker.InitData(@nData, False);
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
  end;
end;

//Desc: ��ȡ������¼
function ReadPoundLog(var nData: TWorkerBusinessPound): Boolean;
var nStr: string;
begin
  Result := False;
  nData.FNewPound := True;
  nData.FStatus := sFlag_TruckBFP;

  if nData.FPound <> '' then
  begin
    nStr := 'Select * From %s Where P_ID=''%s''';
    nStr := Format(nStr, [sTable_PoundLog, nData.FPound]);
  end else //������

  if nData.FCard <> '' then
  begin
    if Pos('+', nData.FCard) > 0 then
    begin
      System.Delete(nData.FCard, 1, 1);
      nStr := nStr + 'P_Bill=''$ID''';
    end else

    if Pos('-', nData.FCard) > 0 then
    begin
      System.Delete(nData.FCard, 1, 1);
      nStr := nStr + 'P_Card=''$ID''';
    end else
    begin
      nStr := nStr + 'P_Card=''$ID'' Or P_Bill=''$ID''';
    end;

    nStr := 'Select * From $PD Where ' + nStr;
    nStr := MacroValue(nStr, [MI('$PD', sTable_PoundLog),
            MI('$ID', nData.FCard)]);
    //xxxxx
  end else //���۵�

  if nData.FTruck = '' then
  begin
    Exit;
  end else
  begin
    nStr := 'Select * From %s Where P_Truck=''%s'' And ' +
            '(IsNull(P_PDate,'''') = '''' Or IsNull(P_MDate,'''') = '''')';
    nStr := Format(nStr, [sTable_PoundLog, nData.FTruck]);
  end;

  with FDM.QueryTemp(nStr, gSysParam.FNetBusMIT) do
  begin
    Result := RecordCount > 0;
    if not Result then Exit;

    with nData do
    begin
      FNewPound    := False;
      FType        := FieldByName('P_Type').AsString;
      FPound       := FieldByName('P_ID').AsString;
      FBillID      := FieldByName('P_Bill').AsString;
      FOrder       := FieldByName('P_Order').AsString;
      FTruck       := FieldByName('P_Truck').AsString;
      FCusID       := FieldByName('P_CusID').AsString;
      FCusName     := FieldByName('P_CusName').AsString;
      FMType       := FieldByName('P_MType').AsString;
      FMID         := FieldByName('P_MID').AsString;
      FMName       := FieldByName('P_MName').AsString;
      FFactNum     := FieldByName('P_FactID').AsString;
      FLimValue    := FieldByName('P_LimValue').AsFloat;
      FPValue      := FieldByName('P_PValue').AsFloat;
      FPDate       := FieldByName('P_PDate').AsString;
      FPMan        := FieldByName('P_PMan').AsString;
      FMValue      := FieldByName('P_MValue').AsFloat;
      FMDate       := FieldByName('P_MDate').AsString;
      FMMan        := FieldByName('P_MMan').AsString;

      FStation     := FieldByName('P_Station').AsString;
      FDirect      := FieldByName('P_Direction').AsString;
      FPModel      := FieldByName('P_PModel').AsString;
      FStatus      := FieldByName('P_Status').AsString;

      if FStatus = sFlag_TruckBFP then
           FStatus := sFlag_TruckBFM
      else FStatus := sFlag_TruckBFP;
    end;
  end;
end;

//Date: 2012-3-22
//Desc: ��ȡnData.FBill�Ĺ�����Ϣ
function PoundReadBill(var nData: TWorkerBusinessPound): Boolean;
var nWorker: TBusinessWorkerBase;
begin
  if gSysParam.FNetBusMIT then
  begin
    ReadPoundLog(nData);
    Result := True;
    Exit;
  end;

  nWorker := nil;
  try
    nData.FCommand := cBC_ReadBillInfo;
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_PoundCommand);

    Result := nWorker.WorkActive(@nData, @nData);
    Exit;
  finally
    gBusinessWorkerManager.RelaseWorkder(nWorker);
  end;
end;

//Date: 2012-3-27
//Desc: ��ȡnData.FOrder������Ϣ
function PoundReadOrder(var nData: TWorkerBusinessPound): Boolean;
var nWorker: TBusinessWorkerBase;
begin
  if gSysParam.FNetBusMIT then
  begin
    ReadPoundLog(nData);
    Result := True;
    Exit;
  end;
  
  nWorker := nil;
  try
    nData.FCommand := cBC_ReadOrderInfo;
    nData.FFactNum := gSysParam.FFactNum;
    nData.FSAPOK := not (gSysParam.FNetSAPSrv and gSysParam.FNetSAPMIT);
    
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_PoundCommand);
    Result := nWorker.WorkActive(@nData, @nData);
    if not Result then Exit;

    if nData.FBase.FErrCode = 'W.00' then
    begin
      ShowDlg(nData.FBase.FErrDesc, sHint);
    end;
  finally
    gBusinessWorkerManager.RelaseWorkder(nWorker);
  end;
end;

//Date: 2012-3-31
//Parm: ���ؼ�¼
//Desc: ɾ��nPound��¼
function PoundDeleteLog(const nPound: string): Boolean;
var nStr: string;
begin
  nStr := 'Delete From %s Where P_ID=''%s''';
  nStr := Format(nStr, [sTable_PoundLog, nPound]);
  
  FDM.ExecuteSQL(nStr, False);
  FDM.ExecuteSQL(nStr, True);
  Result := True;
end;

//Date: 2012-7-6
//Parm: ���ؼ�¼��
//Desc: ɾ��SAP������¼
function PoundDeleteSAPLog(const nPound: string): Boolean;
var nIn,nOut: TWorkerBusinessPound;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := cBC_DeletePoundLog;
    nIn.FPound := nPound;

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_PoundCommand);
    Result := nWorker.WorkActive(@nIn, @nOut); 
  finally
    gBusinessWorkerManager.RelaseWorkder(nWorker);
  end;
end;

//Date: 2012-3-22
//Desc: ��ȡnData.FTruck�Ĺ�����Ϣ
function PoundReadTruck(var nData: TWorkerBusinessPound): Boolean;
var nItem: TWorkerBusinessPound;
    nWorker: TBusinessWorkerBase;
begin
  if gSysParam.FNetBusMIT then
  begin
    ReadPoundLog(nData);
    Result := True;
    Exit;
  end;

  nWorker := nil;
  try
    nData.FCommand := cBC_ReadTruckInfo;
    nData.FBase.FParam := sParam_NoHintOnError;

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_PoundCommand);
    Result := nWorker.WorkActive(@nData, @nItem);

    if Result then
         nData := nItem
    else Result := True;
  finally
    gBusinessWorkerManager.RelaseWorkder(nWorker);
  end;
end;

//------------------------------------------------------------------------------
//Desc: ���Դӻ�����������
function LoadMaterailsFromBuffer(const nID,nName: TStrings): Boolean;
var nIdx: Integer;
begin
  Result := Length(gMaterails) > 0;
  if not Result then Exit;

  nID.Clear;
  nName.Clear;

  for nIdx:=Low(gMaterails) to High(gMaterails) do
  begin
    nID.Add(gMaterails[nIdx].FID);
    nName.Add(gMaterails[nIdx].FName);
  end;
end;

//Desc: �ӱ������ݿ��ȡ����
function ReadMaterails(const nID,nName: TStrings): Boolean;
var nStr: string;
    nIdx: Integer;
begin
  nStr := 'Select M_ID,M_Name From %s Order By M_ID ASC';
  nStr := Format(nStr, [sTable_Materails]);

  with FDM.QueryTemp(nStr, True) do
  begin
    SetLength(gMaterails, RecordCount);
    Result := Length(gMaterails) > 0;
    if not Result then Exit;

    nIdx := 0;
    First;

    while not Eof do
    begin
      gMaterails[nIdx].FID := Fields[0].AsString;
      gMaterails[nIdx].FName := Fields[1].AsString;

      Inc(nIdx);
      Next;
    end;

    LoadMaterailsFromBuffer(nID, nName);
  end;
end;

//Desc: ���±�������
procedure SaveMaterails;
var nStr: string;
    nIdx: Integer;
begin
  nStr := 'Delete From ' + sTable_Materails;
  FDM.ExecuteSQL(nStr, True);

  for nIdx:=Low(gMaterails) to High(gMaterails) do
  with gMaterails[nIdx] do
  begin
    nStr := 'Insert Into %s(M_ID,M_Name) Values(''%s'',''%s'')';
    nStr := Format(nStr, [sTable_Materails, FID, FName]);
    FDM.ExecuteSQL(nStr, True);
  end;

  nStr := 'Update %s Set D_ParamB=''%s'' Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, Date2Str(NOw), sFlag_LoadMaterails]);
  FDM.ExecuteSQL(nStr, True);
end;

//Desc: ���������Ƿ�ո���
function IsUpdateMaterailsJust: Boolean;
var nStr: string;
    nDate: TDateTime;
begin
  nStr := 'Select D_Value,D_ParamB From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict,sFlag_LoadMaterails]);

  with FDM.QueryTemp(nStr, True) do
  if RecordCount > 0 then
  begin
    nDate := Now - Str2Date(Fields[1].AsString);
    if nDate >= Fields[0].AsInteger then
         nDate := 1
    else nDate := 0;
  end else nDate := 0;

  Result := nDate = 0;
end;

//Date: 2012-3-22
//Parm: ���Ϻ�;������
//Desc: ���õ������б�
function PoundLoadMaterails(const nID,nName: TStrings): Boolean;
var nIdx: Integer;
    nListA,nListB: TStrings;
    nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  Result := LoadMaterailsFromBuffer(nID, nName);
  if Result then Exit;
  //buffer load ok

  if gSysParam.FNetBusMIT or IsUpdateMaterailsJust then
  begin
    Result := ReadMaterails(nID, nName);
    Exit;
  end;

  nListA := nil;
  nListB := nil;
  nWorker := nil;
  try
    nIn.FCommand := cBC_LoadMaterails;
    nIn.FSAPOK := not (gSysParam.FNetSAPSrv and gSysParam.FNetSAPMIT);
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessCommand);

    Result := nWorker.WorkActive(@nIn, @nOut);
    if not Result then
    begin
      ReadMaterails(nID, nName);
      Exit;
    end;

    nListA := TStringList.Create;
    nListA.Text := PackerDecodeStr(nOut.FData);

    if nListA.Count < 1 then Exit;
    nListB := TStringList.Create;
    SetLength(gMaterails, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      gMaterails[nIdx].FID := nListB.Values['ID'];
      gMaterails[nIdx].FName := nListB.Values['Name'];
    end;

    Result := LoadMaterailsFromBuffer(nID, nName);
    if Result then SaveMaterails;
  finally
    nListA.Free;
    nListB.Free;
    gBusinessWorkerManager.RelaseWorkder(nWorker);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2012-3-25
//Parm: ����;����;��������
//Desc: ��ȡnGroup.nObject��ǰ�ļ�¼���
function GetSerailID(const nGroup,nObject: string): string;
var nStr,nP,nB: string;
begin
  nStr := 'Update %s Set B_Base=B_Base+1 ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, nGroup, nObject]);
  FDM.ExecuteSQL(nStr, True);

  nStr := 'Select B_Prefix,B_IDLen,B_Base From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, nGroup, nObject]);

  with FDM.QueryTemp(nStr, True) do
  begin
    nP := Fields[0].AsString;
    nB := Fields[2].AsString;

    nStr := StringOfChar('0', Fields[1].AsInteger-Length(nP)-Length(nB));
    Result := nP + nStr + nB;
  end;
end;

//Desc: ���汾������
function SavePound(var nData: TWorkerBusinessPound): Boolean;
var nNew: Boolean;
    nStr,nWhere: string;
begin
  with nData do
  try
    if FPound <> '' then
    begin
      nStr := 'Select Count(*) From %s Where P_ID=''%s''';
      nStr := Format(nStr, [sTable_PoundLog, FPound]);
      nNew := FDM.QueryTemp(nStr, True).Fields[0].AsInteger < 1;
    end else nNew := True;

    if nNew then
    begin
      if FPound = '' then
        FPound := GetSerailID(sFlag_SerailSYS, sFlag_PoundLog);
      //xxxxx
    end else
    begin
      nWhere := Format('P_ID=''%s''', [FPound]);
    end;

    nStr := MakeSQLByStr([
      SF('P_ID', FPound),
      SF('P_Type', FType),
      SF('P_Bill', FBillID),
      SF('P_Order', FOrder),
      SF('P_Truck', FTruck),
      SF('P_CusID', FCusID),
      SF('P_CusName', FCusName),
      SF('P_MID', FMID),
      SF('P_MName', FMName),
      SF('P_MType', FMType),
      SF('P_LimValue', FLimValue, sfVal),
      SF('P_PValue', '$PV', sfVal),
      SF('P_PDate', '$PD', sfVal), SF('P_PMan', '$PM', sfVal),
      SF('P_MValue', '$MV', sfVal),
      SF('P_MDate', '$MD', sfVal), SF('P_MMan', '$MM', sfVal),
      SF('P_FactID', FFactNum),
      SF('P_Station', FStation),
      SF('P_MAC', gSysParam.FLocalMAC),
      SF('P_Direction', FDirect),
      SF('P_PModel', FPModel),
      SF('P_Status', FStatus),
      SF('P_Valid', sFlag_Yes)], sTable_PoundLog, nWhere, nNew);
    //xxxxx

    if FPValue = 0 then
    begin
      nStr := MacroValue(nStr, [MI('$PV', 'Null'),
              MI('$PD', 'Null'), MI('$PM', 'Null')]);
    end else
    begin
      nStr := MacroValue(nStr, [MI('$PV', FloatToStr(FPValue))]);
      if FPDate = '' then
           nStr := MacroValue(nStr, [MI('$PD', sField_SQLServer_Now)])
      else nStr := MacroValue(nStr, [MI('$PD', ''''+FPDate+'''')]);

      if FPMan = '' then
           nStr := MacroValue(nStr, [MI('$PM', ''''+gSysParam.FUserID+'''')])
      else nStr := MacroValue(nStr, [MI('$PM', ''''+FPMan+'''')]);
    end;

    if FMValue = 0 then
    begin
      nStr := MacroValue(nStr, [MI('$MV', 'Null'),
              MI('$MD', 'Null'), MI('$MM', 'Null')]);
    end else
    begin
      nStr := MacroValue(nStr, [MI('$MV', FloatToStr(FMValue))]);
      if FMDate = '' then
           nStr := MacroValue(nStr, [MI('$MD', sField_SQLServer_Now)])
      else nStr := MacroValue(nStr, [MI('$MD', ''''+FMDate+'''')]);

      if FMMan = '' then
           nStr := MacroValue(nStr, [MI('$MM', ''''+gSysParam.FUserID+'''')])
      else nStr := MacroValue(nStr, [MI('$MM', ''''+FMMan+'''')]);
    end;

    FDM.ExecuteSQL(nStr, True);
    Result := True;
  except
    Result := False;
  end;
end;

//Desc: ���泵�ƺ�
procedure SaveTruckNo(const nTruck: string);
var nStr: string;
begin
  nStr := 'Select Count(*) From %s Where T_Truck=''%s'''; 
  nStr := Format(nStr, [sTable_Truck, nTruck]);
  if FDM.QueryTemp(nStr).Fields[0].AsInteger > 0 then Exit;

  nStr := 'Insert Into %s(T_Truck, T_PY) Values(''%s'', ''%s'')';
  nStr := Format(nStr, [sTable_Truck, nTruck, GetPinYinOfStr(nTruck)]);
  FDM.ExecuteSQL(nStr);
end;

//Date: 2012-3-23
//Parm: ��������
//Desc: �����������
function PoundSaveData(var nData: TWorkerBusinessPound): Boolean;
var nStr: string;
    nOut: TWorkerBusinessPound;
    nWorker: TBusinessWorkerBase;
begin
  with nData do
  begin
    if FBillID <> '' then
      FType := sFlag_Sale
    else
    if FOrder <> '' then
      FType := sFlag_Provide
    else
      FType := sFlag_Other;
    //xxxxx
  end;

  Result := SavePound(nData);
  if not Result then
  begin
    ShowMsg('���汾����������ʧ��', sHint);
    Exit;
  end;

  if gSysParam.FNetBusMIT then Exit;
  //����ģʽ
  
  SaveTruckNo(nData.FTruck);
  //���泵�ƺ�

  nWorker := nil;
  try
    nData.FCommand := cBC_SavePoundData;
    nData.FSAPOK := not gSysParam.FNetSAPSrv;

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_PoundCommand);
    Result := nWorker.WorkActive(@nData, @nOut);

    if Result then
    begin
      nStr := 'Update %s Set P_Status=''%s'' Where P_ID=''%s''';
      nStr := Format(nStr, [sTable_PoundLog, sFlag_TruckMIT, nData.FPound]);
      FDM.ExecuteSQL(nStr, True);
    end;
  finally
    gBusinessWorkerManager.RelaseWorkder(nWorker);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2012-4-6
//Parm: ������;���ƺ�;У���ƿ�����
//Desc: ΪnBill�������ƿ�
function SetBillCard(const nBill,nTruck: string; nVerify: Boolean): Boolean;
var nStr: string;
    nP: TFormCommandParam;
begin
  Result := True;
  if nVerify then
  begin
    nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ViaBillCard]);

    with FDM.QueryTemp(nStr) do
     if (RecordCount < 1) or (Fields[0].AsString <> sFlag_Yes) then Exit;
    //no need do card
  end;

  nP.FParamA := nBill;
  nP.FParamB := nTruck;
  CreateBaseFormItem(cFI_FormMakeCard, '', @nP);
  Result := (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK);
end;

//Date: 2012-4-5
//Parm: ��������;������;����;����A,B
//Desc: Ϊ������nBill������ſ�
function SaveBillCard(const nBill,nTruck,nCard,nCardA,nCardB: string): Boolean;
var nListA,nListB: TStrings;
    nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nListA := nil;
  nListB := nil;
  nWorker := nil;
  try
    nListB := TStringList.Create;
    with nListB do
    begin
      Values['M'] := nCard;
      Values['A'] := nCardA;
      Values['B'] := nCardB;
    end;

    nListA := TStringList.Create;
    with nListA do
    begin
      Values['Bill'] := nBill;
      Values['Card'] := PackerEncodeStr(nListB.Text);
      Values['Truck'] := nTruck;
    end;

    nIn.FCommand := cBC_SaveBillCard;
    nIn.FData := PackerEncodeStr(nListA.Text);

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessCommand);
    Result := nWorker.WorkActive(@nIn, @nOut);
  finally
    nListA.Free;
    nListB.Free;
    gBusinessWorkerManager.RelaseWorkder(nWorker);
  end;
end;

//Date: 2012-4-8
//Parm: �ſ���;������
//Desc: ע��ָ���ſ���
function LogoutBillCard(const nCard,nBill: string): Boolean;
var nList: TStrings;
    nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nList := nil;
  nWorker := nil;
  try
    nList := TStringList.Create;
    with nList do
    begin
      Values['Bill'] := nBill;
      Values['Card'] := nCard;
    end;

    nIn.FCommand := cBC_LogoutBillCard;
    nIn.FData := PackerEncodeStr(nList.Text);

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessCommand);
    Result := nWorker.WorkActive(@nIn, @nOut);
  finally
    nList.Free;
    gBusinessWorkerManager.RelaseWorkder(nWorker);
  end;
end;

//Date: 2012-3-23
//Parm: �ſ���;��λ;�������б�
//Desc: ��ȡnPost��λ�ϴſ�ΪnCard�Ľ������б�
function GetLadingBills(const nCard,nPost: string;
 var nData: TLadingTruckItems): Boolean;
var nIdx: Integer;
    nListA,nListB: TStrings;
    nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nListA := nil;
  nListB := nil;
  nWorker := nil;
  try
    nListA := TStringList.Create;
    nListA.Values['Card'] := nCard;
    nListA.Values['Post'] := nPost;

    nIn.FCommand := cBC_GetPostBills;
    nIn.FData := PackerEncodeStr(nListA.Text);
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessCommand);

    SetLength(nData, 0);
    Result := nWorker.WorkActive(@nIn, @nOut);
    if not Result then Exit;
    
    nListA.Text := PackerDecodeStr(nOut.FData);
    SetLength(nData, nListA.Count);
    nListB := TStringList.Create;

    for nIdx:=Low(nData) to High(nData) do
    with nData[nIdx],nListB do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);

      FCard     := Values['Card'];
      FTruck    := Values['Truck'];
      FStatus   := Values['Status'];
      FNext     := Values['Next'];

      FOrder    := Values['Order'];
      FOrderTy  := Values['OrderTy'];
      FCusName  := Values['CusName'];

      FBill     := Values['Bill'];
      FType     := Values['Type'];
      FStock    := Values['Stock'];

      if IsNumber(Values['Value'], True) then
           FValue := StrToFloat(Values['Value'])
      else FValue := 0;
    end;
  finally
    nListA.Free;
    nListB.Free;
    gBusinessWorkerManager.RelaseWorkder(nWorker);
  end;
end;

//Date: 2012-3-25
//Parm: ��������; MCListBox;�ָ���
//Desc: ��nItem����nMC
procedure LoadBillItemToMC(const nItem: TLadingTruckItem; const nMC: TStrings;
 const nDelimiter: string);
var nStr: string;
begin
  with nItem,nMC do
  begin
    Clear;
    Add(Format('���ƺ���:%s %s', [nDelimiter, FTruck]));
    Add(Format('��ǰ״̬:%s %s', [nDelimiter, TruckStatusToStr(FStatus)]));

    Add(Format('%s ', [nDelimiter]));
    Add(Format('��������:%s %s', [nDelimiter, FBill]));
    Add(Format('��������:%s %.3f ��', [nDelimiter, FValue]));
    if FType = sFlag_Dai then nStr := '��װ' else nStr := 'ɢװ';

    Add(Format('Ʒ������:%s %s', [nDelimiter, nStr]));
    Add(Format('Ʒ������:%s %s', [nDelimiter, FStock]));
    
    Add(Format('%s ', [nDelimiter]));
    Add(Format('�������:%s %s', [nDelimiter, FOrder]));
    if FOrderTy = sFlag_XS then nStr := '����' else nStr := 'ת��';

    Add(Format('��������:%s %s', [nDelimiter, nStr]));
    Add(Format('�ͻ�����:%s %s', [nDelimiter, FCusName]));
  end;
end;

//Date: 2012-3-25
//Parm: ��λ;�������б�
//Desc: ����nPost��λ�Ľ���������
function SaveLadingBills(const nPost: string; nData: TLadingTruckItems): Boolean;
var nIdx: Integer;
    nListA,nListB: TStrings;
    nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  Result := False;
  if Length(nData) < 1 then Exit;

  nListA := nil;
  nListB := nil;
  nWorker := nil;
  try
    nListA := TStringList.Create;
    nListB := TStringList.Create;

    for nIdx:=Low(nData) to High(nData) do
    with nData[nIdx],nListA do
    begin
      Values['Bill'] := FBill;
      Values['Stock'] := FStock;
      Values['Value'] := FloatToStr(FValue);
      nListB.Add(PackerEncodeStr(nListA.Text));
    end;

    with nListA do
    begin
      Clear; 
      Values['Post'] := nPost;
      Values['Card'] := nData[0].FCard;
      Values['Type'] := nData[0].FType;
      Values['Truck'] := nData[0].FTruck;
      Values['Bills'] := PackerEncodeStr(nListB.Text);
    end;

    nIn.FCommand := cBC_SavePostBills;
    nIn.FData := PackerEncodeStr(nListA.Text);
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessCommand);

    SetLength(nData, 0);
    Result := nWorker.WorkActive(@nIn, @nOut);
  finally
    nListA.Free;
    nListB.Free;
    gBusinessWorkerManager.RelaseWorkder(nWorker);
  end;
end;

//Date: 2012-4-22
//Parm: ��վ��
//Desc: ��ȡnPound���ĵ�ǰ����
function ReadPoundCard(const nPound: string): string;
var nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  Result := '';
  nWorker := nil;
  try
    nIn.FCommand := cBC_GetPoundCard;
    nIn.FBase.FParam := sParam_NoHintOnError;
    nIn.FData := nPound;
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareMonitor);

    if nWorker.WorkActive(@nIn, @nOut) then
    begin
      Result := Trim(nOut.FData);
    end;
  finally
    gBusinessWorkerManager.RelaseWorkder(nWorker);
  end;
end;

//Date: 2012-7-8
//Desc: ���SAP����״̬�Ƿ�����
function CheckSAPServiceStatus: Boolean;
var nIn,nOut: TBWDataBase;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FMsgNO := sFlag_NotMatter;
    nIn.FParam := sParam_NoHintOnError;

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_ServiceStatus);
    Result := nWorker.WorkActive(@nIn, @nOut);
  finally
    gBusinessWorkerManager.RelaseWorkder(nWorker);
  end;
end;

//Date: 2012-4-25
//Parm: ͨ��;����
//Desc: ��ȡ������������
function LoadTruckQueue(var nLines: TZTLineItems; var nTrucks: TZTTruckItems;
 const nRefreshLine: Boolean): Boolean;
var nIdx: Integer;
    nSLine,nSTruck: string;
    nListA,nListB: TStrings; 
    nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    if nRefreshLine then
         nIn.FData := sFlag_Yes
    else nIn.FData := sFlag_No;

    nIn.FCommand := cBC_GetQueueData;
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareMonitor);

    Result := nWorker.WorkActive(@nIn, @nOut);
    if not Result then Exit;

    nListA.Text := PackerDecodeStr(nOut.FData);
    nSLine := nListA.Values['Lines'];
    nSTruck := nListA.Values['Trucks'];

    nListA.Text := PackerDecodeStr(nSLine);
    SetLength(nLines, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    with nLines[nIdx],nListB do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      FID       := Values['ID'];
      FName     := Values['Name'];
      FStock    := Values['Stock'];
      FValid    := Values['Valid'] <> sFlag_No;

      if IsNumber(Values['Weight'], False) then
           FWeight := StrToInt(Values['Weight'])
      else FWeight := 1;
    end;

    nListA.Text := PackerDecodeStr(nSTruck);
    SetLength(nTrucks, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    with nTrucks[nIdx],nListB do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      FTruck    := Values['Truck'];
      FLine     := Values['Line'];
      FBill     := Values['Bill'];

      if IsNumber(Values['Value'], True) then
           FValue := StrToFloat(Values['Value'])
      else FValue := 0;

      FInFact   := Values['InFact'] = sFlag_Yes;
      FIsRun    := Values['IsRun'] = sFlag_Yes;
           
      if IsNumber(Values['Dai'], False) then
           FDai := StrToInt(Values['Dai'])
      else FDai := 0;

      if IsNumber(Values['Total'], False) then
           FTotal := StrToInt(Values['Total'])
      else FTotal := 0;
    end;
  finally
    nListA.Free;
    nListB.Free;
    gBusinessWorkerManager.RelaseWorkder(nWorker);
  end;
end;

//Date: 2012-4-27
//Parm: ����;����
//Desc: ��nTruck��nLine����
function MakeTruckOutQueue(const nLine,nTruck: string): Boolean;
var nList: TStrings;
    nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  nList := TStringList.Create;
  try
    nList.Values['Line'] := nLine;
    nList.Values['Truck'] := nTruck;

    nIn.FCommand := cBC_GetQueueData;
    nIn.FData := PackerEncodeStr(nList.Text);
    
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareMonitor);
    Result := nWorker.WorkActive(@nIn, @nOut);
  finally
    nList.Free;
    gBusinessWorkerManager.RelaseWorkder(nWorker);
  end;
end;

//Date: 2012-9-15
//Parm: ͨ����;��ͣ��ʶ
//Desc: ��ͣnTunnelͨ���������
        procedure PrinterEnable(const nTunnel: string; const nEnable: Boolean);
var nList: TStrings;
    nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  nList := TStringList.Create;
  try
    nList.Values['Tunnel'] := nTunnel;
    if nEnable then
         nList.Values['Enable'] := sFlag_Yes
    else nList.Values['Enable'] := sFlag_No;

    nIn.FCommand := cBC_PrinterEnable;
    nIn.FData := PackerEncodeStr(nList.Text);
    
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareMonitor);
    nWorker.WorkActive(@nIn, @nOut);
  finally
    nList.Free;
    gBusinessWorkerManager.RelaseWorkder(nWorker);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2012-4-1
//Parm: ��������;Ʒ�ֱ��;�Ƿ�ѯ��
//Desc: ��ӡnBill��������
function PrintBillReport(const nBill,nStock: string; nAsk: Boolean): Boolean;
var nStr,nTmp: string;
    nP,nM: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '�Ƿ�Ҫ��ӡ������?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  if nStock <> '' then
  begin
    nStr := 'Select Count(*) From %s Where D_Name=''%s'' And D_Value=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_PrintBill, nStock]);

    with FDM.QueryTemp(nStr) do
     if Fields[0].AsInteger < 1 then Exit;
    //not need print
  end;

  nStr := 'Select * From %s b ' +
          ' Left Join %s xs On xs.BillID=b.L_ID ' +
          ' Left Join %s zc On zc.BillID=b.L_ID ' +
          'Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, sTable_OrderXS, sTable_OrderZC, nBill]);

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '������[ %s ] ����Ч!!';
    nStr := Format(nStr, [nBill]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'LadingBill.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '�޷���ȷ���ر����ļ�';
    ShowMsg(nStr, sHint); Exit;
  end;

  nP := '0.000';
  nM := '0.000';
  nStr := FDM.SqlTemp.FieldByName('L_Type').AsString;
  nTmp := FDM.SqlTemp.FieldByName('L_TruckID').AsString;

  if (nTmp <> '') and (nStr = sFlag_San) then
  begin
    nStr := 'Select T_BFPValue,T_BFMValue From %s Where T_ID=''%s''';
    nStr := Format(nStr, [sTable_TruckLog, nTmp]);

    with FDM.QuerySQL(nStr) do
    if RecordCount > 0 then
    begin
      nP := Format('%.3f', [Fields[0].AsFloat]);
      nM := Format('%.3f', [Fields[1].AsFloat]);
    end;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  nParam.FName := 'CHWeight';
  nParam.FValue := Num2CNum(FDM.SqlTemp.FieldByName('L_Value').AsFloat);
  FDR.AddParamItem(nParam);

  nParam.FName := 'PValue';
  nParam.FValue := nP;
  FDR.AddParamItem(nParam);

  nParam.FName := 'MValue';
  nParam.FValue := nM;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Date: 2012-4-15
//Parm: ��������;�Ƿ�ѯ��
//Desc: ��ӡnPound������¼
function PrintPoundReport(const nPound: string; nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '�Ƿ�Ҫ��ӡ������?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s Where P_ID=''%s''';
  nStr := Format(nStr, [sTable_PoundLog, nPound]);

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '���ؼ�¼[ %s ] ����Ч!!';
    nStr := Format(nStr, [nPound]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'Pound.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '�޷���ȷ���ر����ļ�';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;

  if Result  then
  begin
    nStr := 'Update %s Set P_PrintNum=P_PrintNum+1 Where P_ID=''%s''';
    nStr := Format(nStr, [sTable_PoundLog, nPound]);
    FDM.ExecuteSQL(nStr, gSysParam.FNetBusMIT);
  end;
end;

end.


