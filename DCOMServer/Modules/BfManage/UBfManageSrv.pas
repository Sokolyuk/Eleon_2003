//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UBfManageSrv;

interface
  uses UBfManage, ULocalDataBaseTypes, UBfManageTypes, Windows;
type
  TBfManageSrv=class(TBfManage)
  protected
    FLocalDataBase:ILocalDataBase;
    procedure InternalInit;override;
    procedure InternalStart;override;
    procedure InternalStop;override;
  protected
    function InternalExists(const guidBf:TGUID; {Out}aFileHandle:PHandle; {Out}aPInfo:PBfInfo; {Out}aPBfTransferInfo:PBfTransferInfo):boolean;override;
    function InternalDelete(const guidBf:TGUID):boolean;override;
    function InternalInsert(const guidBf:TGUID; const aBfInfo:TBfInfo; const aTransferResponder:AnsiString; aTransferDirection:TTransferDirection; {Out}aFileHandle:PHandle; out aBfTransferInfo:TBfTransferInfo):boolean;override;
    //procedure InternalUpdate(const guidBf:TGUID; const aBfInfo:TBfInfo);override;
    function InternalTransferOpenWrite(const guidBf:TGUID; {Out}aFileHandle:PHandle; const aBfInfo:TBfInfo; const aTransferResponder:AnsiString; aTransferDirection:TTransferDirection; out aBfTransferInfo:TBfTransferInfo):boolean;override;
    procedure InternalTransferWrite(const guidBf:TGUID; aFileHandle:THandle; const aTransferWriteIn:TTransferWriteIn; out aTransferWriteOut:TTransferWriteOut);override;
    procedure InternalTransferEndWrite(const guidBf:TGUID; var aFileHandle:THandle; aChecksumDate:TDateTime);override;
    procedure InternalTransferOpenRead(const guidBf:TGUID; {Out}aFileHandle:PHandle; out aBfInfo:TBfInfo; out aBfTransferInfo:TBfTransferInfo);override;
    procedure InternalTransferRead(aFileHandle:THandle; const aTransferReadIn:TTransferReadIn; out aTransferReadOut:TTransferReadOut);override;
    procedure InternalTransferEndRead(var aFileHandle:THandle);override;
  public
    constructor create;
    destructor destroy;override;
  end;

implementation
  uses ULocalDataBase, UServerActionConsts, UTrayInterfaceBase, DbClient, DB, UBfUtils, Comobj, Sysutils, UErrorConsts,
       Variants, UTransferConsts, Registry, UAppConfigRegPathConsts, UBfConsts, dialogs;

constructor TBfManageSrv.create;
begin
  inherited create;
end;

destructor TBfManageSrv.destroy;
begin
  FLocalDataBase:=nil;
  inherited destroy;
end;

procedure TBfManageSrv.InternalStart;
begin
  FLocalDataBase:=TLocalDataBase.Create;
  FLocalDataBase.CallerAction:=cnServerAction;
  inherited InternalStart;
end;

procedure TBfManageSrv.InternalStop;
begin
  FLocalDataBase:=nil;
  inherited InternalStop;
end;

function TBfManageSrv.InternalExists(const guidBf:TGUID; {Out}aFileHandle:PHandle; {Out}aPInfo:PBfInfo; {Out}aPBfTransferInfo:PBfTransferInfo):boolean;
  var tmpCds:TClientDataSet;
      tmpHandle:THandle;
      tmpFileInfo:TFileInfo;
      tmpParams:TParams;
      tmpPath:AnsiString;
      tmpChecksum:Integer;
      tmpChecksumDate:TDateTime;
      tmpTotalSize:Integer;
