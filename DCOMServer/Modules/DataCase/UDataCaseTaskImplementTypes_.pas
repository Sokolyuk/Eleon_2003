unit UDataCaseTaskImplementTypes;
  Устарел, см UTaskImplementTypes
interface
  uses UTTaskTypes, UCallerTypes;
Type
  IDataCaseTaskImplement=interface
  ['{7CC09343-D969-46F0-B9AA-FE0892089C63}']
    Procedure BfTasksImplement(aCallerAction:ICallerAction; aTask:TTask; Const aParams{, aSecurityContext, aSenderParams}:Variant; aTaskID:Integer; aSetResult:PBoolean; aResult:PVariant);
  end;

implementation

end.
