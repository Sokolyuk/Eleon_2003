unit UAppMainThreadExecTypes;

interface
  uses UExecMethodTypes;
type
  IAppMainThreadExec=interface
  ['{E7987433-CD14-4759-B440-1DC0B678FC60}']
    procedure AppMainThreadExec(aExecMethod:IExecMethod; aUserData:Pointer);
  end;

implementation

end.
