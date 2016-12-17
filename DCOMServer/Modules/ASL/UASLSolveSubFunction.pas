//Copyright � 2000-2004 by Dmitry A. Sokolyuk

//21.05.2004
//Application script laguage

unit UASLSolveSubFunction;

interface
  uses UASLSolveStatement, UASLSolveSubFunctionTypes, UTokenParserTypes, UASLSolveStatementTypes, classes;

type

  TASLSolveSubFunction = class(TASLSolveStatement)
  protected
    procedure InternalSetPropertyValue(const aASLSolveStatementEvents:TASLSolveStatementEvents; const aName:AnsiString; const aPropertyIndex:variant; const aValue:variant);override;
    function InternalGetPropertyValue(const aASLSolveStatementEvents:TASLSolveStatementEvents; const aName:AnsiString; const aPropertyIndex:variant):variant;override;
    function InternalGetFunctionValue(const aASLSolveStatementEvents:TASLSolveStatementEvents; const aName:AnsiString; aFunctionParam:TFunctionParam; aIsSubFunction:boolean):variant;override;
    function InternalUnwrapUserdata(const aASLSolveStatementEvents:TASLSolveStatementEvents):pointer;override;
  //protected
  //  function InternalSubFunctionEventsToStatementEvents(const aASLSolveSubFunctionEvents: TASLSolveStatementEvents):TASLSolveStatementEvents;virtual;
  //  function InternalStatementEventsDeWrapUserData(const aASLSolveStatementEvents:TASLSolveStatementEvents):TASLSolveStatementEvents;virtual;
  protected
    function InternalGetPropertyValueSubFunctionParams(const aSubFunctionParamsList:TStringList; aPSubFunctionParamsData:PVariant; aName:AnsiString; const aPropertyIndex:variant; out aResult:variant):boolean;virtual;
    function InternalSetPropertyValueSubFunctionParams(const aSubFunctionParamsList:TStringList; aPSubFunctionParamsData:PVariant; aName:AnsiString; const aPropertyIndex:variant; const aValue:variant):boolean;virtual;
    function InternalParamNameToId(const aSubFunctionParamsList:TStringList; aParamName:AnsiString):integer;virtual;
    procedure InternalSubExceptionAdd(const aExceptionList:TStringList; const aExceptionName:AnsiString; aObject:Pointer);virtual;
    procedure InternalSubExceptionDeleteByName(const aExceptionList:TStringList; aExceptionName:AnsiString);virtual;
    function InternalGetPropertyValueSubFunctionExceptions(const aExceptionList:TStringList; aName:AnsiString; const aPropertyIndex:variant; out aResult:variant):boolean;virtual;
    function InternalSetPropertyValueSubFunctionExceptions(const aExceptionList:TStringList; aName:AnsiString; const aPropertyIndex:variant; const aValue:variant):boolean;virtual;
    function InternalVarIsInteger(aVarType: integer):boolean;virtual;
    function InternalGetPropertyValueSubFunctionDeclaration(const aDeclareList:TStringList; aName:AnsiString; const aPropertyIndex:variant; out aResult:variant):boolean;virtual;
    function InternalSetPropertyValueSubFunctionDeclaration(const aDeclareList:TStringList; aName:AnsiString; const aPropertyIndex:variant; const aValue:variant):boolean;virtual;
  protected
    function InternalSolveSubFunctionBlock(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aSubFunction:AnsiString; var aSubFunctionParamsData:variant; out aSubFunctionResult:variant):TSubFunctionRowResult;virtual;
    function InternalSolveSubFunctionBlockIf(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aSubFunction:AnsiString; var aSubFunctionParamsData:variant; out aSubFunctionResult:variant):TSubFunctionRowResult;virtual;
    function InternalSolveSubFunctionBlockWhile(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aSubFunction:AnsiString; var aSubFunctionParamsData:variant; out aSubFunctionResult:variant):TSubFunctionRowResult;virtual;
    function InternalSolveSubFunctionBlockTry(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aSubFunction:AnsiString; var aSubFunctionParamsData:variant; out aSubFunctionResult:variant):TSubFunctionRowResult;virtual;
    function InternalSolveSubFunctionBlockTryFinally(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; aPosTry:integer; aPosTryTo:integer; const aSubFunction:AnsiString; var aSubFunctionParamsData:variant; out aSubFunctionResult:variant):TSubFunctionRowResult;virtual;
    function InternalSolveSubFunctionBlockTryCatch(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; aPosTry:integer; aPosTryTo:integer; const aSubFunction:AnsiString; var aSubFunctionParamsData:variant; out aSubFunctionResult:variant):TSubFunctionRowResult;virtual;
    function InternalSolveSubFunctionBlockRow(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aSubFunction:AnsiString; var aSubFunctionParamsData:variant; out aSubFunctionRowResult:variant):TSubFunctionRowResult;virtual;
    function InternalSkipNextCommandBlock(var aPos:integer; aPosTo:integer; const aSubFunction:AnsiString; aRaise:boolean):boolean;virtual;
    function InternalSkipNextIfElse(var aPos:integer; aPosTo:integer; const aSubFunction:AnsiString; aRaise:boolean):boolean;virtual;
    function InternalGetNextTokenPropertyNoOut(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aStatement:AnsiString; out aName:AnsiString; out aIndex:variant; aRaise:boolean):boolean;virtual;
    function InternalGetCurrTokenPropertyNoOut(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; const aToken:AnsiString; aIdToken:TIdToken; var aPos:integer; aPosTo:integer; const aStatement:AnsiString; out aName:AnsiString; out aIndex:variant; aRaise:boolean):boolean;virtual;
    procedure InternalSkipIf(var aPos:integer; aPosTo:integer; const aSubFunction:AnsiString);virtual;
    function InternalGetNextTokenProperty(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aStatement:AnsiString; out aName:AnsiString; out aIndex:variant; out aIsOut:boolean; aRaise:boolean):boolean;virtual;
    procedure InternalPushSubFunctionParams(const aSubFunctionParamsList:TStringList; aParamsPos:integer; aParamsPosTo:integer; const aSubFunctionParams:AnsiString; const aSubFunctionParamsData:variant);virtual;
  protected
    procedure InternalSubFunctionRowDeclare(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aSubFunction:AnsiString);virtual;
    procedure InternalDeclareListClearVarData(const aDeclareList: TStringList);virtual;
    procedure InternalDeclareListAdd(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; const aName:AnsiString; const aIndex:variant);virtual;
    function InternalStringListIn(const aStringList: TStringList; const aName:AnsiString; aRaise: boolean):boolean;virtual;
  public
    function SolveSubFunction(aASLSolveSubFunctionEvents:TASLSolveStatementEvents; aParamsPos:integer; aParamsPosTo:integer; aPos:integer; aPosTo:integer; const aSubFunction:AnsiString; var aSubFunctionParamsData:variant; aIsParamOut:TOnIsParamOutEvent):variant;virtual;
  public
    constructor create();
    destructor destroy();override;
  end;


implementation
  uses Sysutils, UStringConsts{$ifndef ver130}, Variants{$endif};

constructor TASLSolveSubFunction.create();
begin
  inherited create();

  //�������� teken-�
  TokenAdd('RETURN', integer(tknReturn), false);
  TokenAdd('DECLARE', integer(tknDeclare), false);
  TokenAdd('WHILE', integer(tknWhile), false);
  TokenAdd('BREAK', integer(tknBreak), false);
  TokenAdd('CONTINUE', integer(tknContinue), false);

  TokenAdd('TRY', integer(tknTry), false);
  TokenAdd('FINALLY', integer(tknFinally), false);
  TokenAdd('CATCH', integer(tknCatch), false);
  TokenAdd('THROW', integer(tknThrow), false);
  TokenAdd('EXCEPTION', integer(tknException), false);

