//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UBlockSQLTaskManage;

interface
// Format Task BlockSQL ----------------------------------------------------------------
//   Task(varVariant:
//       0:( 0:varInteger or varOleStr or varString:aBlockId
//           1:varVariant:(  0:varInteger: aSQLId;
//                           1:varVariant: ( 0:varOleStr:  aSQL
//                                           1:varBoolean: aRequireOpen
//                                         )
//                          *1:varOleStr: aSQL => aRequireOpen=True;
//                           2:varVariant: ( 0:varVariant: aParams(Input)
//                                           1:varBoolean: aRequireOutputParams
//                                         )
//                          *2:Unassigned: нет входных параметров(aParams=Unassigned) и не требуются выходные(aRequireOutputParams=false).
//                        )
//           2:varVariant:(  0:varInteger: aDateTime.OfLowInt
//                           1:varInteger: aDateTime.OfHiInt
//                        )
//          *2:Unassigned; - Если требуется немедленное выполнение.
//           3:varVariant:aEscortData
//         )
//         ..
//       n:(
//         )
//       )

Type
  TViewBlockOfBlockSQLEvent  = procedure(Const aBlockSQLID:Variant; Const aBlockSQL:Variant; Const aWakeup:Variant)of object;
  TViewBlockSQLEvent         = procedure(Const aBlockSQLID:Variant; aSQLID:Integer; Const aSQL:AnsiString; Const aSQLParams:Variant)of object;

  TCompTime=record
    Case Word of
      0:(ofComp:Comp);     {8 byte}
      1:(ofInt64:Int64);   {8 byte}
      2:(ofLongWordLow:LongWord; ofLongWordHigh:LongWord); {4+4 byte}
      3:(ofIntLow:Integer; ofIntHigh:Integer);             {4+4 byte}
  end;

  TBlockSQLTaskManage=class
  private
    FData, FCurrentBlock:Variant;
    FivHBT, FivHBCB:Integer;
    FNextTimeWakeup:TCompTime;
    FNextTimeRequire:Boolean;
    FOnViewBlockOfBlockSQL:TViewBlockOfBlockSQLEvent;
    FOnViewBlockSQL:TViewBlockSQLEvent;
    procedure Set_Data(Const Value:Variant);
    Function Get_DataCount:Integer;
    Function Get_NextTimeWakeup:Comp;
  public
    constructor Create;
    destructor  Destroy; override;
    Procedure   Clear;
    Procedure   ClearData;
    Procedure   ClearCurrentBlock;
    Procedure   AddSQLToCurrentBlock(aSQLId:Integer; Const aSQL:AnsiString; aRequireOpen:Boolean; Const aParams:Variant; aRequireOutputParams:Boolean);
    Procedure   MoveCurrentBlockToTask(Const aBlockId, aEscortData:Variant);
    Procedure   MoveCurrentBlockToTaskWakeup(Const aBlockId, aEscortData:Variant; aWakeup:Comp);
    Procedure   AddToTask(Const aBlockId, aEscortData:Variant; Const aSQLBlock:Variant);
    Procedure   AddToTaskWakeup(Const aBlockId, aEscortData:Variant; Const aSQLBlock:Variant; aWakeup:Comp);
    Procedure   AddBlockToTask(Const aBlock:Variant; aNextTimeRequire:Boolean=false; aWakeup:Comp=0);
    Procedure   View;
    Property    Data:Variant read FData write Set_Data;
    Property    DataCount:Integer read Get_DataCount;
    Property    CurrentBlock:Variant read FCurrentBlock;
    Property    NextTimeWakeup:Comp read Get_NextTimeWakeup;
    Property    NextTimeRequire:Boolean read FNextTimeRequire;
    Property    OnViewBlockOfBlockSQL:TViewBlockOfBlockSQLEvent read FOnViewBlockOfBlockSQL write FOnViewBlockOfBlockSQL;
    Property    OnViewBlockSQL:TViewBlockSQLEvent read FOnViewBlockSQL write FOnViewBlockSQL;
  end;

implementation
  Uses SysUtils{$ifndef ver130}, Variants{$endif};
constructor TBlockSQLTaskManage.Create;
begin
  FData:=Unassigned;
  FCurrentBlock:=Unassigned;
  FivHBT:=-1;
  FivHBCB:=-1;
  FNextTimeWakeup.ofInt64:=$7fffffffffffffff{максимальное положительное число типа Int64};
  FNextTimeRequire:=False;
  FOnViewBlockOfBlockSQL:=Nil;
  FOnViewBlockSQL:=Nil;
  Inherited Create;
end;

