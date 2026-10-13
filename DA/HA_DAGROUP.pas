unit HA_DAGROUP;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, ActiveX, Classes, SysUtils,ComObj, IngaOPC_TLB, StdVcl,OPCDA, OPCTYPES,
  AxCtrls,hadaimp,opcerror,ha_classes,ha_enum,ha_fmglobalParams;


type

  THADAGROUP = class;

  THATimerGroup=class(TThread)
  private
   fGroup:THADAGroup;
   fCS:TRTLCriticalSection;
   fActive:bool;
   fRequestUpdateRate:cardinal;

   fGroupTransaction:THATransaction2;


   fCurrTickRefresh:cardinal;
   flCommandsIsRun:boolean;

   fCommandsClearning:TList;
   fTrList:TList;
   fDeletedItems:TThreadList;
   fStop:boolean;

   fStepTimeCommand:dword;

   fRefreshLastIDTransCommit:boolean;

   fCurrNoConfig:dword;

   fTransactionsIsClearning:boolean; // очистка и удаление транзакций завершено
   fNeedClearTransactions:boolean; // запрос на очистку и удаление всех транзакций, кроме групповой

   fGroupTransactionIsClearning:boolean; // очистка групповой транзакции завершена
   fNeedClearGroupTransaction:boolean; // запрос на очистку групповой транзакции


   procedure SetActive(value:bool);
   procedure SetRequestUpdateRate(value:cardinal);
   function GethServerGroup:dword;
   function GetTransactionCount: integer;

    function GetIDTrans: dword;

  protected
   procedure Execute; override;
  public
   constructor Create(AGroup:THADAGroup);
   destructor destroy; override;
   property Active:bool read fActive write SetActive;
   property RequestUpdateRate:cardinal read fRequestUpdateRate write SetRequestUpdateRate;
   procedure TerminateAndFree;

   procedure FreeCommand(Command:THAPSCommand);
   procedure AddTransaction(Tr:THATransaction2);

   function SearchTransByCancelID(CancelID:dword):THATransaction2;
   property TransactionCount:integer read GetTransactionCount;
   procedure Stop;
   procedure Start;
   property  Stopped:boolean read fStop;

   procedure ClearTransactions;
   procedure ClearGroupTransaction;

   property TransactionsIsClearning:boolean read fTransactionsIsClearning;
   property GroupTransactionIsClearning:boolean read fGroupTransactionIsClearning;

   property GroupTransaction:THATransaction2 read fGroupTransaction;
   property CurrNoConfig:dword read fCurrNoConfig;

   procedure AddDeletedItem(Item:THAOPCItem);
 end;

 PHAVQTCacheItem=^THAVQTCacheItem;
 THAVQTCacheItem=record
  ftTimeStamp   :  TFileTime;
  wQuality      :  word;
  vDataValue    :  OleVariant;
  IndexOPCItem  :  integer;
  IDCache      :  integer;
 end;


{ THAGroupUpdater=class(TThread)
  private
   fGroup:THADAGroup;
   fLastIDTransCommit:cardinal;
   fUpdateList:TList;
   fStop:boolean;
   fCS:TRTLCriticalSection;
  protected
   procedure Execute; override;
  public
   constructor Create(AGroup:THADAGroup);
   destructor Destroy; override;
   procedure TerminateAndFree;
   property LastIDTransCommit:cardinal read fLastIDTransCommit;
   procedure Stop;
   procedure Start;
   property  Stopped:boolean read fStop;
  end;
 }


 TListHAOPCItem=array of THAOPCItem;
 TListFreeItem=array of integer;




  THADAGROUP = class(TTypedComObject,
                     IHADAGroup,
                     IConnectionPointContainer,
                     IOPCItemMgt,
                     IOPCGroupStateMgt,
                     {IOPCPublicGroupStateMgt,}
                     IOPCSyncIO,
                     IOPCAsyncIO2)
  private
   FConnectionPoints:TConnectionPoints;
   FConnectionPoint:TConnectionPoint;

   fClientIUnknown:IUnknown;
   fDataCallBack:IOPCDataCallback;
   fDataChange:bool;
   fServObj:THADAOBJ;
   fListItem:TListHAOPCItem;
   fListFreeItem:TListFreeItem;

   fhClientGroup:OPCHANDLE;
   fhServerGroup:OPCHANDLE;

   fTimerGroup:THATimerGroup;

   fName:string;
   fPercentDeadband:single;
   fTimeBias:Longint;
   fLocaleID:LCID;

   fCountItem:integer; // кол-во Items в группе
   fLastUpdate:Tfiletime;
   fDeleted:boolean;
   fRequestAllUpdate:boolean;



   procedure CallBackOnConnect(const Sink: IUnknown; Connecting: Boolean);

   procedure DeleteItem(Ind:integer);
   function GetUpdateRate: DWORD;
   function GetGroupIsActive: bool;
   function GetCountItems: integer;
   function GetOPCItem(index: integer): THAOPCItem;


  protected
    {Declare IHADAGroup methods here}
    property iFIConnectionPoints:TConnectionPoints read FConnectionPoints
                          write FConnectionPoints implements IConnectionPointContainer;




   // IOPCItemMgt
   function AddItems(dwCount:DWORD; pItemArray:POPCITEMDEFARRAY;
                     out ppAddResults:POPCITEMRESULTARRAY;
                     out ppErrors:PResultList):HResult; stdcall;
   function ValidateItems(dwCount:DWORD; pItemArray:POPCITEMDEFARRAY; bBlobUpdate:BOOL; out ppValidationResults:        POPCITEMRESULTARRAY;
                          out ppErrors:PResultList):HResult; stdcall;
   function RemoveItems(dwCount:DWORD; phServer:POPCHANDLEARRAY; out ppErrors:PResultList):HResult; stdcall;
   function SetActiveState(dwCount:DWORD; phServer:POPCHANDLEARRAY; bActive:BOOL; out ppErrors:PResultList):HResult; stdcall;
   function SetClientHandles(dwCount:DWORD; phServer:POPCHANDLEARRAY;
                                            phClient:POPCHANDLEARRAY;
                             out ppErrors:PResultList):HResult; stdcall;
   function SetDatatypes(dwCount:DWORD; phServer:POPCHANDLEARRAY;
                         pRequestedDatatypes:PVarTypeList;
                         out ppErrors:PResultList):HResult; stdcall;
   function CreateEnumerator(const riid: TIID; out ppUnk: IUnknown): HResult; stdcall;



   //IOPCGroupStateMgt begin
   function GetState(out pUpdateRate:DWORD; out pActive:BOOL; out ppName:POleStr;
                     out pTimeBias:Longint; out pPercentDeadband:Single; out pLCID:TLCID;
                     out phClientGroup:OPCHANDLE; out phServerGroup:OPCHANDLE):HResult;overload;stdcall;
   function SetState(pRequestedUpdateRate:PDWORD; out pRevisedUpdateRate:DWORD; pActive:PBOOL;
                     pTimeBias:PLongint; pPercentDeadband:PSingle; pLCID:PLCID;
                     phClientGroup:POPCHANDLE):HResult; stdcall;
   function SetName(szName:POleStr):HResult;stdcall;
   function CloneGroup(szName:POleStr; const riid: TIID; out ppUnk:IUnknown):HResult;stdcall;


//IOPCPublicGroupStateMgt begin
   function GetState(out pPublic:BOOL):HResult;overload;stdcall;
   function MoveToPublic:HResult;stdcall;


//IOPCSyncIO begin
   function Read(dwSource:OPCDATASOURCE; dwCount:DWORD; phServer:POPCHANDLEARRAY;
                 out ppItemValues:POPCITEMSTATEARRAY; out ppErrors:PResultList):HResult;overload;stdcall;
   function Write(dwCount:DWORD; phServer:POPCHANDLEARRAY; pItemValues:POleVariantArray;
                  out ppErrors:PResultList):HResult;overload;stdcall;
//IOPCSyncIO end

//IOPCAsyncIO2 begin
   function Read(dwCount:DWORD; phServer:POPCHANDLEARRAY; dwTransactionID:DWORD;
                 out pdwCancelID:DWORD; out ppErrors:PResultList):HResult;overload;stdcall;
   function Write(dwCount:DWORD; phServer:POPCHANDLEARRAY; pItemValues:POleVariantArray;
                  dwTransactionID:DWORD; out pdwCancelID:DWORD; out ppErrors:PResultList):HResult;overload;stdcall;
   function Refresh2(dwSource:OPCDATASOURCE; dwTransactionID:DWORD;
                     out pdwCancelID:DWORD):HResult;stdcall;
   function Cancel2(dwCancelID:DWORD):HResult;stdcall;
   function SetEnable(bEnable:BOOL):HResult;stdcall;
   function GetEnable(out pbEnable:BOOL):HResult;stdcall;
//IOPCAsyncIO2 end
  public

   procedure Initialize; override;
   constructor Create(ServObj:THADAOBJ;
                      Name:string;
                      Active:bool;
                      RequestedUpdateRate:DWORD;
                      hClientGroup:OPCHANDLE;
                      pTimeBias:PLongint;
                      pPercentDeadband:PSingle;
                      dwLCID:DWORD);

   destructor Destroy;override;

   function AddItem(IDCache,IDProp:integer; var Ind:integer):THAOPCItem;
   procedure CreateAndExecuteGroupTransaction;

   property hServerGroup:OPCHANDLE read fhServerGroup write fhServerGroup;
   property hClientGroup:OPCHANDLE read fhClientGroup;
   property NameGroup:string read fName;
   property LocaleID:LCID read fLocaleID;
   property UpdateRate:DWORD read GetUpdateRate;
   property GroupIsActive:bool read GetGroupIsActive;

   procedure RefreshGroup(RequestUpdateClient:boolean);
   property DataCallBack:IOPCDataCallBack read fDataCallBack;
   property TimerGroup:THATimerGroup read fTimerGroup;

   property Deleted:boolean read fDeleted;
   procedure SetDeleted;


   property CountOPCItems:integer read GetCountItems;
   property OPCItems[index:integer]:THAOPCItem read GetOPCItem;

  end;


