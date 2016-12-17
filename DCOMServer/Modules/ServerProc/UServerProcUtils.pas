//Copyright � 2000-2003 by Dmitry A. Sokolyuk
unit UServerProcUtils;

{$Ifndef PegasServer}{$Ifndef EAMServer}����������� Defines EAMServer ��� PegasServer.{$endif}{$endif}
{$Ifdef PegasServer}{$Ifdef EAMServer}��������� Defines EAMServer � PegasServer.{$endif}{$endif}

interface
  uses UServerProcTypes, UCallerTypes;

  procedure ServerProcExec(aCallerAction:ICallerAction; Const aServerProcName:AnsiString; Var aParam:Variant; aServerProcExecParams:PServerProcExecParams);

implementation
  uses SysUtils, UServerProcedureTypes, ComObj, UServerProcConsts, UServerProceduresTypes, UTrayConsts, Variants{$IFDEF PegasServer}, Pegas_TLB{$ELSE}, EMServer_TLB{$ENDIF},
       UExternalLocalDataBase, UExternalDataCase, UErrorConsts, UAppMessageTypes, UServerProcConfigureTypes, UTrayTypes;

type
  PServerProcInternalExecParams=^TServerProcInternalExecParams;
  TServerProcInternalExecParams=record//��������! ������� ��������� �� �����������
    aRegName:PAnsiString;//�� ������������ ����
    aServerProcedureAss:PServerProcedureAss;//������������ ����
    aParams:PVariant;//������������ ����
    aCallerAction:ICallerAction;//������������ ����
{$IFDEF PegasServer}
    aExternalDataCase:IExternalPgDataCase;//������������ ����
    aExternalLocalDataBase:IExternalPgLocalDataBase;//������������ ����
    aExternalASMServer:IAUPegas;//�� ������������ ����
{$ELSE}
    aExternalDataCase:IExternalEmDataCase;//������������ ����
    aExternalLocalDataBase:IExternalEmLocalDataBase;//������������ ����
    aExternalASMServer:IEAMServer;//�� ������������ ����
{$ENDIF}
    aBeforeCall:TServerProcEmptyEvent;//�� ������������ ����
    aAfterCall:TServerProcEmptyEvent;//�� ������������ ����
  end;


procedure InternalServerProcExec(aServerProcInternalExecParams:PServerProcInternalExecParams);
  function localGetITray:ITray;begin
    result:=cnTray;
    if not assigned(result) then raise exception.create('cnTray not assigned.');
  end;
  var iFMN, iFMNLen:Integer;
      tmpDispatch:Variant;
      tmpVariant:Variant;
      MyCallDesc:TCallDesc;
      tmpDllVersion:Integer;
      tmpNilDispatch:IDispatch;
{$IFDEF VER140}tmpVariantManager:TVariantManager;{$ENDIF}
      tmpPServerProcedureAss:PServerProcedureAss;
      tmpIUnknown:IUnknown;
      tmpServerProcConfigure:IServerProcConfigure;
