//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UcoServerProc2Base;

interface
  uses ComObj, UServerProcConfigureTypes, UCallerTypes, UTrayTypes, UAppMessageTypes;

type
  TcoServerProc2Base=class(TAutoObject, IServerProcConfigure)
  protected
    function GetVersion:Integer;virtual;
    procedure SetCallerAction(const aCallerAction:ICallerAction);virtual;
    procedure SetTray(const aTray:ITray);virtual;
    procedure SetLoadParams(const aLoadParams:Variant);virtual;
  protected
    FLoadParams:variant;
    FTray:ITray;
    FCallerAction:ICallerAction;
    FAppMessage:IAppMessage;
    FStartTime:TDateTime;
    function InternalGetITray:ITray;virtual;
    function InternalGetIAppMessage:IAppMessage;virtual;
    procedure InternalMessAdd(aStartTime:TDateTime; const aMess:AnsiString; aMessageClass:TMessageClass; aMessageStyle:TMessageStyle);virtual;
    procedure InternalClear;virtual;
  public
    procedure initialize;override;
    destructor destroy;override;
    property LoadParams:variant read FLoadParams;
    property Tray:ITray read FTray;
    property CallerAction:ICallerAction read FCallerAction; 
    property AppMessage:IAppMessage read FAppMessage;
    property StartTime:TDateTime read FStartTime;
  end;

implementation
  uses variants, Sysutils;

procedure TcoServerProc2Base.InternalClear;
begin
  FLoadParams:=Unassigned;
  FTray:=nil;
  FCallerAction:=nil;
  FAppMessage:=nil;
end;

procedure TcoServerProc2Base.initialize;
begin
  FStartTime:=now;
  inherited initialize;
  InternalClear;
end;

destructor TcoServerProc2Base.destroy;
begin
  InternalMessAdd(FStartTime, 'destroy '''+ClassName+''' for 0x'+IntToHex(cardinal(pointer(self)), 4), mecApp, mesInformation);
  InternalClear;
  inherited destroy;
end;

function TcoServerProc2Base.InternalGetITray:ITray;
begin
  result:=FTray;
  if not assigned(result) then raise exception.create(''''+ClassName+'''.FTray not assigned.');
end;

function TcoServerProc2Base.InternalGetIAppMessage:IAppMessage;
begin
  if not assigned(FAppMessage) then InternalGetITray.Query(IAppMessage, FAppMessage);
  result:=FAppMessage;
end;

procedure TcoServerProc2Base.InternalMessAdd(aStartTime:TDateTime; const aMess:AnsiString; aMessageClass:TMessageClass; aMessageStyle:TMessageStyle);
begin
  try
    if assigned(FCallerAction) then FCallerAction.ITMessAdd(aStartTime, now, ClassName, aMess, aMessageClass, aMessageStyle) else
        InternalGetIAppMessage.ITMessAdd(aStartTime, Now, '', ClassName, aMess, aMessageClass, aMessageStyle);
  except end;
end;

function TcoServerProc2Base.GetVersion:Integer;
begin
  result:=2;
end;

procedure TcoServerProc2Base.SetCallerAction(const aCallerAction:ICallerAction);
begin
  FCallerAction:=aCallerAction;
end;

procedure TcoServerProc2Base.SetTray(const aTray:ITray);
begin
  FTray:=aTray;
end;

procedure TcoServerProc2Base.SetLoadParams(const aLoadParams:Variant);
begin
  VarCopyNoInd(FLoadParams, aLoadParams);
end;

end.
