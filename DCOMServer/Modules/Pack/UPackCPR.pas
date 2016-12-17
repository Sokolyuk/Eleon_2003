//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UPackCPR;

interface
  Uses UPack, UPackTypes, UPackCPRTypes, UPackCPTasksTypes, UPackCPErrorsTypes, UADMTypes;
Type
  TPackCPR=Class(TPack, IPack, IPackCPR)
  protected
    FCPROptions:TCPROptions;
    FCPID:Variant;
    FCPTasks:IPackCPTasks;
    FCPErrors:IPackCPErrors;
  protected
    function Get_PackID:TPackID;override;
    function Get_AsVariant:Variant;override;
    procedure Set_AsVariant(const Value:Variant);override;
    function Get_HighBound:Integer;override;
    function Get_CPROptions:TCPROptions;
    procedure Set_CPROptions(Value:TCPROptions);
    function Get_CPID:Variant;
    procedure Set_CPID(const Value:Variant);
    function Get_CPTasks:IPackCPTasks;
    procedure Set_CPTasks(Value:IPackCPTasks);
    function Get_CPErrors:IPackCPErrors;
    procedure Set_CPErrors(Value:IPackCPErrors);
    function ValidVersion(aVersion:Integer):Boolean;override;
    function InternalCreateClone:IPack;override;
  public
    constructor Create;
    destructor Destroy;override;
    procedure Clear;override;
    function Clone:IPack;override;
    function ClonePackCPR:IPackCPR;virtual;
    property CPROptions:TCPROptions read Get_CPROptions write Set_CPROptions;
    property CPID:Variant read Get_CPID write Set_CPID;
    property CPTasks:IPackCPTasks read Get_CPTasks write Set_CPTasks;
    property CPErrors:IPackCPErrors read Get_CPErrors write Set_CPErrors;
    procedure Add(aADMTask:TADMTask; const aParam:Variant; const aRouteParam:Variant; aBlockID:Integer{=-1});
    procedure AddWithError(aADMTask:TADMTask; const aParam:Variant; const aRouteParam:Variant; aBlockId:Integer; const aMessage:AnsiString; aHelpContext:Integer{=0});
  end;

implementation
  Uses SysUtils, UPackCPTasks, UPackConsts, UPackCPErrors, UPackPDTypes, UErrorConsts{$IFDEF VER130}, Windows{$ENDIF}{$IFNDEF VER130}, Variants{$ENDIF};
Constructor TPackCPR.Create;
begin
  FCPTasks:=TPackCPTasks.Create;
  FCPErrors:=TPackCPErrors.Create;
  inherited Create;
end;

destructor TPackCPR.Destroy;
begin
  Clear;
  FCPTasks:=Nil;
  FCPErrors:=Nil;
  inherited Destroy;
  Set_PackVer(1);
end;

procedure TPackCPR.Clear;
begin
  inherited Clear;
  if Assigned(FCPTasks) Then FCPTasks.Clear;
  if Assigned(FCPErrors) Then FCPErrors.Clear;
  FCPROptions:=[];
  FCPID:=Unassigned;
end;

function TPackCPR.ValidVersion(aVersion:Integer):Boolean;
begin
  result:=(aVersion=1)Or(aVersion=2);
end;

function TPackCPR.Get_AsVariant:Variant;
  Var tmpTskV, tmpParamsV, tmpRouteParamsV, tmpBlockIDV:Variant;
begin
  FCPTasks.GetData(tmpTskV, tmpParamsV, tmpRouteParamsV, tmpBlockIDV);
  if VarIsArray(tmpRouteParamsV) Then Set_PackVer(2) else Set_PackVer(1);
  Result:=inherited Get_AsVariant;
  Result[Protocols_CPR_Options{2}]:=Integer(FCPROptions);
  Result[Protocols_CPR_CPID{3}]:=FCPID;
  Result[Protocols_CPR_Tsk{4}]:=tmpTskV;
  Result[Protocols_CPR_Params{5}]:=tmpParamsV;
  Result[Protocols_CPR_BlockID{6}]:=tmpBlockIDV;
  Result[Protocols_CPR_Errors{7}]:=FCPErrors.AsVariant;
  if PackVer=2 then Result[Protocols_CPR_RouteParams{7}]:=tmpRouteParamsV;
  VarClear(tmpTskV);
  VarClear(tmpParamsV);
  VarClear(tmpRouteParamsV);
  VarClear(tmpBlockIDV);
end;

