//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTrayInterfaceBase;

interface
  uses UITObject, UTrayInterfaceTypes, UTrayTypes;
type
  TTrayInterfaceBase=class(TITObject, ITrayInterface)
  protected
    FStateAsTray:TStateAsTray;
    function InternalCheckStateAsTrayForWork(aRaise:boolean):boolean;virtual;
  protected
    procedure InternalInitBegin;virtual;
    procedure InternalInit;virtual;
    procedure InternalInitEnd;virtual;
    procedure InternalStartBegin;virtual;
    procedure InternalStart;virtual;
    procedure InternalStartEnd;virtual;
    procedure InternalStopBegin;virtual;
    procedure InternalStop;virtual;
    procedure InternalStopEnd;virtual;
    procedure InternalFinalBegin;virtual;
    procedure InternalFinal;virtual;
    procedure InternalFinalEnd;virtual;
    function Get_StateAsTray:TStateAsTray;virtual;
  public
    constructor create;
    destructor destroy;override;
    function GetTrayInterfaceName:AnsiString;virtual;
    procedure Init;virtual;
    procedure Start;virtual;
    procedure Stop;virtual;
    procedure Final;virtual;
    property StateAsTray:TStateAsTray read Get_StateAsTray;
  end;

implementation
  uses UTrayUtils, Sysutils, UErrorConsts;

constructor TTrayInterfaceBase.create;
begin
  inherited create;
  FStateAsTray:=tpsNone;
end;

destructor TTrayInterfaceBase.destroy;
begin
  try if FStateAsTray=tpsWork then Stop; except end;
  try if FStateAsTray=tpsInit then Final; except end;
  FStateAsTray:=tpsNone;
  inherited destroy;
end;

function TTrayInterfaceBase.InternalCheckStateAsTrayForWork(aRaise:boolean):boolean;
begin
  if FStateAsTray<>tpsWork then begin
    if aRaise then SetExceptStateAsTray(FStateAsTray);
    result:=false;
  end else result:=true;
end;

function TTrayInterfaceBase.GetTrayInterfaceName:AnsiString;
begin
  result:=ClassName;
end;

procedure TTrayInterfaceBase.InternalInitBegin;begin end;
procedure TTrayInterfaceBase.InternalInit;begin end;
procedure TTrayInterfaceBase.InternalInitEnd;begin end;

procedure TTrayInterfaceBase.Init;
begin
  InternalLock;
  try
    if FStateAsTray<>tpsNone then Raise Exception.CreateFmtHelp(cserInternalError, ['StateAsTray is not None'], cnerInternalError);
    FStateAsTray:=tpsPendingInit;
    try
      InternalInitBegin;
      InternalInit;
      InternalInitEnd;
    except
      FStateAsTray:=tpsNone;
      raise;
    end;
    FStateAsTray:=tpsInit;
  finally
    InternalUnlock;
  end;
end;

procedure TTrayInterfaceBase.InternalStartBegin;begin end;
procedure TTrayInterfaceBase.InternalStart;begin end;
procedure TTrayInterfaceBase.InternalStartEnd;begin end;

procedure TTrayInterfaceBase.Start;
begin
  InternalLock;
  try
    if FStateAsTray<>tpsInit then Raise Exception.CreateFmtHelp(cserInternalError, ['StateAsTray is not Init'], cnerInternalError);
    FStateAsTray:=tpsPendingStart;
    try
      InternalStartBegin;
      InternalStart;
      InternalStartEnd;
    except
      FStateAsTray:=tpsInit;
      raise;
    end;
    FStateAsTray:=tpsWork;
  finally
    InternalUnlock;
  end;
end;

procedure TTrayInterfaceBase.InternalStopBegin;begin end;
procedure TTrayInterfaceBase.InternalStop;begin end;
procedure TTrayInterfaceBase.InternalStopEnd;begin end;

procedure TTrayInterfaceBase.Stop;
begin
  InternalLock;
  try
    if FStateAsTray<>tpsWork then Raise Exception.CreateFmtHelp(cserInternalError, ['StateAsTray is not Work'], cnerInternalError);
    FStateAsTray:=tpsPendingStop;
    try
      InternalStopBegin;
      InternalStop;
      InternalStopEnd;
    except
      FStateAsTray:=tpsWork;
      raise;
    end;
    FStateAsTray:=tpsInit;
  finally
    InternalUnlock;
  end;
end;

procedure TTrayInterfaceBase.InternalFinalBegin;begin end;
procedure TTrayInterfaceBase.InternalFinal;begin end;
procedure TTrayInterfaceBase.InternalFinalEnd;begin end;

procedure TTrayInterfaceBase.Final;
begin
  InternalLock;
  try
    if FStateAsTray<>tpsInit then Raise Exception.CreateFmtHelp(cserInternalError, ['StateAsTray is not Init'], cnerInternalError);
    FStateAsTray:=tpsPendingFinal;
    try
      InternalFinalBegin;
      InternalFinal;
      InternalFinalEnd;
    except
      FStateAsTray:=tpsInit;
      raise;
    end;
    FStateAsTray:=tpsNone;
  finally
    InternalUnlock;
  end;
end;

function TTrayInterfaceBase.Get_StateAsTray:TStateAsTray;
begin
  InternalLock;
  try
    result:=FStateAsTray;
  finally
    InternalUnlock;
  end;
end;

end.
