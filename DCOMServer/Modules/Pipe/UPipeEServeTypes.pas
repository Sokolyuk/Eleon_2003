unit UPipeEServeTypes;

interface
  uses UCallerTypes, UServerProceduresTypes;
type
  IENamedPipe=interface
  ['{A714567B-9C09-48AF-B116-6397B1FFDF1D}']
    function GetCallerAction:ICallerAction;
    function GetStartTime:TDateTime;
    procedure SetStartTime(Value:TDateTime);
    function GetServerProcedures:IServerProcedures;
    property CallerAction:ICallerAction read GetCallerAction;
    property StartTime:TDateTime read GetStartTime write SetStartTime;
    property ServerProcedures:IServerProcedures read GetServerProcedures;
  end;

implementation

end.
