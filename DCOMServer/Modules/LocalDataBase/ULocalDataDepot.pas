unit ULocalDataDepot;
отказался от этой технологии
interface
  Uses UIObject, ULocalDataDepotTypes
{$ifdef ESClient}
       , URegistryDepotTypes
{$else} {$ifndef  EAMServer}{$ifndef PegasServer}Неправильные директивы{$endif}{$endif}
       , ULocalDataBaseTypes
{$endif}
       ;
Type
  TLocalDataDepot=class(TIObject, ILocalDataDepot)
  private
{$ifdef ESClient}
    FRegistryDepot:IRegistryDepot;
{$else} {$ifndef  EAMServer}{$ifndef PegasServer}Неправильные директивы{$endif}{$endif}
    FLocalDataBase:ILocalDataBase;
{$endif}
    FConfigRaiseIfNotAssigned:Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    //..
{$ifdef ESClient}
    Function Get_RegistryDepot:IRegistryDepot;
    Procedure Set_RegistryDepot(Value:IRegistryDepot);
{$else} {$ifndef  EAMServer}{$ifndef PegasServer}Неправильные директивы{$endif}{$endif}
    Function Get_LocalDataBase:ILocalDataBase;
    Procedure Set_LocalDataBase(Value:ILocalDataBase);
{$endif}
    Function Get_ConfigRaiseIfNotAssigned:Boolean;
    Procedure Set_ConfigRaiseIfNotAssigned(Value:Boolean);
    //..
    Procedure QueryInterfaceEx(const IID:TGUID; out Obj);
{$ifdef ESClient}
    Property RegistryDepot:IRegistryDepot read Get_RegistryDepot write Set_RegistryDepot;
{$else} {$ifndef  EAMServer}{$ifndef PegasServer}Неправильные директивы{$endif}{$endif}
    Property LocalDataBase:ILocalDataBase read Get_LocalDataBase write Set_LocalDataBase;
{$endif}
    Property ConfigRaiseIfNotAssigned:Boolean read Get_ConfigRaiseIfNotAssigned write Set_ConfigRaiseIfNotAssigned;
  end;

implementation
  Uses Sysutils
{$IFDEF VER130}
  { Borland Delphi 5.0 }
       , Windows, Comobj
{$ENDIF}
       ;
constructor TLocalDataDepot.Create;
begin
  Inherited Create;
{$ifdef ESClient}
  FRegistryDepot:=Nil;
{$else} {$ifndef  EAMServer}{$ifndef PegasServer}Неправильные директивы{$endif}{$endif}
  FLocalDataBase:=Nil;
{$endif}
  FConfigRaiseIfNotAssigned:=True;
end;

destructor TLocalDataDepot.Destroy;
begin
{$ifdef ESClient}
  FRegistryDepot:=Nil;
{$else} {$ifndef  EAMServer}{$ifndef PegasServer}Неправильные директивы{$endif}{$endif}
  FLocalDataBase:=Nil;
{$endif}
  Inherited Destroy;
end;

Function TLocalDataDepot.Get_ConfigRaiseIfNotAssigned:Boolean;
begin
  Result:=FConfigRaiseIfNotAssigned;
end;

Procedure TLocalDataDepot.Set_ConfigRaiseIfNotAssigned(Value:Boolean);
begin
  FConfigRaiseIfNotAssigned:=Value;
end;

{$ifdef ESClient}
Function TLocalDataDepot.Get_RegistryDepot:IRegistryDepot;
begin
  Result:=FRegistryDepot;
  If Not Assigned(Result) Then Raise Exception.Create('RegistryDepot is not assigned.');
end;

Procedure TLocalDataDepot.Set_RegistryDepot(Value:IRegistryDepot);
begin
  FRegistryDepot:=Value;
end;
{$else} {$ifndef  EAMServer}{$ifndef PegasServer}Неправильные директивы{$endif}{$endif}
Function TLocalDataDepot.Get_LocalDataBase:ILocalDataBase;
begin
  Result:=FLocalDataBase;
  If (FConfigRaiseIfNotAssigned)And(Not Assigned(Result)) Then Raise Exception.Create('LocalDataBase is not assigned.');
end;

Procedure TLocalDataDepot.Set_LocalDataBase(Value:ILocalDataBase);
begin
  FLocalDataBase:=Value;
end;
{$endif}
Procedure TLocalDataDepot.QueryInterfaceEx(const IID:TGUID; out Obj);
begin
  If (QueryInterface(IID, Obj)<>S_OK)Or(Not Assigned(Pointer(Obj))) Then Raise Exception.Create('Interface '''+GUIDToString(IID)+''' not found.');
end;

end.
