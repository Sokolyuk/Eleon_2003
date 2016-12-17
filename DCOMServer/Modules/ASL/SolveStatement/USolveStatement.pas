//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit USolveStatement;

interface
  uses USolveStatementTypes;

type
  TOperandType = (optInteger, optFloat, optString, optBool, optNull);

  function SolveStatement(var aPos:integer; const aStatement:AnsiString; const aOnGetValue:TOnGetValue):variant;

  function GetOperandType(const aOperand:AnsiString):TOperandType;
  function StrToFloatAlternative(const aFloatString:AnsiString):double;


implementation
  uses {$ifndef ver130}variants,{$endif}UTypeUtils, Sysutils, UStringConsts, UStringUtils;

type
  TTokenType = (tknBracketOpen, tknBracketClose, tknOperatorBigger, tknOperatorBiggerEqual, tknOperatorLess, tknOperatorLessEqual, tknOperatorEqual, tknOperatorNotEqual, tknOperatorAddition, tknOperatorSubtract, tknOperatorDivision, tknOperatorMultiplication, tknAND, tknOR, tknISNULL, tknISNOTNULL, tknIN, tknWord, tknString, tknNumber, tknFloat, tknNOT, tknComma);
  TOperator = (oprBigger, oprBiggerEqual, oprLess, oprLessEqual, oprEqual, oprNotEqual, oprAddition, oprSubtract, oprDivision, oprMultiplication, oprAND, oprOR, oprISNULL, oprISNOTNULL, oprIN);

(*
tknOperatorBigger >
tknOperatorBiggerEqual >=
tknOperatorLess <
tknOperatorLessEqual <=
tknOperatorEqual =
tknOperatorAddition +
tknOperatorSubtract -
tknOperatorDivision /
tknOperatorMultiplication *
*)

function InternalTokenTypeToOperator(aTokenType:TTokenType; out aOperator:TOperator):boolean;
begin
  aOperator := TOperator(integer(aTokenType) - integer(tknOperatorBigger));
  result := not(integer(aOperator) < 0) or (integer(aOperator) > integer(oprIN));
end;

function InternalOperandToOperandType(const aOperand:variant):TOperandType;
  var tmpVarType:{$ifndef ver130}TVarType{$else}word{$endif};
begin
  tmpVarType := VarType(aOperand);

  case tmpVarType of
    varNull:result := optNull;
    varSmallint, varInteger, varByte{$ifndef ver130}, varLongWord, varWord, varShortInt, varInt64{$endif}:begin
      result := optInteger;
    end;
    varSingle, varDouble, varCurrency:begin
      result := optFloat;
    end;
    varOleStr, varString:begin
      result := optString;
    end;
    varBoolean:begin
      result := optBool;
    end;
  else
    raise exception.createfmt(cnUnsupportedType, [IntToStr(tmpVarType)]);
  end;
end;

function InternalSolveOperationTwo(const aOperandLeft:variant; aOperator:TOperator; const aOperandRight:variant):variant;
  var tmpLeftInteger, tmpRightInteger:integer;
      tmpLeftFloat, tmpRightFloat:double;
      tmpLeftString, tmpRightString:AnsiString;
      tmpLeftBoolean, tmpRightBoolean:boolean;
      tmpOperandTypeLeft, tmpOperandTypeRight:TOperandType;
      tmpResultBoolean:Boolean;
      tmpResultInteger:integer;
      tmpResultFloat:double;
      tmpResultString:AnsiString;
