unit UTaskImplementDMS;

interface
  uses UTaskImplement, UCallerTypes, UTTaskTypes, UTaskImplementTypes;
type
  TTaskImplementDMS=class(TTaskImplement)
  public
    function TaskImplement(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;override;
  end;

implementation
  uses UTaskImplementDcomManagerServer;

function TTaskImplementDMS.TaskImplement(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;
begin
  case (aTask and tskMTBankMask) of
   tskMTBank_DMS:result:=TaskImplementDcomManagerServer(aCallerAction, aTask, aParams, aTaskContext, false{aRaise});
  else
    result:=false;
  end;
  if not result then result:=inherited TaskImplement(aCallerAction, aTask, aParams, aTaskContext, true{aRaise});
end;


end.
