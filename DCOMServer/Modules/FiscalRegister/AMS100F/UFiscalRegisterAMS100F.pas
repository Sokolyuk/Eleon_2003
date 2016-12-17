unit UFiscalRegisterAMS100F;

interface
  uses windows, UIObject, UFiscalRegisterAMS100FTypes, UFiscalRegisterAMS100FUtils, UFiscalRegisterAMS100FUtilsTypes;

type
  TFiscalRegisterAMS100F = class(TIObject, IFiscalRegisterAMS100F)
  protected
    FLibraryHandle: THandle;
    FSupplierCode: AnsiString;
    FComPortNum: byte;
    FCheckIsPrinted: boolean;//флаг, что чек напечатан
    FErrorMessage: AnsiString;
    FSaleRowCountMax: cardinal;
    FSaleRowCount: cardinal;
  protected
    FOldOnCheckPrepare: TOnCheckPrepareEvent;
    FOldOnError: TOnErrorEvent;
    FOldOnQuery: TOnEventEvent;
    FOldOnCloseCheck: TOnEventEvent;
    FOnCheckPrepare: TOnCheckPrepareEvent;
    FOnError: TOnErrorEvent;
    FOnQuery: TOnEventEvent;
    FOnCloseCheck: TOnEventEvent;
    FOnWaitForFCBB: TOnWaitForFCBBEvent;
  protected
    procedure InternalConnect;virtual;
    procedure InternalDisconnect;virtual;
    procedure InternalInit;virtual;
    procedure InternalFiscalPrint(aUserData:Pointer; aCheckNum, aCheckCount: cardinal);virtual;
    procedure InternalInitEvents;virtual;
    procedure InternalFinalEvents;virtual;
  protected
    procedure InternalOnCheckPrepare(aProgress: Integer);virtual;
    procedure InternalOnError(aErrorCode: Integer; aErrorMsg: PChar);virtual;
    procedure InternalOnQuery;virtual;
    procedure InternalOnCloseCheck;virtual;
    function InternalprintfiscalCheck(aSale:boolean; aSummAllNal, aSummAllCredit:double; aSaleRowCount: cardinal; aUserData:Pointer; aOnGetItem: TAddItemAMS100FEvent; aOnSetFiscalPrintIsSuccess: TOnFiscalPrintIsSuccessEvent):TfiscalprintResult;virtual;
  protected
    function GetOnCheckPrepare: TOnCheckPrepareEvent;virtual;
    procedure SetOnCheckPrepare(value: TOnCheckPrepareEvent);virtual;
    function GetOnError: TOnErrorEvent;virtual;
    procedure SetOnError(value: TOnErrorEvent);virtual;
    function GetOnQuery: TOnEventEvent;virtual;
    procedure SetOnQuery(value: TOnEventEvent);virtual;
    function GetOnCloseCheck: TOnEventEvent;virtual;
    procedure SetOnCloseCheck(value: TOnEventEvent);virtual;
    function GetOnWaitForFCBB: TOnWaitForFCBBEvent;virtual;
    procedure SetOnWaitForFCBB(value: TOnWaitForFCBBEvent);virtual;
    function GetSaleRowCount: cardinal;virtual;
    procedure SetSaleRowCount(value: cardinal);virtual;
  public
    constructor create(const aSupplierCode: AnsiString; aComPortNum: byte);
    destructor destroy;override;
  public
    function printfiscalCheckConnected(out aErrorMessage: AnsiString): boolean;virtual;
    procedure printfiscalAddTitleLine(const aTitleLine: AnsiString);virtual;
    procedure printfiscalAddBottomLine(const aBottomLine: AnsiString);virtual;
    function printfiscalSale(aSummAllNal, aSummAllCredit:double; aRowCount: cardinal; aUserData:Pointer; aOnSaleItem: TAddItemAMS100FEvent; aOnFiscalPrintIsSuccess: TOnFiscalPrintIsSuccessEvent):TfiscalprintResult;virtual;
    function printfiscalReturn(aSummAllNal, aSummAllCredit:double; aRowCount: cardinal; aUserData:Pointer; aOnReturnItem: TAddItemAMS100FEvent; aOnFiscalPrintIsSuccess: TOnFiscalPrintIsSuccessEvent):TfiscalprintResult;virtual;
    procedure printfiscalClearIndicator;virtual;
    procedure printfiscalString(const aString:AnsiString);virtual;
    procedure printfiscalRepeatCheck;virtual;
    procedure printfiscalFeed(aLineCount: Integer);virtual;
    procedure printfiscalKeyboardLock;virtual;
    procedure printfiscalKeyboardUnlock;virtual;
  public
    property OnCheckPrepare: TOnCheckPrepareEvent read GetOnCheckPrepare write SetOnCheckPrepare;
    property OnError: TOnErrorEvent read GetOnError write SetOnError;
    property OnQuery: TOnEventEvent read GetOnQuery write SetOnQuery;
    property OnCloseCheck: TOnEventEvent read GetOnCloseCheck write SetOnCloseCheck;
    property OnWaitForFCBB: TOnWaitForFCBBEvent read GetOnWaitForFCBB write SetOnWaitForFCBB;
    property SaleRowCount: cardinal read GetSaleRowCount write SetSaleRowCount;
  end;


