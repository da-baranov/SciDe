unit SciterOleProxy;

interface

uses
  Windows, Messages, Classes, Variants, Contnrs, SciterApi, TiScriptApi, SysUtils, SciterNativeProxy,
  ComObj, ActiveX;

type
  ESciterOleException = class(Exception)

  end;
  
  TSciterOleWrapper = class(TSciterClassInfo)
  private
    FDispatch: IDispatch;
  protected
    procedure PopulateMethods(const List: TSciterMethodList); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Build(const Obj: IDispatch);
  end;

function GetOleObjectGuid(const Obj: IDispatch): AnsiString;
function GetOleObjectClass(vm: HVM; const Dispatch: IDispatch): tiscript_value;
function RegisterOleObject(vm: HVM; const Dispatch: IDispatch; const Name: WideString): tiscript_value;
function WrapOleObject(vm: HVM; const Dispatch: IDispatch): tiscript_value;

implementation

function GetOleObjectGuid(const Obj: IDispatch): AnsiString;
var
  typeInfo: ITypeInfo;
  typeAttr: PTypeAttr;
begin
  Result := '';
  try
    if Obj = nil then
      Exit;

    OleCheck(Obj.GetTypeInfo(0, LOCALE_USER_DEFAULT, typeInfo));

    OleCheck(typeInfo.GetTypeAttr(typeAttr));

    // Guid
    Result := GUIDToString(typeAttr.guid);
  finally
    if typeAttr <> nil then
      if typeInfo <> nil then
        typeInfo.ReleaseTypeAttr(typeAttr);
  end;
end;

function GetOleObjectClass(vm: HVM; const Dispatch: IDispatch): tiscript_value;
var
  zns: tiscript_value;
  guid: AnsiString;
  wguid: WideString;
  class_name: tiscript_value;
  class_def: tiscript_value;
  sciter_class_def: tiscript_class_def;
  pClassInfo: TSciterOleWrapper;
begin
  // get IID
  guid := GetOleObjectGuid(Dispatch);
  wguid := guid;

  zns         := NI.get_global_ns(vm);
  class_name  := NI.string_value(vm, PWideChar(wguid), Length(wguid));
  class_def   := NI.get_prop(vm, zns, class_name);

  if NI.is_class(vm, class_def) then
  begin
    Result := class_def;
    Exit;
  end
    else
  if NI.is_undefined(class_def) then
  begin
    pClassInfo := TSciterOleWrapper.Create;
    pClassInfo.Build(Dispatch);
    pClassInfo.GetClassDef(sciter_class_def);
    class_def := NI.define_class(vm, @sciter_class_def, zns);
    
    if not NI.is_class(vm, class_def) then
      raise ESciterOleException.Create('Failed to create OLE object wrapper.');
      
    Result := class_def;
    Exit;
  end
    else
  raise ESciterOleException.Create('Cannot define OLE object native class.');
end;

function WrapOleObject(vm: HVM; const Dispatch: IDispatch): tiscript_value;
var
  class_def: tiscript_value;
  retval: tiscript_value;
begin
  class_def := GetOleObjectClass(vm, Dispatch);
  retval := NI.create_object(vm, class_def);
  Dispatch._AddRef;
  NI.set_instance_data(retval, Pointer(Dispatch));
  Result := retval;
end;

function RegisterOleObject(vm: HVM; const Dispatch: IDispatch; const Name: WideString): tiscript_value;
var
  class_def: tiscript_value;
  zns: tiscript_value;
  var_name: tiscript_value;
  var_value: tiscript_value;
  class_instance: tiscript_value;
begin
  zns := NI.get_global_ns(vm);
  class_def := GetOleObjectClass(vm, Dispatch);
  var_name  := NI.string_value(vm, PWideChar(Name), Length(Name));
  var_value := NI.get_prop(vm, zns, var_name);
  if NI.is_undefined(var_value) then
  begin
    class_instance := NI.create_object(vm, class_def);
    if not NI.is_native_object(class_instance) then
      raise ESciterOleException.CreateFmt('Failed to register variable "%s" of type OLE object.', [Name]);
    Dispatch._AddRef;
    NI.set_instance_data(class_instance, Pointer(Dispatch));
    NI.set_prop(vm, zns, var_name, class_instance);
    Result := class_instance;
  end
    else
  begin
    raise ESciterOleException.CreateFmt('Failed to register variable "%s" of type OLE object: object with such name already exists.', [Name]);
  end;
