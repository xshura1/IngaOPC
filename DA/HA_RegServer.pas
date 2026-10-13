unit HA_RegServer;

interface
{$I IngaOPC.inc}

uses Windows,Messages,SysUtils,Classes,Graphics,Controls,Forms,Dialogs,StdCtrls,
     IngaOPC_TLB,Registry,OPCDA,OPC_AE,{$IFDEF HDAINTERFACE} HAHDAIMP,{$ENDIF} OPCHDA;

type
 THATypeServer=(hats_DA,hats_AE,hats_HDA);


procedure RegisterTheServer(TS:THATypeServer; AsService:boolean);
procedure UnRegisterTheServer(TS:THATypeServer);

implementation
uses ComObj,ComCat;

const
 FmtSrvDescr='IngaOPC%s Server';
 FmtSrvName='IngaOPC%s Server';
 ExeName='IngaOPC.exe';
procedure RegisterTheServer(TS:THATypeServer; AsService:boolean);
var
 aReg:TRegistry;
 hr:HRESULT;
 myCLSIDString,SrvDescr,SrvName:string;
begin

 case TS of
  hats_DA: begin
            myCLSIDString:=GUIDToString(CLASS_HADAOBJ);
            SrvDescr:=format(FmtSrvDescr,['DA']);
            SrvName:=format(FmtSrvName,['DA']);
            hr:=CreateComponentCategory(CATID_OPCDAServer20,StringToLPOleStr(SrvDescr));
            if hr <> 0 then exit;
            hr:=RegisterCLSIDInCategory(CLASS_HADAOBJ,CATID_OPCDAServer20);
            if hr <> 0 then exit;
           end;

 {$IFDEF HDAINTERFACE}
  hats_HDA:begin
            myCLSIDString:=GUIDToString(CLASS_HADAOBJ);
            SrvDescr:=format(FmtSrvDescr,['HDA']);
            SrvName:=format(FmtSrvName,['HDA']);
            hr:=CreateComponentCategory(CATID_OPCHDAServer10,StringToLPOleStr(SrvDescr));
            if hr <> 0 then exit;
            hr:=RegisterCLSIDInCategory(CLASS_HAHDAOBJ,CATID_OPCHDAServer10);
            if hr <> 0 then exit;
           end;
 {$ENDIF}

  hats_AE: begin
            myCLSIDString:=GUIDToString(CLASS_HAAEOBJ);
            SrvDescr:=format(FmtSrvDescr,['AE']);
            SrvName:=format(FmtSrvName,['AE']);
            hr:=CreateComponentCategory(OPCEventServerCATID,StringToLPOleStr(SrvDescr));
            if hr <> 0 then exit;
            hr:=RegisterCLSIDInCategory(CLASS_HAAEOBJ,OPCEventServerCATID);
            if hr <> 0 then exit;
           end;

 end;

 {aReg:=nil;
 try
  aReg:=TRegistry.Create;
  aReg.RootKey:=HKEY_CLASSES_ROOT;
  aReg.OpenKey(SrvName,true);
  aReg.WriteString('',SrvDescr);
  aReg.OpenKey('\'+SrvName+'\Clsid',true);
  aReg.WriteString('',myCLSIDString);

  if AsService then
   begin
    aReg.OpenKey('\AppID\'+myCLSIDString,true);
    aReg.WriteString('LocalService','IngaOPCServer');
    aReg.WriteString('ServiceParameters','-Service');
    aReg.WriteString('RunAs','Interactive User');
   end;

  aReg.OpenKey(SrvName+'\OPC',true);

  aReg.OpenKey('\CLSID\'+myCLSIDString,true);
  aReg.WriteString('',SrvDescr);

  aReg.OpenKey('\CLSID\'+myCLSIDString+'\ProgID',true);
  aReg.WriteString('',SrvName);

 finally
  aReg.CloseKey;
  aReg.Free;
 end;
  }

 aReg:=nil;
 try
  aReg:=TRegistry.Create;
  aReg.RootKey:=HKEY_CLASSES_ROOT;
  aReg.OpenKey(SrvName,true);
  aReg.WriteString('',SrvDescr);
 finally
  aReg.CloseKey;
  aReg.Free;
 end;

 aReg:=nil;
 try
  aReg:=TRegistry.Create;
  aReg.RootKey:=HKEY_CLASSES_ROOT;
  aReg.OpenKey(SrvName+'\Clsid',true);
  aReg.WriteString('',myCLSIDString);

  if AsService then
   begin
    aReg.OpenKey('\AppID\'+myCLSIDString,true);
    aReg.WriteString('LocalService','IngaOPCServer');
    aReg.WriteString('ServiceParameters','-Service');
    aReg.WriteString('RunAs','Interactive User');
    aReg.OpenKey('\AppID\'+ExeName,true);
    aReg.WriteString('',myCLSIDString);


   end;

 { if AsService then
   begin
    aReg.WriteString('ServiceParameters','-Service');
    aReg.WriteString('LocalService','IngaOPCServer');
   end;
  }
 finally
  aReg.CloseKey;
  aReg.Free;
 end;

aReg:=nil;
 try
  aReg:=TRegistry.Create;
  aReg.RootKey:=HKEY_CLASSES_ROOT;
  aReg.OpenKey(SrvName+'\OPC',true);
 finally
  aReg.CloseKey;
  aReg.Free;
 end;



 aReg:=nil;
 try
  aReg:=TRegistry.Create;
  aReg.RootKey:=HKEY_CLASSES_ROOT;
  aReg.OpenKey('CLSID\'+myCLSIDString,true);
  aReg.WriteString('',SrvDescr);
  if AsService then
   aReg.WriteString('AppID',myCLSIDString);

 finally
  aReg.CloseKey;
  aReg.Free;
 end;

 aReg:=nil;
 try
  aReg:=TRegistry.Create;
  aReg.RootKey:=HKEY_CLASSES_ROOT;
  aReg.OpenKey('CLSID\'+myCLSIDString+'\ProgID',true);
  aReg.WriteString('',SrvName);
 finally
  aReg.CloseKey;
  aReg.Free;
 end;

end;

procedure UnRegisterTheServer(TS:THATypeServer);
var
 aReg:TRegistry;
 hr:HRESULT;
 myCLSIDString,SrvDescr,SrvName:string;
begin

 case TS of
  hats_DA: begin
            myCLSIDString:=GUIDToString(CLASS_HADAOBJ);
            SrvDescr:=format(FmtSrvDescr,['DA']);
            SrvName:=format(FmtSrvName,['DA']);
            hr:=UnCreateComponentCategory(CATID_OPCDAServer20,StringToLPOleStr(SrvDescr));
            if hr <> 0 then ;
            hr:=UnRegisterCLSIDInCategory(CLASS_HADAOBJ,CATID_OPCDAServer20);
            if hr <> 0 then ;
           end;

  {$IFDEF HDAINTERFACE}
  hats_HDA:begin
            myCLSIDString:=GUIDToString(CLASS_HADAOBJ);
            SrvDescr:=format(FmtSrvDescr,['HDA']);
            SrvName:=format(FmtSrvName,['HDA']);
            hr:=UnCreateComponentCategory(CATID_OPCHDAServer10,StringToLPOleStr(SrvDescr));
            if hr <> 0 then ;
            hr:=UnRegisterCLSIDInCategory(CLASS_HAHDAOBJ,CATID_OPCHDAServer10);
            if hr <> 0 then ;
           end;

  {$ENDIF}

  hats_AE: begin
            myCLSIDString:=GUIDToString(CLASS_HAAEOBJ);
            SrvDescr:=format(FmtSrvDescr,['AE']);
            SrvName:=format(FmtSrvName,['AE']);
            hr:=UnCreateComponentCategory(OPCEventServerCATID,StringToLPOleStr(SrvDescr));
            if hr <> 0 then ;
            hr:=UnRegisterCLSIDInCategory(CLASS_HAAEOBJ,OPCEventServerCATID);
            if hr <> 0 then ;
           end;

 end;



 aReg:=nil;
 try
  aReg:=TRegistry.Create;
  aReg.RootKey:=HKEY_CLASSES_ROOT;
  aReg.DeleteKey(SrvName);
  aReg.DeleteKey('\CLSID\'+myCLSIDString);
  aReg.DeleteKey('\AppID\'+myCLSIDString);
  aReg.DeleteKey('\AppID\'+ExeName);

 finally
  aReg.CloseKey;
  aReg.Free;
 end;




{ aReg:=nil;
 try
  aReg:=TRegistry.Create;
  aReg.RootKey:=HKEY_CLASSES_ROOT;
  aReg.DeleteKey('CLSID\'+myCLSIDString+'\ProgID');
 finally
  aReg.CloseKey;
  aReg.Free;
 end;

 aReg:=nil;
 try
  aReg:=TRegistry.Create;
  aReg.RootKey:=HKEY_CLASSES_ROOT;
  aReg.DeleteKey('CLSID\'+myCLSIDString);
  aReg.DeleteKey('\AppID\'+myCLSIDString);
 finally
  aReg.CloseKey;
  aReg.Free;
 end;

 aReg:=nil;
 try
  aReg:=TRegistry.Create;
  aReg.RootKey:=HKEY_CLASSES_ROOT;
  aReg.DeleteKey(SrvName+'\OPC');
 finally
  aReg.CloseKey;
  aReg.Free;
 end;


 aReg:=nil;
 try
  aReg:=TRegistry.Create;
  aReg.RootKey:=HKEY_CLASSES_ROOT;
  aReg.DeleteKey(SrvName+'\Clsid');
 finally
  aReg.CloseKey;
  aReg.Free;
 end;

 aReg:=nil;
 try
  aReg:=TRegistry.Create;
  aReg.RootKey:=HKEY_CLASSES_ROOT;
  aReg.DeleteKey(SrvName);
 finally
  aReg.CloseKey;
  aReg.Free;
 end; }


end;

end.
