unit UEClientsInfo;

interface
  Uses UEClientsInfoTypes, UITObject, UEClientInfoTypes, UVarsetTypes;
Type
  TEClientsInfo=Class(TITObject, IEClientsInfo)
  Private
    FClients:IVarset;
    FAppStartTime:TDateTime;
    FObjectCount, FStartsAmount:Integer;
    Function InternalCreateVarset:Ivarset;
  Protected
    Function IT_GetAppStartTime:TDateTime;
    Procedure IT_SetAppStartTime(Value:TDateTime);
    Function IT_GetObjectCount:Integer;
    Procedure IT_SetObjectCount(Value:Integer);
    Function IT_GetStartsAmount:Integer;
    Procedure IT_SetStartsAmount(Value:Integer);
    Function IT_GetEClientsV:Variant;
    Procedure IT_SetEClientsV(Value:Variant);
    Function IT_GetClients:IVarset;
  Public
    Constructor Create;
    Destructor Destroy; Override;
    Function ITEClientAdd(aEClientInfo:IEClientInfo):IVarsetDataView;
    Function ITEClientAddV(aEClientInfo:Variant):IVarsetDataView;
    Property ITAppStartTime:TDateTime read IT_GetAppStartTime write IT_SetAppStartTime;
    Property ITObjectCount:Integer read IT_GetObjectCount write IT_SetObjectCount;
    Property ITStartsAmount:Integer read IT_GetStartsAmount write IT_SetStartsAmount;
    Property ITClients:IVarset read IT_GetClients;
    Property ITEClientsV:Variant read IT_GetEClientsV write IT_SetEClientsV;
  End;

implementation
  Uses UEClientInfo, UVarset, Sysutils, Variants;

Constructor TEClientsInfo.Create;
begin
  FClients:=InternalCreateVarset;
  FAppStartTime:=0;
  FObjectCount:=-1;
  FStartsAmount:=-1;
  Inherited Create;
end;

Destructor TEClientsInfo.Destroy;
begin
  FClients:=nil;
  Inherited Destroy;
end;

Function TEClientsInfo.InternalCreateVarset:Ivarset;
begin
  Result:=TVarset.Create;
  Result.ITConfigIntIndexAssignable:=False;
  Result.ITConfigCheckUniqueIntIndex:=False;
  Result.ITConfigCheckUniqueStrIndex:=False;
  Result.ITConfigNoFoundException:=True;
  Result.ITConfigCaseSensitive:=False;
end;

Function TEClientsInfo.IT_GetAppStartTime:TDateTime;
begin
  InternalLock;
  try
    Result:=FAppStartTime;
  finally
    InternalUnlock;
  end;
end;

Procedure TEClientsInfo.IT_SetAppStartTime(Value:TDateTime);
begin
  InternalLock;
  try
    FAppStartTime:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TEClientsInfo.IT_GetObjectCount:Integer;
begin
  InternalLock;
  try
    Result:=FObjectCount;
  finally
    InternalUnlock;
  end;
end;

Procedure TEClientsInfo.IT_SetObjectCount(Value:Integer);
begin
  InternalLock;
  try
    FObjectCount:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TEClientsInfo.IT_GetStartsAmount:Integer;
begin
  InternalLock;
  try
    Result:=FStartsAmount;
  finally
    InternalUnlock;
  end;
end;

Procedure TEClientsInfo.IT_SetStartsAmount(Value:Integer);
begin
  InternalLock;
  try
    FStartsAmount:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TEClientsInfo.IT_GetEClientsV:Variant;
  Var tmpIntIndex:Integer;
      tmpIVarsetDataView:IVarsetDataView;
      tmpV:Variant;
      tmpivHB:Integer;
      tmpIUnknown:IUnknown;
