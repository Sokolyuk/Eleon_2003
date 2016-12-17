unit UTaskImplementReloadUtils;

interface
  uses UTTaskTypes, UCallerTypes, UTaskImplementTypes;

  function TaskImplementReload(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;

implementation
  uses UTrayConsts, Sysutils, UErrorConsts, Variants, UTTaskUtils, UThreadsPoolTypes, UAppSecurityTypes,
       ULocalDataBase, ULocalDataBaseTypes, ULocalDataBaseTriggersTypes, UServerProceduresTypes;

function TaskImplementReload(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;
  var tmpString:AnsiString;
      tmpLocalDataBase:ILocalDataBase;
begin
  result:=true;
  case aTask of
    tskMTReloadSecurity:begin// In MyParams: Empty - tskMTReloadSecurity выполон€етс€ один раз.//              varInteger:(Interval)- интервал между запусками tskMTReloadSecurity.
      try
        IAppSecurity(cnTray.Query(IAppSecurity)).ITReloadSecurety;
      finally//—тавлю на повторное выполнение
        If VarType(aParams)=varInteger Then IThreadsPool(cnTray.Query(IThreadsPool)).ITMSleepTaskAdd(tskMTReloadSecurity, aParams, aCallerAction, Integer(aParams), aTaskContext^.aTaskID, @aTaskContext^.aTaskID);
      end;
    end;
    tskMTReloadTriggers:begin
      try
        tmpLocalDataBase:=TLocalDataBase.Create;
        Try
          tmpLocalDataBase.CallerAction:=aCallerAction;
          tmpLocalDataBase.CheckForTriggers:=False;
          tmpString:=ILocalDataBaseTriggers(cnTray.query(ILocalDataBaseTriggers)).ITReloadTriggers(tmpLocalDataBase);
          If tmpString<>'' Then Raise Exception.Create('Ignored: '+tmpString);
        finally
          tmpLocalDataBase:=Nil;
        end;
      finally//—тавлю на повторное выполнение
        If VarType(aParams)=varInteger Then IThreadsPool(cnTray.Query(IThreadsPool)).ITMSleepTaskAdd(tskMTReloadTriggers, aParams, aCallerAction, Integer(aParams), aTaskContext^.aTaskID, @aTaskContext^.aTaskID);
      end;
    end;
    tskMTServerProcedures:begin
      try
        IServerProcedures(cnTray.Query(IServerProcedures)).ITReload;
      finally//—тавлю на повторное выполнение
        If VarType(aParams)=varInteger Then IThreadsPool(cnTray.Query(IThreadsPool)).ITMSleepTaskAdd(tskMTServerProcedures, aParams, aCallerAction, Integer(aParams), aTaskContext^.aTaskID, @aTaskContext^.aTaskID);
      end;
    end;
  else
    if aRaise then Raise Exception.CreateFmtHelp(cserInternalError, ['Unsupported for '+MTaskToStr(aTask)], cnerInternalError) else result:=false;
  end;
end;

end.
 