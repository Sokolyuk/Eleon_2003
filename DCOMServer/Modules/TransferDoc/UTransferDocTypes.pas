//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTransferDocTypes;

interface
type
  PDocHeadAsVariant=^TDocHeadAsVariant;
  TDocHeadAsVariant=record
    aName, aDocDateTime, aTotalSize, aChecksum, aType, aSource, aDestination, aFlag, aUserId, aCommentary:variant;
  end;
  PDocTransferAsVariant=^TDocTransferAsVariant;
  TDocTransferAsVariant=record
    aTransferPos, aTransferChecksum, aTransferParam:variant;
    aTransfering:boolean;
  end;
  PDocHeadWithTransferAsVariant=^TDocHeadWithTransferAsVariant;
  TDocHeadWithTransferAsVariant=record
    aDocHeadAsVariant:TDocHeadAsVariant;
    aDocTransferAsVariant:TDocTransferAsVariant;
  end;
  TReadIn=record
    aPos:integer;
    aSize:integer;
  end;
  TReadOut=record
    aReadSize:integer;
    aChecksum:integer;
    aData:variant;
  end;
  TWriteIn=record
    aPos:integer;
    aSize:integer;
    aChecksum:integer;
    aData:variant;
    aTransferChecksumIn:integer;
  end;
  TWriteOut=record
    aTransferPos:integer;
    aTransferChecksumOut:integer;
  end;

implementation

end.
