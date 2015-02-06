unit SciterApi;

interface

uses Windows, Messages, Dialogs, Classes, Forms, Controls, SysUtils, ComObj, ActiveX,
  Variants, ExtCtrls, TiScriptApi;

type
  SCDOM_RESULT = type Integer;

const
  SIH_REPLACE_CONTENT     = 0;
  SIH_INSERT_AT_START     = 1;
  SIH_APPEND_AFTER_LAST   = 2;
  SOH_REPLACE             = 3;
  SOH_INSERT_BEFORE       = 4;
  SOH_INSERT_AFTER        = 5;

  T_UNDEFINED = 0;
  T_NULL = 1;
  T_BOOL = 2;
  T_INT = 3;
  T_FLOAT = 4;
  T_STRING = 5;
  T_DATE = 6;
  T_CURRENCY = 7;
  T_LENGTH = 8;
  T_ARRAY = 9;
  T_MAP = 10;
  T_FUNCTION = 11;
  T_BYTES = 12;
  T_OBJECT = 13;
  T_DOM_OBJECT = 14;

  SCDOM_OK: SCDOM_RESULT = 0;
  SCDOM_INVALID_HWND: SCDOM_RESULT = 1;
  SCDOM_INVALID_HANDLE: SCDOM_RESULT = 2;
  SCDOM_PASSIVE_HANDLE: SCDOM_RESULT = 3;
  SCDOM_INVALID_PARAMETER: SCDOM_RESULT = 4;
  SCDOM_OPERATION_FAILED: SCDOM_RESULT = 5;
  SCDOM_OK_NOT_HANDLED: SCDOM_RESULT = (-1);

  HV_OK_TRUE = -1;
  HV_OK = 0;
  HV_BAD_PARAMETER = 1;
  HV_INCOMPATIBLE_TYPE = 2;

type
  ESciterNotImplementedException = class(EOleException)

  end;
  
  HWINDOW = HWND;

  HELEMENT = Pointer;

  LPCSTR_RECEIVER = procedure( str: PAnsiChar; str_length: UINT; param : Pointer ); stdcall;
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

  SciterHostCallback = function(pns: LPSCITER_CALLBACK_NOTIFICATION; callbackParam: Pointer ): UINT; stdcall;
  LPSciterHostCallback = ^SciterHostCallback;
  
  SCN_LOAD_DATA = packed record
    code: UINT;
    hwnd: HWINDOW;
    uri: LPCWSTR;
    outData: PBYTE;
    outDataSize: UINT;
    dataType: UINT;
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
    dataType: UINT;
    status: UINT;
  end;
  LPSCN_DATA_LOADED = ^SCN_DATA_LOADED;

  TProcPointer = procedure; stdcall;
  TSciterClassName = function: PWideChar; stdcall;

  DEBUG_OUTPUT_PROC = procedure(param: Pointer; subsystem: UINT; severity: UINT; text: PWideChar; text_length: UINT); stdcall;
  PDEBUG_OUTPUT_PROC = ^DEBUG_OUTPUT_PROC;

  SciterElementCallback = function(he: HELEMENT; Param: Pointer ): BOOL; stdcall;
  PSciterElementCallback = ^SciterElementCallback;

  ElementEventProc = function(tag: Pointer; he: HELEMENT; evtg: UINT; prms: Pointer ): Integer { really BOOL }; stdcall;
  LPELEMENT_EVENT_PROC = ^ElementEventProc;

  TSciterValue = packed record
    t: UINT;
    u: UINT;
    d: UInt64;
  end;

  PSciterValue = ^TSciterValue;

  ISciterAPI = packed record
    Version: UINT;                                  // is zero for now
    SciterClassName: function: LPCWSTR; stdcall;
    SciterVersion: function(major: Integer): UINT; stdcall;
    SciterDataReady: TProcPointer;
    SciterDataReadyAsync: TProcPointer;
{$ifdef WINDOWS}
    SciterProc: function(hwnd: HWINDOW; msg: Cardinal; wParam: Integer; lParam: Integer): LRESULT; stdcall;
    SciterProcND: function(hwnd: HWINDOW; msg: Cardinal; wParam: Integer; lParam: Integer; var pbHANDLED: Integer): LRESULT; stdcall;
{$endif}
    SciterLoadFile: function(hWndSciter: HWND; filename:LPCWSTR): Integer; stdcall;
    SciterLoadHtml: function(hWndSciter: HWINDOW; html: PByte; htmlSize: UINT; baseUrl: PWideChar): SCDOM_RESULT; stdcall;
    SciterSetCallback: function(hWndSciter: HWINDOW; cb: LPSciterHostCallback; cbParam: Pointer): SCDOM_RESULT; stdcall;
    SciterSetMasterCSS: TProcPointer;
    SciterAppendMasterCSS: TProcPointer;
    SciterSetCSS: TProcPointer;
    SciterSetMediaType: TProcPointer;
    SciterSetMediaVars: TProcPointer;
    SciterGetMinWidth: function(hwnd: HWINDOW): UINT; stdcall;
    SciterGetMinHeight: function(hwnd: HWINDOW; width: UINT): UINT; stdcall;
    SciterCall: function(hWnd: HWINDOW; functionName: PAnsiChar; argc: UINT; argv: PSciterValue; var retval: TSciterValue): BOOL; stdcall;
    SciterEval: function(hwnd: HWINDOW; script: PWideChar; scriptLength: UINT; var pretval: TSciterValue): BOOL; stdcall;
    SciterUpdateWindow: procedure(hwnd: HWINDOW); stdcall;
{$ifdef WINDOWS}
    SciterTranslateMessage: TProcPointer;
{$endif}
    SciterSetOption: TProcPointer;
    SciterGetPPI: TProcPointer;
    SciterGetViewExpando: TProcPointer;
    SciterEnumUrlData: TProcPointer;
{$ifdef WINDOWS}
    SciterRenderD2D: TProcPointer;
    SciterD2DFactory: TProcPointer;
    SciterDWFactory: TProcPointer;
{$endif}
    SciterGraphicsCaps: TProcPointer;
    SciterSetHomeURL: TProcPointer;
    SciterCreateWindow: TProcPointer;
    SciterSetupDebugOutput: function(hwndOrNull: HWINDOW; param: Pointer; pfOutput: PDEBUG_OUTPUT_PROC): SCDOM_RESULT; stdcall;
    SciterDebugSetupClient: TProcPointer;
    SciterDebugAddBreakpoint: TProcPointer;
    SciterDebugRemoveBreakpoint: TProcPointer;
    SciterDebugEnumBreakpoints: TProcPointer;

