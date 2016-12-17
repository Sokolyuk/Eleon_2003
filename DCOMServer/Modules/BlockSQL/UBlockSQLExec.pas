//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UBlockSQLExec;

interface
  uses UBlockSQLResultManage, UBlockSQLTaskManage, UAppMessageTypes, UCallerTypes;
Type
  TBlockSQLExec=class
  private
    FData:Variant;
    FCallerAction:ICallerAction;
    FBuildResult, FCheckSecuretyLDB, FTableAutoLock:Boolean;
    FivBLB, FivBHB:Integer;
    FmecLastError:TMessageClass;
    FBlockSQLResultManage:TBlockSQLResultManage;
    FCountBlock, FCountWakeupBlock, FCountSleepBlock:Integer;
    FBlockSQLTaskManage:TBlockSQLTaskManage;
    Procedure InternalCheckData(Const aData:Variant);
    Procedure Set_Data(Const Value:Variant);
    Function Get_mecLastError:TMessageClass;
    Function Get_Result:Variant;
    Function Get_NextTimeData:Variant;
    Function Get_NextTimeWakeup:comp;
    Function Get_NextTimeRequire:Boolean;
    Procedure Set_CallerAction(Value:ICallerAction);
  public
    constructor Create; //override;
    destructor Destroy; override;
    procedure Exec;
    Property Data:Variant read FData write Set_Data;
    Property CallerAction:ICallerAction read FCallerAction write Set_CallerAction;
    Property BuildResult:Boolean read FBuildResult;
    Property Result:Variant read Get_Result;
    Property CheckSecuretyLDB:Boolean read FCheckSecuretyLDB write FCheckSecuretyLDB;
    Property TableAutoLock:Boolean read FTableAutoLock write FTableAutoLock;
    Property mecLastError:TMessageClass read Get_mecLastError;
    Property CountBlock:Integer read FCountBlock;
    Property CountWakeupBlock:Integer read FCountWakeupBlock;
    Property CountSleepBlock:Integer read FCountSleepBlock;
    Property NextTimeWakeup:Comp read Get_NextTimeWakeup;
    Property NextTimeData:Variant read Get_NextTimeData;
    Property NextTimeRequire:Boolean read Get_NextTimeRequire;
  end;

implementation
  Uses Sysutils, USQLParser, USQLParserTypes, UStringParam, ULocalDataBaseTypes, {UConsts, }UAppSecurityTypes, UTrayConsts,
       ULocalDataBase, UASMConsts, UServerConsts, Variants, UTrayTypes;
constructor TBlockSQLExec.Create;
begin
  FData:=Unassigned;
  FCallerAction:=nil;
  FBuildResult:=false;
  FCheckSecuretyLDB:=true;
  FTableAutoLock:=true;
  FivBLB:=-1;
  FivBHB:=-1;
  FmecLastError:=mecApp;
  FBlockSQLResultManage:=TBlockSQLResultManage.Create;
  FCountBlock:=0;
  FCountWakeupBlock:=0;
  FCountSleepBlock:=0;
  FBlockSQLTaskManage:=TBlockSQLTaskManage.create;
  Inherited Create;
end;

destructor TBlockSQLExec.Destroy;
begin
  try VarClear(FData);            except end;
  try FCallerAction:=nil; except end;
  try FBlockSQLResultManage.Free; except end;
  try FBlockSQLTaskManage.Free;   except end;
  Inherited Destroy;
end;

Function TBlockSQLExec.Get_mecLastError:TMessageClass;
begin
  Result:=FmecLastError;
  FmecLastError:=mecApp;
end;

Function TBlockSQLExec.Get_Result:Variant;
begin
  Result:=FBlockSQLResultManage.Result;
end;

Function  TBlockSQLExec.Get_NextTimeData:Variant;
begin
  Result:=FBlockSQLTaskManage.Data;
end;

Function  TBlockSQLExec.Get_NextTimeWakeup:Comp;
begin
  Result:=FBlockSQLTaskManage.NextTimeWakeup;
end;

Function  TBlockSQLExec.Get_NextTimeRequire:Boolean;
begin
  Result:=FBlockSQLTaskManage.NextTimeRequire;
end;

Procedure TBlockSQLExec.Set_CallerAction(Value:ICallerAction);
begin
  FCallerAction:=Value;
end;

Procedure TBlockSQLExec.InternalCheckData(Const aData:Variant);
begin
  If VarArrayDimCount(aData)<>1 Then Raise Exception.Create('DimCount<>1.');
  //размерность блоков
  If VarIsEmpty(aData) Then begin
    FivBLB:=-1;
    FivBHB:=-1;
  end else begin
    FivBLB:=VarArrayLowBound(aData, 1);
    FivBHB:=VarArrayHighBound(aData, 1);
  end;
