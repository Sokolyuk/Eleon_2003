unit UServerPropertiesPGS;

interface
  uses UServerProperties;
type  
  TServerPropertiesPGS=class(TServerProperties)
    procedure Init;override;
  end;

implementation

procedure TServerPropertiesPGS.Init;
begin
  FServerUserName:='Srv_PGS';
end;

end.
