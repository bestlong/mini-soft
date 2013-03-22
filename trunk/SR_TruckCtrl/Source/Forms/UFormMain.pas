{*******************************************************************************
  ����: dmzn@163.com 2013-3-7
  ����: ϵͳ����Ԫ,�����������ģ��
*******************************************************************************}
unit UFormMain;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, ExtCtrls,
  ImgList, dxStatusBar, cxPC, StdCtrls;

type
  TfFormMain = class(TForm)
    HintPanel: TPanel;
    img1: TImage;
    img2: TImage;
    lblHintLabel: TLabel;
    wPage: TcxTabControl;
    SBar: TdxStatusBar;
    Image1: TImageList;
    Timer1: TTimer;
    procedure wPageResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure wPageChange(Sender: TObject);
  private
    { Private declarations }
    procedure FormLoadConfig;
    procedure FormSaveConfig;
    {*������Ϣ*}
  public
    { Public declarations }
  end;

var
  fFormMain: TfFormMain;

implementation

{$R *.dfm}

uses
  IniFiles, UFormWait, ULibFun, UFrameBase, USysModule, USysConst;

//Desc: ��������
procedure TfFormMain.FormLoadConfig;
var nStr: string;
    nIni: TIniFile;
begin
  HintPanel.DoubleBuffered := True;
  gStatusBar := sBar;

  nStr := Format(sDate, [DateToStr(Now)]);
  StatusBarMsg(nStr, cSBar_Date);
  nStr := Format(sTime, [TimeToStr(Now)]);
  StatusBarMsg(nStr, cSBar_Time);

  wPage.TabIndex := 0;
  CreateBaseFrameItem(cFI_FrameRealTime, Self, alClient);
  //�����������

  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;
end;

//Desc: ���洰������
procedure TfFormMain.FormSaveConfig;
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;

  ActionSysParameter(False);
end;

procedure TfFormMain.FormCreate(Sender: TObject);
var nStr: string;
begin
  InitSystemEnvironment;
  ActionSysParameter(True);

  Application.Title := gSysParam.FAppTitle;
  InitGlobalVariant(gPath, gPath + sConfigFile, gPath + sFormConfig);

  nStr := GetFileVersionStr(Application.ExeName);
  if nStr <> '' then
  begin
    nStr := Copy(nStr, 1, Pos('.', nStr) - 1);
    Caption := gSysParam.FMainTitle + ' V' + nStr;
  end else Caption := gSysParam.FMainTitle;

  InitSystemObject;
  //system object

  FormLoadConfig;
  //��������

  RunSystemObject(Handle);
  //run them
end;

procedure TfFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ShowWaitForm(Self, '�����˳�ϵͳ');
  try
    Application.ProcessMessages;
    FormSaveConfig;
    //��������

    FreeSystemObject;
    //system object
    
    {$IFNDEF debug}
    Sleep(2200);
    {$ENDIF}
  finally
    CloseWaitForm;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ����������,ʱ��
procedure TfFormMain.Timer1Timer(Sender: TObject);
begin
  sBar.Panels[cSBar_Date].Text := Format(sDate, [DateToStr(Now)]);
  sBar.Panels[cSBar_Time].Text := Format(sTime, [TimeToStr(Now)]);
end;

//Desc: ������ǩ���
procedure TfFormMain.wPageResize(Sender: TObject);
var nTab: TcxTabControl;
begin
  nTab := Sender as TcxTabControl;
  nTab.TabWidth := Trunc(nTab.ClientWidth / nTab.Tabs.Count) - 10;
end;

//Desc: ��̬�������
procedure TfFormMain.wPageChange(Sender: TObject);
begin
  LockWindowUpdate(Handle);
  try
    case wPage.TabIndex of
     0: CreateBaseFrameItem(cFI_FrameRealTime, Self);
     1: CreateBaseFrameItem(cFI_FrameRunMon, Self);
     2: CreateBaseFrameItem(cFI_FrameReport, Self);
     3: CreateBaseFrameItem(cFI_FrameRunlog, Self);
     4: CreateBaseFrameItem(cFI_FrameConfig, Self);
    end;
  finally
    Application.ProcessMessages;
    LockWindowUpdate(0);
  end;
end;

end.
