unit UComPort;
 //ver101
interface
 uses  SysUtils, Classes,  windows,  Dialogs,inifiles, uSharedClass,IdTCPServer,haaes,DateUtils;
 type
  TCryptKey16=array [0..15] of byte;
  TComPort=class
   private
    { Private declarations }
    fChangedata:TChangeDrvData;
    fLogging:boolean;
    fTCPServer:TIdTCPServer;

    flagcommand:boolean;

    fTimeoutRead:dword;
    fTimeOutRead485:dword;
    fIntervalTCP:dword;
    fIntervalFullSost:dword;

    fTimeLoadData:TDateTime;
    fAutoLoadData:boolean;



    fKeys:TList;
    fKoloW:integer;
    fKoloR:integer;
    fOldKoloW:integer;
    fOldKoloR:integer;
   // fListOtvet:TList;

    // для аварийного канала
    hComm:THandle;
    fPort:string;
    fBaud:dword;
    fByte:byte;
    fParity:byte;
    fStopBits:byte;
    fDelayRead:integer;
    fDelayRead1:integer;
    fAddrforAlarmChannel:dword;
    fSignAlarm:word;
    fAlarm25Paket:TBuffPort;
    fAlarmYes25Paket:boolean;
    fAlarmTimeLimitSec:dword;
    fAlarmTimeWork:dword;

    procedure In_outPort(var Paket:TPaket);

    procedure In_OutAlarmChannel(var Paket:TPaket);
    procedure AlarmChannelIni(Delay1,Delay2:dword);

    function OpenAlarmChannel(Addr:dword):boolean;
    procedure CloseAlarmChannel;


    procedure SetLogging(ALogging:boolean);

    procedure SetInfoData(P:TBuffPort; Write:boolean;FI,Count:integer; CheckPaket:boolean=false);
    procedure SetStrInfoData(Str:string);

    procedure OnExecute(AThread: TIdPeerThread);
    procedure Onconnect(AThread: TIdPeerThread);
    procedure OnDisconnect(AThread: TIdPeerThread);
    procedure ExecCommand2(AThread: TIdPeerThread);
    function CheckPaket(Arr:TBuffPort; var FirstIndex:dword; out Len:dword):boolean;
    procedure ExecIntCommand(AThread: TIdPeerThread; B:TBuffPort; FI,Size:dword);
    procedure ExecExtCommand(AThread: TIdPeerThread; B:TBuffPort; FI,Size:dword);

    procedure SetKoloBytes(Write:boolean; Kolo:integer);


   public

    constructor Create;
    Destructor Destroy; override;
    function OpenPort:boolean;
    procedure ClosePort;
    function GetKeys(Addr:dword; var KeyFlash, KeyRom: string): boolean;
    function GetPhoneNumber(Addr:dword; NoAlarm:integer; var PhoneNumber:string):boolean;
    procedure InitDRV(PVState:PPVState);
   end;

 function StartStopDevice(Stop:boolean):boolean; export; stdcall;

 procedure InitDRV(PVState:PPVState); export; stdcall;

 function GetPaket(Paket:TPaket):TPaket; export; stdcall;
 procedure SetLogging(ALogging:boolean); export; stdcall;

 procedure EncryptPaket(const BI:TBuffPort; const CK:string; out BO:TBuffPort; out SizeO:dword);
 procedure DecryptPaket(const BI:TBuffPort; const FI,SizeI:dword; const CK:string; out BO:TBuffPort; out SizeO:dword);



 var Co:TComPort;
     IniName:shortstring;
implementation
   uses USetup,idglobal;

 const
  LenHeaderAndCRC=10;

 type

 {TAddrRec=record
  case byte of
   0: (dwAddr:dword);
   1: (bAddr:array [0..3] of byte);
 end; }

 PPVConnectRec=^TPVConnectRec;
 TPVConnectRec=record
   Address:dword;
   OldTimeFullSost:dword;
   OldLoadData:TDateTime;
   ExistsPaket27:boolean;
   Paket27:TBuffPort;            // текущее состояние контроллера
   PVPakets:array of TBuffPort;
 //  KeyFlash:string[16];
 //  KeyRom  :string[16];
 end;

 PPVKey=^TPVKey;
 TPVKey=record
  Address:dword;
  KeyFlash:TCryptKeyShort;
  KeyRom  :TCryptKeyShort;
  PN1     :TPhoneNumber;
  PN2     :TPhoneNumber;
 end;

 TPVConnectMan=class(TObject)
  private
   fConnections:TList;
   fAddr0:dword;
   fSign:word;
   fOldIntervalTCP:dword;
   function SearchPVConnectRec(Addr:dword):PPVConnectRec;
   procedure DeletePVPaket(PVC:PPVConnectRec; index:integer);
  public
   constructor Create;
   destructor Destroy; override;
   procedure AddPaket(Addr:dword; B:TBuffPort);
   function GetPaket(Addr:dword; NoComm:byte; out B:TBuffPort):boolean;
//   function GetKeys(Addr:dword; var KeyFlash,KeyRom:string):boolean;
   function RequestFullSost(Addr: dword):boolean;
   property Addr0:dword read fAddr0 write fAddr0;
 end;


procedure InitDRV(PVState:PPVState); export; stdcall;
begin
 if co=nil then exit;
 co.InitDRV(PVState);
end;


function TComPort.GetKeys(Addr:dword; var KeyFlash, KeyRom: string): boolean;
//const
// key:array [0..15] of byte=($2b,$7e,$15,$16,$28,$ae,$d2,$a6,$ab,$f7,$15,$88,$09,$cf,$4f,$3c);
var i:integer;
    s:string;
    p:PPVKey;
begin
 result:=false;
 p:=nil;
// p:=SearchPVConnectRec(Addr);
// if p=nil then exit;
 for i:=0 to fKeys.Count-1 do
  if TPVKey(fKeys[i]^).Address=Addr then
   begin
    p:=fKeys[i];
    break;
   end;

 if p=nil then exit;

 KeyFlash:='';
 KeyRom:='';

 for i:=0 to high(p^.KeyFlash) do
  KeyFlash:=KeyFlash+chr(p^.KeyFlash[i]);

 for i:=0 to high(p^.KeyRom) do
  KeyRom:=KeyRom+chr(p^.KeyRom[i]);


 result:=true;
end;


function StartStopDevice(Stop:boolean):boolean;  export; stdcall;
begin
 Result:=true;
 if not Stop then
  begin
  // Co:=TComPort.Create;
   result:=Co.OpenPort;
  end
 else
  begin
    Co.ClosePort;
   // Co.Free;
  end;
end;


function GetPaket(Paket:TPaket):TPaket;
begin
 if co=nil then exit;
 Co.In_outPort(Paket);
 result:=Paket;
