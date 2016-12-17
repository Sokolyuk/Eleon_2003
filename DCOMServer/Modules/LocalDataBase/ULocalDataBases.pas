//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit ULocalDataBases;

interface
  uses UITObject, ULocalDataBasesTypes, ULocalDataBaseTypes;
type
  TLocalDataBases=class(TITObject, ILocalDataBases)
  protected
  public
    constructor create;
    destructor destroy;override;
  public
    function CreateInstance:ILocalDataBase;virtual;
  end;

implementation
  uses ULocalDataBase;

constructor TLocalDataBases.create;
begin
  inherited create;
end;

destructor TLocalDataBases.destroy;
begin
  inherited destroy;
end;

function TLocalDataBases.CreateInstance:ILocalDataBase;
begin
  result:=TLocalDataBase.create;
end;

end.
