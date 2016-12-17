//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UPackCPTask;

interface
  Uses UIObject, UPackCPTaskTypes, UADMTypes;
Type
  TPackCPTask=class(TIObject, IPackCPTask)
  private
    FTask:TADMTask;
    FParam:Variant;
    FRouteParam:Variant;
    FBlockID:Integer;
    FStep:Integer;
    FWorked:Boolean;
  protected
    function Get_Task:TADMTask;
    procedure Set_Task(Value:TADMTask);
    function Get_Param:Variant;
    procedure Set_Param(const Value:Variant);
    function Get_RouteParam:Variant;
    procedure Set_RouteParam(const Value:Variant);
    function Get_BlockID:Integer;
    procedure Set_BlockID(Value:Integer);
    function Get_Step:Integer;
    procedure Set_Step(Value:Integer);
    function Get_Worked:Boolean;
    procedure Set_Worked(Value:Boolean);
  public
    constructor Create;
    destructor Destroy;override;
    procedure Clear;
    property Task:TADMTask read Get_Task write Set_Task;
    property Param:Variant read Get_Param write Set_Param;
    property BlockID:Integer read Get_BlockID write Set_BlockID;
    property RouteParam:Variant read Get_RouteParam write Set_RouteParam;
    property Step:Integer read Get_Step write Set_Step;
    property Worked:Boolean read Get_Worked write Set_Worked;
  end;

implementation
  uses SysUtils{$IFNDEF VER130}, Variants{$ENDIF};

constructor TPackCPTask.Create;
begin
  inherited Create;
  Clear;
end;

destructor TPackCPTask.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TPackCPTask.Clear;
begin
  FTask:=tskADMNone;
  FParam:=Unassigned;
  FRouteParam:=Unassigned;
  FBlockID:=-1;
  FStep:=-1;
  FWorked:=False;
end;

function TPackCPTask.Get_Task:TADMTask;
begin
  Result:=FTask;
end;

procedure TPackCPTask.Set_Task(Value:TADMTask);
begin
  FTask:=Value;
end;

function TPackCPTask.Get_Param:Variant;
begin
  Result:=FParam;
end;

procedure TPackCPTask.Set_Param(const Value:Variant);
begin
  FParam:=Value;
end;

function TPackCPTask.Get_RouteParam:Variant;
begin
  Result:=FRouteParam;
end;

procedure TPackCPTask.Set_RouteParam(const Value:Variant);
begin
  FRouteParam:=Value;
end;


function TPackCPTask.Get_BlockID:Integer;
begin
  Result:=FBlockID;
end;

procedure TPackCPTask.Set_BlockID(Value:Integer);
begin
  FBlockID:=Value;
end;

function TPackCPTask.Get_Step:Integer;
begin
  Result:=FStep;
end;

procedure TPackCPTask.Set_Step(Value:Integer);
begin
  FStep:=Value;
end;

function TPackCPTask.Get_Worked:Boolean;
begin
  Result:=FWorked;
end;

procedure TPackCPTask.Set_Worked(Value:Boolean);
begin
  FWorked:=Value;
end;

end.