implementation
  uses sysutils;

resourcestring
  csChon100Dll = 'chon100.dll';
  csNoFoundMethod = 'No found method "%s"';
  csConnectKKM = 'ConnectKKM';
  csSetSupplierCode = 'SetSupplierCode';
  csDisconnectKKM = 'DisconnectKKM';
  csGetErrorMsg = 'GetErrorMsg';
  cscbClearSales = 'cbClearSales';
  cscbClearTitle = 'cbClearTitle';
  cscbClearBottom = 'cbClearBottom';
  csSetChPrepareEvent = 'SetChPrepareEvent';
  csSetErrorEvent = 'SetErrorEvent';
  csSetQueryEvent = 'SetQueryEvent';
  csSetCloseCheckEvent = 'SetCloseCheckEvent';
  cscbSetLinesInSale = 'cbSetLinesInSale';
  csStartWaiting = 'StartWaiting';
  csStopWaiting = 'StopWaiting';
  cscbAddSale = 'cbAddSale';
  cscbSetReturnMode = 'cbSetReturnMode';
  cscbSetCreditMode = 'cbSetCreditMode';
  cscbSetCash = 'cbSetCash';
  cscbAddTitleLine = 'cbAddTitleLine';
  cscbAddBottomLine = 'cbAddBottomLine';
  csClearIndicator = 'ClearIndicator';
  csKKMPrintStr = 'KKMPrintStr';
  csRepeatCheck = 'RepeatCheck';
  csFeed = 'Feed';
  csLock = 'Lock';
  csUnlock = 'UnLock';

constructor TFiscalRegisterAMS100F.create(const aSupplierCode: AnsiString; aComPortNum: byte);
begin
  FLibraryHandle := 0;
  FSupplierCode := aSupplierCode;
  FComPortNum := aComPortNum;
  FCheckIsPrinted := false;

  inherited create;

  FLibraryHandle := LoadLibrary(PChar(csChon100Dll));
  if FLibraryHandle = 0 then raise exception.create(SysErrorMessage(GetLastError) + '(' + csChon100Dll + ')');

  InternalConnect;
  InternalInit;
  InternalInitEvents;
end;

destructor TFiscalRegisterAMS100F.destroy;
begin
  try InternalFinalEvents; except end;
  try InternalDisconnect; except end;
  try
    if FLibraryHandle <> 0 then begin
      FreeLibrary(FLibraryHandle);
      FLibraryHandle := 0;
    end;
  except end;  

  inherited destroy;
end;

procedure TFiscalRegisterAMS100F.InternalConnect;
  var tmpConnectKKM: TConnectKKM;
      tmpSetSupplierCode: TSetSupplierCode;
      tmpGetErrorMsg: TGetErrorMsg;
begin
  @tmpSetSupplierCode := GetProcAddress(FLibraryHandle, PChar(csSetSupplierCode));
  if not assigned(tmpSetSupplierCode) then raise exception.createfmt(csNofoundmethod, [csSetSupplierCode]);
  tmpSetSupplierCode(PChar(FSupplierCode));

  @tmpConnectKKM := GetProcAddress(FLibraryHandle, PChar(csConnectKKM));
  if not assigned(tmpConnectKKM) then raise exception.createfmt(csNoFoundMethod, [csConnectKKM]);
  if tmpConnectKKM(FComPortNum) <> 1 then begin
    @tmpGetErrorMsg := GetProcAddress(FLibraryHandle, PChar(csGetErrorMsg));
    if not assigned(tmpGetErrorMsg) then raise exception.createfmt(csNofoundmethod, [csGetErrorMsg]);
    raise exception.create(tmpGetErrorMsg);
  end;
