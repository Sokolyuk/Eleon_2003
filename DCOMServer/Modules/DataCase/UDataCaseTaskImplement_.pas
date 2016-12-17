unit UDataCaseTaskImplement;
  �������, �� UTaskImplement
interface
  uses UDataCaseTaskImplementTypes, UIObject, UTTaskTypes, UCallerTypes;
type
  TDataCaseTaskImplement=class(TIObject, IDataCaseTaskImplement)
  private
    //..
  public
    constructor Create;
    destructor Destroy; override;
    Procedure BfTasksImplement(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskID:Integer; aSetResult:PBoolean; aResult:PVariant);
  end;

implementation
  uses UTransferBlobFilesTypes, UBlobfileTypes, Sysutils, UTransferBlobfilesUtils, UBlobfileUtils, UCaller,
       UErrorConsts, UTransferBfTaskImpUtils, UTTaskUtils, UTrayConsts, UThreadsPoolTypes
{$ifndef PegasServer}
       , UTTaskParamsUtils
{$EndIf}
{$IFDEF VER140}
       , Variants
{$ENDIF}
                ;
constructor TDataCaseTaskImplement.Create;
begin
  Inherited Create;
end;

destructor TDataCaseTaskImplement.Destroy;
begin
  Inherited Destroy;
end;

Procedure TDataCaseTaskImplement.BfTasksImplement(aCallerAction:ICallerAction; aTask:TTask; Const aParams{, aSecurityContext, aSenderParams}:Variant; aTaskID:Integer; aSetResult:PBoolean; aResult:PVariant);
  Var tmpTransferBlobFiles:ITransferBlobFiles;
      tmpSetResult:Boolean;
      tmpResult:Variant;
begin
  tmpSetResult:=False;
  tmpResult:=Unassigned;
  cnTray.Query(ITransferBlobFiles, tmpTransferBlobFiles);
  Case aTask of
      {44}tskMTBfCheckTransfer:Begin
            try
              tmpTransferBlobFiles.ITCheckTransferProcess;
            finally
              If VarType(aParams)=varInteger Then IThreadsPool(cnTray.Query(IThreadsPool)).ITMateSleepTaskAdd(tskMTBfCheckTransfer, aParams, aCallerAction.SenderParams, aCallerAction.SecurityContext, Integer(aParams), aTaskID, aTaskID);
            end;
          end;
      {45}//tskMTBfCheckActuality:Begin
            //Param( In):[0]-varInteger:(BlobID); [1][0]-varOleStr:(FileName); [1][1]-varDate:(Date); [1][2]-varInteger:(TotalSize)
            //Param(Out):[0]-varInteger:(BlobID); [1][0]-varOleStr:(FileName); [1][1]-varDate:(Date); [1][2]-varInteger:(TotalSize); [2]-varBoolean:(Actuality);
          //  tmpBlobfileInfo:=glVariantToBlobfileInfo(aParams[1]);
          //  tmpInteger:=aParams[0];
          //  tmpBoolean:=tmpTransferBlobFiles.ITCheckBlobfileActuality(aCallerAction, tmpInteger, tmpBlobfileInfo, nil);
          //  tmpSetResult:=True;
          //  tmpResult:=VarArrayOf([tmpInteger, glBlobfileInfoToVariant(tmpBlobfileInfo), tmpBoolean]);
          //end;
      {46}tskMTBfBeginDownload:Begin
            BfTaskImp_BgDn(tmpTransferBlobFiles, aCallerAction, aParams, tmpSetResult, tmpResult);
          end;
      {47}tskMTBfDownload:Begin
            BfTaskImp_Dn(tmpTransferBlobFiles, aCallerAction, aParams, tmpSetResult, tmpResult);
          end;
      {48}tskMTBfEndDownload:Begin
            BfTaskImp_EndDn(tmpTransferBlobFiles, aCallerAction, aParams, tmpSetResult, tmpResult);
          end;
      {49}tskMTBfBeginUpload:Begin
            Raise Exception.Create('!');
          end;
      {50}tskMTBfUpload:Begin
            Raise Exception.Create('!');
          end;
      {51}tskMTBfEndUpload:Begin
            Raise Exception.Create('!');
          end;
      {52}tskMTBfReceiveBeginDownload:Begin
            BfTaskImp_RcBgDn(tmpTransferBlobFiles, aCallerAction, aParams);
          end;
      {53}tskMTBfReceiveDownload:Begin
            BfTaskImp_RcDn(tmpTransferBlobFiles, aCallerAction, aParams);
          end;
//      {54}tskMTBfReceiveEndDownload:Begin
//            ?Raise Exception.Create('!');
//          end;
      {55}tskMTBfReceiveBeginUpload:Begin
            Raise Exception.Create('!');
          end;
      {56}tskMTBfReceiveUpload:Begin
            Raise Exception.Create('!');
          end;
      {57}tskMTBfReceiveEndUpload:Begin
            Raise Exception.Create('!');
          end;
      {58}tskMTBfReceiveErrorBeginDownload:Begin
            BfTaskImp_RcErBgDn(tmpTransferBlobFiles, aCallerAction, aParams);
          end;
      {59}tskMTBfReceiveErrorDownload:Begin
            BfTaskImp_RcErDn(tmpTransferBlobFiles, aCallerAction, aParams);
          end;
//      {60}tskMTBfReceiveErrorEndDownload:Begin
//            ?tmpString:=aParams[0];
//            tmpString1:=aParams[1];
//            tmpInteger:=aParams[2];
//            tmpTransferBlobFiles.ITReceiveErrorEndDownloadBlobfile(tmpString, tmpString1, tmpInteger);
//          end;
      {61}tskMTBfReceiveErrorBeginUpload:Begin
            Raise Exception.Create('!');
          end;
      {62}tskMTBfReceiveErrorUpload:Begin
            Raise Exception.Create('!');
          end;
      {63}tskMTBfReceiveErrorEndUpload:Begin
            Raise Exception.Create('!');
          end;
      {64}tskMTBfAddTransferDownload:Begin
            BfTaskImp_AddDn(tmpTransferBlobFiles, aCallerAction, aParams, tmpSetResult, tmpResult);
          end;
      {65}tskMTBfAddTransferUpload:Begin
            Raise Exception.Create('!');
          end;
          tskMTBfTransferCancel:Begin
            BfTaskImp_TransferCancel(tmpTransferBlobFiles, aCallerAction, aParams, tmpSetResult, tmpResult);
          end;
          tskMTBfReceiveTransferCanceled:Begin
            BfTaskImp_RcTransferCanceled(tmpTransferBlobFiles, aCallerAction, aParams);
          end;
          tskMTBfTransferTerminate:Begin
            BfTaskImp_TransferTerminate(tmpTransferBlobFiles, aCallerAction, aParams, tmpSetResult, tmpResult);
          end;
          tskMTBfReceiveTransferTerminated:Begin
            BfTaskImp_RcTransferTerminated(tmpTransferBlobFiles, aCallerAction, aParams);
          end;
          tskMTBfExists:begin
            BfTaskImp_LocalExists(tmpTransferBlobFiles, aCallerAction, aParams, tmpSetResult, tmpResult);
          end;
  else
    Raise Exception.CreateFmtHelp(cserInternalError, ['Unsupported for '+glTaskToStr(aTask)], cnerInternalError);
  end;
  If Assigned(aSetResult) then aSetResult^:=tmpSetResult;
  If Assigned(aResult) then aResult^:=tmpResult;
  VarClear(tmpResult);
end;






