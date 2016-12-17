unit UAppMessageBase;

interface
  uses UTrayInterface, UAppMessageTypes, UVarsetTypes, UTrayInterfaceTypes;
type
  TAppMessageBase=class(TTrayInterface, IAppMessage)
  protected
    FMessagesMaxCount:Integer;
    FMessages:IVarset;
  private
    FMessCountClassApp, FMessCountClassSQL, FMessCountClassDebug,
    FMessCountClassSecurity, FMessCountClassTransport, FMessCountClassTransfer,
    FMessCountStyleError, FMessCountStyleInfo, FMessCountStyleWarning,
    FMessCountAll:Integer;
  protected
    procedure InternalInit;override;
    procedure InternalFinal;override;
  protected
    function Get_MessCountClassApp:Integer;virtual;
    function Get_MessCountClassSQL:Integer;virtual;
    function Get_MessCountClassDebug:Integer;virtual;
    function Get_MessCountClassSecurity:Integer;virtual;
    function Get_MessCountClassTransport:Integer;virtual;
    function Get_MessCountClassTransfer:Integer;virtual;
    function Get_MessCountStyleError:Integer;virtual;
    function Get_MessCountStyleInfo:Integer;virtual;
    function Get_MessCountStyleWarning:Integer;virtual;
    function Get_MessCountAll:Integer;virtual;
    function Get_MessagesMaxCount:Integer;virtual;
  protected
    procedure InternalNewMessage;virtual;
  public
    constructor create(aMessagesMaxCount:Integer);
    destructor destroy;override;
    Procedure ITMessAdd(aStartTime, aEndTime:TDateTime; Const aUser, aSource, aMessage:AnsiString; aMessageClass:TMessageClass; aMessageStyle:TMessageStyle);virtual;
    Function ITGetNewMess(Var aLastMessage:Longint; aClasses:TMessageClasses; aStyles:TMessageStyles):Variant;virtual;
    Procedure ITMessToBasicLog(Const aMessage:AnsiString; aIndicateTime:boolean=True);virtual;
    property MessCountClassApp:Integer read Get_MessCountClassApp;
    property MessCountClassSQL:Integer read Get_MessCountClassSQL;
    property MessCountClassDebug:Integer read Get_MessCountClassDebug;
    property MessCountClassSecurity:Integer read Get_MessCountClassSecurity;
    property MessCountClassTransport:Integer read Get_MessCountClassTransport;
    property MessCountClassTransfer:Integer read Get_MessCountClassTransfer;
    property MessCountStyleError:Integer read Get_MessCountStyleError;
    property MessCountStyleInfo:Integer read Get_MessCountStyleInfo;
    property MessCountStyleWarning:Integer read Get_MessCountStyleWarning;
    property MessCountAll:Integer read Get_MessCountAll;
    property MessagesMaxCount:Integer read Get_MessagesMaxCount;
  end;

  function GetAppStartDateTime:TDateTime;

implementation
  uses UVarset, Sysutils, UAppMessageUtils, UDateTimeUtils, windows, Variants, UTrayConsts, Comobj{, UConsts, UServerConsts};

constructor TAppMessageBase.Create(aMessagesMaxCount:Integer);
begin
  inherited create;
  FMessagesMaxCount:=aMessagesMaxCount;
  FMessages:=TVarset.Create;
  FMessages.ITConfigIntIndexAssignable:=False;
  FMessages.ITConfigCheckUniqueIntIndex:=False;
  FMessages.ITConfigCheckUniqueStrIndex:=False;
  FMessages.ITConfigNoFoundException:=False;
  FMessages.ITConfigCaseSensitive:=False;
  FMessCountClassApp:=0;
  FMessCountClassSQL:=0;
  FMessCountClassDebug:=0;
  FMessCountClassSecurity:=0;
  FMessCountClassTransport:=0;
  FMessCountClassTransfer:=0;
  FMessCountStyleError:=0;
  FMessCountStyleInfo:=0;
  FMessCountStyleWarning:=0;
  FMessCountAll:=0;
end;

destructor TAppMessageBase.destroy;
begin
  FMessages:=nil;
  inherited destroy;
