unit UConfigureDMTaskTypes;
//Copyright © 2000-2003 by Dmitry A. Sokolyuk
interface
  uses UDMTaskLocalTypes;
type
  IConfigureDMTask=interface
  ['{28667376-B9AD-4611-BF32-4C3C819CD51D}']
    function GetDMTaskLocal:IDMTaskLocal;
    procedure SetDMTaskLocal(aDMTaskLocal:IDMTaskLocal);
    property DMTaskLocal:IDMTaskLocal read GetDMTaskLocal write SetDMTaskLocal;
  end;

implementation

end.