end;

destructor TASLSolveSubFunction.destroy();
begin
  inherited destroy();
end;

procedure TASLSolveSubFunction.InternalPushSubFunctionParams(const aSubFunctionParamsList:TStringList; aParamsPos:integer; aParamsPosTo:integer; const aSubFunctionParams:AnsiString; const aSubFunctionParamsData:variant);
  var tmpToken: AnsiString;
      tmpIdToken: TIdToken;
      tmpLB: integer;
      tmpHB: integer;
      tmpCurr: integer;
begin
  try
    if not assigned(aSubFunctionParamsList) then raise exception.createfmt(cnValueNotAssigned, ['aSubFunctionParamsList']);

    if VarIsArray(aSubFunctionParamsData) then begin
      //��������� ����
      tmpLB := VarArrayLowBound(aSubFunctionParamsData, 1);
      tmpHB := VarArrayHighBound(aSubFunctionParamsData, 1);
    end else begin
      //��������� ������
      tmpLB := 0;
      tmpHB := -1;
    end;

    tmpCurr := -1;


    //�������� ������ ����������
    while true do begin

      if TokenNext(aParamsPos, aParamsPosTo, aSubFunctionParams, @tmpToken, @tmpIdToken) then begin
        //������� ��������
        if tmpIdToken <> tknWord then raise exception.createfmt(cnInvalidStatement, [tmpToken]);

        inc(tmpCurr);//���������� ������� ��������� ����������

        //�������� ������������ ���������� ����������
        if (tmpHB - tmpLB) < tmpCurr then raise exception.create('No enough actual parameters('+IntToStr(tmpHB - tmpLB + 1)+'<'+IntToStr(tmpCurr + 1)+').');

        aSubFunctionParamsList.Objects[aSubFunctionParamsList.Add(AnsiUpperCase(tmpToken))] := pointer(tmpCurr);//�������� �������� ��������� � ��� ����� ������ � �������

        //�������� ������� ����� �����������
        if (TokenNext(aParamsPos, aParamsPosTo, aSubFunctionParams, @tmpToken, @tmpIdToken)) and ((tmpIdToken <> tknComma) or (aParamsPos > aParamsPosTo)) then
            raise exception.createfmt(cnInvalidStatement, [tmpToken]);
      end else begin
        if (tmpHB - tmpLB) > tmpCurr then raise exception.create('Too many actual parameters('+IntToStr(tmpHB - tmpLB + 1)+'>'+IntToStr(tmpCurr + 1)+').');
        break;
      end;

    end;

  except on e:exception do begin
    e.message := 'PushSubFunctionParams: ' + e.message;
    raise;
  end;end;
end;

type
  TPSolveSubFunctionRec = ^TSolveSubFunctionRec;
  TSolveSubFunctionRec = record
    aUserData: pointer;
    aSubFunctionParamsList: TStringList;//������� ������ ���� ���������� � �������������� �������� ��������� � aSubFunctionParams
    aPSubFunctionParamsData: PVariant;//��������� �� aSubFunctionParams
    aIsParamOut: TOnIsParamOutEvent;//����� ���������� ������ @@IsParamOut('aParam1')
    aExceptionList: TStringList;//������ ���� ���������� � ������� TException
    aDeclareList: TStringList;//������ ���� ����������, � �������� � Objects[?] PVariant
  end;

function TASLSolveSubFunction.SolveSubFunction(aASLSolveSubFunctionEvents:TASLSolveStatementEvents; aParamsPos:integer; aParamsPosTo:integer; aPos:integer; aPosTo:integer; const aSubFunction:AnsiString; var aSubFunctionParamsData:variant; aIsParamOut:TOnIsParamOutEvent):variant;
  var tmpSubFunctionResult: variant;
      tmpSubFunctionRowResult: TSubFunctionRowResult;
      tmpSolveSubFunctionRec: TSolveSubFunctionRec;
begin
  // a();
  // declare tmpI;
  // tmpI = b();
  // if (tmpI >= 0) {tmpI = 1;} else {tmpI = -1;}
  // return tmpI + 33;

  //@@IsParamOut['']

  try
    tmpSolveSubFunctionRec.aUserData := aASLSolveSubFunctionEvents.aUserData;
    tmpSolveSubFunctionRec.aSubFunctionParamsList := TStringList.create();
    try
      tmpSolveSubFunctionRec.aExceptionList := TStringList.create();
      try
        InternalPushSubFunctionParams(tmpSolveSubFunctionRec.aSubFunctionParamsList, aParamsPos, aParamsPosTo, aSubFunction, aSubFunctionParamsData);//������� ��������� � ������
        tmpSolveSubFunctionRec.aPSubFunctionParamsData := @aSubFunctionParamsData;
        tmpSolveSubFunctionRec.aIsParamOut := aIsParamOut;

        aASLSolveSubFunctionEvents.aUserData := @tmpSolveSubFunctionRec{Wraped aUserData};
        try
          tmpSolveSubFunctionRec.aDeclareList := TStringList.create();//������ ������ ����������� ����������
          try

            //����� ����
            tmpSubFunctionRowResult := InternalSolveSubFunctionBlock(aASLSolveSubFunctionEvents, aPos, aPosTo, aSubFunction, aSubFunctionParamsData, tmpSubFunctionResult);

          finally
            InternalDeclareListClearVarData(tmpSolveSubFunctionRec.aDeclareList);
            tmpSolveSubFunctionRec.aDeclareList.free;
          end;
        finally
          aASLSolveSubFunctionEvents.aUserData := tmpSolveSubFunctionRec.aUserData;//unwrap userdata

          //��� ������� ��� ������� ����������
          //if assigned(aASLSolveSubFunctionEvents.OnFunctionClose) then aASLSolveSubFunctionEvents.OnFunctionClose(aASLSolveSubFunctionEvents.aUserData);
        end;

      finally
        tmpSolveSubFunctionRec.aExceptionList.free;
      end;
    finally
      tmpSolveSubFunctionRec.aSubFunctionParamsList.free;
    end;

    case tmpSubFunctionRowResult of
      sfrrOkay:begin
        result := unassigned;
      end;
      sfrrReturn:begin
        result := tmpSubFunctionResult;
      end;
      sfrrBreak:begin
        raise exception.createfmt(cnInvalidStatement, [TokenById(cardinal(tknBreak))]);
      end;
      sfrrContinue:begin
        raise exception.createfmt(cnInvalidStatement, [TokenById(cardinal(tknContinue))]);
      end;
      sfrrThrow:begin
        raise exception.createfmt(cnInvalidStatement, [TokenById(cardinal(tknThrow))]);
      end;
    else
      raise exception.createfmt(cnInvalidValueOf, [IntToStr(integer(tmpSubFunctionRowResult)), 'SubFunctionRowResult']);
    end;

  except on e:exception do begin
    e.message := 'SolveSubFunction('+InternalPosToLineCol(aPos, aSubFunction)+'): ' + e.message;
    raise;
  end;end;
end;

function TASLSolveSubFunction.InternalSolveSubFunctionBlock(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aSubFunction:AnsiString; var aSubFunctionParamsData:variant; out aSubFunctionResult:variant):TSubFunctionRowResult;
  var tmpToken: AnsiString;
      tmpIdToken: TIdToken;
      tmpPosSubBlockBegin: integer;
      tmpPosSubBlockRow: integer;
