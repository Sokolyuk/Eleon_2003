unit UPD;

interface
  Uses UPackTypes, UPackEventsTypes, UCallerTypes;
Type
  TPD=Class(TObject)
  Private
    FPD:Variant;
    FBuildResult:Boolean;
    FResult:Variant;
    FChecket, FArrived:boolean;
    FVersion, FOptions:Integer;
    FivLB, FivHB:Integer;
    FCallerAction:ICallerAction;
    FTitlePoint:AnsiString;
    FPDID:Variant;//Self events
    FOnTransportError:TTransportErrorEvent;//Events Place Data
    FOnReceivedCP:TReceivedCPEvent;//Events Command Pack.
    FOnReceiveCPT1:TReceiveCPT1Event;
    FOnReceiveCPT1Error:TReceiveCPT1ErrorEvent;
    FOnCheckSecurityPTask:TCheckSecurityPTaskEvent;
    FOnReceiveCPR1:TReceiveCPR1Event;
    FOnReceiveCPR1Error:TReceiveCPR1ErrorEvent;
    FStartTime:TDateTime;
  Protected
    Procedure Set_CallerAction(Value:ICallerAction);Virtual;
    Function InternalReverceRoute1(Const aData:Variant; aOption:Integer):Variant;Virtual;
    Procedure Set_Data(Const Value:Variant); Virtual;
    Procedure InternalHop1;Virtual;
    Function ReceivedCP(out aBuildResult:Boolean; Const aData:Variant):Variant;Virtual;
  Public
    Constructor Create;
    Destructor Destroy;override;
    Procedure CheckPD;virtual;
    Procedure Hop;virtual;
    Function ReverceRoute(Const aData:Variant; aOption:Integer):Variant; Virtual;
    Procedure TransportError(Const aMessage:Ansistring; aHelpContext:Integer; Const aRes:Variant); Virtual;
    // ..
    Property Arrived:boolean read FArrived;
    Property Checket:boolean read FChecket;
    Property BuildResult:Boolean read FBuildResult write FBuildResult;
    Property Result:Variant read FResult;
    Property Options:Integer read FOptions;
    Property Data:Variant read FPD write Set_Data;
    Property CallerAction:ICallerAction read FCallerAction write Set_CallerAction;
    Property TitlePoint:AnsiString read FTitlePoint write FTitlePoint;
    Property PDID:Variant read FPDID;
    Property StartTime:TDateTime read FStartTime;
    //Events Place Data
    Property OnReceivedCP:TReceivedCPEvent read FOnReceivedCP write FOnReceivedCP;
    //Events Command Pack.
    Property OnReceiveCPT1:TReceiveCPT1Event read FOnReceiveCPT1 write FOnReceiveCPT1;
    Property OnReceiveCPT1Error:TReceiveCPT1ErrorEvent read FOnReceiveCPT1Error write FOnReceiveCPT1Error;
    Property OnCheckSecurityPTask:TCheckSecurityPTaskEvent read FOnCheckSecurityPTask write FOnCheckSecurityPTask;
    Property OnReceiveCPR1:TReceiveCPR1Event read FOnReceiveCPR1 write FOnReceiveCPR1;
    Property OnReceiveCPR1Error:TReceiveCPR1ErrorEvent read FOnReceiveCPR1Error write FOnReceiveCPR1Error;
    Property OnTransportError:TTransportErrorEvent read FOnTransportError write FOnTransportError;
  end;

implementation
  Uses Sysutils, UPackConsts, UPackPD, UPackPDTypes, Variants;
//PD --------------------------------------------------------------------------
Constructor TPD.Create;
begin
  FStartTime:=Now;
  FPD:=Unassigned;
  FChecket:=false;
  FArrived:=false;
  FVersion:=0;
  FivLB:=-1;
  FivHB:=-1;
  FOptions:=0;
  FPDID:=-1;
  FCallerAction:=nil;//из задачи(tskPD), нужен в TransportError для постановка в очередь ReSend.
  FBuildResult:=False;
  FResult:=Unassigned;//Self events
  FOnTransportError:=Nil;//Events Place Data
  FOnReceivedCP:=nil;//Events Command Pack.
  FOnReceiveCPT1:=nil;
  FOnReceiveCPT1Error:=nil;
  FOnCheckSecurityPTask:=nil;
  FOnReceiveCPR1:=nil;
  FOnReceiveCPR1Error:=nil;
  FTitlePoint:='<None>';
  Inherited Create;
end;

destructor TPD.Destroy;
begin
  FResult:=Unassigned;
  FPD:=Unassigned;
  FCallerAction:=nil;
  FTitlePoint:='';
  Inherited Destroy;
end;

Procedure TPD.Set_Data(Const Value:Variant);
begin
  FChecket:=false;
  FArrived:=false;
  FBuildResult:=False;
  FResult:=Unassigned;
  FivLB:=-1;
  FivHB:=-1;
  FOptions:=0;
  FVersion:=0;
  FPDID:=-1;
  FPD:=Value;
  CheckPD;
