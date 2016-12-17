//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UEMailAttachmentTypes;

interface
Type
  TAttachmentType=Integer;
Const
  attInvalid:TAttachmentType=0;
  attFile:TAttachmentType=1;
  attFileName:TAttachmentType=2;
Type
  IEMailAttachment=Interface
  ['{04581866-87B1-41A3-84EA-F87B98C3ABEE}']
    Function Get_AttachmentType:TAttachmentType;
    Function Get_FileName:AnsiString;
    Function Get_AsVariant:Variant;
    Procedure Set_AsVariant(Const Value:Variant);
    Procedure SetAttachmentFile(Const aFileName:AnsiString);
    Procedure SetAttachmentFileName(Const aFileName:AnsiString);
    //Function Get_CacheDir:AnsiString;
    //Procedure Set_CacheDir(Const Value:AnsiString);
    Property AttachmentType:TAttachmentType read Get_AttachmentType;
    Property FileName:AnsiString read Get_FileName;
    Property AsVariant:Variant read Get_AsVariant write Set_AsVariant;
    //Property CacheDir:AnsiString read Get_CacheDir write Set_CacheDir;
  End;

implementation

end.