//|
//| DOM Element API
//|

    Sciter_UseElement: TProcPointer;
    Sciter_UnuseElement: TProcPointer;
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
    SciterGetNthAttributeNameCB: TProcPointer;
    SciterGetNthAttributeValueCB: TProcPointer;
    SciterGetAttributeByNameCB: function(he: HELEMENT; name: PAnsiChar; rcv: PLPCWSTR_RECEIVER; rcv_param: Pointer): SCDOM_RESULT; stdcall;
    SciterSetAttributeByName: function(he: HELEMENT; name: PAnsiChar; value: PWideChar): SCDOM_RESULT; stdcall;
    SciterClearAttributes: TProcPointer;
    SciterGetElementIndex: function(he: HELEMENT; var p_index: UINT): SCDOM_RESULT; stdcall;
    SciterGetElementType: function(he: HELEMENT; var s: LPCSTR): SCDOM_RESULT; stdcall;
    SciterGetElementTypeCB: function(he: HELEMENT; rcv: PLPCSTR_RECEIVER; rcv_param: Pointer): SCDOM_RESULT; stdcall;
    SciterGetStyleAttributeCB: function(he: HELEMENT; name: PAnsiChar; rcv: PLPCWSTR_RECEIVER; rcv_param: Pointer): SCDOM_RESULT; stdcall;
    SciterSetStyleAttribute: function(he: HELEMENT; name: PAnsiChar; value: PWideChar): SCDOM_RESULT; stdcall;
    SciterGetElementLocation: TProcPointer;
    SciterScrollToView: function(he: HELEMENT; SciterScrollFlags: UINT): SCDOM_RESULT; stdcall;
    SciterUpdateElement: TProcPointer;
    SciterRefreshElementArea: TProcPointer;
    SciterSetCapture: TProcPointer;
    SciterReleaseCapture: TProcPointer;
    SciterGetElementHwnd: TProcPointer;  
    SciterCombineURL: TProcPointer;
    SciterSelectElements: function(he: HELEMENT; CSS_selectors: PAnsiChar; Callback: PSciterElementCallback; Param: Pointer): SCDOM_RESULT; stdcall;
    SciterSelectElementsW: function(he: HELEMENT; CSS_selectors: PWideChar; Callback: PSciterElementCallback; Param: Pointer): SCDOM_RESULT; stdcall;
    SciterSelectParent: TProcPointer;
    SciterSelectParentW: TProcPointer;
    SciterSetElementHtml: function(he: HELEMENT; html: PByte; htmlLength: UINT; where: UINT): SCDOM_RESULT; stdcall;
    SciterGetElementUID: TProcPointer;
    SciterGetElementByUID: TProcPointer;
    SciterShowPopup: TProcPointer;
    SciterShowPopupAt: TProcPointer;
    SciterHidePopup: TProcPointer;
    SciterGetElementState: TProcPointer;
    SciterSetElementState: TProcPointer;
    SciterCreateElement: function(tagname: PAnsiChar; textOrNull: PWideChar; var phe: HELEMENT): SCDOM_RESULT; safecall;
    SciterCloneElement: TProcPointer;
    SciterInsertElement: function(he: HELEMENT; hparent: HELEMENT; index: UINT): SCDOM_RESULT; stdcall;
    SciterDetachElement: TProcPointer;
    SciterDeleteElement: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterSetTimer: TProcPointer;
    SciterDetachEventHandler: function(he: HELEMENT; pep: LPELEMENT_EVENT_PROC; tag: Pointer): SCDOM_RESULT; stdcall;
    SciterAttachEventHandler: function(he: HELEMENT; pep: LPELEMENT_EVENT_PROC; tag: Pointer): SCDOM_RESULT; stdcall;
    SciterWindowAttachEventHandler: TProcPointer;
    SciterWindowDetachEventHandler: TProcPointer;
    SciterSendEvent: function(he: HELEMENT; appEventCode: UINT; heSource: HELEMENT; reason: PUINT; var handled: BOOL): SCDOM_RESULT; stdcall;
    SciterPostEvent: function(he: HELEMENT; appEventCode: UINT; heSource: HELEMENT; reason: PUINT): SCDOM_RESULT; stdcall;
    SciterCallBehaviorMethod: TProcPointer;
    SciterRequestElementData: TProcPointer;
    SciterHttpRequest: TProcPointer;
    SciterGetScrollInfo: TProcPointer;
    SciterSetScrollPos: TProcPointer;
    SciterGetElementIntrinsicWidths: TProcPointer;
    SciterGetElementIntrinsicHeight: TProcPointer;
    SciterIsElementVisible: TProcPointer;
    SciterIsElementEnabled: TProcPointer;
    SciterSortElements: TProcPointer;
    SciterSwapElements: TProcPointer;
    SciterTraverseUIEvent: TProcPointer;
    SciterCallScriptingMethod: TProcPointer;
    SciterCallScriptingFunction: TProcPointer;
    SciterEvalElementScript: TProcPointer;
    SciterAttachHwndToElement: TProcPointer;
    SciterControlGetType: TProcPointer;
    SciterGetValue: function(he: HELEMENT; Value: PSciterValue): SCDOM_RESULT; stdcall;  
    SciterSetValue: function(he: HELEMENT; Value: PSciterValue): SCDOM_RESULT; stdcall;
    SciterGetExpando: TProcPointer;
    SciterGetObject: TProcPointer;
    SciterGetElementNamespace: TProcPointer;
    SciterGetHighlightedElement: TProcPointer;
    SciterSetHighlightedElement: TProcPointer;

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
    ValueCopy: function(Value1: PSciterValue; Value2: PSciterValue): UINT; stdcall;
    ValueIsolate: TProcPointer;
    ValueType: function(Value: PSciterValue; var pType: UINT; var pUnits: UINT): UINT; stdcall;
    ValueStringData: function(Value: PSciterValue; var Chars: PWideChar; var NumChars: UINT): UINT; stdcall;
    ValueStringDataSet: function(Value: PSciterValue; Chars: PWideChar; NumChars: UINT; Units: UINT): UINT; stdcall;
    ValueIntData: function(Value: PSciterValue; var pData: Integer): UINT; stdcall;
    ValueIntDataSet:function(Value: PSciterValue; data: Integer; iType: UINT; units: UINT): UINT; stdcall;
    ValueInt64Data: function(Value: PSciterValue; var pData: Int64): UINT; stdcall;
    ValueInt64DataSet: function(Value: PSciterValue; data: Int64; iType: UINT; units: UINT): UINT; stdcall;
    ValueFloatData: function(Value: PSciterValue; var pData: double): UINT; stdcall;
    ValueFloatDataSet: function(Value: PSciterValue; data: double; iType: UINT; units: UINT): UINT; stdcall;
    ValueBinaryData: function(Value: PSciterValue; var bytes: PByte; var pnBytes: UINT): UINT; stdcall; 
    ValueBinaryDataSet: function(Value: PSciterValue; bytes: PByte; nBytes: UINT; pType: UINT; units: UINT): UINT; stdcall;
    ValueElementsCount: function(Value: PSciterValue; var pData: UINT): UINT; stdcall;
    ValueNthElementValue : function(Value: PSciterValue; n: Integer; pretval: PSciterValue): UINT; stdcall;
    ValueNthElementValueSet: function(pval: PSciterValue; n: Integer; pval_to_set: PSciterValue): UINT; stdcall;
    ValueNthElementKey: TProcPointer;
    ValueEnumElements: TProcPointer;
    ValueSetValueToKey: TProcPointer;
    ValueGetValueOfKey: TProcPointer;
    ValueToString: function(Value: PSciterValue; How: UINT): UINT; stdcall;
    ValueFromString: function(Value: PSciterValue; str: PWideChar; strLength: UINT; how: UINT): UINT; stdcall;
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

    SciterFireEvent: TProcPointer;

    SciterGetCallbackParam: TProcPointer;
    SciterPostCallback: TProcPointer;
  end;

  PSciterApi = ^ISciterAPI;

  MOUSE_PARAMS = packed record
    cmd: UINT;
    target: HELEMENT;
    pos: TPoint;
    pos_view: TPoint;
    button_state: UINT;
    alt_state: UINT;
    cursor_type: UINT;
    is_on_icon: BOOL;
    dragging: HELEMENT;
    dragging_mode: UINT;
  end;
  PMOUSE_PARAMS = ^MOUSE_PARAMS;

  KEY_PARAMS = packed record
    cmd: UINT;
    target: HELEMENT;
    key_code: UINT;
    alt_state: UINT;
  end;
  PKEY_PARAMS = ^KEY_PARAMS;

  FOCUS_PARAMS = packed record
    cmd: UINT;
    target: HELEMENT;
    by_mouse_click: BOOL;
    cancel: BOOL;
  end;
  PFOCUS_PARAMS = ^FOCUS_PARAMS;

  TIMER_PARAMS = packed record
    timerId: Pointer;
  end;
  PTIMER_PARAMS = ^TIMER_PARAMS;

  BEHAVIOR_EVENT_PARAMS = packed record
    cmd: UINT;
    heTarget: HELEMENT;
    he: HELEMENT;
    reason: Pointer;
    data: TSciterValue;
  end;
  PBEHAVIOR_EVENT_PARAMS = ^BEHAVIOR_EVENT_PARAMS;

