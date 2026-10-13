unit HA_XMLData;

interface
 uses MSXML_TLB, Windows, Messages, SysUtils, Variants, Classes,HA_Types,VirtualTrees,ha_dllmanager;

 {$I IngaOPC.inc}
 const
  CountDTags=24;
  TemplatesDir ='Templates';
  ConfigsDir   ='Configs';
  ExtTemplate  ='.igt';   //igt
  DescriptionTemplate  ='IngaOPC Template File';
  ExtConfig    ='.igc';   //igc
  DescriptionConfig    ='IngaOPC Config File';
  ExtStoredTags='.igs';   //igs
  DescriptionStoredTags='IngaOPC Stored Tags File';
  ExtDebugInfo ='.igd';   //igd
  DescriptionDebugInfo ='IngaOPC Debug Info File';

 type
  TExplorerMode=(em_Templates,em_Controllers);
  PHADataNode=^THADataNode;
  THADataNode=packed record
   //Parent:PHADataNode;
   Childs:array of PHADataNode;
   OID:integer;
   ClassID:integer;
   Name:widestring;
   Props:widestring;
  end;

  THAData=class(TObject)
   private
    fGenID    : integer;

    fBaseDir  : string;

    fDriverInfo:THADriverInfo2;


   public
    constructor Create(BaseDir:string);
    destructor Destroy; override;
    property BaseDir:string read fBaseDir;



    function GenID:integer;
    procedure ResetGenID;

    procedure GetAllTemplates(st:TStrings);
    procedure GetAllConfigs(st:TStrings);

    procedure DeleteTemplate(TemplateName:string);
    procedure DeleteConfig(ConfigName:string);

    property DriverInfo:THADriverInfo2 read fDriverInfo;

    function LoadOPC(ExplorerMode:TExplorerMode; FileName:string; NodeRoot:PHADataNode; var Script:string):boolean;

    function Load(ExplorerMode:TExplorerMode; FileName:string; TV:TBaseVirtualTree; var Script:string):boolean;
    function Save(ExplorerMode:TExplorerMode; FileName:string; TV:TBaseVirtualTree; const Script:string; const Checked:boolean):boolean;

    function GetDescription(FileName:string):string;
  end;

 procedure DisposeDataNode(Node:PHADataNode);

 var XData:THAData;
implementation
 uses ActiveX;


{ THAData }

procedure DisposeDataNode(Node:PHADataNode);
var i:integer;
begin
 for i:=0 to High(Node.childs) do
  DisposeDataNode(Node.Childs[i]);
 SetLength(Node.Childs,0);
 Node.Childs:=nil; 
 dispose(Node);
end;


function StrToClassID(Str:string):integer;
var s:string;
begin
 result:=-1;
 s:=str;
 if Pos('T',s)<>1 then exit;
 delete(s,1,1);
 result:=strtoint(s);
end;

function ClassIDToStr(ClassID:integer):string;
begin
 result:='T'+inttostr(ClassID);
end;

constructor THAData.Create(BaseDir:string);
begin
 inherited Create;
 fBaseDir:=BaseDir;
 fDriverInfo:=THADriverInfo2.Create(BaseDir+'dll');


end;

procedure THAData.DeleteConfig(ConfigName: string);
var s:string;
begin
 s:=BaseDir+ConfigsDir+'\'+ConfigName+ExtConfig;
 if FileExists(s) then
  DeleteFile(s);
 s:=BaseDir+ConfigsDir+'\'+ConfigName+ExtStoredTags;
 if FileExists(s) then
  DeleteFile(s);

end;

procedure THAData.DeleteTemplate(TemplateName: string);
var s:string;
begin
 s:=BaseDir+TemplatesDir+'\'+TemplateName+ExtTemplate;
 if FileExists(s) then
  DeleteFile(s);
 s:=BaseDir+TemplatesDir+'\'+TemplateName+ExtDebugInfo;
 if FileExists(s) then
  DeleteFile(s);
end;

destructor THAData.Destroy;
begin
// fDoc:=nil;
 fDriverInfo.Free;
 inherited;
end;

function THAData.GenID: integer;
begin
 inc(fGenID);
 result:=fGenID;
end;

{procedure THAData.LoadFromTree(TV: TBaseVirtualTree);
var i:integer;
    p:PDataItem2;
    n:PVirtualNode;
begin
 for i:=0 to fRoot.childNodes.length-1 do
   begin

    LoadFromTree_(fRoot.childNodes.item[i],nil,tv);
   end;
end;   }