implementation

uses ComServ,ha_log,ha_utils,ha_types,ha_opcman,HA_ErrorCodes,Variants;



const
  MinUpdRate=100;


{$I IngaOPC.inc}



{ THADAGROUP }

function THADAGROUP.AddItems(dwCount: DWORD; pItemArray: POPCITEMDEFARRAY;
  out ppAddResults: POPCITEMRESULTARRAY;
  out ppErrors: PResultList): HResult;

var Item:THAOPCItem;
    i,IDC,IDP,hServerHandle:integer;
    ItemArr:POPCITEMDEF;
    s:string;
    sl:TStringList;
    obj:THABaseObj;
    vt:TVarType;
begin
 if fDeleted then
  begin
   result:=E_FAIL;
   exit;
  end;

 result:=CheckOPCMan;
 if result<>s_ok then exit;


 if dwCount<1 then
  begin
   result:=E_INVALIDARG;
   exit;
  end;


 ppAddResults:=OPCTaskMemAlloc(Result,sizeof(OPCITEMRESULT),dwCount);
 if ppAddResults=nil then exit;
 ppErrors:=OPCTaskMemAlloc(Result,sizeof(HRESULT),dwCount);
 if ppErrors=nil then
  begin
   if ppAddResults=nil then
    CoTaskMemFree(ppAddResults);
   exit;
  end;

 result:=s_ok;

 sl:=TStringList.Create;

 try
 fTimerGroup.Stop;
 for i:=0 to dwCount-1 do
  begin
   ItemArr:=@pItemArray[i];

   {if not ValidVariantType(ItemArr.vtRequestedDataType,0) then
     begin
      ppErrors[i]:=OPC_E_BADTYPE;
      result:=s_false;
      continue;
     end;
    }

   s:=ItemArr^.szItemID;
   Obj:=nil;
   if s<>'' then
    begin
     sl.Clear;
     ParsePath(s,sl);
     Obj:=OPCMan.GetDAObjectFromPath(sl,IDC,IDP);
    end;

   if (Obj=nil) or (s='') then
    begin
     ppErrors[i]:=OPC_E_INVALIDITEMID;
     result:=s_false;
     continue;
    end;



   if not (Obj.ClassID in [ClassTag,ClassProp]) then
    begin
     ppErrors[i]:=OPC_E_INVALIDITEMID;
     result:=s_false;
     continue;
    end;

   if IDC<0 then
    begin
     ppErrors[i]:=OPC_E_INVALIDITEMID;
     result:=s_false;
     continue;
    end;


   if Obj.ClassID=ClassTag then
    begin
     {if TIGTag(Obj).IsHide then
      begin
       ppErrors[i]:=OPC_E_INVALIDITEMID;
       result:=s_false;
       continue;
      end;
      }
     vt:=TIGTag(Obj).TypeTag;
    end
   else
    vt:=TIGProp(Obj).TypeProp;

   if ItemArr.vtRequestedDataType<>vt_empty then
   if not ValidVariantType(ItemArr.vtRequestedDataType,vt) then
     begin
      ppErrors[i]:=OPC_E_BADTYPE;
      result:=s_false;
      continue;
     end;



    Item:=AddItem(IDC,IDP,hServerHandle);
    if Item=nil then
     begin
      ppErrors[i]:=E_ADDITEMDEMOERROR;
      result:=s_false;
      continue;
     end;

    Item.ClientHandle:=ItemArr.hClient;
    Item.ServerHandle:=hServerHandle;
    Item.Active:=ItemArr^.bActive;



    if Item.IDProp<0 then
      OPCMan.AddUpdateRate(Item.IdCache,fTimerGroup.RequestUpdateRate,Item.Active and fTimerGroup.Active,hServerGroup);

    if ItemArr.vtRequestedDataType=vt_Empty then
      Item.RequestedDatatype:=Item.CanonicalDataType
    else
      Item.RequestedDatatype:=ItemArr.vtRequestedDataType;
//    GroupTr.AddParam(IDC);
    if hServerHandle>-1 then
      begin
       ppAddResults[i].hServer:=hServerHandle;
       ppAddResults[i].vtCanonicalDataType:=Item.CanonicalDataType;
       ppAddResults[i].dwAccessRights:=Item.AccessRight;
       ppAddResults[i].dwBlobSize:=0;
       ppAddResults[i].pBlob:=nil;
       ppAddResults[i].wReserved:=0;
       ppErrors[i]:=s_ok;
      end;
  end;
 finally
  sl.Free;

  //  fTimerGroup.Stop;
  {OPCMan.AddGroupTransaction(GroupTr);
  while not (GroupTr.TrState in [trs_Commit, trs_cancel]) do
   sleep(1);
  fTimerGroup.Start;
  GroupTr.Free;
   }
  CreateAndExecuteGroupTransaction; 
 end;

end;

function THADAGROUP.ValidateItems(dwCount: DWORD;
  pItemArray: POPCITEMDEFARRAY; bBlobUpdate: BOOL;
  out ppValidationResults: POPCITEMRESULTARRAY;
  out ppErrors: PResultList): HResult;
var i,IDC,IDP:integer;
    ItemArr: POPCITEMDEF;
    sl:TStringList;
    s:string;
    obj:THABaseObj;
    accessr:word;
begin

 if fDeleted then
  begin
   result:=E_FAIL;
   exit;
  end;

 result:=CheckOPCMan;
 if result<>s_ok then exit;


  if dwCount<1 then
  begin
   result:=E_INVALIDARG;
   exit;
  end;
  ppValidationResults := OPCTaskMemAlloc(Result,sizeof(OPCITEMRESULT),dwCount);
  if ppValidationResults=nil then
   exit;

  ppErrors:=OPCTaskMemAlloc(Result,sizeof(HRESULT),dwCount);
  if ppErrors=nil then
   begin
    if ppValidationResults<>nil then
      CoTaskMemFree(ppValidationResults);
    exit;
   end;

 Result := S_OK;

 sl:=TStringList.Create;
 try
 for i:=0 to dwCount-1 do
  begin
   ItemArr:=@POPCITEMDEFARRAY(@pItemArray^)[i];

   {if not OPCMan.ValidVariantType(ItemArr.vtRequestedDataType,0) then
     begin
      ppErrors[i]:=OPC_E_BADTYPE;
      result:=s_false;
      continue;
     end;
    }
   s:=ItemArr.szItemID;
   if s<>'' then
    begin
     sl.Clear;
     ParsePath(s,sl);
     Obj:=OPCMan.GetDAObjectFromPath(sl,IDC,IDP);
    end;

   if (Obj=nil) or (s='') then
    begin
     if s='' then
      ppErrors[i]:=OPC_E_INVALIDITEMID
     else
      ppErrors[i]:=OPC_E_UNKNOWNITEMID;
     Result := S_FALSE;
     continue;
    end;

   if Obj.ClassID<>ClassTag then
    begin
     ppErrors[i]:=OPC_E_UNKNOWNITEMID;
     Result := S_FALSE;
     continue;
    end;

   if not ValidVariantType(ItemArr.vtRequestedDataType,OPCMan.Tag[IDC].TypeTag) then
     begin
      ppErrors[i]:=OPC_E_BADTYPE;
      result:=s_false;
      continue;
     end;


   ppValidationResults[i].vtCanonicalDataType := OPCMan.Tag[IDC].TypeTag;
   accessr:=0;
   if OPCMan.Tag[IDC].IsReadable then
    accessr:=accessr or OPC_READABLE;

   if OPCMan.Tag[IDC].IsWriteable then
    accessr:=accessr or OPC_WRITEABLE;


   ppValidationResults[i].dwAccessRights := accessr;
   if bBlobUpdate then
    begin
      ppValidationResults[i].dwBlobSize:=0;
      ppValidationResults[i].pBlob:=nil;
    end;
    ppErrors[i] := S_OK;

  end;
 finally
  sl.Free;
 end;
end;

function THADAGROUP.RemoveItems(dwCount: DWORD; phServer: POPCHANDLEARRAY;
  out ppErrors: PResultList): HResult;
var i:integer;
//    GroupTr:THAGroupTransaction;
begin
 if fDeleted then
  begin
   result:=E_FAIL;
   exit;
  end;


  if dwCount < 1 then
  begin
   result:=E_INVALIDARG;
   Exit;
  end;

 ppErrors:=OPCTaskMemAlloc(Result,sizeof(HRESULT),dwCount);
 if ppErrors = nil then Exit;


 result:=S_OK;
 fTimerGroup.Stop;
 try
  fTimerGroup.ClearGroupTransaction;
  while not fTimerGroup.GroupTransactionIsClearning do
   sleep(1);
 for i:= 0 to dwCount -1 do
  begin
   if (phServer[i]>High(fListItem)) then
    begin
     ppErrors[i]:=OPC_E_INVALIDHANDLE;
     result:=s_false;
     continue;
    end;

   if fListItem[phServer[i]]=nil then
    begin
     ppErrors[i]:=OPC_E_INVALIDHANDLE;
     result:=s_false;
     continue;
    end;


   if fListItem[phServer[i]].Deleted then
    begin
     ppErrors[i]:=OPC_E_INVALIDHANDLE;
     result:=s_false;
     continue;
    end;

   DeleteItem(phServer[i]);
   ppErrors[i]:=S_OK;

  end;
 finally
  fTimerGroup.Start;
 end;
 CreateAndExecuteGroupTransaction;
end;

function THADAGROUP.SetActiveState(dwCount: DWORD;
  phServer: POPCHANDLEARRAY; bActive: BOOL;
  out ppErrors: PResultList): HResult;
var i:integer;
    item:THAOPCItem;
    NewActive,
    OldActive:boolean;
