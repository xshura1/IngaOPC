unit Main;   // ModBus

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
    

    fOnRts:boolean;


    fListResult:TList;




    procedure PortIni(DelayRead:integer);
    function CalcCRC(Arr:TBuff; Len:cardinal):word;
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
 CommDCB.Flags:=$3004;

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
   fDelayRead:=ini.ReadInteger('Port','DelayRead',2000);

   fOnRts:=ini.ReadBool('Port','OnRts',false);
 finally
  ini.free;
 end;
end;













function TComPort.CalcCRC(Arr:TBuff; Len:cardinal):word;
  const
  CRC_Hi:array [0..255] of byte=( $00, $C1, $81, $40, $01, $C0, $80, $41,
                                  $01, $C0, $80, $41, $00, $C1, $81, $40,
                                  $01, $C0, $80, $41, $00, $C1, $81, $40,
                                  $00, $C1, $81, $40, $01, $C0, $80, $41,
                                  $01, $C0, $80, $41, $00, $C1, $81, $40,
                                  $00, $C1, $81, $40, $01, $C0, $80, $41,
                                  $00, $C1, $81, $40, $01, $C0, $80, $41,
                                  $01, $C0, $80, $41, $00, $C1, $81, $40,
                                  $01, $C0, $80, $41, $00, $C1, $81, $40,
                                  $00, $C1, $81, $40, $01, $C0, $80, $41,
                                  $00, $C1, $81, $40, $01, $C0, $80, $41,
                                  $01, $C0, $80, $41, $00, $C1, $81, $40,
                                  $00, $C1, $81, $40, $01, $C0, $80, $41,
                                  $01, $C0, $80, $41, $00, $C1, $81, $40,
                                  $01, $C0, $80, $41, $00, $C1, $81, $40,
                                  $00, $C1, $81, $40, $01, $C0, $80, $41,
                                  $01, $C0, $80, $41, $00, $C1, $81, $40,
                                  $00, $C1, $81, $40, $01, $C0, $80, $41,
                                  $00, $C1, $81, $40, $01, $C0, $80, $41,
                                  $01, $C0, $80, $41, $00, $C1, $81, $40,
                                  $00, $C1, $81, $40, $01, $C0, $80, $41,
                                  $01, $C0, $80, $41, $00, $C1, $81, $40,
                                  $01, $C0, $80, $41, $00, $C1, $81, $40,
                                  $00, $C1, $81, $40, $01, $C0, $80, $41,
                                  $00, $C1, $81, $40, $01, $C0, $80, $41,
                                  $01, $C0, $80, $41, $00, $C1, $81, $40,
                                  $01, $C0, $80, $41, $00, $C1, $81, $40,
                                  $00, $C1, $81, $40, $01, $C0, $80, $41,
                                  $01, $C0, $80, $41, $00, $C1, $81, $40,
                                  $00, $C1, $81, $40, $01, $C0, $80, $41,
                                  $00, $C1, $81, $40, $01, $C0, $80, $41,
                                  $01, $C0, $80, $41, $00, $C1, $81, $40);

  CRC_Lo:array [0..255] of byte=( $00, $C0, $C1, $01, $C3, $03, $02, $C2,
                                  $C6, $06, $07, $C7, $05, $C5, $C4, $04,
                                  $CC, $0C, $0D, $CD, $0F, $CF, $CE, $0E,
                                  $0A, $CA, $CB, $0B, $C9, $09, $08, $C8,
                                  $D8, $18, $19, $D9, $1B, $DB, $DA, $1A,
                                  $1E, $DE, $DF, $1F, $DD, $1D, $1C, $DC,
                                  $14, $D4, $D5, $15, $D7, $17, $16, $D6,
                                  $D2, $12, $13, $D3, $11, $D1, $D0, $10,
                                  $F0, $30, $31, $F1, $33, $F3, $F2, $32,
                                  $36, $F6, $F7, $37, $F5, $35, $34, $F4,
                                  $3C, $FC, $FD, $3D, $FF, $3F, $3E, $FE,
                                  $FA, $3A, $3B, $FB, $39, $F9, $F8, $38,
                                  $28, $E8, $E9, $29, $EB, $2B, $2A, $EA,
                                  $EE, $2E, $2F, $EF, $2D, $ED, $EC, $2C,
                                  $E4, $24, $25, $E5, $27, $E7, $E6, $26,
                                  $22, $E2, $E3, $23, $E1, $21, $20, $E0,
                                  $A0, $60, $61, $A1, $63, $A3, $A2, $62,
                                  $66, $A6, $A7, $67, $A5, $65, $64, $A4,
                                  $6C, $AC, $AD, $6D, $AF, $6F, $6E, $AE,
                                  $AA, $6A, $6B, $AB, $69, $A9, $A8, $68,
                                  $78, $B8, $B9, $79, $BB, $7B, $7A, $BA,
                                  $BE, $7E, $7F, $BF, $7D, $BD, $BC, $7C,
                                  $B4, $74, $75, $B5, $77, $B7, $B6, $76,
                                  $72, $B2, $B3, $73, $B1, $71, $70, $B0,
                                  $50, $90, $91, $51, $93, $53, $52, $92,
                                  $96, $56, $57, $97, $55, $95, $94, $54,
                                  $9C, $5C, $5D, $9D, $5F, $9F, $9E, $5E,
                                  $5A, $9A, $9B, $5B, $99, $59, $58, $98,
                                  $88, $48, $49, $89, $4B, $8B, $8A, $4A,
                                  $4E, $8E, $8F, $4F, $8D, $4D, $4C, $8C,
                                  $44, $84, $85, $45, $87, $47, $46, $86,
                                  $82, $42, $43, $83, $41, $81, $80, $40 );
  var hi,lo:byte;
      i,index:integer;
  begin
   hi:=$FF; lo:=$FF;
   for i:=0 to Len-1 do
    begin
     index:=hi xor Arr[i];
     hi:=lo xor crc_hi[index];
     lo:=crc_lo[index];
    end;
   result:=makeword(lo,hi);

  end;





