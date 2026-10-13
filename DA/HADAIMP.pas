unit HADAIMP;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  ComObj, ActiveX, Windows,Classes,IngaOPC_TLB, StdVcl,opcda,opccomn,
  opctypes,opcerror,AxCtrls,ha_classes,SysUtils,HADABrowser;

type
  THADAOBJ = class(TAutoObject,
                   IHADAOBJ,
                   IOPCBrowseServerAddressSpace,
                   IOPCCommon,
                   IConnectionPointContainer,
                   IOPCServer,
                   IOPCItemProperties{,
                   IOPCServerPublicGroups})
  private
   FConnectionPoints:TConnectionPoints;
   FConnectionPoint:TConnectionPoint;
   FOPCDABrowser:TOPCDABrowser;
   fClientIUnknown:IUnknown;
   fLocaleID:LCID;
   fClientName:string;

   fListGroup:TList;
   fCurrPath:TStringList;
   fHandle:dword;




    procedure ShutdownOnConnect(const Sink: IUnknown; Connecting: Boolean);
    function GetGroupCount: integer;
    function GetSupportIOPCShutdown: boolean;
    function GetGroup(index: integer): TComObject;
    function GetNoConfigAsOPCMan: boolean;
  protected
    property iFIConnectionPoints:TConnectionPoints read FConnectionPoints write FConnectionPoints implements IConnectionPointContainer;
    property iFOPCDABrowser:TOPCDABrowser read FOPCDABrowser write FOPCDABrowser implements IOPCBrowseServerAddressSpace;
  //IOPCServer
    function AddGroup(szName:POleStr;bActive:BOOL; dwRequestedUpdateRate:DWORD;
                      hClientGroup:OPCHANDLE; pTimeBias:PLongint; pPercentDeadband:PSingle;
                      dwLCID:DWORD; out phServerGroup: OPCHANDLE;
                                    out pRevisedUpdateRate:DWORD;
                                    const riid: TIID;
                                    out ppUnk:IUnknown):HResult; overload; stdcall;
    function GetErrorString(dwError:HResult; dwLocale:TLCID; out ppString:POleStr):HResult;overload; stdcall;
    function GetGroupByName(szName:POleStr; const riid: TIID; out ppUnk:IUnknown):HResult; stdcall;
    function GetStatus(out ppServerStatus:POPCSERVERSTATUS): HResult; stdcall;
    function RemoveGroup(hServerGroup: OPCHANDLE; bForce: BOOL): HResult; stdcall;
    function CreateGroupEnumerator(dwScope:OPCENUMSCOPE; const riid:TIID; out ppUnk:IUnknown):HResult; stdcall;
  //opccomn
    function SetLocaleID(dwLcid:TLCID): HResult; stdcall;
    function GetLocaleID(out   pdwLcid:TLCID): HResult; stdcall;
    function QueryAvailableLocaleIDs(out   pdwCount:UINT; out   pdwLcid:PLCIDARRAY): HResult; stdcall;
    function GetErrorString(dwError:HResult; out   ppString:POleStr): HResult;overload; stdcall;
    function SetClientName(szName:POleStr): HResult; stdcall;

  //IOPCBrowseServerAddressSpace
   { function QueryOrganization(out pNameSpaceType:OPCNAMESPACETYPE):HResult;stdcall;
    function ChangeBrowsePosition(dwBrowseDirection:OPCBROWSEDIRECTION;
                                  szString:POleStr):HResult;stdcall;
    function BrowseOPCItemIDs(dwBrowseFilterType:OPCBROWSETYPE; szFilterCriteria:POleStr;
                              vtDataTypeFilter:TVarType; dwAccessRightsFilter:DWORD;
                              out ppIEnumString:IEnumString):HResult;stdcall;
    function GetItemID(szItemDataID:POleStr; out szItemID:POleStr):HResult;stdcall;
    function BrowseAccessPaths(szItemID:POleStr; out ppIEnumString:IEnumString):HResult;stdcall;
    }
    // IOPCItemProp
    function QueryAvailableProperties(szItemID:POleStr; out pdwCount:DWORD;
                                      out ppPropertyIDs:PDWORDARRAY; out ppDescriptions:POleStrList;
                                      out ppvtDataTypes:PVarTypeList):HResult;stdcall;
    function GetItemProperties(szItemID:POleStr;
                               dwCount:DWORD;
                               pdwPropertyIDs:PDWORDARRAY;
                               out ppvData:POleVariantArray;
                               out ppErrors:PResultList):HResult;stdcall;
    function LookupItemIDs(szItemID:POleStr; dwCount:DWORD; pdwPropertyIDs:PDWORDARRAY;
                           out ppszNewItemIDs:POleStrList;out ppErrors:PResultList): HResult; stdcall;

    function GetPublicGroupByName(szName:POleStr; const riid:TIID; out ppUnk:IUnknown):HResult;stdcall;
    function RemovePublicGroup(hServerGroup:OPCHANDLE; bForce:BOOL):HResult;stdcall;
   public
    procedure Initialize; override;
    procedure ShutDown(Force:boolean);
    destructor Destroy;override;
    procedure DeleteGroup(Group:TComObject);
    procedure AddGroup(Group:TComObject); overload;
    property Groups[index:integer]:TComObject read GetGroup;
    function GetGroupByHandle(AHandle:dword):TComObject;
    function ExistsNameGroup(Name: string):boolean;
    property LocaleID:LCID read fLocaleID;
    property ClientIUnknown:IUnknown read fClientIUnknown;
    property GroupCount:integer read GetGroupCount;
    property hServer:dword read fHandle;
    property IsSupportIOPCShutdown:boolean read GetSupportIOPCShutdown;
