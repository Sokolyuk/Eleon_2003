//Copyright © 2000-2004 by Dmitry A. Sokolyuk
unit UTypeUtils;

interface

  function glVarArrayToString(const aVariant:Variant):AnsiString;
  function glStringToVarArray(const aString:AnsiString):Variant;
  function glVarArrayToBlob(aPVar:PVariant; out aBlobSize:LongWord):Pointer;
  function glBlobToVarArray(aBlob:Pointer; aBlobSize:LongWord):Variant;
  function glStringToGUID(const S:AnsiString):TGUID;
  function glGUIDToString(const ClassID:TGUID):AnsiString;
  procedure glVariantToFile(const aData:Variant; const aFileName:AnsiString);
  function glFileToVariant(const aFileName:AnsiString):Variant;
  function GUIDToVariant(const aBfGUID:TGUID):Variant;
  function VariantToGUID(aParam:Variant):TGUID;

resourcestring
  stUnknownVariantType='Преобразование для VType=%s не поддерживается.';
  stStringUnexpectTerminate='Строка не ожидается закончилась%s.';

implementation
  uses SysUtils, UDateTimeUtils{$ifndef ver130}, Variants{$endif}, UStringUtils, ActiveX;

{$IFDEF VER130} //For varTypes, from D6
Const
  varShortInt=$0010;{ vt_i1  16 }
  varWord=$0012;{ vt_ui2 18 }
  varLongWord=$0013;{ vt_ui4 19 }
  varInt64=$0014;{ vt_i8  20 }
{$ENDIF}

function _VarArrayToString(const aVariant:Variant; aVarType:TVarType):AnsiString;
  Var iJ, ivLB, ivHB : Integer;
      tmpType, tmpVarType:TVarType;
