//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UNodeInfo;

interface
  uses UNodeInfoTypes, UTrayInterface, UTrayInterfaceTypes;
type
  TNodeInfo=class(TTrayInterface, INodeInfo)
  private
    FID:Integer;
    FServerIDBor1a:Integer;
    //FLDBVer:Integer;
    FName:AnsiString;
    FSName:AnsiString;
    FCommentary:AnsiString;
    FAddress:AnsiString;
    FPhone:AnsiString;
    FCardLetter:AnsiString;
    //FADMGroupName:AnsiString;
  protected
    procedure InternalInit;override;
  protected
    function Get_ID:Integer;virtual;
    procedure Set_ID(value:Integer);virtual;
    function Get_ServerIDBor1a:Integer;virtual;
    procedure Set_ServerIDBor1a(value:Integer);virtual;
    //function Get_LDBVer:Integer;virtual;
    //procedure Set_LDBVer(value:Integer);virtual;
    function Get_Name:AnsiString;virtual;
    procedure Set_Name(const value:AnsiString);virtual;
    function Get_SName:AnsiString;virtual;
    procedure Set_SName(const value:AnsiString);virtual;
    function Get_Commentary:AnsiString;virtual;
    procedure Set_Commentary(const value:AnsiString);virtual;
    function Get_Address:AnsiString;virtual;
    procedure Set_Address(const value:AnsiString);virtual;
    function Get_Phone:AnsiString;virtual;
    procedure Set_Phone(const value:AnsiString);virtual;
    function Get_CardLetter:AnsiString;virtual;
    procedure Set_CardLetter(const value:AnsiString);virtual;
    //function Get_ADMGroupName:AnsiString;virtual;
    //Procedure Set_ADMGroupName(const value:AnsiString);virtual;
  public
    constructor create;
    destructor destroy;override;
    property ID:Integer read Get_ID write Set_ID;
    property ServerIDBor1a:Integer read Get_ServerIDBor1a write Set_ServerIDBor1a;
    //property LDBVer1:Integer read Get_LDBVer write Set_LDBVer;
    property Name:AnsiString read Get_Name write Set_Name;
    property SName:AnsiString read Get_SName write Set_SName;
    property Commentary:AnsiString read Get_Commentary write Set_Commentary;
    property Address:AnsiString read Get_Address write Set_Address;
    property Phone:AnsiString read Get_Phone write Set_Phone;
    property CardLetter:AnsiString read Get_CardLetter write Set_CardLetter;
    //Property ADMGroupName:AnsiString read Get_ADMGroupName write Set_ADMGroupName;
  end;

implementation
  uses ULocalDataBaseTypes, ULocalDataBase, Variants, Sysutils, UServerActionConsts;

constructor TNodeInfo.create;
begin
  inherited create;
  FID:=-1;
  FServerIDBor1a:=-1;
  //FLDBVer:=-1;
  FName:='';
  FSName:='';
  FCommentary:='';
  FAddress:='';
  FPhone:='';
  FCardLetter:='';
  //FADMGroupName:='';
end;

destructor TNodeInfo.destroy;
begin
  inherited destroy;
end;

function TNodeInfo.Get_ID:Integer;
begin
  Internallock;
  try
    result:=FID;
  finally
    Internalunlock;
  end;
end;

procedure TNodeInfo.Set_ID(value:Integer);
begin
  Internallock;
  try
    FID:=value;
  finally
    Internalunlock;
  end;
end;

function TNodeInfo.Get_ServerIDBor1a:Integer;
begin
  Internallock;
  try
    result:=FServerIDBor1a;
  finally
    Internalunlock;
  end; 
end;

procedure TNodeInfo.Set_ServerIDBor1a(value:Integer);
begin
  Internallock;
  try
    FServerIDBor1a:=value;
  finally
    Internalunlock;
  end;
end;

{function TNodeInfo.Get_LDBVer:Integer;
begin
  Internallock;
  try
    result:=FLDBVer;
  finally
    Internalunlock;
  end;
end;

procedure TNodeInfo.Set_LDBVer(value:Integer);
begin
  Internallock;
  try
    FLDBVer:=value;
  finally
    Internalunlock;
  end;
end;}

function TNodeInfo.Get_Name:AnsiString;
begin
  Internallock;
  try
    result:=FName;
  finally
    Internalunlock;
  end; 
end;

procedure TNodeInfo.Set_Name(const value:AnsiString);
begin
  Internallock;
  try
    FName:=value;
  finally
    Internalunlock;
  end;
end;

function TNodeInfo.Get_SName:AnsiString;
begin
  Internallock;
  try
    result:=FSName;
  finally
    Internalunlock;
  end; 
end;

