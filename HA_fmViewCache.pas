unit HA_fmViewCache;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, ExtCtrls,HA_CustomFM2, ImgList,ha_classes;

type



 { PtvTagItem=^TtvTagItem;
  TtvTagItem=record
   NameTag:         widestring;
   id:              integer;
   ftOldTimeStamp:  TFileTime;
   ftNewTimeStamp:  TFileTime;
   wOldQuality:     word;
   wNewQuality:     word;
   vOldDataValue:   OleVariant;
   vNewDataValue:   OleVariant;
  end;
  }

  PTVCacheData=^TTVCacheData;
  TTVCacheData=record
   B:THABaseObj;
   id:              integer;
   idProp:          dword;
  // TypeData         :word;
   ftOldTimeStamp:  TFileTime;
   ftNewTimeStamp:  TFileTime;
   wOldQuality:     word;
   wNewQuality:     word;
   vOldDataValue:   OleVariant;
   vNewDataValue:   OleVariant;
  end;


  TfmViewCache = class(TForm)
    Panel1: TPanel;
    Timer1: TTimer;
    IMTv: TImageList;
    TV1: TVirtualDrawTree;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TVExpanding(Sender: TBaseVirtualTree; Node: PVirtualNode;
      var Allowed: Boolean);
    procedure TVGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean;
      var ImageIndex: Integer);
    procedure TV1DrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    fLastUpdate:TFileTime;
    fCurrentNoConfig:dword;
    procedure LoadCache2(Node:PVirtualNode);
    procedure GetCacheData(pt:PTVCacheData);
    procedure SaveIniParams;
    procedure LoadIniParams;
  public
    { Public declarations }
  end;


implementation
  uses ha_opcman,ha_utils,OPCDA, DateUtils,ha_types,inifiles;
{$R *.dfm}

{$I IngaOPC.inc} 



{ TfmViewCache }

procedure TfmViewCache.GetCacheData(pt: PTVCacheData);
var Tag:TIGTag;
    Prop:TIGProp;
begin
 if pt=nil then exit;
 if pt^.id<0 then exit;
// OPCMan.BeginRead;
// try
     Tag:=nil; Prop:=nil;

     pt^.ftOldTimeStamp:=OPCMan.OldFileTime[pt^.id];
     pt^.ftNewTimeStamp:=OPCMan.NewFileTime[pt^.id];


     //pt^.wOldQuality:=OPCMan.OldQuality[pt^.id];
     pt^.wNewQuality:=OPCMan.NewQuality[pt^.id];

     if (pt^.B.ClassID=ClassProp) and (pt^.idProp>0) then
      begin
       Tag:=OPCMan.Tag[pt^.id];
       Prop:=Tag.Prop[pt^.idProp];
       if Prop<>nil then
        begin
         pt^.vOldDataValue:=Prop.Value;
         pt^.wOldQuality:=OPC_Quality_good;
        end;
      end
     else
      begin
       pt^.vOldDataValue:=OPCMan.OldValue[pt^.id];
       pt^.wOldQuality:=OPCMan.OldQuality[pt^.id];
      end;

     pt^.vNewDataValue:=OPCMan.NewValue[pt^.id];
// finally
  //   OPCMan.EndRead;
// end;

{ s:='';
 if OPCMan.Controller[pt^.id]<>nil then
  s:=OPCMan.Controller[pt^.id].FullNameObj;

 if OPCMan.Tag[pt^.id]<>nil then
  if s<>'' then
   pt^.NameTag:=s+BranchSep+OPCMan.Tag[pt^.id].FullNameObj
  else
   pt^.NameTag:=OPCMan.Tag[pt^.id].FullNameObj;
 }


end;


procedure TfmViewCache.FormCreate(Sender: TObject);
begin

 fCurrentNoConfig:=OPCMan.CurrentNoConfig;
 tv1.NodeDataSize:=sizeof(TTVCacheData);
 LoadIniParams;
 LoadCache2(nil);

end;

procedure TfmViewCache.Timer1Timer(Sender: TObject);
var pt:PtvCacheData;
    n:PVirtualNode;
    i:integer;
begin

 if OPCMan.Reseting then exit;

 if fCurrentNoConfig<>OPCMan.CurrentNoConfig then
  begin
   tv1.Clear;
   LoadCache2(nil);
   fCurrentNoConfig:=OPCMan.CurrentNoConfig;
   exit;
  end;
 tv1.BeginUpdate;
 OPCMan.BeginRead;
 try
 try
   n:=tv1.TopNode;
   i:=(tv1.ClientHeight div tv1.DefaultNodeHeight)+1;
   while (n<>nil) and (i>0) do
    begin
     pt:=TV1.GetNodeData(n);
     if pt=nil then continue;
     if pt^.id>=0 then
      GetCacheData(pt);
     n:=TV1.GetNext(n);
     dec(i);
    end;
 except
 end;   
 finally
  OPCMan.EndRead;
  tv1.EndUpdate;
  fLastUpdate:=ConvertToFileTime(now);
  TV1.Refresh;
 end;

