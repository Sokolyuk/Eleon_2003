unit UPackCPTUtilsTypes;

interface
  uses UPackCPTTypes, UPackCPTaskTypes, UPackPDTypes, UADMTypes, UPackTypes{$IFDEF VER130}, UVer130Types{$ENDIF};
type
  TCheckSecurityADMTaskCPTTaskEvent=function(aUserData:Pointer; aTask:TADMTask; aPackID:TPackID; const aSecurityContext:Variant):boolean{worked} of object;
  TReceiveCPTTaskEvent=function(aUserData:Pointer; aPackPD:IPackPD; aPackCPT:IPackCPT; aPackCPTask:IPackCPTask; aSetResult:PBoolean; aResult:PVariant):boolean{worked} of object;
  IReceiveCPTTask=interface
  ['{E73F74CB-8EF6-40D8-BEB0-0C11E654EBF8}']
    function ReceiveCheckSecurityADMCPTTask(aUserData:Pointer; aTask:TADMTask; aPackID:TPackID; const aSecurityContext:Variant):boolean{worked};
    function ReceiveCPTTask(aUserData:Pointer; aPackPD:IPackPD; aPackCPT:IPackCPT; aPackCPTask:IPackCPTask; aSetResult:PBoolean; aResult:PVariant):boolean{worked};
  end;

  PExecuteCPTStruct=^TExecuteCPTStruct;
  TExecuteCPTStruct=record
    aUserData:Pointer;
    OnCheckSecurityADMTaskCPTTask:TCheckSecurityADMTaskCPTTaskEvent;
    OnReceiveCPTTask:TReceiveCPTTaskEvent;
  end;

implementation

end.
