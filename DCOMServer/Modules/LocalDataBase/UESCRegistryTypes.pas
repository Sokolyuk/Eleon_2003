unit UESCRegistryTypes;

interface
  uses Registry;
type
  IESCRegistry=interface
  ['{EE4AD207-EDD6-412D-BCF3-F5FDC225B347}']
    function Get_Registry:TRegistry;
    property Registry:TRegistry read Get_Registry;
  end;
  
implementation

end.
