//Copyright � 2000-2004 by Dmitry A. Sokolyuk

//21.05.2004

unit UTokenParser;

interface
  uses classes{$ifdef ver130}, UVer130Types{$endif}, UTokenParserTypes;

type

  //������� ����� ��� ���������� ��������� ��������� ������� �����������
  TTokenParser = class
  protected
    FSymbolsSpace: AnsiString;
    FSymbolsDelimiter: AnsiString;
    FCommentaryBegin: TStringList;
    FCommentaryEnd: TStringList;
    FToken: TStringList;
  protected
    function InternalExistsSymbol(const aSymbol:char; const aString:AnsiString):boolean;virtual;
    function InternalSymbolIsWord(const aSymbol:char):boolean;virtual;
    function InternalSkipSpace(var aPos:integer; aPosTo:integer; const aString:AnsiString):boolean;virtual;
    function InternalWordIsWord(var aPos:integer; aPosTo:integer; const aString, aWord:AnsiString; aSearchAbsolute:boolean):boolean;virtual;
    function InternalSymbolIsNumber(aSymbol:char):boolean;virtual;
    function InternalSymbolIsNumberDelimiter(aSymbol:char):boolean;virtual;
    procedure InternalSkipNumberical(var aPos:integer; aPosTo:integer; const aStatement:AnsiString; out aIsFloat:boolean);virtual;
    procedure InternalSkipWord(var aPos:integer; aPosTo:integer; const aStatement:AnsiString);virtual;
    function InternalPosToLineCol(aPos:integer; const aSubFunction:AnsiString; aPCol:PInteger = nil; aPLine:PInteger = nil):AnsiString;virtual;
    function InternalTokenNextIfIs(var aPos:integer; aPosTo:integer; const aSubFunction:AnsiString; aPToken:PAnsiString; aPIdTokenNext:TPIdToken; aIdTokenIf:TIdToken):boolean;virtual;
  public
    procedure CommentaryAdd(const aCommentaryBegin, aCommentaryEnd:AnsiString);virtual;
    procedure TokenAdd(const aToken:AnsiString; aidToken:cardinal; aSearchAbsolute:boolean);virtual;
    procedure TokenClear;virtual;
    function TokenById(aIdToken:cardinal; aRaise:boolean=false):AnsiString;virtual;
  public
    property SymbolsDelimiter: AnsiString read FSymbolsDelimiter write FSymbolsDelimiter;
    property SymbolsSpace: AnsiString read FSymbolsSpace write FSymbolsSpace;
  public
    function TokenNext(var aPos:integer; aPosTo:integer; const aString:AnsiString; aPToken:PAnsiString; aPidToken:TPIdToken):boolean;virtual;
  public
    constructor create();
    destructor destroy();override;
  end;

implementation
  uses Sysutils, UStringUtils, UStringConsts;

constructor TTokenParser.create();
begin
  inherited create();

  //�������� ������� ����������� �����
  FSymbolsDelimiter := '()<>=-+/*'',;[]{}!|';//�������, ������� ����� ��������� �����(�� ���� ������������ ����� �� �����), ���� �� �� ������������, �� ��� ������� �������� token-���(����. ���������)
  FSymbolsSpace := #13#10#9#32;//������� ���������(������), ������ ��������� token/�����, ���� �� ������������ 

  FCommentaryBegin := TStringList.Create;
  FCommentaryEnd := TStringList.Create;
  FToken := TStringList.Create;
end;

destructor TTokenParser.destroy();
begin
  FSymbolsDelimiter := '';

  TokenClear;

  FreeAndNil(FCommentaryBegin);
  FreeAndNil(FCommentaryEnd);
  FreeAndNil(FToken);

  inherited destroy();
end;

procedure TTokenParser.CommentaryAdd(const aCommentaryBegin, aCommentaryEnd:AnsiString);
begin
  FCommentaryBegin.Add(aCommentaryBegin);
  FCommentaryEnd.Add(aCommentaryEnd);
end;

type
  TTokenStore = class
    aidToken: cardinal;
    aSearchAbsolute: boolean;
  end;

procedure TTokenParser.TokenAdd(const aToken:AnsiString; aidToken:cardinal; aSearchAbsolute:boolean);
  var tmpTokenStore: TTokenStore;
