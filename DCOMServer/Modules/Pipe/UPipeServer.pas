unit UPipeServer;

interface
  uses Classes, Windows;

type
  TPipeMultiServerBase=class(TThread)
  private
    FPipeName:AnsiString;
    FEvents:array[0..1] of THandle;
    FPipe:THandle;
  protected
    procedure InternalInit;Virtual;
    procedure Execute;override;
    procedure InternalSetMessErr(aStartTime:TDateTime; Const aMessage:AnsiString; aHelpContext:Integer);Virtual;abstract;
    procedure InternalHandCallServer(aPipe:Thandle);Virtual;abstract;
  public
    constructor Create(CreateSuspended:Boolean; Const aPipeName:AnsiString);
    destructor Destroy;override;
    procedure Terminate;Virtual;
  end;

  TPipeCallServerBase=class(TThread)
  private
    FPipe:THandle;
    FMemPointer:Pointer;
    FMemPointerSize:DWORD;
    FEvents:array[0..1] of THandle;
  protected
    procedure InternalInit;Virtual;
    procedure InternalServerReadFromPipe;Virtual;abstract;
    procedure InternalComplete(aStartTime:TDateTime);Virtual;abstract;
    procedure InternalSetMessErr(aStartTime:TDateTime; Const aMessage:AnsiString; aHelpContext:Integer);Virtual;abstract;
    procedure Execute;override;
  public
    constructor Create(aPipe:THandle);
    destructor Destroy;override;
    procedure Terminate;Virtual;
  end;


implementation
  Uses SysUtils, UPipeServerUtils{, UDataCaseConsts, UConsts, UTTaskTypes, Variants, UTypeUtils, UTaskTypes};

constructor TPipeMultiServerBase.Create(CreateSuspended:Boolean; Const aPipeName:AnsiString);
begin
  FPipeName:=aPipeName;
  FillChar(FEvents, Sizeof(FEvents), 0);
  InternalInit;
  inherited Create(CreateSuspended);
end;

destructor TPipeMultiServerBase.Destroy;
begin
  CloseHandle(FEvents[0]);
  CloseHandle(FEvents[1]);
  CloseHandle(FPipe);
  FPipeName:='';
  inherited Destroy;
end;

procedure TPipeMultiServerBase.Terminate;
begin
  SetEvent(FEvents[1]);
  Inherited Terminate;
end;

procedure TPipeMultiServerBase.InternalInit;
  var tmpEvent, tmpPipe:THandle;
