unit MainCOM;   // "прозрачный" драйвер для COM порта

interface
 uses  SysUtils, Classes,  windows,  Dialogs,inifiles, intf;
 type
  TBuff=array [0..255] of byte;

  TComPort=class
   private
    { Private declarations }
    hComm:THandle;
    fPort:string;
    fBaud:dword;
    fByte:byte;
    fParity:byte;
    fStopBits:byte;
    fDelayRead:integer;
    fCountWrite:integer;
    fInModem:boolean;

    fOnRts:boolean;
    fEnableLog:boolean;

    fListResult:TList;




    procedure PortIni(DelayRead:integer);


    procedure SetLog(IsWrite:boolean; Buff:TBuff; Count:dword);
   public
    constructor Create;
    Destructor Destroy; override;
    function OpenPort:HResult;
    function ClosePort:HResult;
    procedure ResetPort;


    function Write(ppDriverData:pDriverData):HResult;
    function Read(out ppDriverData:pDriverData):HResult;




   end;




 var Co:TComPort;
     IniName:shortstring;
implementation
 uses ActiveX,comobj;



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




function TComPort.ClosePort:HResult;
begin
  if (hComm>0) and (hComm<>Invalid_Handle_Value) then
   begin
    PurgeComm(hComm,PURGE_TXCLEAR or PURGE_RXCLEAR);
    CloseHandle(hComm);
   end;
  hComm:=0;
  result:=s_ok;
end;

constructor TComPort.Create;
begin
 inherited;
 fListResult:=TList.Create;
 ResetPort;
end;

destructor TComPort.Destroy;
begin
  ClosePort;
  fListResult.Free;
  inherited;
end;



function TComPort.OpenPort:HResult;
begin
 ClosePort;
 ResetPort;
 hComm:=CreateFile(PCHAR(fPort),
                      GENERIC_READ or  GENERIC_WRITE,
                      0,
                      nil,
                      OPEN_EXISTING,
                      FILE_ATTRIBUTE_NORMAL,
                      0);
  result:=s_ok;
  PortIni(fDelayRead);
end;



procedure TComPort.PortIni(DelayRead: integer);
var
 CommDCB:TDCB;
 DTime:TCommTimeouts;
begin
 if (hComm<=0) or (hComm=Invalid_Handle_Value) then
   exit;


 GetCommState(hComm,CommDCB);
 //CommDCB.Flags:=$3004;//$1011

// CommDCB.Flags:=CommDCB.flags and $CFCF ;
// CommDCB.flags:=CommDCB.flags or $3003 ;

 CommDCB.Parity:=fPARITY;
 CommDCB.BaudRate:=fBaud;
 CommDCB.ByteSize:=fByte;
 CommDCB.StopBits:=fStopBits;
 if SetCommState(hComm,CommDCB) then
  begin
    GetCommTimeouts(hComm,DTime);
    DTime.ReadIntervalTimeout:=100;
    DTime.ReadTotalTimeoutMultiplier:=0;
    DTime.ReadTotalTimeoutConstant:=DelayRead;
    DTime.WriteTotalTimeoutMultiplier:=0;
    DTime.WriteTotalTimeoutConstant:=500;
    SetCommTimeouts(hComm,DTime);
    SetupComm(hComm,90,90);
    SetCommMask(hComm,EV_TXEMPTY);
  end;
end;





procedure TComPort.ResetPort;
var ini:TIniFile;
begin

 ini:=TIniFile.Create(IniName);
 try
   fPort:=ini.ReadString('Port','Port','COM1');
   fBaud:=ini.ReadInteger('Port','Baud',19200);
   fByte:=ini.ReadInteger('Port','Byte',8);
   fParity:=ini.ReadInteger('Port','Parity',0);
   fStopBits:=ini.ReadInteger('Port','StopBits',2);
   fDelayRead:=ini.ReadInteger('Port','DelayRead',2000);
   fCountWrite:=ini.ReadInteger('Port','CountWrite',1);
   fInModem:=ini.ReadBool('Port','InModem',true);
   fEnableLog:=ini.ReadBool('Port','EnableLog',false);
   fOnRts:=ini.ReadBool('Port','OnRts',false);
 finally
  ini.free;
 end;
