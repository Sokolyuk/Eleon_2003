//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTransferDocUtils;

interface
  uses DTask_TLB;
  procedure VariantToTransferDocParam(const aParam:variant; out aDocGuid:TGuid; out aWhereNodeDoc:AnsiString; out aiddcDocsAutoTransfer:Variant; out aidssUserAutoTransfer:variant; out aDCTask:IDCTask);
  function TransferDocParamToVariant(const aDocGuid:TGuid; const aWhereNodeDoc:AnsiString; aPiddcDocsAutoTransfer:PInteger; aPidssUserAutoTransfer:PInteger; const aDCTask:IDCTask):variant;

implementation
  uses Variants, UErrorConsts, SysUtils, UTypeUtils;

procedure VariantToTransferDocParam(const aParam:variant; out aDocGuid:TGuid; out aWhereNodeDoc:AnsiString; out aiddcDocsAutoTransfer:Variant; out aidssUserAutoTransfer:variant; out aDCTask:IDCTask);
  function VariantToIDCTask(const alVariant:variant):IDCTask;
    var tmplIDispatch:IDispatch;
  begin
    if not VarIsEmpty(alVariant) then begin
      tmplIDispatch:=alVariant;
      if not assigned(tmplIDispatch) then raise exception.createFmtHelp(cserInternalError, ['tmplIDispatch not assigned'], cnerInternalError);
      if tmplIDispatch.QueryInterface(IDCTask, result)<>S_OK then raise exception.createFmtHelp(cserInternalError, ['IDCTask no found'], cnerInternalError);
      if not assigned(result) then raise exception.createFmtHelp(cserInternalError, ['aDCTask not assigned'], cnerInternalError);
    end else result:=nil;
  end;
  var tmpHB:integer;
begin
  tmpHB:=VarArrayHighBound(aParam, 1);
  if tmpHB=4 then begin
    aDocGuid:=VariantToGuid(aParam[0]);
    aWhereNodeDoc:=aParam[1];
    aiddcDocsAutoTransfer:=aParam[2];
    aidssUserAutoTransfer:=aParam[3];
    VariantToIDCTask(aParam[4]);
  end else if tmpHB=3 then begin
    if not VarIsArray(aParam[0]) then begin
      aDocGuid:=VariantToGuid(aParam);
      aWhereNodeDoc:='';
      aiddcDocsAutoTransfer:=unassigned;
      aidssUserAutoTransfer:=unassigned;
      aDCTask:=nil;
    end else begin
      aDocGuid:=VariantToGuid(aParam[0]);
      aWhereNodeDoc:=aParam[1];
      aiddcDocsAutoTransfer:=aParam[2];
      aidssUserAutoTransfer:=aParam[3];
      aDCTask:=nil;
    end;
  end else if tmpHB=1 then begin
    aDocGuid:=VariantToGuid(aParam[0]);
    aWhereNodeDoc:=aParam[1];
    aiddcDocsAutoTransfer:=unassigned;
    aidssUserAutoTransfer:=unassigned;
    aDCTask:=nil;
  end else if tmpHB=2 then begin
    aDocGuid:=VariantToGuid(aParam[0]);
    aWhereNodeDoc:=aParam[1];
    aiddcDocsAutoTransfer:=aParam[2];
    aidssUserAutoTransfer:=unassigned;
    aDCTask:=nil;
  end else raise exception.createFmtHelp(cserInternalError, ['Invalid count of params('+IntToStr(tmpHB)+')'], cnerInternalError);
end;

function TransferDocParamToVariant(const aDocGuid:TGuid; const aWhereNodeDoc:AnsiString; aPiddcDocsAutoTransfer:PInteger; aPidssUserAutoTransfer:PInteger; const aDCTask:IDCTask):variant;
  function localIDCTaskToVariant(const aDCTask:IDCTask):Variant;begin
    if assigned(aDCTask) then result:=aDCTask else result:=unassigned;
  end;
  function localaPiddcDocsAutoTransferToVariant:variant;begin
    if assigned(aPiddcDocsAutoTransfer) then result:=aPiddcDocsAutoTransfer^ else result:=unassigned;
  end;
  function localaPidssUserAutoTransferToVariant:variant;begin
    if assigned(aPidssUserAutoTransfer) then result:=aPidssUserAutoTransfer^ else result:=unassigned;
  end;
begin
  if assigned(aDCTask) then begin
    result:=VarArrayOf([GuidToVariant(aDocGuid), aWhereNodeDoc, localaPiddcDocsAutoTransferToVariant, localaPidssUserAutoTransferToVariant, aDCTask]);
  end else begin
    if assigned(aPidssUserAutoTransfer) then begin
      result:=VarArrayOf([GuidToVariant(aDocGuid), aWhereNodeDoc, localaPiddcDocsAutoTransferToVariant, localaPidssUserAutoTransferToVariant]);
    end else begin
      if assigned(aPiddcDocsAutoTransfer) then begin
        result:=VarArrayOf([GuidToVariant(aDocGuid), aWhereNodeDoc, localaPiddcDocsAutoTransferToVariant]);
      end else begin
        if aWhereNodeDoc='' then begin
          result:=GuidToVariant(aDocGuid);
        end else begin
          result:=VarArrayOf([GuidToVariant(aDocGuid), aWhereNodeDoc]);
        end;
      end;
    end;
  end;
end;

end.
