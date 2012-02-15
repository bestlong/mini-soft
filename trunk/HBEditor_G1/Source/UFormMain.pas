{*******************************************************************************
  ����: dmzn@163.com 2010-8-31
  ����: ϵͳ����Ԫ
*******************************************************************************}
unit UFormMain;

{$I link.inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UDataModule, UEditControl, UImgControl, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, dxSkinsdxStatusBarPainter, cxContainer, cxEdit,
  Menus, dxSkinsdxBarPainter, cxButtonEdit, cxCheckGroup,
  cxFontNameComboBox, ExtCtrls, ActnList, cxBarEditItem, dxBar, cxClasses,
  cxListBox, cxMemo, StdCtrls, cxButtons, cxCheckBox, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, cxLabel, cxGroupBox, cxPC, dxStatusBar;

type
  TfFormMain = class(TForm)
    BarMgr: TdxBarManager;
    dxBarManager1Bar1: TdxBar;
    dxBarManager1Bar2: TdxBar;
    dxBarManager1Bar3: TdxBar;
    N14: TdxBarButton;
    N15: TdxBarButton;
    N16: TdxBarButton;
    N1: TdxBarSubItem;
    N6: TdxBarButton;
    N5: TdxBarSubItem;
    dxBarButton2: TdxBarButton;
    dxBarButton3: TdxBarButton;
    dxBarLargeButton1: TdxBarLargeButton;
    dxBarLargeButton2: TdxBarLargeButton;
    dxBarLargeButton3: TdxBarLargeButton;
    dxBarLargeButton4: TdxBarLargeButton;
    dxBarLargeButton5: TdxBarLargeButton;
    dxBarLargeButton19: TdxBarLargeButton;
    EditTimeChar: TdxBarCombo;
    EditDispMode: TdxBarCombo;
    EditDispPos: TdxBarCombo;
    BtnYear: TdxBarButton;
    BtnMonth: TdxBarButton;
    BtnDay: TdxBarButton;
    BtnWeek: TdxBarButton;
    BtnHour: TdxBarButton;
    dxBarManager1Bar4: TdxBar;
    EditPort: TdxBarCombo;
    EditBote: TdxBarCombo;
    dxBarButton11: TdxBarButton;
    dxBarButton13: TdxBarButton;
    dxBarLargeButton20: TdxBarLargeButton;
    WorkPanel: TScrollBox;
    SBar: TdxStatusBar;
    wPage: TcxPageControl;
    SheetScreen: TcxTabSheet;
    SheetMemo: TcxTabSheet;
    cxGroupBox3: TcxGroupBox;
    cxGroupBox4: TcxGroupBox;
    GroupMode: TcxGroupBox;
    BarEdit: TdxBar;
    DockEdit: TdxBarDockControl;
    DockCard: TdxBarDockControl;
    dxBarSubItem5: TdxBarSubItem;
    EditPwd: TcxBarEditItem;
    BtnLogoff: TdxBarButton;
    BtnSyncTime: TdxBarButton;
    BtnSaveParam: TdxBarButton;
    EditFontColor: TdxBarCombo;
    BtnHLeft: TdxBarButton;
    BtnHMid: TdxBarButton;
    BtnHRight: TdxBarButton;
    BtnVTop: TdxBarButton;
    BtnVMid: TdxBarButton;
    BtnVBottom: TdxBarButton;
    dxBarCombo8: TdxBarCombo;
    cxBarEditItem1: TcxBarEditItem;
    BtnCut: TdxBarButton;
    BtnCopy: TdxBarButton;
    BtnPaste: TdxBarButton;
    BtnModeSync: TcxButton;
    EditEnterMode: TcxComboBox;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    EditKeep: TcxComboBox;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    EditExitMode: TcxComboBox;
    cxLabel5: TcxLabel;
    EditEnterSpeed: TcxComboBox;
    EditGS: TcxCheckBox;
    cxLabel6: TcxLabel;
    EditExitSpeed: TcxComboBox;
    ListMovie: TcxListBox;
    BtnBold: TdxBarButton;
    BtnUnder: TdxBarButton;
    BtnItaly: TdxBarButton;
    BtnDel: TcxButton;
    BtnSync: TcxButton;
    BtnSend: TdxBarButton;
    EditText: TcxMemo;
    dxBarSubItem2: TdxBarSubItem;
    dxBarCombo9: TdxBarCombo;
    dxBarCombo10: TdxBarCombo;
    dxBarCombo11: TdxBarCombo;
    cxBarEditItem2: TcxBarEditItem;
    dxBarCombo12: TdxBarCombo;
    BtnClock: TdxBarLargeButton;
    BtnTime: TdxBarLargeButton;
    EditPlayDays: TdxBarCombo;
    ActionList1: TActionList;
    Act_New: TAction;
    Act_Open: TAction;
    Act_Save: TAction;
    Act_Clock: TAction;
    Act_Time: TAction;
    Act_Conn: TAction;
    Act_Send: TAction;
    Act_Help: TAction;
    Act_Copy: TAction;
    Act_Cut: TAction;
    Act_Paste: TAction;
    Timer1: TTimer;
    cxLabel7: TcxLabel;
    cxLabel8: TcxLabel;
    EditScreenW: TcxComboBox;
    EditScreenH: TcxComboBox;
    EditJR: TcxCheckBox;
    GroupInfo: TcxGroupBox;
    EditFontName: TcxBarEditItem;
    BtnRestoreText: TdxBarButton;
    Act_Sync: TAction;
    Act_About: TAction;
    BtnSaveWH: TcxButton;
    EditFontSize: TdxBarCombo;
    EditBlank: TcxCheckBox;
    BtnBg: TdxBarLargeButton;
    BtnCheckPort: TdxBarButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure EditPwdPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnLogoffClick(Sender: TObject);
    procedure EditFontColorDrawItem(Sender: TdxBarCustomCombo;
      AIndex: Integer; ARect: TRect; AState: TOwnerDrawState);
    procedure EditPortChange(Sender: TObject);
    procedure Act_ConnExecute(Sender: TObject);
    procedure BtnSyncTimeClick(Sender: TObject);
    procedure WorkPanelResize(Sender: TObject);
    procedure BtnSaveParamClick(Sender: TObject);
    procedure EditTimeCharChange(Sender: TObject);
    procedure EditScreenWPropertiesEditValueChanged(Sender: TObject);
    procedure BtnSyncClick(Sender: TObject);
    procedure ListMovieClick(Sender: TObject);
    procedure EditFontSizeChange(Sender: TObject);
    procedure EditFontNamePropertiesChange(Sender: TObject);
    procedure EditFontColorChange(Sender: TObject);
    procedure BtnBoldClick(Sender: TObject);
    procedure BtnHLeftClick(Sender: TObject);
    procedure Act_CopyExecute(Sender: TObject);
    procedure Act_CutExecute(Sender: TObject);
    procedure Act_PasteExecute(Sender: TObject);
    procedure EditEnterModePropertiesChange(Sender: TObject);
    procedure Act_SendExecute(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnModeSyncClick(Sender: TObject);
    procedure Act_SyncExecute(Sender: TObject);
    procedure Act_NewExecute(Sender: TObject);
    procedure Act_OpenExecute(Sender: TObject);
    procedure Act_SaveExecute(Sender: TObject);
    procedure Act_HelpExecute(Sender: TObject);
    procedure Act_AboutExecute(Sender: TObject);
    procedure N16Click(Sender: TObject);
    procedure EditPwdKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BtnBgClick(Sender: TObject);
    procedure BtnCheckPortClick(Sender: TObject);
  private
    { Private declarations }
    FLastFile: string;
    {*�ϴα���*}
    FBGFile: string;
    {*����ͼƬ*}
    FBGControl: TZnImageControl;
    {*�������*}
    FEditor: THBEditControl;
    {*�༭����*}
    procedure FormLoadConfig;
    procedure FormSaveConfig;
    {*������Ϣ*}
    procedure SysParamWithFile(const nRead: Boolean);
    {*��д����*}
    procedure OnBgImageClick(Sender: TObject);
    {*����ѡ��*}
    procedure ResetCtrlStatus;
    {*����״̬*}
    function GetClockParam(const nHint: Boolean): Boolean;
    {*ʱ�Ӳ���*}
    procedure LoadMovieList;
    procedure UpdateFormData;
    function MovieInDisk(const nFile: string; const nSave: Boolean): Boolean;
    {*�־û�*}
    function LastFileInDisk(const nSave: Boolean): Boolean;
    {*��Ŀ�ļ�*}
    function GetActiveMovie: PBitmapDataItem;
    {*���Ŀ*}
    procedure SetBarStatus(const nEnable: Boolean);
    function GetBarEditText(const nBarItem: TcxBarEditItem): string;
    {*��������*}
    function SendDataItem(const nData: PBitmapDataItem): Boolean;
    function SendDataList(const nData: TList; var nHint: string): Boolean;
    {*��������*}
  public
    { Public declarations }
  end;

var
  fFormMain: TfFormMain;

implementation

{$R *.dfm}
uses
  IniFiles, UBase64, ULibFun, UMgrCOMM, UMgrLang, UFormWait, CPort, USysConst;

//------------------------------------------------------------------------------
//Desc: ��nData��䵽nList��
procedure FillInFixData(const nList: TStrings; nData: array of TCodeText);
var nStr: string;
    nIdx: Integer;
begin
  nList.Clear;
  gMultiLangManager.SectionID := sMLCommon;

  for nIdx:=Low(nData) to High(nData) do
  begin
    nStr := Format('%s.%s', [nData[nIdx].FCode, ML(nData[nIdx].FText)]);
    nList.AddObject(nStr, TObject(nIdx));
  end;
end;

//Desc: ����nList��nIdx�����Ӧ��nData.Codeֵ
function GetFixData(nList: TStrings; nIdx: Integer; nData: array of TCodeText): string;
begin
  if (nIdx > -1) and (nIdx < nList.Count) then
       Result := nData[Integer(nList.Objects[nIdx])].FCode
  else Result := '';
end;

//Desc: ����nList�ж���ֵΪnCode������
function GetFixDataIdx(nList: TStrings; nCode: string; nData: array of TCodeText): Integer;
var i,nLen: Integer;
begin
  Result := -1;
  nLen := nList.Count - 1;

  for i:=0 to nLen do
  if GetFixData(nList, i, nData) = nCode then
  begin
    Result := i; Break;
  end;
end;

//Desc: ��������
procedure TfFormMain.FormLoadConfig;
var nIdx: Integer;
    nIni: TIniFile;
begin
  with gMultiLangManager do
  if FileExists(gPath + 'Lang.xml') then
  begin
    LoadLangFile(gPath + 'Lang.xml');
    HasItemID := True;
    NowLang := 'cn';

    RegItem('TdxBarCombo', 'Caption');
    RegItem('TdxBarCombo', 'Hint');
    RegItem('TdxBarCombo', 'Items');
    RegItem('TdxBarCombo', 'Text');
    RegItem('TdxBarLargeButton', 'Caption');
    RegItem('TdxBarButton', 'Caption');
    RegItem('TdxBarButton', 'Hint');
    RegItem('TcxComboBox', 'Properties.Items');
    RegItem('TcxTabSheet', 'Caption');
    RegItem('TcxButton', 'Caption');
    RegItem('TcxButton', 'Hint');
    RegItem('TcxGroupBox', 'Caption');
    RegItem('TcxCheckBox', 'Caption');
    RegItem('TdxBarSubItem', 'Caption');
    RegItem('TcxBarEditItem', 'Caption');
    RegItem('TcxBarEditItem', 'Hint');
  end;

  nIni := TIniFile.Create(gPath + sConfigFile);
  try 
    with gSysParam, nIni do
    begin
      FAppTitle := ReadString(sProgID, 'AppTitle', sAppTitle);
      FMainTitle := ReadString(sProgID, 'MainTitle', sMainTitle);
      FCopyLeft := ReadString(sProgID, 'CopyLeft', sCopyRight);
      FCopyRight := ReadString(sProgID, 'CopyRight', sCopyRight);
      gMultiLangManager.AutoNewNode := ReadBool(sProgID, 'AutoTranse', False);

      FAppTitle := ML(FAppTitle, sMLCommon);
      FMainTitle := ML(FMainTitle);
      FCopyLeft := ML(FCopyLeft);
      FCopyRight := ML(FCopyRight);

      //FIsAdmin := False;
      FIsAdmin := True;
      //Ĭ�Ϲ���Ա
      ResetCtrlStatus;
    end;

    Caption := gSysParam.FMainTitle;
    Application.Title := gSysParam.FAppTitle;

    StatusBarMsg(gSysParam.FCopyLeft, 0);
    StatusBarMsg(Time2Str(Now), 1);
    ShowMsgOnLastPanelOfStatusBar(gSysParam.FCopyRight);

    nIni.Free;
    nIni := TIniFile.Create(gPath + sFormConfig);

    LoadFormConfig(Self, nIni);
    //��������
    FLastFile := nIni.ReadString(Name, 'LastFile', '');
    FBGFile   := nIni.ReadString(Name, 'BgFile', gPath + sBackImage);
  finally
    nIni.Free;
  end;

  SetBarStatus(False);
  //���ù�����

  FillInFixData(EditTimeChar.Items, cTimeChar);
  EditTimeChar.ItemIndex := 0;

  FillInFixData(EditDispMode.Items, cDispMode);
  EditDispMode.ItemIndex := 1;
  FillInFixData(EditDispPos.Items, cDispPos);
  EditDispPos.ItemIndex := 5;

  FillInFixData(EditEnterMode.Properties.Items, cEnterMode);
  EditEnterMode.ItemIndex := 3;
  FillInFixData(EditExitMode.Properties.Items, cExitMode);
  EditExitMode.ItemIndex := 3;

  for nIdx:=0 to 99 do
    EditPlayDays.Items.Add(Format(ML('%s��'),[RegularInt(nIdx, 2), nIdx]));
  EditPlayDays.ItemIndex := 0;

  for nIdx:=0 to 126 do
    EditKeep.Properties.Items.Add(IntToStr(nIdx));
  EditKeep.ItemIndex := 1;

  for nIdx:=15 downto 0 do
    EditEnterSpeed.Properties.Items.Add(RegularInt(nIdx, 2));
  EditEnterSpeed.ItemIndex := 5;

  for nIdx:=15 downto 0 do
    EditExitSpeed.Properties.Items.Add(RegularInt(nIdx, 2));
  EditExitSpeed.ItemIndex := 5;

  for nIdx:=5 to 124 do
    EditFontSize.Items.Add(IntToStr(nIdx));
  EditFontSize.ItemIndex := 5;

  for nIdx:=2 to 128 do
    EditScreenW.Properties.Items.Add(IntToStr(nIdx * 8));
  EditScreenW.ItemIndex := -1;

  for nIdx:=2 to 32 do
    EditScreenH.Properties.Items.Add(IntToStr(nIdx * 8));
  EditScreenH.ItemIndex := -1;

  FillColorList(EditFontColor.Items);
  EditFontColor.ItemIndex := GetColorIndex(EditFontColor.Items, clRed);

  SysParamWithFile(True);
  GetValidCOMPort(EditPort.Items);
  EditPort.ItemIndex := EditPort.Items.IndexOf(gSysParam.FCOMMPort);
  EditBote.ItemIndex := EditBote.Items.IndexOf(IntToStr(gSysParam.FCOMMBote));

  if EditPort.Items.Count < 1 then
    EditPort.Text := ML('�޿��ô���');
  //xxxxx

  gMultiLangManager.SectionID := Name;
  gMultiLangManager.TranslateAllCtrl(Self);
  SetRStringMultiLang;
  //�����Է���
end;

//Desc: ��������
procedure TfFormMain.FormSaveConfig;
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath  + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    nIni.WriteString(Name, 'BgFile', FBGFile);
  finally
    nIni.Free;
  end;
end;

procedure TfFormMain.FormCreate(Sender: TObject);
begin
  Randomize;
  gPath := ExtractFilePath(Application.ExeName);
  InitGlobalVariant(gPath, gPath + sConfigFile, gPath + sFormConfig);

  if not IsValidConfigFile(gPath + sConfigFile, sProgID) then
  begin
    ShowDlg(sInvalidConfig, sHint, GetDesktopWindow);
    Application.Terminate;
  end;
  //�����ļ����Ķ�

  gStatusBar := SBar;
  FormLoadConfig;
  //��������
  
  wPage.ActivePage := SheetMemo;
  WorkPanel.DoubleBuffered := True;
  FBGControl := TZnImageControl.Create(WorkPanel);

  with FBGControl do
  begin
    Parent := WorkPanel;
    Align := alClient;
    OnClick := OnBgImageClick;

    if FileExists(FBGFile) then
      Image.LoadFromFile(FBGFile);
  end;
  //���ɱ���ͼƬ

  FEditor := THBEditControl.Create(Self);
  FEditor.Parent := WorkPanel;
  WorkPanelResize(nil);

  if FileExists(FLastFile) then
    MovieInDisk(FLastFile, False);
  //xxxxx
end;

procedure TfFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if gIsSending then
  begin
    Action := caNone; Exit;
  end;

  {$IFNDEF debug}
  if not QueryDlg(ML('ȷ��Ҫ�رճ�����?', sMLCommon), sAsk) then
  begin
    Action := caNone; Exit;
  end;
  {$ENDIF}

  FormSaveConfig;
  //��������
end;

//------------------------------------------------------------------------------
//Desc: ����ѡ��������
procedure TfFormMain.OnBgImageClick(Sender: TObject);
begin
  ActiveControl := nil;
end;

procedure TfFormMain.Timer1Timer(Sender: TObject);
begin
  sBar.Panels[1].Text := Time2Str(Now);
end;

//Desc: ���ݹ���Ȩ���������״̬
procedure TfFormMain.ResetCtrlStatus;
begin
  EditPort.ReadOnly := not gSysParam.FIsAdmin;
  EditBote.ReadOnly := not gSysParam.FIsAdmin;

  EditPwd.Enabled := not gSysParam.FIsAdmin;
  BtnLogoff.Enabled := gSysParam.FIsAdmin;
  BtnSyncTime.Enabled := gSysParam.FIsAdmin;
  BtnSaveParam.Enabled := gSysParam.FIsAdmin;
  BtnCheckPort.Enabled := gSysParam.FIsAdmin;

  BtnSaveWH.Enabled := gSysParam.FIsAdmin;
  EditScreenW.Properties.ReadOnly := not gSysParam.FIsAdmin;
  EditScreenH.Properties.ReadOnly := not gSysParam.FIsAdmin;
end;

//Desc: ��ȡnBarItem��Ӧ�Ŀؼ�����
function TfFormMain.GetBarEditText(const nBarItem: TcxBarEditItem): string;
begin
  if VarIsNull(nBarItem.CurEditValue) then
       Result := ''
  else Result := nBarItem.CurEditValue;
end;

//Desc: ����Ա��¼
procedure TfFormMain.EditPwdPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nStr,nPwd0,nPwd1,nPwd2: string;
begin
  nStr := Trim(GetBarEditText(EditPwd));

  if nStr = '' then
  begin
    ShowMsg(ML('��������Ч������', sMLCommon), sHint);
  end;

  with TIniFile.Create(gPath + sConfigFile) do
  try
    nPwd0 := ReadString('Setup', 'AdminPwd0', '');
    nPwd1 := ReadString('Setup', 'AdminPwd1', '');
    nPwd2 := ReadString('Setup', 'AdminPwd2', '');
  finally
    Free;
  end;

  nStr := EncodeBase64(nStr);
  if (nPwd0 = nStr) or (nPwd1 = nStr) or (nPwd2 = nStr) then
  begin
    ((EditPwd.CurItemLink.Control as TcxBarEditItemControl).Edit as TcxButtonEdit).Text := '';
    gSysParam.FIsAdmin := True;

    ResetCtrlStatus;
    ShowMsg(ML('��¼�ɹ�', sMLCommon), sHint);  
  end else ShowMsg(ML('����������Ч', sMLCommon), sHint);
end;

procedure TfFormMain.EditPwdKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
  begin
    Key := 0;
    EditPwdPropertiesButtonClick(nil, 0);
  end;
end;

//Desc: ע����¼
procedure TfFormMain.BtnLogoffClick(Sender: TObject);
begin
  gSysParam.FIsAdmin := False;
  ResetCtrlStatus;
  ShowMsg(ML('ע���ɹ�', sMLCommon), sHint);
end;

//Desc: ��дϵͳ����
procedure TfFormMain.SysParamWithFile(const nRead: Boolean);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    if nRead then
    begin
      gSysParam.FCOMMPort := nIni.ReadString('conn', 'Port', '');
      gSysParam.FCOMMBote := nIni.ReadInteger('conn', 'Bote', 0);
    end else
    begin
      nIni.WriteString('conn', 'Port', gSysParam.FCOMMPort);
      nIni.WriteInteger('conn', 'Bote', gSysParam.FCOMMBote);
    end;
  finally
    nIni.Free;
  end;
end;

//Desc: ������ɫ
procedure TfFormMain.EditFontColorDrawItem(Sender: TdxBarCustomCombo;
  AIndex: Integer; ARect: TRect; AState: TOwnerDrawState);
var nColor: TColor;
    nRect: TRect;
begin
  nRect := ARect;
  InflateRect(nRect, -1, -1);

  nColor := Integer(Sender.Items.Objects[AIndex]);
  Sender.Canvas.Brush.Color := nColor;
  Sender.Canvas.FillRect(nRect);
end;

//Desc: �������
procedure TfFormMain.EditPortChange(Sender: TObject);
begin
  if EditPort.ItemIndex > -1 then
    gSysParam.FCOMMPort := EditPort.Text;
  if EditBote.ItemIndex > -1 then
    gSysParam.FCOMMBote := StrToInt(EditBote.Text);
  SysParamWithFile(False);
end;

//Desc: ����λ��
procedure TfFormMain.WorkPanelResize(Sender: TObject);
begin
  if Assigned(FEditor) then
  begin
    FEditor.Left := Round((WorkPanel.Width - FEditor.Width) / 2);
    if FEditor.Left < 0 then FEditor.Left := 0;
    FEditor.Top := Round((WorkPanel.Height - FEditor.Height) / 2);
    if FEditor.Top < 0 then FEditor.Top := 0;
  end;
end;

//------------------------------------------------------------------------------
//Desc: �½�
procedure TfFormMain.Act_NewExecute(Sender: TObject);
var nStr: string;
begin
  if ListMovie.Items.Count > 0 then
  begin
    nStr := ML('ȷ��Ҫ������ǰ��Ŀ������?', sMLCommon);
    if not QueryDlg(nStr, sAsk, Handle) then Exit;
  end;

  FEditor.ClearData(FEditor.Data, False);
  FEditor.SetActiveData(nil, True);
  FEditor.Text := '';
  EditText.Text := '';

  ListMovie.Items.Clear;
  SetBarStatus(False);
  ShowMsgOnLastPanelOfStatusBar(ML(sCorConcept));

  FLastFile := '';
  LastFileInDisk(True);
end;

//Desc: ��
procedure TfFormMain.Act_OpenExecute(Sender: TObject);
var nStr: string;
begin
  gMultiLangManager.SectionID := sMLCommon;
  with TOpenDialog.Create(Application) do
  begin
    Title := ML('��');
    Filter := ML('��Ŀ�ļ�(*.Fyi)|*.Fyi');
    Options := Options + [ofFileMustExist];

    if Execute then nStr := FileName else nStr := '';
    Free;
  end;

  if nStr <> '' then
  begin
    if MovieInDisk(nStr, False) then
         ShowMsg(ML('��Ŀ�򿪳ɹ�'), sHint)
    else ShowMsg(ML('��Ŀ��ʧ��'), sHint);

    ShowMsgOnLastPanelOfStatusBar(nStr);
  end;
end;

//Desc: ����
procedure TfFormMain.Act_SaveExecute(Sender: TObject);
var nStr: string;
begin
  gMultiLangManager.SectionID := sMLCommon;
  with TSaveDialog.Create(Application) do
  begin
    Title := ML('����');
    Filter := ML('��Ŀ�ļ�(*.Fyi)|*.Fyi');

    DefaultExt := '*.Fyi';
    Options := Options + [ofOverwritePrompt];

    if FileExists(FLastFile) then
      FileName := FLastFile;
    //xxxxx
    
    if Execute then nStr := FileName else nStr := '';
    Free;
  end;

  if nStr <> '' then
  begin
    if MovieInDisk(nStr, True) then
    begin
      FLastFile := nStr;
      LastFileInDisk(True);
      ShowMsg(ML('��Ŀ����ɹ�'), sHint);
    end else ShowMsg(ML('��Ŀ����ʧ��'), sHint);
  end;
end;

//Desc: �л�����
procedure TfFormMain.BtnBgClick(Sender: TObject);
var nIdx: Integer;
    nBool: Boolean;
    nList: TStrings;
    nRes: TSearchRec;
begin
  nList := TStringList.Create;
  try
    nBool := FindFirst(gPath + 'bg\*.bmp', faAnyFile, nRes) = 0;
    while nBool do
    begin
      nList.Add(gPath + 'bg\' + nRes.Name);
      nBool := FindNext(nRes) = 0;
    end;

    FindClose(nRes);
    nIdx := nList.IndexOf(FBGFile);

    Inc(nIdx);
    if nIdx >= nList.Count then nIdx := 0;

    if (nIdx < nList.Count) and FileExists(nList[nIdx]) then
    begin
      FBGControl.Image.LoadFromFile(nList[nIdx]);
      FBGControl.Invalidate;
      FBGFile := nList[nIdx];
    end;
  finally
    nList.Free;
  end;
end;

//Desc: ����
procedure TfFormMain.Act_HelpExecute(Sender: TObject);
var nStr: string;
begin
  gMultiLangManager.SectionID := sMLCommon;
  nStr := ML('1.������������ʾ��,��ȷ�ϴ��ںż��������ʺ�����') + #13#10 +
          ML('2.���ʹ��USBת�����豸,���ڵ����豸��������ȷ�����ں�') + #13#10 +
          ML('3.���ݸ��ĺ�,ͨ��������ʾ��ť�۲�����Ч��') + #13#10;
  ShowDlg(nStr, ML('��������'), Handle);
end;

//Desc: ����
procedure TfFormMain.Act_AboutExecute(Sender: TObject);
var nStr: string;
begin
  gMultiLangManager.SectionID := sMLCommon;
  nStr := ML('��Ȩ���� ��Ȩ�ؾ�') + #13#10 +
          ML('�汾:') + gSysParam.FMainTitle;
  ShowDlg(nStr, ML('����'), Handle);
end;

//Desc: �˳�
procedure TfFormMain.N16Click(Sender: TObject);
begin
  Close;
end;

//Desc: ��д�ϴδ򿪵Ľ�Ŀ�ļ�
function TfFormMain.LastFileInDisk(const nSave: Boolean): Boolean;
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    if nSave then
         nIni.WriteString(Name, 'LastFile', FLastFile)
    else FLastFile := nIni.ReadString(Name, 'LastFile', '');

    nIni.Free;
    Result := True;
  except
    nIni.Free;
    Result := False;
  end;
end;

//Desc: ��nIni�ж�дnFont����Ϣ
procedure IniFont(const nIni: TIniFile; const nSec: string;
 const nFont: TFont; const nRead: Boolean);
var nStr: string;
    nInt: Integer;
begin
  if nRead then
  begin
    nStr := nIni.ReadString(nSec, 'FontName', '����');
    if nStr <> '' then nFont.Name := nStr;

    nFont.Size := nIni.ReadInteger(nSec, 'FontSize', 9);
    nFont.Color := nIni.ReadInteger(nSec, 'FontColor', clRed);

    nInt := nIni.ReadInteger(nSec, 'FontBold', -1);
    if nInt > 0 then
         nFont.Style := nFont.Style + [fsBold]
    else nFont.Style := nFont.Style - [fsBold];

    nInt := nIni.ReadInteger(nSec, 'FontItaly', -1);
    if nInt > 0 then
         nFont.Style := nFont.Style + [fsItalic]
    else nFont.Style := nFont.Style - [fsItalic];

    nInt := nIni.ReadInteger(nSec, 'FontUnder', -1);
    if nInt > 0 then
         nFont.Style := nFont.Style + [fsUnderline]
    else nFont.Style := nFont.Style - [fsUnderline];
  end else
  begin
    nIni.WriteString(nSec, 'FontName', nFont.Name);
    nIni.WriteInteger(nSec, 'FontSize', nFont.Size);
    nIni.WriteInteger(nSec, 'FontColor', nFont.Color);

    nIni.WriteBool(nSec, 'FontBold', fsBold in nFont.Style);
    nIni.WriteBool(nSec, 'FontItaly', fsItalic in nFont.Style);
    nIni.WriteBool(nSec, 'FontUnder', fsUnderline in nFont.Style);
  end;
end;

//Desc: ��nIni�ж�дnData����Ϣ
procedure IniData(const nIni: TIniFile; const nSec: string;
 const nData: PBitmapDataItem; const nRead: Boolean);
var nStr: string;
begin
  if nRead then
  begin
    FillChar(nData^, SizeOf(TBitmapDataItem), #0);
    nStr := nIni.ReadString(nSec, 'Text', '');
    if nStr <> '' then nData.FText := DecodeBase64(nStr);

    nData.FFont := TFont.Create;
    IniFont(nIni, nSec, nData.FFont, True);

    nData.FModeEnter := nIni.ReadString(nSec, 'ModeEnter', '03');
    nData.FModeExit := nIni.ReadString(nSec, 'ModeExit', '03');
    nData.FModeSerial := nIni.ReadString(nSec, 'ModeSerial', '01');
    nData.FSpeedEnter := nIni.ReadString(nSec, 'SpeedEnter', '0a');
    nData.FSpeedExit := nIni.ReadString(nSec, 'SpeedExit', '0a');
    nData.FKeedTime := nIni.ReadString(nSec, 'KeedTime', '01');

    nData.FVerAlign := nIni.ReadInteger(nSec, 'VerAlign', 0);
    nData.FHorAlign := nIni.ReadInteger(nSec, 'HorAlign', 0);
  end else
  begin
    nIni.WriteString(nSec, 'Text', EncodeBase64(nData.FText));
    IniFont(nIni, nSec, nData.FFont, False);

    nIni.WriteString(nSec, 'ModeEnter', nData.FModeEnter);
    nIni.WriteString(nSec, 'ModeExit', nData.FModeExit);
    nIni.WriteString(nSec, 'ModeSerial', nData.FModeSerial);
    nIni.WriteString(nSec, 'SpeedEnter', nData.FSpeedEnter);
    nIni.WriteString(nSec, 'SpeedExit', nData.FSpeedExit);
    nIni.WriteString(nSec, 'KeedTime', nData.FKeedTime);

    nIni.WriteInteger(nSec, 'VerAlign', nData.FVerAlign);
    nIni.WriteInteger(nSec, 'HorAlign', nData.FHorAlign);
  end;
end;

//Desc: �򿪱����Ŀ�ļ�
function TfFormMain.MovieInDisk(const nFile: string;
  const nSave: Boolean): Boolean;
var nIni: TIniFile;
    i,nLen: Integer;
    nItem: PBitmapDataItem;
begin
  nIni := TIniFile.Create(nFile);
  try
    if nSave then
    begin
      nIni.WriteInteger('Editor', 'Width', FEditor.Width);
      nIni.WriteInteger('Editor', 'Height', FEditor.Height);
      nIni.WriteString('Editor', 'Text', EncodeBase64(FEditor.Text));
      
      IniFont(nIni, 'Editor', FEditor.NormalFont, False);
      nIni.WriteBool('Editor', 'OldCard', EditJR.Checked);
      nIni.WriteBool('Editor', 'HideBlank', FEditor.HideBlank);
      nIni.WriteInteger('Editor', 'Movies', FEditor.Data.Count);

      nLen := FEditor.Data.Count - 1;
      for i:=0 to nLen do
      begin
        nItem := FEditor.Data[i];
        IniData(nIni, 'Movie_' + IntToStr(i), nItem, False);
      end;

      GetClockParam(False);
      with gSysParam, nIni do
      begin
        WriteBool('ClockTime', 'EnableClock', FEnableClock);
        WriteBool('ClockTime', 'EnableTime', FEnablePD);

        WriteString('ClockTime', 'EnableYear', FClockYear);
        WriteString('ClockTime', 'EnableMonth', FClockMonth);
        WriteString('ClockTime', 'EnableDay', FClockDay);
        WriteString('ClockTime', 'EnableWeek', FClockWeek);
        WriteString('ClockTime', 'EnableHour', FClockTime);

        WriteString('ClockTime', 'Char', FClockChar);
        WriteString('ClockTime', 'Mode', FClockMode);
        WriteString('ClockTime', 'Position', FClockPos);
        WriteString('ClockTime', 'PlayDays', FPlayDays);
      end;
    end else
    begin
      FEditor.Width := nIni.ReadInteger('Editor', 'Width', 64);
      FEditor.Height := nIni.ReadInteger('Editor', 'Height', 32);

      FEditor.Text := nIni.ReadString('Editor', 'Text', '');
      if FEditor.Text <> '' then FEditor.Text := DecodeBase64(FEditor.Text);
      IniFont(nIni, 'Editor', FEditor.NormalFont, True);

      FEditor.ClearData(FEditor.Data, False);
      nLen := nIni.ReadInteger('Editor', 'Movies', 0) - 1;
      for i:=0 to nLen do
      begin
        New(nItem);
        FEditor.Data.Add(nItem);
        IniData(nIni, 'Movie_' + IntToStr(i), nItem, True);
      end;

      with gSysParam, nIni do
      begin
        FEnableClock := ReadBool('ClockTime', 'EnableClock', False);
        FEnablePD := ReadBool('ClockTime', 'EnableTime', False);

        FClockYear := ReadString('ClockTime', 'EnableYear', '00');
        FClockMonth := ReadString('ClockTime', 'EnableMonth', '00');
        FClockDay := ReadString('ClockTime', 'EnableDay', '00');
        FClockWeek := ReadString('ClockTime', 'EnableWeek', '00');
        FClockTime := ReadString('ClockTime', 'EnableHour', '00');

        FClockChar := ReadString('ClockTime', 'Char', '00');
        FClockMode := ReadString('ClockTime', 'Mode', '01');
        FClockPos := ReadString('ClockTime', 'Position', '04');
        FPlayDays := ReadString('ClockTime', 'PlayDays', '00');
      end;

      EditJR.Checked := nIni.ReadBool('Editor', 'OldCard', False);
      FEditor.HideBlank := nIni.ReadBool('Editor', 'HideBlank', True);
      UpdateFormData;
    end;

    nIni.Free;
    Result := True;
  except
    nIni.Free;
    Result := False;
  end;
end;

//Desc: �����ݸ��µ�����
procedure TfFormMain.UpdateFormData;
var nIdx: Integer;
begin
  EditScreenW.Text := IntToStr(FEditor.Width);
  EditScreenH.Text := IntToStr(FEditor.Height);
  EditText.Text := FEditor.Text;

  BtnClock.Down := gSysParam.FEnableClock;
  BtnTime.Down := gSysParam.FEnablePD;

  nIdx := GetFixDataIdx(EditTimeChar.Items, gSysParam.FClockChar, cTimeChar);
  if nIdx < 0 then nIdx := 0;
  EditTimeChar.ItemIndex := nIdx;

  nIdx := GetFixDataIdx(EditDispMode.Items, gSysParam.FClockMode, cDispMode);
  EditDispMode.ItemIndex := nIdx;

  nIdx := GetFixDataIdx(EditDispPos.Items, gSysParam.FClockPos, cDispPos);
  EditDispPos.ItemIndex := nIdx;

  BtnYear.Down := gSysParam.FClockYear = '01';
  BtnMonth.Down := gSysParam.FClockMonth = '01';
  BtnDay.Down := gSysParam.FClockDay = '01';
  BtnWeek.Down := gSysParam.FClockWeek = '01';
  BtnHour.Down := gSysParam.FClockTime = '01';
  EditPlayDays.ItemIndex := StrToInt(Hex2Normal(gSysParam.FPlayDays)); 

  LoadMovieList;
  //movie list
end;

//------------------------------------------------------------------------------
//Desc: ��ȡ����
procedure TfFormMain.Act_ConnExecute(Sender: TObject);
var nStr: string;
    nWH: TPoint;
begin
  if FDM.GetCardWH(nWH, nStr) then
  begin
    EditScreenW.Text := IntToStr(nWH.X);
    EditScreenH.Text := IntToStr(nWH.Y);
  end;

  ShowMsg(nStr, sHint);
end;

//Desc: ��ȡʱ�Ӳ���
function TfFormMain.GetClockParam(const nHint: Boolean): Boolean;
var nY,nM,nD,nHH,nMM,nSS,nMS: Word;
begin
  Result := False;
  gMultiLangManager.SectionID := sMLCommon;

  if (EditTimeChar.CurItemIndex < 0) and nHint then
  begin
    EditTimeChar.SetFocus;
    ShowMsg(ML('��ѡ��ʱ�Ӹ�ʽ'), sHint); Exit;
  end;

  if (EditDispMode.CurItemIndex < 0) and nHint then
  begin
    EditDispMode.SetFocus;
    ShowMsg(ML('��ѡ����ʾģʽ'), sHint); Exit;
  end;

  if (EditDispPos.CurItemIndex < 0) and nHint then
  begin
    EditDispPos.SetFocus;
    ShowMsg(ML('��ѡ����ʾλ��'), sHint); Exit;
  end;

  with gSysParam do
  begin
    FEnableClock := BtnClock.Down;
    FClockChar := GetFixData(EditTimeChar.Items, EditTimeChar.CurItemIndex, cTimeChar);
    if FClockChar = '' then FClockChar := '00';

    if not FEnableClock then
      FClockChar := 'ff';
    //xxxxx

    FClockMode := GetFixData(EditDispMode.Items, EditDispMode.CurItemIndex, cDispMode);
    if FClockMode = '' then FClockMode := '01';

    FClockPos := GetFixData(EditDispPos.Items, EditDispPos.CurItemIndex, cDispPos);
    if FClockPos = '' then FClockPos := '05';

    if BtnYear.Down then FClockYear := '01' else FClockYear := '00';
    if BtnMonth.Down then FClockMonth := '01' else FClockMonth := '00';
    if BtnDay.Down then FClockDay := '01' else FClockDay := '00';
    if BtnWeek.Down then FClockWeek := '01' else FClockWeek := '00';
    if BtnHour.Down then FClockTime := '01' else FClockTime := '00';

    DecodeDate(Now(), nY, nM, nD);
    FClockSYear := IntToStr(nY);
    System.Delete(FClockSYear, 1, 2);
    FClockSYear := '14' + HexStr(FClockSYear);

    FClockSMonth := HexStr(nM);
    FClockSDay := HexStr(nD);

    DecodeTime(Now(), nHH, nMM, nSS, nMS);
    FClockSHour := HexStr(nHH);
    FClockSMin := HexStr(nMM);
    FClockSSec := HexStr(nSS);

    nD := DayOfWeek(Now);
    if nD = 1 then
         nD := 7
    else Dec(nD);
    FClockSWeek := HexStr(nD);

    FEnablePD := BtnTime.Down;
    FPlayDays := HexStr(EditPlayDays.ItemIndex);
  end;

  Result := True;
end;

//Desc: ͬ��ʱ��
procedure TfFormMain.BtnSyncTimeClick(Sender: TObject);
var nStr: string;
begin
  if GetClockParam(True) then
  begin
    FDM.SendClock(nStr);
    ShowMsg(nStr, sHint);
  end;
end;

//Desc: ��������
procedure TfFormMain.BtnSaveParamClick(Sender: TObject);
var nStr: string;
    nWH: TPoint;
begin
  gMultiLangManager.SectionID := sMLMain;

  if EditScreenW.ItemIndex < 0 then
  begin
    EditScreenW.SetFocus;
    ShowMsg(ML('��ѡ������'), sHint); Exit;
  end;

  if EditScreenH.ItemIndex < 0 then
  begin
    EditScreenH.SetFocus;
    ShowMsg(ML('��ѡ������'), sHint); Exit;
  end;

  nWH := Point(StrToInt(EditScreenW.Text), StrToInt(EditScreenH.Text));
  FDM.SendCardWH(nWH, nStr);
  ShowMsg(nStr, sHint);
end;

//Desc: �������ö˿�
procedure TfFormMain.BtnCheckPortClick(Sender: TObject);
var nStr: string;
    nIdx: Integer;
begin
  GetValidCOMPort(EditPort.Items);
  //ˢ���б�

  if EditPort.Items.Count < 1 then
  begin
    ShowMsg(ML('δ���ֿ��ÿ��ƿ�', sMLCommon), sHint); Exit;
  end;

  if EditBote.ItemIndex < 0 then
  begin
    ShowMsg(ML('��ѡ����Ч������', sMLCommon), sHInt); Exit;
  end;

  ShowWaitForm(Self, ML('����ɨ����ƿ�', sMLCommon));
  try
    EditPort.ItemIndex := -1;
    FDM.ComPort1.BaudRate := StrToBaudRate(EditBote.Text);
    //baud rate

    for nIdx:=0 to EditPort.Items.Count - 1 do
    try
      FDM.ComPort1.Close;
      FDM.ComPort1.Port := EditPort.Items[nIdx];
      FDM.ComPort1.Open;

      FDM.ComPort1.WriteStr('X');
      if (FDM.ComPort1.ReadStr(nStr, 1) = 1) and (nStr = 'X') then
      begin
        EditPort.ItemIndex := nIdx;
        ShowMsg(ML('�ҵ����ÿ��ƿ�', sMLCommon), sHint); Break;
      end;
    except
      //maybe any error
    end;
  finally
    CloseWaitForm;
    if EditPort.ItemIndex < 0 then
      ShowMsg(ML('δ�ҵ����ÿ��ƿ�', sMLCommon), sHint);
    FDM.ComPort1.Close;
  end;
end;

//Desc: ʱ��
procedure TfFormMain.EditTimeCharChange(Sender: TObject);
begin
  if (Sender = BtnClock) or (Assigned(FEditor) and ((Sender = EditJR) or
     (Assigned(BarMgr.SelectedItem) and BarMgr.SelectedItem.IsSelected))) then
  begin
    FEditor.HasClock := BtnClock.Down and
                        (EditDispMode.CurItemIndex = 0) and (not EditJR.Checked);
    //�Ƿ���ʾʱ��

    GetClockParam(False);
    FEditor.Invalidate;
  end;
end;

//Desc: �������
procedure TfFormMain.EditScreenWPropertiesEditValueChanged(Sender: TObject);
var nWH: TPoint;
begin
  if (EditScreenW.ItemIndex > -1) and (EditScreenH.ItemIndex > -1) then
  begin
    nWH := Point(StrToInt(EditScreenW.Text), StrToInt(EditScreenH.Text));
    gSysParam.FScreenWidth := nWH.X;
    gSysParam.FScreenHeight := nWH.Y;

    FEditor.Width := nWH.X;
    FEditor.Height := nWH.Y;
    WorkPanelResize(nil);
  end;
end;

//Desc: �����Ŀ�б�
procedure TfFormMain.LoadMovieList;
var nStr: string;
    i,nIdx,nLen: Integer;
begin
  nIdx := ListMovie.ItemIndex;
  ListMovie.Clear;
  
  nStr := ML('��%d��', sMLCommon);
  nLen := FEditor.Data.Count - 1;

  for i:=0 to nLen do
    ListMovie.Items.AddObject(Format(nStr, [ListMovie.Items.Count+1]), TObject(i));
  //xxxxx

  if nIdx < 0 then
    nIdx := 0;
  //xxxxx
  
  if nIdx >= ListMovie.Items.Count then
    nIdx := ListMovie.Items.Count - 1;
  ListMovie.ItemIndex := nIdx;
  ListMovieClick(nil);
end;

//Desc: ����
procedure TfFormMain.BtnSyncClick(Sender: TObject);
begin
  SetBarStatus(False);
  EditText.Text := TrimLeft(EditText.Text);

  if EditText.Text = '' then
  begin
    EditText.SetFocus;
    ShowMsg(ML('�������Ŀ����', sMLCommon), sHint); Exit;
  end;

  FEditor.Text := EditText.Text;
  FEditor.SetActiveData(nil);
  
  FEditor.SpitTextNormal(FEditor.Data);
  LoadMovieList;
end;

//Desc: ɾ����ǰ��
procedure TfFormMain.BtnDelClick(Sender: TObject);
var nIdx: Integer;
begin
  nIdx := ListMovie.ItemIndex;
  FEditor.DeleteData(FEditor.Data, nIdx);
  ListMovie.DeleteSelected;

  if nIdx >= ListMovie.Count then
    Dec(nIdx);
  ListMovie.ItemIndex := nIdx;

  SetBarStatus(ListMovie.ItemIndex > -1);
  ListMovieClick(nil);
end;

//Desc: ��ȡ��ǰ���Ŀ
function TfFormMain.GetActiveMovie: PBitmapDataItem;
var nIdx: Integer;
begin
  if (ListMovie.ItemIndex > -1) and Assigned(FEditor) then
  begin
    //nIdx := Integer( ListMovie.Items.Objects[ListMovie.ItemIndex] );
    nIdx := ListMovie.ItemIndex;
    Result := FEditor.Data[nIdx];
  end else Result := nil;
end;

//Desc: ͳһʹ�õ�ǰģʽ
procedure TfFormMain.BtnModeSyncClick(Sender: TObject);
var nStr: string;
    i,nLen: Integer;
    nItem: PBitmapDataItem;
begin
  nStr := ML('ȷ��Ҫ����ǰģʽӦ�õ�������Ļ��?', sMLCommon);
  if not QueryDlg(nStr, sAsk, Handle) then Exit;

  nItem := GetActiveMovie;
  nLen := FEditor.Data.Count - 1;

  for i:=ListMovie.ItemIndex+1 to nLen do
  with PBitmapDataItem(FEditor.Data[i])^ do
  begin
    if FEditor.Data[i] = nItem then Continue;

    FFont.Assign(nItem.FFont);
    FHorAlign := nItem.FHorAlign;
    FVerAlign := nItem.FVerAlign;

    FModeEnter := nItem.FModeEnter;
    FModeExit := nItem.FModeExit;
    FModeSerial := nItem.FModeSerial;

    FSpeedEnter := nItem.FSpeedEnter;
    FSpeedExit := nItem.FSpeedExit;
    FKeedTime := nItem.FKeedTime;
  end;

  EditBlank.Enabled := FEditor.ScrollMode <> smNormal;
  //�ո���
end;

//------------------------------------------------------------------------------
//Desc: ���ù�����״̬
procedure TfFormMain.SetBarStatus(const nEnable: Boolean);
var i,nNum: Integer;
begin
  BtnDel.Enabled := nEnable;
  nNum := BarEdit.ItemLinks.Count - 1;

  for i:=0 to nNum do
    BarEdit.ItemLinks[i].Item.Enabled := nEnable;
  //xxxxx

  BtnRestoreText.Enabled := True;
  BtnCopy.Enabled := True;
  BtnCut.Enabled := True;
  BtnPaste.Enabled := True;
  BtnSend.Enabled := True;

  nNum := GroupMode.ControlCount - 1;  
  for i:=0 to nNum do
    GroupMode.Controls[i].Enabled := nEnable;
  //xxxxx

  EditExitMode.Enabled := nEnable and (not EditGS.Checked);
  EditExitSpeed.Enabled := nEnable and (not EditGS.Checked);

  EditBlank.Checked := Assigned(FEditor) and FEditor.HideBlank;
  EditBlank.Enabled := Assigned(FEditor) and (FEditor.ScrollMode <> smNormal);
end;

//Desc: ���û����
procedure TfFormMain.ListMovieClick(Sender: TObject);
var nItem: PBitmapDataItem;
begin
  nItem := GetActiveMovie;
  if Assigned(nItem) then
  begin
    EditFontName.EditValue := nItem.FFont.Name;
    EditFontSize.Text := IntToStr(nItem.FFont.Size);
    EditFontColor.ItemIndex := GetColorIndex(EditFontColor.Items, nItem.FFont.Color);

    BtnBold.Down := fsBold in nItem.FFont.Style;
    BtnItaly.Down := fsItalic in nItem.FFont.Style;
    BtnUnder.Down := fsUnderline in nItem.FFont.Style;

    BtnHLeft.Down := nItem.FHorAlign = 0;
    BtnHMid.Down := nItem.FHorAlign = 1;
    BtnHRight.Down := nItem.FHorAlign = 2;

    BtnVTop.Down := nItem.FVerAlign = 0;
    BtnVMid.Down := nItem.FVerAlign = 1;
    BtnVBottom.Down := nItem.FVerAlign = 2;

    with EditEnterMode.Properties do
     EditEnterMode.ItemIndex := GetFixDataIdx(Items, nItem.FModeEnter, cEnterMode);
    //xxxxx

    with EditExitMode.Properties do
     EditExitMode.ItemIndex := GetFixDataIdx(Items, nItem.FModeExit, cExitMode);
    //xxxxx

    EditEnterSpeed.Text := RegularInt(15 - StrToInt(Hex2Normal(nItem.FSpeedEnter)), 2);
    EditExitSpeed.Text := RegularInt(15 - StrToInt(Hex2Normal(nItem.FSpeedExit)), 2);
    EditKeep.Text := Hex2Normal(nItem.FKeedTime, 0);
    EditGS.Checked := nItem.FModeSerial = '01';

    FEditor.SetActiveData(nItem);
  end;

  SetBarStatus(Assigned(nItem));
end;

//Desc: ģʽ�ı�
procedure TfFormMain.EditEnterModePropertiesChange(Sender: TObject);
var nStr: string;
    nItem: PBitmapDataItem;
begin
  if not (Sender as TCustomControl).Focused then Exit;
  nItem := GetActiveMovie;

  if Assigned(nItem) then
  begin
    with EditEnterMode do
     nStr := GetFixData(Properties.Items, ItemIndex, cEnterMode);
    if nStr <> '' then nItem.FModeEnter := nStr;

    with EditExitMode do
     nStr := GetFixData(Properties.Items, ItemIndex, cExitMode);
    if nStr <> '' then nItem.FModeExit := nStr;

    nStr := EditEnterSpeed.Text;
    if IsNumber(nStr, False) then nItem.FSpeedEnter := HexStr(15 - StrToInt(nStr));

    nStr := EditExitSpeed.Text;
    if IsNumber(nStr, False) then nItem.FSpeedExit := HexStr(15 - StrToInt(nStr));

    nStr := EditKeep.Text;
    if IsNumber(nStr, False) then nItem.FKeedTime := HexStr(nStr);

    if EditGS.Checked then
         nItem.FModeSerial := '01'
    else nItem.FModeSerial := '00';

    EditExitMode.Enabled := not EditGS.Checked;
    EditExitSpeed.Enabled := not EditGS.Checked;

    FEditor.HideBlank := EditBlank.Checked;
    EditBlank.Enabled := FEditor.ScrollMode <> smNormal;
    //�ո���
  end;
end;

//Desc: �л�����
procedure TfFormMain.EditFontNamePropertiesChange(Sender: TObject);
var nStr: string;
    nItem: PBitmapDataItem;
begin
  nItem := GetActiveMovie;
  nStr := GetBarEditText(EditFontName);

  if (nStr <> '') and Assigned(nItem) then
  begin
    FEditor.NormalFont.Name := nStr;
    nItem.FFont.Name := nStr;
    FEditor.SetActiveData(nItem, True);
  end;
end;

//Desc: �����С
procedure TfFormMain.EditFontSizeChange(Sender: TObject);
var nItem: PBitmapDataItem;
begin
  nItem := GetActiveMovie;
  if (EditFontSize.CurItemIndex > -1) and Assigned(nItem) then
  begin
    FEditor.NormalFont.Size := StrToInt(EditFontSize.CurText);
    nItem.FFont.Size := StrToInt(EditFontSize.CurText);
    FEditor.SetActiveData(nItem, True);
  end;
end;

//Desc: ������ɫ
procedure TfFormMain.EditFontColorChange(Sender: TObject);
var nItem: PBitmapDataItem;
begin
  nItem := GetActiveMovie;
  if (EditFontColor.CurItemIndex > -1) and Assigned(nItem) then
  begin
    FEditor.NormalFont.Color := Integer(EditFontColor.Items.Objects[EditFontColor.CurItemIndex]);
    nItem.FFont.Color := FEditor.NormalFont.Color;
    FEditor.SetActiveData(nItem, True);
  end;
end;

//Desc: ������
procedure TfFormMain.BtnBoldClick(Sender: TObject);
var nItem: PBitmapDataItem;
begin
  nItem := GetActiveMovie;
  if Assigned(nItem) then
  begin
    if BtnBold.Down then
         FEditor.NormalFont.Style := FEditor.NormalFont.Style + [fsBold]
    else FEditor.NormalFont.Style := FEditor.NormalFont.Style - [fsBold];

    if BtnItaly.Down then
         FEditor.NormalFont.Style := FEditor.NormalFont.Style + [fsItalic]
    else FEditor.NormalFont.Style := FEditor.NormalFont.Style - [fsItalic];

    if BtnUnder.Down then
         FEditor.NormalFont.Style := FEditor.NormalFont.Style + [fsUnderline]
    else FEditor.NormalFont.Style := FEditor.NormalFont.Style - [fsUnderline];

    nItem.FFont.Style := FEditor.NormalFont.Style;
    FEditor.SetActiveData(nItem, True);
  end;
end;

//Desc: ���з��
procedure TfFormMain.BtnHLeftClick(Sender: TObject);
var nItem: PBitmapDataItem;
begin
  nItem := GetActiveMovie;
  if Assigned(nItem) then
  begin
    if BtnVTop.Down then
      nItem.FVerAlign := 0 else
    if BtnVMid.Down then
      nItem.FVerAlign := 1 else nItem.FVerAlign := 2;

    if BtnHLeft.Down then
      nItem.FHorAlign := 0 else
    if BtnHMid.Down then
      nItem.FHorAlign := 1 else nItem.FHorAlign := 2;
    FEditor.SetActiveData(nItem, True);
  end;
end;

//Desc: ���½�Ŀ����
procedure TfFormMain.Act_SyncExecute(Sender: TObject);
var nStr: string;
begin
  nStr := ML('�����ָֻ�������֮ǰ?', sMLCommon);
  if QueryDlg(nStr, sAsk, Handle) then EditText.Text := FEditor.Text;
end;

//Desc: ��������
procedure TfFormMain.Act_CopyExecute(Sender: TObject);
begin
  if EditText.SelLength < 1 then
  begin
    EditText.SetFocus;
    ShowMsg(ML('��ѡ��Ҫ���Ƶ�����', sMLCommon), sHint);
  end else EditText.CopyToClipboard;
end;

//Desc: ��������
procedure TfFormMain.Act_CutExecute(Sender: TObject);
begin
  if EditText.SelLength < 1 then
  begin
    EditText.SetFocus;
    ShowMsg(ML('��ѡ��Ҫ���Ƶ�����', sMLMain), sHint);
  end else EditText.CutToClipboard;
end;

//Desc: ճ������
procedure TfFormMain.Act_PasteExecute(Sender: TObject);
begin
  EditText.PasteFromClipboard;
end;

//------------------------------------------------------------------------------
//Desc: ��������
procedure TfFormMain.Act_SendExecute(Sender: TObject);
var nStr: string;
    nList: TList;
    i,nLen: Integer;
    nSM: TScrollMode;
begin
  if ListMovie.Items.Count < 1 then
  begin
    wPage.ActivePage := SheetMemo;
    ListMovie.SetFocus;
    ShowMsg(ML('��Ŀ�б�Ϊ��', sMLCommon), sHint); Exit;
  end;

  nList := FEditor.Data;
  try
    nSM := FEditor.ScrollMode;
    if (not FEditor.HideBlank) or (nSM = smNormal) then
    begin
      nLen := FEditor.Data.Count - 1;
      for i:=0 to nLen do
        FEditor.PaintData(FEditor.Data[i]);
      //��������
    end else
    begin
      nList := TList.Create;
      if nSM = smHor then FEditor.SpitTextHor(nList) else
      if nSM = smVer then FEditor.SpitTextVer(nList);
    end;

    if SendDataList(nList, nStr) then
         ShowMsg(ML('���ͳɹ�', sMLCommon), sHint)
    else ShowMsg(nStr, sHint);
  finally
    if nList <> FEditor.Data then
      FEditor.ClearData(nList, True);
    //xxxxx
  end;
end;

//Desc: ����nData�����б�
function TfFormMain.SendDataList(const nData: TList; var nHint: string): Boolean;
var nWH: TPoint;
    nStr: string;
    nBool: Boolean;
    i,nLen: Integer;
begin
  Result := FDM.ConnCard(nBool, nHint);
  if not Result then Exit;

  try
    Result := FDM.GetCardWH(nWH, nHint, True);
    if not Result then Exit;

    ShowWaitForm(Self, '');
    nLen := nData.Count - 1;

    for i:=0 to nLen do
    begin
      nStr := Format('%d/%d', [i+1, nData.Count]);
      ShowWaitForm(nil, nStr);

      FDM.ComPort1.Write('T', 1);
      nStr := HexStr(i);
      FDM.ComPort1.Write(PChar(nStr), Length(nStr));

      Result := SendDataItem(nData[i]);
      if not Result then
      begin
        nHint := Format(ML('���͵� %d ������ʱ����,����ֹ!', sMLCommon), [i+1]);
        Exit;
      end;
    end;

    GetClockParam(True);
    Result := FDM.SendClock(nHint);
    FDM.ComPort1.Write('G', 1);
  finally
    CloseWaitForm;
    FDM.ComPort1.Close;
  end;
end;

//Desc: ����nData������
function TfFormMain.SendDataItem(const nData: PBitmapDataItem): Boolean;
var nStr: string;
    nLen: Integer;
begin
  try
    with nData^ do
     nStr := FModeEnter + FSpeedEnter + FKeedTime + FModeExit + FSpeedExit +
             FModeSerial + '00' + 'D';
    //xxxxx
    
    nLen := Length(nStr);
    Result := FDM.ComPort1.Write(PChar(nStr), nLen) = nLen;
    if not Result then Exit;

    nStr := ScanWithSingleMode(nData.FBitmap, clBlack, True);
    nLen := Length(nStr);
    Result := FDM.ComPort1.Write(PChar(nStr), nLen) = nLen;
  except
    Result := False;
  end;
end;

end.
