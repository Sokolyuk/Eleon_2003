unit UAppCacheDirFromReg;
не нужен
interface
  uses UAppCacheDir;
type
  TAppCacheDirFromReg=class(TAppCacheDir)
  protected
    procedure InternalInit;override;
    function InternalGetInitGUIDCount:cardinal;override;
    procedure InternalInitGUIDList;override;
  public
    constructor create;overload;
  end;

implementation
  uses UAppConfigRegPathConsts, Registry, windows;

constructor TAppCacheDirFromReg.create;
  Var tmpReg:TRegistry;
begin
  inherited create;
  tmpReg:=TRegistry.Create(KEY_READ);
  try
    tmpReg.RootKey:=HKEY_LOCAL_MACHINE;
    if tmpReg.OpenKey(cnAppConfigRegPath, false) then begin
      CacheDir:=tmpReg.ReadString('CacheDir');
    end;
  finally
    tmpReg.Free;
  end;
end;

procedure TAppCacheDirFromReg.InternalInit;
begin
  inherited InternalInit;
end;

function TAppCacheDirFromReg.InternalGetInitGUIDCount:Cardinal;
begin
  result:=inherited InternalGetInitGUIDCount{+?};
end;

procedure TAppCacheDirFromReg.InternalInitGUIDList;
  //var tmpCount:Cardinal;
begin
  inherited InternalInitGUIDList;
  //tmpCount:=inherited InternalGetInitGUIDCount;
  //GUIDList^.aList[tmpCount]:=I?;
end;

end.
