unit UPackCPRTypes;

interface
  uses UPackCPTasksTypes, UPackCPErrorsTypes, UPackTypes, UADMTypes;
type
  TCPROption={Integer}(croReserver1, croReserver2, croReserver3, croReserver4, croReserver5, croReserver6, croReserver7, croReserver8, croReserver9, croReserver10,
              croReserver11, croReserver12, croReserver13, croReserver14, croReserver15, croReserver16, croReserver17,
              croReserver18, croReserver19, croReserver20, croReserver21, croReserver22, croReserver23, croReserver24,
              croReserver25, croReserver26, croReserver27, croReserver28, croReserver29, croReserver30, croReserver31, croReserver32);

  TCPROptions=Set of TCPROption;

  IPackCPR=Interface(IPack)
  ['{7614476A-1C05-4C4B-9A3F-E94E9F0CD0AD}']
    function Get_CPROptions:TCPROptions;
    procedure Set_CPROptions(Value:TCPROptions);
    function Get_CPID:Variant;
    procedure Set_CPID(Const Value:Variant);
    function Get_CPTasks:IPackCPTasks;
    procedure Set_CPTasks(Value:IPackCPTasks);
    function Get_CPErrors:IPackCPErrors;
    procedure Set_CPErrors(Value:IPackCPErrors);
    function ClonePackCPR:IPackCPR;
    property CPROptions:TCPROptions read Get_CPROptions write Set_CPROptions;
    property CPID:Variant read Get_CPID write Set_CPID;
    property CPTasks:IPackCPTasks read Get_CPTasks write Set_CPTasks;
    property CPErrors:IPackCPErrors read Get_CPErrors write Set_CPErrors;
    procedure Add(aADMTask:TADMTask; Const aParam:Variant; Const aRouteParam:Variant; aBlockID:Integer{=-1});
    procedure AddWithError(aADMTask:TADMTask; Const aParam:Variant; Const aRouteParam:Variant; aBlockId:Integer; Const aMessage:AnsiString; aHelpContext:Integer{=0});
  End;

implementation

end.
