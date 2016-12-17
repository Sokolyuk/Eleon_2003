unit UServerProcedureTypes;

interface

Type
  PServerProcedureAss=^TServerProcedureAss;
  TServerProcedureAss=record
    RegName:AnsiString;
    GUID:TGUID;
    Machine:AnsiString;
    Method:AnsiString;
    LoadParams:Variant;
    RequireASMServer:Boolean;
    RequireDataCase:Boolean;
    RequireLocalDataBase:Boolean;
  End;

  IServerProcedure=Interface
  ['{09CFDB19-4BEF-4DF3-BDD4-3F33A79563F8}']
    function IT_GetRegName:AnsiString;
    procedure IT_SetRegName(const Value:AnsiString);
    function IT_GetGUID:TGUID;
    procedure IT_SetGUID(Value:TGUID);
    function IT_GetMachine:AnsiString;
    procedure IT_SetMachine(const Value:AnsiString);
    function IT_GetMethod:AnsiString;
    procedure IT_SetMethod(const Value:AnsiString);
    function IT_GetLoadParams:Variant;
    procedure IT_SetLoadParams(const Value:Variant);
    function IT_GetRequireASMServer:Boolean;
    procedure IT_SetRequireASMServer(Value:Boolean);
    function IT_GetRequireDataCase:Boolean;
    procedure IT_SetRequireDataCase(Value:Boolean);
    function IT_GetRequireLocalDataBase:Boolean;
    procedure IT_SetRequireLocalDataBase(Value:Boolean);
    function ITGetAss:TServerProcedureAss;
    procedure ITSetAss(const Value:TServerProcedureAss);
    procedure ITSetAssP(Value:PServerProcedureAss);
    function ITCheckEqualP(Value:PServerProcedureAss):Boolean;
    Property ITRegName:AnsiString read IT_GetRegName write IT_SetRegName;
    Property ITGUID:TGUID read IT_GetGUID write IT_SetGUID;
    Property ITMachine:AnsiString read IT_GetMachine write IT_SetMachine;
    Property ITMethod:AnsiString read IT_GetMethod write IT_SetMethod;
    Property ITLoadParams:Variant read IT_GetLoadParams write IT_SetLoadParams;
    Property ITRequireASMServer:Boolean read IT_GetRequireASMServer write IT_SetRequireASMServer;
    Property ITRequireDataCase:Boolean read IT_GetRequireDataCase write IT_SetRequireDataCase;
    Property ITRequireLocalDataBase:Boolean read IT_GetRequireLocalDataBase write IT_SetRequireLocalDataBase;
  End;

implementation

end.
