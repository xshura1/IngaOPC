program ConvertForNewVer;

uses
  Forms,
  ConvMain in 'ConvMain.pas' {Form1},
  MSXML_TLB in 'MSXML_TLB.pas',
  HA_TYPES in 'HA_TYPES.pas',
  HA_XMLData in 'HA_XMLData.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