begin
 if fDeleted then
  begin
   result:=E_FAIL;
   exit;
  end;


 if dwCount<1 then
  begin
   result:=E_INVALIDARG;
   exit;
  end;

 ppErrors:=OPCTaskMemAlloc(Result,sizeof(HResult),dwCount);
 if ppErrors=nil then
  exit;

 result:=s_ok;
 for i:=0 to dwCount-1 do
  begin
   if phServer[i]>High(fListItem) then
    begin
     ppErrors[i]:=OPC_E_INVALIDHANDLE;
     result:=s_false;
     continue;
    end;

   if fListItem[phServer[i]]=nil then
    begin
     ppErrors[i]:=OPC_E_INVALIDHANDLE;
     result:=s_false;
     continue;
    end;

   if fListItem[phServer[i]].CurrentNoConfig<>OPCMan.CurrentNoConfig then
    begin
     ppErrors[i]:=OPC_E_INVALIDHANDLE;
     result:=s_false;
     continue;
    end;

   if fListItem[phServer[i]].Deleted then
    begin
     ppErrors[i]:=OPC_E_INVALIDHANDLE;
     result:=s_false;
     continue;
    end;

   Item:=THAOPCItem(fListItem[phServer[i]]);


   OldActive:=Item.Active and fTimerGroup.Active;
   Item.Active:=bActive;
   if Item.IDProp<0 then
    begin
     NewActive:=Item.Active and fTimerGroup.Active;
     OPCMan.ReplaceUpdateRate(Item.IDCache,fTimerGroup.RequestUpdateRate,OldActive,NewActive,hServerGroup);
    end;
   ppErrors[i]:=s_ok;
  end;

 CreateAndExecuteGroupTransaction;


end;

function THADAGROUP.SetClientHandles(dwCount: DWORD; phServer,
  phClient: POPCHANDLEARRAY; out ppErrors: PResultList): HResult;
var i:integer;
begin
 if fDeleted then
  begin
   result:=E_FAIL;
   exit;
  end;


  if dwCount < 1 then
  begin
   result:=E_INVALIDARG;
   Exit;
  end;

 ppErrors:=OPCTaskMemAlloc(Result,sizeof(HRESULT),dwCount);
 if ppErrors=nil then exit;

 result:=s_ok;
 for i:=0 to dwCount-1 do
  begin
   if phServer[i]>High(fListItem) then
     begin
      ppErrors[i]:=OPC_E_INVALIDHANDLE;
      result:=s_false;
      continue;
     end;

    if fListItem[phServer[i]]=nil then
     begin
      ppErrors[i]:=OPC_E_INVALIDHANDLE;
      result:=s_false;
      continue;
     end;

    if fListItem[phServer[i]].CurrentNoConfig<>OPCMan.CurrentNoConfig then
     begin
      ppErrors[i]:=OPC_E_INVALIDHANDLE;
      result:=s_false;
      continue;
     end;

    if fListItem[phServer[i]].Deleted then
     begin
      ppErrors[i]:=OPC_E_INVALIDHANDLE;
      result:=s_false;
      continue;
     end;

   THAOPCItem(fListItem[phServer[i]]).ClientHandle:=phClient[i];
   ppErrors[i]:=s_ok;
  end;

end;

function THADAGROUP.SetDatatypes(dwCount: DWORD; phServer: POPCHANDLEARRAY;
  pRequestedDatatypes: PVarTypeList; out ppErrors: PResultList): HResult;
var i:integer;
begin
 if fDeleted then
  begin
   result:=E_FAIL;
   exit;
  end;


  if dwCount < 1 then
  begin
   result:=E_INVALIDARG;
   Exit;
  end;

 ppErrors:=OPCTaskMemAlloc(Result,sizeof(HRESULT),dwCount);
 if ppErrors=nil then exit;

 result:=s_ok;
 for i:=0 to dwCount-1 do
  begin
   if phServer[i]>High(fListItem) then
     begin
      ppErrors[i]:=OPC_E_INVALIDHANDLE;
      result:=s_false;
      continue;
     end;

   if  fListItem[phServer[i]]=nil then
     begin
      ppErrors[i]:=OPC_E_INVALIDHANDLE;
      result:=s_false;
      continue;
     end;

   if fListItem[phServer[i]].CurrentNoConfig<>OPCMan.CurrentNoConfig then
     begin
      ppErrors[i]:=OPC_E_INVALIDHANDLE;
      result:=s_false;
      continue;
     end;

   if  fListItem[phServer[i]].Deleted then
     begin
      ppErrors[i]:=OPC_E_INVALIDHANDLE;
      result:=s_false;
      continue;
     end;

   if not ValidVariantType(pRequestedDatatypes[i],THAOPCItem(fListItem[phServer[i]]).CanonicalDataType) then
     begin
       ppErrors[i]:=OPC_E_BADTYPE;
       result:=s_false;
       continue;
     end;

   THAOPCItem(fListItem[phServer[i]]).RequestedDatatype:=pRequestedDatatypes[i];
   ppErrors[i]:=s_ok;

  end;


end;

function THADAGROUP.CreateEnumerator(const riid: TIID;
  out ppUnk: IInterface): HResult;
var i:integer;
    e:TOPCItemEnumerator;
begin
  Result := S_OK;
  if fCountItem = 0 then
   begin
    Result := S_FALSE;
    exit;
   end;
  e:=TOPCItemEnumerator.Create;
  for i:=0 to High(fListItem) do
   if fListItem[i]<>nil then
    if not fListItem[i].Deleted then
     e.AddItem(fListItem[i]);
  ppUnk:=e;  
//  ppUnk := TOPCItemEnumerator.Create(fListItem);
end;



function THADAGROUP.GetState(out pUpdateRate: DWORD; out pActive: BOOL;
  out ppName: POleStr; out pTimeBias: Integer;
  out pPercentDeadband: Single; out pLCID: TLCID; out phClientGroup,
  phServerGroup: OPCHANDLE): HResult;
begin
 if fDeleted then
  begin
   result:=E_FAIL;
   exit;
  end;


  result:=s_ok;
  pUpdateRate:=fTimerGroup.fRequestUpdateRate;
  pActive:=fTimerGroup.fActive;
  ppName:=StringToLPOleStr(fName);
  pTimeBias:=fTimeBias;
  pPercentDeadband:=fPercentDeadband;
  pLCID:=fLocaleID;
  phClientGroup:=fhClientGroup;
  phServerGroup:=fhServerGroup;

end;

function THADAGROUP.SetState(pRequestedUpdateRate: PDWORD;
  out pRevisedUpdateRate: DWORD; pActive: PBOOL; pTimeBias: PLongint;
  pPercentDeadband: PSingle; pLCID: PLCID;
  phClientGroup: POPCHANDLE): HResult;
var i:integer;
    NewActive,
    OldActive,
    OldActiveGr:boolean;
    fl,fla:boolean;

begin
 if fDeleted then
  begin
   result:=E_FAIL;
   exit;
  end;

 result:=s_ok;
 fl:=false;
 if pRequestedUpdateRate<>nil then
  begin
  if pRequestedUpdateRate^<MinUpdRate then
    begin
     fTimerGroup.RequestUpdateRate:=MinUpdRate;
     result:=OPC_S_UNSUPPORTEDRATE;
    end
  else
    fTimerGroup.RequestUpdateRate:=pRequestedUpdateRate^;
   fl:=true;
  end;

 pRevisedUpdateRate:=fTimerGroup.RequestUpdateRate;
 OldActiveGr:=fTimerGroup.Active;
 fla:=false;
 if pActive<>nil then
  begin
   fla:=(fTimerGroup.Active and (not pActive^)) or ((not fTimerGroup.Active) and pActive^);
   fTimerGroup.Active:=pActive^;
   fl:=true;
  end;

  if fl then
   begin
    for i:=0 to High(fListItem) do
     if fListItem[i]<>nil then
     if (fListItem[i].CurrentNoConfig=OPCMan.CurrentNoConfig) and (not fListItem[i].Deleted) then
      if fListItem[i].IDProp<0 then
       begin
        NewActive:=fTimerGroup.fActive and fListItem[i].Active;
        OldActive:=OldActiveGr and fListItem[i].Active;
        OPCMan.ReplaceUpdateRate(fListItem[i].IDCache,pRevisedUpdateRate,OldActive,NewActive,hServerGroup);
       end;
   end;


 if phClientGroup<>nil then
  fhClientGroup:=phClientGroup^;

 if pTimeBias<>nil then
  fTimeBias:=pTimeBias^;

 if pPercentDeadband<>nil then
  fPercentDeadband:=pPercentDeadband^;

 if pLCID<>nil then
  fLocaleID:=pLCID^;

 if fla then
  CreateAndExecuteGroupTransaction;

// OPCMan.SetStateGroup(fhServerGroup,fUpdateRate,fActive);
end;

function THADAGROUP.SetName(szName: POleStr): HResult;
begin
 if fDeleted then
  begin
   result:=E_FAIL;
   exit;
  end;


 if length(szName) = 0 then
  begin
   result:=E_INVALIDARG;
   exit;
  end;


 if fServObj.ExistsNameGroup(szName) then
  begin
   result:=OPC_E_DUPLICATENAME;
   exit;
  end;

 fname:=szName;
 result:=s_ok;

end;

function THADAGROUP.CloneGroup(szName: POleStr; const riid: TIID;
  out ppUnk: IInterface): HResult;
var g:THADAGroup;
    sname:string;
    i,ind:integer;
    Item,SItem:THAOPCItem;
    tmpActive:bool;
