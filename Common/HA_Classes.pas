unit HA_Classes;

interface
 uses ha_types,windows,Classes,uPSCompiler,uPSRuntime,uPSDebugger,Dialogs, intf,
      SysUtils,opcda,opctypes,ActiveX,uPSComponent,opc_ae,HA_Filters;

 {$I IngaOPC.inc}

// const
//  TimeLifesTransaction=60000; // время жизни одной транзакции

 type

//  THATypeCommand=(tc_once,tc_periodic);

  THABaseObj=class(Tobject)
   private
    fOID:TOID;
    //fParentID:TOID;
    fClassID:TOID;
    fNameObj:string;
    fParent:THABaseObj;
    fChilds:array of THABaseObj;
    function GetChild(index: integer): THABaseObj;
    function GetChildCount: integer;
    function GetFullNameObj: string;
   public
    constructor Create(Parent:THABaseObj; OID,ClassID:TOID; NameObj:string);
    destructor destroy; override;
    property OID:TOID read fOID write fOID;
//    property ParentID:TOID read fParentID;
 //   property Parent:THABaseObj read fParent;
    property ClassID:TOID read fClassID;
    property NameObj:string read fNameObj;
    property FullNameObj:string read GetFullNameObj;
    procedure AddChild(Obj:THABaseObj);
    property ChildCount:integer read GetChildCount;
    property Childs[index:integer]:THABaseObj read GetChild;
    procedure ClearChilds;
  end;

  THATemplate=class;
  TIGDevice=class;
  TIGCommand=class;
  TIGProp=class;
  TIGTag=class;
  THAPSCommand=class;
  THAEvent=class;

  TIGPropLinks=array[0..65535] of TIGProp;
  PHAPropLinks=^TIGPropLinks;


  TIGTagList=array of TIGTag;


  TIGVQT=class(TObject)
   private
    fVQT      : OPCItemVQT;
    function GetValue: OLEVariant;
    function GetValueAsArray(index: integer): OLEVariant;
    function GetValueAsArrayCount: integer;
   public
    constructor Create(VQT:OPCItemVQT);
    destructor Destroy; override;
    property Value:OLEVariant read GetValue;
    function ValueIsArray:boolean;
    property ValueAsArray[index:integer]:OLEVariant read GetValueAsArray;
    property ValueAsArrayCount:integer read GetValueAsArrayCount;
  end;


  THAConvertRec=record
   case byte of
    0:  (asArrayByte:array [0..7] of byte);
    1 : (asvt_i2   : smallint );
    2 : (asvt_i4   : integer  );
    3 : (asvt_r4   : single   );
    4 : (asvt_r8   : double   );
    5 : (asvt_cy   : currency );
    6 : (asvt_date : TDateTime);
    7 : (asvt_bool : bool     );
    8 : (asvt_i1   : Shortint );
    9 : (asvt_ui1  : byte     );
    10: (asvt_ui2  : Word     );
    11: (asvt_ui4  : longword );
  end;


  TIGConverter=class(TObject)
   private
    fpValue:POleVariant;
    //fTag:TIGTag;
    fcr:THAConvertRec;
    fType:word;
    function GetBytes(index: byte): byte;
    procedure SetBytes(index: byte; const Value: byte);
    function GetBits(index: byte): boolean;
    procedure SetBits(index: byte; const Value: boolean);
    function GetTag: TIGTag;
    procedure SetTag(const Value: TIGTag);
   public
    procedure SetValue(var Value:Variant);


    property Bytes[index:byte]:byte read GetBytes write SetBytes;
    property Bits[index:byte]:boolean read GetBits write SetBits;
    property Tag:TIGTag read GetTag write SetTag;
   end;

 { TIGTagValue=class(TObject)
   private
    fValue:OleVariant;
    function GetTypeValue: word;
    function Getvt_bool: bool;
    function Getvt_cy: currency;
    function Getvt_date: TDateTime;
    function Getvt_i1: Shortint;
    function GetVt_i2: smallint;
    function Getvt_i4: integer;
    function Getvt_r4: single;
    function Getvt_r8: double;
    function Getvt_ui1: byte;
    function Getvt_ui2: Word;
    function Getvt_ui4: longword;


   public
    constructor Create(Value:OleVariant);
    property TypeValue:word read GetTypeValue;

    property asvt_i2   : smallint   read GetVt_i2;
    property asvt_i4   : integer    read Getvt_i4;
    property asvt_r4   : single     read Getvt_r4;
    property asvt_r8   : double     read Getvt_r8;
    property asvt_cy   : currency   read Getvt_cy;
    property asvt_date : TDateTime  read Getvt_date;
    property asvt_bool : bool       read Getvt_bool;
    property asvt_i1   : Shortint   read Getvt_i1;
    property asvt_ui1  : byte       read Getvt_ui1;
    property asvt_ui2  : Word       read Getvt_ui2;
    property asvt_ui4  : longword   read Getvt_ui4;
  end;  }
{   case byte of
    vt_i2  : (asvt_i2   : smallint);
    vt_i4  : (asvt_i4   : integer);
    vt_r4  : (asvt_r4   : single);
    vt_r8  : (asvt_r8   : double);
    vt_cy  : (asvt_cy   : currency);
    vt_date: (asvt_date : TDateTime);
    vt_bool: (asvt_bool : bool);
    vt_i1  : (asvt_i1   : Shortint);
    vt_ui1 : (asvt_ui1  : byte);
    vt_ui2 : (asvt_ui2  : Word);
    vt_ui4 : (asvt_ui4  : longword);
   end;
 }


  TIGTag=class(THABaseObj)
   private
    fTemplate   : THATemplate;
    fIndex      : integer;     // индекс в массиве fTags класса THATemplate;
    fTypeTag    : word;

    fReadable   : boolean;
    fWriteable  : boolean;
 //   fCalc       : boolean;
    fSaved      : boolean;

    fOnRead     : string;
    fOnWrite    : string;
  //  fOnCalc     : string;

    fVQT        : TIGVQT;



    function GetFileTime: TFileTime;

    function GetOldQuality: word;
    function GetNewQuality: word;
    procedure SetNewQuality(const Value:word);

    function GetNewValue: OleVariant;
    function GetOldValue: OleVariant;
    procedure SetNewValue(const Value: OleVariant);
    function GetProp(index: integer): TIGProp;
    function GetNewValueAsArray(index: integer): OleVariant;
    procedure SetNewValueAsArray(index: integer; const Value: OleVariant);
    function GetOldValueAsArray(index: integer): OleVariant;

    function GetPropByIndex(index: integer): TIGProp;
//    function GetResult: HResult;
//    procedure SetResult(const Value: HResult);
    function GetNewValueAsArrayCount: integer;
    function GetOldValueAsArrayCount: integer;
    function GetIndexForCache: integer;


   public
    TmpPropValues:array of Olevariant;
    procedure AddProp(OID:TOID; Props:string='');

    constructor Create(OID:TOID; NameObj:string; Props:string='');
    destructor Destroy; override;

    property OldValue:OleVariant read GetOldValue;    // use in Pascal Script
    property NewValue:OleVariant read GetNewValue write SetNewValue;

    property OldValueAsArray[index:integer]:OleVariant read GetOldValueAsArray;
    property OldValueAsArrayCount:integer read GetOldValueAsArrayCount;

    property NewValueAsArray[index:integer]:OleVariant read GetNewValueAsArray write SetNewValueAsArray;
    property NewValueAsArrayCount:integer read GetNewValueAsArrayCount;

    function ValueIsArray:boolean;

   // property Result:HResult read GetResult write SetResult;

    property FileTime:TFileTime read GetFileTime;
    property OldQuality:word read GetOldQuality;
    property NewQuality:word read GetNewQuality write SetNewQuality;

   // property OnLocalRead:string read fOnLocalRead;
    property OnRead     :string read fOnRead;
    property OnWrite    :string read fOnWrite;
//    property OnCalc     :string read fOnCalc;

    property IsReadable:boolean read fReadable;
    property IsWriteable:boolean read fWriteable;
    property Saved:boolean read fSaved;
//    property IsCalc:boolean read fCalc;


    property TypeTag:word read fTypeTag;

    property Prop[index:integer]:TIGProp read GetProp;
    function PropExists(ID:dword):boolean;
    function PropIndex(ID:dword):integer;
    property PropByIndex[index:integer]:TIGProp read GetPropByIndex;
    property IndexForCache:integer read GetIndexForCache;

    procedure SetVQT(VQT:TIGVQT);
    property VQT:TIGVQT read fVQT;
  end;

  {$IFDEF HDAINTERFACE}

  TIGTagHDA=class(THABaseObj)
  private
   fTypeTag    : word;
   fReadable   : boolean;
   fWriteable  : boolean;
   fhClient    : OPCHandle;
  public
   constructor Create(OID:TOID; NameObj:string; Props:string='');
   destructor Destroy; override;
   property IsReadable:boolean read fReadable;
   property IsWriteable:boolean read fWriteable;
   property TypeTag:word read fTypeTag;
   property hClient:OPCHandle read fhClient write fhClient;
  end;

  {$ENDIF}



{  THAList=class(TObject)
   private
    fList:TList;
    fIndexList:TList;
    fIndexIsUser:boolean;
    function GetCount: integer;
    function GetItem(index: integer): THABaseObj;
    procedure SetItem(index: integer; const Value: THABaseObj);
   public
    constructor Create;
    destructor destroy; override;
    procedure Add(Obj:THABaseObj);
    procedure AddIndex(Index:integer);
    procedure ClearIndexTable;
    procedure Clear;

    property Items[index:integer]:THABaseObj read GetItem write SetItem; default;
    property Count:integer read GetCount;
    property IndexIsUser:boolean read fIndexIsUser write fIndexIsUser;

  end;
  }

  TIGTags=class(TObject)
   private
    fList:TList;
    fFilterList:TList;
    fKillTagsOnDestroy:boolean;
    fFiltered: boolean;
    fFilter:string;

    fSortScript:string;
    fSorted:boolean;

    fFilterObj:THAFilter;
    function GetCount: integer;
    function GetTag(index: integer): TIGTag;
    procedure SetTag(index: integer; const Value: TIGTag);
    procedure SetFiltered(const Value: boolean);
    procedure SetFilter(const Value: string);
    procedure SetSorted(const Value: boolean);
    procedure SetSortScript(const Value: string);
    procedure QSort(SortList:TList; L, R: Integer);
   public
    constructor Create(KillTagsOnDestroy:boolean);
    destructor Destroy; override;

    property FilterObj:THAFilter read fFilterObj write fFilterObj;

    procedure Add(Tag:TIGTag);
    procedure Clear;

    property Tags[index:integer]:TIGTag read GetTag write SetTag; default;
    property Count:integer read GetCount;

    property Filtered:boolean read fFiltered write SetFiltered;
    property Filter:string read fFilter write SetFilter;

    property SortScript:string read fSortScript write SetSortScript;
    property Sorted:boolean read fSorted write SetSorted;
  end;

  TIGTimer=class(THABaseObj)
   private
    fEnabled:boolean;
    fInterval:dword;
    fOldTime:dword;
    fOnTimer:string;
    procedure SetEnabled(const Value: boolean);
   public
    constructor Create(OID:TOID; NameObj,Props:string);
    property Enabled:boolean read fEnabled write SetEnabled;
    property Interval:dword read fInterval write fInterval;
    property OnTimer:string read fOnTimer;
    function CheckTimer:boolean;
  end;



  THATemplate=class(THABaseObj)
   private
    fOPCMan:Tobject;
    fCurrentController:TIGDevice;
    fTags:      TIGTags;
   // fCountCalcTags:integer;
    fCommands:  TList;
    fProps:     TList;
    fEvents:    TList;
    fTimers:    TList;

    {$IFDEF HDAINTERFACE}
    fTagsHDA :  TList;
    {$ENDIF}

    fCompileID:integer;
    fScript:string;
    fScriptObjList:TList;
    fOnActivateDevice: string;
    fOnDeactivateDevice: string;

    function GetCountTags: integer;
    function GetTag(index: integer): TIGTag;
    procedure SetTag(index: integer; const Value: TIGTag);
    procedure ClearObjs;
    function GetCommand(index: integer): TIGCommand;
    function GetCountCommands: integer;

   // function NormalizePath(APath:string):string;
    function SearchObj(st:TStrings):THABaseObj;

    function ScriptToPScript(ObjList:TList):string;
    procedure PSCompImport(Sender: TObject; x: TPSPascalCompiler);
    procedure PSCompile(Sender: TPSScript);
    procedure PSExecute(sender:TPSScript);
    procedure PSExecImport(Sender: TObject; se: TPSExec; x: TPSRuntimeClassImporter);
    function GetCountEvents: integer;
    function GetEvent(index: integer): THAEvent;
    function GetCountTimers: integer;
    function GetTimer(index: integer): TIGTimer;




   public
    PSDebug:TPSScriptDebugger;
    constructor Create(NameTemplate,Props:string; OID:TOID; Script:string; OPCMan:Tobject);
    destructor destroy; override;

    function SearchTag(OID:TOID):TIGTag;
    function SearchCommand(OID:TOID):TIGCommand;
    function SearchProp(OID:TOID):TIGProp;

    function Init:boolean;

    function AddChildObject(OID,ClassID:TOID; NameObj:string; Props:string=''):THABaseObj;


    property CurrentConroller:TIGDevice read fCurrentController write fCurrentController;

//    property CountCalcTags:integer read fCountCalcTags;
    property CountTags:integer read GetCountTags;
    property Tags[index:integer]:TIGTag read GetTag write SetTag;

    property CountCommands:integer read GetCountCommands;
    property Command[index:integer]:TIGCommand read GetCommand;

    property CountEvents:integer read GetCountEvents;
    property Event[index:integer]:THAEvent read GetEvent;

    property CountTimers:integer read GetCountTimers;
    property Timers[index:integer]:TIGTimer read GetTimer;

    property Script:string read fScript;
    property CompileID:integer read fCompileID;

    property OnActivateDevice:string read fOnActivateDevice;
    property OnDeactivateDevice:string read fOnDeactivateDevice;

  end;

  TIGDevice=class(THABaseObj)
   private
    fHandle:word;
    fFirstIndexCache:integer;
    fAddress:string;
    fHashDRV:cardinal;
    fParam:dword;
    fTemplate:THATemplate;
    fActive:boolean;


    function GetTagsList: TIGTags;
   public
    constructor Create(Parent:THABaseObj; OID:TOID; NameObj:string; Props:string='');

    property Template:THATemplate read fTemplate write fTemplate;
   // property Tags[index:integer]:TIGTag read GetTag write SetTag;
  //  property CountTags:integer read GetCountTags;

    procedure SwithIndexTemplate;
    property FirstIndexCache:integer read fFirstIndexCache write fFirstIndexCache;
    property TagsList:TIGTags read GetTagsList;
   // property CountCalcTags:integer read GetCountCalcTags;
    property Handle:word read fHandle write fHandle;
    property Address:string read fAddress write fAddress;
    property Param:dword read fParam write fParam;
    property HashDrv:cardinal read fHashDrv;
    property Active:boolean read fActive;

  end;




 TIGCommand=class(THABaseObj)
  private
   fHandle:word;
   fTemplate:THATemplate;

   fNoCommand:string;
   fCountW:integer;
   //fCountR:integer;
   fParam:dword;
   fOnBeforeWrite,
   fOnAfterRead:string;

   fData:array of byte;
   fPriority:word;
   fSPriority:word;



   function GetData(index: integer): byte;
   procedure SetCount(const Value: integer);
   procedure SetData(index: integer; const Value: byte);
   function GetCount: integer;

  public
   constructor Create(OID:TOID; NameObj:string; Props:string='');
   destructor Destroy; override;

   property NoCommand:string read fNoCommand;
   property Param:dword read fParam;
   property CountW:integer read fCountW;
 //  property CountR:integer read fCountR;
   property OnBeforeWrite:string read fOnBeforeWrite;
   property OnAfterRead:string read fOnAfterRead;

   property Data[index:integer]:byte read GetData write SetData; default;
   property Count:integer read GetCount write SetCount;

   property Priority:word read fPriority write fPriority;
   property SPriority:word read fSPriority;
