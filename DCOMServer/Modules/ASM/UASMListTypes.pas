unit UASMListTypes;

interface
  Uses UVarsetTypes;
Type
  IASMList=Interface
  ['{4B900F89-243D-4218-BBC1-65D0EF9AC02B}']
    function IT_GetList:IVarset;
    Function ITASMAdd(aObject:TObject):IVarsetDataView;
    Function ITASMDelOfAddr(aObject:TObject):Boolean;
    Function ITASMDelOfIntIndex(aIntIndex:Integer):Boolean;
    Function ITASMDisconnectAll:Integer;
    Property ITList:IVarset read IT_GetList;
  End;

implementation

end.
