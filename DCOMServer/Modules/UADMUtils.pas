//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UADMUtils;

interface
  uses UADMTypes;

  function glADMTaskToStr(const aADMTask:TADMTask):AnsiString;
  function glStrToADMTask(const aStr:AnsiString; aIfFailThenRaise:Boolean=False):TADMTask;
//- - - tskADMPackIsLost - - -
  function ResultPackIsLostToVariant(aOnMessageLost, aOnPackLost:Integer):Variant;
  procedure ResultVariantToPackIsLost(const aParams:Variant; out aOnMessageLost, aOnPackLost:Integer);

implementation
  uses Sysutils, UADMConsts, Variants;
function glADMTaskToStr(const aADMTask:TADMTask):AnsiString;
begin
  case aADMTask of
    tskADMNone                      :Result:=cstskADMNone;
    tskADMGetAbout                  :Result:=cstskADMGetAbout;
    tskADMGetNewMess                :Result:=cstskADMGetNewMess;
    tskADMGetASMServers             :Result:=cstskADMGetASMServers;
    tskADMGetSummJurnal             :Result:=cstskADMGetSummJurnal;
    tskADMStopASMOnID               :Result:=cstskADMStopASMOnID;
    tskADMStopASMOnUser             :Result:=cstskADMStopASMOnUser;
    tskADMStopASMAll                :Result:=cstskADMStopASMAll;
    tskADMGetServerLockStatus       :Result:=cstskADMGetServerLockStatus;
    tskADMServerLock                :Result:=cstskADMServerLock;
    tskADMServerUnlock              :Result:=cstskADMServerUnlock;
    tskADMSendMessToId              :Result:=cstskADMSendMessToId;
    tskADMSendMessToUser            :Result:=cstskADMSendMessToUser;
    tskADMSendMessToAll             :Result:=cstskADMSendMessToAll;
    tskADMCodeOfMateTeam            :Result:=cstskADMCodeOfMateTeam;
    tskADMShotDownServer            :Result:=cstskADMShotDownServer;
    tskADMMessage                   :Result:=cstskADMMessage;
    tskADMCancelTask                :Result:=cstskADMCancelTask;
    tskADMIgnoreTaskAdd             :Result:=cstskADMIgnoreTaskAdd;
    tskADMIgnoreTaskCancel          :Result:=cstskADMIgnoreTaskCancel;
    tskADMPack                      :Result:=cstskADMPack;
    tskADMBlockSQL                    :Result:=cstskADMBlockSQL;
    tskADMReloadSecurity            :Result:=cstskADMReloadSecurity;
    tskADMReloadInternalConfig      :Result:=cstskADMReloadInternalConfig;
    tskADMSendMessToMask            :Result:=cstskADMSendMessToMask;
    tskADMSendPackToId              :Result:=cstskADMSendPackToId;
    tskADMSendPackToUser            :Result:=cstskADMSendPackToUser;
    tskADMSendPackToMask            :Result:=cstskADMSendPackToMask;
    tskADMSendPackToAll             :Result:=cstskADMSendPackToAll;
    tskADMSetLockList               :Result:=cstskADMSetLockList;
    tskADMGetLockList               :Result:=cstskADMGetLockList;
    tskADMClearLockOwner            :Result:=cstskADMClearLockOwner;
    tskADMRunServerProc             :Result:=cstskADMRunServerProc;
    tskADMCPT                       :Result:=cstskADMCPT;
    tskADMCPR                       :Result:=cstskADMCPR;
    tskADMPD                        :Result:=cstskADMPD;
    tskADMExecMT                    :Result:=cstskADMExecMT;
    tskADMGetOnlineStatus           :Result:=cstskADMGetOnlineStatus;
    tskADMGetOnlineMode             :Result:=cstskADMGetOnlineMode;
    tskADMSetOnlineMode             :Result:=cstskADMSetOnlineMode;
    tskADMSetOnline                 :Result:=cstskADMSetOnline;
    tskADMSetOffline                :Result:=cstskADMSetOffline;
    tskADMGetBridgeCount            :Result:=cstskADMGetBridgeCount;
    tskADMCreateBridge              :Result:=cstskADMCreateBridge;
    tskADMDeleteBridge              :Result:=cstskADMDeleteBridge;
    tskADMAddToClientQueue          :Result:=cstskADMAddToClientQueue;
    tskADMExecServerProc            :Result:=cstskADMExecServerProc;
    tskADMClearRePDOfClientID       :Result:=cstskADMClearRePDOfClientID;
    //tskADMBfCheckActuality          :Result:=cstskADMBfCheckActuality;
    //tskADMBfBeginDownload           :Result:=cstskADMBfBeginDownload;
    //tskADMBfDownload                :Result:=cstskADMBfDownload;
    //tskADMBfEndDownload             :Result:=cstskADMBfEndDownload;
    //tskADMBfBeginUpload             :Result:=cstskADMBfBeginUpload;
    //tskADMBfUpload                  :Result:=cstskADMBfUpload;
    //tskADMBfEndUpload               :Result:=cstskADMBfEndUpload;
    //tskADMBfTransferCancel          :Result:=cstskADMBfTransferCancel;
    //tskADMBfAddTransferDownload     :Result:=cstskADMBfAddTransferDownload;
    //tskADMBfAddTransferUpload       :Result:=cstskADMBfAddTransferUpload;
    //tskADMBfExists                  :Result:=cstskADMBfExists;
    //tskADMBfLocalDelete             :Result:=cstskADMBfLocalDelete;
    //tskADMBfTransferTerminate       :Result:=cstskADMBfTransferTerminate;
    //tskADMBfTransferTerminated      :Result:=cstskADMBfTransferTerminated;
    //tskADMBfTransferTerminateByBfName:Result:=cstskADMBfTransferTerminateByBfName;
    //tskADMBfTransferCanceled        :Result:=cstskADMBfTransferCanceled;
    tskADMPackIsLost                :Result:=cstskADMPackIsLost;
    tskADMEQueryInterface           :Result:=cstskADMEQueryInterface;
    tskADMEQueryInterfaceByLevel    :Result:=cstskADMEQueryInterfaceByLevel;
    tskADMEQueryInterfaceByNodeName :Result:=cstskADMEQueryInterfaceByNodeName;
  else
    Result:='tskADMUnknown_'+IntToStr(Integer(aADMTask));
  end;