procedure TNodeInfo.Set_SName(const value:AnsiString);
begin
  Internallock;
  try
    FSName:=value;
  finally
    Internalunlock;
  end;
end;

function TNodeInfo.Get_Commentary:AnsiString;
begin
  Internallock;
  try
    result:=FCommentary;
  finally
    Internalunlock;
  end; 
end;

procedure TNodeInfo.Set_Commentary(const value:AnsiString);
begin
  Internallock;
  try
    FCommentary:=value;
  finally
    Internalunlock;
  end;
end;

function TNodeInfo.Get_Address:AnsiString;
begin
  Internallock;
  try
    result:=FAddress;
  finally
    Internalunlock;
  end;
end;

procedure TNodeInfo.Set_Address(const value:AnsiString);
begin
  Internallock;
  try
    FAddress:=value;
  finally
    Internalunlock;
  end;
end;

function TNodeInfo.Get_Phone:AnsiString;
begin
  Internallock;
  try
    result:=FPhone;
  finally
    Internalunlock;
  end;
end;

procedure TNodeInfo.Set_Phone(const value:AnsiString);
begin
  Internallock;
  try
    FPhone:=value;
  finally
    Internalunlock;
  end;
end;

function TNodeInfo.Get_CardLetter:AnsiString;
begin
  Internallock;
  try
    result:=FCardLetter;
  finally
    Internalunlock;
  end;
end;

procedure TNodeInfo.Set_CardLetter(const value:AnsiString);
begin
  Internallock;
  try
    FCardLetter:=value;
  finally
    Internalunlock;
  end;
end;

procedure TNodeInfo.InternalInit;
{$IFDEF PegasServer}
  //tmpLocalDataBase.OpenSQL('SELECT ServerADMGroupName FROM ssPegasServerConfig');
  //If tmpLocalDataBase.DataSet.RecordCount<>1 Then Raise Exception.Create('Неправильные данные в БД отсутствуют(ssPegasServerConfig).');
begin
{$ELSE}
  Var tmpLocalDataBase:ILocalDataBase;
begin
  tmpLocalDataBase:=TLocalDataBase.Create;
  tmpLocalDataBase.CallerAction:=cnServerAction;
  tmpLocalDataBase.CheckSecuretyLDB:=False;
  tmpLocalDataBase.CheckForTriggers:=False;
  tmpLocalDataBase.OpenSQL('SELECT ServerID,'+{Ver,}'ServerIDBor1a,'+{ServerADMGroupName,}'ShopName,ShopSName,Address,Phone,Commentary,ShopCardLetter FROM ssInternalConfig');
  If tmpLocalDataBase.DataSet.RecordCount<>1 Then Raise Exception.Create('Неправильные данные в ЛБД отсутствуют(ssInternalConfig).');
  FID:=tmpLocalDataBase.DataSet.FieldByName('ServerID').AsInteger;
  FServerIDBor1a:=tmpLocalDataBase.DataSet.FieldByName('ServerIDBor1a').AsInteger;
  //FLDBVer:=tmpLocalDataBase.DataSet.FieldByName('Ver').AsInteger;
  //vlEAMServerLocalBaseCNNBor1a:=tmpLocalDataBase.DataSet.FieldByName('CNNBor1a').AsString;?
  //vlEAMServerLocalBaseIDDK:=tmpLocalDataBase.DataSet.FieldByName('ServerIDDK').AsInteger;?
  //vlEAMServerLocalBaseNumDK:=tmpLocalDataBase.DataSet.FieldByName('ServerNumDK').AsInteger;?
  FName:=tmpLocalDataBase.DataSet.FieldByName('ShopName').AsString;
  FSName:=tmpLocalDataBase.DataSet.FieldByName('ShopSName').AsString;
  FCommentary:=tmpLocalDataBase.DataSet.FieldByName('Commentary').AsString;
  FAddress:=tmpLocalDataBase.DataSet.FieldByName('Address').AsString;
  FPhone:=tmpLocalDataBase.DataSet.FieldByName('Phone').AsString;
  FCardLetter:=tmpLocalDataBase.DataSet.FieldByName('ShopCardLetter').AsString;
{$Endif}
  //FADMGroupName:=tmpLocalDataBase.DataSet.FieldByName('ServerADMGroupName').AsString;
  //If FADMGroupName='' Then Raise Exception.Create('ServerADMGroupName=''''.');
end;

{function TNodeInfo.Get_ADMGroupName:AnsiString;
begin
  InternalLock;
  try
    result:=FADMGroupName;
  finally
    InternalUnlock;
  end;
end;

Procedure TNodeInfo.Set_ADMGroupName(const value:AnsiString);
begin
  InternalLock;
  try
    FADMGroupName:=value;
  finally
    InternalUnlock;
  end;
end;}

end.
