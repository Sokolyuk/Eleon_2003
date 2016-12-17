//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UServerProcedure;

interface
  Uses UITObject, UServerProcedureTypes, UTypeUtils;
Type
  TServerProcedure=class(TITObject, IServerProcedure)
  private
    FRegName:AnsiString;
    FGUID:TGUID;
    FMachine:AnsiString;
    FMethod:AnsiString;
    FLoadParams:Variant;
    FRequireASMServer:Boolean;
    FRequireDataCase:Boolean;
    FRequireLocalDataBase:Boolean;
  protected
    function IT_GetRegName:AnsiString;virtual;
    procedure IT_SetRegName(const Value:AnsiString);virtual;
    function IT_GetGUID:TGUID;virtual;
    procedure IT_SetGUID(Value:TGUID);virtual;
    function IT_GetMachine:AnsiString;virtual;
    procedure IT_SetMachine(const Value:AnsiString);virtual;
    function IT_GetMethod:AnsiString;virtual;
    procedure IT_SetMethod(const Value:AnsiString);virtual;
    function IT_GetLoadParams:Variant;virtual;
    procedure IT_SetLoadParams(const Value:Variant);virtual;
    function IT_GetRequireASMServer:Boolean;virtual;
    procedure IT_SetRequireASMServer(Value:Boolean);virtual;
    function IT_GetRequireDataCase:Boolean;virtual;
    procedure IT_SetRequireDataCase(Value:Boolean);virtual;
    function IT_GetRequireLocalDataBase:Boolean;virtual;
    procedure IT_SetRequireLocalDataBase(Value:Boolean);virtual;
  public
    constructor Create;
    destructor Destroy; override;
    function ITGetAss:TServerProcedureAss;virtual;
    procedure ITSetAss(const Value:TServerProcedureAss);virtual;
    procedure ITSetAssP(Value:PServerProcedureAss);virtual;
    Property ITRegName:AnsiString read IT_GetRegName write IT_SetRegName;
    function ITCheckEqualP(Value:PServerProcedureAss):Boolean;virtual;
    Property ITGUID:TGUID read IT_GetGUID write IT_SetGUID;
    Property ITMachine:AnsiString read IT_GetMachine write IT_SetMachine;
    Property ITMethod:AnsiString read IT_GetMethod write IT_SetMethod;
    Property ITLoadParams:Variant read IT_GetLoadParams write IT_SetLoadParams;
    Property ITRequireASMServer:Boolean read IT_GetRequireASMServer write IT_SetRequireASMServer;
    Property ITRequireDataCase:Boolean read IT_GetRequireDataCase write IT_SetRequireDataCase;
    Property ITRequireLocalDataBase:Boolean read IT_GetRequireLocalDataBase write IT_SetRequireLocalDataBase;
  end;

implementation
  uses variants;

constructor TServerProcedure.Create;
begin
  FRegName:='';
  FMachine:='';
  FMethod:='';
  FLoadParams:=Unassigned;
  FRequireASMServer:=False;
  FRequireDataCase:=False;
  FRequireLocalDataBase:=False;
  Inherited Create;
end;

destructor TServerProcedure.Destroy;
begin
  FRegName:='';
  FMachine:='';
  FMethod:='';
  FLoadParams:=Unassigned;
  Inherited Destroy;
end;

function TServerProcedure.IT_GetRegName:AnsiString;
begin
  InternalLock;
  try
    Result:=FRegName;
  finally
    InternalUnlock;
  end;
end;

procedure TServerProcedure.IT_SetRegName(const Value:AnsiString);
begin
  InternalLock;
  try
    FRegName:=Value;
  finally
    InternalUnlock;
  end;
end;

function TServerProcedure.IT_GetGUID:TGUID;
begin
  InternalLock;
  try
    Result:=FGUID;
  finally
    InternalUnlock;
  end;
end;

procedure TServerProcedure.IT_SetGUID(Value:TGUID);
begin
  InternalLock;
  try
    FGUID:=Value;
  finally
    InternalUnlock;
  end;
end;

function TServerProcedure.IT_GetMachine:AnsiString;
begin
  InternalLock;
  try
    Result:=FMachine;
  finally
    InternalUnlock;
  end;
end;

procedure TServerProcedure.IT_SetMachine(const Value:AnsiString);
begin
  InternalLock;
  try
    FMachine:=Value;
  finally
    InternalUnlock;
  end;
