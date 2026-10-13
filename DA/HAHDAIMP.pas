unit HAHDAIMP;
{$WARN SYMBOL_PLATFORM OFF}
{$I IngaOPC.inc}



interface
{$IFDEF HDAINTERFACE}
uses
  Windows, ActiveX, Classes, ComObj,OPCCOMN,OPCHDA,AxCtrls,OPCError,OPCTypes,
  HA_ErrorCodes,ha_utils,SysUtils,ha_classes,ha_types;

type
  THAHDAObj = class(TComObject,
                    IOPCCommon,
                    IOPCHDA_Server,
                    IOPCHDA_SyncRead,
                    IOPCHDA_ASyncRead,
                    IConnectionPointContainer)

   private
    fLocaleID:LCID;
    fClientName:string;

    FConnectionPoints:TConnectionPoints;
    FConnectionPoint:TConnectionPoint;

    fClientIUnknown:IUnknown;
    procedure ShutdownOnConnect(const Sink: IUnknown; Connecting: Boolean);



   protected
    property iFIConnectionPoints:TConnectionPoints read FConnectionPoints write FConnectionPoints implements IConnectionPointContainer;


    function GetItemAttributes(
        out   pdwCount:                   DWORD;
        out   ppdwAttrID:                 PDWORDARRAY;
        out   ppszAttrName:               POleStrList;
        out   ppszAttrDesc:               POleStrList;
        out   ppvtAttrDataType:           PVarTypeList): HResult; stdcall;
      function GetAggregates(
        out   pdwCount:                   DWORD;
        out   ppdwAggrID:                 PDWORDARRAY;
        out   ppszAggrName:               POleStrList;
        out   ppszAggrDesc:               POleStrList): HResult; stdcall;
      function GetHistorianStatus(
        out   pwStatus:                   OPCHDA_SERVERSTATUS;
        out   pftCurrentTime:             PFileTime;
        out   pftStartTime:               PFileTime;
        out   pwMajorVersion:             Word;
        out   pwMinorVersion:             Word;
        out   pwBuildNumber:              Word;
        out   pdwMaxReturnValues:         DWORD;
        out   ppszStatusString:           POleStr;
        out   ppszVendorInfo:             POleStr): HResult; stdcall;
      function GetItemHandles(
              dwCount:                    DWORD;
              pszItemID:                  POleStrList;
              phClient:                   POPCHANDLEARRAY;
        out   pphServer:                  POPCHANDLEARRAY;
        out   ppErrors:                   PResultList): HResult; stdcall;
      function ReleaseItemHandles(
              dwCount:                    DWORD;
              phServer:                   POPCHANDLEARRAY;
        out   ppErrors:                   PResultList): HResult; stdcall;
      function ValidateItemIDs(
              dwCount:                    DWORD;
              pszItemID:                  POleStrList;
        out   ppErrors:                   PResultList): HResult; stdcall;
      function CreateBrowse(
              dwCount:                    DWORD;
              pdwAttrID:                  PDWORDARRAY;
              pOperator:                  POPCHDA_OPERATORCODESARRAY;
              vFilter:                    POleVariantArray;
        out   pphBrowser:                 IOPCHDA_Browser;
        out   ppErrors:                   PResultList): HResult; stdcall;

      // IOPCCommon
      function SetLocaleID(dwLcid:TLCID): HResult; stdcall;
      function GetLocaleID(out   pdwLcid:TLCID): HResult; stdcall;
      function QueryAvailableLocaleIDs(out   pdwCount:UINT; out   pdwLcid:PLCIDARRAY): HResult; stdcall;
      function GetErrorString(dwError:HResult; out   ppString:POleStr): HResult;overload; stdcall;
      function SetClientName(szName:POleStr): HResult; stdcall;

      //IOPCHDA_SyncRead
      function ReadRaw(
        var   htStartTime:                OPCHDA_TIME;
        var   htEndTime:                  OPCHDA_TIME;
              dwNumValues:                DWORD;
              bBounds:                    BOOL;
              dwNumItems:                 DWORD;
              phServer:                   POPCHANDLEARRAY;
        out   ppItemValues:               POPCHDA_ITEMARRAY;
        out   ppErrors:                   PResultList): HResult; overload; stdcall;

      function ReadProcessed(
        var   htStartTime:                OPCHDA_TIME;
        var   htEndTime:                  OPCHDA_TIME;
              ftResampleInterval:         TFileTime;
              dwNumItems:                 DWORD;
              phServer:                   POPCHANDLEARRAY;
              haAggregate:                PDWORDARRAY;
        out   ppItemValues:               POPCHDA_ITEMARRAY;
        out   ppErrors:                   PResultList): HResult; overload; stdcall;

      function ReadAtTime(
              dwNumTimeStamps:            DWORD;
              ftTimeStamps:               PFileTimeArray;
              dwNumItems:                 DWORD;
              phServer:                   POPCHANDLEARRAY;
        out   ppItemValues:               POPCHDA_ITEMARRAY;
        out   ppErrors:                   PResultList): HResult; overload; stdcall;

      function ReadModified(
        var   htStartTime:                OPCHDA_TIME;
        var   htEndTime:                  OPCHDA_TIME;
              dwNumValues:                DWORD;
              dwNumItems:                 DWORD;
              phServer:                   POPCHANDLEARRAY;
        out   ppItemValues:               POPCHDA_MODIFIEDITEMARRAY;
        out   ppErrors:                   PResultList): HResult;     overload; stdcall;

      function ReadAttribute(
        var   htStartTime:                OPCHDA_TIME;
        var   htEndTime:                  OPCHDA_TIME;
              hServer:                    OPCHANDLE;
              dwNumAttributes:            DWORD;
              pdwAttributeIDs:            PDWORDARRAY;
        out   ppAttributeValues:          POPCHDA_ATTRIBUTEARRAY;
        out   ppErrors:                   PResultList): HResult;   overload; stdcall;

    //AsyncRead
      function ReadRaw(
              dwTransactionID:            DWORD;
        var   htStartTime:                OPCHDA_TIME;
        var   htEndTime:                  OPCHDA_TIME;
              dwNumValues:                DWORD;
              bBounds:                    BOOL;
              dwNumItems:                 DWORD;
              phServer:                   POPCHANDLEARRAY;
        out   pdwCancelID:                DWORD;
        out   ppErrors:                   PResultList): HResult; overload; stdcall;

      function AdviseRaw(
              dwTransactionID:            DWORD;
        var   htStartTime:                OPCHDA_TIME;
              ftUpdateInterval:           TFileTime;
              dwNumItems:                 DWORD;
              phServer:                   POPCHANDLEARRAY;
        out   pdwCancelID:                DWORD;
        out   ppErrors:                   PResultList): HResult;  stdcall;

      function ReadProcessed(
              dwTransactionID:            DWORD;
        var   htStartTime:                OPCHDA_TIME;
        var   htEndTime:                  OPCHDA_TIME;
              ftResampleInterval:         TFileTime;
              dwNumItems:                 DWORD;
              phServer:                   POPCHANDLEARRAY;
              haAggregate:                PDWORDARRAY;
        out   pdwCancelID:                DWORD;
        out   ppErrors:                   PResultList): HResult; overload; stdcall;

      function AdviseProcessed(
              dwTransactionID:            DWORD;
        var   htStartTime:                OPCHDA_TIME;
              ftResampleInterval:         TFileTime;
              dwNumItems:                 DWORD;
              phServer:                   POPCHANDLEARRAY;
              haAggregate:                PDWORDARRAY;
              dwNumIntervals:             DWORD;
        out   pdwCancelID:                DWORD;
        out   ppErrors:                   PResultList): HResult; stdcall;

      function ReadAtTime(
              dwTransactionID:            DWORD;
              dwNumTimeStamps:            DWORD;
              ftTimeStamps:               PFileTimeArray;
              dwNumItems:                 DWORD;
              phServer:                   POPCHANDLEARRAY;
        out   pdwCancelID:                DWORD;
        out   ppErrors:                   PResultList): HResult; overload; stdcall;

      function ReadModified(
              dwTransactionID:            DWORD;
        var   htStartTime:                OPCHDA_TIME;
        var   htEndTime:                  OPCHDA_TIME;
              dwNumValues:                DWORD;
              dwNumItems:                 DWORD;
              phServer:                   POPCHANDLEARRAY;
        out   pdwCancelID:                DWORD;
        out   ppErrors:                   PResultList): HResult; overload; stdcall;

      function ReadAttribute(
              dwTransactionID:            DWORD;
        var   htStartTime:                OPCHDA_TIME;
        var   htEndTime:                  OPCHDA_TIME;
              hServer:                    OPCHANDLE;
              dwNumAttributes:            DWORD;
              dwAttributeIDs:             PDWORDARRAY;
        out   pdwCancelID:                DWORD;
        out   ppErrors:                   PResultList): HResult; overload; stdcall;

      function Cancel(
              dwCancelID:                 DWORD): HResult; stdcall;

   public
      procedure Initialize; override;
      destructor Destroy; override;
  end;

