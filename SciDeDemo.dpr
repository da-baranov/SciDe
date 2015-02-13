program SciDeDemo;

uses
  Forms,
  SciMainForm in 'SciMainForm.pas' {MainForm},
  Sciter in 'Sciter.pas',
  SciterApi in 'SciterApi.pas',
  TiScriptApi in 'TiScriptApi.pas',
  SciterNative in 'SciterNative.pas',
  SciterOle in 'SciterOle.pas',
  NativeForm in 'NativeForm.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'SciDe - Sciter for Delphi';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
