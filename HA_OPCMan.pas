unit HA_OPCMan;
{$I IngaOPC.inc}
interface
 uses
  SysUtils, Classes, Windows, ActiveX,Intf, dialogs,ha_log,variants, ha_classes,
  uPSCompiler, uPSRuntime,uPSDebugger,uPSComponent,
  uPSUtils,HA_DllManager,ha_daGroup,opcda,opctypes,ha_xmldata,comobj,ha_types,
  hadaimp,opc_ae,inifiles,HA_StoredTags,messages,ha_filters,HA_ErrorCodes,HA_DynCommandMan,OPCHDA;


 type

 

   THACacheDebugMode=(cdm_Normal,cdm_Delay,cdm_RunStop);

   TIGPropValues=array of olevariant;

   PDACacheItem=^TDACacheItem;
   TDACacheItem=record
    ftTimeStamp:          TFileTime;
    wQuality:             word;
    vDataValue:           OleVariant;
    pController:          pointer;
    pTag:                 pointer;
   end;


   PSimpleTrParam=^TSimpleTrParam;
   TSimpleTrParam=record
    IDItem:integer;
    Value:variant;
    Quality:integer;
    TimeStamp:TFileTime;
    SetValue:boolean;
    SetQuality:boolean;
    SetTimeStamp:boolean;
   end;



 {PCommandTrans=^TCommandTrans;
 TCommandTrans=record
  hServerGroup:dword;
  Command:THAPSCommand;
 end; }


  THACurrentParams=class(TObject)
   public
    Controller:TIGDevice;
    CurrentTags:TIGTags;
    Command:TIGCommand;
   // ParentCommand:TIGCommand;
    DriverData:TIGDriverData;
    Trans:THATransaction2;
    IGConverter:TIGConverter;
    TagsFilter:THAFilter;
    procedure Clear;
    constructor Create;
    destructor destroy; override;

  end;

  THAOPCMan=class(TThread)
   private
    fXData:THAData;
    fCurrentConfig:string;
    fDllMan:THADriverMan2;//THADriverMan;

    fDynCommandMan:THADynCommandMan;

   // fRunnedHashList:TList;



    fLocalClientHandle:dword;

    fComTable:TList;

    fPSResume:boolean;

    {$IFDEF FULLVERSION}
    fListItems:TList;
    {$ELSE}
    fItem0,
    fItem1,
    fItem2,
    fItem3,
    fItem4,
    fItem5,
    fItem6,
    fItem7,
    fItem8,
    fItem9,
    fItem10,
    fItem11,
    fItem12,
    fItem13,
    fItem14,
    fItem15,
    fItem16,
    fItem17,
    fItem18,
    fItem19,
    fItem20,
    fItem21,
    fItem22,
    fItem23 :pointer;

    {$ENDIF}



    //fListAEItems:TList;
   // fListAECat:TStringList; // список категорий событий строка - ID

    fRoot:THABaseObj;



    fStoredTags:THAStoredTags;

    fTemplates:TList;
    fControllers:TList;


   // fStateCommand:TList;
  //  fDynCommand:TThreadList;
    fCommandsInDrv:TList;
    fcommandsInDrvGen:dword;
    fListIDTransactionsClear:TList;

    fNeedInitDevices:boolean;
    fNeedDeinitDevices:boolean;

    fAddedItems:boolean;

    fCurrIdTrans:cardinal;
   // fCSWrite:TRTLCriticalSection; // крит. секция использована для блокировки
                                    // читающих клиентов перед записью транзакции
    fCSAddTr:TRTLCriticalSection;
    fCSUpdateRate:TRTLCriticalSection;
    fCSLockRead:TRTLCriticalSection;
  //  fCSLockCommands:TRTLCriticalSection;
   // fCSCommandInDrv:TRTLCriticalSection;


    fcClientRead:integer;

   // fLockRead:boolean;
    fListTransactions:TList;
   // fTimeLimitTr:cardinal;

    fGenUniI:dword;
    fGenUniICommand:dword;


    fTimeRun:TFileTime;

    fStop,
    fStopped,
    fReset:boolean;
    fNeedLoadNewConfig:boolean;
    fCurrentNoConfig:dword;

    fOnShutDown:boolean;
    fShutDownHandle:dword;
    fShutDownForce:boolean;



    fCurrP:THACurrentParams;


    fHWNDGlav        :THandle;
    fHWNDDebug       :THandle;
  //  fHWNDDebugDriver :THandle;
    fHWNDDynList     :THandle;
    fCacheDebugMode  :THACacheDebugMode;
    fCacheDebugDelay :dword;
    fCacheDebugRun   :boolean;

    // ДЛЯ ДЕМО ВЕРСИИ
    {$IFDEF DEMOVERSION}
    function GetDemoItem(index:integer):pointer;
    procedure SetDemoItem(index:integer; p:pointer);
    function GetDemoCountItems:integer;
//    function GetMaxDemoCountItems:integer;
    function AddDemoItem(p:pointer):integer;
    {$ENDIF}


    // полная перезагрузка кэша, шаблонов, команд и т.д.
    function ResetOPCMan:boolean;
    function CheckClientsForNewConfig:boolean;
    // загрузка устройств из файла
    function LoadControllers:boolean;
    // загрузка шаблонов из файлов
    function LoadTemplate(TemplateName:string; out IDCache:integer):THATemplate;
    // кол-во тэгов в кэше
    function GetCount: integer;
    // вызов указателя на элемент кэша, предназначенного для чтения
    function CurrItemValRead(i:integer):pointer;
    // вызов указателя на элемент кэша, предназначенного для записи
    function CurrItemValWrite(i:integer):pointer;
    // удаление и освобождение памяти для одного элемента кэша
    procedure ClearItem(ind:integer);
    // подтверждение транзакции на запись одного или нескольких элементов кэша
    function CommitCache:boolean;


    procedure SetPSExecError(AController:TIGDevice);



    // CallBack процедура для отработки логики выгрузки сервера
    procedure LastReleaseCom(var Shutdown: Boolean);

    // отключение одного или всех клиентов от сервера
    // хэндл клиента должен быть перед этим прописан в поле fShutDownHandle
    // если это поле = 0 то отключаются все клиенты
    procedure ShutDown;

    // удаление и освобождение памяти всех объектов
    // необходима для перезагрузки сервера и для его выгрузки
    procedure ClearAllObjects(LoadNewConfig:boolean);

    // CallBack процедуры для отладчика скриптов
    procedure PSBreakpoint(Sender: TObject; const FileName: String;
                           Position, Row, Col: Cardinal);
    procedure PSIdle(Sender: TObject);
    procedure PSLineInfo(Sender: TObject; const FileName: String;
                         Position, Row, Col: Cardinal);

    // генерация уникального номера команды для передачи его в драйвер
    // после драйвера, по этому номеру находится ссылка на команду
    function GenHandleCommandsInDrv:dword;



//******************************************************************************
// в этих методах происходит работа со скриптами

    procedure PSExecuteInitDevice(AInit:boolean);

    // первичная обработка транзакции
    // выполнение скриптов OnRead, OnWrite
    procedure BeforeRunTransaction(Tr:THATransaction2);


    // перед подачей команды в драйвер выполняется скрипт OnBeforeWrite
    // и формируются данные для драйвера (pDriverData)
    function PSExecuteCommandTrans(Command:THAPSCommand):HResult;

    // чтение результатов выполнения команды из драйвера
    // выполняется постоянно в цикле метода Execute
    function LoadResponseDrv:boolean;


    procedure CheckTimers;

//******************************************************************************

    // поиск транзакции по уникальному номеру
    function SearchTransaction(IDTrans:dword; SearchInGroups:boolean):THATransaction2;


    // поиск устройства по адресу
    function SearchControllerByAdress(HashDrv:cardinal; Adress:string):TIGDevice;
    // поиск устройства по имени
    function SearchControllerByName(AName:string):TIGDevice;

    // поиск команды шаблона по номеру команды
    function SearchCommandByNoCommand(Controller:TIGDevice; NoCommand:string):TIGCommand;
    // поиск шаблона по его OID
    function SearchTemplate(OIDTemplate:integer):THATemplate;

    // если открыто окно Driver Data по происходит передача этому окну
    // данных для лога сформированных драйвером
//    procedure LoadDrvInfo;

    // группа функций для чтения параметров которые доступны только кэшу и
    // скриптам сервера
    function GetNewQuality(Index: integer): word;
    function GetNewValue(Index: integer): OleVariant;
    function GetNewFileTime(Index: integer): TFileTime;

    // группа функций для чтения параметров которые доступны
    // на данный момент клиентам
    function GetOldQuality(Index: integer): word;
    function GetOldValue(Index: integer): OleVariant;
    function GetOldFileTime(Index: integer): TFileTime;

    // группа функций для записи параметров в кэш которые будут доступны
    // клиентам после выполнения процедуры CommitCache
    procedure SetNewQuality(Index: integer; const Value: word);
    procedure SetNewValue(Index: integer; const Value: OleVariant);


    // извлечение всех свойств привязанных к конкретной ячейке кэша
    function GetPropValues(Index: integer): TIGPropValues;

    // извлечение шаблона тэга из конкретной ячейки
    function GetTag(index: integer): TIGTag;
    // извлечение ссылки на устройство из конкретной ячейки
    function GetController(index:integer):TIGDevice;



    function GetCountGroups: integer;
    function GetCountServers: integer;
    function GetCountServersWithNotIOPCShutdown: integer;
//    function GetComServer(index: integer): TComObject;
    function GetCurrenthServerGroup(Index: integer): OPCHANDLE;
    function GetCurrentUpdateRate(Index: integer): dword;
    procedure CalcIndexUpdateRate(Index:integer);
  //  function GetResultRW(index: integer): HResult;
  //  procedure SetResultRW(index: integer; const Value: HResult);

    function AddItem(PController,PTag: pointer):integer;
    procedure SetHWNDDebug(const Value: THandle);
    function GetCountTemplates: integer;
    function GetTemplate(index: integer): THATemplate;
    function GetComServer(index: integer): TComObject;
    procedure SetCacheDebugMode(const Value: THACacheDebugMode);
    function GetControllers(index: integer): TIGDevice;
    function GetCountControllers: integer;
    function GetPercentLoadingDrivers: byte;




   protected
    procedure Execute; override;
   public

    //fCSTrGroup:TRTLCriticalSection;

   {$IFDEF DEMOVERSION}
    function GetMaxDemoCountItems:integer;
   {$ENDIF}


    constructor Create(Stopped:boolean);
    destructor destroy; override;
    procedure TerminateAndFree;

    property HWNDGlav:THandle read fHWNDGlav write fHWNDGlav;
    property HWNDDebug:THandle read fHWNDDebug write SetHWNDDebug;
//    property HWNDDebugDriver:THandle read fHWNDDebugDriver write fHWNDDebugDriver;
    property HWNDDynList:THandle read fHWNDDynList write fHWNDDynList;
    property CacheDebugMode:THACacheDebugMode read fCacheDebugMode write SetCacheDebugMode;
    property CacheDebugDelay:dword read fCacheDebugDelay write fCacheDebugDelay;
    procedure SetCacheDebugRun;


    property CurrP:THACurrentParams read fCurrP;

    property Root:THABaseObj read fRoot;
    procedure GetDANamesFromPath( ParentObj:THABaseObj; S:TStrings;
                                BrowseFilterType: OPCBROWSETYPE;
                                FilterCriteria:string;
                                DataTypeFilter: TVarType;
                                AccessRightsFilter: DWORD;
                                AddedPath:string;
                                var Res:boolean);

    function GetDAObjectFromPath(Path:TStrings; out IDCache,IDProp:integer):THABaseObj;


    procedure GetAENamesFromPath(ParentObj:THABaseObj;
                                 S:TStrings;
                                 BrowseFilterType:OPCAEBROWSETYPE;
                                 FilterCriteria:string);

    function GetAEObjectFromPath(Path:TStrings):THABaseObj;

    {$IFDEF HDAINTERFACE}
    procedure GetHDANamesFromPath(ParentObj:THABaseObj;
                                  S:TStrings;
                                  dwBrowseType:OPCHDA_BROWSETYPE;
                                  AddedPath:string);

    function GetHDAObjectFromPath(Path:TStrings):THABaseObj;
    {$ENDIF}


  //  procedure ParsePath(APath:string; Res:TStrings);
//    property Cache:TDA_CacheDRV2 read fcacheDrv;
    property TimeRun:TFileTime read fTimeRun;

    function GenUniI: dword;
    function GenUniICommand:dword;
  //  procedure Log(s:string);

    procedure BeginAddItems;

    procedure EndAddItems;
    property AddedItems:boolean read fAddedItems;

    procedure BeginRead;
    procedure SetValueItem(Index:integer; value:OleVariant);

    property OldValue   [Index:integer]:OleVariant  read GetOldValue;
    property OldQuality [Index:integer]:word        read GetOldQuality;
    property OldFileTime[Index:integer]:TFileTime   read GetOldFileTime;


    property NewValue   [Index:integer]:OleVariant  read GetNewValue    write SetNewValue;
    property NewQuality [Index:integer]:word        read GetNewQuality  write SetNewQuality;
    property NewFileTime[Index:integer]:TFileTime   read GetNewFileTime;

    procedure SetNewValueAsArray(Index,IndexArr:integer; const Value:OleVariant);

    //property ResultRW[index:integer]:HResult          read GetResultRW    write SetResultRW;

    property Tag[index:integer]:TIGTag               read GetTag;
    property Controller[index:integer]:TIGDevice read GetController;

    property PropValues[Index:integer]:TIGPropValues read GetPropValues;

    property CurrentUpdateRate[Index:integer]:dword read GetCurrentUpdateRate;
    property CurrenthServerGroup[Index:integer]:OPCHANDLE read GetCurrenthServerGroup;
    procedure AddUpdateRate(Index:integer; UpdateRate:dword; Active:boolean; hServerGroup:OPCHandle);
    procedure DeleteUpdateRate(Index:integer; Active:boolean; hServerGroup:OPCHandle);
    procedure ReplaceUpdateRate(Index:integer; UpdateRate:dword; OldActive,NewActive:Boolean; hServerGroup:OPCHandle);
   // property Items[Index:integer]:TDACacheItem read GetItem; default;
    property Count:integer read GetCount;
    procedure EndRead;

    property CountLockRead:integer read fcClientRead;

//    procedure AddTransaction(TransactionObj: THATransaction);
    procedure AddTransaction2(Tr:THATransaction2);
    procedure AddCommand(Command:THAPSCommand);
    procedure AddCommandInDynList(Command:THAPSCommand);

//    function AddGroup(COMGroup:pointer; OID:TOID; NameGroup:string; Interval:dword; Active:boolean):THAGroup;
//    procedure AddGroupTransaction(GroupTransaction:THAGroupTransaction);
//    procedure ClearGroupCommand(IDTrans:dword);
//    function SearchGroupByOID(OID:TOID):THAGroup;
 //   function SearchGroupByTimerID(TimerID:dword):THAGroup;

//    function ValidVariantType(VType:TVarType; IdItem:integer):boolean;
   // property BranchSep:char read fBranchSep;


    procedure Stop;
    procedure Start;
    property Stopped:boolean read fStopped;
    procedure Reset;
    property Reseting:boolean read fReset;
    procedure LoadNewConfig;
//    property NeedLoadNewConfig:boolean read fNeedLoadNewConfig;
    property CurrentNoConfig:dword read fCurrentNoConfig;


    //property  PSDebugMode:boolean read fPSDebugMode write fPSDebugMode;

    procedure PSSetBreakPoint(OIDTemplate:integer; Line:longint);
    procedure PSStepOver(OIDTemplate:integer);
    function  PSHasBreakPoint(OIDTemplate:integer; Line:longint):boolean;
   // property  PSActiveLine:longint read fPSActiveLine;
    procedure PSRun(OIDTemplate:integer);
    procedure PSClearAllBreakPoints;

    procedure AddServer(Server:TObject);
    procedure RemoveServer(Server:TObject);
    procedure ShutDownServer(hServer:dword; Force:boolean);
    property IsShutDownServers:boolean read fOnShutDown;

