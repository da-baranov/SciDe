unit Sciter;

interface

uses
  Windows, Forms, Dialogs, Messages, ComObj, ActiveX, Controls, Classes, SysUtils, SciterApi, TiScriptApi,
  Contnrs, Variants, Math, Graphics;

type

  TSciter = class;
  TElementCollection = class;
  TElement = class;

  IElement = interface;
  IElementCollection = interface;
  
    // Element events
  TElementOnMouse = procedure(ASender: TObject; const target: IElement; eventType: Integer;
                                                x: Integer; y: Integer; buttons: Integer;
                                                keys: Integer) of object;
  TElementOnKey = procedure(ASender: TObject; const target: IElement; eventType: Integer;
                                              code: Integer; keys: Integer) of object;
  TElementOnFocus = procedure(ASender: TObject; const target: IElement; eventType: Integer) of object;
  TElementOnTimer = procedure(ASender: TObject; timerId: Integer) of object;
  TElementOnControlEvent = procedure(ASender: TObject; const target: IElement; eventType: Integer;
                                                       reason: Integer; const source: IElement) of object;
  TElementOnScroll = procedure(ASender: TObject; const target: IElement; eventType: Integer;
                                                 pos: Integer; isVertical: WordBool) of object;
  TElementOnChange = procedure(ASender: TObject; const source: IElement) of object;

  // Sciter events
  TSciterOnStdOut = procedure(ASender: TObject; const msg: WideString) of object;
  TSciterOnStdErr = procedure(ASender: TObject; const msg: WideString) of object;
  TSciterOnLoadData = procedure(ASender: TObject; const url: WideString; resType: Integer;
                                                  requestId: Integer; out discard: WordBool) of object;
  TSciterOnDataLoaded = procedure(ASender: TObject; const url: WideString; resType: Integer;
                                                    var data: Byte; dataLength: Integer;
                                                    requestId: Integer) of object;



  IElement = interface
    ['{E2C542D1-5B7B-4513-BFBC-7B0DD9FB04DE}']
    procedure AppendChild(const Element: IElement);
    function CreateElement(const Tag: WideString; const Text: WideString): IElement;
    procedure Delete;
    function Equals(const Element: IElement): WordBool;
    function GetChild(Index: Integer): IElement;
    function Get_Attr(const AttrName: WideString): WideString;
    function Get_ChildrenCount: Integer;
    function Get_Handle: Integer;
    function Get_Index: Integer;
    function Get_InnerHtml: WideString;
    function Get_OnControlEvent: TElementOnControlEvent;
    function Get_OnMouse: TElementOnMouse;
    function Get_OuterHtml: WideString;
    function Get_Parent: IElement;
    function Get_StyleAttr(const AttrName: WideString): WideString;
    function Get_Tag: WideString;
    function Get_Text: WideString;
    function Get_Value: OleVariant;
    procedure InsertElement(const Child: IElement; Index: Integer);
    procedure PostEvent(EventCode: Integer);
    procedure ScrollToView; stdcall;
    function Select(const Selector: WideString): TElement;
    function SelectAll(const Selector: WideString): IElementCollection;
    procedure SendEvent(EventCode: Integer);
    procedure Set_Attr(const AttrName: WideString; const Value: WideString);
    procedure Set_InnerHtml(const Value: WideString);
    procedure Set_OnControlEvent(const Value: TElementOnControlEvent);
    procedure Set_OnMouse(const Value: TElementOnMouse);
    procedure Set_OuterHtml(const Value: WideString);
    procedure Set_StyleAttr(const AttrName: WideString; const Value: WideString);
    procedure Set_Text(const Value: WideString);
    procedure Set_Value(Value: OleVariant);
    property Attr[const AttrName: WideString]: WideString read Get_Attr write Set_Attr;
    property ChildrenCount: Integer read Get_ChildrenCount;
    property Handle: Integer read Get_Handle;
    property Index: Integer read Get_Index;
    property InnerHtml: WideString read Get_InnerHtml write Set_InnerHtml;
    property OuterHtml: WideString read Get_OuterHtml write Set_OuterHtml;
    property Parent: IElement read Get_Parent;
    property StyleAttr[const AttrName: WideString]: WideString read Get_StyleAttr write Set_StyleAttr;
    property Tag: WideString read Get_Tag;
    property Text: WideString read Get_Text write Set_Text;
    property Value: OleVariant read Get_Value write Set_Value;
    property OnControlEvent: TElementOnControlEvent read Get_OnControlEvent write Set_OnControlEvent;
    property OnMouse: TElementOnMouse read Get_OnMouse write Set_OnMouse;
  end;

  IElementCollection = interface
    ['{2E262CE3-43DE-4266-9424-EBA0241F77F8}']
    function Get_Count: Integer;
    function Get_Item(const Index: Integer): TElement;
    procedure RemoveAll;
    property Count: Integer read Get_Count;
    property Item[const Index: Integer]: TElement read Get_Item; default;
  end;

  ISciter = interface
  ['{76F8DE2D-14F0-409B-8478-F9E43A73BC3F}']
    function Call(const FunctionName: WideString; const Args: array of OleVariant): OleVariant;
    function Eval(const Script: WideString): OleVariant;
    function Get_Html: WideString;
    function Get_Root: TElement;
    procedure LoadHtml(const Html: WideString; const BaseURL: WideString);
    procedure LoadURL(const URL: Widestring);
    procedure RegisterComObject(const Name: WideString; const Obj: IDispatch);
    property Html: WideString read Get_Html;
    property Root: TElement read Get_Root;
  end;

  TElement = class(TInterfacedObject, IElement)
  private
    FAttached: Boolean;
    FAttrName: WideString;
    FAttrValue: WideString;
    FELEMENT: HELEMENT;
    FHtml: WideString;
    FOnControlEvent: TElementOnControlEvent;
    FOnFocus: TElementOnFocus;
    FOnKey: TElementOnKey;
    FOnMouse: TElementOnMouse;
    FOnTimer: TElementOnTimer;
    FStyleAttrName: WideString;
    FStyleAttrValue: WideString;
    FTag: WideString;
    FText: WideString;
    function Get_Attr(const AttrName: WideString): WideString;
    function Get_ChildrenCount: Integer;
    function Get_Handle: Integer;
    function Get_Index: Integer;
    function Get_InnerHtml: WideString;
    function Get_OnControlEvent: TElementOnControlEvent;
    function Get_OnMouse: TElementOnMouse;
    function Get_OuterHtml: WideString;
    function Get_Parent: IElement;
    function Get_StyleAttr(const AttrName: WideString): WideString;
    function Get_Tag: WideString;
    function Get_Text: WideString;
    function Get_Value: OleVariant;
    procedure Set_InnerHtml(const Value: WideString);
    procedure Set_OnControlEvent(const Value: TElementOnControlEvent);
    procedure Set_OnMouse(const Value: TElementOnMouse);
    procedure Set_OuterHtml(const Value: WideString);
    procedure Set_Text(const Value: WideString);
    procedure Set_Value(Value: OleVariant);
  protected
    constructor Create(h: HELEMENT);
  public
    destructor Destroy; override;
    procedure AppendChild(const Element: IElement);
    function CreateElement(const Tag: WideString; const Text: WideString): IElement;
    procedure Delete;
    function Equals(const Element: IElement): WordBool;
    function GetChild(Index: Integer): IElement;
    procedure InsertElement(const Child: IElement; Index: Integer);
    procedure PostEvent(EventCode: Integer);
    procedure ScrollToView; stdcall;
    function Select(const Selector: WideString): TElement;
    function SelectAll(const Selector: WideString): IElementCollection;
    procedure SendEvent(EventCode: Integer);
    procedure Set_Attr(const AttrName: WideString; const Value: WideString);
    procedure Set_StyleAttr(const AttrName: WideString; const Value: WideString);
    property Attr[const AttrName: WideString]: WideString read Get_Attr write Set_Attr;
    property ChildrenCount: Integer read Get_ChildrenCount;
    property Handle: Integer read Get_Handle;
    property InnerHtml: WideString read Get_InnerHtml write Set_InnerHtml;
    property OuterHtml: WideString read Get_OuterHtml write Set_OuterHtml;
    property StyleAttr[const AttrName: WideString]: WideString read Get_StyleAttr write Set_StyleAttr;
    property Tag: WideString read Get_Tag;
    property Text: WideString read Get_Text write Set_Text;
    property Value: OleVariant read Get_Value write Set_Value;
    property OnControlEvent: TElementOnControlEvent read Get_OnControlEvent write Set_OnControlEvent;
    property OnMouse: TElementOnMouse read Get_OnMouse write Set_OnMouse;
  end;

  TElementCollection = class(TInterfacedObject, IElementCollection)
  private
    FList: TObjectList;
  protected
    function Get_Count: Integer;
    function Get_Item(const Index: Integer): TElement;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const Item: TElement);
    procedure RemoveAll;
    property Count: Integer read Get_Count;
    property Item[const Index: Integer]: TElement read Get_Item;
  end;

  TSciter = class(TCustomControl, ISciter)
  private
    FBaseUrl: WideString;
    FHtml: WideString;
    FOnStdErr: TSciterOnStdErr;
    FOnStdOut: TSciterOnStdOut;
    FOnStdWarn: TSciterOnStdOut;
    FUrl: WideString;
    function GetHVM: HVM;
    function Get_Html: WideString;
    function Get_Root: TElement;
    procedure SetOnStdErr(const Value: TSciterOnStdErr);
    procedure SetOnStdOut(const Value: TSciterOnStdOut);
    procedure SetOnStdWarn(const Value: TSciterOnStdOut);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure SetParent(AParent: TWinControl); override;
    procedure WndProc(var Message: TMessage); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure MouseWheelHandler(var Message: TMessage); override;
    function Call(const FunctionName: WideString; const Args: array of OleVariant): OleVariant;
    function Eval(const Script: WideString): OleVariant;
    function FindElement(Point: TPoint): IElement;
    function GetElementByHandle(Handle: Integer): IElement;
    function GetMinHeight(Width: Integer): Integer;
    function GetMinWidth: Integer;
    procedure LoadHtml(const Html: WideString; const BaseURL: WideString);
    procedure LoadURL(const URL: Widestring);
    procedure RegisterComObject(const Name: WideString; const Obj: IDispatch);
    function Select(const Selector: WideString): TElement;
    function SelectAll(const Selector: WideString): IElementCollection;
    procedure Test;
    procedure UpdateWindow;
    property Html: WideString read Get_Html;
    property HVM: HVM read GetHVM;
    property Root: TElement read Get_Root;
  published
    property Action;
    property Align;
    property Anchors;
    property BevelEdges;
    property BevelInner;
    property BevelKind;
    property BevelOuter;
    property BevelWidth;
    property BiDiMode;
    property BorderWidth;
    property Caption;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property OnClick;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property OnStdErr: TSciterOnStdErr read FOnStdErr write SetOnStdErr;
    property OnStdOut: TSciterOnStdOut read FOnStdOut write SetOnStdOut;
    property OnStdWarn: TSciterOnStdOut read FOnStdWarn write SetOnStdWarn;
