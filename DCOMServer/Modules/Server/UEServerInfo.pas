unit UEServerInfo;

interface
  Uses UEServerInfoTypes, UITObject, Classes, UEClientsInfoTypes, UVarsetTypes, UProcessInfoTypes;
Type
  TEServerInfo=Class(TITObject, IEServerInfo)
  Private
    FRegName:AnsiString;
    FGUID, FMasterGUID, FPathEXE:AnsiString;
    FType:Integer;
    FPIDList:IVarset;
    FValid:Boolean;
    FEClientsInfo:IEClientsInfo;
    FAutorestartNormal, FAutorestartCritical:Cardinal;
    FAutoKeepStarted:boolean;
    FIProcessInfo:IProcessInfo;
    FAutorestartMessage:AnsiString;
    FAutorestartNornalPeriod:Variant;
    Function InternalGetStartedList:Variant;
    Procedure InternalSetStartedList(aVarset:IVarset; Value:Variant);
  Protected
    Function IT_GetRegName:AnsiString;
    Procedure IT_SetRegName(Value:AnsiString);
    Function IT_GetGUID:AnsiString;
    Procedure IT_SetGUID(Value:AnsiString);
    Function IT_GetType:Integer;
    Procedure IT_SetType(Value:Integer);
    Function IT_GetPIDList:IVarset;
    Function IT_GetPIDStarted:Cardinal;
    Function IT_GetValid:Boolean;
    Procedure IT_SetValid(Value:Boolean);
    Function IT_GetClients:IEClientsInfo;
    Function IT_GetEServerV:Variant;
    Procedure IT_SetEServerV(Value:Variant);
    Function IT_GetPathEXE:AnsiString;
    Procedure IT_SetPathEXE(Value:AnsiString);
    Function IT_GetMasterGUID:AnsiString;
    Procedure IT_SetMasterGUID(Value:AnsiString);
    function IT_GetAutorestartCritical:Cardinal;
    Procedure IT_SetAutorestartCritical(Value:Cardinal);
    function IT_GetAutorestartNormal:Cardinal;
    Procedure IT_SetAutorestartNormal(Value:Cardinal);
    Function IT_GetStarted:Boolean;
    function IT_GetAutoKeepStarted:Boolean;
    Procedure IT_SetAutoKeepStarted(Value:Boolean);
    Function IT_GetProcessInfo:IProcessInfo;
    Function IT_GetAutorestartMessage:AnsiString;
    Procedure IT_SetAutorestartMessage(Value:AnsiString);
  Public
    Constructor Create;
    Destructor Destroy; Override;
    Function ITPIDUpdate(aPID:Cardinal; aEServerState:TEServerState):IVarsetDataView;
    Procedure ITPIDDelete(aPID:Cardinal);
    Procedure IT_SetAutorestartNornalPeriod(Value:AnsiString);
    Function IT_GetAutorestartNornalPeriod:Variant;
    Property ITRegName:AnsiString read IT_GetRegName write IT_SetRegName;
    Property ITGUID:AnsiString read IT_GetGUID write IT_SetGUID;
    Property ITMasterGUID:AnsiString read IT_GetMasterGUID write IT_SetMasterGUID;
    Property ITPathEXE:AnsiString read IT_GetPathEXE write IT_SetPathEXE;
    Property ITType:Integer read IT_GetType write IT_SetType;
    Property ITPIDList:IVarset read IT_GetPIDList;
    Property ITPIDStarted:Cardinal read IT_GetPIDStarted;
    Property ITValid:Boolean read IT_GetValid write IT_SetValid;
    Property ITAutorestartCritical:Cardinal read IT_GetAutorestartCritical write IT_SetAutorestartCritical;
    Property ITAutorestartNormal:Cardinal read IT_GetAutorestartNormal write IT_SetAutorestartNormal;
    Property ITAutorestartMessage:AnsiString read IT_GetAutorestartMessage write IT_SetAutorestartMessage;
    Property ITAutoKeepStarted:Boolean read IT_GetAutoKeepStarted write IT_SetAutoKeepStarted;
    Property ITStarted:Boolean read IT_GetStarted;
    Property ITProcessInfo:IProcessInfo read IT_GetProcessInfo;
    Property ITClients:IEClientsInfo read IT_GetClients;
    Property ITEServerV:Variant read IT_GetEServerV write IT_SetEServerV;
  End;

implementation
  Uses UEClientsInfo, UEClientInfo, UVarset, UTypes, Variants, UProcessInfo, UTypeUtils;

