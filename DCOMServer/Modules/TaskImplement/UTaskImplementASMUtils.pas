unit UTaskImplementASMUtils;

interface
  uses UTTaskTypes, UCallerTypes, UTaskImplementTypes;

  function TaskImplementASM(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;

implementation
  uses UAdmittanceASMTypes, UTrayConsts, Sysutils, UErrorConsts, UAppMessageTypes, Variants, UTTaskUtils;

function TaskImplementASM(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;
  var tmpAdmittanceASM:IAdmittanceASM;
  function localGetAdmittanceASM:IAdmittanceASM; begin
    if not assigned(tmpAdmittanceASM) then cnTray.Query(IAdmittanceASM, tmpAdmittanceASM);
    result:=tmpAdmittanceASM;
  end;
  var tmpInteger:Integer;
begin
  result:=true;
  case aTask of
    tskMTStopAllASM:begin//In Empty
      IAppMessage(cnTray.Query(IAppMessage)).ITMessAdd(Now, Now, aCallerAction.UserName, 'ImplASM', 'tskMTStopAllASM.', mecApp, mesWarning);
      tmpInteger:=localGetAdmittanceASM.StopAllASMServers;
      If assigned(aTaskContext) then begin
        if assigned(aTaskContext^.aResult) then aTaskContext^.aResult^:=tmpInteger;
        aTaskContext^.aSetResult:=true;
        aTaskContext^.aManualResultSet:=false;//разрешаю автоматическую отработку SetComplete??
      end;
    end;//Out varInteger:(Count)
    tskMTStopASMOnID:begin//In varInteger:(ASMID)
      IAppMessage(cnTray.Query(IAppMessage)).ITMessAdd(Now, Now, aCallerAction.UserName, 'ImplASM', 'tskMTStopASMOnID: for ASMId '+IntToStr(Integer(aParams))+'.', mecApp, mesWarning);
      tmpInteger:=localGetAdmittanceASM.StopASMServerOnID(aParams);
      If assigned(aTaskContext) then begin
        if assigned(aTaskContext^.aResult) then aTaskContext^.aResult^:=tmpInteger;
        aTaskContext^.aSetResult:=true;
        aTaskContext^.aManualResultSet:=false;//разрешаю автоматическую отработку SetComplete??
      end;
    end;//Out varInteger:(Count)
    tskMTStopASMOnUser:begin//In varString:(ASMUser)
      IAppMessage(cnTray.Query(IAppMessage)).ITMessAdd(Now, Now, aCallerAction.UserName, 'ImplASM', 'tskMTStopASMOnUser: for user '''+VarToStr(aParams)+'''.', mecApp, mesWarning);
      tmpInteger:=localGetAdmittanceASM.StopASMServerOnUser(aParams);
      If assigned(aTaskContext) then begin
        if assigned(aTaskContext^.aResult) then aTaskContext^.aResult^:=tmpInteger;
        aTaskContext^.aSetResult:=true;
        aTaskContext^.aManualResultSet:=false;//разрешаю автоматическую отработку SetComplete??
      end;
    end;//Out varInteger:(Count)
    tskMTUpdateASMList:begin//In MyParams: [0]:varInteger(ASMNum); [1]:varArray(ASM Info)
      localGetAdmittanceASM.ListUpdate(aParams[0], aParams[1]);
    end;//Out Res: Empty
  else
    if aRaise then Raise Exception.CreateFmtHelp(cserInternalError, ['Unsupported for '+MTaskToStr(aTask)], cnerInternalError) else result:=false;
  end;
end;

end.
