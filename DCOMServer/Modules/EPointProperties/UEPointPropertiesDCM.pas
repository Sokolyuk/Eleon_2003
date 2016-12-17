unit UEPointPropertiesDCM;

interface
  uses UEPointPropertiesSrv, UTrayInterfaceTypes, UNodeTypes;
type
  TEPointPropertiesDcm=class(TEPointPropertiesSrv)
  public
    function GetNodeName(aConnectionName:PAnsiString):AnsiString;override;
    function GetTitlePoint:Ansistring;override;
    function GetNodeType:TNodeType;override;
  end;

implementation
  uses Sysutils, UMachineNameConsts;

function TEPointPropertiesDcm.GetNodeName(aConnectionName:PAnsiString):AnsiString;
begin
  raise exception.create('GetNodeName unsupport for Dcm.');
end;

function TEPointPropertiesDcm.GetTitlePoint:Ansistring;
begin
  result:='DCM <'+cnMachineName+'>';
end;

function TEPointPropertiesDcm.GetNodeType:TNodeType;
begin
  raise exception.create('GetNodeType unsupport for Dcm.');
end;

end.