Constructor TEServerInfo.Create;
begin
  FRegName:='';
  FGUID:='';
  FMasterGUID:='';
  FPathEXE:='';
  FType:=-1;
  FAutorestartNormal:=0;
  FAutorestartCritical:=0;
  FPIDList:=TVarset.Create;
  FPIDList.ITConfigIntIndexAssignable:=False;
  FPIDList.ITConfigCheckUniqueIntIndex:=False;
  FPIDList.ITConfigCheckUniqueStrIndex:=False;
  FPIDList.ITConfigNoFoundException:=True;
  FPIDList.ITConfigCaseSensitive:=False;
  FValid:=False;
  FEClientsInfo:=TEClientsInfo.Create;
  FAutoKeepStarted:=False;
  FIProcessInfo:=TProcessInfo.Create;
  FAutorestartMessage:='';
  Inherited Create;
  IT_SetAutorestartNornalPeriod('');//Init->FAutorestartNornalPeriod
end;

Destructor TEServerInfo.Destroy;
begin
  FPIDList:=Nil;
  FIProcessInfo:=Nil;
  FAutorestartMessage:='';
  VarClear(FAutorestartNornalPeriod);
  Inherited Destroy;
end;

Function TEServerInfo.IT_GetRegName:AnsiString;
begin
  InternalLock;
  try
    Result:=FRegName;
  finally
    InternalUnlock;
  end;
end;

Procedure TEServerInfo.IT_SetRegName(Value:AnsiString);
begin
  InternalLock;
  try
    FRegName:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TEServerInfo.IT_GetGUID:AnsiString;
begin
  InternalLock;
  try
    Result:=FGUID;
  finally
    InternalUnlock;
  end;
end;

Procedure TEServerInfo.IT_SetGUID(Value:AnsiString);
begin
  InternalLock;
  try
    FGUID:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TEServerInfo.IT_GetType:Integer;
begin
  InternalLock;
  try
    Result:=FType;
  finally
    InternalUnlock;
  end;
end;

Procedure TEServerInfo.IT_SetType(Value:Integer);
begin
  InternalLock;
  try
    FType:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TEServerInfo.IT_GetPIDList:IVarset;
begin
  InternalLock;
  try
    Result:=FPIDList;
  finally
    InternalUnlock;
  end;
end;

Function TEServerInfo.IT_GetPIDStarted:Cardinal;
  Var tmpIntIndex:Integer;
      tmpV:Variant;
      tmpTEServerState:TEServerState;
      tmpIVarsetDataView:IVarsetDataView;
begin
  InternalLock;
  try
    //смотрю в списке
    Result:=0;
    tmpIntIndex:=-1;
    while true do begin
      tmpIVarsetDataView:=FPIDList.ITViewNextGetOfIntIndex(tmpIntIndex);
      If tmpIntIndex=-1 Then break;
      tmpV:=tmpIVarsetDataView.ITData;
      tmpTEServerState:=tmpV[1];
      If tmpTEServerState=essStarted then begin
        Result:=tmpV[0];
        Break;
      end;
    end;
  finally
    InternalUnlock;
  end;
end;

Function TEServerInfo.IT_GetStarted:Boolean;
  Var tmpIntIndex:Integer;
      tmpV:Variant;
      tmpTEServerState:TEServerState;
      tmpIVarsetDataView:IVarsetDataView;
begin
  InternalLock;
  try
    //смотрю в списке
    Result:=False;
    tmpIntIndex:=-1;
    while true do begin
      tmpIVarsetDataView:=FPIDList.ITViewNextGetOfIntIndex(tmpIntIndex);
      If tmpIntIndex=-1 Then break;
      tmpV:=tmpIVarsetDataView.ITData;
      tmpTEServerState:=tmpV[1];
      If tmpTEServerState=essStarted then begin
        Result:=True;
        Break;
      end;
    end;
  finally
    InternalUnlock;
  end;
end;

Function TEServerInfo.ITPIDUpdate(aPID:Cardinal; aEServerState:TEServerState):IVarsetDataView;
  Var tmpIntIndex:Integer;
      tmp32bit:T32bit;
      tmpIVarsetDataView:IVarsetDataView;
      tmpOk:Boolean;
