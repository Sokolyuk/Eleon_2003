//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit USimpleVarsetTypes;

Interface
{$IFDEF VER140}uses Variants;{$ENDIF}

Type
  ISimpleVarset=Interface
  ['{C042185A-8ACF-47FC-9ECF-409899C5C0EC}']
    Function IT_GetCount:Cardinal;
    Procedure ITPush(Const aIntIndex:Integer; Const aData:Variant);
    Function ITPop(Out aIntIndex:Integer):Variant;
    Function ITPopOfIntIndex(Const aIntIndex:Integer):Variant;
    function ITUpdateOfIntIndex(Const aIntIndex:Integer; Const aData:Variant):Boolean;
    function ITClear:Boolean;
    function ITClearOfIntIndex(Const aIntIndex:Integer):Boolean;
    Property ITCount:Cardinal read IT_GetCount;
  end;

implementation

end.