end;

function ComObjectMethodHandler(vm: HVM; obj: tiscript_value; tag: Pointer): tiscript_value; cdecl;
function ComObjectGetterHandler(vm: HVM; obj: tiscript_value; tag: Pointer): tiscript_value; cdecl;
procedure ComObjectSetterHandler(vm: HVM; obj: tiscript_value; value: tiscript_value; tag: Pointer); cdecl;
procedure ComObjectFinalizer(vm: HVM; obj: tiscript_value); cdecl;
procedure SciterDebug(param: Pointer; subsystem: UINT; severity: UINT; text: PWideChar; text_length: UINT); stdcall;
procedure Register;

implementation

procedure ElementTagCallback(str: PAnsiChar; str_length: UINT; param : Pointer); stdcall;
var
  pElement: TElement;
  sStr: AnsiString;
begin
  sStr := AnsiString(str);
  pElement := TElement(param);
  pElement.FTag := sStr;
end;

procedure ElementHtmlCallback(bytes: PByte; num_bytes: UINT; param: Pointer); stdcall;
var
  pElement: TElement;
  pStr: PAnsiChar;
  sStr: UTF8String;
  wStr: WideString;
begin
  pElement := TElement(param);
  if (bytes = nil) or (num_bytes = 0) then
  begin
    pElement.FHtml := '';
  end
    else
  begin
    pStr := PAnsiChar(bytes);
    sStr := UTF8String(pStr);
    wStr := UTF8Decode(sStr);
  end;
  pElement.FHtml := wStr;