//    function AddComObject(ComObject:TComObject; ParentHandle:dword):dword;
//    function GetComObject(Handle:dword):TComObject;
//    function RemoveComObject(Handle:dword):boolean;
//    procedure GetComHandles(ParentHandle:dword; L:TList);
//    function GetCountComObjects(ParentHandle:dword):integer;
    property CountServers:integer read GetCountServers;
    property CountGroups:integer read GetCountGroups;
    property CountServersWithNotIOPCShutdown:integer read GetCountServersWithNotIOPCShutdown;
    property HAServer[index:integer]:TComObject read GetComServer;


    function GetVarsFromScript(OIDTemplate:integer; PSTypeProc:TPSTypeProc; var tmp:THATemplate):TIFStringList;
    function GetGlobalVar(tmp:THATemplate; i:integer; PSTypeProc:TPSTypeProc):PPSVariant;
   // procedure GetScripts(TemplateNames,Scripts:TStrings);

    property Templates[index:integer]:THATemplate read GetTemplate;
    property CountTemplates:integer read GetCountTemplates;

    property Controllers[index:integer]:TIGDevice read GetControllers;
    property CountControllers:integer read GetCountControllers;


//    property LocalClientHandle:dword read fLocalClientHandle write fLocalClientHandle;

//    procedure GetDynList(st:TStrings);
    property CurrIdTrans:cardinal read fCurrIdTrans;

    property CurrentConfig:string read fCurrentConfig;

    property PercentLoadingDrivers:byte read GetPercentLoadingDrivers;

    property DLLMan:THADriverMan2 read fDllMan;
  end;

 function CheckOPCMan: HResult;

 var OPCMan:THAOPCMan;

implementation
  uses ha_utils,ComServ,ha_glav,ha_wmconst,IngaOPC_TLB,masks,
  Math,ha_regserver,ha_fmglobalparams;



 function CheckOPCMan: HResult;
 begin
  result:=s_ok;
  if OPCMan=nil then
   begin
    result:=e_fail;
    exit;
   end;
  if OPCMan.Stopped then
   result:=e_fail;
  if OPCMan.AddedItems then
   result:=e_fail;

 end;

type
 PCommandInDrv=^TCommandInDrv;
 TCommandInDrv=record
  Handle:dword;
  Command:THAPSCommand;
 end;

 PDACacheItemValue=^TDACacheitemValue;
 TDACacheitemValue=record
  ftTimeStamp:  TFileTime;
  wQuality:     word;
  vDataValue:   OleVariant;
  IdTrans:      cardinal;
 // ResultRW:      dword;
 end;

 TDACacheUpdateRate=record
  UpdateRate:dword;
  hServerGroup:OPCHandle;
//  Active:bool;
  RefCount:integer;
  RefActive:integer;
 end;


 PDACacheBuffer=^TDACacheBuffer;
 TDACacheBuffer=record
  pItemValue1:PDACacheitemValue;
  pItemValue2:PDACacheitemValue;

  PController:   pointer;
  PTag:          pointer;


  CacheUpdateRates:array of TDACacheUpdateRate;
  CurrentUpdateRateIndex:integer;
  pPropValues:   TIGPropValues;
 end;


 TAECacheItem=record
  Active                :   boolean;  // событие активно
  Acked                 :   boolean; // для событий требующих подтверждение
  ftTimeLastActive      :   TFileTime;
  PController           :   pointer;  // ссылка на Source
  PEvent                :   pointer;  // ссылка на определение события
  PActiveSubEvent       :   pointer; // ссылка на активное подсобытие (если событие сложное)

 end;  




{ THAOPCMan }

function THAOPCMan.AddItem(PController,PTag: pointer): integer;
var p:PDACacheBuffer;
    SR:THAStoredRec;
    fp:Int64;
    i:integer;
    oldCurrentRecordIsFill:dword;
procedure InitValue;
begin
 if (TIGTag(PTag).TypeTag and VarArray)=VarArray then
   p^.pItemValue1^.vDataValue:=VarArrayCreate([0,0],TIGTag(PTag).TypeTag and VarTypeMask)
 else
  begin
    if TIGTag(PTag).TypeTag=vt_bstr then
      p^.pItemValue1^.vDataValue:=VarAsType('',TIGTag(PTag).TypeTag)
    else
      p^.pItemValue1^.vDataValue:=VarAsType(0,TIGTag(PTag).TypeTag);

  end;

 p^.pItemValue1^.wQuality:=OPC_QUALITY_BAD;
 p^.pItemValue1^.ftTimeStamp:=ConvertToFileTime(now);
end;

begin
 new(p);
 fillchar(p^,sizeof(TDACacheBuffer),0);
 p^.PController:=PController;
 p^.PTag:=PTag;

 new(p^.pItemValue1);
 fillchar(p^.pItemValue1^,sizeof(TDACacheitemValue),0);

 if TIGTag(PTag).Saved then
  begin
   i:=0;
   oldCurrentRecordIsFill:=0;
   if fStoredTags.IsWork then
    begin
     while oldCurrentRecordIsFill<>fStoredTags.CurrentRecordIsFill do
      begin
       sleep(100);
       oldCurrentRecordIsFill:=fStoredTags.CurrentRecordIsFill;
      end;
     while fStoredTags.IsWork and (i<5000) do
      begin
       sleep(50);
       inc(i,50);
      end;
    end;

   if fStoredTags.GetStoredRecByTagName(TIGDevice(PController).FullNameObj+BranchSep+TIGTag(PTag).FullNameObj,SR,fp,i) then
    begin
     p^.pItemValue1^.vDataValue:=SR.Value;
     p^.pItemValue1^.wQuality:=SR.Quality;
     p^.pItemValue1^.ftTimeStamp:=SR.TimeStamp;
    end
   else
    InitValue;
  end
 else
  begin
   InitValue;
  end;

 new(p^.pItemValue2);
 fillchar(p^.pItemValue2^,sizeof(TDACacheitemValue),0);

 p^.pItemValue2^:=p^.pItemValue1^;

 {$IFDEF FULLVERSION}
  result:=fListItems.Add(p);
 {$ELSE}
  result:=AddDemoItem(p);
 {$ENDIF}  
end;


{procedure THAOPCMan.AddTransaction(TransactionObj: THATransaction);
begin
 EnterCriticalSection(fCSAddTr);
 fListTransactions.Add(TransactionObj);
 LeaveCriticalSection(fCSAddTr);
end;
 }
procedure THAOPCMan.BeginAddItems;
begin
 fAddedItems:=true;
end;

procedure THAOPCMan.BeginRead;
begin
 EnterCriticalSection(fCSLockRead);
 inc(fcClientRead);
 LeaveCriticalSection(fCSLockRead);
end;


{procedure THAOPCMan.ClearControllers;
var i:integer;
begin
 for i:=0 to fControllers.Count-1 do
  TIGDevice(fControllers[i]).Free;
 fControllers.Clear;
end;
 }

procedure THAOPCMan.ClearItem(ind: integer);
var p:PDACacheBuffer;
begin
 {$IFDEF FULLVERSION}
 if (ind<0) or (ind>=fListItems.Count) then exit;
 p:=fListItems[Ind];
 {$ELSE}
 //if (ind<0) or (ind>=GetDemoCountItems) then exit;
 if ind>=GetMaxDemoCountItems then exit;
 p:=GetDemoItem(ind);
 {$ENDIF}

 if p=nil then exit;
 if p.pItemValue1<>nil then
  dispose(p.pItemValue1);
 if p.pItemValue2<>nil then
  dispose(p.pItemValue2);
 SetLength(p.pPropValues,0);
 SetLength(p.CacheUpdateRates,0);
 dispose(p);
 {$IFDEF FULLVERSION}
 fListItems[Ind]:=nil;
 {$ELSE}
 SetDemoItem(ind,nil);
 {$ENDIF}
end;

{procedure THAOPCMan.ClearListItems;
var i:integer;
begin
 for i:=0 to fListItems.Count-1 do
  ClearItem(i);
 fListItems.Clear;
end;


procedure THAOPCMan.ClearTemplates;
var i:integer;
begin
 for i:=0 to fTemplates.Count-1 do
  THATemplate(fTemplates[i]).Free;
 fTemplates.Clear;
end;

procedure THAOPCMan.ClearTr;
var i:integer;
begin
 for i:=0 to fListTransactions.Count-1 do
  if THATransaction(fListTransactions[i]).DeviceTrans then
   THATransaction(fListTransactions[i]).Free;
 fListTransactions.Clear;
end;
}

constructor THAOPCMan.Create(Stopped:boolean);
begin
 inherited Create(false);
 fLocalClientHandle:=0;

 fCurrentConfig:='';
 fCurrentNoConfig:=1;
 fNeedLoadNewConfig:=false;

 fNeedInitDevices:=false;
 fNeedDeinitDevices:=false;

 fHWNDGlav:=0;
 fHWNDDebug:=0;
// fHWNDDebugDriver:=0;

 fStoredTags:=THAStoredTags.Create;

 fComTable:=TList.Create;
 fCurrP:=THACurrentParams.Create;
 fAddedItems:=true;

 fDllMan:=THADriverMan2.Create(ExtractFilePath(ParamStr(0))+'DLL');
 fDynCommandMan:=THADynCommandMan.Create(fDLLMan);


 ComServer.OnLastRelease:=LastReleaseCom;

 {$IFDEF FULLVERSION}
 fListItems:=TList.Create;
 {$ELSE}
  fItem0  :=nil;
  fItem1  :=nil;
  fItem2  :=nil;
  fItem3  :=nil;
  fItem4  :=nil;
  fItem5  :=nil;
  fItem6  :=nil;
  fItem7  :=nil;
  fItem8  :=nil;
  fItem9  :=nil;
  fItem10  :=nil;
  fItem11  :=nil;
  fItem12  :=nil;
  fItem13  :=nil;
  fItem14  :=nil;
  fItem15  :=nil;
  fItem16  :=nil;
  fItem17  :=nil;
  fItem18  :=nil;
  fItem19  :=nil;
  fItem20  :=nil;
  fItem21  :=nil;
  fItem22  :=nil;
  fItem23  :=nil;
 {$ENDIF}





 //fListAEItems:=TList.Create;
 //fListAECat:=TStringList.Create;


 fTemplates:=TList.Create;
 fControllers:=TList.Create;

 fCommandsInDrv:=TList.Create;
 fListIDTransactionsClear:=TList.Create;



 fCurrIdTrans:=1;
 fcClientRead:=0;

 InitializeCriticalSection(fCSAddTr);
 InitializeCriticalSection(fCSUpdateRate);
 InitializeCriticalSection(fCSLockRead);

 fListTransactions:=TList.Create;

 fStop:=Stopped;
 fStopped:=true;
 fReset:=true;
 fOnShutDown:=false;
// fNeedLoadNewConfig:=false;

 fGenUniI:=0;
 fCommandsInDrvGen:=0;
end;

function THAOPCMan.CurrItemValRead(i: integer): pointer;
var //cb:TDACacheBuffer;
    pcb:PDACacheBuffer;
begin
 result:=nil;
 pcb:=nil;
 {$IFDEF FULLVERSION}
 if (i<0) or (i>=fListItems.count) then exit;
 pcb:=fListItems[i];
 {$ELSE}
 pcb:=GetDemoItem(i);
 {$ENDIF}
 if pcb=nil then exit;

 if pcb^.pItemValue1.IdTrans=fCurrIdTrans then
  result:=PDACacheItemValue(pcb^.pItemValue2)
 else
  if pcb^.pItemValue2.IdTrans=fCurrIdTrans then
    result:=PDACacheItemValue(pcb^.pItemValue1)
  else
   if pcb^.pItemValue1.IdTrans<pcb^.pItemValue2.IdTrans then
     result:=PDACacheItemValue(pcb^.pItemValue2)
   else
    if pcb^.pItemValue1.IdTrans>=pcb^.pItemValue2.IdTrans then
      result:=PDACacheItemValue(pcb^.pItemValue1);
end;

function THAOPCMan.CurrItemValWrite(i: integer): pointer;
var pcb:PDACacheBuffer;

begin
 result:=nil;
 pcb:=nil;
// cb:=TDACacheBuffer(fListItems[i]^);
 {$IFDEF FULLVERSION}
  if (i<0) or (i>=fListItems.count) then exit;
  pcb:=fListItems[i];
 {$ELSE}
 pcb:=GetDemoItem(i);

 {$ENDIF}
 if pcb=nil then exit;

 if pcb^.pItemValue1.IdTrans=fCurrIdTrans then
  result:=PDACacheItemValue(pcb^.pItemValue1)
 else
  if pcb^.pItemValue2.IdTrans=fCurrIdTrans then
    result:=PDACacheItemValue(pcb^.pItemValue2)
  else
   if pcb^.pItemValue1.IdTrans<pcb^.pItemValue2.IdTrans then
     result:=PDACacheItemValue(pcb^.pItemValue1)
   else
    if pcb^.pItemValue1.IdTrans>=pcb^.pItemValue2.IdTrans then
      result:=PDACacheItemValue(pcb^.pItemValue2);

end;

destructor THAOPCMan.destroy;
begin
 try

  ClearAllObjects(false);
  fRoot.Free;
  fStoredTags.TerminateAndFree;
  fListTransactions.Free;
  DeleteCriticalSection(fCSAddTr);
  DeleteCriticalSection(fCSUpdateRate);
//  DeleteCriticalSection(fCSCommandInDrv);

  {$IFDEF FULLVERSION}
  fListItems.Free;
  {$ENDIF}

  fTemplates.Free;
  fControllers.Free;
 // fDM.Free;
  fXData.Free;
  //fListAECat.Free;
//  fPSDebug.Free;
  fDllMan.Free;// TerminateAndFree;
 // fStateCommand.Free;
 // fDynCommand.Free;
  fDynCommandMan.Free;

  fCommandsInDrv.Free;
//  fRunnedHashList.Free;
  fListIDTransactionsClear.Free;
 // fTransGroup.Free;
  fCurrP.Free;
  fComTable.Free;
  DeleteCriticalSection(fCSLockRead);
  AddLog(1,'Destroy',s_ok,'OK');
 except
  on E: Exception do
    AddLog(1,'Destroy',E_FAIL,e.Message);
 end;
 inherited;

end;

procedure THAOPCMan.EndAddItems;
begin
 fAddedItems:=false;
// fStop:=false;
// fStopped:=false;
end;

procedure THAOPCMan.EndRead;
begin
// dec(fcClientRead);
// fMRW.EndRead;
// EnterCriticalSection(fCSLockRead);
 dec(fcClientRead);
// LeaveCriticalSection(fCSLockRead);

end;

procedure THAOPCMan.Execute;
var Tr:THATransaction2;
    i:integer;
    OldStateWFlag,OldStateLFlag:integer;
    PSComm:THAPSCommand;

procedure SendStateOPCMan(WState:integer; LState:integer=0);
begin
 if (OldStateWFlag=WState) and (OldStateLFlag=LState) then exit;
 OldStateWFlag:=WState;
 OldStateLFlag:=LState;
 postmessage(fHWNDGlav,wm_StateOPCMan,WState,LState);

end;



