//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UPackPDPlaceTypes;

interface
  Uses UPackTypes;
Type
  IPackPDPlace=Interface
  ['{895CEB2C-803A-47BC-AB25-8271F4332B9B}']
    Function Get_Place:TPlace;
    Procedure Set_Place(Value:TPlace);
    Function Get_PlaceData:Variant;
    Procedure Set_PlaceData(Const Value:Variant);
    //..
    Property Place:TPlace read Get_Place write Set_Place;
    Property PlaceData:Variant read Get_PlaceData write Set_PlaceData;
  End;

implementation

end.
