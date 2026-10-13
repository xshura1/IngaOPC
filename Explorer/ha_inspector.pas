unit ha_inspector;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,ha_dockfm, VirtualTrees, ExtCtrls, ComCtrls, PageControlEx,ha_types,
  StdCtrls, GsvObjectInspectorGrid,GsvObjectInspectorTypes, Buttons;
  
{$I IngaOPC.inc}

type

  EExistsNameError=class(Exception);

  TNeedValuePropEvent=procedure (TypeEvent:TPSTypeEvent; NewEvent:boolean; var Value:string) of object;
  TFillEventsEvent=procedure (TypeEvent:TPSTypeEvent; St:TStrings) of object;


  TfmInspector = class(TfmDock)
    Panel1: TPanel;
    PageControl: TPageControlEx;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Panel2: TPanel;
    Edit1: TEdit;
    OI: TGsvObjectInspectorGrid;
    SpeedButton1: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure Panel2Resize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OIEnumProperties(Sender: TObject; Index: Integer;
      out Info: PGsvObjectInspectorPropertyInfo);
    procedure OIFillList(Sender: TObject;
      Info: PGsvObjectInspectorPropertyInfo; List: TStrings);
    procedure OIGetIntegerValue(Sender: TObject;
      Info: PGsvObjectInspectorPropertyInfo; out Value: Integer);
    procedure OIGetStringValue(Sender: TObject;
      Info: PGsvObjectInspectorPropertyInfo; out Value: String);
    procedure OINeedValueProp(Sender: TObject;
      Info: PGsvObjectInspectorPropertyInfo; var Value: String);
    procedure OISetIntegerValue(Sender: TObject;
      Info: PGsvObjectInspectorPropertyInfo; const Value: Integer);
    procedure OISetStringValue(Sender: TObject;
      Info: PGsvObjectInspectorPropertyInfo; const Value: String);
    procedure OIShowDialog(Inspector: TComponent;
      Info: PGsvObjectInspectorPropertyInfo; const EditRect: TRect);
    procedure PageControlChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
    fTV:TBaseVirtualTree;
    ObjectManager:   TGsvObjectInspectorObjectInfo;
    Proxy:THABase_Proxy;

    fClassID:integer;
    fSingleNode:PVirtualNode;

    fOnChangedProp:TNotifyEvent;


    fOnNeedValueProp:TNeedValuePropEvent;
    fOnFillEvents:TFillEventsEvent;
    fOnChangeName:TChangeNameEvent;

    procedure DoNeedValueProp(TypeEvent:TPSTypeEvent; NewEvent:boolean; var Value:string);
    procedure DoFillEvents(TypeEvent:TPSTypeEvent; St:TStrings);
    procedure DoChangeName(OldName,NewName:string);

    function FullNameObj(node:PVirtualNode):string;

    function GetDiscriptorProp(NameProp:string):string;
    procedure InspectProp(TV: TBaseVirtualTree);


  public
    { Public declarations }
    procedure Inspect(TV:TBaseVirtualTree);
    procedure Inspect2(DataItems:TList);

    procedure Clear;
    property CurrClassID:integer read fClassID;
    property OnChangedProp:TNotifyEvent read fOnChangedProp write fOnChangedProp;
    property OnNeedValueProp:TNeedValuePropEvent read fOnNeedValueProp write fOnNeedValueProp;
    property OnFillEvents:TFillEventsEvent read fOnFillEvents write fOnFillEvents;
    property OnChangeName:TChangeNameEvent read fOnChangeName write fOnChangeName;
  
  end;

implementation
   uses ActiveX,ha_explorer,ha_xmlData,ha_utils,HA_fmEditArrayValue,HA_fmMemoDialog,HA_InspectorProps;
{$R *.dfm}




procedure TfmInspector.FormCreate(Sender: TObject);
begin
  inherited;

 PageControl.Visible:=TfmExplorer(Owner).ExplorerMode=em_Templates;
 ObjectManager:=TGsvObjectInspectorObjectInfo.Create;
end;

procedure TfmInspector.Inspect(TV:TBaseVirtualTree);
var
    p:PDataItem2;
    fl:boolean;
    narr:TNodeArray;
    i:integer;
    fLinkClassID:TOID;
