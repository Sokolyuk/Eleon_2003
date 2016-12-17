unit UDataCaseExecProcTypes;

interface
type
  TExecThreadProc=procedure(aUserPointer:Pointer; aUserIUnknown:IUnknown);
  TExceptThreadProc=procedure(aUserPointer:Pointer; aUserIUnknown:IUnknown; const aMessage:AnsiString; aHelpContext:Integer);
  TExecThreadProcOfObject=procedure(aUserPointer:Pointer; aUserIUnknown:IUnknown)of object;
  TExceptThreadProcOfObject=procedure(aUserPointer:Pointer; aUserIUnknown:IUnknown; const aMessage:AnsiString; aHelpContext:Integer)of object;
  //..
  PExecThreadStruct=^TExecThreadStruct;
  TExecThreadStruct=record
    UserPointer:Pointer;
    UserIUnknown:IUnknown;
    ThreadProc:TExecThreadProc;
    ThreadProcOfObject:TExecThreadProcOfObject;
    ExceptThreadProc:TExceptThreadProc;//обработчик ошибок
    ExceptThreadProcOfObject:TExceptThreadProcOfObject;//обработчик ошибок
  end;

implementation

end.
