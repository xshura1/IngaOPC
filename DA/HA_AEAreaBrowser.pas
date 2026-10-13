unit HA_AEAreaBrowser;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, ActiveX, Classes, ComObj, IngaOPC_TLB, StdVcl,OPC_AE,
  OPCTypes,HA_Enum,ha_log,SysUtils,ha_ErrorCodes,ha_opcman,ha_classes,OPCError,
  haaeimp,ha_types;

type
  THAAEAreaBrowser = class(TAutoObject, IHAAEAreaBrowser,IOPCEventAreaBrowser)
  private
   fAEServer:THAAEOBJ;
   fBrowsePos:string;
   fCurrPath:TStringList;
   function GetOIDArea(Path:string):integer;
   function GetOIDSource(SName:string):integer;
  protected
    //IOPCEventAreaBrowser
    function ChangeBrowsePosition(
            dwBrowseDirection:          OPCAEBROWSEDIRECTION;
            szString:                   POleStr): HResult; stdcall;
    function BrowseOPCAreas(
            dwBrowseFilterType:         OPCAEBROWSETYPE;
            szFilterCriteria:           POleStr;
      out   ppIEnumString:              IEnumString): HResult; stdcall;
    function GetQualifiedAreaName(
            szAreaName:                 POleStr;
      out   pszQualifiedAreaName:       POleStr): HResult; stdcall;
    function GetQualifiedSourceName(
            szSourceName:               POleStr;
      out   pszQualifiedSourceName:     POleStr): HResult; stdcall;
  public
    constructor Create(AEServer:THAAEOBJ);
    destructor Destroy;override;
  end;

implementation

uses ComServ,Masks,ha_utils;

{ THAAEAreaBrowser }

function THAAEAreaBrowser.BrowseOPCAreas(
  dwBrowseFilterType: OPCAEBROWSETYPE; szFilterCriteria: POleStr;
  out ppIEnumString: IEnumString): HResult;
{var L:TStringList;
    i,OIDTmp:integer;
    sFC:string;
    fl:boolean;
begin}

var
 L:TStringList;
 sFC:string;
 Obj:THABaseObj;
begin
 result:=S_OK;
 L:=TStringList.Create;
 try
  Obj:=OPCMan.GetAEObjectFromPath(fCurrPath);
  if Obj<>nil then
   if Obj.ClassID=ClassController then
    begin
     result:=E_INVALIDARG;
     exit;
    end;

  if szFilterCriteria<>nil then
   sFC:=szFilterCriteria
  else
   sFC:='';

  OPCMan.GetAENamesFromPath(Obj,L,dwBrowseFilterType,sFC);

  if L.Count=0 then
    result:=S_FALSE;

  ppIEnumString:=TOPCStringsEnumerator.Create(L);

 finally
  L.Free;
  AddLog(5,'BrowseOPCItemIDs',result,ErrorCodeToString(result));
 end;


 {if szFilterCriteria<>nil then
   sFC:=szFilterCriteria
 else
   sFC:='';

 fl:=sFC<>'';

 L:=TStringList.Create;
 try
  case dwBrowseFilterType of
   OPC_AREA:if fBrowsePos='' then
             for i:=0 to OPCMan.CountTemplates-1 do
              if fl then
               begin
                if MatchesMask(OPCMan.Templates[i].NameObj,sFC) then
                 L.Add(OPCMan.Templates[i].NameObj);
               end
              else
               L.Add(OPCMan.Templates[i].NameObj);

   OPC_SOURCE:if fBrowsePos<>'' then
               begin
                oidtmp:=-1;
                for i:=0 to OPCMan.CountTemplates-1 do
                 if CompareStr(fBrowsePos,OPCMan.Templates[i].NameObj)=0 then
                  begin
                   oidtmp:=OPCMan.Templates[i].OID;
                   break;
                  end;
                if oidtmp>-1 then
                 begin
                  for i:=0 to OPCMan.Controllers.Count-1 do
                   if TIGDevice(OPCMan.Controllers[i]).Template.OID=oidtmp then
                    if fl then
                     begin
                      if MatchesMask(TIGDevice(OPCMan.Controllers[i]).NameObj,sFC) then
                       L.Add(TIGDevice(OPCMan.Controllers[i]).NameObj);
                     end
                    else
                      L.Add(TIGDevice(OPCMan.Controllers[i]).NameObj);
                 end;

               end;

  end;


  ppIEnumString:=TOPCStringsEnumerator.Create(L);
  if l.Count=0 then
   result:=s_false
  else
   result:=s_ok;
 finally
  L.Free;
 end;
  }
end;

function THAAEAreaBrowser.ChangeBrowsePosition(
  dwBrowseDirection: OPCAEBROWSEDIRECTION; szString: POleStr): HResult;
var i:integer;
    s:string;
    Obj:THABaseObj;
    tmps:TStringList;
begin
 if not Assigned(szString) then
  s:=''
 else
  s:=szString;

 result:=S_OK;
 case dwBrowseDirection of
  OPCAE_BROWSE_UP   : if fCurrPath.Count>0 then
                       fCurrPath.Delete(fCurrPath.Count-1)
                      else
                       result:=e_fail;


  OPCAE_BROWSE_DOWN :if s<>'' then
                       begin
                        fCurrPath.Add(s);
                        Obj:=OPCMan.GetAEObjectFromPath(fCurrPath);
                        if Obj=nil then
                          result:=OPC_E_INVALIDBRANCHNAME
                        else
                         if Obj.ClassID=ClassController then
                          result:=OPC_E_INVALIDBRANCHNAME;
                       end
                      else
                       result:=E_INVALIDARG;


  OPCAE_BROWSE_TO   :if s<>'' then
                      begin
                       tmps:=TStringList.Create;
                       try
                         ParsePath(s,tmps);
                         Obj:=OPCMan.GetAEObjectFromPath(tmps);
                         if Obj=nil then
                          result:=OPC_E_INVALIDBRANCHNAME
                         else
                          if Obj.ClassID=ClassController then
                            result:=OPC_E_INVALIDBRANCHNAME;

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
 AddLog(2,'ChangeBrowsePosition: dwBrowseDirection='+inttostr(dwBrowseDirection)+
           ' szString='+s,result,ErrorCodeToString(result));