const
  Class_HAHDAObj: TGUID = '{21B487F5-D672-4EF1-B019-BEBA57337218}';

{$ENDIF}
implementation
{$IFDEF HDAINTERFACE}

uses ComServ,HAHDABrowser,ha_opcman;



{ THAHDAObj }

function THAHDAObj.AdviseProcessed(dwTransactionID: DWORD;
  var htStartTime: OPCHDA_TIME; ftResampleInterval: TFileTime;
  dwNumItems: DWORD; phServer: POPCHANDLEARRAY; haAggregate: PDWORDARRAY;
  dwNumIntervals: DWORD; out pdwCancelID: DWORD;
  out ppErrors: PResultList): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 result:=E_NOTIMPL;
end;

function THAHDAObj.AdviseRaw(dwTransactionID: DWORD;
  var htStartTime: OPCHDA_TIME; ftUpdateInterval: TFileTime;
  dwNumItems: DWORD; phServer: POPCHANDLEARRAY; out pdwCancelID: DWORD;
  out ppErrors: PResultList): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 result:=E_NOTIMPL;
end;

function THAHDAObj.Cancel(dwCancelID: DWORD): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 result:=E_NOTIMPL;
end;

function THAHDAObj.CreateBrowse(dwCount: DWORD; pdwAttrID: PDWORDARRAY;
  pOperator: POPCHDA_OPERATORCODESARRAY; vFilter: POleVariantArray;
  out pphBrowser: IOPCHDA_Browser; out ppErrors: PResultList): HResult;
