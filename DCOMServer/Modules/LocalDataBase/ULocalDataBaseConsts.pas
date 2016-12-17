unit ULocalDataBaseConsts;
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

Const
  vlLocalDataType:Integer=0;                       //0 - Ado, 1 - Bde.
  stLocalDataBaseConnectionString:AnsiString=''; //Ado - connection to LDB
  stLocalDataBaseName:AnsiString = '';             //Bde
  //..
  vlCheckSecuretyLDB:Boolean=True;
{$IFDEF PegasServer}
  vlTableAutoLock:Boolean=False;
{$endif}
{$IFDEF EAMServer}
  vlTableAutoLock:Boolean=True;
{$ENDIF}
  vlCheckForTriggers:Boolean=True;
  vlIgnoreErrorsInSQLParser:Boolean=False;

implementation

end.
