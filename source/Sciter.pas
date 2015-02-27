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
  TElementOnMouseEventArgs = class
  private
    FButtons: MOUSE_BUTTONS;
    FEventType: MOUSE_EVENTS;
    FHandled: Boolean;
    FKeys: KEYBOARD_STATES;
    FTarget: IElement;
    FViewX: Integer;
    FViewY: Integer;
    FX: Integer;
    FY: Integer;
  public
    property Buttons: MOUSE_BUTTONS read FButtons;
    property EventType: MOUSE_EVENTS read FEventType;
    property Handled: Boolean read FHandled write FHandled;
    property Keys: KEYBOARD_STATES read FKeys;
    property Target: IElement read FTarget;
    property ViewX: Integer read FViewX;
    property ViewY: Integer read FViewY;
    property X: Integer read FX;
    property Y: Integer read FY;
  end;

  TElementOnMouse = procedure(ASender: TObject; const Args: TElementOnMouseEventArgs) of object;

  TElementOnKeyEventArgs = class
  private
    FEventType: KEY_EVENTS;
    FHandled: Boolean;
    FKeyCode: Integer;
    FKeys: KEYBOARD_STATES;
    FTarget: IElement;
  public
    property EventType: KEY_EVENTS read FEventType;
    property Handled: Boolean read FHandled write FHandled;
    property KeyCode: Integer read FKeyCode;
    property Keys: KEYBOARD_STATES read FKeys;
    property Target: IElement read FTarget;
  end;

  TElementOnKey = procedure(ASender: TObject; const Args: TElementOnKeyEventArgs) of object;

  TElementOnFocusEventArgs = class
  private
    FEventType: FOCUS_EVENTS;
    FHandled: Boolean;
    FTarget: IElement;
  public
    property EventType: FOCUS_EVENTS read FEventType;
    property Handled: Boolean read FHandled write FHandled;
    property Target: IElement read FTarget;
  end;

  TElementOnFocus = procedure(ASender: TObject; const Args: TElementOnFocusEventArgs) of object;

  TElementOnTimerEventArgs = class
  private
    FContinue: Boolean;
    FTarget: IElement;
    FTimerId: UINT;
  public
    property Continue: Boolean read FContinue write FContinue;
    property Target: IElement read FTarget;
    property TimerId: UINT read FTimerId;
  end;

  TElementOnTimer = procedure(ASender: TObject; const Args: TElementOnTimerEventArgs) of object;

  TElementOnControlEventArgs = class
  private
    FEventType: BEHAVIOR_EVENTS;
    FHandled: Boolean;
    FReason: Integer;
    FSource: IElement;
    FTarget: IElement;
  public
    property EventType: BEHAVIOR_EVENTS read FEventType;
    property Handled: Boolean read FHandled write FHandled;
    property Reason: Integer read FReason;
    property Source: IElement read FSource;
    property Target: IElement read FTarget;
  end;

  TElementOnControlEvent = procedure(ASender: TObject; const Args: TElementOnControlEventArgs) of object;

  TElementOnScrollEventArgs = class
  private
    FEventType: SCROLL_EVENTS;
    FHandled: Boolean;
    FIsVertical: Boolean;
    FPos: Integer;
    FTarget: IElement;
  public
    property EventType: SCROLL_EVENTS read FEventType;
    property Handled: Boolean read FHandled write FHandled;
    property IsVertical: Boolean read FIsVertical;
    property Pos: Integer read FPos;
    property Target: IElement read FTarget;
  end;

  TElementOnScroll = procedure(ASender: TObject; const Args: TElementOnScrollEventArgs) of object;

  TElementOnSizeEventArgs = class
  private
    FHandled: Boolean;
    FTarget: IElement;
  public
    property Handled: Boolean read FHandled write FHandled;
    property Target: IElement read FTarget;
  end;

  TElementOnSize = procedure(ASender: TObject; const Args: TElementOnSizeEventArgs) of object;

  TOleVariantArray = array of OleVariant;

  TElementOnScriptingCallArgs = class
  private
    FArgs: TOleVariantArray;
    FHandled: Boolean;
    FMethod: WideString;
    FReturnValue: OleVariant;
    FTarget: IElement;
  public
    property Args: TOleVariantArray read FArgs;
    property Handled: Boolean read FHandled write FHandled;
    property Method: WideString read FMethod;
    property ReturnValue: OleVariant read FReturnValue write FReturnValue;
    property Target: IElement read FTarget;
  end;

  TElementOnScriptingCall = procedure(ASender: TObject; const Args: TElementOnScriptingCallArgs) of object;

  TElementOnGestureEventArgs = class
  private
    FCmd: GESTURE_CMD;
    FDeltaTime: UINT;
    FDeltaV: Double;
    FDeltaXY: TSize;
    FFlags: Integer;
    FHandled: Boolean;
    FPos: TPoint;
    FPosView: TPoint;
    FTarget: IElement;
  public
    property Cmd: GESTURE_CMD read FCmd;
    property DeltaTime: UINT read FDeltaTime;
    property DeltaV: Double read FDeltaV;
    property DeltaXY: TSize read FDeltaXY;
    property Flags: Integer read FFlags;
    property Handled: Boolean read FHandled write FHandled;
    property Pos: TPoint read FPos;
    property PosView: TPoint read FPosView;
    property Target: IElement read FTarget;
  end;

  TElementOnGesture = procedure(ASender: TObject; const Args: TElementOnGestureEventArgs) of object;

  TElementOnDataArrivedEventArgs = class
  private
    FDataType: Integer;
    FHandled: Boolean;
    FInitiator: IElement;
    FStatus: Integer;
    FStream: TStream;
    FTarget: IElement;
    FUri: WideString;
  public
    property DataType: Integer read FDataType;
    property Handled: Boolean read FHandled write FHandled;
    property Initiator: IElement read FInitiator;
    property Status: Integer read FStatus;
    property Stream: TStream read FStream;
    property Target: IElement read FTarget;
    property Uri: WideString read FUri;
  end;

  TElementOnDataArrived = procedure(ASender: TObject; const Args: TElementOnDataArrivedEventArgs) of object;

  { Sciter events }
  TSciterOnMessageEventArgs = class
  private
    FMessage: WideString;
    FSeverity: OUTPUT_SEVERITY;
  public
    property Message: WideString read FMessage;
    property Severity: OUTPUT_SEVERITY read FSeverity;
  end;

  TSciterOnMessage = procedure(ASender: TObject; const Args: TSciterOnMessageEventArgs) of object;

  TSciterOnLoadData = procedure(ASender: TObject; var url: WideString; resType: SciterResourceType;
                                                  requestId: Integer; out discard: Boolean) of object;
  TSciterOnDataLoaded = procedure(ASender: TObject; const url: WideString; resType: SciterResourceType;
                                                    data: PByte; dataLength: Integer; status: Integer;
                                                    requestId: Integer) of object;
  TSciterOnDocumentComplete = procedure(ASender: TObject; const url: WideString) of object;
  TSciterOnScriptingCall = procedure(ASender: TObject; const Args: TElementOnScriptingCallArgs) of object;


  IElementEvents = interface
    ['{CC651703-89C1-411D-875E-735D48D6E311}']
    function GetOnControlEvent: TElementOnControlEvent;
    function GetOnDataArrived: TElementOnDataArrived;
    function GetOnFocus: TElementOnFocus;
    function GetOnGesture: TElementOnGesture;
    function GetOnKey: TElementOnKey;
    function GetOnMouse: TElementOnMouse;
    function GetOnScriptingCall: TElementOnScriptingCall;
    function GetOnScroll: TElementOnScroll;
    function GetOnSize: TElementOnSize;
    function GetOnTimer: TElementOnTimer;
    procedure SetOnControlEvent(const Value: TElementOnControlEvent);
    procedure SetOnDataArrived(const Value: TElementOnDataArrived);
    procedure SetOnFocus(const Value: TElementOnFocus);
    procedure SetOnGesture(const Value: TElementOnGesture);
    procedure SetOnKey(const Value: TElementOnKey);
    procedure SetOnMouse(const Value: TElementOnMouse);
    procedure SetOnScriptingCall(const Value: TElementOnScriptingCall);
    procedure SetOnScroll(const Value: TElementOnScroll);
    procedure SetOnSize(const Value: TElementOnSize);
    procedure SetOnTimer(const Value: TElementOnTimer);
    property OnControlEvent: TElementOnControlEvent read GetOnControlEvent write SetOnControlEvent;
    property OnDataArrived: TElementOnDataArrived read GetOnDataArrived write SetOnDataArrived;
    property OnFocus: TElementOnFocus read GetOnFocus write SetOnFocus;
    property OnGesture: TElementOnGesture read GetOnGesture write SetOnGesture;
    property OnKey: TElementOnKey read GetOnKey write SetOnKey;
    property OnMouse: TElementOnMouse read GetOnMouse write SetOnMouse;
    property OnScriptingCall: TElementOnScriptingCall read GetOnScriptingCall write SetOnScriptingCall;
    property OnScroll: TElementOnScroll read GetOnScroll write SetOnScroll;
    property OnSize: TElementOnSize read GetOnSize write SetOnSize;
    property OnTimer: TElementOnTimer read GetOnTimer write SetOnTimer;
  end;

  IElement = interface
    ['{E2C542D1-5B7B-4513-BFBC-7B0DD9FB04DE}']
    procedure AppendChild(const Element: IElement);
    function AttachHwndToElement(h: HWND): boolean;
    function Call(const Method: WideString; const Args: Array of OleVariant): OleVariant;
    function CloneElement: IElement;
    function CreateElement(const Tag: WideString; const Text: WideString): IElement;
    procedure Delete;
    procedure Detach;
    function EqualsTo(const Element: IElement): WordBool;
    function FindNearestParent(const Selector: WideString): IElement;
    function GetAttr(const AttrName: WideString): WideString;
    function GetAttrCount: Integer;
    function GetAttributeName(Index: Integer): WideString;
    function GetAttributeValue(Index: Integer): WideString;
    function GetChild(Index: Integer): IElement;
    function GetChildrenCount: Integer;
    function GetEnabled: boolean;
    function GetHandle: HELEMENT;
    function GetHWND: HWND;
    function GetID: WideString;
    function GetIndex: Integer;
    function GetInnerHtml: WideString;
    function GetOuterHtml: WideString;
    function GetParent: IElement;
    function GetState: Integer;
    function GetStyleAttr(const AttrName: WideString): WideString;
    function GetTag: WideString;
    function GetText: WideString;
    function GetValue: OleVariant;
    function GetVisible: boolean;
    procedure InsertElement(const Child: IElement; const Index: Integer);
    function PostEvent(EventCode: BEHAVIOR_EVENTS): Boolean;
    procedure RemoveChildren;
    procedure Request(const Url: WideString; const RequestType: REQUEST_TYPE);
    procedure ScrollToView;
    function Select(const Selector: WideString): IElement;
    function SelectAll(const Selector: WideString): IElementCollection;
    function SendEvent(EventCode: BEHAVIOR_EVENTS): Boolean;
    procedure SetAttr(const AttrName: WideString; const Value: WideString);
    procedure SetID(const Value: WideString);
    procedure SetInnerHtml(const Value: WideString);
    procedure SetOuterHtml(const Value: WideString);
    procedure SetState(const Value: Integer);
    procedure SetStyleAttr(const AttrName: WideString; const Value: WideString);
    procedure SetText(const Value: WideString);
    function SetTimer(const Milliseconds: UINT): UINT;
    procedure SetValue(Value: OleVariant);
    procedure StopTimer;
    procedure Swap(const Element: IElement);
    function TryCall(const Method: WideString; const Args: array of OleVariant; out RetVal: OleVariant): Boolean;
    property Attr[const AttrName: WideString]: WideString read GetAttr write SetAttr;
    property AttrCount: Integer read GetAttrCount;
    property ChildrenCount: Integer read GetChildrenCount;
    property Enabled: boolean read GetEnabled;
    property Handle: HELEMENT read GetHandle;
    property ID: WideString read GetID write SetID;
    property Index: Integer read GetIndex;
    property InnerHtml: WideString read GetInnerHtml write SetInnerHtml;
    property OuterHtml: WideString read GetOuterHtml write SetOuterHtml;
    property Parent: IElement read GetParent;
    property State: Integer read GetState write SetState;
    property StyleAttr[const AttrName: WideString]: WideString read GetStyleAttr write SetStyleAttr;
    property Tag: WideString read GetTag;
    property Text: WideString read GetText write SetText;
    property Value: OleVariant read GetValue write SetValue;
    property Visible: boolean read GetVisible;
  end;

  IElementCollection = interface
    ['{2E262CE3-43DE-4266-9424-EBA0241F77F8}']
    function GetCount: Integer;
    function GetItem(const Index: Integer): IElement;
    procedure RemoveAll;
    property Count: Integer read GetCount;
    property Item[const Index: Integer]: IElement read GetItem; default;
  end;

  IElements = type IElementCollection;

  TElement = class(TInterfacedObject, IElement, IElementEvents)
  private
    FAttrAnsiName: AnsiString;
    FAttrName: WideString;
    FAttrValue: WideString;
    FELEMENT: HELEMENT;
    FHChild: HELEMENT;
    FHtml: WideString;
    FOnControlEvent: TElementOnControlEvent;
    FOnDataArrived: TElementOnDataArrived;
    FOnFocus: TElementOnFocus;
    FOnGesture: TElementOnGesture;
    FOnKey: TElementOnKey;
    FOnMouse: TElementOnMouse;
    FOnScriptingCall: TElementOnScriptingCall;
    FOnScroll: TElementOnScroll;
    FOnSize: TElementOnSize;
    FOnTimer: TElementOnTimer;
    FSciter: TSciter;
    FStyleAttrName: WideString;
    FStyleAttrValue: WideString;
    FTag: WideString;
    FText: WideString;
    function GetAttr(const AttrName: WideString): WideString;
    function GetAttrCount: Integer;
    function GetChildrenCount: Integer;
    function GetEnabled: boolean;
    function GetHandle: HELEMENT;
    function GetID: WideString;
    function GetIndex: Integer;
    function GetInnerHtml: WideString;
    function GetOnControlEvent: TElementOnControlEvent;
    function GetOnDataArrived: TElementOnDataArrived;
    function GetOnFocus: TElementOnFocus;
    function GetOnGesture: TElementOnGesture;
    function GetOnKey: TElementOnKey;
    function GetOnMouse: TElementOnMouse;
    function GetOnScriptingCall: TElementOnScriptingCall;
    function GetOnScroll: TElementOnScroll;
    function GetOnSize: TElementOnSize;
    function GetOnTimer: TElementOnTimer;
    function GetOuterHtml: WideString;
    function GetParent: IElement;
    function GetState: Integer;
    function GetStyleAttr(const AttrName: WideString): WideString;
    function GetTag: WideString;
    function GetVisible: boolean;
    procedure HandleBehaviorAttach;
    procedure HandleBehaviorDetach;
    function HandleControlEvent(var params: BEHAVIOR_EVENT_PARAMS): BOOL;
    function HandleDataArrived(var params: DATA_ARRIVED_PARAMS): BOOL;
    function HandleFocus(var params: FOCUS_PARAMS): BOOL;
    function HandleGesture(var params: GESTURE_PARAMS): BOOL;
    function HandleInitialization(var params: INITIALIZATION_PARAMS): BOOL;
    function HandleKey(var params: KEY_PARAMS): BOOL;
    function HandleMethodCallEvents(var params: METHOD_PARAMS): BOOL;
    function HandleMouse(var params: MOUSE_PARAMS): BOOL;
    function HandleScriptingCall(var params: SCRIPTING_METHOD_PARAMS): BOOL;
    function HandleScrollEvents(var params: SCROLL_PARAMS): BOOL;
    function HandleSize: BOOL;
    function HandleTimer(var params: TIMER_PARAMS): BOOL;
    procedure SetAttr(const AttrName: WideString; const Value: WideString);
    procedure SetID(const Value: WideString);
    procedure SetInnerHtml(const Value: WideString);
    procedure SetOnControlEvent(const Value: TElementOnControlEvent);
    procedure SetOnDataArrived(const Value: TElementOnDataArrived);
    procedure SetOnFocus(const Value: TElementOnFocus);
    procedure SetOnGesture(const Value: TElementOnGesture);
    procedure SetOnKey(const Value: TElementOnKey);
    procedure SetOnMouse(const Value: TElementOnMouse);
    procedure SetOnScriptingCall(const Value: TElementOnScriptingCall);
    procedure SetOnScroll(const Value: TElementOnScroll);
    procedure SetOnSize(const Value: TElementOnSize);
    procedure SetOnTimer(const Value: TElementOnTimer);
    procedure SetOuterHtml(const Value: WideString);
    procedure SetState(const Value: Integer);
    procedure SetStyleAttr(const AttrName: WideString; const Value: WideString);
  protected
    constructor Create(ASciter: TSciter; h: HELEMENT); virtual;
    procedure DoBehaviorAttach; virtual;
    procedure DoBehaviorDetach; virtual;
    procedure DoControlEvents(const Args: TElementOnControlEventArgs); virtual;
    procedure DoDataArrived(const Args: TElementOnDataArrivedEventArgs); virtual;
    procedure DoFocus(const Args: TElementOnFocusEventArgs); virtual;
    procedure DoGesture(const Args: TElementOnGestureEventArgs); virtual;
    procedure DoKey(const Args: TElementOnKeyEventArgs); virtual;
    procedure DoMouse(const Args: TElementOnMouseEventArgs); virtual;
    procedure DoScriptingCall(const Args: TElementOnScriptingCallArgs); virtual;
    procedure DoScroll(const Args: TElementOnScrollEventArgs); virtual;
    procedure DoSize(const Args: TElementOnSizeEventArgs); virtual;
    procedure DoTimer(const Args: TElementOnTimerEventArgs); virtual;
    function GetText: WideString; virtual;
    function GetValue: OleVariant; virtual;
    procedure SetText(const Value: WideString); virtual;
    procedure SetValue(Value: OleVariant); virtual;
    procedure ThrowException(const Message: String); overload;
    procedure ThrowException(const Message: String; const Args: Array of const); overload;
    property Sciter: TSciter read FSciter;
  public
    destructor Destroy; override;
    procedure AppendChild(const Element: IElement);
    function AttachHwndToElement(h: HWND): boolean;
    class function BehaviorName: AnsiString; virtual;
    function Call(const Method: WideString; const Args: Array of OleVariant): OleVariant;
    procedure ClearAttributes;
    function CloneElement: IElement;
    function CreateElement(const Tag: WideString; const Text: WideString): IElement;
    procedure Delete;
    procedure Detach;
    function EqualsTo(const Element: IElement): WordBool;
    function FindNearestParent(const Selector: WideString): IElement;
    function GetAttributeName(Index: Integer): WideString;
    function GetAttributeValue(Index: Integer): WideString; overload;
    function GetAttributeValue(const Name: WideString): WideString; overload;
    function GetChild(Index: Integer): IElement;
    function GetHWND: HWND;
    procedure InsertElement(const Child: IElement; const AIndex: Integer);
    function IsValid: Boolean;
    function PostEvent(EventCode: BEHAVIOR_EVENTS): Boolean;
    procedure RemoveChildren;
    procedure Request(const Url: WideString; const RequestType: REQUEST_TYPE);
    procedure ScrollToView;
    function Select(const Selector: WideString): IElement;
    function SelectAll(const Selector: WideString): IElementCollection;
    function SendEvent(EventCode: BEHAVIOR_EVENTS): Boolean;
    function SetTimer(const Milliseconds: UINT): UINT;
    procedure StopTimer;
    procedure Swap(const Element: IElement);
    function TryCall(const Method: WideString; const Args: array of OleVariant; out RetVal: OleVariant): Boolean;
    property Attr[const AttrName: WideString]: WideString read GetAttr write SetAttr;
    property AttrCount: Integer read GetAttrCount;
    property ChildrenCount: Integer read GetChildrenCount;
    property Enabled: boolean read GetEnabled;
    property Handle: HELEMENT read GetHandle;
    property ID: WideString read GetID write SetID;
    property InnerHtml: WideString read GetInnerHtml write SetInnerHtml;
    property OuterHtml: WideString read GetOuterHtml write SetOuterHtml;
    property State: Integer read GetState write SetState;
    property StyleAttr[const AttrName: WideString]: WideString read GetStyleAttr write SetStyleAttr;
    property Tag: WideString read GetTag;
    property Text: WideString read GetText write SetText;
    property Value: OleVariant read GetValue write SetValue;
    property Visible: boolean read GetVisible;
    property OnControlEvent: TElementOnControlEvent read GetOnControlEvent write SetOnControlEvent;
    property OnDataArrived: TElementOnDataArrived read GetOnDataArrived write SetOnDataArrived;
    property OnFocus: TElementOnFocus read GetOnFocus write SetOnFocus;
    property OnGesture: TElementOnGesture read GetOnGesture write SetOnGesture;
    property OnKey: TElementOnKey read GetOnKey write SetOnKey;
    property OnMouse: TElementOnMouse read GetOnMouse write SetOnMouse;
    property OnScriptingCall: TElementOnScriptingCall read GetOnScriptingCall write SetOnScriptingCall;
    property OnScroll: TElementOnScroll read GetOnScroll write SetOnScroll;
    property OnSize: TElementOnSize read GetOnSize write SetOnSize;
    property OnTimer: TElementOnTimer read GetOnTimer write SetOnTimer;
  end;

  TElementClass = class of TElement;

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
    function GetCount: Integer;
    function GetItem(const Index: Integer): IElement;
    property Sciter: TSciter read FSciter;
  public
    destructor Destroy; override;
    procedure Add(const Item: TElement);
    procedure RemoveAll;
    property Count: Integer read GetCount;
    property Item[const Index: Integer]: IElement read GetItem; default;
  end;

  TSciter = class(TCustomControl)
  private
    FBaseUrl: WideString;
    FHomeURL: WideString;
    FHtml: WideString;
    FManagedElements: TElementList;
    FMonitorModals: Boolean;
    FOnDataLoaded: TSciterOnDataLoaded;
    FOnDocumentComplete: TSciterOnDocumentComplete;
    FOnEngineDestroyed: TNotifyEvent;
    FOnHandleCreated: TNotifyEvent;
    FOnLoadData: TSciterOnLoadData;
    FOnMessage: TSciterOnMessage;
    FOnScriptingCall: TSciterOnScriptingCall;
    FUrl: WideString;
    function GetHtml: WideString;
    function GetHVM: HVM;
    function GetRoot: IElement;
    function GetVersion: WideString;
    procedure SetOnMessage(const Value: TSciterOnMessage);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure CreateWnd; override;
    function DesignMode: boolean;
    procedure DestroyWnd; override;
    function HandleAttachBehavior(var data: SCN_ATTACH_BEHAVIOR): UINT; virtual;
    function HandleDataLoaded(var data: SCN_DATA_LOADED): UINT; virtual;
    function HandleDocumentComplete(const Url: WideString): BOOL; virtual;
    function HandleEngineDestroyed(var data: SCN_ENGINE_DESTROYED): UINT; virtual;
    function HandleLoadData(var data: SCN_LOAD_DATA): UINT; virtual;
    function HandlePostedNotification(var data: SCN_POSTED_NOTIFICATION): UINT; virtual;
    function HandleScriptingCall(var params: SCRIPTING_METHOD_PARAMS): BOOL; virtual;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
    procedure SetName(const NewName: TComponentName); override;
    procedure SetParent(AParent: TWinControl); override;
    procedure WndProc(var Message: TMessage); override;
    property ManagedElements: TElementList read FManagedElements;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Call(const FunctionName: WideString; const Args: array of OleVariant): OleVariant;
    function Eval(const Script: WideString): OleVariant;
    function FilePathToURL(const FileName: String): String;
    function FindElement(Point: TPoint): IElement;
    function FindElement2(X, Y: Integer): IElement;
    procedure GC;
    function GetElementByHandle(Handle: Integer): IElement;
    function GetMinHeight(Width: Integer): Integer;
    function GetMinWidth: Integer;
    function JsonToSciterValue(const Json: WideString): TSciterValue;
    function JsonToTiScriptValue(const Json: WideString): tiscript_object;
    procedure LoadHtml(const Html: WideString; const BaseURL: WideString);
    function LoadURL(const URL: WideString; Async: Boolean = True { reserved }): Boolean;
    procedure MouseWheelHandler(var Message: TMessage); override;
    procedure RegisterComObject(const Name: WideString; const Obj: OleVariant); overload;
    procedure RegisterComObject(const Name: WideString; const Obj: IDispatch); overload;
    function RegisterNativeClass(const ClassInfo: ISciterClassInfo; ThrowIfExists: Boolean; ReplaceClassDef: Boolean = False): tiscript_class; overload;
    function RegisterNativeClass(const ClassDef: ptiscript_class_def; ThrowIfExists: Boolean; ReplaceClassDef: Boolean { reserved } = False): tiscript_class; overload;
    procedure RegisterNativeFunction(const Name: WideString; Handler: ptiscript_method);
    procedure SaveToFile(const FileName: WideString; const Encoding: WideString = 'UTF-8' { reserved, TODO:} );
    function SciterValueToJson(Obj: TSciterValue): WideString;
    function Select(const Selector: WideString): IElement;
    function SelectAll(const Selector: WideString): IElementCollection;
    procedure SetHomeURL(const URL: WideString);
    procedure SetObject(const Name: WideString; const Json: WideString);
    procedure SetOption(const Key: SCITER_RT_OPTIONS; const Value: UINT_PTR);
    procedure ShowInspector(const Element: IElement = nil);
    function TiScriptValueToJson(Obj: tiscript_value): WideString;
    function TryCall(const FunctionName: WideString; const Args: array of OleVariant): boolean; overload;
    function TryCall(const FunctionName: WideString; const Args: array of OleVariant; out RetVal: OleVariant): boolean; overload;
    procedure UpdateWindow;
    property Html: WideString read GetHtml;
    property Root: IElement read GetRoot;
    property Version: WideString read GetVersion;
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
    property OnMessage: TSciterOnMessage read FOnMessage write SetOnMessage;
    property OnScriptingCall: TSciterOnScriptingCall read FOnScriptingCall write FOnScriptingCall;
  end;

