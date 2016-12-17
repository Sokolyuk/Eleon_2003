unit UConfigureDCTaskTypes;
//Copyright © 2000-2003 by Dmitry A. Sokolyuk
interface
  uses UDCTaskLocalTypes;
type
  IConfigureDCTask=interface
  ['{14C195EE-553B-439A-BE7A-563CA0C514C1}']
    function GetDCTaskLocal:IDCTaskLocal;
    procedure SetDCTaskLocal(aDCTaskLocal:IDCTaskLocal);
    property DCTaskLocal:IDCTaskLocal read GetDCTaskLocal write SetDCTaskLocal;
  end;

implementation

end.