begin
 if fDeleted then
  begin
   result:=E_FAIL;
   exit;
  end;

 if not (IsEqualIID(riid, IID_IOPCItemMgt) or
         IsEqualIID(riid, IID_IUnknown) or
         IsEqualIID(riid, IID_IConnectionPointContainer) or
         IsEqualIID(riid, IID_IOPCItemMgt) or
         IsEqualIID(riid, IID_IOPCGroupStateMgt) or
         IsEqualIID(riid, IID_IOPCSyncIO) or
         IsEqualIID(riid, IID_IOPCAsyncIO2)) then

  begin
    result:=E_NOINTERFACE;
    exit;
  end;

 sname:=szName;
 if sname='' then
  begin
   sname:='Group'+inttostr(OPCMan.GenUniI);
   while fServObj.ExistsNameGroup(sName) do
    sname:='Group'+inttostr(OPCMan.GenUniI);
  end
 else
  if fServObj.ExistsNameGroup(sName) then
  begin
   result:=OPC_E_DUPLICATENAME;
   exit;
  end;

 g:=THADAGroup.Create(fServObj,
                      sName,
                      false, //fTimerGroup.fActive,
                      fTimerGroup.RequestUpdateRate,
                      fhClientGroup,
                      @fTimeBias,
                      @fPercentDeadband,
                      fLocaleID);

 result:=IUnknown(g).QueryInterface(riid,ppUnk);
 g.ObjAddRef;
 for i:=0 to High(fListItem) do
  if fListItem[i]<>nil then
   if not fListItem[i].Deleted then
   begin
    SItem:=fListItem[i];
    Item:=g.AddItem(SItem.IDCache,SItem.IDProp,Ind);
    Item.ServerHandle:=Ind;
    Item.ClientHandle:=SItem.ClientHandle;
    Item.Active:=SItem.Active;
    if Item.IDProp<0 then
     begin
      tmpActive:=false;
      OPCMan.AddUpdateRate(Item.IdCache,fTimerGroup.RequestUpdateRate,false,g.hServerGroup);
     end;

    Item.RequestedDatatype:=SItem.RequestedDatatype;
   end;

 fServObj.AddGroup(g);
end;



function THADAGROUP.GetState(out pPublic: BOOL): HResult;
begin
 if fDeleted then
  begin
   result:=E_FAIL;
   exit;
  end;

 result:=s_ok;
 pPublic:=false;
end;

function THADAGROUP.MoveToPublic: HResult;
begin
 result:=e_nointerface;
end;



function THADAGROUP.Read(dwSource: OPCDATASOURCE; dwCount: DWORD;
  phServer: POPCHANDLEARRAY; out ppItemValues: POPCITEMSTATEARRAY;
  out ppErrors: PResultList): HResult;
var i:integer;
   // p:TDACacheItem;
    Item:THAOPCItem;
    Tr:THATransaction2;
begin
  Tr:=nil;
  if fDeleted then
  begin
   result:=E_FAIL;
   exit;
  end;


 {if FClientIUnknown = nil then begin
    Result := CONNECT_E_NOCONNECTION;
    exit;
  end;
  }

 if dwCount < 1 then
  begin
   result:=E_INVALIDARG;
   Exit;
  end;

 result:=s_ok;
 try
 if dwSource=OPC_DS_DEVICE then
  begin
   Tr:=THATransaction2.Create(self,tk_SyncRead,0,OPCMan.GenUniI,0,true,GlobalParams.IOPCSyncIO_TimeLifeTransaction);
   for i:=0 to dwCount-1 do
    begin

     if phServer[i]>High(fListItem) then
       continue;


     if fListItem[phServer[i]]=nil then
       continue;

     if fListItem[phServer[i]].CurrentNoConfig<>OPCMan.CurrentNoConfig then
      continue;

     if fListItem[phServer[i]].Deleted then
      continue;

     Item:=THAOPCItem(fListItem[phServer[i]]);
     if (Item.AccessRight and OPC_READABLE)<>OPC_READABLE then
       continue;

     Tr.AddItem(Item,nil);
    end;

   if Tr.CountItems>0 then
    begin
     OPCMan.AddTransaction2(tr);
     while Tr.InUse do
      sleep(1);
    end;

   if Tr.TrState=trs_Roolback then
    result:=e_fail;

  // Tr.Free;
  end;

 if result<>s_ok then  exit;


 ppItemValues:=OPCTaskMemAlloc(Result, sizeof(OPCITEMSTATE),dwCount);
 if ppItemValues=nil then
  exit;


 ppErrors:=OPCTaskMemAlloc(Result,sizeof(HRESULT),dwCount);
 if ppErrors=nil then
  begin
   if ppItemValues<>nil then
    CoTaskMemFree(ppItemValues);
   exit;
  end;

 result:=s_ok;
 OPCMan.BeginRead;

 for i:=0 to dwCount-1 do
  begin
   if phServer[i]>High(fListItem) then
    begin
     ppErrors[i]:=OPC_E_INVALIDHANDLE;
     result:=s_false;
     continue;
    end;


   if fListItem[phServer[i]]=nil then
    begin
     ppErrors[i]:=OPC_E_INVALIDHANDLE;
     result:=s_false;
     continue;
    end;

   if fListItem[phServer[i]].CurrentNoConfig<>OPCMan.CurrentNoConfig then
    begin
     ppErrors[i]:=OPC_E_INVALIDHANDLE;
     result:=s_false;
     continue;
    end;

   if fListItem[phServer[i]].Deleted then
    begin
     ppErrors[i]:=OPC_E_INVALIDHANDLE;
     result:=s_false;
     continue;
    end;


   Item:=THAOPCItem(fListItem[phServer[i]]);
   if (Item.AccessRight and OPC_READABLE)<>OPC_READABLE then
    begin
     ppErrors[i]:=OPC_E_BADRIGHTS;
     result:=s_false;
     continue;
    end;

   ppItemValues[i].hClient:=Item.ClientHandle;
   ppItemValues[i].ftTimeStamp:=Item.TimeStamp;

   if (fTimerGroup.Active=false) or (Item.Active=false) then
    begin
     if dwSource=OPC_DS_CACHE then
      ppItemValues[i].wQuality:=OPC_QUALITY_OUT_OF_SERVICE
     else
      ppItemValues[i].wQuality:=Item.Quality;
    end
   else
     ppItemValues[i].wQuality:=Item.Quality;

  // ppErrors[i]:=HAConvertVariantType(ppItemValues[i].vDataValue,Item.Value,fLocaleID,Item.RequestedDatatype);


   if Item.RequestedDatatype<>Item.CanonicalDataType then
    begin
     if Tr<>nil then
      begin
        ppErrors[i]:=Tr.GetResultForItems(Item.IDCache);
        if ppErrors[i]<>s_ok then
         begin
          result:=s_false;
          continue;
         end;

      end;


     ppErrors[i]:=Item.GetValue2(ppItemValues[i].vDataValue);  //HAConvertVariantType(ppItemValues[i].vDataValue,Item.Value,fLocaleID,Item.RequestedDatatype);

     if ppErrors[i]<>s_ok then
      begin
       result:=s_false;
       continue;
      end;

    end
   else
    begin
     if Tr<>nil then
      begin
       ppErrors[i]:=Tr.GetResultForItems(Item.IDCache);
       if ppErrors[i]<>s_ok then
        begin
         result:=s_false;
         continue;
        end;
       //ppItemValues[i].vDataValue:=Item.Value;
       ppErrors[i]:=Item.GetValue2(ppItemValues[i].vDataValue);// HAConvertVariantType(ppItemValues[i].vDataValue,Item.Value,fLocaleID,Item.RequestedDatatype);
       if ppErrors[i]<>s_ok then
         begin
          result:=s_false;
          continue;
         end;
      end
     else
      begin
        ppErrors[i]:=fTimerGroup.fGroupTransaction.GetResultForItems(Item.IDCache); //s_ok;
        ppErrors[i]:=Item.GetValue2(ppItemValues[i].vDataValue);   //HAConvertVariantType(ppItemValues[i].vDataValue,Item.Value,fLocaleID,Item.RequestedDatatype);//ppItemValues[i].vDataValue:=Item.Value;
        if ppErrors[i]<>s_ok then
         begin
          result:=s_false;
          continue;
         end;
      end;
    end;
  end;
 finally
  if Tr<>nil then
   Tr.Free;
  OPCMan.EndRead;
 end;
end;

function THADAGROUP.Write(dwCount: DWORD; phServer: POPCHANDLEARRAY;
  pItemValues: POleVariantArray; out ppErrors: PResultList): HResult;
var Tr:THATransaction2;
    i:integer;
    iVQT:OPCItemVQT;
    Item:THAOPCItem;
    timework:dword;
begin
 if fDeleted then
  begin
   result:=E_FAIL;
   exit;
  end;



  if dwCount = 0 then
   begin
    Result := E_INVALIDARG;
    exit;
   end;

// timework:=GetTickCount;
// AddLog(1,'Begin SyncWrite',s_ok, NameGroup+' '+inttostr(TimerGroup.fRequestUpdateRate)+' '+inttostr(TimeWork));
  ppErrors := OPCTaskMemAlloc(Result,sizeof(HRESULT),dwCount);
  if ppErrors = nil then exit;

 result:=s_ok;
 Tr:=THATransaction2.Create(self,tk_SyncWrite,0,OPCMan.GenUniI,0,true,GlobalParams.IOPCSyncIO_TimeLifeTransaction);
 for i:=0 to dwCount-1 do
  begin
   if phServer[i]>High(fListItem) then
    begin
     ppErrors[i]:=OPC_E_INVALIDHANDLE;
     result:=s_false;
     continue;
    end;

   if fListItem[phServer[i]]=nil then
    begin
     ppErrors[i]:=OPC_E_INVALIDHANDLE;
     result:=s_false;
     continue;
    end;

   if fListItem[phServer[i]].CurrentNoConfig<>OPCMan.CurrentNoConfig then
    begin
     ppErrors[i]:=OPC_E_INVALIDHANDLE;
     result:=s_false;
     continue;
    end;

   if fListItem[phServer[i]].Deleted then
    begin
     ppErrors[i]:=OPC_E_INVALIDHANDLE;
     result:=s_false;
     continue;
    end;


   Item:=fListItem[phServer[i]];
   if (Item.AccessRight and OPC_WRITEABLE)<>OPC_WRITEABLE then
    begin
     ppErrors[i]:=OPC_E_BADRIGHTS;
     result:=s_false;
     continue;
    end;

   if (VarType(pItemValues[i])=vt_empty) or (not ValidVariantType(VarType(pItemValues[i]),Item.CanonicalDataType)) then
    begin
     ppErrors[i]:=OPC_E_BADTYPE;
     result:=s_false;
     continue;
    end;


   if  VarType(pItemValues[i])<>Item.CanonicalDataType then
    begin
     ppErrors[i]:=HAConvertVariantType(iVQT.vDataValue,pItemValues[i],fLocaleID,Item.CanonicalDataType);
     if ppErrors[i]<>s_ok then
      begin
       continue;
      end;
    end
   else
    begin
     iVQT.vDataValue:=pItemValues[i];
     ppErrors[i]:=s_ok;
    end;

   iVQT.bQualitySpecified:=false;
   iVQT.bTimeStampSpecified:=false;
   Tr.AddItem(Item,@iVQT);

  end;



 OPCMan.AddTransaction2(Tr);
 while Tr.InUse do
   sleep(1);

 //if Tr.TrState=trs_Roolback then
 //  result:=e_fail;

 Tr.Free;
 //timework:=GetTickCount-TimeWork;
 AddLog(1,'End SyncWrite',s_ok, NameGroup+' '+inttostr(TimerGroup.fRequestUpdateRate));
