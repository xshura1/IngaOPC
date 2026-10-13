unit UComPort;   // gorsvet

interface
 uses  SysUtils, Classes,  windows,  Dialogs,inifiles, intf;
 type
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
    fDelayRead1:integer;

    fOnRts:boolean;



    fListResult:TList;


    procedure PortIni(DelayRead:integer);
   public
    constructor Create;
    Destructor Destroy; override;

    function Write(ppDriverData:pDriverData):HResult;
    function Read(out ppDriverData:pDriverData):HResult;

    function OpenPort:HResult;
    function ClosePort:HResult;
    procedure ResetPort;


   end;




 var Co:TComPort;
     IniName:shortstring;
implementation
 uses ActiveX,comobj;

 type
  TBuff=array [0..255] of byte;


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
 ResetPort;
 ClosePort;
 hComm:=CreateFile(PCHAR(fPort),
                      GENERIC_READ or  GENERIC_WRITE,
                      0,
                      nil,
                      OPEN_EXISTING,
                      FILE_ATTRIBUTE_NORMAL,// or FILE_FLAG_OVERLAPPED,
                      0);
  result:=GetLastError;
//  result:=(hComm>0) and (hComm<>Invalid_Handle_Value);
  PortIni(fDelayRead);
end;



procedure TComPort.PortIni(DelayRead: integer);
var
CommDCB:TDCB;
DTime:TCommTimeouts;
begin
 if (hComm<=0) or (hComm=Invalid_Handle_Value) then
  begin
   sleep(100);
   exit;
  end;


 GetCommState(hComm,CommDCB);
 if fOnRts then
  CommDCB.Flags:=$3004
 else
  CommDCB.Flags:=$1011;
  
 CommDCB.Parity:=fPARITY;
 CommDCB.BaudRate:=fBaud;
 CommDCB.ByteSize:=fByte;
 CommDCB.StopBits:=fStopBits;
 SetCommState(hComm,CommDCB);
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
   fDelayRead:=ini.ReadInteger('Port','TimeOut',2000);
   fOnRts:=ini.ReadBool('Port','OnRts',false);
 finally
  ini.free;
 end;

end;
















function TComPort.Write(ppDriverData: pDriverData): HResult;
const
 maxCountBuff=255;

var  nw,nr,EvtMask:dword;
     i,j,len:integer;
     pDD:pDriverData;
     pw,pr:TBuff;
     crc:word;
     lenR,lenW:cardinal;
     res:dword;
     s,s1:string;

begin
  result:=s_ok;
  fillchar(pw,sizeof(pw),0);
  fillchar(pr,sizeof(pr),0);


  res:=2;

  // парсим маршрут и добавляем его в начало пакета
  s:=string(ppDriverData^.szAddress);
  len:=length(s);
  j:=0; s1:='';
  for i:=1 to len do
   if (s[i]<>'.') and (i<len) then
    s1:=s1+s[i]
   else
    begin
     if i=len then
      s1:=s1+s[i];
     try
      if j<=8 then
       pw[j]:=strtoint(s1)
      else
       pw[j+1]:=strtoint(s1);
     except
     end;
     inc(j);
     s1:='';
    end;


  pw[9]:=strtoint(string(ppDriverData^.szNoCommand));

  // вычисляем задержку на прием, в зависимости от кол-ва ретрансляторов в маршруте
  j:=1;
  for i:=1 to 6 do
   if pw[i]>0 then
    inc(j);


  // добавляем данные пришедшие от сервера в пакет
  for i:=0 to ppDriverData^.dwDataSize-1 do
    pw[i+11]:=ppDriverData^.pData^[i];

  LenW:=ppDriverData^.dwDataSize+11;

  PortIni(fDelayRead*j);

  nw:=0; nr:=0;


 // if hComm=Invalid_Handle_Value then exit;

  WriteFile(hComm,PW,lenW,nw,nil);
  sleep(1);
//nw:=len+4;
  if lenW<>nw then
   begin
    PurgeComm(hComm,PURGE_TXCLEAR or PURGE_RXCLEAR);



   end
  else
      begin
        WaitCommEvent(hComm,EvtMask,nil);
        ReadFile(hComm,PR,255,nr,nil);

        {if ((BitStat(Paket.RPaket[8],4)=0) and (BitStat(Paket.WPaket[8],4)=1)) or
              (BitStat(Paket.WPaket[8],4)=0) then
            Paket.Errors:=Paket.Errors or ON_Pak;

          if ((BitStat(Paket.RPaket[8],4)=1) and (BitStat(Paket.WPaket[8],4)=1)) or
              (BitStat(Paket.WPaket[8],4)=0) then}

        if nr>9 then
         begin
           res:=0;
         end
        else
         res:=1;

        sleep(1);
        PurgeComm(hComm,PURGE_TXCLEAR or PURGE_RXCLEAR);
      end;



     pdd:=coTaskMemAlloc(sizeof(DriverData));
     pdd^.Handle:=ppDriverData^.Handle;
     pdd^.szAddress:=nil;//stringtolpolestr(ppDriverData^.szAddress);
     pdd^.szNoCommand:=nil;//stringtolpolestr(ppDriverData^.szNoCommand);
     pdd^.Result:=res;
     pdd^.pData:=nil;

     if res=0 then
      begin
       pdd^.dwDataSize:=nr-11;
       pdd^.pData:=coTaskMemAlloc(pdd^.dwDataSize);
       for i:=0 to pdd^.dwDataSize-1 do
        pdd^.pData^[i]:=pr[i+11];
      end
     else
      pdd^.dwDataSize:=0;


 result:=s_ok;
 fListResult.Add(pdd);


end;

function TComPort.Read(out ppDriverData:pDriverData): HResult;
var i:integer;
begin
 ppDriverData:=nil;
 result:=s_false;
 if fListResult.Count=0 then exit;
 ppDriverData:=fListResult[0];
 fListResult.Delete(0);
 result:=s_ok;
end;

initialization
   IniName:=ChangeFileExt(GetModuleFileNameStr(HInstance,true), '.INI');
   Co:=TComport.Create;


end.
