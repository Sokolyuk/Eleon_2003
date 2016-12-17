unit ULocalDataBaseTriggersTypes;

interface
  Uses ULocalDataBaseTriggerTypes, ULocalDataBaseTypes, UCallerTypes, Windows;
Type
  TGetTriggerLocalDataBaseEvent=Function:ILocalDataBase of object;

  PTriggerData=^TTriggerData;
  //PInteger=^Integer;
  TTriggerData=Record
    SQLParams:POleVariant;
    SQLString:PAnsiString;
    TriggerType:TTriggerType;
    RunSQLType:TRunSQLType;
    RunSQLMode:PRunSQLMode;
    RecordAffected:PInteger;
    CDSData:POleVariant;
    AllowExecuteSQL:Boolean;
    AllowExecuteTriggerAfter:Boolean;
    DataFromBeforeToAfter:POleVariant;
  End;

  ILocalDataBaseTriggers=Interface
  ['{80003F35-1CEA-4AC5-AD31-CF793FFD258D}']
    Function ITCheck(aTriggerType:TTriggerType; Const aTables:Variant):Boolean;
    Function ITExec(aGetTriggerLocalDataBaseEvent:TGetTriggerLocalDataBaseEvent; aTriggerData:PTriggerData; Const aTables:Variant; aCallerAction:ICallerAction):Integer;
    Function ITReloadTriggers(aLocalDataBase:ILocalDataBase):AnsiString;
  end;

implementation

end.
