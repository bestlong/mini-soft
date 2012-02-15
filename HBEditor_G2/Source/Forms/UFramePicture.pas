{*******************************************************************************
  ����: dmzn 2009-2-9
  ����: ͼ�ı༭��
*******************************************************************************}
unit UFramePicture;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  UMovedItems, UFrameBase, ULibFun, GIFImage, StdCtrls, ImgList, ComCtrls,
  Dialogs, ToolWin, ExtCtrls;

type
  TfFramePicture = class(TfFrameBase)
    Group2: TGroupBox;
    ToolBar1: TToolBar;
    BtnText: TToolButton;
    BtnTable: TToolButton;
    BtnOpen: TToolButton;
    ImageList1: TImageList;
    BtnDel: TToolButton;
    BtnDown: TToolButton;
    BtnUP: TToolButton;
    ListItems: TListBox;
    Label1: TLabel;
    OpenDialog1: TOpenDialog;
    Group3: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    EditEnter: TComboBox;
    EditExit: TComboBox;
    EditESpeed: TEdit;
    EditESeepd2: TEdit;
    EditKeep: TEdit;
    Check1: TCheckBox;
    Image1: TImage;
    Label9: TLabel;
    Label10: TLabel;
    procedure BtnOpenClick(Sender: TObject);
    procedure BtnTextClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnDownClick(Sender: TObject);
    procedure BtnUPClick(Sender: TObject);
    procedure ListItemsDblClick(Sender: TObject);
    procedure ListItemsClick(Sender: TObject);
    procedure EditEnterChange(Sender: TObject);
    procedure EditESpeedChange(Sender: TObject);
    procedure Check1Click(Sender: TObject);
    procedure Group3MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  protected
    { Private declarations }
    FPictureItem: TPictureMovedItem;
    {*���༭����*}
    procedure UpdateWindow; override;
    {*���´���*}
    procedure DoCreate; override;
    procedure DoDestroy; override;
    {*���ද��*}
    procedure DoItemResized(nNewW,nNewH: integer; nIsApplyed: Boolean); override;
    {*��С����*}
    procedure OnItemDBClick(Sender: TObject);
    {���˫��}
    procedure SetAreaEnable(const nEnable: Boolean);
    {*��Ч����*}
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}
uses
  UFormTextEditor, USysConst, UMgrLang;

//Desc: ����nType���͵Ķ�������
function MakeItemName(const nList: TListBox; const nType:TPictureDataType): string;
var nP: PPictureData;
    nPrefix: string;
    nIdx,nNum: integer;
begin
  nNum := 0;
  gMultiLangManager.SectionID := sMLFrame;

  if nType = ptText then nPrefix := ML('�ı�_%d') else
  if nType = ptPic then nPrefix := ML('ͼƬ_%d');

  for nIdx:=0 to nList.Items.Count - 1 do
  begin
    nP := Pointer(nList.Items.Objects[nIdx]);
    if nP.FType = nType then
    begin
      nList.Items[nIdx] := Format(nPrefix, [nNum]);
      Inc(nNum);
    end;
  end;

  Result := Format(nPrefix, [nNum]);
end;

//Desc: ��nP��ָ����������nItem��
procedure LoadItemData(const nP: PPictureData; const nItem: TPictureMovedItem);
var //nBmp: TBitmap;
    nPic: TPicture;
    //nGif: TGIFImage;
    nData: TDynamicBitmapArray;
begin
  if Assigned(nP) then
       nItem.NowData := nP
  else Exit;

  if not FileExists(nP.FFile) then
  begin
    ShowMsg(ML('����������Ч', sMLFrame), sHint); Exit;
  end;

  nPic := TPicture.Create;
  try
    if nP.FType = ptText then
    begin
      nItem.Stretch := False;
      if LoadFileToBitmap(nP.FFile, nData, nItem.Width, nItem.Height,
                                    True, nP.FSingleLine) then
      begin
        nPic.Bitmap.Assign(nData[0]);
        nData[0].Free;
      end;
    end else

    if nP.FType = ptPic then
    begin
      nItem.Stretch := True;
      nPic.LoadFromFile(nP.FFile);
      {
      if nPic.Graphic is TGIFImage then
      begin
        nGif := TGIFImage(nPic.Graphic);
        if nGif.Images.Count > 0 then
        begin
          nBmp := TBitmap.Create;
          nBmp.Assign(nGif.Images[0].Bitmap);

          nPic.Graphic := nBmp;
          nBmp.Free;
        end;
      end;
      }
    end;

    nItem.Image := nPic;
    nItem.Invalidate;
  except
    //ignor any error
  end;
  nPic.Free;
