//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTransferDocManagesSvr;
  Модуль нормальный, но технология устарела. см. TransferDoc/TransferDocs/TransferDocManage/TransferBf
interface
  uses UTransferDocManages, UCallerTypes, UTransferDocManageTypes;
type
  TTransferDocManagesSrv=class(TTransferDocManages)
    function CreateInstance(aCallerAction:ICallerAction):ITransferDocManage;override;
  end;

implementation
  uses UTransferDocManageSrv;

function TTransferDocManagesSrv.CreateInstance(aCallerAction:ICallerAction):ITransferDocManage;
begin
  result:=TTransferDocManageSrv.Create(Self, aCallerAction);
end;

end.