//    property GroupsIsUpdate:boolean read GetGroupIsUpdate;
    property ClientName:string read fClientName;
    property NoConfigAsOPCMan:boolean read GetNoConfigAsOPCMan;
  end;

implementation

uses ComServ, HA_OPCMan, HA_Enum,HA_Utils,HA_DAGroup,ha_log,
     ha_types, variants,HA_Errorcodes;



{ THADAOBJ }

function THADAOBJ.AddGroup(szName: POleStr; bActive: BOOL;
  dwRequestedUpdateRate: DWORD; hClientGroup: OPCHANDLE;
  pTimeBias: PLongint; pPercentDeadband: PSingle; dwLCID: DWORD;
  out phServerGroup: OPCHANDLE; out pRevisedUpdateRate: DWORD;
  const riid: TIID; out ppUnk: IInterface): HResult;
var g:THADAGroup;
    sname:string;



begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 sname:=szName;
 if not (IsEqualIID(riid, IID_IOPCItemMgt) or
         IsEqualIID(riid, IID_IUnknown) or
         IsEqualIID(riid, IID_IConnectionPointContainer) or
         IsEqualIID(riid, IID_IOPCGroupStateMgt) or
         IsEqualIID(riid, IID_IOPCSyncIO) or
         IsEqualIID(riid, IID_IOPCAsyncIO2)) then

  begin
    phServerGroup:=0;
    result:=E_NOINTERFACE;
    AddLog(2,'AddGroup '+sName,result,ErrorCodeToString(result));
    exit;
  end;


 if sname='' then
  begin
   sname:='Group'+inttostr(OPCMan.GenUniI);
   while ExistsNameGroup(sName) do
    sname:='Group'+inttostr(OPCMan.GenUniI);
  end
 else
  if ExistsNameGroup(sName) then
  begin
   phServerGroup:=0;
   result:=OPC_E_DUPLICATENAME;
   AddLog(2,'AddGroup '+sName,result,ErrorCodeToString(result));
   exit;
  end;

 g:=THADAGroup.Create(self,
                      sName,
                      bActive,
                      dwRequestedUpdateRate,
                      hClientGroup,
                      pTimeBias,
                      pPercentDeadband,
                      dwLCID);


//  if (g as IHADAGroup).QueryInterface(riid,ppUnk)<>s_ok then
  result:=IUnknown(g).QueryInterface(riid,ppUnk);
 { if result<>s_ok then
   begin
    phServerGroup:=0;
    //result:=E_NOINTERFACE;
    g.Free;
    exit;
   end;
  }

 g.ObjAddRef;
 pRevisedUpdateRate:=g.UpdateRate;

 if g.UpdateRate>dwRequestedUpdateRate then
  result:=OPC_S_UNSUPPORTEDRATE;

// g.hServerGroup:=OPCMan.GenUniI; //OPCMan.AddComObject(g,fHandle);
 phServerGroup:=g.hServerGroup;
 fListGroup.Add(g);
 AddLog(2,'AddGroup '+sName,result,ErrorCodeToString(result));
end;

function THADAOBJ.GetErrorString(dwError: HResult; dwLocale: TLCID;
  out ppString: POleStr): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 ppString:=StringToLPoleStr(ErrorCodeToString(dwError));
 result:=S_OK;
end;

function THADAOBJ.GetGroupByName(szName: POleStr; const riid: TIID;
  out ppUnk: IInterface): HResult;