procedure SciterRegisterBehavior(Cls: TElementClass);

{$IFDEF UNICODE}
function LoadResourceAsStream(const ResName: String; const ResType: String): TCustomMemoryStream;
{$ELSE}
function LoadResourceAsStream(const ResName: AnsiString; const ResType: AnsiString): TCustomMemoryStream;
{$ENDIF}

procedure Register;

implementation

uses
  SciterOle;

type
  TByteStream = class(TCustomMemoryStream)
  public
    constructor Create(Ptr: PByte; Size: LongInt);
    function Write(const Buffer; Count: Longint): Longint; override;
  end;

var
  Behaviors: TList;

procedure SciterRegisterBehavior(Cls: TElementClass);
begin
  if Behaviors = nil then
    Behaviors := TList.Create;
  if Behaviors.IndexOf(Cls) = -1 then
    Behaviors.Add(Cls);
end;

procedure SciterDebug(param: Pointer; subsystem: UINT; severity: OUTPUT_SEVERITY; text: PWideChar; text_length: UINT); stdcall;
var
  FSciter: TSciter;
  pArgs: TSciterOnMessageEventArgs;
begin
  FSciter := TSciter(param);
  if Assigned(FSciter.FOnMessage) then
  begin
    pArgs := TSciterOnMessageEventArgs.Create;
    pArgs.FSeverity := severity;
    pArgs.FMessage := WideString(text);
    FSciter.FOnMessage(FSciter, pArgs);
    pArgs.Free;
  end;
