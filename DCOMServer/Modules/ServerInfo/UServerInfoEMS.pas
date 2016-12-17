//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UServerInfoEMS;

interface
  uses UServerInfo, UNodeInfoTypes;
type
  TServerInfoEMS=class(TServerInfo)
  protected
    FNodeInfo:INodeInfo;
    function InternalGetINodeInfo:INodeInfo;
  protected
    function InternalGetInitGUIDCount:Cardinal;override;
    procedure InternalInitGUIDList;override;
  protected
    function InternalGet_poiNode:Variant;override;
    function InternalGet_poiAccess:Variant;override;
  end;

implementation
  uses Sysutils, UTrayConsts, variants, UServerConsts;

function TServerInfoEMS.InternalGetInitGUIDCount:Cardinal;
begin
  result:=inherited InternalGetInitGUIDCount+1;
end;

procedure TServerInfoEMS.InternalInitGUIDList;
  var tmpCount:Cardinal;
begin
  inherited InternalInitGUIDList;
  tmpCount:=inherited InternalGetInitGUIDCount;
  GUIDList^.aList[tmpCount]:=INodeInfo;
end;

function TServerInfoEMS.InternalGetINodeInfo:INodeInfo;
begin
  if not assigned(FNodeInfo) then cnTray.Query(INodeInfo, FNodeInfo);
  result:=FNodeInfo;
end;

function TServerInfoEMS.InternalGet_poiNode:variant;
begin
  with InternalGetINodeInfo do Result:=VarArrayOf([{0}ID, {1}Name, {2}SName, {3}Address, {4}Phone, {5}Commentary, {6}CardLetter]);
end;

function TServerInfoEMS.InternalGet_poiAccess:variant;
begin
  with InternalGetINodeInfo do Result:=VarArrayOf([{0}ID, {1}ServerIDBor1a, {2}unassigned{CNNBor1a}, {3}cnLocalDataType, {4}unassigned{BaseIDDK}, {5}unassigned{NumDK}]);
end;

end.
