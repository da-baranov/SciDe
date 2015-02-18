{*******************************************************}
{                                                       }
{  Helper classes for native integration with Sciter    }
{  Copyright (c) Dmitry Baranov                         }
{                                                       }
{  This Application (or Component) uses Sciter Engine,  }
{  copyright Terra Informatica Software, Inc.           }
{  (http://terrainformatica.com/).                      }
{                                                       }
{*******************************************************}

unit SciterNative;

interface
                                                                                  
uses
  Windows, Messages, Classes, Variants, Contnrs, SciterApi, TiScriptApi, SysUtils,
  ComObj, ActiveX;

type
  TMethodType = (Method, NonIndexedProperty, IndexedProperty);

  TSciterMethodList = class;
  TSciterMethodInfo = class;

  ISciterMethodInfo = interface;
  ISciterMethodInfoList = interface;
  ISciterClassInfo = interface;
  ISciterClassInfoList = interface;
  IVMClassBag = interface;
  IVMClassBagList = interface;
  ISciterClassBag = interface;

  ISciterClassInfo = interface
    ['{2BE4157E-35F2-4279-AD60-C54A867153DE}']
    function GetFinalizerHandler: tiscript_finalizer;
    function GetGCCopyHandler: tiscript_on_gc_copy;
    function GetGetItemHandler: tiscript_get_item;
    function GetGetterHandler: tiscript_tagged_get_prop;
    function GetIteratorHandler: tiscript_iterator;
    function GetMethodHandler: tiscript_tagged_method;
    function GetMethods: ISciterMethodInfoList;
    function GetSciterClassDef: ptiscript_class_def;
    function GetSetItemHandler: tiscript_set_item;
    function GetSetterHandler: tiscript_tagged_set_prop;
    function GetTypeName: WideString;
    procedure SetFinalizerHandler(const Value: tiscript_finalizer);
    procedure SetGCCopyHandler(const Value: tiscript_on_gc_copy);
    procedure SetGetItemHandler(const Value: tiscript_get_item);
    procedure SetGetterHandler(const Value: tiscript_tagged_get_prop);
    procedure SetIteratorHandler(const Value: tiscript_iterator);
    procedure SetMethodHandler(const Value: tiscript_tagged_method);
    procedure SetSetItemHandler(const Value: tiscript_set_item);
    procedure SetSetterHandler(const Value: tiscript_tagged_set_prop);
    procedure SetTypeName(const Value: WideString);
    function ToString: String;
    property FinalizerHandler: tiscript_finalizer read GetFinalizerHandler write SetFinalizerHandler;
    property GCCopyHandler: tiscript_on_gc_copy read GetGCCopyHandler write SetGCCopyHandler;
    property GetItemHandler: tiscript_get_item read GetGetItemHandler write SetGetItemHandler;
    property GetterHandler: tiscript_tagged_get_prop read GetGetterHandler write SetGetterHandler;
    property IteratorHandler: tiscript_iterator read GetIteratorHandler write SetIteratorHandler;
    property MethodHandler: tiscript_tagged_method read GetMethodHandler write SetMethodHandler;
    property Methods: ISciterMethodInfoList read GetMethods;
    property SciterClassDef: ptiscript_class_def read GetSciterClassDef;
    property SetItemHandler: tiscript_set_item read GetSetItemHandler write SetSetItemHandler;
    property SetterHandler: tiscript_tagged_set_prop read GetSetterHandler write SetSetterHandler;
    property TypeName: WideString read GetTypeName write SetTypeName;
  end;

  TSciterClassInfo = class(TInterfacedObject, ISciterClassInfo)
  private
    FAllMethods: ISciterMethodInfoList;
    FFinalizerHandler: tiscript_finalizer;
    FGCCopyHandler: tiscript_on_gc_copy;
    FGetItemHandler: tiscript_get_item;
    FGetterHandler: tiscript_tagged_get_prop;
    FIteratorHandler: tiscript_iterator;
    FMethodHandler: tiscript_tagged_method;
    FMethods: ISciterMethodInfoList;
    FProps: ISciterMethodInfoList;
    FSetItemHandler: tiscript_set_item;
    FSetterHandler: tiscript_tagged_set_prop;
    FTypeName: AnsiString;
    function SelectMethods: ISciterMethodInfoList;
    function SelectProperties: ISciterMethodInfoList;
  protected
    FSciterClassDef: ptiscript_class_def;
    function GetFinalizerHandler: tiscript_finalizer;
    function GetGCCopyHandler: tiscript_on_gc_copy;
    function GetGetItemHandler: tiscript_get_item;
    function GetGetterHandler: tiscript_tagged_get_prop;
    function GetIteratorHandler: tiscript_iterator;
    function GetMethodHandler: tiscript_tagged_method;
    function GetMethods: ISciterMethodInfoList;
    function GetSciterClassDef: ptiscript_class_def;
    function GetSetItemHandler: tiscript_set_item;
    function GetSetterHandler: tiscript_tagged_set_prop;
    function GetTypeName: WideString;
    procedure SetFinalizerHandler(const Value: tiscript_finalizer);
    procedure SetGCCopyHandler(const Value: tiscript_on_gc_copy);
    procedure SetGetItemHandler(const Value: tiscript_get_item);
    procedure SetGetterHandler(const Value: tiscript_tagged_get_prop);
    procedure SetIteratorHandler(const Value: tiscript_iterator);
    procedure SetMethodHandler(const Value: tiscript_tagged_method);
    procedure SetSetItemHandler(const Value: tiscript_set_item);
    procedure SetSetterHandler(const Value: tiscript_tagged_set_prop);
    procedure SetTypeName(const Value: WideString);
    property FinalizerHandler: tiscript_finalizer read GetFinalizerHandler write SetFinalizerHandler;
    property GCCopyHandler: tiscript_on_gc_copy read GetGCCopyHandler write SetGCCopyHandler;
    property GetItemHandler: tiscript_get_item read GetGetItemHandler write SetGetItemHandler;
    property GetterHandler: tiscript_tagged_get_prop read GetGetterHandler write SetGetterHandler;
    property IteratorHandler: tiscript_iterator read GetIteratorHandler write SetIteratorHandler;
    property MethodHandler: tiscript_tagged_method read GetMethodHandler write SetMethodHandler;
    property Methods: ISciterMethodInfoList read GetMethods;
    property SetItemHandler: tiscript_set_item read GetSetItemHandler write SetSetItemHandler;
    property SetterHandler: tiscript_tagged_set_prop read GetSetterHandler write SetSetterHandler;
    property TypeName: WideString read GetTypeName write SetTypeName;
    procedure FreeClassDef;
    procedure BuildClassDef;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function ToString: String; {$IFDEF UNICODE} override; {$ENDIF}
    property SciterClassDef: ptiscript_class_def read GetSciterClassDef;
  end;

  ISciterMethodInfo = interface
  ['{4C446750-0C0E-4F59-99E8-013EAF05CF5C}']
    function GetCallArgsCount: Integer;
    function GetCallType: TMethodType;
    function GetGetArgsCount: Integer;
    function GetHasGetter: Boolean;
    function GetHasSetter: Boolean;
    function GetName: WideString;
    function GetSetArgsCount: Integer;
    procedure SetCallArgsCount(const Value: Integer);
    procedure SetCallType(const Value: TMethodType);
    procedure SetGetArgsCount(const Value: Integer);
    procedure SetHasGetter(const Value: Boolean);
    procedure SetHasSetter(const Value: Boolean);
    procedure SetName(const Value: WideString);
    procedure SetSetArgsCount(const Value: Integer);
    function ToString: String;
    property CallArgsCount: Integer read GetCallArgsCount write SetCallArgsCount;
    property CallType: TMethodType read GetCallType write SetCallType;
    property GetArgsCount: Integer read GetGetArgsCount write SetGetArgsCount;
    property HasGetter: Boolean read GetHasGetter write SetHasGetter;
    property HasSetter: Boolean read GetHasSetter write SetHasSetter;
    property Name: WideString read GetName write SetName;
    property SetArgsCount: Integer read GetSetArgsCount write SetSetArgsCount;
  end;

  ISciterMethodInfoList = interface
    ['{A4230388-20BF-4ED5-81B7-C5227F579CFC}']
    procedure Add(const Item: ISciterMethodInfo);
    procedure Clear;
    function Exists(const MethodName: AnsiString): boolean;
    function GetCount: Integer;
    function GetItem(Index: Integer): ISciterMethodInfo;
    function LookupMethod(const MethodName: AnsiString): ISciterMethodInfo;
    property Count: Integer read GetCount;
    property Item[Index: Integer]: ISciterMethodInfo read GetItem; default;
  end;

  TSciterMethodInfo = class(TInterfacedObject, ISciterMethodInfo)
  private
    FCallArgsCount: Integer;
    FCallType: TMethodType;
    FGetArgsCount: Integer;
    FHasGetter: Boolean;
    FHasSetter: Boolean;
    FName: AnsiString;
    FSetArgsCount: Integer;
    function GetCallArgsCount: Integer;
    function GetCallType: TMethodType;
    function GetGetArgsCount: Integer;
    function GetHasGetter: Boolean;
    function GetHasSetter: Boolean;
    function GetName: WideString;
    function GetSetArgsCount: Integer;
    procedure SetCallArgsCount(const Value: Integer);
    procedure SetCallType(const Value: TMethodType);
    procedure SetGetArgsCount(const Value: Integer);
    procedure SetHasGetter(const Value: Boolean);
    procedure SetHasSetter(const Value: Boolean);
    procedure SetName(const Value: WideString);
    procedure SetSetArgsCount(const Value: Integer);
  public
    destructor Destroy; override;
    function ToString: String; {$IFDEF UNICODE} override; {$ENDIF}
    property CallArgsCount: Integer read GetCallArgsCount write SetCallArgsCount;
    property CallType: TMethodType read GetCallType write SetCallType;
    property GetArgsCount: Integer read GetGetArgsCount write SetGetArgsCount;
    property HasGetter: Boolean read GetHasGetter write SetHasGetter;
    property HasSetter: Boolean read GetHasSetter write SetHasSetter;
    property Name: WideString read GetName write SetName;
    property SetArgsCount: Integer read GetSetArgsCount write SetSetArgsCount;
  end;

  TSciterMethodList = class(TInterfacedObject, ISciterMethodInfoList)
  private
    FList: TInterfaceList;
    function GetCount: Integer;
    function GetItem(Index: Integer): ISciterMethodInfo;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const Item: ISciterMethodInfo);
    procedure Clear;
    function Exists(const MethodName: AnsiString): boolean;
    function LookupMethod(const MethodName: AnsiString): ISciterMethodInfo;
    property Count: Integer read GetCount;
    property Item[Index: Integer]: ISciterMethodInfo read GetItem; default;
  end;

  ISciterClassInfoList = interface
    ['{8A49B48A-8BED-4668-AB37-64C2BD019F96}']
    procedure Add(const ClsInfo: ISciterClassInfo);
    function Exists(const TypeName: AnsiString): boolean;
    function FindClassInfo(const TypeName: AnsiString): ISciterClassInfo;
    function GetCount: Integer;
    function GetItem(Index: Integer): ISciterClassInfo;
    function ToString: String;
    property Count: Integer read GetCount;
    property Item[Index: Integer]: ISciterClassInfo read GetItem; default;
  end;

  TSciterClassInfoList = class(TInterfacedObject, ISciterClassInfoList)
  private
    FList: TInterfaceList;
    function GetCount: Integer;
    function GetItem(Index: Integer): ISciterClassInfo;
  protected
    procedure Add(const ClsInfo: ISciterClassInfo);
    function Exists(const TypeName: AnsiString): boolean;
    function FindClassInfo(const TypeName: AnsiString): ISciterClassInfo;
    property Count: Integer read GetCount;
    property Item[Index: Integer]: ISciterClassInfo read GetItem; default;
  public
    constructor Create;
    destructor Destroy; override;
    function ToString: String; {$IFDEF UNICODE} override; {$ENDIF}
  end;
  
  { Key-value pair where key is a HVM and value is a list of class definitions registered for that VM }
  IVMClassBag = interface
    ['{BC375E40-BB49-4B0A-A4F4-C61ADA94ED03}']
    function GetClassInfoList: ISciterClassInfoList;
    function GetVM: HVM;
    function ToString: String;
    property ClassInfoList: ISciterClassInfoList read GetClassInfoList;
    property VM: HVM read GetVM;
  end;

  TVMClassBag = class(TInterfacedObject, IVMClassBag)
  private
    FList: ISciterClassInfoList;
    FVM: HVM;
    function GetClassInfoList: ISciterClassInfoList;
    function GetVM: HVM;
  protected
    constructor Create(vm: HVM);
  public
    destructor Destroy; override;
    function ToString: String;  {$IFDEF UNICODE} override; {$ENDIF}
    property ClassInfoList: ISciterClassInfoList read GetClassInfoList;
    property VM: HVM read GetVM;
  end;

  IVMClassBagList = interface
    ['{B7B0C33B-7B30-4B32-A3A5-630621887710}']
    procedure Add(const Item: IVMClassBag);
    function ClassInfoExists(const vm: HVM; const TypeName: AnsiString): boolean;
    function Exists(const VM: HVM): boolean;
    function FindClassInfo(const vm: HVM; const TypeName: AnsiString): ISciterClassInfo;
    function GetClassInfoList(const vm: HVM): ISciterClassInfoList;
    function GetCount: Integer;
    function GetItem(Index: Integer): IVMClassBag;
    function ToString: String;
    property Count: Integer read GetCount;
    property Item[Index: Integer]: IVMClassBag read GetItem; default;
  end;

  TVMClassBagList = class(TInterfacedObject, IVMClassBagList)
  private
    FList: TInterfaceList;
    function GetCount: Integer;
    function GetItem(Index: Integer): IVMClassBag;
  protected
    function Exists(const vm: HVM): boolean;
    function GetClassInfoList(const vm: HVM): ISciterClassInfoList;
    property Item[Index: Integer]: IVMClassBag read GetItem; default;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const Item: IVMClassBag);
    function ClassInfoExists(const vm: HVM; const TypeName: AnsiString): boolean; virtual;
    function FindClassInfo(const vm: HVM; const TypeName: AnsiString): ISciterClassInfo; virtual;
    function ToString: String; {$IFDEF UNICODE} override; {$ENDIF}
    property Count: Integer read GetCount;
  end;

  ISciterClassBag = interface(IVMClassBagList)
    function ClassInfoExists(const vm: HVM; const TypeName: AnsiString): boolean;
    function CreateInstance(const TypeName: AnsiString): tiscript_object;
    function FindClassInfo(const vm: HVM; const TypeName: AnsiString): ISciterClassInfo;
    function RegisterClassInfo(vm: HVM; const ClsInfo: ISciterClassInfo): tiscript_class;
    function ResolveClass(vm: HVM; TypeName: WideString): tiscript_class;
  end;

  // TypeName is an input.
  TSciterClassBag = class(TVMClassBagList, ISciterClassBag)
  public
    function ClassInfoExists(const vm: HVM; const TypeName: AnsiString): boolean; override;
    function CreateInstance(const TypeName: AnsiString): tiscript_object;
    function FindClassInfo(const vm: HVM; const TypeName: AnsiString): ISciterClassInfo; override;
    function RegisterClassInfo(vm: HVM; const ClsInfo: ISciterClassInfo): tiscript_class;
    function ResolveClass(vm: HVM; TypeName: WideString): tiscript_class;
  end;

  function CreateSciterClassInfo(const TypeName: WideString): ISciterClassInfo;

