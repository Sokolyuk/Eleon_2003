//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UcoServerProc2BaseIT;

interface
  uses windows, UcoServerProc2Base, UITObjectTypes;
type
  TcoServerProc2BaseIT=class(TcoServerProc2Base)
  protected
    CSLock:TRTLCriticalSection;
  protected
    procedure InternalSetRaise(const aMessage:AnsiString);virtual;
    procedure InternalLock;virtual;
    procedure InternalLockWait(aWait:Integer);virtual;
    procedure InternalLockWaitCS(aCS:PRTLCriticalSection; aWait:Integer);virtual;
    function InternalTryLock:Boolean;virtual;
    procedure InternalUnLock;virtual;
  protected
    procedure IntroCallBack(aUserData:pointer; aCallBackBack:TCallBackBack);virtual;
    procedure IntroCallBackOfObject(aUserData:pointer; aCallBackOfObject:TCallBackBackOfObject);virtual;
  public
    procedure initialize;override;
    destructor destroy;override;
  end;


implementation
  uses Sysutils;

procedure TcoServerProc2BaseIT.initialize;
begin
  InitializeCriticalSection(CSLock);
  inherited initialize;
end;

destructor TcoServerProc2BaseIT.destroy;
begin
  inherited destroy;
  DeleteCriticalSection(CSLock);
end;

procedure TcoServerProc2BaseIT.InternalLock;
begin
  InternalLockWait(180000{3мин});
end;

resourcestring cserrorSetRaise='TITObject(''%s'').InternalLock(CSLock.LockCount=%s, CSLock.OwningThread=%s) unable to set InternalLock(CurrentThreadId=%s):''%s''.';

procedure TcoServerProc2BaseIT.InternalSetRaise(const aMessage:AnsiString);
begin
  raise exception.createfmt(cserrorSetRaise, [ClassName, IntToStr(CSLock.LockCount), IntToStr(CSLock.OwningThread), IntToStr(GetCurrentThreadId), aMessage]);//не разлочился
end;

resourcestring cserrorMThreadBreakIsTrue='MThreadBreak is true.';

procedure TcoServerProc2BaseIT.InternalLockWaitCS(aCS:PRTLCriticalSection; aWait:Integer);
begin
  while not TryEnterCriticalSection(aCS^) do begin
    if aWait<=0 then InternalSetRaise('');
    Dec(aWait, 20);
    Sleep(20);
  end;
end;

procedure TcoServerProc2BaseIT.InternalLockWait(aWait:Integer);
begin
  InternalLockWaitCS(@CSLock, aWait);
end;

function TcoServerProc2BaseIT.InternalTryLock:Boolean;
begin
  Result:=TryEnterCriticalSection(CSLock);
end;

procedure TcoServerProc2BaseIT.InternalUnLock;
begin
  LeaveCriticalSection(CSLock);
end;

procedure TcoServerProc2BaseIT.IntroCallBack(aUserData:pointer; aCallBackBack:TCallBackBack);
begin
  InternalLock;
  try
    if assigned(aCallBackBack) then aCallBackBack(aUserData, self);
  finally
    InternalUnLock;
  end;
end;

procedure TcoServerProc2BaseIT.IntroCallBackOfObject(aUserData:pointer; aCallBackOfObject:TCallBackBackOfObject);
begin
  InternalLock;
  try
    if assigned(aCallBackOfObject) then aCallBackOfObject(aUserData, self);
  finally
    InternalUnLock;
  end;
end;

end.
