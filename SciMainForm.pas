unit SciMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SciterApi, TiScriptApi, Sciter, StdCtrls, OleCtrls,
  ExtCtrls, ComCtrls, ShellCtrls, Menus;

type
  TMainForm = class(TForm)
    pnlContainer: TPanel;
    pc: TPageControl;
    tsBrowser: TTabSheet;
    ts2: TTabSheet;
    ts3: TTabSheet;
    tsDOM: TTabSheet;
    cmd2: TButton;
    cmd3: TButton;
    cmd1: TButton;
    tv1: TShellTreeView;
    sctr1: TSciter;
    txtLog: TMemo;
    spl1: TSplitter;
    mm1: TMainMenu;
    Actions1: TMenuItem;
    NavigatetoSciterwebsite1: TMenuItem;
    cmd4: TButton;
    cmdChangeHeadingsText: TButton;
    cmdRemoveHeadings: TButton;
    DumpHTML1: TMenuItem;
    cmdUnsubscribe: TButton;
    procedure FormCreate(Sender: TObject);
    procedure cmd12Click(Sender: TObject);
    procedure cmd1Click(Sender: TObject);
    procedure cmd2Click(Sender: TObject);
    procedure cmd3Click(Sender: TObject);
    procedure cmd4Click(Sender: TObject);
    procedure cmd5Click(Sender: TObject);
    procedure cmd6Click(Sender: TObject);
    procedure cmd7Click(Sender: TObject);
    procedure cmd8Click(Sender: TObject);
    procedure cmd9Click(Sender: TObject);
    procedure cmdChangeHeadingsTextClick(Sender: TObject);
    procedure cmdRemoveHeadingsClick(Sender: TObject);
    procedure cmdUnsubscribeClick(Sender: TObject);
    procedure DumpHTML1Click(Sender: TObject);
    procedure NavigatetoSciterwebsite1Click(Sender: TObject);
    procedure pcChange(Sender: TObject);
    procedure sctr1StdErr(ASender: TObject; const msg: WideString);
    procedure tv1Change(Sender: TObject; Node: TTreeNode);
  private
    { Private declarations }
    procedure OnElementMouse(ASender: TObject; const target: IElement;
      eventType: MOUSE_EVENTS; x, y: Integer; buttons: MOUSE_BUTTONS; keys: KEYBOARD_STATES);
    procedure OnElementControlEvent(ASender: TObject; const target: IElement; eventType: BEHAVIOR_EVENTS;
                             reason: Integer; const source: IElement);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

var
  MainForm: TMainForm;

implementation

uses ComObj;

{$R *.dfm}

const
  DEFAULT_HTML: WideString = '<html>' +
                             '<head>' +
                             '<style>@import url(richtext.css);body { margin:0;} </style>' +
                             '<script type="text/tiscript">function hello_from_sciter() {return "Hello!";} </script>' +
                             '</head>' +
                             '<body>' +
                             '' +
                             '<richtext style="width:100%; height: 200px"><p>Some text</p>' +
                             '</richtext>' +
                             '</body></html>';

procedure TMainForm.cmd1Click(Sender: TObject);
var
  pBody: TElement;
begin
  pBody := sctr1.Root.Select('body');
  pBody.OnMouse := OnElementMouse;
  pBody.OnControlEvent := OnElementControlEvent;
end;

function SayHelloNative(c: HVM): tiscript_value; cdecl;
begin
  ShowMessage('OK');
  Result := NI.int_value(0);
end;

procedure TMainForm.cmd2Click(Sender: TObject);
var
  method_def: ptiscript_method_def;
  smethod_name: AnsiString;
  func: tiscript_value;
  funcName: tiscript_value;
  pwfuncName: PWideChar;
  i: UINT;
  vm: HVM;
  zns: tiscript_value;
  retval: tiscript_value;
begin
  vm := API.SciterGetVM(sctr1.Handle);

  smethod_name := 'SayHello';

  New(method_def);
  method_def^.dispatch := nil;
  method_def^.name := nil;
  method_def^.handler := nil;
  method_def^.tag := nil;

  method_def.name := StrNew(PAnsiChar(smethod_name));
  method_def.handler := @SayHelloNative;

  func := NI.native_function_value(vm, method_def);
  if not NI.is_native_function(func) then
  begin
    ShowMessage('Operation failed.');
    Exit;
  end;

  funcName := NI.string_value(vm, PWideChar(WideString(smethod_name)), Length(smethod_name));
  NI.get_string_value(funcName, pwFuncName, i);
  zns := NI.get_global_ns(vm);
  NI.set_prop(vm, zns, funcName, func);

  NI.call(vm, zns, func, nil, 0, retval);
  // FSciter.Call(smethod_name, []);
end;

procedure TMainForm.cmd3Click(Sender: TObject);
begin
  try
    ShowMessage(sctr1.Call('hello_from_sciter', []));
  except
    on E:Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TMainForm.cmd4Click(Sender: TObject);
