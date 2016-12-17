unit UCallerTask;

interface
  uses UITObject, UCallerTaskTypes, UTTaskTypes;
type
  TCallerTask=class(TITObject, ICallerTask)
  private
    FCanceled:Boolean;
    FResult:variant;
    FErrorMessage:AnsiString;
    FErrorHelpContext:Integer;
    FStatus:TSTTaskStatus;
    FNextBlockTask:ICallerTask;
    FNextBlockTaskTask:ICallerTaskTask;
    FNextTask:ICallerTask;
    FNextTaskTask:ICallerTaskTask;
    FExceptTask:ICallerTask;
    FExceptTaskTask:ICallerTaskTask;
  protected
    function Get_Canceled:Boolean;virtual;
    procedure Set_Canceled(value:Boolean);virtual;
    function Get_Result:variant;virtual;
    function Get_ResultPtr:pvariant;
    function Get_ErrorMessage:AnsiString;virtual;
    function Get_ErrorHelpContext:Integer;virtual;
    function Get_Status:TSTTaskStatus;virtual;
    procedure Set_Status(value:TSTTaskStatus);virtual;
    function Get_NextBlockTask:ICallerTask;virtual;
    procedure Set_NextBlockTask(value:ICallerTask);virtual;
    function Get_NextTask:ICallerTask;virtual;
    procedure Set_NextTask(value:ICallerTask);virtual;
    function Get_ExceptTask:ICallerTask;virtual;
    procedure Set_ExceptTask(value:ICallerTask);virtual;
    function Get_NextBlockTaskTask:ICallerTaskTask;virtual;
    procedure Set_NextBlockTaskTask(value:ICallerTaskTask);virtual;
    function Get_NextTaskTask:ICallerTaskTask;virtual;
    procedure Set_NextTaskTask(value:ICallerTaskTask);virtual;
    function Get_ExceptTaskTask:ICallerTaskTask;virtual;
    procedure Set_ExceptTaskTask(value:ICallerTaskTask);virtual;
  public
    constructor create;
    destructor destroy;override;
    procedure SetComplete(const aResult:Variant);virtual;
    procedure SetError(const aMessage:AnsiString; aHelpContext:Integer);virtual;
    property Canceled:Boolean read Get_Canceled write Set_Canceled;//Отменено (дальнейшее)выполнение задачи
    property Result:variant read Get_Result;//Основной параметр
    property ResultPtr:pvariant read Get_ResultPtr;//Основной параметр
    property ErrorMessage:AnsiString read Get_ErrorMessage;//Ошибка при выполнении задачи
    property ErrorHelpContext:Integer read Get_ErrorHelpContext;//Helpcontext ошибки при выполнении задачи
    property Status:TSTTaskStatus read Get_Status write Set_Status;//Статус выполняемой задачи
    property NextBlockTask:ICallerTask read Get_NextBlockTask write Set_NextBlockTask;//Следующая блочная задача, выполняется только если в предыдущей задаче не было ошибки.
    property NextBlockTaskTask:ICallerTaskTask read Get_NextBlockTaskTask write Set_NextBlockTaskTask;
    property NextTask:ICallerTask read Get_NextTask write Set_NextTask;//Следующая задача, выполняется независимо от того была ли ошибка в предыдущей задаче. это нужно для последовательного выполнения
    property NextTaskTask:ICallerTaskTask read Get_NextTaskTask write Set_NextTaskTask;
    property ExceptTask:ICallerTask read Get_ExceptTask write Set_ExceptTask;//Задача вслучае ошибки при выолнении. Сообщение и HelpContext можно взять из aTaskPath.PrevTaskPath.CurrCallerTask.ITResultErrorMessage
    property ExceptTaskTask:ICallerTaskTask read Get_ExceptTaskTask write Set_ExceptTaskTask;
  end;


  TCallerTaskTask=class(TITObject, ICallerTaskTask)
  private
    FTask:TTask;
    FParams:Variant;
  protected
    function Get_Task:TTask;virtual;
    procedure Set_Task(value:TTask);virtual;
    function Get_Params:Variant;virtual;
    procedure Set_Params(const value:Variant);virtual;
  public
    constructor create;
    destructor destroy;override;
    property Task:TTask read Get_Task write Set_Task;
    property Params:Variant read Get_Params write Set_Params;
  end;

implementation
  uses variants;

constructor TCallerTaskTask.create;
begin
  inherited create;
  FTask:=tskMTNone;
  FParams:=unassigned;
end;

destructor TCallerTaskTask.destroy;
begin
  FParams:=unassigned;
  inherited destroy;
end;

function TCallerTaskTask.Get_Task:TTask;
begin
  InternalLock;
  try
    result:=FTask;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerTaskTask.Set_Task(value:TTask);
begin
  InternalLock;
  try
    FTask:=value;
  finally
    InternalUnlock;
  end;
