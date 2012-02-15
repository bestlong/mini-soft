{*******************************************************************************
  ����: dmzn@163.com 2011-4-29
  ����: ���������
*******************************************************************************}
unit UFormJS_M;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormBase, UMultiJS, UMultiJSCtrl, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, dxStatusBar;

type
  TfFormJS_M = class(TBaseForm)
    dxStatusBar1: TdxStatusBar;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure WorkPanelResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
    FBGImage: TBitmap;
    //����ͼ
    FPerWeight: Double;
    //����
    FLoadPanels: Boolean;
    //������
    FJSer: TMultiJSManager;
    //������
    FTunnels: array of TMultiJSPanelTunnel;
    //װ����
    procedure LoadTunnelList;
    //���복��
    procedure OnData(nPort: string; nData: TMultiJSTunnel);
    //��������
    procedure DoOnLoad(Sender: TObject; var nDone: Boolean);
    procedure DoOnStart(Sender: TObject; var nDone: Boolean);
    procedure DoOnStop(Sender: TObject; var nDone: Boolean);
    procedure DoOnDone(Sender: TObject; var nDone: Boolean);
    //��尴ť
  protected
    procedure EnableChanged(var Msg: TMessage); message WM_ENABLE;
    procedure CreateParams(var Params : TCreateParams); override;
    //������
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, UMgrControl, UDataModule, USysConst, UFormWait,
  UFormZTParam_M, UFormJSTruck_M, USysDB, USysGrid, ZnMD5;

var
  gForm: TfFormJS_M;
  //ȫ��ʹ��

class function TfFormJS_M.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;
  if not Assigned(gForm) then
  begin
    gForm := TfFormJS_M.Create(Application);
    with gForm do
    begin
      Caption := '��������̨';
      //FormStyle := fsStayOnTop;
      Position := poDesigned;
    end;
  end;

  with gForm do
  begin
    if not Showing then Show;
    WindowState := wsNormal;
  end;
end;

class function TfFormJS_M.FormID: integer;
begin
  Result := cFI_FormJSForm;
end;

procedure TfFormJS_M.FormCreate(Sender: TObject);
var nStr: string;
    nIni: TIniFile;
begin
  DoubleBuffered := True;
  FLoadPanels := False;
  FBGImage := nil;
  
  FJSer := TMultiJSManager.Create;
  FJSer.OnData := OnData;

  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    nStr := nIni.ReadString(Name, 'BGImage', '');
    nStr := MacroValue(nStr, [MI('$Path/', gPath)]);

    if FileExists(nStr) then
    begin
      FBGImage := TBitmap.Create;
      FBGImage.LoadFromFile(nStr);
    end;
  finally
    nIni.Free;
  end;
end;

procedure TfFormJS_M.FormClose(Sender: TObject; var Action: TCloseAction);
var nIdx: Integer;
begin
  for nIdx:=ControlCount - 1 downto 0 do
   if Controls[nIdx] is TMultiJSPanel then
    if (Controls[nIdx] as TMultiJSPanel).Tunnel.FStatus = sStatus_Busy then
  begin
    Action := caMinimize; Exit;
  end;

  SaveFormConfig(Self); 
  FBGImage.Free;
  FJSer.Free;
  
  Action := caFree;
  gForm := nil;
end;

//Desc: ������ͼ��
procedure TfFormJS_M.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
  //Params.ExStyle := Params.ExStyle or WS_EX_TOOLWINDOW;
end;

procedure TfFormJS_M.EnableChanged(var Msg: TMessage);
begin
  inherited;
  if not Active then
    EnableWindow(Handle, True);
  //has mouse focus
end;

//------------------------------------------------------------------------------
//Desc: ��ȡ��Ч��ջ����
function GetTunnelCount: Integer;
var nInt: Integer;
    nStr,nKey: string;
begin
  Result := 1;
  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';;
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_KeyName]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nKey := Fields[0].AsString;
    if Pos(nKey, gSysParam.FHintText) < 1 then Exit; //��˾����
  end else Exit;

  nStr := 'Select D_Value,D_ParamB From %s Where D_Name=''%s'' And D_Memo=''%s''';;
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ValidDate]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nStr := Format('dmzn_js_%s_%s', [nKey, Date2Str(Fields[0].AsDateTime)]);
    nStr := MD5Print(MD5String(nStr));
    if nStr <> Fields[1].AsString then Exit; //ϵͳ��Ч��

    nInt := Trunc(Fields[0].AsDateTime - Date());
    if nInt < 1 then
    begin
      Result := 0;
      ShowDlg('ϵͳ�ѹ���,����ϵ����Ա!', sHint); Exit;
    end;

    if nInt < 7 then
    begin
      nStr := Format('ϵͳ���� %d �쵽��', [nInt]);
      ShowMsg(nStr, sHint);
    end;
  end else Exit;

  nStr := 'Select D_Value,D_ParamB From %s Where D_Name=''%s'' And D_Memo=''%s''';;
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_Tunnel]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nStr := Format('dmzn_js_%s_%s', [nKey, Fields[0].AsString]);
    nStr := MD5Print(MD5String(nStr));
    if nStr = Fields[1].AsString then Result := Fields[0].AsInteger; //װ������
  end;
