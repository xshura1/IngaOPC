unit ha_listobject;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, ExtCtrls,ha_dockfm, ComCtrls, ToolWin, ImgList,ActiveX,
  Menus,ha_types, Buttons, TB2Item, TB2Dock, TB2Toolbar;
 {$I IngaOPC.inc}
type
 // TChangeFullNameEvent=procedure (OldName,NewName:string) of object;
  TfmListObject = class(TfmDock)
    Panel1: TPanel;
    TV: TVirtualStringTree;
    ImageList1: TImageList;
    IMTv: TImageList;
    PopupMenu1: TPopupMenu;
    N1001: TMenuItem;
    N10001: TMenuItem;
    TBDock1: TTBDock;
    TBToolbar1: TTBToolbar;
    BtnDubl: TTBItem;
    BtnController: TTBItem;
    BtnCommand: TTBItem;
    BtnProp: TTBItem;
    BtnTag: TTBItem;
    BtnFolder: TTBItem;
    BtnDel: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    TBSeparatorItem2: TTBSeparatorItem;
    BtnEvent: TTBItem;
    BtnCatAE: TTBItem;
    BtnTimer: TTBItem;
    BtnTagHDA: TTBItem;
    procedure FormCreate(Sender: TObject);
    procedure TVGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure BtnTagClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure TVCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure TVPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType);
    procedure TVDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure TVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure TVGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean;
      var ImageIndex: Integer);
    procedure N1001Click(Sender: TObject);
    procedure N10001Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TVMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TVKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
  private
    { Private declarations }
    fContextNode:PVirtualNode;

    fOnChangeName:TChangeNameEvent;
    fOnChangedObj:TNotifyEvent;

    procedure DoChangeName(OldName,NewName:string);

    function GetImageIndexObj(ClassID: integer): integer;
    procedure DeleteObjs;
    function GetParentNodeForClass(ClassID:integer):PVirtualNode;
    function GetRootNodeForClassID(ClassID:integer):PVirtualNode;
    function SearchRootNodeForNode(Node:PVirtualNode): PVirtualNode;


    function CreateUniqueName(ClassID:integer; ParentNode:PVirtualNode; Head:string):string;
    function ExistsNameObj(OID,ClassID:integer; AName:string; ParentNode: PVirtualNode):boolean;
    procedure CheckBtn;
    function FullNameObj(node:PVirtualNode):string; overload;



    procedure CheckNames;
    procedure CheckTemplate;
    procedure CheckConfig;

    function GetOIDTemplate: integer;
  public
    { Public declarations }
  //  Template_Proxy:THATemplate_Proxy;
    procedure NewTemplate;
    procedure NewConfig;
    procedure GetClassAndOID(Path:TStrings; out OID,ClassID:integer);
    property OnChangeName:TChangeNameEvent read fOnChangeName write fOnChangeName;
    property OnChangedObj:TNotifyEvent read fOnChangedObj write fOnChangedObj;

    procedure GetSelectedNames(St:TStrings);
    function FullNameObj(OID:integer):string; overload;
    procedure Check;
    procedure MsgToObject(Msg:TMessage);
    function ContextSearch(Str:string):boolean;
    procedure ResetContextPosition;
    property OIDTemplate:integer read GetOIDTemplate;

    procedure FillListProps(DataItems:TList; ForCheckedObj:boolean);
  end;


 // var fmListObject:TfmListObject;
implementation
  uses ha_xmldata,ha_inspector,ha_explorer,ha_messages;
{$R *.dfm}


procedure TfmListObject.FormCreate(Sender: TObject);

begin
// Template_Proxy:=THATemplate_Proxy.Create;
 tv.NodeDataSize:=sizeof(TDataItem2);
 BtnTag.Tag:=ClassTag;
 BtnFolder.Tag:=ClassFolder;
 BtnProp.Tag:=ClassProp;
 BtnCommand.Tag:=ClassCommand;
 BtnController.Tag:=ClassController;
 BtnEvent.Tag:=ClassEvent;
 BtnCatAE.Tag:=ClassCatEvent;
 BtnTimer.Tag:=ClassTimer;
 BtnTagHDA.Tag:=ClassTagHDA;

 if TfmExplorer(Owner).ExplorerMode=em_Controllers then
  begin
   BtnProp.Visible:=false;
   BtnTag.Visible:=false;
   BtnCommand.Visible:=false;
   BtnEvent.Visible:=false;
   BtnCatAE.Visible:=false;
   BtnTimer.Visible:=false;
  end
 else
  BtnController.Visible:=false;
 CheckBtn;
end;


procedure TfmListObject.TVGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var p:PDataItem2;
begin
  P:=tv.GetNodeData(node);
  if p=nil then exit;
  if p^.LinkNode=nil then
   CellText:=P^.Name
  else
   CellText:=p^.LinkNode.Name; 
end;

procedure TfmListObject.BtnTagClick(Sender: TObject);

procedure DubleNode(NodeSource,NodeDest:PVirtualNode);
var ps,pd:PDataItem2;
    ns,nd:PVirtualNode;
begin
 ps:=tv.GetNodeData(NodeSource);
 if ps=nil then exit;
 pd:=tv.GetNodeData(NodeDest);
 if pd=nil then exit;
 pd^:=ps^;
 pd^.LinkNode:=ps^.LinkNode;
 pd^.OID:=XData.GenID;

 ns:=tv.GetFirstChild(NodeSource);
 while ns<>nil do
  begin
   nd:=tv.AddChild(NodeDest);
   ps:=tv.GetNodeData(ns);
   if ps=nil then exit;
   pd:=tv.GetNodeData(nd);
   if pd=nil then exit;
   DubleNode(ns,nd);
   ns:=tv.GetNextSibling(ns);
  end;
end;

var n,nn,n1:PVirtualNode;
    p:PDataItem2;
    ClassID:integer;
    Head:string;
  //  Proxy:THABase_Proxy;
    flDubl:boolean;
    fl:boolean;
