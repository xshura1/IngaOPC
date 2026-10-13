unit Main;   // ModBus

interface
 uses  SysUtils, Classes,  windows,  Dialogs,inifiles, intf;
 type


  TIngaDrv=class
   private
    { Private declarations }
    fListResult:TList;
   public
    constructor Create;
    destructor Destroy; override;

    function OpenDrv:HResult;
    function CloseDrv:HResult;

    function Write(ppDriverData:pDriverData):HResult;
    function Read(out ppDriverData:pDriverData):HResult;
   end;




 var IngaDrv:TIngaDrv;
  //   IniName:shortstring;
implementation
 uses ActiveX,comobj;


{
function GetModuleFileNameStr(Instance: THandle; FullPath:boolean): String;
var
  buffer : array [0..MAX_PATH] of Char;
  i:integer;
  s:string;
begin
  GetModuleFileName( Instance, buffer, MAX_PATH);
  s := buffer;
  result:=s;
  if FullPath then exit;
  result:='';
  for i:=length(s) downto 1 do
   if s[i]<>'\' then
    result:=s[i]+result
   else
    break;

end;
 }


constructor TIngaDrv.Create;
begin
 inherited;
 fListResult:=TList.Create;
end;

destructor TIngaDrv.Destroy;
begin
  fListResult.Free;
  inherited;
end;


function TIngaDrv.Write(ppDriverData: pDriverData): HResult;
var pdd:pDriverData;
begin


 pdd:=coTaskMemAlloc(sizeof(DriverData));
 fillchar(pdd^,sizeof(DriverData),0);
 pdd^.Handle:=ppDriverData^.Handle;
 pdd^.Param:=ppDriverData^.Param;
 pdd^.Result:=0;
 result:=s_ok;
 fListResult.Add(pdd);
end;

function TIngaDrv.Read(out ppDriverData:pDriverData):HResult;
begin
 ppDriverData:=nil;
 result:=s_false;
 if fListResult.Count=0 then exit;
 ppDriverData:=fListResult[0];
 fListResult.Delete(0);
 result:=s_ok;
end;

function TIngaDrv.CloseDrv: HResult;
begin
 result:=s_ok;
end;

function TIngaDrv.OpenDrv: HResult;
begin
 result:=s_ok;
end;

initialization
   IngaDrv:=TIngaDrv.Create;


end.
