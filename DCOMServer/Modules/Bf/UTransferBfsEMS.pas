unit UTransferBfsEMS;
  ћодуль нормальный, но технологи€ устарела. см. TransferDoc/TransferDocs/TransferDocManage/TransferBf
interface
  uses UTransferBfsTable;
Type
  TTransferBfsEMS=class(TTransferBfsTable)
    function InternalCheckResponderNameForDownload(const aResponderName, aConnectionName:AnsiString):AnsiString;override;
  End;

implementation
  uses UNodeNameConsts;

function TTransferBfsEMS.InternalCheckResponderNameForDownload(const aResponderName, aConnectionName:AnsiString):AnsiString;
begin
  If aResponderName='' Then Result:=csNodePGS else Result:=aResponderName;
end;

end.