function TComPort.Write(ppDriverData: pDriverData): HResult;
var  nw,nr,EvtMask:dword;
     i:integer;
     pDD:pDriverData;
     pw,pr:TBuff;
     crc:word;
     res:dword;
begin
 
 res:=0;
 if hComm<>Invalid_Handle_Value then
   begin
        fillchar(pw,sizeof(pw),0);
        fillchar(pr,sizeof(pr),0);

        pw[0]:=strtoint(string(ppDriverData^.szAddress));
        pw[1]:=strtoint(string(ppDriverData^.szNoCommand));
        for i:=0 to ppDriverData^.dwDataSize-1 do pw[i+2]:=ppDriverData^.pData^[i];

        crc:=CalcCRC(pw,ppDriverData^.dwDataSize+2);
        pw[ppDriverData^.dwDataSize+2]:=HiByte(crc);
        pw[ppDriverData^.dwDataSize+3]:=LoByte(crc);


      //  PortIni(fDelayRead);

        nw:=0; nr:=0;
        WriteFile(hComm,PW,ppDriverData^.dwDataSize+4,nw,nil);

        sleep(1);

        if ppDriverData^.dwDataSize+4<>nw then
          begin
           PurgeComm(hComm,PURGE_TXCLEAR or PURGE_RXCLEAR);
           res:=1;
          end
        else
          begin
            WaitCommEvent(hComm,EvtMask,nil);
            ReadFile(hComm,PR,255,nr,nil);
            sleep(1);
            PurgeComm(hComm,PURGE_TXCLEAR or PURGE_RXCLEAR);
          end;

        if nr<=3 then
         res:=1
        else
         begin
          crc:=CalcCRC(pr,nr-2);
          if crc<>makeword(pr[nr-1],pr[nr-2]) then
           res:=1;
         end;
   end
  else
   res:=2;

 pdd:=coTaskMemAlloc(sizeof(DriverData));
 fillchar(pdd^,sizeof(DriverData),0);
 pdd^.Handle:=ppDriverData^.Handle;
 pdd^.Param:=ppDriverData^.Param;
 pdd^.Result:=res;
 if res=0 then
  begin
   pdd^.dwDataSize:=nr-4;
   pdd^.pData:=coTaskMemAlloc(pdd^.dwDataSize);
   for i:=0 to pdd^.dwDataSize-1 do
    pdd^.pData^[i]:=pr[i+2];
  end;

 result:=s_ok;
 fListResult.Add(pdd);
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

initialization
   IniName:=ChangeFileExt(GetModuleFileNameStr(HInstance,true), '.INI');
   Co:=TComport.Create;


end.
