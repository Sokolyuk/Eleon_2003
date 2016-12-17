//Copyright © 2000-2004 by Dmitry A. Sokolyuk
{$Define MyDebug}
unit ULocalDataBase;

interface
  uses UITObject, ADOdb, DBTables, Db, UServerConsts, ULocalDataBaseTypes, Classes, UCallerTypes, UAppMessageTypes,
       UAppSecurityTypes, ULocalDataBaseTriggersTypes, USyncTypes, ULocalDataBaseUtils;

type
  TLocalDataBase=class(TITObject, ILocalDataBase)
  private
    FADOC:TADOConnection;
    FADOCM:TADOCommand;
    FADODS:TADODataSet;
    FBDEQuery:TQuery;
    FBDEDataBase:TDataBase;
    FLockOwner:Integer;
    FCallerAction:ICallerAction;
    FTables:Variant;
    FCountTran:Integer;
    FTabTran:AnsiString;
    FCheckSecuretyLDB, FTableAutoLock:Boolean;
    FmecLastError:TMessageClass;
    Recordset:_Recordset;
    FCnnType:Integer;
    FMessAdd:Boolean;
    FPersistentMode:TPersistentMode;
    FLockListTimeOut:Integer;
    FRecursionDepth:Integer;
    FCheckForTriggers:boolean;
    FOldADOCAfterConnect, FOldADOCAfterDisconnect:TNotifyEvent;
    FADOCCreated:Boolean;
    FGenerateLockOwner:Boolean;
    FAppSecurity:IAppSecurity;
    FAppMessage:IAppMessage;
    FLocalDataBaseTriggers:ILocalDataBaseTriggers;
    FSync:ISync;
    FLDBId:Integer;
  protected
    function InternalGetUserName:AnsiString;virtual;
    function InternalGetSecurityContext:Variant;virtual;
    function InternalGetIAppMessage:IAppMessage;virtual;
    function InternalGetIAppSecurity:IAppSecurity;virtual;
    function InternalGetILocalDataBaseTriggers:ILocalDataBaseTriggers;virtual;
    function InternalGetISync:ISync;virtual;
    procedure InternalCreate(aADOC:TADOConnection=Nil);
    //function InternalGetFirstCurForCDS(My_RecSet:_Recordset; var aRecAff:Integer ):OleVariant;
    function InternalGetCurFromQueryForCDS(Var aRecAff:Integer):OleVariant;
    procedure UASMessAdd(aStartTime:TDateTime; const stMess:AnsiString; MessageClass:TMessageClass; MessType:TMessageStyle);
    procedure ADOConnection1AfterConnect(Sender:TObject);
    procedure ADOConnection1AfterDisconnect(Sender:TObject);
    procedure InternalUnlockList;
    procedure InternalTableLock(const aTables:Variant; var astTab, aTabTran:AnsiString; var aCountTran:Integer; var aRequireUnlocking:Boolean);
    procedure InternalTableUnLock(aCountTran:Integer; var aTabTran, astTab:AnsiString);
    function InternalExec(aRunSQLMode:TRunSQLMode; const aSQL:AnsiString; var aParams:OleVariant):Integer;
    function InternalOpen(aRunSQLMode:TRunSQLMode; const aSQL:AnsiString; var aParams:OleVariant; var aRecAff:Integer; aOnlyExists:Boolean):OleVariant;
    {IUnknown}//Auxiliary methods
    function Get_DataSet:TDataSet;
    function Get_mecLastError:TMessageClass;
    procedure Set_CallerAction(value:ICallerAction);virtual;
    function Get_CallerAction:ICallerAction;virtual;
    function Get_FCheckSecuretyLDB:Boolean;
    procedure Set_FCheckSecuretyLDB(Value:Boolean);
    function Get_FTableAutoLock:Boolean;
    procedure Set_FTableAutoLock(Value:Boolean);
    procedure Set_FMessAdd(Value:Boolean);
    function Get_FPersistentMode:TPersistentMode;
    procedure Set_FPersistentMode(Value:TPersistentMode);
    function Get_LockOwner:Integer;
    function Get_RecursionDepth:Integer;
    procedure Set_RecursionDepth(Value:Integer);
    function Get_CheckForTriggers:Boolean;
    procedure Set_CheckForTriggers(Value:Boolean);
  public
    constructor create;overload;
    constructor create(aLockOwner:Integer);overload;
    constructor createForOneADOC(aLockOwner:Integer; aADOC:TADOConnection);overload;
    destructor destroy;override;
    //Main methods
    function ExistsSQL(const aSQL:AnsiString):boolean;overload;virtual;
    function ExistsSQL(const aSQL:AnsiString; out aRecAff:Integer):boolean;overload;virtual;
    function ExistsSQL(const aSQL:AnsiString; var aParams:OleVariant):boolean;overload;virtual;
    function ExistsSQL(const aSQL:AnsiString; var aParams:OleVariant; out aRecAff:Integer):boolean;overload;virtual;
    function ExistsSQL(const aSQL:AnsiString; var aParams:TParams):boolean;overload;virtual;
    function ExistsSQL(const aSQL:AnsiString; var aParams:TParams; out aRecAff:Integer):boolean;overload;virtual;
    function ExecSQL(const aSQL:AnsiString; var aParams:OleVariant):Integer;overload;
    function ExecSQL(const aSQL:AnsiString; var aParams:TParams):Integer;overload;
    function ExecSQL(const aSQL:AnsiString):Integer;overload;
    function OpenSQL(const aSQL:AnsiString; var aParams:OleVariant; var aRecAff:Integer):OleVariant;overload;
    function OpenSQL(const aSQL:AnsiString; var aParams:TParams; var aRecAff:Integer):OleVariant;overload;
    function OpenSQL(const aSQL:AnsiString; var aParams:OleVariant):OleVariant;overload;
    function OpenSQL(const aSQL:AnsiString; var aParams:TParams):OleVariant;overload;
    function OpenSQL(const aSQL:AnsiString):OleVariant;overload;
    function OpenSQL(const aSQL:AnsiString; var aRecAff:Integer):OleVariant; overload;
    function ExecProc(const aSQL:AnsiString; var aParams:OleVariant):Integer;overload;
    function ExecProc(const aSQL:AnsiString; var aParams:TParams):Integer;overload;
    function ExecProc(const aSQL:AnsiString):Integer;overload;
    function OpenProc(const aSQL:AnsiString; var aParams:OleVariant; var aRecAff:Integer):OleVariant;overload;
    function OpenProc(const aSQL:AnsiString; var aParams:TParams; var aRecAff:Integer):OleVariant;overload;
    function OpenProc(const aSQL:AnsiString; var aParams:OleVariant):OleVariant;overload;
    function OpenProc(const aSQL:AnsiString; var aParams:TParams):OleVariant;overload;
    function OpenProc(const aSQL:AnsiString):OleVariant;overload;
    function WaitForLockList(const aLockList:AnsiString; aRaise:Boolean; aTimeout:Integer):Boolean;
    Property CallerAction:ICallerAction read Get_CallerAction write Set_CallerAction;
    Property DataSet:TDataSet read Get_DataSet;
    Property CheckSecuretyLDB:Boolean read Get_FCheckSecuretyLDB Write Set_FCheckSecuretyLDB;
    Property TableAutoLock:Boolean read Get_FTableAutoLock write Set_FTableAutoLock;
    Property mecLastError:TMessageClass read Get_mecLastError;
    Property LockOwner:Integer Read Get_LockOwner;
    Property MessAdd:Boolean Write Set_FMessAdd;
    Property PersistentMode:TPersistentMode read Get_FPersistentMode write Set_FPersistentMode;
    function Get_LockListTimeOut:Integer;
    procedure Set_LockListTimeOut(Value:Integer);
    Property LockListTimeOut:Integer read Get_LockListTimeOut write Set_LockListTimeOut;
    Property RecursionDepth:Integer read Get_RecursionDepth write Set_RecursionDepth;
    Property CheckForTriggers:Boolean read Get_CheckForTriggers write Set_CheckForTriggers;
    function CloneForOneADOC:ILocalDataBase;
  end;