procedure TPackCPR.Set_AsVariant(const Value:Variant);
begin
  try
    inherited Set_AsVariant(Value);
    //проверяю тип пакета
    //Беру протокол
    CPROptions:=TCPROptions(Integer(Value[Protocols_CPR_Options]));
    //Беру Id пакета(CP).
    CPID:=Value[Protocols_CPR_CPID];
    if PackVer=1 then FCPTasks.SetData(Value[Protocols_CPR_Tsk], Value[Protocols_CPR_Params], Unassigned, Value[Protocols_CPR_BlockID])
              {2}else FCPTasks.SetData(Value[Protocols_CPR_Tsk], Value[Protocols_CPR_Params], Value[Protocols_CPR_RouteParams], Value[Protocols_CPR_BlockID]);
    FCPErrors.AsVariant:=Value[Protocols_CPR_Errors];
  except on e:exception do begin
    Clear;
    e.message:='Set_AsVariant: '+e.message;
    raise;
  end;End;
end;

function TPackCPR.Get_HighBound:Integer;
begin
  if PackVer=1 then Result:=Protocols_CPR_Count_Ver1-1 else {2}Result:=Protocols_CPR_Count_Ver2-1;
end;

function TPackCPR.Get_CPROptions:TCPROptions;
begin
  Result:=FCPROptions;
end;

procedure TPackCPR.Set_CPROptions(Value:TCPROptions);
begin
  FCPROptions:=Value;
end;

function TPackCPR.Get_CPID:Variant;
begin
  Result:=FCPID;
end;

{$IFDEF VER130}
const
  varWord=$0012;
  varShortInt=$0010;
{$ENDIF}

procedure TPackCPR.Set_CPID(const Value:Variant);
begin
  case VarType(Value) of
    varEmpty, varSmallint, varInteger, varString, varOleStr, varByte, varWord, varShortInt:;
  else
    raise exception.createFmtHelp(cserInternalError, ['CPID(Client/VarType='+IntToStr(Integer(VarType(Value)))+')'], cnerInternalError);
  end;
  FCPID:=Value;
end;

function TPackCPR.Get_CPTasks:IPackCPTasks;
begin
  Result:=FCPTasks;
end;

procedure TPackCPR.Set_CPTasks(Value:IPackCPTasks);
begin
  FCPTasks:=Value;
end;

function TPackCPR.Get_CPErrors:IPackCPErrors;
begin
  Result:=FCPErrors;
end;

procedure TPackCPR.Set_CPErrors(Value:IPackCPErrors);
begin
  FCPErrors:=Value;
end;

function TPackCPR.Get_PackID:TPackID;
begin
  Result:=pciCPR;
end;

procedure TPackCPR.Add(aADMTask:TADMTask; const aParam:Variant; const aRouteParam:Variant; aBlockID:Integer{=-1});
begin
  FCPTasks.TaskAdd(aADMTask, aParam, aRouteParam, aBlockId);
end;

procedure TPackCPR.AddWithError(aADMTask:TADMTask; const aParam:Variant; const aRouteParam:Variant; aBlockId:Integer; const aMessage:AnsiString; aHelpContext:Integer{=0});
  Var tmpStep:Integer;
begin
  tmpStep:=FCPTasks.TaskAdd(aADMTask, aParam, aRouteParam, aBlockId);
  FCPErrors.Add(tmpStep, aMessage, aHelpContext);
end;

function TPackCPR.InternalCreateClone:IPack;
begin
  result:=TPackCPR.create;
end;

function TPackCPR.Clone:IPack;
  var tmpIPackCPR:IPackCPR;
begin
  result:=inherited Clone;
  if (not assigned(result))or(result.QueryInterface(IPackCPR, tmpIPackCPR)<>S_OK)or(not assigned(tmpIPackCPR)) then raise exception.createFmtHelp(cserInternalError, ['IPackCPR no found'], cnerInternalError);
  tmpIPackCPR.CPROptions:=FCPROptions;
  tmpIPackCPR.CPID:=FCPID;
  tmpIPackCPR.CPTasks:=FCPTasks.Clone;
  tmpIPackCPR.CPErrors:=CPErrors.Clone;
end;

function TPackCPR.ClonePackCPR:IPackCPR;
  var tmpIPack:IPack;
begin
  tmpIPack:=Clone;
  if (not assigned(tmpIPack))or(tmpIPack.QueryInterface(IPackCPR, Result)<>S_OK)or(not assigned(result)) then raise exception.createFmtHelp(cserInternalError, ['IPackCPR no found'], cnerInternalError);
end;

end.
