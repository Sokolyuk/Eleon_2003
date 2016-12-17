//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UServerInfo;

interface
  uses UTrayInterface, UServerInfoTypes, UTrayInterfaceTypes;
type
  TServerInfo=class(TTrayInterface, IServerInfo)
  private
    FServerADMGroupName:AnsiString;
    FServerSecurityContext:Variant;
  protected
    function InternalGetInitGUIDCount:Cardinal;override;
    procedure InternalInitGUIDList;override;
    procedure InternalInit;override;
  protected
    function InternalGet_poiNode:Variant;virtual;abstract;
    function InternalGet_poiAccess:Variant;virtual;abstract;
    Function Get_ServerADMGroupName:AnsiString;virtual;
    Procedure Set_ServerADMGroupName(const value:AnsiString);virtual;
    Function Get_ServerSecurityContext:Variant;virtual;
    Procedure Set_ServerSecurityContext(const value:Variant);virtual;
  public
    constructor create;
    destructor destroy;override;
    Function ServerInfo(aPartOfInfo:TPartOfInfo):Variant;virtual;
    property ServerADMGroupName:AnsiString read Get_ServerADMGroupName write Set_ServerADMGroupName;
    property ServerSecurityContext:Variant read Get_ServerSecurityContext write Set_ServerSecurityContext;
  end;

implementation
  uses UTrayConsts, UAppInfoTypes, UAppMessageTypes, UAppCacheDirTypes, Variants, Sysutils, ULocalDataBaseTypes,
       ULocalDataBase, UTypeUtils, UServerActionConsts, UServerOnlineTypes;
  
constructor TServerInfo.create;
begin
  inherited create;
  FServerADMGroupName:='';
  FServerSecurityContext:=unassigned;
end;

destructor TServerInfo.destroy;
begin
  FServerADMGroupName:='';
  FServerSecurityContext:=unassigned;
  inherited destroy;
end;

function TServerInfo.InternalGetInitGUIDCount:Cardinal;
begin
  result:=inherited InternalGetInitGUIDCount+3;
end;

procedure TServerInfo.InternalInitGUIDList;
  var tmpCount:Cardinal;
begin
  inherited InternalInitGUIDList;
  tmpCount:=inherited InternalGetInitGUIDCount;
  GUIDList^.aList[tmpCount]:=IAppInfo;
  GUIDList^.aList[tmpCount+1]:=IAppMessage;
  GUIDList^.aList[tmpCount+2]:=IAppCacheDir;
end;

procedure TServerInfo.InternalInit;
  Var tmpLocalDataBase:ILocalDataBase;
begin
  tmpLocalDataBase:=TLocalDataBase.Create;
  tmpLocalDataBase.CallerAction:=cnServerAction;
  tmpLocalDataBase.CheckSecuretyLDB:=False;
  tmpLocalDataBase.CheckForTriggers:=False;
{$IFDEF PegasServer}
  tmpLocalDataBase.OpenSQL('SELECT ServerSecurityContext FROM ssPegasServerConfig');
  If tmpLocalDataBase.DataSet.RecordCount<>1 Then Raise Exception.Create('Неправильные данные в БД отсутствуют(ssPegasServerConfig).');
{$ELSE}
  tmpLocalDataBase.OpenSQL('SELECT ServerSecurityContext FROM ssInternalConfig');
  If tmpLocalDataBase.DataSet.RecordCount<>1 Then Raise Exception.Create('Неправильные данные в ЛБД отсутствуют(ssInternalConfig).');
{$Endif}
  FServerSecurityContext:=glStringToVarArray(tmpLocalDataBase.DataSet.FieldByName('ServerSecurityContext').AsString);
end;

Function TServerInfo.ServerInfo(aPartOfInfo:TPartOfInfo):Variant;
  var tmpAppVersion:TAppVersion;
      tmpAppInfo:IAppInfo;
      tmpAppMessage:IAppMessage;
begin
  InternalLock;
  try
    Result:=Unassigned;
    Case aPartOfInfo of
      poiServerAbout:begin
        cnTray.Query(IAppInfo, tmpAppInfo);
        tmpAppVersion:=tmpAppInfo.FileVersion;
        Result:=VarArrayOf([tmpAppInfo.InternalName, tmpAppVersion.Major, tmpAppVersion.Minor, tmpAppVersion.Release, tmpAppVersion.build, tmpAppInfo.Comments, tmpAppInfo.Icon]);
      end;
      poiASM:begin
        Raise Exception.Create('Невозможно получение данных по разделу poiASM('+IntToStr(1{poiASM})+').');
      end;
      poiNode:Result:=InternalGet_poiNode;
      poiAccess:Result:=InternalGet_poiAccess;
      poiMessageStatistic:begin
        cnTray.Query(IAppMessage, tmpAppMessage);
        //                                All 23            SQL 59                        App 60                        Debug 63                        Secur 56                           Info 52                       Error 51                       Warning 54                       Saved 21             Max buff size 42
        result:=VarArrayOf([tmpAppMessage.MessCountAll, tmpAppMessage.MessCountClassSQL, tmpAppMessage.MessCountClassApp, tmpAppMessage.MessCountClassDebug, tmpAppMessage.MessCountClassSecurity, tmpAppMessage.MessCountStyleInfo, tmpAppMessage.MessCountStyleError, tmpAppMessage.MessCountStyleWarning, tmpAppMessage.MessCountAll{MessSave}, tmpAppMessage.MessagesMaxCount]);
      end;
      poiCacheDir:Result:=IAppCacheDir(cnTray.Query(IAppCacheDir)).CacheDir;
      poiOnLine:result:=IServerOnline(cnTray.Query(IServerOnline)).ITOnLineStatus;
    else
      Raise Exception.Create('aPartOfInfo('+IntToStr(Integer(aPartOfInfo))+') is unknown.');
    end;
  finally
    InternalUnlock;
  end;
end;

Function TServerInfo.Get_ServerADMGroupName:AnsiString;
begin
  Internallock;
  try
    result:=FServerADMGroupName;
  finally
    Internalunlock;
  end;
end;

Procedure TServerInfo.Set_ServerADMGroupName(const value:AnsiString);
begin
  Internallock;
  try
    FServerADMGroupName:=value;
  finally
    Internalunlock;
  end;
end;

Function TServerInfo.Get_ServerSecurityContext:Variant;
begin
  Internallock;
  try
    result:=FServerSecurityContext;
  finally
    Internalunlock;
  end;
end;

Procedure TServerInfo.Set_ServerSecurityContext(const value:Variant);
begin
  Internallock;
  try
    FServerSecurityContext:=value;
  finally
    Internalunlock;
  end;
end;

end.
