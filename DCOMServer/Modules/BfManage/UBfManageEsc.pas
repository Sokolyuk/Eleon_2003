unit UBfManageESC;

interface
  uses UBfManage, Windows, UBfManageTypes, UBfManageESCTypes;
type
  TBfManageEsc=class(TBfManage, IBfManageESC)
  protected
    FRegRootKey:HKEY;
    FRegKeyPath:AnsiString;
    function Get_RegRootKey:HKEY;virtual;
    function Get_RegKeyPath:AnsiString;virtual;
    procedure Set_RegRootKey(value:HKEY);virtual;
    procedure Set_RegKeyPath(const value:AnsiString);virtual;
  protected
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
    property RegRootKey:HKEY read Get_RegRootKey write Set_RegRootKey;
    property RegKeyPath:AnsiString read Get_RegKeyPath write Set_RegKeyPath;
  end;

implementation
  uses UBfUtils, Comobj, Sysutils, UErrorConsts{$IFNDEF VER130}, Variants{$ENDIF}, UTransferConsts, Registry, UBfConsts{$IFDEF VER130}, FileCtrl{$ENDIF};

constructor TBfManageEsc.create;
begin
  inherited create;
  FRegRootKey:=HKEY_LOCAL_MACHINE;
  FRegKeyPath:='\Software\Eleon\Depot\Bf';
end;

destructor TBfManageEsc.destroy;
begin
  inherited destroy;
end;

function TBfManageEsc.Get_RegRootKey:HKEY;
begin
  result:=FRegRootKey;
end;

function TBfManageEsc.Get_RegKeyPath:AnsiString;
begin
  result:=FRegKeyPath;
end;

procedure TBfManageEsc.Set_RegRootKey(value:HKEY);
begin
  FRegRootKey:=value;
end;

procedure TBfManageEsc.Set_RegKeyPath(const value:AnsiString);
begin
  FRegKeyPath:=value;
end;                   

procedure TBfManageEsc.InternalStart;
begin
  inherited InternalStart;
end;

procedure TBfManageEsc.InternalStop;
begin
  inherited InternalStop;
end;

function TBfManageEsc.InternalExists(const guidBf:TGUID; {Out}aFileHandle:PHandle; {Out}aPInfo:PBfInfo; {Out}aPBfTransferInfo:PBfTransferInfo):boolean;
  var tmpRegistry:TRegistry;
      tmpHandle:THandle;
      tmpFileInfo:TFileInfo;
      tmpInfo:TBfInfo;