begin
 Clear;
 fTV:=TV;
 fl:=true;
 fClassID:=-1;
 fLinkClassID:=-1;
 Edit1.Text:='';
 narr:=tv.GetSortedSelection(true);
 for i:=Low(narr) to High(narr) do
  begin
   p:=tv.GetNodeData(narr[i]);
   if fClassID<0 then
    begin
     fClassID:=p^.ClassID;
     if p^.LinkNode<>nil then
      fLinkClassID:=p^.linkNode.ClassID;
     continue;
    end;

   if (p^.ClassID<>fClassID) then
    begin
     fl:=false;
     break;
    end
   else
    if (p^.LinkNode<>nil) then
     if fLinkClassID<>p^.LinkNode.ClassID then
      begin
       fl:=false;
       break;
      end;

  { p:=tv.GetNodeData(narr[i]);
   if (fClassID>-1) and (p^.ClassID<>fClassID) then
    begin
     fl:=false;
     break;
    end;
   else
    if fClassID<0 then
     fClassID:=p^.ClassID;
   }
  end;

 if Length(narr)=0 then exit;
 if not fl then exit;

 case fClassID of
  ClassTemplate  :Proxy:=THATemplate_Proxy.Create;
  ClassFolder    :Proxy:=THABase_Proxy.Create;
  ClassTag       :Proxy:=TIGTag_Proxy.Create;
  ClassProp      :Proxy:=TIGProp_Proxy.Create;
  ClassCommand   :Proxy:=TIGCommand_Proxy.Create;
  ClassLinkProp  :begin
    //               Proxy:=THALinkProp_Proxy.Create;
                   Proxy:=THALinkProp2_Proxy.Create;
                  // THALinkProp2_Proxy(Proxy).HAProp:=TIGProp_Proxy.Create;
                  end;
  ClassController:Proxy:=TIGDevice_Proxy.Create;
  ClassEvent     :Proxy:=THAEvent_Proxy.Create;
  ClassCatEvent  :Proxy:=THACatEvent_Proxy.Create;
  ClassTimer     :Proxy:=TIGTimer_Proxy.Create;

  {$IFDEF HDAINTERFACE}
  ClassTagHDA    :Proxy:=TIGTagHDA_Proxy.Create;
  {$ENDIF}
 end;

 if Proxy=nil then exit;
 if Length(narr)=1 then
  fSingleNode:=narr[0];

 for i:=Low(narr) to High(narr) do
  begin
   p:=tv.GetNodeData(narr[i]);
   if p<>nil then
     Proxy.AddData(p)
  end;

 ObjectManager.TheObject := Proxy;
 if Assigned(ObjectManager.TheObject) then
   OI.NewObject
 else
  begin
   OI.Clear;
   FreeAndNil(Proxy);
  end;

 if fSingleNode<>nil then
  Edit1.Text:=FullNameObj(fSingleNode);
end;


function TfmInspector.FullNameObj(node: PVirtualNode): string;
var n:PVirtualNode;
    p:PDataItem2;
begin
 n:=node;
 result:='';
 while n<>nil do
  begin
   p:=fTV.GetNodeData(n);
   if p=nil then exit;
   if p^.ClassID in [ClassFolderTags,ClassFolderProps,ClassFolderCommands] then break;
   if result='' then
    result:=p^.Name
   else
    result:=p^.Name+BranchSep+result;
   n:=n.Parent;
  end;
end;

procedure TfmInspector.Panel2Resize(Sender: TObject);
begin
  inherited;
// Edit1.Width:=Panel2.Width;
end;

function TfmInspector.GetDiscriptorProp(NameProp: string): string;
begin
 result:='';
 case fClassID of
  ClassTag:if CompareText('Name',NameProp)=0 then
            result:='Имя тэга используется для доступа ОРС клиентов'
           else
            if CompareText('TypeTag',NameProp)=0 then
             result:='Тип данных тэга'
            else
             if CompareText('Readable',NameProp)=0 then
              result:='Значение тэга доступно для чтения'
             else
              if CompareText('Writeable',NameProp)=0 then
               result:='Значение тэга доступно для записи'
              else
               if CompareText('OnRead',NameProp)=0 then
                result:='Событие возникает при чтении значения тэга'
               else
                if CompareText('OnWrite',NameProp)=0 then
                 result:='Событие возникает при записи значения в тэг'
                else
                 if CompareText('OnCalc',NameProp)=0 then
                  result:='Событие возникает при вычислении значения тэга';

  ClassProp:if CompareText('TypeProp',NameProp)=0 then
             result:='Тип данных свойства'
            else
             if CompareText('PropID',NameProp)=0 then
              result:='Идентификатор свойства. Идетификатор пользовательского свойства начинается с 5000. Для более подробной информации см. спецификацию OPC DA2';

  ClassLinkProp:if CompareText('TypeProp',NameProp)=0 then
                result:='Тип данных свойства'
                else
                 if CompareText('PropID',NameProp)=0 then
                  result:='Идентификатор свойства. Идетификатор пользовательского свойства начинается с 5000. Для более подробной информации см. спецификацию OPC DA2'
                 else
                  if CompareText('Value',NameProp)=0 then
                  result:='Значение свойства';



 end;