end;

function TServerProcedure.IT_GetMethod:AnsiString;
begin
  InternalLock;
  try
    Result:=FMethod;
  finally
    InternalUnlock;
  end;
end;

procedure TServerProcedure.IT_SetMethod(const Value:AnsiString);
begin
  InternalLock;
  try
    FMethod:=Value;
  finally
    InternalUnlock;
  end;
end;

function TServerProcedure.IT_GetLoadParams:Variant;
begin
  InternalLock;
  try
    Result:=FLoadParams;
  finally
    InternalUnlock;
  end;
end;

procedure TServerProcedure.IT_SetLoadParams(const Value:Variant);
begin
  InternalLock;
  try
    FLoadParams:=Value;
  finally
    InternalUnlock;
  end;
end;

function TServerProcedure.IT_GetRequireASMServer:Boolean;
begin
  InternalLock;
  try
    Result:=FRequireASMServer;
  finally
    InternalUnlock;
  end;
end;

procedure TServerProcedure.IT_SetRequireASMServer(Value:Boolean);
begin
  InternalLock;
  try
    FRequireASMServer:=Value;
  finally
    InternalUnlock;
  end;
end;

function TServerProcedure.IT_GetRequireDataCase:Boolean;
begin
  InternalLock;
  try
    Result:=FRequireDataCase;
  finally
    InternalUnlock;
  end;
end;

procedure TServerProcedure.IT_SetRequireDataCase(Value:Boolean);
begin
  InternalLock;
  try
    FRequireDataCase:=Value;
  finally
    InternalUnlock;
  end;
end;

function TServerProcedure.IT_GetRequireLocalDataBase:Boolean;
begin
  InternalLock;
  try
    Result:=FRequireLocalDataBase;
  finally
    InternalUnlock;
  end;
end;

procedure TServerProcedure.IT_SetRequireLocalDataBase(Value:Boolean);
begin
  InternalLock;
  try
    FRequireLocalDataBase:=Value;
  finally
    InternalUnlock;
  end;
end;


function TServerProcedure.ITGetAss:TServerProcedureAss;
begin
  InternalLock;
  try
    Result.RegName:=FRegName;
    Result.GUID:=FGUID;
    Result.Machine:=FMachine;
    Result.Method:=FMethod;
    Result.LoadParams:=FLoadParams;
    Result.RequireASMServer:=FRequireASMServer;
    Result.RequireDataCase:=FRequireDataCase;
    Result.RequireLocalDataBase:=FRequireLocalDataBase;
  finally
    InternalUnlock;
  end;
end;

procedure TServerProcedure.ITSetAss(const Value:TServerProcedureAss);
begin
  InternalLock;
  try
    FRegName:=Value.RegName;
    FGUID:=Value.GUID;
    FMachine:=Value.Machine;
    FMethod:=Value.Method;
    FLoadParams:=Value.LoadParams;
    FRequireASMServer:=Value.RequireASMServer;
    FRequireDataCase:=Value.RequireDataCase;
    FRequireLocalDataBase:=Value.RequireLocalDataBase;
  finally
    InternalUnlock;
  end;
end;

procedure TServerProcedure.ITSetAssP(Value:PServerProcedureAss);
begin
  InternalLock;
  try
    FRegName:=Value^.RegName;
    FGUID:=Value^.GUID;
    FMachine:=Value^.Machine;
    FMethod:=Value^.Method;
    FLoadParams:=Value^.LoadParams;
    FRequireASMServer:=Value^.RequireASMServer;
    FRequireDataCase:=Value^.RequireDataCase;
    FRequireLocalDataBase:=Value^.RequireLocalDataBase;
  finally
    InternalUnlock;
  end;
end;

function TServerProcedure.ITCheckEqualP(Value:PServerProcedureAss):Boolean;
begin
  InternalLock;
  try
    Result:=(FRegName=Value^.RegName)And(glGUIDToString(FGUID)=glGUIDToString(Value^.GUID))And(FMachine=Value^.Machine)And(FMethod=Value^.Method)And
    (FRequireASMServer=Value^.RequireASMServer)And(FRequireDataCase=Value^.RequireDataCase)And(FRequireLocalDataBase=Value^.RequireLocalDataBase)And
    (GlVarArrayToString(FLoadParams)=GlVarArrayToString(Value^.LoadParams));
  finally
    InternalUnlock;
  end;
end;

end.
