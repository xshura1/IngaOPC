program IngaOPC;

{%ToDo 'IngaOPC.todo'}

uses
  FastMM4,
  SvcMgr,
  Forms,
  SysUtils,
  WinSvc,
  ActiveX,
  HA_Glav in 'HA_Glav.pas' {fmGlav},
  HA_OPCMan in 'HA_OPCMan.pas',
  HA_LOG in 'HA_LOG.pas',
  HA_Utils in 'HA_Utils.pas',
  HA_fmViewDriverData in 'HA_fmViewDriverData.pas' {fmViewDriverData},
  HA_DllManager in 'HA_DllManager.pas',
  HA_wmConst in 'HA_wmConst.pas',
  IngaOPC_TLB in 'IngaOPC_TLB.pas',
  OPCtypes in 'DA\OPCtypes.pas',
  HA_DAGROUP in 'DA\HA_DAGROUP.pas',
  HADAIMP in 'DA\HADAIMP.pas',
  OPCCOMN in 'DA\OPCCOMN.pas',
  OPCDA in 'DA\OPCDA.pas',
  ComCat in 'DA\comcat.pas',
  HA_RegServer in 'DA\HA_RegServer.pas',
  OpcError in 'DA\OPCerror.pas',
  HA_Enum in 'HA_Enum.pas',
  HA_ErrorCodes in 'DA\HA_ErrorCodes.pas',
  HA_fmViewCache in 'HA_fmViewCache.pas' {fmViewCache},
  HA_CustomFM2 in 'HA_CustomFM2.pas' {fmCustom2},
  HA_fmViewLog in 'HA_fmViewLog.pas' {fmViewLog},
  syncobjs,
  windows,
  HA_TYPES in 'Common\HA_TYPES.pas',
  HA_Classes in 'Common\HA_Classes.pas',
  MSXML_TLB in 'Common\MSXML_TLB.pas',
  HA_XMLData in 'Common\HA_XMLData.pas',
  ha_Explorer in 'Explorer\ha_Explorer.pas' {fmExplorer},
  ha_inspector in 'Explorer\ha_inspector.pas' {fmInspector},
  ha_listobject in 'Explorer\ha_listobject.pas' {fmListObject},
  ha_dockfm in 'Explorer\ha_dockfm.pas' {fmDock},
  HA_templateopendialog in 'HA_templateopendialog.pas' {fmTemplateOpenDialog},
  HA_fmViewDynList in 'HA_fmViewDynList.pas' {fmViewDynList},
  uConjoinHost in 'Explorer\uConjoinHost.pas' {ConjoinDockHost},
  Intf in 'dll\Intf.pas',
  HA_Messages in 'Explorer\HA_Messages.pas' {fmMessages},
  HAAEIMP in 'DA\HAAEIMP.pas' {HAAEOBJ: CoClass},
  OPC_AE in 'DA\OPC_AE.pas',
  HA_AEAreaBrowser in 'DA\HA_AEAreaBrowser.pas' {HAAEAreaBrowser: CoClass},
  HA_fmViewClients in 'HA_fmViewClients.pas' {fmViewClients},
  HA_ListVars in 'Explorer\HA_ListVars.pas' {fmListVars},
  HA_PSFunctions in 'Common\HA_PSFunctions.pas',
  HA_About in 'HA_About.pas' {fmAbout},
  HA_fmUnloader in 'HA_fmUnloader.pas' {fmUnloader},
  HA_StoredTags in 'HA_StoredTags.pas',
  HA_Filters in 'HA_Filters.pas',
  HA_fmGlobalParams in 'HA_fmGlobalParams.pas' {fmGlobalParams},
  HA_DynCommandMan in 'HA_DynCommandMan.pas',
  HA_fmEditArrayValue in 'HA_fmEditArrayValue.pas' {fmEditArrayValue},
  HA_InspectorProps in 'Explorer\HA_InspectorProps.pas' {fmInspectorProps},
  HA_fmDriverLinks in 'HA_fmDriverLinks.pas' {fmDriverLinks},
  HADABrowser in 'DA\HADABrowser.pas',
  HAHDAIMP in 'DA\HAHDAIMP.pas',
  OPCHDA in 'DA\OPCHDA.pas',
  HAHDABrowser in 'DA\HAHDABrowser.pas',
  HA_fmMemoDialog in 'Explorer\HA_fmMemoDialog.pas' {fmMemoDialog};

