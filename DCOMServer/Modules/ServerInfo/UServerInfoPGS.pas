unit UServerInfoPGS;

interface
  uses UServerInfo;
type
  TServerInfoPGS=class(TServerInfo)
  protected
    function InternalGet_poiNode:Variant;override;
    function InternalGet_poiAccess:Variant;override;
  end;

implementation
  uses Sysutils, Variants;
  
function TServerInfoPGS.InternalGet_poiNode:Variant;
begin
  result:=unassigned;
  Raise Exception.Create('���������� ��������� ������ �� ������� poiNode.');
end;

function TServerInfoPGS.InternalGet_poiAccess:Variant;
begin
  result:=unassigned;
  Raise Exception.Create('���������� ��������� ������ �� ������� poiAccess.');
end;

end.

