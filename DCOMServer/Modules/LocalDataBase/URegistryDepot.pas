unit URegistryDepot;
отказался от этой технологии
interface
  Uses URegistryDepotTypes, UIObject, Registry, Windows;
Type
  TRegistryDepot=class(TIObject, IRegistryDepot)
  private
    FRegistry:TRegistry;
  protected
    Function Get_RootKey:HKEY;
    Procedure Set_RootKey(Value:HKEY);
    Function Get_Registry:TRegistry;
  public
    constructor Create;
    destructor Destroy; override;
    //..
    Property RootKey:HKEY read Get_RootKey write Set_RootKey;
    Property Registry:TRegistry read Get_Registry;
  end;

implementation
  Uses Sysutils;
constructor TRegistryDepot.Create;
begin
  Inherited Create;
  FRegistry:=TRegistry.Create(KEY_ALL_ACCESS);
  If Assigned(GL_DataCase) Then begin
    FRegistry.Rootkey:=GL_DataCase.RegistryDepotRootKey;
  end else begin
    FRegistry.Rootkey:=HKEY_LOCAL_MACHINE;
  end;
end;

destructor TRegistryDepot.Destroy;
begin
  FreeAndNil(FRegistry);
  Inherited Destroy;
end;

Function TRegistryDepot.Get_RootKey:HKEY;
begin
  Result:=FRegistry.RootKey;
end;
 
Procedure TRegistryDepot.Set_RootKey(Value:HKEY);
begin
  FRegistry.RootKey:=Value;
end;

Function TRegistryDepot.Get_Registry:TRegistry;
begin
  Result:=FRegistry;
end;
  
end.
