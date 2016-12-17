//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UThreadsPool;

interface
  uses UThreadsPoolTypes, UTTaskTypes, UDataCaseExecProcTypes, UTrayInterfaceTypes, UMThread, UMThreadTypes, UCallerTypes,
       UVarsetTypes, ExtCtrls, UAppMessageTypes, UTaskImplementTypes, UTrayTypes, UCallerTaskTypes, windows, UTrayInterface
       {$IFDEF VER130}, UVer130Types{$ENDIF};
type
  TThreadsPool=class(TTrayInterface, IThreadsPool)
  protected
    FMCountReady, FMCountWait, FMCountDuringCreating:Integer;//Количество свободных потоков
    FMCountPerpetualReady:Integer;//Количество основных свободных потоков
    FMCount:Integer;//Зарегистрированных
    FMCountPerpetual:Integer;//Количество основных свободных потоков
    FMCountWakeupTask, FTHForMCountWakeupTask:Integer;
    FMCountExecProcThread, FTHForMCountExecProcThread:Integer;
    FMCountNewTask, FTHForMCountNewTask:Integer;//{FMCountExecProcThread, }FMCountWakeupTask{, FMCountNewTask}:Integer;//счетчик количества запросов на ExecProcThread/NewTask/Wakeup
    FMNumberedMap, FMNumberedMapReady:Integer;//Карта потоков/Ready-потоков
    FMPerpetualCount, FMMaxCount:Integer;
    FVSMTasks, FVSMSleepTasks:IVarset;
    FTaskCount:Integer;
    FMArray, FMIgnoreTask:Variant;
    FFAppMessage:IAppMessage;
  protected
    FExecProcThread:IVarset;
    FEvents:array[0..3] of THandle;
    FWakeupTimer:TTimer;
  protected
    FNextTimeWakeup:TDateTime;//для обтимизации и исключения повторного назначения времени Wakeup
  protected
    FTaskImplement:ITaskImplement;
  protected
    function InternalGetInitGUIDCount:Cardinal;override;
    procedure InternalInitGUIDList;override;
    function GetFAppMessage:IAppMessage;virtual;
    procedure InternalSetMessage(aStartTime:TDateTime; const aMessage:AnsiString; aMec:TMessageClass; aMes:TMessageStyle);virtual;
    function InternalGetWaitMessage(aWait:cardinal):AnsiString;virtual;
  protected
    property FAppMessage:IAppMessage read GetFAppMessage;
    procedure InternalInit;override;
    procedure InternalStart;override;
    procedure InternalStop;override;
    procedure InternalFinal;override;
    procedure InternalMTaskAdd(aTask:TTask; aCallerAction:ICallerAction; const aParams:Variant; {const aSenderParams, aSenderSecurityContext:Variant;} aTaskNumbered:Integer; aPTaskID:PInteger);virtual;
    procedure InternalMTaskAddWithCallerTask(aTask:TTask; aCallerAction:ICallerAction; const aParams:Variant; aCallerTask:ICallerTask; aEndTaskEventI:IEndTaskEvent; aEndTaskEvent:PEndTaskEvent; aTaskNumbered:Integer; aPTaskID:PInteger);virtual;
    procedure InternalMSleepTaskAdd(aTask:TTask; aCallerAction:ICallerAction; const aParams:Variant; {const aSenderParams, aSenderSecurityContext:Variant;} aWakeup:TDateTime; aTaskNumbered:Integer; aPTaskID:PInteger);virtual;
    procedure InternalMSleepTaskAddWithCallerTask(aTask:TTask; aCallerAction:ICallerAction; const aParams:Variant; aWakeup:TDateTime; aCallerTask:ICallerTask; aEndTaskEventI:IEndTaskEvent; aEndTaskEvent:PEndTaskEvent; aTaskNumbered:Integer; aPTaskID:PInteger);virtual;
    function InternalDropMThread(aMThread:IMThread):boolean;virtual;
    //function InternalGetMCount:Integer;virtual;
    procedure ITNLCreateMThread(aPerpetual:Boolean);virtual;
    procedure InternalNLCreateMThread(aPerpetual:Boolean);virtual;
    function InternalMIgnoreTaskCheck(aTask:TTask):Boolean;virtual;
    function Get_MCountReady:PInteger;virtual;
    function Get_MCountWait:PInteger;virtual;
    function Get_MCountDuringCreating:PInteger;virtual;
    function Get_MCountPerpetualReady:PInteger;virtual;
    function Get_MCount:PInteger;virtual;
    function Get_MCountPerpetual:PInteger;virtual;
    function Get_MNumberedMap:PInteger;virtual;
    function Get_MNumberedMapReady:PInteger;virtual;
    //function ITGetMCount:Integer;virtual;
    function InternalShotDown:boolean;virtual;
    function InternalUserName:AnsiString;virtual;
  protected
    procedure InternalOnWakeup(Sender:TObject);
    procedure InternalSetNextTimeWakeup(aNextTimeWakeup:TDateTime);
  protected
    function ITExecProcThreadForThread:PExecThreadStruct;virtual;
    procedure ITExecProcThreadForThreadImpl(aExecThreadStruct:PExecThreadStruct);virtual;
    function ITDropPerpetualMThread(aCount:integer):boolean;virtual;
  public
    constructor create(aMPerpetualCount, aMMaxCount:Integer);
    destructor destroy;override;
    procedure ITMTaskAdd(aTask:TTask; const aParams:Variant; const aSenderParams, aSenderSecurityContext:Variant; aTaskNumbered:Integer; aPTaskID:PInteger);overload;virtual;
    procedure ITMTaskAdd(aTask:TTask; const aParams:Variant; const aSenderParams, aSenderSecurityContext:Variant);overload;virtual;
    procedure ITMTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aTaskNumbered:Integer; aPTaskID:PInteger);overload;virtual;
    procedure ITMTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction);overload;virtual;
    procedure ITMSleepTaskAdd(aTask:TTask; const aParams:Variant; const aSenderParams, aSenderSecurityContext:Variant; aSleep:LongWord);overload;virtual;
    procedure ITMSleepTaskAdd(aTask:TTask; const aParams:Variant; const aSenderParams, aSenderSecurityContext:Variant; aSleep:LongWord; aTaskNumbered:Integer; aPTaskID:PInteger);overload;virtual;
    procedure ITMSleepTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aSleep:LongWord);overload;virtual;
    procedure ITMSleepTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aSleep:LongWord; aTaskNumbered:Integer; aPTaskID:PInteger);overload;virtual;
    procedure ITMWakeUpTaskAdd(aTask:TTask; const aParams:Variant; const aSenderParams, aSenderSecurityContext:Variant; aWakeup:TDateTime);overload;virtual;
    procedure ITMWakeUpTaskAdd(aTask:TTask; const aParams:Variant; const aSenderParams, aSenderSecurityContext:Variant; aWakeup:TDateTime; aTaskNumbered:Integer; aPTaskID:PInteger);overload;virtual;
    procedure ITMWakeUpTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aWakeup:TDateTime);overload;virtual;
    procedure ITMWakeUpTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aWakeup:TDateTime; aTaskNumbered:Integer; aPTaskID:PInteger);overload;virtual;
    procedure ITMTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aCallerTask:ICallerTask; aEndTaskEventI:IEndTaskEvent; aEndTaskEvent:PEndTaskEvent);overload;
    procedure ITMSleepTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aSleep:LongWord; aCallerTask:ICallerTask; aEndTaskEventI:IEndTaskEvent; aEndTaskEvent:PEndTaskEvent);overload;
    procedure ITMWakeUpTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aWakeup:TDateTime; aCallerTask:ICallerTask; aEndTaskEventI:IEndTaskEvent; aEndTaskEvent:PEndTaskEvent);overload;
    function ITMTaskView(aParams:PVariant; out aCallerAction:ICallerAction; out aCallerTask:ICallerTask; out aEndTaskEventI:IEndTaskEvent; aEndTaskEvent:PEndTaskEvent; aTaskID:PInteger):TTask;virtual;
    function ITMSleepTaskView(aParams:PVariant; out aCallerAction:ICallerAction; out aCallerTask:ICallerTask; out aEndTaskEventI:IEndTaskEvent; aEndTaskEvent:PEndTaskEvent; aWakeup:PDateTime; aTaskID:PInteger):TTask;virtual;
    function ITMIgnoreTaskCheck(aTask:TTask):Boolean;virtual;
    function ITNLExecProcThread(aExecThreadStruct:PExecThreadStruct; aRaise:Boolean):Boolean;virtual;
    function ITMTaskCancel(aTaskID:Integer):Boolean;virtual;
    procedure ITMIgnoreTaskAdd(aTask:TTask);virtual;
    function ITMIgnoreTaskCancel(aTask:TTask):Boolean;virtual;
    function ITMTask:Variant;virtual;
    function ITMSleepTask:Variant;virtual;
    function ITMArray:Variant;virtual;
    function ITMTaskIgnore:Variant;virtual;
    property MCountReady:PInteger read Get_MCountReady;//Количество свободных потоков
    property MCountWait:PInteger read Get_MCountWait;//Количество Wait потоков
    property MCountDuringCreating:PInteger read Get_MCountDuringCreating;//В процессе создания
    property MCountPerpetualReady:PInteger read Get_MCountPerpetualReady;//Количество основных свободных потоков
    property MCount:PInteger read Get_MCount;//Зарегистрированных
    property MCountPerpetual:PInteger read Get_MCountPerpetual;//Зарегистрированных
    property MNumberedMap:PInteger read Get_MNumberedMap;
    property MNumberedMapReady:PInteger read Get_MNumberedMapReady;//Карта потоков/Ready-потоков
    function WaitForExecuteTask(aMThread:IMThread):TDataCaseResultEvent;virtual;
    procedure ITNLForceGetReadyM;virtual;
    function ITDropMThread(aMThread:IMThread):boolean;virtual;
    procedure ITRegMThread(aMThread:IMThread; aMNumber:PInteger);virtual;
    function Get_MPerpetualCount:Integer;virtual;
    procedure Set_MPerpetualCount(value:Integer);virtual;
    property MPerpetualCount:Integer read Get_MPerpetualCount write Set_MPerpetualCount;
    function Get_MMaxCount:Integer;virtual;
    procedure Set_MMaxCount(value:Integer);virtual;
    property MMaxCount:Integer read Get_MMaxCount write Set_MMaxCount;
  end;

implementation
  uses Sysutils, UDateTimeUtils, UTrayConsts, UTTaskUtils, UADMTypes, UVarset, UThreadsPoolConsts, UErrorConsts,
        UCaller, UMThreadConsts, UMThreadUtils, UTrayUtils, UTaskImplementTypesUtils{$IFNDEF VER130}, Variants{$ENDIF};