begin
  //�������� ��������� ������� ASL. ������ ������ ���� ������.

  result := sfrrOkay;

  while true do begin

    tmpPosSubBlockRow := aPos;//���� ���. ������ �������, ��� ������� �������

    if TokenNext(aPos, aPosTo, aSubFunction, @tmpToken, @tmpIdToken) then begin
      case tmpIdToken of
        tknDotWithComma:begin
          //������ ��������
        end;
        tknIf:begin
          result := InternalSolveSubFunctionBlockIf(aASLSolveSubFunctionEvents, aPos, aPosTo, aSubFunction, aSubFunctionParamsData, aSubFunctionResult);
        end;
        tknWhile:begin
          result := InternalSolveSubFunctionBlockWhile(aASLSolveSubFunctionEvents, aPos, aPosTo, aSubFunction, aSubFunctionParamsData, aSubFunctionResult);
        end;
        tknFigureBracketOpen:begin
          //{a();b();} - ����� �� ���� � �������� �������
          tmpPosSubBlockBegin := aPos;//���� ���. ����. ������
          InternalSkipBracketsFrom(aPos, aPosTo, aSubFunction, tknFigureBracketOpen, tknFigureBracketClose);//������� ����. ������
          result := InternalSolveSubFunctionBlock(aASLSolveSubFunctionEvents, tmpPosSubBlockBegin, aPos - 2, aSubFunction, aSubFunctionParamsData, aSubFunctionResult);//����� ��������� ������ ����� �� ������ ������� ���������� ��������, ������ ����� ��������. ��� �������� ��� ����������� ������ ������� -1(������ �� ��������� ������� ������ �����) � ��� ��� -1(������� ������������� ������) ����� -2)
        end;
        tknTry:begin
          //  try{          try{         try{
          //    ..            ..           throw Exception('My exception message');
          //  }finally{     }catch{      }catch(exception e1){
          //    ..            ..           e1.Message = '???' + e1.message;
          //  }             }              throw;
          //                             }
          result := InternalSolveSubFunctionBlockTry(aASLSolveSubFunctionEvents, aPos, aPosTo, aSubFunction, aSubFunctionParamsData, aSubFunctionResult);
        end;
      else
        //������� �������
        InternalSkipBracketsTo(aPos, aPosTo, aSubFunction, tknDotWithComma);//������� ;

        result := InternalSolveSubFunctionBlockRow(aASLSolveSubFunctionEvents, tmpPosSubBlockRow, aPos - 2, aSubFunction, aSubFunctionParamsData, aSubFunctionResult);//����� ��������� ������ ����� �� ������ ������� ���������� ��������, ������ ����� ��������. ��� �������� ��� ����������� ������ ������� -1(������ �� ��������� ������� ������ �����) � ��� ��� -1(������� ������������� ������) ����� -2)
      end;

      if result <> sfrrOkay then break;//��� return ��� break ��� continue ��� throw

    end else begin
      //������ ������ ���
      break;
    end;
  end;
end;

function TASLSolveSubFunction.InternalSolveSubFunctionBlockIf(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aSubFunction:AnsiString; var aSubFunctionParamsData:variant; out aSubFunctionResult:variant):TSubFunctionRowResult;
  var tmpToken: AnsiString;
      tmpIdToken: TIdToken;
      tmpIfResult: variant;
      tmpPosStatement: integer;
      tmpPosCommandBlock: integer;
begin
  result := sfrrOkay;

  //������ ������������� ������
  if (not TokenNext(aPos, aPosTo, aSubFunction, @tmpToken, @tmpIdToken)) or (tmpIdToken <> tknBracketOpen) then raise exception.createfmt(cnExpectStatement, [TokenById(tknBracketOpen)]);

  //����� ��� � ������
  tmpPosStatement := aPos;//��������� ���. ����. ������
  InternalSkipBracketsFrom(aPos, aPosTo, aSubFunction, tknBracketOpen, tknBracketClose);//�������������� �� ���. ����. ������
  tmpIfResult := InternalSolveStatement(aASLSolveSubFunctionEvents, tmpPosStatement, aPos - 2, aSubFunction);//����� �������//����� ��������� ������ ����� �� ������ ������� ���������� ��������, ������ ����� ��������. ��� �������� ��� ����������� ������ ������� -1(������ �� ��������� ������� ������ �����) � ��� ��� -1(������� ������������� ������) ����� -2)

  //�������� ��� boolean
  if VarType(tmpIfResult) <> varBoolean then raise exception.createfmt(cnInvalidValueOfOperand, [IntToStr(integer(VarType(tmpIfResult))), 'if']);

  //���� ������� ����� then
  tmpPosCommandBlock := aPos;
  InternalSkipNextCommandBlock(aPos, aPosTo, aSubFunction, true);

  if tmpIfResult then begin
    //true, ����� then
    result := InternalSolveSubFunctionBlock(aASLSolveSubFunctionEvents, tmpPosCommandBlock, aPos - 1{�������. �� ����� ������ �����}, aSubFunction, aSubFunctionParamsData, aSubFunctionResult);

    //��������� else
    InternalSkipNextIfElse(aPos, aPosTo, aSubFunction, false);
  end else begin
    //false, ����� else(���� ����)
    if InternalTokenNextIfIs(aPos, aPosTo, aSubFunction, @tmpToken, nil, tknElse) then begin
      if InternalTokenNextIfIs(aPos, aPosTo, aSubFunction, @tmpToken, nil, tknIf) then begin
        //�����������: else if
        result := InternalSolveSubFunctionBlockIf(aASLSolveSubFunctionEvents, aPos, aPosTo, aSubFunction, aSubFunctionParamsData, aSubFunctionResult);
      end else begin
        //����� �� ���� ������
        tmpPosCommandBlock := aPos;
        InternalSkipNextCommandBlock(aPos, aPosTo, aSubFunction, true);
        //�����
        result := InternalSolveSubFunctionBlock(aASLSolveSubFunctionEvents, tmpPosCommandBlock, aPos - 1{�������. �� ����� ������ �����}, aSubFunction, aSubFunctionParamsData, aSubFunctionResult);
      end;
    end;
  end;
end;

function TASLSolveSubFunction.InternalSolveSubFunctionBlockTryFinally(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; aPosTry:integer; aPosTryTo:integer; const aSubFunction:AnsiString; var aSubFunctionParamsData:variant; out aSubFunctionResult:variant):TSubFunctionRowResult;
  var tmpIdToken: TIdToken;
      tmpPosSubFinallyBegin: integer;
      tmpSubFunctionRowResult: TSubFunctionRowResult;
begin
  //�� ����� ������ ���: try { ... } finally|{ ... }

  //�������� �� {
  if (not TokenNext(aPos, aPosTo, aSubFunction, nil, @tmpIdToken)) or (tmpIdToken <> tknFigureBracketOpen) then raise exception.createfmt(cnExpectStatement, [TokenById(tknFigureBracketOpen)]);

  //������ }
  tmpPosSubFinallyBegin := aPos;//���� ���. ����. ������
  InternalSkipBracketsFrom(aPos, aPosTo, aSubFunction, tknFigureBracketOpen, tknFigureBracketClose);//������� ����. ������

  //������ aPos ���: try { ... } finally { ... }|

  try
    result := InternalSolveSubFunctionBlock(aASLSolveSubFunctionEvents, aPosTry, aPosTryTo, aSubFunction, aSubFunctionParamsData, aSubFunctionResult);//����� ��������� ������ ����� �� ������ ������� ���������� ��������, ������ ����� ��������. ��� �������� ��� ����������� ������ ������� -1(������ �� ��������� ������� ������ �����) � ��� ��� -1(������� ������������� ������) ����� -2)
  finally
    tmpSubFunctionRowResult := InternalSolveSubFunctionBlock(aASLSolveSubFunctionEvents, tmpPosSubFinallyBegin, aPos - 2, aSubFunction, aSubFunctionParamsData, aSubFunctionResult);//����� ��������� ������ ����� �� ������ ������� ���������� ��������, ������ ����� ��������. ��� �������� ��� ����������� ������ ������� -1(������ �� ��������� ������� ������ �����) � ��� ��� -1(������� ������������� ������) ����� -2)
    if tmpSubFunctionRowResult <> sfrrOkay then raise exception.createfmt(cnInvalidValueOf, [IntToStr(integer(tmpSubFunctionRowResult)), 'try-finally result']);
  end;