end;

constructor THAAEAreaBrowser.Create(AEServer: THAAEOBJ);
begin
 inherited Create;
 fCurrPath:=TStringList.Create;
 fAEServer:=AEServer;
 fAEServer.AddAreaBrowser(self);
end;

destructor THAAEAreaBrowser.Destroy;
begin
  fAEServer.DeleteAreaBrowser(self);
  fCurrPath.Free;
  inherited;
end;

function THAAEAreaBrowser.GetOIDArea(Path: string): integer;
var i:integer;
begin
 result:=-1;
 for i:=0 to OPCMan.CountTemplates-1 do
  if CompareStr(Path,OPCMan.Templates[i].NameObj)=0 then
   begin
    result:=OPCMan.Templates[i].OID;
    break;
   end;
end;

function THAAEAreaBrowser.GetOIDSource(SName: string): integer;
var i,oidtmp:integer;
begin
 result:=-1;
 oidtmp:=GetOIDArea(fBrowsePos);
 if oidtmp<0 then exit;
 for i:=0 to OPCMan.CountControllers-1 do
  if OPCMan.Controllers[i].Template.OID=oidtmp then
   if CompareStr(SName,OPCMan.Controllers[i].NameObj)=0 then
    begin
     result:=OPCMan.Controllers[i].OID;
     break;
    end;
end;

function THAAEAreaBrowser.GetQualifiedAreaName(szAreaName: POleStr;
  out pszQualifiedAreaName: POleStr): HResult;
var s:string;
    st:TStringList;
    i:integer;
    obj:THABaseObj;
begin
 s:=szAreaName;
 {if ss='' then
  begin
   result:=s_ok;
   for i:=0 to fCurrPath.Count-1 do
    if ss='' then
     ss:=fCurrPath[i]
    else
     ss:=ss+BranchSep+fCurrPath[i];
   pszQualifiedAreaName:=StringToLPOleStr(ss);
   AddLog(5,'GetItemId szItemDataID='+szItemDataID+' szItemID='+szItemID,result,ErrorCodeToString(result));
   exit;
  end;
  }

 st:=TStringList.Create;
 try
   for i:=0 to fCurrPath.Count-1 do
    st.Add(fCurrPath[i]);

   st.Add(s);
   Obj:=OPCMan.GetAEObjectFromPath(st);
   if (Obj=nil) then
    result:=E_INVALIDARG
   else
    if Obj.ClassID=ClassController then
     result:=E_INVALIDARG
    else
     result:=S_OK;


   if result=s_ok then
    begin
     s:='';
     for i:=0 to st.Count-1 do
      if s='' then
       s:=st[i]
      else
       s:=s+BranchSep+st[i];

      pszQualifiedAreaName:=StringToLPOLESTR(s);
    end;
 finally
  st.Free;
 end;

// AddLog(5,'GetItemId szItemDataID='+szItemDataID+' szItemID='+szItemID,result,ErrorCodeToString(result));

{ if GetOIDArea(szAreaName)<0 then
  begin
   result:=E_INVALIDARG;
   exit;
  end;
 pszQualifiedAreaName:=szAreaName;
 result:=s_ok;}
end;

function THAAEAreaBrowser.GetQualifiedSourceName(szSourceName: POleStr;
  out pszQualifiedSourceName: POleStr): HResult;
var s:string;
    st:TStringList;
    i:integer;
    obj:THABaseObj;
begin
 s:=szSourceName;
 {if ss='' then
  begin
   result:=s_ok;
   for i:=0 to fCurrPath.Count-1 do
    if ss='' then
     ss:=fCurrPath[i]
    else
     ss:=ss+BranchSep+fCurrPath[i];
   pszQualifiedAreaName:=StringToLPOleStr(ss);
   AddLog(5,'GetItemId szItemDataID='+szItemDataID+' szItemID='+szItemID,result,ErrorCodeToString(result));
   exit;
  end;
  }

 st:=TStringList.Create;
 try
   for i:=0 to fCurrPath.Count-1 do
    st.Add(fCurrPath[i]);

   st.Add(s);
   Obj:=OPCMan.GetAEObjectFromPath(st);
   if (Obj=nil) then
    result:=E_INVALIDARG
   else
    if Obj.ClassID<>ClassController then
     result:=E_INVALIDARG
    else
     result:=S_OK;


   if result=s_ok then
    begin
     s:='';
     for i:=0 to st.Count-1 do
      if s='' then
       s:=st[i]
      else
       s:=s+BranchSep+st[i];

      pszQualifiedSourceName:=StringToLPOLESTR(s);
    end;
 finally
  st.Free;
 end;

{ if GetOIDSource(szSourceName)<0 then
  begin
   result:=E_INVALIDARG;
   exit;
  end;
 pszQualifiedSourceName:=szSourceName;
 result:=s_ok;}
end;

initialization
  TAutoObjectFactory.Create(ComServer, THAAEAreaBrowser, Class_HAAEAreaBrowser,
    ciInternal, tmFree);
end.
