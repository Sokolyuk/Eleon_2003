//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UPackPDErrorTypes;

interface
Type
  IPackPDError=Interface
  ['{EF7F9499-1D91-419F-ABDB-93EA3CA2FBA8}']
    function Get_AsVariant:Variant;
    procedure Set_AsVariant(Const Value:Variant);
    //..
    procedure Clear;
    function Clone:IPackPDError;
    property AsVariant:Variant read Get_AsVariant write Set_AsVariant;
  End;

implementation

end.
