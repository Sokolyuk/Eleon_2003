//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UStartupUtils;

interface
  function GL_CheckParam:Char;
  procedure GL_ConfigureApp;
  function DetectServerRegName:AnsiString;
  procedure SetMessage(aStartTime:TDateTime; const aMessage:AnsiString);
  procedure SetErrorMessage(aStartTime:TDateTime; const aMessage:AnsiString; aHelpContext:Integer);
  procedure RegStartedServer;
  procedure UnRegStartedServer;
  procedure RegSetServerError(const aMessage:AnsiString; aHelpContext:Integer);
  procedure RegClearServerError;

implementation
  uses Sysutils, Registry, windows, UServerConsts, UPipeServerConsts, ComObj, UTypeUtils, UAppConfigRegPathConsts,
       Pegas_TLB, EMServer_TLB, Classes, UAppMessageTypes, UTrayConsts, ULogFileConsts, UAppMessageConsts;

function GL_CheckParam:Char;
begin
  if ParamCount>0 then begin
    if (AnsiUppercase(ParamStr(1))='-C') or (AnsiUppercase(ParamStr(1))='/C') or (AnsiUppercase(ParamStr(1))='/CONFIGURE') or (AnsiUppercase(ParamStr(1))='\C') Then Result:='c' else//configure mode
      if (ParamStr(1)='?') or (ParamStr(1)='/?') or (ParamStr(1)='\?') or (ParamStr(1)='-?') Then Result:='h' else//help mode
        if AnsiUppercase(ParamStr(1))='-EMBEDDING' {DCOM запуск} Then Result:='e' else
          if AnsiUppercase(ParamStr(1))='-REGSERVER' Then Result:='g' else
            if AnsiUppercase(ParamStr(1))='-UNREGSERVER' Then Result:='t' else
              Result:='u';//unknown mode
  end else begin//run mode
    Result:='r';
  end;
end;

procedure GL_ConfigureApp;
 var Reg:TRegistry;
     tmpThreadingModel:AnsiString;
