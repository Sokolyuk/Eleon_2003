//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UProtocolDetector;

interface
  uses UPackEventsTypes, UCallerTypes;

type
  TProtocolDetector=Class(TObject)
  private
    FData:Variant;
    FSyncMode:Boolean;
    FTitlePoint:AnsiString;
    FCallerAction:ICallerAction;
    //Events Protocol Detector
    FOnReceivePDAsync:TReceivProtocolEvent;
    FOnReceivePDSync:TReceivProtocolEvent;
    FOnReceiveCPTAsync:TReceivProtocolEvent;
    FOnReceiveCPTSync:TReceivProtocolEvent;
    FOnReceiveCPRAsync:TReceivProtocolEvent;
    FOnReceiveCPRSync:TReceivProtocolEvent;
    //Events Place Data
    FOnReceivedCP:TReceivedCPEvent;
    FOnTransportError:TTransportErrorEvent;
    //Events Command Pack.
    FOnReceiveCPT1:TReceiveCPT1Event;
    FOnReceiveCPT1Error:TReceiveCPT1ErrorEvent;
    FOnCheckSecurityPTask:TCheckSecurityPTaskEvent;
    FOnReceiveCPR1:TReceiveCPR1Event;
    FOnReceiveCPR1Error:TReceiveCPR1ErrorEvent;
    procedure Set_CallerAction(value:ICallerAction);
    procedure Set_Data(const aData:Variant);
  public
    constructor Create;
    destructor Destroy;override;
    function Exec:Variant;
    property SyncMode:Boolean Read FSyncMode Write FSyncMode;
    property Data:Variant read FData write Set_Data;
    property CallerAction:ICallerAction read FCallerAction write Set_CallerAction;
    property TitlePoint:AnsiString read FTitlePoint write FTitlePoint;
    //Receive
    function ReceivePDAsync:Variant;virtual;
    function ReceivePDSync:Variant;virtual;
    function ReceiveCPTAsync:Variant;virtual;
    function ReceiveCPTSync:Variant;virtual;
    function ReceiveCPRAsync:Variant;virtual;
    function ReceiveCPRSync:Variant;virtual;
    //Events Protocol Detector
    property OnReceivePDAsync:TReceivProtocolEvent read FOnReceivePDAsync  write FOnReceivePDAsync;
    property OnReceivePDSync:TReceivProtocolEvent read FOnReceivePDSync   write FOnReceivePDSync;
    property OnReceiveCPTAsync:TReceivProtocolEvent read FOnReceiveCPTAsync write FOnReceiveCPTAsync;
    property OnReceiveCPTSync:TReceivProtocolEvent read FOnReceiveCPTSync  write FOnReceiveCPTSync;
    property OnReceiveCPRAsync:TReceivProtocolEvent read FOnReceiveCPRAsync write FOnReceiveCPRAsync;
    property OnReceiveCPRSync:TReceivProtocolEvent read FOnReceiveCPRSync  write FOnReceiveCPRSync;
    //Events Place Data
    property OnReceivedCP:TReceivedCPEvent read FOnReceivedCP write FOnReceivedCP;
    property OnTransportError:TTransportErrorEvent read FOnTransportError write FOnTransportError;
    //Events Command Pack.
    property OnReceiveCPT1:TReceiveCPT1Event read FOnReceiveCPT1 write FOnReceiveCPT1;
    property OnReceiveCPT1Error:TReceiveCPT1ErrorEvent read FOnReceiveCPT1Error write FOnReceiveCPT1Error;
    property OnCheckSecurityPTask:TCheckSecurityPTaskEvent read FOnCheckSecurityPTask write FOnCheckSecurityPTask;
    property OnReceiveCPR1:TReceiveCPR1Event read FOnReceiveCPR1 write FOnReceiveCPR1;
    property OnReceiveCPR1Error:TReceiveCPR1ErrorEvent read FOnReceiveCPR1Error write FOnReceiveCPR1Error;
  end;

implementation
  uses Sysutils, UPackConsts, Variants, UErrorConsts;
