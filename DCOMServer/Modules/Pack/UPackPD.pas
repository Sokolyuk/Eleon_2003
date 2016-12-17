//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UPackPD;

interface
  Uses UPack, UPackPDTypes, UPackTypes, UPackPDPlacesTypes, UPackPDErrorTypes{$IFNDEF VER130}, Variants{$ENDIF}{$IFDEF VER130}, Windows{$ENDIF};

Type
  TPackPD=class(TPack, IPackPD)
  private
    FPDOptions:TPackPDOptions;
    FPlaces:IPackPDPlaces;
    FData:Variant;
    FPDID:Variant{varInteger Or varString Or varOleStr};
    FPDError:IPackPDError;
  protected
    function Get_PackID:TPackID;override;
    function ValidVersion(aVersion:Integer):Boolean;override;
    function Get_AsVariant:Variant;override;
    procedure Set_AsVariant(const Value:Variant);override;
    function Get_HighBound:Integer;override;
    function Get_PDOptions:TPackPDOptions;
    procedure Set_PDOptions(Value:TPackPDOptions);
    function Get_Places:IPackPDPlaces;
    procedure Set_Places(Value:IPackPDPlaces);
    function Get_DataAsVariant:Variant;
    procedure Set_DataAsVariant(const Value:Variant);
    function Get_DataAsIPack:IPack;
    procedure Set_DataAsIPack(Value:IPack);
    function Get_PDID:Variant;
    procedure Set_PDID(const Value:Variant);
    function Get_PDError:IPackPDError;
    procedure Set_PDError(Value:IPackPDError);
    function InternalCreateClone:IPack;override;
  public
    constructor Create;
    destructor Destroy;override;
    procedure Clear;override;
    function Clone:IPack;override;
    function ClonePackPD:IPackPD;virtual;
    property PDOptions:TPackPDOptions read Get_PDOptions write Set_PDOptions;
    property Places:IPackPDPlaces read Get_Places write Set_Places;
    property DataAsVariant:Variant read Get_DataAsVariant write Set_DataAsVariant;
    property DataAsIPack:IPack read Get_DataAsIPack write Set_DataAsIPack;
    property PDID:Variant{varInteger Or varString Or varOleStr} read Get_PDID write Set_PDID;
    property PDError:IPackPDError read Get_PDError write Set_PDError;
  end;

implementation
  uses UPackPDPlaces, UPackPDError, SysUtils, UPackConsts, UErrorConsts, UPackUtils;

constructor TPackPD.Create;
begin
  Inherited Create;
  FPlaces:=TPackPDPlaces.Create;
  FPDError:=TPackPDError.Create;
  Set_PackVer(1);
end;

destructor TPackPD.Destroy;
begin
  Clear;
  FPlaces:=nil;
  FPDError:=nil;
  Inherited Destroy;
end;

procedure TPackPD.Clear;
begin
  Inherited Clear;
  FPDOptions:=[];
  if assigned(FPlaces) then FPlaces.Clear;
  FData:=Unassigned;
  FPDID:=Integer(-1){Unassigned};
  if assigned(FPDError) then FPDError.Clear;
end;

procedure TPackPD.Set_AsVariant(const Value:Variant);
begin
  try
    Inherited Set_AsVariant(Value);
    Integer(FPDOptions):=Integer(Value[Protocols_PD_Options]);
    FPlaces.SetPlaces(Value[Protocols_PD_CurrNum], Value[Protocols_PD_Place], Value[Protocols_PD_PlaceData]);
    FData:=Value[Protocols_PD_Data];
    //беру ID протокола PD.
    PDID:=Value[Protocols_PD_PDID];
    FPDError.AsVariant:=Value[Protocols_PD_Error];
  except on e:exception do begin
    Clear;
    e.message:='Set_AsVariant: '+e.message;
    raise;
  end;end;
end;

function TPackPD.Get_AsVariant:Variant;
begin
  Result:=Inherited Get_AsVariant;
  Result[Protocols_PD_Options]:=Integer(FPDOptions);
  Result[Protocols_PD_CurrNum]:=FPlaces.CurrNum;
  Result[Protocols_PD_Place]:=FPlaces.AsVariantPlaces;
  Result[Protocols_PD_PlaceData]:=FPlaces.AsVariantPlacesData;
  Result[Protocols_PD_Data]:=DataAsVariant;
  Result[Protocols_PD_PDID]:=FPDID;
  Result[Protocols_PD_Error]:=FPDError.AsVariant;
end;

function TPackPD.Get_PDOptions:TPackPDOptions;
begin
  Result:=FPDOptions;
end;

procedure TPackPD.Set_PDOptions(Value:TPackPDOptions);
begin
  FPDOptions:=value;