begin
 fRoot:=THABaseObj.Create(nil,0,0,'');
 fXData:=THAData.Create(ExtractFilePath(ParamStr(0)));
 OldStateWFlag:=0;
 OldStateLFlag:=0;
  repeat
   sleep(1);



   if fReset then
    begin
     fStop:=false;
     fStopped:=false;
     SendStateOPCMan(som_IsReseting,1);
     ClearAllObjects(true);
     ResetOPCMan;
    // fDllMan.Open;
     if fComTable.Count>0 then
      fDLLMan.Open(0);
     fReset:=false;
     SendStateOPCMan(som_IsReseting,2);
     fNeedLoadNewConfig:=false;
    end;

   if fOnShutDown then
    begin
     ShutDown;
     fOnShutDown:=false;
    end;


   if fNeedLoadNewConfig then
     fReset:=CheckClientsForNewConfig;


   if fNeedInitDevices then
    begin
     fDLLMan.Open(0);
     PSExecuteInitDevice(True);
     fNeedInitDevices:=false;

    end;

   if fNeedDeinitDevices then
    begin
     PSExecuteInitDevice(false);
     fNeedDeinitDevices:=false;
     fDLLMan.close(0,false);
    end;

   CheckTimers; 

   if not fStop then
    begin
       SendStateOPCMan(som_IsRunning);
       if LoadResponseDrv then
         SendStateOPCMan(som_RWDevice);

       for i:=0 to fDynCommandMan.CountHash-1 do
        begin
         PSComm:=fDynCommandMan.HashCommands[i];
         if PSComm<>nil then
          if PSComm.CurrentNoConfig=fCurrentNoConfig then
           PSExecuteCommandTrans(PSComm);
        end;

   fDynCommandMan.CheckDeletedCommand;
   if Terminated then
    fListTransactions.Clear;

   for i:=fListTransactions.Count-1 downto 0 do
  // if fListTransactions.Count>0 then
    begin

     Tr:=THATransaction2(fListTransactions[i]);

     case Tr.TrState of
      trs_Wait: begin
                 BeforeRunTransaction(Tr);
                 if Tr.TrState in [trs_Commit,trs_Roolback,trs_Cancel,trs_Clear] then
                  begin
                    EnterCriticalSection(fCSAddTr);
                    fListTransactions.Delete(i);
                    Tr.InUse:=false;
                    LeaveCriticalSection(fCSAddTr);
                  end;
                end;

      trs_Commit,
      trs_Roolback,
      trs_Cancel,
      trs_Clear    :begin
                     EnterCriticalSection(fCSAddTr);
                     fListTransactions.Delete(i);
                     Tr.InUse:=false;
                     LeaveCriticalSection(fCSAddTr);
                    end;
     end;

    end;

   case fCacheDebugMode of
    cdm_Delay:sleep(fCacheDebugDelay);
    cdm_RunStop:begin
                 while (not fCacheDebugRun) do
                  sleep(1);
                 fCacheDebugRun:=false;
                end;
   end;

  end
   else
    if not fStopped then
     begin
       fDllMan.Close(0,true);
       fStopped:=true;
       SendStateOPCMan(som_IsStopped);
     end;


 until terminated; //and (fTransGroup.Count=0);

 AddLog(1,'Terminated',s_ok,'OK');

end;

function THAOPCMan.GetCount: integer;
begin
{$IFDEF FULLVERSION}
 result:=fListItems.count;
{$ELSE}
 result:=GetDemoCountItems;
{$ENDIF}
end;

function THAOPCMan.GenUniI: dword;
begin
 inc(fGenUniI);
 if fGenUniI=0 then
  inc(fGenUniI);
 result:=fGenUniI;
end;


{function THAOPCMan.GetItem(Index: integer): TDACacheItem;
var cb:TDACacheBuffer;
    p:PDACacheItemValue;
begin
 cb:= TDACacheBuffer(fListItems[Index]^);
 result.pController:=cb.PController;
 result.pTag:=cb.PTag;


 p:=nil;
 p:=CurrItemValRead(Index);
 if p<>nil then
  begin
   result.ftTimeStamp:=p^.ftTimeStamp;
   result.wQuality:=p^.wQuality;
   result.vDataValue:=p^.vDataValue;
  end


end;
 }


procedure THAOPCMan.LastReleaseCom(var Shutdown: Boolean);
begin
 ShutDown:=ComServer.StartMode<>smStandalone	;
end;




{procedure THAOPCMan.ParseName(AName: string; L: TStringList);
var i:integer;
    s:string;
begin
 l.Clear;
 s:='';
 for i:=1 to length(AName) do
  begin
   if (AName[i]=BranchSep) or (i=Length(AName)) then
    begin
     if i=Length(AName) then
      s:=s+AName[i];
     l.Add(s);
     s:='';
    end
   else
    s:=s+AName[i];
  end;



end;

 }

procedure THAOPCMan.PSBreakpoint(Sender: TObject; const FileName: String;
  Position, Row, Col: Cardinal);
begin
// fPSIdle:=true;
 fPSResume:=false;
 if fHWNDDebug=0 then exit;
 SendMessage(fHWNDDebug,wm_PSBreakPoint,TPSScriptDebugger(Sender).Tag,row);


// Synchronize(Sync_LoadActiveLineScript);
end;



function THAOPCMan.PSHasBreakPoint(OIDTemplate:integer; Line: Integer): boolean;
var tmp:THATemplate;
begin
 result:=false;
 tmp:=SearchTemplate(OIDTemplate);
 if tmp=nil then exit;
 result:=tmp.PSDebug.HasBreakPoint(tmp.PSDebug.MainFileName,Line);
end;

procedure THAOPCMan.PSIdle(Sender: TObject);
begin
// while fPSIdle do
 sleep(50);

 if fPSResume then
  if Sender is TPSScriptDebugger then
   begin
    fPSResume:=false;
    TPSScriptDebugger(Sender).Resume;
    SendMessage(fHWNDDebug,wm_PSIdle,TPSScriptDebugger(Sender).Tag,0);
   end;
end;

procedure THAOPCMan.PSLineInfo(Sender: TObject; const FileName: String;
  Position, Row, Col: Cardinal);
begin
 if fHWNDDebug=0 then exit;
 if TPSScriptDebugger(Sender).Exec.DebugMode<>dmRun then
   SendMessage(fHWNDDebug,wm_PSLineInfo,TPSScriptDebugger(Sender).Tag,row);
// Synchronize(Sync_LoadActiveLineScript);
end;

procedure THAOPCMan.PSRun(OIDTemplate:integer);
var i:integer;
    tmp:THATemplate;
begin
 //fPSLineInfoON:=false;
 if OIDTemplate>=0 then
  begin
   tmp:=SearchTemplate(OIDTemplate);
   if tmp=nil then exit;
   if tmp.PSDebug.Running then
    fPSResume:=true;
  end
 else
  for i:=0 to fTemplates.Count-1 do
   if THATemplate(fTemplates[i]).PSDebug.Running then
     fPSResume:=true;

{ if fPSDebug.Running then
  begin
   fPSResume:=true;
  // fPSIdle:=false;
  end;}
end;

procedure THAOPCMan.Reset;
begin
 fReset:=true;
end;






function THAOPCMan.ResetOPCMan: boolean;

function SortContr(Item1,Item2:pointer):integer;
var c1,c2:TIGDevice;
begin
 c1:=TIGDevice(Item1);
 c2:=TIGDevice(Item2);
 if c1.HashDrv<c2.HashDrv then result:=1
 else
  if c1.HashDrv>c2.HashDrv then result:=-1
  else
   result:=0;


end;

var st:systemtime;

begin
 AddLog(1,'Обновление конфигурации...',s_ok,' ');
 fcClientRead:=0;
 GetSystemtime(st);
 SystemTimeToFileTime(ST,fTimeRun);
 BeginAddItems;
 try
 // sleep(10000);
  result:=Loadcontrollers;
  
  fDynCommandMan.Refresh;
 finally
  EndAddItems;
 end;
end;

{procedure THAOPCMan.SetItem(Index: integer; const Value: TDACacheItem);
var cb:TDACacheBuffer;
    p:PDACacheItemValue;
begin
 cb:= TDACacheBuffer(fListItems[Index]^);
 cb.PController:=Value.pController;
 cb.PTag:=Value.pTag;

 p:=nil;
 p:=CurrItemValWrite(Index);
 if p<>nil then
  begin
   p^.ftTimeStamp:=Value.ftTimeStamp;
   p^.wQuality:=Value.wQuality;
   p^.vDataValue:=Value.vDataValue;
  end


end;  }

procedure THAOPCMan.PSSetBreakPoint(OIDTemplate:integer; Line: longint);
var PS:TPSScriptDebugger;
    tmp:THATemplate;
begin
// if not Assigned(fmDebugger) then exit;
 if fHWNDDebug=0 then exit;
 tmp:=SearchTemplate(OIDTemplate);
 if tmp=nil then exit;

  PS:=tmp.PSDebug;
  if PS.HasBreakPoint(PS.MainFileName,Line) then
   PS.ClearBreakPoint(PS.MainFileName,Line)
  else
   PS.SetBreakPoint(PS.MainFileName,Line);
end;


procedure THAOPCMan.SetValueItem(Index:integer; value: OleVariant);
var p:PDACacheItemValue;
begin
 p:=CurrItemValWrite(Index);
 if p=nil then exit;
 p^.vDataValue:=Value;
 p.IdTrans:=fCurrIdTrans;
end;

procedure THAOPCMan.PSStepOver(OIDTemplate:integer);
var tmp:THATemplate;
begin
 tmp:=SearchTemplate(OIDTemplate);
 if tmp=nil then exit;
 tmp.PSDebug.StepOver;
end;

procedure THAOPCMan.Stop;
begin
 fStopped:=false;
// fOnShutDown:=OnShutDown;
 fStop:=true;
end;

procedure THAOPCMan.TerminateAndFree;
begin
 //SetCacheDebugMode(cdm_Normal);
 Terminate;
 WaitFor;
 free;
end;

{function THAOPCMan.ValidVariantType(VType: TVarType;
  IdItem: integer): boolean;
begin
 if (vType and VarArray)=varArray then
  result:=boolean((vType and VarTypeMask) in [varEmpty..$14])
 else
  result:=boolean(vType in [varEmpty..$14]);

end;  }










{ TBranchNode }

{procedure TBranchNode.AddBranchChild(Branch: TBranchNode);
begin
 fBranchs:=ReallocMemory(fBranchs,sizeof(TBranchNode)*(fCountBranchs+1));
 inc(fCountBranchs);
 fBranchs[fCountBranchs-1]:=Branch;
end;

procedure TBranchNode.AddIndLeaf(IndLeaf: integer);
begin
 fLeafs:=ReallocMemory(fLeafs,sizeof(integer)*(fCountLeafs+1));
 inc(fCountLeafs);
 fLeafs[fCountLeafs-1]:=Indleaf;
end;

constructor TBranchNode.Create(AName: string; ParentBranch: TBranchNode);
begin
inherited Create;
 fName:=AName;
 fBranchs:=nil;
 fCountBranchs:=0;
 fLeafs:=nil;
 fCountLeafs:=0;
 fParentBranch:=ParentBranch;
 if fParentBranch<>nil then
  fParentBranch.AddBranchChild(self);
end;

destructor TBranchNode.Destroy;
 var i:integer;
begin
 for i:=0 to fCountBranchs-1 do
  fBranchs[i].Free;
  FreeMem(fBranchs);
  FreeMem(fLeafs);
  inherited;
end;}


function THAOPCMan.GetVarsFromScript(OIDTemplate:integer; PSTypeProc:TPSTypeProc; var tmp:THATemplate):TIFStringList;
begin
 result:=nil;
 tmp:=SearchTemplate(OIDTemplate);
 if tmp=nil then exit;
 case PSTypeProc of
  pstp_Global:result:=tmp.PSDebug.Exec.GlobalVarNames;
  pstp_Local :result:=tmp.PSDebug.Exec.CurrentProcVars;
  pstp_Params:result:=tmp.PSDebug.Exec.CurrentProcParams;
 end;

end;


{procedure THAOPCMan.LoadDrvInfo;
var s:string;
begin
 if fHWNDDebugDriver<>0 then
  while fDLLMan.CountInfo>0 do
   begin
    s:=fDLLMan.NextInfo;
    SendMessage(fHWNDDebugDriver,wm_DebugDriver,integer(s),0);
   end;
end;
 }


function THAOPCMan.GetNewQuality(Index: integer): word;
 var p:PDACacheItemValue;
begin
 result:=OPC_QUALITY_BAD;
 p:=CurrItemValWrite(Index);
 if p<>nil then
  result:=p^.wQuality;
end;

function THAOPCMan.GetNewValue(Index: integer): OleVariant;
 var p:PDACacheItemValue;
     pcb:PDACacheBuffer;
  //   pp:pointer;
begin
 result:=null;
 pcb:=nil;
 p:=CurrItemValWrite(Index);
 if p=nil then exit;
 if p^.IdTrans<fCurrIdTrans then
  p:=CurrItemValRead(Index);
 if p<>nil then
  begin

   {$IFDEF FULLVERSION}
   pcb:=fListItems[index];
   {$ELSE}
   pcb:=GetDemoItem(index);
   {$ENDIF}
   if pcb=nil then exit;

   result:=VarAsType(p^.vDataValue,TIGTag(pcb^.PTag).TypeTag);
   //if VariantChangeTypeEx(result,p^.vDataValue,LOCALE_SYSTEM_DEFAULT,0,TIGTag(cb.PTag).TypeTag)<>s_ok then
   // raise Exception.Create('Error convert');
  end;
end;


function THAOPCMan.GetOldQuality(Index: integer): word;
var p:PDACacheItemValue;
    pcb:PDACacheBuffer;
begin
// BeginRead;
 if fStop then
  result:=OPC_QUALITY_OUT_OF_SERVICE
 else
  begin
   result:=OPC_QUALITY_BAD;

   {$IFDEF FULLVERSION}
   if (index<0) or (index>=fListItems.count) then exit;
   pcb:=fListItems[index];
   {$ELSE}
   pcb:=GetDemoItem(index);
   {$ENDIF}

   if pcb=nil then exit;

{   if not fDllMan.DrvIsOpen(TIGDevice(pcb^.PController).HashDrv) then
    begin
     result:=OPC_QUALITY_NOT_CONNECTED;
     exit;
    end;
 }
   p:=CurrItemValRead(Index);
   if p<>nil then
    result:=p^.wQuality;
  end;
// EndRead;
end;

function THAOPCMan.GetOldValue(Index: integer): OleVariant;
var p:PDACacheItemValue;
    pcb:PDACacheBuffer;
begin
// BeginRead;
 result:=null;
 pcb:=nil;
 p:=CurrItemValRead(Index);
 if p<>nil then
  begin
   {$IFDEF FULLVERSION}
   pcb:=fListItems[index];
   {$ELSE}
   pcb:=GetDemoItem(index);
   {$ENDIF}
   if pcb=nil then exit;
   result:=VarAsType(p^.vDataValue,TIGTag(pcb^.PTag).TypeTag);

  end;
// EndRead;
end;


procedure THAOPCMan.SetNewQuality(Index: integer; const Value: word);
 var p,pr:PDACacheItemValue;
    pcb:PDACacheBuffer;
begin
 p:=CurrItemValWrite(Index);
 pr:=CurrItemValRead(Index);
 if p<>nil then
  begin

   p^.wQuality:=Value;
   p^.ftTimeStamp:=ConvertToFileTime(now);
   if p.IdTrans<>fCurrIDTrans then
    if pr<>nil then
     p^.vDataValue:=pr^.vDataValue;
  // if pr<>nil then
  //  p^.vDataValue:=pr^.vDataValue;
   p.IdTrans:=fCurrIdTrans;
  // postmessage(fHWNDGlav,wm_OPCManChangedTag,index,integer(TDACacheBuffer(fListItems[Index]^).PClientData));

   {$IFDEF FULLVERSION}
   pcb:=fListItems[index];
   {$ELSE}
   pcb:=GetDemoItem(index);
   {$ENDIF}
   if pcb=nil then exit;

   if TIGTag(pcb^.PTag).Saved then
    fStoredTags.AddRecord(TIGDevice(pcb^.PController).FullNameObj+BranchSep+TIGTag(pcb^.PTag).FullNameObj,p^.vDataValue,p^.wQuality,p^.ftTimeStamp);
  end


end;

procedure THAOPCMan.SetNewValue(Index: integer; const Value: OleVariant);
 var p:PDACacheItemValue;
     pcb:PDACacheBuffer;
