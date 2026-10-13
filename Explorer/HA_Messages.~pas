unit HA_Messages;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ha_dockfm, StdCtrls, ExtCtrls,ha_types, VirtualTrees, ImgList;

type
  TfmMessages = class(TfmDock)
    Panel1: TPanel;
    TV: TVirtualStringTree;
    IMTv: TImageList;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TVDblClick(Sender: TObject);
    procedure TVGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure TVGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean;
      var ImageIndex: Integer);
  private
    function GetCountErrors: integer;
    function GetCountAll: integer;
    { Private declarations }

  public
    { Public declarations }
    procedure AddMessage(AMessage:string; AMsg:TMessage);
    procedure ClearMessages;
    property CountErrors:integer read GetCountErrors;
    property CountAll:integer read GetCountAll;
  end;



implementation
 uses ha_explorer;
{$R *.dfm}


 type
  PMessageItem=^TMessageItem;
  TMessageItem=record
   Caption:widestring;
   Msg:TMessage;
  end;


{ TfmMessages }

procedure TfmMessages.AddMessage(AMessage: string; AMsg: TMessage);
var p:PMessageItem;
    n:PVirtualNode;
begin
 n:=tv.AddChild(nil);
 p:=tv.GetNodeData(n);
 if p=nil then exit;
 p^.Caption:=AMessage;
 p^.Msg:=AMsg;
 tv.Refresh;
end;

procedure TfmMessages.ClearMessages;
begin
 TV.Clear;
end;

procedure TfmMessages.FormDestroy(Sender: TObject);
begin
 //ClearMessages;
  inherited;

end;

function TfmMessages.GetCountErrors:integer;
var p:PMessageItem;
    n:PVirtualNode;
begin
 result:=0;
 n:=tv.GetFirst;
 while n<>nil do
  begin
   p:=tv.GetNodeData(n);
   if p=nil then continue;
   if p^.Msg.Result=HATypeMsgError then
    inc(result);
   n:=tv.GetNext(n);
  end;
end;

procedure TfmMessages.FormCreate(Sender: TObject);
begin
  inherited;
 TV.NodeDataSize:=sizeof(TMessageItem);
end;

procedure TfmMessages.TVDblClick(Sender: TObject);
var p:PMessageItem;
begin
 p:=tv.GetNodeData(tv.FocusedNode);
 if p=nil then exit;
 TfmExplorer(Owner).MsgToObject(p.Msg);
end;

procedure TfmMessages.TVGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var p:PMessageItem;
begin
 p:=tv.GetNodeData(Node);
 if p=nil then exit;
 case Column of
  0:case p^.Msg.Result of
     HATypeMsgError    : CellText:='[Ошибка]';
     HATypeMsgWarning  : CellText:='[Предупреждение]';
     HATypeMsgExecError: CellText:='[Ошибка выполнения]';
    end;
  1:CellText:=p^.Caption;
 end;

end;

procedure TfmMessages.TVGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var p:PMessageItem;
begin
 if Column>0 then exit;
 p:=tv.GetNodeData(Node);
 if p=nil then exit;
 if Kind in [ikNormal,ikSelected] then
   case p^.Msg.Result of
     HATypeMsgError    : ImageIndex:=0;
     HATypeMsgWarning  : ImageIndex:=1;
     HATypeMsgExecError: ImageIndex:=2;
   end;



end;

function TfmMessages.GetCountAll: integer;
begin
 result:=tv.TotalCount;
end;

end.