end;

//Desc: ��ȡnBox��ѡ�е���Ŀ����
function GetSelectedItemData(const nBox: TListBox): Pointer;
begin
  if nBox.ItemIndex < 0 then
       Result := nil
  else Result := nBox.Items.Objects[nBox.ItemIndex];
end;

//------------------------------------------------------------------------------
procedure TfFramePicture.DoCreate;
var i: Integer;
begin
  EditEnter.Clear;
  for i:=Low(cEnterMode) to High(cEnterMode) do
    EditEnter.Items.Add(ML(cEnterMode[i].FText));
  //xxxxx

  EditExit.Clear;
  for i:=Low(cExitMode) to High(cExitMode) do
    EditExit.Items.Add(ML(cExitMode[i].FText));
  //xxxxx
end;

//Desc: �ͷ���Դ
procedure TfFramePicture.DoDestroy;
begin
  inherited;
end;

//Desc: ���´�����Ϣ
procedure TfFramePicture.UpdateWindow;
var i,nCount: Integer;
begin
  inherited;
  FMovedItem.OnDblClick := OnItemDBClick;
  FPictureItem := TPictureMovedItem(FMovedItem);

  ListItems.Clear;
  nCount := FPictureItem.DataList.Count - 1;

  for i:=0 to nCount do
    ListItems.Items.AddObject('', FPictureItem.DataList[i]);
  MakeItemName(ListItems, ptText);
  MakeItemName(ListItems, ptPic); 
end;

procedure TfFramePicture.DoItemResized(nNewW,nNewH: integer; nIsApplyed: Boolean);
begin
  inherited;
  if nIsApplyed then
    LoadItemData(FPictureItem.NowData, FPictureItem);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Desc: ����ͼƬ
procedure TfFramePicture.BtnOpenClick(Sender: TObject);
var nP: PPictureData;
    nType: TPictureDataType;
    nFiles: TStrings;
    i,nCount: integer;
begin
  nType := ptText;
  nFiles := TStringList.Create;
  try
    with TOpenDialog.Create(Application) do
    begin
      Title := ML('����ļ�', sMLFrame);
      Filter := 'ͼƬ(*.bmp,*.jpg,*.gif)|*.bmp;*.jpg;*.gif|�ĵ�(*.txt;*.rft)|*.txt;*.rtf';
      Filter := ML(Filter, sMLFrame);

      Options := Options + [ofAllowMultiSelect];
      if Execute then
      begin
        nFiles.AddStrings(Files);
        if FilterIndex = 1 then nType := ptPic else
        if FilterIndex = 2 then nType := ptText;
      end else nFiles.Clear;
      
      Free;
    end;

    nCount := nFiles.Count - 1;
    for i:=0 to nCount do
     if FPictureItem.FindData(nFiles[i]) < 0 then
     begin
       nP := FPictureItem.DataList[FPictureItem.AddData(nFiles[i], nType)];
       ListItems.Items.AddObject(MakeItemName(ListItems, nType), TObject(nP));
     end;

    if nCount >= 0 then
    begin
      ListItems.ItemIndex := ListItems.Items.Count - 1;
      ListItemsClick(nil);
    end;
  finally
    nFiles.Free;
  end;
end;

//Desc: �ı��༭
procedure TfFramePicture.BtnTextClick(Sender: TObject);
var nStr: string;
    nBool: Boolean;
    nP: PPictureData;