implementation

uses Sysutils, USQLParser, USQLParserTypes, Dbclient, Provider, ADOInt, Forms, Windows, UStringParam,
     ULocalDataBaseTriggerTypes, UCaller, UTrayConsts, UASMConsts, UUniqueStrUtils, Variants, UStringUtils;

var CnLDBId:Integer=0;

procedure TLocalDataBase.InternalCreate(aADOC:TADOConnection=Nil);
  var st:AnsiString;
      tmpADOCCoutCurrent:integer;
begin
  FLDBId:=InterLockedIncrement(CnLDBId);

  FCallerAction:=nil;
  FAppSecurity:=nil;
  FAppMessage:=nil;
  FLocalDataBaseTriggers:=nil;
  FSync:=nil;
  FTables:=Unassigned;
  FCountTran:=0;
  FTabTran:='';
  FCnnType := cnLocalDataType;
  FMessAdd:=True;
  FADOCCreated:=False;//для поддержки BDE
  Case FCnnType of
    0:begin//Ado
      if Assigned(aADOC) then begin
        FADOC:=aADOC;
        FOldADOCAfterConnect:=FADOC.AfterConnect;
        FOldADOCAfterDisconnect:=FADOC.AfterDisconnect;
        FADOCCreated:=False;
      end else begin
        tmpADOCCoutCurrent:=InterLockedIncrement(cnADOCCoutCurrent);
        if tmpADOCCoutCurrent > cnADOCCoutMax then cnADOCCoutMax := tmpADOCCoutCurrent;

        FADOC:=TADOConnection.Create(Nil);
        FADOC.IsolationLevel:=ilReadCommitted;
        FADOC.ConnectionString:=cnLocalDataBaseConnectionString;
        FADOC.LoginPrompt:=False;
        FADOCCreated:=True;
        FOldADOCAfterConnect:=nil;
        FOldADOCAfterDisconnect:=nil;
      end;
      FADOC.AfterConnect:=ADOConnection1AfterConnect;
      FADOC.AfterDisconnect:=ADOConnection1AfterDisconnect;
      FADOCM:=TADOCommand.Create(Nil);
      FADOCM.Connection:=FADOC;
      //FADOCM.Prepared:=True;
      FADODS:=TADODataSet.Create(Nil);
      FBDEQuery:=Nil;
      FBDEDataBase:=Nil;
    end;
    1:begin//Bde
      FBDEQuery:=TQuery.Create(Nil);
      //Только для того что бы отключить логин промт
      FBDEDataBase:=TDataBase.Create(Nil);
      FBDEDataBase.LoginPrompt:=False;
      FBDEDataBase.AliasName:=cnLocalDataBaseName;
      st:=UniqueStringStrong;
      FBDEDataBase.DatabaseName:=st;
      FBDEQuery.DatabaseName:=st;
      FADOC:=Nil;
      FADOCM:=Nil;
      FADODS:=Nil;
    end;
  else
    raise exception.create('Неправильное значение типа соединения с локальной базой.');
  end;
  FCheckSecuretyLDB:=True;
  FTableAutoLock:=True;
  FLockOwner:=-1;
  Recordset:=Nil;
  FmecLastError:=mecApp;
  FPersistentMode.Count:=0;
  FPersistentMode.Interval:=0;
  FLockListTimeOut:=15000;
  FRecursionDepth:=-1;
  FCheckForTriggers:=True;
end;

Constructor TLocalDataBase.Create(aLockOwner:Integer);
begin
  InternalCreate;
  FLockOwner:=aLockOwner;
  FGenerateLockOwner:=False;
  Inherited Create;
end;

Constructor TLocalDataBase.Create;
begin
  InternalCreate;
  FLockOwner:=InternalGetISync.ITGenerateLockOwner;
  FGenerateLockOwner:=True;
  Inherited Create;
end;

Constructor TLocalDataBase.CreateForOneADOC(aLockOwner:Integer; aADOC:TADOConnection);
begin
  InternalCreate(aADOC);
  FLockOwner:=aLockOwner;
  FGenerateLockOwner:=False;
  Inherited Create;
end;

function TLocalDataBase.CloneForOneADOC:ILocalDataBase;
begin
  Result:=TLocalDataBase.CreateForOneADOC(FLockOwner, FADOC);
  Result.CallerAction:=FCallerAction;
  Result.CheckSecuretyLDB:=FCheckSecuretyLDB;
  Result.TableAutoLock:=FTableAutoLock;
  Result.MessAdd:=FMessAdd;
  Result.PersistentMode:=FPersistentMode;
  Result.RecursionDepth:=FRecursionDepth+1;{Тут же увеличиваю счетчик вложенности}
  Result.CheckForTriggers:=FCheckForTriggers;
end;

Destructor TLocalDataBase.Destroy;
begin
  InternalUnlockList;
  if FGenerateLockOwner then InternalGetISync.ITClearLockOwner(FLockOwner);
  Recordset:=Nil;
  FreeAndNil(FADODS);
  if Assigned(FADOCM) then FADOCM.Connection:=Nil;
  FreeAndNil(FADOCM);
  if FADOCCreated then begin
    FreeAndNil(FADOC);
    InterLockedDecrement(cnADOCCoutCurrent);
  end else begin
    FADOC.AfterConnect:=FOldADOCAfterConnect;
    FADOC.AfterDisconnect:=FOldADOCAfterDisconnect;
    FADOC:=Nil;
  end;
  FreeAndNil(FBDEQuery);
  FreeAndNil(FBDEDataBase);
  FCallerAction:=nil;
  FAppSecurity:=nil;
  FAppMessage:=nil;
  FLocalDataBaseTriggers:=nil;
  FSync:=nil;
  FTables:=Unassigned;
  Inherited Destroy;
end;

function TLocalDataBase.Get_mecLastError:TMessageClass;
begin
  Result:=FmecLastError;
  FmecLastError:=mecApp;
end;

procedure TLocalDataBase.Set_CallerAction(Value:ICallerAction);
begin
  FCallerAction:=Value;
end;

function TLocalDataBase.Get_CallerAction:ICallerAction;
begin
  Result:=FCallerAction;
end;

function TLocalDataBase.Get_FCheckSecuretyLDB:Boolean;
begin
  Result:=FCheckSecuretyLDB;
end;

procedure TLocalDataBase.Set_FCheckSecuretyLDB(Value:Boolean);
begin
  FCheckSecuretyLDB:=Value;
end;

function TLocalDataBase.Get_FTableAutoLock:Boolean;
begin
  Result:=FTableAutoLock;
end;

procedure TLocalDataBase.Set_FTableAutoLock(Value:Boolean);
begin
  FTableAutoLock:=Value;
end;

procedure TLocalDataBase.Set_FMessAdd(Value:Boolean);
begin
  FMessAdd:=Value;
end;

function TLocalDataBase.Get_FPersistentMode:TPersistentMode;
begin
  Result:=FPersistentMode;
end;

procedure TLocalDataBase.Set_FPersistentMode(Value:TPersistentMode);
begin
  FPersistentMode:=Value;
end;

