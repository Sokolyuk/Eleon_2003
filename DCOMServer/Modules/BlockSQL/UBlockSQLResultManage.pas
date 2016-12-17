//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UBlockSQLResultManage;

interface
// Format Result BlockSQL ----------------------------------------------------------------
// Result(varVariant:
//       0:Success
//         ( 0:varInteger or varOleStr or varString:aBlockId
//           1:varVariant:(  0:varInteger: aSQLId;
//                           1:varInteger: aRecaff;
//                           2:varVariant: aParams;
//                           3:varVariant: aCur
//                        )
//           2:varVariant: aEscortData
//         )
//       1:Error
//         ( 0:varInteger: aBlockId;
//           1:varOleStr:  aErrMess;
//           2:varInteger: aSQLId;           возможное значение: Unassigned - для неизвестного aSQLId
//           3:varVariant: aArraySqlId;      возможное значение: Unassigned - для неизвестного aArraySQLId
//           4:varVariant: aEscortData;
//         )
//         ..
//       n:(
//         )
//       )

Type
  TBlockSQLResultManage = class
  private
    FResult:Variant;
    FCurrentBlock:Variant;
    FivHBR, FivHBCB:Integer;
  public
    constructor Create;
    destructor  Destroy; override;
    Procedure   Clear;
    Procedure   ClearResult;
    Procedure   ClearCurrentBlock;
    Procedure   AddOkToCurrentBlock(aSQLId, aRecaff:Integer; Const aParams, aCur:Variant);
    Procedure   MoveOkCurrentBlockToResult(Const aBlockId, aEscortData:Variant);
    Procedure   AddErrorBlockSQLToResult(Const aBlockId, aEscortData:Variant; aSQLId:Integer; Const aErrMess:AnsiString; Const aArraySqlId:Variant);
    Procedure   AddErrorBlockToResult(Const aBlockId, aEscortData:Variant; Const aErrMess:AnsiString; Const aArraySqlId:Variant);
    Property    CurrentBlock:Variant read FCurrentBlock;
    Property    Result:Variant read FResult;
  end;

implementation
  Uses SysUtils, Variants;
constructor TBlockSQLResultManage.Create;
begin
  FResult:=Unassigned;
  FCurrentBlock:=Unassigned;
  FivHBR:=-1;
  FivHBCB:=-1;
  Inherited Create;
end;

destructor TBlockSQLResultManage.Destroy;
begin
  Try
    VarClear(FResult);
    VarClear(FCurrentBlock);
  Except end;
  Inherited Destroy;
end;

Procedure TBlockSQLResultManage.ClearResult;
begin
  FResult:=Unassigned;
  FivHBR:=-1;
end;

Procedure TBlockSQLResultManage.ClearCurrentBlock;
begin
  FCurrentBlock:=Unassigned;
  FivHBCB:=-1;
end;

Procedure TBlockSQLResultManage.Clear;
begin
  ClearResult;
  ClearCurrentBlock;
end;

Procedure TBlockSQLResultManage.AddOkToCurrentBlock(aSQLId, aRecaff:Integer; Const aParams, aCur:Variant);
begin
  if (VarType(FCurrentBlock)and varArray)=varArray Then begin
    VarArrayRedim(FCurrentBlock, FivHBCB+1);
    Inc(FivHBCB);
  end else begin
    FCurrentBlock:=VarArrayCreate([0,0], varVariant);
    FivHBCB:=0;
  end;
  FCurrentBlock[FivHBCB]:=VarArrayOf([aSQLId, aRecaff, aParams, aCur]);
end;

Procedure TBlockSQLResultManage.MoveOkCurrentBlockToResult(Const aBlockId, aEscortData:Variant);
begin
  If ((VarType(aBlockId)<>varInteger)And(VarType(aBlockId)<>varOleStr)And(VarType(aBlockId)<>varString))Or(VarIsArray(aBlockId)) Then
    Raise Exception.Create('aBlockId is incorrect.');
  if (VarType(FResult)and varArray)=varArray Then begin
    VarArrayRedim(FResult, FivHBR+1);
    Inc(FivHBR);
  end else begin
    FResult:=VarArrayCreate([0,0], varVariant);
    FivHBR:=0;
  end;
  FResult[FivHBR]:=VarArrayOf([aBlockId, FCurrentBlock, aEscortData]);
  ClearCurrentBlock;
end;

Procedure TBlockSQLResultManage.AddErrorBlockSQLToResult(Const aBlockId, aEscortData:Variant; aSQLId:Integer; Const aErrMess:AnsiString; Const aArraySqlId:Variant);
begin
  If ((VarType(aBlockId)<>varInteger)And(VarType(aBlockId)<>varOleStr)And(VarType(aBlockId)<>varString))Or(VarIsArray(aBlockId)) Then
    Raise Exception.Create('aBlockId is incorrect.');
  if (VarType(FResult)and varArray)=varArray Then begin
    VarArrayRedim(FResult, FivHBR+1);
    Inc(FivHBR);
  end else begin
    FResult:=VarArrayCreate([0,0], varVariant);
    FivHBR:=0;
  end;
  FResult[FivHBR]:=VarArrayOf([aBlockId, aErrMess, aSQLId, aArraySqlId, aEscortData]);
end;

Procedure TBlockSQLResultManage.AddErrorBlockToResult(Const aBlockId, aEscortData:Variant; Const aErrMess:AnsiString; Const aArraySqlId:Variant);
begin
  If ((VarType(aBlockId)<>varInteger)And(VarType(aBlockId)<>varOleStr)And(VarType(aBlockId)<>varString))Or(VarIsArray(aBlockId)) Then
    Raise Exception.Create('aBlockId is incorrect.');
  if (VarType(FResult)and varArray)=varArray Then begin
    VarArrayRedim(FResult, FivHBR+1);
    Inc(FivHBR);
  end else begin
    FResult:=VarArrayCreate([0,0], varVariant);
    FivHBR:=0;
  end;
  FResult[FivHBR]:=VarArrayOf([aBlockId, aErrMess, Unassigned, aArraySqlId, aEscortData]);
end;

end.
