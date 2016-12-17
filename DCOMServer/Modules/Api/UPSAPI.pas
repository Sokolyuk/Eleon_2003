unit UPSAPI;

interface
  Uses PsAPI, AccCtrl;

//Type
{  TProcessInfo=record
    ID:THandle;
    Name:AnsiString;
    FileName:AnsiString;
    aMemoryCounters:PROCESS_MEMORY_COUNTERS;
  end;}


  Procedure SetPrivilege(Const aPrivilegeName:AnsiString; Enable:boolean);
  //Procedure LoadProcessesInfo(Var aTProcessInfo:TProcessesInfo);
  Function HandlerToUserName(aHandle:THandle; aObjectType:SE_OBJECT_TYPE):AnsiString;
  Function FileNameToPID(Const aFilename:AnsiString):THandle;
  Function glpsGetVMUsageOfPID(aPID:Cardinal):Cardinal;

implementation
  Uses Windows, Sysutils, AclAPI;

{ SeChangeNotifyPrivilege, SeShutdownPrivilege, SeSecurityPrivilege, SeBackupPrivilege, SeRestorePrivilege
  SeSystemtimePrivilege, SeRemoteShutdownPrivilege, SeTakeOwnershipPrivilege, SeDebugPrivilege, SeSystemEnvironmentPrivilege,
  SeSystemProfilePrivilege, SeProfileSingleProcessPrivilege, SeIncreaseBasePriorityPrivilege, SeLoadDriverPrivilege,
  SeCreatePagefilePrivilege, SeIncreaseQuotaPrivilege, SeAuditPrivilege}
Procedure SetPrivilege(Const aPrivilegeName:AnsiString; Enable:boolean);
  Var PrevPrivileges:TTokenPrivileges;
      Privileges:TTokenPrivileges;
      Token:THandle;
      dwRetLen:DWord;
begin
  if not OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, Token) then Raise Exception.Create(SysErrorMessage(GetLastError));
  try
    Privileges.PrivilegeCount:=1;
    if LookupPrivilegeValue(nil, PChar(aPrivilegeName), Privileges.Privileges[0].LUID) then begin
      if Enable then Privileges.Privileges[0].Attributes:=SE_PRIVILEGE_ENABLED
                else Privileges.Privileges[0].Attributes:=0;
      dwRetLen:=0;
      If Not AdjustTokenPrivileges(Token, False, Privileges, SizeOf(PrevPrivileges), PrevPrivileges, dwRetLen) Then Raise Exception.Create(SysErrorMessage(GetLastError));
    end else Raise Exception.Create(SysErrorMessage(GetLastError));
  finally
    CloseHandle(Token);
  end;
end;

{Procedure LoadProcessesInfo(Var aTProcessesInfo:TProcessesInfo);
  Var tmpProcess:THandle;
      tmpMod:HMODULE;
      tmpDWORD:DWORD;
      tmpPChar:PChar;
      tmpLength:Cardinal;
      tmpppsmemCounters:PPROCESS_MEMORY_COUNTERS;
begin
  if aTProcessesInfo.PID=0 Then aTProcessesInfo.ProcessName:='System Idle Process' else begin
    tmpProcess:=OpenProcess(PROCESS_QUERY_INFORMATION Or PROCESS_VM_READ, FALSE, aTProcessesInfo.PID);
    If tmpProcess=0 Then Raise Exception.Create('OpenProcess: '+SysErrorMessage(GetLastError));
    try
      if EnumProcessModules(tmpProcess, @tmpMod, sizeof(tmpMod), tmpDWORD) then begin
        tmpLength:=MAX_PATH;
        GetMem(tmpPChar, tmpLength);
        try
          If Not Boolean(GetModuleBaseName(tmpProcess, tmpMod, tmpPChar, tmpLength)) Then Raise Exception.Create('GetModuleBaseName: '+SysErrorMessage(GetLastError));
          aTProcessesInfo.ProcessName:=tmpPChar;
          //..
          If Not Boolean(GetModuleFileNameEx(tmpProcess, tmpMod, tmpPChar, tmpLength)) Then Raise Exception.Create('GetModuleFileNameEx: '+SysErrorMessage(GetLastError));
          aTProcessesInfo.FileName:=tmpPChar;
        finally
          FreeMem(tmpPChar, tmpLength);
        end;
      end else Raise Exception.Create('EnumProcessModules: '+SysErrorMessage(GetLastError));
      //..
      tmpppsmemCounters:=@aTProcessesInfo.aPROCESS_MEMORY_COUNTERS;
      if Not GetProcessMemoryInfo(tmpProcess, tmpppsmemCounters, SizeOf(aTProcessesInfo.aPROCESS_MEMORY_COUNTERS)) then Raise Exception.Create('GetProcessMemoryInfo: '+SysErrorMessage(GetLastError));
    finally
      CloseHandle(tmpProcess);
    end;
  end;
end;}

