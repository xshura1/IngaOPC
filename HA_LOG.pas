unit HA_LOG;

interface
   uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
        Dialogs;

 type
  THALOG=class(TThread)
   private
    fListLog:TStringList;
    //ff:TextFile;
    fFilterCategory:dword;
    fFilterResult:dword; // bit=0 then All; bit=1 then OnlyError;
    fHandle:THandle;
    fFileName:string;
   protected
    procedure Execute; override;
   public
    constructor Create;
    destructor destroy; override;
    procedure AddLog(Category,Info:string; Result:HRESULT; ResultStr:string);
    procedure TerminateAndFree;
    property HandleWin:THandle read fHandle write fHandle;
    property FilterCategory:dword read fFilterCategory write fFilterCategory;
    property FilterResult:dword read fFilterResult write fFilterResult;
  end;

 var Log:THALog;
 procedure AddLog(Category:integer; Info:string; Result:HRESULT; ResultStr:string);
implementation
  uses ha_wmConst,ha_utils;

procedure AddLog(Category:integer; Info:string; Result:HRESULT; ResultStr:string);
var s:string;
begin
 if not Assigned(Log) then exit;
 if BitStat(Log.FilterCategory,Category)=0 then exit;
 if Category>1 then
  if (BitStat(Log.fFilterResult,Category)=1) and (Result=s_ok) then exit;

 case Category of
  1:s:='OPCServer';
  2:s:='OPCServerDA Object';
  3:s:='OPCGroupDA Object';
  4:s:='OPCGroup Timer';
  5:s:='OPCServerAE Object';
  
 end;
 Log.AddLog(s,Info,Result,ResultStr);
end;

{ THALOG }

procedure THALOG.AddLog(Category,Info:string; Result:HRESULT; ResultStr:string);
begin
 fListLog.Add(FormatDateTime('dd.mm.yy hh:nn:ss:zzz',now)+#9+Category+#9+Info+#9+IntToHex(Result,8)+#9+ResultStr);
end;

constructor THALOG.Create;
var f:TextFile;
    IOError :integer;

begin
 inherited Create(false);
 fHandle:=0;
 fListLog:=TStringList.Create;
 fFileName:=ChangeFileExt(ParamStr(0),'.log');

 fFilterCategory:=255;
 fFilterResult:=255;

 AssignFile(F, fFileName);

 Rewrite(F);
 IOError := IOResult;
 if IOError = 0 then
  begin
    // WriteLN(f,' ');
    // WriteLN(f,#9+FormatDateTime('dd.mm.yy hh:nn:ss:zzz',now)+#9+'       Run Server');
    WriteLN(f,FormatDateTime('dd.mm.yy hh:nn:ss:zzz',now)+#9+'OPCServer'+#9+'Загрузка...'+#9+' '+#9+' ');
  end;
 CloseFile(f);

{ if not FileExists(fFileName) then
  begin
   Rewrite(F);
   IOError := IOResult;
   if IOError = 0 then
    begin
     WriteLN(f,' ');
     WriteLN(f,'Category'+#9+'DateTime'+#9+'Message');
     WriteLN(f,#9+FormatDateTime('dd.mm.yy hh:nn:ss:zzz',now)+#9+'       Run Server');
    end;
   CloseFile(f);
  end
 else
  begin
   Append(F);
   IOError := IOResult;
   if IOError = 0 then
    begin
     WriteLN(f,' ');
     WriteLN(f,#9+FormatDateTime('dd.mm.yy hh:nn:ss:zzz',now)+#9+'       Run Server');
    end;
   CloseFile(f);
  end    }

end;

destructor THALOG.destroy;
begin
 fListLog.Free;
 inherited;
end;

procedure THALOG.Execute;
var f:TextFile;
    IOError :integer;
   // fl:boolean;
    s:string;
begin
 repeat
  if fListLog.Count>0 then
   begin
    AssignFile(F, fFileName);
    if FileExists(fFileName) then
     Append(F)
    else
     Rewrite(F);

    IOError := IOResult;
   // fl:=false;
    if IOError = 0 then
    while fListLog.Count>0 do
     begin
     //  fl:=true;
       s:=fListLog[0];
       WriteLN(f,fListLog[0]);
       fListLog.Delete(0);
       IOError := IOResult;
       if IOError>0 then break;
       if fHandle<>0 then
         SendMessage(fHandle,wm_changehalog,integer(s),0);

       sleep(3);
     end;
    CloseFile(F);
   // if fl and (fHandle<>0) then
   //   PostMessage(fHandle,wm_changehalog,0,0);
   end
  else
   sleep(3);
 until Terminated;

end;

procedure THALOG.TerminateAndFree;
begin
 terminate;
 waitfor;
 free;

end;

initialization
 Log:=THALog.Create;
finalization
 Log.TerminateAndFree;
 Log:=nil;

end.