end;

procedure SetLogging(ALogging:boolean);
begin
 if co=nil then exit;
 co.SetLogging(ALogging);
end;

function CalcCRC(Arr: TBuffPort; FirstIndex,
  EndIndex: cardinal): word;
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
   for i:=FirstIndex to EndIndex do
    begin
     index:=hi xor Arr[i];
     hi:=lo xor crc_hi[index];
     lo:=crc_lo[index];
    end;
   result:=makeword(lo,hi);
end;



function TComPort.CheckPaket(Arr: TBuffPort; var FirstIndex: dword;
  out Len: dword): boolean;
var crc:word;
    hi,lo,i,j,lendata,cbl:integer;
begin
 result:=false;
 {
 // for uncrypt paket
 while not result do
  begin
   Len:=0;
   if FirstIndex>High(Arr) then exit;
   j:=-1;
   for i:=FirstIndex to High(Arr) do
    if Arr[i]=$55 then
     begin
      j:=i;
      break;
     end;
   if j=-1 then break;
   if (j+LenHeaderAndCRC)>High(Arr) then exit;
  // lendata:=Arr[j+1];
   hi:=Arr[j+1]+(LenHeaderAndCRC-2)+j;
   lo:=Arr[j+1]+(LenHeaderAndCRC-1)+j;
   crc:=makeword(Arr[lo],Arr[hi]);
   result:=crc=CalcCRC(Arr,j,hi-1);
   FirstIndex:=j;
   Len:=Arr[j+1]+LenHeaderAndCRC;
   if not result then
    FirstIndex:=FirstIndex+1;
  end;
  }
 while not result do
  begin
   Len:=0;
   if FirstIndex>High(Arr) then exit;
   j:=-1;
   for i:=FirstIndex to High(Arr) do
    if Arr[i]=$55 then
     begin
      j:=i;
      break;
     end;
   if j=-1 then break;
   //if (j+LenHeaderAndCRC)>High(Arr) then exit;
   {cbl:=(Arr[j+1]+6) div 16;
   if cbl=0 then
    cbl:=1;
    }

   if BitStat(Arr[j+2],2)=1 then
    begin
     hi:=j+11+Arr[j+1];
     lo:=hi+1;
     crc:=makeword(Arr[lo],Arr[hi]);
     result:=crc=CalcCRC(Arr,j,hi-1);
     FirstIndex:=j;
     len:=11+Arr[j+1]+2;
     if not result then
      FirstIndex:=FirstIndex+1;
    end
   else
    begin
    // вычисляем кол-во блоков по 16 байт криптованного пакета
       cbl:=((Arr[j+1]+6) div 16);
       if ((Arr[j+1]+6) mod 16)>0 then
        cbl:=cbl+1;


      // lendata:=Arr[j+1];
       hi:=j+7+(cbl*16);//Arr[j+7+(cbl*16)];//+(LenHeaderAndCRC-2)+j;
       lo:=j+7+(cbl*16)+1;//Arr[j+7+(cbl*16)+1];//+(LenHeaderAndCRC-1)+j;
       crc:=makeword(Arr[lo],Arr[hi]);
       result:=crc=CalcCRC(Arr,j,hi-1);
       FirstIndex:=j;
       Len:=7+(cbl*16)+2;//Arr[j+1]+LenHeaderAndCRC;
       if not result then
        FirstIndex:=FirstIndex+1;
    end;
  end;


end;

procedure TComPort.ClosePort;
var i:integer;
begin
{ for i:=0 to fKeys.Count-1 do
  dispose(fKeys[i]);
 fKeys.Clear;  }

 try
 fTCPServer.Active:=false;
 except
 end;
// CloseAlarmChannel;
end;

constructor TComPort.Create;
begin
 inherited;
// fListOtvet:=TList.Create;
 fChangedata:=GetProcAddress(GetModuleHandle(nil),'DrvInfo');
 fTCPServer:=TIdTCPServer.Create(nil);
 fTCPServer.OnExecute:=OnExecute;
 fTCPServer.OnConnect:=Onconnect;
 fTCPServer.OnDisconnect:=OnDisconnect;
 randomize;
 flagcommand:=false;
 fKeys:=TList.Create;
 fKoloW:=0;
 fKoloR:=0;
 fOldKoloR:=0;
 fOldKoloW:=0;

end;

destructor TComPort.Destroy;
var i:integer;
begin
//  ClosePort;
{  for i:=0 to fListOtvet.Count-1 do
   Dispose(fListOtvet[i]);
  fListOtvet.Free;}
  for i:=0 to fKeys.Count-1 do
  dispose(fKeys[i]);
 fKeys.Clear;
 fKeys.Free;
 CloseAlarmChannel;
  inherited;
end;


procedure EncryptPaket(const BI:TBuffPort; const CK:string; out BO:TBuffPort; out SizeO:dword);
var bc:array [0..15] of byte;
    bout:array [0..15] of byte;
//    bo:TBuffPort;
    i,ii,cbl,j,ei:integer;
    ac:TAesContext;
    crc:word;
begin
{ i:=strtoint(Edit1.Text);
 j:=i div 16;
 k:=i mod 16;
 if k>0 then
  j:=j+1;}


 fillchar(bo,sizeof(bo),0);
 sizeo:=0;
 for i:=0 to 6 do bo[i]:=bi[i];

 // вычисляем кол-во блоков по 16 байт криптованного пакета
 cbl:=((bi[1]+6) div 16);
 if ((bi[1]+6) mod 16)>0 then
  cbl:=cbl+1;

 j:=7;
 i:=aes_set_encrypt_key(PChar(ck),16,ac);

 // криптуем по блокам
 for i:=0 to cbl-1 do
  begin
   for ii:=0 to 15 do
    bc[ii]:=bi[ii+j];
   aes_encrypt_block(bc,bout,ac);
   for ii:=0 to 15 do
    bo[ii+j]:=bout[ii];
   inc(j,16);
  end;

 // вычисляем конечный индекс шифрованного пакета
 ei:=7+(cbl*16)-1;
 crc:=CalcCRC(bo,0,ei);
 bo[ei+1]:=HiByte(crc);
 bo[ei+2]:=LoByte(crc);
 SizeO:=ei+3;
// bo[2]:=bo[2] or $40;
// bo[2]:=BitSet(bo[2],6,1);
end;

procedure DecryptPaket(const BI:TBuffPort; const FI,SizeI:dword; const CK:string; out BO:TBuffPort; out SizeO:dword);
var bc:array [0..15] of byte;
    bout:array [0..15] of byte;
    i,ii,cbl,j,ei:integer;
    ac:TAesContext;
    crc:word;
