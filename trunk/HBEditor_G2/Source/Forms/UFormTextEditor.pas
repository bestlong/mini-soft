unit UFormTextEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, USysConst, ULibFun, RichEdit, UMgrLang, ImgList, StdCtrls,
  URichEdit, ComCtrls, ToolWin, ExtCtrls, Menus;

type
  TfFormTextEditor = class(TForm)
    ToolBar1: TToolBar;
    BtnOpen: TToolButton;
    BtnSave: TToolButton;
    BtnBold: TToolButton;
    BtnItalic: TToolButton;
    ImageList1: TImageList;
    BtnUnder: TToolButton;
    BtnAL: TToolButton;
    BtnAM: TToolButton;
    BtnAR: TToolButton;
    Label1: TLabel;
    ListColor: TComboBox;
    Label2: TLabel;
    ListSize: TComboBox;
    Label3: TLabel;
    ListFont: TComboBox;
    ToolButton9: TToolButton;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Label4: TLabel;
    EditSpace: TEdit;
    UpDown1: TUpDown;
    Label5: TLabel;
    Rich1: TUHISRichEdit;
    PMenu1: TPopupMenu;
    mAutoH: TMenuItem;
    mSingle: TMenuItem;
    procedure BtnOpenClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ListColorDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListFontChange(Sender: TObject);
    procedure EditSpaceKeyPress(Sender: TObject; var Key: Char);
    procedure Rich1SelectionChange(Sender: TObject);
    procedure BtnBoldClick(Sender: TObject);
    procedure BtnALClick(Sender: TObject);
    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
    procedure mAutoHClick(Sender: TObject);
  private
    { Private declarations }
    FFile: string;
    FColorDefine: TBitmap;
  public
    { Public declarations }
  end;

function LoadFileToBitmap(const nFile: string; var nData: TDynamicBitmapArray;
 const nW,nH: Integer; const nOnlyFirst,nSingle: Boolean): Boolean;
function ShowTextEditor(const nFile: string; var nSingle: Boolean): string;
//��ں���

implementation

{$R *.dfm}

var
  gRich: TUHISRichEdit;

//------------------------------------------------------------------------------
function MakeTitle(const nFile: string): string;
begin
  Result := ML('�ı��༭ ', sMLTxtEdt) + nFile;
end;

function MakeFileName: string;
var nIdx: integer;
begin
  nIdx := 0;
  while True do
  begin
    Result := Format(gPath + sDocument + ML('�ı�0_%d.rtf', sMLTxtEdt), [nIdx]);
    if FileExists(Result) then Inc(nIdx) else Break;
  end;
end;

//Desc: ��ʾ��nFile�ı༭��
function ShowTextEditor(const nFile: string; var nSingle: Boolean): string;
begin
  with TfFormTextEditor.Create(Application) do
  try
    if FileExists(nFile) then
         FFile := nFile
    else FFile := MakeFileName;

    Caption := MakeTitle(FFile);
    mSingle.Checked := nSingle;
    if FileExists(FFile) then Rich1.Lines.LoadFromFile(FFile);

    ShowModal;
    Result := FFile;
    
    nSingle := mSingle.Checked;
    Rich1.Lines.SaveToFile(FFile);
  finally
    Free;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2009-11-26
//Parm: ���ı�;���ݻ���;�Ƿ��һҳ
//Desc: ��nRich���ݻ��Ƶ�������,����nData����
function RichEditPrint(const nRich: TUHISRichEdit; var nData: TDynamicBitmapArray;
  const nOnlyFirst: Boolean = True): Boolean;
var nLen: Integer;
    nInch: Integer;
    nFmt: TFormatRange;
    nTextLength: Integer;
    nTextPrinted,nLastPrinted: Integer;