end;

function SciterCheck(const SR: SCDOM_RESULT; const FmtString: String; const Args: array of const; const AllowNotHandled: Boolean = False): SCDOM_RESULT; overload;
begin
  if SCDOM_RESULT(SR) = SCDOM_OK then
  begin
    Result := SCDOM_OK;
  end
    else
  begin
    if ( SR = SCDOM_OK_NOT_HANDLED) and (AllowNotHandled) then
    begin
      Result := SR;
      Exit;
    end;
    raise ESciterException.CreateFmt(FmtString, Args);
  end;
end;

function SciterCheck(const SR: SCDOM_RESULT; const Msg: String; const AllowNotHandled: Boolean = false): SCDOM_RESULT; overload;
begin
  Result := SciterCheck(SR, Msg, [], AllowNotHandled);
end;

function ElementFactory(const ASciter: TSciter; const he: HELEMENT): TElement;
begin
  Result := TElement.Create(ASciter, he);
end;

{$IFDEF UNICODE}
function LoadResourceAsStream(const ResName: String; const ResType: String): TCustomMemoryStream;
begin
  try
    Result := TResourceStream.Create(HInstance, ResName, PWideChar(ResType));
    Result.Position := 0;
  except
    on E:Exception do
    begin
      Result := nil;
    end;
  end;
end;
{$ELSE}
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
{$ENDIF}

function HostCallback(pns: LPSCITER_CALLBACK_NOTIFICATION; callbackParam: Pointer ): UINT; stdcall;
var
  pSciter: TSciter;
begin
  Result := 0;
  pSciter := TObject(callbackParam) as TSciter;
  case pns.code of
    SciterApi.SC_LOAD_DATA:
      Result := pSciter.HandleLoadData(LPSCN_LOAD_DATA(pns)^);
      
    SciterApi.SC_DATA_LOADED:
      Result := pSciter.HandleDataLoaded(LPSCN_DATA_LOADED(pns)^);

    SciterApi.SC_ATTACH_BEHAVIOR:
      Result := pSciter.HandleAttachBehavior(LPSCN_ATTACH_BEHAVIOR(pns)^);

    SciterApi.SC_ENGINE_DESTROYED:
      Result := pSciter.HandleEngineDestroyed(LPSCN_ENGINE_DESTROYED(pns)^);

    SciterApi.SC_POSTED_NOTIFICATION:
      Result := pSciter.HandlePostedNotification(LPSCN_POSTED_NOTIFICATION(pns)^);
  end;