begin
 fillchar(bo,sizeof(bo),0);
 sizeo:=0;
 
 for i:=0 to 6 do bo[i]:=bi[FI+i];

 // вычисляем кол-во блоков по 16 байт криптованного пакета
 cbl:=((bi[FI+1]+6) div 16);
 if ((bi[FI+1]+6) mod 16)>0 then
  cbl:=cbl+1;

 j:=FI+7;
 i:=aes_set_decrypt_key(PChar(ck),16,ac);

 for i:=0 to cbl-1 do
  begin
   for ii:=0 to 15 do
    bc[ii]:=bi[ii+j];
   aes_decrypt_block(bc,bout,ac);
   for ii:=0 to 15 do
    bo[ii+j-FI]:=bout[ii];
   inc(j,16);
  end;

 SizeO:=bo[1]+7+6;

end;


procedure TComPort.ExecCommand2(AThread: TIdPeerThread);
var bw,bo:TBuffPort;
    crc:word;
    i,j:integer;
    fi,len:dword;
   // ar:TAddrRec;
    b:byte;
    fl:boolean;
    kf,kr:string;
begin
 fillchar(bw,sizeof(TBuffPort),0);
 bw[0]:=$55;
 bw[1]:=0;
 bw[2]:=$4;
 bw[7]:=2;


 bw[8]:=0;//random(255);
 bw[9]:=0;
 bw[10]:=0;
 crc:=CalcCrc(bw,0,10);
 bw[11]:=hiByte(crc);
 bw[12]:=loByte(crc);

// TPVConnectMan(AThread.Data).
 //GetKeys(0,kf,kr);

 //EncryptPaket(bw,kf,bo,len);

 SetInfoData(bw,true,0,13);
 //SetInfoData(bo,true,0,len);

 AThread.Connection.WriteBuffer(bw,13);
 SetKoloBytes(true,13);

end;

procedure TComPort.ExecExtCommand(AThread: TIdPeerThread; B: TBuffPort; FI,
  Size: dword);
var no:byte;
   // ar:TAddrRec;
    br:TBuffPort;
    i:integer;
    kf,kr:string;
    sizeo,Addr:dword;
    crc,sign,hiAddr,loAddr:word;
begin
// if ((b[fi+2] shr 1) and 1)=1 then exit;
 Addr:=0;
 loAddr:=makeword(b[fi+6],b[fi+5]);
 hiAddr:=makeword(b[fi+4],b[fi+3]);
 Addr:=makelong(loAddr,hiAddr);

// for i:=0 to 3 do ar.bAddr[i]:=b[i+3+fi];
 Fillchar(br,sizeof(br),0);
 {for i:=0 to size-1 do
  br[i]:=B[i+fi];
  }
// TPVConnectMan(AThread.Data).
 GetKeys(Addr,kf,kr);
 DecryptPaket(B,FI,Size,kf,br,sizeo);
 if sizeo=0 then exit;
 SetInfoData(br,false,0,sizeo);
 sign:=makeword(br[sizeo-3],br[sizeo-4]);
// if TPVConnectMan(AThread.Data).fSign<>sign then exit;
 crc:=makeword(br[sizeo-1],br[sizeo-2]);
 if calccrc(br,7,sizeo-3)<>crc then exit;

 TPVConnectMan(AThread.Data).AddPaket(Addr,br);

end;

procedure TComPort.ExecIntCommand(AThread: TIdPeerThread; B: TBuffPort; FI,
  Size: dword);
var no:byte;
   // ar:TAddrRec;
    i:integer;

  //  br:TBuffPort;

  //  kf,kr:string;
  //  sizeo:dword;
    Addr:dword;
    crc,sign,loAddr,hiAddr:word;
begin
 Addr:=0;
 loAddr:=makeword(b[fi+6],b[fi+5]);
 hiAddr:=makeword(b[fi+4],b[fi+3]);
 Addr:=makelong(loAddr,hiAddr);

// for i:=0 to 3 do ar.bAddr[i]:=b[i+3+fi];

 SetInfoData(b,false,FI,size);
 if size=0 then exit;
 sign:=makeword(b[size-3],b[size-4]);
 //if TPVConnectMan(AThread.Data).fSign<>sign then exit;
 crc:=makeword(b[size-1],b[size-2]);
 if calccrc(b,FI,size-3)<>crc then exit;

 no:=b[FI+7];
 case no of
  2: begin
      //ar.dwAddr:=0;
      //for i:=0 to 2 do ar.bAddr[i]:=b[FI+i+3];
        TPVConnectMan(AThread.Data).Addr0:=Addr and $FFFFFF00;
      TPVConnectMan(AThread.Data).fSign:=sign;
     end;
 end;


end;

procedure TComPort.In_outPort(var Paket: TPaket);
var  //ar:TAddrRec;
     i,ii:integer;
     th:TIdPeerThread;
     j:cardinal;
     L:TList;
     crc:dword;
    // bw:TIDBytes;
     Addr:dword;
     fl:boolean;
     b:TBuffPort;
     size:dword;
     kr,kf:string;
     loAddr,hiAddr:word;
     TimeOutRead:dword;
begin
  Addr:=0;
  loAddr:=makeword(Paket.WPaket[6],Paket.WPaket[5]);
  hiAddr:=makeword(Paket.WPaket[4],Paket.WPaket[3]);
  Addr:=makelong(loAddr,hiAddr);
  Paket.Errors:=Paket.Errors or On_CDP;
  //Paket.Errors:=0;
