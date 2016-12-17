unit UTaskStorage;

Interface
  Uses UTaskStorageTypes, UITObject, UTaskCaller, UTaskCallerTypes, UVarset, UTTaskType, UVarsetTypes;

Type
  TTaskStorage=class(TITObject, ITaskStorage)
  private
    FTaskStorage, FTaskSuspendStorage, FTaskIgnore:IVarset;
    FTaskID:Integer;
    FIOnTaskStorageTaskPush:IOnTaskStorageTaskPush;
    FMaxTaskCount, FMaxSuspendTaskCount:Cardinal;
    Procedure InternalTaskPushEx(Const aTaskCaller:ITaskCaller);
    Function InternalCheckTaskID(aTaskID:Integer):Boolean;
    Function InternalCheckIgnoreTask(aTask:TTask):Boolean;
  protected
    Function IT_GetOnTaskPush:IOnTaskStorageTaskPush;
    Procedure IT_SetOnTaskPush(aOnTaskPush:IOnTaskStorageTaskPush);
    Function IT_GetMaxTaskCount:Cardinal;
    Procedure IT_SetMaxTaskCount(Value:Cardinal);
    Function IT_GetMaxSuspendTaskCount:Cardinal;
    Procedure IT_SetMaxSuspendTaskCount(Value:Cardinal);
  public
    constructor Create;
    destructor Destroy; override;
    Procedure ITTaskAdd(aTask:TTask; Const aParams, aSenderParams, aSenderSecurityContext:Variant);
    Procedure ITTaskAddO(aTask:TTask; Const aParams, aSenderParams, aSenderSecurityContext:Variant; aTaskNumbered:Integer; Out aTaskID:Integer);
    Procedure ITTaskSleepAdd(aTask:TTask; Const aParams, aSenderParams, aSenderSecurityContext:Variant; aSleep:LongWord);
    Procedure ITTaskSleepAddO(aTask:TTask; Const aParams, aSenderParams, aSenderSecurityContext:Variant; aSleep:LongWord; aTaskNumbered:Integer; Out aTaskID:Integer);
    Procedure ITTaskWakeupAdd(aTask:TTask; Const aParams, aSenderParams, aSenderSecurityContext:Variant; aWakeup:TDateTime);
    Procedure ITTaskWakeupAddO(aTask:TTask; Const aParams, aSenderParams, aSenderSecurityContext:Variant; aWakeup:TDateTime; aTaskNumbered:Integer; Out aTaskID:Integer);
    Procedure ITTaskPushEx(aTaskCaller:ITaskCaller);
    Function ITMateTaskCancel(aTaskID:Integer):Boolean;
    Procedure ITMateIgnoreTaskAdd(aTask:TTask);
    Function ITMateIgnoreTaskCancel(aTask:TTask):Boolean;
    Function ITMateIgnoreTaskCheck(aTask:TTask):Boolean;
    Function ITTaskPop:ITaskCaller;       //Доставать все подряд
    Function ITTaskPopWakeup:ITaskCaller; //Доставать только у которых пришло время.
    Property ITOnTaskPush:IOnTaskStorageTaskPush read IT_GetOnTaskPush write IT_SetOnTaskPush;
    Property ITMaxTaskCount:Cardinal read IT_GetMaxTaskCount write IT_SetMaxTaskCount;
    Property ITMaxSuspendTaskCount:Cardinal read IT_GetMaxSuspendTaskCount write IT_SetMaxSuspendTaskCount;
  end;

Implementation
  Uses UCaller, UCallerTypes, SysUtils, UDateTimeUtils, UTaskTypes, UTypes, UObjectsTypes;

Constructor TTaskStorage.Create;
begin
  FTaskID:=0;
  //..
  FTaskStorage:=TVarset.Create;
  FTaskStorage.ITConfigCheckUniqueIntIndex:=False;//Проверять уникальность IntIndex.
  FTaskStorage.ITConfigIntIndexAssignable:=True;//Разрешить устанавливать свой IntIndex.
  FTaskStorage.ITConfigNoFoundException:=False;
  //..
  FTaskSuspendStorage:=TVarset.Create;
  FTaskSuspendStorage.ITConfigCheckUniqueIntIndex:=False;//Проверять уникальность IntIndex.
  FTaskSuspendStorage.ITConfigIntIndexAssignable:=True;//Разрешить устанавливать свой IntIndex.
  //..
  FTaskIgnore:=TVarset.Create;
  FTaskIgnore.ITConfigCheckUniqueIntIndex:=False;//Проверять уникальность IntIndex.
  FTaskIgnore.ITConfigIntIndexAssignable:=True;//Разрешить устанавливать свой IntIndex.
  //..
  FIOnTaskStorageTaskPush:=Nil;
  FMaxTaskCount:=500;
  FMaxSuspendTaskCount:=1000;
  Inherited Create;