constructor TThreadsPool.create(aMPerpetualCount, aMMaxCount:Integer);
begin
  inherited create;
  FMCountReady:=0;//Количество свободных потоков
  FMCountPerpetual:=0;//Количество постоянных
  FMCountWait:=0;//Количество Wait потоков
  FMCountDuringCreating:=0;//В процессе создания
  FMCountPerpetualReady:=0;//Количество основных свободных потоков
  FMCount:=0;//Зарегистрированных
  FMCountExecProcThread:=0;//счетчик количества запросов на ExecProcThread/NewTask/Wakeup
  FTHForMCountExecProcThread:=0;
  FMCountWakeupTask:=0;//счетчик количества запросов на ExecProcThread/NewTask/Wakeup
  FTHForMCountWakeupTask:=0;
  FMCountNewTask:=0;//счетчик количества запросов на ExecProcThread/NewTask/Wakeup
  FTHForMCountNewTask:=0;
  FMNumberedMap:=0;//Карта потоков
  FMNumberedMapReady:=0;//Карта Ready-потоков
  FNextTimeWakeup:=0;
  //..
  FTaskCount:=-1;
  FVSMTasks:=TVarset.Create;
  FVSMTasks.ITConfigIntIndexAssignable:=false;
  FVSMTasks.ITConfigCheckUniqueIntIndex:=false;
  FVSMTasks.ITConfigCheckUniqueStrIndex:=False;
  FVSMTasks.ITConfigNoFoundException:=True;
  FVSMTasks.ITConfigCaseSensitive:=False;
  FVSMTasks.ITConfigMaxCount:=cnMaxTaskNum;
  //M Sleeping tasks array
  FVSMSleepTasks:=TVarset.Create;
  FVSMSleepTasks.ITConfigIntIndexAssignable:=false;
  FVSMSleepTasks.ITConfigCheckUniqueIntIndex:=false;
  FVSMSleepTasks.ITConfigCheckUniqueStrIndex:=False;
  FVSMSleepTasks.ITConfigNoFoundException:=True;
  FVSMSleepTasks.ITConfigCaseSensitive:=False;
  FVSMSleepTasks.ITConfigMaxCount:=cnMaxSleepTaskNum;
  //Ignore task
  FMIgnoreTask:=unassigned;
  FMArray:=unassigned;
  //..
  FExecProcThread:=TVarset.Create;
  FExecProcThread.ITConfigCheckUniqueIntIndex:=False;
  FExecProcThread.ITConfigCheckUniqueStrIndex:=False;
  FExecProcThread.ITConfigMaxCount:=1000;
  //..
  Fillchar(FEvents, Sizeof(FEvents), 0);
  FEvents[0]:=CreateEvent(Nil{no security attribute}, TRUE{manual-reset event}, TRUE{initial state = signaled}, Nil{unnamed event object});
  FEvents[1]:=CreateEvent(Nil{no security attribute}, TRUE{manual-reset event}, TRUE{initial state = signaled}, Nil{unnamed event object});
  FEvents[2]:=CreateEvent(Nil{no security attribute}, TRUE{manual-reset event}, TRUE{initial state = signaled}, Nil{unnamed event object});
  FEvents[3]:=CreateEvent(Nil{no security attribute}, TRUE{manual-reset event}, TRUE{initial state = signaled}, Nil{unnamed event object});
  if (FEvents[0]=0)Or(FEvents[1]=0)or(FEvents[2]=0)or(FEvents[3]=0) Then raise exception.createFmtHelp(cserInvalidValueOf, ['FEvents'], cnerInvalidValueOf);
  ResetEvent(FEvents[0]);//Shotdown
  ResetEvent(FEvents[1]);//Выделить поток
  ResetEvent(FEvents[2]);//AddTask
  ResetEvent(FEvents[3]);//Sleep/WakekupTask
  FWakeupTimer:=TTimer.Create(Nil);
  FWakeupTimer.Enabled:=False;
  FWakeupTimer.OnTimer:=InternalOnWakeup;
  FTaskImplement:=nil;
  FMPerpetualCount:=aMPerpetualCount;
  FMMaxCount:=aMMaxCount;
end;

destructor TThreadsPool.destroy;
begin
  //??!FStateAsTray:=tpsNone;
  FTaskImplement:=nil;
  FFAppMessage:=nil;
  //??!if assigned(FGUIDList) then begin Freemem(FGUIDList);FGUIDList:=nil;end;
  FExecProcThread:=Nil;
  FreeAndNil(FWakeupTimer);
  Closehandle(FEvents[0]);
  Closehandle(FEvents[1]);
  Closehandle(FEvents[2]);
  Closehandle(FEvents[3]);
  Fillchar(FEvents, Sizeof(FEvents), 0);
  inherited destroy;
end;

function TThreadsPool.InternalGetInitGUIDCount:Cardinal;
begin
  result:=inherited InternalGetInitGUIDCount+2;
end;

procedure TThreadsPool.InternalInitGUIDList;
  var tmpCount:Cardinal;
begin
  inherited InternalInitGUIDList;
  tmpCount:=inherited InternalGetInitGUIDCount;
  GUIDList^.aList[tmpCount]:=ITaskImplement;
  GUIDList^.aList[tmpCount+1]:=IAppMessage;
  //GUIDList^.aList[tmpCount+2]:=ILogFile;
end;

procedure TThreadsPool.InternalInit;
begin
  cnTlsThreadBreak:=TlsAlloc;
  if integer(cnTlsThreadBreak)=-1 then raise exception.create('TlsAlloc(cnTlsThreadBreak): '+SysErrorMessage(GetLastError));
  cnTlsMThreadObject:=TlsAlloc;
  if integer(cnTlsMThreadObject)=-1 then raise exception.create('TlsAlloc(cnTlsMThreadObject): '+SysErrorMessage(GetLastError));
  ResetEvent(FEvents[0]);//Shotdown
end;

procedure TThreadsPool.InternalStart;
  var tmpI:Integer;
begin
  cnTray.Query(ITaskImplement, FTaskImplement);
  InternalOnWakeup(FWakeupTimer);
  for tmpI:=FMCount to FMPerpetualCount-1 do begin
    ITNLCreateMThread(true);
  end;
end;

procedure TThreadsPool.InternalStop;
begin
  if Assigned(FWakeupTimer) Then begin//выключаю таймер, разберу позже
    FWakeupTimer.enabled:=False;
  end;
  SetEvent(FEvents[0]);//Устанавливаю флаг на прекращение обработки команд, и делается Terminate без destroy, т.е. FreeOnTerminate=false
end;

function TThreadsPool.InternalGetWaitMessage(aWait:cardinal):AnsiString;
begin
  if aWait=0 then result:='' else begin
    result:='Wait';
    if (aWait div 1000)<>0 then result:=result+' '+IntToStr(aWait div 1000)+' sec';
    if (aWait mod 1000)<>0 then result:=result+' '+IntToStr(aWait mod 1000)+' msec';
    result:=result+'. ';
  end;
end;

procedure TThreadsPool.InternalFinal;
  var tmpStartStopTime:TDateTime;
  procedure localSetThreadBreak;
  var tmplIUnknown:IUnknown;
      tmplMThread:IMThread;
      tmplI:integer;
  begin
    if VarIsArray(FMArray) then begin//ThreadBreak для всех потоков
      for tmplI:=VarArrayLowBound(FMArray, 1) to VarArrayHighBound(FMArray, 1) do begin
        tmplIUnknown:=FMArray[tmplI];
        if (assigned(tmplIUnknown))and(tmplIUnknown.QueryInterface(IMThread, tmplMThread)=S_OK)and(assigned(tmplMThread)) then begin
          tmplMThread.ThreadBreak:=true;
          InternalSetMessage(tmpStartStopTime, 'Set ThreadBreak. ThreadID='+IntToStr(tmplMThread.GetThreadID)+'.', mecApp, mesInformation);
        end;
      end;
    end;
  end;
  var tmpMCount, tmpMCountDuringCreating:integer;//для лога
  function localGetMess:AnsiString;begin
    result:='MCount='+IntToStr(tmpMCount);
    if tmpMCountDuringCreating<>0 then result:=result+' MCountDuringCreating='+IntToStr(tmpMCountDuringCreating);
  end;
  var tmpInteger:Integer;
      tmpStartTime:TDateTime;
      tmpWait:Cardinal;
begin
  tmpStartTime:=now;
  try
    tmpStartStopTime:=now;
    tmpMCount:=FMCount;//для лога
    tmpMCountDuringCreating:=FMCountDuringCreating;//для лога
    localSetThreadBreak;
    FMArray:=unassigned;//отпускаю все потоки
    tmpWait:=0;
    While True do begin
      if (FMCount=0)and(FMCountDuringCreating=0) then begin
        InternalSetMessage(tmpStartTime, InternalGetWaitMessage(tmpWait)+'All '+localGetMess+' threads are discharged.', mecApp, mesInformation);
        break;
      end;
      inc(tmpWait, 150);
      sleep(150);
      if tmpWait>60000 then begin
        InternalSetMessage(tmpStartStopTime, InternalGetWaitMessage(tmpWait)+'Still there are MCount='+IntToStr(FMCount)+'/MCountDuringCreating='+IntToStr(FMCountDuringCreating)+' threads.', mecApp, mesWarning);
        break;
      end;
    end;//sleep(1000);//Можно не делать, но я всеравно даю время потокам закрыться наверняка.
  except on e:exception do begin
    try InternalSetMessage(tmpStartTime, 'InternalFinal(1): '+e.message, mecApp, mesError);except end;
  end;end;
  try
    if assigned(FExecProcThread) then begin
      tmpInteger:=FExecProcThread.ITCount;
      if tmpInteger>0 then begin
        while tmpInteger>0 do begin
          tmpInteger:=FExecProcThread.ITPopV(False);
          PExecThreadStruct(tmpInteger)^.UserIUnknown:=Nil;
          Freemem(Pointer(tmpInteger));
        end;
        InternalSetMessage(tmpStartTime, 'FExecProcThread.ITCount='+IntToStr(tmpInteger), mecApp, mesWarning);
      end;  
    end;
  except on e:exception do begin
    try InternalSetMessage(tmpStartTime, 'InternalFinal(2): '+e.message, mecApp, mesError);except end;
  end;end;
  try
    FTaskImplement:=nil;
    FFAppMessage:=nil;
    TlsFree(cnTlsThreadBreak);
    cnTlsThreadBreak:=cnTlsNoIndex;
    TlsFree(cnTlsMThreadObject);
    cnTlsMThreadObject:=cnTlsNoIndex;
  except on e:exception do begin
    try InternalSetMessage(tmpStartTime, 'InternalFinal(3): '+e.message, mecApp, mesError);except end;
  end;end;
end;

function TThreadsPool.Get_MPerpetualCount:Integer;
begin
  result:=FMPerpetualCount;
end;

procedure TThreadsPool.Set_MPerpetualCount(value:Integer);
  var tmpI:Integer;
begin
  Internallock;
  try
    FMPerpetualCount:=value;
    if (FMPerpetualCount<>value)and(InternalCheckStateAsTrayForWork(false)) then begin
      if value>FMCountPerpetual then begin
        for tmpI:=1 to value-FMCountPerpetual do ITNLCreateMThread(true);
      end else begin
        ITDropPerpetualMThread(FMCountPerpetual-value);
      end;
    end;
  finally
    Internalunlock;
  end;
end;

function TThreadsPool.Get_MMaxCount:Integer;
begin
  result:=FMMaxCount;
end;

