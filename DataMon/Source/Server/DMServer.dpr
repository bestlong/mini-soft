program DMServer;

{$IFNDEF debug}
{#ROGEN:DataMon.rodl} // RemObjects: Careful, do not remove!
{$ENDIF}

uses
  FastMM4,
  Windows,
  Forms,
  UFormMain in 'UFormMain.pas' {Form1},
  UDataModule in 'UDataModule.pas' {FDM: TDataModule},
  DataMon_Intf in 'DataMon_Intf.pas',
  DataMon_Invk in 'DataMon_Invk.pas',
  DataService_Impl in 'DataService_Impl.pas',
  UMgrDBWriter in 'UMgrDBWriter.pas';

{$R *.res}

{$IFNDEF debug}
{$R RODLFile.res}
{$ENDIF}

var
  gMutexHwnd: Hwnd;
  //������

begin
  gMutexHwnd := CreateMutex(nil, True, 'RunSoft_DMServer');
  //����������
  if GetLastError = ERROR_ALREADY_EXISTS then
  begin
    ReleaseMutex(gMutexHwnd);
    CloseHandle(gMutexHwnd); Exit;
  end; //����һ��ʵ��

  Application.Initialize;
  Application.CreateForm(TFDM, FDM);
  Application.CreateForm(TfFormMain, fFormMain);
  Application.Run;
end.
