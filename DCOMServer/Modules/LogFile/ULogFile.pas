//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit ULogFile;

interface
  uses UTrayInterface, ULogFileTypes, UTrayInterfaceTypes;
type
  TLogFile=class(TTrayInterface, ILogFile)
  protected
    F:Text;
    FFileName, FFileNameAutoChangeFile:AnsiString;
    FOpened, FErrorToRaise, FErrorOccured :Boolean;
    FErrorMess:AnsiString;
    FWriteSelfMess:boolean;
    FAddToFileNameCurrentDataTime:boolean;
    FCountMessToAutoChangeFileName, FCountMessAutoChangeFileName, FCountMess:Integer;
    FOverrideExists:boolean;
    procedure InternalAutoChangeFileName;virtual;
  protected
    function ITGetErrorToRaise:Boolean;virtual;{FErrorToRaise}
    procedure ITSetErrorToRaise(value:Boolean);virtual;
    function ITGetOpened:Boolean;virtual;{FOpened}
    function ITGetWriteSelfMess:Boolean;virtual;{FWriteSelfMess}
    procedure ITSetWriteSelfMess(value:Boolean);virtual;
    function ITGetCountMessToAutoChangeFileName:Integer;virtual;
    procedure ITSetCountMessToAutoChangeFileName(value:Integer);virtual;{FCountMessToAutoChangeFileName}
    function ITGetCountMessAutoChangeFileName:Integer;virtual;{FCountMessAutoChangeFileName}
    function ITGetCountMess:Integer;virtual;{FCountMess}
    function ITGetFileName:AnsiString;virtual;{FFileName}
    function ITGetAddToFileNameCurrentDataTimeAtOpen:Boolean;virtual;
    procedure ITSetAddToFileNameCurrentDataTimeAtOpen(value:Boolean);virtual;{FAddToFileNameCurrentDataTime}
    function ITGetOverrideExists:boolean;virtual;
    procedure ITSetOverrideExists(value:Boolean);virtual;
  public
    constructor Create(const aFileName:AnsiString);
    destructor Destroy;override;
    procedure ITWriteToLog(const value:AnsiString; blIndicateTime:boolean=True);virtual;
    procedure ITWriteLnToLog(const value:AnsiString; blIndicateTime:boolean=True);virtual;
    procedure ITOpenLog;virtual;
    procedure ITCloseLog;virtual;
    property ITErrorToRaise:Boolean read ITGetErrorToRaise write ITSetErrorToRaise;
    property ITOpened:boolean read ITGetOpened;
    property ITWriteSelfMess:boolean read ITGetWriteSelfMess write ITSetWriteSelfMess;
    property ITCountMessToAutoChangeFileName:Integer read ITGetCountMessToAutoChangeFileName write ITSetCountMessToAutoChangeFileName;
    property ITCountMessAutoChangeFileName:Integer read ITGetCountMessAutoChangeFileName;
    property ITCountMess:Integer read ITGetCountMess;
    property ITFileName:AnsiString read ITGetFileName;
    property ITAddToFileNameCurrentDataTimeAtOpen:Boolean read ITGetAddToFileNameCurrentDataTimeAtOpen write ITSetAddToFileNameCurrentDataTimeAtOpen;
    property ITOverrideExists:boolean read ITGetOverrideExists write ITSetOverrideExists;
  end;


implementation
Uses SysUtils, UObjectsTypes;

// TLogFile --------------------------------------------------------------------
constructor TLogFile.Create(const aFileName:AnsiString);
begin
  FFileName:=aFileName;
  FFileNameAutoChangeFile:=aFileName;
  FOpened:=False;
  FErrorOccured:=False;
  FErrorToRaise:=False;
  FWriteSelfMess:=True;
  FOverrideExists:=false;
  FErrorMess:='';
  FCountMessToAutoChangeFileName:=-1;
  FCountMessAutoChangeFileName:=0;
  FCountMess:=0;
  FAddToFileNameCurrentDataTime:=False;
  Inherited Create;
end;

