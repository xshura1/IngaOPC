unit HA_ListVars;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ha_dockfm, VirtualTrees, ExtCtrls,uPSRuntime,typinfo,uPSCompiler,regexpr,
  Menus;

type
  TfmListVars = class(TfmDock)
    Panel1: TPanel;
    tv: TVirtualStringTree;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    procedure tvGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure tvDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure tvMeasureItem(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; var NodeHeight: Integer);
    procedure tvInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure tvPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
  private
    { Private declarations }

    function GetVarDebug(VarName:string):PPSVariant;
    function GetVarValue(P:PPSVariant):string;
 //   function VarObjToPObj(VarObj:string; out UserName:string):string;
  public
    { Public declarations }
    procedure RefreshVars;
    procedure GetAllVars(Vars:TStrings);
    procedure AddVarDebug(VarName:string);
    procedure ClearVars;
    function VarValue(VarName:string):string;

  end;



implementation
  uses uPSUtils,ha_classes, uPSDebugger,ha_explorer,ha_utils,ha_types;
{$R *.dfm}

 type
  PPSNodeData=^TPSNodeData;
  TPSNodeData=record
   VarName   :widestring;
  { UserName  :widestring;
   Name      :widestring;
   Value     :widestring;
   IsBaseObj :boolean;
   }
  // PSTypeData:integer;
  end;

procedure TfmListVars.AddVarDebug(VarName: string);
var P:PPSNodeData;
    n:PVirtualNode;
begin

 n:=tv.AddChild(nil);
 P:=tv.GetNodeData(n);
 if P=nil then exit;
 p^.VarName:=VarName;

end;

function TfmListVars.GetVarDebug(VarName: string): PPSVariant;
var i,ic,oid,classid:integer;
    tmp:THATemplate;
    Reg:TRegExpr;
    st:TStringList;
    VarName_,s:string;
begin
 result:=nil;

 VarName_:=VarName;

 Reg:=TRegExpr.Create;
 st:=TStringList.Create;
 try
  Reg.ModifierI:=false;
  Reg.Expression:=RegScript;
  if Reg.Exec(VarName_) then
	 begin
    s:=Reg.Match[0];
    st.Clear;
    ParsePath(NormalizePath(s),st);
    TfmExplorer(Owner).fmListObject.GetClassAndOID(st,oid,classid);
    if oid<0 then exit;
    VarName_:=format(FormatPScript,[ClassID,OID]);
   end;
 finally
  Reg.Free;
  st.Free;
 end;




 tmp:=TfmExplorer(Owner).CurrentOPCManTemplate;
 if tmp=nil then exit;

 // локальные переменные
 ic:=tmp.PSDebug.Exec.CurrentProcVars.Count;
 for i:=0 to ic-1 do
  if CompareText(VarName_,tmp.PSDebug.Exec.CurrentProcVars[i])=0 then
   begin
    result:=tmp.PSDebug.Exec.GetProcVar(i);
    break;
   end;
 if result<>nil then exit;

 // глобальные переменные
 ic:=tmp.PSDebug.Exec.GlobalVarNames.Count;
 for i:=0 to ic-1 do
  if CompareText(VarName_,tmp.PSDebug.Exec.GlobalVarNames[i])=0 then
   begin
    result:=tmp.PSDebug.Exec.GetGlobalVar(i);
    break;
   end;

 if result<>nil then exit;
// параметры процедур
 ic:=tmp.PSDebug.Exec.CurrentProcParams.Count;
 for i:=0 to ic-1 do
  if CompareText(VarName_,tmp.PSDebug.Exec.CurrentProcParams[i])=0 then
   begin
    result:=tmp.PSDebug.Exec.GetProcParam(i);
    break;
   end;

end;

procedure TfmListVars.tvGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);

var pNode:PPSNodeData;

begin

 pNode:=tv.GetNodeData(Node);
 if pNode=nil then exit;
 case Column of
  0:CellText:=pNode^.VarName;
  1:begin
        CellText:=VarValue(pNode^.VarName);
{        p:=GetVarDebug(pNode^.Name);
        if p<>nil then
         CellText:=GetVarValue(p)
        else
         CellText:='Не найдена';}
     end;
 end;

end;

procedure TfmListVars.tvDblClick(Sender: TObject);
var s:string;
begin
 if InputQuery('Добавление переменной','Имя переменной',s) then
  AddVarDebug(s);
end;

procedure TfmListVars.FormCreate(Sender: TObject);
begin
  inherited;
 tv.NodeDataSize:=sizeof(TPSNodeData);
end;

procedure TfmListVars.RefreshVars;
var n:PVirtualNode;
    p:PPSNodeData;
begin
 n:=TV.GetFirst;
 while n<>nil do
  begin
   p:=tv.GetNodeData(n);
   if p<>nil then
    tv.ReinitNode(n,false);
   n:=tv.GetNext(n);
  end;
 tv.Refresh;
end;

procedure TfmListVars.GetAllVars(Vars: TStrings);
var n:PVirtualNode;
    p:PPSNodeData;