procedure TThreadsPool.Set_MMaxCount(value:Integer);
begin
  FMMaxCount:=value;
end;

procedure TThreadsPool.ITMSleepTaskAdd(aTask:TTask; const aParams:Variant; const aSenderParams, aSenderSecurityContext:Variant; aSleep:LongWord);
begin
  ITMSleepTaskAdd(aTask, aParams, aSenderParams, aSenderSecurityContext, aSleep, -1{tkiNoTaskID}, nil);
end;

procedure TThreadsPool.ITMSleepTaskAdd(aTask:TTask; const aParams:Variant; const aSenderParams, aSenderSecurityContext:Variant; aSleep:LongWord; aTaskNumbered:Integer; aPTaskID:PInteger);
begin
  Internallock;
  try
    try
      InternalCheckStateAsTrayForWork(true{aRaise});
      InternalMSleepTaskAdd(aTask, TCallerAction.CreateNewAction(aSenderSecurityContext, aSenderParams), aParams, MSecsToDateTime(aSleep+DateTimeToMSecs(Now)), aTaskNumbered, aPTaskID);
    except On e:exception do begin
      e.message:='ITMSleepTaskAdd: '+e.message;
      raise;
    end;end;
  finally
    Internalunlock;
  end;
end;

procedure TThreadsPool.ITMWakeUpTaskAdd(aTask:TTask; const aParams:Variant; const aSenderParams, aSenderSecurityContext:Variant; aWakeup:TDateTime);
begin
  ITMWakeUpTaskAdd(aTask, aParams, aSenderParams, aSenderSecurityContext, aWakeup, -1{tkiNoTaskID}, nil);
end;

procedure TThreadsPool.ITMWakeUpTaskAdd(aTask:TTask; const aParams:Variant; const aSenderParams, aSenderSecurityContext:Variant; aWakeup:TDateTime; aTaskNumbered:integer; aPTaskID:PInteger);
begin
  Internallock;
  try
    try
      InternalCheckStateAsTrayForWork(true{aRaise});
      InternalMSleepTaskAdd(aTask, TCallerAction.CreateNewAction(aSenderSecurityContext, aSenderParams), aParams, aWakeup, aTaskNumbered, aPTaskID);
    except On e:exception do begin
      e.message:='ITMWakeUpTaskAdd: '+e.message;
      raise;
    end;end;
  finally
    Internalunlock;
  end;
end;

procedure TThreadsPool.ITMTaskAdd(aTask:TTask; const aParams:Variant; const aSenderParams, aSenderSecurityContext:Variant);
begin
  ITMTaskAdd(aTask, aParams, aSenderParams, aSenderSecurityContext, -1, nil);
end;

procedure TThreadsPool.ITMTaskAdd(aTask:TTask; const aParams:Variant; const aSenderParams, aSenderSecurityContext:Variant; aTaskNumbered:integer; aPTaskID:PInteger);
begin
  Internallock;
  try
    try
      InternalCheckStateAsTrayForWork(true{aRaise});
      InternalMTaskAdd(aTask, TCallerAction.CreateNewAction(aSenderSecurityContext, aSenderParams), aParams, aTaskNumbered, aPTaskID);
    except On e:exception do begin
      e.message:='ITMTaskAdd: '+e.message;
      raise;
    end;end;
  finally
    Internalunlock;
  end;
end;

type PIntroCallUserData=^TIntroCallUserData;
     TIntroCallUserData=record
       aHandle:PHandle;
       aCounter:PInteger;
       aThreadsPool:TThreadsPool;
     end;

procedure InternalIntroCallAdd(aUserData:Pointer; aVarset:IVarset; aVarsetData:IVarsetData);
  var tmpCount:Integer;
begin
  tmpCount:=aVarset.ITCount;
  PIntroCallUserData(aUserData)^.aCounter^:=tmpCount;
  if tmpCount>0 then begin
    Setevent(PIntroCallUserData(aUserData)^.aHandle^);
    PIntroCallUserData(aUserData)^.aThreadsPool.ITNLForceGetReadyM;//проверяю достаток в потоках
  end;
end;

procedure InternalIntroCallDec(aUserData:Pointer; aVarset:IVarset; aVarsetData:IVarsetData);
  var tmpCount:Integer;
begin
  tmpCount:=aVarset.ITCount;
  PIntroCallUserData(aUserData)^.aCounter^:=tmpCount;
  if tmpCount<1 then Resetevent(PIntroCallUserData(aUserData)^.aHandle^) else begin
    PIntroCallUserData(aUserData)^.aThreadsPool.ITNLForceGetReadyM;//проверяю достаток в потоках
  end;
end;

