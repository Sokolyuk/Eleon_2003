unit UProcessesList;

interface
  uses UITObject, UVarsetTypes, UProcessInfoTypes, UProcessesListTypes;
type
  TProcessesList=Class(TITObject, IProcessesList)
  private
    FList:IVarset;
  protected
    Function IT_GetList:IVarset;
  public
    Constructor Create;
    Destructor Destroy; Override;
    Function ITRefresh:Integer;
    Property ITList:IVarset read IT_GetList;
  end;

implementation
  Uses UVarset, UProcessInfo, PSAPI, Windows, SysUtils;

Constructor TProcessesList.Create;
begin
  FList:=TVarset.Create;
  Inherited Create;
end;

Destructor TProcessesList.Destroy;
begin
  FList:=Nil;
  Inherited Destroy;
end;

Function TProcessesList.IT_GetList:IVarset;
begin
  InternalLock;
  try
    Result:=FList;
  finally
    InternalUnlock;
  end;
end;

Function TProcessesList.ITRefresh:Integer;
  Type
    TIDProcess = Array[0..1023] of THandle;
  Var tmpIDProcess:TIDProcess;
      tmpNeeded:Cardinal;
      tmpI:Integer;
      tmpProcess:THandle;
      tmpPChar:PChar;
      tmpIProcessInfo:IProcessInfo;
begin
  InternalLock;
  try
    Result:=0;
    FList.ITClear;
    If Not EnumProcesses(@tmpIDProcess, SizeOf(tmpIDProcess), tmpNeeded) Then begin
      Result:=GetLastError;
      Exit;
    end;
    GetMem(tmpPChar, MAX_PATH);
    try
      For tmpI:=0 to (tmpNeeded div SizeOf(THandle))-1 do begin
        If (tmpIDProcess[tmpI]=0) Then Continue;
        tmpIProcessInfo:=TProcessInfo.Create;
        tmpIProcessInfo.ITPID:=tmpIDProcess[tmpI];
        tmpProcess:=OpenProcess(PROCESS_QUERY_INFORMATION Or PROCESS_VM_READ, FALSE, tmpIDProcess[tmpI]);
        If tmpProcess<>0 Then begin
          try
            If Boolean(GetModuleFileNameEx(tmpProcess, 0, tmpPChar, MAX_PATH)) Then begin
              tmpIProcessInfo.ITPathEXE:=tmpPChar;
            end else begin
              //fail
              tmpIProcessInfo.ITErrorMessage:='GetModuleFileNameEx: '+SysErrorMessage(GetLastError);
            end;
          finally
            CloseHandle(tmpProcess);
          end;
        end else begin
          //fail
          tmpIProcessInfo.ITErrorMessage:='OpenProcess: '+SysErrorMessage(GetLastError);
        end;
        //добавл€ю
        FList.ITPushV(tmpIProcessInfo);
        tmpIProcessInfo:=Nil;
      end;
    finally
      FreeMem(tmpPChar, MAX_PATH);
    end;
  finally
    InternalUnlock;
  end;
end;

end.
