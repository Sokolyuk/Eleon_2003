unit UTaskCallerTypes;
������� ��. CallerTaskTypes  
interface
  Uses UTTaskTypes, UCallerTypes, UTypes;

Type
  ITaskCaller=Interface
  ['{1CA32C5F-BE10-4EE8-B4C3-6E8FAE6C92D7}']
    Function ITGet_Task:TTask;
    Procedure ITSet_Task(Value:TTask);
    Function ITGet_IsSuspendTask:Boolean;
    Function ITGet_Numbered:Integer;
    Procedure ITSet_Numbered(Value:Integer);
    Function ITGet_TaskID:Integer;
    Procedure ITSet_TaskID(Value:Integer);
    Function ITGet_Sleep:LongWord;
    Procedure ITSet_Sleep(Value:LongWord);
    Function ITGet_Wakeup:TDateTime;
    Procedure ITSet_Wakeup(Value:TDateTime);
    Function ITGet_IsWakeupTask:Boolean;
    Function ITGet_Params:Variant;
    Procedure ITSet_Params(Value:Variant);
    Function ITGet_ResultData:Variant;
    Procedure ITSet_ResultData(Value:Variant);
    Function IT_GetResultErrorMessage:AnsiString;
    Procedure IT_SetResultErrorMessage(Value:AnsiString);
    //Function ITGet_SenderParams:Variant;
    //Procedure ITSet_SenderParams(Value:Variant);
    Function ITGet_CallerAction:ICallerAction;
    Procedure ITSet_CallerAction(Value:ICallerAction);
    Function ITGet_Status:TSTTaskStatus;
    Procedure ITSet_Status(Value:TSTTaskStatus);
    Function ITGet_Canceled:Boolean;
    Procedure ITSet_Canceled(Value:Boolean);
    Function IT_GetNextTask:ITaskCaller;
    Procedure IT_SetNextTask(Value:ITaskCaller);
    Function IT_GetExceptTask:ITaskCaller;
    Procedure IT_SetExceptTask(Value:ITaskCaller);
    Function IT_GetResultErrorHelpContext:Integer;
    Procedure IT_SetResultErrorHelpContext(Value:Integer);
    Function IT_GetNextBlockTask:ITaskCaller;
    Procedure IT_SetNextBlockTask(Value:ITaskCaller);
    //..
    Function ITClone:ITaskCaller;//������� �����
    //..
    ?Property ITTask:TTask read ITGet_Task write ITSet_Task;               //������
    Property ITIsSuspendTask:Boolean read ITGet_IsSuspendTask;            //��� ���������� ������
    Property ITNumbered:Integer read ITGet_Numbered write ITSet_Numbered; //������������ ��� ���(-1)
    Property ITTaskID:Integer read ITGet_TaskID write ITSet_TaskID;       //����������� �������������(���� ITNumbered<>-1 �� ITNumbered)
    Property ITSleep:LongWord read ITGet_Sleep write ITSet_Sleep;         //����� ������� ����� Now() ������ ���������
    Property ITWakeup:TDateTime read ITGet_Wakeup write ITSet_Wakeup;     //����� � ������� ���� ���������
    Property ITIsWakeupTask:Boolean read ITGet_IsWakeupTask;              //��� ���������� ������, ��������� ����� ������������(WakeupTask).
    ?Property ITParams:Variant read ITGet_Params write ITSet_Params;       //�������� ��������
   o Property ITResultData:Variant read ITGet_ResultData write ITSet_ResultData;       //�������� ��������
   o Property ITResultErrorMessage:AnsiString read IT_GetResultErrorMessage write IT_SetResultErrorMessage;//������ ��� ���������� ������
   o Property ITResultErrorHelpContext:Integer read IT_GetResultErrorHelpContext write IT_SetResultErrorHelpContext;//Helpcontext ������ ��� ���������� ������
    //Property ITSenderParams:Variant read ITGet_SenderParams write ITSet_SenderParams; //�������� �����������
    Property ITCallerAction:ICallerAction read ITGet_CallerAction write ITSet_CallerAction; //-
   o Property ITStatus:TSTTaskStatus read ITGet_Status write ITSet_Status; //������ ����������� ������
   o Property ITCanceled:Boolean read ITGet_Canceled write ITSet_Canceled; //�������� (����������)���������� ������
   o Property ITNextBlockTask:ITaskCaller read IT_GetNextBlockTask write IT_SetNextBlockTask;//��������� ������� ������, ����������� ������ ���� � ���������� ������ �� ���� ������.
   o Property ITNextTask:ITaskCaller read IT_GetNextTask write IT_SetNextTask; //��������� ������, ����������� ���������� �� ���� ���� �� ������ � ���������� ������. ��� ����� ��� ����������������� ����������
   o Property ITExceptTask:ITaskCaller read IT_GetExceptTask write IT_SetExceptTask; //������ ������� ������ ��� ���������. ��������� � HelpContext ����� ����� �� aTaskPath.PrevTaskPath.CurrTaskCaller.ITResultErrorMessage
  end;









implementation

end.