begin
 ClassID:=TToolButton(Sender).Tag;
 flDubl:=Sender=BtnDubl;
 fl:=true;
 case ClassID of
  ClassFolder :Head:='Folder';
  ClassTag    :Head:='Tag';
  ClassProp   :Head:='Prop';
  ClassCommand:Head:='Command';
  ClassController:Head:='Device';
  ClassEvent  :Head:='Event';
  ClassTimer  :Head:='Timer';
  ClassCatEvent:Head:='Category';
  ClassTagHDA :Head:='HDA Tag';
 else
  fl:=false;
 end;

 if not fl then exit;
 n1:=nil;

 n1:=tv.FocusedNode;
 p:=tv.GetNodeData(n1);

 if p<>nil then
  if p^.ClassID=ClassID then
   Head:=p^.Name
  else
    n1:=nil;

 tv.TreeOptions.SelectionOptions:=tv.TreeOptions.SelectionOptions-[toMultiSelect];
 if flDubl and (n1<>nil) then
  n:=n1.Parent
 else
  n:=GetParentNodeForClass(ClassID);

 if n=nil then exit;

  if ClassID=ClassEvent then
   begin
    if n1=nil then
     nn:=tv.AddChild(n)
    else
     nn:=tv.AddChild(n1);
   end
  else
   nn:=tv.AddChild(n);

 p:=tv.GetNodeData(nn);

 {p^.OID:=XData.GenID;
 p^.ClassID:=ClassID;
 p^.Name:=CreateUniqueName(ClassID,n,Head);
 p^.LinkNode:=nil;}
 if flDubl then
  begin
   if n1<>nil then
    begin
     DubleNode(n1,nn);
     p^.Name:=CreateUniqueName(ClassID,n,Head);
    end;
  end
 else
  begin
     p^.OID:=XData.GenID;
     p^.ClassID:=ClassID;
     p^.Name:=CreateUniqueName(ClassID,n,Head);
     p^.LinkNode:=nil;
     case ClassID of
      ClassTag:with TIGTag_Proxy.Create do
                begin
                 AddData(p);
                 DataType:=vt_ui1;
                 Readable:=true;
                 Writeable:=true;
                 OnRead:='';
                 OnWrite:='';
                 Free;
                end;
      {$IFDEF HDAINTERFACE}
      ClassTagHDA:with TIGTagHDA_Proxy.Create do
                   begin
                     AddData(p);
                     DataType:=vt_ui1;
                     Readable:=true;
                     Writeable:=true;
                     Free;
                   end;
      {$ENDIF}

      ClassProp:with TIGProp_Proxy.Create do
                 begin
                   AddData(p);
                   DataType:=vt_ui1;
                   PropID:=5000;
                   Free;
                 end;
      ClassCommand:with TIGCommand_Proxy.Create do
                     begin
                       AddData(p);
                       NoCommand:='';
                       CountWriteBytes:=0;
                       Param:=0;
                       OnBeforeWrite:='';
                       OnAfterRead:='';
                       Free;
                     end;
      ClassController:with TIGDevice_Proxy.Create do
                       begin
                         AddData(p);
                         TemplateName:='';
                         DriverName:='';
                         Address:='';
                         Param:=0;
                         Free;
                       end;
      ClassTimer   :with TIGTimer_Proxy.Create do
                       begin
                         AddData(p);
                         Enabled:=true;
                         Interval:=1000;
                         Free;
                       end;
      ClassEvent   :with THAEvent_Proxy.Create do
                       begin
                         AddData(p);
                         Description:='';
                         Enabled:=true;
                         Severity:=500;
                         Free;
                       end;
      ClassCatEvent:with THACatEvent_Proxy.Create do
                           begin
                             AddData(p);
                             TypeEvent:=$0004;
                             Free;
                           end;
     end;
  end;

 //p^:=XData.NewObj(ClassID,CreateUniqueName(ClassID,n,Head));

 tv.TreeOptions.SelectionOptions:=tv.TreeOptions.SelectionOptions+[toMultiSelect];
 //tv.SortTree(0,sdAscending);
 tv.FocusedNode:=nn;
 tv.Selected[nn]:=true;
 tv.RepaintNode(nn);
 if Assigned(fOnChangedObj) then
  fOnChangedObj(self);
end;

procedure TfmListObject.DeleteObjs;
begin
 if tv.SelectedCount=0 then exit;
 //if MessageDlg('Удалить выделенные объекты ?',mtConfirmation,[mbYes, mbNo],0)=mrYes then
 if MessageBox(handle,'Удалить выделенные объекты ?',PChar(caption),MB_YESNO or MB_ICONQUESTION or MB_APPLMODAL	)=IDYES then
  begin
   TfmExplorer(Owner).fmInspector.Clear;
   tv.DeleteSelectedNodes;
   if Assigned(fOnChangedObj) then
    fOnChangedObj(self);
  end;
end;

procedure TfmListObject.BtnDelClick(Sender: TObject);
begin
 DeleteObjs;
end;



function TfmListObject.GetParentNodeForClass(ClassID:integer):PVirtualNode;
var n:PVirtualNode;
    p:PDataItem2;
    ClassID_:integer;
