//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTransferDocManage;
  Модуль нормальный, но технология устарела. см. TransferDoc/TransferDocs/TransferDocManage/TransferBf
interface
  uses UITObject, UTransferDocManageTypes, UTransferDocManagesTypes, UCallerTypes, UTrayTypes, UTransferDocImplManageTypes,
       UTransferDocTypes, UAppMessageTypes;
type
  TTransferDocManage=class(TITObject, ITransferDocManage)
  protected
    FOwner:ITransferDocManages;
    FCallerAction:ICallerAction;
    FTransferDocImplManage:ITransferDocImplManage;
    FDocImplGuid:TGuid;
    FCurrentDocType:integer;
    FCurrentDocImplGuid:TGuid;
    FTransfering:boolean;
    FTransferingDocGuid:TGuid;
    function InternalCheckStateAsTrayForWork(aRaise:boolean):boolean;
    procedure InternalAfterCreate;virtual;
    procedure InternalBeforeDestroy;virtual;
    function InternalGetITray:ITray;virtual;
    function InternalGetITransferDocImplManage(const aDocImplGuid:TGuid):ITransferDocImplManage;virtual;
    procedure InternalFreeTransferDocImplManage;virtual;
    function InternalDocTypeToImplGuid(aDocType:Integer):TGuid;virtual;abstract;
    procedure InternalMessAdd(aStart:TDateTime; const aMessage:AnsiString; aMessageClass:TMessageClass; aMessageStyle:TMessageStyle);virtual;
  public
    constructor create(aOwner:ITransferDocManages; aCallerAction:ICallerAction);
    destructor destroy;override;
  protected
    function InternalSelect(aIsOpenWrite:boolean; const aDocGuid:TGuid; out aDocHeadWithTransferAsVariant:TDocHeadWithTransferAsVariant):boolean;virtual;abstract;
    procedure InternalInsert(aIsOpenWrite:boolean; const aDocGuid:TGuid; const aDocHeadAsVariant:TDocHeadAsVariant; out aDocTransferAsVariant:TDocTransferAsVariant);virtual;abstract;
    procedure InternalUpdate(aIsOpenWrite:boolean; const aDocGuid:TGuid; const aDocHeadAsVariantExists, aDocHeadAsVariantNew:TDocHeadAsVariant; var aDocTransferAsVariant:TDocTransferAsVariant);virtual;abstract;
    procedure InternalDelete(const aDocGuid:TGuid);virtual;abstract;
    procedure InternalOpenRead(const aDocGuid:TGuid; out aDocHeadWithTransferAsVariant:TDocHeadWithTransferAsVariant; out aUserData:variant);virtual;abstract;
    procedure InternalRead(const aReadIn:TReadIn; out aReadOut:TReadOut; var aTransferParam:Variant);virtual;abstract;
    procedure InternalEndReadBeforeEndWrite(aEndWriteOk:boolean; const aEndWriteErrorString:AnsiString; aEndWriteErrorHC:integer; out aUserData:variant);virtual;abstract;
    procedure InternalEndReadAfterEndWrite(aEndWriteOk:boolean; const aEndWriteErrorString:AnsiString; aEndWriteErrorHC:integer; aEndWriteEndWriteOk:boolean; const aEndWriteEndWriteErrorString:AnsiString; aEndWriteEndWriteErrorHC:integer; const aUserData:variant);virtual;abstract;
    procedure InternalOpenWrite(const aDocGuid:TGuid; const aDocHeadAsVariant:TDocHeadAsVariant; out aDocTransferAsVariant:TDocTransferAsVariant; const aUserData:variant);virtual;abstract;
    procedure InternalWrite(const aWriteIn:TWriteIn; out aWriteOut:TWriteOut; var aTransferParam:Variant);virtual;abstract;
    procedure InternalEndWrite(aEndWriteOk:boolean; const aEndWriteErrorString:AnsiString; aEndWriteErrorHC:integer; var aUserData:variant);virtual;abstract;
    function InternalDestinationToNodeName(aDestination:integer; out aMultiDestination:boolean):AnsiString;virtual;abstract;
    function InternalGetReadBlockSize:integer;virtual;abstract;
    procedure InternalBeginDocTransfered(const aDocGuid:TGuid; const aiddcDocsAutoTransfer, aidssUserAutoTransfer:variant);virtual;abstract;
    procedure InternalCommitDocTransfered;virtual;abstract;
    procedure InternalRollbackDocTransfered;virtual;abstract;
  public
    function Exists(const aDocGuid:TGuid; out aTransfering:boolean):boolean;virtual;
    function Select(const aDocGuid:TGuid; out aDocHeadWithTransferAsVariant:TDocHeadWithTransferAsVariant):boolean;virtual;
    procedure Insert(const aDocGuid:TGuid; const aDocHeadAsVariant:TDocHeadAsVariant; out aDocTransferAsVariant:TDocTransferAsVariant);virtual;
    procedure Update(const aDocGuid:TGuid; const aDocHeadAsVariant:TDocHeadAsVariant; out aDocTransferAsVariant:TDocTransferAsVariant);virtual;
    procedure Delete(const aDocGuid:TGuid);virtual;
    procedure OpenRead(const aDocGuid:TGuid; out aDocHeadWithTransferAsVariant:TDocHeadWithTransferAsVariant; out aUserData:variant);virtual;
    procedure Read(const aReadIn:TReadIn; out aReadOut:TReadOut; var aTransferParam:Variant);virtual;
    procedure EndReadBeforeEndWrite(aEndWriteOk:boolean; const aEndWriteErrorString:AnsiString; aEndWriteErrorHC:integer; out aUserData:variant);virtual;
    procedure EndReadAfterEndWrite(aEndWriteOk:boolean; const aEndWriteErrorString:AnsiString; aEndWriteErrorHC:integer; aEndWriteEndWriteOk:boolean; const aEndWriteEndWriteErrorString:AnsiString; aEndWriteEndWriteErrorHC:integer; const aUserData:variant);virtual;
    procedure OpenWrite(const aDocGuid:TGuid; const aDocHeadAsVariant:TDocHeadAsVariant; out aDocTransferAsVariant:TDocTransferAsVariant; const aUserData:variant);virtual;
    procedure Write(const aWriteIn:TWriteIn; out aWriteOut:TWriteOut; var aTransferParam:Variant);virtual;
    procedure EndWrite(aEndWriteOk:boolean; const aEndWriteErrorString:AnsiString; aEndWriteErrorHC:integer; var aUserData:variant);virtual;
    function DestinationToNodeName(aDestination:integer; out aMultiDestination:boolean):AnsiString;virtual;
    function GetReadBlockSize:integer;virtual;
    procedure BeginDocTransfered(const aDocGuid:TGuid; const aiddcDocsAutoTransfer, aidssUserAutoTransfer:variant);virtual;
    procedure CommitDocTransfered;virtual;
    procedure RollbackDocTransfered;virtual;
  end;