begin
  SetLength(nData, 0);
  nInch := Screen.PixelsPerInch;
  nTextLength := SendMessage (nRich.Handle, WM_GETTEXTLENGTH, 0, 0 );

  nTextPrinted := 0;
  nLastPrinted := 0;
  while nTextPrinted < nTextLength do
  begin
    nLen := Length(nData);
    SetLength(nData, nLen + 1);

    nData[nLen] := TBitmap.Create;
    nData[nLen].Width := nRich.ClientWidth ;
    nData[nLen].Height := nRich.ClientHeight;

    nData[nLen].Canvas.Brush.Color := nRich.Color;
    nData[nLen].Canvas.FillRect(nRich.ClientRect);
    //��䱳��ɫ

    SetMapMode(nData[nLen].Canvas.Handle, MM_TEXT );
    SetBkMode(nData[nLen].Canvas.Handle, TRANSPARENT);
    //����ģʽ
    
    with nFmt do
    begin
      hdc:= nData[nLen].Canvas.Handle;
      hdcTarget:= hdc;

      rc := Rect(0, 0, nData[nLen].Width * 1440 div nInch,
                       nData[nLen].Height * 1440 div nInch);
      rcPage:= rc;

      chrg.cpMin := nTextPrinted;
      chrg.cpMax := -1;
    end;

    nTextPrinted := SendMessage(nRich.Handle, EM_FORMATRANGE, 1, Integer(@nFmt));
    Application.ProcessMessages;

    if nTextPrinted <= nLastPrinted then
    begin
      nLen := Length(nData) - 1;
      nData[nLen].Free;
      SetLength(nData, nLen); Break;
    end; //�մ�ӡ

    nLastPrinted := nTextPrinted;
    if nOnlyFirst then Break;
    //���ֻ��ӡ��ҳ,���˳�
  end;

  SendMessage(nRich.Handle, EM_FORMATRANGE, 0, 0);
  // Tell the control to release cached information.
  Application.ProcessMessages;
  Result := Length(nData) > 0;
end;

//Date: 2010-6-16
//Parm: ���ı�;���и�;����;ֻȡ��ҳ
//Desc: ��nRich�������Ծ���ģʽ���д�ӡ
function RichEditPrintSingle(const nRich: TUHISRichEdit; var nData: TDynamicBitmapArray;
  const nOnlyFirst: Boolean = True): Boolean;
var nStr: string;
    nBmp: TBitmap;
    nL,nT,nVal: Integer;

  //Desc: �������嵽����
  procedure CopyFont(nCanvas: TCanvas; nFont: TRxTextAttributes);
  begin
    with nCanvas do
    begin
      Font.Name := nFont.Name;
      Font.Size := nFont.Size;
      Font.Color := nFont.Color;
      Font.Style := nFont.Style;
    end;
  end;

  //Desc: ��nLongBmp���ΪÿĻ����
  procedure SplitBmp(const nLongBmp: TBitmap; const nMaxW: Integer);
  var nLx,nLen: Integer;
  begin
    nLx := 0;
    while nLx < nMaxW do
    begin
      nLen := Length(nData);
      SetLength(nData, nLen + 1);

      nData[nLen] := TBitmap.Create;
      with nData[nLen] do
      begin
        Width := nRich.ClientWidth;
        Height := nRich.ClientHeight;

        Canvas.CopyRect(Rect(0, 0, Width, Height),
                        nLongBmp.Canvas, Rect(nLx, 0, nLx + Width, Height));
        Inc(nLx, Width);
      end;
    end;
  end;

