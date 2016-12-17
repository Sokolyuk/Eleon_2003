unit UTray;

interface
  uses UITObject, UTrayTypes, UTrayInterfaceTypes, Windows;
type
  PTrayRec=^TTrayRec;
  TTrayRec=record
    aInited:boolean;
    aStarted:boolean;
    aIUnknown:IUnknown;
    aAccessCount:integer;
    aNext:PTrayRec;
  end;
  TBeforeWhatDo=(bwdInit, bwdStart);
  TAfterWhatDo=(awdStop, awdFinal);
  TPendingState=(pdsNone, pdsInitTray, pdsStartTray, pdsStopTray, pdsFinalTray);
  TUnlock2Event=procedure(aTrayInterface:ITrayInterface) of object;

  TTray=class(TITObject, ITray)
  private
    FTrayHeap:PTrayRec;
    FInitedTray, FStartedTray:boolean;
    FTrayMessage:TTrayMessageEvent;
    FTrayErrorMessage:TTrayErrorMessageEvent;
    FAccessCount:integer;
    FPendingState:TPendingState;
    FThreadsInMultiLock2:Integer;
    FLock2:boolean;
    CSLock2:TRTLCriticalSection;
  protected
    procedure InternalSetMessage(aStartTime:TDateTime; const aMessage:AnsiString);virtual;
    procedure InternalSetErrorMessage(aStartTime:TDateTime; const aMessage:AnsiString; aHelpContext:Integer);virtual;
    procedure InternalFreeTray;virtual;
    procedure InternalTrayBefore(aFirstDo:boolean; aSkipTrayRec:PTrayRec; const aGUID:TGUID; aBeforeWhatDo:TBeforeWhatDo; aRecursion:cardinal; const aForName:AnsiString);
    procedure InternalTrayAfter(aAfterWhatDo:TAfterWhatDo; aRaise:boolean);virtual;
    function Get_InitedTray:boolean;virtual;
    function Get_StartedTray:boolean;virtual;
    function GetTrayMessage:TTrayMessageEvent;virtual;
    procedure SetTrayMessage(aTrayMessage:TTrayMessageEvent);virtual;
    function GetTrayErrorMessage:TTrayErrorMessageEvent;
    procedure SetTrayErrorMessage(aTrayErrorMessage:TTrayErrorMessageEvent);
    function InternalLockWaitWithRaise(aWait:Integer; aRaise:boolean):boolean;virtual;
    Procedure InternalLock;override;
    function InternalLockWithRaise(aRaise:boolean):boolean;virtual;
    function InternalMultiLock2:Boolean;virtual;
    Procedure InternalMultiUnlock2;virtual;
    Procedure InternalBlockLock2;virtual;
    Procedure InternalLock2Wait(aWait:Integer);virtual;
    Procedure InternalUnBlocklock2;virtual;
    Procedure InternalSetRaise2(const aMessage:AnsiString);virtual;
    Procedure InternalLock3;virtual;
    Procedure InternalUnlock3;virtual;
    Procedure InternalUnlock3WithOnUnlock2(aOnUnlock2:TUnlock2Event; aTrayInterface:ITrayInterface);virtual;
    procedure InternalOnUnlock2(aTrayInterface:ITrayInterface);virtual;
  public
    constructor create;
    destructor destroy;override;
    //ITrayInterface
    function InitTray(aRaise:boolean=true):boolean;virtual;
    function StartTray(aRaise:boolean=true):boolean;virtual;
    function StopTray(aRaise:boolean=true):boolean;virtual;
    function FinalTray(aRaise:boolean=true):boolean;virtual;
    //ITray
    Procedure Push(aIUnknown:IUnknown);virtual;
    function Query(const aGUID:TGUID; out Obj; aTrayQueryMode:PTrayQueryMode=Nil):boolean;overload;virtual;
    Function Query(const aGUID:TGUID; aTrayQueryMode:PTrayQueryMode=Nil; aResult:PBoolean=Nil):IUnknown;overload;virtual;
    Function Query(const aGUID:TGUID; out Obj; aRaise:boolean):boolean;overload;virtual;
    Function Query(const aGUID:TGUID; aRaise:boolean; aResult:PBoolean=Nil):IUnknown;overload;virtual;
    //Function Drop(Const aGUID:TGUID):boolean;virtual;
    property InitedTray:boolean read Get_InitedTray;
    property StartedTray:boolean read Get_StartedTray;
    property OnTrayMessage:TTrayMessageEvent read GetTrayMessage write SetTrayMessage;
    property OnTrayErrorMessage:TTrayErrorMessageEvent read GetTrayErrorMessage write SetTrayErrorMessage;
    Function ReViewTopPriorities(aRaise:boolean=true):boolean;virtual;
  end;

