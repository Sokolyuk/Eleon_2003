//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UAppSecurity;

interface
  uses UTrayInterface, UAppSecurityTypes, Dbclient, UTTaskTypes, UAdmTypes, UTrayInterfaceTypes, UTrayTypes, UAppMessageTypes;
type
  TAppSecurity=class(TTrayInterface, IAppSecurity)
  private
    FCDSLDB, FCDSMT, FCDSPT:TClientDataSet;
    //FTray:ITray;
    FAppMessage:IAppMessage;
  protected
    function InternalGetIAppMessage:IAppMessage;virtual;
    //function InternalGetITray:ITray;virtual;
  protected
    function InternalGetInitGUIDCount:Cardinal;override;
    procedure InternalInitGUIDList;override;
    procedure InternalInit;override;
  protected
    property CDSLDB:TClientDataSet read FCDSLDB;
    property CDSMT:TClientDataSet read FCDSMT;
    property CDSPT:TClientDataSet read FCDSPT;
  public
    constructor create;
    destructor destroy;override;
    Procedure ITReloadSecurety;virtual;
    Procedure ITCheckSecurityLDB(Const aTables, aSecurityContext:Variant);virtual;
    Procedure ITCheckSecurityMTask(aMTask:TTask; Const aSecurityContext:Variant);virtual;
    Procedure ITCheckSecurityPTask(aPTask:TADMTask; Const aSecurityContext:Variant);virtual;
  end;

implementation
  uses Sysutils, ULocalDataBaseTypes, ULocalDataBase, UServerInfoTypes, UTrayConsts, Db, USQLParserTypes,
       USQLParserUtils, UStringUtils, Variants, UServerPropertiesTypes, UTTaskUtils, UServerActionConsts, UErrorConsts;

constructor TAppSecurity.create;
begin
  inherited create;
  FCDSLDB:=TClientDataSet.Create(Nil);
  FCDSMT:=TClientDataSet.Create(Nil);
  FCDSPT:=TClientDataSet.Create(Nil);
end;

destructor TAppSecurity.destroy;
begin
  FreeAndNil(FCDSLDB);
  FreeAndNil(FCDSMT);
  FreeAndNil(FCDSPT);
  inherited destroy;
end;

function TAppSecurity.InternalGetInitGUIDCount:Cardinal;
begin
  result:=inherited InternalGetInitGUIDCount+1;
end;

procedure TAppSecurity.InternalInitGUIDList;
  var tmpCount:Cardinal;
begin
  inherited InternalInitGUIDList;
  tmpCount:=inherited InternalGetInitGUIDCount;
  GUIDList^.aList[tmpCount]:=IServerInfo;
end;

procedure TAppSecurity.InternalInit;
begin
  ITReloadSecurety;
end;

Procedure TAppSecurity.ITReloadSecurety;
  Var tmpLDB:ILocalDataBase;//!!!
begin
  Internallock;
  try
    tmpLDB:=TLocalDataBase.Create;
    tmpLDB.CallerAction:=cnServerAction;
    tmpLDB.CheckSecuretyLDB:=False;
    tmpLDB.CheckForTriggers:=False;
    FCDSLDB.Data:=tmpLDB.OpenSQL('SELECT CommandName,TableName,GroupName,[Deny] FROM ssInternalAccessLDB');
    FCDSMT.Data:=tmpLDB.OpenSQL('SELECT IdMTask,GroupName,[Deny] FROM ssInternalAccessMT');
    FCDSPT.Data:=tmpLDB.OpenSQL('SELECT IdPTask,GroupName,[Deny] FROM ssInternalAccessPT');
  finally
    Internalunlock;
  end;
end;

