//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UELoginUtils;

interface

  function CheckForRole(const aSecurityContext:variant; const aRole:AnsiString):boolean;

implementation
  uses {$ifndef ver130}variants, {$endif}SysUtils;

function CheckForRole(const aSecurityContext:variant; const aRole:AnsiString):boolean;
  var tmpI:integer;
begin
  result := false;
  if not VarIsArray(aSecurityContext) then exit;
  for tmpI := VarArrayLowBound(aSecurityContext, 1) to VarArrayHighBound(aSecurityContext, 1) do begin
    if AnsiUpperCase(AnsiString(VarToStr(aSecurityContext[tmpI]))) = AnsiUpperCase(aRole) then begin
      result := true;
      exit;
    end;
  end;
end;

end.