begin
 if Vars=nil then exit;
 n:=TV.GetFirst;
 while n<>nil do
  begin
   p:=TV.GetNodeData(n);
   if p<>nil then
    Vars.Add(p^.VarName);
   n:=tv.GetNext(n);
  end;
end;

{function TfmListVars.VarObjToPObj(VarObj: string; out UserName:string):string;

var Reg:TRegExpr;
    s:string;
    st:TStringList;
    oid,ClassId:integer;

function NormalizePath(APath:string):string;
begin
 result:=APath;
 delete(result,1,2);
 delete(result,length(result)-1,2);
end;

begin
 Reg:=TRegExpr.Create;
 st:=TStringList.Create;
 try
  Reg.ModifierI:=false;
  Reg.Expression:=RegScript;
  if Reg.Exec(VarObj) then
	 begin
    s:=Reg.Match[0];
    st.Clear;
    ParsePath(NormalizePath(s),st);
    TfmExplorer(Owner).fmListObject.GetClassAndOID(st,oid,classid);
    if oid<0 then exit;
    result:=format(FormatPScript,[ClassID,OID]);
    UserName:=s;
   end
  else
   begin
    result:=VarObj;
    UserName:=VarObj;
   end;
 finally
  Reg.Free;
  st.Free;
 end;
end;
 }
procedure TfmListVars.ClearVars;
begin
 tv.Clear;
end;

procedure TfmListVars.N3Click(Sender: TObject);
begin
  inherited;
 tv.Clear;
end;

procedure TfmListVars.N1Click(Sender: TObject);
begin
  inherited;
 tv.DeleteNode(tv.FocusedNode);
end;

function TfmListVars.VarValue(VarName: string): string;
var p:PPSVariant;
begin
 result:='';
 p:=GetVarDebug(VarName);
 if p=nil then exit;
 result:=GetVarValue(p);
end;

function TfmListVars.GetVarValue(P: PPSVariant):string;
const
 NL=#13#10;


function GetValueForClassCommand(Obj:TIGCommand):string;
const
 Fmt='TIGCommand'+nl+'Name=''%s'''+nl+'Count=%d'+nl+'Data=[%s]'+nl+'Priority=%d';
var s:string;
    i:integer;
begin
 s:='';
 for i:=0 to Obj.Count-1 do
  if s='' then
   s:=inttostr(Obj.Data[i])
  else
   s:=s+' '+inttostr(Obj.Data[i]);

 result:=format(Fmt,[Obj.NameObj,Obj.Count,s,Obj.Priority]);
end;

function GetValueForClassTag(Obj:TIGTag):string;
const
 Fmt='TIGTag'+nl+'Name=''%s'''+nl+'DataType=%d'+nl+'OldValue=%s'+nl+'NewValue=%s'+nl+'OldQuality=%s'+nl+'NewQuality=%s';
var sold,snew:string;
    i,len:integer;
begin
  if (Obj.TypeTag and VarArray)<>VarArray then
   begin
    sold:=Obj.OldValue;
    snew:=Obj.NewValue;
   end
  else
   begin
    len:=VarArrayHighBound(Obj.OldValue,1);
    sold:='';
    for i:=0 to len do
     if sold='' then
      sold:=VarToStr(Obj.OldValue[i])
     else
      sold:=sold+' '+VarToStr(Obj.OldValue[i]);

    len:=VarArrayHighBound(Obj.NewValue,1);
    sNew:='';
    for i:=0 to len do
     if sNew='' then
      sNew:=VarToStr(Obj.OldValue[i])
     else
      sNew:=sNew+' '+VarToStr(Obj.OldValue[i]);

    sOld:='['+sOld+']';
    sNew:='['+sNew+']';
   end;
  result:=format(Fmt,[Obj.FullNameObj,Obj.TypeTag,sOld,sNew,QualityToStr(Obj.OldQuality,true),QualityToStr(Obj.NewQuality,true)]);
end;

function GetValueForClassController(Obj:TIGDevice):string;
const
 Fmt='TIGDevice'+nl+'Name=''%s'''+nl+'Address=''%s'''+nl+'TemplateName=''%s'''+nl+'Param=%d';
begin
  result:=format(Fmt,[Obj.NameObj,Obj.Address,Obj.Template.NameObj,Obj.Param]);
end;



function GetValueForBase(Obj:THABaseObj):string;
begin
  result:='';
  if Obj=nil then exit;
  case Obj.ClassID of
   ClassCommand    :result:=GetValueForClassCommand(TIGCommand(Obj));
   ClassTag        :result:=GetValueForClassTag(TIGTag(Obj));
   ClassController :result:=GetValueForClassController(TIGDevice(Obj));

  end;
end;


function GetValueForTIGConverter(Obj:TIGConverter):string;
const
 Fmt='TIGConverter'+nl+'Value=%s'+nl+'Bytes=[%s]';
var s:string;
    i:integer;
begin
  s:='';
  for i:=0 to 7 do
   if s='' then
    s:=inttostr(Obj.Bytes[i])
   else
    s:=s+' '+inttostr(Obj.Bytes[i]);

  result:=format(Fmt,['',s]);
