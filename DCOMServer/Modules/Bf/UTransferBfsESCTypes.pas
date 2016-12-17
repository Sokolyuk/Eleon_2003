unit UTransferBfsESCTypes;
  ћодуль нормальный, но технологи€ устарела. см. TransferDoc/TransferDocs/TransferDocManage/TransferBf
interface
  uses UTransferBfsTypes, windows, UCallerTypes, UBfTypes;
type
  TWhere=(wrePGS, wreEMS, wreESC);
  ITransferBfsESC=interface(ITransferBfs)
  ['{E1297C58-8A59-4B89-BCA0-8C5FC4B1ED2E}']
    function Get_RegRootKey:HKEY;
    function Get_RegKeyPath:AnsiString;
    procedure Set_RegRootKey(value:HKEY);
    procedure Set_RegKeyPath(const value:AnsiString);
    property RegRootKey:HKEY read Get_RegRootKey write Set_RegRootKey;
    property RegKeyPath:AnsiString read Get_RegKeyPath write Set_RegKeyPath;
    //..
    function ITAddTransferParaDownload(const aBfName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString; aPTransferParam:PTransferParam; aPTransferProcessEvents:PTransferProcessEvents):AnsiString;
    function ITReceiveBeginParaDownload(aCallerAction:ICallerAction; const aTransferName, aResponderTransferName:AnsiString; aFileTotalSize:Cardinal):Boolean{worked};
    function ITReceiveProcessParaDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString; aTransferedPos:Cardinal; aTransferErrorCount:Integer; aTransferSpeed:double):Boolean{worked};
    function ITReceiveCompleteParaDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString; aTransferErrorCount:Integer; aTransferSpeed:double):Boolean{worked};
    function ITReceiveErrorParaDownload(aCallerAction:ICallerAction; const aTransferName, aErrorMessage:AnsiString; aHelpContext:Integer; aCanceled:Boolean; aTransferErrorCount:Integer):Boolean{worked};
    //..
    function ITBfDelete(const aBfName:AnsiString; aWhere:TWhere; const aConnectionName:AnsiString; aCallerAction:ICallerAction):boolean;
  end;

implementation

end.
