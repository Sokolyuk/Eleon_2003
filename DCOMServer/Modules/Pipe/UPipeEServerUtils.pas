unit UPipeEServerUtils;

interface
  uses UPipeServerBaseTypes;
  procedure EServerStoredProcViaCallNamedPipe(aNamedPipe:INamedPipe; Out aProcName, aProcParams:AnsiString);

implementation
  uses windows, Sysutils, UErrorConsts, UPipeServerUtils;
  
procedure EServerStoredProcViaCallNamedPipe(aNamedPipe:INamedPipe; Out aProcName, aProcParams:AnsiString);
  Var tmpRet:Boolean;
      tmpOverlapped:TOverlapped;
      tmpOutSize:Cardinal;
      tmpDataSize:Cardinal;
      tmpResultString:AnsiString;
      tmpMemPointerSize:Cardinal;
      tmpMemPointer:Pointer;
      tmpEvent:THandle;
      tmpPointer:Pointer;
begin
  If not assigned(aNamedPipe) Then Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['aNamedPipe'], cnerInvalidValueOf);
  //„итаю заголовок(4байта)
  tmpEvent:=aNamedPipe.EventWait;
  Fillchar(tmpOverlapped, Sizeof(tmpOverlapped), 0);
  tmpOverlapped.hEvent:=aNamedPipe.EventWait;
  ResetEvent(aNamedPipe.EventWait);//—тавлю флаг клиента обратно в 0.
  //..
  tmpMemPointerSize:=0;
  tmpDataSize:=0;
  //grab whatever's coming through the pipe...
  tmpRet:=ReadFile(aNamedPipe.Pipe,              // file to read from
                   tmpDataSize,        // address of input buffer
                   SizeOf(tmpDataSize),// number of bytes to read
                   tmpMemPointerSize,    // number of bytes read
                   @tmpOverlapped);    // overlapped stuff, not needed
  If (Not tmpRet)And(GetLastError=ERROR_IO_PENDING) Then begin
    Case WaitForMultipleObjects(1, @tmpEvent, FALSE, INFINITE ) of   //ERROR_MORE_DATA
      WAIT_OBJECT_0:begin//клиент сделал запись
        //Ok.
      end;
{      WAIT_OBJECT_0+1:begin//остановка сервера
        Exit;
      end;}
    else
      Raise Exception.Create('Unknown result of WaitForMultipleObjects.');
    end;
  end;
  //If FMemPointerSize=0 then continue;//если ничего не получил, значит плохие данные, читаю др.
  If tmpDataSize>10240000{10mb}then Raise Exception.Create('tmpDataSize='+IntToStr(tmpDataSize)+'>10240000{10mb}.');
  //читаю данные
  GetMem(tmpMemPointer, tmpDataSize);//выдел€ю пам€ть под данные
  try
    Fillchar(tmpOverlapped, Sizeof(tmpOverlapped), 0);
    tmpOverlapped.hEvent:=aNamedPipe.EventWait;
    ResetEvent(aNamedPipe.EventWait);//—тавлю флаг клиента обратно в 0.
    //..
    tmpMemPointerSize:=0;
    //grab whatever's coming through the pipe...
    tmpRet:=ReadFile(aNamedPipe.Pipe,            // file to read from
                     tmpMemPointer^,     // address of input buffer
                     tmpDataSize,      // number of bytes to read
                     tmpMemPointerSize,  // number of bytes read
                     @tmpOverlapped);  // overlapped stuff, not needed
    If (Not tmpRet)And(GetLastError=ERROR_IO_PENDING) Then begin
      Case WaitForMultipleObjects(1, @tmpEvent, FALSE, INFINITE ) of
        WAIT_OBJECT_0:begin//клиент сделал запись
          //Ok.
        end;
        {WAIT_OBJECT_0+1:begin//остановка сервера
          Exit;
        end;}
      else
        Raise Exception.Create('Unknown result of WaitForMultipleObjects.');
      end;
    end;
    //..
     If tmpMemPointerSize=0 then Exit;//если ничего не получил, значит плохие данные, читаю др.
    //..
    try
      tmpResultString:='';//no error
      //..
      if (tmpMemPointerSize=0)Or(Not Assigned(tmpMemPointer)) then Raise Exception.Create('Invalid call-params.');;
      aProcName:=PChar(tmpMemPointer);
      SetLength(aProcParams, Integer(tmpMemPointerSize)-Length(aProcName)-1);
      tmpPointer:=Pointer(Cardinal(Length(aProcName))+Cardinal(tmpMemPointer)+1);
      Move(tmpPointer^, PChar(aProcParams)^, Length(aProcParams));
    except on e:exception do begin
      tmpResultString:=psuIntegerToString(e.helpcontext)+tmpResultString+e.message;
    end;end;
    tmpResultString:=psuIntegerToString(Length(tmpResultString))+tmpResultString;
  finally
    FreeMem(tmpMemPointer);
    //tmpMemPointer:=Nil;
  end;
  //..
  Fillchar(tmpOverlapped, Sizeof(tmpOverlapped), 0);
  tmpOverlapped.hEvent:=aNamedPipe.EventWait;
  ResetEvent(aNamedPipe.EventWait);//—тавлю флаг клиента обратно в 0.
  // send it back out...
  tmpRet:=WriteFile(aNamedPipe.Pipe,                    // file to write to
                    PChar(tmpResultString)^,  // address of output buffer
                    Length(tmpResultString),  // number of bytes to write
                    tmpOutSize,               // number of bytes written
                    @tmpOverlapped);          // overlapped stuff, not needed
  If (Not tmpRet)And(GetLastError=ERROR_IO_PENDING) Then begin
    Case WaitForMultipleObjects(1, @tmpEvent, FALSE, INFINITE ) of
      WAIT_OBJECT_0:begin//клиент сделал запись
        //Ok.
      end;
      {WAIT_OBJECT_0+1:begin//остановка сервера
        Exit;
      end;}
    else
      Raise Exception.Create('Unknown result of WaitForMultipleObjects.');
    end;
  end;
end;

end.
