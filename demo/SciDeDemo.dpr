program SciDeDemo;

uses
  Forms,
  SciMainForm in 'SciMainForm.pas' {MainForm},
  Sciter in '..\source\Sciter.pas',
  SciterApi in '..\source\SciterApi.pas',
  TiScriptApi in '..\source\TiScriptApi.pas',
  SciterNative in '..\source\SciterNative.pas',
  SciterOle in '..\source\SciterOle.pas',
  NativeForm in 'NativeForm.pas',
  SciDeDemo_TLB in 'SciDeDemo_TLB.pas';

{$R *.TLB}

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'SciDe - Sciter for Delphi';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
