//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTTaskUtils;

interface
  uses UTTaskTypes;

  function MTaskToStr(const aMTask:TTask):AnsiString;
  function StrToMTask(const aString:AnsiString; aIfFailThenRaise:Boolean=False):TTask;
implementation
  uses Sysutils, UTTaskConsts;

function MTaskToStr(const aMTask:TTask):AnsiString;
begin
  case aMTask of
    tskMTNone                       :Result:=cstskMTNone;
    tskMTDestroyMate                :Result:=cstskMTDestroyMate;
    tskMTSetPerpetualMate           :Result:=cstskMTSetPerpetualMate;
    //tskMTReadEServerPipe            :Result:=cstskMTReadEServerPipe;
    tskMTSendMessToId               :Result:=cstskMTSendMessToId;
    tskMTSendMessToUser             :Result:=cstskMTSendMessToUser;
    tskMTSendMessToAll              :Result:=cstskMTSendMessToAll;
    tskMTStopAllASM                 :Result:=cstskMTStopAllASM;
    tskMTStopASMOnID                :Result:=cstskMTStopASMOnID;
    tskMTStopASMOnUser              :Result:=cstskMTStopASMOnUser;
    tskMTShotDownServer             :Result:=cstskMTShotDownServer;
    tskMTShotDownServerImmediately  :Result:=cstskMTShotDownServerImmediately;
    tskMTSendEvent                  :Result:=cstskMTSendEvent;
    //tskMTSendEventToOneOfList       :Result:=cstskMTSendEventToOneOfList;
    tskMTSendEventViaBridge         :Result:=cstskMTSendEventViaBridge;
    tskMTSendCommand                :Result:=cstskMTSendCommand;
    tskMTSendCommandViaBridge       :Result:=cstskMTSendCommandViaBridge;
    //tskMTAutoExecuteCommand         :Result:=cstskMTAutoExecuteCommand;
    tskMTUpdateASMList              :Result:=cstskMTUpdateASMList;
    tskMTCancelTask                 :Result:=cstskMTCancelTask;
    tskMTIgnoreTaskAdd              :Result:=cstskMTIgnoreTaskAdd;
    tskMTIgnoreTaskCancel           :Result:=cstskMTIgnoreTaskCancel;
    tskMTPD                         :Result:=cstskMTPD;
    tskMTPDConnectionName           :Result:=cstskMTPDConnectionName;
    //tskMTMessToLog                  :Result:=cstskMTMessToLog;
    tskMTTableCommand               :Result:=cstskMTTableCommand;
    tskMTBlockSQLExec               :Result:=cstskMTBlockSQLExec;
    tskMTCreateBridge               :Result:=cstskMTCreateBridge;
    tskMTConnectBridge              :Result:=cstskMTConnectBridge;
    tskMTOnLineCheck                :Result:=cstskMTOnLineCheck;
    tskMTOnLineSet                  :Result:=cstskMTOnLineSet;
    tskMTOffLineSet                 :Result:=cstskMTOffLineSet;
    tskMTCircleOnLineSetForASM      :Result:=cstskMTCircleOnLineSetForASM;
    tskMTReloadSecurity             :Result:=cstskMTReloadSecurity;
    //tskMTInternalConfig             :Result:=cstskMTInternalConfig;
    tskMTSleepRunner                :Result:=cstskMTSleepRunner;
    //tskMTRunServerProc              :Result:=cstskMTRunServerProc;
    tskMTCPT                        :Result:=cstskMTCPT;
    tskMTCPR                        :Result:=cstskMTCPR;
    tskMTRePD                       :Result:=cstskMTRePD;
    tskMTExecServerProc             :Result:=cstskMTExecServerProc;
