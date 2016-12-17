//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UBfManage;

interface
  uses UTrayInterface, UBfManageTypes, UAppCacheDirTypes, windows;
type
  TBfManage=class(TTrayInterface, IBfManage)
  protected
    FBfCachePath:AnsiString;
    FAppCacheDir:IAppCacheDir;
    function InternalGetBfCachePath:AnsiString;virtual;
    function InternalGetIAppCacheDir:IAppCacheDir;virtual;
  protected
    procedure InternalFinal;override;
    function InternalGetInitGUIDCount:Cardinal;override;
    procedure InternalInitGUIDList;override;
  protected
    function InternalBuffToChecksum(aPointer:Pointer; aCount:Cardinal):Integer;virtual;
    function InternalRecalcChecksum(aFileHandle:THandle; aToPos:Cardinal):Integer;virtual;
    procedure InternalSetFileDateTime(aFileHandle:THandle; aDateTime:TDateTime);virtual;
    procedure InternalSetFileSize(aFileHandle:THandle; aTotalSize:cardinal);virtual;
    procedure InternalGetFileInfo(aHandle:THandle; out aFileInfo:TFileInfo);virtual;
  protected
    function InternalExists(const guidBf:TGUID; {Out}aFileHandle:PHandle; {Out}aPInfo:PBfInfo; {Out}aPBfTransferInfo:PBfTransferInfo):boolean;virtual;abstract;
    function InternalDelete(const guidBf:TGUID):boolean;virtual;abstract;
    function InternalInsert(const guidBf:TGUID; const aBfInfo:TBfInfo; const aTransferResponder:AnsiString; aTransferDirection:TTransferDirection; {Out}aFileHandle:PHandle; out aBfTransferInfo:TBfTransferInfo):boolean;virtual;abstract;
    function InternalTransferOpenWrite(const guidBf:TGUID; {Out}aFileHandle:PHandle; const aBfInfo:TBfInfo; const aTransferResponder:AnsiString; aTransferDirection:TTransferDirection; out aBfTransferInfo:TBfTransferInfo):boolean;virtual;abstract;
    procedure InternalTransferWrite(const guidBf:TGUID; aFileHandle:THandle; const aTransferWriteIn:TTransferWriteIn; out aTransferWriteOut:TTransferWriteOut);virtual;abstract;
    procedure InternalTransferEndWrite(const guidBf:TGUID; var aFileHandle:THandle; aChecksumDate:TDateTime);virtual;abstract;
    procedure InternalTransferOpenRead(const guidBf:TGUID; {Out}aFileHandle:PHandle; out aBfInfo:TBfInfo; out aBfTransferInfo:TBfTransferInfo);virtual;abstract;
    procedure InternalTransferRead(aFileHandle:THandle; const aTransferReadIn:TTransferReadIn; out aTransferReadOut:TTransferReadOut);virtual;abstract;
    procedure InternalTransferEndRead(var aFileHandle:THandle);virtual;abstract;
  public
    constructor create;
    destructor destroy;override;
  public
    function InternalFileOpenRead(const aFilePath:AnsiString; {out}aPFileInfo:PFileInfo):THandle;virtual;
    function InternalFileOpenWrite(const aFilePath:AnsiString; {out}aPFileInfo:PFileInfo):THandle;virtual;
    function InternalFileCreateWrite(const aFilePath:AnsiString):THandle;virtual;
    //..
    function Exists(const guidBf:TGUID; {Out}aFileHandle:PHandle; {Out}aPInfo:PBfInfo; {Out}aPBfTransferInfo:PBfTransferInfo):boolean;virtual;
    function Delete(const guidBf:TGUID):boolean;virtual;
    procedure Insert(const guidBf:TGUID; const aBfInfo:TBfInfo; const aTransferResponder:AnsiString; aTransferDirection:TTransferDirection; {Out}aFileHandle:PHandle; out aBfTransferInfo:TBfTransferInfo);virtual;
    //function Update(const guidBf:TGUID; const aBfInfo:TBfInfo);virtual;
    function TransferOpenWrite(const guidBf:TGUID; {Out}aFileHandle:PHandle; const aBfInfo:TBfInfo; const aTransferResponder:AnsiString; aTransferDirection:TTransferDirection; out aBfTransferInfo:TBfTransferInfo):boolean;virtual;
    procedure TransferWrite(const guidBf:TGUID; aFileHandle:THandle; const aTransferWriteIn:TTransferWriteIn; out aTransferWriteOut:TTransferWriteOut);virtual;
    procedure TransferEndWrite(const guidBf:TGUID; var aFileHandle:THandle; aChecksumDate:TDateTime);virtual;
    procedure TransferOpenRead(const guidBf:TGUID; {Out}aFileHandle:PHandle; out aBfInfo:TBfInfo; out aBfTransferInfo:TBfTransferInfo);virtual;
    procedure TransferRead(aFileHandle:THandle; const aTransferReadIn:TTransferReadIn; out aTransferReadOut:TTransferReadOut);virtual;
    procedure TransferEndRead(var aFileHandle:THandle);virtual;
  end;

