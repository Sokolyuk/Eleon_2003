unit UExternalLocalDataBase;

interface
  Uses ComObj, ActiveX, AxCtrls, Classes, EMServer_TLB, StdVcl, ULocalDataBase, UTTaskTypes,
       ULocalDataBaseTriggersTypes, UCallerTypes, ULocalDataBaseTypes, ADODB;
type
  TExternalEmLocalDataBase=Class;
  TLDBTriggersData=Class
  Private
    FTriggerData:PTriggerData;
    FOwner:TExternalEmLocalDataBase;
  Public
    Constructor Create(aOwner:TExternalEmLocalDataBase);
    Destructor Destroy; override;
    function Get_SQLParams:OleVariant; safecall;
    procedure Set_SQLParams(Value:OleVariant); safecall;
    function Get_RunSQLType:TxRunSQLType; safecall;
    function Get_RunSQLMode:TxRunSQLMode; safecall;
    procedure Set_RunSQLMode(Value:TxRunSQLMode); safecall;
    function Get_TriggerType:TxTriggerType; safecall;
    function Get_SQLString:WideString; safecall;
    procedure Set_SQLString(const Value:WideString); safecall;
    function Get_RecordAffected:SYSINT; safecall;
    procedure Set_RecordAffected(Value:SYSINT); safecall;
    function Get_CDSData:OleVariant; safecall;
    procedure Set_CDSData(Value:OleVariant); safecall;
    function Get_AllowExecuteSQL:WordBool; safecall;
    procedure Set_AllowExecuteSQL(Value:WordBool); safecall;
    function Get_AllowExecuteTriggerAfter:WordBool; safecall;
    procedure Set_AllowExecuteTriggerAfter(Value:WordBool); safecall;
    function Get_DataFromBeforeToAfter:OleVariant; safecall;
    procedure Set_DataFromBeforeToAfter(Value:OleVariant); safecall;
    property SQLParams:OleVariant read Get_SQLParams write Set_SQLParams;
    property RunSQLType:TxRunSQLType read Get_RunSQLType;
    property RunSQLMode:TxRunSQLMode read Get_RunSQLMode write Set_RunSQLMode;
    property TriggerType:TxTriggerType read Get_TriggerType;
    property SQLString:WideString read Get_SQLString write Set_SQLString;
    property RecordAffected:SYSINT read Get_RecordAffected write Set_RecordAffected;
    property CDSData:OleVariant read Get_CDSData write Set_CDSData;
    property AllowExecuteSQL:WordBool read Get_AllowExecuteSQL write Set_AllowExecuteSQL;
    property AllowExecuteTriggerAfter:WordBool read Get_AllowExecuteTriggerAfter write Set_AllowExecuteTriggerAfter;
    property DataFromBeforeToAfter:OleVariant read Get_DataFromBeforeToAfter write Set_DataFromBeforeToAfter;
  End;

  TExternalEmLocalDataBase=class(TAutoObject,
{$Ifndef D6}                     IConnectionPointContainer,{$endif}
                                 IExternalEmLocalDataBase, IExternalEmDataSet, IExternalEmLocalDataBaseTriggersData)
  private
    { Private declarations }
{$Ifndef D6}
    FConnectionPoints:TConnectionPoints;
    FConnectionPoint:TConnectionPoint;
    FSinkList:TList;
    FEvents:IExternalEmLocalDataBaseEvents;
{$endif}
    FLocalDataBaseAssigned:ILocalDataBase;
    FLocalDataBaseCreated:ILocalDataBase;
    FLDBTriggersData:TLDBTriggersData;
  public
    procedure Initialize; override;
    Destructor Destroy; override;
    {IUnknown}
    function ObjAddRef:Integer; override; stdcall;
    function ObjRelease:Integer; override; stdcall;
    Procedure NewLocalDataBase;
    Procedure NewLocalDataBaseForOneADOC(aLockOwner:Integer; aADOC:TADOConnection);
    Function Get_LocalDataBase:ILocalDataBase;
    Procedure Set_LocalDataBase(Value:ILocalDataBase);
    Function Get_LocalDataBaseTriggerData:PTriggerData;
    Procedure Set_LocalDataBaseTriggerData(Value:PTriggerData);
    Property LocalDataBase:ILocalDataBase read Get_LocalDataBase write Set_LocalDataBase;
    Property LocalDataBaseTriggerData:PTriggerData read Get_LocalDataBaseTriggerData write Set_LocalDataBaseTriggerData;
    function ObjQueryInterface(const IID:TGUID; out Obj):HResult; override; stdcall;
  protected
    {IUnknown}
    function _AddRef:Integer; stdcall;
    function _Release:Integer; stdcall;
{$Ifndef D6}
    property ConnectionPoints:TConnectionPoints read FConnectionPoints implements IConnectionPointContainer;
    procedure EventSinkChanged(const EventSink:IUnknown); override;
{$endif}
    function ExecSQL(const aSQL:WideString):SYSINT; safecall;
    function ExecSQLO(const aSQL:WideString; Var aParams:OleVariant):SYSINT; safecall;
    procedure OpenSQL(const aSQL:WideString; out aRes:OleVariant); safecall;
    procedure OpenSQLO(const aSQL:WideString; var aParams:OleVariant; out aRes:OleVariant); safecall;
    procedure OpenSQLOO(const aSQL:WideString; var aParams:OleVariant; out aRecAff:SYSINT; out aRes:OleVariant); safecall;
    function ExecProc(const aSQL:WideString):SYSINT; safecall;
    function ExecProcO(const aSQL:WideString; var aParams:OleVariant):SYSINT; safecall;
    procedure OpenProc(const aSQL:WideString; out aRes:OleVariant); safecall;
    procedure OpenProcO(const aSQL:WideString; var aParams:OleVariant; out aRes:OleVariant); safecall;
    procedure OpenProcOO(const aSQL:WideString; var aParams:OleVariant; out aRecAff:SYSINT; out aRes:OleVariant); safecall;
    function Get_mecLastError:TxMessClass; safecall;
    function Get_UserName:WideString; safecall;
    function Get_LockOwner:SYSINT; safecall;
    procedure Set_MessAdd(Value:WordBool); safecall;
    function Get_PersistentModeCount:SYSINT; safecall;
    function Get_PersistentModeInterval:SYSINT; safecall;
    procedure Set_PersistentModeCount(Value:SYSINT); safecall;
    procedure Set_PersistentModeInterval(Value:SYSINT); safecall;
    function Get_DataSet:IExternalEmDataSet; safecall;
    function WaitForLockList(const aTab:WideString; aIfFailThenRaise:WordBool; aTimeout:SYSINT):WordBool; safecall;
    function Get_TableAutoLock:WordBool; safecall;
    procedure Set_TableAutoLock(Value:WordBool); safecall;
    function Get_LockListTimeOut:SYSINT; safecall;
    procedure Set_LockListTimeOut(Value:SYSINT); safecall;
    // IExternalDataSet
    procedure FieldByName(const aName:WideString; out aRes:OleVariant); safecall;
    procedure Next; safecall;
    procedure Prior; safecall;
    procedure First; safecall;
    procedure Last; safecall;
    procedure Edit; safecall;
    procedure Post; safecall;
    function Get_Active:WordBool; safecall;
    procedure Set_Active(Value:WordBool); safecall;
    function Get_RecordCount:SYSINT; safecall;
    function Get_RecNo:SYSINT; safecall;
    procedure Set_RecNo(Value:SYSINT); safecall;
    property Active:WordBool read Get_Active write Set_Active;
    property RecordCount:SYSINT read Get_RecordCount;
    property RecNo:SYSINT read Get_RecNo write Set_RecNo;
    function Get_Eof:WordBool; safecall;
    procedure Field(aFieldNum:SYSINT; out aRes:OleVariant); safecall;
    //..
    function Get_SQLParams:OleVariant; safecall;
    procedure Set_SQLParams(Value:OleVariant); safecall;
    function Get_RunSQLType:TxRunSQLType; safecall;
    function Get_RunSQLMode:TxRunSQLMode; safecall;
    procedure Set_RunSQLMode(Value:TxRunSQLMode); safecall;
    function Get_TriggerType:TxTriggerType; safecall;
    function Get_SQLString:WideString; safecall;
    procedure Set_SQLString(const Value:WideString); safecall;
    function Get_RecordAffected:SYSINT; safecall;
    procedure Set_RecordAffected(Value:SYSINT); safecall;
    function Get_CDSData:OleVariant; safecall;
    procedure Set_CDSData(Value:OleVariant); safecall;
    function Get_AllowExecuteSQL:WordBool; safecall;
    procedure Set_AllowExecuteSQL(Value:WordBool); safecall;
    function Get_AllowExecuteTriggerAfter:WordBool; safecall;
    procedure Set_AllowExecuteTriggerAfter(Value:WordBool); safecall;
    function Get_DataFromBeforeToAfter:OleVariant; safecall;
    procedure Set_DataFromBeforeToAfter(Value:OleVariant); safecall;
    property SQLParams:OleVariant read Get_SQLParams write Set_SQLParams;
    property RunSQLType:TxRunSQLType read Get_RunSQLType;
    property RunSQLMode:TxRunSQLMode read Get_RunSQLMode write Set_RunSQLMode;
    property TriggerType:TxTriggerType read Get_TriggerType;
    property SQLString:WideString read Get_SQLString write Set_SQLString;
    property RecordAffected:SYSINT read Get_RecordAffected write Set_RecordAffected;
    property CDSData:OleVariant read Get_CDSData write Set_CDSData;
    property AllowExecuteSQL:WordBool read Get_AllowExecuteSQL write Set_AllowExecuteSQL;
    property AllowExecuteTriggerAfter:WordBool read Get_AllowExecuteTriggerAfter write Set_AllowExecuteTriggerAfter;
    property DataFromBeforeToAfter:OleVariant read Get_DataFromBeforeToAfter write Set_DataFromBeforeToAfter;
  end;

