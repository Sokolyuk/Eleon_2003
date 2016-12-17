unit ULocalDataDepotTypes;
отказался от этой технологии
interface
  Uses
{$ifndef ESClient} {$ifndef  EAMServer}{$ifndef PegasServer}Неправильные директивы{$endif}{$endif}
       ULocalDataBaseTypes
{$else}
       URegistryDepotTypes
{$endif}
       ;
Type
  ILocalDataDepot=Interface
  ['{3EDD6FE1-BA80-4C3A-948C-46604BE6B260}']
{$ifndef ESClient} {$ifndef  EAMServer}{$ifndef PegasServer}Неправильные директивы{$endif}{$endif}
    Function Get_LocalDataBase:ILocalDataBase;
    Procedure Set_LocalDataBase(Value:ILocalDataBase);
{$else}
    Function Get_RegistryDepot:IRegistryDepot;
    Procedure Set_RegistryDepot(Value:IRegistryDepot);
{$endif}
    Function Get_ConfigRaiseIfNotAssigned:Boolean;
    Procedure Set_ConfigRaiseIfNotAssigned(Value:Boolean);
    //..
    Procedure QueryInterfaceEx(const IID:TGUID; out Obj);
{$ifndef ESClient} {$ifndef  EAMServer}{$ifndef PegasServer}Неправильные директивы{$endif}{$endif}
    Property LocalDataBase:ILocalDataBase read Get_LocalDataBase write Set_LocalDataBase;
{$else}
    Property RegistryDepot:IRegistryDepot read Get_RegistryDepot write Set_RegistryDepot;
{$endif}
    Property ConfigRaiseIfNotAssigned:Boolean read Get_ConfigRaiseIfNotAssigned write Set_ConfigRaiseIfNotAssigned;
  end;

implementation

end.