begin
 result:=nil;
 ClassID_:=ClassID;

 case TfmExplorer(Owner).ExplorerMode of
  em_Controllers:begin
                  n:=tv.FocusedNode;
                  while n<>nil do
                   begin
                    p:=tv.GetNodeData(n);
                    if p=nil then break;
                    if p^.ClassID in [ClassFolder] then
                     begin
                      result:=n;
                      break;
                     end;
                    n:=n.Parent;
                   end;
                  if result=nil then
                    result:=tv.RootNode;
                 end;
  em_Templates:case ClassID_ of
                ClassProp           :result:=GetRootNodeForClassID(ClassFolderProps);
                ClassCommand        :result:=GetRootNodeForClassID(ClassFolderCommands);
                ClassCatEvent       :result:=GetRootNodeForClassID(ClassFolderEvents);
                ClassTimer          :result:=GetRootNodeForClassID(ClassFolderTimers);
                ClassTag,
                ClassTagHDA         :begin
                                      n:=SearchRootNodeForNode(tv.FocusedNode);
                                      p:=tv.GetNodeData(n);
                                      if (p=nil) or ((p<>nil) and (p^.ClassID<>ClassFolderTags)) then
                                       result:=GetRootNodeForClassID(ClassFolderTags)
                                      else
                                       begin
                                         p:=tv.GetNodeData(tv.FocusedNode);
                                         if p^.ClassID in [ClassFolder,ClassFolderTags] then
                                          result:=tv.FocusedNode
                                         else
                                          begin
                                           n:=tv.FocusedNode;
                                           while n<>nil do
                                            begin
                                             p:=tv.GetNodeData(n);
                                             if p<>nil then
                                              if p^.ClassID in [ClassFolder,ClassFolderTags] then
                                               begin
                                                result:=n;
                                                break;
                                               end;
                                              n:=n.Parent;
                                            end;
                                         end;
                                        end;


                                     end;
                ClassFolder         :begin
                                      n:=SearchRootNodeForNode(tv.FocusedNode);
                                      p:=tv.GetNodeData(n);
                                      if (p=nil) or ((p<>nil) and (not (p^.ClassID in [ClassFolderTags]))) then
                                       result:=nil
                                      else
                                        if p^.ClassID=ClassFolderTags then
                                          begin
                                             p:=tv.GetNodeData(tv.FocusedNode);
                                             if p^.ClassID in [ClassFolder,ClassFolderTags] then
                                              result:=tv.FocusedNode
                                             else
                                              begin
                                               n:=tv.FocusedNode;
                                               while n<>nil do
                                                begin
                                                 p:=tv.GetNodeData(n);
                                                 if p<>nil then
                                                  if p^.ClassID in [ClassFolder,ClassFolderTags] then
                                                   begin
                                                    result:=n;
                                                    break;
                                                   end;
                                                  n:=n.Parent;
                                                end;
                                           end;
                                        end;
                                     end;
                ClassEvent         :begin
                                      n:=SearchRootNodeForNode(tv.FocusedNode);
                                      p:=tv.GetNodeData(n);
                                      if (p<>nil) and (p^.ClassID=ClassFolderEvents) then
                                       begin
                                         p:=tv.GetNodeData(tv.FocusedNode);
                                         if p^.ClassID in [ClassCatEvent] then
                                          result:=tv.FocusedNode
                                         else
                                          begin
                                           n:=tv.FocusedNode;
                                           while n<>nil do
                                            begin
                                             p:=tv.GetNodeData(n);
                                             if p<>nil then
                                              if p^.ClassID in [ClassCatEvent] then
                                               begin
                                                result:=n;
                                                break;
                                               end;
                                              n:=n.Parent;
                                            end;
                                         end;
                                        end;


                                     end;
               end;
 end;
 exit;
 if not (ClassID_ in [ClassTag,ClassTagHDA,ClassFolder]) then
   result:=GetRootNodeForClassID(ClassID_-HighClassFolders)
 else
  begin
    n:=tv.FocusedNode;
    p:=tv.GetNodeData(n);
    if p<>nil then
     begin
       if p^.ClassID=ClassFolderTags then
        begin
         result:=n;
         exit;
        end;


       if p^.ClassID in [ClassFolder,ClassTag,ClassTagHDA] then
         while n<>nil do
           begin
            p:=tv.GetNodeData(n);
            if p<>nil then
            if p^.ClassID in [ClassFolder,ClassFolderTags,ClassTag,ClassTagHDA] then
             begin
              result:=n;
              if p^.ClassID in [ClassTag,ClassTagHDA] then
               result:=n.Parent;
              exit;
             end;
            n:=n.Parent;
           end;
     end;

      result:=GetRootNodeForClassID(ClassFolderTags);

  end;

end;

function TfmListObject.CreateUniqueName(ClassID: integer;
  ParentNode: PVirtualNode; Head:string): string;
var i,ind:integer;
    s,k:string;
begin
 ind:=0;
 s:=trim(Head);
 if not ExistsNameObj(-1,ClassID,s,ParentNode) then
  result:=s
 else
  begin
   k:='';
   for i:=Length(s) downto 1 do
    if s[i] in ['0'..'9'] then
      k:=s[i]+k
    else
      break;
   if k<>'' then
    begin
     s:=trim(stringreplace(s,k,'',[]));
     ind:=strtoint(k);
    end;

   repeat
    inc(ind);
   until not ExistsNameObj(-1,ClassID,s+inttostr(ind),ParentNode);
   result:=s+inttostr(ind);
  end;












{ i:=1;
 s:=Head+inttostr(i);
 while ExistsNameObj(ClassID,s,ParentNode) do
  begin
   inc(i);
   s:=Head+inttostr(i);
  end;
 result:=s;  }
end;

function TfmListObject.ExistsNameObj(OID,ClassID: integer;
  AName: string; ParentNode: PVirtualNode): boolean;
var n:PVirtualNode;
    p:PDataItem2;
begin
 result:=false;
 if ParentNode=nil then exit;
 n:=ParentNode.FirstChild;
 while n<>nil do
  begin
   p:=tv.GetNodeData(n);
   if (p^.OID<>OID) and (p^.ClassID=ClassID) and (CompareStr(p^.Name,AName)=0)  then
    begin
     result:=true;
     break;
    end;
   n:=tv.GetNextSibling(n);
  end;
end;

procedure TfmListObject.CheckBtn;
{const
 ArrHint:array [6..10] of string=('Дублировать папку',
                                  'Дублировать тэг',
                                  'Дублировать свойство',
                                  'Дублировать команду',
                                  'Дублировать устройство');}
var n:PVirtualNode;

begin

 n:=tv.FocusedNode;
 if TfmExplorer(Owner).ExplorerMode=em_Templates then
  BtnDel.Enabled:=(n<>nil) and (tv.GetNodeLevel(n)>1)
 else
  BtnDel.Enabled:=(n<>nil);

 BtnDubl.Enabled:=(BtnDubl.Tag>HighClassFolders) or (BtnDubl.Tag=ClassFolder);

 if BtnDubl.Enabled then
  begin
   case BtnDubl.Tag of
     ClassFolder      :BtnDubl.ImageIndex:=6;
     ClassTag         :BtnDubl.ImageIndex:=7;
     ClassProp        :BtnDubl.ImageIndex:=8;
     ClassCommand     :BtnDubl.ImageIndex:=9;
     ClassController  :BtnDubl.ImageIndex:=10;
     ClassEvent       :BtnDubl.ImageIndex:=12;
   end;

   case BtnDubl.ImageIndex of
    6:BtnDubl.Hint:='Дублировать папку';
    7:BtnDubl.Hint:='Дублировать тэг';
    8:BtnDubl.Hint:='Дублировать свойство';
    9:BtnDubl.Hint:='Дублировать команду';
    10:BtnDubl.Hint:='Дублировать устройство';
    12:BtnDubl.Hint:='Дублировать событие';
    else
     BtnDubl.Hint:='';
   end;

  { if (BtnDubl.ImageIndex>=Low(ArrHint)) and (BtnDubl.ImageIndex<=High(ArrHint)) then
    BtnDubl.Hint:=ArrHint[BtnDubl.imageindex]
   else
    BtnDubl.Hint:='';
   }

  end;
end;

procedure TfmListObject.TVCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var p1,p2:PDataItem2;
begin
 if (tv.GetNodeLevel(Node1)=0) or (tv.GetNodeLevel(Node2)=0) then
  begin
   result:=0;
   exit;
  end;

 p1:=tv.GetNodeData(Node1);
 p2:=tv.GetNodeData(Node2);
 if p1^.ClassID<p2^.ClassID then result:=-1
 else
  if p1^.ClassID>p2^.ClassID then result:=1
  else
   result:=CompareStr(p1^.Name,p2^.Name);

end;

