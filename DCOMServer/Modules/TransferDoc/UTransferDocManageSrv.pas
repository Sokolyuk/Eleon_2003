//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTransferDocManageSrv;
  Модуль нормальный, но технология устарела. см. TransferDoc/TransferDocs/TransferDocManage/TransferBf
interface
  uses UTransferDocManage, ULocalDataBaseTypes, UTransferDocManageTypes, UTransferDocTypes, DbClient, Db;
type
  TTransferDocManageSrv=class(TTransferDocManage)
  protected
    FExecEvent:boolean;
    FInternalPDocSelectGuid:PGuid;
    FInternalPDocUpdateGuid:PGuid;
    FInternalPDocInsertGuid:PGuid;
    FInternalPDocDeleteGuid:PGuid;
    FInternalPDocOpenWriteGuid:PGuid;
    FInternalPDocOpenWriteTransferAsVariant:PDocTransferAsVariant;
    FInternalPDocInsertHeadAsVariant:PDocHeadAsVariant;
    FInternalPDocUpdateHeadAsVariant:PDocHeadAsVariant;
    FInternalPDocOpenWriteHeadAsVariant:PDocHeadAsVariant;
    procedure InternalDocHeadAsVariantToParams(const aDocHeadAsVariant:TDocHeadAsVariant; var aParams:TParams);virtual;
    procedure InternalDocTransferAsVariantToParams(const aDocTransferAsVariant:TDocTransferAsVariant; var aParams:TParams);virtual;
  protected
    function QueryInterface(const IID:TGUID; out Obj):HRESULT;override;
    function InternalDocTypeToImplGuid(aDocType:Integer):TGUID;override;
  protected
    FLocalDataBase, FLocalDataBaseSetTransfered:ILocalDataBase;
    procedure InternalAfterCreate;override;
    procedure InternalBeforeDestroy;override;
  protected
    function InternalSelect(aIsOpenWrite:boolean; const aDocGuid:TGuid; out aDocHeadWithTransferAsVariant:TDocHeadWithTransferAsVariant):boolean;override;
    procedure InternalInsert(aIsOpenWrite:boolean; const aDocGuid:TGuid; const aDocHeadAsVariant:TDocHeadAsVariant; out aDocTransferAsVariant:TDocTransferAsVariant);override;
    procedure InternalUpdate(aIsOpenWrite:boolean; const aDocGuid:TGuid; const aDocHeadAsVariantExists, aDocHeadAsVariantNew:TDocHeadAsVariant; var aDocTransferAsVariant:TDocTransferAsVariant);override;
    procedure InternalDelete(const aDocGuid:TGuid);override;
    procedure InternalOpenRead(const aDocGuid:TGuid; out aDocHeadWithTransferAsVariant:TDocHeadWithTransferAsVariant; out aUserData:variant);override;
    procedure InternalRead(const aReadIn:TReadIn; out aReadOut:TReadOut; var aTransferParam:Variant);override;
    procedure InternalEndReadBeforeEndWrite(aEndWriteOk:boolean; const aEndWriteErrorString:AnsiString; aEndWriteErrorHC:integer; out aUserData:variant);override;
    procedure InternalEndReadAfterEndWrite(aEndWriteOk:boolean; const aEndWriteErrorString:AnsiString; aEndWriteErrorHC:integer; aEndWriteEndWriteOk:boolean; const aEndWriteEndWriteErrorString:AnsiString; aEndWriteEndWriteErrorHC:integer; const aUserData:variant);override;
    procedure InternalOpenWrite(const aDocGuid:TGuid; const aDocHeadAsVariant:TDocHeadAsVariant; out aDocTransferAsVariant:TDocTransferAsVariant; const aUserData:variant);override;
    procedure InternalWrite(const aWriteIn:TWriteIn; out aWriteOut:TWriteOut; var aTransferParam:Variant);override;
    procedure InternalEndWrite(aEndWriteOk:boolean; const aEndWriteErrorString:AnsiString; aEndWriteErrorHC:integer; var aUserData:variant);override;
    function InternalDestinationToNodeName(aDestination:integer; out aMultiDestination:boolean):AnsiString;override;
    function InternalGetReadBlockSize:integer;override;
    procedure InternalBeginDocTransfered(const aDocGuid:TGuid; const aiddcDocsAutoTransfer, aidssUserAutoTransfer:variant);override;
    procedure InternalCommitDocTransfered;override;
    procedure InternalRollbackDocTransfered;override;
  protected
    procedure InternalSelectCheckUpdateHeadRegInfo(const aDocHeadWithTransferAsVariant:TDocHeadWithTransferAsVariant);virtual;
    procedure InternalSetDocInsert(const aDocTransferAsVariant:TDocTransferAsVariant);virtual;
    procedure InternalSetDocUpdate(const aDocTransferAsVariant:TDocTransferAsVariant);virtual;
    procedure InternalSetDocDelete;virtual;
    procedure InternalSetDocOpenWrite(aPDocTransferAsVariant:PDocTransferAsVariant);virtual;
    procedure InternalSetDocWrite(aOutTransferPos, aOutTransferChecksum:integer; const aTransferParam:Variant);virtual;
    procedure InternalSetDocEndWrite;virtual;
  end;

