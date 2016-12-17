unit UTaskThread;

interface
  Uses Classes, Windows, UVarset, UTaskCallerTypes, UCaller, UCallerTypes, UTaskImplementTypes,
       UTaskThreadTypes, UTaskPathTypes;
Type
  TTaskThread=class(TThread, IUnknown, ITaskThread)
  private
    CSLock:TRTLCriticalSection;
    FRefCount:Integer;
    FState:TTaskThreadState;
    FSuspend:Boolean;
    FIOwnerCallerAction:ICallerAction;
    FInactivity:Cardinal;
    FITaskImplement:ITaskImplement;
    FCreateDateTime:TDateTime;
    FIOnTaskThreadDestroy:IOnTaskThreadDestroy;
    FIOnTaskThreadViewTask:IOnTaskThreadViewTask;
    FIOnTaskThreadInactivity:IOnTaskThreadInactivity;
    FIOnTaskThreadTask:IOnTaskThreadTask;
    FIOnTaskThreadCheckPerpetualReady:IOnTaskThreadCheckPerpetualReady;
    FInactivityValue:Cardinal;
    FPerpetual:Boolean;
    FNoSuspend:Boolean;
    FtmpIOnTaskThreadTask:IOnTaskThreadTask;
    FtmpITaskImplement:ITaskImplement;
    Procedure InternalLock;
    Procedure InternalUnLock;                                                             //Function ITPopTaskExecute:ITaskCaller;
{$Hints Off}
    //Лучше эти методы на прямую не вызывать, т.к. все расчитано на много потоковую работу через интерфейс 'ITaskThread'.
    procedure Terminate; reintroduce;
    procedure Resume; reintroduce;
    procedure Suspend; reintroduce;
    property FreeOnTerminate;
    property Suspended;
{$Hints On}
  protected
    procedure Execute; reintroduce; override;
    Procedure InternalExecuteTask(aRecursionCount:Integer; aCurrTaskCaller:ITaskCaller; aPrevTaskPath:ITaskPath); Virtual;
    Procedure InternalTask(Const aTaskPath:ITaskPath);Virtual;
    function _AddRef: Integer; virtual; stdcall;
    function _Release: Integer; virtual; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
    //..
    function IT_GetOnDestroy:IOnTaskThreadDestroy;
    procedure IT_SetOnDestroy(aOnDestroy:IOnTaskThreadDestroy);
    function IT_GetState:TTaskThreadState;
    procedure IT_SetState(aState:TTaskThreadState);
    function IT_GetOwnerCallerAction:ICallerAction;
    procedure IT_SetOwnerCallerAction(Value:ICallerAction);
    function IT_GetOnViewTask:IOnTaskThreadViewTask;
    procedure IT_SetOnViewTask(Value:IOnTaskThreadViewTask);
    function IT_GetInactivity:Cardinal;
    procedure IT_SetInactivity(Value:Cardinal);
    function IT_GetOnInactivity:IOnTaskThreadInactivity;
    procedure IT_SetOnInactivity(Value:IOnTaskThreadInactivity);
    function IT_GetOnTask:IOnTaskThreadTask;
    procedure IT_SetOnTask(Value:IOnTaskThreadTask);
    function IT_GetTaskImplement:ITaskImplement;
    procedure IT_SetTaskImplement(Value:ITaskImplement);
    function IT_GetInactivityValue:Cardinal;
    function IT_GetThreadID:THandle;
    function IT_GetPerpetual:Boolean;
    procedure IT_SetPerpetual(Value:Boolean);
    function IT_GetNoSuspend:Boolean;
    procedure IT_SetNoSuspend(Value:Boolean);
    function IT_GetOnCheckPerpetualReady:IOnTaskThreadCheckPerpetualReady;
    procedure IT_SetOnCheckPerpetualReady(Value:IOnTaskThreadCheckPerpetualReady);
  public
    constructor Create;
    destructor Destroy; override;
    Procedure ITSuspend;
    Function ITSuspended:Boolean;
    Procedure ITResume;                                                                   //Function ITTaskExecute(aTaskCaller:ITaskCaller):Boolean;
    Property ITState:TTaskThreadState read IT_GetState Write IT_SetState;
    Property ITOwnerCallerAction:ICallerAction Read IT_GetOwnerCallerAction Write IT_SetOwnerCallerAction;
    Property ITTaskImplement:ITaskImplement read IT_GetTaskImplement write IT_SetTaskImplement;
    Property ITInactivity:Cardinal read IT_GetInactivity write IT_SetInactivity;
    Property ITInactivityValue:Cardinal read IT_GetInactivityValue;
    Property ITThreadID:THandle read IT_GetThreadID;
    Property ITPerpetual:Boolean read IT_GetPerpetual write IT_SetPerpetual;
    Property ITNoSuspend:Boolean read IT_GetNoSuspend write IT_SetNoSuspend;
    Property ITOnDestroy:IOnTaskThreadDestroy read IT_GetOnDestroy write IT_SetOnDestroy;
    Property ITOnViewTask:IOnTaskThreadViewTask Read IT_GetOnViewTask Write IT_SetOnViewTask;
    Property ITOnInactivity:IOnTaskThreadInactivity read IT_GetOnInactivity write IT_SetOnInactivity;
    Property ITOnTask:IOnTaskThreadTask read IT_GetOnTask write IT_SetOnTask;
    Property ITOnCheckPerpetualReady:IOnTaskThreadCheckPerpetualReady read IT_GetOnCheckPerpetualReady write IT_SetOnCheckPerpetualReady;
  end;

