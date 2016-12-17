unit UTableCommandMaster;

interface
  Uses UTableCommandAnalyser, UBlockSQLTaskManage, UCallerTypes;
  
Type
  TTableCommandMaster=class(TObject)
  private
    FTableCommandAnalyser:TTableCommandAnalyser;
    FBlockSQLTaskManage:TBlockSQLTaskManage;
    FListBlock:Variant;
    FivHB, FivHBR:Integer;
    FResult:Variant;
    FSetSQLIDAsSend:Variant;
    FivHBSetSQLIDAsSend:Integer;
    FivCRSetSQLIDAsSend:Integer;
    FCPID:Integer;
    FCheckActuality:Boolean;
    FBlockCount:Integer;
    Function Get_ResultCount:Integer;
    Function Get_Result(Index:Integer):Variant;
    Procedure SetCallerAction(Value:ICallerAction);
    Function  GetCallerAction:ICallerAction;
  Protected
    procedure TableCommandIsEmpty(aTableCommandAnalyser:Pointer{TTableCommandAnalyser});
    procedure BlockReady(aTableCommandAnalyser:Pointer{TTableCommandAnalyser}; aIDShop, aBlockId:Integer; aDateExecute:Variant);
    procedure CommandReadyOfBlock(aTableCommandAnalyser:Pointer{TTableCommandAnalyser}; aIDShop, aBlockId, aSQLID:Integer; aSQL:AnsiString);
    procedure ListBlock(aTableCommandAnalyser:Pointer{TTableCommandAnalyser}; aIDShop, aCompleteState, aBlockId:Integer; aSQLIDList, aDateCreate:Variant; aIdentifier:AnsiString);
    Procedure EndOfListBlock(aTableCommandAnalyser:Pointer{TTableCommandAnalyser});
    procedure BeforeShopReady(aTableCommandAnalyser:Pointer; aIDShop, aSQLID:Integer);
    procedure ShopReady(aTableCommandAnalyser:Pointer; aIDShop:Integer);
    procedure AllSetAsSend(aTableCommandAnalyser:TTableCommandAnalyser);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Exec;virtual;
    property Result[Index:Integer]:Variant read Get_Result;// write FResult;
    property ResultCount:Integer read Get_ResultCount;
    Property CallerAction:ICallerAction read GetCallerAction write SetCallerAction;
    Property CheckActuality:Boolean read FCheckActuality write FCheckActuality;
    Property BlockCount:Integer read FBlockCount write FBlockCount;
  end;

implementation
  Uses SysUtils, {UManageCPT1, }UADMTypes, UPackConsts, UPackTypes, UPackPD, UPackPDTypes, UAppMessageTypes,
       UTrayConsts, Variants, UPackCPTTypes, UPackCPT;

constructor TTableCommandMaster.Create;
begin
  FTableCommandAnalyser:=TTableCommandAnalyser.Create;
  FListBlock:=Unassigned;
  FTableCommandAnalyser.OnTableCommandIsEmpty:=TableCommandIsEmpty;
  FTableCommandAnalyser.OnBlockReady:=BlockReady;
  FTableCommandAnalyser.OnCommandReadyOfBlock:=CommandReadyOfBlock;
  FTableCommandAnalyser.OnListBlock:=ListBlock;
  FTableCommandAnalyser.OnEndOfListBlock:=EndOfListBlock;
  FTableCommandAnalyser.OnBeforeShopReady:=BeforeShopReady;
  FTableCommandAnalyser.OnShopReady:=ShopReady;
  FivHB:=-1;
  FivHBR:=-1;
  FCPID:=-1;
  FBlockSQLTaskManage:=TBlockSQLTaskManage.Create;
  FResult:=Unassigned;
  FSetSQLIDAsSend:=Unassigned;
  FivHBSetSQLIDAsSend:=-1;
  FivCRSetSQLIDAsSend:=-1;
  FCheckActuality:=false;
  FBlockCount:=150;
  Inherited Create;
end;

destructor TTableCommandMaster.Destroy;
begin
  try
    FTableCommandAnalyser.Free;
    FBlockSQLTaskManage.Free;
    FivHB:=-1;
    VarClear(FListBlock);
    FivHBR:=-1;
    VarClear(FResult);
    VarClear(FSetSQLIDAsSend);
  except end;
  Inherited Destroy;
end;

Procedure TTableCommandMaster.SetCallerAction(Value:ICallerAction);
begin
  FTableCommandAnalyser.CallerAction:=Value;
