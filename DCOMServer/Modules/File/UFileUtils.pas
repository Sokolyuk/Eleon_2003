unit UFileUtils;

interface
  Uses Windows, UFileUtilsTypes;

  Function fuOpenFile(Const aFileName:AnsiString; Out aFileHandle:THandle; aRaise:Boolean=True):Boolean;
  function fuGetFileInfo(aFileHandle:THandle; aFileInfo:PByHandleFileInformation; aRaise:Boolean=true):Boolean;
  function fuGetFileInfoByFileName(Const aFileName:AnsiString; aFileInfo:PByHandleFileInformation; aRaise:Boolean=true):Boolean;

implementation
  Uses SysUtils;

Function fuOpenFile(Const aFileName:AnsiString; Out aFileHandle:THandle; aRaise:Boolean=True):Boolean;
begin
  aFileHandle:=CreateFile(PChar(aFileName), GENERIC_READ, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  If (aFileHandle=0)Or(aFileHandle=$FFFFFFFF) then begin
    If aRaise Then Raise Exception.Create(SysErrorMessage(GetLastError)+'('+aFileName+').');
    Result:=False;
    Exit;
  end;
  Result:=True;
end;

function fuGetFileInfo(aFileHandle:THandle; aFileInfo:PByHandleFileInformation; aRaise:Boolean=true):Boolean;
begin
  Result:=Assigned(aFileInfo);
  If Not Result Then begin
    If aRaise Then raise Exception.Create('aFileInfo is not assigned.');
    Exit;
  end;
  FillChar(aFileInfo^, SizeOf(aFileInfo^), 0);
  If Not GetFileInformationByHandle(aFileHandle, aFileInfo^) Then begin
    If aRaise Then raise Exception.Create(SysErrorMessage(GetLastError));
    Result:=False;
    Exit;
  end;
  Result:=True;
end;

function fuGetFileInfoByFileName(Const aFileName:AnsiString; aFileInfo:PByHandleFileInformation; aRaise:Boolean=true):Boolean;
  Var tmpHandle:THandle;
begin
  If Not fuOpenFile(aFileName, tmpHandle, aRaise) Then begin
    Result:=False;
    Exit;
  end;
  try
    Result:=fuGetFileInfo(tmpHandle, aFileInfo, aRaise);
  finally
    CloseHandle(tmpHandle);
  end;
end;

end.