end;

procedure ElementTagCallback(str: PAnsiChar; str_length: UINT; param : Pointer); stdcall;
var
  pElement: TElement;
  sStr: AnsiString;
begin
  pElement := TObject(param) as TElement;
  if (str = nil) or (str_length = 0) then
  begin
    pElement.FTag := '';
  end
    else
  begin
    sStr := AnsiString(str);
    pElement.FTag := WideString(sStr); // implicit unicode->ascii
  end;
end;

procedure ElementHtmlCallback(bytes: PByte; num_bytes: UINT; param: Pointer); stdcall;
var
  pElement: TElement;
  pStr: PAnsiChar;
  sStr: UTF8String;
  wStr: WideString;
begin
  pElement := TObject(param) as TElement;
  if (bytes = nil) or (num_bytes = 0) then
  begin
    pElement.FHtml := '';
  end
    else
  begin
    pStr := PAnsiChar(bytes);
    sStr := UTF8String(pStr);
    {$IFDEF UNICODE}
    wStr := UTF8ToString(pStr);
    {$ELSE}
    wStr := UTF8Decode(sStr);
    {$ENDIF}
  end;
  pElement.FHtml := wStr;
end;

procedure ElementTextCallback(str: PWideChar; str_length: UINT; param: Pointer); stdcall;
var
  pElement: TElement;
begin
  pElement := TObject(param) as TElement;
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
  pElement := TObject(param) as TElement;
  if (str_length = 0) or (str = nil) then
    pElement.FAttrAnsiName := ''
  else
    pElement.FAttrAnsiName := AnsiString(str);
end;

procedure NthAttributeValueCallback(str: PWideChar; str_length: UINT; param : Pointer); stdcall;
var
  pElement: TElement;
begin
  pElement := TObject(param) as TElement;
  if (str_length = 0) or (str = nil) then
    pElement.FAttrValue := ''
  else
    pElement.FAttrValue := WideString(str);
end;

procedure AttributeTextCallback(str: PWideChar; str_length: UINT; param: Pointer); stdcall;
var
  pElement: TElement;
begin
  pElement := TObject(param) as TElement;
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
  pElement := TObject(param) as TElement;
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
  pElementCollection := TObject(Param) as TElementCollection;
  pElement := ElementFactory(pElementCollection.Sciter, he);
  pElementCollection.Add(pElement);
  Result := False; // Continue
end;

function SelectSingleNodeCallback(he: HELEMENT; Param: Pointer ): BOOL; stdcall;
var
  pElement: TElement;
begin
  pElement := TObject(Param) as TElement;
  pElement.FHChild := he;
  Result := True; // Stop at first element
end;

function WindowElementEventProc(tag: Pointer; he: HELEMENT; evtg: EVENT_GROUPS; prms: Pointer): BOOL; stdcall;
const
  MAX_URL_LENGTH = 2048;
var
  pSciter: TSciter;
  pBehaviorEventParams:   PBEHAVIOR_EVENT_PARAMS;
  pScriptingMethodParams: PSCRIPTING_METHOD_PARAMS;
  sUri: WideString;
begin
  Result := False;
  pSciter := TObject(tag) as TSciter;

  case evtg of
    HANDLE_BEHAVIOR_EVENT:
      begin
        pBehaviorEventParams := prms;
        if pBehaviorEventParams.cmd = DOCUMENT_COMPLETE then
        begin
          sUri := '';
          if SciterVarType(@pBehaviorEventParams.data) = T_STRING then
            sUri := SciterVarToString(@pBehaviorEventParams.data);
          Result := pSciter.HandleDocumentComplete(sUri);
        end;
      end;

    HANDLE_SCRIPTING_METHOD_CALL:
      begin
        pScriptingMethodParams := PSCRIPTING_METHOD_PARAMS(prms);
        Result := pSciter.HandleScriptingCall(pScriptingMethodParams^);
      end;
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
  pGestureParams: PGESTURE_PARAMS;
  pScriptingMethodParams: PSCRIPTING_METHOD_PARAMS;
  pDataArrivedParams: PDATA_ARRIVED_PARAMS;
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
      Result := pElement.HandleInitialization(pInitParams^);
    end;

    HANDLE_MOUSE:
    begin
      pMouseParams := prms;
      Result := pElement.HandleMouse(pMouseParams^);
    end;

    HANDLE_KEY:
    begin
      pKeyParams := prms;
      Result := pElement.HandleKey(pKeyParams^);
    end;

    HANDLE_FOCUS:
    begin
      pFocusParams := prms;
      Result := pElement.HandleFocus(pFocusParams^);
    end;

    HANDLE_TIMER:
    begin
      pTimerParams := prms;
      Result := pElement.HandleTimer(pTimerParams^);
    end;

    HANDLE_BEHAVIOR_EVENT:
    begin
      pBehaviorEventParams := prms;
      Result := pElement.HandleControlEvent(pBehaviorEventParams^);
    end;

    HANDLE_METHOD_CALL:
    begin
      pMethodCallParams := prms;
      Result := pElement.HandleMethodCallEvents(pMethodCallParams^);
    end;

    HANDLE_DATA_ARRIVED:
    begin
      pDataArrivedParams := prms;
      Result := pElement.HandleDataArrived(pDataArrivedParams^);
    end;

    HANDLE_SCROLL:
    begin
      pScrollParams := prms;
      Result := pElement.HandleScrollEvents(pScrollParams^);
    end;

    HANDLE_SIZE:
    begin
      Result := pElement.HandleSize;
    end;

    HANDLE_SCRIPTING_METHOD_CALL:
    begin
      pScriptingMethodParams := prms;
      Result := pElement.HandleScriptingCall(pScriptingMethodParams^);
    end;

    HANDLE_TISCRIPT_METHOD_CALL:
    begin
      Result := False; // --> routes to HANDLE_SCRIPTING_METHOD_CALL
    end;

    HANDLE_GESTURE:
    begin
      pGestureParams := prms;
      Result := pElement.HandleGesture(pGestureParams^);
    end;
  end;
end;

constructor TSciter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FManagedElements := TElementList.Create(False);
  Width := 300;
  Height := 300;
  TabStop := True;
  Caption := 'Sciter';
end;

destructor TSciter.Destroy;
begin
  FManagedElements.Free;
  inherited;
end;

function TSciter.Call(const FunctionName: WideString;
  const Args: array of OleVariant): OleVariant;
begin
  if not TryCall(FunctionName, Args, Result) then
    raise ESciterCallException.Create(FunctionName);
end;

procedure TSciter.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or WS_CHILD or WS_TABSTOP or WS_VISIBLE;
  Params.ExStyle := Params.ExStyle or WS_EX_CONTROLPARENT;
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
  API.ValueInit(@pVal);
  if API.SciterEval(Handle, PWideChar(Script), Length(Script), pVal)  then
    S2V(@pVal, pResult)
  else
    pResult := Unassigned;
  Result := pResult;
end;

function TSciter.FilePathToURL(const FileName: String): String;
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
      pResult := ElementFactory(Self, hResult);
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
  Result := ElementFactory(Self, HELEMENT(Handle));
end;

function TSciter.GetHtml: WideString;
var
  pRoot: IElement;
begin
  pRoot := GetRoot;
  if pRoot = nil then
  begin
    Result := ''
  end
    else
  begin
    Result := pRoot.OuterHtml;
  end;
  pRoot := nil;
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

function TSciter.GetRoot: IElement;
var
  he: HELEMENT;
begin
  if not HandleAllocated then
  begin
    Result := nil;
    Exit;
  end;

  he := nil;
  if API.SciterGetRootElement(Handle, he) = SCDOM_OK then
    Result := ElementFactory(Self, he)
  else
    Result := nil;
end;

function TSciter.GetVersion: WideString;
type
  TVer = record
    a: Word;
    b: Word;
  end;
  PVer = ^TVer;
var
  ver: UINT;
begin
  ver := API.SciterVersion(true);
  Result := '3.0.' + Format('%d.%d', [PVer(@ver)^.a, PVer(@ver)^.b]);
end;

function TSciter.HandleAttachBehavior(var data: SCN_ATTACH_BEHAVIOR): UINT;
var
  sBehaviorName: AnsiString;
  pElement: TElement;
  i: Integer;
  pClass: TElementClass;
begin
  Result := 0;
  
  sBehaviorName := AnsiString(data.behaviorName);
  if Behaviors <> nil then
  begin
    for i := 0 to Behaviors.Count - 1 do
    begin
      pClass := TElementClass(Behaviors[i]);
      if pClass.BehaviorName = sBehaviorName then
      begin
        pElement := pClass.Create(Self, data.element);
        pElement._AddRef;  // NB: Important. Without this, element'll be destroyed prematurely
        data.elementTag := pElement;
      end;
    end;
  end;
end;

function TSciter.HandleDataLoaded(var data: SCN_DATA_LOADED): UINT;
begin
  if Assigned(FOnDataLoaded) then
    FOnDataLoaded(Self, WideString(data.uri), data.dataType, data.data, data.dataSize, 0, Integer(data.status));
  Result := 0;
end;

function TSciter.HandleDocumentComplete(const Url: WideString): BOOL;
var
  bHandled: Integer;
begin
  Result := False;
  if Assigned(FOnDocumentComplete) then
    FOnDocumentComplete(Self, Url);

  // Temporary fix: sometimes bottom part of document stays invisible until parent form gets resized
  API.SciterProcND(Handle, WM_SIZE, 0, MAKELPARAM(ClientRect.Right - ClientRect.Left + 1, ClientRect.Bottom - ClientRect.Top), bHandled);
end;

function TSciter.HandleEngineDestroyed(var data: SCN_ENGINE_DESTROYED): UINT;
begin
  if data.hwnd = Handle then
  begin
    if Assigned(FOnEngineDestroyed) then
      FOnEngineDestroyed(Self);
  end;
  Result := 0;
end;

function TSciter.HandleLoadData(var data: SCN_LOAD_DATA): UINT;
var
  discard: Boolean;
  wUrl: WideString;
  wResName: WideString;
  pStream: TCustomMemoryStream;
