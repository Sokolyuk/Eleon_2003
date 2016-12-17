unit UDataCaseImplement;

interface
  Uses UITObject, UDataCaseImplementTypes, UTaskStorageTypes, UTaskThreadTypes, UVarsetTypes, UTaskImplementTypes,
       UTaskCallerTypes, UCallerTypes;
Type
  TDataCaseImplement=class(TITObject, IDataCaseImplement, IOnTaskThreadDestroy, IOnTaskThreadViewTask,
                                      IOnTaskThreadInactivity, IOnTaskStorageTaskPush, IOnTaskThreadCheckPerpetualReady)
  private
    FITaskStorage:ITaskStorage;
    FITaskThreads:IVarset;
    FITaskImplement:ITaskImplement;
    FOwnerCallerAction:ICallerAction;
    FLastFindCheckPerpetualReady:TDateTime;
    FLastFindCheckPerpetualReadyResult:Boolean;
  protected
    Function IT_GetITaskStorage:ITaskStorage;
    procedure IT_SetITaskStorage(Value:ITaskStorage);
    Function IT_GetITaskThreads:IVarset;
    procedure IT_SetITaskThreads(Value:IVarset);
    Function IT_GetITaskImplement:ITaskImplement;
    procedure IT_SetITaskImplement(Value:ITaskImplement);
    Function IT_GetOwnerCallerAction:ICallerAction;
    procedure IT_SetOwnerCallerAction(Value:ICallerAction);
    {..}
    Function IT_GetIOnTaskThreadDestroy:IOnTaskThreadDestroy;
    Function IT_GetIOnTaskThreadViewTask:IOnTaskThreadViewTask;
    Function IT_GetIOnTaskThreadInactivity:IOnTaskThreadInactivity;
    Function IT_GetIOnTaskStorageTaskPush:IOnTaskStorageTaskPush;
    {..}
    procedure OnTaskThreadDestroy(aTaskThread:ITaskThread);
    Function OnTaskThreadViewTask:ITaskCaller;
    procedure OnTaskThreadInactivity(aTaskThread:ITaskThread);
    Procedure OnTaskStorageTaskPush(aTaskCount:Integer);
    Function OnTaskThreadCheckPerpetualReady:Boolean;
    {..}
    Function ITTaskThreadToIVarsetDataView(aITaskThread:ITaskThread):IVarsetDataView;
    Procedure ITDestroyTaskThread(Var aTaskThread:ITaskThread);
    Procedure ITPushTaskThread(aITaskThread:ITaskThread; aPerpetual:Boolean);
    Function ITCreateTaskThread:ITaskThread;
  public
    constructor Create;
    destructor Destroy; override;
    Property ITITaskStorage:ITaskStorage read IT_GetITaskStorage write IT_SetITaskStorage;
    Property ITITaskThreads:IVarset read IT_GetITaskThreads write IT_SetITaskThreads;
    Property ITITaskImplement:ITaskImplement read IT_GetITaskImplement write IT_SetITaskImplement;
    Property ITOwnerCallerAction:ICallerAction read IT_GetOwnerCallerAction write IT_SetOwnerCallerAction;
    {..}
    Property ITIOnTaskThreadDestroy:IOnTaskThreadDestroy read IT_GetIOnTaskThreadDestroy;
    Property ITIOnTaskThreadViewTask:IOnTaskThreadViewTask read IT_GetIOnTaskThreadViewTask;
    Property ITIOnTaskThreadInactivity:IOnTaskThreadInactivity read IT_GetIOnTaskThreadInactivity;
    Property ITIOnTaskStorageTaskPush:IOnTaskStorageTaskPush read IT_GetIOnTaskStorageTaskPush;
  end;

implementation
  Uses UObjectsTypes, SysUtils, UDataCaseConsts, UVarset, UTaskThread, UDataCaseImplementConsts;

