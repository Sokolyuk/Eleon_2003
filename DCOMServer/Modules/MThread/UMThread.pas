unit UMThread;

interface
  uses UMThreadTypes, UAppMessageTypes, Classes, Windows, UThreadsPoolTypes, ULogFileTypes, UTrayTypes;
type
  TMThread=class(TThread, IUnknown, IMThread)
  protected
    CSLock:TRTLCriticalSection;
    FRefCount:Integer;
    FThreadsPool:IThreadsPool;
  protected
    FIsPerpetualM:boolean;
    FState:TMThreadState;
    FExitExecute:Boolean;
    FThreadBreak:Boolean;
    FBeginTimeOfInactivity:TDateTime;
    FStartTime, FStartBysyTime:TDateTime;
    FRegistered:Boolean;
    FMNumber:Integer;
    FLogFile:ILogFile;
    FAppMessage:IAppMessage;
    procedure InternalSetMessage(aStartTime:TDateTime; const aMessage:AnsiString; amecMess:TMessageClass; amesMess:TMessageStyle);overload;virtual;
    procedure InternalSetMessage(aStartTime, aEndTime:TDateTime; const aMessage:AnsiString; amecMess:TMessageClass; amesMess:TMessageStyle);overload;virtual;
    function InternalGetUserName(aTray:ITray):AnsiString;virtual;
    function GetRegistered:Boolean;virtual;
    procedure SetRegistered(Value:Boolean);virtual;
  protected
    {IUnknown}
    function QueryInterface(const IID:TGUID; out Obj):HResult;virtual;stdcall;
    function _AddRef:Integer;virtual;stdcall;
    function _Release:Integer;virtual;stdcall;
  protected
    procedure InternalLock;virtual;
    procedure InternalLockWait(aWait:Integer);virtual;
    function InternalTryLock:Boolean;virtual;
    procedure InternalUnLock;virtual;
    function GetMNumber:Integer;virtual;
  protected
    procedure Execute;override;
    procedure InternalStartM;
    function ITGetState:TMThreadState;virtual;
    procedure ITSetState(Value:TMThreadState);virtual;
    property MNumber:Integer read GetMNumber;
    function GetIsPerpetualM:boolean;virtual;
    function GetBeginTimeOfInactivity:TDateTime;virtual;
    function GetGetThreadID:Cardinal;virtual;
    function GetThreadBreak:Boolean;virtual;
    procedure SetThreadBreak(value:Boolean);virtual;
    function GetThreadTerminated:boolean;virtual;
  public
    constructor Create(aCreateSuspended:Boolean; aPerpetual:Boolean; aThreadsPool:IThreadsPool);
    destructor destroy;override;
    Property ITState:TMThreadState read ITGetState write ITSetState;
    property BeginTimeOfInactivity:TDateTime read GetBeginTimeOfInactivity;
    property Registered:Boolean read GetRegistered write SetRegistered;
    property IsPerpetualM:boolean read GetIsPerpetualM;
    property GetThreadID:Cardinal read GetGetThreadID;
    property ThreadBreak:boolean read GetThreadBreak write SetThreadBreak;
    property ThreadTerminated:boolean read GetThreadTerminated;
  end;

implementation
  uses Sysutils, UTrayConsts, ActiveX, UCalculus, UDateTimeUtils, UMThreadConsts, UMThreadUtils;

constructor TMThread.Create(aCreateSuspended:Boolean; aPerpetual:Boolean; aThreadsPool:IThreadsPool);
begin
  FStartTime:=Now;
  FStartBysyTime:=0;
  InterLockedIncrement(cnMThreadCount);
  InterLockedIncrement(cnMThreadCreatedCount);
  if not assigned(aThreadsPool) then raise exception.create('aThreadsPool is not assigned.');
  inherited create(aCreateSuspended);
  FRefCount:=0;
  InitializeCriticalSection(CSLock);
  FreeOnTerminate:=True;
  FExitExecute:=False;
  FThreadBreak:=False;
  //State
  FState:=stsWait;
  FRegistered:=False;
  //Create params
  FBeginTimeOfInactivity:=Now;
  FIsPerpetualM:=False;
  FIsPerpetualM:=aPerpetual;
  FMNumber:=0;//установитс€ в ITRegMThread
  FThreadsPool:=aThreadsPool;
  FLogFile:=nil;
  FAppMessage:=nil;
  InterlockedIncrement(FThreadsPool.MCountDuringCreating^);
end;

destructor TMThread.destroy;
  function localMN:AnsiString;begin
    if FIsPerpetualM then result:=' Is perpetual.';
    result:=result+' MN='+Int64ToSBase(FMNumber, 2);
  end;
  Var tmpCreationTime, tmpExitTime, tmpKernelTime, tmpUserTime:TFileTime;
      tmpSystemTime:TSystemTime;
      tmpSt:AnsiString;
      tmpInt64:Int64;
      tmpDouble:Double;
