unit UDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,inifiles, ComCtrls, Spin;

type
  TfmDialog = class(TForm)
    BtnOK: TButton;
    BtnCancel: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    RichEdit1: TRichEdit;
    EDCountWrite: TSpinEdit;
    Label7: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    procedure SaveIni;
    procedure LoadIni;
  public
    { Public declarations }
  end;



implementation
 uses Main;
{$R *.dfm}

procedure TfmDialog.FormCreate(Sender: TObject);
begin
 LoadIni;
end;

procedure TfmDialog.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 Action:=caFree;
end;

procedure TfmDialog.LoadIni;
var ini:TIniFile;
  
begin
 ini:=TIniFile.Create(IniName);
 try
   EDCountWrite.Value:=ini.ReadInteger('Port','CountWrite',1);
 finally
  ini.free;
 end;

end;

procedure TfmDialog.SaveIni;
var ini:TIniFile;
begin
 ini:=TIniFile.Create(IniName);
 try
   ini.WriteInteger('Port','CountWrite',EDCountWrite.Value);
 finally
  ini.free;
 end;

end;

procedure TfmDialog.BtnOKClick(Sender: TObject);
begin
 SaveIni;
end;

end.
