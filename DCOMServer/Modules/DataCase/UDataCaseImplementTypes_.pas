unit UDataCaseImplementTypes;

interface
  Uses UTaskThreadTypes, UTaskStorageTypes, UVarsetTypes, UTaskImplementTypes, UCallerTypes;

Type
  IDataCaseImplement=Interface
  ['{D54216CA-EE3F-4A19-B3BB-A7CDC811F1BC}']
    Function IT_GetIOnTaskThreadDestroy:IOnTaskThreadDestroy;
    Function IT_GetIOnTaskThreadViewTask:IOnTaskThreadViewTask;
    Function IT_GetIOnTaskThreadInactivity:IOnTaskThreadInactivity;
    Function IT_GetIOnTaskStorageTaskPush:IOnTaskStorageTaskPush;
    Function IT_GetITaskStorage:ITaskStorage;
    procedure IT_SetITaskStorage(Value:ITaskStorage);
    Function IT_GetITaskThreads:IVarset;
    procedure IT_SetITaskThreads(Value:IVarset);
    Function IT_GetITaskImplement:ITaskImplement;
    procedure IT_SetITaskImplement(Value:ITaskImplement);
    Function IT_GetOwnerCallerAction:ICallerAction;
    procedure IT_SetOwnerCallerAction(Value:ICallerAction);
    {..}
    Function ITTaskThreadToIVarsetDataView(aITaskThread:ITaskThread):IVarsetDataView;
    Procedure ITDestroyTaskThread(Var aTaskThread:ITaskThread);
    Procedure ITPushTaskThread(aITaskThread:ITaskThread; aPerpetual:Boolean);
    Function ITCreateTaskThread:ITaskThread;
    {..}
    Property ITITaskStorage:ITaskStorage read IT_GetITaskStorage write IT_SetITaskStorage;
    Property ITITaskThreads:IVarset read IT_GetITaskThreads write IT_SetITaskThreads;
    Property ITITaskImplement:ITaskImplement read IT_GetITaskImplement write IT_SetITaskImplement;
    Property ITOwnerCallerAction:ICallerAction read IT_GetOwnerCallerAction write IT_SetOwnerCallerAction;
    {..}
    Property ITIOnTaskThreadDestroy:IOnTaskThreadDestroy read IT_GetIOnTaskThreadDestroy;
    Property ITIOnTaskThreadViewTask:IOnTaskThreadViewTask read IT_GetIOnTaskThreadViewTask;
    Property ITIOnTaskThreadInactivity:IOnTaskThreadInactivity read IT_GetIOnTaskThreadInactivity;
    Property ITIOnTaskStorageTaskPush:IOnTaskStorageTaskPush read IT_GetIOnTaskStorageTaskPush;
  End;

implementation

end.
