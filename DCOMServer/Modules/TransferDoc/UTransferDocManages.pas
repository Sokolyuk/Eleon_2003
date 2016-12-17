//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTransferDocManages;
  Модуль нормальный, но технология устарела. см. TransferDoc/TransferDocs/TransferDocManage/TransferBf
interface
  uses UTrayInterface, UTransferDocManagesTypes, UCallerTypes, UTransferDocManageTypes;
type
  TTransferDocManages=class(TTrayInterface, ITransferDocManages)
  protected
  public
    constructor create;
    destructor destroy;override;
  public
    function CreateInstance(aCallerAction:ICallerAction):ITransferDocManage;virtual;abstract;
    function CheckStateAsTrayForWork(aRaise:boolean):boolean;virtual;
  end;

implementation
  uses UTransferDocManage;
constructor TTransferDocManages.create;
begin
  inherited create;
end;

destructor TTransferDocManages.destroy;
begin
  inherited destroy;
end;

function TTransferDocManages.CheckStateAsTrayForWork(aRaise:boolean):boolean;
begin
  result:=InternalCheckStateAsTrayForWork(aRaise);
end;

end.
