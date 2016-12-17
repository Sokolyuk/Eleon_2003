unit UTaskCaller;

interface
  Uses UTaskCallerTypes, UITObject, UTypes, UTTaskTypes, UCallerTypes;

Type

  TTaskCaller=class(TITObject, ITaskCaller)
  private
    FTask:TTask;
    FNumbered:Integer;
    FTaskID:Integer;
    FSleep:LongWord;
    FWakeup:TDateTime;
    FParams, {FSenderParams, }FResultData:Variant;
    FResultErrorMessage:AnsiString;
    FCallerAction:ICallerAction;
    FStatus:TSTTaskStatus;
    FCanceled:Boolean;
    FSleepTask, FWakeupTask:Boolean;
    FNextBlockTask:ITaskCaller;
    FNextTask:ITaskCaller;
    FExceptTask:ITaskCaller;
    FResultErrorHelpContext:Integer;
  protected
    Function ITGet_Task:TTask;
    Procedure ITSet_Task(Value:TTask);
    Function ITGet_IsSuspendTask:Boolean;
    Function ITGet_Numbered:Integer;
    Procedure ITSet_Numbered(Value:Integer);
    Function ITGet_TaskID:Integer;
    Procedure ITSet_TaskID(Value:Integer);
    Function ITGet_Sleep:LongWord;
    Procedure ITSet_Sleep(Value:LongWord);
    Function ITGet_Wakeup:TDateTime;
    Procedure ITSet_Wakeup(Value:TDateTime);
    Function ITGet_IsWakeupTask:Boolean;
    Function ITGet_Params:Variant;
    Procedure ITSet_Params(Value:Variant);
    Function ITGet_ResultData:Variant;
    Procedure ITSet_ResultData(Value:Variant);
    Function IT_GetResultErrorMessage:AnsiString;
    Procedure IT_SetResultErrorMessage(Value:AnsiString);
    //Function ITGet_SenderParams:Variant;
    //Procedure ITSet_SenderParams(Value:Variant);
    Function ITGet_CallerAction:ICallerAction;
    Procedure ITSet_CallerAction(Value:ICallerAction);
    Function ITGet_Status:TSTTaskStatus;
    Procedure ITSet_Status(Value:TSTTaskStatus);
    Function ITGet_Canceled:Boolean;
    Procedure ITSet_Canceled(Value:Boolean);
    Function IT_GetNextTask:ITaskCaller;
    Procedure IT_SetNextTask(Value:ITaskCaller);
    Function IT_GetExceptTask:ITaskCaller;
    Procedure IT_SetExceptTask(Value:ITaskCaller);
    Function IT_GetNextBlockTask:ITaskCaller;
    Procedure IT_SetNextBlockTask(Value:ITaskCaller);
    Function IT_GetResultErrorHelpContext:Integer;
    Procedure IT_SetResultErrorHelpContext(Value:Integer);
  public
    Constructor Create;
    Destructor Destroy; override;
    Function ITClone:ITaskCaller;
    //..
    Property ITTask:TTask read ITGet_Task write ITSet_Task;               //Задача
    Property ITIsSuspendTask:Boolean read ITGet_IsSuspendTask;            //Это отложенная задача
    Property ITNumbered:Integer read ITGet_Numbered write ITSet_Numbered; //Номированная или нет(-1)
    Property ITTaskID:Integer read ITGet_TaskID write ITSet_TaskID;       //Присвоенный идентификатор(если ITNumbered<>-1 то ITNumbered)
    Property ITSleep:LongWord read ITGet_Sleep write ITSet_Sleep;         //Через сколько после Now() задача проснется
    Property ITWakeup:TDateTime read ITGet_Wakeup write ITSet_Wakeup;     //Врямя в которое зада проснется
    Property ITIsWakeupTask:Boolean read ITGet_IsWakeupTask;              //Это отложенная задача, назначено время срабатывания(WakeupTask).
    Property ITParams:Variant read ITGet_Params write ITSet_Params;       //Основной параметр
    //Property ITSenderParams:Variant read ITGet_SenderParams write ITSet_SenderParams; //Параметр отправителя
    Property ITCallerAction:ICallerAction read ITGet_CallerAction write ITSet_CallerAction; //-
    Property ITCanceled:Boolean read ITGet_Canceled write ITSet_Canceled;
    Property ITNextBlockTask:ITaskCaller read IT_GetNextBlockTask write IT_SetNextBlockTask;
    Property ITNextTask:ITaskCaller read IT_GetNextTask write IT_SetNextTask;
    Property ITExceptTask:ITaskCaller read IT_GetExceptTask write IT_SetExceptTask;
    Property ITResultData:Variant read ITGet_ResultData write ITSet_ResultData;
    Property ITResultErrorMessage:AnsiString read IT_GetResultErrorMessage write IT_SetResultErrorMessage;
    //Значение ITStatus устанавльвается последним и означает что все значещие поля назначены(ITResultData, ITResultErrorMessage).
    Property ITStatus:TSTTaskStatus read ITGet_Status write ITSet_Status;
    Property ITResultErrorHelpContext:Integer read IT_GetResultErrorHelpContext write IT_SetResultErrorHelpContext;
  end;

