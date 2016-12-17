unit UASMList;

interface
  Uses UTrayInterfaceBase, UASMListTypes, UVarset, UVarsetTypes, UTrayInterfaceTypes;
Type
  TASMList=Class(TTrayInterfaceBase, IASMList)
  Private
    FList:IVarset;
  Protected
    procedure InternalFinal;override;
  Protected
    function IT_GetList:IVarset;
  Public
    Constructor Create;
    Destructor Destroy;override;
    Function ITASMAdd(aObject:TObject):IVarsetDataView;
    Function ITASMDelOfAddr(aObject:TObject):Boolean;
    Function ITASMDelOfIntIndex(aIntIndex:Integer):Boolean;
    Function ITASMDisconnectAll:Integer;
    Property ITList:IVarset read IT_GetList;
  End;

implementation
  Uses SysUtils, ComObj, ActiveX;

Constructor TASMList.Create;
begin
  Inherited Create;
  FList:=TVarset.Create;
end;

Destructor TASMList.Destroy;
begin
  FList:=Nil;
  Inherited Destroy;
end;

function TASMList.IT_GetList:IVarset;
begin
  InternalLock;
  try
    Result:=FList;
  finally
    InternalUnlock;
  end;
end;

Function TASMList.ITASMAdd(aObject:TObject):IVarsetDataView;
begin
  InternalLock;
  try
    Result:=FList.ITPushV(Integer(Pointer(aObject)));
  finally
    InternalUnlock;
  end;
end;

Function TASMList.ITASMDelOfAddr(aObject:TObject):Boolean;
  Var tmpIntIndex:Integer;
      tmpIVarsetDataView:IVarsetDataView;
      tmpPointer:Pointer;
begin
  InternalLock;
  try
    Result:=False;
    try
      tmpIntIndex:=-1;
      While true do begin
        tmpIVarsetDataView:=FList.ITViewNextGetOfIntIndex(tmpIntIndex);
        If tmpIntIndex=-1 then break;
        tmpPointer:=Pointer(Integer(tmpIVarsetDataView.ITData));
        If tmpPointer=Pointer(aObject) Then begin
          FList.ITClearOfIntIndex(tmpIntIndex);
          Result:=True;
          break;
        end;
      end;
      tmpIVarsetDataView:=Nil;
    except on e:exception do begin
      e.message:='ITASMDelOfAddr: '+e.message;
      raise;
    end;end;
  finally
    InternalUnlock;
  end;
end;

Function TASMList.ITASMDelOfIntIndex(aIntIndex:Integer):Boolean;
begin
  InternalLock;
  try
    Result:=False;
    try
      Result:=FList.ITClearOfIntIndex(aIntIndex);
    except on e:exception do begin
      e.message:='ITASMDelOfIntIndex: '+e.message;
      raise;
    end;end;
  finally
    InternalUnlock;
  end;
end;

Function TASMList.ITASMDisconnectAll:Integer;
  Var tmpIUnknown:IUnknown;
      tmpIntIndex:Integer;
      tmpIVarsetDataView:IVarsetDataView;
      tmpPointer:Pointer;
begin
  InternalLock;
  try
    Result:=0;
    tmpIntIndex:=-1;
    while true do begin
      tmpIVarsetDataView:=FList.ITViewNextGetOfIntIndex(tmpIntIndex);
      If tmpIntIndex=-1 then break;
      tmpPointer:=Pointer(Integer(tmpIVarsetDataView.ITData));
      tmpIUnknown:=TComObject(tmpPointer);
      CoDisconnectObject(tmpIUnknown, 0);
      tmpIUnknown:=Nil;//FList.ITClearOfIntIndex(tmpIntIndex);
      Inc(Result);
    end;
    tmpIVarsetDataView:=Nil;
  finally
    InternalUnlock;
  end;
end;

procedure TASMList.InternalFinal;
begin
  ITASMDisconnectAll;
end;

end.
