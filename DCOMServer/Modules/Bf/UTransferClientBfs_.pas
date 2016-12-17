unit UTransferClientBfs;

interface
  Uses UTransferBlobfiles, UTransferClientBlobfilesTypes, UCallerTypes, UBlobfileTypes, ULocalDataDepotTypes;

type
  TTransferClientBlobfiles=class(TTransferBlobfiles, ITransferClientBlobfiles)
  private
  protected
    function InternalBlobfileIdToTableBlobfileInfo(aIdBase:Integer; Var aLocalDataDepot:ILocalDataDepot; Out aTableBlobfileInfo:TTableBlobfileInfo):boolean;override;
    procedure InternalWriteTableBlobfileInfoToReg(aLocalDataDepot:ILocalDataDepot; aTransferBlobFile:ITransferBlobFile);Virtual;
    procedure InternalInsertTableBlobfileInfoAtBegin(Var aLocalDataDepot:ILocalDataDepot; aTransferBlobFile:ITransferBlobFile);override;
    procedure InternalUpdateTableBlobfileInfoAtBegin(Var aLocalDataDepot:ILocalDataDepot; aTransferBlobFile:ITransferBlobFile);override;
    procedure InternalUpdateTableBlobfileInfoAtProcess(Var aLocalDataDepot:ILocalDataDepot; aTransferBlobFile:ITransferBlobFile);override;
    procedure InternalUpdateTableBlobfileInfoAtComplete(Var aLocalDataDepot:ILocalDataDepot; aTransferBlobFile:ITransferBlobFile);override;
    function InternalTableUpdateChecksum(aIdBase:Integer; aFileHandle:THandle; aChecksumDate:TDateTime; Var aLocalDataDepot:ILocalDataDepot):Integer;override;
    //Function InternalReadTBfTransferInfo(aIdBase:Integer; Out aTBfTransferInfo:TTBfTransferInfo; Var aLocalDataDepot:ILocalDataDepot):Boolean{Transfering};override;
    function InternalDeleteTbfInfo(aIdBase:Integer; Var aLocalDataDepot:ILocalDataDepot);override;
    procedure InternalUpdateTableBlobfileInfo(aIdBase:Integer; Const aNewPath, aNewFileName:AnsiString; Var aLocalDataDepot:ILocalDataDepot);override;
    procedure InternalSendPackPD(Const ConnectionName:AnsiString; aPackPD:IPackPD; aCallerAction:ICallerAction);override;
    procedure InternalSendPackPDSleep(Const ConnectionName:AnsiString; aPackPD:IPackPD; aCallerAction:ICallerAction; aSleepTime:Integer);override;
  public
    constructor Create;
    destructor Destroy;override;
    function ITAddTransferDownload(aCallerAction:ICallerAction; Const aConnectionName:AnsiString; aIdBase:Integer; aTransferAuto, aTransferProcessToSender:Boolean; aTransferFrom:TTransferFrom=trfFarServer; aPTransferProcessEvents:PTransferProcessEvents=Nil; aCheckLocalAccessible:boolean=true; Const aTransferName:AnsiString=''; aFileDate:TDateTime=0; aLocalDataDepot:ILocalDataDepot=nil):AnsiString;Override;
    function ITAddTransferParaDownload(aCallerAction:ICallerAction; Const aConnectionName:AnsiString; aIdBase:Integer; aTransferAuto{, aTransferProcessToSender}:Boolean; {aTransferFrom:TTransferFrom=trfFarServer; }aPTransferProcessEvents:PTransferProcessEvents=Nil; {aCheckLocalAccessible:boolean=true;} Const aTransferName:AnsiString=''; aFileDate:TDateTime=0; aLocalDataDepot:ILocalDataDepot=nil):AnsiString;Virtual;
    function ITReceiveAddParaDownloadBlobfile(Const aSenderTransferName:AnsiString; Const aOldTransferName:AnsiString; Const aNewTransferName:AnsiString; aTransferFrom:TTransferFrom; aLocalDataDepot:ILocalDataDepot=nil):Boolean{worked};Virtual;
    function ITReceiveBeginParaDownloadBlobfile(Const aSenderTransferName:AnsiString; aTransferSize:Cardinal; aLocalDataDepot:ILocalDataDepot=nil):Boolean{worked};Virtual;
    function ITReceiveProcessParaDownloadBlobfile(Const aSenderTransferName:AnsiString; aTransferedSize:Cardinal; aTransferErrorCount:Integer; aTransferSpeed:double):Boolean{worked};Virtual;
    function ITReceiveCompleteParaDownloadBlobfile(Const aSenderTransferName:AnsiString; aIdLocal:Integer; aTransferedSize:Cardinal; aTransferErrorCount:Integer; aTransferSpeed:double):Boolean{worked};Virtual;
    function ITReceiveErrorParaDownloadBlobfile(Const aSenderTransferName, aErrorMessage:AnsiString; aHelpContext:Integer; aCanceled:Boolean; aTransferedSize:Cardinal; aTransferErrorCount:Integer; aTransferSpeed:double):Boolean{worked};Virtual;
  end;

