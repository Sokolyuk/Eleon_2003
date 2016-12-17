unit USQLParserTypes;

interface
Type
  TSQLCommandType=({0}sctSelect, {1}sctInsert, {2}sctDelete, {3}sctUpdate, {4}sctBeginTran, {5}sctCommitTran, {6}sctRollbackTran, {7}sctExec, {8}sctCreate, {9}sctAlter, {10}sctDrop, {11}sctTruncate);
  TParseMode=({0}pmdSQLString, {1}pmdExecProc);
  TSetSQLCommandType=Set of TSQLCommandType;


implementation

end.
