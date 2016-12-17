//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UCaller;

interface
  uses Windows, UADMTypes, UITObject, UCallerTypes, UAppMessageTypes, UTrayTypes;
type
  { TCallerSecurityContext }
  TCallerSecurityContext=class(TITObject, ICallerSecurityContext)
  protected
    FUserName:AnsiString;
    FSecurityContext:Variant;
    function ITGetUserName:AnsiString;
    function ITGetSecurityContext:Variant;
    procedure ITSetSecurityContext(const Value:Variant);
    function ITGetAsString:AnsiString;
    procedure ITSetAsString(const Value:AnsiString);
  public
    constructor Create;overload;
    constructor Create(const aSecurityContext:Variant);overload;
    constructor Create(const aAsString:AnsiString);overload;
    destructor Destroy; override;
    property UserName:AnsiString read ITGetUserName;
    property SecurityContext:Variant read ITGetSecurityContext write ITSetSecurityContext;
    property AsString:AnsiString read ITGetAsString write ITSetAsString;
    function Clone:ICallerSecurityContext;virtual;
  end;

  { TCallerSenderParams }
  TCallerSenderParams=class(TITObject, ICallerSenderParams)
  protected
    FSenderParams:Variant;
    FSenderASMNum:Integer;
    FSenderADMTaskNum:TADMTask;
    FSenderPackCPID:Variant;
    FSenderPackPD:Variant;
    FSenderRouteParam:Variant;
    function ITGetSenderParams:Variant;
    procedure ITSetSenderParams(const Value:Variant);
    function ITGetSenderASMNum:Integer;
    procedure ITSetSenderASMNum(Value:Integer);
    function ITGetSenderADMTaskNum:TADMTask;
    procedure ITSetSenderADMTaskNum(Value:TADMTask);
    function ITGetSenderPackCPID:Variant;
    procedure ITSetSenderPackCPID(const Value:Variant);
    function ITGetSenderPackPD:Variant;
    procedure ITSetSenderPackPD(const Value:Variant);
    function ITGetSenderRouteParam:Variant;
    procedure ITSetSenderRouteParam(const Value:Variant);
    procedure InternalClearSenderParams;
  public
    constructor Create;overload;
    constructor Create(const aSenderParams:Variant);overload;
    destructor Destroy;override;
    { ICallerSecurityContext }
    property SenderParams:Variant read ITGetSenderParams write ITSetSenderParams;
    property SenderASMNum:Integer read ITGetSenderASMNum write ITSetSenderASMNum;
    property SenderADMTaskNum:TADMTask read ITGetSenderADMTaskNum write ITSetSenderADMTaskNum;
    property SenderPackCPID:Variant read ITGetSenderPackCPID write ITSetSenderPackCPID;
    property SenderPackPD:Variant read ITGetSenderPackPD write ITSetSenderPackPD;
    property SenderRouteParam:Variant read ITGetSenderRouteParam write ITSetSenderRouteParam;
    function Clone:ICallerSenderParams;virtual;
  end;

  {TCallerAction}
  TCallerAction=class(TITObject, ICallerAction)
  protected
    FAppMessage:IAppMessage;
  protected
    function InternalGetITray:ITray;virtual;
    function InternalGetIAppMessage:IAppMessage;virtual;
  protected
    FActionName:AnsiString;
    FICallerSecurityContext:ICallerSecurityContext;
    FICallerSenderParams:ICallerSenderParams;
    procedure InternalCreate;virtual;
    procedure InternalCreateNewAction;virtual;
    function InternalCreateNewActionName(aPrefix:AnsiString):AnsiString;virtual;
    function ITGetActionName:AnsiString;virtual;
    procedure ITSetActionName(const Value:AnsiString);virtual;
    function ITGetICallerSecurityContext:ICallerSecurityContext;virtual;
    procedure ITSetICallerSecurityContext(Value:ICallerSecurityContext);virtual;
    function ITGetICallerSenderParams:ICallerSenderParams;virtual;
    procedure ITSetICallerSenderParams(Value:ICallerSenderParams);virtual;
    function ITGetSenderParams:Variant;virtual;
    procedure ITSetSenderParams(const Value:Variant);virtual;
    function ITGetUserName:AnsiString;virtual;
    function ITGetSecurityContext:Variant;virtual;
    procedure ITSetSecurityContext(const Value:Variant);virtual;
  public
    constructor CreateNewAction(const aSecurityContext:Variant);overload;
    constructor CreateNewAction(const aSecurityContext:Variant; const aSenderParams:Variant);overload;
    constructor CreateNewAction(aCallerSecurityContext:ICallerSecurityContext);overload;
    constructor CreateNewAction(aCallerSecurityContext:ICallerSecurityContext; aCallerSenderParams:ICallerSenderParams);overload;
    constructor Create(const aActionName:AnsiString);overload;
    constructor Create(const aSecurityContext:Variant; const aActionName:AnsiString);overload;
    constructor Create(const aSecurityContext:Variant; const aSenderParams:Variant; const aActionName:AnsiString);overload;
    constructor Create(aCallerSecurityContext:ICallerSecurityContext; const aActionName:AnsiString);overload;
    constructor Create(aCallerSecurityContext:ICallerSecurityContext; aCallerSenderParams:ICallerSenderParams; const aActionName:AnsiString);overload;
    constructor Create;overload;
    destructor Destroy;override;
    { ICallerAction }
    procedure ITMessAdd(aStartTime, aEndTime:TDateTime; const aSource, aMess:AnsiString; aMessageClass:TMessageClass; aMessageStyle:TMessageStyle);virtual;
    procedure CreateNewActionName(aPrefix:AnsiString);virtual;
    //function Clone(aCallerSecurityContext:ICallerSecurityContext):ICallerAction;virtual;
    function Clone:ICallerAction;virtual;
    property UserName:AnsiString read ITGetUserName;
    property SecurityContext:Variant read ITGetSecurityContext write ITSetSecurityContext;
    property SenderParams:Variant read ITGetSenderParams write ITSetSenderParams;
    property ActionName:AnsiString read ITGetActionName Write ITSetActionName;
    property CallerSenderParams:ICallerSenderParams read ITGetICallerSenderParams write ITSetICallerSenderParams;
    property CallerSecurityContext:ICallerSecurityContext read ITGetICallerSecurityContext write ITSetICallerSecurityContext;
  end;

