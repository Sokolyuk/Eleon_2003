unit UThreadsPoolServer;

interface
  uses UThreadsPool, UServerPropertiesTypes{$ifdef PegasServer}, UPipeEServer{$endif};
type
  TThreadsPoolServer=class(TThreadsPool)
{$ifdef PegasServer}
  protected
    FPipeMultiEServer:TPipeMultiEServer;
{$endif}
  protected
    FFServerProperties:IServerProperties;
    function GetFServerProperties:IServerProperties;virtual;
    function InternalGetInitGUIDCount:Cardinal;override;
    procedure InternalInitGUIDList;override;
    property FServerProperties:IServerProperties read GetFServerProperties;
    procedure InternalNLCreateMThread(aPerpetual:Boolean);override;
    procedure InternalStartBegin;override;
    procedure InternalStartEnd;override;
    procedure InternalStopEnd;override;
    procedure InternalFinalBegin;override;
    procedure InternalFinalEnd;override;
    function InternalShotDown:boolean;override;
    function InternalUserName:AnsiString;override;
  public
    constructor create(aMPerpetualCount, aMMaxCount:Integer);
    destructor destroy;override;
  end;

implementation
  uses UPipeServerConsts, UServerConsts, UServerActionConsts, UAdmittanceASMTypes, UMThreadServer, Sysutils, UErrorConsts, UCaller,
       variants, UAppMessageTypes, UTTaskTypes, UTrayConsts;

constructor TThreadsPoolServer.create(aMPerpetualCount, aMMaxCount:Integer);
begin
  inherited create(aMPerpetualCount, aMMaxCount);
end;

destructor TThreadsPoolServer.destroy;
begin
  FFServerProperties:=nil;
  inherited destroy;
end;

function TThreadsPoolServer.InternalGetInitGUIDCount:Cardinal;
begin
  result:=inherited InternalGetInitGUIDCount+2;
end;

procedure TThreadsPoolServer.InternalInitGUIDList;
  var tmpInheritedCount:Cardinal;
begin
  inherited InternalInitGUIDList;
  tmpInheritedCount:=inherited InternalGetInitGUIDCount;
  GUIDList^.aList[tmpInheritedCount]:=IServerProperties;
  GUIDList^.aList[tmpInheritedCount+1]:=IAdmittanceASM;
end;

procedure TThreadsPoolServer.InternalNLCreateMThread(aPerpetual:Boolean);
begin
  TMThreadServer.Create(False, aPerpetual, Self);
end;

