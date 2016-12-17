unit UEServerInfoTypes;

interface
  Uses Classes, UEClientsInfoTypes, UVarsetTypes, UProcessInfoTypes;
Type
  TEServerState=Integer;
Const
  essStarted:TEServerState=1;
  essTerminated:TEServerState=2;
  {-1-unknown; 0-Wait for respond; 1-started; 2-Terminated}
Type
  IEServerInfo=Interface
  ['{3BA553CE-1BE1-454F-8E78-2C4DB81AA4E5}']
    Function IT_GetRegName:AnsiString;
    Procedure IT_SetRegName(Value:AnsiString);
    Function IT_GetGUID:AnsiString;
    Procedure IT_SetGUID(Value:AnsiString);
    Function IT_GetType:Integer;
    Procedure IT_SetType(Value:Integer);
    Function IT_GetPIDList:IVarset;
    Function IT_GetPIDStarted:Cardinal;
    Function IT_GetValid:Boolean;
    Procedure IT_SetValid(Value:Boolean);
    Function IT_GetClients:IEClientsInfo;
    Function IT_GetEServerV:Variant;
    Procedure IT_SetEServerV(Value:Variant);
    Function IT_GetPathEXE:AnsiString;
    Procedure IT_SetPathEXE(Value:AnsiString);
    Function IT_GetMasterGUID:AnsiString;
    Procedure IT_SetMasterGUID(Value:AnsiString);
    function IT_GetAutorestartCritical:Cardinal;
    Procedure IT_SetAutorestartCritical(Value:Cardinal);
    function IT_GetAutorestartNormal:Cardinal;
    Procedure IT_SetAutorestartNormal(Value:Cardinal);
    Function IT_GetStarted:Boolean;
    function IT_GetAutoKeepStarted:Boolean;
    Procedure IT_SetAutoKeepStarted(Value:Boolean);
    Function IT_GetProcessInfo:IProcessInfo;
    Function IT_GetAutorestartMessage:AnsiString;
    Procedure IT_SetAutorestartMessage(Value:AnsiString);
    //..
    Procedure IT_SetAutorestartNornalPeriod(Value:AnsiString);
    Function IT_GetAutorestartNornalPeriod:Variant;
    Function ITPIDUpdate(aPID:Cardinal; aEServerState:TEServerState):IVarsetDataView;
    Procedure ITPIDDelete(aPID:Cardinal);
    Property ITRegName:AnsiString read IT_GetRegName write IT_SetRegName;
    Property ITGUID:AnsiString read IT_GetGUID write IT_SetGUID;
    Property ITPathEXE:AnsiString read IT_GetPathEXE write IT_SetPathEXE;
    Property ITMasterGUID:AnsiString read IT_GetMasterGUID write IT_SetMasterGUID;
    Property ITType:Integer read IT_GetType write IT_SetType;
    Property ITPIDList:IVarset read IT_GetPIDList;
    Property ITPIDStarted:Cardinal read IT_GetPIDStarted;
    Property ITStarted:Boolean read IT_GetStarted;
    Property ITValid:Boolean read IT_GetValid write IT_SetValid;
    Property ITAutorestartCritical:Cardinal read IT_GetAutorestartCritical write IT_SetAutorestartCritical;
    Property ITAutorestartNormal:Cardinal read IT_GetAutorestartNormal write IT_SetAutorestartNormal;
    Property ITAutorestartMessage:AnsiString read IT_GetAutorestartMessage write IT_SetAutorestartMessage;
    Property ITAutoKeepStarted:Boolean read IT_GetAutoKeepStarted write IT_SetAutoKeepStarted;
    Property ITProcessInfo:IProcessInfo read IT_GetProcessInfo;
    Property ITClients:IEClientsInfo read IT_GetClients;
    Property ITEServerV:Variant read IT_GetEServerV write IT_SetEServerV;
  End;

implementation

end.