(*{!!!}procedure InternalIntroCallAdd11(aUserData:Pointer; aVarset:IVarset; aVarsetData:IVarsetData);
  var tmpCount:Integer;
begin
  tmpCount:=aVarset.ITCount;
  {inc(}PIntroCallUserData(aUserData)^.aCounter^:=tmpCount{)};
  if tmpCount>0 then begin
    Setevent(PIntroCallUserData(aUserData)^.aHandle^);
    PIntroCallUserData(aUserData)^.aThreadsPool.ITNLForceGetReadyM;//проверяю достаток в потоках
  end;
  PIntroCallUserData(aUserData)^.aThreadsPool.InternalSetMessage(now, 'ITNLExecProcThread: '+IntToHex(Cardinal(Integer(aVarsetData.ITData)), 4), mecApp, mesWarning);
end;(**)

(*{!!!}procedure InternalIntroCallDec11(aUserData:Pointer; aVarset:IVarset; aVarsetData:IVarsetData);
  var tmpCount:Integer;
begin
  tmpCount:=aVarset.ITCount;
  PIntroCallUserData(aUserData)^.aCounter^:=tmpCount;
  if tmpCount<1 then Resetevent(PIntroCallUserData(aUserData)^.aHandle^) else begin
    PIntroCallUserData(aUserData)^.aThreadsPool.ITNLForceGetReadyM;//проверяю достаток в потоках
  end;

  if assigned(aVarsetData) then begin
    PIntroCallUserData(aUserData)^.aThreadsPool.InternalSetMessage(now, 'ITExecProcThreadForThread: '+IntToHex(Cardinal(Integer(aVarsetData.ITData)), 4)+' Delta='+TwoDateTimeToDurationStr(now, aVarsetData.DateCreate), mecApp, mesWarning);
  end else begin
    PIntroCallUserData(aUserData)^.aThreadsPool.InternalSetMessage(now, 'ITExecProcThreadForThread: Nil(not assigned(aVarsetData)).', mecApp, mesWarning);
  end;
end;(**)

//Type IVarsetDataWithDateCreate=interface
     //['{C8F580D4-5257-489A-8667-B5D7F891B832}']
     //  function Get_DateCreate:TDateTime;
     //  property DateCreate:TDateTime read Get_DateCreate;
     //end;
     //TVarsetDataWithDateCreate=class(TVarsetData, IVarsetDataWithDateCreate)
     //private
     //  FDateCreate:TDateTime;
     //protected
     //  function Get_DateCreate:TDateTime;
     //public
     //  constructor Create;
     //  property DateCreate:TDateTime read Get_DateCreate;
     //end;

//constructor TVarsetDataWithDateCreate.Create;
//begin
//  inherited create;
//  FDateCreate:=now;
//end;

//function TVarsetDataWithDateCreate.Get_DateCreate:TDateTime;
//begin
//  result:=FDateCreate;
//end;

function TThreadsPool.ITMTaskView(aParams:PVariant; out aCallerAction:ICallerAction; out aCallerTask:ICallerTask; out aEndTaskEventI:IEndTaskEvent; aEndTaskEvent:PEndTaskEvent; aTaskID:PInteger):TTask;
  var tmpIVarsetData:IVarsetData;
      tmpIUnknown:IUnknown;
      tmpIntroCallUserData:TIntroCallUserData;
      tmpIntroCallStructData:TIntroCallStructData;
      //tmpVarsetDataWithDateCreate:IVarsetDataWithDateCreate;
begin
  Internallock;
  try
    if FVSMTasks.ITCount=0 Then begin//Если заданий нет (FMTasksCount=0)
      Result:=tskMTNone;
    end else begin
      try
        tmpIntroCallUserData.aHandle:=@FEvents[2];
        tmpIntroCallUserData.aCounter:=@FMCountNewTask;
        tmpIntroCallUserData.aThreadsPool:=self;
        tmpIntroCallStructData.UserData:=@tmpIntroCallUserData;
        tmpIntroCallStructData.OnIntroCallData:=InternalIntroCallDec;
        tmpIVarsetData:=FVSMTasks.ITPopIC(True, @tmpIntroCallStructData);//Получаю задание
        Result:=tmpIVarsetData.ITData[0];
        aParams^:=tmpIVarsetData.ITData[1];
        aTaskID^:=tmpIVarsetData.ITData[3];
        tmpIUnknown:=tmpIVarsetData.ITData[2];
        if (not assigned(tmpIUnknown))or(tmpIUnknown.QueryInterface(ICallerAction, aCallerAction)<>S_OK)or(not assigned(aCallerAction)) then raise exception.createFmtHelp(cserInternalError, ['ICallerAction is not found.'], cnerInternalError);
        case VarArrayHighBound(tmpIVarsetData.ITData, 1) of
          3:begin
            aCallerTask:=nil;
            aEndTaskEventI:=nil;
            fillchar(aEndTaskEvent^, sizeof(aEndTaskEvent^), 0);
          end;
          6:begin
            tmpIUnknown:=tmpIVarsetData.ITData[4]{aCallerTask};
            if (not assigned(tmpIUnknown))or(tmpIUnknown.QueryInterface(ICallerTask, aCallerTask)<>S_OK) then aCallerTask:=nil;
            tmpIUnknown:=tmpIVarsetData.ITData[5]{EndTaskEventI};
            if (not assigned(tmpIUnknown))or(tmpIUnknown.QueryInterface(IEndTaskEvent, aEndTaskEventI)<>S_OK) then aEndTaskEventI:=nil;
            VariantToEndTaskEvent(tmpIVarsetData.ITData[6], aEndTaskEvent);
          end;
        else
          raise exception.createFmtHelp(cserInternalError, ['HighBound<>3,6.'], cnerInternalError);
        end;
        //if tmpIVarsetData.QueryInterface(IVarsetDataWithDateCreate, tmpVarsetDataWithDateCreate)=S_OK then
            //InternalSetMessage(now, 'ITMTaskView: Delta='+TwoDateTimeToDurationStr(now, tmpIVarsetData.DateCreate), mecApp, mesWarning);
      except on e:exception do begin
        Result:=tskMTNone;
        try
        InternalSetMessage(now, 'InternalError: '+e.Message+'/HC='+IntToStr(e.HelpContext), mecApp, mesError);
        aCallerTask.SetError(e.message, e.HelpContext);
      except end;end;end;
    end;
  finally
    Internalunlock;
  end;
end;

//[0]-varInteger:(aASMSenderNum) [1]-varIntwgwr:(aaPlaceResult:TPlaceResult) [2]-varInteger:(TaskID)
procedure TThreadsPool.InternalMTaskAdd(aTask:TTask; aCallerAction:ICallerAction; const aParams:Variant; aTaskNumbered:Integer; aPTaskID:PInteger);
  var tmpTaskID:Integer;
      tmpIntroCallStructData:TIntroCallStructData;
      tmpIntroCallUserData:TIntroCallUserData;
      tmpVarsetData:IVarsetData;
begin
  try
    if aTask=tskMTNone then raise exception.create('aTask=tskMTNone.');//??!!
    if assigned(aPTaskID) then aPTaskID^:=-1;//Проверка на игнорирование задачи
    if ITMIgnoreTaskCheck(aTask) Then begin//InternalSetMessage(now, 'IMTaskAdd: Задание игнорируется: '+MTaskToStr(aTask)+'.', mecApp, mesWarning);//Exit;
      raise exception.create('IMTaskAdd: Задание игнорируется: '+MTaskToStr(aTask)+'.');
    end;//Проверка переполнения списка задач
    if FVSMTasks.ITCount+1>Cardinal(cnMaxTaskNum) Then raise exception.create('Список задач переполнен (FVSMTasks.ITCount='+IntToStr(FVSMTasks.ITCount)+').');
    //ITNLForceGetReadyM;//Проверка возможности выполнения
    tmpIntroCallUserData.aHandle:=@FEvents[2];
    tmpIntroCallUserData.aCounter:=@FMCountNewTask;
    tmpIntroCallUserData.aThreadsPool:=self;
    tmpIntroCallStructData.UserData:=@tmpIntroCallUserData;
    tmpIntroCallStructData.OnIntroCallData:=InternalIntroCallAdd;
    tmpVarsetData:=TVarsetData.create;
    if aTaskNumbered=-1{tkiNoTaskID} then begin//--Создание нового задания
      tmpTaskID:=InterlockedIncrement(FTaskCount);//Создается задание с новым номером//FVSMTasks.ITPushV(VarArrayOf([aTask, aParams, aCallerAction{Result}, tmpSenderParams, tmpTaskID, aSenderSecurityContext]));
      tmpVarsetData.ITData:=VarArrayOf([aTask{0}, aParams{1}, aCallerAction{2}, tmpTaskID{3}]);
      if assigned(aPTaskID) then aPTaskID^:=tmpTaskID;//см. ITMTaskCancel там тоже varArray
    end else begin//Заданию присваивается указанный номер//Проверяю уникальность//указанный номер "хороший"      0      1        2                      3                4              5
      tmpVarsetData.ITData:=VarArrayOf([aTask{0}, aParams{1}, aCallerAction{2}, aTaskNumbered{3}]);
      if assigned(aPTaskID) then aPTaskID^:=aTaskNumbered;
    end;
    FVSMTasks.ITPushIC(tmpVarsetData, @tmpIntroCallStructData);
  except on e:exception do begin
    e.Message:='IMTaskAdd: '+e.Message;
    raise;
  end;end;
end;

procedure TThreadsPool.InternalMTaskAddWithCallerTask(aTask:TTask; aCallerAction:ICallerAction; const aParams:Variant; aCallerTask:ICallerTask; aEndTaskEventI:IEndTaskEvent; aEndTaskEvent:PEndTaskEvent; aTaskNumbered:Integer; aPTaskID:PInteger);
  var tmpTaskID:Integer;
      tmpIntroCallStructData:TIntroCallStructData;
      tmpIntroCallUserData:TIntroCallUserData;
      tmpVarsetData:IVarsetData;
begin
  try
    if aTask=tskMTNone then raise exception.create('aTask=tskMTNone.');
    if assigned(aPTaskID) then aPTaskID^:=-1;//Проверка на игнорирование задачи
    if ITMIgnoreTaskCheck(aTask) Then raise exception.create('IMTaskAdd: Задание игнорируется: '+MTaskToStr(aTask)+'.');
    if FVSMTasks.ITCount+1>Cardinal(cnMaxTaskNum) Then raise exception.create('Список задач переполнен (FVSMTasks.ITCount='+IntToStr(FVSMTasks.ITCount)+').');//Проверка переполнения списка задач
    //ITNLForceGetReadyM;//Проверка возможности выполнения
    tmpIntroCallUserData.aHandle:=@FEvents[2];
    tmpIntroCallUserData.aCounter:=@FMCountNewTask;
    tmpIntroCallUserData.aThreadsPool:=self;
    tmpIntroCallStructData.UserData:=@tmpIntroCallUserData;
    tmpIntroCallStructData.OnIntroCallData:=InternalIntroCallAdd;
    tmpVarsetData:=TVarsetData.create;
    if aTaskNumbered=-1 then begin//Создание нового задания
      tmpTaskID:=InterlockedIncrement(FTaskCount);//Создается задание с новым номером// 0 1 2 3 4(TaskID) 5 SecurityContext
      tmpVarsetData.ITData:=VarArrayOf([aTask{0}, aParams{1}, aCallerAction{2}, tmpTaskID{3}, aCallerTask{4}, aEndTaskEventI{5}, EndTaskEventToVariant(aEndTaskEvent){6}]);
      if assigned(aPTaskID) then aPTaskID^:=tmpTaskID;//см. ITMTaskCancel там тоже varArray
    end else begin//Заданию присваивается указанный номер//Проверяю уникальность//указанный номер "хороший" 0 1 2 3 4 5
      tmpVarsetData.ITData:=VarArrayOf([aTask{0}, aParams{1}, aCallerAction{2}, aTaskNumbered{3}, aCallerTask{4}, aEndTaskEventI{5}, EndTaskEventToVariant(aEndTaskEvent){6}]);
      if assigned(aPTaskID) then aPTaskID^:=aTaskNumbered;
    end;
    FVSMTasks.ITPushIC(tmpVarsetData, @tmpIntroCallStructData);
  except on e:exception do begin
    e.Message:='IMTaskAddWithCallerTask: '+e.Message;
    raise;
  end;end;
end;

procedure TThreadsPool.ITMTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aCallerTask:ICallerTask; aEndTaskEventI:IEndTaskEvent; aEndTaskEvent:PEndTaskEvent);
begin
  Internallock;
  try
    try
      InternalCheckStateAsTrayForWork(true{aRaise});
      InternalMTaskAddWithCallerTask(aTask, aCallerAction, aParams, aCallerTask, aEndTaskEventI, aEndTaskEvent, -1, nil);
    except on e:exception do begin
      e.message:='ITMTaskAdd: '+e.message;
      raise;
    end;end;
  finally
    Internalunlock;
  end;
end;

procedure TThreadsPool.ITMSleepTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aSleep:LongWord; aCallerTask:ICallerTask; aEndTaskEventI:IEndTaskEvent; aEndTaskEvent:PEndTaskEvent);
begin
  Internallock;
  try
    try
      InternalCheckStateAsTrayForWork(true{aRaise});
      InternalMSleepTaskAddWithCallerTask(aTask, aCallerAction, aParams, MSecsToDateTime(aSleep+DateTimeToMSecs(Now)), aCallerTask, aEndTaskEventI, aEndTaskEvent, -1, nil);
    except On e:exception do begin
      e.message:='ITMSleepTaskAdd: '+e.message;
      raise;
    end;end;
  finally
    Internalunlock;
  end;
end;

procedure TThreadsPool.ITMWakeUpTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aWakeup:TDateTime; aCallerTask:ICallerTask; aEndTaskEventI:IEndTaskEvent; aEndTaskEvent:PEndTaskEvent);
begin
  Internallock;
  try
    try
      InternalCheckStateAsTrayForWork(true{aRaise});
      InternalMSleepTaskAddWithCallerTask(aTask, aCallerAction, aParams, aWakeup, aCallerTask, aEndTaskEventI, aEndTaskEvent, -1, nil);
    except On e:exception do begin
      e.message:='ITMWakeUpTaskAdd: '+e.message;
      raise;
    end;end;
  finally
    Internalunlock;
  end;
end;

procedure InternalIntroCallSleepView(aUserData:Pointer; aVarset:IVarset; aVarsetData:IVarsetData);
  var tmpCountReady:Cardinal;
      tmpNextTime:TDateTime;
begin
  tmpNextTime:=aVarset.ITGetNextTimeWakeupAfterTime(@tmpCountReady, now);
  if tmpCountReady>0 then begin
    TThreadsPool(aUserData).FMCountWakeupTask:=tmpCountReady;
    SetEvent(TThreadsPool(aUserData).FEvents[3]);
    TThreadsPool(aUserData).ITNLForceGetReadyM;//проверяю достаток в потоках
  end else begin
    TThreadsPool(aUserData).InternalSetNextTimeWakeup(tmpNextTime);
    Resetevent(TThreadsPool(aUserData).FEvents[3]);
    TThreadsPool(aUserData).FMCountWakeupTask:=0;
  end;
  //TThreadsPool(aUserData).InternalSetMessage(now, 'InternalIntroCallSleepView: Set FMCountWakeupTask='+IntToStr(TThreadsPool(aUserData).FMCountWakeupTask)+'.', mecApp, mesWarning);
end;

//Sleep Task __________________________________________________________________
function TThreadsPool.ITMSleepTaskView(aParams:PVariant; out aCallerAction:ICallerAction; out aCallerTask:ICallerTask; out aEndTaskEventI:IEndTaskEvent; aEndTaskEvent:PEndTaskEvent; aWakeup:PDateTime; aTaskID:PInteger):TTask;
  var tmpIVarsetData:IVarsetData;
      tmpIUnknown:IUnknown;
      tmpIntroCallStructData:TIntroCallStructData;
begin
  Internallock;
  try
    try
      tmpIntroCallStructData.UserData:=self;
      tmpIntroCallStructData.OnIntroCallData:=InternalIntroCallSleepView;
      tmpIVarsetData:=FVSMSleepTasks.ITPopWakeupIC(@tmpIntroCallStructData);
      if assigned(tmpIVarsetData) Then begin
        Result:=tmpIVarsetData.ITData[0];
        aParams^:=tmpIVarsetData.ITData[1];
        if assigned(aWakeup) then aWakeup^:=tmpIVarsetData.ITWakeup;
        aTaskID^:=tmpIVarsetData.ITData[3];
        tmpIUnknown:=tmpIVarsetData.ITData[2];
        if (not assigned(tmpIUnknown))or(tmpIUnknown.QueryInterface(ICallerAction, aCallerAction)<>S_OK)or(not assigned(aCallerAction)) then raise exception.createFmtHelp(cserInternalError, ['ICallerAction not found.'], cnerInternalError);
        case VarArrayHighBound(tmpIVarsetData.ITData, 1) of
          3:begin
            aCallerTask:=nil;
            aEndTaskEventI:=nil;
            if assigned(aEndTaskEvent) then fillchar(aEndTaskEvent^, sizeof(aEndTaskEvent^), 0);
          end;
          6:begin
            tmpIUnknown:=tmpIVarsetData.ITData[4]{aCallerTask};
            if (not assigned(tmpIUnknown))or(tmpIUnknown.QueryInterface(ICallerTask, aCallerTask)<>S_OK) then aCallerTask:=nil;
            tmpIUnknown:=tmpIVarsetData.ITData[5]{EndTaskEventI};
            if (not assigned(tmpIUnknown))or(tmpIUnknown.QueryInterface(IEndTaskEvent, aEndTaskEventI)<>S_OK) then aEndTaskEventI:=nil;
            VariantToEndTaskEvent(tmpIVarsetData.ITData[6], aEndTaskEvent);
          end;
        else
          raise exception.createFmtHelp(cserInternalError, ['HighBound<>3,6.'], cnerInternalError);
        end;
      end else begin//Нет готовых задач
        Result:=tskMTNone;
      end;
    except on e:exception do begin
      Result:=tskMTNone;
      InternalSetMessage(now, 'InternalError: '+e.Message+'/HC='+IntToStr(e.HelpContext), mecApp, mesError);
    end;end;
  finally
    Internalunlock;
  end;
