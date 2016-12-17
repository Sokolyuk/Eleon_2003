//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UVarset;

interface
  uses Windows, Classes, UITObject, UVarsetTypes{$IFDEF VER130}, UVer130Types{$ENDIF};
type
  TVarsetData=class(TITObject, IVarsetData, IVarsetDataView)
  private
    FData:Variant;
    FIntIndex:Integer;
    FStrIndex:AnsiString;
    FWakeup:TDateTime;
    FChecked:Boolean;
    FReferenceIntIndex:IVarsetDataIntIndex;
    FReferenceStrIndex:IVarsetDataStrIndex;
  protected
    function IT_GetData:Variant;
    procedure IT_SetData(const Value:Variant);
    procedure IT_SetIntIndex(Value:Integer);
    function IT_GetIntIndex:Integer;
    procedure IT_SetStrIndex(const Value:AnsiString);
    function IT_GetStrIndex:AnsiString;
    function IT_GetWakeup:TDateTime;
    procedure IT_SetWakeup(Value:TDateTime);
    function IT_GetIsWakeup:Boolean;
    function IT_GetChecked:boolean;
    procedure IT_SetChecked(value:boolean);
    function IT_GetReferenceIntIndex:IVarsetDataIntIndex;
    procedure IT_SetReferenceIntIndex(Value:IVarsetDataIntIndex);
    function IT_GetReferenceStrIndex:IVarsetDataStrIndex;
    procedure IT_SetReferenceStrIndex(Value:IVarsetDataStrIndex);
    procedure InternalAssign(const aData:Variant; aIntIndex:Integer; const aStrIndex:AnsiString; aWakeup:TDateTime; aChecked:Boolean;
                                     aReferenceIntIndex:IVarsetDataIntIndex; aReferenceStrIndex:IVarsetDataStrIndex);
    function ITGet_AsIVarsetDataView:IVarsetDataView;
  public
    constructor Create;
    destructor Destroy; override;
    //..
    procedure ITAssign(aIVarsetDataView:IVarsetDataView);
    procedure ITAssignD(aIVarsetData:IVarsetData);
{RW}property ITData:Variant read IT_GetData write IT_SetData;
{RW}property ITIntIndex:Integer read IT_GetIntIndex write IT_SetIntIndex;
{RW}property ITStrIndex:AnsiString read IT_GetStrIndex write IT_SetStrIndex;
{RW}property ITWakeup:TDateTime read IT_GetWakeup write IT_SetWakeup;
{RO}property ITIsWakeup:Boolean read IT_GetIsWakeup;
{RW}property ITChecked:Boolean read IT_GetChecked write IT_SetChecked;
    property ITReferenceIntIndex:IVarsetDataIntIndex read IT_GetReferenceIntIndex write IT_SetReferenceIntIndex;
    property ITReferenceStrIndex:IVarsetDataStrIndex read IT_GetReferenceStrIndex write IT_SetReferenceStrIndex;
  end;

  TVarset=class(TITObject, IVarset)
  private
    FList:TList;
    FConfigCapacityRange, FUniqueIntIndex:Integer;
    FConfigIntIndexAssignable, FConfigCheckUniqueIntIndex, FConfigCheckUniqueStrIndex, FConfigNoFoundException, FConfigCaseSensitive:Boolean;
    FConfigMaxCount:Cardinal;
  protected
    procedure InternalCheckCapacity;Virtual;
    function InternalCompareStr(const aValue1, aValue2:AnsiString):Boolean;Virtual;
    function InternalPop(aIndex:Integer; aRaise:TRaiseStyle=rasDefault):IVarsetData;Virtual;
    function InternalIntIndexToIndex(aIntIndex:Integer; aRaise:TRaiseStyle=rasDefault):Integer;Virtual;
    function InternalStrIndexToIndex(const aStrIndex:AnsiString; aRaise:TRaiseStyle=rasDefault):Integer;Virtual;
    function InternalIntIndexToNextIndex(aNext:Boolean; var aIntIndex:Integer):Integer;Virtual;
    function InternalStrIndexToNextIndex(aNext:Boolean; var aStrIndex:AnsiString):Integer;Virtual;
    procedure InternalAppend(aVarset:IVarset; aReassignIntIndexes:Boolean=True; aReassignStrIndexes:Boolean=True);Virtual;
    procedure InternalCreate;Virtual;
    function InternalPush(const aVarsetData:IVarsetData; aNextTimeWakeup:PDateTime):IVarsetDataView;Virtual;
    function InternalGetNextTimeWakeupAfterTime(aBeforeNowTimeWakeup:PCardinal; aAfterTime:TDateTime):TDateTime;Virtual;
    function InternalPopWakeup(aNextTimeWakeup:PDateTime):IVarsetData;Virtual;
  protected
    function IT_GetCount:Cardinal{Integer};Virtual;
    function IT_GetView(Index:Integer):IVarsetDataView;Virtual;
    function IT_GetViewOfStrIndex(const aStrIndex:AnsiString):IVarsetDataView;Virtual;
    function IT_GetViewOfIntIndex(aIntIndex:Integer):IVarsetDataView;Virtual;
    function IT_GetViewOfStrIndexEx(const aStrIndex:AnsiString; aRaise:TRaiseStyle=rasDefault):IVarsetDataView;Virtual;
    function IT_GetViewOfIntIndexEx(aIntIndex:Integer; aRaise:TRaiseStyle=rasDefault):IVarsetDataView;Virtual;
    function IT_GetViewDataOfStrIndexEx(const aStrIndex:AnsiString; aRaise:TRaiseStyle=rasDefault):Variant;Virtual;
    function IT_GetViewDataOfIntIndexEx(aIntIndex:Integer; aRaise:TRaiseStyle=rasDefault):Variant;Virtual;
    procedure IT_SetConfigIntIndexAssignable(Value:Boolean);Virtual;
    function IT_GetConfigIntIndexAssignable:Boolean;Virtual;
    procedure IT_SetConfigCheckUniqueIntIndex(Value:Boolean);Virtual;
    function IT_GetConfigCheckUniqueIntIndex:Boolean;Virtual;
    procedure IT_SetConfigCheckUniqueStrIndex(Value:Boolean);Virtual;
    function IT_GetConfigCheckUniqueStrIndex:Boolean;Virtual;
    procedure IT_SetConfigCapacityRange(Value:Integer);Virtual;
    function IT_GetConfigCapacityRange:Integer;Virtual;
    function IT_GetConfigNoFoundException:Boolean;Virtual;
    procedure IT_SetConfigNoFoundException(Value:Boolean);Virtual;
    function IT_GetConfigCaseSensitive:Boolean;Virtual;
    procedure IT_SetConfigCaseSensitive(Value:Boolean);Virtual;
    function IT_GetConfigMaxCount:Cardinal;Virtual;
    procedure IT_SetConfigMaxCount(Value:Cardinal);Virtual;
  public
    constructor Create;Virtual;
    constructor CreateUseLock(aUse:Boolean);Virtual;
    destructor Destroy; override;
    //..
    function ITPushV(const aData:Variant):IVarsetDataView;Virtual;
    function ITPushVIC(const aData:Variant; aIntroCallStructData:PIntroCallStructData):IVarsetDataView;Virtual;
    function ITPushVOfIntIndex(aIntIndex:Integer; const aData:Variant):IVarsetDataView;Virtual;
    function ITPushVOfStrIndex(const aStrIndex:AnsiString; const aData:Variant):IVarsetDataView;Virtual;
    function ITPushVI(const aData:Variant; aReferenceIntIndex:IVarsetDataIntIndex; aReferenceStrIndex:IVarsetDataStrIndex):IVarsetDataView;Virtual;
    function ITPush(const aVarsetData:IVarsetData):IVarsetDataView;Virtual;
    function ITPushIC(const aVarsetData:IVarsetData; aIntroCallStructData:PIntroCallStructData):IVarsetDataView;Virtual;
    function ITPushW(const aVarsetData:IVarsetData; Out aNextTimeWakeup:TDateTime):IVarsetDataView;Virtual;
    function ITPopV(aNilIfNone:Boolean=false):Variant;Virtual;
    function ITPopVIC(aNilIfNone:Boolean{=false}; aIntroCallStructData:PIntroCallStructData):Variant;Virtual;
    function ITPop(aNilIfNone:Boolean=false):IVarsetData;Virtual;
    function ITPopIC(aNilIfNone:Boolean{=false}; aIntroCallStructData:PIntroCallStructData):IVarsetData;Virtual;
    function ITPopOfIntIndex(aIntIndex:Integer):IVarsetData;Virtual;
    function ITPopOfStrIndexEx(const aStrIndex:AnsiString; aRaise:TRaiseStyle=rasDefault):IVarsetData;Virtual;
    function ITPopWakeup:IVarsetData;Virtual;
    function ITPopWakeupIC(aIntroCallStructData:PIntroCallStructData):IVarsetData;
    function ITPopWakeupW(Out aNextTimeWakeup:TDateTime):IVarsetData;virtual;
    function ITUpdateDataOfStrIndex(const aStrIndex:AnsiString; const aData:Variant):boolean;Virtual;
    function ITUpdateDataOfStrIndexEx(const aStrIndex:AnsiString; const aData:Variant; aRaise:TRaiseStyle):Boolean;Virtual;
    function ITUpdateDataOfIntIndex(aIntIndex:Integer; const aData:Variant):Boolean;virtual;
    function ITUpdateDataOfIntIndexEx(aIntIndex:Integer; const aData:Variant; aRaise:TRaiseStyle):Boolean;virtual;
    procedure ITAssign(aVarset:IVarset; aReassignIntIndexes:Boolean=False; aReassignStrIndexes:Boolean=False);Virtual;
    procedure ITAppend(aVarset:IVarset; aReassignIntIndexes:Boolean=True; aReassignStrIndexes:Boolean=True);Virtual;
    procedure ITAppendAndClearChecked(aVarset:IVarset; aReassignIntIndexes:Boolean=True; aReassignStrIndexes:Boolean=True);Virtual;
    function ITClear:Boolean;Virtual;
    function ITClearOfIndex(const aIndex:Integer):Boolean;Virtual;
    function ITClearOfIntIndex(const aIntIndex:Integer):Boolean;Virtual;
    function ITClearOfStrIndex(const aStrIndex:AnsiString):Boolean;Virtual;
    //..
    function ITClearChecked:Integer;Virtual;
    procedure ITSetAllChecked(aChecked:boolean);Virtual;
    //Steping
    function ITViewNextGetOfIntIndex(var aIntIndex:Integer):IVarsetDataView;Virtual;
    function ITViewPrevGetOfIntIndex(var aIntIndex:Integer):IVarsetDataView;Virtual;
    function ITViewNextDataGetOfIntIndex(var aIntIndex:Integer):Variant;Virtual;
    function ITViewPrevDataGetOfIntIndex(var aIntIndex:Integer):Variant;Virtual;
    function ITViewNextGetOfStrIndex(var aStrIndex:AnsiString):IVarsetDataView;Virtual;
    function ITViewPrevGetOfStrIndex(var aStrIndex:AnsiString):IVarsetDataView;Virtual;
    function ITViewNextDataGetOfStrIndex(var aStrIndex:AnsiString):Variant;Virtual;
    function ITViewPrevDataGetOfStrIndex(var aStrIndex:AnsiString):Variant;Virtual;
    //Exist
    function ITExistsIntIndex(aIntIndex:Integer):Boolean;Virtual;
    function ITExistsStrIndex(const aStrIndex:AnsiString):Boolean;Virtual;
    function ITGetNextTimeWakeup:TDateTime;
    function ITGetNextTimeWakeupAfterTime(aBeforeNowTimeWakeup:PCardinal; aAfterTime:TDateTime):TDateTime;
    //Property
    property ITCount:Cardinal{Integer} read IT_GetCount;
    property ITView[Index:Integer]:IVarsetDataView read IT_GetView;
    property ITViewOfStrIndex[const Index:AnsiString]:IVarsetDataView read IT_GetViewOfStrIndex;
    property ITViewOfIntIndex[Index:Integer]:IVarsetDataView read IT_GetViewOfIntIndex;
    property ITViewOfStrIndexEx[const Index:AnsiString; aRaise:TRaiseStyle]:IVarsetDataView read IT_GetViewOfStrIndexEx;
    property ITViewOfIntIndexEx[Index:Integer; aRaise:TRaiseStyle]:IVarsetDataView read IT_GetViewOfIntIndexEx;
    property ITViewDataOfStrIndexEx[const Index:AnsiString; aRaise:TRaiseStyle]:Variant read IT_GetViewDataOfStrIndexEx;
    property ITViewDataOfIntIndexEx[Index:Integer; aRaise:TRaiseStyle]:Variant read IT_GetViewDataOfIntIndexEx;
    //Configure
    property ITConfigIntIndexAssignable:Boolean read IT_GetConfigIntIndexAssignable write IT_SetConfigIntIndexAssignable;
    property ITConfigCheckUniqueIntIndex:Boolean read IT_GetConfigCheckUniqueIntIndex write IT_SetConfigCheckUniqueIntIndex;
    property ITConfigCheckUniqueStrIndex:Boolean read IT_GetConfigCheckUniqueStrIndex write IT_SetConfigCheckUniqueStrIndex;
    property ITConfigCapacityRange:Integer read IT_GetConfigCapacityRange write IT_SetConfigCapacityRange;
    property ITConfigMaxCount:Cardinal read IT_GetConfigMaxCount write IT_SetConfigMaxCount;
    property ITConfigNoFoundException:Boolean read IT_GetConfigNoFoundException write IT_SetConfigNoFoundException;
    //property ITConfigCaseSensive:Boolean read IT_GetConfigNoFoundException write IT_SetConfigNoFoundException;
    property ITConfigCaseSensitive:Boolean read IT_GetConfigCaseSensitive write IT_SetConfigCaseSensitive;
    property ITNextTimeWakeup:TDateTime read ITGetNextTimeWakeup;
    procedure ITIntroCall(aIntroCallStruct:PIntroCallStruct);
  end;

