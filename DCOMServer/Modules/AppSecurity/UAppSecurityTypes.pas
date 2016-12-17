unit UAppSecurityTypes;

interface
  uses UADMTypes, UTTaskTypes;
type
  IAppSecurity=interface
  ['{85D6D91A-15BE-4C62-AA3C-BC82EA6F2F22}']
    Procedure ITReloadSecurety;
    Procedure ITCheckSecurityLDB(Const aTables, aSecurityContext:Variant);
    Procedure ITCheckSecurityMTask(aMTask:TTask; Const aSecurityContext:Variant);
    Procedure ITCheckSecurityPTask(aPTask:TADMTask; Const aSecurityContext:Variant);
  end;


implementation

end.
