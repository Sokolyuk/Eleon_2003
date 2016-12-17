//Copyright © 2000-2004 by Dmitry A. Sokolyuk
unit UTransferDocImplManageTypes;

interface
  uses UTransferDocTypes;
type
  TSelectCheckUpdateHeadRegInfoEvent=procedure(const aDocHeadWithTransferAsVariant:TDocHeadWithTransferAsVariant) of object;
  TSetDocInsertEvent=procedure(const aDocTransferAsVariant:TDocTransferAsVariant) of object;
  TSetDocUpdateEvent=procedure(const aDocTransferAsVariant:TDocTransferAsVariant) of object;
  TSetDocDeleteEvent=procedure of object;
  TSetDocOpenWriteEvent=procedure({out по требованию}aPDocTransferAsVariant:PDocTransferAsVariant) of object;
  TSetDocWriteEvent=procedure(aOutTransferPos, aOutTransferChecksum:integer; const aTransferParam:Variant) of object;
  TSetDocEndWriteEvent=procedure of object;

  ITransferDocImplManage=interface
  ['{F7C40230-07F7-4E80-8E59-C81B89442117}']
    procedure OnSelectCheckHeadRegInfo(const aSenderIntf:IUnknown; aIsOpenWrite:boolean; const aDocGuid:TGuid; var aDocHeadWithTransferAsVariant:TDocHeadWithTransferAsVariant; aSelectCheckUpdateHeadRegInfo:TSelectCheckUpdateHeadRegInfoEvent);
    procedure OnInsert(aSetDocInsert:TSetDocInsertEvent; const aSenderIntf:IUnknown; aIsOpenWrite:boolean; const aDocGuid:TGuid; const aDocHeadAsVariant:TDocHeadAsVariant; var aDocTransferAsVariant:TDocTransferAsVariant);
    procedure OnUpdate(aSetDocUpdate:TSetDocUpdateEvent; const aSenderIntf:IUnknown; aIsOpenWrite:boolean; const aDocGuid:TGuid; const aDocHeadAsVariantExists, aDocHeadAsVariantNew:TDocHeadAsVariant; var aDocTransferAsVariant:TDocTransferAsVariant);
    procedure OnDelete(aSetDocDelete:TSetDocDeleteEvent; const aSenderIntf:IUnknown; const aDocGuid:TGuid; const aDocHeadWithTransferAsVariant:TDocHeadWithTransferAsVariant);
    procedure OnOpenRead(const aSenderIntf:IUnknown; const aDocGuid:TGuid; const aDocHeadWithTransferAsVariant:TDocHeadWithTransferAsVariant; out aUserData:variant);
    procedure OnRead(const aSenderIntf:IUnknown; const aReadIn:TReadIn; out aReadOut:TReadOut; var aTransferParam:Variant);
    procedure OnEndReadBeforeEndWrite(const aSenderIntf:IUnknown; aEndWriteOk:boolean; const aEndWriteErrorString:AnsiString; aEndWriteErrorHC:integer; out aUserData:variant);
    procedure OnEndReadAfterEndWrite(const aSenderIntf:IUnknown; aEndWriteOk:boolean; const aEndWriteErrorString:AnsiString; aEndWriteErrorHC:integer; aEndWriteEndWriteOk:boolean; const aEndWriteEndWriteErrorString:AnsiString; aEndWriteEndWriteErrorHC:integer; const aUserData:variant);
    procedure OnOpenWrite(aSetDocOpenWrite:TSetDocOpenWriteEvent; const aSenderIntf:IUnknown; const aDocGuid:TGuid; const aDocHeadAsVariant:TDocHeadAsVariant; const aUserData:variant);
    procedure OnWrite(aSetDocWrite:TSetDocWriteEvent; const aSenderIntf:IUnknown; const aWriteIn:TWriteIn; out aWriteOut:TWriteOut; var aTransferParam:variant);
    procedure OnEndWrite(aSetDocEndWrite:TSetDocEndWriteEvent; const aSenderIntf:IUnknown; aEndWriteOk:boolean; const aEndWriteErrorString:AnsiString; aEndWriteErrorHC:integer; var aUserData:variant);
    function OnDestinationToNodeName(const aSenderIntf:IUnknown; aDestination:integer; out aMultiDestination:boolean):AnsiString;
    function OnGetReadBlockSize(const aSenderIntf:IUnknown):integer;
  end;

implementation

end.
