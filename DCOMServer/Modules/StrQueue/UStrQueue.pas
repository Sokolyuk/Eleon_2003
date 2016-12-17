//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UStrQueue;

interface
  Uses ULocalDataBaseTypes, UCallerTypes, UStrQueueTypes, UTrayInterface;
Type
  TStrQueue=class(TTrayInterface, IStrQueue)
  //protected
  //  function InternalCheckConnectForPackAsString(aPackAsString:AnsiString):boolean;virtual;
  public
    constructor Create;
    destructor Destroy;override;
    function QueuePush(aLocalDataBase:ILocalDataBase; aQueueId:TQueueId; Const aClientQueueId, aSender, aStrData, aCommentary:AnsiString; Const aSenderParams, aSecurityContext:Variant; aWakeUp:TDateTime):Integer;virtual;
    function QueuePop(aLocalDataBase:ILocalDataBase; aQueueId:TQueueId; Out aClientQueueId:AnsiString; Out aSender:AnsiString; Out aStrData:AnsiString; Out aSenderParams:Variant; Out aSecurityContext:Variant):Boolean;virtual;
    function QueueView(aLocalDataBase:ILocalDataBase; aQueueId:TQueueId; Out aClientQueueId:AnsiString; Out aSender:AnsiString; Out aSenderParams:Variant; Out aSecurityContext:Variant; Var aLastssInternalQueueId:Integer):AnsiString;virtual;
    procedure ClearQueue(aLocalDataBase:ILocalDataBase);virtual;
    procedure ClearQueueMentioned(aLocalDataBase:ILocalDataBase; aQueueId:TQueueId);virtual;
    function ClearRePDFromQueueOfClientID(aCallerAction:ICallerAction; aLocalDataBase:ILocalDataBase; Const aClientQueueId:AnsiString; aCheckSecurity:Boolean=True):Integer;virtual;
  end;

implementation
  uses SysUtils, Db, DbClient, UTypeUtils, UStringUtils, UStringConsts, UAppMessageTypes, UStrQueueConsts, Variants
       //, UAdmittanceASMTypes
       ;

constructor TStrQueue.Create;
begin
  Inherited Create;
end;

destructor TStrQueue.Destroy;
begin
  Inherited Destroy;
end;

Function TStrQueue.QueuePush;
  Var iI:Integer;
      tmpSt:AnsiString;
      tmpParams:TParams;
      tmpOleParams:OleVariant;
      OldTableAutoLock:Boolean;