implementation
  uses UTrayConsts, Sysutils, ActiveX, UErrorConsts, UEQueryInterfaceTrayTypes;

procedure TTransferDocManage.InternalAfterCreate;
begin
end;

procedure TTransferDocManage.InternalBeforeDestroy;
begin
  InternalFreeTransferDocImplManage;
  FTransferDocImplManage:=nil;
  FOwner:=nil;
  FCallerAction:=nil;
end;

procedure TTransferDocManage.InternalFreeTransferDocImplManage;
begin
  try
    if FTransfering then raise exception.create('FreeTransferDocImplManage: Transfering is true.');
    FTransferDocImplManage:=nil;
    //??FDocImplGuid:=IUnknown;
    FillChar(FDocImplGuid, Sizeof(FDocImplGuid), 0);
  except on e:exception do begin
    e.message:='TTransferDocManage.InternalFreeTransferDocImplManage: '+e.message;
    raise;
  end;end;
end;

function TTransferDocManage.InternalGetITransferDocImplManage(const aDocImplGuid:TGuid):ITransferDocImplManage;
  var tmpIUnknown:IUnknown;
      tmpTransferDocImplManage:ITransferDocImplManage;
begin
  if (assigned(FTransferDocImplManage))and(IsEqualGUID(aDocImplGuid, FDocImplGuid)) then begin
    result:=FTransferDocImplManage;
  end else begin
    if FTransfering then raise exception.create('GetTransferDocImplManage(No support for multy-reading): Transfering is true.');
    if not assigned(FCallerAction) then raise exception.create('FCallerAction not assigned.');
    tmpIUnknown:=IEQueryInterfaceTray(InternalGetITray.Query(IEQueryInterfaceTray)).EQueryInterface(FCallerAction.SecurityContext, aDocImplGuid);
    if (tmpIUnknown.QueryInterface(ITransferDocImplManage, tmpTransferDocImplManage)<>S_OK)or(not assigned(tmpTransferDocImplManage)) then raise exception.createFmtHelp(cserInternalError, ['ITransferDocImplManage no found'], cnerInternalError);
    FTransferDocImplManage:=tmpTransferDocImplManage;
    result:=FTransferDocImplManage;
    FDocImplGuid:=aDocImplGuid;
  end;
