unit UClusterChip;

interface
  uses UClusterChipTypes;
type
  TClusterChip=class
  protected
    FPChipList:PChipList;//Cluster
    FCluster:TClusterChip;//Chip
    FOnChipEvent:TOnChipEvent;
    FOnChipEventI:TOnChipEventI;
    FOnChipEventV:TOnChipEventV;
    FOnGetChipType:TOnGetChipTypeEvent;
    FOwner:TObject;//ClusterChip
  protected
    function InternalGetLastChipListElement:PChipList;virtual;
    function Get_Cluster:TClusterChip;virtual;
    procedure Set_Cluster(Value:TClusterChip);virtual;
    function Get_ChipType:Integer;virtual;
  public
    constructor Create;
    destructor Destroy;override;
    function OwnerGetInterface(const IID:TGUID; out Obj):Boolean;virtual;
    procedure RegisterChip(Value:TClusterChip);virtual;//Cluster
    procedure UnregisterChip(Value:TClusterChip);virtual;
    procedure ViewRegisterChip(aOnView:TOnViewEvent);virtual;
    procedure GetRegisterChipByOne(var aPChipList:PChipList; aChipType:Integer);virtual;
    property ChipList:PChipList read FPChipList;
    function SendChipEvent(aChipType:Integer; Sender:TObject; aParam:Integer):boolean;virtual;
    function SendChipEventI(aChipType:Integer; Sender:TObject; aParam:IUnknown):boolean;virtual;
    function SendChipEventV(aChipType:Integer; Sender:TObject; const aParam:variant):boolean;virtual;
    property Cluster:TClusterChip read Get_Cluster write Set_Cluster;//Chip
    property ChipType:Integer read Get_ChipType;
    property OnGetChipType:TOnGetChipTypeEvent read FOnGetChipType write FOnGetChipType;
    property OnChipEvent:TOnChipEvent read FOnChipEvent write FOnChipEvent;
    property OnChipEventI:TOnChipEventI read FOnChipEventI write FOnChipEventI;
    property OnChipEventV:TOnChipEventV read FOnChipEventV write FOnChipEventV;
    property Owner:TObject read FOwner write FOwner;//ClusterChip
  end;

implementation
  uses SysUtils{$IFDEF VER130}, windows{$ENDIF};

constructor TClusterChip.Create;
begin
  //Cluster
  FPChipList:=nil;
  //Chip
  FCluster:=nil;
  FOnChipEvent:=nil;
  FOnChipEventI:=nil;
  FOnChipEventV:=nil;
  FOnGetChipType:=nil;
  //ClusterChip
  FOwner:=nil;
  Inherited Create;
end;

destructor TClusterChip.Destroy;
begin
  //Cluster
  while assigned(FPChipList) do begin
    if FPChipList^.Chip Is TClusterChip then begin
      TClusterChip(FPChipList^.Chip).Set_Cluster(nil);
    end;
  end;
  //Chip
  if assigned(FCluster) then begin
    FCluster.UnregisterChip(Self);
    FCluster:=nil;
  end;
  Inherited Destroy;
end;

procedure TClusterChip.UnregisterChip(Value:TClusterChip);
  var tmpChipList, tmpChipListPrev:PChipList;
begin
  try
    if not (Value is TClusterChip) then Raise Exception.Create('Value not TClusterChip.');
    tmpChipListPrev:=nil;
    tmpChipList:=FPChipList;
    while tmpChipList<>nil do begin
      if Pointer(tmpChipList^.Chip)=Pointer(Value) then begin
        if assigned(tmpChipListPrev) then tmpChipListPrev^.Next:=tmpChipList^.Next else FPChipList:=tmpChipList^.Next;
        Dispose(tmpChipList);
        Break;
      end;
      tmpChipListPrev:=tmpChipList;
      tmpChipList:=tmpChipList^.Next;
    end;
  except on e:exception do begin
    e.message:='UnregisterChip: '+e.message;
    raise;
  end;end;
end;

function TClusterChip.InternalGetLastChipListElement:PChipList;
begin
  Result:=FPChipList;
  if assigned(Result) then begin
    while Result^.Next<>nil do begin
      Result:=Result^.Next;
    end;
  end;
end;

procedure TClusterChip.RegisterChip(Value:TClusterChip);
  var tmpChipList:PChipList;
begin
  try
    if not (Value is TClusterChip) then raise exception.create('Value not TClusterChip.');
    if assigned(FPChipList) then begin
      tmpChipList:=InternalGetLastChipListElement;
      New(tmpChipList^.Next);
      tmpChipList:=tmpChipList^.Next;
    end else begin
      New(FPChipList);
      tmpChipList:=FPChipList;
    end;
    tmpChipList^.Next:=nil;
    tmpChipList^.Chip:=Value;
  except on e:exception do begin
    e.message:='RegisterChip: '+e.message;
    raise;
  end;end;
end;

procedure TClusterChip.ViewRegisterChip(aOnView:TOnViewEvent);
  var tmpPChipList:PChipList;
