unit UFiscalRegisterAMS100FTypes;

interface
  uses UFiscalRegisterAMS100FUtilsTypes;

type
  TAddItemAMS100FEvent = function (aUserData:Pointer; out aTradeName:AnsiString; out aArtName:AnsiString; out aUniStr36:AnsiString; out aSumm, aCount: double; out aShopSection:Cardinal):boolean of object;//result true - out data is set, false - no set out data.
  TOnFiscalPrintIsSuccessEvent = procedure(aUserData:Pointer; aCheckNum, aCheckCount: cardinal) of object;
  TOnWaitForFCBBEvent = procedure(aUserData:Pointer; aCheckNum, aCheckCount: cardinal) of object;

  TfiscalprintResult = (fprPrintedNone, fprPrintedAll, fprPrintedPart);

  IFiscalRegisterAMS100F = interface ['{4CCFE692-9D64-486E-88D8-FCDB51AC4E8F}']
    function GetOnCheckPrepare: TOnCheckPrepareEvent;
    procedure SetOnCheckPrepare(value: TOnCheckPrepareEvent);
    function GetOnError: TOnErrorEvent;
    procedure SetOnError(value: TOnErrorEvent);
    function GetOnQuery: TOnEventEvent;
    procedure SetOnQuery(value: TOnEventEvent);
    function GetOnCloseCheck: TOnEventEvent;
    procedure SetOnCloseCheck(value: TOnEventEvent);
    function GetOnWaitForFCBB: TOnWaitForFCBBEvent;
    procedure SetOnWaitForFCBB(value: TOnWaitForFCBBEvent);
    function GetSaleRowCount: cardinal;
    procedure SetSaleRowCount(value: cardinal);
    //
    property OnCheckPrepare: TOnCheckPrepareEvent read GetOnCheckPrepare write SetOnCheckPrepare;
    property OnError: TOnErrorEvent read GetOnError write SetOnError;
    property OnQuery: TOnEventEvent read GetOnQuery write SetOnQuery;
    property OnCloseCheck: TOnEventEvent read GetOnCloseCheck write SetOnCloseCheck;
    property OnWaitForFCBB: TOnWaitForFCBBEvent read GetOnWaitForFCBB write SetOnWaitForFCBB;
    property SaleRowCount: cardinal read GetSaleRowCount write SetSaleRowCount;//текущее количество прожаж в чеке
    //
    function printfiscalCheckConnected(out aErrorMessage: AnsiString): boolean;
    procedure printfiscalAddTitleLine(const aTitleLine: AnsiString);
    procedure printfiscalAddBottomLine(const aBottomLine: AnsiString);
    function printfiscalSale(aSummAllNal, aSummAllCredit:double; aRowCount: cardinal; aUserData:Pointer; aOnSaleItem: TAddItemAMS100FEvent; aOnFiscalPrintIsSuccess: TOnFiscalPrintIsSuccessEvent):TfiscalprintResult;
    function printfiscalReturn(aSummAllNal, aSummAllCredit:double; aRowCount: cardinal; aUserData:Pointer; aOnReturnItem: TAddItemAMS100FEvent; aOnFiscalPrintIsSuccess: TOnFiscalPrintIsSuccessEvent):TfiscalprintResult;
    procedure printfiscalClearIndicator;
    procedure printfiscalString(const aString:AnsiString);
    procedure printfiscalRepeatCheck;
    procedure printfiscalFeed(aLineCount: Integer);
    procedure printfiscalKeyboardLock;
    procedure printfiscalKeyboardUnlock;
  end;

implementation

end.
