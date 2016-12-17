unit UServerPropertiesEMS;

interface
  uses UServerProperties;
type  
  TServerPropertiesEMS=class(TServerProperties)
    procedure Init;override;
  end;

implementation

procedure TServerPropertiesEMS.Init;
begin
  FServerUserName:='Srv_EMS';
end;

end.
