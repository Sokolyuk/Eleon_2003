//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UPackCPTaskTypes;

interface
  uses UADMTypes;
type
  IPackCPTask=Interface
  ['{42B410B1-260B-41A3-A595-0E0A2DAAD83A}']
    function Get_Task:TADMTask;
    procedure Set_Task(Value:TADMTask);
    function Get_Param:Variant;
    procedure Set_Param(Const Value:Variant);
    function Get_RouteParam:Variant;
    procedure Set_RouteParam(Const Value:Variant);
    function Get_BlockID:Integer;
    procedure Set_BlockID(Value:Integer);
    function Get_Step:Integer;
    procedure Set_Step(Value:Integer);
    function Get_Worked:Boolean;
    procedure Set_Worked(Value:Boolean);
    //..
    procedure Clear;
    property Task:TADMTask read Get_Task write Set_Task;
    property Param:Variant read Get_Param write Set_Param;
    property RouteParam:Variant read Get_RouteParam write Set_RouteParam;
    property BlockID:Integer read Get_BlockID write Set_BlockID;
    property Step:Integer read Get_Step write Set_Step;
    //..
    property Worked:Boolean read Get_Worked write Set_Worked;
  end;

implementation

end.
