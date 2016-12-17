unit UAppSecurityPGS;

{$Define TruncatedSecurity}

interface
  uses UAppSecurity, UTTaskTypes, UADMTypes;
type
  TAppSecurityPGS=class(TAppSecurity)
  public
    Procedure ITCheckSecurityLDB(Const aTables, aSecurityContext:Variant);override;
  end;

implementation

Procedure TAppSecurityPGS.ITCheckSecurityLDB(Const aTables, aSecurityContext:Variant);
begin
end;

end.