//   procedure RunOnce;
//   procedure RunPeriodic;

   procedure Run;

   property Handle:word read fHandle;

 end;






 TIGProp=class(THABaseObj)
   private
    fTemplate: THATemplate;
    fPropID  : DWord;
    fTypeProp: word;
    fValue   : variant;
    fUniqueValue:boolean;
    function GetValueAsArray(index: integer): Variant;
    function GetValueAsArrayCount: integer;

   public
    constructor Create(OID:TOID; NameObj:string; Props:string='');
    property Value:variant read fValue;
    property TypeProp:word read fTypeProp;
    property PropID:DWord read fPropID;
    function ValueIsArray:boolean;
    property ValueAsArray[index:integer]:Variant read GetValueAsArray;
    property ValueAsArrayCount:integer read GetValueAsArrayCount;

 end;



 THAPSCommandState=(cs_Wait,cs_BeforeWriting,cs_AfterWriting,cs_Commit);
 // cs_Wait - команда не в DynList;
 // cs_BeforeWriting - команда в DynList но еще не подана на устройство;
 // cs_AfterWriting - команда подана на устройство, но на нее еще не пришел ответ;
 // cs_Commit - на команду пришел ответ и она удалена из DynList;

 THAPSCommand=class(THABaseObj)
  private
   fParentCommand:TIGCommand;
   fData:array of byte;
   fResult:dword;
   fController:TIGDevice;
   fIDTrans:dword;
   fhServerGroup:dword; // необходима для идентификации группы, от которой была послана эта команда
   fState:THAPSCommandState;

   fPriority:word;

   fLoadTime:dword;     // время загрузки команды в милисекундах
   fUpdateRate:dword;   // время обновленя группы, от имени которой была создана команда в милисекундах
   fRequestTime:dword;  // время необходимое для подачи команды (макс. время "пребывания" команды в DynList

   //fInOPCMan:boolean;
   fInUse:boolean;
   fDeleted:boolean;

   fCurrentNoConfig:dword;

   function GetData(index: integer): byte;
   procedure SetData(index: integer; const Value: byte);
   function GetCount: integer;
   procedure SetCount(const Value: integer);
  public
   constructor Create(ParentCommand:TIGCommand);
   destructor destroy; override;
   property ParentCommand:TIGCommand read fParentCommand write fParentCommand;
   property hServerGroup:dword read fhServerGroup write fhServerGroup;
   property IDTrans:dword read fIDTrans write fIDTrans;
   property Controller:TIGDevice read fController write fController;
   property Data[index:integer]:byte read GetData write SetData; default;
   property Count:integer read GetCount write SetCount;
   property Result:dword read fResult write fResult;
   property State:THAPSCommandState read fState write fState;

   property Priority:word read fPriority write fPriority;

   property LoadTime:dword read fLoadTime write fLoadTime;
   property UpdateRate:dword read fUpdateRate write fUpdateRate;
   property RequestTime:dword read fRequestTime write fRequestTime;
 //  property InDevice:boolean read fInDevice write fInDevice;
   property InUse:boolean read fInUse write fInUse;
   property Deleted:boolean read fDeleted write fDeleted;

   property CurrentNoConfig:dword read fCurrentNoConfig;
 end;

 TIGDriverData=class(TObject)
  private
    fResult: dword;
    fData:array of byte;
    function GetCount: integer;
    function GetData(index: integer): byte;
    procedure SetCount(const Value: integer);
    procedure SetData(index: integer; const Value: byte);
  public
   property Data[index:integer]:byte read GetData write SetData; default;
   property Count:integer read GetCount write SetCount;
   property Result:dword read fResult write fResult;
 end;

  THAOPCItem=class;

  THATransactionKind=(tk_AsyncRead,tk_SyncRead,tk_AsyncWrite,tk_SyncWrite,tk_AsyncRefresh,tk_Group);
  THATransactionState=(trs_Wait,trs_Processed,trs_Commit,trs_Roolback,trs_Cancel,trs_Clear);
  // trs_Wait - транзакция не обработана, при попадании такой транзакции в TrList, происходит выполнение скриптов на формирование нужных команд;
  // trs_Processed - транзакция обработана скриптами и сформированы команды на запись в устройство;
  // trs_Commit,trs_Cancel - транзакция отработана (все команды в транзакции имеют статус cs_Commit);
  // trs_Rollback - для tk_Sync... означает что превышен лимит времени для выполнения транзакции (см. настройки параметр fIOPCSyncIO_TimeLifeTransaction)

  PHATransactionParam2=^THATransactionParam2;
  THATransactionParam2=record
   VQT:TIGVQT;
   OPCItem:THAOPCItem;
   Result:HResult;
  end;

  THATransaction2=class(TObject)
   private
    fGroup:pointer;
    fTimeToLifes:cardinal;
    fTimeCreate:cardinal;
    fForDevice:boolean;
    fItems:TList;
    fCommands:TList;
    fIDTrans:dword;
    fClientIDTrans:dword;
    fIDCancel:dword;
    fTrKind:THATransactionKind;
    fTrState:THATransactionState;
    fInUse:boolean;
    fCurrentNoConfig:dword;
    function GetCommand(index: integer): THAPSCommand;
    function GetCountCommands: integer;
    function GetCountItems: integer;
    function GetItem(index: integer): THAOPCItem;
    function GetInUse: boolean;
    function GetVQT(index: integer): TIGVQT;
    procedure SetTrState(const Value: THATransactionState);
    function GetCountCommitCommands: integer;


   public
    constructor Create(Group:pointer; TrKind:THATransactionKind; ClientIDTrans,IdTrans,IdCancel:dword; ForDevice:boolean; TimeToLifes:cardinal);
    destructor destroy; override;

    procedure Read;
    procedure Write;
    procedure Cancel;

    procedure ClearTr(ClearOnlyCommands:boolean);

    property IDTrans:dword read fIdTrans write fIDTrans;
    property IDCancel:dword read fIdCancel;
    property TrKind:THATransactionKind read fTrKind;
    property TrState:THATransactionState read fTrState write SetTrState;

    procedure AddItem(Item:THAOPCItem; ItemVQT:POPCITEMVQT);
    procedure AddCommand(Command:THAPSCommand);
    procedure Sort;
    procedure UpdateState;
    property Items[index:integer]:THAOPCItem read GetItem;
    property CountItems:integer read GetCountItems;
    property Commands[index:integer]:THAPSCommand read GetCommand;
    property CountCommands:integer read GetCountCommands;
    property VQT[index:integer]:TIGVQT read GetVQT;

    property CountCommitCommands:integer read GetCountCommitCommands;

    procedure SetResultForItems(IDCache:integer; Result:HResult);

    function GetResultForItems(IDCache:integer):HResult;

    function SetCancel:boolean;

    property InUse:boolean read GetInUse write fInUse;
    property ForDevice:boolean read fForDevice;
    property CurrentNoConfig:dword read fCurrentNoConfig;
   end;




 THAOPCItem=class(TObject)
   private
    fGroup:TObject;
    fIdCache:integer;
    fIdProp: integer;
    fClientHandle:OPCHANDLE;
    fServerHandle:OPCHANDLE;
    fActive:bool;
    fCountRef:integer;
    fRequestedDatatype:TVarType;

    fOldQuality       : word;
    fOldValue         : OleVariant;
    fOldTimeStamp     : TFileTime;
    fOldResult        : HResult;

    fCurrentNoConfig  : dword;
    fDeleted: boolean;

    function GetQuality:word;
    function GetAccessRight:dword;
    function GetCanonicalDataType:TVarType;
    function GetValue:OleVariant;
    function GetTimeStamp:TFileTime;
    function GetItemIsTrans: boolean;
    function GetFullName: string;
    function GetRequestedDatatype: TVarType;
    function GetProp(IDProp: dword): TIGProp;
   public
    constructor Create(Group:TObject; IDCache,IDProp:integer);
    property FullName:string read GetFullName;

    property AccessRight:dword read GetAccessRight;
    property CanonicalDataType:TVarType read GetCanonicalDataType;
    property RequestedDatatype:TVarType read GetRequestedDatatype write fRequestedDatatype;
    property IDCache:integer read fIDCache;
    property IDProp:integer read fIDProp;
    property ClientHandle:OPCHANDLE read fClientHandle write fClientHandle;
    property ServerHandle:OPCHANDLE read fServerHandle write fServerHandle;
    property Active:bool read fActive write fActive;

    property ItemIsTrans:boolean read GetItemIsTrans;
    procedure AddRef;
    procedure ReleaseRef;
    property Deleted:boolean read fDeleted write fDeleted;


    property Quality:word read GetQuality;
 //   property Value:oleVariant read GetValue;
    function GetValue2(var Dest:OleVariant):HResult;
    property TimeStamp:TFileTime read GetTimeStamp;

    property OldQuality:word read fOldQuality write fOldQuality;
    property OldValue:oleVariant read fOldValue write fOldValue;
    property OldTimeStamp:TFileTime read fOldTimeStamp write fOldTimeStamp;
    property OldResult:HResult read fOldResult write fOldResult;

    property CurrentNoConfig:dword read fCurrentNoConfig;

    property Prop[IDProp:dword]:TIGProp read GetProp;
  end;


 TIGTagProcR=procedure(Device:TIGDevice; Tags:TIGTags; FromGroup:boolean) of object;
 TIGTagProcW=procedure(Device:TIGDevice; Tags:TIGTags) of object;

 TIGCommandProcBW=procedure (Device:TIGDevice; Command:TIGCommand; var Cancel:boolean) of object;
 TIGCommandProcAR=procedure (Device:TIGDevice; Command:TIGCommand; DriverData:TIGDriverData) of object;
 TIGInitDevice=procedure (Device:TIGDevice) of object;
 TIGTimerProc=procedure (Device:TIGDevice; Timer:TIGTimer) of object;



 THAEvent=class(THABaseObj)
  private
   fTemplate: THATemplate;
   fIDCat:dword;
   fDescription:string;
   fSeverity:word;
   fOnCheckDefinition:string;
   function GetTypeEvent: dword;
  public
   constructor Create(OID:TOID; NameObj:string; Props:string='');
   destructor Destroy; override;
   property IDCat:dword read fIDCat write fIDCat;
   property TypeEvent:dword read GetTypeEvent;
 end;









 procedure SIRegisterHAOBJ(CL: TPSPascalCompiler);
 procedure RIRegisterHAOBJ(cl: TPSRuntimeClassImporter; se: TPSExec);



implementation
  uses ha_opcman, variants,ha_dagroup,ha_utils,ha_log,regexpr,
  uPSR_dateutils,
  uPSC_dateutils,
  HA_ErrorCodes,
  opcerror,
  uPSUtils,
  HA_PSFunctions;

{$I IngaOPC.inc}

{ THABaseObj }

procedure THABaseObj.AddChild(Obj: THABaseObj);
begin
 SetLength(fChilds,length(fChilds)+1);
 Obj.fParent:=self;
 fChilds[High(fChilds)]:=Obj;
end;

procedure THABaseObj.ClearChilds;
var i:integer;
begin
 if fChilds<>nil then
  begin
   for i:=0 to High(fChilds) do
   // try
    if fChilds[i].ClassID=ClassFolder then
     begin
      fChilds[i].ClearChilds;
      fChilds[i].Free;
     end;
   // except
   // end;
   SetLength(fChilds,0);
   fChilds:=nil;
  end;

end;

constructor THABaseObj.Create(Parent:THABaseObj; OID, ClassID: TOID; NameObj:string);
begin
 inherited Create;
 fOID:=OID;
 fParent:=Parent;
 fClassID:=ClassID;
 fNameObj:=NameObj;
 fChilds:=nil;
end;

destructor THABaseObj.destroy;
begin
 ClearChilds;
 inherited;
end;

function THABaseObj.GetChild(index: integer): THABaseObj;
begin
 result:=nil;
 if (index<0) or (index>=GetChildCount) then exit;
 result:=fChilds[index];
end;

function THABaseObj.GetChildCount: integer;
begin
 result:=length(fChilds);
end;

function THABaseObj.GetFullNameObj: string;
var B:THABaseObj;
begin
 result:='';
 B:=self;
 while B<>nil do
  begin
   if B.ClassID>=ClassFolder then
    if result='' then
     result:=B.fNameObj
    else
     result:=B.fNameObj+BranchSep+result;
    B:=B.fParent;
  end;
end;

{ THATemplate }



function THATemplate.AddChildObject(OID,ClassID: TOID; NameObj,
  Props: string): THABaseObj;
begin
 result:=nil;
 case ClassID of
  ClassProp:begin
             result:=TIGProp.Create(OID,NameObj,Props);
             TIGProp(result).fTemplate:=self;
             fProps.Add(result);
            end;
  ClassTag :begin
             result:=TIGTag.Create(OID,NameObj,Props);
             TIGTag(result).fTemplate:=self;
             fTags.Add(TIGTag(result));
            end;
  ClassCommand:begin
                result:=TIGCommand.Create(OID,NameObj,Props);
                TIGCommand(result).fTemplate:=self;
                TIGCommand(result).fHandle:=fCommands.Add(result)+1;
               end;

  ClassEvent :begin
               result:=THAEvent.Create(OID,NameObj,Props);
               THAEvent(result).fTemplate:=self;
               fEvents.Add(result);
              end;
  ClassTimer :begin
               result:=TIGTimer.Create(OID,NameObj,Props);
               fTimers.Add(result);
              end;
  {$IFDEF HDAINTERFACE}
  ClassTagHDA:begin
               result:=TIGTagHDA.Create(OID,NameObj,Props);
               fTagsHDA.Add(result);
              end;
  {$ENDIF}
 end;
end;