begin
  try
    if GetThreadTimes(Handle, tmpCreationTime, tmpExitTime, tmpKernelTime, tmpUserTime) then begin
      FileTimeToSystemTime(tmpExitTime, tmpSystemTime);
      tmpSt:='/KernelTime='+TwoDateTimeToDurationStr(-109205, SystemTimeToDateTime(tmpSystemTime));
      tmpInt64:=MSecsBetweenDateTime(-109205, SystemTimeToDateTime(tmpSystemTime));
      if tmpInt64=0 then tmpSt:='' else begin
        tmpSt:=tmpSt+', UserTime='+MSecsToDurationStr(tmpInt64);
        tmpDouble:=DateTimeToMSecs(Now)-DateTimeToMSecs(FStartTime);
        tmpDouble:=(tmpInt64/tmpDouble)*100;
        tmpSt:=tmpSt+', Usage='+FloatToStrF(tmpDouble, ffFixed, 1, 2)+'%';
      end;
    end else begin
      tmpSt:=' GetThreadTimes: '+SysErrorMessage(GetLastError);
    end;
    InternalSetMessage(FStartTime, 'Done thread.'+localMN+tmpSt, mecApp, mesInformation);
  except end;
  FLogFile:=nil;
  FAppMessage:=nil;
  if not Terminated then begin
    Terminate;
    WaitFor;
  end;
  Registered:=false;//разрегистрируетс€ в FThreadsPool
  FThreadsPool:=nil;
  DeleteCriticalSection(CSLock);
  inherited destroy;
  InterLockedDecrement(cnMThreadCount);
end;

{TMThread.IUnknown}
function TMThread.QueryInterface(const IID:TGUID; out Obj):HResult;
begin
  if GetInterface(IID, Obj) then Result:=S_OK else Result:=E_NOINTERFACE;
end;

function TMThread._AddRef:Integer;
begin
  Result:=InterLockedIncrement(FRefCount);
end;

function TMThread._Release:Integer;
begin
  Result:=InterLockedDecrement(FRefCount);
  if Result=0 then begin
    ThreadBreak:=true;
    FreeOnTerminate:=true;
    resume;
    terminate;
  end;
end;

{Lock}
procedure TMThread.InternalLock;
begin
  InternalLockWait(180000{3мин});
end;

procedure TMThread.InternalLockWait(aWait:Integer);
  var tmpI:Integer;