var
  pBody: IElement;
  i: Integer;
begin
  pBody := sctr1.Select('body');
  for i := 0 to 10 do
  begin
    pBody.AppendChild(pBody.CreateElement('h1', 'Heading ' + IntToStr(i)));
  end;
end;

procedure TMainForm.cmd5Click(Sender: TObject);
var
  pBody: IElement;
  pH: IElement;
begin
  pBody := sctr1.Root.Select('body');
  pH := sctr1.Root.CreateElement('h1', 'Heading1');
  pBody.AppendChild(pH);
end;

procedure TMainForm.cmd6Click(Sender: TObject);
var
  pBody: IElement;
  sMessage: AnsiString;
begin
  pBody := sctr1.Select('body');
  sMessage := Format('<body> has %d child nodes. First node tag is %s',
    [pBody.ChildrenCount, pBody.GetChild(0).Tag]);
  ShowMessage(sMessage);
end;

procedure TMainForm.cmd7Click(Sender: TObject);
var
  pBody: IElement;
begin
  pBody := sctr1.Root.Select('body');
  pBody.Attr['lang'] := 'RU';
  pBody.StyleAttr['background-color'] := '#FFFFFF';
  ShowMessage(pBody.StyleAttr['width']);
  ShowMessage(pBody.OuterHtml);
end;

procedure TMainForm.cmd8Click(Sender: TObject);
var
  pH: IElementCollection;
  i: Integer;
begin
  pH := sctr1.Root.SelectAll('h1');
  for i := 0 to pH.Count - 1 do
    pH[i].Delete;
end;

procedure TMainForm.cmd9Click(Sender: TObject);
var
  pH: IElementCollection;
  i: Integer;
begin
  pH := sctr1.Root.SelectAll('h1');
  for i := 0 to pH.Count - 1 do
    pH[i].InnerHtml := '<img src="theme:button-defaulted"/ >Heading ' + IntToStr(i);
end;

procedure TMainForm.OnElementControlEvent(ASender: TObject;
  const target: IElement; eventType: BEHAVIOR_EVENTS; reason: Integer;
  const source: IElement);
begin
  if target <> nil then
    txtLog.Lines.Add(Format('Control event of type %d, sender is %s, value is %s', [Integer(eventType), target.Tag, target.Value]))
  else
    txtLog.Lines.Add(Format('Control event of type %d', [Integer(eventType)]));
end;

procedure TMainForm.OnElementMouse(ASender: TObject; const target: IElement;
  eventType: MOUSE_EVENTS; x, y: Integer; buttons: MOUSE_BUTTONS; keys: KEYBOARD_STATES);
begin
  txtLog.Lines.Add(Format('MouseEvent of type %d at %d:%d', [Integer(eventType), x, y]));
end;

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  sctr1.LoadHtml(DEFAULT_HTML, '');
end;

procedure TMainForm.cmd12Click(Sender: TObject);
begin
  sctr1.SetFocus;
end;

procedure TMainForm.cmdChangeHeadingsTextClick(Sender: TObject);
var
  i: Integer;
  pList: IElementCollection;
begin
  pList := sctr1.SelectAll('h1');
  for i := 0 to pList.Count - 1 do
    pList[i].Text := 'Heading ' + IntToStr(i) + ' - text changed at ' + DateTimeToStr(Now);
end;

procedure TMainForm.cmdRemoveHeadingsClick(Sender: TObject);
var
  pList: IElementCollection;
begin
  pList := sctr1.SelectAll('h1');
  pList.RemoveAll;
end;

procedure TMainForm.cmdUnsubscribeClick(Sender: TObject);
var
  pBody: TElement;
begin
  pBody := sctr1.Root.Select('body');
  pBody.OnMouse := nil;
  pBody.OnControlEvent := nil;
end;

procedure TMainForm.DumpHTML1Click(Sender: TObject);
begin
  txtLog.Lines.Clear;
  txtLog.Text := sctr1.Html;
end;

procedure TMainForm.NavigatetoSciterwebsite1Click(Sender: TObject);
begin
  sctr1.LoadURL('http://www.terrainformatica.com');
end;

procedure TMainForm.pcChange(Sender: TObject);
begin
  if pc.ActivePage = tsDOM then
  begin
    sctr1.LoadHtml(DEFAULT_HTML, '');
  end;
end;

procedure TMainForm.sctr1StdErr(ASender: TObject; const msg: WideString);
begin
  txtLog.Lines.Add(msg);
end;

procedure TMainForm.tv1Change(Sender: TObject; Node: TTreeNode);
begin
  try
    txtLog.Clear;
    sctr1.LoadURL('file://' + StringReplace(tv1.Path, '\', '/', [rfReplaceAll]));
  except
  end;
end;

end.
