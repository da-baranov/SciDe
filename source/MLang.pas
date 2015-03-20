unit MLang;

{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers.
{$IFDEF SUPPORTS_PLATFORM_WARNINGS}
{$WARN SYMBOL_PLATFORM OFF}
{$ENDIF}

interface

uses
  Windows, ActiveX, Classes, Variants;

const
  // TypeLibrary Major and minor versions
  MultiLanguageMajorVersion = 0;
  MultiLanguageMinorVersion = 2;

  LIBID_MultiLanguage: TGUID = '{275C23E0-3747-11D0-9FEA-00AA003F8646}';        // Do Not Localize

  IID_IMLangStringBufW: TGUID = '{D24ACD21-BA72-11D0-B188-00AA0038C969}';       // Do Not Localize
  IID_IMLangStringBufA: TGUID = '{D24ACD23-BA72-11D0-B188-00AA0038C969}';       // Do Not Localize
  IID_IMLangString: TGUID = '{C04D65CE-B70D-11D0-B188-00AA0038C969}';           // Do Not Localize
  IID_IMLangStringWStr: TGUID = '{C04D65D0-B70D-11D0-B188-00AA0038C969}';       // Do Not Localize
  IID_IMLangStringAStr: TGUID = '{C04D65D2-B70D-11D0-B188-00AA0038C969}';       // Do Not Localize
  CLSID_CMLangString: TGUID = '{C04D65CF-B70D-11D0-B188-00AA0038C969}';         // Do Not Localize
  IID_IMLangLineBreakConsole: TGUID = '{F5BE2EE1-BFD7-11D0-B188-00AA0038C969}'; // Do Not Localize
  IID_IEnumCodePage: TGUID = '{275C23E3-3747-11D0-9FEA-00AA003F8646}';          // Do Not Localize
  IID_IEnumRfc1766: TGUID = '{3DC39D1D-C030-11D0-B81B-00C04FC9B31F}';           // Do Not Localize
  IID_IEnumScript: TGUID = '{AE5F1430-388B-11D2-8380-00C04F8F5DA1}';            // Do Not Localize
  IID_IMLangConvertCharset: TGUID = '{D66D6F98-CDAA-11D0-B822-00C04FC9B31F}';   // Do Not Localize
  CLSID_CMLangConvertCharset: TGUID = '{D66D6F99-CDAA-11D0-B822-00C04FC9B31F}'; // Do Not Localize
  IID_IMultiLanguage: TGUID = '{275C23E1-3747-11D0-9FEA-00AA003F8646}';         // Do Not Localize
  IID_IMultiLanguage2: TGUID = '{DCCFC164-2B38-11D2-B7EC-00C04F8F5D9A}';        // Do Not Localize
  IID_ISequentialStream: TGUID = '{0C733A30-2A1C-11CE-ADE5-00AA0044773D}';      // Do Not Localize
  IID_IStream: TGUID = '{0000000C-0000-0000-C000-000000000046}';                // Do Not Localize
  IID_IMLangCodePages: TGUID = '{359F3443-BD4A-11D0-B188-00AA0038C969}';        // Do Not Localize
  IID_IMLangFontLink: TGUID = '{359F3441-BD4A-11D0-B188-00AA0038C969}';         // Do Not Localize
  IID_IMLangFontLink2: TGUID = '{DCCFC162-2B38-11D2-B7EC-00C04F8F5D9A}';        // Do Not Localize
  IID_IMultiLanguage3: TGUID = '{4E5868AB-B157-4623-9ACC-6A1D9CAEBE04}';        // Do Not Localize
  CLSID_CMultiLanguage: TGUID = '{275C23E2-3747-11D0-9FEA-00AA003F8646}';       // Do Not Localize

// *********************************************************************//
// Declaration of Enumerations defined in Type Library
// *********************************************************************//
// Constants for enum tagMLSTR_FLAGS
type
  tagMLSTR_FLAGS = TOleEnum;
const
  MLSTR_READ = $00000001;
  MLSTR_WRITE = $00000002;

// Constants for enum tagMIMECONTF
type
  tagMIMECONTF = TOleEnum;
const
  MIMECONTF_MAILNEWS = $00000001;
  MIMECONTF_BROWSER = $00000002;
  MIMECONTF_MINIMAL = $00000004;
  MIMECONTF_IMPORT = $00000008;
  MIMECONTF_SAVABLE_MAILNEWS = $00000100;
  MIMECONTF_SAVABLE_BROWSER = $00000200;
  MIMECONTF_EXPORT = $00000400;
  MIMECONTF_PRIVCONVERTER = $00010000;
  MIMECONTF_VALID = $00020000;
  MIMECONTF_VALID_NLS = $00040000;
  MIMECONTF_MIME_IE4 = $10000000;
  MIMECONTF_MIME_LATEST = $20000000;
  MIMECONTF_MIME_REGISTRY = $40000000;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary
// *********************************************************************//
  IMLangStringBufW = interface;
  IMLangStringBufA = interface;
  IMLangString = interface;
  IMLangStringWStr = interface;
  IMLangStringAStr = interface;
  IMLangLineBreakConsole = interface;
  IEnumCodePage = interface;
  IEnumRfc1766 = interface;
  IEnumScript = interface;
  IMLangConvertCharset = interface;
  IMultiLanguage = interface;
  IMultiLanguage2 = interface;
  ISequentialStream = interface;
  IStream = interface;
  IMLangCodePages = interface;
  IMLangFontLink = interface;
  IMLangFontLink2 = interface;
  IMultiLanguage3 = interface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  CMLangString = IMLangString;
  CMLangConvertCharset = IMLangConvertCharset;
  CMultiLanguage = IMultiLanguage;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
//  PUserType1 = PGUID;

  tagMIMECPINFO = packed record
    dwFlags: Cardinal;
    uiCodePage: SYSUINT;
    uiFamilyCodePage: SYSUINT;
    wszDescription: array[0..63] of WideChar;
    wszWebCharset: array[0..49] of WideChar;
    wszHeaderCharset: array[0..49] of WideChar;
    wszBodyCharset: array[0..49] of WideChar;
    wszFixedWidthFont: array[0..31] of WideChar;
    wszProportionalFont: array[0..31] of WideChar;
    bGDICharset: Byte;
  end;

  tagRFC1766INFO = packed record
    lcid: Cardinal;
    wszRfc1766: array[0..5] of WideChar;
    wszLocaleName: array[0..31] of WideChar;
  end;

  tagSCRIPTINFO = packed record
    ScriptId: Byte;
    uiCodePage: SYSUINT;
    wszDescription: array[0..47] of WideChar;
    wszFixedWidthFont: array[0..31] of WideChar;
    wszProportionalFont: array[0..31] of WideChar;
  end;

  tagMIMECSETINFO = packed record
    uiCodePage: SYSUINT;
    uiInternetEncoding: SYSUINT;
    wszCharset: array[0..49] of WideChar;
  end;

  _LARGE_INTEGER = packed record
    QuadPart: Int64;
  end;

  _ULARGE_INTEGER = packed record
    QuadPart: Largeuint;
  end;

  _FILETIME = packed record
    dwLowDateTime: Cardinal;
    dwHighDateTime: Cardinal;
  end;

  tagSTATSTG = packed record
    pwcsName: PWideChar;
    type_: Cardinal;
    cbSize: _ULARGE_INTEGER;
    mtime: _FILETIME;
    ctime: _FILETIME;
    atime: _FILETIME;
    grfMode: Cardinal;
    grfLocksSupported: Cardinal;
    clsid: TGUID;
    grfStateBits: Cardinal;
    reserved: Cardinal;
  end;

  tagDetectEncodingInfo = packed record
    nLangID: SYSUINT;
    nCodePage: SYSUINT;
    nDocPercent: SYSINT;
    nConfidence: SYSINT;
  end;

  tagUNICODERANGE = packed record
    wcFrom: Word;
    wcTo: Word;
  end;

  tagSCRIPFONTINFO = packed record
    scripts: Int64;
    wszFont: array[0..31] of WideChar;
  end;


// *********************************************************************//
// Interface: IMLangStringBufW
// Flags:     (0)
// GUID:      {D24ACD21-BA72-11D0-B188-00AA0038C969}
// *********************************************************************//
  IMLangStringBufW = interface(IUnknown)
    ['{D24ACD21-BA72-11D0-B188-00AA0038C969}'] // Do Not Localize
    function GetStatus(out plFlags: Integer; out pcchBuf: Integer): HResult; stdcall;
    function LockBuf(cchOffset: Integer; cchMaxLock: Integer; out ppszBuf: PWideChar;
                     out pcchBuf: Integer): HResult; stdcall;
    function UnlockBuf(pszBuf: PWideChar; cchOffset: Integer; cchWrite: Integer): HResult; stdcall;
    function Insert(cchOffset: Integer; cchMaxInsert: Integer; out pcchActual: Integer): HResult; stdcall;
    function Delete(cchOffset: Integer; cchDelete: Integer): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IMLangStringBufA
// Flags:     (0)
// GUID:      {D24ACD23-BA72-11D0-B188-00AA0038C969}
// *********************************************************************//
  IMLangStringBufA = interface(IUnknown)
    ['{D24ACD23-BA72-11D0-B188-00AA0038C969}'] // Do Not Localize
    function GetStatus(out plFlags: Integer; out pcchBuf: Integer): HResult; stdcall;
    function LockBuf(cchOffset: Integer; cchMaxLock: Integer; out ppszBuf: PAnsiChar; 
                     out pcchBuf: Integer): HResult; stdcall;
    function UnlockBuf(pszBuf: PAnsiChar; cchOffset: Integer; cchWrite: Integer): HResult; stdcall;
    function Insert(cchOffset: Integer; cchMaxInsert: Integer; out pcchActual: Integer): HResult; stdcall;
    function Delete(cchOffset: Integer; cchDelete: Integer): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IMLangString
// Flags:     (0)
// GUID:      {C04D65CE-B70D-11D0-B188-00AA0038C969}
// *********************************************************************//
  IMLangString = interface(IUnknown)
    ['{C04D65CE-B70D-11D0-B188-00AA0038C969}'] // Do Not Localize
    function Sync(fNoAccess: Integer): HResult; stdcall;
    function GetLength(out plLen: Integer): HResult; stdcall;
    function SetMLStr(lDestPos: Integer; lDestLen: Integer; const pSrcMLStr: IUnknown; 
                      lSrcPos: Integer; lSrcLen: Integer): HResult; stdcall;
    function GetMLStr(lSrcPos: Integer; lSrcLen: Integer; const pUnkOuter: IUnknown; 
                      dwClsContext: Cardinal; var piid: TGUID; out ppDestMLStr: IUnknown; 
                      out plDestPos: Integer; out plDestLen: Integer): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IMLangStringWStr
// Flags:     (0)
// GUID:      {C04D65D0-B70D-11D0-B188-00AA0038C969}
// *********************************************************************//
  IMLangStringWStr = interface(IMLangString)
    ['{C04D65D0-B70D-11D0-B188-00AA0038C969}'] // Do Not Localize
    function SetWStr(lDestPos: Integer; lDestLen: Integer; pszSrc: PWideChar; cchSrc: Integer;
                     out pcchActual: Integer; out plActualLen: Integer): HResult; stdcall;
    function SetStrBufW(lDestPos: Integer; lDestLen: Integer; const pSrcBuf: IMLangStringBufW; 
                        out pcchActual: Integer; out plActualLen: Integer): HResult; stdcall;
    function GetWStr(lSrcPos: Integer; lSrcLen: Integer; out pszDest: PWideChar; cchDest: Integer; 
                     out pcchActual: Integer; out plActualLen: Integer): HResult; stdcall;
    function GetStrBufW(lSrcPos: Integer; lSrcMaxLen: Integer; out ppDestBuf: IMLangStringBufW; 
                        out plDestLen: Integer): HResult; stdcall;
    function LockWStr(lSrcPos: Integer; lSrcLen: Integer; lFlags: Integer; cchRequest: Integer; 
                      out ppszDest: PWideChar; out pcchDest: Integer; out plDestLen: Integer): HResult; stdcall;
    function UnlockWStr(pszSrc: PWideChar; cchSrc: Integer; out pcchActual: Integer;
                        out plActualLen: Integer): HResult; stdcall;
    function SetLocale(lDestPos: Integer; lDestLen: Integer; locale: Cardinal): HResult; stdcall;
    function GetLocale(lSrcPos: Integer; lSrcMaxLen: Integer; out plocale: Cardinal; 
                       out plLocalePos: Integer; out plLocaleLen: Integer): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IMLangStringAStr
// Flags:     (0)
// GUID:      {C04D65D2-B70D-11D0-B188-00AA0038C969}
// *********************************************************************//
  IMLangStringAStr = interface(IMLangString)
    ['{C04D65D2-B70D-11D0-B188-00AA0038C969}'] // Do Not Localize
    function SetAStr(lDestPos: Integer; lDestLen: Integer; uCodePage: SYSUINT; 
                     pszSrc: PAnsiChar; cchSrc: Integer; out pcchActual: Integer;
                     out plActualLen: Integer): HResult; stdcall;
    function SetStrBufA(lDestPos: Integer; lDestLen: Integer; uCodePage: SYSUINT; 
                        const pSrcBuf: IMLangStringBufA; out pcchActual: Integer; 
                        out plActualLen: Integer): HResult; stdcall;
    function GetAStr(lSrcPos: Integer; lSrcLen: Integer; uCodePageIn: SYSUINT;
                     out puCodePageOut: SYSUINT; out pszDest: PAnsiChar; cchDest: Integer;
                     out pcchActual: Integer; out plActualLen: Integer): HResult; stdcall;
    function GetStrBufA(lSrcPos: Integer; lSrcMaxLen: Integer; out puDestCodePage: SYSUINT; 
                        out ppDestBuf: IMLangStringBufA; out plDestLen: Integer): HResult; stdcall;
    function LockAStr(lSrcPos: Integer; lSrcLen: Integer; lFlags: Integer; uCodePageIn: SYSUINT; 
                      cchRequest: Integer; out puCodePageOut: SYSUINT; out ppszDest: PAnsiChar;
                      out pcchDest: Integer; out plDestLen: Integer): HResult; stdcall;
    function UnlockAStr(pszSrc: PAnsiChar; cchSrc: Integer; out pcchActual: Integer;
                        out plActualLen: Integer): HResult; stdcall;
    function SetLocale(lDestPos: Integer; lDestLen: Integer; locale: Cardinal): HResult; stdcall;
    function GetLocale(lSrcPos: Integer; lSrcMaxLen: Integer; out plocale: Cardinal; 
                       out plLocalePos: Integer; out plLocaleLen: Integer): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IMLangLineBreakConsole
// Flags:     (0)
// GUID:      {F5BE2EE1-BFD7-11D0-B188-00AA0038C969}
// *********************************************************************//
  IMLangLineBreakConsole = interface(IUnknown)
    ['{F5BE2EE1-BFD7-11D0-B188-00AA0038C969}'] // Do Not Localize
    function BreakLineML(const pSrcMLStr: IMLangString; lSrcPos: Integer; lSrcLen: Integer; 
                         cMinColumns: Integer; cMaxColumns: Integer; out plLineLen: Integer; 
                         out plSkipLen: Integer): HResult; stdcall;
    function BreakLineW(locale: Cardinal; var pszSrc: Word; cchSrc: Integer; cMaxColumns: Integer; 
                        out pcchLine: Integer; out pcchSkip: Integer): HResult; stdcall;
    function BreakLineA(locale: Cardinal; uCodePage: SYSUINT; pszSrc: PAnsiChar; 
                        cchSrc: Integer; cMaxColumns: Integer; out pcchLine: Integer; 
                        out pcchSkip: Integer): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IEnumCodePage
// Flags:     (0)
// GUID:      {275C23E3-3747-11D0-9FEA-00AA003F8646}
// *********************************************************************//
  IEnumCodePage = interface(IUnknown)
    ['{275C23E3-3747-11D0-9FEA-00AA003F8646}'] // Do Not Localize
    function Clone(out ppEnum: IEnumCodePage): HResult; stdcall;
    function Next(celt: Cardinal; out rgelt: tagMIMECPINFO; out pceltFetched: Cardinal): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Skip(celt: Cardinal): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IEnumRfc1766
// Flags:     (0)
// GUID:      {3DC39D1D-C030-11D0-B81B-00C04FC9B31F}
// *********************************************************************//
  IEnumRfc1766 = interface(IUnknown)
    ['{3DC39D1D-C030-11D0-B81B-00C04FC9B31F}'] // Do Not Localize
    function Clone(out ppEnum: IEnumRfc1766): HResult; stdcall;
    function Next(celt: Cardinal; out rgelt: tagRFC1766INFO; out pceltFetched: Cardinal): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Skip(celt: Cardinal): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IEnumScript
// Flags:     (0)
// GUID:      {AE5F1430-388B-11D2-8380-00C04F8F5DA1}
// *********************************************************************//
  IEnumScript = interface(IUnknown)
    ['{AE5F1430-388B-11D2-8380-00C04F8F5DA1}'] // Do Not Localize
    function Clone(out ppEnum: IEnumScript): HResult; stdcall;
    function Next(celt: Cardinal; out rgelt: tagSCRIPTINFO; out pceltFetched: Cardinal): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Skip(celt: Cardinal): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IMLangConvertCharset
// Flags:     (0)
// GUID:      {D66D6F98-CDAA-11D0-B822-00C04FC9B31F}
// *********************************************************************//
  IMLangConvertCharset = interface(IUnknown)
    ['{D66D6F98-CDAA-11D0-B822-00C04FC9B31F}'] // Do Not Localize
    function Initialize(uiSrcCodePage: SYSUINT; uiDstCodePage: SYSUINT; dwProperty: Cardinal): HResult; stdcall;
    function GetSourceCodePage(out puiSrcCodePage: SYSUINT): HResult; stdcall;
    function GetDestinationCodePage(out puiDstCodePage: SYSUINT): HResult; stdcall;
    function GetProperty(out pdwProperty: Cardinal): HResult; stdcall;
    function DoConversion(var pSrcStr: Byte; var pcSrcSize: SYSUINT; var pDstStr: Byte; 
                          var pcDstSize: SYSUINT): HResult; stdcall;
    function DoConversionToUnicode(pSrcStr: PAnsiChar; var pcSrcSize: SYSUINT;
                                   pDstStr: PWideChar; var pcDstSize: SYSUINT): HResult; stdcall;
    function DoConversionFromUnicode(pSrcStr: PWideChar; var pcSrcSize: SYSUINT;
                                     pDstStr: PAnsiChar; var pcDstSize: SYSUINT): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IMultiLanguage
// Flags:     (0)
// GUID:      {275C23E1-3747-11D0-9FEA-00AA003F8646}
// *********************************************************************//
  IMultiLanguage = interface(IUnknown)
    ['{275C23E1-3747-11D0-9FEA-00AA003F8646}'] // Do Not Localize
    function GetNumberOfCodePageInfo(out pcCodePage: SYSUINT): HResult; stdcall;
    function GetCodePageInfo(uiCodePage: SYSUINT; out pCodePageInfo: tagMIMECPINFO): HResult; stdcall;
    function GetFamilyCodePage(uiCodePage: SYSUINT; out puiFamilyCodePage: SYSUINT): HResult; stdcall;
    function EnumCodePages(grfFlags: Cardinal; out ppEnumCodePage: IEnumCodePage): HResult; stdcall;
    function GetCharsetInfo(const Charset: WideString; out pCharsetInfo: tagMIMECSETINFO): HResult; stdcall;
    function IsConvertible(dwSrcEncoding: Cardinal; dwDstEncoding: Cardinal): HResult; stdcall;
    function ConvertString(var pdwMode: Cardinal; dwSrcEncoding: Cardinal; dwDstEncoding: Cardinal; 
                           var pSrcStr: Byte; var pcSrcSize: SYSUINT; var pDstStr: Byte; 
                           var pcDstSize: SYSUINT): HResult; stdcall;
    function ConvertStringToUnicode(var pdwMode: Cardinal; dwEncoding: Cardinal;
                                    pSrcStr: PAnsiChar; var pcSrcSize: SYSUINT;
                                    pDstStr: PWideChar; var pcDstSize: SYSUINT): HResult; stdcall;
    function ConvertStringFromUnicode(var pdwMode: Cardinal; dwEncoding: Cardinal; 
                                      pSrcStr: PWideChar; var pcSrcSize: SYSUINT;
                                      pDstStr: PAnsiChar; var pcDstSize: SYSUINT): HResult; stdcall;
    function ConvertStringReset: HResult; stdcall;
    function GetRfc1766FromLcid(locale: Cardinal; out pbstrRfc1766: WideString): HResult; stdcall;
    function GetLcidFromRfc1766(out plocale: Cardinal; const bstrRfc1766: WideString): HResult; stdcall;
    function EnumRfc1766(out ppEnumRfc1766: IEnumRfc1766): HResult; stdcall;
    function GetRfc1766Info(locale: Cardinal; out pRfc1766Info: tagRFC1766INFO): HResult; stdcall;
    function CreateConvertCharset(uiSrcCodePage: SYSUINT; uiDstCodePage: SYSUINT; 
                                  dwProperty: Cardinal; 
                                  out ppMLangConvertCharset: IMLangConvertCharset): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IMultiLanguage2
// Flags:     (0)
// GUID:      {DCCFC164-2B38-11D2-B7EC-00C04F8F5D9A}
// *********************************************************************//
  IMultiLanguage2 = interface(IUnknown)
    ['{DCCFC164-2B38-11D2-B7EC-00C04F8F5D9A}'] // Do Not Localize
    function GetNumberOfCodePageInfo(out pcCodePage: SYSUINT): HResult; stdcall;
    function GetCodePageInfo(uiCodePage: SYSUINT; LangId: Word; out pCodePageInfo: tagMIMECPINFO): HResult; stdcall;
    function GetFamilyCodePage(uiCodePage: SYSUINT; out puiFamilyCodePage: SYSUINT): HResult; stdcall;
    function EnumCodePages(grfFlags: Cardinal; LangId: Word; out ppEnumCodePage: IEnumCodePage): HResult; stdcall;
    function GetCharsetInfo(const Charset: WideString; out pCharsetInfo: tagMIMECSETINFO): HResult; stdcall;
    function IsConvertible(dwSrcEncoding: Cardinal; dwDstEncoding: Cardinal): HResult; stdcall;
    function ConvertString(var pdwMode: Cardinal; dwSrcEncoding: Cardinal; dwDstEncoding: Cardinal; 
                           var pSrcStr: Byte; var pcSrcSize: SYSUINT; var pDstStr: Byte; 
                           var pcDstSize: SYSUINT): HResult; stdcall;
    function ConvertStringToUnicode(var pdwMode: Cardinal; dwEncoding: Cardinal; 
                                    pSrcStr: PAnsiChar; var pcSrcSize: SYSUINT;
                                    pDstStr: PWideChar; var pcDstSize: SYSUINT): HResult; stdcall;
    function ConvertStringFromUnicode(var pdwMode: Cardinal; dwEncoding: Cardinal;
                                      pSrcStr: PWideChar; var pcSrcSize: SYSUINT;
                                      pDstStr: PAnsiChar; var pcDstSize: SYSUINT): HResult; stdcall;
    function ConvertStringReset: HResult; stdcall;
    function GetRfc1766FromLcid(locale: Cardinal; out pbstrRfc1766: WideString): HResult; stdcall;
    function GetLcidFromRfc1766(out plocale: Cardinal; const bstrRfc1766: WideString): HResult; stdcall;
    function EnumRfc1766(LangId: Word; out ppEnumRfc1766: IEnumRfc1766): HResult; stdcall;
    function GetRfc1766Info(locale: Cardinal; LangId: Word; out pRfc1766Info: tagRFC1766INFO): HResult; stdcall;
    function CreateConvertCharset(uiSrcCodePage: SYSUINT; uiDstCodePage: SYSUINT; 
                                  dwProperty: Cardinal; 
                                  out ppMLangConvertCharset: IMLangConvertCharset): HResult; stdcall;
    function ConvertStringInIStream(var pdwMode: Cardinal; dwFlag: Cardinal; var lpFallBack: Word; 
                                    dwSrcEncoding: Cardinal; dwDstEncoding: Cardinal; 
                                    const pstmIn: ISequentialStream; 
                                    const pstmOut: ISequentialStream): HResult; stdcall;
    function ConvertStringToUnicodeEx(var pdwMode: Cardinal; dwEncoding: Cardinal; 
                                      pSrcStr: PAnsiChar; var pcSrcSize: SYSUINT;
                                      pDstStr: PWideChar; var pcDstSize: SYSUINT; dwFlag: Cardinal;
                                      var lpFallBack: Word): HResult; stdcall;
    function ConvertStringFromUnicodeEx(var pdwMode: Cardinal; dwEncoding: Cardinal;
                                        pSrcStr: PWideChar; var pcSrcSize: SYSUINT;
                                        pDstStr: PAnsiChar; var pcDstSize: SYSUINT;
                                        dwFlag: Cardinal; var lpFallBack: Word): HResult; stdcall;
    function DetectCodepageInIStream(dwFlag: Cardinal; dwPrefWinCodePage: Cardinal; 
                                     const pstmIn: ISequentialStream; 
                                     var lpEncoding: tagDetectEncodingInfo; var pnScores: SYSINT): HResult; stdcall;
    function DetectInputCodepage(dwFlag: Cardinal; dwPrefWinCodePage: Cardinal; 
                                 pSrcStr: PAnsiChar; var pcSrcSize: SYSINT;
                                 var lpEncoding: tagDetectEncodingInfo; var pnScores: SYSINT): HResult; stdcall;
    function ValidateCodePage(uiCodePage: SYSUINT; hwnd: HWND): HResult; stdcall;
    function GetCodePageDescription(uiCodePage: SYSUINT; lcid: Cardinal; lpWideCharStr: PWideChar; 
                                    cchWideChar: SYSINT): HResult; stdcall;
    function IsCodePageInstallable(uiCodePage: SYSUINT): HResult; stdcall;
    function SetMimeDBSource(dwSource: tagMIMECONTF): HResult; stdcall;
    function GetNumberOfScripts(out pnScripts: SYSUINT): HResult; stdcall;
    function EnumScripts(dwFlags: Cardinal; LangId: Word; out ppEnumScript: IEnumScript): HResult; stdcall;
    function ValidateCodePageEx(uiCodePage: SYSUINT; hwnd: HWND;
                                dwfIODControl: Cardinal): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ISequentialStream
// Flags:     (0)
// GUID:      {0C733A30-2A1C-11CE-ADE5-00AA0044773D}
// *********************************************************************//
  ISequentialStream = interface(IUnknown)
    ['{0C733A30-2A1C-11CE-ADE5-00AA0044773D}'] // Do Not Localize
    function RemoteRead(out pv: Byte; cb: Cardinal; out pcbRead: Cardinal): HResult; stdcall;
    function RemoteWrite(var pv: Byte; cb: Cardinal; out pcbWritten: Cardinal): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IStream
// Flags:     (0)
// GUID:      {0000000C-0000-0000-C000-000000000046}
// *********************************************************************//
  IStream = interface(ISequentialStream)
    ['{0000000C-0000-0000-C000-000000000046}'] // Do Not Localize
    function RemoteSeek(dlibMove: _LARGE_INTEGER; dwOrigin: Cardinal; 
                        out plibNewPosition: _ULARGE_INTEGER): HResult; stdcall;
    function SetSize(libNewSize: _ULARGE_INTEGER): HResult; stdcall;
    function RemoteCopyTo(const pstm: ISequentialStream; cb: _ULARGE_INTEGER; 
                          out pcbRead: _ULARGE_INTEGER; out pcbWritten: _ULARGE_INTEGER): HResult; stdcall;
    function Commit(grfCommitFlags: Cardinal): HResult; stdcall;
    function Revert: HResult; stdcall;
    function LockRegion(libOffset: _ULARGE_INTEGER; cb: _ULARGE_INTEGER; dwLockType: Cardinal): HResult; stdcall;
    function UnlockRegion(libOffset: _ULARGE_INTEGER; cb: _ULARGE_INTEGER; dwLockType: Cardinal): HResult; stdcall;
    function Stat(out pstatstg: tagSTATSTG; grfStatFlag: Cardinal): HResult; stdcall;
    function Clone(out ppstm: ISequentialStream): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IMLangCodePages
// Flags:     (0)
// GUID:      {359F3443-BD4A-11D0-B188-00AA0038C969}
// *********************************************************************//
  IMLangCodePages = interface(IUnknown)
    ['{359F3443-BD4A-11D0-B188-00AA0038C969}'] // Do Not Localize
    function GetCharCodePages(chSrc: WideChar; out pdwCodePages: Cardinal): HResult; stdcall;
    function GetStrCodePages(pszSrc: PWideChar; cchSrc: Integer; dwPriorityCodePages: Cardinal;
                             out pdwCodePages: Cardinal; out pcchCodePages: Integer): HResult; stdcall;
    function CodePageToCodePages(uCodePage: SYSUINT; out pdwCodePages: Cardinal): HResult; stdcall;
    function CodePagesToCodePage(dwCodePages: Cardinal; uDefaultCodePage: SYSUINT; 
                                 out puCodePage: SYSUINT): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IMLangFontLink
// Flags:     (0)
// GUID:      {359F3441-BD4A-11D0-B188-00AA0038C969}
// *********************************************************************//
  IMLangFontLink = interface(IMLangCodePages)
    ['{359F3441-BD4A-11D0-B188-00AA0038C969}'] // Do Not Localize
    function GetFontCodePages(DC: HDC; Font: HFONT;
                              out pdwCodePages: Cardinal): HResult; stdcall;
    function MapFont(DC: HDC; dwCodePages: Cardinal;
                     SrcFont: HFONT; out phDestFont: HFONT): HResult; stdcall;
    function ReleaseFont(hFont: HFONT): HResult; stdcall;
    function ResetFontMapping: HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IMLangFontLink2
// Flags:     (0)
// GUID:      {DCCFC162-2B38-11D2-B7EC-00C04F8F5D9A}
// *********************************************************************//
  IMLangFontLink2 = interface(IMLangCodePages)
    ['{DCCFC162-2B38-11D2-B7EC-00C04F8F5D9A}'] // Do Not Localize
    function GetFontCodePages(DC: HDC; Font: HFONT;
                              out pdwCodePages: Cardinal): HResult; stdcall;
    function ReleaseFont(hFont: HFONT): HResult; stdcall;
    function ResetFontMapping: HResult; stdcall;
    function MapFont(DC: HDC; dwCodePages: Cardinal; chSrc: WideChar;
                     out pFont: HFONT): HResult; stdcall;
    function GetFontUnicodeRanges(DC: HDC; var puiRanges: SYSUINT;
                                  out pUranges: tagUNICODERANGE): HResult; stdcall;
    function GetScriptFontInfo(sid: Byte; dwFlags: Cardinal; var puiFonts: SYSUINT;
                               out pScriptFont: tagSCRIPFONTINFO): HResult; stdcall;
    function CodePageToScriptID(uiCodePage: SYSUINT; out pSid: Byte): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IMultiLanguage3
// Flags:     (0)
// GUID:      {4E5868AB-B157-4623-9ACC-6A1D9CAEBE04}
// *********************************************************************//
  IMultiLanguage3 = interface(IMultiLanguage2)
    ['{4E5868AB-B157-4623-9ACC-6A1D9CAEBE04}'] // Do Not Localize
    function DetectOutboundCodePage(dwFlags: Cardinal; lpWideCharStr: PWideChar; 
                                    cchWideChar: SYSUINT; var puiPreferredCodePages: SYSUINT; 
                                    nPreferredCodePages: SYSUINT; 
                                    var puiDetectedCodePages: SYSUINT; 
                                    var pnDetectedCodePages: SYSUINT; var lpSpecialChar: WideChar): HResult; stdcall;
    function DetectOutboundCodePageInIStream(dwFlags: Cardinal; const pStrIn: ISequentialStream;
                                             var puiPreferredCodePages: SYSUINT; 
                                             nPreferredCodePages: SYSUINT; 
                                             var puiDetectedCodePages: SYSUINT; 
                                             var pnDetectedCodePages: SYSUINT; 
                                             var lpSpecialChar: WideChar): HResult; stdcall;
  end;

// *********************************************************************//
// The Class CoCMLangString provides a Create and CreateRemote method to          
// create instances of the default interface IMLangString exposed by              
// the CoClass CMLangString. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCMLangString = class
    class function Create: IMLangString;
    class function CreateRemote(const MachineName: string): IMLangString;
  end;

// *********************************************************************//
// The Class CoCMLangConvertCharset provides a Create and CreateRemote method to
// create instances of the default interface IMLangConvertCharset exposed by
// the CoClass CMLangConvertCharset. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoCMLangConvertCharset = class
    class function Create: IMLangConvertCharset;
    class function CreateRemote(const MachineName: string): IMLangConvertCharset;
  end;

// *********************************************************************//
// The Class CoCMultiLanguage provides a Create and CreateRemote method to
// create instances of the default interface IMultiLanguage exposed by
// the CoClass CMultiLanguage. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoCMultiLanguage = class
    class function Create: IMultiLanguage;
    class function CreateRemote(const MachineName: string): IMultiLanguage;
  end;

implementation

uses
  ComObj;

class function CoCMLangString.Create: IMLangString;
begin
  Result := CreateComObject(CLSID_CMLangString) as IMLangString;
end;

class function CoCMLangString.CreateRemote(const MachineName: string): IMLangString;
begin
  Result := CreateRemoteComObject(MachineName, CLSID_CMLangString) as IMLangString;
end;

class function CoCMLangConvertCharset.Create: IMLangConvertCharset;
begin
  Result := CreateComObject(CLSID_CMLangConvertCharset) as IMLangConvertCharset;
end;

class function CoCMLangConvertCharset.CreateRemote(const MachineName: string): IMLangConvertCharset;
begin
  Result := CreateRemoteComObject(MachineName, CLSID_CMLangConvertCharset) as IMLangConvertCharset;
end;

class function CoCMultiLanguage.Create: IMultiLanguage;
begin
  Result := CreateComObject(CLSID_CMultiLanguage) as IMultiLanguage;
end;

class function CoCMultiLanguage.CreateRemote(const MachineName: string): IMultiLanguage;
begin
  Result := CreateRemoteComObject(MachineName, CLSID_CMultiLanguage) as IMultiLanguage;
end;

end.
