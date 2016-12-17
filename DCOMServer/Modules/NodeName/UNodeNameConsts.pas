//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UNodeNameConsts;

interface
  uses UNodeNameTypes;
const//PEGAS.NODE:1.ID:1
  csNodeDelimiter{:Char}='.';
  csValueDelimiter{:Char}=':';
  cnNodeDelimiter:TNodeDelimiter=[csNodeDelimiter, csValueDelimiter];
  csNodePGS:AnsiString='PEGAS';
  csNodeEMS:AnsiString='NODE';
  csNodeESC:AnsiString='ID';
implementation
end.