const
  VarsetCapacityRange=20;

implementation
  uses SysUtils{$IFNDEF VER130}, Variants{$ENDIF};

//TVarsetData*****************************************************************************
constructor TVarsetData.Create;
begin
  FData:=Unassigned;
  FIntIndex:=-1;
  FStrIndex:='';
  FWakeup:=Now;
  //ObjectType:=otTVarsetData;
  FReferenceIntIndex:=nil;
  FReferenceStrIndex:=nil;
  Inherited Create;
end;

destructor TVarsetData.Destroy;
begin
  FReferenceIntIndex:=nil;
  FReferenceStrIndex:=nil;
  FStrIndex:='';
  VarClear(FData);
  Inherited Destroy;
end;

function TVarsetData.ITGet_AsIVarsetDataView:IVarsetDataView;
begin
  Result:=Self;
  if Not Assigned(Result) then raise exception.create('Unexpect error. IVarsetDataView is not assigned.');
end;

procedure TVarsetData.InternalAssign(const aData:Variant; aIntIndex:Integer; const aStrIndex:AnsiString; aWakeup:TDateTime; aChecked:Boolean;
                                     aReferenceIntIndex:IVarsetDataIntIndex; aReferenceStrIndex:IVarsetDataStrIndex);
begin
  FData:=aData;
  FIntIndex:=aIntIndex;
  FStrIndex:=aStrIndex;
  FWakeup:=aWakeup;
  FChecked:=aChecked;
  FReferenceIntIndex:=aReferenceIntIndex;
  FReferenceStrIndex:=aReferenceStrIndex;
