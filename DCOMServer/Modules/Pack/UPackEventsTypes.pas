unit UPackEventsTypes;

interface
  Uses UADMTypes, UPackTypes, UPackCPRTypes;
Type
  //Events Protocol Detector
  TReceivProtocolEvent=function(aProtocolDetector:TObject{Pointer}{TProtocolDetector}; Const aData:Variant):Variant of object;
  //Events Place Data
  TReceivedCPEvent=Function(aPD:TObject{Pointer}{TPD}; out aBuildResult:Boolean; Const aData:Variant):Variant of object;
  TTransportErrorEvent=Procedure(aPD{TPD}:TObject{Pointer}; Const aMessage:AnsiString; aHelpContext:Integer; Const aRes:Variant) of object;
  //Events Command Pack.
  TReceiveCPT1Event=Procedure(aCommandPack:TObject{Pointer}{TCommandPack}; aPackCPR{ManageCPT1}{aManageCPR1}:IPackCPR{TObject}{Pointer}{TManageCPR1}; Const aPDID:Variant; Const aCPID:Variant; aBlockID:Integer; aCPTask:TADMTask; aPos:Integer; Const aParams:Variant; Const aRouteParams:Variant) of object;
  TReceiveCPT1ErrorEvent=Procedure(aCommandPack:TObject{Pointer}{TCommandPack}; aPackCPR{ManageCPT1}{aManageCPR1}:IPackCPR{TObject}{Pointer}{TManageCPR1}; Const aPDID:Variant; Const aCPID:Variant; aBlockID:Integer; aCPTask:TADMTask; aPos:Integer; Const aMessage:AnsiString; aHelpContext:Integer; Const aRouteParam:Variant) of object;
  TReceiveCPR1Event=Procedure(aCommandPack:TObject{Pointer}{TCommandPack}; Const aPDID:Variant; Const aCPID:Variant; aBlockID:Integer; aCPTask:TADMTask; aPos:Integer; Const aParams:Variant; Const aRouteParams:Variant) of object;
  TReceiveCPR1ErrorEvent=Procedure(aCommandPack:TObject{Pointer}{TCommandPack}; Const aPDID:Variant; Const aCPID:Variant; aBlockID:Integer; aCPTask:TADMTask; aPos:Integer; Const aMessage:AnsiString; aHelpContext:Integer; aResultWithError:Boolean; Const aRouteParam:Variant) of object;
  TCheckSecurityPTaskEvent=Procedure(aTask:TADMTask; aProtocolType:TProtocolType; Const aSecurityContext:Variant) of object;
  //TPackReceiver
  TEmptyEvent=Procedure of object;
  TExceptionEvent=Procedure(aObject:TObject{Pointer}; Const aMessage:AnsiString; aHelpContext:Integer) of object;

implementation

end.
