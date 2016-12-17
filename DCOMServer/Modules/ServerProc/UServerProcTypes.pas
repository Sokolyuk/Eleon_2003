unit UServerProcTypes;

interface
  uses UServerProcedureTypes, UCallerTypes{$IFDEF PegasServer}, Pegas_TLB{$ELSE}, EMServer_TLB{$ENDIF},
       UServerProceduresTypes, ULocalDataBaseTypes, ULocalDataBaseTriggersTypes;
type
  TServerProcEmptyEvent=Procedure of object;
  PServerProcExecParams=^TServerProcExecParams;
  TServerProcExecParams=record
    aServerProcedures:IServerProcedures;//�� ������������ ����
{$IFDEF PegasServer}
    aExternalASMServer:IAUPegas;//�� ������������ ����
{$ELSE}
    aExternalASMServer:IEAMServer;//�� ������������ ����
{$ENDIF}
    aOnBeforeCall:TServerProcEmptyEvent;//�� ������������ ����
    aOnAfterCall:TServerProcEmptyEvent;//�� ������������ ����
    aShowMessage:boolean;//�� ������������ ����
    aShowMessagePrefix:PAnsiString;//�� ������������ ���� def=nil;
    aLocalDataBase:ILocalDataBase;//�� ������������ ����
    aLocalDataBaseTriggerData:PTriggerData;//�� ������������ ����
  end;

implementation

end.