end;

procedure TfmViewCache.LoadCache2(Node: PVirtualNode);

function FirstIndexCache(ANode:PVirtualNode):integer;
var n:PVirtualNode;
    p:PTVCacheData;
begin
 result:=-1;
 n:=ANode;
 while n<>nil do
  begin
   p:=tv1.GetNodeData(n);
   if p=nil then exit;
   if p^.B=nil then exit;
   if p^.B.ClassID=ClassController then
    begin
     result:=TIGDevice(p^.B).FirstIndexCache;
     break;
    end;
   n:=n.Parent;
  end;
end;

var p,pParent:PTVCacheData;
    B:THABaseObj;
    i,fi:integer;
    n:PVirtualNode;
begin
 Timer1.Enabled:=false;

 OPCMan.BeginRead;
 try
 B:=nil;
 if Node=nil then
  B:=OPCMan.Root
 else
  begin
   p:=TV1.GetNodeData(Node);
   if p=nil then exit;
   B:=p^.B;
  end;
 if B=nil then exit;
// if Node<>nil then
//  TV.DeleteChildren(Node);
 if B.ClassID=ClassController then
  B:=TIGDevice(B).Template;

  for i:=0 to B.ChildCount-1 do
  begin
   pParent:=tv1.GetNodeData(Node);
   n:=tv1.AddChild(Node);
   p:=tv1.GetNodeData(n);
   if p=nil then continue;
   p^.B:=B.Childs[i];
   p^.id:=-1;
   p^.idProp:=0;

   if p^.B.ClassID in [ClassTag] then
    begin
     fi:=FirstIndexCache(n);
     if fi>=0 then
      begin
        p^.id:=fi+TIGTag(p^.B).IndexForCache;

       {$IFDEF DEMOVERSION}
       //if p^.B.ClassID=ClassTag then
       if TIGTag(p^.B).IndexForCache<0 then
        begin
          tv1.DeleteNode(n);
          continue;
        end;
       {$ENDIF}
      end;

     GetCacheData(p);
    end
   else
    if p^.B.ClassID=ClassProp then
     if pParent<>nil then
      begin
       p^.id:=pParent.id;
       p^.idProp:=TIGProp(p^.B).PropID;
       GetCacheData(p);
      end;

   if (p^.B.ChildCount>0) or (p^.B.ClassID=ClassController) then
    n.States:=n.States+[vsHasChildren];
  end;
 finally
  OPCMan.EndRead;
  Timer1.Enabled:=true;
 end;
end;

procedure TfmViewCache.TVExpanding(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var Allowed: Boolean);
begin

if Node.ChildCount=0 then
  LoadCache2(Node);
end;

procedure TfmViewCache.TVGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var p:PTVCacheData;
begin

 p:=Sender.GetNodeData(Node);
 if Kind in [ikNormal,ikSelected] then
  begin
    if p=nil then exit;
    if p^.B=nil then exit;
    if Column=0 then
      case p^.B.Classid of
        ClassFolder          :ImageIndex:=0;

        ClassTag             :ImageIndex:=1;
        ClassProp            :ImageIndex:=2;
        ClassCommand         :ImageIndex:=3;
        ClassLinkProp        :ImageIndex:=5;
        ClassController      :ImageIndex:=4;
       end
    else
     if (Column=2) and (p^.B.ClassID in [ClassTag,ClassProp]) then
      if (p^.wOldQuality<>OPC_Quality_Good) then
       ImageIndex:=6;

  end;
{ else
  if Kind in [ikState] then
   ImageIndex:=6;
 }
 if p^.B=nil then exit;
 if (p^.B.ChildCount>0) or (p^.B.ClassID=ClassController) then
  node.States:=node.States+[vsHasChildren];
end;

procedure TfmViewCache.TV1DrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var p:PTVCacheData;

