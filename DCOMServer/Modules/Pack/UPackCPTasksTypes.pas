//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UPackCPTasksTypes;

interface
  Uses UVarsetTypes, UPackCPTaskTypes, UADMTypes;
Type
  IPackCPTasks=Interface
  ['{3F2E1411-B5EF-4D61-8E31-7004DC5EAAAA}']
    function Get_LowBound:Integer;
    function Get_HighBound:Integer;
    function Get_PackCPTasks:IVarset;
    function Get_UsedRouteParams:Boolean;
    function Get_Count:Integer;
    //..
    procedure SetData(Const aTsk:Variant; Const aParams:Variant; Const aRouteParams:Variant; Const aBlockID:Variant);
    procedure GetData(Out aTsk:Variant; Out aParams:Variant; Out aRouteParams:Variant; Out aBlockID:Variant);
    function TaskAdd(aADMTask:TADMTask; Const aParam:Variant; Const aRouteParam:Variant; aBlockID:Integer{=-1}):Integer;
    function TaskAddWithWorked(aADMTask:TADMTask; Const aParam:Variant; Const aRouteParam:Variant; aBlockID:Integer{=-1}; aWorked:Boolean{=False}):Integer;
    procedure ClearByWorked(aWorked:Boolean);
    procedure SetWorked(aWorked:Boolean);
    procedure Clear;
    function ViewNext(Var aIntIndex:Integer):IPackCPTask;
    function Clone:IPackCPTasks;
    property LowBound:Integer read Get_LowBound;
    property HighBound:Integer read Get_HighBound;
    property Count:Integer read Get_Count;
    property PackCPTasks:IVarset read Get_PackCPTasks;
    property UsedRouteParams:Boolean read Get_UsedRouteParams;
  end;

implementation

end.
