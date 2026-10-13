unit HA_fmViewDriverData;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, ExtCtrls, ImgList, StdCtrls, ComCtrls, ToolWin,
  SynEdit, SynMemo,ha_types, Menus,HA_wmConst, HA_CustomFM2,IniFiles,
  PageControlEx,intf,ha_utils, Buttons;

type
  PDataTVDriver=^TDataTVDriver;
  TDataTVDriver=record
   IDLog      : dword;
   IsWrite    : boolean;
   LogTime    : TDateTime;
   Handle     : dword;
   Address    : widestring;
   Data       : widestring;
   DataSize   : dword;
   Result     : dword;
   NoCommand  : widestring;
   Param      : dword;
   AddrDrv    : dword;
   SelfAddrDrv: dword;
  end;

 TPanelFilter=class(TPanel)
  private
   fCheckBox:TCheckBox;
   fEdit:TEdit;
   fColumn:integer;
   fOnChecked:TNotifyEvent;
   function GetChecked: boolean;
   function GetFilter: string;
   procedure WMSize(var Message: TWMSize); message WM_SIZE;
   procedure OnCheck(sender:TObject);
  public
   constructor Create(AOwner:TComponent; Column:integer);
   destructor Destroy; override;
   property Checked:boolean read GetChecked;
   property Filter:string read GetFilter;
   property Column:integer read fColumn;
   property OnChecked:TNotifyEvent read fOnChecked write fOnChecked;
  end;


  TfmViewDriverData = class(TForm)
    PC: TPageControlEx;
    SD: TSaveDialog;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    Label1: TLabel;
    Panel1: TPanel;
    CBData: TComboBox;
    Label2: TLabel;
    BtnFreeze: TSpeedButton;
    PanelFilter: TPanel;
    BtnStop: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure TVDriverLogGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure TVDriverLogColumnResize(Sender: TVTHeader;
      Column: TColumnIndex);
    procedure TVDriverLogInitNode(Sender: TBaseVirtualTree;
      ParentNode, Node: PVirtualNode;
      var InitialStates: TVirtualNodeInitStates);
  private
  //  fST:TStringList;
    fIDLog:dword;
    procedure TVDriverLogCompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode;
                                      Column: TColumnIndex; var Result: Integer);

    procedure TVDriverLogHeaderClick(Sender: TVTHeader; Column: TColumnIndex; Button: TMouseButton;
                                      Shift: TShiftState; X, Y: Integer);

    procedure OnChangeDriverData(var Msg:TMessage); message wm_DebugDriver;

    procedure FilterInit(Sender:TObject);

    procedure OnChangeDriverDataW(var Msg:TMessage); message wm_DebugDriverW;
    procedure OnChangeDriverDataR(var Msg:TMessage); message wm_DebugDriverR;
    procedure AddNode(pDD:PDriverData; HashID:dword; Writing:boolean);
    function HashIDToDriverName(HashID:dword):string;


    function ConvertSData(SData:string):string;
    function GetCellText(p:PDataTVDriver; Column:TColumnIndex):string;
    function GetCurrentTV:TVirtualStringTree;
    function GetPanelFilter(Index:integer):TPanelFilter;
    procedure RefreshPanelFilter;

    procedure LoadIniParams;
    procedure SaveIniParams;
    procedure AddDrivers;
    procedure AddPage(PageName:string; HashID:cardinal);
    procedure SaveLogs;
    { Private declarations }
  public
    { Public declarations }

  end;



implementation
  uses ha_opcman,{uPSRuntime,}HA_DllManager;
{$R *.dfm}







{ TfmDebugger }




procedure TfmViewDriverData.FormCreate(Sender: TObject);
var i:integer;
begin
{ for i:=0 to 8 do
  with TPanelFilter.Create(PanelFilter,i) do
   begin
    Parent:=PanelFilter;
    Height:=PanelFilter.Height;
    OnChecked:=FilterInit;
    Width:=50;
    Top:=0;
   end;
 }
 fIDLog:=0;
 LoadIniParams;
 CBData.ItemIndex:=0;
 OPCMan.DLLMan.HWNDDebug:=Handle;
 AddDrivers;
end;

procedure TfmViewDriverData.OnChangeDriverData(var Msg: TMessage);
var R:integer;
    f:boolean;
    s:string;
    i,j:integer;
    RE:TSynEdit;