Constructor TDataCaseImplement.Create;
begin
  //ObjectType:=otTDataCaseImplement; //Тип объекта
  Inherited Create;
  FITaskStorage:=Nil;
  FITaskThreads:=Nil;
  FITaskImplement:=Nil;
  FOwnerCallerAction:=Nil;
  FLastFindCheckPerpetualReady:=0;
  FLastFindCheckPerpetualReadyResult:=False;
end;

Destructor TDataCaseImplement.Destroy;
begin
  try
    FITaskStorage:=Nil;
    FITaskThreads:=Nil;
    FITaskImplement:=Nil;
    FOwnerCallerAction:=Nil;
  except end;
  Inherited Destroy;
end;

Function TDataCaseImplement.IT_GetITaskStorage:ITaskStorage;
begin
  InternalLock;
  try
    Result:=FITaskStorage;
  finally
    InternalUnlock;
  end;
end;

procedure TDataCaseImplement.IT_SetITaskStorage(Value:ITaskStorage);
begin
  InternalLock;
  try
    FITaskStorage:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TDataCaseImplement.IT_GetITaskThreads:IVarset;
begin
  InternalLock;
  try
    Result:=FITaskThreads;
  finally
    InternalUnlock;
  end;
end;

procedure TDataCaseImplement.IT_SetITaskThreads(Value:IVarset);
begin
  InternalLock;
  try
    FITaskThreads:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TDataCaseImplement.IT_GetITaskImplement:ITaskImplement;
begin
  InternalLock;
  try
    Result:=FITaskImplement;
  finally
    InternalUnlock;
  end;
end;

procedure TDataCaseImplement.IT_SetITaskImplement(Value:ITaskImplement);
begin
  InternalLock;
  try
    FITaskImplement:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TDataCaseImplement.IT_GetOwnerCallerAction:ICallerAction;
begin
  InternalLock;
  try
    Result:=FOwnerCallerAction;
  finally
    InternalUnlock;
  end;
end;

procedure TDataCaseImplement.IT_SetOwnerCallerAction(Value:ICallerAction);
begin
  InternalLock;
  try
    FOwnerCallerAction:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TDataCaseImplement.IT_GetIOnTaskThreadDestroy:IOnTaskThreadDestroy;
begin
  Result:=Self;
end;

Function TDataCaseImplement.IT_GetIOnTaskThreadViewTask:IOnTaskThreadViewTask;
begin
  Result:=Self;
end;

Function TDataCaseImplement.IT_GetIOnTaskThreadInactivity:IOnTaskThreadInactivity;
begin
  Result:=Self;
end;

Function TDataCaseImplement.IT_GetIOnTaskStorageTaskPush:IOnTaskStorageTaskPush;
begin
  Result:=Self;
end;

procedure TDataCaseImplement.OnTaskThreadDestroy(aTaskThread:ITaskThread);
begin
 //Пока ничего
end;

Function TDataCaseImplement.OnTaskThreadViewTask:ITaskCaller;
  Var tmpITaskStorage:ITaskStorage;
begin
  tmpITaskStorage:=FITaskStorage;
  If Assigned(tmpITaskStorage) Then Result:=tmpITaskStorage.ITTaskPopWakeup Else Result:=Nil;
end;

procedure TDataCaseImplement.OnTaskThreadInactivity(aTaskThread:ITaskThread);
  Var tmpIVarsetDataView:IVarsetDataView;
      tmpITaskThreads:IVarset;
begin
  If Not Assigned(aTaskThread) Then Raise Exception.Create('This TaskThread is not assigned.');
  If aTaskThread.ITPerpetual Then begin
    //Perpetual
    aTaskThread.ITSuspend;
  end else begin
    //не Perpetual
    tmpIVarsetDataView:=ITTaskThreadToIVarsetDataView(aTaskThread);
    If Assigned(tmpIVarsetDataView) then begin
      ITDestroyTaskThread(aTaskThread);
      tmpITaskThreads:=FITaskThreads;
      If Not Assigned(tmpITaskThreads) Then Raise Exception.Create('TaskThreads is not assigned.');
      tmpITaskThreads.ITClearOfIntIndex(tmpIVarsetDataView.ITIntIndex);
      tmpITaskThreads:=Nil;
      tmpIVarsetDataView:=Nil;
    end else Raise Exception.Create('This TaskThread in TaskThreads is not found.');
  end;