var
  ClassBag: ISciterClassBag;
  
implementation

uses Math;

function CreateSciterClassInfo(const TypeName: WideString): ISciterClassInfo;
var
  pResult: ISciterClassInfo;
begin
  pResult := TSciterClassInfo.Create;
  pResult.TypeName := AnsiString(TypeName);
  Result := pResult;
end;

constructor TSciterClassInfo.Create;
begin
  FSciterClassDef := nil;
  FAllMethods := TSciterMethodList.Create;
  FProps := TSciterMethodList.Create;
  FMethods := TSciterMethodList.Create;
end;

destructor TSciterClassInfo.Destroy;
begin
  OutputDebugStringA(PAnsiChar('SciterClassInfo ' + FTypeName + ' is being destroyed.'));
  FProps := nil;
  FMethods := nil;
  FAllMethods := nil;
  if FSciterClassDef <> nil then
    Dispose(FSciterClassDef);
  inherited;
end;

procedure TSciterClassInfo.FreeClassDef;
var
  pMethods: ptiscript_method_def;
  pProps: ptiscript_prop_def;
  i: Integer;
begin
  StrDispose(FSciterClassDef.name);
  FSciterClassDef.consts := nil;
  FSciterClassDef.get_item := nil;
  FSciterClassDef.set_item := nil;
  FSciterClassDef.finalizer := nil;
  FSciterClassDef.iterator := nil;
  FSciterClassDef.on_gc_copy := nil;
  FSciterClassDef.prototype := 0;

  // Dispose methods
  pMethods := FSciterClassDef.methods;
  for i := 0 to FSciterClassDef.methodsc - 1 do
  begin
    StrDispose(pMethods.name);
    Inc(pMethods);
  end;
  CoTaskMemFree(FSciterClassDef.methods);

  // Dispose properties
  pProps := FSciterClassDef.props;
  for i := 0 to FSciterClassDef.propsc - 1 do
  begin
    StrDispose(pProps.name);
    Inc(pProps);
  end;
  CoTaskMemFree(FSciterClassDef.props);
