//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UPackCPTasks;

interface
  Uses UPackCPTasksTypes, UIObject, UVarsetTypes, UPackCPTaskTypes, UTTaskTypes, UADMTypes;
Type
  TPackCPTasks=class(TIObject, IPackCPTasks)
  protected
    FPackCPTasks:IVarset;
  protected
    function Get_LowBound:Integer;virtual;
    function Get_HighBound:Integer;virtual;
    function Get_PackCPTasks:IVarset;virtual;
    function InternalIVarsetDataViewToIPackCPTask(aIVarsetDataView:IVarsetDataView):IPackCPTask;virtual;
    function InternalTaskAddWithWorked(aADMTask:TADMTask; Const aParam:Variant; Const aRouteParam:Variant; aBlockID:Integer{=-1}; aWorked:Boolean{=False}):Integer;virtual;
    function Get_UsedRouteParams:Boolean;virtual;
    function Get_Count:Integer;virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetData(Const aTsk:Variant; Const aParams:Variant; Const aRouteParams:Variant; Const aBlockID:Variant);virtual;
    procedure GetData(Out aTsk:Variant; Out aParams:Variant; Out aRouteParams:Variant; Out aBlockID:Variant);virtual;
    procedure Clear;virtual;
    procedure ClearByWorked(aWorked:Boolean);virtual;
    procedure SetWorked(aWorked:Boolean);virtual;
    function TaskAdd(aADMTask:TADMTask; Const aParam, aRouteParam:Variant; aBlockID:Integer{=-1}):Integer;virtual;
    function TaskAddWithWorked(aADMTask:TADMTask; Const aParam:Variant; Const aRouteParam:Variant; aBlockID:Integer{=-1}; aWorked:Boolean{=False}):Integer;virtual;
    function ViewNext(Var aIntIndex:Integer):IPackCPTask;virtual;
    function Clone:IPackCPTasks;virtual;
    property LowBound:Integer read Get_LowBound;
    property HighBound:Integer read Get_HighBound;
    property PackCPTasks:IVarset read Get_PackCPTasks;
    property UsedRouteParams:Boolean read Get_UsedRouteParams;
    property Count:Integer read Get_Count;
  end;

implementation
  Uses SysUtils, UVarset, UPackCPTask, UErrorConsts{$IFNDEF VER130}, Variants{$ENDIF}{$IFDEF VER130}, Windows{$ENDIF};
constructor TPackCPTasks.Create;
begin
  FPackCPTasks:=TVarset.Create;
  FPackCPTasks.ITConfigIntIndexAssignable:=False;
  FPackCPTasks.ITConfigCheckUniqueIntIndex:=False;
  FPackCPTasks.ITConfigCheckUniqueStrIndex:=False;
  FPackCPTasks.ITConfigNoFoundException:=True;
  FPackCPTasks.ITConfigCaseSensitive:=False;
  Clear;
  Inherited Create;
end;

destructor TPackCPTasks.Destroy;
begin
  Clear;
  FPackCPTasks:=Nil;
  Inherited Destroy;
end;

procedure TPackCPTasks.Clear;
begin
  FPackCPTasks.ITClear;
end;

function TPackCPTasks.Get_UsedRouteParams:Boolean;
  Var tmpIntIndex:Integer;
      tmpIUnknown:IUnknown;
      tmpPackCPTask:IPackCPTask;
begin
  Result:=False;
  tmpIntIndex:=-1;
  while true do begin
    tmpIUnknown:=FPackCPTasks.ITViewNextDataGetOfIntIndex(tmpIntIndex);
    If tmpIntIndex=-1 then break;
    If (Not Assigned(tmpIUnknown))Or(tmpIUnknown.QueryInterface(IPackCPTask, tmpPackCPTask)<>S_OK)Or(Not Assigned(tmpPackCPTask)) Then Raise Exception.CreateFmt(cserInternalError, ['IPackCPTask is not found.']);
    Result:=Not VarIsEmpty(tmpPackCPTask.RouteParam);
    If Result then break;
  end;
  tmpIUnknown:=Nil;
  tmpPackCPTask:=Nil;
end;

procedure TPackCPTasks.ClearByWorked(aWorked:Boolean);
  Var tmpIntIndex, tmpIntIndexPrev:Integer;
      tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
      tmpPackCPTask:IPackCPTask;
begin
  tmpIntIndex:=-1;
  while true do begin
    tmpIntIndexPrev:=tmpIntIndex;
    tmpIVarsetDataView:=FPackCPTasks.ITViewNextGetOfIntIndex(tmpIntIndex);
    If tmpIntIndex=-1 then break;
    tmpIUnknown:=tmpIVarsetDataView.ITData;
    If (Not Assigned(tmpIUnknown))Or(tmpIUnknown.QueryInterface(IPackCPTask, tmpPackCPTask)<>S_OK)Or(Not Assigned(tmpPackCPTask)) Then Raise Exception.CreateFmt(cserInternalError, ['IPackCPTask is not found.']);
    If tmpPackCPTask.Worked=aWorked Then begin
      FPackCPTasks.ITClearOfIntIndex(tmpIntIndex);
      tmpIntIndex:=tmpIntIndexPrev;
    end;
  end;