begin
  nBool := False;
  nStr := ShowTextEditor('', nBool);

  nP := FPictureItem.DataList[FPictureItem.AddData(nStr, ptText)];
  nP.FSingleLine := nBool;
  if nBool then nP.FModeEnter := 3;
  
  nStr := MakeItemName(ListItems, ptText);
  ListItems.Items.AddObject(nStr, TObject(nP));
  LoadItemData(nP, FPictureItem);
end;

//Desc: ˫���ؼ�
procedure TfFramePicture.OnItemDBClick(Sender: TObject);
var nIdx: integer;
begin
  if Assigned(FPictureItem.NowData) then
  begin
    for nIdx:=0 to ListItems.Items.Count - 1 do
     if Pointer(ListItems.Items.Objects[nIdx]) = FPictureItem.NowData then
     begin
       ListItems.ItemIndex := nIdx;
       ListItemsDblClick(nil); Exit;
     end;
  end;

  BtnOpenClick(nil);
  //��
end;

//Desc: ɾ����
procedure TfFramePicture.BtnDelClick(Sender: TObject);
var nIdx: integer;
    nP: PPictureData;
begin
  nP := GetSelectedItemData(ListItems);
  if Assigned(nP) then
  begin
    nIdx := ListItems.ItemIndex;
    ListItems.Items.Delete(nIdx);

    if nIdx > 0 then Dec(nIdx);
    ListItems.ItemIndex := nIdx;

    nIdx := FPictureItem.DataList.IndexOf(nP);
    FPictureItem.DeleteData(nIdx);

    if ListItems.ItemIndex < 0 then
    begin
      FPictureItem.NowData := nil;
      FPictureItem.Image.Graphic := nil;
      FPictureItem.Invalidate;
    end else ListItemsClick(nil);
  end;
end;

//Desc: �༭����
procedure TfFramePicture.ListItemsDblClick(Sender: TObject);
var nStr: string;
    nP: PPictureData;
begin
  if ListItems.ItemIndex > -1 then
  begin
    nP := Pointer(ListItems.Items.Objects[ListItems.ItemIndex]);
    if nP.FType = ptText then
    begin
      nP.FFile := ShowTextEditor(nP.FFile, nP.FSingleLine);
      LoadItemData(nP, FPictureItem);
    end else

    if nP.FType = ptPic then
    begin
      with TOpenDialog.Create(Application) do
      begin
        Title := ML('����ͼƬ', sMLFrame);
        Filter := ML('ͼƬ(*.bmp,*.jpg,*.gif)|*.bmp;*.jpg;*.gif');

        if Execute then nStr := FileName else nStr := '';
        Free;
      end;

      if FileExists(nStr) then
      begin
        nP.FFile := nStr;
        LoadItemData(nP, FPictureItem);
        ListItemsClick(nil);
      end;
    end;
  end;
end;

//Desc: ����ѡ������
procedure TfFramePicture.ListItemsClick(Sender: TObject);
var nP: PPictureData;
begin
  SetAreaEnable(False);
  Image1.Visible := False;
  nP := GetSelectedItemData(ListItems);

  if Assigned(nP) then
  begin
    SetAreaEnable(True);
    EditEnter.ItemIndex := nP.FModeEnter;
    EditExit.ItemIndex := nP.FModeExit;
    EditESpeed.Text := IntToStr(nP.FSpeedEnter);
    EditESeepd2.Text := IntToStr(nP.FSpeedExit);
    EditKeep.Text := IntToStr(nP.FKeedTime);
    Check1.Checked := nP.FModeSerial = 1;

    LoadItemData(nP, FPictureItem);
    //load content
    if (nP.FType = ptPic) and FileExists(nP.FFile) then
    begin     
      Image1.Picture.LoadFromFile(nP.FFile);
      Image1.Visible := True;
    end;
  end;
end;

//Desc: ������ģʽ
procedure TfFramePicture.EditEnterChange(Sender: TObject);
var nP: PPictureData;
begin
  nP := GetSelectedItemData(ListItems);
  if Assigned(nP) then
  begin
    if Sender = EditEnter then
      nP.FModeEnter := EditEnter.ItemIndex;
    if Sender = EditExit then
      nP.FModeExit := EditExit.ItemIndex;
  end;