begin
  nL := 0;
  nBmp := nil;

  SetLength(nData, 0);
  nRich.SelStart := 0;

  while True do
  try
    nRich.SelLength := 1;
    if nRich.SelText = '' then Break;

    nStr := nRich.SelText;
    if (Length(nStr) = 1) and (Ord(nStr[1]) < 48) then
    begin
      nRich.SelStart := nRich.SelStart + 1; Continue;
    end;

    if nOnlyFirst then
    begin
      if Length(nData) < 1 then
      begin
        SetLength(nData, 1);
        nData[0] := TBitmap.Create;
        nData[0].Width := nRich.ClientWidth;
        nData[0].Height := nRich.ClientHeight;

        nData[0].Canvas.Brush.Color := nRich.Color;
        nData[0].Canvas.FillRect(nRich.ClientRect);
      end;

      with nData[0],nRich do
      begin
        CopyFont(Canvas, SelAttributes);
        nT := Canvas.TextHeight(nStr);
        nT := Trunc((ClientHeight - nT) / 2);

        SetBkMode(Canvas.Handle, Windows.TRANSPARENT);
        Canvas.TextOut(nL, nT, nStr);

        nL := nL + Canvas.TextWidth(nStr);
        if nL < ClientWidth then
        begin
          nRich.SelStart := nRich.SelStart + 1;
          Continue;
        end else Break;
      end;
    end; //ֻɨ��ʼһ��

    if not Assigned(nBmp) then
    begin
      nBmp := TBitmap.Create;
      nBmp.Height := nRich.ClientHeight;
      nBmp.Width := Trunc(1024 * 5 / nRich.ClientWidth) * nRich.ClientWidth;
    end; //�½�������

    if nL = 0 then
    begin
      nBmp.Canvas.Brush.Color := nRich.Color;
      nBmp.Canvas.FillRect(Rect(0, 0, nBmp.Width, nBmp.Height));
    end; //����

    CopyFont(nBmp.Canvas, nRich.SelAttributes);
    nVal := nBmp.Canvas.TextWidth(nStr);

    if nL + nVal <= nBmp.Width then
    begin
      nT := nBmp.Canvas.TextHeight(nStr);
      nT := Trunc((nBmp.Height - nT) / 2);

      SetBkMode(nBmp.Canvas.Handle, Windows.TRANSPARENT);
      nBmp.Canvas.TextOut(nL, nT, nStr);

      nRich.SelStart := nRich.SelStart + 1;
      nL := nL + nVal;
      Continue;
    end; //δ��һҳ

    nVal := nL;
    nL := 0;
    SplitBmp(nBmp, nVal);
  except 
    if Assigned(nBmp) then
      FreeAndNil(nBmp);
    nL := 0;
  end;

  if Assigned(nBmp) then
  begin
    if nL > 0 then
      SplitBmp(nBmp, nL);
    nBmp.Free;
  end;

  Result := Length(nData) > 0;
end;

//Desc: ��ʼ������
procedure InitProperty(const nRich: TUHISRichEdit);
begin
  nRich.Color := clBlack;
end;

//Date: 2009-11-24
//Parm: �ļ�·��;ͼƬ����;ͼƬ���
//Desc: ��nFile��������nW.nH��Сɨ�赽nData��
function LoadFileToBitmap(const nFile: string; var nData: TDynamicBitmapArray;
 const nW,nH: Integer; const nOnlyFirst,nSingle: Boolean): Boolean;
begin
  try
    if not Assigned(gRich) then
    begin
      gRich := TUHISRichEdit.Create(Application);
      gRich.Visible := False;
      gRich.SelectionBar := False;
      
      gRich.ScrollBars := TScrollStyle(ssNone);
      gRich.Parent := Application.MainForm;
    end;

    InitProperty(gRich);
    gRich.ClientWidth := nW;
    gRich.ClientHeight := nH;
    //��������Ա��Զ�����

    gRich.Lines.LoadFromFile(nFile);
    Application.ProcessMessages;

    if nSingle then
         Result := RichEditPrintSingle(gRich, nData, nOnlyFirst)
    else Result := RichEditPrint(gRich, nData, nOnlyFirst);
  except
    Result := False;
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormTextEditor.FormCreate(Sender: TObject);
var i: integer;
begin
  FillColorCombox(ListColor);
  if gIsFullColor then ListColor.Items.AddObject('', TObject(0));
  ListFont.Items.Assign(Screen.Fonts);

  ListSize.Clear;
  for i:=1 to 500 do ListSize.Items.Add(IntToStr(i));

  ListFont.ItemIndex := ListFont.Items.IndexOf(Rich1.Font.Name);
  ListSize.ItemIndex := ListSize.Items.IndexOf(IntToStr(Rich1.Font.Size));
  SetColorComboxIndex(ListColor, Rich1.Font.Color);

  Rich1.Paragraph.LineSpacingRule := lsSpecifiedOrMore;
  UpDown1.Position := 11;
  Rich1.Paragraph.LineSpacing := UpDown1.Position;
  InitProperty(Rich1);

  EditSpace.Text := IntToStr(Rich1.Paragraph.LineSpacing);
  LoadFormConfig(Self);