end;

function GetValueForTIGTags(Obj:TIGTags):string;
const
 Fmt='TIGTags'+nl+'Count=%d'+nl+'Filter=''%s'''+nl+'Filtered=%s';
var s:string;

begin
  if Obj.Filtered then
   s:='True'
  else
   s:='False';
 result:=format(Fmt,[Obj.Count,Obj.Filter,s]);
end;

function GetValueForTIGDriverData(Obj:TIGDriverData):string;
const
 Fmt='TIGDriverData'+nl+'result=%d'+nl+'count=%d'+nl+'Data=[%s]';
var s:string;
    i:integer;
begin
 s:='';
 for i:=0 to Obj.Count-1 do
  if s='' then
   s:=inttostr(Obj.Data[i])
  else
   s:=s+' '+inttostr(Obj.Data[i]);

 result:=format(Fmt,[Obj.Result,Obj.Count,s]);
end;


function GetValueForObject(Obj:TObject):string;
begin
 if Obj is TIGConverter then
  result:=GetValueForTIGConverter(TIGConverter(Obj))
 else
  if Obj is TIGTags then
   result:=GetValueForTIGTags(TIGTags(Obj))
  else
   if Obj is TIGDriverData then
    result:=GetValueForTIGDriverData(TIGDriverData(Obj));
end;

var pIFC:TPSVariantIFC;
begin
    result:='';
    try
     case p.FType.BaseType of
          btU8        :result:=inttostr(PPSVariantU8(p)^.Data);
          btS8        :result:=inttostr(PPSVariantS8(p)^.Data);
          btU16       :result:=inttostr(PPSVariantU16(p)^.Data);
          btS16       :result:=inttostr(PPSVariantS16(p)^.Data);
          btU32       :result:=inttostr(PPSVariantU32(p)^.Data);
          btS32       :result:=inttostr(PPSVariantS32(p)^.Data);
          btSingle    :result:=floattostr(PPSVariantSingle(p)^.Data);
          btDouble    :result:=floattostr(PPSVariantDouble(p)^.Data);
          btExtended  :result:=floattostr(PPSVariantExtended(p)^.Data);
          btString    :result:=PPSVariantAString(p)^.Data;
          btVariant   :result:=PPSVariantVariant(p)^.Data;
          btPointer   :begin
                        pIFC:=NewTPSVariantIFC(p, False);
                        if pIFC.aType.BaseType=btClass then
                         begin
                          if TObject(pIFC.Dta^) is THABaseObj then
                           result:=GetValueForBase(THABaseObj(pIFC.Dta^))
                          else
                           result:=GetValueForObject(TObject(pIFC.Dta^));
                         end
                        else
                         case pIFC.aType.BaseType of
                          btU8,
                          btS8,
                          btU16,
                          btS16,
                          btU32,
                          btS32       :result:=inttostr(VNGetInt(pIFC));

                          btSingle,
                          btDouble,
                          btExtended  :result:=floattostr(VNGetReal(pIFC));
                          btString    :result:=VNGetString(pIFC);



                         end;
                       end;
          btClass     :begin
                        if PPSVariantClass(p)^.Data is THABaseObj then
                         result:=GetValueForBase(THABaseObj(PPSVariantClass(p)^.Data))
                        else
                         result:=GetValueForObject(PPSVariantClass(p)^.Data);
                       end;



     end;
    except
     on e:exception do
      result:=e.Message;
    end;

end;



procedure TfmListVars.tvMeasureItem(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; var NodeHeight: Integer);
var p:PPSNodeData;
begin
  inherited;
  p:=TV.GetNodeData(Node);
  if p=nil then exit;
  TargetCanvas.Font:=TV.Font;
  NodeHeight:=TV.ComputeNodeHeight(TargetCanvas,Node,1,VarValue(p^.VarName));
  if NodeHeight=0 then
   NodeHeight:=tv.DefaultNodeHeight
  else
   NodeHeight:=NodeHeight+(tv.DefaultNodeHeight div 2);
end;

procedure TfmListVars.tvInitNode(Sender: TBaseVirtualTree; ParentNode,
  Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
begin
  inherited;
 Include(InitialStates, ivsMultiline);
end;

procedure TfmListVars.tvPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
begin
  inherited;
 TargetCanvas.Font.Color:=clWindowText;
end;

procedure TfmListVars.N4Click(Sender: TObject);
begin
 tvDblClick(nil);

end;

procedure TfmListVars.N5Click(Sender: TObject);
var p:PPSNodeData;
    s:string;
begin
  inherited;
 if TV.SelectedCount<>1 then exit;

 p:=tv.GetNodeData(tv.FocusedNode);
 if p=nil then exit;
 s:=p^.VarName;
 if InputQuery('Изменение переменной','Имя переменной',s) then
  begin
   p^.VarName:=s;
   tv.ReinitNode(tv.FocusedNode,false);
   tv.Refresh;
  end;
end;

end.
