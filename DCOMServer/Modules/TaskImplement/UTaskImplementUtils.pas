//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTaskImplementUtils;

interface
  uses UTTaskTypes;
  function MTBank0ToMTBankN(aTask:TTask):TTask;
implementation

function MTBank0ToMTBankN(aTask:TTask):TTask;
begin  
  case aTask of
    1:result:=tskMTDestroyMate;
    2:result:=tskMTSetPerpetualMate;
    4:result:=tskMTSendMessToId;
    5:result:=tskMTSendMessToUser;
    6:result:=tskMTSendMessToAll;
    7:result:=tskMTStopAllASM;
    8:result:=tskMTStopASMOnID;
    9:result:=tskMTStopASMOnUser;
    10:result:=tskMTShotDownServer;
    11:result:=tskMTShotDownServerImmediately;
    12:result:=tskMTSendEvent;
    14:result:=tskMTSendEventViaBridge;
    15:result:=tskMTSendCommand;
    16:result:=tskMTSendCommandViaBridge;
    18:result:=tskMTUpdateASMList;
    19:result:=tskMTCancelTask;
    20:result:=tskMTIgnoreTaskAdd;
    21:result:=tskMTIgnoreTaskCancel;
    22:result:=tskMTPD;
    24:result:=tskMTTableCommand;
    25:result:=tskMTBlockSQLExec;
    26:result:=tskMTCreateBridge;
    27:result:=tskMTConnectBridge;
    28:result:=tskMTOnLineCheck;
    29:result:=tskMTOnLineSet;
    30:result:=tskMTOffLineSet;
    31:result:=tskMTCircleOnLineSetForASM;
    32:result:=tskMTReloadSecurity;
    34:result:=tskMTSleepRunner;
    36:result:=tskMTCPT;
    37:result:=tskMTCPR;
    38:result:=tskMTRePD;
    39:result:=tskMTExecServerProc;
    41:result:=tskMTReloadTriggers{tskMTStopPD};
    42:result:=tskMTServerProcedures{tskMTSendMessToAppMask};
    43:result:=tskMTSyncTime;
    //44:result:=tskMTBfCheckTransfer;
    //45:result:=tskMTBfCheckActuality;
    //46:result:=tskMTBfBeginDownload;
    //47:result:=tskMTBfDownload;
    //48:result:=tskMTBfEndDownload;
    //49:result:=tskMTBfBeginUpload;
    //50:result:=tskMTBfUpload;
    //51:result:=tskMTBfEndUpload;
    //52:result:=tskMTBfReceiveBeginDownload;
    //53:result:=tskMTBfReceiveDownload;
    //54:result:=tskMTBfReceiveEndDownload_UNUSED;
    //55:result:=tskMTBfReceiveBeginUpload;
    //56:result:=tskMTBfReceiveUpload;
    //57:result:=tskMTBfReceiveEndUpload;
    //58:result:=tskMTBfReceiveErrorBeginDownload;
    //59:result:=tskMTBfReceiveErrorDownload;
    //60:result:=tskMTBfReceiveErrorEndDownload_UNUSED;
    //61:result:=tskMTBfReceiveErrorBeginUpload;
    //62:result:=tskMTBfReceiveErrorUpload;
    //63:result:=tskMTBfReceiveErrorEndUpload;
    //64:result:=tskMTBfAddTransferDownload;
    //65:result:=tskMTBfAddTransferUpload;
    //66:result:=tskMTBfTransferCancel;
    //67:result:=tskMTBfReceiveErrorTransferCancel;
    //68:result:=tskMTBfReceiveTransferCanceled;
    //69:result:=tskMTBfTransferTerminate;
    //70:result:=tskMTBfReceiveTransferTerminated;
    //71:result:=tskMTBfExists;
  else
    result:=aTask;  
  end;
end;

end.
