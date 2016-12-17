//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit USecurityUtils;

interface
  uses UCallerTypes, USecurityTypes;
  Function SecurityVarArrayToString(Const aVarArray:Variant{; aUserName:PAnsiString}):AnsiString;
  Function SecurityStringToVarArray(Const aString:AnsiString):Variant;
  Function CompareSecurity(aSecurity1, aSecurity2:ICallerSecurityContext; aEqualLevel:TEqualLevels; aRaise:Boolean):Boolean{equal};

implementation
  uses UStringUtils, UStringConsts, SysUtils, UErrorConsts{$IFNDEF VER130}, Variants{$ENDIF};

Function SecurityVarArrayToString(Const aVarArray:Variant{; aUserName:PAnsiString}):AnsiString;
  Var tmpI:Integer;
begin
  Result:='';
  If VarIsEmpty(aVarArray) Then exit;
  If (Not VarIsArray(aVarArray))Or(VarArrayLowBound(aVarArray, 1)<>0) then Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['aVarArray'], cnerInvalidValueOf);
  for tmpI:=0 to VarArrayHighBound(aVarArray, 1) do begin
    Result:=Result+aVarArray[tmpI]+csParamsStrSeparator;
  end;
  {If Assigned(aUserName) Then aUserName^:=aVarArray[0];}
end;

Function SecurityStringToVarArray(Const aString:AnsiString):Variant;
  Var tmpCurrentPos, tmpivHB:Integer;
      tmpSt:AnsiString;
Begin
  Result:=Unassigned;
  tmpivHB:=-1;
  tmpCurrentPos:=-1;
  While True do begin
    tmpSt:=GetParamFromParamsStr(tmpCurrentPos, aString, csParamsStrSeparator);
    If tmpCurrentPos=-1 Then Break;
    If tmpivHB=-1 then begin
      Result:=VarArrayCreate([0, 0], varOleStr)
    end else begin
      Inc(tmpivHB);
      VarArrayRedim(Result, tmpivHB);
    end;
    Result[tmpivHB]:=tmpSt;
  end;
end;

Function CompareSecurity(aSecurity1, aSecurity2:ICallerSecurityContext; aEqualLevel:TEqualLevels; aRaise:Boolean):Boolean{equal};
begin
  Result:=True;
  if eqlUserName in aEqualLevel then begin
    If AnsiUpperCase(aSecurity1.UserName)<>AnsiUpperCase(aSecurity2.UserName) Then begin
      If aRaise Then Raise Exception.Create('Distinction in a name('+aSecurity1.UserName+'<>'+aSecurity2.UserName+').') else begin
        result:=false;
        exit;
      end;
    end;
  end;
  if eqlRoles in aEqualLevel then begin
    Raise Exception.Create('eqlRoles in aEqualLevel!');
  end;
end;

end.