begin
  //получаю тип операндов
  tmpOperandTypeLeft := InternalOperandToOperandType(aOperandLeft);
  tmpOperandTypeRight := InternalOperandToOperandType(aOperandRight);

  if ((tmpOperandTypeLeft <> optNull) and (tmpOperandTypeRight <> optNull)) and (tmpOperandTypeLeft <> tmpOperandTypeRight) then raise exception.create(cnInvalidTypeCast);

  if (tmpOperandTypeLeft = optNull) or (tmpOperandTypeRight = optNull) then begin
    case aOperator of
      oprBigger, oprBiggerEqual, oprLess, oprLessEqual, oprEqual, oprNotEqual:begin
        result := false;
      end;
      oprAND, oprOR:begin
        raise exception.createfmt(cnInvalidTypeCastOperation, ['with null']);
      end;
      oprAddition, oprSubtract, oprDivision, oprMultiplication:begin
        result := null;
      end;
    else
      raise exception.createfmt(cnInvalidValueOf, [IntToStr(integer(aOperator)), 'aOperator']);
    end;
  end else begin
    //от warning-ов
    tmpLeftInteger := 0;
    tmpRightInteger := 0;
    tmpLeftFloat := 0;
    tmpRightFloat := 0;
    tmpLeftString := '';
    tmpRightString := '';
    tmpLeftBoolean := false;
    tmpRightBoolean := false;

    //беру значения
    case tmpOperandTypeLeft of
      optInteger:begin
        tmpLeftInteger := aOperandLeft;
        tmpRightInteger := aOperandRight;
      end;
      optFloat:begin
        tmpLeftFloat := aOperandLeft;
        tmpRightFloat := aOperandRight;
      end;
      optString:begin
        tmpLeftString := aOperandLeft;
        tmpRightString := aOperandRight;
      end;
      optBool:begin
        tmpLeftBoolean := aOperandLeft;
        tmpRightBoolean := aOperandRight;
      end;
    else
      raise exception.createfmt(cnUnsupportedType, [IntToStr(integer(tmpOperandTypeLeft))]);
    end;

    //выполняю действие
    case aOperator of
      oprBigger:begin
        case tmpOperandTypeLeft of
          optInteger:begin
            tmpResultBoolean := tmpLeftInteger > tmpRightInteger;
          end;
          optFloat:begin
            tmpResultBoolean := tmpLeftFloat > tmpRightFloat;
          end;
          optString:begin
            tmpResultBoolean := AnsiUpperCase(tmpLeftString) > AnsiUpperCase(tmpRightString);
          end;
          optBool:begin
            tmpResultBoolean := tmpLeftBoolean > tmpRightBoolean;
          end;
        else
          raise exception.createfmt(cnInvalidTypeCastOperation, ['>']);
        end;
        result := tmpResultBoolean;
      end;
      oprBiggerEqual:begin
        case tmpOperandTypeLeft of
          optInteger:begin
            tmpResultBoolean := tmpLeftInteger >= tmpRightInteger;
          end;
          optFloat:begin
            tmpResultBoolean := tmpLeftFloat >= tmpRightFloat;
          end;
          optString:begin
            tmpResultBoolean := AnsiUpperCase(tmpLeftString) >= AnsiUpperCase(tmpRightString);
          end;
          optBool:begin
            tmpResultBoolean := tmpLeftBoolean >= tmpRightBoolean;
          end;
        else
          raise exception.createfmt(cnInvalidTypeCastOperation, ['>=']);
        end;
        result := tmpResultBoolean;
      end;
      oprLess:begin
        case tmpOperandTypeLeft of
          optInteger:begin
            tmpResultBoolean := tmpLeftInteger < tmpRightInteger;
          end;
          optFloat:begin
            tmpResultBoolean := tmpLeftFloat < tmpRightFloat;
          end;
          optString:begin
            tmpResultBoolean := AnsiUpperCase(tmpLeftString) < AnsiUpperCase(tmpRightString);
          end;
          optBool:begin
            tmpResultBoolean := tmpLeftBoolean < tmpRightBoolean;
          end;
        else
          raise exception.createfmt(cnInvalidTypeCastOperation, ['<']);
        end;
        result := tmpResultBoolean;
      end;
      oprLessEqual:begin
        case tmpOperandTypeLeft of
          optInteger:begin
            tmpResultBoolean := tmpLeftInteger <= tmpRightInteger;
          end;
          optFloat:begin
            tmpResultBoolean := tmpLeftFloat <= tmpRightFloat;
          end;
          optString:begin
            tmpResultBoolean := AnsiUpperCase(tmpLeftString) <= AnsiUpperCase(tmpRightString);
          end;
          optBool:begin
            tmpResultBoolean := tmpLeftBoolean <= tmpRightBoolean;
          end;
        else
          raise exception.createfmt(cnInvalidTypeCastOperation, ['<=']);
        end;
        result := tmpResultBoolean;
      end;
      oprEqual:begin
        case tmpOperandTypeLeft of
          optInteger:begin
            tmpResultBoolean := tmpLeftInteger = tmpRightInteger;
          end;
          optFloat:begin
            tmpResultBoolean := tmpLeftFloat = tmpRightFloat;
          end;
          optString:begin
            tmpResultBoolean := AnsiUpperCase(tmpLeftString) = AnsiUpperCase(tmpRightString);
          end;
          optBool:begin
            tmpResultBoolean := tmpLeftBoolean = tmpRightBoolean;
          end;
        else
          raise exception.createfmt(cnInvalidTypeCastOperation, ['=']);
        end;
        result := tmpResultBoolean;
      end;
      oprNotEqual:begin
        case tmpOperandTypeLeft of
          optInteger:begin
            tmpResultBoolean := tmpLeftInteger <> tmpRightInteger;
          end;
          optFloat:begin
            tmpResultBoolean := tmpLeftFloat <> tmpRightFloat;
          end;
          optString:begin
            tmpResultBoolean := AnsiUpperCase(tmpLeftString) <> AnsiUpperCase(tmpRightString);
          end;
          optBool:begin
            tmpResultBoolean := tmpLeftBoolean <> tmpRightBoolean;
          end;
        else
          raise exception.createfmt(cnInvalidTypeCastOperation, ['<>']);
        end;
        result := tmpResultBoolean;
      end;
      oprAND:begin
        case tmpOperandTypeLeft of
          optBool:begin
            tmpResultBoolean := tmpLeftBoolean and tmpRightBoolean;
          end;
        else
          raise exception.createfmt(cnInvalidTypeCastOperation, ['AND']);
        end;
        result := tmpResultBoolean;
      end;
      oprOR:begin
        case tmpOperandTypeLeft of
          optBool:begin
            tmpResultBoolean := tmpLeftBoolean or tmpRightBoolean;
          end;
        else
          raise exception.createfmt(cnInvalidTypeCastOperation, ['OR']);
        end;
        result := tmpResultBoolean;
      end;
      oprAddition:begin
        case tmpOperandTypeLeft of
          optInteger:begin
            tmpResultInteger := tmpLeftInteger + tmpRightInteger;
            result := tmpResultInteger;
          end;
          optFloat:begin
            tmpResultFloat := tmpLeftFloat + tmpRightFloat;
            result := tmpResultFloat;
          end;
          optString:begin
            tmpResultString := tmpLeftString + tmpRightString;
            result := tmpResultString;
          end;
        else
          raise exception.createfmt(cnInvalidTypeCastOperation, ['+']);
        end;
      end;
      oprSubtract:begin
        case tmpOperandTypeLeft of
          optInteger:begin
            tmpResultInteger := tmpLeftInteger - tmpRightInteger;
            result := tmpResultInteger;
          end;
          optFloat:begin
            tmpResultFloat := tmpLeftFloat - tmpRightFloat;
            result := tmpResultFloat;
          end;
        else
          raise exception.createfmt(cnInvalidTypeCastOperation, ['-']);
        end;
      end;
      oprDivision:begin
        case tmpOperandTypeLeft of
          optInteger:begin
            tmpResultFloat := tmpLeftInteger / tmpRightInteger;
            result := tmpResultFloat;
          end;
          optFloat:begin
            tmpResultFloat := tmpLeftFloat / tmpRightFloat;
            result := tmpResultFloat;
          end;
        else
          raise exception.createfmt(cnInvalidTypeCastOperation, ['/']);
        end;
      end;
      oprMultiplication:begin
        case tmpOperandTypeLeft of
          optInteger:begin
            tmpResultInteger := tmpLeftInteger * tmpRightInteger;
            result := tmpResultInteger;
          end;
          optFloat:begin
            tmpResultFloat := tmpLeftFloat * tmpRightFloat;
            result := tmpResultFloat;
          end;
        else
          raise exception.createfmt(cnInvalidTypeCastOperation, ['*']);
        end;
      end;
    else
      raise exception.createfmt(cnInvalidValueOf, [IntToStr(integer(aOperator)), 'aOperator']);
    end;
  end;
