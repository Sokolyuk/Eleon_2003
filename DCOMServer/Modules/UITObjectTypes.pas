unit UITObjectTypes;

interface
type
  TCallBackBack=procedure(aUserData:pointer; aIntf:IUnknown);
  TCallBackBackOfObject=procedure(aUserData:pointer; aIntf:IUnknown) of object;
  IIntroCallBack=interface
  ['{3F0EFFF3-2194-4F8B-B0D4-B1C459AF4989}']
    procedure IntroCallBack(aUserData:pointer; aCallBackBack:TCallBackBack);
    procedure IntroCallBackOfObject(aUserData:pointer; aCallBackOfObject:TCallBackBackOfObject);
  end;

implementation

end.
