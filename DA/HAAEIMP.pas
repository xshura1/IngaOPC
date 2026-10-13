unit HAAEIMP;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
   Windows, ActiveX, Classes, ComObj, IngaOPC_TLB, StdVcl,OPC_AE,OPCCOMN,
  OPCTypes,HA_Utils,HA_Log,opcerror,ha_opcman,SysUtils,AxCtrls,ha_classes,
  ha_types;

type
  THAAEOBJ = class(TAutoObject,
                   IHAAEOBJ,
                   IOPCEventServer,
                   IOPCCommon,
                   IConnectionPointContainer)
  private
   FConnectionPoints:TConnectionPoints;
   FConnectionPoint:TConnectionPoint;
   fClientIUnknown:IUnknown;
   fLocaleID:LCID;
   fClientName:string;
   fListBrowsers:TList;
   procedure ShutdownOnConnect(const Sink: IUnknown; Connecting: Boolean);
  protected
    property iFIConnectionPoints:TConnectionPoints read FConnectionPoints
                          write FConnectionPoints implements IConnectionPointContainer;

      //IOPCEventServer
    function GetStatus(out   ppEventServerStatus:POPCEVENTSERVERSTATUS): HResult; stdcall;
    function CreateEventSubscription(
            bActive:                    BOOL;
            dwBufferTime:               DWORD;
            dwMaxSize:                  DWORD;
            hClientSubscription:        OPCHANDLE;
      const riid:                       TIID;
      out   ppUnk:                      IUnknown;
      out   pdwRevisedBufferTime:       DWORD;
      out   pdwRevisedMaxSize:          DWORD): HResult; stdcall;
    function QueryAvailableFilters(
      out   pdwFilterMask:              DWORD): HResult; stdcall;
    function QueryEventCategories(
            dwEventType:                DWORD;
      out   pdwCount:                   DWORD;
      out   ppdwEventCategories:        PDWORDARRAY;
      out   ppszEventCategoryDescs:     POleStrList): HResult; stdcall;
    function QueryConditionNames(
            dwEventCategory:            DWORD;
      out   pdwCount:                   DWORD;
      out   ppszConditionNames:         POleStrList): HResult; stdcall;
    function QuerySubConditionNames(
            szConditionName:            POleStr;
      out   pdwCount:                   DWORD;
      out   ppszSubConditionNames:      POleStrList): HResult; stdcall;
    function QuerySourceConditions(
            szSource:                   POleStr;
      out   pdwCount:                   DWORD;
      out   ppszConditionNames:         POleStrList): HResult; stdcall;
    function QueryEventAttributes(
            dwEventCategory:            DWORD;
      out   pdwCount:                   DWORD;
      out   ppdwAttrIDs:                PDWORDARRAY;
      out   ppszAttrDescs:              POleStrList;
      out   ppvtAttrTypes:              PVarTypeList): HResult; stdcall;
    function TranslateToItemIDs(
            szSource:                   POleStr;
            dwEventCategory:            DWORD;
            szConditionName:            POleStr;
            szSubconditionName:         POleStr;
            dwCount:                    DWORD;
            pdwAssocAttrIDs:            PDWORDARRAY;
      out   ppszAttrItemIDs:            POleStrList;
      out   ppszNodeNames:              POleStrList;
      out   ppCLSIDs:                   PGUIDList): HResult; stdcall;
    function GetConditionState(
            szSource:                   POleStr;
            szConditionName:            POleStr;
            dwNumEventAttrs:            DWORD;
            pdwAttributeIDs:            PDWORDARRAY;
      out   ppConditionState:           POPCCONDITIONSTATE): HResult; stdcall;
    function EnableConditionByArea(
            dwNumAreas:                 DWORD;
            pszAreas:                   POleStrList): HResult; stdcall;
    function EnableConditionBySource(
            dwNumSources:               DWORD;
            pszSources:                 POleStrList): HResult; stdcall;
    function DisableConditionByArea(
            dwNumAreas:                 DWORD;
            pszAreas:                   POleStrList): HResult; stdcall;
    function DisableConditionBySource(
            dwNumSources:               DWORD;
            pszSources:                 POleStrList): HResult; stdcall;
    function AckCondition(
            dwCount:                    DWORD;
            szAcknowledgerID:           POleStr;
            szComment:                  POleStr;
            pszSource:                  POleStrList;
            pszConditionName:           POleStrList;
            pftActiveTime:              PFileTimeArray;
            pdwCookie:                  PDWORDARRAY;
      out   ppErrors:                   PResultList): HResult; stdcall;
    function CreateAreaBrowser(
      const riid:                       TIID;
      out   ppUnk:                      IUnknown): HResult; stdcall;


   //opccomn
    function SetLocaleID(dwLcid:TLCID): HResult; stdcall;
    function GetLocaleID(out   pdwLcid:TLCID): HResult; stdcall;
    function QueryAvailableLocaleIDs(out   pdwCount:UINT; out   pdwLcid:PLCIDARRAY): HResult; stdcall;
    function GetErrorString(dwError:HResult; out   ppString:POleStr): HResult;overload; stdcall;
    function SetClientName(szName:POleStr): HResult; stdcall;
   public
    procedure Initialize; override;
    destructor Destroy;override;
    procedure DeleteAreaBrowser(AB:TComObject);
    procedure AddAreaBrowser(AB:TComObject);
  end;

