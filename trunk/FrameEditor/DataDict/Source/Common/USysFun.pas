{*******************************************************************************
  ����: dmzn@ylsoft.com 2007-10-09
  ����: ��Ŀͨ�ú������嵥Ԫ
*******************************************************************************}
unit USysFun;

interface

uses
  Windows, Classes, ComCtrls, Forms, SysUtils, IniFiles, TypInfo, ULibFun,
  USysConst;

procedure ShowMsgOnLastPanelOfStatusBar(const nMsg: string);
procedure StatusBarMsg(const nMsg: string; const nIdx: integer);
//��״̬����ʾ��Ϣ

procedure InitSystemEnvironment;
//��ʼ��ϵͳ���л����ı���
procedure LoadSysParameter(const nIni: TIniFile = nil);
//����ϵͳ���ò���

procedure LoadListViewColumn(const nWidths: string; const nLv: TListView);
//�����б��ͷ���
function MakeListViewColumnInfo(const nLv: TListView): string;
//����б��ͷ�����Ϣ

procedure GetOrdTypeInfo(nTypeInfo: PTypeInfo; nList: TStrings);
//��ȡ������������ʱ��Ϣ

implementation

//---------------------------------- �������л��� ------------------------------
//Date: 2007-01-09
//Desc: ��ʼ�����л���
procedure InitSystemEnvironment;
begin
  Randomize;
  ShortDateFormat := 'YYYY-MM-DD';
  gPath := ExtractFilePath(Application.ExeName);
end;

//Date: 2007-09-13
//Desc: ����ϵͳ���ò���
procedure LoadSysParameter(const nIni: TIniFile = nil);
var nTmp: TIniFile;
begin
  if Assigned(nIni) then
       nTmp := nIni
  else nTmp := TIniFile.Create(gPath + sConfigFile);

  try
    with gSysParam, nTmp do
    begin
      FProgID := ReadString(sConfigSec, 'ProgID', sProgID);
      //�����ʶ�����������в���
      FAppTitle := ReadString(FProgID, 'AppTitle', sAppTitle);
      FMainTitle := ReadString(FProgID, 'MainTitle', sMainCaption);
      FHintText := ReadString(FProgID, 'HintText', '');
    end;
  finally
    if not Assigned(nIni) then nTmp.Free;
  end;

  nTmp := TIniFile.Create(gPath + sDBConfig);
  try
    with gSysParam, nTmp do
    begin
      FTableEntity := ReadString(sTableSec, 'TableEntity', sTable_Entity);
      FTableDict := ReadString(sTableSec, 'TableDictItem', sTable_Dict);
    end;
  finally
    nTmp.Free;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ��ȫ��״̬�����һ��Panel����ʾnMsg��Ϣ
procedure ShowMsgOnLastPanelOfStatusBar(const nMsg: string);
begin
  if Assigned(gStatusBar) and (gStatusBar.Panels.Count > 0) then
  begin
    gStatusBar.Panels[gStatusBar.Panels.Count - 1].Text := nMsg;
    Application.ProcessMessages;
  end;
end;

//Desc: ������nIdx��Panel����ʾnMsg��Ϣ
procedure StatusBarMsg(const nMsg: string; const nIdx: integer);
begin
  if Assigned(gStatusBar) and (gStatusBar.Panels.Count > nIdx) and
     (nIdx > -1) then
  begin
    gStatusBar.Panels[nIdx].Text := nMsg;
    gStatusBar.Panels[nIdx].Width := gStatusBar.Canvas.TextWidth(nMsg) + 20;
    Application.ProcessMessages;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2007-11-30
//Parm: �����Ϣ;�б�
//Desc: ����nList�ı�ͷ���
procedure LoadListViewColumn(const nWidths: string; const nLv: TListView);
var nList: TStrings;
    i,nCount: integer;
begin
  if nLv.Columns.Count > 0 then
  begin
    nList := TStringList.Create;
    try
      if SplitStr(nWidths, nList, nLv.Columns.Count, ';') And
         (nLv.Columns.Count = nList.Count) then
      begin
        nCount := nList.Count - 1;
        for i:=0 to nCount do
         if IsNumber(nList[i], False) then
          nLv.Columns[i].Width := StrToInt(nList[i]);
      end;
    finally
      nList.Free;
    end;
  end;
end;

//Date: 2007-11-30
//Parm: �б�
//Desc: ���nLv�ı�ͷ�����Ϣ
function MakeListViewColumnInfo(const nLv: TListView): string;
var i,nCount: integer;
begin
  Result := '';
  nCount := nLv.Columns.Count - 1;

  for i:=0 to nCount do
  if i = nCount then
       Result := Result + IntToStr(nLv.Columns[i].Width)
  else Result := Result + IntToStr(nLv.Columns[i].Width) + ';';
end;

//Desc: ��ȡnTypeInfo������ʱ����,����nList��
procedure GetOrdTypeInfo(nTypeInfo: PTypeInfo; nList: TStrings);
var nIdx: integer;
    nData: PTypeData;
begin
  nList.Clear;
  nData := GetTypeData(nTypeInfo);

  if nTypeInfo^.Kind = tkEnumeration then
   for nIdx:=nData^.MinValue to nData^.MaxValue do
    nList.Add(Format('%d=%d.%s', [nIdx, nIdx, GetEnumName(nTypeInfo, nIdx)]));
end;

end.


