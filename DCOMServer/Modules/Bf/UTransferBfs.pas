unit UTransferBfs;
  Модуль нормальный, но технология устарела. см. TransferDoc/TransferDocs/TransferDocManage/TransferBf
{$Define CallerNameNoWork}
interface
  uses UTrayInterface, UTransferBfsTypes, UVarsetTypes, UBfTypes, Windows, UTransferBfTypes, UPackPDPlacesTypes, UCallerTypes,
       UPackPDTypes, UPackTypes, UADMTypes, UTrayTypes, UAppCacheDirTypes, USyncTypes, UAppMessageTypes, UEPointPropertiesTypes,
       UThreadsPoolTypes, UUniqueStrUtils;
type
  TVarsetViewMode=(vvmView, vvmPop);
  TInternalCancelMode=(icmIsTerminate, icmToDoOnResponder, icmSendNotificationForCaller);
  //Возможные вариантиы: icmCancelResponder, icmCanceledForResponder, icmTerminateResponder, icmTerminatedForResponder(TInternalCancelMode=(icmCancelResponder, icmCanceledForResponder, icmTerminateResponder, icmTerminatedForResponder))
  //Нормализовал тип до вида - icmIsTerminate, icmToDoOnResponder, icmSendNotificationForCaller.
  //Если icmIsTerminate установлен, то это ITTerminate, в противном случае это ITCancel.
  //Если icmToDoOnResponder установлен, то для ITTerminate на Responder-а отправляется tskADMCancel/tskADMTerminate
  //Если icmSendNotificationForCaller установлен, то для ITTerminate на Responder-а отправляется tskADMCanceled/tskADMTerminated
  TInternalCancelModes=set of TInternalCancelMode;
  TTransferBfs=class(TTrayInterface, ITransferBfs)
  protected
    FOpenBfs:IVarset;
    FSync:ISync;
    FAppCacheDir:IAppCacheDir;
    FThreadsPool:IThreadsPool;
    FEPointProperties:IEPointProperties;
    FCacheDirBf:AnsiString;
  protected
    function InternalGetISync:ISync;virtual;
    function InternalGetIAppCacheDir:IAppCacheDir;virtual;
    function InternalGetIEPointProperties:IEPointProperties;virtual;
    function InternalGetIThreadsPool:IThreadsPool;virtual;
  protected
    procedure InternalInitGUIDList;override;
    function InternalGetInitGUIDCount:cardinal;override;
    procedure InternalStart;override;
    procedure InternalStop;override;
    procedure InternalFinal;override;
  protected
    procedure InternalCloseAllBfs;virtual;
    function InternalGetBfFileinfo(aFileHandle:THandle; Out aBfFileinfo:TBfFileinfo; aRaise:boolean=true):boolean;virtual;
    function InternalSetBfFileinfo(aTransferBf:ITransferBf; aRaise:boolean=true):boolean;virtual;
    function InternalBfIdToTableBfInfo(const aBfName:AnsiString; var aUserInterface:IUnknown; Out aTableBfInfo:TTableBfInfo):boolean;virtual;abstract;
    function InternalCreateSessionStrId(const aBfName:AnsiString):AnsiString;virtual;
    function InternalReadBf(aTransferBf:ITransferBf; var aBfTransfer:TBfTransfer; Out aData:Variant):boolean{Complete};virtual;
    function InternalWriteBf(aTransferBf:ITransferBf; aBfTransfer:TBfTransfer; const aData:Variant):boolean;virtual;
    function InternalRecalcChecksum(aFileHandle:THandle; aToPos:Cardinal):Integer;virtual;
    function InternalTableUpdateChecksum(const aBfName:AnsiString; aFileHandle:THandle; aChecksumDate:TDateTime; var aUserInterface:IUnknown):Integer;virtual;abstract;
    function InternalBuffToChecksum(aPointer:Pointer; aCount:Cardinal):Integer;virtual;
    procedure InternalClearTableBfInfo(var aTableBfInfo:TTableBfInfo);virtual;
    function InternalDeleteTbfInfo(const aBfName:AnsiString; var aUserInterface:IUnknown):boolean;virtual;abstract;
    procedure InternalInsertTableBfInfoAtBegin(var aUserInterface:IUnknown; aTransferBf:ITransferBf);virtual;abstract;
    procedure InternalUpdateTableBfInfoAtBegin(var aUserInterface:IUnknown; aTransferBf:ITransferBf);virtual;abstract;
    procedure InternalUpdateTableBfInfoAtProcess(var aUserInterface:IUnknown; aTransferBf:ITransferBf);virtual;abstract;
    procedure InternalUpdateTableBfInfoAtComplete(var aUserInterface:IUnknown; aTransferBf:ITransferBf);virtual;abstract;
    procedure InternalUpdateTableBfInfo(const aBfName:AnsiString; const aNewPath, aNewFileName:AnsiString; var aUserInterface:IUnknown);virtual;abstract;
    procedure InternalReceiveSendBeginDownload(aTransferBf:ITransferBf; aWaitSendTime:Cardinal);virtual;
    procedure InternalReceiveSendBeginDownloadWithCancelResp(aTransferBf:ITransferBf; aWaitSendTime:Cardinal);virtual;
    procedure InternalReceiveSendDownload(aTransferBf:ITransferBf; aWaitSendTime:Cardinal);virtual;
    procedure InternalReceiveSendEndDownload(aTransferBf:ITransferBf);virtual;
    function InternalTransferNameToITransferBf(const aTransferName:AnsiString; aView:TVarsetViewMode; aRaise:boolean=True):ITransferBf;virtual;
    function InternalTransferModeAndBfNameToITransferBf(const aBfName:AnsiString; aTransferMode:TTransferMode; aRaise:boolean{=True}; aTransfreName:PAnsiString):ITransferBf;virtual;
    function InternalResetAllDownloadOfBfName(const aBfName:AnsiString):Integer;virtual;
    //..
    function InternalGetCachePathBf:AnsiString;virtual;
    //Установка результата перекачки
    procedure InternalAddTransferError(aTransferBf:ITransferBf; const aErrorMessage:AnsiString; aHelpContext:Integer);virtual;
    function InternalSetTransferError(aTransferBf:ITransferBf{; aCallerAction:ICallerAction}; const aTransferName:AnsiString; const aErrorMessage:AnsiString; aHelpContext:Integer; aCancel:boolean; aRaise:boolean; aPCanceled:Pboolean):boolean;virtual;
    function InternalSetTransferResult(aTransferBf:ITransferBf; aSetResultStatus:TSetResultStatus; aRaise:boolean):boolean;virtual;
    function InternalToSetResultVariant(aSetResultStatus:TSetResultStatus; aTransferBf:ITransferBf):variant;virtual;
    //Событие(пакетное) перекачки
    procedure InternalSetTransferResultSendPack(const aConnectionName:AnsiString; aCallerAction:ICallerAction; const aResult:Variant);virtual;
    //События(адресные) перекачки
    //function InternalSetTransferResultAddEvents(aOnAddTransfer:TAddTransferEvent; aUserData:Pointer; const aBfName:AnsiString{; {aTransferFrom:TTransferFrom;} {const {aOldTransferName, }{aNewTransferName:AnsiString}):boolean;virtual;
    function InternalSetTransferResultBeginEvents(aOnBeginTransfer:TBeginTransferEvent; aUserData:Pointer; aTransferBf:ITransferBf; const aBfName:AnsiString; {aTransferFrom:TTransferFrom;} aTotalSize:Cardinal):boolean;virtual;
    function InternalSetTransferResultProcessEvents(aOnProcessTransfer:TProcessTransferEvent; aUserData:Pointer; aTransferBf:ITransferBf; const aBfName:AnsiString; {aTransferFrom:TTransferFrom;} aTransferedSize:Cardinal; aTransferErrorCount:Integer; aTransferSpeed:double{; aPercent:Word}):boolean;virtual;
    function InternalSetTransferResultCompleteEvents(aOnCompleteTransfer:TCompleteTransferEvent; aUserData:Pointer; aTransferBf:ITransferBf; const aBfName:AnsiString; {aTransferFrom:TTransferFrom;} {aTransferedSize:Cardinal; }aTransferErrorCount:Integer; aTransferSpeed:double; const aBfLocation, aBfCommentary:AnsiString):boolean;virtual;
    function InternalSetTransferResultErrorEvents(aOnErrorTransfer:TErrorTransferEvent; aUserData:Pointer; aTransferBf:ITransferBf; const aBfName:AnsiString; {aTransferFrom:TTransferFrom;} const aMessage:AnsiString; aHelpContext:Integer; aCanceled:boolean; {aTransferedSize:Cardinal; }aTransferErrorCount:Integer{; aTransferSpeed:double}):boolean;virtual;
    function InternalViewNextTransferBfOfIntIndex(var aIntIndex:Integer):ITransferBf;virtual;
    function InternalTransferCancel(const aTransferName:AnsiString; aInternalCancelModes:TInternalCancelModes; const aTerminatorSysName:AnsiString):boolean;virtual;
    procedure InternalTransferCancelSendNotificationForCaller(aTransferBf:ITransferBf; aCallerAction:ICallerAction; aInternalCancelModes:TInternalCancelModes; const aTerminatorSysName:AnsiString);virtual;
    function InternalResponderTransferCancel(aTransferBf:ITransferBf; aInternalCancelModes:TInternalCancelModes):boolean;virtual;
    procedure InternalBfLocalUseEvents(aCallerAction:ICallerAction; const aBfName:AnsiString; const aInfo:TTableBfInfo; const aIfExistsUseEvents:TUseTransferEvents; const aConnectionName:AnsiString; aUserInterface:IUnknown);virtual;
    function InternalBfLocalExists(aCallerAction:ICallerAction; const aBfName:AnsiString; {Out}aPInfo:PTableBfInfo; aIfExistsUseEvents:PUseTransferEvents; const aConnectionName:AnsiString; aUserInterface:IUnknown):boolean;virtual;
    procedure InternalSendPackPD(const aConnectionName:AnsiString; aPackPD:IPackPD; aCallerAction:ICallerAction);virtual;
    procedure InternalSendPackPDSleep(const aConnectionName:AnsiString; aPackPD:IPackPD; aCallerAction:ICallerAction; aSleepTime:Integer);virtual;
    function InternalTransferInfoToStr(aTransferBf:ITransferBf; aShowErrorCount:boolean):AnsiString;virtual;
    procedure InternalResponderNameToPlaces(const aConnectionName:AnsiString; const aResponderName:AnsiString; aPlaces:IPackPDPlaces);virtual;abstract;
    function InternalCheckResponderNameForDownload(const aResponderName, aConnectionName:AnsiString):AnsiString;virtual;abstract;
    function InternalTerminateAllTransferWithBfName(const aBfName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString):boolean;virtual;
    function InternalExistsTransferWithBfName(const aBfName:AnsiString):boolean;virtual;
  public
    constructor Create;
    destructor Destroy;override;
    procedure ITCheckTransferProcess;virtual;
    //..
  protected
    function InternalITAddTransferDownload(aTransferBf:ITransferBf;{для ParaDownload} const aBfName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString; aPTransferParam:PTransferParam; aPTransferProcessEvents:PTransferProcessEvents):AnsiString;virtual;
  public
    function ITAddTransferDownload(const aBfName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString; aPTransferParam:PTransferParam; aPTransferProcessEvents:PTransferProcessEvents):AnsiString;virtual;
    function ITTransferCancel(const aTransferName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString; aCancelResponder:boolean):boolean;virtual;
    function ITTransferTerminate(const aTransferName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString):boolean;virtual;
    function ITTransferTerminateByBfName(const aBfName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString):Boolean;virtual;
    function ITBfLocalExists(const aBfName:AnsiString; aCallerAction:ICallerAction; {Out}aPInfo:PTableBfInfo; aIfExistsUseEvents:PUseTransferEvents; const aConnectionName:AnsiString):boolean;virtual;
    function ITBfLocalDelete(const aBfName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString):boolean;virtual;
    function ITBeginDownload(const aBfName:AnsiString; aCallerAction:ICallerAction; out aTBfInfoBeginDownload:TTBfInfoBeginDownload):AnsiString{TransferName};virtual;
    procedure ITDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString; aSequenceNumber:Cardinal; var aTransfer:TBfTransfer; Out aData:Variant);virtual;
    procedure ITEndDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString);virtual;
    procedure ITReceiveBeginDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString; const aResponderTransferName:AnsiString; const aTBfInfoBeginDownload:TTBfInfoBeginDownload);virtual;
    procedure ITReceiveDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString; aSequenceNumber:Cardinal; aTransfer:TBfTransfer; const aData:Variant);virtual;
    procedure ITReceiveErrorBeginDownload(aCallerAction:ICallerAction; const aTransferName, aErrorMessage:AnsiString; aHelpContext:Integer);virtual;
    procedure ITReceiveErrorDownload(aCallerAction:ICallerAction; const aTransferName, aErrorMessage:AnsiString; aHelpContext:Integer);virtual;
    function ITReceiveTransferCanceled(aCallerAction:ICallerAction; const aTransferName:AnsiString):boolean;virtual;
    function ITReceiveTransferTerminated(aCallerAction:ICallerAction; const aTransferName, aTerminatorSysName:AnsiString):boolean;virtual;
    procedure ITTransportError(aCallerAction:ICallerAction; const aConnectionName:AnsiString; aPack:IPack; const aMessage:AnsiString; aHelpContext:Integer);virtual;
  end;

implementation
  uses UVarset, SysUtils, UFileUtils, {$warnings off}FileCtrl{$warnings on}, UTransferBf, UBfConsts, UTypeUtils, UPackPD,
       UTTaskTypes, UPackCPT, UPackCPTTypes, UTransferConsts, UBfUtils, UErrorConsts, UPackCPR, UPackCPRTypes, UUtils,
       UDateTimeUtils, UPackPDPlaceTypes, UTransferBfsUtils, UTransferBfTaskImpUtils, USecurityUtils, USecurityTypes,
       UTrayConsts{$IFDEF VER140}, variants{$ENDIF}, UServerActionConsts;
constructor TTransferBfs.Create;
begin
  Inherited Create;
  FOpenBfs:=TVarset.Create;
  FOpenBfs.ITConfigIntIndexAssignable:=False;
  FOpenBfs.ITConfigCheckUniqueIntIndex:=False;
  FOpenBfs.ITConfigCheckUniqueStrIndex:=True;
  FOpenBfs.ITConfigNoFoundException:=True;
  FOpenBfs.ITConfigCaseSensitive:=True;
  FOpenBfs.ITConfigMaxCount:=cnTransferBfsMaxCount;
end;

destructor TTransferBfs.Destroy;
begin
  InternalCloseAllBfs;
  FOpenBfs:=nil;
  Inherited Destroy;
end;

procedure TTransferBfs.InternalCloseAllBfs;
begin
  FOpenBfs.ITClear;
end;

function TTransferBfs.InternalGetBfFileinfo(aFileHandle:THandle; Out aBfFileinfo:TBfFileinfo; aRaise:boolean=true):boolean;
  var tmpFileInfo:TByHandleFileInformation;
      tmpLocalFileTime:TFileTime;
      tmpInteger:Integer;
begin
  Result:=fuGetFileInfo(aFileHandle, @tmpFileInfo, aRaise);
  if not Result then Exit;//верно, т.к. Exit может быть если только aRaise=false
  FileTimeToLocalFileTime(tmpFileInfo.ftLastWriteTime, tmpLocalFileTime);
  Result:=FileTimeToDosDateTime(tmpLocalFileTime, LongRec(tmpInteger).Hi, LongRec(tmpInteger).Lo);
  if not Result then begin
    if aRaise then raise exception.create(SysErrorMessage(GetLastError));
    Exit;
  end;
  aBfFileinfo.Date:=FileDateToDateTime(tmpInteger);
  aBfFileinfo.TotalSize:=tmpFileInfo.nFileSizeLow;
end;

function TTransferBfs.InternalGetCachePathBf:AnsiString;
begin
  Result:=FCacheDirBf;//InternalGetIAppCacheDir.CacheDir+csBfCacheSubDir;?
end;

var cnLastSessionStrId:AnsiString='';

function TTransferBfs.InternalCreateSessionStrId(const aBfName:AnsiString):AnsiString;
{  function LocalIdToStr(aId:Integer):AnsiString;
  begin
    if aId=-1 then begin
      Result:='';
    end else begin
      Result:=IntToStr(aId);
    end;
  end;}
begin
  while true do begin
    Result:='Tr'+aBfName+'#'+UniqueStringLow;
    if cnLastSessionStrId<>Result then begin
      cnLastSessionStrId:=Result;
      break;
    end;
  end;
end;

function TTransferBfs.InternalBuffToChecksum(aPointer:Pointer; aCount:Cardinal):Integer;
 type PChecksumArray=^TChecksumArray;
      TChecksumArray=Array[0..$FFFFFF] of byte;
  var tmpI:Integer;
      tmpChecksumArray:PChecksumArray;
begin
  tmpChecksumArray:=PChecksumArray(aPointer);
  Result:=0;
  if aCount<>0 then for tmpI:=0 to (aCount div SizeOf(Result))-1 do Result:=Result Xor PInteger(@tmpChecksumArray^[tmpI*SizeOf(Result)])^;
end;

function TTransferBfs.InternalRecalcChecksum(aFileHandle:THandle; aToPos:Cardinal):Integer;
 Type TChecksumBuff=array[0..4095] of byte;
  var tmpChecksumBuff:TChecksumBuff;
      tmpBytesReaded, tmpBytesToRead:Cardinal;
begin//make the countdown from aToPos.
  Result:=0;
  tmpBytesReaded:=0;
  tmpBytesToRead:=0;
  if SetFilePointer(aFileHandle, 0, nil, FILE_BEGIN)=$FFFFFFFF then raise exception.createHelp(SysErrorMessage(GetLastError), cnerSetFilePointer);
  While true do begin
    if aToPos=0 then break else if aToPos>=SizeOf(tmpChecksumBuff) then tmpBytesToRead:=SizeOf(tmpChecksumBuff) else tmpBytesToRead:=aToPos;
    Dec(aToPos, tmpBytesToRead);
    if not ReadFile(aFileHandle, tmpChecksumBuff, tmpBytesToRead, tmpBytesReaded, nil) then raise exception.createHelp(SysErrorMessage(GetLastError), cnerReadFile);
    Result:=Result Xor InternalBuffToChecksum(@tmpChecksumBuff, tmpBytesReaded);
    if tmpBytesReaded<>tmpBytesToRead{SizeOf(tmpChecksumBuff)} then Break;
  end;
end;