procedure TfmListObject.TVPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
var p:PDataItem2;
begin
  inherited;
 if TfmExplorer(Owner).ExplorerMode=em_Templates then
  begin
   if tv.GetNodeLevel(Node)in [0,1] then
    TargetCanvas.Font.Style:=TargetCanvas.Font.Style+[fsBold];
  end
 else
  begin
   p:=tv.GetNodeData(Node);
   if p=nil then exit;
   if p^.ClassID=ClassFolder then
    TargetCanvas.Font.Style:=TargetCanvas.Font.Style+[fsBold];
  end;
end;

procedure TfmListObject.TVDragOver(Sender: TBaseVirtualTree; Source: TObject;
  Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
  var Effect: Integer; var Accept: Boolean);
var 
 i,Cl: Integer;
 SelectNodes: TNodeArray;
 p:PDataItem2;
begin
 Accept := True;
 SelectNodes := Sender.GetSortedSelection(True);
 // определяем выделение объектов одного класса
 cl:=-1;
 for i:=Low(SelectNodes) to High(SelectNodes) do
  begin
   p:=tv.GetNodeData(SelectNodes[i]);
   if p=nil then continue;
   if (Cl>-1) and (p^.ClassID<>Cl) then
    begin
     Accept:=false;
     break;
    end
   else
    if Cl<0 then
     Cl:=p^.ClassID;

  end;

 if not Accept then exit;
 p:=tv.GetNodeData(tv.DropTargetNode);
 if p=nil then exit;

 case cl of
  ClassTag        :   Accept:=p^.ClassID in [ClassFolderTags,ClassFolder,ClassTag];
  ClassProp       :   Accept:=p^.ClassID in [ClassTag];
  ClassFolder     :   Accept:=p^.ClassID in [ClassFolderTags,ClassFolder,ClassTag];
  ClassController :   Accept:=p^.ClassID in [ClassFolder,ClassController];
 else
  Accept:=false;
 end;  

{ for i := low(SelectNodes) to high(SelectNodes) do
  if (Sender.HasAsParent(Sender.DropTargetNode, SelectNodes[i])) then
    // (SelectNodes[i].Parent=Sender.DropTargetNode.Parent) then
  begin
   Accept := False;
   Exit;
  end;
 }
end;

procedure TfmListObject.TVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
  DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
  Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
 SelectNodes: TNodeArray;
 PredNode,n: PVirtualNode;
 p,pl:PDataItem2;
 i: Integer;
 AddingProp:boolean;
 s,OldName,NewName:string;


begin

 AddingProp:=false;
 if Sender.DropTargetNode = nil then Exit;
 SelectNodes := Sender.GetSortedSelection(True);
 PredNode := Sender.DropTargetNode;

 p:=sender.GetNodeData(PredNode);
 if p^.ClassID=ClassTag then
  AddingProp:=true;

 if not AddingProp then
 while PredNode<>nil do
   begin
    p:=sender.GetNodeData(PredNode);
    if p<>nil then
     if p^.ClassID<HighClassFolders then
      break;
    PredNode:=PredNode.Parent;
   end;

 if (PredNode=nil) and (TfmExplorer(Owner).ExplorerMode=em_Templates) then exit;

 for i := low(SelectNodes) to high(SelectNodes) do
 begin
  if AddingProp then
   begin
     pl:=sender.GetNodeData(SelectNodes[i]);
     if pl^.ClassID=classProp then
      begin
        s:=pl^.Name;
        n:=sender.AddChild(PredNode);
        p:=sender.GetNodeData(n);
        p^.OID:=XData.GenID;
        p^.ClassID:=ClassLinkProp;
        p^.Name:='';
        p^.Props:='';
        //p^:=XData.NewObj(ClassLinkProp,'');
        p^.LinkNode:=pl;//SelectNodes[i];
        p^.Name:=s;
      end;
   end
  else
    begin
     OldName:=FullNameObj(SelectNodes[i]);
     Sender.MoveTo(SelectNodes[i], PredNode, amAddChildLast, false); // перемещаем узлы
     NewName:=FullNameObj(SelectNodes[i]);
     if PredNode<>nil then
      Sender.Expanded[PredNode]:=true;
     DoChangeName(OldName,NewName);
    end;
 // PredNode := SelectNodes[i]
 end;
 //Sender.SortTree(0,sdAscending);
 fContextNode:=nil;
 if Assigned(fOnChangedObj) then
  fOnChangedObj(self);
end;

procedure TfmListObject.TVGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var p:PDataItem2;
begin
 if Kind in [ikNormal,ikSelected] then
  begin
    p:=tv.GetNodeData(Node);
    if p=nil then exit;
    ImageIndex:=GetImageIndexObj(p^.ClassID);
    
  end;

end;

function TfmListObject.GetImageIndexObj(ClassID: integer): integer;
begin
 result:=-1;
 case Classid of
  ClassFolder,
  ClassFolderTags,
  ClassFolderCommands,
  ClassFolderProps,
  ClassFolderEvents,
  ClassFolderTimers    :result:=0;

  ClassTag             :result:=1;
  ClassProp            :result:=2;
  ClassCommand         :result:=3;
  ClassLinkProp        :result:=5;
  ClassController      :result:=4;
  ClassEvent           :result:=6;
 end;
end;

procedure TfmListObject.NewTemplate;
var n,n1:PVirtualNode;
    p:PDataItem2;
begin
 tv.Clear;
 n:=tv.AddChild(nil);
 p:=tv.GetNodeData(n);
 p.LinkNode:=nil;
 p.OID:=XData.GenID;
 p.ClassID:=ClassTemplate;
 p.Name:='Template';
 with THATemplate_Proxy.Create do
  begin
   AddData(p);
   DateCreate:=DateTimeToStr(now);
   DateLastUpdate:=DateTimeToStr(now);
   Free;
  end;



 n1:=tv.AddChild(n);
 p:=tv.GetNodeData(n1);
 p.LinkNode:=nil;
 p.OID:=XData.GenID;
 p.ClassID:=ClassFolderTags;
 p.Name:='Tags';


 n1:=tv.AddChild(n);
 p:=tv.GetNodeData(n1);
 p.LinkNode:=nil;
 p.OID:=XData.GenID;
 p.ClassID:=ClassFolderProps;
 p.Name:='Properties';

 n1:=tv.AddChild(n);
 p:=tv.GetNodeData(n1);
 p.LinkNode:=nil;
 p.OID:=XData.GenID;
 p.ClassID:=ClassFolderCommands;
 p.Name:='Commands';

 n1:=tv.AddChild(n);
 p:=tv.GetNodeData(n1);
 p.LinkNode:=nil;
 p.OID:=XData.GenID;
 p.ClassID:=ClassFolderTimers;
 p.Name:='Timers';


