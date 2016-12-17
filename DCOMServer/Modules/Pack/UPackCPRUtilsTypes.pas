unit UPackCPRUtilsTypes;
                                                               
interface
  uses UPackTypes, UADMTypes, UPackCPTaskTypes, UPackCPRTypes, UPackPDTypes;
type
  TCheckSecurityADMTaskCPRTaskEvent=function(aUserData:Pointer; aTask:TADMTask; aPackID:TPackID; const aSecurityContext:Variant):Boolean{worked} of object;
  TReceiveCPRTaskEvent=function(aUserData:Pointer; aPackPD:IPackPD; aPackCPR:IPackCPR; aPackCPTask:IPackCPTask):Boolean{worked} of object;
  TReceiveCPRTaskVEvent=function(aUserData:Pointer; const aCPID:Variant; aBlockID:Integer; aCPTask:TADMTask; aPos:Integer; const aParam:Variant):Boolean{worked} of object;
  TReceiveCPRTaskErrorEvent=function(aUserData:Pointer; aPackPD:IPackPD; aPackCPR:IPackCPR; aPackCPTask:IPackCPTask; const aMessage:AnsiString; aHelpContext:Integer):Boolean{worked} of object;
  TReceiveCPRTaskErrorVEvent=function(aUserData:Pointer; const aCPID:Variant; aBlockID:Integer; aCPTask:TADMTask; aPos:Integer; const aParam:Variant; const aMessage:AnsiString; aHelpContext:Integer; aResultWithError:Boolean):Boolean{worked} of object;

  IReceiveCPRTask=interface
  ['{5C7FA803-20BF-4FCB-9328-B40919E399A9}']
    function ReceiveCheckSecurityADMCPRTask(aUserData:Pointer; aTask:TADMTask; aPackID:TPackID; const aSecurityContext:Variant):Boolean{worked};
    function ReceiveCPRTask(aUserData:Pointer; aPackPD:IPackPD; aPackCPR:IPackCPR; aPackCPTask:IPackCPTask):boolean{worked};
    function ReceiveCPRTaskError(aUserData:Pointer; aPackPD:IPackPD; aPackCPR:IPackCPR; aPackCPTask:IPackCPTask; const aMessage:AnsiString; aHelpContext:Integer):Boolean{worked};
  end;

  PExecuteCPRStruct=^TExecuteCPRStruct;
  TExecuteCPRStruct=record
    aUserData:Pointer;
    OnCheckSecurityADMTaskCPRTask:TCheckSecurityADMTaskCPRTaskEvent;
    OnReceiveCPRTask:TReceiveCPRTaskEvent;
    OnReceiveCPRTaskV:TReceiveCPRTaskVEvent;
    OnReceiveCPRTaskError:TReceiveCPRTaskErrorEvent;
    OnReceiveCPRTaskErrorV:TReceiveCPRTaskErrorVEvent;
  end;

implementation

end.
