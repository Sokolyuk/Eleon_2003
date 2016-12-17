//------------------------------------------------------
// Dmitry A. Sokolyuk                                  -
// 20.07.01                                            -
// fix for bracket and add SQL command for Transaction -
//                                                     -
//                                    sokolyuk@ksho.ru -
//------------------------------------------------------

Unit USQLParser;

Interface
  Uses SysUtils, SQLParserComp, USQLParserTypes;

Type
  TSetTokenType = Set of TTokenType;

  TSQLCommandParser = Class(TObject)
  Private
    FCheckRepeated:Boolean;
    FParseMode:TParseMode;
  Public
    Constructor Create;
    Function  SkipSymbol(_aQueryParser:TQueryParserComp; InvalidType, BreakType:TSetTokenType; blIfCommaThenBreak:boolean=false):Boolean;
    Procedure SQLCommandToTableName(aSQL:AnsiString; Var aTabResult:Variant);
    Procedure AfterWhereToTableName(_aQueryParser:TQueryParserComp; Var aTabResult:Variant);
    Procedure AfterFromToTableName(_aQueryParser:TQueryParserComp; aSQLCommandType:TSQLCommandType; Var aTabResult:Variant);
    Procedure OneSQLCommandToTableName(aSQL:AnsiString; Var aTabResult:Variant);
    Procedure AnalyseToken(_aQueryParser:TQueryParserComp; aSQLCommandType:TSQLCommandType; Var aTabResult:Variant);
    Procedure AnalyseCommand(_aQueryParser:TQueryParserComp; Var aTabResult:Variant);
    Procedure AnalyseSELECTInBrackets(_aQueryParser:TQueryParserComp; Var aTabResult:Variant; blOnlyOneBracket:Boolean=False);
    Property  CheckRepeated:Boolean read FCheckRepeated write FCheckRepeated;
    Property  ParseMode:TParseMode read FParseMode write FParseMode;
  End;

implementation
  uses variants;

Constructor TSQLCommandParser.Create;
begin
  FCheckRepeated:=True;
  FParseMode:=pmdSQLString;
  Inherited Create;
end;

Function  TSQLCommandParser.SkipSymbol(_aQueryParser:TQueryParserComp; InvalidType, BreakType:TSetTokenType; blIfCommaThenBreak:boolean=false):Boolean;
Begin
  Result:=False;
  While True Do begin
     If _aQueryParser.EOF=True Then Begin
     Break;
    End;
    _aQueryParser.NextToken;
    If (_aQueryParser.TokenType in BreakType) Or ((blIfCommaThenBreak=True)And(_aQueryParser.Token=',')) Then begin
      Result:=True;
      Break;
    End;
    If (_aQueryParser.TokenType in InvalidType)Then begin
      Break;
    end;
  End;
end;

Procedure TSQLCommandParser.AfterWhereToTableName(_aQueryParser:TQueryParserComp; Var aTabResult:Variant);
Begin
  If _aQueryParser.EOF=True Then Exit;
  While True do begin
    // Ищу начало суб выборки
    If _aQueryParser.Token='(' Then begin
      If _aQueryParser.EOF=True Then begin
        Raise Exception.Create('Неправильный синтаксис: ожидается '')''.');
      end;
      AnalyseSELECTInBrackets(_aQueryParser, aTabResult);
      // ..
    end;
    If _aQueryParser.EOF=True Then Break;
    _aQueryParser.NextToken;
  end;
End;
Procedure TSQLCommandParser.AnalyseSELECTInBrackets(_aQueryParser:TQueryParserComp; Var aTabResult:Variant; blOnlyOneBracket:Boolean=False);
  Var iI, iLevel: Integer;
      aSQL:AnsiString;