implementation
  uses Sysutils, UMThreadUtils, UTrayConsts{$IFDEF VER130}, ComObj{$ENDIF};
                            
constructor TTray.create;
begin
  inherited create;
  FTrayHeap:=Nil;
  FInitedTray:=false;
  FStartedTray:=false;
  FTrayMessage:=nil;
  FTrayErrorMessage:=nil;
  FAccessCount:=0;
  FPendingState:=pdsNone;
  FThreadsInMultiLock2:=0;
  FLock2:=false;
  InitializeCriticalSection(CSLock2);
  InterlockedIncrement(cnTrayCount);
end;

destructor TTray.destroy;
begin
  if FStartedTray Then StopTray;
  if FInitedTray then FinalTray;
  InternalLock3;
  DeleteCriticalSection(CSLock2);
  InternalFreeTray;
  inherited destroy;
  InterlockedDecrement(cnTrayCount);
end;

procedure TTray.InternalFreeTray;
  var tmpTrayRec:PTrayRec;
begin
  while Assigned(FTrayHeap) do begin
    FTrayHeap^.aIUnknown:=nil;//отпускаю
    tmpTrayRec:=FTrayHeap;
    FTrayHeap:=FTrayHeap^.aNext;
    FreeMem(tmpTrayRec);//Dispose(tmpTrayRec);//разбираю
  end;
end;