end;

procedure TASLSolveSubFunction.InternalSubExceptionAdd(const aExceptionList:TStringList; const aExceptionName:AnsiString; aObject:Pointer);
begin
  if not assigned(aExceptionList) then raise exception.createfmt(cnValueNotAssigned, ['aExceptionList']);

  aExceptionList.Objects[aExceptionList.Add(AnsiUpperCase(aExceptionName))] := aObject;
end;

procedure TASLSolveSubFunction.InternalSubExceptionDeleteByName(const aExceptionList:TStringList; aExceptionName:AnsiString);
  var tmpI: integer;
begin
  if not assigned(aExceptionList) then raise exception.createfmt(cnValueNotAssigned, ['aExceptionList']);

  aExceptionName := AnsiUpperCase(aExceptionName);

  for tmpI := aExceptionList.count -1 downto 0 do begin
    if aExceptionList.Strings[tmpI] = aExceptionName then begin
      aExceptionList.Delete(tmpI);
      break;
    end;
  end;
end;

function TASLSolveSubFunction.InternalSolveSubFunctionBlockTryCatch(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; aPosTry:integer; aPosTryTo:integer; const aSubFunction:AnsiString; var aSubFunctionParamsData:variant; out aSubFunctionResult:variant):TSubFunctionRowResult;
  var tmpExceptionName: AnsiString;
      tmpIdToken: TIdToken;
      tmpPosSubCatchBegin: integer;
      tmpSubFunctionRowResult: TSubFunctionRowResult;
begin
  //�� ����� ������ ���: try { ... } catch|-- (Exception e)
  //                                        \ { ... }

  //�������� �� {
  if not TokenNext(aPos, aPosTo, aSubFunction, nil, @tmpIdToken) then raise exception.createfmt(cnExpectStatement, [TokenById(tknFigureBracketOpen)]);

  //��������� ���� �� ��� exception
  tmpExceptionName := '';//��������� ������ ���
  if tmpIdToken = tknBracketOpen then begin//����� (
    //��� exception
    if (not TokenNext(aPos, aPosTo, aSubFunction, nil, @tmpIdToken)) or (tmpIdToken <> tknException) then raise exception.createfmt(cnExpectStatement, [TokenById(tknException)]);
    //��� ��� exception
    if (not TokenNext(aPos, aPosTo, aSubFunction, @tmpExceptionName, @tmpIdToken)) or (tmpIdToken <> tknWord) then raise exception.createfmt(cnInvalidStatement, [tmpExceptionName]);
    //��� )
    if (not TokenNext(aPos, aPosTo, aSubFunction, nil, @tmpIdToken)) or (tmpIdToken <> tknBracketClose) then raise exception.createfmt(cnExpectStatement, [TokenById(tknBracketClose)]);
    //��� {
    if not TokenNext(aPos, aPosTo, aSubFunction, nil, @tmpIdToken) then raise exception.createfmt(cnExpectStatement, [TokenById(tknFigureBracketOpen)]);

  end;

  if tmpIdToken <> tknFigureBracketOpen then raise exception.createfmt(cnExpectStatement, [TokenById(tknFigureBracketOpen)]);//������� ���� �� ����


  //������ }
  tmpPosSubCatchBegin := aPos;//���� ���. ����. ������
  InternalSkipBracketsFrom(aPos, aPosTo, aSubFunction, tknFigureBracketOpen, tknFigureBracketClose);//������� ����. ������

  //������ aPos ���: try { ... } catch { ... }|

  result := sfrrOkay;//�� ���������
  try
    result := InternalSolveSubFunctionBlock(aASLSolveSubFunctionEvents, aPosTry, aPosTryTo, aSubFunction, aSubFunctionParamsData, aSubFunctionResult);//����� ��������� ������ ����� �� ������ ������� ���������� ��������, ������ ����� ��������. ��� �������� ��� ����������� ������ ������� -1(������ �� ��������� ������� ������ �����) � ��� ��� -1(������� ������������� ������) ����� -2)
  except on e:exception do begin
    //����������� ���� ����������

    if tmpExceptionName <> '' then begin
      if not assigned(aASLSolveSubFunctionEvents.aUserData) then raise exception.createfmt(cnValueNotAssigned, ['aUserData']);
      InternalSubExceptionAdd(TPSolveSubFunctionRec(aASLSolveSubFunctionEvents.aUserData)^.aExceptionList, tmpExceptionName, pointer(e));
    end;
    try
      tmpSubFunctionRowResult := InternalSolveSubFunctionBlock(aASLSolveSubFunctionEvents, tmpPosSubCatchBegin, aPos - 2, aSubFunction, aSubFunctionParamsData, aSubFunctionResult);//����� ��������� ������ ����� �� ������ ������� ���������� ��������, ������ ����� ��������. ��� �������� ��� ����������� ������ ������� -1(������ �� ��������� ������� ������ �����) � ��� ��� -1(������� ������������� ������) ����� -2)
    finally
      if tmpExceptionName <> '' then InternalSubExceptionDeleteByName(TPSolveSubFunctionRec(aASLSolveSubFunctionEvents.aUserData)^.aExceptionList, tmpExceptionName);
    end;

    if tmpSubFunctionRowResult = sfrrThrow then begin
      raise;
    end else if tmpSubFunctionRowResult <> sfrrOkay then raise exception.createfmt(cnInvalidValueOf, [IntToStr(integer(tmpSubFunctionRowResult)), 'try-finally result']);
  end;end;

end;

function TASLSolveSubFunction.InternalSolveSubFunctionBlockTry(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aSubFunction:AnsiString; var aSubFunctionParamsData:variant; out aSubFunctionResult:variant):TSubFunctionRowResult;
  var tmpToken: AnsiString;
      tmpIdToken: TIdToken;
      tmpPosSubTryBegin, tmpPosSubTryEnd: integer;
begin
  //  try{          try{         try{
  //    ..            ..           throw Exception('My exception message');
  //  }finally{     }catch{      }catch(exception e1){
  //    ..            ..           e1.Message = '???' + e1.message;
  //  }             }              throw;
  //                             }

  //�������� �� {
  if (not TokenNext(aPos, aPosTo, aSubFunction, @tmpToken, @tmpIdToken)) or (tmpIdToken <> tknFigureBracketOpen) then raise exception.createfmt(cnExpectStatement, [TokenById(tknFigureBracketOpen)]);

  //������ }
  tmpPosSubTryBegin := aPos;//���� ���. ����. ������
  InternalSkipBracketsFrom(aPos, aPosTo, aSubFunction, tknFigureBracketOpen, tknFigureBracketClose);//������� ����. ������

  //���� ���. ����. ������
  tmpPosSubTryEnd := aPos -2;

  //������ ��� �����
  if not TokenNext(aPos, aPosTo, aSubFunction, @tmpToken, @tmpIdToken) then raise exception.createfmt(cnExpectStatement, [TokenById(tknFinally)]);

  case tmpIdToken of
    tknFinally:begin
      result := InternalSolveSubFunctionBlockTryFinally(aASLSolveSubFunctionEvents, aPos, aPosTo, tmpPosSubTryBegin, tmpPosSubTryEnd, aSubFunction, aSubFunctionParamsData, aSubFunctionResult);
    end;
    tknCatch:begin
      result := InternalSolveSubFunctionBlockTryCatch(aASLSolveSubFunctionEvents, aPos, aPosTo, tmpPosSubTryBegin, tmpPosSubTryEnd, aSubFunction, aSubFunctionParamsData, aSubFunctionResult);
    end;
  else
    raise exception.createfmt(cnExpectStatement, [TokenById(tknFinally)]);
  end;