implementation
  uses Sysutils, UErrorConsts, UBfConsts{$IFDEF VER130}, FileCtrl{$ENDIF};

constructor TBfManage.create;
begin
  inherited create;
  FBfCachePath:='';
  FAppCacheDir:=nil;
end;

destructor TBfManage.destroy;
begin
  FBfCachePath:='';
  FAppCacheDir:=nil;
  inherited destroy;
end;

function TBfManage.InternalGetBfCachePath:AnsiString;
begin
  Result:=FBfCachePath;
end;

function TBfManage.Exists(const guidBf:TGUID; {Out}aFileHandle:PHandle; {Out}aPInfo:PBfInfo; {Out}aPBfTransferInfo:PBfTransferInfo):boolean;
begin
  InternalCheckStateAsTrayForWork(true);
  result:=InternalExists(guidBf, aFileHandle, aPInfo, aPBfTransferInfo);
end;

function TBfManage.Delete(const guidBf:TGUID):boolean;
begin
  InternalCheckStateAsTrayForWork(true);
  result:=InternalDelete(guidBf);
end;

procedure TBfManage.Insert(const guidBf:TGUID; const aBfInfo:TBfInfo; const aTransferResponder:AnsiString; aTransferDirection:TTransferDirection; {Out}aFileHandle:PHandle; out aBfTransferInfo:TBfTransferInfo);
begin
  InternalCheckStateAsTrayForWork(true);
  InternalInsert(guidBf, aBfInfo, aTransferResponder, aTransferDirection, aFileHandle, aBfTransferInfo);
end;

function TBfManage.TransferOpenWrite(const guidBf:TGUID; {Out}aFileHandle:PHandle; const aBfInfo:TBfInfo; const aTransferResponder:AnsiString; aTransferDirection:TTransferDirection; out aBfTransferInfo:TBfTransferInfo):boolean;
begin
  InternalCheckStateAsTrayForWork(true);
  result:=InternalTransferOpenWrite(guidBf, aFileHandle, aBfInfo, aTransferResponder, aTransferDirection, aBfTransferInfo);
end;

procedure TBfManage.TransferOpenRead(const guidBf:TGUID; {Out}aFileHandle:PHandle; out aBfInfo:TBfInfo; out aBfTransferInfo:TBfTransferInfo);
begin
  InternalCheckStateAsTrayForWork(true);
  InternalTransferOpenRead(guidBf, aFileHandle, aBfInfo, aBfTransferInfo);
end;

procedure TBfManage.TransferWrite(const guidBf:TGUID; aFileHandle:THandle; const aTransferWriteIn:TTransferWriteIn; out aTransferWriteOut:TTransferWriteOut);
begin
  InternalCheckStateAsTrayForWork(true);
  InternalTransferWrite(guidBf, aFileHandle, aTransferWriteIn, aTransferWriteOut);