procedure THATemplate.ClearObjs;
var i:integer;
begin

 fTags.Clear;

 for i:=0 to fTagsHDA.Count-1 do
  TIGTagHDA(fTagsHDA[i]).Free;
 fTagsHDA.Clear; 

 for i:=0 to fCommands.Count-1 do
  TIGCommand(fCommands[i]).Free;
 fCommands.Clear;


 for i:=0 to fProps.Count-1 do
  TIGProp(fProps[i]).Free;
 fProps.Clear;

 for i:=0 to fEvents.Count-1 do
  THAEvent(fEvents[i]).Free;
 fEvents.Clear;

 for i:=0 to fTimers.Count-1 do
  TIGTimer(fTimers[i]).Free;
 fTimers.Clear; 
end;

constructor THATemplate.Create(NameTemplate,Props:string; OID: TOID; Script:string; OPCMan:Tobject);
var p:PDataItem2;
    Proxy:THATemplate_Proxy;
begin
 inherited Create(nil,OID,ClassTemplate,NameTemplate);
 fTags:=TIGTags.Create(true);
 fCommands:=TList.Create;
 fProps:=TList.Create;
 fEvents:=TList.Create;
 fTimers:=TList.Create;

 {$IFDEF HDAINTERFACE}
 fTagsHDA:=TList.Create;
 {$ENDIF}

 fCompileID:=-1;


 fOPCMan:=OPCMan;
 PSDebug:=TPSScriptDebugger.Create(nil);
 PSDebug.OnCompile:=PSCompile;
 PSDebug.OnCompImport:=PSCompImport;
 PSDebug.OnExecImport:=PSExecImport;
 PSDebug.OnExecute:=PSExecute;
 PSDebug.Tag:=OID;
 fScript:=Script;

 Proxy:=THATemplate_Proxy.Create;
 new(p);
  try
    fillchar(p^,sizeof(TDataItem2),0);
    p^.Name:=NameTemplate;
    p^.Props:=Props;
    Proxy.AddData(p);
    fCompileID:=Proxy.CompileID;
    fOnActivateDevice:=Proxy.OnActivateDevice;
    fOnDeactivateDevice:=Proxy.OnDeactivateDevice;
  finally
   dispose(p);
   Proxy.Free;
  end;



end;

destructor THATemplate.destroy;
begin
  ClearObjs;
  fTags.Free;
  fCommands.Free;
  fProps.Free;
  fEvents.Free;
  fTimers.Free;
  PSDebug.Free;

  {$IFDEF HDAINTERFACE}
  fTagsHDA.Free;
  {$ENDIF}
  inherited;
end;


function THATemplate.GetCommand(index: integer): TIGCommand;
begin
 result:=nil;
 if index>=fCommands.Count then exit;
 result:=fCommands[index];
end;

function THATemplate.GetCountCommands: integer;
begin
 result:=fCommands.Count;
end;

function THATemplate.GetCountTags: integer;
begin
 result:=fTags.Count;
end;

function THATemplate.GetTag(index: integer): TIGTag;
begin
 result:=fTags[index]; //TIGTag(fTags[index]);
end;

function THATemplate.Init:boolean;
var i:integer;
    B:THABaseObj;
    Reg:TRegExpr;
    s:string;


function ScriptParamToPascalParam(param:string):string;
var s,ps:string;

begin
 result:=Param;
 if Reg.Exec(Param) then
	repeat
    s:=Reg.Match[0];
    ps:='HAPROC'+sysutils.inttostr(MakeHashId(s)); //format(FormatPScriptProc,[MakeHashId(s)]);
    result:=stringreplace(result,s,ps,[rfReplaceAll, rfIgnoreCase]);
  until not Reg.ExecNext;
  result:=trim(result);
end;


begin
 result:=true;
 fScriptObjList:=TList.Create;
 try
  PSDebug.Script.Text:=ScriptToPScript(fScriptObjList);
  if PSDebug.Compile then
   begin
    for i:=0 to fScriptObjList.Count-1 do
     begin
      B:=fScriptObjList[i];
      PSDebug.SetVarToInstance(format(FormatPScript,[B.ClassID,B.OID]),B);
     end;
     PSDebug.SetVarToInstance('IGCONVERTER',OPCMan.CurrP.IGConverter);
   end
  else
   begin
    fScript:='';
    s:='';
    for i:=0 to PSDebug.CompilerMessageCount-1 do
     s:=s+' '+PSDebug.CompilerMessages[i].MessageToString;
    AddLog(1,'Компиляция шаблона "'+fNameObj+'"',s_false,s); 
    result:=false;
   end;

 finally
  fScriptObjList.Free;
 end;

 if not result then exit;
 
// fTags.SortTags;
// fCountCalcTags:=0;
{ for i:=0 to fTags.Count-1 do
  begin
   fTags[i].fIndex:=i;
 //  if fTags[i].fCalc then
 //   inc(fCountCalcTags);
  end;
 }

 Reg:=TRegExpr.Create;
 try
  Reg.Expression:=RegScriptProc;
  for i:=0 to fTags.Count-1 do
   begin
    fTags[i].fIndex:=i;
   // if fTags[i].fCalc then
   //  inc(fCountCalcTags);

    fTags[i].fOnRead:=ScriptParamToPascalParam(fTags[i].fOnRead);
    fTags[i].fOnWrite:=ScriptParamToPascalParam(fTags[i].fOnWrite);
   end;

  for i:=0 to fCommands.Count-1 do
   begin
    TIGCommand(fcommands[i]).fOnBeforeWrite:=ScriptParamToPascalParam(TIGCommand(fcommands[i]).fOnBeforeWrite);
    TIGCommand(fcommands[i]).fOnAfterRead:=ScriptParamToPascalParam(TIGCommand(fcommands[i]).fOnAfterRead);
   end;

  for i:=0 to fTimers.Count-1 do
   TIGTimer(fTimers[i]).fOnTimer:=ScriptParamToPascalParam(TIGTimer(fTimers[i]).fOnTimer);


  fOnActivateDevice:=ScriptParamToPascalParam(fOnActivateDevice);
  fOnDeactivateDevice:=ScriptParamToPascalParam(fOnDeactivateDevice);


 finally
  Reg.Free;
 end;


end;

procedure THATemplate.PSCompile(Sender: TPSScript);
var i:integer;
    B:THABaseObj;
    s:string;
begin
  for i:=0 to fScriptObjList.Count-1 do
   begin
    s:='';
    B:=fScriptObjList[i];
    case B.ClassID of
     ClassTag     : S:='TIGTag';
     ClassCommand : S:='TIGCommand';
    // ClassLinkProp: S:='TIGProp';
    end;
    if s<>'' then
     Sender.AddRegisteredVariable(format(FormatPScript,[B.ClassID,B.OID]),s);
   end;
 // Sender.AddRegisteredVariable('Device','TIGDevice');
end;

procedure THATemplate.PSCompImport(Sender: TObject; x: TPSPascalCompiler);
begin
 SIRegisterHAOBJ(x);
end;

procedure THATemplate.PSExecImport(Sender: TObject; se: TPSExec;
  x: TPSRuntimeClassImporter);
begin
 RIRegisterHAOBJ(x,se);
end;

procedure THATemplate.PSExecute(sender: TPSScript);
begin
// sender.AddRegisteredVariable('asd','integer');
end;

{function THATemplate.NormalizePath(APath:string):string;
begin
 result:=APath;
 delete(result,1,2);
 delete(result,length(result)-1,2);
end;
 }

function THATemplate.SearchObj(st:TStrings):THABaseObj;
var i,j:integer;
    B:THABaseObj;
    fl,flEnd:boolean;
begin
 result:=nil;
 B:=self;
 flEnd:=false;
 for i:=0 to st.Count-1 do
  begin
   fl:=false;
   for j:=0 to B.ChildCount-1 do
    if CompareStr(st[i],b.Childs[j].NameObj)=0 then
     begin
      B:=B.Childs[j];
      fl:=true;
      break;
     end;
    if not fl then break;
    if fl and (i=st.Count-1) then
     flEnd:=true;
  end;

 if flEnd then
  begin
   result:=B;
   exit;
  end;

 for i:=0 to st.Count-1 do
  begin
   fl:=false;
   for j:=0 to fCommands.Count-1 do
    if CompareStr(st[i],THABaseObj(fCommands[j]).NameObj)=0 then
     begin
      B:=THABaseObj(fCommands[j]);
      fl:=true;
      break;
     end;
    if not fl then break;
    if fl and (i=st.Count-1) then
     flEnd:=true;
  end;

 if flEnd then
  result:=B;


end;



function THATemplate.ScriptToPScript(ObjList:TList): string;
var Reg:TRegExpr;
    s,ps:string;
    st:TStringList;
    B:THABaseObj;
    i:integer;
begin
 result:=DeleteCommentFromScript(fScript);
 Reg:=TRegExpr.Create;
 st:=TStringList.Create;
 try

  // находим все объекты
  Reg.Expression:=RegScript;
  if Reg.Exec(fScript) then
	 repeat
    s:=Reg.Match[0];
    st.Clear;
    ParsePath(NormalizePath(s),st);
    B:=SearchObj(st);
    if B=nil then continue;
    if ObjList.IndexOf(b)<0 then
     ObjList.Add(b);
    ps:=format(FormatPScript,[B.ClassID,B.OID]);
    result:=stringreplace(result,s,ps,[rfReplaceAll, rfIgnoreCase]);
   until not Reg.ExecNext;

  // находим все процедуры
  Reg.Expression:=RegScriptProc;
  st.Text:=result;
  for i:=0 to st.Count-1 do
   begin
    if Reg.Exec(st[i]) then
	   repeat
      s:=Reg.Match[0];
      ps:='HAPROC'+sysutils.inttostr(MakeHashId(s));
      st[i]:=stringreplace(st[i],s,ps,[rfReplaceAll, rfIgnoreCase]);
     until not Reg.ExecNext;
   end;
  result:=st.Text;

 finally
  Reg.Free;
  st.Free;
 end;

end;

function THATemplate.SearchCommand(OID: TOID): TIGCommand;
var i:integer;
begin
 result:=nil;
 for i:=0 to fCommands.Count-1 do
  if TIGCommand(fCommands[i]).fOID=OID then
   begin
    result:=fCommands[i];
    break;
   end;


end;

function THATemplate.SearchProp(OID: TOID): TIGProp;
var i:integer;
begin
 result:=nil;
 for i:=0 to fProps.Count-1 do
  if TIGProp(fProps[i]).fOID=OID then
   begin
    result:=fProps[i];
    break;
   end;
end;


function THATemplate.SearchTag(OID: TOID): TIGTag;
var i:integer;
begin
 result:=nil;
 for i:=0 to fTags.Count-1 do
  if fTags[i].fOID=OID then
   begin
    result:=fTags[i];
    break;
   end;

end;

procedure THATemplate.SetTag(index: integer; const Value: TIGTag);
begin
 fTags[index]:=value;
end;






function THATemplate.GetCountEvents: integer;
begin
 result:=fEvents.Count;
end;

function THATemplate.GetEvent(index: integer): THAEvent;
begin
 result:=nil;
 if index>=fEvents.Count then exit;
 result:=fEvents[index];
end;

function THATemplate.GetCountTimers: integer;
begin
 result:=fTimers.Count;
end;

function THATemplate.GetTimer(index: integer): TIGTimer;
begin
 result:=nil;
 if index>=fTimers.Count then exit;
 result:=fTimers[index];
end;

{ TIGTag }

constructor TIGTag.Create(OID: TOID; NameObj,
  Props: string);
var p:PDataItem2;
    Proxy:TIGTag_Proxy;
begin
  inherited Create(nil,oid,ClassTag,NameObj);
  Proxy:=TIGTag_Proxy.Create;
  new(p);
  try
    fillchar(p^,sizeof(TDataItem2),0);
    p^.Name:=NameObj;
    p^.Props:=Props;
    Proxy.AddData(p);
    fReadable:=Proxy.Readable;
    fWriteable:=Proxy.Writeable;
    fSaved:=Proxy.Saved;
    fTypeTag:=Proxy.DataType;
    fOnRead:=Proxy.OnRead;
    fOnWrite:=Proxy.OnWrite;
  finally
   dispose(p);
   Proxy.Free;
  end;

{ st:=TStringList.Create;
  try
   st.Text:=Props;
   for i:=0 to st.Count-1 do
    begin
     if CompareText('Readable',st.Names[i])=0 then
      begin
       v:=st.ValueFromIndex[i];
       fReadable:=v;
      end
     else
      if CompareText('Writeable',st.Names[i])=0 then
       begin
        v:=st.ValueFromIndex[i];
        fWriteable:=v;
       end
      else
       if CompareText('TypeTag',st.Names[i])=0 then
         fTypeTag:=StrToVarType(st.ValueFromIndex[i])
       else
         if CompareText('OnRead',st.Names[i])=0 then
            fOnRead:=st.ValueFromIndex[i]
          else
           if CompareText('OnWrite',st.Names[i])=0 then
            fOnWrite:=st.ValueFromIndex[i];






    end;
  finally
   st.Free;
  end;
 }
end;


destructor TIGTag.Destroy;
begin
  SetLength(TmpPropValues,0);
  inherited;
end;

function TIGTag.GetFileTime: TFileTime;
begin
 result:=THAOPCMan(fTemplate.fOPCMan).OldFileTime[fTemplate.CurrentConroller.FirstIndexCache+fIndex];
end;

function TIGTag.GetNewValue: OleVariant;
begin
 result:=THAOPCMan(fTemplate.fOPCMan).NewValue[fTemplate.CurrentConroller.FirstIndexCache+fIndex];
end;

function TIGTag.GetOldValue: OleVariant;
begin
 result:=THAOPCMan(fTemplate.fOPCMan).OldValue[fTemplate.CurrentConroller.FirstIndexCache+fIndex];
end;

function TIGTag.GetProp(index: integer): TIGProp;
const
 fmt='Свойство ID=%d для тэга %s не найдено';
var i,cp:integer;
begin
 result:=nil;
 cp:=ChildCount;
 for i:=0 to CP-1 do
  if TIGProp(Childs[i]).fPropID=index then
   begin
    result:=TIGProp(Childs[i]);
    result.fValue:=VarAsType(THAOPCMan(fTemplate.fOPCMan).PropValues[fTemplate.CurrentConroller.FirstIndexCache+fIndex][i],result.fTypeProp);
    break;
   end;
// if result=nil then
//  raise Exception.Create(format(fmt,[index,FullNameObj]));
end;

function TIGTag.GetOldQuality: word;
begin
 result:=THAOPCMan(fTemplate.fOPCMan).OldQuality[fTemplate.CurrentConroller.FirstIndexCache+fIndex];
end;


procedure TIGTag.SetNewValue(const Value: OleVariant);
begin
 THAOPCMan(fTemplate.fOPCMan).NewValue[fTemplate.CurrentConroller.FirstIndexCache+fIndex]:=Value;
// THAOPCMan(fTemplate.fOPCMan).NewQuality[fTemplate.CurrentConroller.FirstIndexCache+fIndex]:=OPC_QUALITY_GOOD;

end;

function TIGTag.PropExists(ID: dword): boolean;
var i,cp:integer;
begin
 result:=false;
 cp:=ChildCount;
 for i:=0 to CP-1 do
  if TIGProp(Childs[i]).fPropID=ID then
   begin
    result:=true;
    break;
   end;
