unit UPipeEClientUtils;

interface
  Procedure EClientStoredProcViaCallNamedPipe(Const aPipeName, aProcName, aProcParams:AnsiString);

implementation
  uses Sysutils, UErrorConsts, UPipeServerUtils, Windows;
  
Procedure EClientStoredProcViaCallNamedPipe(Const aPipeName, aProcName, aProcParams:AnsiString);
  var tmpIn, tmpInSize:Cardinal;
      tmpOut:AnsiString;
      tmpMemPointer, tmpPointer:Pointer;
      tmpMess:AnsiString;
      tmpHC:Integer;
begin
  tmpOut:=aProcName+#0+aProcParams;
  tmpOut:=psuIntegerToString(Length(tmpOut))+tmpOut;
  GetMem(tmpMemPointer, 8192);//выделяю память под данные
  try
    if not CallNamedPipe(PChar(aPipeName),
                          PChar(tmpOut),
                          Length(tmpOut),
                          tmpMemPointer{@tmpIn},
                          8192{Sizeof(tmpIn)},
                          tmpInSize,
                          NMPWAIT_USE_DEFAULT_WAIT
                         ) then Raise Exception.Create(SysErrorMessage(GetLastError));
    tmpHC:=-1;
    if tmpInSize>0 then tmpIn:=PCardinal(tmpMemPointer)^ else tmpIn:=0;
    if tmpIn>0 then begin//Есть ошибка
      If (tmpIn+5)>8192 then begin
        tmpPointer:=Pointer(Cardinal(tmpMemPointer)+8192);
      end else begin
        if tmpIn<4 then begin
          Raise Exception.CreateFmtHelp(cserInternalError, ['tmpIn<4, invalid result.'], cnerInternalError);
        end else begin
          tmpPointer:=Pointer(Cardinal(tmpMemPointer)+4);
          tmpHC:=PInteger(tmpPointer)^;
          tmpPointer:=Pointer(Cardinal(tmpMemPointer)+tmpIn+4);
        end;
      end;
      PChar(tmpPointer)^:=#0;
      tmpMess:=PChar(Cardinal(tmpMemPointer)+8);
      Raise Exception.CreateHelp(tmpMess, tmpHC);
    end;
  finally
    FreeMem(tmpMemPointer);
  end;
end;

end.