implementation
  uses SysUtils, ComServ, ULocalDataBaseTriggerTypes, Windows, UAS, ULogFileTypes, UTrayConsts, UServerConsts;

Constructor TLDBTriggersData.Create(aOwner:TExternalEmLocalDataBase);
begin
  FOwner:=aOwner;
  FTriggerData:=Nil;
  Inherited Create;
end;

Destructor TLDBTriggersData.Destroy;
begin
  FOwner:=Nil;
  FTriggerData:=Nil;
  Inherited Destroy;
end;

function TLDBTriggersData.Get_SQLParams:OleVariant;
  Var tmpPOleVariant:POleVariant;
begin
  tmpPOleVariant:=FOwner.LocalDataBaseTriggerData^.SQLParams;
  If Not Assigned(tmpPOleVariant) Then Raise Exception.Create('SQLParams is not assigned.');
  Result:=tmpPOleVariant^;
end;

procedure TLDBTriggersData.Set_SQLParams(Value:OleVariant);
  Var tmpPOleVariant:POleVariant;
begin
  tmpPOleVariant:=FOwner.LocalDataBaseTriggerData^.SQLParams;
  If Not Assigned(tmpPOleVariant) Then Raise Exception.Create('SQLParams is not assigned.');
  tmpPOleVariant^:=Value;
