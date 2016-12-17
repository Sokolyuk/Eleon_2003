unit UEServersListTypes;

interface
  Uses UVarsetTypes, UEServerInfoTypes;
Type
  IEServersList=Interface
  ['{9C88C1EB-E3A9-4348-B6FB-2DECE8AD595F}']
    function IT_GetList:IVarset;
    function IT_GetListV:Variant;
    Procedure IT_SetListV(Value:Variant);
    //..
    Function ITListAdd(Value:IEServerInfo):IVarsetDataView;
    Function ITEServerOfRegName(Const aRegName:AnsiString):IEServerInfo;
    Function ITEServerOfRegNameV(Const aRegName:AnsiString):Variant;
    Property ITList:IVarset read IT_GetList;
    Property ITListV:Variant read IT_GetListV write IT_SetListV;
  end;
implementation

end.
