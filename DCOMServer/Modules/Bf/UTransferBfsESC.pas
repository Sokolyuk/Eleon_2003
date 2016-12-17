unit UTransferBfsESC;
  Модуль нормальный, но технология устарела. см. TransferDoc/TransferDocs/TransferDocManage/TransferBf
interface
  uses UTransferBfs, UTransferBfsTypes, UESCRegistryTypes, UTransferBfTypes, UBfTypes, UPackPDPlacesTypes, windows, UCallerTypes,
       UTransferBfsESCTypes;
type
  TTransferBfsESC=class(TTransferBfs, ITransferBfsESC)
  protected
    procedure InternalInit;override;
  protected
    FRegRootKey:HKEY;
    FRegKeyPath:AnsiString;
    function Get_RegRootKey:HKEY;virtual;
    function Get_RegKeyPath:AnsiString;virtual;
    procedure Set_RegRootKey(value:HKEY);virtual;
    procedure Set_RegKeyPath(const value:AnsiString);virtual;
  protected
    procedure InternalInitRegistry(var aESCRegistry:IESCRegistry);virtual;
    function InternalTableUpdateChecksum(const aBfName:AnsiString; aFileHandle:THandle; aChecksumDate:TDateTime; var aUserInterface:IUnknown):Integer;override;
    procedure InternalUpdateTableBfInfoAtBegin(var aUserInterface:IUnknown; aTransferBf:ITransferBf);override;
    function InternalBfIdToTableBfInfo(const aBfName:AnsiString; var aUserInterface:IUnknown; out aTableBfInfo:TTableBfInfo):boolean;override;
    function InternalDeleteTbfInfo(const aBfName:AnsiString; var aUserInterface:IUnknown):boolean;override;
    procedure InternalInsertTableBfInfoAtBegin(var aUserInterface:IUnknown; aTransferBf:ITransferBf);override;
    procedure InternalUpdateTableBfInfoAtProcess(var aUserInterface:IUnknown; aTransferBf:ITransferBf);override;
    procedure InternalUpdateTableBfInfoAtComplete(var aUserInterface:IUnknown; aTransferBf:ITransferBf);override;
    procedure InternalUpdateTableBfInfo(const aBfName:AnsiString; const aNewPath, aNewFileName:AnsiString; var aUserInterface:IUnknown);override;
    procedure InternalResponderNameToPlaces(const aConnectionName:AnsiString; const aResponderName:AnsiString; aPlaces:IPackPDPlaces);override;
    function InternalCheckResponderNameForDownload(const aResponderName, aConnectionName:AnsiString):AnsiString;override;
  public
    constructor create;
    destructor destroy;override;
    property RegRootKey:HKEY read Get_RegRootKey write Set_RegRootKey;
    property RegKeyPath:AnsiString read Get_RegKeyPath write Set_RegKeyPath;
  public
    function ITAddTransferDownload(const aBfName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString; aPTransferParam:PTransferParam; aPTransferProcessEvents:PTransferProcessEvents):AnsiString;override;
    function ITAddTransferParaDownload(const aBfName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString; aPTransferParam:PTransferParam; aPTransferProcessEvents:PTransferProcessEvents):AnsiString;virtual;
    function ITTransferCancel(const aTransferName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString; aCancelResponder:boolean):boolean;override;
    function ITTransferTerminate(const aTransferName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString):boolean;override;
    function ITReceiveBeginParaDownload(aCallerAction:ICallerAction; const aTransferName, aResponderTransferName:AnsiString; aFileTotalSize:Cardinal):Boolean{worked};virtual;
    function ITReceiveProcessParaDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString; aTransferedPos:Cardinal; aTransferErrorCount:Integer; aTransferSpeed:double):Boolean{worked};virtual;
    function ITReceiveCompleteParaDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString; aTransferErrorCount:Integer; aTransferSpeed:double):Boolean{worked};virtual;
    function ITReceiveErrorParaDownload(aCallerAction:ICallerAction; const aTransferName, aErrorMessage:AnsiString; aHelpContext:Integer; aCanceled:Boolean; aTransferErrorCount:Integer):Boolean{worked};virtual;
    function ITBfDelete(const aBfName:AnsiString; aWhere:TWhere; const aConnectionName:AnsiString; aCallerAction:ICallerAction):boolean;virtual;
  end;

implementation
  uses UESCRegistry, SysUtils, UErrorConsts, UNodeNameUtils, UPackCPTTypes, UPackCPT, UPackCPRTypes, UPackCPTaskTypes,
       UADMTypes, UEServerConnectionsTypes, UTrayConsts, UPackCPR, UPackPDTypes, UPackPD, UTransferConsts, UPackTypes,
       UEServerConnectionTypes, UTransferBfTaskImpUtils, USecurityUtils, USecurityTypes, UNodeNameConsts, UTransferBf,
       UAppMessageTypes, UBfConsts, variants;

constructor TTransferBfsESC.create;
begin
  inherited create;
  FRegRootKey:=HKEY_LOCAL_MACHINE;
  FRegKeyPath:='\Software\Eleon\Depot\Bf';
end;

destructor TTransferBfsESC.destroy;
begin
  inherited destroy;
end;

procedure TTransferBfsESC.InternalInitRegistry(var aESCRegistry:IESCRegistry);
begin
  if not assigned(aESCRegistry) then begin
    aESCRegistry:=TESCRegistry.create;
    aESCRegistry.Registry.RootKey:=FRegRootKey;
  end;
end;

function TTransferBfsESC.Get_RegRootKey:HKEY;  	
begin
  result:=FRegRootKey;
end;

function TTransferBfsESC.Get_RegKeyPath:AnsiString;
begin
  result:=FRegKeyPath;
end;

procedure TTransferBfsESC.Set_RegRootKey(value:HKEY);
begin
  FRegRootKey:=value;
end;

procedure TTransferBfsESC.Set_RegKeyPath(const value:AnsiString);
begin
  FRegKeyPath:=value;