begin
  Result := LOAD_OK;

  wUrl := WideString(data.uri);

  // Hadling res: URL scheme
  {$IFDEF UNICODE}
  if Pos(WideString('res:'), wUrl) = 1 then
  {$ELSE}
  if Pos('res:', wUrl) = 1 then
  {$ENDIF}
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
      wUrl := WideString(data.uri);
      FOnLoadData(Self, wUrl, data.dataType, Integer(data.requestId), discard);
      data.uri := PWideChar(wUrl);
      if discard then
        Result := LOAD_DISCARD;
    end;
  end;
end;

function TSciter.HandlePostedNotification(
  var data: SCN_POSTED_NOTIFICATION): UINT;
begin
  Result := 0;
end;

function TSciter.HandleScriptingCall(
  var params: SCRIPTING_METHOD_PARAMS): BOOL;
var
  pEventArgs: TElementOnScriptingCallArgs;
  pVal: PSciterValue;
  i: Integer;
begin
  Result := False;

  if Assigned(FOnScriptingCall) then
  begin
    API.ValueInit(@params.rv);
    pEventArgs := TElementOnScriptingCallArgs.Create;
    pEventArgs.FMethod := WideString(AnsiString(params.name));
    pEventArgs.FReturnValue := Unassigned;

    SetLength(pEventArgs.FArgs, params.argc);
    pVal := params.argv;
    if params.argc > 0 then
    begin
      for i := 0 to params.argc - 1 do
      begin
        S2V(pVal, pEventArgs.FArgs[i]);
        Inc(pVal, sizeof(TSciterValue));
      end;
    end;
    FOnScriptingCall(Self, pEventArgs);
    if pEventArgs.Handled then
    begin
      V2S(pEventArgs.FReturnValue, @params.rv);
    end;
    Result := pEventArgs.Handled;

    pEventArgs.FReturnValue := Unassigned;
    SetLength(pEventArgs.FArgs, 0);
    pEventArgs.Free;
  end;
  
end;

//function TSciter.HandleScriptingCall(
//  params: PTISCRIPT_METHOD_PARAMS): BOOL;
//begin
//  Result := False;
//  { Don't know how to get method name! }
//  { if method returns False then overloaded HandleScriptingCall(params: PSCRIPTING_METHOD_PARAMS) will be called }
//end;

function TSciter.JsonToSciterValue(const Json: WideString): TSciterValue;
var
  pObj: TSciterValue;
begin
  API.ValueInit(@pObj);
  if API.ValueFromString(@pObj, PWideChar(Json), Length(Json), CVT_XJSON_LITERAL) <> 0 then
    raise ESciterException.Create('Sciter failed parsing JSON string.');
  Result := pObj;
end;

function TSciter.JsonToTiScriptValue(const Json: WideString): tiscript_object;
var
  sv: TSciterValue;
  tv: tiscript_value;
begin
  sv := JsonToSciterValue(Json);
  if not API.Sciter_S2T(VM, @sv, tv) then
    raise ESciterException.Create('Sciter failed parsing JSON string.');
  Result := tv;
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
  end
    // else HTML will be loaded in CreateWnd
end;

function TSciter.LoadURL(const URL: WideString; Async: Boolean = True): Boolean;
begin
  Result := False;
  
  if DesignMode then
    Exit;

  FUrl := URL;
  FHtml := '';
  FBaseUrl := '';

  if HandleAllocated then
  begin
    Result := API.SciterLoadFile(Handle, PWideChar(URL));
  end
  // else URL will be loaded in CreateWnd
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
  sCaption: String;
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
  const Obj: OleVariant);
begin
  SciterOle.RegisterOleObject(VM, IDispatch(Obj), Name);
end;

procedure TSciter.RegisterComObject(const Name: WideString;
  const Obj: IDispatch);
begin
  SciterOle.RegisterOleObject(VM, Obj, Name);
end;

function TSciter.RegisterNativeClass(const ClassInfo: ISciterClassInfo;
  ThrowIfExists, ReplaceClassDef: Boolean): tiscript_class;
begin
  if ClassInfo = nil then
    raise ESciterException.Create('Argument cannot be null');

  if SciterApi.IsNativeClassExists(VM, ClassInfo.TypeName) then
  begin
    if ThrowIfExists then
    begin
      raise ESciterException.CreateFmt('Native class with such name ("%s") already exists.', [ClassInfo.TypeName]);
    end
      else
    begin
      Result := GetNativeClass(VM, ClassInfo.TypeName);
      Exit;
    end;
  end;

  if ClassBag.ClassInfoExists(VM, ClassInfo.TypeName) then
  begin
    if ThrowIfExists then
    begin
      raise ESciterException.CreateFmt('Definition of native class "%s" is already in cache.', [ClassInfo.TypeName])
    end
      else
    begin
      Result := ClassBag.ResolveClass(VM, ClassInfo.TypeName);
    end;
  end
    else
  begin
    Result := ClassBag.RegisterClassInfo(VM, ClassInfo);
  end;
end;

function TSciter.RegisterNativeClass(const ClassDef: ptiscript_class_def; ThrowIfExists: Boolean; ReplaceClassDef: Boolean): tiscript_class;
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

{ Exprerimental, need to leverage WideCharToMultiByte  }
procedure TSciter.SaveToFile(const FileName, Encoding: WideString);
var
  sUTF8: UTF8String;
  F: TextFile;
begin
  sUTF8 := UTF8Encode(Html);
  try
    AssignFile(F, AnsiString(FileName));
    Rewrite(F);
    Write(F, sUTF8);
  finally
    CloseFile(F);
  end;
end;

function TSciter.SciterValueToJson(Obj: TSciterValue): WideString;
var
  pWStr: PWideChar;
  iNum: UINT;
  pCopy: TSciterValue;
begin
  pCopy := Obj;
  if API.ValueToString(@pCopy, CVT_XJSON_LITERAL) <> 0 then
    raise ESciterException.Create('Failed to convert SciterValue to JSON');
  if API.ValueStringData(@pCopy, pWStr, iNum) <> 0 then
    raise ESciterException.Create('Failed to convert SciterValue to JSON');
  Result := WideString(pWstr);
end;

function TSciter.Select(const Selector: WideString): IElement;
var
  pRoot: IElement;
begin
  pRoot := GetRoot;
  Result := pRoot.Select(Selector);
end;

function TSciter.SelectAll(const Selector: WideString): IElementCollection;
var
  pRoot: IElement;
begin
  pRoot := GetRoot;
  Result := pRoot.SelectAll(Selector);
end;

procedure TSciter.SetHomeURL(const URL: WideString);
begin
  FHomeURL := URL;
  if HandleAllocated then
  begin
    if not API.SciterSetHomeURL(Handle, PWideChar(URL)) then
      raise ESciterException.Create('Failed to set Sciter home URL');
  end;
end;

procedure TSciter.SetName(const NewName: TComponentName);
begin
  inherited;
  Invalidate;
end;

{ Exprerimental }
procedure TSciter.SetObject(const Name, Json: WideString);
var
  var_name: tiscript_string;
  zns: tiscript_value;
  obj: tiscript_value;
  s: WideString;
begin
  zns := NI.get_global_ns(vm);
  var_name  := NI.string_value(vm, PWideChar(Name), Length(Name));

  obj := JsonToTiScriptValue(Json);
  s := TiScriptValueToJson(obj);

  if not NI.set_prop(VM, zns, var_name, obj) then
    raise ESciterException.Create('Failed to set native object');
end;

procedure TSciter.SetOnMessage(const Value: TSciterOnMessage);
begin
  FOnMessage := Value;
end;

procedure TSciter.SetOption(const Key: SCITER_RT_OPTIONS;
  const Value: UINT_PTR);
begin
  API.SciterSetOption(Handle, Key, Value);
end;

procedure TSciter.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
end;

procedure TSciter.ShowInspector(const Element: IElement);
begin
  {
  if Element = nil then
    SciterApi.SciterWindowInspector(Handle, API)
  else
    SciterApi.SciterInspector(HELEMENT(Element.Handle), API);
  }
end;

function TSciter.TiScriptValueToJson(Obj: tiscript_value): WideString;
var
  sv: TSciterValue;
begin
  API.ValueInit(@sv);
  if not API.Sciter_T2S(VM, Obj, sv, False) then
    raise ESciterException.Create('Failed to convert tiscript_value to JSON.');
  Result := SciterValueToJson(sv);
end;

function TSciter.TryCall(const FunctionName: WideString;
  const Args: array of OleVariant): boolean;
var
  pRetVal: OleVariant;
begin
  Result := TryCall(FunctionName, Args, pRetVal);
end;

function TSciter.TryCall(const FunctionName: WideString;
  const Args: array of OleVariant; out RetVal: OleVariant): boolean;
var
  pVal: TSciterValue;
  sFunctionName: AnsiString;
  pArgs: array[0..255] of TSciterValue;
  cArgs: Integer;
  i: Integer;
begin
  sFunctionName := AnsiString(FunctionName);
  API.ValueInit(@pVal);

  cArgs := Length(Args);
  if cArgs > 256 then
    raise ESciterException.Create('Too many arguments.');

  for i := Low(pArgs) to High(pArgs) do
    API.ValueInit(@pArgs[i]);

  for i := Low(Args) to High(Args) do
  begin
    V2S(Args[i], @pArgs[i]);
  end;

  if API.SciterCall(Handle, PAnsiChar(sFunctionName), cArgs, @pArgs[0], pVal) then
  begin
    S2V(@pVal, RetVal);
    Result := True;
  end
    else
  begin
    RetVal := Unassigned;
    Result := False;
  end;
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

  function EnumChildProc(h: HWND; l: LPARAM): BOOL; stdcall;
  var
    pClassName: array[0..255] of AnsiChar;
  begin
    Result := TRUE;
    if GetClassNameA(h, @pClassName, 256) = 0 then
      Exit; // and continue

    if string(pClassName) = 'H-SMILE-FRAME' then
    begin
      if not IsWindowEnabled(h) then
        EnableWindow(h, TRUE);
      Result := FALSE;
    end;
  end;
  
  procedure TweakSciterModals;
  begin
    EnumThreadWindows(GetCurrentThreadId, @EnumChildProc, 0);
  end;

