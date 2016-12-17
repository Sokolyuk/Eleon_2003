unit UTransferBf;
  Модуль нормальный, но технология устарела. см. TransferDoc/TransferDocs/TransferDocManage/TransferBf
interface
  uses Windows, UTransferBfTypes, UITObject, UObjectsTypes, UCallerTypes, UPackPDTypes, UBfTypes,
       UVarsetTypes, USyncTypes;
type
  TTransferBf=class(TITObject, ITransferBf)
  private
    FFileHandle:THandle;
    FTableBfName:AnsiString;
    FTableBfDir{Path}:AnsiString;
    FTableBfDate:TDateTime;
    FFileTotalSize:Cardinal;
    FTableBfCommentary:AnsiString;
    FTransferMode:TTransferMode;
    FTransferStep:TTransferStep;
    FBeginTime:TDateTime;
    FLastSessionBeginTime:TDateTime;
    FLastAccessTime:TDateTime;
    FBfName:AnsiString;
    FTableBfChecksum:Integer;
    FLastSessionTransferedSize:Cardinal;
    FCallerActions:IVarset;
    FTransferPackPD:IPackPD;
    FTransferName:AnsiString;
    FResponderTransferName:AnsiString;
    FLockOwner:Integer;
    FCachePath:AnsiString;
    FTransferAuto:Boolean;
    FTransferProcessToSender:Boolean;
    FTransferErrorCount:Integer;
    FActive:Boolean;
    FTransferErrorLastMessage:AnsiString;
    FTransferErrorLastHelpContext:Integer;
    FTransferProcessEvents:TTransferProcessEvents;
    FConnectionName:AnsiString;
    FTransferSpeed:Double;
    FSequenceNumber:Cardinal;
    FBfType:Integer;
    FTransferPos:Cardinal;
    FTransfering:Boolean;
    FTransferChecksum:Integer;
    FTransferSchedule:AnsiString;
    FUseOwnPathAndFileName:boolean;
    FTransferResponder:AnsiString;
    FTransferDirection:TTransferDirection;
    FSync:ISync;
  protected
    function InternalGetISync:ISync;virtual;
  protected
    procedure ITSetTransferLockWait;virtual;
    procedure ITFreeTransferLock;virtual;
    procedure ITransferBf{IITObject}.ITLock=InternalLock;
    procedure ITransferBf{IITObject}.ITLockWait=InternalLockWait;
    function ITransferBf{IITObject}.ITTryLock=InternalTryLock;
    procedure ITransferBf{IITObject}.ITUnlock=InternalUnLock;
    //..
    function Get_FileHandle:THandle;virtual;
    procedure Set_FileHandle(Value:THandle);virtual;
    function Get_TableBfName:AnsiString;virtual;
    procedure Set_TableBfName(const value:AnsiString);virtual;
    function Get_TableBfDate:TDateTime;virtual;
    procedure Set_TableBfDate(Value:TDateTime);virtual;
    function Get_FileTotalSize:Cardinal;virtual;
    procedure Set_FileTotalSize(Value:Cardinal);virtual;
    function Get_TableBfCommentary:AnsiString;virtual;
    procedure Set_TableBfCommentary(const value:AnsiString);virtual;
    function Get_TransferMode:TTransferMode;virtual;
    procedure Set_TransferMode(Value:TTransferMode);virtual;
    function Get_BeginTime:TDateTime;virtual;
    procedure Set_BeginTime(Value:TDateTime);virtual;
    function Get_LastSessionBeginTime:TDateTime;virtual;
    procedure Set_LastSessionBeginTime(Value:TDateTime);virtual;
    function Get_LastAccessTime:TDateTime;virtual;
    procedure Set_LastAccessTime(Value:TDateTime);virtual;
    function Get_BfName:AnsiString;virtual;
    procedure Set_BfName(const value:AnsiString);virtual;
    function Get_TableBfChecksum:Integer;virtual;
    procedure Set_TableBfChecksum(Value:Integer);virtual;
    function Get_LastSessionTransferedSize:Cardinal;virtual;
    procedure Set_LastSessionTransferedSize(Value:Cardinal);virtual;
    function Get_CallerActions:IVarset;virtual;
    function Get_TransferPackPD:IPackPD;virtual;
    procedure Set_TransferPackPD(Value:IPackPD);virtual;
    function Get_TransferStep:TTransferStep;virtual;
    procedure Set_TransferStep(Value:TTransferStep);virtual;
    function Get_TransferName:AnsiString;virtual;
    procedure Set_TransferName(const value:AnsiString);virtual;
    function Get_ResponderTransferName:AnsiString;virtual;
    procedure Set_ResponderTransferName(const value:AnsiString);virtual;
    function Get_TableBfDir:AnsiString;virtual;
    procedure Set_TableBfDir(const value:AnsiString);virtual;
    function Get_LockOwner:Integer;virtual;
    procedure Set_LockOwner(Value:Integer);virtual;
    function Get_CachePath:AnsiString;virtual;
    procedure Set_CachePath(const value:AnsiString);virtual;
    function Get_TransferAuto:Boolean;virtual;
    procedure Set_TransferAuto(Value:Boolean);virtual;
    function Get_TransferProcessToSender:Boolean;virtual;
    procedure Set_TransferProcessToSender(Value:Boolean);virtual;
    function Get_TransferErrorCount:Integer;virtual;
    procedure Set_TransferErrorCount(Value:Integer);virtual;
    function Get_Active:Boolean;virtual;
    procedure Set_Active(Value:Boolean);virtual;
    function Get_TransferErrorLastMessage:AnsiString;virtual;
    procedure Set_TransferErrorLastMessage(const value:AnsiString);virtual;
    function Get_TransferErrorLastHelpContext:Integer;virtual;
    procedure Set_TransferErrorLastHelpContext(Value:Integer);virtual;
    function Get_TransferProcessEvents:TTransferProcessEvents;virtual;
    procedure Set_TransferProcessEvents(Value:TTransferProcessEvents);virtual;
    function Get_TransferParam:TTransferParam;virtual;
    procedure Set_TransferParam(Value:TTransferParam);virtual;
    function Get_ConnectionName:AnsiString;virtual;
    procedure Set_ConnectionName(const value:AnsiString);virtual;
    function Get_TransferSpeed:double;virtual;
    procedure Set_TransferSpeed(Value:double);virtual;
    function Get_SequenceNumber:Cardinal;virtual;
    procedure Set_SequenceNumber(value:Cardinal);virtual;
    function Get_BfType:Integer;virtual;
    procedure Set_BfType(Value:Integer);virtual;
    function Get_TransferPos:Cardinal;virtual;
    procedure Set_TransferPos(Value:Cardinal);virtual;
    function Get_Transfering:Boolean;virtual;
    procedure Set_Transfering(Value:Boolean);virtual;
    function Get_TransferChecksum:Integer;virtual;
    procedure Set_TransferChecksum(Value:Integer);virtual;
    function Get_TransferSchedule:AnsiString;virtual;
    procedure Set_TransferSchedule(const value:AnsiString);virtual;
    function Get_RealBfLocation:AnsiString;virtual;
    function Get_RealBfDir:AnsiString;virtual;
    function Get_RealBfUsedCacheDir:Boolean;virtual;
    function Get_UseOwnPathAndFileName:boolean;virtual;
    procedure Set_UseOwnPathAndFileName(value:boolean);virtual;
    function Get_TransferResponder:AnsiString;virtual;
    procedure Set_TransferResponder(const value:AnsiString);virtual;
    function Get_TransferDirection:TTransferDirection;virtual;
    procedure Set_TransferDirection(Value:TTransferDirection);virtual;
  public
    constructor Create{(aProgramRunMode:TProgramRunMode)};
    destructor Destroy; override;
    //..
    property BfName:AnsiString read Get_BfName write Set_BfName;
    property FileHandle:THandle read Get_FileHandle write Set_FileHandle;
    property TableBfName:AnsiString read Get_TableBfName write Set_TableBfName;
    property TableBfDir:AnsiString read Get_TableBfDir write Set_TableBfDir;
    property TableBfDate:TDateTime read Get_TableBfDate write Set_TableBfDate;
    property FileTotalSize:Cardinal read Get_FileTotalSize write Set_FileTotalSize;
    property TableBfCommentary:AnsiString read Get_TableBfCommentary write Set_TableBfCommentary;
    property TransferAuto:Boolean read Get_TransferAuto write Set_TransferAuto;
    property TransferProcessToSender:Boolean read Get_TransferProcessToSender write Set_TransferProcessToSender;
    property TransferMode:TTransferMode read Get_TransferMode write Set_TransferMode;
    property TransferStep:TTransferStep read Get_TransferStep write Set_TransferStep;
    property TransferErrorCount:Integer read Get_TransferErrorCount write Set_TransferErrorCount;
    property BeginTime:TDateTime read Get_BeginTime write Set_BeginTime;
    property LastSessionBeginTime:TDateTime read Get_LastSessionBeginTime write Set_LastSessionBeginTime;
    property LastAccessTime:TDateTime read Get_LastAccessTime write Set_LastAccessTime;
    property TableBfChecksum:Integer read Get_TableBfChecksum write Set_TableBfChecksum;
    property LastSessionTransferedSize:Cardinal read Get_LastSessionTransferedSize write Set_LastSessionTransferedSize;
    property TransferSpeed:Double read Get_TransferSpeed write Set_TransferSpeed;
    property CallerActions:IVarset read Get_CallerActions;
    function Get_CallerActionFirst:ICallerAction;virtual;
    property CallerActionFirst:ICallerAction read Get_CallerActionFirst;
    procedure CallerActionAdd(aCallerAction:ICallerAction; aRaiseNonUnique:Boolean);virtual;
    function CallerActionViewNextGetOfIntIndex(Var aIntIndex:Integer):ICallerAction;virtual;
    property TransferPackPD:IPackPD read Get_TransferPackPD write Set_TransferPackPD;
    property TransferName:AnsiString read Get_TransferName write Set_TransferName;
    property ResponderTransferName:AnsiString read Get_ResponderTransferName write Set_ResponderTransferName;
    property LockOwner:Integer read Get_LockOwner write Set_LockOwner;
    property CachePath:AnsiString read Get_CachePath write Set_CachePath;
    property Active:Boolean read Get_Active write Set_Active;
    property TransferErrorLastMessage:AnsiString read Get_TransferErrorLastMessage write Set_TransferErrorLastMessage;
    property TransferErrorLastHelpContext:Integer read Get_TransferErrorLastHelpContext write Set_TransferErrorLastHelpContext;
    property TransferProcessEvents:TTransferProcessEvents read Get_TransferProcessEvents write Set_TransferProcessEvents;
    property TransferParam:TTransferParam read Get_TransferParam write Set_TransferParam;
    property ConnectionName:AnsiString read Get_ConnectionName write Set_ConnectionName;
    property SequenceNumber:Cardinal read Get_SequenceNumber write Set_SequenceNumber;
    property BfType:Integer read Get_BfType write Set_BfType;
    property TransferPos:Cardinal read Get_TransferPos write Set_TransferPos;
    property Transfering:Boolean read Get_Transfering write Set_Transfering;
    property TransferChecksum:Integer read Get_TransferChecksum write Set_TransferChecksum;
    property TransferSchedule:AnsiString read Get_TransferSchedule write Set_TransferSchedule;
    //..
    property RealBfLocation:AnsiString read Get_RealBfLocation;
    property RealBfDir:AnsiString read Get_RealBfDir;
    property RealBfUsedCacheDir:Boolean read Get_RealBfUsedCacheDir;
    property UseOwnPathAndFileName:boolean read Get_UseOwnPathAndFileName write Set_UseOwnPathAndFileName;
    //..
    property TransferResponder:AnsiString read Get_TransferResponder write Set_TransferResponder;
    property TransferDirection:TTransferDirection read Get_TransferDirection write Set_TransferDirection;
  end;

