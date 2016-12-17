//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit USysUtils;

interface

  Function GetLocalComputerName:AnsiString;

implementation
  Uses Windows;

Function GetLocalComputerName:AnsiString;
  Type PWord = ^Word;
  Var tmpPChar:PChar;
      tmpLen:Cardinal;
Begin
  tmpLen:=80;
  GetMem(tmpPChar, 80);
  GetComputerName(tmpPChar, tmpLen);
  Result:=tmpPChar;
  FreeMem(tmpPChar, 80);
end;

end.