begin
 pcb:=nil;
 p:=CurrItemValWrite(Index);
 if p<>nil then
  begin

   {$IFDEF FULLVERSION}
   pcb:=fListItems[index];
   {$ELSE}
   pcb:=GetDemoItem(index);
   {$ENDIF}
   if pcb=nil then exit;

   p^.vDataValue:=Value;
   p^.ftTimeStamp:=ConvertToFileTime(now);
   p^.wQuality:=OPC_QUALITY_GOOD;
   p.IdTrans:=fCurrIdTrans;
   if not TIGTag(pcb^.PTag).Saved then exit;
   fStoredTags.AddRecord(TIGDevice(pcb^.PController).FullNameObj+BranchSep+TIGTag(pcb^.PTag).FullNameObj,p^.vDataValue,p^.wQuality,p^.ftTimeStamp);

  end;
end;

function THAOPCMan.GetOldFileTime(Index: integer): TFileTime;
var p:PDACacheItemValue;
begin
// BeginRead;
 result.dwLowDateTime:=0;
 result.dwHighDateTime:=0;
 p:=CurrItemValRead(Index);
 if p<>nil then
  result:=p^.ftTimeStamp;
// EndRead;
end;





procedure THAOPCMan.AddCommand(Command: THAPSCommand);
begin
 Command.OID:=GenUniICommand;
 if fCurrp.Trans<>nil then
  fCurrP.Trans.AddCommand(Command)
 else
  fDynCommandMan.AddCommand(Command);
end;

function THAOPCMan.PSExecuteCommandTrans(Command:THAPSCommand): HResult;
var pDD:pDriverData;
    i:integer;
    CProcBW:TIGCommandProcBW;
    p:PCommandInDrv;
    res,CanCancel:boolean;
    hres:HResult;
begin
 try
 res:=true;
 fCurrP.Clear;
 result:=s_ok;
 CanCancel:=false;
 if Command.ParentCommand.OnBeforeWrite<>'' then
  begin
    fCurrP.Command:=Command.ParentCommand;
    fCurrP.Controller:=Command.Controller;
    fCurrP.Trans:=SearchTransaction(Command.IDTrans,false);

    fCurrP.Controller.SwithIndexTemplate;
   // fCurrP.Controller.TagsList.IndexIsUser:=false;
    fCurrP.Command.Count:=Command.Count;
    for i:=0 to fCurrP.Command.Count-1 do
     fCurrP.Command.Data[i]:=Command.Data[i];

    fCurrP.Controller.TagsList.Filtered:=false;
    CProcBW:=TIGCommandProcBW(fCurrP.Controller.Template.PSDebug.Exec.GetProcAsMethodN(fCurrP.Command.OnBeforeWrite));
    try

      CProcBW(fCurrP.Controller,fCurrP.Command, CanCancel);
      fCurrP.Controller.TagsList.Filtered:=false;
      CommitCache;
      if fCurrP.Trans=nil then
        fCurrP.Trans:=SearchTransaction(Command.IDTrans,true);
      if fCurrP.Trans<>nil then
       begin
        fCurrP.Trans.SetResultForItems(-1,s_ok);
        if fCurrP.Trans.TrKind=tk_Group then
          fCurrP.Trans.InUse:=false;
       end;

    except
     if fCurrP.Trans=nil then
      fCurrP.Trans:=SearchTransaction(Command.IDTrans,true);

     if fCurrP.Trans<>nil then
      begin
       fCurrP.Trans.SetResultForItems(-1,E_BEFOREWRITECOMMAND_SCRIPTERROR);
       if fCurrP.Trans.TrKind=tk_Group then
        fCurrP.Trans.InUse:=false
       else
        fCurrP.Trans.TrState:=trs_Commit;
      end;
     SetPSExecError(fCurrP.Controller);
     Command.InUse:=false;
     res:=false;
   end;

  end;

 if not res then exit;
 if CanCancel then
  begin
   Command.State:=cs_commit;
   Command.InUse:=false;
   if fCurrP.Trans<>nil then
    if fCurrP.Trans.TrKind<>tk_Group then
     fCurrP.Trans.UpdateState;
   exit;
  end;

 new(p);
 p^.Handle:=GenHandleCommandsInDrv;
 p^.Command:=Command;
 //p^.Command.InUse:=true;
 fCommandsInDrv.Add(p);

 //new(pDD);
 pDD:=OPCTaskMemAlloc(hRes,sizeof(DriverData),1);
 fillchar(pDD^,sizeof(DriverData),0);
 pDD^.AddrDrv:=0;
 pDD.Handle:=p^.Handle;
 pDD.Result:=0;
 pDD.szAddress:=StringToLPOleStr(Command.Controller.address);
 pDD.szNoCommand:=StringToLPOleStr(Command.ParentCommand.NoCommand);
 pDD.Param:=Command.ParentCommand.Param;

 pDD.dwDataSize:=Command.Count;
 try
  //GetMem(DD.pData,DD.dwDataSize);
  pDD.pData:=OPCTaskMemAlloc(hres,sizeof(byte),pDD.dwDataSize);
  if hRes=s_ok then
   for i:=0 to Command.Count-1 do
     pDD.pData^[i]:=Command[i];

  Command.State:=cs_AfterWriting;
  if not fDLLMan.Write(Command.Controller.HashDrv,pDD) then
   begin
    if pDD^.pData<>nil then
     coTaskMemFree(pDD^.pData);
    if pDD^.szAddress<>nil then
     coTaskMemFree(pDD^.szAddress);
    if pDD^.szNoCommand<>nil then
     coTaskMemFree(pDD^.szNoCommand);
    coTaskMemFree(pDD);   
   end;

  if Command.ParentCommand.SPriority>0 then
   command.ParentCommand.Priority:=Command.ParentCommand.SPriority;
 except
 end;

 fCurrP.Clear;
except
 on E:Exception do
  AddLog(1,'PSExecuteCommandTrans',s_false,e.Message);
end;
end;

function THAOPCMan.CommitCache: boolean;
var ii:cardinal;
begin
 result:=true;
 ii:=GetTickCount;

 EnterCriticalSection(fCSLockRead);
// try
   while (fcClientRead>0) and (abs(GetTickCount-ii)<=GlobalParams.TimeOutCommitCache) do
     sleep(1);

   if fcClientRead<=0 then
    inc(fCurrIdTrans)
   else
    begin
     result:=false;
     AddLog(1,'CommitCache',E_FAIL,'RoolBack Transaction');
    end;
// finally
  LeaveCriticalSection(fCSLockRead);
// end;

end;




function THAOPCMan.LoadResponseDrv:boolean;

 function SearchGroupByhServerGroup(hServerGroup:dword):THADAGroup;
  var i,j:integer;
      Srv:THADAOBJ;
  begin
    result:=nil;
    for i:=0 to fComTable.Count-1 do
     begin
      Srv:=THADAOBJ(fComTable[i]);
      for j:=0 to Srv.GroupCount-1 do
       if THADAGroup(Srv.Groups[j]).hServerGroup=hServerGroup then
        begin
          result:=THADAGroup(Srv.Groups[j]);
          break;
        end;
     end;
  end;


var j,k:integer;
    pDD:pDriverData;
    Command:THAPSCommand;
    CProc:TIGCommandProcAR;


begin
 try
 result:=false;

 for j:=fCommandsInDrv.Count-1 downto 0 do
  if TCommandInDrv(fCommandsInDrv[j]^).Command.Deleted then
   begin
     Command:=TCommandInDrv(fCommandsInDrv[j]^).Command;
     Command.InUse:=false;
     if Command.IDTrans=0 then
      Command.Free;
     dispose(fCommandsInDrv[j]);
     fCommandsInDrv.delete(j);
   end;

 for k:=0 to fDLLMan.CountHash-1 do
 begin

     if fDLLMan.Read(fDLLMan.HashID[k],pDD)<>s_ok then continue;

         result:=true;
         fCurrP.Clear;
         Command:=nil;

       //  L:=fCommandsInDrv.LockList;
         try
             if pDD.Handle>0 then
              for j:=fCommandsInDrv.Count-1 downto 0 do
               if TCommandInDrv(fCommandsInDrv[j]^).Handle=pDD.Handle then
                begin
                 Command:=TCommandInDrv(fCommandsInDrv[j]^).Command;
                 dispose(fCommandsInDrv[j]);
                 fCommandsInDrv.delete(j);
                 break;
                end;



             if Command=nil then
              begin
               fCurrP.Controller:=SearchControllerByAdress(fDLLMan.HashID[k],string(pDD.szAddress));
             //  if fCurrP.Controller=nil then continue;
               fCurrP.Command:=SearchCommandByNoCommand(fCurrP.Controller,string(pDD.szNoCommand));
             //  if fCurrP.Command=nil then continue;
              end
             else
              begin
               fCurrP.Controller:=Command.Controller;
               fCurrP.Command:=Command.ParentCommand;
               fCurrP.Trans:=SearchTransaction(Command.IDTrans,false);
               Command.State:=cs_Commit;
              end;

             if (fCurrP.Command<>nil) and (fCurrP.Controller<>nil) then
              begin
                 fCurrP.Controller.SwithIndexTemplate;
                 fCurrP.Command.Count:=0;
                 if fCurrP.Command.OnAfterRead<>'' then
                  begin
                     if Command<>nil then
                      begin
                       fCurrP.Command.Count:=Command.Count;
                       for j:=0 to fCurrP.Command.Count-1 do
                         fCurrP.Command.Data[j]:=Command.Data[j];
                      end;

                     fCurrP.DriverData.Count:=pDD.dwDataSize;
                     for j:=0 to pDD.dwDataSize-1 do
                      fCurrP.DriverData.Data[j]:=pDD.pData^[j];
                     fCurrP.DriverData.Result:=pDD.Result;



                     fCurrP.Controller.TagsList.Filtered:=false;
                     CProc:=TIGCommandProcAR(fCurrP.Controller.Template.PSDebug.Exec.GetProcAsMethodN(fCurrP.Command.OnAfterRead));
                     try
                         CProc(fCurrP.Controller,fCurrP.Command,fCurrP.DriverData);
                         fCurrP.Controller.TagsList.Filtered:=false;
                         CommitCache;
                         if fCurrP.Trans=nil then
                          if Command<>nil then
                            fCurrP.Trans:=SearchTransaction(Command.IDTrans,true);
                         if fCurrP.Trans<>nil then
                          begin
                           fCurrP.Trans.SetResultForItems(-1,s_ok);
                           if fCurrP.Trans.TrKind=tk_Group then
                            fCurrP.Trans.InUse:=false;
                          end;
                         
                     except
                        if fCurrP.Trans=nil then
                          fCurrP.Trans:=SearchTransaction(Command.IDTrans,true);
                        if fCurrP.Trans<>nil then
                         begin
                          fCurrP.Trans.SetResultForItems(-1,E_AFTERREADCOMMAND_SCRIPTERROR);
                          if fCurrP.Trans.TrKind=tk_Group then
                            fCurrP.Trans.InUse:=false
                          else
                            fCurrP.Trans.TrState:=trs_Commit;
                         end;
                        SetPSExecError(fCurrP.Controller);
                     end;


                  end;
               end;


             if fCurrP.Trans<>nil then
              if fCurrP.Trans.TrKind<>tk_Group then
               fCurrP.Trans.UpdateState;

             fCurrP.Clear;
             if pDD.dwDataSize>0 then
              coTaskMemFree(pDD^.pData);

             if pDD.szAddress<>nil then
              coTaskMemFree(pDD.szAddress);
             if pDD.szNoCommand<>nil then
              coTaskMemFree(pDD.szNoCommand);
             coTaskMemFree(pDD);

         finally
          if Command<>nil then
           if Command.IDTrans=0 then
            Command.Free
           else
            Command.InUse:=false

         end;





 end;
 except
  on e:exception do
  AddLog(1,'LoadResponse',s_false,e.Message);
 end;
end;

function THAOPCMan.GetPropValues(Index: integer): TIGPropValues;
var pcb:PDACacheBuffer;
begin
  result:=nil;
  pcb:=nil;
 {$IFDEF FULLVERSION}
 if (Index<0) or (Index>=fListItems.count) then exit;
 pcb:=fListItems[Index];
 {$ELSE}
 pcb:=GetDemoItem(Index);
 {$ENDIF}
 if pcb=nil then exit;
 result:=pcb^.pPropValues;

end;

function THAOPCMan.SearchControllerByAdress(HashDrv: cardinal;
  Adress: string): TIGDevice;
var i:integer;
    fl:boolean;
begin
 fl:=false;
 result:=nil;
 for i:=0 to fControllers.Count-1 do
  begin
   if (TIGDevice(fControllers[i]).HashDrv<>HashDrv) then
    if fl then
     break
    else
     continue;

   fl:=true;
   if CompareStr(TIGDevice(fControllers[i]).Address,Adress)=0 then
    begin
     result:=fControllers[i];
     break;
    end;
  end;

end;

function THAOPCMan.SearchCommandByNoCommand(Controller: TIGDevice;
  NoCommand: string): TIGCommand;
var i:integer;
    tmp:THATemplate;
begin
 result:=nil;
 if Controller=nil then exit;
 tmp:=Controller.Template;
 if tmp=nil then exit;
 for i:=0 to tmp.CountCommands-1 do
  if CompareStr(tmp.Command[i].NoCommand,NoCommand)=0 then
   begin
    result:=tmp.Command[i];
    break;
   end;
end;

function THAOPCMan.GetTag(index: integer): TIGTag;
var pcb:PDACacheBuffer;
begin
 result:=nil;
 pcb:=nil;
 {$IFDEF FULLVERSION}
 if (Index<0) or (Index>=fListItems.count) then exit;
 pcb:=fListItems[Index];
 {$ELSE}
 pcb:=GetDemoItem(Index);
 {$ENDIF}
 if pcb=nil then exit;
 result:=pcb^.PTag;

end;





procedure THAOPCMan.SetNewValueAsArray(Index, IndexArr: integer;
  const Value: OleVariant);
var p,p1:PDACacheItemValue;
    pcb:PDACacheBuffer;
    v:OleVariant;

begin
 VarClear(v);
 p:=CurrItemValWrite(Index);
 pcb:=nil;
 if p<>nil then
  begin
   if p^.IdTrans<fCurrIdTrans then
    begin
     v:=p^.vDataValue;
     p1:=CurrItemValRead(Index);
     if p1=nil then exit;
     p^.vDataValue:=p1^.vDataValue;
    end;

  { if not VarIsEmpty(v) then
    begin
     VarArrayRedim(p^.vDataValue, VarArrayHighBound(v,1));
     lo:=VarArrayLowBound(p^.vDataValue,1);
     hi:=VarArrayHighBound(p^.vDataValue,1);
     for i:=lo to hi do
      p^.vDataValue[i]:=v[i];
    end;   }

   {$IFDEF FULLVERSION}
   pcb:=fListItems[index];
   {$ELSE}
   pcb:=GetDemoItem(index);
   {$ENDIF}
   if pcb=nil then exit;

   if VarArrayHighBound(p^.vDataValue,1)<indexArr then
    VarArrayRedim(p^.vDataValue, IndexArr);

   p^.vDataValue[indexArr]:=VarAsType(Value,TIGTag(pcb^.PTag).TypeTag and VarTypeMask);
   p^.ftTimeStamp:=ConvertToFileTime(now);
   p^.wQuality:=OPC_QUALITY_GOOD;
   p^.IdTrans:=fCurrIdTrans;
   if not TIGTag(pcb^.PTag).Saved then exit;
   fStoredTags.AddRecord(TIGDevice(pcb^.PController).FullNameObj+BranchSep+TIGTag(pcb^.PTag).FullNameObj,p^.vDataValue,p^.wQuality,p^.ftTimeStamp);
  end;
end;


function THAOPCMan.GetDAObjectFromPath(Path: TStrings; out IDCache,IDProp:integer): THABaseObj;
var c:TIGDevice;
    b:THABaseObj;
    i,ii,ci,j:integer;
    fl:boolean;