implementation
 uses SysUtils, UTrayConsts, USecurityUtils, UCallerConsts, UUniqueStrUtils{$IFNDEF VER130}, Variants{$ENDIF}, UErrorConsts;

{**  TCallerSecurityContext  **}
constructor TCallerSecurityContext.Create;
begin
  FUserName:='';
  FSecurityContext:=Unassigned;
  Inherited Create;
end;

constructor TCallerSecurityContext.Create(const aSecurityContext:Variant);
begin
  Inherited Create;
  ITSetSecurityContext(aSecurityContext);
end;

constructor TCallerSecurityContext.Create(const aAsString:AnsiString);
begin
  Inherited Create;
  ITSetAsString(aAsString);
end;

destructor TCallerSecurityContext.Destroy;
begin
  FUserName:='';
  VarClear(FSecurityContext);
  Inherited Destroy;
end;

function TCallerSecurityContext.ITGetUserName:AnsiString;
begin
  InternalLock;
  try
    Result:=FUserName;
  finally
    InternalUnlock;
  end;
end;

{function TCallerSecurityContext.ITGetPSecurityContext:PVariant;
begin
  InternalLock;
  try
    Result:=Addr(FSecurityContext);
  finally
    InternalUnlock;
  end;
end;}

{procedure TCallerSecurityContext.ITSetPSecurityContext(Value:PVariant);
begin
  InternalLock;
  try
    FSecurityContext:=Value^;
    Try
      If Not VarIsArray(FSecurityContext) Then FUserName:='<SecurityContext not Array>' else
        FUserName:=VarToStr(FSecurityContext[0]);
    except
      FUserName:='<Invalid SecurityContext>';
    end;
  finally
    InternalUnlock;
  end;
end;}

function TCallerSecurityContext.ITGetAsString:AnsiString;
begin
  InternalLock;
  try
    Result:=SecurityVarArrayToString(FSecurityContext);
  finally
    InternalUnlock;
  end;