end;

function TIGTag.GetNewValueAsArray(index: integer): OleVariant;
var ind:integer;

    //v:olevariant;
begin
 ind:=fTemplate.CurrentConroller.FirstIndexCache+fIndex;
 //v:=THAOPCMan(fTemplate.fOPCMan).NewValue[ind];
 if (VarType(THAOPCMan(fTemplate.fOPCMan).NewValue[ind]) and VarArray)<>VarArray then
  begin
   raise Exception.Create('Value is not Array');
  end;

 if VarArrayHighBound(THAOPCMan(fTemplate.fOPCMan).NewValue[ind],1)<index then
  result:=VarAsType(0,fTypeTag and VarTypeMask)
 else
  result:=VarAsType(THAOPCMan(fTemplate.fOPCMan).NewValue[ind][index],fTypeTag and VarTypeMask);
end;

procedure TIGTag.SetNewValueAsArray(index: integer;
  const Value: OleVariant);
var ind:integer;
begin
 ind:=fTemplate.CurrentConroller.FirstIndexCache+fIndex;
 if (VarType(THAOPCMan(fTemplate.fOPCMan).NewValue[ind]) and VarArray)<>VarArray then
  begin
   raise Exception.Create('Value is not Array');
  end;
 THAOPCMan(fTemplate.fOPCMan).SetNewValueAsArray(ind,Index,Value);
end;

function TIGTag.GetOldValueAsArray(index: integer): OleVariant;
var ind:integer;
begin
 ind:=fTemplate.CurrentConroller.FirstIndexCache+fIndex;

 if (VarType(THAOPCMan(fTemplate.fOPCMan).OldValue[ind]) and VarArray)<>VarArray then
  begin
   raise Exception.Create('Value is not Array');
  end;


 if VarArrayHighBound(THAOPCMan(fTemplate.fOPCMan).OldValue[ind],1)<Index then
  result:=VarAsType(0,fTypeTag and VarTypeMask)
 else
  result:=VarAsType(THAOPCMan(fTemplate.fOPCMan).OldValue[ind][index],fTypeTag and VarTypeMask);

end;


function TIGTag.ValueIsArray: boolean;
begin
 result:=(fTypeTag and VarArray)=VarArray;
end;


function TIGTag.GetPropByIndex(index: integer): TIGProp;
begin
  result:=TIGProp(Childs[index]);
end;

function TIGTag.PropIndex(ID: dword): integer;
var i,cp:integer;
begin
 result:=-1;
 cp:=ChildCount;
 for i:=0 to CP-1 do
  if TIGProp(Childs[i]).fPropID=ID then
   begin
    result:=i;
    break;
   end;
end;



procedure TIGTag.AddProp(OID: TOID; Props: string);
var i:integer;
    st:TStringList;
    OIDLink:integer;
    B:TIGProp;//BaseObj;
    ws:widestring;
begin
 st:=TStringList.Create;
  try
   OIDLink:=-1;
   st.Text:=Props;
   for i:=0 to st.Count-1 do
    if CompareText('OIDLink',st.Names[i])=0 then
      OIDLink:=strtoint(st.ValueFromIndex[i])
    else
     if CompareText('Value',st.Names[i])=0 then
       ws:=st.ValueFromIndex[i];

   if OIDLink<0 then exit;

   B:=fTemplate.SearchProp(OIDLink);
   if B=nil then exit;
   AddChild(B);
   SetLength(TmpPropValues,Length(TmpPropValues)+1);
   TmpPropValues[High(TmpPropValues)]:=HAHexStringValueToVariant(ws);
   {if (B.TypeProp and vt_Array)<>vt_Array then
    TmpPropValues[High(TmpPropValues)]:=VarAsType(ws,B.TypeProp)
   else
    begin
      st.Clear;
      s:='';
      for i:=1 to Length(ws) do
       if ws[i]='|' then
        begin
         st.Add(s);
         s:='';
        end
       else
        if i=Length(ws) then
         begin
          s:=s+ws[i];
          st.Add(s);
         end
        else
         s:=s+ws[i];

      TmpPropValues[High(TmpPropValues)]:=VarArrayCreate([0,st.Count-1],B.TypeProp and VarTypeMask);
      for i:=0 to st.Count-1 do
       TmpPropValues[High(TmpPropValues)][i]:=VarAsType(st[i],B.TypeProp and VarTypeMask);
    end;}

  finally
   st.Free;
  end;


end;

procedure TIGTag.SetVQT(VQT: TIGVQT);
begin
 fVQT:=VQT;
end;


{*******************************************************************************
 *                       Pascal Script procedures                              *
 *******************************************************************************}

procedure PS_TIGTag_GetOldValue(self:TIGTag; var Value:OleVariant);
begin
 Value:=self.OldValue;
end;

procedure PS_TIGTag_GetNewValue(self:TIGTag; var Value:OleVariant);
begin
 Value:=self.NewValue;
end;

procedure PS_TIGTag_SetNewValue(self:TIGTag; const Value:OleVariant);
begin
 self.NewValue:=Value;
end;

procedure PS_TIGTag_GetCountProps(self:TIGTag; var Value:integer);
begin
 value:=self.ChildCount;
end;

procedure PS_TIGTag_GetProp(self:TIGTag; var Value:TIGProp; Index:integer);
begin
 value:=self.Prop[index];
end;

procedure PS_TIGTag_SetNewValueAsArray(self:TIGTag; const Value:OleVariant; Index:integer);
begin
 self.SetNewValueAsArray(index, value);
end;

procedure PS_TIGTag_GetNewValueAsArray(self:TIGTag; var Value:OleVariant; Index:integer);
begin
 value:=self.NewValueAsArray[index];
end;

procedure PS_TIGTag_GetNewValueAsArrayCount(self:TIGTag; var Value:integer);
begin
 value:=self.NewValueAsArrayCount;
end;


procedure PS_TIGTag_GetOldValueAsArray(self:TIGTag; var Value:OleVariant; Index:integer);
begin
 value:=self.OldValueAsArray[index];
end;

procedure PS_TIGTag_GetOldValueAsArrayCount(self:TIGTag; var Value:integer);
begin
 value:=self.OldValueAsArrayCount;
end;


procedure PS_TIGTag_GetVQT(self:TIGTag; var Value:TIGVQT);
begin
 value:=self.VQT;
end;

procedure PS_TIGTag_GetOldQuality(self:TIGTag; var Value:word);
begin
 value:=self.OldQuality;
end;

procedure PS_TIGTag_GetNewQuality(self:TIGTag; var Value:word);
begin
 value:=self.NewQuality;
end;

procedure PS_TIGTag_SetNewQuality(self:TIGTag; const Value:word);
begin
 self.NewQuality:=value;
end;

procedure PS_TIGTag_GetDataType(self:TIGTag; var Value:word);
begin
 value:=self.TypeTag;
end;

procedure PS_TIGTag_GetIsReadable(self:TIGTag; var Value:boolean);
begin
 value:=self.IsReadable;
end;

procedure PS_TIGTag_GetIsWriteable(self:TIGTag; var Value:boolean);
begin
 value:=self.IsWriteable;
end;

procedure PS_TIGTag_GetIsStored(self:TIGTag; var Value:boolean);
begin
 value:=self.Saved;
end;

procedure PS_TIGTag_GetName(self:TIGTag; var Value:string);
begin
 value:=self.NameObj;
end;


{procedure PS_TIGTag_SetResult(self:TIGTag; const Value:integer);
begin
 self.Result:=value;
end;

procedure PS_TIGTag_GetResult(self:TIGTag; var Value:integer);
begin
 value:=self.Result;
end;
}



function TIGTag.GetNewValueAsArrayCount: integer;
var ind:integer;
begin
 result:=-1;
 ind:=fTemplate.CurrentConroller.FirstIndexCache+fIndex;
 //v:=THAOPCMan(fTemplate.fOPCMan).NewValue[ind];
 if (VarType(THAOPCMan(fTemplate.fOPCMan).NewValue[ind]) and VarArray)=VarArray then
  begin
   result:=VarArrayHighBound(THAOPCMan(fTemplate.fOPCMan).NewValue[ind],1)+1;
  end;
end;

function TIGTag.GetOldValueAsArrayCount: integer;
var ind:integer;
begin
 result:=-1;
 ind:=fTemplate.CurrentConroller.FirstIndexCache+fIndex;
 //v:=THAOPCMan(fTemplate.fOPCMan).NewValue[ind];
 if (VarType(THAOPCMan(fTemplate.fOPCMan).OldValue[ind]) and VarArray)=VarArray then
  begin
   result:=VarArrayHighBound(THAOPCMan(fTemplate.fOPCMan).OldValue[ind],1)+1;
  end;

end;

function TIGTag.GetIndexForCache: integer;
begin
 {$IFDEF FULLVERSION}
 result:=fIndex;
 {$ELSE}
 if (fTemplate.CurrentConroller.FirstIndexCache+fIndex)>=THAOPCMan(fTemplate.fOPCMan).GetMaxDemoCountItems then
  result:=-1
 else
  result:=fIndex;
 {$ENDIF}
end;

{ TIGDevice }

constructor TIGDevice.Create(Parent: THABaseObj; OID: TOID;
  NameObj, Props: string);
var //st:TStringList;
    //i:integer;
    p:PDataItem2;
    Proxy:TIGDevice_Proxy;
begin
  inherited Create(Parent,OID,classController,NameObj);
  Proxy:=TIGDevice_Proxy.Create;
  new(p);
  try
    fillchar(p^,sizeof(TDataItem2),0);
    p^.Name:=NameObj;
    p^.Props:=Props;
    Proxy.AddData(p);
    fHashDrv:=MakeHashId(Proxy.DriverName);
    fAddress:=Proxy.Address;
    fActive:=Proxy.Active;
    fParam:=Proxy.Param;
  finally
   dispose(p);
   Proxy.Free;
  end;


{  st:=TStringList.Create;
  try
   st.Text:=Props;
   for i:=0 to st.Count-1 do
    begin
     if CompareText('DriverName',st.Names[i])=0 then
      fHashDrv:=MakeHashId(st.ValueFromIndex[i])
     else
      if CompareText('Address',st.Names[i])=0 then
       fAddress:=st.ValueFromIndex[i];

    end;
  finally
   st.Free;
  end;  }
end;

{function TIGDevice.GetCountCalcTags: integer;
begin
 result:=fTemplate.fCountCalcTags;
end;
 }

{function TIGDevice.GetCountTags: integer;
begin
 result:=fTemplate.fTags.Count;
end;
 }

{function TIGDevice.GetTag(index: integer): TIGTag;
begin
 fTemplate.CurrentConroller:=self;
 result:=fTemplate.Tags[index];
end;
 }


function TIGDevice.GetTagsList: TIGTags;
begin
 result:=fTemplate.fTags;
end;
{
procedure TIGDevice.SetTag(index: integer; const Value: TIGTag);
begin
 fTemplate.CurrentConroller:=self;
 fTemplate.Tags[index]:=Value;
end;
 }
procedure TIGDevice.SwithIndexTemplate;
begin
 fTemplate.CurrentConroller:=self;
end;


{*******************************************************************************
 *                       Pascal Script procedures                              *
 *******************************************************************************}

{procedure PS_TIGDevice_GetTag(self:TIGDevice; var Value:TIGTag; I:integer);
begin
 Value:=self.Tags[i];
end;
 }
{procedure PS_TIGDevice_SetTag(self:TIGDevice; const Value:TIGTag; I:integer);
begin
 self.Tags[i]:=Value;
end;
 }
{procedure PS_TIGDevice_GetCountTags(self:TIGDevice; var Value:integer);
begin
 value:=self.GetCountTags;
end;
 }
procedure PS_TIGDevice_GetAddress(self:TIGDevice; var Value:string);
begin
 value:=self.Address;
end;

procedure PS_TIGDevice_SetAddress(self:TIGDevice; const Value:string);
begin
 self.Address:=value;
end;

procedure PS_TIGDevice_GetParam(self:TIGDevice; var Value:dword);
begin
 value:=self.Param;
end;

procedure PS_TIGDevice_SetParam(self:TIGDevice; const Value:dword);
begin
 self.Param:=value;
end;


procedure PS_TIGDevice_GetTags(self:TIGDevice; var Value:TIGTags);
begin
 value:=self.TagsList;
end;

procedure PS_TIGDevice_GetTemplateName(self:TIGDevice; var Value:string);
begin
 value:='';
 if self.Template<>nil then
  value:=self.Template.NameObj;
end;



{ TIGCommand }



constructor TIGCommand.Create(OID:TOID; NameObj:string; Props:string='');
var p:PDataItem2;
    Proxy:TIGCommand_Proxy;
begin
  inherited Create(nil,oid,ClassCommand,NameObj);
  fData:=nil;
  Proxy:=TIGCommand_Proxy.Create;
  new(p);
  try
    fillchar(p^,sizeof(TDataItem2),0);
    p^.Name:=NameObj;
    p^.Props:=Props;
    Proxy.AddData(p);
    fNoCommand:=Proxy.NoCommand;
    fCountW:=Proxy.CountWriteBytes;

    fParam:=Proxy.Param;

    fOnBeforeWrite:=Proxy.OnBeforeWrite;
    fOnAfterRead:=Proxy.OnAfterRead;
    fPriority:=Proxy.Priority;
    fSPriority:=fPriority;
  finally
   dispose(p);
   Proxy.Free;
  end;

end;


destructor TIGCommand.Destroy;
begin
  SetLength(fData,0);
  inherited;
end;


function TIGCommand.GetCount: integer;
begin
 if Length(fData)=0 then
  if fCountW>0 then
   SetLength(fData,fCountW);
 result:=Length(fData);
end;

function TIGCommand.GetData(index: integer): byte;
begin
  if Length(fData)=0 then
   if fCountW>0 then
    SetLength(fData,fCountW);
  result:=fData[index];
end;



procedure TIGCommand.Run;
var C:THAPSCommand;
begin
 if OPCMan.CountServers=0 then exit;
 C:=THAPSCommand.Create(self);
// C.InDynList:=false;
 C.Controller:=fTemplate.fCurrentController;
 THAOPCMan(self.fTemplate.fOPCMan).AddCommand(C);
end;

{procedure TIGCommand.RunOnce;
begin
 Run(tc_once);
end;

procedure TIGCommand.RunPeriodic;
begin
 Run(tc_periodic);
end;
 }
procedure TIGCommand.SetCount(const Value: integer);
begin
 SetLength(fData,Value);
end;

procedure TIGCommand.SetData(index: integer; const Value: byte);
begin
 if Length(fData)=0 then
  if fCountW>0 then
   SetLength(fData,fCountW);

 fData[index]:=Value;
end;





{*******************************************************************************
 *                       Pascal Script procedures                              *
 *******************************************************************************}

procedure PS_TIGCommand_GetData(self:TIGCommand; var Value:byte; I:integer);
begin
 try
  Value:=self[i];
 except
  raise Exception.Create('TIGcommand: Выход за пределы массива');
 end;