var i:dword;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

{ if dwCount=0 then
  begin
   result:=E_INVALIDARG;
   exit;
  end;
 }
 ppErrors:=nil;
 result:=s_ok;
 if dwCount>0 then
  begin
   ppErrors:=OPCTaskMemAlloc(result,sizeof(HResult),dwCount);
   if result<>s_ok then exit;
   for i:=0 to dwCount-1 do
    begin
    // if pdwAttrID[i]<>0 then
    //  begin
       ppErrors[i]:=OPC_E_UNKNOWNATTRID;
       result:=s_false;
    //   continue;
    //  end;
    // ppErrors[i]:=s_ok;
    end;
  end;

 pphBrowser:=THA_HDABrowser.Create;
end;

destructor THAHDAObj.Destroy;
begin
 FConnectionPoint.Free;
 FConnectionPoints.Free;
 inherited;
end;

function THAHDAObj.GetAggregates(out pdwCount: DWORD;
  out ppdwAggrID: PDWORDARRAY; out ppszAggrName,
  ppszAggrDesc: POleStrList): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 pdwCount:=0;
 ppdwAggrID:=nil;
 ppszAggrName:=nil;
 ppszAggrDesc:=nil;
 result:=s_ok;
end;

function THAHDAObj.GetErrorString(dwError: HResult;
  out ppString: POleStr): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 ppString:=StringToLPoleStr(ErrorCodeToString(dwError));
 result:=S_OK;
end;

function THAHDAObj.GetHistorianStatus(out pwStatus: OPCHDA_SERVERSTATUS;
  out pftCurrentTime, pftStartTime: PFileTime; out pwMajorVersion,
  pwMinorVersion, pwBuildNumber: Word; out pdwMaxReturnValues: DWORD;
  out ppszStatusString, ppszVendorInfo: POleStr): HResult;
