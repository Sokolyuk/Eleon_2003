unit UFiscalRegisterAMS100FUtilsTypes;

interface
  uses windows;

type
  TAppCheckPrepare = procedure(Progress: Integer); stdcall;
  TAppError = procedure (ErrorCode: Integer; ErrorMsg: PChar); stdcall;
  TAppEvent = procedure; stdcall;

  TOnCheckPrepareEvent = procedure(aProgress: Integer) of object;
  TOnErrorEvent = procedure (aErrorCode: Integer; aErrorMsg: PChar) of object;
  TOnEventEvent = procedure of object;

  //chon100.dll
  TcbAddBottomLine = function (Line: PChar): Integer; stdcall;
  TcbAddSale = function (Name: PChar; Price, Qty: Double; Section: Integer): Integer; stdcall;
  TcbAddTitleLine = function (Line: PChar): Integer; stdcall;
  TcbGetBottomLinesCount = function (): Integer; stdcall;
  TcbClearBottom = procedure (); stdcall;
  TcbSetCreditMode = procedure (Mode: Integer); stdcall;
  TcbGetCreditMode = function (): Integer; stdcall;
  TcbClearSales = procedure ; stdcall;
  TcbClearTitle = procedure ; stdcall;
  TcbDeleteSale = function (Index: Integer): Integer; stdcall;
  TcbGetBottomLine = function (Index: Integer; var Line: PChar): Integer; stdcall;
  TcbGetDiscountValue = function (): Integer; stdcall;
  TcbGetSale = function (Index: Integer; var Name: PChar; var Price, Qty: Double; var Section: Integer): Integer; stdcall;
  TcbGetTitleLine = function (Index: Integer; var Line: PChar): Integer; stdcall;
  TcbGetSalesCount = function (): Integer; stdcall;
  TcbSetReturnMode = procedure (Mode: Integer); stdcall;
  TcbGetReturnMode = function (): Integer; stdcall;
  TcbSetCash = function (Value: Double): Integer; stdcall;
  TcbGetCash = function (): Double; stdcall;
  TcbSetDiscountValue = function (Value: Integer): Integer; stdcall;
  TcbSetLinesInSale = function (Value: Integer): Integer; stdcall;
  TcbGetLinesInSale = function (): Integer; stdcall;
  TcbGetSum = function (): Double; stdcall;
  TcbGetTitleLinesCount = function (): Integer; stdcall;
  TcbSetClearBufMode = procedure (Mode: Integer); stdcall;
  TcbGetClearBufMode = function (): Integer; stdcall;
  TRepeatCheck = function (): Integer; stdcall;
  TClearIndicator = function (): Integer; stdcall;
  TConnectKKM = function (Port: Integer): Integer; stdcall;
  TDisconnectKKM = procedure ; stdcall;
  TGetDiscountMode = function : Integer; stdcall;
  TGetErrorCode = function : Integer; stdcall;
  TGetErrorMsg = function : PChar; stdcall;
  TFeed = function (LineCount: Integer): Integer; stdcall;
  TGetBroughtSum = function (var Sum: Double): Integer; stdcall;
  TGetCashSum = function (var Sum: Double): Integer; stdcall;
  TGetKKMNum = function (var KKMNum: Integer): Integer; stdcall;
  TGetKLNum = function (var KLNum: Integer): Integer; stdcall;
  TGetNI = function (var NI: Double): Integer; stdcall;
  TGetRemovedQty = function (var Qty: Integer): Integer; stdcall;
  TGetRemovedSum = function (var Sum: Double): Integer; stdcall;
  TGetReturnedSum = function (var Sum: Double): Integer; stdcall;
  TGetReturnedSumOnSection = function (Section: Integer; var Sum: Double): Integer; stdcall;
  TGetSaleCountOnSection = function (Section: Integer; var SaleCount: Integer): Integer; stdcall;
  TGetSaleNum = function (var SaleNum: Integer): Integer; stdcall;
  TGetSalesSumOnSection = function (Section: Integer; var Sum: Double): Integer; stdcall;
  TGetSalesSumWithNDEC = function (var Sum: Double): Integer; stdcall;
  TGetSalesSumWithoutNDEC = function (var Sum: Double): Integer; stdcall;
  TGetKKMVers = function : Integer; stdcall;
  TLock = function : Integer; stdcall;
  TPrintBarCode = function (Code: PChar; DigitFlag: Integer): Integer; stdcall;
  TReadSaleFromKL = function (SaleNum: Integer; var Section, Credit, Discount: Integer; var Sum: Double): Integer; stdcall;
  TStartWaiting = procedure (StopFlag: Integer); stdcall;
  TStopWaiting = procedure ; stdcall;
  TSetSupplierCode = procedure (Code: PChar); stdcall;
  TUnLock = function : Integer; stdcall;
  TWaitingStatus = function : Integer; stdcall;
  TSetChPrepareEvent = procedure (Ptr: TAppCheckPrepare); stdcall;
  TSetErrorEvent = procedure (Ptr: TAppError); stdcall;
  TSetQueryEvent = procedure (Ptr: TAppEvent); stdcall;
  TSetCloseCheckEvent = procedure (Ptr: TAppEvent); stdcall;
  TKKMPrintStr = function (aString: AnsiString):integer; stdcall;

var
  cnOnCheckPrepare: TOnCheckPrepareEvent = nil;
  cnOnError: TOnErrorEvent = nil;
  cnOnQuery: TOnEventEvent = nil;
  cnOnCloseCheck: TOnEventEvent = nil;

var
  cnSetAMS100FEvents: TRTLCriticalSection;

implementation

initialization
  InitializeCriticalSection(cnSetAMS100FEvents);
finalization
  DeleteCriticalSection(cnSetAMS100FEvents);
end.
