unit SciMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SciterApi, TiScriptApi, Sciter, StdCtrls, OleCtrls,
  ExtCtrls, ComCtrls, Menus, ComObj, ActiveX, SciDeDemo_TLB,
  ComServ, AppEvnts;

type
  TMainForm = class(TForm)
    Actions1: TMenuItem;
    Button1: TButton;
    cmdCallNative: TButton;
    cmdEval: TButton;
    cmdGetCaseHistory: TButton;
    cmdReload: TButton;
    ctxSciter: TPopupMenu;
    DumpHTML1: TMenuItem;
    GC: TButton;
    Label1: TLabel;
    mm1: TMainMenu;
    mnuElementAtCursor: TMenuItem;
    mnuOpenFile: TMenuItem;
    mnuSaveFile: TMenuItem;
    N1: TMenuItem;
    NavigatetoSciterwebsite1: TMenuItem;
    ofd: TOpenDialog;
    pnlCommands: TPanel;
    pnlContainer: TPanel;
    Sciter1: TSciter;
    sfd: TSaveDialog;
    spl1: TSplitter;
    txt1: TEdit;
    txt2: TEdit;
    txtLog: TMemo;
    cmdCallTiScript: TButton;
    procedure Button1Click(Sender: TObject);
    procedure cmdCallNativeClick(Sender: TObject);
    procedure cmdCallTiScriptClick(Sender: TObject);
    procedure cmdEvalClick(Sender: TObject);
    procedure cmdGetCaseHistoryClick(Sender: TObject);
    procedure cmdReloadClick(Sender: TObject);
    procedure cmdSaveToFileClick(Sender: TObject);
    procedure cmdShowInspectorClick(Sender: TObject);
    procedure DumpHTML1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GCClick(Sender: TObject);
    procedure mnuElementAtCursorClick(Sender: TObject);
    procedure mnuOpenFileClick(Sender: TObject);
    procedure NavigatetoSciterwebsite1Click(Sender: TObject);
    procedure OnSciterOut(ASender: TObject; const msg: WideString);
    procedure Sciter1DocumentComplete(ASender: TObject; const url: WideString);
    procedure Sciter1LoadData(ASender: TObject; const url: WideString; resType:
        SciterResourceType; requestId: Integer; out discard: Boolean);
    procedure Sciter1Message(ASender: TObject; const Args: TSciterOnMessageEventArgs);
    procedure Sciter1ScriptingCall(ASender: TObject; const Args:
        TElementOnScriptingCallArgs);
  private
    FBodyEvents: IElementEvents;
    FButton: TButton;
    FDivRequestEvents: IElementEvents;
    FExamplesBase: WideString;
    FHomeUrl: WideString;
    FTimerDivEvents: IElementEvents;
    FTxtEvents: IElementEvents;
    procedure OnBodyMethodCall(ASender: TObject; const Args: TElementOnScriptingCallArgs);
    procedure OnDivRequestDataArrived(ASender: TObject; const Args: TElementOnDataArrivedEventArgs);
    procedure OnDivTimer(ASender: TObject; const Args: TElementOnTimerEventArgs);
    procedure OnElementControlEvent(ASender: TObject; const Args: TElementOnControlEventArgs);
    procedure OnElementMouse(ASender: TObject; const Args: TElementOnMouseEventArgs);
    procedure OnElementSize(ASender: TObject; const Args: TElementOnSizeEventArgs);
    procedure OnNativeButtonClick(Sender: TObject);
    procedure OnSciterControlEvent(ASender: TObject; const Args: TElementOnControlEventArgs);
  end;

  { For testing purposes }
  TTest = class(TAutoIntfObject, ITest)
  public
    constructor Create;
    destructor Destroy; override;
    procedure SayHello; safecall;
  end;


function CreateObjectNative(vm: HVM): tiscript_value; cdecl;
function SayHelloNative(c: HVM): tiscript_value; cdecl;

var
  MainForm: TMainForm;

implementation

uses SciterOle, SciterNative, NativeForm, Math;

{$R *.dfm}
{$R ..\resources\Richtext.res}
{$R ..\resources\Mvc.res}

procedure TMainForm.Button1Click(Sender: TObject);
var
  sv: TSciterValue;
begin
  sv := Sciter1.JsonToSciterValue(' { firstName: "Lars", lastName: "Carlsson", age: 70, address: { country: "Sweden", city: "Stockholm" }}');
  ShowMessage(Sciter1.SciterValueToJson(sv));
end;

