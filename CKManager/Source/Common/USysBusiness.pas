{*******************************************************************************
  ����: dmzn@163.com 2010-3-8
  ����: ϵͳҵ����
*******************************************************************************}
unit USysBusiness;

interface

uses
  Windows, Classes, Controls, SysUtils, ULibFun, UAdjustForm, UFormCtrl, DB,
  UDataModule, USysDB;

function AdjustHintToRead(const nHint: string): string;
//������ʾ����

function LoadItemExtInfo(const nInfo: TStrings; const nFlag,nID: string;
 const nDelimiter: string = ';'): Boolean;
//��ȡ��չ��Ϣ
function SaveItemExtInfo(const nInfo: TStrings; const nFlag,nID: string;
 const nClearFirst: Boolean = False; const nDelimiter: string = ';'): Boolean;
//������չ��Ϣ

function IsWeekValid(const nWeek: string; var nHint: string): Boolean;
//�����Ƿ���Ч
function IsWeekHasEnable(const nWeek: string): Boolean;
//�����Ƿ�����
function IsNextWeekEnable(const nWeek: string): Boolean;
//��һ�����Ƿ�����
function IsPreWeekOver(const nWeek: string): Integer;
//��һ�����Ƿ����

implementation

//Desc: ����nHintΪ�׶��ĸ�ʽ
function AdjustHintToRead(const nHint: string): string;
var nIdx: Integer;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    nList.Text := nHint;
    for nIdx:=0 to nList.Count - 1 do
      nList[nIdx] := '��.' + nList[nIdx];
    Result := nList.Text;
  finally
    nList.Free;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2011-6-11
//Parm: ��Ϣ��;�����ʶ;��¼��ʶ;��Ϣ�ָ���
//Desc: ��ȡnFlag.nID����չ��Ϣ,����nInfo��
function LoadItemExtInfo(const nInfo: TStrings; const nFlag,nID: string;
 const nDelimiter: string = ';'): Boolean;
var nStr: string;
begin
  nInfo.Clear;
  nStr := MacroValue(sQuery_ExtInfo, [MI('$Table', sTable_ExtInfo),
                     MI('$Group', nFlag), MI('$ID', nID)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      nStr := FieldByName('I_Item').AsString + nDelimiter +
              FieldByName('I_Info').AsString;
      nInfo.Add(nStr);
        
      Next;
    end;
  end;

  Result := nInfo.Count > 0;
end;

//Date: 2011-6-11
//Parm: ��Ϣ��;�����ʶ;��¼��ʶ;�Ƿ�������;��Ϣ�ָ���
//Desc: ���nFlag.nID����չ��ϢnInfo
function SaveItemExtInfo(const nInfo: TStrings; const nFlag,nID: string;
 const nClearFirst: Boolean; const nDelimiter: string): Boolean;
var nBool: Boolean;
    i,nCount,nPos: integer;
    nStr,nSQL,nTmp: string;
begin
  nBool := FDM.ADOConn.InTransaction;
  if not nBool then FDM.ADOConn.BeginTrans;
  try
    if nClearFirst then
    begin
      nSQL := 'Delete From %s Where I_Group=''%s'' and I_ItemID=''%s''';
      nSQL := Format(nSQL, [sTable_ExtInfo, nFlag, nID]);
      FDM.ExecuteSQL(nSQL);
    end;

    nCount := nInfo.Count - 1;
    for i:=0 to nCount do
    begin
      nStr := nInfo[i];
      nPos := Pos(nDelimiter, nStr);

      nTmp := Copy(nStr, 1, nPos - 1);
      System.Delete(nStr, 1, nPos + Length(nDelimiter) - 1);

      nSQL := 'Insert Into %s(I_Group, I_ItemID, I_Item, I_Info) ' +
              'Values(''%s'', ''%s'', ''%s'', ''%s'')';
      nSQL := Format(nSQL, [sTable_ExtInfo, nFlag, nID, nTmp, nStr]);
      FDM.ExecuteSQL(nSQL);
    end;

    if not nBool then
      FDM.ADOConn.CommitTrans;
    Result := True;
  except
    if not nBool then
      FDM.ADOConn.RollbackTrans;
    Result := False;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ���nWeek�Ƿ���ڻ����
function IsWeekValid(const nWeek: string; var nHint: string): Boolean;
var nStr: string;
begin
  nStr := 'Select W_End,$Now From $W Where W_NO=''$NO''';
  nStr := MacroValue(nStr, [MI('$W', sTable_Weeks),
          MI('$Now', FDM.SQLServerNow), MI('$NO', nWeek)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsDateTime + 1 > Fields[1].AsDateTime;
    if not Result then
      nHint := '�������ѽ���';
    //xxxxx
  end else
  begin
    Result := False;
    nHint := '����������Ч';
  end;
end;

//Desc: ���nWeek�Ƿ��ѿ�ʼ
function IsWeekHasEnable(const nWeek: string): Boolean;
var nStr: string;
begin
  nStr := 'Select Top 1 * From $PL Where P_Week=''$NO''';
  nStr := MacroValue(nStr, [MI('$PL', sTable_BuyPlan), MI('$NO', nWeek)]);
  Result := FDM.QueryTemp(nStr).RecordCount > 0;
end;

//Desc: ���nWeek����������Ƿ��ѿ�ʼ
function IsNextWeekEnable(const nWeek: string): Boolean;
var nStr: string;
begin
  nStr := 'Select Top 1 * From $PL Where P_Week In ' +
          '( Select W_NO From $W Where W_Begin > (' +
          '  Select Top 1 W_Begin From $W Where W_NO=''$NO''))';
  nStr := MacroValue(nStr, [MI('$PL', sTable_BuyPlan),
          MI('$W', sTable_Weeks), MI('$NO', nWeek)]);
  Result := FDM.QueryTemp(nStr).RecordCount > 0;
end;

//Desc: ���nWeeǰ��������Ƿ������
function IsPreWeekOver(const nWeek: string): Integer;
var nStr: string;
begin
  nStr := 'Select Count(*) From $Req Where (R_ReqValue<>R_KValue) And ' +
          '(R_Week In ( Select W_NO From $W Where W_Begin < (' +
          '  Select Top 1 W_Begin From $W Where W_NO=''$NO'')))';
  nStr := MacroValue(nStr, [MI('$Req', sTable_BuyReq),
          MI('$W', sTable_Weeks), MI('$NO', nWeek)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[0].AsInteger
  else Result := 0;
end;

end.