end;

Procedure TBlockSQLExec.Set_Data(Const Value:Variant);
begin
  InternalCheckData(Value);
  FData:=Value;
  FBuildResult:=False;
  FCountWakeupBlock:=0;
  FCountSleepBlock:=0;
  If VarIsEmpty(Value) Then FCountBlock:=0 else FCountBlock:=FivBHB-FivBLB+1;
  FBlockSQLTaskManage.Clear;
end;

procedure TBlockSQLExec.Exec;
  Var iI, iII, iI2, ivLB, ivHB:Integer;
      iTables:Variant;
      tmpSQLCommandParser:TSQLCommandParser;
      iRequireUnlocking, iRequireTran:boolean;
      istTab:AnsiString;
      tmpStringParam:TStringParam;
      tmpLDB:ILocalDataBase;
      tmpRecaff:Integer;
      iRequireOpenSQL, iRequireSQLParams:boolean;
      iSQL:AnsiString;
      tmpOleVariant, tmpOleV_Cur:OleVariant;
      iBlockId, iEscortData:Variant;
      iSqlId:Integer;
      iWakeup, iNow:TCompTime;
      ibExceptInCurrentBlockExec, ibExceptInCurrentBlockCheck:boolean;
      iArraySqlId:Variant;
      // for exception
      tmpSt:AnsiString;
      tmpI:Integer;
      st:ansistring;
      iStartTime, iStartSQLTime:TDateTime;
