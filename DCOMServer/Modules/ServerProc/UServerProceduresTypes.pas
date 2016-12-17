unit UServerProceduresTypes;

interface
  Uses UServerProcedureTypes;
Type
  IServerProcedures=Interface
  ['{8256E4E6-73F3-4756-9E7C-030ECC361AC6}']
    function ITRegNameToServerProcedureAss(const aRegName:AnsiString):TServerProcedureAss;
    procedure ITReload;
  End;

implementation

end.