//{40}tskMTIPD                        :Result:=cstskMTIPD;
{41}tskMTReloadTriggers             :Result:=cstskMTReloadTriggers;
{42}tskMTServerProcedures           :Result:=cstskMTServerProcedures;
{43}tskMTSyncTime                   :Result:=cstskMTSyncTime;
{44}//tskMTBfCheckTransfer            :Result:=cstskMTBfCheckTransfer;
{45}//tskMTBfCheckActuality           :Result:=cstskMTBfCheckActuality;
{46}//tskMTBfBeginDownload            :Result:=cstskMTBfBeginDownload;
{47}//tskMTBfDownload                 :Result:=cstskMTBfDownload;
{48}//tskMTBfEndDownload              :Result:=cstskMTBfEndDownload;
{49}//tskMTBfBeginUpload              :Result:=cstskMTBfBeginUpload;
{50}//tskMTBfUpload                   :Result:=cstskMTBfUpload;
{51}//tskMTBfEndUpload                :Result:=cstskMTBfEndUpload;
{52}//tskMTBfReceiveBeginDownload     :Result:=cstskMTBfReceiveBeginDownload;
{53}//tskMTBfReceiveDownload          :Result:=cstskMTBfReceiveDownload;
{54}//tskMTBfReceiveEndDownload_UNUSED:Result:=cstskMTBfReceiveEndDownload_UNUSED;
{55}//tskMTBfReceiveBeginUpload       :Result:=cstskMTBfReceiveBeginUpload;
{56}//tskMTBfReceiveUpload            :Result:=cstskMTBfReceiveUpload;
{57}//tskMTBfReceiveEndUpload         :Result:=cstskMTBfReceiveEndUpload;
{58}//tskMTBfReceiveErrorBeginDownload:Result:=cstskMTBfReceiveErrorBeginDownload;
{59}//tskMTBfReceiveErrorDownload     :Result:=cstskMTBfReceiveErrorDownload;
{60}//tskMTBfReceiveErrorEndDownload_UNUSED  :Result:=cstskMTBfReceiveErrorEndDownload_UNUSED;
{61}//tskMTBfReceiveErrorBeginUpload  :Result:=cstskMTBfReceiveErrorBeginUpload;
{62}//tskMTBfReceiveErrorUpload       :Result:=cstskMTBfReceiveErrorUpload;
{63}//tskMTBfReceiveErrorEndUpload    :Result:=cstskMTBfReceiveErrorEndUpload;
{64}//tskMTBfAddTransferDownload      :Result:=cstskMTBfAddTransferDownload;
{65}//tskMTBfAddTransferUpload        :Result:=cstskMTBfAddTransferUpload;
    //tskMTBfTransferCancel           :Result:=cstskMTBfTransferCancel;
    //tskMTBfExists                   :result:=cstskMTBfExists;
    //tskMTBfLocalDelete              :result:=cstskMTBfLocalDelete;
    //tskMTBfTransferTerminateByBfName:result:=cstskMTBfTransferTerminateByBfName;
    tskMTEQueryInterface            :result:=cstskMTEQueryInterface;
    tskMTEQueryInterfaceByLevel     :result:=cstskMTEQueryInterfaceByLevel;
    tskMTEQueryInterfaceByNodeName  :result:=cstskMTEQueryInterfaceByNodeName;
  else
    Result:='tskUnknown_'+IntToStr(Integer(aMTask));
  end;
end;

function StrToMTask(const aString:AnsiString; aIfFailThenRaise:Boolean=False):TTask;
  var tmpStr:AnsiString;
      tmpErr:Boolean;
