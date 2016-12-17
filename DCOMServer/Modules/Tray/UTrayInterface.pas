//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTrayInterface;

interface
  uses UTrayInterfaceTypes, UTrayInterfaceBase, UTrayTypes;
type
  TTrayInterface=class(TTrayInterfaceBase, ITrayInterfaceInitFor)
  private
    FGUIDList:PGUIDList;
    procedure InternalCreateGUIDList;
  protected
    property GUIDList:PGUIDList read FGUIDList;
    procedure InternalInitGUIDList;virtual;
    function InternalGetInitGUIDCount:Cardinal;virtual;
  protected
    function InternalGetITray:ITray;virtual;
  protected
    procedure InternalMustBeforeInitFor(var aGUIDList:PGUIDList);virtual;
    procedure InternalMustBeforeStartFor(var aGUIDList:PGUIDList);virtual;
    procedure InternalMustAfterStopFor(var aGUIDList:PGUIDList);virtual;
    procedure InternalMustAfterFinalFor(var aGUIDList:PGUIDList);virtual;
  public
    constructor create;
    destructor destroy;override;
    procedure MustBeforeInitFor(var aGUIDList:PGUIDList);virtual;
    procedure MustBeforeStartFor(var aGUIDList:PGUIDList);virtual;
    procedure MustAfterStopFor(var aGUIDList:PGUIDList);virtual;
    procedure MustAfterFinalFor(var aGUIDList:PGUIDList);virtual;
  end;

implementation
  uses UErrorConsts, UTrayConsts, Sysutils;
constructor TTrayInterface.create;
begin
  inherited create;
  InternalCreateGUIDList;
end;

destructor TTrayInterface.destroy;
begin
  if assigned(FGUIDList) then begin Freemem(FGUIDList);FGUIDList:=nil;end;
  inherited destroy;
end;

function TTrayInterface.InternalGetInitGUIDCount:Cardinal;
begin
  result:=0;
end;

procedure TTrayInterface.InternalCreateGUIDList;
  var tmpCount:Cardinal;
begin
  tmpCount:=InternalGetInitGUIDCount;
  Getmem(FGUIDList, Sizeof(Cardinal)+Sizeof(TGUID)*tmpCount);
  FGUIDList^.aCount:=tmpCount;
  InternalInitGUIDList;
end;

procedure TTrayInterface.InternalInitGUIDList;
begin
end;

procedure TTrayInterface.InternalMustBeforeInitFor(var aGUIDList:PGUIDList);
begin
  aGUIDList:=FGUIDList;
end;

procedure TTrayInterface.MustBeforeInitFor(var aGUIDList:PGUIDList);
begin
  InternalLock;
  try
    InternalMustBeforeInitFor(aGUIDList);
  finally
    InternalUnlock;
  end;
end;

procedure TTrayInterface.InternalMustBeforeStartFor(var aGUIDList:PGUIDList);
begin
  aGUIDList:=FGUIDList;
end;

procedure TTrayInterface.MustBeforeStartFor(var aGUIDList:PGUIDList);
begin
  InternalLock;
  try
    InternalMustBeforeStartFor(aGUIDList);
  finally
    InternalUnlock;
  end;
end;

procedure TTrayInterface.InternalMustAfterStopFor(var aGUIDList:PGUIDList);
begin
  aGUIDList:=FGUIDList;
end;

procedure TTrayInterface.MustAfterStopFor(var aGUIDList:PGUIDList);
begin
  InternalLock;
  try
    InternalMustAfterStopFor(aGUIDList);
  finally
    InternalUnlock;
  end;
end;

procedure TTrayInterface.InternalMustAfterFinalFor(var aGUIDList:PGUIDList);
begin
  aGUIDList:=FGUIDList;
end;

procedure TTrayInterface.MustAfterFinalFor(var aGUIDList:PGUIDList);
begin
  InternalLock;
  try
    InternalMustAfterFinalFor(aGUIDList);
  finally
    InternalUnlock;
  end;
end;

function TTrayInterface.InternalGetITray:ITray;
begin
  result:=cnTray;
  if not assigned(result) then raise exception.createFmtHelp(cserInternalError, ['cnTray not assigned'], cnerInternalError);
end;

end.