end;

function TASLSolveSubFunction.InternalSolveSubFunctionBlockWhile(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aSubFunction:AnsiString; var aSubFunctionParamsData:variant; out aSubFunctionResult:variant):TSubFunctionRowResult;
  var tmpToken: AnsiString;
      tmpIdToken: TIdToken;
      tmpIfResult: variant;
      tmpPosIfBegin, tmpPosIfEnd: integer;
      tmpPosBlockBegin, tmpPosBlockEnd: integer;
      tmpSubFunctionRowResult: TSubFunctionRowResult;
      tmpSubFunctionResult: variant;
      tmpPos: integer;
begin
  result := sfrrOkay;
  aSubFunctionResult := unassigned;

  //������ ������������� ������
  if (not TokenNext(aPos, aPosTo, aSubFunction, @tmpToken, @tmpIdToken)) or (tmpIdToken <> tknBracketOpen) then raise exception.createfmt(cnExpectStatement, [TokenById(tknBracketOpen)]);

  //��������� ������� ������
  tmpPosIfBegin := aPos;//��������� ���. ����. ������
  InternalSkipBracketsFrom(aPos, aPosTo, aSubFunction, tknBracketOpen, tknBracketClose);//�������������� �� ���. ����. ������
  tmpPosIfEnd := aPos - 2;//-����� ����� � -������

  //��������� ������� �����
  tmpPosBlockBegin := aPos;
  InternalSkipNextCommandBlock(aPos, aPosTo, aSubFunction, true);
  tmpPosBlockEnd := aPos - 1;//-����� �����

  while true do begin
    tmpPos := tmpPosIfBegin;

    tmpIfResult := InternalSolveStatement(aASLSolveSubFunctionEvents, tmpPos, tmpPosIfEnd, aSubFunction);//����� �������

    //�������� ��� boolean
    if VarType(tmpIfResult) <> varBoolean then raise exception.createfmt(cnInvalidValueOfOperand, [IntToStr(integer(VarType(tmpIfResult))), 'while']);

    //�������� �� �����
    if not tmpIfResult then break;

    //�������� ����
    tmpPos := tmpPosBlockBegin;
    tmpSubFunctionRowResult := InternalSolveSubFunctionBlock(aASLSolveSubFunctionEvents, tmpPos, tmpPosBlockEnd, aSubFunction, aSubFunctionParamsData, tmpSubFunctionResult);

    //�������� ���������� ����������
    case tmpSubFunctionRowResult of
      sfrrOkay:begin
      end;
      sfrrBreak:begin
        //������� ������� ����
        break;
      end;
      sfrrContinue:begin
        continue;
      end;
      sfrrReturn:begin
        aSubFunctionResult := tmpSubFunctionResult;
        result := sfrrReturn;
        break;
      end;
      sfrrThrow:begin//���� ���� � catch
        result := sfrrThrow;
        break;
      end;
    else
      raise exception.createfmt(cnInvalidValueOf, [IntToStr(integer(tmpSubFunctionRowResult)), 'Function result']);
    end;
  end;
end;

function TASLSolveSubFunction.InternalSolveSubFunctionBlockRow(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aSubFunction:AnsiString; var aSubFunctionParamsData:variant; out aSubFunctionRowResult:variant):TSubFunctionRowResult;
  var tmpToken: AnsiString;
      tmpIdToken: TIdToken;
      tmpName: AnsiString;
      tmpIndex: variant;
      tmpFunctionSolvedParamsArray: TFunctionParam;
      tmpIsSubFunction: boolean;
      tmpPos: integer;
begin
  //declare tmpI
  //tmpI = 33 + 1 + aParams[0];
  //MyFunc(1, '3', MyProp);
  //return '12' + MyProp1

  result := sfrrOkay;
  aSubFunctionRowResult := unassigned;

  if TokenNext(aPos, aPosTo, aSubFunction, @tmpToken, @tmpIdToken) then begin
    case tmpIdToken of
      tknDeclare:begin
        //declare tmpI / declare tmpI[33, 1]
        //InternalGetNextTokenPropertyNoOut(aASLSolveSubFunctionEvents, aPos, aPosTo, aSubFunction, tmpName, tmpIndex, true);
        //if TokenNext(aPos, aPosTo, aSubFunction, @tmpToken, @tmpIdToken) then raise exception.createfmt(cnInvalidStatement, [tmpToken]);

        InternalSubFunctionRowDeclare(aASLSolveSubFunctionEvents, aPos, aPosTo, aSubFunction);
      end;
      tknReturn:begin
        //return 1 / return 'aa' + MyProp[33]
        aSubFunctionRowResult := InternalSolveStatement(aASLSolveSubFunctionEvents, aPos, aPosTo, aSubFunction);

        //�������� ����� ������ ������ �� ����
        if TokenNext(aPos, aPosTo, aSubFunction, @tmpToken, @tmpIdToken) then raise exception.createfmt(cnInvalidStatement, [tmpToken]);

        result := sfrrReturn;//�������� SubFinction
      end;
      tknBreak:begin
        //�������� ����� ������ ������ �� ����
        if TokenNext(aPos, aPosTo, aSubFunction, @tmpToken, @tmpIdToken) then raise exception.createfmt(cnInvalidStatement, [tmpToken]);

        result := sfrrBreak;//������� block ��� Break
      end;
      tknContinue:begin
        //�������� ����� ������ ������ �� ����
        if TokenNext(aPos, aPosTo, aSubFunction, @tmpToken, @tmpIdToken) then raise exception.createfmt(cnInvalidStatement, [tmpToken]);

        result := sfrrContinue;//������� block ��� Continue
      end;
      tknThrow:begin
        //�������� ����� ������ ������ �� ����
        // throw;
        // throw exception('123');
        if TokenNext(aPos, aPosTo, aSubFunction, @tmpToken, @tmpIdToken) then begin
          //��� exception
          if tmpIdToken <> tknException then raise exception.createfmt(cnInvalidStatement, [tmpToken]);
          //��� (
          if (not TokenNext(aPos, aPosTo, aSubFunction, @tmpToken, @tmpIdToken)) or (tmpIdToken <> tknBracketOpen) then raise exception.createfmt(cnExpectStatement, [TokenById(tknBracketOpen)]);
          //��������� ���. � ������
          tmpPos := aPos;
          //��� )
          InternalSkipBracketsFrom(aPos, aPosTo, aSubFunction, tknBracketOpen, tknBracketClose);//������� ����. ������
          //����� ��������� ���������
          aSubFunctionRowResult := InternalSolveStatement(aASLSolveSubFunctionEvents, tmpPos, aPos - 2, aSubFunction);

          if (VarType(aSubFunctionRowResult) <> varOleStr) and (VarType(aSubFunctionRowResult) <> varString) then raise exception.createfmt(cnExpectType, ['STRING']);

          raise exception.create(aSubFunctionRowResult);

        end else begin
          result := sfrrThrow;//������� block ��� catch
        end;
      end;
      tknWord, tknExec:begin
        //MyFunc(1, '3', MyProp);
        //Exec MySubFunc(1, '3', MyProp);
        //tmpI = 33 + 1 + aParams[0]; / tmpI[11] = MyFunc();

        if InternalGetCurrTokenFunction(aASLSolveSubFunctionEvents, tmpToken, tmpIdToken, aPos, aPosTo, aSubFunction, tmpName, tmpFunctionSolvedParamsArray, tmpIsSubFunction, false) then begin
          //��� �������
          InternalGetFunctionValue(aASLSolveSubFunctionEvents, tmpName, tmpFunctionSolvedParamsArray, tmpIsSubFunction);
        end else if InternalGetCurrTokenPropertyNoOut(aASLSolveSubFunctionEvents, tmpToken, tmpIdToken, aPos, aPosTo, aSubFunction, tmpName, tmpIndex, false) then begin
          //��� ��������
          // tmpI[33] = MyFun(1) + '11';
          if (not TokenNext(aPos, aPosTo, aSubFunction, @tmpToken, @tmpIdToken)) or (tmpIdToken <> tknOperatorEqual) or (tmpToken <> '=') then raise exception.createfmt(cnExpectStatement, ['=']);//�������� ������ '='

          InternalSetPropertyValue(aASLSolveSubFunctionEvents, tmpName, tmpIndex, InternalSolveStatement(aASLSolveSubFunctionEvents, aPos, aPosTo, aSubFunction));
        end else begin
          raise exception.createfmt(cnInvalidStatement, [tmpToken]);
        end;
      end;
    else
      raise exception.createfmt(cnInvalidStatement, [tmpToken]);
    end;
  end;
