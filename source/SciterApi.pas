{*******************************************************}
{                                                       }
{  Sciter API                                           }
{  Copyright (c) Dmitry Baranov                         }
{                                                       }
{  This unit uses Sciter Engine,                        }
{  copyright Terra Informatica Software, Inc.           }
{  (http://terrainformatica.com/).                      }
{                                                       }
{*******************************************************}

unit SciterApi;

interface

uses Windows, Messages, Dialogs, Classes, Forms, Controls, SysUtils, ComObj, ActiveX,
  Variants, ExtCtrls, TiScriptApi;

const
  SIH_REPLACE_CONTENT      = 0;
  SIH_INSERT_AT_START      = 1;
  SIH_APPEND_AFTER_LAST    = 2;
  SOH_REPLACE              = 3;
  SOH_INSERT_BEFORE        = 4;
  SOH_INSERT_AFTER         = 5;

const
  HV_OK_TRUE               = -1;
  HV_OK                    = 0;
  HV_BAD_PARAMETER         = 1;
  HV_INCOMPATIBLE_TYPE     = 2;

const
  SC_LOAD_DATA             = $1;
  SC_DATA_LOADED           = $2;
  SC_DOCUMENT_COMPLETE     = $3 deprecated;
  SC_ATTACH_BEHAVIOR       = $4;
  SC_ENGINE_DESTROYED      = $5;
  SC_POSTED_NOTIFICATION   = $6;

const
  LOAD_OK     : UINT       = 0;
  LOAD_DISCARD: UINT       = 1;
  LOAD_DELAYED: UINT       = 2;

type
  SCDOM_RESULT =
  (
    SCDOM_OK                = 0,
    SCDOM_INVALID_HWND      = 1,
    SCDOM_INVALID_HANDLE    = 2,
    SCDOM_PASSIVE_HANDLE    = 3,
    SCDOM_INVALID_PARAMETER = 4,
    SCDOM_OPERATION_FAILED  = 5,
    SCDOM_OK_NOT_HANDLED    = -1,
    SCDOM_DUMMY             = MAXINT
  );

  HWINDOW = HWND;

  HELEMENT = Pointer;

  LPVOID   = Pointer;

  UINT_PTR = UINT;


  LPCSTR_RECEIVER = procedure(str: PAnsiChar; str_length: UINT; param : Pointer); stdcall;
  PLPCSTR_RECEIVER = ^LPCSTR_RECEIVER;


  LPCWSTR_RECEIVER = procedure(str: PWideChar; str_length: UINT; param: Pointer); stdcall;
  PLPCWSTR_RECEIVER = ^LPCWSTR_RECEIVER;


  LPCBYTE_RECEIVER = procedure(bytes: PByte; num_bytes: UINT; param: Pointer); stdcall;
  PLPCBYTE_RECEIVER = ^LPCBYTE_RECEIVER;


  SCITER_CALLBACK_NOTIFICATION = packed record
    code: UINT;
    hwnd: HWINDOW;
  end;
  LPSCITER_CALLBACK_NOTIFICATION = ^SCITER_CALLBACK_NOTIFICATION;


  SciterHostCallback = function(pns: LPSCITER_CALLBACK_NOTIFICATION; callbackParam: Pointer): UINT; stdcall;
  LPSciterHostCallback = ^SciterHostCallback;


  ElementEventProc = function(tag: Pointer; he: HELEMENT; evtg: UINT; prms: Pointer): BOOL; stdcall;
  LPELEMENT_EVENT_PROC = ^ElementEventProc;


  SciterResourceType { NB: UINT }  =
  (
    RT_DATA_HTML   = 0,
    RT_DATA_IMAGE  = 1,
    RT_DATA_STYLE  = 2,
    RT_DATA_CURSOR = 3,
    RT_DATA_SCRIPT = 4,
    RT_DATA_RAW    = 5,
    SciterResourceTypeDummy = MaxInt
  );

  SCITER_RT_OPTIONS { NB: UINT_PTR } = (
   SCITER_SMOOTH_SCROLL = 1,      // value:TRUE - enable, value:FALSE - disable, enabled by default
   SCITER_CONNECTION_TIMEOUT = 2, // value: milliseconds, connection timeout of http client
   SCITER_HTTPS_ERROR = 3,        // value: 0 - drop connection, 1 - use builtin dialog, 2 - accept connection silently
   SCITER_FONT_SMOOTHING = 4,     // value: 0 - system default, 1 - no smoothing, 2 - std smoothing, 3 - clear type
   SCITER_TRANSPARENT_WINDOW = 6, // Windows Aero support, value:
                                  // 0 - normal drawing,
                                  // 1 - window has transparent background after calls DwmExtendFrameIntoClientArea() or DwmEnableBlurBehindWindow().
   SCITER_SET_GPU_BLACKLIST  = 7, // hWnd = NULL,
                                  // value = LPCBYTE, json - GPU black list, see: gpu-blacklist.json resource.
   SCITER_SET_SCRIPT_RUNTIME_FEATURES = 8, // value - combination of SCRIPT_RUNTIME_FEATURES flags.
   SCITER_SET_GFX_LAYER = 9,      // hWnd = NULL, value - GFX_LAYER
   SCITER_SET_DEBUG_MODE = 10,    // hWnd, value - TRUE/FALSE
   SCITER_SET_UX_THEMING = 11     // hWnd = NULL, value - BOOL, TRUE - the engine will use "unisex" theme that is common for all platforms.
                                  // That UX theme is not using OS primitives for rendering input elements. Use it if you want exactly
                                  // the same (modulo fonts) look-n-feel on all platforms.
  );

  SCN_LOAD_DATA = packed record
             code: UINT;
             hwnd: HWINDOW;
              uri: LPCWSTR;
          outData: PBYTE;
      outDataSize: UINT;
         dataType: SciterResourceType;
        requestId: Pointer;
        principal: HELEMENT;
        initiator: HELEMENT;
  end;
  LPSCN_LOAD_DATA = ^SCN_LOAD_DATA;


  SCN_DATA_LOADED = packed record
            code: UINT;
            hwnd: HWINDOW;
             uri: LPCWSTR;
            data: PByte;
        dataSize: UINT;
        dataType: SciterResourceType;
          status: UINT;
  end;
  LPSCN_DATA_LOADED = ^SCN_DATA_LOADED;


  SCN_ATTACH_BEHAVIOR = packed record
            code: UINT;
            hwnd: HWINDOW;
         element: HELEMENT;
    behaviorName: PAnsiChar;
     elementProc: LPELEMENT_EVENT_PROC;
      elementTag: LPVOID
  end;
  LPSCN_ATTACH_BEHAVIOR = ^SCN_ATTACH_BEHAVIOR;


  SCN_ENGINE_DESTROYED = packed record
    code: UINT;
    hwnd: HWINDOW
  end;
  LPSCN_ENGINE_DESTROYED = ^SCN_ENGINE_DESTROYED;


  SCN_POSTED_NOTIFICATION = packed record
       code: UINT;
       hwnd: HWINDOW;
     wparam: UINT_PTR;
     lparam: UINT_PTR;
    lreturn: UINT_PTR;
  end;
  LPSCN_POSTED_NOTIFICATION = ^SCN_POSTED_NOTIFICATION;

  TProcPointer = procedure; stdcall;

  DEBUG_OUTPUT_PROC = procedure(param: Pointer; subsystem: UINT; severity: UINT; text: PWideChar; text_length: UINT); stdcall;
  PDEBUG_OUTPUT_PROC = ^DEBUG_OUTPUT_PROC;


  SciterElementCallback = function(he: HELEMENT; Param: Pointer ): BOOL; stdcall;
  PSciterElementCallback = ^SciterElementCallback;


  VALUE_STRING_CVT_TYPE =
  (
    CVT_SIMPLE,
    CVT_JSON_LITERAL,
    CVT_JSON_MAP,
    CVT_XJSON_LITERAL,
    VALUE_STRING_CVT_TYPE_DUMMY = MAXINT
  );


  TSciterValueType =
  (
    T_UNDEFINED,
    T_NULL,
    T_BOOL,
    T_INT,
    T_FLOAT,
    T_STRING,
    T_DATE,
    T_CURRENCY,
    T_LENGTH,
    T_ARRAY,
    T_MAP,
    T_FUNCTION,
    T_BYTES,
    T_OBJECT,
    T_DOM_OBJECT,
    T_DUMMY = MAXINT
  );


  EVENT_GROUPS =
  (
      HANDLE_INITIALIZATION        = $0000,
      HANDLE_MOUSE                 = $0001,
      HANDLE_KEY                   = $0002,
      HANDLE_FOCUS                 = $0004,
      HANDLE_SCROLL                = $0008,
      HANDLE_TIMER                 = $0010,
      HANDLE_SIZE                  = $0020,
      HANDLE_DATA_ARRIVED          = $080,
      HANDLE_BEHAVIOR_EVENT        = $0100,
      HANDLE_METHOD_CALL           = $0200,
      HANDLE_SCRIPTING_METHOD_CALL = $0400,
      HANDLE_TISCRIPT_METHOD_CALL  = $0800,
      HANDLE_EXCHANGE              = $1000,
      HANDLE_GESTURE               = $2000,
      HANDLE_ALL                   = $FFFF,
      SUBSCRIPTIONS_REQUEST        = -1,
      EVENT_GROUPS_DUMMY           = MAXINT
  );


  ELEMENT_STATE_BITS =
  (
   STATE_LINK             = $00000001,
   STATE_HOVER            = $00000002,
   STATE_ACTIVE           = $00000004,
   STATE_FOCUS            = $00000008,
   STATE_VISITED          = $00000010,
   STATE_CURRENT          = $00000020,
   STATE_CHECKED          = $00000040,
   STATE_DISABLED         = $00000080,
   STATE_READONLY         = $00000100,
   STATE_EXPANDED         = $00000200,
   STATE_COLLAPSED        = $00000400,
   STATE_INCOMPLETE       = $00000800,
   STATE_ANIMATING        = $00001000,
   STATE_FOCUSABLE        = $00002000,
   STATE_ANCHOR           = $00004000,
   STATE_SYNTHETIC        = $00008000,
   STATE_OWNS_POPUP       = $00010000,
   STATE_TABFOCUS         = $00020000,
   STATE_EMPTY            = $00040000,
   STATE_BUSY             = $00080000,
   STATE_DRAG_OVER        = $00100000,
   STATE_DROP_TARGET      = $00200000,
   STATE_MOVING           = $00400000,
   STATE_COPYING          = $00800000,
   STATE_DRAG_SOURCE      = $01000000,
   STATE_DROP_MARKER      = $02000000,
   STATE_PRESSED          = $04000000,
   STATE_POPUP            = $08000000,
   STATE_IS_LTR           = $10000000,
   STATE_IS_RTL           = $20000000,
   ELEMENT_STATE_BITS_DUMMY = MAXINT
  );


  ELEMENT_AREAS =
  (
    ROOT_RELATIVE      = 1,
    SELF_RELATIVE      = 2,
    CONTAINER_RELATIVE = 3,
    VIEW_RELATIVE      = 4,
    CONTENT_BOX        = 0,
    PADDING_BOX        = $10,
    BORDER_BOX         = $20,
    MARGIN_BOX         = $30,
    BACK_IMAGE_AREA    = $40,
    FORE_IMAGE_AREA    = $50,
    SCROLLABLE_AREA    = $60,
    ELEMENT_AREAS_DUMMY = MAXINT
  );


  TSciterValue = record
    t: UINT;
    u: UINT;
    d: UInt64;
  end;
  PSciterValue = ^TSciterValue;

  TSciterValueArray = array[0..$FFFF] of TSciterValue;
  PSciterValueArray = ^TSciterValueArray;

  BEHAVIOR_METHOD_IDENTIFIERS =
  (
    DO_CLICK = 0,
    GET_TEXT_VALUE = 1,
    SET_TEXT_VALUE,
      // p - TEXT_VALUE_PARAMS

    TEXT_EDIT_GET_SELECTION,
      // p - TEXT_EDIT_SELECTION_PARAMS

    TEXT_EDIT_SET_SELECTION,
      // p - TEXT_EDIT_SELECTION_PARAMS

    // Replace selection content or insert text at current caret position.
    // Replaced text will be selected.
    TEXT_EDIT_REPLACE_SELECTION,
      // p - TEXT_EDIT_REPLACE_SELECTION_PARAMS

    // Set value of type="vscrollbar"/"hscrollbar"
    SCROLL_BAR_GET_VALUE,
    SCROLL_BAR_SET_VALUE,

    TEXT_EDIT_GET_CARET_POSITION, 
    TEXT_EDIT_GET_SELECTION_TEXT, // p - TEXT_SELECTION_PARAMS
    TEXT_EDIT_GET_SELECTION_HTML, // p - TEXT_SELECTION_PARAMS
    TEXT_EDIT_CHAR_POS_AT_XY,     // p - TEXT_EDIT_CHAR_POS_AT_XY_PARAMS

    IS_EMPTY      = $FC,       // p - IS_EMPTY_PARAMS // set VALUE_PARAMS::is_empty (false/true) reflects :empty state of the element.
    GET_VALUE     = $FD,       // p - VALUE_PARAMS
    SET_VALUE     = $FE,       // p - VALUE_PARAMS

    FIRST_APPLICATION_METHOD_ID = $100,
    BEHAVIOR_METHOD_IDENTIFIERS_DUMMY = MAXINT
  );

  METHOD_PARAMS = record
    methodID: BEHAVIOR_METHOD_IDENTIFIERS;
  end;
  PMETHOD_PARAMS = ^METHOD_PARAMS;

  IS_EMPTY_PARAMS = packed record
    methodID: BEHAVIOR_METHOD_IDENTIFIERS;
    is_empty: UINT;
  end;
  PIS_EMPTY_PARAMS = ^IS_EMPTY_PARAMS;


  REQUEST_PARAM = record
    name: PWideChar;
    value: PWideChar;
  end;
  PREQUEST_PARAM = ^REQUEST_PARAM;


  BEHAVIOR_EVENTS =
  (
    BUTTON_CLICK = 0,
    BUTTON_PRESS = 1,
    BUTTON_STATE_CHANGED = 2,
    EDIT_VALUE_CHANGING = 3,
    EDIT_VALUE_CHANGED = 4,
    SELECT_SELECTION_CHANGED = 5,
    SELECT_STATE_CHANGED = 6,
    POPUP_REQUEST   = 7,
    POPUP_READY     = 8,
    POPUP_DISMISSED = 9,
    MENU_ITEM_ACTIVE = $A,
    MENU_ITEM_CLICK = $B,
    CONTEXT_MENU_REQUEST = $10,
    VISIUAL_STATUS_CHANGED = $11,
    DISABLED_STATUS_CHANGED = $12,
    POPUP_DISMISSING = $13,
    CONTENT_CHANGED = $15,
    HYPERLINK_CLICK = $80,
    ELEMENT_COLLAPSED = $90,
    ELEMENT_EXPANDED,
    ACTIVATE_CHILD,
    INIT_DATA_VIEW,
    ROWS_DATA_REQUEST,
    UI_STATE_CHANGED,
    FORM_SUBMIT,
    FORM_RESET,
    DOCUMENT_COMPLETE,
    HISTORY_PUSH,
    HISTORY_DROP,
    HISTORY_PRIOR,
    HISTORY_NEXT,
    HISTORY_STATE_CHANGED,
    CLOSE_POPUP,
    REQUEST_TOOLTIP,
    ANIMATION         = $A0,
    DOCUMENT_CREATED  = $C0,
    VIDEO_INITIALIZED = $D1,
    VIDEO_STARTED     = $D2,
    VIDEO_STOPPED     = $D3,
    VIDEO_BIND_RQ     = $D4,
    FIRST_APPLICATION_EVENT_CODE = $100,
    BEHAVIOR_EVENTS_DUMMY = MAXINT
  );

  BEHAVIOR_EVENT_PARAMS = packed record
         cmd: BEHAVIOR_EVENTS;
    heTarget: HELEMENT;
          he: HELEMENT;
      reason: Pointer;
        data: TSciterValue;
  end;
  PBEHAVIOR_EVENT_PARAMS = ^BEHAVIOR_EVENT_PARAMS;


  SciterWindowDelegate = function(hwnd: HWINDOW; msg: UINT; w: WParam; l: LPARAM; pParam: LPVOID; var pResult: LRESULT): BOOL; stdcall;
  PSciterWindowDelegate = ^SciterWindowDelegate;

  ISciterAPI = packed record
    Version: UINT;
    SciterClassName: function: LPCWSTR; stdcall;
    SciterVersion: function(major: BOOL): UINT; stdcall;
    SciterDataReady: function(hwnd: HWINDOW; uri: PWideChar; data: PByte; dataLength: UINT): BOOL; stdcall;
    SciterDataReadyAsync: function(hwnd: HWINDOW; uri: PWideChar; data: PByte; dataLength: UINT; requestId: LPVOID): BOOL; stdcall;
    SciterProc: function(hwnd: HWINDOW; msg: Cardinal; wParam: Integer; lParam: Integer): LRESULT; stdcall;
    SciterProcND: function(hwnd: HWINDOW; msg: Cardinal; wParam: Integer; lParam: Integer; var pbHANDLED: Integer): LRESULT; stdcall;
    SciterLoadFile: function(hWndSciter: HWINDOW; filename:LPCWSTR): BOOL; stdcall;
    SciterLoadHtml: function(hWndSciter: HWINDOW; html: PByte; htmlSize: UINT; baseUrl: PWideChar): BOOL; stdcall;
    SciterSetCallback: procedure(hWndSciter: HWINDOW; cb: LPSciterHostCallback; cbParam: Pointer); stdcall;
    SciterSetMasterCSS: function(utf: PAnsiChar; numBytes: UINT): BOOL; stdcall;
    SciterAppendMasterCSS: function(utf: PAnsiChar; numBytes: UINT): BOOL; stdcall;
    SciterSetCSS: function(hWndSciter: HWindow; utf8: PAnsiChar; numBytes: UINT; baseUrl: PWideChar; mediaType: PWideChar): BOOL; stdcall;
    SciterSetMediaType: function(hWndSciter: HWINDOW; mediaTYpe: PWideChar): BOOL; stdcall;
    SciterSetMediaVars: function(hWndSciter: HWINDOW; const mediaVars: PSciterValue): BOOL; stdcall;
    SciterGetMinWidth: function(hwnd: HWINDOW): UINT; stdcall;
    SciterGetMinHeight: function(hwnd: HWINDOW; width: UINT): UINT; stdcall;
    SciterCall: function(hWnd: HWINDOW; functionName: PAnsiChar; argc: UINT; argv: PSciterValue; var retval: TSciterValue): BOOL; stdcall;
    SciterEval: function(hwnd: HWINDOW; script: PWideChar; scriptLength: UINT; var pretval: TSciterValue): BOOL; stdcall;
    SciterUpdateWindow: procedure(hwnd: HWINDOW); stdcall;
    SciterTranslateMessage: function(var lpMsg: TMsg): BOOL; stdcall;
    SciterSetOption: function(hwnd: HWINDOW; option: SCITER_RT_OPTIONS; value: UINT_PTR): BOOL; stdcall;
    SciterGetPPI: procedure(hWndSciter: HWINDOW; var px: UINT; var py: UINT); stdcall;
    SciterGetViewExpando: function( hwnd: HWINDOW; pval: PSciterValue ): BOOL; stdcall;
    SciterEnumUrlData: Pointer;  // TODO:
    SciterRenderD2D: TProcPointer;
    SciterD2DFactory: TProcPointer;
    SciterDWFactory: TProcPointer;
    SciterGraphicsCaps: function(var pcaps: UINT): BOOL; stdcall;
    SciterSetHomeURL: function(hWndSciter: HWINDOW; baseUrl: PWideChar): BOOL; stdcall;
    SciterCreateWindow: function( creationFlags: UINT; var frame: TRect; delegate: PSciterWindowDelegate; delegateParam: LPVOID; parent: HWINDOW): HWINDOW; stdcall;
    SciterSetupDebugOutput: procedure(hwndOrNull: HWINDOW; param: Pointer; pfOutput: PDEBUG_OUTPUT_PROC); stdcall;
    SciterDebugSetupClient: TProcPointer;
    SciterDebugAddBreakpoint: TProcPointer;
    SciterDebugRemoveBreakpoint: TProcPointer;
    SciterDebugEnumBreakpoints: TProcPointer;

//|
//| DOM Element API
//|

    Sciter_UseElement: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    Sciter_UnuseElement: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetRootElement: function(hwnd: HWINDOW; var Handle: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetFocusElement: function(hwnd: HWINDOW; var Handle: HELEMENT): SCDOM_RESULT; stdcall;
    SciterFindElement: function(hwnd: HWINDOW; Point: TPoint; var Handle: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetChildrenCount: function(he: HELEMENT; var count: UINT): SCDOM_RESULT; stdcall;
    SciterGetNthChild: function(he: HELEMENT; index: UINT; var retval: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetParentElement: function(he: HELEMENT; var p_parent_he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetElementHtmlCB: function(he: HELEMENT; Outer: BOOL; Callback: PLPCBYTE_RECEIVER; Param: Pointer ): SCDOM_RESULT; stdcall;
    SciterGetElementTextCB: function(he: HELEMENT; callback: PLPCWSTR_RECEIVER; Param: Pointer): SCDOM_RESULT; stdcall;
    SciterSetElementText: function(he: HELEMENT; Value: PWideChar; Len: UINT): SCDOM_RESULT; stdcall;
    SciterGetAttributeCount: function(he: HELEMENT; var Count: UINT): SCDOM_RESULT; stdcall;
    SciterGetNthAttributeNameCB: function(he: HELEMENT; n: UINT; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): SCDOM_RESULT; stdcall;
    SciterGetNthAttributeValueCB: function(he: HELEMENT; n: UINT; rcv: PLPCWSTR_RECEIVER; rcv_param: LPVOID): SCDOM_RESULT; stdcall;
    SciterGetAttributeByNameCB: function(he: HELEMENT; name: PAnsiChar; rcv: PLPCWSTR_RECEIVER; rcv_param: Pointer): SCDOM_RESULT; stdcall;
    SciterSetAttributeByName: function(he: HELEMENT; name: PAnsiChar; value: PWideChar): SCDOM_RESULT; stdcall;
    SciterClearAttributes: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetElementIndex: function(he: HELEMENT; var p_index: UINT): SCDOM_RESULT; stdcall;
    SciterGetElementType: function(he: HELEMENT; var s: LPCSTR): SCDOM_RESULT; stdcall;
    SciterGetElementTypeCB: function(he: HELEMENT; rcv: PLPCSTR_RECEIVER; rcv_param: Pointer): SCDOM_RESULT; stdcall;
    SciterGetStyleAttributeCB: function(he: HELEMENT; name: PAnsiChar; rcv: PLPCWSTR_RECEIVER; rcv_param: Pointer): SCDOM_RESULT; stdcall;
    SciterSetStyleAttribute: function(he: HELEMENT; name: PAnsiChar; value: PWideChar): SCDOM_RESULT; stdcall;
    SciterGetElementLocation: function(he: HELEMENT; var p_location: TRect; areas: ELEMENT_AREAS): SCDOM_RESULT; stdcall;
    SciterScrollToView: function(he: HELEMENT; SciterScrollFlags: UINT): SCDOM_RESULT; stdcall;
    SciterUpdateElement: function(he: HELEMENT; andForceRender: BOOL): SCDOM_RESULT; stdcall;
    SciterRefreshElementArea: function(he: HELEMENT; rc: TRect): SCDOM_RESULT; stdcall;
    SciterSetCapture: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterReleaseCapture: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetElementHwnd: function(he: HELEMENT; var p_hwnd: HWND; rootWindow: BOOL): SCDOM_RESULT; stdcall;  
    SciterCombineURL: function(he: HELEMENT; szUrlBuffer: PWideChar; UrlBufferSize: UINT): SCDOM_RESULT; stdcall;
    SciterSelectElements: function(he: HELEMENT; CSS_selectors: PAnsiChar; Callback: PSciterElementCallback; Param: Pointer): SCDOM_RESULT; stdcall;
    SciterSelectElementsW: function(he: HELEMENT; CSS_selectors: PWideChar; Callback: PSciterElementCallback; Param: Pointer): SCDOM_RESULT; stdcall;
    SciterSelectParent: function(he: HELEMENT; selector: PAnsiChar; depth: UINT; var heFound: HELEMENT): SCDOM_RESULT; stdcall;
    SciterSelectParentW: function(he: HELEMENT; selector: PWideChar; depth: UINT; var heFound: HELEMENT): SCDOM_RESULT; stdcall;
    SciterSetElementHtml: function(he: HELEMENT; html: PByte; htmlLength: UINT; where: UINT): SCDOM_RESULT; stdcall;
    SciterGetElementUID: function(he: HELEMENT; var puid: UINT): SCDOM_RESULT; stdcall;
    SciterGetElementByUID: function(hwnd: HELEMENT; uid: UINT; var phe: HELEMENT): SCDOM_RESULT; stdcall;
    SciterShowPopup: function(popup: HELEMENT; Anchor: HELEMENT; placement: UINT): SCDOM_RESULT; stdcall;
    SciterShowPopupAt: function(Popup: HELEMENT; pos: TPoint; animate: BOOL): SCDOM_RESULT; stdcall;
    SciterHidePopup: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetElementState: function(he: HELEMENT; var pstateBits: UINT): SCDOM_RESULT; stdcall;
    SciterSetElementState: function(he: HELEMENT; stateBitsToSet: UINT; stateBitsToClear: UINT; updateView: BOOL): SCDOM_RESULT; stdcall;
    SciterCreateElement: function(const tagname: PAnsiChar; const textOrNull: PWideChar; var phe: HELEMENT): SCDOM_RESULT; stdcall;
    SciterCloneElement: function(he: HELEMENT; var phe: HELEMENT): SCDOM_RESULT; stdcall;
    SciterInsertElement: function(he: HELEMENT; hparent: HELEMENT; index: UINT): SCDOM_RESULT; stdcall;
    SciterDetachElement: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterDeleteElement: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterSetTimer: function(he: HELEMENT; milliseconds: UINT; var timer_id: UINT ): SCDOM_RESULT; stdcall;
    SciterDetachEventHandler: function(he: HELEMENT; pep: LPELEMENT_EVENT_PROC; tag: Pointer): SCDOM_RESULT; stdcall;
    SciterAttachEventHandler: function(he: HELEMENT; pep: LPELEMENT_EVENT_PROC; tag: Pointer): SCDOM_RESULT; stdcall;
    SciterWindowAttachEventHandler: function(hwndLayout: HWINDOW; pep: LPELEMENT_EVENT_PROC; tag: LPVOID; subscription: UINT): SCDOM_RESULT; stdcall;
    SciterWindowDetachEventHandler: function(hwndLayout: HWINDOW; pep: LPELEMENT_EVENT_PROC; tag: LPVOID): SCDOM_RESULT; stdcall;
    SciterSendEvent: function(he: HELEMENT; appEventCode: UINT; heSource: HELEMENT; reason: PUINT; var handled: BOOL): SCDOM_RESULT; stdcall;
    SciterPostEvent: function(he: HELEMENT; appEventCode: UINT; heSource: HELEMENT; reason: PUINT): SCDOM_RESULT; stdcall;
    SciterCallBehaviorMethod: function(he: HELEMENT; params: PMETHOD_PARAMS): SCDOM_RESULT; stdcall;
    SciterRequestElementData: function(he: HELEMENT; url: PWideChar; dataType: UINT; initiator: HELEMENT ): SCDOM_RESULT; stdcall;
    SciterHttpRequest: function( he: HELEMENT; url: PWideChar; dataType: UINT;
      requestType: UINT; requestParams: PREQUEST_PARAM;
      nParams: UINT): SCDOM_RESULT; stdcall;
    SciterGetScrollInfo: function(he: HELEMENT; var scrollPos: TPoint; var viewRect:TRect; var contentSize: TSize): SCDOM_RESULT; stdcall;
    SciterSetScrollPos: function(he: HELEMENT; scrollPos: TPoint; smooth: BOOL): SCDOM_RESULT; stdcall;
    SciterGetElementIntrinsicWidths: function(he: HELEMENT; var pMinWidth: integer; var pMaxWidth: integer): SCDOM_RESULT; stdcall;
    SciterGetElementIntrinsicHeight: function(he: HELEMENT; forWidth: Integer; var pHeight: integer): SCDOM_RESULT; stdcall;
    SciterIsElementVisible: function(he: HELEMENT; var pVisible: BOOL): SCDOM_RESULT; stdcall;
    SciterIsElementEnabled: function(he: HELEMENT; var pEnabled: BOOL): SCDOM_RESULT; stdcall;
    SciterSortElements: TProcPointer;
    SciterSwapElements: function( he1: HELEMENT; he2: HELEMENT ): SCDOM_RESULT; stdcall;
    SciterTraverseUIEvent: function( evt: UINT; eventCtlStruct: LPVOID ; var bOutProcessed: BOOL): SCDOM_RESULT; stdcall;
    SciterCallScriptingMethod: function(he: HELEMENT; name: PAnsiChar; argv: PSciterValue; argc: UINT; var retval: TSciterValue): SCDOM_RESULT; stdcall;
    SciterCallScriptingFunction: function(he: HELEMENT; name: PAnsiChar; argv: PSciterValue; argc: UINT; var retval: TSciterValue): SCDOM_RESULT; stdcall;
    SciterEvalElementScript: function(he: HELEMENT; script: PWideChar; scriptLength: UINT; var retval: TSciterValueType): SCDOM_RESULT; stdcall;
    SciterAttachHwndToElement: function(he: HELEMENT; hwnd: HWINDOW): SCDOM_RESULT; stdcall;
    SciterControlGetType: TProcPointer;
    SciterGetValue: function(he: HELEMENT; Value: PSciterValue): SCDOM_RESULT; stdcall;  
    SciterSetValue: function(he: HELEMENT; Value: PSciterValue): SCDOM_RESULT; stdcall;
    SciterGetExpando: TProcPointer;
    SciterGetObject: function(he: HELEMENT; var pval: tiscript_value; forceCreation: BOOL): SCDOM_RESULT; stdcall;
    SciterGetElementNamespace: function(he: HELEMENT; var pval: tiscript_value): SCDOM_RESULT; stdcall;
    SciterGetHighlightedElement: function(h: HWINDOW; var he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterSetHighlightedElement: function(h: HWINDOW; he: HELEMENT): SCDOM_RESULT; stdcall;

    SciterNodeAddRef: TProcPointer;
    SciterNodeRelease: TProcPointer;
    SciterNodeCastFromElement: TProcPointer;
    SciterNodeCastToElement: TProcPointer;
    SciterNodeFirstChild: TProcPointer;
    SciterNodeLastChild: TProcPointer;
    SciterNodeNextSibling: TProcPointer;
    SciterNodePrevSibling: TProcPointer;
    SciterNodeParent: TProcPointer;
    SciterNodeNthChild: TProcPointer;
    SciterNodeChildrenCount: TProcPointer;
    SciterNodeType: TProcPointer;
    SciterNodeGetText: TProcPointer;
    SciterNodeSetText: TProcPointer;
    SciterNodeInsert: TProcPointer;
    SciterNodeRemove: TProcPointer;
    SciterCreateTextNode: TProcPointer;
    SciterCreateCommentNode: TProcPointer;

    ValueInit: function(Value: PSciterValue): UINT; stdcall;
    ValueClear: function(Value: PSciterValue): UINT; stdcall;
    ValueCompare: function(Value1: PSciterValue; Value2: PSciterValue): UINT; stdcall;
    ValueCopy: function(dst: PSciterValue; src: PSciterValue): UINT; stdcall;
    ValueIsolate: TProcPointer;
    ValueType: function(Value: PSciterValue; var pType: TSciterValueType; var pUnits: UINT): UINT; stdcall;
    ValueStringData: function(Value: PSciterValue; var Chars: PWideChar; var NumChars: UINT): UINT; stdcall;
    ValueStringDataSet: function(Value: PSciterValue; Chars: PWideChar; NumChars: UINT; Units: UINT): UINT; stdcall;
    ValueIntData: function(Value: PSciterValue; var pData: Integer): UINT; stdcall;
    ValueIntDataSet:function(Value: PSciterValue; data: Integer; iType: TSciterValueType; units: UINT): UINT; stdcall;
    ValueInt64Data: function(Value: PSciterValue; var pData: Int64): UINT; stdcall;
    ValueInt64DataSet: function(Value: PSciterValue; data: Int64; iType: TSciterValueType; units: UINT): UINT; stdcall;
    ValueFloatData: function(Value: PSciterValue; var pData: double): UINT; stdcall;
    ValueFloatDataSet: function(Value: PSciterValue; data: double; iType: TSciterValueType; units: UINT): UINT; stdcall;
    ValueBinaryData: function(Value: PSciterValue; var bytes: PByte; var pnBytes: UINT): UINT; stdcall; 
    ValueBinaryDataSet: function(Value: PSciterValue; bytes: PByte; nBytes: UINT; pType: TSciterValueType; units: UINT): UINT; stdcall;
    ValueElementsCount: function(Value: PSciterValue; var pData: UINT): UINT; stdcall;
    ValueNthElementValue : function(Value: PSciterValue; n: Integer; pretval: PSciterValue): UINT; stdcall;
    ValueNthElementValueSet: function(pval: PSciterValue; n: Integer; pval_to_set: PSciterValue): UINT; stdcall;
    ValueNthElementKey: TProcPointer;
    ValueEnumElements: TProcPointer;
    ValueSetValueToKey: TProcPointer;
    ValueGetValueOfKey: TProcPointer;
    ValueToString: function(Value: PSciterValue; How: VALUE_STRING_CVT_TYPE): UINT; stdcall;
    ValueFromString: function(Value: PSciterValue; str: PWideChar; strLength: UINT; how: VALUE_STRING_CVT_TYPE): UINT; stdcall;
    ValueInvoke: TProcPointer;
    ValueNativeFunctorSet: TProcPointer;
    ValueIsNativeFunctor: TProcPointer;

    // tiscript VM API
    TIScriptAPI: function: ptiscript_native_interface; stdcall;

    SciterGetVM: function(h: HWND): HVM; stdcall;

    // Sciter_v2V
    Sciter_T2S: function(vm: HVM; script_value: tiscript_value; var sciter_value: TSciterValue; isolate: BOOL): BOOL; stdcall;
    Sciter_S2T: function(vm: HVM; value: PSciterValue; var out_script_value: tiscript_value): BOOL; stdcall;

    SciterOpenArchive: TProcPointer;
    SciterGetArchiveItem: TProcPointer;
    SciterCloseArchive: TProcPointer;

    SciterFireEvent: function(var evt: BEHAVIOR_EVENT_PARAMS; post: BOOL; var handled: BOOL): SCDOM_RESULT; stdcall;

    SciterGetCallbackParam: TProcPointer;
    SciterPostCallback: TProcPointer;
  end;

  PSciterApi = ^ISciterAPI;
  
  
  SciterApiFunc = function: PSciterApi; stdcall;
  PSciterApiFunc = ^SciterApiFunc;


  INITIALIZATION_EVENTS =
  (
    BEHAVIOR_DETACH = 0,
    BEHAVIOR_ATTACH = 1,
    INITIALIZATION_EVENTS_DUMMY = MAXINT
  );


  INITIALIZATION_PARAMS = packed record
    cmd: INITIALIZATION_EVENTS;
  end;
  PINITIALIZATION_PARAMS = ^INITIALIZATION_PARAMS;


  KEYBOARD_STATES =
  (
    CONTROL_KEY_PRESSED = 1,
    SHIFT_KEY_PRESSED = 2,
    ALT_KEY_PRESSED = 4,
    KEYBOARD_STATES_DUMMY = MAXINT
  );


  CURSOR_TYPE =
  (
    CURSOR_ARROW,
    CURSOR_IBEAM,
    CURSOR_WAIT,
    CURSOR_CROSS,
    CURSOR_UPARROW,
    CURSOR_SIZENWSE,
    CURSOR_SIZENESW,
    CURSOR_SIZEWE,
    CURSOR_SIZENS,
    CURSOR_SIZEALL,
    CURSOR_NO,
    CURSOR_APPSTARTING,
    CURSOR_HELP,
    CURSOR_HAND,
    CURSOR_DRAG_MOVE,
    CURSOR_DRAG_COPY,
    CURSOR_OTHER,
    CURSOR_TYPE_DUMMY = MAXINT
  );


  MOUSE_EVENTS =
  (
    MOUSE_ENTER  = 0,
    MOUSE_LEAVE  = 1,
    MOUSE_MOVE   = 2,
    MOUSE_UP     = 3,
    MOUSE_DOWN   = 4,
    MOUSE_DCLICK = 5,
    MOUSE_WHEEL  = 6,
    MOUSE_TICK   = 7,
    MOUSE_IDLE   = 8,
    DROP         = 9,
    DRAG_ENTER   = 10,
    DRAG_LEAVE   = 11,
    DRAG_REQUEST = 12,
    MOUSE_CLICK  = $FF,
    DRAGGING     = $100,
    MOUSE_EVENTS_DUMMY = MAXINT
  );


  MOUSE_BUTTONS =
  (
    MAIN_MOUSE_BUTTON    = 1,
    PROP_MOUSE_BUTTON    = 2,
    MIDDLE_MOUSE_BUTTON  = 4,
    MOUSE_BUTTONS_DUMMY  = MAXINT
  );


  MOUSE_PARAMS = packed record
             cmd: MOUSE_EVENTS;
          target: HELEMENT;
             pos: TPoint;
        pos_view: TPoint;
    button_state: MOUSE_BUTTONS;
       alt_state: KEYBOARD_STATES;
     cursor_type: CURSOR_TYPE;
      is_on_icon: BOOL;
        dragging: HELEMENT;
   dragging_mode: UINT;
  end;
  PMOUSE_PARAMS = ^MOUSE_PARAMS;


  KEY_EVENTS =
  (
    KEY_DOWN = 0,
    KEY_UP,
    KEY_CHAR,
    KEY_EVENTS_DUMMY = MAXINT
  );

  KEY_PARAMS = packed record
          cmd: KEY_EVENTS;
       target: HELEMENT;
     key_code: UINT;
    alt_state: KEYBOARD_STATES;
  end;
  PKEY_PARAMS = ^KEY_PARAMS;


  FOCUS_EVENTS =
  (
    LOST_FOCUS,
    GOT_FOCUS,
    FOCUS_EVENTS_DUMMY = MAXINT
  );


  FOCUS_PARAMS = packed record
               cmd: FOCUS_EVENTS;
            target: HELEMENT;
    by_mouse_click: BOOL;
            cancel: BOOL;
  end;
  PFOCUS_PARAMS = ^FOCUS_PARAMS;


  DATA_ARRIVED_PARAMS = packed record
    initiator: HELEMENT;
         data: PByte;
     dataSize: UINT;
     dataType: UINT;
       status: UINT;
          uri: PWideChar;
  end;
  PDATA_ARRIVED_PARAMS = ^DATA_ARRIVED_PARAMS;

  DRAW_EVENTS =
  (
      DRAW_BACKGROUND = 0,
      DRAW_CONTENT = 1,
      DRAW_FOREGROUND = 2,
      DRAW_EVENTS_DUMMY = MAXINT
  );

  DRAW_PARAMS = packed record
    cmd: DRAW_EVENTS;
    hdc: HDC;
    area: TRect;
    reserved: UINT;
  end;
  PDRAW_PARAMS=^DRAW_PARAMS;


  TIMER_PARAMS = packed record
    timerId: Pointer;
  end;
  PTIMER_PARAMS = ^TIMER_PARAMS;


  SCRIPTING_METHOD_PARAMS = record
    name: PAnsiChar;
    argv: PSciterValue; // SCITER_VALUE*
    argc: UINT;
    rv: TSciterValue;
  end;
  PSCRIPTING_METHOD_PARAMS = ^SCRIPTING_METHOD_PARAMS;


  TISCRIPT_METHOD_PARAMS = record
    vm: HVM;
    tag: tiscript_value;
    result: tiscript_value;
  end;
  PTISCRIPT_METHOD_PARAMS = ^TISCRIPT_METHOD_PARAMS;


  SCROLL_EVENTS =
  (
    SCROLL_HOME,
    SCROLL_END,
    SCROLL_STEP_PLUS,
    SCROLL_STEP_MINUS,
    SCROLL_PAGE_PLUS,
    SCROLL_PAGE_MINUS,
    SCROLL_POS,
    SCROLL_SLIDER_RELEASED,
    SCROLL_CORNER_PRESSED,
    SCROLL_CORNER_RELEASED,
    SCROLL_EVENTS_DUMMY = MAXINT
  );

  SCROLL_PARAMS = packed record
    cmd: SCROLL_EVENTS;
    target: HELEMENT;
    pos: integer;
    vertical: BOOL;
  end;
  PSCROLL_PARAMS = ^SCROLL_PARAMS;


  { Inspector }
  TSciterInspector = procedure(root: HELEMENT; papi: PSciterApi); stdcall;
  TSciterWindowInspector = procedure(hwndSciter: HWINDOW; papi: PSciterApi); stdcall;


  { Exceptions }
  ESciterException = class(Exception)
  end;

  ESciterNullPointerException = class(ESciterException)
  public
    constructor Create;
  end;

  ESciterCallException = class(ESciterException)
  public
    constructor Create(const MethodName: String);
  end;

  ESciterNotImplementedException = class(ESciterException)
  end;

function _SciterAPI: PSciterApi; stdcall;

{ Conversion functions. Mnemonics are: T - tiscript_value, S - TSciterValue, V - VARIANT }
function  S2V(Value: PSciterValue; var OleValue: OleVariant): UINT;
function  V2S(const Value: OleVariant; SciterValue: PSciterValue): UINT;
function  T2V(const vm: HVM; Value: tiscript_value): OleVariant;
function  V2T(const vm: HVM; const Value: OleVariant): tiscript_value;

function  API: PSciterApi;
function NI: ptiscript_native_interface;
function IsNameExists(const vm: HVM; const Name: WideString): boolean;
function IsNativeClassExists(const vm: HVM; const Name: WideString): boolean;
function GetNativeObject(const vm: HVM; const Name: WideString): tiscript_value;
function GetNativeClass(const vm: HVM; const ClassName: WideString): tiscript_class;
function RegisterNativeFunction(const vm: HVM; const Name: WideString; Handler: ptiscript_method; ThrowIfExists: Boolean = False): Boolean;
function RegisterNativeClass(const vm: HVM; ClassDef: ptiscript_class_def; ThrowIfExists: Boolean; ReplaceClassDef: Boolean): tiscript_class;
function CreateObjectInstance(const vm: HVM; Obj: Pointer; OfClass: tiscript_class): tiscript_object; overload;
function CreateObjectInstance(const vm: HVM; Obj: Pointer; OfClass: WideString): tiscript_object; overload;
procedure RegisterObject(const vm: HVM; Obj: tiscript_object; const VarName: WideString); overload;
procedure RegisterObject(const vm: HVM; Obj: Pointer; const OfClass: WideString; const VarName: WideString); overload;
function SciterVarType(value: PSciterValue): TSciterValueType;
function SciterVarToString(value: PSciterValue): WideString;
procedure ThrowError(const vm: HVM; const Message: AnsiString); overload;
procedure ThrowError(const vm: HVM; const Message: WideString); overload;
function GetNativeObjectJson(const Value: PSciterValue): WideString;

implementation

var
  FAPI: PSciterApi;
  FNI: ptiscript_native_interface;
  HSCITER: HMODULE;

function GetNativeObjectJson(const Value: PSciterValue): WideString;
var
  pWStr: PWideChar;
  iNum: UINT;
  pType: TSciterValueType;
  pUnits: UINT;
begin
  pUnits := 0;
  API.ValueType(Value, pType, pUnits);
  if (pType = T_NULL) or (pType = T_UNDEFINED) then
  begin
    Result := '';
    Exit;
  end;
  
  API.ValueToString(Value, CVT_XJSON_LITERAL);
  API.ValueStringData(Value, pWStr, iNum);
  Result := WideString(pWstr);
end;

function NI: ptiscript_native_interface;
begin
  if FNI = nil then
  begin
    if FAPI = nil then
      raise ESciterException.Create('Sciter DLL is not loaded.');
    FNI := FAPI.TIScriptAPI;
  end;
  Result := FNI;
end;

procedure ThrowError(const vm: HVM; const Message: AnsiString);
begin
  NI.throw_error(vm, PWideChar(WideString(Message)));
end;

procedure ThrowError(const vm: HVM; const Message: WideString);
begin
  NI.throw_error(vm, PWideChar(Message));
end;

function IsNativeClassExists(const vm: HVM; const Name: WideString): boolean;
var
  var_name: tiscript_string;
  var_value: tiscript_object;
  zns: tiscript_value;
begin
  Result := False;

  zns := NI.get_global_ns(vm);
  var_name  := NI.string_value(vm, PWideChar(Name), Length(Name));
  var_value := NI.get_prop(vm, zns, var_name);
  
  if NI.is_class(vm, var_value) then
    Result := True;
end;

{ Returns true if an object (class, variable, constant etc) exists in the global namespace,
  false otherwise }
function IsNameExists(const vm: HVM; const Name: WideString): boolean;
var
  var_name: tiscript_string;
  var_value: tiscript_object;
  zns: tiscript_value;
begin
  zns := NI.get_global_ns(vm);
  var_name  := NI.string_value(vm, PWideChar(Name), Length(Name));
  var_value := NI.get_prop(vm, zns, var_name);
  Result := not NI.is_undefined(var_value);
end;

function GetNativeObject(const vm: HVM; const Name: WideString): tiscript_value;
var
  var_name: tiscript_string;
  var_value: tiscript_object;
  zns: tiscript_value;
begin
  zns := NI.get_global_ns(vm);
  var_name  := NI.string_value(vm, PWideChar(Name), Length(Name));
  var_value := NI.get_prop(vm, zns, var_name);
  Result := var_value;
end;

{ Returns tiscript value of type "class" }
function GetNativeClass(const vm: HVM; const ClassName: WideString): tiscript_class;
var
  zns: tiscript_value;
  tclass_name: tiscript_string;
  class_def: tiscript_class;
begin
  zns := NI.get_global_ns(vm);
  tclass_name  := NI.string_value(vm, PWideChar(ClassName), Length(ClassName));
  class_def    := NI.get_prop(vm, zns, tclass_name);
  if NI.is_class(vm, class_def) then
    Result := class_def
  else
    Result := NI.undefined_value;
end;

{ Returns true if a function registration was successfull,
  false if a function with same name was already registered,
  throws an exception otherwise }
function RegisterNativeFunction(const vm: HVM; const Name: WideString; Handler: ptiscript_method; ThrowIfExists: Boolean = False): Boolean;
var
  method_def: ptiscript_method_def;
  smethod_name: AnsiString;
  func_def: tiscript_value;
  func_name: tiscript_value;
  zns: tiscript_value;
begin
  if IsNameExists(vm, Name) and ThrowIfExists then
    raise ESciterException.CreateFmt('Failed to register native function %s. Object with same name already exists.', [Name]);
    
  zns := NI.get_global_ns(vm);

  smethod_name := AnsiString(Name);
  func_name := NI.string_value(vm, PWideChar(Name), Length(Name));
  func_def := NI.get_prop(vm, zns, func_name);

  if NI.is_undefined(func_def) then
  begin
    New(method_def);
    method_def.dispatch := nil;
    method_def.name := StrNew(PAnsiChar(smethod_name));
    method_def.handler := Handler;
    method_def.tag := nil;
    func_def := NI.native_function_value(vm, method_def);
    if not NI.is_native_function(func_def) then
    begin
      raise Exception.CreateFmt('Failed to register native function "%s".', [Name]);
    end;
    NI.set_prop(vm, zns, func_name, func_def);
    Result := True;
  end
    else
  if NI.is_native_function(func_def) then
  begin
    Result := False;
  end
    else
  begin
    raise ESciterException.CreateFmt('Cannot register native function "%s" (unexprected error). Seems that object with same name already exists.', [Name]);
  end;
end;

function RegisterNativeClass(const vm: HVM; ClassDef: ptiscript_class_def; ThrowIfExists: Boolean; ReplaceClassDef: Boolean): tiscript_class;
var
  zns: tiscript_value;
  wclass_name: WideString;
  tclass_name: tiscript_string;
  class_def: tiscript_class;
begin
  zns := NI.get_global_ns(vm);

  wclass_name  := WideString(AnsiString(ClassDef.name));
  tclass_name  := NI.string_value(vm, PWideChar(wclass_name), Length(wclass_name));
  class_def    := NI.get_prop(vm, zns, tclass_name);

  if NI.is_undefined(class_def) then
  begin
    class_def := NI.define_class(vm, ClassDef, zns);
    if not NI.is_class(vm, class_def) then
      raise ESciterException.CreateFmt('Failed to register class definition.', []);
    Result := class_def;
  end
    else
  if NI.is_class(vm, class_def) then
  begin
    if ThrowIfExists then
    begin
      raise ESciterException.CreateFmt('Class "%s" already exists.', [String(ClassDef.name)]);
    end
      else
    begin
      Result := class_def;
    end;
  end
    else
  begin
    raise ESciterException.CreateFmt('Failed to register native class "%s". Object with same name (class, namespace, constant, variable or function) already exists.', [String(ClassDef.name)]);
  end;
end;

function SciterVarType(value: PSciterValue): TSciterValueType;
var
  pUnits: UINT;
begin
  API.ValueType(value, Result, pUnits);
end;

function SciterVarToString(value: PSciterValue): WideString;
var
  pCh: PWideChar;
  iNum: UINT;
begin
  API.ValueStringData(value, pCh, iNum);
  Result := WideString(pCh);
end;

function CreateObjectInstance(const vm: HVM; Obj: Pointer; OfClass: tiscript_class): tiscript_object;
begin
  if not NI.is_class(vm, OfClass) then
    raise ESciterException.CreateFmt('Cannot create object instance. Provided value is not a class.', []);
  Result := NI.create_object(vm, OfClass);
  NI.set_instance_data(Result, Obj);
end;

function CreateObjectInstance(const vm: HVM; Obj: Pointer; OfClass: WideString): tiscript_object;
var
  t_class: tiscript_class;
begin
  t_class := GetNativeClass(vm, OfClass);
  Result := CreateObjectInstance(vm, Obj, t_class);
end;

procedure RegisterObject(const vm: HVM; Obj: tiscript_object; const VarName: WideString);
var
  zns: tiscript_value;
  var_name: tiscript_value;
begin
  if not NI.is_native_object(Obj) then
    raise ESciterException.CreateFmt('Cannot register object instance. Provided value is not an object.', []);

  // If a variable VarName already exists it'll be rewritten
  var_name := NI.string_value(vm, PWideChar(VarName), Length(VarName));
  zns := NI.get_global_ns(vm);
  NI.set_prop(vm, zns, var_name, Obj);
end;

procedure RegisterObject(const vm: HVM; Obj: Pointer; const OfClass: WideString; const VarName: WideString); overload;
var
  o: tiscript_value;
begin
  o := CreateObjectInstance(vm, Obj, OfClass);
  RegisterObject(vm, o, VarName);
end;

function API: PSciterApi;
var
  pFuncPtr: SciterApiFunc;
begin
  if FAPI = nil then
  begin
    HSCITER := LoadLibrary('sciter32.dll');
    if HSCITER = 0 then
      raise ESciterException.Create('Failed to load Sciter DLL.');

    pFuncPtr := GetProcAddress(HSCITER, 'SciterAPI');
    if pFuncPtr = nil then
      raise ESciterException.Create('Failed to get pointer to SciterAPI function.');

    FAPI := pFuncPtr();
  end;
  Result := FAPI;
end;


function _SciterAPI: PSciterApi; external 'sciter32.dll' name 'SciterAPI'; stdcall;

{ SciterValue to Variant conversion }
function S2V(Value: PSciterValue; var OleValue: OleVariant): UINT;
var
  pType: TSciterValueType;
  pUnits: UINT;
  pWStr: PWideChar;
  iNum: UINT;
  sWStr: WideString;
  iResult: Integer;
  dResult: Double;
  i64Result: Int64;
  ft: TFileTime;
  pbResult: PByte;
  cResult: Currency;
  st: SYSTEMTIME;
  pDispValue: IDispatch;
  arrSize: UINT;
  sArrItem: TSciterValue;
  oArrItem: OleVariant;
  oleArrayResult: Variant;
  j: Integer;
begin
  API.ValueInit(@sArrItem);
  
  API.ValueType(Value, pType, pUnits);
  case pType of
    T_ARRAY:
      begin
        API.ValueElementsCount(Value, arrSize);
        OleValue := VarArrayCreate([0, arrSize], varVariant );
        for j := 0 to arrSize - 1 do
        begin
          oArrItem := Unassigned;
          API.ValueNthElementValue(Value, j, @sArrItem);
          S2V(@sArrItem, oArrItem );
          VarArrayPut(Variant(OleValue), oArrItem, [j]);
        end;
        Result := HV_OK;
      end;
    T_BOOL:
      begin
        Result := FAPI.ValueIntData(Value, iResult);
        if Result = HV_OK then
        begin
          OleValue := iResult <> 0;
        end
          else
        begin
          OleValue := False;
        end;
      end;
    T_BYTES:
      begin
        raise ESciterNotImplementedException.CreateFmt('Cannot convert T_BYTES to Variant (not implemented).', []);
      end;
    T_CURRENCY:
      begin
        // TODO: ?
        Result := FAPI.ValueInt64Data(Value, i64Result);
        cResult := PCurrency(@i64Result)^;
        OleValue := cResult;
      end;
    T_DATE:
      begin
        Result := FAPI.ValueInt64Data(Value, i64Result);
        ft := TFileTime(i64Result);
        FileTimeToSystemTime(ft, st);
        SystemTimeToVariantTime(st, dResult);
        OleValue := TDateTime(dResult);
      end;
    T_DOM_OBJECT:
      begin
        raise ESciterNotImplementedException.CreateFmt('Cannot convert T_DOM_OBJECT to Variant (not implemented).', []);
      end;
    T_FLOAT:
      begin
        Result := API.ValueFloatData(Value, dResult);
        OleValue := dResult;
      end;
    T_STRING:
      begin
        Result := API.ValueStringData(Value, pWStr, iNum);
        sWStr := WideString(pWStr);
        OleValue := sWStr;
      end;
    T_MAP:
      begin
        OleValue := GetNativeObjectJson(Value);
        Result := HV_OK;
      end;
    T_FUNCTION:
      begin
        raise ESciterNotImplementedException.CreateFmt('Cannot convert T_FUNCTION to Variant (not implemented).', []);
      end;
    T_INT:
      begin
        Result := FAPI.ValueIntData(Value, iResult);
        OleValue := iResult;
      end;
    T_LENGTH:
      begin
        raise ESciterNotImplementedException.CreateFmt('Cannot convert T_LENGTH to Variant (not implemented).', []);
      end;
    
    T_NULL:
      begin
        OleValue := Null;
        Result := HV_OK;
      end;
    T_OBJECT:
      // TODO: returns OleVariant if Object wraps IDispatch, JSON otherwise 
      begin
        pbResult := nil;
        Result := API.ValueBinaryData(Value, pbResult, iNum);
        if Result = HV_OK then
        begin
          if pbResult <> nil then
          begin
            pDispValue := IDispatch(Pointer(pbResult));
            try
              pDispValue._AddRef;
              pDispValue._Release;
              OleValue := OleVariant(pDispValue);
            except
              // not an IDispatch, probably native tiscript object
              OleValue := GetNativeObjectJson(Value);
              Result := HV_OK;
            end;
          end
            else
          begin
            OleValue := Unassigned;
          end;
        end
          else
        begin
          OleValue := GetNativeObjectJson(Value);
          Result := HV_OK;
        end;
      end;
    T_UNDEFINED:
      begin
        OleValue := Unassigned;
        Result := HV_OK;
      end;
    else
      begin
        raise ESciterNotImplementedException.CreateFmt('Conversion from Sciter type %d to Variant is not implemented.', [Integer(pType)]);
      end;
  end;
end;

{ Variant to SciterValue conversion }
function V2S(const Value: OleVariant; SciterValue: PSciterValue): UINT;
var
  sWStr: WideString;
  i64: Int64;
  d: Double;
  date: TDateTime;
  st: SYSTEMTIME;
  ft: FILETIME;
  pDisp: IDispatch;
  cCur: Currency;
  vt: Word;
  i: Integer;
  oArrItem: Variant;
  sArrItem: TSciterValue;
begin
  FAPI.ValueInit(SciterValue);
  vt := VarType(Value);

  if (vt and varArray) = varArray then
  begin
    for i := VarArrayLowBound(Value, 1) to VarArrayHighBound(Value, 1) do
    begin
      oArrItem := VarArrayGet(Value, [i]);
      V2S(oArrItem, @sArrItem);
      API.ValueNthElementValueSet(SciterValue, i, @sArrItem);
    end;
    Result := 0;
    Exit;
  end;

  case vt of
    varEmpty:
      begin
        API.ValueInit(SciterValue);
        Result := 0;
      end;
    varNull:
      begin
        API.ValueInit(SciterValue);
        Result := 0;
      end;
    varString:
      begin
        sWStr := Value;
        Result:= FAPI.ValueStringDataSet(SciterValue, PWideChar(sWStr), Length(sWStr), 0);
      end;
    varOleStr:
      begin
        sWStr := Value;
        Result:= FAPI.ValueStringDataSet(SciterValue, PWideChar(sWStr), Length(sWStr), 0);
      end;
    varBoolean:
      begin
        if Value then
          Result := API.ValueIntDataSet(SciterValue, 1, T_BOOL, 0)
        else
          Result := API.ValueIntDataSet(SciterValue, 0, T_BOOL, 0);
      end;
    varByte,
    varSmallInt,
    varInteger,
    varWord,
    varLongWord:
      begin
        Result := FAPI.ValueIntDataSet(SciterValue, Integer(Value), T_INT, 0);
      end;
    varInt64:
      begin
        i64 := Value;
        Result := FAPI.ValueInt64DataSet(SciterValue, i64, T_INT, 0);
      end;
    varSingle,
    varDouble:
      begin
        Result := FAPI.ValueFloatDataSet(SciterValue, Double(Value), T_FLOAT, 0);
      end;
    varCurrency:
      begin
        cCur := Value;
        i64 := PInt64(@cCur)^;
        Result := FAPI.ValueInt64DataSet(SciterValue, i64, T_CURRENCY, 0);
      end;
    varDate:
      begin
        date := TDateTime(Value);
        d := Double(date);
        VariantTimeToSystemTime(d, st);
        SystemTimeToFileTime(st, ft);
        i64 := Int64(ft);
        Result := FAPI.ValueInt64DataSet(SciterValue, i64, T_DATE, 0);
      end;
    varDispatch:
      begin
        pDisp := IDispatch(Value);
        //pDisp._AddRef;
        Result := FAPI.ValueBinaryDataSet(SciterValue, PByte(pDisp), 1, T_OBJECT, 0);
      end;
    else
      begin
        raise ESciterNotImplementedException.CreateFmt('Cannot convert VARIANT of type %d to Sciter value.', [vt]);
      end;
  end;
end;

{ tiscript value to Variant conversion }
function T2V(const vm: HVM; Value: tiscript_value): OleVariant;
var
  sValue: TSciterValue;
begin
  API.ValueInit(@sValue);
  API.Sciter_T2S(vm, Value, sValue, False);
  S2V(@sValue, Result);
end;

{ Variant to tiscript value conversion }
function V2T(const vm: HVM; const Value: OleVariant): tiscript_value;
var
  sValue: TSciterValue;
  tResult: tiscript_value;
begin
  API.ValueInit(@sValue);
  V2S(Value, @sValue);
  API.Sciter_S2T(vm, @sValue, tResult);
  Result := tResult;
end;

{ ESciterNullPointerException }

constructor ESciterNullPointerException.Create;
begin
  inherited Create('The argument cannot be null.');
end;

{ ESciterCallException }

constructor ESciterCallException.Create(const MethodName: String);
begin
  inherited CreateFmt('Method "%s" call failed.', [MethodName]);
end;

initialization
  HSCITER := 0;

finalization
  if HSCITER <> 0 then
    FreeLibrary(HSCITER);

end.