end;

Function  TTableCommandMaster.GetCallerAction:ICallerAction;
begin
  Result:=FTableCommandAnalyser.CallerAction;
end;

Function TTableCommandMaster.Get_ResultCount:Integer;
begin
  Result:=FivHBR+1;
end;

Function TTableCommandMaster.Get_Result(Index:Integer):Variant;
begin
  If (Index>=0)And(Index<=FivHBR) Then Result:=FResult[Index]
    else Raise Exception.Create('TTableCommandMaster.Get_Result: Index('+IntToStr(Index)+') вне диапазона([0,'+IntToStr(FivHBR)+']).');
end;

procedure TTableCommandMaster.Exec;
begin
  FivHB:=-1;
  FListBlock:=Unassigned;
  FivHBR:=-1;
  VarClear(FResult);
  VarClear(FSetSQLIDAsSend);
  FBlockSQLTaskManage.Clear;
  FCPID:=-1;
  FTableCommandAnalyser.BlockCount:=FBlockCount;
  If FTableCommandAnalyser.Open>0 then begin//Есть новые команды
    If FCheckActuality Then FTableCommandAnalyser.ListBlock;//Стирает все неактуальные записи
    FTableCommandAnalyser.Exec;//Формирует BlockSQL
    FTableCommandAnalyser.LDBBeginTran;
    try
      AllSetAsSend(FTableCommandAnalyser);
      FTableCommandAnalyser.LDBCommitTran;
    except
      try FTableCommandAnalyser.LDBRollBackTran; except end;
      raise;
    end;
  end else begin//Выборка пустая
    {None}
  end;
end;

procedure TTableCommandMaster.ListBlock(aTableCommandAnalyser:Pointer; aIDShop, aCompleteState, aBlockId:Integer; aSQLIDList, aDateCreate:Variant; aIdentifier:AnsiString);
  Var iI, iII, iSaveNum:Integer;
      iDateCreate, iDateCreateCurr:TCompTime;
      tmpStIdentifier:AnsiString;
