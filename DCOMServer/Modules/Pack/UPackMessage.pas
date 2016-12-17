//Copyright © 2000-2004 by Dmitry A. Sokolyuk
unit UPackMessage;

interface
  Uses UPack, UPackMessageTypes, UVarsetTypes, UPackTypes;
Type
  // ----------------------
  // Version 0
  // ----------------------
  //  0-From
  //  1-Message
  // ----------------------
  // Version 1
  // ----------------------
  //  0-ID
  //  1-Ver
  //  2-Message
  //  3-Subject
  //  4-Priority
  //  5-MsgType
  //  6-Attachments
  //  7-DateCreate  
  TPackMessage=class(TPack, IPackMessage)
  private
    FPriority:TPriority;
    FMsgType:TMsgType;
    FSubject:AnsiString;
    FMsg:AnsiString;
    FAttachments:IVarset;
    FDateCreate:TDateTime;
    FSenderForSysMsg:AnsiString;
  protected
    function Get_PackID:TPackID;override;
    function Get_AsVariant:Variant;override;
    procedure Set_AsVariant(const Value:Variant);override;
    function Get_HighBound:Integer;override;
    function Get_Priority:TPriority;
    procedure Set_Priority(Value:TPriority);
    function Get_MsgType:TMsgType;
    procedure Set_MsgType(Value:TMsgType);
    function Get_Subject:AnsiString;
    procedure Set_Subject(const Value:AnsiString);
    function Get_Msg:AnsiString;
    procedure Set_Msg(const Value:AnsiString);
    function Get_Attachments:IVarset;
    function Get_DateCreate:TDateTime;
    function Get_AsVariantSysMsg:Variant;
    procedure Set_AsVariantSysMsg(const Value:Variant);
    function Get_Sender:AnsiString;
    function Get_Receiver:AnsiString;
    function ValidVersion(aVersion:Integer):Boolean;override;
    function InternalCreateClone:IPack;override;
  public
    constructor Create;
    destructor Destroy;override;
    procedure Clear;override;
    function Clone:IPack;override;
    function ClonePackMessage:IPackMessage;virtual;
    property Priority:TPriority read Get_Priority write Set_Priority;
    property MsgType:TMsgType read Get_MsgType write Set_MsgType;
    property Subject:AnsiString read Get_Subject write Set_Subject;
    property Msg:AnsiString read Get_Msg write Set_Msg;
    property Attachments:IVarset read Get_Attachments;
    property DateCreate:TDateTime read Get_DateCreate;
    property AsVariantSysMsg:Variant read Get_AsVariantSysMsg write Set_AsVariantSysMsg;
    property Sender:AnsiString read Get_Sender;
    property Receiver:AnsiString read Get_Receiver;
  end;


implementation
  uses SysUtils, UVarset, UPackConsts, UEMailAttachmentTypes, UEMailAttachment, UErrorConsts, UPackPDTypes
       {$IFNDEF VER130}, Variants{$ENDIF}{$IFDEF VER130}, Windows, FileCtrl{$ENDIF};
{$IFDEF VER130}
  type TVarType=Integer;
{$ENDIF}
constructor TPackMessage.Create;
begin
  FAttachments:=TVarset.Create;
  FAttachments.ITConfigIntIndexAssignable:=False;
  FAttachments.ITConfigCheckUniqueIntIndex:=False;
  FAttachments.ITConfigCheckUniqueStrIndex:=False;
  FAttachments.ITConfigNoFoundException:=True;
  FAttachments.ITConfigCaseSensitive:=False;
  Inherited Create;
  Set_PackVer(1);
end;

destructor TPackMessage.Destroy;
begin
  FAttachments:=nil;
  FSubject:='';
  FMsg:='';
  FSenderForSysMsg:='';
  Inherited Destroy;
end;

procedure TPackMessage.Clear;
begin
  inherited Clear;
  FPriority:=prtNormal;
  FMsgType:=mstUser;
  FSubject:='';
  FMsg:='';
  FSenderForSysMsg:='';
  FDateCreate:=0;
  if Assigned(FAttachments) then FAttachments.ITClear;
end;

function TPackMessage.Get_Priority:TPriority;
begin
  Result:=FPriority;
end;

