unit UTransferBfsTable;
  Модуль нормальный, но технология устарела. см. TransferDoc/TransferDocs/TransferDocManage/TransferBf
interface
  uses UTransferBfs, UTransferBfsTypes, ULocalDataBaseTypes, UTransferBfTypes, UBfTypes,
       UPackPDPlacesTypes;
type
  TTransferBfsTable=class(TTransferBfs)
  protected
    procedure InternalInit;override;
  protected
    procedure InternalInitLocalDataBase(var aLocalDataBase:ILocalDataBase);virtual;
    function InternalTableUpdateChecksum(const aBfName:AnsiString; aFileHandle:THandle; aChecksumDate:TDateTime; var aUserInterface:IUnknown):Integer;override;
    procedure InternalUpdateTableBfInfoAtBegin(var aUserInterface:IUnknown; aTransferBf:ITransferBf);override;
    function InternalBfIdToTableBfInfo(const aBfName:AnsiString; var aUserInterface:IUnknown; out aTableBfInfo:TTableBfInfo):boolean;override;
    function InternalDeleteTbfInfo(const aBfName:AnsiString; var aUserInterface:IUnknown):boolean;override;
    procedure InternalInsertTableBfInfoAtBegin(var aUserInterface:IUnknown; aTransferBf:ITransferBf);override;
    procedure InternalUpdateTableBfInfoAtProcess(var aUserInterface:IUnknown; aTransferBf:ITransferBf);override;
    procedure InternalUpdateTableBfInfoAtComplete(var aUserInterface:IUnknown; aTransferBf:ITransferBf);override;
    procedure InternalUpdateTableBfInfo(const aBfName:AnsiString; const aNewPath, aNewFileName:AnsiString; var aUserInterface:IUnknown);override;
    procedure InternalResponderNameToPlaces(const aConnectionName:AnsiString; const aResponderName:AnsiString; aPlaces:IPackPDPlaces);override;
  end;

implementation
  uses ULocalDataBase, Db, DbClient, SysUtils, UTypeUtils, UNodeNameUtils, UTrayConsts, UEPointPropertiesTypes,
       UServerInfoTypes, UServerActionConsts{$IFDEF VER140}, Variants{$ENDIF}, Registry, UAppConfigRegPathConsts, UBfConsts,
       windows, UErrorConsts;

procedure TTransferBfsTable.InternalInitLocalDataBase(var aLocalDataBase:ILocalDataBase);
begin
  if not assigned(aLocalDataBase) then begin
    aLocalDataBase:=TLocalDataBase.Create;
    aLocalDataBase.CallerAction:=cnServerAction;
  end;
end;

function TTransferBfsTable.InternalTableUpdateChecksum(const aBfName:AnsiString; aFileHandle:THandle; aChecksumDate:TDateTime; var aUserInterface:IUnknown):Integer;
  var tmpOleParams:OleVariant;
      tmpParams:TParams;
