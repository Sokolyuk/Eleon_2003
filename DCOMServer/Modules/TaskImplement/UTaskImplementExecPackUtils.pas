//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTaskImplementExecPackUtils;

interface
  uses UTTaskTypes, UCallerTypes, UTaskImplementTypes;

  function TaskImplementExecPack(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;

implementation
  uses UEPointPropertiesTypes, UTrayConsts, Sysutils, UErrorConsts, UAppMessageTypes, Variants, UTTaskUtils,
       UThreadsPoolTypes, UStrQueueTypes, ULocalDataBase, ULocalDataBaseTypes, UServerInfoTypes, UTypeUtils,
       UDateTimeUtils, ULogFileTypes, UPDServer, UMThreadUtils, UServerActionConsts, UPackPDTypes
{$IFDEF PegasServer}
       , UCPRHandlerServerPegas
{$ELSE}
       , UCPRHandlerEMServer
{$ENDIF}
       ;
function TaskImplementExecPack(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;
  var tmpStrQueue:IStrQueue;
  function localGetStrQueue:IStrQueue;begin
    if not assigned(tmpStrQueue) then cnTray.Query(IStrQueue, tmpStrQueue);
    result:=tmpStrQueue;
  end;
  var tmpThreadsPool:IThreadsPool;
  function localGetThreadsPool:IThreadsPool;begin
    if not assigned(tmpThreadsPool) then cnTray.Query(IThreadsPool, tmpThreadsPool);
    result:=tmpThreadsPool;
  end;
  var tmpAppMessage:IAppMessage;
  function localGetAppMessage:IAppMessage;begin
    if not assigned(tmpAppMessage) then cnTray.Query(IAppMessage, tmpAppMessage);
    result:=tmpAppMessage;
  end;
  var tmpLocalDataBase:ILocalDataBase;
      tmpSecurityContext, tmpV, tmpSenderParams:Variant;
      tmpSt1, tmpSt2, tmpSt3:AnsiString;
      tmpStartTime:TDateTime;
      tmpPD:TPDServer;
{$IFDEF PegasServer}
      tmpCPRHandlerServerPegas:TCPRHandlerServerPegas;
{$ELSE}
      tmpCPRHandlerEMServer:TCPRHandlerEMServer;
{$ENDIF}
      tmpIUnknown:IUnknown;
      tmpIPackPD:IPackPD;
begin
  result:=true;
  tmpStartTime:=now;
  case aTask of
    tskMTCPT:begin
      Raise Exception.Create('!!');//Out Res: Empty
    end;
    tskMTCPR:begin
      Raise Exception.Create('!!');//Out Res: Empty
    end;
    tskMTRePD:begin//In MyParams: varInteger:(Circle interval);
      try
        tmpLocalDataBase:=TLocalDataBase.Create;
        try
          tmpLocalDataBase.CallerAction:=cnServerAction;
          tmpLocalDataBase.LockListTimeOut:=15000{15sec}; {¬рем€ в течение которого пытаетс€ захватить лок дл€ удалении из очереди.}
          While True do begin
            If MThreadBreak{Terminated} Then Break; //т.к. могут быть большие списки
            If localGetStrQueue.QueuePop(tmpLocalDataBase, qidRePD{aQueueId}, tmpSt1{aClientQueueId}, tmpSt2{aSender}, tmpSt3{aStrData}, tmpSenderParams{aSenderParams}, tmpSecurityContext{aSecurityContext})=False then begin
              Break;//ќчередь кончалась или в ней ни чего не было
            end;
            try//»з очереди вз€лс€ PD.//ѕараметры ClientQueueId и aSender неиспользуютс€
              tmpV:=glStringToVarArray(tmpSt3);
              try//ѕробую отправить еще раз
                localGetThreadsPool.ITMTaskAdd(tskMTPD, tmpV, tmpSenderParams, tmpSecurityContext);
              except
                sleep(500);//ќригинальное решение
                localGetThreadsPool.ITMTaskAdd(tskMTPD, tmpV, tmpSenderParams, tmpSecurityContext);
              end;
              localGetAppMessage.ITMessAdd(tmpStartTime, now, aCallerAction.UserName, 'ExecPackImpl', 'tskMTRePD(aClientQueueId='''+tmpSt1+''', aSender='''+tmpSt2+'''): Ok.', mecApp, mesInformation);
            except
              on e:exception do begin
                try
                  tmpLocalDataBase.LockListTimeOut:=240000{4min}; {¬рем€ в течение которого пытаетс€ захватить лок при, удалении из очереди.}
                  try                                                                                                                                                                                                                             {TimeStampToDateTime(MSecsToTimeStamp(}
                    localGetStrQueue.QueuePush(tmpLocalDataBase, qidRePD{aQueueId}, tmpSt1{aClientQueueId}, tmpSt2{aSender}, tmpSt3{aStrData}, 'tskMTRePD: ITMTaskAdd: '+E.Message{Commentary}, tmpSenderParams{aSenderParams}, tmpSecurityContext{aSecurityContext}, MSecsToDateTime(180000+DateTimeToMSecs(Now)){WakeUp});
                    localGetAppMessage.ITMessAdd(tmpStartTime, now, aCallerAction.UserName, 'ExecPackImpl', 'tskMTRePD(aClientQueueId='''+tmpSt1+''', aSender='''+tmpSt2+'''): '''+E.Message+'''/HC='+IntToStr(e.HelpContext)+' >> PUSH.', mecApp, mesWarning);
                  finally
                    tmpLocalDataBase.LockListTimeOut:=15000{15sec}; {¬рем€ в течение которого пытаетс€ захватить лок дл€ удалении из очереди.}
                  end;
                except
                  on e:exception do begin
                    ILogFile(cnTray.Query(ILogFile)).ITWriteLnToLog(#13#10'ERROR: tskMTRePD: Except in except(ITMTaskAdd, ѕакет потер€н): '''+E.Message+'''/HC='+IntToStr(e.HelpContext)+'.');
                    Raise Exception.Create('tskMTRePD: Except in except(ITMTaskAdd, ѕакет потер€н): '''+E.Message+'''/HC='+IntToStr(e.HelpContext)+'.');
                  end;
                end;
              end;
            end;
          end;
        finally
          tmpLocalDataBase:=Nil;
        end;
      finally//—тавлю на повторное выполнение
        If VarType(aParams)=varInteger Then localGetThreadsPool.ITMSleepTaskAdd(tskMTRePD, aParams, aCallerAction, Integer(aParams), aTaskContext^.aTaskID, @aTaskContext^.aTaskID);
      end;//Out Res:Empty
    end;
    tskMTPDConnectionName:begin
      tmpIUnknown:=aParams[1];//aParams[0]-дл€ сервера игнорируетс€
      if (not assigned(tmpIUnknown))or(tmpIUnknown.QueryInterface(IPackPD, tmpIPackPD)<>S_OK)or(not assigned(tmpIPackPD)) then raise exception.createFmtHelp(cserInternalError, ['IPackPD no found'], cnerInternalError);
      result:=TaskImplementExecPack(aCallerAction, tskMTPD, tmpIPackPD.AsVariant, aTaskContext, aRaise);
    end;
    tskMTPD:begin//In aParams: varVariant(Data(Protocol_PD));
      tmpPD:=TPDServer.Create;
      try
        tmpPD.Data:=aParams;
        tmpPD.CallerAction:=aCallerAction{!?!?-“еоритически, если суда придет пакет с CPT, то в некоторых случа€х может изменитьс€ SenderParams};
        //tmpPD.SenderParams:=aCallerAction.SenderParams;
        tmpPD.TitlePoint:=IEPointProperties(cnTray.Query(IEPointProperties)).TitlePoint;
{$IFDEF PegasServer}
        tmpCPRHandlerServerPegas:=TCPRHandlerServerPegas.Create;
        try
          tmpCPRHandlerServerPegas.CallerAction:=aCallerAction;
          tmpPD.OnReceiveCPR1:=tmpCPRHandlerServerPegas.ReceiveCPR1;
          tmpPD.OnReceiveCPR1Error:=tmpCPRHandlerServerPegas.ReceiveCPR1Error;
          tmpPD.OnTransportError:=tmpCPRHandlerServerPegas.TransportError;
          tmpPD.Hop;
        finally
          FreeAndNil(tmpCPRHandlerServerPegas);
        end;
{$ELSE}
        tmpCPRHandlerEMServer:=TCPRHandlerEMServer.Create;
        try
          tmpPD.OnReceiveCPR1:=tmpCPRHandlerEMServer.ReceiveCPR1;
          tmpPD.OnReceiveCPR1Error:=tmpCPRHandlerEMServer.ReceiveCPR1Error;
          tmpPD.OnTransportError:=tmpCPRHandlerEMServer.TransportError;
          tmpPD.Hop;
        finally
          FreeAndNil(tmpCPRHandlerEMServer);
        end;
{$ENDIF}
        if (tmpPD.BuildResult)And(Not VarIsEmpty(tmpPD.Result)) Then begin
          If assigned(aTaskContext) then begin
            if assigned(aTaskContext^.aResult) then aTaskContext^.aResult^:=tmpPD.Result;
            aTaskContext^.aPackToCPR:=false;
            aTaskContext^.aSetResult:=true;
            aTaskContext^.aManualResultSet:=false;//разрешаю автоматическую отработку SetComplete
          end;
        end;
      Finally
        FreeAndNil(tmpPD);
      end;
    end;//Out Res: Empty
  else
    if aRaise then raise exception.createFmtHelp(cserInternalError, ['Unsupported for '+MTaskToStr(aTask)], cnerInternalError) else result:=false;
  end;
end;

end.
