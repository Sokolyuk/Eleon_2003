unit UAppCacheDirTypes;

interface
type
  IAppCacheDir=interface
  ['{7A1FB422-6D28-4A96-AFFD-1DDF91267E03}']
    Function Get_CacheDir:AnsiString;
    Procedure Set_CacheDir(Value:AnsiString);
    Function Get_CacheDirAutoCreate:boolean;
    Procedure Set_CacheDirAutoCreate(Const Value:boolean);
    Function Get_CacheDirExists:boolean;
    Property CacheDir:AnsiString read Get_CacheDir write Set_CacheDir;
    property CacheDirExists:boolean read Get_CacheDirExists;
    property CacheDirAutoCreate:boolean read Get_CacheDirAutoCreate write Set_CacheDirAutoCreate;
  end;

implementation

end.
