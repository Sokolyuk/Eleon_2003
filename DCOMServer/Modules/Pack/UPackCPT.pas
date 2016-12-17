//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UPackCPT;

interface
  Uses UPack, UPackTypes, UPackCPTTypes, UPackCPTasksTypes;
Type
  TPackCPT=Class(TPack, IPackCPT)
  protected
    FCPTOptions:TCPTOptions;
    FCPID:Variant;
    FCPTasks:IPackCPTasks;
  protected
    function Get_PackID:TPackID;override;
    function Get_AsVariant:Variant;override;
    procedure Set_AsVariant(const Value:Variant);override;
    function Get_HighBound:Integer;override;
    function Get_CPTOptions:TCPTOptions;
    procedure Set_CPTOptions(Value:TCPTOptions);
    function Get_CPID:Variant;
    procedure Set_CPID(const Value:Variant);
    function Get_CPTasks:IPackCPTasks;
    procedure Set_CPTasks(Value:IPackCPTasks);
    function ValidVersion(aVersion:Integer):Boolean;override;
    function InternalCreateClone:IPack;override;
  public
    constructor Create;
    destructor Destroy;override;
    procedure Clear;override;
    function Clone:IPack;override;
    function ClonePackCPT:IPackCPT;virtual;
    property CPTOptions:TCPTOptions read Get_CPTOptions write Set_CPTOptions;
    property CPID:Variant read Get_CPID write Set_CPID;
    property CPTTasks:IPackCPTasks read Get_CPTasks write Set_CPTasks;
  end;

implementation
  uses SysUtils, UPackCPTasks, UPackConsts, UPackPDTypes, UErrorConsts{$IFDEF VER130}, Windows{$ENDIF}{$IFNDEF VER130}, Variants{$ENDIF};

constructor TPackCPT.Create;
begin
  inherited Create;
  FCPTasks:=TPackCPTasks.Create;
  Set_PackVer(1);
end;

destructor TPackCPT.Destroy;
begin
  Clear;
  FCPTasks:=Nil;
  inherited Destroy;
end;

procedure TPackCPT.Clear;
begin
  inherited Clear;
  FCPTOptions:=[];
  FCPID:=Unassigned;
  if Assigned(FCPTasks) Then FCPTasks.Clear; 
end;

function TPackCPT.Get_AsVariant:Variant;
  Var tmpTskV, tmpParamsV, tmpRouteParamsV, tmpBlockIDV:Variant;
begin
  FCPTasks.GetData(tmpTskV, tmpParamsV, tmpRouteParamsV, tmpBlockIDV);
  if VarIsArray(tmpRouteParamsV) Then Set_PackVer(2) else Set_PackVer(1);
  Result:=inherited Get_AsVariant;
  Result[Protocols_CPT_Options{2}]:=Integer(FCPTOptions);
  Result[Protocols_CPT_CPID{3}]:=FCPID;
  Result[Protocols_CPT_Tsk{4}]:=tmpTskV;
  Result[Protocols_CPT_Params{5}]:=tmpParamsV;
  Result[Protocols_CPT_BlockID{6}]:=tmpBlockIDV;
  if PackVer=2 then Result[Protocols_CPT_RouteParams{7}]:=tmpRouteParamsV;
  VarClear(tmpTskV);
  VarClear(tmpParamsV);
  VarClear(tmpRouteParamsV);
  VarClear(tmpBlockIDV);
end;

procedure TPackCPT.Set_AsVariant(const Value:Variant);
begin
  try
    inherited Set_AsVariant(Value);
    //проверяю тип пакета
    //Беру протокол
    CPTOptions:=TCPTOptions(Integer(Value[Protocols_CPT_Options]));
    //Беру Id пакета(CP).
    CPID:=Value[Protocols_CPT_CPID];
    if PackVer=1 then FCPTasks.SetData(Value[Protocols_CPT_Tsk], Value[Protocols_CPT_Params], Unassigned, Value[Protocols_CPT_BlockID])
              {2}else FCPTasks.SetData(Value[Protocols_CPT_Tsk], Value[Protocols_CPT_Params], Value[Protocols_CPT_RouteParams], Value[Protocols_CPT_BlockID]);
  except on e:exception do begin
    Clear;
    e.message:='Set_AsVariant: '+e.message;
    raise;
  end;End;
end;

function TPackCPT.ValidVersion(aVersion:Integer):boolean;
begin
  Result:=(aVersion=1)Or(aVersion=2);
end;

function TPackCPT.Get_HighBound:Integer; 
begin
  if PackVer=1 then Result:=Protocols_CPT_Count_Ver1-1 else {2}Result:=Protocols_CPT_Count_Ver2-1;
end;

function TPackCPT.Get_CPTOptions:TCPTOptions;
begin
  Result:=FCPTOptions;
end;

procedure TPackCPT.Set_CPTOptions(Value:TCPTOptions);
begin
  FCPTOptions:=Value;
end;

function TPackCPT.Get_CPID:Variant;
begin
  Result:=FCPID;
end;

{$IFDEF VER130}
const
  varWord=$0012;
  varShortInt=$0010;
{$ENDIF}

procedure TPackCPT.Set_CPID(const Value:Variant);
begin
  case VarType(Value) of
    varEmpty, varSmallint, varInteger, varString, varOleStr, varByte, varWord, varShortInt:;
  else
    raise exception.createFmtHelp(cserInternalError, ['CPID(Client/VarType='+IntToStr(Integer(VarType(Value)))+')'], cnerInternalError);
  end;
  FCPID:=Value;
end;

function TPackCPT.Get_CPTasks:IPackCPTasks;
begin
  Result:=FCPTasks;
end;

procedure TPackCPT.Set_CPTasks(Value:IPackCPTasks);
begin
  FCPTasks:=Value;
end;

function TPackCPT.Get_PackID:TPackID;
begin
  Result:=pciCPT;
end;

function TPackCPT.InternalCreateClone:IPack;
begin
  result:=TPackCPT.create;
end;

function TPackCPT.Clone:IPack;
  var tmpIPackCPT:IPackCPT;
begin
  result:=inherited Clone;
  if (not assigned(result))or(result.QueryInterface(IPackCPT, tmpIPackCPT)<>S_OK)or(not assigned(tmpIPackCPT)) then raise exception.createFmtHelp(cserInternalError, ['IPackCPT no found'], cnerInternalError);
  tmpIPackCPT.CPTOptions:=FCPTOptions;
  tmpIPackCPT.CPID:=FCPID;
  tmpIPackCPT.CPTasks:=FCPTasks.Clone;
end;

function TPackCPT.ClonePackCPT:IPackCPT;
  var tmpIPack:IPack;
begin
  tmpIPack:=Clone;
  if (not assigned(tmpIPack))or(tmpIPack.QueryInterface(IPackCPT, Result)<>S_OK)or(not assigned(result)) then raise exception.createFmtHelp(cserInternalError, ['IPackCPT no found'], cnerInternalError);
end;

end.
