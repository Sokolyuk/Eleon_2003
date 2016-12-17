unit UProtocolDetectorServer;

interface
  Uses UProtocolDetector, UPackEventsTypes;

Type
  TFromProtocol=(fplEPack, fplInvoke);
  TProtocolDetectorServer=class(TProtocolDetector)
  private
    FFromProtocol:TFromProtocol;
    FPDID:AnsiString;
    FIsPD:Boolean;
  public
    Constructor Create;
    Destructor Destroy;override;
    Function ReceivePDAsync:Variant;override;
    Function ReceivePDSync:Variant;override;
    Function ReceiveCPTAsync:Variant;override;
    Function ReceiveCPTSync:Variant;override;
    Function ReceiveCPRAsync:Variant;override;
    Function ReceiveCPRSync:Variant;override;
    Property FromProtocol:TFromProtocol read FFromProtocol write FFromProtocol;
    Property AfterExecPDID:AnsiString read FPDID;
    Property AfterIsPD:Boolean read FIsPD;
  end;

implementation
  Uses Sysutils, UPD, UCommandPackServer, UPackConsts, UADMTypes, {UConsts, }UPackTypes, UTTaskTypes, UTrayConsts,
       UThreadsPoolTypes, Variants;
Constructor TProtocolDetectorServer.Create;
begin
  FPDID:='';
  FIsPD:=False;
  Inherited Create;
end;

Destructor  TProtocolDetectorServer.Destroy;
begin
  try
    FPDID:='';
  except end;
  Inherited Destroy;
end;

Function TProtocolDetectorServer.ReceivePDAsync:Variant;
  Var tmpPD:TPD;
begin//������ TPD ��� CheckPD � ReverceRoute.
  Result:=Unassigned;
  tmpPD:=TPD.Create;
  Try//Events Place Data
    tmpPD.OnReceivedCP:=OnReceivedCP;//Events Command Pack.
    tmpPD.OnReceiveCPT1:=OnReceiveCPT1;
    tmpPD.OnReceiveCPT1Error:=OnReceiveCPT1Error;
    tmpPD.OnReceiveCPR1:=OnReceiveCPR1;
    tmpPD.OnReceiveCPR1Error:=OnReceiveCPR1Error;
    tmpPD.OnCheckSecurityPTask:=OnCheckSecurityPTask;
    tmpPD.OnTransportError:=OnTransportError;
    tmpPD.CallerAction:=CallerAction;//tmpPD.SecurityContext:=Unassigned;   //Unassigned - �.�. ��������� ������ CheckPD � ReverceRoute.
    tmpPD.TitlePoint:=TitlePoint;
    tmpPD.Data:=Data;
    tmpPD.CheckPD;
    FPDID:=VarToStr(tmpPD.PDID);
    FIsPD:=True;
    //�������� �������� SenderParams. ������ ����� �������������� SenderParams ������ ������ ����� tskMTPD � TPDServer. �� ���������� �������(Hop)
    //� ��� ���� TProtocolDetectorServer ������� ���� �����.
    //����� ������� �������� PlaceData ��� TaskAdd.
    If (tmpPD.Options And Protocols_PD_Options_WithNotificationOfError)=Protocols_PD_Options_WithNotificationOfError Then begin
      //��������� ����������� � ������� �� ����� ����������� ������;
      If (tmpPD.Options And Protocols_PD_Options_ReturnDataIfTransportError)=Protocols_PD_Options_ReturnDataIfTransportError Then begin
        //��������� ������� ������
        CallerAction.SenderParams:=VarArrayOf([-1{rstSTNoASM}, -1{tsiNoPackID}, tmpPD.ReverceRoute(Data[Protocols_PD_Data], popError), Integer(tskADMNone)]);
      end else begin//�� ��������� ������� ������
        CallerAction.SenderParams:=VarArrayOf([-1{rstSTNoASM}, -1{tsiNoPackID}, tmpPD.ReverceRoute(Unassigned, popError), Integer(tskADMNone)]);
      end;
    end else begin//�� ��������� ����������� � ������� �� ����� ����������� ������;
      CallerAction.SenderParams:=Unassigned;
    end;
    IThreadsPool(cnTray.Query(IThreadsPool)).ITMTaskAdd(tskMTPD, Data, CallerAction);
  Finally
    tmpPD.free;
  end;
end;

Function TProtocolDetectorServer.ReceivePDSync:Variant;
begin
  Raise Exception.Create('��� ��������� PD SyncMode �� ����������, ����������� Async(EPackAsync).');
end;

Function TProtocolDetectorServer.ReceiveCPTAsync:Variant;
begin
  Raise Exception.Create('��� ��������� CPT, CPR ASyncMode �� ����������, ����������� Sync(EPackSync).');
end;

Function TProtocolDetectorServer.ReceiveCPTSync:Variant;
  Var iCP:TCommandPackServer;
begin
  iCP:=TCommandPackServer.Create;
  Try//Events Command Pack.
    iCP.OnReceiveCPT1:=OnReceiveCPT1;
    iCP.OnReceiveCPT1Error:=OnReceiveCPT1Error;
    iCP.OnReceiveCPR1:=OnReceiveCPR1;
    iCP.OnReceiveCPR1Error:=OnReceiveCPR1Error;
    iCP.OnCheckSecurityPTask:=OnCheckSecurityPTask;
    iCP.OwnerPD:=Nil;
    iCP.TitlePoint:=TitlePoint;
    iCP.Data:=Data;
    iCP.CallerAction:=CallerAction;
    Result:=iCP.Exec;//Sync for CPT
  Finally
    iCP.free;
  end;
end;

Function TProtocolDetectorServer.ReceiveCPRAsync:Variant;
begin
  Raise Exception.Create('��� ��������� CPT, CPR ASyncMode �� ����������, ����������� Sync(EPackSync).');
end;

Function TProtocolDetectorServer.ReceiveCPRSync:Variant;
begin
  Raise Exception.Create('��� ��������� CPR SyncMode �� ����������.');
end;

end.