end;

procedure TCallerSecurityContext.ITSetAsString(const Value:AnsiString);
begin
  InternalLock;
  try
    ITSetSecurityContext(SecurityStringToVarArray(Value));
  finally
    InternalUnlock;
  end;
end;

function TCallerSecurityContext.ITGetSecurityContext:Variant;
begin
  InternalLock;
  try
    Result:=FSecurityContext;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerSecurityContext.ITSetSecurityContext(const Value:Variant);
begin
  InternalLock;
  try
    FSecurityContext:=Value;
    If Not VarIsArray(FSecurityContext) Then FUserName:=csUnknownUserName else begin
      Try
        FUserName:=VarToStr(FSecurityContext[0]);
      except
        FUserName:=csInvalidUserName;
      end;
    end;
  finally
    InternalUnlock;
  end;
end;

function TCallerSecurityContext.Clone:ICallerSecurityContext;
begin
  InternalLock;
  try
    result:=TCallerSecurityContext.Create(SecurityContext);
  finally
    InternalUnlock;
  end;
end;

{**  TCallerSenderParams  **}
constructor TCallerSenderParams.Create;
begin
  Inherited Create;
  InternalClearSenderParams;
end;

constructor TCallerSenderParams.Create(const aSenderParams:Variant);
begin
  Inherited Create;
  ITSetSenderParams(aSenderParams);
end;

destructor TCallerSenderParams.Destroy;
begin
  Inherited Destroy;
  try
    VarClear(FSenderParams);
    VarClear(FSenderPackCPID);
    VarClear(FSenderPackPD);
    VarClear(FSenderRouteParam);
  except end;
end;

function TCallerSenderParams.ITGetSenderParams:Variant;
begin
  InternalLock;
  try
    Result:=FSenderParams;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerSenderParams.InternalClearSenderParams;
begin
  FSenderParams:=Unassigned;//Чищу если не арай
  FSenderASMNum:=-1;
  FSenderADMTaskNum:=tskADMNone;
  FSenderPackCPID:=-1;
  FSenderPackPD:=Unassigned;
  FSenderRouteParam:=Unassigned;
end;

procedure TCallerSenderParams.ITSetSenderParams(const Value:Variant);
begin
  InternalLock;
  try
    FSenderParams:=Value;
    If VarIsArray(FSenderParams) Then begin
      FSenderASMNum:=FSenderParams[0];
      FSenderADMTaskNum:=FSenderParams[3];
      FSenderPackCPID:=FSenderParams[1];
      FSenderPackPD:=FSenderParams[2];
      If VarArrayHighBound(FSenderParams, 1)>3{т.е. есть №4}then FSenderRouteParam:=FSenderParams[4] else FSenderRouteParam:=Unassigned;
    end else begin
      InternalClearSenderParams;
    end;
  finally
    InternalUnlock;
  end;
end;

function TCallerSenderParams.ITGetSenderASMNum:Integer;
begin
  InternalLock;
  try
    Result:=FSenderASMNum;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerSenderParams.ITSetSenderASMNum(Value:Integer);
begin
  InternalLock;
  try
    FSenderASMNum:=Value;
    If Value=-1{ничего} Then begin
      If VarIsArray(FSenderParams) then begin
        FSenderParams[0]:=Value{rstSTNoASM};
      end else begin
        FSenderParams:=Unassigned;
      end;
    end else begin
      If not VarIsArray(FSenderParams) then begin
        FSenderParams:=VarArrayCreate([0,3], varVariant);
        //FSenderParams[0]:=Value;
        FSenderParams[1]:=FSenderPackCPID;
        FSenderParams[2]:=FSenderPackPD;
        FSenderParams[3]:=FSenderADMTaskNum;
      end;
      FSenderParams[0]:=Value;
    end;
  finally
    InternalUnlock;
  end;
end;

function TCallerSenderParams.ITGetSenderADMTaskNum:TADMTask;
begin
  InternalLock;
  try
    Result:=FSenderADMTaskNum;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerSenderParams.ITSetSenderADMTaskNum(Value:TADMTask);
