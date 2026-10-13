unit HA_fmUnloader;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,ha_opcman, ComCtrls, StdCtrls,ha_fmGlobalParams;

type
  TfmUnloader = class(TForm)
    PB: TProgressBar;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function UnloadClients(H:THandle):boolean;

implementation

{$R *.dfm}

function UnloadClients(H:THandle):boolean;
var CountAll,CountY,CountN:integer;
    j,TimeOut:dword;
    s:string;
begin
 result:=true;
 if OPCMan=nil then exit;
 OPCMan.CacheDebugMode:=cdm_Normal;

 CountAll:=OPCMan.CountServers;
 if CountAll=0 then exit;
 if CountAll=1 then
  s:='Отключить клиента ?'
 else
  s:='Отключить всех клиентов ?';

 if MessageBox(h,PChar(s),PChar(Application.Title) ,MB_YESNO or MB_ICONQUESTION or MB_APPLMODAL)=IDNO	then
  begin
   result:=false;
   exit;
  end;

 CountN:=OPCMan.CountServersWithNotIOPCShutdown;
 CountY:=CountALL-CountN;
 with TfmUnloader.Create(application) do
  try
   PB.Max:=CountAll;
   PB.Position:=0;
   show;
   OPCMan.ShutDownServer(0,false);
   j:=0;
   TimeOut:=GlobalParams.IOPCShutdown_TimeOut;
   while (OPCMan.CountServers>CountN) and (j<=TimeOut) do
    begin
     sleep(100);
     inc(j,100);
     PB.Position:=PB.Max-OPCMan.CountServers;
     Application.ProcessMessages;
    end;

   if OPCMan.CountServers=0 then exit;

   OPCMan.ShutDownServer(0,true);
   j:=0;
   while (OPCMan.CountServers>0) and (j<=TimeOut) do
    begin
     sleep(100);
     inc(j,100);
     PB.Position:=PB.Max-OPCMan.CountServers;
     Application.ProcessMessages;
    end;

  finally
   Close;

  end;
end;


end.