end;

Destructor TTaskStorage.Destroy;
begin
  Try
    FTaskStorage:=Nil;
    FTaskSuspendStorage:=Nil;
    FTaskIgnore:=Nil;
    FIOnTaskStorageTaskPush:=Nil;
  Except end;
  Inherited Destroy;
end;

Function TTaskStorage.IT_GetOnTaskPush:IOnTaskStorageTaskPush;
begin
  InternalLock;
  Try
    Result:=FIOnTaskStorageTaskPush;
  Finally
    InternalUnLock;
  End;
end;

Procedure TTaskStorage.IT_SetOnTaskPush(aOnTaskPush:IOnTaskStorageTaskPush);
begin
  InternalLock;
  Try
    FIOnTaskStorageTaskPush:=aOnTaskPush;
  Finally
    InternalUnLock;
  End;
end;

Function TTaskStorage.IT_GetMaxTaskCount:Cardinal;
begin
  InternalLock;
  Try
    Result:=FMaxTaskCount;
  Finally
    InternalUnLock;
  End;
end;

Procedure TTaskStorage.IT_SetMaxTaskCount(Value:Cardinal);
begin
  InternalLock;
  Try
    FMaxTaskCount:=Value;
  Finally
    InternalUnLock;
  End;
end;

Function TTaskStorage.IT_GetMaxSuspendTaskCount:Cardinal;
begin
  InternalLock;
  Try
    Result:=FMaxSuspendTaskCount;
  Finally
    InternalUnLock;
  End;
end;

Procedure TTaskStorage.IT_SetMaxSuspendTaskCount(Value:Cardinal);
begin
  InternalLock;
  Try
    FMaxSuspendTaskCount:=Value;
  Finally
    InternalUnLock;
  End;
end;

Function TTaskStorage.InternalCheckTaskID(aTaskID:Integer):Boolean;
begin
  Result:=(FTaskSuspendStorage.ITExistsIntIndex(aTaskID))Or(FTaskStorage.ITExistsIntIndex(aTaskID));
end;

Procedure TTaskStorage.InternalTaskPushEx(Const aTaskCaller:ITaskCaller);
  Var tmpIVarsetData:IVarsetData;
      tmpICallerAction:ICallerAction;
      tmpIOnTaskStorageTaskPush:IOnTaskStorageTaskPush;
begin
  If Not Assigned(aTaskCaller) Then Raise Exception.Create('TaskCaller is not assigned.');
  If InternalCheckIgnoreTask(aTaskCaller.ITTask) Then begin
    tmpICallerAction:=aTaskCaller.ITCallerAction;
    If Assigned(tmpICallerAction) Then tmpICallerAction.ITMessAdd(Now, Now, Self, 'TTaskStorage', 'Ignore add task '''+TaskToStr(aTaskCaller.ITTask)+'('+IntToStr(Integer(aTaskCaller.ITTask))+')''.', mecApp, mesWarning);
    Exit;
  end;
  //..
  If aTaskCaller.ITNumbered<0 Then begin
    aTaskCaller.ITTaskID:=FTaskID;
    Inc(FTaskID);
  end else begin
    //Check unique
    If InternalCheckTaskID(aTaskCaller.ITNumbered) Then Raise Exception.Create('IntIndex='+IntToStr(aTaskCaller.ITNumbered)+' already exists.');
    aTaskCaller.ITTaskID:=aTaskCaller.ITNumbered;
  end;
  //..
  tmpIOnTaskStorageTaskPush:=FIOnTaskStorageTaskPush;
  If Assigned(tmpIOnTaskStorageTaskPush){Наначен приемниек задач} Then begin
    tmpIOnTaskStorageTaskPush.OnTaskStorageTaskPush(FTaskStorage.ITCount+1);
    tmpIOnTaskStorageTaskPush:=Nil;
  end;  
  //..
  tmpIVarsetData:=TVarsetData.Create;
  tmpIVarsetData.ITIntIndex:=aTaskCaller.ITTaskID;
  tmpIVarsetData.ITData:=aTaskCaller;
  //..
  If aTaskCaller.ITIsSuspendTask Then begin
    //Это отложенная задача, для нее нужно чтобы ITSleep было 0, а время срабатывания находилось в ITWakeup.
    If FTaskSuspendStorage.ITCount>=FMaxSuspendTaskCount Then Raise Exception.Create('Overflow TaskSuspendStorage(FMaxSuspendTaskCount='+IntToStr(FMaxSuspendTaskCount)+').');
    If aTaskCaller.ITIsWakeupTask Then begin
      //Назначено время срабатывания
      If aTaskCaller.ITSleep>0 Then begin
        //Есть задержка в срабатывании
        aTaskCaller.ITWakeup:=aTaskCaller.ITWakeup+aTaskCaller.ITSleep/MSecsPerDay;//MSecsToDateTime(aTaskCaller.ITSleep);
        aTaskCaller.ITSleep:=0;
      end else begin
        //Нет задержки в срабатывании
        //Ничего, т.к. уже все нормально
      end;
    end else begin
      //Не назначено время срабатывания
      If aTaskCaller.ITSleep>0 Then begin
        //Есть задержка в срабатывании
        aTaskCaller.ITWakeup:=Now+aTaskCaller.ITSleep/MSecsPerDay;//MSecsToDateTime();

        aTaskCaller.ITSleep:=0;
      end else begin
        //Нет задержки в срабатывании, по логике такого случая быть не должно
        aTaskCaller.ITWakeup:=Now;
      end;
    end;
    tmpIVarsetData.ITWakeup:=aTaskCaller.ITWakeup;
    FTaskSuspendStorage.ITPush(tmpIVarsetData);
  end else begin
    If FTaskStorage.ITCount>=FMaxTaskCount Then Raise Exception.Create('Overflow TaskStorage(FMaxTaskCount='+IntToStr(FMaxTaskCount)+').');
    FTaskStorage.ITPush(tmpIVarsetData);
  end;
  aTaskCaller.ITStatus:=tssQueue;
  tmpIVarsetData:=Nil;
