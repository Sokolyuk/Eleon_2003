//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UPackCPErrors;

interface
  Uses UIObject, UPackCPErrorsTypes, UVarsetTypes, Windows;
Type
  TPackCPErrors=class(TIObject, IPackCPErrors)
  private
    FPackCPErrors:IVarset;
  protected
    function Get_AsVariant:Variant;virtual;
    procedure Set_AsVariant(const Value:Variant);virtual;
    function Get_LowBound:Integer;virtual;
    function Get_HighBound:Integer;virtual;
    function Get_Count:Integer;virtual;
  public
    constructor Create;
    destructor Destroy;override;
    procedure Clear;virtual;
    function CheckError(aStep:Integer; aPMessage:PAnsiString; aPHelpContext:PInteger; aWithRaise:Boolean=False):Boolean;virtual;
    property AsVariant:Variant read Get_AsVariant write Set_AsVariant;
    property LowBound:Integer read Get_LowBound;
    property HighBound:Integer read Get_HighBound;
    property Count:Integer read Get_Count;
    procedure Add(aStep:Integer; const aMessage:AnsiString; aHelpContext:Integer=0);virtual;
    function Clone:IPackCPErrors;virtual;
  end;

implementation
  uses UVarset, SysUtils, UErrorConsts{$IFNDEF VER130}, Variants{$ENDIF};
constructor TPackCPErrors.Create;
begin
  FPackCPErrors:=TVarset.Create;
  FPackCPErrors.ITConfigIntIndexAssignable:=True;
  FPackCPErrors.ITConfigCheckUniqueIntIndex:=True;
  FPackCPErrors.ITConfigCheckUniqueStrIndex:=False;
  FPackCPErrors.ITConfigCaseSensitive:=False;
  FPackCPErrors.ITConfigNoFoundException:=True;
  inherited Create;
  Clear;
end;

destructor TPackCPErrors.Destroy;
begin
  Clear;
  FPackCPErrors:=nil;
  inherited Destroy;
end;

procedure TPackCPErrors.Clear;
begin
  FPackCPErrors.ITClear;
end;

function TPackCPErrors.Get_AsVariant:Variant;
  var tmpI, tmpData:Integer;
      tmpIntIndex:Integer;
      tmpIVarsetDataView:IVarsetDataView;
begin
  try
    if FPackCPErrors.ITCount=0 then begin
      Result:=Unassigned;
    end else begin
      Result:=VarArrayCreate([LowBound, HighBound], varVariant);
      tmpI:=LowBound;
      tmpIntIndex:=-1;
      while true do begin
        tmpIVarsetDataView:=FPackCPErrors.ITViewNextGetOfIntIndex(tmpIntIndex);
        if tmpIntIndex=-1 then break;
        if tmpI>HighBound then raise exception.createFmtHelp(cserInternalError, ['Disparity array bound'], cnerInternalError);
        tmpData:=tmpIVarsetDataView.ITData;
        if tmpData=0 then begin
          Result[tmpI]:=VarArrayOf([tmpIVarsetDataView.ITIntIndex, tmpIVarsetDataView.ITStrIndex]);
        end else begin
          Result[tmpI]:=VarArrayOf([tmpIVarsetDataView.ITIntIndex, tmpIVarsetDataView.ITStrIndex, tmpData]);
        end;  
        Inc(tmpI);
      end;
      tmpIVarsetDataView:=nil;
      if tmpI-1<>HighBound then raise exception.createFmtHelp(cserInternalError, ['Disparity array bound(2)'], cnerInternalError);
    end;
  except on e:exception do begin
    e.message:='Get_AsVariant: '+e.message;
    raise;
  end;end;    
end;

procedure TPackCPErrors.Set_AsVariant(const Value:Variant);
  var tmpIVarsetData:IVarsetData;
      tmpI:Integer;
      tmpivLB, tmpivHB:Integer;
begin
  try
    Clear;
    if VarIsArray(Value) then begin
      tmpivLB:=VarArrayLowBound(Value, 1);
      tmpivHB:=VarArrayHighBound(Value, 1);
      for tmpI:=tmpivLB to tmpivHB do begin
        tmpIVarsetData:=TVarsetData.Create;
        tmpIVarsetData.ITIntIndex:=Value[tmpI][0];
        tmpIVarsetData.ITStrIndex:=Value[tmpI][1];
        if VarArrayHighBound(Value[tmpI], 1)=2 then begin
          tmpIVarsetData.ITData:=Value[tmpI][2];
        end else begin
          tmpIVarsetData.ITData:=0;//HelpIndex not assigned
        end;
        FPackCPErrors.ITPush(tmpIVarsetData);
      end;
      tmpIVarsetData:=nil;
    end;
  except on e:exception do begin
    Clear;
    e.message:='Set_AsVariant: '+e.message;
    raise;
  end;end;
end;

function TPackCPErrors.Get_LowBound:Integer;
begin
  result:=0;
end;

function TPackCPErrors.Get_HighBound:Integer;
begin
  Result:=FPackCPErrors.ITCount-1;
end;

function TPackCPErrors.Get_Count:Integer;
begin
  Result:=FPackCPErrors.ITCount;
end;

function TPackCPErrors.CheckError(aStep:Integer; aPMessage:PAnsiString; aPHelpContext:PInteger; aWithRaise:Boolean=False):Boolean;
  var tmpIVarsetDataView:IVarsetDataView;
      tmpMessage:AnsiString;
      tmpHelpContext:Integer;
begin
  Result:=FPackCPErrors.ITExistsIntIndex(aStep);
  if Result then begin
    tmpIVarsetDataView:=FPackCPErrors.ITViewOfIntIndex[aStep];
    if Not Assigned(tmpIVarsetDataView) then raise exception.createFmt(cserInternalError, ['tmpIVarsetDataView not assigned.']);
    tmpMessage:=tmpIVarsetDataView.ITStrIndex;
    tmpHelpContext:=tmpIVarsetDataView.ITData;
    if Assigned(aPHelpContext) then aPHelpContext^:=tmpHelpContext;
    if tmpMessage='' then tmpMessage:='No message.';
    if aWithRaise then raise exception.createHelp(tmpMessage, tmpHelpContext) else if Assigned(aPMessage) then aPMessage^:=tmpMessage;
  end else begin
    if Assigned(aPMessage) then aPMessage^:='';
    if Assigned(aPHelpContext) then aPHelpContext^:=0;
  end;
end;

procedure TPackCPErrors.Add(aStep:Integer; const aMessage:AnsiString; aHelpContext:Integer=0);
  var tmpIVarsetData:TVarsetData;
begin
  tmpIVarsetData:=TVarsetData.Create;
  tmpIVarsetData.ITIntIndex:=aStep;
  tmpIVarsetData.ITStrIndex:=aMessage;
  tmpIVarsetData.ITData:=aHelpContext;
  FPackCPErrors.ITPush(tmpIVarsetData);
end;

function TPackCPErrors.Clone:IPackCPErrors;
begin
  result:=TPackCPErrors.Create;
  Result.AsVariant:=AsVariant;
end;

end.