//OpenAlarmChannel(Addr);


  if (fAddrforAlarmChannel=Addr) and (not Paket.EnableAlarmChannel) then
   begin
    CloseAlarmChannel;
    fAddrForAlarmChannel:=0;
   end;

  if (fAddrforAlarmChannel=0) and Paket.EnableAlarmChannel then
   begin
    SetStrInfoData('NeedOpenAlarmChannel');
    if OpenAlarmChannel(Addr) then
     begin
      fAddrForAlarmChannel:=Addr;
      fAlarmTimeWork:=GetTickCount;
     end;
   end;

  if (fAddrForAlarmChannel=Addr) and Paket.EnableAlarmChannel then
   begin
     if abs(GetTickCount-fAlarmTimeWork)>=(fAlarmTimeLimitSec*1000) then
      begin
       CloseAlarmChannel;
       fAddrForAlarmChannel:=0;
       exit;
      end;

     In_OutAlarmChannel(Paket);
     exit;
   end;

 if not fTCPServer.Active then
  begin
   Paket.Errors:=0;
   exit;
  end;


 L:=fTCPServer.Threads.LockList;
 try
 try
   {Addr:=0;
   loAddr:=makeword(Paket.WPaket[6],Paket.WPaket[5]);
   hiAddr:=makeword(Paket.WPaket[4],Paket.WPaket[3]);
   Addr:=makelong(loAddr,hiAddr); }

 // ar.dwAddr:=0;
  th:=nil;
 // for i:=0 to 3 do
  // ar.bAddr[i]:=Paket.WPaket[i+3];

  //FullAddr:=ar.dwAddr;
  //ar.bAddr[3]:=0;

  for i:=0 to L.Count-1 do
   if TIdPeerThread(l[i]).Data<>nil then
   if TPVConnectMan(TIdPeerThread(l[i]).Data).Addr0=(Addr and $FFFFFF00) then
    begin
     th:=TIdPeerThread(l[i]);
     Paket.WPaket[Paket.WCount-2]:=random(255);
     Paket.WPaket[Paket.WCount-1]:=HiByte(TPVConnectMan(Th.Data).fSign);
     Paket.WPaket[Paket.WCount]:=LoByte(TPVConnectMan(Th.Data).fSign);

     crc:=CalcCRC(Paket.WPaket,7,Paket.WCount);
     Paket.WPaket[Paket.WCount+1]:=hiByte(crc);
     Paket.WPaket[Paket.WCount+2]:=loByte(crc);

     Paket.Errors:=Paket.Errors or ON_CDP;
     // если команда опроса, то обрабатываем по особому

     if Paket.WPaket[7]=25 then
      begin
       fl:=TPVConnectMan(Th.Data).GetPaket(Addr,25,Paket.RPaket);
       if fl then
        begin
         Paket.Errors:=Paket.Errors or On_Contr or On_Pak;
         sleep(10);
         exit;
        end
      end;

     //b:=Paket.WPaket;
//     TPVConnectMan(Th.Data).
     GetKeys(Addr,kf,kr);
     EncryptPaket(Paket.WPaket,kf,b,size);
     Th.Connection.WriteBuffer(b,size);
     SetKoloBytes(true,size);
   //  SetInfoData(Paket.WPaket,true,0,Paket.WCount+3);
     SetInfoData(b,true,0,size);

     fl:=Paket.RCount=0;  j:=0;
     if (Addr and $F)=1 then
      TimeOutRead:=fTimeOutRead
     else
      TimeOutRead:=fTimeOutRead485;

     while (not fl) and (j<TimeoutRead) do
      begin
       fl:=TPVConnectMan(Th.Data).GetPaket(Addr,Paket.WPaket[7],Paket.RPaket);
       sleep(50);
       inc(j,50);
      end;

     if fl then
      begin
        if (BitStat(Paket.RPaket[2],4)=0) and (BitStat(Paket.RPaket[2],5)=0) then
         Paket.Errors:=Paket.Errors or On_Contr or On_Pak
        else
         Paket.Errors:=Paket.Errors or On_Pak;
        if Paket.Delay0>0 then
         sleep(Paket.Delay0);
      end
     else
      begin
       //ar.dwAddr:=FullAddr;
       if (Addr and $F)=1 then
        Th.Connection.Disconnect;
        //th.TerminateAndWaitFor;
//        th.Terminate;

      end;


    end;




 except

 end;
 finally
  fTCPServer.Threads.UnlockList;
 end;




{ try
 ar.dwAddr:=0;
 th:=nil;
 for i:=0 to 3 do
  ar.bAddr[i]:=Paket.WPaket[i+3];

 for i:=0 to fTCPServer.Socket.ActiveConnections-1 do
  if integer(fTCPServer.Socket.Connections[i].Data)=ar.dwAddr then
   begin
    th:=TServerThread(fTCPServer.Socket.GetClientThread(TServerClientWinSocket(fTCPServer.Socket.Connections[i])));
    break;
   end;

 if th=nil then
  begin
   Paket.Errors:=0;
   sleep(10);
   exit;
  end;

 th.WritePaket(Paket);
 j:=0;
 while th.IsWork and (j<fDelayRead) do
  begin
   sleep(50);
   inc(j);
  end;
 if j>=fDelayRead then
  Paket.errors:=0
 else
  Paket:=th.fPaket;
except
 Paket.Errors:=0;
end; }

end;






procedure TComPort.Onconnect(AThread: TIdPeerThread);
begin
 AThread.Data:=TPVConnectMan.Create;
 SetStrInfoData('Connect');
 ExecCommand2(AThread);
end;

procedure TComPort.OnDisconnect(AThread: TIdPeerThread);
begin
 AThread.Data.Free;
 fTCPServer.ThreadMgr.ReleaseThread(AThread);
 SetStrInfoData('Disconnect');
end;

procedure TComPort.OnExecute(AThread: TIdPeerThread);
var br,bo:TBuffPort;
    i,j:integer;
    b:byte;
    fi,size,len:dword;
    cm:TPVConnectMan;
    crc:word;
    //ar:TAddrRec;
    kf,kr:string;
    timenow,timeneed:TDateTime;
    Year, Month, Day, Hour, Min, Sec, MSec: Word;