end;

procedure TPackCPTasks.SetWorked(aWorked:Boolean);
  Var tmpIntIndex:Integer;
      tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
      tmpPackCPTask:IPackCPTask;
begin
  tmpIntIndex:=-1;
  while true do begin
    tmpIVarsetDataView:=FPackCPTasks.ITViewNextGetOfIntIndex(tmpIntIndex);
    If tmpIntIndex=-1 then break;
    tmpIUnknown:=tmpIVarsetDataView.ITData;
    If (Not Assigned(tmpIUnknown))Or(tmpIUnknown.QueryInterface(IPackCPTask, tmpPackCPTask)<>S_OK)Or(Not Assigned(tmpPackCPTask)) Then Raise Exception.CreateFmt(cserInternalError, ['IPackCPTask is not found.']);
    tmpPackCPTask.Worked:=aWorked;
  end;
end;

procedure TPackCPTasks.SetData(Const aTsk:Variant; Const aParams:Variant; Const aRouteParams:Variant; Const aBlockID:Variant);
  Var tmpI:Integer;
      tmpIsArray, tmpRouteIsArray:Boolean;
      tmpPackCPTask:IPackCPTask;
      tmpLowBound, tmpHighBound:Integer;
begin
  Clear;//Чищу прежние данные
  tmpIsArray:=VarIsArray(aTsk);
  If (tmpIsArray<>VarIsArray(aParams))Or(tmpIsArray<>VarIsArray(aBlockID))Then Raise Exception.Create('Disparity arrays.');
  If tmpIsArray Then begin
    // получаю диапозон списка команд
    tmpLowBound:=VarArrayLowBound(aTsk, 1);
    tmpHighBound:=VarArrayHighBound(aTsk, 1);
    // проверяю соответствие диапозона списка команд для всех массивов
    If (tmpLowBound<>VarArrayLowBound(aParams, 1)) Or
       (tmpHighBound<>VarArrayHighBound(aParams, 1)) Then raise Exception.create('Неправильная размерность CPT_Params & CPT_Tsk.');
    If (tmpLowBound<>VarArrayLowBound(aBlockID, 1)) Or
       (tmpHighBound<>VarArrayHighBound(aBlockID, 1)) Then raise Exception.create('Неправильная размерность CPT_BlockID & CPT_Tsk.');
    tmpRouteIsArray:=VarIsArray(aRouteParams);//Проверяю RouteParams
    If tmpRouteIsArray Then begin
      If (tmpLowBound<>VarArrayLowBound(aRouteParams, 1)) Or
         (tmpHighBound<>VarArrayHighBound(aRouteParams, 1)) Then raise Exception.create('Неправильная размерность CPT_RouteParams & CPT_Tsk.');
    end;
    For tmpI:=tmpLowBound to tmpHighBound do begin
      tmpPackCPTask:=TPackCPTask.Create;
      tmpPackCPTask.Task:=aTsk[tmpI];
      tmpPackCPTask.Param:=aParams[tmpI];
      tmpPackCPTask.BlockID:=aBlockID[tmpI];
      If tmpRouteIsArray Then begin//Устанавливаю RouteParams
        tmpPackCPTask.RouteParam:=aRouteParams[tmpI];
      end else begin
        tmpPackCPTask.RouteParam:=Unassigned;
      end;
      tmpPackCPTask.Step:=tmpI;
      FPackCPTasks.ITPushV(tmpPackCPTask)
    end;
    tmpPackCPTask:=Nil;
  end;
end;

procedure TPackCPTasks.GetData(Out aTsk:Variant; Out aParams:Variant; Out aRouteParams:Variant; Out aBlockID:Variant);
  Var tmpI, tmpIntIndex:Integer;
      tmpIVarsetDataView:IVarsetDataView;
      tmpPackCPTask:IPackCPTask;
      tmpIUnknown:IUnknown;
      tmpLowBound, tmpHighBound:Integer;
      tmpUsedRouteParams:Boolean;