begin
  if (assigned(aFileHandle))and(aFileHandle^<>0) then begin
    CloseHandle(aFileHandle^);
    aFileHandle^:=0;
  end;
  tmpCds:=TClientDataSet.Create(nil);
  try
    tmpCds.Data:=FLocalDataBase.OpenSQL('select Path,Filename,TotalSize,Checksum,ChecksumDate,BfType,TransferPos,TransferChecksum,TransferDirection,TransferResponder,Commentary from ssBf where guidBf='''+GUIDToString(guidBf)+'''');
    result:=tmpCds.RecordCount=1;
    if result then begin//Есть Bf
      tmpPath:=tmpCds.FieldByName('Path').AsString;
      tmpChecksum:=tmpCds.FieldByName('Checksum').AsInteger;
      tmpChecksumDate:=tmpCds.FieldByName('ChecksumDate').AsDateTime;
      tmpTotalSize:=tmpCds.FieldByName('TotalSize').AsInteger;
      if (tmpPath<>'')and(tmpPath[Length(tmpPath)]<>'\') then tmpPath:=tmpPath+'\';
      tmpHandle:=InternalFileOpenRead(glConvertToTableBfLocation(InternalGetBfCachePath, tmpPath, tmpCds.FieldByName('Filename').AsString, nil), @tmpFileInfo);
      try
        if (tmpCds.FieldByName('TransferPos').IsNull)and((tmpCds.FieldByName('Checksum').IsNull)or(tmpChecksumDate<>tmpFileInfo.FileDateTime)or(tmpTotalSize<>tmpFileInfo.TotalSize)) then begin
          tmpParams:=TParams.Create;
          try
            tmpParams.CreateParam(ftInteger, 'Checksum', ptUnknown).AsInteger:=InternalRecalcChecksum(tmpHandle, $FFFFFFFF);
            tmpParams.CreateParam(ftDateTime, 'ChecksumDate', ptUnknown).AsDateTime:=tmpFileInfo.FileDateTime;
            if FLocalDataBase.ExecSQL('update ssBf set Checksum=:Checksum, ChecksumDate=:ChecksumDate, TotalSize='+IntToStr(tmpFileInfo.TotalSize)+' where guidBf='''+GUIDToString(guidBf)+'''', tmpParams)<>1 then raise exception.create('UPDATE RA<>1');
            tmpChecksum:=tmpParams.ParamByName('Checksum').AsInteger;
            tmpChecksumDate:=tmpParams.ParamByName('ChecksumDate').AsDateTime;
            tmpTotalSize:=tmpFileInfo.TotalSize;
          finally
            tmpParams.Free;
          end;
        end;
      finally
        if assigned(aFileHandle) then aFileHandle^:=tmpHandle else CloseHandle(tmpHandle);
      end;
      if assigned(aPInfo) then begin
        aPInfo^.Path:=tmpPath;
        aPInfo^.Filename:=tmpCds.FieldByName('Filename').AsString;
        aPInfo^.TotalSize:=tmpTotalSize;
        aPInfo^.Checksum:=tmpChecksum;
        aPInfo^.ChecksumDate:=tmpChecksumDate;
        aPInfo^.BfType:=tmpCds.FieldByName('BfType').AsInteger;
        aPInfo^.Commentary:=tmpCds.FieldByName('Commentary').AsString;
      end;
      if assigned(aPBfTransferInfo) then begin
        aPBfTransferInfo^.Transfering:=not tmpCds.FieldByName('TransferPos').IsNull;
        aPBfTransferInfo^.Pos:=tmpCds.FieldByName('TransferPos').AsInteger;
        aPBfTransferInfo^.Checksum:=tmpCds.FieldByName('TransferChecksum').AsInteger;
        aPBfTransferInfo^.Responder:=tmpCds.FieldByName('TransferResponder').AsString;
        aPBfTransferInfo^.Direction:=tmpCds.FieldByName('TransferDirection').AsInteger;
      end;
    end else begin//Нет Bf-а
      if assigned(aPInfo) then begin//чищу поля
        aPInfo^.Path:='';
        aPInfo^.Filename:='';
        aPInfo^.Commentary:='';
        aPInfo^.Checksum:=0;
        aPInfo^.ChecksumDate:=0;
        aPInfo^.TotalSize:=0;
        aPInfo^.BfType:=0;
      end;
      if assigned(aPBfTransferInfo) then begin
        aPBfTransferInfo^.Transfering:=false;
        aPBfTransferInfo^.Pos:=0;
        aPBfTransferInfo^.Checksum:=0;
        aPBfTransferInfo^.Responder:='';
        aPBfTransferInfo^.Direction:=0;
      end;
    end;
  finally
    tmpCds.Free;
  end;
end;

function TBfManageSrv.InternalDelete(const guidBf:TGUID):boolean;
  var tmpCds:TClientDataSet;
begin
  tmpCds:=TClientDataSet.Create(nil);
  try
    tmpCds.Data:=FLocalDataBase.OpenSQL('select Path,Filename from ssBf where guidBf='''+GUIDToString(guidBf)+'''');
    result:=tmpCds.RecordCount=1;
    if result then begin//Есть Bf
      deletefile(glConvertToTableBfLocation(InternalGetBfCachePath, tmpCds.FieldByName('Path').AsString, tmpCds.FieldByName('Filename').AsString, nil));
      FLocalDataBase.ExecSQL('delete from ssBf where guidBf='''+GUIDToString(guidBf)+'''');
    end;
  finally
    tmpCds.free;
  end;
end;

function TBfManageSrv.InternalInsert(const guidBf:TGUID; const aBfInfo:TBfInfo; const aTransferResponder:AnsiString; aTransferDirection:TTransferDirection; {Out}aFileHandle:PHandle; out aBfTransferInfo:TBfTransferInfo):boolean;
  var tmpParams:TParams;
      tmpHandle:THandle;
      tmpFileName:AnsiString;
      tmpFileInfo:TFileInfo;
begin
  result:=true;
  if (assigned(aFileHandle))and(aFileHandle^<>0) then begin
    closehandle(aFileHandle^);
    aFileHandle^:=0;
  end;
  tmpFileName:=glConvertToTableBfLocation(InternalGetBfCachePath, aBfInfo.Path, aBfInfo.Filename, nil);
  if FileExists(tmpFileName) then begin
    tmpHandle:=InternalFileOpenRead(tmpFileName, @tmpFileInfo);
    try
      if (aBfInfo.TotalSize=tmpFileInfo.TotalSize)and(aBfInfo.ChecksumDate=tmpFileInfo.FileDateTime)and(aBfInfo.Checksum=InternalRecalcChecksum(tmpHandle, $FFFFFFFF)) then begin
        result:=false;
        tmpParams:=TParams.Create;
        try
          tmpParams.CreateParam(ftGuid, 'guidBf', ptUnknown).AsString:=GUIDToString(guidBf);
          tmpParams.CreateParam(ftString, 'Path', ptUnknown).AsString:=aBfInfo.Path;
          tmpParams.CreateParam(ftString, 'Filename', ptUnknown).AsString:=aBfInfo.Filename;
          tmpParams.CreateParam(ftInteger, 'TotalSize', ptUnknown).AsInteger:=aBfInfo.TotalSize;
          tmpParams.CreateParam(ftInteger, 'Checksum', ptUnknown).AsInteger:=aBfInfo.Checksum;
          tmpParams.CreateParam(ftDateTime, 'ChecksumDate', ptUnknown).AsDateTime:=aBfInfo.ChecksumDate;
          tmpParams.CreateParam(ftInteger, 'BfType', ptUnknown).AsInteger:=aBfInfo.BfType;
          tmpParams.CreateParam(ftString, 'Commentary', ptUnknown).AsString:=aBfInfo.Commentary;
          FLocalDataBase.ExecSQL('insert into ssBf (guidBf,Path,Filename,TotalSize,Checksum,ChecksumDate,BfType,Commentary,TransferPos,TransferChecksum,TransferResponder,TransferDirection)values(:guidBf,:Path,:Filename,:TotalSize,:Checksum,:ChecksumDate,:BfType,:Commentary'+',NULL,NULL,NULL,NULL)', tmpParams);
        finally
          tmpParams.free;
        end;
        aBfTransferInfo.Transfering:=false;
        aBfTransferInfo.Pos:=0;
        aBfTransferInfo.Checksum:=0;
        aBfTransferInfo.Responder:='';
        aBfTransferInfo.Direction:=0;
      end;
    finally
      closehandle(tmpHandle);
    end;
  end else begin
    tmpHandle:=InternalFileCreateWrite(tmpFileName);
    try
      InternalSetFileSize(tmpHandle, aBfInfo.TotalSize);
    finally
      if assigned(aFileHandle) then aFileHandle^:=tmpHandle else CloseHandle(tmpHandle);
    end;
    try
      tmpParams:=TParams.Create;
      try
        tmpParams.CreateParam(ftGuid, 'guidBf', ptUnknown).AsString:=GUIDToString(guidBf);
        tmpParams.CreateParam(ftString, 'Path', ptUnknown).AsString:=aBfInfo.Path;
        tmpParams.CreateParam(ftString, 'Filename', ptUnknown).AsString:=aBfInfo.Filename;
        tmpParams.CreateParam(ftInteger, 'TotalSize', ptUnknown).AsInteger:=aBfInfo.TotalSize;
        tmpParams.CreateParam(ftInteger, 'Checksum', ptUnknown).AsInteger:=aBfInfo.Checksum;
        tmpParams.CreateParam(ftDateTime, 'ChecksumDate', ptUnknown).AsDateTime:=aBfInfo.ChecksumDate;
        tmpParams.CreateParam(ftInteger, 'BfType', ptUnknown).AsInteger:=aBfInfo.BfType;
        tmpParams.CreateParam(ftString, 'Commentary', ptUnknown).AsString:=aBfInfo.Commentary;
        tmpParams.CreateParam(ftInteger, 'TransferPos', ptUnknown).AsInteger:=0;
        tmpParams.CreateParam(ftInteger, 'TransferChecksum', ptUnknown).AsInteger:=0;
        tmpParams.CreateParam(ftString, 'TransferResponder', ptUnknown).AsString:=aTransferResponder;
        tmpParams.CreateParam(ftInteger, 'TransferDirection', ptUnknown).AsInteger:=aTransferDirection;//Checksum,ChecksumDate,:Checksum,:ChecksumDate,
        FLocalDataBase.ExecSQL('insert into ssBf (guidBf,Path,Filename,TotalSize,Checksum,ChecksumDate,BfType,Commentary,TransferPos,TransferChecksum,TransferResponder,TransferDirection)values(:guidBf,:Path,:Filename,:TotalSize,:Checksum,:ChecksumDate,:BfType,:Commentary,:TransferPos,:'+'TransferChecksum,:TransferResponder,:TransferDirection)', tmpParams);
      finally
        tmpParams.free;
      end;
      aBfTransferInfo.Transfering:=true;
      aBfTransferInfo.Pos:=0;
      aBfTransferInfo.Checksum:=0;
      aBfTransferInfo.Responder:=aTransferResponder;
      aBfTransferInfo.Direction:=aTransferDirection;
    except
      if assigned(aFileHandle) then begin
        CloseHandle(aFileHandle^);
        aFileHandle^:=0;
      end;
      DeleteFile(tmpFileName);
      raise;
    end;
  end;
end;

{procedure TBfManageSrv.InternalUpdate(const guidBf:TGUID; const aBfInfo:TBfInfo);
begin
  raise exception.createFmtHelp(cserInternalError, ['UNDERCONSTRUCTION'], cnerInternalError);
end;}

procedure TBfManageSrv.InternalTransferWrite(const guidBf:TGUID; aFileHandle:THandle; const aTransferWriteIn:TTransferWriteIn; out aTransferWriteOut:TTransferWriteOut);
  var tmpBytesWrite:Cardinal;
      tmpPntr:Pointer;
      tmpTransferPos:Cardinal;
      tmpTransferChecksum:Integer;
begin
  tmpTransferPos:=aTransferWriteIn.Pos+aTransferWriteIn.Size;
  tmpTransferChecksum:=aTransferWriteIn.Checksum xor aTransferWriteIn.TransferChecksum;
  if SetFilePointer(aFileHandle, aTransferWriteIn.Pos, nil, FILE_BEGIN)=$FFFFFFFF then raise exception.createHelp(SysErrorMessage(GetLastError), cnerSetFilePointer);
  tmpPntr:=VarArrayLock(aTransferWriteIn.Data);
  try
    if InternalBuffToChecksum(tmpPntr, aTransferWriteIn.Size)<>aTransferWriteIn.Checksum then raise exception.createHelp('Checksum error.', cnerChecksumError);
    if not WriteFile(aFileHandle, tmpPntr^, aTransferWriteIn.Size, tmpBytesWrite, nil) then raise exception.createHelp(SysErrorMessage(GetLastError), cnerWriteFile);
    if Integer(tmpBytesWrite)<>aTransferWriteIn.Size then raise exception.createFmt(cserInternalError, ['TransferSize<>tmpBytesWrite']);
  finally
    varArrayUnlock(aTransferWriteIn.Data);
  end;
  if FLocalDataBase.ExecSQL('update ssBf set TransferPos='+IntToStr(tmpTransferPos)+', TransferChecksum='+IntToStr(tmpTransferChecksum)+' where guidBf='''+GuidToString(guidBf)+'''')<>1 then raise exception.create('UPDATE RA<>1');
  aTransferWriteOut.TransferPos:=tmpTransferPos;
  aTransferWriteOut.TransferChecksum:=tmpTransferChecksum;
end;

procedure TBfManageSrv.InternalTransferRead(aFileHandle:THandle; const aTransferReadIn:TTransferReadIn; out aTransferReadOut:TTransferReadOut);
  var tmpPntr:Pointer;
      tmpBytesRead:Cardinal;
begin
  //!!Нет проверки на чтение за предами скаченного
  if SetFilePointer(aFileHandle, aTransferReadIn.Pos, nil, FILE_BEGIN)=$FFFFFFFF then raise exception.createHelp(SysErrorMessage(GetLastError), cnerSetFilePointer);
  aTransferReadOut.Data:=VarArrayCreate([0, aTransferReadIn.Size], varByte);
  tmpPntr:=VarArrayLock(aTransferReadOut.Data);
  try
    if not ReadFile(aFileHandle, tmpPntr^, aTransferReadIn.Size, tmpBytesRead, nil) then raise exception.createHelp(SysErrorMessage(GetLastError), cnerReadFile);
    aTransferReadOut.Size:=tmpBytesRead;
    aTransferReadOut.CheckSum:=InternalBuffToChecksum(tmpPntr, aTransferReadOut.Size);
  finally
    varArrayUnlock(aTransferReadOut.Data);
  end;
  if aTransferReadIn.Size<>aTransferReadOut.Size then begin
    varArrayRedim(aTransferReadOut.Data, aTransferReadOut.Size);
  end;
end;

procedure TBfManageSrv.InternalTransferEndWrite(const guidBf:TGUID; var aFileHandle:THandle; aChecksumDate:TDateTime);
begin
  InternalSetFileDateTime(aFileHandle, aChecksumDate);
  if FLocalDataBase.ExecSQL('update ssBf set TransferPos=NULL,TransferChecksum=NULL,TransferResponder=NULL,TransferDirection=NULL where guidBf='''+GuidToString(guidBf)+'''')<>1 then raise exception.create('UPDATE RA<>1');
  if CloseHandle(aFileHandle) then aFileHandle:=0;
end;

procedure TBfManageSrv.InternalTransferEndRead(var aFileHandle:THandle);
begin
  if CloseHandle(aFileHandle) then aFileHandle:=0;
end;

function TBfManageSrv.InternalTransferOpenWrite(const guidBf:TGUID; {Out}aFileHandle:PHandle; const aBfInfo:TBfInfo; const aTransferResponder:AnsiString; aTransferDirection:TTransferDirection; out aBfTransferInfo:TBfTransferInfo):boolean;
  var tmpCurrBfInfo:TBfInfo;
      tmpBfFileNameNew, tmpBfFileName, tmpBfFileNameBack:AnsiString;
      tmpFileHandle:THandle;
      tmpParams:TParams;
      tmpNewBfLocation:boolean;
      tmpFileInfo:TFileInfo;
      tmpBfFileNameBackExt:AnsiString;
      tmpDir:AnsiString;
begin
  result:=true;
  if (assigned(aFileHandle))and(aFileHandle^<>0) then begin
    CloseHandle(aFileHandle^);
    aFileHandle^:=0;
  end;
  if InternalExists(guidBf, nil, @tmpCurrBfInfo, @aBfTransferInfo) then begin
    if aBfTransferInfo.Transfering then begin//качается
      if (tmpCurrBfInfo.Checksum<>aBfInfo.Checksum)or(tmpCurrBfInfo.ChecksumDate<>aBfInfo.ChecksumDate)or(tmpCurrBfInfo.TotalSize<>aBfInfo.TotalSize) then begin//другой файл, меняю его на новый
        tmpBfFileName:=glConvertToTableBfLocation(InternalGetBfCachePath, tmpCurrBfInfo.Path, tmpCurrBfInfo.Filename, nil);
        tmpBfFileNameBackExt:='.BAK';
        repeat
          tmpBfFileNameBack:=tmpBfFileName+tmpBfFileNameBackExt;
          tmpBfFileNameBackExt:=tmpBfFileNameBackExt+'.$';
        until not FileExists(tmpBfFileNameBack);
        if not RenameFile(tmpBfFileName, tmpBfFileNameBack) then raise exception.create('RenameFile '''+tmpBfFileName+''' to '''+tmpBfFileNameBack+''' is false.');
        try
          tmpBfFileNameNew:=glConvertToTableBfLocation(InternalGetBfCachePath, aBfInfo.Path, aBfInfo.Filename, nil);
          tmpFileHandle:=InternalFileCreateWrite(tmpBfFileNameNew);
          try
            InternalSetFileSize(tmpFileHandle, aBfInfo.TotalSize);
            tmpParams:=TParams.create;
            try
              tmpParams.CreateParam(ftString, 'Path', ptUnknown).AsString:=aBfInfo.Path;
              tmpParams.CreateParam(ftString, 'Filename', ptUnknown).AsString:=aBfInfo.Filename;
              tmpParams.CreateParam(ftInteger, 'TotalSize', ptUnknown).AsInteger:=aBfInfo.TotalSize;
              tmpParams.CreateParam(ftInteger, 'Checksum', ptUnknown).AsInteger:=aBfInfo.Checksum;
              tmpParams.CreateParam(ftDateTime, 'ChecksumDate', ptUnknown).AsDateTime:=aBfInfo.ChecksumDate;
              tmpParams.CreateParam(ftInteger, 'BfType', ptUnknown).AsInteger:=aBfInfo.BfType;
              tmpParams.CreateParam(ftString, 'TransferResponder', ptUnknown).AsString:=aTransferResponder;
              tmpParams.CreateParam(ftString, 'Commentary', ptUnknown).AsString:=aBfInfo.Commentary;
              if FLocalDataBase.ExecSQL('update ssBf set Path=:Path,Filename=:Filename,TotalSize=:TotalSize,Checksum=:Checksum,ChecksumDate=:ChecksumDate,BfType=:BfType,TransferPos=0,TransferChecksum=0,TransferDirection='+IntToStr(aTransferDirection)+',TransferResponder=:TransferResponder,Commentary=:Commentary where guidBf='''+GuidToString(guidBf)+'''', tmpParams)<>1 then raise exception.create('UPDATE RA<>1');
              aBfTransferInfo.Transfering:=true;//сбросил на др. файл
              aBfTransferInfo.Pos:=0;
              aBfTransferInfo.Checksum:=0;
              aBfTransferInfo.Responder:=aTransferResponder;
              aBfTransferInfo.Direction:=aTransferDirection;
            finally
              tmpParams.free;
            end;
            if assigned(aFileHandle) then aFileHandle^:=tmpFileHandle else closehandle(tmpFileHandle);
          except
            closehandle(tmpFileHandle);
            deletefile(tmpBfFileNameNew);
            raise;
          end;
          deletefile(tmpBfFileNameBack);
        except
          RenameFile(tmpBfFileNameBack, tmpBfFileName);
          raise;
        end;
      end else begin//тот же файл и размер тот же
        tmpBfFileName:=glConvertToTableBfLocation(InternalGetBfCachePath, tmpCurrBfInfo.Path, tmpCurrBfInfo.Filename, nil);
        tmpBfFileNameNew:=glConvertToTableBfLocation(InternalGetBfCachePath, aBfInfo.Path, aBfInfo.Filename, nil);
        tmpNewBfLocation:=AnsiUpperCase(tmpBfFileName)<>AnsiUpperCase(tmpBfFileNameNew);
        if tmpNewBfLocation then begin
          tmpDir:=ExtractFilePath(tmpBfFileNameNew);
          if not DirectoryExists(tmpDir) then if not ForceDirectories(tmpDir) then raise exception.create('Can''t create folder '''+tmpDir+'''.');
          if not CopyFile(PChar(tmpBfFileName), PChar(tmpBfFileNameNew), true) then raise exception.createHelp(SysErrorMessage(GetLastError), cnerCopyFile);
        end;
        try
          tmpFileHandle:=InternalFileOpenWrite(tmpBfFileNameNew, @tmpFileInfo);
          try
            if aBfTransferInfo.Checksum<>InternalRecalcChecksum(tmpFileHandle, aBfTransferInfo.Pos) then begin//несходится Checksum
              tmpParams:=TParams.create;
              try
                tmpParams.CreateParam(ftString, 'Path', ptUnknown).AsString:=aBfInfo.Path;
                tmpParams.CreateParam(ftString, 'Filename', ptUnknown).AsString:=aBfInfo.Filename;
                tmpParams.CreateParam(ftInteger, 'BfType', ptUnknown).AsInteger:=aBfInfo.BfType;
                tmpParams.CreateParam(ftString, 'TransferResponder', ptUnknown).AsString:=aTransferResponder;
                tmpParams.CreateParam(ftString, 'Commentary', ptUnknown).AsString:=aBfInfo.Commentary;
                if FLocalDataBase.ExecSQL('update ssBf set Path=:Path,Filename=:Filename,BfType=:BfType,TransferPos=0,TransferChecksum=0,TransferDirection='+IntToStr(aTransferDirection)+',TransferResponder=:TransferResponder,Commentary=:Commentary where guidBf='''+GuidToString(guidBf)+'''', tmpParams)<>1 then raise exception.create('UPDATE RA<>1');
                aBfTransferInfo.Pos:=0;//сбросил на 0
                aBfTransferInfo.Checksum:=0;
                aBfTransferInfo.Responder:=aTransferResponder;
                aBfTransferInfo.Direction:=aTransferDirection;
              finally
                tmpParams.free;
              end;
            end else begin//Сходится Checksum, др. проверяю и просто update-чу
              if (tmpCurrBfInfo.Path<>aBfInfo.Path)or(tmpCurrBfInfo.Filename<>aBfInfo.Filename)or(tmpCurrBfInfo.BfType<>aBfInfo.BfType)or(aBfTransferInfo.Responder<>aTransferResponder)or(tmpCurrBfInfo.Commentary<>aBfInfo.Commentary) then begin
                tmpParams:=TParams.create;
                try
                  tmpParams.CreateParam(ftString, 'Path', ptUnknown).AsString:=aBfInfo.Path;
                  tmpParams.CreateParam(ftString, 'Filename', ptUnknown).AsString:=aBfInfo.Filename;
                  tmpParams.CreateParam(ftInteger, 'BfType', ptUnknown).AsInteger:=aBfInfo.BfType;
                  tmpParams.CreateParam(ftString, 'TransferResponder', ptUnknown).AsString:=aTransferResponder;
                  tmpParams.CreateParam(ftString, 'Commentary', ptUnknown).AsString:=aBfInfo.Commentary;
                  if FLocalDataBase.ExecSQL('update ssBf set Path=:Path,Filename=:Filename,BfType=:BfType,TransferDirection='+IntToStr(aTransferDirection)+',TransferResponder=:TransferResponder,Commentary=:Commentary where guidBf='''+GuidToString(guidBf)+'''', tmpParams)<>1 then raise exception.create('UPDATE RA<>1');
                finally
                  tmpParams.free;
                end;
              end;  
            end;
            if assigned(aFileHandle) then aFileHandle^:=tmpFileHandle else closehandle(tmpFileHandle);
            if tmpNewBfLocation then DeleteFile(tmpBfFileName);
          except
            closehandle(tmpFileHandle);
            if assigned(aFileHandle) then aFileHandle^:=0;
            raise;
          end;
        except
          if tmpNewBfLocation then DeleteFile(tmpBfFileNameNew);
          raise;
        end;
      end;
    end else begin//Не качается
      if (tmpCurrBfInfo.Checksum<>aBfInfo.Checksum)or(tmpCurrBfInfo.ChecksumDate<>aBfInfo.ChecksumDate)or(tmpCurrBfInfo.TotalSize<>aBfInfo.TotalSize) then begin//другой файл, меняю его на новый
        tmpBfFileName:=glConvertToTableBfLocation(InternalGetBfCachePath, tmpCurrBfInfo.Path, tmpCurrBfInfo.Filename, nil);
        tmpBfFileNameBackExt:='.BAK';
        repeat
          tmpBfFileNameBack:=tmpBfFileName+tmpBfFileNameBackExt;
          tmpBfFileNameBackExt:=tmpBfFileNameBackExt+'.$';
        until not FileExists(tmpBfFileNameBack);
        if not RenameFile(tmpBfFileName, tmpBfFileNameBack) then raise exception.create('RenameFile '''+tmpBfFileName+''' to '''+tmpBfFileNameBack+''' is false.');
        try
          tmpBfFileNameNew:=glConvertToTableBfLocation(InternalGetBfCachePath, aBfInfo.Path, aBfInfo.Filename, nil);
          tmpFileHandle:=InternalFileCreateWrite(tmpBfFileNameNew);
          try
            InternalSetFileSize(tmpFileHandle, aBfInfo.TotalSize);
            tmpParams:=TParams.create;
            try
              tmpParams.CreateParam(ftString, 'Path', ptUnknown).AsString:=aBfInfo.Path;
              tmpParams.CreateParam(ftString, 'Filename', ptUnknown).AsString:=aBfInfo.Filename;
              tmpParams.CreateParam(ftInteger, 'TotalSize', ptUnknown).AsInteger:=aBfInfo.TotalSize;
              tmpParams.CreateParam(ftInteger, 'Checksum', ptUnknown).AsInteger:=aBfInfo.Checksum;
              tmpParams.CreateParam(ftDateTime, 'ChecksumDate', ptUnknown).AsDateTime:=aBfInfo.ChecksumDate;
              tmpParams.CreateParam(ftInteger, 'BfType', ptUnknown).AsInteger:=aBfInfo.BfType;
              tmpParams.CreateParam(ftString, 'TransferResponder', ptUnknown).AsString:=aTransferResponder;
              tmpParams.CreateParam(ftString, 'Commentary', ptUnknown).AsString:=aBfInfo.Commentary;
              if FLocalDataBase.ExecSQL('update ssBf set Path=:Path,Filename=:Filename,TotalSize=:TotalSize,Checksum=:Checksum,ChecksumDate=:ChecksumDate,BfType=:BfType,TransferPos=0,TransferChecksum=0,TransferDirection='+IntToStr(aTransferDirection)+',TransferResponder=:TransferResponder,Commentary=:Commentary where guidBf='''+GuidToString(guidBf)+'''', tmpParams)<>1 then raise exception.create('UPDATE RA<>1');
              aBfTransferInfo.Transfering:=true;//сбросил на 0
              aBfTransferInfo.Pos:=0;
              aBfTransferInfo.Checksum:=0;
              aBfTransferInfo.Responder:=aTransferResponder;
              aBfTransferInfo.Direction:=aTransferDirection;
            finally
              tmpParams.free;
            end;
            if assigned(aFileHandle) then aFileHandle^:=tmpFileHandle else closehandle(tmpFileHandle);
          except
            closehandle(tmpFileHandle);
            deletefile(tmpBfFileNameNew);
            raise;
          end;
          deletefile(tmpBfFileNameBack);
        except
          RenameFile(tmpBfFileNameBack, tmpBfFileName);
          raise;
        end;
      end else begin//такой же файл
        if (tmpCurrBfInfo.Path<>aBfInfo.Path)or(tmpCurrBfInfo.Filename<>aBfInfo.Filename)or(tmpCurrBfInfo.BfType<>aBfInfo.BfType)or(tmpCurrBfInfo.Commentary<>aBfInfo.Commentary) then begin
          tmpBfFileName:=glConvertToTableBfLocation(InternalGetBfCachePath, tmpCurrBfInfo.Path, tmpCurrBfInfo.Filename, nil);
          tmpBfFileNameNew:=glConvertToTableBfLocation(InternalGetBfCachePath, aBfInfo.Path, aBfInfo.Filename, nil);
          tmpNewBfLocation:=AnsiUpperCase(tmpBfFileName)<>AnsiUpperCase(tmpBfFileNameNew);
          if tmpNewBfLocation then begin
            if not CopyFile(PChar(tmpBfFileName), PChar(tmpBfFileNameNew), true) then raise exception.createHelp(SysErrorMessage(GetLastError), cnerCopyFile);
          end;
          try
            tmpParams:=TParams.create;
            try
              tmpParams.CreateParam(ftString, 'Path', ptUnknown).AsString:=aBfInfo.Path;
              tmpParams.CreateParam(ftString, 'Filename', ptUnknown).AsString:=aBfInfo.Filename;
              tmpParams.CreateParam(ftInteger, 'BfType', ptUnknown).AsInteger:=aBfInfo.BfType;
              tmpParams.CreateParam(ftString, 'Commentary', ptUnknown).AsString:=aBfInfo.Commentary;
              if FLocalDataBase.ExecSQL('update ssBf set Path=:Path,Filename=:Filename,BfType=:BfType,Commentary=:Commentary where guidBf='''+GuidToString(guidBf)+'''', tmpParams)<>1 then raise exception.create('UPDATE RA<>1');
            finally
              tmpParams.free;
            end;
            if (assigned(aFileHandle))and(aFileHandle^<>0) then begin
              CloseHandle(aFileHandle^);
              aFileHandle^:=0;
            end;  
            if tmpNewBfLocation then DeleteFile(tmpBfFileName);
          except
            if tmpNewBfLocation then DeleteFile(tmpBfFileNameNew);
            raise;
          end;
        end;  
        aBfTransferInfo.Transfering:=false;
        aBfTransferInfo.Pos:=0;
        aBfTransferInfo.Checksum:=0;
        aBfTransferInfo.Responder:='';
        aBfTransferInfo.Direction:=0;
        result:=false;
      end;
    end;
  end else result:=InternalInsert(guidBf, aBfInfo, aTransferResponder, aTransferDirection, aFileHandle, aBfTransferInfo);
end;

procedure TBfManageSrv.InternalTransferOpenRead(const guidBf:TGUID; {Out}aFileHandle:PHandle; out aBfInfo:TBfInfo; out aBfTransferInfo:TBfTransferInfo);
begin
  if not InternalExists(guidBf, aFileHandle, @aBfInfo, @aBfTransferInfo) then raise exception.createFmtHelp(cserBfNameNotExists, [GuidToString(guidBf)], cnerBfNameNotExists);
end;

procedure TBfManageSrv.InternalInit;
  var tmpRegistry:TRegistry;
begin
  inherited InternalInit;
  tmpRegistry:=TRegistry.create;
  try
    tmpRegistry.RootKey:=HKEY_LOCAL_MACHINE;
    if not tmpRegistry.OpenKey(cnAppConfigRegPath, false) then raise exception.create('Can''t OpenKey='''+cnAppConfigRegPath+'''');
    if tmpRegistry.ValueExists(csRegValueCacheDirBf) then begin
      FBfCachePath:=tmpRegistry.ReadString(csRegValueCacheDirBf);
    end else begin
      FBfCachePath:=InternalGetIAppCacheDir.CacheDir+csBfCacheSubDir;
      tmpRegistry.WriteString(csRegValueCacheDirBf, FBfCachePath);
    end;
  finally
    tmpRegistry.Free;
  end;
end;

end.
