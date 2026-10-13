unit HA_About;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ShellApi;

type
  TfmAbout = class(TForm)
    Label1: TLabel;
    Image1: TImage;
    Label6: TLabel;
    Label7: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label4: TLabel;
    Button1: TButton;
    Bevel1: TBevel;
    Label9: TLabel;
    procedure Label4Click(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure WMNCHitTest(var M: TWMNCHitTest); message wm_NCHitTest;

  public
    { Public declarations }
  end;


implementation

{$R *.DFM}
{$I IngaOPC.inc}

procedure TfmAbout.Label4Click(Sender: TObject);
begin

// ShellExecute(Application.Handle,'open','mailto:xshura@integralplus.ru',nil,nil,0);
end;

procedure TfmAbout.Label5Click(Sender: TObject);
var res:THandle;
begin
 res:= ShellExecute(Application.Handle,'open','http://www.integralplus.ru',nil,nil,0);
 if res<>0 then
  showmessage(inttostr(res));
end;

procedure TfmAbout.FormCreate(Sender: TObject);
var
 sAppName,s:string;
 pcBuf,pcValue: PChar;
 iAppSize,iLenOfValue:DWord;
begin

 sAppName := Application.ExeName;
 iAppSize:= GetFileVersionInfoSize(PChar(sAppName),iAppSize);
 if iAppSize > 0 then
  begin
   pcBuf := AllocMem(iAppSize);
   GetFileVersionInfo(PChar(sAppName),0,iAppSize,pcBuf);
    VerQueryValue(pcBuf,PChar('\\StringFileInfo\\041904E3\\FileVersion'), Pointer(pcValue),iLenOfValue);
  end;
  s:=pcValue;
 // s:=copy(s,1,length(s)-4);
  Label7.Caption:='Версия '+s;
  FreeMem(pcBuf,iAppSize);
  {$IFDEF DEMOVERSION}
  label1.caption:='IngaOPC Server Демо';
//  label8.Caption:='макс. кол-во точек в/в - 24';
  {$ELSE}
  label1.Caption:='IngaOPC Server';
 // label8.Caption:='';
  {$ENDIF}
end;

procedure TfmAbout.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 Action:=caFree;
end;

procedure TfmAbout.WMNCHitTest(var M: TWMNCHitTest);
begin
 inherited;
 if M.Result = htClient then
  M.Result := htCaption;
end;

end.
