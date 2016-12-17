unit UEPointPropertiesSrv;

interface
  uses UEPointProperties;
type
  TEPointPropertiesSrv=class(TEPointProperties)
  protected
    function InternalGetCacheDirBf:AnsiString;override;
  end;

implementation
  uses Sysutils, UEPointConfigureConsts, Registry, Windows, UAppConfigRegPathConsts, UBfConsts;

function TEPointPropertiesSrv.InternalGetCacheDirBf:AnsiString;
  var tmpRegistry:TRegistry;
begin
  tmpRegistry:=TRegistry.create;
  try
    tmpRegistry.RootKey:=HKEY_LOCAL_MACHINE;
    if not tmpRegistry.OpenKey(cnAppConfigRegPath, false) then raise exception.create('Can''t OpenKey='''+cnAppConfigRegPath+'''');
    if tmpRegistry.ValueExists(csRegValueCacheDirBf) then begin
      result:=tmpRegistry.ReadString(csRegValueCacheDirBf);
    end else begin
      result:=InternalGetIAppCacheDir.CacheDir+csBfCacheSubDir;
      tmpRegistry.WriteString(csRegValueCacheDirBf, result);
    end;
  finally
    tmpRegistry.Free;
  end;
end;

end.