end;















function TComPort.Write(ppDriverData: pDriverData): HResult;
var  nw,nr,EvtMask,size,fiCRC:dword;
     i:integer;
     pDD:pDriverData;
     pw,pr:TBuff;
     res:dword;
     s:string;
     IsGroup:boolean;
begin

 res:=1;
 try
  if hComm<>Invalid_Handle_Value then
   begin
        for i:=0 to ppDriverData^.dwDataSize-1 do
         pw[i]:=ppDriverData^.pData[i];

        for i:=0 to fCountWrite-1 do
         begin
            nw:=0; nr:=0;
            PurgeComm(hComm,PURGE_TXCLEAR or PURGE_RXCLEAR);
            WriteFile(hComm,pw,ppDriverData^.dwDataSize,nw,nil);
            SetLog(true,PW,nw);

            sleep(1);
            if ppDriverData^.dwDataSize<>nw then
             begin
              PurgeComm(hComm,PURGE_TXCLEAR or PURGE_RXCLEAR);
              break;
             end
            else
              begin
                WaitCommEvent(hComm,EvtMask,nil);
                ReadFile(hComm,PR,High(PR)+1,nr,nil);
                SetLog(false,PR,nr);
                sleep(1);
                PurgeComm(hComm,PURGE_TXCLEAR or PURGE_RXCLEAR);
                if nr>0 then
                 res:=0;
                if nr>0 then break;
              end;
         end;
   end
  else
   res:=2;

 finally
   pdd:=coTaskMemAlloc(sizeof(DriverData));
   fillchar(pdd^,sizeof(DriverData),0);
   pdd^.AddrDrv:=ppDriverData^.AddrDrv;
   pdd^.Handle:=ppDriverData^.Handle;
   pdd^.Param:=ppDriverData^.Param;
   pdd^.Result:=res;
   if res=0 then
    begin
     pdd^.dwDataSize:=nr;
     pdd^.pData:=coTaskMemAlloc(pdd^.dwDataSize);
     for i:=0 to pdd^.dwDataSize-1 do
      pdd^.pData^[i]:=pr[i];
    end;

   result:=s_ok;
   fListResult.Add(pdd);
 end;
end;

function TComPort.Read(out ppDriverData:pDriverData):HResult;
begin
 ppDriverData:=nil;
 result:=s_false;

 if fListResult.Count=0 then exit;
 ppDriverData:=fListResult[0];
 fListResult.Delete(0);
 result:=s_ok;
end;


procedure TComPort.SetLog(IsWrite: boolean; Buff: TBuff; Count: dword);
const
 M='%s %s %s(%d)';

var F:TextFile;
    fFileName,sw,sd:string;
    IOError,i :integer;
begin
  if not fEnableLog then exit;
  fFileName:=ChangeFileExt(GetModuleFileNameStr(HInstance,true), '.logdrv');
  AssignFile(F, fFileName);
  if FileExists(fFileName) then
   Append(F)
  else
   Rewrite(F);

  IOError := IOResult;
  if IOError = 0 then
   begin
     if IsWrite then
      sw:='w'
     else
      sw:='r';

     sd:='';
     for i:=0 to count-1 do
      sd:=sd+' '+inttohex(Buff[i],2);

     WriteLN(f,format(m,[sw,formatdatetime('hh:nn:ss:zzz',now),sd,count]));
     IOError := IOResult;
   end;
  CloseFile(F);
end;

initialization
   IniName:=ChangeFileExt(GetModuleFileNameStr(HInstance,true), '.INI');
   Co:=TComport.Create;


end.
