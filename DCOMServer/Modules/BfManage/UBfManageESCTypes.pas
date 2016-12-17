//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UBfManageESCTypes;

interface
  uses UBfManageTypes, windows;
type
  IBfManageESC=interface(IBfManage)
  ['{ACE27A82-4605-4650-877C-D3E5C440C02D}']
    function Get_RegRootKey:HKEY;
    function Get_RegKeyPath:AnsiString;
    procedure Set_RegRootKey(value:HKEY);
    procedure Set_RegKeyPath(const value:AnsiString);
    property RegRootKey:HKEY read Get_RegRootKey write Set_RegRootKey;
    property RegKeyPath:AnsiString read Get_RegKeyPath write Set_RegKeyPath;
  end;

implementation

end.