end;

procedure TFiscalRegisterAMS100F.InternalDisconnect;
  var tmpDisconnectKKM: TDisconnectKKM;
begin
  @tmpDisconnectKKM := GetProcAddress(FLibraryHandle, PChar(csDisconnectKKM));
  if not assigned(tmpDisconnectKKM) then raise exception.createfmt(csNofoundmethod, [csDisconnectKKM]);
  tmpDisconnectKKM;
end;

procedure TFiscalRegisterAMS100F.InternalInit;
  var tmpcbClearSales: TcbClearSales;
      tmpcbClearTitle: TcbClearTitle;
      tmpcbClearBottom: TcbClearBottom;
      tmpSetChPrepareEvent: TSetChPrepareEvent;
      tmpSetErrorEvent: TSetErrorEvent;
      tmpSetQueryEvent: TSetQueryEvent;
      tmpSetCloseCheckEvent: TSetCloseCheckEvent;
      tmpcbSetLinesInSale: TcbSetLinesInSale;
      tmpGetErrorMsg: TGetErrorMsg;
begin
  @tmpcbClearSales := GetProcAddress(FLibraryHandle, PChar(cscbClearSales));
  if not assigned(tmpcbClearSales) then raise exception.createfmt(csNofoundmethod, [cscbClearSales]);
  tmpcbClearSales;

  @tmpcbClearTitle := GetProcAddress(FLibraryHandle, PChar(cscbClearTitle));
  if not assigned(tmpcbClearTitle) then raise exception.createfmt(csNofoundmethod, [cscbClearTitle]);
  tmpcbClearTitle;

  @tmpcbClearBottom := GetProcAddress(FLibraryHandle, PChar(cscbClearBottom));
  if not assigned(tmpcbClearBottom) then raise exception.createfmt(csNofoundmethod, [cscbClearBottom]);
  tmpcbClearBottom;

  @tmpSetChPrepareEvent := GetProcAddress(FLibraryHandle, PChar(csSetChPrepareEvent));
  if not assigned(tmpSetChPrepareEvent) then raise exception.createfmt(csNofoundmethod, [csSetChPrepareEvent]);
  tmpSetChPrepareEvent(DefaultAppCheckPrepare);

  @tmpSetErrorEvent := GetProcAddress(FLibraryHandle, PChar(csSetErrorEvent));
  if not assigned(tmpSetErrorEvent) then raise exception.createfmt(csNofoundmethod, [csSetErrorEvent]);
  tmpSetErrorEvent(DefaultAppError);

  @tmpSetQueryEvent := GetProcAddress(FLibraryHandle, PChar(csSetQueryEvent));
  if not assigned(tmpSetQueryEvent) then raise exception.createfmt(csNofoundmethod, [csSetQueryEvent]);
  tmpSetQueryEvent(DefaultQuery);

  @tmpSetCloseCheckEvent := GetProcAddress(FLibraryHandle, PChar(csSetCloseCheckEvent));
  if not assigned(tmpSetCloseCheckEvent) then raise exception.createfmt(csNofoundmethod, [csSetCloseCheckEvent]);
  tmpSetCloseCheckEvent(DefaultCloseCheck);

  @tmpcbSetLinesInSale := GetProcAddress(FLibraryHandle, PChar(cscbSetLinesInSale));
  if not assigned(tmpcbSetLinesInSale) then raise exception.createfmt(csNofoundmethod, [cscbSetLinesInSale]);
  //ставлю 2 строки, но 13 покупок
  if tmpcbSetLinesInSale(2) <> 1 then begin
    @tmpGetErrorMsg := GetProcAddress(FLibraryHandle, PChar(csGetErrorMsg));
    if not assigned(tmpGetErrorMsg) then raise exception.createfmt(csNofoundmethod, [csGetErrorMsg]);
    raise exception.create(tmpGetErrorMsg);
  end;
  FSaleRowCountMax := 13;//настраиваю класс
  FSaleRowCount := 13;
end;

procedure TFiscalRegisterAMS100F.InternalFiscalPrint(aUserData:Pointer; aCheckNum, aCheckCount: cardinal);
  var tmpStartWaiting: TStartWaiting;
      tmpStopWaiting: TStopWaiting;
