//Copyright © 2000-2003 by Dmitry A. Sokolyuk
{$Ifndef PegasServer}{$Ifndef EAMServer}Неназначены Defines EAMServer или PegasServer.{$endif}{$endif}{$Ifdef PegasServer}{$Ifdef EAMServer}Назначены Defines EAMServer и PegasServer.{$endif}{$endif}
unit UCommandPackServer;

interface
  uses UCommandPack, UADMTypes, UPackTypes, UPackCPRTypes;

type
  TCommandPackServer=class(TCommandPack)
  protected
    function InternalGetReverceRoute:Variant;virtual;
  public
    constructor Create;
    destructor Destroy;override;
    procedure CheckSecurityPTask(aTask:TADMTask; aProtocolType:TProtocolType; const aSecurityContext:Variant);override;
    procedure ReceiveCPT1(aPackCPR:IPackCPR; const aPDID:Variant; const aCPID:Variant; aBlockID:Integer; aCPTask:TADMTask; aPos:Integer; const aParams:Variant; const aRouteParam:Variant);override;
    procedure ReceiveCPR1(const aPDID:Variant; const aCPID:Variant; aBlockID:Integer; aCPTask:TADMTask; aPos:Integer; const aParams:Variant; const aRouteParam:Variant); override;
    procedure ReceiveCPR1Error(const aPDID:Variant; const aCPID:Variant; aBlockID:Integer; aCPTask:TADMTask; aPos:Integer; const aMessage:AnsiString; aHelpContext:Integer; aResultWithError:Boolean; const aRouteParam:Variant); override;
  end;


implementation
  uses SysUtils, {UConsts, }UBlockSQLExec, UPackConsts, ULocalDataBase, ULocalDataBaseTypes, UTTaskTypes, UDateTimeUtils,
       UErrorConsts, UADMUtils, {UTransferBfsTypes, }UCaller, UTaskImplementTypes, {UTransferBfTaskImpUtils, }UTypeUtils,
       UServerInfoTypes, UTrayConsts, UAppMessageTypes, UAdmittanceASMTypes, UServerLockTypes, UThreadsPoolTypes, USyncTypes,
       UAppSecurityTypes, UASMConsts {$Ifdef EAMServer}, UServerActionConsts, UStrQueueTypes, UServerOnlineTypes{$endif}
       , Variants;
constructor TCommandPackServer.Create;
begin
  inherited Create;
end;

destructor  TCommandPackServer.Destroy;
begin
  inherited destroy;
end;

function TCommandPackServer.InternalGetReverceRoute:Variant;
begin
  if assigned(OwnerPD) then Result:=OwnerPD.ReverceRoute(Unassigned, popError) else Result:=Unassigned;
end;

procedure TCommandPackServer.ReceiveCPT1(aPackCPR:IPackCPR; const aPDID:Variant; const aCPID:Variant; aBlockID:Integer; aCPTask:TADMTask; aPos:Integer; const aParams:Variant; const aRouteParam:Variant);
  function localGetSenderParams:Variant;begin
    if VarIsEmpty(aRouteParam) then Result:=VarArrayOf([-1{rstSTNoASM}, CPID, InternalGetReverceRoute, aCPTask]) else Result:=VarArrayOf([-1{rstSTNoASM}, CPID, InternalGetReverceRoute, aCPTask, aRouteParam]);
  end;