begin
  tmpTokenStore := TTokenStore.Create;
  tmpTokenStore.aidToken := aidToken;
  tmpTokenStore.aSearchAbsolute := aSearchAbsolute;

  FToken.Objects[FToken.Add(aToken)] := tmpTokenStore;
end;

procedure TTokenParser.TokenClear;
begin
  while FToken.Count > 0 do begin
    if assigned(FToken.Objects[0]) and (FToken.Objects[0] is TObject) then begin
      FToken.Objects[0].free;
      FToken.Objects[0] := nil;
    end;
    FToken.Delete(0);
  end;
end;

function TTokenParser.InternalExistsSymbol(const aSymbol:char; const aString:AnsiString):boolean;
  var tmpI: cardinal;
begin
  result := false;

  for tmpI := 1 to length(aString) do begin
    if aString[tmpI] = aSymbol then begin
      //����� ������ �������, ������ ��� �� word
      result := true;
      break;
    end;
  end;
end;

function TTokenParser.InternalSymbolIsWord(const aSymbol:char):boolean;
begin
  result := (not(InternalExistsSymbol(aSymbol, FSymbolsDelimiter))) and (not(InternalExistsSymbol(aSymbol, FSymbolsSpace)));
end;

function TTokenParser.TokenNext(var aPos:integer; aPosTo:integer; const aString:AnsiString; aPToken:PAnsiString; aPidToken:TPIdToken):boolean;
  var tmpPos: integer;
      tmpIsFloat: boolean;
      tmpToken: AnsiString;
      tmpI: integer;
      tmpBoolean: boolean;
      tmpIdToken: TIdToken;