end;

Procedure TTaskStorage.ITTaskAdd(aTask:TTask; Const aParams, aSenderParams, aSenderSecurityContext:Variant);
  Var tmpTaskID:Integer;
begin
  InternalLock;
  Try
    ITTaskAddO(aTask, aParams, aSenderParams, aSenderSecurityContext, -1, tmpTaskID);
  Finally
    InternalUnLock;
  End;
end;

Procedure TTaskStorage.ITTaskAddO(aTask:TTask; Const aParams, aSenderParams, aSenderSecurityContext:Variant; aTaskNumbered:Integer; Out aTaskID:Integer);
  Var tmpTaskCaller:ITaskCaller;
      tmpCallerAction:ICallerAction;
begin
  InternalLock;
  Try
    tmpCallerAction:=TCallerAction.CreateNewAction(aSenderSecurityContext);
    tmpTaskCaller:=TTaskCaller.Create;
    tmpTaskCaller.ITTask:=aTask;
    tmpTaskCaller.ITParams:=aParams;
    tmpTaskCaller.ITSenderParams:=aSenderParams;
    tmpTaskCaller.ITCallerAction:=tmpCallerAction;
    tmpTaskCaller.ITNumbered:=aTaskNumbered;
    InternalTaskPushEx(tmpTaskCaller);
    aTaskID:=tmpTaskCaller.ITTaskID;
  Finally
    InternalUnLock;
  End;
end;

Procedure TTaskStorage.ITTaskSleepAdd(aTask:TTask; Const aParams, aSenderParams, aSenderSecurityContext:Variant; aSleep:LongWord);
  Var tmpTaskID:Integer;
begin
  InternalLock;
  Try
    ITTaskSleepAddO(aTask, aParams, aSenderParams, aSenderSecurityContext, aSleep, -1, tmpTaskID);
  Finally
    InternalUnLock;
  End;
end;

Procedure TTaskStorage.ITTaskSleepAddO(aTask:TTask; Const aParams, aSenderParams, aSenderSecurityContext:Variant; aSleep:LongWord; aTaskNumbered:Integer; Out aTaskID:Integer);
  Var tmpTaskCaller:ITaskCaller;
      tmpCallerAction:ICallerAction;
begin
  InternalLock;
  Try
    tmpCallerAction:=TCallerAction.CreateNewAction(aSenderSecurityContext);
    tmpTaskCaller:=TTaskCaller.Create;
    tmpTaskCaller.ITTask:=aTask;
    tmpTaskCaller.ITParams:=aParams;
    tmpTaskCaller.ITSenderParams:=aSenderParams;
    tmpTaskCaller.ITCallerAction:=tmpCallerAction;
    tmpTaskCaller.ITSleep:=aSleep;
    tmpTaskCaller.ITNumbered:=aTaskNumbered;
    InternalTaskPushEx(tmpTaskCaller);
    aTaskID:=tmpTaskCaller.ITTaskID;
  Finally
    InternalUnLock;
  End;
end;

Procedure TTaskStorage.ITTaskWakeupAdd(aTask:TTask; Const aParams, aSenderParams, aSenderSecurityContext:Variant; aWakeup:TDateTime);
  Var tmpTaskID:Integer;