function _SciterAPI: PSciterApi; stdcall;
function S2V(Value: PSciterValue): OleVariant;
function V2S(const Value: OleVariant; SciterValue: PSciterValue): SCDOM_RESULT;
function V2T(vm: HVM; Value: tiscript_value): OleVariant;
function T2V(vm: HVM; const Value: OleVariant): tiscript_value;
function API: PSciterApi;
function NI: ptiscript_native_interface;

implementation

var
  FAPI: PSciterApi;
  FNI: ptiscript_native_interface;

function API: PSciterApi;
begin
  Result := FAPI;
end;

function NI: ptiscript_native_interface;
begin
  Result := FNI;
end;

function _SciterAPI: PSciterApi; external 'sciter32.dll' name 'SciterAPI'; stdcall;

function S2V(Value: PSciterValue): OleVariant;
var
  oResult: OleVariant;
  pType: UINT;
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
  oArrItem: Variant;
  oleArrayResult: Variant;
  j: Integer;
begin
  FAPI.ValueType(Value, pType, pUnits);
  case pType of
    T_ARRAY:
      begin
        API.ValueElementsCount(Value, arrSize);
        oleArrayResult := VarArrayCreate([0, arrSize], varVariant );
        for j := 0 to arrSize - 1 do
        begin
          API.ValueNthElementValue(Value, j, @sArrItem);
          oArrItem := S2V(@sArrItem);
          VarArrayPut(oleArrayResult, oArrItem, [j]);
        end;
        Result := oleArrayResult;
      end;
    T_BOOL:
      begin
        if FAPI.ValueIntData(Value, iResult) = HV_OK then
          Result := iResult <> 0
        else
          Result := False;
      end;
    T_BYTES:
      begin
        raise ESciterNotImplementedException.CreateFmt('Cannot convert T_BYTES to Variant (E_NOT_IMPLEMENTED).', []);
      end;
    T_CURRENCY:
      begin
        FAPI.ValueInt64Data(Value, i64Result);
        cResult := CompToCurrency(i64Result);
        //cResult := PCurrency(i64Result)^;
        // PInt64(aCurrencyVar)^
        oResult := cResult;
      end;
    T_DATE:
      begin
        FAPI.ValueInt64Data(Value, i64Result);
        ft := TFileTime(i64Result);
        FileTimeToSystemTime(ft, st);
        SystemTimeToVariantTime(st, dResult);
        oResult := TDateTime(dResult);
      end;
    T_DOM_OBJECT:
      begin
        raise ESciterNotImplementedException.CreateFmt('Cannot convert T_DOM_OBJECT to Variant (E_NOT_IMPLEMENTED).', []);
      end;
    T_FLOAT:
      begin
        FAPI.ValueFloatData(Value, dResult);
        oResult := dResult;
      end;
    T_STRING:
      begin
        FAPI.ValueStringData(Value, pWStr, iNum);
        sWStr := WideString(pWStr);
        oResult := sWStr;
      end;
    T_FUNCTION:
      begin
        raise ESciterNotImplementedException.CreateFmt('Cannot convert T_FUNCTION to Variant (E_NOT_IMPLEMENTED).', []);
      end;
    T_INT:
      begin
        FAPI.ValueIntData(Value, iResult);
        oResult := iResult;
      end;
    T_LENGTH:
      begin
        raise ESciterNotImplementedException.CreateFmt('Cannot convert T_LENGTH to Variant (E_NOT_IMPLEMENTED).', []);
      end;
    T_MAP:
      begin
        raise ESciterNotImplementedException.CreateFmt('Cannot convert T_MAP to Variant (E_NOT_IMPLEMENTED).', []);
      end;
    T_NULL:
      begin
        oResult := Null;
      end;
    T_OBJECT:
      begin
        pbResult := nil;
        if API.ValueBinaryData(Value, pbResult, iNum) = HV_OK then
        begin
          if pbResult <> nil then
          begin
            pDispValue := IDispatch(Pointer(pbResult));
            pDispValue._AddRef;
            oResult := OleVariant(pDispValue);
          end
            else
          begin
            oResult := Unassigned;
          end;
        end
          else
        begin
          oResult := Unassigned;
        end;
      end;
    T_UNDEFINED:
      begin
        oResult := Unassigned;
      end;
    else
      begin
        raise ESciterNotImplementedException.CreateFmt('Not implemented (%d)', [pType]);
      end;
  end;
  Result := oResult;
