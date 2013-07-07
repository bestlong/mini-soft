{*******************************************************************************
  ����: dmzn@163.com 2013-07-06
  ����: �������
*******************************************************************************}
unit UFormArea;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters, cxContainer,
  cxEdit, cxTextEdit, dxLayoutControl, StdCtrls;

type
  TfFormArea = class(TfFormNormal)
    EditID: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditName: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditURL: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
  private
    { Private declarations }
    FIsAdd: Boolean;
    FAreaID: string;
    //�����ʶ
    procedure InitFormData(const nID: string);
    //��������
  protected
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
    procedure GetSaveSQLList(const nList: TStrings); override;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}

uses
  ULibFun, UMgrControl, UFormCtrl, UFormBase, UDataModule, USysDB, USysConst;

class function TfFormArea.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  case nP.FCommand of
   cCmd_AddData:
    with TfFormArea.Create(Application) do
    begin
      FAreaID := nP.FParamA;
      FIsAdd := True;
      Caption := '���� - ���';

      InitFormData('');
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
      Free;
    end;
   cCmd_EditData:
    with TfFormArea.Create(Application) do
    begin
      FAreaID := nP.FParamA;
      FIsAdd := False;
      Caption := '���� - �޸�';

      InitFormData(FAreaID);
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
      Free;
    end;
  end;
end;

class function TfFormArea.FormID: integer;
begin
  Result := cFI_FormArea;
end;

procedure TfFormArea.InitFormData(const nID: string);
var nStr: string;
begin
  if nID <> '' then
  begin
    nStr := 'Select * From %s Where A_ID=''%s''';
    nStr := Format(nStr, [sTable_Area, nID]);

    with FDM.QuerySQL(nStr) do
    if RecordCount > 0 then
    begin
      EditID.Text := FieldByName('A_ID').AsString;
      EditName.Text := FieldByName('A_Name').AsString;
      EditURL.Text := FieldByName('A_MIT').AsString;
    end;
  end;
end;

//Desc: ��֤����
function TfFormArea.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var nStr: string;
begin
  Result := True;

  if Sender = EditID then
  begin
    Result := Trim(EditID.Text) <> '';
    nHint := '����д��Ч���';
    if not Result then Exit;

    if FIsAdd then
    begin
      nStr := 'Select Count(*) From %s Where A_ID=''%s''';
      nStr := Format(nStr, [sTable_Area, EditID.Text]);
    end else

    if EditID.Text <> FAreaID then
    begin
      nStr := 'Select Count(*) From %s Where A_ID=''%s''';
      nStr := Format(nStr, [sTable_Area, EditID.Text]);
    end else nStr := '';

    if nStr <> '' then
    begin
      with FDM.QuerySQL(nStr) do
      begin
        Result := Fields[0].AsInteger < 1;
        nHint := '�ñ�������Ѵ���';
      end;
    end;
  end else

  if Sender = EditName then
  begin
    Result := Trim(EditName.Text) <> '';
    nHint := '����д��������';
  end else

  if Sender = EditURL then
  begin
    nStr := LowerCase(EditURL.Text);
    Result := (nStr = '') or (Pos('http://', nStr) = 1);
    nHint := '�����ַ��"http"��ͷ';
  end;
end;

//Desc����������
procedure TfFormArea.GetSaveSQLList(const nList: TStrings);
var nStr: string;
begin
  if FIsAdd then
  begin
    nStr := MakeSQLByStr([SF('A_ID', EditID.Text),
            SF('A_Name', EditName.Text), SF('A_MIT', EditURL.Text),
            SF('A_Parent', FAreaID)], sTable_Area, '', True);
    nList.Add(nStr);
  end else
  begin
    nStr := Format('A_ID=''%s''', [FAreaID]);
    nStr := MakeSQLByStr([SF('A_ID', EditID.Text),
            SF('A_Name', EditName.Text), SF('A_MIT', EditURL.Text)],
            sTable_Area, nStr, False);
    nList.Add(nStr);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormArea, TfFormArea.FormID);
end.
