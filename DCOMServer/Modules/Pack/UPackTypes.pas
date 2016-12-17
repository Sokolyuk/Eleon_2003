//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UPackTypes;

interface
  uses UCallerTypes;

type
  // for protocol PR
  TPlace=({0}pdsNone,
          {1}pdsEventOnID,  {2}pdsEventOnUser,   {3}pdsEventOnAll,   {4}pdsEventOnBridge,
          {5}pdsCommandOnID,{6}pdsCommandOnUser, {7}pdsCommandOnAll, {8}pdsCommandOnBridge,
          {9}pdsEventOnMask,{10}pdsCommandOnMask, {11}pdsEventOnNameMask, {12}pdsCommandOnNameMask);

  TProtocolType=(ptlCPT,   //CPT-command pack with task
                 ptlCPR,   //CPR-command pack with result
                 ptlPD);   //PR -place result (transport protocol)

  TPackID=(pciNone{0}, pciCPT{1}, pciCPR{2}, pciPD{3}, pciMessage);

  IPack=Interface
  ['{77AC6DEE-AF53-4592-A5C0-F1477DD2DAEA}']
    function Get_PackID:TPackID;
    function Get_PackVer:Integer;
    function Get_AsVariant:Variant;
    procedure Set_AsVariant(Const Value:Variant);
    function Get_LowBound:Integer;
    function Get_HighBound:Integer;
    function Get_CallerAction:ICallerAction;
    procedure Set_CallerAction(Value:ICallerAction);
    function Clone:IPack;
    property PackID:TPackID read Get_PackID;
    property PackVer:Integer read Get_PackVer;
    property AsVariant:Variant read Get_AsVariant write Set_AsVariant;
    property LowBound:Integer read Get_LowBound;
    property HighBound:Integer read Get_HighBound;
    property CallerAction:ICallerAction read Get_CallerAction write Set_CallerAction;
  end;

implementation

end.
