unit USecurityReliable;

interface
  uses UTrayInterface, USecurityReliableTypes;
type
  TSecurityReliable=class(TTrayInterface, ISecurityReliable)
  protected
    FList:IVarset;
  public
    constructor create;
    destructor destroy;override;
    function Add(const aData:AnsiString):integer;virtual;
    function Del(aId:Integer):boolean;virtual;
    function Check(aId:Integer; const aData:AnsiString):boolean;virtual;
  end;

implementation
  uses windows;
  var cnSecurityReliableCounter:integer=0;

constructor TSecurityReliable.create;
begin
  inherited create;
end;

destructor TSecurityReliable.destroy;
begin
  inherited destroy;
end;

Function TSecurityReliable.Add(const aData:AnsiString):integer;
  Var ivHB:Integer;
      iSRC:Integer;
Begin
  Internallock;
  try
    Result:=-1;
    iSRC:=InterLockedIncrement(cnSecurityReliableCounter);
    If (VarType(FSecurityReliable) and varArray)=varArray Then begin
      //уже существует, добавл€ю
      ivHB:=VarArrayHighBound(FSecurityReliable, 1)+1;
      VarArrayRedim(FSecurityReliable, ivHB);
      // out res
      FSecurityReliable[ivHB]:=VarArrayOf([iSRC, vlData]);
      Result:=iSRC;
    end else begin
      // создаю новый
      FSecurityReliable:=VarArrayCreate([0,0], varVariant);
      // out res
      FSecurityReliable[0]:=VarArrayOf([iSRC, vlData]);
      Result:=iSRC;
    end;
  finally
    Internalunlock;
  end;
end;

Function TSecurityReliable.ITSecurityReliableDel(aId:integer):boolean;
  var iI, ivLB, ivHB : Integer;
Begin
  Internallock;
  try
    Result:=False;
    If (VarType(FSecurityReliable) and varArray)<>varArray Then Exit;
    // ..
    ivLB:=VarArrayLowBound(FSecurityReliable, 1);
    ivHB:=VarArrayHighBound(FSecurityReliable, 1);
    For iI:=ivLB to ivHB do begin
      If FSecurityReliable[iI][0]=vlID Then begin
        // Ќашел
        Result:=True;
        If ivLB=ivHB Then begin
          // Ёто единственна€ запись
          FSecurityReliable:=Unassigned;
          Break; // выхожу из поиска
        end else begin
          // Ёто не единственна€ запись
          FSecurityReliable[iI]:=FSecurityReliable[ivHB];
          Dec(ivHB);
          VarArrayRedim(FSecurityReliable, ivHB);
          Break; // выхожу из поиска
        end;
      end;
    end;
  finally
    Internalunlock;
  end;
end;

Function TSecurityReliable.ITSecurityReliableCheck(aId:integer; const aData:AnsiString):boolean;
  var iI:Integer;
Begin
  Internallock;
  try
    Result:=False;
    If (VarType(FSecurityReliable) and varArray)<>varArray Then Exit;
    // ..
    For iI:=VarArrayLowBound(FSecurityReliable, 1) to VarArrayHighBound(FSecurityReliable, 1) do begin
      If FSecurityReliable[iI][0]=vlID Then begin
        // Ќашел Id
        If AnsiString(VarToStr(FSecurityReliable[iI][1]))=AnsiString(vlData) Then begin
          // ѕравильные данные
          Result:=True;
        end else begin
          // Ќе правильные данные
          // Result:=False;
        end;
        Break;
      end;
    end;
  finally
    Internalunlock;
  end;
end;

end.