end;

procedure ElementTextCallback(str: PWideChar; str_length: UINT; param: Pointer); stdcall;
var
  pElement: TElement;
  sStr: WideString;
begin
  sStr := WideString(str);
  pElement := TElement(param);
  pElement.FText := sStr;
end;

procedure AttributeTextCallback(str: PWideChar; str_length: UINT; param: Pointer); stdcall;
var
  pElement: TElement;
  sStr: WideString;
begin
  sStr := WideString(str);
  pElement := TElement(param);
  pElement.FAttrValue := sStr;
end;

procedure StyleAttributeTextCallback(str: PWideChar; str_length: UINT; param: Pointer); stdcall;
var
  pElement: TElement;
  sStr: WideString;
begin
  sStr := WideString(str);
  pElement := TElement(param);
  pElement.FStyleAttrValue := sStr;
end;

function SelectorCallback(he: HELEMENT; Param: Pointer ): BOOL; stdcall;
var
  pElementCollection: TElementCollection;
  pElement: TElement;
begin
  pElementCollection := TElementCollection(Param);
  pElement := TElement.Create(he);
  pElementCollection.Add(pElement);
  Result := False;
end;

function ElementEventProc(tag: Pointer; he: HELEMENT; evtg: UINT; prms: Pointer): Integer; stdcall;
var
  pElement: TElement;
  pSource: TElement;
  pTarget: TElement;
  pMouseParams: PMOUSE_PARAMS;
  pKeyParams: PKEY_PARAMS;
  pFocusParams: PFOCUS_PARAMS;
  pTimerParams: PTIMER_PARAMS;
  pBehaviorEventParams: PBEHAVIOR_EVENT_PARAMS;
begin
  Result := 0;

  if prms = nil then Exit;
  if tag = nil then Exit;

  pElement := TElement(tag);

  case evtg of
    0: // HANDLE_INITIALIZATION
    begin

    end;
    1: // HANDLE_MOUSE
    begin
      if Assigned(pElement.FOnMouse) then
      begin
        pMouseParams := prms;
        pTarget := TElement.Create(pMouseParams.target);
        pElement.OnMouse(pElement, pTarget, pMouseParams.cmd, pMouseParams.pos.X, pMouseParams.pos.Y, pMouseParams.button_state, pMouseParams.alt_state);
        pTarget.Free;
      end;
    end;
    2: // HANDLE_KEY
    begin
      if Assigned(pElement.FOnKey) then
      begin
        pKeyParams := prms;
        pTarget := TElement.Create(pKeyParams.target);
        pElement.FOnKey(pElement, pTarget, pKeyParams.cmd, pKeyParams.key_code, pKeyParams.alt_state);
        pTarget.Free;
      end;
    end;
    4: // HANLDE_FOCUS
    begin
      if Assigned(pElement.FOnFocus) then
      begin
        pFocusParams := prms;
        pTarget := TElement.Create(pFocusParams.target);
        pElement.FOnFocus(pElement, pTarget, pFocusParams.cmd);
        pTarget.Free;
      end;
    end;
    16: // HANLDE_TIMER
    begin
      if Assigned(pElement.FOnTimer) then
      begin
        pTimerParams := prms;
        pElement.FOnTimer(pElement, Integer(pTimerParams.timerId));
      end;
    end;

    256: // HANDLE_BEHAVIOR_EVENT
    begin
      if Assigned(pElement.OnControlEvent) then
      begin
        pBehaviorEventParams := prms;
        if pBehaviorEventParams.heTarget <> nil then
          pTarget := TElement.Create(pBehaviorEventParams.heTarget)
        else
          pTarget := nil;
        if pBehaviorEventParams.he <> nil then
          pSource := TElement.Create(pBehaviorEventParams.he)
        else
          pSource := nil;

        pElement.FOnControlEvent(pElement, pTarget, pBehaviorEventParams.cmd, Integer(pBehaviorEventParams.reason), pSource);
        
        if pSource <> nil then
          pSource.Free;
        if pTarget <> nil then
          pTarget.Free;
          
      end;
    end;
    512: // HANDLE_METHOD_CALL
    begin

    end;
    128: // HANDLE_DATA_ARRIVED
    begin

    end;
    8: // HANLDE_SCROLL
    begin

    end;
    32: // HANLDE_SIZE
    begin

    end;
    1024: // HANDLE_SCRIPTING_METHOD_CALL
    begin

    end;
    2048: // HANDLE_TISCRIPT_METHOD_CALL
    begin

    end;
    8192: // HANDLE_GESTURE
    begin

    end;
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

procedure DispatchPropertyPut(const Dispatch: IDispatch; const MethodName: WideString; const AParams: array of OleVariant);
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
  pDispPut: TDispID;
  pNames: array[0..0] of POleStr;
  VarResult: Variant;
begin
  pDispPut := DISPID_PROPERTYPUT;

  Flags := INVOKE_PROPERTYPUT or INVOKE_PROPERTYPUTREF;

  Argc := High(AParams) + 1;
  if Argc < 0 then Argc := 0;

  // Method DISPID
  pNames[0] := PWideChar(MethodName);
  OleCheck(Dispatch.GetIDsOfNames(GUID_NULL, @pNames, 1, LOCALE_USER_DEFAULT, @pDispIds));

  // Paramarray
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
  params.cNamedArgs := 1;
  params.rgdispidNamedArgs := @pDispPut;

  try
    OleCheck(Dispatch.Invoke(pDispIds[0], GUID_NULL, LOCALE_USER_DEFAULT, Flags, TDispParams(Params), @VarResult, @ExcepInfo, @ArgErr));
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

  // Paramarray
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

