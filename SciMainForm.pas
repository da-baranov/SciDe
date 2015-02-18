unit SciMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SciterApi, TiScriptApi, Sciter, StdCtrls, OleCtrls,
  ExtCtrls, ComCtrls, ShellCtrls, Menus, ComObj, ActiveX, SciDeDemo_TLB,
  ComServ;

type
  TMainForm = class(TForm)
    Actions1: TMenuItem;
    cmdCallNative: TButton;
    cmdEval: TButton;
    ctxSciter: TPopupMenu;
    DumpHTML1: TMenuItem;
    GC: TButton;
    Label1: TLabel;
    mm1: TMainMenu;
    mnuElementAtCursor: TMenuItem;
    NavigatetoSciterwebsite1: TMenuItem;
    pnlCommands: TPanel;
    pnlContainer: TPanel;
    Sciter1: TSciter;
    spl1: TSplitter;
    txt1: TEdit;
    txt2: TEdit;
    txtLog: TMemo;
    procedure cmdCallNativeClick(Sender: TObject);
    procedure cmdEvalClick(Sender: TObject);
    procedure DumpHTML1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GCClick(Sender: TObject);
    procedure mnuElementAtCursorClick(Sender: TObject);
    procedure NavigatetoSciterwebsite1Click(Sender: TObject);
    procedure OnSciterOut(ASender: TObject; const msg: WideString);
    procedure Sciter1DocumentComplete(ASender: TObject; const url: WideString);
    procedure Sciter1MethodCall(ASender: TObject; const MethodName: WideString;
        const Args: array of OLEVariant; var ReturnValue: OLEVariant; var Handled:
        Boolean);
  private
    FExamplesBase: WideString;
    FHomeUrl: WideString;
    procedure OnElementControlEvent(ASender: TObject; const target: IElement; eventType: BEHAVIOR_EVENTS;
                             reason: Integer; const source: IElement);
    procedure OnElementMouse(ASender: TObject; const target: IElement;
      eventType: MOUSE_EVENTS; x, y: Integer; buttons: MOUSE_BUTTONS; keys: KEYBOARD_STATES);
    procedure OnElementSize(ASender: TObject; const target: IElement);
    procedure OnNativeButtonClick(Sender: TObject);
    procedure OnSciterControlEvent(ASender: TObject; const target: IElement; eventType: BEHAVIOR_EVENTS;
                             reason: Integer; const source: IElement);
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

uses SciterOle, SciterNative, NativeForm;

{$R *.dfm}
{$R Richtext.res}

procedure TMainForm.cmdCallNativeClick(Sender: TObject);
begin
  Sciter1.Eval('SayHello()');
  // Sciter1.Call('global::SayHello', []); // crashes here
end;

procedure TMainForm.cmdEvalClick(Sender: TObject);
begin
  try
    ShowMessage(Sciter1.Call('sciter_sum', [StrToInt(txt1.Text), StrToInt(txt2.Text)]));
  except
    on E:Exception do ShowMessage(E.Message);
  end;
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
begin
  FExamplesBase := ExtractFileDir(Application.ExeName);
  FExamplesBase := Sciter1.FilePathToURL(FExamplesBase) + '/';
  FHomeURL := FExamplesBase + 'scide.htm';
  Sciter1.LoadUrl(FHomeURL);

  // Registering native functions
  Sciter1.RegisterNativeFunction('CreateObject', @CreateObjectNative);
  Sciter1.RegisterNativeFunction('SayHello',     @SayHelloNative);

  // Registering native form
  nf := TNativeForm.Create;
  Sciter1.RegisterNativeClass(nf.SciterClassDef, false, false);

  // Registering external OLE object variable
  pTest := TTest.Create;
  Sciter1.RegisterComObject('Test', pTest);
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

procedure TMainForm.NavigatetoSciterwebsite1Click(Sender: TObject);
begin
  Sciter1.LoadURL('http://www.terrainformatica.com/sciter/main.whtm');
