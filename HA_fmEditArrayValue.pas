unit HA_fmEditArrayValue;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls,ha_utils;

type
  TfmEditArrayValue = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    BtnCancel: TButton;
    BtnOK: TButton;
    Panel3: TPanel;
    RE: TRichEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


function EditArrayValue(const NameObj:string; TypeData:word; var wsValue:widestring):boolean;

implementation

{$R *.dfm}

function EditArrayValue(const NameObj:string; TypeData:word; var wsValue:widestring):boolean;
var i:integer;
    v:olevariant;
begin
 result:=false;
 with TfmEditArrayValue.Create(application) do
  begin
   Caption:='Значение для '+NameObj;
   RE.Lines.Clear;
   v:=HAHexStringValueToVariant(wsValue);
   if (v<>null) and VarIsArray(v) then
    for i:=0 to VarArrayHighBound(v,1) do
     RE.Lines.Add(VarToStr(v[i]));

   result:=ShowModal=mrOK;
   if not result then exit;
   v:=VarArrayCreate([0,RE.Lines.Count-1],TypeData);
   try
    for i:=0 to RE.Lines.Count-1 do
     v[i]:=VarAsType(RE.Lines[i],TypeData);
    wsValue:=HAVariantToHexStringValue(v);

   except
    VarClear(v);
    result:=false;
   end;

  end;
end;

procedure TfmEditArrayValue.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 Action:=caFree;
end;

end.
