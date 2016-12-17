//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UEMailMessage;

interface
  uses UIObject, UEMailMessageTypes, UVarsetTypes;
type
  //*********************************************************
  //
  //  0:varInteger - Версия
  //  1:varOleStr  - Subject
  //  2:varOleStr  - Addresses(To)
  //  3:varOleStr  - From
  //  4:varOleStr  - Body(Message)
  //  5:varArray   - Attachments
  //
  //*********************************************************

  TEMailMessage=class(TIObject, IEMailMessage)
  protected
    FSubject:AnsiString;
    FAddresses:AnsiString;
    FFrom:AnsiString;
    FBody:AnsiString;
    FAttachments:IVarset;
    FCacheDir:AnsiString;
  protected
    function Get_Subject:AnsiString;
    procedure Set_Subject(Value:AnsiString);
    function Get_Addresses:AnsiString;
    procedure Set_Addresses(Value:AnsiString);
    function Get_From:AnsiString;
    procedure Set_From(Value:AnsiString);
    function Get_Body:AnsiString;
    procedure Set_Body(Value:AnsiString);
    function Get_Attachments:IVarset;
    function Get_DataV:Variant;
    procedure Set_DataV(Value:Variant);
    procedure InternalCheck(Const aDataV:Variant);
    function Get_CacheDir:AnsiString;
    procedure Set_CacheDir(Value:AnsiString);
  public
    constructor Create;
    destructor Destroy; override;
    Property Subject:AnsiString read Get_Subject write Set_Subject;
    Property Addresses:AnsiString read Get_Addresses write Set_Addresses;
    Property From:AnsiString read Get_From write Set_From;
    Property Body:AnsiString read Get_Body write Set_Body;
    Property Attachments:IVarset read Get_Attachments;
    Property DataV:Variant read Get_DataV write Set_DataV;
    Property CacheDir:AnsiString read Get_CacheDir write Set_CacheDir;
  end;

implementation
  uses UVarset, UEMailAttachmentTypes, SysUtils, UEMailAttachment{$IFnDEF VER130}, Variants{$ENDIF};

constructor TEMailMessage.Create;
begin
  inherited create;
  FSubject:='';
  FAddresses:='';
  FFrom:='';
  FBody:='';
  FCacheDir:='';
  FAttachments:=TVarset.Create;
  FAttachments.ITConfigIntIndexAssignable:=False;
  FAttachments.ITConfigCheckUniqueIntIndex:=False;
  FAttachments.ITConfigCheckUniqueStrIndex:=False;
  FAttachments.ITConfigNoFoundException:=True;
  FAttachments.ITConfigCaseSensitive:=False;
end;

destructor TEMailMessage.destroy;
begin
  FSubject:='';
  FAddresses:='';
  FFrom:='';
  FBody:='';
  FCacheDir:='';
  FAttachments:=Nil;
  inherited destroy;
end;

function TEMailMessage.Get_Subject:AnsiString;
begin
  Result:=FSubject;
end;

procedure TEMailMessage.Set_Subject(Value:AnsiString);
begin
  FSubject:=Value;
end;

function TEMailMessage.Get_Addresses:AnsiString;
begin
  Result:=FAddresses;
end;

procedure TEMailMessage.Set_Addresses(Value:AnsiString);
begin
  FAddresses:=Value;
end;

function TEMailMessage.Get_From:AnsiString;
begin
  Result:=FFrom;
end;

procedure TEMailMessage.Set_From(Value:AnsiString);
begin
  FFrom:=Value;
end;

function TEMailMessage.Get_Body:AnsiString;
begin
  Result:=FBody;
end;

procedure TEMailMessage.Set_Body(Value:AnsiString);
begin
  FBody:=Value;
end;

function TEMailMessage.Get_Attachments:IVarset;
begin
  Result:=FAttachments;
end;

function TEMailMessage.Get_DataV:Variant;
  Var tmpIEMailAttachment:IEMailAttachment;
      tmpIntIndex:Integer;
      tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
      tmpV:Variant;
      tmpivHB:Integer;
