unit ULogMessageConsts;
устарел
interface
  Uses Graphics;
Const
  //Общая для Пегаса и М-Сервенра секция
  //Названия объектов программы
  stASMName            :AnsiString = 'ASM';
  //stFormName           : AnsiString = '*Frm';
//  stUserServer         : AnsiString = '*Srv';
  stThrServantTeam     :AnsiString = '*Mt';
  stThreadEvents       :AnsiString = ''{TE'};
  stThreadServant      :AnsiString = ''{TS'};
  stThreadASM          :AnsiString = ''{TA'};
  stThreadForm         :AnsiString = ''{TF'};
  // Log Class
  stmecApp            :AnsiString='App';
  stmecSQL            :AnsiString='SQL';
  stmecDebug          :AnsiString='Dedug';
  stmecSecurity       :AnsiString='Secur';
  stmecTransport      :AnsiString='Transport';
  stmecTransfer       :AnsiString='Transfer';
  stmecUnknown        :AnsiString = '?????';
  clbstmecSQL:TColor= clAqua{16773836};
  clbstmecDebug:TColor= clGray{15657706};
  clbstmecSecurity:TColor= clLime{14810077};
  clbstmecTransport:TColor= clOlive{0068AEDD};
  clbstmecTransfer:TColor= clBlue;
  clbstmecUnknown:TColor= clFuchsia{00B9FBFD};
  // ..
  clfstmecSQL           :TColor= clBlack;
  clfstmecDebug         :TColor= clBlack;
  clfstmecSecurity      :TColor= clBlack;
  clfstmecTransport     :TColor= clWhite;
  clfstmecTransfer       :TColor=clWhite;
  clfstmecUnknown       :TColor= clBlack;
  // Log Type
  stmesInformation     : AnsiString = 'Info';
  stmesError           : AnsiString = 'Error';
  stmesWarning         : AnsiString = 'Warning';
  stmesUnknown         : AnsiString = '?????';
  clbstmesError         : TColor     = clRed{2302963};
  clbstmesWarning       : TColor     = clYellow{65535};
  clbstmesUnknown       : TColor     = clFuchsia{00B9FBFD};
  clfstmesError         :TColor     = clWhite;
  clfstmesWarning       :TColor     = clBlack;
  clfstmesUnknown       :TColor     = clBlack;

implementation

end.
