//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UPackMessageTypes;

interface
  uses UVarsetTypes, UPackTypes, UPackPDTypes;
type
  TPriority=(prtExtreme{0}, prtHigh{1}, prtNormal{2}, prtLow{3});
  TMsgType=(mstSystem{0}, mstAdministrative{1}, mstUser{2});

  IPackMessage=interface(IPack)
  ['{10B8452B-B904-4CDC-A4FF-CA664A725DD3}']
    function Get_Priority:TPriority;
    procedure Set_Priority(Value:TPriority);
    function Get_MsgType:TMsgType;
    procedure Set_MsgType(Value:TMsgType);
    function Get_Subject:AnsiString;
    procedure Set_Subject(const Value:AnsiString);
    function Get_Msg:AnsiString;
    procedure Set_Msg(const Value:AnsiString);
    function Get_Attachments:IVarset;
    function Get_AsVariant:Variant;
    procedure Set_AsVariant(const Value:Variant);
    function Get_DateCreate:TDateTime;
    function Get_AsVariantSysMsg:Variant;
    procedure Set_AsVariantSysMsg(const Value:Variant);
    function Get_Sender:AnsiString;
    function Get_Receiver:AnsiString;
    function ClonePackMessage:IPackMessage;
    //..
    property Sender:AnsiString read Get_Sender;
    property Receiver:AnsiString read Get_Receiver;
    property Priority:TPriority read Get_Priority write Set_Priority;
    property MsgType:TMsgType read Get_MsgType write Set_MsgType;
    property Subject:AnsiString read Get_Subject write Set_Subject;
    property Msg:AnsiString read Get_Msg write Set_Msg;
    property Attachments:IVarset read Get_Attachments;
    property AsVariantSysMsg:Variant read Get_AsVariantSysMsg write Set_AsVariantSysMsg;
    property DateCreate:TDateTime read Get_DateCreate;
  end;

  IReceivePackMessage=interface
  ['{6E51D53C-3721-4EDA-9BD2-5FA8A885E3A2}']
    function ReceivePackMessage(aUserData:Pointer; aPackPD:IPackPD; aPackMessage:IPackMessage):boolean{worked};
  end;
  //TReceivePackMessageEvent=function(aUserData:Pointer; aPackPD:IPackPD; aPackMessage:IPackMessage):Boolean{worked} of object;
implementation

end.
