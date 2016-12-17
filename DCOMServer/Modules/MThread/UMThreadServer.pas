unit UMThreadServer;

interface
  uses UServerPropertiesTypes, UMThread, UTrayTypes, UThreadsPoolTypes;
type
  TMThreadServer=class(TMThread)
  protected
    FServerProperties:IServerProperties;
    function InternalGetUserName(aTray:ITray):AnsiString;override;
  public
    constructor Create(aCreateSuspended:Boolean; aPerpetual:Boolean; aThreadsPool:IThreadsPool);
    destructor destroy;override;
  end;

implementation

constructor TMThreadServer.create(aCreateSuspended:Boolean; aPerpetual:Boolean; aThreadsPool:IThreadsPool);
begin
  FServerProperties:=nil;
  inherited create(aCreateSuspended, aPerpetual, aThreadsPool);
end;

destructor TMThreadServer.destroy;
begin
  inherited destroy;
  FServerProperties:=nil;
end;

function TMThreadServer.InternalGetUserName(aTray:ITray):AnsiString;
begin
  if not assigned(FServerProperties) then begin
    aTray.Query(IServerProperties, FServerProperties, false);
  end;
  if assigned(FServerProperties) then result:=FServerProperties.ServerUserName else result:='';
end;

end.
