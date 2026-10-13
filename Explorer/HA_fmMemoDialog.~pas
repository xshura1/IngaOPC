unit HA_fmMemoDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfmMemoDialog = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Memo1: TMemo;
    Panel3: TPanel;
    BtnCancel: TButton;
    BtnOK: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    function GetText: string;
    procedure SetText(const Value: string);
    { Private declarations }
  public
    { Public declarations }
    constructor Create(PropName:string);
    property Text:string read GetText write SetText;
  end;



implementation

{$R *.dfm}

{ TfmMemoDialog }

function TfmMemoDialog.GetText: string;
begin
 result:=Memo1.Lines.Text;
end;

procedure TfmMemoDialog.SetText(const Value: string);
begin
 Memo1.Lines.Text:=Value;
end;

procedure TfmMemoDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 Action:=caFree;
end;

constructor TfmMemoDialog.Create(PropName: string);
begin
 inherited Create(Application);
 Caption:=PropName;
end;

end.