begin
  InternalLock;
  try
    FSenderADMTaskNum:=Value;
    If Value=tskADMNone{ничего} Then begin
      If VarIsArray(FSenderParams) then begin
        FSenderParams[3]:=Value{tskADMNone};
      end else begin
        FSenderParams:=Unassigned;
      end;
    end else begin
      If not VarIsArray(FSenderParams) then begin
        FSenderParams:=VarArrayCreate([0,3], varVariant);
        FSenderParams[0]:=FSenderASMNum;
        FSenderParams[1]:=FSenderPackCPID;
        FSenderParams[2]:=FSenderPackPD;
      end;
      FSenderParams[3]:=Value{not-tskADMNone};
    end;  
  finally
    InternalUnlock;
  end;
end;

function TCallerSenderParams.ITGetSenderPackCPID:Variant;
begin
  InternalLock;
  try
    Result:=FSenderPackCPID;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerSenderParams.ITSetSenderPackCPID(const Value:Variant);
begin
  InternalLock;
  try
    FSenderPackCPID:=Value;
    If Value=-1{ничего} Then begin
      If VarIsArray(FSenderParams) then begin
        FSenderParams[1]:=Value{tsiNoPackID};
      end else begin
        FSenderParams:=Unassigned;
      end;
    end else begin
      If not VarIsArray(FSenderParams) then begin
        FSenderParams:=VarArrayCreate([0,3], varVariant);
        FSenderParams[0]:=FSenderASMNum;
        FSenderParams[2]:=FSenderPackPD;
        FSenderParams[3]:=FSenderADMTaskNum;
      end;
      FSenderParams[1]:=Value{not-tsiNoPackID};
    end;
  finally
    InternalUnlock;
  end;
end;

function TCallerSenderParams.ITGetSenderPackPD:Variant;
begin
  InternalLock;
  try
    Result:=FSenderPackPD;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerSenderParams.ITSetSenderPackPD(const Value:Variant);
begin
  InternalLock;
  try
    FSenderPackPD:=Value;
    If VarIsEmpty(Value){ничего} Then begin
      If VarIsArray(FSenderParams) then begin
        FSenderParams[2]:=Value{Unassigned};
      end else begin
        FSenderParams:=Unassigned;
      end;
    end else begin
      If not VarIsArray(FSenderParams) then begin
        FSenderParams:=VarArrayCreate([0,3], varVariant);
        FSenderParams[0]:=FSenderASMNum;
        FSenderParams[1]:=FSenderPackCPID;
        FSenderParams[3]:=FSenderADMTaskNum;
      end;
      FSenderParams[2]:=Value{nassigned};
    end;
  finally
    InternalUnlock;
  end;
end;

function TCallerSenderParams.ITGetSenderRouteParam:Variant;
begin
  InternalLock;
  try
    Result:=FSenderRouteParam;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerSenderParams.ITSetSenderRouteParam(const Value:Variant);
begin
  InternalLock;
  try
    FSenderRouteParam:=Value;
    If VarIsEmpty(Value){ничего} Then begin
      If VarIsArray(FSenderParams) then begin
        If VarArrayHighBound(FSenderParams, 1)>3{т.е. есть №4}then VarArrayRedim(FSenderParams, 3);
      end else begin
        FSenderParams:=Unassigned;
      end;
    end else begin
      If VarIsArray(FSenderParams) then begin
        If VarArrayHighBound(FSenderParams, 1)<4 then VarArrayRedim(FSenderParams, 4);
      end else begin
        FSenderParams:=VarArrayCreate([0,4], varVariant);
        FSenderParams[0]:=FSenderASMNum;
        FSenderParams[1]:=FSenderPackCPID;
        FSenderParams[2]:=FSenderPackPD;
        FSenderParams[3]:=FSenderADMTaskNum;
      end;
      FSenderParams[4]:=Value{assigned};
    end;
  finally
    InternalUnlock;
  end;
end;

function TCallerSenderParams.Clone:ICallerSenderParams;
begin
  InternalLock;
  try
    result:=TCallerSenderParams.Create(SenderParams);
  finally
    InternalUnlock;
  end;
end;