procedure THAData.GetAllConfigs(st: TStrings);
var sr: TSearchRec;
begin
 st.Clear;
 if FindFirst(fBaseDir+ConfigsDir+'\*'+ExtConfig,faAnyFile,sr)=0 then
  begin
    st.Add(ChangeFileExt(sr.Name,''));
    while FindNext(sr)=0 do
     st.Add(ChangeFileExt(sr.Name,''));
  end;
  FindClose(sr);
end;

procedure THAData.GetAllTemplates(st: TStrings);
var sr: TSearchRec;
begin
 st.Clear;
if FindFirst(fBaseDir+TemplatesDir+'\*'+ExtTemplate,faAnyFile,sr)=0 then
  begin
    st.Add(ChangeFileExt(sr.Name,''));
    while FindNext(sr)=0 do
     st.Add(ChangeFileExt(sr.Name,''));

  end;
  FindClose(sr);
end;



{function THAData.LoadTemplate(NewTemplate: boolean; TemplateName: string;
  TV: TBaseVirtualTree; var Script: string): boolean;
begin
 result:=Load(TemplateName,TV, Script);
end;
 }
function THAData.GetDescription(FileName: string): string;
begin

end;

function THAData.Load(ExplorerMode:TExplorerMode; FileName: string; TV:TBaseVirtualTree; var Script:string): boolean;
type
 TLinkTmp=record
  Data:PDataItem2;
  OID :integer;
 end;
 TLinkTmpArray=array of TLinkTmp;

var narr:TLinkTmpArray;

procedure LoadFromTree_(n: IXMLDOMNode; node: PVirtualNode);
var i:integer;
    p:PDataItem2;
    ntv:PVirtualNode;
    nxml:IXMLDOMNode;
    s:string;
begin
 if StrToClassID(n.nodeName)=ClassFolderEvents then exit;

 ntv:=tv.AddChild(node);

 p:=tv.GetNodeData(ntv);
 p^.LinkNode:=nil;
 s:=n.nodeName;

 if p=nil then exit;
 p.ClassID:=StrToClassID(N.nodeName);

 {if p^.ClassID=ClassLinkProp then
  begin
   tv.IsVisible[ntv]:=false;
 //  if Node<>nil then
 //   tv.HasChildren[node]:=false;
  end;
  }

 p^.Name:='';
 p^.Props:='';
 p^.Description:='';

 for i:=0 to n.attributes.length-1 do
  begin
   nxml:=n.attributes.item[i];
   if CompareText('Name',nxml.nodeName)=0 then
    p.Name:=nxml.nodeValue
   else
    if CompareText('OID',nxml.nodeName)=0 then
     begin
      p.OID:=nxml.nodeValue;
      if fGenID<p.OID then
       fGenID:=p.OID;
     end
    else
     if CompareText('OIDLink',nxml.nodeName)=0 then
      begin
        SetLength(narr,Length(narr)+1);
        narr[High(narr)].Data:=p;
        narr[High(narr)].OID:=nxml.nodeValue;
      end
     else
      if CompareText('Description',nxml.nodeName)=0 then
       begin
        p^.Description:=nxml.nodeValue;
       end
      else
       begin
        s:='';
        s:=nxml.nodeName+'='+nxml.nodeValue;
        p.Props:=p.Props+s+#13#10;
       end;
  end;

 for i:=0 to n.childNodes.length-1 do
  LoadFromTree_(n.childNodes.item[i],ntv);

end;

var i:integer;
    Doc:DomDocument;
    root:IXMLDOMElement;
    FileDescription:string;
    pl:PDataItem2;
    nl:PVirtualNode;