end;

procedure TVarsetData.ITAssign(aIVarsetDataView:IVarsetDataView);
begin
  InternalLock;
  try
    InternalAssign(aIVarsetDataView.ITData, aIVarsetDataView.ITIntIndex,  aIVarsetDataView.ITStrIndex,
                   aIVarsetDataView.ITWakeup, aIVarsetDataView.ITChecked, aIVarsetDataView.ITReferenceIntIndex, aIVarsetDataView.ITReferenceStrIndex);
    {FData:=aIVarsetDataView.ITData;
    FIntIndex:=aIVarsetDataView.ITIntIndex;
    FStrIndex:=aIVarsetDataView.ITStrIndex;
    FWakeup:=aIVarsetDataView.ITWakeup;
    FChecked:=aIVarsetDataView.ITChecked;
    FIVarsetDataIntIndex:=aIVarsetDataView.ITReferenceIntIndex;
    FIVarsetDataStrIndex:=aIVarsetDataView.ITReferenceStrIndex;}
  finally
    InternalUnLock;
  end;
end;

procedure TVarsetData.ITAssignD(aIVarsetData:IVarsetData);
begin
  InternalLock;
  try
    InternalAssign(aIVarsetData.ITData, aIVarsetData.ITIntIndex,  aIVarsetData.ITStrIndex,
                   aIVarsetData.ITWakeup, aIVarsetData.ITChecked, aIVarsetData.ITReferenceIntIndex, aIVarsetData.ITReferenceStrIndex);
  finally
    InternalUnLock;
  end;
end;

function TVarsetData.IT_GetData:Variant;
begin
  InternalLock;
  try
    Result:=FData;
  finally
    InternalUnLock;
  end;
end;

procedure TVarsetData.IT_SetData(const Value:Variant);
begin
  InternalLock;
  try
    FData:=Value;
  finally
    InternalUnLock;
  end;
end;

procedure TVarsetData.IT_SetIntIndex(Value:Integer);
begin
  InternalLock;
  try
    FIntIndex:=Value;
    if Assigned(FReferenceIntIndex) then begin
      FReferenceIntIndex.ITIntIndex:=FIntIndex;
    end;
  finally
    InternalUnLock;
  end;
end;

function TVarsetData.IT_GetIntIndex:Integer;
begin
  InternalLock;
  try
    if Assigned(FReferenceIntIndex) then begin
      FIntIndex:=FReferenceIntIndex.ITIntIndex;
    end;
    Result:=FIntIndex;
  finally
    InternalUnLock;
  end;
end;

procedure TVarsetData.IT_SetStrIndex(const Value:AnsiString);
begin
  InternalLock;
  try
    FStrIndex:=Value;
    if Assigned(FReferenceStrIndex) then begin
      FReferenceStrIndex.ITStrIndex:=FStrIndex;
    end;
  finally
    InternalUnLock;
  end;
end;

function TVarsetData.IT_GetStrIndex:AnsiString;
begin
  InternalLock;
  try
    if Assigned(FReferenceStrIndex) then begin
      FStrIndex:=FReferenceStrIndex.ITStrIndex;
    end;
    Result:=FStrIndex;
  finally
    InternalUnLock;
  end;
end;

function TVarsetData.IT_GetWakeup:TDateTime;
begin
  InternalLock;
  try
    Result:=FWakeup;
  finally
    InternalUnLock;
  end;
end;

procedure TVarsetData.IT_SetWakeup(Value:TDateTime);
begin
  InternalLock;
  try
    FWakeup:=Value;
  finally
    InternalUnLock;
  end;
end;

function TVarsetData.IT_GetIsWakeup:Boolean;
begin
  InternalLock;
  try
    Result:=Now>=FWakeup;
  finally
    InternalUnLock;
  end;
end;

function TVarsetData.IT_GetChecked:boolean;
begin
  result:=FChecked;
end;

procedure TVarsetData.IT_SetChecked(value:boolean);
begin
  begin
    InternalLock;
    try
      FChecked:=value;
    finally
      InternalUnlock;
    end;
  end;
end;

function TVarsetData.IT_GetReferenceIntIndex:IVarsetDataIntIndex;
begin
  InternalLock;
  try
    Result:=FReferenceIntIndex;
  finally
    InternalUnlock;
  end;
end;

procedure TVarsetData.IT_SetReferenceIntIndex(Value:IVarsetDataIntIndex);
begin
  InternalLock;
  try
    FReferenceIntIndex:=Value;
  finally
    InternalUnlock;
  end;
end;

function TVarsetData.IT_GetReferenceStrIndex:IVarsetDataStrIndex;
begin
  InternalLock;
  try
    Result:=FReferenceStrIndex;
  finally
    InternalUnlock;
  end;
end;

procedure TVarsetData.IT_SetReferenceStrIndex(Value:IVarsetDataStrIndex);
begin
  InternalLock;
  try
    FReferenceStrIndex:=Value;
  finally
    InternalUnlock;
  end;
end;

//TVarset*********************************************************************************
procedure TVarset.InternalCreate;
begin
  FList:=TList.Create;
  FConfigCapacityRange:=VarsetCapacityRange;
  InternalCheckCapacity;
  FConfigIntIndexAssignable:=False;//присваивать внешний индекс нельзя.
  FConfigCheckUniqueIntIndex:=False;//Проверять уникальность Int индекса не нужно.
  FConfigCheckUniqueStrIndex:=False;//Проверять уникальность Str индекса не нужно.
  FConfigNoFoundException:=True;//Давать Raise Except если элемент ненайден.
  FConfigCaseSensitive:=False;// Для StrIndex нечуствительность к регистру.
  FUniqueIntIndex:=0;
  FConfigMaxCount:=4294967295;
end;

constructor TVarset.Create;
begin
  InternalCreate;
  Inherited Create;
end;

constructor TVarset.CreateUseLock(aUse:Boolean);
begin
  InternalCreate;
  Inherited CreateUseLock(aUse);
end;

destructor TVarset.Destroy;
begin
  try
    ITClear;
    FreeAndNil(FList);
  except end;
  Inherited Destroy;
end;

procedure TVarset.InternalCheckCapacity;
begin
  if (FList.Count<(FList.Capacity-FConfigCapacityRange*2))or(FList.Count>=FList.Capacity) then FList.Capacity:=FList.Count+FConfigCapacityRange;
end;

function TVarset.IT_GetCount:Cardinal{Integer};
begin
  InternalLock;
  try
    Result:=0;
    try
      if FList.Count>=0 then Result:=FList.Count else Result:=0;
    except on e:exception do begin
      e.message:='IT_GetCount: '+e.message;
      raise;
    end;end;
  finally
    InternalUnLock;
  end;
end;

