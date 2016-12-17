unit UEServersList;

interface
  Uses UEServersListTypes, UVarsetTypes, UITObject, UEServerInfoTypes;
Type
  TEServersList=Class(TITObject, IEServersList)
  Private
    FList:IVarset;
  Protected
    function IT_GetList:IVarset;
    function IT_GetListV:Variant;
    Procedure IT_SetListV(Value:Variant);
  Public
    Constructor Create;
    Destructor Destroy; Override;
    Function ITListAdd(Value:IEServerInfo):IVarsetDataView;
    Function ITEServerOfRegName(Const aRegName:AnsiString):IEServerInfo;
    Function ITEServerOfRegNameV(Const aRegName:AnsiString):Variant;
    Property ITList:IVarset read IT_GetList;
    Property ITListV:Variant read IT_GetListV write IT_SetListV;
  End;

implementation
  Uses UVarset, Variants, UEServerInfo, SysUtils;

Constructor TEServersList.Create;
begin
  FList:=TVarset.Create;
  FList.ITConfigIntIndexAssignable:=False;
  FList.ITConfigCheckUniqueIntIndex:=False;
  FList.ITConfigCheckUniqueStrIndex:=False;
  FList.ITConfigNoFoundException:=True;
  FList.ITConfigCaseSensitive:=False;
  Inherited Create;
end;

Destructor TEServersList.Destroy;
begin
  FList:=Nil;
  Inherited Destroy;
end;

function TEServersList.IT_GetList:IVarset;
begin
  InternalLock;
  try
    Result:=FList;
  finally
    InternalUnlock;
  end;
end;

Function TEServersList.ITEServerOfRegName(Const aRegName:AnsiString):IEServerInfo;
  Var tmpIntIndex:Integer;
      tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
      tmpFind:Boolean;
begin
  InternalLock;
  try
    tmpFind:=false;
    tmpIntIndex:=-1;
    while true do begin
      tmpIVarsetDataView:=FList.ITViewNextGetOfIntIndex(tmpIntIndex);
      If tmpIntIndex=-1 then break;
      tmpIUnknown:=tmpIVarsetDataView.ITData;
      If AnsiUpperCase(IEServerInfo(tmpIUnknown).ITRegName)=AnsiUpperCase(aRegName) Then begin
        Result:=IEServerInfo(tmpIUnknown);
        tmpFind:=True;
        Break;
      end;
    end;
    If not tmpFind Then Raise Exception.Create('RegName='''+aRegName+''' not found.');
    tmpIUnknown:=Nil;
    tmpIVarsetDataView:=Nil;
  finally
    InternalUnlock;
  end;
end;

Function TEServersList.ITEServerOfRegNameV(Const aRegName:AnsiString):Variant;
  Var tmpIEServerInfo:IEServerInfo;
begin
  InternalLock;
  try
    tmpIEServerInfo:=ITEServerOfRegName(aRegName);
    Result:=tmpIEServerInfo.ITEServerV;
    tmpIEServerInfo:=Nil;
  finally
    InternalUnlock;
  end;
end;

function TEServersList.IT_GetListV:Variant;
  Var tmpIntIndex:Integer;
      tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
      tmpivHB:Integer;
begin
  InternalLock;
  try
    Result:=Unassigned;
    tmpivHB:=-1;
    tmpIntIndex:=-1;
    while true do begin
      tmpIVarsetDataView:=FList.ITViewNextGetOfIntIndex(tmpIntIndex);
      If tmpIntIndex=-1 then break;
      If Assigned(tmpIVarsetDataView) Then begin
        tmpIUnknown:=tmpIVarsetDataView.ITData;
        If Assigned(tmpIUnknown) Then begin
          If tmpivHB=-1 then begin
            Result:=VarArrayCreate([0, 0], varVariant);
            tmpivHB:=0;
          end else begin
            VarArrayRedim(Result, tmpivHB+1);
            Inc(tmpivHB);
          end;
          Result[tmpivHB]:=IEServerInfo(tmpIUnknown).ITEServerV;
          tmpIUnknown:=Nil;
        end;
        tmpIVarsetDataView:=Nil;
      end;
    end;
  finally
    InternalUnlock;
  end;
end;

Procedure TEServersList.IT_SetListV(Value:Variant);
  Var tmpList:IVarset;
      tmpIEServerInfo:IEServerInfo;
      tmpI:Integer;
begin
  InternalLock;
  try
    try
      tmpList:=TVarset.Create;
      try
        tmpList.ITConfigIntIndexAssignable:=False;
        tmpList.ITConfigCheckUniqueIntIndex:=False;
        tmpList.ITConfigCheckUniqueStrIndex:=False;
        tmpList.ITConfigNoFoundException:=True;
        tmpList.ITConfigCaseSensitive:=False;
        For tmpI:=VarArrayLowBound(Value, 1) to VarArrayHighBound(Value, 1 ) do begin
          tmpIEServerInfo:=TEServerInfo.Create;
          try
            tmpIEServerInfo.ITEServerV:=Value[tmpI];
            tmpList.ITPushV(tmpIEServerInfo);
          finally
            tmpIEServerInfo:=Nil;
          end;
        end;
        FList:=tmpList;
      finally
        tmpList:=Nil;
      end;
    except
      on e:exception do begin
        Raise Exception.Create('IT_SetListV: '+e.message);
      end;
    end;
  finally
    InternalUnlock;
  end;
end;

Function TEServersList.ITListAdd(Value:IEServerInfo):IVarsetDataView;
begin
  InternalLock;
  try
    Result:=FList.ITPushV(Value);
  finally
    InternalUnlock;
  end;
end;

end.