end;

constructor TTransferDocManage.create(aOwner:ITransferDocManages; aCallerAction:ICallerAction);
begin
  inherited create;
  FOwner:=aOwner;
  FCallerAction:=aCallerAction;
  FCurrentDocType:=-1;
  FTransfering:=false;
  //??FTransferingDocGuid:=IUnknown;
  FillChar(FTransferingDocGuid, Sizeof(FTransferingDocGuid), 0);
  InternalAfterCreate;
end;

destructor TTransferDocManage.destroy;
begin
  FTransfering:=false;
  //??FTransferingDocGuid:=IUnknown;
  FillChar(FTransferingDocGuid, Sizeof(FTransferingDocGuid), 0);
  InternalBeforeDestroy;
  inherited destroy;
end;

function TTransferDocManage.InternalGetITray:ITray;
begin
  result:=cnTray;
  if not assigned(result) then raise exception.create('Tray not assigned.');
end;

function TTransferDocManage.InternalCheckStateAsTrayForWork(aRaise:boolean):boolean;
begin
  if assigned(FOwner) then result:=FOwner.CheckStateAsTrayForWork(aRaise) else result:=true;
end;

function TTransferDocManage.Exists(const aDocGuid:TGuid; out aTransfering:boolean):boolean;
  var tmpDocHeadWithTransferAsVariant:TDocHeadWithTransferAsVariant;
begin
  InternalLock;
  try
    InternalCheckStateAsTrayForWork(true);
    result:=InternalSelect({aIsOpenWrite}false, aDocGuid, tmpDocHeadWithTransferAsVariant);
    aTransfering:=tmpDocHeadWithTransferAsVariant.aDocTransferAsVariant.aTransfering;
  finally
    InternalUnLock;
  end;  
end;

function TTransferDocManage.Select(const aDocGuid:TGuid; out aDocHeadWithTransferAsVariant:TDocHeadWithTransferAsVariant):boolean;
begin
  InternalLock;
  try
    InternalCheckStateAsTrayForWork(true);
    result:=InternalSelect({aIsOpenWrite}false, aDocGuid, aDocHeadWithTransferAsVariant);
  finally
    InternalUnLock;
  end;
end;