begin
{try
 for i:=0 to PC.PageCount-1 do
  if PC.Pages[i].Tag=Msg.LParam then
   begin
     for j:=0 to pc.Pages[i].ComponentCount-1 do
      if pc.Pages[i].Components[j] is TSynEdit then
       begin
        RE:=TSynEdit(pc.Pages[i].Components[j]);
        break;
       end;
     s:=string(Msg.WParam);
     R:=RE.CaretY;
     f:=Re.Lines.Count=R;
     RE.Lines.Add(s);
     if f then
      RE.caretY:=R+1;//fST.Count;
  end;
 except
 end;
 }
end;

procedure TfmViewDriverData.FormDestroy(Sender: TObject);
begin
 SaveLogs;
 OPCMan.DLLMan.HWNDDebug:=0;
 SaveIniParams;
 inherited;
end;

procedure TfmViewDriverData.LoadIniParams;
var ini:TIniFile;
    sec:string;

begin
 Inherited;
 ini:=TIniFile.Create(ChangeFileExt(ParamStr(0),'.ini'));
 try
   sec:=ClassName;
   Left:=ini.ReadInteger(sec,'Left',0);
   Top:=ini.ReadInteger(sec,'Top',0);
   Width:=ini.ReadInteger(sec,'Width',width);
   Height:=ini.ReadInteger(sec,'Height',height);

 finally
  ini.Free;
 end;
end;

procedure TfmViewDriverData.SaveIniParams;
var ini:TIniFile;
    sec:string;

begin
 ini:=TIniFile.Create(ChangeFileExt(ParamStr(0),'.ini'));
 try
   sec:=ClassName;
   ini.WriteInteger(sec,'Left',Left);
   ini.WriteInteger(sec,'Top',Top);
   ini.WriteInteger(sec,'Width',Width);
   ini.WriteInteger(sec,'Height',Height);
 finally
  ini.Free;
 end;

end;

procedure TfmViewDriverData.AddDrivers;
var st:TStringList;
    i:integer;
begin
 st:=TStringList.create;
 try
 OPCMan.DLLMan.GetDrivers(st,true);

 for i:=0 to st.Count-1 do
   AddPage(st[i],dword(st.Objects[i]));
 finally
  st.Free;
  Label1.Visible:=PC.PageCount=0;
  PC.Visible:=not Label1.Visible;
 end;
end;

procedure TfmViewDriverData.AddPage(PageName: string; HashID: cardinal);
var ts:TTabSheet;
  //  ED:TSynEdit;
    TV:TVirtualStringTree;
    TVCol:TVirtualTreeColumn;
    Panel:TPanel;
begin

  ts:=TTabSheet.Create(PC);
  ts.PageControl:=pc;
  ts.Caption:=PageName;
  ts.Tag:=HashID;

  Panel:=TPanel.Create(ts);
  with Panel do
   begin
    Parent:=ts;
    BevelOuter:=bvLowered;
    Align:=alClient;
    Caption:='';
   end;

{  ED:=TSynEdit.Create(ts);
  ED.Parent:=ts;
  ED.Align:=alClient;
  ED.Gutter.Visible:=false;
  ED.BorderStyle:=bsNone;
  ED.RightEdge:=0;
  ED.ReadOnly:=true;
  ED.PopupMenu:=PopupMenu1;
 }
  with TVirtualStringTree.Create(ts) do
   begin
      Indent:=0;
      NodeDataSize:=sizeof(TDataTVDriver);
      OnGetText:=TVDriverLogGetText;
      OnHeaderClick:=TVDriverLogHeaderClick;
      OnCompareNodes:=TVDriverLogCompareNodes;
     // OnColumnResize:=TVDriverLogColumnResize;
     // OnInitNode:=TVDriverLogInitNode;
      Parent:=Panel;
      Align:=alClient;
      BorderStyle := bsNone;
      Colors.FocusedSelectionColor := clBtnFace;
      Colors.FocusedSelectionBorderColor := clBtnFace;
      Header.AutoSizeIndex := 0;
      Header.Options := [hoColumnResize, hoDrag, hoVisible, hoShowSortGlyphs];
      Header.Style := hsFlatButtons;
      TreeOptions.MiscOptions := [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning];
      TreeOptions.PaintOptions := [toShowDropmark, toShowHorzGridLines, toShowRoot, toShowVertGridLines, toThemeAware, toUseBlendedImages];
      TreeOptions.SelectionOptions := [toFullRowSelect];
      PopupMenu:=PopupMenu1;

      TVCol:=Header.Columns.Add;
      TVCol.Text:='';
      TVCol.Width:=150;

      TVCol:=Header.Columns.Add;
      TVCol.Text:='Time';
      TVCol.Width:=110;

      TVCol:=Header.Columns.Add;
      TVCol.Text:='Handle';
      TVCol.Width:=60;

      TVCol:=Header.Columns.Add;
      TVCol.Text:='Address';
      TVCol.Width:=200;

      TVCol:=Header.Columns.Add;
      TVCol.Text:='NoCommand';
      TVCol.Width:=80;


      TVCol:=Header.Columns.Add;
      TVCol.Text:='Data';
      TVCol.Width:=300;

      TVCol:=Header.Columns.Add;
      TVCol.Text:='DataSize';
      TVCol.Width:=60;

      TVCol:=Header.Columns.Add;
      TVCol.Text:='Result';
      TVCol.Width:=60;

      TVCol:=Header.Columns.Add;
      TVCol.Text:='Param';
      TVCol.Width:=60;



      
   end;

  RefreshPanelFilter;