end;

procedure PS_TIGCommand_SetData(self:TIGCommand; const Value:byte; I:integer);
begin
 try
  self[i]:=Value;
 except
  raise Exception.Create('TIGcommand: Выход за пределы массива');
 end;
end;


procedure PS_TIGCommand_GetCount(self:TIGCommand; var Value:integer);
begin
 Value:=self.Count;
end;

procedure PS_TIGCommand_SetCount(self:TIGCommand; const Value:integer);
begin
 self.Count:=Value;
end;

procedure PS_TIGCommand_GetPriority(self:TIGCommand; var Value:word);
begin
 Value:=self.Priority;
end;

procedure PS_TIGCommand_SetPriority(self:TIGCommand; const Value:word);
begin
 self.Priority:=Value;
end;

procedure PS_TIGCommand_GetNoCommand(self:TIGCommand; var Value:string);
begin
 Value:=self.NoCommand;
end;





{ THAPSCommand }

constructor THAPSCommand.Create(ParentCommand:TIGCommand);
var i:integer;
begin
 inherited Create(nil,-1,ClassCommand,'');
 fhServerGroup:=0;
 fParentCommand:=ParentCommand;
// fIsExecuted:=false;
 if fParentCommand=nil then exit;
 SetLength(fData,fParentCommand.Count);
 for i:=0 to High(fData) do
  fData[i]:=fParentCommand.fData[i];
 fPriority:=fParentCommand.Priority;

// fParentCommand.Count:=0;

 fState:=cs_Wait;
 fInUse:=false;
 fDeleted:=false;
 fIDTrans:=0;
 fCurrentNoConfig:=OPCMan.CurrentNoConfig;
 //fInDevice:=false;
end;

destructor THAPSCommand.destroy;
begin
  SetLength(fData,0);
  inherited;
end;

function THAPSCommand.GetCount: integer;
begin
 result:=Length(fData);
end;


function THAPSCommand.GetData(index: integer): byte;
begin
 if index>High(fData) then
  SetLength(fData,Length(fData)+(index+1));
 result:=fData[index];
end;





procedure THAPSCommand.SetCount(const Value: integer);
begin
 SetLength(fData,Value);
end;

procedure THAPSCommand.SetData(index: integer; const Value: byte);
begin
 if index>High(fData) then
  SetLength(fData,Length(fData)+(index+1));
 fData[index]:=Value;
end;


{*******************************************************************************
 *                       Pascal Script procedures                              *
 *******************************************************************************}

{procedure PS_THAPSCommand_GetData(self:THAPSCommand; var Value:byte; I:integer);
begin
 Value:=self[i];
end;

procedure PS_THAPSCommand_SetData(self:THAPSCommand; const Value:byte; I:integer);
begin
 self[i]:=Value;
end;


procedure PS_THAPSCommand_GetCount(self:THAPSCommand; var Value:integer);
begin
 Value:=self.Count;
end;

procedure PS_THAPSCommand_SetCount(self:THAPSCommand; const Value:integer);
begin
 self.Count:=Value;
end;

procedure PS_THAPSCommand_GetResult(self:THAPSCommand; var Value:dword);
begin
 Value:=self.Result;
end;

procedure PS_THAPSCommand_GetNoCommand(self:THAPSCommand; var Value:string);
begin
 Value:='';
 if self.ParentCommand<>nil then
  Value:=self.ParentCommand.NoCommand;
end;

 }


{ THAList }

{procedure THAList.Add(Obj: THABaseObj);
begin
 fList.Add(Obj);
end;

procedure THAList.AddIndex(Index: integer);
begin
 fIndexList.Add(pointer(Index));

end;

procedure THAList.Clear;
var i:integer;
begin
 for i:=0 to fList.Count-1 do
   THABaseObj(fList[i]).Free;
  fList.clear;
  fIndexList.Clear;
end;

procedure THAList.ClearIndexTable;
begin
 fIndexList.Clear;

end;

constructor THAList.Create;
begin
 inherited;
 fList:=TList.Create;
 fIndexList:=TList.Create;
 fIndexIsUser:=false;
end;

destructor THAList.destroy;
begin
  clear;
  fList.Free;
  fIndexList.Free;
  inherited;
end;

function THAList.GetCount: integer;
begin
 if fIndexIsUser then
  result:=fIndexList.Count
 else
  result:=fList.Count;

end;

function THAList.GetItem(index: integer): THABaseObj;
begin
 if fIndexIsUser then
  result:=fList[integer(fIndexList[index])]
 else
  result:=fList[index];
end;

procedure THAList.SetItem(index: integer; const Value: THABaseObj);
begin
 if fIndexIsUser then
  fList[integer(fIndexList[index])]:=value
 else
  fList[index]:=value;

end;
 }


{ TIGTags }


{function TIGTags.GetTag(index: integer): TIGTag;
begin
 result:=TIGTag(Items[index]);
end;

procedure TIGTags.SetTag(index: integer; const Value: TIGTag);
begin
 Items[index]:=value;
end;

procedure TIGTags.SortTags;

function Sort_(Item1, Item2: Pointer): Integer;
var T1,T2:TIGTag;
begin
 result:=0;
 if Item1=nil then exit;
 if Item2=nil then exit;
 T1:=TIGTag(Item1);
 T2:=TIGTag(Item2);



 if T1.fCalc and (not T2.fCalc) then result:=-1
 else
  if (not T1.fCalc) and T2.fCalc then result:=1
  else
   result:=0;

end;

begin
//  fList.Sort(@Sort_);
end;
 }


{*******************************************************************************
 *                       Pascal Script procedures                              *
 *******************************************************************************}

{procedure PS_TIGTags_GetTag(self:TIGTags; var Value:TIGTag; I:integer);
begin
 value:=self.Tags[i];
end;

procedure PS_TIGTags_GetCount(self:TIGTags; var Value:integer);
begin
 value:=self.Count;
end;
 }


















procedure THAOPCItem.AddRef;
begin
 inc(fCountRef);
end;


constructor THAOPCItem.Create(Group:TObject; IDCache,IDProp: integer);
begin
 inherited Create;
 fCurrentNoConfig:=OPCMan.CurrentNoConfig;
 fIDCache:=IDCache;
 fIDProp:=IDProp;
 fGroup:=Group;
 fActive:=true;
 fCountRef:=0;
 fOldValue:=GetValue;
 fOldQuality:=GetQuality;
 fOldTimeStamp:=GetTimeStamp;

end;

function THAOPCItem.GetAccessRight: dword;
begin
 result:=0;
 if fIDProp<0 then
  begin
   if OPCMan.Tag[fIDCache].IsReadable then
     result:=result or OPC_READABLE;
   if OPCMan.Tag[fIDCache].IsWriteable then
     result:=result or OPC_WRITEABLE;
  end
 else
  result:=OPC_READABLE or OPC_WRITEABLE;
end;

function THAOPCItem.GetCanonicalDataType: TVarType;
begin
 result:=vt_empty;
 if fCurrentNoConfig<>OPCMan.CurrentNoConfig then exit;
 if fIDProp<0 then
  result:=OPCMan.Tag[fIDCache].TypeTag
 else
  result:=OPCMan.Tag[fIDCache].PropByIndex[fIDProp].TypeProp;
end;

function THAOPCItem.GetFullName: string;
begin
 result:='';
 if fCurrentNoConfig<>OPCMan.CurrentNoConfig then exit;
 if fIDProp>=0 then
  result:=OPCMan.Tag[fIDCache].PropByIndex[fIDProp].FullNameObj
 else
  result:=OPCMan.Tag[fIDCache].FullNameObj;

 result:=OPCMan.Controller[fIDCache].FullNameObj+BranchSep+result;
end;

function THAOPCItem.GetItemIsTrans: boolean;
begin
 result:=fCountRef>0;
end;

function THAOPCItem.GetProp(IDProp: dword): TIGProp;
begin
 result:=nil;
 if fCurrentNoConfig<>OPCMan.CurrentNoConfig then exit;
 if fIDProp<0 then
  result:=OPCMan.Tag[fIDCache].Prop[IDProp];

end;

function THAOPCItem.GetQuality: word;
begin
 if fCurrentNoConfig<>OPCMan.CurrentNoConfig then
  result:=OPC_QUALITY_CONFIG_ERROR
 else
  if fIDProp<0 then
   result:=OPCMan.OldQuality[fIDCache]
  else
   result:=OPC_QUALITY_GOOD;
end;

function THAOPCItem.GetRequestedDatatype: TVarType;
begin
 if fRequestedDataType>0 then
  Result := fRequestedDatatype
 else
  Result:=GetCanonicalDataType; 
end;

function THAOPCItem.GetTimeStamp: TFileTime;
begin
 result.dwLowDateTime:=0; result.dwHighDateTime:=0;
 if fCurrentNoConfig=OPCMan.CurrentNoConfig then
  result:=OPCMan.OldFileTime[fIDCache];
end;

function THAOPCItem.GetValue: OleVariant;
begin
 if fCurrentNoConfig=OPCMan.CurrentNoConfig then
  if fIDProp<0 then
   result:=OPCMan.OldValue[fIDCache]
  else
   result:=OPCMan.PropValues[fIDCache][fIDProp];
end;

function THAOPCItem.GetValue2(var Dest: OleVariant): HResult;
var dt:word;
begin
 if fCurrentNoConfig=OPCMan.CurrentNoConfig then
  begin
   if fRequestedDatatype>0 then
    dt:=fRequestedDatatype
   else
    dt:=GetCanonicalDataType;

   if fIDProp<0 then
    result:=HAConvertVariantType(Dest,OPCMan.OldValue[fIDCache],THADAGroup(fGroup).LocaleID,dt)
   else
    result:=HAConvertVariantType(Dest,OPCMan.PropValues[fIDCache][fIDProp],THADAGroup(fGroup).LocaleID,dt);
  end
 else
  result:=e_fail; 
end;

procedure THAOPCItem.ReleaseRef;
begin
 dec(fCountRef);
end;




constructor TIGProp.Create(OID: TOID; NameObj, Props: string);
var p:PDataItem2;
    Proxy:TIGProp_Proxy;
begin
  inherited Create(nil,oid,ClassProp,NameObj);
  Proxy:=TIGProp_Proxy.Create;
  new(p);
  try
    fillchar(p^,sizeof(TDataItem2),0);
    p^.Name:=NameObj;
    p^.Props:=Props;
    Proxy.AddData(p);
    fTypeProp:=Proxy.DataType;
    fPropID:=Proxy.PropID;
    fUniqueValue:=Proxy.UniqueValue;
  finally
   dispose(p);
   Proxy.Free;
  end;

{ st:=TStringList.Create;
  try
   st.Text:=Props;
   for i:=0 to st.Count-1 do
    begin
     if CompareText('PropID',st.Names[i])=0 then
      fPropID:=strtoint(st.ValueFromIndex[i])
     else
      if CompareText('TypeProp',st.Names[i])=0 then
        fTypeProp:=strtovartype(st.ValueFromIndex[i]);



    end;
  finally
   st.Free;
  end;
 }
end;

function TIGProp.GetValueAsArray(index: integer): Variant;
begin
 result:=fValue[index];
end;

function TIGProp.GetValueAsArrayCount: integer;
begin
 result:=VarArrayHighBound(fValue,1)+1;
end;

function TIGProp.ValueIsArray: boolean;
begin
  result:=(fTypeProp and VarArray)=VarArray;
end;

{*******************************************************************************
 *                       Pascal Script procedures                              *
 *******************************************************************************}
procedure PS_TIGProp_GetValue(self:TIGProp; var Value:variant);
begin

 value:=VarAsType(self.fValue,self.fTypeProp);
end;

procedure PS_TIGProp_GetTypeProp(self:TIGProp; var Value:word);
begin
 value:=self.fTypeProp;
end;

procedure PS_TIGProp_GetPropID(self:TIGProp; var Value:dword);
begin
 value:=self.fPropID;
end;

procedure PS_TIGProp_GetValueAsArrayCount(self:TIGProp; var Value:integer);
begin
 value:=self.ValueAsArrayCount;
end;

procedure PS_TIGProp_GetValueAsArray(self:TIGProp; var Value:OleVariant; Index:integer);
begin
 value:=self.ValueAsArray[index];
end;

procedure PS_TIGProp_GetUniqueValue(self:TIGProp; var Value:boolean);
begin
 value:=self.fUniqueValue;
end;











{ THATransaction2 }

procedure THATransaction2.AddCommand(Command: THAPSCommand);
begin
 Command.fIDTrans:=fIDTrans;
 Command.fhServerGroup:=THADAGroup(fGroup).hServerGroup;
 fCommands.Add(Command);
end;


procedure THATransaction2.AddItem(Item: THAOPCItem; ItemVQT: POPCITEMVQT);
var p:PHATransactionParam2;
    i:integer;
    fl:boolean;
begin
 fl:=false;
 for i:=0 to fItems.Count-1 do
  if THATransactionParam2(fItems[i]^).OPCItem.fIdCache=Item.fIdCache then
   begin
    fl:=true;
    break;
   end;

 if fl then exit;

 new(p);
 fillchar(p^,sizeof(PHATransactionParam2),0);

 Item.AddRef;

 p^.OPCItem:=Item;
 p^.Result:=s_ok;
 if ItemVQT<>nil then
   p^.VQT:=TIGVQT.Create(ItemVQT^);

 fItems.Add(p);
end;

procedure THATransaction2.ClearTr(ClearOnlyCommands:boolean);
var i:integer;
begin
 if not ClearOnlyCommands then
  begin
     for i:=0 to fItems.Count-1 do
      begin
       if THATransactionParam2(fItems[i]^).VQT<>nil then
        begin
         THATransactionParam2(fItems[i]^).VQT.Free;
         THATransactionParam2(fItems[i]^).VQT:=nil;
        end;
       THATransactionParam2(fItems[i]^).OPCItem.ReleaseRef;
       dispose(fItems[i]);
      end;
     fItems.Clear;
  end;


 // команды на момент уничтожения транзакции могут находиться в кэше
 // сервера, чтобы их удалить, необходимо пометить их как удаленные
 // (пометка на удаление создается в потоке группы)
 // после этого кэш сервера очищается от этих команд

 // реальное освобождение команд происходит в потоке группы, которой
 // принадлежит транзакция
 for i:=0 to fCommands.Count-1 do
   THADAGroup(fGroup).TimerGroup.FreeCommand(fCommands[i]);

 fCommands.clear;

end;

constructor THATransaction2.Create(Group:pointer; TrKind: THATransactionKind; ClientIDTrans,IdTrans,
  IdCancel: dword; ForDevice:boolean; TimeToLifes:cardinal);
begin
 inherited Create;
 fTimeToLifes:=TimeToLifes;
 fGroup:=Group;
 fItems:=TList.Create;
 fCommands:=TList.Create;
 fTrKind:=TrKind;
 fIDTrans:=IdTrans;
 fClientIDTrans:=ClientIDTrans;
 fIDCancel:=IdCancel;
 fTrState:=trs_wait;
 fInUse:=false;
