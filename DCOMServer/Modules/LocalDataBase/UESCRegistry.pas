unit UESCRegistry;

interface
  uses UIObject, UESCRegistryTypes, Registry;
type
  TESCRegistry=class(TIObject, IESCRegistry)
  protected
    FRegistry:TRegistry;
  protected
    function Get_Registry:TRegistry;virtual;
  public
    constructor create;
    destructor destroy;override;
  public
    property ESCRegistry:TRegistry read Get_Registry;
  end;

implementation
  uses Sysutils, windows;

constructor TESCRegistry.create;
begin
  inherited create;
  FRegistry:=TRegistry.create(KEY_ALL_ACCESS);
end;

destructor TESCRegistry.destroy;
begin
  FreeAndNil(FRegistry);
  inherited destroy;
end;

function TESCRegistry.Get_Registry:TRegistry;
begin
  result:=FRegistry;
end;

end.