procedure TPackMessage.Set_Priority(Value:TPriority);
begin
  FPriority:=Value;
end;

function TPackMessage.Get_MsgType:TMsgType;
begin
  Result:=FMsgType;
end;

procedure TPackMessage.Set_MsgType(Value:TMsgType);
begin
  FMsgType:=Value;
end;

function TPackMessage.Get_Subject:AnsiString;
begin
  Result:=FSubject;
end;

procedure TPackMessage.Set_Subject(const Value:AnsiString);
begin
  FSubject:=Value;
end;

function TPackMessage.Get_Msg:AnsiString;
begin
  Result:=FMsg;
end;

procedure TPackMessage.Set_Msg(const Value:AnsiString);
begin
  FMsg:=Value;
end;

function TPackMessage.Get_Attachments:IVarset;
begin
  Result:=FAttachments;
end;

function TPackMessage.Get_HighBound:Integer;
begin
  Result:=Protocols_Message_Count-1;
end;

function TPackMessage.Get_AsVariant:Variant;
  Var tmpV:Variant;
      tmpivHB, tmpIntIndex:Integer;
      tmpIEMailAttachment:IEMailAttachment;
      tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
begin
  Result:=Inherited Get_AsVariant;
  tmpV:=Unassigned;
  tmpivHB:=-1;
  tmpIEMailAttachment:=nil;
  tmpIntIndex:=-1;
  while true do begin
    tmpIVarsetDataView:=FAttachments.ITViewNextGetOfIntIndex(tmpIntIndex);
    if tmpIntIndex=-1 then break;
    tmpIUnknown:=tmpIVarsetDataView.ITData;
    if (not Assigned(tmpIUnknown))Or(tmpIUnknown.QueryInterface(IEMailAttachment, tmpIEMailAttachment)<>S_OK)Or(not Assigned(tmpIEMailAttachment)) then raise exception.create('¬нутренн€€ ошибка: QueryInterface: IEMailAttachment not found. ќбратитесь к разработчику.');
    if tmpivHB<0 then begin
      tmpV:=VarArrayCreate([0, 0], varVariant);
      tmpivHB:=0;
    end else begin
      VarArrayRedim(tmpV, tmpivHB+1);
      Inc(tmpivHB);
    end;
    tmpV[tmpivHB]:=tmpIEMailAttachment.AsVariant;
  end;
  tmpIVarsetDataView:=nil;
  tmpIEMailAttachment:=nil;
  tmpIUnknown:=nil;
  //..
  Result[Protocols_Message_Message]:=FMsg;
  Result[Protocols_Message_Subject]:=FSubject;
  Result[Protocols_Message_Priority]:=FPriority;
  Result[Protocols_Message_MsgType]:=FMsgType;
  Result[Protocols_Message_Attachments]:=tmpV;
  Result[Protocols_Message_DateCreate]:=FDateCreate;
  VarClear(tmpV);
end;

procedure TPackMessage.Set_AsVariant(const Value:Variant);
  Var tmpI:Integer;
      tmpIEMailAttachment:IEMailAttachment;
      tmpVarType:TVarType;
