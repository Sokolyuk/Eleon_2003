unit UDMTaskLocalTypes;
//Copyright © 2000-2003 by Dmitry A. Sokolyuk
interface
type
  IDMTaskLocal=interface
  ['{23957AB3-1A0C-4AE2-96A0-EA8E9B8A23D5}']
    procedure SetParam(const aParam:Variant);
    procedure Cancel;
    procedure Terminate;
  end;

implementation

end.
