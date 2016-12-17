{$Define Debug}
unit URecVar;

interface

Const
{ RecVariant type codes }
  rvEmpty    = $0000; { vt_empty       }
  rvNull     = $0001; { vt_null        }
  rvSmallint = $0002; { vt_i2          }
  rvInteger  = $0003; { vt_i4          }
  rvSingle   = $0004; { vt_r4          }
  rvDouble   = $0005; { vt_r8          }
  rvCurrency = $0006; { vt_cy          }
  rvDate     = $0007; { vt_date        }
  rvOleStr   = $0008; { vt_bstr        }
//rvDispatch = $0009; { vt_dispatch    } {UNSUPPORTED - SDA}
//rvError    = $000A; { vt_error       } {UNSUPPORTED - SDA}
  rvBoolean  = $000B; { vt_bool        }
  rvVariant  = $000C; { vt_variant     }
//rvUnknown  = $000D; { vt_unknown     } {UNSUPPORTED - SDA}
//rvDecimal  = $000E; { vt_decimal     } {UNSUPPORTED}
                       { undefined  $0f } {UNSUPPORTED}
  rvShortInt = $0010; { vt_i1          }
  rvByte     = $0011; { vt_ui1         }
  rvWord     = $0012; { vt_ui2         }
  rvLongWord = $0013; { vt_ui4         }
  rvInt64    = $0014; { vt_i8          }
