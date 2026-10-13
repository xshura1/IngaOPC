unit ha_Explorer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees,ha_listObject, Menus, ExtCtrls,ha_inspector,
  SynEdit, ComCtrls, ToolWin, ImgList,ha_customfm2, StdCtrls,regexpr,
  SynEditHighlighter, SynHighlighterPas, uPSComponent,uPSCompiler,
  uPSRuntime,uPSDebugger,ha_types, SynEditMiscClasses, SynEditSearch,ha_messages,uConjoinHost,
  Buttons,ha_xmldata,ha_wmconst,ha_classes,ha_ListVars,
  SynCompletionProposal,SynEditTypes,shellapi;

type

  TfmExplorer = class(TfmCustom2)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    PanelLeft: TPanel;
    SplitterLeft: TSplitter;
    PanelRight: TPanel;
    SplitterRight: TSplitter;
    PanelCenter: TPanel;
    N3: TMenuItem;
    ToolBar1: TToolBar;
    BtnNew: TToolButton;
    ED: TSynEdit;
    ImageList1: TImageList;
    BtnSave: TToolButton;
    SynPasSyn1: TSynPasSyn;
    Panel1: TPanel;
    ToolBar2: TToolBar;
    BtnRunScript: TToolButton;
    BtnStepScript: TToolButton;
    ToolButton3: TToolButton;
    PS: TPSScript;
    BtnOpen: TToolButton;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    OD: TOpenDialog;
    SD: TSaveDialog;
    SynEditSearch1: TSynEditSearch;
    PanelBottom: TPanel;
    SplitterBottom: TSplitter;
    N10: TMenuItem;
    Panel2: TPanel;
    ESearch: TEdit;
    BtnSearch: TSpeedButton;
    N11: TMenuItem;
    SCP: TSynCompletionProposal;
    ToolButton1: TToolButton;
    BtnCompileTemplate: TToolButton;
    Timer1: TTimer;
    StatusBar1: TStatusBar;
    imglGutterGlyphs: TImageList;
    BtnDebug: TToolButton;
    BtnAddBreakPoint: TToolButton;
    BtnDelBreakPoint: TToolButton;
    imglActions: TImageList;
    procedure FormDestroy(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure PanelLeftDockDrop(Sender: TObject; Source: TDragDockObject;
      X, Y: Integer);
    procedure PanelLeftUnDock(Sender: TObject; Client: TControl;
      NewTarget: TWinControl; var Allow: Boolean);
    procedure N3Click(Sender: TObject);
    procedure PanelLeftDockOver(Sender: TObject; Source: TDragDockObject;
      X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure PanelRightDockOver(Sender: TObject; Source: TDragDockObject;
      X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure BtnNewClick(Sender: TObject);
    procedure PanelLeftResize(Sender: TObject);
    procedure BtnApplyClick(Sender: TObject);
    procedure BtnRunScriptClick(Sender: TObject);
    procedure BtnStepScriptClick(Sender: TObject);
    procedure PSCompImport(Sender: TObject; x: TPSPascalCompiler);
    procedure PSExecImport(Sender: TObject; se: TPSExec;
      x: TPSRuntimeClassImporter);
    procedure PSCompile(Sender: TPSScript);
    procedure BtnOpenClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure EDDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure EDDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure EDSpecialLineColors(Sender: TObject; Line: Integer;
      var Special: Boolean; var FG, BG: TColor);
    procedure EDClick(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure PanelBottomDockOver(Sender: TObject; Source: TDragDockObject;
      X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure PanelLeftGetSiteInfo(Sender: TObject; DockClient: TControl;
      var InfluenceRect: TRect; MousePos: TPoint; var CanDock: Boolean);
    procedure BtnSearchClick(Sender: TObject);
    procedure ESearchChange(Sender: TObject);
    procedure ESearchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure EDKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EDGutterClick(Sender: TObject; Button: TMouseButton; X, Y,
      Line: Integer; Mark: TSynEditMark);
    procedure BtnDebugClick(Sender: TObject);
    procedure N11Click(Sender: TObject);
    procedure SCPExecute(Kind: SynCompletionType; Sender: TObject;
      var CurrentInput: String; var x, y: Integer;
      var CanExecute: Boolean);
    procedure EDChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtnCompileTemplateClick(Sender: TObject);
    procedure EDMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure EDStatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure BtnAddBreakPointClick(Sender: TObject);
    procedure BtnDelBreakPointClick(Sender: TObject);
  private
    { Private declarations }
    fGen:dword;
    fExplorerMode:TExplorerMode;
    fReg:TRegExpr;
    fObjList:TStringList;
    fFileName:string;
    fErrorRow:integer;
    fActiveLine:integer;

    fDebugBreakPoints:TList;
    fIsDebugMode:boolean;
    fCurrentOPCManTemplate:THATemplate;


    fEDOldX,fEDOldY:integer;
    fHW:THintWindow;

    procedure CheckBtnDebug;

    procedure SaveIniParams; override;
    procedure InitMode;
    procedure NewTemplate;
    procedure NewConfig;
//    procedure OnChangedEvent(NameEvent:string; ClassID:integer);
    function ScriptToPScript: string;
    function Compile:boolean;
    procedure GetPositionBeginTerm(var ARow,ACol:cardinal);
    procedure NewProc(TypeEvent:TPSTypeEvent; NameProc:string);

    function GetHAObjAtMouse(var sHAObj:string; XY: TBufferCoord):boolean;

    procedure OnNeedValueProp(TypeEvent:TPSTypeEvent; NewEvent:boolean; var Value:string);
    procedure OnChangeName(OldName,NewName:string);



    procedure SetVisibleLine(Line:integer);

    procedure SetVisibleListObject;
    procedure SetVisibleInspect;
    procedure SetVisibleMessages;
    procedure SetVisibleVars;

    procedure Open(FileName:string);
    procedure Save(FileName:string);
    function CheckSave:boolean;
    procedure OnChangedDoc(Sender:TObject);
    procedure SetChangedDoc(Changed:boolean);


    function BuildDoc:boolean;

    function HasBreakPoint(Line:integer):boolean;
    procedure SetBreakPoint(Line:integer);
    procedure ClearBreakPoint(Line:integer);
    procedure SaveDebugInfo;
    function SetDebugMode:boolean;
    procedure SetEditMode;
    function GetTemplateFromOPCMan(NameTemplate:string):THATemplate;

    procedure wmPSLineInfo(var Msg:TMessage); message wm_PSLineInfo;
    procedure wmPSBreakPoint(var Msg:TMessage); message wm_PSBreakpoint;
    procedure wmPSIdle(var Msg:TMessage); message wm_PSIdle;
    procedure wmPSExecError(var Msg:TMessage); message wm_PSExecError;

  public
    { Public declarations }


    fmListObject:TfmListObject;
    fmInspector:TfmInspector;
    fmMessages:TfmMessages;
    fmListVars:TfmListVars;


    constructor Create(var AFormVar:TfmCustom2; ExplorerMode:TExplorerMode);
    procedure ShowDockPanel(APanel:TPanel; MakeVisible:boolean);
    property ExplorerMode:TExplorerMode read fExplorerMode;
    procedure OnFillEvents(TypeEvent:TPSTypeEvent; St:TStrings);

    procedure MsgToObject(Msg:TMessage);

    property CurrentOPCManTemplate:THATemplate read fCurrentOPCManTemplate;

    procedure PaintGutterGlyphs(Line:integer);

  end;


implementation
  uses ha_dockfm,ha_utils,
       HA_templateopendialog,strutils,inifiles,ha_Glav,ha_opcman;
{$R *.dfm}


 const
  BGHeader=#13#10+'begin'+#13#10+#13#10+'end;'+#13#10+#13#10;

  // old version
  RegEventFmtTR='procedure +((\w+)|(\w*<[^<>/]+/>\w*)) *\( *Device *: *TIGDevice *; *Tags *: *TIGTags *; *FromGroup *: *boolean *\)';
  RegEventFmtTW='procedure +((\w+)|(\w*<[^<>/]+/>\w*)) *\( *Device *: *TIGDevice *; *Tags *: *TIGTags *\)';

  //RegEventFmtTRW='procedure *(\x0D\x0A)* +((\w+)|(\w*<[^<>/]+/>\w*)) * *(\x0D\x0A)*\( *(\x0D\x0A)* *Device * *(\x0D\x0A)*: *(\x0D\x0A)* *TIGDevice *(\x0D\x0A)* *; *(\x0D\x0A)* *Tags *(\x0D\x0A)* *: *(\x0D\x0A)* *TIGTags *(\x0D\x0A)* *\) *(\x0D\x0A)* *;';


  //  RegEventFmtBW='procedure +((\w+)|(\w*<[^<>/]+/>\w*)) *\( *Device *: *TIGDevice *; *Command *: *TIGCommand *\)';

  RegEventFmtBW='procedure +((\w+)|(\w*<[^<>/]+/>\w*)) *\( *Device *: *TIGDevice *; *Command *: *TIGCommand *; *var *Cancel *: *boolean *\)';
//  RegEventFmtBW='procedure *(\x0D\x0A)* +((\w+)|(\w*<[^<>/]+/>\w*)) *(\x0D\x0A)*\( *(\x0D\x0A)* *Device *(\x0D\x0A)* *: *(\x0D\x0A)* *TIGDevice *(\x0D\x0A)* *; *(\x0D\x0A)* *Command *(\x0D\x0A)* *: *(\x0D\x0A)* *TIGCommand *(\x0D\x0A)* *; *(\x0D\x0A)* *var *(\x0D\x0A)* +CanCancel *: *boolean *\) *;';
  //procedure *(\r\n)* +((\w+)|(\w*<[^<>/]+/>\w*)) *(\r\n)*\( *(\r\n)* *Device *(\r\n)* *: *(\r\n)* *TIGDevice *(\r\n)* *; *(\r\n)* *Command *(\r\n)* *: *(\r\n)* *TIGCommand *(\r\n)* *; *(\r\n)* *var *(\r\n)* +CanCancel *: *boolean *\) *;

  RegEventFmtAR='procedure +((\w+)|(\w*<[^<>/]+/>\w*)) *\( *Device *: *TIGDevice *; *Command *: *TIGCommand; *DriverData *: *TIGDriverData *\)';
//  RegEventFmtAR='procedure +((\w+)|(\w*<[^<>/]+/>\w*)) *\( *Device *\n*: *TIGDevice *\n*;\n* *Command *: *TIGCommand;\n* *DriverData *\n*:\n* *TIGDriverData *\)';

  RegEventFmtCheckDef='procedure +((\w+)|(\w*<[^<>/]+/>\w*)) *\( *Tags *: *TIGTags *; *var *Active *: *boolean *\)';

  RegEventFmtActiveDevice='procedure +((\w+)|(\w*<[^<>/]+/>\w*)) *\( *Device *: *TIGDevice *\)';

  RegEventFmtTimer='procedure +((\w+)|(\w*<[^<>/]+/>\w*)) *\( *Device *: *TIGDevice *; * Timer *: *TIGTimer *\)';

  RegSearchProcFmt='procedure +%s';

  ProcFmtTR='procedure %s(Device:TIGDevice; Tags:TIGTags; FromGroup:boolean);'+BGHeader;
  ProcFmtTW='procedure %s(Device:TIGDevice; Tags:TIGTags);'+BGHeader;

  ProcFmtBW='procedure %s(Device:TIGDevice; Command:TIGCommand; var Cancel:boolean);'+BGHeader;
  ProcFmtAR='procedure %s(Device:TIGDevice; Command:TIGCommand; DriverData:TIGDriverData);'+BGHeader;
  ProcFmtCheckDef='procedure %s(Tags:TIGTags; var Active:boolean);'+BGHeader;
  ProcFmtActiveDevice='procedure %s(Device:TIGDevice);'+BGHeader;
  ProcFmtTimer='procedure %s(Device:TIGDevice; Timer:TIGTimer);'+BGHeader;

constructor TfmExplorer.Create(var AFormVar:TfmCustom2;
  ExplorerMode: TExplorerMode);
type
 pDockRec=^TDockRec;
 TDockRec=record
  APanel:TPanel;
  ARect:TPoint;
  IsWork:boolean;
  AlSide:TAlign;
  fm:TfmDock;
 end;

var ini:TiniFile;
    sec:string;
    DR:TList;
    i:integer;
    

function Sort(Item1,Item2:pointer):integer;
var d1,d2:PDockRec;
begin
 d1:=PDockRec(Item1);
 d2:=PDockRec(Item2);
 if d1^.APanel<>d2^.APanel then
  result:=1
 else
  begin
   if d1^.ARect.X=d2^.ARect.X then
    begin
      if d1^.ARect.Y<=d2^.ARect.Y then
       begin
        if d1^.AlSide=alNone then d1^.AlSide:=alTop;
        if d2^.AlSide=alNone then d2^.AlSide:=alClient;
       end
      else
       begin
        if d2^.AlSide=alNone then d2^.AlSide:=alTop;
        if d1^.AlSide=alNone then d1^.AlSide:=alClient;
       end;
    end
   else
    if d1^.ARect.Y=d2^.ARect.Y then
    begin
      if d1^.ARect.X<=d2^.ARect.X then
       begin
        if d1^.AlSide=alNone then d1^.AlSide:=alLeft;
        if d2^.AlSide=alNone then d2^.AlSide:=alClient;
       end
      else
       begin
        if d2^.AlSide=alNone then d2^.AlSide:=alLeft;
        if d1^.AlSide=alNone then d1^.AlSide:=alClient;
       end;
    end;

   result:=0;
  end;
end;

procedure SetHostDockPanel(aLeft,aTop:integer; s:string; fmDock:TfmDock);
var pr:pDockRec;
    APanel:TPanel;
begin
  if s<>'' then
    begin
     APanel:=nil;
     if CompareText(s,'PanelLeft')=0 then
       APanel:=PanelLeft //ManualDock(PanelLeft)
     else
      if CompareText(s,'PanelRight')=0 then
       APanel:=PanelRight // ManualDock(PanelRight)
      else
       if CompareText(s,'PanelBottom')=0 then
         APanel:=PanelBottom
       else
        if CompareText(s,'PanelNone')=0 then
         begin
          if fmDock is TfmListObject then
           APanel:=PanelLeft
          else
           if fmDock is TfmInspector then
            APanel:=PanelLeft
           else
            if fmDock is TfmMessages then
             APanel:=PanelBottom;  
         end;

      if APanel<>nil then
       begin
        new(pr);
        pr^.APanel:=APanel;
        pr^.ARect.X:=aLeft;
        pr^.ARect.Y:=aTop;
        pr^.IsWork:=false;
        pr^.AlSide:=alNone;
        pr^.fm:=fmDock;
        DR.Add(pr);
       end;
    end;

end;

begin
 fHW:=THintWindow.Create(self);
 fhw.Color:=clInfoBK;
 if ExplorerMode=em_Templates then
  tag:=1
 else
  tag:=2;
 inherited Create(AFormVar);
 fGen:=0;
 fExplorerMode:=ExplorerMode;
 SetEditMode;


 fDebugBreakPoints:=TList.Create;


 fReg:=TRegExpr.Create;
 fObjList:=TStringList.Create;

 fmListObject:=TfmListObject.Create(self);
 fmInspector:=TfmInspector.Create(self);
 fmMessages:=TfmMessages.Create(self);
 fmListVars:=TfmListVars.Create(self);


 fmInspector.OnNeedValueProp:=OnNeedValueProp;
 fmInspector.OnFillEvents:=OnFillEvents;
 fmInspector.OnChangeName:=OnChangeName;
 fmInspector.OnChangedProp:=OnChangedDoc;


 fmListObject.OnChangeName:=OnChangeName;
 fmListObject.OnChangedObj:=OnChangedDoc;



 dr:=TList.Create;

 ini:=TIniFile.Create(ChangeFileExt(ParamStr(0),'.ini'));
 try


  if fExplorerMode=em_Templates then
   begin

     with fmListObject do
      begin
         sec:=ClassName;

         Left:=ini.ReadInteger(sec,'Left',0);
         Top:=ini.ReadInteger(sec,'Top',0);
         Width:=ini.ReadInteger(sec,'Width',width);
         Height:=ini.ReadInteger(sec,'Height',height);
         Visible:=ini.ReadBool(sec,'Visible',true);
         SetHostDockPanel(Left,Top,ini.ReadString(sec,'HostDockSite','PanelNone'),fmListObject);
      end;

     with fmInspector do
      begin
         sec:=ClassName;

         Left:=ini.ReadInteger(sec,'Left',0);
         Top:=ini.ReadInteger(sec,'Top',10);
         Width:=ini.ReadInteger(sec,'Width',width);
         Height:=ini.ReadInteger(sec,'Height',height);
         Visible:=ini.ReadBool(sec,'Visible',true);
         SetHostDockPanel(Left,Top,ini.ReadString(sec,'HostDockSite','PanelNone'),fmInspector);
      end;

     with fmMessages do
      begin
         sec:=ClassName;

         Left:=ini.ReadInteger(sec,'Left',0);
         Top:=ini.ReadInteger(sec,'Top',0);
         Width:=ini.ReadInteger(sec,'Width',width);
         Height:=ini.ReadInteger(sec,'Height',height);


         Visible:=ini.ReadBool(sec,'Visible',true);
         SetHostDockPanel(Left,Top,ini.ReadString(sec,'HostDockSite','PanelNone'),fmMessages);


      end;

    with fmListVars do
      begin
         sec:=ClassName;
         Left:=ini.ReadInteger(sec,'Left',0);
         Top:=ini.ReadInteger(sec,'Top',0);
         Width:=ini.ReadInteger(sec,'Width',width);
         Height:=ini.ReadInteger(sec,'Height',height);
         Visible:=ini.ReadBool(sec,'Visible',false);
         SetHostDockPanel(Left,Top,ini.ReadString(sec,'HostDockSite','PanelNone'),fmListVars);
      end;

   end;
 // else
 //  Open(ini.ReadString('Config','DefaultConfig',''));



  DR.Sort(@Sort);

  for i:=0 to DR.Count-1 do
   if TDockRec(DR[i]^).AlSide=alClient then
   begin
    TDockRec(DR[i]^).fm.ManualDock(TDockRec(DR[i]^).APanel,nil,TDockRec(DR[i]^).AlSide);

    //dispose(DR[i]);
   end;

  for i:=0 to DR.Count-1 do
   begin
    if TDockRec(DR[i]^).AlSide<>alClient then
     TDockRec(DR[i]^).fm.ManualDock(TDockRec(DR[i]^).APanel,nil,TDockRec(DR[i]^).AlSide);
    dispose(DR[i]);
   end;


   if Tag=0 then
    sec:=ClassName
   else
    sec:=ClassName+inttostr(Tag);

   windowstate:=TWindowState(ini.ReadInteger(Sec,'WindowState',integer(wsNormal)));

   if PanelLeft.VisibleDockClientCount>0 then
    PanelLeft.Width:=ini.ReadInteger(sec,'PanelLeftWidth',Width div 6);

   if PanelRight.VisibleDockClientCount>0 then
    PanelRight.Width:=ini.ReadInteger(sec,'PanelRightWidth',Width div 6);

   if PanelBottom.VisibleDockClientCount>0 then
     PanelBottom.Height:=ini.ReadInteger(sec,'PanelBottomHeight',Height div 6);


 finally
  ini.Free;
  dr.Free;
 end;


 InitMode;
end;

procedure TfmExplorer.FormDestroy(Sender: TObject);
var ini:TIniFile;

begin
 if fExplorerMode=em_Templates then
  begin
   ini:=TIniFile.Create(ChangeFileExt(ParamStr(0),'.ini'));
   try
    ini.WriteString('Config','DefaultTemplate',fFileName);
   finally
    ini.Free;
   end;

   SaveDebugInfo;



  end;
 fmListObject.Free;
 fmInspector.Free;
 fmMessages.Free;
 fmListVars.Free;
 fReg.Free;
 fObjList.Free;
 fDebugBreakPoints.Free;

 SetEditMode;
 fhw.Free;
end;

procedure TfmExplorer.N2Click(Sender: TObject);
begin
 SetVisibleListObject;
end;

procedure TfmExplorer.ShowDockPanel(APanel: TPanel; MakeVisible: boolean);
begin
 if not MakeVisible and (APanel.VisibleDockClientCount > 1) then
    Exit;

 if (APanel.VisibleDockClientCount =0) then
  exit;

  if APanel = PanelLeft then
    SplitterLeft.Visible := MakeVisible
  else
   if APanel = PanelRight then
    SplitterRight.Visible := MakeVisible
   else
    if APanel = PanelBottom then
     SplitterBottom.Visible:=MakeVisible;


    if MakeVisible then
     begin
      if APanel = PanelBottom then
       APanel.Height := ClientHeight div 6
      else
       APanel.Width := ClientWidth div 6;

      if APanel = PanelLeft then
       SplitterLeft.Left := APanel.Width + SplitterLeft.Width
      else
       if APanel = PanelRight then
         SplitterRight.Left := APanel.Left - SplitterRight.Width
       else
        if APanel = PanelBottom then
          SplitterBottom.Top:=APanel.Top+SplitterBottom.Height;


     end

    else
      if APanel = PanelBottom then
       APanel.Height:=0
      else
       APanel.Width := 0;


{ if APanel.Width=0 then
  begin
  if APanel.VisibleDockClientCount>0 then
   APanel.Width:=100;
  end
 else
  if APanel.VisibleDockClientCount=0 then
   APanel.Width:=0;}
// if APanel.VisibleDockClientCount>0 then exit;
// APanel.Height:=1;
end;

procedure TfmExplorer.PanelLeftDockDrop(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer);
begin
// ShowDockPanel(PanelLeft,true);
if (Sender as TPanel).VisibleDockClientCount = 1 then
 begin
  ShowDockPanel(Sender as TPanel, True);
 end;
end;

procedure TfmExplorer.PanelLeftUnDock(Sender: TObject; Client: TControl;
  NewTarget: TWinControl; var Allow: Boolean);
begin
 if not (Sender is TPanel) then exit;
 if (Sender as TPanel).VisibleDockClientCount = 1 then
    ShowDockPanel(Sender as TPanel, False)
// else
//    ShowDockPanel(Sender as TPanel, true);
end;

procedure TfmExplorer.N3Click(Sender: TObject);
begin
 SetVisibleInspect;
{ if not fmInspector.Visible then
  begin
   fmInspector.Show;
   if Assigned(fmInspector.HostDockSite) then
    ShowDockPanel(fmInspector.HostDockSite as TPanel,true);
  end
 else
  fmInspector.SetFocus;}
end;

procedure TfmExplorer.PanelLeftDockOver(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
var
  ARect: TRect;
begin
  Accept := Source.Control is TfmDock;
  if Accept then
  begin
    //Modify the DockRect to preview dock area.
    ARect.TopLeft := TPanel(sender).ClientToScreen(Point(0, 0));
    ARect.BottomRight := TPanel(sender).ClientToScreen(
      Point(Self.ClientWidth div 6, TPanel(sender).Height));
    Source.DockRect := ARect;
  end;
end;

procedure TfmExplorer.PanelRightDockOver(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
var
  ARect: TRect;
begin
  Accept := Source.Control is TfmDock;
  if Accept then
  begin
    //Modify the DockRect to preview dock area.
    ARect.TopLeft := TPanel(sender).ClientToScreen(Point(0-(Self.ClientWidth div 6), 0));
    ARect.BottomRight := TPanel(sender).ClientToScreen(
      Point(0, TPanel(sender).Height));
    Source.DockRect := ARect;
  end;
end;

procedure TfmExplorer.BtnNewClick(Sender: TObject);
begin
 case fExplorerMode of
  em_Templates  :NewTemplate;
  em_Controllers:NewConfig;
 end;
end;

procedure TfmExplorer.InitMode;
begin
 if fExplorerMode=em_Controllers then
  begin
   Caption:='Конфигурация';


   BtnCompileTemplate.Hint:='Проверить конфигурацию';

 //  N1.Visible:=false;
   N2.Visible:=false;
   N3.Visible:=false;
   N11.Visible:=false;
  // N14.Visible:=false;
  // N12.Caption:='Конфигурация';

   Panel1.Visible:=false;
   BtnDebug.Visible:=false;

   N4.Caption:='Конфигурация';

   BtnNew.Hint:='Создать конфигурацию';
   BtnOpen.Hint:='Редактировать конфигурацию';
   BtnSave.Hint:='Сохранить конфигурацию';


   PanelCenter.Visible:=false;
   PanelLeft.DockSite:=false;
   PanelRight.DockSite:=false;
   PanelBottom.DockSite:=false;

   PanelLeft.Align:=alClient;
   PanelRight.Width:=ClientWidth div 2;

   SplitterRight.Visible:=true;
   SplitterRight.Left := PanelRight.Left - SplitterRight.Width;
   SplitterBottom.Visible:=true;

//   fmListObject.HostDockSite:=PanelLeft;
//   fmListObject.Show;
   fmListObject.BorderStyle:=bsNone;
   fmListObject.Parent:=PanelLeft;
   fmListObject.Top:=0;
   fmListObject.Left:=0;
   fmListObject.Show;

 //  fmInspector.HostDockSite:=PanelRight;
 //  fmInspector.Show;
   fmInspector.BorderStyle:=bsNone;
   fmInspector.Parent:=PanelRight;
   fmInspector.Top:=0;
   fmInspector.Left:=0;
   fmInspector.Show;

   PanelBottom.Height:=0;
 //  fmMessages.HostDockSite:=PanelBottom;
 //  fmMessages.Show;
   fmMessages.BorderStyle:=bsNone;
   fmMessages.Parent:=PanelBottom;

   fmMessages.Top:=0;
   fmMessages.Left:=0;
   fmMessages.Show;

  end
 else
  begin
   Caption:='Шаблон';

   BtnCompileTemplate.Hint:='Проверить шаблон';

   N1.Visible:=true;
   N4.Caption:='Шаблон';
 //  N14.Visible:=true;
 //  N12.Caption:='Шаблон';

   Panel1.Visible:=true;
   BtnDebug.Visible:=true;

   BtnNew.Hint:='Создать шаблон';
   BtnOpen.Hint:='Редактировать шаблон';
   BtnSave.Hint:='Сохранить шаблон';


   PanelCenter.Visible:=true;

   PanelLeft.DockSite:=true;
   PanelRight.DockSite:=true;
   PanelBottom.DockSite:=true;
   PanelLeft.Align:=alLeft;

 {  fmListObject.HostDockSite:=PanelLeft;
   fmListObject.show;
   ShowDockPanel(PanelLeft,true);

   fmInspector.HostDockSite:=PanelRight;
   fmInspector.Show;
   ShowDockPanel(PanelRight,true);

   fmMessages.HostDockSite:=PanelBottom;
   fmMessages.Show;
   ShowDockPanel(PanelBottom,true);
  }

//   NewTemplate;

  end;
end;

procedure TfmExplorer.PanelLeftResize(Sender: TObject);
begin
 if fExplorerMode=em_Controllers then
  begin
   fmListObject.Height:=PanelLeft.Height;
   fmListObject.Width:=PanelLeft.Width;
   fmInspector.Height:=PanelRight.Height;
   fmInspector.Width:=PanelRight.Width;
   fmMessages.Height:=PanelBottom.Height;
   fmMessages.Width:=PanelBottom.Width;
  end;
end;

procedure TfmExplorer.NewTemplate;
begin
 XData.ResetGenID;
 fmListObject.NewTemplate;
 ED.Lines.Text:='begin'+#13#10+#13#10+'end.';

 fFileName:='';
 caption:='Шаблоны - '+'Untitled';
 SetChangedDoc(false);
 CheckBtnDebug;
end;

procedure TfmExplorer.BtnApplyClick(Sender: TObject);
begin


end;

{procedure TfmExplorer.OnChangedEvent(NameEvent: string; ClassID: integer);
var i:integer;
    r,c:cardinal;
    s:string;
begin
 fReg.Expression :=format(RegSearchProcFmt,[NameEvent]);
 if fReg.Exec (ED.Text) then
  showmessage('Найдено')
 else
  begin
   GetPositionBeginTerm(r,c);
   s:=format(ProcFmt1,[NameEvent]);
   Ed.CaretX:=c;
   ED.CaretY:=r;
   ED.SelText:=s;
   i:=r-(ED.LinesInWindow div 2);
   if i>0 then
    ED.TopLine:=i;
   Ed.CaretY:=r;
  end;

 ed.SetFocus;
end;  }


procedure TfmExplorer.BtnRunScriptClick(Sender: TObject);
var k:word;
begin
 k:=vk_f9;
 EDKeyDown(nil,k,[]);
end;

procedure TfmExplorer.BtnStepScriptClick(Sender: TObject);
var k:word;
begin
 k:=vk_f8;
 EDKeyDown(nil,k,[]);


end;


{function NormalizePath(APath:string):string;
begin
 result:=APath;
 delete(result,1,2);
 delete(result,length(result)-1,2);
end;
 }

function TfmExplorer.ScriptToPScript: string;
var //Reg:TRegExpr;
    s,ps:string;
    st:TStringList;
    oid,classid,i:integer;





begin
// result:=ED.Lines.Text;
 result:=DeleteCommentFromScript(ED.Lines.Text);

 fReg.ModifierI:=false;
 st:=TStringList.Create;
 try
  fReg.Expression:=RegScript;
  if fReg.Exec(ED.Lines.Text) then
	 repeat
    s:=fReg.Match[0];
    st.Clear;
    ParsePath(NormalizePath(s),st);
    fmListObject.GetClassAndOID(st,oid,classid);
    if oid<0 then continue;
    ps:=format(FormatPScript,[ClassID,OID]);
    if fObjList.IndexOfName(ps)<0 then
     fObjList.AddObject(ps,TObject(classid));

    result:=stringreplace(result,s,ps,[rfReplaceAll, rfIgnoreCase]);
   until not fReg.ExecNext;

   // находим все процедуры
  fReg.Expression:=RegScriptProc;
  st.Text:=result;
  for i:=0 to st.Count-1 do
   begin
    if fReg.Exec(st[i]) then
	   repeat
      s:=fReg.Match[0];
      ps:='HAPROC'+sysutils.inttostr(MakeHashId(s));
      st[i]:=stringreplace(st[i],s,ps,[rfReplaceAll, rfIgnoreCase]);
     until not fReg.ExecNext;
   end;
  result:=st.Text;
 finally
  st.Free;
 end;

end;


function TfmExplorer.Compile: boolean;
var i:integer;
    m:TMessage;
  //  j,jj,jjj:dword;
begin
 fErrorRow:=-1;
// j:=GetTickCount;
 result:=true;
 fObjList.Clear;
 PS.Script.Text:=ScriptToPScript;
// jj:=GetTickCount-j;
// j:=GetTickCount;
 ps.Compile;
// jjj:=GetTickCount-j;
  begin
   for i:=0 to ps.CompilerMessageCount-1 do
    begin
      m.Msg:=HAMsgScript;
      if CompareText(ps.CompilerMessages[i].ErrorType,'Error')=0 then
       m.Result:=HATypeMsgError
      else
       m.Result:=HATypeMsgWarning;
      m.WParam:=ps.CompilerMessages[i].Row;
      m.LParam:=ps.CompilerMessages[i].Col;

      fmMessages.AddMessage(ps.CompilerMessages[i].ShortMessageToString,m);
    end;

  end;

end;

procedure TfmExplorer.PSCompImport(Sender: TObject; x: TPSPascalCompiler);
begin
  inherited;
 SIRegisterHAOBJ(x);
end;

procedure TfmExplorer.PSExecImport(Sender: TObject; se: TPSExec;
  x: TPSRuntimeClassImporter);
begin
  inherited;
 RIRegisterHAOBJ(x,se);
end;

procedure TfmExplorer.PSCompile(Sender: TPSScript);
var i:integer;
    s:string;
    cl:integer;
begin
  for i:=0 to fObjList.Count-1 do
   begin
    S:='';
    cl:=integer(fObjList.Objects[i]);
    case cl of
     ClassTag     : S:='TIGTag';
     ClassCommand : S:='TIGCommand';
    // ClassLinkProp: S:='TIGProp';
    end;
    if s<>'' then
     Sender.AddRegisteredVariable(fObjList[i],s);

   end;
 //Sender.AddRegisteredVariable('IGCONVERTER','TIGConverter');
end;

procedure TfmExplorer.BtnOpenClick(Sender: TObject);
var s,s1:string;
begin
 if fmInspector.Showing then
  fmInspector.FocusControl(nil);
 if BtnSave.Enabled then
  begin
   if fExplorerMode=em_Templates then
    begin
      s:='Шаблон '+fFileName+' был изменен.'+#13#10#13#10+'Сохранить шаблон ?';
      s1:='Шаблоны';
    end
   else
    begin
     s:='Конфигурация '+fFileName+' была изменена.'+#13#10#13#10+'Сохранить конфигурацию ?';
     s1:='Конфигурация';
    end;

   case MessageBox(handle,PChar(s),PChar(s1),MB_YESNOCANCEL or MB_ICONWARNING or MB_APPLMODAL	) of
    IDYES: BtnSaveClick(nil);
    IDCANCEL:exit;
   end;
  end;
  s:=fFileName;
  if OpenTemplate(fExplorerMode,s) then
   Open(s);
end;


procedure TfmExplorer.BtnSaveClick(Sender: TObject);
var s:string;
begin
 if not CheckSave then exit;
 s:=fFileName;
 if fFileName='' then
  begin

   if SaveTemplate(fExplorerMode,s) then
    begin
     fFileName:=s;
     Save(fFileName);
    end;
  end
 else
  Save(fFileName);
end;

procedure TfmExplorer.N9Click(Sender: TObject);
var s:string;
begin
 if not CheckSave then exit;
 if SaveTemplate(fExplorerMode,s) then
  begin
   Save(s);
   fmGlav.GetConfigsServer;
  end;
end;

procedure TfmExplorer.GetPositionBeginTerm(var ARow, ACol: cardinal);
const
 EndTerm='end';
 BeginTerm='begin';
var s:string;
    i,j,jj,k,kk,iEnd,iBegin:integer;

begin

 iEnd:=0; iBegin:=0;
 for i:=ED.Lines.Count-1 downto 0 do
  begin
   s:=LowerCase(ED.Lines[i]);
   j:=1;
   jj:=PosEx(EndTerm,s,j);
   while jj>0 do
    begin
     inc(iEnd);
     inc(j,jj);
     jj:=PosEx(EndTerm,s,j);
    end;

   k:=1;
   kk:=PosEx(BeginTerm,s,k);
   while kk>0 do
    begin
     inc(iBegin);
     inc(k,kk);
     kk:=PosEx(BeginTerm,s,k);
    end;

   if iBegin=iEnd then
    begin
     ARow:=i+1;
     ACol:=PosEx(BeginTerm,s,1);
     break;
    end;


  end;

end;

procedure TfmExplorer.SaveIniParams;
var ini:TIniFile;
    sec,s:string;
begin
 inherited;
 ini:=TIniFile.Create(ChangeFileExt(ParamStr(0),'.ini'));
 try
   if Tag=0 then
    sec:=ClassName
   else
    sec:=ClassName+inttostr(Tag);
   ini.WriteInteger(sec,'PanelLeftWidth',PanelLeft.Width);
   ini.WriteInteger(sec,'PanelRightWidth',PanelRight.Width);
   ini.WriteInteger(sec,'PanelBottomHeight',PanelBottom.Height);
   ini.WriteInteger(sec,'WindowState',integer(windowstate));

  if fExplorerMode=em_Templates then
  begin
   with fmListObject do
    begin
       sec:=ClassName;
       ini.WriteInteger(sec,'Left',Left);
       ini.WriteInteger(sec,'Top',Top);
       ini.WriteInteger(sec,'Width',Width);
       ini.WriteInteger(sec,'Height',Height);
       ini.WriteBool(sec,'Visible',Visible);
      // ini.WriteInteger(sec,'Align',integer(fmListObject.Align));
       if HostDockSite<>nil then
        s:=HostDockSite.Name
       else
        s:='';
       ini.WriteString(sec,'HostDockSite',s);
    end;

   with fmInspector do
    begin
       sec:=ClassName;
       ini.WriteInteger(sec,'Left',Left);
       ini.WriteInteger(sec,'Top',Top);
       ini.WriteInteger(sec,'Width',Width);
       ini.WriteInteger(sec,'Height',Height);
       ini.WriteBool(sec,'Visible',Visible);
       ini.WriteInteger(sec,'Align',integer(fmInspector.Align));
       if HostDockSite<>nil then
        s:=HostDockSite.Name
       else
        s:='';
       ini.WriteString(sec,'HostDockSite',s);
    end;

   with fmMessages do
    begin
       sec:=ClassName;
       ini.WriteInteger(sec,'Left',Left);
       ini.WriteInteger(sec,'Top',Top);
       ini.WriteInteger(sec,'Width',Width);
       ini.WriteInteger(sec,'Height',Height);
       ini.WriteBool(sec,'Visible',Visible);
     //  ini.WriteInteger(sec,'Align',integer(Align));
       if HostDockSite<>nil then
        s:=HostDockSite.Name
       else
        s:='';
       ini.WriteString(sec,'HostDockSite',s);
    end;

  with fmListVars do
    begin
       sec:=ClassName;
       ini.WriteInteger(sec,'Left',Left);
       ini.WriteInteger(sec,'Top',Top);
       ini.WriteInteger(sec,'Width',Width);
       ini.WriteInteger(sec,'Height',Height);
       ini.WriteBool(sec,'Visible',Visible);
      // ini.WriteInteger(sec,'Align',integer(fmListObject.Align));
       if HostDockSite<>nil then
        s:=HostDockSite.Name
       else
        s:='';
       ini.WriteString(sec,'HostDockSite',s);
    end;

 end;

 finally
  ini.Free;
 end;

end;

procedure TfmExplorer.OnFillEvents(TypeEvent: TPSTypeEvent; St: TStrings);
var i,j,jj,k:integer;
    s,s1,sScript:string;
begin
  St.Clear;


  fReg.ModifierI:=true;
  case TypeEvent of
   pste_TagsR       : fReg.Expression:=RegEventFmtTR;
   pste_TagsW       : fReg.Expression:=RegEventFmtTW;
   pste_CommandsBW  : fReg.Expression:=RegEventFmtBW;
   pste_CommandsAR  : fReg.Expression:=RegEventFmtAR;
   pste_EventDef    : fReg.Expression:=RegEventFmtCheckDef;
   pste_Device      : fReg.Expression:=RegEventFmtActiveDevice;
   pste_Timer       : fReg.Expression:=RegEventFmtTimer;
  end;

  sScript:=StringReplace(ED.Lines.Text,#$d#$a,' ',[rfReplaceAll, rfIgnoreCase]);

  if fReg.Exec(sScript) then
	 repeat
    st.Add(fReg.Match[0]);
  //  st.AddObject(fReg.Match[0],TObject(fReg.MatchPos[0]));
  //  i:=fReg.MatchPos[0];
   until not fReg.ExecNext;

  for i:=st.Count-1 downto 0 do
   begin
  //  k:=integer(st.Objects[i]);
    s:=st[i];
    delete(s,1,Length('procedure'));
    st[i]:='';
    for j:=1 to length(s) do
     if s[j]<>'(' then
      st[i]:=st[i]+s[j]
     else
      break;

    st[i]:=trim(st[i]);
  //  st.Objects[i]:=TObject(k);
   end;

  for i:=0 to ED.Lines.Count-1 do
   begin
     for j:=0 to st.Count-1 do
     if integer(st.Objects[j])=0 then
     begin
      k:=pos(st[j],ED.Lines[i]);
      if k<>0 then
       begin
        s:=ED.Lines[i];
        s1:='';
        for jj:=k to length(s) do
         if s[jj]<>'(' then
          s1:=s1+s[jj]
         else
          break;

        if comparetext(st[j],s1)=0 then
         begin
          st.Objects[j]:=TObject(i);
          break;
         end;
       end;
     end;
   end;

 { fReg.Expression:=RegParseEventFmt;
  for i:=st.Count-1 downto 0 do
   begin
    if fReg.Exec(st[i]) then
     begin
      s:=fReg.Match[0];
      delete(s,1,Length('procedure'));
      delete(s,length(s),1);
      st[i]:=Trim(s);
     end
    else
     st.Delete(i);
   end;
  }
end;

procedure TfmExplorer.OnNeedValueProp(TypeEvent: TPSTypeEvent;
 NewEvent:boolean; var Value: string);
var st:TStringList;
    i,j:integer;
    fl:boolean;
    s,s1:string;
begin
 st:=TStringList.Create;
 try
  // находим все события в скрипте
  OnFillEvents(TypeEvent,st);
  if NewEvent then
   begin
    // генерируем название нового события
    s:=value;
    fl:=false;
    s1:=s;
    while true do
     begin
      for i:=0 to st.Count-1 do
       if CompareText(s1,st[i])=0 then
        begin
         fl:=true;
         break;
        end;
      if fl then
       begin
        inc(fGen);
        s1:=s+inttostr(fGen);
        fl:=false;
       end
      else
       break;

     end;
    Value:=s1;
    NewProc(TypeEvent,s1);
   end
  else
   begin
    // иначе находим событие и показываем пользователю
    j:=-1;
    for i:=0 to st.Count-1 do
     if CompareText(Value,st[i])=0 then
      begin
       j:=integer(st.Objects[i]);
       break;
      end;
    if j<0 then exit;
    // получаем индекс начала найденной строки
   // apos:=integer(st.Objects[j]);
    // получаем индекс строки в скрипте
   // arow:=ED.CharIndexToRowCol(apos).Line;
    SetVisibleLine(j+1);//arow);
{    ED.CaretY:=arow;
    i:=arow-(ED.LinesInWindow div 2);
    if i>0 then ED.TopLine:=i;
    ED.Refresh;
    ED.SetFocus;}
   end;

 finally
  st.Free;
 end;
end;

procedure TfmExplorer.NewProc(TypeEvent: TPSTypeEvent; NameProc: string);
var r,c:cardinal;
    s:string;
begin
   GetPositionBeginTerm(r,c);
   //if r>1 then
   // s:=#13#10;
   case TypeEvent of
    pste_TagsR      : s:=format(ProcFmtTR,[NameProc]);
    pste_TagsW      : s:=format(ProcFmtTW,[NameProc]);
    pste_CommandsBW : s:=format(ProcFmtBW,[NameProc]);
    pste_CommandsAR : s:=format(ProcFmtAR,[NameProc]);
    pste_EventDef   : s:=format(ProcFmtCheckDef,[NameProc]);
    pste_Device     : s:=format(ProcFmtActiveDevice,[NameProc]);
    pste_Timer      : s:=format(ProcFmtTimer,[NameProc]);
   end;


   Ed.CaretX:=c;
   ED.CaretY:=r;
   ED.SelText:=s;
   SetVisibleLine(r);
   {i:=r-(ED.LinesInWindow div 2);
   if i>0 then
    ED.TopLine:=i;
   Ed.CaretY:=r;
   ED.SetFocus;}
end;

procedure TfmExplorer.OnChangeName(OldName, NewName: string);
begin
 ed.SearchReplace(format(FormatScript,[OldName]), format(FormatScript,[NewName]), [ssoWholeWord,ssoReplace, ssoReplaceAll,ssoEntireScope,ssoMatchCase]);
end;


procedure TfmExplorer.EDDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var L,Path:TStringList;
    i:integer;
    aOID,aClassID:integer;
begin
  inherited;
  Accept:=(Source is TBaseVirtualTree) and (TComponent(Source).Owner=fmListObject);
  if not Accept then exit;

  L:=TStringList.Create;
  Path:=TStringList.Create;
  try
   fmListObject.GetSelectedNames(l);
   for i:=0 to l.Count-1 do
    begin
     Path.Clear;
     ParsePath(l[i],Path);
     fmListObject.GetClassAndOID(Path,aOID,aClassID);
     Accept:=aClassID in [ClassTag,ClassCommand];
     if not Accept then
      break;
    end;
  finally
   l.Free;
   Path.Free;
  end;



end;

procedure TfmExplorer.EDDragDrop(Sender, Source: TObject; X, Y: Integer);
var L:TStringList;
    i:integer;
begin
  L:=TStringList.Create;
  try
   fmListObject.GetSelectedNames(l);
   for i:=0 to l.Count-1 do
    l[i]:=format(FormatScript,[l[i]]);

   ED.CaretX:=ED.PixelsToRowColumn(x,y).Column; ED.CaretY:=ED.PixelsToRowColumn(x,y).Row;
   ED.SelText:=l.Text;
 //  if l.Count>0 then
 //   ED.SetFocus;
  finally
   l.Free;
  end;
end;


function TfmExplorer.HasBreakPoint(Line:integer):boolean;
var i:integer;
begin
 result:=false;
 for i:=0 to fDebugBreakPoints.Count-1 do
  if integer(fDebugBreakPoints[i])=Line then
   begin
    result:=true;
    break;
   end;
end;

procedure TfmExplorer.EDSpecialLineColors(Sender: TObject; Line: Integer;
  var Special: Boolean; var FG, BG: TColor);


begin
  inherited;
 //if fCurrentOPCManTemplate<>nil then
 // if fCurrentOPCManTemplate.PSDebug.Exec.DebugMode=dmRun then
  // fActiveLine:=-1;
 PaintGutterGlyphs(Line);
 if fErrorRow=Line then
  begin
   bg:=clMaroon;
   fg:=clWhite;
   Special:=true;
   exit;
  end;

 if HasBreakPoint(Line) then
  begin
    Special := True;
    if Line = fActiveLine then
     begin
      BG := clBlue;//clWhite;
      FG := clWhite;//clRed;
     end
    else
     begin
      FG := clWhite;
      BG := clRed;
     end;
  end
 else
  if Line = fActiveLine then
   begin
       Special := True;
       FG := clWhite;
       bg := clBlue;

   end
  else
    Special := False;
end;

procedure TfmExplorer.EDClick(Sender: TObject);
begin

 fErrorRow:=0;
 ED.Refresh;

 
end;

procedure TfmExplorer.SetVisibleLine(Line: integer);
var i:integer;
begin
  ED.CaretY:=Line;

  i:=Line-(ED.LinesInWindow div 2);
  //if i>0 then
  ED.TopLine:=i;
  ED.SetFocus;
end;

procedure TfmExplorer.N10Click(Sender: TObject);
begin
 SetVisibleMessages;
end;

procedure TfmExplorer.PanelBottomDockOver(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
var
  ARect: TRect;
begin
  Accept := Source.Control is TfmDock;
  if Accept then
  begin
    //Modify the DockRect to preview dock area.
    ARect.TopLeft := TPanel(sender).ClientToScreen(Point(0, 0-(Self.ClientHeight div 6)));
    ARect.BottomRight := TPanel(sender).ClientToScreen(
      Point(Self.ClientWidth, 0));
    Source.DockRect := ARect;
  end;

end;

function TfmExplorer.BuildDoc:boolean;
begin
 fmMessages.ClearMessages;
 if fExplorerMode=em_Templates then
  begin
   ED.SetFocus;
   Compile;
  end
 else
  fmListObject.TV.SetFocus;
 fmListObject.Check;
 result:=fmMessages.CountErrors=0;
 if fmMessages.CountAll>0 then
  N10Click(nil);

end;

procedure TfmExplorer.MsgToObject(Msg: TMessage);
begin
 case Msg.Msg of
   HAMsgListObj:Begin
                 SetVisibleListObject;
                 fmListObject.MsgToObject(Msg);
                end;
   HAMsgScript:begin
                SetVisibleLine(Msg.WParam);
                ED.CaretX:=Msg.LParam;
                fErrorRow:=Msg.WParam;
                ED.Refresh;
               end;
 end;

end;

procedure TfmExplorer.PanelLeftGetSiteInfo(Sender: TObject;
  DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint;
  var CanDock: Boolean);
begin
  inherited;
 CanDock := DockClient is TFmDock;
end;

procedure TfmExplorer.SetVisibleInspect;
begin
  if not fmInspector.Showing then
   begin
     fmInspector.Show;
     fmInspector.Inspect(fmListObject.TV);
     if Assigned(fmInspector.HostDockSite) then
      ShowDockPanel(fmInspector.HostDockSite as TPanel,true);
   end;   
   fmInspector.SetFocus;
end;

procedure TfmExplorer.SetVisibleListObject;
begin
  if not fmListObject.Showing then
   begin
    fmListObject.Show;
    if Assigned(fmListObject.HostDockSite) then
     ShowDockPanel(fmListObject.HostDockSite as TPanel,true);
   end;
   fmListObject.SetFocus;
end;

procedure TfmExplorer.SetVisibleMessages;
begin
  if fExplorerMode=em_Templates then
   begin
    if not fmMessages.Showing then
     begin
       fmMessages.Show;
       if Assigned(fmMessages.HostDockSite) then
        ShowDockPanel(fmMessages.HostDockSite as TPanel,true);
     end;
    fmMessages.SetFocus;
  end
 else
  PanelBottom.Height:=ClientHeight div 4;   
end;

procedure TfmExplorer.BtnSearchClick(Sender: TObject);
begin
  inherited;
 if not fmListObject.ContextSearch(ESearch.Text) then
  begin
   ESearch.Font.Color:=clRed;
   BtnSearch.Enabled:=false;
  end
 else
  ESearch.SetFocus; 
end;

procedure TfmExplorer.ESearchChange(Sender: TObject);
begin
  inherited;
{    ESearch.Font.Color:=clWindowText;
    BtnSearch.Enabled:=true;
    fmListObject.ResetContextPosition;}
end;

procedure TfmExplorer.ESearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
 if key=vk_Return then
   BtnSearchClick(nil)
 else
   begin
    ESearch.Font.Color:=clWindowText;
    BtnSearch.Enabled:=true;
    fmListObject.ResetContextPosition;
   end;
end;

procedure TfmExplorer.Open(FileName: string);

procedure NewDoc_;
begin
 if fExplorerMode=Em_Templates then
    NewTemplate
 else
  if fExplorerMode=Em_Controllers then
    NewConfig;
end;

var sc,s:string;
    ini:TIniFile;
    st:TStringList;
    i,Line:integer;
begin

  if FileName<>'' then
   begin
    if not XData.Load(fExplorerMode,FileName,fmListObject.TV,sc) then
     begin
      NewDoc_;
      exit;
     end;


    case fExplorerMode of
     Em_Templates:begin
                   SaveDebugInfo;
                   SetEditMode;
                   fDebugBreakPoints.Clear;
                   fmListVars.ClearVars;

                   ED.Lines.Text:=sc;
                   ED.SetFocus;
                   caption:='Шаблоны - '+FileName;
                   ini:=TIniFile.Create(ExtractFilePath(ParamStr(0))+'\'+TemplatesDir+'\'+FileName+ExtDebugInfo);
                   st:=TStringList.Create;
                   try
                    ini.ReadSection('Breakpoints',st);
                    for i:=0 to st.Count-1 do
                     begin
                      line:=ini.ReadInteger('Breakpoints',st[i],-1);
                      if line>0 then
                       fDebugBreakPoints.Add(pointer(Line));
                     end;

                    st.Clear;
                    ini.ReadSection('Vars',st);
                    for i:=0 to st.Count-1 do
                     begin
                      s:=ini.ReadString('Vars',st[i],'');
                      if s<>'' then
                       fmListVars.AddVarDebug(s);
                     end;

                    ED.TopLine:=ini.ReadInteger('Others','TopLine',0);
                    ED.CaretY:=ini.ReadInteger('Others','CursorLine',0);
                    ED.CaretX:=ini.ReadInteger('Others','CursorCol',0);
                   finally
                    st.Free;
                    ini.Free;
                    ED.Refresh;
                    
                   end;



                   BuildDoc;
                  end;
     Em_Controllers:begin
                      caption:='Конфигурация - '+FileName;
                      BuildDoc;
                    end;
    end;

    fFileName:=FileName;
    SetChangedDoc(false);
   end
  else
   NewDoc_;
 CheckBtnDebug;
end;

procedure TfmExplorer.Save(FileName:string);
begin
 if FileName<>'' then
  begin
   fFileName:=FileName;
   XData.Save(fExplorerMode,fFileName,fmListObject.tv,ED.Lines.Text,fmMessages.CountErrors=0);
   case fExplorerMode of
    em_Templates:caption:='Шаблоны - '+fFileName;
    em_Controllers:caption:='Конфигурация - '+fFileName;
   end;
   SetChangedDoc(false); 
  end;
end;

procedure TfmExplorer.FormShow(Sender: TObject);
var ini:TIniFile;
begin
  inherited;
 ini:=TIniFile.Create(ChangeFileExt(ParamStr(0),'.ini'));
 try
  case fExplorerMode of
   em_Templates:Open(ini.ReadString('Config','DefaultTemplate',''));
   em_Controllers:Open(ini.ReadString('Config','DefaultConfig',''));
  end; 
 finally
  ini.Free;
 end;

end;

procedure TfmExplorer.NewConfig;
begin
 XData.ResetGenID;
 fmListObject.NewConfig;
 fFileName:='';
 caption:='Конфигурация - '+'Untitled';
 SetChangedDoc(false);
end;

procedure TfmExplorer.ClearBreakPoint(Line: integer);
begin
 fDebugBreakPoints.Remove(pointer(Line));
 if fIsDebugMode and Assigned(fCurrentOPCManTemplate) then
  fCurrentOPCManTemplate.PSDebug.ClearBreakPoint(fCurrentOPCManTemplate.PSDebug.MainFileName,Line);
end;

procedure TfmExplorer.SetBreakPoint(Line: integer);
begin
 fDebugBreakPoints.Add(pointer(Line));
 if fIsDebugMode and Assigned(fCurrentOPCManTemplate) then
  fCurrentOPCManTemplate.PSDebug.SetBreakPoint(fCurrentOPCManTemplate.PSDebug.MainFileName,Line);

end;

procedure TfmExplorer.EDKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
case key of
  vk_F5:begin
         if HasBreakPoint(ED.CaretY) then
           ClearBreakPoint(ED.CaretY)
         else
           SetBreakPoint(ED.CaretY);
         ED.Refresh;
        end;
  vk_F8:if fIsDebugMode and Assigned(fCurrentOPCManTemplate) then
          fCurrentOPCManTemplate.PSDebug.StepOver;

  vk_F9:if fIsDebugMode and Assigned(fCurrentOPCManTemplate) then
          OPCMan.PSRun(-1);

 end;
 fmListVars.RefreshVars;
end;

procedure TfmExplorer.SaveDebugInfo;
var i:integer;
    ini:TIniFile;
    st:TStringList;
begin
 if fFileName<>'' then
    begin
     ini:=TIniFile.Create(ExtractFilePath(ParamStr(0))+'\'+TemplatesDir+'\'+fFileName+ExtDebugInfo);
     st:=TStringList.Create;
     try
      ini.EraseSection('Breakpoints');
      for i:=0 to fDebugBreakPoints.Count-1 do
        ini.WriteInteger('Breakpoints','BP'+inttostr(i),integer(fDebugBreakPoints[i]));
      ini.WriteInteger('Others','TopLine',ED.TopLine);
      ini.WriteInteger('Others','CursorLine',ED.CaretY);
      ini.WriteInteger('Others','CursorCol',ED.CaretX);

      fmListVars.GetAllVars(st);
      ini.EraseSection('Vars');
      for i:=0 to st.Count-1 do
        ini.WriteString('Vars','V'+inttostr(i),st[i]);

     finally
      ini.Free;
      st.Free;
     end;
    end;
end;

procedure TfmExplorer.EDGutterClick(Sender: TObject; Button: TMouseButton;
  X, Y, Line: Integer; Mark: TSynEditMark);
begin
  inherited;
  if HasBreakPoint(Line) then
    ClearBreakPoint(Line)
  else
    SetBreakPoint(Line);
  ED.Refresh;  
end;

procedure TfmExplorer.BtnDebugClick(Sender: TObject);
begin
  inherited;
 if BtnDebug.Down then
  begin
   if not SetDebugMode then
    BtnDebug.Down:=false
   else
     fmListVars.RefreshVars;
  end
 else
  begin
   SetEditMode;
   fmListVars.RefreshVars;
  end;

end;

procedure TfmExplorer.wmPSBreakPoint(var Msg: TMessage);
begin
 wmPSLineInfo(Msg);
end;

procedure TfmExplorer.wmPSIdle(var Msg: TMessage);
begin
 fActiveLine:=0;
 ED.Refresh;
 fmListVars.RefreshVars;
end;

procedure TfmExplorer.wmPSLineInfo(var Msg: TMessage);
begin
 fActiveLine:=msg.LParam;
 if (FActiveLine < ED.TopLine +2) or (FActiveLine > ED.TopLine + ED.LinesInWindow -2) then
  begin
   ED.TopLine := FActiveLine - (ED.LinesInWindow div 2);
  end;
 ED.CaretY := FActiveLine;
 ED.CaretX := 1;
 ED.Refresh;
 fmListVars.RefreshVars;
end;

function TfmExplorer.SetDebugMode:boolean;
var i:integer;
begin
 SetEditMode;
 result:=false;
 //if fExplorerMode<>em_Templates then exit;
 fCurrentOPCManTemplate:=GetTemplateFromOPCMan(fFileName);
 if fCurrentOPCManTemplate=nil then exit;
 fIsDebugMode:=true;
 OPCMan.HWNDDebug:=Handle;
 result:=true;
 BtnDebug.Down:=true;
 for i:=0 to fDebugBreakPoints.Count-1 do
  fCurrentOPCManTemplate.PSDebug.SetBreakPoint(fCurrentOPCManTemplate.PSDebug.MainFileName,integer(fDebugBreakPoints[i]));
 ED.ReadOnly:=true;
 ED.SetFocus;
 ED.Color:=$00E4E4E4;//clInactiveBorder;
 Panel1.Visible:=true;

end;

procedure TfmExplorer.SetEditMode;
begin
 Panel1.Visible:=false;
 OPCMan.HWNDDebug:=0;
 //if fExplorerMode<>em_Templates then exit;
 //if not fIsDebugMode then exit;
 if fCurrentOPCManTemplate=nil then exit;
 fCurrentOPCManTemplate.PSDebug.ClearBreakPoints;
 OPCMan.PSRun(-1);
 fIsDebugMode:=false;
 BtnDebug.Down:=false;
 fCurrentOPCManTemplate:=nil;
 fActiveLine:=0;
 ED.ReadOnly:=false;
 ED.Color:=clWindow;
 ED.Refresh;

end;

function TfmExplorer.GetTemplateFromOPCMan(NameTemplate:string): THATemplate;
var i,ct:integer;
begin
 result:=nil;
 if OPCMan=nil then exit;
 ct:=OPCMan.CountTemplates;
 for i:=0 to ct-1 do
  if CompareText(OPCMan.Templates[i].NameObj,NameTemplate)=0 then
   begin
    result:=OPCMan.Templates[i];
    break;
   end;
end;

procedure TfmExplorer.SetVisibleVars;
begin
  if not fmListVars.Showing then
   begin
     fmListVars.Show;
     if Assigned(fmListVars.HostDockSite) then
      ShowDockPanel(fmListVars.HostDockSite as TPanel,true);
   end;
   fmListVars.SetFocus;

end;

procedure TfmExplorer.N11Click(Sender: TObject);
begin
  inherited;
 SetVisibleVars;
end;

procedure TfmExplorer.SCPExecute(Kind: SynCompletionType; Sender: TObject;
  var CurrentInput: String; var x, y: Integer; var CanExecute: Boolean);
begin
  inherited;
//
end;

procedure TfmExplorer.OnChangedDoc(Sender: TObject);
begin
 SetChangedDoc(true);
end;

procedure TfmExplorer.SetChangedDoc(Changed: boolean);
begin
 BtnSave.Enabled:=Changed;
 N8.Enabled:=Changed;
end;

procedure TfmExplorer.EDChange(Sender: TObject);
begin
  inherited;
 SetChangedDoc(true);
end;

procedure TfmExplorer.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var s,s1:string;

begin
  inherited;
 if fmInspector.Showing then
  fmInspector.FocusControl(nil);
 if BtnSave.Enabled then
  begin
   if fExplorerMode=em_Templates then
    begin
      s:='Шаблон '+fFileName+' был изменен.'+#13#10#13#10+'Сохранить шаблон ?';
      s1:='Шаблоны';
    end
   else
    begin
     s:='Конфигурация '+fFileName+' была изменена.'+#13#10#13#10+'Сохранить конфигурацию ?';
     s1:='Конфигурация';
    end;

   case MessageBox(handle,PChar(s),PChar(s1),MB_YESNOCANCEL or MB_ICONWARNING or MB_APPLMODAL	) of
    IDYES: BtnSaveClick(nil);
    IDCANCEL:CanClose:=false;
   end;
  end;
end;

procedure TfmExplorer.BtnCompileTemplateClick(Sender: TObject);
var s:string;
begin
  inherited;

 BuildDoc;
 case fExplorerMode of
  em_Templates  : s:='Проверка шаблона: ';
  em_Controllers: s:='Проверка конфигурации: ';
 end;
 if fmMessages.CountAll=0 then
  MessageBox(handle, PChar(s+'ОК'), 'Результат проверки', MB_ICONINFORMATION)
 else
  if fmMessages.CountErrors>0 then
   MessageBox(handle, PChar(s+'есть ошибки'), 'Результат проверки', MB_ICONINFORMATION)
  else
   MessageBox(handle, PChar(s+'есть предупреждения'), 'Результат проверки', MB_ICONINFORMATION);
end;

procedure TfmExplorer.EDMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
 if (fEDOldX<>X) or (fEDOldY<>Y) then
  begin
   fhw.ReleaseHandle;
   Timer1.Enabled:=false;
   fEDOldX:=X;
   fEDOldY:=Y;
   Timer1.Enabled:=true;
  end;
end;

procedure TfmExplorer.Timer1Timer(Sender: TObject);
var s,v:string;
    pt:TPoint;
    r:TRect;
    maxWidth:integer;
begin
  inherited;
  Timer1.Enabled:=false;
  fhw.ReleaseHandle;

  GetCursorPos(Pt);                    // mouse position (on screen)
  Pt := ED.ScreenToClient(Pt);    // convert to SynEdit coordinates
  { Make sure it fits within the SynEdit bounds }
  if (Pt.X < 0) or (Pt.Y < 0) or (Pt.X > ED.Width) or (Pt.Y> ED.Height) then EXIT;

  if not GetHAObjAtMouse(v,ED.DisplayToBufferPos(ED.PixelsToRowColumn(Pt.X,Pt.Y))) then
   v:=ed.WordAtMouse;

  s:=fmListVars.VarValue(v);
  if s<>'' then
   begin
    s:=' '+v+'='+s;

    maxWidth:=ED.Width-pt.X;
    pt:=ed.ClientToScreen(pt);
    r:=fhw.CalcHintRect(maxWidth,s,nil);
    offsetrect(r,pt.X,pt.Y);
    fhw.ActivateHint(r,s);
   end
  else
   s:='33'; 

end;

function TfmExplorer.GetHAObjAtMouse(var sHAObj: string; XY: TBufferCoord): boolean;
var i,len:integer;
    s,sl,sr:string;
    fl1,fl2:boolean;
begin
 result:=false;
 s:=ED.Lines[XY.Line-1];
 if s='' then exit;
 len:=Length(s);
 sl:=''; sr:='';
 fl1:=false; fl2:=false;
 for i:=XY.Char downto 1 do
  begin
   sl:=s[i]+sl;

   if s[i]='"' then
    fl1:=true;
   if s[i]='[' then
    fl2:=true;
   if fl1 and fl2 then break;
  end;
 if not (fl1 and fl2) then exit;

 fl1:=false; fl2:=false;
 for i:=XY.Char+1 to len do
  begin
   sr:=sr+s[i];

   if s[i]='"' then
    fl1:=true;
   if s[i]=']' then
    fl2:=true;
   if fl1 and fl2 then break;
  end;
 if not (fl1 and fl2) then exit;
 sHAObj:=sl+sr;
 result:=true;


end;

procedure TfmExplorer.wmPSExecError(var Msg: TMessage);
{Msg.WParam - указатель на строку ошибки
 Msg.LParam - указатель на структуру Msg}
var s:string;
    m:TMessage;
begin
 fActiveLine:=-1;
 s:=string(Msg.WParam);
 m:=TMessage(pointer(Msg.LParam)^);
 fmMessages.AddMessage(s,m);
 ED.Refresh;
end;

procedure TfmExplorer.EDStatusChange(Sender: TObject;
  Changes: TSynStatusChanges);
begin
  inherited;
 StatusBar1.Panels[0].Text := '  '+IntToStr(ed.CaretY)+':  '+IntToStr(ed.CaretX);

end;

procedure TfmExplorer.PaintGutterGlyphs(Line:integer);
var
  LH, X, Y: integer;
  ImgIndex: integer;
begin
 x:=14;
 LH:=ED.LineHeight;

 Y := (LH - imglGutterGlyphs.Height) div 2
           + LH * (Line - ED.TopLine);

 ImgIndex:=-1;
 if HasBreakPoint(Line) then
  begin
   if Line=fActiveLine then
    ImgIndex:=1
   else
    ImgIndex:=2;
  end
 else
  if Line=fActiveLine then
   ImgIndex:=0;

 if ImgIndex>-1 then
  imglGutterGlyphs.Draw(ED.Canvas, X, Y, ImgIndex);

{ if fIsDebugMode then
  begin

  end
 else
  begin

  end;



  if fDebugger <> nil then
  begin
    FirstLine := SynEditor.RowToLine(FirstLine);
    LastLine := SynEditor.RowToLine(LastLine);
    X := 14;
    LH := SynEditor.LineHeight;
    while FirstLine <= LastLine do
    begin
      Y := (LH - imglGutterGlyphs.Height) div 2
           + LH * (SynEditor.LineToRow(FirstLine) - SynEditor.TopLine);
      LI := fDebugger.GetLineInfos(FirstLine);
      if dlCurrentLine in LI then begin
        if dlBreakpointLine in LI then
          ImgIndex := 2
        else
          ImgIndex := 1;
      end else if dlExecutableLine in LI then begin
        if dlBreakpointLine in LI then
          ImgIndex := 3
        else
          ImgIndex := 0;
      end else begin
        if dlBreakpointLine in LI then
          ImgIndex := 4
        else
          ImgIndex := -1;
      end;
      if ImgIndex >= 0 then
        imglGutterGlyphs.Draw(ACanvas, X, Y, ImgIndex);
      Inc(FirstLine);
    end;
  end;
 }
end;


function TfmExplorer.CheckSave: boolean;
var s:string;
begin
 result:=true;
 BuildDoc;
 if fmMessages.CountErrors>0 then
  begin
  case fExplorerMode of
   em_Templates: s:=  'При проверке шаблона были обнаружены ошибки.'
                      +#13#10+'Шаблон не будет загружен при обновлении конфигурации сервера.'
                      +#13#10+'Сохранить шаблон ?';
   em_Controllers: s:=  'При проверке конфирурации были обнаружены ошибки.'
                        +#13#10+'Конфигурация не будет загружена при обновлении конфигурации сервера.'
                        +#13#10+'Сохранить конфигурацию ?';
  end;
   result:=MessageBox(handle, PChar(s), 'Результат проверки', MB_ICONINFORMATION or MB_YESNO)=IDYES;
  end;

end;

procedure TfmExplorer.BtnAddBreakPointClick(Sender: TObject);
var k:word;
begin
 k:=vk_f5;
 EDKeyDown(nil,k,[]);


end;

procedure TfmExplorer.BtnDelBreakPointClick(Sender: TObject);
begin
 fDebugBreakPoints.Clear;
 if fIsDebugMode and Assigned(fCurrentOPCManTemplate) then
  fCurrentOPCManTemplate.PSDebug.ClearBreakPoints;
 ED.Refresh;
end;

procedure TfmExplorer.CheckBtnDebug;
begin
 BtnDebug.Enabled:=GetTemplateFromOPCMan(fFileName)<>nil;
 if BtnDebug.Enabled then
  BtnDebug.Hint:='Отладка'
 else
  BtnDebug.Hint:='В текущей конфигурации шаблон не используется. Отладка невозможна';
end;


end.
