//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTransferBfsTypes;
  Модуль нормальный, но технология устарела. см. TransferDoc/TransferDocs/TransferDocManage/TransferBf
interface
  Uses UBfTypes, UPackPDPlacesTypes, UCallerTypes, UPackPDTypes, UPackTypes,
       UADMTypes, windows, UTransferBfTypes;
type
  TChecksumBuff=array[0..4095] of byte;
  ITransferBfs=Interface
  ['{83C3FEEB-A205-4D88-82B7-52678E432F39}']
    //-BaseBf
    //-BaseBfTransport
    //Информация о Bf
    function ITBfLocalExists(const aBfName:AnsiString; aCallerAction:ICallerAction; {Out}aPInfo:PTableBfInfo; aIfExistsUseEvents:PUseTransferEvents; const aConnectionName:AnsiString):boolean;
    function ITBfLocalDelete(const aBfName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString):boolean;
    //Add+Del+Edit
    procedure ITCheckTransferProcess;
    function ITTransferTerminate(const aTransferName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString):Boolean;
    function ITTransferTerminateByBfName(const aBfName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString):Boolean;
    function ITReceiveTransferTerminated(aCallerAction:ICallerAction; const aTransferName, aTerminatorSysName:AnsiString):Boolean;
    procedure ITTransportError(aCallerAction:ICallerAction; const ConnectionName:AnsiString; aPack:IPack; const aMessage:AnsiString; aHelpContext:Integer);
    //Информация о Transfers+List+Detail info of transfer.
    //-Server
    function ITBeginDownload(const aBfName:AnsiString; aCallerAction:ICallerAction; Out aTBfInfoBeginDownload:TTBfInfoBeginDownload):AnsiString{TransferName};
    procedure ITDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString; aSequenceNumber:Cardinal; Var aTransfer:TBfTransfer; Out aBf:Variant);
    procedure ITEndDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString);
    function ITTransferCancel(const aTransferName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString; aCancelResponder:Boolean{=True}):Boolean;
    //-Client
    function ITAddTransferDownload(const aBfName:AnsiString; aCallerAction:ICallerAction; const aConnectionName:AnsiString; aPTransferParam:PTransferParam{=Nil}; aPTransferProcessEvents:PTransferProcessEvents{=Nil}):AnsiString{TransferName};
    procedure ITReceiveBeginDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString; const aResponderTransferName:AnsiString; const aTBfInfoBeginDownload:TTBfInfoBeginDownload);
    procedure ITReceiveDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString; aSequenceNumber:Cardinal; aTransfer:TBfTransfer; const aBf:Variant);
    procedure ITReceiveErrorBeginDownload(aCallerAction:ICallerAction; const aTransferName, aErrorMessage:AnsiString; aHelpContext:Integer);
    procedure ITReceiveErrorDownload(aCallerAction:ICallerAction; const aTransferName, aErrorMessage:AnsiString; aHelpContext:Integer);
    function ITReceiveTransferCanceled(aCallerAction:ICallerAction; const aTransferName:AnsiString):Boolean;
  end;
  //..
(*  ITransferBfsServer=Interface(ITransferBfs)
    ['{1B911BEC-F2A0-49AF-81A9-C7C5E77E243B}']
    //-Server
    function ITBeginDownload(aIdBase:Integer; aCallerAction:ICallerAction; Out aTBfInfoBeginDownload:TTBfInfoBeginDownload):AnsiString{TransferName};
    procedure ITDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString; aSequenceNumber:Cardinal; Var aTransfer:TBfTransfer; Out aBf:Variant);
    procedure ITEndDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString);
    function ITTransferCancel(const aTransferName:AnsiString; aCallerAction:ICallerAction; aCancelResponder:Boolean{=True}):Boolean;
  end;
  //..
  ITransferBfsClient=Interface(ITransferBfs)
    ['{72823E50-CD67-44E2-ACC4-BCD798AF294E}']
    //-Client
    function ITAddTransferDownload(aIdBase:Integer; aCallerAction:ICallerAction; const aConnectionName:AnsiString; aPTransferParam:PTransferParam{=Nil}; aPTransferProcessEvents:PTransferProcessEvents{=Nil}):AnsiString{TransferName};
    procedure ITReceiveBeginDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString; const aResponderTransferName:AnsiString; const aTBfInfoBeginDownload:TTBfInfoBeginDownload);
    procedure ITReceiveDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString; aSequenceNumber:Cardinal; aTransfer:TBfTransfer; const aBf:Variant);
    procedure ITReceiveErrorBeginDownload(aCallerAction:ICallerAction; const aTransferName, aErrorMessage:AnsiString; aHelpContext:Integer);
    procedure ITReceiveErrorDownload(aCallerAction:ICallerAction; const aTransferName, aErrorMessage:AnsiString; aHelpContext:Integer);
    function ITReceiveTransferCanceled(aCallerAction:ICallerAction; const aTransferName:AnsiString):Boolean;
  end;(**)

implementation
(*    procedure ITCheckTransferProcess;
    function ITTransferCancel(const aTransferName:AnsiString; aCallerAction:ICallerAction; aCancelResponder:Boolean{=True}):Boolean;
    function ITTransferTerminate(const aTransferName:AnsiString; aCallerAction:ICallerAction):Boolean;
    function ITBfLocalExists(aIdBase:Integer; aCallerAction:ICallerAction; {Out}aPInfo:PTableBfInfo; aIfExistsUseEvents:PUseTransferEvents; const aConnectionName:AnsiString):boolean;
    function ITBeginDownload(aIdBase:Integer; aCallerAction:ICallerAction; Out aTBfInfoBeginDownload:TTBfInfoBeginDownload):AnsiString{TransferName};
    procedure ITDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString; aSequenceNumber:Cardinal; Var aTransfer:TBfTransfer; Out aBf:Variant);
    procedure ITEndDownload(aCallerAction:ICallerAction; const aTransferName:AnsiString);
    function ITReceiveTransferCanceled(aCallerAction:ICallerAction; const aTransferName:AnsiString):Boolean;
    function ITReceiveTransferTerminated(aCallerAction:ICallerAction; const aTransferName, aTerminatorSysName:AnsiString):Boolean;
    procedure ITTransportError(aCallerAction:ICallerAction; const ConnectionName:AnsiString; aPack:IPack; const aMessage:AnsiString; aHelpContext:Integer);*)
end.