procedure PaintHeader(const l,t:integer; AColor:TColor);
var s:string;
begin
 PaintInfo.Canvas.Font.Color:=AColor;
 case p^.B.ClassID of
  ClassTag  :begin
              s:='';
              if TIGTag(p^.B).IsReadable then  s:=s+'R';
              if TIGTag(p^.B).IsWriteable then s:=s+'W';

              PaintInfo.Canvas.TextOut(l,t,p^.B.NameObj+'   ('+AnsiLowerCase(VarTypeToStr(TIGTag(p^.B).TypeTag))+')  '+s);
             end;
  ClassProp :PaintInfo.Canvas.TextOut(l,t,p^.B.NameObj+'   ('+AnsiLowerCase(VarTypeToStr(TIGProp(p^.B).TypeProp))+')');
 else
   PaintInfo.Canvas.TextOut(l,t,p^.B.NameObj);
 end;
end;

procedure PaintOLD(const l,t:integer; AColor:TColor);
var s:string;
begin
 PaintInfo.Canvas.Font.Color:=AColor;
 PaintInfo.Canvas.Font.Style:=PaintInfo.Canvas.Font.Style+[fsBold];
 case PaintInfo.Column of
  1: begin
      if p^.vOldDataValue=null then
       s:=''
      else
      if VarIsArray(p^.vOldDataValue) then
       s:=ArrayVariantToString(p^.vOldDataValue)
      else
       s:=p^.vOldDataValue;
     end;
  2:s:=QualityToStr(p^.wOldQuality);
  3:s:=FormatDateTime('dd.mm.yyyy hh:nn:ss:zzz',ConvertToDateTime(p^.ftOldTimeStamp));


 end;
 if PaintInfo.Column=2 then
  PaintInfo.Canvas.TextOut(l+20,t,s)
 else
  PaintInfo.Canvas.TextOut(l,t,s);
 PaintInfo.Canvas.Font.Style:=PaintInfo.Canvas.Font.Style-[fsBold]; 
end;

procedure PaintNew(const l,t:integer; AColor:TColor);
var s:string;
begin

 PaintInfo.Canvas.Font.Color:=AColor;
 PaintInfo.Canvas.Font.Style:=PaintInfo.Canvas.Font.Style-[fsBold];
 case PaintInfo.Column of
  1: begin
      if p^.vNewDataValue=null then
       s:=''
      else
       if VarIsArray(p^.vNewDataValue) then
        s:=ArrayVariantToString(p^.vNewDataValue)
       else
        s:=p^.vNewDataValue;
     end;
  2:s:=QualityToStr(p^.wNewQuality);
  3:s:=FormatDateTime('dd.mm.yyyy hh:nn:ss:zzz',ConvertToDateTime(p^.ftNewTimeStamp));


 end;
 if PaintInfo.Column=2 then
  PaintInfo.Canvas.TextOut(l+20,t,s)
 else
  PaintInfo.Canvas.TextOut(l,t,s);
end;


var h,t,t1,l:integer;

    fl:boolean;
    dt,dlu:TDateTime;


begin
 p:=Sender.GetNodeData(PaintInfo.Node);
 if p=nil then exit;
 if p^.B=nil then exit;
