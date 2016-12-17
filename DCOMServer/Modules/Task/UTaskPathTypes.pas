unit UTaskPathTypes;
устарел  
interface
  Uses UTaskCallerTypes;
Type
  ITaskPath=interface
  ['{B507010C-25A6-4F33-AAFF-020C6A3BD4B8}']
    Function GetCurrTaskCaller:ITaskCaller;
    Procedure SetCurrTaskCaller(Value:ITaskCaller);
    Function GetPrevTaskPath:ITaskPath;
    Procedure SetPrevTaskPath(Value:ITaskPath);
    //..
    property CurrTaskCaller:ITaskCaller read GetCurrTaskCaller write SetCurrTaskCaller;
    property PrevTaskPath:ITaskPath read GetPrevTaskPath write SetPrevTaskPath;
  end;

implementation

end.
