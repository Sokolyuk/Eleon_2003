//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UAppMessageTypes;

interface

Type
  TMessageClass=({0}mecApp, {1}mecSQL, {2}mecSecurity, {3}mecDebug, {4}mecTransport, {5}mecTransfer, mecReserve7, mecReserve8, mecReserve9, mecReserve10, mecReserve11, mecReserve12, mecReserve13, mecReserve14, mecReserve15, mecReserve16, mecReserve17, mecReserve18, mecReserve19,
                    mecReserve20, mecReserve21, mecReserve22, mecReserve23, mecReserve24, mecReserve25, mecReserve26, mecReserve27, mecReserve28, mecReserve29, mecReserve30, mecReserve31, mecReserve32);
  TMessageStyle=({0}mesError, {1}mesInformation, {2}mesWarning, mesReserve4, mesReserve5, mesReserve6, mesReserve7, mesReserve8, mesReserve9, mesReserve10, mesReserve11, mesReserve12, mesReserve13, mesReserve14, mesReserve15, mesReserve16, mesReserve17, mesReserve18, mesReserve19,
                    mesReserve20, mesReserve21, mesReserve22, mesReserve23, mesReserve24, mesReserve25, mesReserve26, mesReserve27, mesReserve28, mesReserve29, mesReserve30, mesReserve31, mesReserve32);
  TMessageClasses=set of TMessageClass;
  TMessageStyles=set of TMessageStyle;

  IAppMessage=interface
  ['{66BC8967-476B-4471-BF55-AC5F73F27BEA}']
    procedure ITMessAdd(aStartTime, aEndTime:TDateTime; Const aUser, aSource, aMessage:AnsiString; aMessageClass:TMessageClass; aMessageStyle:TMessageStyle);
    function ITGetNewMess(Var aLastMessage:Longint; aClasses:TMessageClasses; aStyles:TMessageStyles):Variant;
    procedure ITMessToBasicLog(Const aMessage:AnsiString; aIndicateTime:boolean=True);
    function Get_MessCountClassApp:Integer;
    function Get_MessCountClassSQL:Integer;
    function Get_MessCountClassDebug:Integer;
    function Get_MessCountClassSecurity:Integer;
    function Get_MessCountClassTransport:Integer;
    function Get_MessCountClassTransfer:Integer;
    function Get_MessCountStyleError:Integer;
    function Get_MessCountStyleInfo:Integer;
    function Get_MessCountStyleWarning:Integer;
    function Get_MessCountAll:Integer;
    function Get_MessagesMaxCount:cardinal;
    procedure Set_MessagesMaxCount(value:cardinal);
    property MessCountClassApp:Integer read Get_MessCountClassApp;
    property MessCountClassSQL:Integer read Get_MessCountClassSQL;
    property MessCountClassDebug:Integer read Get_MessCountClassDebug;
    property MessCountClassSecurity:Integer read Get_MessCountClassSecurity;
    property MessCountClassTransport:Integer read Get_MessCountClassTransport;
    property MessCountClassTransfer:Integer read Get_MessCountClassTransfer;
    property MessCountStyleError:Integer read Get_MessCountStyleError;
    property MessCountStyleInfo:Integer read Get_MessCountStyleInfo;
    property MessCountStyleWarning:Integer read Get_MessCountStyleWarning;
    property MessCountAll:Integer read Get_MessCountAll;
    property MessagesMaxCount:cardinal read Get_MessagesMaxCount write Set_MessagesMaxCount; 
  end;

implementation

end.