var i:integer;
    co:THADAGroup;
    s:string;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 s:=szName;
 if s='' then
  begin
   result:=E_INVALIDARG;
   AddLog(2,'GetGroupByName '+s,result,ErrorCodeToString(result));
   exit;
  end;

 co:=nil;
    for i:=0 to fListGroup.Count-1 do
      if THADAGroup(fListGroup[i]).NameGroup=s then
        if not THADAGroup(fListGroup[i]).Deleted then
         begin
          co:=THADAGroup(fListGroup[i]);
          break;
         end;


     if (co=nil) or (addr(ppUnk) = nil) then
      begin
       result:=E_INVALIDARG;
       AddLog(2,'GetGroupByName '+s,result,ErrorCodeToString(result));
       exit;
      end;

     result:=IUnknown(co).QueryInterface(riid,ppUnk);
end;

function THADAOBJ.GetStatus(out ppServerStatus: POPCSERVERSTATUS): HResult;
begin
 if (addr(ppServerStatus) = nil) then
  begin
   Result:=E_INVALIDARG;
   AddLog(2,'GetStatus',result,ErrorCodeToString(result));
   Exit;
  end;


 ppServerStatus:=OPCTaskMemAlloc(result, sizeof(OPCSERVERSTATUS),1);

 if ppServerStatus = nil then
  begin
   AddLog(2,'GetStatus',result,ErrorCodeToString(result));
   Exit;
  end;

 result:=S_OK;
 AddLog(2,'GetStatus',result,ErrorCodeToString(result));

 ppServerStatus.ftStartTime:=OPCMan.TimeRun;
 ppServerStatus.ftCurrentTime:=ConvertToFileTime(now);
 if {OPCMan.AddedItems or } OPCMan.Stopped then
  ppServerStatus.dwServerState:=OPC_STATUS_FAILED
 else
  if OPCMan.AddedItems then
   ppServerStatus.dwServerState:=OPC_STATUS_NOCONFIG
  else
   ppServerStatus.dwServerState:=OPC_STATUS_RUNNING;


 ppServerStatus.dwGroupCount:=GetGroupCount; //OPCMan.GetCountComObjects(fHandle);
 ppServerStatus.dwBandWidth:=100;
 ppServerStatus.wMajorVersion:=1;
 ppServerStatus.wMinorVersion:=1;
 ppServerStatus.wBuildNumber:=1;
 ppServerStatus.szVendorInfo:=StringToLPOLESTR('Integral+');


end;

function THADAOBJ.RemoveGroup(hServerGroup: OPCHANDLE;
  bForce: BOOL): HResult;
var i,j:integer;
    co: THADAGroup;
    s:string;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 if hServerGroup < 1 then
  begin
   result:=E_INVALIDARG;
   AddLog(2,'RemoveGroup',result,ErrorCodeToString(result));
   Exit;
  end;

 co:=nil;
 j:=-1;
 for i:=0 to fListGroup.Count-1 do
  if THADAGroup(fListGroup[i]).hServerGroup=hServerGroup then
   begin
    co:=THADAGroup(fListGroup[i]);
    j:=i;
    break;
   end;

 if co=nil then
  begin
   result:=E_INVALIDARG;
   AddLog(2,'RemoveGroup',result,ErrorCodeToString(result));
   Exit;
  end;


     s:=co.NameGroup;
      // group is already removed from internal list at this point
      if co.RefCount = 1 then
       begin
        // server owns the only reference, release it...
        co.ObjRelease;
        Result:= S_OK;
        AddLog(2,'RemoveGroup '+s,result,ErrorCodeToString(result));
       end
      else
       begin
        if bForce then
          begin
           // there are several references, release forced...
           // !!! LOOK HERE !!!
          // coDisconnectObject(co as IHADAGroup,0);
           co.Free;
           Result:= S_OK;
           AddLog(2,'RemoveGroup '+s,result,ErrorCodeToString(result));
          end
        else
          begin
           // there are several references, mark as deleted...
           co.SetDeleted;
           // release server reference
           while co.refcount>1 do
            co.ObjRelease;
           Result:= OPC_S_INUSE;
           AddLog(2,'RemoveGroup '+s,result,ErrorCodeToString(result));
          end;
       end;


end;

function THADAOBJ.CreateGroupEnumerator(dwScope: OPCENUMSCOPE;
  const riid: TIID; out ppUnk: IInterface): HResult;