begin
  @tmpStartWaiting := GetProcAddress(FLibraryHandle, PChar(csStartWaiting));
  if not assigned(tmpStartWaiting) then raise exception.createfmt(csNofoundmethod, [csStartWaiting]);
  @tmpStopWaiting := GetProcAddress(FLibraryHandle, PChar(csStopWaiting));
  if not assigned(tmpStopWaiting) then raise exception.createfmt(csNofoundmethod, [csStopWaiting]);
  tmpStartWaiting(1);
  try
    if assigned(FOnWaitForFCBB) then FOnWaitForFCBB(aUserData, aCheckNum, aCheckCount);
  finally
    tmpStopWaiting;
  end;
end;

function TFiscalRegisterAMS100F.InternalprintfiscalCheck(aSale:boolean; aSummAllNal, aSummAllCredit:double; aSaleRowCount: cardinal; aUserData:Pointer; aOnGetItem:TAddItemAMS100FEvent; aOnSetFiscalPrintIsSuccess: TOnFiscalPrintIsSuccessEvent):TfiscalprintResult;
  var tmpcbClearSales: TcbClearSales;
      tmpcbAddSale: TcbAddSale;
      tmpcbSetReturnMode: TcbSetReturnMode;
      tmpcbSetCreditMode: TcbSetCreditMode;
      tmpcbSetCash: TcbSetCash;
      tmpGetErrorMsg: TGetErrorMsg;
      tmpSaleRowCount: cardinal;
      tmpSaleRowCountAll: cardinal;
      tmpSalePartSumm: double;
      tmpSalePartSummAll: double;
      tmpTradeName: AnsiString;
      tmpArtName: AnsiString;
      tmpUniStr36: AnsiString;
      tmpSumm: double;
      tmpCount: double;
      tmpShopSection: Cardinal;
      tmpStr: AnsiString;
      tmpEOF: boolean;
      tmpCheckNum: cardinal;
      tmpCheckCount: cardinal;
      tmpOneRowMode: boolean;
