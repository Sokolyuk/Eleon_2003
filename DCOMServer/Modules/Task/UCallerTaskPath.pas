unit UCallerTaskPath;

interface
  uses UITObject, UCallerTaskPathTypes, UCallerTaskTypes;
type
  TCallerTaskPath=class(TITObject, ICallerTaskPath)
  private
    FFirst:ICallerTask;
    FPrev:ICallerTask;
  protected
    procedure Set_First(value:ICallerTask);virtual;
    function Get_First:ICallerTask;virtual;
    procedure Set_Prev(value:ICallerTask);virtual;
    function Get_Prev:ICallerTask;virtual;
  public
    constructor create;
    destructor destroy;override;
    property First:ICallerTask read Get_First write Set_First;
    property Prev:ICallerTask read Get_Prev write Set_Prev;
  end;

implementation

constructor TCallerTaskPath.create;
begin
  inherited create;
  FFirst:=nil;
  FPrev:=nil;
end;

destructor TCallerTaskPath.destroy;
begin
  FFirst:=nil;
  FPrev:=nil;
  inherited destroy;
end;

procedure TCallerTaskPath.Set_First(value:ICallerTask);
begin
  InternalLock;
  try
    FFirst:=value;
  finally
    InternalUnlock;
  end;
end;

function TCallerTaskPath.Get_First:ICallerTask;
begin
  InternalLock;
  try
    result:=FFirst;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerTaskPath.Set_Prev(value:ICallerTask);
begin
  InternalLock;
  try
    FPrev:=value;
  finally
    InternalUnlock;
  end;
end;

function TCallerTaskPath.Get_Prev:ICallerTask;
begin
  InternalLock;
  try
    result:=FPrev;
  finally
    InternalUnlock;
  end;
end;

end.
