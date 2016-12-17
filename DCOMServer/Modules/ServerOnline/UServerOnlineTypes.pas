//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UServerOnlineTypes;

interface
  uses UCallerTypes;
type
  TOnLineMode=(olmAuto, olmManual);
  IServerOnline=interface
  ['{B59FD96A-6211-4FF9-B8D0-A247F802E7A8}']
    Function ITGetOnLineStatus:Boolean;
    procedure ITSetOnLineStatus(Value:Boolean; aCallerAction:ICallerAction);
    Property ITOnLineStatus:Boolean read ITGetOnLineStatus;
    Function ITGetOnLineMode:TOnLineMode;
    Procedure ITSetOnLineMode(Value:TOnLineMode);
    Property ITOnLineMode:TOnLineMode read ITGetOnLineMode write ITSetOnLineMode;
  end;

implementation

end.
