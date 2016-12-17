unit UPackCPTUtils;

interface
  uses UPackCPTUtilsTypes, UPackCPTTypes, UPackPDTypes, UPackCPRTypes;

  function ExecuteCPT(aPackPD:IPackPD; aPackCPT:IPackCPT; aResultPackCPR:IPackCPR; aPExecuteCPTStruct:PExecuteCPTStruct):boolean;

implementation
  uses UCallerTypes{$IFDEF VER150}, Variants{$ENDIF}{$IFDEF VER140}, Variants{$ENDIF}, UPackCPTaskTypes, UVarsetTypes, Sysutils, UErrorConsts, UVarset, UADMTypes;

function ExecuteCPT(aPackPD:IPackPD; aPackCPT:IPackCPT; aResultPackCPR:IPackCPR; aPExecuteCPTStruct:PExecuteCPTStruct):boolean;
  function localGetParam(aCPTOptions:TCPTOptions; aPackCPTask:IPackCPTask):Variant;begin
    if ctoReturnParamsIfError in aPackCPT.CPTOptions then result:=aPackCPTask.param{������� ��������� ���� ������} else result:=unassigned;
  end;
  function localGetSecurityContext(aCallerAction:ICallerAction):variant;begin
    if assigned(aCallerAction) then result:=aCallerAction.SecurityContext else result:=unassigned;
  end;
  var tmpIntIndex:Integer;
      tmpIPackCPTask:IPackCPTask;
      tmpListOfBreakedBlock:IVarset;
      tmpIVarsetData:IVarsetData;
      tmpResult:variant;
      tmpSetResult:boolean;
begin
  Result:=Unassigned;
  try
    if not assigned(aPackCPT) then raise exception.createFmtHelp(cserInternalError, ['aPackCPT not assigned'], cnerInternalError);
    tmpListOfBreakedBlock:=TVarset.Create;
    try
      tmpListOfBreakedBlock.ITConfigIntIndexAssignable:=True;
      tmpListOfBreakedBlock.ITConfigCheckUniqueIntIndex:=True;
      tmpListOfBreakedBlock.ITConfigCheckUniqueStrIndex:=False;
      tmpListOfBreakedBlock.ITConfigNoFoundException:=False;
      tmpListOfBreakedBlock.ITConfigCaseSensitive:=False;
      if assigned(aResultPackCPR) then aResultPackCPR.CPID:=aPackCPT.CPID;//����� � CPR ��� ����� �� ID ��� � � CPT.
      tmpIntIndex:=-1;
      while true do begin
        tmpIPackCPTask:=aPackCPT.CPTasks.ViewNext(tmpIntIndex);
        if tmpIntIndex=-1 then break;
        if not assigned(tmpIPackCPTask) then raise exception.createFmtHelp(cserInternalError, ['tmpIPackCPTask not assigned'], cnerInternalError);
        //�������� ������� �������� ������ ����������� ��� �� ���� �������
        if tmpListOfBreakedBlock.ITExistsIntIndex(tmpIPackCPTask.BlockID) then Continue;//������. �������� ������������.
        tmpResult:=unassigned;
        tmpSetResult:=false;
        try
          if (assigned(aPExecuteCPTStruct))and(assigned(aPExecuteCPTStruct^.OnCheckSecurityADMTaskCPTTask)) then aPExecuteCPTStruct^.OnCheckSecurityADMTaskCPTTask(aPExecuteCPTStruct^.aUserData, tmpIPackCPTask.Task, aPackCPT.PackID, localGetSecurityContext(aPackCPT.CallerAction));
          case tmpIPackCPTask.Task of
            tskADMNone:;
          else
            if (assigned(aPExecuteCPTStruct))and(assigned(aPExecuteCPTStruct^.OnReceiveCPTTask)) then tmpIPackCPTask.Worked:=aPExecuteCPTStruct^.OnReceiveCPTTask(aPExecuteCPTStruct^.aUserData, aPackPD, aPackCPT, tmpIPackCPTask, @tmpSetResult, @tmpResult) else tmpIPackCPTask.Worked:=false;
            result:=result and tmpIPackCPTask.Worked;
          end;
          if tmpSetResult and(assigned(aResultPackCPR)) then aResultPackCPR.Add(tmpIPackCPTask.Task, tmpResult, tmpIPackCPTask.RouteParam, tmpIPackCPTask.BlockID);
        except on e:exception do begin
          if assigned(aResultPackCPR) then aResultPackCPR.AddWithError(tmpIPackCPTask.Task, localGetParam(aPackCPT.CPTOptions, tmpIPackCPTask), tmpIPackCPTask.RouteParam, tmpIPackCPTask.BlockID, e.message, e.HelpContext);//������������ ���������
          if tmpIPackCPTask.BlockID<>-1 then begin//�������� ����� ����� � ������ ��������� ������, �.�. ��������� ������
            tmpIVarsetData:=TVarsetData.Create;
            tmpIVarsetData.ITIntIndex:=tmpIPackCPTask.BlockID;
            tmpListOfBreakedBlock.ITPush(tmpIVarsetData);
            tmpIVarsetData:=nil;
          end;
        end;end;
      end;
    finally
      tmpListOfBreakedBlock:=nil;
    end;
  except on e:exception do begin
    e.message:='ExecuteCPT: '+e.message;
    raise;
  end;End;
end;

end.
