unit UEClientInfoTypes;

interface
Type
  IEClientInfo=Interface
  ['{F38901EB-5DBE-4584-9B9D-9882EAC6B81A}']
    Function IT_GetThis:Boolean;
    Procedure IT_SetThis(Value:Boolean);
    Function IT_GetStartTime:TDateTime;
    Procedure IT_SetStartTime(Value:TDateTime);
    Function IT_GetID:Integer;
    Procedure IT_SetID(Value:Integer);
    Function IT_GetUser:AnsiString;
    Procedure IT_SetUser(Value:AnsiString);
    Function IT_GetLoginType:Integer;
    Procedure IT_SetLoginType(Value:Integer);
    Function IT_GetEvent:boolean;
    Procedure IT_SetEvent(Value:boolean);
    Function IT_GetEClientV:Variant;
    Procedure IT_SetEClientV(Value:Variant);
    //..
    Property ITThis:Boolean read IT_GetThis write IT_SetThis;
    Property ITStartTime:TDateTime read IT_GetStartTime write IT_SetStartTime;
    Property ITID:Integer read IT_GetID write IT_SetID;
    Property ITUser:AnsiString read IT_GetUser write IT_SetUser;
    Property ITLoginType:Integer read IT_GetLoginType write IT_SetLoginType;
    Property ITEvent:Boolean read IT_GetEvent write IT_SetEvent;
    Property ITEClientV:Variant read IT_GetEClientV write IT_SetEClientV;
  end;
implementation

end.