end;

procedure TThreadsPool.InternalMSleepTaskAddWithCallerTask(aTask:TTask; aCallerAction:ICallerAction; const aParams:Variant; aWakeup:TDateTime; aCallerTask:ICallerTask; aEndTaskEventI:IEndTaskEvent; aEndTaskEvent:PEndTaskEvent; aTaskNumbered:Integer; aPTaskID:PInteger);
  var tmpTaskID:Integer;
      tmpIVarsetData:IVarsetData;
      tmpIntroCallStructData:TIntroCallStructData;
begin
  try
    if aTask=tskMTNone then raise exception.create('tskMTNone.');
    if assigned(aPTaskID) then aPTaskID^:=-1{tkiNoTaskID};//Проверка на игнорирование задачи
    if ITMIgnoreTaskCheck(aTask) Then raise exception.create('IMTaskAdd: Задание игнорируется: '+MTaskToStr(aTask)+'.');
    if {ITGet}FMCount=0 Then raise exception.create('Задание невозможно выполнить, MCount=0.');
    if FVSMSleepTasks.ITCount+1>Cardinal(cnMaxSleepTaskNum) Then raise exception.create('Список задач переполнен (Count='+IntToStr(FVSMSleepTasks.ITCount+1)+').');
    tmpIVarsetData:=TVarsetData.Create;//--Создание нового задания
    if aTaskNumbered=-1{tkiNoTaskID} then begin//Создается задание с новым номером
      tmpTaskID:=InterlockedIncrement(FTaskCount);//tmpIVarsetData.ITData:=VarArrayOf([aTask{0}, aParams{1}, aCallerAction{2}, tmpSenderParams{3}, aWakeup{4}, tmpTaskID{5}, aSenderSecurityContext{6}]);
      tmpIVarsetData.ITData:=VarArrayOf([aTask{0}, aParams{1}, aCallerAction{2}, tmpTaskID{3}, aCallerTask{4}, aEndTaskEventI{5}, EndTaskEventToVariant(aEndTaskEvent){6}]);
      if assigned(aPTaskID) then aPTaskID^:=tmpTaskID;
    end else begin//Заданию присваивается указанный номер//Проверяю уникальность//указанный номер "хороший"        0      1        2                      3                4        5           6              7
      tmpIVarsetData.ITData:=VarArrayOf([aTask{0}, aParams{1}, aCallerAction{2}, aTaskNumbered{3}, aCallerTask{4}, aEndTaskEventI{5}, EndTaskEventToVariant(aEndTaskEvent){6}]);
      if assigned(aPTaskID) then aPTaskID^:=aTaskNumbered;
    end;
    tmpIVarsetData.ITWakeup:=aWakeup;
    tmpIntroCallStructData.UserData:=self;
    tmpIntroCallStructData.OnIntroCallData:=InternalIntroCallSleepView;
    FVSMSleepTasks.ITPushIC(tmpIVarsetData, @tmpIntroCallStructData);
  except on e:exception do begin
    e.Message:='IMSleepTaskAdd: '+e.Message;
    raise;
  end;end;
end;

//[0]-varInteger:(aASMSenderNum) [1]-varIntwgwr:(aaPlaceResult:TPlaceResult) [2]-varInteger:(TaskID)
procedure TThreadsPool.InternalMSleepTaskAdd(aTask:TTask; aCallerAction:ICallerAction; const aParams:Variant; aWakeup:TDateTime; aTaskNumbered:Integer; aPTaskID:PInteger);
  var tmpTaskID:Integer;
      tmpIVarsetData:IVarsetData;
      tmpIntroCallStructData:TIntroCallStructData;
begin
  try
    if aTask=tskMTNone then raise exception.create('tskMTNone.');
    if assigned(aPTaskID) then aPTaskID^:=-1{tkiNoTaskID};//Проверка на игнорирование задачи
    if ITMIgnoreTaskCheck(aTask) Then raise exception.create('IMTaskAdd: Задание игнорируется: '+MTaskToStr(aTask)+'.');
    if {ITGet}FMCount=0 Then raise exception.create('Задание невозможно выполнить, MCount=0.');
    if FVSMSleepTasks.ITCount+1>Cardinal(cnMaxSleepTaskNum) Then raise exception.create('Список задач переполнен (Count='+IntToStr(FVSMSleepTasks.ITCount+1)+').');
    tmpIVarsetData:=TVarsetData.Create;//--Создание нового задания
    if aTaskNumbered=-1{tkiNoTaskID} then begin//Создается задание с новым номером
      tmpTaskID:=InterlockedIncrement(FTaskCount);//tmpIVarsetData.ITData:=VarArrayOf([aTask{0}, aParams{1}, aCallerAction{2}, tmpSenderParams{3}, aWakeup{4}, tmpTaskID{5}, aSenderSecurityContext{6}]);
      tmpIVarsetData.ITData:=VarArrayOf([aTask{0}, aParams{1}, aCallerAction{2}, tmpTaskID{3}]);
      if assigned(aPTaskID) then aPTaskID^:=tmpTaskID;
    end else begin//Заданию присваивается указанный номер//Проверяю уникальность//указанный номер "хороший"        0      1        2                      3                4        5           6              7
      tmpIVarsetData.ITData:=VarArrayOf([aTask{0}, aParams{1}, aCallerAction{2}, aTaskNumbered{3}]);
      if assigned(aPTaskID) then aPTaskID^:=aTaskNumbered;
    end;
    tmpIVarsetData.ITWakeup:=aWakeup;
    tmpIntroCallStructData.UserData:=self;
    tmpIntroCallStructData.OnIntroCallData:=InternalIntroCallSleepView;
    FVSMSleepTasks.ITPushIC(tmpIVarsetData, @tmpIntroCallStructData);
  except on e:exception do begin
    e.Message:='IMSleepTaskAdd: '+e.Message;
    raise;
  end;end;
end;

function TThreadsPool.ITDropPerpetualMThread(aCount:integer):boolean;
  var tmpI, tmpLB, tmpHB:Integer;
      tmpIMThread:IMThread;
begin
  InternalLock;
  try
    Result:=False;
    if not VarIsArray(FMArray) Then Exit;
    tmpLB:=VarArrayLowBound(FMArray, 1);
    tmpHB:=VarArrayHighBound(FMArray, 1);
    for tmpI:=tmpLB to tmpHB do begin
      if aCount=0 then break;
      tmpIMThread:=IMThread(IUnknown(FMArray[tmpI]));
      if tmpIMThread.IsPerpetualM then begin
        Result:=True;
        tmpIMThread.Registered:=False;//убираю из MNumberedMap и MNumberedMapReady
        tmpIMThread:=nil;//.ITAutoTerminateAndAutoFree;
        if tmpHB=tmpI Then begin//если это последняя запись
          if tmpLB=tmpI Then begin//если это единственная запись
            FMArray:=Unassigned;
          end else begin//если это не единственная запись
            FMArray[tmpI]:=unassigned;
            VarArrayRedim(FMArray, tmpHB-1);
          end;
        end else begin//если это не последняя и не единственная запись
          FMArray[tmpI]:=FMArray[tmpHB];//ставлю последнюю на место ненужной
          FMArray[tmpHB]:=unassigned;
          VarArrayRedim(FMArray, tmpHB-1);
        end;
        dec(aCount);
      end;
    end;
  finally
    InternalUnlock;
  end;
end;

function TThreadsPool.InternalDropMThread(aMThread:IMThread):boolean;
  var tmpI, tmpLB, tmpHB:Integer;
begin
  Result:=False;
  if not VarIsArray(FMArray) Then Exit;
  tmpLB:=VarArrayLowBound(FMArray, 1);
  tmpHB:=VarArrayHighBound(FMArray, 1);
  for tmpI:=tmpLB to tmpHB do begin
    if Pointer(IUnknown(FMArray[tmpI]))=Pointer(aMThread) Then begin//нашел
      Result:=True;
      aMThread.Registered:=False;//убираю из MNumberedMap и MNumberedMapReady
      aMThread:=nil;//.ITAutoTerminateAndAutoFree;
      if tmpHB=tmpI Then begin//если это последняя запись
        if tmpLB=tmpI Then begin//если это единственная запись
          FMArray:=Unassigned;
        end else begin//если это не единственная запись
          FMArray[tmpI]:=unassigned;
          VarArrayRedim(FMArray, tmpHB-1);
        end;
      end else begin//если это не последняя и не единственная запись
        FMArray[tmpI]:=FMArray[tmpHB];//ставлю последнюю на место ненужной
        FMArray[tmpHB]:=unassigned;
        VarArrayRedim(FMArray, tmpHB-1);
      end;
      break;
    end;            
  end;
end;

function TThreadsPool.ITDropMThread(aMThread:IMThread):boolean;
begin
  Internallock;
  try
    Result:=InternalDropMThread(aMThread);
  finally
    Internalunlock;
  end;
end;

{function TThreadsPool.InternalGetMCount:Integer;
begin
  Result:=0;
  if not VarIsArray(FMArray) Then exit;
  Result:=VarArrayHighBound(FMArray, 1)-VarArrayLowBound(FMArray, 1)+1;
end;}

{function TThreadsPool.ITGetMCount:Integer;
begin
  Result:=FMCount;
end;}

procedure TThreadsPool.InternalNLCreateMThread(aPerpetual:Boolean);
begin
  TMThread.Create(False, aPerpetual, Self);
end;

procedure TThreadsPool.ITNLCreateMThread(aPerpetual:Boolean);
begin
  if FMCount<FMMaxCount{cnMMaxCount} Then InternalNLCreateMThread(aPerpetual);
end;

procedure TThreadsPool.ITRegMThread(aMThread:IMThread; aMNumber:PInteger);
  function GetMNumber:Integer; begin//Внимание! Эта функция не моногопоточная и расчинана на последовательное выполнение.
    if aMThread.IsPerpetualM then result:=0 else begin//Ищу свободный номер
      Result:=1;
      while true do begin
        if (FMNumberedMap and Result)=0 then break;
        if Result=$40000000{31-й bit, последний возможный} then begin
          Result:=0;
          break;
        end;
        Result:=Result shl 1;
      end;
    end;
  end;