begin
  InternalLock;
  try
    tmpIntIndex:=-1;
    tmpOk:=False;
    while true do begin
      tmpIVarsetDataView:=FPIDList.ITViewNextGetOfIntIndex(tmpIntIndex);
      If tmpIntIndex=-1 Then break;
      tmp32bit.ofInteger:=tmpIVarsetDataView.ITData[0];
      If tmp32bit.ofLongword=aPID then begin
        tmpIVarsetDataView.ITData:=VarArrayOf([tmp32bit.ofInteger, aEServerState]);
        Result:=tmpIVarsetDataView;
        tmpOk:=True;
        Break;
      end;
    end;
    tmpIVarsetDataView:=Nil;
    If Not tmpOk then begin
      tmp32bit.ofLongword:=aPID;
      Result:=FPIDList.ITPushV(VarArrayOf([tmp32bit.ofInteger, aEServerState]));
    end;
    //Синхронизирую процесс инфо
    If aEServerState=essStarted Then begin
      FIProcessInfo.ITPID:=aPID;
    end else FIProcessInfo.ITPID:=0;
  finally
    InternalUnlock;
  end;
end;

Procedure TEServerInfo.ITPIDDelete(aPID:Cardinal);
  Var tmpIntIndex:Integer;
      tmpV:Variant;
      tmp32bit:T32bit;
      tmpIVarsetDataView:IVarsetDataView;
begin
  InternalLock;
  try
    tmpIntIndex:=-1;
    while true do begin
      tmpIVarsetDataView:=FPIDList.ITViewNextGetOfIntIndex(tmpIntIndex);
      If tmpIntIndex=-1 Then break;
      tmpV:=tmpIVarsetDataView.ITData;
      tmp32bit.ofInteger:=tmpV[0];
      If tmp32bit.ofLongword=aPID then begin
        FPIDList.ITClearOfIntIndex(tmpIntIndex);
        Break;
      end;
    end;
    tmpIVarsetDataView:=Nil;
    //Синхронизирую процесс инфо
    If FIProcessInfo.ITPID=aPID Then begin
      FIProcessInfo.ITPID:=0; //чищу
    end;
  finally
    InternalUnlock;
  end;
end;

Function TEServerInfo.IT_GetValid:Boolean;
begin
  InternalLock;
  try
    Result:=FValid;
  finally
    InternalUnlock;
  end;
end;

Procedure TEServerInfo.IT_SetValid(Value:Boolean);
begin
  InternalLock;
  try
    FValid:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TEServerInfo.IT_GetPathEXE:AnsiString;
begin
  InternalLock;
  try
    Result:=FPathEXE;
  finally
    InternalUnlock;
  end;
end;

Procedure TEServerInfo.IT_SetPathEXE(Value:AnsiString);
begin
  InternalLock;
  try
    FPathEXE:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TEServerInfo.IT_GetMasterGUID:AnsiString;
begin
  InternalLock;
  try
    Result:=FMasterGUID;
  finally
    InternalUnlock;
  end;
end;

Procedure TEServerInfo.IT_SetMasterGUID(Value:AnsiString);
begin
  InternalLock;
  try
    FMasterGUID:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TEServerInfo.IT_GetClients:IEClientsInfo;
begin
  InternalLock;
  try
    Result:=FEClientsInfo;
  finally
    InternalUnlock;
  end;
end;

function TEServerInfo.IT_GetAutorestartCritical:Cardinal;
begin
  InternalLock;
  try
    Result:=FAutorestartCritical;
  finally
    InternalUnlock;
  end;
end;

Procedure TEServerInfo.IT_SetAutorestartCritical(Value:Cardinal);
begin
  InternalLock;
  try
    FAutorestartCritical:=Value;
  finally
    InternalUnlock;
  end;
end;

function TEServerInfo.IT_GetAutorestartNormal:Cardinal;
begin
  InternalLock;
  try
    Result:=FAutorestartNormal;
  finally
    InternalUnlock;
  end;
end;

Procedure TEServerInfo.IT_SetAutorestartNormal(Value:Cardinal);
begin
  InternalLock;
  try
    FAutorestartNormal:=Value;
  finally
    InternalUnlock;
  end;
end;

Procedure TEServerInfo.IT_SetAutorestartNornalPeriod(Value:AnsiString);
  Var tmpV, tmpV1:Variant;
      tmpDateTime:TDateTime;
begin
  InternalLock;
  try
    //12/0(3(1){тип дат периода};7(123123123){дата начала периода};7(123123){дата конца периода};7(123123123){время последнего срабатывания})
    If Value<>'' Then begin
      tmpV:=glStringToVarArray(Value);
      tmpV1:=VarArrayCreate([0, 3], varVariant);
      tmpV1[0]:=Integer(tmpV[0]);
      tmpV1[1]:=TDateTime(tmpV[1]);
      tmpV1[2]:=TDateTime(tmpV[2]);
      tmpV1[3]:=TDateTime(tmpV[3]);
      VarClear(tmpV);
    end else begin
      tmpV1:=VarArrayCreate([0, 3], varVariant);
      tmpV1[0]:=Integer(3);
      tmpDateTime:=37298.1319444;
      tmpV1[1]:=tmpDateTime;
      tmpDateTime:=37298.15625;
      tmpV1[2]:=tmpDateTime;
      tmpDateTime:=0;
      tmpV1[3]:=tmpDateTime;
    end;
    FAutorestartNornalPeriod:=tmpV1;
    VarClear(tmpV1);
  finally
    InternalUnlock;
  end;
