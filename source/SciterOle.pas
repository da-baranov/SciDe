{*******************************************************}
{                                                       }
{  Helper classes for Sciter/OLE interaction            }
{  Copyright (c) Dmitry Baranov                         }
{                                                       }
{  This unit uses Sciter Engine,                        }
{  copyright Terra Informatica Software, Inc.           }
{  (http://terrainformatica.com/).                      }
{                                                       }
{*******************************************************}

unit SciterOle;

interface

uses
  Windows, Messages, Classes, Variants, Contnrs, SciterApi, TiScriptApi, SysUtils, SciterNative,
  ComObj, ActiveX;

type
  ESciterOleException = class(ESciterException)
  end;

  ISciterOleClassInfo = interface(ISciterClassInfo)
    procedure Build(Ptr: Pointer); overload;
    procedure Build(const Value: OleVariant); overload;
    procedure Build(const Dispatch: IDispatch); overload;
    procedure Build(const TypeInfo: ITypeInfo); overload;
  end;

  TSciterOleNative = class(TSciterClassInfo, ISciterOleClassInfo)
  public
    constructor Create; override;
    procedure Build(Ptr: Pointer); overload;
    procedure Build(const Value: OleVariant); overload;
    procedure Build(const Dispatch: IDispatch); overload;
    procedure Build(const TypeInfo: ITypeInfo); overload;
  end;

function DispatchInvoke(const Dispatch: IDispatch; const DispID: integer;
  const AParams: array of OleVariant): OleVariant; overload;

function DispatchInvoke(const Dispatch: IDispatch; const MethodName: WideString;
  const AParams: array of OleVariant): OleVariant; overload;

function DispatchGetItem(const Dispatch: IDispatch; const Index: OleVariant): OleVariant;

procedure DispatchSetItem(const Dispatch: IDispatch; const Index: OleVariant; const Value: OleVariant);

function GetOleObjectGuid(const Obj: IDispatch): AnsiString;

function FindOrCreateOleObjectClass(vm: HVM; const Dispatch: IDispatch): tiscript_class;

function RegisterOleObject(vm: HVM; const Dispatch: IDispatch; const Name: WideString): tiscript_object;

function WrapOleObject(vm: HVM; const Dispatch: IDispatch): tiscript_object;

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
    Result := AnsiString(GUIDToString(typeAttr.guid));
  finally
    if typeAttr <> nil then
      if typeInfo <> nil then
        typeInfo.ReleaseTypeAttr(typeAttr);
  end;
end;

function FindOrCreateOleObjectClass(vm: HVM; const Dispatch: IDispatch): tiscript_class;
var
  pOleClassInfo: ISciterOleClassInfo;
  sGuid: AnsiString;
begin
  sGuid := GetOleObjectGuid(Dispatch);
  
  if not ClassBag.ClassInfoExists(vm, sGuid) then
  begin
    pOleClassInfo := TSciterOleNative.Create;
    pOleClassInfo.Build(Dispatch);
    Result := ClassBag.RegisterClassInfo(vm, pOleClassInfo);
  end
    else
  begin
    Result := SciterApi.GetNativeClass(vm, WideString(sGuid));
  end;
end;

function WrapOleObject(vm: HVM; const Dispatch: IDispatch): tiscript_object;
var
  ole_class_def: tiscript_class;
begin
  if Dispatch = nil then
  begin
    Result := NI.undefined_value;
    Exit;
  end;
  
  ole_class_def := FindOrCreateOleObjectClass(vm, Dispatch);
  Dispatch._AddRef;
  Result := SciterApi.CreateObjectInstance(vm, Pointer(Dispatch), ole_class_def);
end;

function RegisterOleObject(vm: HVM; const Dispatch: IDispatch; const Name: WideString): tiscript_object;
var
  ole_class_def: tiscript_class;
  class_instance: tiscript_object;
begin
  if SciterApi.IsNameExists(vm, Name) then
    raise ESciterOleException.CreateFmt('Cannot register OLE Object: variable with name %s already exists.', [Name]);

  Assert(Dispatch <> nil, 'OLE object is undefined');
      
  ole_class_def := FindOrCreateOleObjectClass(vm, Dispatch);
  Dispatch._AddRef;
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
    try
      OleCheck(Dispatch.Invoke(pDispIds[0], GUID_NULL, LOCALE_USER_DEFAULT, Flags, TDispParams(Params), @VarResult, @ExcepInfo, @ArgErr));
      Result := VarResult;
    finally
      FreeMem(pArgs, sizeof(TVariantArg) * Argc);
    end;
  except
    on E:EOleError do
    begin
      raise ESciterOleException.CreateFmt('OLE Error code %d: %s', [ExcepInfo.wCode, ExcepInfo.bstrDescription]);
    end;
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
    try
      OleCheck(Dispatch.Invoke(DispID, GUID_NULL, LOCALE_USER_DEFAULT, Flags, TDispParams(Params), @VarResult, @ExcepInfo, @ArgErr));
    finally
      FreeMem(pArgs, sizeof(TVariantArg) * Argc);
    end;
  except
    on E:EOleError do
    begin
      raise ESciterOleException.CreateFmt('OLE Error code %d: %s', [ExcepInfo.wCode, ExcepInfo.bstrDescription]);
    end;
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
    try
      OleCheck(Dispatch.Invoke(DISPID_VALUE, GUID_NULL, LOCALE_USER_DEFAULT, Flags, TDispParams(Params), @VarResult, @ExcepInfo, @ArgErr));
    finally
      FreeMem(pArgs, sizeof(TVariantArg) * 2);
    end;
  except
    on E:EOleError do
    begin
      raise ESciterOleException.CreateFmt('OLE Error code %d: %s', [ExcepInfo.wCode, ExcepInfo.bstrDescription]);
    end;
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
    try
      OleCheck(Dispatch.Invoke(DISPID_VALUE, GUID_NULL, LOCALE_USER_DEFAULT, Flags, TDispParams(Params), @VarResult, @ExcepInfo, @ArgErr));
    finally
      FreeMem(pArgs, sizeof(TVariantArg) * 1);
    end;
  except
    on E:EOleError do
    begin
      raise ESciterOleException.CreateFmt('OLE Error code %d: %s', [ExcepInfo.wCode, ExcepInfo.bstrDescription]);
    end;
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
  iCounter: Integer;
begin
  try
    pDisp := IDispatch(NI.get_instance_data(obj));
    iCounter := pDisp._Release; // in most cases should be 1 here
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
begin
  if instance_data <> nil then
  begin
    //pthis := IDispatch(instance_data);
    //pthis._AddRef();
    //NI.set_instance_data(new_self, Pointer(pthis));

    NI.set_instance_data(new_self, instance_data);
  end;
end;

function OleGetterHandler(vm: HVM; obj: tiscript_value; tag: Pointer): tiscript_value; cdecl;
var
  pSender: Pointer;
  pDispatch: IDispatch;
  sMethodName: AnsiString;
  oValue: OleVariant;
begin
  Result := NI.nothing_value;
  try
    sMethodName := ISciterMethodInfo(tag).Name;

    pSender := NI.get_instance_data(obj);
    pDispatch := IDispatch(pSender);

    oValue := ComObj.GetDispatchPropValue(pDispatch, WideString(sMethodName));

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
  pSender: Pointer;
  pDispatch: IDispatch;
  oValue: OleVariant;
  sMethodName: AnsiString;
begin
  sMethodName := ISciterMethodInfo(tag).Name;
  try
    pSender := NI.get_instance_data(obj);
    pDispatch := IDispatch(pSender);
    oValue := T2V(vm, value);
    ComObj.SetDispatchPropValue(pDispatch, WideString(sMethodName), oValue);
  except
    on E:Exception do
      ThrowError(vm, E.Message);
  end;
end;

function OleMethodHandler(vm: HVM; obj: tiscript_value; tag: Pointer): tiscript_value; cdecl;
var
  pSender: Pointer;
  pDisp: IDispatch;
  sMethodName: AnsiString;
  argc: Integer;
  arg: tiscript_value;
  pthis: tiscript_object;
  sarg: TSciterValue;
  oargs: array of OleVariant;
  i: Integer;
  oresult: OleVariant;
begin
  Result := NI.nothing_value;
  sMethodName := ISciterMethodInfo(tag).Name;
  try
    pthis := NI.get_arg_n(vm, 0);
    // super = arg(1)
    //
    pSender    := NI.get_instance_data(pthis);
    pDisp      := IDispatch(pSender);

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
    oResult := DispatchInvoke(pDisp, WideString(sMethodName), oargs);

    if VarType(oResult) = varDispatch then
      Result := WrapOleObject(vm, IDispatch(oResult))
    else
      Result := V2T(vm, oResult);
  except
    on E:Exception do
      ThrowError(vm, E.Message);
  end;
end;

constructor TSciterOleNative.Create;
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

{ TSciterOleWrapper }

procedure TSciterOleNative.Build(Ptr: Pointer);
var
  pDisp: IDispatch;
begin
  if Ptr = nil then
    raise ESciterNullPointerException.Create;

  try
    pDisp := IDispatch(Ptr);
    pDisp._AddRef;
    pDisp._Release;
  except
    on E:Exception do
      raise ESciterException.Create('Cannot cast pointer to IDispatch.');
  end;
  Build(IDispatch(Ptr));
end;

procedure TSciterOleNative.Build(const Value: OleVariant);
begin
  Build(IDispatch(Value));
end;

procedure TSciterOleNative.Build(const Dispatch: IDispatch);
var
  pTypeInfo: ITypeInfo;
begin
  if Dispatch = nil then
    raise ESciterNullPointerException.Create;
    
  OleCheck(Dispatch.GetTypeInfo(0, LOCALE_USER_DEFAULT, pTypeInfo));
  Build(pTypeInfo);
end;

procedure TSciterOleNative.Build(const TypeInfo: ITypeInfo);
var
  typeAttr: PTypeAttr;
  funcDesc: PFuncDesc;
  sfuncName: PWideChar;
  funcName: WideString;
  i: Integer;
  cNames: Integer;
  pMethodInfo: ISciterMethodInfo;
begin
  if TypeInfo = nil then
    raise ESciterNullPointerException.Create;
    
  try
    OleCheck(TypeInfo.GetTypeAttr(typeAttr));

    Self.TypeName := AnsiString(GUIDToString(typeAttr.guid));

    for i := 0 to typeAttr.cFuncs - 1 do
    try
      funcDesc := nil;
      OleCheck(typeInfo.GetFuncDesc(i, funcDesc));

      sfuncName := nil;
      typeInfo.GetNames(funcDesc.memid, @sfuncName, 1, cNames);
      funcName := WideString(sfuncName);

      pMethodInfo := Methods.LookupMethod(AnsiString(funcName));

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
