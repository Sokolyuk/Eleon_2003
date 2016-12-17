unit UUniqueStr;
смотри UUniqueStrUtils
interface
  uses UTrayInterface, UUniqueStrTypes, UTrayInterfaceTypes;
type
  TUniqueStr=class(TTrayInterface, IUniqueStr)
  public
    constructor create;
    destructor destroy;override;
    Function ITGetUniqueString(aStrongUnique:TUniqueLevel=unlStrong):AnsiString;virtual;
  end;

implementation
  uses UCalculus, UDateTimeUtils, SysUtils, Windows, UMachineNameConsts;

constructor TUniqueStr.create;
begin
 inherited create;
end;

destructor TUniqueStr.destroy;
begin
 inherited destroy;
end;

var cnLastUniqueString:ansistring='';

Function TUniqueStr.ITGetUniqueString(aStrongUnique:TUniqueLevel=unlStrong):AnsiString;
begin
  InternalLock;
  try
    Repeat
      Case aStrongUnique of
        unlStrong:Result:=cnMachineName+Int64ToSBase(DateTimeToMSecs(Now), cnEnBase)+'_'+Int64ToSBase(Random(916132831{zzzzz}), cnEnBase);
        unlNormal:Result:=cnMachineSName+Int64ToSBase(DateTimeToMSecs(Now), cnEnBase);//+'_'+Int64ToSBase(Random(3843{zz}), cnEnBase);
        unlLow:Result:=Int64ToSBase(DateTimeToMSecs(Now), cnEnBase);
      else
        Raise Exception.Create('Unknown StrongLevel.');
      end;
    Until cnLastUniqueString<>Result;
    cnLastUniqueString:=Result;
  finally
    InternalUnlock;
  end;  
end;

end.
