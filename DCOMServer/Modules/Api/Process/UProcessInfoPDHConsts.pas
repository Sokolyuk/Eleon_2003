unit UProcessInfoPDHConsts;

interface
Const
  pdhCPUUsagePrivilegedTime=$1;
  pdhCPUUsageProcessorTime=$2;
  pdhCPUUsageUserTime=$4;
  pdhCreatingProcessID=$8;
  pdhElapsedTime=$10;
  pdhHandles=$20;
  pdhIODataBytesPerSec=$40;
  pdhIODataOperationsPerSec=$80;
  pdhIODataOtherBytesPerSec=$100;
  pdhIODataOtherOperationsPerSec=$200;
  pdhIOReadBytesPerSec=$400;
  pdhIOReadOperationsPerSec=$800;
  pdhIOWriteBytesPerSec=$1000;
  pdhIOWriteOperationsPerSec=$2000;
  pdhPageFaultPerSec=$4000;
  pdhPageFileBytes=$8000;
  pdhPageFilePeakBytes=$10000;
  pdhPoolNonPagedBytes=$20000;
  pdhPoolPagedBytes=$40000;
  pdhPriorityBase=$80000;
  pdhPrivateBytes=$100000;
  pdhThreads=$200000;
  pdhVirtualBytes=$400000;
  pdhVirtualBytesPeak=$800000;
  pdhWorkingSet=$1000000;
  pdhWorkingSetPeak=$2000000;
  //..
  pdhStCPUUsagePrivilegedTime:AnsiString='\% Privileged Time';
  pdhStCPUUsageProcessorTime:AnsiString='\% Processor Time';
  pdhStCPUUsageUserTime:AnsiString='\% User Time';
  pdhStCreatingProcessID:AnsiString='\Creating Process ID';
  pdhStElapsedTime:AnsiString='\Elapsed Time';
  pdhStHandles:AnsiString='\Handle Count';
  pdhStIODataBytesPerSec:AnsiString='\IO Data Bytes/sec';
  pdhStIODataOperationsPerSec:AnsiString='\IO Data Operations/sec';
  pdhStIODataOtherBytesPerSec:AnsiString='\IO Other Bytes/sec';
  pdhStIODataOtherOperationsPerSec:AnsiString='\IO Other Operations/sec';
  pdhStIOReadBytesPerSec:AnsiString='\IO Read Bytes/sec';
  pdhStIOReadOperationsPerSec:AnsiString='\IO Read Operations/sec';
  pdhStIOWriteBytesPerSec:AnsiString='\IO Write Bytes/sec';
  pdhStIOWriteOperationsPerSec:AnsiString='\IO Write Operations/sec';
  pdhStPageFaultPerSec:AnsiString='\Page Faults/sec';
  pdhStPageFileBytes:AnsiString='\Page File Bytes';
  pdhStPageFilePeakBytes:AnsiString='\Page File Bytes Peak';
  pdhStPoolNonPagedBytes:AnsiString='\Pool Nonpaged Bytes';
  pdhStPoolPagedBytes:AnsiString='\Pool Paged Bytes';
  pdhStPriorityBase:AnsiString='\Priority Base';
  pdhStPrivateBytes:AnsiString='\Private Bytes';
  pdhStThreads:AnsiString='\Thread Count';
  pdhStVirtualBytes:AnsiString='\Virtual Bytes';
  pdhStVirtualBytesPeak:AnsiString='\Virtual Bytes Peak';
  pdhStWorkingSet:AnsiString='\Working Set';
  pdhStWorkingSetPeak:AnsiString='\Working Set Peak';

implementation

end.
 