unit UServerConsts;
???
{$i ServerType.inc}
{$Ifndef ServerType}
   ServerType.inc не найден
{$endif}
{$Ifndef PegasServer}
  {$Ifndef EAMServer}
    {$Ifndef ESClient}
      Неназначены Defines EAMServer или PegasServer или Client.
    {$endif}
  {$endif}
{$endif}
{$Ifdef PegasServer}
  {$Ifdef EAMServer}
    Назначены Defines EAMServer и PegasServer.
  {$endif}
  {$Ifdef ESClient}
    Назначены Defines PegasServer и Client.
  {$endif}
{$endif}
{$Ifdef EAMServer}
  {$Ifdef ESClient}
    Назначены Defines EAMServer и Client.
  {$endif}
{$endif}

interface
  Uses UCallerTypes, Comobj, Messages;
Var
  ServerCallerAction:ICallerAction=Nil;
  // Server proc Dll
  vPossibleDllVersion:Integer=1;
  // Factory
  GL_AOF_ASM:TAutoObjectFactory=Nil;
  GL_AOF_EDC:TAutoObjectFactory=Nil;
  GL_AOF_ELDB:TAutoObjectFactory=Nil;
{$IFDEF EAMServer}
  //vlSecurityReliableCounter:integer=0;
  stEComputerName:AnsiString=''; //Имя компьютера с Pegasom
  stEComputerGUID:AnsiString='';
  //..
  vlEAMServerLocalBaseVer   : Integer = -1;
  vlEAMServerLocalBaseServerIDBor1a:Integer=-1;
  vlEAMServerLocalBaseCNNBor1a:AnsiString='';
  vlEAMServerLocalBaseID    : Integer = -1;
  vlEAMServerLocalBaseIDDK:Integer=-1;
  vlEAMServerLocalBaseNumDK:Integer=-1;
  stShopName    :AnsiString='';
  stShopSName   :AnsiString='';
  stCommentary  :AnsiString='';
  stAddress     :AnsiString='';
  stPhone       :AnsiString='';
  stShopCardLetter :AnsiString='';
{$ENDIF}
  vlServerADMGroupName:AnsiString='';
  vlThreadingModel:TThreadingModel=tmFree;  //Потокова модель приложения
  //..
  // Идентификатор задания в Mate
  GL_TaskID_MessToLog    :integer = -1;
{$IFDEF PegasServer}
  GL_TaskID_GetSQLCommandFromPegas : integer = -1;
{$ENDIF}
  //..
{$IFDEF PegasServer}
  // Pegas
  stServerUserName  :AnsiString = 'SRV_PGS';
  stServerActionName:AnsiString = 'PGS';
{$endif}
{$IFDEF EAMServer}
  // M-Server
  stServerUserName  :AnsiString = 'SRV_EMS';
  stServerActionName:AnsiString = 'EMS';
{$ENDIF}
  // Statistics - Class
  vlStatisticMessCountClassSQL : Integer = 0;   // Всего сообщений SQL
  vlStatisticMessCountClassApp : Integer = 0;  // Всего сообщений App
  vlStatisticMessCountClassDebug : Integer = 0;  // Всего сообщений Debug
  vlStatisticMessCountClassSecurity : Integer = 0;  // Всего сообщений Security
  // Statistics - Type
  vlStatisticMessCountTypeInfo : Integer = 0;   // Всего сообщений Info
  vlStatisticMessCountTypeError : Integer = 0;  // Всего сообщений Error
  vlStatisticMessCountTypeWarning : Integer = 0;  // Всего сообщений Warning
  vlAppStabilityMessCountMax : Integer = 200;     // буфер
{$IFDEF PegasServer}
  stProgramName           : AnsiString = 'Pegas';
  stProgramDescription    : AnsiString = 'Промежуточный DCom сервер(''Pegas'').'#13#10'Dmitry A. Sokolyuk(sokoluyk@yahoo.com) KS'#13#10'10/04/01'#13#10'Игнорируется повторный ELogin.'#13#10'Поддержра Multi-GUID.';
{$Endif}
{$IFDEF EAMServer}
  stProgramName           : AnsiString = 'EAMServer';
  stProgramDescription    : AnsiString = 'Промежуточный DCom сервер(''EMServer'').'#13#10'Dmitry A. Sokolyuk(sokoluyk@yahoo.com) KS'#13#10'10/04/01'#13#10'Игнорируется повторный ELogin.'#13#10'Поддержра Multi-GUID.';
{$ENDIF}
  GL_Log_Longint:Longint=0;
  glProcessID{gFormHandle}:LongWord=0;
  stServerRegName      :AnsiString = '';
{$IFDEF PegasServer}
  stConnectionString : AnsiString = '';                         // Имя компьютера с Pegasom
  stFieldNameGroupName : AnsiString ='GroupName';
{$ENDIF}

Var
  CallerCreateCount:Integer=0;
  
implementation

end.
