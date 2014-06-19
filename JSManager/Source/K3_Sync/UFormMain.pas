{*******************************************************************************
  ����: dmzn@163.com 2014-06-16
  ����: K3����������ͬ��
*******************************************************************************}
unit UFormMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UTrayIcon, ComCtrls, ExtCtrls, StdCtrls;

type
  TfFormMain = class(TForm)
    Group3: TGroupBox;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    Label49: TLabel;
    Label50: TLabel;
    Label53: TLabel;
    Label54: TLabel;
    Label55: TLabel;
    Label56: TLabel;
    Label57: TLabel;
    Label58: TLabel;
    Timer1: TTimer;
    sBar: TStatusBar;
    MemoLog: TMemo;
    Timer2: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    { Private declarations }
    FTrayIcon: TTrayIcon;
    {*״̬��ͼ��*}
    procedure InitSystemObjects;
    //ϵͳ����
    procedure SetLable(const nFlag,nText: string);
    //���ñ���
    procedure ShowLog(const nStr: string);
    //��¼��־
  public
    { Public declarations }
  end;

var
  fFormMain: TfFormMain;

implementation

{$R *.dfm}

uses
  ULibFun, UMgrParam, UMgrDBConn, UFormWait, USysLoger, USyncConst;

procedure TfFormMain.InitSystemObjects;
begin
  gSysLoger := TSysLoger.Create(gPath + sLogDir, 'Event_K3_Sync');
  gSysLoger.LogEvent := ShowLog;
  gSysLoger.LogSync := True;

  gParamManager := TParamManager.Create(gPath + 'Parameters.xml');
  //param

  gDBConnManager := TDBConnManager.Create;
  gDBConnManager.AddParam(gParamManager.GetDB(sDB_K3)^);
  gDBConnManager.AddParam(gParamManager.GetDB(sDB_JS)^);
  gDBConnManager.MaxConn := gParamManager.GetPerform(sPerform).FPoolSizeConn;

  gSyncer := TSyncThread.Create;
  //��ʼͬ��
end;

procedure TfFormMain.FormCreate(Sender: TObject);
begin
  gPath := ExtractFilePath(Application.ExeName);
  InitGlobalVariant(gPath, gPath + sConfigFile, gPath + sFormConfig, gPath + sDBConfig);

  LoadFormConfig(Self);
  InitSystemObjects;
end;

procedure TfFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if not QueryDlg(sCloseQuery, sAsk) then
  begin
    Action := caNone;
    Exit;
  end;

  ShowWaitForm(Self, '�����˳�');
  try
    gSyncer.StopMe;
    SaveFormConfig(Self);
  finally
    CloseWaitForm;
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormMain.Timer1Timer(Sender: TObject);
begin
  sBar.Panels[0].Text := Format(sDate, [DateToStr(Now)]);
  sBar.Panels[1].Text := Format(sTime, [TimeToStr(Now)]);

  if not Application.Active then Exit;
  //update status
    
  with gDBConnManager.Status do
  begin
    SetLable('B.1', Format('%d ��', [FNumObjRequest]));
    SetLable('B.2', Format('%d ��', [FNumObjRequestErr]));
    SetLable('B.3', Format('%d ��', [FNumConnParam]));
    SetLable('B.4', Format('%d ��', [FNumConnItem]));
    SetLable('B.5', Format('%d ��', [FNumConnObj]));

    SetLable('B.6', Format('%d ��', [FNumObjConned]));
    SetLable('B.7', Format('%d ��', [FNumObjReUsed]));
    SetLable('B.8', Format('%d ��', [FNumObjWait]));
    SetLable('B.9', Format('%d ��', [FNumWaitMax]));
    SetLable('B.10', Format('%s', [DateTime2Str(FNumMaxTime)]));
  end;
end;
 
//Date: 2012-2-24
//Parm: ��ʶ;����
//Desc: ���ñ�ʶΪnFlag�ı���ΪnText
procedure TfFormMain.SetLable(const nFlag, nText: string);
var nIdx: Integer;
    nCtrl: TWinControl;
begin
  if nFlag[1] = 'B' then nCtrl := Group3 else Exit;

  for nIdx:=nCtrl.ControlCount - 1 downto 0 do
  if (nCtrl.Controls[nIdx] is TLabel) and
     (TLabel(nCtrl.Controls[nIdx]).Hint = nFlag) then
  begin
    TLabel(nCtrl.Controls[nIdx]).Caption := nText;
    Break;
  end;
end;

procedure TfFormMain.ShowLog(const nStr: string);
var nIdx: Integer;
begin
  MemoLog.Lines.BeginUpdate;
  try
    MemoLog.Lines.Insert(0, nStr);
    if MemoLog.Lines.Count > 100 then
     for nIdx:=MemoLog.Lines.Count - 1 downto 50 do
      MemoLog.Lines.Delete(nIdx);
  finally
    MemoLog.Lines.EndUpdate;
  end;
end;

procedure TfFormMain.Timer2Timer(Sender: TObject);
begin
  Timer2.Enabled := (FTrayIcon = nil);
  //verify timer's valid

  if not Assigned(FTrayIcon) then
  begin
    if FindWindow('Shell_TrayWnd', nil) > 0 then
    begin
      FTrayIcon := TTrayIcon.Create(Self);
      FTrayIcon.Hint := Caption;
      FTrayIcon.Visible := True;
    end;
  end;
end;

end.
