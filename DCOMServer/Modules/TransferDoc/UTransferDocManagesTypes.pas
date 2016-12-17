//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTransferDocManagesTypes;
  Модуль нормальный, но технология устарела. см. TransferDoc/TransferDocs/TransferDocManage/TransferBf
interface
  uses UTransferDocManageTypes, UCallerTypes;
type  
  ITransferDocManages=interface
  ['{0FE0F1C2-58BA-48D7-9E4E-56E36AA9F5A8}']
    function CreateInstance(aCallerAction:ICallerAction):ITransferDocManage;
    function CheckStateAsTrayForWork(aRaise:boolean):boolean;
  end;
implementation

end.
