//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UCommandPack;

interface
  Uses UPackEventsTypes, UADMTypes, UPD, UPackTypes, UCallerTypes, UPackCPRTypes{, UManageCPR1};
Type
  TCommandPack=Class(TObject)
  Private
    FOwnerPD:TPD;
    FCP:Variant;
    FChecket:boolean;
    FUsedRouteParams:boolean;
    FBuildResult:boolean;
    FVersion:Integer;
    FProtocol:Integer;
    FCPID:Variant;
    FivLB, FivHB:Integer;
    FCallerAction:ICallerAction;
    FTitlePoint:AnsiString;
    FOnReceiveCPT1:TReceiveCPT1Event;
    FOnCheckSecurityPTask:TCheckSecurityPTaskEvent;
    FOnReceiveCPT1Error:TReceiveCPT1ErrorEvent;
    FOnReceiveCPR1:TReceiveCPR1Event;
    FOnReceiveCPR1Error:TReceiveCPR1ErrorEvent;
    FStartTime:TDateTime;
    Function InternalExecuteCPT1:Variant;
    Procedure InternalExecuteCPR1;
    Procedure InternalCheckCPT1;
    Procedure InternalCheckCPR1;
    Procedure Set_Data(Const Value:Variant);
    Procedure Set_CallerAction(Value:ICallerAction);
    Function Get_PDID:Variant;
  protected
    Function InternalGetRouteParams(aPos:Integer):Variant; virtual;  
  Public
    Constructor Create;
    Destructor Destroy; override;
    Procedure CheckCP;
    Function Exec:Variant;                 // не отправляет результаты а просто выполняет пакет и возвращает результат
    Property BuildResult:boolean read FBuildResult;
    Property Data:Variant read FCP write Set_Data;
    Property CallerAction:ICallerAction read FCallerAction write Set_CallerAction;
    Property OwnerPD:TPD read FOwnerPD write FOwnerPD;
    Property TitlePoint:AnsiString read FTitlePoint write FTitlePoint;
    property ivLB:Integer read FivLB;
    property ivHB:Integer read FivHB;
    property CPID:variant read FCPID;
    Property PDID:Variant read Get_PDID;
    //Property DataCase:IDataCase{3} read FDataCase write FDataCase;
    Property StartTime:TDateTime read FStartTime;
    property UsedRouteParams:Boolean read FUsedRouteParams;
    // Events Command Pack.
    Property OnReceiveCPT1:TReceiveCPT1Event read FOnReceiveCPT1 write FOnReceiveCPT1;
    Property OnReceiveCPT1Error:TReceiveCPT1ErrorEvent read FOnReceiveCPT1Error write FOnReceiveCPT1Error;
    Property OnCheckSecurityPTask:TCheckSecurityPTaskEvent read FOnCheckSecurityPTask write FOnCheckSecurityPTask;
    Property OnReceiveCPR1:TReceiveCPR1Event read FOnReceiveCPR1 write FOnReceiveCPR1;
    Property OnReceiveCPR1Error:TReceiveCPR1ErrorEvent read FOnReceiveCPR1Error write FOnReceiveCPR1Error;
    //from protected
    procedure CheckSecurityPTask(aTask:TADMTask; aProtocolType:TProtocolType; Const aSecurityContext:Variant);virtual;
    Procedure ReceiveCPT1(aPackCPR:IPackCPR; Const aPDID:Variant; Const aCPID:Variant; aBlockID:Integer; aCPTask:TADMTask; aPos:Integer; Const aParams:Variant; Const aRouteParam:Variant); virtual;
    Procedure ReceiveCPT1Error(aPackCPR:IPackCPR; Const aPDID:Variant; Const aCPID:Variant; aBlockID:Integer; aCPTask:TADMTask; aPos:Integer; Const aMessage:AnsiString; aHelpContext:Integer; Const aRouteParam:Variant); virtual;
    Procedure ReceiveCPR1(Const aPDID:Variant; Const aCPID:Variant; aBlockID:Integer; aCPTask:TADMTask; aPos:Integer; Const aParams:Variant; Const aRouteParam:Variant); virtual;
    Procedure ReceiveCPR1Error(Const aPDID:Variant; Const aCPID:Variant; aBlockID:Integer; aCPTask:TADMTask; aPos:Integer; Const aMessage:AnsiString; aHelpContext:Integer; aResultWithError:Boolean; Const aRouteParam:Variant); virtual;
  end;

