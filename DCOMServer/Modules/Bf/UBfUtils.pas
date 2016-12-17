//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UBfUtils;

interface
  {$IFDEF VER130}uses UVer130Types;{$ENDIF}
  function glConvertToTableBfLocation(const aCachePath, aPath, aFileName:AnsiString; aUsedCachePath:PBoolean):AnsiString;overload;
  function glConvertToTableBfLocation(const aCachePath, aFilePath:AnsiString; aUsedCachePath:PBoolean):AnsiString;overload;
  function glUsedCachePath(const aTBfPath:AnsiString):Boolean;
implementation
  uses Sysutils;

function glUsedCachePath(Const aTBfPath:AnsiString):Boolean;
  var ltmpLength:Integer;
begin
  ltmpLength:=Length(aTBfPath);
  if (ltmpLength=0)or(not(((ltmpLength>1)and(aTBfPath[1]='\')and(aTBfPath[2]='\'))or(ltmpLength>1)and(aTBfPath[2]=':'))) then begin
    Result:=True;
  end else result:=false;
end;

function glConvertToTableBfLocation(const aCachePath, aPath, aFileName:AnsiString; aUsedCachePath:PBoolean):AnsiString;
  var tmpFilePath:AnsiString;
begin
  if (aPath<>'')and(aPath[Length(aPath)]<>'\') then tmpFilePath:=aPath+'\'+aFileName else tmpFilePath:=aPath+aFileName;
  result:=glConvertToTableBfLocation(aCachePath, tmpFilePath, aUsedCachePath);
end;

function glConvertToTableBfLocation(const aCachePath, aFilePath:AnsiString; aUsedCachePath:PBoolean):AnsiString;
begin
  if aFilePath='' then raise exception.create('aFilePath empty.');
  if glUsedCachePath(aFilePath) then begin
    result:=aCachePath+aFilePath;
    if assigned(aUsedCachePath) then aUsedCachePath^:=true;
  end else begin
    Result:=aFilePath;
    if assigned(aUsedCachePath) then aUsedCachePath^:=false;
  end;
end;

end.
