unit UPipeEServer;

interface
  uses UPipeServerBase, Classes, UPipeServerBaseTypes, UCallerTypes, UPipeEServeTypes, UServerProceduresTypes,
       UThreadsPoolTypes;
type
  TPipeMultiEServer=class(TPipeMultiServerBase)
  private
    FCallerAction:ICallerAction;
    FServerProcedures:IServerProcedures;
    FThreadsPool:IThreadsPool;
  protected
    function InternalGetIServerProcedures:IServerProcedures;virtual;
    function InternalGetIThreadsPool:IThreadsPool;virtual;
  protected
    procedure InternalSetMess(aStartTime:TDateTime; Const aMessage:AnsiString);override;
    procedure InternalSetMessErr(aStartTime:TDateTime; Const aMessage:AnsiString; aHelpContext:Integer);override;
    procedure InternalHandCallServer(aNamedPipe:INamedPipe);override;
    function CreateNamedPipe:TNamedPipe;override;
  public
    constructor Create(aCallerAction:ICallerAction; aCreateSuspended:Boolean; Const aPipeName:AnsiString);
    destructor Destroy;override;
    property CallerAction:ICallerAction read FCallerAction;
  end;

  TENamedPipe=class(TNamedPipe, IENamedPipe)
  private
    FCallerAction:ICallerAction;
    FStartTime:TDateTime;
    FServerProcedures:IServerProcedures;
  protected
    function GetCallerAction:ICallerAction;virtual;
    function GetStartTime:TDateTime;virtual;
    procedure SetStartTime(Value:TDateTime);virtual;
    function GetServerProcedures:IServerProcedures;virtual;
  public
    constructor Create(aCallerAction:ICallerAction; aServerProcedures:IServerProcedures; Const aPipeName:AnsiString);
    destructor Destroy;override;
    property CallerAction:ICallerAction read GetCallerAction;
    property StartTime:TDateTime read GetStartTime write SetStartTime;
    property ServerProcedures:IServerProcedures read GetServerProcedures;
  end;

var cnCallCount:Integer=0;

implementation
  uses Windows, Sysutils, UPipeServerUtils, UDataCaseExecProcTypes, UPipeEServerUtils, UErrorConsts,
       UTTaskTypes, Variants, UTypeUtils, UServerProcUtils, UAppMessageTypes, UTrayConsts, UServerProcTypes;

constructor TPipeMultiEServer.Create(aCallerAction:ICallerAction; aCreateSuspended:Boolean; Const aPipeName:AnsiString);
begin
  if not assigned(aCallerAction) then Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['aCallerAction'], cnerInvalidValueOf);
  FCallerAction:=aCallerAction;
  FServerProcedures:=nil;
  FThreadsPool:=nil;
  inherited Create(aCreateSuspended, aPipeName);
end;

destructor TPipeMultiEServer.Destroy;
begin
  FServerProcedures:=nil;
  FThreadsPool:=nil;
  inherited Destroy;
  FCallerAction:=nil;//т.к. в inherited Destroy; есть SetMessage
end;

procedure TPipeMultiEServer.InternalSetMess(aStartTime:TDateTime; Const aMessage:AnsiString);
begin
  if assigned(FCallerAction) then FCallerAction.ITMessAdd(aStartTime, Now, 'Pipe', aMessage, mecApp, mesInformation);
end;

procedure TPipeMultiEServer.InternalSetMessErr(aStartTime:TDateTime; Const aMessage:AnsiString; aHelpContext:Integer);
begin
  if assigned(FCallerAction) then FCallerAction.ITMessAdd(aStartTime, Now, 'Pipe', aMessage+'/HC='+IntToStr(aHelpContext), mecApp, mesError);
end;

procedure InternalThreadProcEServerStoredProc(aUserPointer:Pointer; aUserIUnknown:IUnknown);
  var tmpENamedPipe:IENamedPipe;
      tmpNamedPipe:INamedPipe;
      tmpProcName, tmpProcParams:AnsiString;
      tmpV:Variant;
      tmpServerProcExecParams:TServerProcExecParams;
