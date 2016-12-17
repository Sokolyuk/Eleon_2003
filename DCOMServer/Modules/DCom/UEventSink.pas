unit UEventSink;

interface
  Uses UIObject, ActiveX;
Type
  TInvokeEvent=procedure(DispID:Integer; var Params:TDispParams) of object;
  IEventSink=Interface(IUnknown)
    function Get_IIDEvents:TGUID;
    procedure Set_IIDEvents(Value:TGUID);
    function Get_OnInvoke:TInvokeEvent;
    procedure Set_OnInvoke(Value:TInvokeEvent);
    function Get_TitlePoint:AnsiString;
    procedure Set_TitlePoint(const Value:AnsiString);
    procedure InterfaceConnectEx(const Source: IUnknown; {const IID: TIID;} const Sink: IUnknown; var Connection:Longint);
    procedure InterfaceDisconnectEx(const Source: IUnknown; {const IID: TIID;} var Connection:Longint);
    Property IIDEvents:TGUID read Get_IIDEvents write Set_IIDEvents;
    Property OnInvoke:TInvokeEvent read Get_OnInvoke write Set_OnInvoke;
    Property TitlePoint:AnsiString read Get_TitlePoint write Set_TitlePoint;
  end;
  //Обработчик событий
  TEventSink=class(TIObject, {IUnknown, }IDispatch, IEventSink)
  private
    FIIDEvents:TGUID;
    FOnInvoke:TInvokeEvent;
    FTitlePoint:AnsiString;
    FRefCount:Integer;
  protected
    {IUnknown}
    function QueryInterface(const IID:TGUID; out Obj):HResult;override;//virtual;stdcall;
    //function _AddRef: Integer; virtual; stdcall;
    //function _Release: Integer; virtual; stdcall;
    {IDispatch}
    function GetTypeInfoCount(out Count:Integer): HResult;virtual;stdcall;
    function GetTypeInfo(Index, LocaleID:Integer; out TypeInfo):HResult;virtual;stdcall;
    function GetIDsOfNames(const IID:TGUID; Names:Pointer; NameCount, LocaleID:Integer; DispIDs:Pointer):HResult;virtual;stdcall;
    function Invoke(DispID:Integer; const IID:TGUID; LocaleID:Integer; Flags:Word; var Params; VarResult, ExcepInfo, ArgErr:Pointer):HResult;virtual;stdcall;
    {IEventSink}
    function Get_IIDEvents:TGUID;
    procedure Set_IIDEvents(Value:TGUID);
    function Get_OnInvoke:TInvokeEvent;
    procedure Set_OnInvoke(Value:TInvokeEvent);
    function Get_TitlePoint:AnsiString;
    procedure Set_TitlePoint(const Value:AnsiString);
  public
    constructor Create;
    destructor Destroy;override;
    procedure InterfaceConnectEx(const Source:IUnknown; const Sink:IUnknown; var Connection:Longint);
    procedure InterfaceDisconnectEx(const Source:IUnknown; var Connection:Longint);
    Property IIDEvents:TGUID read Get_IIDEvents write Set_IIDEvents;
    Property OnInvoke:TInvokeEvent read Get_OnInvoke write Set_OnInvoke;
    Property TitlePoint:AnsiString read Get_TitlePoint write Set_TitlePoint;
  end;

implementation
  uses Windows, SysUtils;
//Обработчик событий TEventSink
constructor TEventSink.Create;
begin
  FIIDEvents:=IDispatch;
  FOnInvoke:=Nil;
  FTitlePoint:='<None>';
  FRefCount:=0;
  inherited Create;
end;

destructor TEventSink.Destroy;
begin
  FTitlePoint:='';
  inherited Destroy;
end;  

function TEventSink.Get_IIDEvents:TGUID;
begin
  Result:=FIIDEvents;
end;

procedure TEventSink.Set_IIDEvents(Value:TGUID);
begin
  FIIDEvents:=Value;
end;

function TEventSink.Get_OnInvoke:TInvokeEvent;
begin
  Result:=FOnInvoke;
end;

procedure TEventSink.Set_OnInvoke(Value:TInvokeEvent);
begin
  FOnInvoke:=Value;
end;

function TEventSink.Get_TitlePoint:AnsiString;
begin
  Result:=FTitlePoint;
end;

procedure TEventSink.Set_TitlePoint(const Value:AnsiString);
begin
  FTitlePoint:=Value;
end;