begin
  iNow.ofComp:=TimeStampToMSecs(DateTimeToTimeStamp(Now));
  iTables:=Unassigned;
  tmpOleVariant:=Unassigned;
  tmpOleV_Cur:=Unassigned;
  iArraySqlId:=Unassigned;
  try
    Try
      If VarIsEmpty(FData) Then Raise Exception.Create('Нет данных.');
      //Данные есть
      FBlockSQLResultManage.Clear; // Очищаю результат
      tmpLDB:=TLocalDataBase.Create{(GL_DataCase)};
      try
        tmpLDB.CallerAction:=FCallerAction;
        //Настраиваю LDB
        tmpLDB.CheckSecuretyLDB:=False; // Security проверяется тут
        tmpLDB.TableAutoLock:=false;    // TableAutoLock выполняется тут
        // ..
{Block} For iI:=FivBLB to FivBHB do begin
          // Цыкл блоков комманд
          If ((VarType(FData[iI])and varArray)<>varArray)Or((VarType(FData[iI][1])and varArray)<>varArray) Then Raise Exception.Create('Неправильный формат. Блок не массив.');
          // Проверяю время выполнения пакета
 {Time}   If Not VarIsEmpty(FData[iI][2]) then begin
            // Врямя выполнения указано, проверяю настало или нет
            iWakeup.ofIntLow:=FData[iI][2][0];
            iWakeup.ofIntHigh:=FData[iI][2][1];
            If iNow.ofInt64<iWakeup.ofInt64 Then begin
              // Время выполнения этого блока еще не настало
              Inc(FCountSleepBlock);
              FBlockSQLTaskManage.AddBlockToTask(FData[iI], true, iWakeup.OfComp);
              Continue;
            end;
          end else begin
            // Время не указано выполняю немедленно
 {Time}   end;
          iStartTime:=Now;
          iBlockId:=FData[iI][0];
          iEscortData:=FData[iI][3];
          Inc(FCountWakeupBlock);
          FBuildResult:=True;  // Говорю что можно будет брать результат.
          ibExceptInCurrentBlockCheck:=False;// для того чтобы передать IDSQL из Check в Exception
          iSQLId:=-1; // от варнинга, ушел от варнинга через ibExceptInCurrentBlockCheck
          VarClear(iTables); // Чищу таблицу локов и аксессов.
          Try
            ivLB:=VarArrayLowBound(FData[iI][1], 1);
            ivHB:=VarArrayHighBound(FData[iI][1], 1);

            //FCallerAction.ITMessAdd(iStartSQLTime, Now, 'SQLParser check', 'cnCheckSecuretyLDB='+IntToStr(integer(cnCheckSecuretyLDB)) + ' cnTableAutoLock=' + IntToStr(Integer(cnTableAutoLock)), mecApp, mesWarning);
            //FCallerAction.ITMessAdd(iStartSQLTime, Now, 'SQLParser check', 'CheckSecuretyLDB='+IntToStr(integer(cnCheckSecuretyLDB And FCheckSecuretyLDB)) + ' TableAutoLock=' + IntToStr(Integer(cnTableAutoLock And FTableAutoLock)), mecApp, mesWarning);
            //FCallerAction.ITMessAdd(iStartSQLTime, Now, 'SQLParser check', IntToStr(integer((cnCheckSecuretyLDB And FCheckSecuretyLDB) or (cnTableAutoLock And FTableAutoLock))), mecApp, mesWarning);

 {SQLParser}If (cnCheckSecuretyLDB And FCheckSecuretyLDB) or (cnTableAutoLock And FTableAutoLock) Then begin
              // Получаю список таблиц к которым будут обращения в этом блоке

            //FCallerAction.ITMessAdd(iStartSQLTime, Now, 'SQLParser check', '!!', mecApp, mesWarning);

              Try
                tmpSQLCommandParser:=TSQLCommandParser.Create;
                Try
                  For iII:=ivLB to ivHB do begin
                    // нужно "парсить"
                    // Определяю способ SQL запроса
                    If (VarType(FData[iI][1][iII][1])and varArray)=varArray then begin
                      // полный способ запроса
                      iSQL:=VarToStr(FData[iI][1][iII][1][0]);
                    end else begin
                      // упрощенный, требуется выполнить Exec.
                      iSQL:=VarToStr(FData[iI][1][iII][1]);
                    end;
                    // для того чтобы передать IDSQL из Check в Exception
                    iSqlId:=FData[iI][1][iII][0];
                    Try
                      tmpSQLCommandParser.SQLCommandToTableName(iSQL, iTables);
                    except
                      ibExceptInCurrentBlockCheck:=True; // для того чтобы передать IDSQL из Check в Exception
                      raise;
                    end;
                  end;
                finally
                  tmpSQLCommandParser.Free;
                end;
              except on e:exception do begin
                e.message:='BlockSQL.SQLParser: '+e.message;
                raise;
              end;end;
 {SQLParser}end;
            // Проверяю права на выполнение комманд
 {Securety} if cnCheckSecuretyLDB And FCheckSecuretyLDB Then begin
              try
                IAppSecurity(cnTray.Query(IAppSecurity)).ITCheckSecurityLDB(iTables, FCallerAction.SecurityContext);
              except
                FmecLastError:=mecSecurity;
                raise;
              end;
 {Securety} end;
            // Лочу
            iRequireUnlocking:=False;
 {Lock}     If cnTableAutoLock And FTableAutoLock then begin
              If (VarType(iTables)And varArray)=varArray Then begin
                // есть таблицы
                istTab:='';
                For iI2:=VarArrayLowBound(iTables, 1) to VarArrayHighBound(iTables, 1) do begin
                  Case TSQLCommandType(Integer(iTables[iI2][0])) of
                    {0}sctSelect, {4}sctBeginTran, {5}sctCommitTran, {6}sctRollbackTran,//Ничего не лочу
                    {7}sctExec, {8}sctCreate, {9}sctAlter, {10}sctDrop, {11}sctTruncate:;
                    {1}sctInsert, {2}sctDelete, {3}sctUpdate:begin
                      // Эти комманды требуют лок
                      If Pos(UpperCase(VarToStr(iTables[iI2][1])), UpperCase(istTab))<1 then begin
                        // такой таблицы еще нет в списке для лочиния
                        istTab:=istTab+'+'+UpperCase(VarToStr(iTables[iI2][1]))+','; // формирую запрос для лока
                      end;
                    end;
                  Else
                    Raise Exception.Create('Внутренняя ошибка. TSQLCommandType(iTables[iI2][0])='+inttostr(Integer(TSQLCommandType(iTables[iI2][0])))+'.');
                  End;
                end;
                If istTab<>'' Then begin
                  // есть таблицы которые надо лочить
                  SetLength(istTab, Length(istTab)-1); // убираю последнюю запятую, без транзакции
                  // Пробую залочить
                  tmpLDB.WaitForLockList(istTab, True, 15000); // таймаут 15 сек, по истечении raise.
                  // установлен лок
                  iRequireUnlocking:=True; // ставлю флаг что требуется разлокирование
                end;
              end;
 {Lock}     end;
            try
              iStartSQLTime:=Now;
              // Безопастность проверина, таблицы залочины
              // Выполняю блок комманд
              iRequireTran:=Boolean(((ivHB-ivLB)>0{не одна комманда})And(istTab<>''{есть локи(т.е. изменения базы)}));
              If iRequireTran Then tmpLDB.ExecSQL('BEGIN TRANSACTION');
              ibExceptInCurrentBlockExec:=False;
              iSQLId:=-1; // от варнинга, ушел от варнинга через ibExceptInCurrentBlockExec
              Try
 {CurrentBlock} For iII:=ivLB to ivHB do begin
                  Try
                    iSqlId:=FData[iI][1][iII][0];
                    // Определяю способ SQL запроса
        {GetSQL}    If (VarType(FData[iI][1][iII][1])and varArray)=varArray then begin
                      // полный способ запроса
                      iRequireOpenSQL:=Boolean(FData[iI][1][iII][1][1]);
                      iSQL:=VarToStr(FData[iI][1][iII][1][0]);
                    end else begin
                      // упрощенный, требуется выполнить Exec.
                      iRequireOpenSQL:=False;
                      iSQL:=VarToStr(FData[iI][1][iII][1]);
        {GetSQL}    end;
                    // Определяю способ применения параметров(Params) для SQL
        {GetParams} If VarIsEmpty(FData[iI][1][iII][2]) Then begin
                      // упрощенный, нет входных и не требуются выходные параметры.
                      iRequireSQLParams:=False;
                      tmpOleVariant:=Unassigned;
                    end else begin
                      // полный способ запроса
                      iRequireSQLParams:=Boolean(FData[iI][1][iII][2][1]);
                      tmpOleVariant:=FData[iI][1][iII][2][0];
        {GetParams} end;
                    // Выполняю запрос
        {Exec}      If iRequireOpenSQL then begin
                      // Требуется Open
                      tmpOleV_Cur:=tmpLDB.OpenSQL(iSQL, tmpOleVariant, tmpRecaff);
                    end else begin
                      // Требуется Exec
                      tmpRecaff:=tmpLDB.ExecSQL(iSQL, tmpOleVariant);
                      tmpOleV_Cur:=Unassigned;
        {Exec}      end;
                    // tmpOleVariant >> Res
                    // tmpRecaff >> Res
                    // If iRequireSQLParams{флаг указывает что требуются выходные параметры} then tmpOleVariant >> Res
                    If Not iRequireSQLParams Then {Не требуются выходные параметры}VarClear(tmpOleVariant);
                    FBlockSQLResultManage.AddOkToCurrentBlock(iSqlId, tmpRecaff, tmpOleVariant, tmpOleV_Cur);
                  Except
                    ibExceptInCurrentBlockExec:=True;
                    raise;
                  End;
 {CurrentBlock} end;
                If iRequireTran Then tmpLDB.ExecSQL('COMMIT TRANSACTION');
                FBlockSQLResultManage.MoveOkCurrentBlockToResult(iBlockId, iEscortData);
              Except
                On E:Exception Do Begin
                  try If iRequireTran Then tmpLDB.ExecSQL('ROLLBACK TRANSACTION'); except end;
                  FBlockSQLResultManage.ClearCurrentBlock;
                  // Создаю iArraySqlId(полный список SQLId участвующих в блоке)
                  try
                    iArraySqlId:=VarArrayCreate([ivLB,ivHB], varInteger);
                    For iII:=ivLB to ivHB do begin
                      iArraySqlId[iII]:=FData[iI][1][iII][0];
                    end;
                  except
                    iArraySqlId:=Unassigned;
                  end;
                  // Помещяю ошибку в результат
                  If ibExceptInCurrentBlockExec Then begin
                    FBlockSQLResultManage.AddErrorBlockSQLToResult(iBlockId, iEscortData, iSQLId, 'ExecBlock: '+E.Message, iArraySqlId);
                  end else begin
                    FBlockSQLResultManage.AddErrorBlockToResult(iBlockId, iEscortData, 'NearExecBlock: '+E.Message, iArraySqlId);
                  end;
                  // Деляю сообщение в журнал
{Err to log}      Try
                    tmpSt:='';
                    If VarIsArray(iArraySqlId) then begin
                      For tmpI:=varArrayLowBound(iArraySqlId, 1) to VarArrayHighBound(iArraySqlId, 1) do begin
                        tmpSt:=tmpSt+VarToStr(iArraySqlId[tmpI])+',';
                      end;
                      If tmpSt<>'' Then SetLength(tmpSt, Length(tmpSt)-1) else tmpSt:='SqlId no available.';
                    end else tmpSt:='iArraySqlId is not array.';
                    FCallerAction.ITMessAdd(iStartSQLTime, Now, 'TBlockSQLExec.Exec', '(SQLID='+tmpSt+'): '+e.message, mecApp, mesError);
                    //If VarIsArray(FSecurityContext) then begin
                    //  IAppMessage(cnTray.Query(IAppMessage)).ITMessAdd(iStartSQLTime, Now, FSecurityContext[0], 'TBlockSQLExec.Exec', '(SQLID='+tmpSt+'): '+e.message, mecApp, mesError);
                    //end else Raise Exception.Create(e.message);
                    tmpSt:='';
                  except
                    try tmpSt:=''; IAppMessage(cnTray.Query(IAppMessage)).ITMessAdd(iStartSQLTime, Now, '', 'TBlockSQLExec.Exec', e.message, mecApp, mesError); except end;
{Err to log}      end;
                end;
              End;
            finally
 {UnLock}     if iRequireUnlocking then begin
                // Преобразую строку из '+' в '-'
                tmpStringParam:=TStringParam.Create;
                Try
                  tmpStringParam.stTabCMD:=stTabCMD;
                  tmpStringParam.stAddCMD:=stAddCMD;
                  tmpStringParam.stDelCMD:=stDelCMD;
                  tmpStringParam.StringParam:=istTab;
                  tmpStringParam.GetParamMode:=cmAdd;
                  istTab:='';
                  For iI2:=1 to tmpStringParam.CountParam do begin
                    istTab:=istTab+'-'+tmpStringParam.GetParam(iI2)+',';
                  end;
                finally
                  tmpStringParam.Free;
                end;
                SetLength(istTab, Length(istTab)-1); // убираю последнюю запятую
                // Раззалочиваю
                tmpLDB.WaitForLockList(istTab, True, 0);
                istTab:='';
 {UnLock}     end;
            end;
          Except
            On E:Exception do begin
              FBlockSQLResultManage.ClearCurrentBlock;
              // Создаю iArraySqlId(полный список SQLId участвующих в блоке)
              try
                ivLB:=VarArrayLowBound(FData[iI][1], 1);
                ivHB:=VarArrayHighBound(FData[iI][1], 1);
                iArraySqlId:=VarArrayCreate([ivLB,ivHB], varInteger);
                For iII:=ivLB to ivHB do begin
                  iArraySqlId[iII]:=FData[iI][1][iII][0];
                end;
              except
                iArraySqlId:=Unassigned;
              end;
              // для того чтобы передать IDSQL из Check в Exception
              If ibExceptInCurrentBlockCheck Then begin
                FBlockSQLResultManage.AddErrorBlockSQLToResult(iBlockId, iEscortData, iSQLId, 'CheckBlock: '+E.Message, iArraySqlId);
              end else begin
                FBlockSQLResultManage.AddErrorBlockToResult(iBlockId, iEscortData, 'CheckBlock: '+E.Message, iArraySqlId);
              end;
              // Деляю сообщение в журнал
{Err to log}  Try
                tmpSt:='';
                If VarIsArray(iArraySqlId) then begin
                  For tmpI:=varArrayLowBound(iArraySqlId, 1) to VarArrayHighBound(iArraySqlId, 1) do begin
                    tmpSt:=tmpSt+VarToStr(iArraySqlId[tmpI])+',';
                end;
                  If tmpSt<>'' Then SetLength(tmpSt, Length(tmpSt)-1) else tmpSt:='SqlId no available.';
                end else tmpSt:='iArraySqlId is not array.';
                FCallerAction.ITMessAdd(iStartTime, Now, 'TBlockSQLExec.Exec', '(SQLID='+tmpSt+'): '+e.message, mecApp, mesError);
                //If VarIsArray(FSecurityContext) then begin
                //  IAppMessage(cnTray.Query(IAppMessage)).ITMessAdd(iStartTime, Now, FSecurityContext[0], 'TBlockSQLExec.Exec', '(SQLID='+tmpSt+'): '+e.message, mecApp, mesError);
                //end else Raise Exception.Create(e.message);
                tmpSt:='';
              except
                try tmpSt:=''; IAppMessage(cnTray.Query(IAppMessage)).ITMessAdd(iStartTime, Now, '', 'TBlockSQLExec.Exec', e.message, mecApp, mesError); except end;
{Err to log}  end;
            end;
          End;
{Block} end;
      finally
        tmpLDB:=Nil;
      end;
    Except
      On E:Exception Do Begin
        Raise Exception.Create('TBlockSQLExec.Exec: '+E.Message);
      End;
    End;
  finally
    VarClear(iTables);
    VarClear(tmpOleVariant);
    VarClear(tmpOleV_Cur);
    VarClear(iArraySqlId);
    VarClear(iEscortData);
    VarClear(iBlockId);
  end;
end;

end.