implementation
  uses ULocalDataBasesTypes, Sysutils, UTransferDocImplManageTypes, UErrorConsts, UTypeUtils, variants, UAppMessageTypes;

procedure TTransferDocManageSrv.InternalAfterCreate;
begin
  inherited InternalAfterCreate;
  if not assigned(FCallerAction) then raise exception.create('CallerAction not assigned.');
  FLocalDataBase:=ILocalDataBases(InternalGetITray.Query(ILocalDataBases)).CreateInstance;
  FLocalDataBase.CallerAction:=FCallerAction;
end;

procedure TTransferDocManageSrv.InternalBeforeDestroy;
begin
  FLocalDataBase:=nil;
  FLocalDataBaseSetTransfered:=nil;
  inherited InternalBeforeDestroy;
end;

function TTransferDocManageSrv.QueryInterface(const IID:TGUID; out Obj):HRESULT;
begin
  if (IsEqualGuid(IID, ILocalDataBase))and(assigned(FLocalDataBase)) then begin
    ILocalDataBase(Obj):=FLocalDataBase;
    result:=S_OK;
  end else result:=inherited QueryInterface(IID, Obj);
end;

function TTransferDocManageSrv.InternalDocTypeToImplGuid(aDocType:Integer):TGUID;
begin     
  if FCurrentDocType<>aDocType then begin
    FLocalDataBase.OpenSQL('select ImplGuid from dcType where iddcType='+IntToStr(aDocType));
    if FLocalDataBase.DataSet.RecordCount<>1 then raise exception.create('Unknown type='+IntToStr(aDocType)+'.');
    FCurrentDocImplGuid:=StringToGuid(FLocalDataBase.DataSet.FieldByName('ImplGuid').AsString);
  end;
  result:=FCurrentDocImplGuid;
end;

procedure TTransferDocManageSrv.InternalDocHeadAsVariantToParams(const aDocHeadAsVariant:TDocHeadAsVariant; var aParams:TParams);
  var tmpParam:TParam;
      tmpVarType:word;
begin
  tmpParam:=aParams.CreateParam(ftString, 'Nm', ptUnknown);
  tmpVarType:=VarType(aDocHeadAsVariant.aName);
  if (tmpVarType=varEmpty)or(tmpVarType=varNull) then tmpParam.Clear else tmpParam.AsString:=VarToStr(aDocHeadAsVariant.aName);
  tmpParam:=aParams.CreateParam(ftDateTime, 'DocDT', ptUnknown);
  tmpVarType:=VarType(aDocHeadAsVariant.aDocDateTime);
  if (tmpVarType=varEmpty)or(tmpVarType=varNull) then tmpParam.Clear else tmpParam.AsDateTime:=aDocHeadAsVariant.aDocDateTime;
  tmpParam:=aParams.CreateParam(ftInteger, 'TSz', ptUnknown);
  tmpVarType:=VarType(aDocHeadAsVariant.aTotalSize);
  if (tmpVarType=varEmpty)or(tmpVarType=varNull) then tmpParam.Clear else tmpParam.AsInteger:=aDocHeadAsVariant.aTotalSize;
  tmpParam:=aParams.CreateParam(ftInteger, 'Chsum', ptUnknown);
  tmpVarType:=VarType(aDocHeadAsVariant.aChecksum);
  if (tmpVarType=varEmpty)or(tmpVarType=varNull) then tmpParam.Clear else tmpParam.AsInteger:=aDocHeadAsVariant.aChecksum;
  tmpParam:=aParams.CreateParam(ftInteger, 'Tp', ptUnknown);
  tmpVarType:=VarType(aDocHeadAsVariant.aType);
  if (tmpVarType=varEmpty)or(tmpVarType=varNull) then tmpParam.Clear else tmpParam.AsInteger:=aDocHeadAsVariant.aType;
  tmpParam:=aParams.CreateParam(ftInteger, 'Src', ptUnknown);
  tmpVarType:=VarType(aDocHeadAsVariant.aSource);
  if (tmpVarType=varEmpty)or(tmpVarType=varNull) then tmpParam.Clear else tmpParam.AsInteger:=aDocHeadAsVariant.aSource;
  tmpParam:=aParams.CreateParam(ftInteger, 'Dst', ptUnknown);
  tmpVarType:=VarType(aDocHeadAsVariant.aDestination);
  if (tmpVarType=varEmpty)or(tmpVarType=varNull) then tmpParam.Clear else tmpParam.AsInteger:=aDocHeadAsVariant.aDestination;
  tmpParam:=aParams.CreateParam(ftInteger, 'Flg', ptUnknown);
  tmpVarType:=VarType(aDocHeadAsVariant.aFlag);
  if (tmpVarType=varEmpty)or(tmpVarType=varNull) then tmpParam.Clear else tmpParam.AsInteger:=aDocHeadAsVariant.aFlag;
  tmpParam:=aParams.CreateParam(ftInteger, 'Usr', ptUnknown);
  tmpVarType:=VarType(aDocHeadAsVariant.aUserId);
  if (tmpVarType=varEmpty)or(tmpVarType=varNull) then tmpParam.Clear else tmpParam.AsInteger:=aDocHeadAsVariant.aUserId;
  tmpParam:=aParams.CreateParam(ftString, 'Cmnt', ptUnknown);
  tmpVarType:=VarType(aDocHeadAsVariant.aCommentary);
  if (tmpVarType=varEmpty)or(tmpVarType=varNull) then tmpParam.Clear else tmpParam.AsString:=VarToStr(aDocHeadAsVariant.aCommentary);