implementation
  Uses UObjectsTypes
{$IFDEF VER140}
  { Borland Delphi 6.0 }
       , Variants
{$ENDIF}
       ;

Constructor TTaskCaller.Create;
begin
  //ObjectType:=otTTaskCaller;
  Inherited Create;
  FTask:=tskMTNone;
  FNumbered:=-1;
  FTaskID:=-1;
  FSleep:=0;
  FWakeup:=0.0;
  FParams:=Unassigned;
  FResultData:=Unassigned;
  FResultErrorMessage:='';
  //FSenderParams:=Unassigned;
  FCallerAction:=Nil;
  FStatus:=tssNoTask;
  FCanceled:=False;
  FSleepTask:=False;
  FWakeupTask:=False;
  FNextTask:=Nil;
  FExceptTask:=Nil;
  FNextBlockTask:=Nil;
  FResultErrorHelpContext:=0;
end;

Destructor TTaskCaller.Destroy;
begin
  Try
    FCallerAction:=Nil;
    FNextBlockTask:=Nil;
    FNextTask:=Nil;
    FExceptTask:=Nil;
    VarClear(FParams);
    VarClear(FResultData);
    //VarClear(FSenderParams);
    FResultErrorMessage:='';
  except end;
  Inherited Destroy;
end;

Function TTaskCaller.ITGet_Task:TTask;
begin
  InternalLock;
  try
    Result:=FTask;
  finally
    InternalUnLock;
  end;  
end;

Procedure TTaskCaller.ITSet_Task(Value:TTask);
begin
  InternalLock;
  try
    FTask:=Value;
  finally
    InternalUnLock;
  end;
end;

Function TTaskCaller.ITGet_IsSuspendTask:Boolean;
begin
  InternalLock;
  try
    Result:=FSleepTask Or FWakeupTask;
  finally
    InternalUnLock;
  end;
end;

Function TTaskCaller.ITGet_Numbered:Integer;
begin
  InternalLock;
  try
    Result:=FNumbered;
  finally
    InternalUnLock;
  end;
end;

Procedure TTaskCaller.ITSet_Numbered(Value:Integer);
begin
  InternalLock;
  try
    FNumbered:=Value;
  finally
    InternalUnLock;
  end;
end;

Function TTaskCaller.ITGet_TaskID:Integer;
begin
  InternalLock;
  try
    Result:=FTaskID;
  finally
    InternalUnLock;
  end;
end;

Procedure TTaskCaller.ITSet_TaskID(Value:Integer);
begin
  InternalLock;
  try
    FTaskID:=Value;
  finally
    InternalUnLock;
  end;
end;

Function TTaskCaller.ITGet_Sleep:LongWord;
begin
  InternalLock;
  try
    Result:=FSleep;
  finally
    InternalUnLock;
  end;
end;

Procedure TTaskCaller.ITSet_Sleep(Value:LongWord);
begin
  InternalLock;
  try
    FSleep:=Value;
    If FSleep=0 Then FSleepTask:=False else FSleepTask:=True;
  finally
    InternalUnLock;
  end;  
end;

Function TTaskCaller.ITGet_Wakeup:TDateTime;
begin
  InternalLock;
  try
    Result:=FWakeup;
  finally
    InternalUnLock;
  end;
end;

Procedure TTaskCaller.ITSet_Wakeup(Value:TDateTime);
begin
  InternalLock;
  try
    FWakeup:=Value;
    If FWakeup=0 Then FWakeupTask:=False else FWakeupTask:=True;
  finally
    InternalUnLock;
  end;
end;

Function TTaskCaller.ITGet_IsWakeupTask:Boolean;
begin
  InternalLock;
  try
    Result:=FWakeupTask;
  finally
    InternalUnLock;
  end;
end;

Function TTaskCaller.ITGet_Params:Variant;
begin
  InternalLock;
  try
    Result:=FParams;
  finally
    InternalUnLock;
  end;  
end;

Procedure TTaskCaller.ITSet_Params(Value:Variant);
begin
  InternalLock;
  try
    FParams:=Value;
  finally
    InternalUnLock;
  end;  
end;

Function TTaskCaller.ITGet_ResultData:Variant;
begin
  InternalLock;
  try
    Result:=FResultData;
  finally
    InternalUnLock;
  end;
end;

Procedure TTaskCaller.ITSet_ResultData(Value:Variant);
begin
  InternalLock;
  try
    FResultData:=Value;
  finally
    InternalUnLock;
  end;