begin
  try
    Result:=InternalRecalcChecksum(aFileHandle, $FFFFFFFF);
    InternalInitLocalDataBase(ILocalDataBase(aUserInterface));
    tmpParams:=TParams.Create;
    try
      With tmpParams.CreateParam(ftDateTime, 'ChecksumDate', ptUnknown) do AsDateTime:=aChecksumDate;
      tmpOleParams:=PackageParams(tmpParams);
      try
        if ILocalDataBase(aUserInterface).ExecSQL('UPDATE ssBf SET [Checksum]='+IntToStr(Result)+',[ChecksumDate]=:ChecksumDate WHERE BfName='''+glStrToSql(aBfName)+'''', tmpOleParams)<>1 then raise exception.create('Recaf<>1.');
      finally
        VarClear(tmpOleParams);
      end;
    finally
      FreeAndNil(tmpParams);
    end;
  except on e:exception do begin
    e.message:='ITblUpdateChecksum: '+e.message;
    raise;
  end;end;
end;

function TTransferBfsTable.InternalBfIdToTableBfInfo(const aBfName:AnsiString; var aUserInterface:IUnknown; out aTableBfInfo:TTableBfInfo):boolean;
begin
  try
    InternalInitLocalDataBase(ILocalDataBase(aUserInterface));
    ILocalDataBase(aUserInterface).OpenSQL('SELECT [Path],[Filename],[Checksum],[ChecksumDate],[BfType],[TransferSchedule],[Commentary] FROM ssBf WHERE BfName='''+glStrToSql(aBfName)+'''');
    //Проверки
    Result:=ILocalDataBase(aUserInterface).DataSet.RecordCount=1;
    if Result then begin
      if ILocalDataBase(aUserInterface).DataSet.FieldByName('Filename').IsNull then raise exception.create('Invalid name of Bf. Name is null.');
      if not ILocalDataBase(aUserInterface).DataSet.FieldByName('Path').IsNull then begin
        aTableBfInfo.Path:=ILocalDataBase(aUserInterface).DataSet.FieldByName('Path').AsString;
        if (aTableBfInfo.Path<>'')And(aTableBfInfo.Path[Length(aTableBfInfo.Path)]<>'\') then aTableBfInfo.Path:=aTableBfInfo.Path+'\';
      end else aTableBfInfo.Path:='';
      //Получаю имя
      aTableBfInfo.Filename:=ILocalDataBase(aUserInterface).DataSet.FieldByName('Filename').AsString;
      if ILocalDataBase(aUserInterface).DataSet.FieldByName('Checksum').IsNull then aTableBfInfo.Checksum:=0 else aTableBfInfo.Checksum:=ILocalDataBase(aUserInterface).DataSet.FieldByName('Checksum').AsInteger;
      if ILocalDataBase(aUserInterface).DataSet.FieldByName('ChecksumDate').IsNull then aTableBfInfo.ChecksumDate:=0 else aTableBfInfo.ChecksumDate:=ILocalDataBase(aUserInterface).DataSet.FieldByName('ChecksumDate').AsDateTime;
      if ILocalDataBase(aUserInterface).DataSet.FieldByName('Commentary').IsNull then aTableBfInfo.Commentary:='' else aTableBfInfo.Commentary:=ILocalDataBase(aUserInterface).DataSet.FieldByName('Commentary').AsString;
      if ILocalDataBase(aUserInterface).DataSet.FieldByName('BfType').IsNull then aTableBfInfo.BfType:=0 else aTableBfInfo.BfType:=ILocalDataBase(aUserInterface).DataSet.FieldByName('BfType').AsInteger;
      if ILocalDataBase(aUserInterface).DataSet.FieldByName('TransferSchedule').IsNull then aTableBfInfo.TransferSchedule:='' else aTableBfInfo.TransferSchedule:=ILocalDataBase(aUserInterface).DataSet.FieldByName('TransferSchedule').AsString;
      //ssBfTransfering
      ILocalDataBase(aUserInterface).OpenSQL('SELECT [Pos],[Checksum],[Responder],[Direction] FROM ssBfTransfer WHERE BfName='''+glStrToSql(aBfName)+'''');
      aTableBfInfo.Transfering:=ILocalDataBase(aUserInterface).DataSet.RecordCount=1;
      if aTableBfInfo.Transfering then begin//Exists registry key or SELECT * FROM ssBfTransfer WHERE BfName='xx'
        aTableBfInfo.TransferPos:=Cardinal(ILocalDataBase(aUserInterface).DataSet.FieldByName('Pos').AsInteger);
        aTableBfInfo.TransferChecksum:=ILocalDataBase(aUserInterface).DataSet.FieldByName('Checksum').AsInteger;
        aTableBfInfo.TransferResponder:=ILocalDataBase(aUserInterface).DataSet.FieldByName('Responder').AsString;
        aTableBfInfo.TransferDirection:=TTransferDirection(ILocalDataBase(aUserInterface).DataSet.FieldByName('Direction').AsInteger);
      end else begin
        aTableBfInfo.TransferPos:=0;
        aTableBfInfo.TransferChecksum:=0;
        aTableBfInfo.TransferResponder:='';
        aTableBfInfo.TransferDirection:=trdDownloadClient;
      end;
    end else InternalClearTableBfInfo(aTableBfInfo);
  except on e:exception do begin
    e.message:='IBfIdToTBfInfo: '+e.message;
    raise;
  end;end;
end;

function TTransferBfsTable.InternalDeleteTbfInfo(const aBfName:AnsiString; var aUserInterface:IUnknown):Boolean;
begin
  InternalInitLocalDataBase(ILocalDataBase(aUserInterface));
  try
    ILocalDataBase(aUserInterface).ExecSQL('DELETE FROM ssBfTransfer WHERE BfName='''+glStrToSql(aBfName)+'''');
  finally
    Result:=ILocalDataBase(aUserInterface).ExecSQL('DELETE FROM ssBf WHERE BfName='''+glStrToSql(aBfName)+'''')>0;
  end;  
end;

procedure TTransferBfsTable.InternalInsertTableBfInfoAtBegin(var aUserInterface:IUnknown; aTransferBf:ITransferBf);
  var tmpOleV:OleVariant;
      tmpParams:TParams;
begin
  if not Assigned(aTransferBf) then raise exception.create('TransferBf is not assigned.');
  InternalInitLocalDataBase(ILocalDataBase(aUserInterface));
  ILocalDataBase(aUserInterface).ExecSQL('BEGIN TRANSACTION');
  Try
    tmpParams:=TParams.Create;
    try
      With tmpParams.CreateParam(ftDateTime, 'ChecksumDate', ptUnknown) do AsDateTime:=aTransferBf.TableBfDate;
      tmpOleV:=PackageParams(tmpParams);
      ILocalDataBase(aUserInterface).ExecSQL('INSERT INTO ssBf([BfName],[Path],[Filename],[Checksum],[ChecksumDate],[BfType],TransferSchedule,Commentary)VALUES('''+glStrToSql(aTransferBf.BfName)+''','''+glStrToSQL(aTransferBf.TableBfDir)+''','''+glStrToSQL(aTransferBf.TableBfName)+''','+IntToStr(aTransferBf.TableBfChecksum)+',:ChecksumDate,'+IntToStr(aTransferBf.BfType)+','''+glStrToSQL(aTransferBf.TransferSchedule)+''','''+glStrToSQL(aTransferBf.TableBfCommentary)+''')', tmpOleV);
    finally
      FreeAndNil(tmpParams);
      VarClear(tmpOleV);
    end;
    ILocalDataBase(aUserInterface).ExecSQL('INSERT INTO ssBfTransfer([BfName],[Pos],[Checksum],[Responder],[Direction])VALUES('''+glStrToSql(aTransferBf.BfName)+''','+IntToStr(Integer(aTransferBf.TransferPos))+','+IntToStr(aTransferBf.TransferChecksum)+','''+glStrToSql(aTransferBf.TransferResponder)+''','+IntToStr(Integer(aTransferBf.TransferDirection))+')');
    ILocalDataBase(aUserInterface).ExecSQL('COMMIT TRANSACTION');
  Except
    try ILocalDataBase(aUserInterface).ExecSQL('ROLLBACK TRANSACTION');except end;
    raise;
  end;
end;

procedure TTransferBfsTable.InternalUpdateTableBfInfoAtBegin(var aUserInterface:IUnknown; aTransferBf:ITransferBf);
  var tmpOleV:OleVariant;
      tmpParams:TParams;
begin
  if not Assigned(aTransferBf) then raise exception.create('TransferBf is not assigned.');
  InternalInitLocalDataBase(ILocalDataBase(aUserInterface));
  ILocalDataBase(aUserInterface).ExecSQL('BEGIN TRANSACTION');
  try
    tmpParams:=TParams.Create;
    try
      With tmpParams.CreateParam(ftDateTime, 'ChecksumDate', ptUnknown) do AsDateTime:=aTransferBf.TableBfDate;
      tmpOleV:=PackageParams(tmpParams);
      if ILocalDataBase(aUserInterface).ExecSQL('UPDATE ssBf SET [Path]='''+glStrToSQL(aTransferBf.TableBfDir)+''',[Filename]='''+glStrToSQL(aTransferBf.TableBfName)+''',[Checksum]='+IntToStr(aTransferBf.TableBfChecksum)+',[ChecksumDate]=:ChecksumDate,[BfType]='+IntToStr(aTransferBf.BfType)+',[TransferSchedule]='''+glStrToSQL(aTransferBf.TransferSchedule)+''',[Commentary]='''+glStrToSQL(aTransferBf.TableBfCommentary)+''' WHERE BfName='''+glStrToSql(aTransferBf.BfName)+'''', tmpOleV)<>1 then raise exception.createFmtHelp(cserInternalError, ['UpdAtBg: RecAff<>1 after update'], cnerInternalError);
    finally
      FreeAndNil(tmpParams);
    end;
    if ILocalDataBase(aUserInterface).ExecSQL('UPDATE ssBfTransfer SET [Pos]='+IntToStr(aTransferBf.TransferPos)+',[Checksum]='+IntToStr(aTransferBf.TransferChecksum)+',[Responder]='''+glStrToSql(aTransferBf.TransferResponder)+''',[Direction]='+IntToStr(Integer(aTransferBf.TransferDirection))+' WHERE BfName='''+glStrToSql(aTransferBf.BfName)+'''', tmpOleV)<>1 then raise exception.createFmtHelp(cserInternalError, ['UpdAtBg: RecAff<>1 after update'], cnerInternalError);
    ILocalDataBase(aUserInterface).ExecSQL('COMMIT TRANSACTION');
  except
    try ILocalDataBase(aUserInterface).ExecSQL('ROLLBACK TRANSACTION');except end;
    raise;
  end;
end;

procedure TTransferBfsTable.InternalUpdateTableBfInfoAtProcess(var aUserInterface:IUnknown; aTransferBf:ITransferBf);
begin
  if not Assigned(aTransferBf) then raise exception.create('TransferBf is not assigned.');
  if not aTransferBf.Transfering then raise exception.create('Unable to UpdateAtProcess. Transfering is false.');
  InternalInitLocalDataBase(ILocalDataBase(aUserInterface));
  if ILocalDataBase(aUserInterface).ExecSQL('UPDATE ssBfTransfer SET [Pos]='+IntToStr(aTransferBf.TransferPos)+',[Checksum]='+IntToStr(aTransferBf.TransferChecksum)+' WHERE BfName='''+glStrToSql(aTransferBf.BfName)+'''')<>1 then raise exception.createFmtHelp(cserInternalError, ['AtProcess: RecordAffected<>1 after update'], cnerInternalError);
end;

procedure TTransferBfsTable.InternalUpdateTableBfInfoAtComplete(var aUserInterface:IUnknown; aTransferBf:ITransferBf);
//  var tmpOleV:OleVariant;
//      tmpParams:TParams;
begin
  if not Assigned(aTransferBf) then raise exception.create('TransferBf is not assigned.');
  //if aTransferBf.Transfering then raise exception.create('Unable to UpdateAtComplete. Transfering is true.');
  InternalInitLocalDataBase(ILocalDataBase(aUserInterface));
  ILocalDataBase(aUserInterface).ExecSQL('DELETE FROM ssBfTransfer WHERE BfName='''+glStrToSql(aTransferBf.BfName)+'''');
  //tmpParams:=TParams.Create;
  //try
    //With tmpParams.CreateParam(ftDateTime, 'TransferedDate', ptUnknown) do AsDateTime:=Now;
    //tmpOleV:=PackageParams(tmpParams);
    //if ILocalDataBase(aUserInterface).ExecSQL('UPDATE ssBf SET TransferPos=NULL,TransferChecksum=NULL,TransferedDate=:TransferedDate WHERE IdssBf='+glStrToSql(aTransferBf.BfName), tmpOleV)<>1 then ?raise exception.create('AtComplete: RecordAffected<>1 after update. Contact to developer.');
    //tmpOleV:=unassigned;
  //finally
  //  FreeAndNil(tmpParams);
  //end;
end;

procedure TTransferBfsTable.InternalUpdateTableBfInfo(const aBfName:AnsiString; const aNewPath, aNewFileName:AnsiString; var aUserInterface:IUnknown);
begin
  InternalInitLocalDataBase(ILocalDataBase(aUserInterface));
  if ILocalDataBase(aUserInterface).ExecSQL('UPDATE ssBf SET Path='''+glStrToSQL(aNewPath)+''',FileName='+glStrToSQL(aNewFileName)+' WHERE BfName='''+glStrToSql(aBfName)+'''')<>1 then raise exception.createFmtHelp(cserInternalError, ['AtProcess: RecordAffected<>1 after update'], cnerInternalError);
end;

procedure TTransferBfsTable.InternalResponderNameToPlaces(const aConnectionName:AnsiString; const aResponderName:AnsiString; aPlaces:IPackPDPlaces);
begin
  TwoNodeNameToPDPlaces(InternalGetIEPointProperties.NodeName[@aConnectionName], aResponderName, aPlaces);
  (*
  {-$ifndef ESClient}{$ifndef PegasServer}{$ifdef EAMServer}
          tmpTransferPackPD.Places.AddPlace(pdsCommandOnBridge, GL_DataCase.ServerID{[aConnectionName]});
          tmpTransferPackPD.Places.CurrNum:=0;
  {-$else}Нет директив{$endif}{$else}плохие директивы{-$endif}{-$else}
          tmpTransferPackPD.Places.AddPlace(pdsCommandOnID, GL_DataCase.ConnectionId[aConnectionName]);
          tmpTransferPackPD.Places.CurrNum:=1;
  {-$endif}(**)
end;

//          -------- @Pegas(@Root)
//         /      /
//        /      /
//  SQLServer Nodes
//
// "."-Означает отношение субобъекта к объекту. Например: @Pegas.@Node:9.#771
// ":"-Означает соответствие значению. Например: @Pegas.@Node:9
// "#"-Знак номера
// "@"-Префикс для системного имени
// "(" и ")"-скобки для параметра
//
// Системные имена:
// "Pegas"-Пегас(или Root или PGS)
// "SP"-Стореная процедура. Пример: @Pegas.@SP:'lpu_QuickSendMail'(12/0(8('sda@yahoo.com');8('sda@ksho.ru');8('Hi!')))
// "Node"-LocalServer или EMS.
// "User"-Имеетюся ввиду все приложения пользователя. А не клиентские сервера (ближний/дальний)
//     @Pegas.@User:Dcomadm-все пользователи с именем dcomadm в системе.
//     @Pegas.@Node:14.@User:dcomadm -все пользователи с именем dcomadm в магазине ПМ
//     @Pegas.@Node:8.@User:* -все пользователи на Кутузе.
//     @Pegas.@User:* -все пользователи в системе.
//
//  ID
//  User
//  Node
//  Mask
//  NameMask

//  ID
//  User
//  Node

//Pegas.Node:8.Id:781 Node:8.Id:781
//node:7.user:dcomadm

//Node:*.user:*

procedure TTransferBfsTable.InternalInit;
  var tmpRegistry:TRegistry;
begin
  inherited InternalInit; 
  tmpRegistry:=TRegistry.create;
  try
    tmpRegistry.RootKey:=HKEY_LOCAL_MACHINE;
    if not tmpRegistry.OpenKey(cnAppConfigRegPath, false) then raise exception.create('Can''t OpenKey='''+cnAppConfigRegPath+'''');
    if tmpRegistry.ValueExists(csRegValueCacheDirBf) then begin
      FCacheDirBf:=tmpRegistry.ReadString(csRegValueCacheDirBf);
    end else begin
      FCacheDirBf:=InternalGetIAppCacheDir.CacheDir+csBfCacheSubDir;
      tmpRegistry.WriteString(csRegValueCacheDirBf, FCacheDirBf);
    end;
  finally
    tmpRegistry.Free;
  end;  
end;

end.