var ct,st:PFileTime;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 pwStatus:=1;
 pftCurrentTime:=OPCTaskMemAlloc(Result, SizeOf(TFileTime),1);
 if pftCurrentTime=nil then
  begin
   result:=e_fail;
   exit;
  end;
 pftCurrentTime^:=ConvertToFileTime(Now);

 pftStartTime:=OPCTaskMemAlloc(Result, SizeOf(TFileTime),1);
 if pftStartTime=nil then
  begin
   if pftCurrentTime<>nil then
    coTaskMemFree(pftCurrentTime);
   result:=e_fail;
   exit;
  end;

 pftStartTime^:=OPCMan.TimeRun;

 pwMajorVersion:=1;
 pwMinorVersion:=2;
 pwBuildNumber:=10;
 pdwMaxReturnValues:=0;
 ppszVendorInfo:=StringToLPOleStr('Inga HDA Server');
 result:=s_ok;
end;

function THAHDAObj.GetItemAttributes(out pdwCount: DWORD;
  out ppdwAttrID: PDWORDARRAY; out ppszAttrName, ppszAttrDesc: POleStrList;
  out ppvtAttrDataType: PVarTypeList): HResult;

procedure ClearParams;
begin
 if ppdwAttrID<>nil then
  coTaskMemFree(ppdwAttrID);
 ppdwAttrID:=nil;

 if ppszAttrName<>nil then
  coTaskMemFree(ppszAttrName);
 ppszAttrName:=nil;

 if ppszAttrDesc<>nil then
  coTaskMemFree(ppszAttrDesc);
 ppszAttrDesc:=nil;

 if ppvtAttrDataType<>nil then
  coTaskMemFree(ppvtAttrDataType);
 ppvtAttrDataType:=nil;

end;

begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 pdwCount:=0;
 result:=s_ok;
{ pdwCount:=1;

 ppdwAttrID        := OPCTaskMemAlloc(result,sizeof(DWORD),pdwCount);
 if result<>s_ok then
  begin
   ClearParams;
   Exit;
  end;

 ppszAttrName      := OPCTaskMemAlloc(result,sizeof(POleStr),pdwCount);
 if result<>s_ok then
  begin
   ClearParams;
   Exit;
  end;

 ppszAttrDesc      := OPCTaskMemAlloc(result,sizeof(POleStr),pdwCount);
 if result<>s_ok then
  begin
   ClearParams;
   Exit;
  end;

 ppvtAttrDataType  := OPCTaskMemAlloc(result,sizeof(TVarType),pdwCount);
 if result<>s_ok then
  begin
   ClearParams;
   Exit;
  end;

 ppdwAttrID[0]:=OPCHDA_DATA_TYPE;
 ppszAttrName[0]:=StringToLPoleStr('Тип данных');
 ppszAttrDesc[0]:=StringToLPoleStr('Тип данных');
 ppvtAttrDataType[0]:=VT_I2;
 result:=s_ok;}
end;

function THAHDAObj.GetItemHandles(dwCount: DWORD; pszItemID: POleStrList;
  phClient: POPCHANDLEARRAY; out pphServer: POPCHANDLEARRAY;
  out ppErrors: PResultList): HResult;
var i:integer;
    st:TStringList;
    Obj:THABaseObj;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 if dwCount=0 then
  begin
   result:=E_INVALIDARG;
   exit;
  end;

 pphServer:=nil;
 ppErrors:=nil;
 st:=TStringList.Create;
 try

   pphServer:=OPCTaskMemAlloc(result,sizeof(OPCHandle),dwCount);
   if result<>s_ok then
    exit;

   ppErrors:=OPCTaskMemAlloc(result,sizeof(HResult),dwCount);
   if result<>s_ok then
    begin
     if pphServer<>nil then
      coTaskMemFree(pphServer);
     exit;
    end;
    
   result:=s_ok;
   for i:=0 to dwCount-1 do
    begin
     st.Clear;
     ParsePath(pszItemID[i],st);
     Obj:=OPCMan.GetHDAObjectFromPath(st);
     if Obj=nil then
      begin
       ppErrors[i]:=OPC_E_UNKNOWNITEMID;
       result:=s_false;
       continue;
      end;

     if Obj.ClassID<>ClassTagHDA then
      begin
       ppErrors[i]:=OPC_E_UNKNOWNITEMID;
       result:=s_false;
       continue;
      end;


     pphServer[i]:=i;
     ppErrors[i]:=s_ok;
     TIGTagHDA(Obj).hClient:=phClient[i];

    end;



 finally
  st.Free;
 end;