//rvWord64   = $0015; { vt_ui8         } {UNSUPPORTED}

  { if adding new items, update Variants' varLast, BaseTypeMap and OpTypeMap }
//rvStrArg   = $0048; { vt_clsid    }    {UNSUPPORTED - SDA}
  rvString   = $0100; { Pascal string; not OLE compatible }
//rvAny      = $0101; { Corba any }      {UNSUPPORTED - SDA}
  rvTypeMask = $0FFF;
  rvArray    = $2000;
//rvByRef    = $4000;                    {UNSUPPORTED - SDA}
  reRecVarisNotArray:ansiString ='RecVar не массив.';
  reTypeMishmash:ansiString='Несоответствие типов.';
Type
{$IfDef Debug}
  PMemArrayByte = ^TMemarrayByte;
  TMemarrayByte = array[0..$ffff] of byte;
  PMemArrayChar = ^TMemarrayChar;
  TMemarrayChar = array[0..$ffff] of Char;
{$Endif}

  TRecVarArrayBound = packed record
    ElementCount: Integer;
    LowBound: Integer;
  end;

  PRecVarArray = ^TRecVarArray;
  TRecVarArray = packed record
    DimCount: Word;            { структура не проверятся в RecVarArrayCreate }
    Flags: Word;               {  }
    ElementSize: Integer;      {  }
    LockCount: Integer;        {  }
    Data: Pointer;             {  }
    Bounds: array[0..255] of TRecVarArrayBound;
  end;

  TRecVarType = Word;
  PRecVarData = ^TRecVarData;
  TRecVarData = packed record
    VType: TRecVarType;
    case Integer of
      0: (Reserved1: Word;
          case Integer of
            0: (Reserved2, Reserved3: Word;
                case Integer of
                  rvSmallInt:   (VSmallInt: SmallInt);
                  rvInteger:    (VInteger: Integer);
                  rvSingle:     (VSingle: Single);
                  rvDouble:     (VDouble: Double);
                  rvCurrency:   (VCurrency: Currency);
                  rvDate:       (VDate: TDateTime);
                  rvOleStr:     (VOleStr: PWideChar{WideString});
                  rvBoolean:    (VBoolean: WordBool);
                  rvShortInt:   (VShortInt: ShortInt);
                  rvByte:       (VByte: Byte);
                  rvWord:       (VWord: Word);
                  rvLongWord:   (VLongWord: LongWord);
                  rvInt64:      (VInt64: Int64);
                  rvArray:      (VArray: PRecVarArray);
                  rvString:     (VString:Pointer{AnsiString});
                  rvVariant:    (VVariant:PRecVarData);
               );
            1: (VLongs: array[0..2] of LongInt);
         );
      2: (VWords: array [0..6] of Word);
      3: (VBytes: array [0..13] of Byte);
  end;

  //TRecVar = TRecVarData;
Const
  rvrUnassigned:TRecVarData=(VType:rvEmpty; Reserved1:0; Reserved2:0; Reserved3:0);
  rvrNull      :TRecVarData=(VType:rvNull; Reserved1:0; Reserved2:0; Reserved3:0);


Type
  TRecVarManage = class(TObject)
  private
  public
    constructor Create;
    destructor Destroy; override;
    // ..
  end;

  TRecVarArrayToStr = Class(TObject)
  Private
    FStr:Ansistring;
    FShowNum:Boolean;
    FShortType:Boolean;
    Function  _RecVarArrayToStr(aRecVar:TRecVarData):AnsiString;
  Public
    constructor Create;
    Function  RecVarArrayToStr(aRecVar:TRecVarData):AnsiString;
    Property  Str:Ansistring read FStr;
    Property  ShowNum:Boolean read FShowNum write FShowNum;
    Property  ShortType:Boolean read FShortType write FShortType;
  end;


    function RecVarArrayCreate(const Bounds: array of Integer; RecVarType: Integer): TRecVarData;
    function RecVarArrayOf(const Values: array of Variant): TRecVarData;
    procedure RecVarClear(Var aRecVar:TRecVarData);
    procedure RecVarCopy(var Dest : TRecVarData; const Source: TRecVarData);    
    // ..
    function RecVarIsArray(const A: TRecVarData): Boolean;
    function RecVarType(const V: TRecVarData): Integer;
    function RecVarArrayLowBound(const A: TRecVarData; Dim: Integer): Integer;
    function RecVarArrayHighBound(const A: TRecVarData; Dim: Integer): Integer;
    // ..
    procedure RecVarArrayRedim(var A : TRecVarData; HighBound: Integer);
    function  RecVarArrayGet(var A: TRecVarData; IndexCount: Integer; Indices: Integer): TRecVarData;
    procedure RecVarArrayPut(var A: TRecVarData; const Value: TRecVarData; IndexCount: Integer; Indices: Integer);
    // Convert to RecVar
    Function  SmallintToRecVar(aValue:Smallint):TRecVarData;
    Function  IntegerToRecVar(aValue:Integer):TRecVarData;
    Function  SingleToRecVar(aValue:Single):TRecVarData;
    Function  DoubleToRecVar(aValue:Double):TRecVarData;
    Function  CurrencyToRecVar(aValue:Currency):TRecVarData;
    Function  DateTimeToRecVar(aValue:TDateTime):TRecVarData;
    Function  WideStringToRecVar(aValue:WideString):TRecVarData;
    Function  BooleanToRecVar(aValue:Boolean):TRecVarData;
    Function  ShortIntToRecVar(aValue:ShortInt):TRecVarData;
    Function  ByteToRecVar(aValue:Byte):TRecVarData;
    Function  WordToRecVar(aValue:Word):TRecVarData;
    Function  LongWordToRecVar(aValue:LongWord):TRecVarData;
    Function  Int64ToRecVar(aValue:Int64):TRecVarData;
    Function  AnsiStringToRecVar(aValue:AnsiString):TRecVarData;
    Function  VariantToRecVar(aValue:Variant):TRecVarData;
    Function  BlobToRecVar(aValue:Variant):TRecVarData;
    // Convert from RecVar
    Function  RecVarToSmallint(aValue:TRecVarData):Smallint;
    Function  RecVarToInteger(aValue:TRecVarData):Integer;
    Function  RecVarToSingle(aValue:TRecVarData):Single;
    Function  RecVarToDouble(aValue:TRecVarData):Double;
    Function  RecVarToCurrency(aValue:TRecVarData):Currency;
    Function  RecVarToDateTime(aValue:TRecVarData):TDateTime;
    Function  RecVarToWideString(aValue:TRecVarData):WideString;
    Function  RecVarToBoolean(aValue:TRecVarData):Boolean;
    Function  RecVarToShortInt(aValue:TRecVarData):ShortInt;
    Function  RecVarToByte(aValue:TRecVarData):Byte;
    Function  RecVarToWord(aValue:TRecVarData):Word;
    Function  RecVarToLongWord(aValue:TRecVarData):LongWord;
    Function  RecVarToInt64(aValue:TRecVarData):Int64;
    Function  RecVarToAnsiString(aValue:TRecVarData):AnsiString;
    Function  RecVarToVariant(aValue:TRecVarData):Variant;
    Function  RecVarToBlob(aValue:TRecVarData):Variant;

implementation
  Uses Sysutils;

constructor TRecvarManage.Create;
begin
  Inherited Create;
end;

destructor  TRecvarManage.Destroy;
begin
  Inherited Destroy;
end;

constructor TRecVarArrayToStr.Create;
begin
  FStr:='';
  FShowNum:=false{true};
  FShortType:=true;
  Inherited Create;
end;

Function  TRecVarArrayToStr._RecVarArrayToStr(aRecVar:TRecVarData):AnsiString;
  Var st : AnsiString;
      iJ : Integer;
begin
  If RecVarIsArray(aRecVar) Then begin
    // VarArray
    st:='(';
    For iJ:=RecVarArrayLowBound(aRecVar,1) to RecVarArrayHighBound(aRecVar,1) do begin
      If FShowNum then begin
        st:=st+{'#'+}IntToStr(iJ)+':'+_RecVarArrayToStr(RecVarArrayGet(aRecVar, 1, iJ));
      end else begin
        st:=st+_RecVarArrayToStr(RecVarArrayGet(aRecVar, 1, iJ));
      end;
      If iJ>=RecVarArrayHighBound(aRecVar,1) Then
        st:=st+')'
      else
        st:=st+',';
    end;
  End else begin
    // simple Variant
    if FShortType then begin
      Case RecVarType(aRecVar) of
        rvEmpty    : st:='Emp';
        rvNull     : st:='Nul';
        rvSmallint : st:='SmI:'+IntToStr(aRecVar.VSmallInt);
        rvInteger  : st:='Int:' +IntToStr(aRecVar.VInteger);
        rvSingle   : st:='Sng:'+FloatToStr(aRecVar.VSingle);
        rvDouble   : st:='Dbl:' +FloatToStr(aRecVar.VDouble);
        rvCurrency : st:='Cur:' +FloatToStr(aRecVar.VCurrency);
        rvDate     : st:='Dat:'+DateTimeToStr(aRecVar.VDate);
        rvOleStr   : st:='OSt:''???''';
        rvBoolean  : begin If aRecVar.VBoolean Then st:='Bln:True' else st:='Bln:False'; end;
        rvShortInt : st:='ShI:' +IntToStr(aRecVar.VShortInt);
        rvByte     : st:='Byt:'+IntToStr(aRecVar.VByte);
        rvWord     : st:='Wrd:' +IntToStr(aRecVar.VWord);
        rvLongWord : st:='LWr:'+IntToStr(aRecVar.VLongWord);
        rvInt64    : st:='I64:' +IntToStr(aRecVar.VInt64);
        rvString   : st:='Str:''???''';
      else
        st:='???:''???''';
      end;
    end else begin
      Case RecVarType(aRecVar) of
        rvEmpty    : st:='Empty';
        rvNull     : st:='Null';
        rvSmallint : st:='Smallint:'+IntToStr(aRecVar.VSmallInt);
        rvInteger  : st:='Integer:' +IntToStr(aRecVar.VInteger);
        rvSingle   : st:='Single:'+FloatToStr(aRecVar.VSingle);
        rvDouble   : st:='Double:' +FloatToStr(aRecVar.VDouble);
        rvCurrency : st:='Currency:' +FloatToStr(aRecVar.VCurrency);
        rvDate     : st:='Date:'+DateTimeToStr(aRecVar.VDate);
        rvOleStr   : st:='OleStr:''???''';
        rvBoolean  : begin If aRecVar.VBoolean Then st:='Boolean:True' else st:='Boolean:False'; end;
        rvShortInt : st:='ShortInt:' +IntToStr(aRecVar.VShortInt);
        rvByte     : st:='Byte:'+IntToStr(aRecVar.VByte);
        rvWord     : st:='Word:' +IntToStr(aRecVar.VWord);
        rvLongWord : st:='LongWord:'+IntToStr(aRecVar.VLongWord);
        rvInt64    : st:='Int64:' +IntToStr(aRecVar.VInt64);
        rvString   : st:='String:''???''';
      else
        st:='???:''???''';
      end;
    end;
  end;
  Result:=st;
end;

Function  TRecVarArrayToStr.RecVarArrayToStr(aRecVar:TRecVarData):AnsiString;
begin
  FStr:=_RecVarArrayToStr(aRecVar);
  Result:=FStr;
end;

// ..
function RecVarArrayCreate(const Bounds: array of Integer; RecVarType: Integer): TRecVarData;
var
  iDimCount, iElementSize, iElementCount: Integer;
  tmpPRecVarArray:PRecVarArray;
  tmpPointer:Pointer;
begin
  if High(Bounds)<>1 then Raise Exception.Create('RecVar не поддерживает  многоразмерные массивы.');
  If Bounds[0]>Bounds[1] then Raise Exception.Create('Не правильная размерность Bounds.');
  Result:=rvrUnassigned;
  iDimCount:=1;
  iElementCount:=Bounds[1]-Bounds[0]+1;
  Case RecVarType of
    rvSmallint{0002h}:begin
      iElementSize:=SizeOf(Smallint);
    end;
    rvInteger{0003h}:begin
      iElementSize:=SizeOf(Integer);
    end;
    rvSingle{0004h}:begin
      iElementSize:=SizeOf(Single);
    end;
    rvDouble{0005h}:begin
      iElementSize:=SizeOf(Double);
    end;
    rvCurrency{0006h}:begin
      iElementSize:=SizeOf(Currency);
    end;
    rvDate{0007h}:begin
      iElementSize:=SizeOf(TDateTime);
    end;
    rvOleStr{0008h}:begin
      iElementSize:=SizeOf(PWideChar{WideString});
    end;
    rvBoolean{000Bh}:begin
      iElementSize:=SizeOf(WordBool);
    end;
    rvVariant{000Ch}:begin
      iElementSize:=SizeOf(TRecVarData);
    end;
    rvShortInt{0010h}:begin
      iElementSize:=SizeOf(ShortInt);
    end;
    rvByte{0011h}:begin
      iElementSize:=SizeOf(Byte);
    end;
    rvWord{0012h}:begin
      iElementSize:=SizeOf(Word);
    end;
    rvLongWord{0013h}:begin
      iElementSize:=SizeOf(LongWord);
    end;
    rvInt64{0014h}:begin
      iElementSize:=SizeOf(Int64);
    end;
    rvString{0100h}:begin
      iElementSize:=SizeOf(Pointer{AnsiString});
    end;
  else
    Raise Exception.Create('RecVarType='+IntToStr(RecVarType)+' не поддерживается.');
  end;
  // ..
  //GetMem(tmpPRecVarArray, 16{TRecVarArray без Bounds}+SizeOf(TRecVarArrayBound)*iDimCount);
  tmpPRecVarArray:=AllocMem(16{TRecVarArray без Bounds}+SizeOf(TRecVarArrayBound)*iDimCount);
  try
    tmpPRecVarArray^.DimCount:=iDimCount;
    tmpPRecVarArray^.Flags:=0;
    tmpPRecVarArray^.LockCount:=0;
    tmpPRecVarArray^.Bounds[0].LowBound:=Bounds[0];
    tmpPRecVarArray^.Bounds[0].ElementCount:=iElementCount;
    tmpPRecVarArray^.ElementSize:=iElementSize;
    //GetMem(tmpPointer, iElementSize*iElementCount);
    tmpPointer:=AllocMem(iElementSize*iElementCount);
    try
      //FillChar(tmpPointer^, iElementSize*iElementCount, 0);
      tmpPRecVarArray^.Data:=tmpPointer;
      Result.VArray:=tmpPRecVarArray;
      Result.VType:=RecVarType or rvArray;
    except
      FreeMem(tmpPointer);
      Raise;
    end;
  except
    FreeMem(tmpPRecVarArray);
    raise;
  end;
end;

function RecVarArrayOf(const Values: array of Variant): TRecVarData;
begin
  //1
end;

procedure RecVarClear(Var aRecVar:TRecVarData);
  var tmpPRecVarData:PRecVarData;
      tmpPRecVarArray:PRecVarArray;
      tmpPointer:Pointer;
      iI:Integer;
begin
  If RecVarIsArray(aRecVar){(aRecVar.VType and rvArray)=rvArray} then begin
    // RecVar is array
    If aRecVar.VArray^.DimCount<>1 Then Raise Exception.Create('Не умею разбарать многомерный RecVar.');
    case aRecVar.VType and rvTypeMask{0FFFh} of
      rvSmallint{0002h}, rvInteger{0003h}, rvSingle{0004h}, rvDouble{0005h}, rvCurrency{0006h}, rvDate{0007h}, rvBoolean{000Bh},
      rvShortInt{0010h}, rvByte{0011h}, rvWord{0012h}, rvLongWord{0013h}, rvInt64{0014h}:begin
        tmpPRecVarArray:=aRecVar.VArray;
        try
          tmpPointer:=tmpPRecVarArray^.Data;
          try
            {ничего}
          finally
            FreeMem(tmpPointer);
          end;
        finally
          FreeMem(tmpPRecVarArray);
        end;
      end;
      rvVariant{000Ch}:begin
        tmpPRecVarArray:=aRecVar.VArray;
        try
          tmpPointer:=tmpPRecVarArray^.Data;
          try
            For iI:=0 to tmpPRecVarArray^.Bounds[0].ElementCount-1 do begin
              tmpPRecVarData:=Pointer(PChar(tmpPointer)+iI*tmpPRecVarArray^.ElementSize);
              RecVarClear(tmpPRecVarData^);
            end;
          finally
            FreeMem(tmpPointer);
          end;
        finally
          FreeMem(tmpPRecVarArray);
        end;
      end;
      rvString{0100h}, rvOleStr{0008h}:begin
        Raise Exception.Create('Пока не сделал.');
      end;
      rvEmpty{0000h}, rvNull{0001h}:begin
        Raise Exception.Create('Недопустимое значение aRecVar.VType='+IntToStr(aRecVar.VType)+'.');
      end;
    else
      Raise Exception.Create('Неизвестный тип RecVar.VType='+IntToStr(aRecVar.VType));
    end;
  end else begin
    // RecVar is variable
    case aRecVar.VType of
      rvEmpty{0000h}, rvNull{0001h}, rvSmallint{0002h}, rvInteger{0003h}, rvSingle{0004h}, rvDouble{0005h},
      rvCurrency{0006h}, rvDate{0007h}, rvBoolean{000Bh}, rvShortInt{0010h}, rvByte{0011h}, rvWord{0012h},
      rvLongWord{0013h}, rvInt64{0014h}:begin
        {ничего не разбираю т.к. нет подстуктур}
        {а входной параметр разбирет вызвавший процедуру.}
      end;
      rvVariant{000Ch}:begin
        tmpPRecVarData:=aRecVar.VVariant;
        try
          RecVarClear(tmpPRecVarData^);
        finally
          FreeMem(tmpPRecVarData);
        end;
      end;
      rvOleStr{0008h}, rvString{0100h}: begin
        Raise Exception.Create('Пока не сделал.');
      end;
    else
      Raise Exception.Create('Неизвестный тип RecVar.VType='+IntToStr(aRecVar.VType));
    end;
  end;
  aRecVar:=rvrUnassigned;
end;

procedure RecVarCopy(var Dest : TRecVarData; const Source: TRecVarData);
  var tmpPRecVarData, tmpPRecVarDataDest, tmpPRecVarDataSource:PRecVarData;
      tmpPRecVarArray:PRecVarArray;
      tmpPointer:Pointer;
      iI, iDimCount, iTRecVarArraySizeOf, iRecVarArrayDataSizeOf:Integer;
begin                       {!!!}
  RecVarClear(Dest);
  If RecVarIsArray(Source){(Source.VType and rvArray)=rvArray} then begin
    // Source is array
    iDimCount:=Source.VArray^.DimCount;
    If iDimCount<>1 Then Raise Exception.Create('Не умею копировать многомерный RecVar.');
    case Source.VType and rvTypeMask{0FFFh} of
      rvSmallint{0002h}, rvInteger{0003h}, rvSingle{0004h}, rvDouble{0005h}, rvCurrency{0006h}, rvDate{0007h}, rvBoolean{000Bh},
      rvShortInt{0010h}, rvByte{0011h}, rvWord{0012h}, rvLongWord{0013h}, rvInt64{0014h}:begin
        If Source.VArray<>Nil then begin
          // усди существует RecVarArray
          iTRecVarArraySizeOf:=16{TRecVarArray без Bounds}+SizeOf(TRecVarArrayBound)*iDimCount;
          GetMem(tmpPRecVarArray, iTRecVarArraySizeOf);
          try
            Move(Source.VArray^, tmpPRecVarArray^, iTRecVarArraySizeOf);
            tmpPRecVarArray^.Data:=Nil;
            If Source.VArray^.Data<>Nil then begin
              // если существует RecVarArrayData.
              iRecVarArrayDataSizeOf:=Source.VArray^.ElementSize*Source.VArray^.Bounds[0].ElementCount;
              GetMem(tmpPointer, iRecVarArrayDataSizeOf);
              try
                Move(Source.VArray^.Data^, tmpPointer^, iRecVarArrayDataSizeOf);
                tmpPRecVarArray^.Data:=tmpPointer;
                Dest.VArray:=tmpPRecVarArray;
              except
                try tmpPRecVarArray^.Data:=Nil; except end;
                FreeMem(tmpPointer);
                raise;
              end;
            end;
          except
            try Dest.VArray:=Nil; except end;
            FreeMem(tmpPRecVarArray);
            raise;
          end;
        end;
      end;
      rvVariant{000Ch}:begin
        If Source.VArray<>Nil then begin
          // усди существует RecVarArray
          iTRecVarArraySizeOf:=16{TRecVarArray без Bounds}+SizeOf(TRecVarArrayBound)*iDimCount;
          GetMem(tmpPRecVarArray, iTRecVarArraySizeOf);
          try
            Move(Source.VArray^, tmpPRecVarArray^, iTRecVarArraySizeOf);
            tmpPRecVarArray^.Data:=Nil;
            If Source.VArray^.Data<>Nil then begin
              // если существует RecVarArrayData.
              iRecVarArrayDataSizeOf:=Source.VArray^.ElementSize*Source.VArray^.Bounds[0].ElementCount;
              //GetMem(tmpPointer, iRecVarArrayDataSizeOf);
              tmpPointer:=AllocMem(iRecVarArrayDataSizeOf);
              try
                //FillChar(tmpPointer^, iRecVarArrayDataSizeOf, 0);
                For iI:=0 to Source.VArray^.Bounds[0].ElementCount-1 do begin
                  tmpPRecVarDataDest:=Pointer(PChar(tmpPointer)+iI*Source.VArray^.ElementSize);
                  tmpPRecVarDataSource:=Pointer(PChar(Source.VArray^.Data)+iI*Source.VArray^.ElementSize);
                  RecVarCopy(tmpPRecVarDataDest^, tmpPRecVarDataSource^);
                end;
                tmpPRecVarArray^.Data:=tmpPointer;
                Dest.VArray:=tmpPRecVarArray;
              except
                try tmpPRecVarArray^.Data:=Nil; except end;
                FreeMem(tmpPointer);
                raise;
              end;
            end;
          except
            try Dest.VArray:=Nil; except end;
            FreeMem(tmpPRecVarArray);
            raise;
          end;
        end;
      end;
      rvString{0100h}, rvOleStr{0008h}:begin
        Raise Exception.Create('Пока не сделал.');
      end;
      rvEmpty{0000h}, rvNull{0001h}:begin
        Raise Exception.Create('Недопустимое значение Source.VType='+IntToStr(Source.VType)+'.');
      end;
    else
      Raise Exception.Create('Неизвестный тип Source.VType='+IntToStr(Source.VType));
    end;
    Dest.VType:=Source.VType;
  end else begin
    // Source is variable
    case Source.VType of
      rvEmpty{0000h}, rvNull{0001h}, rvSmallint{0002h}, rvInteger{0003h}, rvSingle{0004h}, rvDouble{0005h},
      rvCurrency{0006h}, rvDate{0007h}, rvBoolean{000Bh}, rvShortInt{0010h}, rvByte{0011h}, rvWord{0012h},
      rvLongWord{0013h}, rvInt64{0014h}:begin
        Dest.VBytes:=Source.VBytes;
      end;
      rvVariant{000Ch}:begin
        Dest.VVariant:=Nil;
        //GetMem(tmpPRecVarData, SizeOf(TRecVarData));
        tmpPRecVarData:=AllocMem(SizeOf(TRecVarData));
        try
          //FillChar(tmpPRecVarData^, SizeOf(TRecVarData), 0);
          RecVarCopy(tmpPRecVarData^, Source.VVariant^);
          Dest.VVariant:=tmpPRecVarData;
        except
          FreeMem(tmpPRecVarData);
          Raise;
        end;
      end;
      rvOleStr{0008h}, rvString{0100h}: begin
        Raise Exception.Create('Пока не сделал.');
      end;
    else
      Raise Exception.Create('Неизвестный тип Source.VType='+IntToStr(Source.VType));
    end;
    Dest.VType:=Source.VType;
  end;
end;

function RecVarIsArray(const A: TRecVarData): Boolean;
begin
  If (A.VType and rvArray)=rvArray Then
    If A.VArray<>Nil then begin
      If A.VArray^.Data<>Nil then begin
        Result:=True;
        Exit;
      end else Raise Exception.Create('Полу A.VArray^.Data не может быть Nil.');
    end else Raise Exception.Create('Полу A.VArray не может быть Nil.');
  Result:=false;
end;

function RecVarType(const V: TRecVarData): Integer;
begin
  Result:=V.VType;
end;
// ..
function RecVarArrayLowBound(const A: TRecVarData; Dim: Integer): Integer;
begin
  If Not RecVarIsArray(A) then Raise Exception.Create(reRecVarisNotArray);
  If (Dim<>1)Or(A.VArray^.DimCount<>1) then Raise Exception.Create('Не умею работать с многомерным RecVar.');
  Result:=A.VArray^.Bounds[0].LowBound;
end;

function RecVarArrayHighBound(const A: TRecVarData; Dim: Integer): Integer;
begin
  If Not RecVarIsArray(A) then Raise Exception.Create(reRecVarisNotArray);
  If (Dim<>1)Or(A.VArray^.DimCount<>1) then Raise Exception.Create('Не умею работать с многомерным RecVar.');
  Result:=A.VArray^.Bounds[0].LowBound+A.VArray^.Bounds[0].ElementCount-1;
end;
// ..
procedure RecVarArrayRedim(var A : TRecVarData; HighBound: Integer);
  Var tmpPRecVarArray:PRecVarArray;
      iOldElementCount, iNewElementCount, {iFromZero,} iI, irvLB, irvHB:Integer;
begin
  If Not RecVarIsArray(A) then Raise Exception.Create(reRecVarisNotArray);
  // it's array
  tmpPRecVarArray:=A.VArray;
  If tmpPRecVarArray^.DimCount<>1 then Raise Exception.Create('Не умею читать из многомерного RecVar.');
  irvLB:=tmpPRecVarArray^.Bounds[0].LowBound;
  iOldElementCount:=tmpPRecVarArray^.Bounds[0].ElementCount;
  irvHB:=tmpPRecVarArray^.Bounds[0].LowBound+iOldElementCount-1;
  If HighBound<irvLB then Raise Exception.Create('HighBound не может быть меньше LowBound.');
  If HighBound=irvHB then Exit;
  iNewElementCount:=HighBound-irvLB+1;
  // Изменяется размер
  If HighBound<irvHB then begin
    // Удаляю часть записей
    For iI:=iNewElementCount{+1} to iOldElementCount-1{irvHB-irvLB+1} do begin
      RecVarClear(PRecVarData(PChar(tmpPRecVarArray^.Data)+iI*tmpPRecVarArray^.ElementSize)^);
    end;
    ReallocMem(tmpPRecVarArray^.Data, iNewElementCount*tmpPRecVarArray^.ElementSize);
  end else begin
    // Добавляю новые записи
    ReallocMem(tmpPRecVarArray^.Data, iNewElementCount*tmpPRecVarArray^.ElementSize);
    FillChar(Pointer(PChar(tmpPRecVarArray^.Data)+iOldElementCount*tmpPRecVarArray^.ElementSize)^, (iNewElementCount-iOldElementCount)*tmpPRecVarArray^.ElementSize, 0);
  end;
  tmpPRecVarArray^.Bounds[0].ElementCount:=iNewElementCount;
end;

function  RecVarArrayGet(var A: TRecVarData; IndexCount: Integer; Indices: Integer): TRecVarData;
Type  PiSmallInt = ^Smallint;
      PiInteger  = ^Integer;
      PiSingle   = ^Single;
      PiDouble   = ^Double;
      PiCurrency = ^Currency;
      PiDateTime = ^TDateTime;
      PiWordBool = ^WordBool;
      PiShortInt = ^ShortInt;
      PiByte     = ^Byte;
      PiWord     = ^Word;
      PiLongWord = ^LongWord;
      PiInt64    = ^Int64;
  var //tmpPRecVarData:PRecVarData;
      tmpPRecVarArray:PRecVarArray;
      tmpPointer:Pointer;
      {iI,}irvLB, irvHB, iFromZero, iVType:Integer;
begin
  If Not RecVarIsArray(A) then Raise Exception.Create(reRecVarisNotArray);
  // it's array
  Result:=rvrUnassigned;
  tmpPRecVarArray:=A.VArray;
  If (IndexCount<>1)Or(tmpPRecVarArray^.DimCount<>1) then Raise Exception.Create('Не умею читать из многомерного RecVar.');
  irvLB:=tmpPRecVarArray^.Bounds[0].LowBound;
  irvHB:=tmpPRecVarArray^.Bounds[0].LowBound+tmpPRecVarArray^.Bounds[0].ElementCount-1;
  If (Indices<irvLB)Or(Indices>irvHB) then Raise Exception.Create('Indices не в допустимом диапазоне.');
  iFromZero:=Indices-irvLB;
  tmpPointer:=Pointer(PChar(tmpPRecVarArray^.Data)+iFromZero*tmpPRecVarArray^.ElementSize);
  iVType:=A.VType and rvTypeMask{0FFFh};
  case iVType of
    rvSmallint{0002h}:begin
      Result.VType:=iVType;
      Result.VSmallInt:=PiSmallInt(tmpPointer)^;
    end;
    rvInteger{0003h}:begin
      Result.VType:=iVType;
      Result.VInteger:=PiInteger(tmpPointer)^;
    end;
    rvSingle{0004h}:begin
      Result.VType:=iVType;
      Result.VSingle:=PiSingle(tmpPointer)^;
    end;
    rvDouble{0005h}:begin
      Result.VType:=iVType;
      Result.VDouble:=PiDouble(tmpPointer)^;
    end;
    rvCurrency{0006h}:begin
      Result.VType:=iVType;
      Result.VCurrency:=PiCurrency(tmpPointer)^;
    end;
    rvDate{0007h}:begin
      Result.VType:=iVType;
      Result.VDate:=PiDateTime(tmpPointer)^;
    end;
    rvBoolean{000Bh}:begin
      Result.VType:=iVType;
      Result.VBoolean:=PiWordBool(tmpPointer)^;
    end;
    rvShortInt{0010h}:begin
      Result.VType:=iVType;
      Result.VShortInt:=PiShortInt(tmpPointer)^;
    end;
    rvByte{0011h}:begin
      Result.VType:=iVType;
      Result.VByte:=PiByte(tmpPointer)^;
    end;
    rvWord{0012h}:begin
      Result.VType:=iVType;
      Result.VWord:=PiWord(tmpPointer)^;
    end;
    rvLongWord{0013h}:begin
      Result.VType:=iVType;
      Result.VLongWord:=PiLongWord(tmpPointer)^;
    end;
    rvInt64{0014h}:begin
      Result.VType:=iVType;
      Result.VInt64:=PiInt64(tmpPointer)^;
    end;
    rvVariant{000Ch}:begin
      RecVarCopy(Result, PRecVarData(tmpPointer)^);
    end;
    rvString{0100h}, rvOleStr{0008h}:begin
      Raise Exception.Create('Пока не сделал.');
    end;
    rvEmpty{0000h}, rvNull{0001h}:begin
      Raise Exception.Create('Недопустимое значение A.VType='+IntToStr(A.VType)+'.');
    end;
  else
    Raise Exception.Create('Неизвестный тип A.VType='+IntToStr(A.VType));
  end;
end;

procedure RecVarArrayPut(var A: TRecVarData; const Value: TRecVarData; IndexCount: Integer; Indices: Integer);
Type  PiSmallInt = ^Smallint;
      PiInteger  = ^Integer;
      PiSingle   = ^Single;
      PiDouble   = ^Double;
      PiCurrency = ^Currency;
      PiDateTime = ^TDateTime;
      PiWordBool = ^WordBool;
      PiShortInt = ^ShortInt;
      PiByte     = ^Byte;
      PiWord     = ^Word;
      PiLongWord = ^LongWord;
      PiInt64    = ^Int64;
  var //tmpPRecVarData:PRecVarData;
      tmpPRecVarArray:PRecVarArray;
      tmpPointer:Pointer;
      {iI,}irvLB, irvHB, iFromZero, iVType:Integer;
begin
  If Not RecVarIsArray(A) then Raise Exception.Create(reRecVarisNotArray);
  // it's array
{  If RecVarIsArray(Value) then begin
    if A.VArray=Value.VArray then Raise Exception.Create('Недопустимо копирование RecVar в себя.');
  end;}
  tmpPRecVarArray:=A.VArray;
  If (IndexCount<>1)Or(tmpPRecVarArray^.DimCount<>1)Or((RecVarIsArray(Value))and(Value.VArray^.DimCount<>1)) then Raise Exception.Create('Не умею писать в многомерного RecVar.');
  irvLB:=tmpPRecVarArray^.Bounds[0].LowBound;
  irvHB:=tmpPRecVarArray^.Bounds[0].LowBound+tmpPRecVarArray^.Bounds[0].ElementCount-1;
  iFromZero:=Indices-irvLB;
  If (Indices<irvLB)Or(Indices>irvHB) then Raise Exception.Create('Indices не в допустимом диапазоне.');
  tmpPointer:=Pointer(PChar(tmpPRecVarArray^.Data)+iFromZero*tmpPRecVarArray^.ElementSize);
  iVType:=A.VType and rvTypeMask{0FFFh};
  If Value.VType<>iVType then
    If iVType<>rvVariant then Raise Exception.Create(reTypeMishmash);
  case iVType of
    rvSmallint{0002h}:begin
      PiSmallInt(tmpPointer)^:=Value.VSmallInt;
    end;
    rvInteger{0003h}:begin
      PiInteger(tmpPointer)^:=Value.VInteger;
    end;
    rvSingle{0004h}:begin
      PiSingle(tmpPointer)^:=Value.VSingle;
    end;
    rvDouble{0005h}:begin
      PiDouble(tmpPointer)^:=Value.VDouble;
    end;
    rvCurrency{0006h}:begin
      PiCurrency(tmpPointer)^:=Value.VCurrency;
    end;
    rvDate{0007h}:begin
      PiDateTime(tmpPointer)^:=Value.VDate;
    end;
    rvBoolean{000Bh}:begin
      PiWordBool(tmpPointer)^:=Value.VBoolean;
    end;
    rvShortInt{0010h}:begin
      PiShortInt(tmpPointer)^:=Value.VShortInt;
    end;
    rvByte{0011h}:begin
      PiByte(tmpPointer)^:=Value.VByte;
    end;
    rvWord{0012h}:begin
      PiWord(tmpPointer)^:=Value.VWord;
    end;
    rvLongWord{0013h}:begin
      PiLongWord(tmpPointer)^:=Value.VLongWord;
    end;
    rvInt64{0014h}:begin
      PiInt64(tmpPointer)^:=Value.VInt64;
    end;
    rvVariant{000Ch}:begin
      RecVarCopy(PRecVarData(tmpPointer)^, Value);
    end;
    rvString{0100h}, rvOleStr{0008h}:begin
      Raise Exception.Create('Пока не сделал.');
    end;
    rvEmpty{0000h}, rvNull{0001h}:begin
      Raise Exception.Create('Недопустимое значение A.VType='+IntToStr(A.VType)+'.');
    end;
  else
    Raise Exception.Create('Неизвестный тип A.VType='+IntToStr(A.VType));
  end;
end;

// Convert to RecVar
Function  SmallintToRecVar(aValue:Smallint):TRecVarData;
begin
  Result:=rvrUnassigned;
  Result.VType:=rvSmallint;
  Result.VSmallInt:=aValue;
end;

Function  IntegerToRecVar(aValue:Integer):TRecVarData;
begin
  Result:=rvrUnassigned;
  Result.VType:=rvInteger;
  Result.VInteger:=aValue;
end;

Function  SingleToRecVar(aValue:Single):TRecVarData;
begin
  Result:=rvrUnassigned;
  Result.VType:=rvSingle;
  Result.VSingle:=aValue;
end;

Function  DoubleToRecVar(aValue:Double):TRecVarData;
begin
  Result:=rvrUnassigned;
  Result.VType:=rvDouble;
  Result.VDouble:=aValue;
end;

Function  CurrencyToRecVar(aValue:Currency):TRecVarData;
begin
  Result:=rvrUnassigned;
  Result.VType:=rvCurrency;
  Result.VCurrency:=aValue;
end;

Function  DateTimeToRecVar(aValue:TDateTime):TRecVarData;
begin
  Result:=rvrUnassigned;
  Result.VType:=rvDate;
  Result.VDate:=aValue;
end;

Function  WideStringToRecVar(aValue:WideString):TRecVarData;
begin
  Result:=rvrUnassigned;
  Raise Exception.Create('Пока не сделал.');
end;

Function  BooleanToRecVar(aValue:Boolean):TRecVarData;
begin
  Result:=rvrUnassigned;
  Result.VType:=rvBoolean;
  Result.VBoolean:=aValue;
end;

Function  ShortIntToRecVar(aValue:ShortInt):TRecVarData;
begin
  Result:=rvrUnassigned;
  Result.VType:=rvShortInt;
  Result.VShortInt:=aValue;
end;

Function  ByteToRecVar(aValue:Byte):TRecVarData;
begin
  Result:=rvrUnassigned;
  Result.VType:=rvByte;
  Result.VByte:=aValue;
end;

Function  WordToRecVar(aValue:Word):TRecVarData;
begin
  Result:=rvrUnassigned;
  Result.VType:=rvWord;
  Result.VWord:=aValue;
end;

Function  LongWordToRecVar(aValue:LongWord):TRecVarData;
begin
  Result:=rvrUnassigned;
  Result.VType:=rvLongWord;
  Result.VLongWord:=aValue;
end;

Function  Int64ToRecVar(aValue:Int64):TRecVarData;
begin
  Result:=rvrUnassigned;
  Result.VType:=rvInt64;
  Result.VInt64:=aValue;
end;

Function  AnsiStringToRecVar(aValue:AnsiString):TRecVarData;
begin
  Result:=rvrUnassigned;
  Raise Exception.Create('Пока не умею.');
end;

Function  VariantToRecVar(aValue:Variant):TRecVarData;
begin
  Result:=rvrUnassigned;
  Raise Exception.Create('Пока не умею.');
end;

Function  BlobToRecVar(aValue:Variant):TRecVarData;
begin
  Result:=rvrUnassigned;
  Raise Exception.Create('Пока не умею.');
end;

// Convert from RecVar
Function  RecVarToSmallint(aValue:TRecVarData):Smallint;
begin
  If aValue.VType=rvSmallint then begin
    Result:=aValue.VSmallInt;
  end else begin
    Raise Exception.Create(reTypeMishmash);
  end;
end;

Function  RecVarToInteger(aValue:TRecVarData):Integer;
begin
  If aValue.VType=rvInteger then begin
    Result:=aValue.VInteger;
  end else begin
    Raise Exception.Create(reTypeMishmash);
  end;
end;

Function  RecVarToSingle(aValue:TRecVarData):Single;
begin
  If aValue.VType=rvSingle then begin
    Result:=aValue.VSingle;
  end else begin
    Raise Exception.Create(reTypeMishmash);
  end;
end;

Function  RecVarToDouble(aValue:TRecVarData):Double;
begin
  If aValue.VType=rvDouble then begin
    Result:=aValue.VDouble;
  end else begin
    Raise Exception.Create(reTypeMishmash);
  end;
end;

Function  RecVarToCurrency(aValue:TRecVarData):Currency;
begin
  If aValue.VType=rvCurrency then begin
    Result:=aValue.VCurrency;
  end else begin
    Raise Exception.Create(reTypeMishmash);
  end;
end;

Function  RecVarToDateTime(aValue:TRecVarData):TDateTime;
begin
  If aValue.VType=rvDate then begin
    Result:=aValue.VDate;
  end else begin
    Raise Exception.Create(reTypeMishmash);
  end;
end;

Function  RecVarToWideString(aValue:TRecVarData):WideString;
begin
  Raise Exception.Create('Пока не умею.');
end;

Function  RecVarToBoolean(aValue:TRecVarData):Boolean;
begin
  If aValue.VType=rvBoolean then begin
    Result:=aValue.VBoolean;
  end else begin
    Raise Exception.Create(reTypeMishmash);
  end;
end;

Function  RecVarToShortInt(aValue:TRecVarData):ShortInt;
begin
  If aValue.VType=rvShortInt then begin
    Result:=aValue.VShortInt;
  end else begin
    Raise Exception.Create(reTypeMishmash);
  end;
end;

Function  RecVarToByte(aValue:TRecVarData):Byte;
begin
  If aValue.VType=rvByte then begin
    Result:=aValue.VByte;
  end else begin
    Raise Exception.Create(reTypeMishmash);
  end;
end;

Function  RecVarToWord(aValue:TRecVarData):Word;
begin
  If aValue.VType=rvWord then begin
    Result:=aValue.VWord;
  end else begin
    Raise Exception.Create(reTypeMishmash);
  end;
end;

Function  RecVarToLongWord(aValue:TRecVarData):LongWord;
begin
  If aValue.VType=rvLongWord then begin
    Result:=aValue.VLongWord;
  end else begin
    Raise Exception.Create(reTypeMishmash);
  end;
end;

Function  RecVarToInt64(aValue:TRecVarData):Int64;
begin
  If aValue.VType=rvInt64 then begin
    Result:=aValue.VInt64;
  end else begin
    Raise Exception.Create(reTypeMishmash);
  end;
end;

Function  RecVarToAnsiString(aValue:TRecVarData):AnsiString;
begin
  Raise Exception.Create('Пока не умею.');
end;

Function  RecVarToVariant(aValue:TRecVarData):Variant;
begin
  Raise Exception.Create('Пока не умею.');
end;

Function  RecVarToBlob(aValue:TRecVarData):Variant;
begin
  Raise Exception.Create('Пока не умею.');
end;


end.