end;

procedure TSciterClassInfo.BuildClassDef;
var
  i: Integer;
  pInfo: ISciterMethodInfo;
  pclass_methods: ptiscript_method_def;
  pMethods: ISciterMethodInfoList;
  pProps: ISciterMethodInfoList;
  smethod_name: AnsiString;
  sprop_name: AnsiString;
  szMethods: Integer;
  szProps: Integer;
  pclass_props: ptiscript_prop_def;
begin
  New(FSciterClassDef);
  FSciterClassDef.methods    := nil;
  FSciterClassDef.props      := nil;
  FSciterClassDef.consts     := nil; // Not implemented
  FSciterClassDef.get_item   := FGetItemHandler;
  FSciterClassDef.set_item   := FSetItemHandler;
  FSciterClassDef.finalizer  := FFinalizerHandler;
  FSciterClassDef.iterator   := FIteratorHandler;
  FSciterClassDef.on_gc_copy := FGCCopyHandler;
  FSciterClassDef.prototype  := 0;   // Not implemented
  FSciterClassDef.name       := StrNew(PAnsiChar(Self.FTypeName));

  // Methods
  pMethods := Self.SelectMethods;
  FSciterClassDef.methodsc := pMethods.Count + 1;
  szMethods := SizeOf(tiscript_method_def) * FSciterClassDef.methodsc; // 1 - "null-terminating record"
  pclass_methods := CoTaskMemAlloc(szMethods);
  FSciterClassDef.methods := pclass_methods;

  for i := 0 to pMethods.Count - 1 do
  begin
    pInfo := pMethods[i];
    smethod_name := AnsiString(pInfo.Name);
    pclass_methods.name := StrNew(PAnsiChar(smethod_name));
    pclass_methods.handler := @FMethodHandler;
    pclass_methods.dispatch := nil;
    pclass_methods.tag := Pointer(pInfo);
    Inc(pclass_methods);
  end;
  // null-terminating record
  pclass_methods.dispatch := nil;
  pclass_methods.name := nil;
  pclass_methods.handler := nil;
  pclass_methods.tag := nil;

  // Properties
  pProps := Self.SelectProperties;
  FSciterClassDef.propsc := pProps.Count + 1;
  szProps := SizeOf(tiscript_prop_def) * FSciterClassDef.propsc; // 1 - "null-terminating record"
  pclass_props := CoTaskMemAlloc(szProps);
  FSciterClassDef.props := pclass_props;
  for i := 0 to pProps.Count - 1 do
  begin
    pInfo := pProps[i];
    sprop_name := AnsiString(pInfo.Name);
    pclass_props.dispatch := nil;
    pclass_props.name := StrNew(PAnsiChar(sprop_name));

    // non-indexed property getter
    if (pInfo.HasGetter) and (pInfo.GetArgsCount = 0) then
      pclass_props.getter := @FGetterHandler
    else
      pclass_props.getter := nil;

    // non-indexed property setter
    if (pInfo.HasSetter) and (pInfo.SetArgsCount = 1) then
      pclass_props.setter := @FSetterHandler
    else
      pclass_props.setter := nil;

    pclass_props.tag := Pointer(pInfo);

    Inc(pclass_props);
  end;
  // null-terminating record
  pclass_props.dispatch := nil;
  pclass_props.name := nil;
  pclass_props.getter := nil;
  pclass_props.setter := nil;
  pclass_props.tag := nil;