{TEventSink.IUnknown}
{function TEventSink._AddRef:Integer;
begin  // No need to implement, since lifetime is tied to client
  Result:=InterLockedIncrement(FRefCount);
end;

function TEventSink._Release:Integer;
begin  // No need to implement, since lifetime is tied to client
  Result:=InterLockedDecrement(FRefCount);
  if Result=0 then Destroy;
end;}

function TEventSink.QueryInterface(const IID:TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then Result:=S_OK//First look for my own implementation of an interface (I implement IUnknown and IDispatch).
    else if IsEqualIID(IID, FIIDEvents) then Result:=QueryInterface(IDispatch, Obj)//Next, if they are looking for outgoing interface, recurse to return//our IDispatch pointer.
      else Result:=E_NOINTERFACE;//For everything else, return an error.
end;

{TEventSink.IDispatch}
function TEventSink.GetIDsOfNames(const IID:TGUID; Names:Pointer; NameCount, LocaleID:Integer; DispIDs:Pointer):HResult;
begin
  Result:=E_NOTIMPL;
end;

function TEventSink.GetTypeInfo(Index, LocaleID:Integer; out TypeInfo):HResult;
begin
  Pointer(TypeInfo):=nil;
  Result:=E_NOTIMPL;
end;

function TEventSink.GetTypeInfoCount(out Count:Integer):HResult;
begin
  Count:=0;
  Result:=S_OK;
end;
     
function TEventSink.Invoke(DispID:Integer; const IID:TGUID; LocaleID:Integer; Flags:Word; var Params; VarResult, ExcepInfo, ArgErr:Pointer):HResult;
begin
  try
    if Assigned(FOnInvoke) then FOnInvoke(DispID, TDispParams(Params)) else begin
      raise exception.create('OnInvoke is not assigned.');
    end;
    {case DispID of
    Else
      raise exception.create('Неизвестное значение DispID='+IntToStr(DispID)+'.');
    end;}
    Result:=S_OK;
  except on e:exception do begin
    if ExcepInfo<>nil then begin
      FillChar(ExcepInfo^, SizeOf(TExcepInfo), 0);
      PExcepInfo(ExcepInfo)^.bstrSource:=StringToOleStr('Invoke');
      PExcepInfo(ExcepInfo)^.bstrDescription:=StringToOleStr(FTitlePoint+': '+'Invoke: '+e.message);
      PExcepInfo(ExcepInfo)^.scode:=E_FAIL;
    end;
    result:=DISP_E_EXCEPTION;
  end;end;
end;

procedure TEventSink.InterfaceConnectEx(const Source:IUnknown; const Sink:IUnknown; var Connection:Longint);
  var CPC:IConnectionPointContainer;
      CP:IConnectionPoint;
      Res:HResult;
begin
  Connection:=0;
  Res:=Source.QueryInterface(IConnectionPointContainer, CPC);
  try
    if Succeeded(Res) then begin
      Res:=CPC.FindConnectionPoint(FIIDEvents, CP);
      if Succeeded(Res) then begin
        Res:=CP.Advise(Sink, Connection);
        if Succeeded(Res) then Exit//No Error
                          else raise exception.create('Advise: ');
      end else raise exception.create('FindConnectionPoint: ');
    end else raise exception.create('QueryInterface: ');
  except on e:exception do begin
    e.message:='InterfaceConnect.'+e.message+SysErrorMessage(ResultCode(Res))+'('+IntToStr(ResultCode(Res))+').';
    raise;
  end;end;
end;

procedure TEventSink.InterfaceDisconnectEx(const Source:IUnknown; var Connection:Longint);
  var CPC:IConnectionPointContainer;
      CP:IConnectionPoint;
      Res:HResult;
begin
  if Connection<>0 then begin
    Res:=Source.QueryInterface(IConnectionPointContainer, CPC);
    try
      if Succeeded(Res) then begin
        Res:=CPC.FindConnectionPoint(FIIDEvents, CP);
        if Succeeded(Res) then begin
          Res:=CP.Unadvise(Connection);
          if Succeeded(Res) then begin
            Connection:=0;
            Exit;
          end else raise exception.create('Unadvise: ');
        end else raise exception.create('FindConnectionPoint: ');
      end else raise exception.create('QueryInterface: ');
    except on e:exception do begin
      e.message:='InterfaceDisconnect.'+e.message+SysErrorMessage(ResultCode(Res))+'('+IntToStr(ResultCode(Res))+').';
      raise;
    end;end;
  end;
end;

end.