// Protocol Detector -----------------------------------------------------------
constructor TProtocolDetector.Create;
begin
  FData:=Unassigned;
  FCallerAction:=nil;
  FSyncMode:=false;  // async
  // Events Protocol Detector
  FOnReceivePDAsync:=nil;
  FOnReceivePDSync:=nil;
  FOnReceiveCPTAsync:=nil;
  FOnReceiveCPTSync:=nil;
  FOnReceiveCPRAsync:=nil;
  FOnReceiveCPRSync:=nil;
  // Events Place Data
  FOnReceivedCP:=nil;
  FOnTransportError:=Nil;
  //Events Command Pack.
  FOnReceiveCPT1:=nil;
  FOnReceiveCPT1Error:=nil;
  FOnCheckSecurityPTask:=nil;
  FOnReceiveCPR1:=nil;
  FOnReceiveCPR1Error:=nil;
  //..
  FTitlePoint:='<None>';
  Inherited Create;
end;

destructor TProtocolDetector.Destroy;
begin
  try
    VarClear(FData);
    FCallerAction:=nil;
  except end;
  inherited Destroy;
end;

procedure TProtocolDetector.Set_CallerAction(value:ICallerAction);
begin
  FCallerAction:=value;
end;

procedure TProtocolDetector.Set_Data(const aData:Variant);
begin
  FData:=aData;
end;

function TProtocolDetector.Exec:Variant;
begin
  try
    Result:=Unassigned;
    if VarIsEmpty(FData) then raise exception.createFmtHelp(cserInternalError, ['Data is empty'], cnerInternalError);
    if (VarType(FData)and varArray)<>varArray then raise exception.create('Не удается распознать формат пакета.');
    case FData[Protocols_ID] of
      Protocols_PD:begin
        if FSyncMode then begin
          // Sync
          if assigned(FOnReceivePDSync) then Result:=FOnReceivePDSync(Self, FData) else Result:=ReceivePDSync;
        end else begin
          // ASync
          if assigned(FOnReceivePDAsync) then Result:=FOnReceivePDAsync(Self, FData) else Result:=ReceivePDAsync;
        end;
      end;
      Protocols_CPT:begin
        if FSyncMode then begin
          // Sync
          if assigned(FOnReceiveCPTSync) then Result:=FOnReceiveCPTSync(Self, FData) else Result:=ReceiveCPTSync;
        end else begin
          // Async
          if assigned(FOnReceiveCPTAsync) then Result:=FOnReceiveCPTAsync(Self, FData) else Result:=ReceiveCPTAsync;
        end;
      end;
      Protocols_CPR:begin
        if FSyncMode then begin
          // Sync
          if assigned(FOnReceiveCPRSync) then Result:=FOnReceiveCPRSync(Self, FData) else Result:=ReceiveCPRSync;
        end else begin
          // Async
          if assigned(FOnReceiveCPRAsync) then Result:=FOnReceiveCPRAsync(Self, FData) else Result:=ReceiveCPRAsync;
        end;
      end;
    else
      raise exception.createFmtHelp(cserInternalError, ['Неизвестный протокол'], cnerInternalError);
    end;
  except on e:exception do begin
    e.message:='TProtocolDetector.Exec: '+e.message;
    raise;
  end;end;
end;

function TProtocolDetector.ReceivePDAsync:Variant;
begin
  raise exception.createFmtHelp(cserInternalError, ['TProtocolDetector.ReceivePDAsync не реализован'], cnerInternalError);
end;

function TProtocolDetector.ReceivePDSync:Variant;
begin
  raise exception.createFmtHelp(cserInternalError, ['TProtocolDetector.ReceivePDSync не реализован'], cnerInternalError);
end;

function TProtocolDetector.ReceiveCPTAsync:Variant;
begin
  raise exception.createFmtHelp(cserInternalError, ['TProtocolDetector.ReceiveCPTAsync не реализован'], cnerInternalError);
end;

function TProtocolDetector.ReceiveCPTSync:Variant;
begin
  raise exception.createFmtHelp(cserInternalError, ['TProtocolDetector.ReceiveCPTSync не реализован'], cnerInternalError);
end;

function TProtocolDetector.ReceiveCPRAsync:Variant;
begin
  raise exception.createFmtHelp(cserInternalError, ['TProtocolDetector.ReceiveCPRAsync не реализован'], cnerInternalError);
end;

function TProtocolDetector.ReceiveCPRSync:Variant;
begin
  raise exception.createFmtHelp(cserInternalError, ['TProtocolDetector.ReceiveCPRSync не реализован'], cnerInternalError);
end;

end.
