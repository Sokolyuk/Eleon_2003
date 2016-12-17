unit UEMailMessageTypes;

interface
  Uses UVarsetTypes;

Type
  IEMailMessage=Interface
  ['{66BC591A-AE31-429D-B879-BAB01C9BC7F7}']
    Function Get_Subject:AnsiString;
    Procedure Set_Subject(Value:AnsiString);
    Function Get_Addresses:AnsiString;
    Procedure Set_Addresses(Value:AnsiString);
    Function Get_From:AnsiString;
    Procedure Set_From(Value:AnsiString);
    Function Get_Body:AnsiString;
    Procedure Set_Body(Value:AnsiString);
    Function Get_Attachments:IVarset;
    Function Get_DataV:Variant;
    Procedure Set_DataV(Value:Variant);
    Function Get_CacheDir:AnsiString;
    Procedure Set_CacheDir(Value:AnsiString);
    //..
    Property Subject:AnsiString read Get_Subject write Set_Subject;
    Property Addresses:AnsiString read Get_Addresses write Set_Addresses;
    Property From:AnsiString read Get_From write Set_From;
    Property Body:AnsiString read Get_Body write Set_Body;
    Property Attachments:IVarset read Get_Attachments;
    Property DataV:Variant read Get_DataV write Set_DataV;
    Property CacheDir:AnsiString read Get_CacheDir write Set_CacheDir;
  End;


implementation

end.