begin
  // Процедура вызывается TTableCommandAnalyser.OnListBlock после каждого прочтенного блока и
  //   предназначена для удаления неактуальных записей из таблицы ssTableCommad.
  CallerAction.ITMessAdd(Now, Now, 'TTableMaster', 'ListBlock is started.', mecDebug, mesInformation);
  iSaveNum:=-1; // начальная утановка
  tmpStIdentifier:=UpperCase(aIdentifier); // Поднимаю регист, т.е. делаю ssTableCommand.Identifier не чуствительным к регистру.
  if VarIsEmpty(FListBlock) then begin
    // Список пустой, создаю
    FListBlock:=VarArrayCreate([0,0], varVariant);
    FivHB:=0;
    iSaveNum:=FivHB;
  end else begin
    // Список не пустой
    // Проверяю
    For iI:=0 to FivHB do begin
      If Integer(FListBlock[iI][0])=aIDShop then begin
        // Магазин тотже
        If (tmpStIdentifier<>'')And(AnsiString(FListBlock[iI][2])=tmpStIdentifier) then begin
          // Identifier(тип операции) тотже
          iDateCreate.ofComp:=TimeStampToMSecs(DateTimeToTimeStamp(VarToDateTime(FListBlock[iI][1])));
          iDateCreateCurr.ofComp:=TimeStampToMSecs(DateTimeToTimeStamp(VarToDateTime(aDateCreate)));
          If iDateCreate.ofInt64<iDateCreateCurr.ofInt64 then begin
            // найден(пришел) более актуальный блок
            If aCompleteState<0 Then begin
              // Блок надо отправить у него CompleteState -1 или -2
              // удаляю прежний
              // >-1 на -1(Delete)
              // >-1 на +1(Delete)
{=}           For iII:=0 to VarArrayHighBound(FListBlock[iI][3], 1) do
                TTableCommandAnalyser(aTableCommandAnalyser).SetRecAsDelete(Integer(FListBlock[iI][3][iII]));
{=}           iSaveNum:=iI; // на его место записываю более актуальный
            end else begin
              // Блок не надо отправлять у него CompleteState 2,3 или 4(Err)
              If Integer(FListBlock[iI][4{CompleteState}])<0 Then begin
                // >+1(Lost) на -1
                For iII:=0 to VarArrayHighBound(FListBlock[iI][3], 1) do
                  TTableCommandAnalyser(aTableCommandAnalyser).SetRecAsLost(Integer(aSQLIDList[iII]));
                iSaveNum:=-1;  // означает что не надо добавлять, а надо просто покинуть процедуру
              end else begin
                // >+1 на +1(Delete)
{=}             For iII:=0 to VarArrayHighBound(FListBlock[iI][3], 1) do
                  TTableCommandAnalyser(aTableCommandAnalyser).SetRecAsDelete(Integer(FListBlock[iI][3][iII]));
{=}             iSaveNum:=iI; // на его место записываю более актуальный
              end;
            end;
          end else begin
            // найден(пришел) менее актуальный блок
            If aCompleteState<0 Then begin
              If Integer(FListBlock[iI][4{CompleteState}])<0 Then begin
                // -1(Delete) на >-1
                For iII:=0 to VarArrayHighBound(aSQLIDList, 1) do
                  TTableCommandAnalyser(aTableCommandAnalyser).SetRecAsDelete(Integer(aSQLIDList[iII]));
                iSaveNum:=-1;  // означает что не надо добавлять, а надо просто покинуть процедуру
              end else begin
                // -1 на >+1(Lost)
{=}             For iII:=0 to VarArrayHighBound(FListBlock[iI][3], 1) do
                  TTableCommandAnalyser(aTableCommandAnalyser).SetRecAsLost(Integer(FListBlock[iI][3][iII]));
{=}             iSaveNum:=iI; // на его место записываю более актуальный
              end;
            end else begin
              // +1(Delete) на >-1
              // +1(Delete) на >+1
              For iII:=0 to VarArrayHighBound(aSQLIDList, 1) do
                TTableCommandAnalyser(aTableCommandAnalyser).SetRecAsDelete(Integer(aSQLIDList[iII]));
              iSaveNum:=-1;  // означает что не надо добавлять, а надо просто покинуть процедуру
            end;
          end;
          Break;
        end;
      end;
    end;
    If iI>FivHB Then begin
      // Цыкл кончился и не нашел более актуальный блок среди загруженых ранее в FListBlock.
      // Добавляю блок
      VarArrayRedim(FListBlock, FivHB+1);
      Inc(FivHB);
      iSaveNum:=FivHB;
    end;
  end;
  If iSaveNum>-1 Then begin
    // Присваиваю                     0        1            2                3           4
    FListBlock[iSaveNum]:=VarArrayOf([aIDShop, aDateCreate, tmpStIdentifier, aSQLIDList, aCompleteState]);
  end;
end;

Procedure TTableCommandMaster.EndOfListBlock(aTableCommandAnalyser:Pointer);
  Var iI, iII:Integer;
begin
  If VarIsArray(FListBlock) Then begin
    try
      For iI:=0 to FivHB do begin
        If Not(Integer(FListBlock[iI][4{CompleteState}])<0) Then begin
          For iII:=0 to VarArrayHighBound(FListBlock[iI][3], 1) do
            TTableCommandAnalyser(aTableCommandAnalyser).SetRecAsLost(Integer(FListBlock[iI][3][iII]));
        End;
      end;
    finally
      VarClear(FListBlock);
    end;
  end;    
end;

procedure TTableCommandMaster.TableCommandIsEmpty(aTableCommandAnalyser:Pointer{TTableCommandAnalyser});
begin
  // None
end;

procedure TTableCommandMaster.BlockReady(aTableCommandAnalyser:Pointer{TTableCommandAnalyser}; aIDShop, aBlockId:Integer; aDateExecute:Variant);
begin
  if VarIsEmpty(aDateExecute) Or VarIsNull(aDateExecute) then begin
    // дата выполнения не указана
    // ставлю на немедленное выполнение
    FBlockSQLTaskManage.MoveCurrentBlockToTask(aBlockId, Unassigned);
  end else begin
    FBlockSQLTaskManage.MoveCurrentBlockToTaskWakeup(aBlockId, TimeStampToMSecs(DateTimeToTimeStamp(VarToDateTime(aDateExecute))), Unassigned);
  end;
end;

