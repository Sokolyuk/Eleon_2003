unit UPackCPErrorsTypes;

interface
  Uses Windows;
Type
  IPackCPErrors=Interface
  ['{EFF57662-3D2C-49AB-BC8E-5E287758F8FC}']
    function Get_AsVariant:Variant;
    procedure Set_AsVariant(const Value:Variant);
    function Get_LowBound:Integer;
    function Get_HighBound:Integer;
    function Get_Count:Integer;
    //..
    procedure Clear;
    function CheckError(aStep:Integer; aPMessage:PAnsiString; aPHelpContext:PInteger; aWithRaise:Boolean=False):Boolean;
    procedure Add(aStep:Integer; const aMessage:AnsiString; aHelpContext:Integer=0);
    function Clone:IPackCPErrors;
    property AsVariant:Variant read Get_AsVariant write Set_AsVariant;
    property LowBound:Integer read Get_LowBound{ write Set_LowBound};
    property HighBound:Integer read Get_HighBound{ write Set_HighBound};
    property Count:Integer read Get_Count;
  end;

implementation

end.