begin
  //проверки
  if not assigned(aOnGetItem) then raise exception.create('aOnGetItem not assigned.');
  @tmpcbClearSales := GetProcAddress(FLibraryHandle, PChar(cscbClearSales));
  if not assigned(tmpcbClearSales) then raise exception.createfmt(csNofoundmethod, [cscbClearSales]);
  @tmpcbAddSale := GetProcAddress(FLibraryHandle, PChar(cscbAddSale));
  if not assigned(tmpcbAddSale) then raise exception.createfmt(csNofoundmethod, [cscbAddSale]);
  @tmpcbSetReturnMode := GetProcAddress(FLibraryHandle, PChar(cscbSetReturnMode));
  if not assigned(tmpcbSetReturnMode) then raise exception.createfmt(csNofoundmethod, [cscbSetReturnMode]);
  @tmpcbSetCreditMode := GetProcAddress(FLibraryHandle, PChar(cscbSetCreditMode));
  if not assigned(tmpcbSetCreditMode) then raise exception.createfmt(csNofoundmethod, [cscbSetCreditMode]);
  @tmpcbSetCash := GetProcAddress(FLibraryHandle, PChar(cscbSetCash));
  if not assigned(tmpcbSetCash) then raise exception.createfmt(csNofoundmethod, [cscbSetCash]);
  @tmpGetErrorMsg := GetProcAddress(FLibraryHandle, PChar(csGetErrorMsg));
  if not assigned(tmpGetErrorMsg) then raise exception.createfmt(csNofoundmethod, [csGetErrorMsg]);

  if (aSummAllNal <> 0) and (aSummAllCredit <> 0) then raise exception.create('Денежный расчет может быть полностью наличным или полностью безналичным.');

  //процедура
  result := fprPrintedNone;

  if aSale then begin
    //настраиваю как продажу
    tmpcbSetReturnMode(0);
  end else begin
    //настраиваю как возврат
    tmpcbSetReturnMode(1);
  end;

  if aSummAllNal = 0 then begin
    tmpcbSetCreditMode(1);//безнал
  end else begin
    tmpcbSetCreditMode(0);//нал
  end;

  tmpEOF := false;
  tmpCheckNum := 0;
  tmpSalePartSummAll := 0;
  tmpSaleRowCountAll := 0;//сколько SaleRow всего

  while true do begin//делаю цикл. т.к. AMS100F может пробивать не более 13 покупок в одном чеке
    //сбрасываю покупки в базе, доболнительная проврка
    tmpcbClearSales;

    FCheckIsPrinted := false;//сбрасываю флаг, что чек напечатан
    FErrorMessage := '';//сбрасываю текст ошибки
    tmpSaleRowCount := 0;//количество продаж в одном чеке
    tmpSalePartSumm := 0;//сумма продаж в одном чеке
    inc(tmpCheckNum);//порядковый номер чека с 1

    //формирую данные
    while true do begin
      if tmpSaleRowCount = FSaleRowCount{13} then begin
        //получаем истенное значение tmpEOF, на тот слай если SaleRow на самом деле уже закончились
        if tmpSaleRowCountAll = aSaleRowCount then begin
          tmpEOF := true;
          //дополнительная проверка
          if aOnGetItem(aUserData, tmpTradeName, tmpArtName, tmpUniStr36, tmpSumm, tmpCount, tmpShopSection) then raise exception.create('Не соответствует количество SaleRow('+IntToStr(aSaleRowCount)+') заявленное с фактическим');
        end;

        break;
      end;

      //обычный вызов
      tmpEOF := not aOnGetItem(aUserData, tmpTradeName, tmpArtName, tmpUniStr36, tmpSumm, tmpCount, tmpShopSection);

      if tmpEOF then begin
        //дополнительная проверочка
        if tmpSaleRowCountAll <> aSaleRowCount then raise exception.create('Не соответствует количество SaleRow заявленное('+IntToStr(aSaleRowCount)+') с фактическим('+IntToStr(tmpSaleRowCountAll)+')');
        break;
      end;

      //Если есть торговое назвение, добавляю его
      if tmpTradeName <> '' then begin
        tmpStr :=  tmpTradeName + '                 ';
        SetLength(tmpStr, 17);
        tmpOneRowMode := false;
      end else begin
        tmpOneRowMode := true;
      end;

      //Если есть уникальный номер, добавляю его
      if tmpUniStr36 <> '' then begin
        tmpStr :=  tmpStr + tmpUniStr36;
      end;

      //если есть артикуд, добавляю его
      if tmpArtName <> '' then begin
        if tmpStr <> '' then begin
          tmpStr := tmpStr + '/';
        end;
        tmpStr := tmpStr + tmpArtName;
      end;

      //подравниваю все строку
      if tmpStr <> '' then begin
        tmpStr :=  tmpStr + '                 ';
        if tmpOneRowMode then begin
          //существует только вторая строка
          SetLength(tmpStr, 17);
        end else begin
          //существуют обе строки
          SetLength(tmpStr, 34);
        end;
      end;

      //tmpStr :=  tmpStr + tmpUniStr36 + '/' + tmpArtName + '                 ';
      //SetLength(tmpStr, 34);
                                  
      tmpSalePartSumm := tmpSalePartSumm + tmpSumm;

      if tmpcbAddSale(PChar(tmpStr), tmpSumm, tmpCount, tmpShopSection) <> 1 then raise exception.create(tmpGetErrorMsg);

      inc(tmpSaleRowCount);
      inc(tmpSaleRowCountAll);
    end;

    //Если что-то было добавлено к товару
    if tmpSaleRowCount < 1 then raise exception.create('tmpSaleRowCount < 1');

    if aSummAllNal <> 0 then begin//расчет за нал
      if tmpSalePartSumm > aSummAllNal then raise exception.create('Введено недостаточно наличных('+FloatToStr(tmpSalePartSumm)+'>'+FloatToStr(aSummAllNal)+').');
      if tmpEOF then begin
        //напечатана вся покупка
        if tmpcbSetCash(aSummAllNal - tmpSalePartSummAll) <> 1 then raise exception.create(tmpGetErrorMsg);
      end else begin
        //напечатана часть покупки
        if tmpcbSetCash(tmpSalePartSumm) <> 1 then raise exception.create(tmpGetErrorMsg);
      end;

      tmpSalePartSummAll := tmpSalePartSummAll + tmpSalePartSumm;//расчитываю суммы всех напечатанных чеков, для корректного расчета сдачи на последнем чеке
    end;

    //вызываю событие печати чеков
    tmpCheckCount := aSaleRowCount div FSaleRowCount{13};
    if (tmpCheckCount * FSaleRowCount{13}) < aSaleRowCount then inc(tmpCheckCount);

    //ФЦ+ВВ
    InternalFiscalPrint(aUserData, tmpCheckNum, tmpCheckCount);

    //смотрю была ли ошибка при печати
    if FErrorMessage <> '' then raise exception.create(FErrorMessage);

    //печатаю чек
    if not FCheckIsPrinted then begin
      //чек не был напечатан, рассматриваю это как отказ от печати
      if tmpCheckNum > 1 then begin
        //уже был напечан фискальный чек
        result := fprPrintedPart;//ставлю что напечатана только часть чеков
      end else begin
        //еще не печатался фискальный чек
        result := fprPrintedNone;//ставлю что ничего не напечатано
      end;
      break;
    end;

    //успешно напечатано, отправляю извещение что все строки принятые до сего момента выведены в фискальный регистратор
    if assigned(aOnSetFiscalPrintIsSuccess) then aOnSetFiscalPrintIsSuccess(aUserData, tmpCheckNum, tmpCheckCount);

    if tmpEOF then begin
      //все напечатал
      result := fprPrintedAll;//ставлю что все чеки напечатаны
      break;
    end;
  end;
