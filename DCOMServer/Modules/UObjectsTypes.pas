//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UObjectsTypes;

interface
type
  IITObject=Interface
  ['{B7FD9CB7-7F62-4BA7-BD08-D8A88BCF1AFC}']
    Procedure ITLock;
    Procedure ITLockWait(aWait:Integer);
    Function ITTryLock:Boolean{success};
    Procedure ITUnlock;
  end; 

implementation

end.
