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

uses Controls;

function _MethodHandler(vm: HVM; self: tiscript_value; tag: Pointer): tiscript_value; cdecl;
var
  pForm: TForm;
  pInfo: ISciterMethodInfo;
begin
  pForm := NI.get_instance_data(self);
  pInfo := ISciterMethodInfo(tag);
  
  if pInfo.Name = 'this' then
  begin
    // pForm := TForm.Create(Application) is dangerous because of
    // finalizer call followed by Application destructor call.
    // The form will be freed twice.
    pForm := TForm.CreateParented(GetDesktopWindow);

    pForm.Caption := 'Sciter';
    pForm.ClientWidth := 400;
    pForm.ClientHeight := 200;
    pForm.Position := poScreenCenter;
    NI.set_instance_data(self, pForm);
  end

  else if pInfo.Name = 'Show' then
  begin
    if pForm <> nil then
    begin
      pForm.Show;
      pForm.BringToFront();
    end;
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

  pForm := TObject(NI.get_instance_data(this)) as TForm;
  if pForm <> nil then
  begin
    pForm.Free;
    NI.set_instance_data(this, nil);
  end;
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