end;

Function TRunSQLTypeToTxRunSQLType(aRunSQLType:TRunSQLType):TxRunSQLType;
begin
  If aRunSQLType=rstOpen Then result:=xrstOpen else
  If aRunSQLType=rstExec Then result:=xrstExec else Raise Exception.Create('Unknown value aRunSQLType.');
end;

function TLDBTriggersData.Get_RunSQLType:TxRunSQLType;
begin
  Result:=TRunSQLTypeToTxRunSQLType(FOwner.LocalDataBaseTriggerData^.RunSQLType);
end;

Function TRunSQLModeToTxRunSQLMode(aRunSQLMode:TRunSQLMode):TxRunSQLMode;
begin
  If aRunSQLMode=rmdSQL Then Result:=xrmdSQL Else
  If aRunSQLMode=rmdProc Then Result:=xrmdProc Else Raise Exception.Create('Unknown value aRunSQLMode.');
end;

function TLDBTriggersData.Get_RunSQLMode:TxRunSQLMode;
  Var tmpPRunSQLMode:PRunSQLMode;
begin
  tmpPRunSQLMode:=FOwner.LocalDataBaseTriggerData^.RunSQLMode;
  If Not Assigned(tmpPRunSQLMode) Then Raise Exception.Create('RunSQLMode is not assigned.');
  Result:=TRunSQLModeToTxRunSQLMode(tmpPRunSQLMode^);
