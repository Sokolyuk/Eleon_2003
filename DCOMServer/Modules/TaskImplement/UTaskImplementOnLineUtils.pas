//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTaskImplementOnLineUtils;
{$Ifndef PegasServer}{$Ifndef EAMServer}
  Этот модуль изначально серверный
{$endif}{$endif}
interface
  uses UTTaskTypes, UCallerTypes, UTaskImplementTypes;

  function TaskImplementOnLine(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;

implementation
  uses UTrayConsts, Sysutils, UErrorConsts, Variants, UTTaskUtils, UThreadsPoolTypes
       {$Ifdef EAMServer}, UServerOnlineTypes, Pegas_TLB, Comobj, UEventSink, UDateTimeUtils, UAdmittanceASMTypes,
       UAS, UASMTypes, UASMUtilsConsts, UAppMessageTypes, UServerConsts, UASMUtils{$endif}, EMServer_TLB;
const cnPingTime:Cardinal=90000;//1min 40sec//120000;{2min; 1min-для ПМ маловато}

function TaskImplementOnLine(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;
{$IFDEF EAMServer}
  var tmpServerOnline:IServerOnline;
  function localGetIServerOnline:IServerOnline;begin
    if not assigned(tmpServerOnline) then cnTray.Query(IServerOnline, tmpServerOnline);
    result:=tmpServerOnline;
  end;
  var tmpThreadsPool:IThreadsPool;
  function localGetIThreadsPool:IThreadsPool;begin
    if not assigned(tmpThreadsPool) then cnTray.Query(IThreadsPool, tmpThreadsPool);
    result:=tmpThreadsPool;
  end;
  var tmpAdmittanceASM:IAdmittanceASM;
  function localGetIAdmittanceASM:IAdmittanceASM;begin
    if not assigned(tmpAdmittanceASM) then cnTray.Query(IAdmittanceASM, tmpAdmittanceASM);
    result:=tmpAdmittanceASM;
  end;
  function localGetTaskID:Integer;begin
    if assigned(aTaskContext) then result:=aTaskContext^.aTaskID else result:=-1;
  end;
  var {$Warnings off}tmpCnn:IAUPegasDisp;{$Warnings on}
      tmpEventSink:IEventSink;
      tmpStart:TDateTime;
      tmpCookie:Longint;
      tmpV:variant;
      tmpPtr:TEAMServer;
      tmpI, tmpPingTime:Integer;
      tmpASMState:TASMState;
{$endif}
begin
  result:=true;
  case aTask of
    tskMTOnLineCheck:begin//In aParams: VarInteger:Interval
{$IFDEF PegasServer}
      raise exception.createFmtHelp(cserInapplicableCommandForPegasServer, [MTaskToStr(aTask)], cnerInapplicableCommandForPegasServer);
{$ELSE}
      try
        if (VarIsArray(aParams))and(VarArrayHighBound(aParams, 1)>=2) then begin
          tmpPingTime:=aParams[1];
        end else begin
          tmpPingTime:=cnPingTime;
        end;
        if localGetIServerOnline.ITOnLineMode=olmAuto then begin
          //try//Проверяю связь. Попытка №1.
          //  tmpStart:=now;
          //  {$Warnings off}tmpcnn:=IAUPegasDisp(CreateRemoteComObject(cnEComputerName, StringToGUID(cnEComputerGUID)) as IDispatch);{$Warnings on}
          //  try
          //    tmpEventSink:=TEventSink.Create;
          //    try
          //      if cnIsEMSClient then begin
//{$Warnings off}   tmpEventSink.IIDEvents:=IEAMServerEvents;
          //      end else begin
//{$Warnings off}   tmpEventSink.IIDEvents:=IAUPegasEvents;
          //      end;
          //      tmpEventSink.OnInvoke:=nil;
          //      tmpEventSink.InterfaceConnectEx(tmpcnn, tmpEventSink, tmpCookie);
//{$Warnings on}  try{Ok}finally
//{$Warnings off}   tmpEventSink.InterfaceDisconnectEx(tmpcnn, tmpCookie);{$Warnings on}
          //      end;
          //    finally
          //      tmpEventSink:=nil;
          //    end;
          //  finally
          //    tmpcnn:=nil;
          //  end;
          //  if MSecsBetweenDateTime(tmpStart, now)>tmpPingTime then raise exception.create(TwoDateTimeToDurationStr(tmpStart, now)+'>'+MSecsToDurationStr(tmpPingTime));
          //  localGetIServerOnline.ITSetOnLineStatus(True, aCallerAction);
          //except on e:exception do begin
            try//Проверяю связь вторично. Попытка №2.
              tmpStart:=now;
{$Warnings off}tmpcnn:=IAUPegasDisp(CreateRemoteComObject(cnEComputerName, StringToGUID(cnEComputerGUID)) as IDispatch);
{$Warnings on}try
                tmpEventSink:=TEventSink.Create;
                try
                  if cnIsEMSClient then begin
{$Warnings off}     tmpEventSink.IIDEvents:=IEAMServerEvents;
                  end else begin
{$Warnings off}     tmpEventSink.IIDEvents:=IAUPegasEvents;
                  end;
                  tmpEventSink.OnInvoke:=nil;
                  tmpEventSink.InterfaceConnectEx(tmpcnn, tmpEventSink, tmpCookie);
{$Warnings on}    try{Ok}finally
{$Warnings off}     tmpEventSink.InterfaceDisconnectEx(tmpcnn, tmpCookie);{$Warnings on}
                  end;
                finally
                  tmpEventSink:=nil;
                end;
              finally
                tmpcnn:=nil;
              end;
              if MSecsBetweenDateTime(tmpStart, now)>tmpPingTime then raise exception.create('Время пинга '+TwoDateTimeToDurationStr(tmpStart, now)+'>'+MSecsToDurationStr(tmpPingTime));
              localGetIServerOnline.ITSetOnLineStatus(True, aCallerAction);
            except on t:exception do begin
              localGetIServerOnline.ITSetOnLineStatus(False, aCallerAction);
          //    t.message:=t.message+' First error: '''+e.message+'''.';
              raise;
            end;end;
          //end;end;
          if localGetIServerOnline.ITGetOnLineStatus then begin//Проверка мостов//Online
            tmpV:=Unassigned;
            repeat
              if VarIsArray(tmpV) then tmpPtr:=Pointer(Integer(tmpV[5])) else tmpPtr:=nil;
              tmpV:=localGetIAdmittanceASM.GetInfoNextASMAndLock(tmpPtr);
              if VarIsArray(tmpV) then begin//если что то взялось значит и залочилось
                try
                  tmpPtr:=Pointer(Integer(tmpV[5]));
                  tmpASMState:=IntegerToASMState(Integer(tmpV[4]));
                  if (rsMServerOnLine in tmpASMState)and((rsMServerLogin in tmpASMState)or(rsBridge in tmpASMState)) then begin
                    try
                      case tmpPtr.ITSendCommand({1}cmdEPing, unassigned, aCallerAction.SecurityContext, vlWiatForUnLockSendEvent, true) of
                        tslError:begin//EPing не прошел//Передергиваю мост
                          try tmpPtr.ITSetOffLine; except end;
                          try tmpPtr.ITSetOnLine; except end;
                        end;
                        tslTimeOut, tslOk:begin//Похоже что работает
                        end;
                      else
                        raise exception.create('Не известное значение ITSendEvent(tsl???).');
                      end;
                    except on e:exception do begin
                      try aCallerAction.ITMessAdd(tmpStart, now, 'tskMTOnLineCheck', 'ITSendCommand(ASM='+IntToStr(Integer(tmpV[0]))+'): '+e.message+'/HC='+IntToStr(e.HelpContext), mecApp, mesError);except end;
                    end;end;
                  end;
                finally
                  localGetIAdmittanceASM.UnLock(tmpPtr);
                end;
              end else begin//ASM кончились
                break;
              end;
            until False;
          end;
        end;
      finally//Ставлю на повторное выполнение
        if VarIsArray(aParams) then localGetIThreadsPool.ITMSleepTaskAdd(tskMTOnLineCheck, aParams, aCallerAction, Integer(aParams[0]), localGetTaskID, nil) else
            localGetIThreadsPool.ITMSleepTaskAdd(tskMTOnLineCheck, aParams, aCallerAction, Integer(aParams), localGetTaskID, nil);
      end;
{$ENDIF}
    end;//Out Res:Empty
    tskMTOnLineSet:begin//In aParams: Empty
{$IFDEF PegasServer}
      raise exception.createFmtHelp(cserInapplicableCommandForPegasServer, [MTaskToStr(aTask)], cnerInapplicableCommandForPegasServer);
{$ELSE}
      tmpStart:=now;
      tmpI:=0;
      tmpPtr:=nil; tmpV:=Unassigned;
      Repeat
        tmpV:=localGetIAdmittanceASM.GetInfoNextASMAndLock(tmpPtr);
        if VarIsArray(tmpV) then begin
          try
            tmpPtr:=Pointer(Integer(tmpV[5]));
            if tmpPtr<>nil then begin//Нашел ASM
              try
                tmpPtr.ITSetOnLine;
              except on e:exception do begin
                aCallerAction.ITMessAdd(tmpStart, now, 'tskMTOnLineSet', 'ITSetOnLine: '+e.message+'/HC='+IntToStr(e.HelpContext), mecApp, mesError);
                localGetIThreadsPool.ITMSleepTaskAdd(tskMTCircleOnLineSetForASM, Integer(Pointer(tmpPtr)), aCallerAction, 15000);
              end;end;
              Inc(tmpI);//счетчик
            end;
          finally
            localGetIAdmittanceASM.UnLock(tmpPtr);
          end;
        end else begin//Кончились
          Break;
        end;
      until False;
      if (assigned(aTaskContext))and(assigned(aTaskContext^.aResult)) then begin
        aTaskContext^.aResult^:=tmpI;
        aTaskContext^.aSetResult:=true;
        aTaskContext^.aManualResultSet:=false;//разрешаю автоматическую отработку SetComplete??
      end;
{$ENDIF}
    end;//Out Res: Empty
    tskMTCircleOnLineSetForASM:begin
{$IFDEF PegasServer}
      raise exception.createFmtHelp(cserInapplicableCommandForPegasServer, [MTaskToStr(aTask)], cnerInapplicableCommandForPegasServer);
{$ELSE}
      if localGetIServerOnline.ITOnLineStatus then begin
        if localGetIAdmittanceASM.Lock(Pointer(Integer(aParams)))<1 then raise exception.create('tskMTCircleOnLineSetForASM: ITAdmittanceASM.Lock<1.');
        try
          try
            TEAMServer(Pointer(Integer(aParams))).ITSetOnLine;
          except//Если мост неподнялся пробую еще раз поднять но позже.
            localGetIThreadsPool.ITMSleepTaskAdd(tskMTCircleOnLineSetForASM, aParams, aCallerAction, 15000, localGetTaskID, nil);
            raise;
          end;
        finally
          localGetIAdmittanceASM.UnLock(Pointer(Integer(aParams)));
        End;
      end;
{$ENDIF}
    end;//Out Res: Empty
    tskMTOffLineSet:begin//In aParams: Empty
{$IFDEF PegasServer}
      raise exception.createFmtHelp(cserInapplicableCommandForPegasServer, [MTaskToStr(aTask)], cnerInapplicableCommandForPegasServer);
{$ELSE}
      tmpStart:=now;
      tmpI:=0;
      tmpPtr:=nil; tmpV:=Unassigned;
      repeat
        tmpV:=localGetIAdmittanceASM.GetInfoNextASMAndLock(tmpPtr);
        if VarIsArray(tmpV) then begin
          try
            tmpPtr:=Pointer(Integer(tmpV[5]));
            if tmpPtr<>nil then begin//Нашел ASM
              try
                tmpPtr.ITSetOffLine;
              except on e:exception do
                aCallerAction.ITMessAdd(tmpStart, now, 'tskMTOffLineSet', 'ITSetOffLine: '+e.message+'/HC='+IntToStr(e.HelpContext), mecApp, mesError);
              end;
              inc(tmpI);//счетчик
            end;
          finally
            localGetIAdmittanceASM.UnLock(tmpPtr);
          end;
        end else begin//Кончились
          Break;
        end;
      until False;
      if (assigned(aTaskContext))and(assigned(aTaskContext^.aResult)) then begin
        aTaskContext^.aResult^:=tmpI;
        aTaskContext^.aSetResult:=true;
        aTaskContext^.aManualResultSet:=false;//разрешаю автоматическую отработку SetComplete??
      end;
{$ENDIF}
    end;//Out Res:Empty
  else
    if aRaise then raise exception.createFmtHelp(cserInternalError, ['Unsupported for '+MTaskToStr(aTask)], cnerInternalError) else result:=false;
  end;
end;

end.