destructor TBlockSQLTaskManage.Destroy;
begin
  Try
    VarClear(FData);
    VarClear(FCurrentBlock);
  Except end;
  Inherited Destroy;
end;

Procedure TBlockSQLTaskManage.ClearData;
begin
  FData:=Unassigned;
  FivHBT:=-1;
  FNextTimeWakeup.ofInt64:=$7fffffffffffffff{максимальное положительное число типа Int64};
  FNextTimeRequire:=False;
end;

Procedure TBlockSQLTaskManage.ClearCurrentBlock;
begin
  FCurrentBlock:=Unassigned;
  FivHBCB:=-1;
end;

Procedure TBlockSQLTaskManage.Clear;
begin
  ClearData;
  ClearCurrentBlock;
end;

Procedure TBlockSQLTaskManage.AddSQLToCurrentBlock(aSQLId:Integer; Const aSQL:AnsiString; aRequireOpen:Boolean; Const aParams:Variant; aRequireOutputParams:Boolean);
  Var ivSQL, ivParams:Variant;
begin
  if (VarType(FCurrentBlock)and varArray)=varArray Then begin
    VarArrayRedim(FCurrentBlock, FivHBCB+1);
    Inc(FivHBCB);
  end else begin
    FCurrentBlock:=VarArrayCreate([0,0], varVariant);
    FivHBCB:=0;
  end;
  If aRequireOpen then begin
    ivSQL:=VarArrayOf([aSQL, aRequireOpen]);
  end else begin
    // Упращенная форма. Оптимизация
    ivSQL:=aSQL;
    // Полния форма - ivSQL:=VarArrayOf([aSQL, aRequireOpen]);
  end;
  try
    If ((VarIsEmpty(aParams))And(aRequireOutputParams=false)) then begin
      // Упращенная форма. Оптимизация. т.е. нет входных параметров и не требуются выходные.
      ivParams:=Unassigned;
    end else begin
      // Полния форма.
      ivParams:=VarArrayOf([aParams, aRequireOutputParams]);
    end;
    try
      FCurrentBlock[FivHBCB]:=VarArrayOf([aSQLId, ivSQL, ivParams]);
    finally
      VarClear(ivParams);
    end;
  finally
    VarClear(ivSQL);
  end;
end;

Procedure   TBlockSQLTaskManage.MoveCurrentBlockToTask(Const aBlockId, aEscortData:Variant);
begin
  If ((VarType(aBlockId)<>varInteger)And(VarType(aBlockId)<>varOleStr)And(VarType(aBlockId)<>varString))Or(VarIsArray(aBlockId)) Then
    Raise Exception.Create('aBlockId is incorrect.');
  if (VarType(FData)and varArray)=varArray Then begin
    VarArrayRedim(FData, FivHBT+1);
    Inc(FivHBT);
  end else begin
    FData:=VarArrayCreate([0,0], varVariant);
    FivHBT:=0;
  end;
  FData[FivHBT]:=VarArrayOf([aBlockId, FCurrentBlock, Unassigned, aEscortData]);
  ClearCurrentBlock;
end;

Procedure   TBlockSQLTaskManage.MoveCurrentBlockToTaskWakeup(Const aBlockId, aEscortData:Variant; aWakeup:Comp);
  Var iWakeup:TCompTime;
begin
  If ((VarType(aBlockId)<>varInteger)And(VarType(aBlockId)<>varOleStr)And(VarType(aBlockId)<>varString))Or(VarIsArray(aBlockId)) Then
    Raise Exception.Create('aBlockId is incorrect.');
  if (VarType(FData)and varArray)=varArray Then begin
    VarArrayRedim(FData, FivHBT+1);
    Inc(FivHBT);
  end else begin
    FData:=VarArrayCreate([0,0], varVariant);
    FivHBT:=0;
  end;
  iWakeup.OfComp:=aWakeup;
  FData[FivHBT]:=VarArrayOf([aBlockId, FCurrentBlock, VarArrayOf([iWakeup.ofIntLow, iWakeup.ofIntHigh]), aEscortData]);
  If FNextTimeWakeup.OfInt64>iWakeup.ofInt64 Then begin
    FNextTimeWakeup.OfInt64:=iWakeup.ofInt64;
    FNextTimeRequire:=True;
  end;
  ClearCurrentBlock;
end;