end;

function TPackPD.Get_Places:IPackPDPlaces;
begin
  Result:=FPlaces;
end;

procedure TPackPD.Set_Places(Value:IPackPDPlaces);
begin
  FPlaces:=Value;
end;

function TPackPD.Get_DataAsVariant:Variant;
  var tmpIPack:IPack;
      tmpIUnknown:IUnknown;
begin
  if VarType(FData)=varUnknown then begin
    tmpIUnknown:=FData;
    if not assigned(tmpIUnknown) then raise exception.createFmtHelp(cserInternalError, ['tmpIUnknown not assigned'], cnerInternalError);
    if (tmpIUnknown.QueryInterface(IPack, tmpIPack)<>S_OK)Or(not assigned(tmpIPack)) then raise exception.createFmtHelp(cserInternalError, ['Interface IPack is not found(1)'], cnerInternalError);
    Result:=tmpIPack.AsVariant;
    tmpIUnknown:=nil;
    tmpIPack:=nil;
  end else begin
    Result:=FData;
  end;
end;

procedure TPackPD.Set_DataAsVariant(const Value:Variant);
begin
  FData:=Value;
end;

function TPackPD.Get_DataAsIPack:IPack;
  var tmpIUnknown:IUnknown;
      tmpIPack:IPack;
begin
  if VarIsEmpty(FData) then raise exception.createFmtHelp(cserInternalError, ['FData is empty'], cnerInternalError);
  result:=nil;
  if VarType(FData)<>varUnknown then begin
    tmpIPack:=VariantToPack(FData);
    tmpIPack.CallerAction:=FCallerAction;//наверное так логично
    FData:=tmpIPack;
    tmpIPack:=nil;
  end;
  if VarType(FData)=varUnknown then begin
    tmpIUnknown:=FData;
    if (tmpIUnknown.QueryInterface(IPack, Result)<>S_OK)or(not assigned(Result)) then raise exception.createFmtHelp(cserInternalError, ['Interface IPack not found'], cnerInternalError);
    tmpIUnknown:=nil;
  end else begin
    raise exception.createFmtHelp(cserInternalError, ['Unexpected type of FPackPDData'], cnerInternalError);
  end;
end;

procedure TPackPD.Set_DataAsIPack(Value:IPack);
begin
  FData:=Value;
end;

function TPackPD.Get_PDID:Variant;
begin
  Result:=FPDID;
end;

{$IFDEF VER130}
const
  varWord=$0012;
  varShortInt=$0010;
{$ENDIF}

procedure TPackPD.Set_PDID(const Value:Variant);
begin
  case VarType(Value) of
    varEmpty, varSmallint, varInteger, varString, varOleStr, varByte, varWord, varShortInt:;
  else
    raise exception.createFmtHelp(cserInternalError, ['PDID(Client/VarType='+IntToStr(Integer(VarType(Value)))+')'], cnerInternalError);
  end;
  FPDID:=Value;
end;

function TPackPD.Get_PDError:IPackPDError;
begin
  Result:=FPDError;
end;

procedure TPackPD.Set_PDError(Value:IPackPDError);
begin
  FPDError:=Value;
end;

function TPackPD.Get_HighBound:Integer;
begin
  Result:=Protocols_PD_Count-1;
end;

function TPackPD.Get_PackID:TPackID;
begin
  Result:=pciPD;
end;

function TPackPD.ValidVersion(aVersion:Integer):Boolean;
begin
  result:=aVersion=1;
end;

function TPackPD.InternalCreateClone:IPack;
begin
  result:=TPackPD.Create;
end;

function TPackPD.Clone:IPack;
  var tmpIPackPD:IPackPD;
begin
  result:=inherited Clone;
  if (not assigned(result))or(result.QueryInterface(IPackPD, tmpIPackPD)<>S_OK)or(not assigned(tmpIPackPD)) then raise exception.createFmtHelp(cserInternalError, ['IPackPD no found'], cnerInternalError);
  tmpIPackPD.PDOptions:=FPDOptions;
  tmpIPackPD.Places:=FPlaces.Clone;
  tmpIPackPD.PDID:=FPDID;
  tmpIPackPD.PDError:=FPDError.Clone;
  tmpIPackPD.DataAsIPack:=DataAsIPack.Clone;
end;

function TPackPD.ClonePackPD:IPackPD;
  var tmpIPack:IPack;
begin
  tmpIPack:=Clone;
  if (not assigned(tmpIPack))or(tmpIPack.QueryInterface(IPackPD, Result)<>S_OK)or(not assigned(result)) then raise exception.createFmtHelp(cserInternalError, ['IPackPD no found'], cnerInternalError);
end;

end.