{**  TCallerAction  **}
procedure TCallerAction.InternalCreateNewAction;
begin
  FActionName:=InternalCreateNewActionName('');
  FICallerSenderParams:=Nil;
end;

constructor TCallerAction.Create;
begin
  InternalCreateNewAction;
  FICallerSecurityContext:=TCallerSecurityContext.Create(Unassigned);
  Inherited Create;
end;

constructor TCallerAction.CreateNewAction(const aSecurityContext:Variant);
begin
  InternalCreateNewAction;
  FICallerSecurityContext:=TCallerSecurityContext.Create(aSecurityContext);
  Inherited Create;
end;

constructor TCallerAction.CreateNewAction(const aSecurityContext:Variant; const aSenderParams:Variant);
begin
  InternalCreateNewAction;
  FICallerSecurityContext:=TCallerSecurityContext.Create(aSecurityContext);
  FICallerSenderParams:=TCallerSenderParams.Create(aSenderParams);
  Inherited Create;
end;

constructor TCallerAction.CreateNewAction(aCallerSecurityContext:ICallerSecurityContext);
begin
  If Not Assigned(aCallerSecurityContext) Then Raise Exception.Create('CallerSecurityContext is not assigned.');
  InternalCreateNewAction;
  FICallerSecurityContext:=aCallerSecurityContext;
  Inherited Create;
end;

constructor TCallerAction.CreateNewAction(aCallerSecurityContext:ICallerSecurityContext; aCallerSenderParams:ICallerSenderParams);
begin
  If Not Assigned(aCallerSecurityContext) Then Raise Exception.Create('CallerSecurityContext is not assigned.');
  If Not Assigned(aCallerSenderParams) Then Raise Exception.Create('CallerSenderParams is not assigned.');
  InternalCreateNewAction;
  FICallerSecurityContext:=aCallerSecurityContext;
  FICallerSenderParams:=aCallerSenderParams;
  Inherited Create;
end;

procedure TCallerAction.InternalCreate;
begin
  FActionName:='';
  FICallerSenderParams:=Nil;
  FICallerSecurityContext:=Nil;
end;

constructor TCallerAction.Create(const aActionName:AnsiString);
begin
  InternalCreate;
  FActionName:=aActionName;
  Inherited Create;
end;

constructor TCallerAction.Create(const aSecurityContext:Variant; const aActionName:AnsiString);
begin
  InternalCreate;
  FActionName:=aActionName;
  FICallerSecurityContext:=TCallerSecurityContext.Create(aSecurityContext);
  Inherited Create;
end;

constructor TCallerAction.Create(const aSecurityContext:Variant; const aSenderParams:Variant; const aActionName:AnsiString);
begin
  InternalCreate;
  FActionName:=aActionName;
  FICallerSecurityContext:=TCallerSecurityContext.Create(aSecurityContext);
  FICallerSenderParams:=TCallerSenderParams.Create(aSenderParams);
  Inherited Create;
end;

constructor TCallerAction.Create(aCallerSecurityContext:ICallerSecurityContext; const aActionName:AnsiString);
begin
  If Not Assigned(aCallerSecurityContext) Then Raise Exception.Create('CallerSecurityContext is not assigned.');
  InternalCreate;
  FActionName:=aActionName;
  FICallerSecurityContext:=aCallerSecurityContext;
  Inherited Create;
end;

constructor TCallerAction.Create(aCallerSecurityContext:ICallerSecurityContext; aCallerSenderParams:ICallerSenderParams; const aActionName:AnsiString);
begin
  If Not Assigned(aCallerSecurityContext) Then Raise Exception.Create('CallerSecurityContext is not assigned.');
  InternalCreate;
  FActionName:=aActionName;
  FICallerSecurityContext:=aCallerSecurityContext;
  Inherited Create;
end;

destructor TCallerAction.Destroy;
begin
  FActionName:='';
  FICallerSecurityContext:=Nil;
  FICallerSenderParams:=Nil;
  Inherited Destroy;
end;


function  TCallerAction.ITGetActionName:AnsiString;
begin
  InternalLock;
  try
    Result:=FActionName;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerAction.ITSetActionName(const Value:AnsiString);
begin
  InternalLock;
  try
    FActionName:=Value;
  finally
    InternalUnlock;
  end;