end;

//Desc: ���복���б�
procedure TfFormJS_M.LoadTunnelList;
var nList,nTmp: TStrings;
    i,nCount,nIdx: Integer;
begin
  nList := TStringList.Create;
  nTmp := TStringList.Create;
  try
    SetLength(FTunnels, 0);
    if not LoadZTList(nList) then Exit;
    nCount := nList.Count - 1;

    for i:=0 to nCount do
    if SplitStr(nList[i], nTmp, 4, ';') then
    begin
      nIdx := Length(FTunnels);
      SetLength(FTunnels, nIdx + 1);
      FillChar(FTunnels[nIdx], SizeOf(TMultiJSPanelTunnel), #0);

      with FTunnels[nIdx] do
      begin
        FPanelName := nTmp[0];
        FComm := nTmp[1];
        FTunnel := StrToInt(nTmp[2]);
        FDelay := StrToInt(nTmp[3]);
      end;
    end;

    i := Length(FTunnels);
    nCount := GetTunnelCount;

    if i < nCount then
      nCount := i;
    SetLength(FTunnels, nCount);

    nCount := High(FTunnels);
    if nCount < 0 then Exit;
    nList.Clear;

    for i:=Low(FTunnels) to nCount do
    begin
      if nList.IndexOf(FTunnels[i].FComm) < 0 then
        nList.Add(FTunnels[i].FComm);
      //port list

      with TMultiJSPanel.Create(Self) do
      begin
        Parent := Self;
        OnLoad := DoOnLoad;
        OnStart := DoOnStart;
        OnStop := DoOnStop;
        OnDone := DoOndone;

        PerWeight := FPerWeight;
        AdjustPostion;
        SetTunnel(FTunnels[i]);
      end;
    end;

    for i:=nList.Count - 1 downto 0 do
    begin
      nCount := 0;

      for nIdx:=Low(FTunnels) to High(FTunnels) do
       if CompareText(FTunnels[nIdx].FComm, nList[i]) = 0 then Inc(nCount);
      FJSer.AddPort(nList[i], 9600, nCount);
    end;
  finally
    nList.Free;
    nTmp.Free;
  end;
end;

//Desc: ���µ��������λ��
procedure TfFormJS_M.WorkPanelResize(Sender: TObject);
var i,nCount,nL,nT: Integer;
    nInt,nIdx,nNum,nFixL: Integer;
begin
  if not FLoadPanels then Exit;
  //û�������
  if Length(FTunnels) < 1 then Exit;
  //û�����

  with TMultiJSPanel.PanelRect do
  begin
    HorzScrollBar.Position := 0;
    VertScrollBar.Position := 0;

    nInt := Right + cSpace_H_Edge;
    nNum := Trunc((ClientWidth - cSpace_H_Edge) / nInt);

    nIdx := Length(FTunnels);
    if nNum > nIdx then nNum := nIdx;
    if nNum < 1 then nNum := 1;
    //ÿ�������

    nInt := nInt * nNum;
    if (ClientWidth - cSpace_H_Edge) <= nInt then
    begin
      nFixL := cSpace_H_Edge;
    end else //fill form
    begin
      nInt := (ClientWidth + cSpace_H_Edge) - nInt;
      nFixL := Trunc(nInt / 2) ;
    end; //center form

    nCount := Length(FTunnels);
    i := Trunc(nCount / nNum);
    if nCount mod nNum <> 0 then Inc(i);
    //�������

    nInt := (Bottom + cSpace_H_Edge) * i;
    if (ClientHeight - cSpace_H_Edge) <= nInt then
    begin
      nT := cSpace_H_Edge;
    end else //fill form
    begin
      nInt := ClientHeight - nInt;
      nT := Trunc(nInt / 2);
    end; //center form
  end;

  nIdx := 0;
  nL := nFixL;
  nCount := ControlCount - 1;

  for i:=0 to nCount do
  begin
    if not (Controls[i] is TMultiJSPanel) then Continue;
    //only jspanel

    Controls[i].Left := nL;
    Controls[i].Top := nT;

    nL := nL + TMultiJSPanel.PanelRect.Right + cSpace_H_Edge;
    Inc(nIdx);

    if nIdx = nNum then
    begin
      nIdx := 0;
      nL := nFixL;
      nT := nT + TMultiJSPanel.PanelRect.Bottom + cSpace_H_Edge;
    end;
  end;
end;

//Desc: �������
procedure TfFormJS_M.FormShow(Sender: TObject);
begin
  if not FLoadPanels then
  try
    ShowWaitForm(Application.MainForm, '��ʼ��װ����');
    FPerWeight := GetWeightPerPackage;
    LoadTunnelList;

    FLoadPanels := True;

  finally
    CloseWaitForm;
  end;
end;

//Desc: ���Ʊ���
procedure TfFormJS_M.FormPaint(Sender: TObject);
var nX,nY: integer;
begin
  if Assigned(FBGImage) and (FBGImage.Width > 0) then
  begin
    nX := -Random(FBGImage.Width);
    while nX < Width do
    begin
      nY := -Random(FBGImage.Height);

      while nY < Height do
      begin
        Canvas.Draw(nX, nY, FBGImage);
        Inc(nY, FBGImage.Height);
      end;

      Inc(nX, FBGImage.Width);
    end;
  end;
end;

//------------------------------------------------------------------------------
//Desc: �յ�����
procedure TfFormJS_M.OnData(nPort: string; nData: TMultiJSTunnel);
var nIdx: Integer;
begin
  for nIdx:=ControlCount - 1 downto 0 do
   if Controls[nIdx] is TMultiJSPanel then
    with (Controls[nIdx] as TMultiJSPanel) do
    begin
      if CompareStr(Tunnel.FComm, nPort) <> 0 then Continue;
      if Tunnel.FTunnel = nData.FTunnel then JSProgress(nData.FHasDone);
    end;
end;

//Desc: �������
procedure TfFormJS_M.DoOnLoad(Sender: TObject; var nDone: Boolean);
var nStr: string;
    nIdx: Integer;
    nData: TMultiJSPanelData;
begin
  nDone := ShowZTTruckForm(nData, Self);
  if nDone then
  begin
    for nIdx:=ControlCount - 1 downto 0 do
     if Controls[nIdx] is TMultiJSPanel then
      with Controls[nIdx] as TMultiJSPanel do
       if nData.FRecordID = UIData.FRecordID then
       begin
         if Self.Controls[nIdx] = Sender then Exit;
         //self is ignor

         nStr := '����[ %s ]����[ %s ],Ҫ������?';
         nStr := Format(nStr, [UIData.FTruckNo, Tunnel.FPanelName]); 

         if not QueryDlg(nStr, sAsk, Handle) then
         begin
           nDone := (Sender as TMultiJSPanel).UIData.FRecordID <> '';
           Exit;
         end;
       end;
    //forbid multi load

    (Sender as TMultiJSPanel).SetData(nData);
  end;
end;

//Desc: ��ʼ����
procedure TfFormJS_M.DoOnStart(Sender: TObject; var nDone: Boolean);
var nStr: string;
begin
  with Sender as TMultiJSPanel do
  begin
    nDone := FJSer.SetTunnelData(Tunnel.FComm, Tunnel.FTunnel, Tunnel.FDelay,
             UIData.FTruckNo, UIData.FHaveDai, nStr);
    if nStr <> '' then ShowMsg(nStr, sHint);
  end;
end;

//Desc: ֹͣ����
procedure TfFormJS_M.DoOnStop(Sender: TObject; var nDone: Boolean);
var nStr: string;
begin
  with Sender as TMultiJSPanel do
  begin
    nDone := FJSer.StopTunnel(Tunnel.FComm, Tunnel.FTunnel, nStr);
    if nStr <> '' then ShowMsg(nStr, sHint);
  end;
end;

//Desc: װ�����
procedure TfFormJS_M.DoOnDone(Sender: TObject; var nDone: Boolean);
var nStr: string;
begin
  with Sender as TMultiJSPanel do
  try
    nStr := 'Update $TB Set L_DaiShu=$DS,L_BC=$BC,L_ZTLine=''$ZT'',' +
            'L_HasDone=''$Yes'',L_OKTime=''$Now'' Where L_ID=$ID';
    nStr := MacroValue(nStr, [MI('$TB', sTable_JSLog), MI('$Yes', sFlag_Yes),
            MI('$ZT', Tunnel.FPanelName), MI('$DS', IntToStr(UIData.FTotalDS)),
            MI('$BC', IntToStr(UIData.FTotalBC)), MI('$ID', UIData.FRecordID),
            MI('$Now', DateTime2Str(Now))]);
    FDM.ExecuteSQL(nStr);
  except
    //ignor any error
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormJS_M, TfFormJS_M.FormID);
end.