??
Procedure TMThread.InternalProcImplement(aDataCaseImplementEvent:TDataCaseImplementEvent);
  Type TExceptionMode=(exmNormal, exmPDTransport);
  Var MyParams, tmpV:Variant;
      iTask:TTask;
      tmpi, tmpi1, MySTTaskNum:Integer;
{$IFDEF PegasServer}ptrtmp:TAUPegas;{$ELSE}ptrtmp:TEAMServer;{$ENDIF}
      MySenderParams:Variant;      // aSenderPaHrams - ��������� �������� �����������. ������� �� TaskView.
        vlASMSenderNum:Integer;    // -K ����� ���������� ASM(��� ������� �� �������� ����������� ��� ����������� ASM)             // for aSenderParams
        vlSenderADMTaskNum:TADMTask;
        vlSenderPackCPID:Variant;    // - ID ������ ������������� ������������. ��� ������������� ������������ ����������� ������.  // for aSenderParams
        vlSenderPackPD:Variant;    // - �������� PD. ��� �������� ���������� ��� ������.                                          // for aSenderParams
        vlRouteParams:Variant;
      MySecurityContext:Variant;
      //..
      tmpWakeUp:TDateTime;
      MyTaskID:Integer;//task ID
      MyExceptionMode:TExceptionMode;
      //..
      tmpPD:TPDServer;
      //..
      tmpLocalDataBase:ILocalDataBase;
{$IFDEF PegasServer}
      tmpTableCommandMaster:TTableCommandMaster;
      tmpCPRHandlerServerPegas:TCPRHandlerServerPegas;
{$ENDIF}
{$IFDEF EAMServer}
      tmpPntr:Pointer;
      {$Warnings off}tmpCnn:IAUPegasDisp;{$Warnings on}
      tmpEventSink:IEventSink{TEventSink};
      tmpCookie:Longint;
      tmpCPRHandlerEMServer:TCPRHandlerEMServer;
{$ENDIF}
      tmpOleV:OleVariant;
      tmpParams:TParams;
      tmpBlockSQLExec:TBlockSQLExec;
      tmpStrQueue:TStrQueue;
      tmpSecurityContext, tmpSenderParams:Variant;
      tmpSt1, tmpSt2, tmpSt3:AnsiString;
      iStartTime:TDateTime;
      tmpBoolean:Boolean;
      tmpSt:AnsiString;
  Procedure _TaskSetExecute(_TaskNum:Integer);begin
    //if _TaskNum<>rstSTQueueNumNone then ?FThreadsPool.ITMateResSetExecute(_TaskNum);
  end;
  Procedure _TaskSetError(Const _Res:Variant; Const _ErrMess:AnsiString; _HelpContext:Integer; _DataCaseNum:Integer; Const _SenderPackID:Variant; _SenderPackPD:Variant; _SenderADMTaskNum:TADMTask; Const _SecurityContext:Variant);
  Var tmplPackCPR:IPackCPR;
  begin
    //If _DataCaseNum<>rstSTQueueNumNone Then FOwnerDataCase.ITMateResSetError(_DataCaseNum, _ErrMess); // �������� ��������� � DataCase
    If (VarType(_SenderPackPD) and varArray)=varArray Then begin
      //��������� �������� ����������
      Case MyExceptionMode of
        exmNormal:begin
          tmplPackCPR:=TPackCPR.Create;
          try
            tmplPackCPR.CPROptions:=[];
            tmplPackCPR.CPID:=_SenderPackID;
            tmplPackCPR.AddWithError(_SenderADMTaskNum, _Res, vlRouteParams, -1, GL_DataCase.stServerName+_ErrMess, _HelpContext);
            _SenderPackPD[Protocols_PD_Data]:=tmplPackCPR.AsVariant;
          finally
            tmplPackCPR:=Nil;
          end;
          //��������� ���������
          GL_DataCase.ITMateTaskAdd(tskMTPD, _SenderPackPD, Unassigned, _SecurityContext);
        end;
        exmPDTransport:begin
          _SenderPackPD[Protocols_PD_Error]:=VarArrayOf([_ErrMess, _Res, _HelpContext{061102}]);
          //��������� ���������
          GL_DataCase.ITMateTaskAdd(tskMTPD, _SenderPackPD, Unassigned, _SecurityContext);
        end;
      else
        Raise Exception.Create('MyExceptionMode?');
      end;
    end;
  end;
  Procedure _TaskSetErrorWithCustomSenderParams(Const _Res:Variant; Const _ErrMess:AnsiString; _HelpContext:Integer; Const _SenderParams,_SecurityContext:Variant);Begin
     If VarIsArray(_SenderParams) Then _TaskSetError(_Res, _ErrMess, _HelpContext, Integer(_SenderParams[0]), {Integer(}_SenderParams[1]{)}, _SenderParams[2], TADMTask(_SenderParams[3]), _SecurityContext)
     Else _TaskSetError(_Res, _ErrMess, _HelpContext, rstSTNoASM, tsiNoPackID, Unassigned, tskADMNone, _SecurityContext);
  end;
  Procedure _TaskSetComplete(Const _Res:Variant; _DataCaseNum:Integer; Const _SenderPackID:Variant; _SenderPackPD:Variant; _SenderADMTaskNum:TADMTask; Const _SecurityContext:Variant; _PackToCPR:Boolean); //Override;
  Var tmplPackCPR:IPackCPR;
  begin
    //If _DataCaseNum<>rstSTQueueNumNone Then FOwnerDataCase.ITMateResSetComplete(_DataCaseNum, _Res); // �������� ��������� � DataCase
    If VarIsArray(_SenderPackPD) Then begin
      //��������� �������� ����������
      If _PackToCPR then begin
        //��������� ����� ��������� � CPR
        tmplPackCPR:=TPackCPR.Create;
        try
          tmplPackCPR.CPROptions:=[];
          tmplPackCPR.CPID:=_SenderPackID;
          tmplPackCPR.Add(_SenderADMTaskNum, _Res, vlRouteParams, -1);
          _SenderPackPD[Protocols_PD_Data]:=tmplPackCPR.AsVariant;
        finally
          tmplPackCPR:=Nil;
        end;
      end else begin
        //��������� ����� �������� ��� ���������
        _SenderPackPD[Protocols_PD_Data]:=_Res;
      end;
      //��������� ���������
      GL_DataCase.ITMateTaskAdd(tskMTPD, _SenderPackPD, Unassigned, _SecurityContext);
    end;
  end;
  Procedure _TaskSetCompleteWithCustomSenderParams(Const _Res:Variant;  Const _SenderParams, _SecurityContext:Variant; _PackToCPR:Boolean=true);begin
     If VarIsArray(_SenderParams) Then _TaskSetComplete(_Res, Integer(_SenderParams[0]), Integer(_SenderParams[1]), _SenderParams[2], TADMTask(_SenderParams[3]), _SecurityContext, _PackToCPR)
     Else _TaskSetComplete(_Res, rstSTNoASM, tsiNoPackID, Unassigned, tskADMNone, _SecurityContext, _PackToCPR);
  end;
  Procedure _TaskSetStandartError(Const _Res:Variant; Const _ErrMess:AnsiString; _HelpContext:Integer=0);Begin
    _TaskSetError(_Res, _ErrMess, _HelpContext, MySTTaskNum, vlSenderPackCPID, vlSenderPackPD, vlSenderADMTaskNum, MySecurityContext);
  end;
  Procedure _TaskSetStandartComplete(Const _Res:Variant; _PackToCPR:Boolean=true);Begin
    _TaskSetComplete(_Res, MySTTaskNum, vlSenderPackCPID, vlSenderPackPD, vlSenderADMTaskNum, MySecurityContext, _PackToCPR);
  End;
  Procedure _GetCurrentUserNase(Const _SecurityContext:Variant);begin
    Try
      If Not VarIsArray(_SecurityContext) Then FUserName:='<Unassigned>' else
        FUserName:=VarToStr(_SecurityContext[0]);
    except
      FUserName:='<Invalid SecurityContext>';
    end;
  end;
begin
  iStartTime:=Now;
  Case aDataCaseImplementEvent of
    dieNewTask:begin
      iTask:=?FThreadsPool.ITMateTaskView(MyParams, MySTTaskNum, MySenderParams, MySecurityContext, MyTaskID);
      tmpWakeUp:=0;
    end;
    dieWakeupTask:begin
      iTask:=?FThreadsPool.ITMateSleepTaskView(MyParams, MySTTaskNum, MySenderParams, MySecurityContext, tmpWakeUp, MyTaskID);
    end;
  else
    Raise Exception.CreateFmtHelp(cserInternalError, ['Unknown aDataCaseImplementEvent'], cnerInternalError);
  end;
  if iTask=tskMTNone then exit;
  //..
      Try
        _GetCurrentUserNase(MySecurityContext);
        //������ ��������� �����������
        If VarIsArray(MySenderParams) Then begin//���� ������
            vlASMSenderNum:=MySenderParams[0];//for MySenderParams
            vlSenderADMTaskNum:=MySenderParams[3];
            vlSenderPackCPID:=MySenderParams[1];//for MySenderParams
            vlSenderPackPD:=MySenderParams[2];//for MySenderParams
            If VarArrayHighBound(MySenderParams, 1)>3 Then begin
              vlRouteParams:=MySenderParams[4];
            end else begin
              vlRouteParams:=Unassigned;
            end;
        end else begin//�� ������, ������� ������ ��������
          MySenderParams:=Unassigned;//MySenderParams
          vlASMSenderNum:=rstSTNoASM;//for MySenderParams
          vlSenderADMTaskNum:=tskADMNone;
          vlSenderPackCPID:=tsiNoPackID;//for MySenderParams
          vlSenderPackPD:=Unassigned;//MySenderParams
          vlRouteParams:=Unassigned;
        end;
        MyExceptionMode:=exmNormal;
(* �������� ����������
*** ���������� ������������. --------------------------------------------------------------------------------------
  iTask{TTask}                - ��������� ITMateSleepTaskView, �.�. Id �������� �������. | �������� ������������.
  MyParams{Variant}           - ��������� � �������� �������.                            | �������� ������������.
  MySTTaskNum{Integer}        - Id ������ � ������ ����������� ��� DataCase.             | ������������ � TaskAdd.
  MySecurityContext{Variant}  - �������� ���������� �������� �������.                    | �������� ������������.
  MyTaskID{Integer}           - Id �������� �������.                                     | �������� ������������ ��� ������������ � TaskAdd.
  MyExceptionMode             - ���������� ������ ��������� ����������.
*** ���������� ��� �������� ����������. ---------------------------------------------------------------------------
  MySenderParams{Variant}     - ��������� ��� �������� �����������. ������� �� TaskView.                                  | �������� ������������.
    vlASMSenderNum{Integer}   - ����� ASM (��� ������� �� �������� ����������� ��� ����������� ASM).                      | �������� ������������.
    vlSenderADMTaskNum
    vlSenderPackCPID{Integer}   - ID ������ ������������� ������������. ��� ������������� ������������ ����������� ������.  | �������� ������������.
    vlSenderPackPD{Variant}   - �������� PD. ��� �������� ���������� ��� ������.                                          | �������� ������������.
*** ������ --------------------------------------------------------------------------------------------------------
  aWakeUp{Integer}            - ����� � ������� ������� ������ ���� ����������. ����������� ��� SleepTask.                | �������� ������������.
*)      // ..
        If iTask<>tskMTNone then If GL_DataCase=Nil Then Raise Exception.Create('GL_DataCase=Nil. ���������� ��������� ������������.') else GL_DataCase.ITCheckSecurityMTask(iTask, MySecurityContext);
        Case iTask of
