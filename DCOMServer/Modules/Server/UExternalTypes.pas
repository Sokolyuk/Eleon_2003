unit UExternalTypes;
{$Ifndef PegasServer}{$Ifndef EAMServer}{$Ifndef ESClient}Неназначены Defines EAMServer или PegasServer или Client.{$endif}{$endif}{$endif}
{$Ifdef PegasServer}{$Ifdef EAMServer}Назначены Defines EAMServer и PegasServer.{$endif}{$Ifdef ESClient}Назначены Defines PegasServer и Client.{$endif}{$endif}
{$Ifdef EAMServer}{$Ifdef ESClient}Назначены Defines EAMServer и Client.{$endif}{$endif}
interface
  Uses UExternalDataCase, UExternalLocalDataBase;
  Type
{$IFDEF EAMServer}
    TExternalDataCase11=TExternalEmDataCase;
    TExternalLocalDataBase11=TExternalEmLocalDataBase;
{$ENDIF}
{$IFDEF PegasServer}
    TExternalDataCase11=TExternalPgDataCase;
    TExternalLocalDataBase11=TExternalPgLocalDataBase;
{$ENDIF}


implementation

end.