function TLocalDataBase.Get_LockOwner:Integer;
begin
  Result:=FLockOwner;
end;

function TLocalDataBase.Get_RecursionDepth:Integer;
begin
  Result:=FRecursionDepth;
end;

procedure TLocalDataBase.Set_RecursionDepth(Value:Integer);
begin
  FRecursionDepth:=Value;
end;

function TLocalDataBase.Get_CheckForTriggers:Boolean;
begin
  Result:=FCheckForTriggers;
end;

procedure TLocalDataBase.Set_CheckForTriggers(Value:Boolean);
begin
  FCheckForTriggers:=Value;
end;

function TLocalDataBase.Get_LockListTimeOut:Integer;
begin
  Result:=FLockListTimeOut;
end;

procedure TLocalDataBase.Set_LockListTimeOut(Value:Integer);
begin
  FLockListTimeOut:=Value;
end;

procedure TLocalDataBase.UASMessAdd(aStartTime:TDateTime; const stMess:AnsiString; MessageClass:TMessageClass; MessType:TMessageStyle);
begin
  if FMessAdd then begin
    if assigned(FCallerAction) then FCallerAction.ITMessAdd(aStartTime, now, 'LDB'+IntToStr(FLDBId)+'/'+IntToStr(FLockOwner), stMess, MessageClass, MessType) else
        InternalGetIAppMessage.ITMessAdd(aStartTime, now, InternalGetUserName, 'LDB'+IntToStr(FLDBId)+'/'+IntToStr(FLockOwner), stMess, MessageClass, MessType);
  end;
end;

procedure TLocalDataBase.ADOConnection1AfterConnect(Sender:TObject);
begin
  //UASMessAdd(Now, 'Connected to LocalDB(ADO). AllocMemCount='+IntToStr(AllocMemCount)+', AllocMemSize='+IntToStr(AllocMemSize), mecApp, mesInformation);
end;

procedure TLocalDataBase.ADOConnection1AfterDisconnect(Sender:TObject);
begin
  InternalUnlockList;
  //UASMessAdd(Now, 'Disconnected from LocalDB(ADO). AllocMemCount='+IntToStr(AllocMemCount)+', AllocMemSize='+IntToStr(AllocMemSize), mecApp, mesInformation);
end;

function TLocalDataBase.WaitForLockList(const aLockList:AnsiString; aRaise:Boolean; aTimeout:Integer):Boolean;
begin
  Result:=InternalGetISync.ITSetLockListWait(aLockList, FCallerAction{InternalGetUserName}, FLockOwner, aRaise, aTimeout, FMessAdd);//таймаут 15 сек, по истечении raise.
end;

procedure TLocalDataBase.InternalUnlockList;
  var tmpStringParam:TStringParam;
      iI:Integer;
begin
  if FTabTran<>'' then begin
    tmpStringParam:=TStringParam.Create;
    try
      tmpStringParam.stTabCMD:=stTabCMD;
      tmpStringParam.stAddCMD:=stAddCMD;
      tmpStringParam.stDelCMD:=stDelCMD;
      tmpStringParam.StringParam:=FTabTran;
      tmpStringParam.GetParamMode:=cmAdd;
      FTabTran:='';
      for iI:=1 to tmpStringParam.CountParam do begin
        FTabTran:=FTabTran+'-'+tmpStringParam.GetParam(iI)+';';
      end;
    finally
      tmpStringParam.Free;
    end;
    SetLength(FTabTran, Length(FTabTran)-1);//убираю последнюю запятую, уже после минусов.//Раззалочиваю
    InternalGetISync.ITSetLockList(FTabTran, FCallerAction{InternalGetUserName}, FLockOwner, True, FMessAdd);
    FTabTran:='';
  end;
end;

procedure TLocalDataBase.InternalTableLock(const aTables:Variant; var astTab, aTabTran:AnsiString; var aCountTran:Integer; var aRequireUnlocking:Boolean);
  var iI:Integer;
begin
  aRequireUnlocking:=False;//ставлю флаг что не требуется разлокирование//локирование разрешено
  if VarIsArray(aTables) then begin//есть таблицы
    astTab:='';
    for iI:=VarArrayLowBound(aTables, 1) to VarArrayHighBound(aTables, 1) do begin
      Case TSQLCommandType(Integer(aTables[iI][0])) of
        sctSelect:;//Ничего не лочу
        {8}sctCreate, {9}sctAlter, {10}sctDrop, {11}sctTruncate:;//Поскольку SQLParser пока не умеет извлекать имена из этих таблиц, то ничего не делаю.
        sctInsert, sctDelete, sctUpdate, sctExec:begin
          // Для поддержки лока в транзакции
          if aCountTran>0 then begin
            //если в транзакции то надо разлочивать после Commit-а или Roolback.
            //поэтому держу свой списочек и освобождаю его по завершении транзакции.
            //При этом если таблица уже есть в списке локов транзакции, то повторно ее не лочу - это оптимизация.
            if Pos(UpperCase(VarToStr(aTables[iI][1])), UpperCase(aTabTran))<1 then begin//Такая таблица еще не залочена
              astTab:=astTab+'+'+VarToStr(aTables[iI][1])+';';//формирую запрос для лока в транзакции
            end;
          end else begin//Эти комманды требуют лок
            if Pos(UpperCase(VarToStr(aTables[iI][1])), UpperCase(astTab))<1 then begin
              astTab:=astTab+'+'+VarToStr(aTables[iI][1])+';'; //формирую запрос для лока
            end;
          end;
        end;
        sctBeginTran:begin
          Inc(aCountTran);//увеличиваю счетчик транцакций
        end;
        sctCommitTran, sctRollbackTran:begin
          {!!}FADOCM.Prepared:=False;
          Dec(aCountTran);//уменьшаю счетчик транцакций
          if (aCountTran<1)And(aTabTran<>'') then aRequireUnlocking:=True; //ставлю флаг что требуется разлокирование
        end;
      else
        raise exception.create('Внутренняя ошибка. TSQLCommandType(aTables[iI][0])='+inttostr(Integer(TSQLCommandType(aTables[iI][0])))+'.');
      end;
    end;
    if astTab<>'' then begin//есть таблицы которые надо лочить
      SetLength(astTab, Length(astTab)-1); //убираю последнюю запятую, без транзакции//Пробую залочить
      InternalGetISync.ITSetLockListWait(astTab, FCallerAction{InternalGetUserName}, FLockOwner, True, FLockListTimeOut{15000}, FMessAdd);//таймаут 15 сек, по истечении raise.
      if aCountTran>0 then begin//для Tran
        if aTabTran<>'' then aTabTran:=aTabTran+';'+astTab else aTabTran:=astTab;
        astTab:='';//Сбрасываю чтобы не разлочивалось, т.к. это в транзакции.
      end else begin//установлен лок
        aRequireUnlocking:=True;//ставлю флаг что требуется разлокирование
      end;
    end;
  end;
end;