type
  TComMethodCall = (Method, NonIndexedProperty, IndexedProperty);

  TComMethodInfo = class
  private
    function GetAnsiName: AnsiString;
  public
    CallArgsCount: Integer;
    CallType: TComMethodCall;
    GetArgsCount: Integer;
    HasGetter: Boolean;
    HasSetter: Boolean;
    Name: WideString;
    SetArgsCount: Integer;
    property AnsiName: AnsiString read GetAnsiName;
  end;

  TComMethodInfoList = class(TObjectList)
  private
    function Get_Item(const Index: Integer): TComMethodInfo;
  public
    procedure Add(Info: TComMethodInfo);
    function LookupMethodInfo(const Name: WideString): TComMethodInfo;
    property Item[const Index: Integer]: TComMethodInfo read Get_Item; default;
  end;

  TComClassInfo = class
  private
    FAllMethods: TComMethodInfoList;
    FClassDef: ptiscript_class_def;
    FMethods: TComMethodInfoList;
    FNativeMethods: Pointer;
    FNativeMethodsSz: Integer;
    FProps: TComMethodInfoList;
    procedure BuildClassDef;
    function GetAnsiGuid: AnsiString;
    function GetAnsiProgId: AnsiString;
    function GetClassDef: ptiscript_class_def;
    function GetMethods: TComMethodInfoList;
    function GetProps: TComMethodInfoList;
  public
    Guid: WideString;
    ProgID: WideString;
    constructor Create;
    destructor Destroy; override;
    procedure Build(const Obj: IDispatch);
    property AllMethods: TComMethodInfoList read FAllMethods;
    property AnsiGuid: AnsiString read GetAnsiGuid;
    property AnsiProgId: AnsiString read GetAnsiProgId;
    property ClassDef: ptiscript_class_def read GetClassDef;
    property Methods: TComMethodInfoList read GetMethods;
    property Props: TComMethodInfoList read GetProps;
  end;

  TComClassList = class(TObjectList)
  private
    function GetItem(const Index: Integer): TComClassInfo;
  public
    destructor Destroy; override;
    procedure Add(Value: TComClassInfo);
    function LookupClassInfo(const Obj: IDispatch): TComClassInfo;
    property Item[const Index: Integer]: TComClassInfo read GetItem; default;
  end;

var
  CLASS_BAG: TComClassList;

constructor TSciter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 300;
  Height := 300;
  TabStop := True;
  Caption := 'Sciter';
end;

destructor TSciter.Destroy;
begin
  inherited;
end;

function TSciter.Call(const FunctionName: WideString;
  const Args: array of OleVariant): OleVariant;
var
  pVal: TSciterValue;
  sFunctionName: AnsiString;
  pArgs: array of TSciterValue;
  i: Integer;
begin
  sFunctionName := FunctionName;
  SetLength(pArgs, Length(Args));
  for i := Low(Args) to High(Args) do
  begin
    V2S(Args[i], @Args[i]);
  end;
  if API.SciterCall(Self.Handle, PAnsiChar(sFunctionName), 0, nil, pVal) then
    Result := S2V(@pVal)
  else
    raise Exception.CreateFmt('Failed to call function "%s".', [FunctionName]);
end;

procedure TSciter.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
end;

procedure TSciter.CreateWindowHandle(const Params: TCreateParams);
begin
  inherited;
  if HandleAllocated then
  begin
    API.SciterSetupDebugOutput(Self.Handle, Self, @SciterDebug); 
    if FHtml <> '' then
    begin
      LoadHtml(FHtml, FBaseUrl);
      FHtml := '';
      FBaseUrl := '';
      FUrl := '';
    end;
    if FUrl <> '' then
    begin
      LoadURL(FUrl);
      FHtml := '';
      FBaseUrl := '';
      FUrl := '';
    end;
  end;
end;

procedure TSciter.CreateWnd;
begin
  inherited;
end;

function TSciter.Eval(const Script: WideString): OleVariant;
var
  pVal: TSciterValue;
begin
  if API.SciterEval(Self.Handle, PWideChar(Script), Length(Script), pVal)  then
    Result := S2V(@pVal)
  else
    Result := Unassigned;
end;

function TSciter.FindElement(Point: TPoint): IElement;
var
  hResult: HELEMENT;
  pResult: TElement;
begin
  if API.SciterFindElement(Handle, Point, hResult) <> SCDOM_OK then
  begin
    Result := nil;
  end
    else
  begin
    if hResult = nil then
    begin
      Result := nil;
    end
      else
    begin
      pResult := TElement.Create(hResult);
      Result := pResult;
    end;
  end;
end;

function TSciter.GetElementByHandle(Handle: Integer): IElement;
begin
  Result := TElement.Create(HELEMENT(Handle));
end;

function TSciter.GetHVM: HVM;
begin
  Result := API.SciterGetVM(Self.Handle);
end;

function TSciter.GetMinHeight(Width: Integer): Integer;
begin
  Result := API.SciterGetMinHeight(Handle, Width);
end;

function TSciter.GetMinWidth: Integer;
begin
  Result := API.SciterGetMinWidth(Handle);
end;

function TSciter.Get_Html: WideString;
begin
  Result := Get_Root.OuterHtml;
end;

function TSciter.Get_Root: TElement;
var
  he: HELEMENT;
  h: HWND;
begin
  he := nil;
  h := Self.WindowHandle;
  if API.SciterGetRootElement(h, he) = SCDOM_OK then
    Result := TElement.Create(he)
  else
    Result := nil;
end;

procedure TSciter.LoadHtml(const Html: WideString; const BaseURL: WideString);
var
  sHtml: AnsiString;
  pHtml: PAnsiChar;
  iLen: UINT;
begin
  if (csDesigning in ComponentState) then
    Exit;

  if not HandleAllocated then
  begin
    FHtml := Html;
    FBaseUrl := BaseURL;
    FUrl := '';
  end
    else
  begin
    sHtml := UTF8Encode(Html);
    pHtml := PAnsiChar(sHtml);
    iLen := Length(sHtml);
    API.SciterLoadHtml(Handle, PByte(pHtml), iLen, PWideChar(BaseURL));
  end;
end;

procedure TSciter.LoadURL(const URL: Widestring);
begin
  if (csDesigning in ComponentState) then
    Exit;

  if not HandleAllocated then
  begin
    FHtml := '';
    FBaseUrl := '';
    FUrl := URL;
  end
    else
  begin
    API.SciterLoadFile(Self.Handle, PWideChar(URL));
  end;
end;

{ Tweaking TWinControl focus behavior }
procedure TSciter.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  SetFocus;
end;

{ Tweaking TWinControl MouseWheel behavior }
procedure TSciter.MouseWheelHandler(var Message: TMessage);
var
  pMsg: TWMMouseWheel;
begin
  pMsg := TWMMouseWheel(Message);
  if pMsg.WheelDelta < 0 then
    Perform(WM_VSCROLL, 1, 0)
  else
    Perform(WM_VSCROLL, 0, 0);
end;

procedure TSciter.RegisterComObject(const Name: WideString;
  const Obj: IDispatch);
