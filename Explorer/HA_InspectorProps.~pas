unit HA_InspectorProps;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, VirtualTrees,ha_listobject,ha_types, Buttons,
  Grids, GsvObjectInspectorGrid,GsvObjectInspectorTypes,Ha_Explorer;

type
  TfmInspectorProps = class(TForm)
    Panel4: TPanel;
    OIProps: TGsvObjectInspectorGrid;
    procedure TVPropsAllGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure FormCreate(Sender: TObject);
    procedure OIPropsEnumProperties(Sender: TObject; Index: Integer;
      out Info: PGsvObjectInspectorPropertyInfo);
  private
    { Private declarations }

    fListNodeTags:TList;
    fListProps:TList;
    fInfo:TGsvObjectInspectorPropertyInfo;
    fLock:boolean;
  public
    { Public declarations }

    destructor Destroy; override;
    procedure FillAllProps;
    procedure Lock;
    procedure UnLock;
  end;



implementation

{$R *.dfm}

type
 TDataProp=class(TObject)
  private
   fDataItem:PDataItem2;
  public
   constructor Create(DataItem:PDataItem2); 
 end;

{ TfmInspectorProps }

procedure TfmInspectorProps.FormCreate(Sender: TObject);
begin
 fListNodeTags:=TList.Create;
 fListProps:=TList.Create;
 fLock:=false;
 FillAllProps;
 OIProps.NewObject;
end;


destructor TfmInspectorProps.Destroy;
begin
  fListNodeTags.Free;
  fListProps.Free;
  inherited;
end;

procedure TfmInspectorProps.FillAllProps;
var fListObject:TfmListObject;
    i:integer;
begin

 fListObject:=TfmExplorer(Owner).fmListObject;
 if fListObject=nil then exit;

 fListObject.FillListProps(fListProps,false);
// for i:=0 to fListProps.Count-1 do
end;


procedure TfmInspectorProps.TVPropsAllGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var p:PDataItem2;
begin
  if fLock then exit;
  try
    P:=Sender.GetNodeData(node);
    if p=nil then exit;

    CellText:=P^.Name;
  except
   Lock;
   UnLock;
  end;
end;

procedure TfmInspectorProps.Lock;
begin
 fLock:=true;
end;

procedure TfmInspectorProps.UnLock;
begin
 FillAllProps;
 fLock:=false;
end;



procedure TfmInspectorProps.OIPropsEnumProperties(Sender: TObject;
  Index: Integer; out Info: PGsvObjectInspectorPropertyInfo);
begin
 if (index<0) or (index>=fListProps.Count) then
  begin
   Info:=nil;
   exit;
  end;

 fInfo.Caption:=TDataItem2(fListProps[index]^).Name;
 fInfo.Level:=0;
 fInfo.Kind:=pkText;
 fInfo.Checking:=true;

 fInfo.TheObject:=TDataProp.Create(fListProps[index]);
 Info:=@fInfo;
end;

{ TDataTVProp }

constructor TDataProp.Create(DataItem: PDataItem2);
begin
 inherited Create;
 fDataItem:=DataItem;
end;

end.