end;

Function TxRunSQLModeToTRunSQLMode(axRunSQLMode:TxRunSQLMode):TRunSQLMode;
begin
  If axRunSQLMode=xrmdSQL Then Result:=rmdSQL Else
  If axRunSQLMode=xrmdProc Then Result:=rmdProc Else Raise Exception.Create('Unknown value axRunSQLMode.');
end;

procedure TLDBTriggersData.Set_RunSQLMode(Value:TxRunSQLMode);
  Var tmpPRunSQLMode:PRunSQLMode;
begin
  tmpPRunSQLMode:=FOwner.LocalDataBaseTriggerData^.RunSQLMode;
  If Not Assigned(tmpPRunSQLMode) Then Raise Exception.Create('RunSQLMode is not assigned.');
  tmpPRunSQLMode^:=TxRunSQLModeToTRunSQLMode(Value);
end;

Function TTriggerTypeToTxTriggerType(aTriggerType:TTriggerType):TxTriggerType;
begin
  If aTriggerType=cftBefore Then Result:=xcftBefore Else
  If aTriggerType=cftAfter Then Result:=xcftAfter Else Raise Exception.Create('Unknown value aTriggerType.');
end;

function TLDBTriggersData.Get_TriggerType:TxTriggerType;
begin
  Result:=TTriggerTypeToTxTriggerType(FOwner.LocalDataBaseTriggerData^.TriggerType);
end;

function TLDBTriggersData.Get_SQLString:WideString;
  Var tmpPAnsiString:PAnsiString;
begin
  tmpPAnsiString:=FOwner.LocalDataBaseTriggerData^.SQLString;
  If Not Assigned(tmpPAnsiString) Then Raise Exception.Create('SQLString is not assigned.');
  Result:=tmpPAnsiString^;
end;

procedure TLDBTriggersData.Set_SQLString(const Value:WideString);
  Var tmpPAnsiString:PAnsiString;
begin
  tmpPAnsiString:=FOwner.LocalDataBaseTriggerData^.SQLString;
  If Not Assigned(tmpPAnsiString) Then Raise Exception.Create('SQLString is not assigned.');
  tmpPAnsiString^:=Value;
end;

function TLDBTriggersData.Get_RecordAffected:SYSINT;
  Var tmpPInteger:PInteger;
begin
  tmpPInteger:=FOwner.LocalDataBaseTriggerData^.RecordAffected;
  If Not Assigned(tmpPInteger) Then Raise Exception.Create('RecordAffected is not assigned.');
  Result:=tmpPInteger^;
end;

procedure TLDBTriggersData.Set_RecordAffected(Value:SYSINT);
  Var tmpPInteger:PInteger;
begin
  tmpPInteger:=FOwner.LocalDataBaseTriggerData^.RecordAffected;
  If Not Assigned(tmpPInteger) Then Raise Exception.Create('RecordAffected is not assigned.');
  tmpPInteger^:=Value;
end;

function TLDBTriggersData.Get_CDSData:OleVariant;
  Var tmpPOleVariant:POleVariant;
begin
  tmpPOleVariant:=FOwner.LocalDataBaseTriggerData^.CDSData;
  If Not Assigned(tmpPOleVariant) Then Raise Exception.Create('CDSData is not assigned.');
  Result:=tmpPOleVariant^;
end;

procedure TLDBTriggersData.Set_CDSData(Value:OleVariant);
  Var tmpPOleVariant:POleVariant;
begin
  tmpPOleVariant:=FOwner.LocalDataBaseTriggerData^.CDSData;
  If Not Assigned(tmpPOleVariant) Then Raise Exception.Create('CDSData is not assigned.');
  tmpPOleVariant^:=Value;