end;

function TSciterClassInfo.GetFinalizerHandler: tiscript_finalizer;
begin
  Result := FFinalizerHandler;
end;

function TSciterClassInfo.GetGCCopyHandler: tiscript_on_gc_copy;
begin
  Result := FGCCopyHandler;
end;

function TSciterClassInfo.GetGetItemHandler: tiscript_get_item;
begin
  Result := FGetItemHandler;
end;

function TSciterClassInfo.GetGetterHandler: tiscript_tagged_get_prop;
begin
  Result := FGetterHandler;
end;

function TSciterClassInfo.GetIteratorHandler: tiscript_iterator;
begin
  Result := FIteratorHandler;
end;

function TSciterClassInfo.GetMethodHandler: tiscript_tagged_method;
begin
  Result := FMethodHandler;
end;

function TSciterClassInfo.GetMethods: ISciterMethodInfoList;
begin
  Result := FAllMethods;
end;

function TSciterClassInfo.GetSciterClassDef: ptiscript_class_def;
begin
  if FSciterClassDef = nil then
    Self.BuildClassDef;
  Result := FSciterClassDef;
end;

function TSciterClassInfo.GetSetItemHandler: tiscript_set_item;
begin
  Result := SetItemHandler;
end;

function TSciterClassInfo.GetSetterHandler: tiscript_tagged_set_prop;
begin
  Result := FSetterHandler;
