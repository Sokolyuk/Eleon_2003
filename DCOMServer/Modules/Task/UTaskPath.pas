unit UTaskPath;

interface
  Uses UTaskPathTypes, UTaskCallerTypes, UIObject;
Type
  TTaskPath=class(TIObject, ITaskPath)
  private
    FCurrTaskCaller:ITaskCaller;
    FPrevTaskPath:ITaskPath;
  protected
    Function GetCurrTaskCaller:ITaskCaller;
    Procedure SetCurrTaskCaller(Value:ITaskCaller);
    Function GetPrevTaskPath:ITaskPath;
    Procedure SetPrevTaskPath(Value:ITaskPath);
  public
    constructor Create;
    destructor Destroy; override;
    property CurrTaskCaller:ITaskCaller read GetCurrTaskCaller write SetCurrTaskCaller;
    property PrevTaskPath:ITaskPath read GetPrevTaskPath write SetPrevTaskPath;
  end;

implementation

constructor TTaskPath.Create;
begin
  inherited Create;
  FCurrTaskCaller:=Nil;;
  FPrevTaskPath:=Nil;
end;

destructor TTaskPath.Destroy;
begin
  FCurrTaskCaller:=Nil;;
  FPrevTaskPath:=Nil;
  inherited Destroy;
end;

Function TTaskPath.GetCurrTaskCaller:ITaskCaller;
begin
  Result:=FCurrTaskCaller;
end;

Procedure TTaskPath.SetCurrTaskCaller(Value:ITaskCaller);
begin
  FCurrTaskCaller:=Value;
end;

Function TTaskPath.GetPrevTaskPath:ITaskPath;
begin
  Result:=FPrevTaskPath;
end;

Procedure TTaskPath.SetPrevTaskPath(Value:ITaskPath);
begin
  FPrevTaskPath:=Value;
end;

end.
