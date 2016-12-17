unit UProcessInfoPDHTypes;

interface
type
  TCounters=Cardinal;
  //..
  TProcInfoPDH=record
    PID:THandle;
    Name:AnsiString;
    FileName:AnsiString;
    CPUUsagePrivilegedTime:Word;{%}
    CPUUsageProcessorTime:Word;{%}
    CPUUsageUserTime:Word;{%}
    CreatingProcessID:Cardinal;
    ElapsedTime:Cardinal;
    Handles:Cardinal;
    IODataBytesPerSec:Cardinal;
    IODataOperationsPerSec:Cardinal;
    IODataOtherBytesPerSec:Cardinal;
    IODataOtherOperationsPerSec:Cardinal;
    IOReadBytesPerSec:Cardinal;
    IOReadOperationsPerSec:Cardinal;
    IOWriteBytesPerSec:Cardinal;
    IOWriteOperationsPerSec:Cardinal;
    PageFaultPerSec:Cardinal;
    PageFileBytes:Cardinal;
    PageFilePeakBytes:Cardinal;
    PoolNonPagedBytes:Cardinal;
    PoolPagedBytes:Cardinal;
    PriorityBase:Cardinal;
    PrivateBytes:Cardinal;
    Threads:Cardinal;
    VirtualBytes:Cardinal;
    VirtualBytesPeak:Cardinal;
    WorkingSet:Cardinal;
    WorkingSetPeak:Cardinal;

(*class Win32_PerfFormattedData_PerfProc_Process : Win32_PerfFormattedData

  string Caption  ;
  uint32 CreatingProcessID  ;
  string Description  ;
  uint64 ElapsedTime  ;
  uint64 Frequency_Object  ;
  uint64 Frequency_PerfTime  ;
  uint64 Frequency_Sys100NS  ;
  uint32 HandleCount  ;
  uint32 IDProcess  ;
  uint64 IODataOperationsPerSec  ;
  uint64 IOOtherOperationsPerSec  ;
  uint64 IOReadBytesPerSec  ;
  uint64 IOReadOperationsPerSec  ;
  uint64 IOWriteBytesPerSec  ;
  uint64 IOWriteOperationsPerSec  ;
  uint64 IODataBytesPerSec  ;  
  uint64 IOOtherBytesPerSec  ;
  string Name  ;
  uint32 PageFaultsPerSec  ;
  uint64 PageFileBytes  ;
  uint64 PageFileBytesPeak  ;
  uint64 PercentPrivilegedTime  ;
  uint64 PercentProcessorTime  ;
  uint64 PercentUserTime  ;
  uint32 PoolNonpagedBytes  ;
  uint32 PoolPagedBytes  ;
  uint32 PriorityBase  ;
  uint64 PrivateBytes  ;
  uint32 ThreadCount  ;
  uint64 Timestamp_Object  ;
  uint64 Timestamp_PerfTime  ;
  uint64 Timestamp_Sys100NS  ;
  uint64 VirtualBytes  ;
  uint64 VirtualBytesPeak  ;
  uint64 WorkingSet  ;
  uint64 WorkingSetPeak  ;
;*)

  end;

  IProcessInfoPDH=Interface
  ['{B3D1B2CE-964F-46B1-A871-1C1F66932D09}']
    Function IT_GetPID:Cardinal;
    Procedure IT_SetPID(Value:Cardinal);
    Function IT_GetInfoPDH:TProcInfoPDH;
    Function IT_GetCounters:TCounters;
    Procedure IT_SetCounters(Value:TCounters);
    //..
    Procedure ITRefresh;
    Procedure ITRefreshProcInfoPDH;
    Procedure ITVerifyCounters;
    Property ITPID:Cardinal read IT_GetPID write IT_SetPID;
    Property ITInfoPDH:TProcInfoPDH read IT_GetInfoPDH;
    Property ITCounters:TCounters read IT_GetCounters write IT_SetCounters;
  end;

implementation

end.
