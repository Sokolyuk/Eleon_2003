unit UProcessesListTypes;

interface
  uses UVarsetTypes, UProcessInfoTypes;
Type
  IProcessesList=Interface
  ['{B972EA2C-4D1C-4FDA-A681-580DF5371E44}']
    Function IT_GetList:IVarset;
    //..
    Function ITRefresh:Integer;
    Property ITList:IVarset read IT_GetList;
  end;

implementation

end.
