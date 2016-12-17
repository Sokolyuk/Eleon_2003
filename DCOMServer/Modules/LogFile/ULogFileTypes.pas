//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit ULogFileTypes;

interface                                             
Type
  ILogFile=Interface
  ['{45C690A6-876A-4944-BA74-6DEA284B28D0}']
    function ITGetErrorToRaise:Boolean; {FErrorToRaise}
    procedure ITSetErrorToRaise(value:Boolean);
    function ITGetOpened:Boolean;{FOpened}
    function ITGetWriteSelfMess:Boolean;{FWriteSelfMess}
    procedure ITSetWriteSelfMess(value:Boolean);
    function ITGetCountMessToAutoChangeFileName:Integer;
    procedure ITSetCountMessToAutoChangeFileName(value:Integer);{FCountMessToAutoChangeFileName}
    function ITGetCountMessAutoChangeFileName:Integer;{FCountMessAutoChangeFileName}
    function ITGetCountMess:Integer;{FCountMess}
    function ITGetFileName:AnsiString;{FFileName}
    function ITGetAddToFileNameCurrentDataTimeAtOpen:Boolean;
    procedure ITSetAddToFileNameCurrentDataTimeAtOpen(value:Boolean);{FAddToFileNameCurrentDataTime}
    procedure ITWriteToLog(const value:AnsiString; blIndicateTime:boolean=True);
    procedure ITWriteLnToLog(const value:AnsiString; blIndicateTime:boolean=True);
    function ITGetOverrideExists:boolean;
    procedure ITSetOverrideExists(value:Boolean);
    procedure ITOpenLog;
    procedure ITCloseLog;
    property ITErrorToRaise:Boolean read ITGetErrorToRaise write ITSetErrorToRaise;
    property ITOpened:boolean read ITGetOpened;
    property ITWriteSelfMess:boolean read ITGetWriteSelfMess write ITSetWriteSelfMess;
    property ITCountMessToAutoChangeFileName:Integer read ITGetCountMessToAutoChangeFileName write ITSetCountMessToAutoChangeFileName;
    property ITCountMessAutoChangeFileName:Integer read ITGetCountMessAutoChangeFileName;
    property ITCountMess:Integer read ITGetCountMess;
    property ITFileName:AnsiString read ITGetFileName;
    property ITAddToFileNameCurrentDataTimeAtOpen:Boolean read ITGetAddToFileNameCurrentDataTimeAtOpen write ITSetAddToFileNameCurrentDataTimeAtOpen;
    property ITOverrideExists:boolean read ITGetOverrideExists write ITSetOverrideExists;
  End;

implementation

end.