begin
{$IFDEF PegasServer}
  cnSQLServerSecurityContext:=glStringToVarArray('12/0(8(''SQLServer''))');
{$Endif}
  Reg:=TRegistry.Create(KEY_READ);
  try
    Reg.RootKey:=HKEY_LOCAL_MACHINE;
    if not reg.KeyExists(cnAppConfigRegPath) Then raise Exception.Create('Запись не существует. Для создания записи в реестре запустите программу с параметром ''-c''. (См. ''-?'')'); {    if Not Reg.KeyExists(cnAppConfigRegPath) Then begin if MessageDlg('Запись ''HKEY_LOCAL_MACHINE'+cnAppConfigRegPath+''' не существует.'#13#10'   Хотите создать такую запись?', mtConfirmation, [mbYes, mbNo], 0) = mrYes Then Begin ChangeSettingsApp:=True; Reg.Free; Exit end else begin Reg.Free; exit; end; end;}
    if Reg.OpenKey(cnAppConfigRegPath, false) then
      begin
        //cnCacheDir:=Reg.ReadString('CacheDir');
{$IFDEF PegasServer}
        cnConnectionString:=Reg.ReadString('ConnectionString');
        cnLocalDataBaseConnectionString{stSecurityConnectionString}:=Reg.ReadString('SecurityConnectionString');
        tmpThreadingModel:=Reg.ReadString('ThreadingModel');
        //cnLog:=Reg.ReadBool('Log');
        cnShowErrors:=Reg.ReadBool('ShowErrors');
        {$Warnings off}NoErrMsg:=Not cnShowErrors;{$warnings on}
        cnDataBaseNamePicture:=Reg.ReadString('DataBaseNamePicture');
        cnDataBaseNamePictureExt:=Reg.ReadString('DataBaseNamePictureExt');
        cnDataBaseNamePictureDate:=Reg.ReadString('DataBaseNamePictureDate');
        try csPipeName:=Reg.ReadString('PipeName'); except end;
        if csPipeName='' then csPipeName:='\\.\pipe\SQLServerToPegasServer';
        if {(cnCacheDir='')or}(cnDataBaseNamePicture='')or(cnDataBaseNamePictureExt='')or(cnDataBaseNamePictureDate='')
            or (cnConnectionString='')or(cnLocalDataBaseConnectionString='') Then raise Exception.Create('Значения не могут быть пустыми');
        if (tmpThreadingModel='tmSingle') Then cnThreadingModel:=tmSingle else
          if tmpThreadingModel='tmApartment' Then cnThreadingModel:=tmApartment else
            if tmpThreadingModel='tmBoth' Then cnThreadingModel:=tmBoth else
              if tmpThreadingModel='tmFree' Then cnThreadingModel:=tmFree else raise Exception.Create('Значения потоковой модели установлены не верно.');
{$ELSE}
        cnEComputerName:=Reg.ReadString('EComputerName');
        Try
          cnEComputerGUID:=Reg.ReadString('EComputerGUID');
          if cnEComputerGUID='' Then raise Exception.Create('stEComputerGUID=''''.');
        Except
          cnEComputerGUID:=GUIDToString(CLASS_AUPegas);
        End;
        cnLocalDataBaseConnectionString:=Reg.ReadString('LocalDataBaseConnectionString');
        tmpThreadingModel:=Reg.ReadString('ThreadingModel');
        //cnLog:=Reg.ReadBool('Log');
        cnCheckSecuretyLDB:=Reg.ReadBool('CheckSecuretyLDB');
        try cnCheckForTriggers:=Reg.ReadBool('CheckForTriggers'); except cnCheckForTriggers:=true; end;
        try cnIgnoreErrorsInSQLParser:=Reg.ReadBool('IgnoreErrorsInSQLParser'); except end;
        cnTableAutoLock:=Reg.ReadBool('TableAutoLock');
        cnShowErrors:=Reg.ReadBool('ShowErrors');
        {$Warnings off}NoErrMsg:=Not cnShowErrors;{$Warnings on}
        cnDataBaseNamePicture:=Reg.ReadString('DataBaseNamePicture');
        cnDataBaseNamePictureExt:=Reg.ReadString('DataBaseNamePictureExt');
        cnDataBaseNamePictureDate:=Reg.ReadString('DataBaseNamePictureDate');
        cnLocalDataType:=Reg.ReadInteger('LocalDataType');
        cnLocalDataBaseName:=Reg.ReadString('LocalDataBaseName');
        if (cnDataBaseNamePicture='')or(cnDataBaseNamePictureExt='')or(cnDataBaseNamePictureDate='')or(cnEComputerName='')or(cnLocalDataBaseConnectionString='') Then raise Exception.Create('Значения не могут быть пустыми');
        if (tmpThreadingModel='tmSingle') Then cnThreadingModel:=tmSingle else
          if tmpThreadingModel='tmApartment' Then cnThreadingModel:=tmApartment else
            if tmpThreadingModel='tmBoth' Then cnThreadingModel:=tmBoth else
              if tmpThreadingModel='tmFree' Then cnThreadingModel:=tmFree else raise Exception.Create('Значения потоковой модели установлены не верно.');
{$ENDIF}
      end
        Else raise Exception.Create('Не удается открыть регистр на чтение.');
    Reg.Free;
  except on e:exception do begin
    Reg.Free;
    e.message:='Ошибка при открытии реестра: ''HKEY_LOCAL_MACHINE'+cnAppConfigRegPath+''''#13#10+e.message;
    raise;
  end;end;
end;

function DetectServerRegName:AnsiString;
  Var tmpReg:TRegistry;
      tmpStringList:TStringList;
      tmpI:Integer;
      tmpStErrHis:ansiString;
      tmpType:Integer;
begin
  Result:='';
  tmpReg:=TRegistry.Create(KEY_READ);
  try
    tmpReg.RootKey:=HKEY_LOCAL_MACHINE;
    if tmpReg.OpenKey('\Software\Eleon\Server\List',False) then Begin
      tmpStringList:=TStringList.Create;
      try
        tmpReg.GetKeyNames(tmpStringList);
        for tmpI:=0 to tmpStringList.Count-1 do begin
          if tmpReg.OpenKey('\Software\Eleon\Server\List\'+tmpStringList.Strings[tmpI],False) then Begin
            try
              if AnsiUpperCase(tmpReg.ReadString('GUID'))=AnsiUpperCase(GUIDToString({$ifdef PegasServer}Pegas_TLB.CLASS_AUPegas{$else}EMServer_TLB.CLASS_EAMServer{$endif})) Then begin
                if AnsiUpperCase(tmpReg.ReadString('MasterGUID'))=AnsiUpperCase(GUIDToString({$ifdef PegasServer}Pegas_TLB{$else}EMServer_TLB{$endif}.CLASS_MasterServer)) Then begin
                  tmpType := tmpReg.ReadInteger('Type');
                  if {$ifdef PegasServer}tmpType=1{$else}(tmpType=2) or (tmpType=3){$endif} Then begin
                    if tmpType = 3 then cnIsEMSClient := true;
                    if AnsiUpperCase(tmpReg.ReadString('PathEXE'))=AnsiUpperCase(ParamStr(0)) Then begin
                      Result:=tmpStringList.Strings[tmpI];//Нешел свою регистрацию
                      Break;
                    end else raise exception.Create('PathEXE: '+AnsiUpperCase(tmpReg.ReadString('PathEXE'))+'<>'+AnsiUpperCase(ParamStr(0)));
                  end else raise exception.Create('Type: '+IntToStr(tmpReg.ReadInteger('Type'))+'<>'+{$ifdef PegasServer}'1'{$else}'2 or 3'{$endif});
                end else raise exception.Create('MasterGUID: '+AnsiUpperCase(tmpReg.ReadString('MasterGUID'))+'<>'+AnsiUpperCase(GUIDToString({$ifdef PegasServer}Pegas_TLB{$else}EMServer_TLB{$endif}.CLASS_MasterServer)));
              end else raise exception.Create('GUID: '+AnsiUpperCase(tmpReg.ReadString('GUID'))+'<>'+AnsiUpperCase(GUIDToString({$ifdef PegasServer}Pegas_TLB.CLASS_AUPegas{$else}EMServer_TLB.CLASS_EAMServer{$endif})));
            except on e:exception do begin
              tmpStErrHis:=tmpStErrHis+'RegName='''+tmpStringList.Strings[tmpI]+'''=>'''+e.Message+'''.';
            end;{Raise Exception.Create('Неправильная регистрационная запись.');}end;
          end;
        end;
        if tmpI>tmpStringList.Count-1 Then begin
          raise exception.create('Сервер не найден в списке регистраций('+tmpStErrHis+').');
        end;
      finally
        FreeAndNil(tmpStringList);
      end;
    End else raise Exception.Create('Список регистраций не найден.');
  finally
    FreeAndNil(tmpReg);
  end;
  if Result='' then raise Exception.Create('Сервер не найден в списке регистраций.');
end;

procedure RegStartedServer;
  Var tmpReg:TRegistry;
begin
  if cnProcessID=0 Then raise Exception.Create('cnProcessID is 0.');
  tmpReg:=TRegistry.Create(KEY_WRITE);
  try
    Try
      tmpReg.RootKey:=HKEY_LOCAL_MACHINE;
      if tmpReg.OpenKey('\Software\Eleon\Server\List\'+cnServerRegName+'\Started',True) then Begin
        tmpReg.WriteString(IntToStr(cnProcessID), FormatDateTime('ddmmyy hh:nn:ss.zzz', Now)+' '+'STARTED');
      End;
    Except on e:exception do
      IAppMessage(cnTray.Query(IAppMessage)).ITMessAdd(Now, Now, 'stServerUserName', 'RunApp.StartUp', 'RegStartedServer(Ignored): '+e.message, mecApp, mesError);
    End;
  finally
    FreeAndNil(tmpReg);
  end;
end;

procedure UnRegStartedServer;
  Var tmpReg:TRegistry;
begin
  if cnServerRegName='' Then Exit;
  tmpReg:=TRegistry.Create(KEY_READ Or KEY_WRITE);
  try
    Try
      tmpReg.RootKey:=HKEY_LOCAL_MACHINE;
      if tmpReg.OpenKey('\Software\Eleon\Server\List\'+cnServerRegName+'\Started',False) then Begin
        tmpReg.DeleteValue(IntToStr(cnProcessID));
      End;
    Except End;
  finally
    FreeAndNil(tmpReg);
  end;
end;

procedure SetMessage(aStartTime:TDateTime; const aMessage:AnsiString);
begin
  if assigned(cnAppMessage)and(assigned(cnLogFile)) then cnAppMessage.ITMessAdd(aStartTime, now, '', 'TRAY', aMessage, mecApp, mesInformation);
end;

procedure SetErrorMessage(aStartTime:TDateTime; const aMessage:AnsiString; aHelpContext:Integer);
begin
  if assigned(cnAppMessage)and(assigned(cnLogFile)) then cnAppMessage.ITMessAdd(aStartTime, now, '', 'TRAY', aMessage+'/HC='+IntToStr(aHelpContext), mecApp, mesError);
end;

procedure RegSetServerError(const aMessage:AnsiString; aHelpContext:Integer);
  Var tmpReg:TRegistry;
begin
  if cnServerRegName='' then exit;
  tmpReg:=TRegistry.Create(KEY_WRITE);
  try
    try
      tmpReg.RootKey:=HKEY_LOCAL_MACHINE;
      if tmpReg.OpenKey('\Software\Eleon\Server\List\'+cnServerRegName, true) then Begin
        tmpReg.WriteString('LastError', 'PID='+IntToStr(GetCurrentProcessID)+' '+FormatDateTime('ddmmyy hh:nn:ss.zzz', Now)+' '+aMessage+'/HC='+IntToStr(aHelpContext));
      End;
    Except on e:exception do
      try if assigned(cnTray) then IAppMessage(cnTray.Query(IAppMessage)).ITMessAdd(Now, Now, '', 'RunApp.StartUp', 'RegSetServerError(Ignored): '+e.message, mecApp, mesError);except end; 
    End;
  finally
    FreeAndNil(tmpReg);
  end;
end;

procedure RegClearServerError;
  Var tmpReg:TRegistry;
begin
  if cnServerRegName='' then exit;
  tmpReg:=TRegistry.Create(KEY_WRITE);
  try
    try
      tmpReg.RootKey:=HKEY_LOCAL_MACHINE;
      if tmpReg.OpenKey('\Software\Eleon\Server\List\'+cnServerRegName, true) then tmpReg.DeleteValue('LastError');
    except on e:exception do
      try if assigned(cnTray) then IAppMessage(cnTray.Query(IAppMessage)).ITMessAdd(Now, Now, '', 'RunApp.StartUp', 'RegSetServerError(Ignored): '+e.message, mecApp, mesError);except end;
    end;
  finally
    FreeAndNil(tmpReg);
  end;
end;

end.