end;

Function TDataCaseImplement.OnTaskThreadCheckPerpetualReady:Boolean;
  Var tmpIntIndex:Integer;
      tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
      tmpReady:Boolean;
      tmpSuspendedReadyITaskThread:ITaskThread;
      tmpITaskThreads:IVarset;
begin
  If (Now-FLastFindCheckPerpetualReady)>cnCheckPerpetualReadyInterval Then begin
    tmpITaskThreads:=FITaskThreads;
    If Assigned(tmpITaskThreads) Then begin
      tmpReady:=False;
      tmpSuspendedReadyITaskThread:=Nil;
      tmpIntIndex:=-1;
      //Поиск
      While true do begin
        tmpIVarsetDataView:=tmpITaskThreads.ITViewNextGetOfIntIndex(tmpIntIndex);
        If tmpIntIndex=-1 Then Break;
        tmpIUnknown:=tmpIVarsetDataView.ITData;
        If ITaskThread(tmpIUnknown).ITPerpetual Then begin
          If ITaskThread(tmpIUnknown).ITState=ttsReady Then begin
            If ITaskThread(tmpIUnknown).ITSuspended Then begin
              tmpSuspendedReadyITaskThread:=ITaskThread(tmpIUnknown);
            end else begin
              tmpSuspendedReadyITaskThread:=Nil;//Этот уже ненужен, т.к. есть хороший и не спящий.
              tmpReady:=True;
              Break;
            end;
          end;
        end;  
      end;
      //Отпускаю уже не нужные интерфейсы 
      tmpIVarsetDataView:=Nil;
      tmpIUnknown:=Nil;
      tmpITaskThreads:=Nil;
      //Разбираю результат поиска
      If tmpReady then begin
        //Есть хороший ready
        Result:=True;
      end else begin
        If Assigned(tmpSuspendedReadyITaskThread) then begin
          //Есть спящий ready
          tmpSuspendedReadyITaskThread.ITResume;
          tmpSuspendedReadyITaskThread:=Nil;
          Result:=True;
        end else begin
          //нет ready
          Result:=False;
        end;
      end;
    end else begin
      Result:=False;
    end;
    //..
    FLastFindCheckPerpetualReadyResult:=Result;
    FLastFindCheckPerpetualReady:=Now;
  end else begin
    Result:=FLastFindCheckPerpetualReadyResult;
  end;
end;

Procedure TDataCaseImplement.OnTaskStorageTaskPush(aTaskCount:Integer);
  Var tmpIntIndex:Integer;
      tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
      tmpReady:Boolean;
      tmpITaskThreads:IVarset;
      tmpITaskThread:ITaskThread;
begin
  If aTaskCount<cnMaxTaskCountInTaskStorage Then Exit;
  tmpITaskThreads:=FITaskThreads;
  If Not Assigned(tmpITaskThreads) Then Raise Exception.Create('TaskThreads is not assigned.');
  tmpIntIndex:=-1;
  tmpReady:=False;
  //Поиск
  While true do begin
    tmpIVarsetDataView:=tmpITaskThreads.ITViewNextGetOfIntIndex(tmpIntIndex);
    If tmpIntIndex=-1 Then Break;
    tmpIUnknown:=tmpIVarsetDataView.ITData;
    If ITaskThread(tmpIUnknown).ITState=ttsReady Then begin
      If ITaskThread(tmpIUnknown).ITSuspended Then ITaskThread(tmpIUnknown).ITResume;
      tmpReady:=True;
      Break;
    end;
    tmpIUnknown:=Nil;
  end;
  tmpIVarsetDataView:=Nil;
  //Обрабатываю результаты поиска
  If (Not tmpReady)And(tmpITaskThreads.ITCount<cnTaskThreadMaxCount) Then begin
    tmpITaskThread:=ITCreateTaskThread;
    If Assigned(tmpITaskThread) Then begin
      ITPushTaskThread(tmpITaskThread, False);
      tmpITaskThread.ITResume;
    end;
  end;
  //Принудительно разбираю интерфейсы
  tmpITaskThreads:=Nil;
