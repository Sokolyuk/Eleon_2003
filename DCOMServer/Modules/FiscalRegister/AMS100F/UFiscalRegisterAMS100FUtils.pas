unit UFiscalRegisterAMS100FUtils;

interface
  uses windows, UFiscalRegisterAMS100FUtilsTypes;

  procedure DefaultAppCheckPrepare(Progress: Integer);stdcall;
  procedure DefaultAppError(ErrorCode: Integer; ErrorMsg: PChar);stdcall;
  procedure DefaultQuery;stdcall;
  procedure DefaultCloseCheck;stdcall;

implementation

procedure DefaultAppCheckPrepare(Progress: Integer);
begin
  EnterCriticalSection(cnSetAMS100FEvents);
  try
    if assigned(cnOnCheckPrepare) then cnOnCheckPrepare(Progress);
  finally
    LeaveCriticalSection(cnSetAMS100FEvents);
  end;
end;

procedure DefaultAppError(ErrorCode: Integer; ErrorMsg: PChar);
begin
  EnterCriticalSection(cnSetAMS100FEvents);
  try
    if assigned(cnOnError) then cnOnError(ErrorCode, ErrorMsg);
  finally
    LeaveCriticalSection(cnSetAMS100FEvents);
  end;
end;

procedure DefaultQuery;
begin
  EnterCriticalSection(cnSetAMS100FEvents);
  try
    if assigned(cnOnQuery) then cnOnQuery();
  finally
    LeaveCriticalSection(cnSetAMS100FEvents);
  end;
end;

procedure DefaultCloseCheck;
begin
  EnterCriticalSection(cnSetAMS100FEvents);
  try
    if assigned(cnOnCloseCheck) then cnOnCloseCheck();
  finally
    LeaveCriticalSection(cnSetAMS100FEvents);
  end;
end;

end.