begin
result:=true;
try
 fGenID:=0;
 tv.BeginUpdate;
 try
 tv.Clear;
 script:='';
 Doc:=CoDOMDocument.Create;
 Doc.Set_async(false);
 case ExplorerMode of
  Em_Templates:begin
                Doc.Load(fBaseDir+TemplatesDir+'\'+FileName+ExtTemplate);
                Root:=Doc.documentElement;
                FileDescription:=Root.getAttribute('FileDescription');
                if CompareText(FileDescription,DescriptionTemplate)<>0 then
                 begin
                  result:=false;
                  exit;
                 end;
                Script:=Root.getAttribute('Script');
               end;
  Em_Controllers:begin
                  Doc.Load(fBaseDir+ConfigsDir+'\'+FileName+ExtConfig);
                  Root:=Doc.documentElement;
                  FileDescription:=Root.getAttribute('FileDescription');
                  if CompareText(FileDescription,DescriptionConfig)<>0 then
                   begin
                     result:=false;
                     exit;
                   end;   
                 end;
 end;



 

 for i:=0 to Root.childNodes.length-1 do
  LoadFromTree_(Root.childNodes.item[i],nil);

 for i:=0 to High(narr) do
  begin
   nl:=tv.GetFirst;
   while nl<>nil do
    begin
     pl:=tv.GetNodeData(nl);
     //if pl=nil then exit;
     if pl^.OID=narr[i].OID then
      begin
       narr[i].Data^.Name:=pl^.Name;
       narr[i].Data^.LinkNode:=pl;
       break;
      end;
     nl:=tv.GetNext(nl);
    end;
  end;

 finally
 // tv.SortTree(0,sdAscending);
  if ExplorerMode=Em_Templates then
   if tv.GetFirst<>nil then
    tv.Expanded[tv.GetFirst]:=true;
  tv.EndUpdate;
  SetLength(narr,0);
  Doc:=nil;
 end;
except
 result:=false;
end;
end;

function THAData.LoadOPC(ExplorerMode:TExplorerMode; FileName: string; NodeRoot: PHADataNode;
  var Script: string): boolean;


procedure LoadOPC_(n: IXMLDOMNode; node: PHADataNode);
var i:integer;
    ntv:PHADataNode;
    nxml:IXMLDOMNode;
    s:string;
begin
 
 new(ntv);
 SetLength(node.Childs,length(node.Childs)+1);
 node.Childs[High(node.Childs)]:=ntv;

 s:=n.nodeName;
 ntv^.ClassID:=StrToClassID(N.nodeName);
 ntv^.Name:='';
 ntv^.Props:='';

 for i:=0 to n.attributes.length-1 do
  begin
   nxml:=n.attributes.item[i];
   if CompareText('Name',nxml.nodeName)=0 then
    ntv^.Name:=nxml.nodeValue
   else
    if CompareText('OID',nxml.nodeName)=0 then
     ntv^.OID:=nxml.nodeValue
    else
      begin
       s:='';
       s:=nxml.nodeName+'='+nxml.nodeValue;
       ntv^.Props:=ntv^.Props+s+#13#10;
      end;
  end;

 for i:=0 to n.childNodes.length-1 do
  LoadOPC_(n.childNodes.item[i],ntv);

end;

var i:integer;
    Doc:DomDocument;
    root:IXMLDOMElement;
    FileDescription:string;
    Checked:boolean;
begin
result:=true;
try
 fGenID:=0;

 try
 script:='';


 Doc:=CoDOMDocument.Create;


 Doc.Set_async(false);
 case ExplorerMode of
  Em_Templates:begin
                 Doc.Load(fBaseDir+TemplatesDir+'\'+FileName+ExtTemplate);
                 Root:=Doc.documentElement;
                 FileDescription:=Root.getAttribute('FileDescription');
                 if CompareText(FileDescription,DescriptionTemplate)<>0 then
                  begin
                   result:=false;
                   exit;
                  end;
                 Script:=Root.getAttribute('Script');
               end;
  Em_Controllers:begin
                   Doc.Load(fBaseDir+ConfigsDir+'\'+FileName+ExtConfig);
                   Root:=Doc.documentElement;
                   FileDescription:=Root.getAttribute('FileDescription');
                   if CompareText(FileDescription,DescriptionConfig)<>0 then
                    begin
                     result:=false;
                     exit;
                    end;
                 end;
 end;

 Checked:=Root.getAttribute('Checked');
 if not Checked then
  begin
   result:=false;
   exit;
  end;

 for i:=0 to Root.childNodes.length-1 do
  LoadOPC_(Root.childNodes.item[i],NodeRoot);


  except
    result:=false;
  end;
finally
  Doc:=nil;
 end;
end;

{function THAData.NewObj(ClassID: integer; Name: string): TDataItem2;
var st:TStringList;
begin
 result.OID:=GenID;
 result.ClassID:=ClassID;
 result.Name:=Name;
 result.Props:='';
 st:=TStringList.Create;
 try
 case ClassID of
  ClassTag:
           begin
            st.Add('TypeTag=VT_UI1');
            st.Add('Readable=true');
            st.Add('Writeable=true');
           // st.Add('OnLocalRead=');
            st.Add('OnRead=');
            st.Add('OnWrite=');
           end;
  ClassProp:begin
              st.Add('PropID=5000');
              st.Add('TypeProp=VT_UI1');
            end;
  ClassLinkProp:begin
                 st.Add('Value=');

                end;
  ClassController:begin
                   st.Add('TemplateName=');
                   st.Add('DriverName=');
                   st.Add('Address=');
                  end;
  ClassCommand   :begin
                   st.Add('NoCommand=');
                   st.Add('CountWriteBytes=0');
                   st.Add('CountReadBytes=0');
                   st.Add('OnBeforeWrite=');
                   st.Add('OnAfterRead=');
                  end;


 end;
 result.Props:=st.Text;
 finally
  st.Free;
 end;
end;
 }



{function THAData.SaveTemplate(TemplateName: string; TV: TBaseVirtualTree;
  const Script: string): boolean;
begin

end;
 }
procedure THAData.ResetGenID;
begin
 fGenID:=0;
end;

function THAData.Save(ExplorerMode:TExplorerMode; FileName:string; TV:TBaseVirtualTree; const Script:string; const Checked:boolean): boolean;

var Doc:DomDocument;
procedure SaveFromTree_(n: IXMLDOMElement; node: PVirtualNode);
var ntv:PVirtualNode;
    nxml:IXMLDOMElement;
    p,plink:PDataItem2;
    i,cc:integer;
    st:TStringList;
    v:OleVariant;
begin
 p:=tv.GetNodeData(node);
 if p=nil then exit;
 nxml:=Doc.createElement(ClassIDToStr(p^.ClassID));

 nxml.setAttribute('OID',p^.OID);
 nxml.setAttribute('Description',p^.Description);
 if p^.LinkNode<>nil then
  begin
   plink:=p^.LinkNode;
   nxml.setAttribute('OIDLink',plink^.OID);
  end
 else
  nxml.setAttribute('Name',p^.Name);

 v:=nxml.nodeTypedValue;
 st:=TStringList.Create;
 try
  st.Text:=p^.Props;
  for i:=0 to st.Count-1 do
   nxml.setAttribute(st.Names[i],st.ValueFromIndex[i]);
 finally
  st.Free;
 end;

 n.appendChild(nxml);


 ntv:=node.FirstChild;
 cc:=Node.ChildCount;
 for i:=0 to cc-1 do
  begin
    SaveFromTree_(nxml,ntv);
    ntv:=tv.GetNextSibling(ntv);
  end;
end;


var ntv:PVirtualNode;
    p:PDataItem2;
    Root:IXMLDOMElement;
    i,cc:integer;
    Proxy:THATemplate_Proxy;
    
begin
 Doc:=CoDOMDocument.Create;
 Doc.Set_async(false);
 Doc.LoadXML('<Header/>');
 Root:=Doc.documentElement;

 case ExplorerMode of
  Em_Templates:   begin
                   Root.setAttribute('FileDescription',DescriptionTemplate);
                   Root.setAttribute('Version','0101');
                   Root.setAttribute('Checked',Checked);
                  end;
  Em_Controllers: begin
                   Root.setAttribute('FileDescription',DescriptionConfig);
                   Root.setAttribute('Version','0101');
                   Root.setAttribute('Checked',Checked);
                  end;
 end;


// Root.setAttribute('GenID',inttostr(fGenId));
 if ExplorerMode=Em_Templates then
  Root.setAttribute('Script',Script);


 ntv:=tv.RootNode.FirstChild;
 cc:=tv.rootNode.ChildCount;

 case ExplorerMode of
  Em_Templates:begin
                p:=TV.GetNodeData(ntv);
                if p<>nil then
                 begin
                  Proxy:=THATemplate_Proxy.Create;
                  try
                   Proxy.AddData(p);
                   Proxy.DateLastUpdate:=DateTimeToStr(now);
                   Proxy.CompileID:=Proxy.CompileID+1;
                  finally
                   Proxy.Free;
                  end;

                 end;

               end;
  Em_Controllers:;
 end;



 for i:=0 to cc-1 do
  begin
    SaveFromTree_(Root,ntv);
    ntv:=tv.GetNextSibling(ntv);
  end;

 case ExplorerMode of
  Em_Templates:Doc.save(fBaseDir+TemplatesDir+'\'+FileName+ExtTemplate);

  Em_Controllers:Doc.save(fBaseDir+ConfigsDir+'\'+FileName+ExtConfig);
 end;

 result:=true;
end;



end.
