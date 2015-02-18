{*******************************************************}
{                                                       }
{  Sciter control                                       }
{  Copyright (c) Dmitry Baranov                         }
{                                                       }
{  This component uses Sciter Engine,                   }
{  copyright Terra Informatica Software, Inc.           }
{  (http://terrainformatica.com/).                      }
{                                                       }
{*******************************************************}

unit Sciter;

interface

uses
  Windows, Forms, Dialogs, Messages, ComObj, ActiveX, OleCtrls, Controls, Classes, SysUtils, SciterApi, TiScriptApi,
  Contnrs, Variants, Math, Graphics, SciterNative;

type

  TSciter = class;
  TElementCollection = class;
  TElement = class;

  IElement = interface;
  IElementCollection = interface;

  { Element events }
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
  TElementOnSize = procedure(ASender: TObject; const target: IElement) of object;

  { Sciter events }
  TSciterOnStdOut = procedure(ASender: TObject; const msg: WideString) of object;
  TSciterOnStdErr = procedure(ASender: TObject; const msg: WideString) of object;
  TSciterOnLoadData = procedure(ASender: TObject; const url: WideString; resType: SciterResourceType;
                                                  requestId: Integer; out discard: WordBool) of object;
  TSciterOnDataLoaded = procedure(ASender: TObject; const url: WideString; resType: SciterResourceType;
                                                    data: PByte; dataLength: Integer;
                                                    requestId: Integer) of object;
  TSciterOnDocumentComplete = procedure(ASender: TObject; const url: WideString) of object;
  TSciterOnMethodCall = procedure(ASender: TObject; const MethodName: WideString; const Args: array of OleVariant;
    var ReturnValue: OleVariant; var Handled: boolean) of object;


  IElement = interface
    ['{E2C542D1-5B7B-4513-BFBC-7B0DD9FB04DE}']
    procedure AppendChild(const Element: IElement);
    function AttachHwndToElement(h: HWND): boolean;
    function CloneElement: TElement;
    function CreateElement(const Tag: WideString; const Text: WideString): IElement;
    procedure Delete;
    function Equals(const Element: IElement): WordBool;
    function FindNearestParent(const Selector: WideString): TElement;
    function GetAttrCount: Integer;
    function GetAttributeName(Index: Integer): WideString;
    function GetAttributeValue(Index: Integer): WideString;
    function GetChild(Index: Integer): IElement;
    function GetEnabled: boolean;
    function GetVisible: boolean;
    function Get_Attr(const AttrName: WideString): WideString;
    function Get_ChildrenCount: Integer;
    function Get_Handle: Integer;
    function Get_ID: WideString;
    function Get_Index: Integer;
    function Get_InnerHtml: WideString;
    function Get_OuterHtml: WideString;
    function Get_Parent: IElement;
    function Get_StyleAttr(const AttrName: WideString): WideString;
    function Get_Tag: WideString;
    function Get_Text: WideString;
    function Get_Value: OleVariant;
    procedure InsertElement(const Child: IElement; Index: Integer);
    function PostEvent(EventCode: BEHAVIOR_EVENTS): Boolean;
    procedure ScrollToView;
    function Select(const Selector: WideString): TElement;
    function SelectAll(const Selector: WideString): IElementCollection;
    function SendEvent(EventCode: BEHAVIOR_EVENTS): Boolean;
    procedure Set_Attr(const AttrName: WideString; const Value: WideString);
    procedure Set_ID(const Value: WideString);
    procedure Set_InnerHtml(const Value: WideString);
    procedure Set_OuterHtml(const Value: WideString);
    procedure Set_StyleAttr(const AttrName: WideString; const Value: WideString);
    procedure Set_Text(const Value: WideString);
    procedure Set_Value(Value: OleVariant);
    property Attr[const AttrName: WideString]: WideString read Get_Attr write Set_Attr;
    property AttrCount: Integer read GetAttrCount;
    property ChildrenCount: Integer read Get_ChildrenCount;
    property Enabled: boolean read GetEnabled;
    property Handle: Integer read Get_Handle;
    property ID: WideString read Get_ID write Set_ID;
    property Index: Integer read Get_Index;
    property InnerHtml: WideString read Get_InnerHtml write Set_InnerHtml;
    property OuterHtml: WideString read Get_OuterHtml write Set_OuterHtml;
    property Parent: IElement read Get_Parent;
    property StyleAttr[const AttrName: WideString]: WideString read Get_StyleAttr write Set_StyleAttr;
    property Tag: WideString read Get_Tag;
    property Text: WideString read Get_Text write Set_Text;
    property Value: OleVariant read Get_Value write Set_Value;
    property Visible: boolean read GetVisible;
  end;

  IElementCollection = interface
    ['{2E262CE3-43DE-4266-9424-EBA0241F77F8}']
    function Get_Count: Integer;
    function Get_Item(const Index: Integer): TElement;
    procedure RemoveAll;
    property Count: Integer read Get_Count;
    property Item[const Index: Integer]: TElement read Get_Item; default;
  end;

  TElement = class(TInterfacedObject, IElement)
  private
    FAttrAnsiName: WideString;
    FAttrName: WideString;
    FAttrValue: WideString;
    FELEMENT: HELEMENT;
    FHChild: HELEMENT;
    FHtml: WideString;
    FOnControlEvent: TElementOnControlEvent;
    FOnFocus: TElementOnFocus;
    FOnKey: TElementOnKey;
    FOnMouse: TElementOnMouse;
    FOnScroll: TElementOnScroll;
    FOnSize: TElementOnSize;
    FOnTimer: TElementOnTimer;
    FSciter: TSciter;
    FStyleAttrName: WideString;
    FStyleAttrValue: WideString;
    FTag: WideString;
    FText: WideString;
    function GetAttrCount: Integer;
    function GetEnabled: boolean;
    function GetVisible: boolean;
    function Get_Attr(const AttrName: WideString): WideString;
    function Get_ChildrenCount: Integer;
    function Get_Handle: Integer;
    function Get_ID: WideString;
    function Get_Index: Integer;
    function Get_InnerHtml: WideString;
    function Get_OnControlEvent: TElementOnControlEvent;
    function Get_OnFocus: TElementOnFocus;
    function Get_OnKey: TElementOnKey;
    function Get_OnMouse: TElementOnMouse;
    function Get_OnScroll: TElementOnScroll;
    function Get_OnSize: TElementOnSize;
    function Get_OnTimer: TElementOnTimer;
    function Get_OuterHtml: WideString;
    function Get_Parent: IElement;
    function Get_StyleAttr(const AttrName: WideString): WideString;
    function Get_Tag: WideString;
    function Get_Text: WideString;
    function Get_Value: OleVariant;
    procedure Set_Attr(const AttrName: WideString; const Value: WideString);
    procedure Set_ID(const Value: WideString);
    procedure Set_InnerHtml(const Value: WideString);
    procedure Set_OnControlEvent(const Value: TElementOnControlEvent);
    procedure Set_OnFocus(const Value: TElementOnFocus);
    procedure Set_OnKey(const Value: TElementOnKey);
    procedure Set_OnMouse(const Value: TElementOnMouse);
    procedure Set_OnScroll(const Value: TElementOnScroll);
    procedure Set_OnSize(const Value: TElementOnSize);
    procedure Set_OnTimer(const Value: TElementOnTimer);
    procedure Set_OuterHtml(const Value: WideString);
    procedure Set_StyleAttr(const AttrName: WideString; const Value: WideString);
    procedure Set_Text(const Value: WideString);
    procedure Set_Value(Value: OleVariant);
  protected
    constructor Create(ASciter: TSciter; h: HELEMENT); virtual;
    function HandleBehaviorEvents(params: PBEHAVIOR_EVENT_PARAMS): BOOL; virtual;
    function HandleFocus(params: PFOCUS_PARAMS): BOOL; virtual;
    function HandleInitialization(params: PINITIALIZATION_PARAMS): BOOL; virtual;
    function HandleKey(params: PKEY_PARAMS): BOOL; virtual;
    function HandleMethodCallEvents(params: PMETHOD_PARAMS): BOOL; virtual;
    function HandleMouse(params: PMOUSE_PARAMS): BOOL; virtual;
    function HandleScriptingCall(params: PSCRIPTING_METHOD_PARAMS): UINT; overload; virtual;
    function HandleScriptingCall(params: PTISCRIPT_METHOD_PARAMS): UINT; overload; virtual;
    function HandleScrollEvents(params: PSCROLL_PARAMS): BOOL; virtual;
    function HandleSize: BOOL; virtual;
    function HandleTimer(params: PTIMER_PARAMS): BOOL; virtual;
    function IsValid: Boolean;
    procedure ThrowException(const Message: AnsiString); overload; 
    procedure ThrowException(const Message: AnsiString; const Args: Array of const); overload;
    property Sciter: TSciter read FSciter;
  public
    destructor Destroy; override;
    procedure AppendChild(const Element: IElement);
    function AttachHwndToElement(h: HWND): boolean;
    procedure ClearAttributes;
    function CloneElement: TElement;
    function CreateElement(const Tag: WideString; const Text: WideString): IElement;
    procedure Delete;
    function Equals(const Element: IElement): WordBool;
    function FindNearestParent(const Selector: WideString): TElement;
    function GetAttributeName(Index: Integer): WideString;
    function GetAttributeValue(Index: Integer): WideString; overload;
    function GetAttributeValue(const Name: WideString): WideString; overload;
    function GetChild(Index: Integer): IElement;
    procedure InsertElement(const Child: IElement; Index: Integer);
    function PostEvent(EventCode: BEHAVIOR_EVENTS): Boolean;
    procedure ScrollToView;
    function Select(const Selector: WideString): TElement;
    function SelectAll(const Selector: WideString): IElementCollection;
    function SendEvent(EventCode: BEHAVIOR_EVENTS): Boolean;
    property Attr[const AttrName: WideString]: WideString read Get_Attr write Set_Attr;
    property AttrCount: Integer read GetAttrCount;
    property ChildrenCount: Integer read Get_ChildrenCount;
    property Enabled: boolean read GetEnabled;
    property Handle: Integer read Get_Handle;
    property ID: WideString read Get_ID write Set_ID;
    property InnerHtml: WideString read Get_InnerHtml write Set_InnerHtml;
    property OuterHtml: WideString read Get_OuterHtml write Set_OuterHtml;
    property StyleAttr[const AttrName: WideString]: WideString read Get_StyleAttr write Set_StyleAttr;
    property Tag: WideString read Get_Tag;
    property Text: WideString read Get_Text write Set_Text;
    property Value: OleVariant read Get_Value write Set_Value;
    property Visible: boolean read GetVisible;
    property OnControlEvent: TElementOnControlEvent read Get_OnControlEvent write Set_OnControlEvent;
    property OnFocus: TElementOnFocus read Get_OnFocus write Set_OnFocus;
    property OnKey: TElementOnKey read Get_OnKey write Set_OnKey;
    property OnMouse: TElementOnMouse read Get_OnMouse write Set_OnMouse;
    property OnScroll: TElementOnScroll read Get_OnScroll write Set_OnScroll;
    property OnSize: TElementOnSize read Get_OnSize write Set_OnSize;
    property OnTimer: TElementOnTimer read Get_OnTimer write Set_OnTimer;
  end;

  TElementList = class(TObjectList)
  private
    function GetItem(const Index: Integer): TElement;
  protected
    procedure Add(const Element: TElement);
    procedure Remove(const Element: TElement);
    property Item[const Index: Integer]: TElement read GetItem; default;
  end;

  TElementCollection = class(TInterfacedObject, IElementCollection)
  private
    FList: TObjectList;
    FSciter: TSciter;
  protected
    constructor Create(ASciter: TSciter);
    function Get_Count: Integer;
    function Get_Item(const Index: Integer): TElement;
    property Sciter: TSciter read FSciter;
  public
    destructor Destroy; override;
    procedure Add(const Item: TElement);
    procedure RemoveAll;
    property Count: Integer read Get_Count;
    property Item[const Index: Integer]: TElement read Get_Item;
  end;

  TSciter = class(TCustomControl)
  private
    FBaseUrl: WideString;
    FHomeURL: WideString;
    FHtml: WideString;
    FInnerList: TElementList;
    FOnDataLoaded: TSciterOnDataLoaded;
    FOnDocumentComplete: TSciterOnDocumentComplete;
    FOnEngineDestroyed: TNotifyEvent;
    FOnHandleCreated: TNotifyEvent;
    FOnLoadData: TSciterOnLoadData;
    FOnMethodCall: TSciterOnMethodCall;
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
    function DesignMode: boolean;
    procedure DestroyWnd; override;
    function HandleAttachBehavior(data: LPSCN_ATTACH_BEHAVIOR): UINT; virtual;
    function HandleDataLoaded(data: LPSCN_DATA_LOADED): UINT; virtual;
    function HandleDocumentComplete(const Url: WideString): BOOL; virtual;
    function HandleEngineDestroyed(data: LPSCN_ENGINE_DESTROYED): UINT; virtual;
    function HandleLoadData(data: LPSCN_LOAD_DATA): UINT; virtual;
    function HandlePostedNotification(data: LPSCN_POSTED_NOTIFICATION): UINT; virtual;
    function HandleScriptingCall(params: PSCRIPTING_METHOD_PARAMS): BOOL; overload; virtual;
    function HandleScriptingCall(params: PTISCRIPT_METHOD_PARAMS): BOOL; overload; virtual;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
    procedure SetName(const NewName: TComponentName); override;
    procedure SetParent(AParent: TWinControl); override;
    procedure WndProc(var Message: TMessage); override;
    property InnerList: TElementList read FInnerList;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AppendMasterCSS(const Value: WideString);
    function Call(const FunctionName: WideString; const Args: array of OleVariant): OleVariant;
    function Eval(const Script: WideString): OleVariant;
    function FilePathToURL(const FileName: AnsiString): AnsiString;
    function FindElement(Point: TPoint): IElement;
    function FindElement2(X, Y: Integer): IElement;
    procedure GC;
    function GetElementByHandle(Handle: Integer): IElement;
    function GetMinHeight(Width: Integer): Integer;
    function GetMinWidth: Integer;
    procedure LoadHtml(const Html: WideString; const BaseURL: WideString);
    function LoadURL(const URL: WideString): Boolean;
    procedure MouseWheelHandler(var Message: TMessage); override;
    procedure RegisterComObject(const Name: WideString; const Obj: IDispatch);
    function RegisterNativeClass(ClassDef: ptiscript_class_def; ThrowIfExists: Boolean; ReplaceClassDef: Boolean { reserved } = False): tiscript_value;
    procedure RegisterNativeFunction(const Name: WideString; Handler: ptiscript_method);
    function Select(const Selector: WideString): TElement;
    function SelectAll(const Selector: WideString): IElementCollection;
    procedure SetHomeURL(const URL: WideString);
    procedure SetMasterCSS(const Value: WideString);
    procedure UpdateWindow;
    property Html: WideString read Get_Html;
    property Root: TElement read Get_Root;
    property VM: HVM read GetHVM;
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
    property OnDataLoaded: TSciterOnDataLoaded read FOnDataLoaded write FOnDataLoaded;
    property OnDocumentComplete: TSciterOnDocumentComplete read FOnDocumentComplete write FOnDocumentComplete;
    property OnEngineDestroyed: TNotifyEvent read FOnEngineDestroyed write FOnEngineDestroyed;
    property OnHandleCreated: TNotifyEvent read FOnHandleCreated write FOnHandleCreated;
    property OnLoadData: TSciterOnLoadData read FOnLoadData write FOnLoadData;
    property OnMethodCall: TSciterOnMethodCall read FOnMethodCall write FOnMethodCall;
    property OnStdErr: TSciterOnStdErr read FOnStdErr write SetOnStdErr;
    property OnStdOut: TSciterOnStdOut read FOnStdOut write SetOnStdOut;
    property OnStdWarn: TSciterOnStdOut read FOnStdWarn write SetOnStdWarn;
end;

procedure SciterDebug(param: Pointer; subsystem: UINT; severity: UINT; text: PWideChar; text_length: UINT); stdcall;
function LoadResourceAsStream(const ResName: AnsiString; const ResType: AnsiString): TCustomMemoryStream;
function LoadResourceAsAnsiString(ResName: PAnsiChar; ResType: PAnsiChar): AnsiString; overload;
function LoadResourceAsAnsiString(ResID: integer; ResType: PAnsiChar): AnsiString; overload;
function LoadResourceAsWideString(ResID: integer; ResType: PAnsiChar): WideString;

procedure Register;

implementation

uses SciterOle;

function LoadResourceAsAnsiString(ResName: PAnsiChar; ResType: PAnsiChar): AnsiString;
var
  pStream: TResourceStream;
  pStringStream: TStringStream;
begin
  pStream := nil;
  pStringStream := nil;
  try
    pStream := TResourceStream.Create(HInstance, ResName, ResType);
    pStream.Position := 0;
    pStringStream := TStringStream.Create('');
    pStringStream.CopyFrom(pStream, pStream.Size);
    Result := pStringStream.DataString;
  finally
    if pStringStream <> nil then
      pStringStream.Free;
    if pStream <> nil then
      pStream.Free;
  end;
end;

function LoadResourceAsStream(const ResName: AnsiString; const ResType: AnsiString): TCustomMemoryStream;
begin
  try
    Result := TResourceStream.Create(HInstance, ResName, PAnsiChar(ResType));
    Result.Position := 0;
  except
    on E:Exception do
    begin
      Result := nil;
    end;
  end;
end;

function LoadResourceAsAnsiString(ResID: integer; ResType: PAnsiChar): AnsiString;
var
  pStream: TResourceStream;
  pStringStream: TStringStream;
begin
  pStream := nil;
  pStringStream := nil;
  try
    pStream := TResourceStream.CreateFromID(HINSTANCE, ResID, ResType);
    pStream.Position := 0;
    pStringStream := TStringStream.Create('');
    pStringStream.CopyFrom(pStream, pStream.Size);
    Result := pStringStream.DataString;
  finally
    if pStringStream <> nil then
      pStringStream.Free;
    if pStream <> nil then
      pStream.Free;
  end;
end;

function LoadResourceAsWideString(ResID: integer; ResType: PAnsiChar): WideString;
begin
  Result := UTF8Decode(LoadResourceAsAnsiString(ResID, ResType));
end;

function HostCallback(pns: LPSCITER_CALLBACK_NOTIFICATION; callbackParam: Pointer ): UINT; stdcall;
var
  pSciter: TSciter;
begin
  Result := 0;
  pSciter := TObject(callbackParam) as TSciter;
  case pns.code of
    SciterApi.SC_LOAD_DATA:
      Result := pSciter.HandleLoadData(LPSCN_LOAD_DATA(pns));
      
    SciterApi.SC_DATA_LOADED:
      Result := pSciter.HandleDataLoaded(LPSCN_DATA_LOADED(pns));

    SciterApi.SC_ATTACH_BEHAVIOR:
      Result := pSciter.HandleAttachBehavior(LPSCN_ATTACH_BEHAVIOR(pns));

    SciterApi.SC_ENGINE_DESTROYED:
      Result := pSciter.HandleEngineDestroyed(LPSCN_ENGINE_DESTROYED(pns));

    SciterApi.SC_POSTED_NOTIFICATION:
      Result := pSciter.HandlePostedNotification(LPSCN_POSTED_NOTIFICATION(pns));
  end;
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
    pElement.FTag := sStr; // implicit unicode->ascii
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
  if (str = nil) or (str_length = 0) then
  begin
    pElement.FText := '';
  end
    else
  begin
    pElement.FText := WideString(str);
  end;
end;

procedure NthAttributeNameCallback(str: PAnsiChar; str_length: UINT; param : Pointer); stdcall;
var
  pElement: TElement;
begin
  pElement := TElement(param);
  if (str_length = 0) or (str = nil) then
    pElement.FAttrAnsiName := ''
  else
    pElement.FAttrAnsiName := AnsiString(str);
end;

procedure NthAttributeValueCallback(str: PWideChar; str_length: UINT; param : Pointer); stdcall;
var
  pElement: TElement;
begin
  pElement := TElement(param);
  if (str_length = 0) or (str = nil) then
    pElement.FAttrValue := ''
  else
    pElement.FAttrValue := WideString(str);
end;

procedure AttributeTextCallback(str: PWideChar; str_length: UINT; param: Pointer); stdcall;
var
  pElement: TElement;
begin
  pElement := TElement(param);
  if (str = nil) or (str_length = 0) then
  begin
    pElement.FAttrValue := '';
  end
    else
  begin
    pElement.FAttrValue := WideString(str);
  end;
end;

procedure StyleAttributeTextCallback(str: PWideChar; str_length: UINT; param: Pointer); stdcall;
var
  pElement: TElement;
begin
  pElement := TElement(param);
  if (str = nil) or (str_length = 0) then
  begin
    pElement.FStyleAttrValue := '';
  end
    else
  begin
    pElement.FStyleAttrValue := WideString(str);
  end;
end;

function SelectorCallback(he: HELEMENT; Param: Pointer ): BOOL; stdcall;
var
  pElementCollection: TElementCollection;
  pElement: TElement;
begin
  pElementCollection := TElementCollection(Param);
  pElement := TElement.Create(pElementCollection.Sciter, he);
  pElementCollection.Add(pElement);
  Result := False; // Continue
end;

function SelectSingleNodeCallback(he: HELEMENT; Param: Pointer ): BOOL; stdcall;
var
  pElement: TElement;
begin
  pElement := TElement(Param);
  pElement.FHChild := he;
  Result := True; // Stop
end;

function WindowElementEventProc(tag: Pointer; he: HELEMENT; evtg: UINT; prms: Pointer): BOOL; stdcall;
const
  MAX_URL_LENGTH = 2048;
var
  pSciter: TSciter;
  pBehaviorEventParams: PBEHAVIOR_EVENT_PARAMS;
  pScriptingMethodParams: PSCRIPTING_METHOD_PARAMS;
  pTiScriptMethodParams: PTISCRIPT_METHOD_PARAMS;
  arrUri: array[0..MAX_URL_LENGTH] of WideChar;
  sUri: WideString;
  i: UINT;
begin
  Result := False;
  pSciter := TObject(tag) as TSciter;
  if evtg = UINT(HANDLE_BEHAVIOR_EVENT) then
  begin
    pBehaviorEventParams := prms;
    if pBehaviorEventParams.cmd = DOCUMENT_COMPLETE then
    begin
      for i := Low(arrUri) to High(arrUri) do
        arrUri[i] := WideChar(0);
      arrUri[0] := ' ';
      if API.SciterCombineURL(pBehaviorEventParams.heTarget, @arrUri[0], MAX_URL_LENGTH) = SCDOM_OK then
        sUri := arrUri
      else
        sUri := '';
      Result := pSciter.HandleDocumentComplete(sUri);
    end;
  end

  else if evtg = UINT(HANDLE_SCRIPTING_METHOD_CALL) then
  begin
    pScriptingMethodParams := prms;
    Result := pSciter.HandleScriptingCall(pScriptingMethodParams);
  end

  else if evtg = UINT(HANDLE_TISCRIPT_METHOD_CALL) then
  begin
    pTiScriptMethodParams := prms;
    Result := pSciter.HandleScriptingCall(pTiScriptMethodParams);
  end;
end;

function ElementEventProc(tag: Pointer; he: HELEMENT; evtg: UINT; prms: Pointer): BOOL; stdcall;
var
  pElement: TElement;
  pInitParams: PINITIALIZATION_PARAMS;
  pMouseParams: PMOUSE_PARAMS;
  pKeyParams: PKEY_PARAMS;
  pFocusParams: PFOCUS_PARAMS;
  pTimerParams: PTIMER_PARAMS;
  pBehaviorEventParams: PBEHAVIOR_EVENT_PARAMS;
  pMethodCallParams: PMETHOD_PARAMS;
  pScrollParams: PSCROLL_PARAMS;
begin
  Result := False;

  if prms = nil then Exit;
  if tag = nil then Exit;

  pElement := TObject(tag) as TElement;
  if pElement = nil then Exit;

  case EVENT_GROUPS(evtg) of
    HANDLE_INITIALIZATION:
    begin
      pInitParams := prms;
      Result := pElement.HandleInitialization(pInitParams);
    end;

    HANDLE_MOUSE:
    begin
      pMouseParams := prms;
      Result := pElement.HandleMouse(pMouseParams);
    end;

    HANDLE_KEY:
    begin
      pKeyParams := prms;
      Result := pElement.HandleKey(pKeyParams);
    end;

    HANDLE_FOCUS:
    begin
      pFocusParams := prms;
      Result := pElement.HandleFocus(pFocusParams);
    end;

    HANDLE_TIMER:
    begin
      pTimerParams := prms;
      Result := pElement.HandleTimer(pTimerParams);
    end;

    HANDLE_BEHAVIOR_EVENT:
    begin
      pBehaviorEventParams := prms;
      Result := pElement.HandleBehaviorEvents(pBehaviorEventParams);
    end;

    HANDLE_METHOD_CALL:
    begin
      pMethodCallParams := prms;
      Result := pElement.HandleMethodCallEvents(pMethodCallParams);
    end;

    HANDLE_DATA_ARRIVED:
    begin

    end;

    HANDLE_SCROLL:
    begin
      pScrollParams := prms;
      Result := pElement.HandleScrollEvents(pScrollParams);
    end;
    
    HANDLE_SIZE:
    begin
      Result := pElement.HandleSize;
    end;

    HANDLE_SCRIPTING_METHOD_CALL:
    begin

    end;

    HANDLE_TISCRIPT_METHOD_CALL:
    begin

    end;

    HANDLE_GESTURE:
    begin

    end;
  end;
end;

constructor TSciter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FInnerList := TElementList.Create(False);
  Width := 300;
  Height := 300;
  TabStop := True;
  Caption := 'Sciter';
end;

destructor TSciter.Destroy;
var
  i: Integer;
begin
  for i := FInnerList.Count - 1 downto 0 do
  begin
    FInnerList[i].Free;
  end;
  FInnerList.Clear;
  FInnerList.Free;
  inherited;
end;

procedure TSciter.AppendMasterCSS(const Value: WideString);
var
  sUTF8: UTF8String;
begin
  sUTF8 := UTF8Encode(Value);
  if not API.SciterAppendMasterCSS(PAnsiChar(sUTF8), Length(sUTF8)) then
    raise ESciterException.Create('Failed to append a string to Sciter master CSS');
end;

function TSciter.Call(const FunctionName: WideString;
  const Args: array of OleVariant): OleVariant;
var
  pVal: TSciterValue;
  sFunctionName: AnsiString;
  pArgs: array[0..255] of TSciterValue;
  cArgs: Integer;
  i: Integer;
begin
  sFunctionName := FunctionName;
  API.ValueInit(@pVal);

  cArgs := Length(Args);

  for i := Low(pArgs) to High(pArgs) do
    API.ValueInit(@pArgs[i]);

  for i := Low(Args) to High(Args) do
  begin
    V2S(Args[i], @pArgs[i]);
  end;

  if API.SciterCall(Handle, PAnsiChar(sFunctionName), cArgs, @pArgs[0], pVal) then
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
end;

procedure TSciter.CreateWnd;
var
  SR: SCDOM_RESULT;
begin
  inherited CreateWnd;

  if DesignMode then
    Exit;

  if HandleAllocated then
  begin
    API.SciterSetCallback(Handle, @HostCallback, Self);

    SR := API.SciterWindowAttachEventHandler(Handle, @WindowElementEventProc, Self, UINT(HANDLE_ALL));
    if SR <> SCDOM_OK then
      raise ESciterException.Create('Failed to setup Sciter window element callback function.');

    API.SciterSetupDebugOutput(Handle, Self, @SciterDebug);

    API.SciterSetHomeURL(Handle, PWideChar(FHomeURL));

    if FHtml <> '' then
    begin
      LoadHtml(FHtml, FBaseUrl);
    end
      else
    if FUrl <> '' then
    begin
      LoadURL(FUrl);
    end;
    if Assigned(FOnHandleCreated) then
      FOnHandleCreated(Self);
  end;
end;

function TSciter.DesignMode: boolean;
begin
  Result := csDesigning in ComponentState;
end;

procedure TSciter.DestroyWnd;
var
  pbHandled: Integer;
begin
  API.SciterSetCallback(Handle, nil, nil);
  API.SciterWindowAttachEventHandler(Handle, nil, nil, UINT(HANDLE_ALL));
  API.SciterSetupDebugOutput(Handle, nil, nil);
  API.SciterProcND(Handle, WM_DESTROY, 0, 0, pbHandled);
  inherited;
end;

function TSciter.Eval(const Script: WideString): OleVariant;
var
  pVal: TSciterValue;
  pResult: OleVariant;
begin
  if API.SciterEval(Handle, PWideChar(Script), Length(Script), pVal)  then
    S2V(@pVal, pResult)
  else
    pResult := Unassigned;
  Result := pResult;
end;

function TSciter.FilePathToURL(const FileName: AnsiString): AnsiString;
begin
  Result := 'file:///' + StringReplace(FileName, '\', '/', [rfReplaceAll]);
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
      pResult := TElement.Create(Self, hResult);
      Result := pResult;
    end;
  end;
end;

function TSciter.FindElement2(X, Y: Integer): IElement;
var
  pP: TPoint;
begin
  pP.X := X;
  pP.Y := Y;
  Result := FindElement(pP);
end;

procedure TSciter.GC;
begin
  NI.invoke_gc(VM);
end;

function TSciter.GetElementByHandle(Handle: Integer): IElement;
begin
  Result := TElement.Create(Self, HELEMENT(Handle));
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
var
  pRoot: TElement;
begin
  pRoot := Get_Root;
  if pRoot = nil then
  begin
    Result := ''
  end
    else
  begin
    Result := pRoot.OuterHtml;
    pRoot.Free;
  end;
end;

function TSciter.Get_Root: TElement;
var
  he: HELEMENT;
  h: HWND;
begin
  he := nil;
  h := Self.Handle;
  if API.SciterGetRootElement(h, he) = SCDOM_OK then
    Result := TElement.Create(Self, he)
  else
    Result := nil;
end;

function TSciter.HandleAttachBehavior(data: LPSCN_ATTACH_BEHAVIOR): UINT;
begin
  Result := 0;
end;

function TSciter.HandleDataLoaded(data: LPSCN_DATA_LOADED): UINT;
begin
  if Assigned(FOnDataLoaded) then
    FOnDataLoaded(Self, WideString(data.uri), data.dataType, data.data, data.dataSize, 0);
  Result := 0;
end;

function TSciter.HandleDocumentComplete(const Url: WideString): BOOL;
begin
  Result := False;
  if Assigned(FOnDocumentComplete) then
    FOnDocumentComplete(Self, Url);
end;

function TSciter.HandleEngineDestroyed(data: LPSCN_ENGINE_DESTROYED): UINT;
begin
  if data.hwnd = Handle then
  begin
    if Assigned(FOnEngineDestroyed) then
      FOnEngineDestroyed(Self);
  end;
  Result := 0;
end;

function TSciter.HandleLoadData(data: LPSCN_LOAD_DATA): UINT;
var
  discard: WordBool;
  wUrl: WideString;
  wResName: WideString;
  pStream: TCustomMemoryStream;
begin
  Result := LOAD_OK;

  wUrl := WideString(data.uri);

  // Hadling res: URL scheme
  if Pos('res:', wUrl) = 1 then
  begin
    wResName := StringReplace(wUrl, 'res:', '', []);
    wResName := StringReplace(wResName, '-', '_', [rfReplaceAll]);
    wResName := StringReplace(wResName, '.', '_', [rfReplaceAll]);
    pStream := LoadResourceAsStream(wResName, 'HTML');
    if pStream <> nil then
    begin
      API.SciterDataReady(Handle, data.uri, pStream.Memory, pStream.Size);
      Result := LOAD_OK;
      pStream.Free;
      Exit;
    end;
  end
    else
  begin
    if Assigned(FOnLoadData) then
    begin
      FOnLoadData(Self, WideString(data.uri), data.dataType, Integer(data.requestId), discard);
      if discard then
        Result := LOAD_DISCARD;
    end;
  end;
end;

function TSciter.HandlePostedNotification(
  data: LPSCN_POSTED_NOTIFICATION): UINT;
begin
  Result := 0;
end;

function TSciter.HandleScriptingCall(
  params: PSCRIPTING_METHOD_PARAMS): BOOL;
var
  pArgs: array of OleVariant;
  sMethodName: WideString;
  pResult: OleVariant;
  bHandled: Boolean;
  pSciterVal: PSciterValue;
  i: Integer;
begin
  Result := False;
  bHandled := False;

  if Assigned(FOnMethodCall) then
  try
    sMethodName := WideString(AnsiString(params.name));
    SetLength(pArgs, params.argc);
    pSciterVal := params.argv;
    for i := 0 to params.argc - 1 do
    begin
      S2V(pSciterVal, pArgs[i]);
      Inc(pSciterVal);
    end;
    FOnMethodCall(Self, sMethodName, pArgs, pResult, bHandled);
    if bHandled then
      V2S(pResult, @params.result);
    Result := bHandled;
  except
    Exit;
  end;
end;

function TSciter.HandleScriptingCall(
  params: PTISCRIPT_METHOD_PARAMS): BOOL;
begin
  Result := False;
  Exit;
  { Don't know how to get method name! }
  { if method returns False then overloaded HandleScriptingCall(params: PSCRIPTING_METHOD_PARAMS) will be called }

  {
  if Assigned(FOnMethodCall) then
  try
    tname := NI.to_string(params.vm, params.tag);
    sMethodName := T2V(vm, tname);
    iArgc := NI.get_arg_count(params.vm);
    SetLength(pArgs, iArgc);
    for i := 0 to iArgc - 1 do
    begin
      tval := NI.get_arg_n(vm, i);
      if NI.is_object(tval) then
        oArg := Unassigned
      else
        oArg := T2V(vm, tval);
      pArgs[i] := oArg;
    end;
    FOnMethodCall(Self, sMethodName, pArgs, pResult, bHandled);
    if bHandled then
      params.result := V2T(vm, pResult);
    Result := bHandled;
  except
  end;
  }
end;

procedure TSciter.LoadHtml(const Html: WideString; const BaseURL: WideString);
var
  sHtml: AnsiString;
  pHtml: PAnsiChar;
  iLen: UINT;
begin
  FHtml := Html;
  sHtml := UTF8Encode(Html);
  pHtml := PAnsiChar(sHtml);
  iLen := Length(sHtml);
  FBaseUrl := BaseURL;

  FUrl := '';

  if HandleAllocated then
  begin
    if not API.SciterLoadHtml(Handle, PByte(pHtml), iLen, PWideChar(BaseURL)) then
      raise ESciterException.CreateFmt('Failed to load HTML.', []);
  end;
end;

function TSciter.LoadURL(const URL: WideString): Boolean;
begin
  Result := False;
  if DesignMode then
    Exit;

  FUrl := URL;
  FHtml := '';
  FBaseUrl := '';

  if HandleAllocated then
  begin
    // if not API.SciterLoadFile(Handle, PWideChar(URL)) then
    //  raise ESciterException.CreateFmt('Failed to load URL %s', [URL]);
    Result := API.SciterLoadFile(Handle, PWideChar(URL));
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

procedure TSciter.Paint;
var
  sCaption: AnsiString;
  iWidth: Integer;
  iHeight: Integer;
  X, Y: Integer;
  pIcon: TBitmap;
  hBmp: HBITMAP;
begin
  inherited;

  if DesignMode then
  begin
    sCaption := Name;
     
    pIcon := nil;
    
    hBMP := LoadBitmap(hInstance, 'TSCITER');
    if hBMP <> 0 then
    begin
      pIcon := TBitmap.Create;
      pIcon.Handle := hBMP;
    end;
    
    Canvas.Brush.Color := clWindow;
    iWidth := Canvas.TextWidth(sCaption) + 28;
    iHeight := Max(Canvas.TextHeight(sCaption), 28);
    X := Round(ClientWidth / 2) - Round(iWidth / 2);
    Y := Round(ClientHeight / 2) - Round(iHeight / 2);
    Canvas.FillRect(ClientRect);

    if pIcon <> nil then
      Canvas.Draw(X, Y, pIcon);
      
    Canvas.TextOut(X + 28, Y + 5, Name);

    if pIcon <> nil then
    begin
      pIcon.Free;
    end;

    if hBmp <> 0 then
      DeleteObject(hBmp);
  end;
end;

procedure TSciter.RegisterComObject(const Name: WideString;
  const Obj: IDispatch);
var
  vm: TiScriptApi.HVM;
begin
  vm := API.SciterGetVM(Handle);
  SciterOle.RegisterOleObject(vm, Obj, Name);
end;

function TSciter.RegisterNativeClass(ClassDef: ptiscript_class_def; ThrowIfExists: Boolean; ReplaceClassDef: Boolean): tiscript_value;
var
  vm: HVM;
begin
  vm := API.SciterGetVM(Handle);
  Result := SciterAPI.RegisterNativeClass(vm, ClassDef, ThrowIfExists, ReplaceClassDef);
end;

procedure TSciter.RegisterNativeFunction(const Name: WideString;
  Handler: ptiscript_method);
begin
  SciterAPI.RegisterNativeFunction(VM, Name, Handler);
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

procedure TSciter.SetHomeURL(const URL: WideString);
begin
  FHomeURL := URL;
  if HandleAllocated then
  begin
    API.SciterSetHomeURL(Handle, PWideChar(URL));
  end;
end;

procedure TSciter.SetMasterCSS(const Value: WideString);
var
  sUTF8: UTF8String;
begin
  sUTF8 := UTF8Encode(Value);
  if not API.SciterSetMasterCSS(PAnsiChar(sUTF8), Length(sUTF8)) then
    raise ESciterException.Create('Failed to set Sciter master CSS');
end;

procedure TSciter.SetName(const NewName: TComponentName);
begin
  inherited;
  Invalidate;
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
  if not DesignMode then
  begin
    // Tweaking arrow keys and TAB handling (VCL-specific)
    if Message.Msg = WM_GETDLGCODE then
    begin
      Message.Result := DLGC_WANTALLKEYS or DLGC_WANTTAB or DLGC_WANTARROWS or DLGC_WANTCHARS or DLGC_HASSETSEL;
      if Message.lParam <> 0 then
      begin
        M := PMsg(Message.lParam);
        case M.Message of
          WM_KEYDOWN, WM_KEYUP, WM_CHAR:
          begin
            Perform(M.message, M.wParam, M.lParam);
            Message.Result := Message.Result or DLGC_WANTMESSAGE or DLGC_WANTTAB;
          end;
        end;
      end;
      Exit;
    end;

    if HandleAllocated then
    begin
      llResult := API.SciterProcND(Handle, Message.Msg, Message.WParam, Message.LParam, bHandled);
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
  end
    else
  begin
    inherited WndProc(Message);
  end
end;

constructor TElement.Create(ASciter: TSciter; h: HELEMENT);
begin
  if h = nil then
    ThrowException('Invalid element handle.', []);
  FSciter := ASciter;
  Self.FELEMENT := h;
  API.Sciter_UseElement(FElement);
  API.SciterAttachEventHandler(Self.FElement, @ElementEventProc, Self);
  FSciter.InnerList.Add(Self);
end;

destructor TElement.Destroy;
begin
  API.SciterDetachEventHandler(Self.FElement, @ElementEventProc, Self);
  API.Sciter_UnuseElement(FElement);
  if FSciter.InnerList.IndexOf(Self) >= 0 then
    FSciter.InnerList.Remove(Self);
  inherited;
end;

{ TElement }
procedure TElement.AppendChild(const Element: IElement);
begin
  InsertElement(Element, MaxInt);
end;

function TElement.AttachHwndToElement(h: HWND): boolean;
begin
  Result := API.SciterAttachHwndToElement(FElement, h) = SCDOM_OK;
end;

procedure TElement.ClearAttributes;
begin
  API.SciterClearAttributes(FElement);
end;

function TElement.CloneElement: TElement;
var
  phe: HELEMENT;
begin
  Result := nil;
  if API.SciterCloneElement(FElement, phe) = SCDOM_OK then
    Result := TElement.Create(Self.Sciter, phe);
end;

function TElement.CreateElement(const Tag: WideString; const Text: WideString): IElement;
var
  pElement: TElement;
  pHandle: HELEMENT;
  sTag: AnsiString;
begin
  sTag := Tag;
  API.SciterCreateElement(PAnsiChar(sTag), PWideChar(Text), pHandle);
  pElement := TElement.Create(Self.Sciter, pHandle);
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

function TElement.FindNearestParent(const Selector: WideString): TElement;
var
  pHE: HELEMENT;
  SR: SCDOM_RESULT;
begin
  pHE := nil;
  SR := API.SciterSelectParentW(FElement, PWideChar(Selector), 0, pHE);
  if (SR <> SCDOM_OK) or (pHE = nil) then
    Result := nil
  else
    Result := TElement.Create(Sciter, pHE);
end;

function TElement.GetAttrCount: Integer;
var
  Cnt: UINT;
begin
  API.SciterGetAttributeCount(FElement, Cnt);
  Result := Integer(Cnt);
end;

function TElement.GetAttributeName(Index: Integer): WideString;
var
  nCnt: UINT;
begin
  API.SciterGetAttributeCount(FElement, nCnt);
  if Index >= nCnt then
    ThrowException('Attribute index (%d) is out of range.', [Index]);
    
  if API.SciterGetNthAttributeNameCB(FElement, Index, @NThAttributeNameCallback, Self) = SCDOM_OK then
    Result := WideString(Self.FAttrAnsiName)
  else
    ThrowException('Failed to get attribute name.');
end;

function TElement.GetAttributeValue(Index: Integer): WideString;
var
  nCnt: UINT;
begin
  API.SciterGetAttributeCount(FElement, nCnt);
  if Index >= nCnt then
    ThrowException('Attribute index (%d) is out of range.', [Index]);

  if API.SciterGetNthAttributeValueCB(FElement, Index, @NThAttributeValueCallback, Self) = SCDOM_OK then
    Result := Self.FAttrValue
  else
    ThrowException('Failed to get attribute value.');
end;

function TElement.GetAttributeValue(const Name: WideString): WideString;
begin
  Result := Get_Attr(Name);
end;

function TElement.GetChild(Index: Integer): IElement;
var
  hResult: HELEMENT;
  pResult: TElement;
  nCnt: UINT;
  SR: SCDOM_RESULT;
begin
  API.SciterGetChildrenCount(FElement, nCnt);
  if Index >= nCnt then
    ThrowException('Child element index (%d) is out of range.', [Index]);

  SR := API.SciterGetNthChild(FElement, UINT(Index), hResult);
  if SR <> SCDOM_OK then
    ThrowException('Failed to get child element with index %d.', [Index]);
    
  if hResult = nil then
    Result := nil
  else
  begin
    pResult := TElement.Create(Self.Sciter, hResult);
    Result := pResult;
  end;
end;

function TElement.GetEnabled: boolean;
var
  pResult: LongBool;
begin
  API.SciterIsElementEnabled(FELEMENT, pResult);
  Result := pResult;
end;

function TElement.GetVisible: boolean;
var
  pResult: LongBool;
begin
  API.SciterIsElementVisible(FELEMENT, pResult);
  Result := pResult;
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

function TElement.Get_ID: WideString;
begin
  Result := Attr['id'];
end;

function TElement.Get_Index: Integer;
var
  pResult: UINT;
begin
  pResult := 0;
  if API.SciterGetElementIndex(FElement, pResult) <> SCDOM_OK then
    ThrowException('Failed to get element index.');
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

function TElement.Get_OnFocus: TElementOnFocus;
begin
  Result := FOnFocus;
end;

function TElement.Get_OnKey: TElementOnKey;
begin
  Result := FOnKey;
end;

function TElement.Get_OnMouse: TElementOnMouse;
begin
  Result := FOnMouse;
end;

function TElement.Get_OnScroll: TElementOnScroll;
begin
  Result := FOnScroll;
end;

function TElement.Get_OnSize: TElementOnSize;
begin
  Result := FOnSize;
end;

function TElement.Get_OnTimer: TElementOnTimer;
begin
  Result := FOnTimer;
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
    pResult := TElement.Create(Self.Sciter, pParent);
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

function TElement.HandleBehaviorEvents(
  params: PBEHAVIOR_EVENT_PARAMS): BOOL;
var
  pSource: TElement;
  pTarget: TElement;
begin
  Result := False;
  if Assigned(FOnControlEvent) then
  begin
    if params.heTarget <> nil then
      pTarget := TElement.Create(Self.Sciter, params.heTarget)
    else
      pTarget := nil;
    if params.he <> nil then
      pSource := TElement.Create(Self.Sciter, params.he)
    else
      pSource := nil;

    FOnControlEvent(Sciter, pTarget, params.cmd, Integer(params.reason), pSource);

    if pSource <> nil then
      pSource.Free;
    if pTarget <> nil then
      pTarget.Free;
  end;
end;

function TElement.HandleFocus(params: PFOCUS_PARAMS): BOOL;
var
  pTarget: TElement;
begin
  Result := False;
  pTarget := nil;
  if Assigned(FOnFocus) then
  begin
    if params.target <> nil then
      pTarget := TElement.Create(Self.Sciter, params.target);
    FOnFocus(Sciter, pTarget, params.cmd);
    if pTarget <> nil then
      pTarget.Free;
  end;
end;

function TElement.HandleInitialization(
  params: PINITIALIZATION_PARAMS): BOOL;
begin
  Result := False;
end;

function TElement.HandleKey(params: PKEY_PARAMS): BOOL;
var
  pTarget: TElement;
begin
  Result := False;
  pTarget := nil;
  if Assigned(FOnKey) then
  begin
    if params.target <> nil then
      pTarget := TElement.Create(Self.Sciter, params.target);
    FOnKey(Sciter, pTarget, params.cmd, params.key_code, params.alt_state);
    if pTarget <> nil then
      pTarget.Free;
  end;
end;

function TElement.HandleMethodCallEvents(params: PMETHOD_PARAMS): BOOL;
begin
  Result := False;
end;

function TElement.HandleMouse(params: PMOUSE_PARAMS): BOOL;
var
  pTarget: TElement;
begin
  Result := False;
  pTarget := nil;
  if Assigned(FOnMouse) then
  begin
    if params.target <> nil then
      pTarget := TElement.Create(Self.Sciter, params.target);
    FOnMouse(Sciter, pTarget, params.cmd, params.pos.x, params.pos.Y, params.button_state, params.alt_state);
    if pTarget <> nil then
      pTarget.Free;
  end;
end;

function TElement.HandleScriptingCall(
  params: PSCRIPTING_METHOD_PARAMS): UINT;
begin
  Result := 0;
end;

function TElement.HandleScriptingCall(
  params: PTISCRIPT_METHOD_PARAMS): UINT;
begin
  Result := 0;
end;

function TElement.HandleScrollEvents(params: PSCROLL_PARAMS): BOOL;
var
  pTarget: TElement;
begin
  pTarget := nil;
  if Assigned(FOnScroll) then
  begin
    if params.target <> nil then
      pTarget := TElement.Create(Self.Sciter, params.target);
    FOnScroll(Sciter, pTarget, params.cmd, params.pos, params.vertical);
    if pTarget <> nil then
      pTarget.Free;
  end;
  Result := False;
end;

function TElement.HandleSize: BOOL;
begin
  Result := False;
  if Assigned(FOnSize) then
  begin
    FOnSize(Sciter, Self);
  end;
end;

function TElement.HandleTimer(params: PTIMER_PARAMS): BOOL;
begin
  if Assigned(FOnTimer) then
    FOnTimer(Sciter, Integer(params.timerId));
  Result := False;
end;

procedure TElement.InsertElement(const Child: IElement; Index: Integer);
begin
  if API.SciterInsertElement(HELEMENT(Child.Handle), FElement, Index) <> SCDOM_OK then
    ThrowException('Failed to insert or append child element.');
end;

function TElement.IsValid: Boolean;
begin
  Result := FElement <> nil;
end;

function TElement.PostEvent(EventCode: BEHAVIOR_EVENTS): Boolean;
begin
  Result := API.SciterPostEvent(FELEMENT, UINT(EventCode), nil, nil) = SCDOM_OK;
end;

procedure TElement.ScrollToView;
begin
  API.SciterScrollToView(FElement, 0);
end;

function TElement.Select(const Selector: WideString): TElement;
begin
  FHChild := nil;
  Result := nil;
  if API.SciterSelectElementsW(FELEMENT, PWideChar(Selector), @SelectSingleNodeCallback, Self) = SCDOM_OK then
  begin
    if FHChild <> nil then
      Result := TElement.Create(Sciter, FHChild)
    else
      Result := nil;
  end
    else
  ThrowException('The Select method failed. Check selector expression syntax.');
end;

function TElement.SelectAll(const Selector: WideString): IElementCollection;
var
  pResult: TElementCollection;
begin
  pResult := TElementCollection.Create(Self.Sciter);
  if API.SciterSelectElementsW(FELEMENT, PWideChar(Selector), @SelectorCallback, pResult) = SCDOM_OK then
    Result := pResult
  else
    ThrowException('The Select method failed. Check selector expression syntax.');
end;

function TElement.SendEvent(EventCode: BEHAVIOR_EVENTS): Boolean;
var
  handled: BOOL;
begin
  Result := API.SciterSendEvent(FELEMENT, UINT(EventCode), nil, nil, handled) = SCDOM_OK;
end;

procedure TElement.Set_Attr(const AttrName, Value: WideString);
var
  sAttrName: AnsiString;
begin
  sAttrName := AttrName;
  if API.SciterSetAttributeByName(FElement, PAnsiChar(sAttrName), PWideChar(Value)) <> SCDOM_OK then
    ThrowException('Failed to set "%s" attribute value.', [AttrName]);
end;

procedure TElement.Set_ID(const Value: WideString);
begin
  Attr['id'] := Value;
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
  if API.SciterSetElementHtml(FElement, PByte(pStr), iLen, SIH_REPLACE_CONTENT) <> SCDOM_OK then
    ThrowException('Failed to set the inner html property on element');
end;

procedure TElement.Set_OnControlEvent(const Value: TElementOnControlEvent);
begin
  FOnControlEvent := Value;
end;

procedure TElement.Set_OnFocus(const Value: TElementOnFocus);
begin
  FOnFocus := Value;
end;

procedure TElement.Set_OnKey(const Value: TElementOnKey);
begin
  FOnKey := Value;
end;

procedure TElement.Set_OnMouse(const Value: TElementOnMouse);
begin
  FOnMouse := Value;
end;

procedure TElement.Set_OnScroll(const Value: TElementOnScroll);
begin
  FOnScroll := Value;
end;

procedure TElement.Set_OnSize(const Value: TElementOnSize);
begin
  FOnSize := Value;
end;

procedure TElement.Set_OnTimer(const Value: TElementOnTimer);
begin
  FOnTimer := Value;
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
  if API.SciterSetElementHtml(FElement, PByte(pStr), iLen, SOH_REPLACE) <> SCDOM_OK then
    ThrowException('Failed to set the outer html property on element');
end;

procedure TElement.Set_StyleAttr(const AttrName, Value: WideString);
var
  sStyleAttrName: AnsiString;
  hr: SCDOM_RESULT;
begin
  sStyleAttrName := AttrName;
  hr := API.SciterSetStyleAttribute(FElement, PAnsiChar(sStyleAttrName), PWideChar(Value));
  if hr <> SCDOM_OK then
    ThrowException('Failed to set style attribute.');
end;

procedure TElement.Set_Text(const Value: WideString);
var
  hr: SCDOM_RESULT;
begin
  hr := API.SciterSetElementText(FElement, PWideChar(Value), Length(Value));
  if hr <> SCDOM_OK then
    ThrowException('Failed to set element text.', []);
end;

procedure TElement.Set_Value(Value: OleVariant);
var
  sValue: TSciterValue;
begin
  V2S(Value, @sValue);
  if API.SciterSetValue(FElement, @sValue) <> SCDOM_OK then
    ThrowException('Failed to set element value.', []);
end;

procedure TElement.ThrowException(const Message: AnsiString);
begin
  raise ESciterException.Create(Message);
end;

procedure TElement.ThrowException(const Message: AnsiString;
  const Args: array of const);
begin
  raise ESciterException.CreateFmt(Message, Args);
end;

constructor TElementCollection.Create;
begin
  FSciter := ASciter;
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


{ TElementList }

procedure TElementList.Add(const Element: TElement);
begin
  inherited Add(Element);
end;

function TElementList.GetItem(const Index: Integer): TElement;
begin
  Result := inherited GetItem(Index) as TElement;
end;

procedure TElementList.Remove(const Element: TElement);
begin
  if inherited IndexOf(Element) <> -1 then
    inherited Remove(Element);
end;


initialization
  CoInitialize(nil);
  OleInitialize(nil);

end.
