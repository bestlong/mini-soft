{*******************************************************************************
  ����: dmzn@163.com 2009-5-20
  ����: ���ݿ����ӡ�������� 
*******************************************************************************}
unit UDataModule;

{$I Link.Inc}
interface

uses
  Windows, Graphics, SysUtils, Classes, dxPSGlbl, dxPSUtl, dxPSEngn,
  dxPrnPg, ULibFun, dxWrap, dxPrnDev, dxPSCompsProvider, dxPSFillPatterns,
  dxPSEdgePatterns, cxLookAndFeels, dxPSCore, dxPScxCommon, dxPScxGrid6Lnk,
  XPMan, dxLayoutLookAndFeels, cxEdit, ImgList, Controls, cxGraphics, DB,
  ADODB, dxBkgnd, dxPSPDFExportCore, dxPSPDFExport, cxDrawTextUtils,
  dxPSPrVwStd, dxPScxEditorProducers, dxPScxExtEditorProducers,
  dxPScxPageControlProducer;

type
  TFDM = class(TDataModule)
    ADOConn: TADOConnection;
    SqlQuery: TADOQuery;
    Command: TADOQuery;
    SqlTemp: TADOQuery;
    ImageBig: TcxImageList;
    Imagesmall: TcxImageList;
    edtStyle: TcxDefaultEditStyleController;
    dxLayout1: TdxLayoutLookAndFeelList;
    ImageMid: TcxImageList;
    XPM1: TXPManifest;
    dxLayoutWeb1: TdxLayoutWebLookAndFeel;
    ImageBar: TcxImageList;
    dxPrinter1: TdxComponentPrinter;
    dxGridLink1: TdxGridReportLink;
    cxLoF1: TcxLookAndFeelController;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function QuerySQL(const nSQL: string): TDataSet;
    function QueryTemp(const nSQL: string): TDataSet;
    procedure QueryData(const nQuery: TADOQuery; const nSQL: string);
    {*��ѯ����*}
    function ExecuteSQL(const nSQL: string): integer;
    {*ִ��д����*}
    function AdjustAllSystemTables: Boolean;
    {*У��ϵͳ��*}
    function IconIndex(const nName: string): integer;
    procedure LoadSystemIcons(const nIconFile: string);
    {*����ͼ��*}
    function WriteSysLog(const nGroup,nItem,nEvent: string;
     const nHint: Boolean = True;
     const nKeyID: string = ''; const nMan: string = ''): Boolean;
    {*ϵͳ��־*}
    function SQLServerNow: string;
    function ServerNow: TDateTime;
    {*������ʱ��*}
    function GetFieldMax(const nTable,nField: string): integer;
    {*�ֶ����ֵ*}
    function GetRandomID(const nPrefix: string; const nIDLen: Integer): string;
    function GetSerialID(const nPrefix,nTable,nField: string;
     const nIncLen: Integer = 3): string;
    function GetSerialID2(const nPrefix,nTable,nKey,nField: string;
     const nFixID: Integer; const nIncLen: Integer = 3): string;
    function GetNeighborID(const nID: string;const nNext: Boolean;
     const nIncLen: Integer = 3): string;
    {*�Զ����*}
    procedure FillStringsData(const nList: TStrings; const nSQL: string;
      const nFieldLen: integer = 0; const nFieldFlag: string = '';
      const nExclude: TDynamicStrArray = nil);
    {*�������*}
    function LoadDBImage(const nDS: TDataSet; const nFieldName: string;
      const nPicture: TPicture): Boolean;
    function SaveDBImage(const nDS: TDataSet; const nFieldName: string;
      const nImage: string): Boolean; overload;
    function SaveDBImage(const nDS: TDataSet; const nFieldName: string;
      const nImage: TGraphic): Boolean; overload;
    {*��дͼƬ*}
  end;

var
  FDM: TFDM;

implementation