Function glpsGetVMUsageOfPID(aPID:Cardinal):Cardinal;
  Var tmpProcess:THandle;
      tmpPROCESS_MEMORY_COUNTERS:_PROCESS_MEMORY_COUNTERS;
      tmpppsmemCounters:PPROCESS_MEMORY_COUNTERS;
begin
  tmpProcess:=OpenProcess(PROCESS_QUERY_INFORMATION Or PROCESS_VM_READ, False, aPID);
  If tmpProcess=0 Then Raise Exception.Create('OpenProcess: '+SysErrorMessage(GetLastError));
  Result:=0;//от варнингов
  try
    tmpppsmemCounters:=@tmpPROCESS_MEMORY_COUNTERS;
    if Not GetProcessMemoryInfo(tmpProcess, tmpppsmemCounters, SizeOf(tmpPROCESS_MEMORY_COUNTERS)) then Raise Exception.Create('GetProcessMemoryInfo: '+SysErrorMessage(GetLastError));
    Result:=tmpPROCESS_MEMORY_COUNTERS.PagefileUsage;
  finally
    CloseHandle(tmpProcess);
  end;
end;

Function HandlerToUserName(aHandle:THandle; aObjectType:SE_OBJECT_TYPE):AnsiString;
  Var pSidOwner:PSID;
      AcctName:PChar;
      DomainName:PChar;
      AcctNameSize:Cardinal;
      DomainNameSize:DWORD;
      eUse:SID_NAME_USE;
      ppSD:PPSECURITY_DESCRIPTOR;
      tmpDWORD:DWORD;
      tmpPSID:PSID;
      tmpLastError:DWord;
begin
  tmpDWORD:=DWord(aObjectType);
  pSidOwner:=@tmpPSID;
  tmpLastError:=GetSecurityInfo(aHandle, SE_OBJECT_TYPE(tmpDWORD), OWNER_SECURITY_INFORMATION, @pSidOwner, nil, nil, nil, ppSD);
  If tmpLastError<>ERROR_SUCCESS Then Raise Exception.Create(SysErrorMessage(tmpLastError));
  try
    AcctNameSize:=MAX_PATH;
    DomainNameSize:=MAX_PATH;
    eUse:=SidTypeUnknown;
    GetMem(AcctName, AcctNameSize);
    try
      GetMem(DomainName, DomainNameSize);
      try
        If Not LookupAccountSid(nil, pSidOwner, AcctName, AcctNameSize, DomainName, DomainNameSize, eUse) Then Raise Exception.Create(SysErrorMessage(GetLastError));
        Result:=DomainName+'\'+AcctName;
      finally
        FreeMem(DomainName, DomainNameSize);
      end;
    finally
      FreeMem(AcctName, AcctNameSize);
    end;
  finally
    LocalFree(HLOCAL(ppSD));
  end;
end;

Function FileNameToPID(Const aFilename:AnsiString):THandle;
  Type
    TIDProcess = Array[0..1023] of THandle;
  Var tmpIDProcess:TIDProcess;
      tmpNeeded:Cardinal;
      tmpI:Integer;
      tmpProcess:THandle;
      tmpPChar:PChar;
      tmpSt:AnsiString;
begin
  Result:=0;
  If Not EnumProcesses(@tmpIDProcess, SizeOf(tmpIDProcess), tmpNeeded) Then Raise Exception.Create(SysErrorMessage(GetLastError));
  GetMem(tmpPChar, MAX_PATH);
  try
    For tmpI:=0 to (tmpNeeded div SizeOf(THandle))-1 do begin
      If (tmpIDProcess[tmpI]=0){Or(tmpIDProcess[tmpI]=8)} Then Continue;
      tmpProcess:=OpenProcess(PROCESS_QUERY_INFORMATION Or PROCESS_VM_READ, FALSE, tmpIDProcess[tmpI]);
      If tmpProcess<>0 Then begin
        try
          If Boolean(GetModuleFileNameEx(tmpProcess, 0, tmpPChar, MAX_PATH)) Then begin
            tmpSt:=tmpPChar;
            If AnsiUpperCase(tmpSt)=AnsiUpperCase(aFilename) Then begin
              Result:=tmpIDProcess[tmpI];
              Break;
            end;
          end;  
        finally
          CloseHandle(tmpProcess);
        end;
      end;
    end;
  finally
    FreeMem(tmpPChar, MAX_PATH);
  end;
end;

end.