procedure TTableCommandMaster.CommandReadyOfBlock(aTableCommandAnalyser:Pointer{TTableCommandAnalyser}; aIDShop, aBlockId, aSQLID:Integer; aSQL:AnsiString);
begin
  FBlockSQLTaskManage.AddSQLToCurrentBlock(aSQLID, aSQL, False, Unassigned, False);
  //TTableCommandAnalyser(aTableCommandAnalyser).SetRecAsSend(aSQLID, FCPID);
  If VarIsEmpty(FSetSQLIDAsSend) Then begin
    FivHBSetSQLIDAsSend:=FBlockCount-1;
    FivCRSetSQLIDAsSend:=0;
    FSetSQLIDAsSend:=VarArrayCreate([0,FivHBSetSQLIDAsSend,0,1], varInteger);
  end else begin
    If FivCRSetSQLIDAsSend+1>FivHBSetSQLIDAsSend Then begin
      VarArrayRedim(FSetSQLIDAsSend, FivHBSetSQLIDAsSend+FBlockCount-1);
      FivHBSetSQLIDAsSend:=FivHBSetSQLIDAsSend+FBlockCount-1;
      FivCRSetSQLIDAsSend:=FivCRSetSQLIDAsSend+1;
    end else begin
      FivCRSetSQLIDAsSend:=FivCRSetSQLIDAsSend+1;
    end;
  end;
  FSetSQLIDAsSend[FivCRSetSQLIDAsSend, 0]:=aSQLID;
  FSetSQLIDAsSend[FivCRSetSQLIDAsSend, 1]:=FCPID;
end;

procedure TTableCommandMaster.BeforeShopReady(aTableCommandAnalyser:Pointer; aIDShop, aSQLID:Integer);
begin
  FCPID:=aSQLID;//для CPID
end;

procedure TTableCommandMaster.ShopReady(aTableCommandAnalyser:Pointer; aIDShop:Integer);
  Var tmpPackCPT:IPackCPT;
      tmpPackPD:IPackPD;//tmpManagePD1:TManagePD1;
begin
  If FBlockSQLTaskManage.DataCount>0 Then begin
    If VarIsEmpty(FResult) then begin
      FResult:=VarArrayCreate([0,0], varVariant);
      FivHBR:=0;
    end else begin
      VarArrayRedim(FResult, FivHBR+1);
      Inc(FivHBR);
    end;
    tmpPackCPT:=TPackCPT.Create;
    try
      //tmpManageCPT1.New(0, FCPID, Unassigned, Unassigned, Unassigned, Unassigned);
      tmpPackCPT.CPTasks.TaskAdd(tskADMBlockSQL, FBlockSQLTaskManage.Data, Unassigned, -1);
      //tmpManageCPT1.TaskAdd(tskADMBlockSQL, FBlockSQLTaskManage.Data, Unassigned, -1);
      tmpPackPD:=TPackPD.Create;//tmpManagePD1:=TManagePD1.Create;
      try
        tmpPackPD.PDOptions:=TPackPDOptions(popTask Or Protocols_PD_Options_ReturnDataIfTransportError);
        //tmpPackPD.Places.SetPlaces(0{CurrNum}, Unassigned, Unassigned);
        //tmpPackPD.DataAsVariant:=tmpManageCPT1.Result;
        tmpPackPD.DataAsIPack:=tmpPackCPT;
        tmpPackPD.PDID:=FCPID;//tmpManagePD1.New(popTask Or Protocols_PD_Options_ReturnDataIfTransportError{Option}, 0{CurrNum}, Unassigned, Unassigned, tmpManageCPT1.Result{Data}, FCPID{FPDID}, Unassigned{Error});
        tmpPackPD.Places.CurrNum:=0;
        tmpPackPD.Places.AddPlace(pdsEventOnBridge{Place}, aIDShop{PlaceData});//tmpManagePD1.AddPlace(pdsEventOnBridge{Place}, aIDShop{PlaceData});
        FResult[FivHBR]:=tmpPackPD.AsVariant;//tmpManagePD1.Result;
      finally
        tmpPackPD:=Nil;//tmpManagePD1.free;
      end;
    finally
      tmpPackCPT:=nil;
    end;
  end;
  FBlockSQLTaskManage.Clear;
  FCPID:=-1;
end;

procedure TTableCommandMaster.AllSetAsSend(aTableCommandAnalyser:TTableCommandAnalyser);
  Var iI:Integer;
begin
  If VarIsEmpty(FSetSQLIDAsSend) then Exit;
  For iI:=0 to FivCRSetSQLIDAsSend do begin
    aTableCommandAnalyser.SetRecAsSend(FSetSQLIDAsSend[iI, 0], FSetSQLIDAsSend[iI, 1]);
  end;
  VarClear(FSetSQLIDAsSend);
end;

end.
