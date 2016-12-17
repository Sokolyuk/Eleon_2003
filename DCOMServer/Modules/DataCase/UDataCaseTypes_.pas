unit UDataCaseTypes;

interface
  Uses UTTaskType, UTaskTypes, UTypes, UCallerTypes, UADMTypes, UTaskStorageTypes, UVarsetTypes;

Type
  IBasicDataCase = interface
    ['{5461A6EA-7385-463A-8BF6-FB54344BC46D}']
    // Init DataCase
    Procedure   LoadConfig;
    Procedure   ITMateThreadStart;
    // Message
    Procedure ITMessAdd(aDateTime, aStartTime:TDateTime; Const aAction:AnsiString; aAddr:Pointer; Const aUser, aSource, aMess:AnsiString; aMessageClass:TMessageClass; aMessageStyle:TMessageStyle);
    Function  ITGetUniqueString(aStrongUnique:Boolean=True):AnsiString;
    // Message
    Function  ITGetNewMess(Var iLastMess:Longint; vlClassFilter:TMessClass; vlStyleFilter:TMessStyle):OleVariant;
    Procedure ITMessToBasicLog(aMess:AnsiString; blIndicateTime:boolean=True);
    // MateTask
    Function  ITMateTaskAdd(vlTsk:TTask; Params:Variant; aSenderParams, aSenderSecurityContext:Variant; aTaskNumbered:Integer; Out aTaskID:Integer):Integer;                        overload;
    Function  ITMateTaskAdd(vlTsk:TTask; Params:Variant; aSenderParams, aSenderSecurityContext:Variant):Integer;                                                                    overload;
    Function  ITMateSleepTaskAdd(vlTsk:TTask; Params:Variant; aSenderParams, aSenderSecurityContext:Variant; aSleep:LongWord):Integer;                                              overload;
    Function  ITMateSleepTaskAdd(vlTsk:TTask; Params:Variant; aSenderParams, aSenderSecurityContext:Variant; aSleep:LongWord; aTaskNumbered:Integer; Out aTaskID:Integer):Integer;  overload;
    Function  ITMateWakeUpTaskAdd(vlTsk:TTask; Params:Variant; aSenderParams, aSenderSecurityContext:Variant; aWakeup:Comp):Integer;                                                overload;
    Function  ITMateWakeUpTaskAdd(vlTsk:TTask; Params:Variant; aSenderParams, aSenderSecurityContext:Variant; aWakeup:Comp; aTaskNumbered:Integer; Out aTaskID:Integer):Integer;    overload;
    // Misc
    Function  Get_ServerName:Ansistring;
    Property  stServerName:AnsiString read Get_ServerName;
    Function  ITAdmittanceASM_StopAllASMServers : Integer ;                           // остановить все ASM в списке (в ASM.destroy вызываетс€ функци€ GLAdmittanceASM_ListASMDel(Self))
    Function  ITAdmittanceASM_StopASMServerOnID(iIDASM:Integer): Integer;             // остановить ASM с указанным ID
    Function  ITAdmittanceASM_StopASMServerOnUser(stUserASM:AnsiString): Integer;     // остановить все ASM, которые принадлежат указанному User'у.
    // ShotDown
    Procedure SetITSetShotDown(Value:Boolean);
    Function  GetITSetShotDown:Boolean;
    Property  ITShotDown:Boolean read GetITSetShotDown write SetITSetShotDown;
    // ƒоступ к списку ASM серверов
    Procedure ITAdmittanceASM_ListAdd(MyData : Variant);                                     // добавить в список
    function  ITAdmittanceASM_ListDel(aaPntr : Pointer; aaHeedingLock:Boolean):boolean;      // удалить из списка
    Function  ITAdmittanceASM_ListUpdate(aaASMNum:Integer; NewData:Variant):Boolean;
    Function  ITAdmittanceASM_CountOfListASM : Integer;                                      // количество серверов в списке
    Function  ITAdmittanceASM_GetAddrNextASMAndLock( CurrentAddr : Pointer ) : Pointer;      // на входе адрес текущего ASM на выходе адрес следующего ASM (дл€ получени€ адреса первого ASM на вход Nil).
    Function  ITAdmittanceASM_GetAddrPrevASMAndLock( CurrentAddr : Pointer ) : Pointer;      // јналогично GLAdmittanceASM_GetAddrNextASM, но только с конца.
    Function  ITAdmittanceASM_GetPntrOnIdAndLock(aaASMSenderNum:Integer):Pointer;
    Function  ITAdmittanceASM_GetInfoNextASMAndLock  ( CurrentAddr : Pointer ) : Variant;      // на входе адрес текущего ASM на выходе адрес следующего ASM (дл€ получени€ адреса первого ASM на вход Nil).
    Function  ITAdmittanceASM_GetInfoPrevASMAndLock  ( CurrentAddr : Pointer ) : Variant;      // јналогично GLAdmittanceASM_GetAddrNextASM, но только с конца.
    Function  ITAdmittanceASM_GetInfoNextASMAndNoLock( CurrentAddr : Pointer ) : Variant;
    Function  ITAdmittanceASM_GetInfoPrevASMAndNoLock( CurrentAddr : Pointer ) : Variant;
    Function  ITAdmittanceASM_GetInfoASMOnPntrAndNoLock( CurrentAddr : Pointer ) : Variant;
    Function  ITAdmittanceASM_GetInfoASMOnPntrAndLock( CurrentAddr : Pointer ) : Variant;
    Function  ITAdmittanceASM_GetInfoASMOnIdAndNoLock( aaASMNum:Integer ) : Variant;
    Function  ITAdmittanceASM_GetInfoASMOnIdAndLock( aaASMNum:Integer ) : Variant;
    // ..
    Function  ITSecurityReliableAdd(const vlData: WideString):Integer;
    Function  ITSecurityReliableDel(vlId: Integer):boolean;
    Function  ITGetOnLineStatus:Boolean;
    Function  ITSecurityReliableCheck(vlId: Integer; const vlData: WideString): Boolean;
    procedure ITSetOnLineStatus(Value:Boolean; MySecurityContext:Variant);
    Property  ITOnLineStatus:Boolean read ITGetOnLineStatus;
    Function  ITGetOnLineMode:Integer;
    Procedure ITSetOnLineMode(Value:Integer);
    Property  ITOnLineMode:Integer read ITGetOnLineMode write ITSetOnLineMode;
    Function  ITMateResCancelAllResultForASM(aaASMNum:Integer): boolean;
    // MateRes
    Function  ITMateResGetStatus(aaSTTaskNum:Integer):TSTTaskStatus;
    Function  ITMateResCancelResult(aaSTTaskNum:Integer): boolean;
    Function  ITMateResElicitResult(aaSTTaskNum:Integer; Var vRes:Variant):Boolean;
    // Hide/Show ASM
    Function  ITAdmittanceASM_Hide(aASMNum:Integer):Boolean;
    Function  ITAdmittanceASM_Show(aASMNum:Integer):Boolean;
     // Lock/UnLock ASM
    Function  ITAdmittanceASM_Lock(aASMNum:Integer):Integer;      Overload;
    Function  ITAdmittanceASM_Lock(aPntr:Pointer):Integer;        Overload;
    Function  ITAdmittanceASM_UnLock(aASMNum:Integer):Integer;    Overload;
    Function  ITAdmittanceASM_UnLock(aPntr:Pointer):Integer;      Overload;
    Function  ITAdmittanceASM_LockCount(aPntr:Pointer):Integer;   Overload;
    Function  ITAdmittanceASM_LockCount(aASMNum:Integer):Integer; Overload;
    // LockList
    Function  ITGenerateLockOwner:Integer;
    Procedure ITClearLockOwner(aLockOwnerNum:Integer; aCallerAction:ICallerAction);
    Function  ITSetLockList(const aTab, aUser:WideString; aLockOwnerNum:Integer; aCallerAction:ICallerAction; aIfFailThenRaise:Boolean; aMessAdd:boolean=true):Boolean;
    Function  ITGetLockList:Variant;
    // Securety
    Procedure ITReloadSecurety;
    Procedure ITCheckSecurityLDB(aTables, aSecurityContext:Variant); {>17<}
    Procedure ITCheckSecurityMTask(aMTask:TTask; aSecurityContext:Variant);
    Procedure ITCheckSecurityPTask(aPTask:TADMTask; aSecurityContext:Variant);
    // Lock
    // Server lock
    Function  Get_ITServerLockMessage : AnsiString;
    Function  Get_ITServerLockUser:AnsiString;
    Function  Get_blServerLock : boolean;
    Property  ITServerLockMessage : AnsiString read Get_ITServerLockMessage {write Set_ITServerLockMessage};
    Property  ITServerLockUser : AnsiString read Get_ITServerLockUser;
    Property  ITblServerLock : boolean read Get_blServerLock {write Set_blServerLock};
    Procedure ITServerLock(aUser, aMessage:AnsiString);
    Procedure ITServerUnLock;
    // Info
    Function  ITMateTask:Variant;
    Function  ITMateSleepTask:Variant;
    Function  ITMateRes:Variant;
    Function  ITMateArray:Variant;
    Function  ITMateTaskIgnore:Variant;
    Function  ITMatePerpetualCheckReady:Boolean;
    Function  ITServerInfo(vlPartId:Integer{TxPartOfInfo}):Variant;
    procedure ITGetASMServers(out vlASMServers, vlExtDataASMServers: Variant);
    Function  ITMateTaskCancel(aTaskID:Integer):Boolean;
    Procedure ITMateIgnoreTaskAdd(aTask:TTask);
    // Misc
    Function  ITMateIgnoreTaskCancel(aTask:TTask):Boolean;
    Function  ITNewActionID:Integer;
  end;

(*  IDataCaseEMS = interface(IBasicDataCase)
  ['{02336E61-6A1C-44F6-8553-90E3DD662DD9}']
  End;

  IDataCasePGS = interface(IBasicDataCase)
  ['{152F516B-A577-45A3-922E-23B6598C765F}']
  End;*)

  IDataCase=Interface
  ['{CAB84DC1-1AEE-4391-A0AF-17DE0D0E44CE}']
    Function IT_GetITaskStorage:ITaskStorage;
    Function IT_GetITaskThreads:IVarset;
    Function IT_GetOwnerCallerAction:ICallerAction;
    procedure IT_SetOwnerCallerAction(Value:ICallerAction);
    {..}
    Procedure ITResumeTaskThreads;
    Procedure ITDataCaseStop;
    Procedure ITDataCaseStart;
    Property ITITaskStorage:ITaskStorage read IT_GetITaskStorage;
    Property ITITaskThreads:IVarset read IT_GetITaskThreads;
    Property ITOwnerCallerAction:ICallerAction read IT_GetOwnerCallerAction write IT_SetOwnerCallerAction;
  End;

implementation

end.
