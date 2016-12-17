//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UEPointProperties;

interface
  uses UTrayInterface, UEPointPropertiesTypes, UAppCacheDirTypes, UNodeTypes;
type
  TEPointProperties=class(TTrayInterface, IEPointProperties)
  protected
    function GetNodeName(aConnectionName:PAnsiString):AnsiString;virtual;abstract;
    function GetTitlePoint:Ansistring;virtual;
    function GetConfigure(const Value:AnsiString):AnsiString;virtual;
    function GetNodeType:TNodeType;virtual;abstract;
  protected
    function InternalGetCacheDirBf:AnsiString;virtual;abstract;
    function InternalGetIAppCacheDir:IAppCacheDir;virtual;
  public
    constructor create;
    destructor destroy;override;
    property NodeName[aConnectionName:PAnsiString]:AnsiString read GetNodeName;
    property NodeType:TNodeType read GetNodeType;
    property TitlePoint:AnsiString read GetTitlePoint;
    property Configure[const Value:AnsiString]:AnsiString read GetConfigure;
  end;

implementation
  uses Sysutils, UEPointConfigureConsts;
  
constructor TEPointProperties.create;
begin
  inherited create;
end;

destructor TEPointProperties.destroy;
begin
  inherited destroy;
end;

function TEPointProperties.GetTitlePoint:Ansistring;
begin
  result:='<None>';
end;

function TEPointProperties.InternalGetIAppCacheDir:IAppCacheDir;
begin
  InternalGetITray.Query(IAppCacheDir, result);
end;

function TEPointProperties.GetConfigure(const Value:AnsiString):AnsiString;
begin
  if AnsiUpperCase(Value)=cscnfgCacheDirBf then begin
    result:=InternalGetCacheDirBf;
  end else raise exception.create('Configure: Unknown value '''+Value+'''.');
end;

end.