{ n1:=tv.AddChild(n);
 p:=tv.GetNodeData(n1);
 p.LinkNode:=nil;
 p.OID:=XData.GenID;
 p.ClassID:=ClassFolderEvents;
 p.Name:='Events';
 }

 TV.Expanded[n]:=true;

end;

procedure TfmListObject.N1001Click(Sender: TObject);
var i:integer;
begin
  inherited;
 for i:=0 to 99 do
  BtnTagClick(BtnTag);
end;

procedure TfmListObject.N10001Click(Sender: TObject);
var i:integer;
begin
  inherited;
 for i:=0 to 999 do
  BtnTagClick(BtnTag);
end;

procedure TfmListObject.GetClassAndOID(Path:TStrings; out OID,
  ClassID: integer);

function SearchNode(Root:PVirtualNode):PVirtualNode;
var n:PVirtualNode;
    p:PDataItem2;
    i:integer;
    fl:boolean;
begin
 result:=nil;
 if Root=nil then exit;
 n:=Root.FirstChild;
 i:=0;
 fl:=false;
 while n<>nil do
  begin
   p:=tv.GetNodeData(n);
   if p=nil then break;
   fl:=false;
   if CompareStr(p^.Name,path[i])=0 then
    begin
     fl:=true;
     result:=n;
     inc(i);
     if i>=path.Count then break;
     n:=n.FirstChild;
    end
   else
    n:=tv.GetNextSibling(n);
  end;

 if (i<path.Count-1) or (not fl) then
  result:=nil;
end;

var n,nTags,nProps,nCommands:PVirtualNode;
    p:PDataItem2;
begin
 OID:=-1;
 ClassID:=-1;
{ n:=tv.RootNode.FirstChild;
 while n<>nil do
  begin
   p:=tv.GetNodeData(n);
   if p=nil then break;
   case p^.ClassID of
    ClassFolderTags     : nTags:=n;
    ClassFolderProps    : nProps:=n;
    ClassFolderCommands : nCommands:=n;
   end;
   n:=tv.GetNextSibling(n);
  end;}

 nTags:=GetRootNodeForClassID(ClassFolderTags);
 nProps:=GetRootNodeForClassID(ClassFolderProps);
 nCommands:=GetRootNodeForClassID(ClassFolderCommands);
 n:=SearchNode(nTags);
 p:=tv.GetNodeData(n);
 if p<>nil then
  begin
   oid:=p^.OID;
   classid:=p^.ClassID;
   exit;
  end;

 n:=SearchNode(nCommands);
 p:=tv.GetNodeData(n);
 if p<>nil then
  begin
   oid:=p^.OID;
   classid:=p^.ClassID;
   exit;
  end;
end;



procedure TfmListObject.DoChangeName(OldName, NewName: string);
begin
 if Assigned(fOnChangeName) then
  fOnChangeName(OldName,NewName);
end;

function TfmListObject.FullNameObj(node: PVirtualNode): string;
var n:PVirtualNode;
    p:PDataItem2;
begin
 n:=node;
 result:='';
 while n<>nil do
  begin
   p:=TV.GetNodeData(n);
   if p=nil then exit;
   if p^.ClassID in [ClassFolderTags,ClassFolderProps,ClassFolderCommands] then break;
   if result='' then
    result:=p^.Name
   else
    result:=p^.Name+BranchSep+result;
   n:=n.Parent;
  end;


end;

procedure TfmListObject.GetSelectedNames(St: TStrings);
var SelectNodes: TNodeArray;
    i:integer;
begin
 St.Clear;
 SelectNodes:=tv.GetSortedSelection(true);
 for i := low(SelectNodes) to high(SelectNodes) do
  begin
   St.Add(FullNameObj(SelectNodes[i]));
  end;
end;

function TfmListObject.FullNameObj(OID: integer): string;
var n:PVirtualNode;
    p:PDataItem2;
begin
 n:=TV.GetFirst;
 result:='';
 while n<>nil do
  begin
   p:=TV.GetNodeData(n);
   if p=nil then continue;
   if p^.OID=OID then
    begin
     result:=FullNameObj(n);
     break;
    end;
   n:=TV.GetNext(n);
  end;
end;

procedure TfmListObject.Check;
begin
 CheckNames;
 if TfmExplorer(Owner).ExplorerMode=em_Templates then
  CheckTemplate
 else
  CheckConfig;
end;



procedure TfmListObject.MsgToObject(Msg: TMessage);
var n:PVirtualNode;
    p:PDataItem2;
begin
 tv.TreeOptions.SelectionOptions:=tv.TreeOptions.SelectionOptions-[toMultiSelect];
 tv.TreeOptions.SelectionOptions:=tv.TreeOptions.SelectionOptions+[toMultiSelect];
 n:=tv.GetFirst;
 while n<>nil do
  begin
   p:=tv.GetNodeData(n);
   if p<>nil then
    begin
     if p^.OID=Msg.WParam then
      begin

       tv.FocusedNode:=n;
       tv.Selected[n]:=true;
       tv.ReinitNode(n,false);
       break;
      end;
    end;

   n:=tv.GetNext(n);
  end;

end;

procedure TfmListObject.CheckNames;
var fm:TfmMessages;
    n:pVirtualNode;
    p:PDataItem2;
    m:TMessage;
begin
 fm:=TfmExplorer(Owner).fmMessages;
 if fm=nil then exit;
 n:=tv.GetFirst;
 while n<>nil do
  begin
   p:=tv.GetNodeData(n);
   if p<>nil then
    begin
     if ExistsNameObj(p^.OID, p^.ClassID,p^.Name,n.Parent) then
      begin
       m.Msg:=HAMsgListObj;
       m.WParam:=p^.OID;
       m.Result:=HATypeMsgError;
       fm.AddMessage('Объект с именем "'+FullNameObj(n)+'" уже существует',m);
      end;
    end;
   n:=tv.GetNext(n);
  end;

end;

procedure TfmListObject.CheckTemplate;
var fm:TfmMessages;

procedure SetMessage(Msg,Result:integer; OID:TOID; Message:string);
var m:TMessage;
begin
  m.Msg:=Msg;
  m.Result:=Result;
  m.WParam:=OID;
  fm.AddMessage(Message,m);
end;


procedure CheckTags(ANode:PVirtualNode);
var i,j,oid:integer;
    fl:boolean;
    m:TMessage;
    Proxy:TIGTag_Proxy;
    ProxyL:THALinkProp2_Proxy;
   // ProxyP:TIGProp_Proxy;

    str,stw:TStringList;
    n:PVirtualNode;
    p:PDataItem2;
    v,v1:olevariant;

    L:TList;