begin
  if not assigned(aOnView) then Exit;
  tmpPChipList:=FPChipList;
  while assigned(tmpPChipList) do begin
    if tmpPChipList^.Chip is TClusterChip then begin
      aOnView(tmpPChipList^.Chip, TClusterChip(tmpPChipList^.Chip).Owner);
    end;
    tmpPChipList:=tmpPChipList^.Next;
  end;
end;

function TClusterChip.Get_Cluster:TClusterChip;
begin
  Result:=FCluster;
end;

procedure TClusterChip.Set_Cluster(Value:TClusterChip);
begin
  if Value<>FCluster then begin
    if assigned(FCluster) then FCluster.UnregisterChip(Self);
    if assigned(Value) then Value.RegisterChip(Self);
    FCluster:=Value;
  end;
end;

function TClusterChip.Get_ChipType:Integer;
begin
  if assigned(FOnGetChipType) then begin
    Result:=FOnGetChipType;
  end else begin
    Result:=0;
  end;
end;

function TClusterChip.SendChipEvent(aChipType:Integer; Sender:TObject; aParam:Integer):boolean;
  var tmpPChipList:PChipList;
      tmpTOnChipEvent:TOnChipEvent;
      tmpChipType:Integer;
begin
  tmpPChipList:=FPChipList;
  result:=false;
  while assigned(tmpPChipList) do begin
    if tmpPChipList^.Chip is TClusterChip then begin
      tmpChipType:=TClusterChip(tmpPChipList^.Chip).ChipType and aChipType;
      if tmpChipType<>0 then begin
        tmpTOnChipEvent:=TClusterChip(tmpPChipList^.Chip).OnChipEvent;
        if assigned(tmpTOnChipEvent) then result:=tmpTOnChipEvent(tmpChipType, Sender, aParam);
      end;
    end;
    if result then break;//если result=true, значит событие отработало и больше его не рассылаю.
    tmpPChipList:=tmpPChipList^.Next;
  end;
end;

function TClusterChip.SendChipEventI(aChipType:Integer; Sender:TObject; aParam:IUnknown):boolean;
  var tmpPChipList:PChipList;
      tmpTOnChipEventI:TOnChipEventI;
      tmpChipType:Integer;
begin
  tmpPChipList:=FPChipList;
  result:=false;
  while assigned(tmpPChipList) do begin
    if tmpPChipList^.Chip is TClusterChip then begin
      tmpChipType:=TClusterChip(tmpPChipList^.Chip).ChipType and aChipType;
      if tmpChipType<>0 then begin
        tmpTOnChipEventI:=TClusterChip(tmpPChipList^.Chip).OnChipEventI;
        if assigned(tmpTOnChipEventI) then result:=tmpTOnChipEventI(tmpChipType, Sender, aParam);
      end;
    end;
    if result then break;//если result=true, значит событие отработало и больше его не рассылаю.
    tmpPChipList:=tmpPChipList^.Next;
  end;
end;

function TClusterChip.SendChipEventV(aChipType:Integer; Sender:TObject; const aParam:variant):boolean;
  var tmpPChipList:PChipList;
      tmpTOnChipEventV:TOnChipEventV;
      tmpChipType:Integer;
begin
  tmpPChipList:=FPChipList;
  result:=false;
  while assigned(tmpPChipList) do begin
    if tmpPChipList^.Chip is TClusterChip then begin
      tmpChipType:=TClusterChip(tmpPChipList^.Chip).ChipType and aChipType;
      if tmpChipType<>0 then begin
        tmpTOnChipEventV:=TClusterChip(tmpPChipList^.Chip).OnChipEventV;
        if assigned(tmpTOnChipEventV) then result:=tmpTOnChipEventV(tmpChipType, Sender, aParam);
      end;
    end;
    if result then break;//если result=true, значит событие отработало и больше его не рассылаю.
    tmpPChipList:=tmpPChipList^.Next;
  end;
end;

procedure TClusterChip.GetRegisterChipByOne(var aPChipList:PChipList; aChipType:Integer);
begin
  if not assigned(aPChipList) then aPChipList:=FPChipList else aPChipList:=aPChipList^.Next;
  while assigned(aPChipList) do begin
    if (aPChipList^.Chip is TClusterChip)and((TClusterChip(aPChipList^.Chip).ChipType and aChipType)<>0) then begin
      break;
    end;
    aPChipList:=aPChipList^.Next;
  end;
end;

function TClusterChip.OwnerGetInterface(const IID:TGUID; out Obj):Boolean;
  var tmpIUnknown:IUnknown;
begin
  result:=assigned(FOwner);
  if result then begin
    result:=(FOwner.GetInterface(IID, Obj))and(assigned(pointer(Obj)));
    if (not result)and(FOwner.GetInterface(IUnknown, tmpIUnknown))and(assigned(tmpIUnknown)) then result:=(tmpIUnknown.QueryInterface(IID, Obj)=S_OK)and(assigned(pointer(Obj)));
  end;
end;

end.
