unit DemoBehavior;

interface

uses
  Sciter, SysUtils, Classes, SciterAPI, Windows, Dialogs;

type
  TDemoBehavior = class(TElement)
  private
    FBodyIndex: IElement;
    FHeight: IElement;
    FHeightEvents: IElementEvents;
    FWeight: IElement;
    FWeightEvents: IElementEvents;
    procedure RecalcBMI;
  protected
    procedure DoBehaviorAttach(const Args: TElementOnBehaviorEventArgs); override;
    procedure DoBehaviorDetach(const Args: TElementOnBehaviorEventArgs); override;
    procedure DoControlEvents(const Args: TElementOnControlEventArgs); override;
    function GetText: WideString; override;
    function GetValue: OleVariant; override;
    procedure SetText(const Value: WideString); override;
    procedure SetValue(Value: OleVariant); override;
  public
    destructor Destroy; override;
    class function BehaviorName: AnsiString; override;
  end;

  TEventFilterBehavior = class(TElement)
  protected
    procedure DoBehaviorAttach(const Args: TElementOnBehaviorEventArgs); override;
    function QuerySubscriptionEvents: EVENT_GROUPS; override;
    procedure DoFocus(const Args: TElementOnFocusEventArgs); override;
    procedure DoMouse(const Args: TElementOnMouseEventArgs); override;
  public
    class function BehaviorName: AnsiString; override;
  end;

implementation

uses
  Variants;

destructor TDemoBehavior.Destroy;
begin
  FWeightEvents := nil;
  FHeightEvents := nil;
  FHeight := nil;
  FWeight := nil;
  inherited;
end;

{ TDemoBehavior }

class function TDemoBehavior.BehaviorName: AnsiString;
begin
  Result := 'DemoBehavior';
end;

procedure TDemoBehavior.DoBehaviorAttach(const Args: TElementOnBehaviorEventArgs);
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
  FHeight := Self.Select('#txtHeight');
  FHeightEvents := FHeight as IElementEvents;
  FBodyIndex := Self.Select('#txtBodyIndex');
  RecalcBMI;
  Args.Handled := True;
end;

procedure TDemoBehavior.DoBehaviorDetach(const Args: TElementOnBehaviorEventArgs);
begin
  inherited;
end;

procedure TDemoBehavior.DoControlEvents(const Args: TElementOnControlEventArgs);
begin
  if Args.EventType = EDIT_VALUE_CHANGED then
    RecalcBMI;
  inherited;
end;

function TDemoBehavior.GetText: WideString;
begin
  Result := FBodyIndex.Text;
end;

function TDemoBehavior.GetValue: OleVariant;
begin
  Result := FBodyIndex.Value;
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
    on E:Exception do
    begin
      FBodyIndex.Value := Unassigned;
      ThrowError(Sciter.VM, E.Message);
    end;
  end;
end;

procedure TDemoBehavior.SetText(const Value: WideString);
begin
end;

procedure TDemoBehavior.SetValue(Value: OleVariant);
begin
end;

{ TEventFilterBehavior }

class function TEventFilterBehavior.BehaviorName: AnsiString;
begin
  Result := 'EventFilter';
end;

procedure TEventFilterBehavior.DoBehaviorAttach(
  const Args: TElementOnBehaviorEventArgs);
begin
  inherited;
  Args.Element.Text := 'This behavior handles focus events and ignores mouse events';
end;

procedure TEventFilterBehavior.DoFocus(
  const Args: TElementOnFocusEventArgs);
begin
  inherited;
  if Args.EventType = GOT_FOCUS then
    Args.Element.Text := 'GOT FOCUS'
  else
    Args.Element.Text := 'LOST_FOCUS';
end;

procedure TEventFilterBehavior.DoMouse(const Args: TElementOnMouseEventArgs);
begin
  Args.Element.Text := Format('OnMouseEvent %d:%d', [Args.X, Args.Y]);
end;

function TEventFilterBehavior.QuerySubscriptionEvents: EVENT_GROUPS;
begin
  Result := HANDLE_FOCUS;
end;

initialization
  
  SciterRegisterBehavior(TDemoBehavior);
  SciterRegisterBehavior(TEventFilterBehavior);

end.
