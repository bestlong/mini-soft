{*******************************************************************************
  ����: dmzn@163.com 2011-10-22
  ����: �м��ҵ�����ݷ������
*******************************************************************************}
unit UMITPacker;

interface

uses
  Windows, SysUtils, Classes, ULibFun, UBusinessPacker, UBusinessConst;

type
  TMITPackerBase = class(TBusinessPackerBase)
  protected
    procedure DoPackIn(const nData: Pointer); override;
    procedure DoUnPackIn(const nData: Pointer); override;
    procedure DoPackOut(const nData: Pointer); override;
    procedure DoUnPackOut(const nData: Pointer); override;
  end;

  TMITBusinessCommand = class(TMITPackerBase)
  protected
    procedure DoPackIn(const nData: Pointer); override;
    procedure DoUnPackIn(const nData: Pointer); override;
    procedure DoPackOut(const nData: Pointer); override;
    procedure DoUnPackOut(const nData: Pointer); override;
  public
    class function PackerName: string; override;
  end;

implementation

//Date: 2012-3-7
//Parm: ��������
//Desc: ����������nData�������
procedure TMITPackerBase.DoPackIn(const nData: Pointer);
begin
  inherited;
  
  with FStrBuilder,PBWDataBase(nData)^ do
  begin
    Values['Worker'] := PackerName;
    Values['MSGNO'] := PackerEncode(FMsgNo);
    Values['KEY']   := PackerEncode(FKey);

    PackWorkerInfo(FStrBuilder, FFrom, 'Frm');
    PackWorkerInfo(FStrBuilder, FVia, 'Via');
    PackWorkerInfo(FStrBuilder, FFinal, 'Fin');
  end;
end;

//Date: 2012-3-7
//Parm: �ַ�����
//Desc: ��nStr�������
procedure TMITPackerBase.DoUnPackIn(const nData: Pointer);
begin
  inherited;

  with FStrBuilder,PBWDataBase(nData)^ do
  begin
    PackerDecode(Values['MSGNO'], FMsgNO);
    PackerDecode(Values['KEY'], FKey);

    PackWorkerInfo(FStrBuilder, FFrom, 'Frm', False);
    PackWorkerInfo(FStrBuilder, FVia, 'Via', False);
    PackWorkerInfo(FStrBuilder, FFinal, 'Fin', False);
  end;
end;

//Date: 2012-3-7
//Parm: �ṹ����
//Desc: �Խṹ����nData�������
procedure TMITPackerBase.DoPackOut(const nData: Pointer);
begin
  inherited;

  with FStrBuilder,PBWDataBase(nData)^ do
  begin
    Values['Worker'] := PackerName;
    Values['Result'] := BoolToStr(FResult);
    Values['ErrCode'] := PackerEncode(FErrCode);
    Values['ErrDesc'] := PackerEncode(FErrDesc);

    PackWorkerInfo(FStrBuilder, FFrom, 'Frm');
    PackWorkerInfo(FStrBuilder, FVia, 'Via');
    PackWorkerInfo(FStrBuilder, FFinal, 'Fin');
  end;
end;

//Date: 2012-3-7
//Parm: �ַ�����
//Desc: ��nStr�������
procedure TMITPackerBase.DoUnPackOut(const nData: Pointer);
begin
  inherited;

  with FStrBuilder,PBWDataBase(nData)^ do
  begin
    if Values['Result'] = '' then
         FResult := False
    else FResult := StrToBool(Values['Result']);
    
    PackerDecode(Values['ErrCode'], FErrCode);
    PackerDecode(Values['ErrDesc'], FErrDesc);

    PackWorkerInfo(FStrBuilder, FFrom, 'Frm', False);
    PackWorkerInfo(FStrBuilder, FVia, 'Via', False);
    PackWorkerInfo(FStrBuilder, FFinal, 'Fin', False);
  end; 
end;

//------------------------------------------------------------------------------
class function TMITBusinessCommand.PackerName: string;
begin
  Result := sBus_BusinessCommand;
end;

procedure TMITBusinessCommand.DoPackIn(const nData: Pointer);
begin
  inherited;

  with FStrBuilder,PWorkerBusinessCommand(nData)^ do
  begin
    Values['Command'] := IntToStr(FCommand);
    Values['Data']    := PackerEncode(FData);
  end;
end;

procedure TMITBusinessCommand.DoUnPackIn(const nData: Pointer);
begin
  inherited;

  with FStrBuilder,PWorkerBusinessCommand(nData)^ do
  begin
    PackerDecode(Values['Command'], FCommand);
    PackerDecode(Values['Data'], FData);
  end;
end;

procedure TMITBusinessCommand.DoPackOut(const nData: Pointer);
begin
  inherited;

  with FStrBuilder,PWorkerBusinessCommand(nData)^ do
  begin
    Values['Command'] := IntToStr(FCommand);
    Values['Data']    := PackerEncode(FData);
  end;
end;

procedure TMITBusinessCommand.DoUnPackOut(const nData: Pointer);
begin
  inherited;

  with FStrBuilder,PWorkerBusinessCommand(nData)^ do
  begin
    PackerDecode(Values['Command'], FCommand);
    PackerDecode(Values['Data'], FData);
  end;
end;

initialization
  gBusinessPackerManager.RegistePacker(TMITBusinessCommand);
end.
