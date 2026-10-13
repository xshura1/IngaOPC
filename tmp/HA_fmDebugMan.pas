unit HA_fmDebugMan;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, HA_CustomFM2, TB2Dock, TB2Toolbar, TB2Item, ExtCtrls,inifiles,
  StdCtrls, ImgList, Spin, Buttons;

type
  TfmDebugMan = class(TfmCustom2)
    TBDock1: TTBDock;
    TBToolbar1: TTBToolbar;
    TBItem1: TTBItem;
    TBItem3: TTBItem;
    TBControlItem1: TTBControlItem;
    Panel1: TPanel;
    CB: TComboBox;
    ImageList1: TImageList;
    TBSeparatorItem1: TTBSeparatorItem;
    SEDelay: TSpinEdit;
    LabelDelay: TLabel;
    BtnRun: TSpeedButton;
    TBItem4: TTBItem;
    TBItem5: TTBItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TBItem3Click(Sender: TObject);
    procedure CBCloseUp(Sender: TObject);
    procedure SEDelayChange(Sender: TObject);
    procedure BtnRunClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    fListWindow:TList;


    function SearchViewForm(id:integer):TfmCustom2;


    procedure OnCloseChild(Sender:TObject; var Action:TCloseAction);

   // procedure LoadIni(fm:TForm);
   // procedure SaveIni(fm:TForm);
    procedure SaveIniParams; override;
    procedure LoadIniParams; override;
    procedure SetDebugMode;
    //procedure OnDestroyChild(Sender:TObject);
  public
    { Public declarations }
    procedure ShowViewForm(id: integer);
  end;



implementation
  uses HA_fmViewCache,
       HA_fmViewLog,
       HA_fmViewDriverData,
       HA_fmViewDynList,
       HA_fmViewClients,
       HA_OPCMan;
{$R *.dfm}

{ TfmDebugMan }

procedure TfmDebugMan.ShowViewForm(id: integer);
var fm:TForm;
    i:integer;
begin
 fm:=SearchViewForm(id);
// if (fm=nil) and (not Showing) then exit;

 if fm=nil then
  begin
   case id of
     2:fm:=TfmViewCache.Create(nil);
     3:fm:=TfmViewLog.Create(nil);
     5:fm:=TfmViewDriverData.Create(nil);
    // 8:fm:=TfmViewDynList.Create(nil);
     9:fm:=TfmViewClients.Create(nil);
   end;
   if fm=nil then exit;

   fListWindow.Add(fm);
   fm.Tag:=id;
   fm.OnClose:=OnCloseChild;
   fm.Show;

  end
 else
   fm.Show;


end;

procedure TfmDebugMan.FormCreate(Sender: TObject);
begin
  inherited;
 fListWindow:=TList.Create;
 cb.ItemIndex:=0;
 CBCloseUp(nil);
end;

procedure TfmDebugMan.FormDestroy(Sender: TObject);
var i:integer;
begin
  for i:=fListWindow.Count-1 downto 0 do
   TForm(fListWindow[i]).Close;
  fListWindow.Free;
  inherited;
end;

function TfmDebugMan.SearchViewForm(id: integer): TfmCustom2;
var i:integer;
begin
 result:=nil;
 for i:=0 to fListWindow.Count-1 do
  if TForm(fListWindow[i]).Tag=id then
   begin
     result:=fListWindow[i];
     break;
   end;
end;

procedure TfmDebugMan.TBItem3Click(Sender: TObject);
begin
  inherited;
  if Sender=nil then exit;
  ShowViewForm(TTBItem(Sender).Tag);
  TTBItem(Sender).Checked:=true;
end;




procedure TfmDebugMan.OnCloseChild(Sender: TObject; var Action: TCloseAction);
var i:integer;
begin
 Action:=caFree;
// saveIni(TForm(sender));
 for i:=0 to TBToolBar1.Items.Count-1 do
  if TBToolBar1.Items[i].Tag=TForm(Sender).Tag then
   begin
     TBToolBar1.Items[i].Checked:=false;
     //ShowViewForm(TBToolBar1.Items[i].Tag,false);
     fListWindow.Remove(Sender);
     break;
   end;