implementation
  Uses SysUtils, UPackConsts, UPackCPTTypes, UTrayConsts, UAppMessageTypes, UTypeUtils, UPackCPR
{$Ifdef DebugPack}
       , UAppMessageTypes, UTypeUtils
{$Endif}       
       , Variants;
// Command pack ----------------------------------------------------------------
Constructor TCommandPack.Create;
begin
  FStartTime:=Now;
  FCP:=Unassigned;
  FChecket:=false;
  FUsedRouteParams:=False;
  FBuildResult:=False;
  FVersion:=0;
  FProtocol:=-1;
  FCPID:={tsiNoPackID}-1;
  FivLB:=-1;
  FivHB:=-1;
  FOwnerPD:=Nil;
  FCallerAction:=Nil;
  FOnReceiveCPT1:=Nil;
  FOnReceiveCPT1Error:=Nil;
  FOnCheckSecurityPTask:=Nil;
  FOnReceiveCPR1:=Nil;
  FOnReceiveCPR1Error:=Nil;
  FTitlePoint:='<None>';
  Inherited Create;
end;

Destructor TCommandPack.Destroy;
begin
  FCP:=unassigned;
  FCallerAction:=nil;
  FTitlePoint:='';
  inherited destroy;
end;

Function TCommandPack.Get_PDID:Variant;
begin
  If assigned(FOwnerPD) Then begin   
    Result:=FOwnerPD.PDID;
  end else begin
    Result:=-1;
  end;
end;

Procedure TCommandPack.Set_Data(Const Value:Variant);
begin
  FChecket:=false;
  FUsedRouteParams:=False;
  FBuildResult:=False;
  FVersion:=0;
  FProtocol:=-1;
  FCPID:={tsiNoPackID}-1;
  FivLB:=-1;
  FivHB:=-1;
  FCP:=Value;
end;

Procedure TCommandPack.Set_CallerAction(Value:ICallerAction);
begin
  FCallerAction:=Value;
end;

