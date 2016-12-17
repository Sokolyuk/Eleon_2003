//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTaskImplementESC;

interface
  uses UTaskImplement, UTTaskTypes, UCallerTypes, UTaskImplementTypes;
type
  TTaskImplementESC=class(TTaskImplement)
  protected
    function InternalGetInitGUIDCount:Cardinal;override;
    procedure InternalInitGUIDList;override;
  public
    function TaskImplement(aCallerAction:ICallerAction; aTask:TTask; const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;override;
  end;

implementation
  uses UTaskImplementUtils, UTaskImplementMThreadUtils, UTaskImplementTaskUtils, {UTaskImplementBfUtils,}
       UAppMessageTypes, UTaskImplementExecPackESCUtils, UTaskImplementEQueryInterfaceUtils;

function TTaskImplementESC.InternalGetInitGUIDCount:Cardinal;
begin
  result:=inherited InternalGetInitGUIDCount+1;
end;

procedure TTaskImplementESC.InternalInitGUIDList;
  var tmpInhCnt:Cardinal;
begin
  inherited InternalInitGUIDList;
  tmpInhCnt:=inherited InternalGetInitGUIDCount;
  GUIDList^.aList[tmpInhCnt]:=IAppMessage;
end;

function TTaskImplementESC.TaskImplement(aCallerAction:ICallerAction; aTask:TTask; const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;
begin
  if (aTask and tskMTBankMask)=0 then aTask:=MTBank0ToMTBankN(aTask);
  case (aTask and tskMTBankMask) of
    tskMTBank_MThread:result:=TaskImplementMThread(aCallerAction, aTask, aParams, aTaskContext, false{aRaise});
    tskMTBank_Task:result:=TaskImplementTask(aCallerAction, aTask, aParams, aTaskContext, false{aRaise});//IThreadsPool
    //tskMTBank_Bf:result:=TaskImplementBf(aCallerAction, aTask, aParams, aTaskContext, false{aRaise});
    tskMTBank_ExecPack:result:=TaskImplementExecPackESC(aCallerAction, aTask, aParams, aTaskContext, false{aRaise});
    tskMTBank_EQueryInterface:result:=TaskImplementEQueryInterface(aCallerAction, aTask, aParams, aTaskContext, false{aRaise});
    //tskMTBank_ShotDownServer:result:=TaskImplementShotDownServer(aCallerAction, aTask, aParams, aTaskContext, false{aRaise});//IServerProperties/IAppMessage/IThreadsPool
    //tskMTBank_Reload:result:=TaskImplementReload(aCallerAction, aTask, aParams, aTaskContext, false{aRaise});//IAppSecurity/ILocalDataBaseTriggers/IThreadsPool/IServerProcedures
  else
    result:=false;
  end;
  if not result then result:=inherited TaskImplement(aCallerAction, aTask, aParams, aTaskContext, true{aRaise});
end;

end.
