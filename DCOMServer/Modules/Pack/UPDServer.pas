//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UPDServer;
{$Ifndef PegasServer}{$Ifndef EAMServer}{$Ifndef ESClient}Неназначены Defines EAMServer, PegasServer или Client.{$endif}{$endif}{$endif}
{$Ifdef PegasServer}{$Ifdef EAMServer}Назначены Defines EAMServer и PegasServer.{$endif}{$endif}

Interface
  Uses UPD, UThreadsPoolTypes, UAdmittanceASMTypes;
  
Type
  TPDServer=class(TPD)
  private
    FThreadsPool:IThreadsPool;
    FAdmittanceASM:IAdmittanceASM;
  Protected
    function InternalGetIThreadsPool:IThreadsPool;virtual;
    function InternalGetIAdmittanceASM:IAdmittanceASM;virtual;
    Procedure InternalHop1;Override;
    Function ReceivedCP(out aBuildResult:Boolean; Const aData:Variant):Variant;Override;
  Public
    Constructor Create;
    Destructor Destroy;override;
    Procedure CheckPD;override;
    Procedure TransportError(Const aMessage:Ansistring; aHelpContext:Integer; Const aRes:Variant);Override;
  end;

implementation
  Uses UCommandPackServer, UPackConsts, UPackTypes, Sysutils, UASMConsts, UADMTypes, ULocalDataBase, UStrQueue, UAS,
       ULocalDataBaseTypes, UStringsetTypes, Windows, UTTaskTypes, UDateTimeUtils, UErrorConsts, UPackUtils,
       UTypeUtils, UAppMessageTypes, UTrayConsts, UStrQueueTypes, ULogFileTypes, UServerInfoTypes, UASMTypes{$Ifdef DebugPack},
       UTypeUtils{$endif}, Variants, UServerActionConsts, UASMUtilsConsts, UNodeInfoTypes, UBitTypes;

Constructor TPDServer.Create;
begin
  Inherited Create;
  FThreadsPool:=nil;
  FAdmittanceASM:=nil;
end;

Destructor  TPDServer.Destroy;
begin
  FThreadsPool:=nil;
  FAdmittanceASM:=nil;
  Inherited Destroy;
end;

