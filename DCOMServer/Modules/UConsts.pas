unit UConsts;

interface
  Uses Messages;
Var
  stComputerName:AnsiString='';
  stShortComputerName:AnsiString='';
  AppStartDateTime:TDateTime=0;

implementation
  Uses Windows;

Function GetComputerName:AnsiString;
Var st: PChar;
    Len : Cardinal;
Begin
  Len:=80;
  GetMem(st,80);
  Windows.GetComputerName(st,Len);
  Result:=st;
  FreeMem(st, 80);
end;

initialization
  stComputerName:=GetComputerName;
finalization
  stComputerName:='';
end.
