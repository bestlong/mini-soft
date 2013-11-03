{*******************************************************************************
  ����: dmzn@163.com 2013-10-28
  ����: ������Ļ����
*******************************************************************************}
unit UFormProgress;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs;

type
  TfFormProgress = class(TForm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure ShowProgressForm(const nHint: string);
procedure CloseProgressForm;
//��ں���

implementation

{$R *.dfm}

uses UFormWait;

var
  gForm: TfFormProgress = nil;

procedure ShowProgressForm(const nHint: string);
begin
  if not Assigned(gForm) then
    gForm := TfFormProgress.Create(nil);
  //xxxxx

  gForm.Show;
  gForm.Activate;
  ShowWaitForm(gForm, nHint);
end;

procedure CloseProgressForm;
begin
  CloseWaitForm;
  gForm.Free;
  gForm := nil; 
end;

end.