begin
  try
    if FPackCPTasks.ITCount=0 then begin
      aTsk:=unassigned;
      aParams:=unassigned;
      aRouteParams:=unassigned;
      aBlockID:=-1;
    end else begin
      tmpLowBound:=LowBound;
      tmpHighBound:=HighBound;
      tmpUsedRouteParams:=UsedRouteParams;
      aTsk:=VarArrayCreate([tmpLowBound, tmpHighBound], varInteger);
      aParams:=VarArrayCreate([tmpLowBound, tmpHighBound], varVariant);
      aBlockID:=VarArrayCreate([tmpLowBound, tmpHighBound], varInteger);
      If tmpUsedRouteParams then begin
        aRouteParams:=VarArrayCreate([tmpLowBound, tmpHighBound], varVariant);
      end else begin
        aRouteParams:=Unassigned;
      end;
      tmpI:=tmpLowBound-1;
      tmpIntIndex:=-1;
      while true do begin
        tmpIVarsetDataView:=FPackCPTasks.ITViewNextGetOfIntIndex(tmpIntIndex);
        If tmpIntIndex=-1 then break;
        Inc(tmpI);
        tmpIUnknown:=tmpIVarsetDataView.ITData;
        If (Not Assigned(tmpIUnknown))Or(tmpIUnknown.QueryInterface(IPackCPTask, tmpPackCPTask)<>S_OK)Or(Not Assigned(tmpPackCPTask)) Then Raise Exception.CreateFmt(cserInternalError, ['IPackCPTask is not found.']);
        If tmpI>tmpHighBound Then Raise Exception.CreateFmt(cserInternalError, ['Disparity array bound.']);
        aTsk[tmpI]:=tmpPackCPTask.Task;
        aParams[tmpI]:=tmpPackCPTask.Param;
        aBlockID[tmpI]:=tmpPackCPTask.BlockID;
        If tmpUsedRouteParams Then aRouteParams[tmpI]:=tmpPackCPTask.RouteParam;
      end;
      tmpIVarsetDataView:=Nil;
      tmpPackCPTask:=Nil;
      tmpIUnknown:=Nil;
      If tmpI<>tmpHighBound Then Raise Exception.CreateFmt(cserInternalError, ['Disparity array bound(2).']);
    end;
  except
    VarClear(aTsk);
    VarClear(aParams);
    VarClear(aRouteParams);
    VarClear(aBlockID);
    raise;
  end;  
end;

function TPackCPTasks.Get_LowBound:Integer;
begin
  Result:=0;
end;

function TPackCPTasks.Get_HighBound:Integer;
begin
  Result:=FPackCPTasks.ITCount-1;
end;

function TPackCPTasks.Get_Count:Integer;
begin
  Result:=FPackCPTasks.ITCount;
end;

function TPackCPTasks.Get_PackCPTasks:IVarset;
begin
  Result:=FPackCPTasks;
end;

function TPackCPTasks.InternalIVarsetDataViewToIPackCPTask(aIVarsetDataView:IVarsetDataView):IPackCPTask;
  Var tmpIUnknown:IUnknown;
begin
  If Assigned(aIVarsetDataView) Then begin
    tmpIUnknown:=aIVarsetDataView.ITData;
    If (Not Assigned(tmpIUnknown))Or(tmpIUnknown.QueryInterface(IPackCPTask, Result)<>S_OK)Or(Not Assigned(Result)) Then Raise Exception.CreateFmt(cserInternalError, ['IPackCPTask is not found.']);
    tmpIUnknown:=Nil;
  end else begin
    Result:=Nil;
  end;
end;

function TPackCPTasks.ViewNext(Var aIntIndex:Integer):IPackCPTask;
  Var tmpIVarsetDataView:IVarsetDataView;
begin
  tmpIVarsetDataView:=FPackCPTasks.ITViewNextGetOfIntIndex(aIntIndex);
  Result:=InternalIVarsetDataViewToIPackCPTask(tmpIVarsetDataView);
end;

function TPackCPTasks.TaskAdd(aADMTask:TADMTask; Const aParam:Variant; Const aRouteParam:Variant; aBlockID:Integer{=-1}):Integer;
begin
  Result:=InternalTaskAddWithWorked(aADMTask, aParam, aRouteParam, aBlockID, False);
end;

function TPackCPTasks.InternalTaskAddWithWorked(aADMTask:TADMTask; Const aParam:Variant; Const aRouteParam:Variant; aBlockID:Integer{=-1}; aWorked:Boolean{=False}):Integer;
  Var tmpPackCPTask:IPackCPTask;
begin
  tmpPackCPTask:=TPackCPTask.Create;
  tmpPackCPTask.Task:=aADMTask;
  tmpPackCPTask.Param:=aParam;
  tmpPackCPTask.RouteParam:=aRouteParam;
  tmpPackCPTask.BlockID:=aBlockID;
  tmpPackCPTask.Step:=-1;
  tmpPackCPTask.Worked:=aWorked;
  FPackCPTasks.ITPushV(tmpPackCPTask);
  Result:=FPackCPTasks.ITCount-1;
end;

function TPackCPTasks.TaskAddWithWorked(aADMTask:TADMTask; Const aParam:Variant; Const aRouteParam:Variant; aBlockID:Integer{=-1}; aWorked:Boolean{=False}):Integer;
begin
  Result:=InternalTaskAddWithWorked(aADMTask, aParam, aRouteParam, aBlockID, aWorked);
end;

function TPackCPTasks.Clone:IPackCPTasks;
  var tmpTsk:Variant;
      tmpParams:Variant;
      tmpRouteParams:Variant;
      tmpBlockID:Variant;
begin
  result:=TPackCPTasks.Create;
  GetData(tmpTsk, tmpParams, tmpRouteParams, tmpBlockID);
  result.SetData(tmpTsk, tmpParams, tmpRouteParams, tmpBlockID);
end;

end.
