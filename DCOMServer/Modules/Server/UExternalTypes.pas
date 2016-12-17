unit UExternalTypes;
{$Ifndef PegasServer}{$Ifndef EAMServer}{$Ifndef ESClient}����������� Defines EAMServer ��� PegasServer ��� Client.{$endif}{$endif}{$endif}
{$Ifdef PegasServer}{$Ifdef EAMServer}��������� Defines EAMServer � PegasServer.{$endif}{$Ifdef ESClient}��������� Defines PegasServer � Client.{$endif}{$endif}
{$Ifdef EAMServer}{$Ifdef ESClient}��������� Defines EAMServer � Client.{$endif}{$endif}
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