implementation
  uses SysUtils, {$warnings off}FileCtrl{$warnings on}, UBfUtils, UVarset, UTransferConsts, UErrorConsts, UTrayConsts,
       UTrayTypes;

constructor TTransferBf.Create;
begin
  Inherited Create;
  FFileHandle:=0;
  FTableBfName:='';
  FTableBfDir{Path}:='';
  FTableBfDate:=0;
  FFileTotalSize:=0;
  FTableBfCommentary:='';
  FBeginTime:=0;
  FLastSessionBeginTime:=0;
  FLastAccessTime:=0;
  FBfName:='';
  FTableBfChecksum:=0;
  FLastSessionTransferedSize:=0;
  FCallerActions:=TVarset.Create;
  FCallerActions.ITConfigIntIndexAssignable:=False;
  FCallerActions.ITConfigCheckUniqueIntIndex:=False;
  FCallerActions.ITConfigCheckUniqueStrIndex:=False;
  FCallerActions.ITConfigNoFoundException:=True;
  FTransferPackPD:=nil;
  FTransferMode:=trmNone;
  FTransferStep:=trsNone;
  FResponderTransferName:='';
  FTransferName:='';
  FLockOwner:=-1;
  FCachePath:='';
  FTransferAuto:=True;
  FTransferErrorCount:=0;
  FTransferProcessToSender:=False;
  FActive:=False;
  FTransferErrorLastMessage:='';
  FTransferErrorLastHelpContext:=0;
  //FTransferFrom:=trfFarServer;//По умолчанию качать можно с пегаса.
  //FTransferedFrom:=trfFarServer;//По умолчанию качать можно отовсюду.
  Fillchar(FTransferProcessEvents, Sizeof(FTransferProcessEvents), 0);
  FConnectionName:='';
  FTransferSpeed:=0;
  FSequenceNumber:=0;
  FBfType:=0;
  FTransferPos:=0;
  FTransfering:=False;
  FTransferChecksum:=0;
  FTransferSchedule:='';
  FUseOwnPathAndFileName:=False;
  FTransferResponder:='';
  FTransferDirection:=trdDownloadClient;