implementation
  Uses Sysutils, UTaskTypes, UTypes, UTTaskType, ULogFileTypes, ULogFileConsts, UTaskPath;

Constructor TTaskThread.Create;
begin
  InitializeCriticalSection(CSLock);
  FRefCount:=0;
  FInactivityValue:=0;
  FInactivity:=60000{default=1min};
  FreeOnTerminate:=True;
  FState:=ttsWork;
  FIOwnerCallerAction:=Nil;
  FIOnTaskThreadDestroy:=Nil;
  FIOnTaskThreadViewTask:=Nil;
  FIOnTaskThreadInactivity:=Nil;
  FIOnTaskThreadTask:=Nil;
  FIOnTaskThreadCheckPerpetualReady:=Nil;
  FSuspend:=False;
  FCreateDateTime:=Now;
  FITaskImplement:=Nil;
  FtmpIOnTaskThreadTask:=Nil;
  FtmpITaskImplement:=Nil;
  FPerpetual:=False;
  FNoSuspend:=False;
  Inherited Create(True);
end;

Destructor TTaskThread.Destroy;
  Var tmpIOwnerCallerAction:ICallerAction;
      tmpIOnTaskThreadDestroy:IOnTaskThreadDestroy;
begin
  try
    tmpIOnTaskThreadDestroy:=FIOnTaskThreadDestroy;
    If Assigned(tmpIOnTaskThreadDestroy) Then begin
      try
        tmpIOnTaskThreadDestroy.OnTaskThreadDestroy(Self);
      except end;
      tmpIOnTaskThreadDestroy:=Nil;
    end;
    FtmpIOnTaskThreadTask:=Nil;
    FtmpITaskImplement:=Nil;
    FIOnTaskThreadDestroy:=Nil;
    FIOnTaskThreadViewTask:=Nil;
    FIOnTaskThreadInactivity:=Nil;
    FIOnTaskThreadTask:=Nil;
    FIOnTaskThreadCheckPerpetualReady:=Nil;
    Try
      tmpIOwnerCallerAction:=FIOwnerCallerAction;
      If (FRefCount>0)And(Assigned(tmpIOwnerCallerAction)) Then begin
        tmpIOwnerCallerAction.ITMessAdd(Now, FCreateDateTime, Self, 'TTaskThread', 'FRefCount('+IntToStr(FRefCount)+')<1', mecApp, mesWarning);
        tmpIOwnerCallerAction:=Nil;
      end;
    Except end;
    FIOwnerCallerAction:=Nil;
    FITaskImplement:=Nil;
  Except end;
  DeleteCriticalSection(CSLock);
  Inherited Destroy;