{$R *.dfm}
uses
  Variants, cxImageListEditor, UFormCtrl, UMgrIni, UMgrLog,
  {$IFDEF UseReport}UDataReport,{$ENDIF}
  {$IFDEF cxLookupCombox}USysLookupAdapter,{$ENDIF}
  USysConst, USysDB;

//------------------------------------------------------------------------------
procedure WriteLog(const nEvent: string);
var nItem: PLogItem;
begin
  nItem := gLogManager.NewLogItem;
  nItem.FWriter.FOjbect := TFDM;
  nItem.FWriter.FDesc := '����ģ��';
  nItem.FLogTag := [ltWriteFile];
  nItem.FEvent := nEvent;
  gLogManager.AddNewLog(nItem);
end;

//------------------------------------------------------------------------------
//Date: 2009-5-27
//Parm: ͼ�������ļ�
//Desc: ����nIconFile��Ӧ��ͼ���б�
procedure TFDM.LoadSystemIcons(const nIconFile: string);
var nStr,nPath: string;
    i,nCount: integer;
    nItem: PIniDataItem;
    nBig,nMid,nSmall: TStrings;
    nEditor: TcxImageListEditor;
begin
  if gIniManager.LoadIni(nIconFile) then
  begin
    ImageBig.Clear;
    ImageMid.Clear;
    ImageSmall.Clear;
  end else Exit;

  nPath := ExtractFilePath(nIconFile);
  nCount := gIniManager.Items.Count - 1;

  nEditor := nil;
  nBig := TStringList.Create;
  nMid := TStringList.Create;
  nSmall := TStringList.Create;
  try
    for i:=0 to nCount do
    begin
      nItem := gIniManager.Items[i];
      nStr := nPath + nItem.FKeyValue;

      if FileExists(nStr) then
       if CompareText(nItem.FSection, 'Large') = 0 then
         nItem.FExtValue := nBig.Add(nStr) else
       if CompareText(nItem.FSection, 'Middle') = 0 then
         nItem.FExtValue := nMid.Add(nStr) else
       if CompareText(nItem.FSection, 'Small') = 0 then
         nItem.FExtValue := nSmall.Add(nStr);
    end;

    if nBig.Count > 0 then
    begin
      {$IFDEF cxLibrary42}
        nEditor := TcxImageListEditor.Create;
      {$ELSE}
        nEditor := TcxImageListEditor.Create(Self);
      {$ENDIF}
      nEditor.ImageList := ImageBig;
      nEditor.AddImages(nBig, amAdd);
      nEditor.ApplyChanges;
      FreeAndNil(nEditor);
    end;

    if nMid.Count > 0 then
    begin
      {$IFDEF cxLibrary42}
        nEditor := TcxImageListEditor.Create;
      {$ELSE}
        nEditor := TcxImageListEditor.Create(Self);
      {$ENDIF}
      nEditor.ImageList := ImageMid;
      nEditor.AddImages(nMid, amAdd);
      nEditor.ApplyChanges;
      FreeAndNil(nEditor);
    end;
    
    if nSmall.Count > 0 then
    begin
      {$IFDEF cxLibrary42}
        nEditor := TcxImageListEditor.Create;
      {$ELSE}
        nEditor := TcxImageListEditor.Create(Self);
      {$ENDIF}
      nEditor.ImageList := ImageSmall;
      nEditor.AddImages(nSmall, amAdd);
      nEditor.ApplyChanges;
      FreeAndNil(nEditor);
    end;
  finally
    nBig.Free;
    nMid.Free;
    nSmall.Free;
    if Assigned(nEditor) then nEditor.Free;
  end;
end;

//Date: 2009-5-27
//Parm: ͼ������
//Desc: ��ȡnNameͼ�������
function TFDM.IconIndex(const nName: string): integer;
var nItem: PIniDataItem;
begin
  nItem := gIniManager.FindItem(nName);
  if Assigned(nItem) and (not VarIsEmpty(nItem.FExtValue)) then
       Result := nItem.FExtValue
  else Result := -1;
