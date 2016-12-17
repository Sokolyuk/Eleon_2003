unit UTransferBfsUtils;
  ћодуль нормальный, но технологи€ устарела. см. TransferDoc/TransferDocs/TransferDocManage/TransferBf
interface
  uses UBfTypes;

  procedure VariantToSendPackBeginDownload(const aVariant:Variant; out aBfName, aResponderTransferName:AnsiString; out aTotalSize:Cardinal);
  function SendPackBeginDownloadToVariant(const aBfName, aResponderTransferName:AnsiString; aTotalSize:Cardinal):Variant;
  procedure VariantToSendPackProcessDownload(const aVariant:Variant; out aBfName:AnsiString; out aTransferPos:Cardinal; out aTransferErrorCount:Integer; out aTransferSpeed:double);
  function SendPackProcessDownloadToVariant(const aBfName:AnsiString; aTransferPos:Cardinal; aTransferErrorCount:Integer; aTransferSpeed:double):Variant;
  procedure VariantToSendPackCompleteDownload(const aVariant:Variant; out aBfName:AnsiString; out aTransferErrorCount:Integer; out aTransferSpeed:double);
  function SendPackCompleteDownloadToVariant(const aBfName:AnsiString; aTransferErrorCount:Integer; aTransferSpeed:double):Variant;
  procedure VariantToSendPackErrorTransfer(const aVariant:Variant; out aBfName:AnsiString; out aCanceled:boolean; out aTransferErrorCount:Integer);
  function SendPackErrorTransferToVariant(const aBfName:AnsiString; aCanceled:boolean; aTransferErrorCount:Integer):Variant;
  function VariantToResultStatus(const aVariant:Variant):TSetResultStatus;

implementation
  uses Sysutils{$IFDEF VER140}, Variants{$ENDIF};

function SendPackBeginDownloadToVariant(const aBfName, aResponderTransferName:AnsiString; aTotalSize:Cardinal):Variant;
begin               //0                          1        2                       3
  Result:=VarArrayOf([Integer(srsBeginDownload), aBfName, aResponderTransferName, Integer(aTotalSize)]);
end;

procedure VariantToSendPackBeginDownload(const aVariant:Variant; out aBfName, aResponderTransferName:AnsiString; out aTotalSize:Cardinal);
begin
  aBfName:=aVariant[1];
  aResponderTransferName:=aVariant[2];
  aTotalSize:=Cardinal(Integer(aVariant[3]));
end;

function SendPackProcessDownloadToVariant(const aBfName:AnsiString; aTransferPos:Cardinal; aTransferErrorCount:Integer; aTransferSpeed:double):Variant;
begin               //0                            1        2                         3                         4
  Result:=VarArrayOf([Integer(srsProcessDownload), aBfName, Integer(aTransferPos), aTransferErrorCount, aTransferSpeed]);
end;

procedure VariantToSendPackProcessDownload(const aVariant:Variant; out aBfName:AnsiString; out aTransferPos:Cardinal; out aTransferErrorCount:Integer; out aTransferSpeed:double{; out aPercent:Word});
begin
  aBfName:=aVariant[1];
  aTransferPos:=Cardinal(Integer(aVariant[2]));
  aTransferErrorCount:=aVariant[3];
  aTransferSpeed:=aVariant[4];
end;

function SendPackCompleteDownloadToVariant(const aBfName:AnsiString; aTransferErrorCount:Integer; aTransferSpeed:double):Variant;
begin               //0                             1                                    2                         3                    4
  Result:=VarArrayOf([Integer(srsCompleteDownload), aBfName, aTransferErrorCount, aTransferSpeed]);
end;

procedure VariantToSendPackCompleteDownload(const aVariant:Variant; out aBfName:AnsiString; out aTransferErrorCount:Integer; out aTransferSpeed:double);
begin
  aBfName:=aVariant[1];
  aTransferErrorCount:=aVariant[2];
  aTransferSpeed:=aVariant[3];
end;

function SendPackErrorTransferToVariant(const aBfName:AnsiString; aCanceled:boolean; aTransferErrorCount:Integer):Variant;
begin               //0                          1                                                                  2                         3                    4
  Result:=VarArrayOf([Integer(srsErrorTransfer), aBfName, aCanceled, aTransferErrorCount]);
end;

procedure VariantToSendPackErrorTransfer(const aVariant:Variant; out aBfName:AnsiString; out aCanceled:boolean; out aTransferErrorCount:Integer);
begin
  aBfName:=aVariant[1];
  aCanceled:=aVariant[2];
  aTransferErrorCount:=aVariant[3];
end;

{function SendPackAddTransferDownloadToVariant(aIdBase:Integer; aTransferFrom:TTransferFrom; const aNewDownloadBfName, aOldDownloadBfName:AnsiString):Variant;
begin               //0                        1        2              3                         4
  Result:=VarArrayOf([integer(srsAddDownload), aIdBase, aTransferFrom, aNewDownloadBfName, aOldDownloadBfName]);
end;

procedure VariantToSendPackAddTransferDownload(const aVariant:Variant; out aIdBase:Integer; out aTransferFrom:TTransferFrom; out aNewDownloadBfName, aOldDownloadBfName:AnsiString);
begin
  aIdBase:=aVariant[1];
  aTransferFrom:=TTransferFrom(Integer(aVariant[2]));
  aNewDownloadBfName:=aVariant[3];
  aOldDownloadBfName:=aVariant[4];
end;}

function VariantToResultStatus(const aVariant:Variant):TSetResultStatus;
begin
  try
    if not VarIsArray(aVariant) then raise exception.create('aVariant not array.');
    Result:=TSetResultStatus(Integer(aVariant[0]));
    case Result of
      {srsAddDownload, }srsBeginDownload, srsProcessDownload, srsCompleteDownload, srsErrorTransfer:;
    else
      Raise Exception.Create('Invalid value='+IntToStr(Integer(Result))+'.');
    end;
  except
    on e:exception do begin e.message:='VariantToResultStatus: '+e.message; raise; end;
  end
end;

end.