end;




function THADAGROUP.Read(dwCount: DWORD; phServer: POPCHANDLEARRAY;
  dwTransactionID: DWORD; out pdwCancelID: DWORD;
  out ppErrors: PResultList): HResult;
var Tr:THATransaction2;
    i:integer;
    Item:THAOPCItem;
begin
 if fDeleted then
  begin
   result:=E_FAIL;
   exit;
  end;

  if FClientIUnknown = nil then begin
    Result := CONNECT_E_NOCONNECTION;
    exit;
  end;

  if (dwCount = 0){ or (dwTransactionID = 0)} then
   begin
    Result := E_INVALIDARG;
    exit;
   end;

  ppErrors := OPCTaskMemAlloc(Result,sizeof(HRESULT),dwCount);
  if ppErrors = nil then exit;

 result:=s_ok;
 pdwCancelID:=OPCMan.GenUniI;
 Tr:=THATransaction2.Create(Self,tk_AsyncRead,dwTransactionID,OPCMan.GenUniI,pdwCancelID,true,GlobalParams.IOPCSyncIO_TimeLifeTransaction);
 for i:=0 to dwCount-1 do
  begin
   if phServer[i]>High(fListItem) then
    begin
     ppErrors[i]:=OPC_E_INVALIDHANDLE;
     result:=s_false;
     continue;
    end;

   if fListItem[phServer[i]]=nil then
    begin
     ppErrors[i]:=OPC_E_INVALIDHANDLE;
     result:=s_false;
     continue;
    end;

   if fListItem[phServer[i]].CurrentNoConfig<>OPCMan.CurrentNoConfig then
    begin
     ppErrors[i]:=OPC_E_INVALIDHANDLE;
     result:=s_false;
     continue;
    end;

   if fListItem[phServer[i]].Deleted then
    begin
     ppErrors[i]:=OPC_E_INVALIDHANDLE;
     result:=s_false;
     continue;
    end;

   Item:=fListItem[phServer[i]];
   if (Item.AccessRight and OPC_READABLE)<>OPC_READABLE then
    begin
     ppErrors[i]:=OPC_E_BADRIGHTS;
     result:=s_false;
     continue;
    end;

   Tr.AddItem(Item,nil);
   ppErrors[i]:=s_ok;
  end;

 if tr.CountItems>0 then
  fTimerGroup.AddTransaction(Tr)

 else
  Tr.Free;
end;

function THADAGROUP.Write(dwCount: DWORD; phServer: POPCHANDLEARRAY;
  pItemValues: POleVariantArray; dwTransactionID: DWORD;
  out pdwCancelID: DWORD; out ppErrors: PResultList): HResult;
var Tr:THATransaction2;
    i:integer;
    iVQT:OPCItemVQT;
    Item:THAOPCItem;
begin
 if fDeleted then
  begin
   result:=E_FAIL;
   exit;
  end;

  if FClientIUnknown = nil then begin
    Result := CONNECT_E_NOCONNECTION;
    exit;
  end;

  if (dwCount = 0) {or (dwTransactionID = 0)} then
   begin
    Result := E_INVALIDARG;
    exit;
   end;


  ppErrors := OPCTaskMemAlloc(Result,sizeof(HRESULT),dwCount);
  if ppErrors = nil then exit;

 result:=s_ok;
 pdwCancelID:=OPCMan.GenUniI;
 Tr:=THATransaction2.Create(self,tk_AsyncWrite,dwTransactionID,OPCMan.GenUniI,pdwCancelID,true,GlobalParams.IOPCSyncIO_TimeLifeTransaction);
 for i:=0 to dwCount-1 do
  begin
   if phServer[i]>High(fListItem) then
    begin
     ppErrors[i]:=OPC_E_INVALIDHANDLE;
     result:=s_false;
     continue;
    end;

   if fListItem[phServer[i]]=nil then
    begin
     ppErrors[i]:=OPC_E_INVALIDHANDLE;
     result:=s_false;
     continue;
    end;

   if fListItem[phServer[i]].CurrentNoConfig<>OPCMan.CurrentNoConfig then
    begin
     ppErrors[i]:=OPC_E_INVALIDHANDLE;
     result:=s_false;
     continue;
    end;

   if fListItem[phServer[i]].Deleted then
    begin
     ppErrors[i]:=OPC_E_INVALIDHANDLE;
     result:=s_false;
     continue;
    end;

   Item:=fListItem[phServer[i]];
   if (Item.AccessRight and OPC_WRITEABLE)<>OPC_WRITEABLE then
    begin
     ppErrors[i]:=OPC_E_BADRIGHTS;
     result:=s_false;
     continue;
    end;

   if VarType(pItemValues[i])=vt_empty then
    begin
     ppErrors[i]:=OPC_E_BADTYPE;
     result:=s_false;
     continue;
    end;


   if  VarType(pItemValues[i])<>Item.CanonicalDataType then
    begin
     ppErrors[i]:=HAConvertVariantType(iVQT.vDataValue,pItemValues[i],fLocaleID,Item.CanonicalDataType);
     if ppErrors[i]<>s_ok then
      begin
       result:=s_false;
       continue;
      end;
    end
   else
    begin
     iVQT.vDataValue:=pItemValues[i];
     ppErrors[i]:=s_ok;
    end;


  // iVQT.vDataValue:=pItemValues[i];
   iVQT.bQualitySpecified:=false;
   iVQT.bTimeStampSpecified:=false;
   Tr.AddItem(fListItem[phServer[i]],@iVQT);
   //ppErrors[i]:=s_ok;
  end;

 if tr.CountItems>0 then
  fTimerGroup.AddTransaction(Tr)
 else
  Tr.Free;

end;

function THADAGROUP.Refresh2(dwSource: OPCDATASOURCE;
  dwTransactionID: DWORD; out pdwCancelID: DWORD): HResult;
var Tr:THATransaction2;
    i,c:integer;
    ExistsActiveItem:boolean;
begin
 if fDeleted then
  begin
   result:=E_FAIL;
   exit;
  end;


 if FClientIUnknown = nil then begin
    Result := CONNECT_E_NOCONNECTION;
    exit;
 end;

 if (dwTransactionID = 0) then begin
    Result := E_INVALIDARG;
    exit;
 end;

 result:=e_fail;
 if fTimerGroup.Active=false then exit;
 if fCountItem=0 then exit;
 ExistsActiveItem:=false;
 for i:=0 to High(fListItem) do
  if fListItem[i]<>nil then
   if not fListItem[i].Deleted then
   if fListItem[i].Active<>false then
    begin
      ExistsActiveItem:=true;
      break;
    end;
 if not ExistsActiveItem then exit;

 pdwCancelID:=OPCMan.GenUniI;
 Tr:=THATransaction2.Create(self,tk_AsyncRefresh,dwTransactionID,OPCMan.GenUniI,pdwCancelID,dwSource=OPC_DS_DEVICE,GlobalParams.IOPCSyncIO_TimeLifeTransaction);
 c:=Length(fListItem);
 for i:=0 to c-1 do
  if fListItem[i]<>nil then
   if not fListItem[i].Deleted then
    Tr.AddItem(fListItem[i],nil);

 fTimerGroup.AddTransaction(Tr);

 result:=s_ok;
end;

function THADAGROUP.Cancel2(dwCancelID: DWORD): HResult;
var  tr:THATransaction2;
begin
 if fDeleted then
  begin
   result:=E_FAIL;
   exit;
  end;


 result:=E_FAIL;
 tr:=fTimerGroup.SearchTransByCancelID(dwCancelID);
 if tr=nil then exit;
 if tr.SetCancel then
   result:=s_ok;

end;

function THADAGROUP.SetEnable(bEnable: BOOL): HResult;
begin
 if fDeleted then
  begin
   result:=E_FAIL;
   exit;
  end;

  if FClientIUnknown = nil then begin
    Result := CONNECT_E_NOCONNECTION;
    exit;
  end;
 result:=s_ok;
 fDataChange:=bEnable;
end;

function THADAGROUP.GetEnable(out pbEnable: BOOL): HResult;
begin
 if fDeleted then
  begin
   result:=E_FAIL;
   exit;
  end;

  if FClientIUnknown = nil then begin
    Result := CONNECT_E_NOCONNECTION;
    exit;
  end;
 result:=s_ok;
 pbEnable:=fDataChange;
end;



procedure THADAGROUP.Initialize;
begin
  inherited;
  FConnectionPoints:=TConnectionPoints.Create(self);
  FConnectionPoint:=FConnectionPoints.CreateConnectionPoint(IID_IOPCDataCallback,ckSingle,CallBackOnConnect);
  fRequestAllUpdate:=true;
end;


constructor THADAGROUP.Create(ServObj:THADAOBJ;
                              Name:string;
                              Active:bool;
                              RequestedUpdateRate:DWORD;
                              hClientGroup:OPCHANDLE;
                              pTimeBias:PLongint;
                              pPercentDeadband:PSingle;
                              dwLCID:DWORD);