end;

destructor TTransferBf.Destroy;
begin
  If FFileHandle<>0 Then Closehandle(FFileHandle);
  FTransferSchedule:='';
  FTransferResponder:='';
  FCachePath:='';
  FTableBfName:='';
  FTableBfDir{Path}:='';
  FTableBfCommentary:='';
  FResponderTransferName:='';
  FTransferErrorLastMessage:='';
  FConnectionName:='';
  If FLockOwner<>-1 Then begin
    try InternalGetISync.ITClearLockOwner(FLockOwner);except end;   
    FLockOwner:=-1;
  end;
  FCallerActions:=nil;
  FTransferPackPD:=nil;
  Inherited Destroy;
end;

function TTransferBf.Get_BfType:Integer;
begin
  Result:=FBfType;
end;

procedure TTransferBf.Set_BfType(Value:Integer);
begin
  FBfType:=Value;
end;

function TTransferBf.Get_TransferPos:Cardinal;
begin
  Result:=FTransferPos;
end;

procedure TTransferBf.Set_TransferPos(Value:Cardinal);
begin
  FTransferPos:=Value;
end;

function TTransferBf.Get_Transfering:Boolean;
begin
  Result:=FTransfering;
end;

procedure TTransferBf.Set_Transfering(Value:Boolean);
begin
  FTransfering:=Value;
