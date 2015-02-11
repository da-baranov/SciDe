unit SciterOleProxy;

interface

uses
  Windows, Messages, Classes, Variants, Contnrs, SciterApi, TiScriptApi, SysUtils, SciterNativeProxy,
  ComObj, ActiveX;

type
  ESciterOleException = class(ESciterException)
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

  TActiveXObjectImpl = class(TSciterClassInfo)
  protected
    procedure PopulateMethods(const List: TSciterMethodList); override;
  public
    constructor Create; override;
  end;

function GetOleObjectGuid(const Obj: IDispatch): AnsiString;
function RegisterOleObjectClass(vm: HVM; const Dispatch: IDispatch): tiscript_value;
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

function RegisterOleObjectClass(vm: HVM; const Dispatch: IDispatch): tiscript_value;
var
  sciter_class_def: tiscript_class_def;
  pClassInfo: TSciterOleWrapper;
begin
  pClassInfo := TSciterOleWrapper.Create;
  pClassInfo.Build(Dispatch);
  pClassInfo.GetClassDef(sciter_class_def);
  Result := RegisterNativeClass(vm, @sciter_class_def, False, False);
  pClassInfo.FreeClassDef(sciter_class_def);
end;

function WrapOleObject(vm: HVM; const Dispatch: IDispatch): tiscript_value;
var
  ole_class_def: tiscript_value;
begin
  ole_class_def := RegisterOleObjectClass(vm, Dispatch);
  Dispatch._AddRef;
  Result := SciterApi.CreateObjectInstance(vm, Pointer(Dispatch), ole_class_def);
end;

function RegisterOleObject(vm: HVM; const Dispatch: IDispatch; const Name: WideString): tiscript_value;
var
  ole_class_def: tiscript_value;
  class_instance: tiscript_value;
begin
  if SciterApi.IsNameExists(vm, Name) then
    raise ESciterOleException.CreateFmt('Cannot register OLE Object: variable with name %s already exists.', [Name]);
    
  ole_class_def := RegisterOleObjectClass(vm, Dispatch);
  class_instance := SciterApi.CreateObjectInstance(vm, Pointer(Dispatch), ole_class_def);
  SciterApi.RegisterObject(vm, class_instance, Name);

  Result := class_instance;
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

function OleIteratorHandler(vm: HVM; index: ptiscript_value; obj: tiscript_value): tiscript_value; cdecl;
var
  pDisp: IDispatch;
  oIndex: OleVariant;
  oValue: OleVariant;
  pEnum: IEnumVariant;
  Params: DISPPARAMS;
  VarResult: Variant;
  Flags: Word;
  ExcepInfo: TExcepInfo;
  ArgErr: integer;
  Celt: UINT;
  CeltFetched: UINT;
begin
  Result := NI.nothing_value;
  
  try
    pDisp := IDispatch(NI.get_instance_data(obj));
    if not NI.is_int(index^) then
    begin
      index^ := NI.int_value(0);
    end;

    oIndex := T2V(vm, index^);

    Flags := INVOKE_FUNC or INVOKE_PROPERTYGET;

    Params.rgvarg := nil;
    Params.cArgs := 0;
    params.cNamedArgs := 0;
    params.rgdispidNamedArgs := nil;

    if Succeeded(pDisp.Invoke(DISPID_NEWENUM, GUID_NULL, LOCALE_USER_DEFAULT, Flags, TDispParams(Params), @VarResult, @ExcepInfo, @ArgErr)) then
    begin
      Celt := oIndex;
      if VarSupports(VarResult, IEnumVariant, pEnum) then
      begin
        if pEnum.Reset = S_OK then
          if pEnum.Skip(Celt) = S_OK then
            if pEnum.Next(1, oValue, CeltFetched) = S_OK then
            begin
              if VarType(oValue) = varDispatch then
              begin
                Result := WrapOleObject(vm, IDispatch(oValue));
                index^ := NI.int_value(Integer(oIndex) + 1);
              end
                else
              begin
                Result := V2T(vm, oValue);
                index^ := NI.int_value(Integer(oIndex) + 1);
              end;
              Exit;
            end;
      end
        else
      begin
        ThrowError(vm, 'Iterator is not supported. Cannot cast value returned by property or method with DISPID=-4 to IEnumVARIANT.');
        Exit;
      end;
    end
      else
    begin
      ThrowError(vm, 'Iterator is not supported.');
      Exit;
    end;
  except
    on E:Exception do
      ThrowError(vm, E.Message);
  end;
end;