begin
 if AThread.Data<>nil then
  begin
    cm:=TPVConnectMan(AThread.Data);
    if abs(GetTickCount-TPVConnectMan(AThread.Data).fOldIntervalTCP)>=fIntervalTCP then
     begin
      br[0]:=0;
      AThread.Connection.WriteBuffer(br,1);
      SetKoloBytes(true,1);
      SetInfoData(br,true,0,1);
      TPVConnectMan(AThread.Data).fOldIntervalTCP:=GetTickCount;
      sleep(100);
     end;

   for i:=0 to cm.fConnections.Count-1 do
    begin
     if cm.RequestFullSost(TPVConnectRec(cm.fConnections[i]^).Address) then
      begin
        fillchar(br,sizeof(TBuffPort),0);
        br[0]:=$55;
        br[1]:=1;
        br[2]:=$0;
        br[3]:=TPVConnectRec(cm.fConnections[i]^).Address shr 24;
        br[4]:=TPVConnectRec(cm.fConnections[i]^).Address shr 16;
        br[5]:=TPVConnectRec(cm.fConnections[i]^).Address shr 8;
        br[6]:=TPVConnectRec(cm.fConnections[i]^).Address;
        br[7]:=27;
        br[8]:=0;
        br[9]:=random(255);
        br[10]:=HiByte(TPVConnectMan(AThread.Data).fSign);
        br[11]:=LoByte(TPVConnectMan(AThread.Data).fSign);
        crc:=CalcCrc(br,7,11);
        br[12]:=hiByte(crc);
        br[13]:=loByte(crc);
        GetKeys(TPVConnectRec(cm.fConnections[i]^).Address,kf,kr);
        EncryptPaket(br,kf,bo,len);
        AThread.Connection.WriteBuffer(bo,len);
        SetKoloBytes(true,len);
        SetInfoData(bo,true,0,len,true);
      end;

     if fAutoLoadData then
     if CompareDate(TPVConnectRec(cm.fConnections[i]^).OldLoadData, now)<> 0	then
      begin
       timenow:=time;
       timeneed:=fTimeLoadData;
       if timenow>=timeneed then
        begin
         fillchar(br,sizeof(TBuffPort),0);
         DecodeDate(Now,Year, Month, Day);
         DecodeTime(Now,Hour, Min, Sec, MSec);

         br[0]:=$55;
         br[1]:=7;
         br[2]:=$0;
         br[3]:=TPVConnectRec(cm.fConnections[i]^).Address shr 24;
         br[4]:=TPVConnectRec(cm.fConnections[i]^).Address shr 16;
         br[5]:=TPVConnectRec(cm.fConnections[i]^).Address shr 8;
         br[6]:=TPVConnectRec(cm.fConnections[i]^).Address;
         br[7]:=7;
         br[8]:=Sec;
         br[9]:=Min;
         br[10]:=Hour;
         br[11]:=Day;
         br[12]:=Month;
         br[13]:=1;
         br[14]:=Year-2000;

         br[15]:=random(255);
         br[16]:=HiByte(TPVConnectMan(AThread.Data).fSign);
         br[17]:=LoByte(TPVConnectMan(AThread.Data).fSign);
         crc:=CalcCrc(br,7,17);
         br[18]:=hiByte(crc);
         br[19]:=loByte(crc);
         GetKeys(TPVConnectRec(cm.fConnections[i]^).Address,kf,kr);
         EncryptPaket(br,kf,bo,len);
         AThread.Connection.WriteBuffer(bo,len);
         SetKoloBytes(true,len);
         SetInfoData(bo,true,0,len,true);
         TPVConnectRec(cm.fConnections[i]^).OldLoadData:=now;
        end;
      end;

   end;
  end;



 if Athread.Terminated then
  begin
   sleep(100);
   exit;
  end;
  AThread.Connection.ReadTimeout:=50;//High(Integer);
 // AThread.Connection.ReadBuffer(b,1);
 // AThread.Connection.ReadTimeout:=50;
  j:=0;
  FillChar(br,sizeof(TBuffPort),0);
  while True do
   try
    AThread.Connection.ReadBuffer(b,1);
    br[j]:=b;
    inc(j);

   except
     fi:=0;
     if j>0 then
      begin
       SetKoloBytes(false,j);
       SetInfoData(br,false,0,j);
      end;

     while CheckPaket(br,fi,size) do
      begin
       if ((br[fi+2] and 1)=1) then
        if (((br[fi+2] shr 2) and 1)=1) then
         ExecIntCommand(AThread,br,fi,size)
        else
         ExecExtCommand(AThread,br,fi,size);
       inc(fi);
      end;

    break;
   end;


end;



function TComPort.OpenPort:boolean;
var ini:TIniFile;
    CommDCB:TDCB;
    DTime:TCommTimeouts;
    s:string;
begin

 ini:=TIniFile.Create(IniName);
 try
   fTCPServer.DefaultPort :=ini.ReadInteger('TCP','Port',33002);
   fTimeoutRead           :=ini.ReadInteger('TCP','TimeoutRead',10000);
   fTimeoutRead485        :=ini.ReadInteger('TCP','TimeoutRead485',2000);

   fIntervalTCP           :=ini.ReadInteger('TCP','IntervalTCP',540000);
   fIntervalFullSost      :=ini.ReadInteger('TCP','IntervalFullSost',600000);

   fPort                  :=ini.ReadString('AlarmChannel','Port','COM1');
   fBaud                  :=ini.ReadInteger('AlarmChannel','Baud',19200);
   fByte                  :=ini.ReadInteger('AlarmChannel','Byte',8);
   fParity                :=ini.ReadInteger('AlarmChannel','Parity',0);
   fStopBits              :=ini.ReadInteger('AlarmChannel','StopBits',2);
   fDelayRead             :=ini.ReadInteger('AlarmChannel','DelayRead',2000);
   fDelayRead1            :=ini.ReadInteger('AlarmChannel','DelayRead1',100);
   fAlarmTimeLimitSec     :=ini.ReadInteger('AlarmChannel','AlarmTimeLimitSec',600);

   fTimeLoadData:=StrToDateTime(ini.ReadString('TCP','TimeLoadData','01.01.2001 1:00:00'));
   fTimeLoadData:=Frac(fTimeloadData);

   fAutoLoadData:=ini.ReadBool('TCP','AutoLoadData',false);



 finally
  ini.free;
 end;

 
 ClosePort;
 fTCPServer.Active:=true;

{ hComm:=CreateFile(PCHAR(fPort),
                      GENERIC_READ or  GENERIC_WRITE,
                      0,
                      nil,
                      OPEN_EXISTING,
                      FILE_ATTRIBUTE_NORMAL,// or FILE_FLAG_OVERLAPPED,
                      0);
 if (hComm>0) and (hComm<>Invalid_Handle_Value) then exit;

 GetCommState(hComm,CommDCB);
 CommDCB.Flags:=CommDCB.Flags or RTS_CONTROL_HANDSHAKE;

 CommDCB.Parity:=fPARITY;
 CommDCB.BaudRate:=fBaud;
 CommDCB.ByteSize:=fByte;
 CommDCB.StopBits:=fStopBits;
 SetCommState(hComm,CommDCB);
 GetCommTimeouts(hComm,DTime);
 DTime.ReadIntervalTimeout:=fDelayRead1;
 DTime.ReadTotalTimeoutMultiplier:=0;
 DTime.ReadTotalTimeoutConstant:=fDelayRead;
 DTime.WriteTotalTimeoutMultiplier:=0;
 DTime.WriteTotalTimeoutConstant:=500;
 SetCommTimeouts(hComm,DTime);
 SetupComm(hComm,90,90);
 SetCommMask(hComm,EV_TXEMPTY);
 }

end;

 { TServerThread }


function CheckPaket(Arr: TBuffPort; var FirstIndex: dword;
  out Len: dword): boolean;
var crc:word;
    hi,lo,i,j:integer;
begin
 result:=false;

 while not result do
  begin
   Len:=0;
   if FirstIndex>High(Arr) then exit;
   j:=-1;
   for i:=FirstIndex to High(Arr) do
    if Arr[i]=$55 then
     begin
      j:=i;
      break;
     end;
   if j=-1 then break;
   if (j+LenHeaderAndCRC)>High(Arr) then exit;
   hi:=Arr[j+1]+(LenHeaderAndCRC-2);
   lo:=Arr[j+1]+(LenHeaderAndCRC-1);
   crc:=makeword(Arr[lo],Arr[hi]);
   result:=crc=CalcCRC(Arr,j,hi-1);
   FirstIndex:=j;
   Len:=Arr[j+1]+LenHeaderAndCRC;
   if not result then
    FirstIndex:=FirstIndex+1;
  end;