end;

function TTransferBf.Get_TransferChecksum:Integer;
begin
  Result:=FTransferChecksum;
end;

procedure TTransferBf.Set_TransferChecksum(Value:Integer);
begin
  FTransferChecksum:=Value;
end;

function TTransferBf.Get_TransferSchedule:AnsiString;
begin
  Result:=FTransferSchedule;
end;

procedure TTransferBf.Set_TransferSchedule(const value:AnsiString);
begin
  FTransferSchedule:=Value;
end;

function TTransferBf.Get_FileHandle:THandle;
begin
  Result:=FFileHandle;
end;

procedure TTransferBf.Set_FileHandle(Value:THandle);
begin
  If FFileHandle<>Value Then begin
    If (FFileHandle<>0)And(FFileHandle<>$FFFFFFFF) Then try Closehandle(FFileHandle); except end;
    FFileHandle:=Value;
  end;
end;

function TTransferBf.Get_TableBfName:AnsiString;
begin
  Result:=FTableBfName;
end;

procedure TTransferBf.Set_TableBfName(const value:AnsiString);
begin
  FTableBfName:=Value;
end;

function TTransferBf.Get_TableBfDate:TDateTime;
begin
  Result:=FTableBfDate;
end;

procedure TTransferBf.Set_TableBfDate(Value:TDateTime);
begin
  FTableBfDate:=Value;
end;

function TTransferBf.Get_FileTotalSize:Cardinal;
begin
  Result:=FFileTotalSize;
end;

procedure TTransferBf.Set_FileTotalSize(Value:Cardinal);
begin
  FFileTotalSize:=Value;
end;

function TTransferBf.Get_TableBfCommentary:AnsiString;
begin
  Result:=FTableBfCommentary;
end;