procedure TMainForm.cmdCallNativeClick(Sender: TObject);
begin
  ShowMessage(Sciter1.Call('Echo', ['Echo "Hello World" OK']));
end;

procedure TMainForm.cmdCallTiScriptClick(Sender: TObject);
begin
  ShowMessage(Sciter1.TiScriptCall('', 'Echo', ['Echo "Hello World" OK']));
end;

procedure TMainForm.cmdEvalClick(Sender: TObject);
begin
  try
    ShowMessage(Sciter1.Call('sciter_sum', [StrToInt(txt1.Text), StrToInt(txt2.Text)]));
  except
    on E:Exception do ShowMessage(E.Message);
  end;
end;

procedure TMainForm.cmdGetCaseHistoryClick(Sender: TObject);
var
  s: OleVariant;
begin
  s := Sciter1.Eval('caseHistory');
  ShowMessage(s);
end;

procedure TMainForm.cmdReloadClick(Sender: TObject);
begin
  Sciter1.LoadURL(FHomeUrl);
end;

procedure TMainForm.cmdSaveToFileClick(Sender: TObject);
begin
  if sfd.Execute then
    Sciter1.SaveToFile(sfd.FileName);  
end;

procedure TMainForm.cmdShowInspectorClick(Sender: TObject);
begin
  Sciter1.ShowInspector;
end;

procedure TMainForm.DumpHTML1Click(Sender: TObject);
begin
  txtLog.Lines.Clear;
  txtLog.Text := Sciter1.Root.OuterHtml;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  nf: TNativeForm;
  pTest: ITest;
  pXml: OleVariant;
begin
  Caption := Caption + ' :: Sciter version ' + Sciter1.Version;
  FExamplesBase := ExtractFileDir(Application.ExeName);
  FExamplesBase := Sciter1.FilePathToURL(FExamplesBase) + '/';
  FHomeURL := FExamplesBase + 'scide.htm';
  Sciter1.LoadUrl(FHomeURL);

  // Registering native functions
  Sciter1.RegisterNativeFunction('CreateObject', ptiscript_method(@CreateObjectNative));
  Sciter1.RegisterNativeFunction('SayHello',     ptiscript_method(@SayHelloNative));

  // Registering native form
  nf := TNativeForm.Create;
  Sciter1.RegisterNativeClass(nf, true);

  // Registering external OLE object variable
  pTest := TTest.Create;
  Sciter1.RegisterComObject('Test', pTest);

  // Registering another external OLE
  pXml := CreateOleObject('MSXML2.DOMDocument');
  pXml.LoadXML('<xml><item>Foo</item><item>Bar</item></xml>');
  Sciter1.RegisterComObject('XML', pXml);

  Sciter1.Println('Hello', []);
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  Sciter1.SetFocus;
end;

procedure TMainForm.GCClick(Sender: TObject);
begin
  Sciter1.GC;
end;

procedure TMainForm.mnuElementAtCursorClick(Sender: TObject);
var
  pt: TPoint;
  pEl: IElement;
begin
  pt := Mouse.CursorPos;
  pt := Sciter1.ScreenToClient(pt);
  pEl := Sciter1.FindElement(pt);
  if pEl <> nil then
    txtLog.Lines.Add(Format('Element at %d:%d is %s', [pt.X, pt.Y, pEl.Tag]));
end;

procedure TMainForm.mnuOpenFileClick(Sender: TObject);
begin
  if ofd.Execute then
    Sciter1.LoadURL(Sciter1.FilePathToURL(ofd.FileName));
end;

procedure TMainForm.NavigatetoSciterwebsite1Click(Sender: TObject);
begin
  Sciter1.LoadURL('http://www.terrainformatica.com/sciter/main.whtm');
end;

procedure TMainForm.OnBodyMethodCall(ASender: TObject;
  const Args: TElementOnScriptingCallArgs);
begin
  if Args.Method = 'Foo' then
  begin
    ShowMessage(Args.Argument[0]);
    Args.Handled := True;
  end;
end;

procedure TMainForm.OnDivRequestDataArrived(ASender: TObject; const Args: TElementOnDataArrivedEventArgs);
begin
  Args.Target.Text := Format('Got %d bytes of data from %s. HTTP status: %d', [Args.Stream.Size, Args.Uri, Args.Status]);
  Args.Handled := True; 
end;

procedure TMainForm.OnDivTimer(ASender: TObject; const Args: TElementOnTimerEventArgs);
begin
  Args.Target.Text := 'Timer event at ' + DateTimeToStr(Now);
  Args.Continue := False;
