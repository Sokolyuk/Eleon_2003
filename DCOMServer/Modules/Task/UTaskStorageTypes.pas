unit UTaskStorageTypes;

interface
  Uses UTTaskType, UTaskCallerTypes;

Type
  IOnTaskStorageTaskPush=Interface
  ['{8E8E04B4-5093-44B0-BCD1-3BAC2B309B23}']
    Procedure OnTaskStorageTaskPush(aTaskCount:Integer); //TTaskPushEvent=Procedure(aTaskCount:Integer) of object;
  end;

  ITaskStorage=Interface
  ['{3E29108B-9AFB-4B6B-A1D8-F82671048818}']
    Function IT_GetOnTaskPush:IOnTaskStorageTaskPush;
    Procedure IT_SetOnTaskPush(aOnTaskPush:IOnTaskStorageTaskPush);
    Function IT_GetMaxTaskCount:Cardinal;
    Procedure IT_SetMaxTaskCount(Value:Cardinal);
    Function IT_GetMaxSuspendTaskCount:Cardinal;
    Procedure IT_SetMaxSuspendTaskCount(Value:Cardinal);
    //..
    Procedure ITTaskAdd(aTask:TTask; Const aParams, aSenderParams, aSenderSecurityContext:Variant);
    Procedure ITTaskSleepAdd(aTask:TTask; Const aParams, aSenderParams, aSenderSecurityContext:Variant; aSleep:LongWord);
    Procedure ITTaskWakeupAdd(aTask:TTask; Const aParams, aSenderParams, aSenderSecurityContext:Variant; aWakeup:TDateTime);
    Procedure ITTaskPushEx(aTaskCaller:ITaskCaller);
    Function  ITMateTaskCancel(aTaskID:Integer):Boolean;
    Procedure ITMateIgnoreTaskAdd(aTask:TTask);
    Function  ITMateIgnoreTaskCancel(aTask:TTask):Boolean;
    Function  ITMateIgnoreTaskCheck(aTask:TTask):Boolean;
    Function ITTaskPop:ITaskCaller;       //Доставать все подряд
    Function ITTaskPopWakeup:ITaskCaller; //Доставать только у которых пришло время.
    Property ITOnTaskPush:IOnTaskStorageTaskPush read IT_GetOnTaskPush write IT_SetOnTaskPush;
    Property ITMaxTaskCount:Cardinal read IT_GetMaxTaskCount write IT_SetMaxTaskCount;
    Property ITMaxSuspendTaskCount:Cardinal read IT_GetMaxSuspendTaskCount write IT_SetMaxSuspendTaskCount;
  End;

implementation

end.
