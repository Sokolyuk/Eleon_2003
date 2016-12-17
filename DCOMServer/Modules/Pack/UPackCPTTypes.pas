//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UPackCPTTypes;

interface
  Uses UPackCPTasksTypes, UPackTypes;

Type
  TCPTOption={Integer}(ctoReturnParamsIfError, ctoReserver2, ctoReserver3, ctoReserver4, ctoReserver5, ctoReserver6, ctoReserver7, ctoReserver8, ctoReserver9, ctoReserver10,
              ctoReserver11, ctoReserver12, ctoReserver13, ctoReserver14, ctoReserver15, ctoReserver16, ctoReserver17,
              ctoReserver18, ctoReserver19, ctoReserver20, ctoReserver21, ctoReserver22, ctoReserver23, ctoReserver24,
              ctoReserver25, ctoReserver26, ctoReserver27, ctoReserver28, ctoReserver29, ctoReserver30, ctoReserver31, ctoReserver32);

  TCPTOptions=Set of TCPTOption;

  IPackCPT=Interface(IPack)
  ['{DC82E4E6-8B7E-44F6-AAA2-E728259832E9}']
    function Get_CPTOptions:TCPTOptions;
    procedure Set_CPTOptions(Value:TCPTOptions);
    function Get_CPID:Variant;
    procedure Set_CPID(Const Value:Variant);
    function Get_CPTasks:IPackCPTasks;
    procedure Set_CPTasks(Value:IPackCPTasks);
    function ClonePackCPT:IPackCPT;
    property CPTOptions:TCPTOptions read Get_CPTOptions write Set_CPTOptions;
    property CPID:Variant read Get_CPID write Set_CPID;
    property CPTasks:IPackCPTasks read Get_CPTasks write Set_CPTasks;
  end;

implementation

end.
