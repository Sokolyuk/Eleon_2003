//Copyright © 2000-2004 by Dmitry A. Sokolyuk
unit UDocImplManageTypes;

interface

type
  TOnDocSetDocHeadEvent = function(const aDocHeadAsVariant:TDocHeadAsVariant):boolean of object;//true - есть еще данные, false данные закончились

  TOnDocGetDocDataEvent = function(out aData:variant):boolean of object;//true - есть еще данные, false данные закончились
  TOnDocSetDocDataEvent = function(const aData:variant):boolean of object;//true - есть еще данные, false данные закончились


  IDocImplManage=interface
  ['{F7C40230-07F7-4E80-8E59-C81B89442117}']
    procedure OnDocGet(const aSenderIntf:IUnknown; const aDocGuid:TGuid; aOnDocSetDocHead:TOnDocSetDocHeadEvent; aOnDocSetDocData:TOnDocSetDocDataEvent);
    function OnDocSet(const aSenderIntf:IUnknown; aDocHeadAsVariant:TDocHeadAsVariant; aOnDocGetDocData:TOnDocGetDocDataEvent):TGuid;


    function OnDocCreate(const aSenderIntf:IUnknown; const aDocHeadAsVariant:TDocHeadAsVariant; aOnDocCreateGetDocData:TOnDocCreateGetDocDataEvent):TGuid;

    function OnDocDelete(const aDocGuid:TGuid):boolean;




     

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