// ..........
          tskMTSetPerpetualMate:begin
            FBeginTimeOfInactivity:=now;
            FIsPerpetualMate:=True;     // ��������� Mate ����������� �� �����������
            _TaskSetStandartComplete(Unassigned);//_TaskSetComplete(Unassigned, MySTTaskNum, vlSenderPackCPID, vlSenderPackPD, vlSenderADMTaskNum);
          end;
// ..........
// ..........
          tskMTDestroyMate:begin
              If Pointer(Integer(MyParams))=Self Then begin
                ?FThreadsPool.ITDropOneMateFromArray(Self);
                FreeOnTerminate:=True;
                Terminate;
                _TaskSetStandartComplete(Unassigned);
                Exit;//Continue;
              end else begin
                If FOwnerDataCase.ITFreeAndDropOneMateFromArray(Pointer(Integer(MyParams)))= True Then
                  _TaskSetStandartComplete(Unassigned) else _TaskSetStandartError(Unassigned, 'Mate �� ������.');
              end;
          end;
// ..........
          tskMTStopAllASM:begin
// In Empty
              If GL_DataCase=Nil Then Raise Exception.Create('GL_DataCase=Nil');
              InternalSetMessage(iStartTime, 'tskMTStopAllASM.', mecApp, mesWarning);
              _TaskSetStandartComplete(GL_DataCase.ITAdmittanceASM_StopAllASMServers);
// Out varInteger:(Count)
          end;
// ..........
          tskMTStopASMOnID:begin
// In varInteger:(ASMID)
              If GL_DataCase=Nil Then Raise Exception.Create('GL_DataCase=Nil');
              InternalSetMessage(iStartTime, 'tskMTStopASMOnID: for ASMId '+IntToStr(Integer(MyParams))+'.', mecApp, mesWarning);
              _TaskSetStandartComplete(GL_DataCase.ITAdmittanceASM_StopASMServerOnID(MyParams));
// Out varInteger:(Count)
          end;
// ..........
          tskMTStopASMOnUser:begin