end;

function V2S(const Value: OleVariant; SciterValue: PSciterValue): SCDOM_RESULT;
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
  FAPI.ValueClear(SciterValue);
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
    Result := SCDOM_OK;
    Exit;
  end;

  case vt of
    varEmpty:
      begin
        API.ValueInit(SciterValue);
        Result := SCDOM_OK;
      end;
    varNull:
      begin
        API.ValueInit(SciterValue);
        Result := SCDOM_OK;
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
        Result := FAPI.ValueInt64DataSet(SciterValue, i64, 0, 0);
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
        pDisp._AddRef; // TODO: ?
        Result := FAPI.ValueBinaryDataSet(SciterValue, PByte(pDisp), 1, T_OBJECT, 0);
      end;
    else
      begin
        raise ESciterNotImplementedException.CreateFmt('Cannot convert VARIANT of type %d to Sciter value.', [vt]);
      end;
  end;
end;

function V2T(vm: HVM; Value: tiscript_value): OleVariant;
var
  sValue: TSciterValue;
begin
  API.Sciter_T2S(vm, Value, sValue, False);
  Result := S2V(@sValue);
end;

function T2V(vm: HVM; const Value: OleVariant): tiscript_value;
var
  sValue: TSciterValue;
  tResult: tiscript_value;
begin
  V2S(Value, @sValue);
  API.Sciter_S2T(vm, @sValue, tResult);
  Result := tResult;
end;

{ TSciter }

initialization
  FAPI := _SciterAPI;
  FNI  := FAPI.TIScriptAPI;

end.