var   tmpLongint, tmpLongint1:Longint;
      tmpV, tmpV1:Variant;
      tmpBlockSQLExec:TBlockSQLExec;
{$Ifdef EAMServer}
      tmpLocalDataBase:ILocalDataBase;
{$endif}
  function CheckParamsIn(vlParamsCount:Integer; const _V:OleVariant; aRaise:Boolean=true):boolean;
    var _iSize:Integer;
  begin
{1..n}if (VarType(_V) and VarArray) = varArray then _iSize:=VarArrayHighBound(_V,1)-VarArrayLowBound(_V,1)+1 else
{-1}    if (VarType(_V)=varNull) Or (VarType(_V)=varEmpty) then _iSize:=-1 else
{0}       _iSize:=0;
      result:=vlParamsCount=_iSize;
      if (not result)and(aRaise) then raise exception.create('не верное количество параметров(ожидается='+IntToStr(vlParamsCount)+', пришло='+IntToStr(_iSize)+').');
    end;
  var tmpAdmittanceASM:IAdmittanceASM;
  function localGetAdmittanceASM:IAdmittanceASM;begin
    if not assigned(tmpAdmittanceASM) then cnTray.Query(IAdmittanceASM, tmpAdmittanceASM);
    result:=tmpAdmittanceASM;
  end;
  var tmpThreadsPool:IThreadsPool;
  function localGetThreadsPool:IThreadsPool;begin
    if not assigned(tmpThreadsPool) then cnTray.Query(IThreadsPool, tmpThreadsPool);
    result:=tmpThreadsPool;
  end;
  procedure ResultStandartAdd(const _Params:Variant);begin
    if assigned(aPackCPR) then aPackCPR.Add(aCPTask, _Params, aRouteParam, aBlockID);
  end;
  function localGetBridgeCount:Integer;
    var ltmpV:Variant;
        ltmpptr:Pointer;
  begin
    ltmpV:=Unassigned;
    ltmpptr:=nil;
    Result:=0;
    repeat
      ltmpV:=localGetAdmittanceASM.GetInfoNextASMAndLock(ltmpptr);
      //Проверяю что взялось
      if VarIsEmpty(ltmpV) then Break;
      ltmpptr:=Pointer(Integer(ltmpV[5]));
      try
        if (Integer(ltmpV[4]) and msk_rsBridge)=msk_rsBridge then begin
          //Это мост
          Inc(Result);
        end;
      finally
        localGetAdmittanceASM.UnLock(ltmpptr);
      end;
    until False;
  end;
  function localGetFirstBridgeASMID:Integer;
    var ltmpV:Variant;
        ltmpptr:Pointer;
  begin
    ltmpV:=Unassigned;
    ltmpptr:=nil;
    Result:=-1;
    repeat
  //                 [0]                     [1]                            [2][0]            [2][1]                   [2][2]                [2][3]                     [2][4]             [2][5]               [2][6]  [2][7]
  //  (varInteger:(LockCount); varInteger:(0-Show 1-hide); varArray:(varInteger:(FUASNum); varOleStr(stASMUSER); ?varData(StartDateTime); ?varBoolean:(blEvent); ?varInteger:(vlASMState); varInteger:(self)));
      ltmpV:=localGetAdmittanceASM.GetInfoNextASMAndLock(ltmpptr);
      //Проверяю что взялось
      if VarIsEmpty(ltmpV) then Break;
      ltmpptr:=Pointer(Integer(ltmpV[5]));
      try
        if (Integer(ltmpV[4]) and msk_rsBridge)=msk_rsBridge then begin
          //Это мост
          Result:=Integer(ltmpV[0]);
          Break;
        end;
      finally
        localGetAdmittanceASM.UnLock(ltmpptr);
      end;
    until False;
    if Result<0 then raise exception.create('Мост не найден.');
  end;
  var tmpResult:Variant;
      tmpServerLock:IServerLock;
      tmpTaskContext:TTaskContext;
  function localGetPTaskContext:PTaskContext;begin
    tmpTaskContext:=cnDefTaskContext;
    tmpResult:=unassigned;
    tmpTaskContext.aResult:=@tmpResult;
    result:=@tmpTaskContext;
  end;
begin
  tmpV:=Unassigned;
  try
    try
      CallerAction.SenderParams:=localGetSenderParams;
      case aCPTask of
        tskADMGetAbout:begin
//Param [In]: Empty
          CheckParamsIn(-1, aParams);
          ResultStandartAdd(IServerInfo(cnTray.Query(IServerInfo)).ServerInfo(poiServerAbout));
//Param[Out]:       0                        1              2           3                         4                          5
//Param[Out]:(out stName: WideString; out vlVerMajor, vlVerMinor, vlVerRelease: SYSINT; out stDescription: WideString; out vlICO: OleVariant);
        end;
        tskADMGetSummJurnal:begin
//Param [In]: Empty
          CheckParamsIn(-1, aParams);
          ResultStandartAdd(IServerInfo(cnTray.Query(IServerInfo)).ServerInfo(poiMessageStatistic));
//Param[Out]:                               0   All 23           1 SQL 59                       2 App 60                       3 Debug 63                       4 Secur 56                         5  Info 52                      6 Error 51                    7   Warning 54             8 Saved 21          9  Max buff size 42
//Param[Out]: result:=VarArrayOf([vlStatisticMessCountAll, vlStatisticMessCountClassSQL, vlStatisticMessCountClassApp, vlStatisticMessCountClassDebug, vlStatisticMessCountClassSecurity, vlStatisticMessCountTypeInfo, vlStatisticMessCountTypeError, vlStatisticMessCountTypeWarning, vlStatisticMessSave, vlAppStabilityMessCountMax]);
        end;
        tskADMGetNewMess:begin
//Param [In]: 0-NumLastMess; 1-vlClassFilter: TxMessClass; 2-vlStyleFilter: TxMessStyle;
          CheckParamsIn(3, aParams);
          tmpLongint:=LongInt(Integer(aParams[0]));
          tmpLongint1:=tmpLongint;
          tmpV:=IAppMessage(cnTray.Query(IAppMessage)).ITGetNewMess(tmpLongint, []{aParams[1]}, []{aParams[2]});
          ResultStandartAdd(VarArrayOf([tmpV, Integer(tmpLongint), Integer(tmpLongint1)]));
          tmpV:=unassigned;