end;

function TLDBTriggersData.Get_AllowExecuteSQL:WordBool;
begin
  Result:=FOwner.LocalDataBaseTriggerData^.AllowExecuteSQL;
end;

procedure TLDBTriggersData.Set_AllowExecuteSQL(Value:WordBool);
begin
  FOwner.LocalDataBaseTriggerData^.AllowExecuteSQL:=Value;
end;

function TLDBTriggersData.Get_AllowExecuteTriggerAfter:WordBool;
begin
  Result:=FOwner.LocalDataBaseTriggerData^.AllowExecuteTriggerAfter;
end;

procedure TLDBTriggersData.Set_AllowExecuteTriggerAfter(Value:WordBool);
begin
  FOwner.LocalDataBaseTriggerData^.AllowExecuteTriggerAfter:=Value;
end;

function TLDBTriggersData.Get_DataFromBeforeToAfter:OleVariant;
  Var tmpPOleVariant:POleVariant;
begin
  tmpPOleVariant:=FOwner.LocalDataBaseTriggerData^.DataFromBeforeToAfter;
  If Not Assigned(tmpPOleVariant) Then Raise Exception.Create('DataFromBeforeToAfter is not assigned.');
  Result:=tmpPOleVariant^;
end;

procedure TLDBTriggersData.Set_DataFromBeforeToAfter(Value:OleVariant);
  Var tmpPOleVariant:POleVariant;
begin
  tmpPOleVariant:=FOwner.LocalDataBaseTriggerData^.DataFromBeforeToAfter;
  If Not Assigned(tmpPOleVariant) Then Raise Exception.Create('DataFromBeforeToAfter is not assigned.');
  tmpPOleVariant^:=Value;
end;

//----------------------------------------------------------------------------------------
{$Ifndef D6}
procedure TExternalEmLocalDataBase.EventSinkChanged(const EventSink:IUnknown);
begin
  FEvents:=EventSink as IExternalEmLocalDataBaseEvents;
  if FConnectionPoint<>nil then
     FSinkList:=FConnectionPoint.SinkList;
end;
{$endif}
procedure TExternalEmLocalDataBase.Initialize;
begin
  inherited Initialize;
  FLDBTriggersData:=TLDBTriggersData.Create(Self);
{$Ifndef D6}
  FConnectionPoints:=TConnectionPoints.Create(Self);
  if AutoFactory.EventTypeInfo<>nil then FConnectionPoint:=FConnectionPoints.CreateConnectionPoint(AutoFactory.EventIID, ckSingle, EventConnect) else FConnectionPoint := nil;
{$endif}
  FLocalDataBaseCreated:=Nil;
  FLocalDataBaseAssigned:=Nil;
end;

