unit Sciter;

interface

uses
  Windows, Forms, Dialogs, Messages, ComObj, ActiveX, OleCtrls, Controls, Classes, SysUtils, SciterApi, TiScriptApi,
  Contnrs, Variants, Math, Graphics;

type

  TSciter = class;
  TElementCollection = class;
  TElement = class;

  IElement = interface;
  IElementCollection = interface;
  
    // Element events
  TElementOnMouse = procedure(ASender: TObject; const target: IElement; eventType: MOUSE_EVENTS;
                                                x: Integer; y: Integer; buttons: MOUSE_BUTTONS;
                                                keys: KEYBOARD_STATES) of object;
  TElementOnKey = procedure(ASender: TObject; const target: IElement; eventType: KEY_EVENTS;
                                              code: Integer; keys: KEYBOARD_STATES) of object;
  TElementOnFocus = procedure(ASender: TObject; const target: IElement; eventType: FOCUS_EVENTS) of object;
  TElementOnTimer = procedure(ASender: TObject; timerId: Integer) of object;
  TElementOnControlEvent = procedure(ASender: TObject; const target: IElement; eventType: BEHAVIOR_EVENTS;
                                                       reason: Integer; const source: IElement) of object;
  TElementOnScroll = procedure(ASender: TObject; const target: IElement; eventType: SCROLL_EVENTS;
                                                 pos: Integer; isVertical: WordBool) of object;

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
    procedure RegisterNativeFunction(const Name: WideString; Handler: tiscript_method);
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

procedure SciterDebug(param: Pointer; subsystem: UINT; severity: UINT; text: PWideChar; text_length: UINT); stdcall;
procedure Register;

implementation

uses SciterOleProxy;

function CreateObjectNative(vm: HVM): tiscript_value; cdecl;
var
  oVal: OleVariant;
  pVal: IDispatch;
  tProgId: tiscript_value;
  pProgId: PWideChar;
  iCnt: UINT;
  sProgId: WideString;
begin
  iCnt := NI.get_arg_count(vm);
  tProgId := NI.get_arg_n(vm, 2);
  NI.get_string_value(tProgId, pProgId, iCnt);
  sProgId := WideString(pProgId);
  oVal := CreateOleObject(sProgId);
  Result := WrapOleObject(vm, IDispatch(oVal));
end;

procedure ElementTagCallback(str: PAnsiChar; str_length: UINT; param : Pointer); stdcall;
var
  pElement: TElement;
  sStr: AnsiString;
begin
  pElement := TElement(param);
  if str_length > 0 then
  begin
    sStr := String(str);
    pElement.FTag := sStr; 
  end
    else
  begin
    pElement.FTag := '';
  end;
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
begin
  pElement := TElement(param);
  if str_length > 0 then
  begin
    pElement.FText := WideCharLenToString(str, str_length);
  end
    else
  begin
    pElement.FText := '';
  end;
end;

procedure AttributeTextCallback(str: PWideChar; str_length: UINT; param: Pointer); stdcall;
var
  pElement: TElement;
begin
  pElement := TElement(param);
  if str_length > 0 then
  begin
    pElement.FAttrValue := WideCharLenToString(str, str_length);
  end
    else
  begin
    pElement.FAttrValue := '';
  end;
end;

procedure StyleAttributeTextCallback(str: PWideChar; str_length: UINT; param: Pointer); stdcall;
var
  pElement: TElement;
begin
  pElement := TElement(param);
  if str_length > 0 then
  begin
    pElement.FStyleAttrValue := WideCharLenToString(str, str_length);
  end
    else
  begin
    pElement.FStyleAttrValue := '';
  end;
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


type
  TComMethodCall = (Method, NonIndexedProperty, IndexedProperty);

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
  API.ValueInit(@pVal);
  SetLength(pArgs, Length(Args));
  for i := Low(Args) to High(Args) do
  begin
    V2S(Args[i], @Args[i]);
  end;
  // if API.SciterCall(Self.Handle, PAnsiChar(sFunctionName), Length(pArgs), @pArgs[0], pVal) then
  if API.SciterCall(Handle, PAnsiChar(sFunctionName), 0, nil, pVal) then
    S2V(@pVal, Result)
  else
    raise Exception.CreateFmt('Failed to call function "%s".', [FunctionName]);
end;

procedure TSciter.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or WS_TABSTOP;
end;

procedure TSciter.CreateWindowHandle(const Params: TCreateParams);
begin
  inherited;
  if HandleAllocated then
  begin
    API.SciterSetupDebugOutput(Self.Handle, Self, @SciterDebug);
    RegisterNativeFunction('CreateObject', @CreateObjectNative); 
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
    S2V(@pVal, Result)
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
  vm: TiScriptApi.HVM;
begin
  vm := API.SciterGetVM(Handle);
  SciterOleProxy.RegisterOleObject(vm, Obj, Name);
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
  if API.SciterGetElementTypeCB(FElement, @ElementTagCallback, Self) = SCDOM_OK then
    Result := FTag
  else
    Result := '';
end;

function TElement.Get_Text: WideString;
begin
  if API.SciterGetElementTextCB(FELEMENT, @ElementTextCallback, Self) = SCDOM_OK then
    Result := FText
  else
    Result := '';
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
    S2V(@pValue, Result);
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

procedure TSciter.RegisterNativeFunction(const Name: WideString;
  Handler: tiscript_method);
var
  method_def: ptiscript_method_def;
  smethod_name: AnsiString;
  func_def: tiscript_value;
  func_name: tiscript_value;
  vm: TiScriptApi.HVM;
  zns: tiscript_value;
begin
  vm := API.SciterGetVM(Handle);
  zns := NI.get_global_ns(vm);
  
  smethod_name := Name;
  func_name := NI.string_value(vm, PWideChar(Name), Length(Name));

  New(method_def);
  method_def.dispatch := nil;
  method_def.name := StrNew(PAnsiChar(smethod_name));
  method_def.handler := @Handler;
  method_def.tag := nil;

  func_def := NI.native_function_value(vm, method_def);
  if not NI.is_native_function(func_def) then
  begin
    raise Exception.CreateFmt('Failed to register native function "%s".', [Name]);
  end;

  NI.set_prop(vm, zns, func_name, func_def);

  // NI.call(vm, zns, func_def, nil, 0, retval);
end;


initialization
  CoInitialize(nil);
  OleInitialize(nil);

end.