end;

function InternalSymbolIsNumber(aSymbol:char):boolean;
begin
  result := (aSymbol = '0') or (aSymbol = '1') or (aSymbol = '2') or (aSymbol = '3') or (aSymbol = '4') or (aSymbol = '5') or (aSymbol = '6') or (aSymbol = '7') or (aSymbol = '8') or (aSymbol = '9');
end;

function InternalSymbolIsNumberDelimiter(aSymbol:char):boolean;
begin
  result := (aSymbol = '.');// or (aSymbol = ',');
end;

procedure InternalSkipNumberical(var aPos:integer; const aStatement:AnsiString; out aIsFloat:boolean);
  var tmpLength:integer;
begin
  tmpLength := Length(aStatement);
  if (aPos>tmpLength) or (aPos<1) then raise exception.createfmt(cnUnsatisfiedStatementTerminated, [aStatement]);
  aIsFloat := false;
  while true do begin
    if (aPos>tmpLength) then break;//если строка кончилась, выхожу
    if InternalSymbolIsNumberDelimiter(aStatement[aPos]) then begin//это точка
      if aIsFloat then break;//вторая точка/запятая в цисле, считаю что это началось следующее число, выхожу
      aIsFloat := true;//первая точка/запятая, ставлю что это float
      inc(aPos);
    end else if InternalSymbolIsNumber(aStatement[aPos]) then begin//это цифра
      inc(aPos);
    end else break;//это что-то иное, выхожу
  end;