end;

Function TDataCaseImplement.ITTaskThreadToIVarsetDataView(aITaskThread:ITaskThread):IVarsetDataView;
  Var tmpIVarsetDataView:IVarsetDataView;
      tmpIntIndex:Integer;
      tmpFound:Boolean;
      tmpIUnknown:IUnknown;
      tmpITaskThreads:IVarset;
begin
  tmpITaskThreads:=FITaskThreads;
  If Not Assigned(tmpITaskThreads) Then Raise Exception.Create('TaskThreads is not assigned.');
  tmpFound:=False;
  tmpIntIndex:=-1;
  While true do begin
    tmpIVarsetDataView:=tmpITaskThreads.ITViewNextGetOfIntIndex(tmpIntIndex);
    If tmpIntIndex=-1 Then Break;
    tmpIUnknown:=tmpIVarsetDataView.ITData;
    If ITaskThread(tmpIUnknown)=aITaskThread Then begin
      tmpFound:=True;
      Break;
    end;
  end;
  tmpIUnknown:=Nil;
  If tmpFound Then begin
    //Нашел в списке
    Result:=tmpIVarsetDataView;
  end else begin
    //Не нашел в списке
    Result:=Nil;
  end;
  //Принудительно освобождаю
  tmpITaskThreads:=Nil;
  tmpIVarsetDataView:=Nil;
end;

Procedure TDataCaseImplement.ITDestroyTaskThread(Var aTaskThread:ITaskThread);
begin
  If Assigned(aTaskThread) Then begin
    aTaskThread.ITTaskImplement:=Nil;
    aTaskThread.ITOnViewTask:=Nil;
    aTaskThread.ITOnInactivity:=Nil;
    aTaskThread.ITOnDestroy:=Nil;
    aTaskThread.ITOnTask:=Nil;
    aTaskThread.ITResume;
    aTaskThread:=Nil;
  end;
end;

Procedure TDataCaseImplement.ITPushTaskThread(aITaskThread:ITaskThread; aPerpetual:Boolean);
  Var tmpIVarsetData:IVarsetData;
      tmpITaskThreads:IVarset;
begin
  tmpITaskThreads:=FITaskThreads;
  If Not Assigned(tmpITaskThreads) Then Raise Exception.Create('TaskThreads is not assigned.');
  tmpIVarsetData:=TVarsetData.Create;
  //If aPerpetual Then tmpIVarsetData.ITStrIndex:='+'{Ставлю что обязательный} Else tmpIVarsetData.ITStrIndex:='';
  aITaskThread.ITPerpetual:=aPerpetual;
  tmpIVarsetData.ITData:=aITaskThread;
  tmpITaskThreads.ITPush(tmpIVarsetData);
  //Принудительно разбираю интерфейсы
  tmpIVarsetData:=Nil;
  tmpITaskThreads:=Nil;
end;

Function TDataCaseImplement.ITCreateTaskThread:ITaskThread;
begin
  Result:=TTaskThread.Create;
  Result.ITOnDestroy:=Nil;
  Result.ITOnTask:=Nil;
  Result.ITOnViewTask:=Self;
  Result.ITOnInactivity:=Self;
  Result.ITOnCheckPerpetualReady:=Self;
  Result.ITTaskImplement:=FITaskImplement;
  Result.ITInactivity:=cnInactivity;
  Result.ITOwnerCallerAction:=FOwnerCallerAction;
end;

end.