end;

Procedure TPD.Set_CallerAction(Value:ICallerAction);
begin
  FCallerAction:=Value;
end;

Procedure TPD.CheckPD;
begin
  Try
    FChecket:=false;
    // проверяю размерность пакета
    If (VarType(FPD) and varArray)<>varArray then raise Exception.create('vPD is not array.');
    try
      // проверяю тип пакета
      If (VarType(FPD[Protocols_ID])<>varInteger) Or (FPD[Protocols_ID]<>Integer(Protocols_PD)) then raise exception.create('Протокол не PD(ID<>Interger(3)).');
      If Integer(Protocols_PD_Count)<>(VarArrayHighBound(FPD, 1)-VarArrayLowBound(FPD, 1)+1) Then raise exception.create('Неправильная размерность vPD.');
    except on e:exception do begin
      e.message:='Проверка тип пакета: '+e.message;
      raise;
    end;end;
    // проверяю соответствие типам массивов
    If (VarType(FPD[Protocols_PD_Place])<>(varArray Or varInteger)) Then raise Exception.create('Неправильный формат команды (PD_Place is not VarArray & VarInteger).');
    If (VarType(FPD[Protocols_PD_PlaceData]) and varArray)<>varArray Then raise Exception.create('Неправильный формат параметров (PD_PlaceData is not VarArray).');
    // получаю диапозон
    FivLB:=VarArrayLowBound (FPD[Protocols_PD_Place], 1);
    FivHB:=VarArrayHighBound(FPD[Protocols_PD_Place], 1);
    // проверяю соответствие диапозона списка команд для всех массивов
    If (FivLB<>VarArrayLowBound(FPD[Protocols_PD_PlaceData], 1)) Or
       (FivHB<>VarArrayHighBound(FPD[Protocols_PD_PlaceData], 1)) Then raise Exception.create('Неправильная размерность PD_Place & PD_PlaceData.');
    // проверяю корректность CurrNum
    If FPD[Protocols_PD_CurrNum]<FivLB Then Raise Exception.Create('Неправильное значение (CurrNum<FivLB).');
    // Беру версию
    FVersion:=FPD[Protocols_Ver];
    // Проверяю допустимые версии
    Case FVersion of
      1:;
    else
      raise Exception.Create('Неизвестная версия протокола(Ver='+IntToStr(FVersion)+').');
    end;
    // Беру параметры
    FOptions:=FPD[Protocols_PD_Options];
    // ..
    If FivHB=(FPD[Protocols_PD_CurrNum]-1) Then FArrived:=True else begin
      If FivHB<(FPD[Protocols_PD_CurrNum]-1) Then Raise Exception.Create('Неправильное значение(FivHB('+IntToStr(FivHB)+')<(CurrNum('+IntToStr(FPD[Protocols_PD_CurrNum])+')-1)). Пакет пролетел пункт назначения.') else
        FArrived:=False;
    end;
    //беру ID протокола PD.
    FPDID:=FPD[Protocols_PD_PDID];
    Case VarType(FPDID) of
      varEmpty, varSmallint, varInteger, varString, varOleStr, varByte, varWord, varShortInt:;
    else
      Raise Exception.Create('Неправильный тип PDID(Client/VarType='+IntToStr(Integer(VarType(FPDID)))+').');
    end;
    // Теперь считается что проверка завершена и пакет коррестный
    FChecket:=true;
  Except On E:Exception do begin
    E.Message:='TPD.CheckPD: '+E.Message;
    Raise;
  end;End;
end;

Procedure TPD.Hop;
begin
  Try
    FBuildResult:=False;
    FResult:=Unassigned;
    If FChecket=false then CheckPD;
    //Проверяю прилел или нет
    If FArrived=true then begin
      //Прилетел
      If VarIsEmpty(FPD[Protocols_PD_Error]) Then begin
        //Нет ошибок
        If Assigned(FOnReceivedCP) Then FResult:=FOnReceivedCP(Self, FBuildResult, FPD[Protocols_PD_Data]) else FResult:=ReceivedCP(FBuildResult, FPD[Protocols_PD_Data]);
      end else begin
        //Есть ошибки при транспортировке
        If VarArrayHighBound(FPD[Protocols_PD_Error], 1)>1 then begin
          //есть HelpContext
          If Assigned(FOnTransportError) Then FOnTransportError(Self, FPD[Protocols_PD_Error][0], FPD[Protocols_PD_Error][2], FPD[Protocols_PD_Error][1]) Else
              TransportError(FPD[Protocols_PD_Error][0], FPD[Protocols_PD_Error][2], FPD[Protocols_PD_Error][1]);
        end else begin
          //нет HelpContext
          If Assigned(FOnTransportError) Then FOnTransportError(Self, FPD[Protocols_PD_Error][0], {HelpContext}0, FPD[Protocols_PD_Error][1]) Else
              TransportError(FPD[Protocols_PD_Error][0], {HelpContext}0, FPD[Protocols_PD_Error][1]);
        end;
      end;
    end else begin
      //еще не прилетел
      Case FVersion of
        1:InternalHop1;
      else
        raise Exception.Create('Неизвестная версия протокола(Ver='+IntToStr(FVersion)+').');
      end;
    end;
  Except On E:Exception do begin
    E.Message:='TPD.Hop: '+E.Message;
    Raise;
  end;End;