end;

procedure TTransferDocManageSrv.InternalDocTransferAsVariantToParams(const aDocTransferAsVariant:TDocTransferAsVariant; var aParams:TParams);
  var tmpParam:TParam;
      tmpVarType:word;
begin
  tmpParam:=aParams.CreateParam(ftInteger, 'Trp', ptUnknown);
  tmpVarType:=VarType(aDocTransferAsVariant.aTransferPos);
  if (tmpVarType=varEmpty)or(tmpVarType=varNull) then tmpParam.Clear else tmpParam.AsInteger:=aDocTransferAsVariant.aTransferPos;
  tmpParam:=aParams.CreateParam(ftInteger, 'Tcs', ptUnknown);
  tmpVarType:=VarType(aDocTransferAsVariant.aTransferChecksum);
  if (tmpVarType=varEmpty)or(tmpVarType=varNull) then tmpParam.Clear else tmpParam.AsInteger:=aDocTransferAsVariant.aTransferChecksum;
  tmpParam:=aParams.CreateParam(ftString, 'Trp', ptUnknown);
  tmpVarType:=VarType(aDocTransferAsVariant.aTransferParam);
  if (tmpVarType=varEmpty)or(tmpVarType=varNull) then tmpParam.Clear else tmpParam.AsString:=glVarArrayToString(aDocTransferAsVariant.aTransferParam);
end;

procedure TTransferDocManageSrv.InternalSelectCheckUpdateHeadRegInfo(const aDocHeadWithTransferAsVariant:TDocHeadWithTransferAsVariant);
  var tmpParams:TParams;