// fCountExecCommand:=0;
 fForDevice:=ForDevice;
 fTimeCreate:=GetTickCount;
 fCurrentNoConfig:=OPCMan.CurrentNoConfig;
end;

destructor THATransaction2.destroy;
begin
  ClearTr(false);
  fItems.Free;
  fCommands.Free;
  inherited;
end;

function THATransaction2.GetCommand(index: integer): THAPSCommand;
begin
 result:=nil;
 if (index<0) or (index>=fCommands.count) then exit;
 result:=fcommands[index];
end;

function THATransaction2.GetCountCommands: integer;
begin
 result:=fCommands.Count;
end;

function THATransaction2.GetCountItems: integer;
begin
 result:=fItems.Count;
end;

function THATransaction2.GetItem(index: integer): THAOPCItem;
begin
 result:=nil;
 if (index<0) or (index>=fItems.Count) then exit;
 result:=THATransactionParam2(fItems[index]^).OPCItem;
end;





procedure THATransaction2.Read;
var i,fCount,fcountErrors:integer;
    res,resr,ResQ:HResult;
    fClientHandle :POPCHANDLEARRAY;
    fValues :POleVariantArray;
    fQuality:PWORDARRAY;
    fTime   :PTFileTimeARRAY;
    fErrors :PResultList;
    t:THAOPCItem;

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
end;

begin
 if fItems.Count=0 then exit;
 if THADAGroup(fGroup).DataCallback=nil then exit;


 fClientHandle:=nil;
 fQuality:=nil;
 fTime:=nil;
 fValues:=nil;
 fErrors:=nil;

 fCount:=fItems.Count;

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

 ResQ:=s_ok;
 fCountErrors:=0;

 OPCMan.BeginRead;
 try
   for i:=0 to fCount-1 do
    begin
     t:=THAOPCItem(THATransactionParam2(fItems[i]^).OPCItem);
     fClientHandle[i]:=t.ClientHandle;

     if t.CurrentNoConfig<>OPCMan.CurrentNoConfig then
      begin
       fErrors[i]:=OPC_E_INVALIDHANDLE;
       res:=s_false;
       continue;
      end;

     if t.Deleted then
      begin
       fErrors[i]:=OPC_E_INVALIDHANDLE;
       res:=s_false;
       continue;
      end;

     if (t.AccessRight and OPC_READABLE)<>OPC_READABLE then
      begin
       fErrors[i]:=OPC_E_BADRIGHTS;
      // inc(fCountErrors);
       continue;
      end;



     fErrors[i]:=THATransactionParam2(fItems[i]^).Result; //s_ok;
     if fErrors[i]<>s_ok then
      Res:=S_FALSE;

     fErrors[i]:=t.GetValue2(fValues[i]);
     if fErrors[i]<>s_ok then
      res:=s_false;


     fQuality[i]:=t.Quality;
     if t.Quality<>OPC_QUALITY_GOOD then
      resq:=s_false;

     if fTrState=trs_Roolback then
      begin
       fErrors[i]:=E_FAIL;
       Res:=S_FALSE;
      end;

     fTime[i]:=t.TimeStamp;
    end;
 finally
  OPCMan.EndRead;
 end; 

 if fTrKind=tk_AsyncRefresh then
  begin
    resr:= THADAGroup(fGroup).DataCallBack.OnDataChange(fClientIDTrans,
                                                    THADAGroup(fGroup).hClientGroup,
                                                    ResQ,
                                                    Res,
                                                    fCount,
                                                    @fClientHandle^,
                                                    @fValues^,
                                                    @fQuality^,
                                                    @fTime^,
                                                    @fErrors^);

    AddLog(3,'IOPCAsyncIO2 Refresh2',ResR,ErrorCodeToString(ResR));
  end
 else
  if fTrKind=tk_AsyncRead then
  begin
   resr:=THADAGroup(fGroup).DataCallBack.OnReadComplete(fClientIDTrans,
                                                   THADAGroup(fGroup).hClientGroup,
                                                   ResQ,
                                                   Res,
                                                   fCount,
                                                   @fClientHandle^,
                                                   @fValues^,
                                                   @fQuality^,
                                                   @fTime^,
                                                   @fErrors^);
   AddLog(3,'IOPCAsyncIO2 Read',ResR,ErrorCodeToString(ResR));
  end;
 ClearParams;
end;

procedure THATransaction2.UpdateState;
var i,j,k:integer;
    rupd:dword;
begin
 if fTrState=trs_Commit then exit;
 rupd:=THADAGroup(fGroup).TimerGroup.RequestUpdateRate;// div fCommands.Count;
 j:=0;
 k:=0;
 for i:=0 to fCommands.Count-1 do
  if THAPSCommand(fCommands[i]).State=cs_Wait then
   begin
      inc(k);
      THAPSCommand(fCommands[i]).UpdateRate:=rupd;
      if fTrKind<>tk_Group then
       OPCMan.AddCommandInDynList(fCommands[i]);
   end
  else
   if THAPSCommand(fCommands[i]).State=cs_Commit then
    inc(j);

 if (j=fCommands.Count) or (fCommands.Count=0) then
   TrState:=trs_commit
 else
   TrState:=trs_Processed;
end;

procedure THATransaction2.Sort;

function SortItemsRead(Item1,Item2:pointer):integer;
var T1,T2:TIGTag;
    C1,C2:integer;//TIGDevice;

begin
 {Сортируем в таком порядке:
   Контроллеры
   Скрипты
  }


 C1:=OPCMan.Controller[THATransactionParam2(Item1^).OPCItem.IDCache].OID;
 C2:=OPCMan.Controller[THATransactionParam2(Item2^).OPCItem.IDCache].OID;


 if C1<C2 then result:=1
 else
  if C1>C2 then result:=-1
  else
   begin
       T1:=OPCMan.Tag[THATransactionParam2(Item1^).OPCItem.IDCache];
       T2:=OPCMan.Tag[THATransactionParam2(Item2^).OPCItem.IDCache];

       result:=CompareText(T1.fOnRead,T2.fOnRead);
      { S1:=0; S2:=0;
       if not T1.IsCalc then
         S1:=integer(T1.fScriptR);
       if not T2.IsCalc then
         S2:=integer(T2.fScriptR);

       if S1<S2 then result:=1
       else
        if S1>S2 then result:=-1
        else
         if S1=S2 then
             result:=0;
       }
    end;
end;

function SortItemsWrite(Item1,Item2:pointer):integer;
var T1,T2:TIGTag;
    C1,C2:integer;//TIGDevice;
    
begin
 {Сортируем в таком порядке:
   Контроллеры
   Скрипты
  }


 C1:=OPCMan.Controller[THATransactionParam2(Item1^).OPCItem.IDCache].OID;
 C2:=OPCMan.Controller[THATransactionParam2(Item2^).OPCItem.IDCache].OID;


 if C1<C2 then result:=1
 else
  if C1>C2 then result:=-1
  else
   begin
     T1:=OPCMan.Tag[THATransactionParam2(Item1^).OPCItem.IDCache];
     T2:=OPCMan.Tag[THATransactionParam2(Item2^).OPCItem.IDCache];
     result:=CompareText(T1.fOnWrite,T2.fOnWrite);

   {  S1:=Integer(T1.fScriptW);
     S2:=Integer(T2.fScriptW);

     if S1<S2 then result:=1
       else
        if S1>S2 then result:=-1
        else
         if S1=S2 then
             result:=0;
    }
   end;
end;


begin
 if fTrKind in [tk_AsyncRead,tk_SyncRead,tk_AsyncRefresh,tk_Group] then
   fItems.Sort(@SortItemsRead)
 else
   fItems.Sort(@SortItemsWrite);
end;


procedure THATransaction2.Write;
var i,fCount:integer;
    res,resr:HResult;
    fClientHandle :POPCHANDLEARRAY;
    fErrors :PResultList;
    t:THAOPCItem;

procedure ClearParams;
begin
 if fClientHandle<>nil then
  CoTaskMemFree(fClientHandle);
 if fErrors<>nil then
  CoTaskMemFree(fErrors);
end;

begin
 if THADAGroup(fGroup).DataCallback=nil then exit;

 fClientHandle:=nil;
 fErrors:=nil;

 fCount:=fItems.Count;

 fClientHandle:=OPCTaskMemAlloc(Res,sizeof(OPCHandle),fCount);
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


 for i:=0 to fCount-1 do
  begin
   t:=THAOPCItem(THATransactionParam2(fItems[i]^).OPCItem);
   fClientHandle[i]:=t.ClientHandle;
   if t.CurrentNoConfig<>OPCMan.CurrentNoConfig then
    begin
     fErrors[i]:=OPC_E_INVALIDHANDLE;
     res:=s_false;
     continue;
    end;

   if t.Deleted then
    begin
     fErrors[i]:=OPC_E_INVALIDHANDLE;
     res:=s_false;
     continue;
    end;

   if fTrState=trs_Roolback then
    fErrors[i]:=E_FAIL
   else
    fErrors[i]:=THATransactionParam2(fItems[i]^).Result; //s_ok;

   if fErrors[i]<>s_ok then
     Res:=S_FALSE;
  end;

 resr:=THADAGroup(fGroup).DataCallBack.OnWriteComplete(fClientIDTrans,
                                                       THADAGroup(fGroup).hClientGroup,
                                                       Res,
                                                       fCount,
                                                       @fClientHandle^,
                                                       @fErrors^);
 AddLog(3,'IOPCAsyncIO2 Write',ResR,ErrorCodeToString(ResR));
 ClearParams;
 //fTrState:=trs_Commit;
end;

{function TIGTag.GetResult: HResult;
begin
 result:=THAOPCMan(fTemplate.fOPCMan).ResultRW[fTemplate.CurrentConroller.FirstIndexCache+fIndex];
end;

procedure TIGTag.SetResult(const Value: HResult);
begin
 THAOPCMan(fTemplate.fOPCMan).ResultRW[fTemplate.CurrentConroller.FirstIndexCache+fIndex]:=Value;
end;
 }
function THATransaction2.GetInUse: boolean;
var i:cardinal;
begin
 i:=GetTickCount;
 if fTrKind in [tk_SyncRead,tk_SyncWrite] then
  if abs(i-fTimeCreate)>=fTimeToLifes then
   TrState:=trs_Roolback;
 result:=fInUse;

end;


function THATransaction2.GetVQT(index: integer): TIGVQT;
begin
 result:=nil;
 if (index<0) or (index>=fItems.Count) then exit;
 result:=THATransactionParam2(fItems[index]^).VQT;

end;

procedure THATransaction2.SetResultForItems(IDCache: integer;
  Result: HResult);
var i:integer;
    p:PHATransactionParam2;
begin
 for i:=0 to fItems.Count-1 do
  begin
   p:=fItems[i];
   if p=nil then continue;
   if (p^.OPCItem.IDCache=IDCache) or (IDCache<0) then
     p^.Result:=Result;
  end;
end;

function THATransaction2.GetResultForItems(IDCache: integer): HResult;
var i:integer;
    p:PHATransactionParam2;
begin

 result:=s_ok;
 for i:=0 to fItems.Count-1 do
  begin
   p:=fItems[i];
   if p=nil then continue;
   if p^.OPCItem.IDCache=IDCache then
    begin
     result:=p^.Result;
     break;
    end;
  end;

end;

procedure THATransaction2.SetTrState(const Value: THATransactionState);
var i:integer;
begin
  fTrState := Value;
 { if fTrKind=tk_Group then exit;
  if fTrState in [trs_Commit,trs_Cancel,trs_Roolback] then
  for i:=0 to fCommands.Count-1 do
   THAPSCommand(fCommands[i]).Deleted:=true;}
end;

function THATransaction2.SetCancel: boolean;
var i,k:integer;
begin
 result:=false;
 if fTrState in [trs_Commit,trs_Cancel,trs_Roolback] then exit;
 k:=0;
 for i:=0 to fCommands.Count-1 do
  if THAPSCommand(fCommands[i]).State in [cs_Wait,cs_BeforeWriting] then
   inc(k);

 result:=k=fCommands.Count;
 if result then
  fTrState:=trs_Cancel;
end;

procedure THATransaction2.Cancel;
var resR:HResult;
begin
 resR:=THADAGroup(fGroup).DataCallBack.OnCancelComplete(fClientIDTrans,THADAGroup(fGroup).hClientGroup);
 if resr<>s_ok then
  AddLog(3,'IOPCAsyncIO2 Cancel',ResR,ErrorCodeToString(ResR));
end;

function THATransaction2.GetCountCommitCommands: integer;
var i:integer;
begin
 result:=0;
 for i:=0 to fCommands.Count-1 do
  if THAPSCommand(fCommands[i]).State=cs_Commit then
   inc(result);
end;

{ TIGVQT }

constructor TIGVQT.Create(VQT: OPCItemVQT);
begin
 fVQT:=VQT;
end;



destructor TIGVQT.Destroy;
begin
  VarClear(fVQT.vDataValue);
  inherited;
end;

function TIGVQT.GetValue: OLEVariant;
begin
 result:=fVQT.vDataValue;
end;

function TIGVQT.GetValueAsArray(index: integer): OLEVariant;
begin
 if (VarType(fVQT.vDataValue) and VarArray)<>VarArray then
  begin
   raise Exception.Create('Value is not Array');
  end;
 if VarArrayHighBound(fVQT.vDataValue,1)<index then
  result:=VarAsType(0,VarType(fVQT.vDataValue) and VarTypeMask)
 else
  result:=VarAsType(fVQT.vDataValue[index],VarType(fVQT.vDataValue) and VarTypeMask);

end;

function TIGVQT.GetValueAsArrayCount: integer;
begin
 result:=0;
 if (VarType(fVQT.vDataValue) and vt_array)=vt_array then
   result:=VarArrayHighBound(fVQT.vDataValue,1)+1;
end;

function TIGVQT.ValueIsArray: boolean;
begin
 result:=(VarType(fVQT.vDataValue) and VarArray)=VarArray;
end;


{*******************************************************************************
 *                       Pascal Script procedures                              *
 *******************************************************************************}

procedure PS_TIGVQT_GetValue(self:TIGVQT; var Value:OleVariant);
begin
 Value:=self.Value;
end;

procedure PS_TIGVQT_GetValueAsArray(self:TIGVQT; var Value:OleVariant; Index:integer);
begin
 value:=self.ValueAsArray[index];
end;

procedure PS_TIGVQT_GetValueAsArrayCount(self:TIGVQT; var Value:integer);
begin
 Value:=self.GetValueAsArrayCount;
end;















{function TIGTag.GetHide: boolean;
begin
 result:=((fFlags and tf_read)<>tf_read) and ((fFlags and tf_write)<>tf_write);
end;
 }
function TIGTag.GetNewQuality: word;
begin
 result:=THAOPCMan(fTemplate.fOPCMan).NewQuality[fTemplate.CurrentConroller.FirstIndexCache+fIndex];
end;


procedure TIGTag.SetNewQuality(const Value: word);
begin
 THAOPCMan(fTemplate.fOPCMan).NewQuality[fTemplate.CurrentConroller.FirstIndexCache+fIndex]:=Value;