implementation

uses ComServ,ha_ErrorCodes,HA_AEAreaBrowser;

{ THAAEOBJ }

function THAAEOBJ.AckCondition(dwCount: DWORD; szAcknowledgerID,
  szComment: POleStr; pszSource, pszConditionName: POleStrList;
  pftActiveTime: PFileTimeArray; pdwCookie: PDWORDARRAY;
  out ppErrors: PResultList): HResult;
begin

end;

procedure THAAEOBJ.AddAreaBrowser(AB: TComObject);
begin
 fListBrowsers.Add(AB);
end;

function THAAEOBJ.CreateAreaBrowser(const riid: TIID;
  out ppUnk: IInterface): HResult;
var ab:THAAEAreaBrowser;
begin
  ab:=THAAEAreaBrowser.Create(self);
  result:=IUnknown(ab).QueryInterface(riid,ppUnk);

end;

function THAAEOBJ.CreateEventSubscription(bActive: BOOL; dwBufferTime,
  dwMaxSize: DWORD; hClientSubscription: OPCHANDLE; const riid: TIID;
  out ppUnk: IInterface; out pdwRevisedBufferTime,
  pdwRevisedMaxSize: DWORD): HResult;
begin

end;

procedure THAAEOBJ.DeleteAreaBrowser(AB: TComObject);
var i:integer;
begin
 for i:=0 to fListBrowsers.Count-1 do
  if AB=fListBrowsers[i] then
   begin
    fListBrowsers.Delete(i);
    break;
   end;

end;

destructor THAAEOBJ.Destroy;
var i:integer;
    ab:THAAEAreaBrowser;
    L:TList;
begin
  L:=TList.Create;
   try
    for i:=0 to fListBrowsers.Count-1 do
     l.Add(fListBrowsers[i]);

    for i:=0 to L.Count-1 do
     begin
      ab:=THAAEAreaBrowser(L[i]);
      if ab.RefCount=1 then
       ab.ObjRelease
      else
       ab.Free;
     end;
   finally
    l.Free;
   end;


  FConnectionPoint.Free;
  FConnectionPoints.Free;
  inherited;
end;

function THAAEOBJ.DisableConditionByArea(dwNumAreas: DWORD;
  pszAreas: POleStrList): HResult;
begin

end;

function THAAEOBJ.DisableConditionBySource(dwNumSources: DWORD;
  pszSources: POleStrList): HResult;
begin

end;

function THAAEOBJ.EnableConditionByArea(dwNumAreas: DWORD;
  pszAreas: POleStrList): HResult;
begin

end;

function THAAEOBJ.EnableConditionBySource(dwNumSources: DWORD;
  pszSources: POleStrList): HResult;
begin

end;

function THAAEOBJ.GetConditionState(szSource, szConditionName: POleStr;
  dwNumEventAttrs: DWORD; pdwAttributeIDs: PDWORDARRAY;
  out ppConditionState: POPCCONDITIONSTATE): HResult;
begin
 result:=s_false;
end;

function THAAEOBJ.GetErrorString(dwError: HResult;
  out ppString: POleStr): HResult;
begin
 ppString:=StringToLPoleStr(ErrorCodeToString(dwError));
 result:=S_OK;
end;

function THAAEOBJ.GetLocaleID(out pdwLcid: TLCID): HResult;
begin
 pdwLcid:=fLocaleId;
 result:=S_OK;
 AddLog(5,'GetLocaleID',result,ErrorCodeToString(result));
end;

function THAAEOBJ.GetStatus(
  out ppEventServerStatus: POPCEVENTSERVERSTATUS): HResult;
begin
 if (addr(ppEventServerStatus) = nil) then
  begin
   Result:=E_INVALIDARG;
   AddLog(5,'GetStatus',result,ErrorCodeToString(result));
   Exit;
  end;


 ppEventServerStatus:=OPCTaskMemAlloc(result, sizeof(OPCEVENTSERVERSTATUS),1);

 if ppEventServerStatus = nil then
  begin
   AddLog(5,'GetStatus',result,ErrorCodeToString(result));
   Exit;
  end;

 result:=S_OK;
 AddLog(5,'GetStatus',result,ErrorCodeToString(result));

 ppEventServerStatus.ftStartTime:=OPCMan.TimeRun;
 ppEventServerStatus.ftCurrentTime:=ConvertToFileTime(now);
 if {OPCMan.AddedItems or} OPCMan.Stopped then
  ppEventServerStatus.dwServerState:=OPCAE_STATUS_FAILED
 else
  ppEventServerStatus.dwServerState:=OPCAE_STATUS_RUNNING;

 ppEventServerStatus.wMajorVersion:=1;
 ppEventServerStatus.wMinorVersion:=1;
 ppEventServerStatus.wBuildNumber:=1;
 ppEventServerStatus.szVendorInfo:=StringToLPOLESTR('Integral+');

