//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UCallerTaskTypes;

interface
  uses UTTaskTypes;
type
  ICallerTaskTask=interface
  ['{435A0DA6-96E7-4805-A7AF-59CAD60B1BD0}']
    function Get_Task:TTask;
    procedure Set_Task(value:TTask);
    function Get_Params:Variant;
    procedure Set_Params(const value:Variant);
    property Task:TTask read Get_Task write Set_Task;
    property Params:Variant read Get_Params write Set_Params;
  end;

  TSTTaskStatus=({0}tssNoTask, {1}tssExecute, {2}tssComplete, {3}tssError, {4}tssCanceled);
  ICallerTask=interface
  ['{8A3F072F-5B9C-49C7-A547-1D3F5EDF3542}']
    function Get_Canceled:Boolean;
    procedure Set_Canceled(value:Boolean);
    function Get_Result:variant;
    function Get_ResultPtr:pvariant;
    function Get_ErrorMessage:AnsiString;
    function Get_ErrorHelpContext:Integer;
    function Get_Status:TSTTaskStatus;
    procedure Set_Status(value:TSTTaskStatus);
    function Get_NextBlockTask:ICallerTask;
    procedure Set_NextBlockTask(value:ICallerTask);
    function Get_NextTask:ICallerTask;
    procedure Set_NextTask(value:ICallerTask);
    function Get_ExceptTask:ICallerTask;
    procedure Set_ExceptTask(value:ICallerTask);
    function Get_NextBlockTaskTask:ICallerTaskTask;
    procedure Set_NextBlockTaskTask(value:ICallerTaskTask);
    function Get_NextTaskTask:ICallerTaskTask;
    procedure Set_NextTaskTask(value:ICallerTaskTask);
    function Get_ExceptTaskTask:ICallerTaskTask;
    procedure Set_ExceptTaskTask(value:ICallerTaskTask);
    procedure SetComplete(const aResult:Variant);
    procedure SetError(const aMessage:AnsiString; aHelpContext:Integer);
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

implementation

end.

