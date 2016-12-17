unit UProcessInfoTypes;

interface
  Uses PsApi;
type
  TProcInfo=record
    PID:THandle;
    Name:AnsiString;
    FileName:AnsiString;
    MemoryCounters:PROCESS_MEMORY_COUNTERS;
  end;

  IProcessInfo=Interface
  ['{B28A1589-2EBE-45D4-B805-9CCC35616115}']
    Function IT_GetPID:Cardinal;
    Procedure IT_SetPID(Value:Cardinal);
    Function IT_GetInfo:TProcInfo;
    //..
    Procedure ITRefresh;
    Property ITPID:Cardinal read IT_GetPID write IT_SetPID;
    Property ITInfo:TProcInfo read IT_GetInfo;
  end;

implementation

end.
