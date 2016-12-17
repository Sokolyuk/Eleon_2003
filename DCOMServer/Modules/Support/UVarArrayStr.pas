unit UVarArrayStr;
  Алгоритм устар, рекомендуется использовать UTypeUtils
interface
  Uses UStrToSQL;

resourcestring
  stUnknownVariantType='Преобразование для VType=%s не поддерживается.';
  stStringUnexpectTerminate='Строка не ожидается закончилась%s.';


Type
  TVarArrayToStr = Class(TObject)
  Private
    FStr:Ansistring;
    FShowNum:Boolean;
    FShortType:Boolean;
    Function  _VarArrayToStr(V:Variant):AnsiString;
  Public
    constructor Create;
    Function  VarArrayToStr(V:Variant):AnsiString;
    Property  Str:Ansistring read FStr;
    Property  ShowNum:Boolean read FShowNum write FShowNum;
    Property  ShortType:Boolean read FShortType write FShortType;
  end;

  TVarArrayString = Class(TObject)
  Private
    FStrToSQL:TStrToSQL;
    Function _VarArrayToString(aVar:Variant; aVarType:Integer):AnsiString;
    Function _StringToVarArray(aString:AnsiString; aiPosEndOfBlock:Integer):Variant;
    { Blob }
    Procedure _GetBlobSize(aVar:Variant; Var aBlobSize:LongWord);
    Function _VarArrayToBlob(aPVar:PVariant; aBlobSize:LongWord; Var aBlobPos:LongWord):Pointer;
    Function _BlobToVarArray(aBlob:Pointer; aBlobSize:LongWord):Variant;
  Public
    Constructor Create;
    Destructor  Destroy; Override;
    Function VarArrayToString(aVar:Variant):AnsiString;
    Function StringToVarArray(aString:AnsiString):Variant;
    { Blob }
    Function VarArrayToBlob(aPVar:PVariant; out aBlobSize:LongWord):Pointer;
    Function BlobToVarArray(aBlob:Pointer; aBlobSize:LongWord):Variant;
  end;

implementation
  Uses SysUtils, UTypes
{$IFDEF VER140}
  { Borland Delphi 6.0 }
       , Variants
{$ENDIF}
       ;
constructor TVarArrayToStr.Create;
begin
  FStr:='';
  FShowNum:=false{true};
  FShortType:=true;
  Inherited Create;
end;

Function  TVarArrayToStr._VarArrayToStr(V:Variant):AnsiString;
  Var st : AnsiString;
      iJ : Integer;
