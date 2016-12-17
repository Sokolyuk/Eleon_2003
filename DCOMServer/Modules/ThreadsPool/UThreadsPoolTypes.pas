//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UThreadsPoolTypes;

interface
  uses UTTaskTypes, UDataCaseExecProcTypes, UMThreadTypes, UCallerTypes, UCallerTaskTypes, UTaskImplementTypes{$IFDEF VER130}, UVer130Types{$ENDIF};

type
  TDataCaseResultEvent=(dreThreadBreak, dreThreadUnusedTimeout);
  IThreadsPool=interface ['{576B7B94-704D-4345-8E2C-3C6A1B77FD71}']//Task array
    procedure ITMTaskAdd(aTask:TTask; const aParams:Variant; const aSenderParams, aSenderSecurityContext:Variant; aTaskNumbered:Integer; aPTaskID:PInteger);overload;
    procedure ITMTaskAdd(aTask:TTask; const aParams:Variant; const aSenderParams, aSenderSecurityContext:Variant);overload;
    procedure ITMTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aTaskNumbered:Integer; aPTaskID:PInteger);overload;
    procedure ITMTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction);overload;
    procedure ITMSleepTaskAdd(aTask:TTask; const aParams:Variant; const aSenderParams, aSenderSecurityContext:Variant; aSleep:LongWord);overload;
    procedure ITMSleepTaskAdd(aTask:TTask; const aParams:Variant; const aSenderParams, aSenderSecurityContext:Variant; aSleep:LongWord; aTaskNumbered:Integer; aPTaskID:PInteger);overload;
    procedure ITMSleepTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aSleep:LongWord);overload;
    procedure ITMSleepTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aSleep:LongWord; aTaskNumbered:Integer; aPTaskID:PInteger);overload;
    procedure ITMWakeUpTaskAdd(aTask:TTask; const aParams:Variant; const aSenderParams, aSenderSecurityContext:Variant; aWakeup:TDateTime);overload;
    procedure ITMWakeUpTaskAdd(aTask:TTask; const aParams:Variant; const aSenderParams, aSenderSecurityContext:Variant; aWakeup:TDateTime; aTaskNumbered:Integer; aPTaskID:PInteger);overload;
    procedure ITMWakeUpTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aWakeup:TDateTime);overload;
    procedure ITMWakeUpTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aWakeup:TDateTime; aTaskNumbered:Integer; aPTaskID:PInteger);overload;
    //..
    procedure ITMTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aCallerTask:ICallerTask; aEndTaskEventI:IEndTaskEvent; aEndTaskEvent:PEndTaskEvent);overload;
    procedure ITMSleepTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aSleep:LongWord; aCallerTask:ICallerTask; aEndTaskEventI:IEndTaskEvent; aEndTaskEvent:PEndTaskEvent);overload;
    procedure ITMWakeUpTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aWakeup:TDateTime; aCallerTask:ICallerTask; aEndTaskEventI:IEndTaskEvent; aEndTaskEvent:PEndTaskEvent);overload;
    function ITMIgnoreTaskCheck(aTask:TTask):Boolean;
    function ITMTaskCancel(aTaskID:Integer):Boolean;
    procedure ITMIgnoreTaskAdd(aTask:TTask);
    function ITMIgnoreTaskCancel(aTask:TTask):Boolean;
    //Info of task array
    function ITMTask:Variant;
    function ITMSleepTask:Variant;
    function ITMTaskIgnore:Variant;
    //Threads list(MArray)
    function ITMArray:Variant;
    procedure ITNLForceGetReadyM;
    //function ITGetMCount:Integer;
    //IWaitForExecuteTask
    function Get_MCountReady:PInteger;
    function Get_MCountWait:PInteger;
    function Get_MCountPerpetualReady:PInteger;
    function Get_MCount:PInteger;
    function Get_MCountPerpetual:PInteger;
    function Get_MNumberedMap:PInteger;
    function Get_MNumberedMapReady:PInteger;
    function Get_MCountDuringCreating:PInteger;
    property MCountReady:PInteger read Get_MCountReady;//Количество свободных потоков
    property MCountWait:PInteger read Get_MCountWait;//Количество Wait потоков
    property MCountPerpetualReady:PInteger read Get_MCountPerpetualReady;//Количество основных свободных потоков
    property MCount:PInteger read Get_MCount;//Зарегистрированных
    property MCountPerpetual:PInteger read Get_MCountPerpetual;//Зарегистрировано постоянных
    property MCountDuringCreating:PInteger read Get_MCountDuringCreating;//В процессе создания
    property MNumberedMap:PInteger read Get_MNumberedMap;
    property MNumberedMapReady:PInteger read Get_MNumberedMapReady;//Карта потоков/Ready-потоков
    function WaitForExecuteTask(aMThread:IMThread):TDataCaseResultEvent;
    function ITNLExecProcThread(aExecThreadStruct:PExecThreadStruct; aRaise:Boolean):Boolean;
    function ITDropMThread(aMThread:IMThread):boolean;
    procedure ITRegMThread(aMThread:IMThread; aMNumber:PInteger);
    function Get_MPerpetualCount:Integer;
    procedure Set_MPerpetualCount(value:Integer);
    property MPerpetualCount:Integer read Get_MPerpetualCount write Set_MPerpetualCount;
    function Get_MMaxCount:Integer;
    procedure Set_MMaxCount(value:Integer);
    property MMaxCount:Integer read Get_MMaxCount write Set_MMaxCount;
  end;

implementation

end.
