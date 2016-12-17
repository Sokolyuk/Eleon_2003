unit UTaskImplementSendEventUtils;
{$Ifndef PegasServer}{$Ifndef EAMServer}
  Этот модуль изначально серверный
{$endif}{$endif}
interface
  uses UTTaskTypes, UCallerTypes, UTaskImplementTypes;

  function TaskImplementSendEvent(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;

implementation
  uses Sysutils, UErrorConsts, UTTaskUtils, UTrayConsts, Variants, UAdmittanceASMTypes, UThreadsPoolTypes,
       UASMConsts, UASMTypes, UAS, UAppMessageTypes, UNodeInfoTypes, UASMUtilsConsts;

function TaskImplementSendEvent(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;
  var tmpAdmittanceASM:IAdmittanceASM;
  function localGetAdmittanceASM:IAdmittanceASM; begin
    if not assigned(tmpAdmittanceASM) then cnTray.Query(IAdmittanceASM, tmpAdmittanceASM);
    result:=tmpAdmittanceASM;
  end;
  var tmpV:Variant;
      tmpI:Integer;
      tmpPtr:{$IFDEF PegasServer}TAUPegas{$ELSE}TEAMServer{$ENDIF};
begin
  result:=true;
  case aTask of
    tskMTSendMessToId:begin//In MyParams:[0]-varInteger:stASMId(Номер) [1]-varArray:vlDataToSend(данные для ITSendEvent)
      if assigned(aTaskContext) then aTaskContext^.aExceptionMode:=exmPDTransport;//In MyParams:[0]-varInteger(ASM ID); [1]-varInteger(EventID); [2]-varArray(Data); [3]-varInteger(интервал); [4]-varInteger(Колич. попыток)
      result:=TaskImplementSendEvent(aCallerAction, tskMTSendEvent, VarArrayOf([aParams[0], evnOnMessage, aParams[1], vlSendEventInterval, vlSendEventAttempt]){aParams}, aTaskContext, aRaise);
    end;
    tskMTSendMessToUser:begin//In aParams:[0]-stUserName(Имя) [1]-vlDataToSend(данные для ITSendEvent)
      if assigned(aTaskContext) then aTaskContext^.aExceptionMode:=exmPDTransport;
      tmpV:=Unassigned;
      tmpi:=0;
      repeat
        If VarIsArray(tmpV) Then tmpPtr:=Pointer(Integer(tmpV[5])) else tmpPtr:=nil;
        tmpV:=localGetAdmittanceASM.GetInfoNextASMAndLock(tmpPtr);
        If VarIsArray(tmpV) Then begin//если что то взялось значит и залочилось
          try
            If AnsiUpperCase(AnsiString(tmpV[1]))=AnsiUpperCase(AnsiString(aParams[0])) Then begin//Нашел ASM нужного пользователя
              IThreadsPool(cnTray.Query(IThreadsPool)).ITMTaskAdd(tskMTSendEvent, VarArrayOf([tmpV[0], evnOnMessage, aParams[1], vlSendEventInterval, vlSendEventAttempt]), aCallerAction);
            end;
          finally
            localGetAdmittanceASM.UnLock(tmpPtr);
          end;
        end else begin//Кончились
          Break;
        end;
      until False;
      if assigned(aTaskContext) then begin//Результат
        aTaskContext^.aSetResult:=true;
        if assigned(aTaskContext^.aResult) then aTaskContext^.aResult^:=tmpi;
        aTaskContext^.aManualResultSet:=false;//разрешаю автоматическую отработку SetComplete??
      end;
    end;//Out Res:[0]-varinteger:(сколько сообщений отправлено)
    tskMTSendMessToAll:begin//In aParams:[0]-vlDataToSend(данные для ITSendEvent)
      if assigned(aTaskContext) then aTaskContext^.aExceptionMode:=exmPDTransport;
      tmpi:=0;
      tmpPtr:=nil; tmpV:=Unassigned;
      Repeat
        tmpV:=localGetAdmittanceASM.GetInfoNextASMAndLock(tmpPtr);
        If VarIsArray(tmpV) Then begin
          try
            tmpPtr:=Pointer(Integer(tmpV[5]));
            IThreadsPool(cnTray.Query(IThreadsPool)).ITMTaskAdd(tskMTSendEvent, VarArrayOf([tmpV[0], evnOnMessage, aParams, vlSendEventInterval, vlSendEventAttempt]), aCallerAction);
          finally
            localGetAdmittanceASM.UnLock(tmpPtr);
          end;
        end else begin
          Break;
        end;
      Until False;
      if assigned(aTaskContext) then begin//Результат
        aTaskContext^.aSetResult:=true;
        if assigned(aTaskContext^.aResult) then aTaskContext^.aResult^:=tmpi;
        aTaskContext^.aManualResultSet:=false;//разрешаю автоматическую отработку SetComplete??
      end;//Out Res: [0]-varinteger:(сколько сообщений отправлено)
    end;
    tskMTSendEvent:begin//In aParams: [0]-varInteger(ASM ID); [1]-varInteger(EventID); [2]-varArray(Data); [3]-varInteger(интервал); [4]-varInteger(Колич. попыток)
      if assigned(aTaskContext) then aTaskContext^.aExceptionMode:=exmPDTransport;
      tmpi:=0;
      tmpPtr:=localGetAdmittanceASM.GetPntrOnIdAndLock(aParams[0]);//беру addr ASM
      If tmpPtr=Nil Then Raise Exception.Create('Не удается отправить событие, ASMNum='+IntToStr(aParams[0])+' не существует.');//Проверяю на Nil
      try//Пробую отправить
        Case tmpPtr.ITSendEvent(aParams[1], aParams[2], aCallerAction.SecurityContext, vlWiatForUnLockSendEvent, True{evnOnPack<>aParams[1]{Show send pack message}) of
          tslError:Raise Exception.Create('Событие для ASMNum='+IntToStr(aParams[0])+'.');
          tslTimeOut:begin//уменьшаю счетчик и перепосылаю сообщние
            If aParams[4]>0 then begin
              If aParams[4]=1 then IAppMessage(cnTray.Query(IAppMessage)).ITMessAdd(Now, Now, aCallerAction.UserName, 'ImplSendEvent', 'ITSendEvent: Время ожидание когда будет UnLock(ASMNum='+IntToStr(Integer(aParams[0]))+', EventID='+IntToStr(Integer(aParams[1]))+', Attempt='+IntToStr(Integer(aParams[4]))+').', mecDebug, mesWarning);
              IThreadsPool(cnTray.Query(IThreadsPool)).ITMSleepTaskAdd(tskMTSendEvent, VarArrayOf([aParams[0], aParams[1], aParams[2], aParams[3], aParams[4]-1]), aCallerAction, LongWord(aParams[3]), aTaskContext^.aTaskID, @aTaskContext^.aTaskID);
            end else begin//Сообщение не будет отправлено, все возможности исчерпаны
              Raise Exception.Create('Событие для ASMNum='+IntToStr(aParams[0])+' не будет отправлено, число попыток=0.');
            end;
          end;
          tslOk:begin
            Inc(tmpi);//счетчик отправленных сообщений;//Добавляю в лог сообщение об отправке события клиенту
          end;
        else
          raise exception.create('Не известное значение ITSendEvent(tsl???).');
        end;
      finally
        localGetAdmittanceASM.UnLock(tmpPtr);
      end;
      if assigned(aTaskContext) then begin//Результат
        aTaskContext^.aSetResult:=true;
        if assigned(aTaskContext^.aResult) then aTaskContext^.aResult^:=tmpi;
        aTaskContext^.aManualResultSet:=false;//разрешаю автоматическую отработку SetComplete??
      end;
    end;
    tskMTSendEventViaBridge:Begin//In aParams: [0]-varInteger(ID Node); [1]-varInteger(EventID); [2]-varArray(Data); [3]-varInteger(интервал); [4]-varInteger(Колич. попыток)
      if assigned(aTaskContext) then aTaskContext^.aExceptionMode:=exmPDTransport;
{$IFDEF PegasServer}
      tmpV:=Unassigned;
      Repeat
        If VarIsArray(tmpV) Then tmpPtr:=Pointer(Integer(tmpV[5])) else tmpPtr:=nil;
        tmpV:=localGetAdmittanceASM.GetInfoNextASMAndLock(tmpPtr);//Проверяю что взялось
        If VarIsArray(tmpV) Then begin//если что то взялось значит и залочилось
          try
            tmpPtr:=Pointer(Integer(tmpV[5]));
            If ((Integer(tmpV[4]) and msk_rsBridge)=msk_rsBridge) And (Integer(aParams[0])=(Integer(tmpV[7]))) Then begin//Это мост к нужному EAMS//Пробую отправить через этот мост
              Case tmpPtr.ITSendEvent(aParams[1], aParams[2], aCallerAction.SecurityContext, vlWiatForUnLockSendEvent, True) of
                tslError, tslTimeOut:;
                tslOk:Break;
              else
                raise exception.create('Не известное значение ITSendEvent(tsl???).');
              end;
            End;
          finally
            localGetAdmittanceASM.UnLock(tmpPtr);
          end;
        end else begin//ASM Кончились, нет моста или мосты все заняты//Не отправил//уменьшаю счетчик и перепосылаю сообщние
          If aParams[4]>0 then begin
            IThreadsPool(cnTray.Query(IThreadsPool)).ITMSleepTaskAdd(tskMTSendEventViaBridge, VarArrayOf([aParams[0], aParams[1], aParams[2], aParams[3], aParams[4]-1]), aCallerAction, LongWord(aParams[3]), aTaskContext^.aTaskID, @aTaskContext^.aTaskID);
          end else begin//Сообщение не будет отправлено, все возможности исчерпаны
            Raise Exception.Create('Событие не будет отправлено, число попыток=0.');
          end;
          Break;
        end;
      until False;
{$ELSE}
      raise exception.create('Команда не применима для EMServer.');
{$ENDIF}
    end;
    tskMTSendCommand:Begin//In aParams: [0]-varInteger(ID ASM); [1]-varInteger(EventID); [2]-varArray(Data); [3]-varInteger(интервал); [4]-varInteger(Колич. попыток)
      if assigned(aTaskContext) then aTaskContext^.aExceptionMode:=exmPDTransport;
{$IFDEF PegasServer}
      Raise Exception.Create('Команда не применима для PegasServer.');
{$ELSE}
      tmpV:=Unassigned;
      tmpi:=0;
      Repeat
        If VarIsArray(tmpV) Then tmpPtr:=Pointer(Integer(tmpV[5])) else tmpPtr:=nil;
        tmpV:=localGetAdmittanceASM.GetInfoNextASMAndLock(tmpPtr);//Проверяю что взялось
        If VarIsArray(tmpV) Then begin//если что то взялось значит и залочилось
          try
            tmpPtr:=Pointer(Integer(tmpV[5]));
            If Integer(tmpV[0])=Integer(aParams[0]) Then begin//Это мост к нужному EAMS//Пробую отправить через этот мост
              Case tmpPtr.ITSendCommand(aParams[1], aParams[2], aCallerAction.SecurityContext, vlWiatForUnLockSendEvent, True) of
                tslError, tslTimeOut:tmpi:=0;
                tslOk:begin
                  Inc(tmpi);//счетчик отправленных сообщений;
                  Break;
                end;
              else
                raise exception.create('Не известное значение ITSendEvent(tsl???).');
              end;
            End;
          finally
            localGetAdmittanceASM.UnLock(tmpPtr);
          end;
        end else begin//ASM Кончились, нет моста или мосты все заняты//Не отправил//уменьшаю счетчик и перепосылаю сообщние
          If aParams[4]>0 then begin
            IThreadsPool(cnTray.Query(IThreadsPool)).ITMSleepTaskAdd(tskMTSendCommand, VarArrayOf([aParams[0], aParams[1], aParams[2], aParams[3], aParams[4]-1]), aCallerAction, LongWord(aParams[3]), aTaskContext^.aTaskID, @aTaskContext^.aTaskID);
          end else begin//Сообщение не будет отправлено, все возможности исчерпаны
            Raise Exception.Create('Событие не будет отправлено, число попыток=0.');
          end;
          Break;
        end;
      Until False;
      if (tmpi>0)and(assigned(aTaskContext)) then begin//Результат
        aTaskContext^.aSetResult:=true;
        if assigned(aTaskContext^.aResult) then aTaskContext^.aResult^:=tmpi;
        aTaskContext^.aManualResultSet:=false;//разрешаю автоматическую отработку SetComplete??
      end;
{$ENDIF}
    end;
    tskMTSendCommandViaBridge:Begin//In aParams: [0]-varInteger(ID Node); [1]-varInteger(EventID); [2]-varArray(Data); [3]-varInteger(интервал); [4]-varInteger(Колич. попыток)//In aParams:                          [0]-varInteger(EventID); [1]-varArray(Data); [2]-varInteger(интервал); [3]-varInteger(Колич. попыток)
      if assigned(aTaskContext) then aTaskContext^.aExceptionMode:=exmPDTransport;
{$IFDEF PegasServer}
      Raise Exception.Create('Команда не применима для PegasServer.');
{$ELSE}
      tmpV:=Unassigned;
      Repeat
        If VarIsArray(tmpV) Then tmpPtr:=Pointer(Integer(tmpV[5])) else tmpPtr:=nil;
        tmpV:=localGetAdmittanceASM.GetInfoNextASMAndLock(tmpPtr);//Проверяю что взялось
        If VarIsArray(tmpV) Then begin//если что то взялось значит и залочилось
          try
            tmpPtr:=Pointer(Integer(tmpV[5]));
            If ((Integer(tmpV[4]) and msk_rsBridge)=msk_rsBridge)And(Integer(aParams[0])=INodeInfo(cnTray.Query(INodeInfo)).ID{(Integer(tmpV[7]))}) Then begin
              Case tmpPtr.ITSendCommand(aParams[1], aParams[2], aCallerAction.SecurityContext, vlWiatForUnLockSendEvent, True) of
                tslError, tslTimeOut:;
                tslOk:Break;
              else
                raise exception.create('Не известное значение ITSendEvent(tsl???).');
              end;
            End;
          finally
            localGetAdmittanceASM.UnLock(tmpPtr);
          end;
        end else begin//ASM Кончились, нет моста или мосты все заняты//Не отправил//уменьшаю счетчик и перепосылаю сообщние
          If aParams[4]>0 then begin
            IThreadsPool(cnTray.Query(IThreadsPool)).ITMSleepTaskAdd(tskMTSendCommandViaBridge, VarArrayOf([aParams[0], aParams[1], aParams[2], aParams[3], aParams[4]-1]), aCallerAction, LongWord(aParams[3]), aTaskContext^.aTaskID, @aTaskContext^.aTaskID);
          end else begin//Сообщение не будет отправлено, все возможности исчерпаны
            Raise Exception.Create('Событие не будет отправлено, число попыток=0.');
          end;
          Break;
        end;
      Until False;
{$ENDIF}
    End;
  else
    if aRaise then Raise Exception.CreateFmtHelp(cserInternalError, ['Unsupported for '+MTaskToStr(aTask)], cnerInternalError) else result:=false;
  end;
end;

end.