end;

procedure TMainForm.OnElementControlEvent(ASender: TObject; const Args: TElementOnControlEventArgs);
begin
  txtLog.Lines.Add(Format('ControlEvent of type %d on %s, value=%s', [Integer(Args.EventType), Args.Target.Tag, Args.Target.Value]));
end;

procedure TMainForm.OnElementMouse(ASender: TObject; const Args: TElementOnMouseEventArgs);
begin
  txtLog.Lines.Add(Format('MouseEvent of type %d at %d:%d', [Integer(Args.EventType), Args.X, Args.Y]));
end;

procedure TMainForm.OnElementSize(ASender: TObject;
  const Args: TElementOnSizeEventArgs);
begin
  txtLog.Lines.Add(Format('SizeEvent', []));
end;

procedure TMainForm.OnNativeButtonClick(Sender: TObject);
begin
  ShowMessage('It works');
end;

procedure TMainForm.OnSciterControlEvent(ASender: TObject;
  const Args: TElementOnControlEventArgs);
var
  pDiv: IElement;
  pCol: IElementCollection;
  i: Integer;
  pPre: IElement;
  sText: WideString;

  procedure Dump(const El: IElement; var Text: WideString);
  var
    i: Integer;
    j: Integer;
  begin
    Text := Text + El.Tag + ' [ ';
    for j := 0 to El.AttrCount - 1 do
    begin
      Text := Text + El.GetAttributeName(j) + '="' + El.GetAttributeValue(j) + '" ';
    end;
    Text := Text + ' ] ' + #13#10;
    for i := 0 to El.ChildrenCount - 1 do
      Dump(El.GetChild(i), Text);
  end;
begin
  if Args.EventType = BUTTON_CLICK then
  begin
    if Args.Target.ID = 'cmdCreateHeadings' then
    begin
      pDiv := Sciter1.Root.Select('#divHeadings');
      if pDiv <> nil then
      begin
        for i := 1 to 10 do
        begin
          pDiv.AppendChild(pDiv.CreateElement('h4', 'Heading ' + IntToStr(i)));
        end;
      end;
    end;

    if Args.Target.ID = 'cmdCloneHeadings' then
    begin
      pDiv := Sciter1.Root.Select('#divHeadings');
      if pDiv <> nil then
      begin
        for i := 0 to Min(pDiv.ChildrenCount, 10) - 1 do
          pDiv.AppendChild(pDiv.GetChild(i).CloneElement);
      end;
    end;

    if Args.Target.ID = 'cmdChangeHeadingsText' then
    begin
      pDiv := Sciter1.Root.Select('#divHeadings');
      if pDiv <> nil then
      begin
        pCol := pDiv.SelectAll('h4');
        for i := 0 to pCol.Count - 1 do
          pCol[i].Text := 'Heading (text changed at ' + DateTimeToStr(Now) + ')';
      end;
    end;

    if Args.Target.ID = 'cmdRemoveHeadings' then
    begin
      pDiv := Sciter1.Root.Select('#divHeadings');
      if pDiv <> nil then
      begin
        pDiv.SelectAll('h4').RemoveAll;
      end;
    end;

    if Args.Target.ID = 'cmdDump' then
    begin
      pPre := Sciter1.Root.Select('#preDump');
      sText := '';
      Dump(Sciter1.Root, sText);
      pPre.Text := sText;
    end;

    if Args.Target.ID = 'cmdStartTimer' then
    begin
      pDiv := Sciter1.Root.Select('#divTimer');
      if pDiv <> nil then
        pDiv.SetTimer(1000);
    end;

    if Args.Target.ID = 'cmdStopTimer' then
    begin
      pDiv := Sciter1.Root.Select('#divTimer');
      if pDiv <> nil then
        pDiv.StopTimer;
    end;

    if Args.Target.ID = 'cmdRequest' then
    begin
      pDiv := Sciter1.Root.Select('#divRequest');
      pDiv.Request('http://terrainformatica.com/sciter', GET_ASYNC);
    end;

    if Args.Target.ID = 'cmdInsertBefore' then
      Sciter1.Root.Select('#spanBeforeAfter').InsertBefore('<span style="color: red">Before</span>');
    if Args.Target.ID = 'cmdInsertAfter' then
      Sciter1.Root.Select('#spanBeforeAfter').InsertAfter('<span style="color: lime">After</span>');
  end;
end;