// if p^.B.ClassID=ClassTag then
//  if TIGTag(p^.B).IndexForCache>5 then exit;
 //fl:=false;
 l:=tv1.Indent*(Sender.GetNodeLevel(PaintInfo.Node)+1)+PaintInfo.CellRect.Left+tv1.Indent+tv1.Images.Width;
 h:=PaintInfo.Canvas.TextHeight('AAA');

 t:=PaintInfo.CellRect.Top+1;
 t1:=t+h+1;

 dt:=converttoDateTime(p.ftOldTimeStamp);
 dlu:=converttoDateTime(fLastUpdate);
 fl:=(dlu<=IncMilliSecond(dt,Timer1.Interval)) and (IncMilliSecond(dlu,Timer1.Interval)>dt);

 if PaintInfo.Column=4 then
  begin
   PaintInfo.Canvas.Font.Color:=Sender.Font.Color;
   if p^.B.ClassID in [ClassTag] then
    PaintInfo.Canvas.TextOut(PaintInfo.CellRect.Left,t,inttostr(p^.id));
  end;

 if PaintInfo.Column=0 then
  if fl and (p^.B.ClassID in [ClassTag,ClassProp]) then
   PaintHeader(l,PaintInfo.CellRect.Top+((tv1.DefaultNodeHeight div 2)-h div 2),clBlue)
  else
   PaintHeader(l,PaintInfo.CellRect.Top+((tv1.DefaultNodeHeight div 2)-h div 2),Sender.Font.Color);

 if (p^.B.ClassID in [ClassTag]) then
  begin
    l:=PaintInfo.CellRect.Left;
    if fl then
     PaintOLD(l,t,clBlue)
    else
     PaintOLD(l,t,Sender.Font.Color);

    PaintNew(l,t1,clBtnShadow);
  end
 else
  if (p^.B.ClassID in [ClassProp]) then
   begin
    l:=PaintInfo.CellRect.Left;
    PaintOLD(l,PaintInfo.CellRect.Top+((tv1.DefaultNodeHeight div 2)-h div 2),Sender.Font.Color);


   end;


 {case PaintInfo.Column of
  0:begin
      PaintInfo.Canvas.TextOut(l,PaintInfo.CellRect.Top+((tv1.DefaultNodeHeight div 2)-h div 2),p^.B.NameObj);
    end;
  1:begin
     if VarIsArray(p^.vOldDataValue) then
       s:=ArrayVariantToString(p^.vOldDataValue)
      else
       s:=p^.vOldDataValue;
      PaintInfo.Canvas.Font.Color:=Sender.Font.Color;
      //PaintInfo.Canvas.Font.Style:=PaintInfo.Canvas.Font.Style-[fsItalic];
      PaintInfo.Canvas.TextOut(l,t,s);

     if VarIsArray(p^.vNewDataValue) then
       s:=ArrayVariantToString(p^.vNewDataValue)
      else
       s:=p^.vNewDataValue;
      PaintInfo.Canvas.Font.Color:=clBtnShadow;
     // PaintInfo.Canvas.Font.Style:=PaintInfo.Canvas.Font.Style+[fsItalic];
      PaintInfo.Canvas.TextOut(l,t1,s);
    end;
  2:begin
      s:=QualityToStr(p^.wOldQuality);
      PaintInfo.Canvas.Font.Color:=Sender.Font.Color;
//      PaintInfo.Canvas.Font.Style:=PaintInfo.Canvas.Font.Style-[fsItalic];
      PaintInfo.Canvas.TextOut(l+20,t,s);
      s:=QualityToStr(p^.wNewQuality);
      PaintInfo.Canvas.Font.Color:=clBtnShadow;
     // PaintInfo.Canvas.Font.Style:=PaintInfo.Canvas.Font.Style+[fsItalic];
      PaintInfo.Canvas.TextOut(l+20,t1,s);
    end;
  3:begin
      s:=FormatDateTime('dd.mm.yyyy hh:nn:ss:zzz',ConvertToDateTime(p^.ftOldTimeStamp));
      PaintInfo.Canvas.Font.Color:=Sender.Font.Color;
      //PaintInfo.Canvas.Font.Style:=PaintInfo.Canvas.Font.Style-[fsItalic];
      PaintInfo.Canvas.TextOut(l,t,s);
      s:=FormatDateTime('dd.mm.yyyy hh:nn:ss:zzz',ConvertToDateTime(p^.ftNewTimeStamp));
      PaintInfo.Canvas.Font.Color:=clBtnShadow;
     // PaintInfo.Canvas.Font.Style:=PaintInfo.Canvas.Font.Style+[fsItalic];
      PaintInfo.Canvas.TextOut(l,t1,s);
    end;

 end; }
end;

procedure TfmViewCache.SaveIniParams;
var ini:TIniFile;
    sec:string;
    i:integer;
begin
 Inherited;
 ini:=TIniFile.Create(ChangeFileExt(ParamStr(0),'.ini'));
 try
   sec:=ClassName;
   ini.WriteInteger(sec,'Left',Left);
   ini.WriteInteger(sec,'Top',Top);
   ini.WriteInteger(sec,'Width',Width);
   ini.WriteInteger(sec,'Height',Height);
   for i:=0 to TV1.Header.Columns.Count-1 do
    ini.WriteInteger(sec,'TVColumnWidth'+inttostr(i),TV1.Header.Columns[i].Width);
 finally
  ini.Free;
 end;

end;


procedure TfmViewCache.LoadIniParams;
var ini:TIniFile;
    sec:string;
    i:integer;
begin
 ini:=TIniFile.Create(ChangeFileExt(ParamStr(0),'.ini'));
 try
   sec:=ClassName;
   Left:=ini.ReadInteger(sec,'Left',0);
   Top:=ini.ReadInteger(sec,'Top',0);
   Width:=ini.ReadInteger(sec,'Width',width);
   Height:=ini.ReadInteger(sec,'Height',height);
   for i:=0 to TV1.Header.Columns.Count-1 do
    TV1.Header.Columns[i].Width:=ini.ReadInteger(sec,'TVColumnWidth'+inttostr(i),TV1.Header.Columns[i].Width);
 finally
  ini.Free;
 end;

end;

procedure TfmViewCache.FormDestroy(Sender: TObject);
begin
 SaveIniParams;
end;

end.
