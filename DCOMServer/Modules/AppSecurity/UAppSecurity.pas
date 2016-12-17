//Copyright � 2000-2003 by Dmitry A. Sokolyuk
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
    Result:=False;//��������, ���� ������ SecuretyContext, �� ������ ��������� ��� ������
    if blSCEmpty then Exit;//--
    aDS.First;//�������������� �� ������
    While aDS.eof=false do begin // ���� �� ��������//�������� ��������� �� ������� ������ � �������� �����.
      if aDeny=aDS.FieldByName('Deny').AsInteger then begin//Deny ���.//SecurityContext �� ������
        For tmplI:=ivLB To ivHB do begin
          if aDS.FieldByName('GroupName').IsNull then begin
           Break;//������ ������, ������ ��� ��������� �� ���� ������.
          end;
          if CheckIncludeParamStrInParamsStr(AnsiUpperCase(aDS.FieldByName('GroupName').AsString), AnsiUpperCase(VarToStr(aSecurityContext[tmplI])), ';') then begin
            Break;//������ ��������� � �������� �����.
          end;
        end;
      end else begin//�� ��� Deny
        tmplI:=ivHB+1;//������������ ��� ������� ������ �� ��������� � �������� �����.
      end;
      if tmplI<=ivHB then begin//������������� ������ ��������� � �������� �����.
        tmpTableName:=AnsiUpperCase(aDS.FieldByName('TableName').AsString);
        tmpCommandName:=AnsiUpperCase(aDS.FieldByName('CommandName').AsString);//������� ������ ��������� � �������� �����.//TableName
        if aDS.FieldByName('TableName').IsNull then begin//���� ����� �� ����� �� ������� ��� ���� ������
          AllTableName:=True;
        end else begin//��� ����� �� ������� ��� ���� ������
          AllTableName:=False;
        end;//CommandName
        if aDS.FieldByName('CommandName').IsNull then begin//���� ����� �� ��� �������
          AllCommandName:=True;
        end else begin//��� ����� �� ��� �������
          AllCommandName:=False;
        end;//-- ���������� --------------------
        if AllTableName then begin//���� ����� �� ��� �������
          if AllCommandName then begin//���� ����� �� ��� �������
            Result:=True;
            Exit;
          end else begin//��� ����� �� ��� �������
            if aSQLCommandType in ParamsStrToSQLCommands(tmpCommandName) then begin
              Result:=True;//�.�. ���� ����� �� ��� ������� � �� ��� �������
              Exit;
            end;
          end;
        end else begin//��� ����� �� ��� �������
          if AllCommandName then begin//���� ����� �� ��� �������
            if CheckIncludeParamStrInParamsStr(tmpTableName, aTableName, ';') then begin
              Result:=True;//�.�. ���� ����� �� ��� ������� � �� ��� �������
              Exit;
            end;
          end else begin//��� ����� �� ��� �������
            if  (CheckIncludeParamStrInParamsStr(tmpTableName, aTableName, ';'))And
                (aSQLCommandType in ParamsStrToSQLCommands(tmpCommandName)) then Begin
              Result:=True;//�.�. ���� ����� �� ��� ������� � �� ��� �������
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
      if not CDSLDB.Active then raise exception.create('FCDSLDB is not active.');//���� ����������� aTables.
      if VarIsArray(aTables) then begin//���� �������
        ivtLB:=VarArrayLowBound(aTables, 1);
        ivtHB:=VarArrayHighBound(aTables, 1);
        blTNEmpty:=False;
      end else begin//��� ������//blTNEmpty:=True;
{$IfDef TruncatedSecurity}
        InternalGetIAppMessage.ITMessAdd(Now, now, IServerProperties(cnTray.Query(IServerProperties)).ServerUserName, 'TDataCase', 'ITCheckSecurityLDB(������������): ������ ������ � SQL ������� �� ���������. ���������� � ������������.', mecApp, mesWarning);
        Exit;
{$Else}
        raise exception.createFmtHelp(cserInternalError, ['������ ������ � SQL ������� �� ���������. ���������� � ������������.'], cnerInternalError);
{$Endif}
      end;//���� ����������� SecurityContext.
      if VarIsArray(aSecurityContext) then begin//���� �����
        ivLB:=VarArrayLowBound(aSecurityContext, 1);
        ivHB:=VarArrayHighBound(aSecurityContext, 1);
        blSCEmpty:=False;
      end else begin//��� ����//blSCEmpty:=True;
{$IfDef TruncatedSecurity}
        InternalGetIAppMessage.ITMessAdd(Now, now, IServerProperties(cnTray.Query(IServerProperties)).ServerUserName, 'TDataCase', 'ITCheckSecurityLDB(������������): ������ ����� �� ���������(SecurityContext). ���������� � ������������.', mecApp, mesWarning);
        Exit;
{$Else}
        raise exception.createFmtHelp(cserInternalError, ['������ ����� �� ���������(SecurityContext). ���������� � ������������.'], cnerInternalError);
{$Endif}
      end;//�������� Deny//���� �������//���� �����
      if not blTNEmpty then begin
        for tmpI:=ivtLB To ivtHB do begin// ����� ���� � �������� ������, ������� ����� ������������ ����.
          if CheckSecurityGroup(CDSLDB, TSQLCommandType(aTables[tmpI][0]), AnsiUpperCase(VarToStr(aTables[tmpI][1])), 1)= True then begin
            //raise exception.create('��� ���� �� Command='''+SQLCommandToStr(TSQLCommandType(aTables[tmpI][0]))+''', Table='''+VarToStr(aTables[tmpI][1])+''', User='''+aSecurityContext[0]+'''(Deny).');
            raise exception.createFmtHelp(cserAccessDenied, ['Command='''+SQLCommandToStr(TSQLCommandType(aTables[tmpI][0]))+''', Table='''+VarToStr(aTables[tmpI][1])+''', User='''+aSecurityContext[0]+'''(Deny).'], cnerAccessDenied);
          end;
        end;//For
      end;//���� �������//���� �����
      if not blTNEmpty then begin
        for tmpI:=ivtLB To ivtHB do begin//����� ���� � �������� ������, ������� ����� ������������ ����.
          if CheckSecurityGroup(CDSLDB, TSQLCommandType(aTables[tmpI][0]), AnsiUpperCase(VarToStr(aTables[tmpI][1])), 0)= False then begin
            //raise exception.create('��� ���� �� Command='''+SQLCommandToStr(TSQLCommandType(aTables[tmpI][0]))+''', Table='''+VarToStr(aTables[tmpI][1])+''', User='''+aSecurityContext[0]+'''(Access).');
            raise exception.createFmtHelp(cserAccessDenied, ['Command='''+SQLCommandToStr(TSQLCommandType(aTables[tmpI][0]))+''', Table='''+VarToStr(aTables[tmpI][1])+''', User='''+aSecurityContext[0]+'''(Access).'], cnerAccessDenied);
          end;
        end;//For
      end;
    except on e:exception do begin
      e.message:='������������ LDB: '+e.message;
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
    Result:=False;//��������, ���� ������ SecuretyContext, �� ������ ��������� ��� ������
    if blSCEmpty then Exit;//--
    aDS.First;//�������������� �� ������
    While aDS.eof=false do begin//���� �� ��������//�������� ��������� �� ������� ������ � �������� �����.
      if aDeny=aDS.FieldByName('Deny').AsInteger then begin//Deny ���.//SecurityContext �� ������
        For tmplI:=ivLB To ivHB do begin
          if aDS.FieldByName('GroupName').IsNull then begin
            Break;//������ ������, ������ ��� ��������� �� ���� ������.
          end;
          //If UpperCase(aDS.FieldByName('GroupName').AsString)=UpperCase(VarToStr(aSecurityContext[tmplI])) then begin
          if CheckIncludeParamStrInParamsStr(AnsiUpperCase(aDS.FieldByName('GroupName').AsString), AnsiUpperCase(VarToStr(aSecurityContext[tmplI])), ';') then begin
            Break;//������ ��������� � �������� �����.
          end;
        end;
      end else begin//�� ��� Deny
        tmplI:=ivHB+1;//������������ ��� ������� ������ �� ��������� � �������� �����.
      end;
      if tmplI<=ivHB then begin
        if (aDS.FieldByName('IdMTask').IsNull)Or(aDS.FieldByName('IdMTask').AsInteger=-1)
         Or(aDS.FieldByName('IdMTask').AsInteger=Integer(_MTask)) then begin//������ ������, ������ ��� ��������� �� ���� ������.
         Result:=True;//�.�. ���� ����� �� ��� ������� � �� ��� �������
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
      if Not CDSMT.Active then raise exception.create('FCDSMT is not active.');//���� ����������� SecurityContext.
      if (VarType(aSecurityContext) and varArray)=varArray then begin//���� �����
        ivLB:=VarArrayLowBound(aSecurityContext, 1);
        ivHB:=VarArrayHighBound(aSecurityContext, 1);
        blSCEmpty:=False;
      end else begin//��� ����
        blSCEmpty:=True;
        raise exception.create('������ ����� �� ���������(SecurityContext). ���������� � ������������.');
      end;
      if CheckSecurityGroup(CDSMT, aMTask, 1)= True then begin
        raise exception.create('��� ���� �� MTask='''+MTaskToStr(aMTask)+''', User='''+aSecurityContext[0]+'''(Deny).');
      end;
      if CheckSecurityGroup(CDSMT, aMTask, 0)= False then begin
        raise exception.create('��� ���� �� MTask='''+MTaskToStr(aMTask)+''', User='''+aSecurityContext[0]+'''(Access).');
      end;
    except on e:exception Do begin
      e.message:='������������ MTask: '+e.message;
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
    Result:=False;//��������, ���� ������ SecuretyContext, �� ������ ��������� ��� ������
    if blSCEmpty then Exit;//--
    aDS.First;//�������������� �� ������
    While aDS.eof=false do begin//���� �� ��������//�������� ��������� �� ������� ������ � �������� �����.
      if aDeny=aDS.FieldByName('Deny').AsInteger then begin//Deny ���.//SecurityContext �� ������
        For tmplI:=ivLB To ivHB do begin
          if aDS.FieldByName('GroupName').IsNull then begin//������ ������, ������ ��� ��������� �� ���� ������.
            Break;
          end;
          //If UpperCase(aDS.FieldByName('GroupName').AsString)=UpperCase(VarToStr(aSecurityContext[tmplI])) then begin
          if CheckIncludeParamStrInParamsStr(AnsiUpperCase(aDS.FieldByName('GroupName').AsString), AnsiUpperCase(VarToStr(aSecurityContext[tmplI])), ';') then begin
            Break;//������ ��������� � �������� �����.
          end;
        end;
      end else begin//�� ��� Deny
        tmplI:=ivHB+1;//������������ ��� ������� ������ �� ��������� � �������� �����.
      end;
      if tmplI<=ivHB then begin
        if (aDS.FieldByName('IdPTask').IsNull)Or(aDS.FieldByName('IdPTask').AsInteger=-1)
         Or(aDS.FieldByName('IdPTask').AsInteger=Integer(_PTask)) then begin//������ ������, ������ ��� ��������� �� ���� ������.
         Result:=True;//�.�. ���� ����� �� ��� ������� � �� ��� �������
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
      if Not CDSPT.Active then raise exception.create('CDSPT is not active.');//���� ����������� SecurityContext.
      if (VarType(aSecurityContext) and varArray)=varArray then begin//���� �����
        ivLB:=VarArrayLowBound(aSecurityContext, 1);
        ivHB:=VarArrayHighBound(aSecurityContext, 1);
        blSCEmpty:=False;
      end else begin//��� ����
        blSCEmpty:=True;
        raise exception.create('������ ����� �� ���������(SecurityContext). ���������� � ������������.');
      end;
      if CheckSecurityGroup(CDSPT, aPTask, 1)= True then begin
        raise exception.create('��� ���� �� PTask='''+IntToStr(Integer(aPTask))+''', User='''+aSecurityContext[0]+'''(Deny).');
      end;
      if CheckSecurityGroup(CDSPT, aPTask, 0)= False then begin
        raise exception.create('��� ���� �� PTask='''+IntToStr(Integer(aPTask))+''', User='''+aSecurityContext[0]+'''(Access).');
      end;
    except on e:exception Do begin
      e.message:='������������ PTask: '+e.message;
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
