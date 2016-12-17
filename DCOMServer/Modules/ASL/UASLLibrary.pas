//Copyright © 2000-2004 by Dmitry A. Sokolyuk

//25.05.2004
//Application script laguage

unit UASLLibrary;

interface
  uses UASLSolveSubFunction, UASLLibraryTypes, UASLSolveStatementTypes, classes;

type
  TASLLibrary = class(TASLSolveSubFunction)
  protected
    FOnLibGetProperty: TOnLibGetPropertyEvent;
    FOnLibSetProperty: TOnLibSetPropertyEvent;
    FOnLibFunction: TOnLibFunctionEvent;
    FNameSpace: TStringList;
    FASLLibrary: AnsiString;
  protected
    function InternalDewrapUserData(aUserData: pointer; aPNamespace:PAnsiString; aPSubFunctionName:PAnsiString):pointer;virtual;
  protected
    procedure InternalClearStringList(const aStringList:TStringList);virtual;
    procedure LoadNamespace(var aPos:integer; aPosTo:integer; const aNamespace:AnsiString; const aASLLibrary:AnsiString);virtual;
    function InternalGetNamespace(aNamespace:AnsiString; aRaise:boolean = false):TStringList;virtual;
    function InternalGetNamespaceWithCreate(const aNamespace:AnsiString):TStringList;virtual;
    procedure InternalPushSubFunction(const aStringList:TStringList; const aSubFunctionName:AnsiString; aSubFunctionParamsPos, aSubFunctionParamsPosTo, aSubFunctionPos, aSubFunctionPosTo:integer);virtual;
    procedure InternalCheckDudlicateName(const aStringList:TStringList; aName:AnsiString);virtual;
    procedure InternalGetSubFunctionInfo(var aActualNameSpace:AnsiString; aSelfNamespace:AnsiString; aSubFunctionName:AnsiString; out aSubFunctionParamsPos, aSubFunctionParamsPosTo, aSubFunctionPos, aSubFunctionPosTo:integer);virtual;
  protected
    function InternalOnLibGetProperty(aUserData:pointer; const aName:AnsiString; const aIndex:variant):variant;virtual;
    procedure InternalOnLibSetProperty(aUserData:pointer; const aName:AnsiString; const aIndex:variant; const aValue:variant);virtual;
    function InternalOnLibFunction(aUserData:pointer; const aSubFunctionName:AnsiString; var aSubFunctionParamsData:variant; aOnIsParamOut:TOnIsParamOutEvent):variant;virtual;
    function InternalOnLibSubFunction(aUserData:pointer; const aSubFunctionName:AnsiString; var aSubFunctionParamsData:variant; aOnIsParamOut:TOnIsParamOutEvent):variant;virtual;
  protected
    procedure InternalSubNameToFunctionName(const aSubFunctionNameWithNamespace:AnsiString; out aNamespace:AnsiString; out aSubFunctionName:AnsiString);virtual;
  protected
    procedure SetASLLibrary(const aASLLibrary: AnsiString);virtual;
    procedure InternalLoadLibrary(const aASLLibrary:AnsiString);virtual;
  public
    function ExecuteSubFunction(aUserData:pointer; const aNameSpace:AnsiString; const aSelfNamespace:AnsiString; const aSubFunctionName:AnsiString; var aSubFunctionParamsData:variant; aIsParamOut:TOnIsParamOutEvent):variant;overload;virtual;
    function ExecuteSubFunction(aUserData:pointer; const aSubFunctionNameWithNamespace:AnsiString; var aSubFunctionParamsData:variant):variant;overload;virtual;
  public
    property OnLibGetProperty:TOnLibGetPropertyEvent read FOnLibGetProperty write FOnLibGetProperty;
    property OnLibSetProperty:TOnLibSetPropertyEvent read FOnLibSetProperty write FOnLibSetProperty;
    property OnLibFunction:TOnLibFunctionEvent read FOnLibFunction write FOnLibFunction;
    property ASLLibrary:AnsiString read FASLLibrary write SetASLLibrary;
  public
    constructor create();
    destructor destroy();override;
  end;

implementation
  uses Sysutils, UStringConsts, UASLLibSubFunction, UTokenParserTypes, UASLSolveSubFunctionTypes;

constructor TASLLibrary.create();
begin
  FOnLibGetProperty := nil;
  FOnLibSetProperty := nil;
  FOnLibFunction := nil;

  FNameSpace := TStringList.Create;

  inherited create();

  TokenAdd('FUNCTION', integer(tknFunction), false);
  TokenAdd('NAMESPACE', integer(tknNamespace), false);
