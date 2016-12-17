unit UTaskImplementDcomManagerServer;

interface
  uses UTaskImplement, UCallerTypes, UTTaskTypes, UTaskImplementTypes;

  function TaskImplementDcomManagerServer(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;

implementation
  uses UTrayConsts, UAppMessageTypes, Sysutils, UTrayTypes, DateUtils, UVarsetTypes, UProcessInfoTypes, UEServersTypes,
       UEServerInfoTypes, UErrorConsts, Comobj, Windows, Variants, UProjectUtils, UTypeUtils, UThreadsPoolTypes,
       Pegas_TLB, EMServer_TLB;

Procedure InternalStartServer(aCallerAction:ICallerAction; aIEServerInfo:IEServerInfo);
begin
  If Not Assigned(aIEServerInfo) Then Raise Exception.Create('IEServerInfo is not assigned.');
  aCallerAction.ITMessAdd(now, now, '', 'InternalStartServer: RegName='''+aIEServerInfo.ITRegName+'''.', mecApp, mesInformation);
  try
    CreateRemoteComObject('', StringToGUID(aIEServerInfo.ITMasterGUID));
  except on e:exception do begin
    try
      CreateRemoteComObject('', StringToGUID(aIEServerInfo.ITGUID));
    except
      on e1:exception do raise exception.Create(E1.Message+'(PrevErr:'+e.Message+')');
    end;
  end;end;
end;

function GetComputerName:AnsiString;
Var st:PChar;
    Len:Cardinal;
Begin
  Len:=80;
  GetMem(st,80);
  Windows.GetComputerName(st, Len);
  Result:=st;
  FreeMem(st, 80);
end;

Procedure InternalStopServerViaIMasterServer(aCallerAction:ICallerAction; aIEServerInfo:IEServerInfo; aMessageCount, aMessageInterval:Integer; Const aMessage:AnsiString);
  Var tmpCnn:Variant;
      tmpIUnknown:IUnknown;
      tmpIDispatch:IDispatch;
      tmpParam1, tmpParam2:Integer;
      tmpParam3:WideString;
      tmpStart:TDateTime;
  function localGetMessage:AnsiString;
  begin
    Case aIEServerInfo.ITType of
      1:result:='Office Server';
      2:result:='Shop Server';
    else
      result:='Unknown Server';
    end;
    result:=result+' <'+GetComputerName+'.'''+aIEServerInfo.ITRegName+'''> is STOPPING.'
  end;
begin
  tmpStart:=now;
  aCallerAction.ITMessAdd(tmpStart, now, '', 'InternalStopServerViaIMasterServer: '''+aIEServerInfo.ITRegName+'''.', mecApp, mesInformation);
  tmpIUnknown:=IDispatch(CreateRemoteComObject('', StringToGUID(aIEServerInfo.ITMasterGUID)));
  tmpIDispatch:=tmpIUnknown as IDispatch;
  tmpCnn:=tmpIDispatch;
  tmpIDispatch:=Nil;
  tmpIUnknown:=Nil;
  try
    If Not VarIsEmpty(tmpCnn) Then begin
      tmpCnn.ETaskAdd(tskMTSendMessToAll, VarArrayOf(['DcomMgrSrv', localGetMessage]), Unassigned);
      If aMessage='' Then begin
        tmpParam1:=0;
        tmpParam2:=4000;
        tmpParam3:='';
      end else begin
        tmpParam1:=aMessageCount;
        tmpParam2:=aMessageInterval;
        tmpParam3:=aMessage;
      end;
      tmpCnn.ETaskAdd(tskMTShotDownServer, VarArrayOf([tmpParam1, tmpParam2, tmpParam3]), Unassigned);
    end else raise exception.Create('tmpIMasterServerDisp is not assigned.');
  finally
    VarClear(tmpCnn);
  end;
end;

Function InternalWaitForStopServer(aCallerAction:ICallerAction; Const aRegName:AnsiString; aPID:Cardinal; aTimeOut:Cardinal):Boolean;
  Var tmpStart:TDateTime;
      tmpDouble:Double;
      tmpRemainTimeout:Integer;
begin
  tmpStart:=Now;
  aCallerAction.ITMessAdd(tmpStart, now, '', 'InternalWaitForStopServer: RegName='''+aRegName+''', PID='+IntToStr(aPID)+'.', mecApp, mesInformation);
  If aPID=0 Then Raise Exception.Create('Server Regname='''+aRegName+''' is not started(PID=0).');
  Case glCheckStartedServerOfPID(aRegName, aPID, aTimeOut) of
    True:begin
      Result:=False;
    end;
    False:begin
      Result:=true;
    end;
  Else
    Result:=False;
  End;
  try//Remain timeout
    tmpDouble:=Now-tmpStart;
    tmpDouble:=tmpDouble*MSecsPerDay;
    tmpRemainTimeout:=aTimeOut-Round(tmpDouble);
  except
    tmpRemainTimeout:=60000{60sec};
  end;
  While true do begin//Stop Pid
    If Not glPIDCheckExist(aPID) Then begin
      Result:=true;
      Break;
    end;
    If tmpRemainTimeout>0 Then begin
      dec(tmpRemainTimeout, 500);
      Sleep(500);
    end else begin
      Result:=False;
      aCallerAction.ITMessAdd(tmpStart, now, '', 'InternalWaitForStopServer: RegName='''+aRegName+''', PID='+IntToStr(aPID)+': PID EXIST, Timeout expired.', mecApp, mesInformation);
      break;
    end;
  end;
end;

Procedure InternalTerminateProcessOfPID(aCallerAction:ICallerAction; aPID:Cardinal);
  Var tmpHandle:THandle;
begin
  aCallerAction.ITMessAdd(now, now, '', 'InternalTerminateProcessOfPID: PID='+IntToStr(aPID)+'.', mecApp, mesInformation);
  If aPID=0 Then Raise Exception.Create('TerminateProcess: PID=0.');
  tmpHandle:=OpenProcess(PROCESS_TERMINATE, False, aPID);
  If tmpHandle=0 Then Raise Exception.Create('OpenProcess(Handle=0): '+SysErrorMessage(GetLastError));
  If Not TerminateProcess(tmpHandle, 0) then Raise Exception.Create('TerminateProcess: '+SysErrorMessage(GetLastError));
end;

Procedure InternalRestartEServer(aCallerAction:ICallerAction; aIEServerInfo:IEServerInfo; aPID:Cardinal);
begin
  If aPID=0 Then Raise Exception.Create('PID=0.');
  InternalStopServerViaIMasterServer(aCallerAction, aIEServerInfo, 6, 30000{3min}, aIEServerInfo.ITAutorestartMessage);
  If Not InternalWaitForStopServer(aCallerAction, aIEServerInfo.ITRegName, aPID, 360000{6min}) Then InternalTerminateProcessOfPID(aCallerAction, aPID);
  aIEServerInfo.ITPIDDelete(aPID);
  InternalStartServer(aCallerAction, aIEServerInfo);
end;


Procedure InternalChekEServers(aCallerAction:ICallerAction);
  procedure localSetMessage(aStartTime:TDateTime; const aMessage:AnsiString; aMec:TMessageClass; aMes:TMessageStyle);begin
    aCallerAction.ITMessAdd(aStartTime, now, aCallerAction.UserName, aMessage, aMec, aMes);
  end;
  Function lInternalCheckTime(aType:Integer; aBeg, aEnd:TDateTime; Out aLastExec:TDateTime):Boolean;
    Var tmpBeg, tmpEnd:TDateTime;
        AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond:Word;
  begin
    If aType<>3 Then Raise Exception.Create('Type='+IntToStr(aType)+' unsupported.');
    //aType=3--Раз в день
    DecodeTime(aBeg, aHour, aMinute, aSecond, aMilliSecond);
    DecodeDate(Now, aYear, aMonth, aDay);
    tmpBeg:=EncodeDateTime(aYear, aMonth, aDay, aHour, aMinute, aSecond, aMilliSecond);
    DecodeTime(aEnd, aHour, aMinute, aSecond, aMilliSecond);
    DecodeDate(Now, aYear, aMonth, aDay);
    tmpEnd:=EncodeDateTime(aYear, aMonth, aDay, aHour, aMinute, aSecond, aMilliSecond);
    Result:=(Now>tmpBeg)And(Now<tmpEnd);
    If Result Then aLastExec:=aBeg else aLastExec:=0;
  end;
  Var tmpIntIndex:Integer;
      tmpIVarsetDataView:IVarsetDataView;
      tmpEServersList:IVarset;
      tmpIUnknown:IUnknown;
      tmpPIDStarted:Cardinal;
      tmpProcInfo:TProcInfo;
      tmpAutorestartCritical, tmpAutorestartNormal:Cardinal;
      tmpV:Variant;
      tmpLastExec:TDateTime;
      tmpStartTime:TDateTime;
      tmpIEServerInfo:IEServerInfo;
begin
  tmpStartTime:=now;
  try
    tmpEServersList:=IEServers(cnTray.Query(IEServers)).ITEServersList.ITList;
    tmpIntIndex:=-1;
    while true do begin
      tmpIVarsetDataView:=tmpEServersList.ITViewNextGetOfIntIndex(tmpIntIndex);
      If tmpIntIndex=-1 then break;
      tmpIUnknown:=tmpIVarsetDataView.ITData;
      if (not assigned(tmpIUnknown))or(tmpIUnknown.QueryInterface(IEServerInfo, tmpIEServerInfo)<>S_OK)or(not assigned(tmpIEServerInfo)) then Raise Exception.CreateFmtHelp(cserInternalError, ['IEServerInfo no found'], cnerInternalError);
      tmpPIDStarted:=tmpIEServerInfo.ITPIDStarted;
      If tmpPIDStarted=0{No started} Then begin
        If tmpIEServerInfo.ITAutoKeepStarted Then begin
          try
            InternalStartServer(aCallerAction, tmpIEServerInfo);
            localSetMessage(tmpStartTime, 'AutoKeepStarted(RegName='''+tmpIEServerInfo.ITRegName+'''): ЗАПУЩЕН', mecApp, mesInformation);
          except on e:exception do begin
            localSetMessage(tmpStartTime, 'AutoKeepStarted(RegName='''+tmpIEServerInfo.ITRegName+'''): '+e.Message+'/HC='+IntToStr(e.HelpContext), mecApp, mesError);
          end;end;
        end;
      end else begin//Started
        try
          tmpProcInfo:=tmpIEServerInfo.ITProcessInfo.ITInfo;
          tmpAutorestartCritical:=tmpIEServerInfo.ITAutorestartCritical;
          tmpAutorestartNormal:=tmpIEServerInfo.ITAutorestartNormal;
          If (tmpAutorestartCritical>0)And(tmpProcInfo.MemoryCounters.PagefileUsage>=tmpAutorestartCritical) Then begin//Нужно срочно перезапустить
            try
              InternalRestartEServer(aCallerAction, tmpIEServerInfo, tmpPIDStarted);
              localSetMessage(tmpStartTime, 'InternalRestartEServer(RegName='''+tmpIEServerInfo.ITRegName+''', PID='+IntToStr(tmpPIDStarted)+')-Critical(VMSize='+IntToStr(tmpProcInfo.MemoryCounters.PagefileUsage)+'>Critical='+IntToStr(tmpAutorestartCritical)+'): ПЕРЕЗАПУЩЕН', mecApp, mesInformation);
            except on e:exception do
              localSetMessage(tmpStartTime, 'InternalRestartEServer(RegName='''+tmpIEServerInfo.ITRegName+''', PID='+IntToStr(tmpPIDStarted)+')-Critical(VMSize='+IntToStr(tmpProcInfo.MemoryCounters.PagefileUsage)+'>Critical='+IntToStr(tmpAutorestartCritical)+'): '+e.Message+'/HC='+IntToStr(e.HelpContext), mecApp, mesError);
            end;
          end else begin
            If (tmpAutorestartNormal>0)And(tmpProcInfo.MemoryCounters.PagefileUsage>=tmpAutorestartNormal) Then begin//Можно бы и перезапустить
              tmpV:=tmpIEServerInfo.IT_GetAutorestartNornalPeriod;
              If lInternalCheckTime(tmpV[0], tmpV[1], tmpV[2], tmpLastExec) Then begin//Пора
                try
                  InternalRestartEServer(aCallerAction, tmpIEServerInfo, tmpPIDStarted);
                  localSetMessage(tmpStartTime, 'InternalRestartEServer(RegName='''+tmpIEServerInfo.ITRegName+''', PID='+IntToStr(tmpPIDStarted)+')-Normal(VMSize='+IntToStr(tmpProcInfo.MemoryCounters.PagefileUsage)+'>Normal='+IntToStr(tmpAutorestartNormal)+'): ПЕРЕЗАПУЩЕН', mecApp, mesInformation);
                  tmpV[3]:=tmpLastExec;
                  tmpIEServerInfo.IT_SetAutorestartNornalPeriod(glVarArrayToString(tmpV));
                except on e:exception do
                  localSetMessage(tmpStartTime, 'InternalRestartEServer(RegName='''+tmpIEServerInfo.ITRegName+''', PID='+IntToStr(tmpPIDStarted)+')-Normal(VMSize='+IntToStr(tmpProcInfo.MemoryCounters.PagefileUsage)+'>Normal='+IntToStr(tmpAutorestartNormal)+'): '+e.Message+'/HC='+IntToStr(e.HelpContext), mecApp, mesError);
                end;
              end else begin//Можнобы но не время
                localSetMessage(tmpStartTime, 'InternalRestartEServer(RegName='''+tmpIEServerInfo.ITRegName+''', PID='+IntToStr(tmpPIDStarted)+')-Normal(VMSize='+IntToStr(tmpProcInfo.MemoryCounters.PagefileUsage)+'>Normal='+IntToStr(tmpAutorestartNormal)+'): НЕВРЕМЯ', mecApp, mesInformation);
              end;
            end else begin//Не нужно
              localSetMessage(tmpStartTime, 'InternalRestartEServer(RegName='''+tmpIEServerInfo.ITRegName+''', PID='+IntToStr(tmpPIDStarted)+')-Normal(VMSize='+IntToStr(tmpProcInfo.MemoryCounters.PagefileUsage)+'<Normal='+IntToStr(tmpAutorestartNormal)+'): НЕНУЖНО', mecApp, mesInformation);
            end;
          end;
        except on e:exception do begin
          localSetMessage(tmpStartTime, 'Check started process(RegName='''+tmpIEServerInfo.ITRegName+''', PID='+IntToStr(tmpPIDStarted)+'): '+e.message, mecApp, mesError);
        end;end;
      end;
    end;
    tmpIUnknown:=Nil;
    tmpIEServerInfo:=Nil;
    tmpIVarsetDataView:=Nil;
    tmpEServersList:=Nil;
  except
    on e:exception do begin
      raise exception.Create('InternalChekEServers: '+e.Message);
    end;
  end;
end;

Procedure InternalCheckEServersReg(aIEServers:IEServers);
begin
  If not assigned(aIEServers) Then Exit;
  aIEServers.ITCheck;
end;

Procedure InternalEServerLogin(aDispatch:IDispatch; Const aUser, aPass:WideString; aConnectType:Integer; Out aSecurityContext:OleVariant; Out aLoginLevel:Integer);
  Var {$Warnings off}tmpAUPegas:IAUPegasDisp;
      tmpEAMServer:IEAMServerDisp;{$Warnings on}
  Function localInt64ToDouble(aValue:Int64):Double;
    Type
      TLocalInt64 = record
        Case Word of
          0:(ofInt64:Int64);   {8 byte}
          1:(ofIntLow:Integer; ofIntHigh:Integer); {4+4 byte}
          2:(ofDouble:Double); {8 byte}
          3:(ofComp:Comp);     {8 byte}
          4:(ofDateTime:TDateTime); {8 byte}
      end;
    Var tmpLocalInt64:TLocalInt64;
  begin
    tmpLocalInt64.ofInt64:=aValue;
    Result:=tmpLocalInt64.ofDouble;
  end;
  //Var tmpLastError:Integer;
begin
  If Not Assigned(aDispatch) Then Raise Exception.Create('aDispatch is not assigned.');
  Case aConnectType of
    1:begin{$Warnings off}
      tmpAUPegas:=IAUPegasDisp(aDispatch as IDispatch);
      tmpAUPegas.ELoginEx(Unassigned, aUser, aPass, aSecurityContext, aLoginLevel);
      tmpAUPegas.ERegAppMask:=localInt64ToDouble(8);
    end;
    2:begin
      tmpEAMServer:=IEAMServerDisp(aDispatch as IDispatch);
      tmpEAMServer.ELoginEx(aUser, aPass, aSecurityContext, aLoginLevel);
      tmpEAMServer.ERegAppMask:=localInt64ToDouble(8);
    end;{$Warnings on}
  else
    Raise Exception.Create('unknown Connection type='+IntToStr(aConnectType)+'.');  
  end;(*{$Warnings off}If (aDispatch.QueryInterface({IAUPegas}CLASS_AUPegas, tmpAUPegas)<>S_OK) then begin tmpLastError:=GetLastError; If (aDispatch.QueryInterface({IEAMServer}CLASS_EAMServer, tmpEAMServer)<>S_OK) then Raise Exception.Create('Unable to get interface(Pg='+SysErrorMessage(tmpLastError)+'/Em='+SysErrorMessage(GetLastError)+').'); end; {$Warnings on} If Assigned(tmpAUPegas) Then begin tmpAUPegas.ELoginEx(Unassigned, aUser, aPass, aSecurityContext, aLoginLevel); tmpAUPegas.ERegAppMask:=localInt64ToDouble(8); end else If Assigned(tmpEAMServer) Then begin tmpEAMServer.ELoginEx(aUser, aPass, aSecurityContext, aLoginLevel); tmpEAMServer.ERegAppMask:=localInt64ToDouble(8); end else Raise Exception.Create('Interface not assigned.');*)
end;

Function InternalCMDStopEServer(aCallerAction:ICallerAction; Const aRegName:AnsiString; aMessageCount, aMessageInterval:Integer; Const aMessage:AnsiString; aForceTerminate:Boolean):Cardinal;
  Var tmpIEServerInfo:IEServerInfo;
begin
  tmpIEServerInfo:=IEServers(cnTray.Query(IEServers)).ITEServersList.ITEServerOfRegName(aRegName);
  Result:=tmpIEServerInfo.ITPIDStarted;
  InternalStopServerViaIMasterServer(aCallerAction, tmpIEServerInfo, aMessageCount, aMessageInterval, aMessage);
  If (aForceTerminate)And(Not InternalWaitForStopServer(aCallerAction, tmpIEServerInfo.ITRegName, Result, aMessageCount*aMessageInterval+120000{2min})) Then InternalTerminateProcessOfPID(aCallerAction, Result);
  tmpIEServerInfo.ITPIDDelete(Result);
end;

Procedure InternalCMDStartEServer(aCallerAction:ICallerAction; Const aRegName:AnsiString);
begin
  InternalStartServer(aCallerAction, IEServers(cnTray.Query(IEServers)).ITEServersList.ITEServerOfRegName(aRegName));
end;

Procedure InternalCMDRestartEServer(aCallerAction:ICallerAction; Const aRegName:AnsiString; aMessageCount, aMessageInterval:Integer; Const aMessage:AnsiString);
begin
  InternalCMDStopEServer(aCallerAction, aRegName, aMessageCount, aMessageInterval, aMessage, True);
  InternalCMDStartEServer(aCallerAction, aRegName);
end;

function TaskImplementDcomManagerServer(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;
  var tmpOleVariant:OleVariant;
      tmpInteger:Integer;
begin
  result:=true;
  if assigned(aTaskContext) then aTaskContext^.aManualResultSet:=true;
  case aTask of
    tskMTDMSCheckEServers:begin
      try
        InternalChekEServers(aCallerAction);
      finally
        IThreadsPool(cnTray.Query(IThreadsPool)).ITMSleepTaskAdd(aTask, aParams, aCallerAction, aParams[0]);
      end;
    end;
    tskMTDMSCheckEServersReg:begin
      try
        InternalCheckEServersReg(IEServers(cnTray.Query(IEServers)));
      finally
        IThreadsPool(cnTray.Query(IThreadsPool)).ITMSleepTaskAdd(aTask, aParams, aCallerAction, aParams[0]);
      end;
    end;
    tskMTDMSEServerLogin:begin//[0]-varDispath:(IAuPegas или IEAMServer); [1]-varOleStr:(User); [2]-varOleStr:(Pass);
      //tmpInteger:=-1;//от варнингов
      tmpOleVariant:=Unassigned;//от варнингов
      InternalEServerLogin(aParams[0], aParams[1], aParams[2], aParams[3], tmpOleVariant, tmpInteger);
      if (assigned(aTaskContext))and(assigned(aTaskContext^.aResult)) then begin
        aTaskContext^.aResult^:=VarArrayOf([tmpOleVariant, tmpInteger]);//[0]-varVariant:(SecurityContext; [1]-varIntger:(LoginLevel);
        aTaskContext^.aSetResult:=true;
      end;
    end;
    tskMTDMSStopServer:begin
      //[0]-varOleStr:(ServerRegName); [1]-varInteger:(Count); [2]-varInteger:(Interval); [3]-varOleStr:(Message); [4]-varBoolean:(ForceTerminate);
      //[0]-varOleStr:(ServerRegName); Count=0; Interval=5000; Message=''; ForceTerminate=True;
      If VarIsArray(aParams) Then begin
        InternalCMDStopEServer(aCallerAction, aParams[0]{RegName}, aParams[1]{count}, aParams[2]{Interval}, aParams[3]{Message}, aParams[4]{ForceTerminate});
      end else begin
        InternalCMDStopEServer(aCallerAction, aParams{RegName}, 0{count}, 4000{Interval}, ''{Message}, True{ForceTerminate});
      end;
    end;
    tskMTDMSReStartServer:begin
      //[0]-varOleStr:(ServerRegName); [1]-varInteger:(Count); [2]-varInteger:(Interval); [3]-varOleStr:(Message); [4]-varBoolean:(ForceTerminate);
      //varOleStr:(ServerRegName); Count=0; Interval=5000; Message=''; ForceTerminate=True;
      If VarIsArray(aParams) Then begin
        InternalCMDRestartEServer(aCallerAction, aParams[0]{RegName}, aParams[1]{count}, aParams[2]{Interval}, aParams[3]{Message});
      end else begin
        InternalCMDRestartEServer(aCallerAction, aParams{RegName}, 0{count}, 4000{Interval}, ''{Message});
      end;
    end;
    tskMTDMSStartServer:begin//varOleStr:(ServerRegName);
      InternalCMDStartEServer(aCallerAction, aParams{RegName});
    end;
  end;
end;

end.
