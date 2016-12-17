//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTrayTypes;

interface
  uses UTrayInterfaceTypes;
{$ifdef ver130}
  type PBoolean=^Boolean;
{$endif}
  
type
  PTrayQueryMode=^TTrayQueryMode;
  TTrayQueryMode=record
    aRaise:boolean;
  end;
  TTrayMessageEvent=procedure(aStartTime:TDateTime; Const aMessage:AnsiString);
  TTrayErrorMessageEvent=procedure(aStartTime:TDateTime; Const aMessage:AnsiString; aHelpContext:Integer);
  ITray=interface
  ['{B8AEE0B3-6AD2-42D5-BAEB-E40C97F3287B}']
    function Get_InitedTray:boolean;
    function Get_StartedTray:boolean;
    function GetTrayMessage:TTrayMessageEvent;
    function GetTrayErrorMessage:TTrayErrorMessageEvent;
    procedure SetTrayMessage(aTrayMessage:TTrayMessageEvent);
    procedure SetTrayErrorMessage(aTrayErrorMessage:TTrayErrorMessageEvent);
    function InitTray(aRaise:boolean=true):boolean;
    function StartTray(aRaise:boolean=true):boolean;
    function StopTray(aRaise:boolean=true):boolean;
    function FinalTray(aRaise:boolean=true):boolean;
    procedure Push(aIUnknown:IUnknown);
    function Query(const aGUID:TGUID; out Obj; aRaise:boolean):boolean;overload;
    function Query(const aGUID:TGUID; out Obj; aTrayQueryMode:PTrayQueryMode=nil):boolean;overload;
    function Query(const aGUID:TGUID; aTrayQueryMode:PTrayQueryMode=nil; aResult:PBoolean=nil):IUnknown;overload;
    function Query(const aGUID:TGUID; aRaise:boolean; aResult:PBoolean=nil):IUnknown;overload;
    property InitedTray:boolean read Get_InitedTray;
    property StartedTray:boolean read Get_StartedTray;
    property OnTrayMessage:TTrayMessageEvent read GetTrayMessage write SetTrayMessage;
    property OnTrayErrorMessage:TTrayErrorMessageEvent read GetTrayErrorMessage write SetTrayErrorMessage;
    function ReViewTopPriorities(aRaise:boolean=true):boolean;
  end;
const
  cnTrayQueryModeDef:TTrayQueryMode=(aRaise:true;);
implementation

end.