begin
 str:=TStringList.Create;
 stw:=TStringList.Create;

 Proxy:=TIGTag_Proxy.Create;
 ProxyL:=THALinkProp2_Proxy.Create;
// ProxyP:=TIGProp_Proxy.Create;
 L:=TList.Create;
 try
  TfmExplorer(Owner).OnFillEvents(pste_TagsR,str);
  TfmExplorer(Owner).OnFillEvents(pste_TagsW,stw);
  n:=ANode;
  while n<>nil do
    begin
     p:=tv.GetNodeData(n);
     if p<>nil then
      if p^.ClassID=ClassTag then
       begin
        Proxy.ClearData;
        Proxy.AddData(p);
        if Proxy.OnRead<>'' then
         begin
            fl:=false;
            for i:=0 to str.Count-1 do
             if CompareText(Trim(str[i]),Trim(Proxy.OnRead))=0 then
              begin
               fl:=true;
               break;
              end;

            if not fl then
              SetMessage(HAMsgListObj,HATypeMsgError,p^.OID,'Обработчик события тэга "'+Proxy.OnRead+'" не найден');
         end;

        if Proxy.OnWrite<>'' then
         begin
            fl:=false;
            for i:=0 to stw.Count-1 do
             if CompareText(Trim(stw[i]),Trim(Proxy.OnWrite))=0 then
              begin
               fl:=true;
               break;
              end;

            if not fl then
              SetMessage(HAMsgListObj,HATypeMsgError,p^.OID,'Обработчик события тэга "'+Proxy.OnWrite+'" не найден');
         end;

       end
      else
       if p^.ClassID=ClassLinkProp then
        begin
          ProxyL.ClearData;
          ProxyL.AddData(p);


          fl:=true;
          try
           if (ProxyL.HAProp.DataType and vt_Array)<>vt_Array then
            v:=VarAsType(ProxyL.Value,ProxyL.HAProp.DataType);
           // добавляем во временный лист свойства, значения которых должны быть уникальны
        //   ProxyP.ClearData;
        //   ProxyP.AddData(p^.LinkNode);
           if ProxyL.HAProp.UniqueValue then
            L.Add(p);

          except
            fl:=false;
            SetMessage(HAMsgListObj,HATypeMsgError,p^.OID,'Неверное значение для свойства');
          end;
        end;

     n:=tv.GetNext(n);
    end;

   for i:=0 to L.Count-1 do
    begin
     ProxyL.ClearData;
     ProxyL.AddData(l[i]);
     oid:=PDataItem2(l[i]).LinkNode.OID;
     v:=VarAsType(ProxyL.Value,ProxyL.HAProp.DataType);
     fl:=false;
     for j:=0 to L.Count-1 do
      if j<>i then
       begin
        ProxyL.ClearData;
        ProxyL.AddData(l[j]);
        if oid=PDataItem2(l[j]).LinkNode.OID then
         begin
          v1:=VarAsType(ProxyL.Value,ProxyL.HAProp.DataType);
          if VarCompareValue(v,v1)=vrEqual then
            SetMessage(HAMsgListObj,HATypeMsgError,ProxyL.OID,'Значение свойства не уникально');
         end;

       end;
    end;


 finally
  Proxy.Free;
  ProxyL.Free;
 // ProxyP.Free;
  L.Free;
  str.Free;
  stw.Free;
 end;
end;

procedure CheckProps(ANode:PVirtualNode);
var i,j,id:integer;

    m:TMessage;
    Proxy:TIGProp_Proxy;
    L:TList;
    n:PVirtualNode;
    p:PDataItem2;

function SortL(Item1,Item2:pointer):integer;
begin
 if cardinal(Item1)<cardinal(Item2) then result:=1
 else
  if cardinal(Item1)>cardinal(Item2) then result:=-1
  else
   result:=0;

end;

begin
 Proxy:=TIGProp_Proxy.Create;
 L:=TList.Create;
 try
  n:=ANode;

  while n<>nil do
   begin
     p:=tv.GetNodeData(n);
     if p<>nil then
      if p^.ClassID=ClassProp then
       begin
        Proxy.ClearData;
        Proxy.AddData(p);
        L.Add(pointer(Proxy.PropID));
       end;
     n:=tv.GetNext(n);
   end;
  L.Sort(@SortL);
  n:=ANode;
  while n<>nil do
    begin
     p:=tv.GetNodeData(n);
     if p<>nil then
      if p^.ClassID=ClassProp then
       begin
        Proxy.ClearData;
        Proxy.AddData(p);
        id:=Proxy.PropID;
        j:=0;
        for i:=0 to l.Count-1 do
         if id=cardinal(l[i]) then
          begin
           inc(j);
           if j>1 then
            break;
          end;

        if j>1 then
          SetMessage(HAMsgListObj,HATypeMsgError,p^.OID,'Идентификатор свойства не уникален');
       end;

     n:=tv.GetNext(n);
    end;
 finally
  Proxy.Free;
  L.Free;
 end;
end;


procedure CheckCommands(ANode:PVirtualNode);
var i:integer;
    fl:boolean;
    m:TMessage;
    Proxy:TIGCommand_Proxy;
    stbw,star:TStringList;
    n:PVirtualNode;
    p:PDataItem2;
begin
 stbw:=TStringList.Create;
 star:=TStringList.Create;
 Proxy:=TIGCommand_Proxy.Create;
 try
  TfmExplorer(Owner).OnFillEvents(pste_CommandsBW,stbw);
  TfmExplorer(Owner).OnFillEvents(pste_CommandsAR,star);
  n:=ANode;

  while n<>nil do
    begin
     p:=tv.GetNodeData(n);
     if p<>nil then
      if p^.ClassID=ClassCommand then
       begin
        Proxy.ClearData;
        Proxy.AddData(p);

        if Proxy.NoCommand='' then
          SetMessage(HAMsgListObj,HATypeMsgWarning,p^.OID,'Не заполнено поле "Номер команды"');



        if Proxy.OnBeforeWrite<>'' then
         begin
            fl:=false;
            for i:=0 to stbw.Count-1 do
             if CompareText(Trim(stbw[i]),Trim(Proxy.OnBeforeWrite))=0 then
              begin
               fl:=true;
               break;
              end;

            if not fl then
              SetMessage(HAMsgListObj,HATypeMsgError,p^.OID,'Обработчик события команды "'+Proxy.OnBeforeWrite+'" не найден');
         end;

        if Proxy.OnAfterRead<>'' then
         begin
            fl:=false;
            for i:=0 to star.Count-1 do
             if CompareText(Trim(star[i]),Trim(Proxy.OnAfterRead))=0 then
              begin
               fl:=true;
               break;
              end;

            if not fl then
              SetMessage(HAMsgListObj,HATypeMsgError,p^.OID,'Обработчик события команды "'+Proxy.OnAfterRead+'" не найден');
         end;

        if (Proxy.Priority<1) or (Proxy.Priority>10000) then
             SetMessage(HAMsgListObj,HATypeMsgError,p^.OID,'Приоритет команды должен быть в диапазоне 1-10000');

       end;
     n:=tv.GetNext(n);
    end;
 finally
  Proxy.Free;
  stbw.Free;
  star.Free;
 end;
