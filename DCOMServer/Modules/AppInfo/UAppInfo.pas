//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UAppInfo;

interface
  uses UTrayInterface, UAppInfoTypes, UTrayInterfaceTypes;
type
  TAppInfo=class(TTrayInterface, IAppInfo)
  private
    FStartTime:TDateTime;
    FCompanyName:AnsiString;
    FFileDescription:AnsiString;
    FFileVersion:TAppVersion;
    FInternalName:AnsiString;
    FLegalCopyright:AnsiString;
    FLegalTradeMarks:AnsiString;
    FOriginalFileName:AnsiString;
    FProductName:AnsiString;
    FProductVersion:TAppVersion;
    FComments:AnsiString;
  protected
    procedure InternalInit;override;
  protected
    function Get_StartTime:TDateTime;virtual;
    function Get_CompanyName:AnsiString;virtual;
    function Get_FileDescription:AnsiString;virtual;
    function Get_FileVersionAsString:AnsiString;virtual;
    function Get_FileVersion:TAppVersion;virtual;
    function Get_InternalName:AnsiString;virtual;
    function Get_LegalCopyright:AnsiString;virtual;
    function Get_LegalTradeMarks:AnsiString;virtual;
    function Get_OriginalFileName:AnsiString;virtual;
    function Get_ProductName:AnsiString;virtual;
    function Get_ProductVersion:TAppVersion;virtual;
    function Get_ProductVersionAsString:AnsiString;virtual;
    function Get_Comments:AnsiString;virtual;
    function Get_Icon:Variant;virtual;
  public
    constructor create;
    destructor destroy;override;
    property StartTime:TDateTime read Get_StartTime;
    property CompanyName:AnsiString read Get_CompanyName;
    property FileDescription:AnsiString read Get_FileDescription;
    property FileVersionAsString:AnsiString read Get_FileVersionAsString;
    property FileVersion:TAppVersion read Get_FileVersion;
    property InternalName:AnsiString read Get_InternalName;
    property LegalCopyright:AnsiString read Get_LegalCopyright;
    property LegalTradeMarks:AnsiString read Get_LegalTradeMarks;
    property OriginalFileName:AnsiString read Get_OriginalFileName;
    property ProductName:AnsiString read Get_ProductName;
    property ProductVersionAsString:AnsiString read Get_ProductVersionAsString;
    property ProductVersion:TAppVersion read Get_ProductVersion;
    property Comments:AnsiString read Get_Comments;
  end;

implementation
  uses Sysutils, Classes, Forms{$IFNDEF VER130}, Variants{$ENDIF}, Windows;

constructor TAppInfo.create;
begin
  inherited create;
  FStartTime:=now;
  FillChar(FFileVersion, SizeOf(TAppVersion), 0);
  FillChar(FProductVersion, SizeOf(TAppVersion), 0);
end;

destructor TAppInfo.destroy;
begin
  FCompanyName:='';
  FFileDescription:='';
  FInternalName:='';
  FLegalCopyright:='';
  FLegalTradeMarks:='';
  FOriginalFileName:='';
  FProductName:='';
  FComments:='';
  inherited destroy;
end;

function TAppInfo.Get_StartTime:TDateTime;
begin
  InternalLock;
  try
    result:=FStartTime;
  finally
   InternalUnlock;
  end;
end;

function TAppInfo.Get_CompanyName:AnsiString;
begin
  InternalLock;
  try
    result:=FCompanyName;
  finally
   InternalUnlock;
  end;
end;

function TAppInfo.Get_FileDescription:AnsiString;
begin
  InternalLock;
  try
    result:=FFileDescription;
  finally
   InternalUnlock;
  end;
end;

function TAppInfo.Get_FileVersionAsString:AnsiString;
begin
  InternalLock;
  try
    result:=IntToStr(FFileVersion.major)+'.'+IntToStr(FFileVersion.minor)+'.'+IntToStr(FFileVersion.release)+'.'+IntToStr(FFileVersion.build);
  finally
   InternalUnlock;
  end;
end;

function TAppInfo.Get_FileVersion:TAppVersion;
begin
  InternalLock;
  try
    result:=FFileVersion;
  finally
   InternalUnlock;
  end;
end;

function TAppInfo.Get_InternalName:AnsiString;
begin
  InternalLock;
  try
    result:=FInternalName;
  finally
   InternalUnlock;
  end;
end;

function TAppInfo.Get_LegalCopyright:AnsiString;
begin
  InternalLock;
  try
    result:=FLegalCopyright;
  finally
   InternalUnlock;
  end;
end;

function TAppInfo.Get_LegalTradeMarks:AnsiString;
begin
  InternalLock;
  try
    result:=FLegalTradeMarks;
  finally
   InternalUnlock;
  end;
end;

function TAppInfo.Get_OriginalFileName:AnsiString;
begin
  InternalLock;
  try
    result:=FOriginalFileName;
  finally
   InternalUnlock;
  end;