Procedure   TBlockSQLTaskManage.AddToTask(Const aBlockId, aEscortData:Variant; Const aSQLBlock:Variant);
begin
  If ((VarType(aBlockId)<>varInteger)And(VarType(aBlockId)<>varOleStr)And(VarType(aBlockId)<>varString))Or(VarIsArray(aBlockId)) Then
    Raise Exception.Create('aBlockId is incorrect.');
  if (VarType(FData)and varArray)=varArray Then begin
    VarArrayRedim(FData, FivHBT+1);
    Inc(FivHBT);
  end else begin
    FData:=VarArrayCreate([0,0], varVariant);
    FivHBT:=0;
  end;
  FData[FivHBT]:=VarArrayOf([aBlockId, aSQLBlock, Unassigned, aEscortData]);
end;

Procedure   TBlockSQLTaskManage.AddToTaskWakeup(Const aBlockId, aEscortData:Variant; Const aSQLBlock:Variant; aWakeup:Comp);
  Var iWakeup:TCompTime;
begin
  If ((VarType(aBlockId)<>varInteger)And(VarType(aBlockId)<>varOleStr)And(VarType(aBlockId)<>varString))Or(VarIsArray(aBlockId)) Then
    Raise Exception.Create('aBlockId is incorrect.');
  if (VarType(FData)and varArray)=varArray Then begin
    VarArrayRedim(FData, FivHBT+1);
    Inc(FivHBT);
  end else begin
    FData:=VarArrayCreate([0,0], varVariant);
    FivHBT:=0;
  end;
  iWakeup.OfComp:=aWakeup;
  FData[FivHBT]:=VarArrayOf([aBlockId, aSQLBlock, VarArrayOf([iWakeup.ofIntLow, iWakeup.ofIntHigh]), aEscortData]);
  If FNextTimeWakeup.OfInt64>iWakeup.ofInt64 Then begin
    FNextTimeRequire:=True;
    FNextTimeWakeup.OfInt64:=iWakeup.ofInt64;
  end;
end;

Procedure   TBlockSQLTaskManage.AddBlockToTask(Const aBlock:Variant; aNextTimeRequire:Boolean=false; aWakeup:Comp=0);
  Var iWakeup:TCompTime;
begin
  if (VarType(FData)and varArray)=varArray Then begin
    VarArrayRedim(FData, FivHBT+1);
    Inc(FivHBT);
  end else begin
    FData:=VarArrayCreate([0,0], varVariant);
    FivHBT:=0;
  end;
  If aNextTimeRequire then begin
    FNextTimeRequire:=True;
    iWakeup.OfComp:=aWakeup;
    If FNextTimeWakeup.OfInt64>iWakeup.ofInt64 Then FNextTimeWakeup.OfInt64:=iWakeup.ofInt64;
  end;
  FData[FivHBT]:=aBlock;
end;

procedure TBlockSQLTaskManage.Set_Data(Const Value:Variant);
  Var iI:Integer;
      iNextTimeWakeup:TCompTime;
begin
  Clear;
  FData:=Value;
  If Not VarIsEmpty(Value) Then begin
    FivHBT:=VarArrayHighBound(Value, 1);
    For iI:=0 to FivHBT do begin
      If not VarIsEmpty(FData[iI][2]) then begin
        iNextTimeWakeup.ofIntLow:=Integer(FData[iI][2][0]);
        iNextTimeWakeup.ofIntHigh:=Integer(FData[iI][2][1]);
        If FNextTimeWakeup.OfInt64>iNextTimeWakeup.ofInt64 Then begin
          FNextTimeWakeup.OfInt64:=iNextTimeWakeup.ofInt64;
          FNextTimeRequire:=True;
        end;
      end;
    end;
  end;  
end;

Function TBlockSQLTaskManage.Get_DataCount:Integer;
begin
  result:=FivHBT+1;
end;

Function TBlockSQLTaskManage.Get_NextTimeWakeup:Comp;
begin
  Result:=FNextTimeWakeup.OfComp;
end;

// View ----------------------------------------------------------------------------------

Procedure TBlockSQLTaskManage.View;
  Var iI, iII:Integer;
      tmpBlockSQLID:Integer;
begin
  If FivHBT<0 then exit;
  For iI:=0 to FivHBT do begin
    If Assigned(FOnViewBlockOfBlockSQL) then FOnViewBlockOfBlockSQL(FData[iI][0], FData[iI][1], FData[iI][2]);
    If Assigned(FOnViewBlockSQL) Then begin
      tmpBlockSQLID:=FData[iI][0];
      For iII:=0 to VarArrayHighBound(FData[iI][1], 1) do begin
        FOnViewBlockSQL(tmpBlockSQLID{aBlockSQLID}, FData[iI][1][iII][0]{aSQLID}, FData[iI][1][iII][1]{aSQL}, FData[iI][1][iII][2]{aSQLParams});
      end;
    end;
  end;
end;

end.

