//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UEQueryInterfaceCnnTypes;

interface
  uses UCallerTypes;
type
  IEQueryInterfaceCnn=interface
  ['{3BA3829A-E31C-4295-9F05-1ED06E1477C0}']
    procedure ITUpEQueryInterfaceCnn(aCallerAction:ICallerAction; aGuid:TGUID; out aInterface:IDispatch);
    procedure ITUpEQueryInterfaceCnnByLevel(aCallerAction:ICallerAction; aLevel:Integer; const aGuid:TGUID; out aInterface:IDispatch);
    procedure ITUpEQueryInterfaceCnnByNodeName(aCallerAction:ICallerAction; const aNodeName:WideString; aGuid:TGUID; out aInterface:IDispatch);
    procedure ITDnEQueryInterfaceCnn(aCallerAction:ICallerAction; aGuid:TGUID; out aInterface:IDispatch);
    procedure ITDnEQueryInterfaceCnnByLevel(aCallerAction:ICallerAction; aLevel:Integer; const aGuid:TGUID; out aInterface:IDispatch);
    procedure ITDnEQueryInterfaceCnnByNodeName(aCallerAction:ICallerAction; const aNodeName:WideString; aGuid:TGUID; out aInterface:IDispatch);
  end;

implementation

end.