end;

Function TEServerInfo.IT_GetAutorestartNornalPeriod:Variant;
begin
  InternalLock;
  try
    Result:=FAutorestartNornalPeriod;
  finally
    InternalUnlock;
  end;
end;

function TEServerInfo.IT_GetAutoKeepStarted:Boolean;
begin
  InternalLock;
  try
    Result:=FAutoKeepStarted;
  finally
    InternalUnlock;
  end;
end;

Procedure TEServerInfo.IT_SetAutoKeepStarted(Value:Boolean);
begin
  InternalLock;
  try
    FAutoKeepStarted:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TEServerInfo.IT_GetProcessInfo:IProcessInfo;
begin
  InternalLock;
  try
    Result:=FIProcessInfo;
  finally
    InternalUnlock;
  end;
end;

Function TEServerInfo.IT_GetAutorestartMessage:AnsiString;
begin
  InternalLock;
  try
    Result:=FAutorestartMessage;
  finally
    InternalUnlock;
  end;
end;

Procedure TEServerInfo.IT_SetAutorestartMessage(Value:AnsiString);
begin
  InternalLock;
  try
    FAutorestartMessage:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TEServerInfo.InternalGetStartedList:Variant;
  Var tmpivHB:Integer;
      tmpIntIndex:Integer;
      tmpIVarsetDataView:IVarsetDataView;
begin
  Result:=Unassigned;
  tmpivHB:=-1;
  tmpIntIndex:=-1;
  while true do begin
    tmpIVarsetDataView:=FPIDList.ITViewNextGetOfIntIndex(tmpIntIndex);
    If tmpIntIndex=-1 then break;
    If tmpivHB<0 then begin
      Result:=VarArrayCreate([0, 0], varVariant);
      tmpivHB:=0;
    end else begin
      VarArrayRedim(Result, tmpivHB+1);
      Inc(tmpivHB);
    end;
    Result[tmpivHB]:=tmpIVarsetDataView.ITData;
  end;
end;

Procedure TEServerInfo.InternalSetStartedList(aVarset:IVarset; Value:Variant);
  Var tmpI:Integer;
begin
  For tmpI:=VarArrayLowBound(Value, 1) to VarArrayHighBound(Value, 1) do begin
    aVarset.ITPushV(VarArrayOf([Value[tmpI][0], Value[tmpI][1]]));
  end;
end;

Function TEServerInfo.IT_GetEServerV:Variant;
 Function lInternalBooleanToInteger(aBoolean:Boolean):Integer;
 begin
   If aBoolean Then result:=0 else result:=-1;
 end;
begin
  InternalLock;
  try                // 0  1         2      3      4                       5                                  6
    Result:=VarArrayOf([0, FRegName, FGuid, FType, InternalGetStartedList, lInternalBooleanToInteger(FValid), FEClientsInfo.ITEClientsV]);
  finally
    InternalUnlock;
  end;
end;

Procedure TEServerInfo.IT_SetEServerV(Value:Variant);
  Var tmpValid:Boolean;
      tmpRegName, tmpGuid:AnsiString;
      tmpType:Integer;
      tmpStartedList:IVarset;
begin
  InternalLock;
  try
    //tmpChecked:=Value[0];
    tmpRegName:=Value[1];
    tmpGuid:=Value[2];
    tmpType:=Value[3];
    tmpStartedList:=TVarset.Create;
    tmpStartedList.ITConfigIntIndexAssignable:=False;
    tmpStartedList.ITConfigCheckUniqueIntIndex:=False;
    tmpStartedList.ITConfigCheckUniqueStrIndex:=False;
    tmpStartedList.ITConfigNoFoundException:=True;
    tmpStartedList.ITConfigCaseSensitive:=False;
    InternalSetStartedList(tmpStartedList, Value[4]);
    tmpValid:=Value[5];
    FEClientsInfo.ITEClientsV:=Value[6];
    //..
    //FChecked:=tmpChecked;
    FRegName:=tmpRegName;
    FGuid:=tmpGuid;
    FType:=tmpType;
    FPIDList.ITAssign(tmpStartedList);
    FValid:=tmpValid;
  finally
    InternalUnlock;
  end;
end;

end.
