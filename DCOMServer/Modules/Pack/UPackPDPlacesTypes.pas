//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UPackPDPlacesTypes;

interface
  Uses UPackTypes, UPackPDPlaceTypes;
Type
  IPackPDPlaces=Interface
  ['{D885B2B9-5005-43F3-AB56-9F504F6B7337}']
    function Get_CurrNum:Integer;
    procedure Set_CurrNum(Value:Integer);
    function Get_Places:Variant;
    function Get_PlacesData:Variant;
    function Get_LowBound:Integer;
    function Get_HighBound:Integer;
    function Get_Arrived:boolean;
    //..
    procedure Clear;
    procedure SetPlaces(aCurrNum:Integer; Const aPlace:Variant; Const aPlaceData:Variant);
    procedure GetPlaces(Out aCurrNum:Integer; Out aPlaces:Variant; Out aPlacesData:Variant);
    procedure AddPlace(aPlace:TPlace; Const aPlaceData:Variant);
    procedure ReverceRoute;
    function Clone:IPackPDPlaces;
    property CurrNum:Integer read Get_CurrNum write Set_CurrNum;
    property AsVariantPlaces:Variant read Get_Places;
    property AsVariantPlacesData:Variant read Get_PlacesData;
    property Arrived:Boolean read Get_Arrived;
    property LowBound:Integer read Get_LowBound;
    property HighBound:Integer read Get_HighBound;
    function ViewNextPackPDPlaceOfIntIndex(Var aIntIndex:Integer):IPackPDPlace;
    function ViewPrevPackPDPlaceOfIntIndex(Var aIntIndex:Integer):IPackPDPlace;
  end;

implementation

end.