end;

{ TIGTagValue }

{constructor TIGTagValue.Create(Value:OleVariant);
begin
 inherited Create;
 fValue:=Value;
end;

function TIGTagValue.GetTypeValue: word;
begin
 result:=VarType(fValue);
end;

function TIGTagValue.Getvt_bool: bool;
begin
 result:=VarAsType(fValue,vt_bool);
end;

function TIGTagValue.Getvt_cy: currency;
begin
 result:=VarAsType(fValue,vt_cy);
end;

function TIGTagValue.Getvt_date: TDateTime;
begin
 result:=VarAsType(fValue,vt_date);
end;

function TIGTagValue.Getvt_i1: Shortint;
begin
  result:=VarAsType(fValue,vt_i1);
end;

function TIGTagValue.GetVt_i2: smallint;
begin
 result:=VarAsType(fValue,Vt_i2);
end;

function TIGTagValue.Getvt_i4: integer;
begin
 result:=VarAsType(fValue,vt_i4);
end;

function TIGTagValue.Getvt_r4: single;
begin
 result:=VarAsType(fValue,vt_r4);
end;

function TIGTagValue.Getvt_r8: double;
begin
 result:=VarAsType(fValue,vt_r8);
end;

function TIGTagValue.Getvt_ui1: byte;
begin
 result:=VarAsType(fValue,vt_ui1);
end;

function TIGTagValue.Getvt_ui2: Word;
begin
 result:=VarAsType(fValue,vt_ui2);
end;

function TIGTagValue.Getvt_ui4: longword;
begin
 result:=VarAsType(fValue,vt_ui4);
end;
 }

{ TIGDriverData }

function TIGDriverData.GetCount: integer;
begin
 result:=Length(fData);
end;

function TIGDriverData.GetData(index: integer): byte;
begin
// if index>High(fData) then
//  SetLength(fData,Length(fData)+(index+1));
 result:=fData[index];

end;

procedure TIGDriverData.SetCount(const Value: integer);
begin
 SetLength(fData,Value);
end;

procedure TIGDriverData.SetData(index: integer; const Value: byte);
begin
// if index>High(fData) then
//  SetLength(fData,Length(fData)+(index+1));
 fData[index]:=Value;

end;

{*******************************************************************************
 *                       Pascal Script procedures                              *
 *******************************************************************************}

procedure PS_TIGDriverData_GetData(self:TIGDriverData; var Value:byte; I:integer);
begin
 if i>=Self.Count then
  raise Exception.Create('TIGDriverData: Выход за пределы массива');
 Value:=self[i];
end;


procedure PS_TIGDriverData_GetCount(self:TIGDriverData; var Value:integer);
begin
 Value:=self.Count;
end;


procedure PS_TIGDriverData_GetResult(self:TIGDriverData; var Value:dword);
begin
 Value:=self.Result;
end;








{ THAEvent }

constructor THAEvent.Create(OID: TOID; NameObj, Props: string);
var p:PDataItem2;
    Proxy:THAEvent_Proxy;
begin
  inherited Create(nil,oid,ClassEvent,NameObj);
  Proxy:=THAEvent_Proxy.Create;
  new(p);
  try
    fillchar(p^,sizeof(TDataItem2),0);
    p^.Name:=NameObj;
    p^.Props:=Props;
    Proxy.AddData(p);
    fDescription:=Proxy.Description;
    fSeverity:=Proxy.Severity;
    fOnCheckDefinition:=Proxy.OnCheckDefinition;
  finally
   dispose(p);
   Proxy.Free;
  end;

end;

destructor THAEvent.Destroy;
begin

  inherited;
end;

function THAEvent.GetTypeEvent: dword;
begin
 if Length(fChilds)=0 then
  result:=OPC_SIMPLE_EVENT
 else
  result:=OPC_CONDITION_EVENT;
end;

{ TIGTags }

procedure TIGTags.Add(Tag: TIGTag);
begin
 fList.Add(Tag);
end;

procedure TIGTags.Clear;
var i:integer;
begin
 if fKillTagsOnDestroy then
  for i:=0 to fList.Count-1 do
    THABaseObj(fList[i]).Free;
  fList.clear;
  fFilterList.Clear;
  fFiltered:=false;
end;

constructor TIGTags.Create(KillTagsOnDestroy:boolean);
begin
 inherited Create;
 fKillTagsOnDestroy:=KillTagsOnDestroy;
 fList:=TList.Create;
 fFilterList:=TList.Create;
 fFiltered:=false;
end;

destructor TIGTags.Destroy;
begin
  clear;
  fList.Free;
  fFilterList.Free;
  inherited;
end;

function TIGTags.GetCount: integer;
begin
 if fFiltered then
  result:=fFilterList.Count
 else
  result:=fList.Count;
end;

function TIGTags.GetTag(index: integer): TIGTag;
begin
 result:=nil;
 if (index<0) then exit;
 if fFiltered and (index>=fFilterList.count) then exit;
 if (not fFiltered) and (index>=fList.count) then exit;
 if fFiltered then
  result:=fFilterList[index]
 else
  result:=fList[index];
end;



procedure TIGTags.QSort(SortList:TList; L, R: Integer);
var
  I, J: Integer;
  P, T: TIGTag;
  ExecError:boolean;
begin
  repeat
    I := L;
    J := R;
    P := SortList[(L + R) shr 1];
    repeat
      while fFilterObj.ExecSort(SortList[I], P,ExecError)<0 do
        Inc(I);
      while fFilterObj.ExecSort(SortList[J], P,ExecError)>0 do
        Dec(J);
      if I <= J then
      begin
        T := SortList[I];
        SortList[I] := SortList[J];
        SortList[J] := T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then
      QSort(SortList, L, J);
    L := I;
  until I >= R;

end;

procedure TIGTags.SetFilter(const Value: string);
begin
  fFilter := Value;
  fFiltered:=false;

end;

procedure TIGTags.SetFiltered(const Value: boolean);
var i:integer;
    res:boolean;
begin
  if fFiltered=Value then exit;
  fFilterList.Clear;
  fFiltered := Value;
  if not fFiltered then exit;
  if fFilterObj=nil then exit;
  if not fFilterObj.SetScript(fFilter,ts_Filter) then exit;


  for i:=0 to fList.Count-1 do
   begin
    res:=fFilterObj.ExecFilter(fList[i],fFiltered);
    if not fFiltered then break;
    if res then
     fFilterList.Add(fList[i]);
   end;

  if not fFiltered then
   fFilterList.Clear;

end;

procedure TIGTags.SetSorted(const Value: boolean);
var l:TList;
begin
  if fSorted=Value then exit;
  fSorted := Value;
  if not fSorted then exit;
  if fFilterObj=nil then exit;
  if not fFilterObj.SetScript(fSortScript,ts_Sort) then exit;

  if fFiltered then
   l:=fFilterList
  else
   l:=fList;

  QSort(L,0,L.Count-1);

{  for i:=0 to fList.Count-1 do
   begin
    fFiltered:=fFilterObj.Exec(fList[i],fSorted);
    if not fFiltered then break;
    if res then
     fFilterList.Add(fList[i]);
   end;
 }


end;

procedure TIGTags.SetSortScript(const Value: string);
begin
  fSortScript := Value;
  fSorted:=false;
end;

procedure TIGTags.SetTag(index: integer; const Value: TIGTag);
begin
 if (index<0) then exit;
 if fFiltered and (index>=fFilterList.count) then exit;
 if (not fFiltered) and (index>=fList.count) then exit;
 if fFiltered then
  fFilterList[index]:=value
 else
  fList[index]:=value;
end;

{*******************************************************************************
 *                       Pascal Script procedures                              *
 *******************************************************************************}

procedure PS_TIGTags_GetTag(self:TIGTags; var Value:TIGTag; I:integer);
begin
 if i>=Self.Count then
  raise Exception.Create('TIGTags: Выход за пределы массива');

 value:=self.Tags[i];
end;

procedure PS_TIGTags_GetCount(self:TIGTags; var Value:integer);
begin
 value:=self.Count;
end;

procedure PS_TIGTags_GetFilter(self:TIGTags; var Value:string);
begin
 value:=self.Filter;
end;

procedure PS_TIGTags_SetFilter(self:TIGTags; const Value:string);
begin
 self.Filter:=value;
end;


procedure PS_TIGTags_GetFiltered(self:TIGTags; var Value:boolean);
begin
 value:=self.Filtered;
end;

procedure PS_TIGTags_SetFiltered(self:TIGTags; const Value:boolean);
begin
 self.Filtered:=value;
end;


procedure PS_TIGTags_GetSortScript(self:TIGTags; var Value:string);
begin
 value:=self.SortScript;
end;

procedure PS_TIGTags_SetSortScript(self:TIGTags; const Value:string);
begin
 self.SortScript:=value;
end;


procedure PS_TIGTags_GetSorted(self:TIGTags; var Value:boolean);
begin
 value:=self.Sorted;
end;

procedure PS_TIGTags_SetSorted(self:TIGTags; const Value:boolean);
begin
 self.Sorted:=value;
end;



{ TIGConverter }


function TIGConverter.GetBits(index: byte): boolean;
begin

end;

function TIGConverter.GetBytes(index: byte): byte;
begin
 result:=0;
 if (index<0) or (index>7) then exit;
 if fpValue=nil then exit;
 result:=fcr.asArrayByte[index];
end;

function TIGConverter.GetTag: TIGTag;
begin

end;

procedure TIGConverter.SetBits(index: byte; const Value: boolean);
begin

end;

procedure TIGConverter.SetBytes(index: byte; const Value: byte);
begin
 if (index<0) or (index>7) then exit;
 if fpValue=nil then exit;

 fcr.asArrayByte[index]:=Value;

 case fType of
  vt_i1   :fpValue^:=fcr.asvt_i1;
  vt_ui1  :fpValue^:=fcr.asvt_ui1;

  vt_i2   :fpValue^:=fcr.asvt_i2;
  vt_ui2  :fpValue^:=fcr.asvt_ui2;

  vt_i4   :fpValue^:=fcr.asvt_i4;
  vt_ui4  :fpValue^:=fcr.asvt_ui4;

  vt_r4   :fpValue^:=fcr.asvt_r4;
  vt_r8   :fpValue^:=fcr.asvt_r8;

  vt_cy   :fpValue^:=fcr.asvt_cy;

  vt_date :fpValue^:=fcr.asvt_date;

//  vt_bstr :cr.asvt_i1:=fv;

  vt_bool :fpValue^:=fcr.asvt_bool;
  else
   exit;
 end;

// result:=cr.asArrayByte[index];


end;


procedure TIGConverter.SetTag(const Value: TIGTag);
begin

end;

procedure TIGConverter.SetValue(var Value: Variant);
begin
 fpValue:=nil;
 if not (varType(Value) in [vt_i2..vt_r8,vt_cy,vt_date,vt_bool,vt_i1..vt_ui4]) then
   raise Exception.Create('Массивы не поддерживаются');

 fpValue:=@Value;
 fType:=VarType(fpValue^);

 case fType of
  vt_i1   :fcr.asvt_i1:=fpValue^;
  vt_ui1  :fcr.asvt_ui1:=fpValue^;

  vt_i2   :fcr.asvt_i2:=fpValue^;
  vt_ui2  :fcr.asvt_ui2:=fpValue^;

  vt_i4   :fcr.asvt_i4:=fpValue^;
  vt_ui4  :fcr.asvt_ui4:=fpValue^;

  vt_r4   :fcr.asvt_r4:=fpValue^;
  vt_r8   :fcr.asvt_r8:=fpValue^;

  vt_cy   :fcr.asvt_cy:=fpValue^;

  vt_date :fcr.asvt_date:=fpValue^;

//  vt_bstr :cr.asvt_i1:=fv;

  vt_bool :fcr.asvt_bool:=fpValue^;
  else
   exit;
 end;

end;

{*******************************************************************************
 *                       Pascal Script procedures                              *
 *******************************************************************************}

procedure PS_TIGConverter_GetBytes(self:TIGConverter; var Value:byte; I:byte);
begin
 value:=self.Bytes[i];
end;

procedure PS_TIGConverter_SetBytes(self:TIGConverter; const Value:byte; I:byte);
begin
 self.Bytes[i]:=Value;
end;




{ TIGTimer }

function TIGTimer.CheckTimer: boolean;
var i:dword;
begin
 result:=false;
 if not fEnabled then exit;
 if OPCMan.CountServers=0 then exit;
 i:=GetTickCount;
 if Abs(i-fOldTime)>=fInterval then
  begin
   result:=true;
   fOldTime:=i;
  end;
end;

constructor TIGTimer.Create(OID: TOID; NameObj,Props: string);
var p:PDataItem2;
    Proxy:TIGTimer_Proxy;
begin
  inherited Create(nil,oid,ClassTimer,NameObj);
  Proxy:=TIGTimer_Proxy.Create;
  new(p);
  try
    fillchar(p^,sizeof(TDataItem2),0);
    p^.Name:=NameObj;
    p^.Props:=Props;
    Proxy.AddData(p);
    fEnabled:=Proxy.Enabled;
    fInterval:=Proxy.Interval;
    fOnTimer:=Proxy.OnTimer;
    fOldTime:=GetTickCount;
  finally
   dispose(p);
   Proxy.Free;
  end;
end;


{*******************************************************************************
 *                       Pascal Script procedures                              *
 *******************************************************************************}

procedure PS_TIGTimer_GetEnabled(self:TIGTimer; var Value:boolean);
begin
 value:=self.Enabled;
end;

procedure PS_TIGTimer_GetInterval(self:TIGTimer; var Value:dword);
begin
 value:=self.Interval;
end;













procedure SIRegisterHAOBJ(CL: TPSPascalCompiler);
begin
 RegisterDateTimeLibrary_C(CL);
 SIRegisterHAFunc(CL);

 Cl.AddType('DWORD',btU32);
 Cl.AddDelphiFunction('function makeword(bLow,bHigh:byte):word;');
 Cl.AddDelphiFunction('function makelong(bLow,bHigh:word):dword;');