function TTransferBfs.ITBeginDownload(const aBfName:AnsiString; aCallerAction:ICallerAction; Out aTBfInfoBeginDownload:TTBfInfoBeginDownload):AnsiString{TransferName};
  function LocalFromToString(const aSenderPackPD:Variant):AnsiString;
    var ltmpPackPD:IPackPD;
        ltmpIntIndex:Integer;
        ltmpPackPDPlace:IPackPDPlace;
  begin
    ltmpPackPD:=TPackPD.Create;
    try
      ltmpPackPD.AsVariant:=aSenderPackPD;
      ltmpIntIndex:=-1;
      ltmpPackPDPlace:=ltmpPackPD.Places.ViewPrevPackPDPlaceOfIntIndex(ltmpIntIndex);
      case ltmpPackPDPlace.Place of
        pdsEventOnID:Result:='ID'+VarToStr(ltmpPackPDPlace.PlaceData);
        pdsEventOnUser:Result:='US'+VarToStr(ltmpPackPDPlace.PlaceData);
        pdsEventOnBridge:Result:='BR'+VarToStr(ltmpPackPDPlace.PlaceData);
      else
        raise exception.create('Unexpect value of PackPDPlace.Place('+IntToStr(Integer(ltmpPackPDPlace.Place))+').');
      end;
    finally
      ltmpPackPD:=nil;
    end;
  end;
  var tmpTableBfInfo:TTableBfInfo;
      tmpBfFileinfo:TBfFileinfo;
      tmpFileHandle:THandle;
      tmpTransferBf:ITransferBf;
      tmpLockOwner:Integer;
      tmpStartTime:TDateTime;
      tmpUserInterface:IUnknown;