end;

//Desc: ʱ��
procedure TfFramePicture.EditESpeedChange(Sender: TObject);
var nInt: Integer;
    nP: PPictureData;
begin
  nP := GetSelectedItemData(ListItems);
  if not Assigned(nP) then Exit;

  if IsNumber(TEdit(Sender).Text, False) then
       nInt := StrToInt(TEdit(Sender).Text)
  else Exit;

  if ((Sender = EditESpeed) or (Sender = EditESeepd2)) and
     (nInt > 15) then TEdit(Sender).Text := '0';

  if (Sender = EditKeep) and (nInt > 127) then
    TEdit(Sender).Text := '0';
  nInt := StrToInt(TEdit(Sender).Text);

  if Sender = EditESpeed then nP.FSpeedEnter := nInt else
  if Sender = EditESeepd2 then nP.FSpeedExit := nInt else
  if Sender = EditKeep then nP.FKeedTime := nInt;
end;

//Desc: ����ǰ��
procedure TfFramePicture.Check1Click(Sender: TObject);
var nP: PPictureData;
begin
  nP := GetSelectedItemData(ListItems);
  if Assigned(nP) then
  begin
    if Check1.Checked then
         nP.FModeSerial := 1
    else nP.FModeSerial := 0;
  end;
end;

//Desc: ����
procedure TfFramePicture.BtnDownClick(Sender: TObject);
var nStr: string;
    nIdx: integer;
    nP: PPictureData;
begin
  nIdx := ListItems.ItemIndex;
  if (nIdx > -1) and (nIdx < ListItems.Count - 1) then
  begin
    nStr := ListItems.Items[nIdx];
    nP := Pointer(ListItems.Items.Objects[nIdx]);

    ListItems.Items[nIdx] := ListItems.Items[nIdx + 1];
    ListItems.Items.Objects[nIdx] := ListItems.Items.Objects[nIdx + 1];

    ListItems.Items[nIdx + 1] := nStr;
    ListItems.Items.Objects[nIdx + 1] := TObject(nP);
    ListItems.ItemIndex := nIdx + 1;
  end;
end;

//Desc: ����
procedure TfFramePicture.BtnUPClick(Sender: TObject);
var nIdx: integer;
    nStr: string;
    nP: PPictureData;
begin
  nIdx := ListItems.ItemIndex;
  if nIdx > 0 then
  begin
    nStr := ListItems.Items[nIdx];
    nP := Pointer(ListItems.Items.Objects[nIdx]);

    ListItems.Items[nIdx] := ListItems.Items[nIdx - 1];
    ListItems.Items.Objects[nIdx] := ListItems.Items.Objects[nIdx - 1];

    ListItems.Items[nIdx - 1] := nStr;
    ListItems.Items.Objects[nIdx - 1] := TObject(nP);
    ListItems.ItemIndex := nIdx - 1;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ����/������Ч��
procedure TfFramePicture.SetAreaEnable(const nEnable: Boolean);
var i,nCount: Integer;
begin
  if Group3.Enabled = nEnable then
       Exit
  else Group3.Enabled := nEnable;
  nCount := Group3.ControlCount - 1;
  
  for i:=0 to nCount do
  begin
    if Group3.Controls[i] is TComboBox then
    with Group3.Controls[i] as TComboBox do
    begin
      Enabled := nEnable;
      if not nEnable then
      begin
        ItemIndex := -1;
        Color := clBtnFace;
      end else Color := clWindow;
    end;

    if Group3.Controls[i] is TEdit then
    with Group3.Controls[i] as TEdit do
    begin
      Enabled := nEnable;
      if not nEnable then
      begin
        Text := '';
        Color := clBtnFace;
      end else Color := clWindow;
    end;
  end;
end;

procedure TfFramePicture.Group3MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SetAreaEnable(ListItems.ItemIndex > -1);
end;

end.
