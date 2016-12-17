//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTagStringUtils;

interface

  function GetTagValue(const aTagString:AnsiString; const aTagName:AnsiString; aRaise:boolean):AnsiString;

implementation
  uses Sysutils, UStringUtils;

function GetTagValue(const aTagString:AnsiString; const aTagName:AnsiString; aRaise:boolean):AnsiString;
  var tmpPos, tmpTagPos:integer;
      tmpCurrentTag, tmpTagName:AnsiString;
begin
  if (aTagName = '') or (aTagString = '') then raise exception.create('Input values is empty.');
  result := '';
  tmpPos := -1;
  while(true) do begin
    tmpCurrentTag := UStringUtils.GetParamFromParamsStr(tmpPos, aTagString, ';');
    if tmpPos = -1 then begin
      if aRaise then raise exception.create('Tag '''+aTagName+''' no found.');
      break;
    end;  
    tmpTagPos := -1;
    tmpTagName := UStringUtils.GetParamFromParamsStr(tmpTagPos, tmpCurrentTag, '=');
    if AnsiUpperCase(tmpTagName) = AnsiUpperCase(aTagName) then begin//нашел интерисующий тэг
      result := copy(tmpCurrentTag, tmpTagPos, Length(tmpCurrentTag) - tmpTagPos + 1);
      break;
    end;
  end;
end;

end.