implementation
  Uses UPackPDTypes, UPackPD, UPackCPTTypes, UPackCPT, UPackCPRTypes, UPackCPR, UPackCPTaskTypes, Sysutils,
       UADMTypes, UDataCaseConsts, UPackTypes, UTransferBlobFileTypes, UTransferConsts, UTTaskParamsUtils;
       
constructor TTransferClientBlobfiles.Create;
begin
  Inherited Create;
end;

destructor TTransferClientBlobfiles.Destroy;
begin
  Inherited Destroy;
end;

(*Function TTransferClientBlobfiles.InternalReadTBfTransferInfo(aIdBase:Integer; Out aTBfTransferInfo:TTBfTransferInfo; Var aLocalDataDepot:ILocalDataDepot):Boolean{Transfering};
begin
  InternalInitLocalDataDepot(aLocalDataDepot);
  ?
end;(**)

Procedure TTransferClientBlobfiles.InternalSendPackPD(Const ConnectionName:AnsiString; aPackPD:IPackPD; aCallerAction:ICallerAction);
begin
  If Assigned(GL_DataCase.OnSendPackASync) Then GL_DataCase.OnSendPackASync(aConnectionName, aPackPD.AsVariant);
end;

Procedure TTransferClientBlobfiles.InternalSendPackPDSleep(Const ConnectionName:AnsiString; aPackPD:IPackPD; aCallerAction:ICallerAction; aSleepTime:Integer);
begin
  1
end;

Function TTransferClientBlobfiles.InternalDeleteTbfInfo(aIdBase:Integer; Var aLocalDataDepot:ILocalDataDepot);
begin
  InternalInitLocalDataDepot(aLocalDataDepot);
  Result:=aLocalDataDepot.RegistryDepot.Registry.DeleteKey(InternalGetRegistryDepotCacheRegkey+IntToStr(aIdBase));
end;

Procedure TTransferClientBlobfiles.InternalUpdateTableBlobfileInfo(aIdBase:Integer; Const aNewPath, aNewFileName:AnsiString; Var aLocalDataDepot:ILocalDataDepot);
begin
  InternalInitLocalDataDepot(aLocalDataDepot);
  If Not aLocalDataDepot.RegistryDepot.Registry.OpenKey(InternalGetRegistryDepotCacheRegkey+IntToStr(aIdBase), False) Then Raise Exception.Create('Blobfile #'+IntToStr(aIdBase)+' not exists.');
  aLocalDataDepot.RegistryDepot.Registry.WriteString('Path', aNewPath);
  aLocalDataDepot.RegistryDepot.Registry.WriteString('FileName', aNewFileName);
end;

Function TTransferClientBlobfiles.InternalTableUpdateChecksum(aIdBase:Integer; aFileHandle:THandle; aChecksumDate:TDateTime; Var aLocalDataDepot:ILocalDataDepot):Integer;
begin
  try
    InternalInitLocalDataDepot(aLocalDataDepot);
    Result:=InternalRecalcChecksum(aFileHandle);
    If Not aLocalDataDepot.RegistryDepot.Registry.OpenKey(InternalGetRegistryDepotCacheRegkey+IntToStr(aIdBase), False) Then Raise Exception.Create('Blobfile #'+IntToStr(aIdBase)+' not exists.');
    aLocalDataDepot.RegistryDepot.Registry.WriteInteger('Checksum', Result);
    aLocalDataDepot.RegistryDepot.Registry.WriteDateTime('ChecksumDate', aChecksumDate);
  except
    on e:exception do begin
      e.message:='IntTableUpdateChecksum: '+e.message;
      raise;
    end;
  end;
end;

Function TTransferClientBlobfiles.InternalBlobfileIdToTableBlobfileInfo(aIdBase:Integer; Var aLocalDataDepot:ILocalDataDepot; Out aTableBlobfileInfo:TTableBlobfileInfo):boolean;
begin
  try
    InternalInitLocalDataDepot(aLocalDataDepot);
    Result:=aLocalDataDepot.RegistryDepot.Registry.OpenKey(InternalGetRegistryDepotCacheRegkey+IntToStr(aIdBase), False);
    If Result Then begin
      try
        aTableBlobfileInfo.Path:=aLocalDataDepot.RegistryDepot.Registry.ReadString('Path');
        If (aTableBlobfileInfo.Path<>'')And(aTableBlobfileInfo.Path[Length(aTableBlobfileInfo.Path)]<>'\') Then aTableBlobfileInfo.Path:=aTableBlobfileInfo.Path+'\';
        aTableBlobfileInfo.Filename:=aLocalDataDepot.RegistryDepot.Registry.ReadString('Filename');
        aTableBlobfileInfo.Checksum:=aLocalDataDepot.RegistryDepot.Registry.ReadInteger('Checksum');
        aTableBlobfileInfo.ChecksumDate:=aLocalDataDepot.RegistryDepot.Registry.ReadDateTime('ChecksumDate');
        aTableBlobfileInfo.Commentary:=aLocalDataDepot.RegistryDepot.Registry.ReadString('Commentary');
        aTableBlobfileInfo.BfType:=aLocalDataDepot.RegistryDepot.Registry.ReadInteger('BfType');

        ValueExists(
        aTableBlobfileInfo.TransferPos:=aLocalDataDepot.RegistryDepot.Registry.ReadInteger('TransferPos');
        aTableBlobfileInfo.TransferChecksum:=aLocalDataDepot.RegistryDepot.Registry.ReadInteger('TransferChecksum');
        aTableBlobfileInfo.TransferSchedule:=aLocalDataDepot.RegistryDepot.Registry.ReadString('TransferSchedule');
        aTableBlobfileInfo.TransferedDate:=aLocalDataDepot.RegistryDepot.Registry.ReadDateTime('TransferedDate');
      except on e:exception do begin
        e.message:='Read reg(Id='+IntToStr(aIdBase)+'): '+e.message;
        raise;
      end;end;
    end else InternalClearTableBlobfileInfo(aTableBlobfileInfo);
  except on e:exception do begin
    e.message:='IBfIdToTBfInfo: '+e.message;
    raise;
  end;end;
end;

Procedure TTransferClientBlobfiles.InternalWriteTableBlobfileInfoToReg(aLocalDataDepot:ILocalDataDepot; aTransferBlobFile:ITransferBlobFile);
begin
  aLocalDataDepot.RegistryDepot.Registry.WriteString('Path', aTransferBlobFile.TableBfDir);
  aLocalDataDepot.RegistryDepot.Registry.WriteString('Filename', aTransferBlobFile.TableBfName);
  aLocalDataDepot.RegistryDepot.Registry.WriteInteger('Checksum', aTransferBlobFile.TableBfChecksum);
  aLocalDataDepot.RegistryDepot.Registry.WriteDateTime('ChecksumDate', aTransferBlobFile.TableBfDate);
  aLocalDataDepot.RegistryDepot.Registry.WriteString('Commentary', aTransferBlobFile.TableBfCommentary);
  aLocalDataDepot.RegistryDepot.Registry.WriteInteger('BfType', aTransferBlobFile.BfType);
  aLocalDataDepot.RegistryDepot.Registry.WriteString('TransferSchedule', aTransferBlobFile.TransferSchedule);
  if aTransferBlobFile.Transfering then begin
    aLocalDataDepot.RegistryDepot.Registry.WriteInteger('TransferPos', aTransferBlobFile.TransferPos);
    aLocalDataDepot.RegistryDepot.Registry.WriteInteger('TransferChecksum', aTransferBlobFile.TransferChecksum);
  end else begin
    If aLocalDataDepot.RegistryDepot.Registry.ValueExists('TransferPos') Then aLocalDataDepot.RegistryDepot.Registry.DeleteValue('TransferPos');
    If aLocalDataDepot.RegistryDepot.Registry.ValueExists('TransferChecksum') Then aLocalDataDepot.RegistryDepot.Registry.DeleteValue('TransferChecksum');
  end;
end;

Procedure TTransferClientBlobfiles.InternalInsertTableBlobfileInfoAtBegin(Var aLocalDataDepot:ILocalDataDepot; aTransferBlobFile:ITransferBlobFile);
begin
  If Not Assigned(aTransferBlobFile) Then Raise Exception.Create('TransferBlobFile is not assigned.');
  InternalInitLocalDataDepot(aLocalDataDepot);
  try
    If Not aLocalDataDepot.RegistryDepot.Registry.OpenKey(InternalGetRegistryDepotCacheRegkey+IntToStr(aTransferBlobFile.IdBase), True) Then Raise Exception.Create('Unable to create registry key for Blobfile #'+IntToStr(aTransferBlobFile.IdBase)+'.');
    InternalWriteTableBlobfileInfoToReg(aLocalDataDepot, aTransferBlobFile);
  except
    try aLocalDataDepot.RegistryDepot.Registry.DeleteKey(InternalGetRegistryDepotCacheRegkey+IntToStr(aTransferBlobFile.IdBase)); except end;
    Raise;
  end;
end;

Procedure TTransferClientBlobfiles.InternalUpdateTableBlobfileInfoAtProcess(Var aLocalDataDepot:ILocalDataDepot; aTransferBlobFile:ITransferBlobFile);
begin
  If Not Assigned(aTransferBlobFile) Then Raise Exception.Create('TransferBlobFile is not assigned.');
  if not aTransferBlobFile.Transfering then Raise Exception.Create('Unable to UpdateAtProcess. Transfering is false.');
  InternalInitLocalDataDepot(aLocalDataDepot);
  try
    If Not aLocalDataDepot.RegistryDepot.Registry.OpenKey(InternalGetRegistryDepotCacheRegkey+IntToStr(aTransferBlobFile.IdBase), False) Then Raise Exception.Create('Unable to open registry key for Blobfile #'+IntToStr(aTransferBlobFile.IdBase)+'.');
    aLocalDataDepot.RegistryDepot.Registry.WriteInteger('TransferPos', aTransferBlobFile.TransferPos);
    aLocalDataDepot.RegistryDepot.Registry.WriteInteger('TransferChecksum', aTransferBlobFile.TransferChecksum);
  except
    try aLocalDataDepot.RegistryDepot.Registry.DeleteKey(InternalGetRegistryDepotCacheRegkey+IntToStr(aTransferBlobFile.IdBase)); except end;
    Raise;
  end;
end;

Procedure TTransferClientBlobfiles.InternalUpdateTableBlobfileInfoAtComplete(Var aLocalDataDepot:ILocalDataDepot; aTransferBlobFile:ITransferBlobFile);
begin
  If Not Assigned(aTransferBlobFile) Then Raise Exception.Create('TransferBlobFile is not assigned.');
  if aTransferBlobFile.Transfering then Raise Exception.Create('Unable to UpdateAtComplete. Transfering is true.');
  InternalInitLocalDataDepot(aLocalDataDepot);
  try
    If Not aLocalDataDepot.RegistryDepot.Registry.OpenKey(InternalGetRegistryDepotCacheRegkey+IntToStr(aTransferBlobFile.IdBase), True) Then Raise Exception.Create('Unable to create registry key for Blobfile #'+IntToStr(aTransferBlobFile.IdBase)+'.');
    InternalWriteTableBlobfileInfoToReg(aLocalDataDepot, aTransferBlobFile);
    aLocalDataDepot.RegistryDepot.Registry.WriteDateTime('TransferedDate', Now);
  except
    try aLocalDataDepot.RegistryDepot.Registry.DeleteKey(InternalGetRegistryDepotCacheRegkey+IntToStr(aTransferBlobFile.IdBase)); except end;
    Raise;
  end;
end;

Function TTransferClientBlobfiles.ITAddTransferDownload(aCallerAction:ICallerAction; Const aConnectionName:AnsiString; aIdBase:Integer; aTransferAuto, aTransferProcessToSender:Boolean; aTransferFrom:TTransferFrom=trfFarServer; aPTransferProcessEvents:PTransferProcessEvents=Nil; aCheckLocalAccessible:boolean=true; Const aTransferName:AnsiString=''; aFileDate:TDateTime=0; aLocalDataDepot:ILocalDataDepot=nil):AnsiString;
  Var tmpPackCPT:IPackCPT;
      tmpIfAccessibleUseEvents:TUseTransferEvents;
      tmpPack:OleVariant;
      tmpPackCPR:IPackCPR;
      tmpIntIndex:Integer;
      tmpIPackCPTask:IPackCPTask;
      tmpBoolean:Boolean;
begin
  if not assigned(aCallerAction) then Raise Exception.Create('aCallerAction is not assigned.');
  if (not assigned(GL_DataCase.OnSendPackSync))Or(Not assigned(GL_DataCase.OnSendPackSync)) then Raise Exception.Create('OnSendPackSync/ASync is not assigned.');
  Result:='';//Устанавливаю результат-"не добавил"
  FillChar(tmpIfAccessibleUseEvents, SizeOf(tmpIfAccessibleUseEvents), 0);//Уже установилось - tmpIfAccessibleUseEvents.tpToSender:=False;
  If Assigned(aPTransferProcessEvents) Then begin
    tmpIfAccessibleUseEvents.UserData:=aPTransferProcessEvents^.UserData;
    tmpIfAccessibleUseEvents.OnCompleteTransfer:=aPTransferProcessEvents^.OnCompleteTransfer
  end;
  If Not ITBlobfileLocalAccessible(aCallerAction, aIdBase, nil, @tmpIfAccessibleUseEvents, aConnectionName) Then begin//На локальной машине нет такого блоба. Ищу его на локальном сервере.
    tmpPackCPT:=TPackCPT.Create;
    try//Param:[0]-varInteger(ID); [1]-varOleStr:(DownloadBlobfileName); [2]-varBoolean:(TransferAuto); [3]-varBoolean:(TransferProcessToSender); [4]-varInteger:(TransferFrom); [5]-varDate:(FileDate{для докачки})
      tmpPackCPT.CPTTasks.TaskAdd(tskADMBfAccessible, aIdBase, {RouteParam}aIdBase, -1);
      tmpPack:=tmpPackCPT.AsVariant;
      GL_DataCase.OnSendPackSync(aConnectionName, tmpPack);
    finally
      tmpPackCPT:=nil;
    end;
    tmpBoolean:=false;//от варнингов
    tmpPackCPR:=TPackCPR.Create;
    try
      tmpPackCPR.AsVariant:=tmpPack;
      tmpIntIndex:=-1;
      tmpIPackCPTask:=tmpPackCPR.CPTasks.ViewNext(tmpIntIndex);
      If (Not Assigned(tmpIPackCPTask))Or(tmpIPackCPTask.Task<>tskADMBfAccessible) Then Raise Exception.Create('Invalid CPR from local server for tskADMBfAccessible.');
      tmpPackCPR.CPErrors.CheckError(tmpIPackCPTask.Step, nil, nil, true);
      try
        tmpBoolean:=tmpIPackCPTask.Param;
      except
        on e:exception do begin e.Message:='Invalid CPR.Param from local server for tskADMBfAccessible: '''+e.Message+'''.'; Raise; end;
      end;
    finally
      tmpPackCPR:=nil;
    end;
    if tmpBoolean then begin//есть на ближнем сервере
      Result:=Inherited ITAddTransferDownload(aCallerAction, aConnectionName, aIdBase, aTransferAuto, aTransferProcessToSender, aTransferFrom, aPTransferProcessEvents, aCheckLocalAccessible, aTransferName, aFileDate, aLocalDataDepot);
    end else begin//нет на ближнем сервере, надо качать с дальнего
      Result:=ITAddTransferParaDownload(aCallerAction, aConnectionName, aIdBase, aTransferAuto{, aTransferProcessToSender}, {aTransferFrom, }aPTransferProcessEvents, {aCheckLocalAccessible, }aTransferName, aFileDate, aLocalDataDepot);
    end;
  end;
end;

Function TTransferClientBlobfiles.ITAddTransferParaDownload(aCallerAction:ICallerAction; Const aConnectionName:AnsiString; aIdBase:Integer; aTransferAuto{, aTransferProcessToSender}:Boolean; {aTransferFrom:TTransferFrom=trfFarServer; }aPTransferProcessEvents:PTransferProcessEvents=Nil; {aCheckLocalAccessible:boolean=true;} Const aTransferName:AnsiString=''; aFileDate:TDateTime=0; aLocalDataDepot:ILocalDataDepot=nil):AnsiString;
  Var tmpTransferBlobFile:ITransferBlobFile;
      tmpBlobfileInfo:TBlobfileInfo;
      tmpLockOwner:Integer;
      tmpPackPD:IPackPD;
      tmpPackCPT:IPackCPT;
begin{aCallerAction/aConnectionName/aIdBase/aTransferAuto/aPTransferProcessEvents/aTransferName/aFileDate/aLocalDataDepot}
  tmpLockOwner:=GL_DataCase.ITGenerateLockOwner;//Ставлю приватный лок, что бы не качался один файл несколько раз.
  GL_DataCase.ITSetLockWait(csllTransfer+IntToStr(aIdBase), aCallerAction.UserName, tmpLockOwner, True, cnTransferSetLockListWait);
  GL_DataCase.ITFreeLock(csllTransfer+IntToStr(aIdBase), tmpLockOwner);
  //..
  try
    If Not Assigned(aCallerAction) Then Raise Exception.Create('CallerAction is not assigned.');
    tmpLockOwner:=GL_DataCase.ITGenerateLockOwner;//Ставлю приватный лок, что бы не качался один файл несколько раз.
    GL_DataCase.ITSetLockWait(csllTransfer+IntToStr(aIdBase), aCallerAction.UserName, tmpLockOwner, True, cnTransferSetLockListWait);
    try
      tmpBlobfileInfo.FileName:='';
      tmpBlobfileInfo.Date:=aFileDate{+};//Для докачки
      tmpBlobfileInfo.TotalSize:=0;
      tmpTransferBlobFile:=InternalBeginUploadBlobfile(Nil, aCalleraction{+}, aTransferName{+}, @Result, False{CreateFile}, tmpBlobfileInfo, trmParaDownload, trsReceiveParaDownload);
      tmpTransferBlobFile.TransferAuto:=aTransferAuto{+};
      tmpTransferBlobFile.IdBase:=aIdBase{+};//Сохраняю номер файла в таблице
      tmpTransferBlobFile.ConnectionName:=aConnectionName{+};
      If Assigned(aPTransferProcessEvents) Then tmpTransferBlobFile.TransferProcessEvents:=aPTransferProcessEvents^{+};
      //..
      tmpPackPD:=TPackPD.Create;
      try
        tmpPackPD.PDID:=Result;//'BfParaDownloadAdd_'+IntToStr(aIdBase);
        tmpPackPD.PDOptions:=[pdoWithNotificationOfError]+[pdoNoTransform]{+[pdoNoPutOnReSending]+[pdoReturnDataIfError]};
        tmpPackPD.Places.CurrNum:=1;
        tmpPackPD.Places.AddPlace(pdsCommandOnID, Gl_DataCase.ConnectionID[aConnectionName]);
        tmpPackCPT:=TPackCPT.Create;
        try//Param:[0]-varInteger(ID); [1]-varOleStr:(DownloadBlobfileName); [2]-varBoolean:(TransferAuto); [3]-varBoolean:(TransferProcessToSender); [4]-varInteger:(TransferFrom); [5]-varDate:(FileDate{для докачки})
          //[0]-varInteger(ID);
          //[1]-varOleStr:(DownloadBlobfileName);
          //[2]-varBoolean:(TransferAuto);
          //[3]-varBoolean:(TransferProcessToSender);
          //[4]-varInteger:(TransferFrom);
          //[5]-varDate:(FileDate{для докачки})
          //tmpPackCPT.CPID:=Result;
          tmpPackCPT.CPTTasks.TaskAdd(tskADMBfAddTransferDownload, BfAddTransferDownloadToParams(aIdBase, '', aTransferAuto, {aTransferProcessToSender}True, {aTransferFrom}trfFarServer, aFileDate), {RouteParam}{aIdBase}Result, -1);
          tmpPackCPT.CPTOptions:=[{ctoReturnParamsIfError-нужно для разбора}];
          tmpPackPD.DataAsIPack:=tmpPackCPT;
          GL_DataCase.OnSendPackASync(aConnectionName, tmpPackPD.AsVariant);//InternalGetEServerConnection.EPackASync(tmpPackPD.AsVariant);
        finally
          tmpPackCPT:=nil;
        end;
      finally
        tmpPackPD:=Nil;
      end;
    finally
      GL_DataCase.ITFreeLock(csllTransfer+IntToStr(aIdBase), tmpLockOwner);
    end;
  except on e:exception do begin e.message:='ITAddTransferParaDownload: '+e.message;raise;end;end;
end;

Function TTransferClientBlobfiles.ITReceiveAddParaDownloadBlobfile(Const aSenderTransferName:AnsiString; Const aOldTransferName:AnsiString; Const aNewTransferName:AnsiString; aTransferFrom:TTransferFrom; aLocalDataDepot:ILocalDataDepot=nil):Boolean{worked};
  Var tmpTransferBlobFile:ITransferBlobFile;
begin
  Result:=False;//от варнингов
  If aSenderTransferName='' then Raise Exception.Create('aSenderTransferName is empty.');
  tmpTransferBlobFile:=InternalTransferNameToITransferBlobFile(aSenderTransferName, vvmView, True);
  GL_DataCase.ITSetLockWait(csllTransfer+IntToStr(tmpTransferBlobFile.IdBase), tmpTransferBlobFile.CallerActionFirst.UserName, tmpTransferBlobFile.LockOwner, True, cnTransferSetLockListWait);
  try
    If tmpTransferBlobFile.TransferMode<>trmParaDownload Then Raise Exception.Create('TransferMode is not trmParaDownload.');
    try
      tmpTransferBlobFile.LastAccessTime:=Now;
      tmpTransferBlobFile.ResponderTransferOldName:=aOldTransferName;
      tmpTransferBlobFile.ResponderTransferName:=aNewTransferName;
      tmpTransferBlobFile.TransferStep:=trsReceiveParaAddDownload;
      tmpTransferBlobFile.TransferedFrom:=aTransferFrom;
      Result:=InternalSetTransferResult(tmpTransferBlobFile, srsAddDownload, True{raise});
    except
      on e:exception do begin
        try
          e.message:='ITReceiveBfBeginDownload: '+e.message;
          InternalSetTransferError(tmpTransferBlobFile, aSenderTransferName, e.message, E.HelpContext, True);
        except end;
        Raise Exception.CreateHelp(e.message, E.HelpContext);
      end;
    end;
  finally
    GL_DataCase.ITFreeLock(csllTransfer+IntToStr(tmpTransferBlobFile.IdBase), tmpTransferBlobFile.LockOwner);
  end;
end;

Function TTransferClientBlobfiles.ITReceiveBeginParaDownloadBlobfile(Const aSenderTransferName:AnsiString; aTransferSize:Cardinal; aLocalDataDepot:ILocalDataDepot=nil):Boolean{worked};
  Var tmpTransferBlobFile:ITransferBlobFile;
begin
  Result:=False;//от варнингов
  If aSenderTransferName='' then Raise Exception.Create('aSenderTransferName is empty.');
  tmpTransferBlobFile:=InternalTransferNameToITransferBlobFile(aSenderTransferName, vvmView, True);
  GL_DataCase.ITSetLockWait(csllTransfer+IntToStr(tmpTransferBlobFile.IdBase), tmpTransferBlobFile.CallerActionFirst.UserName, tmpTransferBlobFile.LockOwner, True, cnTransferSetLockListWait);
  try
    If tmpTransferBlobFile.TransferMode<>trmParaDownload Then Raise Exception.Create('TransferMode is not trmParaDownload.');
    try
      tmpTransferBlobFile.LastAccessTime:=Now;
      tmpTransferBlobFile.TransferStep:=trsReceiveParaBeginDownload;
      tmpTransferBlobFile.FileTotalSize:=aTransferSize;
      Result:=InternalSetTransferResult(tmpTransferBlobFile, srsBeginDownload, True{falseпоставил true для отладки});
    except
      on e:exception do begin
        try
          e.message:='ITReceiveBfBeginDownload: '+e.message;
          InternalSetTransferError(tmpTransferBlobFile, aSenderTransferName, e.message, E.HelpContext, True);//InternalTransferError(tmpTransferBlobFile, aSenderTransferName, e.message, E.HelpContext, True);
        except end;
        Raise Exception.CreateHelp(e.message, E.HelpContext);
      end;
    end;
  finally
    GL_DataCase.ITFreeLock(csllTransfer+IntToStr(tmpTransferBlobFile.IdBase), tmpTransferBlobFile.LockOwner);
  end;
end;

Function TTransferClientBlobfiles.ITReceiveProcessParaDownloadBlobfile(Const aSenderTransferName:AnsiString; aTransferedSize:Cardinal; aTransferErrorCount:Integer; aTransferSpeed:double):Boolean{worked};
  Var tmpTransferBlobFile:ITransferBlobFile;
begin
  Result:=False;//от варнингов
  tmpTransferBlobFile:=InternalTransferNameToITransferBlobFile(aSenderTransferName, vvmView, True);
  GL_DataCase.ITSetLockWait(csllTransfer+IntToStr(tmpTransferBlobFile.IdBase), tmpTransferBlobFile.CallerActionFirst.UserName, tmpTransferBlobFile.LockOwner, True, cnTransferSetLockListWait);
  try
    If tmpTransferBlobFile.TransferMode<>trmParaDownload Then Raise Exception.Create('TransferMode is not trmParaDownload.');
    try
      tmpTransferBlobFile.LastAccessTime:=Now;
      tmpTransferBlobFile.TransferStep:=trsReceiveParaProcessDownload;
      tmpTransferBlobFile.TransferedSize:=aTransferedSize;
      tmpTransferBlobFile.TransferErrorCount:=aTransferErrorCount;
      tmpTransferBlobFile.TransferSpeed:=aTransferSpeed;
      Result:=InternalSetTransferResult(tmpTransferBlobFile, srsProcessDownload, True);//InternalTransferComplete(tmpTransferBlobFile, VarArrayOf([1, Integer(((tmpTransferBlobFile.TransferedSize*100)Div tmpTransferBlobFile.FileTotalSize))]), False);
    except
      on e:exception do begin
        e.message:='ITReceiveDownloadBlobfile: '+e.message;
        InternalSetTransferError(tmpTransferBlobFile, aSenderTransferName, e.message, E.HelpContext, True);//InternalTransferError(tmpTransferBlobFile, aSenderTransferName, e.message, E.HelpContext, True);
        Raise;
      end;
    end;
  finally
    GL_DataCase.ITFreeLock(csllTransfer+IntToStr(tmpTransferBlobFile.IdBase), tmpTransferBlobFile.LockOwner);
  end;
end;

Function TTransferClientBlobfiles.ITReceiveCompleteParaDownloadBlobfile(Const aSenderTransferName:AnsiString; aIdLocal:Integer; aTransferedSize:Cardinal; aTransferErrorCount:Integer; aTransferSpeed:double):Boolean{worked};
  Var tmpTransferBlobFile:ITransferBlobFile;
      tmpTransferProcessEvents:TTransferProcessEvents;
begin
  Result:=False;//от варнингов
  tmpTransferBlobFile:=InternalTransferNameToITransferBlobFile(aSenderTransferName, vvmView, True);//для попытки залочить
  GL_DataCase.ITSetLockWait(csllTransfer+IntToStr(tmpTransferBlobFile.IdBase), tmpTransferBlobFile.CallerActionFirst.UserName, tmpTransferBlobFile.LockOwner, True, cnTransferSetLockListWait);
  try
    if tmpTransferBlobFile.TransferMode<>trmParaDownload then raise exception.create('TransferMode is not trmParaDownload.');
    try
      tmpTransferBlobFile.LastAccessTime:=Now;
      tmpTransferBlobFile.IdLocal:=aIdLocal;
      tmpTransferBlobFile.TransferedSize:=aTransferedSize;
      tmpTransferBlobFile.TransferErrorCount:=aTransferErrorCount;
      tmpTransferBlobFile.TransferSpeed:=aTransferSpeed;
      tmpTransferBlobFile.TransferStep:=trsReceiveParaCompleteDownload;
      Result:=InternalSetTransferResult(tmpTransferBlobFile, srsCompleteDownload, True);//InternalTransferComplete(tmpTransferBlobFile, InternalSetCompleteEndDownload(tmpTransferBlobFile.IdBase, tmpTransferBlobFile.IdLocal, tmpTransferBlobFile.TransferedSize, tmpTransferBlobFile.TransferErrorCount, tmpTransferSpeed), False);
      //..
      tmpTransferProcessEvents:=tmpTransferBlobFile.TransferProcessEvents;
      Inherited InternalITAddTransferDownload(tmpTransferBlobFile, tmpTransferBlobFile.CallerActionFirst, tmpTransferBlobFile.ConnectionName, tmpTransferBlobFile.IdBase, tmpTransferBlobFile.TransferAuto, tmpTransferBlobFile.TransferProcessToSender, tmpTransferBlobFile.TransferFrom, @tmpTransferProcessEvents, False{aCheckLocalAccessible}, aSenderTransferName, tmpTransferBlobFile.TableBfDate, nil);
    Except
      On e:exception do begin
        e.Message:='ITReceiveEndDownloadBlobfile: '+e.message;
        InternalSetTransferError(tmpTransferBlobFile, aSenderTransferName, e.message, E.HelpContext, True);//InternalTransferError(tmpTransferBlobFile, aSenderTransferName, e.message, E.HelpContext, True);
        raise;
      end;
    End;
  finally
    GL_DataCase.ITFreeLock(csllTransfer+IntToStr(tmpTransferBlobFile.IdBase), tmpTransferBlobFile.LockOwner);
  end;
end;

Function TTransferClientBlobfiles.ITReceiveErrorParaDownloadBlobfile(Const aSenderTransferName, aErrorMessage:AnsiString; aHelpContext:Integer; aCanceled:Boolean; aTransferedSize:Cardinal; aTransferErrorCount:Integer; aTransferSpeed:double):Boolean{worked};
  Var tmpTransferBlobFile:ITransferBlobFile;
begin
  //ErrorCount
  If aSenderTransferName='' Then Raise Exception.CreateFmtHelp(cserInvalidTransferName, [aSenderTransferName], cnerInvalidTransferName);
  tmpTransferBlobFile:=InternalTransferNameToITransferBlobFile(aSenderTransferName, vvmView, True);
  GL_DataCase.ITSetLockWait(csllTransfer+IntToStr(tmpTransferBlobFile.IdBase), tmpTransferBlobFile.CallerActionFirst.UserName, tmpTransferBlobFile.LockOwner, True, cnTransferSetLockListWait);
  try
    tmpTransferBlobFile.LastAccessTime:=Now;
    Result:=InternalSetTransferError(tmpTransferBlobFile, aSenderTransferName, aErrorMessage, aHelpContext, True);
  finally
    GL_DataCase.ITFreeLock(csllTransfer+IntToStr(tmpTransferBlobFile.IdBase), tmpTransferBlobFile.LockOwner);
  end;
end;


  try//проверить старый блоб
    If aLocalDataDepot.RegistryDepot.Registry.OpenKey(InternalGetRegistryDepotCacheRegkey+IntToStr(aTransferBlobFile.IdBase), False) Then begin//Похоже такой блоб уже существует
      tmpOldFileLocation:=InternalGetCachePath+aLocalDataDepot.RegistryDepot.Registry.ReadString('Path');
      If (tmpOldFileLocation<>'')And(tmpOldFileLocation[Length(tmpOldFileLocation)]<>'\') Then tmpOldFileLocation:=tmpOldFileLocation+'\';
      tmpOldFileLocation:=tmpOldFileLocation+IntToStr(aTransferBlobFile.IdBase)+'_'+ aLocalDataDepot.RegistryDepot.Registry.ReadString('Filename');
      Deletefile(tmpOldFileLocation);
    end;
  except {Warning} end;

end.
