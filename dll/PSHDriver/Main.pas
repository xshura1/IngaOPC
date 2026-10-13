unit Main;   // для счетчиков ПСЧ

interface
 uses  SysUtils, Classes,  windows,  Dialogs,inifiles, intf;
 type
  TBuff=array [0..255] of byte;

  TComPort=class
   private
    { Private declarations }
    fCountWrite:integer;
    fListResult:TList;




    function CalcCRC(Arr:TBuff; fi, Len:cardinal):string;

    procedure SetAddrAndNoCommand(Addr,NoCommand:string; var Buff:TBuff; out fiCRC, Size:dword; out IsGroup:boolean);

   public
    constructor Create;
    Destructor Destroy; override;
    function OpenPort:HResult;
    function ClosePort:HResult;


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
  result:=s_ok;
end;

constructor TComPort.Create;
begin
 inherited;
 fListResult:=TList.Create;
end;

destructor TComPort.Destroy;
begin
  ClosePort;
  fListResult.Free;
  inherited;
end;



function TComPort.OpenPort:HResult;
begin
 result:=s_ok;
end;
















function TComPort.CalcCRC(Arr:TBuff; fi, Len:cardinal):string;
var h,h1,h2:dword;
    i:integer;
begin
 h:=0;
 for i:=fi to Len-1 do
  h:=h+Arr[i];
 h:=h mod 256;
 h1:=h div 16;
 h2:=h mod 16;
 result:=inttohex(h1,1)+inttohex(h2,1);
end;

function crcpsch(data:TBuff; n:byte):string; // CRC для ПСЧ
var i:byte;
    temp,temp1,temp2:integer;

begin
 temp:=0;
 for i:=0 to n-1 do
  temp:=temp+data[i];
 temp:=temp mod 256;
 temp1:=temp div 16;
 temp2:=temp mod 16;
 if (temp1>=0)and(temp1<=9)then
  temp1:=temp1+48
 else
  temp1:=temp1+55;
 if (temp2>=0) and (temp2<=9) then
  temp2:=temp2+48
 else
  temp2:=temp2+55;

result:=chr(temp1)+chr(temp2);

end;


function TComPort.Write(ppDriverData: pDriverData): HResult;
var  nw,nr,EvtMask,size,fiCRC:dword;
     i:integer;
     pDD:pDriverData;
     pw,pr:TBuff;
     res:dword;
     s:string;
     IsGroup:boolean;
     AddrDrv:dword;
     dwCount:dword;
begin

 res:=1;
 try
       case ppDriverData.AddrDrv of
        0:begin
              AddrDrv:=535760372;
              if Length(string(ppDriverData^.szNoCommand))<2 then
               exit;

              fillchar(pw,sizeof(pw),0);
              fillchar(pr,sizeof(pr),0);
              SetAddrAndNoCommand(string(ppDriverData^.szAddress),string(ppDriverData^.szNoCommand),pw,fiCRC, size, IsGroup);
              if size=0 then exit;

              for i:=0 to ppDriverData^.dwDataSize-1 do
               pw[i+size]:=ppDriverData^.pData^[i];

              size:=size+ppDriverData^.dwDataSize;

              s:=CalcCRC(pw,fiCRC,size);
              pw[size]:=ord(s[1]);
              pw[size+1]:=ord(s[2]);
              pw[size+2]:=13;
              dwCount:=size+3;
              res:=0;
          end;

        535760372:begin
                    AddrDrv:=0;
                    dwCount:=0;
                    if ppDriverData.Result=0 then
                     begin

                      for i:=0 to ppDriverData.dwDataSize-1 do
                       PW[i]:=ppDriverData.pData[i];
                      nr:=ppDriverData.dwDataSize;

                      if nr>8 then
                        if (PW[nr-1]=13) and (PW[0]=ord('~')) then
                           begin
                            s:=chr(PW[nr-3])+chr(PW[nr-2]);
                            if s=CalcCRC(PW,0,nr-3) then
                             begin
                              res:=0;
                              dwCount:=nr-5-3;
                             end;
                           end;


                     end;
                  end;

       end;

 finally
   pdd:=coTaskMemAlloc(sizeof(DriverData));
   fillchar(pdd^,sizeof(DriverData),0);
   pdd^.AddrDrv:=AddrDrv;
   pdd^.Handle:=ppDriverData^.Handle;
   pdd^.Param:=ppDriverData^.Param;
   pdd^.Result:=res;
   if res=0 then
    begin

     pdd^.dwDataSize:=dwCount;
     pdd^.pData:=coTaskMemAlloc(pdd^.dwDataSize);
     for i:=0 to pdd^.dwDataSize-1 do
      if AddrDrv<>0 then
       pdd^.pData^[i]:=PW[i]
      else
       pdd^.pData^[i]:=PW[i+5];
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

procedure TComPort.SetAddrAndNoCommand(Addr, NoCommand: string;
  var Buff: TBuff; out fiCRC, Size: dword; out IsGroup:boolean);
var sAddr,sAddrM,s1:string;
    len,i,j:integer;

begin
 Size:=0;

 if Pos('_',Addr)>0 then
  begin
   sAddrM:=copy(Addr,1,pos('_',Addr)-1);
   sAddr:=copy(Addr,pos('_',Addr)+1,Length(Addr));
   fiCRC:=9;
  end
 else
  begin
   sAddr:=Addr;
   sAddrM:='';
   fiCRC:=0;
  end;

  len:=length(sAddrM);
  j:=0; s1:='';
  for i:=1 to len do
   if (sAddrM[i]<>'.') and (i<len) then
    s1:=s1+sAddrM[i]
   else
    begin
     if i=len then
      s1:=s1+sAddrM[i];
     try
      Buff[j]:=strtoint(s1);
     except
     end;
     inc(j);
     s1:='';
    end;

  Size:=j;

  IsGroup:=NoCommand[1]='@';
  if IsGroup then
   begin
    Buff[j]:=ord('@');

    for i:=4 to Length(sAddr) do
     begin
      Buff[i-3+j]:=ord(sAddr[i]);
      inc(size);
     end;
   end
  else
   begin
    Buff[j]:=ord('#');

    for i:=1 to Length(sAddr) do
     begin
      Buff[i+j]:=ord(sAddr[i]);
      inc(size);
     end;
   end;



 for i:=2 to Length(NoCommand) do
   Buff[size+(i-1)]:=ord(NoCommand[i]);

 size:=size+Length(NoCommand);

end;


initialization
   IniName:=ChangeFileExt(GetModuleFileNameStr(HInstance,true), '.INI');
   Co:=TComport.Create;


end.