begin
  // 0:varInteger - Версия
  // 1:varOleStr  - Subject
  // 2:varOleStr  - Addresses(To)
  // 3:varOleStr  - From
  // 4:varOleStr  - Body(Message)
  // 5:varArray   - Attachments
  //..
  Result:=VarArrayCreate([0, 5], varVariant);
  Result[0]:=1;
  Result[1]:=FSubject;
  Result[2]:=FAddresses;
  Result[3]:=FFrom;
  Result[4]:=FBody;
  //..
  tmpV:=Unassigned;
  tmpivHB:=-1;
  tmpIEMailAttachment:=Nil;
  tmpIntIndex:=-1;
  while true do begin
    tmpIVarsetDataView:=FAttachments.ITViewNextGetOfIntIndex(tmpIntIndex);
    If tmpIntIndex=-1 then break;
    tmpIUnknown:=tmpIVarsetDataView.ITData;
    If (Not Assigned(tmpIUnknown))Or(tmpIUnknown.QueryInterface(IEMailAttachment, tmpIEMailAttachment)<>S_OK)Or(Not Assigned(tmpIEMailAttachment)) Then Raise Exception.Create('Внутренняя ошибка: QueryInterface: IEMailAttachment not found. Обратитесь к разработчику.');
    If tmpivHB<0 Then begin
      tmpV:=VarArrayCreate([0, 0], varVariant);
      tmpivHB:=0;
    end else begin
      VarArrayRedim(tmpV, tmpivHB+1);
      Inc(tmpivHB);
    end;
    tmpV[tmpivHB]:=tmpIEMailAttachment.AsVariant;
  end;
  tmpIVarsetDataView:=Nil;
  tmpIEMailAttachment:=Nil;
  tmpIUnknown:=Nil;
  Result[5]:=tmpV;
  VarClear(tmpV);
end;

procedure TEMailMessage.InternalCheck(Const aDataV:Variant);
  Var tmpVarType:TVarType;
begin
  Try
    If Not VarIsArray(aDataV) Then Raise Exception.Create('data is not array.');
    If (VarArrayLowBound(aDataV, 1)<>0)Or(VarArrayHighBound(aDataV, 1)<>5) Then raise exception.Create('Invalid array bound.');
    If aDataV[0]<>1 Then raise exception.Create('Unknown version.');
    tmpVarType:=VarType(aDataV[1]);
    If (tmpVarType<>varOleStr)And(tmpVarType<>varString) Then raise exception.Create('Invalid VarType.');
    tmpVarType:=VarType(aDataV[2]);
    If (tmpVarType<>varOleStr)And(tmpVarType<>varString) Then raise exception.Create('Invalid VarType.');
    tmpVarType:=VarType(aDataV[3]);
    If (tmpVarType<>varOleStr)And(tmpVarType<>varString) Then raise exception.Create('Invalid VarType.');
    tmpVarType:=VarType(aDataV[4]);
    If (tmpVarType<>varOleStr)And(tmpVarType<>varString) Then raise exception.Create('Invalid VarType.');
    If (Not VarIsEmpty(aDataV[5]))And(Not VarIsArray(aDataV[5])) Then raise exception.Create('Invalid VarType for attachment.');
  except
    On e:exception do Raise exception.Create('InternalCheck(EMailMessage): '+e.message);
  end;
end;

procedure TEMailMessage.Set_DataV(Value:Variant);
  Var tmpSubject:AnsiString;
      tmpAddresses:AnsiString;
      tmpFrom:AnsiString;
      tmpBody:AnsiString;
      tmpAttachments:IVarset;
      tmpI:Integer;
      tmpIEMailAttachment:IEMailAttachment;
begin
  try
    InternalCheck(Value);
    tmpSubject:=Value[1];
    tmpAddresses:=Value[2];
    tmpFrom:=Value[3];
    tmpBody:=Value[4];
    //..
    tmpAttachments:=TVarset.Create;
    tmpAttachments.ITConfigIntIndexAssignable:=False;
    tmpAttachments.ITConfigCheckUniqueIntIndex:=False;
    tmpAttachments.ITConfigCheckUniqueStrIndex:=False;
    tmpAttachments.ITConfigNoFoundException:=True;
    tmpAttachments.ITConfigCaseSensitive:=False;
    //..
    if VarIsArray(Value[5]) then begin
      for tmpI:=0 to VarArrayHighBound(Value[5], 1) do begin
        tmpIEMailAttachment:=TEMailAttachment.Create;
        //tmpIEMailAttachment.CacheDir:=FCacheDir;
        tmpIEMailAttachment.AsVariant:=Value[5][tmpI];
        tmpAttachments.ITPushV(tmpIEMailAttachment);
        tmpIEMailAttachment:=nil;
      end;
    end;
    //..
    FAttachments.ITAssign(tmpAttachments, True, True);
    tmpAttachments:=nil;
    FSubject:=tmpSubject;
    FAddresses:=tmpAddresses;
    FFrom:=tmpFrom;
    FBody:=tmpBody;
  except on e:exception do begin
    raise exception.create('Set_DataV: '+e.message);
  end;end;
end;

function TEMailMessage.Get_CacheDir:AnsiString;
begin
  Result:=FCacheDir;
end;

procedure TEMailMessage.Set_CacheDir(Value:AnsiString);
begin
  If Value=FCacheDir Then Exit;
  If Value<>'' Then begin
    If Value[Length(Value)]<>'\' Then Value:=Value+'\';
  end;
  Value:=Value+'CacheMail\';
  if Not DirectoryExists(Value) Then if Not ForceDirectories(Value) then Raise Exception.Create('Не удается создать каталог '''+Value+'''.');
  FCacheDir:=Value;
end;

End.