end;

{TTaskThread.IUnknown}
function TTaskThread.QueryInterface(const IID:TGUID; out Obj):HResult;
begin
  if GetInterface(IID, Obj) then Result:=S_OK else Result:=E_NOINTERFACE;
end;

function TTaskThread._AddRef:Integer;
begin
  Result:=InterLockedIncrement(FRefCount);
end;

function TTaskThread._Release:Integer;
begin
  Result:=InterLockedDecrement(FRefCount);
  if Result=0 then begin
    ITResume;
    Inherited Terminate;
  end;
end;

{TTaskThread.Lock}
Procedure TTaskThread.InternalLock;
  Var iTimeOut:Integer;
begin
  iTimeOut:=0;
  While Not TryEnterCriticalSection(CSLock) do begin
    inc(iTimeOut);
    If iTimeOut>(900000 div 133) then begin {15мин}
      // не разлочился
      Raise Exception.Create('TTaskThread.InternalLock(CSLock.LockCount='+IntToStr(CSLock.LockCount)+', CSLock.OwningThread='+IntToStr(CSLock.OwningThread)+').');
    end;
    sleep(133);
  end;
end;

Procedure TTaskThread.InternalUnLock;
begin
  LeaveCriticalSection(CSLock);
end;

procedure TTaskThread.Terminate;
begin
  Raise Exception.Create('Method ''Terminate'' not used.');
end;

procedure TTaskThread.Resume;
begin
  Raise Exception.Create('Method ''Resume'' not used.');
end;

procedure TTaskThread.Suspend;
begin
  Raise Exception.Create('Method ''Suspend'' not used.');
end;  

//****************************************************************************************
function TTaskThread.IT_GetOnDestroy:IOnTaskThreadDestroy;
begin
  InternalLock;
  try
    Result:=FIOnTaskThreadDestroy;
  finally
    InternalUnLock;
  end;
end;

procedure TTaskThread.IT_SetOnDestroy(aOnDestroy:IOnTaskThreadDestroy);
begin
  InternalLock;
  try
    FIOnTaskThreadDestroy:=aOnDestroy;
  finally
    InternalUnLock;
  end;
end;

function TTaskThread.IT_GetState:TTaskThreadState;
begin
  InternalLock;
  try
    Result:=FState;
  finally
    InternalUnLock;
  end;
end;

procedure TTaskThread.IT_SetState(aState:TTaskThreadState);
begin
  InternalLock;
  try
    FState:=aState;
  finally
    InternalUnLock;
  end;
end;

{Function TTaskThread.ITTaskExecute(aTaskCaller:ITaskCaller):Boolean;
begin
  InternalLock;
  try
    If (Assigned(FTaskExecuteCaller))Or(ITState<>ttsReady)Or(Terminated) Then begin
      Result:=False;
    end else begin
      FTaskExecuteCaller:=aTaskCaller;
      Result:=True;
    end;
  finally
    InternalUnLock;
  end;
end;

Function TTaskThread.ITPopTaskExecute:ITaskCaller;
begin
  InternalLock;
  try
    Result:=FTaskExecuteCaller;
    FTaskExecuteCaller:=Nil;
  finally
    InternalUnLock;
  end;
end;}

function TTaskThread.IT_GetOwnerCallerAction:ICallerAction;
begin
  InternalLock;
  try
    Result:=FIOwnerCallerAction;
  finally
    InternalUnLock;
  end;
end;

procedure TTaskThread.IT_SetOwnerCallerAction(Value:ICallerAction);
begin
  InternalLock;
  try
    FIOwnerCallerAction:=Value;
  finally
    InternalUnLock;
  end;
