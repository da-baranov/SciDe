unit DemoBehavior;

interface

uses
  Sciter, SciterAPI, Windows, Dialogs;

type
  TDemoBehavior = class(TElement)
  private
    FTextArea: IElement;
    procedure OnMethodCallHandler(ASender: TObject; const Args: TElementOnScriptingCallArgs);
  protected
    procedure DoBehaviorAttach; override;
    procedure DoMouse(const Args: TElementOnMouseEventArgs); override;
    function GetValue: OleVariant; override;
    procedure SetValue(Value: OleVariant); override;
    function GetText: WideString; override;
    procedure SetText(const Value: WideString); override;
  public
    class function BehaviorName: AnsiString; override;
    constructor Create(ASciter: TSciter; AElement: HELEMENT); override;
    destructor Destroy; override;
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

procedure TDemoBehavior.DoMouse(const Args: TElementOnMouseEventArgs);
begin
  if Args.EventType = MOUSE_UP then
  begin
    ShowMessage('Behavior MouseUp event is being handled.');
  end;
end;

procedure TDemoBehavior.OnMethodCallHandler(ASender: TObject; const Args: TElementOnScriptingCallArgs);
var
  sText: WideString;
begin
  if Args.Method = 'nativeValue' then
  begin
    sText := GetValue;
    Args.ReturnValue := sText;
    Args.Handled := True;
  end;
end;

destructor TDemoBehavior.Destroy;
begin

  inherited;
end;

function TDemoBehavior.GetText: WideString;
begin
  Result := FTextArea.Text;
end;

procedure TDemoBehavior.SetText(const Value: WideString);
begin
  FTextArea.Text := Value;
end;

procedure TDemoBehavior.SetValue(Value: OleVariant);
begin
  FTextArea.Value := Value;
end;

initialization
  
  SciterRegisterBehavior(TDemoBehavior);

end.
