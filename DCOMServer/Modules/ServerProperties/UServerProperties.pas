unit UServerProperties;

interface
  uses UTrayInterface, UServerPropertiesTypes, UTrayInterfaceTypes;
type
  TServerProperties=class(TTrayInterface, IServerProperties)
  protected
    FServerUserName:AnsiString;
    FShotDown:boolean;
    Procedure Set_ShotDown(Value:Boolean);virtual;
    Function Get_ShotDown:Boolean;virtual;
    Function Get_ServerUserName:Ansistring;virtual;
  public
    constructor create;
    destructor destroy;override;
    Property ServerUserName:AnsiString read Get_ServerUserName;
    Property ShotDown:Boolean read Get_ShotDown write Set_ShotDown;
  end;

implementation

constructor TServerProperties.create;
begin
  inherited create;
  FServerUserName:='';
  FShotDown:=false;
end;

destructor TServerProperties.destroy;
begin
  inherited destroy;
end;

Procedure TServerProperties.Set_ShotDown(Value:Boolean);
begin
  Internallock;
  try
    FShotDown:=Value;
  finally
    Internalunlock;
  end;
end;

Function TServerProperties.Get_ShotDown:Boolean;
begin
  Internallock;
  try
    result:=FShotDown;
  finally
    Internalunlock;
  end;
end;

Function TServerProperties.Get_ServerUserName:Ansistring;
begin
  Internallock;
  try
    result:=FServerUserName;
  finally
    Internalunlock;
  end;
end;

end.
