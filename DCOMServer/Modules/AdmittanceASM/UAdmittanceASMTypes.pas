unit UAdmittanceASMTypes;

interface
type
  IAdmittanceASM=interface
  ['{E03974D7-11AC-4682-A870-C9CE9B835393}']
    function StopAllASMServers:Integer;                              //���������� ��� ASM � ������ (� ASM.destroy ���������� ������� GLAdmittanceASM_ListASMDel(Self))
    function StopASMServerOnID(iIDASM:Integer):Integer;              //���������� ASM � ��������� ID
    function StopASMServerOnUser(const stUserASM:AnsiString):Integer;      //���������� ��� ASM, ������� ����������� ���������� User'�.
    //������ � ������ ASM ��������
    procedure ListAdd(const aData:Variant);                                     //�������� � ������
    function ListDel(aaPntr:Pointer; aaHeedingLock:Boolean):boolean;      //������� �� ������
    function ListUpdate(aaASMNum:Integer; const NewData:Variant):Boolean;
    function CountOfListASM:Integer;                                      //���������� �������� � ������
    function GetAddrNextASMAndLock(aAddr:Pointer):Pointer;      //�� ����� ����� �������� ASM �� ������ ����� ���������� ASM (��� ��������� ������ ������� ASM �� ���� Nil).
    function GetAddrPrevASMAndLock(aAddr:Pointer):Pointer;      //���������� GLAdmittanceASM_GetAddrNextASM, �� ������ � �����.
    function GetPntrOnIdAndLock(aASMSenderNum:Integer):Pointer;
    function GetPntrOnIdAndNoLock(aASMSenderNum:Integer):Pointer;
    function GetInfoNextASMAndLock(aAddr:Pointer):Variant;      //�� ����� ����� �������� ASM �� ������ ����� ���������� ASM (��� ��������� ������ ������� ASM �� ���� Nil).
    function GetInfoPrevASMAndLock(aAddr:Pointer):Variant;      //���������� GLAdmittanceASM_GetAddrNextASM, �� ������ � �����.
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
