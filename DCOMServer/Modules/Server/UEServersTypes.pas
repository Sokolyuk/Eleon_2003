unit UEServersTypes;

interface
  Uses UEServersListTypes;
Type
  IEServers=Interface
  ['{2A25910B-801D-43A3-A45B-BDEDFBE9CE96}']
    Function IT_GetEServersList:IEServersList;
    Procedure ITCheck;
    Property ITEServersList:IEServersList Read IT_GetEServersList;
  end;

implementation

end.
