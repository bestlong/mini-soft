{*******************************************************************************
  ����: dmzn@163.com 2012-2-29
  ����: Bus-MIT��������Ԫ
*******************************************************************************}
unit UFormMain;

{$I link.inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UTrayIcon, StdCtrls, ExtCtrls, ComCtrls, XPMan;

type
  TfFormMain = class(TForm)
    HintPanel: TPanel;
    Image1: TImage;
    Image2: TImage;
    HintLabel: TLabel;
    wPage: TPageControl;
    sBar: TStatusBar;
    SheetSummary: TTabSheet;
    SheetParam: TTabSheet;
    Timer1: TTimer;
    SheetRunLog: TTabSheet;
    XPManifest1: TXPManifest;
    Timer2: TTimer;
    SheetHard: TTabSheet;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure wPageChange(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    { Private declarations }
    FTrayIcon: TTrayIcon;
    {*״̬��ͼ��*}
    procedure WM_RESTOREFORM(var nMsg: TMessage); message WM_User + $0001;
    {*�ָ�״̬*}
    procedure FormLoadConfig;
    procedure FormSaveConfig;
    {*������Ϣ*}
    procedure SetHintText(const nLabel: TLabel);
    {*��ʾ��Ϣ*}
  public
    { Public declarations }
  end;

var
  fFormMain: TfFormMain;

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, UFormWait, UFrameBase, USysModule, UROModule, UMITConst;

//------------------------------------------------------------------------------
//Date: 2007-10-15
//Parm: ��ǩ
//Desc: ��nLabel����ʾ��ʾ��Ϣ
procedure TfFormMain.SetHintText(const nLabel: TLabel);
begin
  nLabel.Font.Color := clWhite;
  nLabel.Font.Size := 12;
  nLabel.Font.Style := nLabel.Font.Style + [fsBold];

  nLabel.Caption := sHintText;
  nLabel.Left := 12;
  nLabel.Top := (HintPanel.Height + nLabel.Height - 12) div 2;
end;
       
//Desc: ��������
procedure TfFormMain.FormLoadConfig;
var nStr: string;
    nIni: TIniFile;
begin     
  SetHintText(HintLabel);
  HintPanel.DoubleBuffered := True; 
  gStatusBar := sBar;

  nStr := Format(sDate, [DateToStr(Now)]);
  StatusBarMsg(nStr, cSBar_Date);
  nStr := Format(sTime, [TimeToStr(Now)]);
  StatusBarMsg(nStr, cSBar_Time);

  {$IFDEF HardMon}
  SheetHard.TabVisible := False;
  {$ELSE}
  SheetHard.TabVisible := False;
  {$ENDIF}

  wPage.ActivePage := SheetSummary;
  CreateBaseFrameItem(cFI_FrameSummary, SheetSummary, alNone).Centered := True;
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
var nStr: string;
begin
  ShowWaitForm(Self, '�����˳�ϵͳ');
  try
    Application.ProcessMessages;

    ROModule.ActiveServer([stTcp, stHttp], False, nStr);
    //stop server

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

//Desc: ��ʱ����ϵͳ�߼�
procedure TfFormMain.Timer2Timer(Sender: TObject);
begin
  Timer2.Enabled := (FTrayIcon = nil);
  //verify timer's valid

  if not Assigned(FTrayIcon) then
  begin
    if FindWindow('Shell_TrayWnd', nil) > 0 then
    begin
      FTrayIcon := TTrayIcon.Create(Self);
      FTrayIcon.Hint := gSysParam.FAppTitle;
      FTrayIcon.Visible := True;
    end;
  end;
end;

//Desc: �ָ�����״̬
procedure TfFormMain.WM_RESTOREFORM(var nMsg: TMessage);
begin
  if Assigned(FTrayIcon) then FTrayIcon.Restore;
end;

//Desc: ��̬�������
procedure TfFormMain.wPageChange(Sender: TObject);
begin
  if wPage.ActivePage = SheetRunLog then
    CreateBaseFrameItem(cFI_FrameRunlog, SheetRunLog);
  if wPage.ActivePage = SheetParam then
    CreateBaseFrameItem(cFI_FrameParam, SheetParam);
  if wPage.ActivePage = SheetHard then
    CreateBaseFrameItem(cFI_FrameHard, SheetHard);
end;

end.
