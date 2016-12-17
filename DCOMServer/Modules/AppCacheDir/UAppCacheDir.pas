//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UAppCacheDir;

interface
  uses UTrayInterface, UAppCacheDirTypes;
type
  TAppCacheDir=class(TTrayInterface, IAppCacheDir)
  protected
    FCacheDir:AnsiString;
    FCacheDirExists:boolean;
    FCacheDirAutoCreate:boolean;
  protected
    Function Get_CacheDir:AnsiString;virtual;
    Procedure Set_CacheDir(Value:AnsiString);virtual;
    Function Get_CacheDirExists:boolean;virtual;
    Function Get_CacheDirAutoCreate:boolean;virtual;
    Procedure Set_CacheDirAutoCreate(Const Value:boolean);virtual;
  public
    constructor create;overload;
    constructor create(const aAppCacheDir:AnsiString);overload;
    constructor create(const aAppCacheDir:AnsiString; aCacheDirAutoCreate:Boolean);overload;
    destructor destroy;override;
    Property CacheDir:AnsiString read Get_CacheDir write Set_CacheDir;
    property CacheDirExists:boolean read Get_CacheDirExists;
    property CacheDirAutoCreate:boolean read Get_CacheDirAutoCreate write Set_CacheDirAutoCreate;
  end;

implementation
  uses SysUtils{$IFDEF VER130}, FileCtrl{$ENDIF};

constructor TAppCacheDir.create;
begin
  inherited create;
  FCacheDirExists:=true;
  FCacheDirAutoCreate:=false;
  CacheDir:='Cache';
end;

constructor TAppCacheDir.create(const aAppCacheDir:AnsiString);
begin
  inherited Create;
  FCacheDirExists:=true;
  FCacheDirAutoCreate:=false;
  CacheDir:=aAppCacheDir;
end;

constructor TAppCacheDir.create(const aAppCacheDir:AnsiString; aCacheDirAutoCreate:Boolean);
begin
  inherited Create;
  FCacheDirExists:=true;
  FCacheDirAutoCreate:=aCacheDirAutoCreate;
  CacheDir:=aAppCacheDir;
end;

destructor TAppCacheDir.destroy;
begin
  FCacheDir:='';
  inherited destroy;
end;

Function TAppCacheDir.Get_CacheDir:AnsiString;
begin
  internalLock;
  try
    result:=FCacheDir;
  finally
    InternalUnlock;
  end;
end;

Procedure TAppCacheDir.Set_CacheDir(Value:AnsiString);
begin
  internalLock;
  try
    if Value<>FCacheDir then begin
      if (Value<>'')and(Value[Length(Value)]<>'\') Then Value:=Value+'\';
      if Value='' then begin
        FCacheDirExists:=true;
      end else begin
        try
          FCacheDirExists:=DirectoryExists(Value);
        except
          FCacheDirExists:=false;
        end;
        if (FCacheDirAutoCreate)and(not FCacheDirExists)then begin
          if not ForceDirectories(value) then raise exception.create('Can''t create folder '''+value+'''.');
          FCacheDirExists:=true;
        end;
      end;
      FCacheDir:=Value;
    end;
  finally
    InternalUnlock;
  end;
end;

Function TAppCacheDir.Get_CacheDirAutoCreate:boolean;
begin
  internalLock;
  try
    result:=FCacheDirAutoCreate;
  finally
    InternalUnlock;
  end;
end;

Procedure TAppCacheDir.Set_CacheDirAutoCreate(Const Value:boolean);
begin
  internalLock;
  try
    FCacheDirAutoCreate:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TAppCacheDir.Get_CacheDirExists:boolean;
begin
  internalLock;
  try
    result:=FCacheDirExists;
  finally
    InternalUnlock;
  end;
end;

end.
