//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTTaskTypes;

interface

Type
  TTask=Integer;
Const
  tskMTBankMask=$ff00;
  tskMTTaskMask=$00ff;
  tskMTNone=0;
  tskMTBank_MThread=$0100;
  tskMTDestroyMate=tskMTBank_MThread+1;//{ 1}разобрать слейв с указанным адресом(varinteger)
  tskMTSetPerpetualMate=tskMTBank_MThread+2;//{ 2}запретить слейву посылать tskDestroySlave по бездействию
  tskMTBank_ASM=$0200;
  tskMTStopAllASM=tskMTBank_ASM+0;//{ 7}
  tskMTStopASMOnID=tskMTBank_ASM+1;//{ 8}
  tskMTStopASMOnUser=tskMTBank_ASM+2;//{ 9}
  tskMTUpdateASMList=tskMTBank_ASM+3;//{18}
  tskMTBank_ShotDownServer=$0300;
  tskMTShotDownServer=tskMTBank_ShotDownServer+0;//{10}
  tskMTShotDownServerImmediately=tskMTBank_ShotDownServer+1;//{11}
  tskMTBank_SendEvent=$0400;
  tskMTSendMessToId=tskMTBank_SendEvent+0;//{ 4}
  tskMTSendMessToUser=tskMTBank_SendEvent+1;//{ 5}
  tskMTSendMessToAll=tskMTBank_SendEvent+2;//{ 6}
  tskMTSendEvent=tskMTBank_SendEvent+3;//{12}
  tskMTSendEventViaBridge=tskMTBank_SendEvent+4;//{14}
  tskMTSendCommand=tskMTBank_SendEvent+5;//{15}
  tskMTSendCommandViaBridge=tskMTBank_SendEvent+6;//{16}
  tskMTBank_Task=$0500;
  tskMTCancelTask=tskMTBank_Task+0;//{19}
  tskMTIgnoreTaskAdd=tskMTBank_Task+1;//{20}
  tskMTIgnoreTaskCancel=tskMTBank_Task+2;//{21}
  tskMTBank_OnLine=$0600;
  tskMTOnLineCheck=tskMTBank_OnLine+0;//{28} - ONLY FOR EAMServer
  tskMTOnLineSet=tskMTBank_OnLine+1;//{29} - ONLY FOR EAMServer
  tskMTOffLineSet=tskMTBank_OnLine+2;//{30} - ONLY FOR EAMServer
  tskMTCircleOnLineSetForASM=tskMTBank_OnLine+3;//{31} - ONLY FOR EAMServer
  tskMTBank_Bridge=$0700;
  tskMTCreateBridge=tskMTBank_Bridge+0;//{26} - ONLY FOR EAMServer
  tskMTConnectBridge=tskMTBank_Bridge+1;//{27} - ONLY FOR EAMServer
  tskMTBank_Reload=$0800;
  tskMTReloadSecurity=tskMTBank_Reload+0;//{32}
  tskMTReloadTriggers=tskMTBank_Reload+1;//{41}
  tskMTServerProcedures=tskMTBank_Reload+2;//{42}
  tskMTBank_ExecPack=$0900;
  tskMTCPT=tskMTBank_ExecPack+0;//{36}
  tskMTCPR=tskMTBank_ExecPack+1;//{37}
  tskMTRePD=tskMTBank_ExecPack+2;//{38}
  tskMTPD=tskMTBank_ExecPack+3;//{22}
  tskMTPDConnectionName=tskMTBank_ExecPack+4;
  tskMTBank_ServerUtils=$0A00;
  tskMTTableCommand=tskMTBank_ServerUtils+0;//{24} - ONLY FOR PEGAS
  tskMTBlockSQLExec=tskMTBank_ServerUtils+1;//{25} - ONLY FOR EAMServer
  tskMTExecServerProc=tskMTBank_ServerUtils+2;//{39}Запускает ServerProc(Dll)
  tskMTSyncTime=tskMTBank_ServerUtils+3;//{43}
  tskMTSleepRunner=tskMTBank_ServerUtils+4;//{34}
  (*tskMTBank_Bf=$0B00;
  tskMTBfCheckTransfer=tskMTBank_Bf+0;//{44}
  tskMTBfCheckActuality=tskMTBank_Bf+1;//{45}
  tskMTBfBeginDownload=tskMTBank_Bf+2;//{46}
  tskMTBfDownload=tskMTBank_Bf+3;//{47}
  tskMTBfEndDownload=tskMTBank_Bf+4;//{48}
  tskMTBfBeginUpload=tskMTBank_Bf+5;//{49}
  tskMTBfUpload=tskMTBank_Bf+6;//{50}
  tskMTBfEndUpload=tskMTBank_Bf+7;//{51}
  tskMTBfReceiveBeginDownload=tskMTBank_Bf+8;//{52}
  tskMTBfReceiveDownload=tskMTBank_Bf+9;//{53}
  tskMTBfReceiveEndDownload_UNUSED=tskMTBank_Bf+10;//{54}
  tskMTBfReceiveBeginUpload=tskMTBank_Bf+11;//{55}
  tskMTBfReceiveUpload=tskMTBank_Bf+12;//{56}
  tskMTBfReceiveEndUpload=tskMTBank_Bf+13;//{57}
  tskMTBfReceiveErrorBeginDownload=tskMTBank_Bf+14;//{58}
  tskMTBfReceiveErrorDownload=tskMTBank_Bf+15;//{59}
  tskMTBfReceiveErrorEndDownload_UNUSED=tskMTBank_Bf+16;//{60}
  tskMTBfReceiveErrorBeginUpload=tskMTBank_Bf+17;//{61}
  tskMTBfReceiveErrorUpload=tskMTBank_Bf+18;//{62}
  tskMTBfReceiveErrorEndUpload=tskMTBank_Bf+19;//{63}
  tskMTBfAddTransferDownload=tskMTBank_Bf+20;//{64}
  tskMTBfAddTransferUpload=tskMTBank_Bf+21;//{65}
  tskMTBfTransferCancel=tskMTBank_Bf+22;//{66}
  tskMTBfReceiveErrorTransferCancel=tskMTBank_Bf+23;//{67}
  tskMTBfReceiveTransferCanceled=tskMTBank_Bf+24;//{68}
  tskMTBfTransferTerminate=tskMTBank_Bf+25;//{69}
  tskMTBfReceiveTransferTerminated=tskMTBank_Bf+26;//{70}
  tskMTBfExists=tskMTBank_Bf+27;{71}
  tskMTBfLocalDelete=tskMTBank_Bf+28;
  tskMTBfTransferTerminateByBfName=tskMTBank_Bf+29;(**)
  tskMTBank_DMS=$0C00;
  tskMTDMSCheckEServers=tskMTBank_DMS+0;
  tskMTDMSCheckEServersReg=tskMTBank_DMS+1;
  tskMTDMSEServerLogin=tskMTBank_DMS+2;
  tskMTDMSStopServer=tskMTBank_DMS+3;
  tskMTDMSStartServer=tskMTBank_DMS+4;
  tskMTDMSReStartServer=tskMTBank_DMS+5;
  tskMTBank_EQueryInterface=$0D00;
  tskMTEQueryInterface=tskMTBank_EQueryInterface+0;
  tskMTEQueryInterfaceByLevel=tskMTBank_EQueryInterface+1;
  tskMTEQueryInterfaceByNodeName=tskMTBank_EQueryInterface+2;
implementation
(*     { 3}tskMTx0,
       {17}tskMTx1,
       {33}tskMTx2,
       {40}tskMTx3,
       {23}tskMTx4,
       {35}tskMTx5,              //
  //       Name                             |Must Execute | Description
TTask=({ 0}tskMTNone,                       //            | крутится когда нет комманд
       { 1}tskMTDestroyMate,                //            | разобрать слейв с указанным адресом(varinteger)
       { 2}tskMTSetPerpetualMate,           //            | запретить слейву посылать tskDestroySlave по бездействию
.      { 3}tskMTReadEServerPipe,               // - ONLY FOR PEGAS
       { 4}tskMTSendMessToId,               //            |
       { 5}tskMTSendMessToUser,             //            |
       { 6}tskMTSendMessToAll,              //            |  //           tskMTCodeOfMateTeam,     //            | Получить свод данных по работе STTeam
       { 7}tskMTStopAllASM,                 //            |
       { 8}tskMTStopASMOnID,                //            |
       { 9}tskMTStopASMOnUser,              //            |
       {10}tskMTShotDownServer,             //            |
       {11}tskMTShotDownServerImmediately,
       {12}tskMTSendEvent,                  //
       {13}tskMTSendEventToOneOfList,       //
       {14}tskMTSendEventViaBridge,         //
       {15}tskMTSendCommand,                // - ONLY FOR EAMServer
       {16}tskMTSendCommandViaBridge,       // - ONLY FOR EAMServer
.      {17}tskMTAutoExecuteCommand,         //
       {18}tskMTUpdateASMList,              //
       {19}tskMTCancelTask,                 //
       {20}tskMTIgnoreTaskAdd,              //
       {21}tskMTIgnoreTaskCancel,           //
       {22}tskMTPD,                         //
.      {23}tskMTMessToLog,                  //
       {24}tskMTTableCommand,               // - ONLY FOR PEGAS
       {25}tskMTBlockSQLExec,               // - ONLY FOR EAMServer
       {26}tskMTCreateBridge,               // - ONLY FOR EAMServer
       {27}tskMTConnectBridge,              // - ONLY FOR EAMServer
       {28}tskMTOnLineCheck,                // - ONLY FOR EAMServer
       {29}tskMTOnLineSet,                  // - ONLY FOR EAMServer
       {30}tskMTOffLineSet,                 // - ONLY FOR EAMServer
       {31}tskMTCircleOnLineSetForASM,      // - ONLY FOR EAMServer
       {32}tskMTReloadSecurity,             //
.      {33}tskMTInternalConfig,             //
       {34}tskMTSleepRunner,                //
.      {35}tskMTRunServerProc,              //
       {36}tskMTCPT,                        //
       {37}tskMTCPR,                        //
       {38}tskMTRePD,                       //
       {39}tskMTExecServerProc,             //
.      {40}tskMTIPD,                         //
       {41}tskMTReloadTriggers{tskMTStopPD},                     //
       {42}tskMTServerProcedures{tskMTSendMessToAppMask},          //
       {43}tskMTSyncTime,                   //
       {44}tskMTBfCheckTransfer,
       {45}tskMTBfCheckActuality,
       {46}tskMTBfBeginDownload,
       {47}tskMTBfDownload,
       {48}tskMTBfEndDownload,
       {49}tskMTBfBeginUpload,
       {50}tskMTBfUpload,
       {51}tskMTBfEndUpload,
       {52}tskMTBfReceiveBeginDownload,
       {53}tskMTBfReceiveDownload,
       {54}tskMTBfReceiveEndDownload_UNUSED,
       {55}tskMTBfReceiveBeginUpload,
       {56}tskMTBfReceiveUpload,
       {57}tskMTBfReceiveEndUpload,
       {58}tskMTBfReceiveErrorBeginDownload,
       {59}tskMTBfReceiveErrorDownload,
       {60}tskMTBfReceiveErrorEndDownload_UNUSED,
       {61}tskMTBfReceiveErrorBeginUpload,
       {62}tskMTBfReceiveErrorUpload,
       {63}tskMTBfReceiveErrorEndUpload,
       {64}tskMTBfAddTransferDownload,
       {65}tskMTBfAddTransferUpload,
       {66}tskMTBfTransferCancel,
       {67}tskMTBfReceiveErrorTransferCancel,
       {68}tskMTBfReceiveTransferCanceled,
       {69}tskMTBfTransferTerminate,
       {70}tskMTBfReceiveTransferTerminated,
       {71}tskMTBfExists
          );
*)
end.
