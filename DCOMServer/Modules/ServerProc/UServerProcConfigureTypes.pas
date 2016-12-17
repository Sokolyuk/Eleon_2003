//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UServerProcConfigureTypes;

interface
  uses UCallerTypes, UTrayTypes;
type
  IServerProcConfigure=interface
  ['{27C98FDF-53CE-4C7E-BE19-B82D27988B39}']
    function GetVersion:Integer;
    procedure SetCallerAction(const aCallerAction:ICallerAction);
    procedure SetTray(const aTray:ITray);
    procedure SetLoadParams(const aLoadParams:Variant);
  end;

implementation

end.