var LS:TStringList;
    LU:TInterfaceList;
    i:integer;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

  if IsEqualIID(riid,IID_IEnumString) then
   begin
    LS:=TStringList.Create;
    try
     Result := S_OK;
     case dwScope of
      OPC_ENUM_PRIVATE_CONNECTIONS, OPC_ENUM_PRIVATE,
      OPC_ENUM_ALL_CONNECTIONS, OPC_ENUM_ALL         : for i:=0 to fListGroup.Count-1 do
                                                         if not THADAGroup(fListGroup[i]).Deleted then
                                                           LS.Add(THADAGroup(fListGroup[i]).NameGroup);

     end;

     if ls.Count=0 then
       result:=s_false;

     ppUnk:=TOPCStringsEnumerator.Create(LS);
    finally
     LS.Free;
     AddLog(2,'CreateGroupEnumerator as IEnumString',result,ErrorCodeToString(result));
     
    end;

   end
  else
   if IsEqualIID(riid,IID_IEnumUnknown) then
    begin
      LU:=TInterfaceList.Create;
      try
       Result := S_OK;
       case dwScope of
        OPC_ENUM_PRIVATE_CONNECTIONS, OPC_ENUM_PRIVATE,
        OPC_ENUM_ALL_CONNECTIONS, OPC_ENUM_ALL         :for i:=0 to fListGroup.Count-1 do
                                                         if not THADAGroup(fListGroup[i]).Deleted then
                                                           LU.Add(TComObject(fListGroup[i]));


       end;

       if lu.Count=0 then
         result:=s_false;

       ppUnk:=TOPCUnknownEnumerator.Create(LU);
      finally
       LU.Free;
       AddLog(2,'CreateGroupEnumerator as IEnumUnknown',result,ErrorCodeToString(result));

      end;
    end
   else
    begin
     result:=E_NOINTERFACE;
     AddLog(2,'CreateGroupEnumerator',result,ErrorCodeToString(result));
    end;
end;






function THADAOBJ.SetLocaleID(dwLcid: TLCID): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 if  (dwLcid<>LOCALE_SYSTEM_DEFAULT) and (dwLcid<>LOCALE_USER_DEFAULT) then
  result:=E_INVALIDARG
 else
  begin
   fLocaleId:=dwLcid;
   result:=S_OK;
  end;
 AddLog(2,'SetLocaleID',result,ErrorCodeToString(result));
end;

function THADAOBJ.GetLocaleID(out pdwLcid: TLCID): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 pdwLcid:=fLocaleId;
 result:=S_OK;
 AddLog(2,'GetLocaleID',result,ErrorCodeToString(result));
end;

function THADAOBJ.QueryAvailableLocaleIDs(out pdwCount: UINT;
  out pdwLcid: PLCIDARRAY): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 pdwCount:=2;
 pdwLcid:=OPCTaskMemAlloc(Result,sizeof(LCID),pdwCount);
 if pdwLcid=nil then exit;
 pdwLcid[0]:=LOCALE_SYSTEM_DEFAULT;
 pdwLcid[1]:=LOCALE_USER_DEFAULT;
 result:=S_OK;
 AddLog(2,'QueryAvailableLocaleIDs',result,ErrorCodeToString(result));
end;

function THADAOBJ.GetErrorString(dwError: HResult;
  out ppString: POleStr): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 ppString:=StringToLPoleStr(ErrorCodeToString(dwError));
 result:=S_OK;
end;

function THADAOBJ.SetClientName(szName: POleStr): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 fclientName:=szName;
 result:=S_OK;
 AddLog(2,'SetClientName',result,ErrorCodeToString(result));
end;





