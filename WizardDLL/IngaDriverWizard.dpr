program IngaDriverWizard;

uses
  Forms,
  MainWizard in 'MainWizard.pas' {fmWizard};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfmWizard, fmWizard);
  Application.Run;
end.