var u:DWord;
begin
 inherited Create;
 //coInitializeEx(nil,COINIT_MULTITHREADED);

 fListItem:=nil;
 fListFreeItem:=nil;
// fVQTCache:=nil;

 fServObj:=ServObj;
 fName:=Name;
 fhServerGroup:=OPCMan.GenUniI;
 fhClientGroup:=hClientGroup;
 fDataChange:=true;
 fDeleted:=false;
 fLocaleID:=dwLCID;

 if Assigned(pPercentDeadband) then
  fPercentDeadband:=pPercentDeadband^
 else
  fPercentDeadband:=0;

 if Assigned(pTimeBias) then
  fTimeBias:=pTimeBias^
 else
  fTimeBias:=GetTimeBias;

 if RequestedUpdateRate<MinUpdRate then
  U:=MinUpdRate
 else
  U:=RequestedUpdateRate;

 fTimerGroup:=THATimerGroup.Create(self);
 fTimerGroup.fRequestUpdateRate:=U;
 fTimerGroup.fActive:=Active;

end;

destructor THADAGROUP.Destroy;
var i:integer;
begin
try
 //SetDeleted;

 fTimerGroup.TerminateAndFree;
 fServObj.DeleteGroup(Self);
 FConnectionPoint.Free;
 FConnectionPoints.Free;
 if fCountItem>0 then
  begin
   for i:=0 to High(fListItem) do
    if fListItem[i]<>nil then
     begin
      if fListItem[i].IDProp<0 then
       OPCMan.DeleteUpdateRate(fListItem[i].IDCache,true,hServerGroup);
      fListItem[i].Free;
      fListItem[i]:=nil;
      dec(fCountItem);
      if fCountItem<=0 then
       break;
     //DeleteItem(i);
    end;
  end;
 SetLength(fListItem,0);
 SetLength(fListFreeItem,0);
 //fClientIUnknown:=nil;
 AddLog(3,'Destroy Group: '+fName,s_ok,'OK');
 except
  on E: Exception do
    AddLog(3,'Destroy Group: '+fName,E_FAIL,e.Message);
 end;
 inherited;
end;



procedure THADAGROUP.CallBackOnConnect(const Sink: IInterface;
  Connecting: Boolean);
begin
 if connecting then
  begin
   fClientIUnknown:=Sink;
   if not Succeeded(fClientIUnknown.QueryInterface(IID_IOPCDATACALLBACK,fDataCallback)) then
    fDataCallback:=nil;
  end
 else
  fClientIUnknown:=nil;
end;







function THADAGROUP.AddItem(IDCache,IDProp: integer;
  var Ind: integer): THAOPCItem;
begin
  Ind:=-1;
  result:=nil;

 {$IFDEF DEMOVERSION}
  if IDCache>=OPCMan.GetMaxDemoCountItems then exit;
 {$ENDIF}

  result:=THAOPCItem.Create(self,IdCache,IDProp);
  inc(fCountItem);
  if Length(fListFreeItem)>0 then
   begin
    fListItem[fListFreeItem[High(fListFreeItem)]]:=result;
    Ind:=fListFreeItem[High(fListFreeItem)];
    SetLength(fListFreeItem,Length(fListFreeItem)-1);
   end
  else
    begin
     SetLength(fListItem,Length(fListItem)+1);
     Ind:=High(fListItem);
     fListItem[Ind]:=result;
    end;
//  if IDProp<0 then
//    OPCMan.AddUpdateRate(IdCache,fTimerGroup.RequestTick,hServerGroup);


end;

procedure THADAGROUP.DeleteItem(Ind: integer);
begin
try
 if (Ind<0) or (Ind>High(fListItem)) then exit;
 if fListItem[Ind]=nil then exit;


// while fListItem[Ind].ItemIsTrans do
//  sleep(1);

 dec(fCountItem);


 if fListItem[Ind].CurrentNoConfig=OPCMan.CurrentNoConfig then
  if fListItem[Ind].IDProp<0 then
    OPCMan.DeleteUpdateRate(fListItem[Ind].IDCache,fTimerGroup.Active and fListItem[Ind].Active,hServerGroup);

 fListItem[ind].Deleted:=true;

 if fListItem[ind].ItemIsTrans then
  fTimerGroup.AddDeletedItem(fListItem[ind])
 else
  fListItem[Ind].Free;

 fListItem[Ind]:=nil; 
 if fCountItem>0 then
  begin
     if ind=High(fListItem) then
      SetLength(fListItem,Length(fListItem)-1)
     else
      begin
       //fListItem[Ind]:=nil;
       SetLength(fListFreeItem,Length(fListFreeItem)+1);
       fListFreeItem[High(fListFreeItem)]:=Ind;
      end;
  end
  else
   begin
    SetLength(fListItem,0);
    SetLength(fListFreeItem,0);
   end;

except
  on E: Exception do
    AddLog(3,'Delete Item',E_FAIL,e.Message);
end;

end;

function THADAGROUP.GetUpdateRate: DWORD;
begin
 result:=fTimerGroup.fRequestUpdateRate;
end;

procedure THADAGROUP.RefreshGroup(RequestUpdateClient:boolean);

var i,fCount:integer;
    res,resr,resq:HResult;
    fClientHandle :POPCHANDLEARRAY;
    fValues :POleVariantArray;
    fQuality:PWORDARRAY;
    fTime   :PTFileTimeARRAY;
    fErrors :PResultList;
    L:TList;
    t:THAOPCItem;
    FTOld:TFileTime;
   // s:string;
   // dt:TDateTime;
   // LI1,LI2:Large_Integer;
    TimeWork:dword;

procedure ClearParams;
var i:integer;
begin
 if fClientHandle<>nil then
  CoTaskMemFree(fClientHandle);
 if fQuality<>nil then
  CoTaskMemFree(fQuality);
 if fTime<>nil then
  CoTaskMemFree(fTime);
 if fValues<>nil then
  begin
    for i:=0 to fCount-1 do VarClear(fValues[i]);
    CoTaskMemFree(fValues);
  end;
 if fErrors<>nil then
  CoTaskMemFree(fErrors);
 if L<>nil then
  l.Free;
end;

function CheckModifyTag(OPCItem:THAOPCItem; OldTime:TFileTime):boolean;
var i:integer;
    res:HResult;
    v:olevariant;
begin
 result:=false;
 try
     if OPCItem=nil then exit;
     if fRequestAllUpdate then
      begin
       result:=true;
       exit;
      end;
     result:=OPCItem.OldQuality<>OPCItem.Quality;
     if result then exit;

     if (OPCItem.CanonicalDataType and vt_Array)<>vt_Array then
      begin
        {case OPCItem.CanonicalDataType of
         VT_I1  :begin
                  i1_1:=OPCItem.OldValue;
                  i1_2:=OPCItem.Value;
                  result:=i1_1<>i1_2;
                 end;
         VT_UI2 :begin
                  ui2_1:=OPCItem.OldValue;
                  ui2_2:=OPCItem.Value;
                  result:=ui2_1<>ui2_2;
                 end;
         VT_UI4 :begin
                  ui4_1:=OPCItem.OldValue;
                  ui4_2:=OPCItem.Value;
                  result:=ui4_1<>ui4_2;
                 end;
        else  }
         if OPCItem.GetValue2(v)=s_ok then
          result:=VarCompareValue(OPCItem.OldValue,v)<>vrEqual;
          // result:=VarCompareValue(OPCItem.OldValue,OPCItem.Value)<>vrEqual;


       // end;
      end
     else
      begin
       if OPCItem.GetValue2(v)=s_ok then
        result:=VarArrayHighBound(OPCItem.OldValue,1)<>VarArrayHighBound(v,1);
       //result:=VarArrayHighBound(OPCItem.OldValue,1)<>VarArrayHighBound(OPCItem.Value,1);
       if not result then
        begin
          if OPCItem.GetValue2(v)<>s_ok then
           begin
            result:=true;
            exit;
           end;

          for i:=0 to VarArrayHighBound(v,1) do
           begin
            result:=VarCompareValue(OPCItem.OldValue[i],v[i])<>vrEqual;
            if result then break;

           end;
        end;

      end;
    if result then exit;
    res:=fTimerGroup.fGroupTransaction.GetResultForItems(OPCItem.IDCache);
    result:=OPCItem.OldResult<>res;
    if result then
     OPCItem.OldResult:=res;
 finally
  if result then
   begin
    if OPCItem.GetValue2(v)=s_ok then
     OPCItem.OldValue:=v;
    OPCItem.OldQuality:=OPCItem.Quality;
    OPCItem.OldTimeStamp:=OPCItem.TimeStamp;
   end;
 end;
end;


begin
 ftold:=fLastUpdate;
 fLastUpdate:=ConvertToFileTime(now);
 if fDeleted then exit;

 {if not RequestUpdateClient then
  begin
    OPCMan.BeginRead;
    try
      for i:=0 to High(fListItem) do
       if (fListItem[i]<>nil) and fListItem[i].Active then
         begin
        //if (CompareFileTime(fListItem[i].TimeStamp,FTOld)>=0) or fRequestAllUpdate then
        // L.Add(fListItem[i]);
          if CheckModifyTag(fListItem[i],ftOld) then
           begin
            if Length(fVQTCache)=0 then
             SetLength(fVQTCache,Length(fVQTCache)+1);
            j:=High(fVQTCache);
            fVQTCache[j].ftTimeStamp:=fListItem[i].TimeStamp;
            fVQTCache[j].wQuality:=fListItem[i].Quality;
            fVQTCache[j].vDataValue:=fListItem[i].Value;
            fVQTCache[j].IndexOPCItem:=i;
            fVQTCache[j].IDCache:=fListItem[i].IDCache;


            fListItem[i].OldTimeStamp:=fVQTCache[j].ftTimeStamp;
            fListItem[i].OldQuality:=fVQTCache[j].wQuality;
            fListItem[i].OldValue:=fVQTCache[j].vDataValue;
           end;
         end;
   finally
    fLastIDTransCommit:=OPCMan.CurrIdTrans;
    OPCMan.EndRead;
   end;
  exit;
  end; }

 if fClientIUnknown = nil then exit;
 if fDataCallback   = nil then exit;

