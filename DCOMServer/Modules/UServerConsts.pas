unit UServerConsts;
???
{$i ServerType.inc}
{$Ifndef ServerType}
   ServerType.inc �� ������
{$endif}
{$Ifndef PegasServer}
  {$Ifndef EAMServer}
    {$Ifndef ESClient}
      ����������� Defines EAMServer ��� PegasServer ��� Client.
    {$endif}
  {$endif}
{$endif}
{$Ifdef PegasServer}
  {$Ifdef EAMServer}
    ��������� Defines EAMServer � PegasServer.
  {$endif}
  {$Ifdef ESClient}
    ��������� Defines PegasServer � Client.
  {$endif}
{$endif}
{$Ifdef EAMServer}
  {$Ifdef ESClient}
    ��������� Defines EAMServer � Client.
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
  stEComputerName:AnsiString=''; //��� ���������� � Pegasom
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
  vlThreadingModel:TThreadingModel=tmFree;  //�������� ������ ����������
  //..
  // ������������� ������� � Mate
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
  vlStatisticMessCountClassSQL : Integer = 0;   // ����� ��������� SQL
  vlStatisticMessCountClassApp : Integer = 0;  // ����� ��������� App
  vlStatisticMessCountClassDebug : Integer = 0;  // ����� ��������� Debug
  vlStatisticMessCountClassSecurity : Integer = 0;  // ����� ��������� Security
  // Statistics - Type
  vlStatisticMessCountTypeInfo : Integer = 0;   // ����� ��������� Info
  vlStatisticMessCountTypeError : Integer = 0;  // ����� ��������� Error
  vlStatisticMessCountTypeWarning : Integer = 0;  // ����� ��������� Warning
  vlAppStabilityMessCountMax : Integer = 200;     // �����
{$IFDEF PegasServer}
  stProgramName           : AnsiString = 'Pegas';
  stProgramDescription    : AnsiString = '������������� DCom ������(''Pegas'').'#13#10'Dmitry A. Sokolyuk(sokoluyk@yahoo.com) KS'#13#10'10/04/01'#13#10'������������ ��������� ELogin.'#13#10'��������� Multi-GUID.';
{$Endif}
{$IFDEF EAMServer}
  stProgramName           : AnsiString = 'EAMServer';
  stProgramDescription    : AnsiString = '������������� DCom ������(''EMServer'').'#13#10'Dmitry A. Sokolyuk(sokoluyk@yahoo.com) KS'#13#10'10/04/01'#13#10'������������ ��������� ELogin.'#13#10'��������� Multi-GUID.';
{$ENDIF}
  GL_Log_Longint:Longint=0;
  glProcessID{gFormHandle}:LongWord=0;
  stServerRegName      :AnsiString = '';
{$IFDEF PegasServer}
  stConnectionString : AnsiString = '';                         // ��� ���������� � Pegasom
  stFieldNameGroupName : AnsiString ='GroupName';
{$ENDIF}

Var
  CallerCreateCount:Integer=0;
  
implementation

end.