begin
  result:=nil;
  IDCache:=-1;
  IDProp:=-1;
  if Path.Count=0 then exit;
  ci:=Path.Count;
  B:=fRoot;
  for i:=0 to ci-1 do
   begin
    fl:=false;
    ii:=i;
    for j:=B.ChildCount-1 downto 0 do
     if CompareStr(B.Childs[j].NameObj,Path[i])=0 then
      begin
       fl:=true;
       result:=B.Childs[j];
       B:=result;
       break;
      end;
    if not fl then break;
    if result.ClassID=ClassController then break;
   end;

  if not fl then
   begin
    result:=nil;
    exit;
   end;

  if ii=ci-1 then  exit;

  if result.ClassID=ClassController then
   begin
      c:=TIGDevice(result);
      inc(ii);
      B:=TIGDevice(result).Template;
      for i:=ii to ci-1 do
       begin
        fl:=false;
        for j:=B.ChildCount-1 downto 0 do
         if CompareStr(B.Childs[j].NameObj,Path[i])=0 then
          begin
           fl:=true;
           result:=B.Childs[j];
           B:=result;
           if result.ClassID=ClassTag then
            IDCache:=c.FirstIndexCache+TIGTag(result).IndexForCache
           else
            if result.ClassID=ClassProp then
             IDProp:=j;

           break;
          end;
        if not fl then break;
       end;
   end;

  if not fl then
    result:=nil;



end;


{procedure THAOPCMan.ParsePath(APath:string; Res:TStrings);
var i:integer;
    ss:string;
begin
 if APath='' then exit;
 ss:='';
 for i:=1 to Length(APath) do
  if APath[i]<>BranchSep then
   begin
    ss:=ss+APath[i];
    if i=Length(APath) then
     Res.Add(ss);
   end
  else
   begin
    res.Add(ss);
    ss:='';
   end;
end;
 }

procedure THAOPCMan.GetDANamesFromPath(ParentObj:THABaseObj;
                                     S:TStrings;
                                     BrowseFilterType: OPCBROWSETYPE;
                                     FilterCriteria:string;
                                     DataTypeFilter: TVarType;
                                     AccessRightsFilter: DWORD;
                                     AddedPath:string;
                                     var Res:boolean);


function CheckFilters(ATag:TIGTag; AName:string):boolean;
begin
{ if ATag.IsHide then
  begin
   result:=false;
   exit;
  end;
 }
 {$IFDEF DEMOVERSION}
 if ATag.IndexForCache<0 then
  begin
   result:=false;
   exit;
  end;
 {$ENDIF}
  
 result:=true;
 if (DataTypeFilter=vt_Empty) and  (AccessRightsFilter=0) and (FilterCriteria='') then
   exit;

 if FilterCriteria<>'' then
  result:=MatchesMask(AName,FilterCriteria);


 if DataTypeFilter<>vt_Empty then
  result:=result and (ATag.TypeTag=DataTypeFilter);

 if AccessRightsFilter<>0 then
  case AccessRightsFilter of
   OPC_READABLE:result:=result and ATag.IsReadable;// and (not ATag.IsWriteable);
   OPC_WRITEABLE:result:=result and ATag.IsWriteable;// and (not ATag.IsReadable);
   OPC_READABLE and OPC_WRITEABLE:result:=result and ATag.IsReadable and ATag.IsWriteable;
  end;




end;


var i:integer;
    b:THABaseObj;
    ss:string;
begin
 if ParentObj=nil then
  B:=fRoot
 else
  if ParentObj.ClassID=ClassController then
   begin
    B:=TIGDevice(ParentObj).Template;
   end
  else
   B:=ParentObj;

 for i:=0 to B.ChildCount-1 do
  case BrowseFilterType of
   OPC_BRANCH:if B.Childs[i].ClassID in [ClassFolder,ClassController] then
                s.Add(B.Childs[i].NameObj);

   OPC_LEAF  :if B.Childs[i].ClassID in [ClassTag] then
               if CheckFilters(TIGTag(B.Childs[i]),B.Childs[i].NameObj) then
                 s.Add(B.Childs[i].NameObj);

   OPC_FLAT  :begin
               if B.Childs[i].ClassID in [ClassTag] then
                begin
                 if CheckFilters(TIGTag(B.Childs[i]),AddedPath+B.Childs[i].NameObj) then
                  if AddedPath<>'' then
                    s.Add(AddedPath+BranchSep+B.Childs[i].NameObj)
                  else
                    s.Add(B.Childs[i].NameObj);
                end
               else
                if B.Childs[i].ClassID in [ClassFolder,ClassController] then
                 begin
                  if AddedPath<>'' then
                   ss:=AddedPath+BranchSep+B.Childs[i].NameObj
                  else
                   ss:=B.Childs[i].NameObj;
                  {if B.Childs[i].ClassID=ClassController then
                    ss:=B.Childs[i].FullNameObj+BranchSep
                  else
                   ss:=AddedPath;}
                  GetDANamesFromPath(B.Childs[i],
                                   s,
                                   BrowseFilterType,
                                   FilterCriteria,
                                   DataTypeFilter,
                                   AccessRightsFilter,
                                   ss,res);
                 end;

              end;

  end;

end;

function THAOPCMan.SearchControllerByName(AName: string): TIGDevice;
var i:integer;
begin
 result:=nil;
 for i:=0 to fControllers.Count-1 do
  if comparestr(TIGDevice(fControllers[i]).NameObj,AName)=0 then
    begin
     result:=fControllers[i];
     break;
    end;
end;



{procedure THAOPCMan.ClearGroupCommand(IDTrans:dword);
var i:integer;
    j:dword;
begin }
 //EnterCriticalSection(fCSLockCommands);
{ try
  fListIDTransactionsClear.Add(pointer(IDTrans));
 finally
  LeaveCriticalSection(fCSLockCommands);
 end;
 }

{ try
 with fCommandsInDrv.LockList do
 try
 for i:=Count-1 downto 0 do
  if TCommandInDrv(Items[i]^).Command.IDTrans=IDTrans then
   begin
     dispose(Items[i]);
     Delete(i);
   end;
 finally
  fCommandsInDrv.UnlockList;
 end;

 with fDynCommand.LockList do
  try
   for i:=Count-1 downto 0 do
    begin
     j:=THAPSCommand(Items[i]).IDTrans;
     if j=IDTrans then
      Delete(i);
    end;
  finally
   fDynCommand.UnlockList;
  end;
 except
  AddLog(1,'Clear Group Command',s_false,'Error');
 end; }
//end;





function THAOPCMan.GetController(index: integer): TIGDevice;
var pcb:PDACacheBuffer;
begin
 result:=nil;
 pcb:=nil;
 {$IFDEF FULLVERSION}
 if (index<0) or (index>=fListItems.count) then exit;
 pcb:=fListItems[Index];
 {$ELSE}
 pcb:=GetDemoItem(Index);
 {$ENDIF}
 if pcb=nil then exit;
 result:=pcb^.PController;
end;



procedure THAOPCMan.ShutDown;
var i:integer;
    l: Tlist;
  //  co:THADAObj;
begin
  l := TList.Create;
  try
   for i:=0 to fComTable.Count-1 do
     l.Add(fComTable[i]);

   for i:=0 to L.Count-1 do
    if (THADAObj(L[i]).hServer=fShutDownHandle) or (fShutDownHandle=0) then
     if fShutDownForce then
       coDisconnectObject(THADAObj(L[i]) as IHADAObj,0)
     else
      THADAObj(L[i]).ShutDown(fShutDownForce);

  finally
   l.Free;
  end;

end;



{function THAOPCMan.AddComObject(ComObject: TComObject; ParentHandle: dword):dword;
var p:PHAComItem;
    i,j:integer;

begin
 new(p);
 p^.ComObj:=ComObject;
 p^.ParentHandle:=ParentHandle;
 j:=-1;
 for i:=0 to fComTable.Count-1 do
  if fComTable[i]=nil then
   begin
    j:=i;
    break;
   end;
 if j>-1 then
  begin
   fComTable[j]:=p;
   result:=j;
  end
 else
  result:=fComTable.Add(p);
 result:=result+1;
 if ParentHandle=0 then
  inc(fCountServers)
 else
  inc(fCountGroups);
end;

function THAOPCMan.GetComObject(Handle: dword):TComObject;
var i:integer;
begin
 result:=nil;
 if (Handle=0) or (Handle>fComTable.Count) then exit;
 result:=THAComItem(fComTable[Handle-1]^).ComObj;
end;

function THAOPCMan.RemoveComObject(Handle: dword): boolean;
var co:TComObject;
begin
 result:=false;
 if (Handle=0) or (Handle>fComTable.Count) then exit;
 if fComTable[Handle-1]=nil then exit;
 result:=true;
 if THAComItem(fComTable[Handle-1]^).ParentHandle=0 then
  dec(fCountServers)
 else
  dec(fCountGroups);

 dispose(fComTable[Handle-1]);
 fComTable[Handle-1]:=nil;
end;

procedure THAOPCMan.GetComHandles(ParentHandle: dword; L: TList);
var i:integer;
    ph:dword;
begin
  ph:=ParentHandle;
  for i:=0 to fComTable.Count-1 do
   if fComTable[i]<>nil then
    if THAComItem(fComTable[i]^).ParentHandle=PH then
    l.Add(pointer(i+1));
end;

function THAOPCMan.GetCountComObjects(ParentHandle: dword): integer;
var i:integer;
begin
 result:=0;
 for i:=0 to fComTable.Count-1 do
  if fComTable[i]<>nil then
   if THAComItem(fComTable[i]^).ParentHandle=ParentHandle then
     inc(result);

end;
}

{procedure THAOPCMan.ClearTransGroup;
var i:integer;
begin
 for i:=0 to fTransGroup.Count-1 do
  THAGroupTransaction(fTransGroup[i]).TrState:=trs_Cancel;
 fTransGroup.Clear;
end;
 }

procedure THAOPCMan.ClearAllObjects(LoadNewConfig:boolean);
var i:integer;
begin


 fDllMan.Close(0,true);

 fNeedInitDevices:=false;
 fNeedDeinitDevices:=false;


 fRoot.ClearChilds;
 fListTransactions.Clear;
 for i:=0 to fCommandsInDrv.Count-1 do
  begin
    if TCommandInDrv(fCommandsInDrv[i]^).Command.IDTrans=0 then
     TCommandInDrv(fCommandsInDrv[i]^).Command.Free
    else
     TCommandInDrv(fCommandsInDrv[i]^).Command.InUse:=false;
    dispose(fCommandsInDrv[i]);
  end;

 fCommandsInDrv.Clear;


 if LoadNewConfig then
  fDynCommandMan.ClearCommandsForOldNoConfig(fCurrentNoConfig)
 else
  fDynCommandMan.ClearAllCommands;


 for i:=0 to fControllers.Count-1 do
  TIGDevice(fControllers[i]).Free;
 fControllers.Clear;

 for i:=0 to fTemplates.Count-1 do
  THATemplate(fTemplates[i]).Free;
 fTemplates.Clear;


 {$IFDEF FULLVERSION}
 for i:=0 to fListItems.Count-1 do
  ClearItem(i);
 fListItems.Clear;
 {$ELSE}
 cdemo:=GetDemoCountItems;
 for i:=0 to cdemo-1 do
  ClearItem(i);
 {$ENDIF}

// fListAECat.Clear;

end;

procedure THAOPCMan.Start;
begin
 fStop:=false;
end;

{function THAOPCMan.GetGroup(hServerGroup: dword): TComObject;
var i:integer;
//   co:THADAObj;
begin
 result:=nil;
 for i:=fComTable.Count-1 downto 0 do
  begin
  // co:=THADAObj(fComTable[i]);
   result:=THADAObj(fComTable[i]).GetGroupByHandle(hServerGroup);
   if result<>nil then
    break;
  end;
end;
 }
procedure THAOPCMan.AddServer(Server: TObject);
begin
 if fComTable.Count=0 then
  begin
  // fDLLMan.Open(0);
   fNeedInitDevices:=true;
  end;
 fComTable.Add(Server);

 postmessage(fHWNDGlav,wm_StateOPCMan,som_IsRunning,0);
end;

procedure THAOPCMan.RemoveServer(Server: TObject);
begin
 fComTable.Remove(Server);
 if fComTable.Count=0 then
  begin
   fNeedDeinitDevices:=true;
  // fDLLMan.close(0,false);
  end;

 postmessage(fHWNDGlav,wm_StateOPCMan,som_IsRunning,0);
end;

function THAOPCMan.GetCountGroups: integer;
var i:integer;
begin
 result:=0;
 for i:=0 to fComTable.Count-1 do
  inc(result,THADAObj(fComTable[i]).GroupCount);
end;

function THAOPCMan.GetCountServers: integer;
begin
 result:=fComTable.Count;
end;



procedure THAOPCMan.ShutDownServer(hServer:dword; Force:boolean);
begin
 fShutDownHandle:=hServer;
 fShutDownForce:=Force;
 fOnShutDown:=true;
end;


function THAOPCMan.GetCountServersWithNotIOPCShutdown: integer;
var i:integer;
begin
 result:=0;
 for i:=0 to fComTable.Count-1 do
  if not THADAObj(fComTable[i]).IsSupportIOPCShutdown then
   inc(result);
end;




function THAOPCMan.GetCurrenthServerGroup(Index: integer): OPCHANDLE;
var i:integer;
    pcb:PDACacheBuffer;
begin
 result:=0;
 {$IFDEF FULLVERSION}
 if (Index<0) or (Index>=fListItems.count) then exit;
 pcb:=fListItems[Index];
 {$ELSE}
 pcb:=GetDemoItem(Index);
 {$ENDIF}
 if pcb=nil then exit;
 i:=pcb^.CurrentUpdateRateIndex;
 if (i<0) or (i>=Length(pcb^.CacheUpdateRates)) then exit;
 result:=pcb^.CacheUpdateRates[i].hServerGroup;


{ i:=TDACacheBuffer(fListItems[Index]^).CurrentUpdateRateIndex;
 if (i<0) or (i>=Length(TDACacheBuffer(fListItems[Index]^).CacheUpdateRates)) then exit;
 result:=TDACacheBuffer(fListItems[Index]^).CacheUpdateRates[i].hServerGroup;}
end;

function THAOPCMan.GetCurrentUpdateRate(Index: integer): dword;
var i:integer;
    pcb:PDACacheBuffer;
begin
 result:=0;
 {$IFDEF FULLVERSION}
 if (Index<0) or (Index>=fListItems.count) then exit;
 pcb:=fListItems[Index];
 {$ELSE}
 pcb:=GetDemoItem(Index);
 {$ENDIF}
 if pcb=nil then exit;

 i:=pcb^.CurrentUpdateRateIndex;
 if (i<0) or (i>=Length(pcb^.CacheUpdateRates)) then exit;
 result:=pcb^.CacheUpdateRates[i].UpdateRate;


{ i:=TDACacheBuffer(fListItems[Index]^).CurrentUpdateRateIndex;
 if (i<0) or (i>=Length(TDACacheBuffer(fListItems[Index]^).CacheUpdateRates)) then exit;
 result:=TDACacheBuffer(fListItems[Index]^).CacheUpdateRates[i].UpdateRate;}
end;





procedure THAOPCMan.CalcIndexUpdateRate(Index: integer);
var i,j:integer;
    ur:dword;
    pcb:PDACacheBuffer;
begin
 {$IFDEF FULLVERSION}
 if (Index<0) or (Index>=fListItems.count) then exit;
 pcb:=fListItems[Index];
 {$ELSE}
 pcb:=GetDemoItem(Index);
 {$ENDIF}
 if pcb=nil then exit;

 j:=-1;
 ur:=0;
 for i:=0 to High(pcb^.CacheUpdateRates) do
  if pcb^.CacheUpdateRates[i].RefActive>0 then
   if (pcb^.CacheUpdateRates[i].UpdateRate<ur) or (ur=0) then
    begin
     ur:=pcb^.CacheUpdateRates[i].UpdateRate;
     j:=i;
    end;
 pcb^.CurrentUpdateRateIndex:=j;




