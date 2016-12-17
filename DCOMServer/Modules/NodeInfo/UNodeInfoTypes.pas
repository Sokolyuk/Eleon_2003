unit UNodeInfoTypes;

interface
type
  INodeInfo=interface
  ['{E89442AC-026C-442F-A951-D09700BC1CFA}']
    function Get_ID:Integer;
    procedure Set_ID(value:Integer);
    function Get_Name:AnsiString;
    procedure Set_Name(const value:AnsiString);
    function Get_SName:AnsiString;
    procedure Set_SName(const value:AnsiString);
    function Get_Address:AnsiString;
    procedure Set_Address(const value:AnsiString);
    function Get_Phone:AnsiString;
    procedure Set_Phone(const value:AnsiString);
    function Get_Commentary:AnsiString;
    procedure Set_Commentary(const value:AnsiString);
    function Get_ServerIDBor1a:Integer;
    procedure Set_ServerIDBor1a(value:Integer);
    function Get_CardLetter:AnsiString;
    procedure Set_CardLetter(const value:AnsiString);
    //..
    property ID:Integer read Get_ID write Set_ID;
    property Name:AnsiString read Get_Name write Set_Name;
    property SName:AnsiString read Get_SName write Set_SName;
    property Address:AnsiString read Get_Address write Set_Address;
    property Phone:AnsiString read Get_Phone write Set_Phone;
    property Commentary:AnsiString read Get_Commentary write Set_Commentary;
    property ServerIDBor1a:Integer read Get_ServerIDBor1a write Set_ServerIDBor1a;
    property CardLetter:AnsiString read Get_CardLetter write Set_CardLetter;
  end;

implementation
    //function Get_LDBVer:Integer;
    //procedure Set_LDBVer(value:Integer);
    //function Get_ADMGroupName:AnsiString;
    //Procedure Set_ADMGroupName(const value:AnsiString);
    //property LDBVer1:Integer read Get_LDBVer write Set_LDBVer;
    //Property ADMGroupName:AnsiString read Get_ADMGroupName write Set_ADMGroupName;
end.
