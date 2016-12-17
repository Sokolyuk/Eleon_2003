//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UEPointPropertiesESC;

interface
  uses UEPointProperties, UTrayInterfaceTypes, UEServerConnectionsTypes, UNodeTypes;
type
  TEPointPropertiesESC=class(TEPointProperties)
  protected
    FIsSetCacheDirBf:boolean;
    FCacheDirBf:AnsiString;
    FEServerConnections:IEServerConnections;
    function InternalGetIEServerConnections:IEServerConnections;virtual;
  protected
    function InternalGetInitGUIDCount:Cardinal;override;
    procedure InternalInitGUIDList;override;
  protected
    function GetNodeName(aConnectionName:PAnsiString):AnsiString;override;
    function GetNodeType:TNodeType;override;
  protected
    function InternalGetCacheDirBf:AnsiString;override;
  public
    constructor create;
    destructor destroy;override;
  end;

implementation
  uses UTrayConsts, Sysutils, UNodeNameConsts, UEServerConnectionTypes, Registry, UBfManageESCTypes, UBfConsts;

constructor TEPointPropertiesESC.create;
begin
  inherited create;
  FIsSetCacheDirBf:=false;
end;

destructor TEPointPropertiesESC.destroy;
begin
  inherited destroy;
end;

function TEPointPropertiesESC.InternalGetInitGUIDCount:Cardinal;
begin
  result:=inherited InternalGetInitGUIDCount+1;
end;

procedure TEPointPropertiesESC.InternalInitGUIDList;
  var tmpCount:Cardinal;
begin
  inherited InternalInitGUIDList;
  tmpCount:=inherited InternalGetInitGUIDCount;
  GUIDList^.aList[tmpCount]:=IEServerConnections;
end;

function TEPointPropertiesESC.InternalGetIEServerConnections:IEServerConnections;
begin
  if not assigned(FEServerConnections) then InternalGetITray.Query(IEServerConnections, FEServerConnections);
  result:=FEServerConnections;
end;

function TEPointPropertiesESC.GetNodeName(aConnectionName:PAnsiString):AnsiString;
  var tmpEServerConnection:IEServerConnection;
begin//pegas.node:25.ID:33
  if assigned(aConnectionName) then tmpEServerConnection:=InternalGetIEServerConnections.ViewOfName(aConnectionName^) else
      tmpEServerConnection:=InternalGetIEServerConnections.View;
  if not tmpEServerConnection.Active then raise exception.create('EServerConnection not active.');
  if not tmpEServerConnection.ESCServerInfo.Loaded then tmpEServerConnection.LoadServerInfo;
  Result:=csNodePGS+csNodeDelimiter{.}+csNodeEMS+csValueDelimiter{:}+IntToStr(tmpEServerConnection.ESCServerInfo.NodeId)+csNodeDelimiter+csNodeESC+csValueDelimiter+IntToStr(tmpEServerConnection.ESCServerInfo.AsmId);
end;

function TEPointPropertiesEsc.InternalGetCacheDirBf:AnsiString;
  var tmpRegistry:TRegistry;
      tmpBfManageESC:IBfManageESC;
begin
  if FIsSetCacheDirBf then begin
    result:=FCacheDirBf;
  end else begin
    InternalGetITray.Query(IBfManageESC, tmpBfManageESC);
    tmpRegistry:=TRegistry.create;
    try
      tmpRegistry.RootKey:=tmpBfManageESC.RegRootKey;//HKEY_LOCAL_MACHINE;
      if not tmpRegistry.OpenKey(tmpBfManageESC.RegKeyPath, false) then raise exception.create('Can''t OpenKey='''+tmpBfManageESC.RegKeyPath+'''');
      if tmpRegistry.ValueExists(csRegValueCacheDirBf) then begin
        result:=tmpRegistry.ReadString(csRegValueCacheDirBf);
      end else begin
        result:=InternalGetIAppCacheDir.CacheDir+csBfCacheSubDir;
        tmpRegistry.WriteString(csRegValueCacheDirBf, result);
      end;
    finally
      tmpRegistry.Free;
    end;
    FIsSetCacheDirBf:=true;
  end;
end;

function TEPointPropertiesEsc.GetNodeType:TNodeType;
begin
  result:=nodEsc;
end;

end.