//Param[Out]: [0]              0            1        2       3         4          5                6           [1]                    [2]
//Param[Out]: VarArrayOf([stMyDateTime, stMyAddr, stUser, stSource, stMess, stMessageClass, stMessageStyle]);  [NewValue-NumLastMess] [OldValue-NumLastMess]
        end;
        tskADMGetASMServers:begin
//Param [In]: Empty
          CheckParamsIn(-1, aParams);
          localGetAdmittanceASM.ITGetASMServers(tmpV, tmpV1);
          ResultStandartAdd(VarArrayOf([tmpV, tmpV1]));
          tmpV:=unassigned;
          tmpV1:=unassigned;
//Param[Out]:                    [0]                 [0][0]       [0][1]      [0][2] [0][3]   [0][4]   [0][5]                   [1]                         [1][0]                    [1][1]         [1][2]
//Param[Out]: VarArrayOf([vlASMServers(VarArrayOf([aablThis, aaStartDateTime, aaNum, aaUser, aaState, aaLoginType]);), vlExtDataASMServers(VarArrayOf([AppStartDateTime, ComServer.ObjectCount, vlASMStartNum]);)]);
        end;
        tskADMGetServerLockStatus:begin
//Param [In]: Empty
          CheckParamsIn(-1, aParams);
          cnTray.Query(IServerLock, tmpServerLock);
          ResultStandartAdd(VarArrayOf([tmpServerLock.ITblServerLock, tmpServerLock.ITServerLockMessage, tmpServerLock.ITServerLockUser]));
//Param[Out]:                         [0]                          [1]             [2]
//Param[Out]: VarArrayOf([DataCase.ITblServerLock, DataCase.ITServerLockMessage, DataCase.ITServerLockUser]);
        end;
        tskADMServerLock:begin