end;

function TCallerTaskTask.Get_Params:Variant;
begin
  InternalLock;
  try
    result:=FParams;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerTaskTask.Set_Params(const value:Variant);
begin
  InternalLock;
  try
    FParams:=value;
  finally
    InternalUnlock;
  end;
end;

constructor TCallerTask.create;
begin
  inherited create;
  FCanceled:=false;
  FResult:=unassigned;
  FErrorMessage:='';
  FErrorHelpContext:=0;
  FStatus:=tssNoTask;
  FNextBlockTask:=nil;
  FNextBlockTaskTask:=nil;
  FNextTask:=nil;
  FNextTaskTask:=nil;
  FExceptTask:=nil;
  FExceptTaskTask:=nil;
end;

destructor TCallerTask.destroy;
begin
  FResult:=unassigned;
  FErrorMessage:='';
  FNextBlockTask:=nil;
  FNextBlockTaskTask:=nil;
  FNextTask:=nil;
  FNextTaskTask:=nil;
  FExceptTask:=nil;
  FExceptTaskTask:=nil;
  inherited destroy;
end;

function TCallerTask.Get_Canceled:Boolean;
begin
  InternalLock;
  try
    result:=FCanceled;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerTask.Set_Canceled(value:Boolean);
begin
  InternalLock;
  try
    FCanceled:=value;
  finally
    InternalUnlock;
  end;
end;

function TCallerTask.Get_Result:variant;
begin
  InternalLock;
  try
    result:=FResult;
  finally
    InternalUnlock;
  end;
end;

function TCallerTask.Get_ResultPtr:pvariant;
begin
  InternalLock;
  try
    result:=@FResult;
  finally
    InternalUnlock;
  end;
end;

function TCallerTask.Get_ErrorMessage:AnsiString;
begin
  InternalLock;
  try
    result:=FResult;
  finally
    InternalUnlock;
  end;
end;

function TCallerTask.Get_ErrorHelpContext:Integer;
begin
  InternalLock;
  try
    result:=FErrorHelpContext;
  finally
    InternalUnlock;
  end;
end;

function TCallerTask.Get_Status:TSTTaskStatus;
begin
  InternalLock;
  try
    result:=FStatus;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerTask.Set_Status(value:TSTTaskStatus);
begin
  InternalLock;
  try
    FStatus:=value;
  finally
    InternalUnlock;
  end;
end;

function TCallerTask.Get_NextBlockTask:ICallerTask;
begin
  InternalLock;
  try
    result:=FNextBlockTask;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerTask.Set_NextBlockTask(value:ICallerTask);
begin
  InternalLock;
  try
    FNextBlockTask:=value;
  finally
    InternalUnlock;
  end;
end;

function TCallerTask.Get_NextTask:ICallerTask;
begin
  InternalLock;
  try
    result:=FNextTask;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerTask.Set_NextTask(value:ICallerTask);
begin
  InternalLock;
  try
    FNextTask:=value;
  finally
    InternalUnlock;
  end;
end;

function TCallerTask.Get_ExceptTask:ICallerTask;
begin
  InternalLock;
  try
    result:=FExceptTask;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerTask.Set_ExceptTask(value:ICallerTask);
begin
  InternalLock;
  try
    FExceptTask:=value;
  finally
    InternalUnlock;
  end;
end;

function TCallerTask.Get_NextBlockTaskTask:ICallerTaskTask;
begin
  InternalLock;
  try
    result:=FNextBlockTaskTask;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerTask.Set_NextBlockTaskTask(value:ICallerTaskTask);
begin
  InternalLock;
  try
    FNextBlockTaskTask:=value;
  finally
    InternalUnlock;
  end;
end;

function TCallerTask.Get_NextTaskTask:ICallerTaskTask;
begin
  InternalLock;
  try
    result:=FNextTaskTask;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerTask.Set_NextTaskTask(value:ICallerTaskTask);
begin
  InternalLock;
  try
    FNextTaskTask:=value;
  finally
    InternalUnlock;
  end;
end;

function TCallerTask.Get_ExceptTaskTask:ICallerTaskTask;
begin
  InternalLock;
  try
    result:=FExceptTaskTask;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerTask.Set_ExceptTaskTask(value:ICallerTaskTask);
begin
  InternalLock;
  try
    FExceptTaskTask:=value;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerTask.SetComplete(const aResult:Variant);
begin
  InternalLock;
  try
    FResult:=aResult;
    FStatus:=tssComplete;
  finally
    InternalUnlock;
  end;
end;

procedure TCallerTask.SetError(const aMessage:AnsiString; aHelpContext:Integer);
begin
  InternalLock;
  try
    FErrorMessage:=aMessage;
    FErrorHelpContext:=aHelpContext;
    FStatus:=tssError;
  finally
    InternalUnlock;
  end;
end;

end.