end;

function glStrToADMTask(const aStr:AnsiString; aIfFailThenRaise:Boolean=False):TADMTask;
  var tmpStr:AnsiString;
      tmpErr:Boolean;
begin
  Result:=TADMTask(-1);
  tmpStr:=AnsiUpperCase(aStr);
  if tmpStr=UpperCase(cstskADMNone) then Result:=tskADMNone else
  if tmpStr=UpperCase(cstskADMGetAbout) then Result:=tskADMGetAbout else
  if tmpStr=UpperCase(cstskADMGetNewMess) then Result:=tskADMGetNewMess else
  if tmpStr=UpperCase(cstskADMGetASMServers) then Result:=tskADMGetASMServers else
  if tmpStr=UpperCase(cstskADMGetSummJurnal) then Result:=tskADMGetSummJurnal else
  if tmpStr=UpperCase(cstskADMStopASMOnID) then Result:=tskADMStopASMOnID else
  if tmpStr=UpperCase(cstskADMStopASMOnUser) then Result:=tskADMStopASMOnUser else
  if tmpStr=UpperCase(cstskADMStopASMAll) then Result:=tskADMStopASMAll else
  if tmpStr=UpperCase(cstskADMGetServerLockStatus) then Result:=tskADMGetServerLockStatus else
  if tmpStr=UpperCase(cstskADMServerLock) then Result:=tskADMServerLock else
  if tmpStr=UpperCase(cstskADMServerUnlock) then Result:=tskADMServerUnlock else
  if tmpStr=UpperCase(cstskADMSendMessToId) then Result:=tskADMSendMessToId else
  if tmpStr=UpperCase(cstskADMSendMessToUser) then Result:=tskADMSendMessToUser else
  if tmpStr=UpperCase(cstskADMSendMessToAll) then Result:=tskADMSendMessToAll else
  if tmpStr=UpperCase(cstskADMCodeOfMateTeam) then Result:=tskADMCodeOfMateTeam else
  if tmpStr=UpperCase(cstskADMShotDownServer) then Result:=tskADMShotDownServer else
  if tmpStr=UpperCase(cstskADMMessage) then Result:=tskADMMessage else
  if tmpStr=UpperCase(cstskADMCancelTask) then Result:=tskADMCancelTask else
  if tmpStr=UpperCase(cstskADMIgnoreTaskAdd) then Result:=tskADMIgnoreTaskAdd else
  if tmpStr=UpperCase(cstskADMIgnoreTaskCancel) then Result:=tskADMIgnoreTaskCancel else
  if tmpStr=UpperCase(cstskADMPack) then Result:=tskADMPack else
  if tmpStr=UpperCase(cstskADMBlockSQL) then Result:=tskADMBlockSQL else
  if tmpStr=UpperCase(cstskADMReloadSecurity) then Result:=tskADMReloadSecurity else
  if tmpStr=UpperCase(cstskADMReloadInternalConfig) then Result:=tskADMReloadInternalConfig else
  if tmpStr=UpperCase(cstskADMSendMessToMask) then Result:=tskADMSendMessToMask else
  if tmpStr=UpperCase(cstskADMSendPackToId) then Result:=tskADMSendPackToId else
  if tmpStr=UpperCase(cstskADMSendPackToUser) then Result:=tskADMSendPackToUser else
  if tmpStr=UpperCase(cstskADMSendPackToMask) then Result:=tskADMSendPackToMask else
  if tmpStr=UpperCase(cstskADMSendPackToAll) then Result:=tskADMSendPackToAll else
  if tmpStr=UpperCase(cstskADMSetLockList) then Result:=tskADMSetLockList else
  if tmpStr=UpperCase(cstskADMGetLockList) then Result:=tskADMGetLockList else
  if tmpStr=UpperCase(cstskADMClearLockOwner) then Result:=tskADMClearLockOwner else
  if tmpStr=UpperCase(cstskADMRunServerProc) then Result:=tskADMRunServerProc else
  if tmpStr=UpperCase(cstskADMCPT) then Result:=tskADMCPT else
  if tmpStr=UpperCase(cstskADMCPR) then Result:=tskADMCPR else
  if tmpStr=UpperCase(cstskADMPD) then Result:=tskADMPD else
  if tmpStr=UpperCase(cstskADMExecMT) then Result:=tskADMExecMT else
  if tmpStr=UpperCase(cstskADMGetOnlineStatus) then Result:=tskADMGetOnlineStatus else
  if tmpStr=UpperCase(cstskADMGetOnlineMode) then Result:=tskADMGetOnlineMode else
  if tmpStr=UpperCase(cstskADMSetOnlineMode) then Result:=tskADMSetOnlineMode else
  if tmpStr=UpperCase(cstskADMSetOnline) then Result:=tskADMSetOnline else
  if tmpStr=UpperCase(cstskADMSetOffline) then Result:=tskADMSetOffline else
  if tmpStr=UpperCase(cstskADMGetBridgeCount) then Result:=tskADMGetBridgeCount else
  if tmpStr=UpperCase(cstskADMCreateBridge) then Result:=tskADMCreateBridge else
  if tmpStr=UpperCase(cstskADMDeleteBridge) then Result:=tskADMDeleteBridge else
  if tmpStr=UpperCase(cstskADMAddToClientQueue) then Result:=tskADMAddToClientQueue else
  if tmpStr=UpperCase(cstskADMExecServerProc) then Result:=tskADMExecServerProc else
  if tmpStr=UpperCase(cstskADMClearRePDOfClientID) then Result:=tskADMClearRePDOfClientID else
  //if tmpStr=UpperCase(cstskADMBfCheckActuality) then Result:=tskADMBfCheckActuality else
  //if tmpStr=UpperCase(cstskADMBfBeginDownload) then Result:=tskADMBfBeginDownload else
  //if tmpStr=UpperCase(cstskADMBfDownload) then Result:=tskADMBfDownload else
  //if tmpStr=UpperCase(cstskADMBfEndDownload) then Result:=tskADMBfEndDownload else
  //if tmpStr=UpperCase(cstskADMBfBeginUpload) then Result:=tskADMBfBeginUpload else
  //if tmpStr=UpperCase(cstskADMBfUpload) then Result:=tskADMBfUpload else
  //if tmpStr=UpperCase(cstskADMBfEndUpload) then Result:=tskADMBfEndUpload else
  //if tmpStr=UpperCase(cstskADMBfTransferCancel) then Result:=tskADMBfTransferCancel else
  //if tmpStr=UpperCase(cstskADMBfAddTransferDownload) then Result:=tskADMBfAddTransferDownload else
  //if tmpStr=UpperCase(cstskADMBfAddTransferUpload) then Result:=tskADMBfAddTransferUpload else
  //if tmpStr=UpperCase(cstskADMBfExists) then Result:=tskADMBfExists else
  //if tmpStr=UpperCase(cstskADMBfLocalDelete) then Result:=tskADMBfLocalDelete else
  //if tmpStr=UpperCase(cstskADMBfTransferTerminateByBfName) then Result:=tskADMBfTransferTerminateByBfName else
  //if tmpStr=UpperCase(cstskADMBfTransferCanceled) then Result:=tskADMBfTransferCanceled else
  //if tmpStr=UpperCase(cstskADMBfTransferTerminate) then Result:=tskADMBfTransferTerminate else
  //if tmpStr=UpperCase(cstskADMBfTransferTerminated) then Result:=tskADMBfTransferTerminated else
  if tmpStr=UpperCase(cstskADMPackIsLost) then Result:=tskADMPackIsLost else
  if tmpStr=UpperCase(cstskADMEQueryInterface) then Result:=tskADMEQueryInterface else
  if tmpStr=UpperCase(cstskADMEQueryInterfaceByLevel) then Result:=tskADMEQueryInterfaceByLevel else
  if tmpStr=UpperCase(cstskADMEQueryInterfaceByNodeName) then Result:=tskADMEQueryInterfaceByNodeName else
  begin
    tmpErr:=False;
    if Copy(tmpStr, 1, 14)='TSKADMUNKNOWN_' then begin
      tmpStr:=Copy(aStr, 15, Length(aStr)-15);
      Try
        Result:=TADMTask(StrToInt(tmpStr));
      Except
        tmpErr:=True;
      end;
    end else begin
      tmpErr:=True;
    end;
    tmpStr:='';
    if tmpErr then begin
      if aIfFailThenRaise then raise exception.create('Невозможно конвертировать '''+aStr+''' в TADMTask.') else
        result:=TADMTask(-1);
    end;
  end;
end;

Function ResultPackIsLostToVariant(aOnMessageLost, aOnPackLost:Integer):Variant;
begin
  Result:=VarArrayOf([aOnMessageLost, aOnPackLost]);
end;

Procedure ResultVariantToPackIsLost(const aParams:Variant; out aOnMessageLost, aOnPackLost:Integer);
begin
  aOnMessageLost:=aParams[0];
  aOnPackLost:=aParams[1];
end;

end.