begin
  if not assigned(aCallerAction) then raise exception.create('Calleraction is not assigned.');
  if not assigned(aCallerAction.CallerSenderParams) then raise exception.create('CallerSenderParams is not assigned.');
  tmpStartTime:=Now;
  //Устанавливаю "общественный" лок для download
  if not InternalBfIdToTableBfInfo(aBfName, tmpUserInterface, tmpTableBfInfo){Получаю все данные из таблицы} then begin
    raise exception.createFmtHelp(cserBfNameNotExists, [aBfName], cnerBfNameNotExists);
  end else begin
    if tmpTableBfInfo.Transfering then raise exception.createFmtHelp(cserCantDownloadDuringTransfer, [aBfName], cnerCantDownloadDuringTransfer);
    tmpLockOwner:=InternalGetISync.ITGenerateLockOwner;
    //Устанавли ваю и этот лок, т.к. он позволяет синхронизироваться в этом месте, а далее синхронизация будет выполняться через ITLockWait.
    try
      InternalGetISync.ITSetLockWait(csllTransferDownloadServer+aBfName+LocalFromToString(aCallerAction.CallerSenderParams.SenderPackPD), aCallerAction{.UserName}, tmpLockOwner, True, cnTransferLockWait, true);
    except on e:exception do begin
      e.message:=e.message+': '+Format(cserUnableSetLock, [aBfName]);
      e.HelpContext:=cnerUnableSetLock;
      raise;
    end;end;
    try
      tmpTransferBf:=TTransferBf.Create;//Создаю объект для хранения сведений о перекачке
      tmpTransferBf.LockOwner:=tmpLockOwner;
      tmpTransferBf.CachePath:=InternalGetCachePathBf;
      tmpTransferBf.CallerActionAdd(aCallerAction, False);
      tmpTransferBf.BfName:=aBfName;
      tmpTransferBf.TableBfDir:=tmpTableBfInfo.Path;
      tmpTransferBf.TableBfName:=tmpTableBfInfo.Filename;
      tmpTransferBf.TableBfDate:=tmpTableBfInfo.ChecksumDate;
      tmpTransferBf.TableBfChecksum:=tmpTableBfInfo.Checksum;
      tmpTransferBf.TableBfCommentary:=tmpTableBfInfo.Commentary;
      tmpTransferBf.BfType:=tmpTableBfInfo.BfType;
      tmpTransferBf.TransferPos:=tmpTableBfInfo.TransferPos;
      tmpTransferBf.TransferChecksum:=tmpTableBfInfo.TransferChecksum;
      tmpTransferBf.TransferSchedule:=tmpTableBfInfo.TransferSchedule;
      tmpTransferBf.TransferResponder:=tmpTableBfInfo.TransferResponder;
      tmpTransferBf.TransferDirection:=tmpTableBfInfo.TransferDirection;
      tmpTransferBf.Transfering:=tmpTableBfInfo.Transfering;
      //..
      tmpFileHandle:=CreateFile(PChar(tmpTransferBf.RealBfLocation), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
      if (tmpFileHandle=0)Or(tmpFileHandle=$FFFFFFFF) then raise exception.createHelp(SysErrorMessage(GetLastError)+'('+tmpTransferBf.RealBfLocation+').', cnerCreateFile);
      try
        InternalGetBfFileinfo(tmpFileHandle, tmpBfFileinfo, True{Raise});//Беру информацию офайле
        if (tmpTableBfInfo.ChecksumDate=0)Or(tmpTableBfInfo.ChecksumDate<>tmpBfFileinfo.Date) then begin
          //Расчитать контрольную сумму если ее нет или она устарела
          tmpTransferBf.TableBfChecksum:=InternalTableUpdateChecksum(aBfName, tmpFileHandle, tmpBfFileinfo.Date, tmpUserInterface);
          tmpTransferBf.TableBfDate:=tmpBfFileinfo.Date;
        end;
        tmpTransferBf.FileHandle:=tmpFileHandle;//Сохраняю Handle
        tmpFileHandle:=0;
      except
        if tmpFileHandle<>0 then begin
          CloseHandle(tmpFileHandle);//В случае ошибки разбираю Handle
        end;
        raise;
      end;
      tmpTransferBf.FileTotalSize:=tmpBfFileinfo.TotalSize;//Сохраняю размер файла
      tmpTransferBf.TransferMode:=trmDownload;//Устанавливаю направление перекачки
      tmpTransferBf.TransferStep:=trsTransferResponder;
      tmpTransferBf.BeginTime:=tmpStartTime;//Сохраняю время начала действий по перекачке.
      tmpTransferBf.LastSessionBeginTime:=tmpStartTime;//Сохраняю время начала действий в последней сесси - тут этот параметр не важен, он важен клиентской части, где возможна ReBeginDownload.
      tmpTransferBf.LastAccessTime:=Now;//Сохраняю время последнего обращения
      //Out
      aTBfInfoBeginDownload.Path:=tmpTransferBf.TableBfDir;
      aTBfInfoBeginDownload.Filename:=tmpTransferBf.TableBfName;
      aTBfInfoBeginDownload.Checksum:=tmpTransferBf.TableBfChecksum;
      aTBfInfoBeginDownload.ChecksumDate:=tmpTransferBf.TableBfDate;
      aTBfInfoBeginDownload.BfType:=tmpTransferBf.BfType;
      aTBfInfoBeginDownload.TransferSchedule:=tmpTransferBf.TransferSchedule;
      aTBfInfoBeginDownload.TotalSize:=tmpTransferBf.FileTotalSize;
      aTBfInfoBeginDownload.Commentary:=tmpTransferBf.TableBfCommentary;
      //..
      Result:=InternalCreateSessionStrId(aBfName);//Генерирую унакальную, короткую строку.
      FOpenBfs.ITPushVOfStrIndex(Result, tmpTransferBf);//Добавляю новую перекачку в список.
    except//Вообщето это перестраховка, т.к. tmpTransferBf:=nil чистик лок.
      InternalGetISync.ITClearLockOwner(tmpLockOwner);
      tmpTransferBf:=nil;
      raise;
    end;
    tmpTransferBf.Active:=True;//Активизирую
    tmpTransferBf:=nil;
    //tmpIVarsetData:=TVarsetData.Create;//Создаю объект для работы с varset.
    //tmpIVarsetData.ITData:=tmpTransferBf;//Указываю хранимый объект
    //tmpTransferBf:=nil;//Разбираю уже не нужную ссылку на объект.
    //Result:=InternalCreateSessionStrId(aBfName);//Генерирую унакальную, короткую строку.
    //tmpIVarsetData.ITStrIndex:=Result;//Указываю StrIndex, который также используется как Str-Id этой перекачки(PDID для пакетов в асинхронном режиме).
    //FOpenBfs.ITPush(tmpIVarsetData);//Добавляю новую перекачку в список.
    //tmpIVarsetData:=nil;
  end;
  aCallerAction.ITMessAdd(Now, tmpStartTime, 'BgDn', 'Add download(server) '''+Result+'''/#'+aBfName, mecTransfer, mesInformation);
end;

procedure TTransferBfs.ITDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString; aSequenceNumber:Cardinal; var aTransfer:TBfTransfer; Out aData:Variant);
  var tmpTransferBf:ITransferBf;
      tmpStartTime:TDateTime;
begin
  // Серверная часть download-перекачки совершенно простая, и не имеет в себе сложных алгоритмов. Два наиболее
  //сложных алгоритма раходятся в ITAddDownload и в ITReceiveBeginDownload. В них перекачка разбирается, в какой
  //файл ей качаться и если докачка, то пригоден ли имеющийся файл(Checksum, Size, Path, ..). Процедура же ITDownload
  //по сути только выдает запрашиваемые фрагменты Bf. И самое сложное в ней это наличие проверки SequenceNumber.
  //Result:=false;//от варнингов
  try
    //If aTransferName='' then raise exception.createFmtHelp(cserInvalidTransferName, [aTransferName], cnerInvalidTransferName);
    tmpStartTime:=Now;
    tmpTransferBf:=InternalTransferNameToITransferBf(aTransferName, vvmView, True);
    tmpTransferBf.ITSetTransferLockWait;
    try
      tmpTransferBf.ITLockWait(cnTransferLockWait);
      try
        //Проверяю права. Т.к. пришол запрос на следующию порцию, я должен проверить можно ли дать ответ.
        //Я должен сравнить aCallerAction(который пришел) и tmpTransferBf.CallerActionFirst(считается преоритетным Caller-ом).
        //В этом сравнении роли не важны, т.к. они могут меняться(Add/Del), а вот имя пользователя не меняется и его то я сравню.
        try
          CompareSecurity(tmpTransferBf.CallerActionFirst.CallerSecurityContext, aCallerAction.CallerSecurityContext, [eqlUserName], true{aRaise});
        except on e:exception do begin
          e.HelpContext:=cnerAccessDenied;
          e.message:=Format(cserAccessDenied, [e.message]);
          raise;
        end;end;
        if not tmpTransferBf.Active then raise exception.createHelp(cserTransferIsCanceled, cnerTransferIsCanceled);
        if tmpTransferBf.TransferMode<>trmDownload then raise exception.createHelp(cserWrongModeOfTransfer, cnerWrongModeOfTransfer);
        if tmpTransferBf.TransferStep<>trsTransferResponder then raise exception.createHelp(cserWrongStepOfTransfer, cnerWrongStepOfTransfer);
        try
          if tmpTransferBf.SequenceNumber>aSequenceNumber then raise exception.createFmtHelp(cserPastSequenceNumber, [tmpTransferBf.SequenceNumber, aSequenceNumber], cnerPastSequenceNumber);
          tmpTransferBf.LastAccessTime:=Now;
          InternalReadBf(tmpTransferBf, aTransfer, aData);
          tmpTransferBf.SequenceNumber:=aSequenceNumber;
          tmpTransferBf.CallerActionFirst.ITMessAdd(now, tmpStartTime, 'DnBf', ''''+aTransferName+'''/#'+tmpTransferBf.BfName+'('+InternalTransferInfoToStr(tmpTransferBf, False)+' Sn='+IntToStr(aSequenceNumber)+').', mecTransfer, mesInformation);
        except on e:exception do begin 
          InternalAddTransferError(tmpTransferBf, e.message, e.HelpContext);//Записываю текст ошибки в TransferErrorLastMessage, иувеличиваю счетчик
        end;end;
      finally
        tmpTransferBf.ITUnlock;
      end;
    finally
      tmpTransferBf.ITFreeTransferLock;
    end;
  except on e:exception do begin e.message:='DnBf: '+e.message; raise; end;end;
end;

procedure TTransferBfs.ITEndDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString);
  var tmpTransferBf:ITransferBf;
begin
  try
    if aTransferName='' then raise exception.createFmtHelp(cserInvalidTransferName, [aTransferName], cnerInvalidTransferName);
    tmpTransferBf:=InternalTransferNameToITransferBf(aTransferName, vvmView, True);
    tmpTransferBf.ITSetTransferLockWait;
    try
      tmpTransferBf.ITLockWait(cnTransferLockWait);
      try
        try//Проверяю права.
          CompareSecurity(tmpTransferBf.CallerActionFirst.CallerSecurityContext, aCallerAction.CallerSecurityContext, [eqlUserName], true{aRaise});
        except on e:exception do begin
          e.HelpContext:=cnerAccessDenied;
          e.message:=Format(cserAccessDenied, [e.message]);
          raise;
        end;end;
        InternalTransferNameToITransferBf(aTransferName, vvmPop, True);//Удаляю из списка доступных перекачек
        tmpTransferBf.Active:=False{True};//Ставлю что это не активная(не действительная) перекачка
        //Все локи разберуться при уничтожении объекта, по этому напрямую локи не чищу, они почистятся сами в tmpTransferBf:=nil;
        tmpTransferBf.CallerActionFirst.ITMessAdd(Now, tmpTransferBf.BeginTime, 'EnDn', ''''+aTransferName+'''/#'+tmpTransferBf.BfName+' is complete. TotalSize='+IntToStr(tmpTransferBf.FileTotalSize)+' '+InternalTransferInfoToStr(tmpTransferBf, True), mecTransfer, mesInformation);
      finally
        tmpTransferBf.ITUnlock;
      end;
   finally
     tmpTransferBf.ITFreeTransferLock;
     tmpTransferBf:=nil;
   end;
  except on e:exception do begin e.message:='EndDn: '+e.message;raise;end;end;
end;

//function TTransferBfs.ITBeginUploadBf(aCallerAction:ICallerAction; const aTransferName:AnsiString; aInfo:TBfInfo):AnsiString{UploadBfID};
//begin
  //InternalBeginUploadBf(nil, aCallerAction, aTransferName, @Result, True{CreateFile}, aInfo, trmUpload, trsTransferResponder{, False{ReceiveUpload});
//end;

{procedure TTransferBfs.InternalUploadBf(aTransferBf:ITransferBf; aTransfer:TBfTransfer; const aData:Variant; aPComplete:Pboolean; aReceiveDownload:boolean=False);
  var tmpComplete:boolean;
begin
  if not assigned(aTransferBf) then raise exception.create('TransferBf not assigned.');
  aTransferBf.LastAccessTime:=Now;
  tmpComplete:=InternalWriteBf(aTransferBf, aTransfer, aData);
  if assigned(aPComplete) then aPComplete^:=tmpComplete;
end;}

//function TTransferBfs.ITUploadBf(aCallerAction:ICallerAction; const aTransferName:AnsiString; aSequenceNumber:Cardinal; aTransfer:TBfTransfer; const aData:Variant):boolean;
//begin
//    result:=false;
(*  try
    //??aSequenceNumber:Cardinal;
    InternalUploadBf(InternalTransferNameToITransferBf(aTransferName, vvmView, True), aTransfer, aData, @Result, False{aReceiveUpload});
  except
    on e:exception do begin
      e.message:='ITUploadBf: '+e.message;
      raise;
    end;
  end;*)
//end;

function TTransferBfs.InternalSetBfFileinfo(aTransferBf:ITransferBf; aRaise:boolean=True):boolean;
  var tmpRes:Integer;
      tmpBytesWrite:Cardinal;
begin
  if not assigned(aTransferBf) then raise exception.create('aTransferBf not assigned.');
  tmpRes:=FileSetDate(aTransferBf.FileHandle, DateTimeToFileDate(aTransferBf.TableBfDate));//Ставлю время
  Result:=tmpRes=0;
  if not Result then begin
    if aRaise then raise exception.createHelp(SysErrorMessage(tmpRes), cnerFileSetDate);
    Exit;
  end;
  Result:=SetFilePointer(aTransferBf.FileHandle, aTransferBf.FileTotalSize-1, nil, FILE_BEGIN)<>$FFFFFFFF;//устанавливаю файл на позицию
  if not Result then begin
    if aRaise then raise exception.createHelp(SysErrorMessage(tmpRes), cnerSetFilePointer);
    Exit;
  end;
  tmpRes:=0;
  Result:=WriteFile(aTransferBf.FileHandle, tmpRes, 1, tmpBytesWrite, nil);
  if (Not Result)And(aRaise) then raise exception.createHelp(SysErrorMessage(GetLastError), cnerWriteFile);
end;

procedure TTransferBfs.InternalClearTableBfInfo(var aTableBfInfo:TTableBfInfo);
begin
  aTableBfInfo.Path:='';
  aTableBfInfo.Filename:='';
  aTableBfInfo.Checksum:=0;
  aTableBfInfo.ChecksumDate:=0;
  aTableBfInfo.BfType:=0;
  aTableBfInfo.Transfering:=False;
  aTableBfInfo.TransferPos:=0;
  aTableBfInfo.TransferChecksum:=0;
  aTableBfInfo.TransferSchedule:='';
  //aTableBfInfo.TransferedDate:=0;
  aTableBfInfo.TransferResponder:='';
  aTableBfInfo.TransferDirection:=trdDownloadClient;
  aTableBfInfo.Commentary:='';
end;

function TTransferBfs.InternalITAddTransferDownload(aTransferBf:ITransferBf;{для ParaDownload} const aBfName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString; aPTransferParam:PTransferParam{=nil}; aPTransferProcessEvents:PTransferProcessEvents{=nil}):AnsiString{TransferName};
  function LocalTransferParam:PTransferParam;
  begin
    if assigned(aPTransferParam) then Result:=aPTransferParam else Result:=@cnTransferParam;
  end;
  var tmpTransferBf:ITransferBf;
      tmpTransferPackPD:IPackPD;
      tmpLockOwner:Integer;
      tmpTbfInfo:TTableBfInfo;
      tmpUseTransferEvents:TUseTransferEvents;
      tmpBfFileinfo:TBfFileinfo;
      tmpFileHandle:THandle;
      tmpKeepOnDnld, tmpKeepOnDnldWithUsedOwnPath:AnsiString;
      tmpStartTime:TDateTime;
      tmpUseOwnPathAndFileName:boolean;
      tmpLocalTransferParam:PTransferParam;
      tmpString:AnsiString;
      tmpUserInterface:IUnknown;
begin
  try
    if not assigned(aCallerAction) then raise exception.create('CallerAction is not assigned.');
    tmpStartTime:=Now;
    if assigned(aTransferBf) then tmpLockOwner:=aTransferBf.LockOwner else tmpLockOwner:=InternalGetISync.ITGenerateLockOwner;//Ставлю приватный лок, что бы не качался один файл несколько раз.
    //  Для синхронизации в этом месте, оставляю такой лок. Последующая синхронизация будет осуществляться через
    //tmpTransferBf.ITLockWait(cnTransferLockWait{7сек}).
    InternalGetISync.ITSetLockWait(csllTransfer+aBfName, aCallerAction{.UserName}, tmpLockOwner, True, cnTransferLockWait, true);
    try
      FillChar(tmpUseTransferEvents, SizeOf(tmpUseTransferEvents), 0);
      tmpLocalTransferParam:=LocalTransferParam;
      tmpUseTransferEvents.tpToSender:=tmpLocalTransferParam^.TransferProcessToSender;
      if assigned(aPTransferProcessEvents) then begin
        tmpUseTransferEvents.UserData:=aPTransferProcessEvents^.UserData;
        tmpUseTransferEvents.OnCompleteTransfer:=aPTransferProcessEvents^.OnCompleteTransfer;
      end;//Проверка на локальной машине.
      if (InternalBfLocalExists(aCallerAction, aBfName, @tmpTbfInfo, nil, aConnectionName, tmpUserInterface))and(not tmpTbfInfo.Transfering) then begin
        //Проверяю на соответствие заданного пути для скачивания и имеющегося
        if ((tmpLocalTransferParam^.Path<>'')Or(tmpLocalTransferParam^.FileName<>''))and((AnsiUpperCase(tmpTbfInfo.Path)<>AnsiUpperCase(tmpLocalTransferParam^.Path))Or(AnsiUpperCase(tmpTbfInfo.Filename)<>AnsiUpperCase(tmpLocalTransferParam^.FileName))) then raise exception.createHelp(cserAlreadyUsedWithAnotherPath, cnerAlreadyUsedWithAnotherPath);
        InternalBfLocalUseEvents(aCallerAction, aBfName, tmpTbfInfo, tmpUseTransferEvents, aConnectionName, tmpUserInterface);
        Exit;//Такой блоб уже есть, ничего не делаю. Отработал события и выхожу
      end;
      //Теперь прочитался из таблицы некий tmpTbfInfo.TransferResponder, и пришел др. параметр в tmpLocalTransferParam^.ResponderName
      //можно бы было их сравнить и в случае несоответствия дать Exception, но я сделаю что бы всеравно качала из tmpLocalTransferParam^.ResponderName(как сказали).
      //Так же оставляю и этот, "клиентский" лок. Он полезен в этом месте, т.к. он показывает есть или нет перекачка в данный момент.
      if (not assigned(aTransferBf))and(not InternalGetISync.ITSetLock(csllTransferDownloadClient+aBfName, aCallerAction, tmpLockOwner, false, true)) then begin
        //Bf качается сейчас(др. соединением.)
        tmpTransferBf:=InternalTransferModeAndBfNameToITransferBf(aBfName, trmReceiveDownload, True, @Result);
        //если различные заданные Path&FileName и у скачивающегося, то raise.
        if ((tmpLocalTransferParam^.Path<>'')Or(tmpLocalTransferParam^.FileName<>''))And((AnsiUpperCase(tmpTransferBf.TableBfDir)<>AnsiUpperCase(tmpLocalTransferParam^.Path))Or(AnsiUpperCase(tmpTransferBf.TableBfName)<>AnsiUpperCase(tmpLocalTransferParam^.FileName))) then raise exception.createHelp(cserAlreadyUsedWithAnotherPath, cnerAlreadyUsedWithAnotherPath);
        tmpTransferBf.CallerActionAdd(aCallerAction, false);//Raise exception.create('download for IdBase='+IntToStr(aIdBase)+' already exists.');
        case tmpTransferBf.TransferMode of
          trmReceiveDownload:begin
            case tmpTransferBf.TransferStep of
              trsReceiveDownload:begin
                InternalSetTransferResultSendPack(tmpTransferBf.ConnectionName, aCallerAction, InternalToSetResultVariant(srsBeginDownload, tmpTransferBf));
              end;
            end;
          end;
        end;
      end else begin//Bf не существует(на этой машине) или не докачен
        try//снимаю лок
          tmpFileHandle:=0;
          tmpUseOwnPathAndFileName:=not((tmpLocalTransferParam^.Path='')And(tmpLocalTransferParam^.FileName=''));
          try//чтобы навярника разобрать tmpFileHandle
            if tmpTbfInfo.Transfering then begin//не докачен с того раза, проверяю возможно ли его использовать для дальнейшей докачки.
              tmpKeepOnDnld:=glConvertToTableBfLocation(InternalGetCachePathBf, tmpTbfInfo.Path, tmpTbfInfo.FileName, nil);
              try//открыть, сравнить дату, длину и скаченную контр.сумму если что то не так качать заново
                tmpFileHandle:=CreateFile(PChar(tmpKeepOnDnld), GENERIC_WRITE Or GENERIC_READ, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
                if (tmpFileHandle=0)Or(tmpFileHandle=$FFFFFFFF) then raise exception.createHelp(SysErrorMessage(GetLastError)+'('+tmpKeepOnDnld+').', cnerCreateFile);//теперь tmpFileHandle хороший
                InternalGetBfFileinfo(tmpFileHandle, tmpBfFileinfo, True{Raise});//Беру информацию офайле
                if tmpBfFileinfo.Date<>tmpTbfInfo.ChecksumDate then raise exception.create({cserImpossiblyToKeepOnDownload+}'Different dates(File('+FormatDateTime('ddmmyy hh:nn:ss.zzz', tmpBfFileinfo.Date)+')<>Tbf('+FormatDateTime('ddmmyy hh:nn:ss.zzz', tmpTbfInfo.ChecksumDate)+')).');
                if tmpBfFileinfo.TotalSize<tmpTbfInfo.TransferPos then raise exception.create({cserImpossiblyToKeepOnDownload+}'Invalid value of total size.');
                if tmpTbfInfo.TransferChecksum<>InternalRecalcChecksum(tmpFileHandle, tmpTbfInfo.TransferPos) then raise exception.create({cserImpossiblyToKeepOnDownload+}cserChecksumError);
                //Теперь предварительно уверен что имеющийся недокаченный файл - нормален.
                if (tmpUseOwnPathAndFileName)And((AnsiUpperCase(tmpTbfInfo.Path)<>AnsiUpperCase(tmpLocalTransferParam^.Path))//Задан собственный путь, надо провери где лежит недокаченный файл,
                    Or(AnsiUpperCase(tmpTbfInfo.Filename)<>AnsiUpperCase(tmpLocalTransferParam^.FileName))) then begin       //и если не там, то перенести его и поправить инфо в таблице/реестре.
                  CloseHandle(tmpFileHandle);//Для предстоящих операций переноса, надо отпутить файл.
                  tmpFileHandle:=0;//обнуляю tmpFileHandle, что б на случай ошибки, не выполнять лишний CloseHandle
                  try
                    if glUsedCachePath(tmpLocalTransferParam^.Path) then tmpString:=InternalGetCachePathBf+tmpLocalTransferParam^.Path else tmpString:=tmpLocalTransferParam^.Path;//Получил новый путь
                    if not DirectoryExists(tmpString) then if not ForceDirectories(tmpString) then raise exception.create('Can''t create folder '''+tmpString+'''.');//Проверил существует ли каталог
                    tmpKeepOnDnldWithUsedOwnPath:=tmpString{указанный путь}+tmpLocalTransferParam^.FileName;//Получил новый путь с именем файла
                    if FileExists(tmpKeepOnDnldWithUsedOwnPath) then begin//Если файл существует, застираю его, а сообщение(Warning) пишу в лог.
                      aCallerAction.ITMessAdd(Now, tmpStartTime, 'AdDn', '#'+aBfName+'. File('+tmpKeepOnDnldWithUsedOwnPath+') already exists, and it will be replaced.', mecTransfer, mesWarning);
                    end;
                    InternalUpdateTableBfInfo(aBfName, tmpLocalTransferParam^.Path, tmpLocalTransferParam^.FileName, tmpUserInterface);//Выравниваю Инфо
                    try
                      if not MoveFileEx(PChar(tmpKeepOnDnld), PChar(tmpKeepOnDnldWithUsedOwnPath), MOVEFILE_REPLACE_EXISTING) then raise exception.create(SysErrorMessage(GetLastError));//переношу на новое(указанное) место
                    except//Произошла ошибка при переносе, возвращаю прежние значения в реестре
                      InternalUpdateTableBfInfo(aBfName, tmpTbfInfo.Path, tmpTbfInfo.FileName, tmpUserInterface);
                      raise;
                    end;
                    tmpKeepOnDnld:=tmpKeepOnDnldWithUsedOwnPath;//выравниваю tmpKeepOnDnld, т.е. полный путь к файлу
                    tmpTbfInfo.Path:=tmpLocalTransferParam^.Path;//Ставлю новый путь
                    tmpTbfInfo.FileName:=tmpLocalTransferParam^.FileName;//Ставлю новый FileName
                    //Открываю егоже еще раз, но теперь на новом(указанном) месте
                    tmpFileHandle:=CreateFile(PChar(tmpKeepOnDnld), GENERIC_WRITE Or GENERIC_READ, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
                    if (tmpFileHandle=0)Or(tmpFileHandle=$FFFFFFFF) then raise exception.create(SysErrorMessage(GetLastError)+'('+tmpKeepOnDnld+').');//теперь tmpFileHandle хороший
                  except on e:exception do begin
                    e.message:='MoveFile: '+e.message;
                    raise;
                  end;end;
                end;
              except on e:exception do begin//Impossible to place on the specified path and filename.
                //чищу прежнюю перекачку в таблице/реестре и сам файл на диске
                //aCallerAction.ITMessAdd(Now, tmpStartTime, 'AddDn('+IntToStr(aIdBase)+')', e.message, mecTransfer, mesError);
                InternalDeleteTbfInfo(aBfName, tmpUserInterface);//в таблице/реестре
                InternalClearTableBfInfo(tmpTbfInfo);//ставлю что почищен, т.е. чищу tmpTbfInfo:=0/'';
                if tmpFileHandle<>0 then begin//что бы сработал последующий DeleteFile
                  try CloseHandle(tmpFileHandle);except end;//В случае ошибки разбираю Handle
                  tmpFileHandle:=0;
                end;
                DeleteFile(tmpKeepOnDnld);//сам файл на диске
                aCallerAction.ITMessAdd(Now, tmpStartTime, 'AdDn='+aBfName, Format(cserKeepOnDownloadIsCanceledErrorOccured, [e.message, e.HelpContext]), mecTransfer, mesError);//raise;
                tmpBfFileinfo.TotalSize:=0;//обнуляю, т.к. докачки не будет, в противном случае она имела бы значение размера файла которое сохранилось бы в tmpTransferBf.FileTotalSize.
              end;end;
            end else begin//еще не существует
              tmpFileHandle:=0;
              tmpBfFileinfo.TotalSize:=0;//обнуляю для порядку, т.е. что бы реальные данные соответствовали действительности
            end;
            //Если assigned(aTransferBf) то не создаю новый TransferBf, а назначаю данные в имеющийся, т.е. в него. 
            if assigned(aTransferBf) then tmpTransferBf:=aTransferBf else tmpTransferBf:=TTransferBf.Create;//Создаю объект для хранения сведений о перекачке
            tmpTransferBf.FileHandle:=tmpFileHandle;//Сохраняю Handle
            tmpFileHandle:=0;
          except//чтобы разобрать tmpFileHandle
            if tmpFileHandle<>0 then begin
              try CloseHandle(tmpFileHandle);except end;//В случае ошибки разбираю Handle
              //tmpFileHandle:=0; - закоментировано т.к. далее не используется, в случае изменений возможно раскоментировать.
            end;
            raise;
          end;
          tmpTransferBf.CallerActionAdd(aCallerAction, false);//в нем есть проверка на повторяющиеся CallerAction
          tmpTransferBf.CachePath:=InternalGetCachePathBf;
          tmpTransferBf.BfName:=aBfName;//Сохраняю номер файла в таблице
          tmpTransferBf.BeginTime:=tmpStartTime;//Сохраняю время начала действий по перекачке.
          tmpTransferBf.LastSessionBeginTime:=tmpStartTime;//Сохраняю время начала действий в последней сесси
          tmpTransferBf.TransferSpeed:=0;
          tmpTransferBf.LastAccessTime:=Now;//Сохраняю время последнего обращения
          tmpTransferBf.TransferMode:=trmReceiveDownload;//Устанавливаю направление перекачки
          tmpTransferBf.TransferStep:=trsReceiveBeginDownload;
          tmpTransferBf.FileTotalSize:=tmpBfFileinfo.TotalSize;//Сохраняю размер файла
          tmpTransferBf.LastSessionTransferedSize:=0;//TransferedSize в последней сессии
          //..
          tmpTransferBf.Transfering:=tmpTbfInfo.Transfering;
          tmpTransferBf.TransferPos:=tmpTbfInfo.TransferPos;
          tmpTransferBf.TransferChecksum:=tmpTbfInfo.TransferChecksum;
          //..
          tmpTransferBf.UseOwnPathAndFileName:=tmpUseOwnPathAndFileName;
          tmpTransferBf.TableBfDir:=tmpTbfInfo.Path;
          tmpTransferBf.TableBfName:=tmpTbfInfo.Filename;//Сохраняю имя файла(pict1.gif).
          tmpTransferBf.TableBfDate:=tmpTbfInfo.ChecksumDate;//Сохраняю дату файла
          tmpTransferBf.TableBfChecksum:=tmpTbfInfo.Checksum;
          //Эти значения можно не ставить, т.к. они будут установлены на (точно)актуальные в RcBgDn.
          tmpTransferBf.TableBfCommentary:=tmpTbfInfo.Commentary;//-нет смысла брать, т.к. подтяну новое значение
          tmpTransferBf.BfType:=tmpTbfInfo.BfType;//-нет смысла брать, т.к. подтяну новое значение
          tmpTransferBf.TransferSchedule:=tmpTbfInfo.TransferSchedule;//-нет смысла брать, т.к. подтяну новое значение
          //..
          tmpTransferBf.TransferAuto:=tmpLocalTransferParam^.TransferAuto;
          tmpTransferBf.TransferProcessToSender:=tmpLocalTransferParam^.TransferProcessToSender;    
          tmpTransferBf.TransferResponder:=InternalCheckResponderNameForDownload(tmpLocalTransferParam^.TransferResponder, aConnectionName);//В любом случае качаю как сказано при вызове процедуры.
          tmpTransferBf.ConnectionName:=aConnectionName;
          tmpTransferBf.SequenceNumber:=1;//т.к. после создания 0, и первый цикл Download проверка на SequenceNumber не работает
          if assigned(aPTransferProcessEvents) then tmpTransferBf.TransferProcessEvents:=aPTransferProcessEvents^;
          tmpTransferBf.LockOwner:=tmpLockOwner;
          if assigned(aTransferBf) then begin
            result:=aTransferBf.TransferName;////в ParaDwnl уже сгенерирован TransferName, и тут он просто назначается
          end else begin
            result:=InternalCreateSessionStrId(aBfName);//Генерирую TransferName
          end;
          //..
          tmpTransferPackPD:=TPackPD.Create;
          tmpTransferPackPD.PDID:=Result;
          tmpTransferPackPD.PDOptions:=[pdoWithNotificationOfError]+[pdoNoTransform]+[pdoNoPutOnReSending];
          InternalResponderNameToPlaces(aConnectionName, tmpTransferBf.TransferResponder, tmpTransferPackPD.Places);
          tmpTransferBf.TransferPackPD:=tmpTransferPackPD;
        except//Если ошибка чищу лок
          InternalGetISync.ITFreeLock(csllTransferDownloadClient+aBfName, tmpLockOwner);
          raise;
        end;
        if not assigned(aTransferBf) then begin//в ParaDwnl уже добавлен в список с таким именем.
          FOpenBfs.ITPushVOfStrIndex(Result, tmpTransferBf);
        end;
        tmpTransferBf.Active:=True;//Активизирую
        if tmpTransferBf.Transfering then begin
          aCallerAction.ITMessAdd(Now, tmpStartTime, 'AdDn', 'Keep on download(client) '''+Result+'''/#'+aBfName+'(FromPos='+IntToStr(tmpTransferBf.TransferPos)+' '+InternalTransferInfoToStr(tmpTransferBf, False)+').', mecTransfer, mesInformation);
        end else begin
          aCallerAction.ITMessAdd(Now, tmpStartTime, 'AdDn', 'Add download(client) '''+Result+'''/#'+aBfName+'.', mecTransfer, mesInformation);
        end;
        InternalReceiveSendBeginDownload(tmpTransferBf, 0);
      end;
    finally
      InternalGetISync.ITFreeLock(csllTransfer+aBfName, tmpLockOwner);
    end;
  except on e:exception do begin e.message:='AdDn: '+e.message; raise;end;end;
end;

function TTransferBfs.ITAddTransferDownload(const aBfName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString; aPTransferParam:PTransferParam{=nil}; aPTransferProcessEvents:PTransferProcessEvents{=nil}):AnsiString{ITransferBf};
begin
  Result:=InternalITAddTransferDownload(nil, aBfName, aCallerAction, aConnectionName, aPTransferParam, aPTransferProcessEvents);
end;

function TTransferBfs.InternalTransferModeAndBfNameToITransferBf(const aBfName:AnsiString; aTransferMode:TTransferMode; aRaise:boolean{=True}; aTransfreName:PAnsiString):ITransferBf;
  var tmpIVarsetDataView:IVarsetDataView;
      tmpIntIndex:Integer;
      tmpIUnknown:IUnknown;
begin
  if assigned(aTransfreName) then aTransfreName^:='';
  tmpIntIndex:=-1;
  while true do begin
    tmpIVarsetDataView:=FOpenBfs.ITViewNextGetOfIntIndex(tmpIntIndex);
    if (tmpIntIndex=-1)or(not assigned(tmpIVarsetDataView)) then begin
      Result:=nil;
      if aRaise then raise exception.create('ITr&IdbToTrBf: #'+aBfName+' TransferMode='+IntToStr(Integer(aTransferMode))+' not found.');
      break;
    end;
    tmpIUnknown:=tmpIVarsetDataView.ITData;
    if (Not assigned(tmpIUnknown))Or(tmpIUnknown.QueryInterface(ITransferBf, Result)<>S_OK)Or(Not assigned(Result)) then raise exception.createFmt(cserInternalError, ['Interface ''ITransferBf'' not found.']);
    if (Result.TransferMode=aTransferMode)And(Result.BfName=aBfName)Then begin
      if assigned(aTransfreName) then aTransfreName^:=tmpIVarsetDataView.ITStrIndex;
      break;
    end;  
  end;
  tmpIVarsetDataView:=nil;
  tmpIUnknown:=nil;
end;

function TTransferBfs.InternalTransferNameToITransferBf(const aTransferName:AnsiString; aView:TVarsetViewMode; aRaise:boolean=True):ITransferBf;
  var tmpIVarsetDataView:IVarsetDataView;
      tmpIVarsetData:IVarsetData;
      tmpIUnknown:IUnknown;
begin
  Result:=nil;
  if aTransferName='' then begin
    if aRaise then raise exception.createFmtHelp(cserInvalidTransferName, [aTransferName], cnerInvalidTransferName) else exit;
  end;
  case aView of
    vvmView:tmpIVarsetDataView:=FOpenBfs.ITViewOfStrIndexEx[aTransferName, rasFalse];
    vvmPop:begin
      tmpIVarsetData:=FOpenBfs.ITPopOfStrIndexEx(aTransferName, rasFalse);
      if assigned(tmpIVarsetData) then begin
        tmpIVarsetDataView:=tmpIVarsetData.ITAsIVarsetDataView;
        tmpIVarsetData:=nil;
      end;
    end;
  else
    raise exception.createFmtHelp(cserInternalError, ['Unknown TViewMode('+IntToStr(Integer(aView))+')'], cnerInternalError);
  end;
  if not assigned(tmpIVarsetDataView) then begin
    if aRaise then raise exception.createFmtHelp(cserTransferingBroken, [aTransferName], cnerTransferingBroken) else exit;
  end;
  tmpIUnknown:=tmpIVarsetDataView.ITData;
  if not assigned(tmpIUnknown) then begin
    if aRaise then raise exception.createFmtHelp(cserInternalError, ['tmpIUnknown is not assigned.'], cnerInternalError) else exit;
  end;
  if (tmpIUnknown.QueryInterface(ITransferBf, Result)<>S_OK)Or(Not assigned(Result)) then begin
    if aRaise then raise exception.createFmtHelp(cserInternalError, ['Interface ITransferBf is not found'], cnerInternalError) else begin
      Result:=nil;
      Exit;
    end;
  end;
end;

function TTransferBfs.InternalViewNextTransferBfOfIntIndex(var aIntIndex:Integer):ITransferBf;
  var tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
begin
  tmpIVarsetDataView:=FOpenBfs.ITViewNextGetOfIntIndex(aIntIndex);
  if aIntIndex=-1 then begin
    Result:=nil;
    Exit;
  end;
  tmpIUnknown:=tmpIVarsetDataView.ITData;
  if (Not assigned(tmpIUnknown))Or(tmpIUnknown.QueryInterface(ITransferBf, Result)<>S_OK)Or(Not assigned(Result)) then raise exception.createFmt(cserInternalError, ['Interface ITransferBf is not found']);
end;

function ComparePackPDWithCallerAction(aPackPD:IPackPD; aCallerAction:ICallerAction):boolean;
  var tmpPackPD:IPackPD;
      tmpIntIndex1, tmpIntIndex2:Integer;
      tmpIPackPDPlace1, tmpIPackPDPlace2:IPackPDPlace;
      tmpSt1, tmpSt2:AnsiString;
begin
  tmpPackPD:=TPackPD.Create;
  try
    tmpPackPD.AsVariant:=aCallerAction.CallerSenderParams.SenderPackPD;
    result:=false;
    if aPackPD.Places.CurrNum<>tmpPackPD.Places.CurrNum then exit;//разный currnum
    tmpIntIndex1:=-1;
    tmpIntIndex2:=-1;
    while true do begin
      tmpIPackPDPlace1:=aPackPD.Places.ViewNextPackPDPlaceOfIntIndex(tmpIntIndex1);
      tmpIPackPDPlace2:=tmpPackPD.Places.ViewNextPackPDPlaceOfIntIndex(tmpIntIndex2);
      if (tmpIntIndex1=-1)Or(tmpIntIndex2=-1) then begin
        result:=tmpIntIndex1=tmpIntIndex2{-1=-1};
        break;
      end;
      tmpSt1:=glVarArrayToString(tmpIPackPDPlace1.PlaceData);
      tmpSt2:=glVarArrayToString(tmpIPackPDPlace2.PlaceData);
      if (tmpIPackPDPlace1.Place<>tmpIPackPDPlace2.Place)Or(AnsiUpperCase(tmpSt1)<>AnsiUpperCase(tmpSt2)) then begin
        result:=false;
        break;
      end;
    end;
    tmpIPackPDPlace1:=nil;
    tmpIPackPDPlace2:=nil;
  finally
    tmpPackPD:=nil;
  end;
end;

function TTransferBfs.InternalResponderTransferCancel(aTransferBf:ITransferBf; aInternalCancelModes:TInternalCancelModes):boolean;
  var tmpPackCPT:IPackCPT;
      tmpTPackPDOptions:TPackPDOptions;
begin
  if (assigned(aTransferBf))And(assigned(aTransferBf.TransferPackPD))And(aTransferBf.ResponderTransferName<>'') then begin
    tmpTPackPDOptions:=aTransferBf.TransferPackPD.PDOptions;
    try
      tmpPackCPT:=TPackCPT.Create;
      try
        if icmIsTerminate in aInternalCancelModes then begin//это Terminate
          tmpPackCPT.CPTasks.TaskAdd(tskADMBfTransferTerminate, ParamTransferTerminateToVariant(aTransferBf.ResponderTransferName), {RouteParam}Unassigned, -1);
        end else begin//Это Cancel
          tmpPackCPT.CPTasks.TaskAdd(tskADMBfTransferCancel, ParamTransferCancelToVariant(aTransferBf.ResponderTransferName, False{важный параметр, когда я отменяю Responder-а то он не должен мне отвечать, темболее Cancel-ом}), {RouteParam}Unassigned, -1);
        end;
        aTransferBf.TransferPackPD.DataAsIPack:=tmpPackCPT;
      finally
        tmpPackCPT:=nil;
      end;
      //не надо ответа о успешном выполнении или о ошибке, т.к. tskADMBfTransferCanceled закрывает "сервер"
      aTransferBf.TransferPackPD.PDOptions:=tmpTPackPDOptions+[pdoNoResult{не надо ответа}];
      //Send PD
      InternalSendPackPD(aTransferBf.ConnectionName, aTransferBf.TransferPackPD, aTransferBf.CallerActionFirst);
      aTransferBf.ResponderTransferName:='';//После этой команды(CancelResponder) считаю что Responder-а нет.
      Result:=True;
    finally
      aTransferBf.TransferPackPD.PDOptions:=tmpTPackPDOptions;
    end;  
  end else Result:=False;
  aTransferBf:=nil;
end;

procedure TTransferBfs.InternalTransferCancelSendNotificationForCaller(aTransferBf:ITransferBf; aCallerAction:ICallerAction; aInternalCancelModes:TInternalCancelModes; const aTerminatorSysName:AnsiString);
  var tmpPackPD:IPackPD;
      tmpPackCPR:IPackCPR;
begin
  tmpPackPD:=TPackPD.Create;
  try 
    tmpPackPD.AsVariant:=aCallerAction.CallerSenderParams.SenderPackPD;
    tmpPackCPR:=TPackCPR.Create;
    try
      tmpPackCPR.CPID:=aCallerAction.CallerSenderParams.SenderPackCPID;
      if icmIsTerminate in aInternalCancelModes then begin//это Terminate
        tmpPackCPR.Add(tskADMBfTransferTerminated, ResultTransferTerminatedToVariant(aTerminatorSysName), aCallerAction.CallerSenderParams.SenderRouteParam, -1);
      end else begin//Это Cancel
        tmpPackCPR.Add(tskADMBfTransferCanceled, Unassigned{ResultTransferCanceledToVariant(aTransferName)}, aCallerAction.CallerSenderParams.SenderRouteParam, -1);
      end;             
      tmpPackPD.DataAsIPack:=tmpPackCPR;
      InternalSendPackPD(aTransferBf.ConnectionName, tmpPackPD, aCallerAction);
    finally
      tmpPackCPR:=nil;
    end;
  finally
    tmpPackPD:=nil;
  end;
end;

function TTransferBfs.InternalTransferCancel(const aTransferName:AnsiString; aInternalCancelModes:TInternalCancelModes; const aTerminatorSysName:AnsiString):boolean;
  function localIsWhat:AnsiString; begin
    if icmIsTerminate in aInternalCancelModes then result:='Terminated'{это Terminate} else result:='Canceled'{Это Cancel};
  end;
  var tmpTransferBf:ITransferBf;
      tmpCallerAction:ICallerAction;
      tmpIUnknown:IUnknown;
      tmpIntIndex:Integer;
begin
  tmpTransferBf:=InternalTransferNameToITransferBf(aTransferName, vvmPop, True);//Стираю перекачку из списка
  if icmToDoOnResponder in aInternalCancelModes then InternalResponderTransferCancel(tmpTransferBf, aInternalCancelModes);//Проверяется внутри отправлять или нет
  tmpTransferBf.Active:=False{True};
  //Даю сообщение об отмене перекачки
  try
    tmpTransferBf.CallerActionFirst.ITMessAdd(Now, tmpTransferBf.BeginTime, 'TrfCancel', 'Transfer '''+aTransferName+'''/#'+tmpTransferBf.BfName+' is '+localIsWhat+'('+InternalTransferInfoToStr(tmpTransferBf, true)+').', mecTransfer, mesWarning);
  except end;
  if (tmpTransferBf.CallerActions.ITCount>0)And(icmSendNotificationForCaller in aInternalCancelModes) then begin
    //Есть подписчики, и им шлется CPR что отменена перекачка.
    //Идея такая. У перекачки сервера на Пегасе или на ближнем сервере, могут быть клиенты, которые принимаю данные.
    //Эти самые клиенты регистрируются в списке CallerActions(посредством CallerActionAdd). И они все качают.
    //Для ближнего сервера это особенно характерно. Там, например, много клиентов в магазине хотят видеть картинку.
    //И имеет смысл качать ее единожды. А всем кому интересна информация о такой перекачке, показывать(отправлять события)
    //процесс или упешное завершение или наконец отмену этой перекачки, к примеру Netmenager-ом или dcomadm-ом.
    //С магазином понятно, так моного жалающих следят за конкретной перекачкой, а вот что же на Пегасе(на дальнем сервере)?
    //На пегасе каждая картинка в каждый магазин, может перекачиваться, в какойто момент времени, единожды. По этом случаю даже
    //ставится специальный лок с номером моста(или ASM-Num для клиента). О суда очевидно что на один сервер перекачки(ITransferBf)
    //в общем случае имеется один CallerAction(для Пегаса). Вобщем выглядет примерно так. Но я хочу написать еще одно уточнение.
    //Оно имеет вполне конкретный смысл, но способно окончательно запутать прежнее объяснение, если его не правильно понять.
    //Уточнение: Описанный принцып работы сервера перекачки(ITransferBf на Пегасе) в режиме "перекачка с Пегаса на EMS" идентичен
    //принцыпу работы сервера перекачки(ITransferBf на EMS) в режиме "перекачка с EMS на клиента".
    //                   Pegas
    //                 /      \
    //                 |      |
    //                 V      V
    //            --- EMS1   EMS2 ---
    //          /    / |      |  \   \
    //        /    /   |      |   \   \
    //   Client11 12   13     21  22  23
    //Про TransferMonitor не пишу, потому что его только придумал.
    tmpIntIndex:=-1;
    while true do begin//Извещаю подписчиков, отправляю им Canceled
      tmpIUnknown:=tmpTransferBf.CallerActions.ITViewNextDataGetOfIntIndex(tmpIntIndex);
      if tmpIntIndex=-1 then break;
      if (not assigned(tmpIUnknown))or(tmpIUnknown.QueryInterface(ICallerAction, tmpCallerAction)<>S_OK)or(not assigned(tmpCallerAction)) then raise exception.createFmtHelp(cserInvalidValueOf, ['tmpIUnknown'], cnerInvalidValueOf);
      if (assigned(tmpCallerAction.CallerSenderParams))and(not VarIsEmpty(tmpCallerAction.CallerSenderParams.SenderPackPD)) then begin//Формирую и отправляю пакет для текущего tmpCallerAction.
        InternalTransferCancelSendNotificationForCaller(tmpTransferBf, tmpCallerAction, aInternalCancelModes, aTerminatorSysName);
      end;
    end;
  end;
  //почистить локи
  if tmpTransferBf.LockOwner>0 then InternalGetISync.ITClearLockOwner(tmpTransferBf.LockOwner);
  tmpTransferBf:=nil;
  Result:=True;
end;

function TTransferBfs.ITTransferCancel(const aTransferName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString; aCancelResponder:boolean):boolean;
  function localGetCancelResponder:TInternalCancelModes;begin
    if aCancelResponder then Result:=[icmToDoOnResponder] else Result:=[];
  end;
  var tmpTransferBf:ITransferBf;
{$Ifdef CallerNameNoWork}
      tmpPackPD:IPackPD;
{$endif}
      tmpCallerAction:ICallerAction;
      tmpCancel:boolean;
      tmpIntIndex:Integer;
begin
  if not assigned(aCallerAction) then raise exception.createFmtHelp(cserInvalidValueOf, ['CallerAction'], cnerInvalidValueOf);
  if not assigned(aCallerAction.CallerSenderParams) then raise exception.createFmtHelp(cserInvalidValueOf, ['CallerSenderParams'], cnerInvalidValueOf);
  if varIsEmpty(aCallerAction.CallerSenderParams.SenderPackPD) then raise exception.createFmtHelp(cserInvalidValueOf, ['SenderPackPD'], cnerInvalidValueOf);
  Result:=False;
  tmpTransferBf:=InternalTransferNameToITransferBf(aTransferName, vvmView, False);//Ищу перекачку в списке
  if not assigned(tmpTransferBf) then Exit;//не нашел
  tmpTransferBf.ITSetTransferLockWait;
  try
    tmpTransferBf.ITLockWait(cnTransferLockWait);
    try
      //По возможности не нужно идентифицировать aCallerAction по aCallerAction.CallerSenderParams.SenderPackPD а нужно переделать
      //на идентификацию по aCallerAction.ActionName.
{$Ifdef CallerNameNoWork}
      tmpPackPD:=TPackPD.Create;
      tmpPackPD.AsVariant:=aCallerAction.CallerSenderParams.SenderPackPD;//<< error is not array
{$endif}
      tmpIntIndex:=-1;
      tmpCancel:=False;//от варнингов
      While true do begin//Ищу какой подписчик из списка прислал Cancel
        tmpCallerAction:=tmpTransferBf.CallerActionViewNextGetOfIntIndex(tmpIntIndex);
        if tmpIntIndex=-1 then begin//не нашел
          tmpCancel:=False;//значит кенсел пришел не по адресу, игнорирую его
          break;
        end;
{$Ifdef CallerNameNoWork}
        if ComparePackPDWithCallerAction(tmpPackPD, tmpCallerAction) then begin
{$else}
        if AnsiUpperCase(aCallerAction.ActionName)=AnsiUpperCase(tmpCallerAction.ActionName) then begin только прежде надо что б через пакеты передавалось ActionName.
{$endif}
          if tmpTransferBf.CallerActions.ITCount>1 then begin//есть другие подписчики на перекачку
            //Перекачка не прерывается, но один клиент больше не хочет получать события о ней
            //я его убираю из списка "подписчиков"
            tmpTransferBf.CallerActions.ITClearOfIntIndex(tmpIntIndex);
            tmpCancel:=False;
          end else begin//это был единственный подписчик на перекачку
            tmpCancel:=True;
          end;
          Break;
        end;
      end;
{$Ifdef CallerNameNoWork}
      tmpPackPD:=nil;
{$endif}
      tmpCallerAction:=nil;
      if tmpCancel then Result:=InternalTransferCancel(aTransferName, localGetCancelResponder+[icmSendNotificationForCaller], '');//тут чистятся локи
    finally
      tmpTransferBf.ITUnlock;
    end;
  finally
    tmpTransferBf.ITFreeTransferLock;
    //tmpTransferBf:=nil;
  end;
end;

procedure TTransferBfs.ITReceiveBeginDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString; const aResponderTransferName:AnsiString; const aTBfInfoBeginDownload:TTBfInfoBeginDownload);
  var tmpTransferBf:ITransferBf;
      tmpFileHandle:THandle;
      tmpString, tmpKeepOnDnldWithUsedOwnPath:AnsiString;
      tmpStartTime:TDateTime;
      tmpCanceled:boolean;
      tmpUserInterface:IUnknown;
begin
  if aTransferName='' then raise exception.create('aTransferName is empty.');
  tmpStartTime:=Now;
  tmpTransferBf:=InternalTransferNameToITransferBf(aTransferName, vvmView, True);
  tmpTransferBf.ITSetTransferLockWait;
  try
    tmpTransferBf.ITLockWait(cnTransferLockWait);
    try
      try//Проверяю права.
        CompareSecurity(tmpTransferBf.CallerActionFirst.CallerSecurityContext, aCallerAction.CallerSecurityContext, [eqlUserName], true{aRaise});
      except on e:exception do begin
        e.HelpContext:=cnerAccessDenied;
        e.message:=Format(cserAccessDenied, [e.message]);
        raise;
      end;end;
      //Проверяю соответствие способа и шага перекачки.
      if not tmpTransferBf.Active then raise exception.createHelp(cserTransferIsCanceled, cnerTransferIsCanceled);
      if tmpTransferBf.TransferMode<>trmReceiveDownload then raise exception.createHelp(cserWrongModeOfTransfer, cnerWrongModeOfTransfer);
      if tmpTransferBf.TransferStep<>trsReceiveBeginDownload then raise exception.createHelp(cserWrongStepOfTransfer, cnerWrongStepOfTransfer);
      //Приступаю к обработке
      try
        tmpTransferBf.LastAccessTime:=Now;
        tmpTransferBf.ResponderTransferName:=aResponderTransferName;
        if tmpTransferBf.Transfering then begin//Пытаюсь делать докачку
          tmpFileHandle:=0;//от варнингов
          try
            if tmpTransferBf.TableBfDate<>aTBfInfoBeginDownload.ChecksumDate then raise exception.create({cserImpossiblyToKeepOnDownload+}'Different dates.');
            if tmpTransferBf.FileTotalSize<>aTBfInfoBeginDownload.TotalSize then raise exception.create({cserImpossiblyToKeepOnDownload+}'Different total size of file.');
            if tmpTransferBf.TableBfChecksum<>aTBfInfoBeginDownload.Checksum then raise exception.create({cserImpossiblyToKeepOnDownload+}cserChecksumError);
            //Теперь могу быть уверен, что содержимое файла не изменино
            //  С путями Bf-ов имеется некоторая неконкретность. Они первоначально задаются в заявке на перекачку. Но информации о пути и имени
            //файла(какое значение на дальнем сервере) в локальной таблице/реестре нет. Т.е. получается если начинается новая перекачка то оригинальный
            //путь файла "перетирается" указанным(куда качать). Если все качается без перебоев то хорошо, а если требуется докачка, то она(докачка)
            //не сможет понять какие указаны имя файла и путь, "по базе" или др(собственные). Поэтому последующая докачка "перебивает" имеющиеся пути на свои,
            //указанные в этот(последующий) раз(в InternalAddDownload) и ставит UseOwnPathAndFileName:=True. Или если в последующий раз путь не заданы(='')
            //ставлю UseOwnPathAndFileName:=False. Когда же приходит ответ(в ReceiveDownload) на запрос beginDownload, смотрим UseOwnPathAndFileName.
            //Если UseOwnPathAndFileName=True тогда понимаю что пути заданные и качаю по ним же. А если UseOwnPathAndFileName=False понимаю что пути стаяли
            //как "по умолчанию"(=''), и раз заказчаку(кто вызвал InternalAddDownload) "не важно" где разместить Bf, я размещаю их как в базе, т.е. переношу
            //имеющийся, недокаченный файл в каталог "по базе", и докачиваю туда.
            if (not tmpTransferBf.UseOwnPathAndFileName)and((AnsiUpperCase(tmpTransferBf.TableBfDir)<>AnsiUpperCase(aTBfInfoBeginDownload.Path))Or(AnsiUpperCase(tmpTransferBf.TableBfName)<>AnsiUpperCase(aTBfInfoBeginDownload.Filename))) then begin
              //В AddDnLd не были назначены параметры "куда качать". И эти параметры, отличаются от значений в дальней базе(т.е. со знач. в ответе(aTBfInfoBeginDownload))
              //Поэтому перемещаю файл, как в дальней базе.
              try
                if glUsedCachePath(aTBfInfoBeginDownload.Path) then tmpString:=InternalGetCachePathBf+aTBfInfoBeginDownload.Path else tmpString:=aTBfInfoBeginDownload.Path;//Получил новый путь
                if not DirectoryExists(tmpString) then if not ForceDirectories(tmpString) then raise exception.create('Can''t create folder '''+tmpString+'''.');//Проверил существует ли каталог
                tmpKeepOnDnldWithUsedOwnPath:=tmpString{указанный путь}+aTBfInfoBeginDownload.FileName;//Получил новый путь с именем файла
                if FileExists(tmpKeepOnDnldWithUsedOwnPath) then begin//Если файл существует, застираю его, а сообщение(Warning) пишу в лог.
                  tmpTransferBf.CallerActionFirst.ITMessAdd(Now, tmpStartTime, 'RcBgDn('+tmpTransferBf.BfName+')', 'File('+tmpKeepOnDnldWithUsedOwnPath+') already exists, and it will be replaced.', mecTransfer, mesWarning);
                end;
                InternalUpdateTableBfInfo(tmpTransferBf.BfName, aTBfInfoBeginDownload.Path, aTBfInfoBeginDownload.FileName, tmpUserInterface);//Выравниваю Инфо
                try
                  tmpTransferBf.FileHandle:=0;//Для предстоящих операций переноса, надо отпутить файл. CloseHandle делается в Set_FileHandle.
                  if not MoveFileEx(PChar(tmpTransferBf.RealBfLocation), PChar(tmpKeepOnDnldWithUsedOwnPath), MOVEFILE_REPLACE_EXISTING) then raise exception.create(SysErrorMessage(GetLastError));//переношу на новое(указанное) место
                except//Произошла ошибка при переносе, возвращаю прежние значения в реестре
                  InternalUpdateTableBfInfo(tmpTransferBf.BfName, tmpTransferBf.TableBfDir, tmpTransferBf.TableBfName, tmpUserInterface);
                  raise;
                end;
                //tmpKeepOnDnld:=tmpKeepOnDnldWithUsedOwnPath;//выравниваю tmpKeepOnDnld, т.е. полный путь к файлу
                tmpTransferBf.TableBfDir:=aTBfInfoBeginDownload.Path;//Ставлю новый путь
                tmpTransferBf.TableBfName:=aTBfInfoBeginDownload.FileName;//Ставлю новый FileName, после этих присвоений изменится tmpTransferBf.RealBfLocation
                //Открываю егоже еще раз, но теперь на новом(указанном) месте
                tmpFileHandle:=CreateFile(PChar(tmpTransferBf.RealBfLocation), GENERIC_WRITE Or GENERIC_READ, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
                if (tmpFileHandle=0)Or(tmpFileHandle=$FFFFFFFF) then raise exception.createHelp(SysErrorMessage(GetLastError)+'('+tmpTransferBf.RealBfLocation+').', cnerCreateFile);//теперь tmpFileHandle хороший
                tmpTransferBf.FileHandle:=tmpFileHandle;
                tmpFileHandle:=0;//Обнулил
              except on e:exception do begin
                // Есть ошибка при переносе файла, но это значит то, что неудается перенести перекачку по имеющемуся пути в
                //др. путь, как по базе. А поскольку большой та разницы нет куда качать(лишь бы качать), то оставляю перекачку
                //по прежнему пути. Хай качайить.
                tmpTransferBf.CallerActionFirst.ITMessAdd(Now, tmpStartTime, 'RcBgDn', '#'+tmpTransferBf.BfName+' MoveFile: '+e.message, mecTransfer, mesError);
                if tmpTransferBf.FileHandle=0 then begin//Файл закрыт, открываю прежний его.
                  try
                    tmpFileHandle:=CreateFile(PChar(tmpTransferBf.RealBfLocation), GENERIC_WRITE Or GENERIC_READ, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
                    if (tmpFileHandle=0)Or(tmpFileHandle=$FFFFFFFF) then raise exception.createHelp(SysErrorMessage(GetLastError)+'('+tmpTransferBf.RealBfLocation+').', cnerCreateFile);//теперь tmpFileHandle хороший
                    tmpTransferBf.FileHandle:=tmpFileHandle;
                    tmpFileHandle:=0;//Обнулил
                  except on re:exception do begin
                    re.message:='Return to prev path: '+re.message;
                    raise;
                  end;end;
                end;
                tmpTransferBf.CallerActionFirst.ITMessAdd(Now, tmpStartTime, 'RcBgDn', '#'+tmpTransferBf.BfName+' Can''t to move a file to Base-Path('+tmpKeepOnDnldWithUsedOwnPath+'), this will be as previous('+tmpTransferBf.RealBfLocation+').', mecTransfer, mesWarning);
                //e.message:='MoveFile: '+e.message;
                //raise;
              end;end;
            end;
          except on e:exception do begin//неудается KeepOnDownload, чищу недокачавшийся файл и инфо табл/рег
            //чищу прежнюю перекачку в таблице/реестре и сам файл на диске
            InternalDeleteTbfInfo(tmpTransferBf.BfName, tmpUserInterface);//в таблице/реестре
            //InternalClearTableBfInfo(tmpTbfInfo);//ставлю что почищен
            tmpTransferBf.FileHandle:=0;//что бы сработал последующий DeleteFile
            if tmpFileHandle<>0 then begin//что бы сработал последующий DeleteFile
              try CloseHandle(tmpFileHandle);except end;//В случае ошибки разбираю Handle
              //tmpFileHandle:=0; - закоментировано т.к. далее не используется, в случае изменений возможно раскоментировать.
            end;
            DeleteFile(tmpTransferBf.RealBfLocation);//сам файл на диске
            tmpTransferBf.Transfering:=False;
            tmpTransferBf.TableBfDir:='';
            tmpTransferBf.TableBfName:='';
            tmpTransferBf.TableBfChecksum:=0;
            tmpTransferBf.TableBfDate:=0;
            tmpTransferBf.BfType:=0;
            tmpTransferBf.FileTotalSize:=0;
            tmpTransferBf.TableBfCommentary:='';
            tmpTransferBf.TransferSchedule:='';
            //Чищу остальные параметры
            tmpTransferBf.TransferPos:=0;
            tmpTransferBf.TransferChecksum:=0;
            tmpTransferBf.CallerActionFirst.ITMessAdd(Now, tmpStartTime, 'RcBgDn', ''''+aTransferName+'''/#'+tmpTransferBf.BfName+'. '+Format(cserKeepOnDownloadIsCanceledErrorOccured, [e.message, e.HelpContext]), mecTransfer, mesError);
          end;end;
        end;
        //  Теперь tmpTransferBf может или иметь состояние Transfering=True и открытый FileHandle или нет. Нет
        //означает что начата новая перекачка с 0.
        if tmpTransferBf.Transfering then begin
          //Проверяю входные значения
          if tmpTransferBf.FileHandle=0 then raise exception.create('Invalid value of FileHandle=0. Contact to developer.');//Проверяю FileHandle, он недолжен быть открыт
          //Устанавливаю принятые параметры
          //tmpTransferBf.TableBfDir-уже установлен
          //tmpTransferBf.TableBfName-уже установлен
          //tmpTransferBf.TableBfChecksum-уже установлен
          //tmpTransferBf.TableBfChecksumDate-уже установлен
          //tmpTransferBf.FileTotalSize-уже установлен
          tmpTransferBf.BfType:=aTBfInfoBeginDownload.BfType;
          tmpTransferBf.TransferSchedule:=aTBfInfoBeginDownload.TransferSchedule;
          tmpTransferBf.TableBfCommentary:=aTBfInfoBeginDownload.Commentary;
          InternalSetBfFileinfo(tmpTransferBf, True);//устанавливаю нужное время и размер еще раз, т.к. для докачки это не устанавливалось, и если установить то Микрософт поставит время последнего исправления, т.е. текущее.
          //Устанавливаю остальные параметры уже установлены
          //tmpTransferBf.TransferPos-уже установлен
          //tmpTransferBf.TransferChecksum-уже установлен
          //Обновляю информацию в инфо
          InternalUpdateTableBfInfoAtBegin(tmpUserInterface, tmpTransferBf);//Пишу данные о начале перекачки
        end else begin//Перекачки не существует, создаю новый файл
          //Проверяю входные значения
          if tmpTransferBf.FileHandle<>0 then raise exception.create('Invalid value of FileHandle<>0. Contact to developer.');//Проверяю FileHandle, он недолжен быть открыт
          //Устанавливаю принятые параметры
          tmpTransferBf.TableBfDir:=aTBfInfoBeginDownload.Path;
          tmpTransferBf.TableBfName:=aTBfInfoBeginDownload.Filename;
          tmpTransferBf.TableBfChecksum:=aTBfInfoBeginDownload.Checksum;
          tmpTransferBf.TableBfDate:=aTBfInfoBeginDownload.ChecksumDate;
          tmpTransferBf.BfType:=aTBfInfoBeginDownload.BfType;
          tmpTransferBf.TransferSchedule:=aTBfInfoBeginDownload.TransferSchedule;
          tmpTransferBf.FileTotalSize:=aTBfInfoBeginDownload.TotalSize;
          tmpTransferBf.TableBfCommentary:=aTBfInfoBeginDownload.Commentary;
          //Устанавливаю остальные параметры
          tmpTransferBf.TransferPos:=0;
          tmpTransferBf.TransferChecksum:=0;
          //создаю файл
          tmpFileHandle:=0;
          try//Файл еще не открыт
            if not DirectoryExists(tmpTransferBf.RealBfDir) then if not ForceDirectories(tmpTransferBf.RealBfDir) then raise exception.create('Can''t create folder '''+tmpTransferBf.RealBfDir+'''.');//Проверяю каталог
            if FileExists(tmpTransferBf.RealBfLocation) then begin//Если файл существует, застираю его, а сообщение(Warning) пишу в лог.
              tmpTransferBf.CallerActionFirst.ITMessAdd(Now, tmpStartTime, 'RcBgDn', ''''+aTransferName+'''/#'+tmpTransferBf.BfName+' File('+tmpTransferBf.RealBfLocation+') already exists, and it will be replaced.', mecTransfer, mesWarning);
            end;
            tmpFileHandle:=CreateFile(PChar(tmpTransferBf.RealBfLocation), GENERIC_WRITE Or GENERIC_READ, 0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
            if (tmpFileHandle=0)Or(tmpFileHandle=$FFFFFFFF) then raise exception.create(SysErrorMessage(GetLastError)+'('+tmpTransferBf.RealBfLocation+').');
            //..
            tmpTransferBf.FileHandle:=tmpFileHandle;
            tmpFileHandle:=0;//Обнулил
            InternalSetBfFileinfo(tmpTransferBf, True);//устанавливаю нужное время и размер//InternalSetBfFileinfo(tmpTransferBf.FileHandle, tmpBfFileinfo, True);//устанавливаю нужное время
          except
            if ((tmpFileHandle<>0)And(tmpFileHandle<>$FFFFFFFF))Or(tmpTransferBf.FileHandle<>0) then begin try
              CloseHandle(tmpFileHandle);//Эксепшинов не дает, поэтому вызаваю без проверок
              tmpTransferBf.FileHandle:=0;//Отпускаю что бы недержать
              Deletefile(tmpTransferBf.RealBfLocation);//Стираю пустой файл
            except end;end;
            raise;
          end;
          //Добавляю информацию в инфо
          InternalInsertTableBfInfoAtBegin(tmpUserInterface, tmpTransferBf);//Пишу данные о начале перекачки
          tmpTransferBf.Transfering:=true;
        end;
        //Теперь все вопросы куда качать и с какой позиции решины
        tmpTransferBf.TransferStep:=trsReceiveDownload;//ставлю следующий шаг
        tmpTransferBf.LastSessionBeginTime:=Now;//Ставлю время, что бы получать корректные/правильные значения скорости перекачки
        //..
        InternalReceiveSendDownload(tmpTransferBf, 0);//Отправляю пакет с заявкой на Dn(Download)
        InternalSetTransferResult(tmpTransferBf, srsBeginDownload, true{false поставил true для отладки});//InternalTransferComplete(tmpTransferBf, varArrayOf([1, 0]), False);
        tmpTransferBf.CallerActionFirst.ITMessAdd(Now, tmpTransferBf.BeginTime , 'RcBgDn', ''''+aTransferName+'''/#'+tmpTransferBf.BfName, mecTransfer, mesInformation);
      except on e:exception do begin
        e.message:='RcBnDn: '+e.message;
        InternalSetTransferError(tmpTransferBf, aTransferName, e.message, E.HelpContext, False, True, @tmpCanceled);//InternalTransferError(tmpTransferBf, aTransferName, e.message, E.HelpContext, True);
        if not tmpCanceled then begin
          InternalReceiveSendBeginDownloadWithCancelResp(tmpTransferBf, cnTransferErrorResendInterval);
        end{ else raise - нет смысла в нем, т.к. Перекачка отменина, причины отмены в логе, и все сообщения разосланы};
      end;end;
    finally
      tmpTransferBf.ITUnlock;
    end;
  finally
    tmpTransferBf.ITFreeTransferLock;
    tmpTransferBf:=nil;
  end;
end;

procedure TTransferBfs.InternalReceiveSendBeginDownload(aTransferBf:ITransferBf; aWaitSendTime:Cardinal);
  var tmpPackCPT:IPackCPT;
begin
  //Create CPT
  tmpPackCPT:=TPackCPT.Create;
  tmpPackCPT.CPTasks.TaskAdd(tskADMBfBeginDownload, ParamBgDnToVariant(aTransferBf.BfName), {RouteParam}Unassigned, -1);//VarArrayOf(['', aTransferBf.IdBase, Integer(aTransferBf.TransferFrom)])
  aTransferBf.TransferPackPD.DataAsIPack:=tmpPackCPT;
  //Send PD
  if aWaitSendTime=0 then begin
    InternalSendPackPD(aTransferBf.ConnectionName, aTransferBf.TransferPackPD, aTransferBf.CallerActionFirst);
  end else begin
    InternalSendPackPDSleep(aTransferBf.ConnectionName, aTransferBf.TransferPackPD, aTransferBf.CallerActionFirst, aWaitSendTime);
  end;
end;

procedure TTransferBfs.InternalReceiveSendBeginDownloadWithCancelResp(aTransferBf:ITransferBf; aWaitSendTime:Cardinal);
  var tmpPackCPT:IPackCPT;
begin
  //Create CPT
  tmpPackCPT:=TPackCPT.Create;
  if aTransferBf.ResponderTransferName<>'' then begin
    tmpPackCPT.CPTasks.TaskAdd(tskADMBfTransferCancel, ParamTransferCancelToVariant(aTransferBf.ResponderTransferName, false), {RouteParam}Unassigned, -1);
    aTransferBf.ResponderTransferName:='';//После этой команды(CancelResponder) считаю что Responder-а нет.
  end;
  tmpPackCPT.CPTasks.TaskAdd(tskADMBfBeginDownload, ParamBgDnToVariant(aTransferBf.BfName), {RouteParam}Unassigned, -1);
  aTransferBf.TransferPackPD.DataAsIPack:=tmpPackCPT;
  //Send PD
  if aWaitSendTime=0 then begin
    InternalSendPackPD(aTransferBf.ConnectionName, aTransferBf.TransferPackPD, aTransferBf.CallerActionFirst);
  end else begin
    InternalSendPackPDSleep(aTransferBf.ConnectionName, aTransferBf.TransferPackPD, aTransferBf.CallerActionFirst, aWaitSendTime);
  end;
  aTransferBf.TransferStep:=trsReceiveBeginDownload;//откатываю на beginDownload
  aTransferBf.LastSessionTransferedSize:=0;//Обнуляю счетчик перекачки в последней сессии
  aTransferBf.LastSessionBeginTime:=Now;//ставлю новое значение для времени начала последней сессии
end;

procedure TTransferBfs.InternalReceiveSendDownload(aTransferBf:ITransferBf; aWaitSendTime:Cardinal);
  var tmpPackCPT:IPackCPT;
      tmpBfTransfer:TBfTransfer;
begin
  //Create CPT
  tmpPackCPT:=TPackCPT.Create;
  tmpBfTransfer.Pos:=aTransferBf.TransferPos;//TransferedPos;//TransferedSize
  tmpBfTransfer.TransferSize:=cnTransferSize;
  tmpBfTransfer.CheckSum:=0;
  //[0]-varOleStr:(Bf_Str_Id); [1][0]-:(Pos); [1][1]-:(Size); [1][2]-:(Checksum);
  tmpPackCPT.CPTasks.TaskAdd(tskADMBfDownload, ParamDnToVariant(aTransferBf.ResponderTransferName, aTransferBf.SequenceNumber, tmpBfTransfer) , {RouteParam}Unassigned, -1);
  aTransferBf.TransferPackPD.DataAsIPack:=tmpPackCPT;
  //Send PD
  if aWaitSendTime=0 then begin
    InternalSendPackPD(aTransferBf.ConnectionName, aTransferBf.TransferPackPD, aTransferBf.CallerActionFirst);
  end else begin
    InternalSendPackPDSleep(aTransferBf.ConnectionName, aTransferBf.TransferPackPD, aTransferBf.CallerActionFirst, aWaitSendTime);
  end;
end;

procedure TTransferBfs.InternalReceiveSendEndDownload(aTransferBf:ITransferBf);
  var tmpPackCPT:IPackCPT;
      tmpTPackPDOptions:TPackPDOptions;
begin
  //Create CPT
  tmpPackCPT:=TPackCPT.Create;
  //[0]-varOleStr:(Bf_Str_Id);
  tmpPackCPT.CPTasks.TaskAdd(tskADMBfEndDownload, ParamEndDnToVariant(aTransferBf.ResponderTransferName), {RouteParam}Unassigned, -1);
  aTransferBf.TransferPackPD.DataAsIPack:=tmpPackCPT;
  tmpTPackPDOptions:=aTransferBf.TransferPackPD.PDOptions;
  //не надо ответа о успешном выполнении или о ошибке, т.к. tskADMBfEndDownload только закрывает "сервер" и только
  //после того как "клиент" уже закрыт.
  aTransferBf.TransferPackPD.PDOptions:=tmpTPackPDOptions+[pdoNoResult{не надо ответа}];
  try
  //Send PD
  InternalSendPackPD(aTransferBf.ConnectionName, aTransferBf.TransferPackPD, aTransferBf.CallerActionFirst);
  finally
    aTransferBf.TransferPackPD.PDOptions:=tmpTPackPDOptions;
  end;
end;

procedure TTransferBfs.ITReceiveDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString; aSequenceNumber:Cardinal; aTransfer:TBfTransfer; const aData:Variant);
  var tmpComplete:boolean;
      tmpTransferBf:ITransferBf;
      tmpCanceled:boolean;
      tmpStartTime:TDateTime;
      tmpUserInterface:IUnknown;
begin
  tmpStartTime:=Now;
  tmpTransferBf:=InternalTransferNameToITransferBf(aTransferName, vvmView, True);
  tmpTransferBf.ITSetTransferLockWait;
  try
    tmpTransferBf.ITLockWait(cnTransferLockWait);
    try
      try//Проверяю права.
        CompareSecurity(tmpTransferBf.CallerActionFirst.CallerSecurityContext, aCallerAction.CallerSecurityContext, [eqlUserName], true{aRaise});
      except on e:exception do begin
        e.HelpContext:=cnerAccessDenied;
        e.message:=Format(cserAccessDenied, [e.message]);
        raise;
      end;end;
      if not tmpTransferBf.Active then raise exception.createHelp(cserTransferIsCanceled, cnerTransferIsCanceled);
      if tmpTransferBf.TransferMode<>trmReceiveDownload then raise exception.createHelp(cserWrongModeOfTransfer, cnerWrongModeOfTransfer);
      if tmpTransferBf.TransferStep<>trsReceiveDownload then raise exception.createHelp(cserWrongStepOfTransfer, cnerWrongStepOfTransfer);
      if tmpTransferBf.SequenceNumber<>aSequenceNumber then begin
        tmpTransferBf.CallerActionFirst.ITMessAdd(Now, tmpTransferBf.LastSessionBeginTime, 'RcDn', ''''+aTransferName+'''/#'+tmpTransferBf.BfName+'. Received wrong a SequenceNumber(Expect='+IntToStr(tmpTransferBf.SequenceNumber)+'<>'+IntToStr(aSequenceNumber)+').', mecTransfer, mesWarning);
        Exit;
      end;
      if aTransfer.Pos<>tmpTransferBf.TransferPos then raise exception.createFmtHelp(cserOtherValuePosExpected, [tmpTransferBf.TransferPos, aTransfer.Pos], cnerOtherValuePosExpected);
      try
        tmpTransferBf.LastAccessTime:=Now;
        tmpComplete:=InternalWriteBf(tmpTransferBf, aTransfer, aData);
        //в InternalWriteBf данные записываются в файл с позиции aTransfer.Pos, далее расчитывается
        //tmpTransferBf.TransferPos-новая позиция для следующего запроса,
        //tmpTransferBf.TransferChecksum-контрольная сумма перекаченных данных,
        //tmpTransferBf.LastSessionTransferedSize-количество байт перекаченных в "последней сессии",
        //tmpTransferBf.TransferSpeed-скорость перекачки.
        if tmpComplete then begin
          //Все скачал. Это говорит о том, что теперь файл расположен по правильному путь,
          //в него записаны все даннае, и осталось исправить регистрационную запись в таблицу/реестре и удалить
          //перекачку из списка.
          if tmpTransferBf.TableBfChecksum<>tmpTransferBf.TransferChecksum then begin
            raise exception.createFmtHelp(cserInternalError, ['''tmpTransferBf.TableBfChecksum<>tmpTransferBf.TransferChecksum'''], cnerInternalError);
          end;
          //InternalRecalcChecksum(aTransferBf.FileHandle, $FFFFFFFF)
          //DeleteFile(PChar(tmpFilepath));
          //Перекачкапрошла успешно
          InternalUpdateTableBfInfoAtComplete(tmpUserInterface, tmpTransferBf);//TransferPos=NULL, TransferChecksum=NULL, TransferedDate:=Now;
          InternalReceiveSendEndDownload(tmpTransferBf);//Посылаю сообщение что бы закрыть перекачку. Делать это не очень важно, т.к. она закроится и сама, по бездействию.
          tmpTransferBf.Transfering:=False;//Дезактивирую перекачку
          FOpenBfs.ITClearOfStrIndex(aTransferName);//удаляю перекачку из списка
          InternalSetTransferResult(tmpTransferBf, srsCompleteDownload, True);//событие о завершении перекачки
          tmpTransferBf.FileHandle:=0;//отпускаю файл
          InternalGetISync.ITFreeLock(csllTransferDownloadClient+tmpTransferBf.BfName, tmpTransferBf.LockOwner);//отпускаю лок
          tmpTransferBf.Active:=False{True};//это уже перестраховка
          tmpTransferBf.CallerActionFirst.ITMessAdd(Now, tmpTransferBf.LastSessionBeginTime, 'RcDn', ''''+aTransferName+'''/#'+tmpTransferBf.BfName+' is complete. Transferred(All/Last)='+IntToStr(tmpTransferBf.FileTotalSize)+'/'+IntToStr(tmpTransferBf.LastSessionTransferedSize)+' '+InternalTransferInfoToStr(tmpTransferBf, true)+'.', mecTransfer, mesInformation);
        end else begin//Еще скачиваю, at process.
          tmpTransferBf.SequenceNumber:=tmpTransferBf.SequenceNumber+1;
          //Обнавляю инфо о перекачке(Pos/Checksum) в таблице/реестре
          InternalUpdateTableBfInfoAtProcess(tmpUserInterface, tmpTransferBf);
          InternalReceiveSendDownload(tmpTransferBf, 0);//Отправляю запрос на продолжение перекачки
          InternalSetTransferResult(tmpTransferBf, srsProcessDownload, True);
          tmpTransferBf.CallerActionFirst.ITMessAdd(now, tmpStartTime, 'RcDn', ''''+aTransferName+'''/#'+tmpTransferBf.BfName+'('+InternalTransferInfoToStr(tmpTransferBf, False)+' Sn='+IntToStr(aSequenceNumber)+').', mecTransfer, mesInformation);
        end;
      except on e:exception do begin
        e.message:='RcDnBf: '+e.message;
        InternalSetTransferError(tmpTransferBf, aTransferName, e.message, E.HelpContext, False, True, @tmpCanceled);
        if not tmpCanceled then begin
          tmpTransferBf.LastAccessTime:=now;
          if E.HelpContext=cnerChecksumError{в InternalWriteBf} then begin//в прилетевшем блоке изменина контрольная сумма, перезапрашиваю этот пакет и увеличиваю счетчик ошибок
            InternalReceiveSendDownload(tmpTransferBf, 0);//Перезапрашиваю этот же пакет
            tmpTransferBf.CallerActionFirst.ITMessAdd(Now, tmpTransferBf.LastSessionBeginTime, 'RcDn', ''''+aTransferName+'''/#'+tmpTransferBf.BfName+'. Checksum error. Repeat inquiry.', mecTransfer, mesWarning);
          end else begin
            //Перезапрашиваю этот же пакет. Можно было бы передернуть сессью, но не понятно зачем, т.е передергивание закрывает
            //дальний сервер перекачки(который в данном случае сработал) и открывает его заново
            InternalReceiveSendDownload(tmpTransferBf, cnTransferErrorResendInterval);
            tmpTransferBf.CallerActionFirst.ITMessAdd(Now, tmpTransferBf.LastSessionBeginTime, 'RcDn', ''''+aTransferName+'''/#'+tmpTransferBf.BfName+'. Repeat inquiry.', mecTransfer, mesWarning);
          end;
        end{ else raise - нет смысла в нем, т.к. Перекачка отменина, причины отмены в логе, и все сообщения разосланы};
      end;end;
    finally
      tmpTransferBf.ITUnlock;
    end;
  finally
    tmpTransferBf.ITFreeTransferLock;
    tmpTransferBf:=nil;
  end;
end;

function TTransferBfs.InternalResetAllDownloadOfBfName(const aBfName:AnsiString):Integer;
  var tmpIntIndex:Integer;
      tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
      tmpITransferBf:ITransferBf;
begin
  Result:=0;
  tmpIntIndex:=-1;
  while true do begin
    tmpIVarsetDataView:=FOpenBfs.ITViewNextGetOfIntIndex(tmpIntIndex);
    if tmpIntIndex=-1 then break;
    tmpIUnknown:=tmpIVarsetDataView.ITData;
    if (Not assigned(tmpIUnknown))Or(tmpIUnknown.QueryInterface(ITransferBf, tmpITransferBf)<>S_OK)Or(Not assigned(tmpITransferBf)) then raise exception.createFmt(cserInternalError, ['Interface ''ITransferBf'' not found.']);
    if (tmpITransferBf.BfName=aBfName)And(tmpITransferBf.TransferMode=trmDownload) then begin
      FOpenBfs.ITClearOfIntIndex(tmpIntIndex);
      tmpIntIndex:=-1;//Начинаю поис заново и возможно там же где искал, это место можно оптимизировать!
    end;
  end;
  tmpIVarsetDataView:=nil;
  tmpIUnknown:=nil;
  tmpITransferBf:=nil;
end;

procedure TTransferBfs.ITReceiveErrorBeginDownload(aCallerAction:ICallerAction; const aTransferName, aErrorMessage:AnsiString; aHelpContext:Integer);
  function tmpErrorIsFatal:boolean; begin
    Result:=(aHelpContext=cnerBfNameNotExists)Or(aHelpContext=cnerCantDownloadDuringTransfer)Or(aHelpContext=cnerCreateFile)Or(aHelpContext=cnerUnableSetLock)Or(aHelpContext=cnerAccessDenied);
  end;
  var tmpTransferBf:ITransferBf;
      tmpCanceled:boolean;
begin
  //Прилетела ошибка при запросе открыть сервер для перекачки.
  //Если ошибка позволяет продолжить перекачку, отправляю повторный запрос через интервал cnTransferErrorResendInterval.
  //В противном случае перекачка прерывается.
  if aTransferName='' then raise exception.createFmtHelp(cserInvalidTransferName, [aTransferName], cnerInvalidTransferName);
  tmpTransferBf:=InternalTransferNameToITransferBf(aTransferName, vvmView, True);
  tmpTransferBf.ITSetTransferLockWait;
  try
    tmpTransferBf.ITLockWait(cnTransferLockWait);
    try
      try//Проверяю права.
        CompareSecurity(tmpTransferBf.CallerActionFirst.CallerSecurityContext, aCallerAction.CallerSecurityContext, [eqlUserName], true{aRaise});
      except on e:exception do begin
        e.HelpContext:=cnerAccessDenied;
        e.message:=Format(cserAccessDenied, [e.message]);
        raise;
      end;end;
      //Проверяю соответствие способа и шага перекачки.
      if not tmpTransferBf.Active then raise exception.createHelp(cserTransferIsCanceled, cnerTransferIsCanceled);
      if tmpTransferBf.TransferMode<>trmReceiveDownload then raise exception.createHelp(cserWrongModeOfTransfer, cnerWrongModeOfTransfer);
      if tmpTransferBf.TransferStep<>trsReceiveBeginDownload then raise exception.createHelp(cserWrongStepOfTransfer, cnerWrongStepOfTransfer);
      InternalSetTransferError(tmpTransferBf, aTransferName, aErrorMessage, aHelpContext, tmpErrorIsFatal, True, @tmpCanceled);
      if not tmpCanceled then begin
        //Перекачка не прервалась, ставлю новое время последнего доступа и отправляю повторный запрос на открытие сервера перекачки.
        tmpTransferBf.LastAccessTime:=Now;
        InternalReceiveSendBeginDownload(tmpTransferBf, cnTransferErrorResendInterval);
      end;
    finally
      tmpTransferBf.ITUnlock;
    end;
  finally
    tmpTransferBf.ITFreeTransferLock;
    tmpTransferBf:=nil;
  end;
end;

function TTransferBfs.InternalTransferInfoToStr(aTransferBf:ITransferBf; aShowErrorCount:boolean):AnsiString;
  function localGetPercent:AnsiString; begin
    if (aTransferBf.FileTotalSize<1) then result:='No transfer' else Result:=IntToStr(((aTransferBf.TransferPos*100)div aTransferBf.FileTotalSize))+'%';
  end;
  function localGetErrorCount:AnsiString; begin
    if aShowErrorCount then begin
      if (aTransferBf.TransferErrorCount<1) then result:=' No error' else Result:=' ErrrCnt='+IntToStr(aTransferBf.TransferErrorCount);
    end else result:='';
  end;
begin
  Result:=localGetPercent+' Speed='+TransferSpeedToString(aTransferBf.TransferSpeed)+localGetErrorCount;
end;

procedure TTransferBfs.ITReceiveErrorDownload(aCallerAction:ICallerAction; const aTransferName, aErrorMessage:AnsiString; aHelpContext:Integer);
  function tmpErrorIsFatal:boolean; begin
    Result:=(aHelpContext=cnerInvalidTransferName)Or(aHelpContext=cnerInternalError)Or(aHelpContext=cnerAccessDenied);
  end;
  var tmpTransferBf:ITransferBf;
      tmpCanceled:boolean;
      tmpStartTime:TDateTime;
begin
  if aTransferName='' then raise exception.createFmtHelp(cserInvalidTransferName, [aTransferName], cnerInvalidTransferName);
  tmpStartTime:=Now;
  tmpTransferBf:=InternalTransferNameToITransferBf(aTransferName, vvmView, True);
  tmpTransferBf.ITSetTransferLockWait;
  try
    tmpTransferBf.ITLockWait(cnTransferLockWait);
    try
      try//Проверяю права.
        CompareSecurity(tmpTransferBf.CallerActionFirst.CallerSecurityContext, aCallerAction.CallerSecurityContext, [eqlUserName], true{aRaise});
      except on e:exception do begin
        e.HelpContext:=cnerAccessDenied;
        e.message:=Format(cserAccessDenied, [e.message]);
        raise;
      end;end;
      //Проверяю соответствие способа и шага перекачки.
      if not tmpTransferBf.Active then raise exception.createHelp(cserTransferIsCanceled, cnerTransferIsCanceled);
      if tmpTransferBf.TransferMode<>trmReceiveDownload then raise exception.createHelp(cserWrongModeOfTransfer, cnerWrongModeOfTransfer);
      if tmpTransferBf.TransferStep<>trsReceiveDownload then raise exception.createHelp(cserWrongStepOfTransfer, cnerWrongStepOfTransfer);
      tmpTransferBf.LastAccessTime:=Now;
      //Устанавливаю ошибку, тут происходят проверки: нужноли прерывать перекачку, исчерпано ли максимальное количество ошибок,
      //рассылаются сообщения подписчикам о ошибке.
      InternalSetTransferError(tmpTransferBf, aTransferName, aErrorMessage, aHelpContext, tmpErrorIsFatal, True, @tmpCanceled);
      if not tmpCanceled then begin
        //Перекачка не остановлена, т.е. ошибка или не достаточно классифицирована или не "серьезная"
        if (aHelpContext=cnerTransferingBroken)Or(aHelpContext=cnerTransferIsCanceled)Or(aHelpContext=cnerWrongModeOfTransfer)Or
           (aHelpContext=cnerWrongStepOfTransfer)Or(aHelpContext=cnerPastSequenceNumber) then begin
          //В этом случае целесообразней вызвать ITBegindownload
          InternalReceiveSendBeginDownloadWithCancelResp(tmpTransferBf, cnTransferErrorResendInterval);
          //InternalResponderTransferCancel(tmpTransferBf, []{[icmToDoOnResponder{, icmSendNotificationForCaller}{]});//Отпускаю "сервер" перекачки
          //tmpTransferBf.TransferStep:=trsReceiveBeginDownload;//откатываю на beginDownload
          //tmpTransferBf.LastSessionTransferedSize:=0;//Обнуляю счетчик перекачки в последней сессии
          //tmpTransferBf.LastSessionBeginTime:=Now;//ставлю новое значение для времени начала последней сессии
          //InternalReceiveSendBeginDownload(tmpTransferBf, 0);//отправляю запрос на новый сервер перекачки
          tmpTransferBf.CallerActionFirst.ITMessAdd(now, tmpStartTime, 'RcErDn', 'Reset session '+aTransferName+'/#'+tmpTransferBf.BfName+'('+InternalTransferInfoToStr(tmpTransferBf, true)+').', mecTransfer, mesWarning);
        end else InternalReceiveSendDownload(tmpTransferBf, cnTransferErrorResendInterval);//Отправляю запрос на продолжение перекачки
      end;
    finally
      tmpTransferBf.ITUnlock;
    end;
  finally
    tmpTransferBf.ITFreeTransferLock;
    tmpTransferBf:=nil;
  end;
end;

procedure TTransferBfs.ITCheckTransferProcess;
  var tmpLockOwner:Integer;
  function LocalGetLockOwner:Integer;
  begin
    if tmpLockOwner=-1 then begin
      tmpLockOwner:=InternalGetISync.ITGenerateLockOwner;
    end;
    Result:=tmpLockOwner;
  end;
  var tmpIntIndex:Integer;
      tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
      tmpITransferBf:ITransferBf;
begin
  tmpLockOwner:=-1;
  try
    tmpIntIndex:=-1;
    while true do begin
      tmpIVarsetDataView:=FOpenBfs.ITViewNextGetOfIntIndex(tmpIntIndex);
      if tmpIntIndex=-1 then break;
      tmpIUnknown:=tmpIVarsetDataView.ITData;
      if (Not assigned(tmpIUnknown))Or(tmpIUnknown.QueryInterface(ITransferBf, tmpITransferBf)<>S_OK)Or(Not assigned(tmpITransferBf)) then raise exception.createFmt(cserInternalError, ['Interface ''ITransferBf'' not found.']);
      tmpITransferBf.ITSetTransferLockWait;
      try
        tmpITransferBf.ITLock;
        try
          //Время ожидания вышло
          if not tmpITransferBf.Active then continue;
          case tmpITransferBf.TransferMode of
            trmNone:begin
              //None
            end;
            trmReceiveDownload:begin
              if (DateTimeToMSecs(Now)-DateTimeToMSecs(tmpITransferBf.LastAccessTime)){tmpWait}>cnWaitForRespondInterval then begin
                InternalGetISync.ITSetLockWait(csllTransfer+tmpITransferBf.BfName, tmpITransferBf.CallerActionFirst{.UserName}, LocalGetLockOwner, True, cnTransferLockWait, true);
                case tmpITransferBf.TransferStep of
                  trsReceiveBeginDownload{5}:begin
                    if tmpITransferBf.TransferErrorCount<>-1 then tmpITransferBf.TransferErrorCount:=tmpITransferBf.TransferErrorCount+1;
                    InternalReceiveSendBeginDownload(tmpITransferBf, 0);
                  end;
                  trsReceiveDownload{6}:begin
                    if tmpITransferBf.TransferErrorCount<>-1 then tmpITransferBf.TransferErrorCount:=tmpITransferBf.TransferErrorCount+1;
                    InternalReceiveSendDownload(tmpITransferBf, 0);
                  end;
                end;
              end;
            end;
            trmDownload:begin
              if (DateTimeToMSecs(Now)-DateTimeToMSecs(tmpITransferBf.LastAccessTime))>30000{cnWaitServerDownloadInactivety} then begin
                //InternalGetISync.ITSetLockWait(csllTransfer+tmpITransferBf.BfName, tmpITransferBf.CallerActionFirst{.UserName}, LocalGetLockOwner, True, cnTransferLockWait, true);
                FOpenBfs.ITClearOfIntIndex(tmpIntIndex);
              end;
            end;
          else
            tmpITransferBf.CallerActionFirst.ITMessAdd(Now, Now, 'CheckTransferProcess', 'TransferMode='+IntToStr(Integer(tmpITransferBf.TransferMode))+' for TransferName='''+tmpIVarsetDataView.ITStrIndex+''' is unsupported.', mecTransfer, mesWarning);
          end;
        finally
          tmpITransferBf.ITUnlock;
        end;  
      finally
        tmpITransferBf.ITFreeTransferLock;
      end;
    end;
  finally
    if tmpLockOwner<>-1 then InternalGetISync.ITClearLockOwner(tmpLockOwner);
  end;
  tmpIVarsetDataView:=nil;
  tmpIUnknown:=nil;
  tmpITransferBf:=nil;
end;

procedure TTransferBfs.InternalAddTransferError(aTransferBf:ITransferBf; const aErrorMessage:AnsiString; aHelpContext:Integer);
begin
  if aTransferBf.TransferErrorCount<>-1 then aTransferBf.TransferErrorCount:=aTransferBf.TransferErrorCount+1;
  aTransferBf.TransferErrorLastMessage:=aErrorMessage;
  aTransferBf.TransferErrorLastHelpContext:=aHelpContext;
end;

//Установка результата перекачки
function TTransferBfs.InternalSetTransferError(aTransferBf:ITransferBf; const aTransferName:AnsiString; const aErrorMessage:AnsiString; aHelpContext:Integer; aCancel:boolean; aRaise:boolean; aPCanceled:Pboolean):boolean;
  var tmpPackPD:IPackPD;
      tmpPackCPR:IPackCPR;
      tmpIntIndex:Integer;
      tmpCallerAction:ICallerAction;
      tmpCanceled:boolean;
begin
  Result:=False;
  if not assigned(aTransferBf) then if aRaise then raise exception.create('aTransferBf not assigned.') else exit;
  if aTransferBf.CallerActions.ITCount=0 then if aRaise then raise exception.create('No callerActions.') else exit;
  tmpCanceled:=(((not aTransferBf.TransferAuto)or(aTransferBf.TransferErrorCount>=cnTransferMaxErrorCount))and(aTransferBf.TransferMode<>trmParaDownload))or(aCancel);
  try
    if assigned(aTransferBf.TransferProcessEvents.OnErrorTransfer) then Result:=aTransferBf.TransferProcessEvents.OnErrorTransfer(aTransferBf.TransferProcessEvents.UserData, aTransferBf, aTransferBf.BfName, {aTransferBf.TransferedFrom,} aErrorMessage, aHelpContext, tmpCanceled, {aTransferBf.TransferPos, }aTransferBf.TransferErrorCount{, aTransferBf.TransferSpeed});
  except on e:exception do begin
    e.message:='OnCompleteTransfer: '+e.message;
    raise;
  end;end;
  //..
  tmpIntIndex:=-1;
  While true do begin//Рассылаю подписчикам сообщение об ошибке
    tmpCallerAction:=aTransferBf.CallerActionViewNextGetOfIntIndex(tmpIntIndex);
    if (tmpIntIndex=-1)Or(Not assigned(tmpCallerAction)) then Break;
    if (aTransferBf.TransferProcessToSender)And(assigned(tmpCallerAction.CallerSenderParams)And(Not varIsEmpty(tmpCallerAction.CallerSenderParams.SenderPackPD))) then begin
      tmpPackPD:=TPackPD.Create;
      tmpPackPD.AsVariant:=tmpCallerAction.CallerSenderParams.SenderPackPD;
      tmpPackCPR:=TPackCPR.Create;
      tmpPackCPR.CPID:=tmpCallerAction.CallerSenderParams.SenderPackCPID;
      tmpPackCPR.AddWithError(tmpCallerAction.CallerSenderParams.SenderADMTaskNum, SendPackErrorTransferToVariant(aTransferBf.BfName, {aTransferBf.TransferedFrom,}{tmpCanceled,} {aTransferBf.TransferPos, }tmpCanceled, aTransferBf.TransferErrorCount{, aTransferBf.TransferSpeed}), tmpCallerAction.CallerSenderParams.SenderRouteParam{RouteParam}{Unassigned}, -1, InternalGetIEPointProperties.TitlePoint+': '+aErrorMessage, aHelpContext);
      tmpPackPD.DataAsIPack:=tmpPackCPR;
      InternalSendPackPD(aTransferBf.ConnectionName, tmpPackPD, tmpCallerAction);
      Result:=True;
    end;
  end;
  tmpCallerAction:=nil;
  InternalAddTransferError(aTransferBf, aErrorMessage, aHelpContext);//Записываю текст ошибки в TransferErrorLastMessage, иувеличиваю счетчик
  if tmpCanceled then InternalTransferCancel(aTransferName, [icmToDoOnResponder, icmSendNotificationForCaller], '');//тут чистятся локи
  if assigned(aPCanceled) then aPCanceled^:=tmpCanceled;
  //показать ошибку
  aTransferBf.CallerActionFirst.ITMessAdd(Now, aTransferBf.BeginTime, 'TrEr', 'Transfer error: '''+aTransferName+'''/#'+aTransferBf.BfName+{' Canceled='+IntToStr(Integer(tmpCanceled))+}', ErrCount='+IntToStr(aTransferBf.TransferErrorCount)+', Mes='''+aErrorMessage+'''/HC='+IntToStr(aHelpContext), mecTransfer, mesError);
end;

function TTransferBfs.InternalToSetResultVariant(aSetResultStatus:TSetResultStatus; aTransferBf:ITransferBf):variant;
begin
  case aSetResultStatus of
    srsBeginDownload:begin
      result:=SendPackBeginDownloadToVariant(aTransferBf.BfName, aTransferBf.TransferName, aTransferBf.FileTotalSize);
    end;
    srsProcessDownload:begin//tmpWord:=((aTransferBf.TransferPos*100)Div aTransferBf.FileTotalSize);
      result:=SendPackProcessDownloadToVariant(aTransferBf.BfName, {aTransferBf.TransferedFrom,} aTransferBf.TransferPos, aTransferBf.TransferErrorCount, aTransferBf.TransferSpeed{, tmpWord});
    end;
    srsCompleteDownload:begin
      result:=SendPackCompleteDownloadToVariant(aTransferBf.BfName, {aTransferBf.IdLocal, }{aTransferBf.TransferedFrom,} {aTransferBf.TransferPos, }aTransferBf.TransferErrorCount, aTransferBf.TransferSpeed);
    end;
  else
    raise exception.createFmt(cserInternalError, ['Unknoun value aSetResultStatus']);
  end;
end;

function TTransferBfs.InternalSetTransferResult(aTransferBf:ITransferBf; aSetResultStatus:TSetResultStatus; aRaise:boolean):boolean;
  var tmpIntIndex:Integer;
      tmpCallerAction:ICallerAction;
      tmpBeginTransferEvent:TBeginTransferEvent;
      tmpProcessTransferEvent:TProcessTransferEvent;
      tmpCompleteTransferEvent:TCompleteTransferEvent;
      tmpPointer:Pointer;
      tmpVariant:Variant;
begin
  Result:=False;
  if not assigned(aTransferBf) then if aRaise then raise exception.create('aTransferBf not assigned.') else exit;
  //..
  tmpPointer:=aTransferBf.TransferProcessEvents.UserData;
  case aSetResultStatus of
    //srsAddDownload:begin
    //  tmpAddTransferEvent:=aTransferBf.TransferProcessEvents.OnAddTransfer;
    //  if assigned(tmpAddTransferEvent) then Result:=InternalSetTransferResultAddEvents(tmpAddTransferEvent, tmpPointer, aTransferBf.BfName{, aTransferBf.ResponderTransferName});
    //end;
    srsBeginDownload:begin
      tmpBeginTransferEvent:=aTransferBf.TransferProcessEvents.OnBeginTransfer;
      if assigned(tmpBeginTransferEvent) then Result:=InternalSetTransferResultBeginEvents(tmpBeginTransferEvent, tmpPointer, aTransferBf, aTransferBf.BfName, {aTransferBf.TransferedFrom,} aTransferBf.FileTotalSize);
    end;
    srsProcessDownload:begin
      tmpProcessTransferEvent:=aTransferBf.TransferProcessEvents.OnProcessTransfer;
      if assigned(tmpProcessTransferEvent) then begin
        //tmpWord:=((aTransferBf.TransferPos*100)Div aTransferBf.FileTotalSize);
        Result:=InternalSetTransferResultProcessEvents(tmpProcessTransferEvent, tmpPointer, aTransferBf, aTransferBf.BfName, aTransferBf.TransferPos, aTransferBf.TransferErrorCount, aTransferBf.TransferSpeed{, tmpWord});
      end;
    end;
    srsCompleteDownload:begin
      tmpCompleteTransferEvent:=aTransferBf.TransferProcessEvents.OnCompleteTransfer;
      if assigned(tmpCompleteTransferEvent) Then
      if aTransferBf.TransferMode=trmParaDownload then Result:=InternalSetTransferResultCompleteEvents(tmpCompleteTransferEvent, tmpPointer, aTransferBf, aTransferBf.BfName, {aTransferBf.IdLocal, }{aTransferBf.TransferedFrom,} {aTransferBf.TransferPos, }aTransferBf.TransferErrorCount, aTransferBf.TransferSpeed, '', '')
                                                        else Result:=InternalSetTransferResultCompleteEvents(tmpCompleteTransferEvent, tmpPointer, aTransferBf, aTransferBf.BfName, {aTransferBf.IdLocal, }{aTransferBf.TransferedFrom,} {aTransferBf.TransferPos, }aTransferBf.TransferErrorCount, aTransferBf.TransferSpeed, aTransferBf.RealBfLocation, aTransferBf.TableBfCommentary);
    end;
  else
    raise exception.createFmt(cserInternalError, ['Unknoun value aSetResultStatus']);
  end;
  //..
  if aTransferBf.TransferProcessToSender then begin
    if aTransferBf.CallerActions.ITCount=0 then if aRaise then raise exception.create('No callerAction.') else exit;
    tmpVariant:=InternalToSetResultVariant(aSetResultStatus, aTransferBf);
    tmpIntIndex:=-1;
    while true do begin
      tmpCallerAction:=aTransferBf.CallerActionViewNextGetOfIntIndex(tmpIntIndex);
      if (tmpIntIndex=-1)Or(Not assigned(tmpCallerAction)) then Break;
      if assigned(tmpCallerAction.CallerSenderParams)And(Not varIsEmpty(tmpCallerAction.CallerSenderParams.SenderPackPD)) then begin
        InternalSetTransferResultSendPack(aTransferBf.ConnectionName, tmpCallerAction, tmpVariant);
      end;
    end;
    tmpCallerAction:=nil;
    Result:=True;//Устанавливаю что пакеты полетели
  end;
end;

//Событие(пакетное) перекачки
procedure TTransferBfs.InternalSetTransferResultSendPack(const aConnectionName:AnsiString; aCallerAction:ICallerAction; const aResult:Variant);
  var tmpPackPD:IPackPD;
      tmpPackCPR:IPackCPR;
begin
  if not assigned(aCallerAction) then raise exception.create('aCallerAction is not assigned.');
  tmpPackPD:=TPackPD.Create;
  tmpPackPD.AsVariant:=aCallerAction.CallerSenderParams{?}.SenderPackPD;
  tmpPackCPR:=TPackCPR.Create;
  tmpPackCPR.CPID:=aCallerAction.CallerSenderParams.SenderPackCPID;
  tmpPackCPR.Add(aCallerAction.CallerSenderParams.SenderADMTaskNum, aResult, aCallerAction.CallerSenderParams.SenderRouteParam{RouteParamas}{Unassigned}, -1);
  tmpPackPD.DataAsIPack:=tmpPackCPR;
  InternalSendPackPD(aConnectionName, tmpPackPD, aCallerAction);
  tmpPackCPR:=nil;
  tmpPackPD:=nil;
end;

//События(адресные) перекачки
{function TTransferBfs.InternalSetTransferResultAddEvents(aOnAddTransfer:TAddTransferEvent; aUserData:Pointer; const aBfName:AnsiString):boolean;
begin
  try result:=aOnAddTransfer(aUserData, aBfName); except on e:exception do begin e.message:='OnBeginTransfer: '+e.message;raise;end;end;
end;}

function TTransferBfs.InternalSetTransferResultBeginEvents(aOnBeginTransfer:TBeginTransferEvent; aUserData:Pointer; aTransferBf:ITransferBf; const aBfName:AnsiString; aTotalSize:Cardinal):boolean;
begin
  try result:=aOnBeginTransfer(aUserData, aTransferBf, aBfName, aTotalSize); except on e:exception do begin e.message:='OnBeginTransfer: '+e.message;raise;end;end;
end;

function TTransferBfs.InternalSetTransferResultProcessEvents(aOnProcessTransfer:TProcessTransferEvent; aUserData:Pointer; aTransferBf:ITransferBf; const aBfName:AnsiString; aTransferedSize:Cardinal; aTransferErrorCount:Integer; aTransferSpeed:double):boolean;
begin
  try result:=aOnProcessTransfer(aUserData, aTransferBf, aBfName, aTransferedSize, aTransferErrorCount, aTransferSpeed); except on e:exception do begin e.message:='OnProcessTransfer: '+e.message;raise;end;end;
end;

function TTransferBfs.InternalSetTransferResultCompleteEvents(aOnCompleteTransfer:TCompleteTransferEvent; aUserData:Pointer; aTransferBf:ITransferBf; const aBfName:AnsiString; aTransferErrorCount:Integer; aTransferSpeed:double; const aBfLocation, aBfCommentary:AnsiString):boolean;
begin
  try result:=aOnCompleteTransfer(aUserData, aTransferBf, aBfName, aTransferErrorCount, aTransferSpeed, aBfLocation, aBfCommentary); except on e:exception do begin e.message:='OnCompleteTransfer: '+e.message;raise;end;end;
end;

function TTransferBfs.InternalSetTransferResultErrorEvents(aOnErrorTransfer:TErrorTransferEvent; aUserData:Pointer; aTransferBf:ITransferBf; const aBfName:AnsiString; const aMessage:AnsiString; aHelpContext:Integer; aCanceled:boolean; aTransferErrorCount:Integer):boolean;
begin
  try result:=aOnErrorTransfer(aUserData, aTransferBf, aBfName, aMessage, aHelpContext, aCanceled, aTransferErrorCount); except on e:exception do begin e.message:='OnErrorTransfer: '+e.message;raise;end;end;
end;

procedure TTransferBfs.InternalSendPackPD(const aConnectionName:AnsiString; aPackPD:IPackPD; aCallerAction:ICallerAction);
begin//Процедура отправки пакета, написана для отправки пакета aPackPD, что бы изключить директивы из текста программы.
  InternalGetIThreadsPool.ITMTaskAdd(tskMTPDConnectionName, VarArrayOf([aConnectionName, aPackPD{.AsVariant}]), Unassigned, aCallerAction.SecurityContext);
end;

procedure TTransferBfs.InternalSendPackPDSleep(const aConnectionName:AnsiString; aPackPD:IPackPD; aCallerAction:ICallerAction; aSleepTime:Integer);
begin
  //Процедура отправки пакета с задержкой выполднения, написана для отправки пакета aPackPD, что бы изключить директивы из текста программы,
  //и сделать возможным отправку с задержкой.
  InternalGetIThreadsPool.ITMSleepTaskAdd(tskMTPDConnectionName, VarArrayOf([aConnectionName, aPackPD{.AsVariant}]), Unassigned, aCallerAction.SecurityContext, aSleepTime);
end;

procedure TTransferBfs.ITTransportError(aCallerAction:ICallerAction; const aConnectionName:AnsiString; aPack:IPack; const aMessage:AnsiString; aHelpContext:Integer);
  var tmpTransferBf:ITransferBf;
      tmpCanceled:boolean;
      tmpTransferName:AnsiString;
      tmpPackPD:IPackPD;
begin
  //Отработка транспортной ошибки. Этот вызо бывает когда сформирован ответ на запрос и его не получилось отправить.
  //Ставлю его на отложенную отправку и если нашлась зась запись о нем то поправляю последнее время доступа и увеличиваю
  //счетчик ошибок.
  if (Not assigned(aPack))Or(aPack.QueryInterface(IPackPD, tmpPackPD)<>S_OK)Or(Not assigned(tmpPackPD)) then raise exception.createFmtHelp(cserInvalidValueOf, ['aPack'], cnerInvalidValueOf);
  tmpTransferName:=VarToStr(tmpPackPD.PDID);
  if tmpTransferName='' then raise exception.createFmtHelp(cserInvalidValueOf, ['aPackPD.PDID='''''], cnerInvalidValueOf);
  //Обработка транспортной ошибки, т.е. не удается отправить пакет
  tmpTransferBf:=InternalTransferNameToITransferBf(tmpTransferName, vvmView, False{Не надо райс});
  if assigned(tmpTransferBf) then begin
    //Написал пока толька для Download-a. Для Upload-a нужно еще что-то.
    tmpTransferBf.ITSetTransferLockWait;
    try
      tmpTransferBf.ITLockWait(cnTransferLockWait);
      try
        //aConnectionName<>tmpTransferBf.ConnectionName - не проверяю, т.к. tmpTransferBf.ConnectionName может быть изменен или ..
        InternalSetTransferError(tmpTransferBf, tmpTransferName, aMessage, aHelpContext, False, True, @tmpCanceled);
        if not tmpCanceled then begin//если не отменина, ставлю на отложенную отправку
          tmpTransferBf.LastAccessTime:=Now;
          InternalSendPackPDSleep(tmpTransferBf.ConnectionName, tmpPackPD, aCallerAction, cnTransferErrorResendInterval);
        end;
      finally
        tmpTransferBf.ITUnlock;
      end;
    finally
      tmpTransferBf.ITFreeTransferLock;
      tmpTransferBf:=nil;
    end;
  end else begin//ставлю на отложенную отправку
    //Такого Transfer-а больше нет, этот код может обрабатываться если например перекачка закончилась нормально и
    //отправила команду закрыть "сервер".
    InternalSendPackPDSleep(aConnectionName, tmpPackPD, aCallerAction, cnTransferErrorResendInterval);
  end;
end;

procedure TTransferBfs.InternalBfLocalUseEvents(aCallerAction:ICallerAction; const aBfName:AnsiString; const aInfo:TTableBfInfo; const aIfExistsUseEvents:TUseTransferEvents; const aConnectionName:AnsiString; aUserInterface:IUnknown);
begin
  if assigned(aIfExistsUseEvents.OnCompleteTransfer) Then
    InternalSetTransferResultCompleteEvents(aIfExistsUseEvents.OnCompleteTransfer, aIfExistsUseEvents.UserData, nil, aBfName{, 0{TransferedSize}, 0{TransferErrorCount}, 0{TransferSpeed}, glConvertToTableBfLocation(InternalGetCachePathBf, aInfo.Path, aInfo.Filename, nil), aInfo.Commentary);
  if aIfExistsUseEvents.tpToSender Then
    InternalSetTransferResultSendPack(aConnectionName, aCallerAction, SendPackCompleteDownloadToVariant(aBfName{, 0{TransferedSize}, 0{TransferErrorCount}, 0{TransferSpeed}));
end;

function TTransferBfs.InternalBfLocalExists(aCallerAction:ICallerAction; const aBfName:AnsiString; {Out}aPInfo:PTableBfInfo; aIfExistsUseEvents:PUseTransferEvents; const aConnectionName:AnsiString; aUserInterface:IUnknown):boolean;
  var tmpInfo:TTableBfInfo;
begin
  //if not assigned(aCallerAction) then raise exception.create('aCallerAction is not assigned.');
  Result:=InternalBfIdToTableBfInfo(aBfName, aUserInterface, tmpInfo);
  if assigned(aPInfo) then aPInfo^:=tmpInfo;//передаю инфо
  if (Result)and(not tmpInfo.Transfering)and(assigned(aIfExistsUseEvents)) then begin//отправляю события
    InternalBfLocalUseEvents(aCallerAction, aBfName, tmpInfo, aIfExistsUseEvents^, aConnectionName, aUserInterface);
  end;
end;

function TTransferBfs.ITBfLocalExists(const aBfName:AnsiString; aCallerAction:ICallerAction; {Out}aPInfo:PTableBfInfo; aIfExistsUseEvents:PUseTransferEvents; const aConnectionName:AnsiString):boolean;
  var tmpLockOwner:Integer;
begin
  //if not assigned(aCallerAction) then raise exception.create('aCallerAction is not assigned.');
  tmpLockOwner:=InternalGetISync.ITGenerateLockOwner;
  InternalGetISync.ITSetLockWait(csllTransfer+aBfName, aCallerAction{.UserName}, tmpLockOwner, True, cnTransferLockWait, true);
  try
    Result:=InternalBfLocalExists(aCallerAction, aBfName, aPInfo, aIfExistsUseEvents, aConnectionName, nil);
  finally
    InternalGetISync.ITClearLockOwner(tmpLockOwner);
  end;
end;

function TTransferBfs.InternalTerminateAllTransferWithBfName(const aBfName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString):boolean;
  var tmpIVarsetDataView:IVarsetDataView;
      tmpIntIndex:Integer;
      tmpIUnknown:IUnknown;
      tmpTransferBf:ITransferBf;
begin
  result:=false;
  tmpIntIndex:=-1;
  while true do begin
    tmpIVarsetDataView:=FOpenBfs.ITViewNextGetOfIntIndex(tmpIntIndex);
    if tmpIntIndex=-1 then exit;
    tmpIUnknown:=tmpIVarsetDataView.ITData;
    if (not assigned(tmpIUnknown))or(tmpIUnknown.QueryInterface(ITransferBf, tmpTransferBf)<>S_OK)or(not assigned(tmpTransferBf)) then raise exception.createFmt(cserInternalError, ['Interface ''ITransferBf'' not found.']);
    if tmpTransferBf.BfName=aBfName then begin
      ITTransferTerminate(VarToStr(tmpIVarsetDataView.ITStrIndex), aCallerAction, aConnectionName);
      result:=true;
    end;
  end;
end;

function TTransferBfs.InternalExistsTransferWithBfName(const aBfName:AnsiString):boolean;
  var tmpIVarsetDataView:IVarsetDataView;
      tmpIntIndex:Integer;
      tmpIUnknown:IUnknown;
      tmpTransferBf:ITransferBf;
begin
  result:=false;
  tmpIntIndex:=-1;
  while true do begin
    tmpIVarsetDataView:=FOpenBfs.ITViewNextGetOfIntIndex(tmpIntIndex);
    if tmpIntIndex=-1 then exit;
    tmpIUnknown:=tmpIVarsetDataView.ITData;
    if (not assigned(tmpIUnknown))or(tmpIUnknown.QueryInterface(ITransferBf, tmpTransferBf)<>S_OK)or(not assigned(tmpTransferBf)) then raise exception.createFmt(cserInternalError, ['Interface ''ITransferBf'' not found.']);
    if tmpTransferBf.BfName=aBfName then begin
      result:=true;
      exit;
    end;
  end;
end;

function TTransferBfs.ITBfLocalDelete(const aBfName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString):boolean;
  var tmpLockOwner:Integer;
      tmpUserInterface:IUnknown;
      tmpInfo:TTableBfInfo;
begin
  InternalTerminateAllTransferWithBfName(aBfName, aCallerAction, aConnectionName);
  tmpLockOwner:=InternalGetISync.ITGenerateLockOwner;
  InternalGetISync.ITSetLockWait(csllTransfer+aBfName, aCallerAction, tmpLockOwner, true, cnTransferLockWait, true);
  try
    while InternalExistsTransferWithBfName(aBfName) do begin
      InternalGetISync.ITClearLockOwner(tmpLockOwner);
      try
        InternalTerminateAllTransferWithBfName(aBfName, aCallerAction, aConnectionName);
      finally
        InternalGetISync.ITSetLockWait(csllTransfer+aBfName, aCallerAction, tmpLockOwner, true, cnTransferLockWait, true);
      end;
    end;
    if not InternalBfLocalExists(aCallerAction, aBfName, @tmpInfo, nil, '', nil) then raise exception.createFmtHelp(cserBfNameNotExists, [aBfName], cnerBfNameNotExists);
    DeleteFile(glConvertToTableBfLocation(InternalGetCachePathBf, tmpInfo.Path, tmpInfo.FileName, nil));
    InternalDeleteTbfInfo(aBfName, tmpUserInterface);//в таблице/реестре
  finally
    InternalGetISync.ITClearLockOwner(tmpLockOwner);
  end;
  result:=true;
end;

function TTransferBfs.InternalReadBf(aTransferBf:ITransferBf; var aBfTransfer:TBfTransfer; Out aData:Variant):boolean;
  var tmpBytesRead:Cardinal;
      tmpPntr:Pointer;
begin
  try
    if SetFilePointer(aTransferBf.FileHandle, aBfTransfer.Pos, nil, FILE_BEGIN)=$FFFFFFFF then raise exception.createHelp(SysErrorMessage(GetLastError), cnerSetFilePointer);
    aData:=VarArrayCreate([0, aBfTransfer.TransferSize], varByte);
    tmpPntr:=VarArrayLock(aData);
    try
      if not ReadFile(aTransferBf.FileHandle, tmpPntr^, aBfTransfer.TransferSize, tmpBytesRead, nil) then raise exception.createHelp(SysErrorMessage(GetLastError), cnerReadFile);
      aBfTransfer.CheckSum:=InternalBuffToChecksum(tmpPntr, tmpBytesRead);
    finally
      varArrayUnlock(aData);
    end;
    //..
    Result:=aBfTransfer.TransferSize<>tmpBytesRead;
    if Result then begin
      aBfTransfer.TransferSize:=tmpBytesRead;
      varArrayRedim(aData, tmpBytesRead);
    end;
    aTransferBf.TransferPos:=aBfTransfer.Pos+aBfTransfer.TransferSize;//этот расчет позволяет вычислить процент перекачки на сервере. 
    aTransferBf.LastSessionTransferedSize{TransferedSize}:=aTransferBf.LastSessionTransferedSize+tmpBytesRead;
    aTransferBf.TransferSpeed:=DateTimeToTransferSpeed(aTransferBf.LastSessionBeginTime, Now, aTransferBf.LastSessionTransferedSize{TransferedSize});
  except on e:exception do begin e.message:='BfRead: '+e.message;raise;end;end;
end;

function TTransferBfs.InternalWriteBf(aTransferBf:ITransferBf; aBfTransfer:TBfTransfer; const aData:Variant):boolean;
  var tmpBytesWrite:Cardinal;
      tmpPntr:Pointer;
begin
  try
    if SetFilePointer(aTransferBf.FileHandle, aBfTransfer.Pos, nil, FILE_BEGIN)=$FFFFFFFF then raise exception.createHelp(SysErrorMessage(GetLastError), cnerSetFilePointer);
    tmpPntr:=VarArrayLock(aData);
    try
      if InternalBuffToChecksum(tmpPntr, aBfTransfer.TransferSize)<>aBfTransfer.CheckSum then raise exception.createHelp('Checksum error.', cnerChecksumError);
      if not WriteFile(aTransferBf.FileHandle, tmpPntr^, aBfTransfer.TransferSize, tmpBytesWrite, nil) then raise exception.createHelp(SysErrorMessage(GetLastError), cnerWriteFile);
      if tmpBytesWrite<>aBfTransfer.TransferSize then raise exception.createFmt(cserInternalError, ['TransferSize<>tmpBytesWrite']);
      aTransferBf.TransferPos:=aBfTransfer.Pos+aBfTransfer.TransferSize;//Утанавливаю Pos на начало непрочитанного блока(конец прочитанного).
      aTransferBf.TransferChecksum:=aTransferBf.TransferChecksum xor aBfTransfer.CheckSum;//вычисляю контрольную сумму всех перекаченных байт.
      aTransferBf.LastSessionTransferedSize:=aTransferBf.LastSessionTransferedSize+tmpBytesWrite;//Увеличиваю счетчик перекаченных байт в последнем соединении
      aTransferBf.TransferSpeed:=DateTimeToTransferSpeed(aTransferBf.LastSessionBeginTime, Now, aTransferBf.LastSessionTransferedSize);//Вычисляю скорость перекачки
    finally
      varArrayUnlock(aData);
    end;
    Result:=aTransferBf.TransferPos{(aBfTransfer.Pos+aBfTransfer.TransferSize)}>=aTransferBf.FileTotalSize;
  except on e:exception do begin
    e.message:='BfWrite: '+e.message;
    raise;
  end;end;
end;

function TTransferBfs.ITTransferTerminate(const aTransferName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString):boolean;
  var tmpTransferBf:ITransferBf;
begin//Надо все разбирать
  if not assigned(aCallerAction) then raise exception.createFmtHelp(cserInvalidValueOf, ['aCallerAction'], cnerInvalidValueOf);
  Result:=False;
  tmpTransferBf:=InternalTransferNameToITransferBf(aTransferName, vvmView, False);//Ищу перекачку в списке
  if not assigned(tmpTransferBf) then exit;//не нашел
  tmpTransferBf.ITSetTransferLockWait;
  try
    tmpTransferBf.ITLockWait(cnTransferLockWait);
    try//безопастность для aCallerAction тут не проверяется, она проверина раньше для команды tskADMTransferTerminate/tskMTTransferTerminate
      Result:=InternalTransferCancel(aTransferName, [icmIsTerminate, icmToDoOnResponder, icmSendNotificationForCaller], aCallerAction.UserName);//тут чистятся локи
    finally
      tmpTransferBf.ITUnlock;
    end;
  finally
    tmpTransferBf.ITFreeTransferLock;
    tmpTransferBf:=nil;
  end;
end;

function TTransferBfs.ITTransferTerminateByBfName(const aBfName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString):Boolean;
begin
  result:=InternalTerminateAllTransferWithBfName(aBfName, aCallerAction, aConnectionName);
end;

function TTransferBfs.ITReceiveTransferTerminated(aCallerAction:ICallerAction; const aTransferName, aTerminatorSysName:AnsiString):boolean;
  var tmpTransferBf:ITransferBf;
begin
  //Надо все разбирать
  if not assigned(aCallerAction) then raise exception.createFmtHelp(cserInvalidValueOf, ['aCallerAction'], cnerInvalidValueOf);
  Result:=False;
  tmpTransferBf:=InternalTransferNameToITransferBf(aTransferName, vvmView, False);//Ищу перекачку в списке
  if not assigned(tmpTransferBf) then Exit;//не нашел
  tmpTransferBf.ITSetTransferLockWait;
  try
    tmpTransferBf.ITLockWait(cnTransferLockWait);
    try
      try//Проверяю права.
        CompareSecurity(tmpTransferBf.CallerActionFirst.CallerSecurityContext, aCallerAction.CallerSecurityContext, [eqlUserName], true{aRaise});
      except on e:exception do begin
        e.HelpContext:=cnerAccessDenied;
        e.message:=Format(cserAccessDenied, [e.message]);
        raise;
      end;end;
      Result:=InternalTransferCancel(aTransferName, [icmIsTerminate, {icmToDoOnResponder, }icmSendNotificationForCaller], aTerminatorSysName);//тут чистятся локи
    finally
      tmpTransferBf.ITUnlock;
    end;
  finally
    tmpTransferBf.ITFreeTransferLock;
    tmpTransferBf:=nil;
  end;
end;

function TTransferBfs.ITReceiveTransferCanceled(aCallerAction:ICallerAction; const aTransferName:AnsiString):boolean;
  var tmpTransferBf:ITransferBf;
begin
  //Пришел Canceled. На это сообщение только пишу лог и ничего больше не трогаю.
  if not assigned(aCallerAction) then raise exception.createFmtHelp(cserInvalidValueOf, ['aCallerAction'], cnerInvalidValueOf);
  Result:=False;
  tmpTransferBf:=InternalTransferNameToITransferBf(aTransferName, vvmView, False);//Ищу перекачку в списке
  if not assigned(tmpTransferBf) then begin//не нашел
    aCallerAction.ITMessAdd(Now, Now, 'RcCled', 'Transfer '''+aTransferName+'''(no found) is canceled.', mecTransfer, mesInformation);
  end else begin
    aCallerAction.ITMessAdd(Now, tmpTransferBf.LastSessionBeginTime, 'RcCled', 'Transfer '''+aTransferName+'''/#'+tmpTransferBf.BfName+' is canceled.', mecTransfer, mesInformation);
    tmpTransferBf:=nil;
  end;
end;

function TTransferBfs.InternalGetISync:ISync;
begin
  if not assigned(FSync) then InternalGetITray.Query(ISync, FSync);
  result:=FSync;
end;

function TTransferBfs.InternalGetIEPointProperties:IEPointProperties;
begin
  if not assigned(FEPointProperties) then InternalGetITray.Query(IEPointProperties, FEPointProperties);
  result:=FEPointProperties;
end;

function TTransferBfs.InternalGetIThreadsPool:IThreadsPool;
begin
  if not assigned(FThreadsPool) then InternalGetITray.Query(IThreadsPool, FThreadsPool);
  result:=FThreadsPool;
end;

function TTransferBfs.InternalGetIAppCacheDir:IAppCacheDir;
begin
  if not assigned(FAppCacheDir) then InternalGetITray.Query(IAppCacheDir, FAppCacheDir);
  result:=FAppCacheDir;
end;

function TTransferBfs.InternalGetInitGUIDCount:Cardinal;
begin
  result:=inherited InternalGetInitGUIDCount+5;
end;

procedure TTransferBfs.InternalInitGUIDList;
  var tmpCount:Cardinal;
begin
  inherited InternalInitGUIDList;
  tmpCount:=inherited InternalGetInitGUIDCount;
  GUIDList^.aList[tmpCount]:=ISync;
  GUIDList^.aList[tmpCount+1]:=IAppCacheDir;
  GUIDList^.aList[tmpCount+2]:=IThreadsPool;
  GUIDList^.aList[tmpCount+3]:=IEPointProperties;
  GUIDList^.aList[tmpCount+4]:=IAppMessage;
end;

procedure TTransferBfs.InternalStart;
begin
  inherited InternalStart;
  InternalGetIThreadsPool.ITMIgnoreTaskCancel(tskMTBfCheckTransfer);
  InternalGetIThreadsPool.ITMTaskAdd(tskMTBfCheckTransfer, cnIntervalCheckTransfer, cnServerAction);
end;

procedure TTransferBfs.InternalStop;
begin
  inherited InternalStop;
  InternalGetIThreadsPool.ITMIgnoreTaskAdd(tskMTBfCheckTransfer);
end;

procedure TTransferBfs.InternalFinal;
begin
  inherited InternalFinal;
  InternalCloseAllBfs;
  FSync:=nil;
  FAppCacheDir:=nil;
  FThreadsPool:=nil;
  FEPointProperties:=nil;
end;

end.
