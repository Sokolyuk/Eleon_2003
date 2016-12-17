//Copyright © 2000-2004 by Dmitry A. Sokolyuk

//21.05.2004
//Application script laguage
unit UASLSolveStatement;

interface
  uses UTokenParser, UASLSolveStatementTypes, UTokenParserTypes;

type

  //Класс решает выражение
  TASLSolveStatement = class(TTokenParser)
  protected
    function InternalUnwrapUserdata(const aASLSolveStatementEvents:TASLSolveStatementEvents):pointer;virtual;
    function InternalSolveStatement(const aASLSolveStatementEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aStatement:AnsiString):variant;
    function InternalGetSolvedNextOperand(const aASLSolveStatementEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aStatement:AnsiString; out aOperand:variant; aPLocalParamsArrayOutAdd:PLocalParamsArrayOutAdd):boolean;virtual;
    function InternalGetOperator(var aPos:integer; aPosTo:integer; const aStatement:AnsiString; out aOperator:TOperator):boolean;virtual;
    procedure InternalInternalSkipBracketsFrom(var aPos:integer; aPosTo:integer; const aStatement:AnsiString; aPIdTokenOpen:TPIdToken; aIdTokenClose:TIdToken);virtual;
    procedure InternalSkipBracketsFrom(var aPos:integer; aPosTo:integer; const aStatement:AnsiString; aIdTokenOpen, aIdTokenClose:TIdToken);virtual;
    procedure InternalSkipBracketsTo(var aPos:integer; aPosTo:integer; const aStatement:AnsiString; aIdTokenClose:TIdToken);virtual;
    function InternalSolveOperatorIN(const aLeftOperand:variant; const aParamsArray:variant):boolean;virtual;
    function InternalGetSolvedParamsArrayIn(const aASLSolveStatementEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aStatement:AnsiString):Variant;virtual;
    function InternalGetSolvedParamsArrayInOut(const aASLSolveStatementEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aStatement:AnsiString):TFunctionParam;virtual;
    function InternalInternalGetSolvedParamsArrayInOut(const aASLSolveStatementEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aStatement:AnsiString; aNeedOut:boolean):TFunctionParam;virtual;
    function InternalSolveOperationTwo(const aOperandLeft:variant; aOperator:TOperator; const aOperandRight:variant):variant;virtual;
    function InternalGetCurrTokenFunction(const aASLSolveStatementEvents:TASLSolveStatementEvents; const aToken: AnsiString; aIdToken: TIdToken; var aPos:integer; aPosTo:integer; const aStatement:AnsiString; out aFunctionName:AnsiString; out aFunctionSolvedParamsArray:TFunctionParam; out aIsSubFunction:boolean; aRaise:boolean):boolean;virtual;
    function InternalGetFunctionValue(const aASLSolveStatementEvents:TASLSolveStatementEvents; const aName:AnsiString; aFunctionParam:TFunctionParam; aIsSubFunction:boolean):variant;virtual;
    function InternalGetCurrTokenProperty(const aASLSolveStatementEvents:TASLSolveStatementEvents; const aToken: AnsiString; aIdToken: TIdToken; var aPos:integer; aPosTo:integer; const aStatement:AnsiString; out aName:AnsiString; out aIndex:variant; out aIsOut:boolean; aRaise:boolean):boolean;virtual;
    procedure InternalSetPropertyValue(const aASLSolveStatementEvents:TASLSolveStatementEvents; const aName:AnsiString; const aPropertyIndex:variant; const aValue:variant);virtual;
    function InternalGetPropertyValue(const aASLSolveStatementEvents:TASLSolveStatementEvents; const aName:AnsiString; const aPropertyIndex:variant):variant;virtual;
    function StrToFloatAlternative(const aFloatString:AnsiString):double;virtual;
    function InternalOperandToOperandType(const aOperand:variant):TOperandType;virtual;
    function InternalIdTokenToOperator(aIdToken:TIdToken; out aOperator:TOperator):boolean;virtual;
    function OperandTypeToOperandTypeName(aOperandType:TOperandType):AnsiString;virtual;
  public
    function SolveStatement(const aASLSolveStatementEvents:TASLSolveStatementEvents; const aStatement: AnsiString):variant;virtual;
  public
    constructor create();
    destructor destroy();override;
  end;