end;




{ TPVConnectMan }

procedure TPVConnectMan.AddPaket(Addr: dword; B: TBuffPort);
var p:PPVConnectRec;
    i,j:integer;
begin
 p:=SearchPVConnectRec(Addr);
 if p=nil then
  begin
   new(p);
   p^.Address:=Addr;
   p^.ExistsPaket27:=false;
   p^.OldLoadData:=0;
   fConnections.Add(p);
  end;

 SetLength(p^.PVPakets,Length(p^.PVPakets)+1);
 p^.PVPakets[High(p^.PVPakets)]:=B;
end;

constructor TPVConnectMan.Create;
begin
 inherited Create;
 fConnections:=TList.Create;
 fOldIntervalTCP:=GetTickCount;
end;

procedure TPVConnectMan.DeletePVPaket(PVC: PPVConnectRec; index: integer);
var i,j:integer;
    b:TBuffPort;
begin
 if PVC=nil then exit;
 if (index<0) or (index>high(pvc^.PVPakets)) then exit;

 if (pvc^.PVPakets[index][7]=27) then
  begin
   pvc^.Paket27:=pvc^.PVPakets[index];
   pvc^.ExistsPaket27:=true;
  end;

 if index=High(PVC^.PVPakets) then
  begin
   SetLength(PVC^.PVPakets,Length(PVC^.PVPakets)-1);
   exit;
  end;

 for i:=index to High(PVC^.PVPakets)-1 do
  PVC^.PVPakets[i]:=PVC^.PVPakets[i+1];

 SetLength(PVC^.PVPakets,Length(PVC^.PVPakets)-1);
end;

destructor TPVConnectMan.Destroy;
var i:integer;
begin
  for i:=0 to fConnections.Count-1 do
   dispose(fConnections[i]);
  fConnections.Free;
  inherited;
end;

{function GetKeys(Addr:dword; var KeyFlash, KeyRom: string): boolean;
const
 key:array [0..15] of byte=($2b,$7e,$15,$16,$28,$ae,$d2,$a6,$ab,$f7,$15,$88,$09,$cf,$4f,$3c);
var p:PPVConnectRec;
    i:integer;
    s:string;
begin
 result:=false;
// p:=SearchPVConnectRec(Addr);
// if p=nil then exit;

 s:='';
 for i:=0 to high(key) do
  s:=s+chr(key[i]);

 KeyFlash:=s;//p^.KeyFlash;
 KeyRom:=s;//p^.KeyRom;
 result:=true;
end;  }

function TPVConnectMan.GetPaket(Addr: dword; NoComm: byte;
  out B: TBuffPort): boolean;
var p:PPVConnectRec;
    i,j:integer;
    No:byte;
begin
 result:=false;
 p:=SearchPVConnectRec(Addr);
 if p=nil then exit;
 if NoComm=25 then
  No:=27
 else
  No:=NoComm;

 for i:=0 to High(p^.PVPakets) do
  if p^.PVPakets[i][7]=No then
   begin
    result:=true;
    B:=p^.PVPakets[i];
    DeletePVPaket(p,i);
    break;
   end;
 if result then exit;
 if (NoComm=25) and (p^.ExistsPaket27) then
  begin
   result:=true;
   B:=p^.Paket27;
  end;
end;

function TPVConnectMan.RequestFullSost(Addr: dword): boolean;
var p:PPVConnectRec;
begin
 result:=true;
 p:=SearchPVConnectRec(Addr);
 if p=nil then exit;
 if abs(GetTickCount-p^.OldTimeFullSost)>=co.fIntervalFullSost then
  begin
   result:=true;
   p^.OldTimeFullSost:=GetTickCount;
  end
 else
  result:=false;
end;

function TPVConnectMan.SearchPVConnectRec(Addr: dword): PPVConnectRec;
var i:integer;
begin
 result:=nil;
 for i:=0 to fConnections.Count-1 do
  if TPVConnectRec(fConnections[i]^).Address=Addr then
   begin
    result:=fConnections[i];
    break;
   end;
end;

procedure TComPort.SetInfoData(P: TBuffPort; Write: boolean; FI,Count: integer; CheckPaket:boolean=false);
const
 M='%s %s %s(%d)';
var i:integer;
    sw,sd:string;
begin
 if not fLogging then exit;
 if @fChangeData=nil then exit;

 if Write then
  sw:='w'
 else
  sw:='r';
 if CheckPaket then
  sw:=sw+' CheckPaket'; 
 sd:='';
 for i:=FI to count-1 do
  sd:=sd+' '+inttohex(P[i],2);
 fChangedata(PChar(format(m,[sw,formatdatetime('hh:nn:ss:zzz',now),sd,count])));
end;

procedure TComPort.SetLogging(ALogging: boolean);
begin
 fLogging:=ALogging;
end;

procedure TComPort.SetStrInfoData(Str: string);
begin
 if not fLogging then exit;
 if @fChangeData=nil then exit;
 fChangedata(PChar(Str));
end;

procedure TComPort.InitDRV(PVState:PPVState);
var i,j:integer;
    p:PPVKey;
    //ar:TAddrRec;
    kf,kr:string;
    Addr:dword;
    loAddr,hiAddr:word;
begin
 Addr:=0;
 loAddr:=makeword(PVState^.AdressPV[3],PVState^.AdressPV[2]);
 hiAddr:=makeword(PVState^.AdressPV[1],PVState^.AdressPV[0]);
 Addr:=makelong(loAddr,hiAddr);


{ ar.dwAddr:=0;
 for i:=0 to 3 do
  ar.bAddr[i]:=PVState^.AdressPV[i];}
 if GetKeys(Addr,kf,kr) then exit;

  new(p);
  FillChar(p^,sizeof(TPVKey),0);

  p^.Address:=Addr;

  for i:=0 to 15 do
   p^.KeyFlash[i]:=PVState^.CryptKeys[i];

  for i:=0 to 15 do
   p^.KeyRom[i]:=PVState^.CryptKeys[i+16];


  p^.PN1:=PVState^.Phone1;
  p^.PN2:=PVState^.Phone2;
  
  fKeys.Add(p);

{ for i:=0 to ListPV.Count-1 do
  if TPVState(ListPV[i]^).VER_INT_DEV=101 then
   begin
    new(p);
    FillChar(p^,sizeof(TPVKey),0);
    ar.dwAddr:=0;

    for j:=0 to 3 do
      ar.bAddr[j]:=TPVState(ListPV[i]^).AdressPV[j];
    p^.Address:=ar.dwAddr;

    for j:=0 to 15 do
     p^.KeyFlash[j]:=TPVState(ListPV[i]^).CryptKeys[j];

    for j:=0 to 15 do
     p^.KeyRom[j]:=TPVState(ListPV[i]^).CryptKeys[j+16];
    fKeys.Add(p);
   end;  }