// In varString:(ASMUser)
              If GL_DataCase=Nil Then Raise Exception.Create('GL_DataCase=Nil');
              InternalSetMessage(iStartTime, 'tskMTStopASMOnUser: for user '''+VarToStr(MyParams)+'''.', mecApp, mesWarning);
              _TaskSetStandartComplete(GL_DataCase.ITAdmittanceASM_StopASMServerOnUser(MyParams));
// Out varInteger:(Count)
          end;
// ..........
          tskMTSendMessToId:begin
// In MyParams: [0]-varInteger:stASMId(�����) [1]-varArray:vlDataToSend(������ ��� ITSendEvent)
              MyExceptionMode:=exmPDTransport;
// In MyParams: [0]-varInteger(ASM ID); [1]-varInteger(EventID); [2]-varArray(Data); [3]-varInteger(��������); [4]-varInteger(�����. �������)
              GL_DataCase.ITMateTaskAdd(tskMTSendEvent,
                VarArrayOf([MyParams[0], evnOnMessage, MyParams[1], vlSendEventInterval, vlSendEventAttempt]),
                VarArrayOf([vlASMSenderNum, vlSenderPackCPID, vlSenderPackPD, vlSenderADMTaskNum]), MySecurityContext, MyTaskID, MyTaskID);
          end;
// ..........
          tskMTSendMessToUser:begin
              MyExceptionMode:=exmPDTransport;
// In MyParams: [0]-stUserName(���) [1]-vlDataToSend(������ ��� ITSendEvent)
              tmpV:=Unassigned;
              tmpi:=0;
              ptrtmp:=nil;
              Repeat
                If (FOwnerDataCase<>Nil) and (GL_DataCase<>Nil) Then begin
                  If (VarType(tmpV) and varArray)=varArray Then ptrtmp:=Pointer(Integer(tmpV[5]))
                    else ptrtmp:=nil;
                  tmpV:=FOwnerDataCase.ITAdmittanceASM_GetInfoNextASMAndLock(ptrtmp);
                end else
                  tmpV:=Unassigned;
                // ..
                If (VarType(tmpV) and varArray)=varArray Then begin
                  // ���� ��� �� ������� ������ � ����������
                  try
                    If AnsiString(tmpV[1])=AnsiString(MyParams[0]) Then begin
                      // ����� ASM ������� ������������
                      GL_DataCase.ITMateTaskAdd(tskMTSendEvent,
                        VarArrayOf([tmpV[0], evnOnMessage, MyParams[1], vlSendEventInterval, vlSendEventAttempt]),
                        VarArrayOf([vlASMSenderNum, vlSenderPackCPID, vlSenderPackPD, vlSenderADMTaskNum]), MySecurityContext);
                    end;
                  finally
                    FOwnerDataCase.ITAdmittanceASM_UnLock(ptrtmp);
                  end;
                end else begin
                  // ���������
                  Break;
                end;
              Until False;
              _TaskSetStandartComplete(tmpi);
// Out Res: [0]-varinteger:(������� ��������� ����������)
          end;
// ..........
          tskMTSendMessToAll:
          begin
              MyExceptionMode:=exmPDTransport;
// In MyParams: [0]-vlDataToSend(������ ��� ITSendEvent)
              tmpi:=0;
              ptrtmp:=nil; tmpV:=Unassigned;
              Repeat
                If (FOwnerDataCase<>Nil) and (GL_DataCase<>Nil) Then begin
                  tmpV:=FOwnerDataCase.ITAdmittanceASM_GetInfoNextASMAndLock(ptrtmp);
                end else
                  tmpV:=Unassigned;
                // ..
                If (VarType(tmpV)and varArray)=varArray Then begin
                  try
                    ptrtmp:=Pointer(Integer(tmpV[5]));
                    GL_DataCase.ITMateTaskAdd(tskMTSendEvent,
                      VarArrayOf([tmpV[0], evnOnMessage, MyParams, vlSendEventInterval, vlSendEventAttempt]),
                      VarArrayOf([vlASMSenderNum, vlSenderPackCPID, vlSenderPackPD, vlSenderADMTaskNum]), MySecurityContext);
(*                    // ����� ASM
                    If ptrtmp.ITSendEvent(evnOnMessage, MyParams) Then // ��������� ���������
                      Inc(tmpi); // ������� ������������ ���������  *)
                  finally
                    FOwnerDataCase.ITAdmittanceASM_UnLock(ptrtmp);
                  end;
                end else begin
                  // ���������
                  Break;
                end;
              Until False;
              _TaskSetStandartComplete(tmpi);
// Out Res: [0]-varinteger:(������� ��������� ����������)
          end;
// ..........
          tskMTSendEvent:begin
// In MyParams: [0]-varInteger(ASM ID); [1]-varInteger(EventID); [2]-varArray(Data); [3]-varInteger(��������); [4]-varInteger(�����. �������)
              MyExceptionMode:=exmPDTransport;
              tmpi:=0;
              // ���� addr ASM
              ptrtmp:=FOwnerDataCase.ITAdmittanceASM_GetPntrOnIdAndLock(MyParams[0]);
              // �������� �� Nil
              If ptrtmp=Nil Then Raise Exception.Create('�� ������� ��������� �������, ASMNum='+IntToStr(MyParams[0])+' �� ����������.');
              try
                // ������ ���������
                Case ptrtmp.ITSendEvent(MyParams[1], MyParams[2], MySecurityContext, vlWiatForUnLockSendEvent, True{evnOnPack<>MyParams[1]{Show send pack message}) of
                  tslError:Raise Exception.Create('������� ��� ASMNum='+IntToStr(MyParams[0])+'.');
                  tslTimeOut:begin
                    // �������� ������� � ����������� ��������
                    If MyParams[4]>0 then begin
                      If MyParams[4]=1 then InternalSetMessage(iStartTime, 'ITSendEvent: ����� �������� ����� ����� UnLock(ASMNum='+IntToStr(Integer(MyParams[0]))+', EventID='+IntToStr(Integer(MyParams[1]))+', Attempt='+IntToStr(Integer(MyParams[4]))+').', mecDebug, mesWarning);
                      GL_DataCase.ITMateSleepTaskAdd(tskMTSendEvent,
                        VarArrayOf([MyParams[0], MyParams[1], MyParams[2], MyParams[3], MyParams[4]-1]),
                        VarArrayOf([vlASMSenderNum, vlSenderPackCPID, vlSenderPackPD, vlSenderADMTaskNum]), MySecurityContext, LongWord(MyParams[3]), MyTaskID, MyTaskID);
                    end else begin
                      // ��������� �� ����� ����������, ��� ����������� ���������
                      Raise Exception.Create('������� ��� ASMNum='+IntToStr(MyParams[0])+' �� ����� ����������, ����� �������=0.');
                    end;
                  end;
                  tslOk: begin
                    Inc(tmpi); // ������� ������������ ���������;
                    //�������� � ��� ��������� �� �������� ������� �������
(*                    If evnOnPack=MyParams[1] Then begin
{���}       try If GL_DataCase<>Nil Then
GL_DataCase.ITMessAdd(Now, FOperationStartTime, ptrtmp, ?istUserName, 'ASM#'+IntToStr(MyParams[0]), 'Event(Pack/'+itmpSt+')', mecTransport, mesInformation);
{���}       except end;
                    end;*)
                    //InternalSetMessage(iStartTime, 'tskMTSendEvent: ������� ����������(ASMNum='+IntToStr(Integer(MyParams[0]))+').', mecTransport, mesInformation);
                  end;
                else
                  raise exception.create('�� ��������� �������� ITSendEvent(tsl???).');
                end;
              finally
                FOwnerDataCase.ITAdmittanceASM_UnLock(ptrtmp);
              end;
              _TaskSetStandartComplete(tmpi);
          end;
// ..........
          tskMTSendEventToOneOfList:begin
// In MyParams: [0]-varArray of Integer(ASM ID); [1]-varInteger(EventID); [2]-varArray(Data); [3]-varInteger(��������); [4]-varInteger(�����. �������)
              MyExceptionMode:=exmPDTransport;
              Raise Exception.Create('tskMTSendEventToOneOfList �� ����������.');
          end;
// ..........
          tskMTSendEventViaBridge:Begin
// In MyParams: [0]-varInteger(ID Shop); [1]-varInteger(EventID); [2]-varArray(Data); [3]-varInteger(��������); [4]-varInteger(�����. �������)
              MyExceptionMode:=exmPDTransport;
{$IFDEF PegasServer}
              tmpV:=Unassigned;
              ptrtmp:=nil;
              Repeat
                If (FOwnerDataCase<>Nil) and (GL_DataCase<>Nil) Then begin
                  If (VarType(tmpV) and varArray)=varArray Then ptrtmp:=Pointer(Integer(tmpV[5]))
                    else ptrtmp:=nil;
                  tmpV:=FOwnerDataCase.ITAdmittanceASM_GetInfoNextASMAndLock(ptrtmp);
                end else
                  tmpV:=Unassigned;
                // �������� ��� �������
                If (VarType(tmpV) and varArray)=varArray Then begin
                  // ���� ��� �� ������� ������ � ����������
                  try
                    ptrtmp:=Pointer(Integer(tmpV[5]));
                    If ((Integer(tmpV[4]) and msk_rsBridge)=msk_rsBridge) And (Integer(MyParams[0])=(Integer(tmpV[7]))) Then begin
                      // ��� ���� � ������� EAMS
                      // ������ ��������� ����� ���� ����
                      Case ptrtmp.ITSendEvent(MyParams[1], MyParams[2], MySecurityContext, vlWiatForUnLockSendEvent, True) of
                        tslError, tslTimeOut:{tmpi:=0};
                        tslOk: begin
                          //InternalSetMessage(iStartTime, 'tskMTSendEventViaBridge: ������� ����������(BridgeID='+IntToStr(Integer(MyParams[0]))+').', mecTransport, mesInformation);
                          Break;
                        end;
                      else
                        raise exception.create('�� ��������� �������� ITSendEvent(tsl???).');
                      end;
                    End;
                  finally
                    FOwnerDataCase.ITAdmittanceASM_UnLock(ptrtmp);
                  end;
                  //
                end else begin
                  // ASM ���������, ��� ����� ��� ����� ��� ������
                  // �� ��������
                  // �������� ������� � ����������� ��������
                  If MyParams[4]>0 then begin
                    GL_DataCase.ITMateSleepTaskAdd(tskMTSendEventViaBridge,
                      VarArrayOf([MyParams[0], MyParams[1], MyParams[2], MyParams[3], MyParams[4]-1]),
                      VarArrayOf([vlASMSenderNum, vlSenderPackCPID, vlSenderPackPD, vlSenderADMTaskNum]), MySecurityContext, LongWord(MyParams[3]), MyTaskID, MyTaskID);
                  end else begin
                    // ��������� �� ����� ����������, ��� ����������� ���������
                    Raise Exception.Create('������� �� ����� ����������, ����� �������=0.');
                  end;
                  Break;
                end;
              Until False;
{$ELSE}
              Raise Exception.Create('������� �� ��������� ��� EMServer.');
{$ENDIF}
          end;
// ..........
          tskMTSendCommand:Begin
// In MyParams: [0]-varInteger(ID ASM); [1]-varInteger(EventID); [2]-varArray(Data); [3]-varInteger(��������); [4]-varInteger(�����. �������)
              MyExceptionMode:=exmPDTransport;
{$IFDEF PegasServer}
              Raise Exception.Create('������� �� ��������� ��� PegasServer.');
{$ELSE}
              tmpV:=Unassigned;
              tmpi:=0;
              ptrtmp:=nil;
              Repeat
                If (FOwnerDataCase<>Nil) and (GL_DataCase<>Nil) Then begin
                  If (VarType(tmpV) and varArray)=varArray Then ptrtmp:=Pointer(Integer(tmpV[5]))
                    else ptrtmp:=nil;
                  tmpV:=FOwnerDataCase.ITAdmittanceASM_GetInfoNextASMAndLock(ptrtmp);
                end else
                  tmpV:=Unassigned;
                // �������� ��� �������
                If (VarType(tmpV) and varArray)=varArray Then begin
                  // ���� ��� �� ������� ������ � ����������
                  try
                    ptrtmp:=Pointer(Integer(tmpV[5]));
                    If Integer(tmpV[0])=Integer(MyParams[0]) Then begin
                      // ��� ���� � ������� EAMS
                      // ������ ��������� ����� ���� ����
{``}                      Case ptrtmp.ITSendCommand(MyParams[1], MyParams[2], MySecurityContext, vlWiatForUnLockSendEvent, True) of
                        tslError, tslTimeOut:tmpi:=0;
                        tslOk: begin
                          //InternalSetMessage(iStartTime, 'tskMTSendCommand: ������� ����������(ASM#'+IntToStr(Integer(MyParams[0]))+').', mecTransport, mesInformation);
                          Inc(tmpi); // ������� ������������ ���������;
                          Break;
                        end;
                      else
                        raise exception.create('�� ��������� �������� ITSendEvent(tsl???).');
                      end;
                    End;
                  finally
                    FOwnerDataCase.ITAdmittanceASM_UnLock(ptrtmp);
                  end;
                  //
                end else begin
                  // ASM ���������, ��� ����� ��� ����� ��� ������
                  // �� ��������
                  // �������� ������� � ����������� ��������
                  If MyParams[4]>0 then begin
                    GL_DataCase.ITMateSleepTaskAdd(tskMTSendCommand,
                      VarArrayOf([MyParams[0], MyParams[1], MyParams[2], MyParams[3], MyParams[4]-1]),
                      VarArrayOf([vlASMSenderNum, vlSenderPackCPID, vlSenderPackPD, vlSenderADMTaskNum]), MySecurityContext, LongWord(MyParams[3]), MyTaskID, MyTaskID);
                  end else begin
                    // ��������� �� ����� ����������, ��� ����������� ���������
                    Raise Exception.Create('������� �� ����� ����������, ����� �������=0.');
                  end;
                  Break;
                end;
              Until False;
              If tmpi>0 Then
                _TaskSetStandartComplete(tmpi);
{$ENDIF}
          end;
// ..........
          tskMTSendCommandViaBridge:Begin
// In MyParams: [0]-varInteger(ID Shop); [1]-varInteger(EventID); [2]-varArray(Data); [3]-varInteger(��������); [4]-varInteger(�����. �������)

// In MyParams:                          [0]-varInteger(EventID); [1]-varArray(Data); [2]-varInteger(��������); [3]-varInteger(�����. �������)
              MyExceptionMode:=exmPDTransport;
{$IFDEF PegasServer}
              Raise Exception.Create('������� �� ��������� ��� PegasServer.');
{$ELSE}
              tmpV:=Unassigned;
              ptrtmp:=nil;
              Repeat
                If (FOwnerDataCase<>Nil) and (GL_DataCase<>Nil) Then begin
                  If (VarType(tmpV) and varArray)=varArray Then ptrtmp:=Pointer(Integer(tmpV[5]))
                    else ptrtmp:=nil;
                  tmpV:=FOwnerDataCase.ITAdmittanceASM_GetInfoNextASMAndLock(ptrtmp);
                end else
                  tmpV:=Unassigned;
                // �������� ��� �������
                If (VarType(tmpV) and varArray)=varArray Then begin
                  // ���� ��� �� ������� ������ � ����������
                  try
                    ptrtmp:=Pointer(Integer(tmpV[5]));
                    If ((Integer(tmpV[4]) and msk_rsBridge)=msk_rsBridge)And(Integer(MyParams[0])=vlEAMServerLocalBaseID{(Integer(tmpV[7]))}) Then begin
                    //If (Integer(tmpV[4]) and msk_rsBridge)=msk_rsBridge Then begin
                      // ��� ����
                      // ������ ��������� ����� ���� ����
                      Case ptrtmp.ITSendCommand(MyParams[1], MyParams[2], MySecurityContext, vlWiatForUnLockSendEvent, True) of
                        tslError, tslTimeOut:;//tmpi:=0;
                        tslOk: begin
                          //InternalSetMessage(iStartTime, 'tskMTSendCommandViaBridge: ������� ����������(BridgeID='+IntToStr(Integer(MyParams[0]))+').', mecTransport, mesInformation);
                          Break;
                        end;
                      else
                        raise exception.create('�� ��������� �������� ITSendEvent(tsl???).');
                      end;
                    End;
                  finally
                    FOwnerDataCase.ITAdmittanceASM_UnLock(ptrtmp);
                  end;
                  //
                end else begin
                  // ASM ���������, ��� ����� ��� ����� ��� ������
                  // �� ��������
                  // �������� ������� � ����������� ��������
                  If MyParams[4]>0 then begin
                    GL_DataCase.ITMateSleepTaskAdd(tskMTSendCommandViaBridge,
                      VarArrayOf([MyParams[0], MyParams[1], MyParams[2], MyParams[3], MyParams[4]-1]),
                      VarArrayOf([vlASMSenderNum, vlSenderPackCPID, vlSenderPackPD, vlSenderADMTaskNum]), MySecurityContext, LongWord(MyParams[3]), MyTaskID, MyTaskID);
                  end else begin
                    // ��������� �� ����� ����������, ��� ����������� ���������
                    Raise Exception.Create('������� �� ����� ����������, ����� �������=0.');
                  end;
                  Break;
                end;
              Until False;
{$ENDIF}
          End;
// ..........
          tskMTShotDownServer:begin
// In MyParams: [0]-varInteger(���������� ���������); [1]-varInteger(����� ����� ����������); [2]-varOleStr(����� ��������)
              InternalSetMessage(iStartTime, 'tskMTShotDownServer', mecApp, mesWarning);
              If MyParams[0]>0 Then begin
                tmpi:=MyParams[0]-1;
                if tmpi=0 then tmpi:=-1;  // ����� ����� ���� ������� ������� �������� 0 ��� �� ����
                GL_DataCase.ITMateTaskAdd(tskMTSendMessToAll, VarArrayOf([FUserName, MyParams[2]+'(�������� '+IntToStr(MyParams[0]*MyParams[1] div 60000)+'���. '+IntToStr((MyParams[0]*MyParams[1] mod 60000) div 1000)+'���.)']), VarArrayOf([vlASMSenderNum, vlSenderPackCPID, vlSenderPackPD, vlSenderADMTaskNum]), MySecurityContext{VarArrayOf([vlASMSenderNum, vlPlaceResult, vlSenderTaskID])});
                GL_DataCase.ITMateSleepTaskAdd(tskMTShotDownServer, VarArrayOf([Integer(tmpi), MyParams[1], MyParams[2]]), VarArrayOf([vlASMSenderNum, vlSenderPackCPID, vlSenderPackPD, vlSenderADMTaskNum]), MySecurityContext, LongWord(MyParams[1]), MyTaskID, MyTaskID);
                _TaskSetExecute(MySTTaskNum);
              end else begin
                If MyParams[0]=0 then begin
                  // ���� 0 ��� ��������� ����� ��� ���������
                  GL_DataCase.ITMateSleepTaskAdd(tskMTShotDownServerImmediately, unassigned, unassigned, MySecurityContext, LongWord(MyParams[1]), MyTaskID, MyTaskID);
                end else begin
                  // ���� <0 ����� ��������
                  GL_DataCase.ITMateTaskAdd(tskMTShotDownServerImmediately, unassigned, unassigned, MySecurityContext, MyTaskID, MyTaskID);
                end;
                _TaskSetStandartComplete(Unassigned);
              end;
// Out Res: [0]-varinteger:(������� ��������� ����������)
          end;
          tskMTShotDownServerImmediately:begin
// In MyParams: Emty
              If MForm<>Nil Then begin
                InternalSetMessage(iStartTime, 'tskMTShotDownServerImmediately', mecApp, mesWarning);
                FOwnerDataCase.ITShotDown:=True;
                _TaskSetStandartComplete(Unassigned);
              end else begin
                _TaskSetStandartError(Unassigned, '���������� ��������� ������, �.�. MForm=Nil.');
              end;
// Out Res: Empty
          end;
// .....
          tskMTUpdateASMList:begin
// In MyParams: [0]:varInteger(ASMNum); [1]:varArray(ASM Info)
              GL_DataCase.ITAdmittanceASM_ListUpdate(MyParams[0], MyParams[1]);
              _TaskSetStandartComplete(Unassigned);
// Out Res: Empty
          end;
// .....
          tskMTCancelTask:begin
// In MyParams: varInteger(TaskID);
              _TaskSetStandartComplete(Boolean(GL_DataCase.ITMateTaskCancel(MyParams)));
// Out Res: varBoolean(Canceled or no)
          end;
// .....
          tskMTIgnoreTaskAdd:begin
// In MyParams: varInteger(TaskID);
              FOwnerDataCase.ITMateIgnoreTaskAdd(MyParams);
              _TaskSetStandartComplete(Unassigned);
// Out Res: Empty
          end;
// .....
          tskMTIgnoreTaskCancel:begin
// In MyParams: varInteger(TaskID);
              _TaskSetStandartComplete(FOwnerDataCase.ITMateIgnoreTaskCancel(MyParams));
// Out Res: varBoolean(Canceled or no)
          end;
// .....
      {22}tskMTPD:begin
// In MyParams: varVariant(Data(Protocol_PD));
              tmpPD:=TPDServer.Create;
              Try
                tmpPD.Data:=MyParams;
                tmpPD.SecurityContext:=MySecurityContext;
                tmpPD.SenderParams:=MySenderParams;
                tmpPD.ServerName:=GL_DataCase.stServerName;
{$IFDEF PegasServer}
                tmpCPRHandlerServerPegas:=TCPRHandlerServerPegas.Create(GL_DataCase);
                try
                  tmpCPRHandlerServerPegas.SecurityContext:=MySecurityContext;
                  tmpPD.OnReceiveCPR1:=tmpCPRHandlerServerPegas.ReceiveCPR1;
                  tmpPD.OnReceiveCPR1Error:=tmpCPRHandlerServerPegas.ReceiveCPR1Error;
                  tmpPD.OnTransportError:=tmpCPRHandlerServerPegas.TransportError;
                  tmpPD.Hop;
                finally
                  FreeAndNil(tmpCPRHandlerServerPegas);
                end;
{$ELSE}
                tmpCPRHandlerEMServer:=TCPRHandlerEMServer.Create(GL_DataCase);
                try
                  tmpPD.OnReceiveCPR1:=tmpCPRHandlerEMServer.ReceiveCPR1;
                  tmpPD.OnReceiveCPR1Error:=tmpCPRHandlerEMServer.ReceiveCPR1Error;
                  tmpPD.OnTransportError:=tmpCPRHandlerEMServer.TransportError;
                  tmpPD.Hop;
                finally
                  FreeAndNil(tmpCPRHandlerEMServer);
                end;
{$ENDIF}
                If (tmpPD.BuildResult)And(Not VarIsEmpty(tmpPD.Result)) Then begin
                  _TaskSetStandartComplete(tmpPD.Result, false);
                end;
              Finally
                FreeAndNil(tmpPD);
              end;
// Out Res: Empty
          end;
      {36}tskMTCPT:begin
// In MyParams: ?
              Raise Exception.Create('!!');
// Out Res: Empty
          end;
      {37}tskMTCPR:begin
// In MyParams: ?
            Raise Exception.Create('!!');
// Out Res: Empty
          end;
          tskMTBlockSQLExec:begin
// In MyParams: [0]-varInteger:(tmpBlockId); [1]-varArray:([0]-Id SQL Command;[1]-tmpBlock:[0..n]-varOleStr:(SQLCommand); [2]-varVariant:(SQLParams));          ???[2]-varInteger:(Option CPT)
            {MyIntBeginTask;
            try}
{-$IFDEF PegasServer}
              Raise Exception.Create('������� �� ��������� ��� PegasServer.');
{-$ELSE}
              tmpBlockSQLExec:=TBlockSQLExec.Create;
              try
                tmpBlockSQLExec.DataCase{Message}:=GL_DataCase;
                tmpBlockSQLExec.Data:=MyParams;
                tmpBlockSQLExec.SecurityContext:=MySecurityContext;
                tmpBlockSQLExec.Exec;
                If tmpBlockSQLExec.BuildResult Then begin
                  // ���� ��������� ����������
                  _TaskSetStandartComplete(tmpBlockSQLExec.Result);
                end;
                If tmpBlockSQLExec.NextTimeRequire Then begin
                  // �������� ������� � ����� ������� �������� ����������
                  // ������ �� ��������� ����������
                  GL_DataCase.ITMateWakeUpTaskAdd(tskMTBlockSQLExec, tmpBlockSQLExec.NextTimeData, MySenderParams, MySecurityContext, TimeStampToDateTime(MSecsToTimeStamp(tmpBlockSQLExec.NextTimeWakeup)), MyTaskID, MyTaskID);
                end;
              finally
                FreeAndNil(tmpBlockSQLExec);
              end;
{-$ENDIF}
// Out Res: Empty
          end;
          tskMTConnectBridge:begin
{$IFDEF PegasServer}
              Raise Exception.Create('������� �� ��������� ��� PegasServer.');
{$ELSE}
              If FOwnerDataCase.ITAdmittanceASM_Lock(Pointer(Integer(MyParams)))<1 Then Raise Exception.Create('tskMTConnectBridge: ITAdmittanceASM_Lock<1.');
              Try
                try
                  TEAMServer(Pointer(Integer(MyParams))).ITCreateBridge;
                except
                  If GL_DataCase.ITOnLineStatus Then begin
                    //  ��� OnLine. ���� ���� ���������� ������ ��� ��� ������� �� �����.
                    GL_DataCase.ITMateSleepTaskAdd(tskMTConnectBridge, MyParams, MySenderParams, MySecurityContext, 15000, MyTaskID, MyTaskID);
                  end;
                  // � ���� OffLine �������� ������ ITCreateBridge(� ������� ����������) � ��������, � ��� SetOnLine ���� ��������������.
                  Raise;
                end;
              Finally
                FOwnerDataCase.ITAdmittanceASM_UnLock(Pointer(Integer(MyParams)));
              End;
{$ENDIF}
          end;
          tskMTCreateBridge:begin
// In MyParams: Empty
{$IFDEF PegasServer}
              Raise Exception.Create('������� �� ��������� ��� PegasServer.');
{$ELSE}
              tmpPntr:=GL_AOF_ASM.CreateComObject(Nil);
              GL_DataCase.ITMateTaskAdd(tskMTConnectBridge, Integer(Pointer(tmpPntr)), MySenderParams, MySecurityContext, MyTaskID, MyTaskID);
{$ENDIF}
// Out Res: Empty
          end;
          tskMTTableCommand:begin
// In MyParams: [0]-varVariant:(PD); [1]-varInteger:(interval)
{$IFDEF PegasServer}
              Try
                 tmpTableCommandMaster:=TTableCommandMaster.Create(GL_DataCase);
                 try
                   //tmpTableCommandMaster.DataCase:=GL_DataCase;
                   tmpTableCommandMaster.SecurityContext:=MySecurityContext;
                   While True do begin
                     tmpTableCommandMaster.Exec;
                     If tmpTableCommandMaster.ResultCount<1 Then Break;
                     For tmpi:=0 to tmpTableCommandMaster.ResultCount-1 do begin
                       GL_DataCase.ITMateTaskAdd(tskMTPD, tmpTableCommandMaster.Result[tmpi], MySenderParams, MySecurityContext);
                     end;
                     Sleep(1000);
                   end;
                 finally
                   FreeAndNil(tmpTableCommandMaster);
                 end;
              Finally
                // ������ �� ����������
                GL_DataCase.ITMateSleepTaskAdd(tskMTTableCommand, MyParams, MySenderParams, MySecurityContext, Integer(MyParams[1]), MyTaskID, MyTaskID);
              end;
{$ELSE}
              Raise Exception.Create('������� �� ��������� ��� EMServer.');
{$ENDIF}
// Out Res: Empty
          end;
          tskMTMessToLog:Begin
// In MyParams: [0]-varInteger:(Time Interval);
              try
                tmpLocalDataBase:=TLocalDataBase.Create(GL_DataCase);
                Try
                  tmpLocalDataBase.SecurityContext:=MySecurityContext;
                  //tmpLocalDataBase.DataCase:=GL_DataCase;
                  tmpParams:=TParams.Create;
                  Try
                    tmpV:=GL_DataCase.ITGetNewMess(GL_Log_Longint, xmecApp Or xmecSQL Or xmecDebug Or xmecSecurety{15}, xmesError Or xmesInfo Or xmesWarning{7});
                    If (VarType(tmpV)And varArray)=varArray Then begin
                      For tmpi:=VarArrayLowBound(tmpV, 1) to VarArrayHighBound(tmpV, 1) do begin
                        tmpParams.Clear;
                        With tmpParams.CreateParam(ftString, 'LDate', ptUnknown) do AsString:=tmpV[tmpi][0];
                        With tmpParams.CreateParam(ftString, 'LClass', ptUnknown) do AsString:=tmpV[tmpi][5];
                        With tmpParams.CreateParam(ftString, 'LType', ptUnknown)  do AsString:=tmpV[tmpi][6];
                        With tmpParams.CreateParam(ftString, 'lAddr', ptUnknown)  do AsString:=tmpV[tmpi][1];
                        With tmpParams.CreateParam(ftString, 'lSource', ptUnknown)do AsString:=tmpV[tmpi][3];
                        With tmpParams.CreateParam(ftString, 'lUser', ptUnknown)  do AsString:=tmpV[tmpi][2];
                        With tmpParams.CreateParam(ftString, 'lThrId', ptUnknown) do AsString:=tmpV[tmpi][7];
                        With tmpParams.CreateParam(ftString, 'lMess', ptUnknown)  do
                          If Length(VarToStr(tmpV[tmpi][4]))>255 Then begin
                            AsString:=Copy(VarToStr(tmpV[tmpi][4]), 1, 255);
                            With tmpParams.CreateParam(ftString, 'LMessExt', ptUnknown)  do
                              If Length(VarToStr(tmpV[tmpi][4]))>510 Then begin
                                AsString:=Copy(VarToStr(tmpV[tmpi][4]), 256, 252)+'>>>';
                              end else begin
                                AsString:=Copy(VarToStr(tmpV[tmpi][4]), 256, Length(VarToStr(tmpV[tmpi][4]))-256);
                              end;
                          End Else begin
                            AsString:=tmpV[tmpi][4];
                            With tmpParams.CreateParam(ftString, 'LMessExt', ptUnknown)  do
                              AsString:='-';
                          end;
                        For tmpi1:=0 to tmpParams.Count-1 do
                          If tmpParams.Items[tmpi1].DataType=ftString Then
                            If tmpParams.Items[tmpi1].AsString='' Then tmpParams.Items[tmpi1].AsString:='-';
                        tmpOleV:=PackageParams(tmpParams);
                        tmpLocalDataBase.MessAdd:=False;
                        tmpLocalDataBase.ExecSQL('INSERT INTO ssInternalMainLog(LDate,LClass,LType,LAddr,LSource,LUser,LMess,LMessExt,LThreadId)VALUES(:LDate,:LClass,:LType,:LAddr,:LSource,:LUser,:LMess,:LMessExt,:lThrId)', tmpOleV);
                      end;
                    end;
                  Finally
                    FreeAndNil(tmpParams);
                  End;
                Finally
                  try tmpLocalDataBase:=Nil; except end;
                  // ������ �� ��������� ����������
                  GL_DataCase.ITMateSleepTaskAdd(tskMTMessToLog, MyParams, MySenderParams, MySecurityContext, Integer(MyParams), MyTaskID, MyTaskID);
                End;
              except end;
// Out Res: Empty
          end;
          tskMTOnLineCheck:begin
// In MyParams: VarInteger:Interval
{$IFDEF PegasServer}
              Raise Exception.Create('������� �� ��������� ��� PegasServer.');
{$ELSE}
              Try
                If Gl_DataCase.ITOnLineMode=olmAuto Then begin
                  Try
                    // �������� �����. ������� �1.
                    {$Warnings off}tmpcnn:=IAUPegasDisp(CreateRemoteComObject(stEComputerName, StringToGUID(stEComputerGUID)) as IDispatch);{$Warnings on}
                    try
                      tmpEventSink:=TEventSink.Create;
                      try
{$Warnings off}         tmpEventSink.IIDEvents:=IAUPegasEvents;
                        tmpEventSink.OnInvoke:=nil;
                        tmpEventSink.InterfaceConnectEx(tmpcnn, {IAUPegasEvents,} tmpEventSink, tmpCookie);
{$Warnings on}          try
                          //Ok
                        finally
{$Warnings off}           tmpEventSink.InterfaceDisconnectEx(tmpcnn, {IAUPegasEvents,} tmpCookie);{$Warnings on}
                        end;
                      finally
                        tmpEventSink:=nil;
                      end;
                    finally
                      tmpcnn:=Nil;
                    end;
                    If GL_DataCase<>Nil Then GL_DataCase.ITSetOnLineStatus(True, MySecurityContext);
                  Except
                    try
                      // �������� ����� ��������. ������� �2.
{$Warnings off}       tmpcnn:=IAUPegasDisp(CreateRemoteComObject(stEComputerName, StringToGUID(stEComputerGUID)) as IDispatch);
{$Warnings on}        try
                        tmpEventSink:=TEventSink.Create;
                        try
{$Warnings off}           tmpEventSink.IIDEvents:=IAUPegasEvents;
                          tmpEventSink.OnInvoke:=nil;
                          tmpEventSink.InterfaceConnectEx(tmpcnn, {IAUPegasEvents,} tmpEventSink, tmpCookie);
{$Warnings on}            try
                            //Ok
                          finally
{$Warnings off}             tmpEventSink.InterfaceDisconnectEx(tmpcnn, {IAUPegasEvents,} tmpCookie);{$Warnings on}
                          end;
                        finally
                          tmpEventSink:=nil;
                        end;
                      finally
                        tmpcnn:=Nil;
                      end;
                      If GL_DataCase<>Nil Then GL_DataCase.ITSetOnLineStatus(True, MySecurityContext);
                    Except
                      If GL_DataCase<>Nil Then GL_DataCase.ITSetOnLineStatus(False, MySecurityContext);
                      Raise;
                    end;
                  end;
                  //�������� ������
                  If (FOwnerDataCase<>Nil)and(GL_DataCase<>Nil)And(GL_DataCase.ITGetOnLineStatus) Then begin
                    //Online
                    tmpV:=Unassigned;
                    ptrtmp:=nil;
                    Repeat
                      If (FOwnerDataCase<>Nil) and (GL_DataCase<>Nil) Then begin
                        If (VarType(tmpV) and varArray)=varArray Then ptrtmp:=Pointer(Integer(tmpV[5]))
                          else ptrtmp:=nil;
                        tmpV:=FOwnerDataCase.ITAdmittanceASM_GetInfoNextASMAndLock(ptrtmp);
                      end else
                        tmpV:=Unassigned;
                      //�������� ��� �������
                      If (VarType(tmpV) and varArray)=varArray Then begin
                        // ���� ��� �� ������� ������ � ����������
                        try
                          ptrtmp:=Pointer(Integer(tmpV[5]));
                          //If (Integer(tmpV[4]) and msk_rsBridge)=msk_rsBridge Then begin
                            // ��� ����
                            // ������ ���� ����
                            Case ptrtmp.ITSendCommand({1}cmdEPing, Unassigned, MySecurityContext, vlWiatForUnLockSendEvent, True) of
                              tslError:begin
                                // EPing �� ������
                                //������������ ����
                                try ptrtmp.ITSetOffLine; except end;
                                try ptrtmp.ITSetOnLine;  except end;
                              end;
                              tslTimeOut, tslOk: begin
                                // ������ ��� ��������
                              end;
                            else
                              raise exception.create('�� ��������� �������� ITSendEvent(tsl???).');
                            end;
                          //End;
                        finally
                          FOwnerDataCase.ITAdmittanceASM_UnLock(ptrtmp);
                        end;
                        //
                      end else begin
                        //ASM ���������
                        Break;
                      end;
                    Until False;
                  end;
                end;
              finally//������ �� ��������� ����������
                GL_DataCase.ITMateSleepTaskAdd(tskMTOnLineCheck, MyParams, MySenderParams, MySecurityContext, Integer(MyParams), MyTaskID, MyTaskID);
              end;
{$ENDIF}
//Out Res: Empty
          end;
          tskMTOnLineSet:begin
//In MyParams: Empty
{$IFDEF PegasServer}
              Raise Exception.Create('������� �� ��������� ��� PegasServer.');
{$ELSE}
              tmpi:=0;
              ptrtmp:=nil; tmpV:=Unassigned;
              Repeat
                If (FOwnerDataCase<>Nil) and (GL_DataCase<>Nil) Then begin
                  tmpV:=FOwnerDataCase.ITAdmittanceASM_GetInfoNextASMAndLock(ptrtmp);
                end else
                  tmpV:=Unassigned;
                // ..
                If (VarType(tmpV)and varArray)=varArray Then begin
                  try
                    ptrtmp:=Pointer(Integer(tmpV[5]));
                    If ptrtmp<>Nil then begin
                      // ����� ASM
                      try
                        ptrtmp.ITSetOnLine;
                      except
                        on e:exception do begin
                          InternalSetMessage(iStartTime, 'tskMTOnLineSet: ITSetOnLine: '+e.message, mecApp, mesError);
                          GL_DataCase.ITMateSleepTaskAdd(tskMTCircleOnLineSetForASM, Integer(Pointer(ptrtmp)), Unassigned, MySecurityContext, 15000);
                        end;
                      end;
                      Inc(tmpi); // �������
                    end;
                  finally
                    FOwnerDataCase.ITAdmittanceASM_UnLock(ptrtmp);
                  end;
                end else begin
                  // ���������
                  Break;
                end;
              Until False;
              _TaskSetStandartComplete(tmpi);
{$ENDIF}
// Out Res: Empty
          end;
          tskMTCircleOnLineSetForASM:begin
{$IFDEF PegasServer}
              Raise Exception.Create('������� �� ��������� ��� PegasServer.');
{$ELSE}
              If GL_DataCase.ITOnLineStatus Then begin
                If FOwnerDataCase.ITAdmittanceASM_Lock(Pointer(Integer(MyParams)))<1 Then Raise Exception.Create('tskMTCircleOnLineSetForASM: ITAdmittanceASM_Lock<1.');
                Try
                  try
                    TEAMServer(Pointer(Integer(MyParams))).ITSetOnLine;
                  except
                    //  ���� ���� ���������� ������ ��� ��� ������� �� �����.
                    GL_DataCase.ITMateSleepTaskAdd(tskMTCircleOnLineSetForASM, MyParams, MySenderParams, MySecurityContext, 15000, MyTaskID, MyTaskID);
                    Raise;
                  end;
                Finally
                  FOwnerDataCase.ITAdmittanceASM_UnLock(Pointer(Integer(MyParams)));
                End;
              end;
{$ENDIF}
//Out Res: Empty
          end;
          tskMTOffLineSet:begin
//In MyParams: Empty
{$IFDEF PegasServer}
              Raise Exception.Create('������� �� ��������� ��� PegasServer.');
{$ELSE}
              tmpi:=0;
              ptrtmp:=nil; tmpV:=Unassigned;
              Repeat
                If (FOwnerDataCase<>Nil) and (GL_DataCase<>Nil) Then begin
                  tmpV:=FOwnerDataCase.ITAdmittanceASM_GetInfoNextASMAndLock(ptrtmp);
                end else
                  tmpV:=Unassigned;
                // ..
                If (VarType(tmpV)and varArray)=varArray Then begin
                  try
                    ptrtmp:=Pointer(Integer(tmpV[5]));
                    If ptrtmp<>Nil then begin
                      // ����� ASM
                      try
                        ptrtmp.ITSetOffLine;
                      except
                        on e:exception do
                          InternalSetMessage(iStartTime, 'tskMTOffLineSet: ITSetOffLine: '+e.message, mecApp, mesError);
                      end;
                      Inc(tmpi); // �������
                    end;
                  finally
                    FOwnerDataCase.ITAdmittanceASM_UnLock(ptrtmp);
                  end;
                end else begin
                  // ���������
                  Break;
                end;
              Until False;
              _TaskSetStandartComplete(tmpi);
{$ENDIF}
// Out Res: Empty
          end;
          tskMTReloadSecurity:begin
// In MyParams: Empty - tskMTReloadSecurity ������������ ���� ���.
//              varInteger:(Interval)- �������� ����� ��������� tskMTReloadSecurity.
              try
                GL_DataCase.ITReloadSecurety;
              finally
                // ������ �� ��������� ����������
                If VarType(MyParams)=varInteger Then GL_DataCase.ITMateSleepTaskAdd(tskMTReloadSecurity, MyParams, MySenderParams, MySecurityContext, Integer(MyParams), MyTaskID, MyTaskID);
              end;
            {finally
              MyIntEndTask;
            end;}
//Out Res: Empty
          end;
          tskMTInternalConfig:begin
//In MyParams: Empty
              Raise Exception.Create('������������.');
//Out Res: Empty
          end;
          tskMTSleepRunner:begin
//In MyParams: [0]-Time interval, [1]-tskMTxxx, [2]-Params
             try
               GL_DataCase.ITMateTaskAdd(TTask(Integer(MyParams[1])), MyParams[2], MySenderParams, MySecurityContext, MyTaskID, MyTaskID);
             finally
               // ������ �� ��������� ����������
               GL_DataCase.ITMateSleepTaskAdd(tskMTSleepRunner, MyParams, MySenderParams, MySecurityContext, Integer(MyParams[0]), MyTaskID, MyTaskID);
             end;
// Out Res: Empty
          end;
          tskMTExecServerProc:begin {tskMTClienQueuePop}
// In MyParams: [0]-varString:(ServerProcName); [1]-varVariant:(Params); [2]-varInteger:(Interval)
            try
              tmpV:=MyParams[1];
              ExecServerProc(TCallerAction.CreateNewAction(MySecurityContext, MySenderParams), VarToStr(MyParams[0]), tmpV);
            finally
              If (VarArrayHighBound(MyParams, 1)=2)And(VarType(MyParams[2])=varInteger) Then begin//������ �� ��������� ����������
                MyParams[1]:=tmpV;
                GL_DataCase.ITMateSleepTaskAdd(tskMTExecServerProc, MyParams, MySenderParams, MySecurityContext, Integer(MyParams[2]), MyTaskID, MyTaskID);
              end;
            end;
// Out Res: Empty
          end;
          tskMTRePD:begin
// In MyParams: varInteger:(Circle interval);
              try
                //TLocalDataBase.Create
                tmpLocalDataBase:=TLocalDataBase.Create(GL_DataCase);
                try
                  //tmpLocalDataBase �������� � tmpStrQueue.QueuePop => �������� ��� SecurityContext ������� tskMTRunServerProc.
                  tmpLocalDataBase.SecurityContext:=vServerSecurityContext; IServerInfo(cnTray.Query(IServerInfo)).ServerSecurityContext
                  tmpLocalDataBase.LockListTimeOut:=15000{15sec}; {����� � ������� �������� �������� ��������� ��� ��� �������� �� �������.}
                    tmpStrQueue:=TStrQueue.Create;
                    try
                      tmpStrQueue.LocalDataBase:=tmpLocalDataBase;
                      //���� ������� ���������
                      VarClear(tmpSecurityContext); VarClear(tmpV); VarClear(tmpSenderParams); tmpSt1:=''; tmpSt2:=''; tmpSt3:='';
                      While True do begin
                        If Terminated Then Break; // �.�. ����� ���� ������� ������
                        If tmpStrQueue.QueuePop(qidRePD{aQueueId}, tmpSt1{aClientQueueId}, tmpSt2{aSender}, tmpSt3{aStrData}, tmpSenderParams{aSenderParams}, tmpSecurityContext{aSecurityContext})=False then begin
                          //������� ��������� ��� � ��� �� ���� �� ����
                          Break;
                        end;
                        try
                          //�� ������� ������ PD.
                          //��������� ClientQueueId � aSender ��������������
                          tmpV:=glStringToVarArray(tmpSt3);
                          //������ ��������� ��� ���
                          try
                            GL_DataCase.ITMateTaskAdd(tskMTPD, tmpV, tmpSenderParams, tmpSecurityContext);
                          except
                            //������������ �������
                            sleep(500);
                            GL_DataCase.ITMateTaskAdd(tskMTPD, tmpV, tmpSenderParams, tmpSecurityContext);
                          end;
                          InternalSetMessage(iStartTime, 'tskMTRePD(aClientQueueId='''+tmpSt1+''', aSender='''+tmpSt2+'''): Ok.', mecApp, mesInformation);
                        except
                          on e:exception do begin
                            try
                              tmpLocalDataBase.LockListTimeOut:=240000{4min}; {����� � ������� �������� �������� ��������� ��� ���, �������� �� �������.}
                              try                                                                                                                                                                                                                             {TimeStampToDateTime(MSecsToTimeStamp(}
                                tmpStrQueue.QueuePush(qidRePD{aQueueId}, tmpSt1{aClientQueueId}, tmpSt2{aSender}, tmpSt3{aStrData}, 'tskMTRePD: ITMateTaskAdd: '+E.Message{Commentary}, tmpSenderParams{aSenderParams}, tmpSecurityContext{aSecurityContext}, MSecsToDateTime(180000+DateTimeToMSecs(Now)){WakeUp});
                                InternalSetMessage(iStartTime, 'tskMTRePD(aClientQueueId='''+tmpSt1+''', aSender='''+tmpSt2+'''): '''+E.Message+''' >> PUSH.', mecApp, mesWarning);
                              finally
                                tmpLocalDataBase.LockListTimeOut:=15000{15sec}; {����� � ������� �������� �������� ��������� ��� ��� �������� �� �������.}
                              end;
                            except
                              On E:Exception do begin
                                If GL_BasicLogFile<>Nil Then GL_BasicLogFile.ITWriteLnToLog(#13#10'ERROR: tskMTRePD: Except in except(ITMateTaskAdd, ����� �������): '''+E.Message+'''.');
                                Raise Exception.Create('tskMTRePD: Except in except(ITMateTaskAdd, ����� �������): '''+E.Message+'''.');
                              end;
                            end;
                          end;
                        end;
                      end;
                    finally
                      FreeAndNil(tmpStrQueue);
                      try tmpSt1:=''; tmpSt2:=''; tmpSt3:=''; VarClear(tmpV); VarClear(tmpSecurityContext); VarClear(tmpSenderParams); except end;
                    end;
                finally
                  tmpLocalDataBase:=Nil;
                end;
              finally
                // ������ �� ��������� ����������
                If VarType(MyParams)=varInteger Then GL_DataCase.ITMateSleepTaskAdd(tskMTRePD, MyParams, MySenderParams, MySecurityContext, Integer(MyParams), MyTaskID, MyTaskID);
              end;
// Out Res: Empty
          end;
          tskMTReloadTriggers:begin
              try
                tmpLocalDataBase:=TLocalDataBase.Create(GL_DataCase);
                Try
                  tmpLocalDataBase.SecurityContext:=MySecurityContext;
                  tmpLocalDataBase.CheckForTriggers:=False;
                  tmpSt:=GL_DataCase.ITLocalDataBaseTriggers.ITReloadTriggers(tmpLocalDataBase);
                  If tmpSt<>'' Then Raise Exception.Create('Ignored: '+tmpSt);
                finally
                  tmpLocalDataBase:=Nil;
                end;
              finally
                // ������ �� ��������� ����������
                If VarType(MyParams)=varInteger Then GL_DataCase.ITMateSleepTaskAdd(tskMTReloadTriggers, MyParams, MySenderParams, MySecurityContext, Integer(MyParams), MyTaskID, MyTaskID);
              end;
          end;
          tskMTServerProcedures:begin
              try
                tmpLocalDataBase:=TLocalDataBase.Create(GL_DataCase);
                Try
                  tmpLocalDataBase.SecurityContext:=MySecurityContext;
                  tmpLocalDataBase.CheckForTriggers:=False;
                  tmpSt:=GL_DataCase.ITServerProcedures.ITReload(tmpLocalDataBase);
                  If tmpSt<>'' Then Raise Exception.Create('Ignored: '+tmpSt);
                finally
                  tmpLocalDataBase:=Nil;
                end;
              finally
                // ������ �� ��������� ����������
                If VarType(MyParams)=varInteger Then GL_DataCase.ITMateSleepTaskAdd(tskMTServerProcedures, MyParams, MySenderParams, MySecurityContext, Integer(MyParams), MyTaskID, MyTaskID);
              end;
          end;
          tskMTSyncTime:begin
{$IFDEF PegasServer}
              Raise Exception.Create('������� tskMTSyncTime �� ��������� ��� PegasServer.');
{$ELSE}
              tmpV:=Unassigned;
              ptrtmp:=nil;
              Repeat
                If (FOwnerDataCase<>Nil)and(GL_DataCase<>Nil) Then begin
                  If VarIsArray(tmpV) Then ptrtmp:=Pointer(Integer(tmpV[5])) else ptrtmp:=nil;
                  tmpV:=GL_DataCase.ITAdmittanceASM_GetInfoNextASMAndLock(ptrtmp);
                end else tmpV:=Unassigned;
                // �������� ��� �������
                If VarIsArray(tmpV) Then begin
                  // ���� ��� �� ������� ������ � ����������
                  try
                    ptrtmp:=Pointer(Integer(tmpV[5]));
                    If (Integer(tmpV[4]) and msk_rsBridge)=msk_rsBridge Then begin
                      try
                        ptrtmp.ITSyncTime;
                        break;
                      except end;
                    End;
                  finally
                    FOwnerDataCase.ITAdmittanceASM_UnLock(ptrtmp);
                  end;
                  //
                end else Break;
              Until False;
{$ENDIF}
          end;
      {44}tskMTBfCheckTransfer, tskMTBfCheckActuality, tskMTBfBeginDownload, tskMTBfDownload, tskMTBfEndDownload,
          tskMTBfBeginUpload, tskMTBfUpload, tskMTBfEndUpload, tskMTBfReceiveBeginDownload, tskMTBfReceiveDownload,
          {tskMTBfReceiveEndDownload, }tskMTBfReceiveBeginUpload, tskMTBfReceiveUpload, tskMTBfReceiveEndUpload,
          tskMTBfReceiveErrorBeginDownload, tskMTBfReceiveErrorDownload, {tskMTBfReceiveErrorEndDownload, }tskMTBfReceiveErrorBeginUpload,
          tskMTBfReceiveErrorUpload, tskMTBfReceiveErrorEndUpload, tskMTBfAddTransferDownload, tskMTBfAddTransferUpload,
          tskMTBfTransferCancel, tskMTBfExists{, tskMTBfTransferCheckProcess}:Begin
            //Param:[0]-varOleStr(Filepath); [1]-varOleStr:(UploadblobfileName); [2]-varOleStr:(Commentary); [3][0]-varInteger:(Currnum); [3][1]-varVariant:(Place); [3][2]-varVariant:(PlaceData);
              FDataCaseTaskImplement.BfTasksImplement(TCallerAction.CreateNewAction(MySecurityContext, MySenderParams), iTask, MyParams, MyTaskId, @tmpBoolean, @tmpV);
              If tmpBoolean Then begin
                _TaskSetStandartComplete(tmpV);
              end;
          end;
        Else
            Raise Exception.create('����������� ������� '+glTaskToStr(iTask)+' � ����������� '''+glVarArrayToString(MyParams)+'''');
        end;
      except
        on e:Exception do begin
          If MyExceptionMode=exmPDTransport Then InternalSetMessage(iStartTime, 'Execute Mate('+glTaskToStr(iTask)+'): '+e.Message, mecTransport, mesError)
          else InternalSetMessage(iStartTime, 'Execute Mate('+glTaskToStr(iTask)+'): '+e.Message, mecApp, mesError);
          Try
            _TaskSetStandartError(Unassigned, 'Execute Mate('+glTaskToStr(iTask)+'): '+e.message, e.HelpContext);
          except
            on e:Exception do begin
              InternalSetMessage(iStartTime, 'Execute Mate('+glTaskToStr(iTask)+'): Except(SetError):'+e.Message, mecApp, mesError);
            end;
          end;
          sleep({5}0);
        end;
      End;
end;
1

end.
