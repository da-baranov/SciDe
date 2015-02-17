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
    ctxSciter: TPopupMenu;
    DumpHTML1: TMenuItem;
    mm1: TMainMenu;
    mnuElementAtCursor: TMenuItem;
    NavigatetoSciterwebsite1: TMenuItem;
    pc: TPageControl;
    pnlContainer: TPanel;
    Sciter1: TSciter;
    spl1: TSplitter;
    tsDOM: TTabSheet;
    txtLog: TMemo;
    GC: TButton;
    procedure DumpHTML1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GCClick(Sender: TObject);
    procedure mnuElementAtCursorClick(Sender: TObject);
    procedure NavigatetoSciterwebsite1Click(Sender: TObject);
    procedure OnSciterOut(ASender: TObject; const msg: WideString);
    procedure Sciter1DocumentComplete(ASender: TObject; const url: WideString);
  private
    FExamplesBase: WideString;
    FHomeUrl: WideString;
    procedure OnElementControlEvent(ASender: TObject; const target: IElement; eventType: BEHAVIOR_EVENTS;
                             reason: Integer; const source: IElement);
    { Private declarations }
    procedure OnElementMouse(ASender: TObject; const target: IElement;
      eventType: MOUSE_EVENTS; x, y: Integer; buttons: MOUSE_BUTTONS; keys: KEYBOARD_STATES);
    procedure OnElementSize(ASender: TObject; const target: IElement);
  end;

  { For testing purposes }
  TTest = class(TAutoIntfObject, ITest)
  public
    constructor Create;
    destructor Destroy; override;
    procedure SayHello; safecall;
  end;

function SayHelloNative(c: HVM): tiscript_value; cdecl;

var
  MainForm: TMainForm;

implementation

uses SciterOle, SciterNative, NativeForm;

{$R *.dfm}
{$R Richtext.res}

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

  // Register native function
  Sciter1.RegisterNativeFunction('SayHello', @SayHelloNative);

  // Register native form
  nf := TNativeForm.Create;
  Sciter1.RegisterNativeClass(nf.SciterClassDef, false, false);

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
var
  pDiv: IElement;
  pCol: IElementCollection;
  i: Integer;
  pPre: IElement;
  sText: WideString;

  procedure Dump(const El: IElement; var Text: WideString);
  var
    i: Integer;
  begin
    Text := Text + El.Tag + #13#10;
    for i := 0 to El.ChildrenCount - 1 do
      Dump(El.GetChild(i), Text);
  end;
begin
  if eventType = BUTTON_CLICK then
  begin
    if target.ID = 'cmdCreateHeadings' then
    begin
      pDiv := Sciter1.Root.Select('#divHeadings');

      for i := 1 to 10 do
      begin
        pDiv.AppendChild(pDiv.CreateElement('h4', 'Heading ' + IntToStr(i)));
      end;
    end;

    if target.ID = 'cmdChangeHeadingsText' then
    begin
      pDiv := Sciter1.Root.Select('#divHeadings');
      pCol := pDiv.SelectAll('h4');
      for i := 0 to pCol.Count - 1 do
        pCol[i].Text := 'Heading (text changed at ' + DateTimeToStr(Now) + ')';
    end;

    if target.ID = 'cmdRemoveHeadings' then
    begin
      pDiv := Sciter1.Root.Select('#divHeadings');
      pDiv.SelectAll('h4').RemoveAll;
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

procedure TMainForm.OnSciterOut(ASender: TObject; const msg: WideString);
begin
  txtLog.Lines.Add(msg);
end;

procedure TMainForm.Sciter1DocumentComplete(ASender: TObject; const url:
    WideString);
var
  pBody: TElement;
begin
  txtLog.Lines.Add('Sciter OnDocumentComplete event');
  pBody := Sciter1.Root.Select('body');
  pBody.OnControlEvent := OnElementControlEvent;
end;

function SayHelloNative(c: HVM): tiscript_value; cdecl;
begin
  ShowMessage('Hello!');
  Result := NI.int_value(0);
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
