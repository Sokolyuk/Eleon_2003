//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UPackPDPlaces;

interface
  Uses UIObject, UPackPDPlacesTypes, UPackTypes, UVarsetTypes, UPackPDPlaceTypes;
Type
  TPackPDPlaces=class(TIObject, IPackPDPlaces)
  protected
    FCurrNum:Integer;
    FPlacesI:IVarset;
  protected
    function Get_CurrNum:Integer;virtual;
    procedure Set_CurrNum(Value:Integer);virtual;
    function Get_Places:Variant;virtual;
    function Get_PlacesData:Variant;virtual;
    function Get_LowBound:Integer;virtual;
    function Get_HighBound:Integer;virtual;
    function Get_Arrived:boolean;virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;virtual;
    procedure SetPlaces(aCurrNum:Integer; Const aPlaces:Variant; Const aPlacesData:Variant);virtual;
    procedure GetPlaces(Out aCurrNum:Integer; Out aPlaces:Variant; Out aPlacesData:Variant);virtual;
    procedure AddPlace(aPlace:TPlace; Const aPlaceData:Variant);virtual;
    function ViewNextPackPDPlaceOfIntIndex(Var aIntIndex:Integer):IPackPDPlace;virtual;
    function ViewPrevPackPDPlaceOfIntIndex(Var aIntIndex:Integer):IPackPDPlace;virtual;
    procedure ReverceRoute;virtual;
    function Clone:IPackPDPlaces;virtual;
    property CurrNum:Integer read Get_CurrNum write Set_CurrNum;
    property AsVariantPlaces:Variant read Get_Places;
    property AsVariantPlacesData:Variant read Get_PlacesData;
    property Arrived:Boolean read Get_Arrived;
    property LowBound:Integer read Get_LowBound;
    property HighBound:Integer read Get_HighBound;
    property PlacesI:Variant read Get_Places;
  end;

implementation
  Uses SysUtils, UVarset, UPackPDPlace, UErrorConsts{$IFDEF VER130}, Windows{$ENDIF}{$IFNDEF VER130}, Variants{$ENDIF};

constructor TPackPDPlaces.Create;
begin
  FPlacesI:=TVarset.Create;
  FPlacesI.ITConfigIntIndexAssignable:=False;
  FPlacesI.ITConfigCheckUniqueIntIndex:=False;
  FPlacesI.ITConfigCheckUniqueStrIndex:=False;
  FPlacesI.ITConfigNoFoundException:=True;
  Inherited Create;
  Clear;
end;

destructor TPackPDPlaces.Destroy;
begin
  Clear;
  FPlacesI:=nil;
  Inherited Destroy;
end;

procedure TPackPDPlaces.Clear;
begin
  FCurrNum:=0;
  FPlacesI.ITClear;//FPlaces:=Unassigned;//FPlacesData:=Unassigned;//FLowBound:=0;//FHighBound:=-1;//FArrived:=False;
end;

procedure TPackPDPlaces.SetPlaces(aCurrNum:Integer; Const aPlaces:Variant; Const aPlacesData:Variant);
  Var tmpI, tmpivLB, tmpivHB:Integer;
