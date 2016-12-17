unit UTaskThreadTypes;

interface
  Uses UTaskCallerTypes, UCallerTypes, UTaskTypes, UTaskImplementTypes, Windows, UTaskPathTypes;
Type
  TMateTerminate = ({0}trrNone, {1}trrNormal, {2}trrForced, {3}trrError);
  TState = ({0}stsReady, {1}stsUnderLoad, {2}stsBusy, {3}stsWait);
  TTaskThreadState=({0}ttsReady{Готов}, {1}ttsWork{выполняет задачу}, {2}ttsTerminated{завершен});

  ITaskThread=Interface;

  IOnTaskThreadDestroy=Interface
  ['{9B6FEBEC-9644-4C53-8309-28FB6A01F62E}']
    procedure OnTaskThreadDestroy(aTaskThread:ITaskThread);   //TOnDestroyEvent=procedure(aTaskThread:ITaskThread)of object;
  End;

  IOnTaskThreadViewTask=Interface
  ['{706B3D2D-D817-45B6-B01E-683786537E21}']
    Function OnTaskThreadViewTask:ITaskCaller;  //TOnTaskPopEvent=Function:ITaskCaller of object;
  end;

  IOnTaskThreadInactivity=Interface
  ['{77E73E8E-42E9-41A2-9B57-C01588659CD6}']
    procedure OnTaskThreadInactivity(aTaskThread:ITaskThread); //TOnInactivityEvent=procedure(aTaskThread:ITaskThread)of object;
  end;

  IOnTaskThreadTask=Interface
  ['{2563876C-84A5-4EFE-8BAA-896932E895EE}']
    Procedure OnTaskThreadTask(aTaskPath:ITaskPath); //TOnTaskEvent=Procedure(aTaskCaller:ITaskCaller)of object;
  end;

  IOnTaskThreadCheckPerpetualReady=Interface
  ['{F21A7D63-CA4D-4696-80D4-974E648DF1A3}']
    Function OnTaskThreadCheckPerpetualReady:Boolean;
  End;

  ITaskThread=Interface
  ['{D9B8441F-5ED1-4CFA-99FC-E478D54DEE4C}']
    function IT_GetOnDestroy:IOnTaskThreadDestroy;
    procedure IT_SetOnDestroy(aOnDestroy:IOnTaskThreadDestroy);
    function IT_GetState:TTaskThreadState;
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
    //..                                                                                  //Function ITTaskExecute(aTaskCaller:ITaskCaller):Boolean;
    Procedure ITSuspend;
    Function ITSuspended:Boolean;
    Procedure ITResume;
    Property ITState:TTaskThreadState read IT_GetState;
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

  Function TaskThreadStateToStr(aTaskThreadState:TTaskThreadState):AnsiString;

implementation
  Uses Sysutils;

Function TaskThreadStateToStr(aTaskThreadState:TTaskThreadState):AnsiString;
begin
  Case aTaskThreadState of
    ttsReady:Result:='Ready';
    ttsWork:Result:='Work';
    ttsTerminated:Result:='Terminated';
  else
    Result:='Unknown('+IntToStr(Integer(aTaskThreadState))+')';
  end;
end;

end.
