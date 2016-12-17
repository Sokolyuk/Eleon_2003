unit UListInterface;

interface
  {Uses UListInterfaceTypes;
Type
  TListInterface=Class(TIObject, IListInterface)
  private

  protected

  public
    constructor Create;
    destructor Destroy; override;
  end;}

implementation

{constructor TListInterface.Create;
begin
  Inherited Create;
end;

destructor TListInterface.Destroy;
begin
  Inherited Destroy;
end;}

end.
