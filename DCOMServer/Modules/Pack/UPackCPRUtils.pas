//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UPackCPRUtils;

interface
  uses UPackCPRUtilsTypes, UPackCPRTypes, UPackPDTypes;

  function ExecuteCPR(aPackPD:IPackPD; aPackCPR:IPackCPR; aPExecuteCPRStruct:PExecuteCPRStruct):Boolean;

implementation
  uses Sysutils, UErrorConsts, UPackCPTasksTypes, UPackCPTaskTypes, UVarset, UVarsetTypes, UADMTypes, UAppMessageTypes
       {$IFDEF VER150}, Variants{$ENDIF}{$IFDEF VER140}, Variants{$ENDIF}, UCallerTypes;
       
function ExecuteCPR(aPackPD:IPackPD; aPackCPR:IPackCPR; aPExecuteCPRStruct:PExecuteCPRStruct):Boolean; //True-все отработано, False-не отработано что то или все
  function localGetSecurityContext(aCallerAction:ICallerAction):variant;begin
    if assigned(aCallerAction) then result:=aCallerAction.SecurityContext else result:=unassigned;
  end;
  var tmpErrorCount:Integer;
      tmpIntIndex:Integer;
      tmpIPackCPTask:IPackCPTask;
      tmpListOfBreakedBlock:IVarset;
      tmpIVarsetData:IVarsetData;
      tmpEHelpContext:Integer;
      tmpEMessage:AnsiString;
begin
  try
    if not assigned(aPackCPR) then raise exception.createFmtHelp(cserInternalError, ['aPackCPR not assigned'], cnerInternalError);
    Result:=assigned(aPExecuteCPRStruct);//Изначально ставлю что все отработано(True). а если aPExecuteCPRStruct не назначено то ничего естественно отработать не может, по этому-False.
    tmpIPackCPTask:=nil;
    tmpIVarsetData:=nil;
    tmpListOfBreakedBlock:=TVarset.Create;
    try
      tmpListOfBreakedBlock.ITConfigIntIndexAssignable:=True;
      tmpListOfBreakedBlock.ITConfigCheckUniqueIntIndex:=True;
      tmpListOfBreakedBlock.ITConfigCheckUniqueStrIndex:=False;
      tmpListOfBreakedBlock.ITConfigNoFoundException:=False;
      tmpListOfBreakedBlock.ITConfigCaseSensitive:=False;
      tmpErrorCount:=aPackCPR.CPErrors.Count;
      //tmpIPackCPTasks:=aPackCPR.CPTasks;
      tmpIntIndex:=-1;
      while true do begin
        tmpIPackCPTask:=aPackCPR.CPTasks.ViewNext(tmpIntIndex);
        if tmpIntIndex=-1 then break;
        if not assigned(tmpIPackCPTask) then raise exception.createFmtHelp(cserInternalError, ['tmpIPackCPTask not assigned'], cnerInternalError);
        //Проверяю текущая комманда должна выполняться или ее блок прерван
        if tmpListOfBreakedBlock.ITExistsIntIndex(tmpIPackCPTask.BlockID) then Continue; //следов. комманда пропускается.
        //Проверяю есть ли ошибка в текущей команде
        if (tmpErrorCount>0)and(aPackCPR.CPErrors.CheckError(tmpIPackCPTask.Step, @tmpEMessage, @tmpEHelpContext, False)) then begin//Это ошибка
          //на одном из шагов случилась ошибка,
          if assigned(aPExecuteCPRStruct) then begin
            if assigned(aPExecuteCPRStruct^.OnReceiveCPRTaskError) then begin
              tmpIPackCPTask.Worked:=aPExecuteCPRStruct^.OnReceiveCPRTaskError(aPExecuteCPRStruct^.aUserData, aPackPD, aPackCPR, tmpIPackCPTask, tmpEMessage, tmpEHelpContext);
            end else if assigned(aPExecuteCPRStruct^.OnReceiveCPRTaskErrorV) then begin
              tmpIPackCPTask.Worked:=aPExecuteCPRStruct^.OnReceiveCPRTaskErrorV(aPExecuteCPRStruct^.aUserData, {aPackCPR.OwnerPDID, }aPackCPR.CPID, tmpIPackCPTask.BlockID, tmpIPackCPTask.Task, tmpIPackCPTask.Step, tmpIPackCPTask.Param, tmpEMessage, tmpEHelpContext, True{tmpResultWithError});
            end else tmpIPackCPTask.Worked:=False;
          end else tmpIPackCPTask.Worked:=False;
          Result:=Result and tmpIPackCPTask.Worked;
          if tmpIPackCPTask.BlockID<>-1 then begin//Добавляю номер блока в список прерваных блоков, т.к. произошла ошибка
            tmpIVarsetData:=TVarsetData.Create;
            tmpIVarsetData.ITIntIndex:=tmpIPackCPTask.BlockID;
            tmpListOfBreakedBlock.ITPush(tmpIVarsetData);
            tmpIVarsetData:=nil;
          end;
        end else begin//Ошибки нет, это нормальный результат
          if (assigned(aPExecuteCPRStruct))and(assigned(aPExecuteCPRStruct^.OnCheckSecurityADMTaskCPRTask)) then aPExecuteCPRStruct^.OnCheckSecurityADMTaskCPRTask(aPExecuteCPRStruct^.aUserData, tmpIPackCPTask.Task, aPackCPR.PackID, localGetSecurityContext(aPackCPR.CallerAction));
          case tmpIPackCPTask.Task of
            tskADMNone:;
          else
            if assigned(aPExecuteCPRStruct) then begin
              if assigned(aPExecuteCPRStruct^.OnReceiveCPRTask) then begin
                tmpIPackCPTask.Worked:=aPExecuteCPRStruct^.OnReceiveCPRTask(aPExecuteCPRStruct^.aUserData, aPackPD, aPackCPR, tmpIPackCPTask);
              end else if assigned(aPExecuteCPRStruct^.OnReceiveCPRTaskV) then begin
                tmpIPackCPTask.Worked:=aPExecuteCPRStruct^.OnReceiveCPRTaskV(aPExecuteCPRStruct^.aUserData, {aPackCPR.OwnerPDID, }aPackCPR.CPID, tmpIPackCPTask.BlockID, tmpIPackCPTask.Task, tmpIPackCPTask.Step, tmpIPackCPTask.Param);
              end else tmpIPackCPTask.Worked:=False;
            end else tmpIPackCPTask.Worked:=False;
            Result:=Result and tmpIPackCPTask.Worked;
          end;
        end;
      end;
    finally
      tmpListOfBreakedBlock:=nil;
      tmpIPackCPTask:=nil;
      tmpIVarsetData:=nil;
    end;
  except on e:exception do begin
    e.message:='ExecuteCPR: '+e.message;
    raise;
  end;end;
end;

end.