begin
  InternalLock;
  try
    //                   [0]                 [0][0]       [0][1]      [0][2] [0][3]   [0][4]   [0][5]                   [1]                         [1][0]                    [1][1]         [1][2]
    //VarArrayOf([vlASMServers(VarArrayOf([aablThis, aaStartDateTime, aaNum, aaUser, aaState, aaLoginType]);), vlExtDataASMServers(VarArrayOf([AppStartDateTime, ComServer.ObjectCount, vlASMStartNum]);)]);
    If FClients.ITCount=0 Then begin
      Result:=Unassigned;
      Exit;
    end;
    tmpIntIndex:=-1;
    tmpV:=Unassigned;
    tmpivHB:=-1;
    While true do begin
      tmpIVarsetDataView:=FClients.ITViewNextGetOfIntIndex(tmpIntIndex);
      If tmpIntIndex=-1 Then Break;
      tmpIUnknown:=tmpIVarsetDataView.ITData;
      If Assigned(tmpIUnknown) Then begin
        If tmpivHB=-1 Then begin
          tmpV:=VarArrayCreate([0, 0], varVariant);
          tmpivHB:=0;
        end else begin
          VarArrayRedim(tmpV, tmpivHB+1);
          Inc(tmpivHB);
        end;
        tmpV[tmpivHB]:=IEClientInfo(tmpIUnknown).ITEClientV;
        tmpIUnknown:=Nil;
      end;
    end;
    Result:=VarArrayOf([tmpV, VarArrayOf([FAppStartTime, FObjectCount, FStartsAmount])]);
  finally
    InternalUnlock;
  end;
end; 

Procedure TEClientsInfo.IT_SetEClientsV(Value:Variant);
  Var tmpClients:IVarset;
      tmpI:Integer;
    tmpAppStartTime:TDateTime;
    tmpObjectCount, tmpStartsAmount:Integer;
    tmpEClientInfo:IEClientInfo;
begin
  InternalLock;
  try
    If VarIsEmpty(Value) Then begin
      //Обнуляю имеющееся значение
      FClients.ITClear;
      FAppStartTime:=0;
      FObjectCount:=-1;
      FStartsAmount:=-1;
    end else begin
      //Назначаю новое значение
      try
        tmpClients:=InternalCreateVarset;
        //..
        tmpAppStartTime:=Value[1][0];
        tmpObjectCount:=Value[1][1];
        tmpStartsAmount:=Value[1][2];
        //..
        for tmpI:=VarArrayLowBound(Value[0], 1) to VarArrayHighBound(Value[0], 1) do begin
          tmpEClientInfo:=TEClientInfo.Create;
          tmpEClientInfo.ITEClientV:=Value[0][tmpI];
          tmpClients.ITPushV(tmpEClientInfo);
          tmpEClientInfo:=Nil;
        end;
        //..
        FClients:=Nil;
        FClients:=tmpClients;
        FAppStartTime:=tmpAppStartTime;
        FObjectCount:=tmpObjectCount;
        FStartsAmount:=tmpStartsAmount;
      except
        on e:exception do begin
          tmpEClientInfo:=Nil;
          tmpClients:=Nil;
          Raise Exception.Create('IT_SetEClientsInfo: '+e.Message);
        end;
      end;
    end;
  finally
    InternalUnlock;
  end;
end;

Function TEClientsInfo.IT_GetClients:IVarset;
begin
  InternalLock;
  try
    Result:=FClients;
  finally
    InternalUnlock;
  end;
end;

Function TEClientsInfo.ITEClientAdd(aEClientInfo:IEClientInfo):IVarsetDataView;
begin
  InternalLock;
  try
    Result:=FClients.ITPushV(aEClientInfo);
  finally
    InternalUnlock;
  end;
end;

Function TEClientsInfo.ITEClientAddV(aEClientInfo:Variant):IVarsetDataView;
  Var tmpEClientInfo:IEClientInfo;
begin
  InternalLock;
  try
    tmpEClientInfo:=TEClientInfo.Create;
    tmpEClientInfo.ITEClientV:=aEClientInfo;
    Result:=FClients.ITPushV(tmpEClientInfo);
    tmpEClientInfo:=Nil;
  finally
    InternalUnlock;
  end;
end;

end.