procedure TThreadsPoolServer.InternalStartBegin;
begin
  inherited InternalStartBegin;
{$IFDEF PegasServer}
  if csPipeName='' Then Raise Exception.CreateFmtHelp(cserInternalError, ['csPipeName='''''], cnerInternalError);
  FPipeMultiEServer:=TPipeMultiEServer.Create(TCallerAction.CreateNewAction(cnSQLServerSecurityContext, Unassigned), True, csPipeName);
{$Endif}
end;

procedure TThreadsPoolServer.InternalStartEnd;
begin
  inherited InternalStartEnd;
{$IFDEF PegasServer}
  FPipeMultiEServer.Resume;
{$ENDIF}
end;

procedure TThreadsPoolServer.InternalStopEnd;
{$ifdef PegasServer}
  var tmpWait:Cardinal;
      tmpStartTime:TDateTime;
{$endif}
begin
{$ifdef PegasServer}
  tmpStartTime:=now;
  if Assigned(FPipeMultiEServer) Then begin
    FPipeMultiEServer.Terminate;
    FPipeMultiEServer:=Nil;
    tmpWait:=0;
    While True do begin
      if (cnPipeMultiServerCount=0) then begin
        InternalSetMessage(tmpStartTime, InternalGetWaitMessage(tmpWait)+'NamedPipe are discharged.', mecApp, mesInformation);
        break;
      end;
      inc(tmpWait, 20);
      sleep(20);
      if tmpWait>10000 then begin
        InternalSetMessage(tmpStartTime, InternalGetWaitMessage(tmpWait)+'Still there are NamedPipe='+IntToStr(cnPipeMultiServerCount)+'.', mecApp, mesWarning);
        break;
      end;
    end;
  end;
{$endif}
end;

procedure TThreadsPoolServer.InternalFinalBegin;
  var tmpStartTime:TDateTime;
  procedure localShowStillASM(aAdmittanceASM:IAdmittanceASM);
  var tmplV:Variant;
      tmplPtr:Pointer;
  begin
    tmplV:=unassigned;
    repeat
      if VarIsArray(tmplV) then tmplPtr:=Pointer(Integer(tmplV[5])) else tmplPtr:=nil;
      tmplV:=aAdmittanceASM.GetInfoNextASMAndNoLock(tmplPtr);
      if VarIsArray(tmplV) then InternalSetMessage(tmpStartTime, 'Still there are ASM#'+VarToStr(tmplV[0])+' User='+''''+VarToStr(tmplV[1])+''''+'.', mecApp, mesWarning)
          else break{ ончились};
    until False; 
  end;
  var tmpMCount:integer;//дл€ лога
      tmpAdmittanceASM:IAdmittanceASM;
      tmpWait:Cardinal;
begin
  tmpStartTime:=now;
  try
    if assigned(FTaskImplement) then FTaskImplement.TasksImplements(cnServerAction, tskMTStopAllASM, unassigned, nil);
    if (assigned(cnTray))and(cnTray.Query(IAdmittanceASM, tmpAdmittanceASM, false)) then begin//удалось вз€ть IAdmittanceASM
      tmpMCount:=tmpAdmittanceASM.CountOfListASM;
      tmpWait:=0;
      While true do begin
        if (tmpAdmittanceASM.CountOfListASM<1) then begin
          InternalSetMessage(tmpStartTime, InternalGetWaitMessage(tmpWait)+'All ASM='+IntToStr(tmpMCount)+' are discharged.', mecApp, mesInformation);
          break;
        end;
        sleep(150);
        Inc(tmpWait, 150);
        if tmpWait>60000 then begin
          InternalSetMessage(tmpStartTime, InternalGetWaitMessage(tmpWait)+'Still there are ASM='+IntToStr(tmpAdmittanceASM.CountOfListASM)+'/before='+IntToStr(tmpMCount)+'.', mecApp, mesWarning);
          localShowStillASM(tmpAdmittanceASM);
          break;
        end;//If tmpTimeOut>60000 Then raise exception.create('Ќе удаетс€ принудительно остановить все ASM(TimeOut=1min(All/ASM='+IntToStr(tmpAdmittanceASM.CountOfListASM)+')).');
      end;
    end else begin//не удалось вз€ть IAdmittanceASM, просто жду 10 сек.
      InternalSetMessage(tmpStartTime, 'Is not present IAdmittanceASM.', mecApp, mesError);
    end;
  except on e:exception do begin
    try InternalSetMessage(tmpStartTime, 'InternalFinalBegin: '+e.message, mecApp, mesError);except end;
  end;end;
end;

procedure TThreadsPoolServer.InternalFinalEnd;
begin
  try
    inherited InternalFinalEnd;
    FFServerProperties:=nil;
  except on e:exception do begin
    try InternalSetMessage(now, 'InternalFinalEnd: '+e.message, mecApp, mesError);except end;
  end;end;
end;

function TThreadsPoolServer.InternalShotDown:boolean;
begin
  result:=GetFServerProperties.ShotDown
end;

function TThreadsPoolServer.GetFServerProperties:IServerProperties;
begin
  if not assigned(FFServerProperties) then begin
    cnTray.Query(IServerProperties, FFServerProperties, true{raise});
  end;
  result:=FFServerProperties;
end;

function TThreadsPoolServer.InternalUserName:AnsiString;
begin
  result:=FServerProperties.ServerUserName;
end;

end.