procedure TTransferDocManage.Insert(const aDocGuid:TGuid; const aDocHeadAsVariant:TDocHeadAsVariant; out aDocTransferAsVariant:TDocTransferAsVariant);
begin
  InternalLock;
  try
    InternalCheckStateAsTrayForWork(true);
    InternalInsert({IsOpenWrite}false, aDocGuid, aDocHeadAsVariant, aDocTransferAsVariant);
  finally
    InternalUnLock;
  end;
end;

procedure TTransferDocManage.Update(const aDocGuid:TGuid; const aDocHeadAsVariant:TDocHeadAsVariant; out aDocTransferAsVariant:TDocTransferAsVariant);
  var tmpDocHeadWithTransferAsVariant:TDocHeadWithTransferAsVariant;
begin
  InternalLock;
  try
    InternalCheckStateAsTrayForWork(true);
    if not InternalSelect({IsOpenWrite}false, aDocGuid, tmpDocHeadWithTransferAsVariant) then raise exception.createFmtHelp(cserDocNotExists, [GuidToString(aDocGuid)], cnerDocNotExists);
    aDocTransferAsVariant:=tmpDocHeadWithTransferAsVariant.aDocTransferAsVariant;
    InternalUpdate({IsOpenWrite}false, aDocGuid, {Exists}tmpDocHeadWithTransferAsVariant.aDocHeadAsVariant, {new}aDocHeadAsVariant, aDocTransferAsVariant);
  finally
    InternalUnLock;
  end;
end;

procedure TTransferDocManage.Delete(const aDocGuid:TGuid);
begin
  InternalLock;
  try
    InternalCheckStateAsTrayForWork(true);
    InternalDelete(aDocGuid);
  finally
    InternalUnLock;
  end;
end;

procedure TTransferDocManage.OpenRead(const aDocGuid:TGuid; out aDocHeadWithTransferAsVariant:TDocHeadWithTransferAsVariant; out aUserData:variant);
begin
  InternalLock;
  try
    if FTransfering then raise exception.create('Already transfering.');
    InternalCheckStateAsTrayForWork(true);
    InternalOpenRead(aDocGuid, aDocHeadWithTransferAsVariant, aUserData);
    FTransfering:=true;
    FTransferingDocGuid:=aDocGuid;
  finally
    InternalUnLock;
  end;
end;

procedure TTransferDocManage.Read(const aReadIn:TReadIn; out aReadOut:TReadOut; var aTransferParam:Variant);
begin
  InternalLock;
  try
    if not FTransfering then raise exception.create('Read: No transfering.');
    InternalCheckStateAsTrayForWork(true);
    InternalRead(aReadIn, aReadOut, aTransferParam);
  finally
    InternalUnLock;
  end;
end;

procedure TTransferDocManage.EndReadBeforeEndWrite(aEndWriteOk:boolean; const aEndWriteErrorString:AnsiString; aEndWriteErrorHC:integer; out aUserData:variant);
begin
  InternalLock;
  try
    if not FTransfering then raise exception.create('EndReadBeforeEndWrite: No transfering.');
    InternalCheckStateAsTrayForWork(true);
    InternalEndReadBeforeEndWrite(aEndWriteOk, aEndWriteErrorString, aEndWriteErrorHC, aUserData);
  finally
    InternalUnLock;
  end;
end;

procedure TTransferDocManage.EndReadAfterEndWrite(aEndWriteOk:boolean; const aEndWriteErrorString:AnsiString; aEndWriteErrorHC:integer; aEndWriteEndWriteOk:boolean; const aEndWriteEndWriteErrorString:AnsiString; aEndWriteEndWriteErrorHC:integer; const aUserData:variant);
begin
  InternalLock;
  try
    if not FTransfering then raise exception.create('EndReadAfterEndWrite: No transfering.');
    InternalCheckStateAsTrayForWork(true);
    InternalEndReadAfterEndWrite(aEndWriteOk, aEndWriteErrorString, aEndWriteErrorHC, aEndWriteEndWriteOk, aEndWriteEndWriteErrorString, aEndWriteEndWriteErrorHC, aUserData);
    FTransfering:=false;
    //??FTransferingDocGuid:=IUnknown;
    FillChar(FTransferingDocGuid, Sizeof(FTransferingDocGuid), 0);
    InternalFreeTransferDocImplManage;
  finally
    InternalUnLock;
  end;
