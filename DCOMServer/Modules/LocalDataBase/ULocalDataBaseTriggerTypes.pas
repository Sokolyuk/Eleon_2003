unit ULocalDataBaseTriggerTypes;

interface
  Uses USQLParserTypes;
Type
  TTriggerType=(cftBefore, cftAfter);
  TSetTriggerType=Set Of TTriggerType;

  ILocalDataBaseTrigger=Interface
  ['{FE489706-AB47-4F29-AE6C-53FFABF16AB8}']
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
    Function ITCheckInclude(aTriggerType:TTriggerType; aSQLCommandType:TSQLCommandType; Const aTable:AnsiString):Boolean;
    Function ITCheckEqual(Const aServerProcRegNames:AnsiString; Const aServerProcParam:Variant; Const aTables:AnsiString; aTriggerTypes:TSetTriggerType; aSQLCommands:TSetSQLCommandType):Boolean;
    Function ITGetTriggerRegNames(aTriggerType:TTriggerType; aSQLCommandType:TSQLCommandType; Const aTable:AnsiString):AnsiString;
    Property ITServerProcRegNames:AnsiString read IT_GetServerProcRegNames write IT_SetServerProcRegNames;
    Property ITServerProcParam:Variant read IT_GetServerProcParam write IT_SetServerProcParam;
    Property ITTypes:TSetTriggerType read IT_GetTypes write IT_SetTypes;
    Property ITTables:AnsiString read IT_GetTables write IT_SetTables;
    Property ITSQLCommands:TSetSQLCommandType read IT_GetSQLCommands write IT_SetSQLCommands;
  end;

implementation

end.
