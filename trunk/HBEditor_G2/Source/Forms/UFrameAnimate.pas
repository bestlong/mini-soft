{*******************************************************************************
  ����: dmzn 2009-11-28
  ����: �����༭��
*******************************************************************************}
unit UFrameAnimate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  UMovedItems, UFrameBase, ULibFun, GIFImage, StdCtrls, ImgList, ComCtrls,
  Dialogs, ToolWin, ExtCtrls, Buttons;

type
  TfFrameAnimate = class(TfFrameBase)
    Group2: TGroupBox;
    ListInfo: TListBox;
    OpenDialog1: TOpenDialog;
    BtnOpen: TSpeedButton;
    Image1: TImage;
    Bevel1: TBevel;
    EditSpeed: TComboBox;
    Label1: TLabel;
    Check1: TCheckBox;
    procedure BtnOpenClick(Sender: TObject);
    procedure EditSpeedChange(Sender: TObject);
    procedure Check1Click(Sender: TObject);
  protected
    { Private declarations }
    FAnimateItem: TAnimateMovedItem;
    {*���༭����*}
    procedure UpdateWindow; override;
    {*���´���*}
    procedure DoCreate; override;
    procedure DoDestroy; override;
    {*���ද��*}
    procedure OnItemDBClick(Sender: TObject);
    {*���˫��*}
    procedure LoadAnimateInfo;
    {*������Ϣ*}
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}
uses
  USysConst, UMgrLang;

//------------------------------------------------------------------------------
procedure TfFrameAnimate.DoCreate;
begin
  inherited;
end;

//Desc: �ͷ���Դ
procedure TfFrameAnimate.DoDestroy;
begin
  inherited;
end;

//Desc: ���´�����Ϣ
procedure TfFrameAnimate.UpdateWindow;
var nIdx: integer;
begin
  inherited;
  FMovedItem.OnDblClick := OnItemDBClick;
  FAnimateItem := TAnimateMovedItem(FMovedItem);
  Check1.Checked := FAnimateItem.Reverse;

  EditSpeed.Clear;
  for nIdx:=1 to 16 do EditSpeed.Items.Add(IntToStr(nIdx));    
  LoadAnimateInfo;
end;

//------------------------------------------------------------------------------
//Desc: ����ͼƬ
procedure TfFrameAnimate.BtnOpenClick(Sender: TObject);
var nStr: string;
begin
  with TOpenDialog.Create(Application) do
  begin
    Title := ML('ѡ�񶯻�', sMLFrame);
    Filter := ML('����ͼƬ(*.gif)|*.gif');

    if Execute then nStr := FileName else nStr := '';
    Free;
  end;

  if FileExists(nStr) then
  begin
    FAnimateItem.ImageFile := nStr;
    LoadAnimateInfo;
    FAnimateItem.Invalidate;
  end;
end;

//Desc: ͼƬ��Ϣ
procedure TfFrameAnimate.LoadAnimateInfo;
begin
  if not EditSpeed.Focused then
    Image1.Visible := False;
  ListInfo.Clear;

  with FAnimateItem,ListInfo do
  if PicNum > 0 then
  begin
    gMultiLangManager.SectionID := sMLFrame;
    Items.Add(Format(ML('������Դ: %s'), [ImageFile]));
    Items.Add(Format(ML('��Ч֡��: %d'), [PicNum]));
    Items.Add(Format(ML('�����ٶ�: %d֡/��'), [Speed]));
    Items.Add(Format(ML('ԭʼ��С: %d x %d'), [ImageWH.Right, ImageWH.Bottom]));

    EditSpeed.ItemIndex := EditSpeed.Items.IndexOf(IntToStr(Speed));
    Image1.Picture.LoadFromFile(ImageFile);
    Image1.Visible := True;
  end;
end;

procedure TfFrameAnimate.EditSpeedChange(Sender: TObject);
begin
  if EditSpeed.ItemIndex > -1 then
  begin
    FAnimateItem.Speed := StrToInt(EditSpeed.Text);
    LoadAnimateInfo;
  end;
end;

procedure TfFrameAnimate.OnItemDBClick(Sender: TObject);
begin
  BtnOpenClick(nil);
end;

procedure TfFrameAnimate.Check1Click(Sender: TObject);
begin
  FAnimateItem.Reverse := Check1.Checked;
end;

end.