end;

procedure TTransferDocManage.OpenWrite(const aDocGuid:TGuid; const aDocHeadAsVariant:TDocHeadAsVariant; out aDocTransferAsVariant:TDocTransferAsVariant; const aUserData:variant);
begin
  InternalLock;
  try
    if FTransfering then raise exception.create('OpenWrite: Already transfering.');
    InternalCheckStateAsTrayForWork(true);
    InternalOpenWrite(aDocGuid, aDocHeadAsVariant, aDocTransferAsVariant, aUserData);
    FTransfering:=true;
    FTransferingDocGuid:=aDocGuid;
  finally
    InternalUnLock;
  end;
end;

procedure TTransferDocManage.Write(const aWriteIn:TWriteIn; out aWriteOut:TWriteOut; var aTransferParam:Variant);
begin
  InternalLock;
  try
    if not FTransfering then raise exception.create('Write: No transfering.');
    InternalCheckStateAsTrayForWork(true);
    InternalWrite(aWriteIn, aWriteOut, aTransferParam);
  finally
    InternalUnLock;
  end;
end;

procedure TTransferDocManage.EndWrite(aEndWriteOk:boolean; const aEndWriteErrorString:AnsiString; aEndWriteErrorHC:integer; var aUserData:variant);
begin
  try
    InternalLock;
    try
      if not FTransfering then raise exception.create('EndWrite: No transfering.');
      InternalCheckStateAsTrayForWork(true);
      InternalEndWrite(aEndWriteOk, aEndWriteErrorString, aEndWriteErrorHC, aUserData);
      FTransfering:=false;
      //??FTransferingDocGuid:=IUnknown;
      FillChar(FTransferingDocGuid, Sizeof(FTransferingDocGuid), 0);
      InternalFreeTransferDocImplManage;
    finally
      InternalUnLock;
    end;
  except on e:exception do begin
    e.message:='TTransferDocManage.EndWrite: '+e.message;
    raise;
  end;end;
end;

function TTransferDocManage.DestinationToNodeName(aDestination:integer; out aMultiDestination:boolean):AnsiString;
begin
  InternalLock;
  try
    InternalCheckStateAsTrayForWork(true);
    result:=InternalDestinationToNodeName(aDestination, aMultiDestination);
  finally
    InternalUnLock;
  end;
end;

function TTransferDocManage.GetReadBlockSize:integer;
begin
  InternalLock;
  try
    InternalCheckStateAsTrayForWork(true);
    result:=InternalGetReadBlockSize;
  finally
    InternalUnLock;
  end;
end;

procedure TTransferDocManage.InternalMessAdd(aStart:TDateTime; const aMessage:AnsiString; aMessageClass:TMessageClass; aMessageStyle:TMessageStyle);
  var tmpCallerAction:ICallerAction;
begin
  tmpCallerAction:=FCallerAction;
  if assigned(tmpCallerAction) then begin
    tmpCallerAction.ITMessAdd(aStart, now, 'TrfDocMng', aMessage, aMessageClass, aMessageStyle);
  end;
end;

procedure TTransferDocManage.BeginDocTransfered(const aDocGuid:TGuid; const aiddcDocsAutoTransfer, aidssUserAutoTransfer:variant);
begin
  InternalBeginDocTransfered(aDocGuid, aiddcDocsAutoTransfer, aidssUserAutoTransfer);
end;

procedure TTransferDocManage.CommitDocTransfered;
begin
  InternalCommitDocTransfered;
end;

procedure TTransferDocManage.RollbackDocTransfered;
begin
  InternalRollbackDocTransfered;
end;

end.
