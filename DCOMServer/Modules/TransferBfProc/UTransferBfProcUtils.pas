unit UTransferBfProcUtils;

interface
  uses DTask_TLB;

  function DownloadBfParamToVariant(const aDCTask:IDCTask; const aBfGUID:TGUID; const aTransferResponder, aPath, aFileName:AnsiString):Variant;
  procedure VariantToDownloadBfParam(const aParam:Variant; out aDCTask:IDCTask; out aBfGUID:TGUID; out aTransferResponder, aPath, aFileName:AnsiString);

implementation
  uses Variants, UErrorConsts, SysUtils, UTypeUtils;

function DownloadBfParamToVariant(const aDCTask:IDCTask; const aBfGUID:TGUID; const aTransferResponder, aPath, aFileName:AnsiString):Variant;
  function localIDCTaskToVariant(const aDCTask:IDCTask):Variant;begin
    if assigned(aDCTask) then result:=aDCTask else result:=unassigned;
  end;
begin
  result:=VarArrayOf([localIDCTaskToVariant(aDCTask), GUIDToVariant(aBfGUID), aTransferResponder, aPath, aFileName]);
end;

procedure VariantToDownloadBfParam(const aParam:Variant; out aDCTask:IDCTask; out aBfGUID:TGUID; out aTransferResponder, aPath, aFileName:AnsiString);
  var tmpIDispatch:IDispatch;
begin
  if not VarIsEmpty(aParam[0]) then begin
    tmpIDispatch:=aParam[0];
    if not assigned(tmpIDispatch) then raise exception.createFmtHelp(cserInternalError, ['tmpIDispatch not assigned'], cnerInternalError);
    if tmpIDispatch.QueryInterface(IDCTask, aDCTask)<>S_OK then raise exception.createFmtHelp(cserInternalError, ['IDCTask no found'], cnerInternalError);
    if not assigned(aDCTask) then raise exception.createFmtHelp(cserInternalError, ['aDCTask not assigned'], cnerInternalError);
  end else aDCTask:=nil;
  aBfGUID:=VariantToGUID(aParam[1]);
  aTransferResponder:=aParam[2];
  aPath:=aParam[3];
  aFileName:=aParam[4];
end;

end.