end;

function TFiscalRegisterAMS100F.printfiscalSale(aSummAllNal, aSummAllCredit:double; aRowCount: cardinal; aUserData:Pointer; aOnSaleItem: TAddItemAMS100FEvent; aOnFiscalPrintIsSuccess: TOnFiscalPrintIsSuccessEvent):TfiscalprintResult;
begin
  result := InternalprintfiscalCheck(true, aSummAllNal, aSummAllCredit, aRowCount, aUserData, aOnSaleItem, aOnFiscalPrintIsSuccess);
end;

function TFiscalRegisterAMS100F.printfiscalReturn(aSummAllNal, aSummAllCredit:double; aRowCount: cardinal; aUserData:Pointer; aOnReturnItem: TAddItemAMS100FEvent; aOnFiscalPrintIsSuccess: TOnFiscalPrintIsSuccessEvent):TfiscalprintResult;
begin
  result := InternalprintfiscalCheck(false, aSummAllNal, aSummAllCredit, aRowCount, aUserData, aOnReturnItem, aOnFiscalPrintIsSuccess);
end;


{
Чтобы избежать повторного проведения товара через фискальный регистратор (или базу), Вам следует:
    1) отменить дальнейшую печать
    2) удалить из операции еще не выбитый (в чеке) товар
    3) (не сбрасывая операцию) на закладке открытый день отключить фискальный регистратор
    4) провести операцию без печати фискального чека (т.к. чек уже выбит).
    5) Далее следует включить фискальный регистратор,
    6) в новой операции провести еще не выбитый товар (который удаляли).
}

procedure TFiscalRegisterAMS100F.InternalInitEvents;
begin
  //перецеливаю события на текущее окно
  EnterCriticalSection(cnSetAMS100FEvents);
  try
    //запомнил прежние значения
    FOldOnCheckPrepare := cnOnCheckPrepare;
    FOldOnError := cnOnError;
    FOldOnQuery := cnOnQuery;
    FOldOnCloseCheck := cnOnCloseCheck;

    //перецелил на себя
    cnOnCheckPrepare := InternalOnCheckPrepare;
    cnOnError := InternalOnError;
    cnOnQuery := InternalOnQuery;
    cnOnCloseCheck := InternalOnCloseCheck;
  finally
    LeaveCriticalSection(cnSetAMS100FEvents);
  end;
end;

procedure TFiscalRegisterAMS100F.InternalFinalEvents;
begin
  //возвращаю прежние значения
  EnterCriticalSection(cnSetAMS100FEvents);
  try
    cnOnCheckPrepare := FOldOnCheckPrepare;
    cnOnError := FOldOnError;
    cnOnQuery := FOldOnQuery;
    cnOnCloseCheck := FOldOnCloseCheck;
  finally
    LeaveCriticalSection(cnSetAMS100FEvents);
  end;
end;

procedure TFiscalRegisterAMS100F.InternalOnCheckPrepare(aProgress: Integer);
begin
  if assigned(FOnCheckPrepare) then FOnCheckPrepare(aProgress);
end;

procedure TFiscalRegisterAMS100F.InternalOnError(aErrorCode: Integer; aErrorMsg: PChar);
begin
  FErrorMessage := aErrorMsg;
  if assigned(FOnError) then FOnError(aErrorCode, aErrorMsg);
end;

procedure TFiscalRegisterAMS100F.InternalOnQuery;
begin
  if assigned(FOnQuery) then FOnQuery();
end;

procedure TFiscalRegisterAMS100F.InternalOnCloseCheck;
begin
  FCheckIsPrinted := true;
  if assigned(FOnCloseCheck) then FOnCloseCheck();
end;

