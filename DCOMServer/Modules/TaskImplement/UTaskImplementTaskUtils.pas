//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTaskImplementTaskUtils;

interface
  uses UTTaskTypes, UCallerTypes, UTaskImplementTypes;

  function TaskImplementTask(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;

implementation
  uses UTrayConsts, Sysutils, UErrorConsts{$IFNDEF VER130}, Variants{$ENDIF}, UTTaskUtils, UThreadsPoolTypes;

function TaskImplementTask(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;
  var tmpBoolean:Boolean;
begin
  result:=true;
  case aTask of
    tskMTCancelTask:begin//In MyParams: varInteger(TaskID);
      tmpBoolean:=IThreadsPool(cnTray.Query(IThreadsPool)).ITMTaskCancel(aParams);
      If assigned(aTaskContext) then begin
        if assigned(aTaskContext^.aResult) then aTaskContext^.aResult^:=tmpBoolean;
        aTaskContext^.aSetResult:=true;
        aTaskContext^.aManualResultSet:=false;//разрешаю автоматическую отработку SetComplete??
      end;
    end;//Out Res: varBoolean(Canceled or no)
    tskMTIgnoreTaskAdd:begin//In aParams: varInteger(TaskID);
      IThreadsPool(cnTray.Query(IThreadsPool)).ITMIgnoreTaskAdd(aParams);
    end;//Out Res: Empty
    tskMTIgnoreTaskCancel:begin//In aParams: varInteger(TaskID);
      tmpBoolean:=IThreadsPool(cnTray.Query(IThreadsPool)).ITMIgnoreTaskCancel(aParams);
      If assigned(aTaskContext) then begin
        if assigned(aTaskContext^.aResult) then aTaskContext^.aResult^:=tmpBoolean;
        aTaskContext^.aSetResult:=true;
        aTaskContext^.aManualResultSet:=false;//разрешаю автоматическую отработку SetComplete??
      end;
    end;//Out Res: varBoolean(Canceled or no)
  else
    if aRaise then Raise Exception.CreateFmtHelp(cserInternalError, ['Unsupported for '+MTaskToStr(aTask)], cnerInternalError) else result:=false;
  end;
end;

end.
 