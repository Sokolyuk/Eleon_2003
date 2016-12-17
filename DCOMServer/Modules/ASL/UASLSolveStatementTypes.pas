//Copyright © 2000-2004 by Dmitry A. Sokolyuk

//21.05.2004
//Application script laguage
unit UASLSolveStatementTypes;

interface

type
  TOnIsParamOutEvent = function (aParamId:cardinal):boolean of object;

  TOnGetPropertyEvent = function(aUserData:pointer; const aPropertyName:AnsiString; const aPropertyIndex:variant):variant of object;
  TOnSetPropertyEvent = procedure(aUserData:pointer; const aPropertyName:AnsiString; const aPropertyIndex:variant; const aValue:variant) of object;
  TOnFunctionEvent = function(aUserData:pointer; const aSubFunctionName:AnsiString; var aSubFunctionParams:variant; aOnIsParamOut:TOnIsParamOutEvent):variant of object;

  TOperator = (oprBigger, oprBiggerEqual, oprLess, oprLessEqual, oprEqual, oprNotEqual, oprAddition, oprSubtract, oprDivision, oprMultiplication, oprAND, oprOR, oprISNULL, oprISNOTNULL, oprIN);

  TOperandType = (optInteger, optFloat, optString, optBool, optNull);

  TASLSolveStatementEvents = record
    aUserData: pointer;
    OnFunction: TOnFunctionEvent;
    OnSubFunction: TOnFunctionEvent;
    OnGetProperty: TOnGetPropertyEvent;
    OnSetProperty: TOnSetPropertyEvent;
  end;

  TFunctionParam = record
    aParamIn: variant;
    aParamOut: variant;
  end;

  TOnLocalOutParamsAddEvent = procedure (aParamId:integer; const aParamName:AnsiString; const aPropertyIndex:variant; aPOutParams:PVariant);

  PLocalParamsArrayOutAdd = ^TLocalParamsArrayOutAdd;
  TLocalParamsArrayOutAdd = record
    aPParamId: Integer;
    aPParamOut: PVariant;
    aOnLocalOutParamsAddEvent: TOnLocalOutParamsAddEvent;
  end;


const
  tknBracketOpen = 4;
  tknBracketClose = 5;
  tknOperatorBigger = 6;
  tknOperatorBiggerEqual = 7;
  tknOperatorLess = 8;
  tknOperatorLessEqual = 9;
  tknOperatorEqual = 10;
  tknOperatorNotEqual = 11;
  tknOperatorAddition = 12;
  tknOperatorSubtract = 13;
  tknOperatorDivision = 14;
  tknOperatorMultiplication = 15;
  tknAND = 16;
  tknOR = 17;
  tknISNULL = 18;
  tknISNOTNULL = 19;
  tknIN = 20;
  tknNOT = 21;
  tknComma = 22;
  tknOut = 23;
  tknDotWithComma = 24;
  tknFigureBracketOpen = 25;
  tknFigureBracketClose = 26;
  tknIf = 27;
  tknElse = 28;
  tknSquareBracketOpen = 29;
  tknSquareBracketClose = 30;
  tknExec = 31;

implementation

end.