end;

//Desc: У��ϵͳ��,������������
function TFDM.AdjustAllSystemTables: Boolean;
var nStr: string;
    nList: TStrings;
    nP: PSysTableItem;
    i,nCount: integer;
begin
  nList := TStringList.Create;
  try
    FDM.ADOConn.GetTableNames(nList);
    nCount := gSysTableList.Count - 1;

    for i:=0 to nCount do
    begin
      nP := gSysTableList[i];
      if nList.IndexOf(nP.FTable) > -1 then Continue;

      if gSysDBType = dtAccess then
      begin
        nStr := MacroValue(nP.FNewSQL, [MI('$Inc', sField_Access_AutoInc),
                                        MI('$Float', sField_Access_Decimal),
                                        MI('$Image', sField_Access_Image)]);
      end else

      if gSysDBType = dtSQLServer then
      begin
        nStr := MacroValue(nP.FNewSQL, [MI('$Inc', sField_SQLServer_AutoInc),
                                        MI('$Float', sField_SQLServer_Decimal),
                                        MI('$Image', sField_SQLServer_Image)]);
      end;

      nStr := MacroValue(nStr, [MI('$Table', nP.FTable),
                                MI('$Integer', sFlag_Integer),
                                MI('$Decimal', sFlag_Decimal)]);
      FDM.ExecuteSQL(nStr);
    end;

    nList.Free;
    Result := True;
  except
    nList.Free;
    Result := False;
  end;
end;

//Date: 2009-6-8
//Parm: ��Ϣ����;��ʶ;�¼�;������ʶ;������
//Desc: ��ϵͳ��־��д��һ����־��¼
function TFDM.WriteSysLog(const nGroup, nItem, nEvent: string;
  const nHint: Boolean; const nKeyID, nMan: string): Boolean;
var nStr,nSQL: string;
begin
  nSQL := 'Insert Into $T(L_Date,L_Man,L_Group,L_ItemID,L_KeyID,L_Event) ' +
          'Values($D,''$M'',''$G'',''$I'',''$K'',''$E'')';
  nSQL := MacroValue(nSQL, [MI('$T', sTable_SysLog), MI('$D', SQLServerNow),
                            MI('$G', nGroup), MI('$I', nItem),
                            MI('$E', nEvent), MI('$K', nKeyID)]);

  if nMan = '' then
       nStr := gSysParam.FUserName
  else nStr := nMan;

  nSQL := MacroValue(nSQL, [MI('$M', nStr)]);
  try
    ExecuteSQL(nSQL);
    Result := True;
  except
    Result := False;
    if nHint then ShowMsg('д��ϵͳ��־ʱ��������', sHint);
  end;
end;

//Date: 2010-3-5
//Desc: sql����п��õķ�����ʱ��
function TFDM.SQLServerNow: string;
begin
  if gSysDBType = dtSQLServer then
       Result := sField_SQLServer_Now
  else Result := Format('''%s''', [DateTime2Str(Now)]);
end;

//Date: 2010-3-19
//Parm: ֻȡ������
//Desc: ���ط�������ʱ��
function TFDM.ServerNow: TDateTime;
var nStr: string;
begin
  nStr := 'Select ' + sField_SQLServer_Now;
  Result := FDM.QueryTemp(nStr).Fields[0].AsDateTime;
end;

//Date: 2009-6-10
//Parm: ����;�ֶ�
//Desc: ��ȡnTable.nField�����ֵ
function TFDM.GetFieldMax(const nTable, nField: string): integer;
var nStr: string;
begin
  nStr := 'Select Max(%s) From %s';
  nStr := Format(nStr, [nField, nTable]);

  with QueryTemp(nStr) do
  begin
    Result := Fields[0].AsInteger;
  end;
end;  

