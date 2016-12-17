unit UProcessInfoPDH;

interface
  uses UITObject, UProcessInfoPDHTypes, Pdh;
type
  TProcessInfoPDH=Class(TITObject, IProcessInfoPDH)
  private
    FErrorMessage:AnsiString;
    FProcInfoPDH:TProcInfoPDH;
    FCounters:TCounters;
    FHQUERY:HQUERY;
    FCPUUsagePrivilegedTime:HCOUNTER;
    FCPUUsageProcessorTime:HCOUNTER;
    FCPUUsageUserTime:HCOUNTER;
    FCreatingProcessID:HCOUNTER;
    FElapsedTime:HCOUNTER;
    FHandles:HCOUNTER;
    FIODataBytesPerSec:HCOUNTER;
    FIODataOperationsPerSec:HCOUNTER;
    FIODataOtherBytesPerSec:HCOUNTER;
    FIODataOtherOperationsPerSec:HCOUNTER;
    FIOReadBytesPerSec:HCOUNTER;
    FIOReadOperationsPerSec:HCOUNTER;
    FIOWriteBytesPerSec:HCOUNTER;
    FIOWriteOperationsPerSec:HCOUNTER;
    FPageFaultPerSec:HCOUNTER;
    FPageFileBytes:HCOUNTER;
    FPageFilePeakBytes:HCOUNTER;
    FPoolNonPagedBytes:HCOUNTER;
    FPoolPagedBytes:HCOUNTER;
    FPriorityBase:HCOUNTER;
    FPrivateBytes:HCOUNTER;
    FThreads:HCOUNTER;
    FVirtualBytes:HCOUNTER;
    FVirtualBytesPeak:HCOUNTER;
    FWorkingSet:HCOUNTER;
    FWorkingSetPeak:HCOUNTER;
  protected
    procedure InternalClearInfoPDH;
    procedure InternalLoadProcInfoName;
    Procedure InternalLoadProcInfoPDH;
    Function IT_GetPID:Cardinal;
    Procedure IT_SetPID(Value:Cardinal);
    Function IT_GetInfoPDH:TProcInfoPDH;
    Function IT_GetCounters:TCounters;
    Procedure IT_SetCounters(Value:TCounters);
  public
    Constructor Create;
    Destructor Destroy; Override;
    Procedure ITRefresh;
    Procedure ITRefreshProcInfoPDH;
    Procedure ITVerifyCounters;
    Property ITPID:Cardinal read IT_GetPID write IT_SetPID;
    Property ITInfoPDH:TProcInfoPDH read IT_GetInfoPDH;
    Property ITCounters:TCounters read IT_GetCounters write IT_SetCounters;
  end;

implementation
  Uses SysUtils, Windows, PSApi, UProcessInfoPDHConsts, Dialogs;

Constructor TProcessInfoPDH.Create;
begin
  inherited Create;
  InternalClearInfoPDH;
  FErrorMessage:='';
  FCounters:=0;
  FCPUUsagePrivilegedTime:=0;
  FCPUUsageProcessorTime:=0;
  FCPUUsageUserTime:=0;
  FCreatingProcessID:=0;
  FElapsedTime:=0;
  FHandles:=0;
  FIODataBytesPerSec:=0;
  FIODataOperationsPerSec:=0;
  FIODataOtherBytesPerSec:=0;
  FIODataOtherOperationsPerSec:=0;
  FIOReadBytesPerSec:=0;
  FIOReadOperationsPerSec:=0;
  FIOWriteBytesPerSec:=0;
  FIOWriteOperationsPerSec:=0;
  FPageFaultPerSec:=0;
  FPageFileBytes:=0;
  FPageFilePeakBytes:=0;
  FPoolNonPagedBytes:=0;
  FPoolPagedBytes:=0;
  FPriorityBase:=0;
  FPrivateBytes:=0;
  FThreads:=0;
  FVirtualBytes:=0;
  FVirtualBytesPeak:=0;
  FWorkingSet:=0;
  FWorkingSetPeak:=0;
  If PdhOpenQuery(Nil, 0, FHQUERY)<>ERROR_SUCCESS Then raise exception.Create('Error PdhOpenQuery.');
