unit UPipeServerBase;

interface
  uses UIObject, Classes, Windows, UPipeServerBaseTypes;

type
  TNamedPipe=Class(TIObject, INamedPipe)
  private
    FPipe:THandle;
    FOverlapped:TOverlapped;
    FEventWait:THandle;
  protected
    function GetPipe:THandle;virtual;
    function GetEventWait:THandle;virtual;
  public
    constructor Create(const aPipeName:AnsiString);
    destructor Destroy;override;
    property Pipe:THandle read GetPipe;
    property EventWait:THandle read GetEventWait;
  end;

  TPipeMultiServerBase=class(TThread)
  protected
    FPipeName:AnsiString;
    FEventBreak:THandle;
    FStartTime:TDateTime;
  protected
    procedure InternalInit;virtual;
    procedure Execute;override;
    function CreateNamedPipe:TNamedPipe;virtual;
    procedure InternalSetMess(aStartTime:TDateTime; const aMessage:AnsiString);virtual;abstract;
    procedure InternalSetMessErr(aStartTime:TDateTime; const aMessage:AnsiString; aHelpContext:Integer);virtual;abstract;
    procedure InternalHandCallServer(aNamedPipe:INamedPipe);virtual;abstract;
  public
    constructor Create(aCreateSuspended:Boolean; const aPipeName:AnsiString);
    destructor Destroy;override;
    procedure Terminate;virtual;
  end;

implementation
  Uses SysUtils, UPipeServerConsts;

constructor TPipeMultiServerBase.Create(aCreateSuspended:Boolean; const aPipeName:AnsiString);
begin
  FPipeName:=aPipeName;
  InternalInit;
  FreeOnTerminate:=true;
  FStartTime:=0;
  inherited Create(aCreateSuspended);
  InterLockedIncrement(cnPipeMultiServerCount);
end;

destructor TPipeMultiServerBase.Destroy;
begin
  CloseHandle(FEventBreak);
  InternalSetMess(FStartTime, ClassName+'(PipeName='''+FPipeName+''') is destroyed.');
  FPipeName:='';
  inherited Destroy;
  InterLockedDecrement(cnPipeMultiServerCount);
end;

procedure TPipeMultiServerBase.Terminate;
begin
  inherited terminate;
  inherited resume;
  SetEvent(FEventBreak);
end;

procedure TPipeMultiServerBase.InternalInit;
begin//Создаю событие для Terminate
  FEventBreak:=CreateEvent(nil{no security attribute}, true{manual-reset event}, true{initial state=signaled}, nil{unnamed event object});
  if FEventBreak=0 then raise exception.create('tmpEvents=0');
  ResetEvent(FEventBreak);
end;

function TPipeMultiServerBase.CreateNamedPipe:TNamedPipe;
begin
  result:=TNamedPipe.Create(FPipeName);
end;

procedure TPipeMultiServerBase.Execute;
  var tmpList:TList;
  procedure localFreeList; begin
    try
      while tmpList.Count>0 do begin
        TNamedPipe(tmpList.Items[0]).Free;
        tmpList.Delete(0);
      end;
    finally
      tmpList.Free;
    end;
  end;
  procedure localCreateNewNamedPipe; var tmplNamedPipe:TNamedPipe; begin
    tmplNamedPipe:=CreateNamedPipe;
    tmpList.Add(pointer(tmplNamedPipe));
  end;
  var tmpNow:TDateTime;
      tmpPointer, tmpPtr:Pointer;
      tmpCardinal:Cardinal;
      tmpNamedPipe:TNamedPipe;
      tmpEvent:THandle;
      tmpBreak:Boolean;
begin
  tmpList:=TList.Create;
  try
    FStartTime:=Now;
    InternalSetMess(FStartTime, ClassName+'(PipeName='''+FPipeName+''') is started.');
    tmpBreak:=false;
    while not terminated do begin
      if tmpBreak then begin
        sleep(10);
        continue;
      end;
      tmpNow:=Now;
      try
        while Cardinal(tmpList.Count)<cnNamedPipeMaxCount do localCreateNewNamedPipe;//Создаю Pipe
        Getmem(tmpPointer, (tmpList.Count+1{для terminate})*SizeOf(THandle));
        try
          for tmpCardinal:=0 to tmpList.Count-1 do begin//Заполняю эвентсами
            tmpEvent:=TNamedPipe(tmpList.Items[tmpCardinal]).EventWait;
            tmpPtr:=Pointer(Cardinal(tmpPointer)+tmpCardinal*SizeOf(THandle));
            move(tmpEvent, tmpPtr^, SizeOf(tmpEvent));
          end;
          tmpEvent:=FEventBreak;
          tmpPtr:=Pointer(Cardinal(tmpPointer)+Cardinal(tmpList.Count)*SizeOf(THandle));
          move(tmpEvent, tmpPtr^, SizeOf(tmpEvent));
          tmpCardinal:=WaitForMultipleObjects(tmpList.Count+1, tmpPointer, False, INFINITE);//Жду пока кто-нибудь соединится или поступит событие остановки сервера.
          case tmpCardinal of
            WAIT_FAILED:raise exception.create('WaitForMultipleObjects(WAIT_FAILED): '+SysErrorMessage(GetLastError));
            WAIT_ABANDONED_0:raise exception.create('WaitForMultipleObjects(WAIT_ABANDONED_0): '+SysErrorMessage(GetLastError));
            WAIT_TIMEOUT:raise exception.create('WaitForMultipleObjects(WAIT_TIMEOUT): '+SysErrorMessage(GetLastError));
          else
            tmpCardinal:=tmpCardinal-WAIT_OBJECT_0{на всякий случай};//получаю номер
            if tmpCardinal>Cardinal(tmpList.Count) then raise exception.create('tmpCardinal='''+IntToStr(tmpCardinal)+'''>tmpList.Count='''+IntToStr(tmpList.Count));
          end;
          if tmpCardinal=Cardinal(tmpList.Count) then begin
            tmpBreak:=true;//break;//Terminate
            continue;
          end;
        finally
          Freemem(tmpPointer);
        end;
        tmpNamedPipe:=TNamedPipe(tmpList.Items[tmpCardinal]);
        tmpList.Delete(tmpCardinal);
        InternalHandCallServer(tmpNamedPipe);
        //Sleep(0);
      except on e:exception do begin
        InternalSetMessErr(tmpNow, e.message, e.HelpContext);
        //Sleep(0);
      end;end;
    end;
  finally
    localFreeList;
  end;
