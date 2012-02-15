{*******************************************************************************
  ����: dmzn 2009-2-3
  ����: �����ƶ��Ŀؼ�����
*******************************************************************************}
unit UMovedItems;

interface

uses
  Windows, Classes, Controls, Graphics, SysUtils, ExtCtrls, Jpeg, GIFImage,
  UMovedControl, UMgrLang;

type
  TMovedItemClass = class of TZnMovedControl;
  
  TTextMovedItem = class(TZnMovedControl)
  private
    FText: string;
    {*�ı�����*}
    FLines: TStrings;
    {*��������*}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    {*�����ͷ�*}
    function SplitText: Boolean;
    {����ı�*}
    procedure DoPaint(const nCanvas: TCanvas; const nRect: TRect); override;
    property Lines: TStrings read FLines;
    property Text: string read FText write FText; 
  end;

  TPictureDataType = (ptText, ptPic);
  //�ı�,ͼƬ

  PPictureData = ^TPictureData;
  TPictureData = record
    FFile: string;
    FType: TPictureDataType;
    //��������
    FSingleLine: Boolean;
    //������ʾ
    FModeEnter: Byte;
    FModeExit: Byte;
    //������ģʽ
    FSpeedEnter: Byte;
    FSpeedExit: Byte;
    //�������ٶ�
    FKeedTime: Byte;
    FModeSerial: Byte;
    //ͣ��ʱ��,����ǰ��
  end;

  TPictureMovedItem = class(TZnMovedControl)
  private
    FText: string;
    {*�ı�����*}
    FImage: TPicture;
    {*ͼƬ����*}
    FDataList: TList;
    {*�����б�*}
    FNowData: PPictureData;
    {*�����*}
    FStretch: Boolean;
    {*������ʾ*}
  protected
    procedure SetImage(const nValue: TPicture);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    {*�����ͷ�*}
    procedure DoPaint(const nCanvas: TCanvas; const nRect: TRect); override;
    function AddData(const nFile: string; nType: TPictureDataType): integer;
    function FindData(const nFile: string): Integer;
    procedure DeleteData(const nIdx: Integer);
    {*���ݴ���*}
    property DataList: TList read FDataList;
    property NowData: PPictureData read FNowData write FNowData;
    property Stretch: Boolean read FStretch write FStretch;
    property Text: string read FText write FText;
    property Image: TPicture read FImage write SetImage;
  end;

  TAnimateMovedItem = class(TZnMovedControl)
  private
    FText: string;
    {*�ı�����*}
    FImage: TPicture;
    {*ͼƬ����*}
    FImageFile: string;
    {*ͼƬ�ļ�*}
    FPicNum: Word;
    {*����֡��*}
    FSpeed: Word;
    {*ÿ��֡��*}
    FImageWH: TRect;
    {*������С*}
    FStretch: Boolean;
    {*������ʾ*}
    FReverse: Boolean;
    {*��תɨ��*}
  protected
    procedure SetFile(const nFile: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    {*�����ͷ�*}
    procedure DoPaint(const nCanvas: TCanvas; const nRect: TRect); override;
    {*��������*}
    property PicNum: Word read FPicNum;
    property ImageWH: TRect read FImageWH;
    property Text: string read FText write FText;
    property Speed: Word read FSpeed write FSpeed;
    property Reverse: Boolean read FReverse write FReverse;
    property Stretch: Boolean read FStretch write FStretch;
    property ImageFile: string read FImageFile write SetFile;
  end;

  TTimeItemOption = (toDate, toWeek, toTime);
  TTimeItemOptons = set of TTimeItemOption;
  TTimeTextStyle = (tsSingle, tsMulti);

  TTimeMovedItem = class(TZnMovedControl)
  private
    FTimer: TTimer;
    {*��ʱ��*}
    FOptions: TTimeItemOptons;
    {*��ѡ����*}
    FFixText: string;
    FFixColor: TColor;
    {*�̶�����*}
    FDateText: string;
    FDateColor: TColor;
    {*�������*}
    FWeekText: string;
    FWeekColor: TColor;
    {*�������*}
    FTimeText: string;
    FTimeColor: TColor;
    {*ʱ�����*}
    FTextStyle: TTimeTextStyle;
    {*��ʾ���*}
    FModeChar: Byte;
    FModeLine: Byte;
    FModeDate: Byte;
    FModeWeek: Byte;
    FModeTime: Byte;
    {*��չ����*}
  protected
    procedure DoTimer(Sender: TObject);
    procedure SetModeChar(const nValue: Byte);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    {*�����ͷ�*}
    procedure DoPaint(const nCanvas: TCanvas; const nRect: TRect); override;
    procedure SwitchTimer(const nEnable: Boolean);
    {*��ʱ������*}
    property Options: TTimeItemOptons read FOptions write FOptions;
    property TextStyle: TTimeTextStyle read FTextStyle write FTextStyle;
    property FixText: string read FFixText write FFixText;
    property DateText: string read FDateText write FDateText;
    property WeekText: string read FWeekText write FWeekText;
    property TimeText: string read FTimeText write FTimeText;
    property FixColor: TColor read FFixColor write FFixColor;
    property DateColor: TColor read FDateColor write FDateColor;
    property WeekColor: TColor read FWeekColor write FWeekColor;
    property TimeColor: TColor read FTimeColor write FTimeColor;
    property ModeChar: Byte read FModeChar write SetModeChar;
    property ModeLine: Byte read FModeLine write FModeLine;
    property ModeDate: Byte read FModeDate write FModeDate;
    property ModeWeek: Byte read FModeWeek write FModeWeek;
    property ModeTime: Byte read FModeTime write FModeTime;
    {*��չ����*}
    {*�������*}
  end;

  TClockMovedItem = class(TZnMovedControl)
  private
    FText: string;
    {*�ı�����*}
    FImage: TPicture;
    {*��������*}
    FAutoDot: Boolean;
    FDotPoint: TPoint;
    {*Բ������*}
    FColorHour: TColor;
    FColorMin: TColor;
    FColorSec: TColor;
    {*������ɫ*}
  protected
    procedure Resize;override;
    procedure SetAutoDot(const nValue: Boolean);
    procedure SetImage(const nValue: TPicture);
    procedure PaintZhen(const nCanvas: TCanvas; const nR: integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    {*�����ͷ�*}
    function DefaultDotPoint: TPoint;
    {*Ĭ��ԭ��*}
    procedure DoPaint(const nCanvas: TCanvas; const nRect: TRect); override;
    {*����ͼ��*}
    property Image: TPicture read FImage;
    property Text: string read FText write FText;
    property AutoDot: Boolean read FAutoDot write SetAutoDot;
    property DotPoint: TPoint read FDotPoint write FDotPoint;
    property ColorHour: TColor read FColorHour write FColorHour;
    property ColorMin: TColor read FColorMin write FColorMin;
    property ColorSec: TColor read FColorSec write FColorSec; 
  end;

implementation

constructor TTextMovedItem.Create(AOwner: TComponent);
begin
  inherited;
  Width := 48;
  Height := 23;

  FText := '�ı�����';
  FLines := TStringList.Create;
end;

destructor TTextMovedItem.Destroy;
begin
  FLines.Free;
  inherited;
end;

procedure TTextMovedItem.DoPaint(const nCanvas: TCanvas; const nRect: TRect);
var nMid: integer;
begin
  inherited;
  nCanvas.Font.Assign(Font);
  nMid := Round((Height - nCanvas.TextHeight(FText)) / 2);

  SetBKMode(nCanvas.Handle, TransParent);
  nCanvas.TextOut(2, nMid, FText);
end;

//Desc: ����ַ���,��֤ÿ�п��Բ�ֳ�����.
function TTextMovedItem.SplitText: Boolean;
var nStr,nText: WideString;
    nPos,nLen,nSLen,nW,nSW: integer;
begin
  Canvas.Font.Assign(Font);
  nSW := Canvas.TextWidth('��');
  //���ֿ��

  FLines.Clear;
  nText := FText;
  nSLen := Length(nText);

  nPos := 1;
  while nPos <= nSLen do
  begin
    nStr := Copy(nText, nPos, 100);
    nLen := Length(nStr);
    nW := Canvas.TextWidth(nStr);

    if nLen > 99 then
     while (nW mod Width <> 0) And ((Width - nW mod Width) > nSW) do
     begin
       System.Delete(nStr, nLen, 1);
       nLen := Length(nStr);
       nW := Canvas.TextWidth(nStr);
     end;
    {-------------------------------- �����㷨 ---------------------------------
      1.�ı�����һ��ʱ,ֱ������.
      2.�ı����ù�����ʱ,ֱ������.
      3.�ı���������һ����ʱ,ֱ������.
    ---------------------------------------------------------------------------}

      nPos := nPos + nLen;
      //��һ�ı�����ʼλ��
      FLines.Add(nStr);
  end;

  Result := FLines.Count > 0;
end;

//------------------------------------------------------------------------------
constructor TPictureMovedItem.Create(AOwner: TComponent);
begin
  inherited;
  Width := 48;
  Height := 23;

  FStretch := True;
  FText := 'ͼ������';
  FImage := TPicture.Create;

  FNowData := nil;
  FDataList := TList.Create;
end;

destructor TPictureMovedItem.Destroy;
var nIdx: integer;
begin
  for nIdx:=FDataList.Count - 1 downto 0 do
  begin
    Dispose(PPictureData(FDataList[nIdx]));
    FDataList.Delete(nIdx);
  end;

  FDataList.Free;
  FImage.Free;
  inherited;
end;

function TPictureMovedItem.AddData(const nFile: string;
  nType: TPictureDataType): integer;
var nStr: string;
    nGif: TGIFImage;
    nP: PPictureData;
begin
  New(nP);
  Result := FDataList.Add(nP);

  nP.FFile := nFile;
  nP.FType := nType;
  nP.FModeEnter := ModeEnter;
  nP.FModeExit := ModeExit;
  nP.FSpeedEnter := SpeedEnter;
  nP.FSpeedExit := SpeedExit;
  nP.FKeedTime := KeedTime;
  nP.FModeSerial := ModeSerial;

  nGif := nil;
  if nType = ptPic then
  try
    nStr := ExtractFileExt(nFile);
    if CompareText(nStr, '.gif') <> 0 then Exit;

    nGif := TGIFImage.Create;
    nGif.LoadFromFile(nFile);

    nP.FModeEnter := 0;
    nP.FModeExit := 0;
    nP.FSpeedEnter := 5;
    nP.FSpeedExit := 0;
    nP.FKeedTime := Round(nGif.AnimationSpeed / 1000);
    nP.FModeSerial := 1;
  finally
    nGif.Free;
  end;
end;

procedure TPictureMovedItem.DeleteData(const nIdx: Integer);
begin
  if (nIdx > -1) and (nIdx < FDataList.Count) then
  begin
    Dispose(PPictureData(FDataList[nIdx]));
    FDataList.Delete(nIdx);
  end;
end;

function TPictureMovedItem.FindData(const nFile: string): Integer;
var nIdx: integer;
begin
  Result := -1;
  
  for nIdx:=0 to FDataList.Count - 1 do
  if CompareText(nFile, PPictureData(FDataList[nIdx]).FFile) = 0 then
  begin
    Result := nIdx; Break;
  end;
end;

procedure TPictureMovedItem.SetImage(const nValue: TPicture);
begin
  FImage.Assign(nValue);
end;

procedure TPictureMovedItem.DoPaint(const nCanvas: TCanvas; const nRect: TRect);
var nMid: integer;
begin
  inherited;
  if FImage.Width < 1 then
  begin
    SetBKMode(nCanvas.Handle, TransParent);
    nMid := Round((Height - nCanvas.TextHeight(FText)) / 2);

    nCanvas.Font.Assign(Font);
    nCanvas.TextOut(2, nMid, FText);
  end else

  if FStretch then
  begin
    nCanvas.StretchDraw(ClientRect, FImage.Graphic);
  end else
  begin
    nCanvas.Draw(0, 0, FImage.Graphic);
  end;
end;

//------------------------------------------------------------------------------
constructor TAnimateMovedItem.Create(AOwner: TComponent);
begin
  inherited;
  Width := 48;
  Height := 23;

  FPicNum := 0;
  FSpeed := 0;
  FImageWH := Rect(0, 0, 0, 0);

  FStretch := True;
  FReverse := False;
  
  FText := 'ͼ�Ķ���';
  FImage := TPicture.Create;
end;

destructor TAnimateMovedItem.Destroy;
begin
  FImage.Free;
  inherited;
end;

procedure TAnimateMovedItem.SetFile(const nFile: string);
var nGif: TGIFImage;
begin
  nGif := TGIFImage.Create;
  try
    nGif.LoadFromFile(nFile);
    FImage.Graphic := nGif.Images[0].Bitmap;
    FPicNum := nGif.Images.Count;
    
    if nGif.AnimationSpeed > 0 then
         FSpeed := Round(1000 / nGif.AnimationSpeed)
    else FSpeed := 0;

    FImageWH := Rect(0, 0, nGif.Width, nGif.Height);
    FImageFile := nFile;
  finally
    nGif.Free;
  end;
end;

procedure TAnimateMovedItem.DoPaint(const nCanvas: TCanvas;
  const nRect: TRect);
var nMid: integer;
begin
  inherited;
  if FImage.Width < 1 then
  begin
    SetBKMode(nCanvas.Handle, TransParent);
    nMid := Round((Height - nCanvas.TextHeight(FText)) / 2);

    nCanvas.Font.Assign(Font);
    nCanvas.TextOut(2, nMid, FText);
  end else

  if FStretch then
  begin
    nCanvas.StretchDraw(ClientRect, FImage.Graphic);
  end else
  begin
    nCanvas.Draw(0, 0, FImage.Graphic);
  end;
end;

//------------------------------------------------------------------------------
constructor TTimeMovedItem.Create(AOwner: TComponent);
var nStr: string;
begin
  inherited;
  Width := 96;
  Height := 16;
  
  FTimer := TTimer.Create(Self);
  FTimer.Enabled := False;
  FTimer.OnTimer := DoTimer;

  FOptions := [toTime];
  FTextStyle := tsSingle;
  
  FFixText := '';
  FFixColor := clRed;

  nStr := gMultiLangManager.SectionID;
  gMultiLangManager.SectionID := 'Common';
  try
    FDateText := ML('YYYY��MM��DD��');
    FDateColor := clRed;

    FWeekText := ML('����X');
    FWeekColor := clRed;

    FTimeText := ML('HHʱmm��ss��');
    FTimeColor := clRed;
  finally
    gMultiLangManager.SectionID := nStr;
  end;

  FModeChar := 1;
  FModeLine := 0;
  FModeDate := 0;
  FModeWeek := 0;
  FModeTime := 1;
end;

destructor TTimeMovedItem.Destroy;
begin
  FTimer.Free;
  inherited;
end;

procedure TTimeMovedItem.SwitchTimer(const nEnable: Boolean);
begin
  FTimer.Enabled := nEnable;
end;

procedure TTimeMovedItem.DoTimer(Sender: TObject);
begin
  Invalidate;
end;

procedure TTimeMovedItem.SetModeChar(const nValue: Byte);
var nStr: string;
begin
  if nValue <> FModeChar then
  begin
    FModeChar := nValue;
    if nValue = 0 then //�ַ���ʾ
    begin
      FWeekText := '����X';
      FTimeText := 'HH:mm:ss';
    end else
    begin
      FWeekText := '����X';
      FTimeText := 'HHʱmm��ss��';
    end;
  end;

  nStr := gMultiLangManager.SectionID;
  gMultiLangManager.SectionID := 'Common';

  FWeekText := ML(FWeekText);
  FTimeText := ML(FTimeText);
  gMultiLangManager.SectionID := nStr;
end;

function GetDateText(const nModeChar,nModeDate: Byte): string;
var nStr: string;
begin
  if nModeChar = 0 then //�ַ�ģʽ
  begin
    case nModeDate of
      1: Result := 'YY-MM-DD';
      2: Result := 'YYYY-MM-DD';
    end;
  end else
  begin
    case nModeDate of
      1: Result := 'YY��MM��DD��';
      2: Result := 'YYYY��MM��DD��';
    end;
  end;

  nStr := gMultiLangManager.SectionID;
  gMultiLangManager.SectionID := 'Common';

  Result := ML(Result);
  gMultiLangManager.SectionID := nStr;
end;

//Desc: ��nDate��nFormat��ʽ��
function FormatWeekDay(const nFormat: string; const nDate: TDateTime): string;
var nStr: string;
begin
  case DayOfWeek(nDate) of
    1: nStr := '��';
    2: nStr := 'һ';
    3: nStr := '��';
    4: nStr := '��';
    5: nStr := '��';
    6: nStr := '��';
    7: nStr := '��' else nStr := '';
  end;

  Result := StringReplace(nFormat, 'X', nStr, [rfReplaceAll, rfIgnoreCase]);
  nStr := gMultiLangManager.SectionID;
  gMultiLangManager.SectionID := 'Common';

  Result := ML(Result);
  gMultiLangManager.SectionID := nStr;
end;

//Desc: ����
procedure TTimeMovedItem.DoPaint(const nCanvas: TCanvas; const nRect: TRect);
var nStr,nTmp: string;
    nL,nT,nInt: integer;
begin
  inherited;
  nCanvas.Font.Assign(Font);
  SetBKMode(nCanvas.Handle, Transparent);

  if FModeLine = 0 then
  begin
    if FModeDate = 0 then
         nStr := ''
    else nStr := FormatDateTime(GetDateText(FModeChar, FModeDate), Now);

    case FModeWeek of
      0: ;
      1: begin
           nTmp := FormatWeekDay(FWeekText, Now);
           if nStr = '' then
                nStr := nTmp
           else nStr := nStr + ' ' + nTmp;
         end;
    end;

    case FModeTime of
      0: ;
      1: begin
           nTmp := FormatDateTime(FTimeText, Now);
           if nStr = '' then
                nStr := nTmp
           else nStr := nStr + ' ' + nTmp;
         end;
    end;
    
    nL := Round((Width - nCanvas.TextWidth(nStr)) / 2);
    if nL < 0 then nL := 0;
    nT := Round((Height - nCanvas.TextHeight(nStr)) / 2);
    if nT < 0 then nT := 0;

    nCanvas.TextOut(nL, nT, nStr);
    Exit; //���л������
  end;

  //----------------------------------------------------------------------------
  nT := 0;
  nInt := 0;

  if FModeDate <> 0 then
  begin
    Inc(nT, nCanvas.TextHeight(FormatDateTime(FDateText, Now))); Inc(nInt);
  end;

  if FModeWeek <> 0 then
  begin
    Inc(nT, nCanvas.TextHeight(FormatWeekDay(FWeekText, Now))); Inc(nInt);
  end;

  if FModeTime <> 0 then
  begin
    Inc(nT, nCanvas.TextHeight(FormatDateTime(FTimeText, Now))); Inc(nInt);
  end;

  if nInt > 1 then
  begin
    nInt := Round((Height - nT) / (nInt - 1)); nT := 0;
  end else
  begin
    nInt := 0; nT := Round((Height - nT) / 2);
  end;
  //ÿ���ı��������ʼ����

  if FModeDate <> 0 then
  begin
    nStr := FormatDateTime(GetDateText(FModeChar, FModeDate), Now);
    nL := Round((Width - nCanvas.TextWidth(nStr)) / 2);
    if nL < 0 then nL := 0;

    nCanvas.TextOut(nL, nT, nStr);
    Inc(nT, nInt + nCanvas.TextHeight(nStr));
  end;

  if FModeWeek <> 0 then
  begin
    nStr := FormatWeekDay(FWeekText, Now);
    nL := Round((Width - nCanvas.TextWidth(nStr)) / 2);
    if nL < 0 then nL := 0;

    nCanvas.TextOut(nL, nT, nStr);
    Inc(nT, nInt + nCanvas.TextHeight(nStr));
  end;

  if FModeTime <> 0 then
  begin
    nStr := FormatDateTime(FTimeText, Now);
    nL := Round((Width - nCanvas.TextWidth(nStr)) / 2);
    
    if nL < 0 then nL := 0;
    nCanvas.TextOut(nL, nT, nStr);
  end;
end;
{
//Desc: ����
procedure TTimeMovedItem.DoPaint(const nCanvas: TCanvas; const nRect: TRect);
var nStr: string;
    nL,nT,nInt: integer;
begin
  inherited;
  nCanvas.Font.Assign(Font);
  SetBKMode(nCanvas.Handle, Transparent);

  if FTextStyle = tsSingle then
  begin
    nStr := FFixText;
    if toDate in FOptions then
      nStr := nStr + FormatDateTime(FDateText, Now);
    if toWeek in FOptions then
      nStr := nStr + FormatWeekDay(FWeekText, Now);
    if toTime in FOptions then
      nStr := nStr + FormatDateTime(FTimeText, Now);

    nL := Round((Width - nCanvas.TextWidth(nStr)) / 2);
    if nL < 0 then nL := 0;
    nT := Round((Height - nCanvas.TextHeight(nStr)) / 2);
    if nT < 0 then nT := 0;

    if FFixText <> '' then
    begin
      nCanvas.Font.Color := FFixColor;
      nCanvas.TextOut(nL, nT, FFixText);
      Inc(nL, nCanvas.TextWidth(FFixText));
    end;

    if toDate in FOptions then
    begin
      nStr := FormatDateTime(FDateText, Now);
      nCanvas.Font.Color := FDateColor;
      
      nCanvas.TextOut(nL, nT, nStr);
      Inc(nL, nCanvas.TextWidth(nStr));
    end;

    if toWeek in FOptions then
    begin
      nStr := FormatWeekDay(FWeekText, Now);
      nCanvas.Font.Color := FWeekColor;
      
      nCanvas.TextOut(nL, nT, nStr);
      Inc(nL, nCanvas.TextWidth(nStr));
    end;

    if toTime in FOptions then
    begin
      nStr := FormatDateTime(FTimeText, Now);
      nCanvas.Font.Color := FTimeColor;
      nCanvas.TextOut(nL, nT, nStr);
    end;

    Exit; //���л������
  end;

  //----------------------------------------------------------------------------
  nT := 0;
  nInt := 0;

  if FFixText <> '' then
  begin
    nT := nCanvas.TextHeight(FFixText); Inc(nInt);
  end;

  if toDate in FOptions then
  begin
    Inc(nT, nCanvas.TextHeight(FormatDateTime(FDateText, Now))); Inc(nInt);
  end;

  if toWeek in FOptions then
  begin
    Inc(nT, nCanvas.TextHeight(FormatWeekDay(FWeekText, Now))); Inc(nInt);
  end;

  if toTime in FOptions then
  begin
    Inc(nT, nCanvas.TextHeight(FormatDateTime(FTimeText, Now))); Inc(nInt);
  end;

  if nInt > 1 then
  begin
    nInt := Round((Height - nT) / (nInt - 1)); nT := 0;
  end else
  begin
    nInt := 0; nT := Round((Height - nT) / 2);
  end;
  //ÿ���ı��������ʼ���� 

  if FFixText <> '' then
  begin
    nL := Round((Width - nCanvas.TextWidth(FFixText)) / 2);
    if nL < 0 then nL := 0;

    nCanvas.Font.Color := FFixColor;
    nCanvas.TextOut(nL, nT, FFixText);
    Inc(nT, nInt + nCanvas.TextHeight(FFixText));
  end;

  if toDate in FOptions then
  begin
    nStr := FormatDateTime(FDateText, Now);
    nL := Round((Width - nCanvas.TextWidth(nStr)) / 2);
    if nL < 0 then nL := 0;

    nCanvas.Font.Color := FDateColor;
    nCanvas.TextOut(nL, nT, nStr);
    Inc(nT, nInt + nCanvas.TextHeight(nStr));
  end;

  if toWeek in FOptions then
  begin
    nStr := FormatWeekDay(FWeekText, Now);
    nL := Round((Width - nCanvas.TextWidth(nStr)) / 2);
    if nL < 0 then nL := 0;

    nCanvas.Font.Color := FWeekColor;
    nCanvas.TextOut(nL, nT, nStr);
    Inc(nT, nInt + nCanvas.TextHeight(nStr));
  end;

  if toTime in FOptions then
  begin
    nStr := FormatDateTime(FTimeText, Now);
    nL := Round((Width - nCanvas.TextWidth(nStr)) / 2);
    if nL < 0 then nL := 0;

    nCanvas.Font.Color := FTimeColor;
    nCanvas.TextOut(nL, nT, nStr);
  end;
end;
}

//------------------------------------------------------------------------------
constructor TClockMovedItem.Create(AOwner: TComponent);
begin
  inherited;
  Width := 32;
  Height := 32;
  Font.Color := clRed;

  FColorHour := clYellow;
  FColorMin := clGreen;
  FColorSec := clRed;

  FAutoDot := True;
  FImage := TPicture.Create;
end;

destructor TClockMovedItem.Destroy;
begin
  FImage.Free;
  inherited;
end;

procedure TClockMovedItem.SetImage(const nValue: TPicture);
begin
  FImage.Assign(nValue);
end;

procedure TClockMovedItem.Resize;
begin
  inherited;
  if FAutoDot then FDotPoint := DefaultDotPoint;
end;

procedure TClockMovedItem.SetAutoDot(const nValue: Boolean);
begin
  if FAutoDot <> nValue then
  begin
    FAutoDot := nValue;
    if FAutoDot then FDotPoint := DefaultDotPoint;
  end;
end;

function TClockMovedItem.DefaultDotPoint: TPoint;
begin
  Result.X := Trunc(Width / 2);
  Result.Y := Trunc(Height / 2);
end;

//Desc: ���Ʊ���
procedure TClockMovedItem.PaintZhen(const nCanvas: TCanvas; const nR: integer);
var nInt: integer;
begin
  nCanvas.Brush.Color := clRed;
  with FDotPoint do
  begin
    nCanvas.Ellipse(X-2, Y-2, X+2, Y+2);
    //����ԭ��

    nCanvas.Pen.Width := 3;
    nCanvas.Pen.Color := FColorMin;

    nCanvas.MoveTo(X - 1, Y - 2);
    nInt := Trunc(nR*5/6);
    nCanvas.LineTo(X - 1, Y - nInt);
    //����

    nCanvas.Pen.Color := FColorHour;
    nCanvas.MoveTo(X + 1, Y);
    nInt := Trunc(nR*2/3);
    nCanvas.LineTo(X + nInt, Y);
    //ʱ��

    nCanvas.Pen.Width := 1;
    nCanvas.Pen.Color := FColorSec;
    nCanvas.MoveTo(X - 1, Y);
    nInt := Trunc(nR*0.6);
    nCanvas.LineTo(X - nInt, Y + nInt);
    //����
  end;
end;

procedure TClockMovedItem.DoPaint(const nCanvas: TCanvas;
  const nRect: TRect);
var nR: integer;
begin
  inherited;
  nR := FDotPoint.X;
  if nR > FDotPoint.Y then nR := FDotPoint.Y;
  Dec(nR, 2);

  if FImage.Width < 1 then
  begin
    nCanvas.Pen.Color := clRed;
    nCanvas.Pen.Width := 1;
    with FDotPoint do
    begin
      nCanvas.Ellipse(X - nR, Y - nR, X + nR, Y+ nR);
      //����Բ��

      nCanvas.Pen.Color := clYellow;
      nCanvas.Brush.Color := clYellow;
      nCanvas.Rectangle(X - nR, Y - 1, X - nR + 2, Y + 2); //9��
      nCanvas.Rectangle(X + nR - 2, Y - 1, X + nR, Y + 2); //3��
      nCanvas.Rectangle(X - 1, Y - nR, X + 2, Y - nR + 2);//12��
      nCanvas.Rectangle(X - 1, Y + nR - 2, X + 2, Y + nR); //6��
    end;
  end else
  begin
    nCanvas.StretchDraw(ClientRect, FImage.Graphic);
    //���Ʊ���
  end;

  PaintZhen(nCanvas, nR);
  //����Բ�ĺ�ָ��
end;

end.