begin
  If not assigned(aLocalDataBase) Then Raise Exception.Create('TStrQueue.QueuePush: LocalDataBase is not assigned.');
  Internallock;
  try
    aLocalDataBase.WaitForLockList('+ssInternalQueue,+ssInternalQueueStrData', True, aLocalDataBase.LockListTimeOut);
    try
      OldTableAutoLock:=aLocalDataBase.TableAutoLock;
      aLocalDataBase.TableAutoLock:=False;
      try
        aLocalDataBase.ExecSQL('BEGIN TRANSACTION');
        Result:=-1;//от варнингов
        try
          {If FCheckClientID Then begin//Требуется проверка CheckClientID.
            If aClientQueueId<>'' Then
              If aLocalDataBase.ExecSQL('SELECT ssInternalQueueId FROM ssInternalQueue WHERE ClientQueueId='''+glStrToSQL(aClientQueueId)+'''')<>0 Then Raise Exception.Create('Ошибка при добавлении в таблицу ssInternalQueue: Запись с ClientQueueId='''+aClientQueueId+''' уже существует.');
          end;}
          If Now>=aWakeUp Then begin//Время WakeUp уже прошло.
            If aLocalDataBase.ExecSQL('INSERT INTO ssInternalQueue(QueueId,ClientQueueId,Sender,Commentary,SecurityContext,SenderParams)VALUES('+IntToStr(Integer(aQueueId))+','+StrToSqlStr(aClientQueueId)+','+StrToSqlStr(aSender)+','+StrToSqlStr(aCommentary)+',' +StrToSqlStr(glVarArrayToString(aSecurityContext))+','+StrToSqlStr(glVarArrayToString(aSenderParams))+')')<>1 Then Raise Exception.Create('Ошибка при добавлении в таблицу ssInternalQueue(INS RA<>1).');
          end else begin//Время WakeUp еще не настало.
            tmpParams:=TParams.Create;
            try
              tmpParams.CreateParam(ftDateTime, 'aWakeUp', ptInput).AsDateTime:=aWakeUp;
              tmpOleParams:=PackageParams(tmpParams);
              If aLocalDataBase.ExecSQL('INSERT INTO ssInternalQueue(QueueId,ClientQueueId,Sender,Commentary,SecurityContext,SenderParams,[WakeUp])VALUES('+IntToStr(Integer(aQueueId))+','+StrToSqlStr(aClientQueueId)+','+StrToSqlStr(aSender)+','+StrToSqlStr(aCommentary)+','  +StrToSqlStr(glVarArrayToString(aSecurityContext))+','+StrToSqlStr(glVarArrayToString(aSenderParams))+',:aWakeUp)', tmpOleParams)<>1 Then Raise Exception.Create('Ошибка при добавлении в таблицу ssInternalQueue(INS RA<>1).');
            finally
              tmpParams.free;
              VarClear(tmpOleParams);
            end;
          end;
          aLocalDataBase.OpenSQL('SELECT MAX(ssInternalQueueId) as LastssInternalQueueId From ssInternalQueue');
          If aLocalDataBase.DataSet.RecordCount<>1 Then Raise Exception.Create('Ошибка в таблице ssInternalQueue(SEL RA<>1).');
          Result:=aLocalDataBase.DataSet.FieldByName('LastssInternalQueueId').AsInteger;//Добавля StrData
          For iI:=1 to (Length(aStrData) Div cnLDBMaxStrLength)+1 do begin
            tmpSt:=Copy(aStrData, 1+((iI-1)*cnLDBMaxStrLength), cnLDBMaxStrLength);
            If tmpSt<>'' Then begin
              If aLocalDataBase.ExecSQL('INSERT INTO ssInternalQueueStrData(ssInternalQueueId,Num,StrData)VALUES('+IntToStr(Result)+','+IntToStr(iI)+','+StrToSqlStr(tmpSt)+')')<>1 Then Raise Exception.Create('Ошибка при добавлении в таблицу ssInternalQueueStrData(INS RA<>1).');
            end;
          end;
          tmpSt:='';
          aLocalDataBase.ExecSQL('COMMIT TRANSACTION');
        except
          tmpSt:='';
          aLocalDataBase.ExecSQL('ROLLBACK TRANSACTION');
          Raise;
        end;
      finally
        aLocalDataBase.TableAutoLock:=oldTableAutoLock;
      end;
    finally
      aLocalDataBase.WaitForLockList('-ssInternalQueue;-ssInternalQueueStrData', True, aLocalDataBase.LockListTimeOut);
    end;
  finally
    Internalunlock;
  end;
end;

Function TStrQueue.QueuePop(aLocalDataBase:ILocalDataBase; aQueueId:TQueueId; Out aClientQueueId:AnsiString; Out aSender:AnsiString; Out aStrData:AnsiString; Out aSenderParams:Variant; Out aSecurityContext:Variant):Boolean;
  Var tmpssInternalQueueId:Integer;
      tmpSt:AnsiString;
      tmpWakeUp:TDateTime;
      OldTableAutoLock:Boolean;
begin
  If not assigned(aLocalDataBase) Then Raise Exception.Create('TStrQueue.QueuePop: LocalDataBase is not assigned.');
  Internallock;
  try
    aClientQueueId:='';
    aSender:='';
    aStrData:='';
    Result:=False;
    aLocalDataBase.OpenSQL('SELECT ssInternalQueueId,ClientQueueId,Sender,SecurityContext,SenderParams,WakeUp From ssInternalQueue Where QueueId='+IntToStr(Integer(aQueueId))+' Order by ssInternalQueueId');
    If aLocalDataBase.DataSet.RecordCount<1 Then begin//Очередь пуста
      Exit;
    end;
    While true do begin//Проматываю выборку до конца.
      If aLocalDataBase.DataSet.Eof then begin//В очереди нет активной записи
        Exit;
      end;
      If aLocalDataBase.DataSet.FieldByName('WakeUp').IsNull then begin//Добежал до записи где время не указано => до активной записи.
        break;
      end else begin
        tmpWakeUp:=aLocalDataBase.DataSet.FieldByName('WakeUp').AsDateTime;
        If tmpWakeUp<=Now then begin//Добежал до записи где время указано и меньше Now=> до активной записи.
          break;
        end;
      end;
      aLocalDataBase.DataSet.Next;
    end;
    tmpssInternalQueueId:=aLocalDataBase.DataSet.FieldByName('ssInternalQueueId').AsInteger;
    aClientQueueId:=aLocalDataBase.DataSet.FieldByName('ClientQueueId').AsString;
    aSender:=aLocalDataBase.DataSet.FieldByName('Sender').AsString;
    aSecurityContext:=glStringToVarArray(aLocalDataBase.DataSet.FieldByName('SecurityContext').AsString);
    aSenderParams:=glStringToVarArray(aLocalDataBase.DataSet.FieldByName('SenderParams').AsString);
    aLocalDataBase.OpenSQL('SELECT StrData From ssInternalQueueStrData Where ssInternalQueueId='+IntToStr(tmpssInternalQueueId)+' Order by Num');
    If aLocalDataBase.DataSet.RecordCount>0 then begin
      Result:=True;
      aLocalDataBase.DataSet.First;
      While aLocalDataBase.DataSet.Eof=False do begin
        aStrData:=aStrData+aLocalDataBase.DataSet.FieldByName('StrData').AsString;
        aLocalDataBase.DataSet.Next;
      end;
    end;
    (*//проверяю если это досылка, то есть ли связь, если нет то не даю пакет.
    if (aQueueId=qidRePD{10})and(not InternalCheckConnectForPackAsString(aStrData)) then begin
      aClientQueueId:='';
      aSender:='';
      aStrData:='';
      result:=false;
    end;*)
    //продолжаю
    aLocalDataBase.WaitForLockList('+ssInternalQueue,+ssInternalQueueStrData', True, aLocalDataBase.LockListTimeOut);
    try
      OldTableAutoLock:=aLocalDataBase.TableAutoLock;
      aLocalDataBase.TableAutoLock:=False;
      try
        If aLocalDataBase.DataSet.RecordCount<1 Then begin//Очередь не пуста, а в ssInternalQueueStrData нет соответствующий ssInternalQueueId данных.
          aLocalDataBase.ExecSQL('Delete from ssInternalQueue Where ssInternalQueueId='+IntToStr(tmpssInternalQueueId));
        end else begin
          aLocalDataBase.ExecSQL('BEGIN TRANSACTION');
          try
            aLocalDataBase.ExecSQL('Delete from ssInternalQueueStrData Where ssInternalQueueId='+IntToStr(tmpssInternalQueueId));
            aLocalDataBase.ExecSQL('Delete from ssInternalQueue Where ssInternalQueueId='+IntToStr(tmpssInternalQueueId));
            aLocalDataBase.ExecSQL('COMMIT TRANSACTION');
          except
            tmpSt:='';
            aLocalDataBase.ExecSQL('ROLLBACK TRANSACTION');
            Raise;
          end;
        end;
      finally
        aLocalDataBase.TableAutoLock:=OldTableAutoLock;
      end;
    finally
      aLocalDataBase.WaitForLockList('-ssInternalQueue,-ssInternalQueueStrData', True, aLocalDataBase.LockListTimeOut);
    end;
  finally
    Internalunlock;
  end;
end;
(*
function TStrQueue.InternalCheckConnectForPackAsString(aPackAsString:AnsiString):boolean;
  var tmpPtr:pointer;
      tmpV:variant;
begin
  aPackAsString
  try
    tmpPtr:=nil;
    repeat
      tmpV:=IAdmittanceASM(InternalGetITray.Query(IAdmittanceASM)).GetInfoNextASMAndLock(tmpPtr);
                    // Проверяю что взялось
                    if VarIsArray(tmpV) Then begin
                      // если что то взялось значит и залочилось
                      tmpPtr:=Pointer(Integer(tmpV[5]));
                      try
{$IFDEF PegasServer}
                        if ((Integer(tmpV[4]) and msk_rsBridge)=msk_rsBridge)And(tmplI{ID Node}=(Integer(tmpV[7])){ID Node}) then begin
{$ELSE}
                        if ((Integer(tmpV[4]) and msk_rsBridge)=msk_rsBridge)And(tmplI{ID Node}=INodeInfo(cnTray.Query(INodeInfo)).ID{vlEAMServerLocalBaseID}{ID Node}) Then begin
{$ENDIF}
                          // Это мост
                          // Пробую отправить через этот мост ITSendCommand/ITSendEvent
                          Case tmplPtr.ITSendEvent(evnOnPack{событие evnOnPack}, _aaPD{пакет команд}, CallerAction.SecurityContext, vlWiatForUnLockSendEvent, False{ShowSendPackMess}) of
                            tslError:Raise Exception.Create('Неизвестная ошибка(tslError).');
                            tslTimeOut:Raise Exception.Create('Мост занят.');
                            tslOk:begin
                              // Удалось отправить снимаю все ошибки которые были, т.к. теперь они не нужны.
                              try CallerAction.ITMessAdd(_iStartNow, Now, ClassName+'#'+IntToStr(Integer(tmplV[0])), 'Event(bridge='+VarToStr(tmplI)+'): PD(ID='''+VarToStr(PDID)+''')', mecTransport, mesInformation); except end;
                              _TransportError:=False;
                              _iErrMess:='';
                              tmpHelpContext:=0;
                              Break;
                            end;
                          else
                            raise exception.create('Не известное значение ITSendEvent(tsl?).');
                          end;
                        End;
                      finally
                        InternalGetIAdmittanceASM.UnLock(tmpPtr);
                      end;
                    end else begin
                      // ASM Кончились, не отправил, нет моста
                      If _TransportError Then begin
                        _iErrMess:='Свободный мост('+IntToStr(tmplI{ID Node})+') не найден('+_iErrMess+').';
                        tmpHelpContext:=cnerFreeBridgeNotFound;
                      end else begin
                        _TransportError:=True;
                        _iErrMess:='Мост('+IntToStr(tmplI{ID Node})+') не найден.';
                        tmpHelpContext:=cnerBridgeNotFound;
                      end;
                      // Чтобы выйти из цыкла и не попасть в Except ставлю Break и заполняю _iErrMess и _TransportError.
                      Break;
                    end;
    until false;
--
                repeat
                  //If Gl_DataCase<>Nil Then begin
                    //If VarIsArray(tmplV) Then tmplPtr:=Pointer(Integer(tmplV[5])) else tmplPtr:=nil;
                    tmplV:=InternalGetIAdmittanceASM.GetInfoNextASMAndLock(tmplPtr);
                  //end else tmplV:=Unassigned;
                  try
                    // Проверяю что взялось
                    If VarIsArray(tmplV) Then begin
                      // если что то взялось значит и залочилось
                      tmplPtr:=Pointer(Integer(tmplV[5]));
                      try
{$IFDEF PegasServer}
                        If ((Integer(tmplV[4]) and msk_rsBridge)=msk_rsBridge)And(tmplI{ID Node}=(Integer(tmplV[7])){ID Node}) Then begin
{$ELSE}
                        If ((Integer(tmplV[4]) and msk_rsBridge)=msk_rsBridge)And(tmplI{ID Node}=INodeInfo(cnTray.Query(INodeInfo)).ID{vlEAMServerLocalBaseID}{ID Node}) Then begin
{$ENDIF}
                          // Это мост
                          // Пробую отправить через этот мост ITSendCommand/ITSendEvent
                          Case tmplPtr.ITSendEvent(evnOnPack{событие evnOnPack}, _aaPD{пакет команд}, CallerAction.SecurityContext, vlWiatForUnLockSendEvent, False{ShowSendPackMess}) of
                            tslError:Raise Exception.Create('Неизвестная ошибка(tslError).');
                            tslTimeOut:Raise Exception.Create('Мост занят.');
                            tslOk:begin
                              // Удалось отправить снимаю все ошибки которые были, т.к. теперь они не нужны.
                              try CallerAction.ITMessAdd(_iStartNow, Now, ClassName+'#'+IntToStr(Integer(tmplV[0])), 'Event(bridge='+VarToStr(tmplI)+'): PD(ID='''+VarToStr(PDID)+''')', mecTransport, mesInformation); except end;
                              _TransportError:=False;
                              _iErrMess:='';
                              tmpHelpContext:=0;
                              Break;
                            end;
                          else
                            raise exception.create('Не известное значение ITSendEvent(tsl?).');
                          end;
                        End;
                      finally
                        InternalGetIAdmittanceASM.UnLock(tmplPtr);
                      end;
                    end else begin
                      // ASM Кончились, не отправил, нет моста
                      If _TransportError Then begin
                        _iErrMess:='Свободный мост('+IntToStr(tmplI{ID Node})+') не найден('+_iErrMess+').';
                        tmpHelpContext:=cnerFreeBridgeNotFound;
                      end else begin
                        _TransportError:=True;
                        _iErrMess:='Мост('+IntToStr(tmplI{ID Node})+') не найден.';
                        tmpHelpContext:=cnerBridgeNotFound;
                      end;
                      // Чтобы выйти из цыкла и не попасть в Except ставлю Break и заполняю _iErrMess и _TransportError.
                      Break;
                    end;
                  Except On E:Exception do begin
                    // Ошибка при отправке через этот мост
                    // запоминаю ее и пробую отправить через другой мост.
                   _TransportError:=True;
                   _iErrMess:=e.message;
                   tmpHelpContext:=E.HelpContext;
                  end;End;
                until False;
--
  except on e:exception do begin
    warning
  end;end;
end;
*)
Function TStrQueue.QueueView;
  Var tmpssInternalQueueId:Integer;
      tmpWakeup:TDateTime;
begin
  If not assigned(aLocalDataBase) Then Raise Exception.Create('TStrQueue.QueueView: LocalDataBase is not assigned.');
  Internallock;
  try
    aClientQueueId:='';
    aSender:='';
    Result:='';
    aLocalDataBase.OpenSQL('SELECT ssInternalQueueId,ClientQueueId,Sender,SecurityContext,SenderParams,WakeUp From ssInternalQueue Where QueueId='+IntToStr(Integer(aQueueId))+' Order by ssInternalQueueId');
    If aLocalDataBase.DataSet.RecordCount<1 Then begin//Очередь пуста
      aLastssInternalQueueId:=-1;
      Exit;
    end;//Проматываю до следующей позиции после aLastssInternalQueueId.
    While true do begin
      If aLocalDataBase.DataSet.Eof then begin//В очереди не указанной записи
        aLastssInternalQueueId:=-1;
        Exit;
      end;
      If Not(aLocalDataBase.DataSet.FieldByName('WakeUp').IsNull) then begin
        tmpWakeup:=aLocalDataBase.DataSet.FieldByName('WakeUp').AsDateTime;
        If tmpWakeup>Now then begin//Добежал до записи где время указано и больше Now => до неактивной записи.
          aLocalDataBase.DataSet.Next;
          Continue;
        end;
      end;
      tmpssInternalQueueId:=aLocalDataBase.DataSet.FieldByName('ssInternalQueueId').AsInteger;
      If tmpssInternalQueueId>aLastssInternalQueueId then begin//Добежал до нужной записи.Нужная запись существует
        break;
      end;
      aLocalDataBase.DataSet.Next;
    end;
    tmpssInternalQueueId:=aLocalDataBase.DataSet.FieldByName('ssInternalQueueId').AsInteger;//Переставляю указатель на нужную запись
    aLastssInternalQueueId:=tmpssInternalQueueId;
    aClientQueueId:=aLocalDataBase.DataSet.FieldByName('ClientQueueId').AsString;
    aSender:=aLocalDataBase.DataSet.FieldByName('Sender').AsString;
    aSecurityContext:=glStringToVarArray(aLocalDataBase.DataSet.FieldByName('SecurityContext').AsString);
    aSenderParams:=glStringToVarArray(aLocalDataBase.DataSet.FieldByName('SenderParams').AsString);
    aLocalDataBase.OpenSQL('SELECT StrData From ssInternalQueueStrData Where ssInternalQueueId='+IntToStr(tmpssInternalQueueId)+' Order by Num');
    If aLocalDataBase.DataSet.RecordCount>0 then begin
      aLocalDataBase.DataSet.First;
      While aLocalDataBase.DataSet.Eof=False do begin
        Result:=Result+aLocalDataBase.DataSet.FieldByName('StrData').AsString;
        aLocalDataBase.DataSet.Next;
      end;
    end;
  finally
    Internalunlock;
  end;
end;

Procedure TStrQueue.ClearQueue;
  Var OldTableAutoLock:Boolean;
begin
  If not assigned(aLocalDataBase) Then Raise Exception.Create('TStrQueue.ClearQueue: LocalDataBase is not assigned.');
  Internallock;
  try
    aLocalDataBase.WaitForLockList('+ssInternalQueue,+ssInternalQueueStrData', True, aLocalDataBase.LockListTimeOut);
    try
      OldTableAutoLock:=aLocalDataBase.TableAutoLock;
      aLocalDataBase.TableAutoLock:=False;
      try
        aLocalDataBase.ExecSQL('BEGIN TRANSACTION');
        try
          aLocalDataBase.ExecSQL('Delete from ssInternalQueueStrData');
          aLocalDataBase.ExecSQL('Delete from ssInternalQueue');
          aLocalDataBase.ExecSQL('COMMIT TRANSACTION');
        except
          aLocalDataBase.ExecSQL('ROLLBACK TRANSACTION');
          Raise;
        end;
      finally
        aLocalDataBase.TableAutoLock:=OldTableAutoLock;
      end;
    finally
      aLocalDataBase.WaitForLockList('-ssInternalQueue,-ssInternalQueueStrData', True, aLocalDataBase.LockListTimeOut);
    end;
  finally
    Internalunlock;
  end;
end;

Procedure  TStrQueue.ClearQueueMentioned;
  Var OldTableAutoLock:Boolean;
begin
  If not assigned(aLocalDataBase) Then Raise Exception.Create('TStrQueue.ClearQueueMentioned: LocalDataBase is not assigned.');
  Internallock;
  try
    aLocalDataBase.OpenSQL('Select ssInternalQueueId from ssInternalQueue Where QueueId='+IntToStr(Integer(aQueueId)));
    If aLocalDataBase.DataSet.RecordCount<1 Then begin//Очередь пуста.
      Exit;
    end;
    aLocalDataBase.WaitForLockList('+ssInternalQueue,+ssInternalQueueStrData', True, aLocalDataBase.LockListTimeOut);
    try
      OldTableAutoLock:=aLocalDataBase.TableAutoLock;
      aLocalDataBase.TableAutoLock:=False;
      try
        aLocalDataBase.ExecSQL('BEGIN TRANSACTION');
        try
          aLocalDataBase.DataSet.First;
          While aLocalDataBase.DataSet.Eof=False do begin
            aLocalDataBase.ExecSQL('Delete from ssInternalQueueStrData Where ssInternalQueueId='+IntToStr(aLocalDataBase.DataSet.FieldByName('ssInternalQueueId').AsInteger));
            aLocalDataBase.ExecSQL('Delete from ssInternalQueue Where ssInternalQueueId='+IntToStr(aLocalDataBase.DataSet.FieldByName('ssInternalQueueId').AsInteger));
            aLocalDataBase.DataSet.Next;
          end;
          aLocalDataBase.ExecSQL('COMMIT TRANSACTION');
        except
          aLocalDataBase.ExecSQL('ROLLBACK TRANSACTION');
          Raise;
        end;
      finally
        aLocalDataBase.TableAutoLock:=OldTableAutoLock;
      end;
    finally
      aLocalDataBase.WaitForLockList('-ssInternalQueue,-ssInternalQueueStrData', True, aLocalDataBase.LockListTimeOut);
    end;
  finally
    Internalunlock;
  end;  
end;

Function TStrQueue.ClearRePDFromQueueOfClientID;
  Var OldTableAutoLock:Boolean;
      tmpSt, tmpStrRePD, tmpStrCaller:AnsiString;
  Function SecurityContextToParamsStr(Const _aSecurityContext:Variant):AnsiString;
    Var tmplI:Integer;
  begin
    result:='';
    try
      If VarIsArray(_aSecurityContext) Then begin
        For tmplI:=VarArrayLowBound(_aSecurityContext, 1) to VarArrayHighBound(_aSecurityContext, 1) do begin
          result:=result+_aSecurityContext[tmplI]+csParamsStrSeparator;
        end;
      end;  
    except
      on e:exception do if Assigned(aCallerAction) Then aCallerAction.ITMessAdd(Now, Now, 'TStrQueue', 'Error(Ignored): '+e.message, mecApp, mesError);
    end;
  end;
begin
  Result:=0;
  If not assigned(aLocalDataBase) Then Raise Exception.Create('TStrQueue.ClearQueueMentioned: LocalDataBase is not assigned.');
  Internallock;
  try
    aLocalDataBase.OpenSQL('Select ssInternalQueueId,SecurityContext from ssInternalQueue Where (ClientQueueId='+StrToSqlStr(aClientQueueId)+')AND(QueueId='+IntToStr(Integer(qidRePD))+')');
    If aLocalDataBase.DataSet.RecordCount<1 Then begin //пусто.
      Exit;
    end;
    If aCheckSecurity Then begin
      tmpStrRePD:=SecurityContextToParamsStr(glStringToVarArray(aLocalDataBase.DataSet.FieldByName('SecurityContext').AsString));
      if Assigned(aCallerAction) Then begin
        tmpStrCaller:=SecurityContextToParamsStr(aCallerAction.SecurityContext);
      end else begin
        Raise Exception.Create('CallerAction is not assigned.');
      end;
      tmpSt:=GetDifferentParamsStrFromParamsStr(tmpStrCaller, tmpStrRePD, ';');
      If tmpSt<>'' Then begin
        Raise Exception.Create('Недостаточно прав для выполнение команды ''ClearRePDFromQueueOfClientID''(Не хватает ролей: '''+tmpSt+''').');
      end;
    end;
    aLocalDataBase.WaitForLockList('+ssInternalQueue,+ssInternalQueueStrData', True, aLocalDataBase.LockListTimeOut);
    try
      OldTableAutoLock:=aLocalDataBase.TableAutoLock;
      aLocalDataBase.TableAutoLock:=False;
      try
        aLocalDataBase.ExecSQL('BEGIN TRANSACTION');
        try
          aLocalDataBase.DataSet.First;
          While aLocalDataBase.DataSet.Eof=False do begin
            aLocalDataBase.ExecSQL('Delete from ssInternalQueueStrData Where ssInternalQueueId='+IntToStr(aLocalDataBase.DataSet.FieldByName('ssInternalQueueId').AsInteger));
            aLocalDataBase.ExecSQL('Delete from ssInternalQueue Where ssInternalQueueId='+IntToStr(aLocalDataBase.DataSet.FieldByName('ssInternalQueueId').AsInteger));
            aLocalDataBase.DataSet.Next;
            Inc(Result);
          end;
          aLocalDataBase.ExecSQL('COMMIT TRANSACTION');
        except
          aLocalDataBase.ExecSQL('ROLLBACK TRANSACTION');
          Raise;
        end;
      finally
        aLocalDataBase.TableAutoLock:=OldTableAutoLock;
      end;
    finally
      aLocalDataBase.WaitForLockList('-ssInternalQueue,-ssInternalQueueStrData', True, aLocalDataBase.LockListTimeOut);
    end;
  finally
    Internalunlock;
  end;  
end;

end.