begin
  Try//провер€ю соответствие типам массивов
    If (VarType(aPlaces)<>(varArray Or varInteger)) Then raise Exception.create('Ќеправильный формат команды(PD_Place is not VarArray & VarInteger).');
    If (VarType(aPlacesData)and varArray)<>varArray Then raise Exception.create('Ќеправильный формат параметров (PD_PlaceData is not VarArray).');
    //получаю диапозон
    tmpivLB:=VarArrayLowBound (aPlaces, 1);
    tmpivHB:=VarArrayHighBound(aPlaces, 1);
    //провер€ю соответствие диапозона списка команд дл€ всех массивов
    If (tmpivLB<>VarArrayLowBound(aPlacesData, 1)) Or
       (tmpivHB<>VarArrayHighBound(aPlacesData, 1)) Then raise Exception.create('Ќеправильна€ размерность PD_Place & PD_PlaceData.');
    //провер€ю корректность CurrNum
    If aCurrNum<tmpivLB Then Raise Exception.Create('Ќеправильное значение (CurrNum<tmpivLB).');
    //If tmpivHB=(aCurrNum-1) Then FArrived:=True else begin
    If tmpivHB<(aCurrNum-1) Then Raise Exception.Create('Invalid value(HighBound('+IntToStr(tmpivHB)+')<(CurrNum('+IntToStr(FCurrNum)+')-1)). Pack missed the target.'){ else Result:=False};
    //end;
    //..
    for tmpI:=tmpivLB to tmpivHB do begin
      FPlacesI.ITPushV((IUnknown(TPackPDPlace.Create(aPlaces[tmpI], aPlacesData[tmpI]))));
    end;
    FCurrNum:=aCurrNum;
  Except
    Clear;
    Raise;
  End;
end;

function TPackPDPlaces.ViewNextPackPDPlaceOfIntIndex(Var aIntIndex:Integer):IPackPDPlace;
  var tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
begin
  tmpIVarsetDataView:=FPlacesI.ITViewNextGetOfIntIndex(aIntIndex);
  If aIntIndex=-1 then begin
    result:=nil;
    exit;
  end;
  tmpIUnknown:=tmpIVarsetDataView.ITData;
  if (not Assigned(tmpIUnknown))or(tmpIUnknown.QueryInterface(IPackPDPlace, Result)<>S_OK)or(not Assigned(Result)) then raise exception.create('Interface IPackPDPlace no found.');
end;

function TPackPDPlaces.ViewPrevPackPDPlaceOfIntIndex(Var aIntIndex:Integer):IPackPDPlace;
  var tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
begin
  tmpIVarsetDataView:=FPlacesI.ITViewPrevGetOfIntIndex(aIntIndex);
  If aIntIndex=-1 then begin
    result:=nil;
    exit;
  end;
  tmpIUnknown:=tmpIVarsetDataView.ITData;
  if (not Assigned(tmpIUnknown))or(tmpIUnknown.QueryInterface(IPackPDPlace, Result)<>S_OK)or(not Assigned(Result)) then raise exception.create('Interface IPackPDPlace no found.');
end;

function TPackPDPlaces.Get_CurrNum:Integer;
begin
  Result:=FCurrNum;
end;

procedure TPackPDPlaces.Set_CurrNum(Value:Integer);
begin
  FCurrNum:=Value;
end;

function TPackPDPlaces.Get_Places:Variant;
  Var tmpIntIndex:Integer;
      tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
      tmpIPackPDPlace:IPackPDPlace;
      tmpI:Integer;
begin
  try
    if FPlacesI.ITCount=0 then begin
      Result:=unassigned;
    end else begin
      Result:=VarArrayCreate([LowBound, HighBound], varInteger);
      tmpI:=LowBound;
      tmpIntIndex:=-1;
      while true do begin
        tmpIVarsetDataView:=FPlacesI.ITViewNextGetOfIntIndex(tmpIntIndex);
        If tmpIntIndex=-1 then break;
        tmpIUnknown:=tmpIVarsetDataView.ITData;
        If (Not Assigned(tmpIUnknown))Or(tmpIUnknown.QueryInterface(IPackPDPlace, tmpIPackPDPlace)<>S_OK)Or(Not Assigned(tmpIPackPDPlace)) Then Raise Exception.CreateFmt(cserInternalError, ['Interface ''IPackPDPlace'' not found.']);
        Result[tmpI]:=Integer(tmpIPackPDPlace.Place);
        Inc(tmpI);
      end;
      tmpIVarsetDataView:=nil;
    end;
  except on e:exception do begin
    e.message:='Get_Places: '+e.message;
    Raise;
  end;end;
end;