procedure OleFinalizerHandler(vm: HVM; obj: tiscript_value); cdecl;
var
  pDisp: IDispatch;
begin
  try
    pDisp := IDispatch(NI.get_instance_data(obj));
    pDisp._Release;
    NI.set_instance_data(obj, nil);
  except
    on E:Exception do
      ThrowError(vm, E.Message);
  end;
end;

function OleGetItemHandler(vm: HVM; this, key: tiscript_value): tiscript_value; cdecl;
var
  pSelf: Pointer;
  pDisp: IDispatch;
  oValue: OleVariant;
  oKey: OleVariant;
begin
  Result := NI.nothing_value;
  try
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
    end;
  except
    on E:Exception do
      ThrowError(vm, E.Message);
  end;
end;

procedure OleSetItemHandler(vm: HVM; this, key, value: tiscript_value); cdecl;
var
  pSender: Pointer;
  pDisp: IDispatch;
  okey: OleVariant;
  ovalue: OleVariant;
begin
  try
    pSender := NI.get_instance_data(this);
    if pSender <> nil then
    begin
      pDisp := IDispatch(pSender);

      oKey := T2V(vm, key);
      oValue := T2V(vm, value);

      DispatchSetItem(pDisp, oKey, oValue);
    end;
  except
    on E:Exception do
      ThrowError(vm, E.Message);
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
  Result := NI.nothing_value;
  try
    pMethodInfo := TObject(tag) as TSciterMethodInfo;

    pSender := NI.get_instance_data(obj);
    pDispatch := IDispatch(pSender);

    oValue := ComObj.GetDispatchPropValue(pDispatch, pMethodInfo.Name);

    if VarType(oValue) = varDispatch then
      Result := WrapOleObject(vm, IDispatch(oValue))
    else
      Result := V2T(vm, oValue);
  except
    on E:Exception do
      ThrowError(vm, E.Message);
  end;
end;

procedure OleSetterHandler(vm: HVM; obj, value: tiscript_value; tag: Pointer); cdecl;
var
  pMethodInfo: TSciterMethodInfo;
  pSender: Pointer;
  pDispatch: IDispatch;
  oValue: OleVariant;
begin
  try
    pSender := NI.get_instance_data(obj);
    pDispatch := IDispatch(pSender);
    pMethodInfo := TObject(tag) as TSciterMethodInfo;
    oValue := T2V(vm, value);
    ComObj.SetDispatchPropValue(pDispatch, pMethodInfo.Name, oValue);
  except
    on E:Exception do
      ThrowError(vm, E.Message);
  end;
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
  Result := NI.nothing_value;
  try
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
  except
    on E:Exception do
      ThrowError(vm, E.Message);
  end;
end;

constructor TSciterOleWrapper.Create;
begin
  inherited;
  Self.GetItemHandler   := OleGetItemHandler;
  Self.SetItemHandler   := OleSetItemHandler;
  Self.GCCopyHandler    := OleOnGCCopyHandler;
  Self.FinalizerHandler := OleFinalizerHandler;
  Self.MethodHandler    := OleMethodHandler;
  Self.GetterHandler    := OleGetterHandler;
  Self.SetterHandler    := OleSetterHandler;
  Self.IteratorHandler  := OleIteratorHandler;
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

{ TActiveXObjectImpl }

function ActiveXObjectCtor(vm: HVM; self: tiscript_value; tag: Pointer): tiscript_value; cdecl;
var
  nArgc: Integer;
  tProgId: tiscript_value;
  sProgId: OleVariant;
  oDisp: OleVariant;
  pDisp: IDispatch;
begin
  nArgc := NI.get_arg_count(vm);
  if nArgc <> 3 then
    raise ESciterOleException.CreateFmt('Cannot initialize ActiveXObject. Required constructor parameter (ProgID) is missing.', []);
  tProgId := NI.get_arg_n(vm, 2);
  sProgId := T2V(vm, tProgId);

  oDisp := CreateOleObject(sProgId);
  pDisp := IDispatch(oDisp);

  Result := WrapOleObject(vm, pDisp);
end;

constructor TActiveXObjectImpl.Create;
begin
  inherited;
  Self.TypeName := 'ActiveXObject';
  Self.MethodHandler := @ActiveXObjectCtor;
end;

procedure TActiveXObjectImpl.PopulateMethods(
  const List: TSciterMethodList);
var
  pMethod: TSciterMethodInfo;
begin
  pMethod := List.LookupMethod('this');
  pMethod.CallArgsCount := 1;
end;

end.
