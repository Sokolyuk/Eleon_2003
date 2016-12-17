unit UEPointPropertiesEMS;

interface
  uses UEPointPropertiesSrv, UTrayInterfaceTypes, UNodeInfoTypes, UNodeTypes;
type
  TEPointPropertiesEms=class(TEPointPropertiesSrv)
  protected
    FNodeInfo:INodeInfo;
    function InternalGetINodeInfo:INodeInfo;
  protected
    function InternalGetInitGUIDCount:Cardinal;override;
    procedure InternalInitGUIDList;override;
  public
    function GetNodeName(aConnectionName:PAnsiString):AnsiString;override;
    function GetTitlePoint:Ansistring;override;
    function GetNodeType:TNodeType;override;
  end;

implementation
  uses UTrayConsts, Sysutils, UMachineNameConsts, UNodeNameConsts;

function TEPointPropertiesEMS.InternalGetInitGUIDCount:Cardinal;
begin
  result:=inherited InternalGetInitGUIDCount+1;
end;

procedure TEPointPropertiesEMS.InternalInitGUIDList;
  var tmpCount:Cardinal;
begin
  inherited InternalInitGUIDList;
  tmpCount:=inherited InternalGetInitGUIDCount;
  GUIDList^.aList[tmpCount]:=INodeInfo;
end;

function TEPointPropertiesEMS.GetNodeName(aConnectionName:PAnsiString):AnsiString;
begin//pegas.node:25
  Result:=csNodePGS+csNodeDelimiter+csNodeEMS+csValueDelimiter+IntToStr(InternalGetINodeInfo.ID);
end;

function TEPointPropertiesEMS.InternalGetINodeInfo:INodeInfo;
begin
  if not assigned(FNodeInfo) then cnTray.Query(INodeInfo, FNodeInfo);
  result:=FNodeInfo;
end;

function TEPointPropertiesEMS.GetTitlePoint:Ansistring;
begin
  result:='EMS <'+cnMachineName+'>';
end;

function TEPointPropertiesEMS.GetNodeType:TNodeType;
begin
  result:=nodEms;
end;

end.
