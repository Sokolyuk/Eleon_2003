//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UAppInfoTypes;

interface
  uses UTrayInterfaceTypes;
type
  PAppVersion=^TAppVersion;
  TAppVersion=record
    major:cardinal;
    minor:cardinal;
    release:cardinal;
    build:cardinal;
  end;

  IAppInfo=interface
  ['{7B959FD4-BF59-4FAE-B087-DC2526E5E3E6}']
    function Get_StartTime:TDateTime;
    function Get_CompanyName:AnsiString;
    function Get_FileDescription:AnsiString;
    function Get_FileVersionAsString:AnsiString;
    function Get_FileVersion:TAppVersion;
    function Get_InternalName:AnsiString;
    function Get_LegalCopyright:AnsiString;
    function Get_LegalTradeMarks:AnsiString;
    function Get_OriginalFileName:AnsiString;
    function Get_ProductName:AnsiString;
    function Get_ProductVersion:TAppVersion;
    function Get_ProductVersionAsString:AnsiString;
    function Get_Comments:AnsiString;
    function Get_Icon:Variant;
    //..
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
    property Icon:Variant read Get_Icon;
  end;

  //TPartOfInfo=(poiServerAbout{0}, poiASM{1}, poiShop{2}, poiAccess{3}, poiMessageStatistic{4}, poiCacheDir{5});

implementation

end.
