unit UPipeServerUtils;

interface
  function psuIntegerToString(aInteger:Integer):AnsiString;
implementation

function psuIntegerToString(aInteger:Integer):AnsiString;
  var ltmpI:Integer;
      ltmpByte:byte;
begin
  Result:='';
  For ltmpI:=0 to 3 do begin
    ltmpByte:=(aInteger shr (ltmpI*8)) and $000000FF;
    Result:=Result+Chr(ltmpByte);
  end;
end;

end.
