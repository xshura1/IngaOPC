unit HA_Filters;

interface
 uses
  Windows, Messages, SysUtils, Variants, Classes, uPSCompiler, uPSRuntime,
  uPSComponent,uPSUtils;

 type
  THATypeScript= (ts_Filter,ts_Sort);
  THAFilter=class(TObject)
   private
    fPSScript:TPSScript;

    fScript:string;
    fTypeScript:THATypeScript;
    fResultCompile:boolean;

    fErrors:string;

    fObject:TObject;
    function CompileScript:boolean;
    function ExecuteScript:boolean;


    procedure PSCompImport(Sender: TObject; x: TPSPascalCompiler);
    procedure PSCompile(Sender: TPSScript);
    procedure PSExecute(sender:TPSScript);
    procedure PSExecImport(Sender: TObject; se: TPSExec; x: TPSRuntimeClassImporter);
    procedure PSAfterExecute(Sender: TPSScript);
   public
    constructor Create;
    destructor Destroy; override;
    function SetScript(Script:string; TypeScript:THATypeScript):boolean;
    function ExecFilter(Obj:TObject; out ResultExec:boolean):boolean;
    function ExecSort(Obj1,Obj2:TObject; out ResultExec:boolean):integer;
  end;


implementation
  uses ha_classes;
{ THATagsFilter }







constructor THAFilter.Create;
begin
 inherited;
 fObject:=nil;
 fPSScript:=TPSScript.Create(nil);
 //fPSScript.Comp.AllowNoBegin:=true;
// fPSScript.Comp.AllowNoEnd:=true;
 fPSScript.OnCompile:=PSCompile;
 fPSScript.OnCompImport:=PSCompImport;
 fPSScript.OnExecImport:=PSExecImport;
 fPSScript.OnExecute:=PSExecute;
// fPSScript.OnAfterExecute:=PSAfterExecute;
end;

destructor THAFilter.Destroy;
begin
  fPSScript.Free;
  inherited;
end;


function THAFilter.CompileScript: boolean;
const
 fmt='begin res:=(%s); end.';
begin
 fPSScript.Script.Text:=fScript;//format(fmt,[fScript]);
 result:=fPSScript.Compile;
 fResultCompile:=result;
end;


function THAFilter.ExecuteScript: boolean;
begin
 result:=fPSScript.Execute;
end;

procedure THAFilter.PSCompile(Sender: TPSScript);
begin
 case fTypeScript of
  ts_Filter:begin
             Sender.AddRegisteredVariable('RES','BOOLEAN');
             Sender.AddRegisteredVariable('TAG','TIGTAG');
            end;
  ts_Sort:  begin
             Sender.AddRegisteredVariable('RES','INTEGER');
             Sender.AddRegisteredVariable('TAG1','TIGTAG');
             Sender.AddRegisteredVariable('TAG2','TIGTAG');
            end;
 end;
end;

procedure THAFilter.PSCompImport(Sender: TObject;
  x: TPSPascalCompiler);
begin
  SIRegisterHAOBJ(x);
end;

procedure THAFilter.PSExecImport(Sender: TObject; se: TPSExec;
  x: TPSRuntimeClassImporter);
begin
  RIRegisterHAOBJ(x,se);
end;

procedure THAFilter.PSExecute(sender: TPSScript);
begin

end;

function THAFilter.SetScript(Script: string; TypeScript:THATypeScript): boolean;
var i:integer;

begin
 fTypeScript:=TypeScript;

 case fTypeScript of
  ts_Filter: fScript:=format('begin res:=(%s); end.',[Script]);
  ts_Sort  : fScript:=format('begin %s end.',[Script]);
 end;
 
 fErrors:='';
 result:=CompileScript;
 if not result then
  begin

   for i:=0 to fPSScript.CompilerMessageCount-1 do
    fErrors:=fErrors+fPSScript.CompilerErrorToStr(i);
  end;

end;

procedure THAFilter.PSAfterExecute(Sender: TPSScript);
//var P:PPSVariant;
begin
{ for i:=0 to Sender.Exec.GlobalVarNames.Count-1 do
  if CompareText('RES',Sender.Exec.GlobalVarNames[i])=0 then
   begin
     p:=Sender.Exec.GetGlobalVar(i);
     if p<>nil then
      if p.FType.BaseType=btU8 then
       fResult:=(PPSVariantU8(p)^.Data);
     break;
   end;}
end;

function THAFilter.ExecFilter(Obj: TObject; out ResultExec:boolean):boolean;
var s:string;
    i:integer;
    P:PPSVariant;
begin
 //fResult:=0;
 ResultExec:=false;
 result:=false;

 if fScript='' then exit;
 if not fResultCompile then exit;

 fObject:=Obj;
 if fObject=nil then exit;
 if fObject is TIGTag then
  s:='TAG';

 fPSScript.SetVarToInstance(s,fObject);
 ResultExec:=ExecuteScript;
// Result:=boolean(fResult);

 for i:=0 to fPSScript.Exec.GlobalVarNames.Count-1 do
  if CompareText('RES',fPSScript.Exec.GlobalVarNames[i])=0 then
   begin
     p:=fPSScript.Exec.GetGlobalVar(i);
     if p<>nil then
      if p.FType.BaseType=btU8 then
       Result:=boolean(PPSVariantU8(p)^.Data);
     break;
   end;

end;

function THAFilter.ExecSort(Obj1,Obj2: TObject;
  out ResultExec: boolean): integer;
var i:integer;
    P:PPSVariant;
begin
 ResultExec:=false;
 result:=0;

 if fScript='' then exit;
 if not fResultCompile then exit;

// fObject:=Obj;
 if (Obj1=nil) or (Obj2=nil) then exit;

 fPSScript.SetVarToInstance('TAG1',Obj1);
 fPSScript.SetVarToInstance('TAG2',Obj2);

 ResultExec:=ExecuteScript;

 for i:=0 to fPSScript.Exec.GlobalVarNames.Count-1 do
  if CompareText('RES',fPSScript.Exec.GlobalVarNames[i])=0 then
   begin
     p:=fPSScript.Exec.GetGlobalVar(i);
     if p<>nil then
      if p.FType.BaseType=btS32 then
       Result:=(PPSVariantS32(p)^.Data);
     break;
   end;


end;

end.
