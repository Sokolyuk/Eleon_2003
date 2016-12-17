//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTaskImplementBfUtils;
  ћодуль нормальный, но технологи€ устарела. см. TransferDoc/TransferDocs/TransferDocManage/TransferBf
interface
  uses UTTaskTypes, UCallerTypes, UTaskImplementTypes;

  function TaskImplementBf(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;

implementation
  uses UTransferBfsTypes, Sysutils, UErrorConsts, UTransferBfTaskImpUtils, UTTaskUtils, UTrayConsts, UThreadsPoolTypes
       {$IFDEF VER140}, Variants{$ENDIF}{$IFDEF VER130}, UVer130Types{$ENDIF};

function TaskImplementBf(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;
  Var tmpTransferBf:ITransferBfs;
  function localGetTransferBf:ITransferBfs; begin
    if not assigned(tmpTransferBf) then cnTray.Query(ITransferBfs, tmpTransferBf);
    result:=tmpTransferBf;
  end;
  function localGetTaskID:Integer;begin
    if assigned(aTaskContext) then result:=aTaskContext^.aTaskID else result:=-1;
  end;
  function localGetPTaskID:PInteger;begin
    if assigned(aTaskContext) then result:=@(aTaskContext^.aTaskID) else result:=nil;
  end;
  //Var tmpResult:Variant;
begin
  if assigned(aTaskContext) then begin
    aTaskContext^.aSetResult:=false;
  end else Raise Exception.Create('aTaskContext not assigned.');
  //tmpResult:=Unassigned;
  result:=true;
  case aTask of
    {44}tskMTBfCheckTransfer:begin
          try
            localGetTransferBf.ITCheckTransferProcess;
          finally
            If VarType(aParams)=varInteger then IThreadsPool(cnTray.Query(IThreadsPool)).ITMSleepTaskAdd(tskMTBfCheckTransfer, aParams, aCallerAction.SenderParams, aCallerAction.SecurityContext, Integer(aParams), localGetTaskID, localGetPTaskID);
          end;
        end;
    {45}//tskMTBfCheckActuality:Begin
          //Param( In):[0]-varInteger:(BlobID); [1][0]-varOleStr:(FileName); [1][1]-varDate:(Date); [1][2]-varInteger:(TotalSize)
          //Param(Out):[0]-varInteger:(BlobID); [1][0]-varOleStr:(FileName); [1][1]-varDate:(Date); [1][2]-varInteger:(TotalSize); [2]-varBoolean:(Actuality);
        //  tmpBfInfo:=glVariantToBfInfo(aParams[1]);
        //  tmpInteger:=aParams[0];
        //  tmpBoolean:=localGetTransferBf.ITCheckBfActuality(aCallerAction, tmpInteger, tmpBfInfo, nil);
        //  tmpSetResult:=True;
        //  tmpResult:=VarArrayOf([tmpInteger, glBfInfoToVariant(tmpBfInfo), tmpBoolean]);
        //end;
    {46}tskMTBfBeginDownload:BfTaskImp_BgDn(localGetTransferBf, aCallerAction, aParams, aTaskContext^.aSetResult, aTaskContext^.aResult);
    {47}tskMTBfDownload:BfTaskImp_Dn(localGetTransferBf, aCallerAction, aParams, aTaskContext^.aSetResult, aTaskContext^.aResult);
    {48}tskMTBfEndDownload:BfTaskImp_EndDn(localGetTransferBf, aCallerAction, aParams, aTaskContext^.aSetResult, aTaskContext^.aResult);
    {49}tskMTBfBeginUpload:Raise Exception.Create('!');
    {50}tskMTBfUpload:Raise Exception.Create('!');
    {51}tskMTBfEndUpload:Raise Exception.Create('!');
    {52}tskMTBfReceiveBeginDownload:BfTaskImp_RcBgDn(localGetTransferBf, aCallerAction, aParams);
    {53}tskMTBfReceiveDownload:BfTaskImp_RcDn(localGetTransferBf, aCallerAction, aParams);
//    {54}tskMTBfReceiveEndDownload:Begin
//          ?Raise Exception.Create('!');
//        end;
    {55}tskMTBfReceiveBeginUpload:Raise Exception.Create('!');
    {56}tskMTBfReceiveUpload:Raise Exception.Create('!');
    {57}tskMTBfReceiveEndUpload:Raise Exception.Create('!');
    {58}tskMTBfReceiveErrorBeginDownload:BfTaskImp_RcErBgDn(localGetTransferBf, aCallerAction, aParams);
    {59}tskMTBfReceiveErrorDownload:BfTaskImp_RcErDn(localGetTransferBf, aCallerAction, aParams);
//    {60}tskMTBfReceiveErrorEndDownload:Begin
//          ?tmpString:=aParams[0];
//          tmpString1:=aParams[1];
//          tmpInteger:=aParams[2];
//          localGetTransferBf.ITReceiveErrorEndDownloadBf(tmpString, tmpString1, tmpInteger);
//        end;
    {61}tskMTBfReceiveErrorBeginUpload:Raise Exception.Create('!');
    {62}tskMTBfReceiveErrorUpload:Raise Exception.Create('!');
    {63}tskMTBfReceiveErrorEndUpload:Raise Exception.Create('!');
    {64}tskMTBfAddTransferDownload:BfTaskImp_AddDn(localGetTransferBf, aCallerAction, aTaskContext^.aConnectionName, aParams, aTaskContext^.aSetResult, aTaskContext^.aResult);
    {65}tskMTBfAddTransferUpload:Raise Exception.Create('!');
        tskMTBfTransferCancel:BfTaskImp_TransferCancel(localGetTransferBf, aCallerAction, aTaskContext^.aConnectionName, aParams, aTaskContext^.aSetResult, aTaskContext^.aResult);
        tskMTBfReceiveTransferCanceled:BfTaskImp_RcTransferCanceled(localGetTransferBf, aCallerAction, aParams);
        tskMTBfTransferTerminate:BfTaskImp_TransferTerminate(localGetTransferBf, aCallerAction, aTaskContext^.aConnectionName, aParams, aTaskContext^.aSetResult, aTaskContext^.aResult);
        tskMTBfReceiveTransferTerminated:BfTaskImp_RcTransferTerminated(localGetTransferBf, aCallerAction, aParams);
        tskMTBfExists:BfTaskImp_LocalExists(localGetTransferBf, aCallerAction, aTaskContext^.aConnectionName, aParams, aTaskContext^.aSetResult, aTaskContext^.aResult);
        tskMTBfLocalDelete:BfTaskImp_LocalDelete(localGetTransferBf, aCallerAction, aTaskContext^.aConnectionName, aParams, aTaskContext^.aSetResult, aTaskContext^.aResult);
        tskMTBfTransferTerminateByBfName:BfTaskImp_TransferTerminateByBfName(localGetTransferBf, aCallerAction, aTaskContext^.aConnectionName, aParams, aTaskContext^.aSetResult, aTaskContext^.aResult);
  else
    if aRaise then Raise Exception.CreateFmtHelp(cserInternalError, ['Unsupported for '+MTaskToStr(aTask)], cnerInternalError) else result:=false;
  end;
  {if (assigned(aTaskContext))and(aTaskContext^.aSetResult) then begin
    aTaskContext^.aManualResultSet:=false;//разрешаю автоматическую отработку SetComplete??
  end else begin
    aTaskContext^.aManualResultSet:=aTaskContext^.aManualResultSet;
  end;}
end;

end.