function TVarset.IT_GetView(Index:Integer):IVarsetDataView;
begin
  InternalLock;
  try
    try
      if (FList.Count<1)or(Index<0)or(Index>(FList.Count-1)) then begin
        // Список пустой
        if FConfigNoFoundException then raise exception.create('Index='+IntToStr(Index)+' not found.') Else Result:=nil;
      end else begin
        // список не пустой
        Result:=TVarsetData(FList.Items[Index]);
      end;
    except on e:exception do begin
      e.message:='IT_GetView: '+e.message;
      raise;
    end;end;
  finally
    InternalUnLock;
  end;
end;

function TVarset.InternalCompareStr(const aValue1, aValue2:AnsiString):Boolean;
begin
  if (aValue1='')or(aValue2='') then begin
    //Если строка пустая, то это я понимаю как строка уникальная.
    Result:=False;
  end else begin
    if FConfigCaseSensitive then begin
      Result:=aValue1=aValue2;
    end else begin
      Result:=AnsiUpperCase(aValue1)=AnsiUpperCase(aValue2);
    end;
  end;
end;

function TVarset.IT_GetViewOfStrIndex(const aStrIndex:AnsiString):IVarsetDataView;
begin
  Result:=IT_GetViewOfStrIndexEx(aStrIndex, rasDefault);
end;

function TVarset.ITUpdateDataOfStrIndex(const aStrIndex:AnsiString; const aData:Variant):boolean;
begin
  result:=ITUpdateDataOfStrIndexEx(aStrIndex, aData, rasDefault);
end;

function TVarset.ITUpdateDataOfStrIndexEx(const aStrIndex:AnsiString; const aData:Variant; aRaise:TRaiseStyle):Boolean;
  var tmpIVarsetDataView:IVarsetDataView;
begin
  InternalLock;
  try
    tmpIVarsetDataView:=IT_GetViewOfStrIndexEx(aStrIndex, aRaise);
    result:=assigned(tmpIVarsetDataView);
    if result then tmpIVarsetDataView.ITData:=aData;
  finally
    InternalUnlock;
  end;
end;

function TVarset.ITUpdateDataOfIntIndex(aIntIndex:Integer; const aData:Variant):Boolean;
begin
  result:=ITUpdateDataOfIntIndexEx(aIntIndex, aData, rasDefault);
end;

function TVarset.ITUpdateDataOfIntIndexEx(aIntIndex:Integer; const aData:Variant; aRaise:TRaiseStyle):Boolean;
  var tmpIVarsetDataView:IVarsetDataView;
begin
  InternalLock;
  try
    tmpIVarsetDataView:=IT_GetViewOfIntIndexEx(aIntIndex, aRaise);
    result:=assigned(tmpIVarsetDataView);
    if result then tmpIVarsetDataView.ITData:=aData;
  finally
    InternalUnlock;
  end;
end;

function TVarset.IT_GetViewOfIntIndex(aIntIndex:Integer):IVarsetDataView;
begin
  Result:=IT_GetViewOfIntIndexEx(aIntIndex, rasDefault);
end;

function TVarset.IT_GetViewOfStrIndexEx(const aStrIndex:AnsiString; aRaise:TRaiseStyle=rasDefault):IVarsetDataView;
  var tmpI:Integer;
      tmpIVarsetDataView:IVarsetDataView;
