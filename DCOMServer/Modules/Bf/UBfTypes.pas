unit UBfTypes;

interface
type
  {TBfInfo=record
    FileName:AnsiString;
    Date:TDateTime;
    TotalSize:Cardinal;
  end;}
  //..
  TBfTransfer=record
    Pos:Cardinal;
    TransferSize:Cardinal;
    CheckSum:Integer;
  end;
  //..
  TTransferDirection=(trdDownloadClient{0 или Null}, trdUploadClient{1}, trdUploadServer{2});
  //..
  PTableBfInfo=^TTableBfInfo;
  TTableBfInfo=record
    Path:AnsiString;
    Filename:AnsiString;
    Checksum:Integer;
    ChecksumDate:TDateTime;
    BfType:Integer;
    TransferSchedule:AnsiString;
    Commentary:AnsiString;
    //ssBfTransfering
    Transfering:Boolean;//Exists registry key or SELECT * FROM ssBfTransfer WHERE BfName='xx'            
    TransferPos:Cardinal;
    TransferChecksum:Integer;
    TransferResponder:AnsiString;
    TransferDirection:TTransferDirection;
  end;
  //..
  PTBfInfoBeginDownload=^TTBfInfoBeginDownload;
  TTBfInfoBeginDownload=record
    Path:AnsiString;{1}
    Filename:AnsiString;{1}
    Checksum:Integer;{1}
    ChecksumDate:TDateTime;{1}
    BfType:Integer;
    TransferSchedule:AnsiString;
    TotalSize:Cardinal;
    Commentary:AnsiString;{1}
  end;
  //..
  PTBfTransferInfo=^TTBfTransferInfo;
  TTBfTransferInfo=record
    TransferPos:Cardinal;
    TransferChecksum:Integer;
  end;
  //..
  TBfFileinfo=record
    Date:TDateTime;
    TotalSize:Cardinal;
  end;
  //..
  TTransferStyle=(trlNew, trlOverride);
  //..
  TTransferFrom=(trfClientMachine, trfLocalServer, trfFarServer);
  TSetResultStatus=({0}{srsAddDownload, {1}srsBeginDownload, {2}srsProcessDownload, {3}srsCompleteDownload, {4}srsErrorTransfer, srsTerminateTransfer);
  //TTransferResultCode=(trcOk{0}, trcTerminate{1});aTransferResultCode:TTransferResultCode; 
  //..
  //TAddTransferEvent=function(aUserData:Pointer; const aBfName:AnsiString):Boolean of object;//{; const aNewTransferName:AnsiString}
  TBeginTransferEvent=function(aUserData:Pointer; aTransferBf:IUnknown; const aBfName:AnsiString; aFileTotalSize:Cardinal):Boolean of object;
  TProcessTransferEvent=function(aUserData:Pointer; aTransferBf:IUnknown; const aBfName:AnsiString; aTransferedSize:Cardinal; aTransferErrorCount:Integer; aTransferSpeed:double):boolean of object;
  TCompleteTransferEvent=function(aUserData:Pointer; aTransferBf:IUnknown; const aBfName:AnsiString; aTransferErrorCount:Integer; aTransferSpeed:double; const aBfPath:AnsiString; const aCommentary:AnsiString):boolean of object;
  TErrorTransferEvent=function(aUserData:Pointer; aTransferBf:IUnknown; const aBfName:AnsiString; const aMessage:AnsiString; aHelpContext:Integer; aCanceled:Boolean; aTransferErrorCount:Integer):boolean of object;
  //..
  PTransferProcessEvents=^TTransferProcessEvents;
  TTransferProcessEvents=record
    UserData:Pointer;
    //OnAddTransfer:TAddTransferEvent;
    OnBeginTransfer:TBeginTransferEvent;
    OnProcessTransfer:TProcessTransferEvent;
    OnCompleteTransfer:TCompleteTransferEvent;
    OnErrorTransfer:TErrorTransferEvent;
  end;

  {OnBegin(aParam:PVariant);
  OnProcess(aParam:PVariant);
  OnProcessError(aParam:PVariant; const aMessage:AnsiString; aHelpContext:Integer);
  OnEndOk(aResultCode:TResultCode);
  OnEndError(const aMessage:AnsiString; aHelpContext:Integer);}


  PUseTransferEvents=^TUseTransferEvents;
  TUseTransferEvents=record
    tpToSender:boolean;//send events via pack
    UserData:pointer;//user data
    OnCompleteTransfer:TCompleteTransferEvent;//send OnCompleteTransfer.
  end;

  PTransferParam=^TTransferParam;
  TTransferParam=record
    TransferAuto:boolean;
    TransferProcessToSender:boolean;
    TransferResponder{ResponderName}:AnsiString;
    Path:AnsiString;
    FileName:AnsiString;
  end;

const
  cnTransferParam:TTransferParam=(TransferAuto:True; TransferProcessToSender:True; TransferResponder:'';{TransferFrom:trfFarServer; CheckLocalAccessible:True;} Path:''; FileName:'');

implementation

end.