Begin
  If _aQueryParser.Token<>'(' Then begin
    SkipSymbol(_aQueryParser, [ttString, ttStatementDelimiter, ttSpecialChar, ttSymbol], [], True);
    If _aQueryParser.Token<>'(' Then Raise Exception.Create('Неожиданется символ '''+_aQueryParser.Token+'''.');
  end;
  //теперь пропустил все разделители и установился на '('
  If _aQueryParser.EOF=True Then begin
    Raise Exception.Create('Неправильный синтаксис: ожидается '')''.');
  end;
  //Нашел начало субвыборки
  iI:=0;
  iLevel:=0;
  aSQL:='';
  While True do begin
    If _aQueryParser.Token='(' Then begin
      Inc(iI);
      If iLevel=0 Then Begin
        //если уже не ищет ')'
        SkipSymbol(_aQueryParser, [ttString, ttSpecialChar, ttStatementDelimiter, ttSymbol], [], True);
        If UpperCase(_aQueryParser.Token)='SELECT' Then begin
          iLevel:=iI;
        end;
        Continue;
      End;
    end else begin
      If _aQueryParser.Token=')' Then begin
        If iI>iLevel Then begin
          Dec(iI);
          //Внимание: возможны сленующие режимы работы процедуры:
          //  1) Проматывание пустых скобок. Обычно для Insert >(a,b,c,d)Values>(1,2,3,4)
          //  2) Просмотр скобок в которых заключен суб-Select. Обычно для Insert (a,b,c,d)Values(1,>(Select Id from ss where Num=5),3,4)
          If (blOnlyOneBracket)And({iI}0=iLevel)And(0=iI) Then Break; // Просматриваю только одну скобку, а не все до конца
        end else begin
          //aSQL:=aSQL+_aQueryParser.Token; - чтобы скобка ')' не попала в aSQL
          If (iI=iLevel)And(iLevel>0) Then begin
            //Нашел конец секции
            iLevel:=0;
            Dec(iI);
            If aSQL<>'' Then Begin
              OneSQLCommandToTableName(aSQL, aTabResult); //Вложенный цикл с SELECT
              aSQL:='';
            End;
          end else begin
            Raise Exception.Create('Неправильный синтаксис: не ожидается '')''.');
          end;
          If (blOnlyOneBracket)And(iI=iLevel) Then Break; //Просматриваю только одну скобку, а не все до конца
        end;
      end;
    end;
    //ищу конец субвыборки
    If _aQueryParser.EOF=True Then begin
      If iI>0 Then
        //Если не закрылись все скобки
        Raise Exception.Create('Неправильный синтаксис: ожидается '')''.');
      Exit;
    end;
    If iLevel>0 Then aSQL:=aSQL+_aQueryParser.Token; //если начата секция
    _aQueryParser.NextToken;
  end; //while
  //..
end;

Procedure TSQLCommandParser.AnalyseToken(_aQueryParser:TQueryParserComp; aSQLCommandType:TSQLCommandType; Var aTabResult:Variant);
// Процедура анализирует токен после перечисления имен таблиц
// т.е. для Select и Delete это Where (Select * from t1, t2 >Where .....)
// т.е. для Insert это {Insert into t1, t2 >Values .....)
  Var blVALUE :Boolean;
      {iCountBricet, }iBricketBeforeVALUES, iBricketAfterVALUES:Integer;
Begin
  // Анализирую слово
  Case aSQLCommandType of
    sctInsert:begin
      // sctInsert
      blVALUE:=False;
      iBricketBeforeVALUES:=0;
      iBricketAfterVALUES:=0;
//      iCountBricet:=0;
      While true do begin
        //  Если пропускаю ненужное
        If (_aQueryParser.TokenType<>ttSymbol) And (_aQueryParser.TokenType<>ttSpecialChar) Then Begin
          SkipSymbol(_aQueryParser, [ttString, ttStatementDelimiter, ttSpecialChar, ttSymbol], [], True);
        end;
        If _aQueryParser.EOF=True Then
          If iBricketAfterVALUES=0 Then Raise Exception.Create('Строка неожиданно закончилась.')
            else break;
        If _aQueryParser.Token='(' Then begin
          If Not blVALUE Then Inc(iBricketBeforeVALUES) // если эти скобки до VALUES
                     else Inc(iBricketAfterVALUES);  // если эти скобки после VALUES
          // ..
          AnalyseSELECTInBrackets(_aQueryParser, aTabResult, True);
          _aQueryParser.NextToken;
          If iBricketBeforeVALUES>1 Then Break; // т.е. до VALUES не может быть больше 2 раз '('
          If iBricketAfterVALUES>1 Then Break; // т.е. после VALUES не может быть больше 2 раз '('
          Continue;
        end else
          If UpperCase(_aQueryParser.Token)='VALUES' Then begin
            If blVALUE=True Then Raise Exception.Create('Неожиданется операнд '''+_aQueryParser.Token+'''.');
            _aQueryParser.NextToken;
            blVALUE:=True;
            Continue;
          end else
            If UpperCase(_aQueryParser.Token)='SELECT' Then begin
              AnalyseCommand(_aQueryParser, aTabResult);
            end else
              Raise Exception.Create('Неожиданется символ '''+_aQueryParser.Token+'''.');
        Break;
      end;
    end;
    sctSelect, sctDelete, sctUpdate:begin
     // sctSelect, sctDelete
       // Подгоняю к слову
      If (_aQueryParser.TokenType<>ttSymbol) Or (_aQueryParser.EOF=True) Then begin
        If (SkipSymbol(_aQueryParser, [ttString, ttSpecialChar, ttStatementDelimiter], [ttSymbol], True)=False) Or (_aQueryParser.Token=',') Then begin
          // ... FROM Tab1,,
          If _aQueryParser.EOF=false Then Raise Exception.Create('Неожиданется символ '''+_aQueryParser.Token+'''.');
          Exit;
        end;
      End;
      // ..
      If _aQueryParser.TokenType=ttSymbol Then begin
        If (UpperCase(_aQueryParser.Token)='GROUP') Or (UpperCase(_aQueryParser.Token)='ORDER') Then Begin
          // ..
        end Else
          If (UpperCase(_aQueryParser.Token)='WHERE') Or (UpperCase(_aQueryParser.Token)='HAVING') Then Begin
            _aQueryParser.NextToken; // Пропускаю WHERE
            AfterWhereToTableName(_aQueryParser, aTabResult);
          end Else
            If UpperCase(_aQueryParser.Token)='UNION' Then Begin
              Raise Exception.Create('Анализ операнда UNION не реализован.');
            end Else Begin
              Raise Exception.Create('Неизвестный операнд: '+_aQueryParser.Token+'.');
            End;
      end else begin
        Raise Exception.Create('Неизвестная ошибка.');
      end;
      // sctSelect, sctDelete
    end;
{    sctOther:begin
    end;}
  End;
end;

Procedure TSQLCommandParser.AfterFromToTableName(_aQueryParser:TQueryParserComp; aSQLCommandType:TSQLCommandType; Var aTabResult:Variant);
Var blCurrTableName, blBreak, blEOF : Boolean;
    ivHB:Integer;
    aCurrTableName:AnsiString;
    iCheckRepeatedFound:boolean;
    iIJ:Integer;
    tmpWithFound:Boolean;
begin
  blBreak:=False;
  tmpWithFound:=False;
  If _aQueryParser.EOF=True Then begin
    Raise Exception.Create('Строка неожиданно закончилась.');
  end;
    While True do begin // Сразу запятая True and <>','
      If tmpWithFound Then begin
        tmpWithFound:=False;
      end else begin
        If (_aQueryParser.TokenType<>ttSymbol) {Or (_aQueryParser.EOF=True)} Then begin
          If (SkipSymbol(_aQueryParser, [ttString, ttSpecialChar, ttStatementDelimiter], [ttSymbol], True)=False)Or(_aQueryParser.Token=',')Then begin
            // ... FROM Tab1,,
            If _aQueryParser.EOF Then Raise Exception.Create('Строка неожиданно закончилась.') else Raise Exception.Create('Неправильный синтаксис: ''FROM '+_aQueryParser.Token+'''.');
          end;
        End;
      end;
      // Теперь только ttSymbol, т.е. начало имени таблицы
      blCurrTableName:=False;
      aCurrTableName:=_aQueryParser.Token;
      blEOF:=_aQueryParser.EOF;
      // ..
      Case aSQLCommandType Of
        sctInsert:begin
          If SkipSymbol(_aQueryParser, [ttString, ttStatementDelimiter], [ttSymbol, ttSpecialChar], True)=False Then begin
            // если не спец символ или не символ или не точка, то ошибка
            If _aQueryParser.EOF<>True Then begin
              Raise Exception.Create('Не ожидается символ '''+_aQueryParser.Token+'''.');
            End;
          end;
          If _aQueryParser.TokenType=ttSpecialChar Then Begin
            // Insert into sss (...) Values (...)
            // вышел на ttSpecialChar
            If _aQueryParser.Token='(' Then begin
              blCurrTableName:=True;
              blBreak:=True;
            End else begin
              Raise Exception.Create('Не ожидается символ '''+_aQueryParser.Token+'''.');
            end;
          end;
        End;
        sctSelect, sctDelete, sctUpdate:begin
          If SkipSymbol(_aQueryParser, [ttString, ttStatementDelimiter, ttSpecialChar], [ttSymbol], True)=False Then begin
            // если не спец символ или не символ или не точка, то ошибка
            If _aQueryParser.EOF<>True Then begin
              Raise Exception.Create('Не ожидается символ '''+_aQueryParser.Token+''' возле FROM.');
            End;
          end;
        End;
      End;
      // ..
      If blEOF=True Then Begin
        blCurrTableName:=True;
        blBreak:=True;
      End Else
        If _aQueryParser.Token=',' Then begin
          blCurrTableName:=True;
        End else
          If _aQueryParser.TokenType=ttSymbol Then begin
            blCurrTableName:=True;
            blBreak:=True;
          end else begin
            If (_aQueryParser.EOF=True) And (_aQueryParser.TokenType<>ttSymbol) Then begin
              // From ..., Tab3 #13#10
              blCurrTableName:=True;
              blBreak:=True;
            end else Begin
              If (aSQLCommandType=sctInsert) And (_aQueryParser.Token='(') Then begin
                // ..
                // для случая: insert into Tab1 (Select ...
              end else begin
                Raise Exception.Create('Неизвестная ошибка.');
              end;
            End;
          end;
      If blCurrTableName Then begin
        iCheckRepeatedFound:=false;
        If (VarType(aTabResult) and varArray)=varArray Then begin
          ivHB:=VarArrayHighBound(aTabResult, 1)+1;
          If FCheckRepeated Then begin
            For iIJ:=VarArrayLowBound(aTabResult, 1) to ivHB-1 do begin
              If Uppercase(aTabResult[iIJ][1])=Uppercase(aCurrTableName) then begin
                iCheckRepeatedFound:=true;
                break;
              end;
            end;
          end;
          If Not iCheckRepeatedFound then VarArrayRedim(aTabResult, ivHB);
        end else begin
          aTabResult:=VarArrayCreate([0,0], varVariant);
          ivHB:=0;
        end;
        If Not iCheckRepeatedFound then aTabResult[ivHB]:=VarArrayOf([Integer(aSQLCommandType), Uppercase(aCurrTableName)]);
        //WITH {NOLOCK}
        If aSQLCommandType in [sctSelect, sctDelete, sctUpdate] Then begin
          If (_aQueryParser.TokenType<>ttSymbol) Then begin
            SkipSymbol(_aQueryParser, [ttString, ttSpecialChar, ttStatementDelimiter], [ttSymbol], True);
          End;
          If AnsiUpperCase(_aQueryParser.Token)='WITH' Then begin
            SkipSymbol(_aQueryParser, [ttString, ttSpecialChar, ttStatementDelimiter], [ttSymbol], True);
            if _aQueryParser.Token<>'(' then raise exception.create('Не ожидается символ '''+_aQueryParser.Token+''' возле WITH.');
            while true do begin
              If _aQueryParser.Token=')' Then begin
                If (SkipSymbol(_aQueryParser, [ttString, ttSpecialChar, ttStatementDelimiter], [ttSymbol], True)=False) Then begin
                  If _aQueryParser.EOF Then raise exception.create('Не ожидается символ '''+_aQueryParser.Token+''' возле WITH.');
                end;
                If _aQueryParser.Token=',' then begin
                  //tmpWithFound:=True;
                  blBreak:=_aQueryParser.EOF;
                end else begin
                  blBreak:=true;
                end;
                break;
              end;
              If _aQueryParser.EOF Then Raise Exception.Create('Строка неожиданно закончилась.');
              _aQueryParser.NextToken;
            end;
          end;
        end;
      End;
      If blBreak Then Break;
    End;
end; // AfterFromToTableName

Procedure TSQLCommandParser.AnalyseCommand(_aQueryParser:TQueryParserComp; Var aTabResult:Variant);
  var ivHB:Integer;
      tmpSt:AnsiString;
Begin
    // Проверяю на разделительные символы еще до команды
    If _aQueryParser.TokenType<>ttSymbol Then begin
      If (SkipSymbol(_aQueryParser, [ttString, ttSpecialChar, ttStatementDelimiter], [ttSymbol], True)=False) Or (_aQueryParser.Token=',') Then begin
        If _aQueryParser.EOF Then Exit; // Пустая Строка
        Raise Exception.Create('Не ожидается символ '''+_aQueryParser.Token+''' до SQL команды.');
      end;
    end;
    // Проверяю режим разбора строки
    Case FParseMode of
      pmdSQLString:begin
        // Ожидается SQL выражение.
        // >> После кейса.
      end;
      pmdExecProc:begin
        // Ожидается имя стореной процедуры без команды Exec.
        // Пример: >spu_SaleOper
        tmpSt:=UpperCase(_aQueryParser.Token);
        try
          If SkipSymbol(_aQueryParser, [], [ttSymbol, ttString, ttSpecialChar, ttStatementDelimiter], True) then begin
            Raise Exception.Create('Не ожидается символ '''+_aQueryParser.Token+'''.');
          end;
          If Not _aQueryParser.EOF Then Raise Exception.Create('Не ожидается символ '''+_aQueryParser.Token+'''.');
          // Теперь все проверено и можно добавить в список
          If (VarType(aTabResult) and varArray)=varArray Then begin
            ivHB:=VarArrayHighBound(aTabResult, 1)+1;
            VarArrayRedim(aTabResult, ivHB);
          end else begin
            aTabResult:=VarArrayCreate([0,0], varVariant);
            ivHB:=0;
          end;
          aTabResult[ivHB]:=VarArrayOf([sctExec, tmpSt]);
        Finally
          tmpSt:='';
        End;
        // Выход
        Exit;
      end;
    Else
      Raise Exception.Create('Неизвестное значение ParseMode('+IntToStr(Integer(FParseMode))+').');
    End;
    // Обрабатываю случай для pmdSQLString.
    If {(}UpperCase(_aQueryParser.Token)='DELETE'{) And (aMustBeOnlySelect=false)} Then begin
      // DELETE
      _aQueryParser.NextToken;
      While True do begin
        If UpperCase(_aQueryParser.Token)='FROM' Then Begin
          Break
        End Else
          If UpperCase(_aQueryParser.Token)='WHERE' Then begin
            // для случая если delete записан без from
            _aQueryParser.FirstToken;
            While True do begin
              If UpperCase(_aQueryParser.Token)<>'DELETE' Then _aQueryParser.NextToken else begin
                Break;
              end;
              If _aQueryParser.EOF Then begin
                Raise Exception.Create('Строка неожиданно закончилась.');
              end;
            end;
            //Result:=AfterFromToTableName(aQueryParser, sctDelete, aTabResult);
            //Exit;
            break;
          end;{ else begin
            aQueryParser.NextToken;
          end;}
        // ..
        If SkipSymbol(_aQueryParser, [{ttString, ttSpecialChar,} ttStatementDelimiter], [ttSymbol])=False Then begin
          If _aQueryParser.EOF Then Raise Exception.Create('Не удается найти операнд FROM или WHERE.') else
            Raise Exception.Create('Не ожидается символ '''+_aQueryParser.Token+''' полсе DELETE.');
        end;
      end;
      // Теперь остановился точно на FROM: "Delete /* Comment */ >FROM ..."
      _aQueryParser.NextToken; // Пропускаю FROM
      AfterFromToTableName(_aQueryParser, sctDelete, aTabResult);
      // ..
      AnalyseToken(_aQueryParser, sctDelete, aTabResult);
    end else
      If UpperCase(_aQueryParser.Token)='INSERT'{) And (aMustBeOnlySelect=false) }Then begin
        // INSERT
        _aQueryParser.NextToken;
        // Отматывая к следующему операнду
        If (SkipSymbol(_aQueryParser, [ttString, ttSpecialChar, ttStatementDelimiter], [ttSymbol], True)=False) Or (_aQueryParser.Token=',') Then begin
          If _aQueryParser.EOF Then Raise Exception.Create('Строка неожиданно закончилась.') else
            Raise Exception.Create('Не ожидается символ '''+_aQueryParser.Token+''' полсе INSERT.');
        end;
        // Проверяю на необязательный операнд INTO
        If UpperCase(_aQueryParser.Token)='INTO' Then _aQueryParser.NextToken;
//INSERT INTO #TestTempTab SELECT * FROM TestPermTab
//INSERT INTO TestTab VALUES (1, N'abc')
        // Теперь остановился где перечисляются имена таблиц
        AfterFromToTableName(_aQueryParser, sctInsert, aTabResult);
        // ..
        AnalyseToken(_aQueryParser, sctInsert, aTabResult);
        // INSERT
      end else
        If UpperCase(_aQueryParser.Token)='UPDATE'{) And (aMustBeOnlySelect=false)} Then begin
         // UPDATE
         _aQueryParser.NextToken;
         // Забираю имя таблицы для Update
         AfterFromToTableName(_aQueryParser, sctUpdate, aTabResult);
         // Ищу SET
         If UpperCase(_aQueryParser.Token)<>'SET' Then Begin
           Raise Exception.Create('Ожидается операнд SET.');
         End;
         _aQueryParser.NextToken;
         // Ищу FROM или WHERE
         While True do begin
           If UpperCase(_aQueryParser.Token)='FROM' Then Begin
             // Забираю имя таблицы для SELECT
             _aQueryParser.NextToken;
             AfterFromToTableName(_aQueryParser, sctSelect, aTabResult);
             {If (SkipSymbol(_aQueryParser, [ttString, ttSpecialChar, ttStatementDelimiter], [ttSymbol], True)=False) Or (_aQueryParser.Token=',') Then begin
               If _aQueryParser.EOF=True Then Break // если нет WHERE
                 Else Raise Exception.Create('Не ожидается символ '''+_aQueryParser.Token+''' полсе UPDATE.');
             End;}
             If _aQueryParser.EOF=True Then Break;
             // Ищу WHERE после FROM
             If UpperCase(_aQueryParser.Token)<>'WHERE' Then Begin
               Raise Exception.Create('Ожидается операнд WHERE, найден '+_aQueryParser.Token+'.');
             End;
             // тут теперь может быть только WHERE
             AnalyseToken(_aQueryParser, sctUpdate, aTabResult);
             break;
           End else
             If UpperCase(_aQueryParser.Token)='WHERE' Then Begin
               //_aQueryParser.NextToken;
               AnalyseToken(_aQueryParser, sctUpdate, aTabResult);
               break;
             End Else
               If _aQueryParser.Token='(' Then Begin
                 AnalyseSELECTInBrackets(_aQueryParser, aTabResult, True);
               End;
           If _aQueryParser.EOF=True Then Break;//Raise Exception.Create('Операнд FROM или WHERE найдены.');
           _aQueryParser.NextToken;
         End;
         // UPDATE
        end else
          If UpperCase(_aQueryParser.Token)='SELECT' Then begin
            // SELECT
            _aQueryParser.NextToken;
            // Ищу FROM
            While True do begin
              If UpperCase(_aQueryParser.Token)='FROM' Then Begin
                Break
              End Else
                If UpperCase(_aQueryParser.Token)='INTO' Then begin
                  // для случая если попытка SELECT INTO
                  Raise Exception.Create('Недопустимо использование команды: SELECT INTO.');
                end Else
                  If UpperCase(_aQueryParser.Token)='WHERE' Then begin
                    // для случая если попытка SELECT INTO
                    Raise Exception.Create('Найден операнд WHERE, ожидается операнд FROM.');
                  end;
              // ..
              If SkipSymbol(_aQueryParser, [{ttString, ttSpecialChar,} ttStatementDelimiter], [ttSymbol])=False Then begin
                If _aQueryParser.EOF Then Raise Exception.Create('Не удается найти операнд FROM.') else
                  Raise Exception.Create('Не ожидается символ '''+_aQueryParser.Token+''' полсе SELECT.');
              end;
            end;
            // Теперь остановился точно на FROM: "Select /* Comment */ >FROM ..."
            _aQueryParser.NextToken; // Пропускаю FROM
            AfterFromToTableName(_aQueryParser, sctSelect, aTabResult);
            // ..
            AnalyseToken(_aQueryParser, sctSelect, aTabResult);
          End else
            If UpperCase(_aQueryParser.Token)='BEGIN' Then begin
              // BEGIN TRANSACTION
               If (SkipSymbol(_aQueryParser, [ttString, ttSpecialChar, ttStatementDelimiter], [ttSymbol], True)=False) Or (_aQueryParser.Token=',') Then begin
                 If _aQueryParser.EOF Then Raise Exception.Create('Строка неожиданно закончилась.') else
                   Raise Exception.Create('Не ожидается символ '''+_aQueryParser.Token+''' полсе BEGIN.');
               end;
              If UpperCase(_aQueryParser.Token)<>'TRANSACTION' Then Begin
                Raise Exception.Create('После BEGIN ожидается операнд TRANSACTION.');
              End;
              If SkipSymbol(_aQueryParser, [], [ttSymbol, ttString, ttSpecialChar, ttStatementDelimiter], True) then begin
                Raise Exception.Create('Не ожидается символ '''+_aQueryParser.Token+''' полсе ''BEGIN TRANSACTION''.');
              end;
              If Not _aQueryParser.EOF Then Raise Exception.Create('Не ожидается символ '''+_aQueryParser.Token+''' полсе ''BEGIN TRANSACTION''.');
              // Теперь все проверено и можно добавить в список
              If (VarType(aTabResult) and varArray)=varArray Then begin
                ivHB:=VarArrayHighBound(aTabResult, 1)+1;
                VarArrayRedim(aTabResult, ivHB);
              end else begin
                aTabResult:=VarArrayCreate([0,0], varVariant);
                ivHB:=0;
              end;
              aTabResult[ivHB]:=VarArrayOf([sctBeginTran, '']);
            End else
              If UpperCase(_aQueryParser.Token)='COMMIT' Then begin
                // COMMIT TRANSACTION
                 If (SkipSymbol(_aQueryParser, [ttString, ttSpecialChar, ttStatementDelimiter], [ttSymbol], True)=False) Or (_aQueryParser.Token=',') Then begin
                   If _aQueryParser.EOF Then Raise Exception.Create('Строка неожиданно закончилась.') else
                     Raise Exception.Create('Не ожидается символ '''+_aQueryParser.Token+''' полсе COMMIT.');
                 end;
                If UpperCase(_aQueryParser.Token)<>'TRANSACTION' Then Begin
                  Raise Exception.Create('После COMMIT ожидается операнд TRANSACTION.');
                End;
                If SkipSymbol(_aQueryParser, [], [ttSymbol, ttString, ttSpecialChar, ttStatementDelimiter], True) then begin
                  Raise Exception.Create('Не ожидается символ '''+_aQueryParser.Token+''' полсе ''COMMIT TRANSACTION''.');
                end;
                If Not _aQueryParser.EOF Then Raise Exception.Create('Не ожидается символ '''+_aQueryParser.Token+''' полсе ''COMMIT TRANSACTION''.');
                // Теперь все проверено и можно добавить в список
                If (VarType(aTabResult) and varArray)=varArray Then begin
                  ivHB:=VarArrayHighBound(aTabResult, 1)+1;
                  VarArrayRedim(aTabResult, ivHB);
                end else begin
                  aTabResult:=VarArrayCreate([0,0], varVariant);
                  ivHB:=0;
                end;
                aTabResult[ivHB]:=VarArrayOf([sctCommitTran, '']);
              End else
                If UpperCase(_aQueryParser.Token)='ROLLBACK' Then begin
                  // ROLLBACK TRANSACTION
                   If (SkipSymbol(_aQueryParser, [ttString, ttSpecialChar, ttStatementDelimiter], [ttSymbol], True)=False) Or (_aQueryParser.Token=',') Then begin
                     If _aQueryParser.EOF Then Raise Exception.Create('Строка неожиданно закончилась.') else
                       Raise Exception.Create('Не ожидается символ '''+_aQueryParser.Token+''' полсе ROLLBACK.');
                   end;
                  If UpperCase(_aQueryParser.Token)<>'TRANSACTION' Then Begin
                    Raise Exception.Create('После ROLLBACK ожидается операнд TRANSACTION.');
                  End;
                  If SkipSymbol(_aQueryParser, [], [ttSymbol, ttString, ttSpecialChar, ttStatementDelimiter], True) then begin
                    Raise Exception.Create('Не ожидается символ '''+_aQueryParser.Token+''' полсе ''ROLLBACK TRANSACTION''.');
                  end;
                  If Not _aQueryParser.EOF Then Raise Exception.Create('Не ожидается символ '''+_aQueryParser.Token+''' полсе ''ROLLBACK TRANSACTION''.');
                  // Теперь все проверено и можно добавить в список
                  If (VarType(aTabResult) and varArray)=varArray Then begin
                    ivHB:=VarArrayHighBound(aTabResult, 1)+1;
                    VarArrayRedim(aTabResult, ivHB);
                  end else begin
                    aTabResult:=VarArrayCreate([0,0], varVariant);
                    ivHB:=0;
                  end;
                  aTabResult[ivHB]:=VarArrayOf([sctRollbackTran, '']);
                End else
                  If (UpperCase(_aQueryParser.Token)='EXEC')Or(UpperCase(_aQueryParser.Token)='EXECUTE') Then begin
                    // EXEC
                    _aQueryParser.NextToken;
                    // Отматывая к следующему операнду
                    If (SkipSymbol(_aQueryParser, [ttString, ttSpecialChar, ttStatementDelimiter], [ttSymbol], True)=False) Or (_aQueryParser.Token=',') Then begin
                      If _aQueryParser.EOF Then Raise Exception.Create('Строка неожиданно закончилась.') else
                        Raise Exception.Create('Не ожидается символ '''+_aQueryParser.Token+''' полсе EXEC.');
                    end;
                    // Проверяю 
                    tmpSt:=_aQueryParser.Token;
                    try
                      If SkipSymbol(_aQueryParser, [], [ttSymbol, ttString, ttSpecialChar, ttStatementDelimiter], True) then begin
                        Raise Exception.Create('Не ожидается символ '''+_aQueryParser.Token+''' полсе ''EXEC '+tmpSt+'''.');
                      end;
                      If Not _aQueryParser.EOF Then Raise Exception.Create('Не ожидается символ '''+_aQueryParser.Token+''' полсе ''EXEC '+tmpSt+'''.');
                      // Теперь все проверено и можно добавить в список
                      If (VarType(aTabResult) and varArray)=varArray Then begin
                        ivHB:=VarArrayHighBound(aTabResult, 1)+1;
                        VarArrayRedim(aTabResult, ivHB);
                      end else begin
                        aTabResult:=VarArrayCreate([0,0], varVariant);
                        ivHB:=0;
                      end;
                      aTabResult[ivHB]:=VarArrayOf([sctExec, tmpSt]);
                    Finally
                      tmpSt:='';
                    End;
                    // EXEC
                  End else
                    If UpperCase(_aQueryParser.Token)='CREATE' Then begin
                      // CREATE
                      // Можно добавить в список
                      If (VarType(aTabResult) and varArray)=varArray Then begin
                        ivHB:=VarArrayHighBound(aTabResult, 1)+1;
                        VarArrayRedim(aTabResult, ivHB);
                      end else begin
                        aTabResult:=VarArrayCreate([0,0], varVariant);
                        ivHB:=0;
                      end;
                      aTabResult[ivHB]:=VarArrayOf([sctCreate, '']);
                      // CREATE
                    End else
                      If UpperCase(_aQueryParser.Token)='ALTER' Then begin
                        // ALTER
                        // Можно добавить в список
                        If (VarType(aTabResult) and varArray)=varArray Then begin
                          ivHB:=VarArrayHighBound(aTabResult, 1)+1;
                          VarArrayRedim(aTabResult, ivHB);
                        end else begin
                          aTabResult:=VarArrayCreate([0,0], varVariant);
                          ivHB:=0;
                        end;
                        aTabResult[ivHB]:=VarArrayOf([sctAlter, '']);
                        // ALTER
                      End else
                        If UpperCase(_aQueryParser.Token)='DROP' Then begin
                          // DROP
                          // Можно добавить в список
                          If (VarType(aTabResult) and varArray)=varArray Then begin
                            ivHB:=VarArrayHighBound(aTabResult, 1)+1;
                            VarArrayRedim(aTabResult, ivHB);
                          end else begin
                            aTabResult:=VarArrayCreate([0,0], varVariant);
                            ivHB:=0;
                          end;
                          aTabResult[ivHB]:=VarArrayOf([sctDrop, '']);
                          // DROP
                        End else
                          If UpperCase(_aQueryParser.Token)='TRUNCATE' Then begin
                            // TRUNCATE
                            // Можно добавить в список
                            If (VarType(aTabResult) and varArray)=varArray Then begin
                              ivHB:=VarArrayHighBound(aTabResult, 1)+1;
                              VarArrayRedim(aTabResult, ivHB);
                            end else begin
                              aTabResult:=VarArrayCreate([0,0], varVariant);
                              ivHB:=0;
                            end;
                            aTabResult[ivHB]:=VarArrayOf([sctTruncate, '']);
                            // TRUNCATE
                          End Else begin
                            Raise Exception.Create('Команда '''+_aQueryParser.Token+''' не классифицирована.');
                          End;
End;

Procedure TSQLCommandParser.OneSQLCommandToTableName(aSQL:AnsiString; Var aTabResult:Variant);
  Var _aQueryParser: TQueryParserComp;
begin
  _aQueryParser:=TQueryParserComp.Create{(Nil)};
  Try
    _aQueryParser.TextToParse:=aSQL;
    _aQueryParser.FirstToken;
    AnalyseCommand(_aQueryParser, aTabResult);
  Finally
    _aQueryParser.Free;
  End;
end;

Procedure TSQLCommandParser.SQLCommandToTableName(aSQL:AnsiString; Var aTabResult:Variant);
  Var QueryParser: TQueryParserComp;
      stSQL:AnsiString;
      iCommandNum:Integer;
Begin
  QueryParser:=TQueryParserComp.Create{(Nil)};
  Try
    stSQL:='';
    iCommandNum:=1;
    QueryParser.TextToParse:=aSQL;
    QueryParser.FirstToken;
    //If QueryParser.EOF=True Then RaiseException.Create('Строка неожиданно закончилась.');
    While True Do begin
      Case QueryParser.TokenType of
        ttSymbol, ttString, ttDelimiter, ttSpecialChar, ttStatementDelimiter: Begin
          If (UpperCase(QueryParser.Token)='GO') Or (QueryParser.Token=';') Then Begin
            Try
              OneSQLCommandToTableName(stSQL, aTabResult);
            Except
              On E:Exception Do begin
                // Ошибка при разборе SQL command
                If iCommandNum>1 Then Raise Exception.Create('Команда №'+IntToStr(iCommandNum)+': '+E.Message) Else
                  Raise;
              End;
            End;
            Inc(iCommandNum);
            stSQL:='';
          End else begin
            stSQL:=stSQL+QueryParser.Token;
          End;
        End;
        ttComment, ttCommentedSymbol, ttCommentDelimiter: {Игнорирую комментарии};
      Else
        Raise Exception.Create('Требуется отладка EAMServer(Неизвестное значение TokenType='+IntToStr(Integer(QueryParser.TokenType))+').');
      End;
      If QueryParser.EOF=True Then Begin
        If stSQL<>'' Then Begin
          Try
            OneSQLCommandToTableName(stSQL, aTabResult);
          Except
            On E:Exception Do begin
              // Ошибка при разборе SQL command
              If iCommandNum>1 Then Raise Exception.Create('Команда №'+IntToStr(iCommandNum)+': '+E.Message) Else
                Raise;
            End;
          End;
        end;
        Break;
      End;
      QueryParser.NextToken;
    end;
  Finally
    QueryParser.Free;
    stSQL:='';
  End;
End;

end.