destructor TLogFile.Destroy;
begin
  if FOpened then begin
    FErrorToRaise:=False;
    ITCloseLog;
  end;
  Inherited Destroy;
end;

procedure TLogFile.InternalAutoChangeFileName;
  var iNewFileName, iOldFileName:AnsiString;
begin
  Inc(FCountMess);
  Inc(FCountMessAutoChangeFileName);
  if (FCountMessToAutoChangeFileName<0)Or(FCountMessToAutoChangeFileName>FCountMessAutoChangeFileName) then exit;
  iNewFileName:=ExtractFilePath(FFileNameAutoChangeFile)+ExtractFileName(FFileNameAutoChangeFile)+FormatDateTime('_ddmmyy_hhnnss_zzz', Now)+'_'+IntToStr(Random(9999999))+ExtractFileExt(FFileNameAutoChangeFile);
  Write(F, #13#10'AutoChangeFileName: New name is '''+iNewFileName+'''.'#13#10'  All mess='+IntToStr(FCountMess)+'.'#13#10);
  ITCloseLog;
  iOldFileName:=FFileName;
  FFileName:=iNewFileName;
  ITOpenLog;
  Write(F, #13#10'AutoChangeFileName: Old name is '''+iOldFileName+'''.'#13#10'  All mess='+IntToStr(FCountMess)+'.'#13#10);
  Flush(F);
  FCountMessAutoChangeFileName:=0;
end;

procedure TLogFile.ITWriteToLog(const value:AnsiString; blIndicateTime:boolean=True);
begin
  InternalLock;
  try
    try
      if not FOpened then raise Exception.Create('LogFile not opened.');
      InternalAutoChangeFileName;
      if blIndicateTime then Write(F, FormatDateTime('ddmmyy hh:nn:ss.zzz', Now)+': '+value) else Write(F, value);
      Flush(F);
      FErrorOccured:=False;
      FErrorMess:='';
    except on e:exception do begin
      FErrorOccured:=True;
      FErrorMess:=e.message;
      if FErrorToRaise then raise;
    end;end;
  finally
    InternalUnLock;
  end;
end;

procedure TLogFile.ITWriteLnToLog(const value:AnsiString; blIndicateTime:boolean=True);
begin
  InternalLock;
  try
    try
      if not FOpened then raise Exception.Create('LogFile not opened.');
      InternalAutoChangeFileName;
      if blIndicateTime then Write(F, FormatDateTime('ddmmyy hh:nn:ss.zzz', Now)+': '+value+#13#10) else Write(F, value+#13#10);
      Flush(F);
      FErrorOccured:=False;
      FErrorMess:='';
    except on e:exception do begin
      FErrorOccured:=True;
      FErrorMess:=e.message;
      if FErrorToRaise then raise;
    end;end;
  finally
    InternalUnLock;
  end;
end;

procedure TLogFile.ITOpenLog;
  var tmpFErrorToRaise:boolean;
begin
  InternalLock;
  try
    try
      if FOpened then raise Exception.Create('LogFile already opened.');
      if FAddToFileNameCurrentDataTime then begin           {ExtractFileName(FFileNameAutoChangeFile)}
        FFileName:=ExtractFilePath(FFileNameAutoChangeFile)+ChangeFileExt(ExtractFileName(FFileNameAutoChangeFile), '')+FormatDateTime('_ddmmyy_hhnnss_zzz', Now)+'_'+IntToStr(Random(9999999))+ExtractFileExt(FFileNameAutoChangeFile);
      end;
      AssignFile(F, FFileName);
      FileMode:=0;{Set file access to read only }
      if FOverrideExists then begin
        Rewrite(f);
      end else begin
        {$I-}
        Reset(F);
        CloseFile(F);
        {$I+}
        if IOResult=0 then Append(f) else Rewrite(f);
      end;
      FOpened:=True;
      tmpFErrorToRaise:=FErrorToRaise;
      FErrorToRaise:=True;
      try
        if FWriteSelfMess then begin Write(F, #13#10'Log opened.'#13#10); Flush(F); end;
      finally
        FErrorToRaise:=tmpFErrorToRaise;
      end;
      // ..
      FErrorOccured:=False;
      FErrorMess:='';
    except on e:exception do begin
      FOpened:=True;
      tmpFErrorToRaise:=FErrorToRaise;
      FErrorToRaise:=False;
      try
        ITCloseLog;
      finally
        FErrorToRaise:=tmpFErrorToRaise;
      end;
      FOpened:=False;
      FErrorOccured:=True;
      FErrorMess:=e.message;
      if FErrorToRaise then raise;
    end;end;
  finally
    InternalUnLock;
  end;
end;

procedure TLogFile.ITCloseLog;
begin
  InternalLock;
  try
    try
      if not FOpened then raise Exception.Create('LogFile not opened.');
      if FWriteSelfMess then Write(F, 'Log closed.'#13#10);
      CloseFile(F);
      FErrorOccured:=False;
      FErrorMess:='';
      FOpened:=False;
    except on e:exception do begin
      FErrorOccured:=True;
      FErrorMess:=e.message;
      if FErrorToRaise then raise;
    end;end;
  finally
    InternalUnLock;
  end;
end;

function TLogFile.ITGetErrorToRaise:Boolean;
begin
  InternalLock;
  try
    Result:=FErrorToRaise;
  finally
    InternalUnLock;
  end;  
end;

procedure TLogFile.ITSetErrorToRaise(value:Boolean);
begin
  InternalLock;
  try
    FErrorToRaise:=Value;
  finally
    InternalUnLock;
  end;  
end;

function TLogFile.ITGetOpened:Boolean;
begin
  InternalLock;
  try
    Result:=FOpened;
  finally
    InternalUnLock;
  end;  
end;

function TLogFile.ITGetWriteSelfMess:Boolean;
begin
  InternalLock;
  try
    Result:=FWriteSelfMess;
  finally
    InternalUnLock;
  end;  
end;

procedure TLogFile.ITSetWriteSelfMess(value:Boolean);
begin
  InternalLock;
  try
    FWriteSelfMess:=Value;
  finally
    InternalUnLock;
  end;  
end;

function TLogFile.ITGetCountMessToAutoChangeFileName:Integer;
begin
  InternalLock;
  try
    Result:=FCountMessToAutoChangeFileName;
  finally
    InternalUnLock;
  end;
end;

procedure TLogFile.ITSetCountMessToAutoChangeFileName(value:Integer);
begin
  InternalLock;
  try
    FCountMessToAutoChangeFileName:=Value;
  finally
    InternalUnLock;
  end;  
end;

function TLogFile.ITGetCountMessAutoChangeFileName:Integer;
begin
  InternalLock;
  try
    Result:=FCountMessAutoChangeFileName;
  finally
    InternalUnLock;
  end;
end;

function TLogFile.ITGetCountMess:Integer;
begin
  InternalLock;
  try
    Result:=FCountMess;
  finally
    InternalUnLock;
  end;  
end;

function TLogFile.ITGetFileName:AnsiString;
begin
  InternalLock;
  try
    Result:=FFileName;
  finally
    InternalUnLock;
  end;  
end;

function TLogFile.ITGetAddToFileNameCurrentDataTimeAtOpen:Boolean;
begin
  InternalLock;
  try
    Result:=FAddToFileNameCurrentDataTime;
  finally
    InternalUnLock;
  end;
end;

procedure TLogFile.ITSetAddToFileNameCurrentDataTimeAtOpen(value:Boolean);
begin
  InternalLock;
  try
    FAddToFileNameCurrentDataTime:=Value;
  finally
    InternalUnLock;
  end;  
end;

function TLogFile.ITGetOverrideExists:boolean;
begin
  InternalLock;
  try
    result:=FOverrideExists;
  finally
    InternalUnlock;
  end;
end;

procedure TLogFile.ITSetOverrideExists(value:Boolean);
begin
  InternalLock;
  try
    FOverrideExists:=value;
  finally
    InternalUnlock;
  end;
end;


end.
