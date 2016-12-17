//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTaskImplementMThreadUtils;

interface
  uses UTTaskTypes, UCallerTypes, UTaskImplementTypes;

  function TaskImplementMThread(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;
implementation
  uses Sysutils, UErrorConsts, UTTaskUtils{$IFNDEF VER130}, Variants{$ENDIF};

function TaskImplementMThread(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;
begin
  if assigned(aTaskContext) then begin
    aTaskContext^.aSetResult:=false;
    if assigned(aTaskContext^.aResult) then aTaskContext^.aResult^:=unassigned;
    aTaskContext^.aManualResultSet:=false;//разрешаю автоматическую отработку SetComplete??
  end;
  if aRaise then Raise Exception.CreateFmtHelp(cserInternalError, ['Unsupported for '+MTaskToStr(aTask)], cnerInternalError) else result:=false;
end;

end.
