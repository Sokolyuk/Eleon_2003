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
    // ��� ������ ��� �������
    If _aQueryParser.Token='(' Then begin
      If _aQueryParser.EOF=True Then begin
        Raise Exception.Create('������������ ���������: ��������� '')''.');
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
    If _aQueryParser.Token<>'(' Then Raise Exception.Create('������������ ������ '''+_aQueryParser.Token+'''.');
  end;
  //������ ��������� ��� ����������� � ����������� �� '('
  If _aQueryParser.EOF=True Then begin
    Raise Exception.Create('������������ ���������: ��������� '')''.');
  end;
  //����� ������ ����������
  iI:=0;
  iLevel:=0;
  aSQL:='';
  While True do begin
    If _aQueryParser.Token='(' Then begin
      Inc(iI);
      If iLevel=0 Then Begin
        //���� ��� �� ���� ')'
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
          //��������: �������� ��������� ������ ������ ���������:
          //  1) ������������ ������ ������. ������ ��� Insert >(a,b,c,d)Values>(1,2,3,4)
          //  2) �������� ������ � ������� �������� ���-Select. ������ ��� Insert (a,b,c,d)Values(1,>(Select Id from ss where Num=5),3,4)
          If (blOnlyOneBracket)And({iI}0=iLevel)And(0=iI) Then Break; // ������������ ������ ���� ������, � �� ��� �� �����
        end else begin
          //aSQL:=aSQL+_aQueryParser.Token; - ����� ������ ')' �� ������ � aSQL
          If (iI=iLevel)And(iLevel>0) Then begin
            //����� ����� ������
            iLevel:=0;
            Dec(iI);
            If aSQL<>'' Then Begin
              OneSQLCommandToTableName(aSQL, aTabResult); //��������� ���� � SELECT
              aSQL:='';
            End;
          end else begin
            Raise Exception.Create('������������ ���������: �� ��������� '')''.');
          end;
          If (blOnlyOneBracket)And(iI=iLevel) Then Break; //������������ ������ ���� ������, � �� ��� �� �����
        end;
      end;
    end;
    //��� ����� ����������
    If _aQueryParser.EOF=True Then begin
      If iI>0 Then
        //���� �� ��������� ��� ������
        Raise Exception.Create('������������ ���������: ��������� '')''.');
      Exit;
    end;
    If iLevel>0 Then aSQL:=aSQL+_aQueryParser.Token; //���� ������ ������
    _aQueryParser.NextToken;
  end; //while
  //..
end;

Procedure TSQLCommandParser.AnalyseToken(_aQueryParser:TQueryParserComp; aSQLCommandType:TSQLCommandType; Var aTabResult:Variant);
// ��������� ����������� ����� ����� ������������ ���� ������
// �.�. ��� Select � Delete ��� Where (Select * from t1, t2 >Where .....)
// �.�. ��� Insert ��� {Insert into t1, t2 >Values .....)
  Var blVALUE :Boolean;
      {iCountBricet, }iBricketBeforeVALUES, iBricketAfterVALUES:Integer;
Begin
  // ���������� �����
  Case aSQLCommandType of
    sctInsert:begin
      // sctInsert
      blVALUE:=False;
      iBricketBeforeVALUES:=0;
      iBricketAfterVALUES:=0;
//      iCountBricet:=0;
      While true do begin
        //  ���� ��������� ��������
        If (_aQueryParser.TokenType<>ttSymbol) And (_aQueryParser.TokenType<>ttSpecialChar) Then Begin
          SkipSymbol(_aQueryParser, [ttString, ttStatementDelimiter, ttSpecialChar, ttSymbol], [], True);
        end;
        If _aQueryParser.EOF=True Then
          If iBricketAfterVALUES=0 Then Raise Exception.Create('������ ���������� �����������.')
            else break;
        If _aQueryParser.Token='(' Then begin
          If Not blVALUE Then Inc(iBricketBeforeVALUES) // ���� ��� ������ �� VALUES
                     else Inc(iBricketAfterVALUES);  // ���� ��� ������ ����� VALUES
          // ..
          AnalyseSELECTInBrackets(_aQueryParser, aTabResult, True);
          _aQueryParser.NextToken;
          If iBricketBeforeVALUES>1 Then Break; // �.�. �� VALUES �� ����� ���� ������ 2 ��� '('
          If iBricketAfterVALUES>1 Then Break; // �.�. ����� VALUES �� ����� ���� ������ 2 ��� '('
          Continue;
        end else
          If UpperCase(_aQueryParser.Token)='VALUES' Then begin
            If blVALUE=True Then Raise Exception.Create('������������ ������� '''+_aQueryParser.Token+'''.');
            _aQueryParser.NextToken;
            blVALUE:=True;
            Continue;
          end else
            If UpperCase(_aQueryParser.Token)='SELECT' Then begin
              AnalyseCommand(_aQueryParser, aTabResult);
            end else
              Raise Exception.Create('������������ ������ '''+_aQueryParser.Token+'''.');
        Break;
      end;
    end;
    sctSelect, sctDelete, sctUpdate:begin
     // sctSelect, sctDelete
       // �������� � �����
      If (_aQueryParser.TokenType<>ttSymbol) Or (_aQueryParser.EOF=True) Then begin
        If (SkipSymbol(_aQueryParser, [ttString, ttSpecialChar, ttStatementDelimiter], [ttSymbol], True)=False) Or (_aQueryParser.Token=',') Then begin
          // ... FROM Tab1,,
          If _aQueryParser.EOF=false Then Raise Exception.Create('������������ ������ '''+_aQueryParser.Token+'''.');
          Exit;
        end;
      End;
      // ..
      If _aQueryParser.TokenType=ttSymbol Then begin
        If (UpperCase(_aQueryParser.Token)='GROUP') Or (UpperCase(_aQueryParser.Token)='ORDER') Then Begin
          // ..
        end Else
          If (UpperCase(_aQueryParser.Token)='WHERE') Or (UpperCase(_aQueryParser.Token)='HAVING') Then Begin
            _aQueryParser.NextToken; // ��������� WHERE
            AfterWhereToTableName(_aQueryParser, aTabResult);
          end Else
            If UpperCase(_aQueryParser.Token)='UNION' Then Begin
              Raise Exception.Create('������ �������� UNION �� ����������.');
            end Else Begin
              Raise Exception.Create('����������� �������: '+_aQueryParser.Token+'.');
            End;
      end else begin
        Raise Exception.Create('����������� ������.');
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
    Raise Exception.Create('������ ���������� �����������.');
  end;
    While True do begin // ����� ������� True and <>','
      If tmpWithFound Then begin
        tmpWithFound:=False;
      end else begin
        If (_aQueryParser.TokenType<>ttSymbol) {Or (_aQueryParser.EOF=True)} Then begin
          If (SkipSymbol(_aQueryParser, [ttString, ttSpecialChar, ttStatementDelimiter], [ttSymbol], True)=False)Or(_aQueryParser.Token=',')Then begin
            // ... FROM Tab1,,
            If _aQueryParser.EOF Then Raise Exception.Create('������ ���������� �����������.') else Raise Exception.Create('������������ ���������: ''FROM '+_aQueryParser.Token+'''.');
          end;
        End;
      end;
      // ������ ������ ttSymbol, �.�. ������ ����� �������
      blCurrTableName:=False;
      aCurrTableName:=_aQueryParser.Token;
      blEOF:=_aQueryParser.EOF;
      // ..
      Case aSQLCommandType Of
        sctInsert:begin
          If SkipSymbol(_aQueryParser, [ttString, ttStatementDelimiter], [ttSymbol, ttSpecialChar], True)=False Then begin
            // ���� �� ���� ������ ��� �� ������ ��� �� �����, �� ������
            If _aQueryParser.EOF<>True Then begin
              Raise Exception.Create('�� ��������� ������ '''+_aQueryParser.Token+'''.');
            End;
          end;
          If _aQueryParser.TokenType=ttSpecialChar Then Begin
            // Insert into sss (...) Values (...)
            // ����� �� ttSpecialChar
            If _aQueryParser.Token='(' Then begin
              blCurrTableName:=True;
              blBreak:=True;
            End else begin
              Raise Exception.Create('�� ��������� ������ '''+_aQueryParser.Token+'''.');
            end;
          end;
        End;
        sctSelect, sctDelete, sctUpdate:begin
          If SkipSymbol(_aQueryParser, [ttString, ttStatementDelimiter, ttSpecialChar], [ttSymbol], True)=False Then begin
            // ���� �� ���� ������ ��� �� ������ ��� �� �����, �� ������
            If _aQueryParser.EOF<>True Then begin
              Raise Exception.Create('�� ��������� ������ '''+_aQueryParser.Token+''' ����� FROM.');
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
                // ��� ������: insert into Tab1 (Select ...
              end else begin
                Raise Exception.Create('����������� ������.');
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
            if _aQueryParser.Token<>'(' then raise exception.create('�� ��������� ������ '''+_aQueryParser.Token+''' ����� WITH.');
            while true do begin
              If _aQueryParser.Token=')' Then begin
                If (SkipSymbol(_aQueryParser, [ttString, ttSpecialChar, ttStatementDelimiter], [ttSymbol], True)=False) Then begin
                  If _aQueryParser.EOF Then raise exception.create('�� ��������� ������ '''+_aQueryParser.Token+''' ����� WITH.');
                end;
                If _aQueryParser.Token=',' then begin
                  //tmpWithFound:=True;
                  blBreak:=_aQueryParser.EOF;
                end else begin
                  blBreak:=true;
                end;
                break;
              end;
              If _aQueryParser.EOF Then Raise Exception.Create('������ ���������� �����������.');
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
    // �������� �� �������������� ������� ��� �� �������
    If _aQueryParser.TokenType<>ttSymbol Then begin
      If (SkipSymbol(_aQueryParser, [ttString, ttSpecialChar, ttStatementDelimiter], [ttSymbol], True)=False) Or (_aQueryParser.Token=',') Then begin
        If _aQueryParser.EOF Then Exit; // ������ ������
        Raise Exception.Create('�� ��������� ������ '''+_aQueryParser.Token+''' �� SQL �������.');
      end;
    end;
    // �������� ����� ������� ������
    Case FParseMode of
      pmdSQLString:begin
        // ��������� SQL ���������.
        // >> ����� �����.
      end;
      pmdExecProc:begin
        // ��������� ��� �������� ��������� ��� ������� Exec.
        // ������: >spu_SaleOper
        tmpSt:=UpperCase(_aQueryParser.Token);
        try
          If SkipSymbol(_aQueryParser, [], [ttSymbol, ttString, ttSpecialChar, ttStatementDelimiter], True) then begin
            Raise Exception.Create('�� ��������� ������ '''+_aQueryParser.Token+'''.');
          end;
          If Not _aQueryParser.EOF Then Raise Exception.Create('�� ��������� ������ '''+_aQueryParser.Token+'''.');
          // ������ ��� ��������� � ����� �������� � ������
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
        // �����
        Exit;
      end;
    Else
      Raise Exception.Create('����������� �������� ParseMode('+IntToStr(Integer(FParseMode))+').');
    End;
    // ����������� ������ ��� pmdSQLString.
    If {(}UpperCase(_aQueryParser.Token)='DELETE'{) And (aMustBeOnlySelect=false)} Then begin
      // DELETE
      _aQueryParser.NextToken;
      While True do begin
        If UpperCase(_aQueryParser.Token)='FROM' Then Begin
          Break
        End Else
          If UpperCase(_aQueryParser.Token)='WHERE' Then begin
            // ��� ������ ���� delete ������� ��� from
            _aQueryParser.FirstToken;
            While True do begin
              If UpperCase(_aQueryParser.Token)<>'DELETE' Then _aQueryParser.NextToken else begin
                Break;
              end;
              If _aQueryParser.EOF Then begin
                Raise Exception.Create('������ ���������� �����������.');
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
          If _aQueryParser.EOF Then Raise Exception.Create('�� ������� ����� ������� FROM ��� WHERE.') else
            Raise Exception.Create('�� ��������� ������ '''+_aQueryParser.Token+''' ����� DELETE.');
        end;
      end;
      // ������ ����������� ����� �� FROM: "Delete /* Comment */ >FROM ..."
      _aQueryParser.NextToken; // ��������� FROM
      AfterFromToTableName(_aQueryParser, sctDelete, aTabResult);
      // ..
      AnalyseToken(_aQueryParser, sctDelete, aTabResult);
    end else
      If UpperCase(_aQueryParser.Token)='INSERT'{) And (aMustBeOnlySelect=false) }Then begin
        // INSERT
        _aQueryParser.NextToken;
        // ��������� � ���������� ��������
        If (SkipSymbol(_aQueryParser, [ttString, ttSpecialChar, ttStatementDelimiter], [ttSymbol], True)=False) Or (_aQueryParser.Token=',') Then begin
          If _aQueryParser.EOF Then Raise Exception.Create('������ ���������� �����������.') else
            Raise Exception.Create('�� ��������� ������ '''+_aQueryParser.Token+''' ����� INSERT.');
        end;
        // �������� �� �������������� ������� INTO
        If UpperCase(_aQueryParser.Token)='INTO' Then _aQueryParser.NextToken;
//INSERT INTO #TestTempTab SELECT * FROM TestPermTab
//INSERT INTO TestTab VALUES (1, N'abc')
        // ������ ����������� ��� ������������� ����� ������
        AfterFromToTableName(_aQueryParser, sctInsert, aTabResult);
        // ..
        AnalyseToken(_aQueryParser, sctInsert, aTabResult);
        // INSERT
      end else
        If UpperCase(_aQueryParser.Token)='UPDATE'{) And (aMustBeOnlySelect=false)} Then begin
         // UPDATE
         _aQueryParser.NextToken;
         // ������� ��� ������� ��� Update
         AfterFromToTableName(_aQueryParser, sctUpdate, aTabResult);
         // ��� SET
         If UpperCase(_aQueryParser.Token)<>'SET' Then Begin
           Raise Exception.Create('��������� ������� SET.');
         End;
         _aQueryParser.NextToken;
         // ��� FROM ��� WHERE
         While True do begin
           If UpperCase(_aQueryParser.Token)='FROM' Then Begin
             // ������� ��� ������� ��� SELECT
             _aQueryParser.NextToken;
             AfterFromToTableName(_aQueryParser, sctSelect, aTabResult);
             {If (SkipSymbol(_aQueryParser, [ttString, ttSpecialChar, ttStatementDelimiter], [ttSymbol], True)=False) Or (_aQueryParser.Token=',') Then begin
               If _aQueryParser.EOF=True Then Break // ���� ��� WHERE
                 Else Raise Exception.Create('�� ��������� ������ '''+_aQueryParser.Token+''' ����� UPDATE.');
             End;}
             If _aQueryParser.EOF=True Then Break;
             // ��� WHERE ����� FROM
             If UpperCase(_aQueryParser.Token)<>'WHERE' Then Begin
               Raise Exception.Create('��������� ������� WHERE, ������ '+_aQueryParser.Token+'.');
             End;
             // ��� ������ ����� ���� ������ WHERE
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
           If _aQueryParser.EOF=True Then Break;//Raise Exception.Create('������� FROM ��� WHERE �������.');
           _aQueryParser.NextToken;
         End;
         // UPDATE
        end else
          If UpperCase(_aQueryParser.Token)='SELECT' Then begin
            // SELECT
            _aQueryParser.NextToken;
            // ��� FROM
            While True do begin
              If UpperCase(_aQueryParser.Token)='FROM' Then Begin
                Break
              End Else
                If UpperCase(_aQueryParser.Token)='INTO' Then begin
                  // ��� ������ ���� ������� SELECT INTO
                  Raise Exception.Create('����������� ������������� �������: SELECT INTO.');
                end Else
                  If UpperCase(_aQueryParser.Token)='WHERE' Then begin
                    // ��� ������ ���� ������� SELECT INTO
                    Raise Exception.Create('������ ������� WHERE, ��������� ������� FROM.');
                  end;
              // ..
              If SkipSymbol(_aQueryParser, [{ttString, ttSpecialChar,} ttStatementDelimiter], [ttSymbol])=False Then begin
                If _aQueryParser.EOF Then Raise Exception.Create('�� ������� ����� ������� FROM.') else
                  Raise Exception.Create('�� ��������� ������ '''+_aQueryParser.Token+''' ����� SELECT.');
              end;
            end;
            // ������ ����������� ����� �� FROM: "Select /* Comment */ >FROM ..."
            _aQueryParser.NextToken; // ��������� FROM
            AfterFromToTableName(_aQueryParser, sctSelect, aTabResult);
            // ..
            AnalyseToken(_aQueryParser, sctSelect, aTabResult);
          End else
            If UpperCase(_aQueryParser.Token)='BEGIN' Then begin
              // BEGIN TRANSACTION
               If (SkipSymbol(_aQueryParser, [ttString, ttSpecialChar, ttStatementDelimiter], [ttSymbol], True)=False) Or (_aQueryParser.Token=',') Then begin
                 If _aQueryParser.EOF Then Raise Exception.Create('������ ���������� �����������.') else
                   Raise Exception.Create('�� ��������� ������ '''+_aQueryParser.Token+''' ����� BEGIN.');
               end;
              If UpperCase(_aQueryParser.Token)<>'TRANSACTION' Then Begin
                Raise Exception.Create('����� BEGIN ��������� ������� TRANSACTION.');
              End;
              If SkipSymbol(_aQueryParser, [], [ttSymbol, ttString, ttSpecialChar, ttStatementDelimiter], True) then begin
                Raise Exception.Create('�� ��������� ������ '''+_aQueryParser.Token+''' ����� ''BEGIN TRANSACTION''.');
              end;
              If Not _aQueryParser.EOF Then Raise Exception.Create('�� ��������� ������ '''+_aQueryParser.Token+''' ����� ''BEGIN TRANSACTION''.');
              // ������ ��� ��������� � ����� �������� � ������
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
                   If _aQueryParser.EOF Then Raise Exception.Create('������ ���������� �����������.') else
                     Raise Exception.Create('�� ��������� ������ '''+_aQueryParser.Token+''' ����� COMMIT.');
                 end;
                If UpperCase(_aQueryParser.Token)<>'TRANSACTION' Then Begin
                  Raise Exception.Create('����� COMMIT ��������� ������� TRANSACTION.');
                End;
                If SkipSymbol(_aQueryParser, [], [ttSymbol, ttString, ttSpecialChar, ttStatementDelimiter], True) then begin
                  Raise Exception.Create('�� ��������� ������ '''+_aQueryParser.Token+''' ����� ''COMMIT TRANSACTION''.');
                end;
                If Not _aQueryParser.EOF Then Raise Exception.Create('�� ��������� ������ '''+_aQueryParser.Token+''' ����� ''COMMIT TRANSACTION''.');
                // ������ ��� ��������� � ����� �������� � ������
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
                     If _aQueryParser.EOF Then Raise Exception.Create('������ ���������� �����������.') else
                       Raise Exception.Create('�� ��������� ������ '''+_aQueryParser.Token+''' ����� ROLLBACK.');
                   end;
                  If UpperCase(_aQueryParser.Token)<>'TRANSACTION' Then Begin
                    Raise Exception.Create('����� ROLLBACK ��������� ������� TRANSACTION.');
                  End;
                  If SkipSymbol(_aQueryParser, [], [ttSymbol, ttString, ttSpecialChar, ttStatementDelimiter], True) then begin
                    Raise Exception.Create('�� ��������� ������ '''+_aQueryParser.Token+''' ����� ''ROLLBACK TRANSACTION''.');
                  end;
                  If Not _aQueryParser.EOF Then Raise Exception.Create('�� ��������� ������ '''+_aQueryParser.Token+''' ����� ''ROLLBACK TRANSACTION''.');
                  // ������ ��� ��������� � ����� �������� � ������
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
                    // ��������� � ���������� ��������
                    If (SkipSymbol(_aQueryParser, [ttString, ttSpecialChar, ttStatementDelimiter], [ttSymbol], True)=False) Or (_aQueryParser.Token=',') Then begin
                      If _aQueryParser.EOF Then Raise Exception.Create('������ ���������� �����������.') else
                        Raise Exception.Create('�� ��������� ������ '''+_aQueryParser.Token+''' ����� EXEC.');
                    end;
                    // �������� 
                    tmpSt:=_aQueryParser.Token;
                    try
                      If SkipSymbol(_aQueryParser, [], [ttSymbol, ttString, ttSpecialChar, ttStatementDelimiter], True) then begin
                        Raise Exception.Create('�� ��������� ������ '''+_aQueryParser.Token+''' ����� ''EXEC '+tmpSt+'''.');
                      end;
                      If Not _aQueryParser.EOF Then Raise Exception.Create('�� ��������� ������ '''+_aQueryParser.Token+''' ����� ''EXEC '+tmpSt+'''.');
                      // ������ ��� ��������� � ����� �������� � ������
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
                      // ����� �������� � ������
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
                        // ����� �������� � ������
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
                          // ����� �������� � ������
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
                            // ����� �������� � ������
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
                            Raise Exception.Create('������� '''+_aQueryParser.Token+''' �� ����������������.');
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
    //If QueryParser.EOF=True Then RaiseException.Create('������ ���������� �����������.');
    While True Do begin
      Case QueryParser.TokenType of
        ttSymbol, ttString, ttDelimiter, ttSpecialChar, ttStatementDelimiter: Begin
          If (UpperCase(QueryParser.Token)='GO') Or (QueryParser.Token=';') Then Begin
            Try
              OneSQLCommandToTableName(stSQL, aTabResult);
            Except
              On E:Exception Do begin
                // ������ ��� ������� SQL command
                If iCommandNum>1 Then Raise Exception.Create('������� �'+IntToStr(iCommandNum)+': '+E.Message) Else
                  Raise;
              End;
            End;
            Inc(iCommandNum);
            stSQL:='';
          End else begin
            stSQL:=stSQL+QueryParser.Token;
          End;
        End;
        ttComment, ttCommentedSymbol, ttCommentDelimiter: {��������� �����������};
      Else
        Raise Exception.Create('��������� ������� EAMServer(����������� �������� TokenType='+IntToStr(Integer(QueryParser.TokenType))+').');
      End;
      If QueryParser.EOF=True Then Begin
        If stSQL<>'' Then Begin
          Try
            OneSQLCommandToTableName(stSQL, aTabResult);
          Except
            On E:Exception Do begin
              // ������ ��� ������� SQL command
              If iCommandNum>1 Then Raise Exception.Create('������� �'+IntToStr(iCommandNum)+': '+E.Message) Else
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