// Cl.AddDelphiFunction('function loword(dwValue:dword):word;');


 cl.AddConstantN('OPC_QUALITY_BAD',                      'word').Value.tu16 := $00;
 cl.AddConstantN('OPC_QUALITY_UNCERTAIN',                'word').Value.tu16 := $40;
 cl.AddConstantN('OPC_QUALITY_GOOD',                     'word').Value.tu16 := $C0;

 cl.AddConstantN('OPC_QUALITY_CONFIG_ERROR',             'word').Value.tu16 := $04;
 cl.AddConstantN('OPC_QUALITY_NOT_CONNECTED',            'word').Value.tu16 := $08;
 cl.AddConstantN('OPC_QUALITY_DEVICE_FAILURE',           'word').Value.tu16 := $0C;
 cl.AddConstantN('OPC_QUALITY_SENSOR_FAILURE',           'word').Value.tu16 := $10;
 cl.AddConstantN('OPC_QUALITY_LAST_KNOWN',               'word').Value.tu16 := $14;
 cl.AddConstantN('OPC_QUALITY_COMM_FAILURE',             'word').Value.tu16 := $18;
 cl.AddConstantN('OPC_QUALITY_OUT_OF_SERVICE',           'word').Value.tu16 := $1C;
 cl.AddConstantN('OPC_QUALITY_WAITING_FOR_INITIAL_DATA', 'word').Value.tu16 := $20;



 with CL.AddClassN(CL.FindClass('TObject'), 'TIGProp') do
  begin
    RegisterProperty('VALUE', 'VARIANT', iptr);

    RegisterProperty('DATATYPE', 'WORD', iptr);
    RegisterProperty('UNIQUEVALUE', 'BOOLEAN', iptr);
    RegisterProperty('ID', 'DWORD', iptr);

    RegisterProperty('VALUEASARRAY', 'VARIANT INTEGER', iptr);
    RegisterMethod('FUNCTION VALUEISARRAY:BOOLEAN');

  end;

 with CL.AddClassN(CL.FindClass('TObject'), 'TIGVQT') do
  begin
    RegisterProperty('VALUE', 'VARIANT', iptr);
    RegisterProperty('VALUEASARRAY', 'VARIANT INTEGER', iptr);
    RegisterProperty('VALUEASARRAYCOUNT', 'INTEGER', iptr);
    RegisterMethod('FUNCTION VALUEISARRAY:BOOLEAN');
  end;


 with CL.AddClassN(CL.FindClass('TObject'), 'TIGTag') do
  begin
    RegisterProperty('OLDVALUE', 'VARIANT', iptr);
    RegisterProperty('NEWVALUE', 'VARIANT', iptrw);

    RegisterProperty('OLDVALUEASARRAY', 'VARIANT INTEGER', iptr);
    RegisterProperty('OLDVALUEASARRAYCOUNT', 'INTEGER', iptr);
    RegisterProperty('NEWVALUEASARRAY', 'VARIANT INTEGER', iptrw);
    RegisterProperty('NEWVALUEASARRAYCOUNT', 'INTEGER', iptr);

    RegisterProperty('OLDQUALITY', 'WORD', iptr);
    RegisterProperty('NEWQUALITY', 'WORD', iptrw);

    RegisterProperty('DATATYPE', 'WORD', iptr);

    RegisterProperty('ISREADABLE', 'BOOLEAN', iptr);
    RegisterProperty('ISWRITEABLE', 'BOOLEAN', iptr);
    RegisterProperty('ISSTORED', 'BOOLEAN', iptr);
    RegisterProperty('NAME', 'STRING', iptr);


    RegisterProperty('PROP', 'TIGProp INTEGER', iptr);
    RegisterProperty('COUNTPROPS', 'INTEGER', iptr);
    RegisterMethod('FUNCTION PROPEXISTS(ID:WORD):BOOLEAN');
    RegisterMethod('FUNCTION VALUEISARRAY:BOOLEAN');

//    if TypeScript=ts_OnWriteTag then
    RegisterProperty('VQT', 'TIGVQT', iptr);
   // RegisterProperty('RESULT','INTEGER',iptrw);
  end;

 with CL.AddClassN(CL.FindClass('TObject'), 'TIGTIMER') do
  begin
    RegisterProperty('ENABLED', 'BOOLEAN', iptr);
    RegisterProperty('INTERVAL', 'DWORD', iptr);
  end;

 with CL.AddClassN(CL.FindClass('TObject'), 'TIGCommand') do
  begin
    RegisterProperty('DATA', 'BYTE INTEGER', iptrw);
    SetDefaultPropery('DATA');
    RegisterProperty('COUNT', 'INTEGER', iptrw);
    RegisterProperty('PRIORITY','WORD',iptrw);
    RegisterProperty('NOCOMMAND','STRING',iptr);
    RegisterMethod('procedure Run;');
 //   RegisterMethod('procedure RunPeriodic;');
  end;

{ with CL.AddClassN(CL.FindClass('TObject'), 'THAPSCommand') do
  begin
    RegisterProperty('DATA', 'BYTE INTEGER', iptrw);
    SetDefaultPropery('DATA');
    RegisterProperty('COUNT', 'INTEGER', iptrw);
    RegisterProperty('RESULT', 'CARDINAL', iptr);
  end;
 }
 with CL.AddClassN(CL.FindClass('TObject'), 'TIGDriverData') do
  begin
    RegisterProperty('DATA', 'BYTE INTEGER', iptr);
    SetDefaultPropery('DATA');
    RegisterProperty('COUNT', 'INTEGER', iptr);
    RegisterProperty('RESULT', 'CARDINAL', iptr);
  end;


 with CL.AddClassN(CL.FindClass('TObject'), 'TIGTags') do
  begin
   RegisterProperty('TAG', 'TIGTag INTEGER', iptr);
   SetDefaultPropery('TAG');
   RegisterProperty('COUNT', 'INTEGER', iptr);
   RegisterProperty('FILTER', 'STRING', iptrw);
   RegisterProperty('FILTERED', 'BOOLEAN', iptrw);

   RegisterProperty('SORTSCRIPT', 'STRING', iptrw);
   RegisterProperty('SORTED', 'BOOLEAN', iptrw);
  end;




 with CL.AddClassN(CL.FindClass('TObject'), 'TIGDevice') do
  begin
    RegisterProperty('TAGS', 'TIGTags', iptr);
    RegisterProperty('ADDRESS','STRING',iptrw);
    RegisterProperty('PARAM','DWORD',iptrw);
    RegisterProperty('TEMPLATENAME','STRING',iptr);
//    RegisterProperty('TAG', 'TIGTag INTEGER', iptrw);
//    RegisterProperty('COUNTTAGS', 'INTEGER', iptr);
  end;

 with CL.AddClassN(CL.FindClass('TObject'), 'TIGConverter') do
  begin
    RegisterProperty('BYTES', 'BYTE BYTE', iptrw);
    RegisterMethod('PROCEDURE SETVALUE(VAR VALUE:VARIANT);');
  end;

 Cl.AddUsedVariableN('IGCONVERTER','TIGConverter');
// Sender.AddRegisteredVariable('IGCONVERTER','TIGConverter');

end;


procedure RIRegisterHAOBJ(cl: TPSRuntimeClassImporter; se: TPSExec);
begin

 RegisterDateTimeLibrary_R(Se);
 RIRegisterHAFunc(cl,se);

 SE.RegisterDelphiFunction(@MakeWord, 'MAKEWORD', cdRegister);
 SE.RegisterDelphiFunction(@MakeLong, 'MAKELONG', cdRegister);

 //SE.RegisterDelphiFunction(@windows.LOWORD, 'LOWORD', cdRegister);


 with CL.Add(TIGProp) do
 begin
  RegisterPropertyHelper(@PS_TIGProp_GetValue, nil, 'VALUE');
  RegisterPropertyHelper(@PS_TIGProp_GetUniqueValue, nil, 'UNIQUEVALUE');
  RegisterPropertyHelper(@PS_TIGProp_GetTypeProp, nil, 'DATATYPE');
  RegisterPropertyHelper(@PS_TIGProp_GetPropID, nil, 'ID');
  RegisterPropertyHelper(@PS_TIGProp_GetValueAsArray, nil, 'VALUEASARRAY');
  RegisterMethod(@TIGProp.valueisarray,'VALUEISARRAY');
 end;


 with CL.Add(TIGVQT) do
 begin
  RegisterPropertyHelper(@PS_TIGVQT_GetValue, nil, 'VALUE');
  RegisterPropertyHelper(@PS_TIGVQT_GetValueAsArray, nil, 'VALUEASARRAY');
  RegisterPropertyHelper(@PS_TIGVQT_GetValueAsArrayCount,nil, 'VALUEASARRAYCOUNT');
  RegisterMethod(@TIGVQT.valueisarray,'VALUEISARRAY');
 end;

 with CL.Add(TIGTag) do
 begin
  RegisterPropertyHelper(@PS_TIGTag_GetNewValue, @PS_TIGTag_SetNewValue, 'NEWVALUE');
  RegisterPropertyHelper(@PS_TIGTag_GetOldValue, nil, 'OLDVALUE');

  RegisterPropertyHelper(@PS_TIGTag_GetNewValueAsArray, @PS_TIGTag_SetNewValueAsArray, 'NEWVALUEASARRAY');
  RegisterPropertyHelper(@PS_TIGTag_GetNewValueAsArrayCount,nil,'NEWVALUEASARRAYCOUNT');


  RegisterPropertyHelper(@PS_TIGTag_GetOldValueAsArray, nil, 'OLDVALUEASARRAY');
  RegisterPropertyHelper(@PS_TIGTag_GetOldValueAsArrayCount,nil,'OLDVALUEASARRAYCOUNT');


  RegisterPropertyHelper(@PS_TIGTag_GetOldQuality, nil, 'OLDQUALITY');
  RegisterPropertyHelper(@PS_TIGTag_GetNewQuality, @PS_TIGTag_SetNewQuality, 'NEWQUALITY');

  RegisterPropertyHelper(@PS_TIGTag_GetDataType, nil, 'DATATYPE');

  RegisterPropertyHelper(@PS_TIGTag_GetIsReadable, nil, 'ISREADABLE');
  RegisterPropertyHelper(@PS_TIGTag_GetIsWriteable, nil, 'ISWRITEABLE');
  RegisterPropertyHelper(@PS_TIGTag_GetIsStored, nil, 'ISSTORED');
  RegisterPropertyHelper(@PS_TIGTag_GetName, nil, 'NAME');


  RegisterPropertyHelper(@PS_TIGTag_GetCountProps, nil, 'COUNTPROPS');
  RegisterPropertyHelper(@PS_TIGTag_GetProp, nil, 'PROP');
  RegisterMethod(@TIGTag.PropExists,'PROPEXISTS');
  RegisterMethod(@TIGTag.valueisarray,'VALUEISARRAY');


  RegisterPropertyHelper(@PS_TIGTag_GetVQT,nil,'VQT');
//  RegisterPropertyHelper(@PS_TIGTag_GetResult,@PS_TIGTag_SetResult,'RESULT');
 end;

{ with CL.Add(TIGTagArray) do
 begin
  RegisterPropertyHelper(@PS_TIGTagArray_GetNewValue, @PS_TIGTag_SetNewValue, 'NEWVALUE');
  RegisterPropertyHelper(@PS_TIGTagArray_GetOldValue, nil, 'OLDVALUE');
  RegisterPropertyHelper(@PS_TIGTagArray_GetCountProps, nil, 'COUNTPROPS');
  RegisterPropertyHelper(@PS_TIGTagArray_GetProp, nil, 'PROP');
  RegisterMethod(@TIGTagArray.PropExists,'PROPEXISTS');
 end;   }

 with cl.Add(TIGTimer) do
  begin
   RegisterPropertyHelper(@PS_TIGTimer_GetEnabled,nil,'ENABLED');
   RegisterPropertyHelper(@PS_TIGTimer_GetInterval,nil,'INTERVAL');
  end;


 with cl.Add(TIGTags) do
  begin
   RegisterPropertyHelper(@PS_TIGTags_GetTag,nil,'TAG');
   RegisterPropertyHelper(@PS_TIGTags_GetCount,nil,'COUNT');
   RegisterPropertyHelper(@PS_TIGTags_GetFilter,@PS_TIGTags_SetFilter,'FILTER');
   RegisterPropertyHelper(@PS_TIGTags_GetFiltered,@PS_TIGTags_SetFiltered,'FILTERED');

   RegisterPropertyHelper(@PS_TIGTags_GetSortScript,@PS_TIGTags_SetSortScript,'SORTSCRIPT');
   RegisterPropertyHelper(@PS_TIGTags_GetSorted,@PS_TIGTags_SetSorted,'SORTED');
  end;

 with cl.Add(TIGCommand) do
  begin
   RegisterPropertyHelper(@PS_TIGCommand_GetData,@PS_TIGCommand_SetData,'DATA');
   RegisterPropertyHelper(@PS_TIGCommand_GetCount,@PS_TIGCommand_SetCount,'COUNT');
   RegisterPropertyHelper(@PS_TIGCommand_GetPriority,@PS_TIGCommand_SetPriority,'PRIORITY');
   RegisterPropertyHelper(@PS_TIGCommand_GetNoCommand,nil,'NOCOMMAND');
   RegisterMethod(@TIGCommand.RUN,'RUN');
 //  RegisterMethod(@TIGCommand.RUNPERIODIC,'RUNPERIODIC');
  end;

{ with cl.Add(THAPSCommand) do
  begin
   RegisterPropertyHelper(@PS_THAPSCommand_GetData,@PS_THAPSCommand_SetData,'DATA');
   RegisterPropertyHelper(@PS_THAPSCommand_GetCount,@PS_THAPSCommand_SetCount,'COUNT');
   RegisterPropertyHelper(@PS_THAPSCommand_GetResult,nil,'RESULT');
  end;
 }
 with cl.Add(TIGDriverData) do
  begin
   RegisterPropertyHelper(@PS_TIGDriverData_GetData,nil,'DATA');
   RegisterPropertyHelper(@PS_TIGDriverData_GetCount,nil,'COUNT');
   RegisterPropertyHelper(@PS_TIGDriverData_GetResult,nil,'RESULT');
  end;


 with cl.Add(TIGDevice) do
  begin
   RegisterPropertyHelper(@PS_TIGDevice_GetAddress,@PS_TIGDevice_SetAddress,'ADDRESS');
   RegisterPropertyHelper(@PS_TIGDevice_GetParam,@PS_TIGDevice_SetParam,'PARAM');
   RegisterPropertyHelper(@PS_TIGDevice_GetTags,nil,'TAGS');
   RegisterPropertyHelper(@PS_TIGDevice_GetTemplateName,nil,'TEMPLATENAME');
  end;

 with cl.Add(TIGConverter) do
  begin
   RegisterPropertyHelper(@PS_TIGConverter_GetBytes,@PS_TIGConverter_SetBytes,'BYTES');
   RegisterMethod(@TIGConverter.SETVALUE,'SETVALUE');
  end;

end;






procedure TIGTimer.SetEnabled(const Value: boolean);
begin
 if fEnabled=Value then exit;
 fEnabled := Value;
 if fEnabled then
  fOldTime:=GetTickCount;
end;

{ TIGTagHDA }
{$IFDEF HDAINTERFACE}

constructor TIGTagHDA.Create(OID: TOID; NameObj, Props: string);
var p:PDataItem2;
    Proxy:TIGTagHDA_Proxy;
begin
  inherited Create(nil,oid,ClassTagHDA,NameObj);
  Proxy:=TIGTagHDA_Proxy.Create;
  new(p);
  try
    fillchar(p^,sizeof(TDataItem2),0);
    p^.Name:=NameObj;
    p^.Props:=Props;
    Proxy.AddData(p);
    fReadable:=Proxy.Readable;
    fWriteable:=Proxy.Writeable;
  finally
   dispose(p);
   Proxy.Free;
  end;
end;

destructor TIGTagHDA.Destroy;
begin

  inherited;
end;

{$ENDIF}
end.
