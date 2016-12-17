//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UConfigureCoEventsCnnTypes;

interface
type
  TPingEvent=procedure of object;
  TPackASyncEvent=procedure(const aSecurityContext, aPack:Variant) of object;
  TPackSyncEvent=procedure(const aSecurityContext:Variant; var aPack:OleVariant) of object;
  TSysMessageEvent=procedure(const aSender, aMessage:AnsiString) of object;
  TQueryInterfaceEvent=procedure(const aSecurityContext, aGuid:Variant; out aInterface:IDispatch) of object;
  TQueryInterfaceByLevelEvent=procedure(const aSecurityContext:Variant; aLevel:integer; const aGuid:Variant; out aInterface:IDispatch) of object;
  TQueryInterfaceByNodeNameEvent=procedure(const aSecurityContext:Variant; const aNodeName:AnsiString; const aGuid:Variant; out aInterface:IDispatch) of object;
  IConfigureCoEventsCnn=interface
  ['{9E096467-BAD0-48C7-95B3-0712EF060AE6}']
    function GetOnPing:TPingEvent;
    procedure SetOnPing(value:TPingEvent);
    property OnPing:TPingEvent read GetOnPing write SetOnPing;
    function GetOnPackASync:TPackASyncEvent;
    procedure SetOnPackASync(value:TPackASyncEvent);
    property OnPackASync:TPackASyncEvent read GetOnPackASync write SetOnPackASync;
    function GetOnPackSync:TPackSyncEvent;
    procedure SetOnPackSync(value:TPackSyncEvent);
    property OnPackSync:TPackSyncEvent read GetOnPackSync write SetOnPackSync;
    function GetOnSysMessage:TSysMessageEvent;
    procedure SetOnSysMessage(value:TSysMessageEvent);
    property OnSysMessage:TSysMessageEvent read GetOnSysMessage write SetOnSysMessage;
    function GetOnQueryInterface:TQueryInterfaceEvent;
    procedure SetOnQueryInterface(value:TQueryInterfaceEvent);
    property OnQueryInterface:TQueryInterfaceEvent read GetOnQueryInterface write SetOnQueryInterface;
    function GetOnQueryInterfaceByLevel:TQueryInterfaceByLevelEvent;
    procedure SetOnQueryInterfaceByLevel(value:TQueryInterfaceByLevelEvent);
    property OnQueryInterfaceByLevel:TQueryInterfaceByLevelEvent read GetOnQueryInterfaceByLevel write SetOnQueryInterfaceByLevel;
    function GetOnQueryInterfaceByNodeName:TQueryInterfaceByNodeNameEvent;
    procedure SetOnQueryInterfaceByNodeName(value:TQueryInterfaceByNodeNameEvent);
    property OnQueryInterfaceByNodeName:TQueryInterfaceByNodeNameEvent read GetOnQueryInterfaceByNodeName write SetOnQueryInterfaceByNodeName;
  end;
implementation
end.
