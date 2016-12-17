unit UAppMessageUtils;

interface
  uses UAppMessageTypes;
  Function MessageClassToStr(aMessageClass:TMessageClass):AnsiString;
  Function StrToMessageClass(Const aString:AnsiString):TMessageClass;
  Function MessageStyleToStr(aMessageStyle:TMessageStyle):AnsiString;
  Function StrToMessageStyle(Const aString:AnsiString):TMessageStyle;
implementation
  uses UAppMessageConsts, Sysutils;

Function MessageClassToStr(aMessageClass:TMessageClass):AnsiString;
begin
  Case aMessageClass of
    mecApp:Result:=csmecApp;
    mecSQL:Result:=csmecSQL;
    mecDebug:Result:=csmecDebug;
    mecSecurity:Result:=csmecSecurity;
    mecTransport:Result:=csmecTransport;
    mecTransfer:Result:=csmecTransfer;
  Else
    Result:=csmecUnknown;
  End;
end;

Function StrToMessageClass(Const aString:AnsiString):TMessageClass;
begin
  If UpperCase(aString)=UpperCase(csmecApp) then Result:=mecApp else
  If UpperCase(aString)=UpperCase(csmecSQL) then Result:=mecSQL else
  If UpperCase(aString)=UpperCase(csmecDebug) then Result:=mecDebug else
  If UpperCase(aString)=UpperCase(csmecSecurity) then Result:=mecSecurity else
  If UpperCase(aString)=UpperCase(csmecTransport) then Result:=mecTransport else
  If UpperCase(aString)=UpperCase(csmecTransfer) then Result:=mecTransfer else
      Raise Exception.Create('Unknown value '''+aString+''' of MessageClass.');
end;

Function MessageStyleToStr(aMessageStyle:TMessageStyle):AnsiString;
begin
  Case aMessageStyle of
    mesError:Result:=csmesError;
    mesInformation:Result:=csmesInformation;
    mesWarning:Result:=csmesWarning;
  Else
    Result:=csmesUnknown;
  End;
end;

Function StrToMessageStyle(Const aString:AnsiString):TMessageStyle;
begin
  If UpperCase(aString)=UpperCase(csmesError) then Result:=mesError else
    If UpperCase(aString)=UpperCase(csmesInformation) then Result:=mesInformation else
      If UpperCase(aString)=UpperCase(csmesWarning) then Result:=mesWarning else Raise Exception.Create('Unknown value '''+aString+''' of MessageStyle.');
end;



end.
