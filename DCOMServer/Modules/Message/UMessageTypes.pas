unit UMessageTypes;

interface
  Uses UVarsetTypes;
Type
  TPriority=(prtExtreme{0}, prtHigh{1}, prtNormal{2}, prtLow{3});
  TMsgType=(mstSystem{0}, mstAdministrative{1}, mstUser{2});

  IKSMessage=Interface
  ['{66BC591A-AE31-429D-B879-BAB01C9BC7F7}']
    Function Get_Priority:TPriority;
    Procedure Set_Priority(Value:TPriority);
    Function Get_MsgType:TMsgType;
    Procedure Set_MsgType(Value:TMsgType);
    Function Get_Subject:AnsiString;
    Procedure Set_Subject(Value:AnsiString);
    Function Get_Receiver:AnsiString;
    Procedure Set_Receiver(Value:AnsiString);
    Function Get_Sender:AnsiString;
    Procedure Set_Sender(Value:AnsiString);
    Function Get_Msg:AnsiString;
    Procedure Set_Msg(Value:AnsiString);
    Function Get_Attachments:IVarset;
    Function Get_DataV:Variant;
    Procedure Set_DataV(Value:Variant);
    //..
    Property Priority:TPriority read Get_Priority write Set_Priority;
    Property MsgType:TMsgType read Get_MsgType write Set_MsgType;
    Property Subject:AnsiString read Get_Subject write Set_Subject;
    Property Receiver:AnsiString read Get_Receiver write Set_Receiver;
    Property Sender:AnsiString read Get_Sender write Set_Sender;
    Property Msg:AnsiString read Get_Msg write Set_Msg;
    Property Attachments:IVarset read Get_Attachments;
    Property DataV:Variant read Get_DataV write Set_DataV;
  End;


implementation

end.