end;

function TASLSolveSubFunction.InternalSkipNextCommandBlock(var aPos:integer; aPosTo:integer; const aSubFunction:AnsiString; aRaise:boolean):boolean;
  var tmpToken: AnsiString;
      tmpIdToken: TIdToken;
begin
  //������ �������
  if not TokenNext(aPos, aPosTo, aSubFunction, @tmpToken, @tmpIdToken) then begin
    if aRaise then raise exception.createfmt(cnExpectStatement, [TokenById(tknFigureBracketOpen)]);
    result := false;
    exit;
  end;

  result := true;

  if tmpIdToken = tknFigureBracketOpen then begin
    //��� ���� ������, ��� ��� � { .. }
    InternalSkipBracketsFrom(aPos, aPosTo, aSubFunction, tknFigureBracketOpen, tknFigureBracketClose);
  end else if tmpIdToken = tknDotWithComma then begin
    // ��� ; �.�. ������ ��������
    // ������ �� ����� �.�. ; ��� ���������
  end else begin
    //��� ���� �������, ��� ;
    InternalSkipBracketsTo(aPos, aPosTo, aSubFunction, tknDotWithComma);
  end;
end;

function TASLSolveSubFunction.InternalSkipNextIfElse(var aPos:integer; aPosTo:integer; const aSubFunction:AnsiString; aRaise:boolean):boolean;
  var tmpToken: AnsiString;
begin
  result := true;

  if InternalTokenNextIfIs(aPos, aPosTo, aSubFunction, @tmpToken, nil, tknElse) then begin
    //��� else
    //������ �������
    if InternalTokenNextIfIs(aPos, aPosTo, aSubFunction, @tmpToken, nil, tknIf) then begin
      InternalSkipIf(aPos, aPosTo, aSubFunction);
    end else begin
      InternalSkipNextCommandBlock(aPos, aPosTo, aSubFunction, true);
    end;

  end else begin
    //��� ��� else
    if aRaise then raise exception.createfmt(cnExpectStatement, [TokenById(tknElse)]);
    result := false;
  end;
end;

function TASLSolveSubFunction.InternalGetNextTokenPropertyNoOut(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aStatement:AnsiString; out aName:AnsiString; out aIndex:variant; aRaise:boolean):boolean;
  var tmpIsOut:boolean;
begin
  result := InternalGetNextTokenProperty(aASLSolveSubFunctionEvents, aPos, aPosTo, aStatement, aName, aIndex, tmpIsOut, aRaise);
  if tmpIsOut then begin
    if aRaise then raise exception.createfmt(cnInvalidStatement, [TokenById(tknOut)]);
    result := false;
    exit;
  end;
end;

procedure TASLSolveSubFunction.InternalSubFunctionRowDeclare(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aSubFunction:AnsiString);
  var tmpToken: AnsiString;
      tmpIdToken: TIdToken;
      tmpDeclareIndex: variant;
begin

  while true do begin
    if not InternalGetNextTokenPropertyNoOut(aASLSolveSubFunctionEvents, aPos, aPosTo, aSubFunction, tmpToken, tmpDeclareIndex, false) then break;

    InternalDeclareListAdd(aASLSolveSubFunctionEvents, tmpToken, tmpDeclareIndex);

    //�������� ������� ����� �����������
    if (TokenNext(aPos, aPosTo, aSubFunction, @tmpToken, @tmpIdToken)) and ((tmpIdToken <> tknComma) or (aPos > aPosTo)) then
        raise exception.createfmt(cnInvalidStatement, [tmpToken]);

  end;
end;

procedure TASLSolveSubFunction.InternalDeclareListClearVarData(const aDeclareList: TStringList);
  var tmpI: integer;
      tmpPVariant: PVariant;
begin
  for tmpI := 0 to aDeclareList.Count - 1 do begin
    tmpPVariant := PVariant(aDeclareList.Objects[tmpI]);
    tmpPVariant^ := unassigned;
    dispose(tmpPVariant);

    aDeclareList.Objects[tmpI] := nil;//��� ��� �������
  end;
end;

