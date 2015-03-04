unit DemoBehavior;

interface

uses
  Sciter, SciterAPI, Windows, Dialogs;

type
  TDemoBehavior = class(TElement)
  private
    FWeight: IElement;
    FWeightEvents: IElementEvents;
    FHeight: IElement;
    FHeightEvents: IElementEvents;
    FBodyIndex: IElement;
    procedure OnMethodCallHandler(ASender: TObject; const Args: TElementOnScriptingCallArgs);
    procedure OnValueChanged(Sender: TObject; const Args: TElementOnControlEventArgs);
    procedure RecalcBMI;
  protected
    procedure DoBehaviorAttach; override;
    procedure DoBehaviorDetach; override;
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

uses
  Variants;

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
  Result := FBodyIndex.Value;
end;

procedure TDemoBehavior.DoBehaviorAttach;
begin
  Attr['style'] := 'border: 1px dotted #666666; background-color: #FFCCCC; padding: 20px';
  InnerHtml :=  '<h4>Calculate your Body Mass Index (BMI)</h4>' +
    '<div>' +
    '<div><label for="txtWeight">Weight (kg): </label><input format="fdigits:0; leading-zero:true;" type="decimal" id="txtWeight" style="width: 100px" min="0" max="200" step="1" value="65.0"/></div>' +
    '<div><label for="txtHeight">Height (cm): </label><input format="fdigits:0; leading-zero:true;" type="decimal" id="txtHeight" style="width: 100px" min="0" max="300" step="1" value="170.0"/></div>' +
    '<div><label for="txtBodyIndex">Body index: </label><input format="fdigits:2; leading-zero:true;" type="decimal" id="txtBodyIndex" style="width: 100px" step="0.1" readonly="readonly" value="0.0" /></div>' +
    '</div>';
  FWeight := Self.Select('#txtWeight');
  FWeightEvents := FWeight as IElementEvents;
  FWeightEvents.OnControlEvent := Self.OnValueChanged;
  FHeight := Self.Select('#txtHeight');
  FHeightEvents := FHeight as IElementEvents;
  FHeightEvents.OnControlEvent := Self.OnValueChanged;
  FBodyIndex := Self.Select('#txtBodyIndex');
  RecalcBMI;
end;

procedure TDemoBehavior.DoMouse(const Args: TElementOnMouseEventArgs);
begin
  
end;

procedure TDemoBehavior.OnMethodCallHandler(ASender: TObject; const Args: TElementOnScriptingCallArgs);
begin

end;

destructor TDemoBehavior.Destroy;
begin
  FWeightEvents := nil;
  FHeightEvents := nil;
  FHeight := nil;
  FWeight := nil;
  inherited;
end;

function TDemoBehavior.GetText: WideString;
begin
  Result := FBodyIndex.Text;
end;

procedure TDemoBehavior.SetText(const Value: WideString);
begin
end;

procedure TDemoBehavior.SetValue(Value: OleVariant);
begin
end;

procedure TDemoBehavior.OnValueChanged(Sender: TObject;
  const Args: TElementOnControlEventArgs);
begin
  if Args.EventType = EDIT_VALUE_CHANGED then
    RecalcBMI;
end;

procedure TDemoBehavior.RecalcBMI;
var
  w: OleVariant;
  h: OleVariant;
begin
  try
    w := FWeight.Value;
    h := FHeight.Value;
    if VarIsNumeric(w) and VarIsNumeric(h) and (h <> 0) then
      FBodyIndex.Value := w / ((h / 100) * (h / 100))
    else
      FBodyIndex.Value := Unassigned;
  except
    FBodyIndex.Value := Unassigned;
  end;
end;

procedure TDemoBehavior.DoBehaviorDetach;
begin
  inherited;
end;

initialization
  
  SciterRegisterBehavior(TDemoBehavior);

end.
