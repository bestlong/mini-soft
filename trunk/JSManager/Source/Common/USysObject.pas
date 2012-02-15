{*******************************************************************************
  ����: dmzn@ylsoft.com 2007-11-27
  ����: ͳһ����ϵͳ������
*******************************************************************************}
unit USysObject;

interface

uses
  SysUtils, Classes, USysConst, USysMenu, USysPopedom, UMgrLog;

procedure InitSystemObject;
procedure FreeSystemObject;
//�����ͷ�ϵͳ������    

implementation

//------------------------------------------------------------------------------
//Desc: д��־�ļ�
procedure WriteLog(const nThread: TLogThread; const nLogs: TList);
var nStr: string;
    nFile: TextFile;
    nItem: PLogItem;
    i,nCount: integer;
begin
  nStr := gPath + sLogDir;
  if not DirectoryExists(nStr) then CreateDir(nStr);
  nStr := nStr + DateToStr(Now) + sLogExt;

  AssignFile(nFile, nStr);
  if FileExists(nStr) then
       Append(nFile)
  else Rewrite(nFile);

  try
    nCount := nLogs.Count - 1;
    for i:=0 to nCount do
    begin
      if nThread.Terminated then Exit;
      nItem := nLogs[i];

      nStr := DateTimeToStr(nItem.FTime) + sLogField +       //ʱ��
              nItem.FWriter.FOjbect.ClassName + sLogField +  //����
              nItem.FWriter.FDesc + sLogField +              //����
              nItem.FEvent;                                  //�¼�
      WriteLn(nFile, nStr);
    end;
  finally
    CloseFile(nFile);
  end;
end;

//------------------------------------------------------------------------------
//Desc: ��ʼ��ϵͳ����
procedure InitSystemObject;
begin
  if not Assigned(gLogManager) then
  begin
    gLogManager := TLogManager.Create;
    gLogManager.WriteProcedure := WriteLog;
  end;
end;

//Desc: �ͷ�ϵͳ����
procedure FreeSystemObject;
begin
  FreeAndNil(gLogManager);
end;

end.