end;

function DispatchInvoke(const Dispatch: IDispatch; const MethodName: WideString;
  const AParams: array of OleVariant): OleVariant; overload;
var
  Argc: integer;
  ArgErr: integer;
  ExcepInfo: TExcepInfo;
  Flags: Word;
  i: integer;
  j: integer;
  Params: DISPPARAMS;
  pArgs: PVariantArgList;
  pDispIds: array[0..0] of TDispID;
  pNames: array[0..0] of POleStr;
  VarResult: Variant;
begin
  Result := Unassigned;

  Flags := INVOKE_FUNC;

  Argc := High(AParams) + 1;
  if Argc < 0 then Argc := 0;

  // Method DISPID
  pNames[0] := PWideChar(MethodName);
  OleCheck(Dispatch.GetIDsOfNames(GUID_NULL, @pNames, 1, LOCALE_USER_DEFAULT, @pDispIds));

  // Building paramarray
  GetMem(pArgs, sizeof(TVariantArg) * Argc);
  j := 0;
  for i := High(AParams) downto Low(AParams) do
  begin
    // VariantCopy(vDest, AParams[i]);
    pArgs[j] := tagVARIANT(TVarData(AParams[i]));
    j := j + 1;
  end;

  Params.rgvarg := pArgs;
  Params.cArgs := Argc;
  params.cNamedArgs := 0;
  params.rgdispidNamedArgs := nil;

  try
    OleCheck(Dispatch.Invoke(pDispIds[0], GUID_NULL, LOCALE_USER_DEFAULT, Flags, TDispParams(Params), @VarResult, @ExcepInfo, @ArgErr));
    Result := VarResult;
  finally
    FreeMem(pArgs, sizeof(TVariantArg) * Argc);
  end;
end;

function DispatchInvoke(const Dispatch: IDispatch; const DispID: integer;
  const AParams: array of OleVariant): OleVariant; overload;
var
  Argc: integer;
  ArgErr: integer;
  ExcepInfo: TExcepInfo;
  Flags: Word;
  i: integer;
  j: integer;
  Params: DISPPARAMS;
  pArgs: PVariantArgList;
  VarResult: Variant;
begin
  Result := Unassigned;
  
  Flags := INVOKE_FUNC or INVOKE_PROPERTYPUT or INVOKE_PROPERTYPUTREF;
  
  Argc := High(AParams) + 1;
  if Argc < 0 then Argc := 0;

  GetMem(pArgs, sizeof(TVariantArg) * Argc);
  j := 0;
  for i := High(AParams) downto Low(AParams) do
  begin
    // VariantCopy(vDest, AParams[i]);
    pArgs[j] := tagVARIANT(TVarData(AParams[i]));
    j := j + 1;
  end;

  Params.rgvarg := pArgs;
  Params.cArgs := Argc;
  params.cNamedArgs := 0;
  params.rgdispidNamedArgs := nil;

  try
    OleCheck(Dispatch.Invoke(DispID, GUID_NULL, LOCALE_USER_DEFAULT, Flags, TDispParams(Params), @VarResult, @ExcepInfo, @ArgErr));
  finally
    FreeMem(pArgs, sizeof(TVariantArg) * Argc);
  end;
  Result := VarResult;
end;

procedure DispatchSetItem(const Dispatch: IDispatch; const Index: OleVariant; const Value: OleVariant);
var
  ArgErr: integer;
  ExcepInfo: TExcepInfo;
  Params: DISPPARAMS;
  pArgs: PVariantArgList;
  VarResult: Variant;
  Flags: Word;
begin
  Flags := INVOKE_FUNC or INVOKE_PROPERTYPUT or INVOKE_PROPERTYPUTREF;

  GetMem(pArgs, sizeof(TVariantArg) * 2);
  pArgs[0] := tagVARIANT(TVarData(Index));
  pArgs[1] := tagVARIANT(TVarData(Value));

  Params.rgvarg := pArgs;
  Params.cArgs := 2;
  params.cNamedArgs := 0;
  params.rgdispidNamedArgs := nil;

  try
    OleCheck(Dispatch.Invoke(DISPID_VALUE, GUID_NULL, LOCALE_USER_DEFAULT, Flags, TDispParams(Params), @VarResult, @ExcepInfo, @ArgErr));
  finally
    FreeMem(pArgs, sizeof(TVariantArg) * 2);
  end;
