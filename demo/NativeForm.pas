unit NativeForm;

interface

uses
  Windows, Forms, SciterNative, SciterApi, TiScriptApi;

type
  TNativeForm = class(TSciterClassInfo)
  public
    constructor Create; override;
    destructor Destroy; override;
  end;
  

implementation

function _MethodHandler(vm: HVM; self: tiscript_value; tag: Pointer): tiscript_value; cdecl;
var
  pInfo: ISciterMethodInfo;
  pForm: TForm;
begin
  pForm := NI.get_instance_data(self);
  pInfo := ISciterMethodInfo(tag); 

  
  if pInfo.Name = 'this' then
  begin
    pForm := TForm.Create(Forms.Application);
    pForm.Caption := 'Sciter';
    pForm.ClientWidth := 400;
    pForm.ClientHeight := 200;
    pForm.Position := poScreenCenter;
    NI.set_instance_data(self, pForm);
  end

  else if pInfo.Name = 'Show' then
  begin
    if pForm <> nil then
      pForm.Show;
  end

  else if pInfo.Name = 'Close' then
  begin
    pForm.Close;
    pForm.Free;
    NI.set_instance_data(self, nil);
  end;

  Result := self;
end;

procedure _FinalizerHandler(vm: HVM; this: tiscript_value); cdecl;
var
  pForm: TForm;
begin
  pForm := NI.get_instance_data(this);
  if pForm <> nil then
    pForm.Free;
end;

{ TNativeForm }


constructor TNativeForm.Create;
var
  pInfo: ISciterMethodInfo;
begin
  inherited;
  TypeName := 'NativeForm';
  
  Self.MethodHandler := _MethodHandler;
  Self.FinalizerHandler := _FinalizerHandler;

  pInfo := TSciterMethodInfo.Create;
  pInfo.Name := 'this';
  Self.Methods.Add(pInfo);

  pInfo := TSciterMethodInfo.Create;
  pInfo.Name := 'Show';
  Self.Methods.Add(pInfo);

  pInfo := TSciterMethodInfo.Create;
  pInfo.Name := 'Close';
  Self.Methods.Add(pInfo);
end;

destructor TNativeForm.Destroy;
begin
  inherited;
end;

end.