begin
  //Создаю событие для Connect/Read/Write
  tmpEvent:=CreateEvent(
         Nil,     // no security attribute
         TRUE,    // manual-reset event
         TRUE,    // initial state = signaled
         Nil);    // unnamed event object
  If tmpEvent=0 Then Raise Exception.Create('tmpEvents=0');
  ResetEvent(tmpEvent);
  FEvents[0]:=tmpEvent;
  //Создаю событие для Terminate
  tmpEvent:=CreateEvent(
         Nil,     // no security attribute
         TRUE,    // manual-reset event
         TRUE,    // initial state = signaled
         Nil);    // unnamed event object
  If tmpEvent=0 Then Raise Exception.Create('tmpEvents=0');
  ResetEvent(tmpEvent);
  FEvents[1]:=tmpEvent;
  //..
  tmpPipe:=CreateNamedPipe(
         PChar(FPipeName),        // pipe name
         PIPE_ACCESS_DUPLEX Or    // read/write access
         FILE_FLAG_OVERLAPPED,    // overlapped mode
         PIPE_TYPE_MESSAGE Or     // message-type pipe
         PIPE_READMODE_MESSAGE Or // message-read mode
         PIPE_WAIT,               // blocking mode
         PIPE_UNLIMITED_INSTANCES{1},                       // number of instances
         0,                       // output buffer size
         0,                       // input buffer size
         15000,                   // client time-out
         Nil);                    // no security attributes
  If tmpPipe=INVALID_HANDLE_VALUE then Raise Exception.Create('tmpPipe=INVALID_HANDLE_VALUE. Не удается создать Pipe='''+FPipeName+''', возможно он уже создан.');
  FPipe:=tmpPipe;
end;

{procedure TPipeMultiServerBase.InternalCreateCallServer(aPipe:Thandle);
begin
  TPipeCallServerBase.Create(aPipe);
end;}

procedure TPipeMultiServerBase.Execute;
  Var tmpGetLastError:Cardinal;
      tmpOverlapped:TOverlapped;
      tmpNow:TDateTime;
begin
  While Not Terminated do begin
    tmpNow:=Now;
    try
      Fillchar(tmpOverlapped, Sizeof(tmpOverlapped), 0);
      tmpOverlapped.hEvent:=FEvents[0];
      ResetEvent(FEvents[0]);
      //..
      If ConnectNamedPipe(FPipe, @tmpOverlapped) then Raise Exception.Create('ConnectNamedPipe should return false.');//Соединяюсь с клиентом
      tmpGetLastError:=GetLastError;
      Case tmpGetLastError of
        ERROR_IO_PENDING:;//Ok
        ERROR_PIPE_CONNECTED:{SetEvent(FEvents[0])};//Соединился, дергаю событие
      else
        Raise Exception.Create('ConnectNamedPipe: '+SysErrorMessage(tmpGetLastError));
      end;
      InternalHandCallServer(FPipe);
    Except On e:exception Do Begin
      InternalSetMessErr(tmpNow, e.Message, e.HelpContext);
      Sleep(100);
    End;End;
  end;
end;

//* * * TPipeCallServerBase * * *
constructor TPipeCallServerBase.Create(aPipe:THandle);
begin
  FPipe:=aPipe;
  FillChar(FEvents, Sizeof(FEvents), 0);
  FMemPointer:=Nil;
  FMemPointerSize:=0;
  InternalInit;
  inherited Create(False);
end;

destructor TPipeCallServerBase.Destroy;
begin
  CloseHandle(FEvents[0]);
  CloseHandle(FEvents[1]);
  CloseHandle(FPipe);
  FPipe:=0;
  inherited Destroy;
end;

procedure TPipeCallServerBase.Terminate;
begin
  SetEvent(FEvents[1]);
  Inherited Terminate;
end;

procedure TPipeCallServerBase.InternalInit;
  var tmpEvent:THandle;
begin
  //Создаю событие для Connect/Read/Write
  tmpEvent:=CreateEvent(
         Nil,     // no security attribute
         TRUE,    // manual-reset event
         TRUE,    // initial state = signaled
         Nil);    // unnamed event object
  If tmpEvent=0 Then Raise Exception.Create('tmpEvents=0');
  ResetEvent(tmpEvent);
  FEvents[0]:=tmpEvent;
  //Создаю событие для Terminate
  tmpEvent:=CreateEvent(
         Nil,     // no security attribute
         TRUE,    // manual-reset event
         TRUE,    // initial state = signaled
         Nil);    // unnamed event object
  If tmpEvent=0 Then Raise Exception.Create('tmpEvents=0');
  ResetEvent(tmpEvent);
  FEvents[1]:=tmpEvent;
end;

procedure TPipeCallServerBase.Execute;
  Var tmpGetLastError:Cardinal;
      tmpRet:Boolean;
      tmpOverlapped:TOverlapped;
      tmpOutSize:Cardinal;
      tmpDataSize:Cardinal;
      tmpResultString:AnsiString;
      tmpNow:TDateTime;
begin
  tmpNow:=Now;
  try
    try
      InternalServerReadFromPipe;
    finally
      FlushFileBuffers(FPipe);
      DisconnectNamedPipe(FPipe);
    end;
    InternalComplete(tmpNow);
  Except On e:exception Do Begin
    InternalSetMessErr(tmpNow, e.Message, e.HelpContext);
    Sleep(100);
  End;End;
end;

{procedure TPipeCallServerBase.InternalComplete(aStartTime:TDateTime);
begin
end;

procedure TPipeCallServerBase.InternalServerReadFromPipe;
begin
end;}

end.
