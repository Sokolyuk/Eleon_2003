//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit ULocalDataBasesTypes;

interface
  uses ULocalDataBaseTypes;
type
  ILocalDataBases=interface
  ['{A081E7D2-D4B2-4033-93D0-06BDD5F35935}']
    function CreateInstance:ILocalDataBase;
  end;

implementation

end.
