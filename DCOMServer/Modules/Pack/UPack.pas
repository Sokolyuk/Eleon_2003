//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UPack;

interface
  uses UPackTypes, UIObject, UCallerTypes;
type
  TPack=class(TIObject, IPack)
  protected
    FCallerAction:ICallerAction;
    FPackVer:Integer;
  protected
    function Get_PackID:TPackID;virtual;
    function Get_PackVer:Integer;virtual;
    function Get_AsVariant:Variant;virtual;
    procedure Set_AsVariant(const Value:Variant);virtual;
    function Get_LowBound:Integer;virtual;
    function Get_HighBound:Integer;virtual;
    function Get_CallerAction:ICallerAction;virtual;
    procedure Set_CallerAction(Value:ICallerAction);virtual;
    function ValidVersion(aVersion:Integer):Boolean;virtual;abstract;
    procedure Set_PackVer(Value:Integer);virtual;
    function InternalCreateClone:IPack;virtual;abstract;
  public
    constructor Create;
    destructor Destroy;override;
    procedure Clear;virtual;
    function Clone:IPack;virtual;
    property PackID:TPackID read Get_PackID;
    property PackVer:Integer read Get_PackVer;
    property AsVariant:Variant read Get_AsVariant write Set_AsVariant;
    property LowBound:Integer read Get_LowBound;
    property HighBound:Integer read Get_HighBound;
    property CallerAction:ICallerAction read Get_CallerAction write Set_CallerAction;
  end;


implementation
  uses SysUtils, UPackConsts, UErrorConsts{$IFNDEF VER130}, Variants{$ENDIF};
{$IFDEF VER130}
  type TVarType=Integer;
{$ENDIF}

constructor TPack.create;
begin
  inherited create;
  Clear;
end;

destructor TPack.destroy;
begin
  FCallerAction:=nil;
  inherited Destroy;
end;

procedure TPack.Clear;
begin
  FCallerAction:=nil;
  FPackVer:=-1;
end;

function TPack.Get_PackID:TPackID;
begin
  Result:=pciNone;
end;

function TPack.Get_PackVer:Integer;
begin
  Result:=FPackVer;
end;

procedure TPack.Set_PackVer(Value:Integer);
begin
  if not ValidVersion(Value) then raise exception.create('Unknown version('+IntToStr(FPackVer)+').');
  FPackVer:=Value;
end;

procedure TPack.Set_AsVariant(const Value:Variant);
  var tmpVarType:TVarType;
      tmpLowBound, tmpHighBound:Integer;
begin
  try
    if not VarIsArray(Value) then raise exception.create('AsVariant not array.');
    tmpLowBound:=VarArrayLowBound(Value, 1);
    tmpHighBound:=VarArrayHighBound(Value, 1);
    if (tmpLowBound<>{0}Protocols_ID)Or(tmpHighBound<Protocols_Ver) then raise exception.create('Invalid protocol bounds.');
    tmpVarType:=VarType(Value[Protocols_ID]);
    if tmpVarType<>varInteger then raise exception.create('VarType(V['+IntToStr(Protocols_ID)+'])='+IntToStr(Integer(tmpVarType))+' not varInteger.');
    if TPackID(Integer(Value[Protocols_ID]))<>PackID then raise exception.createFmt(cserInternalError, ['Unknown PackID=('+IntToStr(Integer(Value[Protocols_ID]))+').']);
    tmpVarType:=VarType(Value[Protocols_Ver]);
    if tmpVarType<>varInteger then raise exception.create('VarType(V['+IntToStr(Protocols_Ver)+'])='+IntToStr(Integer(tmpVarType))+' not varInteger.');
    FPackVer:=Value[Protocols_Ver];
    if not ValidVersion(FPackVer) then raise exception.create('Unknown version('+IntToStr(FPackVer)+').');
    if tmpHighBound<>HighBound then raise exception.create('HighBound('+IntToStr(tmpHighBound)+')<>'+IntToStr(HighBound)+'.');
  except
    Clear;
    raise;
  end;  
end;

function TPack.Get_AsVariant:Variant;
begin
  Result:=VarArrayCreate([LowBound, HighBound], varVariant);
  Result[Protocols_ID]:=Integer(PackID);
  Result[Protocols_Ver]:=Integer(PackVer);
end;

function TPack.Get_LowBound:Integer;
begin
  Result:=0;
end;

function TPack.Get_HighBound:Integer;
begin
  Result:=1;
end;

function TPack.Get_CallerAction:ICallerAction;
begin
  Result:=FCallerAction;
end;

procedure TPack.Set_CallerAction(Value:ICallerAction);
begin
  FCallerAction:=Value;
end;

function TPack.Clone:IPack;
begin
  result:=InternalCreateClone;
  if assigned(FCallerAction) then result.CallerAction:=FCallerAction.Clone else result.CallerAction:=nil;
end;

end.
