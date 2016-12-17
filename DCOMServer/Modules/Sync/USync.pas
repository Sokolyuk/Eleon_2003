//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit USync;

interface
  Uses USyncTypes, UTrayInterface, UCallerTypes, UTrayInterfaceTypes, UAppMessageTypes;
Type
  //Add - добавить один лок
  //Free - удалить один лок
  //Set - добавить/удалить список локов, используя префикс +/-
  //Clear - удалить локи
  TSync=class(TTrayInterface, ISync)
  private
    FLockOwnerCounter:Integer;
    FPIntLockRec, FPStrLockRec:PLockRec;
    FStrCount, FIntCount:Integer;
    FAppMessage:IAppMessage;
  protected
    procedure InternalFinal;override;
  protected
    procedure InternalMessage(aStartTime:TDateTime; Const aMessage:AnsiString; aMec:TMessageClass; aMes:TMessageStyle; aCallerAction:ICallerAction);virtual;
    function InternalGetIAppMessage:IAppMessage;virtual;
    function InternalGetLastIntLockRec:PLockRec;virtual;
    function InternalGetLastStrLockRec:PLockRec;virtual;
    procedure InternalAddIntLock(aIntLock:Integer; aLockOwner:Integer; aLifeTime:TDateTime; aCallerAction:ICallerAction; aOptions:TLockOptions);virtual;
    procedure InternalAddStrLock(Const aStrLock:AnsiString; aLockOwner:Integer; aLifeTime:TDateTime; aCallerAction:ICallerAction; aOptions:TLockOptions);virtual;
    procedure InternalDelIntLock(aPIntLockRec, aPIntLockRecPrev:PLockRec);virtual;
    procedure InternalDelStrLock(aPStrLockRec, aPStrLockRecPrev:PLockRec);virtual;
    procedure InternalSearchIntLock(aIntLock:Integer; Out aPIntLockRec, aPIntLockRecPrev:PLockRec);virtual;
    procedure InternalSearchStrLock(Const aStrLock:AnsiString; Out aPStrLockRec, aPStrLockRecPrev:PLockRec; aSearchSubStrLock:Boolean=False);virtual;
    procedure InternalSearchIntLockOwner(aLockOwner:Integer; Out aPIntLockRec, aPIntLockRecPrev:PLockRec);virtual;
    procedure InternalSearchStrLockOwner(aLockOwner:Integer; Out aPStrLockRec, aPStrLockRecPrev:PLockRec);virtual;
    function InternalClearLock:Integer{count};virtual;
    function InternalLifeTimeInfo(aLifeTime:TDateTime):AnsiString;virtual;
    procedure InternalSetLockInfo(alPLockInfo:PLockInfo; aPIntLockRec:PLockRec);virtual;
    function InternalGetUserName(aPIntLockRec:PLockRec):AnsiString;virtual;
    function InternalSetStrLock(Const aStrLock:AnsiString; aLockOwner:Integer; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aPLockInfo:PLockInfo{=Nil}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;virtual;
    function InternalFreeStrLock(Const aStrLock:AnsiString; aLockOwner:Integer):integer;virtual;
    function InternalParseAndCheckExistsStrLock(aCallerAction:ICallerAction; Const aStrLocks:AnsiString; aLockOwner:Integer; aSetStrLocks, aFreeStrLocks:PAnsiString; aAsLockList:Boolean; aRaise:Boolean; aFirstExistsLock:PLockRec):Boolean{ExistsLock};virtual;
    procedure InternalRaiseLocked(aCallerAction:ICallerAction; aOtherLockOwner:Integer; aPStrLockRec:PLockRec; aRaise:boolean);virtual;
    function InternalSetStrLocks(Const aStrLocks:AnsiString; aLockOwner:Integer; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;virtual;
    function InternalClearStrLocks(Const aStrLocks:AnsiString; aLockOwner:Integer):Boolean;virtual;
  public
    constructor Create;
    destructor Destroy; override;
    //..
    function ITGenerateLockOwner:Integer;virtual;
    //..
    function ITSetIntLock(aIntLock:Integer; aLockOwner:Integer; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aPLockInfo:PLockInfo{=Nil}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;virtual;
    function ITSetIntLockWait(aIntLock:Integer; aLockOwner:Integer; aWait:Cardinal; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aPLockInfo:PLockInfo{=Nil}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;virtual;
    function ITFreeIntLock(aIntLock:Integer; aLockOwner:Integer):integer;virtual;
    function ITClearIntLockOwner(aLockOwner:Integer):Integer{count};virtual;
    //..
    function ITSetStrLock(Const aStrLock:AnsiString; aLockOwner:Integer; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aPLockInfo:PLockInfo{=Nil}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;virtual;
    function ITSetStrLockWait(Const aStrLock:AnsiString; aLockOwner:Integer; aWait:Cardinal; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aPLockInfo:PLockInfo{Nil}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;virtual;
    function ITSetStrLockList(Const aStrLockList:AnsiString; aLockOwner:Integer; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;virtual;
    function ITSetStrLockListWait(Const aStrLockList:AnsiString; aLockOwner:Integer; aWait:Cardinal; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aRaise:Boolean{=true}; aOptions:TLockOptions{=[]}):Boolean;virtual;
    function ITSetStrLocks(Const aStrLocks:AnsiString; aLockOwner:Integer; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aRaise:Boolean{=true}; aOptions:TLockOptions{=[]}):Boolean;virtual;
    function ITSetStrLocksWait(Const aStrLocks:AnsiString; aLockOwner:Integer; aWait:Cardinal; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;virtual;
    function ITClearStrLocks(Const aStrLocks:AnsiString; aLockOwner:Integer):Boolean;virtual;
    function ITStrLockSubExists(Const aStrLockSub:AnsiString; aPLockInfo:PLockInfo{=Nil}):Boolean;virtual;
    function ITStrLockExists(Const aStrLock:AnsiString; aPLockInfo:PLockInfo{=Nil}):Boolean;
    function ITFreeStrLock(Const aStrLock:AnsiString; aLockOwner:Integer):integer;virtual;
    function ITClearStrLockOwner(aLockOwner:Integer):Integer{count};virtual;
    //..
    function ITClearLockOwner(aLockOwner:Integer):Integer{count};virtual;
    function ITClearLock:Integer{count};virtual;
    //..
    function ITSetLockList(const aLockList{, aUser}:AnsiString; aCallerAction:ICallerAction; aLockOwner:Integer; aRaise:Boolean; aMessAdd:boolean{=true}):Boolean;virtual;
    function ITSetLockListWait(const aLockList{, aUser}:AnsiString; aCallerAction:ICallerAction; aLockOwner:Integer; aRaise:Boolean; aTimeout:Integer; aMessAdd:boolean{=true}):Boolean;virtual;
    function ITSetLock(const aLock{, aUser}:AnsiString; aCallerAction:ICallerAction; aLockOwner:Integer; aRaise:Boolean; aMessAdd:boolean{=true}):Boolean;virtual;
    function ITFreeLock(const aLock:AnsiString; aLockOwner:Integer):integer;virtual;
    function ITSetLockWait(const aLock{, aUser}:AnsiString; aCallerAction:ICallerAction; aLockOwner:Integer; aRaise:Boolean; aTimeout:Integer; aMessAdd:boolean{=true}):Boolean;virtual;
    function ITGetLockList:Variant;virtual;
    //..
  end;

implementation
  uses Windows, SysUtils, UErrorConsts, USyncConsts, UStringUtils, UStringConsts, USyncUtils, UTrayConsts,
        UTrayTypes{$IFNDEF VER130}, Variants{$ENDIF};

const csParamsStrSeparator = ';';

constructor TSync.Create;
begin
  Inherited Create;
  FLockOwnerCounter:=-1;
  FPIntLockRec:=nil;
  FPStrLockRec:=nil;
  FStrCount:=0;
  FIntCount:=0;
end;

destructor TSync.Destroy;
begin
  InternalClearLock;
  FAppMessage:=nil;
  Inherited Destroy;
end;

function TSync.InternalGetLastStrLockRec:PLockRec;
begin
  Result:=FPStrLockRec;
  if assigned(Result) then begin
    While Result^.Next<>Nil do begin
      Result:=Result^.Next;
    end;
  end;
end;

function TSync.InternalGetLastIntLockRec:PLockRec;
begin
  Result:=FPIntLockRec;
  if assigned(Result) then begin
    While Result^.Next<>Nil do begin
      Result:=Result^.Next;
    end;
  end;
end;

function TSync.ITGenerateLockOwner:Integer;
begin
  Result:=InterLockedIncrement(FLockOwnerCounter);
end;

function TSync.InternalClearLock:Integer{count};
begin
  Result:=0;
  While assigned(FPIntLockRec) do begin
    InternalDelIntLock(FPIntLockRec, Nil);
    Inc(Result);
  end;
  While assigned(FPStrLockRec) do begin
    InternalDelStrLock(FPStrLockRec, Nil);
    Inc(Result);
  end;
end;

function TSync.ITClearLock:Integer{count};
begin
  InternalLock;
  try
    Result:=InternalClearLock;
  finally
    InternalUnlock;
  end;
end;

procedure TSync.InternalAddStrLock(Const aStrLock:AnsiString; aLockOwner:Integer; aLifeTime:TDateTime; aCallerAction:ICallerAction; aOptions:TLockOptions);
  var tmpPStrLockRec:PLockRec;
begin
  if assigned(FPStrLockRec) then begin
    tmpPStrLockRec:=InternalGetLastStrLockRec;
    New(tmpPStrLockRec^.Next);
    tmpPStrLockRec:=tmpPStrLockRec^.Next;
  end else begin
    New(FPStrLockRec);
    tmpPStrLockRec:=FPStrLockRec;
  end;
  tmpPStrLockRec^.Next:=nil;
  tmpPStrLockRec^.LockOwner:=aLockOwner;
  tmpPStrLockRec^.LockCount:=1;
  tmpPStrLockRec^.IntLock:=-1;
  tmpPStrLockRec^.StrLock:=aStrLock;
  tmpPStrLockRec^.CreateTime:=Now;
  tmpPStrLockRec^.LifeTime:=aLifeTime;
  tmpPStrLockRec^.CallerAction:=aCallerAction;
  tmpPStrLockRec^.Options:=aOptions;
  Inc(FStrCount);
  if lopMessAdd in aOptions then InternalMessage(tmpPStrLockRec^.CreateTime, '+SL='''+aStrLock+''' LC=1 LO='+IntToStr(aLockOwner)+InternalLifeTimeInfo(tmpPStrLockRec^.LifeTime), mecApp, mesInformation, aCallerAction);
end;

procedure TSync.InternalAddIntLock(aIntLock:Integer; aLockOwner:Integer; aLifeTime:TDateTime; aCallerAction:ICallerAction; aOptions:TLockOptions);
  var tmpPIntLockRec:PLockRec;
begin
  if assigned(FPIntLockRec) then begin
    tmpPIntLockRec:=InternalGetLastIntLockRec;
    New(tmpPIntLockRec^.Next);
    tmpPIntLockRec:=tmpPIntLockRec^.Next;
  end else begin
    New(FPIntLockRec);
    tmpPIntLockRec:=FPIntLockRec;
  end;
  tmpPIntLockRec^.Next:=nil;
  tmpPIntLockRec^.LockOwner:=aLockOwner;
  tmpPIntLockRec^.LockCount:=1;
  tmpPIntLockRec^.IntLock:=aIntLock;
  tmpPIntLockRec^.StrLock:='';
  tmpPIntLockRec^.CreateTime:=Now;
  tmpPIntLockRec^.LifeTime:=aLifeTime;
  tmpPIntLockRec^.CallerAction:=aCallerAction;
  tmpPIntLockRec^.Options:=aOptions;
  Inc(FIntCount);
  if lopMessAdd in aOptions then InternalMessage(tmpPIntLockRec^.CreateTime, '+IL='+IntToStr(aIntLock)+' LC=1 LO='+IntToStr(aLockOwner)+InternalLifeTimeInfo(tmpPIntLockRec^.LifeTime), mecApp, mesInformation, aCallerAction);
end;

function TSync.InternalLifeTimeInfo(aLifeTime:TDateTime):AnsiString;
begin
  if aLifeTime=0 then begin
    Result:='';
  end else begin
    Result:='LifeTime expired at '+FormatDateTime('ddmmyy hh:nn:ss.zzz', aLifeTime);
  end;
end;

procedure TSync.InternalDelStrLock(aPStrLockRec, aPStrLockRecPrev:PLockRec);
begin
  if Not assigned(aPStrLockRec) then Exit;
  if assigned(aPStrLockRecPrev) then begin
    aPStrLockRecPrev^.Next:=aPStrLockRec^.Next;
  end else begin
    FPStrLockRec:=aPStrLockRec^.Next;
  end;
  if lopMessAdd in aPStrLockRec^.Options then InternalMessage(aPStrLockRec^.CreateTime, '-SL='''+aPStrLockRec^.StrLock+''' LC='+IntToStr(aPStrLockRec^.LockCount)+' LO='+IntToStr(aPStrLockRec^.LockOwner)+InternalLifeTimeInfo(aPStrLockRec^.LifeTime), mecApp, mesInformation, aPStrLockRec^.CallerAction);
  aPStrLockRec^.StrLock:='';
  aPStrLockRec^.CallerAction:=nil;
  Dispose(aPStrLockRec);
  Dec(FStrCount);
end;

procedure TSync.InternalDelIntLock(aPIntLockRec, aPIntLockRecPrev:PLockRec);
begin
  if Not assigned(aPIntLockRec) then Exit;
  if assigned(aPIntLockRecPrev) then begin
    aPIntLockRecPrev^.Next:=aPIntLockRec^.Next;
  end else begin
    FPIntLockRec:=aPIntLockRec^.Next;
  end;
  if lopMessAdd in aPIntLockRec^.Options then InternalMessage(aPIntLockRec^.CreateTime, '-IL='+IntToStr(aPIntLockRec^.IntLock)+' LC='+IntToStr(aPIntLockRec^.LockCount)+' LO='+IntToStr(aPIntLockRec^.LockOwner)+InternalLifeTimeInfo(aPIntLockRec^.LifeTime), mecApp, mesInformation, aPIntLockRec^.CallerAction);
  aPIntLockRec^.StrLock:='';
  aPIntLockRec^.CallerAction:=nil;
  Dispose(aPIntLockRec);
  Dec(FIntCount);
end;

procedure TSync.InternalSearchStrLock(Const aStrLock:AnsiString; Out aPStrLockRec, aPStrLockRecPrev:PLockRec; aSearchSubStrLock:Boolean=False);
  var tmpPStrLockRec, tmpPStrLockRecPrev:PLockRec;
begin
  if assigned(aPStrLockRec) then begin
    tmpPStrLockRec:=aPStrLockRec^.Next;
    tmpPStrLockRecPrev:=aPStrLockRec;
  end else begin
    tmpPStrLockRec:=FPStrLockRec;
    tmpPStrLockRecPrev:=nil;
  end;
  While True do begin
    if Not assigned(tmpPStrLockRec) then begin//Список кончился и значит лок не существует
      aPStrLockRec:=nil;
      aPStrLockRecPrev:=nil;
      break;
    end;
    if (tmpPStrLockRec^.LifeTime=0)Or(tmpPStrLockRec^.LifeTime>=Now) then begin//Еще не устарел
      if ((Not aSearchSubStrLock)And(AnsiUpperCase(tmpPStrLockRec^.StrLock)=AnsiUpperCase(aStrLock)))Or((aSearchSubStrLock)And(Pos(AnsiUpperCase(aStrLock), AnsiUpperCase(tmpPStrLockRec^.StrLock))=1)) then begin//Искомый лок
        aPStrLockRec:=tmpPStrLockRec;
        aPStrLockRecPrev:=tmpPStrLockRecPrev;
        Break;    
      end;
    end else begin//Устарел
      InternalDelStrLock(tmpPStrLockRec, tmpPStrLockRecPrev);//Удаляю устаревший лок
      if assigned(tmpPStrLockRecPrev) then begin//Предыдущий элемент существ.
        tmpPStrLockRec:=tmpPStrLockRecPrev;//tmpPStrLockRec уже удалел. Делаю шаг назад
      end else begin//Предыдущ. элем. не сущ.
        //tmpPStrLockRecPrev:=nil;-уже нил, следует из условия.
        tmpPStrLockRec:=FPStrLockRec;//Ставлю с начала
        Continue;
      end;
    end;
    tmpPStrLockRecPrev:=tmpPStrLockRec;
    tmpPStrLockRec:=tmpPStrLockRec^.Next;
  end;
end;

procedure TSync.InternalSearchIntLock(aIntLock:Integer; Out aPIntLockRec, aPIntLockRecPrev:PLockRec);
  var tmpPIntLockRec, tmpPIntLockRecPrev:PLockRec;
begin
  if assigned(aPIntLockRec) then begin
    tmpPIntLockRec:=aPIntLockRec^.Next;
    tmpPIntLockRecPrev:=aPIntLockRec;
  end else begin
    tmpPIntLockRec:=FPIntLockRec;
    tmpPIntLockRecPrev:=nil;
  end;
  While True do begin
    if Not assigned(tmpPIntLockRec) then begin//Список кончился и значит лок не существует
      aPIntLockRec:=nil;
      aPIntLockRecPrev:=nil;
      break;
    end;
    if (tmpPIntLockRec^.LifeTime=0)Or(tmpPIntLockRec^.LifeTime>=Now) then begin//Еще не устарел
      if (tmpPIntLockRec^.IntLock=aIntLock) then begin//Искомый лок
        aPIntLockRec:=tmpPIntLockRec;
        aPIntLockRecPrev:=tmpPIntLockRecPrev;
        Break;
      end;
    end else begin//Устарел
      InternalDelIntLock(tmpPIntLockRec, tmpPIntLockRecPrev);//Удаляю устаревший лок
      if assigned(tmpPIntLockRecPrev) then begin//Предыдущий элемент существ.
        tmpPIntLockRec:=tmpPIntLockRecPrev;//tmpPIntLockRec уже удалел. Делаю шаг назад
      end else begin//Предыдущ. элем. не сущ.
        //tmpPIntLockRecPrev:=nil;-уже нил, следует из условия.
        tmpPIntLockRec:=FPIntLockRec;//Ставлю с начала
        Continue;
      end;
    end;
    tmpPIntLockRecPrev:=tmpPIntLockRec;
    tmpPIntLockRec:=tmpPIntLockRec^.Next;
  end;
end;

procedure TSync.InternalSearchStrLockOwner(aLockOwner:Integer; Out aPStrLockRec, aPStrLockRecPrev:PLockRec);
  var tmpPStrLockRec, tmpPStrLockRecPrev:PLockRec;
begin
  if assigned(aPStrLockRec) then begin
    tmpPStrLockRec:=aPStrLockRec^.Next;
    tmpPStrLockRecPrev:=aPStrLockRec;
  end else begin
    tmpPStrLockRec:=FPStrLockRec;
    tmpPStrLockRecPrev:=nil;
  end;
  While True do begin
    if Not assigned(tmpPStrLockRec) then begin//Список кончился и значит лок не существует
      aPStrLockRec:=nil;
      aPStrLockRecPrev:=nil;
      break;
    end;
    if (tmpPStrLockRec^.LifeTime=0)Or(tmpPStrLockRec^.LifeTime>=Now) then begin//Еще не устарел
      if (tmpPStrLockRec^.LockOwner=aLockOwner) then begin//Искомый лок
        aPStrLockRec:=tmpPStrLockRec;
        aPStrLockRecPrev:=tmpPStrLockRecPrev;
        Break;
      end;
    end else begin//Устарел
      InternalDelStrLock(tmpPStrLockRec, tmpPStrLockRecPrev);//Удаляю устаревший лок
      if assigned(tmpPStrLockRecPrev) then begin//Предыдущий элемент существ.
        tmpPStrLockRec:=tmpPStrLockRecPrev;//tmpPStrLockRec уже удалел. Делаю шаг назад
      end else begin//Предыдущ. элем. не сущ.
        //tmpPStrLockRecPrev:=nil;-уже нил, следует из условия.
        tmpPStrLockRec:=FPStrLockRec;//Ставлю с начала
        Continue;
      end;
    end;
    tmpPStrLockRecPrev:=tmpPStrLockRec;
    tmpPStrLockRec:=tmpPStrLockRec^.Next;
  end;
end;

procedure TSync.InternalSearchIntLockOwner(aLockOwner:Integer; Out aPIntLockRec, aPIntLockRecPrev:PLockRec);
  var tmpPIntLockRec, tmpPIntLockRecPrev:PLockRec;
begin
  if assigned(aPIntLockRec) then begin
    tmpPIntLockRec:=aPIntLockRec^.Next;
    tmpPIntLockRecPrev:=aPIntLockRec;
  end else begin
    tmpPIntLockRec:=FPIntLockRec;
    tmpPIntLockRecPrev:=nil;
  end;
  While True do begin
    if Not assigned(tmpPIntLockRec) then begin//Список кончился и значит лок не существует
      aPIntLockRec:=nil;
      aPIntLockRecPrev:=nil;
      break;
    end;
    if (tmpPIntLockRec^.LifeTime=0)Or(tmpPIntLockRec^.LifeTime>=Now) then begin//Еще не устарел
      if (tmpPIntLockRec^.LockOwner=aLockOwner) then begin//Искомый лок
        aPIntLockRec:=tmpPIntLockRec;
        aPIntLockRecPrev:=tmpPIntLockRecPrev;
        Break;
      end;
    end else begin//Устарел
      InternalDelIntLock(tmpPIntLockRec, tmpPIntLockRecPrev);//Удаляю устаревший лок
      if assigned(tmpPIntLockRecPrev) then begin//Предыдущий элемент существ.
        tmpPIntLockRec:=tmpPIntLockRecPrev;//tmpPIntLockRec уже удалел. Делаю шаг назад
      end else begin//Предыдущ. элем. не сущ.
        //tmpPIntLockRecPrev:=nil;-уже нил, следует из условия.
        tmpPIntLockRec:=FPIntLockRec;//Ставлю с начала
        Continue;
      end;
    end;
    tmpPIntLockRecPrev:=tmpPIntLockRec;
    tmpPIntLockRec:=tmpPIntLockRec^.Next;
  end;
end;

procedure TSync.InternalSetLockInfo(alPLockInfo:PLockInfo; aPIntLockRec:PLockRec);
begin
  if assigned(alPLockInfo) then begin
    if assigned(aPIntLockRec) then begin
      alPLockInfo^.LockOwner:=aPIntLockRec^.LockOwner;
      alPLockInfo^.LockCount:=aPIntLockRec^.LockCount;
      alPLockInfo^.IntLock:=aPIntLockRec^.IntLock;
      alPLockInfo^.StrLock:=aPIntLockRec^.StrLock;
      alPLockInfo^.CreateTime:=aPIntLockRec^.CreateTime;
      alPLockInfo^.LifeTime:=aPIntLockRec^.LifeTime;
      alPLockInfo^.CallerAction:=aPIntLockRec^.CallerAction;
      alPLockInfo^.Options:=aPIntLockRec^.Options;
    end else begin
      alPLockInfo^.LockOwner:=0;
      alPLockInfo^.LockCount:=0;
      alPLockInfo^.IntLock:=0;
      alPLockInfo^.StrLock:='';
      alPLockInfo^.CreateTime:=0;
      alPLockInfo^.LifeTime:=0;
      alPLockInfo^.CallerAction:=nil;
      alPLockInfo^.Options:=[];
    end;
  end;
end;

function TSync.InternalGetUserName(aPIntLockRec:PLockRec):AnsiString;
begin
  if assigned(aPIntLockRec^.CallerAction) then begin
    Result:=aPIntLockRec^.CallerAction.UserName;
  end else begin
    Result:='Unknown';
  end;
end;

function TSync.ITSetIntLock(aIntLock:Integer; aLockOwner:Integer; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aPLockInfo:PLockInfo{=Nil}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;
  var tmpPIntLockRec, tmpPIntLockRecPrev:PLockRec;
begin
  InternalLock;
  try
    Result:=False;//warning
    tmpPIntLockRec:=nil;
    tmpPIntLockRecPrev:=nil;
    InternalSearchIntLock(aIntLock, tmpPIntLockRec, tmpPIntLockRecPrev);
    if assigned(tmpPIntLockRec) then begin//нашел
      if tmpPIntLockRec^.LockOwner=aLockOwner then begin//мой
        Inc(tmpPIntLockRec^.LockCount);//Увеличиваю счетчик локов
        if tmpPIntLockRec^.Options<>[{lopMessAdd}] then begin//Для оптимизации, т.к. я предпологаю что большинство локов будет только с [lopMessAdd].
          if Not(lopNoChangeCallerActionAtRelock in tmpPIntLockRec^.Options) then begin//Можно менять CallerAction
            tmpPIntLockRec^.CallerAction:=aCallerAction;
          end;
          if Not(lopNoChangeLifeTimeAtRelock in tmpPIntLockRec^.Options) then begin//Можно менять LifeTime
            tmpPIntLockRec^.LifeTime:=aLifeTime;
          end;
          if Not(lopNoChangeOptionsAtRelock in tmpPIntLockRec^.Options) then begin//Можно менять Options
            tmpPIntLockRec^.Options:=aOptions;//ЭТО ПРОСВОЕНИЕ ДОЛЖНО БЫТЬ ПОСЛЕДНИМ
          end;
        end;
        if lopMessAdd in tmpPIntLockRec^.Options then InternalMessage(tmpPIntLockRec^.CreateTime, '+IL='+IntToStr(aIntLock)+' LC='+IntToStr(tmpPIntLockRec^.LockCount)+' LO='+IntToStr(aLockOwner)+InternalLifeTimeInfo(tmpPIntLockRec^.LifeTime), mecApp, mesInformation, aCallerAction);
        Result:=True;
      end else begin//чужой
        if aRaise then begin
          raise exception.createFmtHelp(cserLockedByAnotherUser, [aLockOwner, IntToStr(aIntLock), FormatDateTime('ddmmyy hh:nn:ss.zzz', tmpPIntLockRec^.CreateTime), InternalGetUserName(tmpPIntLockRec), tmpPIntLockRec^.LockOwner], cnerLockedByAnotherUser);
        end else begin
          Result:=False;
        end;
      end;
    end else begin//не нашел
      InternalAddIntLock(aIntLock, aLockOwner, aLifeTime, aCallerAction, aOptions);
      Result:=True;
    end;
    InternalSetLockInfo(aPLockInfo, tmpPIntLockRec);
  finally
    InternalUnlock;
  end;
end;

function TSync.ITSetIntLockWait(aIntLock:Integer; aLockOwner:Integer; aWait:Cardinal; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aPLockInfo:PLockInfo{=Nil}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;
  var tmpTimeOut:Cardinal;
begin
  tmpTimeOut:=0;
  Repeat
    if tmpTimeOut>=aWait then begin//время вышло
      Result:=ITSetIntLock(aIntLock, aLockOwner, aCallerAction, aLifeTime, aPLockInfo, aRaise, aOptions);
      Break;
    end else begin//еще ждем
      Result:=ITSetIntLock(aIntLock, aLockOwner, aCallerAction, aLifeTime, aPLockInfo, False{aRaise}, aOptions);
      if Result then break;
    end;
    Inc(tmpTimeOut, 333);
    Sleep(333);
  Until false;
end;

function TSync.ITFreeIntLock(aIntLock:Integer; aLockOwner:Integer):integer;
  var tmpPIntLockRec, tmpPIntLockRecPrev:PLockRec;
begin
  InternalLock;
  try
    tmpPIntLockRec:=nil;
    tmpPIntLockRecPrev:=nil;
    InternalSearchIntLock(aIntLock, tmpPIntLockRec, tmpPIntLockRecPrev);
    if assigned(tmpPIntLockRec) then begin//нашел
      if tmpPIntLockRec^.LockOwner=aLockOwner then begin//мой
        if tmpPIntLockRec^.LockCount<2 then begin//можно разбирать
          InternalDelIntLock(tmpPIntLockRec, tmpPIntLockRecPrev);
          result:=0;
        end else begin//нужно убавить счетчик
          Dec(tmpPIntLockRec^.LockCount);
          result:=tmpPIntLockRec^.LockCount;
          if lopMessAdd in tmpPIntLockRec^.Options then InternalMessage(tmpPIntLockRec^.CreateTime, '-IL='+IntToStr(aIntLock)+' LC='+IntToStr(tmpPIntLockRec^.LockCount)+' LO='+IntToStr(aLockOwner)+InternalLifeTimeInfo(tmpPIntLockRec^.LifeTime), mecApp, mesInformation, tmpPIntLockRec^.CallerAction);
        end;
        //Result:=True;
      end else begin//не мой
        result:=-2;//Result:=False;
      end;
    end else begin//не нашел
      result:=-1;//Result:=False;
    end;
  finally
    InternalUnlock;
  end;
end;

function TSync.ITClearIntLockOwner(aLockOwner:Integer):Integer{count};
  var tmpPIntLockRec, tmpPIntLockRecPrev:PLockRec;
begin
  Result:=0;
  tmpPIntLockRec:=nil;
  tmpPIntLockRecPrev:=nil;
  Repeat
    InternalSearchIntLockOwner(aLockOwner, tmpPIntLockRec, tmpPIntLockRecPrev);
    if assigned(tmpPIntLockRec) then begin//нашел
      InternalDelIntLock(tmpPIntLockRec, tmpPIntLockRecPrev);
      tmpPIntLockRec:=tmpPIntLockRecPrev;
      tmpPIntLockRecPrev:=nil;
      Inc(Result);
    end else begin//не нашел
      Break;
    end;
  Until False;
end;



function TSync.ITSetStrLock(Const aStrLock:AnsiString; aLockOwner:Integer; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aPLockInfo:PLockInfo{=Nil}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;
begin
  InternalLock;
  try
    Result:=InternalSetStrLock(aStrLock, aLockOwner, aCallerAction, aLifeTime, aPLockInfo, aRaise, aOptions);
  finally
    InternalUnlock;
  end;
end;

function TSync.InternalSetStrLock(const aStrLock:AnsiString; aLockOwner:Integer; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aPLockInfo:PLockInfo{=Nil}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;
  var tmpPStrLockRec, tmpPStrLockRecPrev:PLockRec;
begin//Result:=False;//warning
  tmpPStrLockRec:=nil;
  tmpPStrLockRecPrev:=nil;
  InternalSearchStrLock(aStrLock, tmpPStrLockRec, tmpPStrLockRecPrev);
  if assigned(tmpPStrLockRec) then begin//нашел
    if tmpPStrLockRec^.LockOwner=aLockOwner then begin//мой
      Inc(tmpPStrLockRec^.LockCount);//Увеличиваю счетчик локов
      if tmpPStrLockRec^.Options<>[{lopMessAdd}] then begin//Для оптимизации, т.к. я предпологаю что большинство локов будет только с [lopMessAdd].
        if not(lopNoChangeCallerActionAtRelock in tmpPStrLockRec^.Options) then begin//Можно менять CallerAction
          tmpPStrLockRec^.CallerAction:=aCallerAction;
        end;
        if not(lopNoChangeLifeTimeAtRelock in tmpPStrLockRec^.Options) then begin//Можно менять LifeTime
          tmpPStrLockRec^.LifeTime:=aLifeTime;
        end;
        if not(lopNoChangeOptionsAtRelock in tmpPStrLockRec^.Options) then begin//Можно менять Options
          tmpPStrLockRec^.Options:=aOptions;//ЭТО ПРОСВОЕНИЕ ДОЛЖНО БЫТЬ ПОСЛЕДНИМ
        end;
      end;
      if lopMessAdd in tmpPStrLockRec^.Options then InternalMessage(tmpPStrLockRec^.CreateTime, '+SL='''+aStrLock+''' LC='+IntToStr(tmpPStrLockRec^.LockCount)+' LO='+IntToStr(aLockOwner)+InternalLifeTimeInfo(tmpPStrLockRec^.LifeTime), mecApp, mesInformation, aCallerAction);
      Result:=True;
    end else begin//чужой
      if aRaise then begin
        raise exception.createFmtHelp(cserLockedByAnotherUser, [aLockOwner, aStrLock, FormatDateTime('ddmmyy hh:nn:ss.zzz', tmpPStrLockRec^.CreateTime), InternalGetUserName(tmpPStrLockRec), tmpPStrLockRec^.LockOwner], cnerLockedByAnotherUser);
      end else begin
        Result:=False;
      end;
    end;
  end else begin//не нашел
    InternalAddStrLock(aStrLock, aLockOwner, aLifeTime, aCallerAction, aOptions);
    Result:=True;
  end;
  InternalSetLockInfo(aPLockInfo, tmpPStrLockRec);
end;

function TSync.ITSetStrLockWait(const aStrLock:AnsiString; aLockOwner:Integer; aWait:Cardinal; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aPLockInfo:PLockInfo{=Nil}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;
  var tmpTimeOut:Cardinal;
begin
  tmpTimeOut:=0;
  repeat
    if tmpTimeOut>=aWait then begin//время вышло
      Result:=ITSetStrLock(aStrLock, aLockOwner, aCallerAction, aLifeTime, aPLockInfo, aRaise, aOptions);
      Break;
    end else begin//еще ждем
      Result:=ITSetStrLock(aStrLock, aLockOwner, aCallerAction, aLifeTime, aPLockInfo, False{aRaise}, aOptions);
      if Result then break;
    end;
    Inc(tmpTimeOut, 333);
    Sleep(333);
  until false;
end;

function TSync.ITStrLockSubExists(const aStrLockSub:AnsiString; aPLockInfo:PLockInfo{=Nil}):Boolean;
  var tmpPStrLockRec, tmpPStrLockRecPrev:PLockRec;
begin
  InternalLock;
  try
    result:=false;
    tmpPStrLockRec:=nil;
    tmpPStrLockRecPrev:=nil;
    InternalSearchStrLock(aStrLockSub, tmpPStrLockRec, tmpPStrLockRecPrev, True);
    Result:=assigned(tmpPStrLockRec);
    InternalSetLockInfo(aPLockInfo, tmpPStrLockRec);
  finally
    InternalUnlock;
  end;
end;

function TSync.ITStrLockExists(const aStrLock:AnsiString; aPLockInfo:PLockInfo{=Nil}):Boolean;
  var tmpPStrLockRec, tmpPStrLockRecPrev:PLockRec;
begin
  InternalLock;
  try
    result:=false;
    tmpPStrLockRec:=nil;
    tmpPStrLockRecPrev:=nil;
    InternalSearchStrLock(aStrLock, tmpPStrLockRec, tmpPStrLockRecPrev, False);
    Result:=assigned(tmpPStrLockRec);
    InternalSetLockInfo(aPLockInfo, tmpPStrLockRec);
  finally
    InternalUnlock;
  end;
end;


function TSync.ITFreeStrLock(Const aStrLock:AnsiString; aLockOwner:Integer):integer;
begin
  InternalLock;
  try
    result:=InternalFreeStrLock(aStrLock, aLockOwner);
  finally
    InternalUnlock;
  end;
end;

function TSync.InternalFreeStrLock(Const aStrLock:AnsiString; aLockOwner:Integer):integer;
  var tmpPStrLockRec, tmpPStrLockRecPrev:PLockRec;
begin
  tmpPStrLockRec:=nil;
  tmpPStrLockRecPrev:=nil;
  InternalSearchStrLock(aStrLock, tmpPStrLockRec, tmpPStrLockRecPrev);
  if assigned(tmpPStrLockRec) then begin//нашел
    if tmpPStrLockRec^.LockOwner=aLockOwner then begin//мой
      if tmpPStrLockRec^.LockCount<2 then begin//можно разбирать
        InternalDelStrLock(tmpPStrLockRec, tmpPStrLockRecPrev);
        result:=0;
      end else begin//нужно убавить счетчик
        Dec(tmpPStrLockRec^.LockCount);
        result:=tmpPStrLockRec^.LockCount;
        if lopMessAdd in tmpPStrLockRec^.Options then InternalMessage(tmpPStrLockRec^.CreateTime, '-SL='''+aStrLock+''' LC='+IntToStr(tmpPStrLockRec^.LockCount)+' LO='+IntToStr(aLockOwner)+InternalLifeTimeInfo(tmpPStrLockRec^.LifeTime), mecApp, mesInformation, tmpPStrLockRec^.CallerAction);
      end;
      //Result:=True;
    end else begin//не мой
      result:=-2;//Result:=False;
    end;
  end else begin//не нашел
    result:=-1;//Result:=False;
  end;
end;

function TSync.ITClearStrLockOwner(aLockOwner:Integer):Integer{count};
  var tmpPStrLockRec, tmpPStrLockRecPrev:PLockRec;
begin
  Result:=0;
  tmpPStrLockRec:=nil;
  tmpPStrLockRecPrev:=nil;
  Repeat
    InternalSearchStrLockOwner(aLockOwner, tmpPStrLockRec, tmpPStrLockRecPrev);
    if assigned(tmpPStrLockRec) then begin//нашел
      InternalDelStrLock(tmpPStrLockRec, tmpPStrLockRecPrev);
      tmpPStrLockRec:=tmpPStrLockRecPrev;
      tmpPStrLockRecPrev:=nil;
      Inc(Result);
    end else begin//не нашел
      Break;
    end;
  Until False;
end;

function TSync.ITClearLockOwner(aLockOwner:Integer):Integer{count};
begin
  InternalLock;
  try
    Result:=ITClearIntLockOwner(aLockOwner)+ITClearStrLockOwner(aLockOwner);
  finally
    InternalUnlock;
  end;
end;

procedure TSync.InternalRaiseLocked(aCallerAction:ICallerAction; aOtherLockOwner:Integer; aPStrLockRec:PLockRec; aRaise:boolean);
  var tmpMessage:AnsiString;
begin
  if assigned(aPStrLockRec) then tmpMessage:=Format(cserLockedByAnotherUser, [aOtherLockOwner, aPStrLockRec^.StrLock, FormatDateTime('ddmmyy hh:nn:ss.zzz', aPStrLockRec^.CreateTime), InternalGetUserName(aPStrLockRec), aPStrLockRec^.LockOwner])
      else tmpMessage:=Format(cserLockedByAnotherUser, [0, '?', '?', 0]);
  if aRaise then Raise Exception.CreateHelp(tmpMessage, cnerLockedByAnotherUser)
      else InternalMessage(now, tmpMessage, mecApp, mesWarning{mesError}, aCallerAction);
end;

function TSync.InternalParseAndCheckExistsStrLock(aCallerAction:ICallerAction; Const aStrLocks:AnsiString; aLockOwner:Integer; aSetStrLocks, aFreeStrLocks:PAnsiString; aAsLockList:Boolean; aRaise:Boolean; aFirstExistsLock:PLockRec):Boolean{ExistsLock};
  var tmpSt:AnsiString;
      tmpPStrLockRec, tmpPStrLockRecPrev:PLockRec;
  procedure localCheckExists(aLockStr:PAnsiString);
  begin
    if aAsLockList then tmpSt:=Copy(tmpSt, 2, Length(tmpSt)-1);
    if assigned(aLockStr) then aLockStr^:=aLockStr^+tmpSt+csParamsStrSeparator;
    tmpPStrLockRec:=nil;//Проверяю существует ли такой лок, и если да, то "мой" ли он
    tmpPStrLockRecPrev:=nil;
    InternalSearchStrLock(tmpSt, tmpPStrLockRec, tmpPStrLockRecPrev, False);
    Result:=(assigned(tmpPStrLockRec))And(tmpPStrLockRec^.LockOwner<>aLockOwner);
  end;
  var tmpCurrentPos:Integer;
begin
  Result:=False;
  if Not((aAsLockList)And(assigned(aSetStrLocks))And(assigned(aFreeStrLocks))) then Raise Exception.Create('Invalid input params.');
  if assigned(aSetStrLocks) then aSetStrLocks^:='';
  if assigned(aFreeStrLocks) then aFreeStrLocks^:='';
  tmpCurrentPos:=-1;
  while True do begin//Получаю список "локов" и "Un-локов", при этом проверяю возможность их установить.
    tmpSt:=GetParamFromParamsStr(tmpCurrentPos, aStrLocks, csParamsStrSeparator);
    if tmpCurrentPos=-1 then Break;
    if tmpSt<>'' then begin
      if aAsLockList then begin
        if tmpSt[1]=csAdd then begin
          localCheckExists(aSetStrLocks);
          if Result then Break;//Лок уже стоит, и залочин он др. пользователем
        end else if tmpSt[1]=csFree then begin
          localCheckExists(aFreeStrLocks);
          if Result then Break;//Лок уже стоит, и залочин он др. пользователем
        end else raise exception.create('Invalid format StrLocks(aStrLocks='''+aStrLocks+'''/tmpSt='''+tmpSt+''').');
      end else begin
        localCheckExists(aSetStrLocks);
        if Result then Break;//Лок уже стоит, и залочин он др. пользователем
        localCheckExists(aFreeStrLocks);
        if Result then Break;//Лок уже стоит, и залочин он др. пользователем
      end;
    end;
  end;
  if Result then InternalRaiseLocked(aCallerAction, aLockOwner, tmpPStrLockRec, aRaise);
end;

function TSync.ITSetStrLockList(Const aStrLockList:AnsiString; aLockOwner:Integer; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;
  var tmpSetStrLocks, tmpFreeStrLocks:AnsiString;
begin
  InternalLock;
  try
    Result:=Not InternalParseAndCheckExistsStrLock(aCallerAction, aStrLockList, aLockOwner, @tmpSetStrLocks, @tmpFreeStrLocks, True{aAsLockList}, aRaise, Nil{aFirstExistsLock});//ExistsLock
    if Not Result then Exit;//Запрошена установка без raise.//Теперь устанавливаю локи
    Result:=InternalSetStrLocks(tmpSetStrLocks, aLockOwner, aCallerAction, aLifeTime, aRaise, aOptions);//Теперь чищу локи
    Result:=InternalClearStrLocks(tmpFreeStrLocks, aLockOwner) Or Result;
  finally
    InternalUnlock;
  end;
end;

function TSync.ITSetStrLockListWait(Const aStrLockList:AnsiString; aLockOwner:Integer; aWait:Cardinal; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;
  var tmpTimeOut:Cardinal;
begin
  tmpTimeOut:=0;
  Repeat
    if tmpTimeOut>=aWait then begin//время вышло
      Result:=ITSetStrLockList(aStrLockList, aLockOwner, aCallerAction, aLifeTime, aRaise, aOptions); 
      Break;
    end else begin//еще ждем
      Result:=ITSetStrLockList(aStrLockList, aLockOwner, aCallerAction, aLifeTime, False{aRaise}, aOptions);
      if Result then break;
    end;
    Inc(tmpTimeOut, 333);
    Sleep(333);
  Until false;
end;

function TSync.InternalSetStrLocks(Const aStrLocks:AnsiString; aLockOwner:Integer; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;
  var tmpCurrentPos:Integer;
      tmpSt:AnsiString;
begin
  Result:=False;
  if aStrLocks='' then Exit;
  tmpCurrentPos:=-1;
  While True do begin//Получаю список "локов" и "Un-локов", при этом проверяю возможность их установить.
    tmpSt:=GetParamFromParamsStr(tmpCurrentPos, aStrLocks, csParamsStrSeparator);
    if tmpCurrentPos=-1 then Break;
    Result:=InternalSetStrLock(tmpSt, aLockOwner, aCallerAction, aLifeTime, Nil, aRaise, aOptions) Or Result;
  end;
end;

function TSync.ITSetStrLocks(Const aStrLocks:AnsiString; aLockOwner:Integer; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;
begin
  InternalLock;
  try
    Result:=InternalSetStrLocks(aStrLocks, aLockOwner, aCallerAction, aLifeTime, aRaise, aOptions);
  finally
    InternalUnlock;
  end;
end;

function TSync.ITSetStrLocksWait(Const aStrLocks:AnsiString; aLockOwner:Integer; aWait:Cardinal; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;
  var tmpTimeOut:Cardinal;
begin
  tmpTimeOut:=0;
  Repeat
    if tmpTimeOut>=aWait then begin//время вышло
      Result:=ITSetStrLocks(aStrLocks, aLockOwner, aCallerAction, aLifeTime, aRaise, aOptions);
      Break;
    end else begin//еще ждем
      Result:=ITSetStrLocks(aStrLocks, aLockOwner, aCallerAction, aLifeTime, False{aRaise}, aOptions);
      if Result then break;
    end;
    Inc(tmpTimeOut, 333);
    Sleep(333);
  Until false;
end;

function TSync.InternalClearStrLocks(const aStrLocks:AnsiString; aLockOwner:Integer):Boolean;
  var tmpCurrentPos:Integer;
      tmpSt:AnsiString;
begin
  Result:=False;
  if aStrLocks='' then Exit;
  tmpCurrentPos:=-1;
  While True do begin//Получаю список "локов" и "Un-локов", при этом проверяю возможность их установить.
    tmpSt:=GetParamFromParamsStr(tmpCurrentPos, aStrLocks, csParamsStrSeparator);
    if tmpCurrentPos=-1 then Break;
    Result:=(InternalFreeStrLock(tmpSt, aLockOwner)<0)or Result;
  end;
end;

function TSync.ITClearStrLocks(Const aStrLocks:AnsiString; aLockOwner:Integer):Boolean;
begin
  InternalLock;
  try
    Result:=InternalClearStrLocks(aStrLocks, aLockOwner);
  finally
    InternalUnlock;
  end;
end;

procedure ReplaceSymPoint(aString:PAnsiString);
  var tmpI:Integer;
begin
  for tmpI:=1 to length(aString^) do
    if aString^[tmpI]=',' then aString^[tmpI]:=';';
end;

function TSync.ITSetLockList(const aLockList{, aUser}:AnsiString; aCallerAction:ICallerAction; aLockOwner:Integer; aRaise:Boolean; aMessAdd:boolean{=true}):Boolean;
begin
  ReplaceSymPoint(@aLockList);
  Result:=ITSetStrLockList(aLockList, aLockOwner, aCallerAction, 0, aRaise, BoolToLockOptions(aMessAdd));
end;

function TSync.ITSetLockListWait(const aLockList{, aUser}:AnsiString; aCallerAction:ICallerAction; aLockOwner:Integer; aRaise:Boolean; aTimeout:Integer; aMessAdd:boolean{=true}):Boolean;
begin
  ReplaceSymPoint(@aLockList);
  Result:=ITSetStrLockListWait(aLockList, aLockOwner, aTimeout, aCallerAction, 0, aRaise, BoolToLockOptions(aMessAdd));
end;

function TSync.ITSetLock(const aLock{, aUser}:AnsiString; aCallerAction:ICallerAction; aLockOwner:Integer; aRaise:Boolean; aMessAdd:boolean{=true}):Boolean;
begin
  ReplaceSymPoint(@aLock);
  Result:=ITSetStrLock(aLock, aLockOwner, aCallerAction, 0, Nil, aRaise, BoolToLockOptions(aMessAdd));
end;

function TSync.ITFreeLock(const aLock:AnsiString; aLockOwner:Integer):integer;
begin
  ReplaceSymPoint(@aLock);
  Result:=ITFreeStrLock(aLock, aLockOwner);
end;

function TSync.ITSetLockWait(const aLock{, aUser}:AnsiString; aCallerAction:ICallerAction; aLockOwner:Integer; aRaise:Boolean; aTimeout:Integer; aMessAdd:boolean{=true}):Boolean;
begin
  ReplaceSymPoint(@aLock);
  Result:=ITSetStrLockWait(aLock, aLockOwner, aTimeout, aCallerAction, 0, Nil, aRaise, BoolToLockOptions(aMessAdd));
end;

function TSync.ITGetLockList:Variant;
  var tmpI:Integer;
      tmpPStrLockRec:PLockRec;
  function localGetUserName(aCallerAction:ICallerAction):ansiString;begin
    if assigned(aCallerAction) then result:=aCallerAction.UserName else result:='Unknown';
  end;
begin
  InternalLock;
  try
    if not assigned(FPStrLockRec) then begin
      Result:=unassigned;
      exit;
    end;
    Result:=VarArrayCreate([0, FStrCount-1], varVariant);
    tmpPStrLockRec:=FPStrLockRec;
    tmpI:=0;
    while assigned(tmpPStrLockRec) do begin
      Result[tmpI]:=VarArrayOf([tmpPStrLockRec^.StrLock, localGetUserName(tmpPStrLockRec^.CallerAction), tmpPStrLockRec^.CreateTime, tmpPStrLockRec^.LockOwner, tmpPStrLockRec^.LockCount]);//[0]-Имя лока; [1]-UserName; [2]-DateTime; [3]-ASMNum; [4]-lock count;
      tmpPStrLockRec:=tmpPStrLockRec^.Next;
      inc(tmpI);
    end;
  finally
    InternalUnlock;
  end;
end;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure TSync.InternalFinal;
begin
  ITClearLock;
  FAppMessage:=nil;
end;

function TSync.InternalGetIAppMessage:IAppMessage;
begin
  if not assigned(FAppMessage) then cnTray.Query(IAppMessage, FAppMessage);
  result:=FAppMessage;
end;

procedure TSync.InternalMessage(aStartTime:TDateTime; Const aMessage:AnsiString; aMec:TMessageClass; aMes:TMessageStyle; aCallerAction:ICallerAction);
  var tmpTray:ITray;
begin
  if assigned(aCallerAction) then begin
    aCallerAction.ITMessAdd(aStartTime, now, 'Sync', aMessage, aMec, aMes)
  end else begin
    tmpTray:=cnTray;
    if (not assigned(FAppMessage))and(assigned(tmpTray)) then tmpTray.Query(IAppMessage, FAppMessage, false);
    if assigned(FAppMessage) then FAppMessage.ITMessAdd(aStartTime, now, '', 'Sync', aMessage, aMec, aMes);
  end;
end;

end.
