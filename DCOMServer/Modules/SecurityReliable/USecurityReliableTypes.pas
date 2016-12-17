unit USecurityReliableTypes;

interface
type
  ISecurityReliable=interface
  ['{6CB18829-6610-43DD-B5CE-DA0AA6E2679D}']
    function Add(const aData:AnsiString):integer;
    function Del(aId:Integer):boolean;
    function Check(aId:Integer; const aData:AnsiString):boolean;
  end;

implementation

end.
