unit HA_CustomFM2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs;

type
  TfmCustom2 = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FormVar:^TfmCustom2;
 //   procedure CreateParams(VAR Params: TCreateParams); override;
  protected
    procedure SaveIniParams; virtual;
    procedure LoadIniParams; virtual;

  public
    { Public declarations }
    constructor Create(var AFormVar:TfmCustom2);
    destructor destroy; override;
  end;



implementation
   uses inifiles;
{$R *.dfm}

{ TfmCustom2 }

constructor TfmCustom2.Create(var AFormVar: TfmCustom2);
begin
 inherited Create(Application);
 FormVar:=@AFormVar;
 BorderIcons:=BorderIcons-[biMinimize];
 LoadIniParams;
end;

{procedure TfmCustom2.CreateParams(var Params: TCreateParams);
var ini:TIniFile;
    sec:string;
begin
 Inherited CreateParams(Params);


 // Params.WndParent := GetDesktopWindow;
 ini:=TIniFile.Create(ChangeFileExt(ParamStr(0),'.ini'));
 try
   if Tag=0 then
    sec:=ClassName
   else
    sec:=ClassName+inttostr(Tag);
   Params.X:=ini.ReadInteger(sec,'Left',0);
   Params.Y:=ini.ReadInteger(sec,'Top',0);
   Params.Width:=ini.ReadInteger(sec,'Width',width);
   Params.Height:=ini.ReadInteger(sec,'Height',height);
 finally
  ini.Free;
 end;
end; }

destructor TfmCustom2.destroy;
begin
  FormVar^ := nil;
//  SaveIniParams;
  inherited;
end;

procedure TfmCustom2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 action:=caFree;
 SaveIniParams;
end;



procedure TfmCustom2.LoadIniParams;
var ini:TIniFile;
    sec:string;

begin
 ini:=TIniFile.Create(ChangeFileExt(ParamStr(0),'.ini'));
 try
   if Tag=0 then
    sec:=ClassName
   else
    sec:=ClassName+inttostr(Tag);

   Left:=ini.ReadInteger(sec,'Left',0);
   Top:=ini.ReadInteger(sec,'Top',0);
   Width:=ini.ReadInteger(sec,'Width',width);
   Height:=ini.ReadInteger(sec,'Height',height);
   WindowState:=TWindowState(ini.ReadInteger(sec,'WindowState',0));
 finally
  ini.Free;
 end;
end;

procedure TfmCustom2.SaveIniParams;
var ini:TIniFile;
    sec:string;
begin
 ini:=TIniFile.Create(ChangeFileExt(ParamStr(0),'.ini'));
 try
   if Tag=0 then
    sec:=ClassName
   else
    sec:=ClassName+inttostr(Tag);
   if WindowState=wsNormal then
    begin
     ini.WriteInteger(sec,'Left',Left);
     ini.WriteInteger(sec,'Top',Top);
     ini.WriteInteger(sec,'Width',Width);
     ini.WriteInteger(sec,'Height',Height);
    end; 
   ini.WriteInteger(sec,'WindowState',integer(windowstate));
 finally
  ini.Free;
 end;
end;

end.