begin
  Result:=TTask(-1);
  tmpStr:=AnsiUpperCase(aString);
  if tmpStr=UpperCase(cstskMTNone) then Result:=tskMTNone else
  if tmpStr=UpperCase(cstskMTDestroyMate) then Result:=tskMTDestroyMate else
  if tmpStr=UpperCase(cstskMTSetPerpetualMate) then Result:=tskMTSetPerpetualMate else
  //if tmpStr=UpperCase(cstskMTReadEServerPipe) then Result:=tskMTReadEServerPipe else
  if tmpStr=UpperCase(cstskMTSendMessToId) then Result:=tskMTSendMessToId else
  if tmpStr=UpperCase(cstskMTSendMessToUser) then Result:=tskMTSendMessToUser else
  if tmpStr=UpperCase(cstskMTSendMessToAll) then Result:=tskMTSendMessToAll else
  if tmpStr=UpperCase(cstskMTStopASMOnID) then Result:=tskMTStopASMOnID else
  if tmpStr=UpperCase(cstskMTStopASMOnUser) then Result:=tskMTStopASMOnUser else
  if tmpStr=UpperCase(cstskMTShotDownServer) then Result:=tskMTShotDownServer else
  if tmpStr=UpperCase(cstskMTShotDownServerImmediately) then Result:=tskMTShotDownServerImmediately else
  if tmpStr=UpperCase(cstskMTSendEvent) then Result:=tskMTSendEvent else
  //if tmpStr=UpperCase(cstskMTSendEventToOneOfList) then Result:=tskMTSendEventToOneOfList else
  if tmpStr=UpperCase(cstskMTSendEventViaBridge) then Result:=tskMTSendEventViaBridge else
  if tmpStr=UpperCase(cstskMTSendCommand) then Result:=tskMTSendCommand else
  if tmpStr=UpperCase(cstskMTSendCommandViaBridge) then Result:=tskMTSendCommandViaBridge else
  //if tmpStr=UpperCase(cstskMTAutoExecuteCommand) then Result:=tskMTAutoExecuteCommand else
  if tmpStr=UpperCase(cstskMTUpdateASMList) then Result:=tskMTUpdateASMList else
  if tmpStr=UpperCase(cstskMTCancelTask) then Result:=tskMTCancelTask else
  if tmpStr=UpperCase(cstskMTIgnoreTaskAdd) then Result:=tskMTIgnoreTaskAdd else
  if tmpStr=UpperCase(cstskMTIgnoreTaskCancel) then Result:=tskMTIgnoreTaskCancel else
  if tmpStr=UpperCase(cstskMTPD) then Result:=tskMTPD else
  if tmpStr=UpperCase(cstskMTPDConnectionName) then Result:=tskMTPDConnectionName else
  //if tmpStr=UpperCase(cstskMTMessToLog) then Result:=tskMTMessToLog else
  if tmpStr=UpperCase(cstskMTTableCommand) then Result:=tskMTTableCommand else
  if tmpStr=UpperCase(cstskMTBlockSQLExec) then Result:=tskMTBlockSQLExec else
  if tmpStr=UpperCase(cstskMTCreateBridge) then Result:=tskMTCreateBridge else
  if tmpStr=UpperCase(cstskMTConnectBridge) then Result:=tskMTConnectBridge else
  if tmpStr=UpperCase(cstskMTOnLineCheck) then Result:=tskMTOnLineCheck else
  if tmpStr=UpperCase(cstskMTOnLineSet) then Result:=tskMTOnLineSet else
  if tmpStr=UpperCase(cstskMTOffLineSet) then Result:=tskMTOffLineSet else
  if tmpStr=UpperCase(cstskMTCircleOnLineSetForASM) then Result:=tskMTCircleOnLineSetForASM else
  if tmpStr=UpperCase(cstskMTReloadSecurity) then Result:=tskMTReloadSecurity else
  //if tmpStr=UpperCase(cstskMTInternalConfig) then Result:=tskMTInternalConfig else
  if tmpStr=UpperCase(cstskMTSleepRunner) then Result:=tskMTSleepRunner else
  //if tmpStr=UpperCase(cstskMTRunServerProc) then Result:=tskMTRunServerProc else
  if tmpStr=UpperCase(cstskMTCPT) then Result:=tskMTCPT else
  if tmpStr=UpperCase(cstskMTCPR) then Result:=tskMTCPR else
  if tmpStr=UpperCase(cstskMTRePD) then Result:=tskMTRePD else
  if tmpStr=UpperCase(cstskMTExecServerProc) then Result:=tskMTExecServerProc else
  //if tmpStr=UpperCase(cstskMTIPD) then Result:=tskMTIPD else
  if tmpStr=UpperCase(cstskMTReloadTriggers) then Result:=tskMTReloadTriggers else
  if tmpStr=UpperCase(cstskMTServerProcedures) then Result:=tskMTServerProcedures else
  if tmpStr=UpperCase(cstskMTSyncTime) then Result:=tskMTSyncTime else
  //if tmpStr=UpperCase(cstskMTBfCheckTransfer) then Result:=tskMTBfCheckTransfer else
  //if tmpStr=UpperCase(cstskMTBfCheckActuality) then Result:=tskMTBfCheckActuality else
  //if tmpStr=UpperCase(cstskMTBfBeginDownload) then Result:=tskMTBfBeginDownload else
  //if tmpStr=UpperCase(cstskMTBfDownload) then Result:=tskMTBfDownload else
  //if tmpStr=UpperCase(cstskMTBfEndDownload) then Result:=tskMTBfEndDownload else
  //if tmpStr=UpperCase(cstskMTBfBeginUpload) then Result:=tskMTBfBeginUpload else
  //if tmpStr=UpperCase(cstskMTBfUpload) then Result:=tskMTBfUpload else
  //if tmpStr=UpperCase(cstskMTBfEndUpload) then Result:=tskMTBfEndUpload else
  //if tmpStr=UpperCase(cstskMTBfReceiveBeginDownload) then Result:=tskMTBfReceiveBeginDownload else
  //if tmpStr=UpperCase(cstskMTBfReceiveDownload) then Result:=tskMTBfReceiveDownload else
  //if tmpStr=UpperCase(cstskMTBfReceiveEndDownload_UNUSED) then Result:=tskMTBfReceiveEndDownload_UNUSED else
  //if tmpStr=UpperCase(cstskMTBfReceiveBeginUpload) then Result:=tskMTBfReceiveBeginUpload else
  //if tmpStr=UpperCase(cstskMTBfReceiveUpload) then Result:=tskMTBfReceiveUpload else
  //if tmpStr=UpperCase(cstskMTBfReceiveEndUpload) then Result:=tskMTBfReceiveEndUpload else
  //if tmpStr=UpperCase(cstskMTBfReceiveErrorBeginDownload) then Result:=tskMTBfReceiveErrorBeginDownload else
  //if tmpStr=UpperCase(cstskMTBfReceiveErrorDownload) then Result:=tskMTBfReceiveErrorDownload else
  //if tmpStr=UpperCase(cstskMTBfReceiveErrorEndDownload_UNUSED) then Result:=tskMTBfReceiveErrorEndDownload_UNUSED else
  //if tmpStr=UpperCase(cstskMTBfReceiveErrorBeginUpload) then Result:=tskMTBfReceiveErrorBeginUpload else
  //if tmpStr=UpperCase(cstskMTBfReceiveErrorUpload) then Result:=tskMTBfReceiveErrorUpload else
  //if tmpStr=UpperCase(cstskMTBfReceiveErrorEndUpload) then Result:=tskMTBfReceiveErrorEndUpload else
  //if tmpStr=UpperCase(cstskMTBfAddTransferDownload) then Result:=tskMTBfAddTransferDownload else
  //if tmpStr=UpperCase(cstskMTBfAddTransferUpload) then Result:=tskMTBfAddTransferUpload else
  //if tmpStr=UpperCase(cstskMTBfTransferCancel) then Result:=tskMTBfTransferCancel else
  //if tmpStr=UpperCase(cstskMTBfExists) then result:=tskMTBfExists else
  //if tmpStr=UpperCase(cstskMTBfLocalDelete) then result:=tskMTBfLocalDelete else
  //if tmpStr=UpperCase(cstskMTBfTransferTerminateByBfName) then result:=tskMTBfTransferTerminateByBfName else
  if tmpStr=UpperCase(cstskMTEQueryInterface) then result:=tskMTEQueryInterface else
  if tmpStr=UpperCase(cstskMTEQueryInterfaceByLevel) then result:=tskMTEQueryInterfaceByLevel else
  if tmpStr=UpperCase(cstskMTEQueryInterfaceByNodeName) then result:=tskMTEQueryInterfaceByNodeName else
  begin
    tmpErr:=False;
    if Copy(tmpStr, 1, 11)='TSKUNKNOWN_' then begin
      tmpStr:=Copy(aString, 12, Length(aString)-12);
      try
        Result:=TTask(StrToInt(tmpStr));
      except
        tmpErr:=True;
      end;
    end else begin
      tmpErr:=True;
    end;
    tmpStr:='';
    if tmpErr then begin
      if aIfFailThenRaise then raise exception.create('Невозможно конвертировать '''+aString+''' в TTask.') else
        result:=TTask(-1);
    end;
  end;
end;

end.
