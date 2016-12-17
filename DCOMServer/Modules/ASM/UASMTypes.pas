//Copyright © 2000-2003 by Dmitry A. Sokolyuk
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
{ asTransaction  - Выполняется транзакция
  asLogin        - Пользователь авторизован }
{$ENDIF}
{$IfDef EAMServer}
type
  TASMState=Set of (rsNoSQL, rsNoCDS, rsNoCache, rsKeepConnection, rsKeepLocalConnection, rsNoConnection, rsRollBackOnEClose, rsTransaction, rsMServerLogin, rsPegasLogin, rsADMLogin, rsMServerOnLine, rsOpen, rsCheckRecordsAffectedOnApplyUpdates, rsBridge, rsBridgeReliable);
{ (!) Все флаги действительны только для текущего ASM (!)
   rsNoSQL            - Запрет на запуск SQL запроса
   rsNoCDS            - Запрет на изменение CDS
   rsNoCache          - Запрет на кэщирование данных (каждый запросвыполняется на сервере)
   rsKeepConnection   - Запрещает разрывать соединение, как при транзакции. Нужно для увеличения скорости работы. rsKeepConnection поддерживает вложенные вызовы.
   rsNoConnection     - Установить режим "разорванной связи", т.е. журналирование изменений для данного ASM объекта.
   rsRollBackOnEClose - В случае открытой транзакции, при закрытии ASMCDS EClose, вызывается 'ROLLBACK TRAN', а иначе 'raise exception'.
   rsCheckRecordsAffectedOnApplyUpdates - Проверяет по RecordsAffected целосность данных. В случае работы с триггерами непригоден.
RO rsTransaction      - Выполняется транзакция
RO rsMServerLogin     - Пользователь авторизован на <M-Server>
RO rsPegasLogin       - Пользователь авторизован на <Pegas> (или еще Pegas поднят)
RO rsMServerOnLine    - Существует связь с сервером у прогаммы (локальная копия флага из MForm)
RO rsOpen             - Запущен EOpen
RO rsBridge
   rsKeepLocalConnection - ?
RO rsRequiredForRelogin_    - ?
RO BridgeReliable
}
{$ENDIF}

implementation

end.
