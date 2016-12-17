unit UTaskImplementShotDownServerUtils;

interface
  uses UTTaskTypes, UCallerTypes, UTaskImplementTypes;

  function TaskImplementShotDownServer(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;

implementation
  uses UServerPropertiesTypes, UTrayConsts, Sysutils, UErrorConsts, UAppMessageTypes, Variants, UTTaskUtils,
       UThreadsPoolTypes;

function TaskImplementShotDownServer(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;
  var tmpI:Integer;
begin
  result:=true;
  case aTask of
    tskMTShotDownServer:begin//In MyParams: [0]-varInteger(���������� ���������); [1]-varInteger(����� ����� ����������); [2]-varOleStr(����� ��������)
      IAppMessage(cnTray.Query(IAppMessage)).ITMessAdd(Now, Now, aCallerAction.UserName, 'ImplShotDownServer', 'tskMTShotDownServer', mecApp, mesWarning);
      If aParams[0]>0 Then begin
        tmpI:=aParams[0]-1;
        if tmpI=0 then tmpI:=-1;  // ����� ����� ���� ������� ������� �������� 0 ��� �� ����
        IThreadsPool(cnTray.Query(IThreadsPool)).ITMTaskAdd(tskMTSendMessToAll, VarArrayOf([aCallerAction.UserName, aParams[2]+'(�������� '+IntToStr(aParams[0]*aParams[1] div 60000)+'���. '+IntToStr((aParams[0]*aParams[1] mod 60000) div 1000)+'���.)']), aCallerAction);
        IThreadsPool(cnTray.Query(IThreadsPool)).ITMSleepTaskAdd(tskMTShotDownServer, VarArrayOf([Integer(tmpI), aParams[1], aParams[2]]), aCallerAction, LongWord(aParams[1]), aTaskContext^.aTaskID, @aTaskContext^.aTaskID);
        If assigned(aTaskContext) then begin
          if assigned(aTaskContext^.aResult) then aTaskContext^.aResult^:=VarArrayOf([Integer(tmpI), aParams[1]]);
          aTaskContext^.aSetResult:=true;
          aTaskContext^.aManualResultSet:=false;//�������� �������������� ��������� SetComplete??
        end;
      end else begin
        If aParams[0]=0 then begin//���� 0 ��� ��������� ����� ��� ���������
          IThreadsPool(cnTray.Query(IThreadsPool)).ITMSleepTaskAdd(tskMTShotDownServerImmediately, unassigned, aCallerAction, LongWord(aParams[1]), aTaskContext^.aTaskID, @aTaskContext^.aTaskID);
        end else begin//���� <0 ����� ��������
          IThreadsPool(cnTray.Query(IThreadsPool)).ITMTaskAdd(tskMTShotDownServerImmediately, unassigned, aCallerAction, aTaskContext^.aTaskID, @aTaskContext^.aTaskID);
        end;
      end;
    end;//Out Res: [0]-varinteger:(������� ��������� ����������)
    tskMTShotDownServerImmediately:begin//In aParams: Emty
      IAppMessage(cnTray.Query(IAppMessage)).ITMessAdd(Now, Now, aCallerAction.UserName, 'ImplShotDownServer', 'tskMTShotDownServerImmediately', mecApp, mesWarning);
      IServerProperties(cnTray.Query(IServerProperties)).ShotDown:=True;
      If assigned(aTaskContext) then begin
        if assigned(aTaskContext^.aResult) then aTaskContext^.aResult^:=IServerProperties(cnTray.Query(IServerProperties)).ShotDown;
        aTaskContext^.aSetResult:=true;
        aTaskContext^.aManualResultSet:=false;//�������� �������������� ��������� SetComplete??
      end;
    end;//Out Res: Empty
  else
    if aRaise then Raise Exception.CreateFmtHelp(cserInternalError, ['Unsupported for '+MTaskToStr(aTask)], cnerInternalError) else result:=false;
  end;
end;

end.