function TFiscalRegisterAMS100F.GetOnCheckPrepare: TOnCheckPrepareEvent;
begin
  result := FOnCheckPrepare;
end;

procedure TFiscalRegisterAMS100F.SetOnCheckPrepare(value: TOnCheckPrepareEvent);
begin
  FOnCheckPrepare := value;
end;

function TFiscalRegisterAMS100F.GetOnError: TOnErrorEvent;
begin
  result := FOnError;
end;

procedure TFiscalRegisterAMS100F.SetOnError(value: TOnErrorEvent);
begin
  FOnError := value;
end;

function TFiscalRegisterAMS100F.GetOnQuery: TOnEventEvent;
begin
  result := FOnQuery;
end;

procedure TFiscalRegisterAMS100F.SetOnQuery(value: TOnEventEvent);
begin
  FOnQuery := value;
end;

function TFiscalRegisterAMS100F.GetOnCloseCheck: TOnEventEvent;
begin
  result := FOnCloseCheck;
end;

procedure TFiscalRegisterAMS100F.SetOnCloseCheck(value: TOnEventEvent);
begin
  FOnCloseCheck := value;
end;

function TFiscalRegisterAMS100F.GetOnWaitForFCBB: TOnWaitForFCBBEvent;
begin
  result := FOnWaitForFCBB;
end;

procedure TFiscalRegisterAMS100F.SetOnWaitForFCBB(value: TOnWaitForFCBBEvent);
begin
  FOnWaitForFCBB := value;
end;

function TFiscalRegisterAMS100F.printfiscalCheckConnected(out aErrorMessage: AnsiString): boolean;
  var tmpConnectKKM: TConnectKKM;
      tmpGetErrorMsg: TGetErrorMsg;
begin
  @tmpConnectKKM := GetProcAddress(FLibraryHandle, PChar(csConnectKKM));
  if not assigned(tmpConnectKKM) then raise exception.createfmt(csNoFoundMethod, [csConnectKKM]);
  @tmpGetErrorMsg := GetProcAddress(FLibraryHandle, PChar(csGetErrorMsg));
  if not assigned(tmpGetErrorMsg) then raise exception.createfmt(csNofoundmethod, [csGetErrorMsg]);

  if tmpConnectKKM(FComPortNum) = 1 then begin
    //соединение есть
    result := true;
    aErrorMessage := '';
  end else begin
    //соединение отсутствует
    result := false;
    aErrorMessage := tmpGetErrorMsg;
  end;
end;

procedure TFiscalRegisterAMS100F.printfiscalAddTitleLine(const aTitleLine: AnsiString);
  var tmpcbAddTitleLine: TcbAddTitleLine;
      tmpGetErrorMsg: TGetErrorMsg;
begin
  @tmpcbAddTitleLine := GetProcAddress(FLibraryHandle, PChar(cscbAddTitleLine));
  if not assigned(tmpcbAddTitleLine) then raise exception.createfmt(csNoFoundMethod, [cscbAddTitleLine]);
  @tmpGetErrorMsg := GetProcAddress(FLibraryHandle, PChar(csGetErrorMsg));
  if not assigned(tmpGetErrorMsg) then raise exception.createfmt(csNofoundmethod, [csGetErrorMsg]);

  if tmpcbAddTitleLine(PChar(aTitleLine)) <> 1 then raise exception.create(tmpGetErrorMsg);
end;

procedure TFiscalRegisterAMS100F.printfiscalAddBottomLine(const aBottomLine: AnsiString);
  var tmpcbAddBottomLine: TcbAddBottomLine;
      tmpGetErrorMsg: TGetErrorMsg;
begin
  @tmpcbAddBottomLine := GetProcAddress(FLibraryHandle, PChar(cscbAddBottomLine));
  if not assigned(tmpcbAddBottomLine) then raise exception.createfmt(csNoFoundMethod, [cscbAddBottomLine]);
  @tmpGetErrorMsg := GetProcAddress(FLibraryHandle, PChar(csGetErrorMsg));
  if not assigned(tmpGetErrorMsg) then raise exception.createfmt(csNofoundmethod, [csGetErrorMsg]);

  if tmpcbAddBottomLine(PChar(aBottomLine)) <> 1 then raise exception.create(tmpGetErrorMsg);
end;

procedure TFiscalRegisterAMS100F.printfiscalClearIndicator;
  var tmpClearIndicator: TClearIndicator;