end;

Function TTaskCaller.IT_GetResultErrorMessage:AnsiString;
begin
  InternalLock;
  try
    Result:=FResultErrorMessage;
  finally
    InternalUnLock;
  end;
end;

Procedure TTaskCaller.IT_SetResultErrorMessage(Value:AnsiString);
begin
  InternalLock;
  try
    FResultErrorMessage:=Value;
  finally
    InternalUnLock;
  end;
end;

{Function TTaskCaller.ITGet_SenderParams:Variant;
begin
  InternalLock;
  try
    Result:=FSenderParams;
  finally
    InternalUnLock;
  end;
end;

Procedure TTaskCaller.ITSet_SenderParams(Value:Variant);
begin
  InternalLock;
  try
    FSenderParams:=Value;
  finally
    InternalUnLock;
  end;
end;}

Function TTaskCaller.ITGet_CallerAction:ICallerAction;
begin
  InternalLock;
  try
    Result:=FCallerAction;
  finally
    InternalUnLock;
  end;
end;

Procedure TTaskCaller.ITSet_CallerAction(Value:ICallerAction);
begin
  InternalLock;
  try
    FCallerAction:=Value;
  finally
    InternalUnLock;
  end;  
end;

Function TTaskCaller.ITGet_Status:TSTTaskStatus;
begin
  InternalLock;
  try
    Result:=FStatus;
  finally
    InternalUnLock;
  end;
end;

Procedure TTaskCaller.ITSet_Status(Value:TSTTaskStatus);
begin
  InternalLock;
  try
    FStatus:=Value;
  finally
    InternalUnLock;
  end;
end;

Function TTaskCaller.ITGet_Canceled:Boolean;
begin
  InternalLock;
  try
    Result:=FCanceled;
  finally
    InternalUnLock;
  end;
end;

Procedure TTaskCaller.ITSet_Canceled(Value:Boolean);
begin
  InternalLock;
  try
    FCanceled:=Value;
  finally
    InternalUnLock;
  end;
end;

Function TTaskCaller.IT_GetNextTask:ITaskCaller;
begin
  InternalLock;
  try
    Result:=FNextTask;
  finally
    InternalUnLock;
  end;
end;

Procedure TTaskCaller.IT_SetNextTask(Value:ITaskCaller);
begin
  InternalLock;
  try
    FNextTask:=Value;
  finally
    InternalUnLock;
  end;
end;

Function TTaskCaller.IT_GetExceptTask:ITaskCaller;
begin
  InternalLock;
  try
    Result:=FExceptTask;
  finally
    InternalUnLock;
  end;
end;

Procedure TTaskCaller.IT_SetExceptTask(Value:ITaskCaller);
begin
  InternalLock;
  try
    FExceptTask:=Value;
  finally
    InternalUnLock;
  end;
end;

Function TTaskCaller.IT_GetNextBlockTask:ITaskCaller;
begin
  InternalLock;
  try
    Result:=FNextBlockTask;
  finally
    InternalUnLock;
  end;
end;

Procedure TTaskCaller.IT_SetNextBlockTask(Value:ITaskCaller);
begin
  InternalLock;
  try
    FNextBlockTask:=Value;
  finally
    InternalUnLock;
  end;
end;

Function TTaskCaller.IT_GetResultErrorHelpContext:Integer;
begin
  InternalLock;
  try
    Result:=FResultErrorHelpContext;
  finally
    InternalUnLock;
  end;
end;

Procedure TTaskCaller.IT_SetResultErrorHelpContext(Value:Integer);
begin
  InternalLock;
  try
    FResultErrorHelpContext:=Value;
  finally
    InternalUnLock;
  end;
end;

Function TTaskCaller.ITClone:ITaskCaller;
begin
  InternalLock;
  try
    Result:=TTaskCaller.Create;
    Result.ITTask:=ITTask;
    Result.ITNumbered:=ITNumbered;
    Result.ITTaskID:=ITTaskID;
    Result.ITSleep:=ITSleep;
    Result.ITWakeup:=ITWakeup;
    Result.ITParams:=ITParams;
    Result.ITResultData:=ITResultData;
    Result.ITResultErrorMessage:=ITResultErrorMessage;
    Result.ITResultErrorHelpContext:=ITResultErrorHelpContext;
    //Result.ITSenderParams:=ITSenderParams;
    Result.ITCallerAction:=ITCallerAction;
    Result.ITStatus:=ITStatus;
    Result.ITCanceled:=ITCanceled;
    Result.ITNextBlockTask:=ITNextBlockTask;
    Result.ITNextTask:=ITNextTask;
    Result.ITExceptTask:=ITExceptTask;
  finally
    InternalUnLock;
  end;
end;

end.
