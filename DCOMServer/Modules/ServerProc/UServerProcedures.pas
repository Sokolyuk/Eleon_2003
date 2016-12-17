//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UServerProcedures;

interface
 uses UTrayInterface, UServerProceduresTypes, UVarsetTypes, UServerProcedureTypes, UTrayInterfaceTypes;

type
  TServerProcedures=class(TTrayInterface, IServerProcedures)
  protected
    FServerProcedures:IVarset;
    procedure InternalInit;override;
  public
    constructor Create;
    destructor Destroy;override;
    function ITRegNameToServerProcedureAss(const aRegName:AnsiString):TServerProcedureAss;virtual;
    procedure ITReload;virtual;abstract;
  end;

implementation
  uses UVarSet, SysUtils, UTypeUtils, UServerProcedure, Variants;
       
constructor TServerProcedures.Create;
begin
  FServerProcedures:=TVarset.Create;
  FServerProcedures.ITConfigIntIndexAssignable:=False;
  FServerProcedures.ITConfigCheckUniqueIntIndex:=False;
  FServerProcedures.ITConfigCheckUniqueStrIndex:=False;
  FServerProcedures.ITConfigNoFoundException:=True;
  FServerProcedures.ITConfigCaseSensitive:=False;
  inherited Create;
end;

destructor TServerProcedures.Destroy;
begin
  FServerProcedures:=nil;
  inherited Destroy;
end;

function TServerProcedures.ITRegNameToServerProcedureAss(const aRegName:AnsiString):TServerProcedureAss;
  Var tmpIntIndex:Integer;
      tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
begin
  tmpIntIndex:=-1;
  while True do begin
    tmpIVarsetDataView:=FServerProcedures.ITViewNextGetOfIntIndex(tmpIntIndex);
    if tmpIntIndex=-1 then break;
    tmpIUnknown:=tmpIVarsetDataView.ITData;
    if AnsiUpperCase(IServerProcedure(tmpIUnknown).ITRegName)=AnsiUpperCase(aRegName) then begin
      Result:=IServerProcedure(tmpIUnknown).ITGetAss;
      Break;
    end;
  end;
  tmpIUnknown:=nil;
  tmpIVarsetDataView:=nil;
  if tmpIntIndex=-1 then raise exception.create('RegName='''+aRegName+''' not found.');
end;

procedure TServerProcedures.InternalInit;
begin
  ITReload;
end;

end.
