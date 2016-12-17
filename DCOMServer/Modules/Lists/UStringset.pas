//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UStringset;

interface
  Uses UITObject, UStringsetTypes;
Type
  TStringset=class(TITObject, IStringset)
  private
    FStringCells:PStringCell;
    FConfigureCheckUnique:boolean;
    FConfigCaseSensitive:Boolean;
    Function InternalCompareStr(Const aStr1, aStr2:AnsiString):Boolean;
    Function InternalGetLastStringCell:PStringCell;
  protected
    function IT_GetConfigureCheckUnique:boolean;
    procedure IT_SetConfigureCheckUnique(Value:boolean);
    function IT_GetConfigCaseSensitive:boolean;
    procedure IT_SetConfigCaseSensitive(Value:boolean);
    function IT_GetAsParamStr:AnsiString;
  public
    constructor Create;
    destructor Destroy; override;
    Procedure ITPush(Const aStr:AnsiString);
    function ITPushR(Const aStr:AnsiString):Boolean;
    Function ITClearOfStr(Const aStr:AnsiString):Boolean;
    Function ITClear:Boolean;
    function ITExist(Const aStr:AnsiString):boolean;
    Property ITConfigureCheckUnique:boolean read IT_GetConfigureCheckUnique write IT_SetConfigureCheckUnique;
    Property ITConfigCaseSensitive:Boolean read IT_GetConfigCaseSensitive write IT_SetConfigCaseSensitive;
    Property ITAsParamStr:AnsiString read IT_GetAsParamStr;
  end;

implementation
  Uses sysutils;
  
constructor TStringset.Create;
begin
  Inherited Create;
  FConfigureCheckUnique:=False;
  FConfigCaseSensitive:=False;
  FStringCells:=Nil;
end;

destructor TStringset.Destroy;
begin
  ITClear;
  Inherited Destroy;
end;

function TStringset.IT_GetConfigureCheckUnique:boolean;
begin
  InternalLock;
  try
    Result:=FConfigureCheckUnique;
  finally
    InternalUnlock;
  end;
end;

procedure TStringset.IT_SetConfigureCheckUnique(Value:boolean);
begin
  InternalLock;
  try
    FConfigureCheckUnique:=Value;
  finally
    InternalUnlock;
  end;
end;

function TStringset.IT_GetConfigCaseSensitive:boolean;
begin
  InternalLock;
  try
    Result:=FConfigCaseSensitive;
  finally
    InternalUnlock;
  end;
end;

procedure TStringset.IT_SetConfigCaseSensitive(Value:boolean);
begin
  InternalLock;
  try
    FConfigCaseSensitive:=Value;
  finally
    InternalUnlock;
  end;
end;

Function TStringset.InternalCompareStr(Const aStr1, aStr2:AnsiString):Boolean;
begin
  If FConfigCaseSensitive Then begin
    Result:=aStr1=aStr2;
  end else begin
    Result:=AnsiUppercase(aStr1)=AnsiUppercase(aStr2);
  end;
end;

Function TStringset.ITClearOfStr(Const aStr:AnsiString):Boolean;
  Var tmpStringCells, tmpStringCellsPrev:PStringCell;
begin
  InternalLock;
  try
    Result:=False;
    tmpStringCellsPrev:=Nil;
    tmpStringCells:=FStringCells;
    While tmpStringCells<>Nil do begin
      If InternalCompareStr(tmpStringCells^.Str, aStr) Then begin
        If Assigned(tmpStringCellsPrev) Then begin
          tmpStringCellsPrev^.Next:=tmpStringCells^.Next;
          Dispose(tmpStringCells);
        end else begin
          FStringCells:=tmpStringCells^.Next;
          Dispose(tmpStringCells);
        end;
        Result:=True;
        Break;
      end;
      tmpStringCellsPrev:=tmpStringCells;
      tmpStringCells:=tmpStringCells^.Next;
    end;
  finally
    InternalUnlock;
  end;
end;

Function TStringset.InternalGetLastStringCell:PStringCell;
begin
  Result:=FStringCells;
  If Assigned(Result) Then begin
    While Result^.Next<>Nil do begin
      Result:=Result^.Next;
    end;
  end;
end;

Procedure TStringset.ITPush(Const aStr:AnsiString);
  Var tmpStringCell:PStringCell;
begin
  InternalLock;
  try
    If FConfigureCheckUnique And(ITExist(aStr)) then Raise Exception.Create(''''+aStr+''' already exist.');
    If Assigned(FStringCells) Then begin
      tmpStringCell:=InternalGetLastStringCell;
      New(tmpStringCell^.Next);
      tmpStringCell:=tmpStringCell^.Next;
    end else begin
      New(FStringCells);
      tmpStringCell:=FStringCells;
    end;
    tmpStringCell^.Next:=Nil;
    tmpStringCell^.Str:=aStr;
    tmpStringCell^.Cnt:=1;
  finally
    InternalUnlock;
  end;
end;

function TStringset.ITPushR(Const aStr:AnsiString):Boolean;
  Var tmpStringCell:PStringCell;
begin
  InternalLock;
  try
    If ITExist(aStr) then begin
      Result:=False;
    end else begin
      If Assigned(FStringCells) Then begin
        tmpStringCell:=InternalGetLastStringCell;
        New(tmpStringCell^.Next);
        tmpStringCell:=tmpStringCell^.Next;
      end else begin
        New(FStringCells);
        tmpStringCell:=FStringCells;
      end;
      tmpStringCell^.Next:=Nil;
      tmpStringCell^.Str:=aStr;
      tmpStringCell^.Cnt:=1;
      Result:=True;
    end;
  finally
    InternalUnlock;
  end;
end;

Function TStringset.ITClear:Boolean;
begin
  InternalLock;
  try
    Result:=False;
    While Assigned(FStringCells) do begin
      ITClearOfStr(FStringCells^.Str);
      Result:=True;
    end;
  finally
    InternalUnlock;
  end;
end;

function TStringset.ITExist(Const aStr:AnsiString):boolean;
  Var tmpStringCells:PStringCell;
begin
  InternalLock;
  try
    Result:=False;
    tmpStringCells:=FStringCells;
    While tmpStringCells<>Nil do begin
      If InternalCompareStr(tmpStringCells^.Str, aStr) Then begin
        Result:=True;
        Break;
      end;
      tmpStringCells:=tmpStringCells^.Next;
    end;
  finally
    InternalUnlock;
  end;
end;

function TStringset.IT_GetAsParamStr:AnsiString;
  Var tmpStringCells:PStringCell;
begin
  InternalLock;
  try
    Result:='';
    tmpStringCells:=FStringCells;
    While tmpStringCells<>Nil do begin
      Result:=Result+tmpStringCells^.Str+';';
      tmpStringCells:=tmpStringCells^.Next;
    end;
  finally
    InternalUnlock;
  end;
end;

end.
