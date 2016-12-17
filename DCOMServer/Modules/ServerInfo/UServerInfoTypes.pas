//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UServerInfoTypes;

interface
type
  TPartOfInfo=(poiServerAbout{0}, poiASM{1}, poiNode{2}, poiAccess{3}, poiMessageStatistic{4}, poiCacheDir{5}, poiOnLine{6});
  IServerInfo=interface
  ['{62969DDE-9899-4EB8-A2E5-CA3137F01E59}']
    Function Get_ServerADMGroupName:AnsiString;
    Procedure Set_ServerADMGroupName(const value:AnsiString);
    Function Get_ServerSecurityContext:Variant;
    Procedure Set_ServerSecurityContext(const value:Variant);
    Function ServerInfo(aPartOfInfo:TPartOfInfo):Variant;
    property ServerADMGroupName:AnsiString read Get_ServerADMGroupName write Set_ServerADMGroupName;
    property ServerSecurityContext:Variant read Get_ServerSecurityContext write Set_ServerSecurityContext;
  end;

implementation

end.