begin
  if not DesignMode then
  begin
    if HandleAllocated then
    begin
      case Message.Msg of
        WM_KILLFOCUS:
          FMonitorModals := True;

        WM_SETFOCUS:
          FMonitorModals := False;

        WM_GETDLGCODE:
          // Tweaking arrow keys and TAB handling (VCL-specific)
          begin
            Message.Result := DLGC_WANTALLKEYS or DLGC_WANTTAB or DLGC_WANTARROWS or DLGC_WANTCHARS or DLGC_HASSETSEL;
            if Message.lParam <> 0 then
            begin
              M := PMsg(Message.lParam);
              case M.Message of
                WM_SYSKEYDOWN, WM_SYSKEYUP, WM_SYSCHAR,
                WM_KEYDOWN, WM_KEYUP, WM_CHAR:
                begin
                  Perform(M.message, M.wParam, M.lParam);
                  // Message.Result := Message.Result or DLGC_WANTMESSAGE or DLGC_WANTTAB;
                end;
              end;
            end;
            Exit;
          end;
      end;

      // Tweaking Sciter modals VCL-related problem
      // Displaying a modal, Sciter calls EnableWindow(FALSE) for all the parent windows
      // including application top-level form. And the main form disables all child controls including both Sciter window
      // and the modal, so it gets disabled and cannot be closed with a mouse.
      if FMonitorModals then
      begin
        TweakSciterModals;
      end;

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
    FMonitorModals := False;
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
  FSciter.ManagedElements.Add(Self);
end;

destructor TElement.Destroy;
begin
  API.SciterDetachEventHandler(Self.FElement, @ElementEventProc, Self);
  API.Sciter_UnuseElement(FElement);
  if FSciter.ManagedElements.IndexOf(Self) <> - 1 then
    FSciter.ManagedElements.Remove(Self);
  inherited;
end;

{ TElement }
procedure TElement.AppendChild(const Element: IElement);
begin
  Assert(FSciter.HandleAllocated);
  SciterCheck(
    API.SciterInsertElement(Element.Handle, FElement, $7FFFFFFF { sciter-x-dom.h }),
    'Failed to append child element.'
  );
end;

function TElement.AttachHwndToElement(h: HWND): boolean;
begin
  Result := API.SciterAttachHwndToElement(FElement, h) = SCDOM_OK;
end;

class function TElement.BehaviorName: AnsiString;
begin
  Result := '';
end;

function TElement.Call(const Method: WideString;
  const Args: array of OleVariant): OleVariant;
begin
  if not TryCall(Method, Args, Result) then
    raise ESciterCallException.Create(Method);
end;

procedure TElement.ClearAttributes;
begin
  SciterCheck(
    API.SciterClearAttributes(FElement),
    'Failed to clear element attributes.'
  );
end;

function TElement.CloneElement: IElement;
var
  phe: HELEMENT;
begin
  SciterCheck(
    API.SciterCloneElement(FElement, phe), 'Failed to clone element.'
  );
  Result := ElementFactory(Self.Sciter, phe);
end;

function TElement.CreateElement(const Tag: WideString; const Text: WideString): IElement;
var
  pElement: TElement;
  pHandle: HELEMENT;
  sTag: AnsiString;
begin
  sTag := AnsiString(Tag);
  SciterCheck(
    API.SciterCreateElement(PAnsiChar(sTag), PWideChar(Text), pHandle),
    'Failed to create element "%s".', [Tag]
  );

  pElement := ElementFactory(Self.Sciter, pHandle);
  Result := pElement;
end;

procedure TElement.Delete;
begin
  SciterCheck(
    API.SciterDeleteElement(FElement),
    'Failed to delete element.',
    [],
    True
  );
  FELEMENT := nil;
end;

procedure TElement.Detach;
begin
  SciterCheck(
    API.SciterDetachElement(FElement),
    'Failed to detach element.');
end;

procedure TElement.DoBehaviorAttach;
begin

end;

procedure TElement.DoBehaviorDetach;
begin

end;

procedure TElement.DoControlEvents(const Args: TElementOnControlEventArgs);
begin
  if Assigned(FOnControlEvent) then
    FOnControlEvent(Sciter, Args);
end;

procedure TElement.DoDataArrived(const Args: TElementOnDataArrivedEventArgs);
begin
  if Assigned(FOnDataArrived) then
    FOnDataArrived(Sciter, Args);
end;

procedure TElement.DoFocus(const Args: TElementOnFocusEventArgs);
begin
  if Assigned(FOnFocus) then
    FOnFocus(Sciter, Args);
end;

procedure TElement.DoGesture(const Args: TElementOnGestureEventArgs);
begin
  if Assigned(FOnGesture) then
    FOnGesture(Sciter, Args);
end;

procedure TElement.DoKey(const Args: TElementOnKeyEventArgs);
begin
  if Assigned(FOnKey) then
    FOnKey(Sciter, Args);
end;

procedure TElement.DoMouse(const Args: TElementOnMouseEventArgs);
begin
  if Assigned(FOnMouse) then
    FOnMouse(Sciter, Args);
end;

procedure TElement.DoScriptingCall(const Args: TElementOnScriptingCallArgs);
begin
  if Assigned(FOnScriptingCall) then
    FOnScriptingCall(Sciter, Args);
end;

procedure TElement.DoScroll(const Args: TElementOnScrollEventArgs);
begin
  if Assigned(FOnScroll) then
    Self.FOnScroll(Sciter, Args);
end;

procedure TElement.DoSize(const Args: TElementOnSizeEventArgs);
begin
  if Assigned(FOnSize) then
    FOnSize(Sciter, Args);
end;

procedure TElement.DoTimer(const Args: TElementOnTimerEventArgs);
begin
  if Assigned(FOnTimer) then
    FOnTimer(Sciter, Args);
end;

function TElement.EqualsTo(const Element: IElement): WordBool;
begin
  Result := (Element <> nil) and (Self.Handle = Element.Handle);
end;

function TElement.FindNearestParent(const Selector: WideString): IElement;
var
  pHE: HELEMENT;
begin
  pHE := nil;
  SciterCheck(
    API.SciterSelectParentW(FElement, PWideChar(Selector), 0, pHE),
    'Failed to select nearest parent element.',
    []
  );
  Result := ElementFactory(Sciter, pHE);
end;

function TElement.GetAttr(const AttrName: WideString): WideString;
var
  sAttrName: AnsiString;
  SR: SCDOM_RESULT;
begin
  Result := '';
  
  if AttrName = '' then
  begin
    Result := '';
    Exit;
  end;
  
  sAttrName := AnsiString(AttrName);
  Self.FAttrName := AttrName;
  
  SR := SciterCheck(
    API.SciterGetAttributeByNameCB(FElement, PAnsiChar(sAttrName), @AttributeTextCallback, Self),
    'Failed to get attribute value (attribute name: %s)',
    [AttrName],
    True
  );

  case SR of
    SCDOM_OK_NOT_HANDLED:
      begin
        FAttrValue := '';
        Result := '';
      end;
    SCDOM_OK:
      Result := Self.FAttrValue;
  end;
end;

function TElement.GetAttrCount: Integer;
var
  Cnt: UINT;
begin
  SciterCheck(
    API.SciterGetAttributeCount(FElement, Cnt),
    'Failed to get count of element attributes.'
  );
  Result := Integer(Cnt);
end;

function TElement.GetAttributeName(Index: Integer): WideString;
var
  nCnt: UINT;
begin
  nCnt := GetAttrCount;

  if UINT(Index) >= nCnt then
    ThrowException('Attribute index (%d) is out of range.', [Index]);
    
  SciterCheck(
    API.SciterGetNthAttributeNameCB(FElement, Index, @NThAttributeNameCallback, Self),
    'Failed to get attribute name.',
    []
  );
    
  Result := WideString(Self.FAttrAnsiName)
end;

function TElement.GetAttributeValue(Index: Integer): WideString;
var
  nCnt: UINT;
begin
  nCnt := GetAttrCount;
  
  if UINT(Index) >= nCnt then
    ThrowException('Attribute index (%d) is out of range.', [Index]);

  SciterCheck(
    API.SciterGetNthAttributeValueCB(FElement, Index, @NThAttributeValueCallback, Self),
    'Failed to get attribute #%d value.',
    [Index]
  );

  Result := Self.FAttrValue
end;

function TElement.GetAttributeValue(const Name: WideString): WideString;
begin
  Result := GetAttr(Name);
end;

function TElement.GetChild(Index: Integer): IElement;
var
  hResult: HELEMENT;
  pResult: TElement;
  nCnt: Integer;
begin
  nCnt := GetChildrenCount;

  if Index >= nCnt then
    ThrowException('Child element index (%d) is out of range.', [Index]);

  SciterCheck(
    API.SciterGetNthChild(FElement, UINT(Index), hResult),
    'Failed to get child element with index %d.',
    [Index]
  );
    
  if hResult = nil then
  begin
    Result := nil;
  end
    else
  begin
    pResult := ElementFactory(Self.Sciter, hResult);
    Result := pResult;
  end;
end;

function TElement.GetChildrenCount: Integer;
var
  cnt: UINT;
begin
  SciterCheck(
    API.SciterGetChildrenCount(FElement, cnt),
    'Failed to get count of child elements.'
  );
  Result := Integer(cnt);
end;

function TElement.GetEnabled: boolean;
var
  pResult: LongBool;
begin
  API.SciterIsElementEnabled(FELEMENT, pResult);
  Result := pResult;
end;

function TElement.GetHandle: HELEMENT;
begin
  Result := FELEMENT;
end;

function TElement.GetHWND: HWND;
begin
  Result := 0;
  SciterCheck(
    API.SciterGetElementHwnd(FElement, Result, TRUE),
    'Failed to get window handle.');
end;

function TElement.GetID: WideString;
begin
  Result := GetAttr('id');
end;

function TElement.GetIndex: Integer;
var
  pResult: UINT;
begin
  pResult := 0;
  SciterCheck(
    API.SciterGetElementIndex(FElement, pResult),
    'Failed to get element index.'
  );
  Result := Integer(pResult);
end;