end;

{procedure TfmDebugMan.OnDestroyChild(Sender: TObject);
var i:integer;
begin

 for i:=0 to TBToolBar1.Items.Count-1 do
  if TBToolBar1.Items[i].Tag=TForm(Sender).Tag then
   begin
     TBToolBar1.Items[i].Checked:=false;
     //ShowViewForm(TBToolBar1.Items[i].Tag,false);
     fListWindow.Remove(Sender);
     break;
   end;
 inherited;
end;
 }

{procedure TfmDebugMan.LoadIni(fm:TForm);
var ini:TIniFile;
    sec:string;
begin
 ini:=TIniFile.Create(ChangeFileExt(ParamStr(0),'.ini'));
 try
   sec:=fm.ClassName;
   fm.Left:=ini.ReadInteger(sec,'Left',0);
   fm.Top:=ini.ReadInteger(sec,'Top',0);
   fm.Width:=ini.ReadInteger(sec,'Width',fm.width);
   fm.Height:=ini.ReadInteger(sec,'Height',fm.height);
 finally
  ini.Free;
 end;

end;

procedure TfmDebugMan.SaveIni(fm:TForm);
var ini:TIniFile;
    sec:string;
begin
 ini:=TIniFile.Create(ChangeFileExt(ParamStr(0),'.ini'));
 try
   sec:=fm.ClassName;
   ini.WriteInteger(sec,'Left',fm.Left);
   ini.WriteInteger(sec,'Top',fm.Top);
   ini.WriteInteger(sec,'Width',fm.Width);
   ini.WriteInteger(sec,'Height',fm.Height);
 finally
  ini.Free;
 end;

end;
 }
 
procedure TfmDebugMan.SaveIniParams;
var ini:TIniFile;
    sec:string;
begin
 ini:=TIniFile.Create(ChangeFileExt(ParamStr(0),'.ini'));
 try
   sec:=ClassName;
   ini.WriteInteger(sec,'Left',Left);
   ini.WriteInteger(sec,'Top',Top);
 finally
  ini.Free;
 end;

end;

procedure TfmDebugMan.LoadIniParams;
var ini:TIniFile;
    sec:string;
begin
 ini:=TIniFile.Create(ChangeFileExt(ParamStr(0),'.ini'));
 try
   sec:=ClassName;
   Left:=ini.ReadInteger(sec,'Left',0);
   Top:=ini.ReadInteger(sec,'Top',0);
 finally
  ini.Free;
  SetDebugMode;
 end;

end;

procedure TfmDebugMan.SetDebugMode;
begin
 case CB.ItemIndex of
  0:begin
     SEDelay.Visible:=false;
     LabelDelay.Visible:=false;
     BtnRun.Visible:=false;
     OPCMan.CacheDebugMode:=cdm_Normal;
    end;
  1:begin
     SEDelay.Visible:=true;
     LabelDelay.Visible:=true;
     BtnRun.Visible:=false;
     OPCMan.CacheDebugMode:=cdm_Delay;
     OPCMan.CacheDebugDelay:=SEDelay.Value;
    end;
  2:begin
     SEDelay.Visible:=false;
     LabelDelay.Visible:=false;
     BtnRun.Visible:=true;
     OPCMan.CacheDebugMode:=cdm_RunStop;

    end;

 end;
end;

procedure TfmDebugMan.CBCloseUp(Sender: TObject);
begin
  SetDebugMode;

end;

procedure TfmDebugMan.SEDelayChange(Sender: TObject);
begin
  inherited;
 if SEDelay.Text<>'' then 
 OPCMan.CacheDebugDelay:=SEDelay.Value;
end;

procedure TfmDebugMan.BtnRunClick(Sender: TObject);
begin
  OPCMan.SetCacheDebugRun;

end;

procedure TfmDebugMan.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
 if OPCMan<>nil then
  OPCMan.CacheDebugMode:=cdm_Normal;
end;

end.