{ for i:=0 to High(TDACacheBuffer(fListItems[Index]^).CacheUpdateRates) do
  if TDACacheBuffer(fListItems[Index]^).CacheUpdateRates[i].RefActive>0 then
   if (TDACacheBuffer(fListItems[Index]^).CacheUpdateRates[i].UpdateRate<ur) or (ur=0) then
    begin
     ur:=TDACacheBuffer(fListItems[Index]^).CacheUpdateRates[i].UpdateRate;
     j:=i;
    end;
 TDACacheBuffer(fListItems[Index]^).CurrentUpdateRateIndex:=j;}
end;

procedure THAOPCMan.AddUpdateRate(Index: integer; UpdateRate: dword; Active:boolean; hServerGroup: OPCHandle);
var i,j:integer;
    pcb:PDACacheBuffer;
begin
 {$IFDEF FULLVERSION}
 if (Index<0) or (Index>=fListItems.count) then exit;
 if fListItems[index]=nil then exit;
 pcb:=fListItems[Index];
 {$ELSE}
 pcb:=GetDemoItem(Index);
 {$ENDIF}

 if pcb=nil then exit;

 EnterCriticalSection(fCSUpdateRate);
 j:=-1;
 for i:=0 to High(pcb^.CacheUpdateRates) do
  if pcb^.CacheUpdateRates[i].hServerGroup=hServerGroup then
   begin
    j:=i;
    break;
   end;

 if j<0 then
  begin
   SetLength(pcb^.CacheUpdateRates,Length(pcb^.CacheUpdateRates)+1);
   j:=high(pcb^.CacheUpdateRates);
   pcb^.CacheUpdateRates[j].UpdateRate:=UpdateRate;
   pcb^.CacheUpdateRates[j].hServerGroup:=hServerGroup;
   pcb^.CacheUpdateRates[j].RefCount:=1;
   if Active<>false then
    pcb^.CacheUpdateRates[j].RefActive:=1;
  end
 else
  begin
   inc(pcb^.CacheUpdateRates[j].RefCount);
   if Active then
    inc(pcb^.CacheUpdateRates[j].RefActive);
  end;

 CalcIndexUpdateRate(Index);
 LeaveCriticalSection(fCSUpdateRate);


{
 EnterCriticalSection(fCSUpdateRate);
 j:=-1;
 for i:=0 to High(TDACacheBuffer(fListItems[Index]^).CacheUpdateRates) do
  if TDACacheBuffer(fListItems[Index]^).CacheUpdateRates[i].hServerGroup=hServerGroup then
   begin
    j:=i;
    break;
   end;

 if j<0 then
  begin
   SetLength(TDACacheBuffer(fListItems[Index]^).CacheUpdateRates,Length(TDACacheBuffer(fListItems[Index]^).CacheUpdateRates)+1);
   j:=high(TDACacheBuffer(fListItems[Index]^).CacheUpdateRates);
   TDACacheBuffer(fListItems[Index]^).CacheUpdateRates[j].UpdateRate:=UpdateRate;
   TDACacheBuffer(fListItems[Index]^).CacheUpdateRates[j].hServerGroup:=hServerGroup;
   TDACacheBuffer(fListItems[Index]^).CacheUpdateRates[j].RefCount:=1;
   if Active<>false then
    TDACacheBuffer(fListItems[Index]^).CacheUpdateRates[j].RefActive:=1;
  end
 else
  begin
   inc(TDACacheBuffer(fListItems[Index]^).CacheUpdateRates[j].RefCount);
   if Active then
    inc(TDACacheBuffer(fListItems[Index]^).CacheUpdateRates[j].RefActive);
  end;

 CalcIndexUpdateRate(Index);
 LeaveCriticalSection(fCSUpdateRate); }
end;

procedure THAOPCMan.DeleteUpdateRate(Index: integer; Active:boolean;
  hServerGroup: OPCHandle);
var i,j:integer;
    pcb:PDACacheBuffer;
begin
 {$IFDEF FULLVERSION}
 if (Index<0) or (Index>=fListItems.count) then exit;
 if fListItems[index]=nil then exit;
 pcb:=fListItems[Index];
 {$ELSE}
 pcb:=GetDemoItem(Index);
 {$ENDIF}

 if pcb=nil then exit;

 EnterCriticalSection(fCSUpdateRate);
 j:=-1;
 for i:=0 to High(pcb^.CacheUpdateRates) do
  if pcb^.CacheUpdateRates[i].hServerGroup=hServerGroup then
   begin
    j:=i;
    break;
   end;
 if j<0 then exit;

 dec(pcb^.CacheUpdateRates[j].RefCount);

 if Active then
  dec(pcb^.CacheUpdateRates[j].RefActive);

 if pcb^.CacheUpdateRates[j].RefCount<=0 then
  begin
   for i:=j+1 to High(pcb^.CacheUpdateRates) do
    pcb^.CacheUpdateRates[i-1]:=pcb^.CacheUpdateRates[i];
   SetLength(pcb^.CacheUpdateRates,Length(pcb^.CacheUpdateRates)-1);
  end;



 CalcIndexUpdateRate(Index);
 LeaveCriticalSection(fCSUpdateRate);

{ if Index>=fListItems.Count then exit;
 if fListItems[index]=nil then exit;
 EnterCriticalSection(fCSUpdateRate);
 j:=-1;
 for i:=0 to High(TDACacheBuffer(fListItems[Index]^).CacheUpdateRates) do
  if TDACacheBuffer(fListItems[Index]^).CacheUpdateRates[i].hServerGroup=hServerGroup then
   begin
    j:=i;
    break;
   end;
 if j<0 then exit;

 dec(TDACacheBuffer(fListItems[Index]^).CacheUpdateRates[j].RefCount);

 if Active then
  dec(TDACacheBuffer(fListItems[Index]^).CacheUpdateRates[j].RefActive);

 if TDACacheBuffer(fListItems[Index]^).CacheUpdateRates[j].RefCount<=0 then
  begin
   for i:=j+1 to High(TDACacheBuffer(fListItems[Index]^).CacheUpdateRates) do
    TDACacheBuffer(fListItems[Index]^).CacheUpdateRates[i-1]:=TDACacheBuffer(fListItems[Index]^).CacheUpdateRates[i];
   SetLength(TDACacheBuffer(fListItems[Index]^).CacheUpdateRates,Length(TDACacheBuffer(fListItems[Index]^).CacheUpdateRates)-1);
  end;



 CalcIndexUpdateRate(Index);
 LeaveCriticalSection(fCSUpdateRate);  }
end;

procedure THAOPCMan.ReplaceUpdateRate(Index: integer; UpdateRate:dword; OldActive,NewActive:Boolean;
  hServerGroup: OPCHandle);
var i,j:integer;
    pcb:PDACacheBuffer;
begin
 {$IFDEF FULLVERSION}
 if (Index<0) or (Index>=fListItems.count) then exit;
 if fListItems[index]=nil then exit;
 pcb:=fListItems[Index];
 {$ELSE}
 pcb:=GetDemoItem(Index);
 {$ENDIF}

 if pcb=nil then exit;


 EnterCriticalSection(fCSUpdateRate);
 j:=-1;
 for i:=0 to High(pcb^.CacheUpdateRates) do
  if pcb^.CacheUpdateRates[i].hServerGroup=hServerGroup then
   begin
    j:=i;
    break;
   end;

 if j<0 then exit;

// if pUpdateRate<>nil then
  pcb^.CacheUpdateRates[j].UpdateRate:=UpdateRate;


  if NewActive and (not OldActive) then
    inc(pcb^.CacheUpdateRates[j].RefActive)
   else
    if (not NewActive) and OldActive then
     dec(pcb^.CacheUpdateRates[j].RefActive);




 CalcIndexUpdateRate(Index);
 LeaveCriticalSection(fCSUpdateRate);


{ if Index>=fListItems.Count then exit;
 if fListItems[index]=nil then exit;

 EnterCriticalSection(fCSUpdateRate);
 j:=-1;
 for i:=0 to High(TDACacheBuffer(fListItems[Index]^).CacheUpdateRates) do
  if TDACacheBuffer(fListItems[Index]^).CacheUpdateRates[i].hServerGroup=hServerGroup then
   begin
    j:=i;
    break;
   end;

 if j<0 then exit;

// if pUpdateRate<>nil then
 TDACacheBuffer(fListItems[Index]^).CacheUpdateRates[j].UpdateRate:=UpdateRate;


  if NewActive and (not OldActive) then
    inc(TDACacheBuffer(fListItems[Index]^).CacheUpdateRates[j].RefActive)
   else
    if (not NewActive) and OldActive then
     dec(TDACacheBuffer(fListItems[Index]^).CacheUpdateRates[j].RefActive);




 CalcIndexUpdateRate(Index);
 LeaveCriticalSection(fCSUpdateRate);    }


end;



procedure THAOPCMan.BeforeRunTransaction(Tr: THATransaction2);



function GetScript(index:integer):string;
var T:TIGTag;
begin
 result:='';
 T:=GetTag(index);
 if T=nil then exit;

 case Tr.TrKind of
    tk_AsyncRead,
    tk_SyncRead,
    tk_Group,
    tk_AsyncRefresh:result:=T.OnRead;

    tk_AsyncWrite,
    tk_SyncWrite   :result:=T.OnWrite;
 end;

end;

procedure SetVQT(index:integer);
var T:TIGTag;

begin
 if Tr.TrKind in [tk_AsyncWrite,tk_SyncWrite] then
  begin
    T:=GetTag(Tr.Items[index].IDCache);
    if T<>nil then
     T.SetVQT(Tr.VQT[index]);

  end;
end;

function ExecScript(AScript:string):boolean;
var i,fi:integer;
    TProcR:TIGTagProcR;
    TProcW:TIGTagProcW;
    flIsRead:boolean;

    Res:HResult;
  //  CProc:TIGCommandProc;
begin
 if fCurrP.Controller=nil then exit;
 result:=true;
 try
   fi:=fCurrP.Controller.FirstIndexCache;


   fCurrP.Controller.SwithIndexTemplate;

   if AScript<>'' then
    begin
  //   fCurrP.Controller.Template.PSDebug.SetVarToInstance('IGCONVERTER',fCurrP.IGConverter);
     fCurrP.Controller.TagsList.Filtered:=false;

     case Tr.TrKind of
        tk_AsyncRead,
        tk_SyncRead,
        tk_Group,
        tk_AsyncRefresh:flIsRead:=true;

        tk_AsyncWrite,
        tk_SyncWrite   :flIsRead:=false;
       end;
    // TProc:=TIGTagProc(fCurrP.Controller.Template.PSDebug.Exec.GetProcAsMethodN(AScript));

     if flIsRead then
      TProcR:=TIGTagProcR(fCurrP.Controller.Template.PSDebug.Exec.GetProcAsMethodN(AScript))
     else
      TProcW:=TIGTagProcW(fCurrP.Controller.Template.PSDebug.Exec.GetProcAsMethodN(AScript));

     try
       if flIsRead then
        TProcR(fCurrP.Controller,fCurrP.CurrentTags,Tr.TrKind=tk_Group)
       else
        TProcW(fCurrP.Controller,fCurrP.CurrentTags);

       fCurrP.Controller.TagsList.Filtered:=false;
     except
       SetPSExecError(fCurrP.Controller);
       if fCurrP.CurrentTags.Filtered then
         fCurrP.CurrentTags.Filtered:=false;
       if flIsRead then
        res:=E_READTAGS_SCRIPTERROR
       else
        res:=E_WRITETAGS_SCRIPTERROR;

       for i:=0 to fCurrP.CurrentTags.Count-1 do
        Tr.SetResultForItems(fCurrP.CurrentTags.Tags[i].IndexForCache+FI,res);
       result:=false;
     end;
    end
   else
    if Tr.TrKind in [tk_AsyncWrite,tk_SyncWrite] then
      for i:=0 to fCurrP.CurrentTags.Count-1 do
       begin
        fCurrP.CurrentTags[i].NewValue:=fCurrP.CurrentTags[i].VQT.Value;
        Tr.SetResultForItems(fCurrP.CurrentTags.Tags[i].IndexForCache+FI,s_ok);
       end;



 finally
 fCurrP.CurrentTags.Clear;
 end;
end;

var i:integer;
    SCurr,S:string;
    C:TIGDevice;
    res:boolean;
    
begin
 res:=true;
 fCurrP.Clear;
 SCurr:='';
 S:='';
 try
 Tr.TrState:=trs_Processed;

 fCurrP.Trans:=Tr;
 Tr.Sort;
 i:=0;

 while i<Tr.CountItems do
  begin
   C:=GetController(Tr.Items[i].IDCache);
   if C=nil then
    begin
     inc(i);
     continue;
    end;

   if (Tr.Items[i].IDProp>-1) and (Tr.TrKind in [tk_SyncWrite, tk_AsyncWrite]) then
    if PropValues[Tr.Items[i].IDCache]<>nil then
     begin
      PropValues[Tr.Items[i].IDCache][Tr.Items[i].IDProp]:=Tr.VQT[i].Value;
      fStoredTags.AddRecord(Tr.Items[i].FullName,Tr.VQT[i].Value,OPC_QUALITY_GOOD,ConvertToFileTime(now));

      inc(i);
      continue;
     end;

   S:=GetScript(Tr.Items[i].IDCache);


   if fCurrP.Controller<>C then
    begin
     res:=ExecScript(SCurr) or res;
     fCurrP.Controller:=C;
     //fCurrP.Controller.TagsList.ClearIndexTable;
     fCurrP.CurrentTags.Clear;
     fCurrP.CurrentTags.Add(GetTag(Tr.Items[i].IDCache{-fCurrP.Controller.FirstIndexCache}));

     //fCurrP.Controller.TagsList.AddIndex(Tr.Items[i].IDCache-fCurrP.Controller.FirstIndexCache);
     SetVQT(i);
     SCurr:=S;
    end
   else
    if SCurr<>S then
     begin
       res:=ExecScript(SCurr) or res;
       SCurr:=S;
       //fCurrP.Controller.TagsList.AddIndex(Tr.Items[i].IDCache-fCurrP.Controller.FirstIndexCache);
       fCurrP.CurrentTags.Add(GetTag(Tr.Items[i].IDCache{-fCurrP.Controller.FirstIndexCache}));
       SetVQT(i);
     end
    else
     begin
      //fCurrP.Controller.TagsList.AddIndex(Tr.Items[i].IDCache-fCurrP.Controller.FirstIndexCache);
      fCurrP.CurrentTags.Add(GetTag(Tr.Items[i].IDCache{-fCurrP.Controller.FirstIndexCache}));
      SetVQT(i);
     end;

   inc(i);

   try
   if i>=Tr.CountItems then
    res:=ExecScript(SCurr) or res;

    except
     on E:Exception do
      AddLog(1,'BeforeRun',e_fail,E.Message);
    end;

  end;

 if res then
  CommitCache;

 finally
   fCurrP.Clear;
   if Tr.TrKind=tk_Group then
    Tr.TrState:=trs_Commit
   else
    begin
      Tr.UpdateState;
    end;
 end;
end;




procedure THAOPCMan.AddCommandInDynList(Command: THAPSCommand);
begin
 fDynCommandMan.AddCommand(Command);
end;

procedure THAOPCMan.AddTransaction2(Tr: THATransaction2);
begin

 EnterCriticalSection(fCSAddTr);
 Tr.InUse:=true;
 Tr.TrState:=trs_wait;
 fListTransactions.Add(Tr);
 LeaveCriticalSection(fCSAddTr);
end;


function THAOPCMan.SearchTransaction(IDTrans: dword; SearchInGroups:boolean): THATransaction2;
var i,j:integer;
    srv:THADAObj;
begin
 result:=nil;
 if not SearchInGroups then
  begin
    for i:=0 to fListTransactions.Count-1 do
     if THATransaction2(fListTransactions[i]).IDTrans=IDTrans then
      begin
       result:=fListTransactions[i];
       break;
      end;
  end
 else
   for i:=0 to fComTable.Count-1 do
    begin
     srv:=THADAObj(fComTable[i]);
     for j:=0 to srv.GroupCount-1 do
      if (not THADAGroup(srv.Groups[j]).Deleted) and (THADAGroup(srv.Groups[j]).TimerGroup.GroupTransaction.IDTrans=IDTrans) then
       begin
        result:=THADAGroup(srv.Groups[j]).TimerGroup.GroupTransaction;
        result.InUse:=true;
        break;
       end;
     if result<>nil then break;
    end;