end;

procedure THAAEOBJ.Initialize;
begin
 while OPCMan=nil do sleep(1);
 while OPCMan.AddedItems do sleep(1);
 inherited;
 fListBrowsers:=TList.Create;
 FConnectionPoints:=TConnectionPoints.Create(self);
 FConnectionPoint:=FConnectionPoints.CreateConnectionPoint(IID_IOPCShutdown,ckSingle,ShutdownOnConnect);
// fhandle:=OPCMan.GenUniI;
 fLocaleId:=LOCALE_USER_DEFAULT;
end;

function THAAEOBJ.QueryAvailableFilters(out pdwFilterMask: DWORD): HResult;
begin
 result:=s_false;
end;

function THAAEOBJ.QueryAvailableLocaleIDs(out pdwCount: UINT;
  out pdwLcid: PLCIDARRAY): HResult;
begin
 pdwCount:=2;
 pdwLcid:=OPCTaskMemAlloc(Result,sizeof(LCID),pdwCount);
 if pdwLcid=nil then exit;
 pdwLcid[0]:=LOCALE_SYSTEM_DEFAULT;
 pdwLcid[1]:=LOCALE_USER_DEFAULT;
 result:=S_OK;
 AddLog(5,'QueryAvailableLocaleIDs',result,ErrorCodeToString(result));

end;

function THAAEOBJ.QueryConditionNames(dwEventCategory: DWORD;
  out pdwCount: DWORD; out ppszConditionNames: POleStrList): HResult;
begin

end;

function THAAEOBJ.QueryEventAttributes(dwEventCategory: DWORD;
  out pdwCount: DWORD; out ppdwAttrIDs: PDWORDARRAY;
  out ppszAttrDescs: POleStrList;
  out ppvtAttrTypes: PVarTypeList): HResult;
begin

end;

function THAAEOBJ.QueryEventCategories(dwEventType: DWORD;
  out pdwCount: DWORD; out ppdwEventCategories: PDWORDARRAY;
  out ppszEventCategoryDescs: POleStrList): HResult;
begin

end;

function THAAEOBJ.QuerySourceConditions(szSource: POleStr;
  out pdwCount: DWORD; out ppszConditionNames: POleStrList): HResult;
var i:integer;
    obj:THABaseObj;
    st:TStringList;
    tmp:THATemplate;
begin
 st:=TStringList.Create;
 try
  ParsePath(szSource,st);
  obj:=OPCMan.GetAEObjectFromPath(st);
 finally
  st.Free;
 end;

 if (obj=nil) or ((obj<>nil) and (obj.ClassID<>classController)) then
  begin
   result:=E_INVALIDARG;
   exit;
  end;

 tmp:=TIGDevice(obj).Template;
 pdwCount:=tmp.CountEvents;
 ppszConditionNames:=OPCTaskMemAlloc(Result,sizeof(POleStr),pdwCount);
 if ppszConditionNames=nil then exit;
 for i:=0 to pdwCount-1 do
  ppszConditionNames[i]:=stringtolpolestr(tmp.NameObj+BranchSep+tmp.Event[i].NameObj);

 result:=s_ok;


end;

function THAAEOBJ.QuerySubConditionNames(szConditionName: POleStr;
  out pdwCount: DWORD; out ppszSubConditionNames: POleStrList): HResult;
begin

end;

function THAAEOBJ.SetClientName(szName: POleStr): HResult;
begin
 fclientName:=szName;
 result:=S_OK;
 AddLog(5,'SetClientName',result,ErrorCodeToString(result));

end;

function THAAEOBJ.SetLocaleID(dwLcid: TLCID): HResult;
begin
 if  (dwLcid<>LOCALE_SYSTEM_DEFAULT) and (dwLcid<>LOCALE_USER_DEFAULT) then
  result:=E_INVALIDARG
 else
  begin
   fLocaleId:=dwLcid;
   result:=S_OK;
  end;
 AddLog(5,'SetLocaleID',result,ErrorCodeToString(result));

end;

procedure THAAEOBJ.ShutdownOnConnect(const Sink: IInterface;
  Connecting: Boolean);
begin
 if connecting then
  fClientIUnknown:=Sink
 else
   fClientIUnknown:=nil;
end;

function THAAEOBJ.TranslateToItemIDs(szSource: POleStr;
  dwEventCategory: DWORD; szConditionName, szSubconditionName: POleStr;
  dwCount: DWORD; pdwAssocAttrIDs: PDWORDARRAY; out ppszAttrItemIDs,
  ppszNodeNames: POleStrList; out ppCLSIDs: PGUIDList): HResult;
begin

end;

initialization
  TAutoObjectFactory.Create(ComServer, THAAEOBJ, Class_HAAEOBJ,
    ciMultiInstance, tmApartment);
end.
