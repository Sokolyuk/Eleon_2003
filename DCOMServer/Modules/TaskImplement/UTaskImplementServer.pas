//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTaskImplementServer;

interface
  uses UTaskImplement, UTTaskTypes, UCallerTypes, UTaskImplementTypes;
type
  TTaskImplementServer=class(TTaskImplement)
  protected
    function InternalGetInitGUIDCount:Cardinal;override;
    procedure InternalInitGUIDList;override;
  public
    function TaskImplement(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;override;
  end;

implementation
  uses {UTaskImplementBfUtils, }UTTaskUtils, Sysutils, UErrorConsts, UTaskImplementMThreadUtils, UTaskImplementSendEventUtils,
       UNodeInfoTypes, UAdmittanceASMTypes, UThreadsPoolTypes, UAppMessageTypes, UTaskImplementASMUtils,
       UTaskImplementShotDownServerUtils, UTaskImplementTaskUtils, UTaskImplementOnLineUtils,
       UTaskImplementBridgeUtils, UTaskImplementReloadUtils, UAppSecurityTypes, ULocalDataBaseTriggersTypes,
       UServerProceduresTypes, UTaskImplementExecPackUtils, UStrQueueTypes, UServerInfoTypes, ULogFileTypes,
       UTaskImplementServerUtilsUtils, UTrayConsts, UTaskImplementUtils
       {$Ifdef EAMServer}, UServerOnlineTypes{$endif}, UTaskImplementEQueryInterfaceUtils;

function TTaskImplementServer.InternalGetInitGUIDCount:Cardinal;
begin
  result:=inherited InternalGetInitGUIDCount+9{$Ifdef EAMServer}+1{$endif};
end;

procedure TTaskImplementServer.InternalInitGUIDList;
  var tmpInhCnt:Cardinal;
begin
  inherited InternalInitGUIDList;
  tmpInhCnt:=inherited InternalGetInitGUIDCount;
  GUIDList^.aList[tmpInhCnt]:=IAdmittanceASM;
  GUIDList^.aList[tmpInhCnt+1]:=IAppMessage;
  GUIDList^.aList[tmpInhCnt+2]:=INodeInfo;
  GUIDList^.aList[tmpInhCnt+3]:=IAppSecurity;
  GUIDList^.aList[tmpInhCnt+4]:=IServerProcedures;
  GUIDList^.aList[tmpInhCnt+5]:=ILocalDataBaseTriggers;
  GUIDList^.aList[tmpInhCnt+6]:=IStrQueue;
  GUIDList^.aList[tmpInhCnt+7]:=IServerInfo;
  GUIDList^.aList[tmpInhCnt+8]:=ILogFile;
{$Ifdef EAMServer}
  GUIDList^.aList[InternalGetInitGUIDCount-1]:=IServerOnline;
{$endif}
end;

function TTaskImplementServer.TaskImplement(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;
begin
  if (aTask and tskMTBankMask)=0 then aTask:=MTBank0ToMTBankN(aTask);
  case (aTask and tskMTBankMask) of
    tskMTBank_MThread:result:=TaskImplementMThread(aCallerAction, aTask, aParams, aTaskContext, false{aRaise});
    tskMTBank_SendEvent:result:=TaskImplementSendEvent(aCallerAction, aTask, aParams, aTaskContext, false{aRaise});//IAdmittanceASM/IThreadsPool/IAppMessage
    tskMTBank_ASM:result:=TaskImplementASM(aCallerAction, aTask, aParams, aTaskContext, false{aRaise});
    tskMTBank_ShotDownServer:result:=TaskImplementShotDownServer(aCallerAction, aTask, aParams, aTaskContext, false{aRaise});//IServerProperties/IAppMessage/IThreadsPool
    tskMTBank_Task:result:=TaskImplementTask(aCallerAction, aTask, aParams, aTaskContext, false{aRaise});//IThreadsPool
    tskMTBank_OnLine:result:=TaskImplementOnLine(aCallerAction, aTask, aParams, aTaskContext, false{aRaise});
    tskMTBank_Bridge:result:=TaskImplementBridge(aCallerAction, aTask, aParams, aTaskContext, false{aRaise});
    tskMTBank_Reload:result:=TaskImplementReload(aCallerAction, aTask, aParams, aTaskContext, false{aRaise});//IAppSecurity/ILocalDataBaseTriggers/IThreadsPool/IServerProcedures
    tskMTBank_ExecPack:result:=TaskImplementExecPack(aCallerAction, aTask, aParams, aTaskContext, false{aRaise});//ILogFile/IServerInfo/IServerProperties
    tskMTBank_ServerUtils:result:=TaskImplementServerUtils(aCallerAction, aTask, aParams, aTaskContext, false{aRaise});
    //tskMTBank_Bf:result:=TaskImplementBf(aCallerAction, aTask, aParams, aTaskContext, false{aRaise});
    tskMTBank_EQueryInterface:result:=TaskImplementEQueryInterface(aCallerAction, aTask, aParams, aTaskContext, false{aRaise});
  else
    result:=false;
  end;
  if not result then result:=inherited TaskImplement(aCallerAction, aTask, aParams, aTaskContext, true{aRaise});
end;

end.
