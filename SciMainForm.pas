unit SciMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SciterApi, TiScriptApi, Sciter, StdCtrls, OleCtrls,
  ExtCtrls, ComCtrls, ShellCtrls, Menus;

type
  TMainForm = class(TForm)
    Actions1: TMenuItem;
    cmd1: TButton;
    cmd4: TButton;
    cmdChangeHeadingsText: TButton;
    cmdRemoveHeadings: TButton;
    cmdUnsubscribe: TButton;
    DumpHTML1: TMenuItem;
    mm1: TMainMenu;
    NavigatetoSciterwebsite1: TMenuItem;
    pc: TPageControl;
    pnlContainer: TPanel;
    sctr1: TSciter;
    spl1: TSplitter;
    ts3: TTabSheet;
    tsBrowser: TTabSheet;
    tsDOM: TTabSheet;
    tv1: TShellTreeView;
    txtLog: TMemo;
    cmdSetInnerText: TButton;
    cmdInnerHtml: TButton;
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
    procedure cmdInnerHtmlClick(Sender: TObject);
    procedure cmdRegisterOLEClick(Sender: TObject);
    procedure cmdRemoveHeadingsClick(Sender: TObject);
    procedure cmdSetInnerTextClick(Sender: TObject);
    procedure cmdUnsubscribeClick(Sender: TObject);
    procedure DumpHTML1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure NavigatetoSciterwebsite1Click(Sender: TObject);
    procedure sctr1StdErr(ASender: TObject; const msg: WideString);
    procedure tv1Change(Sender: TObject; Node: TTreeNode);
  private
    procedure OnElementControlEvent(ASender: TObject; const target: IElement; eventType: BEHAVIOR_EVENTS;
                             reason: Integer; const source: IElement);
    { Private declarations }
    procedure OnElementMouse(ASender: TObject; const target: IElement;
      eventType: MOUSE_EVENTS; x, y: Integer; buttons: MOUSE_BUTTONS; keys: KEYBOARD_STATES);
    procedure OnElementSize(ASender: TObject; const target: IElement);
  end;

function SayHelloNative(c: HVM): tiscript_value; cdecl;

var
  MainForm: TMainForm;

implementation

uses ComObj, SciterOleProxy;

{$R *.dfm}

procedure TMainForm.cmd12Click(Sender: TObject);
begin
  sctr1.SetFocus;
end;

procedure TMainForm.cmd1Click(Sender: TObject);
var
  pBody: TElement;
begin
  pBody := sctr1.Root.Select('body');
  if pBody <> nil then
  begin
    pBody.OnSize := OnElementSize;
    pBody.OnMouse := OnElementMouse;
    pBody.OnControlEvent := OnElementControlEvent;
  end;
end;

procedure TMainForm.cmd2Click(Sender: TObject);
begin
  sctr1.RegisterNativeFunction('SayHello', @SayHelloNative);
  sctr1.Call('SayHello', []);
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
  pH: IElement;
  i: Integer;
begin
  pBody := sctr1.Select('body');
  for i := 0 to 10 do
  begin
    pH := pBody.CreateElement('h2', 'Heading ' + IntToStr(i));
    pBody.AppendChild(pH);
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

procedure TMainForm.cmdChangeHeadingsTextClick(Sender: TObject);
var
  i: Integer;
  pList: IElementCollection;
  pItem: IElement;
begin
  pList := sctr1.SelectAll('h2');
  for i := 0 to pList.Count - 1 do
  begin
    pItem := pList[i];
    pItem.Text := 'Heading ' + IntToStr(i) + ' - text changed at ' + DateTimeToStr(Now);
  end;
end;

procedure TMainForm.cmdInnerHtmlClick(Sender: TObject);
var
  pDiv: IElement;
begin
  pDiv := sctr1.Root.Select('#content');
  if pDiv <> nil then
    pDiv.InnerHtml := '<h3>Inner HTML set at ' + DateTimeToStr(Now) + '</h3>';
end;

procedure TMainForm.cmdRegisterOLEClick(Sender: TObject);
var
  oDisp: OleVariant;
  pDisp: IDispatch;
begin
  oDisp := CreateOleObject('MSXML2.DOMDocument');
  oDisp.LoadXml('<x />');
  pDisp := IDispatch(oDisp);
  sctr1.RegisterComObject('xml', pDisp);
end;

procedure TMainForm.cmdRemoveHeadingsClick(Sender: TObject);
var
  pList: IElementCollection;
begin
  pList := sctr1.SelectAll('h2');
  pList.RemoveAll;
end;

procedure TMainForm.cmdSetInnerTextClick(Sender: TObject);
var
  pDiv: IElement;
begin
  pDiv := sctr1.Root.Select('#content');
  if pDiv <> nil then
    pDiv.Text := 'Inner text set at ' + DateTimeToStr(Now);
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

procedure TMainForm.FormCreate(Sender: TObject);
var
  sDefaultPath: AnsiString;
begin
  pc.ActivePage := tsBrowser;
  
  sDefaultPath := ExtractFileDir(Application.ExeName) + '\samples\scide\index.htm';
  sDefaultPath := 'file:///' + StringReplace(sDefaultPath, '\', '/', [rfReplaceAll]);
  sctr1.LoadUrl(sDefaultPath);
  tv1.Root := ExtractFileDir(Application.ExeName) + '\samples';
end;

procedure TMainForm.NavigatetoSciterwebsite1Click(Sender: TObject);
begin
  sctr1.LoadURL('http://www.terrainformatica.com/sciter/main.whtm');
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

procedure TMainForm.OnElementSize(ASender: TObject;
  const target: IElement);
begin
  txtLog.Lines.Add(Format('Size event', []));
end;

procedure TMainForm.sctr1StdErr(ASender: TObject; const msg: WideString);
begin
  txtLog.Lines.Add(msg);
end;

procedure TMainForm.tv1Change(Sender: TObject; Node: TTreeNode);
begin
  try
    if FileExists(tv1.Path) then
    begin
      txtLog.Clear;
      sctr1.LoadURL('file://' + StringReplace(tv1.Path, '\', '/', [rfReplaceAll]));
    end;
  except
  end;
end;

function SayHelloNative(c: HVM): tiscript_value; cdecl;
begin
  ShowMessage('OK');
  Result := NI.int_value(0);
end;



end.
