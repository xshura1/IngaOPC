unit USetup;
 //ver101
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,inifiles,USharedClass, RXSpin, Spin,ucomport, ComCtrls;

type
  TfmSetup = class(TForm)
    Button1: TButton;
    GroupBox1: TGroupBox;
    ComboTimeoutRead: TRxSpinEdit;
    Button2: TButton;
    Label8: TLabel;
    Label6: TLabel;
    ComboIntervalTCP: TRxSpinEdit;
    NoPort: TRxSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    ComboIntervalFullSost: TRxSpinEdit;
    ComboTimeoutRead485: TRxSpinEdit;
    Label3: TLabel;
    DTTime: TDateTimePicker;
    Label4: TLabel;
    CBAutoLoadData: TCheckBox;
    ComboTimeLimitAlarm: TRxSpinEdit;
    Label5: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }

  public
    { Public declarations }
  end;
 procedure ShowSetup(AHandle:THandle); stdcall;
 function TextToItemIndex(Combo:TComboBox;Text:string):integer;
implementation

{$R *.DFM}


function TextToItemIndex(Combo:TComboBox;Text:string):integer;
var i:integer;
begin
 result:=-1;
 for i:=0 to Combo.Items.Count-1 do
  if Combo.Items[i]=Text then
  begin
   result:=i;
   break;
  end;
end;

procedure ShowSetup(AHandle:THandle);
var
  fmSetup: TfmSetup;
  ini:TIniFile;
begin
 Application.handle:=AHandle;
 fmSetup:=TfmSetup.Create(application);
 try
   ini:=TIniFile.Create(IniName);
   try
      fmSetup.NoPort.Value:=ini.ReadInteger('TCP','Port',33002);
      fmSetup.ComboTimeoutRead.Value:=ini.ReadInteger('TCP','TimeoutRead',10000);
      fmSetup.ComboTimeoutRead485.Value:=ini.ReadInteger('TCP','TimeoutRead485',2000);

      fmSetup.ComboIntervalTCP.Value:=ini.ReadInteger('TCP','IntervalTCP',540000);
      fmSetup.ComboIntervalFullSost.Value:=ini.ReadInteger('TCP','IntervalFullSost',600000);

      fmSetup.CBAutoLoadData.Checked:=ini.ReadBool('TCP','AutoLoadData',false);
      fmSetup.DTTime.DateTime:=StrToDateTime(ini.ReadString('TCP','TimeLoadData','1.01.2001 1:00'));

      fmSetup.ComboTimeLimitAlarm.AsInteger:=ini.ReadInteger('AlarmChannel','AlarmTimeLimitSec',600);

      if fmSetup.ShowModal=mrOk then
       begin
         ini.Writeinteger('TCP','Port',fmSetup.NoPort.AsInteger);
         ini.WriteInteger('TCP','TimeoutRead',fmSetup.ComboTimeoutRead.AsInteger);
         ini.WriteInteger('TCP','TimeoutRead485',fmSetup.ComboTimeoutRead485.AsInteger);
         ini.WriteInteger('TCP','IntervalTCP',fmSetup.ComboIntervalTCP.AsInteger);
         ini.WriteInteger('TCP','IntervalFullSost',fmSetup.ComboIntervalFullSost.AsInteger);

         ini.WriteBool('TCP','AutoLoadData',fmSetup.CBAutoLoadData.Checked);
         ini.WriteString('TCP','TimeLoadData',DateTimeToStr(fmSetup.DTTime.DateTime));

         ini.WriteInteger('AlarmChannel','AlarmTimeLimitSec',fmSetup.ComboTimeLimitAlarm.AsInteger);

       end;
   finally
    ini.free;
   end;

 finally
  fmSetup.free;
 end;
end;


procedure TfmSetup.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 Action:=caFree;
end;

end.