(*procedure TLocalDataBase.InternalTableUnLock(aCountTran:Integer; var aTabTran, astTab:AnsiString);
  var tmpStringParam:TStringParam;
      iI:Integer;
begin//Преобразую строку из '+' в '-'
  tmpStringParam:=TStringParam.Create;
  try
    tmpStringParam.stTabCMD:=stTabCMD;
    tmpStringParam.stAddCMD:=stAddCMD;
    tmpStringParam.stDelCMD:=stDelCMD;//для транзакции
    if aCountTran<1 then begin
      if aTabTran<>'' then begin//Транзакция закончилась.
        if astTab<>'' then begin//в последний заход были данные
          tmpStringParam.StringParam:=aTabTran+';'+astTab;
        end else begin//не были данные
          tmpStringParam.StringParam:=aTabTran;
        end;
      end else begin//Транзакции не было или не было захвачено таблиц в транзакции.
        tmpStringParam.StringParam:=astTab;
      end;
    end else begin//Транзакция не закончилась
      tmpStringParam.StringParam:=astTab;
    end;
    tmpStringParam.GetParamMode:=cmAdd;
    astTab:='';
    for iI:=1 to tmpStringParam.CountParam do begin
      astTab:=astTab+'-'+tmpStringParam.GetParam(iI)+';';
    end;
  finally
    tmpStringParam.Free;
  end;
  SetLength(astTab, Length(astTab)-1); // убираю последнюю запятую
  //if FDataCase=Nil then raise exception.create('FDataCase is NULL.');
  //Раззалочиваю
  InternalGetISync.ITSetLockList(astTab, FCallerAction{InternalGetUserName}, FLockOwner{FASMNum}, True, FMessAdd);
  if aCountTran<1 then aTabTran:='';//для транзакции
end;*)

procedure TLocalDataBase.InternalTableUnLock(aCountTran:Integer; var aTabTran, astTab:AnsiString);
  var tmpTabs:ansiString;
      tmpCurrentTab:ansiString;
      tmpI:integer;

  //var tmpStringParam:TStringParam;
  //    iI:Integer;
