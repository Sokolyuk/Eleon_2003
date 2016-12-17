//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit USyncTypes;

interface
  uses UCallerTypes;
//const
//  IID_ISync:TGUID='{F22BC943-FC34-4CBD-A6FC-D17F03B3A2F4}';
type
  TLockOption=(lopMessAdd, lopNoChangeOptionsAtRelock, lopNoChangeLifeTimeAtRelock, lopNoChangeCallerActionAtRelock);//lopCaseSensitive
  TLockOptions=set of TLockOption;
  PLockInfo=^TLockInfo;
  //Add - добавить один лок('ssTable')
  //Free - удалить один лок('ssTable') result - LockCount. 1..n-лок еще установлен, 0-разобрал свой лок, -1-не нашел лок, -2-чужой лок
  //SetLocks - добавить несколько локов('ssTable;ssTab1;ssTab2') !+/- не пишется
  //FreeLocks - удалить несколько локов('ssTable;ssTab1;ssTab2') !+/- не пишется
  //SetLockList - добавить/удалить список локов, используя префикс +/-('+ssTable;-ssTab1')
  //Clear - удалить локи все локи(по признаку).
  //Exists - проверить существует ли лок(по признаку)
  ISync=interface
  ['{F22BC943-FC34-4CBD-A6FC-D17F03B3A2F4}']
    function ITGenerateLockOwner:Integer;
    function ITSetIntLock(aIntLock:Integer; aLockOwner:Integer; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aPLockInfo:PLockInfo{=Nil}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;
    function ITSetIntLockWait(aIntLock:Integer; aLockOwner:Integer; aWait:Cardinal; aCallerAction:ICallerAction{=nil}; aLifeTime:TDateTime{=0}; aPLockInfo:PLockInfo{=Nil}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;
    function ITFreeIntLock(aIntLock:Integer; aLockOwner:Integer):integer;
    function ITClearIntLockOwner(aLockOwner:Integer):Integer{count};
    function ITSetStrLock(Const aStrLock:AnsiString; aLockOwner:Integer; aCallerAction:ICallerAction{=nil}; aLifeTime:TDateTime{=0}; aPLockInfo:PLockInfo{=nil}; aRaise:Boolean{=true}; aOptions:TLockOptions{=[]}):Boolean;
    function ITSetStrLockWait(Const aStrLock:AnsiString; aLockOwner:Integer; aWait:Cardinal; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aPLockInfo:PLockInfo{=Nil}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;
    function ITSetStrLockList(Const aStrLockList:AnsiString; aLockOwner:Integer; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;
    function ITSetStrLockListWait(Const aStrLockList:AnsiString; aLockOwner:Integer; aWait:Cardinal; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;
    function ITSetStrLocks(Const aStrLocks:AnsiString; aLockOwner:Integer; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;
    function ITSetStrLocksWait(Const aStrLocks:AnsiString; aLockOwner:Integer; aWait:Cardinal; aCallerAction:ICallerAction{=Nil}; aLifeTime:TDateTime{=0}; aRaise:Boolean{=True}; aOptions:TLockOptions{=[]}):Boolean;
    function ITClearStrLocks(Const aStrLocks:AnsiString; aLockOwner:Integer):Boolean;
    function ITStrLockSubExists(Const aStrLockSub:AnsiString; aPLockInfo:PLockInfo{=Nil}):Boolean;
    function ITStrLockExists(Const aStrLock:AnsiString; aPLockInfo:PLockInfo{=Nil}):Boolean;
    function ITFreeStrLock(Const aStrLock:AnsiString; aLockOwner:Integer):integer;
    function ITClearStrLockOwner(aLockOwner:Integer):Integer{count};
    function ITClearLockOwner(aLockOwner:Integer):Integer{count};
    function ITClearLock:Integer{count};
    //..
    function ITSetLockList(const aLockList{, aUser}:AnsiString; aCallerAction:ICallerAction; aLockOwner:Integer; aRaise:Boolean; aMessAdd:boolean{=true}):Boolean;
    function ITSetLockListWait(const aLockList{, aUser}:AnsiString; aCallerAction:ICallerAction; aLockOwner:Integer; aRaise:Boolean; aTimeout:Integer; aMessAdd:boolean{=true}):Boolean;
    function ITSetLock(const aLock{, aUser}:AnsiString; aCallerAction:ICallerAction; aLockOwner:Integer; aRaise:Boolean; aMessAdd:boolean{=true}):Boolean;
    function ITFreeLock(const aLock:AnsiString; aLockOwner:Integer):integer;
    function ITSetLockWait(const aLock{, aUser}:AnsiString; aCallerAction:ICallerAction; aLockOwner:Integer; aRaise:Boolean; aTimeout:Integer; aMessAdd:boolean{=true}):Boolean;
    function ITGetLockList:Variant;
  end;
  PLockRec=^TLockRec;
  TLockRec=Record
    Next:PLockRec;
    LockOwner:Integer;
    LockCount:Integer;
    IntLock:Integer;
    StrLock:AnsiString;
    CreateTime:TDateTime;
    LifeTime:TDateTime;
    CallerAction:ICallerAction;
    Options:TLockOptions;
  end;
  TLockInfo=Record
    LockOwner:Integer;
    LockCount:Integer;
    IntLock:Integer;
    StrLock:AnsiString;
    CreateTime:TDateTime;
    LifeTime:TDateTime;
    CallerAction:ICallerAction;
    Options:TLockOptions;
  end;
implementation

end.