end;

function TAppInfo.Get_ProductVersionAsString:AnsiString;
begin
  InternalLock;
  try
    result:=IntToStr(FProductVersion.major)+'.'+IntToStr(FProductVersion.minor)+'.'+IntToStr(FProductVersion.release)+'.'+IntToStr(FProductVersion.build);
  finally
   InternalUnlock;
  end;
end;

function TAppInfo.Get_ProductName:AnsiString;
begin
  InternalLock;
  try
    result:=FProductName;
  finally
   InternalUnlock;
  end;
end;

function TAppInfo.Get_ProductVersion:TAppVersion;
begin
  InternalLock;
  try
    result:=FProductVersion;
  finally
   InternalUnlock;
  end;
end;

function TAppInfo.Get_Comments:AnsiString;
begin
  InternalLock;
  try
    result:=FComments;
  finally
   InternalUnlock;
  end;
end;

function TAppInfo.Get_Icon:Variant;
  var tmpStrm:TMemoryStream;
      tmpPtr:Pointer;
begin
  InternalLock;
  try
    tmpStrm:=TMemoryStream.Create;
    Try
      Application.Icon.SaveToStream(tmpStrm);
      result:=VarArrayCreate([0, tmpStrm.Size], varByte);
      tmpPtr:=VarArrayLock(result);
      Try
        Move(tmpStrm.Memory^, tmpPtr^, tmpStrm.Size);
      Finally
        VarArrayUnlock(result);
      end;
    Finally
      tmpStrm.Free;
    end;
  finally
   InternalUnlock;
  end;
end;

procedure TAppInfo.InternalInit;
const InfoNum=10;
      InfoStr:array[1..InfoNum] of string=('CompanyName', 'FileDescription', 'FileVersion', 'InternalName', 'LegalCopyright', 'LegalTradeMarks', 'OriginalFileName', 'ProductName', 'ProductVersion', 'Comments');
  var tmpExeName:AnsiString;
      tmpSize:Cardinal;
      tmpPointer:Pointer;
      tmpValue:PChar;
      tmpLength:Cardinal;
      tmpI:Cardinal;
  procedure localStringToAppVersion(aValue:PChar; aAppVersion:PAppVersion); var tmpI, tmpN, tmpLength:Integer; tmpStr:AnsiString; begin
    if aValue='' Then begin
      FillChar(aAppVersion^, SizeOf(TAppVersion), 0);
    end else begin
      tmpStr:='';
      tmpN:=0;
      tmpLength:=length(aValue)-1;
      for tmpI:=0 to tmpLength do begin
        if (aValue[tmpI]='.')or(tmpI=tmpLength) then begin
          if tmpI=tmpLength then tmpStr:=tmpStr+aValue[tmpI];
          Case tmpN of
            0:if tmpStr<>'' then aAppVersion^.major:=StrToInt(tmpStr) else aAppVersion^.major:=0;
            1:if tmpStr<>'' then aAppVersion^.minor:=StrToInt(tmpStr) else aAppVersion^.minor:=0;
            2:if tmpStr<>'' then aAppVersion^.release:=StrToInt(tmpStr) else aAppVersion^.release:=0;
            3:if tmpStr<>'' then aAppVersion^.build:=StrToInt(tmpStr) else aAppVersion^.build:=0;
          end;
          Inc(tmpN);
          tmpStr:='';
        end else begin
          tmpStr:=tmpStr+aValue[tmpI];
        end;
      end;
    end;
  end;
begin
  tmpExeName:=Application.ExeName;
  tmpSize:=GetFileVersionInfoSize(PChar(tmpExeName), tmpSize);
  if tmpSize>0 then begin
    tmpPointer:=AllocMem(tmpSize);
    try
      GetFileVersionInfo(PChar(tmpExeName), 0, tmpSize, tmpPointer);
      tmpExeName:='';
      for tmpI:=1 to InfoNum do begin
        if not VerQueryValue(tmpPointer, PChar('StringFileInfo\040904E4\'+InfoStr[tmpI]), Pointer(tmpValue), tmpLength) then tmpValue:=PChar(tmpExeName);
        case tmpI of
          1:FCompanyName:=tmpValue;
          2:FFileDescription:=tmpValue;
          3:localStringToAppVersion(tmpValue, @FFileVersion);
          4:FInternalName:=tmpValue;
          5:FLegalCopyright:=tmpValue;
          6:FLegalTradeMarks:=tmpValue;
          7:FOriginalFileName:=tmpValue;
          8:FProductName:=tmpValue;
          9:localStringToAppVersion(tmpValue, @FProductVersion);
          10:FComments:=tmpValue;
        end;
      end;
    finally
      FreeMem(tmpPointer, tmpSize);
    end;
  end;{else No version information found}
end;

end.