end;

function InternalSkipSpace(var aPos:integer; const aStatement:AnsiString):boolean;
  var tmpLength:integer;
begin
  result := false;//если есть еще строка - true, если строка кончилась false
  tmpLength := Length(aStatement);
  while true do begin
    if aPos > tmpLength then break;
    if (aStatement[aPos] <> #9)and
       (aStatement[aPos] <> #32)and
       (aStatement[aPos] <> #13)and
       (aStatement[aPos] <> #10)then begin
      result := true; 
      break;
    end;
    inc(aPos);
  end;
end;

function InternalSymbolIsWord(const aSymbol:char):boolean;
begin
  result := (aSymbol <> #32) and (aSymbol <> #13) and (aSymbol <> #10) and (aSymbol <> #9) and
            (aSymbol <> '(') and (aSymbol <> ')') and (aSymbol <> '<') and (aSymbol <> '>') and
            (aSymbol <> '=') and (aSymbol <> '-') and (aSymbol <> '+') and (aSymbol <> '/') and
            (aSymbol <> '*') and (aSymbol <> '''') and (aSymbol <> ',');
end;

procedure InternalSkipWord(var aPos:integer; const aStatement:AnsiString);
  var tmpLength:integer;
begin
  tmpLength := Length(aStatement);
  if (aPos>tmpLength) or (aPos<1) then raise exception.createfmt(cnUnsatisfiedStatementTerminated, [aStatement]);
  while true do begin
    if (aPos > tmpLength) or (not InternalSymbolIsWord(aStatement[aPos])) then break;
    inc(aPos);
  end;
end;

function InternalWordIsWord(aPos:integer; const aStatement, aWord:AnsiString):boolean;
  var tmpLength:integer;
      tmpLengthWord:integer;
      tmpPosWord:integer;
begin
  tmpLength := Length(aStatement);
  tmpLengthWord := Length(aWord);
  tmpPosWord := 1;

  result := false;
  while true do begin
    if (aPos > tmpLength) or//кончилось aStatement
       (tmpPosWord > tmpLengthWord) or//или кончилось aWord
       (AnsiUpperCase(aStatement[aPos]) <> AnsiUpperCase(aWord[tmpPosWord])) then break;//или несошлись символы

    if (tmpLengthWord = tmpPosWord) and//сошлось все слово
       ((((aPos + 1) <= tmpLength) and (not InternalSymbolIsWord(aStatement[aPos +1]))//и в строке есть следующий символ, и он не продолжение некоторого слова
        ) or (aPos = tmpLength)//или далее нет символов, т.е. слово кончилось
       )then begin
      result := true;//слово сошлось
      break;
    end;
    inc(tmpPosWord);
    inc(aPos);
  end;
end;

function InternalNextToken(var aPos:integer; const aStatement:AnsiString; out aToken:AnsiString; out aTokenType:TTokenType):boolean;
  var tmpNewPos:integer;
      tmpLength:integer;
      tmpIsFloat:boolean;
      tmpToken:AnsiString;
      tmpTokenType:TTokenType;
      tmpIsNotType:boolean;
begin
  //если есть еще строка - true, если строка кончилась false
  try
    tmpLength := Length(aStatement);
    aToken := '';//чищу, от warning-ов //if (tmpNewPos > tmpLength) or (tmpNewPos < 1) then raise exception.createfmt(cnInvalidValueOf, [IntToStr(tmpNewPos), 'aPos']);
    result := InternalSkipSpace(aPos, aStatement);
    tmpNewPos := aPos;
    if result then begin//строка не кончилась
      if aStatement[tmpNewPos] = '(' then begin
        aTokenType := tknBracketOpen;
        aToken := aStatement[tmpNewPos];
        inc(tmpNewPos);
      end else if aStatement[tmpNewPos] = ')' then begin
        aTokenType := tknBracketClose;
        aToken := aStatement[tmpNewPos];
        inc(tmpNewPos);
      end else if ((tmpNewPos + 1) <= tmpLength)and//'>='
                  (AnsiUpperCase(aStatement[tmpNewPos]) = '>')and
                  (AnsiUpperCase(aStatement[tmpNewPos + 1]) = '=') then begin
        aTokenType := tknOperatorBiggerEqual;
        tmpNewPos := tmpNewPos + 2;
        aToken := copy(aStatement, aPos, tmpNewPos - aPos);
      end else if aStatement[tmpNewPos] = '>' then begin//'>'
        aTokenType := tknOperatorBigger;
        aToken := aStatement[tmpNewPos];
        inc(tmpNewPos);
      end else if ((tmpNewPos + 1) <= tmpLength) and//'<='
                  (aStatement[tmpNewPos] = '<')and
                  (aStatement[tmpNewPos + 1] = '=') then begin
        aTokenType := tknOperatorLessEqual;
        tmpNewPos := tmpNewPos + 2;
        aToken := copy(aStatement, aPos, tmpNewPos - aPos);
      end else if ((tmpNewPos + 1) <= tmpLength) and//'<>'
                  (aStatement[tmpNewPos] = '<')and
                  (aStatement[tmpNewPos + 1] = '>') then begin
        aTokenType := tknOperatorNotEqual;
        tmpNewPos := tmpNewPos + 2;
        aToken := copy(aStatement, aPos, tmpNewPos - aPos);
      end else if aStatement[tmpNewPos] = '<' then begin//'<'
        aTokenType := tknOperatorLess;
        aToken := aStatement[tmpNewPos];
        inc(tmpNewPos);
      end else if aStatement[tmpNewPos] = '=' then begin
        aTokenType := tknOperatorEqual;
        aToken := aStatement[tmpNewPos];
        inc(tmpNewPos);
      end else if aStatement[tmpNewPos] = '+' then begin
        aTokenType := tknOperatorAddition;
        aToken := aStatement[tmpNewPos];
        inc(tmpNewPos);
      end else if (aStatement[tmpNewPos] = '-')then begin
        aTokenType := tknOperatorSubtract;
        aToken := aStatement[tmpNewPos];
        inc(tmpNewPos);
      end else if aStatement[tmpNewPos] = '/' then begin
        aTokenType := tknOperatorDivision;
        aToken := aStatement[tmpNewPos];
        inc(tmpNewPos);
      end else if aStatement[tmpNewPos] = '*' then begin
        aTokenType := tknOperatorMultiplication;
        aToken := aStatement[tmpNewPos];
        inc(tmpNewPos);
      end else if aStatement[tmpNewPos] = ',' then begin
        aTokenType := tknComma;
        aToken := aStatement[tmpNewPos];
        inc(tmpNewPos);
      end else if aStatement[tmpNewPos] = '''' then begin
        aTokenType := tknString;
        SkipString(tmpNewPos, aStatement);
        aToken := SqlToStr(copy(aStatement, aPos + 1, tmpNewPos - aPos - 2));
      end else if (InternalSymbolIsNumber(aStatement[tmpNewPos]))or//'12345' или 123,45
                  (InternalSymbolIsNumberDelimiter(aStatement[tmpNewPos])) then begin
        InternalSkipNumberical(tmpNewPos, aStatement, tmpIsFloat);
        aToken := copy(aStatement, aPos, tmpNewPos - aPos);
        if tmpIsFloat then aTokenType := tknFloat else aTokenType := tknNumber;
      end else if InternalWordIsWord(tmpNewPos, aStatement, 'AND') then begin
        aTokenType := tknAND;
        tmpNewPos := tmpNewPos + 3;
        aToken := copy(aStatement, aPos, tmpNewPos - aPos);
      end else if InternalWordIsWord(tmpNewPos, aStatement, 'OR') then begin
        aTokenType := tknOR;
        tmpNewPos := tmpNewPos + 2;
        aToken := copy(aStatement, aPos, tmpNewPos - aPos);
      end else if InternalWordIsWord(tmpNewPos, aStatement, 'NOT') then begin
        aTokenType := tknNOT;
        tmpNewPos := tmpNewPos + 3;
        aToken := copy(aStatement, aPos, tmpNewPos - aPos);
      end else if InternalWordIsWord(tmpNewPos, aStatement, 'IN') then begin
        aTokenType := tknIN;
        tmpNewPos := tmpNewPos + 2;
        aToken := copy(aStatement, aPos, tmpNewPos - aPos);
      end else if InternalWordIsWord(tmpNewPos, aStatement, 'IS') then begin
        InternalSkipWord(tmpNewPos, aStatement);
        if not InternalNextToken(tmpNewPos, aStatement, tmpToken, tmpTokenType) then raise exception.createfmt(cnUnsatisfiedStatementTerminated, [aStatement]);

        tmpIsNotType := (tmpTokenType = tknNOT);
        if tmpIsNotType then begin
          if not InternalNextToken(tmpNewPos, aStatement, tmpToken, tmpTokenType) then raise exception.createfmt(cnUnsatisfiedStatementTerminated, [aStatement]);
        end else begin
          if (tmpTokenType <> tknWord) or (AnsiUpperCase(tmpToken) <> 'NULL') then raise exception.createfmt(cnInvalidStatement, [tmpToken]);
        end;

        if (tmpTokenType = tknWord) and (AnsiUpperCase(tmpToken) = 'NULL') then begin
          if tmpIsNotType then aTokenType := tknISNOTNULL else aTokenType := tknISNULL;
          aToken := copy(aStatement, aPos, tmpNewPos - aPos);
        end else begin
          raise exception.createfmt(cnInvalidStatement, [tmpToken]);
        end;
      end else begin
        aTokenType := tknWord;
        InternalSkipWord(tmpNewPos, aStatement);
        aToken := copy(aStatement, aPos, tmpNewPos - aPos);
      end;
    end;
    aPos := tmpNewPos;
  except on e:exception do begin
    e.message:= 'NextToken: ' + e.message;
    raise;
  end;end;
end;

function StrToFloatAlternative(const aFloatString:AnsiString):double;
  var tmpLength:integer;
      tmpPos:integer;
      tmpFloatString:AnsiString;
begin
  //обхожу локальные установни системы для разделителя вещественного числа
  try
    result := StrToFloat(aFloatString);
  except
    tmpLength := Length(aFloatString);
    tmpPos := 1;
    tmpFloatString := '';
    while true do begin
      if tmpPos > tmpLength then break;
      if aFloatString[tmpPos] = '.' then begin
        tmpFloatString := tmpFloatString + ',';
      end else if aFloatString[tmpPos] = ',' then begin
        tmpFloatString := tmpFloatString + '.';
      end else tmpFloatString := tmpFloatString + aFloatString[tmpPos];
      inc(tmpPos);
    end;
    result := StrToFloat(tmpFloatString);
  end;
end;

function InternalGetPropertyValue(const aName:AnsiString; const aOnGetValue:TOnGetValue):variant;
begin
  if AnsiUpperCase(aName) = 'FALSE' then begin
    result := false;
  end else if AnsiUpperCase(aName) = 'TRUE' then begin
    result := true;
  end else if assigned(aOnGetValue.aOnProperty) then begin
    result := aOnGetValue.aOnProperty(aName);
  end else if assigned(aOnGetValue.aOnPropertyRegular) then begin
    result := aOnGetValue.aOnPropertyRegular(aOnGetValue.aUserDataRegular, aName);
  end else raise exception.createfmt(cnValueNotAssigned, ['aOnProperty for ' + aName]);
end;

function InternalGetFunctionValue(const aName:AnsiString; const aParams:variant; const aOnGetValue:TOnGetValue):variant;
begin
  if assigned(aOnGetValue.aOnFunction) then begin
    result := aOnGetValue.aOnFunction(aName, aParams);
  end else if assigned(aOnGetValue.aOnFunctionRegular) then begin
    result := aOnGetValue.aOnFunctionRegular(aOnGetValue.aUserDataRegular, aName, aParams);
  end else raise exception.createfmt(cnValueNotAssigned, ['aOnFunction for ' + aName]);
end;

function InternalGetStatementFromBrackets(var aPos:integer; const aStatement:AnsiString):AnsiString;
  var tmpToken:AnsiString;
      tmpTokenType:TTokenType;
      tmpPosOld:integer;
      tmpDepth:integer;
begin
  tmpPosOld := aPos;
  tmpDepth := 1;
  while true do begin
    if not InternalNextToken(aPos, aStatement, tmpToken, tmpTokenType) then raise exception.createfmt(cnUnsatisfiedStatementTerminated, [aStatement]);
    case tmpTokenType of
      tknBracketOpen:inc(tmpDepth);//увеличивается вложенность
      tknBracketClose:dec(tmpDepth);//уменьшается вложенность
    end;
    if tmpDepth = 0 then break;//нашел свою закрывающую скобку
  end;
  result := copy(aStatement, tmpPosOld, aPos - tmpPosOld - 1);//-1 чтобы убрать закрывающую скобку
end;

function InternalGetSolvedNextOperand(var aPos:integer; const aStatement:AnsiString; out aOperand:variant; const aOnGetValue:TOnGetValue):boolean;forward;

function InternalGetSolvedParamsArray(var aPos:integer; const aStatement:AnsiString; const aOnGetValue:TOnGetValue):variant;
  var tmpOperand:variant;
      tmpHB:integer;
      tmpToken:AnsiString;
      tmpTokenType:TTokenType;
begin
  tmpHB := -1;
  result := unassigned;
  while InternalGetSolvedNextOperand(aPos, aStatement, tmpOperand, aOnGetValue) do begin
    if tmpHB = -1 then begin
      result :=VarArrayCreate([0, 0], varVariant);
      tmpHB := 0;
    end else begin
      inc(tmpHB);
      VarArrayRedim(result, tmpHB);
    end;
    result[tmpHB] := tmpOperand;

    if not InternalNextToken(aPos, aStatement, tmpToken, tmpTokenType) then break;
    if tmpTokenType <> tknComma then raise exception.createfmt(cnInvalidStatement, [tmpToken]);
  end;
end;

function InternalGetSolvedNextOperand(var aPos:integer; const aStatement:AnsiString; out aOperand:variant; const aOnGetValue:TOnGetValue):boolean;
  var tmpToken:AnsiString;
      tmpTokenOld:AnsiString;
      tmpTokenType:TTokenType;
      tmpPosNew:integer;
      tmpOperand:variant;
      tmpBoolean:boolean;
      tmpInteger:integer;
      tmpFloat:double;
      tmpOperandType:TOperandType;
begin
  try
    if InternalNextToken(aPos, aStatement, tmpToken, tmpTokenType) then begin
      case tmpTokenType of
        //обрабатываю вложенные скобки
        tknBracketOpen:begin
          tmpPosNew := 1;
          aOperand := SolveStatement(tmpPosNew, InternalGetStatementFromBrackets(aPos, aStatement), aOnGetValue);
        end;
        tknNOT:begin
          //если не нужен левый операнд
          if not InternalGetSolvedNextOperand(aPos, aStatement, tmpOperand, aOnGetValue) then raise exception.createfmt(cnUnsatisfiedStatementTerminated, [aStatement]);
          if VarType(tmpOperand) <> varBoolean then raise exception.createfmt(cnInvalidTypeCastForStatement, [tmpToken]);
          tmpBoolean := tmpOperand;
          aOperand := not tmpBoolean;
        end;
        tknWord:begin
          tmpTokenOld := tmpToken;
          tmpPosNew := aPos;
          if (InternalNextToken(aPos, aStatement, tmpToken, tmpTokenType)) and (tmpTokenType = tknBracketOpen) then begin
            //есть открывающаяся скобка после слова, значит это функция
            tmpPosNew := 1;
            aOperand := InternalGetFunctionValue(tmpTokenOld, InternalGetSolvedParamsArray(tmpPosNew, InternalGetStatementFromBrackets(aPos, aStatement), aOnGetValue), aOnGetValue);
          end else begin
            //это проперти
            aPos := tmpPosNew;
            aOperand := InternalGetPropertyValue(tmpTokenOld, aOnGetValue);
          end;
        end;
        tknString:begin
          aOperand := tmpToken;
        end;
        tknNumber:begin
          tmpInteger := StrToInt(tmpToken);
          aOperand := tmpInteger;
        end;
        tknFloat:begin
          tmpFloat := StrToFloatAlternative(tmpToken);
          aOperand := tmpFloat;
        end;
        tknOperatorSubtract:begin
          //поддержка отрицательного значения
          if not InternalGetSolvedNextOperand(aPos, aStatement, tmpOperand, aOnGetValue) then raise exception.createfmt(cnUnsatisfiedStatementTerminated, [aStatement]);
          tmpOperandType := InternalOperandToOperandType(tmpOperand);
          case tmpOperandType of
            optInteger:begin
              tmpInteger := - tmpOperand;
              aOperand := tmpInteger;
            end;
            optFloat:begin
              tmpFloat := - tmpOperand;
              aOperand := tmpFloat;
            end;
          else
            raise exception.createfmt(cnInvalidStatement, [tmpToken]);
          end;
        end;
      else
        raise exception.createfmt(cnInvalidStatement, [tmpToken]);
      end;
      result := true;
    end else begin
      result := false;
    end;
  except on e:exception do begin
    e.message:= 'GetSolvedNextOperand: ' + e.message;
    raise;
  end;end;
end;

function InternalGetOperator(var aPos:integer; const aStatement:AnsiString; out aOperator:TOperator):boolean;
  var tmpToken:AnsiString;
      tmpTokenType:TTokenType;
begin
  if InternalNextToken(aPos, aStatement, tmpToken, tmpTokenType) then begin
    case tmpTokenType of
      tknOperatorBigger, tknOperatorBiggerEqual, tknOperatorLess, tknOperatorLessEqual, tknOperatorEqual, tknOperatorNotEqual,
      tknOperatorAddition, tknOperatorSubtract, tknOperatorDivision, tknOperatorMultiplication, tknAND, tknOR, tknISNULL, tknISNOTNULL, tknIN:begin
        if not InternalTokenTypeToOperator(tmpTokenType, aOperator) then raise exception.createfmt(cnInvalidStatement, [tmpToken]);
      end;
    else
      raise exception.createfmt(cnInvalidStatement, [tmpToken]);
    end;
    result := true;
  end else begin
    result := false;
  end;
end;

function InternalSolveOperatorIN(const aLeftOperand:variant; const aParamsArray:variant):boolean;
  var tmpI:integer;
begin
  result := false;
  if VarIsArray(aParamsArray) then begin
    for tmpI := VarArrayLowBound(aParamsArray, 1) to VarArrayHighBound(aParamsArray, 1) do begin
      result := result or InternalSolveOperationTwo(aLeftOperand, oprEqual, aParamsArray[tmpI]);
      if result then break;
    end;
  end;
end;

function SolveStatement(var aPos:integer; const aStatement:AnsiString; const aOnGetValue:TOnGetValue):variant;
  var tmpLeftOperand:variant;
      tmpRightOperand:variant;
      tmpOperator:TOperator;
      tmpBoolean:boolean;
      tmpPosNew:integer;
      tmpToken:AnsiString;
      tmpTokenType:TTokenType;
begin
  try
    if InternalGetSolvedNextOperand(aPos, aStatement, tmpLeftOperand, aOnGetValue) then begin
      while true do begin
        if not InternalGetOperator(aPos, aStatement, tmpOperator) then break;

        case tmpOperator of
          //если не нужен правый операнд
          oprISNULL:begin
            tmpBoolean := VarIsNull(tmpLeftOperand);
            tmpLeftOperand := tmpBoolean;
            continue;
          end;
          oprISNOTNULL:begin
            tmpBoolean := not VarIsNull(tmpLeftOperand);
            tmpLeftOperand := tmpBoolean;
            continue;
          end;
          oprIN:begin
            if (not InternalNextToken(aPos, aStatement, tmpToken, tmpTokenType)) or (tmpTokenType <> tknBracketOpen) then raise exception.createfmt(cnInvalidStatement, [tmpToken]);
            tmpPosNew := 1;
            tmpLeftOperand := InternalSolveOperatorIN(tmpLeftOperand, InternalGetSolvedParamsArray(tmpPosNew, InternalGetStatementFromBrackets(aPos, aStatement), aOnGetValue));
            continue;
          end;
        else
          if not InternalGetSolvedNextOperand(aPos, aStatement, tmpRightOperand, aOnGetValue) then raise exception.createfmt(cnUnsatisfiedStatementTerminated, [aStatement]);
          tmpLeftOperand := InternalSolveOperationTwo(tmpLeftOperand, tmpOperator, tmpRightOperand);

          //tmpPosNew := aPos;
          //если нужны все операнды
          //InternalGetSolvedNextOperand(tmpPosNew, aStatement, tmpRightOperand, aOnGetValue);

          //if (VarType(tmpLeftOperand) = varBoolean) and//левый bool
          //   (VarType(tmpRightOperand) <> varBoolean) and//правый не bool
          //   ((tmpOperator = oprAND) or (tmpOperator = oprOR))then begin//а оператор AND или OR
          //  1
          //end else begin
            //"складываю" все операнды подряд
            //tmpLeftOperand := InternalSolveOperationTwo(tmpLeftOperand, tmpOperator, tmpRightOperand);
          //end;
        end;
      end;
    end;

    result := tmpLeftOperand;
  except on e:exception do begin
    e.message:= 'SolveStatement: ' + e.message;
    raise;
  end;end;
end;

function GetOperandType(const aOperand:AnsiString):TOperandType;
  var tmpLength:integer;
      tmpPos:integer;
begin
  if aOperand = '' then raise exception.createfmt(cnInvalidValueOfOperand, ['', 'aOperand']);
  tmpLength := Length(aOperand);

  if aOperand[1] = '''' then begin
    tmpPos := 1;
    SkipString(tmpPos, aOperand);
    if tmpPos <> (tmpLength + 1) then raise exception.createfmt(cnInvalidValueOfOperand, [aOperand, 'aOperand']);
    result := optString;
  end else if AnsiUpperCase(aOperand) = 'NULL' then begin
    result := optNull;
  end else if (AnsiUpperCase(aOperand) = 'FALSE') or (AnsiUpperCase(aOperand) = 'TRUE') then begin
    result := optBool;
  end else if Pos('.', aOperand) <> 0 then begin
    result := optFloat;
  end else result := optInteger;
end;

end.
