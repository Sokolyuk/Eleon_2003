unit UPackPDPlace;

interface
  Uses UIObject, UPackPDPlaceTypes, UPackTypes;
Type
  TPackPDPlace=class(TIObject, IPackPDPlace)
  private
    FPlace:TPlace;
    FPlaceData:Variant;
  protected
    Function Get_Place:TPlace;
    Procedure Set_Place(Value:TPlace);
    Function Get_PlaceData:Variant;
    Procedure Set_PlaceData(Const Value:Variant);
  public
    constructor Create(aPlace:TPlace; const aPlaceData:Variant);
    destructor Destroy;override;
    //..
    Property Place:TPlace read Get_Place write Set_Place;
    Property PlaceData:Variant read Get_PlaceData write Set_PlaceData;
  end;

implementation
{$IFDEF VER140}uses Variants;{$ENDIF}

constructor TPackPDPlace.Create(aPlace:TPlace; const aPlaceData:Variant);
begin
  Inherited Create;
  FPlace:=aPlace;
  FPlaceData:=aPlaceData;
end;

destructor TPackPDPlace.Destroy;
begin
  VarClear(FPlaceData);
  Inherited Destroy;
end;

Function TPackPDPlace.Get_Place:TPlace;
begin
  Result:=FPlace;
end;

Procedure TPackPDPlace.Set_Place(Value:TPlace);
begin
  FPlace:=Value;
end;

Function TPackPDPlace.Get_PlaceData:Variant;
begin
  Result:=FPlaceData;
end;

Procedure TPackPDPlace.Set_PlaceData(Const Value:Variant);
begin
  FPlaceData:=Value;
end;


end.