Procedure TAppSecurity.ITCheckSecurityLDB(Const aTables, aSecurityContext:Variant);
  Var blSCEmpty, blTNEmpty:Boolean;
  Var ivLB, ivHB:Integer;
  Function CheckSecurityGroup(Const aDS:TDataSet; Const aSQLCommandType:TSQLCommandType; Const aTableName:AnsiString; aDeny:Integer):Boolean;
    Var tmpCommandName, tmpTableName:AnsiString;
        AllCommandName, AllTableName:Boolean;
        tmplI:Integer;
  Begin
    Result:=False;//Проверяю, если пустой SecuretyContext, то значит непонятно что искать
    if blSCEmpty then Exit;//--
    aDS.First;//Устанавливаюсь на начало
    While aDS.eof=false do begin // Пока не кончится//Проверяю относится ли текущая запись к текущему юзеру.
      if aDeny=aDS.FieldByName('Deny').AsInteger then begin//Deny тот.//SecurityContext не пустой
        For tmplI:=ivLB To ivHB do begin
          if aDS.FieldByName('GroupName').IsNull then begin
           Break;//Запись пустая, значит она относится ко всем юзерам.
          end;
          if CheckIncludeParamStrInParamsStr(AnsiUpperCase(aDS.FieldByName('GroupName').AsString), AnsiUpperCase(VarToStr(aSecurityContext[tmplI])), ';') then begin
            Break;//Запись относится к текущему юзеру.
          end;
        end;
      end else begin//Не тот Deny
        tmplI:=ivHB+1;//Устанавливаю что текущая запись не относится к текущему юзеру.
      end;
      if tmplI<=ivHB then begin//Установленная запись относится к текущему юзеру.
        tmpTableName:=AnsiUpperCase(aDS.FieldByName('TableName').AsString);
        tmpCommandName:=AnsiUpperCase(aDS.FieldByName('CommandName').AsString);//Текущая запись относится к текущему юзеру.//TableName
        if aDS.FieldByName('TableName').IsNull then begin//Есть право на какую то команду для всех таблиц
          AllTableName:=True;
        end else begin//Нет права на команду для всех таблиц
          AllTableName:=False;
        end;//CommandName
        if aDS.FieldByName('CommandName').IsNull then begin//Есть право на все команды
          AllCommandName:=True;
        end else begin//Нет права на все команды
          AllCommandName:=False;
        end;//-- Обработчик --------------------
        if AllTableName then begin//Есть право на все таблицы
          if AllCommandName then begin//Есть право на все команды
            Result:=True;
            Exit;
          end else begin//Нет права на все команды
            if aSQLCommandType in ParamsStrToSQLCommands(tmpCommandName) then begin
              Result:=True;//т.е. есть право на эту команду и на все таблицы
              Exit;
            end;
          end;
        end else begin//Нет права на все таблицы
          if AllCommandName then begin//Есть право на все команды
            if CheckIncludeParamStrInParamsStr(tmpTableName, aTableName, ';') then begin
              Result:=True;//т.е. есть право на все команды и на эту таблицу
              Exit;
            end;
          end else begin//Нет права на все команды
            if  (CheckIncludeParamStrInParamsStr(tmpTableName, aTableName, ';'))And
                (aSQLCommandType in ParamsStrToSQLCommands(tmpCommandName)) then Begin
              Result:=True;//т.е. есть право на эту команду и на эту таблицу
              Exit;
            end;
          end;
        end;
      end;
      aDS.Next;
    end;//while
  end;
  Var tmpI, ivtLB, ivtHB:Integer;