begin
  if not assigned(aMThread) then exit;
  Internallock;
  try
    if not VarIsArray(FMArray) Then begin//Создаю первый Slave
      FMArray:=VarArrayCreate([0,0], varVariant);
      FMArray[0]:=aMThread;
    end else begin//Добавляю к существующим
      VarArrayRedim(FMArray, VarArrayHighBound(FMArray, 1)+1);
      FMArray[VarArrayHighBound(FMArray, 1)]:={_RecAdd(}aMThread{)};
    end;
    aMNumber^:=GetMNumber;
    aMThread.Registered:=True;//тут он сам поставит MNumberedMap и MNumberedMapReady.
  finally
    Internalunlock;
  end;
end;

procedure TThreadsPool.ITNLForceGetReadyM;
begin
  if (FMCountReady<1)and(FMCountWait<1)and(FMCountDuringCreating<1) Then begin//>-невсякий случай//Нехватает свободного потока, создаю
    ITNLCreateMThread(False);
  end;
end;

function TThreadsPool.Get_MCountReady:PInteger;
begin
  result:=@FMCountReady;
end;

function TThreadsPool.Get_MCountPerpetual:PInteger;
begin
  result:=@FMCountPerpetual;
end;

function TThreadsPool.Get_MCountWait:PInteger;
begin
  result:=@FMCountWait;
end;

function TThreadsPool.Get_MCountDuringCreating:PInteger;
begin
  result:=@FMCountDuringCreating;
end;

function TThreadsPool.Get_MCountPerpetualReady:PInteger;
begin
  result:=@FMCountPerpetualReady;
end;

function TThreadsPool.Get_MCount:PInteger;
begin
  result:=@FMCount;
end;

{function TThreadsPool.Get_MCountExecProcThread:Integer;
begin
  result:=FMCountExecProcThread;
end;}

{function TThreadsPool.Get_MCountWakeupTask:PInteger;
begin
  result:=@FMCountWakeupTask;
end;}

{function TThreadsPool.Get_MCountNewTask:PInteger;
begin
  result:=@FMCountNewTask;
end;}

function TThreadsPool.Get_MNumberedMap:PInteger;
begin
  result:=@FMNumberedMap;
end;

function TThreadsPool.Get_MNumberedMapReady:PInteger;
begin
  result:=@FMNumberedMapReady;
end;

function TThreadsPool.WaitForExecuteTask(aMThread:IMThread):TDataCaseResultEvent;
type
  TWaitResult=(wfrShotdown{0}, wfrExecProcThread{1}, wfrNewTask{2}, wfrWakeupTask{3});
  var tmpTaskContext:TTaskContext;
      tmpEndTaskEvent:TEndTaskEvent;
      tmpParams:Variant;
      tmpCallerAction:ICallerAction;
      tmpResult:Variant;
  procedure localClearTaskContext; begin
    tmpTaskContext:=cnDefTaskContext;//Ставлю значения по умолчанию, чтобы заранее все было настроено
    fillchar(tmpEndTaskEvent, sizeof(tmpEndTaskEvent), 0);
    tmpTaskContext.aEndTaskEvent:=@tmpEndTaskEvent;
    tmpResult:=unassigned;
    tmpTaskContext.aResult:=@tmpResult;
    tmpCallerAction:=nil;
    tmpParams:=unassigned;
  end;
  var tmpCardinal:Cardinal;
      tmpWait:Cardinal;
      tmpInt64:Int64;
      tmpTask:TTask;
      tmpTHForMCountExecProcThread, tmpTHForMCountNewTask, tmpTHForMCountWakeupTask:integer;
      tmpMNumber, tmpLongWait:integer;
      tmpFMCountExecProcThread:integer;
      tmpExecThreadStruct:PExecThreadStruct;
begin
  result:=dreThreadUnusedTimeout;//от варнингов
  tmpMNumber:=aMThread.MNumber;
  if tmpMNumber=0 then tmpLongWait:=40 else begin
    tmpLongWait:=3;
    while tmpMNumber<>0 do begin
      tmpMNumber:=tmpMNumber shr 1;
      inc(tmpLongWait);
    end;
  end;
  while (not MThreadBreak)or(aMThread.ThreadTerminated) do begin
    if FTHForMCountExecProcThread<FMCountExecProcThread then tmpCardinal:=WAIT_OBJECT_0+Cardinal(wfrExecProcThread) else
    if FTHForMCountNewTask<FMCountNewTask then tmpCardinal:=WAIT_OBJECT_0+Cardinal(wfrNewTask) else
    if FTHForMCountWakeupTask<FMCountWakeupTask then tmpCardinal:=WAIT_OBJECT_0+Cardinal(wfrWakeupTask) else begin
      if aMThread.IsPerpetualM then tmpWait:=INFINITE else begin//вычисляю сколько ждать времени
        tmpInt64:=MSecsBetweenDateTime(aMThread.beginTimeOfInactivity, Now);//сколько уже прождал
        if tmpInt64>cnMaxMAmountOfInactivity then tmpWait:=0 else tmpWait:=cnMaxMAmountOfInactivity{сколько ждать всего}-tmpInt64;//сколько осталось ждать
      end;//жду
      tmpCardinal:=WaitForMultipleObjects(4, @FEvents[0], False, tmpWait);
    end;
    tmpCardinal:=tmpCardinal-WAIT_OBJECT_0;
    if tmpCardinal=Cardinal(wfrShotdown) then begin
      result:=dreThreadBreak;
      break;
    end;
    if tmpCardinal+WAIT_OBJECT_0=WAIT_TIMEOUT then begin
      result:=dreThreadUnusedTimeout;
      break;
    end;
    if (aMThread.IsPerpetualM)Or((aMThread.MNumber<>0)and((FMNumberedMapReady and(aMThread.MNumber-1))=0))Or((aMThread.MNumber=0)And(FMNumberedMapReady=0)) then begin//можно выполнять
      if tmpCardinal=Cardinal(wfrExecProcThread) then begin
        while true do begin
          tmpTHForMCountExecProcThread:=InterlockedIncrement(FTHForMCountExecProcThread);
          try
            tmpExecThreadStruct:=nil;//от варнингов
            tmpFMCountExecProcThread:=FMCountExecProcThread;
            if tmpTHForMCountExecProcThread<=tmpFMCountExecProcThread then begin//нужен
              //InternalSetMessage(now, 'FTHForMCountExecProcThread='+IntToStr(tmpTHForMCountExecProcThread)+' <= FMCountExecProcThread='+IntToStr(tmpFMCountExecProcThread)+'. Нужен.', mecApp, mesWarning);
              tmpExecThreadStruct:=ITExecProcThreadForThread;
            end else begin
              //InternalSetMessage(now, 'FTHForMCountExecProcThread='+IntToStr(tmpTHForMCountExecProcThread)+' > FMCountExecProcThread='+IntToStr(tmpFMCountExecProcThread)+'. Не нужен.', mecApp, mesWarning);
              break;//не нужен
            end;
          finally
            InterlockedDecrement(FTHForMCountExecProcThread);
          end;
          if assigned(tmpExecThreadStruct) then begin
            aMThread.ITState:=stsBusy;
            try
              ITExecProcThreadForThreadImpl(tmpExecThreadStruct);
            finally
              aMThread.ITState:=stsReady;
            end;
          end else begin
            sleep(0);
            break;//все, больше нет заявок в очереди
          end;
        end;
        case WaitForMultipleObjects(2, @FEvents[2], False, 0) of//не нужен, смотрю что дальше делать
          WAIT_OBJECT_0:tmpCardinal:=Cardinal(wfrNewTask);
          WAIT_OBJECT_0+1:tmpCardinal:=Cardinal(wfrWakeupTask);
        else
          if not (aMThread.IsPerpetualM) then begin
            aMThread.ITState:=stsWait;
            sleep(3);//жду
            //InternalSetMessage(now, 'WaitForExecuteTask: sleep(3);//не нужен, жду', mecApp, mesWarning);
            aMThread.ITState:=stsReady;
          end else sleep(0);
          continue;//в начало
        end;
        //InternalSetMessage(now, 'Есть др. задача='+IntToStr(Integer(tmpCardinal)), mecApp, mesWarning);
      end;
      if tmpCardinal=Cardinal(wfrNewTask) then begin
        while true do begin
          tmpTHForMCountNewTask:=InterlockedIncrement(FTHForMCountNewTask);
          try
            tmpTask:=tskMTNone;//от варнингов
            if tmpTHForMCountNewTask<=FMCountNewTask then begin
              localClearTaskContext;
              tmpTask:=ITMTaskView(@tmpParams, tmpCallerAction, tmpTaskContext.aCallerTask, tmpTaskContext.aEndTaskEventI, tmpTaskContext.aEndTaskEvent, @tmpTaskContext.aTaskID);
            end else break;
          finally
            InterlockedDecrement(FTHForMCountNewTask);
          end;
          if tmpTask<>tskMTNone then begin
            aMThread.ITState:=stsBusy;
            try
              if not((assigned(tmpTaskContext.aEndTaskEvent^.aOnComplete))or(assigned(tmpTaskContext.aEndTaskEvent^.aOnError))or(assigned(tmpTaskContext.aEndTaskEvent^.aOnCanceled))) then tmpTaskContext.aEndTaskEvent:=nil;
              if (assigned(tmpTaskContext.aCallerTask))and(not assigned(tmpTaskContext.aResult)) then tmpTaskContext.aResult:=tmpTaskContext.aCallerTask.ResultPtr;
              FTaskImplement.TasksImplements(tmpCallerAction, tmpTask, tmpParams, @tmpTaskContext);
            finally
              aMThread.ITState:=stsReady;
            end;
          end else break;
        end;
        if WaitForSingleObject(FEvents[3], 0)=WAIT_OBJECT_0 then tmpCardinal:=Cardinal(wfrWakeupTask) else begin//не нужен, смотрю что дальше делать
          if not (aMThread.IsPerpetualM) then begin
            aMThread.ITState:=stsWait;
            sleep(3);//жду
            aMThread.ITState:=stsReady;
          end else sleep(0);
          continue;
        end;
      end;
      if tmpCardinal=Cardinal(wfrWakeupTask) then begin
        while true do begin
          tmpTHForMCountWakeupTask:=InterlockedIncrement(FTHForMCountWakeupTask);
          try
            tmpTask:=tskMTNone;//от варнингов
            if tmpTHForMCountWakeupTask<=FMCountWakeupTask then begin//нужен
              localClearTaskContext;
              tmpTask:=ITMSleepTaskView(@tmpParams, tmpCallerAction, tmpTaskContext.aCallerTask, tmpTaskContext.aEndTaskEventI, tmpTaskContext.aEndTaskEvent, {@tmpWakeup}nil{aWakeup}, @tmpTaskContext.aTaskID);
            end else break;
          finally
            InterlockedDecrement(FTHForMCountWakeupTask);
          end;
          if tmpTask<>tskMTNone then begin
            aMThread.ITState:=stsBusy;
            try
              if not((assigned(tmpTaskContext.aEndTaskEvent^.aOnComplete))or(assigned(tmpTaskContext.aEndTaskEvent^.aOnError))or(assigned(tmpTaskContext.aEndTaskEvent^.aOnCanceled))) then tmpTaskContext.aEndTaskEvent:=nil;
              if (assigned(tmpTaskContext.aCallerTask))and(not assigned(tmpTaskContext.aResult)) then tmpTaskContext.aResult:=tmpTaskContext.aCallerTask.ResultPtr;
              FTaskImplement.TasksImplements(tmpCallerAction, tmpTask, tmpParams, @tmpTaskContext);
            finally
              aMThread.ITState:=stsReady;
            end;
          end else break;
        end;//InternalSetMessage(now, 'Delta='+TwoDateTimeToDurationStr(now, tmpWakeup), mecApp, mesWarning);
        if not (aMThread.IsPerpetualM) then begin
          aMThread.ITState:=stsWait;
          sleep(3);//жду
          aMThread.ITState:=stsReady;
        end else sleep(0);
        continue;
      end;
    end else begin//ненужен совсем
      aMThread.ITState:=stsWait;
      try
        sleep(tmpLongWait);//долго жду
        //InternalSetMessage(now, 'WaitForExecuteTask: //ненужен совсем//долго жду. sleep('+IntToStr(tmpLongWait)+')', mecApp, mesWarning);
      finally
        aMThread.ITState:=stsReady;
      end;
    end;
  end;
