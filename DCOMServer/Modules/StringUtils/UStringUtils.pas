//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UStringUtils;

interface

  procedure SkipString(var aPos:integer; const aStatement:AnsiString);

  function GetParamFromParamsStr(var aCurrentPos:integer; const aParamsStr:AnsiString; const aParamSeparator:char):AnsiString;
  function CheckIncludeParamStrInParamsStr(const aParamsStr:AnsiString; const aParamStr:AnsiString; const aParamSeparator:char):Boolean;
  function CheckIncludeParamsStrInParamsStr(const aParamsStrSource:AnsiString; const aParamsStrCheck:AnsiString; const aParamSeparator:char):Boolean;
  function GetDifferentParamsStrFromParamsStr(const aParamsStrSource:AnsiString; const aParamsStrDiff:AnsiString; const aParamSeparator:char):AnsiString;
  function CompareParamsStr(const aParamsStr1:AnsiString; const aParamsStr2:AnsiString; const aParamSeparator:char):Boolean;

  function StrToSql(const aStr:AnsiString):AnsiString;
  function SqlToStr(const aSql:AnsiString):AnsiString;
  function StrToSqlStr(const aStr:AnsiString):AnsiString;
  function SqlStrToStr(const aSqlStr:AnsiString):AnsiString;

implementation
  uses UStringConsts, Sysutils;   

procedure SkipString(var aPos:integer; const aStatement:AnsiString);
  var tmpLength:integer;