end;

destructor TASLLibrary.destroy();
begin

  InternalClearStringList(FNameSpace);
  freeandnil(FNameSpace);

  inherited destroy();
end;

procedure TASLLibrary.InternalClearStringList(const aStringList:TStringList);
begin
  while aStringList.count > 0 do begin
    if not assigned(aStringList.Objects[0]) then raise exception.create('Objects[0] not assigned');

    if aStringList.Objects[0] is TStringList then begin
      InternalClearStringList(TStringList(aStringList.Objects[0]));
    end else if aStringList.Objects[0] is TASLLibSubFunction then begin
      //ok
    end else begin
      raise exception.create('Objects[0] is unknown');
    end;

    aStringList.Objects[0].free;
    aStringList.Delete(0);
  end;
end;

function TASLLibrary.InternalGetNamespace(aNamespace:AnsiString; aRaise:boolean = false):TStringList;
  var tmpI: integer;
begin
  aNamespace := AnsiUpperCase(aNamespace);

  for tmpI := 0 to FNameSpace.count - 1 do begin
    if FNameSpace.Strings[tmpI] = aNamespace then begin
      result := TStringList(FNameSpace.Objects[tmpI]);
      exit;
    end;
  end;

  if aRaise then raise exception.create('Namespace '''+aNamespace+''' no found.');

  result := nil;
end;

function TASLLibrary.InternalGetNamespaceWithCreate(const aNamespace:AnsiString):TStringList;
begin
  result := InternalGetNamespace(aNamespace, false);

  if not assigned(result) then begin
    result := TStringList.create;
    try
      FNameSpace.Objects[FNameSpace.Add(AnsiUpperCase(aNamespace))] := result;
    except
      freeandnil(result);
      raise;
    end;
  end;
end;

procedure TASLLibrary.InternalCheckDudlicateName(const aStringList:TStringList; aName:AnsiString);
  var tmpI: integer;
begin
  aName := AnsiUpperCase(aName);

  for tmpI := 0 to aStringList.count - 1 do begin
    if aStringList.Strings[tmpI] = aName then begin
      raise exception.create('Dublicate name for '''+aName+'''');
    end;
  end;
end;

procedure TASLLibrary.InternalPushSubFunction(const aStringList:TStringList; const aSubFunctionName:AnsiString; aSubFunctionParamsPos, aSubFunctionParamsPosTo, aSubFunctionPos, aSubFunctionPosTo:integer);
  var tmpASLLibSubFunction: TASLLibSubFunction;
begin
  InternalCheckDudlicateName(aStringList, aSubFunctionName);

  tmpASLLibSubFunction := TASLLibSubFunction.create;
  try
    tmpASLLibSubFunction.SubFunctionParamsPos := aSubFunctionParamsPos;
    tmpASLLibSubFunction.SubFunctionParamsPosTo := aSubFunctionParamsPosTo;
    tmpASLLibSubFunction.SubFunctionPos := aSubFunctionPos;
    tmpASLLibSubFunction.SubFunctionPosTo := aSubFunctionPosTo;

    aStringList.Objects[aStringList.Add(AnsiUpperCase(aSubFunctionName))] := tmpASLLibSubFunction;
  except
    tmpASLLibSubFunction.free;
    raise;
  end;
end;

procedure TASLLibrary.LoadNamespace(var aPos:integer; aPosTo:integer; const aNamespace:AnsiString; const aASLLibrary:AnsiString);
  var tmpToken: AnsiString;
      tmpIdToken: TIdToken;
      tmpPos: integer;
      tmpSubFunctionParamsPos: integer;
      tmpSubFunctionParamsPosTo: integer;
begin
  while TokenNext(aPos, aPosTo, aASLLibrary, @tmpToken, @tmpIdToken) do begin

    case tmpIdToken of
      tknNamespace:begin
        //нахожу им€ namespace
        if (not TokenNext(aPos, aPosTo, aASLLibrary, @tmpToken, @tmpIdToken)) or (tmpIdToken <> tknWord) then raise exception.createfmt(cnExpectStatement, ['Name of namespace']);
        //нахожу {
        if (not TokenNext(aPos, aPosTo, aASLLibrary, nil, @tmpIdToken)) or (tmpIdToken <> tknFigureBracketOpen) then raise exception.createfmt(cnExpectStatement, ['{ of namespace']);

        tmpPos := aPos;
        //нахожу }
        InternalSkipBracketsFrom(aPos, aPosTo, aASLLibrary, tknFigureBracketOpen, tknFigureBracketClose);

        //загружаю Namespace
        LoadNamespace(tmpPos, aPos - 2, tmpToken, aASLLibrary);
      end;
      tknFunction:begin
        //нахожу им€ function
        if (not TokenNext(aPos, aPosTo, aASLLibrary, @tmpToken, @tmpIdToken)) or (tmpIdToken <> tknWord) then raise exception.createfmt(cnExpectStatement, ['Name of function']);
        //нахожу (
        if (not TokenNext(aPos, aPosTo, aASLLibrary, nil, @tmpIdToken)) or (tmpIdToken <> tknBracketOpen) then raise exception.createfmt(cnExpectStatement, ['( of function '''+tmpToken+'''']);

        tmpPos := aPos;
        //нахожу )
        InternalSkipBracketsFrom(aPos, aPosTo, aASLLibrary, tknBracketOpen, tknBracketClose);

        //беру список параметров
        tmpSubFunctionParamsPos := tmpPos;
        tmpSubFunctionParamsPosTo := aPos - 2;

        //нахожу {
        if (not TokenNext(aPos, aPosTo, aASLLibrary, nil, @tmpIdToken)) or (tmpIdToken <> tknFigureBracketOpen) then raise exception.createfmt(cnExpectStatement, ['{ of function '''+tmpToken+'''']);

        tmpPos := aPos;
        //нахожу }
        InternalSkipBracketsFrom(aPos, aPosTo, aASLLibrary, tknFigureBracketOpen, tknFigureBracketClose);

        InternalPushSubFunction(InternalGetNamespaceWithCreate(aNamespace), tmpToken, tmpSubFunctionParamsPos, tmpSubFunctionParamsPosTo, tmpPos, aPos -2);
      end;
    else
      raise exception.createfmt(cnInvalidStatement, [tmpToken]);
    end;
  end;
end;

procedure TASLLibrary.InternalLoadLibrary(const aASLLibrary:AnsiString);
  var tmpPos: integer;
      tmpPosTo: integer;
begin
  tmpPos := 1;
  tmpPosTo := length(aASLLibrary);

  //чищу список перед загрузкой
  InternalClearStringList(FNameSpace);
  try
    //загружаю библиотеку
    LoadNamespace(tmpPos, tmpPosTo, '', aASLLibrary);

    FASLLibrary := aASLLibrary;
  except
    //ошибка загрузки библиотеки, сбрасываю список
    InternalClearStringList(FNameSpace);
    raise;
  end;
end;

procedure TASLLibrary.InternalGetSubFunctionInfo(var aActualNameSpace:AnsiString; aSelfNamespace:AnsiString; aSubFunctionName:AnsiString; out aSubFunctionParamsPos, aSubFunctionParamsPosTo, aSubFunctionPos, aSubFunctionPosTo:integer);
  var tmpNamespaceList: TStringList;
      tmpSubFunctionIndexOfNamespace: integer;
      tmpASLLibSubFunction: TASLLibSubFunction;
begin
  aActualNameSpace := AnsiUpperCase(aActualNameSpace);
  aSubFunctionName := AnsiUpperCase(aSubFunctionName);

  //если namespace не указан €вно то сначала ищетс€ в своем aSelfNamespace а затем в ''(пустом)
  tmpNamespaceList := nil;
  tmpSubFunctionIndexOfNamespace := -1;
  if (aActualNameSpace = '') and (aSelfNamespace <> '') then begin
    //Namespace €вно не указан
    //свой указан, ищу сначало в своем
    tmpNamespaceList := InternalGetNamespace(aSelfNamespace, false);
    if assigned(tmpNamespaceList) then begin
      tmpSubFunctionIndexOfNamespace := tmpNamespaceList.IndexOf(aSubFunctionName);
      if tmpSubFunctionIndexOfNamespace >= 0 then begin
        //сработал вызов в рамках какого-то namespace-а без €вного указани€ оного, нужно восстановить полное им€ namespace
        aActualNameSpace := aSelfNamespace;//подт€гиваю полный namespace
      end;
    end;
  end;

  //а если не нашелс€ namespace, ищу в пустом
  if (not assigned(tmpNamespaceList)) or (tmpSubFunctionIndexOfNamespace < 0) then begin
    //в своем не нашелс€, ищу в указанном
    tmpNamespaceList := InternalGetNamespace(aActualNameSpace, true);
    tmpSubFunctionIndexOfNamespace := tmpNamespaceList.IndexOf(aSubFunctionName);
  end;

  //теперь уже смотрю что дал поиск
  if tmpSubFunctionIndexOfNamespace < 0 then raise exception.create('SubFunction '''+aSubFunctionName+''' for namespace '''+aActualNameSpace+''' in library is no found.');

  if (not assigned(tmpNamespaceList.Objects[tmpSubFunctionIndexOfNamespace])) or (not (tmpNamespaceList.Objects[tmpSubFunctionIndexOfNamespace] is TASLLibSubFunction)) then raise exception.createfmt(cnInvalidValueOf, ['nodetected', 'NamespaceList.Objects[]']);

  tmpASLLibSubFunction := TASLLibSubFunction(tmpNamespaceList.Objects[tmpSubFunctionIndexOfNamespace]);

  aSubFunctionParamsPos := tmpASLLibSubFunction.SubFunctionParamsPos;
  aSubFunctionParamsPosTo := tmpASLLibSubFunction.SubFunctionParamsPosTo;
  aSubFunctionPos := tmpASLLibSubFunction.SubFunctionPos;
  aSubFunctionPosTo := tmpASLLibSubFunction.SubFunctionPosTo;
end;

type
  TPExecuteSubFunctionWrapUserData = ^TExecuteSubFunctionWrapUserData;
  TExecuteSubFunctionWrapUserData = record
   aUserData: pointer;
   aNamespace: AnsiString;
   aSubFunctionName: AnsiString;
  end;

function TASLLibrary.InternalDewrapUserData(aUserData: pointer; aPNamespace:PAnsiString; aPSubFunctionName:PAnsiString):pointer;
begin
  result := TPExecuteSubFunctionWrapUserData(aUserData)^.aUserData;
  if assigned(aPNamespace) then aPNamespace^ := TPExecuteSubFunctionWrapUserData(aUserData)^.aNamespace;
  if assigned(aPSubFunctionName) then aPSubFunctionName^ := TPExecuteSubFunctionWrapUserData(aUserData)^.aSubFunctionName;
end;

function TASLLibrary.InternalOnLibGetProperty(aUserData:pointer; const aName:AnsiString; const aIndex:variant):variant;
  var tmpNamespace, tmpSubFunctionName: AnsiString; 
begin
  if not assigned(FOnLibGetProperty) then raise exception.createfmt(cnValueNotAssigned, ['OnLibGetProperty']);
  result := FOnLibGetProperty(InternalDewrapUserData(aUserData, @tmpNamespace, @tmpSubFunctionName), tmpNamespace, tmpSubFunctionName, aName, aIndex);
end;

procedure TASLLibrary.InternalOnLibSetProperty(aUserData:pointer; const aName:AnsiString; const aIndex:variant; const aValue:variant);
  var tmpNamespace, tmpSubFunctionName: AnsiString; 
begin
  if not assigned(FOnLibSetProperty) then raise exception.createfmt(cnValueNotAssigned, ['OnLibSetProperty']);
  FOnLibSetProperty(InternalDewrapUserData(aUserData, @tmpNamespace, @tmpSubFunctionName), tmpNamespace, tmpSubFunctionName, aName, aIndex, aValue);
end;

function TASLLibrary.InternalOnLibFunction(aUserData:pointer; const aSubFunctionName:AnsiString; var aSubFunctionParamsData:variant; aOnIsParamOut:TOnIsParamOutEvent):variant;
  var tmpCallerNamespace, tmpCallerSubFunctionName: AnsiString;
begin
  if not assigned(FOnLibFunction) then raise exception.createfmt(cnValueNotAssigned, ['OnLibFunction']);
  result := FOnLibFunction(InternalDewrapUserData(aUserData, @tmpCallerNamespace, @tmpCallerSubFunctionName), aSubFunctionName, aSubFunctionParamsData, aOnIsParamOut, tmpCallerNamespace, tmpCallerSubFunctionName);
end;

function TASLLibrary.InternalOnLibSubFunction(aUserData:pointer; const aSubFunctionName:AnsiString; var aSubFunctionParamsData:variant; aOnIsParamOut:TOnIsParamOutEvent):variant;
  var tmpCallerNamespace, tmpCallerSubFunctionName: AnsiString;
      tmpCallerUserData: pointer;
      tmpNamespace, tmpSubFunctionName: AnsiString;
begin
  tmpCallerUserData := InternalDewrapUserData(aUserData, @tmpCallerNamespace, @tmpCallerSubFunctionName);
  InternalSubNameToFunctionName(aSubFunctionName, tmpNamespace, tmpSubFunctionName);
  result := ExecuteSubFunction(tmpCallerUserData, tmpNamespace, tmpCallerNamespace{SelfNamespace}, tmpSubFunctionName, aSubFunctionParamsData, aOnIsParamOut);
end;

function TASLLibrary.ExecuteSubFunction(aUserData:pointer; const aNameSpace:AnsiString; const aSelfNamespace:AnsiString; const aSubFunctionName:AnsiString; var aSubFunctionParamsData:variant; aIsParamOut:TOnIsParamOutEvent):variant;
  var tmpSubFunctionParamsPos: integer;
      tmpSubFunctionParamsPosTo: integer;
      tmpSubFunctionPos: integer;
      tmpSubFunctionPosTo: integer;
      tmpExecuteSubFunctionWrapUserData: TExecuteSubFunctionWrapUserData;
      tmpASLSolveStatementEvents: TASLSolveStatementEvents;
      tmpActualNameSpace:AnsiString;
begin
  tmpActualNameSpace := aNameSpace;
  InternalGetSubFunctionInfo(tmpActualNameSpace, aSelfNamespace, aSubFunctionName, tmpSubFunctionParamsPos, tmpSubFunctionParamsPosTo, tmpSubFunctionPos, tmpSubFunctionPosTo);
  //дл€ того чтобы пон€ть им€ вызванной функции и namespace
  tmpExecuteSubFunctionWrapUserData.aUserData := aUserData;
  tmpExecuteSubFunctionWrapUserData.aNameSpace := tmpActualNameSpace;
  tmpExecuteSubFunctionWrapUserData.aSubFunctionName := aSubFunctionName;
  //конструкци€ дл€ вызова
  tmpASLSolveStatementEvents.aUserData := @tmpExecuteSubFunctionWrapUserData;
  tmpASLSolveStatementEvents.OnFunction := InternalOnLibFunction;
  tmpASLSolveStatementEvents.OnSubFunction := InternalOnLibSubFunction;
  tmpASLSolveStatementEvents.OnGetProperty := InternalOnLibGetProperty;
  tmpASLSolveStatementEvents.OnSetProperty := InternalOnLibSetProperty;

  result := SolveSubFunction(tmpASLSolveStatementEvents, tmpSubFunctionParamsPos, tmpSubFunctionParamsPosTo, tmpSubFunctionPos, tmpSubFunctionPosTo, FASLLibrary, aSubFunctionParamsData, aIsParamOut);
end;

function TASLLibrary.ExecuteSubFunction(aUserData:pointer; const aSubFunctionNameWithNamespace:AnsiString; var aSubFunctionParamsData:variant):variant;
  var tmpNamespace: AnsiString;
      tmpSubFunctionName: AnsiString;
      tmpIsParamOut:TOnIsParamOutEvent;
begin
  InternalSubNameToFunctionName(aSubFunctionNameWithNamespace, tmpNamespace, tmpSubFunctionName);
  tmpIsParamOut := nil;
  result := ExecuteSubFunction(aUserData, tmpNamespace, ''{aSelfNamespace}, tmpSubFunctionName, aSubFunctionParamsData, tmpIsParamOut);
end;

procedure TASLLibrary.InternalSubNameToFunctionName(const aSubFunctionNameWithNamespace:AnsiString; out aNamespace:AnsiString; out aSubFunctionName:AnsiString);
  var tmpI: integer;
      tmpLength: integer;
begin
  tmpLength := length(aSubFunctionNameWithNamespace);

  for tmpI := tmpLength downto 1 do begin
    if aSubFunctionNameWithNamespace[tmpI] = '.' then begin
      break;
    end;
  end;

  aNamespace := copy(aSubFunctionNameWithNamespace, 1, tmpI - 1);//-1 вырезает точку
  aSubFunctionName := copy(aSubFunctionNameWithNamespace, tmpI + 1, tmpLength - tmpI);
end;

procedure TASLLibrary.SetASLLibrary(const aASLLibrary: AnsiString);
begin
  InternalLoadLibrary(aASLLibrary);
end;

end.