end;


procedure TfmInspector.FormDestroy(Sender: TObject);
begin
 inherited;
 Clear;
 ObjectManager.Free;
end;

procedure TfmInspector.OIEnumProperties(Sender: TObject; Index: Integer;
  out Info: PGsvObjectInspectorPropertyInfo);
begin
 Info := ObjectManager.PropertyInfo(Index);
 if Info<>nil then
 if Info.TheObject is THALinkProp2_Proxy then
  begin
   if CompareText(Info.Name,'Value')<>0 then exit;
   if (THALinkProp2_Proxy(Info.TheObject).HAProp.DataType and vt_Array)=vt_Array then
    Info.Kind:=pkDialog;
  end;
end;

procedure TfmInspector.OIFillList(Sender: TObject;
  Info: PGsvObjectInspectorPropertyInfo; List: TStrings);
begin
 try
    if info.Kind=pkEvent then
     begin
      if (CompareText('OnRead',Info.Name)=0) then
       DoFillEvents(pste_TagsR,List)
      else
        if (CompareText('OnWrite',Info.Name)=0) then
         DoFillEvents(pste_TagsW,List)
      else
       if (CompareText('OnBeforeWrite',Info.Name)=0) then
        DoFillEvents(pste_CommandsBW,List)
       else
         if (CompareText('OnAfterRead',Info.Name)=0) then
           DoFillEvents(pste_CommandsAR,List)
         else
          if CompareText('OnCheckDefinition',Info.Name)=0 then
           DoFillEvents(pste_EventDef,List)
         else
          if (CompareText('OnActivateDevice',Info.Name)=0) or (CompareText('OnDeactivateDevice',Info.Name)=0) then
           DoFillEvents(pste_Device,List)
          else
           if CompareText('OnTimer',Info.Name)=0 then
             DoFillEvents(pste_Timer,List);



     end
    else
     if CompareText('TemplateName',Info.Name)=0 then
       XData.GetAllTemplates(List)
      else
       if CompareText('DriverName',Info.Name)=0 then
        XData.DriverInfo.GetDrivers(List,false)
       else
        ObjectManager.FillList(Info, List);
  except
  //  on E: Exception do
  //    StatusMessage('Error: ' + E.Message);
  end;
end;

procedure TfmInspector.OIGetIntegerValue(Sender: TObject;
  Info: PGsvObjectInspectorPropertyInfo; out Value: Integer);
begin
  try
    Value := ObjectManager.GetIntegerValue(Info);
  except
   // on E: Exception do
   //   StatusMessage('Error: ' + E.Message);
  end;

end;

procedure TfmInspector.OIGetStringValue(Sender: TObject;
  Info: PGsvObjectInspectorPropertyInfo; out Value: String);
begin
  try
    Value := ObjectManager.GetStringValue(Info);
  except
   // on E: Exception do
   //   StatusMessage('Error: ' + E.Message);
  end;

end;

procedure TfmInspector.OINeedValueProp(Sender: TObject;
  Info: PGsvObjectInspectorPropertyInfo; var Value: String);
var fl:boolean;
    
begin
  if Value='' then
   begin
    Value:=format(FormatScriptProc,[THABase_Proxy(Info.TheObject).NameObj])+Info.Name;
    //Value:=Info.Name;
    fl:=true;
   end
  else
   fl:=false;

  if (CompareText('OnRead',Info.Name)=0) then
    DoNeedValueProp(pste_TagsR,fl,value)
  else
    if (CompareText('OnWrite',Info.Name)=0) then
      DoNeedValueProp(pste_TagsW,fl,value)
      else
       if (CompareText('OnBeforeWrite',Info.Name)=0) then
        DoNeedValueProp(pste_CommandsBW,fl,value)
       else
         if (CompareText('OnAfterRead',Info.Name)=0) then
          DoNeedValueProp(pste_CommandsAR,fl,value)
         else
          if CompareText('OnCheckDefinition',Info.Name)=0 then
           DoNeedValueProp(pste_EventDef,fl,value)
          else
           if (CompareText('OnActivateDevice',Info.Name)=0) or (CompareText('OnDeactivateDevice',Info.Name)=0) then
            DoNeedValueProp(pste_Device,fl,value)
           else
            if CompareText('OnTimer',Info.Name)=0 then
              DoNeedValueProp(pste_Timer,fl,value);
end;

procedure TfmInspector.OISetIntegerValue(Sender: TObject;
  Info: PGsvObjectInspectorPropertyInfo; const Value: Integer);