//Desc: ����ǰ׺ΪnPrefix,����ΪnIDLen��������
function TFDM.GetRandomID(const nPrefix: string; const nIDLen: Integer): string;
var nStr,nChar: string;
    nIdx,nMid: integer;
begin
  nStr := FloatToStr(Now);
  while Length(nStr) < nIDLen do
    nStr := nStr + FloatToStr(Now);
  //xxxxx

  nStr := StringReplace(nStr, '.', '0', [rfReplaceAll]);
  nMid := Trunc(Length(nStr) / 2);

  for nIdx:=1 to nMid do
  begin
    nChar := nStr[nIdx];
    nStr[nIdx] := nStr[2 * nMid - nIdx];
    nStr[2 * nMid - nIdx] := nChar[1];
  end;

  Result := nPrefix + Copy(nStr, 1, nIDLen - Length(nPrefix));
end;

//Date: 2009-8-30
//Parm: ǰ׺;����;�ֶ�;����������ų�
//Desc: ����ǰ׺ΪnPrefix,��nTable.nFieldΪ�ο����������
function TFDM.GetSerialID(const nPrefix, nTable, nField: string;
 const nIncLen: Integer = 3): string;
var nStr,nTmp: string;
begin
  Result := '';
  try
    nStr := 'Select getDate()';
    nTmp := FormatDateTime('YYMMDD', QueryTemp(nStr).Fields[0].AsDateTime);

    nStr := 'Select Top 1 $F From $T Where $F Like ''$P$D%'' Order By $F DESC';
    nStr := MacroValue(nStr, [MI('$T', nTable), MI('$F', nField),
            MI('$D', nTmp), MI('$P', nPrefix)]);
    //xxxxx

    with QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      nStr := Fields[0].AsString;
      nStr := Copy(nStr, Length(nStr) - nIncLen + 1, nIncLen);

      if IsNumber(nStr, False) then
           nStr := IntToStr(StrToInt(nStr) + 1)
      else nStr := '1';
    end else nStr := '1';

    nStr := StringOfChar('0', nIncLen - Length(nStr)) + nStr;
    Result := nPrefix + nTmp + nStr;
  except
    //ignor any error
  end;
end;

//Date: 2010-3-4
//Parm: ǰ׺;����;��������;�ֶ�;�������;��ų�
//Desc: ����nFixID��Ӧ����nPrefixΪǰ׺,nTable.nFieldΪ�ο����������
function TFDM.GetSerialID2(const nPrefix, nTable, nKey, nField: string;
  const nFixID: Integer; const nIncLen: Integer): string;
var nInt: Integer;
    nStr,nTmp: string;
begin
  Result := '';
  try
    nStr := 'Select getDate()';
    nTmp := FormatDateTime('YYMMDD', QueryTemp(nStr).Fields[0].AsDateTime);

    nStr := 'Select Top 1 $K,$F From $T Where $F Like ''$P$D%'' Order By $F DESC';
    nStr := MacroValue(nStr, [MI('$T', nTable), MI('$F', nField),
            MI('$D', nTmp), MI('$K', nKey), MI('$P', nPrefix)]);
    //xxxxx

    with QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      if nFixID = Fields[0].AsInteger then
      begin
        Result := Fields[1].AsString; Exit;
      end;

      if nFixID < Fields[0].AsInteger then
      begin
        nStr := 'Select $F From $T Where $K=$ID';
        nStr := MacroValue(nStr, [MI('$F', nField), MI('$T', nTable),
                MI('$K', nKey), MI('$ID', IntToStr(nFixID))]);
        //xxxxx

        with FDM.QueryTemp(nStr) do
        if RecordCount > 0 then
          Result := Fields[0].AsString;
        Exit;
      end;

      nStr := Fields[1].AsString;
      System.Delete(nStr, 1, Length(nPrefix + nTmp));

      if IsNumber(nStr, False) then
      begin
        nInt := Fields[0].AsInteger - StrToInt(nStr);
        nStr := IntToStr(nFixID - nInt);
      end else nStr := '1';
    end else nStr := '1';

    nStr := StringOfChar('0', nIncLen - Length(nStr)) + nStr;
    Result := nPrefix + nTmp + nStr;
  except
    //ignor any error
  end;