Procedure TPDServer.CheckPD;
begin
  try
    Inherited CheckPD;
{$Ifdef DebugPack}
    CallerAction.ITMessAdd(Now, StartTime, 'CheckPD', 'Ok: '+glVarArrayToString(Data), mecTransport , mesInformation);
{$endif}
  except on e:exception do begin
{$Ifdef DebugPack}
    CallerAction.ITMessAdd(Now, StartTime, 'CheckPD', 'Err('''+e.message+'''): '+glVarArrayToString(Data), mecTransport , mesError);
{$endif}
    raise;
  end;end;  
end;

Function TPDServer.ReceivedCP(out aBuildResult:Boolean; Const aData:Variant):Variant;
  Var iCommandPackServer:TCommandPackServer;
begin
  iCommandPackServer:=TCommandPackServer.Create;
  try//Events Command Pack.
    iCommandPackServer.OnReceiveCPT1:=OnReceiveCPT1;
    iCommandPackServer.OnReceiveCPT1Error:=OnReceiveCPT1Error;
    iCommandPackServer.OnReceiveCPR1:=OnReceiveCPR1;
    iCommandPackServer.OnReceiveCPR1Error:=OnReceiveCPR1Error;
    iCommandPackServer.OnCheckSecurityPTask:=OnCheckSecurityPTask;
    iCommandPackServer.OwnerPD:=Self;
    iCommandPackServer.TitlePoint:=TitlePoint;
    iCommandPackServer.Data:=aData;
    iCommandPackServer.CallerAction:=CallerAction;
    Result:=iCommandPackServer.Exec;
    aBuildResult:=iCommandPackServer.BuildResult;
  finally
    iCommandPackServer.free;
  end;
end;

Procedure TPDServer.InternalHop1;
  Type TSendMode = (smdSingleASM, smdViaBridge, smdForListOfASM);
  Var iCurrPlace:TPlace;
      iCurrNum:Integer;
      tmpI64:T64bit;
  Procedure SendEventOnID(_aaPD:Variant; const _aaVarASMId:Variant; _aSendMode:TSendMode{; const _aSecurityContext:Variant});
    Var tmplV:Variant;
{$IFDEF PegasServer}
        tmplPtr:TAUPegas;
{$ELSE}
        tmplPtr:TEAMServer;
{$ENDIF}
        tmplI:Integer;
        _TransportError:Boolean;
        _iErrMess:AnsiString;
        tmpHelpContext:Integer;
        _iStartNow:TDateTime;
    begin
      Try
        try
          _iStartNow:=Now;
          // Устанавливаю новые значения
          // Проверяю надо ли переустановить Place
          If ((Options and Protocols_PD_Options_NoTransform)<>Protocols_PD_Options_NoTransform) And
             (_aaPD[Protocols_PD_Place][iCurrNum]<>pdsEventOnID) Then begin
            If _aaPD[Protocols_PD_Place][iCurrNum]<>pdsEventOnBridge Then begin
              // меняю Place
              tmplV:=_aaPD[Protocols_PD_Place];
              tmplV[iCurrNum]:=pdsEventOnID;
              _aaPD[Protocols_PD_Place]:=tmplV;
              // меняю PlaceData
              tmplV:=_aaPD[Protocols_PD_PlaceData];
              tmplV[iCurrNum]:=_aaVarASMId;
              _aaPD[Protocols_PD_PlaceData]:=tmplV;
            End;
          end;
          // Устанавливаю счетчик
          _aaPD[Protocols_PD_CurrNum]:=iCurrNum+1; // iCurrNum - текущий номер, поскольку есть не стал еще раз вытаскивать.
          // ..
          //If Gl_DataCase=Nil then Raise Exception.Create('DataCase is not assigned.');
          Case _aSendMode Of
            smdSingleASM:Begin
              InternalGetIThreadsPool.ITMTaskAdd(tskMTSendEvent, VarArrayOf([_aaVarASMId,{ASM ID} evnOnPack{событие evnOnPack}, VariantToPack(_aaPD){пакет команд}, vlSendEventInterval, vlSendEventAttempt]),
                                                                    CallerAction{SenderParams, _aSecurityContext});
            End;
            smdViaBridge:Begin
              //DataCase.ITMTaskAdd(tskMTSendCommandViaBridge, VarArrayOf([_aaPD[Protocols_PD_PlaceData][iCurrNum]{ID Node}, cmdEPack,{cmdEPack} _aaPD,{пакет команд} vlSendEventInterval, vlSendEventAttempt]), SenderParams{vPlaceData}, _aSecurityContext);
              tmplV:=Unassigned;
              tmplPtr:=nil;
              tmplI{ID Node}:=_aaPD[Protocols_PD_PlaceData][iCurrNum]; // ID Node
              // Назначаю параметры.
             _TransportError:=False;
             _iErrMess:='';
             tmpHelpContext:=0;
              // Пробую отправить
              try
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
                If _TransportError Then begin
                  // Событие не отправлено была транспортная ошибка.
                  try CallerAction.ITMessAdd(_iStartNow, Now, ClassName, 'Event(bridge='+VarToStr(tmplI{ID Node})+'): PD(ID='''+VarToStr(PDID)+''')', mecTransport, mesError); except end;
                  If Assigned(OnTransportError) Then OnTransportError(Self, _iErrMess, tmpHelpContext, Unassigned) else
                    TransportError(_iErrMess, tmpHelpContext, Unassigned);
                  //!! Уведомление о ошибках
                end;
              Except on E:Exception do begin
                e.message:='Неизвестная ошибка при отправке PD(smdViaBridge): '+e.message;
                Raise;
              end;end;
            end;  
            smdForListOfASM:Begin
              Raise Exception.Create('Не реализовано.');
            End;
          else
            Raise Exception.Create('Неизвестное значение _aSendMode.');
          End;
        finally
          // навсякий случай чищу сам
          VarClear(_aaPD);
          VarClear(tmplV);
        end;
      Except On E:Exception do begin
        e.message:='SendEventOnID: '+e.message;
        Raise;
      end;End;
    end;
  Procedure SendCommandOnID(_aaPD:Variant; const _aaVarASMId:Variant; _aSendMode:TSendMode{; const _aSecurityContext:Variant});
{$IFDEF PegasServer}
{$ELSE}
    Var tmplV : Variant;
        tmplPtr:TEAMServer;
        tmplI:Integer;
        _TransportError:Boolean;
        _iErrMess:AnsiString;
        tmpHelpContext:Integer;
        _iStratNow:TDateTime;
{$ENDIF}
    begin
      Try
{$IFDEF PegasServer}
          Raise Exception.Create('SendCommandOnID для ''Pegas'' неприменима.');
{$ELSE}
        _iStratNow:=Now;
        try
          // Устанавливаю новые значения
          // Проверяю надоли переустановить Place
          If ((Options and Protocols_PD_Options_NoTransform)<>Protocols_PD_Options_NoTransform) And
             (_aaPD[Protocols_PD_Place][iCurrNum]<>pdsCommandOnID) Then begin
            If _aaPD[Protocols_PD_Place][iCurrNum]<>pdsCommandOnBridge Then begin
              // меняю Place
              tmplV:=_aaPD[Protocols_PD_Place];
              tmplV[iCurrNum]:=pdsCommandOnID;
              _aaPD[Protocols_PD_Place]:=tmplV;
              // меняю PlaceData
              tmplV:=_aaPD[Protocols_PD_PlaceData];
              tmplV[iCurrNum]:=_aaVarASMId;
              _aaPD[Protocols_PD_PlaceData]:=tmplV;
            end;
          end;
          // Устанавливаю счетчик
          _aaPD[Protocols_PD_CurrNum]:=iCurrNum+1;
          //If Gl_DataCase=Nil then Raise Exception.Create('Gl_DataCase is not assigned.');
          Case _aSendMode Of
            smdSingleASM:Begin
              InternalGetIThreadsPool.ITMTaskAdd(tskMTSendCommand, VarArrayOf([_aaVarASMId, cmdEPack,{cmdEPack} _aaPD,{пакет команд} vlSendEventInterval, vlSendEventAttempt]),
                                                                    CallerAction{SenderParams}{vPlaceData, _aSecurityContext});
            End;
            smdViaBridge:Begin
              //DataCase.ITMTaskAdd(tskMTSendCommandViaBridge, VarArrayOf([_aaPD[Protocols_PD_PlaceData][iCurrNum]{ID Node}, cmdEPack,{cmdEPack} _aaPD,{пакет команд} vlSendEventInterval, vlSendEventAttempt]), SenderParams{vPlaceData}, _aSecurityContext);
              tmplV:=Unassigned;
              tmplPtr:=nil;
              tmplI{ID Node}:=_aaPD[Protocols_PD_PlaceData][iCurrNum]; // ID Node
              // Назначаю параметры.
             _TransportError:=False;
             _iErrMess:='';
             tmpHelpContext:=0;
              // Пробую отправить
              try
                Repeat
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
                        If ((Integer(tmplV[4]) and msk_rsBridge)=msk_rsBridge)And(tmplI{ID Node}=INodeInfo(cnTray.Query(INodeInfo)).ID{vlEAMServerLocalBaseID}{ID Node}) Then begin
                          // Это мост
                          // Пробую отправить через этот мост ITSendCommand/ITSendEvent
                          Case tmplPtr.ITSendCommand(cmdEPack, _aaPD{пакет команд}, CallerAction.SecurityContext, vlWiatForUnLockSendEvent, False{ShowSendPackMess}) of
                            tslError  : raise exception.Create('Неизвестная ошибка(tslError).');
                            tslTimeOut: raise exception.Create('Мост занят.');
                            tslOk     : begin
                              // Удалось отправить снимаю все ошибки которые были, т.к. теперь они не нужны.
                              try
                                CallerAction.ITMessAdd(Now, _iStratNow, ClassName+'#'+IntToStr(Integer(tmplV[0])), 'Command(bridge='+VarToStr(tmplI{ID Node})+'): PD(ID='''+VarToStr(PDID)+''')', mecTransport, mesInformation);
                              except end;
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
                Until False;
                If _TransportError Then begin
                  // Событие не отправлено была транспортная ошибка.
                  try
                    CallerAction.ITMessAdd(Now, _iStratNow, ClassName, 'Command(Bridge='+VarToStr(tmplI{ID Node})+'): PD(ID='''+VarToStr(PDID)+''')', mecTransport, mesError);
                  except end;
                  If Assigned(OnTransportError) Then OnTransportError(Self, _iErrMess, tmpHelpContext, Unassigned) else
                    TransportError(_iErrMess, tmpHelpContext, Unassigned);
                  //!! Уведомление о ошибках
                end;
              Except on E:Exception do begin
                e.message:='Неизвестная ошибка при отправке PD(smdViaBridge): '+e.message;
                Raise;
              end;end;
            End;
            smdForListOfASM:Begin
              Raise Exception.Create('Не реализовано.');
            End;
          else
            Raise Exception.Create('Неизвестное значение _aSendMode.');
          End;
        finally
          // навсякий случай чищу сам
          VarClear(_aaPD);
          VarClear(tmplV);
        end;
{$ENDIF}
      Except On E:Exception do begin
        e.message:='SendCommandOnID: '+e.message;
        Raise;
      end;End;
    end;             {_aaSendEvent, _aaSendToAll:Boolean;}  {_aaUser:AnsiString;} 
  Function MacroSend(_aaPlace:TPlace; Const _aaPlaceData:Variant; Const _aaPD:Variant):integer;
    Var tmplV:Variant;
        tmplPtr:pointer;
        tmplInt64_pd, tmplInt64:T64bit;
        tmpIUnknown:IUnknown;
        tmpIStringset:IStringset;
    begin
      Result:=0;
      Try
        //If Gl_DataCase=Nil then Raise Exception.Create('DataCase is not assigned.');
        tmplV:=Unassigned;
        Repeat
          If (VarType(tmplV) and varArray)=varArray Then tmplPtr:=Pointer(Integer(tmplV[5]))
            else tmplPtr:=nil;
          tmplV:=InternalGetIAdmittanceASM.GetInfoNextASMAndNoLock(tmplPtr);
          // ..
          If (VarType(tmplV) and varArray)=varArray Then begin
            // если что то взялось
            Case _aaPlace of
              pdsEventOnUser:begin
                If Uppercase(AnsiString(tmplV[1]))=Uppercase(VarToStr(_aaPlaceData)) then begin
                  Inc(Result);
                  SendEventOnID(_aaPD, Integer(tmplV[0]), smdSingleASM{, SecurityContext});
                end;
              end;
              pdsCommandOnUser:begin
                If Uppercase(AnsiString(tmplV[1]))=Uppercase(VarToStr(_aaPlaceData)) then begin
                  Inc(Result);
                  SendCommandOnID(_aaPD, Integer(tmplV[0]), smdSingleASM{, SecurityContext});
                end;
              end;
              pdsEventOnAll:begin
                Inc(Result);
                SendEventOnID(_aaPD, Integer(tmplV[0]), smdSingleASM{, SecurityContext});
              end;
              pdsCommandOnAll:begin
                Inc(Result);
                SendCommandOnID(_aaPD, Integer(tmplV[0]), smdSingleASM{, SecurityContext});
              end;
              pdsEventOnMask:begin
                tmplInt64.ofDouble:=Double(tmplV[8]);
                tmplInt64_pd.ofDouble:=Double(_aaPlaceData);
                If (tmplInt64.ofInt64 And tmplInt64_pd.ofInt64)<>0 then begin
                  Inc(Result);
                  SendEventOnID(_aaPD, Integer(tmplV[0]), smdSingleASM{, SecurityContext});
                end;
              end;
              pdsCommandOnMask:begin
                tmplInt64.ofDouble:=Double(tmplV[8]);
                tmplInt64_pd.ofDouble:=Double(_aaPlaceData);
                If (tmplInt64.ofInt64 and tmplInt64_pd.ofInt64)<>0 then begin
                  Inc(Result);
                  SendCommandOnID(_aaPD, Integer(tmplV[0]), smdSingleASM{, SecurityContext});
                end;
              end;
              pdsEventOnNameMask:begin
                tmpIUnknown:=tmplV[9];
                If assigned(tmpIUnknown) Then begin
                  If (tmpIUnknown.QueryInterface(IStringset, tmpIStringset)<>S_OK)Or(not assigned(tmpIStringset)) Then Raise Exception.Create('IStringset is not found.');
                  If tmpIStringset.ITExist(VarToStr(_aaPlaceData)) Then begin
                    Inc(Result);
                    SendEventOnID(_aaPD, Integer(tmplV[0]), smdSingleASM{, SecurityContext});
                  end;
                end;
              end;
              pdsCommandOnNameMask:begin
                tmpIUnknown:=tmplV[9];
                If assigned(tmpIUnknown) Then begin
                  If (tmpIUnknown.QueryInterface(IStringset, tmpIStringset)<>S_OK)Or(not assigned(tmpIStringset)) Then Raise Exception.Create('IStringset is not found.');
                  If tmpIStringset.ITExist(VarToStr(_aaPlaceData)) Then begin
                    Inc(Result);
                    SendCommandOnID(_aaPD, Integer(tmplV[0]), smdSingleASM{, SecurityContext});
                  end;
                end;
              end;    
            else
              Raise Exception.Create('Неизвестное значение _aaPlace.');
            end;
          end else begin
            // Кончились
            Break;
          end;
        Until False;
      Except On E:Exception do begin
        e.message:='MacroSend: '+e.message;
        Raise;
      end;End;
    end;
  Var tmpSt:AnsiString;
begin
Try
  iCurrNum:=Data[Protocols_PD_CurrNum];
  iCurrPlace:=Data[Protocols_PD_Place][iCurrNum];
(*  // Сразу готовлю параметр PlaceData для TaskAdd.
  If (Options And Protocols_PD_Options_WithNotificationOfError)=Protocols_PD_Options_WithNotificationOfError Then begin
    // требуется уведомление о ошибках во время прохождения пакета;
    If (Options And Protocols_PD_Options_ReturnDataIfTransportError)=Protocols_PD_Options_ReturnDataIfTransportError Then begin
      // требуются обратно данные
      vPlaceData:=VarArrayOf([rstSTNoASM, tsiNoPackID, ReverceRoute(Data[Protocols_PD_Data], popError), Integer(tskADMNone)]);
    end else begin
      // не требуются обратно данные
      vPlaceData:=VarArrayOf([rstSTNoASM, tsiNoPackID, ReverceRoute(Unassigned, popError), Integer(tskADMNone)]);
    end;
  end else begin
    // не требуется уведомление о ошибках во время прохождения пакета;
    vPlaceData:=Unassigned;
  end;*)
  // ..
  Case iCurrPlace of
    // все комманды прерываемые, т.е. - "один сервер, один шаг".
    // развернутая команда(готовая к выполнению)
    pdsEventOnID:begin
      //            Data  Route   AsmId
      SendEventOnID(Data, Data[Protocols_PD_PlaceData][iCurrNum], smdSingleASM{, SecurityContext});
    end;
    pdsCommandOnID:begin
{$IFDEF PegasServer}
      Raise Exception.Create('pdsCommandOnID для ''PegasServer'' неприменима.');
{$ELSE}
      SendCommandOnID(Data, Data[Protocols_PD_PlaceData][iCurrNum], smdSingleASM{, SecurityContext});
{$ENDIF}
    end;
    // не развернутая
    pdsEventOnUser:begin
      If MacroSend(iCurrPlace, Data[Protocols_PD_PlaceData][iCurrNum], Data)<1 Then
      //If MacroSend(True, False, Data, AnsiString(Data[Protocols_PD_PlaceData][iCurrNum]))<1 Then
        Raise Exception.Create('Не удается отправить pdsEventOnUser.ASM не найден.');
    end;
    pdsCommandOnUser:begin
{$IFDEF PegasServer}
      Raise Exception.Create('pdsCommandOnUser для ''PegasServer'' неприменима.');
{$ELSE}
      If MacroSend(iCurrPlace, Data[Protocols_PD_PlaceData][iCurrNum], Data)<1 Then
      //If MacroSend(False, False, Data, AnsiString(Data[Protocols_PD_PlaceData][iCurrNum]))<1 Then
        Raise Exception.Create('Не удается отправить pdsCommandOnUser.ASM не найден.');
{$ENDIF}
    end;
    pdsEventOnAll:begin
      If MacroSend(iCurrPlace, Data[Protocols_PD_PlaceData][iCurrNum], Data)<1 Then
      //If MacroSend(True, True, Data, '')<1 Then
        Raise Exception.Create('Не удается отправить pdsEventOnAll.ASM не найден.');
    end;
    pdsCommandOnAll:begin
{$IFDEF PegasServer}
      Raise Exception.Create('pdsCommandOnAll для ''PegasServer'' неприменима.');
{$ELSE}
      If MacroSend(iCurrPlace, Data[Protocols_PD_PlaceData][iCurrNum], Data)<1 Then
      //If MacroSend(False, True, Data, '')<1 Then
        Raise Exception.Create('Не удается отправить pdsCommandOnAll.ASM не найден.');
{$ENDIF}
    end;
    // Bidge
    pdsEventOnBridge:begin
      SendEventOnID(Data, -1, smdViaBridge{, SecurityContext});
    end;
    pdsCommandOnBridge:begin
{$IFDEF PegasServer}
      Raise Exception.Create('pdsCommandOnBridge для ''PegasServer'' неприменима.');
{$ELSE}
      SendCommandOnID(Data, -1, smdViaBridge{, SecurityContext});
{$ENDIF}
    end;
    pdsEventOnMask{9}:begin
      If MacroSend(iCurrPlace, Data[Protocols_PD_PlaceData][iCurrNum], Data)<1 Then begin
        try
          tmpI64.ofDouble:=Double(Data[Protocols_PD_PlaceData][iCurrNum]);
        except
          Raise Exception.Create('Не удается отправить pdsEventOnMask(?). ASM не найден.');
        end;
        Raise Exception.Create('Не удается отправить pdsEventOnMask('+IntToStr(tmpI64.ofInt64)+'). ASM не найден.');
      end;
    end;
    pdsCommandOnMask{10}:begin
{$IFDEF PegasServer}
      Raise Exception.Create('pdsCommandOnMask для ''PegasServer'' неприменима.');
{$ELSE}
      If MacroSend(iCurrPlace, Data[Protocols_PD_PlaceData][iCurrNum], Data)<1 Then
      //If MacroSend(True, False, Data, AnsiString(Data[Protocols_PD_PlaceData][iCurrNum]))<1 Then
        Raise Exception.Create('Не удается отправить pdsCommandOnMask. ASM не найден.');
{$ENDIF}
    end;
    pdsEventOnNameMask{11}:begin
      If MacroSend(iCurrPlace, Data[Protocols_PD_PlaceData][iCurrNum], Data)<1 Then begin
        try
          tmpSt:=VarToStr(Data[Protocols_PD_PlaceData][iCurrNum]);
        except
          Raise Exception.Create('Не удается отправить pdsEventOnNameMask(?). ASM не найден.');
        end;
        Raise Exception.Create('Не удается отправить pdsEventOnNameMask('+tmpSt+'). ASM не найден.');
      end;
    end;
    pdsCommandOnNameMask{12}:begin
{$IFDEF PegasServer}
      Raise Exception.Create('pdsCommandOnNameMask для ''PegasServer'' неприменима.');
{$ELSE}
      If MacroSend(iCurrPlace, Data[Protocols_PD_PlaceData][iCurrNum], Data)<1 Then Raise Exception.Create('Не удается отправить pdsCommandOnNameMask. ASM не найден.');
{$ENDIF}
    end;
  else
    raise exception.create('Неизвестное значение PR_Place='+IntToStr(Integer(iCurrPlace))+'.');
  end;
Except
  On E:Exception do begin
    e.message:='IHop1: '+e.message;
    Raise; 
  end;
End;
end;

Procedure TPDServer.TransportError(Const aMessage:Ansistring; aHelpContext:Integer; Const aRes:Variant);
  Var tmpLocalDataBase:ILocalDataBase;
      tmpPersistentMode:TPersistentMode;
      tmpStartNow, iWakeUpDateTime:TDateTime;
begin
  tmpStartNow:=Now;
  try
    If (Options and Protocols_PD_Options_NoPutOnReSending)=Protocols_PD_Options_NoPutOnReSending{64} then begin//Установлен флаг Protocols_PD_Options_NoPutOnReSending.//(1) - не ставить на переотправку. Это значит если будет транспортная ошибка, пакет вернется с ней к отправителю.
      Raise Exception.Create('NoPutOnReSending: '+aMessage);
    end else begin//Не установлен флаг Protocols_PD_Options_NoPutOnReSending.//(0)-в случае транспортной ошибки ставит в очередь на доотправку.
      try
        tmpLocalDataBase:=TLocalDataBase.Create;
        try//tmpLocalDataBase работает в tmpStrQueue.QueuePop => назначаю ему SecurityContext задания tskMTRunServerProc.
          tmpLocalDataBase.CallerAction:=cnServerAction;// vServerSecurityContext для постановки в очередь
          tmpLocalDataBase.LockListTimeOut:=200000{3min20sec}; {Время в течение которого пытается захватить лок при постановки в очередь.}
          //Устанавливаю PersistentMode 3x500, для того что бы увеличить вероятность успешной записи.
          tmpPersistentMode.Count:=3;
          tmpPersistentMode.Interval:=500;
          tmpLocalDataBase.PersistentMode:=tmpPersistentMode;
          iWakeUpDateTime:=MSecsToDateTime(77000{1min}+DateTimeToMSecs(Now));
          try
            IStrQueue(cnTray.Query(IStrQueue)).QueuePush(tmpLocalDataBase, qidRePD, VarToStr(PDID), ClassName+'.TransportError', glVarArrayToString(Data){StrData}, aMessage{Commentary}, CallerAction.SenderParams{aSenderParams}, CallerAction.SecurityContext, iWakeUpDateTime{WakeUp});
          except on e:Exception do begin
            e.message:='Push: '+e.message;//!! При этой ошибке теряется пакет который не должен быть потерян!!
            raise;
          end;end;
          try
            CallerAction.ITMessAdd(tmpStartNow, now, ClassName, 'PD(ID='''+VarToStr(PDID)+''') is set on resending(RePD/Wakeup='''+FormatDateTime('ddmmyy hh:nn:ss.zzz ',iWakeUpDateTime)+''').', mecTransport, mesInformation);
          except end;
        finally
          tmpLocalDataBase:=Nil;
        end;
      except on e:exception do begin
        ILogFile(cnTray.Query(ILogFile)).ITWriteLnToLog(#13#10'ERROR: TPDServer.TransportError(aMess='''+aMessage+'''): Queue(Пакет потерян): '+e.message{+'(Pack='''+?tmpVarArrayString.VarArrayToString(Data)+''').'});
        e.message:='Queue(Пакет потерян): '+e.message;
        raise;
      end;end;
    end;
  Except On E:Exception do begin
    CallerAction.ITMessAdd(tmpStartNow, now, ClassName, 'TransportError(PDID='''+VarToStr(PDID)+'''): '+e.message, mecTransport, mesError);
    e.message:=ClassName+'.TransportError: '+e.message;
    raise;
  end;end;
end;

function TPDServer.InternalGetIThreadsPool:IThreadsPool;
begin
  if not assigned(FThreadsPool) then cnTray.Query(IThreadsPool, FThreadsPool);
  result:=FThreadsPool;
end;

function TPDServer.InternalGetIAdmittanceASM:IAdmittanceASM;
begin
  if not assigned(FAdmittanceASM) then cnTray.Query(IAdmittanceASM, FAdmittanceASM);
  result:=FAdmittanceASM;
end;

end.