begin
  try
    tmpPServerProcedureAss:=aServerProcInternalExecParams^.aServerProcedureAss;
    iFMNLen:=Length(tmpPServerProcedureAss^.Method);
    if (tmpPServerProcedureAss^.Method='')or(iFMNLen>250) then raise exception.create('������������ �������� FMethod='''+tmpPServerProcedureAss^.Method+'''.');
    try//������ ��������� ����������
      tmpIUnknown:=CreateRemoteComObject(tmpPServerProcedureAss^.Machine, tmpPServerProcedureAss^.Guid);
    except on e:exception do begin
      e.message:='CreateRemoteComObject: '+e.message;
      raise;
    end;end;
    try//�������� ������ Dll
      tmpDispatch:=tmpIUnknown as IDispatch;
      if (tmpIUnknown.QueryInterface(IServerProcConfigure, tmpServerProcConfigure)=S_OK)and(assigned(tmpServerProcConfigure)) then begin
        tmpDllVersion:=tmpServerProcConfigure.GetVersion;
      end else begin
        tmpDllVersion:=tmpDispatch.GetVersion;
      end;
      tmpIUnknown:=nil;
      case tmpDllVersion of
        cnPossibleDllVersion:begin
          try
            tmpDispatch.SetSecurityContext(aServerProcInternalExecParams^.aCallerAction.SecurityContext);
          except on e:exception do begin
            e.Message:='SetSecurityContext: '+e.Message;
            raise;
          end;end;//������������ SenderParams
          try
            tmpDispatch.SetSenderParams(aServerProcInternalExecParams^.aCallerAction.SenderParams);
          except on e:exception do begin
            e.Message:='SetSenderParams: '+e.Message;
          end;end;//������������ LoadParams
          try
            if Not VarIsEmpty(tmpPServerProcedureAss^.LoadParams) then begin
              try
                tmpDispatch.SetLoadParams(tmpPServerProcedureAss^.LoadParams);
              except on e:exception do begin
                e.Message:='SetLoadParams: '+e.Message;
                Raise;
              end;end;
            end;
          except end;//������������ IASMServer
          if tmpPServerProcedureAss^.RequireASMServer then begin
            If aServerProcInternalExecParams^.aExternalASMServer=Nil Then Raise Exception.Create('ExternalASMServer is not assigned.');
            try
{$IFDEF PegasServer}
              tmpDispatch.SetIAUPegas(IDispatch(aServerProcInternalExecParams^.aExternalASMServer));
{$ELSE}
              tmpDispatch.SetIEAMServer(IDispatch(aServerProcInternalExecParams^.aExternalASMServer));
{$ENDIF}
            except on e:exception do begin
              e.message:='SetIASMServer: '+e.message;
              raise;
            end;end;//Raise Exception.Create('SetIASMServer �� ����������� ��� ������������ ������.');
          end;//������������ IDataCase
          if tmpPServerProcedureAss^.RequireDataCase then begin
            if aServerProcInternalExecParams^.aExternalDataCase=Nil Then Raise Exception.Create('ExternalDataCase is not assigned.');
            try
{$IFDEF PegasServer}
              tmpDispatch.SetIPgDataCase(IDispatch(aServerProcInternalExecParams^.aExternalDataCase));
{$ELSE}
              tmpDispatch.SetIDataCase(IDispatch(aServerProcInternalExecParams^.aExternalDataCase));
{$ENDIF}
            except on e:exception do begin
              e.message:='SetIDataCase: '+e.message;
              raise;
            end;end;
          end;//������������ ILocalDataBase
          if tmpPServerProcedureAss^.RequireLocalDataBase then begin
            if aServerProcInternalExecParams^.aExternalLocalDataBase=nil then raise Exception.Create('ExternalLocalDataBase is not assigned.');
            try
{$IFDEF PegasServer}
              tmpDispatch.SetIPgLocalDataBase(IDispatch(aServerProcInternalExecParams^.aExternalLocalDataBase));
{$ELSE}
              tmpDispatch.SetILocalDataBase(IDispatch(aServerProcInternalExecParams^.aExternalLocalDataBase));
{$ENDIF}
            except on e:exception do begin
              e.message:='SetILocalDataBase: '+e.message;
              raise;
            end;end;
          end;
        end;
        cnPossibleDllVersion2:begin
          if not assigned(tmpServerProcConfigure) then raise exception.create('tmpServerProcConfigure not assigned.');
          tmpServerProcConfigure.SetCallerAction(aServerProcInternalExecParams^.aCallerAction);
          tmpServerProcConfigure.SetTray(localGetITray);
          if not VarIsEmpty(tmpPServerProcedureAss^.LoadParams) then begin
            tmpServerProcConfigure.SetLoadParams(tmpPServerProcedureAss^.LoadParams);
          end;
          tmpServerProcConfigure:=nil;
        end;
      else
        raise exception.create('������������ ������ ServerProc Dll(Ver='+IntToStr(tmpDllVersion)+').');
      end;
{$IFDEF VER140} { Borland Delphi 6.0 }
      GetVariantManager(tmpVariantManager);
{$ENDIF}//������������ ��������� ��� ������ ������ ���������
      tmpVariant:=aServerProcInternalExecParams^.aParams^;
      MyCallDesc.CallType:=1;//Metod
      MyCallDesc.NamedArgCount:=0;//�������� ��� ������
      MyCallDesc.ArgCount:=1;//��� ������������� ��������
      MyCallDesc.ArgTypes[0]:=$8C;//varVariant//����� ��� ������
      iFMN:=MyCallDesc.ArgCount{1};
      While True do begin
        If iFMNLen<iFMN Then Break; //������ ���������
        MyCallDesc.ArgTypes[iFMN]:=Ord(tmpPServerProcedureAss^.Method[iFMN]);
        Inc(iFMN);
      end;
      MyCallDesc.ArgTypes[iFMN]:=0;
      MyCallDesc.ArgTypes[iFMN+1]:=0;
      // ..
      try
        if Assigned(aServerProcInternalExecParams^.aBeforeCall) Then aServerProcInternalExecParams^.aBeforeCall;
        try
          asm
            lea   eax, tmpVariant
            push  eax
            lea   eax, [MyCallDesc]
            push  eax
            lea   eax, [tmpDispatch]
            push  eax
            push  $00
{$IFDEF VER130} {Borland Delphi 5.0}
            call  VarDispProc
{$Else}
  {$IFDEF VER140} {Borland Delphi 6.0}
            call  tmpVariantManager.DispInvoke
  {$Else}
    {$IFDEF VER150} {Borland Delphi 7.0}
              call VarDispProc
    {$Else}
      ����������� ����������
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
            add   esp, $10
          end;
        finally
          if Assigned(aServerProcInternalExecParams^.aAfterCall) then begin
            try aServerProcInternalExecParams^.aAfterCall; except end;
          end;
        end;
        aServerProcInternalExecParams^.aParams^:=tmpVariant;
        tmpVariant:=Unassigned;
      except on e:exception do begin
        if assigned(aServerProcInternalExecParams^.aRegName) then e.message:='Call '''+aServerProcInternalExecParams^.aRegName^+''': '+e.message
            else e.message:='Call: '+e.message;
        raise;
      end;end;
      case tmpDllVersion of
        cnPossibleDllVersion:begin
          try//Clear dll property
            try
              tmpDispatch.SetSecurityContext(Unassigned);
            except end;//Clear SenderParams
            try
              tmpDispatch.SetSenderParams(Unassigned);
            except end;//Clear LoadParams
            try
              if not VarIsEmpty(tmpPServerProcedureAss^.LoadParams) then begin
                tmpDispatch.SetLoadParams(Unassigned);
              end;
            except end;
            tmpNilDispatch:=Nil;//Clear IASMServer
            if tmpPServerProcedureAss^.RequireASMServer then begin
              try
{$IFDEF PegasServer}
                tmpDispatch.SetIAUPegas(tmpNilDispatch);
{$ELSE}
                tmpDispatch.SetIEAMServer(tmpNilDispatch);
{$ENDIF}
              except end;
            end;//������������ IDataCase
            if tmpPServerProcedureAss^.RequireDataCase then begin
              try
{$IFDEF PegasServer}
                tmpDispatch.SetIPgDataCase(tmpNilDispatch);
{$ELSE}
                tmpDispatch.SetIDataCase(tmpNilDispatch);
{$ENDIF}
              except end;
            end;//������������ ILocalDataBase
            if tmpPServerProcedureAss^.RequireLocalDataBase then begin
              try
{$IFDEF PegasServer}
                tmpDispatch.SetIPgLocalDataBase(tmpNilDispatch);
{$ELSE}
                tmpDispatch.SetILocalDataBase(tmpNilDispatch);
{$ENDIF}
              except end;
            end;
          except end;
        end;
        cnPossibleDllVersion2:;
      end;
    finally
      try
        tmpDispatch:=unassigned;
      except end;
    end;
  except on e:exception do begin
    e.message:='ServerProcExec: '+e.message;
    raise;
  end;end;
end;

procedure ServerProcExec(aCallerAction:ICallerAction; Const aServerProcName:AnsiString; Var aParam:Variant; aServerProcExecParams:PServerProcExecParams{�������������� ����});
  function localGetPrefix(alShowMessagePrefix:PAnsiString):AnsiString;begin
    if assigned(alShowMessagePrefix) then result:=alShowMessagePrefix^ else result:='';
  end;
  var tmpPServerProcExecParams:PServerProcExecParams;
  function localGetIServerProcedures:IServerProcedures;begin
    if not assigned(tmpPServerProcExecParams^.aServerProcedures) then cnTray.Query(IServerProcedures, tmpPServerProcExecParams^.aServerProcedures);
    result:=tmpPServerProcExecParams^.aServerProcedures;
  end;
  Var {$IFDEF PegasServer}
      tmpExternalLocalDataBase:TExternalPgLocalDataBase;
      tmpExternalDataCase:TExternalPgDataCase;
      {$ELSE}
      tmpExternalLocalDataBase:TExternalEmLocalDataBase;
      tmpExternalDataCase:TExternalEmDataCase;
      {$ENDIF}
      tmpStartTime:TDateTime;
      tmpServerProcInternalExecParams:TServerProcInternalExecParams;
      tmpServerProcedureAss:TServerProcedureAss;
      tmpTServerProcExecParams:TServerProcExecParams;
begin
  If not assigned(aCallerAction) Then Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['aCallerAction'], cnerInvalidValueOf);
  If aServerProcName='' Then Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['ServerProcName='''''], cnerInvalidValueOf);
  tmpStartTime:=Now;
  if assigned(aServerProcExecParams) then tmpPServerProcExecParams:=aServerProcExecParams else begin
    fillchar(tmpTServerProcExecParams, Sizeof(tmpTServerProcExecParams), 0);
    tmpTServerProcExecParams.aShowMessage:=true;
    tmpPServerProcExecParams:=@tmpTServerProcExecParams;
  end;
{$IFDEF PegasServer}tmpExternalLocalDataBase:=TExternalPgLocalDataBase.Create;{$ELSE}tmpExternalLocalDataBase:=TExternalEmLocalDataBase.Create;{$ENDIF}
  try
    if assigned(tmpPServerProcExecParams^.aLocalDataBase) then tmpExternalLocalDataBase.LocalDataBase:=tmpPServerProcExecParams^.aLocalDataBase
    else begin
      tmpExternalLocalDataBase.NewLocalDataBase;
      tmpExternalLocalDataBase.LocalDataBase.CallerAction:=aCallerAction;
    end;
    if assigned(tmpPServerProcExecParams^.aLocalDataBaseTriggerData) then tmpExternalLocalDataBase.LocalDataBaseTriggerData:=tmpPServerProcExecParams^.aLocalDataBaseTriggerData;
{$IFDEF PegasServer}tmpExternalDataCase:=TExternalPgDataCase.Create;{$ELSE}tmpExternalDataCase:=TExternalEmDataCase.Create;{$ENDIF}
    try
      tmpExternalDataCase.CallerAction:=aCallerAction;
      fillchar(tmpServerProcInternalExecParams, Sizeof(tmpServerProcInternalExecParams), 0);
      tmpServerProcInternalExecParams.aRegName:=@aServerProcName;
      tmpServerProcedureAss:=localGetIServerProcedures.ITRegNameToServerProcedureAss(aServerProcName);//�������� ������ �� ����
      tmpServerProcInternalExecParams.aServerProcedureAss:=@tmpServerProcedureAss;
      tmpServerProcInternalExecParams.aParams:=@aParam;
      tmpServerProcInternalExecParams.aCallerAction:=aCallerAction;
      tmpServerProcInternalExecParams.aExternalDataCase:=tmpExternalDataCase;
      tmpServerProcInternalExecParams.aExternalLocalDataBase:=tmpExternalLocalDataBase;
      tmpServerProcInternalExecParams.aExternalASMServer:=tmpPServerProcExecParams^.aExternalASMServer;
      tmpServerProcInternalExecParams.aBeforeCall:=tmpPServerProcExecParams^.aOnBeforeCall;
      tmpServerProcInternalExecParams.aAfterCall:=tmpPServerProcExecParams^.aOnAfterCall;
      if tmpPServerProcExecParams^.aShowMessage then aCallerAction.ITMessAdd(Now, tmpStartTime, 'ExecSP', localGetPrefix(tmpPServerProcExecParams^.aShowMessagePrefix)+'ServerProcExec(BEFORE) '''+aServerProcName+'''/AN='+aCallerAction.ActionName, mecApp, mesInformation);
      try
        InternalServerProcExec(@tmpServerProcInternalExecParams);//�����
      finally
        if tmpPServerProcExecParams^.aShowMessage then try aCallerAction.ITMessAdd(Now, tmpStartTime, 'ExecSP', localGetPrefix(tmpPServerProcExecParams^.aShowMessagePrefix)+'ServerProcExec(AFTER) '''+aServerProcName+'''/AN='+aCallerAction.ActionName, mecApp, mesInformation);except end;
      end;  
    finally
      tmpServerProcInternalExecParams.aExternalDataCase:=nil;
      FreeAndNil(tmpExternalDataCase);
    end;
  finally
    tmpServerProcInternalExecParams.aExternalLocalDataBase:=nil;
    FreeAndNil(tmpExternalLocalDataBase);
  end;
end;

end.
