unit UServerProcTypes;

interface
  uses UServerProcedureTypes, UCallerTypes{$IFDEF PegasServer}, Pegas_TLB{$ELSE}, EMServer_TLB{$ENDIF},
       UServerProceduresTypes, ULocalDataBaseTypes, ULocalDataBaseTriggersTypes;
type
  TServerProcEmptyEvent=Procedure of object;
  PServerProcExecParams=^TServerProcExecParams;
  TServerProcExecParams=record
    aServerProcedures:IServerProcedures;//не обязательное поле
{$IFDEF PegasServer}
    aExternalASMServer:IAUPegas;//не обязательное поле
{$ELSE}
    aExternalASMServer:IEAMServer;//не обязательное поле
{$ENDIF}
    aOnBeforeCall:TServerProcEmptyEvent;//не обязательное поле
    aOnAfterCall:TServerProcEmptyEvent;//не обязательное поле
    aShowMessage:boolean;//не обязательное поле
    aShowMessagePrefix:PAnsiString;//не обязательное поле def=nil;
    aLocalDataBase:ILocalDataBase;//не обязательное поле
    aLocalDataBaseTriggerData:PTriggerData;//не обязательное поле
  end;

implementation

end.
