unit HAHDABrowser;
 {$I IngaOPC.inc}
interface
{$IFDEF HDAINTERFACE}


 uses
  Windows, Messages,ComObj, ActiveX, StdVcl,OPCHDA,SysUtils, Variants,
  Classes,OPCTypes,ha_utils,OPCCOMN,HA_ErrorCodes,AxCtrls,HA_Enum;

 type
  THA_HDABrowser=class(TInterfacedObject,IOPCHDA_Browser)
   private
    fCurrPath:TStringList;
   protected
    function GetEnum(
            dwBrowseType:               OPCHDA_BROWSETYPE;
      out   ppIEnumString:              IEnumString): HResult; stdcall;
    function ChangeBrowsePosition(
            dwBrowseDirection:          OPCHDA_BROWSEDIRECTION;
            szString:                   POleStr): HResult; stdcall;
    function GetItemID(
            szNode:                     POleStr;
      out   pszItemID:                  POleStr): HResult; stdcall;
    function GetBranchPosition(
      out   pszBranchPos:               POleStr): HResult; stdcall;
   public
    constructor Create;
    destructor Destroy; override;
  end;
{$ENDIF}
implementation
{$IFDEF HDAINTERFACE}

 uses ha_classes,ha_opcman,ha_types,ha_log;

{ THA_HDABrowser }

function THA_HDABrowser.ChangeBrowsePosition(
  dwBrowseDirection: OPCHDA_BROWSEDIRECTION; szString: POleStr): HResult;
var IDC,IDP,i:integer;
    s:string;
    Obj:THABaseObj;
    tmps:TStringList;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 if not Assigned(szString) then
  s:=''
 else
  s:=szString;


 result:=S_OK;

 case dwBrowseDirection of
  OPCHDA_BROWSE_UP   :if fCurrPath.Count>0 then
                         fCurrPath.Delete(fCurrPath.Count-1)
                      else
                        result:=e_fail;


  OPCHDA_BROWSE_DOWN : if s<>'' then
                       begin
                        fCurrPath.Add(s);
                        Obj:=OPCMan.GetHDAObjectFromPath(fCurrPath);
                        if Obj=nil then
                          result:=E_INVALIDARG
                        else
                         if Obj.ClassID=ClassTagHDA then
                          result:=E_INVALIDARG;

                       end
                      else
                       result:=E_INVALIDARG;


  OPCHDA_BROWSE_DIRECT:if s<>'' then
                        begin
                         tmps:=TStringList.Create;
                         try
                          ParsePath(s,tmps);
                          Obj:=OPCMan.GetHDAObjectFromPath(tmps);
                          if Obj=nil then
                            result:=E_INVALIDARG
                          else
                           if Obj.ClassID=ClassTagHDA then
                            result:=E_INVALIDARG;

                          if result=s_ok then
                           begin
                            fCurrPath.Clear;
                            for i:=0 to tmps.Count-1 do
                            fCurrPath.Add(tmps[i]);
                           end;
                         finally
                           tmps.Free;
                         end;
                        end
                       else
                         fCurrPath.Clear;
 end;

 AddLog(2,'THA_HDABrowser.ChangeBrowsePosition='+inttostr(dwBrowseDirection)+
           ' szString='+s,result,ErrorCodeToString(result));

end;



constructor THA_HDABrowser.Create;
begin
  inherited;
  fCurrPath:=TStringList.Create;
end;

destructor THA_HDABrowser.Destroy;
begin
  fCurrPath.free;
  inherited;
end;

function THA_HDABrowser.GetBranchPosition(
  out pszBranchPos: POleStr): HResult;
var s:string;
    i:integer;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;
 
  s:='';
  for i:=0 to fCurrPath.Count-1 do
   if s='' then
    s:=fCurrPath[i]
   else
    s:=s+BranchSep+fCurrPath[i];

  pszBranchPos:=StringToLPOleStr(s);
  result:=s_ok;
end;

function THA_HDABrowser.GetEnum(dwBrowseType: OPCHDA_BROWSETYPE;
  out ppIEnumString: IEnumString): HResult;
var
 L:TStringList;
 S:string;
 i:integer;
 Obj:THABaseObj;
 
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 if not (dwBrowseType in [OPCHDA_BRANCH, OPCHDA_LEAF, OPCHDA_FLAT, OPCHDA_ITEMS]) then
  begin
   result:=E_FAIL;
   exit;
  end;

 result:=S_OK;
  L:=TStringList.Create;
 try
  Obj:=OPCMan.GetHDAObjectFromPath(fCurrPath);
  if Obj<>nil then
   if Obj.ClassID=ClassTagHDA then
    begin
     result:=E_INVALIDARG;
     exit;
    end;


  result:=S_OK;
  OPCMan.GetHDANamesFromPath(Obj,L,dwBrowseType,'');
  if dwBrowseType=OPCHDA_FLAT then
   begin
    s:='';
    for i:=0 to fCurrPath.Count-1 do
     if s<>'' then
      s:=s+BranchSep+fCurrPath[i]
     else
      s:=fCurrPath[i];

    if s<>'' then
     for i:=0 to L.Count-1 do
       L[i]:=s+BranchSep+L[i];

   end;

  if L.Count=0 then
    result:=S_FALSE;

  ppIEnumString:=TOPCStringsEnumerator.Create(L);

 finally
  L.Free;
  AddLog(2,'THA_HDABrowser.GetEnum',result,ErrorCodeToString(result));
 end;


end;

function THA_HDABrowser.GetItemID(szNode: POleStr;
  out pszItemID: POleStr): HResult;
var s:string;
    st:TStringList;
    Obj:THABaseObj;
    i:integer;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;
 
 result:=E_FAIL;
 s:=szNode;
 if s='' then  exit;
 fCurrPath.Add(s);
 try
   Obj:=OPCMan.GetHDAObjectFromPath(fCurrPath);
   if Obj=nil then exit;
   if Obj.ClassID<>ClassTagHDA then exit;
   s:='';
   for i:=0 to fCurrPath.Count-1 do
    if s='' then
     s:=fCurrPath[i]
    else
     s:=s+BranchSep+fCurrPath[i];

   pszItemID:=stringToLPOleStr(s);
   result:=s_ok;
 finally
  fCurrPath.Delete(fCurrPath.Count-1);
 end;

end;



{$ENDIF}
end.
