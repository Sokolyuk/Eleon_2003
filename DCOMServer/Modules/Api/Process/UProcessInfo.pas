unit UProcessInfo;

Interface
  uses UITObject, UProcessInfoTypes;
type
  TProcessInfo=Class(TITObject, IProcessInfo)
  private
    FErrorMessage:AnsiString;
    FProcInfo:TProcInfo;
    procedure InternalClearInfo;
  protected
    Function IT_GetPID:Cardinal;
    Procedure IT_SetPID(Value:Cardinal);
    Function IT_GetInfo:TProcInfo;
  public
    Constructor Create;
    Destructor Destroy; Override;
    Procedure ITRefresh;
    Property ITPID:Cardinal read IT_GetPID write IT_SetPID;
    Property ITInfo:TProcInfo read IT_GetInfo;
  end;

Implementation
  Uses SysUtils, Windows, PsApi;
  
Constructor TProcessInfo.Create;
begin
  InternalClearInfo;
  FErrorMessage:='';
  inherited Create;
end;

Destructor TProcessInfo.Destroy;
begin
  InternalClearInfo;
  FErrorMessage:='';
  inherited Destroy;
end;

procedure TProcessInfo.InternalClearInfo;
begin
  FProcInfo.PID:=0;
  FProcInfo.Name:='';
  FProcInfo.FileName:='';
  FillChar(FProcInfo.MemoryCounters, SizeOf(FProcInfo.MemoryCounters), 0);
  FErrorMessage:='';
end;

Function TProcessInfo.IT_GetPID:Cardinal;
begin
  InternalLock;
  try
    Result:=FProcInfo.PID;
  finally
    InternalUnlock;
  end;
end;

Procedure TProcessInfo.IT_SetPID(Value:Cardinal);
begin
  InternalLock;
  try
    If FProcInfo.PID<>Value Then InternalClearInfo;
    FProcInfo.PID:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TProcessInfo.IT_GetInfo:TProcInfo;
begin
  InternalLock;
  try
    If FErrorMessage<>'' Then Raise Exception.Create('IT_GetInfo: '+FErrorMessage);
    If FProcInfo.PID=0 Then Raise Exception.Create('IT_GetInfo: Data is not assigned.');
    Result:=FProcInfo;
  finally
    InternalUnlock;
  end;
end;

Procedure LoadProcInfo(Var aTProcInfo:TProcInfo);
  Var tmpProcess:THandle;
      tmpMod:HMODULE;
      tmpDWORD:DWORD;
      tmpPChar:PChar;
      tmpLength:Cardinal;
      tmpppsmemCounters:PPROCESS_MEMORY_COUNTERS;
begin
  if aTProcInfo.PID=0 Then aTProcInfo.Name:='System Idle Process' else begin
    tmpProcess:=OpenProcess(PROCESS_QUERY_INFORMATION Or PROCESS_VM_READ, FALSE, aTProcInfo.PID);
    If tmpProcess=0 Then Raise Exception.Create('OpenProcess: '+SysErrorMessage(GetLastError));
    try
      if EnumProcessModules(tmpProcess, @tmpMod, sizeof(tmpMod), tmpDWORD) then begin
        tmpLength:=MAX_PATH;
        GetMem(tmpPChar, tmpLength);
        try
          If Not Boolean(GetModuleBaseName(tmpProcess, tmpMod, tmpPChar, tmpLength)) Then Raise Exception.Create('GetModuleBaseName: '+SysErrorMessage(GetLastError));
          aTProcInfo.Name:=tmpPChar;
          //..
          If Not Boolean(GetModuleFileNameEx(tmpProcess, tmpMod, tmpPChar, tmpLength)) Then Raise Exception.Create('GetModuleFileNameEx: '+SysErrorMessage(GetLastError));
          aTProcInfo.FileName:=tmpPChar;
        finally
          FreeMem(tmpPChar, tmpLength);
        end;
      end else Raise Exception.Create('EnumProcessModules: '+SysErrorMessage(GetLastError));
      //..
      tmpppsmemCounters:=@aTProcInfo.MemoryCounters;
      if Not GetProcessMemoryInfo(tmpProcess, tmpppsmemCounters, SizeOf(aTProcInfo.MemoryCounters)) then Raise Exception.Create('GetProcessMemoryInfo: '+SysErrorMessage(GetLastError));
    finally
      CloseHandle(tmpProcess);
    end;
  end;
end;

Procedure TProcessInfo.ITRefresh;
begin
  InternalLock;
  try
    try
      LoadProcInfo(FProcInfo);
    except
      on e:exception do FErrorMessage:='PID='+IntToStr(FProcInfo.PID)+e.Message;
    end;
  finally
    InternalUnlock;
  end;
end;

end.