begin
  tmpLength := Length(aStatement);
  if (aPos > tmpLength) or (aPos < 1) then raise exception.createfmt(cnUnsatisfiedStatementTerminated, [aStatement]);
  if aStatement[aPos] <> '''' then raise exception.createfmt(cnInvalidValueOf, [aStatement[aPos] + ' position=' + IntToStr(aPos), aStatement]);
  inc(aPos);
  while true do begin
    if (aPos > tmpLength) then raise exception.createfmt(cnUnsatisfiedStatementTerminated, [aStatement]);
    if aStatement[aPos] = '''' then begin//текущая апостроф
      if ((aPos+1)<=tmpLength)and(aStatement[aPos+1] = '''') then begin//следующая есть и это тоже апостроф
        inc(aPos);//проскакиваю двойную
      end else begin//слудующей нет или там не апостроф
        inc(aPos);
        break;//выхожу
      end;
    end;
    inc(aPos);
  end;
end;

function StrToSql(const aStr:AnsiString):AnsiString;
  var tmpI, tmpLastPos, tmpLength:Integer;
begin
  tmpLastPos:=1;
  Result:='';
  tmpLength:=Length(aStr);
  for tmpI:=1 to tmpLength do begin
    if aStr[tmpI]='''' then begin
      Result:=Result+Copy(aStr, tmpLastPos, tmpI-tmpLastPos)+'''';
      tmpLastPos:=tmpI;
    end;
  end;
  Result:=Result+Copy(aStr, tmpLastPos, tmpLength-tmpLastPos+1);
end;

function StrToSqlStr(const aStr:AnsiString):AnsiString;
begin
  result := '''' + StrToSQL(aStr) + '''';
end;

function SqlToStr(const aSql:AnsiString):AnsiString;
  var tmpI:integer;
      tmpLength:integer;
begin
  tmpLength := Length(aSql);

  result := '';
  tmpI := 1;
  while true do begin
    if tmpI > tmpLength then break;
    if aSql[tmpI] = '''' then begin
      if (tmpI+1 <= tmpLength) and (aSql[tmpI+1] = '''') then begin
        result := result + '''';
        inc(tmpI);
      end else begin
        raise exception.create('Bad('') aSql.');
      end;
    end else begin
      result := result + aSql[tmpI];
    end;
    inc(tmpI);
  end;
end;

function SqlStrToStr(const aSqlStr:AnsiString):AnsiString;
  var //tmpI:integer;
      tmpLength:integer;
begin
  tmpLength := Length(aSqlStr);
  if tmpLength = 0 then raise exception.create('aSqlStr is empty.');
  if (tmpLength = 1) or (aSqlStr[1] <> '''') or (aSqlStr[tmpLength] <> '''') then raise exception.create('Bad aSqlStr.');

  result := SqlToStr(Copy(aSqlStr, 2, tmpLength-2));
end;

{function glSQLToStr(const aString:AnsiString):AnsiString;
  var iI : Integer;
begin
  Result:='';
  For iI:=1 to Length(aString) do begin
    if (aString[iI]='''')and(iI>1) Then
      if aString[iI-1]='''' then continue;
    Result:=Result+aString[iI];
  end;
end;}

function GetParamFromParamsStr(var aCurrentPos:integer; const aParamsStr:AnsiString; const aParamSeparator:char):AnsiString;
  var tmpPos:integer;
      tmpLength:integer;
begin
  tmpLength := Length(aParamsStr);
  if aCurrentPos < 1 then aCurrentPos:=1;
  if (tmpLength = 0) or (aCurrentPos > tmpLength) then begin
    aCurrentPos := -1;
    result := '';
    exit;
  end;

  tmpPos := aCurrentPos;
  while true do begin
    if tmpPos > tmpLength then begin
      result := copy(aParamsStr, aCurrentPos, tmpLength - aCurrentPos + 1);
      aCurrentPos := tmpPos;
      break;
    end;

    if aParamsStr[tmpPos] = '''' then begin
      SkipString(tmpPos, aParamsStr);
      continue;
    end;

    if aParamsStr[tmpPos] = aParamSeparator then begin
      result := copy(aParamsStr, aCurrentPos, tmpPos - aCurrentPos);
      aCurrentPos := tmpPos + 1;
      break;
    end;
    inc(tmpPos);
  end;
end;

function CheckIncludeParamStrInParamsStr(const aParamsStr:AnsiString; const aParamStr:AnsiString; const aParamSeparator:char):Boolean;
  var tmpCurrentPos:integer;
      tmpSt:AnsiString;
begin
  result:=False;
  tmpCurrentPos:=-1;
  while true do begin
    tmpSt:=GetParamFromParamsStr(tmpCurrentPos, aParamsStr, aParamSeparator);
    if tmpCurrentPos=-1 then Break;
    if tmpSt=aParamStr then begin
      result:=True;
      Break;
    end;
  end;
end;

function CheckIncludeParamsStrInParamsStr(const aParamsStrSource:AnsiString; const aParamsStrCheck:AnsiString; const aParamSeparator:char):Boolean;
begin
  result:=GetDifferentParamsStrFromParamsStr(aParamsStrSource, aParamsStrCheck, aParamSeparator)='';
end;

function GetDifferentParamsStrFromParamsStr(const aParamsStrSource:AnsiString; const aParamsStrDiff:AnsiString; const aParamSeparator:char):AnsiString;
  var tmpCurrPosSource, tmpCurrPosDiff:integer;
      tmpStrSource, tmpStrDiff:AnsiString;
      tmpFound:boolean;
begin
  result:='';
  tmpCurrPosDiff:=-1;
  while true do begin
    tmpStrDiff:=GetParamFromParamsStr(tmpCurrPosDiff, aParamsStrDiff, aParamSeparator);
    if tmpCurrPosDiff=-1 then Break;
    tmpFound:=False;
    tmpCurrPosSource:=-1;
    while true do begin
      tmpStrSource:=GetParamFromParamsStr(tmpCurrPosSource, aParamsStrSource, aParamSeparator);
      if tmpCurrPosSource=-1 then Break;
      if tmpStrSource=tmpStrDiff then begin
        tmpFound:=True;
        Break;
      end;
    end;
    if not tmpFound then begin
      result:=result + tmpStrDiff + aParamSeparator;
    end;
  end;
end;

function CompareParamsStr(const aParamsStr1:AnsiString; const aParamsStr2:AnsiString; const aParamSeparator:char):boolean;
begin
  result:=(GetDifferentParamsStrFromParamsStr(aParamsStr1, aParamsStr2, aParamSeparator)='')And(GetDifferentParamsStrFromParamsStr(aParamsStr2, aParamsStr1, aParamSeparator)='');
end;

end.
