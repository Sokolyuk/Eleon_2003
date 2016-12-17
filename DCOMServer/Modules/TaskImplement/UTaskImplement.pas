//Copyright � 2000-2003 by Dmitry A. Sokolyuk
unit UTaskImplement;

interface
  uses UTrayInterface, UTaskImplementTypes, UTTaskTypes, UCallerTypes, UTrayInterfaceTypes,
       UAppMessageTypes, UThreadsPoolTypes, UTrayTypes, UEPointPropertiesTypes;
type
  TTaskImplement=class(TTrayInterface, ITaskImplement)
  protected
    FAppMessage:IAppMessage;
    FThreadsPool:IThreadsPool;
    FEPointProperties:IEPointProperties;
    function InternalGetIEPointProperties:IEPointProperties;virtual;
    function InternalGetIAppMessage:IAppMessage;virtual;
    function InternalGetIThreadsPool:IThreadsPool;
    procedure InternalFinal;override;
    function InternalGetTitlePoint:AnsiString;virtual;
  protected
    function InternalGetInitGUIDCount:Cardinal;override;
    procedure InternalInitGUIDList;override;
  protected
    procedure InternalSetMessage(aStartTime:TDateTime; const aUserName, aMessage:AnsiString; aHelpcontext:Integer; amecMess:TMessageClass; amesMess:TMessageStyle);virtual;
    procedure InternalTaskImplementSetComplete(aCallerAction:ICallerAction; aTaskContext:PTaskContext);virtual;
    procedure InternalTaskImplementSetError(aCallerAction:ICallerAction; const aMessage:AnsiString; aHelpcontext:Integer; aTaskContext:PTaskContext);virtual;
  public
    constructor create;
    destructor destroy;override;
    procedure TasksImplements(aCallerAction:ICallerAction; aTask:TTask; const aParams:Variant; aTaskContext:PTaskContext);virtual;
    function TaskImplement(aCallerAction:ICallerAction; aTask:TTask; const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;virtual;
  end;

implementation
  uses Sysutils, UErrorConsts, UTTaskUtils, UTrayConsts, UPackCPR, UPackCPRTypes, UPackConsts, UCallerTaskTypes,
       UCallerTaskPath{$IFNDEF VER130}, Variants{$ENDIF};

constructor TTaskImplement.create;
begin
  inherited create;
  FAppMessage:=nil;
  FThreadsPool:=nil;
  FEPointProperties:=nil;
end;

destructor TTaskImplement.destroy;
begin
  FAppMessage:=nil;
  FThreadsPool:=nil;
  FEPointProperties:=nil;
  inherited destroy;
end;

function TTaskImplement.InternalGetInitGUIDCount:Cardinal;
begin
  result:=inherited InternalGetInitGUIDCount+2;
end;

procedure TTaskImplement.InternalInitGUIDList;
  var tmpCount:Cardinal;
begin
  inherited InternalInitGUIDList;
  tmpCount:=inherited InternalGetInitGUIDCount;
  GUIDList^.aList[tmpCount]:=IAppMessage;
  GUIDList^.aList[tmpCount+1]:=IEPointProperties;
end;

procedure TTaskImplement.InternalFinal;
begin
  inherited InternalFinal;
  FAppMessage:=nil;
  FThreadsPool:=nil;
  FEPointProperties:=nil;
end;

function TTaskImplement.InternalGetIAppMessage:IAppMessage;
begin
  if not assigned(FAppMessage) then InternalGetITray.Query(IAppMessage, FAppMessage);
  result:=FAppMessage;
end;

function TTaskImplement.InternalGetIThreadsPool:IThreadsPool;
begin
  if not assigned(FThreadsPool) then InternalGetITray.Query(IThreadsPool, FThreadsPool);
  result:=FThreadsPool;
end;

function TTaskImplement.InternalGetIEPointProperties:IEPointProperties;
begin
  if not assigned(FEPointProperties) then InternalGetITray.Query(IEPointProperties, FEPointProperties);
  result:=FEPointProperties;
end;

function TTaskImplement.InternalGetTitlePoint:AnsiString;
begin
  result:=InternalGetIEPointProperties.TitlePoint;
end;

procedure TTaskImplement.InternalSetMessage(aStartTime:TDateTime; const aUserName, aMessage:AnsiString; aHelpcontext:Integer; amecMess:TMessageClass; amesMess:TMessageStyle);
begin
  InternalGetIAppMessage.ITMessAdd(aStartTime, Now, aUserName, 'Impl', aMessage+'(HC='+IntToStr(aHelpcontext)+')', amecMess, amesMess);
end;

//����� TasksImplements ��������� ������(aTask/aParams/aCallerAction) � ���������, �� ����������(aSetResult), ��������� ����������(aResult), ��������� ��� ������.
//�������� ����������� �������� ����������, ��������� ��� ��� SetComplete/SetError.
//���� � ������� TaskImplement, ���� �������������� ��������� aSetResult/aResult, �� ������� ��������� ����� ���������.
//�.�. ���� ��� �� ���������� TasksImplements � ��� ���������� � �������� ������ ��� ����������, �� ����� ���������� aSetResult � false, ����� � aResult ����� ��������� ��� � try/except/end ������.
//��� ��� ��������
procedure TTaskImplement.TasksImplements(aCallerAction:ICallerAction; aTask:TTask; const aParams:Variant; aTaskContext:PTaskContext);
  var tmpPTaskContext:PTaskContext;
  function localGetResult:variant; begin
    if (assigned(tmpPTaskContext))and(tmpPTaskContext^.aSetResult)and(assigned(tmpPTaskContext^.aResult)) then Result:=tmpPTaskContext^.aResult^ else Result:=unassigned;
  end;
  procedure localExecTask(alCallerTaskTask:ICallerTaskTask; alCallerTask:ICallerTask);
    var tmplTaskContext:TTaskContext;
  begin
    if (not assigned(alCallerTaskTask))or(not assigned(alCallerTask))then exit;
    tmplTaskContext:=tmpPTaskContext^;
    //!!??tmplTaskContext.aResult
    tmplTaskContext.aCallerTask:=alCallerTask;
    if assigned(tmplTaskContext.aCallerTaskPath) then begin
     if not assigned(tmplTaskContext.aCallerTaskPath.First) then tmplTaskContext.aCallerTaskPath.First:=tmpPTaskContext^.aCallerTask;
     tmplTaskContext.aCallerTaskPath.Prev:=tmpPTaskContext^.aCallerTask;
    end else begin
     tmplTaskContext.aCallerTaskPath:=TCallerTaskPath.Create;
     tmplTaskContext.aCallerTaskPath.First:=tmpPTaskContext^.aCallerTask;
     tmplTaskContext.aCallerTaskPath.Prev:=tmpPTaskContext^.aCallerTask;
    end;
    TasksImplements(aCallerAction, alCallerTaskTask.Task, alCallerTaskTask.Params, @tmplTaskContext);
  end;
  var tmpStartTime:TDateTime;
      tmpTaskContext:TTaskContext;
      tmpResult:Variant;
begin
  tmpStartTime:=now;
  if assigned(aTaskContext) then tmpPTaskContext:=aTaskContext else begin//���������� TaskContext
    tmpTaskContext:=cnDefTaskContext;
    tmpResult:=unassigned;
    tmpTaskContext.aResult:=@tmpResult;
    tmpPTaskContext:=@tmpTaskContext;
  end;
  try
    try//�������� ������
      if assigned(tmpPTaskContext^.aCallerTask) then tmpPTaskContext^.aCallerTask.Status:=tssExecute;
      if not TaskImplement(aCallerAction, aTask, aParams, tmpPTaskContext, false{aRaise}) then raise exception.createFmtHelp(cserInternalError, ['Unsupported for '+MTaskToStr(aTask)], cnerInternalError);
      //SetComplete
      if (not tmpPTaskContext^.aManualResultSet{����-�������� ����������})and(tmpPTaskContext^.aSetResult{��������� ����������}) then begin
        InternalTaskImplementSetComplete(aCallerAction, tmpPTaskContext);//�������� ����������
      end;
      //OnCanceled/OnComplete
      if (assigned(tmpPTaskContext^.aCallerTask))and(tmpPTaskContext^.aCallerTask.Canceled) then begin
        //OnCanceled
        if assigned(tmpPTaskContext^.aEndTaskEventI) then tmpPTaskContext^.aEndTaskEventI.EndTaskCanceled(aCallerAction, aTask, aParams, tmpPTaskContext);
        if (assigned(tmpPTaskContext^.aEndTaskEvent))and(assigned(tmpPTaskContext^.aEndTaskEvent^.aOnCanceled)) then tmpPTaskContext^.aEndTaskEvent^.aOnCanceled(aCallerAction, aTask, aParams, tmpPTaskContext);
      end else begin
        //OnComplete
        if assigned(tmpPTaskContext^.aCallerTask) then begin
          tmpPTaskContext^.aCallerTask.SetComplete(localGetResult);
          localExecTask(tmpPTaskContext^.aCallerTask.NextBlockTaskTask, tmpPTaskContext^.aCallerTask.NextBlockTask);
        end;
        if assigned(tmpPTaskContext^.aEndTaskEventI) then tmpPTaskContext^.aEndTaskEventI.EndTaskComplete(aCallerAction, aTask, aParams, tmpPTaskContext);
        if (assigned(tmpPTaskContext^.aEndTaskEvent))and(assigned(tmpPTaskContext^.aEndTaskEvent^.aOnComplete)) then tmpPTaskContext^.aEndTaskEvent^.aOnComplete(aCallerAction, aTask, aParams, tmpPTaskContext);
      end;
    except on e:exception do begin//��������� ������ ����������
      try
        if tmpPTaskContext^.aExceptionMode=exmPDTransport Then InternalSetMessage(tmpStartTime, aCallerAction.UserName, 'TaskImpl('+MTaskToStr(aTask)+'): '+e.Message, e.helpcontext, mecTransport, mesError)
            else InternalSetMessage(tmpStartTime, aCallerAction.UserName, 'TaskImpl('+MTaskToStr(aTask)+'): '+e.Message, e.helpcontext, mecApp, mesError);

        if tmpPTaskContext^.aManualResultSet{������ �������� ����������} then raise exception.createHelp('TaskImpl: '+e.Message, e.HelpContext);//�� ����� ����-�������� ����������
        try//���� �������� ����������
          InternalTaskImplementSetError(aCallerAction, 'TaskImpl('+MTaskToStr(aTask)+'): '+e.message, e.HelpContext, tmpPTaskContext);
        except on e:exception do begin
          InternalSetMessage(tmpStartTime, aCallerAction.UserName, 'TaskImpl('+MTaskToStr(aTask)+'): Except(SetErr): '+e.Message, e.HelpContext, mecApp, mesError);
        end;end;
      finally//OnError
        if assigned(tmpPTaskContext^.aCallerTask) then begin
          tmpPTaskContext^.aCallerTask.SetError(e.Message, e.HelpContext);
          if assigned(tmpPTaskContext^.aCallerTask.ExceptTask) then begin//ExceptTask
            localExecTask(tmpPTaskContext^.aCallerTask.ExceptTaskTask, tmpPTaskContext^.aCallerTask.ExceptTask);
          end;
        end;
        if assigned(tmpPTaskContext^.aEndTaskEventI) then tmpPTaskContext^.aEndTaskEventI.EndTaskError(aCallerAction, aTask, aParams, tmpPTaskContext, e.Message, e.HelpContext);
        if (assigned(tmpPTaskContext^.aEndTaskEvent))and(assigned(tmpPTaskContext^.aEndTaskEvent^.aOnError)) then tmpPTaskContext^.aEndTaskEvent^.aOnError(aCallerAction, aTask, aParams, tmpPTaskContext, e.Message, e.HelpContext);
      end;
    end;end;
  finally
    if assigned(tmpPTaskContext^.aCallerTask) then begin
      if assigned(tmpPTaskContext^.aCallerTask.NextTask) then begin//NextTask
        localExecTask(tmpPTaskContext^.aCallerTask.NextTaskTask, tmpPTaskContext^.aCallerTask.NextTask);
      end;
    end;
  end;
end;

function TTaskImplement.TaskImplement(aCallerAction:ICallerAction; aTask:TTask; const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;
begin
  {Here there must be a realization of task}
  if aRaise then raise exception.createFmtHelp(cserInternalError, ['Unsupported for '+MTaskToStr(aTask)], cnerInternalError) else result:=false;
end;

procedure TTaskImplement.InternalTaskImplementSetError(aCallerAction:ICallerAction; const aMessage:AnsiString; aHelpcontext:Integer; aTaskContext:PTaskContext);
  function localGetResult:Variant;begin
    if assigned(aTaskContext^.aResult) then result:=aTaskContext^.aResult^ else result:=unassigned;
  end;
  var tmpPackCPR:IPackCPR;
      tmpSenderPackPD:Variant;
begin
  if (not assigned(aCallerAction))or(not assigned(aCallerAction.CallerSenderParams))then exit;
  tmpSenderPackPD:=aCallerAction.CallerSenderParams.SenderPackPD;
  if VarIsArray(tmpSenderPackPD) Then begin//��������� �������� ����������
    case aTaskContext^.aExceptionMode of
      exmNormal:begin
        tmpPackCPR:=TPackCPR.Create;
        try
          tmpPackCPR.CPROptions:=[];
          tmpPackCPR.CPID:=aCallerAction.CallerSenderParams.SenderPackCPID;
          tmpPackCPR.AddWithError(aCallerAction.CallerSenderParams.SenderADMTaskNum, localGetResult, aCallerAction.CallerSenderParams.SenderRouteParam, -1, InternalGetTitlePoint+': '+aMessage, aHelpcontext);
          tmpSenderPackPD[Protocols_PD_Data]:=tmpPackCPR.AsVariant;
        finally
          tmpPackCPR:=nil;
        end;//��������� ���������
        InternalGetIThreadsPool.ITMTaskAdd(tskMTPD, tmpSenderPackPD, Unassigned, aCallerAction.SecurityContext);
      end;
      exmPDTransport:begin
        tmpSenderPackPD[Protocols_PD_Error]:=VarArrayOf([aMessage, localGetResult, aHelpcontext]);//��������� ���������
        InternalGetIThreadsPool.ITMTaskAdd(tskMTPD, tmpSenderPackPD, Unassigned, aCallerAction.SecurityContext);
      end;
    else
      raise exception.create('MyExceptionMode?');
    end;
  end;
end;

procedure TTaskImplement.InternalTaskImplementSetComplete(aCallerAction:ICallerAction; aTaskContext:PTaskContext);
  function localGetResult:Variant;begin
    if assigned(aTaskContext^.aResult) then result:=aTaskContext^.aResult^ else result:=unassigned;
  end;
  var tmpPackCPR:IPackCPR;
      tmpSenderPackPD:Variant;
begin
  if (not assigned(aCallerAction))or(not assigned(aCallerAction.CallerSenderParams))then exit;
  tmpSenderPackPD:=aCallerAction.CallerSenderParams.SenderPackPD;
  if VarIsArray(tmpSenderPackPD) then begin//��������� �������� ����������
    if aTaskContext^.aPackToCPR then begin//��������� ����� ��������� � CPR
      tmpPackCPR:=TPackCPR.Create;
      try
        tmpPackCPR.CPROptions:=[];
        tmpPackCPR.CPID:=aCallerAction.CallerSenderParams.SenderPackCPID; 
        tmpPackCPR.Add(aCallerAction.CallerSenderParams.SenderADMTaskNum, localGetResult, aCallerAction.CallerSenderParams.SenderRouteParam, -1);
        tmpSenderPackPD[Protocols_PD_Data]:=tmpPackCPR.AsVariant;
      finally
        tmpPackCPR:=nil;
      end;
    end else begin//��������� ����� �������� ��� ���������
      tmpSenderPackPD[Protocols_PD_Data]:=localGetResult;
    end;//��������� ���������
    InternalGetIThreadsPool.ITMTaskAdd(tskMTPD, tmpSenderPackPD, Unassigned, aCallerAction.SecurityContext);
  end;
end;

end.