var
  pClassInfo: TComClassInfo;
  vm: TIScriptApi.HVM;
  zns: tiscript_value;
  class_def: tiscript_value;
  class_instance: tiscript_value;
  pinned_class_instance: tiscript_pvalue;
  var_name: tiscript_value;
  var_value: tiscript_value;
begin
  pClassInfo := CLASS_BAG.LookupClassInfo(Obj);
  try
    vm        := API.SciterGetVM(Handle);
    zns       := NI.get_global_ns(vm);
    var_name  := NI.string_value(vm, PWideChar(Name), Length(Name));
    var_value := NI.get_prop(vm, zns, var_name);

    if NI.is_undefined(var_value) then
    begin
      class_def := NI.define_class(vm, pClassInfo.ClassDef, zns);
      if not NI.is_class(vm, class_def) then
        raise Exception.Create('Not a class');
      class_instance := NI.create_object(vm, class_def);
      if not NI.is_native_object(class_instance) then
        raise Exception.Create('Error');
      pinned_class_instance.vm := nil;
      pinned_class_instance.val := class_instance;
      pinned_class_instance.d1 := nil;
      pinned_class_instance.d2 := nil;
      NI.pin(vm, @pinned_class_instance);
      Obj._AddRef;
      NI.set_instance_data(class_instance, Pointer(obj));
      NI.set_prop(vm, zns, var_name, class_instance);
    end;
  finally
    //if pClassInfo <> nil then
    //  pClassInfo.Free;
  end;
end;

function TSciter.Select(const Selector: WideString): TElement;
var
  pRoot: IElement;
begin
  pRoot := Get_Root;
  Result := pRoot.Select(Selector);
end;

function TSciter.SelectAll(const Selector: WideString): IElementCollection;
var
  pRoot: IElement;
begin
  pRoot := Get_Root;
  Result := pRoot.SelectAll(Selector);
end;

procedure TSciter.SetOnStdErr(const Value: TSciterOnStdErr);
begin
  FOnStdErr := Value;
end;

procedure TSciter.SetOnStdOut(const Value: TSciterOnStdOut);
begin
  FOnStdOut := Value;
end;

procedure TSciter.SetOnStdWarn(const Value: TSciterOnStdOut);
begin
  FOnStdWarn := Value;
end;

procedure TSciter.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
end;

procedure TSciter.Test;
begin

end;

procedure TSciter.UpdateWindow;
begin
  API.SciterUpdateWindow(Self.Handle);
end;

procedure TSciter.WndProc(var Message: TMessage);
var
  llResult: LRESULT;
  bHandled: Integer;
  M: PMsg;
begin
  if not (csDesigning in ComponentState) then
  begin
    // Tweaking arrow keys handling (VCL-specific)
    if Message.Msg = WM_GETDLGCODE then
    begin
      Message.Result := DLGC_WANTALLKEYS or DLGC_WANTARROWS or DLGC_WANTCHARS or DLGC_HASSETSEL;
      if Message.lParam <> 0 then
      begin
        M := PMsg(Message.lParam);
        case M.Message of
          WM_KEYDOWN, WM_KEYUP, WM_CHAR:
          begin
            Perform(M.message, M.wParam, M.lParam);
            Message.Result := Message.Result or DLGC_WANTMESSAGE;
          end;
        end;
      end;
      Exit;
    end;
    
    llResult := API.SciterProcND(Self.WindowHandle, Message.Msg, Message.WParam, Message.LParam, bHandled);
    if bHandled <> 0 then
    begin
      Message.Result := llResult;
    end
      else
    begin
      inherited WndProc(Message);
    end;
  end
    else
  begin
    inherited WndProc(Message);
  end;
end;

constructor TElement.Create(h: HELEMENT);
begin
  Self.FELEMENT := h;
end;

destructor TElement.Destroy;
begin
  inherited;
end;

{ TElement }
procedure TElement.AppendChild(const Element: IElement);
begin
  InsertElement(Element, MaxInt);
end;

function TElement.CreateElement(const Tag: WideString; const Text: WideString): IElement;
var
  pElement: TElement;
  pHandle: HELEMENT;
  sTag: AnsiString;
begin
  sTag := Tag;
  API.SciterCreateElement(PAnsiChar(sTag), PWideChar(Text), pHandle);
  pElement := TElement.Create(pHandle);
  Result := pElement;
end;

procedure TElement.Delete;
begin
  API.SciterDeleteElement(FElement);
end;

function TElement.Equals(const Element: IElement): WordBool;
begin
  Result := (Element <> nil) and (Self.Handle = Element.Handle);
end;

function TElement.GetChild(Index: Integer): IElement;
var
  hResult: HELEMENT;
  pResult: TElement;
begin
  API.SciterGetNthChild(FElement, UINT(Index), hResult);
  if hResult = nil then
    Result := nil
  else
  begin
    pResult := TElement.Create(hResult);
    Result := pResult;
  end;
end;

function TElement.Get_Attr(const AttrName: WideString): WideString;
var
  sAttrName: AnsiString;
begin
  sAttrName := AttrName;
  Self.FAttrName := AttrName;
  API.SciterGetAttributeByNameCB(FElement, PAnsiChar(sAttrName), @AttributeTextCallback, Self);
  Result := Self.FAttrValue;
end;

function TElement.Get_ChildrenCount: Integer;
var
  cnt: UINT;
begin
  API.SciterGetChildrenCount(FElement, cnt);
  Result := Integer(cnt);
end;

function TElement.Get_Handle: Integer;
begin
  Result := Integer(FELEMENT);
end;

function TElement.Get_Index: Integer;
var
  pResult: UINT;
begin
  pResult := 0;
  API.SciterGetElementIndex(FElement, pResult);
  Result := Integer(pResult);
end;

function TElement.Get_InnerHtml: WideString;
begin
  API.SciterGetElementHtmlCB(FElement, False, @ElementHtmlCallback, Self);
  Result := Self.FHtml;
end;

function TElement.Get_OnControlEvent: TElementOnControlEvent;
begin
  Result := FOnControlEvent;
end;

function TElement.Get_OnMouse: TElementOnMouse;
begin
  Result := FOnMouse;
end;

function TElement.Get_OuterHtml: WideString;
begin
  API.SciterGetElementHtmlCB(FElement, True, @ElementHtmlCallback, Self);
  Result := Self.FHtml;
end;