end;

//Date: 2009-8-20
//Parm: ���;�Ƿ���һ��
//Desc: ������nID���ڵ���һ������һ�����
function TFDM.GetNeighborID(const nID: string;const nNext: Boolean;
 const nIncLen: Integer = 3): string;
var nStr: string;
    nLen: integer;
begin
  nLen := Length(nID);
  nStr := Copy(nID, nLen - nIncLen - 1, nIncLen);

  if IsNumber(nStr, False) then
  begin
    if nNext then
         nStr := IntToStr(StrToInt(nStr) + 1)
    else nStr := IntToStr(StrToInt(nStr) - 1);
  end else nStr := '1';

  nStr := StringOfChar('0', nIncLen - Length(nStr)) + nStr;
  Result := Copy(nID, 1, nLen - nIncLen) + nStr;
end;

//Date: 2009-6-12
//Parm: ������б�;SQL(Prefix=SQL);�ֶγ�;�ָ���;�ų��ֶ�
//Desc: ��nSQL��ѯ�Ľ�����nList�б�
procedure TFDM.FillStringsData(const nList: TStrings; const nSQL: string;
 const nFieldLen: integer = 0; const nFieldFlag: string = '';
 const nExclude: TDynamicStrArray = nil);
var nPos: integer;
    nStr,nPrefix: string;
begin
  nList.Clear;
  try
    nStr := nSQL;
    nPos := Pos('=', nSQL);

    if nPos > 1 then
    begin
      nPrefix := Copy(nSQL, 1, nPos - 1);
      System.Delete(nStr, 1, nPos);
    end else
    begin
      nPrefix := '';
    end;

    LoadDataToList(QueryTemp(nStr), nList, nPrefix, nFieldLen,
                                    nFieldFlag, nExclude);
    //fill record into list
  except
    //ignor any error
  end;
end;

//------------------------------------------------------------------------------
//Date: 2009-7-4
//Parm: ���ݼ�;�ֶ���;ͼ������
//Desc: ��nImageͼ�����nDS.nField�ֶ�
function TFDM.SaveDBImage(const nDS: TDataSet; const nFieldName: string;
  const nImage: TGraphic): Boolean;
var nField: TField;
    nStream: TMemoryStream;
    nBuf: array[1..MAX_PATH] of Char;
