//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UAppMessageLog;

interface
  uses ULogFileTypes, UAppMessage;
type
  TAppMessageLog=class(TAppMessage)
  private
    FFLogFile:ILogFile;
    FSaveLastMessage:Longint;
    FNoSavedCount:Cardinal;
    FLastSaveTime:TDateTime;
    FStarted:boolean;
    function GetFLogFile:ILogFile;
    property FLogFile:ILogFile read GetFLogFile;
  protected
    {function InternalGetInitGUIDCount:Cardinal;override;
    procedure InternalInitGUIDList;override;}
    procedure InternalStart;override;
    procedure InternalStop;override;
  protected
    procedure InternalNewMessage;override;
    procedure InternalSaveAllMessages;virtual;
  protected
    procedure InternalExecThreadProcOfObject(aUserPointer:Pointer; aUserIUnknown:IUnknown);
  public
    constructor create(aMessagesMaxCount:Integer);
    destructor destroy;override;
    procedure ITMessToBasicLog(Const aMessage:AnsiString; aIndicateTime:boolean=True);override;
  end;

implementation
  uses UTrayConsts, UThreadsPoolTypes, UDataCaseExecProcTypes, UDateTimeUtils, Sysutils, UVarsetTypes, UAppMessageUtils,
       UAppMessageTypes, Windows, UTrayTypes{$IFNDEF VER130}, Variants{$ENDIF};

constructor TAppMessageLog.create(aMessagesMaxCount:Integer);
begin
  inherited create(aMessagesMaxCount);
  FFLogFile:=nil;
  FSaveLastMessage:=0;
  FNoSavedCount:=0;
  FLastSaveTime:=now;
  FStarted:=false;
end;

destructor TAppMessageLog.destroy;
begin
  if FNoSavedCount>0 then InternalSaveAllMessages;
  FFLogFile:=nil;
  inherited destroy;
end;

procedure TAppMessageLog.InternalStart;
begin
  inherited InternalStart;
  FStarted:=true;
end;

procedure TAppMessageLog.InternalStop;
begin
  inherited InternalStop;
  FStarted:=false;
end;

procedure TAppMessageLog.ITMessToBasicLog(const aMessage:AnsiString; aIndicateTime:boolean=True);
Begin
  if assigned(FLogFile) then FLogFile.ITWriteLnToLog(aMessage, aIndicateTime);
End;

{function TAppMessageLog.InternalGetInitGUIDCount:Cardinal;
begin
  result:=inherited InternalGetInitGUIDCount+1;
end;

procedure TAppMessageLog.InternalInitGUIDList;
  var tmpGUIDCount:Cardinal;
begin
  tmpGUIDCount:=inherited InternalGetInitGUIDCount;
  inherited InternalInitGUIDList;
  GUIDList^.aList[tmpGUIDCount]:=ILogfile;
end;}

function TAppMessageLog.GetFLogFile:ILogFile;
  var tmpTray:ITray;
begin
  if not assigned(FFLogFile) then begin
    tmpTray:=cnTray;
    if assigned(tmpTray) then tmpTray.Query(ILogFile, FFLogFile, false);
  end;
  result:=FFLogFile;
end;

procedure TAppMessageLog.InternalNewMessage;
  var tmpThreadsPool:IThreadsPool;
      tmpExecThreadStruct:TExecThreadStruct;
      tmpSaveAll:boolean;
      tmpTray:ITray;
begin
  Inc(FNoSavedCount);
  tmpSaveAll:=(not FStarted)or(FNoSavedCount>=cardinal(FMessagesMaxCount));
  If (not tmpSaveAll)and(FNoSavedCount>=(cardinal(FMessagesMaxCount) div 2)) then begin
    tmpTray:=cnTray;
    tmpSaveAll:=not ((assigned(tmpTray))and(tmpTray.Query(IThreadsPool, tmpThreadsPool, false))and(assigned(tmpThreadsPool)));
    if not tmpSaveAll then begin//берется ThreadsPool
      fillchar(tmpExecThreadStruct, Sizeof(tmpExecThreadStruct), 0);
      tmpExecThreadStruct.ThreadProcOfObject:=InternalExecThreadProcOfObject;
      //!!??tmpExecThreadStruct.UserIUnknown:=self;
      tmpSaveAll:=not tmpThreadsPool.ITNlExecProcThread(@tmpExecThreadStruct, false{raise});
    end;
  end;
  if tmpSaveAll then begin
    InternalSaveAllMessages;
    FNoSavedCount:=0;
  end;
end;

procedure TAppMessageLog.InternalExecThreadProcOfObject(aUserPointer:Pointer; aUserIUnknown:IUnknown);
  var tmpI, tmpSkipCnt:longint;
      tmpBuffDiff, tmpMessCountNow:Integer;
      tmpV:Variant;
      tmpIVarsetDataView:IVarsetDataView;
begin
  Internallock;
  try
    If MessCountAll<=FSaveLastMessage Then exit;
    tmpSkipCnt:=0;
    tmpMessCountNow:=FMessages.ITCount;
    For tmpI:=FSaveLastMessage+1 to MessCountAll do begin
      If tmpI=0 Then Continue;
      tmpBuffDiff:=tmpMessCountNow+tmpI-MessCountAll-1;
      If tmpBuffDiff<0 Then begin
        Inc(tmpSkipCnt);
        Continue;
      end else begin
        if tmpSkipCnt>0 then begin//Записываю сообщение в Log-файл и в буфер в памяти
          ITMessToBasicLog(FormatDateTime('ddmmyy hh:nn:ss.zzz ', Now)+#9+TwoDateTimeToDurationStr(Now, FLastSaveTime)+#9+
              MessageClassToStr(mecApp)+#9+MessageStyleToStr(mesWarning)+#9+'AppMessage'+#9+IntToStr(Integer(GetCurrentThreadId))+#9+''+#9+'Недоступно '+IntToStr(tmpSkipCnt)+' сообщений.', False);
          tmpSkipCnt:=0;
        end;
        tmpIVarsetDataView:=FMessages.ITView[tmpBuffDiff];
        tmpV:=tmpIVarsetDataView.ITData;
        tmpIVarsetDataView:=Nil;
        try
          try                                                                   
            ITMessToBasicLog(FormatDateTime('ddmmyy hh:nn:ss.zzz ', tmpV[0])+#9+MSecsToDurationStr(Abs(DateTimeToMSecs(tmpV[1])))+#9+
                MessageClassToStr(TMessageClass(Integer(tmpV[2])))+#9+MessageStyleToStr(TMessageStyle(Integer(tmpV[3])))+#9+VarToStr(tmpV[4])+#9+IntToStr(Integer(tmpV[5]))+#9+VarToStr(tmpV[6])+#9+VarToStr(tmpV[7]), False);
          except on e:exception do begin try
            ITMessToBasicLog(FormatDateTime('ddmmyy hh:nn:ss.zzz ', tmpV[0])+#9+MSecsToDurationStr(0)+#9+
                MessageClassToStr(mecApp)+#9+MessageStyleToStr(mesError)+#9+'AppMessage'+#9+IntToStr(Integer(GetCurrentThreadId))+#9+''+#9+e.Message+'/HC='+IntToStr(e.HelpContext), False);
          except end;end;end;
        finally
          VarClear(tmpV);
        end;
      end;
    end;
    FSaveLastMessage:=MessCountAll;
    FNoSavedCount:=0;
    FLastSaveTime:=now;
  finally
    Internalunlock;
  end;
end;

procedure TAppMessageLog.InternalSaveAllMessages;
begin
  InternalExecThreadProcOfObject(nil, nil);
end;

end.
