//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UUniqueStrUtils;

interface
  function UniqueStringStrong:AnsiString;
  function UniqueStringNormal:AnsiString;
  function UniqueStringLow:AnsiString;

implementation
  uses windows, UMachineNameConsts, UDateTimeUtils, UCalculus, Sysutils;  
var CSLockStrong, CSLockNormal, CSLockLow:TRTLCriticalSection;
    cnLastUniqueStringStrong:ansistring='';
    cnLastUniqueStringNormal:ansistring='';
    cnLastUniqueStringLow:ansistring='';

function UniqueStringStrong:AnsiString;
begin
  EnterCriticalSection(CSLockStrong);
  try
    repeat
      result:=cnMachineName+Int64ToSBase(DateTimeToMSecs(Now), cnEnBase)+'_'+Int64ToSBase(Random(916132831{zzzzz}), cnEnBase);
    until cnLastUniqueStringStrong<>result;
    cnLastUniqueStringStrong:=Result;
  finally
    LeaveCriticalSection(CSLockStrong);
  end;
end;

function UniqueStringNormal:AnsiString;
begin
  EnterCriticalSection(CSLockNormal);
  try
    repeat
      result:=cnMachineSName+Int64ToSBase(DateTimeToMSecs(Now), cnEnBase);//+'_'+Int64ToSBase(Random(3843{zz}), cnEnBase);
    until cnLastUniqueStringNormal<>result;
    cnLastUniqueStringNormal:=Result;
  finally
    LeaveCriticalSection(CSLockNormal);
  end;
end;

function UniqueStringLow:AnsiString;
begin
  EnterCriticalSection(CSLockLow);
  try
    repeat
      result:=Int64ToSBase(DateTimeToMSecs(Now), cnEnBase);
    until cnLastUniqueStringLow<>result;
    cnLastUniqueStringLow:=Result;
  finally
    LeaveCriticalSection(CSLockLow);
  end;
end;

initialization
  InitializeCriticalSection(CSLockStrong);
  InitializeCriticalSection(CSLockNormal);
  InitializeCriticalSection(CSLockLow);
finalization
  DeleteCriticalSection(CSLockLow);
  DeleteCriticalSection(CSLockNormal);
  DeleteCriticalSection(CSLockStrong);
end.