function TPackPDPlaces.Get_PlacesData:Variant;
  Var tmpIntIndex:Integer;
      tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
      tmpIPackPDPlace:IPackPDPlace;
      tmpI:Integer;
begin
  try
    if FPlacesI.ITCount=0 then begin
      Result:=unassigned;
    end else begin
      Result:=VarArrayCreate([LowBound, HighBound], varVariant);
      tmpI:=LowBound;
      tmpIntIndex:=-1;
      while true do begin
        tmpIVarsetDataView:=FPlacesI.ITViewNextGetOfIntIndex(tmpIntIndex);
        If tmpIntIndex=-1 then break;
        tmpIUnknown:=tmpIVarsetDataView.ITData;
        If (Not Assigned(tmpIUnknown))Or(tmpIUnknown.QueryInterface(IPackPDPlace, tmpIPackPDPlace)<>S_OK)Or(Not Assigned(tmpIPackPDPlace)) Then Raise Exception.CreateFmt(cserInternalError, ['Interface ''IPackPDPlace'' not found.']);
        Result[tmpI]:=tmpIPackPDPlace.PlaceData;
        Inc(tmpI);
      end;
      tmpIVarsetDataView:=nil;
    end;
  except on e:exception do begin
    e.message:='Get_PlacesData: '+e.message;
    Raise;
  end;end;
end;

procedure TPackPDPlaces.GetPlaces(Out aCurrNum:Integer; Out aPlaces:Variant; Out aPlacesData:Variant);
  Var tmpIntIndex:Integer;
      tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
      tmpIPackPDPlace:IPackPDPlace;
      tmpI:Integer;
begin
  try
    aCurrNum:=FCurrNum;
    if FPlacesI.ITCount=0 then begin
      aPlaces:=unassigned;
      aPlacesData:=unassigned;
    end else begin
      aPlaces:=VarArrayCreate([LowBound, HighBound], varInteger);
      aPlacesData:=VarArrayCreate([LowBound, HighBound], varVariant);
      tmpI:=LowBound;
      tmpIntIndex:=-1;
      while true do begin
        tmpIVarsetDataView:=FPlacesI.ITViewNextGetOfIntIndex(tmpIntIndex);
        If tmpIntIndex=-1 then break;
        tmpIUnknown:=tmpIVarsetDataView.ITData;
        If (Not Assigned(tmpIUnknown))Or(tmpIUnknown.QueryInterface(IPackPDPlace, tmpIPackPDPlace)<>S_OK)Or(Not Assigned(tmpIPackPDPlace)) Then Raise Exception.CreateFmt(cserInternalError, ['Interface ''IPackPDPlace'' not found.']);
        aPlaces[tmpI]:=Integer(tmpIPackPDPlace.Place);
        aPlacesData[tmpI]:=tmpIPackPDPlace.PlaceData;
        Inc(tmpI);
      end;
      tmpIVarsetDataView:=nil;
    end;  
  except on e:exception do begin
    e.message:='GetPlaces: '+e.message;
    raise;
  end;end;
end;

function TPackPDPlaces.Get_LowBound:Integer;
begin
  Result:=0;
end;

function TPackPDPlaces.Get_HighBound:Integer;
begin
  Result:=FPlacesI.ITCount-1;
end;

function TPackPDPlaces.Get_Arrived:boolean;
begin
  If HighBound=(FCurrNum-1) Then begin
    Result:=True;
  end else begin
    If HighBound<(FCurrNum-1) Then Raise Exception.Create('Invalid value(HighBound('+IntToStr(HighBound)+')<(CurrNum('+IntToStr(FCurrNum)+')-1)). Pack missed the target.') else Result:=False;
  end;
end;

procedure TPackPDPlaces.AddPlace(aPlace:TPlace; Const aPlaceData:Variant);
begin
  FPlacesI.ITPushV(IUnknown(TPackPDPlace.Create(aPlace, aPlaceData)));