// TimeWork:=GetTickCount;

 fClientHandle:=nil;
 fQuality:=nil;
 fTime:=nil;
 fValues:=nil;
 fErrors:=nil;
 l:=nil;


 l:=TList.Create;

for i:=0 to High(fListItem) do
 if fListItem[i]<>nil then
  if fListItem[i].Active and (not fListItem[i].Deleted) then
   begin
    if CheckModifyTag(fListItem[i],ftOld) or fRequestAllUpdate then
     L.Add(pointer(i));

   end;

 fRequestAllUpdate:=false;
 if L.Count=0 then
  begin
   ClearParams;
   exit;
  end;
 fCount:=l.Count;

// fCount:=Length(fVQTCache);
{ if fCount=0 then
  begin
   ClearParams;
   exit;
  end;
 }
{ fCount:=0;
 for i:=0 to High(fVQTCache) do
  begin
   if fVQTCache[i].IndexOPCItem>High(fListItem) then continue;
   if fListItem[fVQTCache[i].IndexOPCItem]=nil then continue;
   if fListItem[fVQTCache[i].IndexOPCItem].IDCache<>fVQTCache[i].IDCache then continue;
   inc(fCount);
  end;
 if fCount=0 then exit;}

 fClientHandle:=OPCTaskMemAlloc(Res,sizeof(OPCHandle),fCount);
  if Res<>s_ok then
   begin
    ClearParams;
    Exit;
   end;



 fQuality:=OPCTaskMemAlloc(Res,sizeof(word),fCount);
  if Res<>s_ok then
   begin
    ClearParams;
    Exit;
   end;

 fTime:=OPCTaskMemAlloc(Res,sizeof(TFileTime),fCount);
  if Res<>s_ok then
   begin
    ClearParams;
    Exit;
   end;

 fValues:=OPCTaskMemAlloc(Res,sizeof(OleVariant),fCount);
  if Res<>s_ok then
   begin
    ClearParams;
    Exit;
   end;

 fErrors:=OPCTaskMemAlloc(Res,sizeof(HRESULT),fCount);
  if Res<>s_ok then
   begin
    ClearParams;
    Exit;
   end;

 resq:=s_ok;
 OPCMan.BeginRead;

 try
 for i:=0 to fCount-1 do
  begin
   if fListItem[Integer(l[i])]=nil then
    begin
      fErrors[i]:=OPC_E_UNKNOWNITEMID;
      res:=s_false;
      continue;
    end;

   t:=fListItem[Integer(l[i])];
   fClientHandle[i]:=t.ClientHandle;
   if t.CurrentNoConfig<>OPCMan.CurrentNoConfig then
    begin
      fErrors[i]:=OPC_E_INVALIDHANDLE;
      res:=s_false;
      continue;
    end;



   if (t.AccessRight and OPC_READABLE)<>OPC_READABLE then
    begin
     fErrors[i]:=OPC_E_BADRIGHTS;
     res:=s_false;
     continue;
    end;


   fErrors[i]:=fTimerGroup.fGroupTransaction.GetResultForItems(T.IDCache);
   T.OldResult:=fErrors[i];
   if fErrors[i]<>s_ok then
    begin
     res:=s_false;
     continue;
    end;


   fErrors[i]:=t.GetValue2(fValues[i]);
   if fErrors[i]<>s_ok then
    res:=s_false;


   fQuality[i]:=t.Quality;
   if t.Quality<>OPC_QUALITY_GOOD then
    resq:=s_false;
   fTime[i]:=t.TimeStamp;
  end;




  except
   on E:Exception do
    AddLog(3,'Refresh Group',E_fail,e.Message);
  end;

 OPCMan.EndRead;

 resr:=fDataCallBack.OnDataChange( 0,
                                   fhClientGroup,
                                   ResQ,
                                   Res,
                                   fCount,
                                   @fClientHandle^,
                                   @fValues^,
                                   @fQuality^,
                                   @fTime^,
                                   @fErrors^);



 if ResR<>s_ok then
  AddLog(3,'OnDataChange',ResR,ErrorCodeToString(ResR));

 AddLog(1,'OnDataChange',ResR,NameGroup+' '+inttostr(TimerGroup.fRequestUpdateRate)); 
 ClearParams;

end;

{ THAOPCItem }
{
procedure THAOPCItem.AddRef;
begin
 inc(fCountRef);
end;

constructor THAOPCItem.Create(IDCache: integer; ServObj: THADAOBJ);
begin
 inherited Create;
 fIDCache:=IDCache;
 fServObj:=ServObj;
 fActive:=true;
 fCountRef:=0;
end;

function THAOPCItem.GetAccessRight: dword;
begin

end;

function THAOPCItem.GetCanonicalDataType: TVarType;
begin
 result:=OPCMan.Tag[fIDCache].TypeTag;
end;

function THAOPCItem.GetItemIsTrans: boolean;
begin
 result:=fCountRef>0;
end;

function THAOPCItem.GetQuality: word;
begin
 result:=OPCMan.OldQuality[fIDCache];
end;

function THAOPCItem.GetTimeStamp: TFileTime;
begin
 result:=OPCMan.OldFileTime[fIDCache];
end;

function THAOPCItem.GetValue: OleVariant;
begin
 result:=OPCMan.OldValue[fIDCache];
end;

procedure THAOPCItem.ReleaseRef;
begin
 dec(fCountRef);
end;
     }
procedure THADAGROUP.SetDeleted;
begin
  fDeleted := true;
end;


{ THATimerGroup }

{procedure THATimerGroup.AddGroupTransaction(Tr: THAGroupTransaction);
begin
 if OPCMan.Stopped then
  begin
   tr.Free;
   exit;
  end;
 fGroupTrList.Add(Tr);
 OPCMan.AddGroupTransaction(Tr);
end; }

procedure THATimerGroup.AddTransaction(Tr: THATransaction2);
begin
// EnterCriticalSection(fCSTR);
 if Tr.ForDevice then
  OPCMan.AddTransaction2(Tr)
 else
  if Tr.TrKind=tk_AsyncRefresh then
   Tr.TrState:=trs_commit;
 fTrList.Add(Tr);
// LeaveCriticalSection(fCSTR);
end;

{procedure THATimerGroup.ClearCommands;
var i,j:integer;
    Tr:THATransaction2;
begin
 for i:=0 to fGroupTransaction.CountCommands-1 do
  begin
   fGroupTransaction.Commands[i].Deleted:=true;
   fCommandsClearning.Add(fGroupTransaction.Commands[i]);
  end;
 fGroupTransaction.ClearTr;


end;  }

constructor THATimerGroup.Create(AGroup: THADAGroup);
begin
 inherited Create(false);
 fGroup:=AGroup;
 fActive:=false;
// fCommands:=TList.Create;
 fCommandsClearning:=TList.Create;
 fTrList:=TList.Create;
 fDeletedItems:=TThreadList.Create;
 fGroupTransaction:=THATransaction2.Create(fGroup,tk_group,0,OPCMan.GenUniI,OPCMan.GenUniI,false,GlobalParams.IOPCSyncIO_TimeLifeTransaction);
// fGroupTrList:=TList.Create;
 InitializeCriticalSection(fCS);
// InitializeCriticalSection(fCSTR);
 fStop:=false;
 fCurrNoConfig:=OPCMan.CurrentNoConfig;
end;

destructor THATimerGroup.destroy;
begin
 inherited;
end;

procedure THATimerGroup.Execute;

procedure CheckUpdateRate;
var i:integer;
    razn:cardinal;
    fl:boolean;

begin
 EnterCriticalSection(fCS);

 if not flCommandsIsRun then
  if not fGroupTransaction.InUse then
  begin
     if (not fGroup.Deleted) and (fActive<>false) then
         begin
            fl:=false;
            for i:=0 to High(fGroup.fListItem) do
             if fGroup.fListItem[i]<>nil then
              if OPCMan.CurrenthServerGroup[fGroup.fListItem[i].IDCache]=fGroup.hServerGroup then
                begin
                 fl:=true;
                 break;
                end;

             if fl and (fGroupTransaction<>nil) then
              begin

               for i:=0 to fGroupTransaction.CountCommands-1 do
                if fGroupTransaction.Commands[i].State in [cs_Wait] then //,cs_Commit] then
                 begin
                  //fGroupTransaction.Commands[i].State:=cs_Wait;
                  fGroupTransaction.Commands[i].UpdateRate:=fRequestUpdateRate;
                  OPCMan.AddCommandInDynList(fGroupTransaction.Commands[i]);
                 end;
               // было в старой версии!!!
               {for i:=0 to fGroupTransaction.CountCommands-1 do
                if fGroupTransaction.Commands[i].State in [cs_Wait,cs_Commit] then
                 begin
                  fGroupTransaction.Commands[i].State:=cs_Wait;
                  fGroupTransaction.Commands[i].UpdateRate:=fRequestUpdateRate;
                  OPCMan.AddCommandInDynList(fGroupTransaction.Commands[i]);
                 end;}
              end;
          end;
    flCommandsIsRun:=true;
  end;



 // проверка на время обновления клиента
 razn:=abs(GetTickCount-fCurrTickRefresh);
 if razn>=fRequestUpdateRate then
    begin
      if (not fGroup.Deleted) and (fActive<>false) and (fGroup.fDataChange) then
       begin
         fGroup.RefreshGroup(true);
         if fGroupTransaction.CountCommands=fGroupTransaction.CountCommitCommands then
          begin
           fGroupTransaction.ClearTr(true);
           OPCMan.AddTransaction2(fGroupTransaction);
          end;
       end;




      fCurrTickRefresh:=GetTickCount;
      flCommandsIsRun:=false;
    end;

 LeaveCriticalSection(fCS);