end;

function TThreadsPool.ITMIgnoreTaskCheck(aTask:TTask):Boolean;
begin
  Internallock;
  try
    Result:=InternalMIgnoreTaskCheck(aTask);
  finally
    Internalunlock;
  end;
end;

function TThreadsPool.InternalMIgnoreTaskCheck(aTask:TTask):Boolean;
  var tmpI:Integer;
begin
  Result:=False;
  try
    if (VarType(FMIgnoreTask) and varArray)=varArray then begin//Существует Array//Ищу
      for tmpI:=VarArrayLowBound(FMIgnoreTask, 1) to VarArrayHighBound(FMIgnoreTask, 1) do begin
        if FMIgnoreTask[tmpI]=aTask Then begin//Нашел
          Result:=True;
          Break;
        end;
      end;
    end;
  except on e:exception do begin
    e.Message:='IMIgnoreTaskCheck: '+e.Message;
    raise;
  end;end;
end;

procedure InternalIntroCallOnWakeup(aUserData:Pointer; aVarset:IVarset);
begin
  InternalIntroCallSleepView(aUserData, aVarset, nil);
  //TThreadsPool(aUserData).FWakeupTimer.Enabled:=false;
  //inc(TThreadsPool(aUserData).FMCountWakeupTask, 1);
  //SetEvent(TThreadsPool(aUserData).FEvents[3]);
  //TThreadsPool(aUserData).InternalSetMessage(now, 'InternalIntroCallOnWakeup: add FMCountWakeupTask='+IntToStr(TThreadsPool(aUserData).FMCountWakeupTask)+'.', mecApp, mesWarning);
end;

procedure TThreadsPool.InternalOnWakeup(Sender:TObject);
  var tmpIntroCallStruct:TIntroCallStruct;
begin
  //FWakeupTimer.Enabled:=false;//!!??
  tmpIntroCallStruct.UserData:=self;
  tmpIntroCallStruct.OnIntroCall:=InternalIntroCallOnWakeup;
  FVSMSleepTasks.ITIntroCall(@tmpIntroCallStruct);//tmpNextWakeup:=FVSMSleepTasks.ITGetNextTimeWakeupAfterTime(@tmpBeforeNowTimeWakeup, now);//опредиляю солько потов надо запустить и когда след. Wakeup//while tmpBeforeNowTimeWakeup<>0 do begin//наращиваю счетчик потоков//  dec(tmpBeforeNowTimeWakeup);//  InterlockedIncrement(FMCountWakeupTask);//end;//SetEvent(FEvents[3]);//запускаю потоки на выполнение//InternalSetNextTimeWakeup(tmpNextWakeup);//ставлю NextWakeup
end;

function TThreadsPool.InternalShotDown:boolean;
begin
  result:=false;
end;

procedure TThreadsPool.InternalSetNextTimeWakeup(aNextTimeWakeup:TDateTime);
  var tmpInt64:Int64;
      tmpEnabled:boolean;
begin
  if ((FNextTimeWakeup=aNextTimeWakeup)and(FNextTimeWakeup<>0))Or(not assigned(FWakeupTimer)) then exit;
  FWakeupTimer.Enabled:=false;
  tmpEnabled:=true;
  try
    try
      if InternalShotDown then begin//Сервер выключается
        tmpEnabled:=false;
      end else begin
        if aNextTimeWakeup=0 Then begin
          if FVSMSleepTasks.ITCount=0 then begin
            tmpEnabled:=False;
            FWakeupTimer.Interval:=0;
          end else begin
            FWakeupTimer.Interval:=30000;{30sec}
            tmpEnabled:=True;
            tmpInt64:=DateTimeToMSecs(now)+FWakeupTimer.Interval;
            aNextTimeWakeup:=MSecsToDateTime(tmpInt64);
            InternalSetMessage(now, 'FVSMSleepTasks.ITCount<>0 & aNextTimeWakeup=0! SET 30sec.', mecApp, mesError);
          end;
        end else begin
          if Now>aNextTimeWakeup Then tmpInt64:=0 else tmpInt64:=MSecsBetweenDateTime(now, aNextTimeWakeup);
          if tmpInt64=0 then begin//уже пора
            tmpInt64:=1;
          end else if tmpInt64>90000{1,5min}{54000000}{15min} then tmpInt64:=90000;//54000000;
          FWakeupTimer.Interval:=tmpInt64;
          tmpEnabled:=true;
        end;
        FNextTimeWakeup:=aNextTimeWakeup;
      end;
    except on e:exception do begin
      FWakeupTimer.Interval:=30000;{30sec}
      tmpEnabled:=true;
      InternalSetMessage(now, 'InternalSetNextTimeWakeup: '+e.message, mecApp, mesError);
    end;end;
  finally
    FWakeupTimer.Enabled:=tmpEnabled;
  end;
end;

procedure TThreadsPool.ITMTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aTaskNumbered:Integer; aPTaskID:PInteger);
begin
  Internallock;
  try
    try
      InternalCheckStateAsTrayForWork(true{aRaise});
      InternalMTaskAdd(aTask, aCallerAction, aParams, aTaskNumbered, aPTaskID);
    except On e:exception do begin
      e.message:='ITMTaskAdd: '+e.message;
      raise;
    end;end;
  finally
    Internalunlock;
  end;
end;

procedure TThreadsPool.ITMTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction);
begin
  ITMTaskAdd(aTask, aParams, aCallerAction, -1, nil);
end;

procedure TThreadsPool.ITMSleepTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aSleep:LongWord);
begin
  ITMSleepTaskAdd(aTask, aParams, aCallerAction, aSleep, -1, nil);
end;

procedure TThreadsPool.ITMSleepTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aSleep:LongWord; aTaskNumbered:Integer; aPTaskID:PInteger);
begin
  Internallock;
  try
    try
      InternalCheckStateAsTrayForWork(true{aRaise});
      InternalMSleepTaskAdd(aTask, aCallerAction, aParams, MSecsToDateTime(aSleep+DateTimeToMSecs(Now)), aTaskNumbered, aPTaskID);
    except On e:exception do begin
      e.message:='ITMSleepTaskAdd: '+e.message;
      raise;
    end;end;
  finally
    Internalunlock;
  end;
end;

procedure TThreadsPool.ITMWakeUpTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aWakeup:TDateTime);
begin
  ITMWakeUpTaskAdd(aTask, aParams, aCallerAction, aWakeup, -1, nil);
end;

procedure TThreadsPool.ITMWakeUpTaskAdd(aTask:TTask; const aParams:Variant; aCallerAction:ICallerAction; aWakeup:TDateTime; aTaskNumbered:Integer; aPTaskID:PInteger);
begin
  Internallock;
  try
    try
      InternalCheckStateAsTrayForWork(true{aRaise});
      InternalMSleepTaskAdd(aTask, aCallerAction, aParams, aWakeup, aTaskNumbered, aPTaskID);
    except On e:exception do begin
      e.message:='ITMWakeUpTaskAdd: '+e.message;
      raise;
    end;end;
  finally
    Internalunlock;
  end;
end;

function TThreadsPool.ITNLExecProcThread(aExecThreadStruct:PExecThreadStruct; aRaise:Boolean):Boolean;
  var tmpPointer:Pointer;
      tmpIntroCallStructData:TIntroCallStructData;
      tmpIntroCallUserData:TIntroCallUserData;
      tmpVarsetData:IVarsetData;
begin
  result:=InternalCheckStateAsTrayForWork(aRaise);
  if not result then exit;
  if not assigned(aExecThreadStruct) then begin
    if aRaise then raise exception.createFmtHelp(cserInvalidValueOf, ['aExecThreadStruct'], cnerInvalidValueOf);
    result:=false;
    exit;
  end;
  Getmem(tmpPointer, Sizeof(TExecThreadStruct));
  try
    Move(aExecThreadStruct^, tmpPointer^, Sizeof(TExecThreadStruct));
    tmpIntroCallUserData.aHandle:=@FEvents[1];
    tmpIntroCallUserData.aCounter:=@FMCountExecProcThread;
    tmpIntroCallUserData.aThreadsPool:=self;
    tmpIntroCallStructData.UserData:=@tmpIntroCallUserData;
    if assigned(aExecThreadStruct^.UserIUnknown) then aExecThreadStruct^.UserIUnknown._AddRef;
    tmpIntroCallStructData.OnIntroCallData:=InternalIntroCallAdd;
    tmpVarsetData:=TVarsetData.create;
    tmpVarsetData.ITData:=Integer(tmpPointer);
    FExecProcThread.ITPushIC(tmpVarsetData, @tmpIntroCallStructData);//?InterlockedIncrement(FMCountExecProcThread);//увеличиваю счетчик количества запросов
  except
    Freemem(tmpPointer);
    raise;
  end;//ITNLForceGetReadyM;//Проверка возможности выполнения
  result:=true;
end;

function TThreadsPool.ITExecProcThreadForThread:PExecThreadStruct;
  var tmpInteger:Integer;
      tmpVarsetData:IVarsetData;
      tmpIntroCallStructData:TIntroCallStructData;
      tmpIntroCallUserData:TIntroCallUserData;
begin
  tmpIntroCallUserData.aHandle:=@FEvents[1];
  tmpIntroCallUserData.aCounter:=@FMCountExecProcThread;
  tmpIntroCallUserData.aThreadsPool:=self;
  tmpIntroCallStructData.UserData:=@tmpIntroCallUserData;
  tmpIntroCallStructData.OnIntroCallData:=InternalIntroCallDec;
  tmpVarsetData:=FExecProcThread.ITPopIC(True, @tmpIntroCallStructData);
  if assigned(tmpVarsetData)and(not VarIsEmpty(tmpVarsetData.ITData)) then begin
    tmpInteger:=tmpVarsetData.ITData;
    result:=Pointer(tmpInteger);
  end else begin
    result:=nil;
  end;
end;