end;


procedure CheckAE(ANode:PVirtualNode);
var i:integer;
    fl:boolean;
    m:TMessage;
    Proxy:THAEvent_Proxy;
    st:TStringList;
    n:PVirtualNode;
    p:PDataItem2;
begin
 st:=TStringList.Create;
 Proxy:=THAEvent_Proxy.Create;
 try
  TfmExplorer(Owner).OnFillEvents(pste_EventDef,st);
  n:=ANode;

  while n<>nil do
    begin
     p:=tv.GetNodeData(n);
     if p<>nil then
      if p^.ClassID=ClassEvent then
       begin
        Proxy.ClearData;
        Proxy.AddData(p);

        if not Proxy.Enabled then
          SetMessage(HAMsgListObj,HATypeMsgWarning,p^.OID,'Событие '+Proxy.NameObj+' не активно');

        if Proxy.Description='' then
          SetMessage(HAMsgListObj,HATypeMsgWarning,p^.OID,'Не заполнено строковое описание события');


        if Proxy.OnCheckDefinition<>'' then
         begin
            fl:=false;
            for i:=0 to st.Count-1 do
             if CompareText(Trim(st[i]),Trim(Proxy.OnCheckDefinition))=0 then
              begin
               fl:=true;
               break;
              end;

            if not fl then
              SetMessage(HAMsgListObj,HATypeMsgError,p^.OID,'Обработчик условия события "'+Proxy.OnCheckDefinition+'" не найден');
         end;
       end;
     n:=tv.GetNext(n);
    end;
 finally
  Proxy.Free;
  st.Free;
 end;
end;



var n:pVirtualNode;
    
begin
 fm:=TfmExplorer(Owner).fmMessages;
 if fm=nil then exit;
 n:=GetRootNodeForClassID(ClassFolderTags);
 CheckTags(n);

 n:=GetRootNodeForClassID(ClassFolderProps);
 CheckProps(n);

 n:=GetRootNodeForClassID(ClassFolderCommands);
 CheckCommands(n);

 n:=GetRootNodeForClassID(ClassFolderEvents);
 CheckAE(n);


{
 n:=tv.RootNode.FirstChild;
 while n<>nil do
  begin
   p:=tv.GetNodeData(n);
   if p<>nil then
    case p^.ClassID of
     ClassFolderTags:CheckTags(n);
     ClassFolderProps:CheckProps(n);
     ClassFolderCommands:CheckCommands(n);
    end;
   n:=tv.GetNextSibling(n);
  end;
 }

end;

function TfmListObject.GetRootNodeForClassID(ClassID: integer): PVirtualNode;
var n,ntmp:PVirtualNode;
    p:PDataItem2;

begin
 result:=nil;
 if not (ClassID in [ClassTemplate,ClassFolderTags,ClassFolderProps,ClassFolderCommands,ClassFolderEvents,ClassFolderTimers]) then exit;

 n:=TV.GetFirst;
 p:=tv.GetNodeData(n);
 if p=nil then exit;
 if p^.ClassID=ClassTemplate then
  ntmp:=n;
 if ClassId=ClassTemplate then
  begin
   result:=ntmp;
   exit;
  end;


 n:=TV.GetFirstChild(ntmp);
 while n<>nil do
  begin
   p:=tv.GetNodeData(n);
   if p<>nil then
    if p^.ClassID=ClassID then
      begin
       result:=n;
       break;
      end;
   n:=tv.GetNextSibling(n);
  end;

 if result=nil then
  case ClassID of
   ClassFolderTimers:begin
                      n:=tv.AddChild(ntmp);
                      p:=tv.GetNodeData(n);
                      if p<>nil then
                       begin
                        p.LinkNode:=nil;
                        p.OID:=XData.GenID;
                        p.ClassID:=ClassFolderTimers;
                        p.Name:='Timers';
                        result:=n;
                       end;
                     end;
  end;                   

end;

procedure TfmListObject.FormDestroy(Sender: TObject);
begin
  inherited;
// Template_Proxy.Free;
end;

function TfmListObject.SearchRootNodeForNode(Node:PVirtualNode): PVirtualNode;
var n:PVirtualNode;
    lev:integer;
begin
 result:=nil;
 n:=Node;
 while n<>nil do
  begin
   lev:=tv.GetNodeLevel(n);
   if lev=1 then
    begin
     result:=n;
     break;
    end
   else
    if lev<1 then exit; 
   n:=n.Parent;
  end;

end;

function TfmListObject.ContextSearch(Str: string): boolean;
var n:PVirtualNode;
    p:PDataItem2;
begin
 result:=false;
 if fContextNode=nil then
  n:=tv.GetFirst
 else
  n:=TV.GetNext(fContextNode);

 tv.TreeOptions.SelectionOptions:=tv.TreeOptions.SelectionOptions-[toMultiSelect];
 try
   while n<>nil do
    begin
     p:=tv.GetNodeData(n);
     if p<>nil then
     if pos(UpperCase(Str),UpperCase(p^.Name))>0 then
      begin
       result:=true;
       fContextNode:=n;
       break;
      end;
     n:=tv.GetNext(n);
    end;
 finally
  tv.TreeOptions.SelectionOptions:=tv.TreeOptions.SelectionOptions+[toMultiSelect];
  if result then
   begin
    tv.FocusedNode:=n;
    tv.Selected[n]:=true;
    tv.RepaintNode(n);
   end;
 end; 
end;

procedure TfmListObject.ResetContextPosition;
begin
 fContextNode:=nil;
end;

procedure TfmListObject.NewConfig;
begin
 tv.Clear;
end;

function TfmListObject.GetOIDTemplate: integer;
var p:PDataItem2;
begin
 result:=-1;
 p:=TV.GetNodeData(TV.GetFirst);
 if p=nil then exit;
 if p^.ClassID<>ClassTemplate then exit;
 result:=p^.OID;
end;

procedure TfmListObject.TVMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var n:PVirtualNode;
begin
  inherited;
 n:=tv.GetNodeAt(x,y);
 if n=nil then
  begin
   tv.ClearSelection;
   tv.FocusedNode:=nil;
  end;

