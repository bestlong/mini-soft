{*******************************************************************************
  ����: dmzn@163.com 2012-3-7
  ����: ϵͳҵ����ڶ���
*******************************************************************************}
unit SrvBusiness_Impl;

{$I Link.Inc}
interface

uses
  Classes, SysUtils, uROServer, MIT_Service_Intf;

type
  TSrvBusiness = class(TRORemotable, ISrvBusiness)
  private
    procedure WriteLog(const nLog: string);
  protected
    function Action(const nFunName: AnsiString; var nData: AnsiString): Boolean;
  end;

implementation

uses
  USysLoger, UROModule, UBusinessWorker, UMITConst;

procedure TSrvBusiness.WriteLog(const nLog: string);
begin
  gSysLoger.AddLog(TSrvBusiness, 'ҵ��������', nLog);
end;

//Date: 2012-3-7
//Parm: ������;[in]����,[out]�������
//Desc: ִ����nDataΪ������nFunName����
function TSrvBusiness.Action(const nFunName: AnsiString;
 var nData: AnsiString): Boolean;
var nWorker: TBusinessWorkerBase;
begin
  nWorker := gBusinessWorkerManager.LockWorker(nFunName);
  try 
    try
      if nWorker.FunctionName = '' then
      begin
        nData := 'Զ�̵���ʧ��(Worker Is Null).';
        Result := False;
        Exit;
      end;

      Result := nWorker.WorkActive(nData);
      //do action

      with ROModule.LockModuleStatus^ do
      try
        FNumBusiness := FNumBusiness + 1;
      finally
        ROModule.ReleaseStatusLock;
      end;
    except
      on E:Exception do
      begin
        Result := False;
        nData := E.Message;
        WriteLog('Function:[ ' + nFunName + ' ]' + E.Message);

        with ROModule.LockModuleStatus^ do
        try
          FNumActionError := FNumActionError + 1;
        finally
          ROModule.ReleaseStatusLock;
        end;
      end;
    end;

    if (not Result) and (Pos(#10#13, nData) < 1) then
    begin
      nData := Format('��Դ: %s,%s' + #13#10 + '����: %s',
               [gSysParam.FAppFlag, gSysParam.FLocalName,
               nWorker.FunctionName]) + #13#10#13#10 + nData;
      //xxxxx
    end;
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

end.
