unit UDCTaskLocalTypes;
//Copyright © 2000-2003 by Dmitry A. Sokolyuk
interface
  uses DTask_TLB;
type
  IDCTaskLocal=interface
  ['{0380CD86-85FB-4CBB-985D-03520676A06F}']
    procedure OnBegin(aDMTask:IDMTask; const aParam:Variant; out aResParam:Variant);
    procedure OnEnd(aResultCode:integer; const aParam:Variant);
    procedure OnEndError(const aMessage:AnsiString; aHelpContext:integer; const aParam:Variant);
    procedure OnProcess(const aParam:Variant; out aResParam:Variant);
    procedure OnProcessError(const aMessage:AnsiString; aHelpContext:integer; const aParam:Variant; out aResParam:Variant);
  end;

implementation

end.