//Param [In]: VarOleStr:'Message'
          CheckParamsIn(0, aParams);
          cnTray.Query(IServerLock, tmpServerLock);
          if tmpServerLock.ITblServerLock then begin
            raise exception.create(tmpServerLock.ITServerLockMessage);
          end else begin
            tmpServerLock.ITServerLock(CallerAction.UserName, AnsiString(aParams));
            CallerAction.ITMessAdd(Now, StartTime, 'CPSrv', 'Сервер заблокирован(пояснение: '''+aParams+''').', mecApp, mesWarning);
          end;
          ResultStandartAdd(True);
//Param[Out]: Empty
        end;
        tskADMServerUnlock:begin
//Param [In]: Empty
          CheckParamsIn( -1, aParams);
          cnTray.Query(IServerLock, tmpServerLock);
          if tmpServerLock.ITblServerLock then begin
            tmpServerLock.ITServerUnLock;
            CallerAction.ITMessAdd(Now, StartTime, 'CPSrv', 'Сервер разблокирован.', mecApp, mesWarning);
          end else begin
            raise exception.create('Сервер уже разблокирован.');
          end;
          ResultStandartAdd(True);
//Param [out]: Empty
        end;
        tskADMStopASMOnID:begin
//Param [In]: int
          CheckParamsIn(0, aParams);
          localGetThreadsPool.ITMTaskAdd(tskMTStopASMOnID, aParams, CallerAction);
          ResultStandartAdd(True);
//Param[out]: int
        end;
        tskADMStopASMOnUser:begin
//Param [In]: OleStr
          CheckParamsIn(0, aParams);
          localGetThreadsPool.ITMTaskAdd(tskMTStopASMOnUser, aParams, CallerAction);
          ResultStandartAdd(True);
//Param[out]: int
        end;
        tskADMStopASMAll:begin
//Param [In]: Empty
          CheckParamsIn(-1, aParams);
          localGetThreadsPool.ITMTaskAdd(tskMTStopAllASM, Unassigned, CallerAction);
          ResultStandartAdd(True);
//Param[out]: int
        end;
        tskADMSendMessToId:begin
//Param [In]: [0]-(ASM Id); [1]-([0]-varString(From) [1]-varString(Mess));
          CheckParamsIn(2, aParams);
          CheckParamsIn(2, aParams[1]);
          CallerAction.SenderParams:=unassigned;
          localGetThreadsPool.ITMTaskAdd(tskMTSendMessToId, aParams, CallerAction);
          ResultStandartAdd(True);
//Param[out]: Empty
        end;
        tskADMSendMessToUser:begin
//Param [In]: [0]-varInteger(UserName) [1]-varArray([0]-varInteger(ASMSenderNum); [1]-varString(From) [2]-varString(Mess))
          CheckParamsIn(3, aParams);
          CallerAction.SenderParams:=unassigned;
          localGetThreadsPool.ITMTaskAdd(tskMTSendMessToUser, aParams, CallerAction);
          ResultStandartAdd(True);
//Param[out]: Empty
        end;
        tskADMSendMessToAll:begin
//Param [In]: [0]-varInteger(From) [1]-varString(Mess)
          CheckParamsIn(2, aParams);
          CallerAction.SenderParams:=unassigned;
          localGetThreadsPool.ITMTaskAdd(tskMTSendMessToAll, aParams, CallerAction);
          ResultStandartAdd(True);
//Param[out]: Empty
        end;
        tskADMCodeOfMateTeam:begin
//Param [In]: Empty
          CheckParamsIn(-1, aParams);
          ResultStandartAdd(VarArrayOf([localGetThreadsPool.ITMArray, localGetThreadsPool.ITMTaskIgnore,
                                         localGetThreadsPool.ITMTask, localGetThreadsPool.ITMSleepTask, Unassigned]));
//Param[out]: Great CodeOfMTeam array of varriant.
        end;
        tskADMShotDownServer:begin
//Param [In]: [0]-varint:iTimeOut(ms); [1]-varboolean:True/False(рассылать всем сообщения или нет)
          CheckParamsIn(2, aParams);
          CheckParamsIn(3, aParams[0]);
          //vlAbortOnExit:=Boolean(aParams[1]);
          CallerAction.SenderParams:=unassigned;
          localGetThreadsPool.ITMTaskAdd(tskMTShotDownServer, aParams[0], CallerAction);
          ResultStandartAdd(True);
//Param[out]: Empty
        end;
        tskADMCancelTask:begin
//Param [In]: [0]-varint:(TaskID);
          CheckParamsIn(0, aParams);
          ResultStandartAdd(localGetThreadsPool.ITMTaskCancel(aParams));
//Param[out]: varBoolean
        end;
        tskADMIgnoreTaskAdd:begin
//Param [In]: [0]-varint:(TaskID);
          CheckParamsIn(0, aParams);
          localGetThreadsPool.ITMIgnoreTaskAdd(aParams);
          ResultStandartAdd(True);
//Param[out]: Empty
        end;
        tskADMIgnoreTaskCancel:begin
//Param [In]: [0]-varint:(TaskID);
          CheckParamsIn(0, aParams);
          ResultStandartAdd(localGetThreadsPool.ITMIgnoreTaskCancel(aParams));
//Param[out]: Boolean
        end;
        tskADMPack:begin
//Param [In]: varVariant(Data(Protocol_PD));
          CallerAction.SenderParams:=unassigned;
          localGetThreadsPool.ITMTaskAdd(tskMTPD, aParams, CallerAction);
          ResultStandartAdd(True);
//Param[out]: Empty
        end;
        tskADMBlockSQL:begin
        //Param[in]: [0]-varInteger:(tmpBlockId); [1]-varArray:(tmpBlock:[0..n]-varOleStr:(SQLCommand)); [2]-varVariant:(WakeUp-[0]-varInteger:(Low);[1]-varInteger:(High))
        tmpBlockSQLExec:=TBlockSQLExec.Create;
        try
          tmpBlockSQLExec.Data:=aParams;
          tmpBlockSQLExec.CallerAction:=CallerAction;
          tmpBlockSQLExec.Exec;
          if tmpBlockSQLExec.BuildResult then begin//Есть результат выполнения
            ResultStandartAdd(tmpBlockSQLExec.Result);
          end;
          if tmpBlockSQLExec.NextTimeRequire then begin//Остались команды с более позднем временем выполнения//Ставлю на повторное выполнение
            localGetThreadsPool.ITMWakeUpTaskAdd(tskMTBlockSQLExec, MSecsToDateTime(tmpBlockSQLExec.NextTimeData), CallerAction, tmpBlockSQLExec.NextTimeWakeup);
          end;
        finally
          tmpBlockSQLExec.free;
        end;
//Param[out]: Empty
        end;
        tskADMReloadSecurity:begin
//Param [In]:Empty
          CheckParamsIn(-1, aParams);
          localGetThreadsPool.ITMTaskAdd(tskMTReloadSecurity, unassigned, CallerAction);
          ResultStandartAdd(True);
//Param[out]:Empty
        end;
        {tskADMReloadInternalConfig:begin
//Param [In]:Empty
          CheckParamsIn(-1, aParams);
          localGetThreadsPool.ITMTaskAdd(tskMTInternalConfig, unassigned, CallerAction);
          ResultStandartAdd(True);
//Param[out]:Empty
        end;}
        tskADMSetLockList:begin
//Param [In]:[0]-varString(stTab) [1]-varString(stUser) [2]-varInteger(vlASMNum)
          CheckParamsIn(3, aParams);
          ResultStandartAdd(Boolean(ISync(cnTray.Query(ISync)).ITSetLockList(aParams[0], TCallerAction.CreateNewAction(VarArrayOf([VarToStr(aParams[1])])){aParams[1]}, aParams[2], False, True)));
//Param [Out]:[0]-varBoolean(Success)
        end;
        tskADMGetLockList:begin
//Param [In]:Empty
          CheckParamsIn(-1, aParams);
          ResultStandartAdd(ISync(cnTray.Query(ISync)).ITGetLockList);
//Param [Out]: Variant
        end;
        tskADMClearLockOwner:begin
//Param [In]:varInteger(aASMNum)
          CheckParamsIn(0, aParams);
          ISync(cnTray.Query(ISync)).ITClearLockOwner(aParams);
          ResultStandartAdd(Unassigned);
//Param[out]:Empty
        end;
        tskADMAddToClientQueue:begin//Only for EMServer//For shop sale-working..
// In: [0]-varString:(ClientQueueId); [1]-varString:(Sender); [2]-varArray:(ClintData); [3]-varDataTime:(WakeUp)
{$Ifdef PegasServer}
          raise exception.Create('Команда не применима для PegasServer.');
{$ELSE}
          CheckParamsIn(3, aParams);
          tmpLocalDataBase:=TLocalDataBase.Create;
          try
            tmpLocalDataBase.CallerAction:=cnServerAction;
            ResultStandartAdd(IStrQueue(cnTray.Query(IStrQueue)).QueuePush(tmpLocalDataBase, qidClientQueue, aParams[0]{ClientQueueId}, aParams[1]{Sender}, glVarArrayToString(aParams[2]), ''{Commentary}, CallerAction.SenderParams{aSenderParams}, CallerAction.SecurityContext, aParams[3]{WakeUp}));
          finally
            tmpLocalDataBase:=nil;
         end;
{$endif}
        end;
        tskADMExecServerProc:begin
          localGetThreadsPool.ITMTaskAdd(tskMTExecServerProc, aParams, CallerAction);
          ResultStandartAdd(True);
        end;
        tskADMRunServerProc:begin
// In MyParams: [0]-varInteger:(Circle interval); [1]-varVariant:(ServerProcName);
{-$Ifdef PegasServer}
          raise exception.CreateFmtHelp(cserInternalError, ['tskADMRunServerProc убрал, т.к. решил что она не нужна.'], cnerInternalError);
{-$ELSE}
          //??CheckParamsIn(2, aParams);
          //??localGetThreadsPool.ITMTaskAdd(tskMTRunServerProc, aParams, CallerAction);
          //??ResultStandartAdd(True);
{-$endif}
        end;
        tskADMCPT:begin //:TADMTask=84;
// In MyParams: [0]-varVariant:(CPT);
          localGetThreadsPool.ITMTaskAdd(tskMTCPT, aParams, CallerAction);
          ResultStandartAdd(True);
        end;
        tskADMCPR:begin //:TADMTask=85;
// In MyParams: [0]-varVariant:(CPR);
          localGetThreadsPool.ITMTaskAdd(tskMTCPR, aParams, CallerAction);
          ResultStandartAdd(True);
        end;
        tskADMPD:begin //:TADMTask=86;
// In MyParams: [0]-varVariant:(PD);
          localGetThreadsPool.ITMTaskAdd(tskMTPD, aParams, CallerAction);
          ResultStandartAdd(True);
        end;
        tskADMExecMT:begin
          CheckParamsIn(2, aParams);
          localGetThreadsPool.ITMTaskAdd(aParams[0], aParams[1], CallerAction);
          ResultStandartAdd(True);
        end;
        tskADMGetOnlineStatus:begin
// In MyParams: Empty
{$Ifdef EAMServer}
          CheckParamsIn(-1, aParams);
          ResultStandartAdd(IServerOnline(cnTray.Query(IServerOnline)).ITOnLineStatus);
{$Else}
  {$Ifdef PegasServer}
          raise exception.CreateFmtHelp(cserInapplicableCommandForPegasServer, [glADMTaskToStr(aCPTask)], cnerInapplicableCommandForPegasServer);
  {$else}
          Неизвестная деректива
  {$endif}
{$Endif}          
        end;
        tskADMGetOnlineMode:begin
// In MyParams: Empty
{$Ifdef EAMServer}
          CheckParamsIn(-1, aParams);
          ResultStandartAdd(IServerOnline(cnTray.Query(IServerOnline)).ITOnLineMode{0-Auto check; 1-Manual set});
{$Else}
  {$Ifdef PegasServer}
          raise exception.CreateFmtHelp(cserInapplicableCommandForPegasServer, [glADMTaskToStr(aCPTask)], cnerInapplicableCommandForPegasServer);
  {$else}
          Неизвестная деректива
  {$endif}
{$Endif}
        end;
        tskADMSetOnlineMode:begin
// In MyParams: Integer:(OnlineMode)
{$Ifdef EAMServer}
          CheckParamsIn(0, aParams);
          IServerOnline(cnTray.Query(IServerOnline)).ITOnlineMode:=aParams;
          CallerAction.ITMessAdd(Now, StartTime, 'CPSrv', 'SetOnlineMode to '''+VarToStr(aParams)+'''.', mecApp, mesWarning);
          ResultStandartAdd(True);
{$Else}
  {$Ifdef PegasServer}
          raise exception.CreateFmtHelp(cserInapplicableCommandForPegasServer, [glADMTaskToStr(aCPTask)], cnerInapplicableCommandForPegasServer);
  {$else}
          Неизвестная деректива
  {$endif}
{$Endif}
        end;
        tskADMSetOnline:begin
//Param [In]:Empty
{$Ifdef EAMServer}
          CheckParamsIn( -1, aParams);
          IServerOnline(cnTray.Query(IServerOnline)).ITSetOnLineStatus(True, CallerAction);
          CallerAction.ITMessAdd(Now, StartTime, 'CPSrv', 'SetOnlineStatus to ''ONLINE''.', mecApp, mesWarning);
          ResultStandartAdd(True);
{$Else}
  {$Ifdef PegasServer}
          raise exception.CreateFmtHelp(cserInapplicableCommandForPegasServer, [glADMTaskToStr(aCPTask)], cnerInapplicableCommandForPegasServer);
  {$else}
          Неизвестная деректива
  {$endif}
{$Endif}
//Param[out]:Empty
        end;
        tskADMSetOffline:begin
//Param [In]:Empty
{$Ifdef EAMServer}
          CheckParamsIn( -1, aParams);
          IServerOnline(cnTray.Query(IServerOnline)).ITSetOnLineStatus(False, CallerAction);
          CallerAction.ITMessAdd(Now, StartTime, 'CPSrv', 'SetOnlineStatus to ''OFFLINE''.', mecApp, mesWarning);
          ResultStandartAdd(True);
{$else}
  {$Ifdef PegasServer}
          raise exception.CreateFmtHelp(cserInapplicableCommandForPegasServer, [glADMTaskToStr(aCPTask)], cnerInapplicableCommandForPegasServer);
  {$else}
          Неизвестная деректива
  {$endif}
{$Endif}
//Param[out]:Empty
        end;
        tskADMGetBridgeCount:begin
//Param [In]:Empty
          CheckParamsIn( -1, aParams);
          ResultStandartAdd(localGetBridgeCount);
          //raise exception.Create('localGetBridgeCount не переведен на Tray');
//Param[out]:Empty
        end;
        tskADMCreateBridge:begin
//Param [In]:Empty
          CheckParamsIn( -1, aParams);
          localGetThreadsPool.ITMTaskAdd(tskMTCreateBridge, unassigned, CallerAction);
          ResultStandartAdd(True);
//Param[out]:Empty
        end;
        tskADMDeleteBridge:begin
//Param [In]: Integer:(ASMNum)
          CheckParamsIn( 0, aParams);
          if aParams<0 then localGetThreadsPool.ITMTaskAdd(tskMTStopASMOnID, localGetFirstBridgeASMID, CallerAction) else
            localGetThreadsPool.ITMTaskAdd(tskMTStopASMOnID, aParams, CallerAction);
          ResultStandartAdd(True);
//Param[out]:Empty
        end;
        {tskADMBfCheckActuality:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfCheckActuality, aParams, localGetPTaskContext);
        tskADMBfBeginDownload:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfBeginDownload, aParams, localGetPTaskContext);
        tskADMBfDownload:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfDownload, aParams, localGetPTaskContext);
        tskADMBfEndDownload:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfEndDownload, aParams, localGetPTaskContext);
        tskADMBfBeginUpload:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfBeginUpload, aParams, localGetPTaskContext);
        tskADMBfUpload:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfUpload, aParams, localGetPTaskContext);
        tskADMBfEndUpload:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfEndUpload, aParams, localGetPTaskContext);
        tskADMBfTransferCancel:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfTransferCancel, aParams, localGetPTaskContext);
        tskADMBfTransferTerminate:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfTransferTerminate, aParams, localGetPTaskContext);
        tskADMBfAddTransferDownload:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfAddTransferDownload, aParams, localGetPTaskContext);
        tskADMBfExists:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfExists, aParams, localGetPTaskContext);
        tskADMBfLocalDelete:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfLocalDelete, aParams, localGetPTaskContext);
        tskADMBfTransferTerminateByBfName:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfTransferTerminateByBfName, aParams, localGetPTaskContext);}
        tskADMEQueryInterface:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTEQueryInterface, aParams, localGetPTaskContext);
        tskADMEQueryInterfaceByLevel:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTEQueryInterfaceByLevel, aParams, localGetPTaskContext);
        tskADMEQueryInterfaceByNodeName:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTEQueryInterfaceByNodeName, aParams, localGetPTaskContext);
      else
        raise exception.create('Неизвестная команда('+glADMTaskToStr(aCPTask)+'/'+IntToStr(Integer(aCPTask))+').');
      end;
      if tmpTaskContext.aSetResult then begin
        ResultStandartAdd(tmpTaskContext.aResult^);//устанавливаю результат после Bf-операций.
      end;
      VarClear(tmpResult);//не обязательно
    except
      raise;
    end;
  finally
    VarClear(tmpV);
  end;
end;

procedure TCommandPackServer.CheckSecurityPTask(aTask:TADMTask; aProtocolType:TProtocolType; const aSecurityContext:Variant);
begin
  if aTask<>tskADMNone then IAppSecurity(cnTray.Query(IAppSecurity)).ITCheckSecurityPTask(aTask, aSecurityContext);
end;

procedure TCommandPackServer.ReceiveCPR1(const aPDID:Variant; const aCPID:Variant; aBlockID:Integer; aCPTask:TADMTask; aPos:Integer; const aParams:Variant; const aRouteParam:Variant);
  function localGetSenderParams:Variant;
  begin
    if VarIsEmpty(aRouteParam) then Result:=VarArrayOf([-1{rstSTNoASM}, CPID, InternalGetReverceRoute, aCPTask]) else Result:=VarArrayOf([-1{rstSTNoASM}, CPID, InternalGetReverceRoute, aCPTask, aRouteParam]);
  end;
  procedure CheckParamsIn(vlParamsCount:Integer; const _V:OleVariant);
    var _iSize : Integer;
    begin
{1..n}if (VarType(_V) and VarArray) = varArray then _iSize:=VarArrayHighBound(_V,1)-VarArrayLowBound(_V,1)+1 else
{-1}    if (VarType(_V)=varNull) Or (VarType(_V)=varEmpty) then _iSize:=-1 else
{0}       _iSize:=0;
      if vlParamsCount<>_iSize then raise exception.create('не верное количество параметров(ожидается='+IntToStr(vlParamsCount)+', пришло='+IntToStr(_iSize)+').');
    end;
begin
  try
    try
      CallerAction.SenderParams:=localGetSenderParams;
      case aCPTask of
          tskADMGetAbout:begin
//Param[In]:       0                        1              2           3                         4                          5
//Param[In]:(out stName: WideString; out vlVerMajor, vlVerMinor, vlVerRelease: SYSINT; out stDescription: WideString; out vlICO: OleVariant);
          end;
          tskADMGetSummJurnal:begin
//Param[In]:                               0   All 23           1 SQL 59                       2 App 60                       3 Debug 63                       4 Secur 56                         5  Info 52                      6 Error 51                    7   Warning 54             8 Saved 21          9  Max buff size 42
//Param[In]: result:=VarArrayOf([vlStatisticMessCountAll, vlStatisticMessCountClassSQL, vlStatisticMessCountClassApp, vlStatisticMessCountClassDebug, vlStatisticMessCountClassSecurity, vlStatisticMessCountTypeInfo, vlStatisticMessCountTypeError, vlStatisticMessCountTypeWarning, vlStatisticMessSave, vlAppStabilityMessCountMax]);
          end;
          tskADMGetNewMess:begin
//Param[In]: [0]              0            1        2       3         4          5                6         [1]
//Param[In]: VarArrayOf([stMyDateTime, stMyAddr, stUser, stSource, stMess, stMessageClass, stMessageStyle]);  [NumLastMess]
          end;
          tskADMGetASMServers:begin
//Param[In]:                    [0]                 [0][0]       [0][1]      [0][2] [0][3]   [0][4]   [0][5]                   [1]                         [1][0]                    [1][1]         [1][2]
//Param[In]: VarArrayOf([vlASMServers(VarArrayOf([aablThis, aaStartDateTime, aaNum, aaUser, aaState, aaLoginType]);), vlExtDataASMServers(VarArrayOf([AppStartDateTime, ComServer.ObjectCount, vlASMStartNum]);)]);
          end;
          tskADMGetServerLockStatus:begin
//Param[In]:                         [0]                          [1]
//Param[In]: VarArrayOf([DataCase.ITblServerLock, DataCase.ITServerLockMessage]);
          end;
          tskADMServerLock:begin
//Param[In]: Empty
          end;
          tskADMServerUnlock:begin
//Param [In]: Empty
          end;
          tskADMStopASMOnID:begin
//Param[In]: int
          end;
          tskADMStopASMOnUser:begin
//Param[In]: int
          end;
          tskADMStopASMAll:begin
//Param[In]: int
          end;
          tskADMSendMessToId:begin
//Param[In]: int
          end;
          tskADMSendMessToUser:begin
//Param[In]: int
          end;
          tskADMSendMessToAll:begin
//Param[In]: int
          end;
          tskADMCodeOfMateTeam:begin
//Param[In]: Great CodeOfMTeam array of varriant.
          end;
          tskADMShotDownServer:begin
//Param[In]: Empty
          end;
          tskADMCancelTask:begin
//Param[In]: varBoolean
          end;
          tskADMIgnoreTaskAdd:begin
//Param[In]: Empty
          end;
          tskADMIgnoreTaskCancel:begin
//Param[In]: Empty
          end;
          tskADMPack:begin
//Param[in]: Empty
          end;
          tskADMBlockSQL:begin
//Param[in]: Empty
          end;
          tskADMSetLockList:begin
          end;
          tskADMGetLockList:begin
          end;
          tskADMClearLockOwner:begin
          end;
          tskADMExecServerProc:begin  
          end;
          //tskADMBfBeginDownload:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfReceiveBeginDownload, VarArrayOf([aPDID, aParams]), nil);
          //tskADMBfDownload:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfReceiveDownload, VarArrayOf([aPDID, aParams]), nil);
          //tskADMBfBeginUpload:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfReceiveBeginUpload, VarArrayOf([aPDID, aParams]), nil);
          //tskADMBfUpload:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfReceiveUpload, VarArrayOf([aPDID, aParams]), nil);
          //tskADMBfEndUpload:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfReceiveEndUpload, VarArrayOf([aPDID, aParams]), nil);
          //tskADMBfTransferCanceled:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfReceiveTransferCanceled, VarArrayOf([aPDID, aParams]), nil);
          //tskADMBfTransferTerminated:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfReceiveTransferTerminated, VarArrayOf([aPDID, aParams]), nil);
          //tskADMBfAddTransferDownload, tskADMBfExists, tskADMBfTransferCancel, tskADMBfLocalDelete, tskADMBfTransferTerminateByBfName, tskADMBfTransferTerminate:;
          tskADMEQueryInterface, tskADMEQueryInterfaceByLevel, tskADMEQueryInterfaceByNodeName:;
      else
        raise exception.create('Неизвестная команда('+glADMTaskToStr(aCPTask)+'/'+IntToStr(Integer(aCPTask))+').');
      end;
    except
      raise;
    end;
  finally
    //..
  end;
end;

procedure TCommandPackServer.ReceiveCPR1Error(const aPDID:Variant; const aCPID:Variant; aBlockID:Integer; aCPTask:TADMTask; aPos:Integer; const aMessage:AnsiString; aHelpContext:Integer; aResultWithError:Boolean; const aRouteParam:Variant);
  function localGetSenderParams:Variant;begin
    if VarIsEmpty(aRouteParam) then Result:=VarArrayOf([-1{rstSTNoASM}, CPID, InternalGetReverceRoute, aCPTask]) else Result:=VarArrayOf([-1{rstSTNoASM}, CPID, InternalGetReverceRoute, aCPTask, aRouteParam]);
  end;
  procedure localErrorMess;begin
    CallerAction.ITMessAdd(Now, StartTime, 'CPSrv', 'CopralResultPack: (step='+IntToStr(aPos+1)+' of '+IntToStr(ivHB-ivLB+1)+'): '+aMessage, mecApp, mesError);
  end;
begin
  if not aResultWithError then localErrorMess else begin
    CallerAction.SenderParams:=localGetSenderParams;
    (*case aCPTask of
      tskADMBfBeginDownload{89}:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfReceiveErrorBeginDownload, CPRErrorToVariant(aPDID, aMessage, aHelpContext), nil);
      tskADMBfDownload{90}:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfReceiveErrorDownload, CPRErrorToVariant(aPDID, aMessage, aHelpContext), nil);
      tskADMBfBeginUpload{92}:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfReceiveErrorBeginUpload, CPRErrorToVariant(aPDID, aMessage, aHelpContext), nil);
      tskADMBfUpload{93}:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfReceiveErrorUpload, CPRErrorToVariant(aPDID, aMessage, aHelpContext), nil);
      tskADMBfEndUpload{94}:ITaskImplement(cnTray.Query(ITaskImplement)).TasksImplements(CallerAction, tskMTBfReceiveErrorEndUpload, CPRErrorToVariant(aPDID, aMessage, aHelpContext), nil);
    else(**)
      localErrorMess;
    (*end;(**)
  end;
end;

end.