function TElement.Get_Parent: IElement;
var
  pParent: HELEMENT;
  pResult: TElement;
begin
  pParent := nil;
  API.SciterGetParentElement(FELEMENT, pParent);
  if (pParent = nil) then
  begin
    Result := nil;
  end
    else
  begin
    pResult := TElement.Create(pParent);
    Result := pResult;
  end;
end;

function TElement.Get_StyleAttr(const AttrName: WideString): WideString;
var
  sStyleAttrName: AnsiString;
begin
  sStyleAttrName := AttrName;
  Self.FStyleAttrName := AttrName;
  API.SciterGetAttributeByNameCB(FElement, PAnsiChar(sStyleAttrName), @StyleAttributeTextCallback, Self);
  Result := Self.FStyleAttrValue;
end;

function TElement.Get_Tag: WideString;
begin
  API.SciterGetElementTypeCB(FElement, @ElementTagCallback, Self);
  Result := Self.FTag;
end;

function TElement.Get_Text: WideString;
begin
  API.SciterGetElementTextCB(FELEMENT, @ElementTextCallback, Self);
  Result := FText;
end;

function TElement.Get_Value: OleVariant;
var
  pValue: TSciterValue;
begin
  pValue.t := 0;
  pValue.u := 0;
  pValue.d := 0;
  if API.SciterGetValue(FElement, @pValue) <> SCDOM_OK then
    Result := Unassigned
  else
    Result := S2V(@pValue);
end;

procedure TElement.InsertElement(const Child: IElement; Index: Integer);
begin
  API.SciterInsertElement(HELEMENT(Child.Handle), FElement, Index);
end;

procedure TElement.PostEvent(EventCode: Integer);
begin
  API.SciterPostEvent(FELEMENT, UINT(EventCode), nil, nil);
end;

procedure TElement.ScrollToView;
begin
  API.SciterScrollToView(FElement, 0);
end;

function TElement.Select(const Selector: WideString): TElement;
var
  pCol: IElementCollection;
begin
  pCol := SelectAll(Selector);
  if pCol.Count = 0 then
    Result := nil
  else
    Result := pCol[0];
end;

function TElement.SelectAll(const Selector: WideString): IElementCollection;
var
  sSelector: AnsiString;
  pResult: TElementCollection;
begin
  pResult := TElementCollection.Create;
  sSelector := Selector;
  API.SciterSelectElements(FELEMENT, PAnsiChar(sSelector), @SelectorCallback, pResult);
  Result := pResult;
end;

procedure TElement.SendEvent(EventCode: Integer);
var
  handled: BOOL;
begin
  API.SciterSendEvent(FELEMENT, UINT(EventCode), nil, nil, handled);
end;

procedure TElement.Set_Attr(const AttrName, Value: WideString);
var
  sAttrName: AnsiString;
begin
  sAttrName := AttrName;
  API.SciterSetAttributeByName(FElement, PAnsiChar(sAttrName), PWideChar(Value));
end;

procedure TElement.Set_InnerHtml(const Value: WideString);
var
  sStr: UTF8String;
  pStr: PAnsiChar;
  iLen: Integer;
begin
  sStr := UTF8Encode(Value);
  pStr := PAnsiChar(sStr);
  iLen := Length(sStr);
  API.SciterSetElementHtml(FElement, PByte(pStr), iLen, SIH_REPLACE_CONTENT);
end;

procedure TElement.Set_OnControlEvent(const Value: TElementOnControlEvent);
begin
  FOnControlEvent := Value;
  if Assigned(Value) then
  begin
    if not FAttached then
    begin
      API.SciterAttachEventHandler(Self.FElement, @ElementEventProc, Self);
      FAttached := True;
    end;
  end
    else
  begin
    API.SciterDetachEventHandler(Self.FElement, @ElementEventProc, Self);
  end;
end;

procedure TElement.Set_OnMouse(const Value: TElementOnMouse);
begin
  FOnMouse := Value;
  if Assigned(Value) then
  begin
    if not FAttached then
    begin
      API.SciterAttachEventHandler(Self.FElement, @ElementEventProc, Self);
      FAttached := True;
    end;
  end
    else
  begin
    API.SciterDetachEventHandler(Self.FElement, @ElementEventProc, Self);
  end;
end;

procedure TElement.Set_OuterHtml(const Value: WideString);
var
  sStr: UTF8String;
  pStr: PAnsiChar;
  iLen: Integer;
begin
  sStr := UTF8Encode(Value);
  pStr := PAnsiChar(sStr);
  iLen := Length(sStr);
  API.SciterSetElementHtml(FElement, PByte(pStr), iLen, SOH_REPLACE);
end;

procedure TElement.Set_StyleAttr(const AttrName, Value: WideString);
var
  sStyleAttrName: AnsiString;
  hr: SCDOM_RESULT;
begin
  sStyleAttrName := AttrName;
  hr := API.SciterSetStyleAttribute(FElement, PAnsiChar(sStyleAttrName), PWideChar(Value));
  if hr <> SCDOM_OK then
    Exit;
end;

procedure TElement.Set_Text(const Value: WideString);
var
  hr: SCDOM_RESULT;
begin
  hr := API.SciterSetElementText(FElement, PWideChar(Value), Length(Value));
  if hr <> SCDOM_OK then
    raise Exception.CreateFmt('Failed to set element text.', []);
end;

procedure TElement.Set_Value(Value: OleVariant);
var
  sValue: TSciterValue;
begin
  V2S(Value, @sValue);
  API.SciterSetValue(FElement, @sValue);
end;

constructor TElementCollection.Create;
begin
  FList := TObjectList.Create(False);
end;

destructor TElementCollection.Destroy;
begin
  FList.Free;
  inherited;
end;

{ TElementCollection }

procedure TElementCollection.Add(const Item: TElement);
begin
  FList.Add(Item);
end;

function TElementCollection.Get_Count: Integer;
begin
  Result := FList.Count;
end;

function TElementCollection.Get_Item(const Index: Integer): TElement;
begin
  Result := FList[Index] as TElement;
end;

procedure TElementCollection.RemoveAll;
var
  i: Integer;
begin
  for i := Count - 1 downto 0 do
  begin
    Item[i].Delete;
    // TODO: Item[i].Free;
  end;
  FList.Clear;
end;

{ TComClassInfo }