end;

procedure TComPort.SetKoloBytes(Write: boolean; Kolo: integer);
var s:string;
    f:TextFile;
    IOError :integer;
    fFileName:string;
begin
 if Write then
  inc(fKoloW,Kolo)
 else
  inc(fKoloR,Kolo);

 if ((fKoloW-fOldKoloW)>=100) or ((fKoloR-fOldKoloR)>=100) then
 begin

 fFileName:=ExtractFilePath(GetModuleFileNameStr(HInstance))+'KoloBytes.txt'; //ChangeFileExt(ParamStr(0),'.log');
 AssignFile(F, fFileName);
 Rewrite(F);
 IOError := IOResult;
 if IOError = 0 then
    begin
     WriteLN(f,'Write:'+#9+FormatDateTime('dd.mm.yy hh:nn:ss:zzz',now)+#9+inttostr(fKoloW));
     WriteLN(f,'Read:'+#9+FormatDateTime('dd.mm.yy hh:nn:ss:zzz',now)+#9+inttostr(fKoloR));
    end;
 CloseFile(f);
 fOldKoloR:=fKoloR;
 fOldKoloW:=fKoloW;
 end;

end;

function TComPort.GetPhoneNumber(Addr: dword; NoAlarm:integer;
  var PhoneNumber: string): boolean;
var i:integer;
    s:string;
    p:PPVKey;
begin
 result:=false;
 p:=nil;
// p:=SearchPVConnectRec(Addr);
// if p=nil then exit;
 for i:=0 to fKeys.Count-1 do
  if TPVKey(fKeys[i]^).Address=Addr then
   begin
    p:=fKeys[i];
    break;
   end;

 if p=nil then exit;
 if NoAlarm<=0 then exit;
 s:='';
 case NoAlarm of
  1: for i:=0 to High(p.PN1) do s:=s+inttostr(p.pn1[i]);
  2: for i:=0 to High(p.PN2) do s:=s+inttostr(p.pn2[i]);
 end;

 //p.PN1

 PhoneNumber:=s;
 result:=true;

end;

procedure TComPort.CloseAlarmChannel;
const
 c1='+++AT'+chr(13)+chr(10);
 c2='ATH'+chr(13)+chr(10);


procedure RunComm(S:string);
var bw,br:TBuffPort;
    nw,nr,EvtMask,size:dword;
    i:integer;
begin
 fillchar(bw,sizeof(TBuffPort),0);
 fillchar(br,sizeof(TBuffPort),0);

 for i:=1 to Length(s) do
  bw[i-1]:=ord(s[i]);
 size:=Length(s);

 PurgeComm(hComm,PURGE_TXCLEAR or PURGE_RXCLEAR);
 WriteFile(hComm,bw,size,nw,nil);
 WaitCommEvent(hComm,EvtMask,nil);

 ReadFile(hComm,br,255,nr,nil);
 PurgeComm(hComm,PURGE_TXCLEAR or PURGE_RXCLEAR);

end;

begin

 AlarmChannelIni(5000,100);
 fAlarmYes25Paket:=false;
 if ((hComm>0) and (hComm<>Invalid_Handle_Value)) then
  begin
   RunComm(c1);
   RunComm(c2);
   CloseHandle(hComm);
   SetStrInfoData('CloseAlarmChannel OK');
  end;
 hComm:=0;
end;

function TComPort.OpenAlarmChannel(Addr:dword): boolean;
var ini:TIniFile;
    CommDCB:TDCB;
    DTime:TCommTimeouts;
    pn,s:string;
    i,ii:integer;
    nw,nr,lenr,EvtMask:dword;
    bp,bw,br:TBuffPort;
    crc:word;
    fi,size:dword;
begin
  CloseAlarmChannel;
  SetStrInfoData('Begin OpenAlarmChannel Addr='+inttostr(Addr));
  hComm:=CreateFile(PCHAR(fPort),
                      GENERIC_READ or  GENERIC_WRITE,
                      0,
                      nil,
                      OPEN_EXISTING,
                      FILE_ATTRIBUTE_NORMAL,// or FILE_FLAG_OVERLAPPED,
                      0);
 result:= ((hComm>0) and (hComm<>Invalid_Handle_Value));

 SetStrInfoData('OpenAlarmChannel hComm='+inttostr(hComm));

 if not result then exit;

 result:=false;
 AlarmChannelIni(fDelayRead,fDelayRead1);

 for ii:=1 to 2 do
  begin

     if not GetPhoneNumber(Addr,ii,pn) then
      begin
       SetStrInfoData('GetPhoneNumber Failed NoPhone:'+inttostr(ii));
       continue;
      end;

     SetStrInfoData('GetPhoneNumber OK NoPhone:'+inttostr(ii));

     fillchar(bp,sizeof(TBuffPort),0);
     bp[0]:=ord('A');
     bp[1]:=ord('T');
     bp[2]:=ord('D');
     bp[3]:=ord('+');
     bp[4]:=ord('7');

     for i:=1 to Length(PN) do
      bp[i+4]:=ord(PN[i]);
    // bp[Length(pN)+5]:=ord(';');
     bp[Length(PN)+5]:=$0D;
     bp[Length(PN)+6]:=$0A;

     lenr:=100;
     EscapeCommFunction(hComm,CLRDTR);
    // EscapeCommFunction(hComm,SETRTS);
     PurgeComm(hComm,PURGE_TXCLEAR or PURGE_RXCLEAR);
     WriteFile(hComm,bp[0],17,nw,nil);
     WaitCommEvent(hComm,EvtMask,nil);
     fillchar(br,sizeof(TBuffPort),0);
     ReadFile(hComm,br,lenr,nr,nil);
     PurgeComm(hComm,PURGE_TXCLEAR or PURGE_RXCLEAR);
     if nr=0 then continue;
     if nr<>2 then continue;
     //if chr(br[0])<>'1' then exit;
     result:=chr(br[0])='1';
     if result then break;
  end;

 if not result then exit;

 { s:='';
 for i:=0 to nr-1 do
  s:=s+chr(br[i]);
 if s<>'1' then exit;}
 //result:=true;

 AlarmChannelIni(5000,100);


 fillchar(bw,sizeof(TBuffPort),0);
 bw[0]:=$55;
 bw[1]:=0;
 bw[2]:=$4;
 bw[7]:=2;


 bw[8]:=0;//random(255);
 bw[9]:=0;
 bw[10]:=0;
 crc:=CalcCrc(bw,0,10);
 bw[11]:=hiByte(crc);
 bw[12]:=loByte(crc);

 WriteFile(hComm,bw,13,nw,nil);
 WaitCommEvent(hComm,EvtMask,nil);
 fillchar(br,sizeof(TBuffPort),0);
 ReadFile(hComm,br,lenr,nr,nil);
 fi:=0;
 while CheckPaket(br,fi,size) do
  begin
       if ((br[fi+2] and 1)=1) then
        if (((br[fi+2] shr 2) and 1)=1) then
         begin
          //ExecIntCommand(AThread,br,fi,size)
          if br[fi+7]=2 then
           begin
            fsignAlarm:=makeword(br[size-3],br[size-4]);
           // AlarmChannelIni(5000,100);
            result:=true;
           end;
         end;
       inc(fi);
  end;

 fAlarmYes25Paket:=false;
 SetStrInfoData('OpenAlarmChannel OK');
 //if nr=0 then exit;

end;

procedure TComPort.In_OutAlarmChannel(var Paket: TPaket);
var crc,sign:word;
    bw,br:TBuffPort;
    fi,size,sizeo,nr,nw,EvtMask:dword;
    kf,kr:string;
begin
 if not GetKeys(fAddrforAlarmChannel,kf,kr) then exit;

 {if (Paket.WPaket[7]=25) and fAlarmYes25Paket then
  begin
   fillchar(br,sizeof(TBuffPort),0);
   ReadFile(hComm,br,255,nr,nil);
   PurgeComm(hComm,PURGE_TXCLEAR or PURGE_RXCLEAR);
   while CheckPaket(br,fi,size) do
    begin

         if ((br[fi+2] and $7)=$3) then
           begin
             fillchar(Paket.RPaket,sizeof(TBuffPort),0);
             DecryptPaket(br,FI,Size,kf,Paket.RPaket,sizeo);
             if sizeo=0 then exit;
             SetInfoData(Paket.RPaket,false,0,sizeo);
             sign:=makeword(Paket.RPaket[sizeo-3],Paket.RPaket[sizeo-4]);
             if fSignAlarm<>sign then exit;
             crc:=makeword(Paket.RPaket[sizeo-1],Paket.RPaket[sizeo-2]);
             if calccrc(Paket.RPaket,7,sizeo-3)=crc then
              begin
               Paket.Errors:=Paket.Errors or On_Contr or On_Pak;
               fAlarm25Paket:=Paket.RPaket;
               fAlarmYes25Paket:=true;
              end
             else
              fAlarmYes25Paket:=false;

           end;
         inc(fi);
    end;




   Paket.RPaket:=fAlarm25Paket;
   Paket.Errors:=Paket.Errors or On_Contr or On_Pak;
   exit;
  end;
  }

 if (Paket.WPaket[7]=25) then
  Paket.WPaket[7]:=27;

 Paket.WPaket[Paket.WCount-2]:=random(255);
 Paket.WPaket[Paket.WCount-1]:=HiByte(fSignAlarm);
 Paket.WPaket[Paket.WCount]:=LoByte(fSignAlarm);

 crc:=CalcCRC(Paket.WPaket,7,Paket.WCount);
 Paket.WPaket[Paket.WCount+1]:=hiByte(crc);
 Paket.WPaket[Paket.WCount+2]:=loByte(crc);

 Paket.Errors:=Paket.Errors or ON_CDP;
 fillchar(bw,sizeof(TBuffPort),0);
 fillchar(br,sizeof(TBuffPort),0);




 EncryptPaket(Paket.WPaket,kf,bw,size);

 PurgeComm(hComm,PURGE_TXCLEAR or PURGE_RXCLEAR);
 WriteFile(hComm,bw,size,nw,nil);
 WaitCommEvent(hComm,EvtMask,nil);
 fillchar(br,sizeof(TBuffPort),0);
 ReadFile(hComm,br,255,nr,nil);
 PurgeComm(hComm,PURGE_TXCLEAR or PURGE_RXCLEAR);


 fi:=0;
 while CheckPaket(br,fi,size) do
  begin
       if ((br[fi+2] and 1)=1) then
        if (((br[fi+2] shr 2) and 1)=0) and (((br[fi+2] shr 1) and 1)=0) then
         begin
           fillchar(Paket.RPaket,sizeof(TBuffPort),0);
           DecryptPaket(br,FI,Size,kf,Paket.RPaket,sizeo);
           if sizeo=0 then exit;
           SetInfoData(Paket.RPaket,false,0,sizeo);
           sign:=makeword(Paket.RPaket[sizeo-3],Paket.RPaket[sizeo-4]);
           if fSignAlarm<>sign then exit;
           crc:=makeword(Paket.RPaket[sizeo-1],Paket.RPaket[sizeo-2]);
           if calccrc(Paket.RPaket,7,sizeo-3)<>crc then exit;
           Paket.Errors:=Paket.Errors or On_Contr or On_Pak;
           if Paket.WPaket[7]=27 then
            begin
             fAlarm25Paket:=Paket.RPaket;
             fAlarmYes25Paket:=true;
            end;
         end;
       inc(fi);
  end;



end;

procedure TComPort.AlarmChannelIni(Delay1, Delay2: dword);
var CommDCB:TDCB;
    DTime:TCommTimeouts;
    EvtMask:dword;
begin
 if (hComm=Invalid_Handle_Value) or (hComm=0) then exit;
 SetStrInfoData('Begin AlarmChannelINI');
 if not GetCommState(hComm,CommDCB) then
  sleep(100);

// CommDCB.Flags:=$1004;
// CommDCB.Flags:=CommDCB.Flags or RTS_CONTROL_HANDSHAKE;

 CommDCB.Flags:=$2005;//$3051;//$3011 or $40;



 CommDCB.Parity:=fPARITY;
 CommDCB.BaudRate:=fBaud;
 CommDCB.ByteSize:=fByte;
 CommDCB.StopBits:=fStopBits;
 if not SetCommState(hComm,CommDCB) then
  SetStrInfoData('OpenAlarmChannelINI Failed!!!');
 GetCommTimeouts(hComm,DTime);
 DTime.ReadIntervalTimeout:=Delay2;
 DTime.ReadTotalTimeoutMultiplier:=0;
 DTime.ReadTotalTimeoutConstant:=Delay1;
 DTime.WriteTotalTimeoutMultiplier:=0;
 DTime.WriteTotalTimeoutConstant:=500;
 SetCommTimeouts(hComm,DTime);
 SetupComm(hComm,90,90);
 SetCommMask(hComm,EV_TXEMPTY);
 SetStrInfoData('End AlarmChannelINI OK');
end;

initialization
   Co:=TComPort.Create;
   IniName:=ChangeFileExt(GetModuleFileNameStr(HInstance), '.INI');
finalization
 co.Free;

end.
