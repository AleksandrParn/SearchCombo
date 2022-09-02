program SearchTxtSample;

uses
  Vcl.Forms,
  umainfrm in 'umainfrm.pas' {MainForm},
  SearchText in 'SearchText.pas',
  SearchTextOD in 'SearchTextOD.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