end;

function DispatchGetItem(const Dispatch: IDispatch; const Index: OleVariant): OleVariant;
var
  ArgErr: integer;
  ExcepInfo: TExcepInfo;
  Params: DISPPARAMS;
  pArgs: PVariantArgList;
  VarResult: Variant;
  Flags: Word;
begin
  Flags := INVOKE_FUNC or DISPATCH_PROPERTYGET;
  
  GetMem(pArgs, sizeof(TVariantArg) * 1);
  pArgs[0] := tagVARIANT(TVarData(Index));

  Params.rgvarg := pArgs;
  Params.cArgs := 1;
  params.cNamedArgs := 0;
  params.rgdispidNamedArgs := nil;
  try
    OleCheck(Dispatch.Invoke(DISPID_VALUE, GUID_NULL, LOCALE_USER_DEFAULT, Flags, TDispParams(Params), @VarResult, @ExcepInfo, @ArgErr));
  finally
    FreeMem(pArgs, sizeof(TVariantArg) * 1);
  end;
  Result := VarResult;
end;

procedure OleFinalizerHandler(vm: HVM; obj: tiscript_value); cdecl;
var
  pDisp: IDispatch;
begin
  pDisp := IDispatch(NI.get_instance_data(obj));
  pDisp._Release;
  NI.set_instance_data(obj, nil);
end;

function OleGetItemHandler(vm: HVM; this, key: tiscript_value): tiscript_value; cdecl;
var
  pSelf: Pointer;
  pDisp: IDispatch;
  oValue: OleVariant;
  oKey: OleVariant;
begin
  pSelf := NI.get_instance_data(this);

  if pSelf <> nil then
  begin
    pDisp := IDispatch(pSelf);

    // Key
    oKey := T2V(vm, key);

    oValue := DispatchGetItem(pDisp, oKey);

    if VarType(oValue) = varDispatch then
      Result := WrapOleObject(vm, IDispatch(oValue))
    else
      Result := T2V(vm, oValue);
  end
    else
  begin
    Result := NI.nothing_value;
  end;
end;

procedure OleSetItemHandler(vm: HVM; this, key, value: tiscript_value); cdecl;
var
  pSender: Pointer;
  pDisp: IDispatch;
  okey: OleVariant;
  ovalue: OleVariant;
begin
  pSender := NI.get_instance_data(this);
  if pSender <> nil then
  begin
    pDisp := IDispatch(pSender);

    oKey := T2V(vm, key);
    oValue := T2V(vm, value);

    DispatchSetItem(pDisp, oKey, oValue);
  end;
end;

procedure OleOnGCCopyHandler(instance_data: Pointer; new_self: tiscript_value); cdecl;
var
  pThis: IDispatch;
begin
  if instance_data <> nil then
  begin
    pthis := IDispatch(instance_data);
    pthis._AddRef();
    NI.set_instance_data(new_self, Pointer(pthis));
  end;
end;

function OleGetterHandler(vm: HVM; obj: tiscript_value; tag: Pointer): tiscript_value; cdecl;
var
  pSender: Pointer;
  pDispatch: IDispatch;
  pMethodInfo: TSciterMethodInfo;
  oValue: OleVariant;
begin
  pMethodInfo := TSciterMethodInfo(tag);

  pSender := NI.get_instance_data(obj);
  pDispatch := IDispatch(pSender);

  oValue := ComObj.GetDispatchPropValue(pDispatch, pMethodInfo.Name);

  if VarType(oValue) = varDispatch then
    Result := WrapOleObject(vm, IDispatch(oValue))
  else
    Result := V2T(vm, oValue);
end;

procedure OleSetterHandler(vm: HVM; obj, value: tiscript_value; tag: Pointer); cdecl;
var
  pMethodInfo: TSciterMethodInfo;
  pSender: Pointer;
  pDispatch: IDispatch;
  oValue: OleVariant;
begin
  pSender := NI.get_instance_data(obj);
  pDispatch := IDispatch(pSender);
  pMethodInfo := TSciterMethodInfo(tag);
  oValue := T2V(vm, value);
  ComObj.SetDispatchPropValue(pDispatch, pMethodInfo.Name, oValue);
end;