procedure TTransferBf.Set_TableBfCommentary(const value:AnsiString);
begin
  FTableBfCommentary:=Value;
end;

function TTransferBf.Get_TransferMode:TTransferMode;
begin
  Result:=FTransferMode;
end;

procedure TTransferBf.Set_TransferMode(Value:TTransferMode);
begin
  FTransferMode:=Value;
end;

function TTransferBf.Get_BeginTime:TDateTime;
begin
  Result:=FBeginTime;
end;

procedure TTransferBf.Set_BeginTime(Value:TDateTime);
begin
  FBeginTime:=Value;
end;

function TTransferBf.Get_LastSessionBeginTime:TDateTime;
begin
  Result:=FLastSessionBeginTime;
end;

procedure TTransferBf.Set_LastSessionBeginTime(Value:TDateTime);
begin
  FLastSessionBeginTime:=Value;
end;

function TTransferBf.Get_LastAccessTime:TDateTime;
begin
  Result:=FLastAccessTime;
end;

procedure TTransferBf.Set_LastAccessTime(Value:TDateTime);
begin
  FLastAccessTime:=Value;
end;

function TTransferBf.Get_BfName:AnsiString;
begin
  Result:=FBfName;
end;

procedure TTransferBf.Set_BfName(const value:AnsiString);
begin
  FBfName:=Value;
end;

{function TTransferBf.Get_IdLocal:Integer;
begin
  Result:=FIdLocal;
end;

procedure TTransferBf.Set_IdLocal(Value:Integer);
begin
  FIdLocal:=Value;
end;
}
function TTransferBf.Get_TableBfChecksum:Integer;
begin
  Result:=FTableBfChecksum;
end;

procedure TTransferBf.Set_TableBfChecksum(Value:Integer);
begin
  FTableBfChecksum:=Value;
end;

function TTransferBf.Get_LastSessionTransferedSize:Cardinal;
begin
  Result:=FLastSessionTransferedSize;
end;

procedure TTransferBf.Set_LastSessionTransferedSize(Value:Cardinal);
begin
  FLastSessionTransferedSize:=Value;
end;

function TTransferBf.Get_CallerActions:IVarset;
begin
  Result:=FCallerActions;
end;

procedure TTransferBf.CallerActionAdd(aCallerAction:ICallerAction; aRaiseNonUnique:Boolean);
  var tmpIntIndex:integer;
      tmpIUnknown:IUnknown;
      tmpCallerAction:ICallerAction;
begin
  Internallock;
  try
    //Проверочка на повторение aCallerAction.
    tmpIntIndex:=-1;
    while true do begin
      tmpIUnknown:=FCallerActions.ITViewNextDataGetOfIntIndex(tmpIntIndex);
      if tmpIntIndex=-1 then break;
      if (not assigned(tmpIUnknown))or(tmpIUnknown.QueryInterface(ICallerAction, tmpCallerAction)<>S_OK)Or(not assigned(tmpCallerAction)) then raise exception.createFmtHelp(cserInvalidValueOf, ['ICallerAction'], cnerInvalidValueOf);
      if Pointer(tmpCallerAction)=Pointer(aCallerAction) Then begin
        if aRaiseNonUnique then raise exception.create('Such CallerAction already exists.') else exit;
      end;
    end;
    //Добавляю
    FCallerActions.ITPushV(aCallerAction);
  finally
    Internalunlock;
  end;
end;

function TTransferBf.Get_CallerActionFirst:ICallerAction;
  Var tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
      tmpIntIndex:Integer;
begin
  Internallock;
  try
    If FCallerActions.ITCount=0 Then Raise Exception.Create('No callerAction ');
    tmpIntIndex:=-1;
    tmpIVarsetDataView:=FCallerActions.ITViewNextGetOfIntIndex(tmpIntIndex);
    If not assigned(tmpIVarsetDataView) Then Raise Exception.Create('tmpIVarsetDataView is not assigned.');
    tmpIUnknown:=tmpIVarsetDataView.ITData;
    If (not assigned(tmpIUnknown))Or(tmpIUnknown.QueryInterface(ICallerAction, Result)<>S_OK)Or(not assigned(Result)) Then Raise Exception.Create('error at query interface.');
    tmpIVarsetDataView:=nil;
    tmpIUnknown:=nil;
  finally
    Internalunlock;
  end;
end;

