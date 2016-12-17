//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UCallerTaskPathTypes;

interface
  uses UCallerTaskTypes;
type
  ICallerTaskPath=interface
  ['{FCF4919D-9A61-4C71-B91B-9E8E43112674}']
    procedure Set_First(value:ICallerTask);
    function Get_First:ICallerTask;
    procedure Set_Prev(value:ICallerTask);
    function Get_Prev:ICallerTask;
    property First:ICallerTask read Get_First write Set_First;
    property Prev:ICallerTask read Get_Prev write Set_Prev;
  end;

implementation

end.