end;

procedure TPackPDPlaces.ReverceRoute;
  var tmpPlacesI:IVarset;
      tmpIntIndex:Integer;
      tmpIPackPDPlace:IPackPDPlace;
begin
  tmpPlacesI:=TVarset.Create;
  tmpPlacesI.ITConfigIntIndexAssignable:=False;
  tmpPlacesI.ITConfigCheckUniqueIntIndex:=False;
  tmpPlacesI.ITConfigCheckUniqueStrIndex:=False;
  tmpPlacesI.ITConfigNoFoundException:=True;
  tmpIntIndex:=-1;
  while true do begin
    tmpIPackPDPlace:=ViewPrevPackPDPlaceOfIntIndex(tmpIntIndex);
    if tmpIntIndex=-1 then break;
    case tmpIPackPDPlace.Place of
      pdsEventOnID:tmpPlacesI.ITPushV(IUnknown(TPackPDPlace.Create(pdsCommandOnID, tmpIPackPDPlace.PlaceData)));
      pdsEventOnUser:tmpPlacesI.ITPushV(IUnknown(TPackPDPlace.Create(pdsCommandOnUser, tmpIPackPDPlace.PlaceData)));
      pdsEventOnAll:tmpPlacesI.ITPushV(IUnknown(TPackPDPlace.Create(pdsCommandOnAll, tmpIPackPDPlace.PlaceData)));
      pdsEventOnBridge:tmpPlacesI.ITPushV(IUnknown(TPackPDPlace.Create(pdsCommandOnBridge, tmpIPackPDPlace.PlaceData)));
      pdsEventOnMask:tmpPlacesI.ITPushV(IUnknown(TPackPDPlace.Create(pdsCommandOnMask, tmpIPackPDPlace.PlaceData)));
      pdsEventOnNameMask:tmpPlacesI.ITPushV(IUnknown(TPackPDPlace.Create(pdsCommandOnNameMask, tmpIPackPDPlace.PlaceData)));
      pdsCommandOnID:tmpPlacesI.ITPushV(IUnknown(TPackPDPlace.Create(pdsEventOnID, tmpIPackPDPlace.PlaceData)));
      pdsCommandOnUser:tmpPlacesI.ITPushV(IUnknown(TPackPDPlace.Create(pdsEventOnUser, tmpIPackPDPlace.PlaceData)));
      pdsCommandOnAll:tmpPlacesI.ITPushV(IUnknown(TPackPDPlace.Create(pdsEventOnAll, tmpIPackPDPlace.PlaceData)));
      pdsCommandOnBridge:tmpPlacesI.ITPushV(IUnknown(TPackPDPlace.Create(pdsEventOnBridge, tmpIPackPDPlace.PlaceData)));
      pdsCommandOnMask:tmpPlacesI.ITPushV(IUnknown(TPackPDPlace.Create(pdsEventOnMask, tmpIPackPDPlace.PlaceData)));
      pdsCommandOnNameMask:tmpPlacesI.ITPushV(IUnknown(TPackPDPlace.Create(pdsEventOnNameMask, tmpIPackPDPlace.PlaceData)));
    else
      raise exception.createFmtHelp(cserInternalError, ['Place='+IntToStr(Integer(tmpIPackPDPlace.Place))], cnerInternalError);
    end;
  end;
  FCurrNum:=HighBound-FCurrNum+LowBound+1;
  FPlacesI:=tmpPlacesI;
end;

function TPackPDPlaces.Clone:IPackPDPlaces;
  var tmpCurrNum:Integer;
      tmpPlaces:Variant;
      tmpPlacesData:Variant;
begin
  result:=TPackPDPlaces.create;
  result.CurrNum:=FCurrNum;
  GetPlaces(tmpCurrNum, tmpPlaces, tmpPlacesData);
  result.SetPlaces(tmpCurrNum, tmpPlaces, tmpPlacesData);
end;

end.