function TTransferBf.CallerActionViewNextGetOfIntIndex(Var aIntIndex:Integer):ICallerAction;
  Var tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
begin
  Internallock;
  try
    Result:=nil;
    tmpIVarsetDataView:=FCallerActions.ITViewNextGetOfIntIndex(aIntIndex);
    If (aIntIndex=-1)Or(not assigned(tmpIVarsetDataView)) Then Exit;
    tmpIUnknown:=tmpIVarsetDataView.ITData;
    If (not assigned(tmpIUnknown))Or(tmpIUnknown.QueryInterface(ICallerAction, Result)<>S_OK)Or(not assigned(Result)) Then Raise Exception.Create('error at query interface.');
    tmpIVarsetDataView:=nil;
    tmpIUnknown:=nil;
  finally
    Internalunlock;
  end;
end;

function TTransferBf.Get_TransferPackPD:IPackPD;
begin
  Result:=FTransferPackPD;
end;

procedure TTransferBf.Set_TransferPackPD(Value:IPackPD);
begin
  FTransferPackPD:=Value;
end;

function TTransferBf.Get_TransferStep:TTransferStep;
begin
  Result:=FTransferStep;
end;

procedure TTransferBf.Set_TransferStep(Value:TTransferStep);
begin
  FTransferStep:=Value;
end;

function TTransferBf.Get_ResponderTransferName:AnsiString;
begin
  Result:=FResponderTransferName;
end;

procedure TTransferBf.Set_ResponderTransferName(const value:AnsiString);
begin
  FResponderTransferName:=Value;
end;

function TTransferBf.Get_TableBfDir:AnsiString;
begin
  Result:=FTableBfDir;
end;

procedure TTransferBf.Set_TableBfDir(const value:AnsiString);
begin
  FTableBfDir:=Value;
end;

function TTransferBf.Get_LockOwner:Integer;
begin
  Result:=FLockOwner;
end;

procedure TTransferBf.Set_LockOwner(Value:Integer);
begin
  If FLockOwner<>-1 Then InternalGetISync.ITClearLockOwner(FLockOwner);
  FLockOwner:=Value;
end;

function TTransferBf.Get_CachePath:AnsiString;
begin
  result:=FCachePath;
end;