begin
  Result := False;
  nField := nDS.FindField(nFieldName);
  if not (Assigned(nField) and (nField is TBlobField)) then Exit;

  nStream := nil;
  try
    if not Assigned(nImage) then
    begin
      nDS.Edit;
      TBlobField(nField).Clear;
      nDS.Post; Result := True; Exit;
    end;
    
    nStream := TMemoryStream.Create;
    nImage.SaveToStream(nStream);
    nStream.Seek(0, soFromEnd);

    FillChar(nBuf, MAX_PATH, #0);
    StrPCopy(@nBuf[1], nImage.ClassName);
    nStream.WriteBuffer(nBuf, MAX_PATH);

    nDS.Edit;
    nStream.Position := 0;
    TBlobField(nField).LoadFromStream(nStream);

    nDS.Post;
    FreeAndNil(nStream);
    Result := True;
  except
    if Assigned(nStream) then nStream.Free;
    if nDS.State = dsEdit then nDS.Cancel;
  end;
end;

//Date: 2009-6-14
//Parm: ���ݼ�;�ֶ�;ͼƬ�ļ�
//Desc: ��nImage�ļ�����nDS.nField�ֶ�
function TFDM.SaveDBImage(const nDS: TDataSet; const nFieldName: string;
 const nImage: string): Boolean;
var nPic: TPicture;
begin
  Result := False;
  if not FileExists(nImage) then Exit;

  nPic := nil;
  try
    nPic := TPicture.Create;
    nPic.LoadFromFile(nImage);

    SaveDBImage(nDS, nFieldName, nPic.Graphic);
    FreeAndNil(nPic);
  except
    if Assigned(nPic) then nPic.Free;
  end;
end;

//Date: 2009-6-14
//Parm: ���ݼ�;�ֶ�;ͼ��ؼ�;��ʱ·��
//Desc: ��ȡnDS.nField��ͼƬ����,����nPicture��
function TFDM.LoadDBImage(const nDS: TDataSet; const nFieldName: string;
  const nPicture: TPicture): Boolean;
var nField: TField;
    nStream: TMemoryStream;
    nBuf: array[1..MAX_PATH] of Char;
    nImage: TGraphic;
    nClass: TPersistentClass;
begin
  Result := False;
  nPicture.Graphic := nil;
  
  nField := nDS.FindField(nFieldName);
  if not (Assigned(nField) and (nField is TBlobField)) then Exit;

  nImage := nil;
  nStream := nil;
  try
    nStream := TMemoryStream.Create;
    TBlobField(nField).SaveToStream(nStream);

    if nStream.Size < MAX_PATH then Exit;
    nStream.Seek(-MAX_PATH, soFromEnd);
    nStream.ReadBuffer(nBuf, MAX_PATH);

    nClass := FindClass(PChar(@nBuf[1]));
    if Assigned(nClass) then
    begin
      nImage := TGraphicClass(nClass).Create;
      nStream.Size := nStream.Size - MAX_PATH;
      nStream.Seek(0, soFromBeginning);

      nImage.LoadFromStream(nStream);
      nPicture.Graphic := nImage;
      FreeAndNil(nImage);
    end;

    FreeAndNil(nStream);
    Result := True;
  except
    if Assigned(nImage) then nImage.Free;
    if Assigned(nStream) then nStream.Free;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ִ��nSQLд����
function TFDM.ExecuteSQL(const nSQL: string): integer;
begin
  try
    Command.Close;
    Command.SQL.Text := nSQL;
    Result := Command.ExecSQL;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
      raise;
    end;
  end;
end;

//Desc: �����ѯ
function TFDM.QuerySQL(const nSQL: string): TDataSet;
begin
  Result := SQLQuery;
  SQLQuery.Close;
  SQLQuery.SQL.Text := nSQL;
  SQLQuery.Open;
end;

//Desc: ��ʱ��ѯ
function TFDM.QueryTemp(const nSQL: string): TDataSet;
begin
  Result := SQLTemp;
  SQLTemp.Close;
  SQLTemp.SQL.Text := nSQL;
  SQLTemp.Open;
end;

//Desc: ��nQueryִ��nSQL���
procedure TFDM.QueryData(const nQuery: TADOQuery; const nSQL: string);
var nBookMark: Pointer;
begin
  nQuery.DisableControls;
  nBookMark := nQuery.GetBookmark;
  try
    nQuery.Close;
    nQuery.SQL.Text := nSQL;
    nQuery.Open;

    if nQuery.BookmarkValid(nBookMark) then
      nQuery.GotoBookmark(nBookMark);
  finally
    nQuery.FreeBookmark(nBookMark);
    nQuery.EnableControls;
  end;
end;

//------------------------------------------------------------------------------
procedure TFDM.DataModuleCreate(Sender: TObject);
begin
  {$IFDEF UseReport}
  FDR := TFDR.Create(Self.Owner);
  {$ENDIF}

  {$IFDEF cxLookupCombox}
  gLookupComboBoxAdapter := TLookupComboBoxAdapter.Create(ADOConn);
  {$ENDIF}
end;

end.