end;


procedure TfmListObject.CheckConfig;
var fm:TfmMessages;

procedure SetMessage(Msg,Result:integer; OID:TOID; Message:string);
var m:TMessage;
begin
  m.Msg:=Msg;
  m.Result:=Result;
  m.WParam:=OID;
  fm.AddMessage(Message,m);
end;

procedure CheckDevice(p:PDataItem2);
var m:TMessage;
    Proxy:TIGDevice_Proxy;
begin
 Proxy:=TIGDevice_Proxy.Create;
 try
  Proxy.AddData(p);
  if Proxy.TemplateName='' then
    SetMessage(HAMsgListObj,HATypeMsgError,p^.OID,'Не задан шаблон для устройства: '+p^.Name);

  if Proxy.DriverName='' then
    SetMessage(HAMsgListObj,HATypeMsgError,p^.OID,'Не задан драйвер для устройства: '+p^.Name);

  if Proxy.Address='' then
    SetMessage(HAMsgListObj,HATypeMsgWarning,p^.OID,'Не заполнен адрес для устройства: '+p^.Name);

  if not Proxy.Active then
    SetMessage(HAMsgListObj,HATypeMsgWarning,p^.OID,'Устройство: '+p^.Name+' не активно');

 finally
  Proxy.Free;
 end;
end;

var p:PDataItem2;
    n:PVirtualNode;
begin
 fm:=TfmExplorer(Owner).fmMessages;
 if fm=nil then exit;
 n:=TV.GetFirst;
 while n<>nil do
  begin
   p:=TV.GetNodeData(n);
   if p<>nil then
    if p^.ClassID=ClassController then
     CheckDevice(p);
   n:=TV.GetNext(n);
  end;
end;

procedure TfmListObject.TVKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
 SelectNodes: TNodeArray;
 i:integer;
 n,n1:PVirtualNode;
 p:PDataItem2;
 OldName,NewName:string;
begin
  inherited;
 if (ssShift in Shift) and (ssCtrl in Shift) then
  begin
   if tv.SelectedCount=0 then exit;
   SelectNodes := tv.GetSortedSelection(True);
   if TfmExplorer(Owner).ExplorerMode=em_Templates then
    begin
     p:=tv.GetNodeData(SelectNodes[0]);
     if p=nil then exit;
     if p.ClassID in [ClassTemplate, ClassFolderTags, ClassFolderProps,  ClassFolderCommands, ClassFolderEvents] then exit;
    end;

   case Key of
    VK_LEFT:begin
             if TfmExplorer(Owner).ExplorerMode=em_Templates then
              begin
               p:=tv.GetNodeData(SelectNodes[0].Parent);
               if p=nil then exit;
               if p.ClassID in [ClassFolderTags, ClassFolderProps,  ClassFolderCommands, ClassFolderEvents] then exit;
              end;
             if tv.GetNodeLevel(SelectNodes[0])>0 then
             for i:=Low(SelectNodes) to High(SelectNodes) do
              begin
               OldName:=FullNameObj(SelectNodes[i]);
               tv.MoveTo(SelectNodes[i], SelectNodes[i].Parent.Parent, amAddChildLast, false); // перемещаем узлы
               NewName:=FullNameObj(SelectNodes[i]);
               DoChangeName(OldName,NewName);
              end;
            end;
    VK_RIGHT:begin
              if TfmExplorer(Owner).ExplorerMode=em_Templates then
              begin
               p:=tv.GetNodeData(SelectNodes[0]);
               if p=nil then exit;
               if p.ClassID in [ClassFolderTags, ClassFolderProps,  ClassFolderCommands, ClassFolderEvents] then exit;
              end;
              n:=SelectNodes[0];
              n1:=nil;
              while n<>nil do
               begin
                 n:=n.PrevSibling;
                 p:=tv.GetNodeData(n);
                 if p<>nil then
                  if p.ClassID=classfolder then
                   begin
                    n1:=n;
                    break;
                   end;
               end;
              if n1=nil then exit;
              for i:=Low(SelectNodes) to High(SelectNodes) do
               begin
                OldName:=FullNameObj(SelectNodes[i]);
                tv.MoveTo(SelectNodes[i], n1, amAddChildLast, false); // перемещаем узлы
                NewName:=FullNameObj(SelectNodes[i]);
                if n1<>nil then
                 tv.Expanded[n1]:=true;
                DoChangeName(OldName,NewName);

               end;
             end;

     VK_UP : begin
              n1:=SelectNodes[0].PrevSibling;
              if n1=nil then exit;
              if tv.GetNodeLevel(n1)<>tv.GetNodeLevel(SelectNodes[0]) then exit;
              for i:=Low(SelectNodes) to High(SelectNodes) do
                tv.MoveTo(SelectNodes[i], n1, amInsertBefore, false); // перемещаем узлы
             end;

     VK_DOWN :begin
                n1:=SelectNodes[High(SelectNodes)].NextSibling;
                if n1=nil then exit;
                if tv.GetNodeLevel(n1)<>tv.GetNodeLevel(SelectNodes[0]) then exit;
                for i:=Low(SelectNodes) to High(SelectNodes) do
                 begin
                  tv.MoveTo(SelectNodes[i], n1, amInsertAfter, false); // перемещаем узлы
                  n1:=SelectNodes[i];
                 end;
              end;
   end;

    if Assigned(fOnChangedObj) then
     fOnChangedObj(self);
  end;
end;

procedure TfmListObject.FillListProps(DataItems: TList; ForCheckedObj: boolean);
var n,n1:PVirtualNode;
    p:PDataItem2;
begin
 if ForCheckedObj then
  begin

  end
 else
  begin
   n:=GetRootNodeForClassID(ClassFolderProps);
   if n=nil then exit;
   n:=TV.GetFirstChild(n);
   while n<>nil do
    begin
     p:=TV.GetNodeData(n);
     if p<>nil then
      DataItems.Add(p);
     n:=TV.GetNextSibling(n); 
    end;
  end;
end;

procedure TfmListObject.TVChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var p:PDataItem2;
begin
  inherited;
 if TfmExplorer(Owner).fmInspector.Showing then
  TfmExplorer(Owner).fmInspector.Inspect(sender);

  
 BtnDubl.Tag:=0;
 if TV.SelectedCount=1 then
  begin
   p:=tv.GetNodeData(tv.GetFirstSelected);
   if p^.ClassID<>ClassLinkProp then
   BtnDubl.Tag:=p^.ClassID;

   

  end;
 tv.SetFocus;
 CheckBtn;

end;

end.
