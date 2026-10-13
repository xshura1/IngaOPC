library ver101;


uses
  SysUtils,
  Classes,
  windows,
  Dialogs,
  inifiles,
  USharedClass in '..\..\SharedUnit\USharedClass.pas',
  UComPort in 'UComPort.pas',
  USetup in 'USetup.pas' {fmSetup};

const
   NoVer=101;


{$R *.RES}


function InfoDll:TInfoDllItem;  stdcall;
var ini:TIniFile;
begin
 ini:=TIniFile.Create(Ininame);
 try
  result.Description:='Ñâÿçü TCP';
  result.NoVer:=101;
  result.Param:=ini.ReadInteger('TCP','Port',33002);
 finally
  ini.Free;
 end;
end;

 exports
  InfoDll,
  StartStopDevice,
  GetPaket,
  ShowSetup,
  SetLogging,
  InitDRV;
begin

end.