procedure TTray.InternalTrayBefore(aFirstDo:boolean; aSkipTrayRec:PTrayRec; const aGUID:TGUID; aBeforeWhatDo:TBeforeWhatDo; aRecursion:cardinal; const aForName:AnsiString);
  function localGetForName:AnsiString;begin
    if aForName<>'' then result:=' for '''+aForName+'''' else result:='';
  end;
  function localPrefixForName:AnsiString;begin
    if aForName<>'' then result:=aForName+'>' else result:='';
  end;
  var tmpTrayRec:PTrayRec;
      tmpIUnknown:IUnknown;
      tmpTrayInterface:ITrayInterface;
      tmpTrayInterfaceInitFor:ITrayInterfaceInitFor;
      tmpGUIDList:PGUIDList;
      tmpI:Integer;
      tmpStartTime:TDateTime;
  function localCheckInterface:boolean;var ltmpIU:IUnknown; begin
    result:=(tmpIUnknown.QueryInterface(aGUID, ltmpIU)=S_OK)and(assigned(ltmpIU));
    ltmpIU:=nil;
  end;
  function localCheckForDo:boolean; begin
    case aBeforeWhatDo of
      bwdInit:result:=not tmpTrayRec^.aInited;
      bwdStart:result:=not tmpTrayRec^.aStarted;
    else
      result:=false;
    end;
  end;
begin
  if aRecursion>150 then raise exception.create('Internal error(aRecursion>150) for '+GUIDToString(aGUID)+'.');
  tmpTrayRec:=FTrayHeap;
  while assigned(tmpTrayRec) do begin//кручу верхний цыкл
    if (not assigned(aSkipTrayRec))or(aSkipTrayRec<>tmpTrayRec) then begin
      tmpIUnknown:=tmpTrayRec^.aIUnknown;//беру интерфейс
      if (aFirstDo)Or((not aFirstDo)And(localCheckInterface)) Then begin//он очередной OR нашел нужный(не aInited/aStarted)
        tmpStartTime:=now;
        if (assigned(tmpIUnknown))and(tmpIUnknown.QueryInterface(ITrayInterface, tmpTrayInterface)=S_OK)And(assigned(tmpTrayInterface))and(localCheckForDo) then begin//у него есть ITrayInterface, его можно проинитить и он не иниченый.
          if (tmpIUnknown.QueryInterface(ITrayInterfaceInitFor, tmpTrayInterfaceInitFor)=S_OK)And(assigned(tmpTrayInterfaceInitFor)) then begin
            case aBeforeWhatDo of
              bwdInit:tmpTrayInterfaceInitFor.MustBeforeInitFor(tmpGUIDList);//беру список, кого надо проинитить прежде
              bwdStart:tmpTrayInterfaceInitFor.MustBeforeStartFor(tmpGUIDList);//беру список, кого надо стартовать прежде
            else
              tmpGUIDList:=nil;
            end;
            if (assigned(tmpGUIDList))and(tmpGUIDList^.aCount>0) then begin//есть список
              for tmpI:=0 to tmpGUIDList^.aCount-1 do begin//кручу список
                InternalTrayBefore(false, tmpTrayRec, tmpGUIDList^.aList[tmpI], aBeforeWhatDo, aRecursion+1, localPrefixForName+tmpTrayInterfaceInitFor.GetTrayInterfaceName);
              end;
            end;
            tmpTrayInterfaceInitFor:=nil;
          end;
          tmpStartTime:=now;
          case aBeforeWhatDo of
            bwdInit:tmpTrayInterface.Init;//иничу
            bwdStart:tmpTrayInterface.Start;//стартую
          end;
        end else tmpTrayInterface:=nil;
        if localCheckForDo then begin
          case aBeforeWhatDo of//Веду состояние интерфейса вне зависимости от того поддерживает ли он ITrayInterface
            bwdInit:begin
              tmpTrayRec^.aInited:=true;//иничу
              if assigned(tmpTrayInterface) then InternalSetMessage(tmpStartTime, 'InitTray: '+tmpTrayInterface.GetTrayInterfaceName+localGetForName) else InternalSetMessage(tmpStartTime, 'InitTray: IUnknown('+IntToHex(Cardinal(pointer(tmpIUnknown)), 8)+')'+localGetForName);
            end;
            bwdStart:begin
              tmpTrayRec^.aStarted:=true;//стартую
              if assigned(tmpTrayInterface) then InternalSetMessage(tmpStartTime, 'StartTray: '+tmpTrayInterface.GetTrayInterfaceName+localGetForName) else InternalSetMessage(tmpStartTime, 'StartTray: IUnknown('+IntToHex(Cardinal(pointer(tmpIUnknown)), 8)+')'+localGetForName);
            end;
          end;
        end;
        if not aFirstDo then break;//для суб-инит, поскольку найденг нужный(и независимо от того получилось ли взять у него ITrayInterface и сделать сам инит), я ыхожу
      end;
    end;
    tmpTrayRec:=tmpTrayRec^.aNext;//перехожу к следующему
  end;
  if (not aFirstDo)And(not assigned(tmpTrayRec)) Then Raise Exception.Create('Interface '+GUIDToString(aGUID)+localGetForName+' no found.');//для суб-инит, не нашел требуемый интерфейс
end;

function TTray.InitTray(aRaise:boolean=true):boolean;
begin
  if not InternalLockWithRaise(aRaise) then begin Result:=false; exit; end;
  try
    FPendingState:=pdsInitTray;
    if FInitedTray Then begin
      if aRaise then Raise Exception.Create('Tray already ready.');
      result:=false;
      exit;
    end;
    InternalTrayBefore(true, nil, IUnknown, bwdInit, 0, '');
    FInitedTray:=True;
    FPendingState:=pdsNone;
  finally
    InternalUnlock;
  end;
  result:=true;
end;

function TTray.StartTray(aRaise:boolean=true):boolean;
begin
  if not InternalLockWithRaise(aRaise) then begin Result:=false; exit; end;
  try
    FPendingState:=pdsStartTray;
    if not FInitedTray then InitTray(aRaise);//если трэй не инициализирован, то иничу.
    if FStartedTray Then begin
      if aRaise then Raise Exception.Create('Tray already start.');
      result:=false;
      exit;
    end;
    InternalTrayBefore(true, nil, IUnknown, bwdStart, 0, '');
    FStartedTray:=True;
    FPendingState:=pdsNone;
  finally
    InternalUnlock;
  end;
  result:=true;
end;

procedure TTray.InternalTrayAfter(aAfterWhatDo:TAfterWhatDo; aRaise:boolean);
  function localCheckForDo(aTrayRec:PTrayRec):boolean;begin
    case aAfterWhatDo of
      awdStop:result:=aTrayRec^.aStarted;
      awdFinal:result:=aTrayRec^.aInited;
    else
      result:=false;
    end;
  end;
  var tmpTrayInterface:ITrayInterface;
      tmpSubTrayInterfaceInitFor:ITrayInterfaceInitFor;
      tmpTrayRec, tmpSubTrayRec:PTrayRec;
      tmpIUnknown, tmpSubIUnknown, tmpSubIU:IUnknown;
      tmpExistsDoing:boolean;
      tmpGUIDList:PGUIDList;
      tmpSubNeed:boolean;
      tmpI:integer;
      tmpTurnCount:Cardinal;
      tmpStartTime:TDateTime;
      tmpInited:boolean;
begin
  tmpTurnCount:=0;
  tmpTrayRec:=FTrayHeap;
  tmpExistsDoing:=false;
  while assigned(tmpTrayRec) do begin
    tmpIUnknown:=tmpTrayRec^.aIUnknown;
    tmpSubNeed:=false;
    if localCheckForDo(tmpTrayRec) then begin
      if (assigned(tmpIUnknown))and(tmpIUnknown.QueryInterface(ITrayInterface, tmpTrayInterface)<>S_OK) then tmpTrayInterface:=nil;
      tmpSubTrayRec:=FTrayHeap;
      while assigned(tmpSubTrayRec) do begin
        if tmpSubTrayRec<>tmpTrayRec then begin
          tmpSubIUnknown:=tmpSubTrayRec^.aIUnknown;
          if (localCheckForDo(tmpSubTrayRec))and(tmpSubIUnknown.QueryInterface(ITrayInterfaceInitFor, tmpSubTrayInterfaceInitFor)=S_OK)And(assigned(tmpSubTrayInterfaceInitFor)) then begin
            case aAfterWhatDo of
              awdStop:tmpSubTrayInterfaceInitFor.MustAfterStopFor(tmpGUIDList);
              awdFinal:tmpSubTrayInterfaceInitFor.MustAfterFinalFor(tmpGUIDList);
            else
              tmpGUIDList:=nil;
            end;
            if (assigned(tmpGUIDList))and(tmpGUIDList^.aCount>0) then begin//есть список
              for tmpI:=0 to tmpGUIDList^.aCount-1 do begin//кручу список
                if tmpIUnknown.QueryInterface(tmpGUIDList^.aList[tmpI], tmpSubIU)=S_OK then begin
                  tmpSubNeed:=true;
                  break;
                end;
              end;
            end;
          end;
        end;
        if tmpSubNeed then break;
        tmpSubTrayRec:=tmpSubTrayRec^.aNext;
      end;
      if not tmpSubNeed then begin//Веду состояние интерфейса вне зависимости от того поддерживает ли он ITrayInterface
        tmpStartTime:=now;
        case aAfterWhatDo of
          awdStop:begin
            tmpInited:=false;
            if assigned(tmpTrayInterface) then begin
              try
                tmpTrayInterface.Stop;
                InternalSetMessage(tmpStartTime, 'StopTray: '+tmpTrayInterface.GetTrayInterfaceName);
              except on e:exception do begin
                if aRaise then raise;
                InternalSetErrorMessage(tmpStartTime, 'Error: '+e.message, e.HelpContext);
                tmpInited:=true;
              end;end;
            end else begin
              InternalSetMessage(tmpStartTime, 'StopTray: IUnknown('+IntToHex(Cardinal(pointer(tmpIUnknown)), 8)+')');
            end;
            tmpTrayRec^.aStarted:=tmpInited;
          end;
          awdFinal:begin
            tmpInited:=false;
            if assigned(tmpTrayInterface) then begin
              try
                tmpTrayInterface.Final;
                InternalSetMessage(tmpStartTime, 'FinalTray: '+tmpTrayInterface.GetTrayInterfaceName);
              except on e:exception do begin
                if aRaise then raise;
                InternalSetErrorMessage(tmpStartTime, 'Error: '+e.message, e.HelpContext);
                tmpInited:=true;
              end;end;
            end else begin
              InternalSetMessage(tmpStartTime, 'FinalTray: IUnknown('+IntToHex(Cardinal(pointer(tmpIUnknown)), 8)+')');
            end;
            tmpTrayRec^.aInited:=tmpInited;
          end;
        end;
      end;
    end;
    if tmpSubNeed then begin
      tmpExistsDoing:=true;
    end;
    tmpTrayRec:=tmpTrayRec^.aNext;
    If (not assigned(tmpTrayRec))and(tmpExistsDoing) then begin
      tmpTrayRec:=FTrayHeap;
      tmpExistsDoing:=false;
    end;
    inc(tmpTurnCount);
    If tmpTurnCount>150 then Raise Exception.Create('Internal error(tmpTurnCount>150.');
  end;
end;

function TTray.StopTray(aRaise:boolean=true):boolean;
begin
  if not InternalLockWithRaise(aRaise) then begin Result:=false; exit; end;
  try
    if (not FStartedTray)and(FPendingState=pdsNone) Then begin
      if aRaise then Raise Exception.Create('Tray already stop.');
      result:=false;
      exit;
    end;
    FPendingState:=pdsStopTray;
    InternalTrayAfter(awdStop, aRaise);
    FStartedTray:=false;
    FPendingState:=pdsNone;
  finally
    InternalUnlock;
  end;
  result:=true;
end;

function TTray.FinalTray(aRaise:boolean=true):boolean;
begin
  if not InternalLockWithRaise(aRaise) then begin Result:=false; exit; end;
  try
    if (not FInitedTray)and(FPendingState=pdsNone) Then begin
      if aRaise then Raise Exception.Create('Tray already final.');
      result:=false;
      exit;
    end;
    if FStartedTray Then StopTray(aRaise);
    FPendingState:=pdsFinalTray;
    InternalTrayAfter(awdFinal, aRaise);
    FInitedTray:=false;
    FPendingState:=pdsNone;
  finally
    InternalUnlock;
  end;
  result:=true;
end;

procedure TTray.InternalOnUnlock2(aTrayInterface:ITrayInterface);
begin
  case aTrayInterface.StateAsTray of//Синхронизирую добавленый объект с Tray.
    tpsNone:begin
      if FInitedTray then InternalTrayBefore(true, nil, IUnknown, bwdInit, 0, '');
      if FStartedTray then InternalTrayBefore(true, nil, IUnknown, bwdStart, 0, '');
    end;
    tpsInit:begin
      if not FInitedTray then InternalTrayAfter(awdStop, true);
      if FStartedTray then InternalTrayBefore(true, nil, IUnknown, bwdStart, 0, '');
    end;
    tpsWork:begin
      if not FStartedTray then InternalTrayAfter(awdStop, true);
      if not FInitedTray then InternalTrayAfter(awdFinal, true);
    end;
  end;
end;

procedure TTray.Push(aIUnknown:IUnknown);
  var tmpTrayRec, tmpTrayRecNew:PTrayRec;
      tmpTrayInterface:ITrayInterface;
begin
  InternalLock3;
  try
    if not assigned(aIUnknown) then exit;
    If Assigned(FTrayHeap) then begin//ищу
      tmpTrayRec:=FTrayHeap;
      while true do begin
        if not Assigned(tmpTrayRec^.aNext) then begin//нашел последний, создаю еще один
          GetMem(tmpTrayRecNew, SizeOf(tmpTrayRecNew^));//New(tmpTrayRecNew);//создаю
          fillChar(tmpTrayRecNew^, SizeOf(tmpTrayRecNew^), 0);
          tmpTrayRecNew^.aInited:=false;
          tmpTrayRecNew^.aStarted:=false;
          tmpTrayRecNew^.aIUnknown:=aIUnknown;
          tmpTrayRecNew^.aAccessCount:=0;
          tmpTrayRecNew^.aNext:=nil;
          tmpTrayRec^.aNext:=tmpTrayRecNew;//клею
          break;
        end;
        tmpTrayRec:=tmpTrayRec^.aNext;
      end;
    end else begin//Создаю первый
      GetMem(tmpTrayRecNew, SizeOf(tmpTrayRecNew^));//New(tmpTrayRecNew);
      fillChar(tmpTrayRecNew^, SizeOf(tmpTrayRecNew^), 0);
      tmpTrayRecNew^.aInited:=false;
      tmpTrayRecNew^.aStarted:=false;
      tmpTrayRecNew^.aIUnknown:=aIUnknown;
      tmpTrayRecNew^.aAccessCount:=0;
      tmpTrayRecNew^.aNext:=nil;
      FTrayHeap:=tmpTrayRecNew;
    end;
    if aIUnknown.QueryInterface(ITrayInterface, tmpTrayInterface)<>S_OK then tmpTrayInterface:=nil;
  finally
    if assigned(tmpTrayInterface) then InternalUnlock3WithOnUnlock2(InternalOnUnlock2, tmpTrayInterface) else InternalUnlock3;
  end;
end;

//0.0002
function TTray.Query(const aGUID:TGUID; out Obj; aTrayQueryMode:PTrayQueryMode=Nil):boolean;//в ~45 раз дольшечем вызов "напрямую".
  var tmpTrayRec:PTrayRec;
      tmpTrayQueryMode:PTrayQueryMode;
begin
  //Вызов на "прямую" - 0.000018 мсек.
  //Длительность вызова первого интерфейса в списке - 0.0009 мсек(на Pegas -0.00064). Можно добиться результата в 0.0007 мсек, но для этого надо заменить QueryInterface на IsEqualIID(aGUID, tmpTrayRec^.aGUID)..
  //Длительность доступа к каждому добавленному интерфейсу увеличивается на 0.0003 мсек.
  //if not FInitedTray then InitTray;//запрашивается интерфейс, если трэй не инициализирован, то иничу.
  //if not FStartedTray Then StartTray;//если трэй не стартовал, то стартую.
  pointer(Obj):=nil;
  result:=false;
  if assigned(aTrayQueryMode) then tmpTrayQueryMode:=aTrayQueryMode else tmpTrayQueryMode:=@cnTrayQueryModeDef;
  if not InternalMultiLock2 then begin
    if tmpTrayQueryMode^.aRaise then Raise Exception.Create('Tray.Query: not InternalMultiLock2.');
    Result:=false;
    exit;
  end;
  //InternalLock;//0.00022 мсек на лок/унлок
  try//0.00004 try/finally
    //if (Not(FInitedTray And FStartedTray))and() Then begin
    //  if aRaise then Raise Exception.Create('Tray is not ready/start.') else exit;
    //end;
    tmpTrayRec:=FTrayHeap;
    while assigned(tmpTrayRec) do begin//tmpIUnknown:=tmpTrayRec^.aIUnknown;//длительность 0.0003 мсек
      if (assigned(tmpTrayRec^.aIUnknown))And(tmpTrayRec^.aIUnknown.QueryInterface{0.0004 мсек}(aGUID, Obj)=S_OK) Then begin//хороший, нашел
        InterlockedIncrement(tmpTrayRec^.aAccessCount);//Не требуется lock, т.к. это значение "порядковое".
        InterlockedIncrement(FAccessCount);
        result:=true;
        break;
      end;
      tmpTrayRec:=tmpTrayRec^.aNext;
    end;
  finally
    InternalMultiUnlock2;
  end;
  if not assigned(pointer(Obj)) then begin
    if tmpTrayQueryMode^.aRaise then Raise Exception.Create('Tray.Query: Interface '+GUIDToString(aGUID)+' no found.') else begin
      result:=false;
      exit;
    end;
  end;
  //if (result)and(InterlockedIncrement(FAccessCount)>=15000) then begin
  //  if ReViewTopPriorities(false{aRaise}) then FAccessCount:=0;
  //end;
end;

Function TTray.Query(const aGUID:TGUID; out Obj; aRaise:boolean):boolean;
  var tmpTrayQueryMode:TTrayQueryMode;
begin
  tmpTrayQueryMode:=cnTrayQueryModeDef;
  tmpTrayQueryMode.aRaise:=aRaise;
  result:=Query(aGUID, Obj, @tmpTrayQueryMode);
end;

Function TTray.Query(const aGUID:TGUID; aTrayQueryMode:PTrayQueryMode=Nil; aResult:PBoolean=Nil):IUnknown;
  var tmpResult:boolean;
begin//Через эту процедуру время доступа увеличивается на 0.00005 мсек и составляет 0.00085 мсек.
  tmpResult:=Query(aGUID, Result, aTrayQueryMode);
  if assigned(aResult) Then aResult^:=tmpResult;
end;

Function TTray.Query(const aGUID:TGUID; aRaise:boolean; aResult:PBoolean=Nil):IUnknown;
  var tmpResult:boolean;
      tmpTrayQueryMode:TTrayQueryMode;
begin
  tmpTrayQueryMode:=cnTrayQueryModeDef;
  tmpTrayQueryMode.aRaise:=aRaise;
  tmpResult:=Query(aGUID, Result, @tmpTrayQueryMode);
  if assigned(aResult) Then aResult^:=tmpResult;
end;

{Function TTray.Drop(Const aGUID:TGUID):boolean;
  var tmpTrayRec:PTrayRec;
      tmpIUnknown:IUnknown;
begin
  InternalLock3;
  try
    ?
    result:=false;
    tmpTrayRec:=FTrayHeap;
    while assigned(tmpTrayRec) do begin
      if assigned(tmpTrayRec^.aIUnknown) Then begin
        if tmpTrayRec^.aIUnknown.QueryInterface(aGUID, tmpIUnknown)=S_OK then begin
          tmpIUnknown:=nil;
          tmpTrayRec^.aIUnknown:=nil; можно склеивать
          result:=true;
          break;
        end;
      end;
      tmpTrayRec:=tmpTrayRec^.aNext;
    end;
  finally
    InternalUnlock3;
  end;
end;}

function TTray.Get_InitedTray:boolean;
begin
  InternalLock;
  try
    result:=FInitedTray;
  finally
    InternalUnlock;
  end;
end;

function TTray.Get_StartedTray:boolean;
begin
  InternalLock;
  try
    result:=FStartedTray;
  finally
    InternalUnlock;
  end;
end;

function TTray.GetTrayMessage:TTrayMessageEvent;
begin
  InternalLock;
  try
    result:=FTrayMessage;
  finally
    InternalUnlock;
  end;
end;

procedure TTray.SetTrayMessage(aTrayMessage:TTrayMessageEvent);
begin
  InternalLock;
  try
    FTrayMessage:=aTrayMessage;
  finally
    InternalUnlock;
  end;
end;

function TTray.GetTrayErrorMessage:TTrayErrorMessageEvent;
begin
  InternalLock;
  try
    result:=FTrayErrorMessage;
  finally
    InternalUnlock;
  end;
end;

procedure TTray.SetTrayErrorMessage(aTrayErrorMessage:TTrayErrorMessageEvent);
begin
  InternalLock;
  try
    FTrayErrorMessage:=aTrayErrorMessage;
  finally
    InternalUnlock;
  end;
end;

procedure TTray.InternalSetMessage(aStartTime:TDateTime; const aMessage:AnsiString);
begin
  if assigned(FTrayMessage) then FTrayMessage(aStartTime, aMessage);
end;

procedure TTray.InternalSetErrorMessage(aStartTime:TDateTime; const aMessage:AnsiString; aHelpContext:Integer);
begin
  if assigned(FTrayErrorMessage) then FTrayErrorMessage(aStartTime, aMessage, aHelpContext);
end;

Function TTray.ReViewTopPriorities(aRaise:boolean=true):boolean;
  function localPopTrayRecWithMaxAccessCount:PTrayRec;
  var tmplTrayRec, tmplTrayRecPrev, tmplTrayRecMaxAccessPrev:PTrayRec;
  begin
    result:=FTrayHeap;
    if not assigned(result) then exit;
    tmplTrayRecMaxAccessPrev:=nil;
    tmplTrayRecPrev:=nil;
    tmplTrayRec:=FTrayHeap;
    while assigned(tmplTrayRec) do begin
      if tmplTrayRec^.aAccessCount>result^.aAccessCount then begin
        result:=tmplTrayRec;
        tmplTrayRecMaxAccessPrev:=tmplTrayRecPrev;
      end;
      tmplTrayRecPrev:=tmplTrayRec;
      tmplTrayRec:=tmplTrayRec^.aNext;
    end;
    if assigned(tmplTrayRecMaxAccessPrev) then tmplTrayRecMaxAccessPrev^.aNext:=result^.aNext else begin
      FTrayHeap:=result^.aNext;
    end;
    result^.aNext:=nil;
    result^.aAccessCount:=0;//Не требуется lock, т.к. это значение "порядковое".
  end;
  var tmpFTrayHeap, tmpTrayRec:PTrayRec;
      tmpStartTime:TDateTime;
  procedure localShowTrayItems(const aPrefix:AnsiString);
    var tmplTrayRec:PTrayRec;
        tmplIUnknown:IUnknown;
        tmplTrayInterface:ITrayInterface;
  begin
    tmplTrayRec:=FTrayHeap;
    while assigned(tmplTrayRec) do begin
      tmplIUnknown:=tmplTrayRec^.aIUnknown;
      if (assigned(tmplIUnknown))and(tmplIUnknown.QueryInterface(ITrayInterface, tmplTrayInterface)=S_OK)and(assigned(tmplTrayInterface)) then begin
        InternalSetMessage(tmpStartTime, aPrefix+tmplTrayInterface.GetTrayInterfaceName+' '+IntToStr(tmplTrayRec^.aAccessCount));
      end else InternalSetMessage(tmpStartTime, aPrefix+'IUnknown('+IntToHex(Cardinal(pointer(tmplIUnknown)), 8)+')'+' '+IntToStr(tmplTrayRec^.aAccessCount));
      tmplTrayRec:=tmplTrayRec^.aNext;
    end;
  end;
begin
  //if not InternalLockWithRaise(aRaise) then begin Result:=false; exit; end;
  InternalLock3;
  try
    Result:=true;
    tmpStartTime:=now;
    localShowTrayItems('Before ReViewTopPriorities: ');
    tmpFTrayHeap:=localPopTrayRecWithMaxAccessCount;
    if assigned(tmpFTrayHeap) then begin
      tmpTrayRec:=tmpFTrayHeap;
      while true do begin
        tmpTrayRec^.aNext:=localPopTrayRecWithMaxAccessCount;
        if not assigned(tmpTrayRec^.aNext) then break;
        tmpTrayRec:=tmpTrayRec^.aNext;
      end;
    end;
    FTrayHeap:=tmpFTrayHeap;
    localShowTrayItems('After ReViewTopPriorities: ');
  finally
    InternalUnlock3;
  end;
end;

Procedure TTray.InternalLock;
begin
  InternalLockWaitWithRaise(180000, true);
end;

function TTray.InternalLockWithRaise(aRaise:boolean):boolean;
begin
  result:=InternalLockWaitWithRaise(180000, aRaise);
end;

function TTray.InternalLockWaitWithRaise(aWait:Integer; aRaise:boolean):boolean;
begin
  while not InternalTryLock do begin
    if aWait<=0 then begin
      if aRaise then InternalSetRaise('');
      result:=false;
      exit;
    end;
    if FPendingState<>pdsNone then begin
      if aRaise then begin
        case FPendingState of
          pdsInitTray:InternalSetRaise(' Pending INIT tray.');
          pdsStartTray:InternalSetRaise(' Pending START tray.');
          pdsStopTray:InternalSetRaise(' Pending STOP tray.');
          pdsFinalTray:InternalSetRaise(' Pending FINAL tray.');
        else
          InternalSetRaise(' Pending UNKNOWN tray.');
        end;  
      end;
      result:=false;
      exit;
    end;
    Dec(aWait, 33);
    Sleep(33);
  end;
  result:=true;
end;

function TTray.InternalMultiLock2:Boolean;
begin
  if not TryEnterCriticalSection(CSLock2) then InternalLock2Wait(180000);
  result:=not FLock2;
  if result then begin//можно ставить лок
    InterlockedIncrement(FThreadsInMultiLock2);
  end;
  LeaveCriticalSection(CSLock2);
end;

Procedure TTray.InternalMultiUnlock2;
begin
  InterlockedDecrement(FThreadsInMultiLock2);
end;

Procedure TTray.InternalBlockLock2;
  var tmpI:Integer;
      tmpWait:Integer;
begin
  InternalLock2Wait(180000{3мин});
  try
    FLock2:=true;
    try
      tmpI:=0;
      tmpWait:=30000;
      While FThreadsInMultiLock2>0 do begin
        If tmpWait<=0 then Raise Exception.Create('ThreadsInMultiLock2='+IntToStr(FThreadsInMultiLock2)+'.');
        Dec(tmpWait, 10);
        if tmpI>=200 then begin//каждые 200msec проверяю поток на Terminated.
          if MThreadBreak then Raise Exception.Create('MThreadBreak is true.');;
          tmpI:=0;
        end else inc(tmpI, 10);
        Sleep(10);
      end;
    except
      FLock2:=false;
      raise;
    end;
  finally
    LeaveCriticalSection(CSLock2);
  end;
end;

Procedure TTray.InternalSetRaise2(const aMessage:AnsiString);
begin
  Raise Exception.Create('TITObject('''+ClassName+''').InternalLock(CSLock2.LockCount='+IntToStr(CSLock2.LockCount)+', CSLock2.OwningThread='+IntToStr(CSLock2.OwningThread)+') unable to set InternalLock(CurrentThreadId='+IntToStr(GetCurrentThreadId)+').'+aMessage);//не разлочился
end;

Procedure TTray.InternalLock2Wait(aWait:Integer);
  var tmpI:Integer;
begin
  tmpI:=0;
  While not TryEnterCriticalSection(CSLock2) do begin
    If aWait<=0 then InternalSetRaise2('');
    Dec(aWait, 20);
    if tmpI>=200 then begin//каждые 200msec проверяю поток на Terminated.
      if MThreadBreak then Raise Exception.Create('MThreadBreak is true.');;
      tmpI:=0;
    end else inc(tmpI, 20);
    Sleep(20);
  end;
end;

Procedure TTray.InternalUnBlocklock2;
begin
  InternalLock2Wait(180000{3мин});
  FLock2:=false;
  LeaveCriticalSection(CSLock2);
end;

Procedure TTray.InternalLock3;
begin
  InternalLock;
  try
    InternalBlockLock2;
  except
    InternalUnlock;
    raise;
  end;
end;

Procedure TTray.InternalUnlock3;
begin
  InternalUnlock3WithOnUnlock2(nil, nil);
end;

Procedure TTray.InternalUnlock3WithOnUnlock2(aOnUnlock2:TUnlock2Event; aTrayInterface:ITrayInterface);
begin
  try
    InternalUnBlocklock2;
    if assigned(aOnUnlock2) then aOnUnlock2(aTrayInterface);
  finally
    InternalUnlock;
  end;
end;

end.
