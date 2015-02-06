unit SciDe;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SciterIntf, SciterApi, TiScriptApi, Sciter, StdCtrls, OleCtrls,
  ExtCtrls;

type
  TMainForm = class(TForm)
    cmd1: TButton;
    cmd2: TButton;
    cmd3: TButton;
    cmd4: TButton;
    txt1: TMemo;
    cmd5: TButton;
    pnl1: TPanel;
    cmd6: TButton;
    cmd7: TButton;
    cmd8: TButton;
    cmd9: TButton;
    cmd10: TButton;
    cmd11: TButton;
    cmd12: TButton;
    procedure cmd10Click(Sender: TObject);
    procedure cmd11Click(Sender: TObject);
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
  private
    { Private declarations }
    FSciter: TSciter;
    procedure OnErr(Sender: TObject; const Message: WideString);
    procedure OnElementMouse(ASender: TObject; const target: IElement; eventType: Integer;
                                                x: Integer; y: Integer; buttons: Integer;
                                                keys: Integer);
    procedure OnElementControlEvent(ASender: TObject; const target: IElement; eventType: Integer;
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

procedure TMainForm.cmd1Click(Sender: TObject);
var
  pCol: IElementCollection;
  pTxt: TElement;
begin
  pTxt := FSciter.Root.Select('input');
  pTxt.OnMouse := OnElementMouse;
  pTxt.OnControlEvent := OnElementControlEvent;
end;

function SayHelloNative(c: HVM): tiscript_value; cdecl;
begin
  ShowMessage('OK');
  Result := NI.int_value(0);
end;

procedure TMainForm.cmd10Click(Sender: TObject);
var
  pT: IElement;
  pArr: Variant;
begin
  pArr := VarArrayCreate([0, 2], varInteger);
  VarArrayPut(pArr, 1, [0]);
  VarArrayPut(pArr, 11, [1]);
  VarArrayPut(pArr, 29, [2]);

  FSciter.Root.Select('input').Value := Now;
  ShowMessage(FSciter.Root.Select('input').Value);;
end;

procedure TMainForm.cmd11Click(Sender: TObject);
begin
  FSciter.LoadURL('http://txt.newsru.com');
end;

procedure TMainForm.cmd2Click(Sender: TObject);
var
  method_def: ptiscript_method_def;
  method_impl: ptiscript_method;
  smethod_name: AnsiString;
  func: tiscript_value;
  funcName: tiscript_value;
  pwfuncName: PWideChar;
  i: UINT;
  vm: HVM;
  zns: tiscript_value;
  retval: tiscript_value;
begin
  vm := API.SciterGetVM(FSciter.Handle);

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
    ShowMessage(FSciter.Call('hello_from_sciter', []));
  except
    on E:Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TMainForm.cmd4Click(Sender: TObject);
var
  pDisp: IDispatch;
  oDisp: OleVariant;
begin
  oDisp := CreateOleObject('VBScript.RegExp');
  pDisp := IDispatch(oDisp);
  pDisp._AddRef;
  FSciter.RegisterComObject('re', pDisp);
end;

procedure TMainForm.cmd5Click(Sender: TObject);
var
  pBody: IElement;
  pH: IElement;
begin
  pBody := FSciter.Root.Select('body');
  pH := FSciter.Root.CreateElement('h1', 'Heading1');
  pBody.AppendChild(pH);
end;

procedure TMainForm.cmd6Click(Sender: TObject);
var
  pBody: IElement;
  sMessage: AnsiString;
begin
  pBody := FSciter.Select('body');
  sMessage := Format('<body> has %d child nodes. First node tag is %s',
    [pBody.ChildrenCount, pBody.GetChild(0).Tag]);
  ShowMessage(sMessage);
end;

procedure TMainForm.cmd7Click(Sender: TObject);
var
  pBody: IElement;
begin
  pBody := FSciter.Root.Select('body');
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
  pH := FSciter.Root.SelectAll('h1');
  for i := 0 to pH.Count - 1 do
    pH[i].Delete;
end;

procedure TMainForm.cmd9Click(Sender: TObject);
var
  pH: IElementCollection;
  i: Integer;
begin
  pH := FSciter.Root.SelectAll('h1');
  for i := 0 to pH.Count - 1 do
    pH[i].InnerHtml := '<img src="theme:button-defaulted"/ >Heading ' + IntToStr(i);
end;

procedure TMainForm.OnElementControlEvent(ASender: TObject;
  const target: IElement; eventType, reason: Integer;
  const source: IElement);
begin
  txt1.Lines.Add(Format('%d %s', [eventType, target.Value]));
end;

procedure TMainForm.OnElementMouse(ASender: TObject; const target: IElement;
  eventType, x, y, buttons, keys: Integer);
begin
  txt1.Lines.Add(Format('%d %d', [x, y]));
end;

procedure TMainForm.OnErr(Sender: TObject; const Message: WideString);
begin
  txt1.Lines.Add(Message);
end;

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;
  FSciter := TSciter.Create(Self);
  FSciter.Parent := pnl1;
  FSciter.Align := alClient;
  FSciter.OnStdErr := OnErr;
  FSciter.TabOrder := 0;
  FSciter.OnStdOut := OnErr;
  FSciter.LoadHtml('<html>' +
                          '<script type="text/tiscript">function hello_from_sciter() {return "Hello!";} function self#cmd.onClick() { re.Pattern = "\\d\\d"; var rv = re.Test("aaa23bbb"); stdout.println(rv); }</script>' +
                          '<body style=""><h1>Test</h1><button id="cmd">...</button>' +
                          '<input type="time" id="control" value="01:12:32">' +
                          '<textarea style="width: 300px; height: 200px"></textarea>' +
                          '</body></html>', '');
end;

procedure TMainForm.cmd12Click(Sender: TObject);
begin
  FSciter.SetFocus;
end;

end.
