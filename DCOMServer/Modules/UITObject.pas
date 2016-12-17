//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UITObject;
interface
  uses Windows, UIObject, UITObjectTypes;
type
  TITObject=class(TIObject, IUnknown, IIntroCallBack)
  private
    CSLock:TRTLCriticalSection;
    FUseLock:Boolean;
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
    constructor create;
    constructor createUseLock(aUse:Boolean);
    destructor destroy;override;
  end;

implementation
  uses SysUtils, UMThreadUtils;

constructor TITObject.Create;
begin
  InitializeCriticalSection(CSLock);
  FUseLock:=True;
  inherited Create;
end;

constructor TITObject.CreateUseLock(aUse:Boolean);
begin
  InitializeCriticalSection(CSLock);
  FUseLock:=aUse;
  inherited create;
end;

destructor TITObject.destroy;
begin
  DeleteCriticalSection(CSLock);
  inherited destroy;
end;

{ TITObject.Lock }
procedure TITObject.InternalLock;
begin
  InternalLockWait(180000{3мин});
end;

resourcestring cserrorSetRaise='TITObject(''%s'').InternalLock(CSLock.LockCount=%s, CSLock.OwningThread=%s) unable to set InternalLock(CurrentThreadId=%s):''%s''.';

procedure TITObject.InternalSetRaise(const aMessage:AnsiString);
begin
  raise exception.createfmt(cserrorSetRaise, [ClassName, IntToStr(CSLock.LockCount), IntToStr(CSLock.OwningThread), IntToStr(GetCurrentThreadId), aMessage]);//не разлочилс€
end;

resourcestring cserrorMThreadBreakIsTrue='MThreadBreak is true.';

procedure TITObject.InternalLockWaitCS(aCS:PRTLCriticalSection; aWait:Integer);
  var tmpI:Integer;
begin
  if not FUseLock then Exit;
  tmpI:=0;
  while not TryEnterCriticalSection(aCS^) do begin
    if aWait<=0 then InternalSetRaise('');
    Dec(aWait, 20);
    if tmpI>=200 then begin//каждые 200msec провер€ю поток на Terminated.
      if MThreadBreak then raise exception.create(cserrorMThreadBreakIsTrue);
      tmpI:=0;
    end else inc(tmpI, 20);
    Sleep(20);
  end;
end;

procedure TITObject.InternalLockWait(aWait:Integer);
begin
  InternalLockWaitCS(@CSLock, aWait);
end;

function TITObject.InternalTryLock:Boolean;
begin
  if not FUseLock then begin
    Result:=True;
    Exit;
  end else Result:=TryEnterCriticalSection(CSLock);
end;

procedure TITObject.InternalUnLock;
begin
  if not FUseLock then Exit;
  LeaveCriticalSection(CSLock);
end;

procedure TITObject.IntroCallBack(aUserData:pointer; aCallBackBack:TCallBackBack);
begin
  InternalLock;
  try
    if assigned(aCallBackBack) then aCallBackBack(aUserData, self);
  finally
    InternalUnLock;
  end;
end;

procedure TITObject.IntroCallBackOfObject(aUserData:pointer; aCallBackOfObject:TCallBackBackOfObject);
begin
  InternalLock;
  try
    if assigned(aCallBackOfObject) then aCallBackOfObject(aUserData, self);
  finally
    InternalUnLock;
  end;
end;

end.