end;

var i,j:integer;
    TR:THATransaction2;

begin
 repeat
     sleep(1);

     if fNeedClearGroupTransaction then
      begin
        fGroupTransaction.TrState:=trs_Clear;
        fGroupTransaction.ClearTr(false);
        fNeedClearGroupTransaction:=false;
      end;



     if not fStop then CheckUpdateRate;
     for i:=fTrList.Count-1 downto 0 do
       begin
        if not fStop then CheckUpdateRate;
        TR:=THATransaction2(fTrList[i]);
        if fNeedClearTransactions then
            Tr.TrState:=trs_Clear;

        if Tr.TrState in [trs_Commit,trs_Roolback,trs_Cancel,trs_Clear] then
         begin

          while Tr.InUse do
           sleep(1);

          if Tr.TrState<>trs_Clear then
            if Tr.TrState<>trs_cancel then
             case Tr.TrKind of
              tk_AsyncRead,
              tk_AsyncRefresh :Tr.Read;
              tk_AsyncWrite   :Tr.Write;
             end
            else
             Tr.Cancel;


          Tr.Free;
          fTrList.Delete(i);
         end;

       end;
    if not fStop then CheckUpdateRate;

    fTransactionsIsClearning:=fTrList.Count=0;
    fGroupTransactionIsClearning:=fGroupTransaction.CountCommands=0;

    if fTransactionsIsClearning then
     fNeedClearTransactions:=false;


    for i:=fCommandsClearning.Count-1 downto 0 do
     if not THAPSCommand(fCommandsClearning[i]).InUse then
      begin
       THAPSCommand(fCommandsClearning[i]).Free;
       fCommandsClearning.Delete(i);
      end;

    if fCurrNoConfig<>OPCMan.CurrentNoConfig then
      begin
        fGroupTransaction.ClearTr(false);
        fCurrNoConfig:=OPCMan.CurrentNoConfig;
      end;

    with fDeletedItems.LockList do
     try
      for i:=Count-1 downto 0 do
       if not THAOPCItem(Items[i]).ItemIsTrans then
        begin
         THAOPCItem(Items[i]).Free;
         Delete(i);
        end;
     finally
      fDeletedItems.UnlockList;
     end;


  until Terminated and (fCommandsClearning.Count=0);

  AddLog(4,fGroup.fName+' Terminated',s_ok,'OK');
end;


function THATimerGroup.GethServerGroup:dword;
begin
 result:=fGroup.fhServerGroup;
end;



procedure THATimerGroup.Start;
begin
 fCurrTickRefresh:=0;
 flCommandsIsRun:=false;
 
 fStop:=false;
end;

function THATimerGroup.SearchTransByCancelID(
  CancelID: dword): THATransaction2;
var i:integer;
begin
 result:=nil;
 for i:=fTrList.Count-1 downto 0 do
  if THATransaction2(fTrList[i]).IDCancel=CancelID then
   begin
    result:=fTrList[i];
    break;
   end;
end;

procedure THATimerGroup.SetActive(value: bool);
begin
 fActive:=value;
 if fActive<>false then
  fCurrTickRefresh:=0;
end;

procedure THATimerGroup.SetRequestUpdateRate(value: cardinal);
begin
// fCurrTick:=0;
 fRequestUpdateRate:=value;
 //if fCommands.Count>0 then
 if fGroupTransaction.CountCommands>0 then
  fStepTimeCommand:=fRequestUpdateRate div fGroupTransaction.CountCommands
 else
  fStepTimeCommand:=0;
end;


{procedure THATimerGroup.Stop;
begin
 fStop:=true;
end;
 }

procedure THATimerGroup.Stop;
begin
 EnterCriticalSection(fCS);
 fStop:=true;
 LeaveCriticalSection(fCS);
end;

procedure THATimerGroup.TerminateAndFree;
var r:dword;
    i:integer;
begin
 Stop;
 ClearTransactions;
 ClearGroupTransaction;

 while (not fTransactionsIsClearning) and (not fGroupTransactionIsClearning) do
  sleep(1);

 Terminate;
 r:=WaitForSingleObject(Handle, 60000);

 fCommandsClearning.Free;
 fTrList.Free;

 while fGroupTransaction.InUse do
  sleep(1);

 fGroupTransaction.Free;

 with fDeletedItems.LockList do
  try
   for i:=0 to Count-1 do
    THAOPCItem(Items[i]).Free;
  finally
   fDeletedItems.UnlockList;
  end;


 fDeletedItems.Free;



 DeleteCriticalSection(fCS);

 if r=WAIT_OBJECT_0 then
  Free;
end;

procedure THADAGROUP.CreateAndExecuteGroupTransaction;
var i:integer;
begin
 if OPCMan.AddedItems then
  sleep(1);

 fTimerGroup.Stop;
 try
   fTimerGroup.ClearGroupTransaction;
   while not fTimerGroup.GroupTransactionIsClearning do
    sleep(1);

   fTimerGroup.fGroupTransaction.IDTrans:=OPCMan.GenUniI;
   fTimerGroup.fGroupTransaction.TrState:=trs_Wait;

   if fTimerGroup.Active then
     for i:=0 to High(fListItem) do
      if (fListItem[i]<>nil) then
        if (fListItem[i].CurrentNoConfig=OPCMan.CurrentNoConfig) and fListItem[i].Active and (not fListItem[i].Deleted) then
           fTimerGroup.fGroupTransaction.AddItem(fListItem[i],nil);

     OPCMan.AddTransaction2(fTimerGroup.fGroupTransaction);
     while fTimerGroup.fGroupTransaction.InUse do
      sleep(1);
 finally
  fRequestAllUpdate:=true;
  while fTimerGroup.fGroupTransaction.InUse do
   sleep(1);
  fTimerGroup.Start;
 end;

end;

function THATimerGroup.GetTransactionCount: integer;
begin
 result:=fTrList.Count;
end;


function THADAGROUP.GetGroupIsActive: bool;
begin
 result:=fTimerGroup.fActive;
end;

function THADAGROUP.GetCountItems: integer;
begin
 result:=Length(fListItem);
end;

function THADAGROUP.GetOPCItem(index: integer): THAOPCItem;
begin
 result:=nil;
 if (index<0) or (index>High(fListItem)) then exit;
 if fListItem[index].Deleted then exit;
 result:=fListItem[index];
end;

{ THAGroupUpdater }

{constructor THAGroupUpdater.Create(AGroup:THADAGroup);
begin
 inherited Create(false);
 fGroup:=AGroup;
 fUpdateList:=TList.Create;
 InitializeCriticalSection(fCS);
end;

destructor THAGroupUpdater.Destroy;
begin
 DeleteCriticalSection(fCS);
  inherited;
end;

procedure THAGroupUpdater.Execute;

  function CheckModifyTag(OPCItem:THAOPCItem; OldTime:TFileTime):boolean;
  begin
   result:=false;
   if OPCItem=nil then exit;
   result:=OPCItem.OldQuality<>OPCItem.Quality;
   if result then exit;
   if (OPCItem.CanonicalDataType and vt_Array)<>vt_Array then
    result:=VarCompareValue(OPCItem.OldValue,OPCItem.Value)<>vrEqual
   else
    result:=true;
  end;
var i,CountOPCItems:integer;
    oItem:THAOPCItem;
    ftOld:TFileTime;
    p:PHAVQTCacheItem;
begin
  repeat
   if not fStop then
    begin
     EnterCriticalSection(fCS);
     if fLastIDTransCommit<OPCMan.CurrIdTrans then
      begin
        OPCMan.BeginRead;
        try
          CountOPCItems:=fGroup.CountOPCItems;
          for i:=0 to CountOPCItems-1 do
           if (fGroup.OPCItems[i]<>nil) and fGroup.OPCItems[i].Active then
             begin
              oItem:=fGroup.OPCItems[i];
              if CheckModifyTag(oItem,ftOld) then
               begin
                new(p);
                p^.ftTimeStamp:=oItem.TimeStamp;
                p^.wQuality:=oItem.Quality;
                p^.vDataValue:=oItem.Value;
                p^.IndexOPCItem:=i;
                p^.IDCache:=oItem.IDCache;


                oItem.OldTimeStamp:=p^.ftTimeStamp;
                oItem.OldQuality:=p^.wQuality;
                oItem.OldValue:=p^.vDataValue;

                fUpdateList.Add(p);
               end;
             end;
       finally
        fLastIDTransCommit:=OPCMan.CurrIdTrans;
        OPCMan.EndRead;
       end;
   end;
   LeaveCriticalSection(fCS);
  end
  else
   sleep(2);


  until Terminated;
end;

procedure THAGroupUpdater.Start;
begin
 EnterCriticalSection(fCS);
 fStop:=false;
 LeaveCriticalSection(fCS);
end;

procedure THAGroupUpdater.Stop;
begin
 EnterCriticalSection(fCS);
 fStop:=true;
 LeaveCriticalSection(fCS);

end;

procedure THAGroupUpdater.TerminateAndFree;
begin
 Terminate;
 waitfor;
 free;
end;
 }
function THATimerGroup.GetIDTrans: dword;
begin
 result:=fGroupTransaction.IDTrans;
end;


procedure THATimerGroup.FreeCommand(Command: THAPSCommand);
begin
 Command.Deleted:=true;
 fCommandsClearning.Add(Command);
end;

procedure THATimerGroup.ClearTransactions;
begin
 fTransactionsIsClearning:=false;
 fNeedClearTransactions:=true;
end;

procedure THATimerGroup.ClearGroupTransaction;
begin
 fGroupTransactionIsClearning:=false;
 fNeedClearGroupTransaction:=true;
end;

procedure THATimerGroup.AddDeletedItem(Item: THAOPCItem);
begin
 fDeletedItems.Add(Item);
end;

initialization
  TTypedComObjectFactory.Create(ComServer, THADAGROUP, Class_HADAGROUP,
    ciInternal, tmFree);
end.
