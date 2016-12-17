unit UEClientsInfoTypes;

interface
  Uses UVarsetTypes, UEClientInfoTypes;
Type
  IEClientsInfo=Interface
  ['{696F2B46-5D94-4EA6-832A-139BC8DFAFB1}']
    Function IT_GetAppStartTime:TDateTime;
    Procedure IT_SetAppStartTime(Value:TDateTime);
    Function IT_GetObjectCount:Integer;
    Procedure IT_SetObjectCount(Value:Integer);
    Function IT_GetStartsAmount:Integer;
    Procedure IT_SetStartsAmount(Value:Integer);
    Function IT_GetEClientsV:Variant;
    Procedure IT_SetEClientsV(Value:Variant);
    Function IT_GetClients:IVarset;
    //..
    Function ITEClientAdd(aEClientInfo:IEClientInfo):IVarsetDataView;
    Function ITEClientAddV(aEClientInfo:Variant):IVarsetDataView;
    Property ITAppStartTime:TDateTime read IT_GetAppStartTime write IT_SetAppStartTime;
    Property ITObjectCount:Integer read IT_GetObjectCount write IT_SetObjectCount;
    Property ITStartsAmount:Integer read IT_GetStartsAmount write IT_SetStartsAmount;
    Property ITClients:IVarset read IT_GetClients;
    Property ITEClientsV:Variant read IT_GetEClientsV write IT_SetEClientsV;
  End;

implementation

end.