end;

procedure TfFormTextEditor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveFormConfig(Self);
  if Assigned(FColorDefine) then FColorDefine.Free;
end;

//------------------------------------------------------------------------------ 
procedure TfFormTextEditor.ListColorDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var nInt: Integer;
    nColor: TColor;
    nCombox: TComboBox;
begin
  if Control is TComboBox then
  begin
    nCombox := TComboBox(Control);
    nColor := Integer(nCombox.Items.Objects[Index]);

    with nCombox do
    begin
      if nColor > 0 then
      begin
        Canvas.Brush.Color := nColor;
        Canvas.FillRect(Rect);
      end else
      begin
        if not Assigned(FColorDefine) then
        begin
          FColorDefine := TBitmap.Create;
          FColorDefine.Width := Rect.Right - Rect.Left;
          FColorDefine.Height := Rect.Bottom - Rect.Top;

          for nInt:=0 to FColorDefine.Width do
          begin
            nColor := RGB(Random(255), Random(255), Random(255));
            FColorDefine.Canvas.MoveTo(nInt, 0);
            FColorDefine.Canvas.Pen.Color := nColor;
            FColorDefine.Canvas.LineTo(nInt, FColorDefine.Height);
          end;
        end;

        Canvas.StretchDraw(Rect, FColorDefine);
      end;
    end;
  end;
end;

//Desc: ��
procedure TfFormTextEditor.BtnOpenClick(Sender: TObject);
var nStr: string;
begin
  with TOpenDialog.Create(Application) do
  begin
    Title := ML('��', sMLTxtEdt);
    Filter := ML('�ĵ�(*.txt;*.rft)|*.txt;*.rtf|�����ļ�(*.*)|*.*');

    FileName := FFile;
    if Execute then nStr := FileName else nStr := '';
    Free;
  end;

  if FileExists(nStr) then
  begin
    Rich1.Lines.LoadFromFile(nStr);
    Caption := MakeTitle(nStr);
    FFile := nStr;
  end;
end;

//Desc: ����
procedure TfFormTextEditor.BtnSaveClick(Sender: TObject);
var nStr: string;
begin
  with TSaveDialog.Create(Application) do
  begin
    Title := ML('����', sMLTxtEdt);
    DefaultExt := '.rtf';
    Filter := ML('�ĵ�(*.rft)|*.rtf|�����ļ�(*.*)|*.*');

    FileName := FFile;
    Options := Options + [ofOverwritePrompt];
    if Execute then nStr := FileName else nStr := '';
    Free;
  end;

  if nStr <> '' then
  begin
    Rich1.Lines.SaveToFile(nStr);
    Caption := MakeTitle(nStr);
    FFile := nStr;
  end;
end;

//Desc: �����о�
procedure TfFormTextEditor.UpDown1Click(Sender: TObject;
  Button: TUDBtnType);
begin
  EditSpace.Text := IntToStr(UpDown1.Position);
  Rich1.Paragraph.LineSpacing := UpDown1.Position;
end;

procedure TfFormTextEditor.ListFontChange(Sender: TObject);
var nColor: TColor;
    nCombox: TComboBox;
