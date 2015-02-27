unit DemoBehavior;

interface

uses
  Sciter, SciterAPI, Windows, Dialogs;

type
  TDemoBehavior = class(TElement)
  private
    FTextArea: IElement;
    procedure OnMethodCallHandler(ASender: TObject; const target: IElement; const MethodName: WideString; const Args: array of OleVariant; var ReturnValue: OleVariant; var Handled: boolean);
  protected
    procedure DoBehaviorAttach; override;
    function DoMouse(const target: IElement; eventType: MOUSE_EVENTS;
      x, y: Integer; buttons: MOUSE_BUTTONS; keys: KEYBOARD_STATES): Boolean; override;
    function GetValue: OleVariant; override;
  public
    class function BehaviorName: AnsiString; override;
    constructor Create(ASciter: TSciter; AElement: HELEMENT); override;
  end;

implementation

{ TDemoBehavior }

class function TDemoBehavior.BehaviorName: AnsiString;
begin
  Result := 'DemoBehavior';
end;

constructor TDemoBehavior.Create(ASciter: TSciter; AElement: HELEMENT);
begin
  inherited;
  Self.OnScriptingCall := OnMethodCallHandler;
end;

function TDemoBehavior.GetValue: OleVariant;
begin
  Result := FTextArea.Text;
end;

procedure TDemoBehavior.DoBehaviorAttach;
begin
  Attr['style'] := 'border: 1px dotted #666666; background-color: #FFCCCC; padding: 20px';
  InnerHtml := '<h4>Behavior attach OK. Class that implements the behavior is ' + Self.ClassName + '</h4>';
  FTextArea := CreateElement('textarea', 'some text');
  AppendChild(FTextArea);
end;

function TDemoBehavior.DoMouse(const target: IElement; eventType: MOUSE_EVENTS;
      x, y: Integer; buttons: MOUSE_BUTTONS; keys: KEYBOARD_STATES): Boolean;
begin
  if eventType = MOUSE_UP then
  begin
    ShowMessage('Behavior MouseUp event is being handled.');
  end;
  Result := False;
end;

procedure TDemoBehavior.OnMethodCallHandler(ASender: TObject;
  const target: IElement; const MethodName: WideString;
  const Args: array of OleVariant; var ReturnValue: OleVariant;
  var Handled: boolean);
var
  sText: WideString;
begin
  if MethodName = 'nativeValue' then
  begin
    sText := GetValue;
    ReturnValue := sText;
    Handled := True;
  end;
end;

initialization
  
  SciterRegisterBehavior(TDemoBehavior);

end.