end;

Procedure TTaskThread.ITSuspend;
begin
  InternalLock;
  try
    FSuspend:=True;
  finally
    InternalUnLock;
  end;
end;

Function TTaskThread.ITSuspended:Boolean;
begin
  InternalLock;
  try
    Result:=Suspended Or FSuspend;
  finally
    InternalUnLock;
  end;
end;

Procedure TTaskThread.ITResume;
begin
  InternalLock;
  try
    FSuspend:=False;
    Inherited Resume;
  finally
    InternalUnLock;
  end;
end;

function TTaskThread.IT_GetOnViewTask:IOnTaskThreadViewTask;
begin
  InternalLock;
  try
    Result:=FIOnTaskThreadViewTask;
  finally
    InternalUnLock;
  end;
end;

procedure TTaskThread.IT_SetOnViewTask(Value:IOnTaskThreadViewTask);
begin
  InternalLock;
  try
    FIOnTaskThreadViewTask:=Value;
  finally
    InternalUnLock;
  end;
end;

function TTaskThread.IT_GetInactivity:Cardinal;
begin
  InternalLock;
  try
    Result:=FInactivity;
  finally
    InternalUnLock;
  end;
end;

procedure TTaskThread.IT_SetInactivity(Value:Cardinal);
begin
  InternalLock;
  try
    FInactivity:=Value;
  finally
    InternalUnLock;
  end;
end;

function TTaskThread.IT_GetOnInactivity:IOnTaskThreadInactivity;
begin
  InternalLock;
  try
    Result:=FIOnTaskThreadInactivity;
  finally
    InternalUnLock;
  end;
end;

procedure TTaskThread.IT_SetOnInactivity(Value:IOnTaskThreadInactivity);
begin
  InternalLock;
  try
    FIOnTaskThreadInactivity:=Value;
  finally
    InternalUnLock;
  end;
end;

function TTaskThread.IT_GetOnTask:IOnTaskThreadTask;
begin
  InternalLock;
  try
    Result:=FIOnTaskThreadTask;
  finally
    InternalUnLock;
  end;
end;

procedure TTaskThread.IT_SetOnTask(Value:IOnTaskThreadTask);
begin
  InternalLock;
  try
    FIOnTaskThreadTask:=Value;
  finally
    InternalUnLock;
  end;
end;

function TTaskThread.IT_GetTaskImplement:ITaskImplement;
begin
  InternalLock;
  try
    Result:=FITaskImplement;
  finally
    InternalUnLock;
  end;
end;

procedure TTaskThread.IT_SetTaskImplement(Value:ITaskImplement);
begin
  InternalLock;
  try
    FITaskImplement:=Value;
  finally
    InternalUnLock;
  end;
end;

function TTaskThread.IT_GetInactivityValue:Cardinal;
begin
  Result:=FInactivityValue;
end;

function TTaskThread.IT_GetThreadID:THandle;
begin
  Result:=ThreadID;
end;

function TTaskThread.IT_GetPerpetual:Boolean;
begin
  InternalLock;
  try
    Result:=FPerpetual;
  finally
    InternalUnLock;
  end;
end;

procedure TTaskThread.IT_SetPerpetual(Value:Boolean);
begin
  InternalLock;
  try
    FPerpetual:=Value;
  finally
    InternalUnLock;
  end;
end;

function TTaskThread.IT_GetNoSuspend:Boolean;
begin
  InternalLock;
  try
    Result:=FNoSuspend;
  finally
    InternalUnLock;
  end;
end;

procedure TTaskThread.IT_SetNoSuspend(Value:Boolean);
begin
  InternalLock;
  try
    FNoSuspend:=Value;
  finally
    InternalUnLock;
  end;
end;

function TTaskThread.IT_GetOnCheckPerpetualReady:IOnTaskThreadCheckPerpetualReady;
begin
  InternalLock;
  try
    Result:=FIOnTaskThreadCheckPerpetualReady;
  finally
    InternalUnLock;
  end;
