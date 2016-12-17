unit UUniqueStrTypes;
смотри UUniqueStrUtils
interface
Type
  TUniqueLevel=(unlStrong, unlNormal, unlLow);
  IUniqueStr=interface
  ['{AFBB92D8-1205-4E88-8013-D36D3227AFC9}']
    Function ITGetUniqueString(aStrongUnique:TUniqueLevel=unlStrong):AnsiString;
  end;  
implementation

end.


