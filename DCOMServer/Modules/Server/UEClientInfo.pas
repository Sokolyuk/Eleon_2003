unit UEClientInfo;

interface
  Uses UEClientInfoTypes, UITObject;
Type
  TEClientInfo=Class(TITObject, IEClientInfo)
  Private
    FThis:Boolean;
    FStartTime:TDateTime;
    FID:Integer;
    FUser:AnsiString;
    FState:AnsiString;
    FLoginType:Integer;
    FEvent:boolean;
  Protected
    Function IT_GetThis:Boolean;
    Procedure IT_SetThis(Value:Boolean);
    Function IT_GetStartTime:TDateTime;
    Procedure IT_SetStartTime(Value:TDateTime);
    Function IT_GetID:Integer;
    Procedure IT_SetID(Value:Integer);
    Function IT_GetUser:AnsiString;
    Procedure IT_SetUser(Value:AnsiString);
    Function IT_GetState:AnsiString;
    Procedure IT_SetState(Value:AnsiString);
    Function IT_GetLoginType:Integer;
    Procedure IT_SetLoginType(Value:Integer);
    Function IT_GetEvent:boolean;
    Procedure IT_SetEvent(Value:boolean);
    Function IT_GetEClientV:Variant;
    Procedure IT_SetEClientV(Value:Variant);
  Public
    Constructor Create;
    Destructor Destroy; Override;
    Property ITThis:Boolean read IT_GetThis write IT_SetThis;
    Property ITStartTime:TDateTime read IT_GetStartTime write IT_SetStartTime;
    Property ITID:Integer read IT_GetID write IT_SetID;
    Property ITUser:AnsiString read IT_GetUser write IT_SetUser;
    Property ITState:AnsiString read IT_GetState write IT_SetState;
    Property ITLoginType:Integer read IT_GetLoginType write IT_SetLoginType;
    Property ITEvent:Boolean read IT_GetEvent write IT_SetEvent;
    Property ITEClientV:Variant read IT_GetEClientV write IT_SetEClientV;
  End;

implementation
  Uses Sysutils, Variants;

Constructor TEClientInfo.Create;
begin
  FThis:=False;
  FStartTime:=Now;
  FID:=-1;
  FUser:='';
  FState:='';
  FLoginType:=-1;
  FEvent:=False;
  Inherited Create;
end;

Destructor TEClientInfo.Destroy;
begin
  Inherited Destroy;
end;

Function TEClientInfo.IT_GetThis:Boolean;
begin
  InternalLock;
  try
    Result:=FThis;
  finally
    InternalUnlock;
  end;
end;

Procedure TEClientInfo.IT_SetThis(Value:Boolean);
begin
  InternalLock;
  try
    FThis:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TEClientInfo.IT_GetStartTime:TDateTime;
begin
  InternalLock;
  try
    Result:=FStartTime;
  finally
    InternalUnlock;
  end;
end;

Procedure TEClientInfo.IT_SetStartTime(Value:TDateTime);
begin
  InternalLock;
  try
    FStartTime:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TEClientInfo.IT_GetID:Integer;
begin
  InternalLock;
  try
    Result:=FID;
  finally
    InternalUnlock;
  end;
end;

Procedure TEClientInfo.IT_SetID(Value:Integer);
begin
  InternalLock;
  try
    FID:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TEClientInfo.IT_GetUser:AnsiString;
begin
  InternalLock;
  try
    Result:=FUser;
  finally
    InternalUnlock;
  end;
end;

Procedure TEClientInfo.IT_SetUser(Value:AnsiString);
begin
  InternalLock;
  try
    FUser:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TEClientInfo.IT_GetState:AnsiString;
begin
  InternalLock;
  try
    Result:=FState;
  finally
    InternalUnlock;
  end;
end;

Procedure TEClientInfo.IT_SetState(Value:AnsiString);
begin
  InternalLock;
  try
    FState:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TEClientInfo.IT_GetLoginType:Integer;
begin
  InternalLock;
  try
    Result:=FLoginType;
  finally
    InternalUnlock;
  end;
end;

Procedure TEClientInfo.IT_SetLoginType(Value:Integer);
begin
  InternalLock;
  try
    FLoginType:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TEClientInfo.IT_GetEvent:boolean;
begin
  InternalLock;
  try
    result:=FEvent;
  finally
    InternalUnlock;
  end;
end;

Procedure TEClientInfo.IT_SetEvent(Value:boolean);
begin
  InternalLock;
  try
    FEvent:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TEClientInfo.IT_GetEClientV:Variant;
begin
  InternalLock;
  try
    {[0]-aablThis [1]-aaStartDateTime [2]-aaNum [3]-aaUser [4]-aaState [5]-aaLoginType [6]-aaEvent}
    Result:=VarArrayOf([FThis, FStartTime, FID, FUser, FState, FLoginType, FEvent]);
  finally
    InternalUnlock;
  end;
end;

Procedure TEClientInfo.IT_SetEClientV(Value:Variant);
  Var tmpThis:Boolean;
      tmpStartTime:TDateTime;
      tmpID:Integer;
      tmpUser:AnsiString;
      tmpState:AnsiString;
      tmpLoginType:Integer;
      tmpEvent:Boolean;
begin
  InternalLock;
  try
    //[0]       [1]              [2]    [3]     [4]      [5]          [6]
    //aablThis, aaStartDateTime, aaNum, aaUser, aaState, aaLoginType, aaEvent
    try
      tmpThis:=Value[0];
      tmpStartTime:=Value[1];
      tmpID:=Value[2];
      tmpUser:=Value[3];
      tmpState:=Value[4];
      tmpLoginType:=Value[5];
      tmpEvent:=Value[6];
      //..
      FThis:=tmpThis;
      FStartTime:=tmpStartTime;
      FID:=tmpID;
      FUser:=tmpUser;
      FState:=tmpState;
      FLoginType:=tmpLoginType;
      FEvent:=tmpEvent;
    except
      On E:Exception do begin
        Raise Exception.Create('EClientInfo: '+e.message);
      end;  
    end;
  finally
    InternalUnlock;
  end;
end;



end.