end;

Destructor TProcessInfoPDH.Destroy;
begin
  InternalClearInfoPDH;
  FErrorMessage:='';
  FCounters:=0;
  ITVerifyCounters;
  If FhQuery<>0 Then begin
    PdhCloseQuery(FhQuery);
    FhQuery:=0;
  end;
  inherited Destroy;
end;

Function TProcessInfoPDH.IT_GetCounters:TCounters;
begin
  InternalLock;
  try
    Result:=FCounters;
  finally
    InternalUnlock;
  end;
end;

Procedure TProcessInfoPDH.IT_SetCounters(Value:TCounters);
begin
  InternalLock;
  try
    MessageDlg('1 IT_SetCounters('+IntToStr(Value)+')', mtInformation, [mbOk], 0);
    If FCounters<>Value Then begin
      MessageDlg('2 IT_SetCounters('+IntToStr(Value)+')', mtInformation, [mbOk], 0);
      FCounters:=Value;
      //ITVerifyCounters;
    end;
  finally
    InternalUnlock;
  end;
end;

  Const cnPRUs:AnsiString='\Process(Admin#440)\% User Time';

Procedure TProcessInfoPDH.ITVerifyCounters;
  Var tmpSt:AnsiString;
  Function InternalExtractFileName(Const aFileName:AnsiString):AnsiString;
    Var tmplPos:Integer;
  begin
    tmplPos:=Pos('.', aFileName);
    If tmplPos>0 Then begin
      Result:=Copy(aFileName, 0, tmplPos-1);
    end else Result:=aFileName;
  end;
