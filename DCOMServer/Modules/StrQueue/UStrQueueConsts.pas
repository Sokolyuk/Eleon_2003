unit UStrQueueConsts;

interface
Const
  cnLDBMaxStrLength:Integer={$IFDEF PegasServer}8000{$ENDIF}{$IfDef EAMServer}255{$ENDIF};

implementation

end.
