unit UEQueryInterfaceTray;

interface
  uses UITObject, UEQueryInterfaceTrayTypes;
type
  TEQueryInterfaceTray=class(TITObject, IEQueryInterfaceTray)
  public
    function EQueryInterface(const aSecurityContext:Variant; const aGuid:TGuid):IDispatch;virtual;
    function EQueryInterfaceByLevel(const aSecurityContext:Variant; aLevel:Integer; const aGuid:TGuid):IDispatch;virtual;
    function EQueryInterfaceByNodeName(const aSecurityContext:Variant; const aNodeName:AnsiString; const aGuid:TGuid):IDispatch;virtual;
  end;

implementation
  uses UEQueryInterfaceUtils;

function TEQueryInterfaceTray.EQueryInterface(const aSecurityContext:Variant; const aGuid:TGuid):IDispatch;
begin
  result:=UEQueryInterfaceUtils.EQueryInterface(aSecurityContext, aGuid);
end;

function TEQueryInterfaceTray.EQueryInterfaceByLevel(const aSecurityContext:Variant; aLevel:Integer; const aGuid:TGuid):IDispatch;
begin
  result:=UEQueryInterfaceUtils.EQueryInterfaceByLevel(aSecurityContext, aLevel, aGuid);
end;

function TEQueryInterfaceTray.EQueryInterfaceByNodeName(const aSecurityContext:Variant; const aNodeName:AnsiString; const aGuid:TGuid):IDispatch;
begin
  result:=UEQueryInterfaceUtils.EQueryInterfaceByNodeName(aSecurityContext, aNodeName, aGuid);
end;

end.
