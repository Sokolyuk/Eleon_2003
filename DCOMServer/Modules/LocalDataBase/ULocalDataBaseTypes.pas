//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit ULocalDataBaseTypes;

interface
 Uses db, UAppMessageTypes, UCallerTypes;

Type
  PRunSQLMode=^TRunSQLMode;
  TRunSQLMode=(rmdSQL, rmdProc);
  PRunSQLType=^TRunSQLType;
  TRunSQLType=(rstOpen, rstExec);

  TPersistentMode=record
    Count:Integer;
    Interval:Integer;
  end;

  ILocalDataBase = interface
    ['{E549710D-B89F-4603-B86C-73119F3F8AA6}']
    function Get_DataSet:TDataSet;
    function Get_mecLastError:TMessageClass;
    procedure Set_CallerAction(value:ICallerAction);
    function Get_CallerAction:ICallerAction;
    function Get_FCheckSecuretyLDB:Boolean;
    procedure Set_FCheckSecuretyLDB(Value:Boolean);
    function Get_FTableAutoLock:Boolean;
    procedure Set_FTableAutoLock(Value:Boolean);
    procedure Set_FMessAdd(Value:Boolean);
    function Get_FPersistentMode:TPersistentMode;
    procedure Set_FPersistentMode(Value:TPersistentMode);
    function Get_LockOwner:Integer;
    //Main methods
    function ExistsSQL(const aSQL:AnsiString):boolean;overload;
    function ExistsSQL(const aSQL:AnsiString; out aRecAff:Integer):boolean;overload;
    function ExistsSQL(const aSQL:AnsiString; var aParams:OleVariant):boolean;overload;
    function ExistsSQL(const aSQL:AnsiString; var aParams:OleVariant; out aRecAff:Integer):boolean;overload;
    function ExistsSQL(const aSQL:AnsiString; var aParams:TParams):boolean;overload;
    function ExistsSQL(const aSQL:AnsiString; var aParams:TParams; out aRecAff:Integer):boolean;overload;
    function ExecSQL(const aSQL:AnsiString; var aParams:OleVariant):Integer;overload;
    function ExecSQL(const aSQL:AnsiString; var aParams:TParams):Integer;overload;
    function ExecSQL(const aSQL:AnsiString):Integer;overload;
    function OpenSQL(const aSQL:AnsiString; var aParams:OleVariant; var aRecAff:Integer):OleVariant; overload;
    function OpenSQL(const aSQL:AnsiString; var aParams:TParams; var aRecAff:Integer):OleVariant; overload;
    function OpenSQL(const aSQL:AnsiString; var aRecAff:Integer):OleVariant; overload;
    function OpenSQL(const aSQL:AnsiString; var aParams:OleVariant):OleVariant;overload;
    function OpenSQL(const aSQL:AnsiString; var aParams:TParams):OleVariant;overload;
    function OpenSQL(const aSQL:AnsiString):OleVariant;overload;
    function ExecProc(const aSQL:AnsiString; var aParams:OleVariant):Integer;overload;
    function ExecProc(const aSQL:AnsiString; var aParams:TParams):Integer;overload;
    function ExecProc(const aSQL:AnsiString):Integer;overload;
    function OpenProc(const aSQL:AnsiString; var aParams:OleVariant; var aRecAff:Integer):OleVariant; overload;
    function OpenProc(const aSQL:AnsiString; var aParams:TParams; var aRecAff:Integer):OleVariant; overload;
    function OpenProc(const aSQL:AnsiString; var aParams:OleVariant):OleVariant;overload;
    function OpenProc(const aSQL:AnsiString; var aParams:TParams):OleVariant;overload;
    function OpenProc(const aSQL:AnsiString):OleVariant;overload;
    function WaitForLockList(const aLockList:AnsiString; aRaise:Boolean; aTimeout:Integer):Boolean;
    property CallerAction:ICallerAction read Get_CallerAction write Set_CallerAction;
    property DataSet:TDataSet read Get_DataSet;
    property CheckSecuretyLDB:Boolean read Get_FCheckSecuretyLDB Write Set_FCheckSecuretyLDB;
    property TableAutoLock:Boolean read Get_FTableAutoLock write Set_FTableAutoLock;
    property mecLastError:TMessageClass read Get_mecLastError;
    property MessAdd:Boolean Write Set_FMessAdd;
    property PersistentMode:TPersistentMode read Get_FPersistentMode write Set_FPersistentMode;
    property LockOwner:Integer Read Get_LockOwner;
    function Get_LockListTimeOut:Integer;
    procedure Set_LockListTimeOut(Value:Integer);
    property LockListTimeOut:Integer read Get_LockListTimeOut write Set_LockListTimeOut;
    function Get_RecursionDepth:Integer;
    procedure Set_RecursionDepth(Value:Integer);
    property RecursionDepth:Integer read Get_RecursionDepth write Set_RecursionDepth;
    function Get_CheckForTriggers:Boolean;
    procedure Set_CheckForTriggers(Value:Boolean);
    property CheckForTriggers:Boolean read Get_CheckForTriggers write Set_CheckForTriggers;
  End;


implementation

end.