{$R *.TLB}

{$R *.res}
{$I IngaOPC.inc}



function Installing: Boolean;
begin
{ result:=false;
 if FindCmdLineSwitch('INSTALL',['-','\','/'], True) then
  begin
   result:=true;
   coInitialize(nil);
   RegisterTheServer(hats_DA,true);
  end;

 if FindCmdLineSwitch('UNINSTALL',['-','\','/'], True) then
  begin
   result:=true;
   coInitialize(nil);
   UnRegisterTheServer(hats_DA);
  end;}

  Result := FindCmdLineSwitch('INSTALL',['-','\','/'], True) or
            FindCmdLineSwitch('UNINSTALL',['-','\','/'], True);



end;

function StartService: Boolean;
var
  Mgr, Svc: Integer;
  UserName, ServiceStartName: string;
  Config: Pointer;
  Size: DWord;
begin
  Result := False;
  Mgr := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
  if Mgr <> 0 then
  begin
    Svc := OpenService(Mgr, PChar('IngaOPCServer'), SERVICE_ALL_ACCESS);
    Result := Svc <> 0;
    if Result then
    begin
      QueryServiceConfig(Svc, nil, 0, Size);
      Config := AllocMem(Size);
      try
        QueryServiceConfig(Svc, Config, Size, Size);
        ServiceStartName := PQueryServiceConfig(Config)^.lpServiceStartName;
        if CompareText(ServiceStartName, 'LocalSystem') = 0 then
          ServiceStartName := 'SYSTEM';
      finally
        Dispose(Config);
      end;
      CloseServiceHandle(Svc);
    end;
    CloseServiceHandle(Mgr);
  end;
  if Result then
  begin
    Size := 256;
    SetLength(UserName, Size);
    GetUserName(PChar(UserName), Size);
    SetLength(UserName, StrLen(PChar(UserName)));
    Result := CompareText(UserName, ServiceStartName) = 0;
  end;
end;

begin
  {$IFDEF FULLVERSION}
  Application.Title:='IngaOPC Server';
  {$ELSE}
  Application.Title:='IngaOPC Server (DEMO)';
  {$ENDIF}

  if not Installing then
  begin
    CreateMutex(nil, True, 'B9CBDC2D-AEFD-4779-A95E-758C39501DF6');
    if GetLastError = ERROR_ALREADY_EXISTS then
    begin
     {$IFDEF FULLVERSION}
       MessageBox(0, PChar('Сервер уже загружен'), 'IngaOPC Server', MB_ICONERROR);
     {$ELSE}
       MessageBox(0, PChar('Сервер уже загружен'), 'IngaOPC Server (DEMO)', MB_ICONERROR);
     {$ENDIF}
      Halt;
    end;
  end;

  if Installing or StartService then
  begin



    SvcMgr.Application.Initialize;
    IngaOPCService:= TIngaOPCService.CreateNew(SvcMgr.Application, 0);
    SvcMgr.Application.Title := 'IngaOPCDA Server';

    SvcMgr.Application.CreateForm(TfmGlav, fmGlav);
  SvcMgr.Application.Run;
  end
 else
  begin
    Forms.Application.ShowMainForm := False;
    Forms.Application.Initialize;
    Forms.Application.CreateForm(TfmGlav, fmGlav);
    fmGlav.Initialize(False);
    Forms.Application.Run;
  end;











{var CheckEvent:TEvent;

begin
  CheckEvent:= TEvent.Create( nil, false, true, 'B9CBDC2D-AEFD-4779-A95E-758C39501DF6' );
  If CheckEvent.WaitFor( 10 ) <> wrSignaled then
   begin
    MessageBox(0,'Сервер уже запущен','IngaOPC Server',MB_OK or MB_ICONSTOP or MB_APPLMODAL);
    //Application.Terminate;
   end
  else
   begin
    Application.Initialize;
    Application.Title := 'IngaOPC Server';
    Application.CreateForm(TfmGlav, fmGlav);
  Application.ShowMainForm:=False;
    Application.Run;
   end;   }
end.


