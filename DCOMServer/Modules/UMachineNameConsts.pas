//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UMachineNameConsts;
interface
Var
  cnMachineName:AnsiString='';
  cnMachineSName:AnsiString='';

implementation
  Uses Windows, Sysutils;

Function GetMachineName:AnsiString;
Var tmpPChar:PChar;
    tmpLen:Cardinal;
Begin
  tmpLen:=80;
  GetMem(tmpPChar, 80);
  Windows.GetComputerName(tmpPChar, tmpLen);
  Result:=tmpPChar;
  FreeMem(tmpPChar, 80);
end;

initialization
  cnMachineName:=GetMachineName;
  If Length(cnMachineName)>1 Then begin
    If pos('SHOP', AnsiUpperCase(cnMachineName))=1 Then begin
      If Length(cnMachineName)>4 Then cnMachineSName:='S'+AnsiUpperCase(cnMachineName[5]) Else cnMachineSName:='S_';
    end else begin
      cnMachineSName:=AnsiUpperCase(cnMachineName[1]+cnMachineName[Length(cnMachineName)]);
    end;
  end;                              
finalization
  cnMachineName:='';
  cnMachineSName:='';
end.