end;

function THAHDAObj.GetLocaleID(out pdwLcid: TLCID): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 pdwLcid:=fLocaleId;
 result:=S_OK;
end;

procedure THAHDAObj.Initialize;
begin
  inherited;
  while CheckOPCMan<>s_ok do sleep(1);

  FConnectionPoints:=TConnectionPoints.Create(self);
  FConnectionPoint:=FConnectionPoints.CreateConnectionPoint(IID_IOPCHDA_DataCallback,ckSingle,ShutdownOnConnect);
end;

function THAHDAObj.QueryAvailableLocaleIDs(out pdwCount: UINT;
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
end;

function THAHDAObj.ReadAtTime(dwNumTimeStamps: DWORD;
  ftTimeStamps: PFileTimeArray; dwNumItems: DWORD;
  phServer: POPCHANDLEARRAY; out ppItemValues: POPCHDA_ITEMARRAY;
  out ppErrors: PResultList): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 result:=E_NOTIMPL;
end;

function THAHDAObj.ReadAttribute(var htStartTime, htEndTime: OPCHDA_TIME;
  hServer: OPCHANDLE; dwNumAttributes: DWORD; pdwAttributeIDs: PDWORDARRAY;
  out ppAttributeValues: POPCHDA_ATTRIBUTEARRAY;
  out ppErrors: PResultList): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 result:=E_NOTIMPL;
end;

function THAHDAObj.ReadModified(var htStartTime, htEndTime: OPCHDA_TIME;
  dwNumValues, dwNumItems: DWORD; phServer: POPCHANDLEARRAY;
  out ppItemValues: POPCHDA_MODIFIEDITEMARRAY;
  out ppErrors: PResultList): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 result:=E_NOTIMPL;
end;

function THAHDAObj.ReadProcessed(var htStartTime, htEndTime: OPCHDA_TIME;
  ftResampleInterval: TFileTime; dwNumItems: DWORD;
  phServer: POPCHANDLEARRAY; haAggregate: PDWORDARRAY;
  out ppItemValues: POPCHDA_ITEMARRAY; out ppErrors: PResultList): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 result:=E_NOTIMPL;
end;

function THAHDAObj.ReadRaw(var htStartTime, htEndTime: OPCHDA_TIME;
  dwNumValues: DWORD; bBounds: BOOL; dwNumItems: DWORD;
  phServer: POPCHANDLEARRAY; out ppItemValues: POPCHDA_ITEMARRAY;
  out ppErrors: PResultList): HResult;
var i,j:integer;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 result:=E_FAIL;
 ppItemValues:=OPCTaskMemAlloc(result,sizeof(OPCHDA_ITEM),dwNumItems);
 if result<>s_ok then exit;
 ppErrors:=OPCTaskMemAlloc(result,sizeof(HResult),dwNumItems);
 for i:=0 to dwNumItems-1 do
  begin
   ppItemValues[i].pftTimeStamps:=OPCTaskMemAlloc(ppErrors[i],sizeof(TFileTime),dwNumValues);
   ppItemValues[i].pdwQualities:=OPCTaskMemAlloc(ppErrors[i],sizeof(DWORD),dwNumValues);
   ppItemValues[i].pvDataValues:=OPCTaskMemAlloc(ppErrors[i],sizeof(OleVariant),dwNumValues);
   ppItemValues[i].hClient:=phServer[i];
   ppItemValues[i].dwCount:=dwNumValues;
   
   for j:=0 to dwNumValues-1 do
    begin
     ppItemValues[i].pvDataValues[j]:=2;
    end;
  end;

result:=s_ok;
end;

function THAHDAObj.ReadRaw(dwTransactionID: DWORD; var htStartTime,
  htEndTime: OPCHDA_TIME; dwNumValues: DWORD; bBounds: BOOL;
  dwNumItems: DWORD; phServer: POPCHANDLEARRAY; out pdwCancelID: DWORD;
  out ppErrors: PResultList): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 result:=E_NOTIMPL;
end;

function THAHDAObj.ReleaseItemHandles(dwCount: DWORD;
  phServer: POPCHANDLEARRAY; out ppErrors: PResultList): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

result:=E_NOTIMPL;
end;

function THAHDAObj.SetClientName(szName: POleStr): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 fclientName:=szName;
 result:=S_OK;
end;

function THAHDAObj.SetLocaleID(dwLcid: TLCID): HResult;
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
end;

procedure THAHDAObj.ShutdownOnConnect(const Sink: IInterface;
  Connecting: Boolean);
begin
 if connecting then
  fClientIUnknown:=Sink
 else
  fClientIUnknown:=nil;

end;

function THAHDAObj.ValidateItemIDs(dwCount: DWORD; pszItemID: POleStrList;
  out ppErrors: PResultList): HResult;
var i:integer;
    Obj:THABaseObj;
    s:string;
    st:TStringList;
    T:TIGTag;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 result:=s_ok;
 if dwCount=0 then
  begin
   result:=E_INVALIDARG;
   exit;
  end;

 ppErrors:=OPCTaskMemAlloc(Result,sizeof(HRESULT),dwCount);
 if result<>s_ok then exit;

 st:=TStringList.Create;
 try
  for i:=0 to dwCount-1 do
   begin
    s:=pszItemID[i];
    st.Clear;
    ParsePath(s,st);
    Obj:=OPCMan.GetHDAObjectFromPath(st);
    if Obj=nil then
     begin
      ppErrors[i]:=OPC_E_UNKNOWNITEMID;
      result:=s_false;
      continue;
     end;

    if Obj.ClassID<>ClassTagHDA then
     begin
      ppErrors[i]:=OPC_E_UNKNOWNITEMID;
      result:=s_false;
      continue;
     end;

    ppErrors[i]:=s_ok;
   end;

 finally
  st.Free;
 end;


end;

function THAHDAObj.ReadAtTime(dwTransactionID, dwNumTimeStamps: DWORD;
  ftTimeStamps: PFileTimeArray; dwNumItems: DWORD;
  phServer: POPCHANDLEARRAY; out pdwCancelID: DWORD;
  out ppErrors: PResultList): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 result:=E_NOTIMPL;
end;

function THAHDAObj.ReadAttribute(dwTransactionID: DWORD; var htStartTime,
  htEndTime: OPCHDA_TIME; hServer: OPCHANDLE; dwNumAttributes: DWORD;
  dwAttributeIDs: PDWORDARRAY; out pdwCancelID: DWORD;
  out ppErrors: PResultList): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 result:=E_NOTIMPL;
end;

function THAHDAObj.ReadModified(dwTransactionID: DWORD; var htStartTime,
  htEndTime: OPCHDA_TIME; dwNumValues, dwNumItems: DWORD;
  phServer: POPCHANDLEARRAY; out pdwCancelID: DWORD;
  out ppErrors: PResultList): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 result:=E_NOTIMPL;
end;

function THAHDAObj.ReadProcessed(dwTransactionID: DWORD; var htStartTime,
  htEndTime: OPCHDA_TIME; ftResampleInterval: TFileTime; dwNumItems: DWORD;
  phServer: POPCHANDLEARRAY; haAggregate: PDWORDARRAY;
  out pdwCancelID: DWORD; out ppErrors: PResultList): HResult;
begin
 result:=CheckOPCMan;
 if result<>s_ok then exit;

 result:=E_NOTIMPL;
end;


initialization
  TComObjectFactory.Create(ComServer, THAHDAObj, Class_HAHDAObj,
    'Inga HDA Server', '', ciMultiInstance, tmApartment);

{$ENDIF}
end.
