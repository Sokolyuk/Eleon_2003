//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UEMailAttachment;

interface
  uses UEMailAttachmentTypes, UITObject;
type
  //*************************************************************
  //  0:varInteger - Тип аттачмента
  //  1:OleStr     - Имя файла
  //  2:varArray   - Сам файл
  //*************************************************************
  TEMailAttachment=class(TITObject, IEMailAttachment)
  protected
    FAttachmentType:TAttachmentType;
    FFileName:AnsiString;
    FtmpCheckCreatedDir:boolean;
    FCacheDir:AnsiString;
  protected
    function Get_AttachmentType:TAttachmentType;
    function Get_FileName:AnsiString;
    function Get_AsVariant:Variant;
    procedure Set_AsVariant(const Value:Variant);
    procedure InternalCheck(const aAsVariant:Variant);
    function InternalGetCacheDir:AnsiString;
  public
    constructor create;overload;
    constructor create(const aCacheDir:AnsiString);overload;
    destructor Destroy; override;
    procedure SetAttachmentFile(const aFileName:AnsiString);
    procedure SetAttachmentFileName(const aFileName:AnsiString);
    Property AttachmentType:TAttachmentType read Get_AttachmentType;
    Property FileName:AnsiString read Get_FileName;
    Property AsVariant:Variant read Get_AsVariant write Set_AsVariant;
  end;

implementation
  Uses SysUtils, UTypeUtils, {UTrayConsts, }UPackMessageConsts
       {$IFNDEF VER130}, Variants{$ENDIF}{$IFDEF VER130}, FileCtrl{$ENDIF};
{$IFDEF VER130}
  Type TVarType=Integer;
{$ENDIF}

constructor TEMailAttachment.create;
begin
  inherited create;
  FAttachmentType:=attInvalid;
  FFileName:='';
  FtmpCheckCreatedDir:=false;
  FCacheDir:='';
end;

constructor TEMailAttachment.create(const aCacheDir:AnsiString);
begin
  inherited create;
  FAttachmentType:=attInvalid;
  FFileName:='';
  FtmpCheckCreatedDir:=false;
  FCacheDir:=aCacheDir;
end;

destructor TEMailAttachment.Destroy;
begin
  FAttachmentType:=attInvalid;
  FFileName:='';
  Inherited Destroy;
end;

function TEMailAttachment.Get_AttachmentType:TAttachmentType;
begin
  Result:=FAttachmentType;
end;

function TEMailAttachment.Get_FileName:AnsiString;
begin
  Result:=FFileName;
end;

procedure TEMailAttachment.SetAttachmentFile(const aFileName:AnsiString);
begin
  if not FileExists(aFileName) then raise exception.create('File '''+aFileName+''' is not exist.');
  FFileName:=aFileName;
  FAttachmentType:=attFile;
end;

procedure TEMailAttachment.SetAttachmentFileName(const aFileName:AnsiString);
begin
  if not FileExists(aFileName) then raise exception.create('File '''+aFileName+''' is not exist.');
  FFileName:=aFileName;
  FAttachmentType:=attFileName;
end;

function TEMailAttachment.Get_AsVariant:Variant;
begin
  if FAttachmentType=attFileName then begin
    Result:=VarArrayCreate([0, 1], varVariant);
    Result[0]:=FAttachmentType;
    Result[1]:=FFileName;
  end else if FAttachmentType=attFile then begin
    Result:=VarArrayCreate([0, 2], varVariant);
    Result[0]:=FAttachmentType;
    Result[1]:=ExtractFileName(FFileName);
    Result[2]:=glFileToVariant(FFileName);
  end else raise exception.create('Invalid AttachmentType.');
end;

procedure TEMailAttachment.InternalCheck(const aAsVariant:Variant);
  var tmpVarType:TVarType;
begin
  if not VarIsArray(aAsVariant) then raise exception.create('aAsVariant is not array.');
  if VarArrayLowBound(aAsVariant, 1)<>0 then raise exception.create('Invalid array low bound.');
  if aAsVariant[0]=attFileName then begin
    if VarArrayHighBound(aAsVariant, 1)<>1 then raise exception.create('Invalid array high bound.');
  end else if aAsVariant[0]=attFile then begin
    if VarArrayHighBound(aAsVariant, 1)<>2 then raise exception.create('Invalid array high bound.');
    if VarType(aAsVariant[2])<>(varByte Or varArray) then raise exception.create('Invalid Attachment DataType.');
  end else raise exception.create('Invalid AttachmentType.');
  tmpVarType:=VarType(aAsVariant[1]);
  if (tmpVarType<>varOleStr)And(tmpVarType<>varString) then raise exception.create('Invalid VarType.');
end;

function TEMailAttachment.InternalGetCacheDir:AnsiString;
begin
  Result:={IAppCacheDir(cnTray.Query(IAppCacheDir)).CacheDir}FCacheDir+csCacheMailSubDir;
  if not FtmpCheckCreatedDir then begin
    if not DirectoryExists(Result) then if not ForceDirectories(Result) then raise exception.create('Unable to create folder '''+Result+'''.');
    FtmpCheckCreatedDir:=True;
  end;
end;

procedure TEMailAttachment.Set_AsVariant(const Value:Variant);
  Var tmpAttachmentType:TAttachmentType;
      tmpFileName:AnsiString;
begin
  try
    InternalCheck(Value);
    tmpAttachmentType:=Value[0];
    tmpFileName:=Value[1];
    if tmpAttachmentType=attFileName then begin
      if not FileExists(tmpFileName) then raise exception.create('File '''+tmpFileName+''' is not exist.');
    end;
    if tmpAttachmentType=attFile then begin
      tmpFileName:=InternalGetCacheDir+tmpFileName;
      glVariantToFile(value[2], tmpFileName);
    end;
    FAttachmentType:=tmpAttachmentType;
    FFileName:=tmpFileName;
  except
    on e:exception do raise exception.create('Set_AsVariant: '+e.message);
  end;
end;    

end.
