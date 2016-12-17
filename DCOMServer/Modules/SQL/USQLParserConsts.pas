unit USQLParserConsts;

interface
  Uses USQLParserTypes;
Const
  csmSelect:AnsiString='SELECT';
  csmInsert:AnsiString='INSERT';
  csmDelete:AnsiString='DELETE';
  csmUpdate:AnsiString='UPDATE';
  csmBeginTran:AnsiString='BEGINTRAN';
  csmCommitTran:AnsiString='COMMITTRAN';
  csmRollbackTran:AnsiString='ROLLBACKTRAN';
  csmExec:AnsiString='EXEC';
  csmCreate:AnsiString='CREATE';
  csmAlter:AnsiString='ALTER';
  csmDrop:AnsiString='DROP';
  csmTruncate:AnsiString='TRUNCATE';
  cnAllSQLCommands:TSetSQLCommandType=[sctSelect, sctInsert, sctDelete, sctUpdate, sctBeginTran, sctCommitTran, sctRollbackTran,
                                       sctExec, sctCreate, sctAlter, sctDrop, sctTruncate];
implementation

end.
