unit UServerPropertiesTypes;

interface
type
  IServerProperties=interface
  ['{46BDFD4D-B40F-4752-87F5-E4F943112322}']
    procedure Set_ShotDown(Value:Boolean);
    function Get_ShotDown:Boolean;
    function Get_ServerUserName:Ansistring;
    property ServerUserName:AnsiString read Get_ServerUserName;
    property ShotDown:Boolean read Get_ShotDown write Set_ShotDown;
  end;

implementation
end.
