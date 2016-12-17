unit IdBaseComponentV5;

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
  IdGlobalV5;

function TIdBaseComponent.GetVersion: string;
begin
  Result := gsIdVersion;
end;

end.