procedure TThreadsPool.ITExecProcThreadForThreadImpl(aExecThreadStruct:PExecThreadStruct);
begin
  if not Assigned(aExecThreadStruct) Then exit;
  try
    try
      if Assigned(aExecThreadStruct^.ThreadProc) Then aExecThreadStruct^.ThreadProc(aExecThreadStruct^.UserPointer, aExecThreadStruct^.UserIUnknown);
      if Assigned(aExecThreadStruct^.ThreadProcOfObject) Then aExecThreadStruct^.ThreadProcOfObject(aExecThreadStruct^.UserPointer, aExecThreadStruct^.UserIUnknown);
    except on e:exception do begin
      if Assigned(aExecThreadStruct^.ExceptThreadProc) then aExecThreadStruct^.ExceptThreadProc(aExecThreadStruct^.UserPointer, aExecThreadStruct^.UserIUnknown, e.message, e.HelpContext) else
        if Assigned(aExecThreadStruct^.ExceptThreadProcOfObject) then aExecThreadStruct^.ExceptThreadProcOfObject(aExecThreadStruct^.UserPointer, aExecThreadStruct^.UserIUnknown, e.message, e.HelpContext) else begin
          e.Message:='ThreadProc: '+e.Message;
          raise;
        end;
    end;end;
    if assigned(aExecThreadStruct^.UserIUnknown) Then aExecThreadStruct^.UserIUnknown._Release;
  finally
    Freemem(aExecThreadStruct);
  end;
end;

function TThreadsPool.ITMTaskCancel(aTaskID:Integer):Boolean;
  var tmpIntIndex:Integer;
      tmpIVarsetDataView:IVarsetDataView;

begin
  Internallock;
  result:=false;
  try//Сначала буду искать в спящих задачах
    tmpIntIndex:=-1;
    while true do begin
      tmpIVarsetDataView:=FVSMSleepTasks.ITViewNextGetOfIntIndex(tmpIntIndex);
      if tmpIntIndex=-1 then break;
      if tmpIVarsetDataView.ITData[6]=aTaskID then begin
        FVSMSleepTasks.ITClearOfIntIndex(tmpIVarsetDataView.ITIntIndex);
        Result:=true;
        exit;
      end;
    end;
    tmpIntIndex:=-1;
    while true do begin
      tmpIVarsetDataView:=FVSMTasks.ITViewNextGetOfIntIndex(tmpIntIndex);
      if tmpIntIndex=-1 then break;
      if tmpIVarsetDataView.ITData[4]=aTaskID then begin
        FVSMTasks.ITClearOfIntIndex(tmpIVarsetDataView.ITIntIndex);
        Result:=true;
        exit;
      end;
    end;
    tmpIVarsetDataView:=Nil;
  finally
    Internalunlock;
  end;
end;

procedure TThreadsPool.ITMIgnoreTaskAdd(aTask:TTask);
  var tmpHB:Integer;
begin
  Internallock;
  try//проверяю есть ли такое игнорире уже
    if InternalMIgnoreTaskCheck(aTask) then exit;
    try
      if (VarType(FMIgnoreTask) and varArray)<>varArray then begin//FMIgnoreTask is empty
        FMIgnoreTask:=VarArrayCreate([0,0], varInteger);
      end else begin
        tmpHB:=VarArrayHighBound(FMIgnoreTask, 1);
        if tmpHB>50 Then raise exception.create('FMIgnoreTask переполнен(Count=50).');
        VarArrayRedim(FMIgnoreTask, tmpHB+1);
      end;//Теперь существует Array и в нем последняя ячейка свободна
      FMIgnoreTask[VarArrayHighBound(FMIgnoreTask, 1)]:=aTask; // добавляю новую команду которая теперь будет игнорироваться
    except on e:exception do begin
      e.Message:='ITMIgnoreTaskAdd: '+e.Message;
      raise;
    end;end;
  finally
    Internalunlock;
  end;
end;

function TThreadsPool.ITMIgnoreTaskCancel(aTask:TTask):Boolean;
var tmpLB, tmpHB, tmpI:Integer;
begin
  Internallock;
  Result:=False;
  try
    try
      if (VarType(FMIgnoreTask) and varArray)=varArray then begin//Существует Array
        tmpLB:=VarArrayLowBound(FMIgnoreTask, 1);
        tmpHB:=VarArrayHighBound(FMIgnoreTask, 1);//Ищу свободную
        tmpI:=tmpLB;
        While tmpI<=tmpHB do begin
          if FMIgnoreTask[tmpI]=aTask Then begin
            if tmpLB=tmpHB Then begin//Это единственная запись
              FMIgnoreTask:=Unassigned;
              Result:=True;
              Break;//выхожу из поиска
            end else begin//это не единственная запись
              Result:=True;
              FMIgnoreTask[tmpI]:=FMIgnoreTask[tmpHB];
              Dec(tmpHB);
              VarArrayRedim(FMIgnoreTask, tmpHB);
            end;
          end else begin//Если это не искомая то перехожу на следующую
            Inc(tmpI);
          end;
        end;
      end;
    except on e:exception do begin
      e.Message:='ITMIgnoreTaskCancel: '+e.Message;
      raise;
    end;end;
  finally
    Internalunlock;
  end;
end;

function TThreadsPool.ITMTask:Variant;
  var tmpCallerAction:ICallerAction;
  function localGetSenderParams:Variant;begin
    if assigned(tmpCallerAction) then begin
      result:=tmpCallerAction.SenderParams;
    end else result:=unassigned;
  end;
  var tmpIVarsetDataView:IVarsetDataView;
      tmpHB, tmpIntIndex:Integer;
      tmpV:Variant;
      tmpIUnknown:IUnknown;
begin
  Internallock;
  try
    Result:=VarArrayCreate([0,1], varVariant);
    tmpV:=Unassigned;
    tmpHB:=-1;
    tmpIntIndex:=-1;
    while true do begin
      tmpIVarsetDataView:=FVSMTasks.ITViewNextGetOfIntIndex(tmpIntIndex);
      if tmpIntIndex=-1 then break;
      if tmpHB=-1 then begin
        tmpV:=VarArrayCreate([0, 0], varVariant);
        tmpHB:=0;
      end else begin
        VarArrayRedim(tmpV, tmpHB+1);
        Inc(tmpHB);
      end;
      tmpIUnknown:=tmpIVarsetDataView.ITData[2];
      if (not assigned(tmpIUnknown))or(tmpIUnknown.QueryInterface(ICallerAction, tmpCallerAction)<>S_OK)or(not assigned(tmpCallerAction)) then tmpIUnknown:=nil;
      tmpV[tmpHB]:=VarArrayOf([tmpIVarsetDataView.ITData[0]{0}, tmpIVarsetDataView.ITData[1]{1}, localGetSenderParams{2}, tmpIVarsetDataView.ITData[3]{3}]);
    end;
    tmpIVarsetDataView:=Nil;
    Result[0]:=tmpV;
    VarClear(tmpV);
    //150404 Result[1]:=VarArrayOf([FMPerpetualCount{cnMMinCount}, FMMaxCount{cnMMaxCount}, FMCount, cnMaxMAmountOfInactivity, FMCountExecProcThread, FMCountDuringCreating]);
    Result[1]:=VarArrayOf([FMPerpetualCount{cnMMinCount}, FMMaxCount{cnMMaxCount}, FMCount, cnMaxMAmountOfInactivity, cnADOCCoutCurrent, cnADOCCoutMax]);
  finally
    Internalunlock;
  end;
end;

function TThreadsPool.ITMSleepTask:Variant;
  var tmpCallerAction:ICallerAction;
  function localGetSenderParams:Variant;begin
    if assigned(tmpCallerAction) then begin
      result:=tmpCallerAction.SenderParams;
    end else result:=unassigned;
  end;
  var tmpIVarsetDataView:IVarsetDataView;
      tmpHB, tmpIntIndex:Integer;
      tmpIUnknown:IUnknown;
begin
  Internallock;
  try
    Result:=Unassigned;
    tmpHB:=-1;
    tmpIntIndex:=-1;
    while true do begin
      tmpIVarsetDataView:=FVSMSleepTasks.ITViewNextGetOfIntIndex(tmpIntIndex);
      if tmpIntIndex=-1 then break;
      if tmpHB=-1 then begin
        Result:=VarArrayCreate([0, 0], varVariant);
        tmpHB:=0;
      end else begin
        VarArrayRedim(Result, tmpHB+1);
        Inc(tmpHB);
      end;                                                                                                                 
      tmpIUnknown:=tmpIVarsetDataView.ITData[2];
      if (not assigned(tmpIUnknown))or(tmpIUnknown.QueryInterface(ICallerAction, tmpCallerAction)<>S_OK)or(not assigned(tmpCallerAction)) then tmpIUnknown:=nil;
      Result[tmpHB]:=VarArrayOf([tmpIVarsetDataView.ITData[0]{0}, tmpIVarsetDataView.ITData[1]{1}, localGetSenderParams{2},
                                   tmpIVarsetDataView.ITWakeup{3}, tmpIVarsetDataView.ITData[3]{4}]);
    end;
    tmpIVarsetDataView:=Nil;
  finally
    Internalunlock;
  end;
end;

function TThreadsPool.ITMArray:variant;
  var tmpI:Integer;
      tmpM:IMThread;
      tmpIUnknown:IUnknown;
  function localGetTimeInactive:integer;begin
    if tmpM.IsPerpetualM then result:=0 else result:=Integer(MSecsBetweenDateTime(tmpM.beginTimeOfInactivity, Now));
  end;
begin
  Internallock;
  try
    Result:=unassigned;
    for tmpI:=VarArrayLowBound(FMArray, 1) to VarArrayHighBound(FMArray, 1) do begin
      if not VarIsArray(Result) Then begin
        Result:=VarArrayCreate([0,0], varVariant);
      end else begin
        VarArrayRedim(Result, VarArrayHighBound(Result, 1)+1);
      end;
      tmpIUnknown:=FMArray[tmpI]{[0]};
      if tmpIUnknown.QueryInterface(IMThread, tmpM)=S_OK then begin
        Result[VarArrayHighBound(Result, 1)]:=VarArrayOf([tmpM.ITState{0}, localGetTimeInactive{1}, tmpM.IsPerpetualM{2}, integer(tmpM.GetThreadID){3}]);
      end else Result[VarArrayHighBound(Result, 1)]:=VarArrayOf([0, 0, 0]);
    end;
  finally
    Internalunlock;
  end;
end;

function TThreadsPool.ITMTaskIgnore:Variant;
begin
  Internallock;
  try
    Result:=FMIgnoreTask;
  finally
    Internalunlock;
  end;
end;

function TThreadsPool.GetFAppMessage:IAppMessage;
  var tmpTray:ITray;
begin
  if not assigned(FFAppMessage) then begin
    tmpTray:=cnTray;
    if assigned(tmpTray) then tmpTray.Query(IAppMessage, FFAppMessage, true{raise});
  end;
  result:=FFAppMessage;
end;

function TThreadsPool.InternalUserName:AnsiString;
begin
  result:='';
end;

procedure TThreadsPool.InternalSetMessage(aStartTime:TDateTime; const aMessage:AnsiString; aMec:TMessageClass; aMes:TMessageStyle);
begin
  if assigned(FAppMessage) then FAppMessage.ITMessAdd(aStartTime, now, InternalUserName, 'ThrPool', aMessage, aMec, aMes);
end;

end.
