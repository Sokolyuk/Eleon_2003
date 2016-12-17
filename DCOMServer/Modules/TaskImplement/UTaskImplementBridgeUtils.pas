unit UTaskImplementBridgeUtils;
{$Ifndef PegasServer}{$Ifndef EAMServer}
  ���� ������ ���������� ���������
{$endif}{$endif}
interface
  uses UTTaskTypes, UCallerTypes, UTaskImplementTypes;

  function TaskImplementBridge(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;

implementation
  uses UTrayConsts, Sysutils, UErrorConsts, Variants, UTTaskUtils, UThreadsPoolTypes
{$Ifdef EAMServer}
       , Comobj, UEventSink, UAS, UAdmittanceASMTypes, UServerOnlineTypes, UServerConsts
{$endif}
       ;

function TaskImplementBridge(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;
{$ifdef EAMServer}
  var tmpAdmittanceASM:IAdmittanceASM;
  function localGetIAdmittanceASM:IAdmittanceASM;begin
    if not assigned(tmpAdmittanceASM) then cnTray.Query(IAdmittanceASM, tmpAdmittanceASM);
    result:=tmpAdmittanceASM;
  end;
  function localGetTaskID:Integer;begin
    if assigned(aTaskContext) then result:=aTaskContext^.aTaskID else result:=-1;
  end;
   var tmpPtr:TComObject;
       {//!!!}tmpIUnknown:IUnknown;
{$endif}
begin
  result:=true;
  case aTask of
    tskMTCreateBridge:begin//In MyParams: Empty
{$IFDEF PegasServer}
      raise Exception.Create('������� �� ��������� ��� PegasServer.');
{$ELSE}
      tmpPtr:=GL_AOF_ASM.CreateComObject(nil);
      {//!!!}tmpIUnknown:=tmpPtr;
      {//!!!}tmpIUnknown._AddRef;//�.�. EQueryInterface "�������" �� ������������ �������, �����.
      IThreadsPool(cnTray.Query(IThreadsPool)).ITMTaskAdd(tskMTConnectBridge, Integer(Pointer(tmpPtr)), aCallerAction, localGetTaskID, nil);
{$ENDIF}//Out Res: Empty
    end;
    tskMTConnectBridge:begin
{$IFDEF PegasServer}
      raise exception.create('������� �� ��������� ��� PegasServer.');
{$ELSE}
      if localGetIAdmittanceASM.Lock(Pointer(Integer(aParams)))<1 Then Raise Exception.Create('tskMTConnectBridge: ITAdmittanceASM.Lock<1.');
      try
        try
          TEAMServer(Pointer(Integer(aParams))).ITCreateBridge;
        except
          if IServerOnline(cnTray.Query(IServerOnline)).ITOnLineStatus then begin//��� OnLine. ���� ���� ���������� ������ ��� ��� ������� �� �����.
            IThreadsPool(cnTray.Query(IThreadsPool)).ITMSleepTaskAdd(tskMTConnectBridge, aParams, aCallerAction, 15000, localGetTaskID, nil);
          end;
          raise;//� ���� OffLine �������� ������ ITCreateBridge(� ������� ����������) � ��������, � ��� SetOnLine ���� ��������������.
        end;
      finally
        localGetIAdmittanceASM.UnLock(Pointer(Integer(aParams)));
      end;
{$ENDIF}
    end;
  else
    if aRaise then Raise Exception.CreateFmtHelp(cserInternalError, ['Unsupported for '+MTaskToStr(aTask)], cnerInternalError) else result:=false;
  end;
end;

end.
