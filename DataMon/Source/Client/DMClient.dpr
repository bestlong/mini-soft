program DMClient;

uses
  FastMM4,
  Windows,
  Forms,
  UFormMain in 'UFormMain.pas' {Form1},
  UDataModule in 'UDataModule.pas' {FDM: TDataModule};

{$R *.res}
var
  gMutexHwnd: Hwnd;
  //������

begin
  gMutexHwnd := CreateMutex(nil, True, 'RunSoft_DMClient');
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
