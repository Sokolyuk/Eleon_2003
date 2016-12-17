unit USyncUtils;

interface
  uses USyncTypes;

  Function BoolToLockOptions(aMessAdd:Boolean):TLockOptions;
  
implementation
  uses UTrayConsts, Sysutils;

Function BoolToLockOptions(aMessAdd:Boolean):TLockOptions;
begin
  If aMessAdd Then result:=[lopMessAdd] else result:=[];
end;

end.