end;

procedure TMainForm.OnElementControlEvent(ASender: TObject;
  const target: IElement; eventType: BEHAVIOR_EVENTS; reason: Integer;
  const source: IElement);
begin
  txtLog.Lines.Add(Format('Control event of type %d on %s, value=%s', [Integer(eventType), target.Tag, target.Value]));
end;

procedure TMainForm.OnElementMouse(ASender: TObject; const target: IElement;
  eventType: MOUSE_EVENTS; x, y: Integer; buttons: MOUSE_BUTTONS; keys: KEYBOARD_STATES);
begin
  txtLog.Lines.Add(Format('MouseEvent of type %d at %d:%d', [Integer(eventType), x, y]));
end;

procedure TMainForm.OnElementSize(ASender: TObject;
  const target: IElement);
begin
  txtLog.Lines.Add(Format('Size event', []));
end;

procedure TMainForm.OnNativeButtonClick(Sender: TObject);
begin
  ShowMessage('It works');
end;

procedure TMainForm.OnSciterControlEvent(ASender: TObject;
  const target: IElement; eventType: BEHAVIOR_EVENTS; reason: Integer;
  const source: IElement);
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
  if eventType = BUTTON_CLICK then
  begin
    if target.ID = 'cmdCreateHeadings' then
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

    if target.ID = 'cmdChangeHeadingsText' then
    begin
      pDiv := Sciter1.Root.Select('#divHeadings');
      if pDiv <> nil then
      begin
        pCol := pDiv.SelectAll('h4');
        for i := 0 to pCol.Count - 1 do
          pCol[i].Text := 'Heading (text changed at ' + DateTimeToStr(Now) + ')';
      end;
    end;

    if target.ID = 'cmdRemoveHeadings' then
    begin
      pDiv := Sciter1.Root.Select('#divHeadings');
      if pDiv <> nil then
      begin
        pDiv.SelectAll('h4').RemoveAll;
      end;
    end;

    if target.ID = 'cmdDump' then
    begin
      pPre := Sciter1.Root.Select('#preDump');
      sText := '';
      Dump(Sciter1.Root, sText);
      pPre.Text := sText;
    end;
  end;
end;

procedure TMainForm.OnSciterOut(ASender: TObject; const msg: WideString);
begin
  txtLog.Lines.Add(msg);
end;

procedure TMainForm.Sciter1DocumentComplete(ASender: TObject; const url:
    WideString);
var
  pBody: TElement;
  pButton: TButton;

  pDivContainer: TElement;
  pTxtEvents: TElement;
begin
  txtLog.Lines.Add('Sciter OnDocumentComplete event');
  pBody := Sciter1.Root.Select('body');
  pBody.OnControlEvent := OnSciterControlEvent;

  pDivContainer := Sciter1.Root.Select('#divContainer');
  if pDivContainer <> nil then
  begin
    pButton := TButton.Create(Self);
    pButton.Parent := Sciter1;
    pButton.Caption := 'Native button';
    pButton.OnClick := OnNativeButtonClick;
    pButton.Font.Color := clGreen;
    pDivContainer.AttachHwndToElement(pButton.Handle);
  end;

  pTxtEvents := Sciter1.Root.Select('#txtEvents');
  if pTxtEvents <> nil then
  begin
    pTxtEvents.OnControlEvent := OnElementControlEvent;
    pTxtEvents.OnMouse := OnElementMouse;
    pTxtEvents.OnSize := OnElementSize;
  end;
end;

{ Intercepting non-existing function call }
procedure TMainForm.Sciter1MethodCall(ASender: TObject; const MethodName:
    WideString; const Args: array of OLEVariant; var ReturnValue: OleVariant;
    var Handled: Boolean);
begin
  if MethodName = 'Foo' then
  begin
    ShowMessage('Method ' + MethodName + ' is calling with argument ' + Args[0]);
    Handled := True;
  end;
  // else Handled = False and Sciter will emit a warning message
end;

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

end.