begin
  InternalLock;
  Try
    ITTaskWakeupAddO(aTask, aParams, aSenderParams, aSenderSecurityContext, aWakeup, -1, tmpTaskID);
  Finally
    InternalUnLock;
  End;
end;

Procedure TTaskStorage.ITTaskWakeupAddO(aTask:TTask; Const aParams, aSenderParams, aSenderSecurityContext:Variant; aWakeup:TDateTime; aTaskNumbered:Integer; Out aTaskID:Integer);
  Var tmpTaskCaller:ITaskCaller;
      tmpCallerAction:ICallerAction;
begin
  InternalLock;
  Try
    tmpCallerAction:=TCallerAction.CreateNewAction(aSenderSecurityContext);
    tmpTaskCaller:=TTaskCaller.Create;
    tmpTaskCaller.ITTask:=aTask;
    tmpTaskCaller.ITParams:=aParams;
    tmpTaskCaller.ITSenderParams:=aSenderParams;
    tmpTaskCaller.ITCallerAction:=tmpCallerAction;
    tmpTaskCaller.ITWakeup:=aWakeup;
    tmpTaskCaller.ITNumbered:=aTaskNumbered;
    InternalTaskPushEx(tmpTaskCaller);
    aTaskID:=tmpTaskCaller.ITTaskID;
  Finally
    InternalUnLock;
  End;
end;

Procedure TTaskStorage.ITTaskPushEx(aTaskCaller:ITaskCaller);
begin
  InternalLock;
  Try
    InternalTaskPushEx(aTaskCaller);
  Finally
    InternalUnLock;
  End;
end;

//..
Function  TTaskStorage.ITMateTaskCancel(aTaskID:Integer):Boolean;
begin
  InternalLock;
  Try
    Result:=(FTaskStorage.ITClearOfIntIndex(aTaskID))Or(FTaskSuspendStorage.ITClearOfIntIndex(aTaskID));
  Finally
    InternalUnLock;
  End;
end;

Function TTaskStorage.InternalCheckIgnoreTask(aTask:TTask):Boolean;
begin
  Result:=FTaskIgnore.ITExistsIntIndex(Integer(aTask));
end;

Procedure TTaskStorage.ITMateIgnoreTaskAdd(aTask:TTask);
  Var tmpIVarsetData:IVarsetData;
begin
  InternalLock;
  Try
    If Not InternalCheckIgnoreTask(aTask) Then begin
      tmpIVarsetData:=TVarsetData.Create;
      tmpIVarsetData.ITIntIndex:=Integer(aTask);
      FTaskIgnore.ITPush(tmpIVarsetData);
    end;  
  Finally
    InternalUnLock;
  End;
end;

Function  TTaskStorage.ITMateIgnoreTaskCancel(aTask:TTask):Boolean;
begin
  InternalLock;
  Try
    Result:=FTaskIgnore.ITClearOfIntIndex(Integer(aTask));
  Finally
    InternalUnLock;
  End;
end;

Function TTaskStorage.ITMateIgnoreTaskCheck(aTask:TTask):Boolean;
begin
  InternalLock;
  Try
    Result:=InternalCheckIgnoreTask(aTask);
  Finally
    InternalUnLock;
  End;
end;

Function TTaskStorage.ITTaskPop:ITaskCaller;       //Доставать все подряд
  Var tmpIVarsetData:IVarsetData;
      tmpIUnknown:IUnknown;
begin
  InternalLock;
  Try
    tmpIVarsetData:=FTaskStorage.ITPop;
    If Not Assigned(tmpIVarsetData) Then begin
      tmpIVarsetData:=FTaskSuspendStorage.ITPop;
    end;
    If Assigned(tmpIVarsetData) then begin
      tmpIUnknown:=tmpIVarsetData.ITData;
      Result:=ITaskCaller(tmpIUnknown);
    end else begin
      Result:=Nil;
    end;
  Finally
    InternalUnLock;
  End;
end;

Function TTaskStorage.ITTaskPopWakeup:ITaskCaller; //Доставать только у которых пришло время.
  Var tmpIVarsetData:IVarsetData;
      tmpIUnknown:IUnknown;
begin
  InternalLock;
  Try
    tmpIVarsetData:=FTaskStorage.ITPop;
    If Not Assigned(tmpIVarsetData) Then begin
      tmpIVarsetData:=FTaskSuspendStorage.ITPopWakeup;
    end;
    If Assigned(tmpIVarsetData) then begin
      tmpIUnknown:=tmpIVarsetData.ITData;
      Result:=ITaskCaller(tmpIUnknown);
    end else begin
      Result:=Nil;
    end;
  Finally
    InternalUnLock;
  End;
end;

end.