constructor TComClassInfo.Create;
begin
  FAllMethods := TComMethodInfoList.Create(False);
  FProps := TComMethodInfoList.Create(False);
  FMethods := TComMethodInfoList.Create(False);
end;

destructor TComClassInfo.Destroy;
begin
  FClassDef.methods := nil;
  FreeMem(FNativeMethods, FNativeMethodsSz);
  FNativeMethods := nil;
  
  FProps.Free;
  FMethods.Free;
  FAllMethods.Free;
  inherited;
end;

procedure TComClassInfo.Build(const Obj: IDispatch);
var
  iCnt: Integer;
  typeInfo: ITypeInfo;
  typeAttr: PTypeAttr;
  ptypeGuid: PWideChar;
  pprogId: PWideChar;
  typeGuid: WideString;
  funcDesc: PFuncDesc;
  sfuncName: PWideChar;
  funcName: WideString;
  i: Integer;
  cNames: Integer;
  pMethodInfo: TComMethodInfo;
begin
  FAllMethods.Clear;
  FMethods.Clear;
  FProps.Clear;

  try
    if Obj = nil then
      Exit;

    OleCheck(Obj.GetTypeInfoCount(iCnt));
    if iCnt = 0 then
      Exit;

    OleCheck(Obj.GetTypeInfo(0, LOCALE_USER_DEFAULT, typeInfo));

    OleCheck(typeInfo.GetTypeAttr(typeAttr));

    // Guid
    OleCheck(StringFromCLSID(typeAttr.guid, ptypeGuid));
    typeGuid := WideString(ptypeGuid);
    Self.Guid := typeGuid;

    // ProgID
    if Succeeded(ProgIDFromCLSID(typeAttr.guid, pprogId)) then
    begin
      Self.ProgID := WideString(pprogId);
      CoTaskMemFree(pprogId);
    end;


    for i := 0 to typeAttr.cFuncs - 1 do
    try
      funcDesc := nil;
      OleCheck(typeInfo.GetFuncDesc(i, funcDesc));

      sfuncName := nil;
      typeInfo.GetNames(funcDesc.memid, @sfuncName, 1, cNames);
      funcName := WideString(sfuncName);

      pMethodInfo := Self.AllMethods.LookupMethodInfo(funcName);

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
       if sfuncName <> nil then
         CoTaskMemFree(sfuncName);
       if funcDesc <> nil then
        typeInfo.ReleaseFuncDesc(funcDesc);
    end;
    BuildClassDef;
  finally
    if ptypeGuid <> nil then
      CoTaskMemFree(ptypeGuid);
    if typeAttr <> nil then
      if typeInfo <> nil then
        typeInfo.ReleaseTypeAttr(typeAttr);
  end;
end;

procedure TComClassInfo.BuildClassDef;
var
  i: Integer;
  pInfo: TComMethodInfo;
  pclass_methods: ptiscript_method_def;
  pComMethods: TComMethodInfoList;
  pComProps: TComMethodInfoList;
  smethod_name: AnsiString;
  sprop_name: AnsiString;
  propsSz: Integer;
  pclass_props: ptiscript_prop_def;
begin
  GetMem(FClassDef, SizeOf(tiscript_class_def));
  FClassDef.methods := nil;
  FClassDef.props := nil;
  FClassDef.consts := nil;
  FClassDef.get_item := nil;
  FClassDef.set_item := nil;
  FClassDef.finalizer := @ComObjectFinalizer;
  FClassDef.iterator := nil;
  FClassDef.on_gc_copy := nil;
  FClassDef.prototype := 0;

  FClassDef.name := StrNew(PAnsiChar(Self.AnsiGuid));

  // Methods
  pComMethods := Self.Methods;
  FNativeMethodsSz := SizeOf(tiscript_method_def) * (pComMethods.Count + 1); // 1 - "null-terminating record"
  GetMem(pclass_methods, FNativeMethodsSz);
  FClassDef.methods := pclass_methods;
  
  for i := 0 to pComMethods.Count - 1 do
  begin
    pInfo := pComMethods[i];
    smethod_name := pInfo.AnsiName;
    pclass_methods.name := StrNew(PAnsiChar(smethod_name));
    pclass_methods.handler := @ComObjectMethodHandler;
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
  pComProps := Self.Props;
  propsSz := SizeOf(tiscript_prop_def) * (pComProps.Count + 1); // 1 - "null-terminating record"
  GetMem(pclass_props, propsSz);
  FClassDef.props := pclass_props;
  for i := 0 to pComProps.Count - 1 do
  begin
    pInfo := pComProps[i];
    sprop_name := pInfo.Name;
    pclass_props.dispatch := nil;
    pclass_props.name := StrNew(PAnsiChar(sprop_name));

    // non-indexed property getter
    if (pInfo.HasGetter) and (pInfo.GetArgsCount = 0) then
      pclass_props.getter := @ComObjectGetterHandler
    else
      pclass_props.getter := nil;

    // non-indexed property setter
    if (pInfo.HasSetter) and (pInfo.SetArgsCount = 1) then
      pclass_props.setter := @ComObjectSetterHandler
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

function TComClassInfo.GetAnsiGuid: AnsiString;
begin
  Result := Self.Guid;
end;

function TComClassInfo.GetAnsiProgId: AnsiString;
begin
  Result := Self.AnsiProgId;
end;

function TComClassInfo.GetClassDef: ptiscript_class_def;
begin
  Result := FClassDef;
end;

function TComClassInfo.GetMethods: TComMethodInfoList;
var
  i: Integer;
begin
  FMethods.Clear;
  for i := 0 to Self.FAllMethods.Count - 1 do
  begin
    if Self.FAllMethods.Item[i].CallType = Method then
      FMethods.Add(Self.FAllMethods.Item[i]);
  end;
  Result := FMethods;
end;

function TComClassInfo.GetProps: TComMethodInfoList;
var
  i: Integer;
begin
  FProps.Clear;
  for i := 0 to Self.FAllMethods.Count -1 do
  begin
    if (Self.FAllMethods[i].CallType = NonIndexedProperty) or
       (Self.FAllMethods[i].CallType = IndexedProperty) then
      FProps.Add(Self.FAllMethods[i]);
  end;
  Result := FProps;
end;

procedure SciterDebug(param: Pointer; subsystem: UINT; severity: UINT; text: PWideChar; text_length: UINT); stdcall;
var
  FSciter: TSciter;
