unit UExternalDataCase;

interface
  uses ComObj, ActiveX, AxCtrls, Classes, Pegas_TLB, StdVcl, UCallerTypes;

type
  TExternalPgDataCase=class(TAutoObject,{$Ifndef D6}IConnectionPointContainer,{$Endif}IExternalPgDataCase, IExternalEmASMList)
  private
{$Ifndef D6}
    FConnectionPoints:TConnectionPoints;
    FConnectionPoint:TConnectionPoint;
    FSinkList:TList;
    FEvents:IExternalPgDataCaseEvents;
{$Endif}
    FCallerAction:ICallerAction;
  public
    procedure Initialize; override;
    Destructor Destroy; override;
    Function Get_CallerAction:ICallerAction;
    Procedure Set_CallerAction(Value:ICallerAction);
    Property CallerAction:ICallerAction read Get_CallerAction write Set_CallerAction;
    {IUnknown}
    function ObjAddRef:Integer; override; stdcall;
    function ObjRelease:Integer; override; stdcall;
    function ObjQueryInterface(const IID:TGUID; out Obj):HResult; override; stdcall;
  protected
    {IUnknown}
    function _AddRef:Integer; stdcall;
    function _Release:Integer; stdcall;
{$Ifndef D6}
    property ConnectionPoints:TConnectionPoints read FConnectionPoints implements IConnectionPointContainer;
    procedure EventSinkChanged(const EventSink:IUnknown); override;
{$Endif}
    function ITGetUniqueString:WideString; safecall;
    function ITMateSleepTaskAdd(aTsk:SYSINT; aParams, aSenderParams, aSecurityContext:OleVariant; aSleep:Integer):SYSINT; safecall;
    function ITMateSleepTaskAddO(aTsk:SYSINT; aParams, aSenderParams, aSecurityContext:OleVariant; aSleep:Integer; aTaskNumbered:SYSINT; out aTaskID:SYSINT):SYSINT; safecall;
    function ITMateTaskAdd(aTsk:SYSINT; aParams, aSenderParams, aSecurityContext:OleVariant):SYSINT; safecall;
    function ITMateTaskAddO(aTsk:SYSINT; aParams, aSenderParams, aSecurityContext:OleVariant; aTaskNumbered:SYSINT; out aTaskID:SYSINT):SYSINT; safecall;
    function ITMateWakeUpTaskAdd(aTsk:SYSINT; aParams, aSenderParams, aSecurityContext:OleVariant; aWakeup:Largeuint):SYSINT; safecall;
    function ITMateWakeUpTaskAddO(aTsk:SYSINT; aParams, aSenderParams, aSecurityContext:OleVariant; aWakeup:Largeuint; aTaskNumbered:SYSINT; out aTaskID:SYSINT):SYSINT; safecall;
    function ITServerName:WideString; safecall;
    function ITSetLockList(const aTab, aUser:WideString; aLockOwner:SYSINT; aIfFailThenRaise, aMessAdd:WordBool):WordBool; safecall;
    procedure ITCheckSecurityLDB(aTables, aSecurityContext:OleVariant); safecall;
    procedure ITCheckSecurityMTask(aMTask:SYSINT; aSecurityContext:OleVariant); safecall;
    procedure ITCheckSecurityPTask(aPTask:SYSINT; aSecurityContext:OleVariant); safecall;
    procedure ITMessAdd(aDateTime, aStartTime:TDateTime; aAddr:SYSINT; const aUser, aSource, aMess:WideString; aMessageClass:TxPgMessClass; aMessageStyle:TxPgMessStyle); safecall;
    procedure ITMessToBasicLog(const aMess:WideString; aIndicateTime:WordBool); safecall;
    procedure ITServerInfo(aPartId:TxPgPartOfInfo; out aRes:OleVariant); safecall;
    function ITGenerateLockOwner:SYSINT; safecall;
    procedure ITClearLockOwner(aLockOwner:SYSINT); safecall;
    function ITClearRePDFromQueueOfClientID(const aClientQueueId:WideString):SYSINT; safecall;
    function ITExistsMaskName(const aMaskName:WideString):WordBool; safecall;
  end;

implementation
  uses ComServ, SysUtils, UTTaskTypes, UADMTypes, UStringsetTypes, Windows, ULogfileTypes, UTrayConsts,
       UAppMessageTypes, UThreadsPoolTypes, UEPointPropertiesTypes, USyncTypes, UAppSecurityTypes,
       UServerInfoTypes, UStrQueueTypes, ULocalDataBaseTypes, ULocalDataBase, UAdmittanceASMTypes, UServerConsts, UServerActionConsts,
       Variants, UUniqueStrUtils;
{$Ifndef D6}
procedure TExternalPgDataCase.EventSinkChanged(const EventSink:IUnknown);
begin
  FEvents:=EventSink as IExternalPgDataCaseEvents;
  if FConnectionPoint<>nil then FSinkList:=FConnectionPoint.SinkList;