begin
  tmpVarType:=VarType(aVariant);
  tmpType:=tmpVarType And Not(varTypeMask);
  tmpVarType:=tmpVarType And varTypeMask;
  if tmpType<>0{varArray/varByRef} then begin
    if (tmpType<>varByRef)And(tmpType<>varArray) then raise exception.create('Unsupported VarType='+IntToStr(VarType(aVariant))+'.');
    if VarArrayDimCount(aVariant)<>1 then raise exception.create('DimCount('+IntToStr(VarArrayDimCount(aVariant))+')<>1.');
    ivLB:=VarArrayLowBound(aVariant, 1);
    ivHB:=VarArrayHighBound(aVariant, 1);
    Result:=IntToStr(tmpVarType)+'/'+IntToStr(ivLB)+'(';
    For iJ:=ivLB to ivHB do begin
      Result:=Result+_VarArrayToString(aVariant[iJ], tmpVarType);
      if iJ>=ivHB then Result:=Result+')' else Result:=Result+';';
    end;
  end else begin
    //simple Variant
    if aVarType=varVariant then begin
      //для вызова верхнего вызова разборщика
      case tmpVarType{VarType(aVariant)} of
        varEmpty:begin
          Result:='~'{'0()'};
        end;
        varNull:begin
          Result:='#'{'1()'};
        end;
        varSmallint, varInteger, varByte, varSingle, varDouble, varCurrency, varShortInt, varWord, varLongWord, varInt64:begin//Types from D6
          Result:=IntToStr(tmpVarType)+'('+VarToStr(aVariant)+')';
        end;
        varDate:begin
          Result:=IntToStr(tmpVarType)+'('+IntToStr(DateTimeToMSecs(VarToDateTime(aVariant)))+')';
        end;
        varOleStr, varString:begin
          Result:=IntToStr(tmpVarType)+'('''+StrToSql(aVariant)+''')';
        end;
        varBoolean:begin
          Result:=IntToStr(tmpVarType)+'('+IntToStr(Integer(Boolean(aVariant)))+')';
        end;
      else
        raise exception.createResFmt(@stUnknownVariantType, [IntToStr(tmpVarType)]); //Create('Преобразование для типа('+IntToStr(VarType(aVariant))+') невозможно.');
      end;
    end else begin
      case tmpVarType of//для суб-вызова разборщика.
        varSmallint, varInteger, varByte, varSingle, varDouble, varCurrency, varShortInt, varWord, varLongWord, varInt64:begin//Types from D6
          Result:=VarToStr(aVariant);
        end;
        varDate:begin
          Result:=IntToStr(DateTimeToMSecs(VarToDateTime(aVariant)));
        end;
        varOleStr, varString:begin
          Result:=''''+StrToSql(aVariant)+'''';
        end;
        varBoolean:begin
          Result:=IntToStr(Integer(Boolean(aVariant)));
        end;
      else
        raise exception.createResFmt(@stUnknownVariantType, [IntToStr(tmpVarType)]);
      end;
    end;
  end;
end;

function glVarArrayToString(const aVariant:Variant):AnsiString;
begin
  try
    Result:=_VarArrayToString(aVariant, varVariant);
  except on e:exception do begin
    e.message:='VarArrayToString: '+e.message;
    raise;
  end;end;
end;

// Тип/LowBound(Data;Data...)
// 11/0(1;0;0;0;0;1)
// 12/0(5(1,452211);8('1');7(63135825807062);~;#;3/-5(0;0;0)) -array
// ~ -empty
// # -null
function _StringToVarArray(const aString:AnsiString; aiPosEndOfBlock:Integer):Variant;
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
  procedure _AddElementToResult(_aIsVarArray:Boolean; alVarType:Integer; const alElement:Variant; Var _aResult:Variant; _aivLB:Integer; Var _aivHB:Integer);
  begin
    if _aIsVarArray then begin
      if VarIsArray(_aResult) then begin
        VarArrayRedim(_aResult, _aivHB+1);
        inc(_aivHB);
      end else begin
        _aResult:=VarArrayCreate([_aivLB, _aivLB], alVarType);
        _aivHB:=_aivLB;
      end;
      _aResult[_aivHB]:=alElement;
    end else begin
      try
        VarCast(_aResult, alElement, alVarType);
      except on e:exception do begin
        e.message:='VarCast(VType='+IntToStr(alVarType)+'): '+e.message;
        raise;
      end;end;
    end;
  end;
  procedure _DataElemendIsFound(_aStCurrData:AnsiString; _aIsVarArray:Boolean; alVarType:Integer; Var _aResult:Variant; _aivLB:Integer; Var _aivHB:Integer; _aiLength, _aiPosEndOfBlock, _aiI:Integer);
  Var tmplV:Variant;
{$IFDEF VER140}{only D6}
      tmplLongWord:LongWord;
      tmplInt64:Int64;
      tmplWord:Word;
      tmplShortInt:ShortInt;
{$ENDIF}
      tmplByte:Byte;
      tmplSmallInt:SmallInt;
      tmplInteger:Integer;
      tmplSingle:Single;
      tmplDouble:Double;
  begin
    case alVarType of
      varEmpty:begin
        _AddElementToResult(_aIsVarArray, alVarType, Unassigned{'0()'}, _aResult, _aivLB, _aivHB);
      end;
      varNull:begin
        _AddElementToResult(_aIsVarArray, alVarType, Null{'1()'}, _aResult, _aivLB, _aivHB);
      end;
      varInteger:begin
        tmplInteger:=StrToInt(_aStCurrData);
        _AddElementToResult(_aIsVarArray, alVarType, tmplInteger, _aResult, _aivLB, _aivHB);
      end;
      varSmallint:begin
        tmplSmallInt:=StrToInt(_aStCurrData);
        _AddElementToResult(_aIsVarArray, alVarType, tmplSmallInt, _aResult, _aivLB, _aivHB);
      end;
      varByte:begin
        tmplByte:=StrToInt(_aStCurrData);
        _AddElementToResult(_aIsVarArray, alVarType, tmplByte, _aResult, _aivLB, _aivHB);
      end;
{$IFDEF VER140}{only D6}
      varShortInt:begin
        tmplShortInt:=StrToInt(_aStCurrData);
        _AddElementToResult(_aIsVarArray, alVarType, tmplShortInt, _aResult, _aivLB, _aivHB);
      end;
      varWord:begin
        tmplWord:=StrToInt(_aStCurrData);
        _AddElementToResult(_aIsVarArray, alVarType, tmplWord, _aResult, _aivLB, _aivHB);
      end;
      varLongWord:begin
        tmplLongWord:=StrToInt64(_aStCurrData);
        _AddElementToResult(_aIsVarArray, alVarType, tmplLongWord, _aResult, _aivLB, _aivHB);
      end;
      varInt64:begin
        tmplInt64:=StrToInt64(_aStCurrData);
        _AddElementToResult(_aIsVarArray, alVarType, tmplInt64, _aResult, _aivLB, _aivHB);
        tmplV:=unassigned;
      end;
{$ENDIF}
{$IFDEF VER130}{only D6}
      varShortInt, varWord, varLongWord, varInt64:begin
        try
          tmplInteger:=StrToInt(_aStCurrData);
        except on e:exception do begin
          e.message:='D5.VarType-emulator(var_'+IntToStr(alVarType)+'ToInteger): '+e.message;
          raise;
        end;end;
        _AddElementToResult(_aIsVarArray, varInteger, tmplInteger, _aResult, _aivLB, _aivHB);
      end;
{$ENDIF}
      varSingle:begin
        tmplSingle:=StrToFloat(_aStCurrData);
        _AddElementToResult(_aIsVarArray, alVarType, tmplSingle, _aResult, _aivLB, _aivHB);
      end;
      varDouble:begin
        tmplDouble:=StrToFloat(_aStCurrData);
        _AddElementToResult(_aIsVarArray, alVarType, tmplDouble, _aResult, _aivLB, _aivHB);
      end;
      varCurrency:begin
        _AddElementToResult(_aIsVarArray, alVarType, StrToCurr(_aStCurrData), _aResult, _aivLB, _aivHB);
      end;
      varDate:begin
        _AddElementToResult(_aIsVarArray, alVarType, MSecsToDateTime(StrToInt64(_aStCurrData)), _aResult, _aivLB, _aivHB);
      end;
      varOleStr, varString:begin// Проверяю строковый тип и вырезаю скобки
        if (_aStCurrData='')Or(_aStCurrData[1]<>'''')Or(_aStCurrData[Length(_aStCurrData)]<>'''') then raise exception.create('Ожидается строковый тип.');
        _aStCurrData:=Copy(_aStCurrData, 2, Length(_aStCurrData)-2);
        _AddElementToResult(_aIsVarArray, alVarType, SqlToStr(_aStCurrData), _aResult, _aivLB, _aivHB);
      end;
      varBoolean:begin
        if StrToInt(_aStCurrData)=0 then _AddElementToResult(_aIsVarArray, alVarType, False, _aResult, _aivLB, _aivHB)
        else _AddElementToResult(_aIsVarArray, alVarType, True, _aResult, _aivLB, _aivHB);
      end;
      varVariant:begin
        try
          tmplV:=_StringToVarArray(_aStCurrData, _aiPosEndOfBlock-_aiLength+_aiI);
        except on e:exception do begin
          e.message:='(к.бл='+IntToStr(_aiPosEndOfBlock-_aiLength+_aiI)+'):'+ e.message;
          raise;
        end;end;
        _AddElementToResult(_aIsVarArray, alVarType, tmplV, _aResult, _aivLB, _aivHB);
      end;
    else
      raise exception.createResFmt(@stUnknownVariantType, [IntToStr(alVarType)]);
    end;
  end;
begin
  Result:=Unassigned;
  iLength:=Length(aString);
  if iLength=0 then raise exception.create('aString=''''.');
  iI:=1;
  if aString[iI]=IsVarIsEmpty then begin
    Result:=Unassigned;
    inc(iI);
    if iLength>=iI then raise exception.create('Не ожидается символ '''+aString[iI]+'''('+IntToStr(aiPosEndOfBlock-iLength+iI)+').');
    Exit;
  end;
  if aString[iI]=IsVarIsNull then begin
    Result:=Null;
    inc(iI);
    if iLength>=iI then raise exception.create('Не ожидается символ '''+aString[iI]+'''('+IntToStr(aiPosEndOfBlock-iLength+iI)+').');
    Exit;
  end;
  ivLB:=-1; // от варнингов
  ivHB:=-1; // от варнингов
  ivVarType:=-1; // от варнингов
  // Определяю ivVarType, IsVarArray и ivLB.
  iStVarType:='';
  iStLB:='';
  IsVarArray:=false;
  while true do begin
    iCh:=aString[iI];
    if iCh in iSetNumbers then begin
      // это VarType
      if IsVarArray then iStLB:=iStLB+iCh
      else iSTVarType:=iSTVarType+iCh;
    end else begin
      if iCh=IsVarIsArray then begin
        // это varArray
        if iSTVarType='' then raise exception.create('VarType не указан.');
        if IsVarArray then raise exception.create('Не ожидается символ '''+iCh+'''('+IntToStr(aiPosEndOfBlock-iLength+iI)+').');
        IsVarArray:=True;
      end else if iCh=IsBracketOpen then begin
        // это Data
        if IsVarArray then begin
          if iStLB='' then raise exception.create('LowBound не указан.');
          ivLB:=StrToInt(iStLB);
        end else begin
          ivLB:=-1; // от варнингов
        end;
        if iSTVarType='' then raise exception.create('VarType не указан.');
        ivVarType:=StrToInt(iSTVarType);
        Break;
      end else raise exception.create('Не ожидается символ '''+iCh+'''('+IntToStr(aiPosEndOfBlock-iLength+iI)+').');
    end;
    inc(iI);
    if iI>iLength then raise exception.createResFmt(@stStringUnexpectTerminate, ['('+IntToStr(aiPosEndOfBlock-iLength+iI)+')']);
  end;
  // Получил: ivVarType, IsVarArray и ivLB
  // ..                                  v
  // Проверяю что курсор установлен на ..(..Data..
  if aString[iI]=IsBracketOpen then begin
    inc(iI);
    iBracketsOpen:=1;
  end else begin
    raise exception.create('Ожидается символ ''''''('+IntToStr(aiPosEndOfBlock-iLength+iI)+').');
  end;
  iElementAddedToResult:=0;
  iStCurrData:='';
  iApostropheOpen:=False;
  iSaveCurrDataOnThisStep:=true; // Если false то не прибавляет iCh в iStCurrData на текущем шаге.
  // Поднимаю данные
  while true do begin
    iCh:=aString[iI];
    if iCh=IsApostrophe then begin
      // это апостроф, и я его проматываю
      // '';
      // '')
      // '''';
      // ' sadasd''s';
      // 'as dasd ''';
      // 'ghgh'hjhgh;
      if iApostropheOpen then begin
        // открыт
        if (iI+1)>iLength then raise exception.createResFmt(@stStringUnexpectTerminate, ['('+IntToStr(aiPosEndOfBlock-iLength+iI)+')']);
        if aString[iI+1]=IsApostrophe then begin
          iStCurrData:=iStCurrData+IsApostrophe;
          inc(iI);
        end else begin
          //проверка от случая 8('' '')
          if (aString[iI+1] <> IsBracketClose) and (aString[iI+1] <> IsDataSeparator) then raise exception.create('Не ожидается символ '''+aString[iI+1]+'''('+IntToStr(aiPosEndOfBlock-iLength+iI+1)+').');
          iApostropheOpen:=false;
        end;
      end else begin
        //закрыт
        iApostropheOpen:=true;
      end;
    end else if iApostropheOpen then begin
      {блокирую дальнейшую проверку, т.к. открыт апостроф}
    end else if iCh=IsBracketOpen then begin
      // Это открылась скобка
      inc(iBracketsOpen);
    end else if iCh=IsBracketClose then begin
      // Это закрылась скобка
      Dec(iBracketsOpen);
      if iBracketsOpen<0 then raise exception.create('Не ожидается символ '''+iCh+'''('+IntToStr(aiPosEndOfBlock-iLength+iI)+').');
      if iBracketsOpen=0 then begin
        // Это окончилась секция Data.
        if iStCurrData='' then raise exception.create('Значение Data не может быть пустым.');
        if (Not IsVarArray)And(iElementAddedToResult>0) then raise exception.create('Ожидается один параметр.');
        //inc(iElementAddedToResult);
        _DataElemendIsFound(iStCurrData, IsVarArray, ivVarType, Result, ivLB, ivHB, iLength, aiPosEndOfBlock, iI);
        iStCurrData:='';
        inc(iI);
        if iI<=iLength then raise exception.create('Не ожидается символ '''+aString[iI]+'''('+IntToStr(aiPosEndOfBlock-iLength+iI)+').');
        Break;
      end;
    end else if iBracketsOpen>1 then begin
      {Отключаю дальнейшие проверки, т.к. идет Data в скобках}
    end else if iCh=IsDataSeparator then begin
      // Это завершился элемент Data
      if iStCurrData='' then raise exception.create('Значение Data не может быть пустым.');
      if (Not IsVarArray)And(iElementAddedToResult>0) then raise exception.create('Ожидается один параметр.');
      inc(iElementAddedToResult);
      _DataElemendIsFound(iStCurrData, IsVarArray, ivVarType, Result, ivLB, ivHB, iLength, aiPosEndOfBlock, iI);
      iStCurrData:='';
      iSaveCurrDataOnThisStep:=false;                                                                                         {inc(iI); if iI>iLength then raise exception.create('Строка не ожидается закончилась('+IntToStr(iI)+').'); Continue;}
    end;// else raise exception.create('(++)Не ожидается символ '''+iCh+'''('+IntToStr(iI)+').');
    if iSaveCurrDataOnThisStep then iStCurrData:=iStCurrData+iCh else iSaveCurrDataOnThisStep:=true;
    inc(iI);
    if iI>iLength then raise exception.createResFmt(@stStringUnexpectTerminate, ['('+IntToStr(aiPosEndOfBlock-iLength+iI)+')']);
  end;
end;

function glStringToVarArray(const aString:AnsiString):Variant;
begin
  try
    if aString='' then raise exception.create('aSitring=''''.');
    Result:=_StringToVarArray(aString, length(aString));
  except
    on e:exception do begin
      e.message:='StringToVarArray: '+e.message;
      raise;
  end;end;
end;

{ Blob ----------------------------------------------------------------------------------}
const
  //EasyArrayTypes = [varSmallInt, varInteger, varSingle, varDouble, varCurrency, varDate, varBoolean, varByte];
  VariantSize: array[0..varByte] of Word  = (0, 0, SizeOf(SmallInt), SizeOf(Integer),
    SizeOf(Single), SizeOf(Double), SizeOf(Currency), SizeOf(TDateTime), 0, 0,
    SizeOf(Integer), SizeOf(WordBool), 0, 0, 0, 0, 0, SizeOf(Byte));

procedure _GetBlobSize(const aVariant:Variant; Var aBlobSize:LongWord);
  Var ivLB, ivHB, iI, iVarType:Integer;
begin
  iVarType:=VarType(aVariant)and varTypeMask;
  if VarIsArray(aVariant) then begin
    // is array
    if VarArrayDimCount(aVariant)<>1 then raise exception.create('VarArrayDimCount(aVariant)<>1.');
    ivLB:=VarArrayLowBound(aVariant, 1);
    ivHB:=VarArrayHighBound(aVariant, 1);
    inc(aBlobSize,10);{Word+Integer+Integer} //для организации VarArray
    case iVarType of
      varEmpty, varNull:begin
        {ничего, т.к. DataSize=0};
      end;
      varSmallint, varInteger, varByte, varSingle, varDouble, varCurrency, varBoolean, varDate, varShortInt, varWord, varLongWord, varInt64:begin//Types from D6
        inc(aBlobSize, VariantSize[iVarType]*(ivHB-ivLB+1));
      end;
      varOleStr:begin
        inc(aBlobSize, Length(WideString(aVariant))*2);
      end;
      varString:begin
        inc(aBlobSize, Length(AnsiString(aVariant)));
      end;
      varVariant:begin
        // array of variant
        For iI:=ivLB to ivHB do begin
          _GetBlobSize(aVariant[iI], aBlobSize);
        end;
      end;
    else
      raise exception.createResFmt(@stUnknownVariantType, [IntToStr(iVarType)]);
    end;
  end else begin
    case iVarType of
      varEmpty, varNull:{ничего, т.к. DataSize=0};
      varSmallint, varInteger, varByte, varSingle, varDouble, varCurrency, varBoolean, varDate, varShortInt, varWord, varLongWord, varInt64:begin//Types from D6
        inc(aBlobSize,VariantSize[iVarType]);
      end;
      varOleStr:begin
        inc(aBlobSize, Length(WideString(aVariant))*2);
      end;
      varString:begin
        inc(aBlobSize, Length(AnsiString(aVariant)));
      end;
    else
      raise exception.createResFmt(@stUnknownVariantType, [IntToStr(iVarType)]);
    end;
  end;
end;

function _VarArrayToBlob(aPVar:PVariant; aBlobSize:LongWord; Var aBlobPos:LongWord):Pointer;
{  Var iJ, ivLB, ivHB : Integer;
      iDateTime:T64bit;}
begin
  result:=nil;
(*  if VarIsArray(aVariant) then begin
    // VarArray
    if VarArrayDimCount(aVariant)<>1 then raise exception.create('VarArrayDimCount(aVariant)<>1.');
    ivLB:=VarArrayLowBound(aVariant, 1);
    ivHB:=VarArrayHighBound(aVariant,1);
    ?
    Result:=IntToStr(VarType(aVariant)and varTypeMask)+'/'+IntToStr(ivLB)+'(';
    For iJ:=ivLB to ivHB do begin
      Result:=Result+_VarArrayToString(aVariant[iJ], {aLevel+1,} VarType(aVariant)and varTypeMask);
      if iJ>=ivHB Then
        Result:=Result+')'
      else
        Result:=Result+';';
    end;
  end else begin
    // simple Variant
    if aVarType=varVariant then begin
      // для вызова верхнего вызова разборщика
      case VarType(aVariant) of
        varEmpty:begin
          Result:='~'{'0()'};
        end;
        varNull:begin
          Result:='#'{'1()'};
        end;
        varSmallint, varInteger, varByte, varSingle, varDouble, varCurrency
        ?, varShortInt, varWord, varLongWord, varInt64//Types from D6
        :begin
          Result:=IntToStr(VarType(aVariant)and varTypeMask)+'('+VarToStr(aVariant)+')';
        end;
        varDate:begin
          iDateTime.OfComp:=TimeStampToMSecs(DateTimeToTimeStamp(VarToDateTime(aVariant)));
          Result:=IntToStr(VarType(aVariant)and varTypeMask)+'('+IntToStr(iDateTime.ofInt64)+')'; {IntToStr(VarType(aVariant)and varTypeMask)+'('+DateTimeToStr(VarToDateTime(aVariant))+')'}
        end;
        varOleStr, varString:begin
          Result:=IntToStr(VarType(aVariant)and varTypeMask)+'('''+StrToSql(aVariant)+''')';
        end;
        varBoolean:begin
          Result:=IntToStr(VarType(aVariant)and varTypeMask)+'('+IntToStr(Integer(Boolean(aVariant)))+')';
        end;
      else
        raise exception.createResFmt(@stUnknownVariantType, [IntToStr(VarType(aVariant))]);
      end;
    end else begin
      // для суб-вызова разборщика.
      case VarType(aVariant) of
        varSmallint, varInteger, varByte, varSingle, varDouble, varCurrency
        ?, varShortInt, varWord, varLongWord, varInt64//Types from D6
        :begin
          Result:=VarToStr(aVariant);
        end;
        varDate:begin
          iDateTime.OfComp:=TimeStampToMSecs(DateTimeToTimeStamp(VarToDateTime(aVariant)));
          Result:=IntToStr(iDateTime.ofInt64);{Result:=DateTimeToStr(VarToDateTime(aVariant))}
        end;
        varOleStr, varString:begin
          Result:=''''+StrToSql(aVariant)+'''';
        end;
        varBoolean:begin
          Result:=IntToStr(Integer(Boolean(aVariant)));
        end;
      else
        raise exception.create('Преобразование для типа('+IntToStr(VarType(aVariant))+') невозможно.');
      end;
    end;
  end;(*)
end;

function glVarArrayToBlob(aPVar:PVariant; out aBlobSize:LongWord):Pointer;
  Var tmpI:LongWord;
begin
  try
    tmpI:=0;
    _GetBlobSize(aPVar^, aBlobSize);
    Result:=_VarArrayToBlob(aPVar, aBlobSize, tmpI);
  except
    on e:exception do begin
      e.message:='VarArrayToBlob: '+e.message;
      raise;
  end;end;
end;

function _BlobToVarArray(aBlob:Pointer; aBlobSize:LongWord):Variant;
begin
  //1
end;

function glBlobToVarArray(aBlob:Pointer; aBlobSize:LongWord):Variant;
begin
  try
    if aBlob=Nil then raise exception.create('aBlob is NULL.');
    Result:=_BlobToVarArray(aBlob, aBlobSize);
  except
    on e:exception do begin
      e.message:='BlobToVarArray: '+e.message;
      raise;
  end;end;
end;

function Succeeded(Res: HResult):Boolean;
begin
  Result := Res and $80000000 = 0;
end;

procedure OleCheck(Value:HResult);
begin
  if not Succeeded(Value) then raise exception.create(SysErrorMessage(Value));
end;

function glStringToGUID(const S:AnsiString):TGUID;
begin
  OleCheck(CLSIDFromString(PWideChar(WideString(S)), Result));
end;

function glGUIDToString(const ClassID:TGUID):AnsiString;
  var P:PWideChar;
begin
  OleCheck(StringFromCLSID(ClassID, P));
  Result:=P;
  CoTaskMemFree(P);
end;

procedure glVariantToFile(const aData:Variant; const aFileName:AnsiString);
  Var tmpSize:Integer;
      tmpPntr:Pointer;
      tmpFD:File;
begin
  try
    tmpSize:=VarArrayHighBound(aData, 1)-VarArrayLowBound(aData, 1)+1;
    tmpPntr:=VarArrayLock(aData);
    try
      AssignFile(tmpFD, aFileName);
      Rewrite(tmpFD, 1);
      BlockWrite(tmpFD, tmpPntr^, tmpSize);
      CloseFile(tmpFD);
    finally
      VarArrayUnlock(aData);
    end;
  except on e:exception do begin
    e.message:='glVariantToFile: '+e.message;
    raise;
  end;end;
end;

function glFileToVariant(const aFileName:AnsiString):Variant;
  Var tmpSize:Integer;
      tmpPntr:Pointer;
      tmpFD:File;
begin
  try
    AssignFile(tmpFD, aFileName);
    ReSet(tmpFD, 1);
    tmpSize:=FileSize(tmpFD);
    Result:=VarArrayCreate([0, tmpSize], varByte);
    tmpPntr:=VarArrayLock(Result);
    try
      BlockRead(tmpFD, tmpPntr^, tmpSize);
    finally
      try CloseFile(tmpFD); except end;
      VarArrayUnlock(Result);
    end;
  except on e:exception do begin
    e.message:='glFileToVariant: '+e.message;
    raise;
  end;end;
end;

type PIntArray=^TIntArray;
     TIntArray=array[0..3] of Integer;

function GUIDToVariant(const aBfGUID:TGUID):Variant;
begin
  result:=VarArrayCreate([0, 3], varInteger);
  result[0]:=PIntArray(@aBfGUID)^[0];
  result[1]:=PIntArray(@aBfGUID)^[1];
  result[2]:=PIntArray(@aBfGUID)^[2];
  result[3]:=PIntArray(@aBfGUID)^[3];
end;

function VariantToGUID(aParam:Variant):TGUID;
begin
  PIntArray(@result)^[0]:=aParam[0];
  PIntArray(@result)^[1]:=aParam[1];
  PIntArray(@result)^[2]:=aParam[2];
  PIntArray(@result)^[3]:=aParam[3];
end;



end.
