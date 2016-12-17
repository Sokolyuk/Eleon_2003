//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UBfManageTypes;

interface
  uses windows;
type
  PBfInfo=^TBfInfo;
  TBfInfo=record
    Path:AnsiString;
    Filename:AnsiString;
    Checksum:Integer;
    ChecksumDate:TDateTime;
    TotalSize:integer;//Cardinal;
    BfType:Integer;
    Commentary:AnsiString;
  end;
  TTransferDirection=Integer;
const trdDownload:TTransferDirection=0;
      trdUpload:TTransferDirection=1;
type
  PBfTransferInfo=^TBfTransferInfo;
  TBfTransferInfo=record
    Transfering:Boolean;//Exists registry key or SELECT * FROM ssBfTransfer WHERE BfName='xx'
    Pos:integer;//Cardinal;
    Checksum:Integer;
    Responder:AnsiString;
    Direction:TTransferDirection;
  end;
  PFileInfo=^TFileInfo;
  TFileInfo=record
    TotalSize:integer;//Cardinal;
    FileDateTime:TDateTime;
  end;
  TTransferWriteIn=record
    Pos:integer;//Cardinal;
    Size:integer;//Cardinal;
    Checksum:Integer;
    Data:Variant;
    TransferChecksum:Integer;
  end;
  TTransferWriteOut=record
    TransferPos:integer;//Cardinal;
    TransferChecksum:Integer;
  end;
  TTransferReadIn=record
    Pos:integer;//Cardinal;
    Size:integer;//Cardinal;
  end;
  TTransferReadOut=record
    Size:integer;//Cardinal;
    Checksum:Integer;
    Data:Variant;
  end;
  IBfManage=interface
  ['{5990A977-26AB-4648-9161-431EF948EBA2}']
    //function FileOpenRead(const aFilePath:AnsiString; {out}aPFileInfo:PFileInfo):THandle;
    //function FileOpenWrite(const aFilePath:AnsiString; {out}aPFileInfo:PFileInfo):THandle;
    //function FileCreateWrite(const aFilePath:AnsiString):THandle;
    //..
    function Exists(const guidBf:TGUID; {Out}aFileHandle:PHandle; {Out}aPInfo:PBfInfo; {Out}aPBfTransferInfo:PBfTransferInfo):boolean;
    function Delete(const guidBf:TGUID):boolean;
    procedure Insert(const guidBf:TGUID; const aBfInfo:TBfInfo; const aTransferResponder:AnsiString; aTransferDirection:TTransferDirection; {Out}aFileHandle:PHandle; out aBfTransferInfo:TBfTransferInfo);
    //function Update(const guidBf:TGUID; const aBfInfo:TBfInfo);
    function TransferOpenWrite(const guidBf:TGUID; {Out}aFileHandle:PHandle; const aBfInfo:TBfInfo; const aTransferResponder:AnsiString; aTransferDirection:TTransferDirection; out aBfTransferInfo:TBfTransferInfo):boolean;
    procedure TransferWrite(const guidBf:TGUID; aFileHandle:THandle; const aTransferWriteIn:TTransferWriteIn; out aTransferWriteOut:TTransferWriteOut);
    procedure TransferEndWrite(const guidBf:TGUID; var aFileHandle:THandle; aChecksumDate:TDateTime);
    //..
    procedure TransferOpenRead(const guidBf:TGUID; {Out}aFileHandle:PHandle; out aBfInfo:TBfInfo; out aBfTransferInfo:TBfTransferInfo);
    procedure TransferRead(aFileHandle:THandle; const aTransferReadIn:TTransferReadIn; out aTransferReadOut:TTransferReadOut);
    procedure TransferEndRead(var aFileHandle:THandle);
  end;

implementation

end.
