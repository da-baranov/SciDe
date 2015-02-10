unit SciterNativeProxy;

interface

uses
  Windows, Messages, Classes, Variants, Contnrs, SciterApi, TiScriptApi, SysUtils;

type
  TMethodType = (Method, NonIndexedProperty, IndexedProperty);

  TSciterMethodList = class;
  TSciterMethodInfo = class;

  TSciterClassInfo = class
  private
    FAllMethods: TSciterMethodList;
    FFinalizerHandler: tiscript_finalizer;
    FGCCopyHandler: tiscript_on_gc_copy;
    FGetItemHandler: tiscript_get_item;
    FMethods: TSciterMethodList;
    FObj: Pointer;
    FProps: TSciterMethodList;
    FSetItemHandler: tiscript_set_item;
    FTypeName: AnsiString;
    FGetterHandler: tiscript_tagged_get_prop;
    FMethodHandler: tiscript_tagged_method;
    FSetterHandler: tiscript_tagged_set_prop;
    function SelectMethods: TSciterMethodList;
    function SelectProperties: TSciterMethodList;
    procedure SetFinalizerHandler(const Value: tiscript_finalizer);
    procedure SetGCCopyHandler(const Value: tiscript_on_gc_copy);
    procedure SetGetItemHandler(const Value: tiscript_get_item);
    procedure SetSetItemHandler(const Value: tiscript_set_item);
    procedure SetGetterHandler(const Value: tiscript_tagged_get_prop);
    procedure SetMethodHandler(const Value: tiscript_tagged_method);
    procedure SetSetterHandler(const Value: tiscript_tagged_set_prop);
  protected
    procedure PopulateMethods(const List: TSciterMethodList); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Build(Obj: Pointer);
    class procedure FreeClassDef(var ClassDef: tiscript_class_def);
    procedure GetClassDef(var ClassDef: tiscript_class_def);
    property FinalizerHandler: tiscript_finalizer read FFinalizerHandler write SetFinalizerHandler;
    property GCCopyHandler: tiscript_on_gc_copy read FGCCopyHandler write SetGCCopyHandler;
    property GetItemHandler: tiscript_get_item read FGetItemHandler write SetGetItemHandler;
    property GetterHandler: tiscript_tagged_get_prop read FGetterHandler write SetGetterHandler;
    property SetterHandler: tiscript_tagged_set_prop read FSetterHandler write SetSetterHandler;
    property MethodHandler: tiscript_tagged_method read FMethodHandler write SetMethodHandler;
    property Obj: Pointer read FObj;
    property SetItemHandler: tiscript_set_item read FSetItemHandler write SetSetItemHandler;
    property TypeName: AnsiString read FTypeName write FTypeName;
  end;

  TSciterMethodInfo = class
  private
    FCallArgsCount: Integer;
    FCallType: TMethodType;
    FGetArgsCount: Integer;
    FHasGetter: Boolean;
    FHasSetter: Boolean;
    FName: AnsiString;
    FSetArgsCount: Integer;
  public
    property CallArgsCount: Integer read FCallArgsCount write FCallArgsCount;
    property CallType: TMethodType read FCallType write FCallType;
    property GetArgsCount: Integer read FGetArgsCount write FGetArgsCount;
    property HasGetter: Boolean read FHasGetter write FHasGetter;
    property HasSetter: Boolean read FHasSetter write FHasSetter;
    property Name: AnsiString read FName write FName;
    property SetArgsCount: Integer read FSetArgsCount write FSetArgsCount;
  end;

  TSciterMethodList = class(TObjectList)
  private
    function GetSciterMethodInfo(const Index: Integer): TSciterMethodInfo;
  protected
    procedure Add(const Item: TSciterMethodInfo);
    property Item[const Index: Integer]: TSciterMethodInfo read GetSciterMethodInfo; default;
  public
    function LookupMethod(const MethodName: AnsiString): TSciterMethodInfo;
  end;

implementation

constructor TSciterClassInfo.Create;
begin
  FAllMethods := TSciterMethodList.Create(True);
  FProps := TSciterMethodList.Create(False);
  FMethods := TSciterMethodList.Create(False);
end;

destructor TSciterClassInfo.Destroy;
begin
  FProps.Free;
  FMethods.Free;
  FAllMethods.Free;
  inherited;
end;

procedure TSciterClassInfo.Build(Obj: Pointer);
begin
  if FObj <> Obj then
  begin
    FProps.Clear;
    FMethods.Clear;
    FAllMethods.Clear;

    PopulateMethods(FAllMethods);
  end;
end;

class procedure TSciterClassInfo.FreeClassDef(var ClassDef: tiscript_class_def);
begin
  // TODO:
end;

procedure TSciterClassInfo.GetClassDef(var ClassDef: tiscript_class_def);
var
  i: Integer;
  pInfo: TSciterMethodInfo;
  pclass_methods: ptiscript_method_def;
  pMethods: TSciterMethodList;
  pProps: TSciterMethodList;
  smethod_name: AnsiString;
  sprop_name: AnsiString;
  szMethods: Integer;
  szProps: Integer;
  pclass_props: ptiscript_prop_def;
begin
  for i := 0 to FAllMethods.Count - 1 do
  begin
    OutputDebugString(PChar(Format('%s of type %d', [FAllMethods[i].Name, Integer(FAllMethods[i].CallType)])));
  end;
  ClassDef.methods   := nil;
  ClassDef.props     := nil;
  ClassDef.consts    := nil; // Not implemented yet
  ClassDef.get_item  := FGetItemHandler;
  ClassDef.set_item  := FSetItemHandler;
  ClassDef.finalizer := FFinalizerHandler;
  ClassDef.iterator  := nil; // Not implemented
  ClassDef.on_gc_copy := FGCCopyHandler;
  ClassDef.prototype := 0;   // Not implemented
  ClassDef.name := StrNew(PChar(Self.TypeName));

  // Methods
  pMethods := Self.SelectMethods;
  szMethods := SizeOf(tiscript_method_def) * (pMethods.Count + 1); // 1 - "null-terminating record"
  GetMem(pclass_methods, szMethods);
  ClassDef.methods := pclass_methods;

  for i := 0 to pMethods.Count - 1 do
  begin
    pInfo := pMethods[i];
    smethod_name := pInfo.Name;
    pclass_methods.name := StrNew(PAnsiChar(smethod_name));
    pclass_methods.handler := @FMethodHandler;
    pclass_methods.dispatch := nil;
    pclass_methods.tag := pInfo;
    Inc(pclass_methods);
  end;
  // null-terminating record
  pclass_methods.dispatch := nil;
  pclass_methods.name := nil;
  pclass_methods.handler := nil;
  pclass_methods.tag := nil;

  // Properties
  pProps := Self.SelectProperties;
  szProps := SizeOf(tiscript_prop_def) * (pProps.Count + 1); // 1 - "null-terminating record"
  GetMem(pclass_props, szProps);
  ClassDef.props := pclass_props;
  for i := 0 to pProps.Count - 1 do
  begin
    pInfo := pProps[i];
    sprop_name := pInfo.Name;
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

    pclass_props.tag := pInfo;

    Inc(pclass_props);
  end;
  // null-terminating record
  pclass_props.dispatch := nil;
  pclass_props.name := nil;
  pclass_props.getter := nil;
  pclass_props.setter := nil;
  pclass_props.tag := nil;
end;

procedure TSciterClassInfo.PopulateMethods(const List: TSciterMethodList);
begin

end;

function TSciterClassInfo.SelectMethods: TSciterMethodList;
var
  i: Integer;
begin
  FMethods.Clear;
  for i := 0 to FAllMethods.Count - 1 do
  begin
    if FAllMethods.Item[i].CallType = Method then
      FMethods.Add(FAllMethods.Item[i]);
  end;
  Result := FMethods;
end;

function TSciterClassInfo.SelectProperties: TSciterMethodList;
var
  i: Integer;
begin
  FProps.Clear;
  for i := 0 to FAllMethods.Count - 1 do
  begin
    if FAllMethods.Item[i].CallType = NonIndexedProperty then
      FProps.Add(FAllMethods.Item[i]);
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

procedure TSciterClassInfo.SetSetItemHandler(
  const Value: tiscript_set_item);
begin
  FSetItemHandler := Value;
end;

{ TSciterMethodList }

procedure TSciterMethodList.Add(const Item: TSciterMethodInfo);
begin
  inherited Add(Item);
end;

function TSciterMethodList.GetSciterMethodInfo(
  const Index: Integer): TSciterMethodInfo;
begin
  Result := inherited GetItem(Index) as TSciterMethodInfo;
end;

function TSciterMethodList.LookupMethod(
  const MethodName: AnsiString): TSciterMethodInfo;
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

procedure TSciterClassInfo.SetGetterHandler(
  const Value: tiscript_tagged_get_prop);
begin
  FGetterHandler := Value;
end;

procedure TSciterClassInfo.SetMethodHandler(
  const Value: tiscript_tagged_method);
begin
  FMethodHandler := Value;
end;

procedure TSciterClassInfo.SetSetterHandler(
  const Value: tiscript_tagged_set_prop);
begin
  FSetterHandler := Value;
end;

end.