end;

procedure TfmViewDriverData.N1Click(Sender: TObject);
var TV:TVirtualStringTree;
    i:integer;
begin
 TV:=GetCurrentTV;
 if TV=nil then exit;
 case TMenuItem(Sender).Tag of
  1: TV.Clear;
 // 2: if SD.Execute then
 //      ED.Lines.SaveToFile(SD.FileName);
 end;
end;

procedure TfmViewDriverData.SaveLogs;
var i,j:integer;
    dirlog:string;
begin
{ dirlog:=OPCMan.DLLMan.DirDll;
 for i:=0 to pc.PageCount-1 do
  begin
  for j:=0 to pc.Pages[i].ComponentCount-1 do
   if pc.Pages[i].Components[j] is TSynEdit then
    begin
     if TSynEdit(pc.Pages[i].Components[j]).Lines.Count>0 then
      TSynEdit(pc.Pages[i].Components[j]).Lines.SaveToFile(dirlog+'\'+ChangeFileExt(pc.Pages[i].Caption,'.log'));
     break;
    end;
  end;   }
end;

function TfmViewDriverData.GetCellText(p:PDataTVDriver; Column:TColumnIndex):string;
begin
 case column of
  0:if p^.IsWrite then
      result:=HashIDToDriverName(p^.AddrDrv)+'->'+HashIDToDriverName(p^.SelfAddrDrv)
    else
      result:=HashIDToDriverName(p^.SelfAddrDrv)+'->'+HashIDToDriverName(p^.AddrDrv);

  1:result:=formatDateTime('dd.mm hh:nn:ss:zzz',p^.LogTime);
  2:result:=inttostr(p^.Handle);
  3:result:=p^.Address;
  4:result:=p^.NoCommand;
  5:result:=ConvertSData(p^.Data);
  6:result:=inttostr(p^.DataSize);
  7:result:=inttostr(p^.Result);
  8:result:=inttostr(p^.Param);

 end;
end;

procedure TfmViewDriverData.TVDriverLogGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var p:PDataTVDriver;
    TV:TVirtualStringTree;

begin
 TV:=TVirtualStringTree(Sender);
 if TV=nil then exit;
 p:=TV.GetNodeData(Node);
 if p=nil then exit;
 CellText:=GetCellText(p,column);
end;

procedure TfmViewDriverData.OnChangeDriverDataR(var Msg: TMessage);
var pDD:PDriverData;
begin
 pDD:=pointer(Msg.WParam);
 if pDD=nil then exit;
 AddNode(pDD,Msg.LParam,false);
end;

procedure TfmViewDriverData.OnChangeDriverDataW(var Msg: TMessage);
var pDD:PDriverData;
begin
 pDD:=pointer(Msg.WParam);
 if pDD=nil then exit;
 AddNode(pDD,Msg.LParam,true);
end;


procedure TfmViewDriverData.AddNode(pDD: PDriverData; HashID:dword; Writing: boolean);

function pDataToStr(pData: PByteArray; dwSize: dword): string;
var i:integer;
begin
 result:='';
 if pData=nil then exit;
 for i:=0 to dwSize-1 do
  result:=result+inttohex(pData[i],2);
end;


var n:PVirtualNode;
    p:PDataTVDriver;
    i,j:integer;
    TV:TVirtualStringTree;
begin
 if BtnStop.Down then exit;
 TV:=nil;
 for i:=0 to PC.PageCount-1 do
  if dword(PC.Pages[i].Tag)=HashID then
   begin
     for j:=0 to pc.Pages[i].ComponentCount-1 do
      if pc.Pages[i].Components[j] is TVirtualStringTree then
       begin
        TV:=TVirtualStringTree(pc.Pages[i].Components[j]);
        break;
       end;
   end;
 if TV=nil then exit;
 n:=TV.AddChild(nil);
 p:=TV.GetNodeData(n);
 if p=nil then exit;
 inc(fIDLog);
 p^.IDLog:=fIDLog;
 p^.IsWrite:=Writing;
 p^.LogTime:=now;
 p^.Handle:=pDD.Handle;
 p^.Address:=string(pDD^.szAddress);
 p^.Data:=pDataToStr(pDD^.pData,pDD^.dwDataSize);
 p^.DataSize:=pDD^.dwDataSize;
 p^.Result:=pDD^.Result;
 p^.Param:=pDD^.Param;
 p^.NoCommand:=string(pDD^.szNoCommand);
 p^.AddrDrv:=pDD^.AddrDrv;
 p^.SelfAddrDrv:=HashID;
// TV.SortTree(TV.Header.SortColumn,TV.Header.SortDirection);
// TV.Sort(n,TV.Header.SortColumn,TV.Header.SortDirection);
 TV.ReinitNode(n,false);
 TV.Refresh;
 if not BtnFreeze.Down then
  TV.FocusedNode:=n;
end;

function TfmViewDriverData.ConvertSData(SData: string): string;
var i,j,ii:integer;
    s:string;
begin
 i:=1;
 result:='';
 try
   while i<Length(SData) do
    begin
     s:=SData[i]+SData[i+1];
     j:=strtoint('$'+s);
     s:='';
     case CBData.ItemIndex of
      0: s:=inttohex(j,2);
      1: begin
          s:=inttostr(j);
          if length(s)<3 then
           for ii:=1 to 3-Length(s) do
            s:=' '+s;
         end;
      2: for ii:=0 to 7 do
          s:=inttostr(BitStat(j,ii))+s;
     end;
     if result='' then
      result:=s
     else
      result:=result+' '+s;
     inc(i,2);
    end;
 except
  result:=SData;
 end;
end;



procedure TfmViewDriverData.TVDriverLogColumnResize(
  Sender: TVTHeader; Column: TColumnIndex);
begin
 RefreshPanelFilter;
end;

procedure TfmViewDriverData.RefreshPanelFilter;
var TV:TVirtualStringTree;
    i,j,newleft:integer;
    Panel:TPanelFilter;
begin
 TV:=GetCurrentTV;
 if TV=nil then exit;
 newleft:=0;
 for i:=0 to TV.Header.Columns.Count-1 do
  begin
   for j:=0 to PanelFilter.ComponentCount-1 do
    if (PanelFilter.Components[j] is TPanelFilter) then
     if TPanelFilter(PanelFilter.Components[j]).Column=i then
      begin
       Panel:=TPanelFilter(PanelFilter.Components[j]);
       Panel.Left:=newleft;
       Panel.Width:=TV.Header.Columns[i].Width;
       TV.Header.Columns[i].Tag:=integer(Panel);
       newleft:=newleft+TV.Header.Columns[i].Width;
      end;
  end;
end;

function TfmViewDriverData.GetCurrentTV: TVirtualStringTree;
var j:integer;
begin
 result:=nil;
 if PC.ActivePage=nil then exit;
 for j:=0 to PC.ActivePage.ComponentCount-1 do
  if PC.ActivePage.Components[j] is TVirtualStringTree then
   begin
     result:=TVirtualStringTree(PC.ActivePage.Components[j]);
     break;
   end;
end;

{ TPanelFilter }

constructor TPanelFilter.Create(AOwner:TComponent; Column:integer);
begin
 inherited Create(AOwner);
 fCheckBox:=TCheckBox.Create(self);
 fCheckBox.Parent:=self;
 fCheckBox.Left:=5;
 fCheckBox.Top:=4;
 fCheckBox.Width:=13;
 fCheckBox.Caption:='';
 fCheckBox.OnClick:=OnCheck;

 fEdit:=TEdit.Create(self);
 fEdit.Parent:=self;
 fEdit.Left:=22;
 fEdit.Top:=3;
 fEdit.BevelInner:=bvNone;
 fEdit.BevelKind:=bkFlat;
 fEdit.BorderStyle:=bsNone;

 fColumn:=Column;
end;

destructor TPanelFilter.Destroy;
begin

  inherited;
end;

function TPanelFilter.GetChecked: boolean;
begin
 result:=fCheckBox.Checked;
end;

function TPanelFilter.GetFilter: string;
begin
 result:=fEdit.Text;
end;

procedure TPanelFilter.OnCheck(sender: TObject);
begin
 if Assigned(fOnChecked) then
  fOnChecked(Self);
end;

procedure TPanelFilter.WMSize(var Message: TWMSize);
begin
 if fEdit<>nil then
  fEdit.Width:=Width-fEdit.Left-5;
end;

procedure TfmViewDriverData.TVDriverLogInitNode(
  Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
  var InitialStates: TVirtualNodeInitStates);
var TV:TVirtualStringTree;
    p:PDataTVDriver;
    i:integer;
    PF:TPanelFilter;
begin
 TV:=TVirtualStringTree(Sender);
 p:=TV.GetNodeData(Node);
 if p=nil then exit;

 Node.States:=Node.States+[vsVisible];
 for i:=0 to TV.Header.Columns.Count-1 do
  begin
   PF:=GetPanelFilter(i);
   if PF=nil then continue;
    if PF.Checked then
     if CompareText(GetCellText(p,i),PF.Filter)<>0 then
      begin
       //InitialStates:=InitialStates+[ivsDisabled];
       Node.States:=Node.States-[vsVisible];
       break;
      end;
   {   Node.States:=Node.States+[vsVisible]
     else
      Node.States:=Node.States-[vsVisible];
    }
  end;
end;

procedure TfmViewDriverData.FilterInit(Sender: TObject);
var TV:TVirtualStringTree;
    n:PVirtualNode;
begin
 TV:=GetCurrentTV;
 if tv=nil then exit;
 n:=TV.GetFirst;
 while n<>nil do
  begin
   TV.ReinitNode(n,false);
   TV.RepaintNode(n);
   n:=TV.GetNext(n);
  end;
 TV.Refresh;
end;

function TfmViewDriverData.GetPanelFilter(Index: integer): TPanelFilter;
var i:integer;
begin
 result:=nil;
 for i:=0 to PanelFilter.ComponentCount-1 do
  if PanelFilter.Components[i] is TPanelFilter then
   if TPanelFilter(PanelFilter.Components[i]).Column=Index then
    begin
     result:=TPanelFilter(PanelFilter.Components[i]);
     break;
    end;

end;



procedure TfmViewDriverData.TVDriverLogCompareNodes(
  Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode;
  Column: TColumnIndex; var Result: Integer);
var p1,p2:PDataTVDriver;
begin
 p1:=Sender.GetNodeData(Node1);
 p2:=Sender.GetNodeData(Node2);
 if (p1=nil) or (p2=nil) then exit;
 result:=0;
 case Column of
 -1: if p1^.IDLog>p2^.IDLog then result:=1
     else
      if p1^.IDLog<p2^.IDLog then result:=-1;

  0: if p1^.IsWrite and (not p2^.IsWrite) then result:=1
     else
      if (not p1^.IsWrite) and p2^.IsWrite then result:=-1;

  1:if p1^.LogTime>p2^.LogTime then result:=1
    else
     if p1^.LogTime<p2^.LogTime then result:=-1;

  2:if p1^.Handle>p2^.Handle then result:=1
    else
     if p1^.Handle<p2^.Handle then result:=-1;

  3:result:=CompareText(p1^.Address,p2^.Address);
  4:result:=CompareText(p1^.NoCommand,p2^.NoCommand);
  5:result:=CompareText(ConvertSData(p1^.Data),ConvertSData(p2^.Data));
  6:if p1^.DataSize>p2^.DataSize then result:=1
    else
     if p1^.DataSize<p2^.DataSize then result:=-1;

  7:if p1^.Result>p2^.Result then result:=1
    else
     if p1^.Result<p2^.Result then result:=-1;

  8:if p1^.Param>p2^.Param then result:=1
    else
     if p1^.Param<p2^.Param then result:=-1;

 end;
end;

procedure TfmViewDriverData.TVDriverLogHeaderClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
 if Button = mbLeft then
  begin
   if Sender.SortColumn<>Column then
    begin
     Sender.SortColumn:=Column;
     Sender.SortDirection:=sdAscending;
    end
   else
    if Sender.SortDirection=sdAscending then
     Sender.SortDirection:=sdDescending
    else
     Sender.SortColumn:= -1;
   Sender.Treeview.SortTree(Sender.SortColumn, Sender.SortDirection, False);

  end;
end;

function TfmViewDriverData.HashIDToDriverName(HashID: dword): string;
var i:integer;
begin
 result:='';
 if HashID=0 then
  result:='OPC Server'
 else
  for i:=0 to PC.PageCount-1 do
   if dword(PC.Pages[i].Tag)=HashID then
     begin
      result:=PC.Pages[i].Caption;
      break;
     end;
end;

end.