begin
  //���� ���� ��� ������ - true, ���� ������ ��������� false
  try
    if assigned(aPToken) then aPToken^ := '';
    result := InternalSkipSpace(aPos, aPosTo, aString);

    tmpPos := aPos;//��������� ������ �������
    if result then begin//������ �� ���������

      if aString[tmpPos] = '''' then begin
        //������
        tmpIdToken := tknString;
        SkipString(tmpPos, aString);
        tmpToken := SqlToStr(copy(aString, aPos + 1, tmpPos - aPos - 2));
      end else if (InternalSymbolIsNumber(aString[tmpPos]))or//'12345' ��� 123,45
                  (InternalSymbolIsNumberDelimiter(aString[tmpPos])) then begin
        //�����
        InternalSkipNumberical(tmpPos, aPosTo, aString, tmpIsFloat);
        tmpToken := copy(aString, aPos, tmpPos - aPos);

        if tmpIsFloat then tmpIdToken := tknFloat else tmpIdToken := tknNumber;
      end else begin
        //token ��� �����
        tmpBoolean := false;
        tmpIdToken := tknWord;//�� warning-��

        for tmpI := 0 to FToken.Count -1 do begin
          tmpToken := FToken.Strings[tmpI];
          if InternalWordIsWord(tmpPos, aPosTo, aString, tmpToken, TTokenStore(FToken.Objects[tmpI]).aSearchAbsolute) then begin
            //����������������� �����
            tmpIdToken := TTokenStore(FToken.Objects[tmpI]).aidToken;
            //if assigned(aPToken) then aPToken^ := tmpToken;
            tmpBoolean := true;
            break;
          end;
        end;

        if not tmpBoolean then begin
          //�� ����������������� �����
          tmpIdToken := tknWord;
          InternalSkipWord(tmpPos, aPosTo, aString);
          tmpToken := copy(aString, aPos, tmpPos - aPos);
        end;
      end;

      if aPos = tmpPos then raise exception.createfmt(cnInvalidStatement, [copy(aString, aPos, 1)]);

      aPos := tmpPos;
      if assigned(aPidToken) then aPidToken^ := tmpIdToken;
      if assigned(aPToken) then aPToken^ := tmpToken;
    end;

  except on e:exception do begin
    //e.message:= 'TokenNext: ' + e.message;
    raise;
  end;end;
end;

function TTokenParser.InternalSkipSpace(var aPos:integer; aPosTo:integer; const aString:AnsiString):boolean;
  var tmpI: cardinal;
      tmpCommentaryEnd: AnsiString;
      tmpSkipCommentary: boolean;
begin
  result := false;//���� ���� ��� ������ - true, ���� ������ ��������� false

  while true do begin
    if aPos > aPosTo then break;

    tmpSkipCommentary := false;
    //���������� �����������
    for tmpI := 0 to FCommentaryBegin.Count - 1 do begin
      if InternalWordIsWord(aPos, aPosTo, aString, FCommentaryBegin.Strings[tmpI], true) then begin
        //������� �����������, ����� ���� �� ����� ����������� �����
        tmpCommentaryEnd := FCommentaryEnd.Strings[tmpI];
        while true do begin
          if (aPos > aPosTo) or (InternalWordIsWord(aPos, aPosTo, aString, tmpCommentaryEnd, true)) then begin
            tmpSkipCommentary := true;
            break;//���������������� ������ ���������
          end;
          inc(aPos);
        end;

        if tmpSkipCommentary then break;//��� �������� �����������, ������ �� �����
      end;
    end;

    if tmpSkipCommentary then continue;//��� �������� �����������, ��������� �� ������

    //���������� ������������� �������
    if not InternalExistsSymbol(aString[aPos], FSymbolsSpace) then begin
      result := true;
      break;
    end;

    inc(aPos);
  end;
end;

function TTokenParser.InternalWordIsWord(var aPos:integer; aPosTo:integer; const aString, aWord:AnsiString; aSearchAbsolute:boolean):boolean;
  var tmpLengthWord: integer;
      tmpPosWord: integer;
      tmpPos: integer;
begin
  tmpLengthWord := Length(aWord);
  tmpPosWord := 1;
  tmpPos := aPos;//�������� ������

  result := false;
  while true do begin

    if (tmpPos > aPosTo) or//��������� aString
       (tmpPosWord > tmpLengthWord)//��� ��������� aWord
          then break;//��� ��������� �������, � aWord �� ���������

    if (not aSearchAbsolute) and InternalExistsSymbol(aWord[tmpPosWord], FSymbolsSpace) then begin//� ������� ����� ������ ������
    //if (aWord[tmpPosWord] = #32) and (not InternalSymbolIsWord(aString[tmpPos])) then begin//� ������� ����� ������ ������
      //������� �������� �����

      if InternalSkipSpace(tmpPosWord, length(aWord), aWord) and InternalSkipSpace(tmpPos, aPosTo, aString) then begin
        //� ������� ����� ������ ����������
        result := InternalWordIsWord(tmpPos, aPosTo, aString, copy(aWord, tmpPosWord, length(aWord) - tmpPosWord), aSearchAbsolute);
      end else begin
        //� ������� ����� �����������
        result := false;
      end;

      break;
    end else if (AnsiUpperCase(aString[tmpPos]) <> AnsiUpperCase(aWord[tmpPosWord])) then begin
      //����� �� �������
      break;
    end;

    if (tmpLengthWord = tmpPosWord) and//������� ��� �����
       ((((tmpPos + 1) <= aPosTo) and
         //(not InternalSymbolIsWord(aString[tmpPos +1]))//� � ������ ���� ��������� ������, � �� �� ����������� ���������� �����
         //((not InternalSymbolIsWord(aString[tmpPos])) or ((InternalSymbolIsWord(aString[tmpPos])) and (not InternalSymbolIsWord(aString[tmpPos +1]))))//������� ������ �� ����� ��� ������� ������ ����� � ��������� ������ �� ����� - "AB" � "ABC" ��� "//" � "//aa"
         ((aSearchAbsolute) or ((not aSearchAbsolute) and (not InternalSymbolIsWord(aString[tmpPos + 1]))))//� � ������ ���� ��������� ������, � �� �� ����������� ���������� �����
        ) or
        (tmpPos = aPosTo)//��� ����� ��� ��������, �.�. ����� ���������
       )then begin
      result := true;//����� �������
      break;
    end;
    inc(tmpPosWord);
    inc(tmpPos);
  end;

  if result then begin
    //����� �������
    aPos := tmpPos + 1;//������������� �� ������ ���������� token-�
  end;
end;

function TTokenParser.InternalSymbolIsNumber(aSymbol:char):boolean;
begin
  result := (aSymbol = '0') or (aSymbol = '1') or (aSymbol = '2') or (aSymbol = '3') or (aSymbol = '4') or (aSymbol = '5') or (aSymbol = '6') or (aSymbol = '7') or (aSymbol = '8') or (aSymbol = '9');
end;

function TTokenParser.InternalSymbolIsNumberDelimiter(aSymbol:char):boolean;
begin
  result := (aSymbol = '.');// or (aSymbol = ',');
end;

procedure TTokenParser.InternalSkipNumberical(var aPos:integer; aPosTo:integer; const aStatement:AnsiString; out aIsFloat:boolean);
begin
  if (aPos > aPosTo{tmpLength}) or (aPos < 1) then raise exception.createfmt(cnUnsatisfiedStatementTerminated, [aStatement]);
  aIsFloat := false;
  while true do begin
    if (aPos > aPosTo{tmpLength}) then break;//���� ������ ���������, ������
    if InternalSymbolIsNumberDelimiter(aStatement[aPos]) then begin//��� �����
      if aIsFloat then break;//������ �����/������� � �����, ������ ��� ��� �������� ��������� �����, ������
      aIsFloat := true;//������ �����/�������, ������ ��� ��� float
      inc(aPos);
    end else if InternalSymbolIsNumber(aStatement[aPos]) then begin//��� �����
      inc(aPos);
    end else break;//��� ���-�� ����, ������
  end;
end;

procedure TTokenParser.InternalSkipWord(var aPos:integer; aPosTo:integer; const aStatement:AnsiString);
begin
  if (aPos>aPosTo{tmpLength}) or (aPos<1) then raise exception.createfmt(cnUnsatisfiedStatementTerminated, [aStatement]);
  while true do begin
    if (aPos > aPosTo{tmpLength}) or (not InternalSymbolIsWord(aStatement[aPos])) then break;
    inc(aPos);
  end;
end;

function TTokenParser.TokenById(aIdToken:cardinal; aRaise:boolean=false):AnsiString;
  var tmpI: integer;
      tmpFound: boolean;
begin

  case aIdToken of
    tknString: result := 'STRING';
    tknNumber: result := 'NUMBER';
    tknFloat: result := 'FLOAT';
    tknWord: result := 'WORD';
  else
    result := '';
    tmpFound := false;

    for tmpI := 0 to FToken.Count - 1 do begin
      if TTokenStore(FToken.Objects[tmpI]).aidToken = aIdToken then begin
        result := FToken.Strings[tmpI];
        tmpFound := true;
        break;
      end;
    end;

    if aRaise and (not tmpFound) then begin
      raise exception.create('Token by id('+IntToStr(aIdToken)+') no found.');
    end;
  end;
end;

function TTokenParser.InternalPosToLineCol(aPos:integer; const aSubFunction:AnsiString; aPCol:PInteger = nil; aPLine:PInteger = nil):AnsiString;
  var tmpLine: integer;
      tmpCol: integer;
      tmpI: integer;
begin
  if aPos > Length(aSubFunction) then aPos := Length(aSubFunction);

  tmpLine := 1;
  tmpCol := 1;

  for tmpI := 1 to aPos do begin

    //��������� ������ �������
    if aSubFunction[tmpI] = #10 then continue;

    if aSubFunction[tmpI] = #13 then begin
      //����� ������
      inc(tmpLine);
      tmpCol := 1;
    end else begin
      inc(tmpCol);
    end;
  end;

  result := 'Line=' +IntToStr(tmpLine)+ ' Col=' + IntToStr(tmpCol);
  if assigned(aPCol) then aPCol^ := tmpCol;
  if assigned(aPLine) then aPLine^ := tmpLine;

end;

function TTokenParser.InternalTokenNextIfIs(var aPos:integer; aPosTo:integer; const aSubFunction:AnsiString; aPToken:PAnsiString; aPIdTokenNext:TPIdToken; aIdTokenIf:TIdToken):boolean;
  var tmpPos: integer;
      tmpIdToken:TIdToken;
begin
  //������� �� ��������� token ���� �� aIdTokenIf
  tmpPos := aPos;

  if TokenNext(tmpPos, aPosTo, aSubFunction, aPToken, @tmpIdToken) and (tmpIdToken = aIdTokenIf) then begin
    aPos := tmpPos;
    result := true;
  end else begin
    result := false;
  end;

  if assigned(aPIdTokenNext) then aPIdTokenNext^ := tmpIdToken;
end;

end.
