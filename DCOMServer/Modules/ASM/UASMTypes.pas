//Copyright � 2000-2003 by Dmitry A. Sokolyuk
unit UASMTypes;

interface
type
  //For ASM event
  TASMEvents = (evnOnMessage, evnOnPack);
  //For ASM commands
  TASMCommands = ({0}cmdEPack, {1}cmdEPing);
  //for ITSendEvent
  TTestLock=({0}tslOk, {1}tslError, {2}tslTimeOut);
type
  TLoginLevel=({0}llNone{Unknown-Reserved}, {1}llPGS{Base-SQL-Server}, {2}llEMS{Shop-EMS-LDB}, {3}llClient{Client});
{$IFDEF PegasServer}
type
  TASMState=Set of (rsTransaction, rsLogin, rsADMLogin, rsInitialization, rsReliableClient, rsBridge, rsKeepConnection);
{ asTransaction  - ����������� ����������
  asLogin        - ������������ ����������� }
{$ENDIF}
{$IfDef EAMServer}
type
  TASMState=Set of (rsNoSQL, rsNoCDS, rsNoCache, rsKeepConnection, rsKeepLocalConnection, rsNoConnection, rsRollBackOnEClose, rsTransaction, rsMServerLogin, rsPegasLogin, rsADMLogin, rsMServerOnLine, rsOpen, rsCheckRecordsAffectedOnApplyUpdates, rsBridge, rsBridgeReliable);
{ (!) ��� ����� ������������� ������ ��� �������� ASM (!)
   rsNoSQL            - ������ �� ������ SQL �������
   rsNoCDS            - ������ �� ��������� CDS
   rsNoCache          - ������ �� ����������� ������ (������ ����������������� �� �������)
   rsKeepConnection   - ��������� ��������� ����������, ��� ��� ����������. ����� ��� ���������� �������� ������. rsKeepConnection ������������ ��������� ������.
   rsNoConnection     - ���������� ����� "����������� �����", �.�. �������������� ��������� ��� ������� ASM �������.
   rsRollBackOnEClose - � ������ �������� ����������, ��� �������� ASMCDS EClose, ���������� 'ROLLBACK TRAN', � ����� 'raise exception'.
   rsCheckRecordsAffectedOnApplyUpdates - ��������� �� RecordsAffected ���������� ������. � ������ ������ � ���������� ����������.
RO rsTransaction      - ����������� ����������
RO rsMServerLogin     - ������������ ����������� �� <M-Server>
RO rsPegasLogin       - ������������ ����������� �� <Pegas> (��� ��� Pegas ������)
RO rsMServerOnLine    - ���������� ����� � �������� � �������� (��������� ����� ����� �� MForm)
RO rsOpen             - ������� EOpen
RO rsBridge
   rsKeepLocalConnection - ?
RO rsRequiredForRelogin_    - ?
RO BridgeReliable
}
{$ENDIF}

implementation

end.