begin
  try
    ObjectManager.SetIntegerValue(Info, Value);
    if Assigned(fOnChangedProp) then
     fOnChangedProp(self);
  except
    on E: Exception do
     MessageBox(handle,PChar(E.Message),PChar(Caption),MB_OK or MB_ICONERROR or MB_APPLMODAL	);
   //   StatusMessage('Error: ' + E.Message);
  end;

end;

procedure TfmInspector.OISetStringValue(Sender: TObject;
  Info: PGsvObjectInspectorPropertyInfo; const Value: String);
var s:string;
begin
  try
    if comparetext(Info.Name,'NameObj')=0 then
     // raise EExistsNameError.Create('Объект с таким именем уже существует');
     s:=TfmExplorer(Owner).fmListObject.FullNameObj(THABase_Proxy(Info.TheObject).OID);

    ObjectManager.SetStringValue(Info, Value);
    if CompareText(Info.Name,'NameObj')=0 then
     if fSingleNode<>nil then
      begin
       DoChangeName(s,TfmExplorer(Owner).fmListObject.FullNameObj(THABase_Proxy(Info.TheObject).OID));
       fTV.ReinitNode(fSingleNode,false);
       fTV.RepaintNode(fSingleNode);
      end;
    if Assigned(fOnChangedProp) then
     fOnChangedProp(self);
  except
    //on E: Exception do
    //  ShowMessage('Error: ' + E.Message);
   on E: Exception do
     MessageBox(handle,PChar(E.Message),PChar(Caption),MB_OK or MB_ICONERROR or MB_APPLMODAL	); 
  end;

end;

procedure TfmInspector.OIShowDialog(Inspector: TComponent;
  Info: PGsvObjectInspectorPropertyInfo; const EditRect: TRect);
var ws:widestring;
begin
  try
   if Info=nil then exit;
   if CompareText(Info.Name,'Value')=0 then
     begin
       ws:=THALinkProp2_Proxy(Info.TheObject).GetValueAsHexStr;
       if EditArrayValue(THALinkProp2_Proxy(Info.TheObject).HAProp.NameObj, THALinkProp2_Proxy(Info.TheObject).HAProp.DataType and varTypeMask, ws) then
        begin
         THALinkProp2_Proxy(Info.TheObject).Value:=ws;
         if Assigned(fOnChangedProp) then
           fOnChangedProp(self);
        end;
     end
   else
    if CompareText(Info.Name,'Description')=0 then
     begin
      with TfmMemoDialog.Create(Info.Caption) do
       begin
        Text:=THATemplate_Proxy(Info.TheObject).Description;
        if showmodal=mrOk then
         begin
          THABase_Proxy(Info.TheObject).Description:=Text;
          if Assigned(fOnChangedProp) then
           fOnChangedProp(self);
         end;
       end;
     end
    else
     ObjectManager.ShowDialog(Inspector, Info, EditRect);
  except
    //on E: Exception do
   //   StatusMessage('Error: ' + E.Message);
  end;

end;

procedure TfmInspector.PageControlChange(Sender: TObject);
begin
  inherited;
// OI.Clear;
// ObjectManager.TheObject:=nil;

 if PageControl.TabIndex=0 then
  OI.TypeVisibleProps:=vp_Props
 else
  OI.TypeVisibleProps:=vp_Events;
// ObjectManager.TheObject := Proxy;
// if Assigned(ObjectManager.TheObject) then
//   OI.NewObject;
 OI.Refresh;
end;

procedure TfmInspector.Clear;
begin
 OI.Clear;
 ObjectManager.TheObject:=nil;
 fSingleNode:=nil;
 if Proxy<>nil then
  FreeAndNil(Proxy);
end;

procedure TfmInspector.DoFillEvents(TypeEvent: TPSTypeEvent; St: TStrings);
begin
 if Assigned(fOnFillEvents) then
  fOnFillEvents(TypeEvent,St);
end;

procedure TfmInspector.DoNeedValueProp(TypeEvent: TPSTypeEvent;
 NewEvent:boolean; var Value: string);
begin
 if Assigned(fOnNeedValueProp) then
  fOnNeedValueProp(TypeEvent,NewEvent,Value);
end;

procedure TfmInspector.DoChangeName(OldName, NewName: string);
begin
 Edit1.Text:=NewName;
 if Assigned(fOnChangeName) then
  fOnChangeName(OldName,NewName);
end;

procedure TfmInspector.InspectProp(TV: TBaseVirtualTree);
begin

end;

procedure TfmInspector.Inspect2(DataItems: TList);
begin

end;

procedure TfmInspector.SpeedButton1Click(Sender: TObject);
begin
  inherited;
 TfmInspectorProps.Create(Owner).Show;
end;

end.