begin
  If VarIsArray(V)Then begin
    // VarArray
    st:='(';
    For iJ:=VarArrayLowBound(V,1) to VarArrayHighBound(V,1) do begin
      If FShowNum then begin
        st:=st+{'#'+}IntToStr(iJ)+':'+_VarArrayToStr(V[iJ]);
      end else begin
        st:=st+_VarArrayToStr(V[iJ]);
      end;
      If iJ>=VarArrayHighBound(V,1) Then
        st:=st+')'
      else
        st:=st+',';
    end;
  End else begin
    // simple Variant
    if FShortType then begin
      Case VarType(V) of
        varEmpty    : st:='Emp';
        varNull     : st:='Nul';
        varSmallint : st:='SIn:'+VarToStr(V);
        varInteger  : st:='Int:'+VarToStr(V);
        varSingle   : st:='Sng:'+VarToStr(V);
        varDouble   : st:='Dbl:'+VarToStr(V);
        varCurrency : st:='Cur:'+VarToStr(V);
        varDate     : st:='Dat:'+DateTimeToStr(VarToDateTime(V));
        varOleStr   : st:='OSt:'''+VarToStr(V)+'''';
        varDispatch : st:='Dis'''+VarToStr(V)+'''';
        varError    : st:='Err'''+VarToStr(V)+'''';
        varBoolean  : begin If V Then st:='Bln:True' else st:='Bln:False'; end;
        varVariant  : st:='Var'''+VarToStr(V)+'''';
        varUnknown  : st:='Unk'''+VarToStr(V)+'''';
        varByte     : st:='Byt:'+VarToStr(V);
        varStrArg   : st:='StA:'+VarToStr(V);
        varString   : st:='Str:'''+VarToStr(V)+'''';
      else
        st:='Oth:'''+VarToStr(V)+'''';
      end;
    end else begin
      Case VarType(V) of
        varEmpty    : st:='varEmpty';
        varNull     : st:='varNull';
        varSmallint : st:='varSmallint:'+VarToStr(V);
        varInteger  : st:='varInteger:'+VarToStr(V);
        varSingle   : st:='varSingle:'+VarToStr(V);
        varDouble   : st:='varDouble:'+VarToStr(V);
        varCurrency : st:='varCurrency:'+VarToStr(V);
        varDate     : st:='varDate:'+DateTimeToStr(VarToDateTime(V));
        varOleStr   : st:='varOleStr:'''+VarToStr(V)+'''';
        varDispatch : st:='varDispatch'''+VarToStr(V)+'''';
        varError    : st:='varError'''+VarToStr(V)+'''';
        varBoolean  : begin st:='varBoolean:'; If V Then st:=st+'True' else st:=st+'False'; end;
        varVariant  : st:='varVariant'''+VarToStr(V)+'''';
        varUnknown  : st:='varUnknown'''+VarToStr(V)+'''';
        varByte     : st:='varByte:'+VarToStr(V);
        varStrArg   : st:='varStrArg:'+VarToStr(V);
        varString   : st:='varString:'''+VarToStr(V)+'''';
      else
        st:='Other:'''+VarToStr(V)+'''';
      end;
    end;
  end;
  Result:=st;
end;

Function  TVarArrayToStr.VarArrayToStr(V:Variant):AnsiString;
begin
  FStr:=_VarArrayToStr(V);
  Result:=FStr;
end;

// Тип/LowBound(Data;Data...)
// 11/0(1;0;0;0;0;1)
// 12/0(5(1,452211);8('1');7(63135825807062);~;#;3/-5(0;0;0))

Constructor TVarArrayString.Create;
begin
  FStrToSQL:=TStrToSQL.Create;
  Inherited Create;
end;

Destructor TVarArrayString.Destroy;
begin
  FStrToSQL.Free;
  Inherited Destroy;
end;

Function TVarArrayString._VarArrayToString(aVar:Variant; aVarType:Integer):AnsiString;
  Var iJ, ivLB, ivHB : Integer;
      iDateTime:T64bit;
begin
  If VarIsArray(aVar) Then begin
    // VarArray
    If VarArrayDimCount(aVar)<>1 Then Raise Exception.Create('VarArrayDimCount(aVar)<>1.');
    ivLB:=VarArrayLowBound(aVar, 1);
    ivHB:=VarArrayHighBound(aVar,1);
    Result:=IntToStr(VarType(aVar)and varTypeMask)+'/'+IntToStr(ivLB)+'(';
    For iJ:=ivLB to ivHB do begin
      Result:=Result+_VarArrayToString(aVar[iJ], {aLevel+1,} VarType(aVar)and varTypeMask);
      If iJ>=ivHB Then
        Result:=Result+')'
      else
        Result:=Result+';';
    end;
  End else begin
    // simple Variant
    If aVarType=varVariant then begin
      // для вызова верхнего вызова разборщика
      Case VarType(aVar) of
        varEmpty:begin
          Result:='~'{'0()'};
        end;
        varNull:begin
          Result:='#'{'1()'};
        end;
        varSmallint, varInteger, varByte, varSingle, varDouble, varCurrency:begin
          Result:=IntToStr(VarType(aVar)and varTypeMask)+'('+VarToStr(aVar)+')';
        end;
        varDate:begin
          iDateTime.OfComp:=TimeStampToMSecs(DateTimeToTimeStamp(VarToDateTime(aVar)));
          Result:=IntToStr(VarType(aVar)and varTypeMask)+'('+IntToStr(iDateTime.ofInt64)+')'; {IntToStr(VarType(aVar)and varTypeMask)+'('+DateTimeToStr(VarToDateTime(aVar))+')'}
        end;
        varOleStr, varString:begin
          Result:=IntToStr(VarType(aVar)and varTypeMask)+'('''+FStrToSQL.StrToSQL(aVar)+''')';
        end;
        varBoolean:begin
          Result:=IntToStr(VarType(aVar)and varTypeMask)+'('+IntToStr(Integer(Boolean(aVar)))+')';
        end;
      else
        Raise Exception.CreateResFmt(@stUnknownVariantType, [IntToStr(VarType(aVar))]); //Create('Преобразование для типа('+IntToStr(VarType(aVar))+') невозможно.');
      end;
    end else begin
      // для суб-вызова разборщика.
      Case VarType(aVar) of
        varSmallint, varInteger, varByte, varSingle, varDouble, varCurrency:begin
          Result:=VarToStr(aVar);
        end;
        varDate:begin
          iDateTime.OfComp:=TimeStampToMSecs(DateTimeToTimeStamp(VarToDateTime(aVar)));
          Result:=IntToStr(iDateTime.ofInt64);{Result:=DateTimeToStr(VarToDateTime(aVar))}
        end;
        varOleStr, varString:begin
          Result:=''''+FStrToSQL.StrToSQL(aVar)+'''';
        end;
        varBoolean:begin
          Result:=IntToStr(Integer(Boolean(aVar)));
        end;
      else
        Raise Exception.CreateResFmt(@stUnknownVariantType, [IntToStr(VarType(aVar))]);
      end;
    end;
  end;
end;

Function TVarArrayString.VarArrayToString(aVar:Variant):AnsiString;
begin
  try
    Result:=_VarArrayToString(aVar, varVariant);
  except
    on e:Exception do
      Raise Exception.Create('VarArrayToString: '+e.Message);
  end;
end;

// Тип/LowBound(Data;Data...)
// 11/0(1;0;0;0;0;1)
// 12/0(5(1,452211);8('1');7(63135825807062);~;#;3/-5(0;0;0)) -array
// ~ -empty
// # -null
Function TVarArrayString._StringToVarArray(aString:AnsiString; aiPosEndOfBlock:Integer):Variant;
const
    iSetNumbers:set of char=['0'..'9','-','+'];
    IsVarIsArray:char='/';
    IsBracketOpen:char = '(';
    IsBracketClose:char = ')';
    IsVarIsEmpty:char = '~';
    IsVarIsNull:char = '#';
    IsDataSeparator:Char=';';
    IsApostrophe:Char='''';
