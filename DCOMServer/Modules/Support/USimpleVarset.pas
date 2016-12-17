//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit USimpleVarset;

interface
  Uses Windows, USimpleVarsetTypes, Classes;

Type
  TSimpleVarset=Class(TObject, ISimpleVarset)
  Private
    CSLock:TRTLCriticalSection;
    FRefCount:Integer;
    FList:TList;
  Protected
    {IUnknown}
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
    function _AddRef: Integer; virtual; stdcall;
    function _Release: Integer; virtual; stdcall;
    {Lock}
    Procedure InternalLock;
    Procedure InternalUnLock;
    {..}
    Function IT_GetCount:Cardinal;
  Public
    constructor Create;
    destructor  Destroy; override;
    Procedure ITPush(Const aIntIndex:Integer; Const aData:Variant);
    Function ITPop(Out aIntIndex:Integer):Variant;
    Function ITPopOfIntIndex(Const aIntIndex:Integer):Variant;
    function ITUpdateOfIntIndex(Const aIntIndex:Integer; Const aData:Variant):Boolean;
    function ITClear:Boolean;
    function ITClearOfIntIndex(Const aIntIndex:Integer):Boolean;
    Property ITCount:Cardinal{Integer} read IT_GetCount;
  End;

  TSimpleVarsetData=class(TObject)
  private
    FIntIndex:Integer;
    FData:Variant;
  public
    constructor Create;
    destructor Destroy; override;
    Property IntIndex:Integer read FIntIndex write FIntIndex;
    Property Data:Variant read FData write FData;
  end;


Implementation
  uses SysUtils, Variants;

constructor TSimpleVarsetData.Create;
begin
  FIntIndex:=-1;
  FData:=Unassigned;
  Inherited Create;
end;

destructor TSimpleVarsetData.Destroy;
begin
  VarClear(FData);
  Inherited Destroy;
end;

Constructor TSimpleVarset.Create;
begin
  InitializeCriticalSection(CSLock);
  FRefCount:=0;
  FList:=TList.Create;
  Inherited Create;
end;

Destructor  TSimpleVarset.Destroy;
begin
  try
    ITClear;
    FreeAndNil(FList);
  except end;
  DeleteCriticalSection(CSLock);
  Inherited Destroy;
end;

{ TSimpleVarset.IUnknown }
function TSimpleVarset.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then Result := S_OK else Result := E_NOINTERFACE;
end;

function TSimpleVarset._AddRef: Integer;
begin
  Result:=InterLockedIncrement(FRefCount);
end;

function TSimpleVarset._Release: Integer;
begin
  Result:=InterLockedDecrement(FRefCount);
  if Result = 0 then
    Destroy;
end;

{ TSimpleVarset.Lock }
Procedure TSimpleVarset.InternalLock;
  Var iTimeOut:Integer;
begin
  iTimeOut:=0;
  While Not TryEnterCriticalSection(CSLock) do begin
    inc(iTimeOut, 133);
    If iTimeOut>900000 then begin {15мин}
      // не разлочился
      Raise Exception.Create('TSimpleVarset.InternalLock(CSLock.LockCount='+IntToStr(CSLock.LockCount)+', CSLock.OwningThread='+IntToStr(CSLock.OwningThread)+').');
    end;
    sleep(133);
  end;
end;

Procedure TSimpleVarset.InternalUnLock;
begin
  LeaveCriticalSection(CSLock);
end;

Function TSimpleVarset.IT_GetCount:Cardinal;
begin
  InternalLock;
  Try
    Result:=FList.Count;
  Finally
    InternalUnlock;
  End;
end;

Procedure TSimpleVarset.ITPush(Const aIntIndex:Integer; Const aData:Variant);
  Var tmpTSimpleVarsetData:TSimpleVarsetData;
