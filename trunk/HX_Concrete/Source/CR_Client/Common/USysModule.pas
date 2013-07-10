{*******************************************************************************
  ����: dmzn@163.com 2009-6-25
  ����: ��Ԫģ��

  ��ע: ����ģ������ע������,ֻҪUsesһ�¼���.
*******************************************************************************}
unit USysModule;

{$I Link.Inc}
interface

uses
  {System Object}
  UBusinessWorker, UClientWorker, UBusinessPacker, UMITPacker,
  {Normal Module}
  UFrameLog, UFrameSysLog, UFormIncInfo, UFormBackupSQL, UFormRestoreSQL,
  UFormPassword, UFormMemo, UFrameArea, UFormArea, UFrameCard, UFormCard,
  UFormForMenu;

procedure InitSystemObject;
procedure RunSystemObject;
procedure FreeSystemObject;

implementation

uses
  SysUtils, UDataModule, USysLoger, USysDB, USysMAC, USysConst;

//Desc: ��ʼ��ϵͳ����
procedure InitSystemObject;
begin
  gSysLoger := TSysLoger.Create(gPath + sLogDir);
  //system loger
end;

//Desc: ����ϵͳ����
procedure RunSystemObject;
var nStr: string;
begin
  with gSysParam do
  begin
    FLocalMAC   := MakeActionID_MAC;
    GetLocalIPConfig(FLocalName, FLocalIP);

    nStr := 'Select D_Name, D_Value From %s';
    nStr := Format(nStr, [sTable_SysDict]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      First;

      while not eof do
      begin
        nStr := Fields[0].AsString;
        if nStr = sFlag_MITSrvURL then
          gSysParam.FURL_MIT := Fields[1].AsString;
        //xxxxx

        if nStr = sFlag_SiteID then
          gSysParam.FSiteID := Fields[1].AsString;
        //xxxxx

        if nStr = sFlag_DB_Type then
          gSysParam.FSysDBType := Fields[1].AsString;

        Next;
      end;
    end;
  end;
end;

//Desc: �ͷ�ϵͳ����
procedure FreeSystemObject;
begin

end;

end.