var iI, iLength:Integer;
    iStVarType, iStLB, iStCurrData:AnsiString;
    iCh:Char;
    iBracketsOpen:Integer;
    IsVarArray:Boolean;
    ivVarType, ivLB, ivHB, iElementAddedToResult:Integer;
    iApostropheOpen, iSaveCurrDataOnThisStep:Boolean;
  Procedure _AddElementToResult(_aIsVarArray:Boolean; _aivVarType:Integer; Const _aElement:Variant; Var _aResult:Variant; _aivLB:Integer; Var _aivHB:Integer);
  begin
    If _aIsVarArray Then begin
      If VarIsArray(_aResult) then begin
        VarArrayRedim(_aResult, _aivHB+1);
        Inc(_aivHB);
      end else begin
        _aResult:=VarArrayCreate([_aivLB, _aivLB], _aivVarType);
        _aivHB:=_aivLB;
      end;
      _aResult[_aivHB]:=_aElement;
    end else begin
      try
        VarCast(_aResult, _aElement, _aivVarType);
      except
        on e:exception do
          Raise Exception.Create('VarCast to VType('+IntToStr(_aivVarType)+'): '+e.message);
      end;
    end;
  end;
  Procedure _DataElemendIsFound(_aStCurrData:AnsiString; _aIsVarArray:Boolean; _aivVarType:Integer; Var _aResult:Variant; _aivLB:Integer; Var _aivHB:Integer; _aiLength, _aiPosEndOfBlock, _aiI:Integer);
  Var _tmpV:Variant;
      _iDateTime:T64bit;
  begin
    Case _aivVarType of
      varEmpty:begin
        _AddElementToResult(_aIsVarArray, _aivVarType, Unassigned{'0()'}, _aResult, _aivLB, _aivHB);
      end;
      varNull:begin
        _AddElementToResult(_aIsVarArray, _aivVarType, Null{'1()'}, _aResult, _aivLB, _aivHB);
      end;
      varSmallint, varInteger, varByte:begin
        _AddElementToResult(_aIsVarArray, _aivVarType, StrToInt(_aStCurrData), _aResult, _aivLB, _aivHB);
      end;
      varSingle, varDouble:begin
        _AddElementToResult(_aIsVarArray, _aivVarType, StrToFloat(_aStCurrData), _aResult, _aivLB, _aivHB);
      end;
      varCurrency:begin
        _AddElementToResult(_aIsVarArray, _aivVarType, StrToCurr(_aStCurrData), _aResult, _aivLB, _aivHB);
      end;
      varDate:begin
        _iDateTime.ofInt64:=StrToInt64(_aStCurrData);
        _AddElementToResult(_aIsVarArray, _aivVarType, TDateTime(TimeStampToDateTime(MSecsToTimeStamp(_iDateTime.ofComp))), _aResult, _aivLB, _aivHB);
      end;
      varOleStr, varString:begin
        // Проверяю строковый тип и вырезаю скобки
        If (_aStCurrData='')Or(_aStCurrData[1]<>'''')Or(_aStCurrData[Length(_aStCurrData)]<>'''') Then Raise Exception.Create('Ожидается строковый тип.');
        _aStCurrData:=Copy(_aStCurrData, 2, Length(_aStCurrData)-2);
        _AddElementToResult(_aIsVarArray, _aivVarType, FStrToSQL.SQLToStr(_aStCurrData), _aResult, _aivLB, _aivHB);
      end;
      varBoolean:begin
        If StrToInt(_aStCurrData)=0 then _AddElementToResult(_aIsVarArray, _aivVarType, False, _aResult, _aivLB, _aivHB)
        else _AddElementToResult(_aIsVarArray, _aivVarType, True, _aResult, _aivLB, _aivHB);
      end;
      varVariant:Begin
        try
          _tmpV:=_StringToVarArray(_aStCurrData, _aiPosEndOfBlock-_aiLength+_aiI);
        except
          on e:exception do
            Raise Exception.Create('(к.бл='+IntToStr(_aiPosEndOfBlock-_aiLength+_aiI)+'):'+ e.message);
        end;
        try
          _AddElementToResult(_aIsVarArray, _aivVarType, _tmpV, _aResult, _aivLB, _aivHB);
        finally
          VarClear(_tmpV);
        end;
      end;
    Else
      Raise Exception.CreateResFmt(@stUnknownVariantType, [IntToStr(_aivVarType)]);
    end;
  end;
begin
  Result:=Unassigned;
  iLength:=Length(aString);
  If iLength=0 then Raise Exception.Create('aString=''''.');
  iI:=1;
  If aString[iI]=IsVarIsEmpty then begin
    Result:=Unassigned;
    Inc(iI);
    If iLength>=iI Then Raise Exception.Create('Не ожидается символ '''+aString[iI]+'''('+IntToStr(aiPosEndOfBlock-iLength+iI)+').');
    Exit;
  end;
  If aString[iI]=IsVarIsNull then begin
    Result:=Null;
    Inc(iI);
    If iLength>=iI Then Raise Exception.Create('Не ожидается символ '''+aString[iI]+'''('+IntToStr(aiPosEndOfBlock-iLength+iI)+').');
    Exit;
  end;
  ivLB:=-1; // от варнингов
  ivHB:=-1; // от варнингов
  ivVarType:=-1; // от варнингов
  // Определяю ivVarType, IsVarArray и ivLB.
  iStVarType:='';
  iStLB:='';
  IsVarArray:=false;
  While True do begin
    iCh:=aString[iI];
    If iCh in iSetNumbers then begin
      // это VarType
      If IsVarArray Then iStLB:=iStLB+iCh
      else iSTVarType:=iSTVarType+iCh;
    end else begin
      If iCh=IsVarIsArray then begin
        // это varArray
        If iSTVarType='' Then Raise Exception.Create('VarType не указан.');
        If IsVarArray Then Raise Exception.Create('Не ожидается символ '''+iCh+'''('+IntToStr(aiPosEndOfBlock-iLength+iI)+').');
        IsVarArray:=True;
      end else If iCh=IsBracketOpen then begin
        // это Data
        If IsVarArray then begin
          If iStLB='' then Raise Exception.Create('LowBound не указан.');
          ivLB:=StrToInt(iStLB);
        end else begin
          ivLB:=-1; // от варнингов
        end;
        If iSTVarType='' Then Raise Exception.Create('VarType не указан.');
        ivVarType:=StrToInt(iSTVarType);
        Break;
      end else Raise Exception.Create('Не ожидается символ '''+iCh+'''('+IntToStr(aiPosEndOfBlock-iLength+iI)+').');
    end;
    Inc(iI);
    If iI>iLength then Raise Exception.CreateResFmt(@stStringUnexpectTerminate, ['('+IntToStr(aiPosEndOfBlock-iLength+iI)+')']);
  end;
  // Получил: ivVarType, IsVarArray и ivLB
  // ..                                  v
  // Проверяю что курсор установлен на ..(..Data..
  If aString[iI]=IsBracketOpen then begin
    Inc(iI);
    iBracketsOpen:=1;
  end else begin
    Raise Exception.Create('Ожидается символ ''''''('+IntToStr(aiPosEndOfBlock-iLength+iI)+').');
  end;
  iElementAddedToResult:=0;
  iStCurrData:='';
  iApostropheOpen:=False;
  iSaveCurrDataOnThisStep:=true; // Если false то не прибавляет iCh в iStCurrData на текущем шаге.
  // Поднимаю данные
  While True do begin
    iCh:=aString[iI];
    If iCh=IsApostrophe then begin
      // это апостроф, и я его проматываю
      // '';
      // '')
      // '''';
      // ' sadasd''s';
      // 'as dasd ''';
      // 'ghgh'hjhgh;
      If iApostropheOpen Then begin
        // открыт
        If (iI+1)>iLength then Raise Exception.CreateResFmt(@stStringUnexpectTerminate, ['('+IntToStr(aiPosEndOfBlock-iLength+iI)+')']);
        If aString[iI+1]=IsApostrophe Then begin
          iStCurrData:=iStCurrData+IsApostrophe;
          Inc(iI);
        end else begin
          iApostropheOpen:=False;
        end;
      end else begin
        // закрыт
        iApostropheOpen:=True;
      end;
    end else If iApostropheOpen then begin
      {блокирую дальнейшую проверку, т.к. открыт апостроф}
    end else If iCh=IsBracketOpen then begin
      // Это открылась скобка
      Inc(iBracketsOpen);
    end else if iCh=IsBracketClose then begin
      // Это закрылась скобка
      Dec(iBracketsOpen);
      if iBracketsOpen<0 then Raise Exception.Create('Не ожидается символ '''+iCh+'''('+IntToStr(aiPosEndOfBlock-iLength+iI)+').');
      If iBracketsOpen=0 then begin
        // Это окончилась секция Data.
        if iStCurrData='' then Raise Exception.Create('Значение Data не может быть пустым.');
        If (Not IsVarArray)And(iElementAddedToResult>0) then Raise Exception.Create('Ожидается один параметр.');
        //Inc(iElementAddedToResult);
        _DataElemendIsFound(iStCurrData, IsVarArray, ivVarType, Result, ivLB, ivHB, iLength, aiPosEndOfBlock, iI);
        iStCurrData:='';
        Inc(iI);
        If iI<=iLength then Raise Exception.Create('Не ожидается символ '''+aString[iI]+'''('+IntToStr(aiPosEndOfBlock-iLength+iI)+').');
        Break;
      end;
    end else if iBracketsOpen>1 then begin
      {Отключаю дальнейшие проверки, т.к. идет Data в скобках}
    end else if iCh=IsDataSeparator then begin
      // Это завершился элемент Data
      if iStCurrData='' then Raise Exception.Create('Значение Data не может быть пустым.');
      If (Not IsVarArray)And(iElementAddedToResult>0) then Raise Exception.Create('Ожидается один параметр.');
      Inc(iElementAddedToResult);
      _DataElemendIsFound(iStCurrData, IsVarArray, ivVarType, Result, ivLB, ivHB, iLength, aiPosEndOfBlock, iI);
      iStCurrData:='';
      iSaveCurrDataOnThisStep:=false;                                                                                         {Inc(iI); If iI>iLength then Raise Exception.Create('Строка не ожидается закончилась('+IntToStr(iI)+').'); Continue;}
    end;// else Raise Exception.Create('Не ожидается символ '''+iCh+'''('+IntToStr(iI)+').');
    If iSaveCurrDataOnThisStep Then iStCurrData:=iStCurrData+iCh else iSaveCurrDataOnThisStep:=true;
    Inc(iI);
    If iI>iLength then Raise Exception.CreateResFmt(@stStringUnexpectTerminate, ['('+IntToStr(aiPosEndOfBlock-iLength+iI)+')']);
  end;
end;

Function TVarArrayString.StringToVarArray(aString:AnsiString):Variant;
begin
  try
    If aString='' Then Raise Exception.Create('aSitring=''''.');
    Result:=_StringToVarArray(aString, length(aString));
  except
    on e:Exception do
      Raise Exception.Create('StringToVarArray: '+e.Message);
  end;
end;

{ Blob ----------------------------------------------------------------------------------}
const
  //EasyArrayTypes = [varSmallInt, varInteger, varSingle, varDouble, varCurrency, varDate, varBoolean, varByte];
  VariantSize: array[0..varByte] of Word  = (0, 0, SizeOf(SmallInt), SizeOf(Integer),
    SizeOf(Single), SizeOf(Double), SizeOf(Currency), SizeOf(TDateTime), 0, 0,
    SizeOf(Integer), SizeOf(WordBool), 0, 0, 0, 0, 0, SizeOf(Byte));

Procedure TVarArrayString._GetBlobSize(aVar:Variant; Var aBlobSize:LongWord);
  Var ivLB, ivHB, iI, iVarType:Integer;
begin
  iVarType:=VarType(aVar)and varTypeMask;
  If VarIsArray(aVar) Then begin
    // is array
    If VarArrayDimCount(aVar)<>1 Then Raise Exception.Create('VarArrayDimCount(aVar)<>1.');
    ivLB:=VarArrayLowBound(aVar, 1);
    ivHB:=VarArrayHighBound(aVar, 1);
    Inc(aBlobSize,10);{Word+Integer+Integer} //для организации VarArray
    Case iVarType of
      varEmpty, varNull:begin
        {ничего, т.к. DataSize=0};
      end;
      varSmallint, varInteger, varByte, varSingle, varDouble, varCurrency,
      varBoolean, varDate:begin
        Inc(aBlobSize,VariantSize[iVarType]*(ivHB-ivLB+1));
      end;
      varOleStr:begin
        Inc(aBlobSize, Length(WideString(aVar))*2);
      end;
      varString:begin
        Inc(aBlobSize, Length(AnsiString(aVar)));
      end;
      varVariant:begin
        // array of variant
        For iI:=ivLB to ivHB do begin
          _GetBlobSize(aVar[iI], aBlobSize);
        end;
      end;
    else
      Raise Exception.CreateResFmt(@stUnknownVariantType, [IntToStr(iVarType)]);
    end;
  end else begin
    Case iVarType of
      varEmpty, varNull:begin
        {ничего, т.к. DataSize=0};
      end;
      varSmallint, varInteger, varByte, varSingle, varDouble, varCurrency,
      varBoolean, varDate:begin
        Inc(aBlobSize,VariantSize[iVarType]);
      end;
      varOleStr:begin
        Inc(aBlobSize, Length(WideString(aVar))*2);
      end;
      varString:begin
        Inc(aBlobSize, Length(AnsiString(aVar)));
      end;
    else
      Raise Exception.CreateResFmt(@stUnknownVariantType, [IntToStr(iVarType)]);
    end;
  end;
end;

Function TVarArrayString._VarArrayToBlob(aPVar:PVariant; aBlobSize:LongWord; Var aBlobPos:LongWord):Pointer;
{  Var iJ, ivLB, ivHB : Integer;
      iDateTime:T64bit;}
begin
  result:=nil;
(*  If VarIsArray(aVar) Then begin
    // VarArray
    If VarArrayDimCount(aVar)<>1 Then Raise Exception.Create('VarArrayDimCount(aVar)<>1.');
    ivLB:=VarArrayLowBound(aVar, 1);
    ivHB:=VarArrayHighBound(aVar,1);
    ?
    Result:=IntToStr(VarType(aVar)and varTypeMask)+'/'+IntToStr(ivLB)+'(';
    For iJ:=ivLB to ivHB do begin
      Result:=Result+_VarArrayToString(aVar[iJ], {aLevel+1,} VarType(aVar)and varTypeMask);
      If iJ>=ivHB Then
        Result:=Result+')'
      else
        Result:=Result+';';
    end;
  End else begin
    // simple Variant
    If aVarType=varVariant then begin
      // для вызова верхнего вызова разборщика
      Case VarType(aVar) of
        varEmpty:begin
          Result:='~'{'0()'};
        end;
        varNull:begin
          Result:='#'{'1()'};
        end;
        varSmallint, varInteger, varByte, varSingle, varDouble, varCurrency:begin
          Result:=IntToStr(VarType(aVar)and varTypeMask)+'('+VarToStr(aVar)+')';
        end;
        varDate:begin
          iDateTime.OfComp:=TimeStampToMSecs(DateTimeToTimeStamp(VarToDateTime(aVar)));
          Result:=IntToStr(VarType(aVar)and varTypeMask)+'('+IntToStr(iDateTime.ofInt64)+')'; {IntToStr(VarType(aVar)and varTypeMask)+'('+DateTimeToStr(VarToDateTime(aVar))+')'}
        end;
        varOleStr, varString:begin
          Result:=IntToStr(VarType(aVar)and varTypeMask)+'('''+FStrToSQL.StrToSQL(aVar)+''')';
        end;
        varBoolean:begin
          Result:=IntToStr(VarType(aVar)and varTypeMask)+'('+IntToStr(Integer(Boolean(aVar)))+')';
        end;
      else
        Raise Exception.CreateResFmt(@stUnknownVariantType, [IntToStr(VarType(aVar))]);
      end;
    end else begin
      // для суб-вызова разборщика.
      Case VarType(aVar) of
        varSmallint, varInteger, varByte, varSingle, varDouble, varCurrency:begin
          Result:=VarToStr(aVar);
        end;
        varDate:begin
          iDateTime.OfComp:=TimeStampToMSecs(DateTimeToTimeStamp(VarToDateTime(aVar)));
          Result:=IntToStr(iDateTime.ofInt64);{Result:=DateTimeToStr(VarToDateTime(aVar))}
        end;
        varOleStr, varString:begin
          Result:=''''+FStrToSQL.StrToSQL(aVar)+'''';
        end;
        varBoolean:begin
          Result:=IntToStr(Integer(Boolean(aVar)));
        end;
      else
        Raise Exception.Create('Преобразование для типа('+IntToStr(VarType(aVar))+') невозможно.');
      end;
    end;
  end;(*)
end;

Function TVarArrayString.VarArrayToBlob(aPVar:PVariant; out aBlobSize:LongWord):Pointer;
  Var tmpI:LongWord;
begin
  try
    tmpI:=0;
    _GetBlobSize(aPVar^, aBlobSize);
    Result:=_VarArrayToBlob(aPVar, aBlobSize, tmpI);
  except
    on e:Exception do
      Raise Exception.Create('VarArrayToBlob: '+e.Message);
  end;
end;

Function TVarArrayString._BlobToVarArray(aBlob:Pointer; aBlobSize:LongWord):Variant;
begin
  //1
end;

Function TVarArrayString.BlobToVarArray(aBlob:Pointer; aBlobSize:LongWord):Variant;
begin
  try
    If aBlob=Nil Then Raise Exception.Create('aBlob is NULL.');
    Result:=_BlobToVarArray(aBlob, aBlobSize);
  except
    on e:Exception do
      Raise Exception.Create('BlobToVarArray: '+e.Message);
  end;
end;

end.