procedure TMainForm.OnSciterOut(ASender: TObject; const msg: WideString);
begin
  txtLog.Lines.Add(msg);
end;

procedure TMainForm.Sciter1DocumentComplete(ASender: TObject; const url:
    WideString);
var
  pBody: IElement;
  pDivContainer: IElement;
  pDivTimer: IElement;
  pTxt: IElement;
begin
  if FButton <> nil then
    FreeAndNil(FButton);
  txtLog.Lines.Add('OnDocumentComplete: ' + url);
  pBody := Sciter1.Root.Select('body');
  FBodyEvents := pBody as IElementEvents;
  FBodyEvents.OnControlEvent := OnSciterControlEvent;
  FBodyEvents.OnScriptingCall := OnBodyMethodCall;

  pDivContainer := Sciter1.Root.Select('#divContainer');
  if pDivContainer <> nil then
  begin
    FButton := TButton.Create(Self);
    FButton.Parent := Sciter1;
    FButton.Caption := 'Native button';
    FButton.OnClick := OnNativeButtonClick;
    FButton.Font.Color := clGreen;
    pDivContainer.AttachHwndToElement(FButton.Handle);
  end;

  pTxt := Sciter1.Root.Select('#txtEvents');
  if pTxt <> nil then
  begin
    FTxtEvents := pTxt as IElementEvents;
    FTxtEvents.OnControlEvent := OnElementControlEvent;
    FTxtEvents.OnMouse := OnElementMouse;
    FTxtEvents.OnSize := OnElementSize;
  end;

  pDivTimer := Sciter1.Root.Select('#divTimer');
  if pDivTimer <> nil then
  begin
    FTimerDivEvents := pDivTimer as IElementEvents;
    FTimerDivEvents.OnTimer := OnDivTimer;
  end;

  FDivRequestEvents := Sciter1.Root.Select('#divRequest') as IElementEvents;
  FDivRequestEvents.OnDataArrived := OnDivRequestDataArrived;
end;

procedure TMainForm.Sciter1LoadData(ASender: TObject; const url: WideString;
    resType: SciterResourceType; requestId: Integer; out discard: Boolean);
var
  sFileName: AnsiString;
  pMemStm: TMemoryStream;
begin
  if Pos(WideString('scide://'), Url) = 1 then
  begin
    sFileName := StringReplace(Url, 'scide://', '', []);
    pMemStm := TMemoryStream.Create;
    pMemStm.LoadFromFile(sFileName);
    pMemStm.Position := 0;
    Sciter1.DataReady(url, pMemStm.Memory, pMemStm.Size);
    pMemStm.Free;
    Discard := True;
  end;
end;

procedure TMainForm.Sciter1Message(ASender: TObject; const Args:
    TSciterOnMessageEventArgs);
begin
  case Args.Severity of
    OS_INFO, OS_ERROR:
      txtLog.Lines.Add(Args.Message);
  end;
end;

procedure TMainForm.Sciter1ScriptingCall(ASender: TObject; const Args:
    TElementOnScriptingCallArgs);
begin
  if Args.Method = 'Foo' then
  begin
    ShowMessage('Method ' + Args.Method + ' is being called');
    Args.Handled := True;
    Args.ReturnValue := 100;
  end;
  // else Handled = False and Sciter will emit a warning message
end;

{ Intercepting non-existing function call }
function SayHelloNative(c: HVM): tiscript_value; cdecl;
begin
  ShowMessage('Hello!');
  Result := NI.int_value(0);
end;

function CreateObjectNative(vm: HVM): tiscript_value; cdecl;
var
  oVal: OleVariant;
  tProgId: tiscript_value;
  pProgId: PWideChar;
  iCnt: UINT;
  sProgId: WideString;
begin
  Result := NI.nothing_value;
  try
    iCnt := NI.get_arg_count(vm);
    // TODO: Check args count

    tProgId := NI.get_arg_n(vm, 2);
    NI.get_string_value(tProgId, pProgId, iCnt);
    sProgId := WideString(pProgId);
    oVal := CreateOleObject(sProgId);
    Result := WrapOleObject(vm, IDispatch(oVal));
  except
    on E:Exception do
      ThrowError(vm, E.Message);
  end;
end;


{ TTest }

constructor TTest.Create;
begin
  inherited Create(ComServer.TypeLib, IID_ITest);
end;

destructor TTest.Destroy;
begin
  inherited;
end;

procedure TTest.SayHello;
begin
  ShowMessage('TTest: Hello!');
end;

initialization

end.
