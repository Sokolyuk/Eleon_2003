unit UDatasetToChecksumUtils;

interface
  uses DB, SysUtils;

  function FieldsToInt(const aFld: TFields): Integer;
  function DatasetToChecksum(const aDataset: TDataset): Integer;

implementation

type
   T8DataToInt=record
    case word of
      0: (aInteger1, aInteger2:Integer);
      1: (aChar: array[1..4] of Char);
      2: (aDateTime: TDateTime);
      3: (aFloat: Double);
      4: (aCurrency: Currency);
  end;

function FieldsToInt(const aFld: TFields):Integer;
  var tmpI, tmpFieldNum: Integer;
      tmpT8DateToInt: T8DataToInt;
      tmpPos, tmpLen: Integer;
      s: String;
begin
  result := 0;
  for tmpFieldNum := 0 to aFld.Count-1 do begin
    if aFld.Fields[tmpFieldNum].IsNull then begin
      result:= result xor 0;
      continue;
    end;
    with aFld.Fields[tmpFieldNum] do
      case DataType of
        ftInteger,
        ftBytes,
        ftLargeint,
        ftSmallint,
        ftWord :   begin
                     result:= result xor AsInteger;
                   end;
        ftGuid,
        ftString : begin
                     s := AsString;
                     tmpLen := Length(s);
                     tmpPos := 1;

                     while tmpPos <= tmpLen do begin//условие, чтобы после внутреннего цикла вышел и из внешнего

                       tmpT8DateToInt.aInteger1 := 0;
                       for tmpI := 1 to 4 do begin
                         if tmpPos + tmpI - 1 > tmpLen then break;//проверяю на конец строки
                         tmpT8DateToInt.aChar[tmpI] := s[tmpPos + tmpI - 1];
                       end;
                       result := Result xor tmpT8DateToInt.aInteger1;//рачитываю контрл. сумму

                       tmpPos := tmpPos + tmpI - 1;//увеличиваю позицию
                     end;

                   end;
        ftBoolean: begin
                     result:= result xor Ord(AsBoolean);
                   end;
        ftDateTime: begin
                      tmpT8DateToInt.aDateTime:= AsDateTime;
                      result:= result xor tmpT8DateToInt.aInteger1 xor tmpT8DateToInt.aInteger2;
                    end;
        ftFloat:   begin
                     tmpT8DateToInt.aFloat:= AsFloat;
                     result:= result xor tmpT8DateToInt.aInteger1 xor tmpT8DateToInt.aInteger2;
                   end;
	      ftCurrency,
        ftBCD:  begin
                    tmpT8DateToInt.aCurrency:= AsCurrency;
                    Result:= result xor tmpT8DateToInt.aInteger1 xor tmpT8DateToInt.aInteger2;
                 end;
      else raise Exception.Create('Неизвестный тип поля(DataType='+IntToStr(integer(aFld.Fields[tmpFieldNum].DataType))+'.');
    end;
  end;
end;

function DatasetToChecksum(const aDataset:TDataset):integer;
  var tmpRecNo: integer;
begin
  result:= 0;
  if aDataset.Active then begin
     tmpRecNo:= aDataset.RecNo;
     try
       aDataset.First;
       while not aDataset.Eof do begin
         result:= result xor FieldsToInt(aDataset.Fields);
         aDataset.Next;
       end;
     finally
       aDataset.RecNo:= tmpRecNo;
     end;
  end;
end;

end.