end;

function TSciterClassInfo.GetTypeName: WideString;
begin
  Result := WideString(FTypeName);
end;

function TSciterClassInfo.SelectMethods: ISciterMethodInfoList;
var
  i: Integer;
  pItem: ISciterMethodInfo;
begin
  FMethods.Clear;
  for i := 0 to FAllMethods.Count - 1 do
  begin
    pItem := FAllMethods[i];
    if pItem.CallType = Method then
      FMethods.Add(pItem);
  end;
  Result := FMethods;
end;

function TSciterClassInfo.SelectProperties: ISciterMethodInfoList;
var
  i: Integer;
  pItem: ISciterMethodInfo;
begin
  FProps.Clear;
  for i := 0 to FAllMethods.Count - 1 do
  begin
    pItem := FAllMethods[i];
    if pItem.CallType = NonIndexedProperty then
      FProps.Add(pItem);
  end;
  Result := FProps;
end;

procedure TSciterClassInfo.SetFinalizerHandler(
  const Value: tiscript_finalizer);
begin
  FFinalizerHandler := Value;
end;

procedure TSciterClassInfo.SetGCCopyHandler(
  const Value: tiscript_on_gc_copy);
begin
  FGCCopyHandler := Value;
end;

procedure TSciterClassInfo.SetGetItemHandler(
  const Value: tiscript_get_item);
