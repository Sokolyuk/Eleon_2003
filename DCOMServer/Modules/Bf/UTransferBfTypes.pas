unit UTransferBfTypes;
  Модуль нормальный, но технология устарела. см. TransferDoc/TransferDocs/TransferDocManage/TransferBf
interface
  uses Windows, UCallerTypes, UPackPDTypes, UBfTypes, UVarsetTypes, UObjectsTypes;
type
  TTransferMode=(trmNone{0}, trmDownload{1}, trmUpload{2}, trmReceiveDownload{3}, trmReceiveUpload{4}, trmParaDownload{}, trmParaUpload);
  TTransferStep=(trsNone{0}, trsTransferResponder{1}, trsReceiveBeginUpload{2}, trsReceiveUpload{3}, trsReceiveEndUpload{4}, trsReceiveBeginDownload{5}, trsReceiveDownload{6}, trsReceiveEndDownload_UNUSED{7}, trsReceiveParaDownload{8}, trsReceiveParaAddDownload{9}, trsReceiveParaBeginDownload{10}, trsReceiveParaProcessDownload{11}, trsReceiveParaCompleteDownload{12});

  ITransferBf=interface(IITObject)
  ['{C4D5BBF5-A95A-4178-906C-2A7C5EFC46D6}']
    function Get_FileHandle:THandle;
    procedure Set_FileHandle(Value:THandle);
    function Get_TableBfName:AnsiString;
    procedure Set_TableBfName(const value:AnsiString);
    function Get_TableBfDate:TDateTime;
    procedure Set_TableBfDate(Value:TDateTime);
    function Get_FileTotalSize:Cardinal;
    procedure Set_FileTotalSize(Value:Cardinal);
    function Get_TableBfCommentary:AnsiString;
    procedure Set_TableBfCommentary(const value:AnsiString);
    function Get_TransferMode:TTransferMode;
    procedure Set_TransferMode(Value:TTransferMode);
    function Get_TransferStep:TTransferStep;
    procedure Set_TransferStep(Value:TTransferStep);
    function Get_BeginTime:TDateTime;
    procedure Set_BeginTime(Value:TDateTime);
    function Get_LastSessionBeginTime:TDateTime;
    procedure Set_LastSessionBeginTime(Value:TDateTime);
    function Get_LastAccessTime:TDateTime;
    procedure Set_LastAccessTime(Value:TDateTime);
    function Get_BfName:AnsiString;
    procedure Set_BfName(const value:AnsiString);
    function Get_TableBfChecksum:Integer;
    procedure Set_TableBfChecksum(Value:Integer);
    function Get_LastSessionTransferedSize:Cardinal;
    procedure Set_LastSessionTransferedSize(Value:Cardinal);
    function Get_CallerActions:IVarset;
    function Get_TransferPackPD:IPackPD;
    procedure Set_TransferPackPD(Value:IPackPD);
    function Get_TransferName:AnsiString;
    procedure Set_TransferName(const value:AnsiString);
    function Get_ResponderTransferName:AnsiString;
    procedure Set_ResponderTransferName(const value:AnsiString);
    function Get_TableBfDir:AnsiString;
    procedure Set_TableBfDir(const value:AnsiString);
    function Get_LockOwner:Integer;
    procedure Set_LockOwner(Value:Integer);
    function Get_CachePath:AnsiString;
    procedure Set_CachePath(const value:AnsiString);
    function Get_TransferAuto:Boolean;
    procedure Set_TransferAuto(Value:Boolean);
    function Get_TransferProcessToSender:Boolean;
    procedure Set_TransferProcessToSender(Value:Boolean);
    function Get_TransferErrorCount:Integer;
    procedure Set_TransferErrorCount(Value:Integer);
    function Get_Active:Boolean;
    procedure Set_Active(Value:Boolean);
    function Get_TransferErrorLastMessage:AnsiString;
    procedure Set_TransferErrorLastMessage(const value:AnsiString);
    function Get_TransferErrorLastHelpContext:Integer;
    procedure Set_TransferErrorLastHelpContext(Value:Integer);
    function Get_TransferProcessEvents:TTransferProcessEvents;
    procedure Set_TransferProcessEvents(Value:TTransferProcessEvents);
    function Get_TransferParam:TTransferParam;
    procedure Set_TransferParam(Value:TTransferParam);
    function Get_ConnectionName:AnsiString;
    procedure Set_ConnectionName(const value:AnsiString);
    function Get_TransferSpeed:double;
    procedure Set_TransferSpeed(Value:double);
    function Get_SequenceNumber:Cardinal;
    procedure Set_SequenceNumber(value:Cardinal);
    function Get_RealBfLocation:AnsiString;
    function Get_RealBfDir:AnsiString;
    function Get_RealBfUsedCacheDir:Boolean;
    function Get_TransferResponder:AnsiString;
    procedure Set_TransferResponder(const value:AnsiString);
    function Get_TransferDirection:TTransferDirection;
    procedure Set_TransferDirection(Value:TTransferDirection);
    //------------------------------------------------------------------------------------
    procedure ITSetTransferLockWait;
    procedure ITFreeTransferLock;
    //------------------------------------------------------------------------------------
    property BfName:AnsiString read Get_BfName write Set_BfName;
    //Table info
    property TableBfDir:AnsiString read Get_TableBfDir write Set_TableBfDir;
    property TableBfName:AnsiString read Get_TableBfName write Set_TableBfName;
    property TableBfChecksum:Integer read Get_TableBfChecksum write Set_TableBfChecksum;
    property TableBfDate:TDateTime read Get_TableBfDate write Set_TableBfDate;
    property TableBfCommentary:AnsiString read Get_TableBfCommentary write Set_TableBfCommentary;
    //..
    property TransferResponder:AnsiString read Get_TransferResponder write Set_TransferResponder;
    property TransferDirection:TTransferDirection read Get_TransferDirection write Set_TransferDirection;
    //..
    property FileHandle:THandle read Get_FileHandle write Set_FileHandle;
    property FileTotalSize:Cardinal read Get_FileTotalSize write Set_FileTotalSize;
    //Transfer
    property TransferProcessToSender:Boolean read Get_TransferProcessToSender write Set_TransferProcessToSender;
    property TransferAuto:Boolean read Get_TransferAuto write Set_TransferAuto;
    property TransferMode:TTransferMode read Get_TransferMode write Set_TransferMode;
    property TransferStep:TTransferStep read Get_TransferStep write Set_TransferStep;
    //property TransferFrom:TTransferFrom read Get_TransferFrom write Set_TransferFrom;//Откуда можно качать блоб.
    //property TransferedFrom:TTransferFrom read Get_TransferedFrom write Set_TransferedFrom;//Откуда можно качать блоб.
    property TransferErrorCount:Integer read Get_TransferErrorCount write Set_TransferErrorCount;
    property LastSessionTransferedSize:Cardinal read Get_LastSessionTransferedSize write Set_LastSessionTransferedSize;
    property TransferSpeed:Double read Get_TransferSpeed write Set_TransferSpeed;
    property ConnectionName:AnsiString read Get_ConnectionName write Set_ConnectionName;
    property TransferName:AnsiString read Get_TransferName write Set_TransferName;
    property ResponderTransferName:AnsiString read Get_ResponderTransferName write Set_ResponderTransferName;
    property TransferProcessEvents:TTransferProcessEvents read Get_TransferProcessEvents write Set_TransferProcessEvents;
    property TransferParam:TTransferParam read Get_TransferParam write Set_TransferParam;
    property BeginTime:TDateTime read Get_BeginTime write Set_BeginTime;
    property LastSessionBeginTime:TDateTime read Get_LastSessionBeginTime write Set_LastSessionBeginTime;
    property LastAccessTime:TDateTime read Get_LastAccessTime write Set_LastAccessTime;
    //Support
    property LockOwner:Integer read Get_LockOwner write Set_LockOwner;
    property TransferPackPD:IPackPD read Get_TransferPackPD write Set_TransferPackPD;
    property CallerActions:IVarset read Get_CallerActions;
    function Get_CallerActionFirst:ICallerAction;
    property CallerActionFirst:ICallerAction read Get_CallerActionFirst;
    procedure CallerActionAdd(aCallerAction:ICallerAction; aRaiseNonUnique:Boolean);
    function CallerActionViewNextGetOfIntIndex(var aIntIndex:Integer):ICallerAction;
    property CachePath:AnsiString read Get_CachePath write Set_CachePath;
    property Active:Boolean read Get_Active write Set_Active;
    property TransferErrorLastMessage:AnsiString read Get_TransferErrorLastMessage write Set_TransferErrorLastMessage;
    property TransferErrorLastHelpContext:Integer read Get_TransferErrorLastHelpContext write Set_TransferErrorLastHelpContext;
    property SequenceNumber:Cardinal read Get_SequenceNumber write Set_SequenceNumber;
    //..
    function Get_BfType:Integer;
    procedure Set_BfType(Value:Integer);
    function Get_TransferPos:Cardinal;
    procedure Set_TransferPos(Value:Cardinal);
    function Get_Transfering:Boolean;
    procedure Set_Transfering(Value:Boolean);
    function Get_TransferChecksum:Integer;
    procedure Set_TransferChecksum(Value:Integer);
    function Get_TransferSchedule:AnsiString;
    procedure Set_TransferSchedule(const value:AnsiString);
    property BfType:Integer read Get_BfType write Set_BfType;
    property TransferPos:Cardinal read Get_TransferPos write Set_TransferPos;
    property Transfering:Boolean read Get_Transfering write Set_Transfering;
    property TransferChecksum:Integer read Get_TransferChecksum write Set_TransferChecksum;
    property TransferSchedule:AnsiString read Get_TransferSchedule write Set_TransferSchedule;
    //..
    property RealBfLocation:AnsiString read Get_RealBfLocation;
    property RealBfDir:AnsiString read Get_RealBfDir;
    property RealBfUsedCacheDir:Boolean read Get_RealBfUsedCacheDir;
    //..
    function Get_UseOwnPathAndFileName:boolean;
    procedure Set_UseOwnPathAndFileName(value:boolean);
    property UseOwnPathAndFileName:boolean read Get_UseOwnPathAndFileName write Set_UseOwnPathAndFileName;
  end;

implementation

end.
