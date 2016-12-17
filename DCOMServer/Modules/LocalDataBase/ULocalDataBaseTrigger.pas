//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit ULocalDataBaseTrigger;

interface
  Uses UITObject, ULocalDataBaseTriggerTypes, USQLParserTypes;
Type
  TLocalDataBaseTrigger=Class(TITObject, ILocalDataBaseTrigger)
  private
    FTypes:TSetTriggerType;
    FSQLCommands:TSetSQLCommandType;
    FTables:AnsiString;
    FServerProcRegNames:AnsiString;
    FServerProcParam:Variant;
  protected
    Function InternalCheckInclude(aTriggerType:TTriggerType; aSQLCommandType:TSQLCommandType; Const aTable:AnsiString):Boolean;
    Function IT_GetTypes:TSetTriggerType;
    Procedure IT_SetTypes(Value:TSetTriggerType);
    Function IT_GetTables:AnsiString;
    Procedure IT_SetTables(Const Value:AnsiString);
    Function IT_GetSQLCommands:TSetSQLCommandType;
    Procedure IT_SetSQLCommands(Value:TSetSQLCommandType);
    Function IT_GetServerProcRegNames:AnsiString;
    Procedure IT_SetServerProcRegNames(Const Value:AnsiString);
    Function IT_GetServerProcParam:Variant;
    Procedure IT_SetServerProcParam(Const Value:Variant);
  public
    constructor Create;
    destructor Destroy; override;
    Function ITCheckInclude(aTriggerType:TTriggerType; aSQLCommandType:TSQLCommandType; Const aTable:AnsiString):Boolean;
    Function ITCheckEqual(Const aServerProcRegNames:AnsiString; Const aServerProcParam:Variant; Const aTables:AnsiString; aTriggerTypes:TSetTriggerType; aSQLCommands:TSetSQLCommandType):Boolean;
    Function ITGetTriggerRegNames(aTriggerType:TTriggerType; aSQLCommandType:TSQLCommandType; Const aTable:AnsiString):AnsiString;
    Property ITServerProcRegNames:AnsiString read IT_GetServerProcRegNames write IT_SetServerProcRegNames;
    Property ITTypes:TSetTriggerType read IT_GetTypes write IT_SetTypes;
    Property ITTables:AnsiString read IT_GetTables write IT_SetTables;
    Property ITSQLCommands:TSetSQLCommandType read IT_GetSQLCommands write IT_SetSQLCommands;
    Property ITServerProcParam:Variant read IT_GetServerProcParam write IT_SetServerProcParam;
  end;

implementation
  Uses UStringUtils, UTypeUtils, Variants;
constructor TLocalDataBaseTrigger.Create;
begin
  FTypes:=[];
  FTables:='';
  FServerProcRegNames:='';
  FServerProcParam:=Unassigned;
  FSQLCommands:=[];
  Inherited Create;
end;

destructor TLocalDataBaseTrigger.Destroy;
begin
  FTables:='';
  FServerProcRegNames:='';
  FServerProcParam:=Unassigned;
  Inherited Destroy;
end;

Function TLocalDataBaseTrigger.IT_GetTypes:TSetTriggerType;
begin
  InternalLock;
  try
    Result:=FTypes;
  finally
    InternalUnlock;
  end;
end;

Procedure TLocalDataBaseTrigger.IT_SetTypes(Value:TSetTriggerType);
begin
  InternalLock;
  try
    FTypes:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TLocalDataBaseTrigger.IT_GetTables:AnsiString;
begin
  InternalLock;
  try
    Result:=FTables;
  finally
    InternalUnlock;
  end;
end;

Procedure TLocalDataBaseTrigger.IT_SetTables(Const Value:AnsiString);
begin
  InternalLock;
  try
    FTables:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TLocalDataBaseTrigger.IT_GetSQLCommands:TSetSQLCommandType;
begin
  InternalLock;
  try
    Result:=FSQLCommands;
  finally
    InternalUnlock;
  end;
end;

Procedure TLocalDataBaseTrigger.IT_SetSQLCommands(Value:TSetSQLCommandType);
begin
  InternalLock;
  try
    FSQLCommands:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TLocalDataBaseTrigger.IT_GetServerProcRegNames:AnsiString;
begin
  InternalLock;
  try
    Result:=FServerProcRegNames;
  finally
    InternalUnlock;
  end;
end;

Procedure TLocalDataBaseTrigger.IT_SetServerProcRegNames(Const Value:AnsiString);
begin
  InternalLock;
  try
    FServerProcRegNames:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TLocalDataBaseTrigger.IT_GetServerProcParam:Variant;
begin
  InternalLock;
  try
    Result:=FServerProcParam;
  finally
    InternalUnlock;
  end;
end;

Procedure TLocalDataBaseTrigger.IT_SetServerProcParam(Const Value:Variant);
begin
  InternalLock;
  try
    FServerProcParam:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TLocalDataBaseTrigger.InternalCheckInclude(aTriggerType:TTriggerType; aSQLCommandType:TSQLCommandType; Const aTable:AnsiString):Boolean;
begin
  Result:=(aTriggerType in FTypes)And(aSQLCommandType in FSQLCommands)And((FTables=''{Все таблицы})Or(CheckIncludeParamStrInParamsStr(FTables, aTable, ';')));
end;

Function TLocalDataBaseTrigger.ITCheckInclude(aTriggerType:TTriggerType; aSQLCommandType:TSQLCommandType; Const aTable:AnsiString):Boolean;
begin
  InternalLock;
  try
    Result:=InternalCheckInclude(aTriggerType, aSQLCommandType, aTable);
  finally
    InternalUnlock;
  end;
end;

Function TLocalDataBaseTrigger.ITCheckEqual(Const aServerProcRegNames:AnsiString; Const aServerProcParam:Variant; Const aTables:AnsiString; aTriggerTypes:TSetTriggerType; aSQLCommands:TSetSQLCommandType):Boolean;
begin
  InternalLock;
  try
    Result:=(aTriggerTypes=FTypes)And(aSQLCommands=FSQLCommands)And(glVarArrayToString(aServerProcParam)=glVarArrayToString(FServerProcParam))And(CompareParamsStr(aTables, FTables, ';'))And(CompareParamsStr(aServerProcRegNames, FServerProcRegNames, ';'));
  finally
    InternalUnlock;
  end;
end;

Function TLocalDataBaseTrigger.ITGetTriggerRegNames(aTriggerType:TTriggerType; aSQLCommandType:TSQLCommandType; Const aTable:AnsiString):AnsiString;
begin
  If InternalCheckInclude(aTriggerType, aSQLCommandType, aTable) Then begin
    Result:=FServerProcRegNames;
  end else begin
    Result:='';
  end;
end;

end.