begin
  FGetItemHandler := Value;
end;

procedure TSciterClassInfo.SetGetterHandler(
  const Value: tiscript_tagged_get_prop);
begin
  FGetterHandler := Value;
end;

procedure TSciterClassInfo.SetIteratorHandler(
  const Value: tiscript_iterator);
begin
  FIteratorHandler := Value;
end;

procedure TSciterClassInfo.SetMethodHandler(
  const Value: tiscript_tagged_method);
begin
  FMethodHandler := Value;
end;

procedure TSciterClassInfo.SetSetItemHandler(
  const Value: tiscript_set_item);
begin
  FSetItemHandler := Value;
end;

procedure TSciterClassInfo.SetSetterHandler(
  const Value: tiscript_tagged_set_prop);
begin
  FSetterHandler := Value;
end;

procedure TSciterClassInfo.SetTypeName(const Value: WideString);
begin
  FTypeName := AnsiString(Value);
end;

function TSciterClassInfo.ToString: String;
var
  i: Integer;
begin
  Result := 'class: ' + String(Self.TypeName) + #13#10;
  for i := 0 to Self.FAllMethods.Count - 1 do
    Result := Result + Self.FAllMethods[i].ToString + #13#10;
end;

constructor TSciterMethodList.Create;
begin
  FList := TInterfaceList.Create;
end;

destructor TSciterMethodList.Destroy;
begin
  FList.Free;
  inherited;
end;

{ TSciterMethodList }

procedure TSciterMethodList.Add(const Item: ISciterMethodInfo);
begin
  if not Exists(Item.Name) then
    FList.Add(Item)
  else
    raise ESciterException.CreateFmt('Method "%s" was already added.', []);
end;

procedure TSciterMethodList.Clear;
begin
  FList.Clear;
end;

function TSciterMethodList.Exists(const MethodName: AnsiString): boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to Count - 1 do
  begin
    if Item[i].Name = MethodName then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TSciterMethodList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TSciterMethodList.GetItem(
  Index: Integer): ISciterMethodInfo;