begin
  InternalLock;
  try
    Result:=nil;
    try
      if FList.Count>0 then begin
        //список не пустой
        for tmpI:=0 to FList.Count-1 do begin
          tmpIVarsetDataView:=TVarsetData(FList.Items[tmpI]);
          if InternalCompareStr(tmpIVarsetDataView.ITStrIndex, aStrIndex) then begin
            Result:=tmpIVarsetDataView;
            Break;
          end;
        end;
      end;
      if (Result=Nil)and((aRaise=rasTrue)or((aRaise=rasDefault)and(FConfigNoFoundException))) then raise exception.create('StrIndex='''+aStrIndex+''' not found.');
    except On E:Exception do begin
      e.message:='IT_GetViewOfStrIndex: '+e.message;
      raise;
    end;end;
  finally
    InternalUnLock;
  end;
end;

function TVarset.IT_GetViewOfIntIndexEx(aIntIndex:Integer; aRaise:TRaiseStyle=rasDefault):IVarsetDataView;
  var tmpI:Integer;
      tmpIVarsetDataView:IVarsetDataView;
begin
  InternalLock;
  try
    Result:=nil;
    try
      if FList.Count>0 then begin
        //список не пустой
        for tmpI:=0 to FList.Count-1 do begin
          tmpIVarsetDataView:=TVarsetData(FList.Items[tmpI]);
          if tmpIVarsetDataView.ITIntIndex=aIntIndex then begin
            Result:=tmpIVarsetDataView;
            Break;
          end;
        end;
      end;
      if (Result=Nil)and((aRaise=rasTrue)or((aRaise=rasDefault)and(FConfigNoFoundException))) then raise exception.create('IntIndex='+IntToStr(aIntIndex)+' not found.');//(Result=Nil)and(FConfigNoFoundException)
    except on e:exception do begin
      e.message:='IT_GetViewOfStrIndex: '+e.message;
      raise;
    end;end;
  finally
    InternalUnLock;
  end;
end;

function TVarset.IT_GetViewDataOfStrIndexEx(const aStrIndex:AnsiString; aRaise:TRaiseStyle=rasDefault):Variant;
  var tmpIVarsetDataView:IVarsetDataView;
begin
  tmpIVarsetDataView:=IT_GetViewOfStrIndexEx(aStrIndex, aRaise);
  if assigned(tmpIVarsetDataView) then result:=tmpIVarsetDataView.ITData else result:=Unassigned;
  tmpIVarsetDataView:=nil;
end;

function TVarset.IT_GetViewDataOfIntIndexEx(aIntIndex:Integer; aRaise:TRaiseStyle=rasDefault):Variant;
  var tmpIVarsetDataView:IVarsetDataView;
begin
  tmpIVarsetDataView:=IT_GetViewOfIntIndexEx(aIntIndex, aRaise);
  if assigned(tmpIVarsetDataView) then result:=tmpIVarsetDataView.ITData else result:=Unassigned;
  tmpIVarsetDataView:=nil;
end;

procedure TVarset.IT_SetConfigIntIndexAssignable(Value:Boolean);
begin
  InternalLock;
  try
    FConfigIntIndexAssignable:=Value;
  finally
    InternalUnLock;
  end;
end;

function TVarset.IT_GetConfigIntIndexAssignable:Boolean;
begin
  InternalLock;
  try
    Result:=FConfigIntIndexAssignable;
  finally
    InternalUnLock;
  end;
end;

procedure TVarset.IT_SetConfigCheckUniqueIntIndex(Value:Boolean);
begin
  InternalLock;
  try
    FConfigCheckUniqueIntIndex:=Value;
  finally
    InternalUnLock;
  end;
end;

function TVarset.IT_GetConfigCheckUniqueIntIndex:Boolean;
begin
  InternalLock;
  try
    Result:=FConfigCheckUniqueIntIndex;
  finally
    InternalUnLock;
  end;
end;

procedure TVarset.IT_SetConfigCheckUniqueStrIndex(Value:Boolean);
begin
  InternalLock;
  try
    FConfigCheckUniqueStrIndex:=Value;
  finally
    InternalUnLock;
  end;
end;

function TVarset.IT_GetConfigCheckUniqueStrIndex:Boolean;
begin
  InternalLock;
  try
    Result:=FConfigCheckUniqueStrIndex;
  finally
    InternalUnLock;
  end;
end;

procedure TVarset.IT_SetConfigCapacityRange(Value:Integer);
begin
  InternalLock;
  try
    FConfigCapacityRange:=Value;
  finally
    InternalUnLock;
  end;
end;

function TVarset.IT_GetConfigCapacityRange:Integer;
begin
  InternalLock;
  try
    Result:=FConfigCapacityRange;
  finally
    InternalUnLock;
  end;
end;

function TVarset.IT_GetConfigNoFoundException:Boolean;
begin
  InternalLock;
  try
    Result:=FConfigNoFoundException;
  finally
    InternalUnLock;
  end;
end;

procedure TVarset.IT_SetConfigNoFoundException(Value:Boolean);
begin
  InternalLock;
  try
    FConfigNoFoundException:=Value;
  finally
    InternalUnLock;
  end;
end;

function TVarset.IT_GetConfigCaseSensitive:Boolean;
begin
  InternalLock;
  try
    Result:=FConfigCaseSensitive;
  finally
    InternalUnLock;
  end;
end;

procedure TVarset.IT_SetConfigCaseSensitive(Value:Boolean);
begin
  InternalLock;
  try
    FConfigCaseSensitive:=Value;
  finally
    InternalUnLock;
  end;
end;

function TVarset.IT_GetConfigMaxCount:Cardinal;
begin
  InternalLock;
  try
    Result:=FConfigMaxCount;
  finally
    InternalUnLock;
  end;
end;

procedure TVarset.IT_SetConfigMaxCount(Value:Cardinal);
begin
  InternalLock;
  try
    FConfigMaxCount:=Value;
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITPushV(const aData:Variant):IVarsetDataView;
  var tmpIVarsetData:IVarsetData;
begin
  InternalLock;
  try
    tmpIVarsetData:=TVarsetData.Create;
    tmpIVarsetData.ITData:=aData;
    Result:=ITPush(tmpIVarsetData);
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITPushVIC(const aData:Variant; aIntroCallStructData:PIntroCallStructData):IVarsetDataView;
  var tmpIVarsetData:IVarsetData;
begin
  InternalLock;
  try
    tmpIVarsetData:=TVarsetData.Create;
    tmpIVarsetData.ITData:=aData;
    Result:=ITPush(tmpIVarsetData);
    if assigned(aIntroCallStructData) then aIntroCallStructData^.OnIntroCallData(aIntroCallStructData^.UserData, Self, tmpIVarsetData);
  finally
    InternalUnLock;
  end;
end;

procedure TVarset.ITIntroCall(aIntroCallStruct:PIntroCallStruct);
begin
  InternalLock;
  try
    if assigned(aIntroCallStruct) then aIntroCallStruct.OnIntroCall(aIntroCallStruct.UserData, Self);
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITPushVOfIntIndex(aIntIndex:Integer; const aData:Variant):IVarsetDataView;
  var tmpIVarsetData:IVarsetData;
begin
  InternalLock;
  try
    tmpIVarsetData:=TVarsetData.Create;
    tmpIVarsetData.ITData:=aData;
    tmpIVarsetData.ITIntIndex:=aIntIndex;
    Result:=ITPush(tmpIVarsetData);
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITPushVOfStrIndex(const aStrIndex:AnsiString; const aData:Variant):IVarsetDataView;
  var tmpIVarsetData:IVarsetData;
begin
  InternalLock;
  try
    tmpIVarsetData:=TVarsetData.Create;
    tmpIVarsetData.ITData:=aData;
    tmpIVarsetData.ITStrIndex:=aStrIndex;
    Result:=ITPush(tmpIVarsetData);
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITPushVI(const aData:Variant; aReferenceIntIndex:IVarsetDataIntIndex; aReferenceStrIndex:IVarsetDataStrIndex):IVarsetDataView;
  var tmpIVarsetData:IVarsetData;
begin
  InternalLock;
  try
    tmpIVarsetData:=TVarsetData.Create;
    tmpIVarsetData.ITData:=aData;
    tmpIVarsetData.ITReferenceIntIndex:=aReferenceIntIndex;
    tmpIVarsetData.ITReferenceStrIndex:=aReferenceStrIndex;
    Result:=ITPush(tmpIVarsetData);
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITPushW(const aVarsetData:IVarsetData; Out aNextTimeWakeup:TDateTime):IVarsetDataView;
begin
  InternalLock;
  try
    Result:=InternalPush(aVarsetData, @aNextTimeWakeup);
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITPush(const aVarsetData:IVarsetData):IVarsetDataView;
begin
  InternalLock;
  try
    try
      Result:=InternalPush(aVarsetData, Nil);
    Except on e:exception do begin
      e.message:='ITPush: '+e.message;
      raise;
    end;End;
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITPushIC(const aVarsetData:IVarsetData; aIntroCallStructData:PIntroCallStructData):IVarsetDataView;
begin
  InternalLock;
  try
    try
      Result:=InternalPush(aVarsetData, nil);
      if assigned(aIntroCallStructData) then aIntroCallStructData^.OnIntroCallData(aIntroCallStructData^.UserData, Self, aVarsetData);
    except on e:exception do begin
      e.message:='ITPushIC: '+e.message;
      raise;
    end;End;
  finally
    InternalUnLock;
  end;
end;

function TVarset.InternalPush(const aVarsetData:IVarsetData; aNextTimeWakeup:PDateTime):IVarsetDataView;
  var tmpI, tmpIntIndex:Integer;
      tmpContinue:Boolean;
      tmpVarsetData:TVarsetData;
      tmpIVarsetDataView:IVarsetDataView;
      tmpCardinal:Cardinal;
begin
  tmpCardinal:=FList.Count+1;
  if tmpCardinal>FConfigMaxCount then raise exception.create('MaxCount of element='+IntToStr(FConfigMaxCount)+'.');
  Result:=nil;
  if aVarsetData=Nil then raise exception.create('VarsetData is not assigned.');
  tmpIntIndex:=aVarsetData.ITIntIndex;
  //Назначаемость индекса
  if Not FConfigIntIndexAssignable then begin
    if tmpIntIndex>-1 then raise exception.create('IntIndexAssignable=False, aVarsetData.ITIntIndex='+IntToStr(tmpIntIndex)+'(must -1).');
    // Генерируется уникальный индекс
    While True do begin
      Inc(FUniqueIntIndex);
      tmpIntIndex:=FUniqueIntIndex;
      tmpContinue:=False;
      // Уникальность индекса
      if FConfigCheckUniqueIntIndex then begin
        // Требуется проверка унпкальности ключа
        for tmpI:=0 to FList.Count-1 do begin
          tmpIVarsetDataView:=TVarsetData(FList.Items[tmpI]);
          if tmpIVarsetDataView.ITIntIndex=tmpIntIndex then begin
            tmpContinue:=True;
            Break;
          end;
        end;
      end;
      if Not tmpContinue then Break;
    end;
    if FConfigCheckUniqueStrIndex then begin
      //Проверяю уникальность StrIndex
      for tmpI:=0 to FList.Count-1 do begin
        tmpIVarsetDataView:=TVarsetData(FList.Items[tmpI]);
        if InternalCompareStr(tmpIVarsetDataView.ITStrIndex, aVarsetData.ITStrIndex) Then
          raise exception.create('Duplication of a unique StrIndex='''+aVarsetData.ITStrIndex+'''.');
      end;
    end;
  end else begin
    //Проверка допустимых значений(На данный момент не допустимы все отрицательные значения).
    if tmpIntIndex<0 then raise exception.create('Invalid value IntIndex='+IntToStr(tmpIntIndex)+'.');
    // Уникальность индексов
    if (FConfigCheckUniqueIntIndex)or(FConfigCheckUniqueStrIndex)then begin
      // Требуется проверка унпкальности ключа
      for tmpI:=0 to FList.Count-1 do begin
        tmpIVarsetDataView:=TVarsetData(FList.Items[tmpI]);
        if (FConfigCheckUniqueIntIndex)and(tmpIVarsetDataView.ITIntIndex=tmpIntIndex) then begin
          raise exception.create('Duplication of a unique IntIndex='+IntToStr(tmpIntIndex)+'.');
        end;
        //уникальность StrIndex
        if (FConfigCheckUniqueStrIndex)and(InternalCompareStr(tmpIVarsetDataView.ITStrIndex, aVarsetData.ITStrIndex)) then begin
          raise exception.create('Duplication of a unique StrIndex='''+aVarsetData.ITStrIndex+'''.');
        end;
      end;
    end;
  end;
  tmpVarsetData:=TVarsetData.Create;
  try
    aVarsetData.ITIntIndex:=tmpIntIndex;
    tmpVarsetData.ITAssignD(aVarsetData);
    tmpVarsetData._AddRef;//Что не разобрался интерфейсом
    FList.Add(tmpVarsetData);
  except
    tmpVarsetData.Free;
    raise;
  end;
  Result:=tmpVarsetData;
  if Assigned(aNextTimeWakeup) then begin//Ищу NextTimeWakeup
    aNextTimeWakeup^:=InternalGetNextTimeWakeupAfterTime(nil, 0);
  end;
end;

function TVarset.InternalGetNextTimeWakeupAfterTime(aBeforeNowTimeWakeup:PCardinal; aAfterTime:TDateTime):TDateTime;
  var tmpI:Integer;
      tmpBeforeNowTimeWakeup:Cardinal;
      tmpWakeup:TDateTime;
begin
  result:=0;
  tmpBeforeNowTimeWakeup:=0;
  for tmpI:=0 to FList.Count-1 do begin
    tmpWakeup:=TVarsetData(FList.Items[tmpI]).ITWakeup;
    if tmpWakeup<=aAfterTime then begin//до запршенного порога
      inc(tmpBeforeNowTimeWakeup);
      result:=aAfterTime;
    end else begin
      if (Result=0)or(tmpWakeup<Result) then Result:=tmpWakeup;
    end;
  end;
  if assigned(aBeforeNowTimeWakeup) then aBeforeNowTimeWakeup^:=tmpBeforeNowTimeWakeup;
end;

function TVarset.ITGetNextTimeWakeupAfterTime(aBeforeNowTimeWakeup:PCardinal; aAfterTime:TDateTime):TDateTime;
begin
  InternalLock;
  try
    Result:=InternalGetNextTimeWakeupAfterTime(aBeforeNowTimeWakeup, aAfterTime);
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITGetNextTimeWakeup:TDateTime;
begin
  InternalLock;
  try
    Result:=InternalGetNextTimeWakeupAfterTime(nil, 0);
  finally
    InternalUnLock;
  end;
end;

function TVarset.InternalPop(aIndex:Integer; aRaise:TRaiseStyle=rasDefault):IVarsetData;
  var tmpVarsetData:TVarsetData;
begin
  Result:=nil;
  if FList.Count<1 then begin
    if ((aRaise=rasDefault)and(FConfigNoFoundException))or(aRaise=rasTrue) then raise exception.create('Varset.Count=0.') else Result:=nil;
    Exit;
  end;
  if (aIndex>FList.Count-1)or(aIndex<0) then begin
    if ((aRaise=rasDefault)and(FConfigNoFoundException))or(aRaise=rasTrue) then raise exception.create('Index='+IntToStr(aIndex)+' is not exist.') else Result:=nil;
    Exit;
  end;
  tmpVarsetData:=FList.Items[aIndex];
  try
    Result:=tmpVarsetData;
    tmpVarsetData._Release;//Что разобрался интерфейсом
  finally
    FList.Delete(aIndex);
    InternalCheckCapacity;
  end;
end;

function TVarset.ITPop(aNilIfNone:Boolean=False):IVarsetData;
begin
  InternalLock;
  try
    try
      if (aNilIfNone)and(FList.Count<1) then begin
        Result:=nil;
        Exit;
      end;
      Result:=InternalPop(0);
    except on e:exception do begin
      e.message:='ITPop: '+e.message;
      raise;
    end;end;
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITPopIC(aNilIfNone:Boolean{=false}; aIntroCallStructData:PIntroCallStructData):IVarsetData;
begin
  InternalLock;
  try
    Result:=ITPop(aNilIfNone);
    if assigned(aIntroCallStructData) then aIntroCallStructData^.OnIntroCallData(aIntroCallStructData^.UserData, Self, Result);
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITPopWakeupIC(aIntroCallStructData:PIntroCallStructData):IVarsetData;
begin
  InternalLock;
  try
    Result:=InternalPopWakeup(Nil);
    if assigned(aIntroCallStructData) then aIntroCallStructData^.OnIntroCallData(aIntroCallStructData^.UserData, Self, Result);
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITPopOfStrIndexEx(const aStrIndex:AnsiString; aRaise:TRaiseStyle=rasDefault):IVarsetData;
begin
  InternalLock;
  try
    try
      Result:=InternalPop(InternalStrIndexToIndex(aStrIndex, aRaise), aRaise);
    except on e:exception do begin
      e.message:='ITPopOfStrIndexEx: '+e.message;
      raise;
    end;end;
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITPopOfIntIndex(aIntIndex:Integer):IVarsetData;
begin
  InternalLock;
  try
    try
      Result:=InternalPop(InternalIntIndexToIndex(aIntIndex));
    except on e:exception do begin
      e.message:='ITPopOfIntIndex: '+e.message;
      raise;
    end;end;
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITPopV(aNilIfNone:Boolean=False):Variant;
  var tmpIVarsetData:IVarsetData;
begin
  InternalLock;
  try
    if (aNilIfNone)and(FList.Count<1) then begin
      Result:=Unassigned;
      Exit;
    end;
    tmpIVarsetData:=ITPop;
    Result:=tmpIVarsetData.ITData;
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITPopVIC(aNilIfNone:Boolean{=false}; aIntroCallStructData:PIntroCallStructData):Variant;
  var tmpIVarsetData:IVarsetData;
begin
  InternalLock;
  try
    if (aNilIfNone)and(FList.Count<1) then begin
      Result:=Unassigned;
      Exit;
    end;
    tmpIVarsetData:=ITPop;
    Result:=tmpIVarsetData.ITData;
    if assigned(aIntroCallStructData) then aIntroCallStructData^.OnIntroCallData(aIntroCallStructData^.UserData, Self, tmpIVarsetData);
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITPopWakeup:IVarsetData;
begin
  InternalLock;
  try
    Result:=InternalPopWakeup(Nil);
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITPopWakeupW(Out aNextTimeWakeup:TDateTime):IVarsetData;
begin
  InternalLock;
  try
    Result:=InternalPopWakeup(@aNextTimeWakeup);
  finally
    InternalUnLock;
  end;
end;

function TVarset.InternalPopWakeup(aNextTimeWakeup:PDateTime):IVarsetData;
  var tmpIVarsetDataView:IVarsetDataView;
      tmpI:Integer;
begin
  Result:=nil;
  for tmpI:=0 to FList.Count-1 do begin
    tmpIVarsetDataView:=ITView[tmpI];
    if tmpIVarsetDataView.ITIsWakeup then begin
      Result:=InternalPop(tmpI);
      Break;
    end;
  end;
  //Ищу NextTimeWakeup
  if Assigned(aNextTimeWakeup) then begin
    aNextTimeWakeup^:=InternalGetNextTimeWakeupAfterTime(nil, 0);
  end;
end;

function TVarset.ITExistsIntIndex(aIntIndex:Integer):Boolean;
  var tmpIVarsetDataView:IVarsetDataView;
      tmpI:Integer;
begin
  InternalLock;
  try
    Result:=False;
    for tmpI:=0 to FList.Count-1 do begin
      tmpIVarsetDataView:=ITView[tmpI];
      if tmpIVarsetDataView.ITIntIndex=aIntIndex then begin
        Result:=True;
        Break;
      end;
    end;
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITExistsStrIndex(const aStrIndex:AnsiString):Boolean;
  var tmpIVarsetDataView:IVarsetDataView;
      tmpI:Integer;
begin
  InternalLock;
  try
    Result:=False;
    for tmpI:=0 to FList.Count-1 do begin
      tmpIVarsetDataView:=ITView[tmpI];
      if InternalCompareStr(tmpIVarsetDataView.ITStrIndex, aStrIndex) then begin
        Result:=True;
        Break;
      end;
    end;
  finally
    InternalUnLock;
  end;
end;


function TVarset.ITClear:Boolean;
begin
  InternalLock;
  try
    Result:=False;
    While FList.Count>0 do begin
      if ITClearOfIndex(FList.Count-1) then result:=true;
    end;
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITClearOfIndex(const aIndex:Integer):Boolean;
  var tmpIVarsetDataView:IVarsetDataView;
begin
  InternalLock;
  try
    Result:=false;
    if (FList.Count<1)or(aIndex<0)or(aIndex>(FList.Count-1)) then begin
      // Список пустой
      if FConfigNoFoundException then raise exception.create('Index='+IntToStr(aIndex)+' is not exist.');
    end else begin
      // список не пустой
      try
        tmpIVarsetDataView:=TVarsetData(FList.Items[aIndex]);
        TVarsetData(FList.Items[aIndex])._Release;
        tmpIVarsetDataView:=nil;//Разбираю
      except end;
      FList.Items[aIndex]:=nil;
      FList.Delete(aIndex);
      InternalCheckCapacity;
      result:=true;
    end;
  finally
    InternalUnLock;
  end;
end;

function TVarset.InternalIntIndexToIndex(aIntIndex:Integer; aRaise:TRaiseStyle=rasDefault):Integer;
  var tmpIVarsetDataView:IVarsetDataView;
      tmpI:Integer;
begin
  Result:=-1;
  for tmpI:=0 to FList.Count-1 do begin
    tmpIVarsetDataView:=ITView[tmpI];
    if tmpIVarsetDataView.ITIntIndex=aIntIndex then begin
      Result:=tmpI;
      Break;
    end;
  end;
  if (Result=-1)and((aRaise=rasTrue)or((aRaise=rasDefault)and(FConfigNoFoundException))) then raise exception.create('IntIndex='''+IntToStr(aIntIndex)+''' is not exist.');
end;

function TVarset.InternalStrIndexToIndex(const aStrIndex:AnsiString; aRaise:TRaiseStyle=rasDefault):Integer;
  var tmpIVarsetDataView:IVarsetDataView;
      tmpI:Integer;
begin
  Result:=-1;
  for tmpI:=0 to FList.Count-1 do begin
    tmpIVarsetDataView:=ITView[tmpI];
    if InternalCompareStr(tmpIVarsetDataView.ITStrIndex, aStrIndex) then begin
      Result:=tmpI;
      Break;
    end;
  end;
  if (Result=-1)and((aRaise=rasTrue)or((aRaise=rasDefault)and(FConfigNoFoundException))) then raise exception.create('StrIndex='''+aStrIndex+''' is not exist.');
end;

function TVarset.ITClearOfIntIndex(const aIntIndex:Integer):Boolean;
begin
  InternalLock;
  try
    result:=ITClearOfIndex(InternalIntIndexToIndex(aIntIndex));
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITClearOfStrIndex(const aStrIndex:AnsiString):Boolean;
begin
  InternalLock;
  try
    Result:=ITClearOfIndex(InternalStrIndexToIndex(aStrIndex));
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITClearChecked:Integer;
  var tmpIVarsetDataView:IVarsetDataView;
      tmpI:Integer;
begin
  InternalLock;
  try
    Result:=0;
    tmpI:=0;
    while FList.Count>0 do begin
      tmpIVarsetDataView:=ITView[tmpI];
      if tmpIVarsetDataView.ITChecked then begin
        ITClearOfIndex(tmpI);
        Inc(Result);
        Dec(tmpI);
      end;
      tmpIVarsetDataView:=nil;
      Inc(tmpI);
      if tmpI>(FList.Count-1) then break;
    end;
  finally
    InternalUnlock;
  end;
end;

procedure TVarset.ITSetAllChecked(aChecked:boolean);
  var tmpI:Integer;
      tmpIVarsetDataView:IVarsetDataView;
begin
  InternalLock;
  try
    for tmpI:=0 to FList.Count-1 do begin
      tmpIVarsetDataView:=ITView[tmpI];
      tmpIVarsetDataView.ITChecked:=aChecked;
      tmpIVarsetDataView:=nil;
    end;
  finally
    InternalUnlock;
  end;
end;

function TVarset.InternalIntIndexToNextIndex(aNext:Boolean; var aIntIndex:Integer):Integer;
  var tmpI:Integer;
      tmpIVarsetDataView:IVarsetDataView;
begin
  InternalLock;
  try
    Result:=Unassigned;
    try
      if aIntIndex<0 then begin
        // Указан не действительный индекс. Возвращаю первый элемент.
        if FList.Count<1 then begin
          // Список пуст.
          Result:=-1;
        end else begin
          // Список не пуст
          if aNext then begin
            Result:=0;
          end else begin
            Result:=FList.Count-1;
          end;
        end;
      end else begin
        // Указан действительный индекс. Возвращаю следующий элемент.
        tmpI:=InternalIntIndexToIndex(aIntIndex, rasFalse);
        if aNext then begin
          if tmpI<(FList.Count-1) then begin
            // Меньше самого последнего элемента
            Result:=tmpI+1;
          end else begin
            // Самый последний элемент, а нужен следующий
            Result:=-1;
          end;
        end else begin
          if tmpI>0 then begin
            // больше первого элемента
            Result:=tmpI-1;
          end else begin
            // Первый, а нужен перед первым
            Result:=-1;
          end;
        end;
      end;
      if Result<0 then begin
        aIntIndex:=-1;
      end else begin
        tmpIVarsetDataView:=TVarsetData(FList.Items[Result]);
        aIntIndex:=tmpIVarsetDataView.ITIntIndex;
      end;
    except on e:exception do begin
      e.message:='InternalIntIndexToNextIndex: '+e.message;
      raise;
    end;end;
  finally
    InternalUnLock;
  end;
end;

function TVarset.InternalStrIndexToNextIndex(aNext:Boolean; var aStrIndex:AnsiString):Integer;
  var tmpI:Integer;
      tmpIVarsetDataView:IVarsetDataView;
begin
  InternalLock;
  try
    Result:=Unassigned;
    try
      if aStrIndex='' then begin
        // Указан не действительный индекс. Возвращаю первый элемент.
        if FList.Count<1 then begin
          // Список пуст.
          Result:=-1;
        end else begin
          // Список не пуст
          if aNext then begin
            Result:=0;
          end else begin
            Result:=FList.Count-1;
          end;
        end;
      end else begin
        // Указан действительный индекс. Возвращаю следующий элемент.
        tmpI:=InternalStrIndexToIndex(aStrIndex, rasFalse);
        if aNext then begin
          if tmpI<(FList.Count-1) then begin
            // Меньше самого последнего элемента
            Result:=tmpI+1;
          end else begin
            // Самый последний элемент, а нужен следующий
            Result:=-1;
          end;
        end else begin
          if tmpI>0 then begin
            // больше первого элемента
            Result:=tmpI-1;
          end else begin
            // Первый, а нужен перед первым
            Result:=-1;
          end;
        end;
      end;
      if Result<0 then begin
        aStrIndex:='';
      end else begin
        tmpIVarsetDataView:=TVarsetData(FList.Items[Result]);
        aStrIndex:=tmpIVarsetDataView.ITStrIndex;
      end;
    except on e:exception do begin
      e.message:='InternalStrIndexToNextIndex: '+e.message;
      raise;
    end;end;
  finally
    InternalUnLock;
  end;
end;

//Steping
function TVarset.ITViewNextGetOfIntIndex(var aIntIndex:Integer):IVarsetDataView;
  var tmpI:Integer;
begin
  InternalLock;
  try
    try
      tmpI:=InternalIntIndexToNextIndex(True, aIntIndex);
      if tmpI<0 then begin
        Result:=nil;
      end else begin
        Result:=ITView[tmpI];
      end;
    except on e:exception do begin
      e.message:='ITViewNextGetOfIntIndex: '+e.message;
      raise;
    end;end;
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITViewPrevGetOfIntIndex(var aIntIndex:Integer):IVarsetDataView;
  var tmpI:Integer;
begin
  InternalLock;
  try
    try
      tmpI:=InternalIntIndexToNextIndex(False, aIntIndex);
      if tmpI<0 then begin
        Result:=nil;
      end else begin
        Result:=ITView[tmpI];
      end;
    except on e:exception do begin
      e.message:='ITViewPrevGetOfIntIndex: '+e.message;
      raise;
    end;end;
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITViewNextDataGetOfIntIndex(var aIntIndex:Integer):Variant;
  var tmpIVarsetDataView:IVarsetDataView;
begin
  InternalLock;
  try
    tmpIVarsetDataView:=ITViewNextGetOfIntIndex(aIntIndex);
    if assigned(tmpIVarsetDataView) then result:=tmpIVarsetDataView.ITData else result:=Unassigned;
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITViewPrevDataGetOfIntIndex(var aIntIndex:Integer):Variant;
  var tmpIVarsetDataView:IVarsetDataView;
begin
  InternalLock;
  try
    tmpIVarsetDataView:=ITViewPrevGetOfIntIndex(aIntIndex);
    if assigned(tmpIVarsetDataView) then result:=tmpIVarsetDataView.ITData else result:=Unassigned;
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITViewNextGetOfStrIndex(var aStrIndex:AnsiString):IVarsetDataView;
  var tmpI:Integer;
begin
  InternalLock;
  try
    try
      tmpI:=InternalStrIndexToNextIndex(True, aStrIndex);
      if tmpI<0 then begin
        Result:=nil;
      end else begin
        Result:=ITView[tmpI];
      end;
    except on e:exception do begin
      e.message:='ITViewNextGetOfStrIndex: '+e.message;
      raise;
    end;end;
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITViewPrevGetOfStrIndex(var aStrIndex:AnsiString):IVarsetDataView;
  var tmpI:Integer;
begin
  InternalLock;
  try
    try
      tmpI:=InternalStrIndexToNextIndex(False, aStrIndex);
      if tmpI<0 then begin
        Result:=nil;
      end else begin
        Result:=ITView[tmpI];
      end;
    except on e:exception do begin
      e.message:='ITViewPrevGetOfStrIndex: '+e.message;
      raise;
    end;end;
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITViewNextDataGetOfStrIndex(var aStrIndex:AnsiString):Variant;
  var tmpIVarsetDataView:IVarsetDataView;
begin
  InternalLock;
  try
    tmpIVarsetDataView:=ITViewNextGetOfStrIndex(aStrIndex);
    if assigned(tmpIVarsetDataView) then result:=tmpIVarsetDataView.ITData else result:=Unassigned;
  finally
    InternalUnLock;
  end;
end;

function TVarset.ITViewPrevDataGetOfStrIndex(var aStrIndex:AnsiString):Variant;
  var tmpIVarsetDataView:IVarsetDataView;
begin
  InternalLock;
  try
    tmpIVarsetDataView:=ITViewPrevGetOfStrIndex(aStrIndex);
    if assigned(tmpIVarsetDataView) then result:=tmpIVarsetDataView.ITData else result:=Unassigned;
  finally
    InternalUnLock;
  end;
end;

procedure TVarset.InternalAppend(aVarset:IVarset; aReassignIntIndexes:Boolean=True; aReassignStrIndexes:Boolean=True);
  var tmpIntIndex:Integer;
      tmpIVarsetDataView:IVarsetDataView;
      tmpIVarsetData:IVarsetData;
begin
  if Not Assigned(aVarset) then Exit;
  tmpIntIndex:=-1;
  while true do begin
    tmpIVarsetDataView:=aVarset.ITViewNextGetOfIntIndex(tmpIntIndex);
    if tmpIntIndex=-1 then break;
    tmpIVarsetData:=TVarsetData.Create;
    tmpIVarsetData.ITAssign(tmpIVarsetDataView);
    if aReassignIntIndexes then begin
      tmpIVarsetData.ITIntIndex:=-1;
    end;
    if aReassignStrIndexes then begin
      tmpIVarsetData.ITStrIndex:='';
    end;
    ITPush(tmpIVarsetData);
  end;
  tmpIVarsetData:=nil;
  tmpIVarsetDataView:=nil;
end;

procedure TVarset.ITAssign(aVarset:IVarset; aReassignIntIndexes:Boolean=False; aReassignStrIndexes:Boolean=False);
begin
  InternalLock;
  try
    try
      ITClear;
      InternalAppend(aVarset, aReassignIntIndexes, aReassignStrIndexes);
    except on e:exception do begin
      e.message:='ITAssign: '+e.message;
      raise;
    end;end;
  finally
    InternalUnLock;
  end;
end;

procedure TVarset.ITAppend(aVarset:IVarset; aReassignIntIndexes:Boolean=True; aReassignStrIndexes:Boolean=True);
begin
  InternalLock;
  try
    try
      InternalAppend(aVarset, aReassignIntIndexes, aReassignStrIndexes);
    except on e:exception do begin
      e.message:='ITAppend: '+e.message;
      raise;
    end;end;
  finally
    InternalUnlock;
  end;
end;

procedure TVarset.ITAppendAndClearChecked(aVarset:IVarset; aReassignIntIndexes:Boolean=True; aReassignStrIndexes:Boolean=True);
begin
  InternalLock;
  try
    try
      InternalAppend(aVarset, aReassignIntIndexes, aReassignStrIndexes);
      ITClearChecked;
    except on e:exception do begin
      e.message:='ITAppendAndClearChecked: '+e.message;
      raise;
    end;end;
  finally
    InternalUnlock;
  end;
end;

end.
