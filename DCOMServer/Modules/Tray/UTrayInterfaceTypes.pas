//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTrayInterfaceTypes;

interface
type
  PGUIDList=^TGUIDList;
  TGUIDList=record
    aCount:Cardinal;
    aList:array[0..$ffff] of TGUID;
  end;
  TStateAsTray=(tpsNone, tpsInit, tpsWork, tpsPendingInit, tpsPendingStart, tpsPendingStop, tpsPendingFinal);
  ITrayInterface=Interface
  ['{4CB0CBE4-5817-46B2-B321-A18CA64B1D66}']
    function Get_StateAsTray:TStateAsTray;
    function GetTrayInterfaceName:AnsiString;
    procedure Init;
    procedure Start;
    procedure Stop;
    procedure Final;
    property StateAsTray:TStateAsTray read Get_StateAsTray;
  end;

  ITrayInterfaceInitFor=Interface(ITrayInterface)
  ['{337EC30E-75A0-48E7-9AC7-B195C5EFC99C}']
    procedure MustBeforeInitFor(var aGUIDList:PGUIDList);
    procedure MustBeforeStartFor(var aGUIDList:PGUIDList);
    procedure MustAfterStopFor(var aGUIDList:PGUIDList);
    procedure MustAfterFinalFor(var aGUIDList:PGUIDList);
  end;

implementation

end.