function OleMethodHandler(vm: HVM; obj: tiscript_value; tag: Pointer): tiscript_value; cdecl;
var
  pSender: Pointer;
  pDisp: IDispatch;
  pInfo: TSciterMethodInfo;
  argc: Integer;
  arg: tiscript_value;
  sarg: TSciterValue;
  oargs: array of OleVariant;
  i: Integer;
  oresult: OleVariant;
begin
  pSender    := NI.get_instance_data(obj);
  pDisp      := IDispatch(pSender);
  pInfo      := TSciterMethodInfo(tag);

  argc := NI.get_arg_count(vm);

  // Invoke params
  SetLength(oargs, argc - 2);
  for i := 2 to argc - 1 do
  begin
    arg := NI.get_arg_n(vm, i);
    API.Sciter_T2S(vm, arg, sarg, false);
    S2V(@sarg, oargs[i - 2]);
  end;

  // Call method
  oResult := DispatchInvoke(pDisp, pInfo.Name, oargs);

  if VarType(oResult) = varDispatch then
    Result := WrapOleObject(vm, IDispatch(oResult))
  else
    Result := V2T(vm, oResult);
end;

constructor TSciterOleWrapper.Create;
begin
  inherited;
  Self.GetItemHandler := OleGetItemHandler;
  Self.SetItemHandler := OleSetItemHandler;
  Self.GCCopyHandler := OleOnGCCopyHandler;
  Self.FinalizerHandler := OleFinalizerHandler;
  Self.MethodHandler := OleMethodHandler;
  Self.GetterHandler := OleGetterHandler;
  Self.SetterHandler := OleSetterHandler;
end;

destructor TSciterOleWrapper.Destroy;
begin
  FDispatch := nil;
  inherited;
end;

{ TSciterOleWrapper }

procedure TSciterOleWrapper.Build(const Obj: IDispatch);
begin
  FDispatch := Obj;
  Self.TypeName := GetOleObjectGuid(Obj);
  inherited Build(Pointer(Obj));
end;

procedure TSciterOleWrapper.PopulateMethods(const List: TSciterMethodList);
var
  typeInfo: ITypeInfo;
  typeAttr: PTypeAttr;
  funcDesc: PFuncDesc;
  sfuncName: PWideChar;
  funcName: WideString;
  i: Integer;
  cNames: Integer;
  pMethodInfo: TSciterMethodInfo;
begin
  try
    if FDispatch = nil then
      Exit;

    OleCheck(FDispatch.GetTypeInfo(0, LOCALE_USER_DEFAULT, typeInfo));
    OleCheck(typeInfo.GetTypeAttr(typeAttr));

    for i := 0 to typeAttr.cFuncs - 1 do
    try
      funcDesc := nil;
      OleCheck(typeInfo.GetFuncDesc(i, funcDesc));

      sfuncName := nil;
      typeInfo.GetNames(funcDesc.memid, @sfuncName, 1, cNames);
      funcName := WideString(sfuncName);

      pMethodInfo := List.LookupMethod(funcName);

      if funcDesc.invkind = INVOKE_FUNC then
      begin
        pMethodInfo.CallType := Method;
        pMethodInfo.CallArgsCount := funcDesc.cParams;
      end
        else
      if funcDesc.invkind = INVOKE_PROPERTYGET then
      begin
        if funcDesc.cParams > 0 then
        begin
          // Indexed property
          pMethodInfo.CallType := IndexedProperty;
        end
          else
        begin
          // Non-indexed property
          pMethodInfo.CallType := NonIndexedProperty;
        end;
        pMethodInfo.HasGetter := true;
        pMethodInfo.GetArgsCount := funcDesc.cParams;
      end
        else
      // INVOKE_PROPERTYPUT or INVOKE_PROPERTYPUTREF
      begin
        if funcDesc.cParams > 1 then
        begin
          // Indexed property
          pMethodInfo.CallType := IndexedProperty;

        end
          else
        begin
          // Non-indexed property
          pMethodInfo.CallType := NonIndexedProperty;
        end;
        pMethodInfo.HasSetter := True;
        pMethodInfo.SetArgsCount := funcDesc.cParams;
      end;
     finally
       // if sfuncName <> nil then
       //   CoTaskMemFree(sfuncName);
       if funcDesc <> nil then
        typeInfo.ReleaseFuncDesc(funcDesc);
    end;
  finally
    if typeAttr <> nil then
      if typeInfo <> nil then
        typeInfo.ReleaseTypeAttr(typeAttr);
  end;
end;

end.