begin
  if not assigned(FInternalPDocSelectGuid) then raise exception.create('FInternalPDocSelectGuid not assigned.');
  tmpParams:=TParams.Create;
  try
    InternalDocHeadAsVariantToParams(aDocHeadWithTransferAsVariant.aDocHeadAsVariant, tmpParams);
    InternalDocTransferAsVariantToParams(aDocHeadWithTransferAsVariant.aDocTransferAsVariant, tmpParams);
    if FLocalDataBase.ExecSQL('update dcDocs set Name=:Nm,DocDateTime=:DocDT,TotalSize=:TSz,Checksum=:Chsum,iddcType=:Tp,Source=:Src,Destination=:Dst,Flag=:Flg,idssUser=:Usr,Commentary=:Cmnt,TransferPos=:Trp,TransferChecksum=:Tcs,TransferParam=:Trp  where guiddcDocs='''+GUIDToString(FInternalPDocSelectGuid^)+'''', tmpParams)<>1 then raise exception.create('UPDATE RA<>1');
  finally
    tmpParams.Free;
  end;
end;

function TTransferDocManageSrv.InternalSelect(aIsOpenWrite:boolean; const aDocGuid:TGuid; out aDocHeadWithTransferAsVariant:TDocHeadWithTransferAsVariant):boolean;
  var tmpTransferDocImplManage:ITransferDocImplManage;
begin
  FLocalDataBase.OpenSQL('select Name,DocDateTime,TotalSize,Checksum,iddcType,Source,Destination,Flag,TransferPos,TransferChecksum,TransferParam,idssUser,Commentary from dcDocs where guiddcDocs='''+GUIDToString(aDocGuid)+'''');
  result:=FLocalDataBase.Dataset.RecordCount=1;
  if result then begin//Есть Bf
    try
      if FLocalDataBase.Dataset.FieldByName('Name').IsNull then aDocHeadWithTransferAsVariant.aDocHeadAsVariant.aName:=null else aDocHeadWithTransferAsVariant.aDocHeadAsVariant.aName:=FLocalDataBase.Dataset.FieldByName('Name').AsString;
      if FLocalDataBase.Dataset.FieldByName('DocDateTime').IsNull then aDocHeadWithTransferAsVariant.aDocHeadAsVariant.aDocDateTime:=null else aDocHeadWithTransferAsVariant.aDocHeadAsVariant.aDocDateTime:=FLocalDataBase.Dataset.FieldByName('DocDateTime').AsDateTime;
      if FLocalDataBase.Dataset.FieldByName('TotalSize').IsNull then aDocHeadWithTransferAsVariant.aDocHeadAsVariant.aTotalSize:=null else aDocHeadWithTransferAsVariant.aDocHeadAsVariant.aTotalSize:=FLocalDataBase.Dataset.FieldByName('TotalSize').AsInteger;
      if FLocalDataBase.Dataset.FieldByName('Checksum').IsNull then aDocHeadWithTransferAsVariant.aDocHeadAsVariant.aChecksum:=null else aDocHeadWithTransferAsVariant.aDocHeadAsVariant.aChecksum:=FLocalDataBase.Dataset.FieldByName('Checksum').AsInteger;
      if FLocalDataBase.Dataset.FieldByName('iddcType').IsNull then aDocHeadWithTransferAsVariant.aDocHeadAsVariant.aType:=null else aDocHeadWithTransferAsVariant.aDocHeadAsVariant.aType:=FLocalDataBase.Dataset.FieldByName('iddcType').AsInteger;
      if FLocalDataBase.Dataset.FieldByName('Source').IsNull then aDocHeadWithTransferAsVariant.aDocHeadAsVariant.aSource:=null else aDocHeadWithTransferAsVariant.aDocHeadAsVariant.aSource:=FLocalDataBase.Dataset.FieldByName('Source').AsInteger;
      if FLocalDataBase.Dataset.FieldByName('Destination').IsNull then aDocHeadWithTransferAsVariant.aDocHeadAsVariant.aDestination:=null else aDocHeadWithTransferAsVariant.aDocHeadAsVariant.aDestination:=FLocalDataBase.Dataset.FieldByName('Destination').AsInteger;
      if FLocalDataBase.Dataset.FieldByName('Flag').IsNull then aDocHeadWithTransferAsVariant.aDocHeadAsVariant.aFlag:=null else aDocHeadWithTransferAsVariant.aDocHeadAsVariant.aFlag:=FLocalDataBase.Dataset.FieldByName('Flag').AsInteger;
      if FLocalDataBase.Dataset.FieldByName('idssUser').IsNull then aDocHeadWithTransferAsVariant.aDocHeadAsVariant.aUserId:=null else aDocHeadWithTransferAsVariant.aDocHeadAsVariant.aUserId:=FLocalDataBase.Dataset.FieldByName('idssUser').AsInteger;
      if FLocalDataBase.Dataset.FieldByName('Commentary').IsNull then aDocHeadWithTransferAsVariant.aDocHeadAsVariant.aCommentary:=null else aDocHeadWithTransferAsVariant.aDocHeadAsVariant.aCommentary:=FLocalDataBase.Dataset.FieldByName('Commentary').AsString;
      if FLocalDataBase.Dataset.FieldByName('TransferPos').IsNull then begin
        aDocHeadWithTransferAsVariant.aDocTransferAsVariant.aTransferPos:=null;
        aDocHeadWithTransferAsVariant.aDocTransferAsVariant.aTransfering:=false;
      end else begin
        aDocHeadWithTransferAsVariant.aDocTransferAsVariant.aTransferPos:=FLocalDataBase.Dataset.FieldByName('TransferPos').AsInteger;
        aDocHeadWithTransferAsVariant.aDocTransferAsVariant.aTransfering:=true;
      end;
      if FLocalDataBase.Dataset.FieldByName('TransferChecksum').IsNull then aDocHeadWithTransferAsVariant.aDocTransferAsVariant.aTransferChecksum:=null else aDocHeadWithTransferAsVariant.aDocTransferAsVariant.aTransferChecksum:=FLocalDataBase.Dataset.FieldByName('TransferChecksum').AsInteger;
      if FLocalDataBase.Dataset.FieldByName('TransferParam').IsNull then aDocHeadWithTransferAsVariant.aDocTransferAsVariant.aTransferParam:=null else aDocHeadWithTransferAsVariant.aDocTransferAsVariant.aTransferParam:=FLocalDataBase.Dataset.FieldByName('TransferParam').AsString;
      if aIsOpenWrite then tmpTransferDocImplManage:=FTransferDocImplManage else tmpTransferDocImplManage:=InternalGetITransferDocImplManage(InternalDocTypeToImplGuid(aDocHeadWithTransferAsVariant.aDocHeadAsVariant.aType));
      FInternalPDocSelectGuid:=@aDocGuid;
      try
        tmpTransferDocImplManage.OnSelectCheckHeadRegInfo({in}Self, aIsOpenWrite, aDocGuid, aDocHeadWithTransferAsVariant, InternalSelectCheckUpdateHeadRegInfo);//берет FLocalDataBase.DataSet
      finally
        FInternalPDocSelectGuid:=nil;
      end;
    except on e:exception do begin
      e.Message:='Load fields: '+e.message;
      raise;
    end;end;
  end;
end;

procedure TTransferDocManageSrv.InternalSetDocInsert(const aDocTransferAsVariant:TDocTransferAsVariant);
  var tmpParams:TParams;
begin
  if FExecEvent then raise exception.createFmtHelp(cserInternalError, ['FExecEvent is true'], cnerInternalError);
  if not((assigned(FInternalPDocInsertGuid))and(assigned(FInternalPDocInsertHeadAsVariant))) then raise exception.create('Invalid SetDocInsert params.');
  tmpParams:=TParams.Create;
  try
    InternalDocHeadAsVariantToParams(FInternalPDocInsertHeadAsVariant^, tmpParams);
    InternalDocTransferAsVariantToParams(aDocTransferAsVariant, tmpParams);
    FLocalDataBase.ExecSQL('insert into dcDocs (guiddcDocs,Name,DocDateTime,TotalSize,Checksum,iddcType,Source,Destination,Flag,idssUser,Commentary,TransferPos,TransferChecksum,TransferParam)values('''+GUIDToString(FInternalPDocInsertGuid^)+''',:Nm,:DocDT,:TSz,:Chsum,:Tp,:Src,:Dst,:Flg,:Usr,:Cmnt,:Trp,:Tcs,:Trp)', tmpParams);
  finally
    tmpParams.free;
  end;
  FExecEvent:=true;
end;

procedure TTransferDocManageSrv.InternalInsert(aIsOpenWrite:boolean; const aDocGuid:TGuid; const aDocHeadAsVariant:TDocHeadAsVariant; out aDocTransferAsVariant:TDocTransferAsVariant);
  var tmpTransferDocImplManage:ITransferDocImplManage;
begin
  tmpTransferDocImplManage:=InternalGetITransferDocImplManage(InternalDocTypeToImplGuid(aDocHeadAsVariant.aType));
  FInternalPDocInsertGuid:=@aDocGuid;
  FInternalPDocInsertHeadAsVariant:=@aDocHeadAsVariant;
  try
    FExecEvent:=false;
    aDocTransferAsVariant.aTransfering:=true;
    aDocTransferAsVariant.aTransferPos:=0;
    aDocTransferAsVariant.aTransferChecksum:=0;
    aDocTransferAsVariant.aTransferParam:=unassigned;
    tmpTransferDocImplManage.OnInsert(InternalSetDocInsert, self, aIsOpenWrite, aDocGuid, aDocHeadAsVariant, {var}aDocTransferAsVariant);
    if not FExecEvent then InternalSetDocInsert(aDocTransferAsVariant);
  finally
    FInternalPDocInsertGuid:=nil;
    FInternalPDocInsertHeadAsVariant:=nil;
  end;
end;

procedure TTransferDocManageSrv.InternalSetDocUpdate(const aDocTransferAsVariant:TDocTransferAsVariant);
  var tmpParams:TParams;
begin
  if FExecEvent then raise exception.createFmtHelp(cserInternalError, ['FExecEvent is true'], cnerInternalError);
  if not((assigned(FInternalPDocUpdateGuid))and(assigned(FInternalPDocUpdateHeadAsVariant))) then raise exception.create('Invalid SetDocUpdate params.');
  tmpParams:=TParams.Create;
  try
    InternalDocHeadAsVariantToParams(FInternalPDocUpdateHeadAsVariant^, tmpParams);
    InternalDocTransferAsVariantToParams(aDocTransferAsVariant, tmpParams);
    if FLocalDataBase.ExecSQL('update dcDocs set Name=:Nm,DocDateTime=:DocDT,TotalSize=:TSz,Checksum=:Chsum,iddcType=:Tp,Source=:Src,Destination=:Dst,Flag=:Flg,idssUser=:Usr,Commentary=:Cmnt,TransferPos=:Trp,TransferChecksum=:Tcs,TransferParam=:Trp where guiddcDocs='''+GUIDToString(FInternalPDocUpdateGuid^)+'''', tmpParams)<>1 then raise exception.create('SetDocUpdate: UPDATE RA<>1');
  finally
    tmpParams.free;
  end;
  FExecEvent:=true;
end;

procedure TTransferDocManageSrv.InternalUpdate(aIsOpenWrite:boolean; const aDocGuid:TGuid; const aDocHeadAsVariantExists, aDocHeadAsVariantNew:TDocHeadAsVariant; var aDocTransferAsVariant:TDocTransferAsVariant);
  var tmpTransferDocImplManage:ITransferDocImplManage;
begin
  if aDocHeadAsVariantNew.aType<>aDocHeadAsVariantExists.aType then raise exception.create('Unsupport change Doc type.');
  tmpTransferDocImplManage:=InternalGetITransferDocImplManage(InternalDocTypeToImplGuid(aDocHeadAsVariantNew.aType));
  FInternalPDocUpdateGuid:=@aDocGuid;
  FInternalPDocUpdateHeadAsVariant:=@aDocHeadAsVariantNew;
  try
    FExecEvent:=false;
    tmpTransferDocImplManage.OnUpdate(InternalSetDocUpdate, Self, aIsOpenWrite, aDocGuid, aDocHeadAsVariantExists, aDocHeadAsVariantNew, {var}aDocTransferAsVariant);
    if not FExecEvent then InternalSetDocUpdate(aDocTransferAsVariant);
  finally
    FInternalPDocUpdateGuid:=nil;
    FInternalPDocUpdateHeadAsVariant:=nil;
  end;
end;

procedure TTransferDocManageSrv.InternalSetDocDelete;
begin
  if FExecEvent then raise exception.createFmtHelp(cserInternalError, ['FExecEvent is true'], cnerInternalError);
  if not assigned(FInternalPDocDeleteGuid) then raise exception.create('Invalid SetDocDelete params.');
  FLocalDataBase.ExecSQL('delete from dcDocs where guiddcDocs='''+GUIDToString(FInternalPDocDeleteGuid^)+'''');
  FExecEvent:=true;
end;

procedure TTransferDocManageSrv.InternalDelete(const aDocGuid:TGuid);
  var tmpDocHeadWithTransferAsVariant:TDocHeadWithTransferAsVariant;
      tmpTransferDocImplManage:ITransferDocImplManage;
begin
  if InternalSelect({IsOpenWrite}false, aDocGuid, {out}tmpDocHeadWithTransferAsVariant) then begin
    tmpTransferDocImplManage:=InternalGetITransferDocImplManage(InternalDocTypeToImplGuid(tmpDocHeadWithTransferAsVariant.aDocHeadAsVariant.aType));
    FInternalPDocDeleteGuid:=@aDocGuid;
    try
      FExecEvent:=false;
      tmpTransferDocImplManage.OnDelete(InternalSetDocDelete, Self, aDocGuid, {in}tmpDocHeadWithTransferAsVariant);
      if not FExecEvent then InternalSetDocDelete;
    finally
      FInternalPDocDeleteGuid:=nil;
    end;
  end;
end;

procedure TTransferDocManageSrv.InternalOpenRead(const aDocGuid:TGuid; out aDocHeadWithTransferAsVariant:TDocHeadWithTransferAsVariant; out aUserData:variant);
begin
  if not InternalSelect({aIsOpenWrite}false, aDocGuid, aDocHeadWithTransferAsVariant) then raise exception.createFmtHelp(cserDocNotExists, [GuidToString(aDocGuid)], cnerDocNotExists);
  InternalGetITransferDocImplManage(InternalDocTypeToImplGuid(aDocHeadWithTransferAsVariant.aDocHeadAsVariant.aType)).OnOpenRead(Self, {in}aDocGuid, {in}aDocHeadWithTransferAsVariant, {out}aUserData);
end;

procedure TTransferDocManageSrv.InternalRead(const aReadIn:TReadIn; out aReadOut:TReadOut; var aTransferParam:Variant);
  var tmpStart:TdateTime;
begin
  if not assigned(FTransferDocImplManage) then raise exception.createFmtHelp(cserInternalError, ['FTransferDocImplManage not assigned'], cnerInternalError);
  tmpStart:=now;
  FTransferDocImplManage.OnRead(Self, {in}aReadIn, {out}aReadOut, {var}aTransferParam);
  InternalMessAdd(tmpStart, 'Read Pos='+IntToStr(aReadIn.aPos)+' Size='+IntToStr(aReadOut.aReadSize)+' CheckSum='+IntToStr(aReadOut.aChecksum)+' TransferParam='''+glVarArrayToString(aTransferParam)+'''', mecTransfer, mesInformation);
end;

procedure TTransferDocManageSrv.InternalEndReadBeforeEndWrite(aEndWriteOk:boolean; const aEndWriteErrorString:AnsiString; aEndWriteErrorHC:integer; out aUserData:variant);
begin
  if not assigned(FTransferDocImplManage) then raise exception.createFmtHelp(cserInternalError, ['FTransferDocImplManage not assigned'], cnerInternalError);
  FTransferDocImplManage.OnEndReadBeforeEndWrite(Self, aEndWriteOk, aEndWriteErrorString, aEndWriteErrorHC, aUserData);
end;

procedure TTransferDocManageSrv.InternalEndReadAfterEndWrite(aEndWriteOk:boolean; const aEndWriteErrorString:AnsiString; aEndWriteErrorHC:integer; aEndWriteEndWriteOk:boolean; const aEndWriteEndWriteErrorString:AnsiString; aEndWriteEndWriteErrorHC:integer; const aUserData:variant);
begin
  if not assigned(FTransferDocImplManage) then raise exception.createFmtHelp(cserInternalError, ['FTransferDocImplManage not assigned'], cnerInternalError);
  FTransferDocImplManage.OnEndReadAfterEndWrite(Self, aEndWriteOk, aEndWriteErrorString, aEndWriteErrorHC, aEndWriteEndWriteOk, aEndWriteEndWriteErrorString, aEndWriteEndWriteErrorHC, {in}aUserData);
end;

procedure TTransferDocManageSrv.InternalSetDocOpenWrite(aPDocTransferAsVariant:PDocTransferAsVariant);
  var tmpDocHeadWithTransferAsVariant:TDocHeadWithTransferAsVariant;
begin
  if (not assigned(FInternalPDocOpenWriteGuid))or(not assigned(FInternalPDocOpenWriteTransferAsVariant))or(not assigned(FInternalPDocOpenWriteTransferAsVariant))then raise exception.create('Invalid SetDocOpenWrite params.');
  if InternalSelect({IsOpenWrite}true, FInternalPDocOpenWriteGuid^, tmpDocHeadWithTransferAsVariant) then begin
    FInternalPDocOpenWriteTransferAsVariant^:=tmpDocHeadWithTransferAsVariant.aDocTransferAsVariant;
    InternalUpdate({aIsOpenWrite}true, FInternalPDocOpenWriteGuid^, {in}{Exists}tmpDocHeadWithTransferAsVariant.aDocHeadAsVariant, {in}{New}FInternalPDocOpenWriteHeadAsVariant^, {var}FInternalPDocOpenWriteTransferAsVariant^);
  end else InternalInsert({aIsOpenWrite}true, FInternalPDocOpenWriteGuid^, {in}FInternalPDocOpenWriteHeadAsVariant^, {out}FInternalPDocOpenWriteTransferAsVariant^);
  if assigned(aPDocTransferAsVariant) then aPDocTransferAsVariant^:=FInternalPDocOpenWriteTransferAsVariant^;
  FExecEvent:=true;
end;

procedure TTransferDocManageSrv.InternalOpenWrite(const aDocGuid:TGuid; const aDocHeadAsVariant:TDocHeadAsVariant; out aDocTransferAsVariant:TDocTransferAsVariant; const aUserData:variant);
  var tmpTransferDocImplManage:ITransferDocImplManage;
begin
  tmpTransferDocImplManage:=InternalGetITransferDocImplManage(InternalDocTypeToImplGuid(aDocHeadAsVariant.aType));
  FInternalPDocOpenWriteGuid:=@aDocGuid;
  FInternalPDocOpenWriteHeadAsVariant:=@aDocHeadAsVariant;
  FInternalPDocOpenWriteTransferAsVariant:=@aDocTransferAsVariant;
  try
    FExecEvent:=false;
    tmpTransferDocImplManage.OnOpenWrite(InternalSetDocOpenWrite, Self, {in}aDocGuid, {in}aDocHeadAsVariant, {in}aUserData);
    if not FExecEvent then InternalSetDocOpenWrite(nil);
  finally
    FInternalPDocOpenWriteGuid:=nil;
    FInternalPDocOpenWriteHeadAsVariant:=nil;
    FInternalPDocOpenWriteTransferAsVariant:=nil;
  end;
end;

procedure TTransferDocManageSrv.InternalSetDocWrite(aOutTransferPos, aOutTransferChecksum:integer; const aTransferParam:Variant);
  var tmpParams:TParams;
      tmpParam:TParam;
      tmpVarType:word;
begin
  if FExecEvent then raise exception.createFmtHelp(cserInternalError, ['FExecEvent is true'], cnerInternalError);
  tmpParams:=TParams.Create;
  try
    tmpParam:=tmpParams.CreateParam(ftString, 'TransferParam', ptUnknown);
    tmpVarType:=VarType(aTransferParam);
    if (tmpVarType=varEmpty)or(tmpVarType=varNull) then tmpParam.Clear else tmpParam.AsString:=glVarArrayToString(aTransferParam);
    if FLocalDataBase.ExecSQL('update dcDocs set TransferPos='+IntToStr(aOutTransferPos)+',TransferChecksum='+IntToStr(aOutTransferChecksum)+',TransferParam=:TransferParam where guiddcDocs='''+GuidToString(FTransferingDocGuid)+'''', tmpParams)<>1 then raise exception.create('UPDATE RA<>1');
  finally
    tmpParams.free;
  end;
  FExecEvent:=true;
end;

procedure TTransferDocManageSrv.InternalWrite(const aWriteIn:TWriteIn; out aWriteOut:TWriteOut; var aTransferParam:Variant);
  var tmpStart:TdateTime;
begin
  if not assigned(FTransferDocImplManage) then raise exception.createFmtHelp(cserInternalError, ['FTransferDocImplManage not assigned'], cnerInternalError);
  tmpStart:=now;
  FExecEvent:=false;
  FTransferDocImplManage.OnWrite(InternalSetDocWrite, Self, aWriteIn, aWriteOut, aTransferParam);
  InternalMessAdd(tmpStart, 'Write Pos='+IntToStr(aWriteIn.aPos)+' Size='+IntToStr(aWriteIn.aSize)+' CheckSum='+IntToStr(aWriteIn.aChecksum)+' TransferParam='''+glVarArrayToString(aTransferParam)+'''', mecTransfer, mesInformation);
  if not FExecEvent then InternalSetDocWrite(aWriteOut.aTransferPos, aWriteOut.aTransferChecksumOut, aTransferParam);
end;

procedure TTransferDocManageSrv.InternalSetDocEndWrite;
begin
  if FExecEvent then raise exception.createFmtHelp(cserInternalError, ['FExecEvent is true'], cnerInternalError);
  if FLocalDataBase.ExecSQL('update dcDocs set TransferPos=NULL,TransferChecksum=NULL,TransferParam=NULL where guiddcDocs='''+GuidToString(FTransferingDocGuid)+'''')<>1 then raise exception.create('UPDATE RA<>1');
  FExecEvent:=true;
end;

procedure TTransferDocManageSrv.InternalEndWrite(aEndWriteOk:boolean; const aEndWriteErrorString:AnsiString; aEndWriteErrorHC:integer; var aUserData:variant);
begin
  if not assigned(FTransferDocImplManage) then raise exception.createFmtHelp(cserInternalError, ['FTransferDocImplManage not assigned'], cnerInternalError);
  FExecEvent:=false;
  FTransferDocImplManage.OnEndWrite(InternalSetDocEndWrite, Self, aEndWriteOk, aEndWriteErrorString, aEndWriteErrorHC, aUserData);
  if (not FExecEvent)and(aEndWriteOk) then InternalSetDocEndWrite;
end;

function TTransferDocManageSrv.InternalDestinationToNodeName(aDestination:integer; out aMultiDestination:boolean):AnsiString;
begin
  if not assigned(FTransferDocImplManage) then raise exception.createFmtHelp(cserInternalError, ['FTransferDocImplManage not assigned'], cnerInternalError);
  result:=FTransferDocImplManage.OnDestinationToNodeName(self, aDestination, aMultiDestination);
end;

function TTransferDocManageSrv.InternalGetReadBlockSize:integer;
begin
  if not assigned(FTransferDocImplManage) then raise exception.createFmtHelp(cserInternalError, ['FTransferDocImplManage not assigned'], cnerInternalError);
  result:=FTransferDocImplManage.OnGetReadBlockSize(self);
end;

procedure TTransferDocManageSrv.InternalBeginDocTransfered(const aDocGuid:TGuid; const aiddcDocsAutoTransfer, aidssUserAutoTransfer:variant);
  var tmpParams:TParams;
      tmpParam:TParam;
      tmpVarType:word;
      tmpIsAutoTransfer:boolean;
      tmpiddcDocsAutoTransfer:integer;
begin
  if not assigned(FLocalDataBaseSetTransfered) then FLocalDataBaseSetTransfered:=ILocalDataBases(InternalGetITray.Query(ILocalDataBases)).CreateInstance;
  tmpVarType:=VarType(aiddcDocsAutoTransfer);
  tmpIsAutoTransfer:=(tmpVarType<>varEmpty)and(tmpVarType<>varNull);
  if tmpIsAutoTransfer then tmpiddcDocsAutoTransfer:=aiddcDocsAutoTransfer else tmpiddcDocsAutoTransfer:=0;
  tmpParams:=TParams.Create;
  try
    tmpParam:=tmpParams.CreateParam(ftInteger, 'idssUser', ptUnknown);
    try
      if tmpIsAutoTransfer then begin
        tmpVarType:=VarType(aidssUserAutoTransfer);
        if (tmpVarType<>varEmpty)and(tmpVarType<>varNull) then tmpParam.AsInteger:=aidssUserAutoTransfer else tmpParam.Clear;
      end else begin
        FLocalDataBaseSetTransfered.OpenSQL('select idssUser from ssUser where UserSysName='''+glStrToSQL(FCallerAction.UserName)+'''');
        if FLocalDataBaseSetTransfered.DataSet.RecordCount=1 then tmpParam.AsInteger:=FLocalDataBaseSetTransfered.DataSet.FieldByName('idssUser').AsInteger else tmpParam.clear;
      end;
    except
      tmpParam.clear;
    end;
    tmpParam:=tmpParams.CreateParam(ftInteger, 'AutoTransfered', ptUnknown);
    if tmpIsAutoTransfer then tmpParam.AsInteger:=1 else tmpParam.AsInteger:=0;
    FLocalDataBaseSetTransfered.OpenSQL('select iddcDocs from dcDocs where guiddcDocs='''+GuidToString(FTransferingDocGuid)+'''');
    if FLocalDataBaseSetTransfered.DataSet.RecordCount<>1 then raise exception.create('unable determine iddcDocs. RecordCount<>1.');
    FLocalDataBaseSetTransfered.ExecSQL('begin transaction');
    FLocalDataBaseSetTransfered.ExecSQL('insert into dcDocsTransfered (iddcDocs,idssUser,AutoTransfered)values('+FLocalDataBaseSetTransfered.DataSet.FieldByName('iddcDocs').AsString+',:idssUser,:AutoTransfered)', tmpParams);
    if tmpIsAutoTransfer then FLocalDataBaseSetTransfered.ExecSQL('delete from dcDocsAutoTransfer where iddcDocsAutoTransfer='+IntToStr(tmpiddcDocsAutoTransfer));
  finally
    tmpParams.free;
  end;
end;

procedure TTransferDocManageSrv.InternalCommitDocTransfered;
begin
  FLocalDataBaseSetTransfered.ExecSQL('commit transaction');
end;

procedure TTransferDocManageSrv.InternalRollbackDocTransfered;
begin
  FLocalDataBaseSetTransfered.ExecSQL('rollback transaction');
end;

end.