end;
{$Endif}
procedure TExternalPgDataCase.Initialize;
begin
  inherited Initialize;
{$Ifndef D6}
  FConnectionPoints:=TConnectionPoints.Create(Self);
  if AutoFactory.EventTypeInfo<>nil then FConnectionPoint:=FConnectionPoints.CreateConnectionPoint(AutoFactory.EventIID, ckSingle, EventConnect) else FConnectionPoint:=nil;
{$Endif}  
  FCallerAction:=nil;
end;

Destructor TExternalPgDataCase.Destroy;
begin
{$Ifndef D6}
  If Assigned(FConnectionPoints) Then FreeAndNil(FConnectionPoints);
{$Endif}
  FCallerAction:=nil;
  If GL_AOF_EDC<>Nil Then Inherited Destroy // ���� GL_AOF_ELDB=Nil ������ ������� �� ���������� � �� ����� inherited, �.�. �� ����������� ���� �� ��� ������.
  Else begin
    try ILogfile(cnTray.Query(ILogfile)).ITWriteLnToLog(#13#10'WARNING:TExternalDataCase.Destroy:GL_AOF_EDC=Nil, ''Inherited Destroy'' is skipped.'); except end;
  end;
end;

Function TExternalPgDataCase.Get_CallerAction:ICallerAction;
begin
  Result:=FCallerAction;
  If Not Assigned(Result) Then Raise Exception.Create('TExternalPgDataCase:CallerAction is not assigned.');
end;

Procedure TExternalPgDataCase.Set_CallerAction(Value:ICallerAction);
begin
  FCallerAction:=Value;
end;

procedure TExternalPgDataCase.ITMessAdd(aDateTime, aStartTime:TDateTime; aAddr:SYSINT; const aUser, aSource, aMess:WideString; aMessageClass:TxPgMessClass; aMessageStyle:TxPgMessStyle);
begin
  IAppMessage(cnTray.Query(IAppMessage)).ITMessAdd(aDateTime, aStartTime, aUser, aSource, aMess, TMessageClass(aMessageClass), TMessageStyle(aMessageStyle))
end;

function TExternalPgDataCase.ITGetUniqueString:WideString;
begin
  Result:=UniqueStringStrong;
end;

procedure TExternalPgDataCase.ITMessToBasicLog(const aMess:WideString; aIndicateTime:WordBool);
begin
  ILogfile(cnTray.Query(ILogfile)).ITWriteLnToLog(aMess, aIndicateTime);
end;

function TExternalPgDataCase.ITMateTaskAdd(aTsk:SYSINT; aParams, aSenderParams, aSecurityContext:OleVariant):SYSINT;
begin
  Result:=-1;IThreadsPool(cnTray.Query(IThreadsPool)).ITMTaskAdd(TTask(aTsk), aParams, aSenderParams, aSecurityContext);
end;

function TExternalPgDataCase.ITMateTaskAddO(aTsk:SYSINT; aParams, aSenderParams, aSecurityContext:OleVariant; aTaskNumbered:SYSINT; out aTaskID:SYSINT):SYSINT;
begin
  Result:=-1;IThreadsPool(cnTray.Query(IThreadsPool)).ITMTaskAdd(TTask(aTsk), aParams, aSenderParams, aSecurityContext, aTaskNumbered, @aTaskID);
end;

function TExternalPgDataCase.ITMateSleepTaskAdd(aTsk:SYSINT; aParams, aSenderParams, aSecurityContext:OleVariant; aSleep:Integer):SYSINT;
begin
  Result:=-1;IThreadsPool(cnTray.Query(IThreadsPool)).ITMSleepTaskAdd(TTask(aTsk), aParams, aSenderParams, aSecurityContext, aSleep);
end;

function TExternalPgDataCase.ITMateSleepTaskAddO(aTsk:SYSINT; aParams, aSenderParams, aSecurityContext:OleVariant; aSleep:Integer; aTaskNumbered:SYSINT; out aTaskID:SYSINT):SYSINT;
begin
  Result:=-1;IThreadsPool(cnTray.Query(IThreadsPool)).ITMSleepTaskAdd(TTask(aTsk), aParams, aSenderParams, aSecurityContext, aSleep, aTaskNumbered, @aTaskID);
end;

function TExternalPgDataCase.ITMateWakeUpTaskAdd(aTsk:SYSINT; aParams, aSenderParams, aSecurityContext:OleVariant; aWakeup:Largeuint):SYSINT;
begin
  Result:=-1;IThreadsPool(cnTray.Query(IThreadsPool)).ITMWakeUpTaskAdd(TTask(aTsk), aParams, aSenderParams, aSecurityContext, aWakeup);
end;

function TExternalPgDataCase.ITMateWakeUpTaskAddO(aTsk:SYSINT; aParams, aSenderParams, aSecurityContext:OleVariant; aWakeup:Largeuint; aTaskNumbered:SYSINT; out aTaskID:SYSINT):SYSINT;
begin
  Result:=-1;IThreadsPool(cnTray.Query(IThreadsPool)).ITMWakeUpTaskAdd(TTask(aTsk), aParams, aSenderParams, aSecurityContext, aWakeup, aTaskNumbered, @aTaskID);
end;

function TExternalPgDataCase.ITServerName:WideString;
begin
  Result:=IEPointProperties(cnTray.Query(IEPointProperties)).TitlePoint;
end;

function TExternalPgDataCase.ITSetLockList(const aTab, aUser:WideString; aLockOwner:SYSINT; aIfFailThenRaise, aMessAdd:WordBool):WordBool;
begin
  Result:=ISync(cnTray.Query(ISync)).ITSetLockList(aTab, FCallerAction, aLockOwner, aIfFailThenRaise, aMessAdd);
end;

function TExternalPgDataCase.ITGenerateLockOwner:SYSINT;
begin
  Result:=ISync(cnTray.Query(ISync)).ITGenerateLockOwner;
end;

procedure TExternalPgDataCase.ITClearLockOwner(aLockOwner:SYSINT);
begin
  ISync(cnTray.Query(ISync)).ITClearLockOwner(aLockOwner);
end;

procedure TExternalPgDataCase.ITCheckSecurityLDB(aTables, aSecurityContext:OleVariant);
begin
  IAppSecurity(cnTray.Query(IAppSecurity)).ITCheckSecurityLDB(aTables, aSecurityContext);
end;

procedure TExternalPgDataCase.ITCheckSecurityMTask(aMTask:SYSINT; aSecurityContext:OleVariant);
begin
  IAppSecurity(cnTray.Query(IAppSecurity)).ITCheckSecurityMTask(TTask(aMTask), aSecurityContext);
end;

procedure TExternalPgDataCase.ITCheckSecurityPTask(aPTask:SYSINT; aSecurityContext:OleVariant);
begin
  IAppSecurity(cnTray.Query(IAppSecurity)).ITCheckSecurityPTask(TADMTask(aPTask), aSecurityContext);
end;

procedure TExternalPgDataCase.ITServerInfo(aPartId:TxPgPartOfInfo; out aRes:OleVariant);
begin
  aRes:=IServerInfo(cnTray.Query(IServerInfo)).ServerInfo(TPartOfInfo(aPartId));
end;

{IUnknown}
function TExternalPgDataCase._AddRef:Integer;
begin
  Result:=1;
end;

function TExternalPgDataCase._Release:Integer;
begin
  Result:=1;
end;

function TExternalPgDataCase.ObjAddRef:Integer;
begin
  Result:=1;
end;

function TExternalPgDataCase.ObjRelease:Integer;
begin
  Result:=1;
end;

function TExternalPgDataCase.ObjQueryInterface(const IID:TGUID; out Obj):HResult;
begin
  Result:=Inherited ObjQueryInterface(IID, Obj);
end;

function TExternalPgDataCase.ITClearRePDFromQueueOfClientID(const aClientQueueId:WideString):SYSINT;
  var tmpLocalDataBase:ILocalDataBase;
begin
  tmpLocalDataBase:=TLocalDataBase.Create;
  try
    tmpLocalDataBase.CallerAction:=cnServerAction;
    IAppSecurity(cnTray.Query(IAppSecurity)).ITCheckSecurityPTask(tskADMClearRePDOfClientID, FCallerAction.SecurityContext);
    Result:=IStrQueue(cnTray.Query(IStrQueue)).ClearRePDFromQueueOfClientID(FCallerAction, tmpLocalDataBase, aClientQueueId, false{aCheckSecurity});
  finally
    tmpLocalDataBase:=Nil;
  end;
end;

function TExternalPgDataCase.ITExistsMaskName(const aMaskName:WideString):WordBool;
  Var tmpIUnknown:IUnknown;
      tmpV:Variant;
      ptrtmp:TObject;
      tmpIStringset:IStringset;
begin
  Result:=False;
  tmpV:=Unassigned;
  Repeat
    If VarIsArray(tmpV) Then ptrtmp:=Pointer(Integer(tmpV[5])) else ptrtmp:=nil;
    tmpV:=IAdmittanceASM(cnTray.Query(IAdmittanceASM)).GetInfoNextASMAndNoLock(ptrtmp);
    If VarIsArray(tmpV) Then begin
      tmpIUnknown:=tmpV[9];
      If Assigned(tmpIUnknown) Then begin
        If (tmpIUnknown.QueryInterface(IStringset, tmpIStringset)<>S_OK)Or(not assigned(tmpIStringset)) Then Raise Exception.Create('IStringset is not found.');
        If tmpIStringset.ITExist(aMaskName) Then begin
          Result:=True;
          Break;
        end;
      end;
    end else begin
      Break;//���������
    end;
  Until False;
  tmpIUnknown:=Nil;
  VarClear(tmpV);
end;

end.