begin
  InternalLock;
  Try
    tmpTSimpleVarsetData:=TSimpleVarsetData.Create;
    try
      tmpTSimpleVarsetData.IntIndex:=aIntIndex;
      tmpTSimpleVarsetData.Data:=aData;
      FList.Add(tmpTSimpleVarsetData);
    except
      Try
        FreeAndNil(tmpTSimpleVarsetData);
      Except end;
      Raise;
    end;
  Finally
    InternalUnlock;
  End;
end;

Function TSimpleVarset.ITPop(Out aIntIndex:Integer):Variant;
  Var tmpTSimpleVarsetData:TSimpleVarsetData;
begin
  InternalLock;
  Try
    If FList.Count=0 Then raise exception.create('List.Count=0.');
    tmpTSimpleVarsetData:=FList.Items[0];
    FList.Delete(0);
    Result:=tmpTSimpleVarsetData.Data;
    aIntIndex:=tmpTSimpleVarsetData.IntIndex;
    FreeAndNil(tmpTSimpleVarsetData);
  Finally
    InternalUnlock;
  End;
end;

Function TSimpleVarset.ITPopOfIntIndex(Const aIntIndex:Integer):Variant;
  Var tmpTSimpleVarsetData:TSimpleVarsetData;
      tmpI:Integer;
      tmpBoolean:Boolean;
begin
  InternalLock;
  Try
    If FList.Count=0 Then raise exception.create('List.Count=0.');
    tmpBoolean:=False;
    For tmpI:=0 to FList.Count-1 do begin
      tmpTSimpleVarsetData:=FList.Items[tmpI];
      If tmpTSimpleVarsetData.IntIndex=aIntIndex Then begin
        tmpBoolean:=True;
        Break;
      end;
    end;
    If Not tmpBoolean Then Raise Exception.Create('IntIndex='+IntToStr(aIntIndex)+' not found.');
    FList.Delete(tmpI);
    Result:=tmpTSimpleVarsetData.Data;
    FreeAndNil(tmpTSimpleVarsetData);
  Finally
    InternalUnlock;
  End;
end;

function TSimpleVarset.ITUpdateOfIntIndex(Const aIntIndex:Integer; Const aData:Variant):Boolean;
  Var tmpTSimpleVarsetData:TSimpleVarsetData;
      tmpI:Integer;
begin
  InternalLock;
  Try
    Result:=False;
    If FList.Count=0 Then begin
      //raise exception.create('List.Count=0.');
      Exit;
    end;  
    For tmpI:=0 to FList.Count-1 do begin
      tmpTSimpleVarsetData:=FList.Items[tmpI];
      If tmpTSimpleVarsetData.IntIndex=aIntIndex Then begin
        tmpTSimpleVarsetData.Data:=aData;
        Result:=True;
        Break;
      end;
    end;
  Finally
    InternalUnlock;
  End;
end;

function TSimpleVarset.ITClear:Boolean;
  Var tmpTSimpleVarsetData:TSimpleVarsetData;
begin
  InternalLock;
  Try
    Result:=False;
    While FList.Count>0 do begin
      tmpTSimpleVarsetData:=FList.Items[0];
      FList.Delete(0);
      FreeAndNil(tmpTSimpleVarsetData);
      Result:=True;
    End;
  Finally
    InternalUnlock;
  End;
end;

function TSimpleVarset.ITClearOfIntIndex(Const aIntIndex:Integer):Boolean;
  Var tmpTSimpleVarsetData:TSimpleVarsetData;
      tmpI:Integer;
      tmpBoolean:Boolean;
begin
  InternalLock;
  Try
    tmpBoolean:=False;
    For tmpI:=0 to FList.Count-1 do begin
      tmpTSimpleVarsetData:=FList.Items[tmpI];
      If tmpTSimpleVarsetData.IntIndex=aIntIndex Then begin
        tmpBoolean:=True;
        Break;
      end;
    end;
    If Not tmpBoolean Then begin
      Result:=False;
      Exit;
    end;
    FList.Delete(tmpI);
    FreeAndNil(tmpTSimpleVarsetData);
    Result:=True;
  Finally
    InternalUnlock;
  End;
end;

end.
