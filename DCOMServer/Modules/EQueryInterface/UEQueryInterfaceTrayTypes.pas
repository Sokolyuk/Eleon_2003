unit UEQueryInterfaceTrayTypes;

interface
type
  IEQueryInterfaceTray=interface
  ['{B83F9D7A-C7F5-4355-B736-2D5DDE4E49A8}']
    function EQueryInterface(const aSecurityContext:Variant; const aGuid:TGuid):IDispatch;
    function EQueryInterfaceByLevel(const aSecurityContext:Variant; aLevel:Integer; const aGuid:TGuid):IDispatch;
    function EQueryInterfaceByNodeName(const aSecurityContext:Variant; const aNodeName:AnsiString; const aGuid:TGuid):IDispatch;
  end;

implementation

end.