begin
  Result := FList[Index] as ISciterMethodInfo;
end;

function TSciterMethodList.LookupMethod(
  const MethodName: AnsiString): ISciterMethodInfo;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if Item[i].Name = MethodName then
    begin
      Result := Item[i];
      Exit;
    end;
  end;
  Result := TSciterMethodInfo.Create;
  Result.Name := MethodName;
  Add(Result);
end;

constructor TSciterClassInfoList.Create;
begin
  FList := TInterfaceList.Create;
end;

destructor TSciterClassInfoList.Destroy;
begin
  FList.Free;
  inherited;
end;

{ TSciterClassInfoList }

procedure TSciterClassInfoList.Add(const ClsInfo: ISciterClassInfo);
begin
  if not Exists(ClsInfo.TypeName) then
    FList.Add(ClsInfo)
  else
    raise ESciterException.CreateFmt('Class "%s" was already added.', [ClsInfo.TypeName]);
end;

function TSciterClassInfoList.Exists(const TypeName: AnsiString): boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to Count - 1 do
  begin
    if Item[i].TypeName = TypeName then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TSciterClassInfoList.FindClassInfo(
  const TypeName: AnsiString): ISciterClassInfo;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if Item[i].TypeName = TypeName then
    begin
      Result := Item[i];
      Exit;
    end;
  end;
end;

function TSciterClassInfoList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TSciterClassInfoList.GetItem(Index: Integer): ISciterClassInfo;
begin
  Result := FList[Index] as ISciterClassInfo;
end;

function TSciterClassInfoList.ToString: String;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Result := Result + Item[i].ToString + #13#10;
end;

{ TSciterClassBag }

function TSciterClassBag.ClassInfoExists(const vm: HVM;
  const TypeName: AnsiString): boolean;
begin
  Result := Inherited ClassInfoExists(vm, TypeName);
end;

function TSciterClassBag.CreateInstance(
  const TypeName: AnsiString): tiscript_object;
begin
  Result := NI.undefined_value;
end;

function TSciterClassBag.FindClassInfo(const vm: HVM;
  const TypeName: AnsiString): ISciterClassInfo;
begin
  Result := Inherited FindClassInfo(vm, TypeName);
end;

function TSciterClassBag.RegisterClassInfo(
  vm: HVM; const ClsInfo: ISciterClassInfo): tiscript_class;
var
  pVMClassBag: IVMClassBag;
  pClassList: ISciterClassInfoList;
begin
  if not Exists(vm) then
  begin
    pVMClassBag := TVMClassBag.Create(vm);
    Add(pVMClassBag);
  end;

  pClassList := Self.GetClassInfoList(vm);
  if not pClassList.Exists(ClsInfo.TypeName) then
  begin
    pClassList.Add(ClsInfo);
    SciterApi.RegisterNativeClass(vm, ClsInfo.SciterClassDef, False, False);
  end;

  Result := SciterApi.GetNativeClass(vm, WideString(ClsInfo.TypeName));
end;

function TSciterClassBag.ResolveClass(vm: HVM;
  TypeName: WideString): tiscript_class;
begin
 if not Self.ClassInfoExists(vm, AnsiString(TypeName)) then
 begin
   raise ESciterException.CreateFmt('Cannot resolve class "%s": class not registered.', [TypeName]);
 end
   else
 begin
   Result := SciterApi.GetNativeClass(vm, TypeName);
 end;
end;

{ TVMClassInfoDictionary }

constructor TVMClassBag.Create(vm: HVM);
begin
  FVM := vm;
  FList := TSciterClassInfoList.Create;
end;

destructor TVMClassBag.Destroy;
begin
  OutputDebugStringA(PAnsiChar(AnsiString('VMClassBag ' + IntToStr(Integer(FVM)) + ' is being destroyed.')));
  FVM := nil;
  FList := nil;
  inherited;
end;

function TVMClassBag.GetClassInfoList: ISciterClassInfoList;
begin
  Result := FList;
end;

function TVMClassBag.GetVM: HVM;
begin
  Result := FVM;
end;

function TVMClassBag.ToString: String;
begin
  Result := 'VM: ' + IntToStr(Integer(FVM)) + #13#10;
  Result := Result + ClassInfoList.ToString;
end;

constructor TVMClassBagList.Create;
begin
  FList := TInterfaceList.Create;