begin
  try
    Clear;
    Inherited Set_AsVariant(Value);
    if PackVer<>1 then raise exception.create('Unknown version('+IntToStr(PackVer)+').');
    // 0-ID
    // 1-Ver
    // 2-Message
    // 3-Subject
    // 4-Priority
    // 5-MsgType
    // 6-Attachments
    // 7-DateCreate
    tmpVarType:=VarType(Value[Protocols_Message_Message]);
    if (tmpVarType<>varOleStr)and(tmpVarType<>varString) then raise exception.create('Invalid VarType(V[2])='+IntToStr(Integer(tmpVarType))+'.');
    tmpVarType:=VarType(Value[Protocols_Message_Subject]);
    if (tmpVarType<>varOleStr)and(tmpVarType<>varString) then raise exception.create('Invalid VarType(V[3]).='+IntToStr(Integer(tmpVarType))+'.');
    if VarType(Value[Protocols_Message_Priority])<>varInteger then raise exception.create('Invalid VarType(V[4]).');
    if VarType(Value[Protocols_Message_MsgType])<>varInteger then raise exception.create('Invalid VarType(V[5]).');
    if (not VarIsEmpty(Value[Protocols_Message_Attachments]))and(not VarIsArray(Value[Protocols_Message_Attachments])) then raise exception.create('Invalid VarType for attachment[6].');
    if VarType(Value[Protocols_Message_DateCreate])<>varDate then raise exception.create('Invalid VarType(V[7]).');
    //..
    FMsg:=Value[Protocols_Message_Message];
    FSubject:=Value[Protocols_Message_Subject];
    FPriority:=TPriority(Value[Protocols_Message_Priority]);
    FMsgType:=TMsgType(Value[Protocols_Message_MsgType]);
    FDateCreate:=Value[Protocols_Message_DateCreate];
    //..
    if VarIsArray(Value[Protocols_Message_Attachments]) then begin
      For tmpI:=0 to VarArrayHighBound(Value[Protocols_Message_Attachments], 1) do begin
        tmpIEMailAttachment:=TEMailAttachment.Create;
        //tmpIEMailAttachment.CacheDir:=FCacheDir;
        tmpIEMailAttachment.AsVariant:=Value[Protocols_Message_Attachments][tmpI];
        FAttachments.ITPushV(tmpIEMailAttachment);
        tmpIEMailAttachment:=nil;
      end;
    end;
  except on e:exception do begin
    Clear;
    e.message:='Set_AsVariant: '+e.message;
    raise;
  end;end;
end;

function TPackMessage.Get_AsVariantSysMsg:Variant;
begin
  // 0-From
  // 1-Message
  Result:=VarArrayOf(['', FMsg]);
end;

procedure TPackMessage.Set_AsVariantSysMsg(const Value:Variant);
  var tmpVarType:TVarType;
begin
  try
    // 0-From
    // 1-Message
    Clear;
    if not VarIsArray(Value) then raise exception.createFmt(cserInternalError, ['Value is not array.']);
    tmpVarType:=VarType(Value[0]);
    if (tmpVarType<>varOleStr)and(tmpVarType<>varString) then raise exception.create('Invalid VarType(V[0]).='+IntToStr(Integer(tmpVarType))+'.');
    tmpVarType:=VarType(Value[1]);
    if (tmpVarType<>varOleStr)and(tmpVarType<>varString) then raise exception.create('Invalid VarType(V[1]).='+IntToStr(Integer(tmpVarType))+'.');
    FMsg:=Value[1];
    FSenderForSysMsg:=Value[0];
  except on e:exception do begin
    Clear;
    e.message:='Set_AsVariantSysMsg: '+e.message;
    raise;
  end;end;
end;

function TPackMessage.Get_PackID:TPackID;
begin
  Result:=pciMessage;
end;

function TPackMessage.ValidVersion(aVersion:Integer):Boolean;
begin
  result:=aVersion=1;
end;

function TPackMessage.Get_DateCreate:TDateTime;
begin
  Result:=FDateCreate;
end;

function TPackMessage.Get_Sender:AnsiString;
begin
  if FSenderForSysMsg<>'' then begin
    Result:=FSenderForSysMsg;
    Exit;
  end;
  Result:='Get_Sender: UNDERCONSTRUCTION.';
end;

function TPackMessage.Get_Receiver:AnsiString;
begin
  Result:='Get_Receiver: UNDERCONSTRUCTION.';
end;

function TPackMessage.InternalCreateClone:IPack;
begin
  result:=TPackMessage.create;
end;

function TPackMessage.Clone:IPack;
  var tmpIPackMessage:IPackMessage;
begin
  result:=inherited Clone;
  if (not assigned(result))or(result.QueryInterface(IPackMessage, tmpIPackMessage)<>S_OK)or(not assigned(tmpIPackMessage)) then raise exception.createFmtHelp(cserInternalError, ['IPackMessage no found'], cnerInternalError);
  tmpIPackMessage.AsVariant:=AsVariant;
end;

function TPackMessage.ClonePackMessage:IPackMessage;
  var tmpIPack:IPack;
begin
  tmpIPack:=Clone;
  if (not assigned(tmpIPack))or(tmpIPack.QueryInterface(IPackMessage, Result)<>S_OK)or(not assigned(result)) then raise exception.createFmtHelp(cserInternalError, ['IPackMessage no found'], cnerInternalError);
end;

end.
