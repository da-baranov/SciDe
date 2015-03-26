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
  SciDeDemo_TLB in 'SciDeDemo_TLB.pas',
  DemoBehavior in 'DemoBehavior.pas',
  ShockwaveFlashObjects_TLB in 'ShockwaveFlashObjects_TLB.pas';

{$R *.TLB}

{$R *.res}

var
  sCSS: UTF8String;
begin
  sCSS := 'h1 { color: #999999; border-bottom: 2px dotted #333333; } ';
  API.SciterAppendMasterCSS(PChar(sCSS), Length(sCSS));
  Application.Initialize;
  Application.Title := 'SciDe - Sciter for Delphi';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