function TElement.GetInnerHtml: WideString;
begin
  SciterCheck(
    API.SciterGetElementHtmlCB(FElement, False, @ElementHtmlCallback, Self),
    'Failed to get element inner HTML property.'
  );
  
  Result := Self.FHtml;
end;

function TElement.GetOnControlEvent: TElementOnControlEvent;
begin
  Result := FOnControlEvent;
end;

function TElement.GetOnDataArrived: TElementOnDataArrived;
begin
  Result := FOnDataArrived;
end;

function TElement.GetOnFocus: TElementOnFocus;
begin
  Result := FOnFocus;
end;

function TElement.GetOnGesture: TElementOnGesture;
begin
  Result := FOnGesture;
end;

function TElement.GetOnKey: TElementOnKey;
begin
  Result := FOnKey;
end;

function TElement.GetOnMouse: TElementOnMouse;
begin
  Result := FOnMouse;
end;

function TElement.GetOnScriptingCall: TElementOnScriptingCall;
begin
  Result := FOnScriptingCall;
end;

function TElement.GetOnScroll: TElementOnScroll;
begin
  Result := FOnScroll;
end;

function TElement.GetOnSize: TElementOnSize;
begin
  Result := FOnSize;
end;

function TElement.GetOnTimer: TElementOnTimer;
begin
  Result := FOnTimer;
end;

function TElement.GetOuterHtml: WideString;
begin
  SciterCheck(
    API.SciterGetElementHtmlCB(FElement, True, @ElementHtmlCallback, Self),
    'Failed to get element outer HTML property.'
  );
  Result := Self.FHtml;
end;

function TElement.GetParent: IElement;
var
  pParent: HELEMENT;
  pResult: TElement;
begin
  pParent := nil;
  SciterCheck(
    API.SciterGetParentElement(FELEMENT, pParent),
    'Failed to get parent element.'
  );
  
  if (pParent = nil) then
  begin
    Result := nil;
  end
    else
  begin
    pResult := ElementFactory(Self.Sciter, pParent);
    Result := pResult;
  end;
end;

function TElement.GetState: Integer;
var
  uState: UINT;
begin
  API.SciterGetElementState(FElement, uState);
  Result := Integer(uState);
end;

function TElement.GetStyleAttr(const AttrName: WideString): WideString;
var
  sStyleAttrName: AnsiString;
begin
  sStyleAttrName := AnsiString(AttrName);
  Self.FStyleAttrName := AttrName;
  
  SciterCheck(
    API.SciterGetAttributeByNameCB(FElement, PAnsiChar(sStyleAttrName), @StyleAttributeTextCallback, Self),
    'Failed to get element style attribute.');
    
  Result := Self.FStyleAttrValue;
end;

function TElement.GetTag: WideString;
begin
  SciterCheck(
    API.SciterGetElementTypeCB(FElement, @ElementTagCallback, Self),
    'Failed to get element tag.'
  );
  Result := FTag
end;

function TElement.GetText: WideString;
begin
  SciterCheck(
    API.SciterGetElementTextCB(FELEMENT, @ElementTextCallback, Self),
    'Failed to get element text.'
  );
  Result := FText
end;

function TElement.GetValue: OleVariant;
var
  pValue: TSciterValue;
begin
{$R-}
  API.ValueInit(@pValue);
  SciterCheck(
    API.SciterGetValue(FElement, @pValue),
    'Failed to get element value'
  );
  S2V(@pValue, Result);
{$R+}
end;

function TElement.GetVisible: boolean;
var
  pResult: LongBool;
begin
  API.SciterIsElementVisible(FELEMENT, pResult);
  Result := pResult;
end;

procedure TElement.HandleBehaviorAttach;
begin
  DoBehaviorAttach;
end;

procedure TElement.HandleBehaviorDetach;
begin
  DoBehaviorDetach;
end;

function TElement.HandleControlEvent(
  var params: BEHAVIOR_EVENT_PARAMS): BOOL;
var
  pArgs: TElementOnControlEventArgs;
begin
  pArgs := TElementOnControlEventArgs.Create;
  try
    pArgs.FEventType := params.cmd;
    pArgs.FHandled := False;
    if params.heTarget <> nil then
      pArgs.FTarget := ElementFactory(Self.Sciter, params.heTarget);
    if params.he <> nil then
      pArgs.FSource := ElementFactory(Self.Sciter, params.he);
    pArgs.FReason := params.reason;

    DoControlEvents(pArgs);

    Result := pArgs.Handled;
  finally
    pArgs.FTarget := nil;
    pArgs.FSource := nil;
    pArgs.Free;
  end;
end;

function TElement.HandleDataArrived(var params: DATA_ARRIVED_PARAMS): BOOL;
var
  pArgs: TElementOnDataArrivedEventArgs;
begin
  if (params.data = nil) or (params.dataSize = 0) then
  begin
    Result := False;
    Exit;
  end;

  pArgs := TElementOnDataArrivedEventArgs.Create;
  pArgs.FHandled := False;
  pArgs.FTarget := Self;
  if params.initiator <> nil then
    pArgs.FInitiator := ElementFactory(Sciter, params.initiator);
  pArgs.FDataType := params.dataType;
  pArgs.FStatus := params.status;
  pArgs.FStream := TByteStream.Create(params.data, params.dataSize);
  pArgs.FStream.Position := 0;
  pArgs.FUri := WideString(params.uri);
  DoDataArrived(pArgs);
  Result := pArgs.Handled;

  pArgs.FStream.Free;
  pArgs.FInitiator := nil;
  pArgs.FTarget := nil;
  pArgs.Free;
end;

function TElement.HandleFocus(var params: FOCUS_PARAMS): BOOL;
var
  pArgs: TElementOnFocusEventArgs;
begin
  pArgs := TElementOnFocusEventArgs.Create;
  pArgs.FHandled := False;
  pArgs.FEventType := params.cmd;
  if params.target <> nil then
    pArgs.FTarget := ElementFactory(Self.Sciter, params.target);

  DoFocus(pArgs);
  
  Result := pArgs.Handled;
  pArgs.FTarget := nil;
  pArgs.Free;
end;

function TElement.HandleGesture(var params: GESTURE_PARAMS): BOOL;
var
  pArgs: TElementOnGestureEventArgs;
begin
  pArgs := TElementOnGestureEventArgs.Create;
  pArgs.FHandled := False;
  pArgs.FDeltaV := params.delta_v;
  pArgs.FCmd := params.cmd;
  if params.target <> nil then
    pArgs.FTarget := ElementFactory(Sciter, params.target);
  pArgs.FFlags := params.flags;
  pArgs.FPosView := params.pos_view;
  pArgs.FPos := params.pos;
  pArgs.FDeltaXY := params.delta_xy;
  pArgs.FDeltaTime := params.delta_time;

  DoGesture(pArgs);
  Result := pArgs.Handled;

  pArgs.FTarget := nil;
  pArgs.Free;
end;

function TElement.HandleInitialization(
  var params: INITIALIZATION_PARAMS): BOOL;
begin
  case params.cmd of
    BEHAVIOR_ATTACH: HandleBehaviorAttach;
    BEHAVIOR_DETACH: HandleBehaviorDetach;
  end;
  Result := False;
end;

function TElement.HandleKey(var params: KEY_PARAMS): BOOL;
var
  pArgs: TElementOnKeyEventArgs;
begin
  pArgs := TElementOnKeyEventArgs.Create;
  pArgs.FHandled := False;
  if params.target <> nil then
    pArgs.FTarget := ElementFactory(Sciter, params.target);
  pArgs.FKeyCode := params.key_code;
  pArgs.FEventType := params.cmd;
  pArgs.FKeys := params.alt_state;

  DoKey(pArgs);
  Result := pArgs.Handled;

  pArgs.FTarget := nil;
  pArgs.Free;
end;

function TElement.HandleMethodCallEvents(var params: METHOD_PARAMS): BOOL;
var
  x: BEHAVIOR_METHOD_IDENTIFIERS;
begin
  x := params.methodID;
  if x = IS_EMPTY then
  begin
    //pEmptyParams := PIS_EMPTY_PARAMS(params);
    //pEmptyParams.is_empty := 0;
  end;
  Result := False;
end;

function TElement.HandleMouse(var params: MOUSE_PARAMS): BOOL;
var
  pArgs: TElementOnMouseEventArgs;
begin
  pArgs := TElementOnMouseEventArgs.Create;
  pArgs.FButtons := params.button_state;
  pArgs.FEventType := params.cmd;
  pArgs.FHandled := False;
  pArgs.FKeys := params.alt_state;
  if params.target <> nil then
    pArgs.FTarget := ElementFactory(Sciter, params.target);
  pArgs.FX := params.pos.X;
  pArgs.FY := params.pos.Y;
  pArgs.FViewX := params.pos_view.X;
  pArgs.FViewY := params.pos_view.Y;

  DoMouse(pArgs);
  Result := pArgs.Handled;

  pArgs.FTarget := nil;
  pArgs.Free;
end;

function TElement.HandleScriptingCall(
  var params: SCRIPTING_METHOD_PARAMS): BOOL;
var
  pEventArgs: TElementOnScriptingCallArgs;
  pVal: PSciterValue;
  i: Integer;
begin
  API.ValueInit(@(params.rv));

  pEventArgs := TElementOnScriptingCallArgs.Create;
  pEventArgs.FTarget := Self;
  pEventArgs.ReturnValue := Unassigned;
  pEventArgs.FHandled := False;

  SetLength(pEventArgs.FArgs, params.argc);
  pEventArgs.FMethod := WideString(AnsiString(params.name));
  if params.argc > 0 then
  begin
    pVal := params.argv;
    for i := 0 to params.argc - 1 do
    begin
      S2V(pVal, pEventArgs.FArgs[i]);
      Inc(pVal);
    end;
  end;
  
  DoScriptingCall(pEventArgs);
  Result := pEventArgs.Handled;
  V2S(pEventArgs.ReturnValue, @(params.rv));
  
  pEventArgs.FTarget := nil;
  SetLength(pEventArgs.FArgs, 0);
  pEventArgs.ReturnValue := Unassigned;
  pEventArgs.Free;
end;

function TElement.HandleScrollEvents(var params: SCROLL_PARAMS): BOOL;
var
  pArgs: TElementOnScrollEventArgs;
