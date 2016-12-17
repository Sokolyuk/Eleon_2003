unit UTaskImplementServerUtilsUtils;

interface
  uses UTTaskTypes, UCallerTypes, UTaskImplementTypes;

  function TaskImplementServerUtils(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;

implementation
  uses Sysutils, UThreadsPoolTypes, UTrayConsts, UErrorConsts, UTTaskUtils, UServerProcUtils,
       Variants, UBlockSQLExec
{$ifdef EAMServer}
       , UAS, UASMConsts, UAdmittanceASMTypes
{$endif}
{$IFDEF PegasServer}
       , UTableCommandMaster
{$ENDIF}
       ;
function TaskImplementServerUtils(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;
{$ifdef EAMServer}
  var tmpAdmittanceASM:IAdmittanceASM;
  function localGetAdmittanceASM:IAdmittanceASM; begin
    if not assigned(tmpAdmittanceASM) then cnTray.Query(IAdmittanceASM, tmpAdmittanceASM);
    result:=tmpAdmittanceASM;
  end;
{$endif}
  function lacalGetRaramsForServerProc(Const aParam1:Variant):Variant; begin
    result:=aParams;
    result[1]:=aParam1;
  end;
  var tmpThreadsPool:IThreadsPool;
  function localGetThreadsPool:IThreadsPool;begin
    if not assigned(tmpThreadsPool) then cnTray.Query(IThreadsPool, tmpThreadsPool);
    result:=tmpThreadsPool;
  end;
{$IFDEF PegasServer}
  var tmpTableCommandMaster:TTableCommandMaster;
      tmpI:Integer;
{$ENDIF}
  var tmpV:Variant;
      tmpBlockSQLExec:TBlockSQLExec;
{$ifdef EAMServer}
      tmpPtr:TEAMServer;
{$endif}
begin
  result:=true;
  //tmpStartTime:=now;
  case aTask of
    tskMTTableCommand:begin//In MyParams: [0]-varVariant:(PD); [1]-varInteger:(interval)
{$IFDEF PegasServer}
      Try
        tmpTableCommandMaster:=TTableCommandMaster.Create;
        try
          tmpTableCommandMaster.CallerAction:=aCallerAction;
          While True do begin
            tmpTableCommandMaster.Exec;
            If tmpTableCommandMaster.ResultCount<1 Then Break;
            For tmpI:=0 to tmpTableCommandMaster.ResultCount-1 do begin
              localGetThreadsPool.ITMTaskAdd(tskMTPD, tmpTableCommandMaster.Result[tmpI], aCallerAction);
            end;
            Sleep(1000);
          end;
        finally
          FreeAndNil(tmpTableCommandMaster);
        end;
      Finally//—тавлю на выполнение
        localGetThreadsPool.ITMSleepTaskAdd(tskMTTableCommand, aParams, aCallerAction, Integer(aParams[1]), aTaskContext^.aTaskID, @aTaskContext^.aTaskID);
      end;
{$ELSE}
      Raise Exception.Create(' оманда не применима дл€ EMServer.');
{$ENDIF}
    end;//Out Res: Empty
    tskMTBlockSQLExec:begin//In MyParams: [0]-varInteger:(tmpBlockId); [1]-varArray:([0]-Id SQL Command;[1]-tmpBlock:[0..n]-varOleStr:(SQLCommand); [2]-varVariant:(SQLParams));          ???[2]-varInteger:(Option CPT)
      tmpBlockSQLExec:=TBlockSQLExec.Create;
      try
        tmpBlockSQLExec.Data:=aParams;
        tmpBlockSQLExec.CallerAction:=aCallerAction;
        tmpBlockSQLExec.Exec;
        If tmpBlockSQLExec.BuildResult Then begin//≈сть результат выполнени€
          If assigned(aTaskContext) then begin
            if assigned(aTaskContext^.aResult) then aTaskContext^.aResult^:=tmpBlockSQLExec.Result;
            aTaskContext^.aSetResult:=true;
            aTaskContext^.aManualResultSet:=false;//разрешаю автоматическую отработку SetComplete??
          end;
        end;
        If tmpBlockSQLExec.NextTimeRequire Then begin//ќстались команды с более позднем временем выполнени€//—тавлю на повторное выполнение
          localGetThreadsPool.ITMWakeUpTaskAdd(tskMTBlockSQLExec, tmpBlockSQLExec.NextTimeData, aCallerAction, TimeStampToDateTime(MSecsToTimeStamp(tmpBlockSQLExec.NextTimeWakeup)), aTaskContext^.aTaskID, @aTaskContext^.aTaskID);
        end;
      finally
        FreeAndNil(tmpBlockSQLExec);
      end;
    end;//Out Res: Empty
    tskMTExecServerProc:begin//In MyParams: [0]-varString:(ServerProcName); [1]-varVariant:(Params); [2]-varInteger:(Interval)
      try
        tmpV:=aParams[1];
        ServerProcExec(aCallerAction, VarToStr(aParams[0]), tmpV, nil);
      finally
        If (VarArrayHighBound(aParams, 1)=2)And(VarType(aParams[2])=varInteger) Then begin//—тавлю на повторное выполнение
          localGetThreadsPool.ITMSleepTaskAdd(tskMTExecServerProc, lacalGetRaramsForServerProc(tmpV), aCallerAction, Integer(aParams[2]), aTaskContext^.aTaskID, @aTaskContext^.aTaskID);
        end;
      end;
    end;
    tskMTSyncTime:begin
{$IFDEF PegasServer}
      Raise Exception.Create(' оманда tskMTSyncTime не применима дл€ PegasServer.');
{$ELSE}
      tmpV:=Unassigned;
      Repeat
        If VarIsArray(tmpV) Then tmpPtr:=Pointer(Integer(tmpV[5])) else tmpPtr:=nil;
        tmpV:=localGetAdmittanceASM.GetInfoNextASMAndLock(tmpPtr);
        If VarIsArray(tmpV) Then begin
          try//если что то вз€лось значит и залочилось
            tmpPtr:=Pointer(Integer(tmpV[5]));
            If (Integer(tmpV[4]) and msk_rsBridge)=msk_rsBridge Then begin
              try
                tmpPtr.ITSyncTime;
                break;
              except end;
            End;
          finally
            localGetAdmittanceASM.UnLock(tmpPtr);
          end;
        end else Break;
      Until False;
{$ENDIF}
    end;
    tskMTSleepRunner:begin//In MyParams: [0]-Time interval, [1]-tskMTxxx, [2]-Params
      try
        localGetThreadsPool.ITMTaskAdd(TTask(Integer(aParams[1])), aParams[2], aCallerAction, aTaskContext^.aTaskID, @aTaskContext^.aTaskID);
      finally//—тавлю на повторное выполнение
        localGetThreadsPool.ITMSleepTaskAdd(tskMTSleepRunner, aParams, aCallerAction, Integer(aParams[0]), aTaskContext^.aTaskID, @aTaskContext^.aTaskID);
      end;
    end;//Out Res: Empty
  else
    if aRaise then Raise Exception.CreateFmtHelp(cserInternalError, ['Unsupported for '+MTaskToStr(aTask)], cnerInternalError) else result:=false;
  end;
end;

end.