end;

Procedure TAppMessageBase.ITMessAdd(aStartTime, aEndTime:TDateTime; Const aUser, aSource, aMessage:AnsiString; aMessageClass:TMessageClass; aMessageStyle:TMessageStyle);
  var tmpInt64:Int64;
      tmpDuration:TDateTime;
      tmpCount:Integer;
Begin
  InternalLock;
  Try
    Try//Статистика
      tmpCount:=FMessages.ITCount;
      if tmpCount>FMessagesMaxCount-1 Then Begin//буфер наполнился удаляю первую запись
        FMessages.ITPop;
      end;
      try
        tmpInt64:=MSecsBetweenDateTime(aStartTime, aEndTime);
        tmpDuration:=MSecsToDateTime(tmpInt64);
      except
        tmpDuration:=0;
        //tmpInt64:=DateDeltaMSecs;
      end;
      //Записываю сообщение в Log-файл и в буфер в памяти
      {if InternalSaveToBaseLog then begin
        Try ITMessToBasicLog(FormatDateTime('ddmmyy hh:nn:ss.zzz ', aStartTime)+#9+
                         MSecsToDurationStr(tmpInt64)+#9+
                         MessageClassToStr(aMessageClass)+#9+
                         MessageStyleToStr(aMessageStyle)+#9+
                         aSource+#9+
                         IntToStr(Integer(GetCurrentThreadId))+#9+
                         aUser+#9+
                         aMessage, False);Except end;//Создаю запись
      end;{}
      FMessages.ITPushV(VarArrayOf([Now,       //[0]{Date}       varDate
                  tmpDuration,                  //[1]{Duration}   varDate
                  Integer(aMessageClass),       //[2]{Class}      varInteger
                  Integer(aMessageStyle),       //[3]{Type}       varInteger
                  aSource,                      //[4]{Source}     varString
                  Integer(GetCurrentThreadID),  //[5]{Thread}     varInteger
                  aUser,                        //[6]{User}       varString
                  aMessage]));                  //[7]{Message}    varString
      Case aMessageClass of//Статистика, Class
        mecApp:Inc(FMessCountClassApp);
        mecSQL:Inc(FMessCountClassSQL);
        mecDebug:Inc(FMessCountClassDebug);
        mecSecurity:Inc(FMessCountClassSecurity);
        mecTransport:Inc(FMessCountClassTransport);
        mecTransfer:Inc(FMessCountClassTransfer);
      Else
        Inc(FMessCountClassApp);
      End;
      Case aMessageStyle of//Type
        mesError:Inc(FMessCountStyleError);
        mesInformation:Inc(FMessCountStyleInfo);
        mesWarning:Inc(FMessCountStyleWarning);
      Else
        Inc(FMessCountStyleError);
      End;
      Inc(FMessCountAll);//всего сообщений или уникальный номер сообщения
      InternalNewMessage;
    except on e:exception do//Записываю ошибку в лог, т.к. ITMessAdd не должна отражаться на функционировании системы.
      ITMessToBasicLog('ERROR: ITMessAdd: '+e.message+'/HC='+IntToStr(e.helpcontext));
    end;
  Finally
    InternalUnlock;
  End;
end;

Function TAppMessageBase.ITGetNewMess(Var aLastMessage:Longint; aClasses:TMessageClasses; aStyles:TMessageStyles):Variant;
  Var tmpHB:Integer;
  Procedure AddMessRowToVarRes(Const aMessRow:Variant);
    begin
      If VarIsArray(Result) Then begin
        VarArrayRedim(Result, tmpHB+1);
        Inc(tmpHB);
      end else begin
        Result:=VarArrayCreate([0,0], varVariant);
        tmpHB:=0;
      end;
      Result[tmpHB]:=aMessRow;
    end;
  Var tmpI, tmpSkipCnt:longint;
      tmpBuffDiff, tmpMessCountNow:Integer;
begin
  InternalLock;
  Try
    Try
      Result:=Unassigned;
      If FMessCountAll{indexmess+1}<=aLastMessage{indexmess+1} Then exit;
      tmpHB:=-1;
      tmpSkipCnt:=0;
      tmpMessCountNow:=FMessages.ITCount;
      // ..
      For tmpI:=aLastMessage+1 to FMessCountAll do begin
        If tmpI=0 Then Continue;
        tmpBuffDiff:=tmpMessCountNow+tmpI-FMessCountAll-1;
        If tmpBuffDiff<0 Then begin
          Inc(tmpSkipCnt);
          Continue;
        end else begin
          if tmpSkipCnt>0 then begin              
            AddMessRowToVarRes(VarArrayOf([Now, MSecsToDateTime(0), Integer(mecApp), Integer(mesWarning), 'AppMessage', Integer(GetCurrentThreadID), '', 'Недоступно '+IntToStr(tmpSkipCnt)+' сообщений.']));
            tmpSkipCnt:=0;
          end;
          AddMessRowToVarRes(FMessages.ITView[tmpBuffDiff].ITData);
        end;
      end;
      aLastMessage:=FMessCountAll;
    Except on e:exception do begin
      e.message:='ITGetNewMess: '+e.message;
      raise;
    end;end;
  Finally
    InternalUnlock;
  End;
end;

Procedure TAppMessageBase.ITMessToBasicLog(Const aMessage:AnsiString; aIndicateTime:boolean=True);
Begin
End;

function TAppMessageBase.Get_MessCountClassApp:Integer;
Begin
  InternalLock;
  try
    result:=FMessCountClassApp;
  Finally
    InternalUnlock;
  End;
End;

function TAppMessageBase.Get_MessCountClassSQL:Integer;
Begin
  InternalLock;
  try
    result:=FMessCountClassSQL;
  Finally
    InternalUnlock;
  End;
End;

function TAppMessageBase.Get_MessCountClassDebug:Integer;
Begin
  InternalLock;
  try
    result:=FMessCountClassDebug;
  Finally
    InternalUnlock;
  End;
End;

function TAppMessageBase.Get_MessCountClassSecurity:Integer;
Begin
  InternalLock;
  try
    result:=FMessCountClassSecurity;
  Finally
    InternalUnlock;
  End;
End;

function TAppMessageBase.Get_MessCountClassTransport:Integer;
Begin
  InternalLock;
  try
    result:=FMessCountClassTransport;
  Finally
    InternalUnlock;
  End;
End;

function TAppMessageBase.Get_MessCountClassTransfer:Integer;
Begin
  InternalLock;
  try
    result:=FMessCountClassTransfer;
  Finally
    InternalUnlock;
  End;
End;

function TAppMessageBase.Get_MessCountStyleError:Integer;
Begin
  InternalLock;
  try
    result:=FMessCountStyleError;
  Finally
    InternalUnlock;
  End;
End;

function TAppMessageBase.Get_MessCountStyleInfo:Integer;
Begin
  InternalLock;
  try
    result:=FMessCountStyleInfo;
  Finally
    InternalUnlock;
  End;
End;

function TAppMessageBase.Get_MessCountStyleWarning:Integer;
Begin
  InternalLock;
  try
    result:=FMessCountStyleWarning;
  Finally
    InternalUnlock;
  End;
End;

function TAppMessageBase.Get_MessCountAll:Integer;
Begin
  InternalLock;
  try
    result:=FMessCountAll;
  Finally
    InternalUnlock;
  End;
End;

function TAppMessageBase.Get_MessagesMaxCount:Integer;
Begin
  InternalLock;
  try
    result:=FMessagesMaxCount;
  Finally
    InternalUnlock;
  End;
End;

function GetAppStartDateTime:TDateTime;
  Var tmpCreationTime, tmpExitTime, tmpKernelTime, tmpUserTime:TFileTime;
      tmpSystemTime:TSystemTime;
  begin
  If GetProcessTimes(GetCurrentProcess, tmpCreationTime, tmpExitTime, tmpKernelTime, tmpUserTime) Then begin
    FileTimeToLocalFileTime(tmpCreationTime, tmpExitTime);
    FileTimeToSystemTime(tmpExitTime, tmpSystemTime);
    result:=SystemTimeToDateTime(tmpSystemTime);
  end else result:=now;
end;

procedure TAppMessageBase.InternalInit;
  function ThToStr(i:TThreadingModel):AnsiString;begin
    Result:='Error converting.';
    if (i=tmSingle) Then Result:='tmSingle' else
      if i=tmApartment Then Result:='tmApartment' else
        if i=tmBoth Then Result:='tmBoth' else
          if i=tmFree Then Result:='tmFree';
  end;
  function localGetUsername:AnsiString;Type PWord=^Word; Var tmpSt:PChar; tmpLen:Cardinal; begin
    tmpLen:=80;
    GetMem(tmpSt,80);
    try
      GetUserName(tmpSt, tmpLen);
      Result:=tmpSt;
    finally
      FreeMem(tmpSt, 80);
    end;
  end;
  function localGetMyComputerName:AnsiString;
  Var tmpPChar:PChar;
      tmpLen:Cardinal;
  Begin
    tmpLen:=80;
    GetMem(tmpPChar, 80);
    GetComputerName(tmpPChar, tmpLen);
    Result:=tmpPChar;
    FreeMem(tmpPChar, 80);
  end;
begin
  ITMessAdd(Now, GetAppStartDateTime, 'SERVER', 'AppMessage', 'Run. Machine: '''+localGetMyComputerName+'''. User: '''+localGetUsername+'''. PID='+IntToStr(Cardinal(GetCurrentProcessID)), mecApp, mesInformation);
end;

procedure TAppMessageBase.InternalFinal;
  Var tmpCreationTime, tmpExitTime, tmpKernelTime, tmpUserTime:TFileTime;
      tmpSystemTime:TSystemTime;
      tmpSt:AnsiString;
      tmpInt64:Int64;
      tmpDouble:Double;
      tmpAppStartDateTime:TDateTime;
begin
  try
    tmpAppStartDateTime:=GetAppStartDateTime;
    ITMessAdd(tmpAppStartDateTime, now, 'SERVER', 'AppMessage', 'All messages='+IntToStr(FMessCountAll)+' Style: Error='+IntToStr(FMessCountStyleError)+'/Info='+IntToStr(FMessCountStyleInfo)+'/Warning='+IntToStr(FMessCountStyleWarning)+' Class: '+
      'App='+IntToStr(FMessCountClassApp)+'/SQL='+IntToStr(FMessCountClassSQL)+'/Debug='+IntToStr(FMessCountClassDebug)+'/Security='+IntToStr(FMessCountClassSecurity)+
      '/Transport='+IntToStr(FMessCountClassTransport)+'/Transfer='+IntToStr(FMessCountClassTransfer), mecApp, mesInformation);
    If GetProcessTimes(GetCurrentProcess, tmpCreationTime, tmpExitTime, tmpKernelTime, tmpUserTime) Then begin
      FileTimeToSystemTime(tmpKernelTime, tmpSystemTime);
      tmpSt:=tmpSt+'KernelTime='+TwoDateTimeToDurationStr(-109205, SystemTimeToDateTime(tmpSystemTime));
      FileTimeToSystemTime(tmpUserTime, tmpSystemTime);
      tmpInt64:=MSecsBetweenDateTime(-109205, SystemTimeToDateTime(tmpSystemTime));
      tmpSt:=tmpSt+', UserTime='+MSecsToDurationStr(tmpInt64);
      tmpDouble:=DateTimeToMSecs(Now)-DateTimeToMSecs(tmpAppStartDateTime);
      tmpDouble:=(tmpInt64/tmpDouble)*100;
      tmpSt:='Usage='+FloatToStrF(tmpDouble, ffFixed, 1, 2)+'%, '+tmpSt;
    end else begin
      tmpSt:=SysErrorMessage(GetLastError);
    end;
    ITMessAdd(tmpAppStartDateTime, now, 'SERVER', 'AppMessage', 'ProcessTimes: '+tmpSt+'.', mecApp, mesInformation);
    ITMessAdd(tmpAppStartDateTime, now, 'SERVER', 'AppMessage', 'Final.', mecApp, mesInformation);
  except end;
end;

procedure TAppMessageBase.InternalNewMessage;
begin
end;

end.