{function THADAOBJ.QueryOrganization(
  out pNameSpaceType: OPCNAMESPACETYPE): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 pNameSpaceType:=OPC_NS_HIERARCHIAL;
 result:=S_OK;
 AddLog(2,'QueryOrganization',result,ErrorCodeToString(result));
end;

function THADAOBJ.ChangeBrowsePosition(
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

function THADAOBJ.BrowseOPCItemIDs(dwBrowseFilterType: OPCBROWSETYPE;
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

function THADAOBJ.GetItemID(szItemDataID: POleStr;
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

function THADAOBJ.BrowseAccessPaths(szItemID: POleStr;
  out ppIEnumString: IEnumString): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 result:=E_NOTIMPL;
 AddLog(2,'BrowseAccessPaths',result,ErrorCodeToString(result));
end;
 }


function THADAOBJ.QueryAvailableProperties(szItemID: POleStr;
  out pdwCount: DWORD; out ppPropertyIDs: PDWORDARRAY;
  out ppDescriptions: POleStrList;
  out ppvtDataTypes: PVarTypeList): HResult;
var i,IDC,IDP,cp:integer;
    sl:TStringList;
    s:string;
    Obj:THABaseObj;
   // T:TIGTag;

procedure ClearParams;
begin
 if ppPropertyIDs<>nil then
  CoTaskMemFree(ppPropertyIDs);
 if ppDescriptions<>nil then
  CoTaskMemFree(ppDescriptions);
 if ppvtDataTypes<>nil then
  CoTaskMemFree(ppvtDataTypes);
end;

begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 sl:=TStringList.Create;
 s:=szItemID;
 ParsePath(s,sl);
 Obj:=nil;
 Obj:=OPCMan.GetDAObjectFromPath(sl,IDC,IDP);
 sl.Free;
 if (IDC<0) or (Obj=nil) then
  begin
   result:=OPC_E_UNKNOWNITEMID;
   AddLog(2,'QueryAvailableProperties',result,ErrorCodeToString(result));
   exit;
  end;

 if (Obj.ClassID<>ClassTag) and (Obj.ClassID<>ClassProp) then
  begin
   result:=OPC_E_UNKNOWNITEMID;
   AddLog(2,'QueryAvailableProperties',result,ErrorCodeToString(result));
   exit;
  end;

 if Obj.ClassID=ClassTag then
  cp:=TIGTag(Obj).ChildCount
 else
  cp:=0;

// было до ввода свойств как тэгов
// T:=TIGTag(Obj);
// cp:=t.ChildCount;

 pdwCount:=cp+6;

 ppPropertyIDs:=OPCTaskMemAlloc(Result,sizeof(DWORD),pdwCount);
 if ppPropertyIDs=nil then
  begin
   ClearParams;
   AddLog(2,'QueryAvailableProperties',result,ErrorCodeToString(result));
   exit;
  end;

 ppDescriptions:=OPCTaskMemAlloc(Result,sizeof(POleStr),pdwCount);
 if ppDescriptions=nil then
  begin
   ClearParams;
   AddLog(2,'QueryAvailableProperties',result,ErrorCodeToString(result));
   exit;
  end;

 ppvtDataTypes:=OPCTaskMemAlloc(Result,sizeof(TVarType),pdwCount);
 if ppvtDataTypes=nil then
  begin
   ClearParams;
   AddLog(2,'QueryAvailableProperties',result,ErrorCodeToString(result));
   exit;
  end;

 result:=s_ok;

 ppPropertyIDs[0]:=1;
 ppDescriptions[0]:=StringToLPOLEStr('Тип данных');
 ppvtDataTypes[0]:=vt_i2;

 ppPropertyIDs[1]:=2;
 ppDescriptions[1]:=StringToLPOLEStr('Значение');

 if Obj.ClassID=ClassTag then
  ppvtDataTypes[1]:=TIGTag(Obj).TypeTag
 else
  ppvtDataTypes[1]:=TIGProp(Obj).TypeProp;


 ppPropertyIDs[2]:=3;
 ppDescriptions[2]:=StringToLPOLEStr('Качество');
 ppvtDataTypes[2]:=vt_i2;

 ppPropertyIDs[3]:=4;
 ppDescriptions[3]:=StringToLPOLEStr('Время изменения');
 ppvtDataTypes[3]:=vt_date;

 ppPropertyIDs[4]:=5;
 ppDescriptions[4]:=StringToLPOLEStr('Права доступа');
 ppvtDataTypes[4]:=vt_i4;

 ppPropertyIDs[5]:=6;
 ppDescriptions[5]:=StringToLPOLEStr('ServerScanRate');
 ppvtDataTypes[5]:=vt_r4;

 if Obj.ClassID=ClassTag then
  for i:=0 to cp-1 do
   begin
    ppPropertyIDs[i+6]:=TIGTag(Obj).PropByIndex[i].PropID;
    ppDescriptions[i+6]:=StringToLPOLEStr(TIGTag(Obj).PropByIndex[i].NameObj);
    ppvtDataTypes[i+6]:=TIGTag(Obj).PropByIndex[i].TypeProp;
   end;

 AddLog(2,'QueryAvailableProperties',result,ErrorCodeToString(result));
end;

function THADAOBJ.GetItemProperties(szItemID: POleStr; dwCount: DWORD;
  pdwPropertyIDs: PDWORDARRAY; out ppvData: POleVariantArray;
  out ppErrors: PResultList): HResult;
var i,IDC,IDP,pind:integer;
    pArr:PDWORDARRAY;
    v:olevariant;
    sl:TStringList;
    s:string;
    Obj:THABaseObj;
  //  T:TIGTag;
    ar:word;
 
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 if dwCount<1 then
  begin
   result:=E_INVALIDARG;
   AddLog(2,'GetItemProperties',result,ErrorCodeToString(result));
   exit;
  end;

 sl:=TStringList.Create;
 try
  s:=szItemID;
  ParsePath(s,sl);
  Obj:=nil;
  Obj:=OPCMan.GetDAObjectFromPath(sl,IDC,IDP);
 finally
  sl.Free;
 end;

 if (IDC<0) or (Obj=nil) then
  begin
   result:=OPC_E_INVALIDITEMID;
   AddLog(2,'GetItemProperties',result,ErrorCodeToString(result));
   Exit;
  end;

 if (Obj.ClassID<>ClassTag) and (Obj.ClassID<>ClassProp) then
  begin
   result:=OPC_E_INVALIDITEMID;
   AddLog(2,'GetItemProperties',result,ErrorCodeToString(result));
   exit;
  end;

 //T:=TIGTag(Obj);


 ppvData:=OPCTaskMemAlloc(Result,sizeof(OleVariant),dwCount);
 if ppvData=nil then exit;
 ppErrors:=OPCTaskMemAlloc(Result,sizeof(HRESULT),dwCount);
 if ppErrors=nil then
  begin
   if ppvData<>nil then
    CoTaskMemFree(ppvData);
   AddLog(2,'GetItemProperties',result,ErrorCodeToString(result));
   exit;
  end;

 result:=s_ok;
 pArr:=@pdwPropertyIDs^;
 for i:= 0 to dwCount-1 do
  begin
   ppErrors[i]:=S_OK;
   v:=null;
   case pArr[i] of
    1: if Obj.ClassID=ClassTag then
         VariantChangeTypeEx(v,TIGTag(Obj).TypeTag,fLocaleID,0,vt_I2)
       else
         if OPCMan.PropValues[IDC]<>nil then
          VariantChangeTypeEx(v,VarType(OPCMan.PropValues[IDC][IDP]),fLocaleID,0,vt_I2);


    2: if Obj.ClassID=ClassTag then
        HAConvertVariantType(v,OPCMan.OldValue[IDC],fLocaleID,TIGTag(Obj).TypeTag)
       else
        if OPCMan.PropValues[IDC]<>nil then
         HAConvertVariantType(v,OPCMan.PropValues[IDC][IDP],fLocaleID,VarType(OPCMan.PropValues[IDC][IDP]));


    3: if Obj.ClassID=ClassTag then
         VariantChangeTypeEx(v,OPCMan.OldQuality[IDC],fLocaleID,0,vt_I2)
       else
         VariantChangeTypeEx(v,OPC_QUALITY_GOOD,fLocaleID,0,vt_I2);

    4:  VariantChangeTypeEx(v,ConvertToDateTime(OPCMan.OldFileTime[IDC]),fLocaleID,0,vt_date);
    5:  begin
         ar:=0;
         if Obj.ClassID=ClassTag then
          begin
           if TIGTag(Obj).IsReadable then  ar:=OPC_READABLE;
           if TIGTag(Obj).IsWriteable then ar:=ar or OPC_WRITEABLE;
          end
         else
          ar:=OPC_READABLE or OPC_WRITEABLE;

         v:=ar;
         VariantChangeTypeEx(v,ar,fLocaleID,0,vt_I4);
        end;
     6: VariantChangeTypeEx(v,OPCMan.CurrentUpdateRate[IDC],fLocaleID,0,vt_R4);
    else
     if Obj.ClassID=ClassTag then
       begin
        pind:=TIGTag(Obj).PropIndex(pArr[i]);
        if pind>-1 then
          HAConvertVariantType(v,OPCMan.PropValues[IDC][pind],fLocaleID,TIGTag(Obj).PropByIndex[pind].TypeProp)
        else
         begin
          ppErrors[i]:=OPC_E_INVALID_PID;
          result:=S_FALSE;
          continue;
         end;
       end;

   end;

   ppvData[i]:=v;
  end;
 AddLog(2,'GetItemProperties',result,ErrorCodeToString(result));
end;

function THADAOBJ.LookupItemIDs(szItemID: POleStr; dwCount: DWORD;
  pdwPropertyIDs: PDWORDARRAY; out ppszNewItemIDs: POleStrList;
  out ppErrors: PResultList): HResult;
var i,IDC,IDP,CountProp:integer;
    Obj:THABaseObj;
    s:string;
    st:TStringList;
    T:TIGTag;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 if dwCount=0 then
  begin
   result:=E_INVALIDARG;
   exit;
  end;

 st:=TStringList.Create;
 try
  s:=szItemID;
  ParsePath(s,st);
  Obj:=OPCMan.GetDAObjectFromPath(st,IDC,IDP);
  if Obj=nil then
   begin
    result:=OPC_E_INVALIDITEMID;
    AddLog(2,'LookupItemIDs',result,ErrorCodeToString(result));
    exit;
   end
  else
   if Obj.ClassID<>ClassTag then
    begin
     result:=OPC_E_INVALIDITEMID;
     AddLog(2,'LookupItemIDs',result,ErrorCodeToString(result));
     exit;
    end;


 finally
  st.Free;

 end;


 T:=TIGTag(Obj);
 CountProp:=T.ChildCount;



{ if (dwCount=0) and (CountProp>0) then
  begin
   result:=E_INVALIDARG;
   AddLog(2,'LookupItemIDs',result,ErrorCodeToString(result));
   exit;
  end;
 }
{ else
  if (dwCount=0) and (CountProp=0) then
   begin
    result:=s_ok;
    exit;
   end
  else
   if (dwCount=0) then
   begin
    result:=E_INVALIDARG;
    exit;
   end;  }

{ else
  if CountProp=0 then
   begin
    result:=s_ok;
    exit;
   end;
 }
 ppszNewItemIDs:=OPCTaskMemAlloc(Result,sizeof(POleStr),dwCount);
 if ppszNewItemIDs=nil then exit;
 ppErrors:=OPCTaskMemAlloc(Result,sizeof(HRESULT),dwCount);
 if ppErrors=nil then
  begin
   if ppszNewItemIDs<>nil then
    CoTaskMemFree(ppszNewItemIDs);
   AddLog(2,'LookupItemIDs',result,ErrorCodeToString(result));
   exit;
  end;

 result:=s_ok;
 for i:=0 to dwCount-1 do
  begin
   IDP:=T.PropIndex(pdwPropertyIDs^[i]);
   if (IDP>=0) and (i<CountProp) then
     begin
      ppszNewItemIDs[i]:=StringToLPoleStr(s+BranchSep+T.PropByIndex[IDP].NameObj);
      ppErrors[i]:=s_OK;
     end
    else
     begin
      ppErrors[i]:=OPC_E_INVALID_PID;
      result:=s_false;
     end;
   end;
 AddLog(2,'LookupItemIDs',result,ErrorCodeToString(result));
end;



function THADAOBJ.GetPublicGroupByName(szName: POleStr; const riid: TIID;
  out ppUnk: IInterface): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 result:=e_nointerface;
end;

function THADAOBJ.RemovePublicGroup(hServerGroup: OPCHANDLE;
  bForce: BOOL): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 result:=e_nointerface;
end;



procedure THADAOBJ.Initialize;
begin
// coInitializeEx(nil,COINIT_MULTITHREADED);
 
// while OPCMan=nil do sleep(1);
// while OPCMan.AddedItems do sleep(1);
 while CheckOPCMan<>s_ok do sleep(1);

 inherited Initialize;
 fCurrPath:=TStringList.Create;
 FConnectionPoints:=TConnectionPoints.Create(self);
 FConnectionPoint:=FConnectionPoints.CreateConnectionPoint(IID_IOPCShutdown,ckSingle,ShutdownOnConnect);
 FOPCDABrowser:=TOPCDABrowser.Create;
 fListGroup:=TList.Create;
 fhandle:=OPCMan.GenUniI;
 fLocaleId:=LOCALE_USER_DEFAULT;
 OPCMan.AddServer(self);
end;

procedure THADAOBJ.ShutDown(Force:boolean);
var SD:IOPCShutdown;
    res:HResult;
    i:cardinal;

begin
// if fHandle=OPCMan.LocalClientHandle then exit;
 res:=e_fail;
 if not Force then
  begin
   if fClientIUnknown<>nil then
    begin
     res:=fClientIUnknown.QueryInterface(IID_IOPCShutdown,SD);
     if res=s_ok then
     begin
      i:=GetTickCount;
      res:=SD.ShutdownRequest('OnShutdown');
      while (res<>s_ok) and ((GetTickCount-i)<2000) do
       begin
        sleep(20);
        res:=SD.ShutdownRequest('OnShutdown');
       end;
     end;
    end
   else
    coDisconnectObject(self as IHADAObj,0);
  end
 else
  coDisconnectObject(self as IHADAObj,0);

 AddLog(2,'ShutDown',res,ErrorCodeToString(res));
end;

destructor THADAOBJ.Destroy;
var i:integer;
    L:TList;
    co:THADAGroup;
begin
 try
   L:=TList.Create;
   try
      for i:=0 to fListGroup.Count-1 do
        begin
         l.Add(fListGroup[i]);
         THADAGroup(fListGroup[i]).SetDeleted;
        end;

    for i:=0 to L.Count-1 do
     begin
      co:=THADAGroup(L[i]);
      if co.RefCount=1 then
       co.ObjRelease
      else
       co.Free;
     end;
   finally
    l.Free;
   end;



  fCurrPath.Free;
  FConnectionPoint.Free;
  FConnectionPoints.Free;
//  FOPCDABrowser.Free;
  fListGroup.Free;

  if OPCMan<>nil then
   OPCMan.RemoveServer(self);

 inherited;
 AddLog(2,'Destroy '+fClientName,s_ok,'OK');
 except
  on E: Exception do
    AddLog(2,'Destroy '+fClientName,E_FAIL,e.Message);
 end;


end;

{procedure THADAOBJ.DeleteGroup(Group: TObject);
begin
 Log.AddLog('DeleteGroup');
 try

  fListGroup.Remove(Group);
 except
  Log.AddLog('Error DeleteGroup');
 end;
end;   }

function THADAOBJ.ExistsNameGroup(Name: string): boolean;
var i:integer;
    co:THADAGroup;
begin
 result:=false;
 co:=nil;
 for i:=0 to fListGroup.Count-1 do
  begin
   co:=THADAGroup(fListGroup[i]);
   if co.NameGroup=Name then
    if not co.Deleted then
     begin
       result:=true;
       break;
     end;
  end;
end;












procedure THADAOBJ.ShutdownOnConnect(const Sink: IInterface;
  Connecting: Boolean);
begin
 if connecting then
  begin
   fClientIUnknown:=Sink;
//   res:=fClientIUnknown.QueryInterface(IID_IOPCShutdown,SD);
//   SD.ShutdownRequest('dd');
//   OPCMan.Log('ShutdownOnConnect=Connecting');
  end
 else
  begin
   fClientIUnknown:=nil;
//   OPCMan.Log('ShutdownOnConnect=UnConnecting');
  end;

end;



procedure THADAOBJ.DeleteGroup(Group: TComObject);
begin
 fListGroup.Remove(Group);
end;

function THADAOBJ.GetGroupCount: integer;
begin
 result:=fListGroup.Count;
end;

function THADAOBJ.GetGroupByHandle(AHandle: dword): TComObject;
var i:integer;
    co:THADAGroup;
begin
 result:=nil;
 for i:=0 to fListGroup.Count-1 do
  begin
     co:=THADAGroup(fListGroup[i]);
     if (co.hServerGroup=AHandle) and (not co.Deleted) then
      begin
       result:=co;
       break;
      end;
  end;
end;



function THADAOBJ.GetSupportIOPCShutdown: boolean;
var SD:IOPCShutdown;
begin
 result:=false;
 try
 if fClientIUnknown<>nil then
   result:=fClientIUnknown.QueryInterface(IID_IOPCShutdown,SD)=s_ok;
 except
 end;  
end;

procedure THADAOBJ.AddGroup(Group: TComObject);
begin
 fListGroup.Add(group);
end;

{function THADAOBJ.GetGroup(index: integer): TComObject;
begin
 result:=nil;
 if index>=fListGroup.Count then exit;
 if THADAGroup(fListGroup[index]).Deleted then exit;
 result:=fListGroup[index];
end;
 }

{function THADAOBJ.GetGroupIsUpdate: boolean;
var i:integer;
    gr:THADAGroup;
begin
 result:=true;
 for i:=0 to fListGroup.Count-1 do
  begin
   gr:=THADAGroup(fListGroup[i]);
   if not Gr.Deleted then
    if Gr.GroupIsActive and (not Gr.TimerGroup.Stopped) then
     if Gr.LastIDTransCommit<>OPCMan.CurrIdTrans then
      begin
       result:=false;
       break;
      end;
  end;
end; }

function THADAOBJ.GetGroup(index: integer): TComObject;
begin
 result:=nil;
 if (index<0) or (index>=fListGroup.count) then exit;
 result:=fListGroup[index];

end;



function THADAOBJ.GetNoConfigAsOPCMan: boolean;
var i:integer;
begin
 result:=true;
 try
 for i:=0 to fListGroup.Count-1 do
  if THADAGroup(fListGroup[i]).TimerGroup.CurrNoConfig<>OPCMan.CurrentNoConfig then
   begin
    result:=false;
    break;
   end;
 if result then
  fCurrPath.Clear;  
 except
  on E: Exception do
    AddLog(2,'GetNoConfig ',E_FAIL,e.Message);
 end;
end;

{function THADAOBJ.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
 if IsEqualGUID(IID,IID_IOPCBrowseServerAddressSpace) then
  begin
   result:=E_NOINTERFACE;
  end
 else
  if GetInterface(IID, Obj) then Result := S_OK else Result := E_NOINTERFACE;
end;
}
initialization
  TAutoObjectFactory.Create(ComServer, THADAOBJ, Class_HADAOBJ,
    ciMultiInstance, tmApartment);
  ComServer.UIInteractive:=false;
 // CoInitialize(nil);
finalization
 //if an OPC client is connected and this is a forced kill then if CoUnintialize
 //is not called here the OLE dll will generate an error when it is called after
 //we have killed the servers.
 //CoUninitialize;
end.
