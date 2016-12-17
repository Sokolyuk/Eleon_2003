unit IdBaseComponent__;

interface

uses
  Classes;

type
  TIdBaseComponent = class(TComponent)
  public
    function GetVersion: string;
    property Version: string read GetVersion;
  published
  end;

implementation

uses
  IdGlobal__;

function TIdBaseComponent.GetVersion: string;
begin
  Result := gsIdVersion;
end;

end.
