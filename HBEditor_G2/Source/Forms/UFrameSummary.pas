{*******************************************************************************
  ����: dmzn 2009-2-9
  ����: ��ʾ��ժҪ��Ϣ
*******************************************************************************}
unit UFrameSummary;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  USysConst, IniFiles, UMgrLang, Grids, StdCtrls;

type
  TfFrameSummary = class(TFrame)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit4: TEdit;
    Label3: TLabel;
    Edit3: TEdit;
    Edit2: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Edit5: TEdit;
    Label6: TLabel;
    Edit6: TEdit;
    ListBox1: TListBox;
    procedure ListBox1Exit(Sender: TObject);
  private
    { Private declarations }
    procedure LoadScreen(const nScreen: PScreenItem);
    //��������Ϣ
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

procedure ShowScreenSummary(const nScreen: PScreenItem; const nParent: TWinControl);
//��ں���

implementation

{$R *.dfm}

//Desc: ��ʾ��ĻժҪ��Ϣ
procedure ShowScreenSummary(const nScreen: PScreenItem; const nParent: TWinControl);
var nIdx: integer;
    nFrame: TfFrameSummary;
begin
  nFrame := nil;
  for nIdx:=nParent.ControlCount - 1 downto 0 do
   if nParent.Controls[nIdx] is TfFrameSummary then
   begin
     nFrame := nParent.Controls[nIdx] as TfFrameSummary; Break;
   end;

  if not Assigned(nFrame) then
  begin
    nFrame := TfFrameSummary.Create(nParent);
    gMultiLangManager.SectionID := 'FrameItem';
    gMultiLangManager.TranslateAllCtrl(nFrame);
  end; //new frame

  with nFrame do
  begin
    Parent := nParent;
    Align := alClient;

    BringToFront;
    LoadScreen(nScreen);
  end;
end;

constructor TfFrameSummary.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TfFrameSummary.Destroy;
begin
  inherited;
end;

//------------------------------------------------------------------------------
procedure TfFrameSummary.ListBox1Exit(Sender: TObject);
begin
  ListBox1.ItemIndex := - 1;
end;

//Desc: ����nScreen����Ϣ
procedure TfFrameSummary.LoadScreen(const nScreen: PScreenItem);
var nStr: string;
    nIdx: integer;
begin
  Edit1.Text := nScreen.FName;
  case nScreen.FType of
    stSingle : Edit2.Text := '��ɫ';
    stDouble : Edit2.Text := '˫ɫ';
    stFull   : Edit2.Text := 'ȫ��' else Edit2.Text := 'δ֪';
  end;

  Edit2.Text := ML(Edit2.Text, sMLFrame);
  Edit3.Text := Format('%d x %d', [nScreen.FLenY, nScreen.FLenX]);
  nIdx := CardItemIndex(nScreen.FCard);

  if nIdx < 0 then
       Edit4.Text := 'δ֪'
  else Edit4.Text := cCardList[nIdx].FName;

  Edit2.Text := ML(Edit2.Text);
  Edit5.Text := nScreen.FPort;
  Edit6.Text := IntToStr(nScreen.FBote);

  ListBox1.Clear;
  for nIdx:=Low(nScreen.FDevice) to High(nScreen.FDevice) do
  with nScreen.FDevice[nIdx] do
  begin
    nStr := Format(ML('�豸��:%-5d ����:%-10s'),[FID, FName]);
    ListBox1.Items.Add(nStr);
  end;
end;

end.