begin
  @tmpClearIndicator := GetProcAddress(FLibraryHandle, PChar(csClearIndicator));
  if not assigned(tmpClearIndicator) then raise exception.createfmt(csNoFoundMethod, [csClearIndicator]);
  tmpClearIndicator;
end;

procedure TFiscalRegisterAMS100F.printfiscalString(const aString:AnsiString);
  var tmpKKMPrintStr: TKKMPrintStr;
      tmpGetErrorMsg: TGetErrorMsg;
begin
  @tmpKKMPrintStr := GetProcAddress(FLibraryHandle, PChar(csKKMPrintStr));
  if not assigned(tmpKKMPrintStr) then raise exception.createfmt(csNoFoundMethod, [csKKMPrintStr]);
  @tmpGetErrorMsg := GetProcAddress(FLibraryHandle, PChar(csGetErrorMsg));
  if not assigned(tmpGetErrorMsg) then raise exception.createfmt(csNofoundmethod, [csGetErrorMsg]);

  if tmpKKMPrintStr(aString) <> 1 then raise exception.create(tmpGetErrorMsg);
end;

procedure TFiscalRegisterAMS100F.printfiscalRepeatCheck;
  var tmpRepeatCheck: TRepeatCheck;
      tmpGetErrorMsg: TGetErrorMsg;
begin
  @tmpRepeatCheck := GetProcAddress(FLibraryHandle, PChar(csRepeatCheck));
  if not assigned(tmpRepeatCheck) then raise exception.createfmt(csNoFoundMethod, [csRepeatCheck]);
  @tmpGetErrorMsg := GetProcAddress(FLibraryHandle, PChar(csGetErrorMsg));
  if not assigned(tmpGetErrorMsg) then raise exception.createfmt(csNofoundmethod, [csGetErrorMsg]);

  if tmpRepeatCheck() <> 1 then raise exception.create(tmpGetErrorMsg);
end;

procedure TFiscalRegisterAMS100F.printfiscalFeed(aLineCount: Integer);
  var tmpFeed: TFeed;
      tmpGetErrorMsg: TGetErrorMsg;
begin
  @tmpFeed := GetProcAddress(FLibraryHandle, PChar(csFeed));
  if not assigned(tmpFeed) then raise exception.createfmt(csNoFoundMethod, [csFeed]);
  @tmpGetErrorMsg := GetProcAddress(FLibraryHandle, PChar(csGetErrorMsg));
  if not assigned(tmpGetErrorMsg) then raise exception.createfmt(csNofoundmethod, [csGetErrorMsg]);

  if tmpFeed(aLineCount) <> 1 then raise exception.create(tmpGetErrorMsg);
end;

procedure TFiscalRegisterAMS100F.printfiscalKeyboardLock;
  var tmpLock: TLock;
      tmpGetErrorMsg: TGetErrorMsg;
begin
  @tmpLock := GetProcAddress(FLibraryHandle, PChar(csLock));
  if not assigned(tmpLock) then raise exception.createfmt(csNoFoundMethod, [csLock]);
  @tmpGetErrorMsg := GetProcAddress(FLibraryHandle, PChar(csGetErrorMsg));
  if not assigned(tmpGetErrorMsg) then raise exception.createfmt(csNofoundmethod, [csGetErrorMsg]);

  if tmpLock <> 1 then raise exception.create(tmpGetErrorMsg);
end;

procedure TFiscalRegisterAMS100F.printfiscalKeyboardUnlock;
  var tmpUnlock: TUnlock;
      tmpGetErrorMsg: TGetErrorMsg;
begin
  @tmpUnlock := GetProcAddress(FLibraryHandle, PChar(csUnlock));
  if not assigned(tmpUnlock) then raise exception.createfmt(csNoFoundMethod, [csUnlock]);
  @tmpGetErrorMsg := GetProcAddress(FLibraryHandle, PChar(csGetErrorMsg));
  if not assigned(tmpGetErrorMsg) then raise exception.createfmt(csNofoundmethod, [csGetErrorMsg]);

  if tmpUnlock <> 1 then raise exception.create(tmpGetErrorMsg);
end;

function TFiscalRegisterAMS100F.GetSaleRowCount: cardinal;
begin
  result := FSaleRowCount;
end;

procedure TFiscalRegisterAMS100F.SetSaleRowCount(value: cardinal);
begin
  if (value > FSaleRowCountMax) or (value < 1) then raise exception.create('Недопустимое значение SaleRowCount');
  FSaleRowCount := value;
end;

end.