Procedure TCommandPack.CheckCP;
begin
  Try
    If (VarType(FCP) and varArray)<>varArray then raise Exception.create('vCP is not array.');
    Case Integer(FCP[Protocols_ID]) of
      Integer(Protocols_CPT):begin
        Case FCP[Protocols_Ver] of
          1,2:InternalCheckCPT1;
        Else
          Raise Exception.Create('Версия CPT '+IntToStr(FCP[Protocols_Ver])+' не поддерживается.');
        end;
      end;
      Integer(Protocols_CPR):begin
        Case FCP[Protocols_Ver] of
          1,2:InternalCheckCPR1;
        Else
          Raise Exception.Create('Версия CPR '+IntToStr(FCP[Protocols_Ver])+' не поддерживается.');
        end;
      end;
    else
      raise Exception.Create('Неизвестное значение Protocols_ID='+IntToStr(FCP[Protocols_ID])+'.');
    end;
{$Ifdef DebugPack}
    FCallerAction.ITMessAdd(StartTime, now, 'CheckCP', 'Ok: '+glVarArrayToString(FCP), mecTransport , mesInformation);
{$endif}
  Except
    On E:Exception do begin
{$Ifdef DebugPack}
      FCallerAction.ITMessAdd(StartTime, now, 'CheckCP', 'Err('''+E.Message+'''): '+glVarArrayToString(FCP), mecTransport , mesError);
{$endif}
      E.Message:='TCommandPack.CheckCP: '+E.Message;
      Raise;
    end;
  End;
end;

Procedure TCommandPack.InternalCheckCPT1;
begin
  Try
    If VarArrayLowBound(FCP,1)<>{0}Protocols_ID then Raise Exception.Create('Invalid CPT low bound(<>0).');
    FProtocol:=FCP[Protocols_ID];//Беру протокол
    If FProtocol<>Integer(Protocols_CPT) then raise exception.create('Тип пакета не CPT(Command pack with tasks).');//проверяю тип пакета
    FVersion:=FCP[Protocols_Ver];//Беру версию
    Case FVersion of//Проверяю допустимые версии
      1:If VarArrayHighBound(FCP,1)<>Protocols_CPT_Count_Ver1-1 Then raise exception.create('Invalid CPT1 high bound.');
      2:If VarArrayHighBound(FCP,1)<>Protocols_CPT_Count_Ver2-1 Then raise exception.create('Invalid CPT2 high bound.');
    else raise Exception.Create('Unsupported for CPT ver='+IntToStr(FVersion)+'.');
    end;
    //проверяю соответствие типам массивов
    If (VarType(FCP[Protocols_CPT_Tsk])<>(varArray Or varInteger)) Then raise Exception.create('Неправильный формат команды (CPT_Tsk is not VarArray & VarInteger).');
    If (VarType(FCP[Protocols_CPT_Params])and varArray)<>varArray Then raise Exception.create('Неправильный формат параметров (CPT_Params is not VarArray).');
    If (VarType(FCP[Protocols_CPT_BlockID])<>(varArray Or varInteger)) Then raise Exception.create('Неправильный формат команды (CPT_BlockID is not VarArray & VarInteger).');
    //получаю диапозон списка команд
    FivLB:=VarArrayLowBound (FCP[Protocols_CPT_Tsk],1);
    FivHB:=VarArrayHighBound(FCP[Protocols_CPT_Tsk],1);
    //проверяю соответствие диапозона списка команд для всех массивов
    If (FivLB<>VarArrayLowBound(FCP[Protocols_CPT_Params],1)) Or
       (FivHB<>VarArrayHighBound(FCP[Protocols_CPT_Params],1)) Then raise Exception.create('Неправильная размерность CPT_Params & CPT_Tsk.');
    If (FivLB<>VarArrayLowBound(FCP[Protocols_CPT_BlockID],1)) Or
       (FivHB<>VarArrayHighBound(FCP[Protocols_CPT_BlockID],1)) Then raise Exception.create('Неправильная размерность CPT_BlockID & CPT_Tsk.');
    FCPID:=FCP[Protocols_CPT_CPID];//Беру Id пакета(CP).
    FUsedRouteParams:=(FVersion=2)And(VarIsArray(FCP[Protocols_CPT_RouteParams]));//Проверяю RouteParams
    If FUsedRouteParams then begin
      If (FivLB<>VarArrayLowBound(FCP[Protocols_CPT_RouteParams],1)) Or
         (FivHB<>VarArrayHighBound(FCP[Protocols_CPT_RouteParams],1)) Then raise Exception.create('Неправильная размерность CPT_RouteParams & CPT_Tsk.');
    end;
    FChecket:=true;//Теперь считается что проверка завершена и пакет коррестный
  Except On E:Exception do begin
    E.Message:='ICheckCPT1: '+E.Message;
    Raise;
  end;End;
end;

Procedure TCommandPack.InternalCheckCPR1;
begin
  Try
    If VarArrayLowBound(FCP,1)<>{0}Protocols_ID then Raise Exception.Create('Invalid CPR low bound(<>0).');
    FProtocol:=FCP[Protocols_ID];//Беру протокол
    If FProtocol<>Integer(Protocols_CPR) then raise exception.create('Тип пакета не CPR(Command pack with tasks).');//проверяю тип пакета
    FVersion:=FCP[Protocols_Ver];//Беру версию
    Case FVersion of//Проверяю допустимые версии
      1:If VarArrayHighBound(FCP,1)<>Protocols_CPR_Count_Ver1-1 Then raise exception.create('Invalid CPR1 high bound.');
      2:If VarArrayHighBound(FCP,1)<>Protocols_CPR_Count_Ver2-1 Then raise exception.create('Invalid CPR2 high bound.');
    else raise Exception.Create('Неизвестная версия протокола(Ver='+IntToStr(FVersion)+').');
    end;
    //проверяю соответствие типам массивов
    If (VarType(FCP[Protocols_CPR_Tsk])<>(varArray Or varInteger)) Then raise Exception.create('Неправильный формат команды (CPR_Tsk is not VarArray & VarInteger).');
    If (VarType(FCP[Protocols_CPR_Params]) and varArray)<>varArray Then raise Exception.create('Неправильный формат параметров (CPR_Params is not VarArray).');
    If (VarType(FCP[Protocols_CPR_BlockID])<>(varArray Or varInteger)) Then raise Exception.create('Неправильный формат команды (CPR_BlockID is not VarArray & VarInteger).');
    //получаю диапозон списка команд
    FivLB:=VarArrayLowBound (FCP[Protocols_CPR_Tsk],1);
    FivHB:=VarArrayHighBound(FCP[Protocols_CPR_Tsk],1);
    //проверяю соответствие диапозона списка команд для всех массивов
    If (FivLB<>VarArrayLowBound(FCP[Protocols_CPR_Params],1)) Or
       (FivHB<>VarArrayHighBound(FCP[Protocols_CPR_Params],1)) Then raise Exception.create('Неправильная размерность CPR_Params & CPR_Tsk.');
    If (FivLB<>VarArrayLowBound(FCP[Protocols_CPR_BlockID],1)) Or
       (FivHB<>VarArrayHighBound(FCP[Protocols_CPR_BlockID],1)) Then raise Exception.create('Неправильная размерность CPR_BlockID & CPR_Tsk.');
    //Беру Id пакета(CP).
    FCPID:=FCP[Protocols_CPR_CPID];
    FUsedRouteParams:=(FVersion=2)And(VarIsArray(FCP[Protocols_CPR_RouteParams]));//Проверяю RouteParams
    If FUsedRouteParams then begin 
      If (FivLB<>VarArrayLowBound(FCP[Protocols_CPR_RouteParams],1)) Or
         (FivHB<>VarArrayHighBound(FCP[Protocols_CPR_RouteParams],1)) Then raise Exception.create('Неправильная размерность CPR_RouteParams & CPR_Tsk.');
    end;
    //Теперь считается что проверка завершена и пакет коррестный
    FChecket:=true;
  Except On E:Exception do begin
    E.Message:='ICheckCPR1: '+E.Message;
    Raise;
  end;End;
end;

Function TCommandPack.Exec:Variant;
begin
Try
  Result:=Unassigned;
  // Проверяю и загружаю параметры пакета
  If FChecket=false Then CheckCP;
  // ..
  Case FProtocol of
    Integer(Protocols_CPT):Begin
      if Assigned(FOwnerPD) Then Begin
        FBuildResult:=not boolean((integer(FOwnerPD.Data[Protocols_PD_Options]) and integer(Protocols_PD_Options_NoResult))=Integer(Protocols_PD_Options_NoResult));
      end else begin
        FBuildResult:=True;
      end;
      Result:=InternalExecuteCPT1;
    end;
    Integer(Protocols_CPR):begin
      Result:=Unassigned;
      InternalExecuteCPR1;
    end;
  Else
    raise Exception.Create('Неизвестный протокол(ID='+IntToStr(FProtocol)+').');
  end;
Except On E:Exception do begin
  E.Message:='TCommandPack.Exec: '+E.Message;
  Raise;
end;End;
end;

Function TCommandPack.InternalGetRouteParams(aPos:Integer):Variant;
begin
  If FUsedRouteParams then begin
    Case FProtocol of
      Integer(Protocols_CPT):result:=FCP[Protocols_CPT_RouteParams][aPos];
      Integer(Protocols_CPR):result:=FCP[Protocols_CPR_RouteParams][aPos];
    end;
  end else Result:=Unassigned;
end;

Function TCommandPack.InternalExecuteCPT1:Variant;
  Var vListOfBreakedBlock, vTasks, vParams:Variant;
      blSkipCommand, blWasAnError:boolean;
      iTask:TADMTask;
      iI, iPos, iBlockID, iBB:Integer;
      tmpPackCPR:IPackCPR;
begin
Result:=Unassigned;
Try
  try
    iBlockID:=-1;//ЧТО БЫ НЕ БЫЛО ВАРНИНГОВ
    vListOfBreakedBlock:=Unassigned;
    vTasks:=FCP[Protocols_CPT_Tsk];
    vParams:=FCP[Protocols_CPT_Params];
    blWasAnError:=false;//Определяю нужен или нет результат или сообщ. о ошибке.
    tmpPackCPR:=TPackCPR.Create;
    Try
      tmpPackCPR.CPID:=FCPID;//чтобы у CPR был такой же ID как и у CPT.
      For iI:=FivLB to FivHB do begin
        iPos:=iI;
        iTask:=tskADMNone;//от варнингов
        Try//Проверяю текущая комманда должна выполняться или ее блок прерван
          blSkipCommand:=False;
          iBlockID:=FCP[Protocols_CPT_BlockID][iPos];//беру номер блока для текущ. команды
          If VarType(vListOfBreakedBlock)<>varEmpty then begin//список прерваных блоков не пустой
            For iBB:=VarArrayLowBound(vListOfBreakedBlock, 1) to VarArrayHighBound(vListOfBreakedBlock, 1) do begin
              If vListOfBreakedBlock[iBB]=iBlockID Then begin//номер блока текущей команды есть в списке прерваных блоков
                blSkipCommand:=True;
                Break;
              end;
            end;
          end;
          If blSkipCommand Then Continue;//следов. комманда пропускается.
          iTask:=vTasks[iPos];
          If Assigned(FOnCheckSecurityPTask) Then FOnCheckSecurityPTask(iTask, ptlCPT, FCallerAction.SecurityContext) else CheckSecurityPTask(iTask, ptlCPT, FCallerAction.SecurityContext);
          Case iTask of
            tskADMNone:;
          else
            If Assigned(FOnReceiveCPT1) Then FOnReceiveCPT1(Self, tmpPackCPR, PDID, FCPID, iBlockID, iTask, iPos, vParams[iPos], InternalGetRouteParams(iPos))
            else ReceiveCPT1(tmpPackCPR, PDID, FCPID, iBlockID, iTask, iPos, vParams[iPos], InternalGetRouteParams(iPos));
          end;
          blWasAnError:=false;
        Except on E:Exception do begin//на одном из шагов случилась ошибка,
          try
            If Assigned(FOnReceiveCPT1Error) Then FOnReceiveCPT1Error(Self, tmpPackCPR, PDID, FCPID, iBlockID, iTask, iPos, E.Message, E.HelpContext, InternalGetRouteParams(iPos))
            else ReceiveCPT1Error(tmpPackCPR, PDID, FCPID, iBlockID, iTask, iPos, E.Message, E.HelpContext, InternalGetRouteParams(iPos));
          except on e:exception do FCallerAction.ITMessAdd(StartTime, now, 'IExecuteCPT', 'Error in except in ReceiveCPT1Error: '''+e.Message+'''/HC='+IntToStr(e.HelpContext), mecApp , mesError);end;
          blWasAnError:=True;
        end;end;
        If (blWasAnError=true) And (iBlockID<>-1) then begin//Добавляю номер блока в список прерваных блоков, т.к. произошла ошибка
          If VarType(vListOfBreakedBlock)=varEmpty then begin//добавляю первый прерванный блок
            vListOfBreakedBlock:=VarArrayCreate([0,0], varInteger);
            vListOfBreakedBlock[0]:=iBlockID;
          end else begin//добавляю еще прерванный блок
            VarArrayRedim(vListOfBreakedBlock, VarArrayHighBound(vListOfBreakedBlock, 1)+1);
            vListOfBreakedBlock[VarArrayHighBound(vListOfBreakedBlock, 1)]:=iBlockID;
          end;
        end;
      end;//for//Сохранию результат
      If (FBuildResult)And({tmpPackCPR.CPErrors.Count+}tmpPackCPR.CPTasks.PackCPTasks.ITCount{ResultTaskCount}>0) then Result:=tmpPackCPR.AsVariant{Result} else Result:=Unassigned;
    finally//Чищу варианты
      tmpPackCPR:=nil;
      vListOfBreakedBlock:=Unassigned;
      vTasks:=Unassigned;
      vParams:=Unassigned;
    end;
  except on e:exception do begin
    e.Message:='EADMExecCmdPack: ' + e.Message;
    raise;
  end;end;
Except On E:Exception do begin
  E.Message:='IExecuteCPT1: '+E.Message;
  Raise;
end;End;
end;

Procedure TCommandPack.ReceiveCPT1(aPackCPR:IPackCPR; Const aPDID:Variant; Const aCPID:Variant; aBlockID:Integer; aCPTask:TADMTask; aPos:Integer; Const aParams:Variant; Const aRouteParam:Variant);
begin
end;

Procedure TCommandPack.ReceiveCPT1Error(aPackCPR:IPackCPR; Const aPDID:Variant; Const aCPID:Variant; aBlockID:Integer; aCPTask:TADMTask; aPos:Integer; Const aMessage:AnsiString; aHelpContext:Integer; Const aRouteParam:Variant);
  Var istErr:Ansistring;
begin
  istErr:='TCommandPack: (step='+inttostr(aPos+1)+' of '+inttostr(FivHB-FivLB+1)+'): '+aMessage;
  FCallerAction.ITMessAdd(StartTime, now, 'CPS(HC='+IntToStr(aHelpContext)+')', istErr, mecApp, mesError);
  istErr:=FTitlePoint+': '+istErr;
  try
    If ctoReturnParamsIfError in TCPTOptions(Integer(FCP[Protocols_CPT_Options])) then begin//вернуть параметры если ошибка
      aPackCPR.AddWithError{ResultWithErrorAdd}(aCPTask, FCP[Protocols_CPT_Params][aPos]{Params}, InternalGetRouteParams(aPos), aBlockID, istErr, aHelpContext);
    end else begin//не возвращать
      aPackCPR.AddWithError{ResultWithErrorAdd}(aCPTask, Unassigned, InternalGetRouteParams(aPos), aBlockID, istErr, aHelpContext);
    end;
  except
    on e:exception do FCallerAction.ITMessAdd(StartTime, now, 'CPS(HC='+IntToStr(e.HelpContext)+')', 'EADMExecCommandPack: Except: ResultWithErrorStandartAdd: '+e.message, mecApp, mesError);
  end;
end;

Procedure TCommandPack.InternalExecuteCPR1;
  Var vListOfBreakedBlock, vTasks, vParams, vError:Variant;
      blSkipResult, blWasAnError, blInPackError:boolean;
      iI, iPos, iBlockID, iBB, ivErrorLB, ivErrorhB, itmpError: Integer;
      iTask:TADMTask;
      iResultWithError:Boolean; //Флаг что ошибка пришла в результате, а произовла при отработке.
  procedure CheckParamsIn( vlParamsCount:Integer; _V: OleVariant);
    Var _iSize: Integer;
    begin
{1..n}If (VarType(_V) and VarArray) = varArray Then _iSize:=VarArrayHighBound(_V,1)-VarArrayLowBound(_V,1)+1 else
{-1}    if (VarType(_V)=varNull) Or (VarType(_V)=varEmpty) Then _iSize:=-1 else
{0}       _iSize:=0;
      if vlParamsCount<>_iSize Then raise exception.create('не верное количество параметров(ожидается='+IntToStr(vlParamsCount)+', пришло='+IntToStr(_iSize)+').');
    end;
begin
  Try
    try
      ivErrorLB:=-1;//что бы не было варнингов
      ivErrorHB:=-1;
      iBlockID:=-1;//..
      vListOfBreakedBlock:=Unassigned;//..
      vError:=FCP[Protocols_CPR_Errors];//массив для ошибок
      blInPackError:=False;
      If VarIsArray(vError) Then begin//Проверка на ошибку в пакете
        blInPackError:=True;//В пакете есть ошибка
        ivErrorLB:=VarArrayLowBound(vError, 1);
        ivErrorHB:=VarArrayHighBound(vError, 1);
      end;//..
      vTasks:=FCP[Protocols_CPR_Tsk];
      vParams:=FCP[Protocols_CPR_Params];
      blWasAnError:=false;
      iResultWithError:=False;//Сбрасываю флаг что ошибка пришла в результате, а произовла при отработке.
      For iI:=FivLB to FivHB do begin
        iPos:=iI;
        iTask:=tskADMNone; //от варнингов
        Try//Проверяю текущая комманда должна выполняться или ее блок прерван
          blSkipResult:=False;
          iBlockID:=FCP[Protocols_CPR_BlockID][iPos];  // беру номер блока для текущ. команды
          If VarType(vListOfBreakedBlock)<>varEmpty then begin
            //список прерваных блоков не пустой
            For iBB:=VarArrayLowBound(vListOfBreakedBlock, 1) to VarArrayHighBound(vListOfBreakedBlock, 1) do begin
              If vListOfBreakedBlock[iBB]=iBlockID Then
                //номер блока текущей команды есть в списке прерваных блоков
                blSkipResult:=True;
                Break;
            end;
          end;
          //..
          iTask:=TADMTask(Integer(vTasks[iPos]));//Исправил ошибку, для ексцепшина терялся tskADM..
          //Проверяю есть ли ошибка в текущей команде
          iResultWithError:=False; // Сбрасываю флаг что ошибка пришла в результате, а произовла при отработке.
          If blInPackError=True Then begin
            //В пакете есть ошибка
            For itmpError:=ivErrorLB to ivErrorHB do begin
              //Ошибка была при выполнении этой команды
              If vError[itmpError][0]=iI Then begin
                iResultWithError:=True; // Ставлю флаг что ошибка пришла в результате, а произовла при отработке.
                If VarArrayHighBound(vError[itmpError], 1)=2 Then begin
                  Raise Exception.CreateHelp(vError[itmpError][1], vError[itmpError][2]);
                end else begin
                  Raise Exception.Create(vError[itmpError][1]);
                end;
              end;
            end;
          end;
          //..
          If blSkipResult Then Continue;//следов. комманда пропускается.
          // ..
          //iTask:=TADMTask(Integer(vTasks[iPos]));
          If Assigned(FOnCheckSecurityPTask) Then FOnCheckSecurityPTask(iTask, ptlCPR, FCallerAction.SecurityContext) else CheckSecurityPTask(iTask, ptlCPR, FCallerAction.SecurityContext);
          Case iTask of
            tskADMNone:;
          else
            If Assigned(FOnReceiveCPR1) Then FOnReceiveCPR1(Self, PDID, FCPID, iBlockID, iTask, iPos, vParams[iPos], InternalGetRouteParams(iPos))
            else ReceiveCPR1(PDID, FCPID, iBlockID, iTask, iPos, vParams[iPos], InternalGetRouteParams(iPos));
          end;
          blWasAnError:=False;
        Except on e:exception do begin
          // на одном из шагов случилась ошибка,
          try
            If Assigned(FOnReceiveCPR1Error) Then FOnReceiveCPR1Error(Self, PDID, FCPID, iBlockID, iTask, iPos, E.Message, e.HelpContext, iResultWithError, InternalGetRouteParams(iPos))
              else ReceiveCPR1Error(PDID, FCPID, iBlockID, iTask, iPos, E.Message, e.HelpContext, iResultWithError, InternalGetRouteParams(iPos));
          except on e:exception do FCallerAction.ITMessAdd(StartTime, now, 'CPS(HC='+IntToStr(e.HelpContext)+')', 'EADMExecCommandPack: Except: ResultWithErrorStandartAdd: '+e.message, mecApp, mesError);end;
          iResultWithError:=False; // Сбрасываю флаг что ошибка пришла в результате, а произовла при отработке.
          blWasAnError:=True;
        end;end;
        If (blWasAnError=true) And (iBlockID<>-1) then begin
          // Добавляю номер блока в список прерваных блоков, т.к. произошла ошибка
          If VarType(vListOfBreakedBlock)=varEmpty then begin
            // добавляю первый прерванный блок
            vListOfBreakedBlock:=VarArrayCreate([0,0], varInteger);
            vListOfBreakedBlock[0]:=iBlockID;
          end else begin
            // добавляю еще прерванный блок
            VarArrayRedim(vListOfBreakedBlock, VarArrayHighBound(vListOfBreakedBlock, 1)+1);
            vListOfBreakedBlock[VarArrayHighBound(vListOfBreakedBlock, 1)]:=iBlockID;
          end;
        end;
        // ..
      end; // for
    except on e:exception do begin e.Message:='CopralResultPack: ' + e.Message;Raise;end;end;
    vListOfBreakedBlock:=Unassigned;
  Except On E:Exception do begin E.Message:='IExecuteCPR1: '+E.Message;Raise;end;End;
end;

Procedure TCommandPack.ReceiveCPR1(Const aPDID:Variant; Const aCPID:Variant; aBlockID:Integer; aCPTask:TADMTask; aPos:Integer; Const aParams:Variant; Const aRouteParam:Variant);
begin
  FCallerAction.ITMessAdd(StartTime, now, 'TCommandPack', 'ReceiveCPR1: Этого вызова недолжно быть!', mecTransport, mesError);
end;

Procedure TCommandPack.ReceiveCPR1Error(Const aPDID:Variant; Const aCPID:Variant; aBlockID:Integer; aCPTask:TADMTask; aPos:Integer; Const aMessage:AnsiString; aHelpContext:Integer; aResultWithError:Boolean; Const aRouteParam:Variant);
begin
  FCallerAction.ITMessAdd(StartTime, now, 'TCommandPack', 'ReceiveCPR1Error: Этого вызова недолжно быть!', mecTransport, mesError);
end;

procedure TCommandPack.CheckSecurityPTask(aTask:TADMTask; aProtocolType:TProtocolType; Const aSecurityContext:Variant);
begin
  FCallerAction.ITMessAdd(StartTime, now, 'TCommandPack', 'CheckSecurityPTask: Этого вызова недолжно быть!', mecTransport, mesError);
end;

end.
