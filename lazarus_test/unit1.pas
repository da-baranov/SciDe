unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Sciter;

type

  { TForm1 }

  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
    FSciter: TSciter;
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  FSciter := TSciter.Create(Self);
  FSciter.Parent := Self;
  FSciter.HandleNeeded;
  FSciter.Visible := true;
  FSciter.Align := alClient;
  //FSciter.LoadURL('http://www.ya.ru');
end;

end.