begin
  If (not assigned(aUserIUnknown))Or(aUserIUnknown.QueryInterface(IENamedPipe, tmpENamedPipe)<>S_OK)Or(not assigned(tmpENamedPipe)) Then Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['aUserIUnknown'], cnerInvalidValueOf);
  If (aUserIUnknown.QueryInterface(INamedPipe, tmpNamedPipe)<>S_OK)Or(not assigned(tmpNamedPipe)) Then Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['aUserIUnknown'], cnerInvalidValueOf);
  EServerStoredProcViaCallNamedPipe(tmpNamedPipe, tmpProcName, tmpProcParams);
  tmpENamedPipe.CallerAction.ITMessAdd(now, tmpENamedPipe.StartTime, 'Pipe', 'ProcName='''+tmpProcName+'''', mecApp, mesInformation);
  tmpV:=glStringToVararray(tmpProcParams);
  fillchar(tmpServerProcExecParams, sizeof(tmpServerProcExecParams), 0);
  tmpServerProcExecParams.aServerProcedures:=tmpENamedPipe.ServerProcedures;
  tmpServerProcExecParams.aShowMessage:=true;
  ServerProcExec(tmpENamedPipe.CallerAction, tmpProcName, tmpV, @tmpServerProcExecParams);//Вызываю стореную процедуру
  InterlockedIncrement(cnCallCount);
end;

function TPipeMultiEServer.CreateNamedPipe:TNamedPipe;
begin
  result:=TENamedPipe.Create(FCallerAction, FServerProcedures, FPipeName);
end;

procedure TPipeMultiEServer.InternalHandCallServer(aNamedPipe:INamedPipe);
  var tmpExecThreadStruct:TExecThreadStruct;
      tmpENamedPipe:IENamedPipe;
begin
  FillChar(tmpExecThreadStruct, SizeOf(tmpExecThreadStruct), 0);
  tmpExecThreadStruct.ThreadProc:=InternalThreadProcEServerStoredProc;
  tmpExecThreadStruct.UserPointer:=Pointer(FCallerAction);
  tmpExecThreadStruct.UserIUnknown:=aNamedPipe;
  If (assigned(aNamedPipe))And(aNamedPipe.QueryInterface(IENamedPipe, tmpENamedPipe)=S_OK)And(assigned(tmpENamedPipe)) Then tmpENamedPipe.StartTime:=Now;
  //tmpENamedPipe.ServerProcedures:=InternalGetIServerProcedures;
  InternalGetIThreadsPool.ITNLExecProcThread(@tmpExecThreadStruct, true);
end;

function TPipeMultiEServer.InternalGetIServerProcedures:IServerProcedures;
begin
  if (not assigned(FServerProcedures))and(assigned(cnTray)) then cnTray.Query(IServerProcedures, FServerProcedures);
  result:=FServerProcedures;
end;

function TPipeMultiEServer.InternalGetIThreadsPool:IThreadsPool;
begin
  if (not assigned(FThreadsPool))and(assigned(cnTray)) then cnTray.Query(IThreadsPool, FThreadsPool);
  result:=FThreadsPool;
end;

//- - - TENamedPipe - - -
constructor TENamedPipe.create(aCallerAction:ICallerAction; aServerProcedures:IServerProcedures; Const aPipeName:AnsiString);
begin
  if not assigned(aCallerAction) then Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['aCallerAction'], cnerInvalidValueOf);
  FCallerAction:=aCallerAction;
  FServerProcedures:=aServerProcedures;
  inherited Create(aPipeName);
end;

destructor TENamedPipe.destroy;
begin
  FCallerAction:=nil;
  FServerProcedures:=nil;
  inherited destroy;
end;

function TENamedPipe.GetCallerAction:ICallerAction;
begin
  result:=FCallerAction;
end;

function TENamedPipe.GetStartTime:TDateTime;
begin
  result:=FStartTime;
end;

procedure TENamedPipe.SetStartTime(Value:TDateTime);
begin
  FStartTime:=Value;
end;

function TENamedPipe.GetServerProcedures:IServerProcedures;
begin
  result:=FServerProcedures;
end;

end.
