//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTaskImplementTypes;

interface
  uses UTTaskTypes, UCallerTypes, UCallerTaskTypes, UCallerTaskPathTypes;
type
  PTaskContext=^TTaskContext;
  TEndTaskComplete=procedure(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext);
  TEndTaskError=procedure(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; const aMessage:AnsiString; aHelpContext:Integer);
  TEndTaskCanceled=procedure(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext);
  PEndTaskEvent=^TEndTaskEvent;
  TEndTaskEvent=record
    aOnComplete:TEndTaskComplete;
    aOnError:TEndTaskError;
    aOnCanceled:TEndTaskCanceled;
  end;
  IEndTaskEvent=interface
  ['{910D6AFD-A9B5-432F-B9A3-9D444251A764}']
    procedure EndTaskComplete(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext);
    procedure EndTaskError(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; const aMessage:AnsiString; aHelpContext:Integer);
    procedure EndTaskCanceled(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext);
  end;
  ITaskImplement=interface
  ['{B0127814-0895-4AAB-9652-081A46ABA58B}']
    procedure TasksImplements(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext);
  end;
  TExceptionMode=(exmNormal, exmPDTransport);
  TTaskContext=record
    aTaskID:Integer;{def=-1}{RW}
    aExceptionMode:TExceptionMode;{def=exmNormal}{RW}
    aPackToCPR:Boolean;{def=true}{RW}
    aManualResultSet:Boolean;{def=true}{RW}
    aSetResult:Boolean;{def=false}{RW}
    aResult:PVariant;{def=nil}{RW}
    aCallerTask:ICallerTask;{def=nil}//Назначаются в TaskAdd
    aEndTaskEventI:IEndTaskEvent;{def=nil}//Назначаются в TaskAdd
    aEndTaskEvent:PEndTaskEvent;{def=nil}//Назначаются в TaskAdd
    aCallerTaskPath:ICallerTaskPath;{def=nil}{RW}//создается в TasksImplements для рекурсивного вызова, вслучае нескольких задач. Назначать при вызове не нужно.
    aConnectionName:AnsiString;
  end;
const
  cnDefTaskContext:TTaskContext=(aTaskID:-1; aExceptionMode:exmNormal; aPackToCPR:true; aManualResultSet:true; aSetResult:false; aResult:nil; aCallerTask:nil; aEndTaskEventI:nil; aEndTaskEvent:nil; aCallerTaskPath:nil; aConnectionName:'');//default or nil

implementation

end.