end;

// - - - TNamedPipe - - -
constructor TNamedPipe.Create(const aPipeName:AnsiString);
  var tmpGetLastError:Cardinal;
begin
  inherited Create;
  //Создаю событие для Connect/Read/Write
  FEventWait:=CreateEvent(nil, //no security attribute
                          true,//manual-reset event
                          true,//initial state = signaled
                          nil);//unnamed event object
  if FEventWait=0 then raise exception.create('FEventWait=0');
  ResetEvent(FEventWait);
  FPipe:=CreateNamedPipe(
         PChar(aPipeName),        // pipe name
         PIPE_ACCESS_DUPLEX or    // read/write access
         FILE_FLAG_OVERLAPPED,    // overlapped mode
         PIPE_TYPE_MESSAGE or     // message-type pipe
         PIPE_READMODE_MESSAGE or // message-read mode
         PIPE_WAIT,               // blocking mode
         PIPE_UNLIMITED_INSTANCES{1},// number of instances
         0,                       // output buffer size
         0,                       // input buffer size
         15000,                   // client time-out
         nil);                    // no security attributes
  if FPipe=INVALID_HANDLE_VALUE then raise exception.create('FPipe=INVALID_HANDLE_VALUE. Не удается создать Pipe='''+aPipeName+'''.');
  Fillchar(FOverlapped, Sizeof(FOverlapped), 0);
  FOverlapped.hEvent:=FEventWait;
  ConnectNamedPipe(FPipe, @FOverlapped);//if ? then raise exception.create('ConnectNamedPipe should return true.');//Соединяюсь с клиентом
  tmpGetLastError:=GetLastError;
  case tmpGetLastError of
    ERROR_IO_PENDING:;//Ok
    ERROR_PIPE_CONNECTED:SetEvent(FEventWait);//Соединился, дергаю событие
  else
    raise exception.create('ConnectNamedPipe: '+SysErrorMessage(tmpGetLastError));
  end;
end;

destructor TNamedPipe.Destroy;
begin
  FlushFileBuffers(FPipe);
  DisconnectNamedPipe(FPipe);
  CloseHandle(FEventWait);
  if FPipe<>0 then CloseHandle(FPipe);
  inherited Destroy;
end;

function TNamedPipe.GetPipe:THandle;
begin
  result:=FPipe;
end;

function TNamedPipe.GetEventWait:THandle;
begin
  result:=FEventWait;
end;

end.
