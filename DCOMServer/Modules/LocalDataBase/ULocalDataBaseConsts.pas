unit ULocalDataBaseConsts;
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