destructor TExternalEmLocalDataBase.Destroy;
begin
  try
    FreeAndNil(FLDBTriggersData);
    FLocalDataBaseCreated:=Nil;
    FLocalDataBaseAssigned:=Nil;
{$Ifndef D6}
    If Assigned(FConnectionPoints) Then FreeAndNil(FConnectionPoints);
{$endif}
  except end;
  If GL_AOF_ELDB<>Nil Then Inherited Destroy // Если GL_AOF_ELDB=Nil значит фактори не существует и не нужен inherited, т.к. он вычеркивает себя из его списка.
  else begin
    try ILogFile(cnTray.Query(ILogFile)).ITWriteLnToLog(#13#10'WARNING:TExternalEmLocalDataBase.Destroy:GL_AOF_ELDB=Nil, ''Inherited Destroy'' is skipped.'); except end;
  end;
end;

Procedure TExternalEmLocalDataBase.NewLocalDataBase;
begin
  FLocalDataBaseAssigned:=Nil;
  If Assigned(FLocalDataBaseCreated) Then FLocalDataBaseCreated:=Nil;
  FLocalDataBaseCreated:=TLocalDataBase.Create;
end;

Procedure TExternalEmLocalDataBase.NewLocalDataBaseForOneADOC(aLockOwner:Integer; aADOC:TADOConnection);
begin
  FLocalDataBaseAssigned:=Nil;
  If Assigned(FLocalDataBaseCreated) Then FLocalDataBaseCreated:=Nil;
  FLocalDataBaseCreated:=TLocalDataBase.CreateForOneADOC(aLockOwner, aADOC);
end;

Function TExternalEmLocalDataBase.Get_LocalDataBaseTriggerData:PTriggerData;
begin
  Result:=FLDBTriggersData.FTriggerData;
  If Not Assigned(Result) Then Raise Exception.Create('LocalDataBaseTriggerData not assigned.');
end;

Procedure TExternalEmLocalDataBase.Set_LocalDataBaseTriggerData(Value:PTriggerData);
begin
  FLDBTriggersData.FTriggerData:=Value;
end;

Function TExternalEmLocalDataBase.Get_LocalDataBase:ILocalDataBase;
begin
  If Assigned(FLocalDataBaseAssigned) Then Result:=FLocalDataBaseAssigned Else Result:=FLocalDataBaseCreated;
  If Not Assigned(Result) Then Raise Exception.Create('TExternalEmLocalDataBase:LocalDataBase not assigned.');
end;

Procedure TExternalEmLocalDataBase.Set_LocalDataBase(Value:ILocalDataBase);
begin
  FLocalDataBaseCreated:=Nil;
  FLocalDataBaseAssigned:=Value;
end;

function TExternalEmLocalDataBase.ExecSQL(const aSQL:WideString):SYSINT;
begin
  Result:=LocalDataBase.ExecSQL(aSQL);
end;

function TExternalEmLocalDataBase.ExecSQLO(const aSQL:WideString; Var aParams:OleVariant):SYSINT;
begin
  Result:=LocalDataBase.ExecSQL(aSQL, aParams);
end;

procedure TExternalEmLocalDataBase.OpenSQL(const aSQL:WideString; out aRes:OleVariant);
begin
  aRes:=LocalDataBase.OpenSQL(aSQL);
end;

procedure TExternalEmLocalDataBase.OpenSQLO(const aSQL:WideString; var aParams:OleVariant; out aRes:OleVariant);
begin
  aRes:=LocalDataBase.OpenSQL(aSQL, aParams);
end;

procedure TExternalEmLocalDataBase.OpenSQLOO(const aSQL:WideString; var aParams:OleVariant; out aRecAff:SYSINT; out aRes:OleVariant);
begin
  aRes:=LocalDataBase.OpenSQL(aSQL, aParams, aRecAff);
end;

function TExternalEmLocalDataBase.Get_mecLastError:TxMessClass;
begin
  Result:=Integer(LocalDataBase.mecLastError);
end;

function TExternalEmLocalDataBase.Get_UserName:WideString;
begin
  Result:=LocalDataBase.CallerAction.UserName;
end;

function TExternalEmLocalDataBase.Get_LockOwner:SYSINT;
begin
  Result:=LocalDataBase.LockOwner;
end;

procedure TExternalEmLocalDataBase.Set_MessAdd(Value:WordBool);
begin
  LocalDataBase.MessAdd:=Value;
end;

function TExternalEmLocalDataBase.Get_PersistentModeCount:SYSINT;
begin
  Result:=LocalDataBase.PersistentMode.Count;
end;

function TExternalEmLocalDataBase.Get_PersistentModeInterval:SYSINT;
begin
  Result:=LocalDataBase.PersistentMode.Interval;
end;

procedure TExternalEmLocalDataBase.Set_PersistentModeCount(Value:SYSINT);
  Var tmpPersistentMode:TPersistentMode;
begin
  tmpPersistentMode:=LocalDataBase.PersistentMode;
  tmpPersistentMode.Count:=Value;
  LocalDataBase.PersistentMode:=tmpPersistentMode;
end;

procedure TExternalEmLocalDataBase.Set_PersistentModeInterval(Value:SYSINT);
  Var tmpPersistentMode:TPersistentMode;
begin
  tmpPersistentMode:=LocalDataBase.PersistentMode;
  tmpPersistentMode.Interval:=Value;
  LocalDataBase.PersistentMode:=tmpPersistentMode;
end;

function TExternalEmLocalDataBase.Get_DataSet:IExternalEmDataSet;
begin
  Result:=Self;
end;

Function TExternalEmLocalDataBase.WaitForLockList(const aTab:WideString; aIfFailThenRaise:WordBool; aTimeout:SYSINT):WordBool;
begin
  Result:=LocalDataBase.WaitForLockList(aTab, aIfFailThenRaise, aTimeout);
end;

procedure TExternalEmLocalDataBase.FieldByName(const aName:WideString; out aRes:OleVariant);
begin
  aRes:=LocalDataBase.DataSet.FieldByName(aName).Value;
end;

procedure TExternalEmLocalDataBase.Next;
begin
  LocalDataBase.DataSet.Next;
end;

procedure TExternalEmLocalDataBase.Prior;
begin
  LocalDataBase.DataSet.Prior;
end;

procedure TExternalEmLocalDataBase.First;
begin
  LocalDataBase.DataSet.First;
end;

procedure TExternalEmLocalDataBase.Last;
begin
  LocalDataBase.DataSet.Last;
end;

procedure TExternalEmLocalDataBase.Edit;
begin
  LocalDataBase.DataSet.Edit;
end;

procedure TExternalEmLocalDataBase.Post;
begin
  LocalDataBase.DataSet.Post;
end;

function TExternalEmLocalDataBase.Get_Active:WordBool;
begin
  result:=LocalDataBase.DataSet.Active;
end;

procedure TExternalEmLocalDataBase.Set_Active(Value:WordBool);
begin
  LocalDataBase.DataSet.Active:=Value;
end;

function TExternalEmLocalDataBase.Get_RecordCount:SYSINT;
begin
  Result:=LocalDataBase.DataSet.RecordCount;
end;

function TExternalEmLocalDataBase.Get_RecNo:SYSINT;
begin
  Result:=LocalDataBase.DataSet.RecNo;
end;

procedure TExternalEmLocalDataBase.Set_RecNo(Value:SYSINT);
begin
  LocalDataBase.DataSet.RecNo:=Value;
end;

function TExternalEmLocalDataBase.Get_Eof:WordBool;
begin
  Result:=LocalDataBase.DataSet.Eof;
end;

procedure TExternalEmLocalDataBase.Field(aFieldNum:SYSINT; out aRes:OleVariant);
begin
  aRes:=LocalDataBase.DataSet.Fields.Fields[aFieldNum].Value;
end;

{IUnknown}
function TExternalEmLocalDataBase._AddRef:Integer;
begin
  Result:=1;
end;

function TExternalEmLocalDataBase._Release:Integer;
begin
  Result:=1;
end;

function TExternalEmLocalDataBase.ObjAddRef:Integer;
begin
  Result:=1;
end;

function TExternalEmLocalDataBase.ObjRelease:Integer;
begin
  Result:=1;
end;

function TExternalEmLocalDataBase.Get_TableAutoLock:WordBool;
begin
  Result:=LocalDataBase.TableAutoLock;
end;

procedure TExternalEmLocalDataBase.Set_TableAutoLock(Value:WordBool);
begin
  LocalDataBase.TableAutoLock:=Value;
end;

function TExternalEmLocalDataBase.Get_LockListTimeOut:SYSINT;
begin
  Result:=LocalDataBase.LockListTimeOut;
end;

procedure TExternalEmLocalDataBase.Set_LockListTimeOut(Value:SYSINT);
begin
  LocalDataBase.LockListTimeOut:=Value;
end;

function TExternalEmLocalDataBase.ExecProc(const aSQL:WideString):SYSINT;
begin
  Result:=LocalDataBase.ExecProc(aSQL);
end;

function TExternalEmLocalDataBase.ExecProcO(const aSQL:WideString; var aParams:OleVariant):SYSINT;
begin
  Result:=LocalDataBase.ExecProc(aSQL, aParams);
end;

procedure TExternalEmLocalDataBase.OpenProc(const aSQL:WideString; out aRes:OleVariant);
begin
  aRes:=LocalDataBase.OpenProc(aSQL);
end;

procedure TExternalEmLocalDataBase.OpenProcO(const aSQL:WideString; var aParams:OleVariant; out aRes:OleVariant);
begin
  aRes:=LocalDataBase.OpenProc(aSQL, aParams);
end;

procedure TExternalEmLocalDataBase.OpenProcOO(const aSQL:WideString; var aParams:OleVariant; out aRecAff:SYSINT; out aRes:OleVariant);
begin
  aRes:=LocalDataBase.OpenProc(aSQL, aParams, aRecAff);
end;

function TExternalEmLocalDataBase.ObjQueryInterface(const IID:TGUID; out Obj):HResult;
begin
  if GUIDToString(IID)=GUIDToString(IID_IExternalEmLocalDataBaseTriggersData) then begin//IsEqualIID
    if Assigned(FLDBTriggersData.FTriggerData) Then begin
      Result:=Inherited ObjQueryInterface(IID, Obj);
    end else begin
      Result:=E_NOINTERFACE;
    end;
  end else begin
    Result:=Inherited ObjQueryInterface(IID, Obj);
  end;
end;

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function TExternalEmLocalDataBase.Get_SQLParams:OleVariant;
begin
  Result:=FLDBTriggersData.Get_SQLParams;
end;

procedure TExternalEmLocalDataBase.Set_SQLParams(Value:OleVariant);
begin
  FLDBTriggersData.Set_SQLParams(Value);
end;

function TExternalEmLocalDataBase.Get_RunSQLType:TxRunSQLType;
begin
  result:=FLDBTriggersData.Get_RunSQLType;
end;

function TExternalEmLocalDataBase.Get_RunSQLMode:TxRunSQLMode;
begin
  result:=FLDBTriggersData.Get_RunSQLMode;
end;

procedure TExternalEmLocalDataBase.Set_RunSQLMode(Value:TxRunSQLMode);
begin
  FLDBTriggersData.Set_RunSQLMode(Value);
end;

function TExternalEmLocalDataBase.Get_TriggerType:TxTriggerType;
begin
  result:=FLDBTriggersData.Get_TriggerType;
end;

function TExternalEmLocalDataBase.Get_SQLString:WideString;
begin
  result:=FLDBTriggersData.Get_SQLString;
end;

procedure TExternalEmLocalDataBase.Set_SQLString(const Value:WideString);
begin
  FLDBTriggersData.Set_SQLString(Value);
end;

function TExternalEmLocalDataBase.Get_RecordAffected:SYSINT;
begin
  result:=FLDBTriggersData.Get_RecordAffected;
end;

procedure TExternalEmLocalDataBase.Set_RecordAffected(Value:SYSINT);
begin
  FLDBTriggersData.Set_RecordAffected(Value);
end;

function TExternalEmLocalDataBase.Get_CDSData:OleVariant;
begin
  result:=FLDBTriggersData.Get_CDSData;
end;

procedure TExternalEmLocalDataBase.Set_CDSData(Value:OleVariant);
begin
  FLDBTriggersData.Set_CDSData(Value);
end;

function TExternalEmLocalDataBase.Get_AllowExecuteSQL:WordBool;
begin
  result:=FLDBTriggersData.Get_AllowExecuteSQL;
end;

procedure TExternalEmLocalDataBase.Set_AllowExecuteSQL(Value:WordBool);
begin
  FLDBTriggersData.Set_AllowExecuteSQL(Value);
end;

function TExternalEmLocalDataBase.Get_AllowExecuteTriggerAfter:WordBool;
begin
  result:=FLDBTriggersData.Get_AllowExecuteTriggerAfter;
end;

procedure TExternalEmLocalDataBase.Set_AllowExecuteTriggerAfter(Value:WordBool);
begin
  FLDBTriggersData.Set_AllowExecuteTriggerAfter(Value);
end;

function TExternalEmLocalDataBase.Get_DataFromBeforeToAfter:OleVariant;
begin
  result:=FLDBTriggersData.Get_DataFromBeforeToAfter;
end;

procedure TExternalEmLocalDataBase.Set_DataFromBeforeToAfter(Value:OleVariant);
begin
  FLDBTriggersData.Set_DataFromBeforeToAfter(Value);
end;

initialization
end.
