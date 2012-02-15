{*******************************************************************************
  ����: dmzn@ylsoft.com 2007-11-20
  ����: ���ϵͳ�˵�����Ԫ

  Լ��:
  &.TMenuItemData.FFlag
   1.�ñ�������趨�˵����һЩ��Ϊ,��������"|"���ָ��һ���ʶ.
   2.NB:��ʶ�ò˵�����ʾ��Navbar��������
*******************************************************************************}
unit USysMenu;

interface

uses
  Windows, Classes, DB, SysUtils, UMgrMenu, ULibFun, USysConst, USysPopedom,
  UDataModule;

const
  cMenuFlag_SS   = '|';        //�ָ��,Split Symbol
  cMenuFlag_NB   = 'NB';       //��ʾ�ڵ�������,Navbar
  cMenuFlag_NSS  = '_';        //�ָ���,Name Split Symbol

type
  TMenuManager = class(TBaseMenuManager)
  protected
    function QuerySQL(const nSQL: string;
      var nDS: TDataSet; var nAutoFree: Boolean): Boolean; override;
    {*��ѯ*}
    function ExecSQL(const nSQL: string): integer; override;
    {*ִ��д����*}

    function GetItemValue(const nItem: integer): string; override;
    function IsTableExists(const nTable: string): Boolean; override;
    {*��ѯ��*}
  public
    function MenuName(const nEntity,nMenuID: string): string;
    {*�����˵���*}
  end;

var
  gMenuManager: TMenuManager = nil;
  //ȫ�ֲ˵�������

implementation

//------------------------------------------------------------------------------
//Desc: ִ��SQL���
function TMenuManager.ExecSQL(const nSQL: string): integer;
begin
  FDM.Command.Close;
  FDM.Command.SQL.Text := nSQL;
  Result := FDM.Command.ExecSQL;
end;

//Desc: ���nTable���Ƿ����
function TMenuManager.IsTableExists(const nTable: string): Boolean;
var nList: TStrings;
begin
  nList := TStringList.Create;
  try
    FDM.ADOConn.GetTableNames(nList);
    Result := nList.IndexOf(nTable) > -1;
  finally
    nList.Free;
  end;
end;

//Desc: ִ��SQL��ѯ
function TMenuManager.QuerySQL(const nSQL: string; var nDS: TDataSet;
  var nAutoFree: Boolean): Boolean;
begin
  FDM.SQLQuery.Close;
  FDM.SQLQuery.SQL.Text := nSQL;
  FDM.SQLQuery.Open;

  nDS := FDM.SQLQuery;
  Result := nDS.RecordCount > 0;
end;

//Desc: ����ʵ��nEntity��nMenuID�˵�����齨����
function TMenuManager.MenuName(const nEntity, nMenuID: string): string;
begin
  Result := nEntity + cMenuFlag_NSS + nMenuID;
end;

function TMenuManager.GetItemValue(const nItem: integer): string;
begin
  Result := gSysParam.FTableMenu;
end;

initialization
  gMenuManager := TMenuManager.Create;
finalization
  FreeAndNil(gMenuManager);
end.