end;

procedure TTaskThread.IT_SetOnCheckPerpetualReady(Value:IOnTaskThreadCheckPerpetualReady);
begin
  InternalLock;
  try
    FIOnTaskThreadCheckPerpetualReady:=Value;
  finally
    InternalUnLock;
  end;
end;

//****************************************************************************************
Procedure TTaskThread.InternalTask(Const aTaskPath:ITaskPath);
begin
  If Not Assigned(aTaskPath) Then Raise Exception.Create('TaskCaller is not assigned.');
  If Not Assigned(aTaskPath.CurrTaskCaller) Then exit;
  If aTaskPath.CurrTaskCaller.ITCanceled Then begin
    aTaskPath.CurrTaskCaller.ITStatus:=tssCanceled;
    Exit;
  end;
  Raise Exception.Create('Unknown task '''+TaskToStr(aTaskPath.CurrTaskCaller.ITTask)+'''.');
end;

Procedure TTaskThread.InternalExecuteTask(aRecursionCount:Integer; aCurrTaskCaller:ITaskCaller; aPrevTaskPath:ITaskPath);
  Var tmpTaskPath:ITaskPath;
      tmpIOwnerCallerAction:ICallerAction;
      tmpLogFile:ILogFile;
      tmpNow:TDateTime;
begin
  If Not Assigned(aCurrTaskCaller) Then Exit;
  If aRecursionCount>50 Then Raise Exception.Create('aRecursionCount>50');
  tmpTaskPath:=TTaskPath.Create;
  try
    tmpTaskPath.CurrTaskCaller:=aCurrTaskCaller;
    tmpTaskPath.PrevTaskPath:=aPrevTaskPath;
    tmpNow:=Now;
    //-CheckSecurity- aCurrTaskCaller.ITTask
    aCurrTaskCaller.ITStatus:=tssExecute;
    Try
      If Assigned(FtmpIOnTaskThreadTask) Then begin//отработчик через событие назначен
        FtmpIOnTaskThreadTask.OnTaskThreadTask(tmpTaskPath);
      end Else begin//отработчик через событие не назначен
        If Assigned(FtmpITaskImplement) Then begin
          FtmpITaskImplement.Task(tmpTaskPath);
        end Else InternalTask(tmpTaskPath);
      end;
      aCurrTaskCaller.ITStatus:=tssComplete;
      InternalExecuteTask(aRecursionCount+1, aCurrTaskCaller.ITNextBlockTask, tmpTaskPath);
    except
      on e:exception do begin
        try
          aCurrTaskCaller.ITResultErrorMessage:='Execute task '''+TaskToStr(aCurrTaskCaller.ITTask)+''': '+E.Message;
          aCurrTaskCaller.ITResultErrorHelpContext:=E.HelpContext;
          aCurrTaskCaller.ITStatus:=tssError;
          //..
          tmpIOwnerCallerAction:=FIOwnerCallerAction;
          tmpLogFile:=GL_LogFile;
          If Assigned(tmpLogFile) Then tmpLogFile.ITWriteLnToLog('Error (TaskThread.Execute): '''+E.Message+'''.');
          If Assigned(tmpIOwnerCallerAction) Then begin
            tmpIOwnerCallerAction.ITMessAdd(Now, tmpNow, Self, 'TTaskThread', 'Execute task '''+TaskToStr(aCurrTaskCaller.ITTask)+''': '+E.Message, mecApp, mesError);
            tmpIOwnerCallerAction:=Nil;
          end;
        except
          On E:Exception do begin E.Message:='Error in TASK EXCEPT: '+E.Message; Raise; end;
        end;
        //..
        InternalExecuteTask(aRecursionCount+1, aCurrTaskCaller.ITExceptTask, tmpTaskPath);
      end;
    end;
    InternalExecuteTask(aRecursionCount+1, aCurrTaskCaller.ITNextTask, tmpTaskPath);
  finally
    tmpTaskPath:=Nil;
  end;
end;

procedure TTaskThread.Execute;
  Var tmpTaskCaller:ITaskCaller;
      tmpIOwnerCallerAction:ICallerAction;
      tmpIOnTaskThreadViewTask:IOnTaskThreadViewTask;
      tmpIOnTaskThreadInactivity:IOnTaskThreadInactivity;
      tmpDoViewTask:Boolean;
      tmpIOnTaskThreadCheckPerpetualReady:IOnTaskThreadCheckPerpetualReady;
      tmpLogFile:ILogFile;
      tmpNow:TDateTime;
begin
  Try
    //ITState:=ttsReady;
    FInactivityValue:=0;
    tmpNow:=Now;
    While Not Terminated do begin
      Try
        ITState:=ttsReady;
        //tmpTaskCaller:=Nil;
        tmpIOnTaskThreadViewTask:=FIOnTaskThreadViewTask;
        If Assigned(tmpIOnTaskThreadViewTask) Then begin//есть ViewTask
          tmpDoViewTask:=True;//надо смотреть
          If Not FPerpetual Then begin//этот поток дополнительный
            tmpIOnTaskThreadCheckPerpetualReady:=FIOnTaskThreadCheckPerpetualReady;//беру интерфейс ready-провеки основных потоков
            if Assigned(tmpIOnTaskThreadCheckPerpetualReady) Then begin//интерфейс есть
              tmpDoViewTask:=Not tmpIOnTaskThreadCheckPerpetualReady.OnTaskThreadCheckPerpetualReady;//проверяю занятость основных потоков
              tmpIOnTaskThreadCheckPerpetualReady:=Nil;//отпускаю интерфейс
            end;
          end;
          If tmpDoViewTask Then tmpTaskCaller:=tmpIOnTaskThreadViewTask.OnTaskThreadViewTask else tmpTaskCaller:=Nil;//смотрю задачу, если нужно
          tmpIOnTaskThreadViewTask:=Nil;
        end;
        If Assigned(tmpTaskCaller) Then begin//есть задача
          ITState:=ttsWork;
          tmpNow:=Now;
          FtmpIOnTaskThreadTask:=FIOnTaskThreadTask;//Беру отработчик через событие, у него больший приоритет
          FtmpITaskImplement:=FITaskImplement;//беру основной отработчик
          try
            InternalExecuteTask(0, tmpTaskCaller, Nil);
          finally
            FtmpITaskImplement:=Nil;
            FtmpIOnTaskThreadTask:=Nil; tmpTaskCaller:=nil;
          end;
          FInactivityValue:=0;//сбрасываю счетчик бездействия
        end else begin//нет задачи, бездействие(Inactivity)
          Inc(FInactivityValue, 33);
          If FInactivityValue>=FInactivity Then begin
            tmpIOnTaskThreadInactivity:=FIOnTaskThreadInactivity;
            If Assigned(tmpIOnTaskThreadInactivity) Then begin
              tmpIOnTaskThreadInactivity.OnTaskThreadInactivity(Self);
              FInactivityValue:=0;
            end;
          end;
          If FSuspend Then begin
            If Not FNoSuspend Then Inherited Suspend;
            FSuspend:=False;
          end;
          Sleep(33);
        end;
      except
        On E:Exception do begin
          tmpIOwnerCallerAction:=FIOwnerCallerAction;
          If Assigned(tmpIOwnerCallerAction) Then begin
            tmpIOwnerCallerAction.ITMessAdd(Now, tmpNow, Self, 'TTaskThread', 'Execute: HC='+IntToStr(E.HelpContext)+' '+E.Message, mecApp, mesError);
            tmpIOwnerCallerAction:=Nil;
          end;
          Sleep(100);
        end;
      end;
    end;
  finally
    ITState:=ttsTerminated;
    tmpLogFile:=Nil;
  end;
end;

end.

