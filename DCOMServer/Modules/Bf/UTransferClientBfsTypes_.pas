unit UTransferClientBfsTypes;

interface
  uses UTransferBlobfilesTypes, UCallerTypes, UBlobfileTypes, ULocalDataDepotTypes;
type
  ITransferClientBlobfiles=interface(ITransferBlobfiles)
  ['{E2EF3ED5-ACA0-4954-9918-B1C7917A8494}']
    Function ITAddTransferParaDownload(aCallerAction:ICallerAction; Const aConnectionName:AnsiString; aIdBase:Integer; aTransferAuto:Boolean; aPTransferProcessEvents:PTransferProcessEvents=Nil; Const aTransferName:AnsiString=''; aFileDate:TDateTime=0; aLocalDataDepot:ILocalDataDepot=nil):AnsiString;
    Function ITReceiveAddParaDownloadBlobfile(Const aSenderTransferName:AnsiString;
                                              Const aOldTransferName:AnsiString;
                                              Const aNewTransferName:AnsiString;
                                              aTransferFrom:TTransferFrom;
                                              aLocalDataDepot:ILocalDataDepot=nil):Boolean{worked};
    Function ITReceiveBeginParaDownloadBlobfile(Const aSenderTransferName:AnsiString;
                                                aTransferSize:Cardinal;
                                                aLocalDataDepot:ILocalDataDepot=nil):Boolean{worked};
    Function ITReceiveProcessParaDownloadBlobfile(Const aSenderTransferName:AnsiString;
                                                  aTransferedSize:Cardinal;
                                                  aTransferErrorCount:Integer;
                                                  aTransferSpeed:double):Boolean{worked};
    Function ITReceiveCompleteParaDownloadBlobfile(Const aSenderTransferName:AnsiString;
                                                  aIdLocal:Integer;
                                                  aTransferedSize:Cardinal;
                                                  aTransferErrorCount:Integer;
                                                  aTransferSpeed:double):Boolean{worked};
    Function ITReceiveErrorParaDownloadBlobfile(Const aSenderTransferName,
                                                aErrorMessage:AnsiString;
                                                aHelpContext:Integer;
                                                aCanceled:Boolean;
                                                aTransferedSize:Cardinal;
                                                aTransferErrorCount:Integer;
                                                aTransferSpeed:double):Boolean{worked};
  end;
implementation
end.
