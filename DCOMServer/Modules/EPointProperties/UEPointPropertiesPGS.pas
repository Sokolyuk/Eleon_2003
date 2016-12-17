//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UEPointPropertiesPGS;

interface
  uses UEPointPropertiesSrv, UNodeTypes;
type
  TEPointPropertiesPGS=class(TEPointPropertiesSrv)
  protected
    function GetNodeName(aConnectionName:PAnsiString):AnsiString;override;
    function GetTitlePoint:Ansistring;override;
    function GetNodeType:TNodeType;override;
  end;

implementation
  uses UNodeNameConsts, UMachineNameConsts;

function TEPointPropertiesPGS.GetNodeName(aConnectionName:PAnsiString):AnsiString;
begin//pegas
  result:=csNodePGS;
end;

function TEPointPropertiesPGS.GetTitlePoint:Ansistring;
begin
  result:='PGS <'+cnMachineName+'>';
end;

function TEPointPropertiesPgs.GetNodeType:TNodeType;
begin
  result:=nodPgs;
end;

end.
