unit UTransferConsts;

interface
const cnTransferSize:Integer={1500}{7000}{22000}30000;
      cnTransferLockWait:Integer=7000{7sec};
      cnTransferMaxErrorCount:Integer=90{100};
      cnWaitForRespondInterval:Integer=300000{5min}{180000}{3min};
      cnWaitServerDownloadInactivety:Integer=180000{3min};
      cnTransferErrorResendInterval:Integer=20000{20sec};
      cnIntervalCheckTransfer:Integer=5000{5sec};
      csllTransfer:AnsiString='<Transfer>=';
      csllTransferDownloadClient:AnsiString='<TransferDownloadClien>=';
      csllTransferDownloadServer:AnsiString='<TransferDownloadServer>=';
      //Errors. See unit UErrorConsts
      cnerDiffIdBase:Integer=400;    //
      cnerChecksumError:Integer=401; //Use in InternalEndUploadBf, InternalWriteBf
      cnerInvalidTransferName:Integer=402; //Happens if tansfername is empty.
      cnerTransferNameAlreadyUsed:Integer=403;
      cnerTransferingBroken:Integer=404;
      cnerNearOperationTransfer:Integer=405;
      cnerInvalidIdBase:Integer=406;
      cnerPastSequenceNumber:Integer=407;
      cnerTransferInternalFatal:Integer=408;
      cnerAlreadyUsedWithAnotherPath:Integer=409;
      cnerWrongModeOfTransfer:Integer=410;
      cnerWrongStepOfTransfer:Integer=411;
      cnerTransferIsCanceled:Integer=412;
      cnerBfNameNotExists:Integer=413;
      cnerCantDownloadDuringTransfer:Integer=414;
      cnerOtherValuePosExpected:Integer=415;
      cnerUnableSetLock:Integer=416;
resourcestring
      cserChecksumError='Checksum error.';
      cserInvalidTransferName='Invalid TransferName(''%s'').';
      cserTransferNameAlreadyUsed='This TransferName(''%s'') is already used.';
      cserTransferingBroken='Transfering(''%s'') did not begin or broken.';
      cserInvalidBfName='Invalid value BfName for #%s.';
      cserPastSequenceNumber='Such SequenceNumber(%u>%u) has already passed.';
      cserTransferInternalFatal='Transfer internal fatal error: ''%s''. Contact the developers 728-77-11.';
      cserImpossiblyToKeepOnDownload='Impossibly to keep on download.';
      cserAlreadyUsedWithAnotherPath='Already used with another Path and/or FileName.';
      cserWrongModeOfTransfer='Wrong mode of transfer.';
      cserWrongStepOfTransfer='Wrong step of transfer.';
      cserTransferIsCanceled='Transfer is canceled.';
      cserBfNameNotExists='Bf ''%s'' not exists.';
      cserCantDownloadDuringTransfer='Can''t download #%s because that during transfer.';
      cserOtherValuePosExpected='Other value transferpos is expected=%u(present=%u).';
      cserUnableSetLock='Unable to set lock. Such transfer #%s already exists.';
      cserKeepOnDownloadIsCanceledErrorOccured='Keep on download is canceled. Error occured: %s/HC=%d.';

implementation

end.