begin
  Internallock;
  try
    try
      if not CDSLDB.Active then raise exception.create('FCDSLDB is not active.');//Беру размерность aTables.
      if VarIsArray(aTables) then begin//Есть таблицы
        ivtLB:=VarArrayLowBound(aTables, 1);
        ivtHB:=VarArrayHighBound(aTables, 1);
        blTNEmpty:=False;
      end else begin//Нет таблиц//blTNEmpty:=True;
{$IfDef TruncatedSecurity}
        InternalGetIAppMessage.ITMessAdd(Now, now, IServerProperties(cnTray.Query(IServerProperties)).ServerUserName, 'TDataCase', 'ITCheckSecurityLDB(ИГНОРИРУЕТСЯ): Список таблиц в SQL запросе не определен. Обратитесь к разработчику.', mecApp, mesWarning);
        Exit;
{$Else}
        raise exception.createFmtHelp(cserInternalError, ['Список таблиц в SQL запросе не определен. Обратитесь к разработчику.'], cnerInternalError);
{$Endif}
      end;//Беру размерность SecurityContext.
      if VarIsArray(aSecurityContext) then begin//Есть права
        ivLB:=VarArrayLowBound(aSecurityContext, 1);
        ivHB:=VarArrayHighBound(aSecurityContext, 1);
        blSCEmpty:=False;
      end else begin//Нет прав//blSCEmpty:=True;
{$IfDef TruncatedSecurity}
        InternalGetIAppMessage.ITMessAdd(Now, now, IServerProperties(cnTray.Query(IServerProperties)).ServerUserName, 'TDataCase', 'ITCheckSecurityLDB(ИГНОРИРУЕТСЯ): Список групп не определен(SecurityContext). Обратитесь к разработчику.', mecApp, mesWarning);
        Exit;
{$Else}
        raise exception.createFmtHelp(cserInternalError, ['Список групп не определен(SecurityContext). Обратитесь к разработчику.'], cnerInternalError);
{$Endif}
      end;//Проверяю Deny//Есть таблицы//Есть права
      if not blTNEmpty then begin
        for tmpI:=ivtLB To ivtHB do begin// Кручу цыкл с перечнем таблиц, которые хочет использовать юзер.
          if CheckSecurityGroup(CDSLDB, TSQLCommandType(aTables[tmpI][0]), AnsiUpperCase(VarToStr(aTables[tmpI][1])), 1)= True then begin
            //raise exception.create('Нет прав на Command='''+SQLCommandToStr(TSQLCommandType(aTables[tmpI][0]))+''', Table='''+VarToStr(aTables[tmpI][1])+''', User='''+aSecurityContext[0]+'''(Deny).');
            raise exception.createFmtHelp(cserAccessDenied, ['Command='''+SQLCommandToStr(TSQLCommandType(aTables[tmpI][0]))+''', Table='''+VarToStr(aTables[tmpI][1])+''', User='''+aSecurityContext[0]+'''(Deny).'], cnerAccessDenied);
          end;
        end;//For
      end;//Есть таблицы//Есть права
      if not blTNEmpty then begin
        for tmpI:=ivtLB To ivtHB do begin//Кручу цыкл с перечнем таблиц, которые хочет использовать юзер.
          if CheckSecurityGroup(CDSLDB, TSQLCommandType(aTables[tmpI][0]), AnsiUpperCase(VarToStr(aTables[tmpI][1])), 0)= False then begin
            //raise exception.create('Нет прав на Command='''+SQLCommandToStr(TSQLCommandType(aTables[tmpI][0]))+''', Table='''+VarToStr(aTables[tmpI][1])+''', User='''+aSecurityContext[0]+'''(Access).');
            raise exception.createFmtHelp(cserAccessDenied, ['Command='''+SQLCommandToStr(TSQLCommandType(aTables[tmpI][0]))+''', Table='''+VarToStr(aTables[tmpI][1])+''', User='''+aSecurityContext[0]+'''(Access).'], cnerAccessDenied);
          end;
        end;//For
      end;
    except on e:exception do begin
      e.message:='Безопасность LDB: '+e.message;
      raise;
    end;end;
  finally
    Internalunlock;
  end;
end;

Procedure TAppSecurity.ITCheckSecurityMTask(aMTask:TTask; Const aSecurityContext:Variant);
  Var blSCEmpty :Boolean;
      ivLB, ivHB :Integer;
  Function CheckSecurityGroup(aDS:TDataSet; _MTask:TTask; aDeny:Integer):Boolean;
    Var tmplI:Integer;
  Begin
    Result:=False;//Проверяю, если пустой SecuretyContext, то значит непонятно что искать
    if blSCEmpty then Exit;//--
    aDS.First;//Устанавливаюсь на начало
    While aDS.eof=false do begin//Пока не кончится//Проверяю относится ли текущая запись к текущему юзеру.
      if aDeny=aDS.FieldByName('Deny').AsInteger then begin//Deny тот.//SecurityContext не пустой
        For tmplI:=ivLB To ivHB do begin
          if aDS.FieldByName('GroupName').IsNull then begin
            Break;//Запись пустая, значит она относится ко всем юзерам.
          end;
          //If UpperCase(aDS.FieldByName('GroupName').AsString)=UpperCase(VarToStr(aSecurityContext[tmplI])) then begin
          if CheckIncludeParamStrInParamsStr(AnsiUpperCase(aDS.FieldByName('GroupName').AsString), AnsiUpperCase(VarToStr(aSecurityContext[tmplI])), ';') then begin
            Break;//Запись относится к текущему юзеру.
          end;
        end;
      end else begin//Не тот Deny
        tmplI:=ivHB+1;//Устанавливаю что текущая запись не относится к текущему юзеру.
      end;
      if tmplI<=ivHB then begin
        if (aDS.FieldByName('IdMTask').IsNull)Or(aDS.FieldByName('IdMTask').AsInteger=-1)
         Or(aDS.FieldByName('IdMTask').AsInteger=Integer(_MTask)) then begin//Запись пустая, значит она относится ко всем юзерам.
         Result:=True;//т.е. есть право на эту команду и на эту таблицу
         Exit;
        end;
      end;
      aDS.Next;
    end;//while
  end;
begin
  Internallock;
  try
    try
      if Not CDSMT.Active then raise exception.create('FCDSMT is not active.');//Беру размерность SecurityContext.
      if (VarType(aSecurityContext) and varArray)=varArray then begin//Есть права
        ivLB:=VarArrayLowBound(aSecurityContext, 1);
        ivHB:=VarArrayHighBound(aSecurityContext, 1);
        blSCEmpty:=False;
      end else begin//Нет прав
        blSCEmpty:=True;
        raise exception.create('Список групп не определен(SecurityContext). Обратитесь к разработчику.');
      end;
      if CheckSecurityGroup(CDSMT, aMTask, 1)= True then begin
        raise exception.create('Нет прав на MTask='''+MTaskToStr(aMTask)+''', User='''+aSecurityContext[0]+'''(Deny).');
      end;
      if CheckSecurityGroup(CDSMT, aMTask, 0)= False then begin
        raise exception.create('Нет прав на MTask='''+MTaskToStr(aMTask)+''', User='''+aSecurityContext[0]+'''(Access).');
      end;
    except on e:exception Do begin
      e.message:='Безопасность MTask: '+e.message;
      raise;
    end;end;
  finally
    Internalunlock;
  end;
end;

Procedure TAppSecurity.ITCheckSecurityPTask(aPTask:TADMTask; Const aSecurityContext:Variant);
  Var blSCEmpty :Boolean;
      ivLB, ivHB :Integer;
  Function CheckSecurityGroup(aDS:TDataSet; _PTask:TADMTask; aDeny:Integer):Boolean;
    Var tmplI:Integer;
  Begin
    Result:=False;//Проверяю, если пустой SecuretyContext, то значит непонятно что искать
    if blSCEmpty then Exit;//--
    aDS.First;//Устанавливаюсь на начало
    While aDS.eof=false do begin//Пока не кончится//Проверяю относится ли текущая запись к текущему юзеру.
      if aDeny=aDS.FieldByName('Deny').AsInteger then begin//Deny тот.//SecurityContext не пустой
        For tmplI:=ivLB To ivHB do begin
          if aDS.FieldByName('GroupName').IsNull then begin//Запись пустая, значит она относится ко всем юзерам.
            Break;
          end;
          //If UpperCase(aDS.FieldByName('GroupName').AsString)=UpperCase(VarToStr(aSecurityContext[tmplI])) then begin
          if CheckIncludeParamStrInParamsStr(AnsiUpperCase(aDS.FieldByName('GroupName').AsString), AnsiUpperCase(VarToStr(aSecurityContext[tmplI])), ';') then begin
            Break;//Запись относится к текущему юзеру.
          end;
        end;
      end else begin//Не тот Deny
        tmplI:=ivHB+1;//Устанавливаю что текущая запись не относится к текущему юзеру.
      end;
      if tmplI<=ivHB then begin
        if (aDS.FieldByName('IdPTask').IsNull)Or(aDS.FieldByName('IdPTask').AsInteger=-1)
         Or(aDS.FieldByName('IdPTask').AsInteger=Integer(_PTask)) then begin//Запись пустая, значит она относится ко всем юзерам.
         Result:=True;//т.е. есть право на эту команду и на эту таблицу
         Exit;
        end;
      end;
      aDS.Next;
    end;//while
  end;
begin
  Internallock;
  try
    try
      if Not CDSPT.Active then raise exception.create('CDSPT is not active.');//Беру размерность SecurityContext.
      if (VarType(aSecurityContext) and varArray)=varArray then begin//Есть права
        ivLB:=VarArrayLowBound(aSecurityContext, 1);
        ivHB:=VarArrayHighBound(aSecurityContext, 1);
        blSCEmpty:=False;
      end else begin//Нет прав
        blSCEmpty:=True;
        raise exception.create('Список групп не определен(SecurityContext). Обратитесь к разработчику.');
      end;
      if CheckSecurityGroup(CDSPT, aPTask, 1)= True then begin
        raise exception.create('Нет прав на PTask='''+IntToStr(Integer(aPTask))+''', User='''+aSecurityContext[0]+'''(Deny).');
      end;
      if CheckSecurityGroup(CDSPT, aPTask, 0)= False then begin
        raise exception.create('Нет прав на PTask='''+IntToStr(Integer(aPTask))+''', User='''+aSecurityContext[0]+'''(Access).');
      end;
    except on e:exception Do begin
      e.message:='Безопасность PTask: '+e.message;
      raise;
    end;end;
  finally
    Internalunlock;
  end;
end;

{function TAppSecurity.InternalGetITray:ITray;
begin
  if not assigned(FTray) then FTray:=cnTray;
  result:=FTray;
  if not assigned(result) then raise exception.create('FTray is not assigned.');
end;}

function TAppSecurity.InternalGetIAppMessage:IAppMessage;
begin
  if not assigned(FAppMessage) then InternalGetITray.Query(IAppMessage, FAppMessage);
  result:=FAppMessage;
end;

end.
