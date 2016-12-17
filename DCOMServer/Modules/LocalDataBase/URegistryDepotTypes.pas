unit URegistryDepotTypes;
отказался от этой технологии
interface
  Uses Windows, Registry;
Type
  IRegistryDepot=Interface
  ['{9C01614A-550E-40B3-A58C-61E3D7CA7F34}']
    //Function Get_CacheRegkey:AnsiString;
    //Procedure Set_CacheRegkey(Const Value:AnsiString);
    Function Get_RootKey:HKEY;
    Procedure Set_RootKey(Value:HKEY);
    Function Get_Registry:TRegistry;
    //..
    //Property CacheRegkey:AnsiString read Get_CacheRegkey write Set_CacheRegkey;
    Property RootKey:HKEY read Get_RootKey write Set_RootKey;
    Property Registry:TRegistry read Get_Registry;
  End;

implementation

end.