procedure TTransferBf.Set_CachePath(const value:AnsiString);
begin
  If value=FCachePath Then Exit;
  If (Value<>'')And(Value[Length(Value)]<>'\') Then FCachePath:=Value+'\' else FCachePath:=Value;
end;

function TTransferBf.Get_TransferAuto:Boolean;
begin
  Result:=FTransferAuto;
end;

procedure TTransferBf.Set_TransferAuto(Value:Boolean);
begin
  FTransferAuto:=Value;
end;

function TTransferBf.Get_TransferProcessToSender:Boolean;
begin
  Result:=FTransferProcessToSender;
end;

procedure TTransferBf.Set_TransferProcessToSender(Value:Boolean);
begin
  FTransferProcessToSender:=Value;
end;

function TTransferBf.Get_TransferErrorCount:Integer;
begin
  Result:=FTransferErrorCount;
end;

procedure TTransferBf.Set_TransferErrorCount(Value:Integer);
begin
  FTransferErrorCount:=Value;
end;

function TTransferBf.Get_Active:Boolean;
begin
  Result:=FActive;
end;

procedure TTransferBf.Set_Active(Value:Boolean);
begin
  FActive:=Value;
end;

function TTransferBf.Get_TransferErrorLastMessage:AnsiString;
begin
  Result:=FTransferErrorLastMessage;
end;

procedure TTransferBf.Set_TransferErrorLastMessage(const value:AnsiString);
begin
  FTransferErrorLastMessage:=Value;
end;

function TTransferBf.Get_TransferErrorLastHelpContext:Integer;
begin
  Result:=FTransferErrorLastHelpContext;
end;

procedure TTransferBf.Set_TransferErrorLastHelpContext(Value:Integer);
begin
  FTransferErrorLastHelpContext:=Value;
end;

{function TTransferBf.Get_TransferFrom:TTransferFrom;
begin
  Result:=FTransferFrom;
end;

procedure TTransferBf.Set_TransferFrom(Value:TTransferFrom);
begin
  FTransferFrom:=Value;
end;

function TTransferBf.Get_TransferedFrom:TTransferFrom;
begin
  Result:=FTransferedFrom;
end;

procedure TTransferBf.Set_TransferedFrom(Value:TTransferFrom);
begin
  FTransferedFrom:=Value;
end;{}

function TTransferBf.Get_TransferProcessEvents:TTransferProcessEvents;
begin
  Result:=FTransferProcessEvents;
end;

procedure TTransferBf.Set_TransferProcessEvents(Value:TTransferProcessEvents);
begin
  FTransferProcessEvents:=Value;
end;

function TTransferBf.Get_TransferParam:TTransferParam;
begin
  result.TransferAuto:=FTransferAuto;
  result.TransferProcessToSender:=FTransferProcessToSender;
  result.TransferResponder:=FTransferResponder;
  result.Path:=FTableBfDir;
  result.FileName:=FTableBfName;
end;

procedure TTransferBf.Set_TransferParam(Value:TTransferParam);
begin
  TransferAuto:=value.TransferAuto;
  TransferProcessToSender:=value.TransferProcessToSender;
  TransferResponder:=value.TransferResponder;
  TableBfDir:=value.Path;
  TableBfName:=value.FileName;
end;

function TTransferBf.Get_ConnectionName:AnsiString;
begin
  Result:=FConnectionName;
end;

procedure TTransferBf.Set_ConnectionName(const value:AnsiString);
begin
  FConnectionName:=Value;
end;

function TTransferBf.Get_TransferSpeed:double;
begin
  Result:=FTransferSpeed;
end;

procedure TTransferBf.Set_TransferSpeed(Value:double);
begin
  FTransferSpeed:=Value;
end;

function TTransferBf.Get_SequenceNumber:Cardinal;
begin
  result:=FSequenceNumber;
end;

procedure TTransferBf.Set_SequenceNumber(value:Cardinal);
begin
  FSequenceNumber:=Value;
end;

function TTransferBf.Get_RealBfLocation:AnsiString;
begin
  Result:=Get_RealBfDir+FTableBfName;
end;

function TTransferBf.Get_RealBfDir:AnsiString;
begin
  if Get_RealBfUsedCacheDir then Result:=FCachePath+FTableBfDir else Result:=FTableBfDir;
end;

function TTransferBf.Get_RealBfUsedCacheDir:Boolean;
begin
  Result:=glUsedCachePath(FTableBfDir);
end;

function TTransferBf.Get_UseOwnPathAndFileName:Boolean;
begin
  Result:=FUseOwnPathAndFileName;
end;

procedure TTransferBf.Set_UseOwnPathAndFileName(Value:Boolean);
begin
  FUseOwnPathAndFileName:=Value;
end;

procedure TTransferBf.ITSetTransferLockWait;
begin
  if FLockOwner=-1 then raise exception.createFmtHelp(cserInternalError, ['ITSetTransferLockWait: FLockOwner=-1'], cnerInternalError);
  InternalGetISync.ITSetLockWait(csllTransfer+FBfName, CallerActionFirst, FLockOwner, True, cnTransferLockWait, true);
end;

procedure TTransferBf.ITFreeTransferLock;
begin
  if FLockOwner=-1 then raise exception.createFmtHelp(cserInternalError, ['ITSetTransferLockWait: FLockOwner=-1'], cnerInternalError);
  InternalGetISync.ITFreeLock(csllTransfer+FBfName, FLockOwner);
end;

function TTransferBf.Get_TransferResponder:AnsiString;
begin
  Result:=FTransferResponder;
end;

procedure TTransferBf.Set_TransferResponder(const value:AnsiString);
begin
  FTransferResponder:=Value;
end;

function TTransferBf.Get_TransferDirection:TTransferDirection;
begin
  Result:=FTransferDirection;
end;

procedure TTransferBf.Set_TransferDirection(Value:TTransferDirection);
begin
  FTransferDirection:=Value;
end;

function TTransferBf.InternalGetISync:ISync;
  var tmpTray:ITray;
begin
  if not assigned(FSync) then begin
    tmpTray:=cnTray;
    if not assigned(tmpTray) then raise exception.create('cnTray is not assigned.');
    tmpTray.Query(ISync, FSync);
  end;
  result:=FSync;
end;
function TTransferBf.Get_TransferName:AnsiString;
begin
  result:=FTransferName;
end;

procedure TTransferBf.Set_TransferName(const value:AnsiString);
begin
  FTransferName:=value;
end;

end.