end;

function TTransferBfsESC.InternalTableUpdateChecksum(const aBfName:AnsiString; aFileHandle:THandle; aChecksumDate:TDateTime; var aUserInterface:IUnknown):Integer;
begin
  try
    InternalInitRegistry(IESCRegistry(aUserInterface));
    if not IESCRegistry(aUserInterface).Registry.OpenKey(FRegKeyPath+'\'+aBfName, false) then raise exception.createFmtHelp(cserInternalError, ['Can''t OpenKey='''+FRegKeyPath+'\'+aBfName+''''], cnerInternalError);
    Result:=InternalRecalcChecksum(aFileHandle, $FFFFFFFF);
    IESCRegistry(aUserInterface).Registry.WriteDateTime('ChecksumDate', aChecksumDate);
    IESCRegistry(aUserInterface).Registry.WriteInteger('Checksum', result);
  except on e:exception do begin
    e.message:='ITblUpdateChecksum: '+e.message;
    raise;
  end;end;
end;

procedure TTransferBfsESC.InternalUpdateTableBfInfoAtBegin(var aUserInterface:IUnknown; aTransferBf:ITransferBf);
begin
  if not assigned(aTransferBf) then raise exception.create('TransferBf is not assigned.');
  InternalInitRegistry(IESCRegistry(aUserInterface));
  if not IESCRegistry(aUserInterface).Registry.OpenKey(FRegKeyPath+'\'+aTransferBf.BfName, true) then raise exception.createFmtHelp(cserInternalError, ['Can''t OpenKey='''+FRegKeyPath+'\'+aTransferBf.BfName+''''], cnerInternalError);
  IESCRegistry(aUserInterface).Registry.WriteString('Path', aTransferBf.TableBfDir);
  IESCRegistry(aUserInterface).Registry.WriteString('Filename', aTransferBf.TableBfName);
  IESCRegistry(aUserInterface).Registry.WriteInteger('Checksum', aTransferBf.TableBfChecksum);
  IESCRegistry(aUserInterface).Registry.WriteDateTime('ChecksumDate', aTransferBf.TableBfDate);
  IESCRegistry(aUserInterface).Registry.WriteInteger('BfType', aTransferBf.BfType);
  IESCRegistry(aUserInterface).Registry.WriteString('TransferSchedule', aTransferBf.TransferSchedule);
  IESCRegistry(aUserInterface).Registry.WriteString('Commentary', aTransferBf.TableBfCommentary);
  IESCRegistry(aUserInterface).Registry.WriteInteger('TransferPos', aTransferBf.TransferPos);
  IESCRegistry(aUserInterface).Registry.WriteInteger('TransferChecksum', aTransferBf.TransferChecksum);
  IESCRegistry(aUserInterface).Registry.WriteString('TransferResponder', aTransferBf.TransferResponder);
  IESCRegistry(aUserInterface).Registry.WriteInteger('TransferDirection', Integer(aTransferBf.TransferDirection));
end;

function TTransferBfsESC.InternalBfIdToTableBfInfo(const aBfName:AnsiString; var aUserInterface:IUnknown; out aTableBfInfo:TTableBfInfo):boolean;
begin
  try
    InternalInitRegistry(IESCRegistry(aUserInterface));
    result:=IESCRegistry(aUserInterface).Registry.OpenKey(FRegKeyPath+'\'+aBfName, false);
    if result then begin
      aTableBfInfo.Filename:=IESCRegistry(aUserInterface).Registry.ReadString('Filename');//Получаю имя
      if aTableBfInfo.Filename='' then raise exception.create('Invalid BfName=''''.');
      aTableBfInfo.Path:=IESCRegistry(aUserInterface).Registry.ReadString('Path');
      if (aTableBfInfo.Path<>'')and(aTableBfInfo.Path[Length(aTableBfInfo.Path)]<>'\') then aTableBfInfo.Path:=aTableBfInfo.Path+'\';
      if not IESCRegistry(aUserInterface).Registry.ValueExists('Checksum') then aTableBfInfo.Checksum:=0 else aTableBfInfo.Checksum:=IESCRegistry(aUserInterface).Registry.ReadInteger('Checksum');
      if not IESCRegistry(aUserInterface).Registry.ValueExists('ChecksumDate') then aTableBfInfo.ChecksumDate:=0 else aTableBfInfo.ChecksumDate:=IESCRegistry(aUserInterface).Registry.ReadDateTime('ChecksumDate');
      if not IESCRegistry(aUserInterface).Registry.ValueExists('Commentary') then aTableBfInfo.Commentary:='' else aTableBfInfo.Commentary:=IESCRegistry(aUserInterface).Registry.ReadString('Commentary');
      if not IESCRegistry(aUserInterface).Registry.ValueExists('BfType') then aTableBfInfo.BfType:=0 else aTableBfInfo.BfType:=IESCRegistry(aUserInterface).Registry.ReadInteger('BfType');
      if not IESCRegistry(aUserInterface).Registry.ValueExists('TransferSchedule') then aTableBfInfo.TransferSchedule:='' else aTableBfInfo.TransferSchedule:=IESCRegistry(aUserInterface).Registry.ReadString('TransferSchedule');
      aTableBfInfo.Transfering:=IESCRegistry(aUserInterface).Registry.ValueExists('TransferPos');
      if aTableBfInfo.Transfering then begin
        aTableBfInfo.TransferPos:=Cardinal(IESCRegistry(aUserInterface).Registry.ReadInteger('TransferPos'));
        aTableBfInfo.TransferChecksum:=IESCRegistry(aUserInterface).Registry.ReadInteger('TransferChecksum');
        aTableBfInfo.TransferResponder:=IESCRegistry(aUserInterface).Registry.ReadString('TransferResponder');
        aTableBfInfo.TransferDirection:=TTransferDirection(IESCRegistry(aUserInterface).Registry.ReadInteger('TransferDirection'));
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

function TTransferBfsESC.InternalDeleteTbfInfo(const aBfName:AnsiString; var aUserInterface:IUnknown):boolean;
begin
  InternalInitRegistry(IESCRegistry(aUserInterface));
  result:=IESCRegistry(aUserInterface).Registry.DeleteKey(FRegKeyPath+'\'+aBfName);
end;

procedure TTransferBfsESC.InternalInsertTableBfInfoAtBegin(var aUserInterface:IUnknown; aTransferBf:ITransferBf);
begin
  if not assigned(aTransferBf) then raise exception.create('TransferBf is not assigned.');
  InternalInitRegistry(IESCRegistry(aUserInterface));
  if not IESCRegistry(aUserInterface).Registry.OpenKey(FRegKeyPath+'\'+aTransferBf.BfName, true) then raise exception.createFmtHelp(cserInternalError, ['Can''t OpenKey='''+FRegKeyPath+'\'+aTransferBf.BfName+''''], cnerInternalError);
  IESCRegistry(aUserInterface).Registry.WriteString('Path', aTransferBf.TableBfDir);
  IESCRegistry(aUserInterface).Registry.WriteString('Filename', aTransferBf.TableBfName);
  IESCRegistry(aUserInterface).Registry.WriteInteger('Checksum', aTransferBf.TableBfChecksum);
  IESCRegistry(aUserInterface).Registry.WriteDateTime('ChecksumDate', aTransferBf.TableBfDate);
  IESCRegistry(aUserInterface).Registry.WriteInteger('BfType', aTransferBf.BfType);
  IESCRegistry(aUserInterface).Registry.WriteString('TransferSchedule', aTransferBf.TransferSchedule);
  IESCRegistry(aUserInterface).Registry.WriteString('Commentary', aTransferBf.TableBfCommentary);
  IESCRegistry(aUserInterface).Registry.WriteInteger('TransferPos', aTransferBf.TransferPos);
  IESCRegistry(aUserInterface).Registry.WriteInteger('TransferChecksum', aTransferBf.TransferChecksum);
  IESCRegistry(aUserInterface).Registry.WriteString('TransferResponder', aTransferBf.TransferResponder);
  IESCRegistry(aUserInterface).Registry.WriteInteger('TransferDirection', Integer(aTransferBf.TransferDirection));
end;

procedure TTransferBfsESC.InternalUpdateTableBfInfoAtProcess(var aUserInterface:IUnknown; aTransferBf:ITransferBf);
begin
  if not Assigned(aTransferBf) then raise exception.create('TransferBf is not assigned.');
  if not aTransferBf.Transfering then raise exception.create('Unable to UpdateAtProcess. Transfering is false.');
  InternalInitRegistry(IESCRegistry(aUserInterface));
  if not IESCRegistry(aUserInterface).Registry.OpenKey(FRegKeyPath+'\'+aTransferBf.BfName, false) then raise exception.createFmtHelp(cserInternalError, ['Can''t OpenKey='''+FRegKeyPath+'\'+aTransferBf.BfName+''''], cnerInternalError);
  IESCRegistry(aUserInterface).Registry.WriteInteger('TransferPos', aTransferBf.TransferPos);
  IESCRegistry(aUserInterface).Registry.WriteInteger('TransferChecksum', aTransferBf.TransferChecksum);
end;

procedure TTransferBfsESC.InternalUpdateTableBfInfoAtComplete(var aUserInterface:IUnknown; aTransferBf:ITransferBf);
begin
  if not assigned(aTransferBf) then raise exception.create('TransferBf is not assigned.');
  InternalInitRegistry(IESCRegistry(aUserInterface));
  if not IESCRegistry(aUserInterface).Registry.OpenKey(FRegKeyPath+'\'+aTransferBf.BfName, false) then exit;
  IESCRegistry(aUserInterface).Registry.DeleteValue('TransferPos');
  IESCRegistry(aUserInterface).Registry.DeleteValue('TransferChecksum');
  IESCRegistry(aUserInterface).Registry.DeleteValue('TransferResponder');
  IESCRegistry(aUserInterface).Registry.DeleteValue('TransferDirection');
end;

procedure TTransferBfsESC.InternalUpdateTableBfInfo(const aBfName:AnsiString; const aNewPath, aNewFileName:AnsiString; var aUserInterface:IUnknown);
begin
  InternalInitRegistry(IESCRegistry(aUserInterface));
  if not IESCRegistry(aUserInterface).Registry.OpenKey(FRegKeyPath+'\'+aBfName, false) then raise exception.createFmtHelp(cserInternalError, ['Can''t OpenKey='''+FRegKeyPath+'\'+aBfName+''''], cnerInternalError);
  IESCRegistry(aUserInterface).Registry.WriteString('Path', aNewPath);
  IESCRegistry(aUserInterface).Registry.WriteString('Filename', aNewFileName);
end;

procedure TTransferBfsESC.InternalResponderNameToPlaces(const aConnectionName:AnsiString; const aResponderName:AnsiString; aPlaces:IPackPDPlaces);
begin
  TwoNodeNameToPDPlaces(InternalGetIEPointProperties.NodeName[@aConnectionName], aResponderName, aPlaces);
end;

function TTransferBfsESC.ITAddTransferParaDownload(const aBfName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString; aPTransferParam:PTransferParam; aPTransferProcessEvents:PTransferProcessEvents):AnsiString;
  function LocalTransferParam:PTransferParam;
  begin
    if assigned(aPTransferParam) then Result:=aPTransferParam else Result:=@cnTransferParam;
  end;
  var tmpTransferBf:ITransferBf;
      tmpPackPD:IPackPD;
      tmpPackCPT:IPackCPT;
      tmpEServerConnection:IEServerConnection;
      tmpTransferParam:TTransferParam;
      tmpStartTime:TDateTime;
begin
  try
    tmpStartTime:=now;
    if not assigned(aCallerAction) then raise exception.create('CallerAction not assigned.');
    tmpEServerConnection:=IEServerConnections(InternalGetITray.Query(IEServerConnections)).ViewOfName(aConnectionName);
    tmpTransferBf:=TTransferBf.Create;
    tmpTransferBf.LockOwner:=InternalGetISync.ITGenerateLockOwner;//tmpLockOwner:=InternalGetISync.ITGenerateLockOwner;//Ставлю приватный лок, что бы не качался один файл несколько раз.//InternalGetISync.ITSetLockWait(csllTransfer+aBfName, aCallerAction, tmpLockOwner, True, cnTransferLockWait, true);
    tmpTransferBf.CallerActionAdd(aCallerAction, false);
    tmpTransferBf.BfName:=aBfName;
    tmpTransferBf.ITSetTransferLockWait;
    try
      tmpTransferBf.ITLockWait(cnTransferLockWait);
      try
        tmpTransferBf.ConnectionName:=aConnectionName;
        tmpTransferBf.TransferParam:=LocalTransferParam^;
        if assigned(aPTransferProcessEvents) then tmpTransferBf.TransferProcessEvents:=aPTransferProcessEvents^;
        tmpTransferBf.TransferMode:=trmParaDownload;
        tmpTransferBf.TransferStep:=trsReceiveParaDownload;
        tmpTransferBf.LastAccessTime:=Now;//Сохраняю время последнего обращения
        tmpTransferBf.LastSessionBeginTime:=now;
        tmpTransferBf.BeginTime:=now;
        result:=InternalCreateSessionStrId(aBfName);//Генерирую TransferName
        tmpTransferBf.TransferName:=result;
        FOpenBfs.ITPushVOfStrIndex(Result, tmpTransferBf);
        tmpTransferBf.Active:=True;//Активизирую
        aCallerAction.ITMessAdd(Now, tmpStartTime, 'AdPaDn', 'Add paradownload(client) '''+Result+'''/#'+aBfName+'.', mecTransfer, mesInformation);
        //..
        tmpPackPD:=TPackPD.Create;
        tmpPackPD.PDID:=Result;//'BfParaDownloadAdd_'+aBfName;
        tmpPackPD.PDOptions:=[pdoWithNotificationOfError]+[pdoNoTransform]+[pdoNoPutOnReSending];
        tmpPackPD.Places.CurrNum:=0;
        tmpPackPD.Places.AddPlace(pdsCommandOnID, tmpEServerConnection.ESCServerInfo.AsmId);
        tmpPackCPT:=TPackCPT.Create;//Param:[0]-varInteger(ID); [1]-varOleStr:(DownloadBfName); [2]-varBoolean:(TransferAuto); [3]-varBoolean:(TransferProcessToSender); [4]-varInteger:(TransferFrom); [5]-varDate:(FileDate{для докачки})
        //[0]-varInteger(ID);
        //[1]-varOleStr:(DownloadBfName);
        //[2]-varBoolean:(TransferAuto);
        //[3]-varBoolean:(TransferProcessToSender);
        //[4]-varInteger:(TransferFrom);
        //[5]-varDate:(FileDate{для докачки})
        //tmpPackCPT.CPID:=Result;
        tmpTransferParam:=aPTransferParam^;
        tmpTransferParam.TransferProcessToSender:=true;
        tmpTransferParam.TransferResponder:='';
        tmpTransferParam.Path:='';
        tmpTransferParam.FileName:='';
        tmpPackCPT.CPTasks.TaskAdd(tskADMBfAddTransferDownload, ParamAddDnToVariant(aBfName, tmpTransferParam), {RouteParam}Result, -1);
        tmpPackCPT.CPTOptions:=[{ctoReturnParamsIfError-нужно для разбора}];
        tmpPackPD.DataAsIPack:=tmpPackCPT;
        //tmpEServerConnection.EPackASync(tmpPackPD.AsVariant);
        InternalSendPackPD(aConnectionName, tmpPackPD, aCallerAction);
      finally
        tmpTransferBf.ITUnlock;
      end;
    finally
      tmpTransferBf.ITFreeTransferLock
    end;
  except on e:exception do begin e.message:='ITAddTransferParaDownload: '+e.message;raise;end;end;
end;

function TTransferBfsESC.ITAddTransferDownload(const aBfName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString; aPTransferParam:PTransferParam; aPTransferProcessEvents:PTransferProcessEvents):AnsiString;
  Var tmpPackCPT:IPackCPT;
      tmpIfAccessibleUseEvents:TUseTransferEvents;
      tmpPack:OleVariant;
      tmpPackCPR:IPackCPR;
      tmpIntIndex:Integer;
      tmpIPackCPTask:IPackCPTask;
      tmpExists, tmpTransfering:Boolean;
      //tmpHelpContext:integer;
      //tmpMessage:AnsiString;
      tmpIEServerConnection:IEServerConnection;
      tmpTbfInfo:TTableBfInfo;
begin
  Result:='';//Устанавливаю результат-"не добавил"
  FillChar(tmpIfAccessibleUseEvents, SizeOf(tmpIfAccessibleUseEvents), 0);//Уже установилось - tmpIfAccessibleUseEvents.tpToSender:=False;
  if assigned(aPTransferProcessEvents) then begin
    tmpIfAccessibleUseEvents.UserData:=aPTransferProcessEvents^.UserData;
    tmpIfAccessibleUseEvents.OnCompleteTransfer:=aPTransferProcessEvents^.OnCompleteTransfer
  end;
  if not((InternalBfLocalExists(aCallerAction, aBfName, @tmpTbfInfo, @tmpIfAccessibleUseEvents, aConnectionName, nil))and(not tmpTbfInfo.Transfering)) then begin//На локальной машине нет такого блоба. Ищу его на локальном сервере.ITBfLocalExists(aBfName, aCallerAction, nil, @tmpIfAccessibleUseEvents, aConnectionName)
    tmpIEServerConnection:=IEServerConnections(InternalGetITray.Query(IEServerConnections)).ViewOfName(aConnectionName);
    if not tmpIEServerConnection.Authorized then raise exception.create('EServerConnection not authorized.');
    if not tmpIEServerConnection.ESCServerInfo.Loaded then tmpIEServerConnection.LoadServerInfo;
    if not assigned(aCallerAction) then Raise Exception.Create('aCallerAction is not assigned.');
    tmpPackCPT:=TPackCPT.Create;
    try//Param:[0]-varInteger(ID); [1]-varOleStr:(DownloadBfName); [2]-varBoolean:(TransferAuto); [3]-varBoolean:(TransferProcessToSender); [4]-varInteger:(TransferFrom); [5]-varDate:(FileDate{для докачки})
      tmpPackCPT.CPTasks.TaskAdd(tskADMBfExists, ParamLocalExistsToVariant(aBfName), aBfName{RouteParam}, -1);
      tmpPack:=tmpPackCPT.AsVariant;
      tmpIEServerConnection.EPackSync(tmpPack);
    finally
      tmpPackCPT:=nil;
    end;
    tmpExists:=false;//от варнингов
    tmpPackCPR:=TPackCPR.Create;
    try
      tmpPackCPR.AsVariant:=tmpPack;
      tmpIntIndex:=-1;
      tmpIPackCPTask:=tmpPackCPR.CPTasks.ViewNext(tmpIntIndex);
      if (not assigned(tmpIPackCPTask))Or(tmpIPackCPTask.Task<>tskADMBfExists) then raise exception.create('Invalid CPR from local server for tskADMBfExists.');
      tmpPackCPR.CPErrors.CheckError(tmpIPackCPTask.Step, nil{@tmpMessage}, nil{@tmpHelpContext}, false);
      try
        VariantToResultLocalExists(tmpIPackCPTask.Param, tmpExists, tmpTransfering);
      except
        on e:exception do begin e.message:='Invalid CPR.Param from local server for tskADMBfExists: '''+e.message+'''.';Raise;end;
      end;
    finally
      tmpPackCPR:=nil;
    end;
    if (tmpExists)and(not tmpTransfering) then begin//есть на ближнем сервере
      result:=inherited ITAddTransferDownload(aBfName, aCallerAction, aConnectionName, aPTransferParam, aPTransferProcessEvents);
    end else begin//нет на ближнем сервере, надо качать с дальнего
      result:=ITAddTransferParaDownload(aBfName, aCallerAction, aConnectionName, aPTransferParam, aPTransferProcessEvents);
    end;
  end;
end;

(*function TTransferBfsESC.ITReceiveAddParaDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString; const aResponderTransferName:AnsiString):Boolean{worked};
  var tmpTransferBf:ITransferBf;
begin
  Result:=False;//от варнингов
  try
    if not assigned(aCallerAction) then raise exception.createFmtHelp(cserInvalidValueOf, ['aCallerAction'], cnerInvalidValueOf);
    tmpTransferBf:=InternalTransferNameToITransferBf(aTransferName, vvmView, False);//Ищу перекачку в списке
    if not assigned(tmpTransferBf) then Exit;//не нашел
    //..
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
        if tmpTransferBf.TransferMode<>trmParaDownload then raise exception.createHelp(cserWrongModeOfTransfer, cnerWrongModeOfTransfer);
        //if tmpTransferBf.TransferStep<>trsReceiveParaDownload then raise exception.createHelp(cserWrongStepOfTransfer, cnerWrongStepOfTransfer);
        tmpTransferBf.LastAccessTime:=now;
        tmpTransferBf.ResponderTransferName:=aResponderTransferName;
        tmpTransferBf.TransferStep:=trsReceiveParaAddDownload;
        Result:=InternalSetTransferResult(tmpTransferBf, srsAddDownload, True{raise});
      finally
        tmpTransferBf.ITUnlock;
      end;
    finally
      tmpTransferBf.ITFreeTransferLock;
    end;
  except on e:exception do begin
    e.message:='RcAdPaDn: '+e.message;//try InternalSetTransferError(tmpTransferBf, aTransferName, e.message, E.HelpContext, True);except end;
    raise;
  end;end;
end;(**)

function TTransferBfsESC.ITReceiveBeginParaDownload(aCallerAction:ICallerAction; const aTransferName, aResponderTransferName:AnsiString; aFileTotalSize:Cardinal):Boolean{worked};
  Var tmpTransferBf:ITransferBf;
begin
  Result:=False;//от варнингов
  try
    if not assigned(aCallerAction) then raise exception.createFmtHelp(cserInvalidValueOf, ['aCallerAction'], cnerInvalidValueOf);
    tmpTransferBf:=InternalTransferNameToITransferBf(aTransferName, vvmView, False);//Ищу перекачку в списке
    if not assigned(tmpTransferBf) then Exit;//не нашел
    //..
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
        if tmpTransferBf.TransferMode<>trmParaDownload then raise exception.createHelp(cserWrongModeOfTransfer, cnerWrongModeOfTransfer);
        //if tmpTransferBf.TransferStep<>trsReceiveParaAddDownload then raise exception.createHelp(cserWrongStepOfTransfer, cnerWrongStepOfTransfer);
        tmpTransferBf.LastAccessTime:=now;
        tmpTransferBf.FileTotalSize:=aFileTotalSize;
        tmpTransferBf.ResponderTransferName:=aResponderTransferName;
        Result:=InternalSetTransferResult(tmpTransferBf, srsBeginDownload, true);
        tmpTransferBf.TransferStep:=trsReceiveParaBeginDownload;
      finally
        tmpTransferBf.ITUnlock;
      end;
    finally
      tmpTransferBf.ITFreeTransferLock;
    end;
  except on e:exception do begin
    e.message:='RcBgPaDn: '+e.message;//try InternalSetTransferError(tmpTransferBf, aTransferName, e.message, E.HelpContext, True);except end;
    raise;
  end;end;
end;

function TTransferBfsESC.ITReceiveProcessParaDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString; aTransferedPos:Cardinal; aTransferErrorCount:Integer; aTransferSpeed:double):Boolean{worked};
  Var tmpTransferBf:ITransferBf;
begin
  Result:=False;//от варнингов
  try
    if not assigned(aCallerAction) then raise exception.createFmtHelp(cserInvalidValueOf, ['aCallerAction'], cnerInvalidValueOf);
    tmpTransferBf:=InternalTransferNameToITransferBf(aTransferName, vvmView, False);//Ищу перекачку в списке
    if not assigned(tmpTransferBf) then Exit;//не нашел
    //..
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
        if tmpTransferBf.TransferMode<>trmParaDownload then raise exception.createHelp(cserWrongModeOfTransfer, cnerWrongModeOfTransfer);
        //if tmpTransferBf.TransferStep<>trsReceiveParaBeginDownload then raise exception.createHelp(cserWrongStepOfTransfer, cnerWrongStepOfTransfer);
        tmpTransferBf.LastAccessTime:=now;
        tmpTransferBf.TransferStep:=trsReceiveParaProcessDownload;
        tmpTransferBf.TransferPos:=aTransferedPos;
        tmpTransferBf.TransferErrorCount:=aTransferErrorCount;
        tmpTransferBf.TransferSpeed:=aTransferSpeed;
        result:=InternalSetTransferResult(tmpTransferBf, srsProcessDownload, True);
      finally
        tmpTransferBf.ITUnlock;
      end;
    finally
      tmpTransferBf.ITFreeTransferLock;
    end;
  except on e:exception do begin
    e.message:='RcPrPaDn: '+e.message;//InternalSetTransferError(tmpTransferBf, aTransferName, e.message, E.HelpContext, True);
    raise;
  end;end;
end;

function TTransferBfsESC.ITReceiveCompleteParaDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString; aTransferErrorCount:Integer; aTransferSpeed:double):Boolean{worked};
  var tmpTransferBf:ITransferBf;
      tmpTransferProcessEvents:TTransferProcessEvents;
      tmpTransferParam:TTransferParam;
begin
  Result:=False;//от варнингов
  try
    if not assigned(aCallerAction) then raise exception.createFmtHelp(cserInvalidValueOf, ['aCallerAction'], cnerInvalidValueOf);
    tmpTransferBf:=InternalTransferNameToITransferBf(aTransferName, vvmView, False);//Ищу перекачку в списке
    if not assigned(tmpTransferBf) then Exit;//не нашел
    //..
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
        if tmpTransferBf.TransferMode<>trmParaDownload then raise exception.createHelp(cserWrongModeOfTransfer, cnerWrongModeOfTransfer);
        //if tmpTransferBf.TransferStep<>trsReceiveParaProcessDownload then raise exception.createHelp(cserWrongStepOfTransfer, cnerWrongStepOfTransfer);
        tmpTransferBf.LastAccessTime:=now;
        tmpTransferBf.TransferStep:=trsReceiveParaCompleteDownload;
        tmpTransferBf.TransferPos:=0;//чищу
        tmpTransferBf.TransferErrorCount:=aTransferErrorCount;
        tmpTransferBf.TransferSpeed:=aTransferSpeed;
        result:=InternalSetTransferResult(tmpTransferBf, srsCompleteDownload, True);
        //..
        tmpTransferProcessEvents:=tmpTransferBf.TransferProcessEvents;
        tmpTransferParam:=tmpTransferBf.TransferParam;
        inherited InternalITAddTransferDownload(tmpTransferBf, tmpTransferBf.BfName, tmpTransferBf.CallerActionFirst, tmpTransferBf.ConnectionName, @tmpTransferParam, @tmpTransferProcessEvents);
        result:=InternalSetTransferResult(tmpTransferBf, srsProcessDownload, True);
      finally
        tmpTransferBf.ITUnlock;
      end;
    finally
      tmpTransferBf.ITFreeTransferLock;
    end;
  except on e:exception do begin
    e.message:='RcCmPaDn: '+e.message;//InternalSetTransferError(tmpTransferBf, aTransferName, e.message, E.HelpContext, True);
    raise;
  end;end;
end;

function TTransferBfsESC.ITReceiveErrorParaDownload(aCallerAction:ICallerAction; const aTransferName, aErrorMessage:AnsiString; aHelpContext:Integer; aCanceled:Boolean; aTransferErrorCount:Integer):Boolean{worked};
  var tmpTransferBf:ITransferBf;
begin
  Result:=False;//от варнингов
  try
    if not assigned(aCallerAction) then raise exception.createFmtHelp(cserInvalidValueOf, ['aCallerAction'], cnerInvalidValueOf);
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
        if not tmpTransferBf.Active then raise exception.createHelp(cserTransferIsCanceled, cnerTransferIsCanceled);
        tmpTransferBf.LastAccessTime:=now;
        tmpTransferBf.TransferErrorCount:=aTransferErrorCount;
        result:=InternalSetTransferError(tmpTransferBf, aTransferName, aErrorMessage, aHelpContext, false, true, nil);
      finally
        tmpTransferBf.ITUnlock;
      end;
    finally
      tmpTransferBf.ITFreeTransferLock;
    end;
  except on e:exception do begin
    e.message:='RcErPaDn: '+e.message;//InternalSetTransferError(tmpTransferBf, aTransferName, e.message, E.HelpContext, True);
    raise;
  end;end;
end;

function TTransferBfsESC.InternalCheckResponderNameForDownload(const aResponderName, aConnectionName:AnsiString):AnsiString;
  var tmpEServerConnection:IEServerConnection;
begin
  tmpEServerConnection:=IEServerConnections(InternalGetITray.Query(IEServerConnections)).ViewOfName(aConnectionName);
  if not tmpEServerConnection.Active then raise exception.create('EServerConnection not active.');
  if not tmpEServerConnection.ESCServerInfo.Loaded then tmpEServerConnection.LoadServerInfo;
  if aResponderName='' then Result:=csNodePGS+csNodeDelimiter+csNodeEMS+csValueDelimiter+IntToStr(tmpEServerConnection.ESCServerInfo.NodeId) else Result:=aResponderName;
end;

procedure TTransferBfsESC.InternalInit;
  var tmpESCRegistry:IESCRegistry;
begin
  inherited InternalInit;
  InternalInitRegistry(tmpESCRegistry);
  if (tmpESCRegistry.Registry.OpenKey(FRegKeyPath, false))and(tmpESCRegistry.Registry.ValueExists(csRegValueCacheDirBf)) then begin
    FCacheDirBf:=tmpESCRegistry.Registry.ReadString(csRegValueCacheDirBf);
  end else begin
    if not tmpESCRegistry.Registry.OpenKey(FRegKeyPath, true) then raise exception.create('Can''t Open/CreateKey='''+FRegKeyPath+'''');
    FCacheDirBf:=InternalGetIAppCacheDir.CacheDir+csBfCacheSubDir;
    tmpESCRegistry.Registry.WriteString(csRegValueCacheDirBf, FCacheDirBf);
  end;
end;

function TTransferBfsESC.ITBfDelete(const aBfName:AnsiString; aWhere:TWhere; const aConnectionName:AnsiString; aCallerAction:ICallerAction):boolean;
  var tmpEServerConnection:IEServerConnection;
      tmpPackCPT:IPackCPT;
      tmpPackCPR:IPackCPR;
      tmpPack:OleVariant;
      tmpIntIndex:Integer;
      tmpIPackCPTask:IPackCPTask;
      tmpPackPD:IPackPD;
begin
  case aWhere of
    wreESC:ITBfLocalDelete(aBfName, aCallerAction, aConnectionName);
    wreEMS:begin
      tmpEServerConnection:=IEServerConnections(InternalGetITray.Query(IEServerConnections)).ViewOfName(aConnectionName);
      if not tmpEServerConnection.Authorized then raise exception.create('EServerConnection not authorized.');
      tmpPackCPT:=TPackCPT.Create;
      try//Param:[0]-varInteger(ID); [1]-varOleStr:(DownloadBfName); [2]-varBoolean:(TransferAuto); [3]-varBoolean:(TransferProcessToSender); [4]-varInteger:(TransferFrom); [5]-varDate:(FileDate{для докачки})
        tmpPackCPT.CPTasks.TaskAdd(tskADMBfLocalDelete, ParamLocalDeleteToVariant(aBfName), unassigned{aBfName{RouteParam}, -1);
        tmpPack:=tmpPackCPT.AsVariant;
        tmpEServerConnection.EPackSync(tmpPack);
      finally
        tmpPackCPT:=nil;
      end;
      tmpPackCPR:=TPackCPR.Create;
      try
        tmpPackCPR.AsVariant:=tmpPack;
        tmpIntIndex:=-1;
        tmpIPackCPTask:=tmpPackCPR.CPTasks.ViewNext(tmpIntIndex);
        if (not assigned(tmpIPackCPTask))Or(tmpIPackCPTask.Task<>tskADMBfLocalDelete) then raise exception.create('Invalid CPR from local server for tskADMBfLocalDelete.');
        tmpPackCPR.CPErrors.CheckError(tmpIPackCPTask.Step, nil, nil, true);
        try
          VariantToResultLocalDelete(tmpIPackCPTask.Param, result);
        except
          on e:exception do begin e.message:='Invalid CPR.Param from local server for tskADMBfLocalDelete: '''+e.message+'''.';raise;end;
        end;
      finally
        tmpPackCPR:=nil;
      end;
    end;
    wrePGS:begin
      tmpEServerConnection:=IEServerConnections(InternalGetITray.Query(IEServerConnections)).ViewOfName(aConnectionName);
      if not tmpEServerConnection.Authorized then raise exception.create('EServerConnection not authorized.');
      if not tmpEServerConnection.ESCServerInfo.Loaded then tmpEServerConnection.LoadServerInfo;
      if not assigned(aCallerAction) then Raise Exception.Create('aCallerAction is not assigned.');
      tmpPackPD:=TPackPD.Create;
      tmpPackPD.PDID:='Delete#'+aBfName;
      tmpPackPD.PDOptions:=[pdoWithNotificationOfError]+[pdoNoTransform]+[pdoNoPutOnReSending];
      tmpPackPD.Places.CurrNum:=0;
      tmpPackPD.Places.AddPlace(pdsCommandOnID, tmpEServerConnection.ESCServerInfo.AsmId);
      tmpPackPD.Places.AddPlace(pdsCommandOnBridge, tmpEServerConnection.ESCServerInfo.NodeId);
      tmpPackCPT:=TPackCPT.Create;
      tmpPackCPT.CPTasks.TaskAdd(tskADMBfLocalDelete, ParamLocalDeleteToVariant(aBfName), unassigned, -1);
      tmpPackPD.DataAsIPack:=tmpPackCPT;
      InternalSendPackPD(aConnectionName, tmpPackPD, aCallerAction);
      result:=true;
    end;
  else
    raise exception.createFmtHelp(cserInternalError, ['aWhere='+IntToStr(Integer(aWhere))], cnerInternalError);
  end;
end;

function TTransferBfsESC.ITTransferCancel(const aTransferName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString; aCancelResponder:boolean):boolean;
  var tmpTransferBf:ITransferBf;
      tmpEServerConnection:IEServerConnection;
      tmpPackCPT:IPackCPT;
      tmpPackCPR:IPackCPR;
      tmpPack:OleVariant;
      tmpIntIndex:Integer;
      tmpIPackCPTask:IPackCPTask;
begin
  Result:=false;
  tmpTransferBf:=InternalTransferNameToITransferBf(aTransferName, vvmView, False);//Ищу перекачку в списке
  if not assigned(tmpTransferBf) then Exit;//не нашел
  tmpTransferBf.ITSetTransferLockWait;
  try
    tmpTransferBf.ITLockWait(cnTransferLockWait);
    try
      case tmpTransferBf.TransferMode of
        trmParaDownload, trmParaUpload:begin
          tmpEServerConnection:=IEServerConnections(InternalGetITray.Query(IEServerConnections)).ViewOfName(aConnectionName);
          if not tmpEServerConnection.Authorized then raise exception.create('EServerConnection not authorized.');
          if not assigned(aCallerAction) then Raise Exception.Create('aCallerAction is not assigned.');
          tmpPackCPT:=TPackCPT.Create;
          try//Param:[0]-varInteger(ID); [1]-varOleStr:(DownloadBfName); [2]-varBoolean:(TransferAuto); [3]-varBoolean:(TransferProcessToSender); [4]-varInteger:(TransferFrom); [5]-varDate:(FileDate{для докачки})
            tmpPackCPT.CPTasks.TaskAdd(tskADMBfTransferCancel, ParamTransferCancelToVariant(tmpTransferBf.ResponderTransferName, true), unassigned{aBfName{RouteParam}, -1);
            tmpPack:=tmpPackCPT.AsVariant;
            tmpEServerConnection.EPackSync(tmpPack);
          finally
            tmpPackCPT:=nil;
          end;
          tmpPackCPR:=TPackCPR.Create;
          try
            tmpPackCPR.AsVariant:=tmpPack;
            tmpIntIndex:=-1;
            tmpIPackCPTask:=tmpPackCPR.CPTasks.ViewNext(tmpIntIndex);
            if (not assigned(tmpIPackCPTask))Or(tmpIPackCPTask.Task<>tskADMBfTransferCancel) then raise exception.create('Invalid CPR from local server for tskADMBfTransferCancel.');
            tmpPackCPR.CPErrors.CheckError(tmpIPackCPTask.Step, nil, nil, true);
            try
              VariantToResultTransferCancel(tmpIPackCPTask.Param, result);
            except
              on e:exception do begin e.message:='Invalid CPR.Param from local server for tskADMBfTransferCancel: '''+e.message+'''.';raise;end;
            end;
          finally
            tmpPackCPR:=nil;
          end;
        end;
      else
        result:=inherited ITTransferCancel(aTransferName, aCallerAction, aConnectionName, aCancelResponder);
      end;
    finally
      tmpTransferBf.ITUnlock;
    end;
  finally
    tmpTransferBf.ITFreeTransferLock;
  end;
end;

function TTransferBfsESC.ITTransferTerminate(const aTransferName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString):boolean;
  var tmpTransferBf:ITransferBf;
      tmpEServerConnection:IEServerConnection;
      tmpPackCPT:IPackCPT;
      tmpPackCPR:IPackCPR;
      tmpPack:OleVariant;
      tmpIntIndex:Integer;
      tmpIPackCPTask:IPackCPTask;
begin
  if not assigned(aCallerAction) then raise exception.createFmtHelp(cserInvalidValueOf, ['aCallerAction'], cnerInvalidValueOf);
  tmpTransferBf:=InternalTransferNameToITransferBf(aTransferName, vvmView, False);//Ищу перекачку в списке
  if not assigned(tmpTransferBf) then exit;//не нашел
  tmpTransferBf.ITSetTransferLockWait;
  try
    tmpTransferBf.ITLockWait(cnTransferLockWait);
    try
      try
        case tmpTransferBf.TransferMode of
          trmParaDownload, trmParaUpload:begin
            if tmpTransferBf.ResponderTransferName<>'' then begin
              tmpEServerConnection:=IEServerConnections(InternalGetITray.Query(IEServerConnections)).ViewOfName(aConnectionName);
              if not tmpEServerConnection.Authorized then raise exception.create('EServerConnection not authorized.');
              if not assigned(aCallerAction) then Raise Exception.Create('aCallerAction is not assigned.');
              tmpPackCPT:=TPackCPT.Create;
              try//Param:[0]-varInteger(ID); [1]-varOleStr:(DownloadBfName); [2]-varBoolean:(TransferAuto); [3]-varBoolean:(TransferProcessToSender); [4]-varInteger:(TransferFrom); [5]-varDate:(FileDate{для докачки})
                tmpPackCPT.CPTasks.TaskAdd(tskADMBfTransferTerminate, ParamTransferTerminateToVariant(tmpTransferBf.ResponderTransferName), unassigned{aBfName{RouteParam}, -1);
               tmpPack:=tmpPackCPT.AsVariant;
               tmpEServerConnection.EPackSync(tmpPack);
              finally
                tmpPackCPT:=nil;
              end;
              tmpPackCPR:=TPackCPR.Create;
              try
                tmpPackCPR.AsVariant:=tmpPack;
                tmpIntIndex:=-1;
                tmpIPackCPTask:=tmpPackCPR.CPTasks.ViewNext(tmpIntIndex);
                if (not assigned(tmpIPackCPTask))Or(tmpIPackCPTask.Task<>tskADMBfTransferTerminate) then raise exception.create('Invalid CPR from local server for tskADMBfTransferTerminate.');
                tmpPackCPR.CPErrors.CheckError(tmpIPackCPTask.Step, nil, nil, true);
                try
                  VariantToResultTransferTerminate(tmpIPackCPTask.Param, result);
                except
                  on e:exception do begin e.message:='Invalid CPR.Param from local server for tskADMBfTransferTerminate: '''+e.message+'''.';raise;end;
                end;
              finally
                tmpPackCPR:=nil;
              end;
            end;
          end;
        end;
      finally
        result:=inherited ITTransferTerminate(aTransferName, aCallerAction, aConnectionName);
      end;  
    finally
      tmpTransferBf.ITUnlock;
    end;
  finally
    tmpTransferBf.ITFreeTransferLock;
  end;
end;

end.