begin
  FSciter := TSciter(param);
  case severity of
    0: if Assigned(FSciter.FOnStdOut)  then FSciter.FOnStdOut(FSciter, WideString(text));
    1: if Assigned(FSciter.FOnStdWarn) then FSciter.FOnStdWarn(FSciter, WideString(text));
    2: if Assigned(FSciter.FOnStdErr)  then FSciter.FOnStdErr(FSciter, WideString(text));
  end;
end;

procedure ComObjectFinalizer(vm: HVM; obj: tiscript_value); cdecl;
var
  pDisp: IDispatch;
begin
  pDisp := IDispatch(NI.get_instance_data(obj));
	if pDisp <> nil then
  begin
		pDisp._Release;
		NI.set_instance_data(obj, nil);
	end;
end;

function ComObjectGetterHandler(vm: HVM; obj: tiscript_value; tag: Pointer): tiscript_value; cdecl;
var
  pDisp: IDispatch;
  oValue: OleVariant;
  sValue: TSciterValue;
  pMethodInfo: TComMethodInfo;
  tResult: tiscript_value;
begin
  pDisp := IDispatch(NI.get_instance_data(obj));
  pMethodInfo := TComMethodInfo(tag);
  oValue := ComObj.GetDispatchPropValue(pDisp, pMethodInfo.Name);
  V2S(oValue, @sValue);
  API.Sciter_S2T(vm, @sValue, tResult);
  Result := tResult;
end;

procedure ComObjectSetterHandler(vm: HVM; obj: tiscript_value; value: tiscript_value; tag: Pointer); cdecl;
var
  pDisp: IDispatch;
  oValue: OleVariant;
  sValue: TSciterValue;
  pMethodInfo: TComMethodInfo;
begin
  pDisp := IDispatch(NI.get_instance_data(obj));
  pMethodInfo := TComMethodInfo(tag);
  API.Sciter_T2S(vm, value, svalue, False);
  oValue := S2V(@sValue);
  ComObj.SetDispatchPropValue(pDisp, pMethodInfo.Name, oValue);
end;

function ComObjectMethodHandler(vm: HVM; obj: tiscript_value; tag: Pointer): tiscript_value; cdecl;
var
  argc: Integer;
  arg: tiscript_value;
  sarg: TSciterValue;
  oargs: array of OleVariant;
  i: Integer;
  ti_self: tiscript_value;
  ti_super: tiscript_value;
  sender: IDispatch;
  pInfo: TComMethodInfo;
  oresult: OleVariant;
  sresult: TSciterValue;
  tresult: tiscript_value;
begin
  pInfo := nil;
  if tag <> nil then
    pInfo := TComMethodInfo(tag);

  argc := NI.get_arg_count(vm);
  // this
  if argc > 0 then
  begin
    ti_self := NI.get_arg_n(vm, 0);
    sender := IDispatch(NI.get_instance_data(ti_self));
  end;
  // super
  if (argc > 1) then
    ti_super := NI.get_arg_n(vm, 1);

  // Invoke params
  SetLength(oargs, argc - 2);
  for i := 2 to argc - 1 do
  begin
    arg := NI.get_arg_n(vm, i);
    API.Sciter_T2S(vm, arg, sarg, false);
    oargs[i - 2] := S2V(@sarg);
  end;
  oresult := DispatchInvoke(sender, pInfo.Name, oargs);

  // VARIANT to sciter_value
  if V2S(oresult, @sresult) <> SCDOM_OK then
    raise EOleException.CreateFmt('COM object call failed: cannot convert result to VARIANT.', []);

  // sciter_value to tiscript_value
  if not API.Sciter_S2T(vm, @sresult, tresult) then
    raise EOleException.CreateFmt('COM object call failed: cannot convert sciter_value to tiscript_value.', []);
  
  Result := tresult;
end;

{ TComMethodInfoList }

procedure TComMethodInfoList.Add(Info: TComMethodInfo);
begin
  inherited Add(Info);
end;

function TComMethodInfoList.Get_Item(const Index: Integer): TComMethodInfo;
begin
  Result := inherited GetItem(Index) as TComMethodInfo;
end;

function TComMethodInfoList.LookupMethodInfo(
  const Name: WideString): TComMethodInfo;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if Item[i].Name = Name then
    begin
      Result := Item[i];
      Exit;
    end;
  end;
  Result := TComMethodInfo.Create;
  Result.Name := Name;
  Add(Result);
end;

{ TComMethodInfo }

function TComMethodInfo.GetAnsiName: AnsiString;
begin
  Result := Name;
end;

destructor TComClassList.Destroy;
begin
  inherited;
end;

{ TComClassList }

procedure TComClassList.Add(Value: TComClassInfo);
begin
  inherited Add(Value);
end;

function TComClassList.GetItem(const Index: Integer): TComClassInfo;
begin
  Result := inherited GetItem(Index) as TComClassInfo;
end;

function TComClassList.LookupClassInfo(const Obj: IDispatch): TComClassInfo;
var
  pInfo: TComClassInfo;
  i: Integer;
  typeInfo: ITypeInfo;
  typeAttr: PTypeAttr;
  sGuid: AnsiString;
begin
  typeInfo := nil;
  typeAttr := nil;
  try
    Obj.GetTypeInfo(0, LOCALE_USER_DEFAULT, typeInfo);
    typeInfo.GetTypeAttr(typeAttr);
    sGuid := GUIDToString(typeAttr.guid);
    for i := 0 to Count - 1 do
    begin
      if Item[i].AnsiGuid = sGuid then
      begin
        Result := Item[i];
        Exit;
      end;
    end;

    pInfo := TComClassInfo.Create;
    pInfo.Build(Obj);
    Self.Add(pInfo);
    Result := pInfo;
  finally
    if typeInfo <> nil then
    begin
      if typeAttr <> nil then
        typeInfo.ReleaseTypeAttr(typeAttr);
    end;
  end;
end;

procedure Register;
begin
  RegisterComponents('Samples', [TSciter]);
end;

procedure TSciter.Paint;
begin
  inherited;
  if csDesigning in ComponentState then
  begin
    Canvas.Brush.Color := clWindow;
    Canvas.FillRect(ClientRect);
    Canvas.TextOut(10, 10, 'Sciter: ' + Name);
  end;
end;

initialization
  CLASS_BAG := TComClassList.Create(False);

finalization
  CLASS_BAG.Free;
end.
