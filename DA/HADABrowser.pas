unit HADABrowser;

interface
  uses
   ComObj, ActiveX, Windows,Classes, StdVcl,opcda,opccomn,
   opctypes,opcerror,AxCtrls;

  type

  TOPCDABrowser=class(TComObject, IOPCBrowseServerAddressSpace)
   private
    fCurrPath:TStringList;
   protected
    function QueryOrganization(out pNameSpaceType:OPCNAMESPACETYPE):HResult;stdcall;
    function ChangeBrowsePosition(dwBrowseDirection:OPCBROWSEDIRECTION;
                                  szString:POleStr):HResult;stdcall;
    function BrowseOPCItemIDs(dwBrowseFilterType:OPCBROWSETYPE; szFilterCriteria:POleStr;
                              vtDataTypeFilter:TVarType; dwAccessRightsFilter:DWORD;
                              out ppIEnumString:IEnumString):HResult;stdcall;
    function GetItemID(szItemDataID:POleStr; out szItemID:POleStr):HResult;stdcall;
    function BrowseAccessPaths(szItemID:POleStr; out ppIEnumString:IEnumString):HResult;stdcall;
   public
    constructor Create;
    destructor Destroy; override;
  end;
implementation
 uses ComServ,
  ha_classes,SysUtils,ha_OPCMan,ha_log,HA_ErrorCodes,
  HA_Types,ha_Utils,ha_Enum;
{ TOPCDABrowser }

function TOPCDABrowser.BrowseAccessPaths(szItemID: POleStr;
  out ppIEnumString: IEnumString): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 result:=E_NOTIMPL;
 AddLog(2,'BrowseAccessPaths',result,ErrorCodeToString(result));

end;

function TOPCDABrowser.BrowseOPCItemIDs(dwBrowseFilterType: OPCBROWSETYPE;
  szFilterCriteria: POleStr; vtDataTypeFilter: TVarType;
  dwAccessRightsFilter: DWORD; out ppIEnumString: IEnumString): HResult;
var
 L:TStringList;
 S,sFC:string;
 i,IDC,IDP:integer;
 Obj:THABaseObj;
 res:boolean;

begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 if vtDataTypeFilter<>vt_Empty then
  if not ValidVariantType(vtDataTypeFilter,vtDataTypeFilter) then
   begin
    result:=E_INVALIDARG;
    AddLog(2,'BrowseOPCItemIDs',result,ErrorCodeToString(result));
    exit;
   end;

 result:=S_OK;
  L:=TStringList.Create;
 try
  Obj:=OPCMan.GetDAObjectFromPath(fCurrPath,IDC,IDP);
  if Obj<>nil then
   if Obj.ClassID=ClassTag then
    begin
     result:=E_INVALIDARG;
     exit;
    end;

  {if szFilterCriteria<>nil then
   sFC:=szFilterCriteria
  else
   sFC:='';
   }
  res:=false;
  OPCMan.GetDANamesFromPath(Obj,L,dwBrowseFilterType,szFilterCriteria, vtDataTypeFilter,dwAccessRightsFilter,'',res);
  if dwBrowseFilterType=OPC_FLAT then
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
  AddLog(2,'BrowseOPCItemIDs',result,ErrorCodeToString(result));
 end;


end;

function TOPCDABrowser.ChangeBrowsePosition(
  dwBrowseDirection: OPCBROWSEDIRECTION; szString: POleStr): HResult;
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
  OPC_BROWSE_UP   : if fCurrPath.Count>0 then
                     begin
                      fCurrPath.Delete(fCurrPath.Count-1);
                     end
                    else
                      result:=e_fail;


  OPC_BROWSE_DOWN :  if s<>'' then
                       begin
                        fCurrPath.Add(s);
                        Obj:=OPCMan.GetDAObjectFromPath(fCurrPath,IDC,IDP);
                        if Obj=nil then
                          result:=E_INVALIDARG
                        else
                         if Obj.ClassID=ClassTag then
                          result:=E_INVALIDARG;

                       end
                      else
                       result:=E_INVALIDARG;


  OPC_BROWSE_TO   : if s<>'' then
                      begin
                       tmps:=TStringList.Create;
                       try
                         ParsePath(s,tmps);
                         Obj:=OPCMan.GetDAObjectFromPath(tmps,IDC,IDP);
                         if Obj=nil then
                            result:=E_INVALIDARG
                         else
                          if Obj.ClassID=ClassTag then
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

 AddLog(2,'ChangeBrowsePosition: dwBrowseDirection='+inttostr(dwBrowseDirection)+
           ' szString='+s,result,ErrorCodeToString(result));
end;



constructor TOPCDABrowser.Create;
begin
 inherited;
 fCurrPath:=TStringList.Create;
end;

destructor TOPCDABrowser.Destroy;
begin
  fCurrPath.Free;
  inherited;
end;

function TOPCDABrowser.GetItemID(szItemDataID: POleStr;
  out szItemID: POleStr): HResult;
var s,ss,sres:string;
    st:TStringList;
    i,IDC,IDP:integer;
    obj:THABaseObj;

begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;
 ss:=szItemDataID;

 if ss='' then
  begin
   result:=s_ok;
   ss:='';
   for i:=0 to fCurrPath.Count-1 do
    if ss='' then
     ss:=fCurrPath[i]
    else
     ss:=ss+BranchSep+fCurrPath[i];
   szItemID:=StringToLPOleStr(ss);
   AddLog(2,'GetItemId szItemDataID='+szItemDataID+' szItemID='+szItemID,result,ErrorCodeToString(result));
   exit;
  end;

 s:='';
 if pos(BranchSep,ss)=0 then
  for i:=0 to fCurrPath.Count-1 do
   if s='' then
    s:=fCurrPath[i]
   else
    s:=s+BranchSep+fCurrPath[i];

  if s<>'' then
   sres:=s+BranchSep+ss
  else
   sres:=ss;

 st:=TStringList.Create;
 ParsePath(sres,st);
 Obj:=OPCMan.GetDAObjectFromPath(st,IDC,IDP);
 if (Obj=nil) then
  result:=E_INVALIDARG
 else
  result:=S_OK;

 st.Free;

 if result=s_ok then
  szItemId:=StringToLPOLESTR(sres);


 AddLog(2,'GetItemId szItemDataID='+szItemDataID+' szItemID='+szItemID,result,ErrorCodeToString(result));


end;

function TOPCDABrowser.QueryOrganization(
  out pNameSpaceType: OPCNAMESPACETYPE): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;
 pNameSpaceType:=OPC_NS_HIERARCHIAL;
 result:=S_OK;
 AddLog(2,'QueryOrganization',result,ErrorCodeToString(result));

end;


initialization
 TComObjectFactory.Create(ComServer,
                          TOPCDABrowser,
                          IOPCBrowseServerAddressSpace,
                          'TOPCDABrowser',
                          'HA',
                           ciInternal,
                           tmApartment);
end.
