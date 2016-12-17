//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UVarsetTypes;

interface
  {$IFDEF VER130}uses UVer130Types;{$ENDIF}
type
  IVarsetDataIntIndex=Interface
  ['{3C17E736-905C-4657-A0CA-2E2CBD618799}']
    function IT_GetIntIndex:Integer;
    procedure IT_SetIntIndex(Value:Integer);
    property ITIntIndex:Integer read IT_GetIntIndex write IT_SetIntIndex;
  end;

  IVarsetDataStrIndex=Interface
  ['{F80EAC8E-587F-4639-847F-800C3F9D8D47}']
    function IT_GetStrIndex:AnsiString;
    procedure IT_SetStrIndex(const Value:AnsiString);
    property ITStrIndex:AnsiString read IT_GetStrIndex write IT_SetStrIndex;
  End;

  IVarsetDataView=Interface
  ['{EBA66841-149C-4842-819A-40838814889F}']
    function IT_GetData:Variant;
    procedure IT_SetData(const Value:Variant);
    function IT_GetIntIndex:Integer;
    function IT_GetStrIndex:AnsiString;
    function IT_GetWakeup:TDateTime;
    procedure IT_SetWakeup(Value:TDateTime);
    function IT_GetIsWakeup:Boolean;
    function IT_GetChecked:boolean;
    procedure IT_SetChecked(value:boolean);
    function IT_GetReferenceIntIndex:IVarsetDataIntIndex;
    function IT_GetReferenceStrIndex:IVarsetDataStrIndex;
{RW}property ITData:Variant read IT_GetData write IT_SetData;
{RO}property ITIntIndex:Integer read IT_GetIntIndex;
{RO}property ITStrIndex:AnsiString read IT_GetStrIndex;
{RW}property ITWakeup:TDateTime read IT_GetWakeup write IT_SetWakeup;
{RO}property ITIsWakeup:Boolean read IT_GetIsWakeup;
    property ITChecked:Boolean read IT_GetChecked write IT_SetChecked;
    property ITReferenceIntIndex:IVarsetDataIntIndex read IT_GetReferenceIntIndex;
    property ITReferenceStrIndex:IVarsetDataStrIndex read IT_GetReferenceStrIndex;
    //..
    //function ITGet_SyncUsed:Boolean;
    //procedure ITSet_SyncUsed(Value:Boolean);
    //property ITSyncUsed:Boolean read ITGet_SyncUsed write ITSet_SyncUsed;
  end;

  IVarsetData=Interface
  ['{BCEA73A0-802C-4501-BD19-E5BAF1F1F7BD}']
    function IT_GetData:Variant;
    procedure IT_SetData(const Value:Variant);
    function IT_GetIntIndex:Integer;
    procedure IT_SetIntIndex(Value:Integer);
    function IT_GetReferenceIntIndex:IVarsetDataIntIndex;
    procedure IT_SetReferenceIntIndex(Value:IVarsetDataIntIndex);
    function IT_GetStrIndex:AnsiString;
    procedure IT_SetStrIndex(const Value:AnsiString);
    function IT_GetReferenceStrIndex:IVarsetDataStrIndex;
    procedure IT_SetReferenceStrIndex(Value:IVarsetDataStrIndex);
    function IT_GetWakeup:TDateTime;
    procedure IT_SetWakeup(Value:TDateTime);
    function IT_GetIsWakeup:Boolean;
    function IT_GetChecked:boolean;
    procedure IT_SetChecked(value:boolean);
    procedure ITAssign(aIVarsetDataView:IVarsetDataView);
    procedure ITAssignD(aIVarsetData:IVarsetData);
    function ITGet_AsIVarsetDataView:IVarsetDataView;
{RW}property ITData:Variant read IT_GetData write IT_SetData;
{RW}property ITIntIndex:Integer read IT_GetIntIndex write IT_SetIntIndex;
{RW}property ITStrIndex:AnsiString read IT_GetStrIndex write IT_SetStrIndex;
{RW}property ITWakeup:TDateTime read IT_GetWakeup write IT_SetWakeup;
{RO}property ITIsWakeup:Boolean read IT_GetIsWakeup;
    property ITChecked:Boolean read IT_GetChecked write IT_SetChecked;
    property ITReferenceIntIndex:IVarsetDataIntIndex read IT_GetReferenceIntIndex write IT_SetReferenceIntIndex;
    property ITReferenceStrIndex:IVarsetDataStrIndex read IT_GetReferenceStrIndex write IT_SetReferenceStrIndex;
    property ITAsIVarsetDataView:IVarsetDataView read ITGet_AsIVarsetDataView;
    //..
    //function ITGet_SyncUsed:Boolean;
    //procedure ITSet_SyncUsed(Value:Boolean);
    //property ITSyncUsed:Boolean read ITGet_SyncUsed write ITSet_SyncUsed;
  end;

  IVarset=interface;

  TRaiseStyle=(rasDefault, rasTrue, rasFalse);
  TOnIntroCallDataEvent=procedure(aUserData:Pointer; aVarset:IVarset; aVarsetData:IVarsetData);
  TOnIntroCallEvent=procedure(aUserData:Pointer; aVarset:IVarset);
  PIntroCallStructData=^TIntroCallStructData;
  TIntroCallStructData=record
    UserData:Pointer;
    OnIntroCallData:TOnIntroCallDataEvent;
  end;
  PIntroCallStruct=^TIntroCallStruct;
  TIntroCallStruct=record
    UserData:Pointer;
    OnIntroCall:TOnIntroCallEvent;
  end;

  IVarset=Interface
  ['{70A3B311-64FB-4D45-AC01-7417A4B3234B}']
    function IT_GetCount:Cardinal{Integer};
    function IT_GetView(Index:Integer):IVarsetDataView;
    function IT_GetViewOfStrIndex(const aStrIndex:AnsiString):IVarsetDataView;
    function IT_GetViewOfIntIndex(aIntIndex:Integer):IVarsetDataView;
    function IT_GetViewOfStrIndexEx(const aStrIndex:AnsiString; aRaise:TRaiseStyle=rasDefault):IVarsetDataView;
    function IT_GetViewOfIntIndexEx(aIntIndex:Integer; aRaise:TRaiseStyle=rasDefault):IVarsetDataView;
    function IT_GetViewDataOfStrIndexEx(const aStrIndex:AnsiString; aRaise:TRaiseStyle=rasDefault):Variant;
    function IT_GetViewDataOfIntIndexEx(aIntIndex:Integer; aRaise:TRaiseStyle=rasDefault):Variant;
    procedure IT_SetConfigIntIndexAssignable(Value:Boolean);
    function IT_GetConfigIntIndexAssignable:Boolean;
    procedure IT_SetConfigCheckUniqueIntIndex(Value:Boolean);
    function IT_GetConfigCheckUniqueIntIndex:Boolean;
    procedure IT_SetConfigCheckUniqueStrIndex(Value:Boolean);
    function IT_GetConfigCheckUniqueStrIndex:Boolean;
    procedure IT_SetConfigCapacityRange(Value:Integer);
    function IT_GetConfigCapacityRange:Integer;
    function IT_GetConfigNoFoundException:Boolean;
    procedure IT_SetConfigNoFoundException(Value:Boolean);
    function IT_GetConfigCaseSensitive:Boolean;
    procedure IT_SetConfigCaseSensitive(Value:Boolean);
    function IT_GetConfigMaxCount:Cardinal;
    procedure IT_SetConfigMaxCount(Value:Cardinal);
    // ..
    function ITPushV(const aData:Variant):IVarsetDataView;
    function ITPushVIC(const aData:Variant; aIntroCallStructData:PIntroCallStructData):IVarsetDataView;
    function ITPushVOfIntIndex(aIntIndex:Integer; const aData:Variant):IVarsetDataView;
    function ITPushVOfStrIndex(const aStrIndex:AnsiString; const aData:Variant):IVarsetDataView;
    function ITPushVI(const aData:Variant; aReferenceIntIndex:IVarsetDataIntIndex; aReferenceStrIndex:IVarsetDataStrIndex):IVarsetDataView;
    function ITPush(const aVarsetData:IVarsetData):IVarsetDataView;
    function ITPushIC(const aVarsetData:IVarsetData; aIntroCallStructData:PIntroCallStructData):IVarsetDataView;
    function ITPushW(const aVarsetData:IVarsetData; Out aNextTimeWakeup:TDateTime):IVarsetDataView;
    function ITPopV(aNilIfNone:Boolean=false):Variant;
    function ITPopVIC(aNilIfNone:Boolean{=false}; aIntroCallStructData:PIntroCallStructData):Variant;
    function ITPop(aNilIfNone:Boolean=false):IVarsetData;
    function ITPopIC(aNilIfNone:Boolean{=false}; aIntroCallStructData:PIntroCallStructData):IVarsetData;
    function ITPopOfIntIndex(aIntIndex:Integer):IVarsetData;
    function ITPopOfStrIndexEx(const aStrIndex:AnsiString; aRaise:TRaiseStyle=rasDefault):IVarsetData;
    function ITPopWakeup:IVarsetData;
    function ITPopWakeupIC(aIntroCallStructData:PIntroCallStructData):IVarsetData;
    function ITPopWakeupW(Out aNextTimeWakeup:TDateTime):IVarsetData;
    function ITUpdateDataOfStrIndex(const aStrIndex:AnsiString; const aData:Variant):Boolean;
    function ITUpdateDataOfStrIndexEx(const aStrIndex:AnsiString; const aData:Variant; aRaise:TRaiseStyle):Boolean;
    function ITUpdateDataOfIntIndex(aIntIndex:Integer; const aData:Variant):Boolean;
    function ITUpdateDataOfIntIndexEx(aIntIndex:Integer; const aData:Variant; aRaise:TRaiseStyle):Boolean;
    procedure ITAssign(aVarset:IVarset; aReassignIntIndexes:Boolean=False; aReassignStrIndexes:Boolean=False);
    procedure ITAppend(aVarset:IVarset; aReassignIntIndexes:Boolean=True; aReassignStrIndexes:Boolean=True);
    procedure ITAppendAndClearChecked(aVarset:IVarset; aReassignIntIndexes:Boolean=True; aReassignStrIndexes:Boolean=True);
    procedure ITIntroCall(aIntroCallStruct:PIntroCallStruct);
    //..
    function ITClear:Boolean;
    function ITClearOfIndex(const aIndex:Integer):Boolean;
    function ITClearOfIntIndex(const aIntIndex:Integer):Boolean;
    function ITClearOfStrIndex(const aStrIndex:AnsiString):Boolean;
    //..
    procedure ITSetAllChecked(aChecked:boolean);
    function ITClearChecked:Integer;
    //Steping
    function ITViewNextGetOfIntIndex(var aIntIndex:Integer):IVarsetDataView;
    function ITViewPrevGetOfIntIndex(var aIntIndex:Integer):IVarsetDataView;
    function ITViewNextDataGetOfIntIndex(var aIntIndex:Integer):Variant;
    function ITViewPrevDataGetOfIntIndex(var aIntIndex:Integer):Variant;
    function ITViewNextGetOfStrIndex(var aStrIndex:AnsiString):IVarsetDataView;
    function ITViewPrevGetOfStrIndex(var aStrIndex:AnsiString):IVarsetDataView;
    function ITViewNextDataGetOfStrIndex(var aStrIndex:AnsiString):Variant;
    function ITViewPrevDataGetOfStrIndex(var aStrIndex:AnsiString):Variant;
    //Exist
    function ITExistsIntIndex(aIntIndex:Integer):Boolean;
    function ITExistsStrIndex(const aStrIndex:AnsiString):Boolean;
    //..
    function ITGetNextTimeWakeup:TDateTime;
    function ITGetNextTimeWakeupAfterTime(aBeforeNowTimeWakeup:PCardinal; aAfterTime:TDateTime):TDateTime;
    //Property
    property ITCount:Cardinal{Integer} read IT_GetCount;
    property ITView[index:Integer]:IVarsetDataView read IT_GetView;
    property ITViewOfStrIndex[const index:AnsiString]:IVarsetDataView read IT_GetViewOfStrIndex;
    property ITViewOfIntIndex[index:Integer]:IVarsetDataView read IT_GetViewOfIntIndex;
    property ITViewOfStrIndexEx[const index:AnsiString; aRaise:TRaiseStyle]:IVarsetDataView read IT_GetViewOfStrIndexEx;
    property ITViewOfIntIndexEx[index:Integer; aRaise:TRaiseStyle]:IVarsetDataView read IT_GetViewOfIntIndexEx;
    property ITViewDataOfStrIndexEx[const index:AnsiString; aRaise:TRaiseStyle]:Variant read IT_GetViewDataOfStrIndexEx;
    property ITViewDataOfIntIndexEx[index:Integer; aRaise:TRaiseStyle]:Variant read IT_GetViewDataOfIntIndexEx;
    //Configure
    property ITConfigIntIndexAssignable:Boolean read IT_GetConfigIntIndexAssignable write IT_SetConfigIntIndexAssignable;
    property ITConfigCheckUniqueIntIndex:Boolean read IT_GetConfigCheckUniqueIntIndex write IT_SetConfigCheckUniqueIntIndex;
    property ITConfigCheckUniqueStrIndex:Boolean read IT_GetConfigCheckUniqueStrIndex write IT_SetConfigCheckUniqueStrIndex;
    property ITConfigCapacityRange:Integer read IT_GetConfigCapacityRange write IT_SetConfigCapacityRange;
    property ITConfigMaxCount:Cardinal read IT_GetConfigMaxCount write IT_SetConfigMaxCount;
    property ITConfigNoFoundException:Boolean read IT_GetConfigNoFoundException write IT_SetConfigNoFoundException;
    property ITConfigCaseSensitive:Boolean read IT_GetConfigCaseSensitive write IT_SetConfigCaseSensitive;
    //..
    property ITNextTimeWakeup:TDateTime read ITGetNextTimeWakeup;
    //function IT_GetAutoSetSyncUsed:Boolean;
    //procedure IT_SetAutoSetSyncUsed(Value:Boolean);
    //property ITConfigAutoSetSyncUsed:Boolean read IT_GetAutoSetSyncUsed write IT_SetAutoSetSyncUsed;
  end;

implementation

end.