end;

Procedure TPD.InternalHop1;
begin
  Raise Exception.Create('TPD.InternalHop1 не реализована.');
end;

Function TPD.ReverceRoute(Const aData:Variant; aOption:Integer):Variant;
begin
  Try
    If FChecket=false then CheckPD;
    Case FVersion of
      1:Result:=InternalReverceRoute1(aData, aOption);
    else
      raise Exception.Create('Неизвестная версия протокола(Ver='+IntToStr(FVersion)+').');
    end;
  except On E:Exception do begin
    e.message:='TPD.ReverceRoute: '+E.Message;
    raise;
  end;End;
end;

Function TPD.InternalReverceRoute1(Const aData:Variant; aOption:Integer):Variant;
  Var iI:Integer;
      tmpV4, tmpV5:Variant;
      tmpPackPD:IPackPD;//mpr : TManagePD1;
begin
Try
  Result:=Unassigned;
//  If FChecket=false then CheckPD;
  tmpV4:=VarArrayCreate([FivLB{0}, FivHB{-FivLB}], varInteger);
  try
    tmpV5:=VarArrayCreate([FivLB{0}, FivHB{-FivLB}], varVariant);
    try
      // Разворачиваю путь в обратном порядке
      for iI:=FivLB to FivHB do begin
        // Меняю направление на противополаженное
        case TPlace(FPD[Protocols_PD_Place][FivHB-iI]) of
          pdsEventOnID       : tmpV4[iI]:=pdsCommandOnID;
          pdsEventOnUser     : tmpV4[iI]:=pdsCommandOnUser;
          pdsEventOnAll      : tmpV4[iI]:=pdsCommandOnAll;
          pdsEventOnBridge   : tmpV4[iI]:=pdsCommandOnBridge;
          pdsEventOnMask     : tmpV4[iI]:=pdsCommandOnMask;
          pdsEventOnNameMask : tmpV4[iI]:=pdsCommandOnNameMask;
          pdsCommandOnID     : tmpV4[iI]:=pdsEventOnID;
          pdsCommandOnUser   : tmpV4[iI]:=pdsEventOnUser;
          pdsCommandOnAll    : tmpV4[iI]:=pdsEventOnAll;
          pdsCommandOnBridge : tmpV4[iI]:=pdsEventOnBridge;
          pdsCommandOnMask   : tmpV4[iI]:=pdsEventOnMask;
          pdsCommandOnNameMask:tmpV4[iI]:=pdsEventOnNameMask;
        else
          raise Exception.Create('Неизвестное значение PD_Place='+IntToStr(FPD[Protocols_PD_Place][FivHB-iI])+'.');
        end;
        tmpV5[iI]:=FPD[Protocols_PD_PlaceData][FivHB-iI];
      end;
      // ..
      tmpPackPD:=TPackPD.Create;//mpr:=TManagePD1.Create;
      Try
        tmpPackPD.PDOptions:=TPackPDOptions(aOption);
        tmpPackPD.Places.SetPlaces(FivHB-FPD[Protocols_PD_CurrNum]+FivLB+1, tmpV4, tmpV5);
        tmpPackPD.DataAsVariant:=aData;
        tmpPackPD.PDID:=FPD[Protocols_PD_PDID];//mpr.New(aOption, FivHB-FPD[Protocols_PD_CurrNum]+FivLB+1, tmpV4, tmpV5, aData, FPD[Protocols_PD_PDID], Unassigned);
        Result:=tmpPackPD.AsVariant;//mpr.Result;
      finally
        tmpPackPD:=Nil;//mpr.Free;
      end;
    Finally
      tmpV5:=unassigned;
    End;
  Finally
    tmpV4:=unassigned;
  End;
Except On E:Exception do begin
  E.Message:='IReverceRoute1: '+E.Message;
  Raise;
end;End;
end;

Function TPD.ReceivedCP(out aBuildResult:Boolean; Const aData:Variant):Variant;
begin
  aBuildResult:=False;
  Result:=Unassigned;
end;

Procedure TPD.TransportError(Const aMessage:Ansistring; aHelpContext:Integer; Const aRes:Variant);
begin
  Raise Exception.CreateHelp('TPD.TranportError(не реализована): '+aMessage, aHelpContext);
end;

end.
