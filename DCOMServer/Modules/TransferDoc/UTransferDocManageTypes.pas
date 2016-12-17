//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTransferDocManageTypes;
  Модуль нормальный, но технология устарела. см. TransferDoc/TransferDocs/TransferDocManage/TransferBf
interface
  uses UTransferDocTypes;
type
  ITransferDocManage=interface
  ['{0FE60B57-EEC2-484E-A72D-9B71E28C3A74}']
    function Exists(const aDocGuid:TGuid; out aTransfering:boolean):boolean;
    function Select(const aDocGuid:TGuid; out aDocHeadWithTransferAsVariant:TDocHeadWithTransferAsVariant):boolean;
    procedure Insert(const aDocGuid:TGuid; const aDocHeadAsVariant:TDocHeadAsVariant; out aDocTransferAsVariant:TDocTransferAsVariant);
    procedure Update(const aDocGuid:TGuid; const aDocHeadAsVariant:TDocHeadAsVariant; out aDocTransferAsVariant:TDocTransferAsVariant);
    procedure Delete(const aDocGuid:TGuid);
    procedure OpenRead(const aDocGuid:TGuid; out aDocHeadWithTransferAsVariant:TDocHeadWithTransferAsVariant; out aUserData:variant);
    procedure Read(const aReadIn:TReadIn; out aReadOut:TReadOut; var aTransferParam:variant);
    procedure EndReadBeforeEndWrite(aEndWriteOk:boolean; const aEndWriteErrorString:AnsiString; aEndWriteErrorHC:integer; out aUserData:variant);
    procedure EndReadAfterEndWrite(aEndWriteOk:boolean; const aEndWriteErrorString:AnsiString; aEndWriteErrorHC:integer; aEndWriteEndWriteOk:boolean; const aEndWriteEndWriteErrorString:AnsiString; aEndWriteEndWriteErrorHC:integer; const aUserData:variant);
    procedure OpenWrite(const aDocGuid:TGuid; const aDocHeadAsVariant:TDocHeadAsVariant; out aDocTransferAsVariant:TDocTransferAsVariant; const aUserData:variant);
    procedure Write(const aWriteIn:TWriteIn; out aWriteOut:TWriteOut; var aTransferParam:variant);
    procedure EndWrite(aEndWriteOk:boolean; const aEndWriteErrorString:AnsiString; aEndWriteErrorHC:integer; var aUserData:variant);
    function DestinationToNodeName(aDestination:integer; out aMultiDestination:boolean):AnsiString;
    function GetReadBlockSize:integer;
    procedure BeginDocTransfered(const aDocGuid:TGuid; const aiddcDocsAutoTransfer, aidssUserAutoTransfer:variant);
    procedure CommitDocTransfered;
    procedure RollbackDocTransfered;
  end;

implementation

end.