end;

function  TCallerAction.ITGetICallerSecurityContext:ICallerSecurityContext;
begin
  InternalLock;
  try
    Result:=FICallerSecurityContext;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerAction.ITSetICallerSecurityContext(Value:ICallerSecurityContext);
begin
  InternalLock;
  try
    FICallerSecurityContext:=Value;
  finally
    InternalUnlock;
  end;
end;

function  TCallerAction.ITGetICallerSenderParams:ICallerSenderParams;
begin
  InternalLock;
  try
    Result:=FICallerSenderParams;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerAction.ITSetICallerSenderParams(Value:ICallerSenderParams);
begin
  InternalLock;
  try
    FICallerSenderParams:=Value;
  finally
    InternalUnlock;
  end;
end;

function  TCallerAction.ITGetSenderParams:Variant;
begin
  InternalLock;
  try
    If Assigned(FICallerSenderParams) then result:=FICallerSenderParams.SenderParams else result:=Unassigned;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerAction.ITSetSenderParams(const Value:Variant);
begin
  InternalLock;
  try
    If Assigned(FICallerSenderParams) then FICallerSenderParams.SenderParams:=Value else FICallerSenderParams:=TCallerSenderParams.Create(Value);
  finally
    InternalUnlock;
  end;
end;

function TCallerAction.ITGetUserName:AnsiString;
begin
  InternalLock;
  try
    If Assigned(FICallerSecurityContext) then result:=FICallerSecurityContext.UserName else result:='<Unassigned>';
  finally                           
    InternalUnlock;
  end;
end;

function  TCallerAction.ITGetSecurityContext:Variant;
begin
  InternalLock;
  try
    If Assigned(FICallerSecurityContext) then result:=FICallerSecurityContext.SecurityContext else result:=Unassigned;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerAction.ITSetSecurityContext(const Value:Variant);
begin
  InternalLock;
  try
    If Assigned(FICallerSecurityContext) then FICallerSecurityContext.SecurityContext:=Value else Raise Exception.Create('CallerSecurityContext is not assigned.');
  finally
    InternalUnlock;
  end;
end;

{TCallerAction.ICallerAction}
procedure TCallerAction.ITMessAdd(aStartTime, aEndTime:TDateTime; const aSource, aMess:AnsiString; aMessageClass:TMessageClass; aMessageStyle:TMessageStyle);
begin
  InternalLock;
  try
    InternalGetIAppMessage.ITMessAdd(aStartTime, aEndTime, UserName, aSource, aMess, aMessageClass, aMessageStyle);
  finally
    InternalUnlock;
  end;
end;

function TCallerAction.InternalCreateNewActionName(aPrefix:AnsiString):AnsiString;
begin
  Result:=aPrefix+UniqueStringNormal;
(*  If Assigned(GL_DataCase) Then begin
    Result:=aPrefix+GL_DataCase.ITGetUniqueString;//(False);
  end else begin
    Result:=aPrefix+'DataCase is not assigned.';
  end;*)
end;

procedure TCallerAction.CreateNewActionName(aPrefix:AnsiString);
begin
  InternalLock;
  try
    FActionName:=InternalCreateNewActionName(aPrefix);
  finally
    InternalUnlock;
  end;
end;

function TCallerAction.Clone:ICallerAction;
begin
  InternalLock;
  try
    Result:=TCallerAction.Create({nil, nil, }FActionName);
    if assigned(FICallerSenderParams) then Result.CallerSenderParams:=FICallerSenderParams.Clone;
    if assigned(FICallerSecurityContext) then Result.CallerSecurityContext:=FICallerSecurityContext.Clone;
  finally
    InternalUnlock;
  end;
end;

function TCallerAction.InternalGetITray:ITray;
begin
  result:=cnTray;
  if not assigned(result) then raise exception.createFmtHelp(cserInternalError, ['cnTray not assigned'], cnerInternalError);
end;

function TCallerAction.InternalGetIAppMessage:IAppMessage;
begin
  if not assigned(FAppMessage) then InternalGetITray.Query(IAppMessage, FAppMessage);
  result:=FAppMessage;
end;

end.
