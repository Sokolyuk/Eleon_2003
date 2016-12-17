//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UBlockSQLResult;

interface

Type
  TErrorInExecEvent       = procedure(Const aErrMess:AnsiString) of object;
  TErrorInBlockSQLEvent   = procedure(Const aBlockID, aEscortData:Variant; Const aErrMess:AnsiString; Const aSQLID, aArraySQLId:Variant) of object;
  TSuccessInBlockEvent    = procedure(Const aBlockID, aEscortData:Variant) of object;
  TSuccessInBlockSQLEvent = procedure(Const aBlockID, aEscortData:Variant; aSQLID, aRecAff:Integer; Const aParams, aCur:Variant) of object;

  TBlockSQLResult = class
  private
    FCountBlock:Integer;
    FData:Variant;
    FivLB, FivHB:Integer;
    FOnErrorInExec:TErrorInExecEvent;
    FOnErrorInBlockSQL:TErrorInBlockSQLEvent;
    FOnSuccessInBlock:TSuccessInBlockEvent;
    FOnSuccessInBlockSQL:TSuccessInBlockSQLEvent;
    Procedure   InternalCheckData(Const aData:Variant);
    Procedure   Set_Data(Const Value:Variant);
    Function    Get_BlockSQL(Index: Integer):Variant;
  public
    Constructor Create;
    Destructor  Destroy; override;
    Procedure   Exec;
    Property    Data:Variant read FData write Set_Data;
    Property    CountBlock:Integer read FCountBlock;
    Property    BlockSQL[Index:Integer]:Variant read Get_BlockSQL;
    Property    OnErrorInExec:TErrorInExecEvent read FOnErrorInExec write FOnErrorInExec;
    Property    OnErrorInBlockSQL:TErrorInBlockSQLEvent read FOnErrorInBlockSQL write FOnErrorInBlockSQL;
    Property    OnSuccessInBlock:TSuccessInBlockEvent read FOnSuccessInBlock write FOnSuccessInBlock;
    Property    OnSuccessInBlockSQL:TSuccessInBlockSQLEvent read FOnSuccessInBlockSQL write FOnSuccessInBlockSQL;
  end;

implementation
  Uses SysUtils, Variants;

constructor TBlockSQLResult.Create;
begin
  FData:=Unassigned;
  FCountBlock:=0;
  FivLB:=-1; FivHB:=-1;
  Inherited Create;
end;

destructor TBlockSQLResult.Destroy;
begin
  Try VarClear(FData); except end;
  Inherited Destroy;
end;

Procedure  TBlockSQLResult.InternalCheckData(Const aData:Variant);
begin
  // размерность блоков
  If VarIsEmpty(aData) Then begin
    FivLB:=-1;
    FivHB:=-1;
  end else begin
    FivLB:=VarArrayLowBound(aData, 1);
    FivHB:=VarArrayHighBound(aData, 1);
  end;
end;

Procedure  TBlockSQLResult.Set_Data(Const Value:Variant);
begin
  InternalCheckData(Value);
  FData:=Value;
  If VarIsEmpty(Value) Then FCountBlock:=0 else FCountBlock:=FivHB-FivLB+1;
end;


Function   TBlockSQLResult.Get_BlockSQL(Index: Integer):Variant;
begin
  If VarIsEmpty(FData) Then Raise Exception.Create('Нет данных.');
  Result:=FData[Index];
end;

Procedure  TBlockSQLResult.Exec;
  Var iI, iII:Integer;
      tmpV:Variant;
      iBlockID, iEscortData:Variant;
{      st:ansistring;
      tmpVarArrayString:TVarArrayString;}
begin
(*  tmpVarArrayString:=TVarArrayString.Create;
  try
    st:=tmpVarArrayString.VarArrayToString(FData);
    if st='' then ;
  finally
    tmpVarArrayString.free;
  end;*)
  // ..
  If VarIsEmpty(FData) Then Raise Exception.Create('Нет данных.');
  tmpV:=Unassigned;
  try
    For iI:=FivLB to FivHB do begin
      Try
        // Определяю ID блока
        iBlockID:=FData[iI][0];
        Case VarArrayHighBound(FData[iI], 1)-VarArrayLowBound(FData[iI], 1)+1 of
          3:begin
            // Ok
            iEscortData:=FData[iI][2];
            tmpV:=FData[iI][1];
            If (VarType(tmpV)and varArray)<>varArray then Raise Exception.Create('Неизвестный формат BlockSQL(ID='+VarToStr(iBlockID)+').');
            If Assigned(FOnSuccessInBlockSQL) Then begin
              For iII:=VarArrayLowBound(tmpV, 1) to VarArrayHighBound(tmpV, 1) do begin
                FOnSuccessInBlockSQL(iBlockID, iEscortData, tmpV[iII][0], tmpV[iII][1], tmpV[iII][2], tmpV[iII][3]);
              end;
            end;
            If Assigned(FOnSuccessInBlock) Then begin
              FOnSuccessInBlock(iBlockID, iEscortData);
            end;
          end;
          5:begin
            // Err
            If Assigned(FOnErrorInBlockSQL) then begin
              iEscortData:=FData[iI][4];
              FOnErrorInBlockSQL(iBlockID, iEscortData, FData[iI][1], FData[iI][2], FData[iI][3]);
            end;
          end;
        Else
          Raise Exception.Create('Неизвестная размерность BlockSQL(ID='+VarToStr(iBlockID)+').');
        End;
      Except
        // Эта ошибка бывает только если не правильный пакет.
        On E:Exception do begin
          If Assigned(FOnErrorInExec) Then FOnErrorInExec(E.Message) else Raise Exception.Create('Exec: '+E.Message);
        end;
      End;
    end;
  finally
    VarClear(tmpV);
    VarClear(iBlockID);
  end;
end;



end.