end;

destructor TVMClassBagList.Destroy;
begin
  FList.Free;
  inherited;
end;

{ TVMClassBagList }

procedure TVMClassBagList.Add(const Item: IVMClassBag);
begin
  if Exists(Item.VM) then
    raise ESciterException.CreateFmt('VM handle %d was already added.', [Integer(Item.VM)]);
  FList.Add(Item);
end;

function TVMClassBagList.ClassInfoExists(const vm: HVM;
  const TypeName: AnsiString): boolean;
var
  pList: ISciterClassInfoList;
begin
  if not Exists(vm) then
  begin
    Result := False;
  end
    else
  begin
    pList := Self.GetClassInfoList(vm);
    if pList = nil then
    begin
      Result := False;
      Exit;
    end;
    Result := pList.Exists(TypeName);
  end;
end;

function TVMClassBagList.Exists(const vm: HVM): boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to Count - 1 do
  begin
    if Item[i].VM = vm then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TVMClassBagList.FindClassInfo(const vm: HVM;
  const TypeName: AnsiString): ISciterClassInfo;
var
  pClassList: ISciterClassInfoList;
begin
  pClassList := GetClassInfoList(vm);
  if pClassList = nil then
  begin
    Result := nil;
    Exit;
  end;
  Result := pClassList.FindClassInfo(TypeName);
end;

function TVMClassBagList.GetClassInfoList(const vm: HVM): ISciterClassInfoList;
var
  i: Integer;
  pVMClassBag: IVMClassBag;
  pList: ISciterClassInfoList;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    pVMClassBag := Item[i];
    if pVMClassBag.VM = vm then
    begin
      pList := pVMClassBag.ClassInfoList;
      Result := pList;
      Exit;
    end;
  end;
end;

function TVMClassBagList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TVMClassBagList.GetItem(Index: Integer): IVMClassBag;
begin
  Result := FList[Index] as IVMClassBag;
end;

function TVMClassBagList.ToString: String;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Result := Result + Item[i].ToString + #13#10;
end;

{ TSciterMethodInfo }

destructor TSciterMethodInfo.Destroy;
begin
  OutputDebugStringA(PAnsiChar('  SciterMethodInfo ' + FName + ' is being destroyed.'));
  inherited;
end;

function TSciterMethodInfo.GetCallArgsCount: Integer;
begin
  Result := FCallArgsCount;
end;

function TSciterMethodInfo.GetCallType: TMethodType;
begin
  Result := FCallType;
end;

function TSciterMethodInfo.GetGetArgsCount: Integer;
begin
  Result := FGetArgsCount;
end;

function TSciterMethodInfo.GetHasGetter: Boolean;
begin
  Result := FHasGetter;
end;

function TSciterMethodInfo.GetHasSetter: Boolean;
begin
  Result := FHasSetter;
end;

function TSciterMethodInfo.GetName: WideString;
begin
  Result := WideString(FName);
end;

function TSciterMethodInfo.GetSetArgsCount: Integer;
begin
  Result := FSetArgsCount;
end;

procedure TSciterMethodInfo.SetCallArgsCount(const Value: Integer);
begin
  FCallArgsCount := Value;
end;

procedure TSciterMethodInfo.SetCallType(const Value: TMethodType);
begin
  FCallType := Value;
end;

procedure TSciterMethodInfo.SetGetArgsCount(const Value: Integer);
begin
  FGetArgsCount := Value;
end;

procedure TSciterMethodInfo.SetHasGetter(const Value: Boolean);
begin
  FHasGetter := Value;
end;

procedure TSciterMethodInfo.SetHasSetter(const Value: Boolean);
begin
  FHasSetter := Value;
end;

procedure TSciterMethodInfo.SetName(const Value: WideString);
begin
  FName := AnsiString(Value);
end;

procedure TSciterMethodInfo.SetSetArgsCount(const Value: Integer);
begin
  FSetArgsCount := Value;
end;

function TSciterMethodInfo.ToString: String;
begin
  Result := String(Self.Name);
  case CallType of
    Method: Result := Result + ' (method)';
    NonIndexedProperty: Result := Result + ' (non-indexed property)';
    IndexedProperty: Result := Result + ' (indexed property)';
  end;
end;

initialization
  ClassBag := TSciterClassBag.Create;

finalization
  ClassBag := nil;

end.