function TASLSolveSubFunction.InternalStringListIn(const aStringList: TStringList; const aName:AnsiString; aRaise: boolean):boolean;
begin
  result := aStringList.IndexOf(aName) >= 0;

  if result and aRaise then begin
    raise exception.create('''' +aName+''' already exists');
  end;
end;

procedure TASLSolveSubFunction.InternalDeclareListAdd(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; const aName:AnsiString; const aIndex:variant);
  var tmpPSolveSubFunctionRec: TPSolveSubFunctionRec;
      tmpPVariant: PVariant;
      tmpIndex: integer;
      tmpIndexIndex: integer;
begin

  if VarIsEmpty(aIndex) then begin
    tmpIndexIndex := -1;
  end else if VarIsArray(aIndex) and ((VarType(aIndex[0]) and varInteger) = varInteger) and (VarArrayHighBound(aIndex, 1) = 0) and (integer(aIndex[0]) > 0) then begin
    tmpIndexIndex := aIndex[0];
  end else raise exception.create('Invalid index value for declaration '''+aName+'''.');

  tmpPSolveSubFunctionRec := TPSolveSubFunctionRec(aASLSolveSubFunctionEvents.aUserData);

  InternalStringListIn(tmpPSolveSubFunctionRec^.aSubFunctionParamsList, aName, true);
  InternalStringListIn(tmpPSolveSubFunctionRec^.aExceptionList, aName, true);
  InternalStringListIn(tmpPSolveSubFunctionRec^.aDeclareList, aName, true);

  tmpIndex := tmpPSolveSubFunctionRec^.aDeclareList.Add(AnsiUpperCase(AnsiUpperCase(aName)));

  new(tmpPVariant);
  try
    if tmpIndexIndex > 0 then begin
      tmpPVariant^ := VarArrayCreate([0, tmpIndexIndex-1], varVariant);
    end else begin
      tmpPVariant^ := unassigned;
    end;

    tmpPSolveSubFunctionRec^.aDeclareList.Objects[tmpIndex] := pointer(tmpPVariant);
  except
    dispose(tmpPVariant);
    raise;
  end;
end;

function TASLSolveSubFunction.InternalGetCurrTokenPropertyNoOut(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; const aToken:AnsiString; aIdToken:TIdToken; var aPos:integer; aPosTo:integer; const aStatement:AnsiString; out aName:AnsiString; out aIndex:variant; aRaise:boolean):boolean;
  var tmpIsOut:boolean;
begin
  result := InternalGetCurrTokenProperty(aASLSolveSubFunctionEvents, aToken, aIdToken, aPos, aPosTo, aStatement, aName, aIndex, tmpIsOut, aRaise);
  if tmpIsOut then begin
    if aRaise then raise exception.createfmt(cnInvalidStatement, [TokenById(tknOut)]);
    result := false;
    exit;
  end;
end;

procedure TASLSolveSubFunction.InternalSkipIf(var aPos:integer; aPosTo:integer; const aSubFunction:AnsiString);
  var tmpToken: AnsiString;
      tmpIdToken: TIdToken;
begin
  if (not TokenNext(aPos, aPosTo, aSubFunction, @tmpToken, @tmpIdToken)) or (tmpIdToken <> tknBracketOpen) then raise exception.createfmt(cnExpectStatement, [TokenById(tknBracketOpen)]);

  //��������� ������
  InternalSkipBracketsFrom(aPos, aPosTo, aSubFunction, tknBracketOpen, tknBracketClose);//�������������� �� ���. ����. ������

  //��������� then
  InternalSkipNextCommandBlock(aPos, aPosTo, aSubFunction, true);

  //��������� else
  InternalSkipNextIfElse(aPos, aPosTo, aSubFunction, false);
end;

function TASLSolveSubFunction.InternalGetNextTokenProperty(const aASLSolveSubFunctionEvents:TASLSolveStatementEvents; var aPos:integer; aPosTo:integer; const aStatement:AnsiString; out aName:AnsiString; out aIndex:variant; out aIsOut:boolean; aRaise:boolean):boolean;
  var tmpToken: AnsiString;
      tmpIdToken: TIdToken;
      tmpPos:integer;
begin
  tmpPos := aPos;

  if TokenNext(tmpPos, aPosTo, aStatement, @tmpToken, @tmpIdToken) then begin
    result := InternalGetCurrTokenProperty(aASLSolveSubFunctionEvents, tmpToken, tmpIdToken, tmpPos, aPosTo, aStatement, aName, aIndex, aIsOut, aRaise);

    if result then aPos := tmpPos;
  end else begin
    if aRaise then raise exception.createfmt(cnExpectStatement, ['name of property']);
    result := false;
    exit;
  end;
end;

function TASLSolveSubFunction.InternalGetPropertyValueSubFunctionParams(const aSubFunctionParamsList:TStringList; aPSubFunctionParamsData:PVariant; aName:AnsiString; const aPropertyIndex:variant; out aResult:variant):boolean;
  var tmpI: integer;
begin
  if not assigned(aPSubFunctionParamsData) then raise exception.createfmt(cnValueNotAssigned, ['aPSubFunctionParamsData']);

  aName := AnsiUpperCase(aName);//�������� �������

  result := false;

  for tmpI := 0 to aSubFunctionParamsList.count - 1 do begin
    if aSubFunctionParamsList.Strings[tmpI] = aName then begin//� aSubFunctionParamsList ������� ������
      if not VarIsEmpty(aPropertyIndex) then raise exception.create('For params '''+aName+''' PropertyIndex must be empty.');
      aResult := aPSubFunctionParamsData^[integer(aSubFunctionParamsList.Objects[tmpI])];//����� �� ������� �������
      result := true;
      break;
    end;
  end;
end;

{$IFDEF VER130} //For varTypes, from D6
const
  varShortInt=$0010;{ vt_i1  16 }
  varWord=$0012;{ vt_ui2 18 }
  varLongWord=$0013;{ vt_ui4 19 }
  varInt64=$0014;{ vt_i8  20 }
{$ENDIF}

function TASLSolveSubFunction.InternalVarIsInteger(aVarType: integer):boolean;
begin
  result := (aVarType = varInteger) or (aVarType = varByte) or (aVarType = varSmallint) or (aVarType = varShortInt) or (aVarType = varWord) or (aVarType = varLongWord) or (aVarType = varInt64);
end;

function TASLSolveSubFunction.InternalGetPropertyValueSubFunctionDeclaration(const aDeclareList:TStringList; aName:AnsiString; const aPropertyIndex:variant; out aResult:variant):boolean;
  var tmpI: integer;
      tmpPVariant: PVariant;
begin
  result := false;

  aName := AnsiUpperCase(aName);

  for tmpI := aDeclareList.count - 1 downto 0 do begin
    if aDeclareList.Strings[tmpI] = aName then begin//� aExceptionList ������� ������
      tmpPVariant := pointer(aDeclareList.Objects[tmpI]);

      if VarIsEmpty(aPropertyIndex) then begin
        aResult := tmpPVariant^;
      end else begin
        if (not VarIsArray(aPropertyIndex)) or (VarArrayHighBound(aPropertyIndex, 1) <> 0) or (not InternalVarIsInteger(VarType(aPropertyIndex[0]) and (not varArray))) then raise exception.create('Invalid index value for local declaration '''+aName+'''.');
        aResult := tmpPVariant^[aPropertyIndex[0]];
      end;

      result := true;
      break;
    end;
  end;
end;

function TASLSolveSubFunction.InternalGetPropertyValueSubFunctionExceptions(const aExceptionList:TStringList; aName:AnsiString; const aPropertyIndex:variant; out aResult:variant):boolean;
  var tmpI: integer;
      tmpObject: TObject;
begin
  result := false;

  if AnsiUpperCase(copy(aName, length(aName) - 7, 8)) = '.MESSAGE' then begin//������ ��� e.message
    //��������� .message
    aName := AnsiUpperCase(copy(aName, 1, length(aName) - 8));//� �������� �������

    for tmpI := aExceptionList.count - 1 downto 0 do begin
      if aExceptionList.Strings[tmpI] = aName then begin//� aExceptionList ������� ������
        if not VarIsEmpty(aPropertyIndex) then raise exception.create('For exception '''+aName+''' PropertyIndex must be empty.');

        tmpObject := aExceptionList.Objects[tmpI];
        if (not assigned(tmpObject)) or (not (tmpObject is Exception)) then raise exception.createfmt(cnInvalidValueOf, ['undetected', 'aExceptionList.Objects[tmpI]']);
        aResult := Exception(tmpObject).Message;
        result := true;
        break;
      end;
    end;
  end;
end;

function TASLSolveSubFunction.InternalGetPropertyValue(const aASLSolveStatementEvents:TASLSolveStatementEvents; const aName:AnsiString; const aPropertyIndex:variant):variant;
  var tmpPSolveSubFunctionRec: TPSolveSubFunctionRec;
begin
  if not assigned(aASLSolveStatementEvents.aUserData) then raise exception.createfmt(cnValueNotAssigned, ['aUserData']);

  tmpPSolveSubFunctionRec := TPSolveSubFunctionRec(aASLSolveStatementEvents.aUserData);

  if (not InternalGetPropertyValueSubFunctionDeclaration(tmpPSolveSubFunctionRec^.aDeclareList, aName, aPropertyIndex, result)) and
      (not InternalGetPropertyValueSubFunctionExceptions(tmpPSolveSubFunctionRec^.aExceptionList, aName, aPropertyIndex, result)) and
       (not InternalGetPropertyValueSubFunctionParams(tmpPSolveSubFunctionRec^.aSubFunctionParamsList, tmpPSolveSubFunctionRec^.aPSubFunctionParamsData, aName, aPropertyIndex, result)) then begin
      result := inherited InternalGetPropertyValue(aASLSolveStatementEvents, aName, aPropertyIndex);
  end;
end;

function TASLSolveSubFunction.InternalSetPropertyValueSubFunctionParams(const aSubFunctionParamsList:TStringList; aPSubFunctionParamsData:PVariant; aName:AnsiString; const aPropertyIndex:variant; const aValue:variant):boolean;
  var tmpI: integer;
begin
  if not assigned(aPSubFunctionParamsData) then raise exception.createfmt(cnValueNotAssigned, ['aPSubFunctionParamsData']);

  aName := AnsiUpperCase(aName);//�������� �������

  result := false;

  for tmpI := 0 to aSubFunctionParamsList.count - 1 do begin
    if aSubFunctionParamsList.Strings[tmpI] = aName then begin//� aSubFunctionParamsList ������� ������
      if not VarIsEmpty(aPropertyIndex) then raise exception.create('For params '''+aName+''' PropertyIndex must be empty.');
      aPSubFunctionParamsData^[integer(aSubFunctionParamsList.Objects[tmpI])] := aValue;//����� �� ������� �������
      result := true;
      break;
    end;
  end;
end;

function TASLSolveSubFunction.InternalSetPropertyValueSubFunctionDeclaration(const aDeclareList:TStringList; aName:AnsiString; const aPropertyIndex:variant; const aValue:variant):boolean;
  var tmpI: integer;
      tmpPVariant: PVariant;
begin
  result := false;

  aName := AnsiUpperCase(aName);

  for tmpI := aDeclareList.count - 1 downto 0 do begin
    if aDeclareList.Strings[tmpI] = aName then begin//� aDeclareList ������� ������
      tmpPVariant := pointer(aDeclareList.Objects[tmpI]);

      if VarIsEmpty(aPropertyIndex) then begin
        tmpPVariant^ := aValue;
      end else begin
        if (not VarIsArray(aPropertyIndex)) or (VarArrayHighBound(aPropertyIndex, 1) <> 0) or (not InternalVarIsInteger(VarType(aPropertyIndex[0]) and (not varArray))) then raise exception.create('Invalid index value for local declaration '''+aName+'''.');
        tmpPVariant^[aPropertyIndex[0]] := aValue;
      end;

      result := true;
      break;
    end;
  end;
end;

function TASLSolveSubFunction.InternalSetPropertyValueSubFunctionExceptions(const aExceptionList:TStringList; aName:AnsiString; const aPropertyIndex:variant; const aValue:variant):boolean;
  var tmpI: integer;
      tmpObject: TObject;
begin
  result := false;

  if AnsiUpperCase(copy(aName, length(aName) - 7, 8)) = '.MESSAGE' then begin//������ ��� e.message
    //��������� .message
    aName := AnsiUpperCase(copy(aName, 1, length(aName) - 8));//� �������� �������

    for tmpI := aExceptionList.count - 1 downto 0 do begin
      if aExceptionList.Strings[tmpI] = aName then begin//� aExceptionList ������� ������
        if not VarIsEmpty(aPropertyIndex) then raise exception.create('For exception '''+aName+''' PropertyIndex must be empty.');

        tmpObject := aExceptionList.Objects[tmpI];
        if (not assigned(tmpObject)) or (not (tmpObject is Exception)) then raise exception.createfmt(cnInvalidValueOf, ['undetected', 'aExceptionList.Objects[tmpI]']);
        Exception(tmpObject).Message := aValue;
        result := true;
        break;
      end;
    end;
  end;
end;

procedure TASLSolveSubFunction.InternalSetPropertyValue(const aASLSolveStatementEvents:TASLSolveStatementEvents; const aName:AnsiString; const aPropertyIndex:variant; const aValue:variant);
  var tmpPSolveSubFunctionRec: TPSolveSubFunctionRec;
begin
  if not assigned(aASLSolveStatementEvents.aUserData) then raise exception.createfmt(cnValueNotAssigned, ['aUserData']);

  tmpPSolveSubFunctionRec := TPSolveSubFunctionRec(aASLSolveStatementEvents.aUserData);

  if (not InternalSetPropertyValueSubFunctionDeclaration(tmpPSolveSubFunctionRec^.aDeclareList, aName, aPropertyIndex, aValue)) and
      (not InternalSetPropertyValueSubFunctionExceptions(tmpPSolveSubFunctionRec^.aExceptionList, aName, aPropertyIndex, aValue)) and
       (not InternalSetPropertyValueSubFunctionParams(tmpPSolveSubFunctionRec^.aSubFunctionParamsList, tmpPSolveSubFunctionRec^.aPSubFunctionParamsData, aName, aPropertyIndex, aValue)) then begin
    inherited InternalSetPropertyValue(aASLSolveStatementEvents, aName, aPropertyIndex, aValue);
  end;
end;

function TASLSolveSubFunction.InternalParamNameToId(const aSubFunctionParamsList:TStringList; aParamName:AnsiString):integer;
  var tmpI: integer;
begin
  aParamName := AnsiUpperCase(aParamName);//�������� �������

  for tmpI := 0 to aSubFunctionParamsList.count - 1 do begin
    if aSubFunctionParamsList.Strings[tmpI] = aParamName then begin//� aSubFunctionParamsList ������� ������
      result := integer(aSubFunctionParamsList.Objects[tmpI]);
      exit;
    end;
  end;

  raise exception.create('Parameter '''+aParamName+''' no found.');
end;

function TASLSolveSubFunction.InternalGetFunctionValue(const aASLSolveStatementEvents:TASLSolveStatementEvents; const aName:AnsiString; aFunctionParam:TFunctionParam; aIsSubFunction:boolean):variant;
  var tmpPSolveSubFunctionRec: TPSolveSubFunctionRec;
begin
  if not assigned(aASLSolveStatementEvents.aUserData) then raise exception.createfmt(cnValueNotAssigned, ['aUserData']);

  tmpPSolveSubFunctionRec := TPSolveSubFunctionRec(aASLSolveStatementEvents.aUserData);

  if AnsiUpperCase(aName) = '@@ISPARAMOUT' then begin
    if not assigned(tmpPSolveSubFunctionRec^.aIsParamOut) then raise exception.createfmt(cnValueNotAssigned, ['aIsParamOut']);

    if aIsSubFunction or VarIsEmpty(aFunctionParam.aParamIn) or (not VarIsEmpty(aFunctionParam.aParamOut){��������� ��� out}) or (not VarIsArray(aFunctionParam.aParamIn)) or ((VarType(aFunctionParam.aParamIn[0]) <> varOleStr) and (VarType(aFunctionParam.aParamIn[0]) <> varString)) then raise exception.create('Invalid using reserved word ''@@ISPARAMOUT''.');
    result := tmpPSolveSubFunctionRec^.aIsParamOut(InternalParamNameToId(tmpPSolveSubFunctionRec^.aSubFunctionParamsList, aFunctionParam.aParamIn[0]));
  end else begin
    result := inherited InternalGetFunctionValue(aASLSolveStatementEvents, aName, aFunctionParam, aIsSubFunction);
  end;  
end;

function TASLSolveSubFunction.InternalUnwrapUserdata(const aASLSolveStatementEvents:TASLSolveStatementEvents):pointer;
begin
  result := TPSolveSubFunctionRec(inherited InternalUnwrapUserdata(aASLSolveStatementEvents))^.aUserData;
end;

end.