begin//Преобразую строку из '+' в '-'
  if aCountTran<1 then begin
    if aTabTran<>'' then begin//Транзакция закончилась.
      if astTab<>'' then begin//в последний заход были данные
        tmpTabs := aTabTran+';'+astTab;
      end else begin//не были данные
        tmpTabs := aTabTran;
      end;
    end else begin//Транзакции не было или не было захвачено таблиц в транзакции.
      tmpTabs := astTab;
    end;
  end else begin//Транзакция не закончилась
    tmpTabs := astTab;
  end;

  astTab := '';
  tmpI := -1;
  while true do begin
    tmpCurrentTab := GetParamFromParamsStr(tmpI, tmpTabs, ';');
    if tmpI = -1 then break;
    if tmpCurrentTab = '' then raise exception.create('tmpCurrentTab = ''''');

    if tmpCurrentTab[1] = '+' then astTab := astTab + '-' + copy(tmpCurrentTab, 2, length(tmpCurrentTab)-1) + ';';
  end;

  if astTab <> '' then begin
    SetLength(astTab, Length(astTab)-1); // убираю последнюю запятую
    //if FDataCase=Nil then raise exception.create('FDataCase is NULL.');
    //Раззалочиваю
    InternalGetISync.ITSetLockList(astTab, FCallerAction{InternalGetUserName}, FLockOwner{FASMNum}, true, FMessAdd);
  end;

  if aCountTran<1 then aTabTran:='';//для транзакции
end;

function TLocalDataBase.Get_DataSet:TDataSet;
begin
  Case FCnnType of
    0:begin//Ado
      if FADODS<>Nil then begin
        Result := FADODS;
      end else begin
        raise exception.create('Get_DataSet: FADODS=Nil.');
      end;
    end;
    1:begin//Bde
      if FBDEQuery<>Nil then begin
        Result := FBDEQuery;
      end else begin
        raise exception.create('Get_DataSet: FBDEQuery=Nil.');
      end;
    end;
  else
    raise exception.create('Неправильное значение типа соединения с локальной базой.');
  end;
end;

function TLocalDataBase.ExecSQL(const aSQL:AnsiString):Integer;
  var tmpV:OleVariant;
begin
  tmpV:=unassigned;
  Result:=InternalExec(rmdSQL, aSQL, tmpV);
  tmpV:=unassigned;
end;

function TLocalDataBase.ExecSQL(const aSQL:AnsiString; var aParams:OleVariant):Integer;
begin
  Result:=InternalExec(rmdSQL, aSQL, aParams);
end;

function TLocalDataBase.ExecSQL(const aSQL:AnsiString; var aParams:TParams):Integer;
  var tmpV:OleVariant;
begin
  tmpV:=PackageParams(aParams);
  Result:=InternalExec(rmdSQL, aSQL, tmpV);
  UnpackParams(tmpV, aParams);
end;

//Speed: AutoLock         ~0.05 msec
//       MessAdd          ~0.3  msec
//       CheckForTriggers ~0.6  msec
function TLocalDataBase.InternalExec(aRunSQLMode:TRunSQLMode; const aSQL:AnsiString; var aParams:OleVariant):Integer;
  var MyParams:TParams;
      blRequireUnlocking:Boolean;
      tmpSQLCommandParser:TSQLCommandParser;
      iI, iPersistentCount:Integer;
      stTab:AnsiString;
      iStartTime:TDateTime;
{$Ifdef MyDebug}
      st_:AnsiString;
{$Endif}
      tmpTriggerData:TTriggerData;
      tmpTriggerDataFromBeforeToAfter:OleVariant;
begin
  iStartTime:=Now;
  Result:=-1;
  Recordset:=nil;
  FTables:=Unassigned;
  tmpTriggerDataFromBeforeToAfter:=Unassigned;
  if (cnCheckSecuretyLDB and FCheckSecuretyLDB) or (cnTableAutoLock And FTableAutoLock) or (cnCheckForTriggers And FCheckForTriggers) then begin
    //Если разрешена проверка LDB или AutoLock.
    //Беру названия таблиц из SQL. ---
    try
      tmpSQLCommandParser:=TSQLCommandParser.Create;
      try
        case aRunSQLMode of
          //Это SQL команда
          rmdSQL:tmpSQLCommandParser.ParseMode:=pmdSQLString;
          //Это вызов процедуры
          rmdProc:tmpSQLCommandParser.ParseMode:=pmdExecProc;
        end;
        tmpSQLCommandParser.SQLCommandToTableName(aSQL, FTables);
      Finally
        tmpSQLCommandParser.Free;
      end;
    except on e:exception do begin
      if cnIgnoreErrorsInSQLParser then begin
        FTables:=Unassigned;
        if FMessAdd then UASMessAdd(iStartTime, 'SQLParser('+aSQL+'): '''+e.message+'''.', mecApp, mesError);
      end else begin
        e.message:='iExec.SQLParser: '+e.message;
        raise;
      end;
    end;end;
  end;
  if cnCheckSecuretyLDB and FCheckSecuretyLDB then begin
    try
      InternalGetIAppSecurity.ITCheckSecurityLDB(FTables, InternalGetSecurityContext);
    except
      FmecLastError:=mecSecurity;
      raise;
    end;
  end;
  //Проверяю локирование таблиц ---
  blRequireUnlocking:=False;
  if cnTableAutoLock And FTableAutoLock then begin  {Speed: меньше 1 msec}
    InternalTableLock(FTables, stTab, FTabTran, FCountTran, blRequireUnlocking);
  end;
  try
{$Ifdef MyDebug}
    st_:='';
{$Endif}
    //Распаковываю параметры и выполняю комманду SQL команду на Ado или Bde.
    Case FCnnType of
      0:begin // Ado -----------------------------------------------------------------------
        //Выполняю
{Назначаю SQL строку}
        //чищу
        FADOCM.Connection := nil;//передергиваю т.к. иногда в ADOCM "застревает" предыдущий SQL запрос
        FADOCM.Connection := FADOC;
        FADOCM.CommandType := cmdUnknown;//передергиваю т.к. иногда в ADOCM "застревает" предыдущий SQL запрос
        FADOCM.CommandText := '';

        //назначаю
        Case aRunSQLMode of
          rmdSQL:Begin//Это SQL команда
            FADOCM.CommandType:=cmdText;
            FADOCM.CommandText:=aSQL;
          end;
          rmdProc:Begin//Это вызов процедуры
            FADOCM.CommandType:=cmdStoredProc;
            FADOCM.CommandText:=aSQL;
          end;
        end;
{Назначаю SQL строку}//Params
        if (VarIsNull(aParams)=false) and (VarIsEmpty(aParams)=false) then begin
          MyParams:=TParams.Create(Nil);
          UnpackParams(aParams, MyParams);
          FADOCM.Parameters.Clear;
          FADOCM.Parameters.Assign(MyParams);
{$Ifdef MyDebug}
          try
            st_:=' |IN:ParCnt='+IntToStr(MyParams.Count)+': ';
            for iI:=0 To FADOCM.Parameters.Count-1 do begin
              st_:=st_+FADOCM.Parameters.Items[iI].Name+'=''';
              st_:=st_+VarToStr(FADOCM.Parameters.Items[iI].Value)+'''('+IntToStr(Integer(FADOCM.Parameters.Items[iI].DataType))+')';
            end;
          except
            on e:exception do begin
              st_:='IN:Ошибка при открытии параметров: '+e.message;
            end;
          end;
{$Endif}
        End else FADOCM.Parameters.Clear;
        try
          FADOCM.ExecuteOptions:=[eoExecuteNoRecords];{?}
          Recordset:=nil;{?}
          iPersistentCount:=0;
          tmpTriggerData.AllowExecuteSQL:=True;
          tmpTriggerData.AllowExecuteTriggerAfter:=True;//Before trigger
          if cnCheckForTriggers And FCheckForTriggers then begin
            if FRecursionDepth>cnMaxRecursionDepth then raise exception.create('MaxRecursionDepth='+IntToStr(cnMaxRecursionDepth));
            try
              tmpTriggerData.TriggerType:=cftBefore;
              tmpTriggerData.SQLParams:=@aParams;
              tmpTriggerData.SQLString:=@aSQL;
              tmpTriggerData.RunSQLType:=rstExec;
              tmpTriggerData.RunSQLMode:=@aRunSQLMode;
              tmpTriggerData.RecordAffected:=@Result;
              tmpTriggerData.CDSData:=Nil;
              tmpTriggerData.DataFromBeforeToAfter:=@tmpTriggerDataFromBeforeToAfter;
              InternalGetILocalDataBaseTriggers.ITExec(CloneForOneADOC, @tmpTriggerData, FTables, FCallerAction);
            except on e:exception do begin
              e.message:='Trigger(before): '+e.message;
              raise;
            end;end;
          end;//Exec
          try
            if tmpTriggerData.AllowExecuteSQL then begin
              While true do begin
                try
                  FADOCM.Execute(Result, EmptyParam);
                  break;
                except
                  if iPersistentCount>=FPersistentMode.Count then raise
                    else Inc(iPersistentCount);
                end;
                sleep(FPersistentMode.Interval);
              end;
{$Ifdef MyDebug}
              if (VarIsNull(aParams)=false) and (VarIsEmpty(aParams)=false) then begin
                if aRunSQLMode = rmdProc then begin
                  try
                    st_:=st_+' |OUT:ParCnt='+IntToStr(MyParams.Count)+': ';
                    for iI:=0 To FADOCM.Parameters.Count-1 do begin
                      st_:=st_+FADOCM.Parameters.Items[iI].Name+'=''';
                      st_:=st_+VarToStr(FADOCM.Parameters.Items[iI].Value)+'''('+IntToStr(Integer(FADOCM.Parameters.Items[iI].DataType))+')';
                    end;
                  except on e:exception do begin
                    st_:=st_+'OUT:Ошибка при открытии параметров: '+e.message;
                  end;end;
                end;  
              end else st_:='';
              if iPersistentCount=0 then
                if FMessAdd then UASMessAdd(iStartTime, 'LExec: '+aSQL+st_+'(RA='+IntToStr(Result)+').', mecSQL, mesInformation)
              else
                if FMessAdd then UASMessAdd(iStartTime, 'LExec: '+aSQL+st_+'(RA='+IntToStr(Result)+',PC='+IntToStr(iPersistentCount)+').', mecSQL, mesInformation);
              st_:='';
{$Endif}
            end else begin//Не требуется выполнение//RecAff, SQLParams уже назначены
              if FMessAdd then UASMessAdd(iStartTime, 'LExec: '+aSQL+st_+'(AE=False,RA='+IntToStr(Result)+').', mecSQL, mesInformation)
            end;
          except on e:exception do begin
{$Ifdef MyDebug}
            if iPersistentCount=0 then if FMessAdd then UASMessAdd(iStartTime, 'LExec: '+aSQL+st_+'(Error:'''+Copy(e.message, 1, 28)+'..'').', mecSQL, mesInformation)
                else if FMessAdd then UASMessAdd(iStartTime, 'LExec: '+aSQL+st_+'(Error:'''+Copy(e.message, 1, 28)+'..'',PC='+IntToStr(iPersistentCount)+').', mecSQL, mesInformation);
{$Endif}      e.message:=e.message+'(SQL:'+Copy(aSQL, 1, 35)+'..).';
              raise;
          end;end;//After trigger
          if cnCheckForTriggers And FCheckForTriggers And tmpTriggerData.AllowExecuteTriggerAfter then begin
            if FRecursionDepth>cnMaxRecursionDepth then raise exception.create('MaxRecursionDepth='+IntToStr(cnMaxRecursionDepth));
            try
              tmpTriggerData.TriggerType:=cftAfter;
              tmpTriggerData.SQLParams:=@aParams;
              tmpTriggerData.SQLString:=@aSQL;
              tmpTriggerData.RunSQLType:=rstExec;
              tmpTriggerData.RunSQLMode:=@aRunSQLMode;
              tmpTriggerData.RecordAffected:=@Result{integer};
              tmpTriggerData.CDSData:=Nil{OleVariant};
              tmpTriggerData.AllowExecuteSQL:=False;
              tmpTriggerData.AllowExecuteTriggerAfter:=False;
              tmpTriggerData.DataFromBeforeToAfter:=@tmpTriggerDataFromBeforeToAfter;
              InternalGetILocalDataBaseTriggers.ITExec(CloneForOneADOC, @tmpTriggerData, FTables, FCallerAction);
            except on e:exception do begin
              e.message:='Trigger(after): '+e.message;
              raise;
            end;end;
          end;
        Finally//Params
          if (VarIsNull(aParams)=false) and (VarIsEmpty(aParams)=false) then begin
            MyParams.Assign(FADOCM.Parameters);
            aParams:=PackageParams(MyParams);
            FreeAndNil(MyParams);
          end;
        end;
      end;
      1:begin//Bde -----------------------------------------------------------------------
        //Выполняю
        FBDEQuery.SQL.Clear;
        FBDEQuery.SQL.Add(aSQL);
        //Params
        if (VarIsNull(aParams)=false) and (VarIsEmpty(aParams)=false) then begin
          UnpackParams(aParams, FBDEQuery.Params);
{$Ifdef MyDebug}
          try
            st_:=' |ParCnt='+IntToStr(FBDEQuery.Params.Count)+': ';
            for iI:=0 To FBDEQuery.Params.Count-1 do begin
              st_:=st_+FBDEQuery.Params.Items[iI].Name+'=''';
              st_:=st_+VarToStr(FBDEQuery.Params.Items[iI].Value)+'''('+IntToStr(Integer(FBDEQuery.Params.Items[iI].DataType))+')';
            end;
          except on e:exception do begin
            st_:='Ошибка при открытии параметров: '+e.message;
          end;end;
{$Endif}
        end else FBDEQuery.Params.Clear;
        try
{$Ifdef MyDebug}
          if FMessAdd then UASMessAdd(iStartTime, 'LExec(BDE): '+aSQL+st_, mecSQL, mesInformation);
{$endif}
          try
            FBDEQuery.ExecSQL;
          except on e:exception do begin
            e.message:=e.message+'(SQL:'+Copy(aSQL, 1, 35)+'..).';
            raise;
          end;end;
          Result:=FBDEQuery.RowsAffected;
        finally
          //Params
          if (VarIsNull(aParams)=false) and (VarIsEmpty(aParams)=false) then begin
            aParams:=PackageParams(FBDEQuery.Params);
          end;
        end;
      end;
    end;
  finally//Проверяю разлокирование таблиц
    if blRequireUnlocking then begin//Требуется разлокирование
      InternalTableUnLock(FCountTran, FTabTran, stTab);
    end;
  end;
end;

function TLocalDataBase.InternalGetCurFromQueryForCDS(var aRecAff:Integer):OleVariant;
  var tmpDSWriter: TDataPacketWriter;
      tmpRecsOut: integer;
begin
  result := unassigned;
  try
    tmpDSWriter := TDataPacketWriter.Create;
    try
      FBDEQuery.CheckBrowseMode;
      FBDEQuery.BlockReadSize := -1;
      tmpDSWriter.Constraints := True;
      tmpDSWriter.PacketOptions := [grMetaData];
      tmpDSWriter.Options := [poFetchBlobsOnDemand];
      tmpRecsOut := -1;
      tmpDSWriter.GetDataPacket(FBDEQuery, tmpRecsOut, result);
    finally
      tmpDSWriter.free;
    end;
    aRecAff := tmpRecsOut;
  except on e:exception do begin
    result := unassigned;
    e.message:='IGetCurFromQueryForCDS: '+e.message;
    raise;
  end;end;
end;

(*function TLocalDataBase.InternalGetFirstCurForCDS(My_RecSet:_Recordset; var aRecAff:Integer):OleVariant;
  var DSWriter:TDataPacketWriter;
      RecsOut:Integer;
      tmpRecAff:OleVariant;
begin
  try
    Result:=UnAssigned;
    tmpRecAff:=aRecAff;
    while My_RecSet<>nil do begin
      if My_RecSet.State=adStateOpen then
        begin
          try
            DSWriter:=nil;
            FADODS.Recordset:=My_RecSet;
            FADODS.CheckBrowseMode;
            FADODS.BlockReadSize:=-1;
            DSWriter:=TDataPacketWriter.Create;
            DSWriter.Constraints:=True;
            DSWriter.PacketOptions:=[grMetaData];
            DSWriter.Options:=[poFetchBlobsOnDemand];
            RecsOut:=-1;
            DSWriter.GetDataPacket(FADODS, RecsOut, Result);
          finally
            if DSWriter<>Nil then FreeAndNil(DSWriter);
          end;
          aRecAff:=RecsOut;
          FADODS.First;
          Break;
        end;
      My_RecSet:=My_RecSet.NextRecordset(tmpRecAff);
    end;
  except on e:exception do begin
    Result:=Null;
    e.message:='IGetFirstCurForCDS: '+e.message;
    raise;
  end;end;
end;*)

function TLocalDataBase.OpenSQL(const aSQL:AnsiString):OleVariant;
  var aParams:OleVariant;
      tmpRecAff:Integer;
begin
  aParams:=Unassigned;
  Result:=InternalOpen(rmdSQL, aSQL, aParams, tmpRecAff, false);
  aParams:=Unassigned;
end;

function TLocalDataBase.OpenSQL(const aSQL:AnsiString; var aParams:OleVariant):OleVariant;
  var tmpRecAff:Integer;
begin
  Result:=InternalOpen(rmdSQL, aSQL, aParams, tmpRecAff, false);
end;

function TLocalDataBase.OpenSQL(const aSQL:AnsiString; var aParams:TParams):OleVariant;
  var tmpRecAff:Integer;
      tmpV:OleVariant;
begin
  tmpV:=PackageParams(aParams);
  Result:=InternalOpen(rmdSQL, aSQL, tmpV, tmpRecAff, false);
  UnpackParams(tmpV, aParams);
end;

function TLocalDataBase.OpenSQL(const aSQL:AnsiString; var aParams:OleVariant; var aRecAff:Integer):OleVariant;
begin
  Result:=InternalOpen(rmdSQL, aSQL, aParams, aRecAff, false);
end;

function TLocalDataBase.OpenSQL(const aSQL:AnsiString; var aParams:TParams; var aRecAff:Integer):OleVariant;
  var tmpV:OleVariant;
begin
  tmpV:=PackageParams(aParams);
  Result:=InternalOpen(rmdSQL, aSQL, tmpV, aRecAff, false);
  UnpackParams(tmpV, aParams);
end;

function TLocalDataBase.OpenSQL(const aSQL:AnsiString; var aRecAff:Integer):OleVariant;
  var tmpV:OleVariant;
begin
  Result:=InternalOpen(rmdSQL, aSQL, tmpV, aRecAff, false);
end;

function TLocalDataBase.ExistsSQL(const aSQL:AnsiString):boolean;
  var tmpParams:OleVariant;
      tmpRecAff:Integer;
begin
  InternalOpen(rmdSQL, aSQL, tmpParams, tmpRecAff, true{OnlyExists});
  result:=tmpRecAff>0;
end;

function TLocalDataBase.ExistsSQL(const aSQL:AnsiString; out aRecAff:Integer):boolean;
  var tmpParams:OleVariant;
begin
  InternalOpen(rmdSQL, aSQL, tmpParams, aRecAff, true{OnlyExists});
  result:=aRecAff>0;
end;

function TLocalDataBase.ExistsSQL(const aSQL:AnsiString; var aParams:OleVariant):boolean;
  var tmpRecAff:Integer;
begin
  InternalOpen(rmdSQL, aSQL, aParams, tmpRecAff, true{OnlyExists});
  result:=tmpRecAff>0;
end;

function TLocalDataBase.ExistsSQL(const aSQL:AnsiString; var aParams:OleVariant; out aRecAff:Integer):boolean;
begin
  InternalOpen(rmdSQL, aSQL, aParams, aRecAff, true{OnlyExists});
  result:=aRecAff>0;
end;

function TLocalDataBase.ExistsSQL(const aSQL:AnsiString; var aParams:TParams):boolean;
  var tmpRecAff:Integer;
      tmpV:OleVariant;
begin
  tmpV:=PackageParams(aParams);
  InternalOpen(rmdSQL, aSQL, tmpV, tmpRecAff, true{OnlyExists});
  UnpackParams(tmpV, aParams);
  result:=tmpRecAff>0;
end;

function TLocalDataBase.ExistsSQL(const aSQL:AnsiString; var aParams:TParams; out aRecAff:Integer):boolean;
  var tmpV:OleVariant;
begin
  tmpV:=PackageParams(aParams);
  InternalOpen(rmdSQL, aSQL, tmpV, aRecAff, true{OnlyExists});
  UnpackParams(tmpV, aParams);
  result:=aRecAff>0;
end;

function TLocalDataBase.InternalOpen(aRunSQLMode:TRunSQLMode; const aSQL:AnsiString; var aParams:OleVariant; var aRecAff:Integer; aOnlyExists:Boolean):OleVariant;
  function localGetCmd:AnsiString;begin
    if aOnlyExists then result:='LExists' else result:='LOpen';
  end;
  var MyParams:TParams;
      blRequireUnlocking:Boolean;
      tmpSQLCommandParser:TSQLCommandParser;
      stTab:AnsiString;
      iPersistentCount:Integer;
      iStartTime:TDateTime;
{$Ifdef MyDebug}
      st_:AnsiString;
      ii:Integer;
{$Endif}
      tmpTriggerData:TTriggerData;
      tmpTriggerDataFromBeforeToAfter:OleVariant;
      tmpRecordset:_Recordset;
begin
  iStartTime:=Now;
  FTables:=Unassigned;
  Result:=UnAssigned;
  tmpTriggerDataFromBeforeToAfter:=unassigned;
  if (cnCheckSecuretyLDB and FCheckSecuretyLDB) or (cnTableAutoLock and FTableAutoLock) or (cnCheckForTriggers and FCheckForTriggers) then begin//Если разрешена проверка LDB или AutoLock.//Беру названия таблиц из SQL. ---*)
    try
      tmpSQLCommandParser:=TSQLCommandParser.Create;
      try
        case aRunSQLMode of//Это SQL команда
          rmdSQL:tmpSQLCommandParser.ParseMode:=pmdSQLString;//Это вызов процедуры
          rmdProc:tmpSQLCommandParser.ParseMode:=pmdExecProc;
        end;
        tmpSQLCommandParser.SQLCommandToTableName(aSQL, FTables);
      finally
        tmpSQLCommandParser.Free;
      end;
    except on e:exception do begin
      if cnIgnoreErrorsInSQLParser then begin
        FTables:=Unassigned;
        if FMessAdd then UASMessAdd(iStartTime, 'SQLParser('+aSQL+'): '''+e.message+'''.', mecApp, mesError);
      end else begin
        e.message:='iOpen.SQLParser: '+e.message;
        raise;
      end;
    end;end;
  end;
  if cnCheckSecuretyLDB and FCheckSecuretyLDB then begin//Если разрешена проверка LDB.
    try
      InternalGetIAppSecurity.ITCheckSecurityLDB(FTables, InternalGetSecurityContext);//CheckSecurity(FTables);
    except
      FmecLastError:=mecSecurity;
      raise;
    end;
  end;//Проверяю локирование таблиц ---
  blRequireUnlocking := False;
  if cnTableAutoLock And FTableAutoLock then begin
    InternalTableLock(FTables, stTab, FTabTran, FCountTran, blRequireUnlocking);
  end;
  try
{$Ifdef MyDebug}
    st_:='';
{$Endif}//Распаковываю параметры и выполняю комманду SQL команду на Ado или Bde.
    case FCnnType of
      0:begin//Ado//Выполняю
{Назначаю SQL строку}
        //чищу
        FADOCM.Connection := nil;//передергиваю т.к. иногда в ADOCM "застревает" предыдущий SQL запрос
        FADOCM.Connection := FADOC;
        FADOCM.CommandType := cmdUnknown;//передергиваю т.к. иногда в ADOCM "застревает" предыдущий SQL запрос
        FADOCM.CommandText := '';

        //назначаю
        case aRunSQLMode of
          rmdSQL:Begin//Это SQL команда
            FADOCM.CommandType := cmdText;
            FADOCM.CommandText := aSQL;
          end;
          rmdProc:Begin//Это вызов процедуры
            FADOCM.CommandType := cmdStoredProc;
            FADOCM.CommandText := aSQL;
          end;
        end;
{Назначаю SQL строку}//Params
        if (VarIsNull(aParams)=false) and (VarIsEmpty(aParams)=false) then begin
          MyParams:=TParams.Create(nil);
          UnpackParams(aParams, MyParams);
          FADOCM.Parameters.Clear;
          FADOCM.Parameters.Assign(MyParams);
{$Ifdef MyDebug}
          try
            st_:=' |ParCnt='+IntToStr(MyParams.Count)+': ';
            for iI:=0 To FADOCM.Parameters.Count-1 do begin
              st_:=st_+FADOCM.Parameters.Items[iI].Name+'=''';
              st_:=st_+VarToStr(FADOCM.Parameters.Items[iI].Value)+'''('+IntToStr(Integer(FADOCM.Parameters.Items[iI].DataType))+')';
            end;
          except
            on e:exception do begin
              st_:=' Ошибка при открытии параметров: '+e.message;
            end;
          end;
{$Endif}
        end else FADOCM.Parameters.Clear;
        try
          FADOCM.ExecuteOptions:=[];
          Recordset:=nil;{?}
          iPersistentCount:=0;
          tmpTriggerData.AllowExecuteSQL:=True;
          tmpTriggerData.AllowExecuteTriggerAfter:=True;
          if cnCheckForTriggers And FCheckForTriggers then begin//Before trigger
            if FRecursionDepth>cnMaxRecursionDepth then raise exception.create('MaxRecursionDepth='+IntToStr(cnMaxRecursionDepth));
            try
              tmpTriggerData.TriggerType:=cftBefore;
              tmpTriggerData.SQLParams:=@aParams{OleVariant};
              tmpTriggerData.SQLString:=@aSQL{AnsiString};
              tmpTriggerData.RunSQLType:=rstOpen;
              tmpTriggerData.RunSQLMode:=@aRunSQLMode;
              tmpTriggerData.RecordAffected:=@aRecAff{integer};
              tmpTriggerData.CDSData:=@Result{OleVariant};
              tmpTriggerData.DataFromBeforeToAfter:=@tmpTriggerDataFromBeforeToAfter;
              InternalGetILocalDataBaseTriggers.ITExec(CloneForOneADOC, @tmpTriggerData, FTables, FCallerAction);
            except on e:exception do begin
              e.message:='Trigger(before): '+e.message;
              raise;
            end;end;
          end;//Execute
          if tmpTriggerData.AllowExecuteSQL then begin
            try
              While true do begin
                try
                  if aOnlyExists then begin
                    tmpRecordset := FADOCM.Execute(aRecAff, EmptyParam);
                    aRecAff := tmpRecordset.RecordCount;
                    tmpRecordset:=nil;
                  end else Recordset:=FADOCM.Execute(aRecAff, EmptyParam);
                  break;
                except
                  if iPersistentCount>=FPersistentMode.Count then raise
                    else Inc(iPersistentCount);
                end;
                sleep(FPersistentMode.Interval);
              end;
              if aOnlyExists then Result:=unassigned else result := GetDBCursor(Recordset, FADODS, aRecAff);//InternalGetFirstCurForCDS(Recordset, aRecAff);
            except on e:exception do begin
{$Ifdef MyDebug}
              if iPersistentCount=0 then
                if FMessAdd then UASMessAdd(iStartTime, localGetCmd+': '+aSQL+st_+'(Error:'''+Copy(e.message, 1, 28)+'..'').', mecSQL, mesInformation)
              else
                if FMessAdd then UASMessAdd(iStartTime, localGetCmd+': '+aSQL+st_+'(Error:'''+Copy(e.message, 1, 28)+'..'',PC='+IntToStr(iPersistentCount)+').', mecSQL, mesInformation);
{$Endif}
              e.message:=e.message+'(SQL:'+Copy(aSQL, 1, 35)+'..).';
              raise;
            end;end;
{$Ifdef MyDebug}
            if iPersistentCount=0 then
              if FMessAdd then UASMessAdd(iStartTime, localGetCmd+': '+aSQL+st_+'(RA='+IntToStr(aRecAff)+').', mecSQL, mesInformation)
            else
              if FMessAdd then UASMessAdd(iStartTime, localGetCmd+': '+aSQL+st_+'(RA='+IntToStr(aRecAff)+',PC='+IntToStr(iPersistentCount)+').', mecSQL, mesInformation);
{$Endif}
          end else begin//Не требуется выполнение//Resul, aRecAff, SQLParams уже назначены
            if FMessAdd then UASMessAdd(iStartTime, localGetCmd+': '+aSQL+st_+'(AE=False,RA='+IntToStr(aRecAff)+').', mecSQL, mesInformation)
          end;
          if cnCheckForTriggers And FCheckForTriggers and tmpTriggerData.AllowExecuteTriggerAfter then begin//After trigger
            if FRecursionDepth>cnMaxRecursionDepth then raise exception.create('MaxRecursionDepth='+IntToStr(cnMaxRecursionDepth));
            try
              tmpTriggerData.TriggerType:=cftAfter;
              tmpTriggerData.SQLParams:=@aParams;
              tmpTriggerData.SQLString:=@aSQL;
              tmpTriggerData.RunSQLType:=rstOpen;
              tmpTriggerData.RunSQLMode:=@aRunSQLMode;
              tmpTriggerData.RecordAffected:=@aRecAff{integer};
              tmpTriggerData.CDSData:=@Result{OleVariant};
              tmpTriggerData.AllowExecuteSQL:=False;
              tmpTriggerData.AllowExecuteTriggerAfter:=False;
              tmpTriggerData.DataFromBeforeToAfter:=@tmpTriggerDataFromBeforeToAfter;
              InternalGetILocalDataBaseTriggers.ITExec(CloneForOneADOC, @tmpTriggerData, FTables, FCallerAction);
            except on e:exception do begin
              e.message:='Trigger(after): '+e.message;
              raise;
            end;end;
          end;
        finally//Params
          if (VarIsNull(aParams)=false) and (VarIsEmpty(aParams)=false) then begin
            MyParams.Assign(FADOCM.Parameters);
            aParams:=PackageParams(MyParams);
            FreeAndNil(MyParams);
          end;
        end;
      end;
      1:begin//Bde//Выполняю
        FBDEQuery.SQL.Clear;
        FBDEQuery.SQL.Add(aSQL);
        if (VarIsNull(aParams)=false) and (VarIsEmpty(aParams)=false) then begin//Params
          UnpackParams(aParams, FBDEQuery.Params);
{$Ifdef MyDebug}
          try
            st_:=' |ParCnt='+IntToStr(FBDEQuery.Params.Count)+': ';
            for iI:=0 To FBDEQuery.Params.Count-1 do begin
              st_:=st_+FBDEQuery.Params.Items[iI].Name+'=''';
              st_:=st_+FBDEQuery.Params.Items[iI].AsString+'''('+IntToStr(Integer(FBDEQuery.Params.Items[iI].DataType))+')';
            end;
          except on e:exception do begin
            st_:=' Ошибка при открытии параметров: '+e.message;
          end;end;
{$Endif}
        end else FBDEQuery.Params.Clear;
        try
{$Ifdef MyDebug}
          if FMessAdd then UASMessAdd(iStartTime, localGetCmd+'(BDE): '+aSQL+st_, mecSQL, mesInformation);
{$Endif}
          try
            FBDEQuery.Open;
          except on e:exception do begin
            e.message:=e.message+'(SQL:'+Copy(aSQL, 1, 35)+'..).';
            raise;
          end;end;
          Recordset := nil;
          result := InternalGetCurFromQueryForCDS(aRecAff);
        finally
          if (VarIsNull(aParams)=false) and (VarIsEmpty(aParams)=false) then begin//Params
            aParams:=PackageParams(FBDEQuery.Params);
          end;
        end;
      end;
    else
      raise exception.create('Неправильное значение типа соединения с локальной базой.');
    end;
  finally//Проверяю разлокирование таблиц
    if blRequireUnlocking then begin//Требуется разлокирование
      InternalTableUnLock(FCountTran, FTabTran, stTab);
    end;
  end;
end;

function TLocalDataBase.ExecProc(const aSQL:AnsiString):Integer;
  var tmpV:OleVariant;
begin
  tmpV:=unassigned;
  Result:=InternalExec(rmdProc, aSQL, tmpV);
  tmpV:=unassigned;
end;

function TLocalDataBase.ExecProc(const aSQL:AnsiString; var aParams:OleVariant):Integer;
begin
  Result:=InternalExec(rmdProc, aSQL, aParams);
end;

function TLocalDataBase.ExecProc(const aSQL:AnsiString; var aParams:TParams):Integer;
  var tmpV:OleVariant;
begin
  tmpV:=PackageParams(aParams);
  Result:=InternalExec(rmdProc, aSQL, tmpV);
  UnpackParams(tmpV, aParams);
end;

function TLocalDataBase.OpenProc(const aSQL:AnsiString; var aParams:OleVariant; var aRecAff:Integer):OleVariant;
begin
  Result:=InternalOpen(rmdProc, aSQL, aParams, aRecAff, false);
end;

function TLocalDataBase.OpenProc(const aSQL:AnsiString; var aParams:TParams; var aRecAff:Integer):OleVariant;
  var tmpV:OleVariant;
begin
  tmpV:=PackageParams(aParams);
  Result:=InternalOpen(rmdProc, aSQL, tmpV, aRecAff, false);
  UnpackParams(tmpV, aParams);
end;

function TLocalDataBase.OpenProc(const aSQL:AnsiString; var aParams:OleVariant):OleVariant;
  var tmpRecAff:Integer;
begin
  Result:=InternalOpen(rmdProc, aSQL, aParams, tmpRecAff, false);
end;

function TLocalDataBase.OpenProc(const aSQL:AnsiString; var aParams:TParams):OleVariant;
  var tmpRecAff:Integer;
      tmpV:OleVariant;
begin
  tmpV:=PackageParams(aParams);
  Result:=InternalOpen(rmdProc, aSQL, tmpV, tmpRecAff, false);
  UnpackParams(tmpV, aParams);
end;

function TLocalDataBase.OpenProc(const aSQL:AnsiString):OleVariant;
  var tmpParams:OleVariant;
      tmpRecAff:Integer;
begin
  tmpParams:=Unassigned;
  Result:=InternalOpen(rmdProc, aSQL, tmpParams, tmpRecAff, false);
  tmpParams:=Unassigned;
end;

function TLocalDataBase.InternalGetIAppSecurity:IAppSecurity;
begin
  if not assigned(FAppSecurity) then cnTray.Query(IAppSecurity, FAppSecurity);
  result:=FAppSecurity;
end;

function TLocalDataBase.InternalGetIAppMessage:IAppMessage;
begin
  if not assigned(FAppMessage) then cnTray.Query(IAppMessage, FAppMessage);
  result:=FAppMessage;
end;

function TLocalDataBase.InternalGetILocalDataBaseTriggers:ILocalDataBaseTriggers;
begin
  if not assigned(FLocalDataBaseTriggers) then cnTray.Query(ILocalDataBaseTriggers, FLocalDataBaseTriggers);
  result:=FLocalDataBaseTriggers;
end;

function TLocalDataBase.InternalGetISync:ISync;
begin
  if not assigned(FSync) then cnTray.Query(ISync, FSync);
  result:=FSync;
end;

function TLocalDataBase.InternalGetUserName:AnsiString;
begin
  if assigned(FCallerAction) then result:=FCallerAction.UserName else result:='';
end;

function TLocalDataBase.InternalGetSecurityContext:Variant;
begin
  if assigned(FCallerAction) then result:=FCallerAction.SecurityContext else result:=unassigned;
end;

end.
