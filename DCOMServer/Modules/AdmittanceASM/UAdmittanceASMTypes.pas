unit UAdmittanceASMTypes;

interface
type
  IAdmittanceASM=interface
  ['{E03974D7-11AC-4682-A870-C9CE9B835393}']
    function StopAllASMServers:Integer;                              //остановить все ASM в списке (в ASM.destroy вызываетс€ функци€ GLAdmittanceASM_ListASMDel(Self))
    function StopASMServerOnID(iIDASM:Integer):Integer;              //остановить ASM с указанным ID
    function StopASMServerOnUser(const stUserASM:AnsiString):Integer;      //остановить все ASM, которые принадлежат указанному User'у.
    //ƒоступ к списку ASM серверов
    procedure ListAdd(const aData:Variant);                                     //добавить в список
    function ListDel(aaPntr:Pointer; aaHeedingLock:Boolean):boolean;      //удалить из списка
    function ListUpdate(aaASMNum:Integer; const NewData:Variant):Boolean;
    function CountOfListASM:Integer;                                      //количество серверов в списке
    function GetAddrNextASMAndLock(aAddr:Pointer):Pointer;      //на входе адрес текущего ASM на выходе адрес следующего ASM (дл€ получени€ адреса первого ASM на вход Nil).
    function GetAddrPrevASMAndLock(aAddr:Pointer):Pointer;      //јналогично GLAdmittanceASM_GetAddrNextASM, но только с конца.
    function GetPntrOnIdAndLock(aASMSenderNum:Integer):Pointer;
    function GetPntrOnIdAndNoLock(aASMSenderNum:Integer):Pointer;
    function GetInfoNextASMAndLock(aAddr:Pointer):Variant;      //на входе адрес текущего ASM на выходе адрес следующего ASM (дл€ получени€ адреса первого ASM на вход Nil).
    function GetInfoPrevASMAndLock(aAddr:Pointer):Variant;      //јналогично GLAdmittanceASM_GetAddrNextASM, но только с конца.
    function GetInfoNextASMAndNoLock(aAddr:Pointer):Variant;
    function GetInfoPrevASMAndNoLock(aAddr:Pointer):Variant;
    function GetInfoASMOnPntrAndNoLock(aAddr:Pointer):Variant;
    function GetInfoASMOnPntrAndLock(aAddr:Pointer):Variant;
    function GetInfoASMOnIdAndNoLock(aaASMNum:Integer):Variant;
    function GetInfoASMOnIdAndLock(aaASMNum:Integer):Variant;
    //Hide/Show ASM
    function Hide(aASMNum:Integer):Boolean;
    function Show(aASMNum:Integer):Boolean;
    //Lock/UnLock ASM
    function Lock(aASMNum:Integer):Integer;overload;
    function Lock(aPntr:Pointer):Integer;overload;
    function UnLock(aASMNum:Integer):Integer;overload;
    function UnLock(aPntr:Pointer):Integer;overload;
    function LockCount(aPntr:Pointer):Integer;overload;
    function LockCount(aASMNum:Integer):Integer;overload;
    //Admittance-info
    procedure ITGetASMServers(out aASMServers, aExtDataASMServers:Variant);
  end;


implementation

end.