begin
  pArgs := TElementOnScrollEventArgs.Create;
  pArgs.FEventType := params.cmd;
  pArgs.FHandled := False;
  pArgs.FIsVertical := params.vertical;
  if params.target <> nil then
    pArgs.FTarget := ElementFactory(Sciter, params.target);

  DoScroll(pArgs);
  Result := pArgs.Handled;

  pArgs.FTarget := nil;
  pArgs.Free;
end;

function TElement.HandleSize: BOOL;
var
  pArgs: TElementOnSizeEventArgs;
begin
  pArgs := TElementOnSizeEventArgs.Create;
  pArgs.FHandled := False;
  pArgs.FTarget := Self;
  DoSize(pArgs);
  Result := pArgs.Handled;
  pArgs.FTarget := nil;
  pArgs.Free;
end;

function TElement.HandleTimer(var params: TIMER_PARAMS): BOOL;
var
  pArgs: TElementOnTimerEventArgs;
begin
  pArgs := TElementOnTimerEventArgs.Create;
  pArgs.FContinue := False;
  pArgs.FTarget := Self;
  pArgs.FTimerId := params.timerId;
  DoTimer(pArgs);
  Result := pArgs.Continue;
  pArgs.FTarget := nil;
  pArgs.Free;
end;

procedure TElement.InsertElement(const Child: IElement; const AIndex: Integer);
begin
  Assert(FSciter.HandleAllocated);

  if Child = nil then
    raise ESciterNullPointerException.Create;

  SciterCheck(
    API.SciterInsertElement(Child.Handle, FElement, AIndex),
    'Failed to insert child element.'
  );
end;

function TElement.IsValid: Boolean;
begin
  Result := FElement <> nil;
end;

function TElement.PostEvent(EventCode: BEHAVIOR_EVENTS): Boolean;
begin
  Result := API.SciterPostEvent(FELEMENT, UINT(EventCode), nil, nil) = SCDOM_OK;
end;

procedure TElement.RemoveChildren;
begin
  SetText('');
end;

// TODO: Params
procedure TElement.Request(const Url: WideString; const RequestType: REQUEST_TYPE);
begin
  {
  SciterCheck(
    API.SciterHttpRequest(FElement, PWideChar(Url), 0, RequestType, nil, 0),
    'Failed to perform HTTP request.');
  }
  SciterCheck(
    API.SciterRequestElementData(FElement, PWideChar(Url), 0, nil),
    'Failed to initiate data request.'
  );
end;

procedure TElement.ScrollToView;
begin
  API.SciterScrollToView(FElement, 0);
end;

function TElement.Select(const Selector: WideString): IElement;
begin
  FHChild := nil;

  Result := nil;
  SciterCheck(
    API.SciterSelectElementsW(FELEMENT, PWideChar(Selector), @SelectSingleNodeCallback, Self),
    'The Select method failed. Check selector expression syntax.'
  );

  if FHChild <> nil then
    Result := ElementFactory(Sciter, FHChild)
  else
    Result := nil;
end;

function TElement.SelectAll(const Selector: WideString): IElementCollection;
var
  pResult: TElementCollection;
begin
  pResult := TElementCollection.Create(Self.Sciter);
  SciterCheck(
    API.SciterSelectElementsW(FELEMENT, PWideChar(Selector), @SelectorCallback, pResult),
    'The Select method failed. Check selector expression syntax.'
  );
  Result := pResult;
end;

function TElement.SendEvent(EventCode: BEHAVIOR_EVENTS): Boolean;
var
  handled: BOOL;
begin
  Result := API.SciterSendEvent(FELEMENT, UINT(EventCode), nil, nil, handled) = SCDOM_OK;
end;

procedure TElement.SetAttr(const AttrName, Value: WideString);
var
  sAttrName: AnsiString;
begin
  sAttrName := AnsiString(AttrName);
  SciterCheck(
    API.SciterSetAttributeByName(FElement, PAnsiChar(sAttrName), PWideChar(Value)),
    'Failed to set "%s" attribute value.',
    [AttrName]
  );
end;

procedure TElement.SetID(const Value: WideString);
begin
  Attr['id'] := Value;
end;

procedure TElement.SetInnerHtml(const Value: WideString);
var
  sStr: UTF8String;
  pStr: PAnsiChar;
  iLen: Integer;
begin
  sStr := UTF8Encode(Value);
  pStr := PAnsiChar(sStr);
  iLen := Length(sStr);

  SciterCheck(
    API.SciterSetElementHtml(FElement, PByte(pStr), iLen, SIH_REPLACE_CONTENT),
    'Failed to set the inner html property on element'
  );
end;

procedure TElement.SetOnControlEvent(const Value: TElementOnControlEvent);
begin
  FOnControlEvent := Value;
end;

procedure TElement.SetOnDataArrived(const Value: TElementOnDataArrived);
begin
  FOnDataArrived := Value;
end;

procedure TElement.SetOnFocus(const Value: TElementOnFocus);
begin
  FOnFocus := Value;
end;

procedure TElement.SetOnGesture(const Value: TElementOnGesture);
begin
  FOnGesture := Value;
end;

procedure TElement.SetOnKey(const Value: TElementOnKey);
begin
  FOnKey := Value;
end;

procedure TElement.SetOnMouse(const Value: TElementOnMouse);
begin
  FOnMouse := Value;
end;

procedure TElement.SetOnScriptingCall(const Value: TElementOnScriptingCall);
begin
  FOnScriptingCall := Value;
end;

procedure TElement.SetOnScroll(const Value: TElementOnScroll);
begin
  FOnScroll := Value;
end;

procedure TElement.SetOnSize(const Value: TElementOnSize);
begin
  FOnSize := Value;
end;

procedure TElement.SetOnTimer(const Value: TElementOnTimer);
begin
  FOnTimer := Value;
end;

procedure TElement.SetOuterHtml(const Value: WideString);
var
  sStr: UTF8String;
  pStr: PAnsiChar;
  iLen: Integer;
begin
  sStr := UTF8Encode(Value);
  pStr := PAnsiChar(sStr);
  iLen := Length(sStr);

  SciterCheck(
    API.SciterSetElementHtml(FElement, PByte(pStr), iLen, SOH_REPLACE),
    'Failed to set the outer html property on element'
  );
end;

procedure TElement.SetState(const Value: Integer);
begin
  API.SciterSetElementState(FElement, UINT(Value), 0, True);
end;

procedure TElement.SetStyleAttr(const AttrName, Value: WideString);
var
  sStyleAttrName: AnsiString;
begin
  sStyleAttrName := AnsiString(AttrName);

  SciterCheck(
    API.SciterSetStyleAttribute(FElement, PAnsiChar(sStyleAttrName), PWideChar(Value)),
    'Failed to set style attribute.'
  );
end;

procedure TElement.SetText(const Value: WideString);
begin
  SciterCheck(
    API.SciterSetElementText(FElement, PWideChar(Value), Length(Value)),
    'Failed to set element text.'
  );
end;

function TElement.SetTimer(const Milliseconds: UINT): UINT;
begin
  SciterCheck(
    API.SciterSetTimer(FElement, Milliseconds, Result),
    'Failed to set timer.'
  );
end;

procedure TElement.SetValue(Value: OleVariant);
var
  sValue: TSciterValue;
begin
  API.ValueInit(@sValue);
  V2S(Value, @sValue);
  SciterCheck(
    API.SciterSetValue(FElement, @sValue),
    'Failed to set element value.'
  );
end;

procedure TElement.StopTimer;
var
  tid: UINT;
begin
  SciterCheck(
    API.SciterSetTimer(FElement, 0, tid),
    'Failed to stop timer.',
    True);
end;

procedure TElement.Swap(const Element: IElement);
begin
  if Element = nil then
    raise ESciterNullPointerException.Create;
  SciterCheck(
    API.SciterSwapElements(FElement, Element.Handle),
    'Failed to swap elements.'
  );
end;

procedure TElement.ThrowException(const Message: String);
begin
  raise ESciterException.Create(Message);
end;

procedure TElement.ThrowException(const Message: String;
  const Args: array of const);
begin
  raise ESciterException.CreateFmt(Message, Args);
end;

function TElement.TryCall(const Method: WideString; const Args: array of OleVariant; out RetVal: OleVariant): Boolean;
var
  sMethod: AnsiString;
  sargs: array[0..255] of TSciterValue;
  sargc: UINT;
  i: Integer;
  pRetVal: TSciterValue;
begin
  API.ValueInit(@pRetVal);
  
  sargc := Length(Args);

  if sargc > 256 then
    raise ESciterException.Create('Too many arguments.');

  for i := Low(sargs) to High(sargs) do
    API.ValueInit(@sargs[i]);

  if sargc > 0 then
  begin
    for i := 0 to sargc - 1 do
    begin
      V2S(Args[i], @sargs[i]);
    end;
  end;
  sMethod := AnsiString(Method);

  API.ValueInit(@pRetVal);

  if API.SciterCallScriptingMethod(FElement, PAnsiChar(sMethod), @sargs[0], sargc, pRetVal) <> SCDOM_OK then
  begin
    RetVal := Unassigned;
    Result := False;
  end
    else
  begin
    S2V(@pRetVal, RetVal);
    Result := True;
  end;
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

function TElementCollection.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TElementCollection.GetItem(const Index: Integer): IElement;
var
  pElement: IElement;
begin
  pElement := FList[Index] as TElement;
  Result := pElement;
end;

procedure TElementCollection.RemoveAll;
var
  i: Integer;
begin
  for i := Count - 1 downto 0 do
  begin
    Item[i].Delete;
  end;
  FList.Clear;
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

{ TByteStream }

constructor TByteStream.Create(Ptr: PByte; Size: Integer);
begin
  inherited Create;
  SetPointer(Ptr, Size);
end;

function TByteStream.Write(const Buffer; Count: Integer): Longint;
begin
  raise ESciterException.Create('This stream is read-only.');
end;

initialization
  Behaviors := nil;
  CoInitialize(nil);
  OleInitialize(nil);

finalization
  if Assigned(Behaviors) then
    Behaviors.Free;

end.