begin
  nCombox := TComboBox(Sender);
  if nCombox = ListFont then
  begin
    Rich1.SelAttributes.Name := nCombox.Text;
  end else

  if nCombox = ListSize then
  begin
    if IsNumber(nCombox.Text, False) then
      Rich1.SelAttributes.Size := StrToInt(nCombox.Text);
  end else

  if (nCombox = ListColor) and (ListColor.ItemIndex > -1) then
  begin
    nColor := Integer(ListColor.Items.Objects[ListColor.ItemIndex]);
    if nColor < 1 then
    begin
      with TColorDialog.Create(Application) do
      begin
        Color := Rich1.SelAttributes.Color;
        Options := Options + [cdFullOpen];
        
        if Execute then nColor := Color else nColor := -1;
        Free;
      end;

      if nColor < 0 then Exit;
    end;

    Rich1.SelAttributes.Color := nColor;
  end;
end;

procedure TfFormTextEditor.EditSpaceKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    if IsNumber(EditSpace.Text, False) then
    begin
      UpDown1.Position := StrToInt(EditSpace.Text);
      EditSpace.Text := IntToStr(UpDown1.Position);
      Rich1.Paragraph.LineSpacing := UpDown1.Position;
    end;
    Key := #0;
  end else

  if not (Key in [Char(VK_BACK), '0'..'9']) then
  begin
    Key := #0;
  end;
end;

//Desc: �ı�״̬
procedure TfFormTextEditor.Rich1SelectionChange(Sender: TObject);
begin
  with Rich1.SelAttributes do
  begin
    ListFont.ItemIndex := ListFont.Items.IndexOf(Name);
    ListSize.ItemIndex := ListSize.Items.IndexOf(IntToStr(Size));

    SetColorComboxIndex(ListColor, Color);
    if (ListColor.ItemIndex < 0) and gIsFullColor then
      SetColorComboxIndex(ListColor, 0);
    //xxxxx

    BtnBold.Down := fsBold in Style;
    BtnItalic.Down := fsItalic in Style;
    BtnUnder.Down := fsUnderline in Style;
  end;

  mAutoH.Checked := Rich1.Paragraph.LineSpacingRule <> lsSpecified;
  UpDown1.Position := Rich1.Paragraph.LineSpacing;
  EditSpace.Text := IntToStr(UpDown1.Position);
end;

//Desc: ������
procedure TfFormTextEditor.BtnBoldClick(Sender: TObject);
var nButton: TToolButton;
begin
  nButton := TToolButton(Sender);

  with Rich1.SelAttributes do
  begin
    if nButton = BtnBold then
    begin
      if nButton.Down then
           Style := Style + [fsBold]
      else Style := Style - [fsBold];
    end else

    if nButton = BtnItalic then
    begin
      if nButton.Down then
           Style := Style + [fsItalic]
      else Style := Style - [fsItalic];
    end else

    if nButton = BtnUnder then
    begin
      if nButton.Down then
           Style := Style + [fsUnderline]
      else Style := Style - [fsUnderline];
    end;
  end;
end;

//Desc: ����
procedure TfFormTextEditor.BtnALClick(Sender: TObject);
var nButton: TToolButton;
begin
  nButton := TToolButton(Sender);

  if nButton = BtnAL then
  begin
    Rich1.Paragraph.Alignment := paLeftJustify;
  end else

  if nButton = BtnAM then
  begin
    Rich1.Paragraph.Alignment := URichEdit.paCenter;
  end else

  if nButton = BtnAR then
  begin
    Rich1.Paragraph.Alignment := paRightJustify;
  end;
end;

//Desc: �л��и�����
procedure TfFormTextEditor.mAutoHClick(Sender: TObject);
begin
  with TMenuItem(Sender) do
  begin
    Checked := not Checked;
    if Sender <> mAutoH then Exit;

    if Checked then
    begin
      Rich1.Paragraph.LineSpacingRule := lsSpecifiedOrMore;
      UpDown1.Max := 50;
    end else
    begin
      Rich1.Paragraph.LineSpacingRule := lsSpecified;
      UpDown1.Max := 500;
    end;
  end;
end;

end.
