unit UASLLibSubFunction;

interface

type
  TASLLibSubFunction = class
  protected
    FSubFunctionParamsPos: integer;
    FSubFunctionParamsPosTo: integer;
    FSubFunctionPos: integer;
    FSubFunctionPosTo: integer;
  public
    constructor create();
    destructor destroy;override;
  public
    property SubFunctionParamsPos: integer read FSubFunctionParamsPos write FSubFunctionParamsPos;
    property SubFunctionParamsPosTo: integer read FSubFunctionParamsPosTo write FSubFunctionParamsPosTo;
    property SubFunctionPos: integer read FSubFunctionPos write FSubFunctionPos;
    property SubFunctionPosTo: integer read FSubFunctionPosTo write FSubFunctionPosTo;
  end;


implementation

constructor TASLLibSubFunction.create();
begin
  FSubFunctionPos := 0;
  FSubFunctionPosTo := -1;
  FSubFunctionParamsPos := 0;
  FSubFunctionParamsPosTo := -1;

  inherited create();
end;

destructor TASLLibSubFunction.destroy;
begin
  inherited destroy;
end;


end.
