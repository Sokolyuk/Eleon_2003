unit UTransferBfsPGS;

interface
  Uses UTransferBfsTable;
Type
  TTransferBfsPGS=class(TTransferBfsTable)
    function InternalCheckResponderNameForDownload(const aResponderName, aConnectionName:AnsiString):AnsiString;override;
  End;

implementation
  uses UNodeNameConsts, Sysutils;

function TTransferBfsPGS.InternalCheckResponderNameForDownload(const aResponderName, aConnectionName:AnsiString):AnsiString;
begin
  if aResponderName='' then raise exception.create('On pegas aResponderName for download can''t be empty.') else Result:=aResponderName;
end;

end.
