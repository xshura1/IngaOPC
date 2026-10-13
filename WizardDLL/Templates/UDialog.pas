unit UDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,inifiles, ComCtrls, Spin;

type
  TFormDialog = class(TForm)
    BtnOK: TButton;
    BtnCancel: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }

  end;



implementation
 uses Main;
{$R *.dfm}


procedure TFormDialog.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 Action:=caFree;
end;


end.