end;

{function THAOPCMan.GetResultRW(index: integer): HResult;
var p:PDACacheItemValue;
begin
 result:=e_fail;
 if fCurrP.Trans=nil then exit;
 result:=fCurrP.Trans.GetResultForItems(index);
end;

procedure THAOPCMan.SetResultRW(index: integer; const Value: HResult);
var p:PDACacheItemValue;
begin
 if fCurrP.Trans=nil then exit;
 fCurrP.Trans.SetResultForItems(index,Value);
end;}

function THAOPCMan.GetNewFileTime(Index: integer): TFileTime;
var p:PDACacheItemValue;
begin
 result.dwLowDateTime:=0;
 result.dwHighDateTime:=0;
 p:=CurrItemValWrite(Index);
 if p<>nil then
  result:=p^.ftTimeStamp;

end;

{procedure THAOPCMan.GetScripts(TemplateNames,Scripts:TStrings);
var i:integer;
begin
 for i:=0 to fTemplates.Count-1 do
  begin
   Scripts.AddObject(THATemplate(fTemplates[i]).Script,TObject(THATemplate(fTemplates[i]).OID));
   TemplateNames.Add(THATemplate(fTemplates[i]).NameObj);
  end;
end;
 }
 
function THAOPCMan.GetGlobalVar(tmp:THATemplate; i: integer; PSTypeProc:TPSTypeProc): PPSVariant;
begin
 result:=nil;
 if tmp=nil then exit;
 case PSTypeProc of
  pstp_Global:result:=tmp.PSDebug.Exec.GetGlobalVar(i);
  pstp_Local :result:=tmp.PSDebug.Exec.GetProcVar(i);
  pstp_Params:result:=tmp.PSDebug.Exec.GetProcParam(i);
 end;
end;



function THAOPCMan.LoadControllers: boolean;

function SortContr(Item1,Item2:pointer):integer;
var c1,c2:TIGDevice;
begin
 c1:=TIGDevice(Item1);
 c2:=TIGDevice(Item2);
 if c1.HashDrv<c2.HashDrv then result:=1
 else
  if c1.HashDrv>c2.HashDrv then result:=-1
  else
   result:=0;


end;



var NodeRoot:PHADataNode;
    s,FileName:string;
    st:TStringList;
    ini:TIniFile;

procedure LoadControllers_(node:PHADataNode; Parent:THABaseObj);
var b:THABaseObj;
    tmp:THATemplate;
    c:TIGDevice;
    Prop:TIGProp;
    p:PHADataNode;
    //p:PDataItem2;
    i,j,ii,k:integer;
    IDCache:integer;
    fl:boolean;

    pcb:PDACacheBuffer;
    sr:THAStoredRec;
    fi:Int64;
    ihl:integer;
begin
// n:=tv.GetFirstChild(node);


 for j:=0 to High(node.childs) do
  begin


   p:=node.childs[j];
   if p^.ClassID=ClassController then
    begin
     {$IFDEF DEMOVERSION}
      if GetDemoCountItems>=GetMaxDemoCountItems then break;
     {$ENDIF}

     c:=TIGDevice.Create(Parent,p^.OID,p^.Name,p^.Props);
     if not c.Active then
      begin
       c.Free;
       continue;
      end;
     tmp:=nil;
     st.Clear;
     st.Text:=p^.Props;
     for i:=0 to st.Count-1 do
      if CompareText('TemplateName',st.Names[i])=0 then
       begin
        tmp:=LoadTemplate(st.ValueFromIndex[i],IDCache);
        break;
       end;

     if tmp=nil then
      c.Free
     else
      begin
       c.Template:=tmp;
       i:=fControllers.Add(c);
       Parent.AddChild(c);

       {$IFDEF FULLVERSION}
       C.FirstIndexCache:=fListItems.Count;
       {$ELSE}
       c.FirstIndexCache:=GetDemoCountItems;
       {$ENDIF}

       c.Handle:=i+1;
      // fDllMan.Open(c.HashDrv);
       fDllMan.AddDriver(c.HashDrv);
       fl:=IDCache>-1;

       for i:=0 to tmp.CountTags-1 do
        begin
           {$IFDEF DEMOVERSION}
           if GetDemoCountItems>=GetMaxDemoCountItems then break;
           {$ENDIF}

           k:=AddItem(C,tmp.Tags[i]);
           {$IFDEF FULLVERSION}
           pcb:=fListItems[k];
           {$ELSE}
           pcb:=GetDemoItem(k);
           {$ENDIF}
           if pcb=nil then break;

           SetLength(pcb^.pPropValues,tmp.Tags[i].ChildCount);
           for ii:=0 to High(pcb^.pPropValues) do
            begin
             if fl then
              {$IFDEF FULLVERSION}
               pcb^.pPropValues[ii]:=TDaCacheBuffer(fListItems[IDCache]^).pPropValues[ii]
              {$ELSE}
               pcb^.pPropValues[ii]:=TDaCacheBuffer(GetDemoItem(IDCache)^).pPropValues[ii]
              {$ENDIF}

             else
              begin
               Prop:=tmp.Tags[i].PropByIndex[ii];
               if Prop<>nil then
                try

                 if fStoredTags.GetStoredRecByTagName(c.FullNameObj+BranchSep+Prop.FullNameObj,sr,fi,ihl) then
                  begin
                   pcb^.pPropValues[ii]:=sr.Value;
                  end
                 else
                 
                  if (Prop.TypeProp and vt_array)<>vt_array then
                    pcb^.pPropValues[ii]:=varastype(tmp.Tags[i].TmpPropValues[ii], Prop.TypeProp)
                  else
                    pcb^.pPropValues[ii]:=tmp.Tags[i].TmpPropValues[ii];

                except
                 on E:Exception do
                  AddLog(1,'Загрузка свойств',s_false,e.Message);
                end;
              end;
            end;
           SetLength(tmp.Tags[i].TmpPropValues,0);
           inc(IDCache);
        end;

       c.SwithIndexTemplate;
       c.TagsList.FilterObj:=fCurrP.TagsFilter;
       fCurrP.Clear;
       fCurrP.Controller:=c;
       c.Template.PSDebug.Execute;
      //  k:=c.Template.PSDebug.ExecErrorRow;
      //  s:=c.Template.PSDebug.ExecErrorToString;
      // fControllers.Sort(@SortContr);
       //for i:=0 to fControllers.Count-1 do

      end;

    end
   else
    begin
     b:=THABaseObj.Create(Parent,p^.OID,ClassFolder,p^.Name);
     Parent.AddChild(B);
     LoadControllers_(p,b);
    end;

//   {$IFDEF DEMOVERSION}
//   if GetDemoCountItems>=GetMaxDemoCountItems then exit;
//   {$ENDIF}
  end;
end;

