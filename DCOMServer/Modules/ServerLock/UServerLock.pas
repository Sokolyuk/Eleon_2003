unit UServerLock;

interface
  uses UServerLockTypes, UITObject;
type
  TServerLock=class(TITObject, IServerLock)
  protected
    FMessage:AnsiString;
    FUser:AnsiString;
    FLock:boolean;
    FTime:TDateTime;
  public
    constructor create;
    destructor destroy;override;
    Function Get_ITServerLockMessage:AnsiString;virtual;
    Function Get_ITServerLockUser:AnsiString;virtual;
    Function Get_blServerLock:boolean;virtual;
    Property ITServerLockMessage:AnsiString read Get_ITServerLockMessage;
    Property ITServerLockUser:AnsiString read Get_ITServerLockUser;
    Property ITblServerLock:boolean read Get_blServerLock;
    Procedure ITServerLock(Const aUser, aMessage:AnsiString);virtual;
    Procedure ITServerUnLock;virtual;
  end;

implementation
  uses Variants, Sysutils;

constructor TServerLock.create;
begin
  inherited create;
  FMessage:='';
  FUser:='';
  FLock:=false;
  FTime:=0;
end;

destructor TServerLock.destroy;
begin
  inherited destroy;
end;

Function TServerLock.Get_ITServerLockMessage:AnsiString;
begin
  Internallock;
  try
    if FLock then Result:='Сервер заблокирован. '+FormatDateTime('ddmmyy hh:nn:ss.zzz', FTime)+' User='+FUser+': '''+FMessage+'''.' else Result:='Сервер не заблокирован.';
  finally
    Internalunlock;
  end;
end;

Function TServerLock.Get_ITServerLockUser:AnsiString;
begin
  Internallock;
  try
    if FLock then Result:=FUser Else Result:='';
  finally
    Internalunlock;
  end;
end;

Function TServerLock.Get_blServerLock:boolean;
begin
  Internallock;
  try
    Result:=FLock;
  finally
    Internalunlock;
  end;
end;

Procedure TServerLock.ITServerLock(Const aUser, aMessage:AnsiString);
begin
  Internallock;
  try
    FLock:=true;
    FTime:=now;
    FUser:=aUser;
    FMessage:=aMessage;
  finally
    Internalunlock;
  end;
end;

Procedure TServerLock.ITServerUnLock;
begin
  Internallock;
  try
    FLock:=false;
  finally
    Internalunlock;
  end;
end;

end.