end;

procedure TBfManage.TransferEndWrite(const guidBf:TGUID; var aFileHandle:THandle; aChecksumDate:TDateTime);
begin
  InternalCheckStateAsTrayForWork(true);
  InternalTransferEndWrite(guidBf, aFileHandle, aChecksumDate);
end;

procedure TBfManage.TransferRead(aFileHandle:THandle; const aTransferReadIn:TTransferReadIn; out aTransferReadOut:TTransferReadOut);
begin
  InternalCheckStateAsTrayForWork(true);
  InternalTransferRead(aFileHandle, aTransferReadIn, aTransferReadOut);
end;

procedure TBfManage.TransferEndRead(var aFileHandle:THandle);
begin
  InternalCheckStateAsTrayForWork(true);
  InternalTransferEndRead(aFileHandle);
end;

function TBfManage.InternalFileOpenRead(const aFilePath:AnsiString; {out}aPFileInfo:PFileInfo):THandle;
begin
  result:=CreateFile(PChar(aFilePath), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if (result=0)or(result=$FFFFFFFF) then raise exception.createHelp(SysErrorMessage(GetLastError)+'('+aFilePath+').', cnerCreateFile);
  try
    if assigned(aPFileInfo) then InternalGetFileInfo(result, aPFileInfo^);
  except
    CloseHandle(result);
    raise;
  end;
end;

function TBfManage.InternalFileOpenWrite(const aFilePath:AnsiString; {out}aPFileInfo:PFileInfo):THandle;
begin
  result:=CreateFile(PChar(aFilePath), GENERIC_WRITE Or GENERIC_READ, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if (result=0)Or(result=$FFFFFFFF) then raise exception.createHelp(SysErrorMessage(GetLastError)+'('+aFilePath+').', cnerCreateFile);
  try
    if assigned(aPFileInfo) then InternalGetFileInfo(result, aPFileInfo^);
  except
    CloseHandle(result);
    raise;
  end;
end;

function TBfManage.InternalFileCreateWrite(const aFilePath:AnsiString):THandle;
  var tmpDir:AnsiString;
begin
  tmpDir:=ExtractFilePath(aFilePath);
  if not DirectoryExists(tmpDir) then if not ForceDirectories(tmpDir) then raise exception.create('Can''t create folder '''+tmpDir+'''.');
  result:=CreateFile(PChar(aFilePath), GENERIC_WRITE Or GENERIC_READ, 0, nil, CREATE_NEW{CREATE_ALWAYS}, FILE_ATTRIBUTE_NORMAL, 0);
  if (result=0)Or(result=$FFFFFFFF) then raise exception.create(SysErrorMessage(GetLastError)+'('+aFilePath+').');
end;

procedure TBfManage.InternalGetFileInfo(aHandle:THandle; out aFileInfo:TFileInfo);
  var tmpByHandleFileInformation:TByHandleFileInformation;
      tmpLocalFileTime:TFileTime;
      tmpInteger:Integer;
begin
  FillChar(tmpByHandleFileInformation, SizeOf(tmpByHandleFileInformation), 0);
  if not GetFileInformationByHandle(aHandle, tmpByHandleFileInformation) then raise Exception.Create('GetFileInformationByHandle: '+SysErrorMessage(GetLastError));
  FileTimeToLocalFileTime(tmpByHandleFileInformation.ftLastWriteTime, tmpLocalFileTime);
  if not FileTimeToDosDateTime(tmpLocalFileTime, LongRec(tmpInteger).Hi, LongRec(tmpInteger).Lo) then raise exception.create('FileTimeToDosDateTime: '+SysErrorMessage(GetLastError));
  aFileInfo.FileDateTime:=FileDateToDateTime(tmpInteger);
  aFileInfo.TotalSize:=tmpByHandleFileInformation.nFileSizeLow;
end;

function TBfManage.InternalBuffToChecksum(aPointer:Pointer; aCount:Cardinal):Integer;
 type PChecksumArray=^TChecksumArray;
      TChecksumArray=Array[0..$FFFFFF] of byte;
  var tmpI:Integer;
      tmpChecksumArray:PChecksumArray;
begin
  tmpChecksumArray:=PChecksumArray(aPointer);
  Result:=0;
  if aCount<>0 then for tmpI:=0 to (aCount div SizeOf(Result))-1 do Result:=Result Xor PInteger(@tmpChecksumArray^[tmpI*SizeOf(Result)])^;
end;

function TBfManage.InternalRecalcChecksum(aFileHandle:THandle; aToPos:Cardinal):Integer;
 Type TChecksumBuff=array[0..4095] of byte;
  var tmpChecksumBuff:TChecksumBuff;
      tmpBytesReaded, tmpBytesToRead:Cardinal;
begin//make the countdown from aToPos.
  Result:=0;
  tmpBytesReaded:=0;
  tmpBytesToRead:=0;
  if SetFilePointer(aFileHandle, 0, nil, FILE_BEGIN)=$FFFFFFFF then raise exception.createHelp(SysErrorMessage(GetLastError), cnerSetFilePointer);
  while true do begin
    if aToPos=0 then break else if aToPos>=SizeOf(tmpChecksumBuff) then tmpBytesToRead:=SizeOf(tmpChecksumBuff) else tmpBytesToRead:=aToPos;
    Dec(aToPos, tmpBytesToRead);
    if not ReadFile(aFileHandle, tmpChecksumBuff, tmpBytesToRead, tmpBytesReaded, nil) then raise exception.createHelp(SysErrorMessage(GetLastError), cnerReadFile);
    Result:=Result xor InternalBuffToChecksum(@tmpChecksumBuff, tmpBytesReaded);
    if tmpBytesReaded<>tmpBytesToRead{SizeOf(tmpChecksumBuff)} then Break;
  end;
end;

procedure TBfManage.InternalFinal;
begin
  FAppCacheDir:=nil;
  inherited InternalFinal;
end;

function TBfManage.InternalGetIAppCacheDir:IAppCacheDir;
begin
  if not assigned(FAppCacheDir) then InternalGetITray.Query(IAppCacheDir, FAppCacheDir);
  result:=FAppCacheDir;
end;

function TBfManage.InternalGetInitGUIDCount:Cardinal;
begin
  result:=inherited InternalGetInitGUIDCount+1;
end;

procedure TBfManage.InternalInitGUIDList;
  var tmpCount:Cardinal;
begin
  inherited InternalInitGUIDList;
  tmpCount:=inherited InternalGetInitGUIDCount;
  GUIDList^.aList[tmpCount]:=IAppCacheDir;
  //GUIDList^.aList[tmpCount+1]:=IAppMessage;
  //GUIDList^.aList[tmpCount+2]:=IThreadsPool;
end;

procedure TBfManage.InternalSetFileDateTime(aFileHandle:THandle; aDateTime:TDateTime);
  var tmpRes:Integer;
begin
  tmpRes:=FileSetDate(aFileHandle, DateTimeToFileDate(aDateTime));
  if tmpRes<>0 then raise exception.createHelp(SysErrorMessage(tmpRes), cnerFileSetDate);
end;

procedure TBfManage.InternalSetFileSize(aFileHandle:THandle; aTotalSize:cardinal);
  var tmpRes:Integer;
      tmpBytesWrite:Cardinal;
begin
  if SetFilePointer(aFileHandle, aTotalSize-1, nil, FILE_BEGIN)=$FFFFFFFF then raise exception.createHelp(SysErrorMessage(tmpRes), cnerSetFilePointer);
  tmpRes:=0;
  if not WriteFile(aFileHandle, tmpRes, 1, tmpBytesWrite, nil) then raise exception.createHelp(SysErrorMessage(GetLastError), cnerWriteFile);
end;

end.