begin
// {$IFDEF DEMOVERSION}
// fDemoCountItems:=0;
// {$ENDIF}

 new(NodeRoot);
 st:=TStringList.Create;
 ini:=TIniFile.Create(ChangeFileExt(ParamStr(0),'.ini'));
 try
  FileName:=ini.ReadString('Config','DefaultConfig','');
  if fStoredTags.SetStoredFile(ExtractFilePath(ParamStr(0))+ConfigsDir+'\'+FileName+ExtStoredTags)<>s_ok then
    AddLog(1,'Загрузка сохранненых значений тэгов',s_false,fStoredTags.ErrorString);

  if fXData.LoadOPC(em_Controllers, FileName,NodeRoot,s) then
   begin
    LoadControllers_(NodeRoot,fRoot);
    fCurrentConfig:=FileName;
    
    result:=true;
    AddLog(1,'Загрузка конфигурации "'+FileName+'"',s_ok,'OK');
  //  if fStoredTags.SetStoredFile(ExtractFilePath(ParamStr(0))+ConfigsDir+'\'+FileName+ExtStoredTags)<>s_ok then
  //    AddLog(1,'Загрузка сохранненых значений тэгов',s_false,fStoredTags.ErrorString);
   end
  else
   begin
    AddLog(1,'Загрузка конфигурации "'+FileName+'"',s_false,'Есть ошибки конфигурации');
    stop;
    result:=false;
   end;

 finally
  DisposeDataNode(NodeRoot);

  st.Free;
  ini.Free;
 end;
end;

function THAOPCMan.LoadTemplate(TemplateName: string;  out IDCache:integer):THATemplate;


procedure LoadTags(node:PHADataNode; Parent:THABaseObj);
var b:THABaseObj;
    p:PHADataNode;
    i:integer;
begin

 for i:=0 to High(node.childs) do
  begin


   p:=node.childs[i];
   case p^.ClassID of
    ClassTag
    {$IFDEF HDAINTERFACE}
    ,ClassTagHDA
    {$ENDIF}
            : begin
               b:=result.AddChildObject(p^.OID,p^.ClassID,p^.Name,p^.Props);
               Parent.AddChild(B);
               LoadTags(p,b);
              end;

    ClassFolder: begin
                   b:=THABaseObj.Create(Parent,p^.OID,ClassFolder,p^.Name);
                   Parent.AddChild(B);
                   LoadTags(p,b);
                 end;
    ClassLinkProp:begin
                   TIGTag(Parent).AddProp(p^.OID,p^.Props);
                  end;
   end;

  end;

end;


var i,j{,iCat,iEv,iSubEv,idCat}:integer;
    s:string;
    nroot,n,p,pc,{pcCat,pcEv,pcSubEv,}TagsRoot:PHADataNode;
    C:TIGDevice;
 //   ParentEvent:THAEvent;
    countItems:integer;
begin
 IDCache:=-1;
 result:=nil;

 for i:=0 to fTemplates.Count-1 do
  if CompareText(TemplateName,THABaseObj(fTemplates[i]).NameObj)=0 then
   begin
    result:=fTemplates[i];
    break;
   end;

 if result<>nil then
  begin
   i:=0;
   {$IFDEF FULLVERSION}
   countItems:=fListItems.Count;
   {$ELSE}
   countItems:=GetDemoCountItems;
   {$ENDIF}

   while i<countItems do
    begin
     C:=GetController(i);
     if C.Template=result then
      begin
       IDCache:=i;
       break;
      end;
     i:=i+C.TagsList.Count;
    end;
   exit;
  end;


 new(nRoot);
 n:=nRoot;
 try
 try
  if not fXData.LoadOPC(Em_Templates,TemplateName,n,s) then
   begin
    AddLog(1,'Загрузка шаблона "'+TemplateName+'"',s_false,'Ошибка загрузки шаблона');
    Stop;
    exit;
   end;

 if Length(n.Childs)<>1 then exit;
 n:=n.childs[0];
 if n=nil then exit;

 result:=THATemplate.Create(TemplateName,n.Props,fTemplates.Count,s,self);
 result.PSDebug.OnBreakpoint:=PSBreakpoint;
 result.PSDebug.OnIdle:=PSIdle;
 result.PSDebug.OnLineInfo:=PSLineInfo;

 //fTemplates.Add(result);

 TagsRoot:=nil;
 for i:=0 to High(n.childs) do
   begin
    p:=n.childs[i];
    case p^.ClassID of
     ClassFolderProps,
     ClassFolderCommands,
     ClassFolderTimers    :for j:=0 to High(p.childs) do
                            begin
                             pc:=p.childs[j];
                             result.AddChildObject(pc^.OID,pc^.ClassID,pc^.Name,pc^.Props);
                            end;

     ClassFolderTags : TagsRoot:=p;

     {ClassFolderEvents:begin
                        for iCat:=0 to High(p.childs) do
                         begin
                           pcCat:=p.childs[iCat];
                           if pcCat.ClassID=ClassCatEvent then
                            begin
                             idCat:=fListAECat.IndexOf(pcCat.Name);
                             if idCat<0 then
                              idCat:=fListAECat.Add(pcCat.Name);

                             // заполняем список событий для определенной категории
                             for iEv:=0 to High(pcCat.childs) do
                              begin
                               pcEv:=pcCat.childs[iEv];
                               ParentEvent:=THAEvent(result.AddChildObject(pcEv^.OID,pcEv^.ClassID,pcEv^.Name,pcEv^.Props));
                               ParentEvent.IDCat:=idCat;
                               for iSubEv:=0 to High(pcEv.childs) do
                                begin
                                 pcSubEv:=pcEv.childs[iSubEv];
                                 ParentEvent.AddChild(THAEvent.Create(pcSubEv^.OID,pcSubEv^.Name,pcSubEv^.Props));
                                end;
                              end;
                            end;


                         end;
                       end;

      }

    end;
   end;

 if TagsRoot<>nil then
  LoadTags(TagsRoot,result);
 //result.Init;
 if result.Init then
  begin
    fTemplates.Add(result);
    AddLog(1,'Загрузка шаблона "'+TemplateName+'"',s_ok,'OK');
  end
 else
  begin
   AddLog(1,'Загрузка шаблона "'+TemplateName+'"',s_false,'Ошибка загрузки шаблона');
   result.Free;
   result:=nil;
   Stop;
  end;

 {else
  begin
   result.Free;
   result:=nil;
   Stop;
  end; }

 except
  on E:Exception do
   begin
    AddLog(1,'Загрузка шаблона "'+TemplateName+'"',s_false,e.Message);
    if result<>nil then
     begin
      result.Free;
      result:=nil;
      Stop;
     end;
   end;
 end;

 finally
//  DisposeDataNode(n);
  DisposeDataNode(nroot);
 end;
end;

procedure THAOPCMan.PSClearAllBreakPoints;
var i:integer;
begin
 for i:=0 to fTemplates.Count-1 do
  THATemplate(fTemplates[i]).PSDebug.ClearBreakPoints;
end;

procedure THAOPCMan.SetHWNDDebug(const Value: THandle);
begin
  fHWNDDebug := Value;
 // fPSLineInfoON:=true;
end;

function THAOPCMan.SearchTemplate(OIDTemplate: integer): THATemplate;
var i:integer;
begin
 result:=nil;
 for i:=0 to fTemplates.Count-1 do
  if THATemplate(fTemplates[i]).OID=OIDTemplate then
   begin
    result:=fTemplates[i];
    break;
   end;

end;

function THAOPCMan.GenHandleCommandsInDrv: dword;
begin
 inc(fCommandsInDrvGen);
 if fCommandsInDrvGen=0 then
  inc(fCommandsInDrvGen);
 result:=fCommandsInDrvGen;
end;




function THAOPCMan.GetCountTemplates: integer;
begin
 result:=fTemplates.Count;
end;

function THAOPCMan.GetTemplate(index: integer): THATemplate;
begin
 result:=nil;
 if (index<0) or (index>fTemplates.Count-1) then exit;
 result:=fTemplates[index];
end;

procedure THAOPCMan.GetAENamesFromPath(ParentObj: THABaseObj; S: TStrings;
  BrowseFilterType: OPCAEBROWSETYPE; FilterCriteria: string);

function CheckFilters(AName:string):boolean;
begin
 result:=true;
 if FilterCriteria<>'' then
  result:=MatchesMask(AName,FilterCriteria);
end;


var i:integer;
    b:THABaseObj;

begin
 if ParentObj=nil then
  B:=fRoot
 else
  if ParentObj.ClassID=ClassController then
   exit
  else
   B:=ParentObj;

 for i:=0 to B.ChildCount-1 do
  case BrowseFilterType of
   OPC_AREA:if B.Childs[i].ClassID in [ClassFolder] then
              if CheckFilters(B.Childs[i].NameObj) then
                s.Add(B.Childs[i].NameObj);

   OPC_SOURCE:if B.Childs[i].ClassID in [ClassController] then
               if CheckFilters(B.Childs[i].NameObj) then
                 s.Add(B.Childs[i].NameObj);
  end;

end;

function THAOPCMan.GetAEObjectFromPath(Path: TStrings): THABaseObj;
var b:THABaseObj;
    i,ii,ci,j:integer;
    fl:boolean;

begin
  result:=nil;
  if Path.Count=0 then exit;
  ci:=Path.Count;
  B:=fRoot;
  for i:=0 to ci-1 do
   begin
    fl:=false;
    ii:=i;
    for j:=B.ChildCount-1 downto 0 do
     if CompareStr(B.Childs[j].NameObj,Path[i])=0 then
      begin
       fl:=true;
       result:=B.Childs[j];
       B:=result;
       break;
      end;
    if not fl then break;
    if result.ClassID=ClassController then break;
   end;

  if ii=ci-1 then  exit;

  if not fl then
   begin
    result:=nil;
    exit;
   end;
end;

function THAOPCMan.GetComServer(index: integer): TComObject;
begin
 result:=nil;
 if (index<0) or (index>=fComTable.Count) then exit;
 result:=fComTable[index];
end;



procedure THAOPCMan.SetCacheDebugRun;
begin
 fCacheDebugRun:=true;
end;

procedure THAOPCMan.SetCacheDebugMode(const Value: THACacheDebugMode);
begin
  fCacheDebugDelay:=0;
  fCacheDebugRun:=true;
  fCacheDebugMode := Value;
end;

procedure THAOPCMan.SetPSExecError(AController:TIGDevice);
var sError:string;
    mError:TMessage;
begin
 if fHWNDDebug<>0 then
  begin
   sError:=AController.Template.PSDebug.ExecErrorToString;
   mError.Msg:=HAMsgScript;
   mError.Result:=HATypeMsgExecError;
   mError.WParam:=AController.Template.PSDebug.ExecErrorRow;
   mError.LParam:=AController.Template.PSDebug.ExecErrorCol;
   SendMessage(fHWNDDebug,wm_PSExecError,integer(sError),integer(@mError));
  end;
end;

function THAOPCMan.GenUniICommand: dword;
begin
 inc(fGenUniICommand);
 if fGenUniICommand=0 then
  inc(fGenUniICommand);
 result:=fGenUniICommand;

end;

function THAOPCMan.GetControllers(index: integer): TIGDevice;
begin
 result:=nil;
 if (index<0) or (index>fControllers.Count-1) then exit;
 result:=fControllers[index];

end;

function THAOPCMan.GetCountControllers: integer;
begin
 result:=fControllers.Count;
end;

function THAOPCMan.GetPercentLoadingDrivers: byte;
begin
 result:=fDynCommandMan.PercentLoadingDrivers;
end;

{$IFDEF DEMOVERSION}
function THAOPCMan.GetDemoCountItems: integer;
begin
 result:=0;
 if fItem0<>nil then inc(result);
 if fItem1<>nil then inc(result);
 if fItem2<>nil then inc(result);
 if fItem3<>nil then inc(result);
 if fItem4<>nil then inc(result);
 if fItem5<>nil then inc(result);
 if fItem6<>nil then inc(result);
 if fItem7<>nil then inc(result);
 if fItem8<>nil then inc(result);
 if fItem9<>nil then inc(result);
 if fItem10<>nil then inc(result);
 if fItem11<>nil then inc(result);
 if fItem12<>nil then inc(result);
 if fItem13<>nil then inc(result);
 if fItem14<>nil then inc(result);
 if fItem15<>nil then inc(result);
 if fItem16<>nil then inc(result);
 if fItem17<>nil then inc(result);
 if fItem18<>nil then inc(result);
 if fItem19<>nil then inc(result);
 if fItem20<>nil then inc(result);
 if fItem21<>nil then inc(result);
 if fItem22<>nil then inc(result);
 if fItem23<>nil then inc(result);
end;

function THAOPCMan.GetDemoItem(index: integer): pointer;
begin
 result:=nil;
 if (index<0) or (index>=GetMaxDemoCountItems) then exit;
 case index of
  0: result:= fItem0;
  1: result:= fItem1;
  2: result:= fItem2;
  3: result:= fItem3;
  4: result:= fItem4;
  5: result:= fItem5;
  6: result:= fItem6;
  7: result:= fItem7;
  8: result:= fItem8;
  9: result:= fItem9;
  10: result:= fItem10;
  11: result:= fItem11;
  12: result:= fItem12;
  13: result:= fItem13;
  14: result:= fItem14;
  15: result:= fItem15;
  16: result:= fItem16;
  17: result:= fItem17;
  18: result:= fItem18;
  19: result:= fItem19;
  20: result:= fItem20;
  21: result:= fItem21;
  22: result:= fItem22;
  23: result:= fItem23;
 end;
end;

function THAOPCMan.AddDemoItem(p: pointer): integer;
begin
 result:=-1;
 if fItem0=nil  then begin fItem0:=p;  result:=0; exit; end;
 if fItem1=nil  then begin fItem1:=p;  result:=1; exit; end;
 if fItem2=nil  then begin fItem2:=p;  result:=2; exit; end;
 if fItem3=nil  then begin fItem3:=p;  result:=3; exit; end;
 if fItem4=nil  then begin fItem4:=p;  result:=4; exit; end;
 if fItem5=nil  then begin fItem5:=p;  result:=5; exit; end;
 if fItem6=nil  then begin fItem6:=p;  result:=6; exit; end;
 if fItem7=nil  then begin fItem7:=p;  result:=7; exit; end;
 if fItem8=nil  then begin fItem8:=p;  result:=8; exit; end;
 if fItem9=nil  then begin fItem9:=p;  result:=9; exit; end;
 if fItem10=nil then begin fItem10:=p; result:=10; exit; end;
 if fItem11=nil then begin fItem11:=p; result:=11; exit; end;
 if fItem12=nil then begin fItem12:=p; result:=12; exit; end;
 if fItem13=nil then begin fItem13:=p; result:=13; exit; end;
 if fItem14=nil then begin fItem14:=p; result:=14; exit; end;
 if fItem15=nil then begin fItem15:=p; result:=15; exit; end;
 if fItem16=nil then begin fItem16:=p; result:=16; exit; end;
 if fItem17=nil then begin fItem17:=p; result:=17; exit; end;
 if fItem18=nil then begin fItem18:=p; result:=18; exit; end;
 if fItem19=nil then begin fItem19:=p; result:=19; exit; end;
 if fItem20=nil then begin fItem20:=p; result:=20; exit; end;
 if fItem21=nil then begin fItem21:=p; result:=21; exit; end;
 if fItem22=nil then begin fItem22:=p; result:=22; exit; end;
 if fItem23=nil then begin fItem23:=p; result:=23; exit; end;
end;




procedure THAOPCMan.SetDemoItem(index: integer; p:pointer);
begin
 if (index<0) or (index>GetMaxDemoCountItems) then exit;
 case index of
  0: fItem0:=p;
  1: fItem1:=p;
  2: fItem2:=p;
  3: fItem3:=p;
  4: fItem4:=p;
  5: fItem5:=p;
  6: fItem6:=p;
  7: fItem7:=p;
  8: fItem8:=p;
  9: fItem9:=p;
  10: fItem10:=p;
  11: fItem11:=p;
  12: fItem12:=p;
  13: fItem13:=p;
  14: fItem14:=p;
  15: fItem15:=p;
  16: fItem16:=p;
  17: fItem17:=p;
  18: fItem18:=p;
  19: fItem19:=p;
  20: fItem20:=p;
  21: fItem21:=p;
  22: fItem22:=p;
  23: fItem23:=p;
 end;

end;


function THAOPCMan.GetMaxDemoCountItems: integer;
begin
 result:=24;
end;

{$ENDIF}


procedure THAOPCMan.LoadNewConfig;
begin
 inc(fCurrentNoConfig);
 if fCurrentNoConfig=0 then
  fCurrentNoConfig:=1;
 fNeedLoadNewConfig:=true;
 
end;

function THAOPCMan.CheckClientsForNewConfig: boolean;
var i:integer;
begin
 result:=true;
 for i:=0 to fComTable.Count-1 do
  if not THADAObj(fComTable[i]).NoConfigAsOPCMan then
   begin
    result:=false;
    break;
   end;
end;

procedure THAOPCMan.PSExecuteInitDevice(AInit: boolean);

function ExecInitScript(AScript:string):boolean;
var fi:integer;
    TProc:TIGInitDevice;
    sError:string;
   // Res:HResult;

begin

 result:=false;
 if fCurrP.Controller=nil then exit;
 result:=true;

 try
   fi:=fCurrP.Controller.FirstIndexCache;


   fCurrP.Controller.SwithIndexTemplate;

   if AScript<>'' then
    begin

     fCurrP.Controller.TagsList.Filtered:=false;
     TProc:=TIGInitDevice(fCurrP.Controller.Template.PSDebug.Exec.GetProcAsMethodN(AScript));
     if @TProc=nil then exit;
     try
       TProc(fCurrP.Controller);
       fCurrP.Controller.TagsList.Filtered:=false;
     except
      on E:Exception do
      begin
       sError:=e.Message;
       SetPSExecError(fCurrP.Controller);
       //if fCurrP.CurrentTags.Filtered then
       // fCurrP.CurrentTags.Filtered:=false;

       result:=false;
      end;
     end;
    end;



 finally
  fCurrP.Clear;
 end;
end;


var i:integer;
    res:boolean;
begin
 res:=false;
 for i:=0 to fControllers.Count-1 do
  if ((TIGDevice(fControllers[i]).Template.OnActivateDevice<>'') and AInit) or
     ((TIGDevice(fControllers[i]).Template.OnDeactivateDevice<>'') and (not AInit)) then
   begin
     fCurrP.Clear;
     fCurrp.Controller:=fControllers[i];
     if AInit then
      res:=ExecInitScript(TIGDevice(fControllers[i]).Template.OnActivateDevice) or res
     else
      res:=ExecInitScript(TIGDevice(fControllers[i]).Template.OnDeactivateDevice) or res;
   end;
 if res then
  CommitCache;
end;

procedure THAOPCMan.CheckTimers;

function ExecTimerScript(Timer:TIGTimer):boolean;
var fi:integer;
    TProc:TIGTimerProc;
    sError:string;
begin
 result:=false;
 if fCurrP.Controller=nil then exit;
 if Timer=nil then exit;
 result:=true;
 try
   fi:=fCurrP.Controller.FirstIndexCache;
   fCurrP.Controller.SwithIndexTemplate;
   if Timer.OnTimer<>'' then
    begin
     fCurrP.Controller.TagsList.Filtered:=false;
     TProc:=TIGTimerProc(fCurrP.Controller.Template.PSDebug.Exec.GetProcAsMethodN(Timer.OnTimer));
     if @TProc=nil then exit;
     try
       TProc(fCurrP.Controller, Timer);
       fCurrP.Controller.TagsList.Filtered:=false;
     except
      on E:Exception do
      begin
       sError:=e.Message;
       SetPSExecError(fCurrP.Controller);
       result:=false;
      end;
     end;
    end;
 finally
  fCurrP.Clear;
 end;
end;

var i,j,k:integer;
    tmp:THATemplate;
    res:boolean;
begin
 res:=false;
 for i:=0 to fTemplates.Count-1 do
  begin
   tmp:=THATemplate(fTemplates[i]);
   for j:=0 to tmp.CountTimers-1 do
    if tmp.Timers[j].CheckTimer then
     for k:=0 to fControllers.Count-1 do
      if TIGDevice(fControllers[k]).Template=tmp then
       begin
        fCurrP.Clear;
        fCurrp.Controller:=fControllers[k];
        res:=ExecTimerScript(tmp.Timers[j]) or res;
       end;

  end;
 if res then
  CommitCache;
end;


{$IFDEF HDAINTERFACE}
procedure THAOPCMan.GetHDANamesFromPath(ParentObj: THABaseObj; S: TStrings;
  dwBrowseType: OPCHDA_BROWSETYPE; AddedPath:string);
var i:integer;
    b:THABaseObj;
    ss:string;
begin
 if ParentObj=nil then
  B:=fRoot
 else
  if ParentObj.ClassID=ClassController then
   begin
    B:=TIGDevice(ParentObj).Template;
   end
  else
   B:=ParentObj;

 for i:=0 to B.ChildCount-1 do
  case dwBrowseType of

   OPCHDA_BRANCH:if B.Childs[i].ClassID in [ClassFolder,ClassController] then
                   s.Add(B.Childs[i].NameObj);

   OPCHDA_LEAF  :if B.Childs[i].ClassID in [ClassTagHDA] then
                   s.Add(B.Childs[i].NameObj);

   OPCHDA_FLAT,
   OPCHDA_ITEMS  :begin
                  if B.Childs[i].ClassID in [ClassTagHDA] then
                    begin
                      if AddedPath<>'' then
                       s.Add(AddedPath+BranchSep+B.Childs[i].NameObj)
                      else
                       s.Add(B.Childs[i].NameObj);
                    end
                  else
                   if B.Childs[i].ClassID in [ClassFolder,ClassController] then
                    begin
                     if AddedPath<>'' then
                      ss:=AddedPath+BranchSep+B.Childs[i].NameObj
                     else
                      ss:=B.Childs[i].NameObj;

                  GetHDANamesFromPath(B.Childs[i], s, dwBrowseType, ss);
                 end;

              end;

  end;

end;


function THAOPCMan.GetHDAObjectFromPath(Path: TStrings): THABaseObj;
var c:TIGDevice;
    b:THABaseObj;
    i,ii,ci,j:integer;
    fl:boolean;

begin
  result:=nil;
  if Path.Count=0 then exit;
  ci:=Path.Count;
  B:=fRoot;
  for i:=0 to ci-1 do
   begin
    fl:=false;
    ii:=i;
    for j:=B.ChildCount-1 downto 0 do
     if CompareStr(B.Childs[j].NameObj,Path[i])=0 then
      begin
       fl:=true;
       result:=B.Childs[j];
       B:=result;
       break;
      end;
    if not fl then break;
    if result.ClassID=ClassController then break;
   end;

  if not fl then
   begin
    result:=nil;
    exit;
   end;

  if result.ClassID=ClassController then
   begin
      c:=TIGDevice(result);
      inc(ii);
      B:=TIGDevice(result).Template;
      for i:=ii to ci-1 do
       begin
        fl:=false;
        for j:=B.ChildCount-1 downto 0 do
         if CompareStr(B.Childs[j].NameObj,Path[i])=0 then
          begin
           fl:=true;
           result:=B.Childs[j];
           B:=result;
           {if result.ClassID=ClassTagHDA then
            IDCache:=c.FirstIndexCache+TIGTag(result).IndexForCache
           else
            if result.ClassID=ClassProp then
             IDProp:=j;
            }
           break;
          end;
        if not fl then break;
       end;
   end;

  if not fl then
    result:=nil;


end;

{$ENDIF}

{ THACurrentParams }

procedure THACurrentParams.Clear;
begin
 Controller:=nil;
 Trans:=nil;
 Command:=nil;
 CurrentTags.Filtered:=false;
end;

constructor THACurrentParams.Create;
begin
 inherited;
 DriverData:=TIGDriverData.Create;
 CurrentTags:=TIGTags.Create(false);
 IGConverter:=TIGConverter.Create;
 TagsFilter:=THAFilter.Create;
 CurrentTags.FilterObj:=TagsFilter;
// Command:=THAPSCommand.Create(nil);
end;

destructor THACurrentParams.destroy;
begin
 // Command.Free;
  DriverData.Free;
  CurrentTags.Free;
  IGConverter.Free;
  TagsFilter.Free;
  inherited;
end;


initialization
 //OPCMan:=THAOPCMan.Create(true);
finalization
 case ComServer.StartMode of
   smRegServer: begin
                 RegisterTheServer(hats_DA, false);
                 {$IFDEF HDAINTERFACE}
                 RegisterTheServer(hats_HDA, false);
                 {$ENDIF}
                // RegisterTheServer(hats_AE);
                end;
   smUnregServer:begin
                  UnRegisterTheServer(hats_DA);
                  {$IFDEF HDAINTERFACE}
                  UnregisterTheServer(hats_HDA);
                  {$ENDIF}

                //  UnRegisterTheServer(hats_AE);
                 end;
 end;
// OPCMan.TerminateAndFree;
// OPCMan:=nil;
end.
