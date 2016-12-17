//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UEPointPropertiesTypes;

interface
  uses UNodeTypes;
type
  IEPointProperties=interface
  ['{C646997F-0607-4226-9C7D-411B6BC08162}']
    function GetNodeName(aConnectionName:PAnsiString):AnsiString;
    function GetTitlePoint:Ansistring;
    function GetNodeType:TNodeType;
    function GetConfigure(const Value:AnsiString):AnsiString;
    property NodeName[aConnectionName:PAnsiString]:AnsiString read GetNodeName;
    property NodeType:TNodeType read GetNodeType;
    property TitlePoint:AnsiString read GetTitlePoint;
    property Configure[const Value:AnsiString]:AnsiString read GetConfigure;
  end;

implementation

end.
