//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UPackPDError;

interface
  Uses UIObject, UPackPDErrorTypes;
Type
  TPackPDError=class(TIObject, IPackPDError)
  private
    FData:Variant;
  protected
    function Get_AsVariant:Variant;virtual;
    procedure Set_AsVariant(const Value:Variant);virtual;
  public
    constructor Create;
    destructor Destroy;override;
    procedure Clear;virtual;
    function Clone:IPackPDError;virtual;
    property AsVariant:Variant read Get_AsVariant write Set_AsVariant;
  end;


implementation
{$IFNDEF VER130}uses Variants;{$ENDIF}    

constructor TPackPDError.Create;
begin
  inherited Create;
  Clear;
end;

destructor TPackPDError.Destroy;
begin
  Clear;
  inherited destroy;
end;

procedure TPackPDError.Clear;
begin
  FData:=unassigned;
end;

function TPackPDError.Get_AsVariant:Variant;
begin
  Result:=FData;
end;

procedure TPackPDError.Set_AsVariant(const Value:Variant);
begin
  FData:=Value;
end;

function TPackPDError.Clone:IPackPDError;
begin
  result:=TPackPDError.Create;
  result.AsVariant:=AsVariant;
end;

end.
