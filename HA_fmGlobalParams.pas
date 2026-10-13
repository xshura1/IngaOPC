unit HA_fmGlobalParams;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GsvObjectInspectorGrid, ExtCtrls,inifiles,GsvObjectInspectorTypes,
  StdCtrls;

type
   {$M+}
   THAGlobalParams=class(TObject)
    private
    fSection:string;

    fIOPCSyncIO_TimeLifeTransaction: dword;
    fIOPCShutdown_TimeOut: dword;
    fTimeOutCommitCache:dword;

    procedure LoadIni;
    procedure SaveIni;
    public
     constructor Create;
     destructor Destroy; override;
     procedure SaveParams;

    published
     // время жизни транзакции (по истечении которого происходит возврат)
     property IOPCSyncIO_TimeLifeTransaction:dword read fIOPCSyncIO_TimeLifeTransaction write fIOPCSyncIO_TimeLifeTransaction;

     // время на отключение клиента по интерфейсу IOPCShutdown
     property IOPCShutdown_TimeOut:dword read fIOPCShutdown_TimeOut write fIOPCShutdown_TimeOut;

     // время после которого происходит роллбак кэша
     property TimeOutCommitCache:dword read fTimeOutCommitCache write fTimeOutCommitCache;

   end;
   {$M-}

  THAGlobalParams_INFO = class(TGsvObjectInspectorTypeInfo)
  public
    class function  ChildrenInfo(Index: Integer):
                    PGsvObjectInspectorPropertyInfo; override;
  end;



  TfmGlobalParams = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    OI: TGsvObjectInspectorGrid;
    Panel3: TPanel;
    BtnOK: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OIEnumProperties(Sender: TObject;
      Index: Integer; out Info: PGsvObjectInspectorPropertyInfo);
    procedure OIGetIntegerValue(Sender: TObject;
      Info: PGsvObjectInspectorPropertyInfo; out Value: Integer);
    procedure OISetIntegerValue(Sender: TObject;
      Info: PGsvObjectInspectorPropertyInfo; const Value: Integer);
    procedure FormShow(Sender: TObject);
    procedure OIGetStringValue(Sender: TObject;
      Info: PGsvObjectInspectorPropertyInfo; out Value: String);
    procedure OISetStringValue(Sender: TObject;
      Info: PGsvObjectInspectorPropertyInfo; const Value: String);
  private
    { Private declarations }
    ObjectManager:   TGsvObjectInspectorObjectInfo;
  public
    { Public declarations }
  end;


var GlobalParams:THAGlobalParams;
implementation

{$R *.dfm}

{ THAGlobalParams }

constructor THAGlobalParams.Create;
begin
 inherited;
 fSection:='GlobalParams';
 LoadIni;
end;

destructor THAGlobalParams.Destroy;
begin
  SaveIni;
  inherited;
end;

procedure THAGlobalParams.LoadIni;
var ini:TIniFile;
begin
 ini:=TIniFile.Create(ChangeFileExt(ParamStr(0),'.ini'));
 try
  fIOPCSyncIO_TimeLifeTransaction:=Ini.ReadInteger(fSection,'IOPCSyncIO_TimeLifeTransaction',60000);
  fIOPCShutdown_TimeOut:=Ini.ReadInteger(fSection,'IOPCShutdown_TimeOut',10000);
  fTimeOutCommitCache:=ini.ReadInteger(fSection,'TimeOutCommitCache',20000);
 finally
  ini.Free;
 end;

end;

procedure THAGlobalParams.SaveIni;
var ini:TIniFile;
begin
 ini:=TIniFile.Create(ChangeFileExt(ParamStr(0),'.ini'));
 try
  Ini.WriteInteger(fSection,'IOPCSyncIO_TimeLifeTransaction',fIOPCSyncIO_TimeLifeTransaction);
  Ini.WriteInteger(fSection,'IOPCShutdown_TimeOut',fIOPCShutdown_TimeOut);
  ini.WriteInteger(fSection,'TimeOutCommitCache',fTimeOutCommitCache);
 finally
  ini.Free;
 end;

end;

procedure THAGlobalParams.SaveParams;
begin
 SaveIni;
end;


{ THAGlobalParams_INFO }

class function THAGlobalParams_INFO.ChildrenInfo(
  Index: Integer): PGsvObjectInspectorPropertyInfo;
const
  DSK: array[0..2] of TGsvObjectInspectorPropertyInfo = (
    ( Name: 'IOPCSyncIO_TimeLifeTransaction';   Caption: 'Таймаут для IOPCSyncIO (мс.)'; Kind: pkText),
    ( Name: 'IOPCShutdown_TimeOut';  Caption: 'Таймаут для IOPCShutdown (мс.)'; Kind: pkText),
    ( Name: 'TimeOutCommitCache';    Caption: 'Таймаут кэша (мс.)'; Kind: pkText)
    );
begin
  if Index <= High(DSK) then Result := @DSK[Index]
  else                       Result := nil;


end;

procedure TfmGlobalParams.FormCreate(Sender: TObject);
begin
 ObjectManager:=TGsvObjectInspectorObjectInfo.Create;
end;

procedure TfmGlobalParams.FormDestroy(Sender: TObject);
begin
 ObjectManager.Free;
end;

procedure TfmGlobalParams.OIEnumProperties(
  Sender: TObject; Index: Integer;
  out Info: PGsvObjectInspectorPropertyInfo);
begin
 Info := ObjectManager.PropertyInfo(Index);
end;

procedure TfmGlobalParams.OIGetIntegerValue(
  Sender: TObject; Info: PGsvObjectInspectorPropertyInfo;
  out Value: Integer);
begin
 try
    Value := ObjectManager.GetIntegerValue(Info);
  except
  //  on E: Exception do
  //    StatusMessage('Error: ' + E.Message);
  end;

end;

procedure TfmGlobalParams.OISetIntegerValue(
  Sender: TObject; Info: PGsvObjectInspectorPropertyInfo;
  const Value: Integer);
begin
try
 ObjectManager.SetIntegerValue(Info, Value);
except
  // on E: Exception do
   //  StatusMessage('Error: ' + E.Message);
end;

end;

procedure TfmGlobalParams.FormShow(Sender: TObject);
begin
 ObjectManager.TheObject :=GlobalParams;
 if Assigned(ObjectManager.TheObject) then
   OI.NewObject
 else
  begin
   OI.Clear;
  // FreeAndNil(Proxy);
  end;

end;

procedure TfmGlobalParams.OIGetStringValue(Sender: TObject;
  Info: PGsvObjectInspectorPropertyInfo; out Value: String);
begin
 try
    Value := ObjectManager.GetStringValue(Info);
  except
   // on E: Exception do
   //   StatusMessage('Error: ' + E.Message);
  end;

end;

procedure TfmGlobalParams.OISetStringValue(Sender: TObject;
  Info: PGsvObjectInspectorPropertyInfo; const Value: String);
begin
  try
    ObjectManager.SetStringValue(Info, Value);

  except
    //on E: Exception do
    //  ShowMessage('Error: ' + E.Message);
  end;
end;

initialization
 GlobalParams:=THAGlobalParams.Create;
 GsvRegisterTypesInfo([THAGlobalParams_INFO]);
finalization
 GlobalParams.Free;
end.