begin
  tmpI:=0;
  while not TryEnterCriticalSection(CSLock) do begin
    if aWait<=0 then raise exception.create('TMThread('''+ClassName+''').InternalLock(CSLock.LockCount='+IntToStr(CSLock.LockCount)+', CSLock.OwningThread='+IntToStr(CSLock.OwningThread)+').');//не разлочилс€
    dec(aWait, 20);
    if tmpI>=200 then begin//каждые 200msec провер€ю поток на Terminated.
      if MThreadBreak then raise exception.create('MThreadBreak is true.');
      tmpI:=0;
    end else inc(tmpI, 20);
    Sleep(20);
  end;
end;

function TMThread.InternalTryLock:Boolean;
begin
  Result:=TryEnterCriticalSection(CSLock);
end;

procedure TMThread.InternalUnLock;
begin
  LeaveCriticalSection(CSLock);
end;

function TMThread.InternalGetUserName(aTray:ITray):AnsiString;
begin
  result:='';
end;

procedure TMThread.InternalSetMessage(aStartTime:TDateTime; const aMessage:AnsiString; amecMess:TMessageClass; amesMess:TMessageStyle);
begin
  InternalSetMessage(aStartTime, now, aMessage, amecMess, amesMess);
end;

procedure TMThread.InternalSetMessage(aStartTime, aEndTime:TDateTime; const aMessage:AnsiString; amecMess:TMessageClass; amesMess:TMessageStyle);
  var tmpTray:ITray;
begin
  tmpTray:=cnTray;
  if assigned(tmpTray) then begin
    try
      if not assigned(FAppMessage) then begin
        tmpTray.Query(IAppMessage, FAppMessage, false);
      end;
      if assigned(FAppMessage) then FAppMessage.ITMessAdd(aStartTime, aEndTime, InternalGetUserName(tmpTray), 'MThread', aMessage, amecMess, amesMess);
    except
      if not assigned(FLogFile) then begin
        try tmpTray.Query(ILogFile, FLogFile, false); except end;
      end;
      if assigned(FLogFile) then try FLogFile.ITWriteLnToLog(FormatDateTime('ddmmyy hh:nn:ss.zzz', now)+#9+'Thr#'+IntToStr(Integer(GetCurrentThreadId))+#9+aMessage+'"'); except end;
    end;
  end;  
end;

function TMThread.ITGetState:TMThreadState;
begin
  Internallock;
  try
    Result:=FState;
  finally
    Internalunlock;
  end;
end;

procedure TMThread.ITSetState(Value:TMThreadState);
begin
  Internallock;
  try
    if (FRegistered)And(Value=stsBusy) then begin//—тал Busy.
      case FState of
        stsReady:begin//был Ready.
          InterlockedDecrement(FThreadsPool.MCountReady^);//убираю из общего счетчика Ready-потоков
          if FIsPerpetualM then InterlockedDecrement(FThreadsPool.MCountPerpetualReady^);//убираю из общего счетчика PerpetualReady-потоков
          if FMNumber<>0 then InterlockedExchangeAdd(PLongint(FThreadsPool.MNumberedMapReady){^}, -FMNumber);//убираю из MapReady
        end;
        stsWait:begin//был Wait.
          InterlockedDecrement(FThreadsPool.MCountWait^);//убираю из общий счетчик Wait-потоков
        end;
      end;
      FStartBysyTime:=now;
    end else if (FRegistered)And(Value=stsReady) then begin//Ready стал.
      InterlockedIncrement(FThreadsPool.MCountReady^);//ставлю в общий счетчик Ready-потоков
      if FIsPerpetualM then InterlockedIncrement(FThreadsPool.MCountPerpetualReady^);//ставлю в общий счетчик PerpetualReady-потоков
      if FMNumber<>0 then InterlockedExchangeAdd(PLongint(FThreadsPool.MNumberedMapReady){^}, FMNumber);//ставлю в MapReady
      case FState of
        stsBusy:begin//был Busy.
          FBeginTimeOfInactivity:=Now;
        end;
        stsWait:begin//был Wait.
          InterlockedDecrement(FThreadsPool.MCountWait^);//убираю из общего счетчика Wait-потоков
        end
      end;
    end else if (FRegistered)And(Value=stsWait) then begin//—тал Wait.
      InterlockedIncrement(FThreadsPool.MCountWait^);//ставлю в общий счетчик Wait-потоков
      case FState of
        stsReady:begin//был Ready.
          InterlockedDecrement(FThreadsPool.MCountReady^);//убираю из общего счетчика Ready-потоков
          if FIsPerpetualM then InterlockedDecrement(FThreadsPool.MCountPerpetualReady^);//убираю из общего счетчика PerpetualReady-потоков
          if FMNumber<>0 then InterlockedExchangeAdd(PLongint(FThreadsPool.MNumberedMapReady){^}, -FMNumber);//убираю из MapReady
        end;
        stsBusy:begin//был Busy.
          FBeginTimeOfInactivity:=Now;
        end;
      end;
    end;
    FState:=Value;
  finally
    Internalunlock;
  end;
end;

function TMThread.GetRegistered:Boolean;
begin
  Internallock;
  try
    result:=FRegistered;
  finally
    Internalunlock;
  end;
end;

procedure TMThread.SetRegistered(Value:Boolean);
begin
  Internallock;
  try
    if (Value)and(not FRegistered) then begin//–егистрируетс€
      InterlockedIncrement(FThreadsPool.MCount^);//ставлю в общий счетчик потоков
      InterlockedIncrement(FThreadsPool.MCountPerpetual^);//ставлю в общий счетчик потоков
      if FState=stsReady then begin//в состо€нии Ready
        InterlockedIncrement(FThreadsPool.MCountReady^);//ставлю в общий счетчик Ready-потоков
        if FIsPerpetualM then InterlockedIncrement(FThreadsPool.MCountPerpetualReady^);//ставлю в общий счетчик PerpetualReady-потоков
        if FMNumber<>0 then InterlockedExchangeAdd(PLongint(FThreadsPool.MNumberedMapReady){^}, FMNumber);//ставлю в MapReady
      end else if FState=stsWait then begin//в состо€нии Wait
        InterlockedIncrement(FThreadsPool.MCountWait^);//ставлю в общий счетчик Wait-потоков
      end;
      if FMNumber<>0 then InterlockedExchangeAdd(PLongint(FThreadsPool.MNumberedMap){^}, FMNumber);//ставлю в Map
    end;
    if (not Value)and(FRegistered) then begin//–азрегистрируетс€
      if FState=stsReady then begin//в состо€нии Ready
        InterlockedDecrement(FThreadsPool.MCountReady^);//убираю из общего счетчика Ready-потоков
        if FIsPerpetualM then InterlockedDecrement(FThreadsPool.MCountPerpetualReady^);//убираю из общего счетчика PerpetualReady-потоков
        if FMNumber<>0 then InterlockedExchangeAdd(PLongint(FThreadsPool.MNumberedMapReady){^}, -FMNumber);//убираю из MapReady
      end else if FState=stsWait then begin//в состо€нии Wait
        InterlockedDecrement(FThreadsPool.MCountWait^);//убираю из общий счетчик Wait-потоков
      end;
      if FMNumber<>0 then InterlockedExchangeAdd(PLongint(FThreadsPool.MNumberedMap){^}, -FMNumber);//убираю из Map
      InterlockedDecrement(FThreadsPool.MCount^);//убираю из общего счетчика потоков
      InterlockedDecrement(FThreadsPool.MCountPerpetual^);//убираю из общего счетчика потоков
    end;
    FRegistered:=Value;
  finally
    Internalunlock;
  end;
end;

procedure TMThread.Execute;
  var tmpTObject:TObject;
begin
  try
    try
      if not Succeeded(CoInitializeEx(nil, COINIT_MULTITHREADED)) then begin
        raise exception.create('Ќе удаетс€ выполнить CoInitializeEx.');
      end;
    finally
      InterlockedDecrement(FThreadsPool.MCountDuringCreating^);//надо сразу убрать, т.к. если останетс€ MCountDuringCreating>0, еще не создастс€ ни один поток.
    end;
    try
      try
        if (cnTlsThreadBreak<>cnTlsNoIndex)and(not TlsSetValue(cnTlsThreadBreak, @FThreadBreak)) then raise exception.create('TlsSetValue(cnTlsThreadBreak): '+SysErrorMessage(GetLastError));
        tmpTObject:=self;
        if (cnTlsMThreadObject<>cnTlsNoIndex)and(not TlsSetValue(cnTlsMThreadObject, pointer(tmpTObject))) then raise exception.create('TlsSetValue(cnTlsMThreadObject): '+SysErrorMessage(GetLastError));
        FThreadsPool.ITRegMThread(Self, @FMNumber);//регистрирую ы списке
        ITSetState(stsReady);
        InternalSetMessage(FStartTime, 'Init thread. MN='+Int64ToSBase(FMNumber, 2), mecApp, mesInformation);
        try
          InternalStartM;
        except on e:exception do begin
          InternalSetMessage(FStartTime, 'Execute: '+e.message, mecApp, mesError);
        end;end;
      finally
        FExitExecute:=True;
      end;
    finally
      CoUninitialize;
    end;
  except on e:exception do begin
    try InternalSetMessage(FStartTime, 'Init thread: '+e.message, mecApp, mesError); except end;
  end;end;
end;

procedure TMThread.InternalStartM;
begin
  try
    while not Terminated do begin
      try
        if ThreadBreak then sleep(100){ѕерестаю обрабатывать команды и жду _Release} else begin
          case FThreadsPool.WaitForExecuteTask(Self) of
            dreThreadBreak:sleep(100);
            dreThreadUnusedTimeout:begin
              if not FIsPerpetualM{вобщето это недоразумение} then begin
                FThreadsPool.ITDropMThread(Self);
                ThreadBreak:=true;
              end;  
            end;
          end;
        end;  
      except on e:exception do begin
        InternalSetMessage(FStartBysyTime, FBeginTimeOfInactivity, e.message+'/HC='+IntToStr(e.helpcontext), mecApp, mesError);
        sleep(10);
      end;end;  
    end;
  except on e:exception do
    InternalSetMessage(FStartTime, 'IStartM: '+e.message, mecApp, mesError);
  end;
end;

function TMThread.GetIsPerpetualM:boolean;
begin
  //??!Lock вроде пока не надо
  result:=FIsPerpetualM;
end;

function TMThread.GetBeginTimeOfInactivity:TDateTime;
begin
  Internallock;
  try
    result:=FBeginTimeOfInactivity;
  finally
    Internalunlock;
  end;
end;

function TMThread.GetMNumber:Integer;
begin
  //??!Lock вроде пока не надо
  result:=FMNumber;
end;

function TMThread.GetGetThreadID:Cardinal;
begin
  result:=ThreadID;
end;

function TMThread.GetThreadBreak:Boolean;
begin
  Internallock;
  try
    result:=FThreadBreak;
  finally
    Internalunlock;
  end;
end;

procedure TMThread.SetThreadBreak(value:Boolean);
begin
  Internallock;
  try
    FThreadBreak:=value;
  finally
    Internalunlock;
  end;
end;

function TMThread.GetThreadTerminated:boolean;
begin
  result:=Terminated;
end;

end.