begin
  if (assigned(aFileHandle))and(aFileHandle^<>0) then begin
    CloseHandle(aFileHandle^);
    aFileHandle^:=0;
  end;
  tmpRegistry:=TRegistry.Create;
  try
    tmpRegistry.RootKey:=FRegRootKey;
    result:=tmpRegistry.OpenKey(FRegKeyPath+'\'+GuidToString(guidBf), false);
    if result then begin//Есть Bf
      tmpInfo.Filename:=tmpRegistry.ReadString('Filename');
      if tmpInfo.Filename='' then raise exception.create('Invalid Filename=''''.');
      tmpInfo.Path:=tmpRegistry.ReadString('Path');
      if (tmpInfo.Path<>'')and(tmpInfo.Path[Length(tmpInfo.Path)]<>'\') then tmpInfo.Path:=tmpInfo.Path+'\';
      tmpInfo.BfType:=tmpRegistry.ReadInteger('BfType');
      tmpInfo.Commentary:=tmpRegistry.ReadString('Commentary');
      tmpHandle:=InternalFileOpenRead(glConvertToTableBfLocation(InternalGetBfCachePath, tmpInfo.Path, tmpInfo.Filename, nil), @tmpFileInfo);
      try
        if tmpRegistry.ValueExists('TotalSize') then tmpInfo.TotalSize:=tmpRegistry.ReadInteger('TotalSize') else tmpInfo.TotalSize:=0;
        if tmpRegistry.ValueExists('ChecksumDate') then tmpInfo.ChecksumDate:=tmpRegistry.ReadDateTime('ChecksumDate') else tmpInfo.ChecksumDate:=0;
        if tmpRegistry.ValueExists('Checksum') then tmpInfo.Checksum:=tmpRegistry.ReadInteger('Checksum') else tmpInfo.Checksum:=0;
        if (not tmpRegistry.ValueExists('TransferPos'))and((not tmpRegistry.ValueExists('Checksum'))or(tmpInfo.ChecksumDate<>tmpFileInfo.FileDateTime)or(tmpInfo.TotalSize<>tmpFileInfo.TotalSize)) then begin
          tmpInfo.Checksum:=InternalRecalcChecksum(tmpHandle, $FFFFFFFF);
          tmpRegistry.WriteInteger('Checksum', tmpInfo.Checksum);
          tmpInfo.ChecksumDate:=tmpFileInfo.FileDateTime;
          tmpRegistry.WriteDateTime('ChecksumDate', tmpInfo.ChecksumDate);
          tmpInfo.TotalSize:=tmpFileInfo.TotalSize;
          tmpRegistry.WriteInteger('TotalSize', tmpInfo.TotalSize);
        end;
      finally
        if assigned(aFileHandle) then aFileHandle^:=tmpHandle else CloseHandle(tmpHandle);
      end;
      if assigned(aPInfo) then aPInfo^:=tmpInfo;
      if assigned(aPBfTransferInfo) then begin
        aPBfTransferInfo^.Transfering:=tmpRegistry.ValueExists('TransferPos');
        if aPBfTransferInfo^.Transfering then begin
          aPBfTransferInfo^.Pos:=tmpRegistry.ReadInteger('TransferPos');
          aPBfTransferInfo^.Checksum:=tmpRegistry.ReadInteger('TransferChecksum');
          aPBfTransferInfo^.Responder:=tmpRegistry.ReadString('TransferResponder');
          aPBfTransferInfo^.Direction:=tmpRegistry.ReadInteger('TransferDirection');
        end else begin
          aPBfTransferInfo^.Pos:=0;
          aPBfTransferInfo^.Checksum:=0;
          aPBfTransferInfo^.Responder:='';
        end;
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
    tmpRegistry.Free;
  end;
end;

function TBfManageEsc.InternalDelete(const guidBf:TGUID):boolean;
  var tmpRegistry:TRegistry;
      tmpFilename, tmpPath, tmpFilePath:AnsiString;
begin
  tmpRegistry:=TRegistry.create;
  try
    tmpRegistry.RootKey:=FRegRootKey;
    result:=tmpRegistry.OpenKey(FRegKeyPath+'\'+GuidToString(guidBf), false);
    if result then begin//Есть Bf
      tmpFilename:=tmpRegistry.ReadString('Filename');
      if tmpFilename='' then raise exception.create('Invalid Filename=''''.');
      tmpPath:=tmpRegistry.ReadString('Path');
      if (tmpPath<>'')and(tmpPath[Length(tmpPath)]<>'\') then tmpPath:=tmpPath+'\';
      tmpFilePath:=glConvertToTableBfLocation(InternalGetBfCachePath, tmpPath, tmpFilename, nil);
      if (FileExists(tmpFilePath))and(not deletefile(tmpFilePath)) then raise exception.create('DeleteFile: '''+tmpFilePath+'''');
      if not tmpRegistry.DeleteKey(FRegKeyPath+'\'+GuidToString(guidBf)) then raise exception.create('DeleteKey: '''+FRegKeyPath+'\'+GuidToString(guidBf)+'''.');
    end;
  finally
    tmpRegistry.free;
  end;
end;

function TBfManageEsc.InternalInsert(const guidBf:TGUID; const aBfInfo:TBfInfo; const aTransferResponder:AnsiString; aTransferDirection:TTransferDirection; {Out}aFileHandle:PHandle; out aBfTransferInfo:TBfTransferInfo):boolean;
  var tmpHandle:THandle;
      tmpFileName:AnsiString;
      tmpFileInfo:TFileInfo;
      tmpRegistry:TRegistry;
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
        tmpRegistry:=TRegistry.Create;
        try
          tmpRegistry.RootKey:=FRegRootKey;
          if not tmpRegistry.OpenKey(FRegKeyPath+'\'+GuidToString(guidBf), true) then raise exception.create('Can''t open key: '''+FRegKeyPath+'\'+GuidToString(guidBf)+'''.');
          //tmpRegistry.WriteString('guidBf', GUIDToString(guidBf));
          tmpRegistry.WriteString('Path', aBfInfo.Path);
          tmpRegistry.WriteString('Filename', aBfInfo.Filename);
          tmpRegistry.WriteInteger('TotalSize', aBfInfo.TotalSize);
          tmpRegistry.WriteInteger('Checksum', aBfInfo.Checksum);
          tmpRegistry.WriteDateTime('ChecksumDate', aBfInfo.ChecksumDate);
          tmpRegistry.WriteInteger('BfType', aBfInfo.BfType);
          tmpRegistry.WriteString('Commentary', aBfInfo.Commentary);
          if tmpRegistry.ValueExists('TransferPos') then tmpRegistry.DeleteValue('TransferPos');
          if tmpRegistry.ValueExists('TransferChecksum') then tmpRegistry.DeleteValue('TransferChecksum');
          if tmpRegistry.ValueExists('TransferResponder') then tmpRegistry.DeleteValue('TransferResponder');
          if tmpRegistry.ValueExists('TransferDirection') then tmpRegistry.DeleteValue('TransferDirection');
        finally
          tmpRegistry.Free;
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
      tmpRegistry:=TRegistry.Create;
      try
        tmpRegistry.RootKey:=FRegRootKey;
        if not tmpRegistry.OpenKey(FRegKeyPath+'\'+GuidToString(guidBf), true) then raise exception.create('Can''t open key: '''+FRegKeyPath+'\'+GuidToString(guidBf)+'''.');
        //tmpRegistry.WriteString('guidBf', GUIDToString(guidBf));
        tmpRegistry.WriteString('Path', aBfInfo.Path);
        tmpRegistry.WriteString('Filename', aBfInfo.Filename);
        tmpRegistry.WriteInteger('TotalSize', aBfInfo.TotalSize);
        tmpRegistry.WriteInteger('Checksum', aBfInfo.Checksum);
        tmpRegistry.WriteDateTime('ChecksumDate', aBfInfo.ChecksumDate);
        tmpRegistry.WriteInteger('BfType', aBfInfo.BfType);
        tmpRegistry.WriteString('Commentary', aBfInfo.Commentary);
        tmpRegistry.WriteInteger('TransferPos', 0);
        tmpRegistry.WriteInteger('TransferChecksum', 0);
        tmpRegistry.WriteString('TransferResponder', aTransferResponder);
        tmpRegistry.WriteInteger('TransferDirection', integer(aTransferDirection));
      finally
        tmpRegistry.free;
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

{procedure TBfManageEsc.InternalUpdate(const guidBf:TGUID; const aBfInfo:TBfInfo);
begin
  raise exception.createFmtHelp(cserInternalError, ['UNDERCONSTRUCTION'], cnerInternalError);
end;}

procedure TBfManageEsc.InternalTransferWrite(const guidBf:TGUID; aFileHandle:THandle; const aTransferWriteIn:TTransferWriteIn; out aTransferWriteOut:TTransferWriteOut);
  var tmpBytesWrite:Cardinal;
      tmpPntr:Pointer;
      tmpTransferPos:Cardinal;
      tmpTransferChecksum:Integer;
      tmpRegistry:TRegistry;
begin
  tmpRegistry:=TRegistry.create;
  try
    tmpRegistry.RootKey:=FRegRootKey;
    if not tmpRegistry.OpenKey(FRegKeyPath+'\'+GuidToString(guidBf), false) then raise exception.create('OpenKey: '''+FRegKeyPath+'\'+GuidToString(guidBf)+'''.');
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
    aTransferWriteOut.TransferPos:=tmpTransferPos;
    aTransferWriteOut.TransferChecksum:=tmpTransferChecksum;
    tmpRegistry.WriteInteger('TransferPos', tmpTransferPos);
    tmpRegistry.WriteInteger('TransferChecksum', tmpTransferChecksum);
  finally
    tmpRegistry.free;
  end;
end;

procedure TBfManageEsc.InternalTransferRead(aFileHandle:THandle; const aTransferReadIn:TTransferReadIn; out aTransferReadOut:TTransferReadOut);
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

procedure TBfManageEsc.InternalTransferEndWrite(const guidBf:TGUID; var aFileHandle:THandle; aChecksumDate:TDateTime);
  var tmpRegistry:TRegistry;
begin
  tmpRegistry:=TRegistry.create;
  try
    InternalSetFileDateTime(aFileHandle, aChecksumDate);
    tmpRegistry.RootKey:=FRegRootKey;
    if not tmpRegistry.OpenKey(FRegKeyPath+'\'+GuidToString(guidBf), false) then raise exception.create('OpenKey: '''+FRegKeyPath+'\'+GuidToString(guidBf)+'''.');
    tmpRegistry.DeleteValue('TransferPos');
    tmpRegistry.DeleteValue('TransferChecksum');
    tmpRegistry.DeleteValue('TransferResponder');
    tmpRegistry.DeleteValue('TransferDirection');
    if CloseHandle(aFileHandle) then aFileHandle:=0;
  finally
    tmpRegistry.free;
  end;
end;

procedure TBfManageEsc.InternalTransferEndRead(var aFileHandle:THandle);
begin
  if CloseHandle(aFileHandle) then aFileHandle:=0;
end;

function TBfManageEsc.InternalTransferOpenWrite(const guidBf:TGUID; {Out}aFileHandle:PHandle; const aBfInfo:TBfInfo; const aTransferResponder:AnsiString; aTransferDirection:TTransferDirection; out aBfTransferInfo:TBfTransferInfo):boolean;
  var tmpCurrBfInfo:TBfInfo;
      tmpBfFileNameNew, tmpBfFileName, tmpBfFileNameBack:AnsiString;
      tmpFileHandle:THandle;
      tmpRegistry:TRegistry;
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
            tmpRegistry:=TRegistry.create;
            try
              tmpRegistry.RootKey:=FRegRootKey;
              if not tmpRegistry.OpenKey(FRegKeyPath+'\'+GuidToString(guidBf), false) then raise exception.create('Can''t open key: '''+FRegKeyPath+'\'+GuidToString(guidBf)+'''.');
              tmpRegistry.WriteString('Path', aBfInfo.Path);
              tmpRegistry.WriteString('Filename', aBfInfo.Filename);
              tmpRegistry.WriteInteger('TotalSize', aBfInfo.TotalSize);
              tmpRegistry.WriteInteger('Checksum', aBfInfo.Checksum);
              tmpRegistry.WriteDateTime('ChecksumDate', aBfInfo.ChecksumDate);
              tmpRegistry.WriteInteger('BfType', aBfInfo.BfType);
              tmpRegistry.WriteString('TransferResponder', aTransferResponder);
              tmpRegistry.WriteString('Commentary', aBfInfo.Commentary);
              tmpRegistry.WriteInteger('TransferPos', 0);
              tmpRegistry.WriteInteger('TransferChecksum', 0);
              tmpRegistry.WriteInteger('TransferDirection', Integer(aTransferDirection));
              aBfTransferInfo.Transfering:=true;//сбросил на др. файл
              aBfTransferInfo.Pos:=0;
              aBfTransferInfo.Checksum:=0;
              aBfTransferInfo.Responder:=aTransferResponder;
              aBfTransferInfo.Direction:=aTransferDirection;
            finally
              tmpRegistry.free;
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
              tmpRegistry:=TRegistry.create;
              try
                tmpRegistry.RootKey:=FRegRootKey;
                if not tmpRegistry.OpenKey(FRegKeyPath+'\'+GuidToString(guidBf), false) then raise exception.create('Can''t open key: '''+FRegKeyPath+'\'+GuidToString(guidBf)+'''.');
                tmpRegistry.WriteString('Path', aBfInfo.Path);
                tmpRegistry.WriteString('Filename', aBfInfo.Filename);
                tmpRegistry.WriteInteger('BfType', aBfInfo.BfType);
                tmpRegistry.WriteString('TransferResponder', aTransferResponder);
                tmpRegistry.WriteString('Commentary', aBfInfo.Commentary);
                tmpRegistry.WriteInteger('TransferPos', 0);
                tmpRegistry.WriteInteger('TransferChecksum', 0);
                tmpRegistry.WriteInteger('TransferDirection', Integer(aTransferDirection));
                aBfTransferInfo.Pos:=0;//сбросил на 0
                aBfTransferInfo.Checksum:=0;
                aBfTransferInfo.Responder:=aTransferResponder;
                aBfTransferInfo.Direction:=aTransferDirection;
              finally
                tmpRegistry.free;
              end;
            end else begin//Сходится Checksum, др. проверяю и просто update-чу
              if (tmpCurrBfInfo.Path<>aBfInfo.Path)or(tmpCurrBfInfo.Filename<>aBfInfo.Filename)or(tmpCurrBfInfo.BfType<>aBfInfo.BfType)or(aBfTransferInfo.Responder<>aTransferResponder)or(tmpCurrBfInfo.Commentary<>aBfInfo.Commentary) then begin
                tmpRegistry:=TRegistry.create;
                try
                  tmpRegistry.RootKey:=FRegRootKey;
                  if not tmpRegistry.OpenKey(FRegKeyPath+'\'+GuidToString(guidBf), false) then raise exception.create('Can''t open key: '''+FRegKeyPath+'\'+GuidToString(guidBf)+'''.');
                  tmpRegistry.WriteString('Path', aBfInfo.Path);
                  tmpRegistry.WriteString('Filename', aBfInfo.Filename);
                  tmpRegistry.WriteInteger('BfType', aBfInfo.BfType);
                  tmpRegistry.WriteString('TransferResponder', aTransferResponder);
                  tmpRegistry.WriteString('Commentary', aBfInfo.Commentary);
                  tmpRegistry.WriteInteger('TransferDirection', Integer(aTransferDirection));
                finally
                  tmpRegistry.free;
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
            tmpRegistry:=TRegistry.create;
            try
              tmpRegistry.RootKey:=FRegRootKey;
              if not tmpRegistry.OpenKey(FRegKeyPath+'\'+GuidToString(guidBf), false) then raise exception.create('Can''t open key: '''+FRegKeyPath+'\'+GuidToString(guidBf)+'''.');
              tmpRegistry.WriteString('Path', aBfInfo.Path);
              tmpRegistry.WriteString('Filename', aBfInfo.Filename);
              tmpRegistry.WriteInteger('TotalSize', aBfInfo.TotalSize);
              tmpRegistry.WriteInteger('Checksum', aBfInfo.Checksum);
              tmpRegistry.WriteDateTime('ChecksumDate', aBfInfo.ChecksumDate);
              tmpRegistry.WriteInteger('BfType', aBfInfo.BfType);
              tmpRegistry.WriteString('TransferResponder', aTransferResponder);
              tmpRegistry.WriteString('Commentary', aBfInfo.Commentary);
              tmpRegistry.WriteInteger('TransferPos', 0);
              tmpRegistry.WriteInteger('TransferChecksum', 0);
              tmpRegistry.WriteInteger('TransferDirection', Integer(aTransferDirection));
              aBfTransferInfo.Transfering:=true;//сбросил на 0
              aBfTransferInfo.Pos:=0;
              aBfTransferInfo.Checksum:=0;
              aBfTransferInfo.Responder:=aTransferResponder;
              aBfTransferInfo.Direction:=aTransferDirection;
            finally
              tmpRegistry.free;
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
            tmpRegistry:=TRegistry.create;
            try
              tmpRegistry.RootKey:=FRegRootKey;
              if not tmpRegistry.OpenKey(FRegKeyPath+'\'+GuidToString(guidBf), false) then raise exception.create('Can''t open key: '''+FRegKeyPath+'\'+GuidToString(guidBf)+'''.');
              tmpRegistry.WriteString('Path', aBfInfo.Path);
              tmpRegistry.WriteString('Filename', aBfInfo.Filename);
              tmpRegistry.WriteInteger('BfType', aBfInfo.BfType);
              tmpRegistry.WriteString('Commentary', aBfInfo.Commentary);
            finally
              tmpRegistry.free;
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

procedure TBfManageEsc.InternalTransferOpenRead(const guidBf:TGUID; {Out}aFileHandle:PHandle; out aBfInfo:TBfInfo; out aBfTransferInfo:TBfTransferInfo);
begin
  if not InternalExists(guidBf, aFileHandle, @aBfInfo, @aBfTransferInfo) then raise exception.createFmtHelp(cserBfNameNotExists, [GuidToString(guidBf)], cnerBfNameNotExists);
end;

procedure TBfManageEsc.InternalInit;
  var tmpRegistry:TRegistry;
begin
  inherited InternalInit;
  tmpRegistry:=TRegistry.create;
  try
    tmpRegistry.RootKey:=FRegRootKey;
    if (tmpRegistry.OpenKey(FRegKeyPath, false))and(tmpRegistry.ValueExists(csRegValueCacheDirBf)) then begin
      FBfCachePath:=tmpRegistry.ReadString(csRegValueCacheDirBf);
    end else begin
      if not tmpRegistry.OpenKey(FRegKeyPath, true) then raise exception.create('Can''t Open/CreateKey='''+FRegKeyPath+'''');
      FBfCachePath:=InternalGetIAppCacheDir.CacheDir+csBfCacheSubDir;
      tmpRegistry.WriteString(csRegValueCacheDirBf, FBfCachePath);
    end;
  finally
    tmpRegistry.free;
  end;
end;

end.
