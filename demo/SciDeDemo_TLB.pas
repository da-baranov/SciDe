unit SciDeDemo_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : 1.2
// File generated on 23.03.2015 12:30:04 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\git\SciDe\demo\SciDeDemo.tlb (1)
// LIBID: {C7F57E73-1F11-4185-A28E-A7E2CF3CC3BB}
// LCID: 0
// Helpfile: 
// HelpString: SciDeDemo Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  SciDeDemoMajorVersion = 1;
  SciDeDemoMinorVersion = 0;

  LIBID_SciDeDemo: TGUID = '{C7F57E73-1F11-4185-A28E-A7E2CF3CC3BB}';

  IID_ITest: TGUID = '{F538C667-84DE-4F23-BD56-4C87D73F7AE9}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  ITest = interface;
  ITestDisp = dispinterface;

// *********************************************************************//
// Interface: ITest
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F538C667-84DE-4F23-BD56-4C87D73F7AE9}
// *********************************************************************//
  ITest = interface(IDispatch)
    ['{F538C667-84DE-4F23-BD56-4C87D73F7AE9}']
    procedure SayHello; safecall;
  end;

// *********************************************************************//
// DispIntf:  ITestDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F538C667-84DE-4F23-BD56-4C87D73F7AE9}
// *********************************************************************//
  ITestDisp = dispinterface
    ['{F538C667-84DE-4F23-BD56-4C87D73F7AE9}']
    procedure SayHello; dispid 201;
  end;

implementation

uses ComObj;

end.
