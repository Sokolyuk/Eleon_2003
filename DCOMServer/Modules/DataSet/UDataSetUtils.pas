//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UDataSetUtils;

interface
  uses Db;

  //function dsIsValidField(const aFields, aField:AnsiString):boolean;
  function dsIsValidWhere(const aSourceFields:TFields; const aWhere:AnsiString):boolean;

  function dsExists(const aDataSet:TDataSet; const aWhere:AnsiString):boolean;
  function dsExistsNext(const aDataSet:TDataSet; const aWhere:AnsiString):boolean;
  function dsSelectCount(const aDataSet:TDataSet; const aWhere:AnsiString):integer;
  function dsSelect(const aDataSetDest:TDataSet; const aDataSetSource:TDataSet; const aFields:AnsiString; const aWhere:AnsiString; aInitDest:boolean):integer;
  function dsUpdate(const aDataSet:TDataSet; const aFields:AnsiString; const aWhere:AnsiString):integer;

implementation
  uses {$ifndef ver130}variants,{$endif}Sysutils, USolveStatement, USolveStatementTypes, UStringConsts, UStringUtils, UTypeUtils;

resourcestring
  cnValueNotAssigned = '''%s'' not assigned.';
  cnInvalidTypeOfStatement = 'Invalid type(''%s'') of statement ''%s''.';
  cnInvalidValueOf = 'Invalid value(''%s'') of ''%s''.';

function InternalOnPropertyRegular(aUserDataRegular:pointer; const aName:AnsiString):variant;
begin
  if not assigned(aUserDataRegular) then raise exception.createfmt(cnValueNotAssigned, ['aUserDataRegular']);
  result := TFields(aUserDataRegular).FieldByName(aName).AsVariant;
end;

function dsIsValidWhere(const aSourceFields:TFields; const aWhere:AnsiString):boolean;
  var tmpV:variant;
      tmpPos:integer;
      tmpOnGetValue:TOnGetValue;
begin
  if not assigned(aSourceFields) then raise exception.createfmt(cnValueNotAssigned, [aSourceFields]);

  tmpOnGetValue.aOnProperty := nil;
  tmpOnGetValue.aOnFunction := nil;
  tmpOnGetValue.aOnFunctionRegular := nil;
  tmpOnGetValue.aUserDataRegular := pointer(aSourceFields);
  tmpOnGetValue.aOnPropertyRegular := InternalOnPropertyRegular;

  tmpPos := 1;
  tmpV := SolveStatement(tmpPos, aWhere, tmpOnGetValue);
  if VarIsEmpty(tmpV) then tmpV := true;
  if VarType(tmpV) <> varBoolean then raise exception.createfmt(cnInvalidTypeOfStatement, ['not Boolean', aWhere]);
  result := tmpV;
end;

{function dsIsValidField(const aFields, aField:AnsiString):boolean;
begin
  result := CheckIncludeParamStrInParamsStr(aFields, aField, ',');
end;}

function dsSelect(const aDataSetDest:TDataSet; const aDataSetSource:TDataSet; const aFields:AnsiString; const aWhere:AnsiString; aInitDest:boolean):integer;
  var tmpFieldName:AnsiString;
      tmpPos:integer;
      tmpField:TField;
begin
  try
    if not assigned(aDataSetDest) then raise exception.createfmt(cnValueNotAssigned, ['aDataSetDest']);
    if not assigned(aDataSetSource) then raise exception.createfmt(cnValueNotAssigned, ['aDataSetSource']);
    if aFields = '' then raise exception.createfmt(cnInvalidValueOf, [aFields, 'aFields']);
    if not aDataSetSource.active then raise exception.createfmt(cnInvalidValueOf, ['no active', 'aDataSetSource']);
    result := 0;

    if aInitDest then begin
      //закрываю Dest
      if aDataSetDest.active then aDataSetDest.close;
      aDataSetDest.FieldDefs.Clear;

      //создаю в Dest поля
      tmpPos := -1;
      while true do begin
        tmpFieldName := GetParamFromParamsStr(tmpPos, aFields, ',');
        if tmpPos = -1 then break;
        tmpField := aDataSetSource.FieldByName(tmpFieldName);
        aDataSetDest.FieldDefs.Add(tmpFieldName, tmpField.DataType, tmpField.Size, tmpField.Required);
      end;

      //Теперь открываю Dest
      aDataSetDest.open;
    end else begin
      if not aDataSetDest.active then raise exception.createfmt(cnInvalidValueOf, ['no active', 'aDataSetDest']);
    end;

    aDataSetSource.First;
    while not aDataSetSource.Eof do begin
      if dsIsValidWhere(aDataSetSource.Fields, aWhere) then begin
        aDataSetDest.append;
        aDataSetDest.edit;
        //копирую
        tmpPos := -1;
        while true do begin
          tmpFieldName := GetParamFromParamsStr(tmpPos, aFields, ',');
          if tmpPos = -1 then break;
          tmpField := aDataSetSource.FieldByName(tmpFieldName);
          aDataSetDest.FieldByName(tmpFieldName).Assign(tmpField);
        end;
        aDataSetDest.post;
        inc(result);
      end;
      aDataSetSource.Next;
    end;
  except on e:exception do begin
    if aInitDest then begin try aDataSetDest.active := false; except end;end;
    e.message := 'dsSelect: ' + e.message;
    raise;
  end;end;
end;

{$ifdef ver130}
function StrToBool(const aStr:AnsiString):boolean;
begin
  if AnsiUpperCase(aStr) = 'TRUE' then result := true
  else if AnsiUpperCase(aStr) = 'FALSE' then result := false else raise exception.create('Invalid boolean string ''' + aStr + '''.');
end;
{$endif}

function dsUpdate(const aDataSet:TDataSet; const aFields:AnsiString; const aWhere:AnsiString):integer;
  var tmpField:AnsiString;
      tmpFieldName:AnsiString;
      tmpFieldValue:AnsiString;
      tmpPos, tmpSubPos:integer;
begin
  try
    if not assigned(aDataSet) then raise exception.createfmt(cnValueNotAssigned, ['aDataSet']);
    if aFields = '' then raise exception.createfmt(cnInvalidValueOf, [aFields, 'aFields']);
    if not aDataSet.active then raise exception.createfmt(cnInvalidValueOf, ['no active', 'aDataSet']);
    result := 0;

    aDataSet.First;
    while not aDataSet.Eof do begin
      if dsIsValidWhere(aDataSet.Fields, aWhere) then begin
        aDataSet.edit;
        //копирую
        tmpPos := -1;
        while true do begin
          tmpField := GetParamFromParamsStr(tmpPos, aFields, ',');
          if tmpPos = -1 then break;

          tmpSubPos := -1;
          tmpFieldName := trim(GetParamFromParamsStr(tmpSubPos, tmpField, '='));
          if (tmpSubPos = -1) or (tmpFieldName = '') then raise exception.createfmt(cnInvalidStatement, [tmpField]);

          tmpFieldValue := trim(GetParamFromParamsStr(tmpSubPos, tmpField, '='));
          if (tmpSubPos = -1) or (tmpFieldValue = '') or (GetParamFromParamsStr(tmpSubPos, tmpField, '=') <> '') or (tmpSubPos <> -1) then raise exception.createfmt(cnInvalidStatement, [tmpField]);

          case GetOperandType(tmpFieldValue) of
            optInteger:begin
              aDataSet.FieldByName(tmpFieldName).AsInteger := StrToInt(tmpFieldValue);
            end;
            optFloat:begin
              aDataSet.FieldByName(tmpFieldName).AsFloat := StrToFloatAlternative(tmpFieldValue);
            end;
            optString:begin
              aDataSet.FieldByName(tmpFieldName).AsString := SqlStrToStr(tmpFieldValue);
            end;
            optBool:begin
              aDataSet.FieldByName(tmpFieldName).AsBoolean := StrToBool(tmpFieldValue);
            end;
            optNull:begin
              aDataSet.FieldByName(tmpFieldName).Clear;
            end;
          else
            raise exception.createfmt(cnInvalidTypeCastForStatement, [tmpFieldValue]);
          end;  
        end;
        aDataSet.post;
        inc(result);
      end;
      aDataSet.Next;
    end;
  except on e:exception do begin
    e.message := 'dsSelect: ' + e.message;
    raise;
  end;end;
end;

function dsExistsNext(const aDataSet:TDataSet; const aWhere:AnsiString):boolean;
begin
  try
    if not assigned(aDataSet) then raise exception.createfmt(cnValueNotAssigned, ['aDataSet']);
    if not aDataSet.active then raise exception.createfmt(cnInvalidValueOf, ['no active', 'aDataSet']);

    result := false;

    while not aDataSet.Eof do begin
      if dsIsValidWhere(aDataSet.Fields, aWhere) then begin
        result := true;
        break;
      end;
      aDataSet.Next;
    end;
  except on e:exception do begin
    e.message := 'dsNextExists: ' + e.message;
    raise;
  end;end;
end;

function dsExists(const aDataSet:TDataSet; const aWhere:AnsiString):boolean;
begin
  try
    if not assigned(aDataSet) then raise exception.createfmt(cnValueNotAssigned, ['aDataSet']);
    if not aDataSet.active then raise exception.createfmt(cnInvalidValueOf, ['no active', 'aDataSet']);

    result := false;
    aDataSet.First;
    while not aDataSet.Eof do begin
      if dsIsValidWhere(aDataSet.Fields, aWhere) then begin
        result := true;
        break;
      end;
      aDataSet.Next;
    end;
  except on e:exception do begin
    e.message := 'dsExists: ' + e.message;
    raise;
  end;end;
end;

function dsSelectCount(const aDataSet:TDataSet; const aWhere:AnsiString):integer;
begin
  try
    if not assigned(aDataSet) then raise exception.createfmt(cnValueNotAssigned, ['aDataSet']);
    if not aDataSet.active then raise exception.createfmt(cnInvalidValueOf, ['no active', 'aDataSet']);

    result := 0;
    aDataSet.First;
    while not aDataSet.Eof do begin
      if dsIsValidWhere(aDataSet.Fields, aWhere) then begin
        inc(result);
      end;
      aDataSet.Next;
    end;
  except on e:exception do begin
    e.message := 'dsSelectCount: ' + e.message;
    raise;
  end;end;
end;

end.