begin
  InternalLock;
  try
    {If (FCounters And pdhCPUUsagePrivilegedTime)>0 Then begin
      If FCPUUsagePrivilegedTime=0 Then begin
        tmpSt:='\Process('+FProcInfoPDH.Name+')'+pdhStCPUUsagePrivilegedTime;
        If PdhAddCounterA(FHQUERY, PChar(tmpSt), 0, FCPUUsagePrivilegedTime)<>ERROR_SUCCESS Then raise exception.Create('Error PdhAddCounter.');
      end;
    end else begin
      If FCPUUsagePrivilegedTime<>0 Then begin
        PdhRemoveCounter(FCPUUsagePrivilegedTime);
        FCPUUsagePrivilegedTime:=0;
      end;
    end;
    If (FCounters And pdh?)>0 Then begin
      If F?=0 Then begin
        tmpSt:='\Process('+FProcInfoPDH.Name+')'+pdhSt?;
        If PdhAddCounterA(FHQUERY, PChar(tmpSt), 0, F?)<>ERROR_SUCCESS Then raise exception.Create('Error PdhAddCounter.');
      end;
    end else begin
      If F?<>0 Then begin
        PdhRemoveCounter(F?);
        F?:=0;
      end;
    end;}
    //MessageDlg('1 PdhAddCounterA FCounters='+IntToStr(FCounters)+'.', mtInformation, [mbOk], 0);
    If (FCounters And pdhCPUUsageUserTime)>0 Then begin
      //MessageDlg('2 PdhAddCounterA FCPUUsageUserTime='+IntToStr(FCPUUsageUserTime)+'.', mtInformation, [mbOk], 0);
      If FCPUUsageUserTime=0 Then begin
        //MessageDlg('3 PdhAddCounterA FCounters='+IntToStr(FCounters)+'.', mtInformation, [mbOk], 0);
        tmpSt:='\Process('+InternalExtractFileName(FProcInfoPDH.Name)+')'+pdhStCPUUsageUserTime;
        MessageDlg('CREATE 3 PdhAddCounterA FCounters='+IntToStr(FCounters)+', Name='''+PChar(tmpSt)+'''.', mtInformation, [mbOk], 0);
        If PdhAddCounterA(FHQUERY, PChar(cnPRUs{tmpSt}), 0, FCPUUsageUserTime)<>ERROR_SUCCESS Then raise exception.Create('Error PdhAddCounter.');
        MessageDlg('PdhAddCounterA FCounters='+IntToStr(FCounters)+'.', mtInformation, [mbOk], 0);
      end;
    end else begin
      //MessageDlg('4 PdhAddCounterA FCounters='+IntToStr(FCounters)+'.', mtInformation, [mbOk], 0);
      If FCPUUsageUserTime<>0 Then begin
        MessageDlg('REMOTE 5 PdhAddCounterA FCounters='+IntToStr(FCounters)+'.', mtInformation, [mbOk], 0);
        PdhRemoveCounter(FCPUUsageUserTime);
        FCPUUsageUserTime:=0;
      end;
    end;
  finally
    //MessageDlg('Exit PdhAddCounterA FCounters='+IntToStr(FCounters)+'/ FCPUUsageUserTime='+IntToStr(FCPUUsageUserTime)+'.', mtInformation, [mbOk], 0);
    InternalUnlock;
  end;
end;

{    FCPUUsagePrivilegedTime:HCOUNTER;
    FCPUUsageProcessorTime:HCOUNTER;
    FCPUUsageUserTime:HCOUNTER;
    FCreatingProcessID:HCOUNTER;
    FElapsedTime:HCOUNTER;
    FHandles:HCOUNTER;
    FIODataBytesPerSec:HCOUNTER;
    FIODataOperationsPerSec:HCOUNTER;
    FIODataOtherBytesPerSec:HCOUNTER;
    FIODataOtherOperationsPerSec:HCOUNTER;
    FIOReadBytesPerSec:HCOUNTER;
    FIOReadOperationsPerSec:HCOUNTER;
    FIOWriteBytesPerSec:HCOUNTER;
    FIOWriteOperationsPerSec:HCOUNTER;
    FPageFaultPerSec:HCOUNTER;
    FPageFileBytes:HCOUNTER;
    FPageFilePeakBytes:HCOUNTER;
    FPoolNonPagedBytes:HCOUNTER;
    FPoolPagedBytes:HCOUNTER;
    FPriorityBase:HCOUNTER;
    FPrivateBytes:HCOUNTER;
    FThreads:HCOUNTER;
    FVirtualBytes:HCOUNTER;
    FVirtualBytesPeak:HCOUNTER;
    FWorkingSet:HCOUNTER;
    FWorkingSetPeak:HCOUNTER;}

procedure TProcessInfoPDH.InternalClearInfoPDH;
begin
  FProcInfoPDH.PID:=0;
  FProcInfoPDH.Name:='';
  FProcInfoPDH.FileName:='';
  FillChar(FProcInfoPDH, SizeOf(TProcInfoPDH), 0);
  FErrorMessage:='';
end;

Function TProcessInfoPDH.IT_GetPID:Cardinal;
begin
  InternalLock;
  try
    Result:=FProcInfoPDH.PID;
  finally
    InternalUnlock;
  end;
end;

Procedure TProcessInfoPDH.IT_SetPID(Value:Cardinal);
  Var tmpOldCounters:TCounters;
begin
  InternalLock;
  try
    If FProcInfoPDH.PID<>Value Then begin
      InternalClearInfoPDH;
      tmpOldCounters:=FCounters;
      FCounters:=0;
      ITVerifyCounters;
      FCounters:=tmpOldCounters;
      FProcInfoPDH.PID:=Value;
      //InternalLoadProcInfoName;
      //ITVerifyCounters;
      MessageDlg('1 IT_SetPID('+IntToStr(Value)+').', mtInformation, [mbOk], 0);
      //InternalLoadProcInfoPDH;
      //MessageDlg('2 IT_SetPID('+IntToStr(Value)+').', mtInformation, [mbOk], 0);
    end;
  finally
    InternalUnlock;
  end;
end;

Function TProcessInfoPDH.IT_GetInfoPDH:TProcInfoPDH;
begin
  InternalLock;
  try
    If FErrorMessage<>'' Then Raise Exception.Create('IT_GetInfoPDH: '+FErrorMessage);
    If FProcInfoPDH.PID=0 Then Raise Exception.Create('IT_GetInfoPDH: Data is not assigned.');
    Result:=FProcInfoPDH;
  finally
    InternalUnlock;
  end;
end;

Procedure TProcessInfoPDH.InternalLoadProcInfoPDH;
  Var tmpPDH_FMT_COUNTERVALUE:PDH_FMT_COUNTERVALUE;
begin
      If FCounters>0 Then begin
        If FhQuery=0 then raise exception.Create('FhQuery=0.');
        If PdhCollectQueryData(FhQuery)<>ERROR_SUCCESS Then raise exception.Create('Error PdhCollectQueryData.');
        If (FCounters And pdhCPUUsageUserTime)>0 Then begin
          If FCPUUsageUserTime<>0 Then begin
            If PdhGetFormattedCounterValue(FCPUUsageUserTime, PDH_FMT_LARGE, Nil, @tmpPDH_FMT_COUNTERVALUE)<>ERROR_SUCCESS Then raise exception.Create('Error PdhGetFormattedCounterValue.');
            if tmpPDH_FMT_COUNTERVALUE.CStatus<>0 Then raise Exception.Create('tmpPDH_FMT_COUNTERVALUE.CStatus<>0.');
            FProcInfoPDH.CPUUsageUserTime:=tmpPDH_FMT_COUNTERVALUE.largeValue;
          end;
        end;
      end;
(*  CPUUsagePrivilegedTime:Word;{%}
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
    WorkingSetPeak:Cardinal;!!!*)
end;

Procedure TProcessInfoPDH.InternalLoadProcInfoName;
  Var tmpProcess:THandle;
      tmpMod:HMODULE;
      tmpDWORD:DWORD;
      tmpPChar:PChar;
      tmpLength:Cardinal;
begin
  if FProcInfoPDH.PID=0 Then FProcInfoPDH.Name:='System Idle Process' else begin
    tmpProcess:=OpenProcess(PROCESS_QUERY_INFORMATION Or PROCESS_VM_READ, FALSE, FProcInfoPDH.PID);
    If tmpProcess=0 Then Raise Exception.Create('OpenProcess: '+SysErrorMessage(GetLastError));
    try
      if EnumProcessModules(tmpProcess, @tmpMod, sizeof(tmpMod), tmpDWORD) then begin
        tmpLength:=MAX_PATH;
        GetMem(tmpPChar, tmpLength);
        try
          If Not Boolean(GetModuleBaseName(tmpProcess, tmpMod, tmpPChar, tmpLength)) Then Raise Exception.Create('GetModuleBaseName: '+SysErrorMessage(GetLastError));
          FProcInfoPDH.Name:=tmpPChar;
          //..
          If Not Boolean(GetModuleFileNameEx(tmpProcess, tmpMod, tmpPChar, tmpLength)) Then Raise Exception.Create('GetModuleFileNameEx: '+SysErrorMessage(GetLastError));
          FProcInfoPDH.FileName:=tmpPChar;
        finally
          FreeMem(tmpPChar, tmpLength);
        end;
      end else Raise Exception.Create('EnumProcessModules: '+SysErrorMessage(GetLastError));
    finally
      CloseHandle(tmpProcess);
    end;
  end;
end;

Procedure TProcessInfoPDH.ITRefresh;
begin
  InternalLock;
  try
    try
      InternalLoadProcInfoName;
      ITVerifyCounters;
      InternalLoadProcInfoPDH;
    except
      on e:exception do FErrorMessage:='PID='+IntToStr(FProcInfoPDH.PID)+' :'+e.Message;
    end;
  finally
    InternalUnlock;
  end;
end;

Procedure TProcessInfoPDH.ITRefreshProcInfoPDH;
begin
  InternalLock;
  try
    InternalLoadProcInfoPDH;
  finally
    InternalUnlock;
  end;
end;

end.
