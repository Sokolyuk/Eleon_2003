unit UAppMessageConsts;

interface
  Uses Graphics, UAppMessageTypes;
Const
  csmecApp:AnsiString='App';
  csmecSQL:AnsiString='SQL';
  csmecDebug:AnsiString='Dedug';
  csmecSecurity:AnsiString='Secur';
  csmecTransport:AnsiString='Transport';
  csmecTransfer:AnsiString='Transfer';
  csmecUnknown:AnsiString = '???';
  clbcsmecSQL:TColor=clAqua{16773836};
  clbcsmecDebug:TColor=clGray{15657706};
  clbcsmecSecurity:TColor=clLime{14810077};
  clbcsmecTransport:TColor=clOlive{0068AEDD};
  clbcsmecTransfer:TColor=clBlue;
  clbcsmecUnknown:TColor=clFuchsia{00B9FBFD};
  // ..
  clfcsmecSQL:TColor=clBlack;
  clfcsmecDebug:TColor=clBlack;
  clfcsmecSecurity:TColor=clBlack;
  clfcsmecTransport:TColor=clWhite;
  clfcsmecTransfer:TColor=clWhite;
  clfcsmecUnknown:TColor=clBlack;
  //log style
  csmesInformation:AnsiString ='Info';
  csmesError:AnsiString ='Error';
  csmesWarning:AnsiString ='Warning';
  csmesUnknown:AnsiString ='???';
  clbcsmesError:TColor=clRed{2302963};
  clbcsmesWarning:TColor=clYellow{65535};
  clbcsmesUnknown:TColor=clFuchsia{00B9FBFD};
  clfcsmesError:TColor=clWhite;
  clfcsmesWarning:TColor=clBlack;
  clfcsmesUnknown:TColor=clBlack;
var cnAppMessage:IAppMessage=nil;
implementation
initialization
finalization
  try cnAppMessage:=nil;except end;
end.