implementation
  uses UStringConsts, Sysutils{$ifndef ver130}, variants{$endif};

constructor TASLSolveStatement.create();
begin
  inherited create();

  //добавляю комментарии
  CommentaryAdd('//', #13);
  CommentaryAdd('/*', '*/');

  //добавляю teken-ы
  TokenAdd('<>', cardinal(tknOperatorNotEqual), true);
  TokenAdd('>=', cardinal(tknOperatorBiggerEqual), true);
  TokenAdd('<=', cardinal(tknOperatorLessEqual), true);
  TokenAdd('==', cardinal(tknOperatorEqual), true);
  TokenAdd('!=', cardinal(tknOperatorNotEqual), true);
  TokenAdd('||', cardinal(tknOR), true);
  TokenAdd('&&', cardinal(tknAND), true);

  TokenAdd('(', cardinal(tknBracketOpen), true);
  TokenAdd(')', cardinal(tknBracketClose), true);
  TokenAdd('>', cardinal(tknOperatorBigger), true);
  TokenAdd('<', cardinal(tknOperatorLess), true);
  TokenAdd('=', cardinal(tknOperatorEqual), true);
  TokenAdd('+', cardinal(tknOperatorAddition), true);
  TokenAdd('-', cardinal(tknOperatorSubtract), true);
  TokenAdd('/', cardinal(tknOperatorDivision), true);
  TokenAdd('*', cardinal(tknOperatorMultiplication), true);
  TokenAdd('!', cardinal(tknNOT), true);
  TokenAdd(',', cardinal(tknComma), true);
  TokenAdd(';', cardinal(tknDotWithComma), true);
  TokenAdd('{', cardinal(tknFigureBracketOpen), true);
  TokenAdd('}', cardinal(tknFigureBracketClose), true);
  TokenAdd('[', cardinal(tknSquareBracketOpen), true);
  TokenAdd(']', cardinal(tknSquareBracketClose), true);
  
  TokenAdd('AND', cardinal(tknAND), false);
  TokenAdd('OR', cardinal(tknOR), false);
  TokenAdd('IS NULL', cardinal(tknISNULL), false);
  TokenAdd('IS NOT NULL', cardinal(tknISNOTNULL), false);
  TokenAdd('IN', cardinal(tknIN), false);
  TokenAdd('NOT', cardinal(tknNOT), false);
  TokenAdd('OUT', cardinal(tknOut), false);
  TokenAdd('IF', cardinal(tknIf), false);
  TokenAdd('ELSE', cardinal(tknElse), false);
  TokenAdd('EXECUTE', cardinal(tknExec), false);
  TokenAdd('EXEC', cardinal(tknExec), false);
end;

destructor TASLSolveStatement.destroy();
begin
  inherited destroy();
end;

function TASLSolveStatement.InternalSolveStatement(const aASLSolveStatementEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aStatement:AnsiString):variant;
  var tmpLeftOperand:variant;
      tmpRightOperand:variant;
      tmpOperator:TOperator;
      tmpBoolean:boolean;
      tmpPosNew:integer;
      tmpToken:AnsiString;
      tmpIdToken:TIdToken;
begin
  try
    if InternalGetSolvedNextOperand(aASLSolveStatementEvents, aPos, aPosTo, aStatement, tmpLeftOperand, nil) then begin
      while true do begin
        if not InternalGetOperator(aPos, aPosTo, aStatement, tmpOperator) then break;

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
            if (not TokenNext(aPos, aPosTo, aStatement, @tmpToken, @tmpIdToken)) or (tmpIdToken <> tknBracketOpen) then raise exception.createfmt(cnInvalidStatement, [tmpToken]);
            tmpPosNew := aPos;//запоминаю поз. откр. скобки
            InternalSkipBracketsFrom(aPos, aPosTo, aStatement, tknBracketOpen, tknBracketClose);//устанавливаюсь на поз. закр. скобки
            tmpLeftOperand := InternalSolveOperatorIN(tmpLeftOperand, InternalGetSolvedParamsArrayIn(aASLSolveStatementEvents, tmpPosNew, aPos - 2, aStatement));//после прокрутки курсок стоит на первой позиции следующего элемента, значит чтобы использв. это значение для ограничения скобки убираем -1(встаем на последний элемент своего блока) и еще раз -1(убираем закрывающеюся скобку) итого -2)
            continue;
          end;
          //oprSet:begin//!
          //  1
          //  set @tmpA = 33
          //  continue;
          //end;
        else
          if not InternalGetSolvedNextOperand(aASLSolveStatementEvents, aPos, aPosTo, aStatement, tmpRightOperand, nil) then raise exception.createfmt(cnUnsatisfiedStatementTerminated, [aStatement]);
          tmpLeftOperand := InternalSolveOperationTwo(tmpLeftOperand, tmpOperator, tmpRightOperand);

          //tmpPosNew := aPos;
          //если нужны все операнды
          //InternalGetSolvedNextOperand(tmpPosNew, aStatement, tmpRightOperand, aOnValue);

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
    //e.message:= 'SolveStatement: ' + e.message;
    raise;
  end;end;
end;

function TASLSolveStatement.SolveStatement(const aASLSolveStatementEvents:TASLSolveStatementEvents; const aStatement:AnsiString):variant;
  var tmpPos: integer;
begin
  tmpPos := 1;
  result := InternalSolveStatement(aASLSolveStatementEvents, tmpPos, length(aStatement), aStatement);
end;

function TASLSolveStatement.InternalGetSolvedNextOperand(const aASLSolveStatementEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aStatement:AnsiString; out aOperand:variant; aPLocalParamsArrayOutAdd:PLocalParamsArrayOutAdd):boolean;
  var tmpToken:AnsiString;
      tmpIdToken:TIdToken;
      tmpOperand:variant;
      tmpBoolean:boolean;
      tmpInteger:integer;
      tmpFloat:double;
      tmpOperandType:TOperandType;
      tmpPropertyIndex: variant;
      tmpFunctionSolvedParamsArray: TFunctionParam;
      tmpPosBracketOpen: integer;
      tmpFunctionName, tmpPropertyName: AnsiString;
      tmpIsSubFunction, tmpPropertyIsOut: boolean;
begin
  try
    if TokenNext(aPos, aPosTo, aStatement, @tmpToken, @tmpIdToken) then begin
      case tmpIdToken of
        //обрабатываю вложенные скобки
        tknBracketOpen:begin
          tmpPosBracketOpen := aPos;//запоминаю откр. скобки
          InternalSkipBracketsFrom(aPos, aPosTo, aStatement, tknBracketOpen, tknBracketClose);//позицианируюсь на закр. скобку

          aOperand := InternalSolveStatement(aASLSolveStatementEvents, tmpPosBracketOpen, aPos - 2, aStatement);//после прокрутки курсок стоит на первой позиции следующего элемента, значит чтобы использв. это значение для ограничения скобки убираем -1(встаем на последний элемент своего блока) и еще раз -1(убираем закрывающеюся скобку) итого -2)
        end;
        tknNOT:begin
          //если не нужен левый операнд
          if not InternalGetSolvedNextOperand(aASLSolveStatementEvents, aPos, aPosTo, aStatement, tmpOperand, nil) then raise exception.createfmt(cnUnsatisfiedStatementTerminated, [aStatement]);
          if VarType(tmpOperand) <> varBoolean then raise exception.createfmt(cnInvalidTypeCastForStatement, [tmpToken]);
          tmpBoolean := tmpOperand;
          aOperand := not tmpBoolean;
        end;
        tknWord, tknExec:begin
          if InternalGetCurrTokenFunction(aASLSolveStatementEvents, tmpToken, tmpIdToken, aPos, aPosTo, aStatement, tmpFunctionName, tmpFunctionSolvedParamsArray, tmpIsSubFunction, false) then begin
            //это функция
            aOperand := InternalGetFunctionValue(aASLSolveStatementEvents, tmpFunctionName, tmpFunctionSolvedParamsArray, tmpIsSubFunction);
          end else if InternalGetCurrTokenProperty(aASLSolveStatementEvents, tmpToken, tmpIdToken, aPos, aPosTo, aStatement, tmpPropertyName, tmpPropertyIndex, tmpPropertyIsOut, false) then begin
            //это проперти
            if tmpPropertyIsOut then begin
              //директива out для property
              //поддерживаю выходной параметр в property
              if (not assigned(aPLocalParamsArrayOutAdd)) or (not assigned(aPLocalParamsArrayOutAdd^.aOnLocalOutParamsAddEvent)) then raise exception.create('Directives ''OUT'' for token '''+tmpToken+''' is inapplicable(Statement:'''+copy(aStatement, 1, 40)+''').');
              //добавляю out параметр в список для полседующего заполнения
              aPLocalParamsArrayOutAdd^.aOnLocalOutParamsAddEvent(aPLocalParamsArrayOutAdd^.aPParamId, tmpToken, tmpPropertyIndex, aPLocalParamsArrayOutAdd^.aPParamOut);
            end;

            aOperand := InternalGetPropertyValue(aASLSolveStatementEvents, tmpPropertyName, tmpPropertyIndex);
          end else begin
            raise exception.createfmt(cnInvalidStatement, [tmpToken]);
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
          if not InternalGetSolvedNextOperand(aASLSolveStatementEvents, aPos, aPosTo, aStatement, tmpOperand, nil) then raise exception.createfmt(cnUnsatisfiedStatementTerminated, [aStatement]);
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
    //e.message:= 'GetSolvedNextOperand: ' + e.message;
    raise;
  end;end;
end;

function TASLSolveStatement.InternalGetOperator(var aPos:integer; aPosTo:integer; const aStatement:AnsiString; out aOperator:TOperator):boolean;
  var tmpToken:AnsiString;
      tmpIdToken:TIdToken;
begin
  if TokenNext(aPos, aPosTo, aStatement, @tmpToken, @tmpIdToken) then begin
    case tmpIdToken of
      tknOperatorBigger, tknOperatorBiggerEqual, tknOperatorLess, tknOperatorLessEqual, tknOperatorEqual, tknOperatorNotEqual,
      tknOperatorAddition, tknOperatorSubtract, tknOperatorDivision, tknOperatorMultiplication, tknAND, tknOR, tknISNULL, tknISNOTNULL, tknIN:begin
        if not InternalIdTokenToOperator(tmpIdToken, aOperator) then raise exception.createfmt(cnInvalidStatement, [tmpToken]);
      end;
    else
      raise exception.createfmt(cnInvalidStatement, [tmpToken]);
    end;
    result := true;
  end else begin
    result := false;
  end;
end;

procedure TASLSolveStatement.InternalInternalSkipBracketsFrom(var aPos:integer; aPosTo:integer; const aStatement:AnsiString; aPIdTokenOpen:TPIdToken; aIdTokenClose:TIdToken);
  var tmpToken:AnsiString;
      tmpIdToken:TIdToken;
      //tmpPosOld:integer;
      tmpDepth:integer;
begin
  //tmpPosOld := aPos;
  tmpDepth := 1;
  while true do begin
    if not TokenNext(aPos, aPosTo, aStatement, @tmpToken, @tmpIdToken) then begin
      //raise exception.createfmt(cnUnsatisfiedStatementTerminated, [copy(copy(aStatement, aPos, aPosTo - aPos), 1, 30)]);
      raise exception.createfmt(cnExpectStatement, [TokenById(aIdTokenClose)]);
    end;

    if assigned(aPIdTokenOpen) and (tmpIdToken = aPIdTokenOpen^{tknBracketOpen}) then begin
      inc(tmpDepth);//увеличивается вложенность
    end else if tmpIdToken = aIdTokenClose{tknBracketClose} then begin
      dec(tmpDepth);//уменьшается вложенность
    end;

    if tmpDepth = 0 then break;//нашел свою закрывающую скобку
  end;
  //result := copy(aStatement, tmpPosOld, aPos - tmpPosOld - 1);//-1 чтобы убрать закрывающую скобку
end;

procedure TASLSolveStatement.InternalSkipBracketsFrom(var aPos:integer; aPosTo:integer; const aStatement:AnsiString; aIdTokenOpen, aIdTokenClose:TIdToken);
begin
  InternalInternalSkipBracketsFrom(aPos, aPosTo, aStatement, @aIdTokenOpen, aIdTokenClose);
end;

procedure TASLSolveStatement.InternalSkipBracketsTo(var aPos:integer; aPosTo:integer; const aStatement:AnsiString; aIdTokenClose:TIdToken);
begin
  InternalInternalSkipBracketsFrom(aPos, aPosTo, aStatement, nil, aIdTokenClose);
end;

function TASLSolveStatement.InternalSolveOperatorIN(const aLeftOperand:variant; const aParamsArray:variant):boolean;
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

function TASLSolveStatement.InternalGetSolvedParamsArrayIn(const aASLSolveStatementEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aStatement:AnsiString):Variant;
begin
  result := InternalInternalGetSolvedParamsArrayInOut(aASLSolveStatementEvents, aPos, aPosTo, aStatement, false).aParamIn;
end;

function TASLSolveStatement.InternalGetSolvedParamsArrayInOut(const aASLSolveStatementEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aStatement:AnsiString):TFunctionParam;
begin
  result := InternalInternalGetSolvedParamsArrayInOut(aASLSolveStatementEvents, aPos, aPosTo, aStatement, true);
end;

procedure InternalLocalParamsArrayOutAdd(aParamId:integer; const aParamName:AnsiString; const aPropertyIndex:variant; aPOutParams:PVariant);
  var tmpHB: integer;
begin
  if not assigned(aPOutParams) then raise exception.createfmt(cnValueNotAssigned, ['aPOutParams']);

  if VarIsArray(aPOutParams^) then begin
    tmpHB := VarArrayHighBound(aPOutParams^, 1) + 1;
    VarArrayRedim(aPOutParams^, tmpHB);
  end else begin
    aPOutParams^ := VarArrayCreate([0, 0], varVariant);
    tmpHB := 0;
  end;

  aPOutParams^[tmpHB] := VarArrayOf([aParamId, aParamName, aPropertyIndex]);
end;

function TASLSolveStatement.InternalInternalGetSolvedParamsArrayInOut(const aASLSolveStatementEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aStatement:AnsiString; aNeedOut:boolean):TFunctionParam;
  var tmpOperand:variant;
      tmpHB:integer;
      tmpToken:AnsiString;
      tmpIdToken:TIdToken;
      tmpLocalParamsArrayOutAdd: TLocalParamsArrayOutAdd;
  function localGetPLocalParamsArrayOutAdd:PLocalParamsArrayOutAdd;begin
    if aNeedOut then begin
      result := @tmpLocalParamsArrayOutAdd;
    end else begin
      result := nil;
    end;
  end;
begin
  tmpHB := -1;
  result.aParamIn := unassigned;

  tmpLocalParamsArrayOutAdd.aPParamId := 0;//порядковый номер параметра
  tmpLocalParamsArrayOutAdd.aPParamOut := @result.aParamOut;
  tmpLocalParamsArrayOutAdd.aOnLocalOutParamsAddEvent := InternalLocalParamsArrayOutAdd;

  while InternalGetSolvedNextOperand(aASLSolveStatementEvents, aPos, aPosTo, aStatement, tmpOperand, localGetPLocalParamsArrayOutAdd) do begin
    if tmpHB = -1 then begin
      result.aParamIn :=VarArrayCreate([0, 0], varVariant);
      tmpHB := 0;
    end else begin
      inc(tmpHB);
      VarArrayRedim(result.aParamIn, tmpHB);
    end;
    result.aParamIn[tmpHB] := tmpOperand;

    if not TokenNext(aPos, aPosTo, aStatement, @tmpToken, @tmpIdToken) then break;
    if tmpIdToken <> tknComma then raise exception.createfmt(cnInvalidStatement, [tmpToken]);

    inc(tmpLocalParamsArrayOutAdd.aPParamId);//следующий параметр, увеличиваю счетчик
  end;
end;

function TASLSolveStatement.InternalSolveOperationTwo(const aOperandLeft:variant; aOperator:TOperator; const aOperandRight:variant):variant;
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

  if ((tmpOperandTypeLeft <> optNull) and (tmpOperandTypeRight <> optNull)) and (tmpOperandTypeLeft <> tmpOperandTypeRight) then raise exception.createfmt(cnInvalidTypeCast, [OperandTypeToOperandTypeName(tmpOperandTypeLeft), VarToStr(aOperandLeft), OperandTypeToOperandTypeName(tmpOperandTypeRight), VarToStr(aOperandRight)]);

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

function TASLSolveStatement.InternalGetCurrTokenFunction(const aASLSolveStatementEvents:TASLSolveStatementEvents; const aToken: AnsiString; aIdToken: TIdToken; var aPos:integer; aPosTo:integer; const aStatement:AnsiString; out aFunctionName:AnsiString; out aFunctionSolvedParamsArray:TFunctionParam; out aIsSubFunction:boolean; aRaise:boolean):boolean;
  var tmpToken: AnsiString;
      tmpIdToken: TIdToken;
      tmpPos: integer;
      tmpPosSolvedParamsArray : integer;
      tmpFunctionName: AnsiString;
      tmpIsSubFunction: boolean;
begin
  result := true;
  tmpPos := aPos;

  //проверяю префик exec
  if aIdToken = tknExec then begin
    tmpIsSubFunction := true;

    if not TokenNext(tmpPos, aPosTo, aStatement, @tmpToken, @tmpIdToken) then begin
      if aRaise then raise exception.createfmt(cnInvalidStatement, [aToken]);
      result := false;
      exit;
    end;
  end else begin
    tmpIsSubFunction := false;

    tmpToken := aToken;
    tmpIdToken := aIdToken;
  end;

  //получаю имя функции
  if tmpIdToken <> tknWord then begin
    if aRaise then raise exception.createfmt(cnInvalidStatement, [tmpToken]);
    result := false;
    exit;
  end;

  tmpFunctionName := tmpToken;

  if (not TokenNext(tmpPos, aPosTo, aStatement, @tmpToken, @tmpIdToken)) or (tmpIdToken <> tknBracketOpen) then begin
    if aRaise then raise exception.createfmt(cnInvalidStatement, [tmpToken]);
    result := false;
    exit;
  end;

  //решаю содержимое скобок
  tmpPosSolvedParamsArray := tmpPos;//беру начало скобки
  InternalSkipBracketsFrom(tmpPos, aPosTo, aStatement, tknBracketOpen, tknBracketClose);//позицианируюсь на конец скобки

  if not(tmpPos > aPosTo) then begin
    aPos := tmpPos;
    raise exception.createfmt(cnInvalidStatement, [copy(aStatement, aPos, aPosTo - aPos + 1)]);
  end;  

  aFunctionSolvedParamsArray := InternalGetSolvedParamsArrayInOut(aASLSolveStatementEvents, tmpPosSolvedParamsArray, tmpPos - 2, aStatement);//после прокрутки курсок стоит на первой позиции следующего элемента, значит чтобы использв. это значение для ограничения скобки убираем -1(встаем на последний элемент своего блока) и еще раз -1(убираем закрывающеюся скобку) итого -2)

  //выгружаю результаты
  aPos := tmpPos;
  aFunctionName := tmpFunctionName;
  aIsSubFunction := tmpIsSubFunction;
end;

type
  TLocalIsParamOut = class
  protected
    FPParamOut:PVariant;
  public
    function IsParamOut(aParamId:cardinal):boolean;
  public
    constructor create(aPParamOut:PVariant);
  end;

constructor TLocalIsParamOut.create(aPParamOut:PVariant);
begin
  inherited create();

  if not assigned(aPParamOut) then raise exception.createfmt(cnValueNotAssigned, ['aPParamOut']);
  FPParamOut := aPParamOut;
end;

function TLocalIsParamOut.IsParamOut(aParamId:cardinal):boolean;
  var tmpI: integer;
begin
  result := false;

  if VarIsArray(FPParamOut^) then begin
    for tmpI := VarArrayLowBound(FPParamOut^, 1) to VarArrayHighBound(FPParamOut^, 1) do begin
      if FPParamOut^[tmpI][0] = aParamId then begin
        result := true;
        break;
      end;
    end;
  end;
end;

function TASLSolveStatement.InternalGetFunctionValue(const aASLSolveStatementEvents:TASLSolveStatementEvents; const aName:AnsiString; aFunctionParam:TFunctionParam; aIsSubFunction:boolean):variant;
  function LocalGetOnFunction:TOnFunctionEvent;begin
    if aIsSubFunction then begin
      result := aASLSolveStatementEvents.OnSubFunction;
    end else begin
      result := aASLSolveStatementEvents.OnFunction;
    end;

    if not assigned(result) then raise exception.createfmt(cnValueNotAssigned, ['aOnFunction for ' + aName]);
  end;

  var tmpI: integer;
      tmpLocalIsParamOut: TLocalIsParamOut;
      tmpOnFunctionEvent: TOnFunctionEvent;
begin

  tmpLocalIsParamOut := TLocalIsParamOut.create(@aFunctionParam.aParamOut);
  try
    tmpOnFunctionEvent := LocalGetOnFunction();
    result := tmpOnFunctionEvent(InternalUnwrapUserdata(aASLSolveStatementEvents), aName, aFunctionParam.aParamIn, tmpLocalIsParamOut.IsParamOut);
  finally
    FreeAndNil(tmpLocalIsParamOut);
  end;

  //назначение выходного параметра
  if VarIsArray(aFunctionParam.aParamOut) then begin
    //выходные параметры возвращаются только в property
    for tmpI := VarArrayLowBound(aFunctionParam.aParamOut, 1) to VarArrayHighBound(aFunctionParam.aParamOut, 1) do begin
      InternalSetPropertyValue(aASLSolveStatementEvents, aFunctionParam.aParamOut[tmpI][1], aFunctionParam.aParamOut[tmpI][2], aFunctionParam.aParamIn[aFunctionParam.aParamOut[tmpI][0]]);
    end;
  end;
end;

function TASLSolveStatement.InternalGetCurrTokenProperty(const aASLSolveStatementEvents:TASLSolveStatementEvents; const aToken: AnsiString; aIdToken: TIdToken; var aPos:integer; aPosTo:integer; const aStatement:AnsiString; out aName:AnsiString; out aIndex:variant; out aIsOut:boolean; aRaise:boolean):boolean;
  var tmpToken: AnsiString;
      tmpIdToken: TIdToken;
      tmpPos, tmpPosNew, tmpPosSolvedParamsArrayIn: integer;
      tmpPropertyIndex : variant;
      tmpPropertyName: AnsiString;
      tmpPropertyIsOut: boolean;
      tmpBool: boolean;
begin
  result := true;
  tmpPos := aPos;

  tmpPropertyIsOut := false;
  tmpPropertyIndex := unassigned;

  //получаю имя функции
  if aIdToken <> tknWord then begin
    if aRaise then raise exception.createfmt(cnInvalidStatement, [aToken]);
    result := false;
    exit;
  end;

  tmpPropertyName := aToken;

  tmpPosNew := tmpPos;
  //смотрю на Index и на out
  if TokenNext(tmpPosNew, aPosTo, aStatement, @tmpToken, @tmpIdToken) then begin

    //проверяю что это проперти а не функция
    if tmpIdToken = tknBracketOpen then begin
      if aRaise then raise exception.createfmt(cnInvalidStatement, [tmpToken]);
      result := false;
      exit;
    end;

    //проверяю индекс
    if tmpIdToken = tknSquareBracketOpen then begin
      //решаю содержимое скобок
      tmpPosSolvedParamsArrayIn := tmpPosNew;//запоминаю начало скобки
      InternalSkipBracketsFrom(tmpPosNew, aPosTo, aStatement, tknSquareBracketOpen, tknSquareBracketClose);//устанавливаюсь на конец скобки

      tmpPropertyIndex := InternalGetSolvedParamsArrayIn(aASLSolveStatementEvents, tmpPosSolvedParamsArrayIn, tmpPosNew - 2, aStatement);//после прокрутки курсок стоит на первой позиции следующего элемента, значит чтобы использв. это значение для ограничения скобки убираем -1(встаем на последний элемент своего блока) и еще раз -1(убираем закрывающеюся скобку) итого -2)

      tmpPos := tmpPosNew;//удачно катнул вперед, сохраняю
      tmpBool := TokenNext(tmpPosNew, aPosTo, aStatement, @tmpToken, @tmpIdToken);//пробую катнуть еще раз
    end else begin
      tmpBool := true;
    end;

    //проверяю на MyProp out или MyProp[1] out
    if tmpBool and (tmpIdToken = tknOut) then begin
      //директива out для property
      tmpPropertyIsOut := true;
      tmpPos := tmpPosNew;//удачно катнул вперед, сохраняю
    end else begin
      tmpPropertyIsOut := false;
    end;
  end;

  //выгружаю результаты
  aPos := tmpPos;
  aName := tmpPropertyName;
  aIsOut := tmpPropertyIsOut;
  aIndex := tmpPropertyIndex;
end;

function TASLSolveStatement.InternalGetPropertyValue(const aASLSolveStatementEvents:TASLSolveStatementEvents; const aName:AnsiString; const aPropertyIndex:variant):variant;
begin
  if AnsiUpperCase(aName) = 'FALSE' then begin
    if not VarIsEmpty(aPropertyIndex) then raise exception.createfmt(cnInvalidValueOf, ['varEmpty', 'aPropertyIndex']);
    result := false;
  end else if AnsiUpperCase(aName) = 'TRUE' then begin
    if not VarIsEmpty(aPropertyIndex) then raise exception.createfmt(cnInvalidValueOf, ['varEmpty', 'aPropertyIndex']);
    result := true;
  end else if assigned(aASLSolveStatementEvents.OnGetProperty) then begin
    result := aASLSolveStatementEvents.OnGetProperty(InternalUnwrapUserdata(aASLSolveStatementEvents), aName, aPropertyIndex);
  end else raise exception.createfmt(cnValueNotAssigned, ['aOnGetProperty for ''' + aName + '''']);
end;

procedure TASLSolveStatement.InternalSetPropertyValue(const aASLSolveStatementEvents:TASLSolveStatementEvents; const aName:AnsiString; const aPropertyIndex:variant; const aValue:variant);
begin
  if (AnsiUpperCase(aName) = 'FALSE') or (AnsiUpperCase(aName) = 'TRUE') then begin
    raise exception.create('Inadmissible to use reserved word '''+AnsiUpperCase(aName)+'''.');
  end else if assigned(aASLSolveStatementEvents.OnGetProperty) then begin
    aASLSolveStatementEvents.OnSetProperty(InternalUnwrapUserdata(aASLSolveStatementEvents), aName, aPropertyIndex, aValue);
  end else raise exception.createfmt(cnValueNotAssigned, ['aOnSetProperty for ''' + aName + '''']);
end;

function TASLSolveStatement.StrToFloatAlternative(const aFloatString:AnsiString):double;
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

function TASLSolveStatement.InternalOperandToOperandType(const aOperand:variant):TOperandType;
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
    raise exception.createfmt('OperandToOperandType: '+cnUnsupportedType, [IntToStr(tmpVarType)]);
  end;
end;

function TASLSolveStatement.InternalIdTokenToOperator(aIdToken:TIdToken; out aOperator:TOperator):boolean;
begin
  aOperator := TOperator(integer(aIdToken) - integer(tknOperatorBigger));
  result := not(integer(aOperator) < 0) or (integer(aOperator) > integer(oprIN));
end;

function TASLSolveStatement.OperandTypeToOperandTypeName(aOperandType:TOperandType):AnsiString;
begin
  case aOperandType of
    optInteger:result := 'optInteger';
    optString:result := 'optString';
    optNull:result := 'optNull';
    optBool:result := 'optBool';
    optFloat:result := 'optFloat';
  else result :=  'opt_'+IntToStr(Integer(aOperandType));
  end;
end;

function TASLSolveStatement.InternalUnwrapUserdata(const aASLSolveStatementEvents:TASLSolveStatementEvents):pointer;
begin
  result := aASLSolveStatementEvents.aUserData;
end;

end.
